generate_weapons_table()
{
    level.zm_core_maps = [ 
        "zm_island", "zm_genesis", "zm_factory", "zm_castle", "zm_asylum",
        "zm_temple", "zm_sumpf", "zm_stalingrad", "zm_prototype", "zm_moon",
        "zm_zod", "zm_tomb", "zm_theater"
    ];
    
    level.zbr_contact_grenade = getweapon("contact_grenade");
    zm_weapons::add_zombie_weapon("contact_grenade", undefined, undefined, 0, undefined, undefined, 0, undefined, false, "");
    zm_utility::include_weapon("contact_grenade", true);
    zm_utility::register_tactical_grenade_for_level("contact_grenade");
    register_box_weapon("contact_grenade");

    level.zbr_emp_grenade_zm = getweapon("zbr_emp_grenade");

    if(ZBR_ENABLE_EMP)
    {
        zm_weapons::add_zombie_weapon("zbr_emp_grenade", undefined, undefined, 0, undefined, undefined, 0, undefined, false, "");
        zm_utility::include_weapon("zbr_emp_grenade", true);
        zm_utility::register_tactical_grenade_for_level("zbr_emp_grenade");
        register_box_weapon("zbr_emp_grenade");
    }

    level.zbr_knife = getweapon("knife_zbr");
    zm_weapons::add_zombie_weapon("knife_zbr", undefined, undefined, 0, undefined, undefined, 0, undefined, false, "");
    zm_utility::include_weapon("knife_zbr", true);
    //zm_utility::register_melee_weapon_for_level("knife_zbr");
    register_box_weapon("knife_zbr", "knife_zbr");
    
    // a baseline scalar for all weapons that are un-scaled by default
    level.f_unregistered_weapon_scalar ??= 1.0;

    // a scalar applied to all AAT damage used for maps with slower TTK values
    level.f_aat_scalar ??= 1.0;

    level.balance_adjust_easy_scalar ??= 1.0;

    level.b_should_expect_aat_hitmarkers = true;

    level.weapon_scalars_table = [];
    level.hd_scalars_table = [];
    level.head_scalars_table = [];
    level.zbr_weapon_callbacks_table = [];

    register_weapon_scalar("sniper_powerbolt", "sniper_powerbolt_upgraded", 2.0);
    register_weapon_scalar("sniper_fastsemi", "sniper_fastsemi_upgraded", 0.8);
    register_weapon_scalar("sniper_fastbolt", "sniper_fastbolt_upgraded", 1.2 * 1.5);
    register_weapon_hd_modifier("sniper_powerbolt", "sniper_powerbolt_upgraded", 0.7);
    register_weapon_hd_modifier("sniper_fastbolt", "sniper_fastbolt_upgraded", 0.7);
    register_weapon_hd_modifier("sniper_fastsemi", "sniper_fastsemi_upgraded", 0.7);
    register_weapon_head_modifier("sniper_powerbolt", "sniper_powerbolt_upgraded", 0.7);
    register_weapon_head_modifier("sniper_fastbolt", "sniper_fastbolt_upgraded", 0.7);

    register_weapon_scalar("smg_sten", "smg_sten_upgraded", 2.5);
    register_weapon_scalar("smg_versatile", "smg_versatile_upgraded", 2.5);
    register_weapon_scalar("smg_standard", "smg_standard_upgraded", 3.0);
    register_weapon_scalar("smg_fastfire", "smg_fastfire_upgraded", 2);
    register_weapon_scalar("smg_capacity", "smg_capacity_upgraded", 2.5);
    register_weapon_scalar("smg_ak74u", "smg_ak74u_upgraded", 2);
    register_weapon_scalar("smg_mp40", "smg_mp40_upgraded", 3.3);
    register_weapon_scalar("smg_mp40_1940", "smg_mp40_1940_upgraded", 3.3);
    register_weapon_scalar("smg_longrange", "smg_longrange_upgraded", 4);
    register_weapon_scalar("smg_ppsh", "smg_ppsh_upgraded", 2);
    register_weapon_scalar("smg_thompson", "smg_thompson_upgraded", 5);
    fn_burst_smg = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(min(iDamage, 150 * 2.25) * 6 * get_round_damage_boost());
    };
    register_weapon_calculator("smg_burst", fn_burst_smg);
    register_weapon_calculator("smg_burst_upgraded", fn_burst_smg);
    register_weapon_hd_modifier("smg_sten", "smg_sten_upgraded", 0.5);
    register_weapon_hd_modifier("smg_versatile", "smg_versatile_upgraded", 0.5);
    register_weapon_hd_modifier("smg_standard", "smg_standard_upgraded", 0.5);
    register_weapon_hd_modifier("smg_fastfire", "smg_fastfire_upgraded", 0.75);
    register_weapon_hd_modifier("smg_capacity", "smg_capacity_upgraded", 0.5);
    register_weapon_hd_modifier("smg_ak74u", "smg_ak74u_upgraded", 0.5);
    register_weapon_hd_modifier("smg_mp40", "smg_mp40_upgraded", 0.5);
    register_weapon_hd_modifier("smg_mp40_1940", "smg_mp40_1940_upgraded", 0.5);
    register_weapon_hd_modifier("smg_longrange", "smg_longrange_upgraded", 0.5);
    register_weapon_hd_modifier("smg_ppsh", "smg_ppsh_upgraded", 0.5);
    register_weapon_hd_modifier("smg_thompson", "smg_thompson_upgraded", 0.5);
    register_weapon_head_modifier("smg_sten", "smg_sten_upgraded", 0.66);
    register_weapon_head_modifier("smg_fastfire", "smg_fastfire_upgraded", 0.66);
    register_weapon_head_modifier("smg_mp40", "smg_mp40_upgraded", 0.66);
    register_weapon_head_modifier("smg_mp40_1940", "smg_mp40_1940_upgraded", 0.66);
    register_weapon_head_modifier("smg_thompson", "smg_thompson_upgraded", 0.66);
    register_weapon_head_modifier("smg_ppsh", "smg_ppsh_upgraded", 0.5);

    register_weapon_scalar("shotgun_semiauto", "shotgun_semiauto_upgraded", 1.0);
    register_weapon_scalar("shotgun_pump", "shotgun_pump_upgraded", 1.3);
    register_weapon_scalar("shotgun_precision", "shotgun_precision_upgraded", 2.2);
    register_weapon_hd_modifier("shotgun_precision", "shotgun_precision_upgraded", 0.7);
    register_weapon_scalar("shotgun_fullauto", "shotgun_fullauto_upgraded", 1.0);
    register_weapon_scalar("shotgun_energy", "shotgun_energy_upgraded", 50, 160);
    register_weapon_scalar("pistol_shotgun_dw_upgraded", "pistol_shotgun_lh_upgraded", 0.3);

    register_weapon_scalar("pistol_burst", "pistol_burst_upgraded", 3, 2);
    register_weapon_scalar("pistol_fullauto", "pistol_fullauto_upgraded", 5);
    register_weapon_scalar("pistol_energy", "pistol_energy_upgraded", 20, 50);
    register_weapon_scalar("pistol_m1911_upgraded", "pistol_m1911h_upgraded", 20);
    register_weapon_scalar("pistol_revolver38_upgraded", "pistol_revolver38lh_upgraded", 20);
    register_weapon_scalar("pistol_standard_upgraded", "pistol_standardlh_upgraded", 20);
    register_weapon_scalar("pistol_c96_upgraded", undefined, 55);
    register_weapon_head_modifier("pistol_fullauto", "pistol_fullauto_upgraded", 0.2);

    register_weapon_scalar("lmg_slowfire", "lmg_slowfire_upgraded", 2);
    register_weapon_scalar("lmg_light", "lmg_light_upgraded", 2.5);
    register_weapon_scalar("lmg_heavy", "lmg_heavy_upgraded", 1.25);
    register_weapon_scalar("lmg_cqb", "lmg_cqb_upgraded", 1.4);
    register_weapon_scalar("lmg_rpk", "lmg_rpk_upgraded", 1.25);
    register_weapon_scalar("lmg_mg08", "lmg_mg08_upgraded", 1.5);

    register_weapon_scalar("ar_standard", "ar_standard_upgraded", 2.0);
    register_weapon_scalar("ar_marksman", "ar_marksman_upgraded", 9, 6.0);
    register_weapon_scalar("ar_longburst", "ar_longburst_upgraded", 2.5);
    register_weapon_scalar("ar_damage", "ar_damage_upgraded", 2.1);
    register_weapon_scalar("ar_cqb", "ar_cqb_upgraded", 2.2);
    register_weapon_scalar("ar_accurate", "ar_accurate_upgraded", 1.9);
    register_weapon_scalar("ar_garand", "ar_garand_upgraded", 2);
    register_weapon_scalar("ar_famas", "ar_famas_upgraded", 1.9);
    register_weapon_scalar("ar_peacekeeper", "ar_peacekeeper_upgraded", 2.5);
    register_weapon_scalar("ar_stg44", "ar_stg44_upgraded", 3);
    register_weapon_scalar("ar_m16", "ar_m16_upgraded", 6);
    register_weapon_hd_modifier("ar_garand", "ar_garand_upgraded", 0.5);
    register_weapon_hd_modifier("ar_famas", "ar_famas_upgraded", 0.5);
    register_weapon_hd_modifier("ar_m14", "ar_m14_upgraded", 0.5);
    register_weapon_hd_modifier("ar_stg44", "ar_stg44_upgraded", 0.5);
    register_weapon_hd_modifier("ar_m16", "ar_m16_upgraded", 0.25);
    register_weapon_head_modifier("ar_m16", "ar_m16_upgraded", 0.25);
    register_weapon_head_modifier("ar_damage", "ar_damage_upgraded", 0.65);
    register_weapon_head_modifier("ar_peacekeeper", "ar_peacekeeper_upgraded", 0.55);
    register_weapon_hd_modifier("ar_damage", "ar_damage_upgraded", 0.75);

    register_weapon_scalar("launcher_standard", "launcher_standard_upgraded", 90, 180);
    register_weapon_scalar("launcher_multi", "launcher_multi_upgraded", 24, 45);
    register_weapon_scalar("microwavegundw", "microwavegundw_upgraded", 1125, 2625);
    register_weapon_scalar("microwavegunlh", "microwavegunlh_upgraded", 1125, 2625);

    register_weapon_scalar("raygun_mark2", "raygun_mark2_upgraded", 25, 45);
    register_weapon_scalar("raygun_mark3", "raygun_mark3_upgraded", 18, 55);
    register_weapon_hd_modifier("raygun_mark3", "raygun_mark3_upgraded", 0.5);

    fn_special_crossbow = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(min(iDamage, 700 * 3) * 4);
    };
    register_weapon_calculator("special_crossbow_dw_upgraded", fn_special_crossbow);
    register_weapon_calculator("special_crossbowlh_upgraded", fn_special_crossbow);

    register_weapon_scalar("dragon_gauntlet_flamethrower", undefined, 2.5);

    register_weapon_calculator("sentinel_turret", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(CLAMPED_ROUND_NUMBER * 200);
    });
    register_weapon_calculator("helicopter_gunner_turret_primary", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(CLAMPED_ROUND_NUMBER * 500);
    });
}

