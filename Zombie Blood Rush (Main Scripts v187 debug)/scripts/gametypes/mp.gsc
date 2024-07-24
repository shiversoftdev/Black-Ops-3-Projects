autoexec mp_auto()
{
    if(strstartswith(tolower(getdvarstring("mapname")), "mp_"))
    {
        compiler::spawndynamic(${
"spawnflags" "19"
"sm_active_count_min" "3"
"sm_active_count_max" "3"
"script_dropammo" "1"
"model" "c_zom_test_body1"
"engageMinDist" "250"
"engageMaxDist" "700"
"_color" "1 0.25 0"
"SPAWNER" "1"
"script_noteworthy" "zombie_spawner"
"script_forcespawn" "1"
"script_disable_bleeder" "1"
"origin" "10000 10000 10000"
"export" "1"
"count" "9999"
"angles" "0 270 0"
"SCRIPT_FORCESPAWN" "1"
"MAKEROOM" "1"
"ALERTONSPAWN" "0"
"classname" "actor_spawner_zm_usermap_zombie"
"guid" "08D91360"
}$);
    }
    mp_setup_map();
}

// detour zm_spawner<scripts\zm\_zm_spawner.gsc>::do_zombie_rise(spot)
// {
//     self thread [[ function() => 
//     {
//         self endon(#death);
//         if(!isalive(level.tracking_zombie))
//         {
//             level.tracking_zombie = self;
//         }
//         else
//         {
//             return;
//         }
//         for(;;)
//         {
//             iPrintLnBold(self.origin);
//             wait 0.25;
//         }
//     }]]();
//     self [[ @zm_spawner<scripts\zm\_zm_spawner.gsc>::do_zombie_rise ]](spot);
// }

mp_auto_spawns()
{
    if(strstartswith(tolower(getdvarstring("mapname")), "mp_"))
    {
        model = spawn("script_origin", (0, 0, 0));
        foreach(point in arraycombine(struct::get_array("info_player_start", "targetname"), struct::get_array("mp_dm_spawn", "targetname"), true, false))
        {
            model.origin = point.origin;
            
            b_allowed = true;
            foreach(vol in getentarray("trigger_out_of_bounds", "classname"))
            {
                if(model istouching(vol))
                {
                    b_allowed = false;
                    break;
                }
            }

            if(!b_allowed)
            {
                continue;
            }

            if(!isdefined(level.master_spawner))
            {
                level.master_spawner = spawnstruct();
                level.master_spawner.angles = point.angles;
                level.master_spawner.origin = util::ground_position(point.origin, 5000, 1, undefined, true, true);
                point.disabled = true;

                foreach(ent in getentarray("zombie_spawner", "script_noteworthy"))
                {
                    ent.origin = level.master_spawner.origin;
                    ent.agnles = level.master_spawner.angles;
                }

                continue;
            }

            stru = spawnStruct();
            stru.origin = util::ground_position(point.origin, 5000, 1, undefined, true, true);
            stru.angles = point.angles;
            stru.script_noteworthy = "riser_location";
            stru.script_string = "find_flesh";
            stru.targetname = "start_zone_spawners";

            if(DEBUG_ZSPAWNS_NP)
            {
                debug_text(stru.origin + (0, 0, 15), "riser_location", (0, 1, 0), 1.0, 0.3, 999999999);
                debug_sphere(stru.origin, 10, (0, 1, 0), 0.5, 999999999, 0);
            }

            struct::createstruct(stru);
        }
        model delete();
        zm_zonemgr::reinit_zone_spawners();
    }
}

// level.default_start_location
mp_setup_map() // autoexec BTW
{
    switch(tolower(getdvarstring("mapname")))
    {
        case "mp_crucible":
            mp_crucible();
        break;

        case "mp_nuketown_x":
            mp_nuketown_x();
        break;

        case "zm_tomb":
            mp_register_perk("specialty_doubletap2", "p7_zm_vending_doubletap2", (-168.05, -2674.45, 342.125), (0, -77.738 + 90, 0), "zclassic_perks_tomb");
        break;

        case "zm_cosmodrome":
            mp_register_perk("specialty_doubletap2", "p7_zm_vending_doubletap2", (615.641, 1481.18, -168.323), (0, 0 + 90, 0), "zclassic_perks_default");
        break;
    }
}


mp_nuketown_x()
{
    mp_register_perk("specialty_armorvest", "p7_zm_vending_jugg", (-580.388, 433.6, -60.88), (0, -17 + 90, 0));
}