register_weapon_scalar(str_weapon, str_upgrade, scalar_base = 1.0f, scalar_upgrade = scalar_base)
{
    if(!isdefined(level.weapon_scalars_table))
    {
        level.weapon_scalars_table = [];
    }
    if(isdefined(str_weapon))
    {
        level.weapon_scalars_table[str_weapon] = level.balance_adjust_easy_scalar * scalar_base;
    }
    if(isdefined(str_upgrade))
    {
        level.weapon_scalars_table[str_upgrade] = level.balance_adjust_easy_scalar * scalar_upgrade;
    }
}

register_weapon_hd_modifier(str_weapon, str_upgrade, scalar_base = 1.0f, scalar_upgrade = scalar_base)
{
    if(!isdefined(level.hd_scalars_table))
    {
        level.hd_scalars_table = [];
    }
    if(isdefined(str_weapon))
    {
        level.hd_scalars_table[str_weapon] = scalar_base;
    }
    if(isdefined(str_upgrade))
    {
        level.hd_scalars_table[str_upgrade] = scalar_upgrade;
    }
}

register_weapon_head_modifier(str_weapon, str_upgrade, scalar_base = 1.0f, scalar_upgrade = scalar_base)
{
    if(!isdefined(level.head_scalars_table))
    {
        level.head_scalars_table = [];
    }
    if(isdefined(str_weapon))
    {
        level.head_scalars_table[str_weapon] = scalar_base;
    }
    if(isdefined(str_upgrade))
    {
        level.head_scalars_table[str_upgrade] = scalar_upgrade;
    }
}

register_weapon_calculator(str_weapon, fn_calcdmg)
{
    if(!isdefined(level.weapon_calc_table))
    {
        level.weapon_calc_table = [];
    }
    if(isfunctionptr(fn_calcdmg) && isdefined(str_weapon))
    {
        level.weapon_calc_table[str_weapon] = fn_calcdmg;
    }
}

register_weapon_damage_callback(str_weapon, str_upgrade, fn_callback)
{
    level.zbr_weapon_callbacks_table ??= [];
    
    if(str_weapon is defined)
    {
        level.zbr_weapon_callbacks_table[str_weapon] = fn_callback;
    }
    
    if(str_upgrade is defined)
    {
        level.zbr_weapon_callbacks_table[str_upgrade] = fn_callback;
    }
}

// changes when the calculation is run for this weapon scalar, being before custom logic (short circuit) or after (combinatatory)
register_weapon_postcalc(str_weapon, post = false)
{
    if(!isdefined(str_weapon))
    {
        return;
    }
    if(!isdefined(level.weapon_settings))
    {
        level.weapon_settings = [];
    }
    if(!isdefined(level.weapon_settings[str_weapon]))
    {
        level.weapon_settings[str_weapon] = spawnStruct();
    }
    level.weapon_settings[str_weapon].postcalc = post;
}