mp_crucible()
{
    mp_register_perk("specialty_armorvest", "p7_zm_vending_jugg", (-1483.48, -504.347, 40.125), (0, 90, 0));
    mp_register_perk("specialty_doubletap2", "p7_zm_vending_doubletap2", (2037.33, 123.491, -86.1182), (0, 270, 0));
    mp_register_perk("specialty_fastreload", "p7_zm_vending_sleight", (485.835, -817.289, 125.637), (0, 0, 0));
    mp_register_perk("specialty_widowswine", "p7_zm_vending_widows_wine", (-1367.67, 100.907, 44.125), (0, 180, 0));
    mp_register_perk("specialty_staminup", "p7_zm_vending_marathon", (971.645, 953.505, 56.2097), (0, 180, 0));
    mp_register_perk("specialty_quickrevive", "p7_zm_vending_revive", (730.963, 2742.02, 102), (0, 270, 0));

    thread mp_crucible_threaded();
}

mp_crucible_threaded()
{
    gm_os_init();
    level.gm_os_upgrade2 = true; // needed for aats
    
    level.zbr_start_weapon = getweapon("pistol_energy");
    level.zbr_start_weapon_upgraded = getweapon("pistol_energy_upgraded");

    level.idgun_weapons ??= [];
    level.idgun_weapons[level.idgun_weapons.size] = getweapon("idgun_1");
    level.idgun_weapons[level.idgun_weapons.size] = getweapon("idgun_upgraded_1");

    register_box_weapon("idgun_1", "idgun_upgraded_1");

    // gm_os_register_weapon(str_weapon, str_upgrade, undefined, rarityclass = GM_OS_RARITY_NORMAL, pricebias = 1.0, round_enable = 1, b_is_wonder_weapon = false);
    // gm_os_register_weapon("smg_standard", "smg_standard_upgraded", undefined, GM_OS_RARITY_NORMAL, 1.0, 1, false);
    gm_os_register_weapon("ar_longburst",           "ar_longburst_upgraded",            gm_os_aat("ar_longburst_upgraded"),             GM_OS_RARITY_NORMAL, 1.0, 1, false);
    gm_os_register_weapon("smg_capacity",           "smg_capacity_upgraded",            gm_os_aat("smg_capacity_upgraded"),             GM_OS_RARITY_NORMAL, 1.0, 1, false);
    gm_os_register_weapon("smg_burst",              "smg_burst_upgraded",               gm_os_aat("smg_burst_upgraded"),                GM_OS_RARITY_NORMAL, 1.0, 1, false);
    gm_os_register_weapon("lmg_heavy",              "lmg_heavy_upgraded",               gm_os_aat("lmg_heavy_upgraded"),                GM_OS_RARITY_NORMAL, 1.0, 1, false);
    gm_os_register_weapon("sniper_fastbolt",        "sniper_fastbolt_upgraded",         gm_os_aat("sniper_fastbolt_upgraded"),          GM_OS_RARITY_NORMAL, 1.0, 1, false);
    gm_os_register_weapon("pistol_energy",          "pistol_energy_upgraded",           gm_os_aat("pistol_energy_upgraded"),            GM_OS_RARITY_NORMAL, 1.0, 1, false);
    gm_os_register_weapon("shotgun_semiauto",       "shotgun_semiauto_upgraded",        gm_os_aat("shotgun_semiauto_upgraded"),         GM_OS_RARITY_NORMAL, 1.0, 1, false);
    gm_os_register_weapon("zod_riotshield",         "zod_riotshield_upgraded",          gm_os_aat("zod_riotshield_upgraded"),           GM_OS_RARITY_RARE, 1.0, 1, false);
    gm_os_register_weapon("knife_zbr",              "bowie_knife",                      gm_os_aat("bowie_knife"),                       GM_OS_RARITY_VERYRARE, 1.0, 1, false);


    gm_os_register_weapon("ar_accurate",            "ar_accurate_upgraded",             gm_os_aat("ar_accurate_upgraded"),              GM_OS_RARITY_NORMAL, 1.0, 10, false);
    gm_os_register_weapon("smg_standard",           "smg_standard_upgraded",            gm_os_aat("smg_standard_upgraded"),             GM_OS_RARITY_NORMAL, 1.0, 10, false);
    gm_os_register_weapon("lmg_slowfire",           "lmg_slowfire_upgraded",            gm_os_aat("lmg_slowfire_upgraded"),             GM_OS_RARITY_NORMAL, 1.0, 10, false);
    gm_os_register_weapon("sniper_powerbolt",       "sniper_powerbolt_upgraded",        gm_os_aat("sniper_powerbolt_upgraded"),         GM_OS_RARITY_NORMAL, 1.0, 10, false);
    gm_os_register_weapon("smg_longrange",          "smg_longrange_upgraded",           gm_os_aat("smg_longrange_upgraded"),            GM_OS_RARITY_NORMAL, 1.0, 10, false);
    gm_os_register_weapon("shotgun_fullauto",       "shotgun_fullauto_upgraded",        gm_os_aat("shotgun_fullauto_upgraded"),         GM_OS_RARITY_NORMAL, 1.0, 10, false);
    gm_os_register_weapon("bouncingbetty",          undefined,                          undefined,                                      GM_OS_RARITY_VERYRARE, 1.0, 10, false);
    gm_os_register_weapon("zbr_emp_grenade",        undefined,                          undefined,                                      GM_OS_RARITY_VERYRARE, 1.0, 10, false);
    gm_os_register_weapon("octobomb",               "octobomb_upgraded",                undefined,                                      GM_OS_RARITY_VERYRARE, 1.0, 10, false);

    gm_os_register_weapon("ray_gun",                "ray_gun_upgraded",                 gm_os_aat("ray_gun_upgraded"),                  GM_OS_RARITY_VERYRARE, 1.0, 1, false);
    gm_os_register_weapon("idgun_1",                "idgun_upgraded_1",                 gm_os_aat("idgun_upgraded_1"),                  GM_OS_RARITY_ULTRARARE, 1.2, 10, false);
    gm_os_register_weapon("tesla_gun",              "tesla_gun_upgraded",               gm_os_aat("tesla_gun_upgraded"),                GM_OS_RARITY_ULTRARARE, 1.2, 10, false);
    gm_os_register_weapon("annihilator",            undefined,                          undefined,                                      GM_OS_RARITY_ULTRARARE, 1.2, 10, false);

    gm_os_register_weapon("ar_peacekeeper",         "ar_peacekeeper_upgraded",          gm_os_aat("ar_peacekeeper_upgraded"),           GM_OS_RARITY_RARE, 1.0, 1, false);
    gm_os_register_weapon("ar_damage",              "ar_damage_upgraded",               gm_os_aat("ar_damage_upgraded"),                GM_OS_RARITY_RARE, 1.0, 1, false);
    gm_os_register_weapon("smg_versatile",          "smg_versatile_upgraded",           gm_os_aat("smg_versatile_upgraded"),            GM_OS_RARITY_RARE, 1.0, 1, false);
    gm_os_register_weapon("smg_ppsh",               "smg_ppsh_upgraded",                gm_os_aat("smg_ppsh_upgraded"),                 GM_OS_RARITY_RARE, 1.0, 1, false);
    gm_os_register_weapon("ar_garand",              "ar_garand_upgraded",               gm_os_aat("ar_garand_upgraded"),                GM_OS_RARITY_RARE, 1.0, 1, false);

    

    level flag::wait_till("initial_blackscreen_passed");
    gm_os_mark_spawns(array((-172.196,-3293.48,142.125), (455.032,-2158.39,142.125), (-272.333,-927.237,210.125), (350.44,448.988,210.125), (1374.34,90.392,81.0885), (161.897,2572.11,153.5), (410.148,1183.23,146.125), (-1257.87,849.399,90.125), (-543.217,-740.899,82.125), (-1433.07,-961.548,90.125), (-600.752,-2556.47,142.125), (120.601,-375.698,197.5), (-411.091,285.521,298.733)));
    thread gm_os_run();

    delete_perk_by_names("specialty_electriccherry", "vending_electriccherry");
    delete_perk_by_names("specialty_deadshot", "vending_deadshot");
    delete_perk_by_names("specialty_additionalprimaryweapon", "vending_additionalprimaryweapon");
}

mp_register_perk(specialty, model, origin, angles, override_string = "zclassic_perks_start_room")
{
    stru = spawnStruct();
    stru.script_noteworthy = specialty;
    stru.targetname = "zm_perk_machine";
    stru.script_string = override_string;
    stru.model = model;
    stru.origin = origin;
    stru.angles = angles;
    struct::createstruct(stru);
}

detour raps<scripts\shared\vehicles\_raps.gsc>::detonate(attacker = self)
{
	self stopsounds();
	self dodamage(int(CLAMPED_ROUND_NUMBER * 1000), self.origin, attacker, self, "none", "MOD_EXPLOSIVE", 0, self.turretweapon);
}

detour raps<scripts\shared\vehicles\_raps.gsc>::detonate_damage_monitored(enemy, weapon)
{
	self.selfdestruct = 1;
	self dodamage(int(CLAMPED_ROUND_NUMBER * 1000), self.origin, enemy, self, "none", "MOD_EXPLOSIVE", 0, self.turretweapon);
}