weapon_is_postcalc(str_weapon = "")
{
    return isdefined(level.weapon_settings) && isdefined(level.weapon_settings[str_weapon]) && isdefined(level.weapon_settings[str_weapon].postcalc) && level.weapon_settings[str_weapon].postcalc;
}

register_box_weapon(str_weapon, str_upgrade)
{
    if(!isdefined(str_weapon))
    {
        return;
    }
    level.zombie_include_weapons[getweapon(str_weapon)] = 1;
    zm_weapons::add_zombie_weapon(str_weapon, str_upgrade, undefined, 950, undefined, undefined, 950, false, false, "");
    level.zombie_include_weapons[getweapon(str_weapon)] = 1;
    level.zombie_weapons[getweapon(str_weapon)].is_in_box = 1;

    if(isdefined(str_upgrade))
    {
        level.zombie_weapons[getweapon(str_weapon)].upgrade = getweapon(str_upgrade);
        level.zombie_weapons_upgraded[getweapon(str_upgrade)] = getweapon(str_weapon);
    }
}

remove_box_weapon(str_weapon, str_upgrade)
{
    if(!isdefined(str_weapon))
    {
        return;
    }

    level.zombie_include_weapons[getweapon(str_weapon)] = undefined;
    level.zombie_weapons[getweapon(str_weapon)].is_in_box = 0;

    if(isdefined(str_upgrade))
    {
        level.zombie_weapons[getweapon(str_weapon)].upgrade = undefined;
        level.zombie_weapons_upgraded[getweapon(str_upgrade)] = getweapon(str_weapon);
    }
}

debug_log_weapon_stats(w_weapon)
{
    if(!isdefined(w_weapon) || !IsWeapon(w_weapon))
    {
        return;
    }

    w_weapon = w_weapon.rootweapon;

    dev_winfo_update(w_weapon);
    dev_winfo_log_prop(w_weapon.name, "name");
    dev_winfo_log_prop(w_weapon.weapclass, "weapclass");
    dev_winfo_log_prop(w_weapon.type, "type");
    dev_winfo_log_prop(w_weapon.isdualwield, "isdualwield");
    dev_winfo_log_prop(w_weapon.firetype, "firetype");
    dev_winfo_log_prop(w_weapon.firetime, "firetime");
    dev_winfo_log_prop(w_weapon.shotcount, "shotcount");
    dev_winfo_log_prop(w_weapon.burstCount, "burstCount");
    dev_winfo_log_prop(w_weapon.maxdist, "maxdist");

    dev_winfo_log_prop(w_weapon.ismeleeweapon, "ismeleeweapon");
    dev_winfo_log_prop(w_weapon.meleetime, "meleetime");
    dev_winfo_log_prop(w_weapon.meleedamage, "meleedamage");
    
    dev_winfo_log_prop(w_weapon.isheroweapon, "isheroweapon");

    dev_winfo_log_prop(w_weapon.clipsize, "clipsize");
    dev_winfo_log_prop(w_weapon.startammo, "startammo");
    dev_winfo_log_prop(w_weapon.maxammo, "maxammo");
    
    // dev_winfo_log_prop(w_weapon.isbulletweapon, "isbulletweapon");
    // dev_winfo_log_prop(w_weapon.isgrenadeweapon, "isgrenadeweapon");
    // dev_winfo_log_prop(w_weapon.isprojectileweapon, "isprojectileweapon");
    // dev_winfo_log_prop(w_weapon.isheroweapon, "isheroweapon");
    // dev_winfo_log_prop(w_weapon.firetype, "firetype");
    // dev_winfo_log_prop(w_weapon.isboltaction, "isboltaction");
    // dev_winfo_log_prop(w_weapon.isfullauto, "isfullauto");
    // dev_winfo_log_prop(w_weapon.issemiauto, "issemiauto");
    // dev_winfo_log_prop(w_weapon.isburstfire, "isburstfire");
    // dev_winfo_log_prop(w_weapon.ismeleeweapon, "ismeleeweapon");
    // dev_winfo_log_prop(w_weapon.meleetime, "meleetime");
}

debug_weapon_dps_info(w_weapon, damage_cat)
{
    if(!isdefined(level.dev_winfo[w_weapon.name]) || !isdefined(level.dev_winfo[w_weapon.name][damage_cat]))
    {
        return "0,0,0,0";
    }
    // calculate attacks per second
    aps = 1;
    if(w_weapon.ismeleeweapon)
    {
        aps = 1 / (w_weapon.meleetime ? w_weapon.meleetime : 1);
    }
    else if(w_weapon.isburstfire)
    {
        aps = (1 / (w_weapon.isboltaction ? 1 : (w_weapon.firetime ? w_weapon.firetime : 1))) * (w_weapon.shotcount ? w_weapon.shotcount : 1);
    }
    else if(w_weapon.isboltaction) // bolt time is kinda messy
    {
        aps = (w_weapon.isprojectileweapon ? 1 : w_weapon.shotcount);
    }
    else
    {
        aps = (1 / (w_weapon.firetime ? w_weapon.firetime : 1)) * (w_weapon.shotcount ? w_weapon.shotcount : 1);
    }

    if(w_weapon.isdualwield)
    {
        aps *= 2;
    }

    dtap_apsmod = 4;
    // calculate doubletap modifiers
    if(w_weapon.ismeleeweapon)
    {
        dtap_apsmod = 2;
    }
    else if(w_weapon.type != "bullet")
    {
        dtap_apsmod = 2;
    }

    body_dps = int(aps * int(level.dev_winfo[w_weapon.name][damage_cat]));
    body_dpsi = body_dps * INSTAKILL_DMG_PVP_MULTIPLIER;
    body_dpsdt = body_dps * dtap_apsmod;
    body_dpsdti = body_dpsdt * INSTAKILL_DMG_PVP_MULTIPLIER;

    return (body_dps) + "," + (body_dpsi) + "," + (body_dpsdt) + "," + (body_dpsdti);
}

debug_print_weapon_stats(w_weapon)
{
    if(!isdefined(w_weapon) || !IsWeapon(w_weapon))
    {
        return;
    }

    w_weapon = w_weapon.rootweapon;

    if(!isdefined(level.dev_winfo[w_weapon.name]))
    {
        self iPrintLnBold("missing information...");
        return;
    }

    compiler::nprintln("WEAPON INFO DUMP: " + (w_weapon.name ?? "unknown") + " | " + MakeLocalizedString(w_weapon.displayname ?? "unknown"));
    compiler::nprintln("========================================");
    compiler::nprintln("");

    foreach(prop, propval in level.dev_winfo[w_weapon.name])
    {
        compiler::nprintln("\t." + prop + ": " + propval);
    }

    compiler::nprintln("");
    compiler::nprintln("\tCalculated DPS Statistics: ");
    compiler::nprintln("");

    // then calculate dps for head and chest at max efficiency

    compiler::nprintln("\t\tDamage per second (chest, +i, +dt, +idt): " + debug_weapon_dps_info(w_weapon, "damage.chest"));
    compiler::nprintln("\t\tDamage per second (head, +i, +dt, +idt): " + debug_weapon_dps_info(w_weapon, "damage.head"));
    compiler::nprintln("");

    compiler::nprintln("========================================");
}

dev_winfo_update(weapon)
{
    if(!isdefined(level.dev_winfo))
    {
        level.dev_winfo = [];
    }

    weapon = weapon.rootweapon;

    if(!isdefined(level.dev_winfo[weapon.name]))
    {
        level.dev_winfo[weapon.name] = [];
    }

    level.dev_winfo_current = weapon;
}

dev_winfo_log_prop_w(weapon, prop = "undefined", propname)
{
    if(!isdefined(weapon) || !IsWeapon(weapon))
    {
        return;
    }

    weapon = weapon.rootweapon;

    if(!isdefined(level.dev_winfo))
    {
        level.dev_winfo = [];
    }

    if(!isdefined(level.dev_winfo[weapon.name]))
    {
        level.dev_winfo[weapon.name] = [];
    }

    level.dev_winfo[weapon.name][propname] = prop;
}

dev_winfo_log_prop(prop = "undefined", propname)
{
    if(!isdefined(level.dev_winfo_current) || !IsWeapon(level.dev_winfo_current))
    {
        return;
    }

    dev_winfo_log_prop_w(level.dev_winfo_current, prop, propname);
}

dev_weapon_info_console()
{
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");
    self thread dev_weapon_info_cmd_emit();
    for(;;)
    {
        self waittill("weapon_change");
        debug_log_weapon_stats(self getCurrentWeapon());
    }
}

dev_weapon_info_cmd_emit()
{
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");
    for(;;)
    {
        if(self adsButtonPressed() && self meleeButtonPressed() && !self useButtonPressed())
        {
            debug_print_weapon_stats(self getCurrentWeapon());
            while(self adsButtonPressed() || self meleeButtonPressed())
            {
                wait 0.05;
            }
        }

        if(self adsButtonPressed() && self meleeButtonPressed() && self useButtonPressed())
        {
            compiler::nprintln("name,b,bi,bdt,bdti,h,hi,hdt,hdti,class,type,issniper,isbolt,isdw,firetype,clipsize,maxammo");
            foreach(str_weap, props in level.dev_winfo)
            {
                w_weapon = getweapon(str_weap);
                compiler::nprintln(w_weapon.name + "," + debug_weapon_dps_info(w_weapon, "damage.chest") + "," + debug_weapon_dps_info(w_weapon, "damage.head") + "," + w_weapon.weapclass + "," + w_weapon.type + "," + w_weapon.issniperweapon + "," + w_weapon.isboltaction + "," + (w_weapon.isdualwield ? "dw" : "single") + "," + w_weapon.firetype + "," + w_weapon.clipsize + "," + w_weapon.maxammo);
            }
            while(self adsButtonPressed() || self meleeButtonPressed() || self useButtonPressed())
            {
                wait 0.05;
            }
        }
        wait 0.05;
    }
}