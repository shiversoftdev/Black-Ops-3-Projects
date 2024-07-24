#define ORIGIN_OOB = (-100000, -100000, -100000);

// #pragma lazystrings(on)

init_custom_map()
{
    #region DLC 1 (1.09)
    register_custom_map("zm_xmas_rust",         serious::zm_xmas_rust_init,         serious::zm_xmas_rust_weapons,          undefined,                              undefined,                              undefined);
    register_custom_map("zm_daybreak",          serious::zm_daybreak_init,          serious::zm_daybreak_weapons,           serious::zm_daybreak_plrwpns,           serious::zm_daybreak_threaded,          undefined);
    register_custom_map("zm_kyassuruz",         serious::zm_kyassuruz_init,         serious::zm_kyassuruz_weapons,          undefined,                              serious::zm_kyassuruz_threaded,         undefined);
    register_custom_map("zm_cove",              serious::zm_cove_init,              serious::zm_cove_weapons,               undefined,                              serious::zm_cove_threaded,              undefined);
    register_custom_map("zm_mori",              serious::zm_mori_init,              undefined,                              undefined,                              serious::zm_mori_threaded,              undefined);
    register_custom_map("zm_alcatraz_island",   serious::zm_alcatraz_island_init,   serious::zm_alcatraz_island_weapons,    serious::zm_alcatraz_island_spawned,    serious::zm_alcatraz_island_threaded,   serious::zm_alcatraz_island_roundnext);
    register_custom_map("zm_ski_resort",        serious::zm_ski_resort_init,        serious::zm_ski_resort_weapons,         serious::zm_ski_resort_spawned,         serious::zm_ski_resort_threaded,        undefined);
    register_custom_map("zm_log_kowloon",       serious::zm_log_kowloon_init,       serious::zm_log_kowloon_weapons,        serious::zm_log_kowloon_spawned,        serious::zm_log_kowloon_threaded,       undefined);
    
    // partial support
    register_custom_map("zm_whomp_n64_ez",      serious::zm_whomp_n64_ez_init,      serious::zm_whomp_n64_ez_weapons,       undefined,                              serious::zm_whomp_n64_ez_threaded);
    register_custom_map("zm_mario64_v2",        serious::zm_mario64_v2_init,        serious::zm_mario64_v2_weapons,         undefined,                              serious::zm_mario64_v2_threaded,        serious::zm_mario64_v2_roundnext);
    register_custom_map("zm_town",              serious::zm_town_reimagined_init,   serious::zm_town_reimagined_weapons,    undefined,                              undefined,                              undefined);
    #endregion

    #region DLC 2 (1.11)
    
    register_custom_map("zm_survival",          undefined,                          serious::zm_survival_weapons,           undefined,                              serious::zm_survival_threaded,          undefined);
    register_custom_map("zm_velka",             serious::zm_velka_init,             serious::zm_velka_weapons,              undefined,                              serious::zm_velka_threaded,             undefined);
    register_custom_map("zm_1",                 serious::zm_astoria_init,           serious::zm_astoria_weapons,            undefined,                              undefined,                              undefined);
    register_custom_map("zm_westernz",          serious::zm_wanted_init,            serious::zm_wanted_weapons,             undefined,                              serious::zm_wanted_threaded,            undefined);
    register_custom_map("zm_leviathan",         serious::zm_underwater_init,        serious::zm_underwater_weapons,         serious::zm_underwater_spawned,         serious::zm_underwater_threaded,        undefined);
    register_custom_map("zm_terminal",          serious::zm_terminal_init,          serious::zm_terminal_weapons,           undefined,                              undefined,                              undefined);
    register_custom_map("zm_dust_2",            serious::zm_dust_2_init,            undefined,                              undefined,                              undefined,                              undefined);
    register_custom_map("zm_rainy_death",       serious::zm_rainy_death_init,       serious::zm_rainy_death_weapons,        serious::zm_rd_spawned,                 undefined,                              undefined);
    register_custom_map("zm_powerstation",      serious::zm_powerstation_init,      serious::zm_powerstation_weapons,       undefined,                              serious::zm_powerstation_threaded,      serious::zm_powerstation_roundnext);
    register_custom_map("zm_coast",             serious::zm_coast_init,             serious::zm_coast_weapons,              undefined,                              undefined,                              undefined);

    // Point of contact starting room? - not very big, might get scrapped
    // dome v2
    // evil christmas? might be too big

    register_custom_map("zm_three",             serious::zm_three_init,             undefined,                              undefined,                              undefined,                              undefined);
    register_custom_map("zm_town_hd",           serious::zm_town_hd_init,           serious::zm_town_hd_weapons,            serious::zm_town_hd_spawned,            serious::zm_town_hd_threaded,           undefined);
    register_custom_map("zm_47berkerlylane_vkzu", serious::zm_47berkerlylane_init,  undefined,                              undefined,                              serious::zm_47berkerlylane_threaded,    undefined); // TODO wip
    register_custom_map("zm_erosion_jss",       serious::zm_erosion_init,           serious::zm_erosion_weapons,            undefined,                              undefined,                              undefined); // TODO culled
    register_custom_map("zm_wildwest",          undefined,                          serious::zm_wildwest_weapons,           undefined,                              serious::zm_wildwest_threaded,          undefined); 
    register_custom_map("zm_basement",          serious::zm_basement_init,          serious::zm_basement_weapons,           undefined,                              undefined,                              undefined); // TODO: doesnt load

    register_custom_map("zm_irondragon",        serious::zm_irondragon_init,        serious::zm_irondragon_weapons,         undefined,                              serious::zm_irondragon_threaded,        undefined);
    register_custom_map("zm_karma",             serious::zm_karma_init,             serious::zm_karma_weapons,              undefined,                              serious::zm_karma_threaded,             function() => {level.incendiaryfiredamage = int(CLAMPED_ROUND_NUMBER * 250 / 3); level.incendiaryfiredamageticktime = 0.25;});
    register_custom_map("zm_der_riese",         serious::zm_der_riese_init,         serious::zm_der_riese_weapons,          undefined,                              serious::zm_der_riese_threaded,         undefined);
    register_custom_map("zm_prison",            serious::zm_prison_init,            serious::zm_prison_weapons,             undefined,                              serious::zm_prison_threaded,            undefined);
    
    #endregion

    level.playersuicideallowed = false;

    // unsupported maps list:
    // [permanent] Nuketown Remastered - Clix ZE and tons of conflicting files and clientfields
    // [permanent] Great Leap Forward - BGB machine and mystery box overrides
    // [permanent] Mori Rebirth - Clix ZR and tons of conflicting subsystems. Would basically have to replace the entire map's scripts and add custom dll exports. No thanks.

    // temporarily broken (may or may not fix depending on if I feel like it):
    // EVKLA - Unresolved external
    // Void Expanse - Game closes
    // Atonement - Game closes
    // Cataclysm - Way too big. LMS could be used once its improved...
    // Elevation - Same issue, except even bigger.
}

// use level.customs_zombie_damage_scalar to scale damage globally against zombies on a given map

// registers a custom map's callbacks when applicable
// this system also exposes callbacks for custom map developers who would like to support ZBR officially
// callbacks list:
// --- cb_spawnlogic: Runs one time on the level object, right before spawn selection for a map is done. This should be used to blacklist zones, remove barriers, disable easter egg steps, enable pap, etc, etc. 
// --- cb_init_weapons: Runs one time on the level object, after the blackscreen has passed. This should be used to modify weapon tuning, craftables, and setup any necessary overrides for weapon callbacks.
// --- cb_player_weapons: Runs on player spawned on the player. Can be used for perks, powerups, and weapons
// --- cb_gm_threaded: Runs one time on the level object, after zombie spawns are enabled. This should be used for any kind of latent initialization routine, such as moving perks machines, destroying easter egg object threads, etc.
// --- cb_roundnext: Runs when the round changes. NOTE: this also runs when a round resets, so be careful to account for this.
register_custom_map(mapname, cb_spawnlogic, cb_init_weapons, cb_player_weapons, cb_gm_threaded, cb_roundnext)
{
    if(level.script != mapname)
    {
        return;
    }
    
    // NOTE: by choice, I have not checked if I am overriding your custom callbacks.
    level.cb_spawnlogic = cb_spawnlogic;
    level.cb_init_weapons = cb_init_weapons;
    level.cb_player_weapons = cb_player_weapons;
    level.cb_gm_threaded = cb_gm_threaded;
    level.cb_roundnext = cb_roundnext;
}

#region DLC1
#region zm_xmas
zm_xmas_rust_init()
{
    fix_perk_banana_colada();
    fix_perk_bull_ice_blast();
    fix_madgaz_moonshine();
    delete_perk_crusaders_ale();

    // kill their custom hitmarkers
    arrayremovevalue(level.zombie_damage_callbacks, @namespace_74571cc1<scripts\__robit\hitmarkers.gsc>::function_9c301f1a, false);
    zm_spawner::deregister_zombie_death_event_callback(@namespace_74571cc1<scripts\__robit\hitmarkers.gsc>::function_5adbafc9);

    // disable buyable ending
    getent("end_game_trig", "targetname").origin = ORIGIN_OOB;
    getent("sg4y_endgame_laptop_pickup", "targetname").origin = ORIGIN_OOB;
}

zm_xmas_rust_weapons()
{
    arrayremoveindex(level.zombie_weapons, getweapon("h1_ranger"), true);

    register_weapon_scalar(undefined, "h1_stac_up", 0.167);
    register_weapon_scalar(undefined, "h1_m82a1_up", 0.167);
}
#endregion

#region zm_daybreak
zm_daybreak_init()
{
    // kill their custom hitmarkers
    arrayremovevalue(level.zombie_damage_callbacks, @namespace_74571cc1<scripts\__robit\hitmarkers.gsc>::function_9c301f1a, false);
    zm_spawner::deregister_zombie_death_event_callback(@namespace_74571cc1<scripts\__robit\hitmarkers.gsc>::function_5adbafc9);
}

zm_daybreak_weapons()
{
    add_planted_callback(serious::claymore_detonation, "claymore");

    tesla_sniper_calc_dmg = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        if(weapon == level.var_62654d02)
        {
            return int(400 * CLAMPED_ROUND_NUMBER);
        }
        return int(1000 * CLAMPED_ROUND_NUMBER);
    };

    register_weapon_calculator("tesla_sniper", tesla_sniper_calc_dmg);
    register_weapon_calculator("tesla_sniper_upgraded", tesla_sniper_calc_dmg);
    register_weapon_scalar("t8_hellion_salvo", "t8_hellion_salvo_up", 0.25, 0.25);
    register_weapon_postcalc("t8_hellion_salvo", true);
    register_weapon_postcalc("t8_hellion_salvo_up", true);

    // register_box_weapon("wraith_fire");
    register_box_weapon("spx_zombie_shield", "spx_zombie_shield_upgraded");
    register_box_weapon("launcher_multi", "launcher_multi_upgraded");
    register_box_weapon("smg_ppsh", "smg_ppsh_upgraded");
    // register_box_weapon("raygun_mark3", "raygun_mark3_upgraded");
    register_box_weapon("tesla_gun", "tesla_gun_upgraded");
    register_box_weapon("octobomb", "octobomb_upgraded");
}

zm_daybreak_threaded()
{
    level.custom_game_over_hud_elem = serious::end_game_hud; // restore this
    level.var_b77e237a = []; // kill an ee step
    level.var_74fa1516 = -999;
    
    while(level.var_80571cd5 is undefined)
    {
        wait 1;
    }

    if(isdefined(level.var_80571cd5))
    {
        level.var_80571cd5 delete();
    }
    
    if(level.var_532ed1cb is undefined)
    {
        return;
    }

    foreach(ent in level.var_532ed1cb)
    {
        ent.origin = (-100000,-100000,-100000);
    }
}

zm_daybreak_plrwpns()
{
    self thread wraith_fire_watch();
}
#endregion

#region zm_kyassuruz
#define ZM_KYASSURUZ_DRAGONSHIELD_DMG_PER_ROUND = 700;
zm_kyassuruz_init()
{
    // blocks the pap room which is locked behind quest objectives on this map
    level.gm_blacklisted[level.gm_blacklisted.size] = "third_zoneb";

    // auto open PAP
    arr = [
        getent("pap_door_dragon", "targetname"),
        getent("pap_door", "targetname"),
        getent("pap_door_clip", "targetname")
    ];
    if(isdefined(arr))
    {
        foreach(ent in arr)
        {
            if(!isdefined(ent)) continue;
            ent connectPaths();
            ent delete();
        }
    }

    // open the shield room
    shield_room_door = getent("door_shield", "targetname");
    if(isdefined(shield_room_door))
    {
        shield_room_door delete();
    }

    callback::remove_on_spawned(@namespace_8823e0<scripts\zm\zm_kyassuruz.gsc>::on_player_spawned); // delete a leaked spawn thread
    callback::remove_on_spawned(@namespace_cc1b6ae5<scripts\zm\zm_gongs.gsc>::function_a43ad071); // another leak thread
    callback::remove_on_spawned(@zm_flamethrower<scripts\zm\zm_flamethrower.gsc>::flamethrower_swap); // do i even need to say it?
    callback::remove_on_spawned(@namespace_e24825ed<scripts\zm\z_challenges.gsc>::function_a43ad071); // 
}

zm_kyassuruz_weapons()
{
    register_box_weapon("m2_flamethrower", "m2_flamethrower_upgraded");

    // dragon_shield_projectile
    register_weapon_postcalc("dragon_shield_projectile", true);
    register_weapon_calculator("dragon_shield_projectile", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(CLAMPED_ROUND_NUMBER * ZM_KYASSURUZ_DRAGONSHIELD_DMG_PER_ROUND);
    });
}

zm_kyassuruz_threaded()
{
    level.pap_open = true; 

    foreach(firepit in getentarray("fire_pit_trig", "targetname"))
    {
        firepit.origin = ORIGIN_OOB;
    }

    foreach(challenge in getentarray("challenges", "targetname"))
    {
        challenge.origin = ORIGIN_OOB;
    }

    foreach(upgrade in getentarray("shootable_ee", "targetname"))
    {
        upgrade.origin = ORIGIN_OOB;
    }
}
#endregion

#region zm_town
zm_town_reimagined_init()
{
    fix_perk_banana_colada();
    delete_perk_by_names("specialty_tombstone", "vending_tombstone");
    delete_whos_who();
}

zm_town_reimagined_weapons()
{
    // force new weapons into the box
    register_box_weapon("thundergun", "thundergun_upgraded");
    register_box_weapon("smg_ppsh", "smg_ppsh_upgraded");
    // register_box_weapon("raygun_mark3", "raygun_mark3_upgraded");
    register_box_weapon("zod_riotshield", "zod_riotshield_upgraded");
    register_box_weapon("t4_sniper_ptrs41", "t4_sniper_ptrs41_upgraded");
    register_box_weapon("t4_lmg_30cal", "t4_lmg_30cal_upgraded");
    // register_box_weapon("t6_minigun_alcatraz", "t6_minigun_alcatraz_upgraded");
    register_box_weapon("t6_shotgun_acidgat", "t6_shotgun_acidgat_upgraded");
    register_box_weapon("t6_shotgun_blundergat", "t6_shotgun_blundergat_upgraded");
    // register_box_weapon("idgun_0", "idgun_0_upgraded");

    // adjust weapon damage for some explosives which are default weak
    register_weapon_scalar("t6_launch_m32", "t6_launch_m32_upgraded", 5, 5);
    register_weapon_postcalc("t6_launch_m32", true);
    register_weapon_postcalc("t6_launch_m32_upgraded", true);

    register_weapon_scalar("t6_launch_usrpg", "t6_launch_usrpg_upgraded", 7, 7);
    register_weapon_postcalc("t6_launch_usrpg", true);
    register_weapon_postcalc("t6_launch_usrpg_upgraded", true);

    register_weapon_scalar("t6_shotgun_blundergat", "t6_shotgun_blundergat_upgraded", 0.5, 0.5);
    register_weapon_scalar("t4_sniper_ptrs41", "t4_sniper_ptrs41_upgraded", 6, 6);

    remove_box_weapon("idgun_0", "idgun_0_upgraded");
}
#endregion

#region zm_cove
zm_cove_init()
{
    level.cymbal_monkey_model = "p7_zm_zod_bubblegum_machine_with_lion";
    level.shrink_clone_scale = 0.5;
    level.mechz_base_health = 1000;
	level.mechz_health = level.mechz_base_health;
	level.var_fa14536d = 1250;
	level.mechz_faceplate_health = level.var_fa14536d;
	level.var_f12b2aa3 = 50;
	level.mechz_powercap_cover_health = level.var_f12b2aa3;
	level.var_e12ec39f = 50;
	level.mechz_powercap_health = level.var_e12ec39f;
	level.var_3f1bf221 = 25;
	level.var_2cbc5b59 = level.var_3f1bf221;
	level.mechz_health_increase = 100;
	level.mechz_shotgun_damage_mod = 1.5;
	level.mechz_damage_percent = 1;
	level.mechz_helmet_health_percentage = 1;
	level.mechz_explosive_dmg_to_cancel_claw_percentage = 1;
	level.mechz_powerplant_destroyed_health_percentage = 0.25;
	level.mechz_powerplant_expose_health_percentage = 0.5;
}

zm_cove_weapons()
{
    remove_box_weapon("raygun_mark2");
    register_box_weapon("shrink_ray", "shrink_ray_upgraded");
    register_box_weapon("tesla_gun", "tesla_gun_upgraded");
    register_box_weapon("hero_annihilator", undefined);
    register_box_weapon("spx_brazen_bull_shield", "spx_brazen_bull_shield_upgraded");

    register_weapon_scalar("t8_vendetta", "t8_vendetta_up", 0.1, 0.1);
    register_weapon_scalar("t8_switchblade_x9", "t8_switchblade_x9_up", 2);
    register_weapon_scalar("t8_swat_rft", "t8_swat_rft_up", 0.4);
    register_weapon_scalar("t8_rampage", "t8_rampage_up", 0.15);
    register_weapon_scalar("t8_kap45", "t8_kap45_up", 1.5);
    register_weapon_scalar("t8_grav", "t8_grav_up", 2);
    register_weapon_scalar("t8_vkm750", "t8_vkm750_up", 1);
    register_weapon_scalar("t8_vapr_xkg", "t8_vapr_xkg_up", 0.7);
    register_weapon_scalar("t8_titan", "t8_titan_up", 0.4);
    register_weapon_scalar("t8_spitfire", "t8_spitfire_up", 1);
    register_weapon_scalar("t8_sg12", "t8_sg12_up", 0.2);
    register_weapon_scalar("t8_sdm", "t8_sdm_up", 0.08);
    register_weapon_scalar("t8_saug9mm", "t8_saug9mm_up", 2);
    register_weapon_scalar("t8_rk7", "t8_rk7_up", 1.25);
    register_weapon_scalar("t8_rampart17", "t8_rampart17_up", 0.35);
    register_weapon_scalar("t8_paladin", "t8_paladin_hb50_up", 0.8);
    register_weapon_scalar("t8_mx9", "t8_mx9_up", 2.3);
    register_weapon_scalar("t8_mozu", "t8_mozu_up", 0.1);
    register_weapon_scalar("t8_mog12", "t8_mog12_up", 1.75);
    register_weapon_scalar("t8_maddox_rfb", "t8_maddox_rfb_up", 1.6);
    register_weapon_scalar("t8_m1927", "t8_m1927_up", 1.8);
    register_weapon_scalar("t8_koshka", "t8_koshka_up", 0.8);
    register_weapon_scalar("t8_kn57", "t8_kn57_up", 2);
    register_weapon_scalar("t8_icr7", "t8_icr7_up", 1.7);
    register_weapon_scalar("t8_hitchcock_m9", "t8_hitchcock_m9_up", 1.5);
    register_weapon_scalar("t8_hellion_salvo", "t8_hellion_salvo_up", 0.6, 0.6);
    register_weapon_postcalc("t8_hellion_salvo", true);
    register_weapon_postcalc("t8_hellion_salvo_up", true);
    register_weapon_scalar("t8_hades", "t8_hades_up", 3);
    register_weapon_scalar("t8_gks", "t8_gks_up", 3);
    register_weapon_scalar("t8_zweihander", "t8_zweihander_up", 0.36);
    register_weapon_scalar("t8_essex_m07", "t8_essex_m07_up", 4);
    register_weapon_scalar("t8_escargot", "t8_escargot_up", 1.6);
    register_weapon_scalar("t8_cordite", "t8_cordite_up", 2);
    register_weapon_scalar("t8_auger_dmr", "t8_auger_dmr_up", 0.25);
    register_weapon_scalar("t8_abr223", "t8_abr223_up", 1.3);   

    register_weapon_hd_modifier("t8_hades", "t8_hades_up", 0.4);
}

zm_cove_threaded()
{
    // kill their custom hitmarkers
    arrayremovevalue(level.zombie_damage_callbacks, @namespace_74571cc1<scripts\__robit\hitmarkers.gsc>::function_9c301f1a, false);
    zm_spawner::deregister_zombie_death_event_callback(@namespace_74571cc1<scripts\__robit\hitmarkers.gsc>::function_5adbafc9);
    
    fix_vigor_rush();

    foreach(door in level.var_1b3a5cd9)
    {
        door notify(#"hash_adc6d9ff");
        door thread zm_cove_door_override();
    }

    thread zm_cove_valve_always_available();

    getent("cave_pap_clip", "targetname") delete();
	getent("cave_pap_trigger", "targetname") delete();

    door = getent("cave_pap_door", "targetname");
    getent(door.target, "targetname") delete();
    door delete();

    level notify(#"hash_bade18c1");
}

zm_cove_door_override()
{
    wait 1;
    self sethintstring("Hold ^3&&1^7 to place valve");

    wheel = getent(self.target, "targetname");
	wheel show();

    self.zombie_cost = 100;
}

zm_cove_valve_always_available()
{
    level endon("end_game");
    while(true)
    {
        level.var_6dfe30b = true;
        wait 1;
    }
}
#endregion

#region zm_mori
zm_mori_init()
{
    // kill their custom hitmarkers
    arrayremovevalue(level.zombie_damage_callbacks, @namespace_cf7a5f75<scripts\zm\nsz_hitmarkers.gsc>::function_1114d19b, false);
    zm_spawner::deregister_zombie_death_event_callback(@namespace_cf7a5f75<scripts\zm\nsz_hitmarkers.gsc>::function_41b85b21);

    // remove incompatible powerups

    if(isdefined(level.zombie_powerups["invincible"]))
    {
        level.zombie_powerups["invincible"].func_should_drop_with_regular_powerups = serious::nullsub;
    }

    if(isdefined(level.zombie_powerups["bottomless_clip"]))
    {
        level.zombie_powerups["bottomless_clip"].func_should_drop_with_regular_powerups = serious::nullsub;
    }

    foreach(e_trig in getentarray("trig_challenges", "targetname"))
    {
        e_trig.origin = ORIGIN_OOB;
    }

    getent("recipent_ee", "targetname").origin = ORIGIN_OOB;
    getent("end_game_trig", "targetname").origin = ORIGIN_OOB;

    foreach(trap in getentarray("trig_spikes_trap", "targetname"))
    {
        trap.origin = ORIGIN_OOB;
    }

    callback::on_spawned(serious::zm_mori_on_spawned);

    register_box_weapon("hero_annihilator");
    remove_box_weapon("otg_bo4_ray_gun");
    register_weapon_scalar("knife_ballistic", "knife_ballistic_upgraded", 6, 12);
    register_weapon_scalar("bo4_hellion", "bo4_hellion_upgraded", 1, 1);
    register_weapon_postcalc("bo4_hellion", true);
    register_weapon_postcalc("bo4_hellion_upgraded", true);

    register_weapon_scalar("bo4_1897_upgraded", undefined, 7);
    register_weapon_postcalc("bo4_1897_upgraded", true);

    register_weapon_scalar("h1_rpg7", "h1_rpg7_up", 1.2, 1.2);
    register_weapon_postcalc("h1_rpg7", true);
    register_weapon_postcalc("h1_rpg7_up", true);
    
	register_weapon_scalar("bo4_thompson", "bo4_thompson_upgraded", 2);
	register_weapon_scalar("bo4_swordfish", "bo4_swordfish_upgraded", 1.6);
	register_weapon_scalar("bo4_rampage", "bo4_rampage_upgraded", 0.45);
	register_weapon_scalar("bo4_mp40", "bo4_mp40_upgraded", 3.2);
	register_weapon_scalar("bo4_auger", "bo4_auger_upgraded", 4);
	register_weapon_scalar("bo4_abr", "bo4_abr_upgraded", 1.1);
	register_weapon_scalar("bo4_vapr", "bo4_vapr_upgraded", 2.8);
	register_weapon_scalar("bo4_spitfire", "bo4_spitfire_upgraded", 1.8);
	register_weapon_scalar("bo4_saug", "bo4_saug_upgraded", 1.2);
	register_weapon_scalar("bo4_saug_lh", "bo4_saug_lh_upgraded", 1.2);
	register_weapon_scalar("bo4_rampart", "bo4_rampart_upgraded", 2.7);
	register_weapon_scalar("bo4_mp9", "bo4_mp9_upgraded", 2.5);
	register_weapon_scalar("bo4_maddox_rfb", "bo4_maddox_rfb_upgraded", 0.8);
	register_weapon_scalar("bo4_kn57", "bo4_kn57_upgraded", 2.2);
	register_weapon_scalar("bo4_gks", "bo4_gks_upgraded", 2.75);
	register_weapon_scalar("bo4_sdm", "bo4_sdm_upgraded", 0.45);
	register_weapon_scalar("bo4_paladin", "bo4_paladin_upgraded", 2);
	register_weapon_hd_modifier("bo4_paladin", "bo4_paladin_upgraded", 0.6);
	register_weapon_head_modifier("bo4_paladin", "bo4_paladin_upgraded", 0.6);
	register_weapon_scalar("bo4_koshka", "bo4_koshka_upgraded", 3.6);
	register_weapon_hd_modifier("bo4_koshka", "bo4_koshka_upgraded", 0.6);
	register_weapon_head_modifier("bo4_koshka", "bo4_koshka_upgraded", 0.6);
	register_weapon_scalar("bo4_vkm", "bo4_vkm_upgraded", 2.5);
	register_weapon_scalar("bo4_titan", "bo4_titan_upgraded", 1.3);
	register_weapon_scalar("bo4_suma", "bo4_suma_upgraded", 1.3);
	register_weapon_scalar("bo4_sg12", "bo4_sg12_upgraded", 0.55);
	register_weapon_scalar("bo4_mog12", "bo4_mog12_upgraded", 2.5);
	register_weapon_scalar("bo4_strife", "bo4_strife_upgraded", 5);
	register_weapon_scalar("bo4_mozu", "bo4_mozu_upgraded", 2);
	register_weapon_scalar("bo4_kap45", "bo4_kap45_upgraded", 1.5);
	register_weapon_scalar("bo4_garrison", "bo4_garrison_upgraded", 1.5);
	register_weapon_scalar("h1_p90_kgp", "h1_p90_kgp_up", 2.5);
	register_weapon_scalar("h1_mac10_kgp", "h1_mac10_kgp_up", 2.5);
	register_weapon_scalar("h1_mini_uzi_kgp", "h1_mini_uzi_kgp_up", 1.1);
	register_weapon_scalar("h1_skorpion_kgp", "h1_skorpion_kgp_up", 1.4);
	register_weapon_scalar("h1_mp5_kgp", "h1_mp5_kgp_up", 3.6);
	register_weapon_scalar("h1_lynx_cq300_don", "h1_lynx_cq300_don_up", 2);
	register_weapon_scalar("h1_g36c_don", "h1_g36c_don_up", 2.8);
	register_weapon_scalar("h1_bos14_don", "h1_bos14_don_up", 1.6);
	register_weapon_scalar("bo3_m14", "bo3_m14_upgraded", 0.5);
	register_weapon_scalar("mosin", "mosin_upgraded", 1.05);
	register_weapon_scalar("bo3_stg44", "bo3_stg44_upgraded", 3);
	register_weapon_scalar("bo3_galil", "bo3_galil_upgraded", 2.7);
	register_weapon_hd_modifier("bo3_galil", "bo3_galil_upgraded", 0.6);
	register_weapon_head_modifier("bo3_galil", "bo3_galil_upgraded", 0.6);
	register_weapon_scalar("bo3_rpk", "bo3_rpk_upgraded", 2.5);
	register_weapon_scalar("bo3_an94", "bo3_an94_upgraded", 2.8);
	register_weapon_scalar("bo3_sten", "bo3_sten_upgraded", 3);
	register_weapon_scalar("bo3_ak74u", "bo3_ak74u_upgraded", 2);
	register_weapon_scalar("bo3_olympia", "bo3_olympia_upgraded", 1.25);
    set_level_olympia("bo3_olympia", "bo3_olympia_upgraded");
}

zm_mori_on_spawned()
{
    if(self ishost() && !isdefined(level.zm_mori_initial_fix))
    {
        level.initial_round_wait_func = serious::nullsub;
        level.zm_mori_initial_fix = true;
        wait 0.1;
        self notify("menuresponse", "CreateCustomQMenu", "normal");
        self CloseMenu("CreateCustomQMenu");
        level.var_b3803fd4 = "normal";
        level.zombie_powerups["free_jerk"].func_should_drop_with_regular_powerups = 0;
        level.zombie_powerups["zombie_blood"].func_should_drop_with_regular_powerups = 0;
        level.zombie_powerups["bottomless_clip"].func_should_drop_with_regular_powerups = 0;
        level.zombie_powerups["mori_slow"].func_should_drop_with_regular_powerups = 0;
        level.zombie_powerups["invincible"].func_should_drop_with_regular_powerups = 0;
        level.zombie_powerups["mori_aat"].func_should_drop_with_regular_powerups = 0;
        level.zombie_powerups["mori_upg"].func_should_drop_with_regular_powerups = 0;
        level.zombie_powerups["custom_powerup_free_packapunch"].func_should_drop_with_regular_powerups = 0;
        setdvar("ai_disableSpawn", 0);
		level notify(#"hash_83722ae3");
        callback::remove_on_spawned(serious::zm_mori_on_spawned);
    }
}

zm_mori_threaded()
{
    spikes = getentarray("spikes", "targetname");
	foreach(spike in spikes)
	{
		trig = getent(spike.target, "targetname");
        if(isdefined(trig))
        {
            clip = getent(trig.target, "targetname");
            if(isdefined(clip))
            {
                clip connectpaths();
                clip.origin = ORIGIN_OOB;
            }
            trig.origin = ORIGIN_OOB;
        }
        spike.origin = ORIGIN_OOB;
	}
}
#endregion

#region zm_whomp_n64_ez
zm_whomp_n64_ez_init()
{
    level.gm_blacklisted[level.gm_blacklisted.size] = "pap_zone";
    level.gm_oob_monitors[level.gm_oob_monitors.size] = serious::zm_whomp_n64_ez_nopapzone;
    level.fn_zbr_check_bad_point = serious::zm_whomp_n64_ez_bad_points;

    fix_perk_banana_colada();
    fix_perk_bull_ice_blast();
    fix_madgaz_moonshine();
    delete_perk_crusaders_ale();
    delete_perk_by_names("specialty_tombstone", "vending_tombstone");
    delete_whos_who();

    compiler::erasefunc("scripts/zm/dig/_dig.gsc", 0x2c40d8c8, 0x11cbcaa9); // cheat code fix, overwrites function with OP_END
}

zm_whomp_n64_ez_weapons()
{
    register_box_weapon("ray_gun_ultra", "ray_gun_ultra_upgraded");
    remove_box_weapon("thundergun", "thundergun_upgraded");
    register_box_weapon("raygun_mark3", "raygun_mark3_upgraded");
    register_box_weapon("iw6_venomx", "iw6_venomx_up");
    register_weapon_scalar("iw6_p226_rdw", "iw6_p226_rdw_up", 0.1, 0.1);
    remove_box_weapon("idgun_0", "idgun_0_upgraded");
    remove_box_weapon("h1_44magnum", "h1_44magnum_up");
    remove_box_weapon("h1_ranger", "h1_ranger_up");
    remove_box_weapon("t6_storm_psr", "t6_storm_psr_up");
}

zm_whomp_n64_ez_bad_points(v_point)
{
    return distancesquared(v_point, (-366, -1055, -170)) <= 10000;
}

zm_whomp_n64_ez_threaded()
{
    getent("eeDoor", "targetname").origin = ORIGIN_OOB;
    getent("eeDoorClip", "targetname").origin = ORIGIN_OOB;
    getent("ending", "targetname").origin = ORIGIN_OOB;
    getent("CoinDoor", "targetname").origin = ORIGIN_OOB;
    level flag::init("star_get");
	level flag::set("star_get");
    level.var_c0f21d1c = 999;
    level.var_ba00001d = 999;
    level.var_7e284ee = 999;
    level.var_714b2fc2 = 999;
    unlock_all_debris();
}

zm_whomp_n64_ez_nopapzone()
{
    if((self.oob_zone_cache ?? "") == "pap_zone")
    {
        return true;
    }
    return false;
}

#endregion

#region zm_ski_resort
autoexec zm_ski_resort_fast()
{
    if(tolower(getdvarstring("mapname")) == "zm_ski_resort")
    {
        compiler::erasefunc("scripts/zm/zm_chairlift.gsc", 0xdc4eb413, 0xbe7e4d0);
    }
}

zm_ski_resort_init()
{
    level.gm_blacklisted[level.gm_blacklisted.size] = "chairlift_station_zone";
    level.gm_blacklisted[level.gm_blacklisted.size] = "ski_upper_zone";
    level.gm_blacklisted[level.gm_blacklisted.size] = "ski_middle_zone";
    level.gm_blacklisted[level.gm_blacklisted.size] = "ski_lower_zone";

    // kill custom bgb machines
    foreach(ent in getentarray("zbarrier_bgb_machine", "targetname"))
    {
        trigger = getent(ent.target, "targetname");
        trigger.origin = ORIGIN_OOB;
        ent hide();
        trigger hide();

        ent clientfield::set("bgb_power_FX", 1);
        wait 0.05;
        
        for(i = 0; i < (ent GetNumZBarrierPieces()); i++)
        {
            ent hidezbarrierpiece(i);
        }
    }

    // kill wearables
    foreach(hat in array("santa", "antlers", "tophat"))
    {
        trigger = getent(hat + "_perk_hat_trigger", "targetname");
        var_a0201df2 = getent(hat + "_perk_hat_hint_trigger", "targetname");
        hat = getent(trigger.target, "targetname");
        trigger.origin = ORIGIN_OOB;
        var_a0201df2.origin = ORIGIN_OOB;
        hat.origin = ORIGIN_OOB;
    }
}

#define ZM_SKI_RESORT_CLAYMORE_DMG_PER_ROUND = 5000;
zm_ski_resort_weapons()
{
    level.__proximityweaponobjectdetonation_override = level._proximityweaponobjectdetonation_override;
    register_box_weapon("scavenger", "scavenger_upgraded");
    remove_box_weapon("gersch_device");

    register_weapon_scalar("knife_ballistic", "knife_ballistic_upgraded", 6, 12);
    register_weapon_scalar("knife_ballistic", "knife_ballistic_upgraded", 9, 13);
    register_weapon_scalar("mors", "mors_upgraded", 2, 2);
    register_weapon_scalar("volk", "volk_upgraded", 3.5, 4.0);
    register_weapon_scalar("rwl", "rwl_upgraded", 3.0, 3.5);
    register_weapon_scalar("microtar", "microtar_upgraded", 3.0, 3.0);

    register_weapon_postcalc("claymore", true);
    register_weapon_calculator("claymore", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(CLAMPED_ROUND_NUMBER * ZM_SKI_RESORT_CLAYMORE_DMG_PER_ROUND);
    });
    
    level.f_unregistered_weapon_scalar = 2.5;

    level._proximityweaponobjectdetonation_override = function(watcher) =>
    {
        self.team = self.owner.team;
        if(!isfunctionptr(level.__proximityweaponobjectdetonation_override))
        {
            return;
        }
        self [[ level.__proximityweaponobjectdetonation_override ]](watcher);
    };
}

zm_ski_resort_threaded()
{
    // kill easter egg
    for(i = 0; i < level.var_e41012e7.size; i++)
    {
        level.var_e41012e7[i].callback = undefined;
        level.var_e41012e7[i].watcher = serious::nullsubfiveargs;
    }

    // kill zombie counter hud
    if(isdefined(level.var_7c306fc9?.background))
    {
        level.var_7c306fc9.background destroy();
        level.var_7c306fc9.ones.fontscale = 0.01;
        level.var_7c306fc9.ones.x = 10000;
        level.var_7c306fc9.ones.y = 10000;
        level.var_7c306fc9.tens destroy();
        level.var_7c306fc9.tens = level.var_7c306fc9.ones;
        level.var_7c306fc9.hundreds destroy();
        level.var_7c306fc9.hundreds = level.var_7c306fc9.ones;
        level.var_7c306fc9.thousands destroy();
        level.var_7c306fc9.thousands = level.var_7c306fc9.ones;
    }

    wait 3;
    level notify("electric_cherry_on");
}

zm_ski_resort_spawned()
{
    self.zm_ski_resort_spawned = true;
    level.fn_fix_movement ??= @namespace_40246740<scripts\zm\zm_ski.gsc>::function_60f59433;

    foreach(player in getplayers())
    {
        if(player == self)
        {
            continue;
        }
        if(player.sessionstate == "playing" && !isdefined(player.zm_ski_resort_spawned))
        {
            player thread zm_ski_resort_spawned();
        }
    }

    if(isdefined(level.fn_fix_movement))
    {
        self thread [[ level.fn_fix_movement ]]();
    }
}
#endregion

#region zm_mario64_v2
zm_mario64_v2_init()
{
    init_large_map_support();

    level.gm_blacklisted[level.gm_blacklisted.size] = "bobs_zone";
    level.gm_blacklisted[level.gm_blacklisted.size] = "cool_up_zone";
    level.gm_blacklisted[level.gm_blacklisted.size] = "cool_mid_zone";
    level.gm_blacklisted[level.gm_blacklisted.size] = "cool_low_zone";
    level.gm_blacklisted[level.gm_blacklisted.size] = "whomps_zone";
    level.gm_blacklisted[level.gm_blacklisted.size] = "whomps_mid_zone";
    level.gm_blacklisted[level.gm_blacklisted.size] = "whomps_up_zone";

    lms_register_zone_title("start_zone", "Outside the Castle");
        lms_register_cannonical_zones("start_zone", "pathway_zone");
        lms_register_zone_title("pathway_zone", "Outside the Castle");
            lms_register_cannonical_zones("pathway_zone", "revive_zone");
            lms_register_zone_title("revive_zone", "Outside the Castle");
            lms_register_cannonical_zones("pathway_zone", "bridge_zone");
            lms_register_zone_title("bridge_zone", "Outside the Castle");
            lms_register_cannonical_zones("pathway_zone", "dragon_zone");
            lms_register_zone_title("dragon_zone", "Outside the Castle");
    
    lms_register_zone_title("main_zone", "The Castle");
        lms_register_cannonical_zones("main_zone", "bob_room_zone");
        lms_register_zone_title("bob_room_zone", "The Castle");
        lms_register_cannonical_zones("main_zone", "entrance_zone");
        lms_register_zone_title("entrance_zone", "The Castle");
        lms_register_cannonical_zones("main_zone", "dire_room_zone");
        lms_register_zone_title("dire_room_zone", "The Castle");
        lms_register_cannonical_zones("main_zone", "bowser_room_zone");
        lms_register_zone_title("bowser_room_zone", "The Castle");
        lms_register_cannonical_zones("main_zone", "cool_room_zone");
        lms_register_zone_title("cool_room_zone", "The Castle");
        lms_register_cannonical_zones("main_zone", "whomp_room_zone");
        lms_register_zone_title("whomp_room_zone", "The Castle");
        lms_register_cannonical_zones("main_zone", "main_hall_zone");
        lms_register_zone_title("main_hall_zone", "The Castle");
            lms_register_zone_title("garden_zone", "The Castle Garden");
            lms_register_zone_title("basement_entrance_zone", "The Castle Basement");
                lms_register_cannonical_zones("basement_entrance_zone", "bowser2_room_zone");
                lms_register_zone_title("bowser2_room_zone", "The Castle Basement");
                lms_register_cannonical_zones("basement_entrance_zone", "basement_main_zone");
                lms_register_zone_title("basement_main_zone", "The Castle Basement");
                    lms_register_cannonical_zones("basement_main_zone", "basement_tunnel_zone");
                    lms_register_zone_title("basement_tunnel_zone", "The Castle Basement");
                    lms_register_cannonical_zones("basement_tunnel_zone", "basement_entrance_zone");
        lms_register_cannonical_zones("main_zone", "spiral_stairs_zone");
        lms_register_zone_title("spiral_stairs_zone", "The Castle");
            lms_register_zone_title("1st_floor_zone", "The Castle Upstairs");
                lms_register_cannonical_zones("1st_floor_zone", "mirror_room_zone");
                lms_register_zone_title("mirror_room_zone", "The Castle Upstairs");
                lms_register_cannonical_zones("1st_floor_zone", "tiny_huge_room_zone");
                lms_register_zone_title("tiny_huge_room_zone", "The Castle Upstairs");
                lms_register_cannonical_zones("1st_floor_zone", "clock_room_zone");
                lms_register_zone_title("clock_room_zone", "The Castle Upstairs");
                    lms_register_zone_title("infinite_stairs_zone", "The Infinite Stairs");
    
    lms_register_zone_title("bobs_zone", "Bob-omb Battlefield");

    lms_register_zone_title("cool_up_zone", "Cool, Cool Mountain");
        lms_register_cannonical_zones("cool_up_zone", "cool_mid_zone");
        lms_register_zone_title("cool_up_zone", "Cool, Cool Mountain");
            lms_register_cannonical_zones("cool_mid_zone", "cool_low_zone");
            lms_register_cannonical_zones("cool_up_zone", "cool_low_zone");
                lms_register_zone_title("cool_low_zone", "Cool, Cool Mountain");

    lms_register_zone_title("whomps_zone", "Whomp's Fortress");
        lms_register_cannonical_zones("whomps_zone", "whomps_mid_zone");
        lms_register_zone_title("whomps_mid_zone", "Whomp's Fortress");
        lms_register_cannonical_zones("whomps_mid_zone", "whomps_up_zone");
        lms_register_cannonical_zones("whomps_zone", "whomps_up_zone");
            lms_register_zone_title("whomps_up_zone", "Whomp's Fortress");

    lms_register_zone_title("bowser1_zone", "Bowser in the Dark World");

    lms_register_zone_title("boos_zone", "Big Boo's Haunt");
        lms_register_cannonical_zones("boos_zone", "boos_up_zone");
        lms_register_zone_title("boos_up_zone", "Big Boo's Haunt");
        lms_register_cannonical_zones("boos_zone", "boos_down_zone");
        lms_register_zone_title("boos_down_zone", "Big Boo's Haunt");

    lms_register_zone_title("lava_zone", "Lethal Lava Land");

    lms_register_zone_title("wet_dry_zone", "Wet Dry World");

    lms_register_zone_title("hazy_start_zone", "Hazy Maze Cave");
        lms_register_cannonical_zones("hazy_start_zone", "hazy_indy_zone");
        lms_register_zone_title("hazy_indy_zone", "Hazy Maze Cave");
        lms_register_cannonical_zones("hazy_start_zone", "hazy_big_zone");
        lms_register_zone_title("hazy_big_zone", "Hazy Maze Cave");
            lms_register_cannonical_zones("hazy_big_zone", "hazy_maze_zone");
            lms_register_zone_title("hazy_maze_zone", "Hazy Maze Cave");
    
    level.fn_ignore_zone_change = function(player, str_old_zone, str_new_zone) =>
    {
        if(isdefined(str_old_zone) && isdefined(str_new_zone) && str_new_zone == "start_zone")
        {
            if(str_old_zone != "pathway_zone")
            {
                return true;
            }
        }
        return false;
    };

    level.fn_pause_zbr_objective = function() =>
    {
        foreach(s_spawn in struct::get_array("black_orgs", "targetname"))
        {
            if(distancesquared(s_spawn.origin, self.origin) <= 625)
            {
                gm_reduce_objective_time();
                wait 5;
                return true;
            }
        }
        return false;
    };
}

zm_mario64_v2_weapons()
{
    register_weapon_scalar("t5_minigun", "t5_minigun_up", 0.15, 0.15);
    register_weapon_scalar("t5_asp", "t5_asp_up", 1, 0.30);
}

zm_mario64_v2_threaded()
{
    fix_perk_banana_colada();
    fix_perk_bull_ice_blast();
    fix_madgaz_moonshine();
    delete_perk_crusaders_ale();
    delete_perk_by_names("specialty_tombstone", "vending_tombstone");
    delete_whos_who();

    unlock_all_debris();
    open_all_doors();

    foreach(trig in getentarray("trigger_dragon_station", "targetname"))
    {
        trig.origin = ORIGIN_OOB;
    }

    // disable the wasp spam
    getent("trig_bowser1", "targetname").origin = ORIGIN_OOB;
    getent("trig_maze", "targetname").origin = ORIGIN_OOB;

    // collect the key for upstairs
    level clientfield::set("keyA_collected", 1);
    foreach(player in getplayers())
	{
		player.var_1556f6f9 = 1;
        player.stars = 9999;
	}
	level notify(#"hash_640376e5");

    // get rid of the catwalk barrel array and its trigger
    getent("catwalk_mid_trig", "targetname").origin = ORIGIN_OOB;
    foreach(ent in getentarray("catwalk_barrel", "targetname"))
    {
        ent connectPaths();
        ent.origin = ORIGIN_OOB;
    }

    // kill challenge toads
    toads = struct::get_array("str_toad", "targetname");
    foreach(s_toad in toads)
    {
        foreach(e_ent in getentarray("trigger_radius_use", "classname"))
        {
            if(distanceSquared(e_ent.origin, s_toad.origin) <= 625)
            {
                e_ent.origin = ORIGIN_OOB;
                break;
            }
        }
    }

    foreach(star in struct::get_array("world_star", "targetname"))
    {
        foreach(e_ent in getentarray("trigger_radius_use", "classname"))
        {
            if(distanceSquared(e_ent.origin, star.origin) <= 625)
            {
                e_ent.origin = ORIGIN_OOB;
                break;
            }
        }
    }

    foreach(ent in getentarray("stomp_star", "targetname"))
    {
        target = struct::get(ent.target, "targetname");

        foreach(trig in getentarray("trigger_radius", "classname"))
        {
            if(distancesquared(trig.origin, target.origin) < 625)
            {
                trig notify("trigger", level.players[0]);
            }
        }
    }

    zm_mario64_v2_open_stardoor = function() =>
    {
        self.origin = ORIGIN_OOB;
        foreach(door in getentarray(self.target, "targetname"))
        {
            door connectPaths();
            door.origin = ORIGIN_OOB;
        }
    };

    foreach(door in getentarray("star_door", "targetname"))
    {
        if(isdefined(door.script_string) && door.script_string == "extra_trig")
		{
			continue;
		}
        door thread [[ zm_mario64_v2_open_stardoor ]]();
    }

    // teleport this bad boy outta here
    getent("str_egg_incubation", "targetname").origin = ORIGIN_OOB;

    // max out all the stars
    level.var_1f4aa54d = struct::get_array("world_star", "targetname").size;

    callback::on_spawned(serious::zm_mario64_v2_spawned);

    level flag::set("enter_bobs");
    getent("door_bobs_room", "targetname") delete();

    level flag::set("enter_cool");
    getent("door_cool_room", "targetname") delete();

    level flag::set("enter_whomp");
    getent("door_whomps_room", "targetname") delete();

    level.check_for_valid_spawn_near_team_callback = serious::su_select_spawn;
    level.fn_check_damage_custom = function(eInflictor, attacker, result, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime) =>
    {
        if(isplayer(attacker) && isplayer(self))
        {
            attackerzone = (attacker zm_zonemgr::get_player_zone()) ?? "";
            myzone = (self zm_zonemgr::get_player_zone()) ?? "";
            if(myzone == "infinite_stairs_zone" && (myzone != attackerzone))
            {
                return 0;
            }
        }
        return result;
    };
}

zm_mario64_v2_spawned()
{
    self.var_1556f6f9 = 1;
    self.stars = 9999;
}

zm_mario64_v2_roundnext()
{
    level.check_for_valid_spawn_near_team_callback = serious::su_select_spawn;
}
#endregion

#region zm_alcatraz_island
autoexec zm_alcatraz_patch()
{
    if(tolower(getdvarstring("mapname")) == "zm_alcatraz_island")
    {
        level.fn_downed_reviving_cb = function() =>
        {
            self playsoundtoplayer("wpn_tomahawk_cooldown", self);
            self givemaxammo(self.current_tactical_grenade);
            self clientfield::set_to_player("tomahawk_in_use", 3);
        };
        fx_package = spawnstruct();
        fx_package.impact_upgraded = "custom/jerri/tomahawk/fx_tomahawk_impact_upgraded";
        fx_package.impact_regular = "custom/jerri/tomahawk/fx_tomahawk_impact";
        fx_package.cf_hit = "play_tomahawk_hit_sound";
        compiler::erasefunc("scripts/zm/zm_weap_tomahawk.gsc", 0x46b7c49b, 0xC03A2B24); // tomahawk_thrown
        tomahawk_init(@hash_46b7c49b<scripts\zm\zm_weap_tomahawk.gsc>::tomahawk_spawn, serious::tomahawk_return_player, fx_package, getweapon("zombie_tomahawk"));
        callback::on_spawned(serious::watch_for_tomahawk_throw);

        level.afterlife_laststand_override = serious::zm_alcatraz_island_afterlife;
        level.zombiemode_using_afterlife = false;
        compiler::erasefunc("scripts/zm/zm_alcatraz_perks.gsc", 0xa4457e1b, 0xbf9e76f1);
        compiler::erasefunc("scripts/zm/zm_packasplat.gsc", 0xf68fb151, 0xc3e10858); // fire projectile function
    }
}

zm_alcatraz_island_init()
{
    level.gm_blacklisted[level.gm_blacklisted.size] = "under_base_zone";

    foreach(trap in getentarray("tower_trap_activate_trigger", "targetname"))
    {
        trap.origin = ORIGIN_OOB;
    }

    level.custom_fan_trap_damage_func = function(parent) =>
    {
        self endon("fan_trap_finished");
        while(true)
        {
            foreach(player in level.players)
            {
                if(player.sessionstate != "playing")
                {
                    continue;
                }
                if(self istouching(player))
                {
                    if(!player hasperk("specialty_armorvest"))
                    {
                        player dodamage(player.health + 1000, player.origin);
                    }
                    else
                    {
                        player dodamage(int(500 * CLAMPED_ROUND_NUMBER), player.origin);
                    }
                }
            }
            foreach(zombie in GetAITeamArray(level.zombie_team))
            {
                if(!isalive(zombie))
                {
                    continue;
                }
                if(zombie.marked_for_death === true)
                {
                    continue;
                }
                if(self istouching(zombie))
                {
                    zombie.marked_for_death = 1;
                    zombie.a.gib_ref = array::random(array("guts", "right_arm", "left_arm", "head"));
		            zombie thread zombie_death::do_gib();
                    origin = zombie gettagorigin("J_Spine1");
                    playfx(level._effect["fan_trap_blood"], zombie.origin + vectorscale((0, 0, 1), 35));
                    zombie dodamage(zombie.health + 1000, zombie.origin);
                }
            }
            wait 0.1;
        }
    };
    level.custom_acid_trap_damage_func = serious::zm_alcatraz_island_acid_trap_damage;
    level.b_no_pap_poi = true; // cannot spawn at pap as a poi
    level flag::set("afterlife_start_over");
}

zm_alcatraz_island_spawned()
{
    self.var_6c7ef100 = 0;
    self.afterlife = 0;

    self thread wait_for_blundersplat_fired();

    while(!isdefined(self.var_3bda977c))
    {
        wait 1;
    }

    self.var_3bda977c.x = 10000;
    self.var_3bda977c.y = 10000;
    self.var_3bda977c.alpha = 0;
    if(isdefined(self.var_dfd69a5b))
    {
        self.var_dfd69a5b hud::setparent(self.var_3bda977c);
        self.var_dfd69a5b.x = 10000;
        self.var_dfd69a5b.y = 10000;
        self.var_dfd69a5b.alpha = 0;
    }
    foreach(weapon in self GetWeaponsList())
    {
        if(weapon.rootweapon.name ?& issubstr(weapon.rootweapon.name, "shank"))
        {
            self takeweapon(weapon);
        }
    }
}

// damage that the unupgraded acidgat will do per round. upgraded is 2x.
// default value: 150
#define ACIDGAT_DAMAGE_PER_ROUND = 150; // n * 3 * 2 * 20
zm_alcatraz_island_weapons()
{
    remove_box_weapon("pistol_fiveseven_dw");
    register_weapon_scalar("bo2_minigun", "bo2_minigun_upgraded", 2, 2);
    register_weapon_scalar("bo2_blundergat", "bo2_blundergat_upgraded", 0.8, 0.8);
    register_weapon_scalar("bo2_dsr", "bo2_dsr_upgraded", 4, 4);
    level.f_unregistered_weapon_scalar = 1.75;
}

zm_alcatraz_island_roundnext()
{
    foreach(player in getplayers())
    {
        player.var_6c7ef100 = 0;
    }
}

zm_alcatraz_island_afterlife()
{
    self.afterlife = 0;
    level flag::set("afterlife_start_over");
}

zm_alcatraz_island_threaded()
{
    foreach(player in getplayers())
    {
        player.var_6c7ef100 = 0;
    }

    level flag::wait_till("initial_blackscreen_passed");
    level.custom_perk_validation = undefined;
    level.brutus_max_count = 0;
    level.brutus_rounds_enabled = false;
    level.next_brutus_round = 999;

    level.soul_catchers_charged = 999;
    foreach(catcher in level.soul_catchers)
    {
        catcher.is_charged = true;
        catcher.souls_received = 9;
    }

    level notify("gondola_powered_on_roof");
    level notify("unlock_all_perk_machines");
    level notify("cell_1_powerup_activate");
    level notify("cell_2_powerup_activate");
    level notify("intro_powerup_restored");
    level notify(#"hash_7da979af");
    level notify(#"hash_5f89f6f3");
    level notify("activate_warden_office");

    foreach(s_piece in level.zombie_include_craftables["quest_key1"].a_piecestubs)
    {
        if(isdefined(s_piece.pieceSpawn))
        {
            level.players[0] zm_craftables::player_take_piece(s_piece.pieceSpawn);
        }
    }

    foreach(s_piece in level.zombie_include_craftables["plane"].a_piecestubs)
    {
        if(isdefined(s_piece.pieceSpawn))
        {
            s_piece.pieceSpawn zm_craftables::piece_unspawn();
        }
    }

    foreach(trig in level.a_uts_craftables)
    {
        if(trig.craftablestub.str_to_craft == level.zombie_include_craftables["plane"].str_to_craft)
        {
            zm_unitrigger::unregister_unitrigger(trig);
        }
    }

    getent("claymore_trigger", "targetname").origin = ORIGIN_OOB;

    foreach(s_trig in level.struct_class_names["targetname"]["afterlife_trigger"])
    {
        zm_unitrigger::unregister_unitrigger(s_trig.unitrigger_stub);
    }

    level.struct_class_names["targetname"]["afterlife_trigger"] = [];

    pap_spot = (3590.68, -864.209, 5987.69 + 3 + 52);
    pap_angles = (0, 90, 0);
    foreach(pap in GetEntArray("pack_a_punch", "script_noteworthy"))
    {
        if(!isdefined(pap.target))
            continue;
        
        ent = GetEnt(pap.target, "targetname");

        if(!isdefined(ent))
            continue;

        ent.origin = pap_spot;
        ent.angles = pap_angles;
        pap.origin = pap_spot;
        pap.angles = pap_angles;
    }
    
    foreach(pap in GetEntArray("specialty_weapupgrade", "script_noteworthy"))
    {
        if(!isdefined(pap.target))
            continue;
        
        ent = GetEnt(pap.target, "targetname");

        if(!isdefined(ent))
            continue;

        ent.origin = pap_spot;
        ent.angles = pap_angles;
        pap.origin = pap_spot;
        pap.angles = pap_angles;
    }

    getent("elevator_trigger", "targetname").origin = ORIGIN_OOB;
    getent("elevator_trigger_top", "targetname").origin = ORIGIN_OOB;
}
#endregion

#region zm_log_kowloon
autoexec zm_log_kowloon_patch()
{
    if(tolower(getdvarstring("mapname")) == "zm_log_kowloon")
    {
        compiler::erasefunc("scripts/zm/zm_coldwar_hud_lua.gsc", 0xd2c890be, 0x639f47fe);
        compiler::erasefunc("scripts/zm/zm_coldwar_hud_lua.gsc", 0xd2c890be, 0xE2AB5024);
        callback::on_connect(serious::function_639f47fe);
        callback::on_connect(serious::kowloon_playerhealth);

        compiler::script_detour("scripts/zm/zm_zipline_z.gsc", #namespace_68a0b257, #function_22080fd1, function(start_point, var_19810bf8, moving_ent, var_9cb3ccfc) =>
        {
            //self endon(#bled_out);
            self endon(#disconnect);
            moving_ent.origin = self.origin + (0, 0, 0);
            moving_ent.angles = self.angles;
            current_weapon = self getcurrentweapon();
            var_c3879214 = level.var_c3879214;
            var_b4b74721 = level.var_b4b74721;
            var_e0debf0b = level.var_e0debf0b;
            var_4e534cec = 20;
            self setstance("stand");
            self giveweapon(getweapon("bo1_zipline"));
            self switchtoweapon(getweapon("bo1_zipline"));
            self freezecontrolsallowlook(1);
            self disableweaponcycling();
            wait(0.25);
            self playerlinktodelta(moving_ent, "tag_origin", 1, 65, 65, 40, 40);
            moving_ent playsound("evt_zipline_grab");
            moving_ent rotateto(start_point.angles, var_e0debf0b);
            moving_ent moveto(start_point.origin, var_e0debf0b);
            moving_ent waittill(#movedone);
            moving_ent playloopsound("evt_zipline_slide");
            moving_ent moveto(var_19810bf8, var_9cb3ccfc, var_c3879214, var_b4b74721);
            dist = distance2d(moving_ent.origin, var_19810bf8);
            self setdepthoffield(0, 10, 512, 4000, 12, 8);
            moving_ent waittill(#movedone);
            while(dist > var_4e534cec)
            {
                wait(0.05);
                dist = distance2d(moving_ent.origin, var_19810bf8);
            }
            moving_ent stoploopsound(0.5);
            moving_ent playsound("evt_zipline_free");
            self unlink();
            self freezecontrolsallowlook(0);
            self setdepthoffield(0, 0, 512, 4000, 4, 0);
            if(isdefined(current_weapon) && current_weapon != "none" && self hasweapon(current_weapon))
            {
                self switchtoweapon(current_weapon);
                self util::wait_endon(2, "weapon_raising");
            }
            else
            {
                primaries = self getweaponslistprimaries();
                if(isdefined(primaries) && primaries.size > 0 && primaries[0] != "none")
                {
                    self switchtoweapon(primaries[0]);
                }
                self util::wait_endon(2, "weapon_raising");
            }
            self enableweaponcycling();
            self takeweapon(getweapon("bo1_zipline"));
            moving_ent notify(#zip);
        });

    }
}

function_639f47fe()
{
	self endon("disconnect");
	level flag::wait_till("initial_players_connected");
	level flag::wait_till("initial_blackscreen_passed");
	for(;;)
	{
        self util::waittill_any_timeout(2, "weapon_change", "weapon_give");
		weapon = self getcurrentweapon();
		var_2262e63f = zm_weapons::is_weapon_upgraded(weapon);
		self luinotifyevent(&"IsPlayerWeaponPacked", 1, var_2262e63f);
		wait(0.1);
	}
}

kowloon_playerhealth()
{
    self endon("disconnect");
	level flag::wait_till("initial_players_connected");
    setdvar("sv_cheats", 0);
	level flag::wait_till("initial_blackscreen_passed");
    setdvar("sv_cheats", 0);
	wait(0.5);
	var_61fcaea0 = [];
	var_61fcaea0[0] = 1;
	var_61fcaea0[1] = 1;
	var_61fcaea0[2] = 1;
	health = self.health;
	maxhealth = self.maxhealth;
	for(;;)
	{
		if(health != self.health || maxhealth != self.maxhealth)
		{
			health = self.health;
            maxhealth = self.maxhealth;
            self luinotifyevent(&"PlayerHealth", 5, health, maxhealth, var_61fcaea0[0], var_61fcaea0[1], var_61fcaea0[2]);
		}
		wait(0.15);
	}
}

zm_log_kowloon_init()
{
    // objpoints::delete error?
    setdvar("sv_cheats", 0);
    // kill their custom hitmarkers
    arrayremovevalue(level.zombie_damage_callbacks, @namespace_74571cc1<scripts\zm\hitmarkers.gsc>::function_b9a10f85, false);
    zm_spawner::deregister_zombie_death_event_callback(@namespace_74571cc1<scripts\zm\hitmarkers.gsc>::function_50fb33c8);

    foreach(ent in getentarray("perk_quest_1", "targetname"))
    {
        ent.origin = ORIGIN_OOB;
    }

    level.var_798918aa = [];
    level.var_1d41d99b = 0;
}

zm_log_kowloon_threaded()
{
    // fix perks
    fix_elemental_pop();
    fix_vigor_rush();
    delete_perk_by_names("specialty_jetquiet", "vending_ffyl");
    fix_perk_ICU(@var_e423d491<scripts\zm\logical\perks\_zm_perk_icu.gsc>::function_e0aed1f6);
    delete_perk_by_names("specialty_quieter", "vending_tactiquilla");

    // do custom power
	foreach(power_switch in getentarray("kw_power_switches_area", "targetname"))
	{
		trig = getent(power_switch.target, "targetname");
        trig notify("trigger", level.players[0]);
	}

    // kill challenges
    for(i = 1; i < 4; i++)
    {
        getent("lantern_challenge_" + i, "targetname").origin = ORIGIN_OOB;
    }
    getent("lantern_gate_wall_trigger_hint", "targetname").origin = ORIGIN_OOB;
    
    // kill sidequests
    if(getent("skip_5_rounds_trig", "targetname") is defined)
    {
        getent("skip_5_rounds_trig", "targetname").origin = ORIGIN_OOB;
    }
    
	foreach(trig in getentarray("highround_skip_trigs", "targetname"))
	{
		trig.origin = ORIGIN_OOB;
	}
    getent("egg_place_cooked_trig", "targetname").origin = ORIGIN_OOB;

    // delete buyable ending
    getent("end_game_trigger", "targetname").origin = ORIGIN_OOB;

    // unlock debris because the triggers are too tight
    unlock_all_debris();

    level._custom_powerups["money_team"].grab_powerup = function(player) =>
    {
        player playlocalsound("zombie_money_vox");
        points = int(250 * CLAMPED_ROUND_NUMBER);
        players = getplayers();
        for(i = 0; i < players.size; i++)
        {
            if(players[i].team != player.team)
            {
                continue;
            }
            if(!players[i] laststand::player_is_in_laststand() && players[i].sessionstate == "playing")
            {
                players[i] zm_score::add_to_player_score(points);
            }
        }
    };

    if(level._custom_powerups["money"] is defined)
    {
        level._custom_powerups["money"].grab_powerup = function(player) =>
        {
            player playlocalsound("zombie_money_vox");
            player zm_score::add_to_player_score(int(400 * CLAMPED_ROUND_NUMBER));
            level notify(#"hash_bdde100a");
        };
    }
}

zm_log_kowloon_weapons()
{
    enable_slipgun(@namespace_d41c2943<scripts\zm\_zm_weap_slipgun.gsc>::add_slippery_spot);
    // register_weapon_scalar("t9_zm_raygun", "t9_zm_raygun_up", 0.85, 0.85);

    fn_special_raygun_up = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        if(sMeansOfDeath == "MOD_PROJECTILE")
        {
            return int(result * 4);
        }

        return int(min(result, 5000));
    };

    fn_special_raygun = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        if(sMeansOfDeath == "MOD_PROJECTILE")
        {
            return int(result * 3);
        }

        return int(min(result, 2500));
    };
    register_weapon_calculator("t9_zm_raygun", fn_special_raygun);
    register_weapon_calculator("t9_zm_raygun_up", fn_special_raygun_up);

    // register_weapon_scalar("t9_zm_rayrifle", "t9_zm_rayrifle_up", 0.23 / 3, 0.23 / 3);
    // register_weapon_scalar("t9_sniper_powersemi", "t9_sniper_powersemi_up", 0.5, 0.33);
    // register_weapon_scalar("t9_streak_death_machine", "t9_streak_death_machine_up", 0.1, 0.1);
    register_weapon_postcalc("t9_zm_raygun", true);
    register_weapon_postcalc("t9_zm_raygun_up", true);

    // register_weapon_scalar("t9_pistol_semiauto", "t9_pistol_semiauto_up", 1.0, 1.0);
    // register_weapon_scalar("t9_pistol_revolver", "t9_pistol_revolver_up", 1.0, 2.0);
    // register_weapon_scalar("t9_pistol_burst", "t9_pistol_burst_up", 1.0, 1.75);
    // register_weapon_scalar("t9_shotgun_semiauto", "t9_shotgun_semiauto_up", 1.0, 0.85);
    // register_weapon_scalar("t9_sniper_standard", "t9_sniper_standard_up", 2.0, 2.0);
    // register_weapon_hd_modifier("t9_sniper_standard", "t9_sniper_standard_up", 0.7);
    // register_weapon_scalar("t9_sniper_quickscope", "t9_sniper_quickscope_up", 2.5, 2.5);
    // register_weapon_hd_modifier("t9_sniper_quickscope", "t9_sniper_quickscope_up", 0.5);
    // register_weapon_scalar("t9_shotgun_fullauto", "t9_shotgun_fullauto_up", 2.7, 2.7);
    // register_weapon_scalar("t9_tr_precisionsemi", "t9_tr_precisionsemi_up", 3.0, 3.0);
    // register_weapon_head_modifier("t9_tr_precisionsemi", "t9_tr_precisionsemi_up", 0.5);
    // register_weapon_hd_modifier("t9_tr_precisionsemi", "t9_tr_precisionsemi_up", 0.5);
    // register_weapon_scalar("t9_tr_longburst", "t9_tr_longburst_up", 2.0);
    // register_weapon_scalar("t9_tr_powerburst", "t9_tr_powerburst_up", 1.5);
    // register_weapon_scalar("t9_lmg_light", "t9_lmg_light_up", 1.5, 1.5);
    // register_weapon_scalar("t9_smg_accurate", "t9_smg_accurate_up", 6.0, 4.0);
    // register_weapon_head_modifier("t9_smg_accurate", "t9_smg_accurate_up", 0.5);
    // register_weapon_scalar("t9_smg_fastfire", "t9_smg_fastfire_up", 4.0, 3.0);
    // register_weapon_head_modifier("t9_smg_fastfire", "t9_smg_fastfire_up", 0.6);
    // register_weapon_scalar("t9_smg_handling", "t9_smg_handling_up", 1.0, 2.0);
    // register_weapon_head_modifier("t9_smg_handling_up", "t9_smg_handling_up", 0.7);
    // register_weapon_scalar("t9_smg_burst", "t9_smg_burst_up", 8.0, 5.0);
    // register_weapon_head_modifier("t9_smg_burst", "t9_smg_burst_up", 0.5);
    // register_weapon_scalar("t9_smg_heavy", "t9_smg_heavy_up", 5.0, 3.5);
    // register_weapon_head_modifier("t9_smg_heavy", "t9_smg_heavy_up", 0.5);
    // register_weapon_scalar("t9_smg_capacity", "t9_smg_capacity_up", 6.0, 4.0);
    // register_weapon_head_modifier("t9_smg_capacity", "t9_smg_capacity_up", 0.5);
    // register_weapon_scalar("t9_smg_standard", "t9_smg_standard_up", 6.0, 4.0);
    // register_weapon_head_modifier("t9_smg_standard", "t9_smg_standard_up", 0.6);
    // register_weapon_scalar("t9_ar_mobility", "t9_ar_mobility_up", 1.5);
    // register_weapon_scalar("t9_ar_standard", "t9_ar_standard_up", 1.5);
}

zm_log_kowloon_spawned()
{
    self thread slipgun_pvp();
}
#endregion
#endregion

#region DLC2

#region zm_wildwest
zm_wildwest_weapons()
{
    level.f_unregistered_weapon_scalar = 3.0;
    register_weapon_scalar("m2_flamethrower", undefined, 50.0);
    register_weapon_scalar("cheytac", "cheytac_upgraded", 5.0, 5.0);
    register_weapon_scalar("bo1_l96a1", "bo1_l96a1_upgraded", 5.0, 5.0);
    register_weapon_scalar("m1garand", "m1garand_upgraded", 1.0, 1.0);
    register_weapon_scalar("mw3_aa12", "mw3_aa12_upgraded", 1.0, 1.0);

    callback::remove_on_spawned(@zm_flamethrower<scripts\zm\zm_flamethrower.gsc>::flamethrower_swap);
    callback::remove_on_spawned(@namespace_1fdc3748<scripts\zm\zm_wildwest.gsc>::function_3679a65); // kill the stupid endgame thing that doesnt check if you ever die
    
    fn_wolfshowl = function() =>
    {
        self notify("fn_wolfshowl");
        self endon("fn_wolfshowl");
        self endon("disconnect");

        fn_wolfshowl_fired = function(isupgraded, player) =>
        {
            self_pos = self geteye();
            trigger = spawn("script_model", self_pos);
            trigger setmodel("tag_origin");
            vec = anglestoforward(self getplayerangles());
            mo = self.origin;
            end2 = ((vec[0] * 250, vec[1] * 250, vec[2] * 250) + mo) + vectorscale((0, 0, 1), 32);
            speed = distance(mo, end2) / 800;
            trigger moveto(end2, speed);
            wait(0.1);
            trigger thread 
            [[
                function(player, isupgraded = 0) => 
                {
                    self endon("death");
                    dps_players = [];
                    for(;;)
                    {
                        foreach(enemy in level.players)
                        {
                            if(enemy.team == player.team)
                            {
                                continue;
                            }
                            if(enemy.sessionstate != "playing")
                            {
                                continue;
                            }
                            if(isinarray(dps_players, enemy))
                            {
                                continue;
                            }
                            if(distance(enemy.origin, self.origin) < level.var_771b36e3)
                            {
                                dps_players[dps_players.size] = enemy;
                                n_damage = STAFF_WATER_DPS * CLAMPED_ROUND_NUMBER * 0.25;

                                if(!isdefined(enemy.ice_damage_mp))
                                {
                                    enemy.ice_damage_mp = 0.75;
                                }

                                enemy.ice_damage_mp += (int(isupgraded) + 1) * 0.125; // spam fire increases dps

                                // do some of the damage up front as impact damage
                                enemy dodamage(int(n_damage), enemy.origin, player, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                                enemy thread ice_affect_zombie(level.var_ceab76d7, player, enemy.ice_damage_mp);
                            }
                        }
                        wait 0.1;
                    }
                }
            ]](player, isupgraded);
            wait(speed);
            trigger delete();
        };

        for(;;)
        {
            self waittill("weapon_fired", weapon);
            if(!isdefined(weapon))
            {
                continue;
            }
            if(weapon == level.var_ceab76d7 || weapon == level.var_bcac2ec3)
            {
                self thread [[ fn_wolfshowl_fired ]](weapon == level.var_bcac2ec3, self);
            }
        }
    };

    callback::on_connect(fn_wolfshowl);
    foreach(player in level.players)
    {
        player thread [[ fn_wolfshowl ]]();
    }
}

zm_wildwest_threaded()
{
    level flag::wait_till("initial_blackscreen_passed");
    wait 0.05;

    delete_perk_by_names("specialty_vultureaid", "vending_vulture"); // this map has brain damage vulture aid that spams csc errors. no thanks
    delete_perk_by_names("specialty_tombstone", "vending_tombstone");
    delete_whos_who();

    level.playersuicideallowed = false;
	level.canplayersuicide = function() => { return false; };

    level notify(#"hash_de5841e5");

    foreach(subsystem in array("grow_soul", "grow_soul2", "grow_soul3"))
    {
        ending = getent(subsystem + "_ending", "targetname");

        if(isdefined(ending))
        {
            ending.origin = ORIGIN_OOB;
        }

        foreach(ent in getentarray(subsystem, "targetname"))
        {
            ent.origin = ORIGIN_OOB;
            ent notsolid();
        }

        foreach(trig in getentarray(subsystem + "_door", "targetname"))
        {
            if(isdefined(trig.script_flag))
            {
                level flag::set(trig.script_flag);
            }
            if(isdefined(trig.target))
            {
                doors = getentarray(trig.target, "targetname");
                foreach(door in doors)
                {
                    door notsolid();
					door connectpaths();
                    door delete();
                }
            }
        }
    }

    getent("iw_bank_deposit", "targetname").origin = ORIGIN_OOB;
    getent("iw_bank_withdrawal", "targetname").origin = ORIGIN_OOB;
    getent("perk_potion", "targetname").origin = ORIGIN_OOB;
    foreach(ent in getentarray("potion_trig", "targetname"))
    {
        ent.origin = ORIGIN_OOB;
    }

    level.allparts = 2;
    getent("use_elec_switch", "targetname").origin = ORIGIN_OOB;
    getent("elec_switch", "script_noteworthy").origin = ORIGIN_OOB;
    getent("powcraft_clip_build", "targetname").origin = ORIGIN_OOB;
    getent("powcraft_build1", "targetname").origin = ORIGIN_OOB;
}
#endregion

#region zm_survival
#define ZM_SURVIVAL_ERG_DPR = 1100;
#define ZM_SURVIVAL_MRG_DPR = 500;
#define ZM_SURVIVAL_YRG_DPR = 900;
#define ZM_SURVIVAL_ZRG_DPR = 1400;
zm_survival_weapons()
{
    // some levels that are small may require hiding players on spawn so they have a chance to live
    level.zbr_hide_spawnprotect = true;
    level.customs_zombie_damage_scalar = 2;

    fn_weapon_raygun_calc = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        switch(weapon.rootweapon.name)
        {
            case "bo4_ray_gun_m":
                return int(CLAMPED_ROUND_NUMBER * ZM_SURVIVAL_MRG_DPR / 2);
            break;

            case "bo4_ray_gun_m_up":
                return int(CLAMPED_ROUND_NUMBER * ZM_SURVIVAL_MRG_DPR);
            break;

            case "bo4_ray_gun_e":
                return int(CLAMPED_ROUND_NUMBER * ZM_SURVIVAL_ERG_DPR / 2);
            break;

            case "bo4_ray_gun_e_up":
                return int(CLAMPED_ROUND_NUMBER * ZM_SURVIVAL_ERG_DPR);
            break;

            case "bo4_ray_gun_y":
                if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH")
                {
                    return int(CLAMPED_ROUND_NUMBER * ZM_SURVIVAL_YRG_DPR / 4);
                }
                return int(CLAMPED_ROUND_NUMBER * ZM_SURVIVAL_YRG_DPR / 2);
            break;

            case "bo4_ray_gun_y_up":
                if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH")
                {
                    return int(CLAMPED_ROUND_NUMBER * ZM_SURVIVAL_YRG_DPR / 2);
                }
                return int(CLAMPED_ROUND_NUMBER * ZM_SURVIVAL_YRG_DPR);
            break;

            case "bo4_ray_gun_z":
                if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH")
                {
                    return int(CLAMPED_ROUND_NUMBER * ZM_SURVIVAL_ZRG_DPR / 4);
                }
                return int(CLAMPED_ROUND_NUMBER * ZM_SURVIVAL_ZRG_DPR / 2);
            break;

            case "bo4_ray_gun_z_up":
                if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH")
                {
                    return int(CLAMPED_ROUND_NUMBER * ZM_SURVIVAL_ZRG_DPR / 2);
                }
                return int(CLAMPED_ROUND_NUMBER * ZM_SURVIVAL_ZRG_DPR);
            break;
        }
        return result;
    };

    a_str_rayguns = [ "bo4_ray_gun_e", "bo4_ray_gun_m", "bo4_ray_gun_y", "bo4_ray_gun_z" ];

    foreach(str_weapon in a_str_rayguns)
    {
        register_weapon_postcalc(str_weapon, true);
        register_weapon_calculator(str_weapon, fn_weapon_raygun_calc);

        register_weapon_postcalc(str_weapon + "_up", true);
        register_weapon_calculator(str_weapon + "_up", fn_weapon_raygun_calc);
    }

    register_box_weapon("hero_annihilator");

    // map meta:
    // ray guns should be best
    // mark 2 should be OK because of its ease of use

    // Weak: < 20K DPS
    // Acceptible: 25K dps
    // Strong: 35K dps
    // Very Strong: 45K dps
    // Meta: 55K dps
    // OP: 65k+ dps

    // pistols: Acceptible: 25K dps
    // shotguns: Strong: 35K dps
    // smgs: Very Strong: 45K dps
    // ars: Very Strong: 45K dps
    // snipers: Very Strong: 45K dps
    // LMGS: Strong: 35K dps

    level.balance_adjust_easy_scalar = 0.25;
    register_weapon_scalar("lmg_rpk", "lmg_rpk_upgraded", 3.57, 3.57);
    register_weapon_scalar("launcher_ex41", "launcher_ex41_upgraded", 3.08, 3.08);
    register_weapon_scalar("smg_mp40_1940", "smg_mp40_1940_upgraded", 6.52, 6.52);
    register_weapon_scalar("smg_msmc", "smg_msmc_upgraded", 6.05, 6.05);
    register_weapon_scalar("ar_an94", "ar_an94_upgraded", 6.75, 6.75);
    register_weapon_scalar("t8_rk7", "t8_rk7_up", 1 / level.balance_adjust_easy_scalar * 2, 1 / level.balance_adjust_easy_scalar * 2);
    register_weapon_scalar("t8_outlaw", "t8_outlaw_up", 1.58, 1.58);
    register_weapon_scalar("t8_gks", "t8_gks_up", 6.49, 6.49);
    register_weapon_scalar("t8_welling", "t8_welling_up", 6, 0.189);
    register_weapon_scalar("t8_rampage", "t8_rampage_up", 0.48, 0.48);
    register_weapon_scalar("t8_kap45", "t8_kap45_up", 4.8, 4.8);
    register_weapon_scalar("t8_grav", "t8_grav_up", 7.5, 7.5);
    register_weapon_scalar("t8_daemon3xb", "t8_daemon3xb_up", 1.5, 1.5);
    register_weapon_scalar("t8_vapr_xkg", "t8_vapr_xkg_up", 1.5, 1.5);
    register_weapon_scalar("t8_titan", "t8_titan_up", 2.01, 2.01);
    register_weapon_scalar("t8_swat_rft", "t8_swat_rft_up", 1, 1);
    register_weapon_scalar("t8_swordfish", "t8_swordfish_up", 1.43, 1.43);
    register_weapon_scalar("t8_strife", "t8_strife_up", 1, 1);
    register_weapon_scalar("t8_spitfire", "t8_spitfire_up", 3.57, 3.57);
    register_weapon_scalar("t8_sg12", "t8_sg12_up", 0.17, 0.17);
    register_weapon_scalar("t8_saug9mm", "t8_saug9mm_up", 2, 1);
    register_weapon_scalar("t8_rampart17", "t8_rampart17_up", 2.77, 2.77);
    register_weapon_scalar("t8_paladin_hb50", "t8_paladin_hb50_up", 1.60, 1.60);
    register_weapon_scalar("t8_mx9", "t8_mx9_up", 3.32, 3.32);
    register_weapon_scalar("t8_mozu", "t8_mozu_up", 0.66, 0.66);
    register_weapon_scalar("t8_mog12", "t8_mog12_up", 6.37, 6.37);
    register_weapon_scalar("t8_maddox_rfb", "t8_maddox_rfb_up", 1.49, 1.49);
    register_weapon_scalar("t8_m1927", "t8_m1927_up", 1.7, 1.7);
    register_weapon_scalar("t8_m1897", "t8_m1897_up", 5.81, 5.81);
    register_weapon_scalar("t8_koshka", "t8_koshka_up", 4.8, 4.8);
    register_weapon_scalar("t8_kn57", "t8_kn57_up", 1.7, 1.7);
    register_weapon_scalar("t8_icr7", "t8_icr7_up", 1.6, 1.6);
    register_weapon_scalar("t8_hellion_salvo", "t8_hellion_salvo_up", 1 / level.balance_adjust_easy_scalar * 3, 1 / level.balance_adjust_easy_scalar * 3);
    register_weapon_scalar("t8_zweihander", "t8_zweihander_up", 1.98, 1.98);
    register_weapon_scalar("t8_essex_m07", "t8_essex_m07_up", 1.41, 1.41);
    register_weapon_scalar("t8_escargot", "t8_escargot_up", 2.77, 2.77);
    register_weapon_scalar("t8_auger_dmr", "t8_auger_dmr_up", 1, 1);
    register_weapon_scalar("t8_abr223", "t8_abr223_up", 3.67, 3.67);
    register_weapon_scalar("t7_raygun_mark2", "t7_raygun_mark2_upgraded", 0.5, 0.5);
    level.balance_adjust_easy_scalar = 1.0;

    register_weapon_postcalc("t8_hellion_salvo", true);
    register_weapon_postcalc("launcher_ex41_upgraded", true);
}

zm_survival_threaded()
{
    level flag::wait_till("initial_blackscreen_passed");

    // kill their custom hitmarkers
    arrayremovevalue(level.zombie_damage_callbacks, @namespace_74571cc1<scripts\__robit\hitmarkers.gsc>::function_9c301f1a, false);
    zm_spawner::deregister_zombie_death_event_callback(@namespace_74571cc1<scripts\__robit\hitmarkers.gsc>::function_5adbafc9);
    
    wait 3;
    level.next_avogadro_round = 9999;
    level.var_827ee7fb = 999;
}
#endregion

#region zm_town_hd
autoexec zm_town_hd_patch()
{
    if(tolower(getdvarstring("mapname")) == "zm_town_hd")
    {
        // start menu
        level.var_ee71e4d = true;
        compiler::erasefunc("scripts/zm/mc_zombie_counter.gsc", 0xa317f9c2, 0x17C88E2A); // zombie counter
        compiler::erasefunc("scripts/zm/transit_lava.gsc", 0x3201234f, 0x9819DD30); // lava
        compiler::erasefunc("scripts/zm/splash.gsc", 0xA6740DA8, 0xA6740DA8); // splash screen
    }
}

zm_town_hd_init()
{
    level.zbr_hide_spawnprotect = true;

    setdvar("ai_disableSpawn", 0);
	setdvar("ui_enabled", 1);

    // remove zombie counter
    callback::remove_on_ai_spawned(@namespace_a317f9c2<scripts\zm\mc_zombie_counter.gsc>::function_d8b30621);

    // lava
    lava = getentarray("lava_damage", "targetname");
    level.zombie_lava_damage_func = @namespace_3201234f<scripts\zm\transit_lava.gsc>::zombie_lava_damage;
    level.fn_burnplayer = @burnplayer<scripts\shared\_burnplayer.gsc>::setplayerburning;
    level.fn_zombie_death = @zombie_death<scripts\shared\ai\zombie_death.gsc>::on_fire_timeout;

    level.fn_player_lava_damage = function(trig) =>
    {
        level endon("end_game");
        self endon("bled_out");
        self endon("disconnect");

        if(isdefined(self.is_zombie) && self.is_zombie)
        {
            return;
        }

        if(isdefined(self.is_burning) || !zm_utility::is_player_valid(self))
        {
            return;
        }

        if(!isdefined(trig.script_float) || trig.script_float < 0.1)
        {
            return;
        }

        max_dmg = 10;
        min_dmg = 5;
        burn_time = 1;
        max_dmg = max_dmg * trig.script_float;
        min_dmg = min_dmg * trig.script_float;
        burn_time = burn_time * trig.script_float;
        if(burn_time >= 1.5)
        {
            burn_time = 1.5;
        }
        self thread 
        [[ 
            function() => 
            {
                self endon("disconnect");
                self util::waittill_any("bled_out", "stop_flame_damage");
                self notify("stop_flame_damage");
                self notify("burn_finished");
            }
        ]]();

        self.is_burning = true;
        self [[ level.fn_burnplayer ]](burn_time, 0, 0, undefined, undefined);
        self notify("burned");

        if(self.is_on_fire !== true)
        {
            self thread 
            [[
                function() =>
                {
                    self endon("bled_out");
                    self endon("disconnect");

                    self.is_on_fire = true;
                    self.flame_fx_timeout = 6;
                    self thread [[ level.fn_zombie_death ]]();

                    if(isdefined(level._effect) && isdefined(level._effect["character_fire_death_sm"]))
                    {
                        origin = self gettagorigin("j_spinelower");
                        var_25a31987 = util::spawn_model("tag_origin", origin, self.angles);
                        var_25a31987 linkto(self, "j_spinelower");
                        var_25a31987.fx = playfxontag(level._effect["character_fire_death_sm"], var_25a31987, "tag_origin");
                        self thread 
                        [[
                            function(var_25a31987) =>
                            {
                                var_25a31987 endon("death");
                                self util::waittill_any("stop_flame_damage", "bled_out", "disconnect");
                                if(isdefined(var_25a31987.fx))
                                {
                                    var_25a31987.fx delete();
                                }
                                var_25a31987 delete();
                            }
                        ]](var_25a31987);
                    }
                }
            ]]();
        }

        if(!self hasperk("specialty_armorvest"))
        {
            self dodamage(int((CLAMPED_ROUND_NUMBER - 2) * 25), self.origin);
        }
        else
        {
            self dodamage(10, self.origin);
        }

        wait(0.1);
        self.is_burning = undefined;
    };

    array::thread_all(lava, function() => 
    {
        level endon("end_game");
        self endon("death");

        self._trap_type = "";
        if(isdefined(self.script_noteworthy))
        {
            self._trap_type = self.script_noteworthy;
        }

        for(;;)
        {
            foreach(player in level.players)
            {
                ent = player;
                if(isdefined(ent.ignore_lava_damage) && ent.ignore_lava_damage)
                {
                    continue;
                }
                if(isdefined(ent.is_burning))
                {
                    continue;
                }
                if(isplayer(ent) && ent hasperk("specialty_phdflopper"))
                {
                    continue;
                }
                if(player.sessionstate != "playing")
                {
                    continue;
                }
                if(player istouching(self))
                {
                    player thread [[ level.fn_player_lava_damage ]](self);
                }
            }

            foreach(zombie in GetAITeamArray(level.zombie_team))
            {
                if(!isdefined(zombie) || !isalive(zombie))
                {
                    continue;
                }

                ent = zombie;
                if(isdefined(ent.ignore_lava_damage) && ent.ignore_lava_damage)
                {
                    continue;
                }
                if(isdefined(ent.is_burning))
                {
                    continue;
                }
                if(isplayer(ent) && ent hasperk("specialty_phdflopper"))
                {
                    continue;
                }
                if(zombie istouching(self))
                {
                    zombie thread [[ level.zombie_lava_damage_func ]](self);
                }
            }
            wait(0.15);
        }
    });

    // dogs
    level.next_dog_round = 9999;
}

zm_town_hd_weapons()
{
    // claymores
    register_weapon_postcalc("claymore", true);
    register_weapon_calculator("claymore", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(CLAMPED_ROUND_NUMBER * 1500);
    });

    // semtex
    register_weapon_postcalc("sticky_grenade", true);
    register_weapon_calculator("sticky_grenade", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(CLAMPED_ROUND_NUMBER * 500);
    });
}

zm_town_hd_spawned()
{
    level.fn_claymore_watcher = function(angles) =>
    {
        self endon("death");

        while(!isdefined(self.damagearea))
        {
            wait 0.05;
        }

        self.damagearea endon("death");
        while(isdefined(self.damagearea))
        {
            foreach(player in level.players)
            {
                if(player.sessionstate != "playing")
                {
                    continue;
                }
                
                if(player.team == self.owner.team)
                {
                    continue;
                }

                if(player istouching(self.damagearea))
                {
                    self.damagearea notify("trigger", player);
                    break;
                }
            }

            foreach(zombie in GetAITeamArray(level.zombie_team))
            {
                if(!isdefined(zombie) || !isalive(zombie))
                {
                    continue;
                }

                if(zombie istouching(self.damagearea))
                {
                    self.damagearea notify("trigger", zombie);
                    break;
                }
            }

            wait 0.1;
        }
    };

    // claymores
    self thread 
    [[
        function() =>
        {
            self endon("spawned_player");
            self endon("disconnect");
            self endon("bled_out");
            
            for(;;)
            {
                self waittill("grenade_fire", var_b308cd11, w_weapon);
                if(!isdefined(w_weapon) || w_weapon.name != "claymore")
                {
                    continue;
                }

                var_b308cd11.owner = self;
                var_b308cd11 thread [[ level.fn_claymore_watcher ]](self.angles);
            }
        }
    ]]();
}

zm_town_hd_threaded()
{
    delete_perk_by_names("specialty_tombstone", "vending_tombstone");
}
#endregion

#region zm_three
autoexec zm_three_autoexec()
{
    if(tolower(getdvarstring("mapname")) == "zm_three")
    {
        compiler::erasefunc("scripts/zm/zm_three.gsc", 0x5b9baf5b, 0xA9158DBA); // intro credits
        compiler::erasefunc("scripts/zm/zm_three.gsc", 0x5b9baf5b, 0xcf9cbbb); // zombie counter
        compiler::erasefunc("scripts/zm/zm_three.gsc", 0x5b9baf5b, 0x22ac2766); // zombie move speed
        compiler::erasefunc("scripts/zm/growing_soulbox.gsc", 0xa07a45be, 0xC35E6AAB); // soul boxes
    }
}

zm_three_init()
{
    level.var_ddb9e708 = 999;
    getent("ending", "targetname").origin = ORIGIN_OOB; // buyable ending
    getent("maxammo_trigger", "targetname").origin = ORIGIN_OOB;
    getent("shootable_trig", "targetname").origin = ORIGIN_OOB;
    getent("shootable_trig_2", "targetname").origin = ORIGIN_OOB;
    getent("shootable_trig_3", "targetname").origin = ORIGIN_OOB;
}
#endregion

#region zm_velka
autoexec zm_velka_autoexec()
{
    if(tolower(getdvarstring("mapname")) == "zm_velka")
    {
        compiler::erasefunc("scripts/zm/zm_velka.gsc", 0xd750fbee, 0xA9158DBA); // intro credits
        compiler::erasefunc("scripts/zm/zm_velka.gsc", 0x321914d8, 0xd750fbee); // iprints
        compiler::erasefunc("scripts/zm/_zm_ancient_evil_challenges.gsc", 0xecf86d55, 0x9b6abb5); // challenge totems
    }
}

zm_velka_init()
{
    getent("iw_bank_deposit", "targetname").origin = ORIGIN_OOB;
    getent("iw_bank_withdrawal", "targetname").origin = ORIGIN_OOB;
    getent("ending", "targetname").origin = ORIGIN_OOB;
}

zm_velka_threaded()
{
    // kill their custom hitmarkers
    arrayremovevalue(level.zombie_damage_callbacks, @namespace_cf7a5f75<scripts\_nsz\nsz_hitmarkers.gsc>::function_1114d19b, false);
    zm_spawner::deregister_zombie_death_event_callback(@namespace_cf7a5f75<scripts\_nsz\nsz_hitmarkers.gsc>::function_41b85b21);

    level.zombie_powerups["bottomless_clip"].func_should_drop_with_regular_powerups = serious::nullsub;
    level.zombie_powerups["fast_feet"].func_should_drop_with_regular_powerups = serious::nullsub;
    level.zombie_powerups["time_warp"].func_should_drop_with_regular_powerups = serious::nullsub;
}

zm_velka_weapons()
{

}
#endregion

#region zm_47berkerlylane_vkzu
// TODO unfinished
autoexec zm_47berkerlylane_vkzu_autoexec()
{
    if(tolower(getdvarstring("mapname")) == "zm_47berkerlylane_vkzu")
    {
        compiler::erasefunc("scripts/sphynx/commands.gsc", 0x13C90C97, 0xC35E6AAB); // debug commands
        compiler::erasefunc("scripts/vk_script/bl_bunker_door_scene.gsc", 0xece238f9, 0xe7789e74); // on spawned thread leak
        compiler::erasefunc("scripts/zm/_zm_perk_wunderfizz2.gsc", 0x2696077a, 0xc2967418); // delete off brand wonderfizz
        compiler::erasefunc("scripts/zm/zm_47berkerlylane_vkzu.gsc", 0x6df855fb, 0xf51d1e93); // delete perk purchase limit thing
        compiler::erasefunc("scripts/vk_script/bl_igc_intro.gsc", 0x9cf68e4a, 0x5B819C85); // pregame

        foreach(ent in getentarray("contracts_trig", "targetname")) // solves horrible coding that explodes thread count
        {
            ent delete();
        }
    }
}

zm_47berkerlylane_init()
{
    getent("use_power_switch", "targetname") notify("trigger", level.players[0]);
    level flag::set("power_on");
    level flag::set("bunkerexit_flag");
    getent("fire_range_trig_easy", "targetname").origin = ORIGIN_OOB;
    getent("fire_range_trig_hard", "targetname").origin = ORIGIN_OOB;
    getent("trig_ammo_spawn", "targetname").origin = ORIGIN_OOB;

    level.get_player_perk_purchase_limit = undefined; // https://www.youtube.com/watch?v=jm8kiO_OA7U
    
    level notify("round_start");
    thread unlock_all_debris();

    fix_perk_bull_ice_blast();
    delete_perk_crusaders_ale();
    fix_perk_banana_colada();
    fix_madgaz_moonshine();
    delete_whos_who();

    fn_fixup_perklimit = function() => 
    {
        self clientfield::set_player_uimodel("zmHud.perkLimit", level._custom_perks.size - 1);
    };

    callback::on_spawned(fn_fixup_perklimit);
    array::thread_all(level.players, fn_fixup_perklimit);
}

// TODO: concussion_grenade
zm_47berkerlylane_threaded()
{
    // kill their custom hitmarkers
    arrayremovevalue(level.zombie_damage_callbacks, @namespace_449e30ba<scripts\vk_script\bl_hitmarkers.gsc>::function_1114d19b, false);
    zm_spawner::deregister_zombie_death_event_callback(@namespace_449e30ba<scripts\vk_script\bl_hitmarkers.gsc>::function_41b85b21);

    apply_lighting(3);

    wait 2;
    level notify(#"hash_d83f0397");
    wait 2.05;
    getent("uga", "targetname") notify("trigger", level.players[0]);

    trig = getent("trig_valve", "targetname");
	valve = getent(trig.target, "targetname");
    valve show();

	door_left = getent(valve.target, "targetname");
	door_right = getent(door_left.target, "targetname");
	clip = getent(door_right.target, "targetname");
	clip ConnectPaths();
    clip delete();
    trig delete();
    door_right delete();
    door_left delete();

	var_5c8a614 = getent("grab_valves", "targetname");
	getent(var_5c8a614.target, "targetname").origin = ORIGIN_OOB;

    array::thread_all(getentarray("trigs_valve", "targetname"), function() =>
    {
        if(isdefined(self.var_3c7ebc29))
        {
            foreach(stream in self.var_3c7ebc29)
            {
                stream.is_active = true;
            }
        }
        if(isdefined(self.var_62813692))
        {
            foreach(stream in self.var_62813692)
            {
                stream.is_active = true;
            }
        }
    });

    wait 1;
    thread [[ @namespace_4c9d3d00<scripts\vk_script\bl_propane_pipe_system.gsc>::function_89347fa7 ]]();
}
#endregion

#region zm_astoria
autoexec zm_astoria_autoexec()
{
    if(tolower(getdvarstring("mapname")) == "zm_1")
    {
        level.var_b01f60a7 = getentarray("maze_switches", "targetname"); // fixes a crash
        level.var_5b48fcfa = struct::get_array("alistair_grave_weapon");
        level.var_f5764006 = function() => {};

        compiler::erasefunc("scripts/zm/_werewolf_ai.gsc", 0x59f9b153, 0x95a6c7e2); // lets just not
        compiler::erasefunc("scripts/zm/_zm_ast_sq.gsc", 0x2d164742, 0x1a3fa28b); // nah
        compiler::erasefunc("scripts/sphynx/commands/_zm_commands.gsc", 0xb2e35c83, 0x8C87D8EB); // debug commands
        compiler::erasefunc("scripts/sphynx/craftables/_zm_craft_vineshield.gsc", 0x3c88e023, 0xf3b4eaf8); // bad on spawned
        callback::on_spawned(function() =>
        {
            self endon("disconnect");
            self endon("bled_out");
            var_4e7bbc60 = level.var_d7f1e592?.name ?? "";
            str_notify = var_4e7bbc60 + "_pickup_from_table";
            for(;;)
            {
                self waittill(str_notify);
                if(isdefined(self.var_f5c258ba) && self.var_f5c258ba)
                {
                    self zm_equipment::buy("spx_vine_shield_upgraded");
                }
            }
        });
    }
}

zm_astoria_init()
{
    level.zbr_glow_fx = "zombie/fx_powerup_on_red_zmb";

    // kill their custom hitmarkers
    arrayremovevalue(level.zombie_damage_callbacks, @namespace_74571cc1<scripts\__robit\hitmarkers.gsc>::function_9c301f1a, false);
    zm_spawner::deregister_zombie_death_event_callback(@namespace_74571cc1<scripts\__robit\hitmarkers.gsc>::function_5adbafc9);
    
    level flag::set("all_lanterns_collected");
    level flag::set("all_lanterns_shot");
    level flag::set("pap_key_acquired");

    level.get_player_perk_purchase_limit = undefined;
    level._custom_powerups["bonus_points_team"].grab_powerup = function(player) => 
    {
        n_points = randomintrange(1, 25) * 100;
        foreach(_player in level.players)
        {
            if(_player.sessionstate != "playing" || _player.team != player.team)
            {
                continue;
            }
            _player thread zm_powerups::powerup_vo("bonus_points_team");
            _player luinotifyevent(&"zombie_notification", 1, &"HB21_ZM_POWERUPS_BONUS_POINTS");
            _player zm_score::add_to_player_score(n_points);
        }
    };
}

zm_astoria_weapons()
{
    register_box_weapon("raygun_mark2", "raygun_mark2_upgraded");
    register_weapon_scalar("s2_reichs", "s2_reichs_up", 0.25, 0.25);
    register_weapon_scalar("s2_win21", "s2_win21_up", 0.33, 0.33);
    register_weapon_scalar("s2_p38_ldw", "s2_p38_ldw_up", 0.1, 0.1);
    register_weapon_scalar("s2_p38_rdw", "s2_p38_rdw_up", 0.1, 0.1);
    register_weapon_scalar("s2_walther_auto", "s2_walther_auto_up", 0.2, 0.2);
    register_weapon_scalar("s2_svt40", "s2_svt40_up", 0.08, 0.08);
    register_weapon_scalar("s2_ptrs41", "s2_ptrs41_up", 0.03, 0.03);
    register_weapon_scalar("s2_panzerschreck", "s2_panzerschreck_up", 0.5, 0.5);
    register_weapon_scalar("s2_bazooka", "s2_bazooka_up", 0.5, 0.5);
    register_weapon_scalar("s2_m1903", "s2_m1903_up", 0.5, 0.5);
    register_weapon_scalar("s2_m1garand", "s2_m1garand_up", 0.3, 0.3);
    register_weapon_scalar("s2_kar98k_scope", "s2_kar98k_scope_up", 0.4, 0.4);
    register_weapon_scalar("s2_kar98k_irons", "s2_kar98k_irons_up", 0.6, 0.6);

    register_weapon_postcalc("s2_panzerschreck", true);
    register_weapon_postcalc("s2_panzerschreck_up", true);
    register_weapon_postcalc("s2_bazooka", true);
    register_weapon_postcalc("s2_bazooka_up", true);

    fn_im_hybs_im_going_to_make_guns_do_way_too_much_damage_cause_its_fun = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        if(result > 3000)
        {
            result = 3000;
        }
        return result * 0.15;
    };
    register_weapon_calculator("s2_blunderbuss", fn_im_hybs_im_going_to_make_guns_do_way_too_much_damage_cause_its_fun);
    register_weapon_calculator("s2_blunderbuss_up", fn_im_hybs_im_going_to_make_guns_do_way_too_much_damage_cause_its_fun);

    register_weapon_postcalc("t8_allistair_annihalator_upgraded", true);
    fn_allistair = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        if(CLAMPED_ROUND_NUMBER < 10)
        {
            return 250;
        }
        if(sMeansOfDeath == "MOD_PROJECTILE")
            return 2000 * CLAMPED_ROUND_NUMBER;
        return 200 * CLAMPED_ROUND_NUMBER;
    };
    register_weapon_calculator("t8_allistair_annihalator_upgraded", fn_allistair);
}
#endregion

#region zm_basement
autoexec zm_basement_autoexec()
{
    // TODO LUA CRASH
    if(tolower(getdvarstring("mapname")) == "zm_basement")
    {
        system::ignore("zm_game_menu");
    }
}

zm_basement_init()
{
    compiler::catch_exit();
}

zm_basement_weapons()
{

}
#endregion

#region zm_westernz
autoexec zm_wanted_autoexec()
{
    if(tolower(getdvarstring("mapname")) == "zm_westernz")
    {
        system::ignore("inspectable");
        compiler::erasefunc("scripts/zm/_zm_weap_dragonshield.gsc", 0xE492DB2B, 0x7335abdb);
        compiler::erasefunc("scripts/zm/_zm_weap_magmagat.gsc", 0x60798961, 0xf328b19b);

        callback::on_spawned(function() => 
        {
            self endon("disconnect");
            self endon("bled_out");
            fire_projectile = @zm_weap_dragonshield<scripts\zm\_zm_weap_dragonshield.gsc>::function_def57e2d;
            for(;;)
            {
                self waittill("missile_fire", e_projectile, str_weapon);
                if(str_weapon.name != "antler_shield_projectile" && str_weapon.name != "antler_shield_upgraded_projectile")
                {
                    continue;
                }
                e_projectile thread [[ fire_projectile ]](self, str_weapon);
            }
        });

        callback::on_spawned(serious::gm_spectator);

        callback::on_spawned(function() =>
        {
            self endon("bled_out");
            self endon("disconnect");
            for(;;)
            {
                self waittill("missile_fire", e_projectile, str_weapon);
                if(str_weapon.name != "t8_shotgun_magmagat" && str_weapon.name != "t8_shotgun_magmagat_upgraded")
                {
                    continue;
                }
                e_projectile magmagat_fired(str_weapon.name == "t8_shotgun_magmagat_upgraded", self);
            }
        });

        level.fn_downed_reviving_cb = function() =>
        {
            self playsoundtoplayer("wpn_tomahawk_cooldown", self);
            self givemaxammo(self.current_tactical_grenade);
        };

        fx_package = spawnstruct();
        fx_package.impact_upgraded = "harry/tomahawk/fx_tomahawk_impact_ug";
        fx_package.impact_regular = "harry/tomahawk/fx_tomahawk_impact";
        fx_package.cf_hit = "play_tomahawk_hit_sound";
        compiler::erasefunc("scripts/zm/_hb21_zm_weap_tomahawk.gsc", 0x89d026b5, 0xC03A2B24); // tomahawk_thrown
        compiler::erasefunc("scripts/zm/zm_westernz.gsc", 0x950f262d, 0xAEBCF025); // spawn function that is bad
        compiler::erasefunc("scripts/zm/zm_usermap.gsc", 0xD197CC6A, 0x3D040FEE); // spawn function that is bad
        tomahawk_init(@namespace_89d026b5<scripts\zm\_hb21_zm_weap_tomahawk.gsc>::tomahawk_spawn, serious::tomahawk_return_player, fx_package, getweapon("t6_zombie_tomahawk"));
        callback::on_spawned(serious::watch_for_tomahawk_throw);

        level.zbr_dragonshield_name = "antler_shield";
    }
}

zm_wanted_init()
{
    level.zbr_minigun_scalar = 3.0;
    level.fn_pause_zbr_objective = function() =>
    {
        return (self.zone_name ?? "") == "indian_zone";
    };

    // kill their custom hitmarkers
    arrayremovevalue(level.zombie_damage_callbacks, @namespace_bee97303<scripts\zm\_zm_hitmarker.gsc>::function_1114d19b, false);
    zm_spawner::deregister_zombie_death_event_callback(@namespace_bee97303<scripts\zm\_zm_hitmarker.gsc>::function_41b85b21);
    callback::remove_on_ai_spawned(@namespace_bee97303<scripts\zm\_zm_hitmarker.gsc>::function_6a489649);

    level.zbr_disable_killcams = true;
}

zm_wanted_weapons()
{
    level.customs_zombie_damage_scalar = 2.25;
    // level.f_unregistered_weapon_scalar = 2.25;
    level.zbr_glow_fx = "zombie/fx_powerup_on_red_zmb";

    register_box_weapon("t8_shotgun_magmagat", "t8_shotgun_magmagat_upgraded");
    register_box_weapon("tesla_gun", "tesla_gun_upgraded");
    register_box_weapon("t8_shotgun_blundergat", "t8_shotgun_blundergat_upgraded");
    register_box_weapon("t8_shotgun_acidgat", "t8_shotgun_acidgat_upgraded");
    register_box_weapon("m1831", "m1831_upgraded");
    register_box_weapon("ww2_iceaxe", "ww2_iceaxe_upgraded");
    register_box_weapon("ww2_raven", "ww2_raven_upgraded");
    register_box_weapon("t8_allistair_annihalator", "t8_allistair_annihalator_upgraded");
    register_box_weapon("hero_fc4primitivebow");
    register_box_weapon("bo3_boneglass", "bo3_boneglass");
    register_box_weapon("ww2_fliegerfaust", "ww2_fliegerfaust");
    //register_box_weapon(level.zbr_dragonshield_name);
    //remove_box_weapon("thundergun", "thundergun_upgraded");

    // The meta for this map should be oriented around the vast amount of wonderweapons available
    // Most of the wonderweapons are explosives, so the main concern is the ease of use and the asymmetric power from someone with phd to someone without
    // This is a good justification to make explosives slightly less powerful than is expected from wonderweapons.
    // Other than that, here is general purpose balancing:
    //         Wonder-weapons: Best (Map Identity, mostly explosives)
    //         Snipers: Acceptible (map is very open and snipers would dominate if not reigned in)
    //         Shotguns: Strong (map is very large so getting CQB engagements is rare; you should win them.)
    //         SMGs: Weak / untouched (there really isnt a place for these weapons except in very specific places)
    //         ARs: Strong (this map has a lot of medium range engagements)
    //         Explosives: Very Strong (the entire map is designed around explosive use)
    //         LMGs: Acceptible (map would be dominated by these weapons if not reigned in)
    //         Pistols: Very strong (makes the wild west feel)


    level.balance_adjust_easy_scalar = 0.5; // I messed up by factoring all this dps as round 20 dps when its actually round 20 so this scalar will fix that
    
    // register_weapon_scalar("m1827_exp", "m1827_exp_upgraded", 1.96, 1.96);
    // register_weapon_scalar("bo4_escargot", "bo4_escargot_upgraded", 3.24, 3.24);
    // register_weapon_scalar("ww2_ribeyrolles", "ww2_ribeyrolles_upgraded", 2.5, 2.5);
    // register_weapon_scalar("ww2_lewis", "ww2_lewis_upgraded", 1, 1);
    // register_weapon_scalar("lebel_m1811", "lebel_m1811_upgraded", 20.2, 20.2);
    // register_weapon_scalar("fc4_m1887_long", "fc4_m1887_long_upgraded", 20.2, 20.2);
    // register_weapon_scalar("aw_winchester", "aw_winchester_upgraded", 9.96, 9.96);
    // register_weapon_scalar("w1892", "w1892_upgraded", 1, 1);
    // register_weapon_scalar("ww2_winchester94_mark", "ww2_winchester94_mark_upgraded", 3, 3);
    // register_weapon_scalar("doc_w1866_upgraded", undefined, 9.5);
    // register_weapon_scalar("m1896_essex", "m1896_essex_upgraded", 1.58, 1.58);
    // register_weapon_scalar("ww2_mosin", "ww2_mosin_upgraded", 4, 4);
    // register_weapon_scalar("m1903_epic", "m1903_epic_upgraded", 1, 1);
    // register_weapon_scalar("ww2_model21", "ww2_model21_upgraded", 3.13, 3.13);
    // register_weapon_scalar("mwr_ranger", "mwr_ranger_upgraded", 1, 1);
    // register_weapon_scalar("ww2_m1897", "ww2_m1897_upgraded", 1, 1);
    // register_weapon_scalar("m1889", "m1889_upgraded", 2.16, 2.16);
    // register_weapon_scalar("m1887_upgraded", "m1887_lh_upgraded", 11.3, 11.3);
    // register_weapon_scalar("henry_m1840", "henry_m1840_upgraded", 3, 3);
    // register_weapon_scalar("bo3_olympia", "bo3_olympia_upgraded", 1, 1);
    set_level_olympia("bo3_olympia", "bo3_olympia_upgraded");
    // register_weapon_scalar("ww2_m712", "ww2_m712_upgraded", 4.06, 4.06);
    // register_weapon_scalar("ww2_m712_mark_lh", undefined, 4.06);
    // register_weapon_scalar("ww2_enfield2", "ww2_enfield2_upgraded", 4.91, 4.91);
    // register_weapon_scalar("ww2_reichsrevolver", "ww2_reichsrevolver_upgraded", 107, 107);
    // register_weapon_scalar("t8_welling_dw", "t8_welling_dw_lh", 4.59, 4.59);
    // register_weapon_scalar("t8_shotgun_blundergat", "t8_shotgun_blundergat_upgraded", 5.85, 5.85);
    register_weapon_scalar("ww2_fliegerfaust", undefined, 10);
    register_weapon_scalar("wes_jag42", undefined, 200);


    level.balance_adjust_easy_scalar = 1.0;
    register_weapon_postcalc("fc4_m1887_long", true);
    register_weapon_postcalc("fc4_m1887_long_upgraded", true);
    register_weapon_postcalc("doc_w1866_upgraded", true);
    register_weapon_postcalc("m1887_upgraded", true);
    register_weapon_postcalc("m1887_lh_upgraded", true);
    register_weapon_postcalc("ww2_fliegerfaust", true);
    register_weapon_postcalc("wes_jag42", true);

    register_weapon_postcalc("frag_ww2_molotov", true);
    register_weapon_calculator("frag_ww2_molotov", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        self thread blast_furnace_player_burn(attacker, level.weaponnone);
        return int(CLAMPED_ROUND_NUMBER * 250);
    });

    register_weapon_postcalc("t8_raygun", true);
    register_weapon_postcalc("t8_raygun_upgraded", true);
    fn_rayguncalc = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        switch(weapon.rootweapon.name)
        {
            case "t8_raygun":
            if(sMeansOfDeath == "MOD_PROJECTILE")
                return int(0.65 * 525 * CLAMPED_ROUND_NUMBER);
            return int(0.65 * 300 * CLAMPED_ROUND_NUMBER);

            case "t8_raygun_upgraded":
            if(sMeansOfDeath == "MOD_PROJECTILE")
                return int(0.65 * 1025 * CLAMPED_ROUND_NUMBER);
            return int(0.65 * 400 * CLAMPED_ROUND_NUMBER);
        }
        return iDamage;
    };
    register_weapon_calculator("t8_raygun", fn_rayguncalc);
    register_weapon_calculator("t8_raygun_upgraded", fn_rayguncalc);

    register_weapon_postcalc("ww2_crossbow", true);
    register_weapon_postcalc("ww2_crossbow_upgraded", true);
    fn_crossbowcalc = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        switch(weapon.rootweapon.name)
        {
            case "ww2_crossbow":
                return 1000 * CLAMPED_ROUND_NUMBER;

            case "ww2_crossbow_upgraded":
            return 2000 * CLAMPED_ROUND_NUMBER;
        }
        return iDamage;
    };
    register_weapon_calculator("ww2_crossbow", fn_crossbowcalc);
    register_weapon_calculator("ww2_crossbow_upgraded", fn_crossbowcalc);

    register_weapon_postcalc("t8_allistair_annihalator_upgraded", true);
    register_weapon_postcalc("t8_allistair_annihalator", true);
    fn_allistair = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        if(CLAMPED_ROUND_NUMBER < 10)
        {
            return 250;
        }
        switch(weapon.name)
        {
            case "t8_allistair_annihalator": // note: this is being tuned by WU for now
                if(sMeansOfDeath == "MOD_PROJECTILE")
                    return 1000 * CLAMPED_ROUND_NUMBER;
                return 3 * 100 * CLAMPED_ROUND_NUMBER;
            break;
            case "t8_allistair_annihalator_upgraded":
                if(sMeansOfDeath == "MOD_PROJECTILE")
                    return 1500 * CLAMPED_ROUND_NUMBER;
                return 3 * 150 * CLAMPED_ROUND_NUMBER;
            break;
        }
        return result;
    };
    register_weapon_calculator("t8_allistair_annihalator_upgraded", fn_allistair);
    register_weapon_calculator("t8_allistair_annihalator", fn_allistair);

    register_weapon_postcalc("hero_fc4primitivebow", true);
    hero_fc4primitivebow = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return 1800 * CLAMPED_ROUND_NUMBER;
    };
    register_weapon_calculator("hero_fc4primitivebow", hero_fc4primitivebow);

    register_weapon_postcalc("t8_shotgun_acidgat_bullet", true);
    t8_shotgun_acidgat_bullet = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        if(sMeansOfDeath == "MOD_IMPACT")
        {
            return (300 / 3) * CLAMPED_ROUND_NUMBER;
        }
        return (700 / 3) * CLAMPED_ROUND_NUMBER;
    };
    register_weapon_calculator("t8_shotgun_acidgat_bullet", t8_shotgun_acidgat_bullet);

    level.var_a4d1a03b = 999;
    level.var_d3bb5bc4 = 999;

    // allistairs
    level.var_761b6645 = 9999; // disable the original objective

    aa = struct::get("aa", "targetname");
	var_4399a779 = getent("wallbuy_aa_close", "targetname");
	var_78a57c4b = getent("wallbuy_aa_open", "targetname");
	var_53cb7af8 = getent("aa_ee", "targetname");
	var_78a57c4b show();
	var_4399a779 delete();
	var_53cb7af8 delete();
    weap = getweapon("t8_allistair_annihalator");
	weapon_model = zm_utility::spawn_buildkit_weapon_model(level.players[0], weap, undefined, aa.origin, (aa.angles[0] * -1, aa.angles[1] + 180, aa.angles[2] * -1));
	trig = spawn("trigger_radius_use", weapon_model.origin, 0, 32, 32);
	trig setcursorhint("HINT_NOICON");
    trig setHintString("");
    trig TriggerIgnoreTeam();
	trig.var_aa8e5bd9 = 1;
	trig.weapon = weap;
	trig.worldgun = weapon_model;
	trig thread [[ function(weapon_model) => 
    {
        level endon("end_game");
        while(CLAMPED_ROUND_NUMBER < 10)
        {
            wait 1;
        }
        self sethintstring(("Hold ^3&&1^7 for ") + makelocalizedstring(self.weapon.displayname));
        for(;;)
        {
            self waittill("trigger", player);
            if(isdefined(player.is_drinking) && player.is_drinking > 0)
            {
                wait(0.1);
                continue;
            }
            if(player getcurrentweapon() == level.weaponnone)
            {
                wait(0.1);
                continue;
            }
            if(player hasweapon(self.weapon))
            {
                continue;
            }
            current_weapon = level.weaponnone;
            if(zm_utility::is_player_valid(player))
            {
                current_weapon = player getcurrentweapon();
            }
            if(zm_utility::is_player_valid(player) && !(player.is_drinking > 0) && !zm_utility::is_placeable_mine(current_weapon) && !zm_equipment::is_equipment(current_weapon) && !player zm_utility::is_player_revive_tool(current_weapon) && !current_weapon.isheroweapon && !current_weapon.isgadget)
            {
                player thread zm_magicbox::treasure_chest_give_weapon(self.weapon);
                wait 1;
            }
        }
    }]](weapon_model);
}

zm_wanted_threaded()
{
    getent("delorean_trig", "targetname").origin = ORIGIN_OOB;
    getent("boss_trig", "targetname").origin = ORIGIN_OOB;
    getent("bgb_bowl", "targetname").origin = ORIGIN_OOB;
    getent("cage_left", "targetname").origin = ORIGIN_OOB;
	getent("cage_right", "targetname").origin = ORIGIN_OOB;
    level clientfield::set("ee_item_1", 1);
	level.var_7e37dd51 = 1;
	level flag::set("key_obtained");
    clips = getentarray("barn_clips", "targetname");
	door1 = getent("barn_door1", "targetname");
	door2 = getent("barn_door2", "targetname");
	var_9ace708d = getent("barn_door_small", "targetname");
	level flag::set("doc_barn_enter");
	foreach(clip in clips)
	{
		clip connectpaths();
		clip delete();
	}
	v_angles = vectornormalize(anglestoforward(door1.angles));
	var_e2ea1b3f = door1.origin + (vectorscale(v_angles, -69));
	door1 moveto(var_e2ea1b3f, 2, 0.5, 0.5);
	playsoundatposition(door1.script_sound, door1.origin);
	var_23b6fbae = vectornormalize(anglestoforward(door2.angles));
	var_6166326f = door2.origin + vectorscale(var_23b6fbae, 69);
	door2 moveto(var_6166326f, 2, 0.5, 0.5);
	playsoundatposition(door2.script_sound, door2.origin);
	var_9ace708d movez(-200, 0.5, 0.5);
	var_9ace708d waittill("movedone");
	var_9ace708d delete();
	level.var_74af2179 = true;
    level.var_4a1fc1df = true;
    level.var_9a0ab035 = true;
    level.var_740835cc = true;
    wait 0.05;
    level.var_ad2dbf53 = 9999;
    getent("prison_trig", "targetname") notify("trigger", level.players[0]);
    getent("power_valve_trig", "targetname") notify("trigger", level.players[0]);
    foreach(ent in getentarray("bgb_machine_use", "targetname"))
    {
        if(isdefined(ent.unitrigger_stub.var_8b8a66cc))
        {
            ent.unitrigger_stub.var_8b8a66cc.origin = ORIGIN_OOB;
        }

        ent hide();        
        for(i = 0; i < (ent GetNumZBarrierPieces()); i++)
        {
            ent hidezbarrierpiece(i);
        }
    }
    level.special_weapon_magicbox_check = function() => { return true; };
    level flag::set("power_on");
    var_79a279c = getent("blacksmith_clip", "targetname");
	var_79a279c delete();
	var_8a8570f = getentarray("blacksmith_door2", "targetname");
	foreach(var_2a30c68c in var_8a8570f)
	{
		var_2a30c68c show();
	}
	var_d0d1db35 = getentarray("blacksmith_door", "targetname");
	foreach(var_6b9550ba in var_d0d1db35)
	{
		var_6b9550ba hide();
	}

    thread clone_perk_machine("specialty_phdflopper", "vending_phdflopper", (-555, 1595, 0.4), (0, 0 + 90, 0)); // spawn
    thread clone_perk_machine("specialty_phdflopper", "vending_phdflopper", (2474, -317, 16), (0, -149 + 90, 0));
    thread clone_perk_machine("specialty_phdflopper", "vending_phdflopper", (67, -1764, 8), (0, 22 + 90, 0));
    thread clone_perk_machine("specialty_phdflopper", "vending_phdflopper", (754, 590, 4), (0, -72 + 90, 0));

    getent("saloon_trig", "targetname").origin = ORIGIN_OOB;
    // getent("saloon_doors", "targetname").origin = ORIGIN_OOB;
    foreach(door in getentarray("saloon_door", "targetname"))
    {
        door movez(-200, 0.5, 0);
        if(isdefined(door.script_firefx))
        {
            playfx(level._effect[door.script_firefx], door.origin);
        }
        if(isdefined(door.script_sound))
        {
            playsoundatposition(door.script_sound, door.origin);
        }
    }
    level thread scene::play("saloon_door_open", "targetname");
    level.var_c26377be = 1;

    cm_bgbm_spawn((-543, 1022, 0), (0, 23, 0));
    
}
#endregion

#region zm_leviathan
autoexec zm_underwater_autoexec()
{
    if(tolower(getdvarstring("mapname")) == "zm_leviathan")
    {
        level.zbr_max_ai_override = 48; // adjusted because of g_spawn issues
        cm_bgbm_blacklist_place((4028, 363, -106));
        setdvar("g_throttleTempEnts", "1");
        system::ignore("zm_time_trial");
        system::ignore("zm_easteregg_keypad");

        compiler::erasefunc("scripts/zm/weapons/zm_alt_weapons.gsc", 0xce121f88, 0xBE02CC45);
        compiler::erasefunc("scripts/zm/zm_excavator.gsc", 0x617a7d88, 0xc1c9acbc); // disable excavators

        callback::on_spawned(function() =>
        {
            self endon("bled_out");
            self endon("disconnect");
            self [[ @namespace_ce121f88<scripts\zm\weapons\zm_alt_weapons.gsc>::function_8509f4d6 ]]();
        });

        callback::on_spawned(function() =>
        {
            self endon("bled_out");
            self endon("disconnect");
            self [[ @namespace_ce121f88<scripts\zm\weapons\zm_alt_weapons.gsc>::function_34a91725 ]]();
        });

        callback::on_spawned(function() =>
        {
            self endon("bled_out");
            self endon("disconnect");
            self endon("disconnect");
            self endon("game_ended");
            self waittill("bled_out");
            self.drownstage = 0;
            self clientfield::set_to_player("drown_stage", 0);
            if(isdefined(self.drown_vision_set) && self.drown_vision_set)
            {
                visionset_mgr::deactivate("overlay", "drown_blur", self);
                self.drown_vision_set = 0;
            }
        });

        callback::on_spawned(function() =>
        {
            self endon("bled_out");
            self endon("disconnect");
            self [[ @drown<scripts\shared\drown.gsc>::watch_game_ended ]]();
        });

        level.do_not_apply_rand_lighting = true;
        getent("ee_cryo_button", "targetname").origin = ORIGIN_OOB;
        getent("scientist_trigger", "targetname").origin = ORIGIN_OOB;
        array::thread_all(getentarray("radio_trigger", "targetname"), sys::delete);
        array::thread_all(getentarray("teddy_trigger", "targetname"), sys::delete);
        array::thread_all(getentarray("diver_scene_trigger", "targetname"), sys::delete);
        compiler::erasefunc("scripts/zm/zm_leviathan_spawning.gsc", 0x13520f1f, 0x670dd7d2); // leaper rounds
        compiler::erasefunc("scripts/zm/zm_leviathan_spawning.gsc", 0x13520f1f, 0x3eef2a7f); // special ai round
        level.is_leviathan_first_spawn_complete = false;
        level.fn_wait_spawned = function() =>
        {
            if(level.is_leviathan_first_spawn_complete)
            {
                return;
            }

            self enableInvulnerability();
            wait 1;

            b_any_touching = true;
            while(b_any_touching && !level.is_leviathan_first_spawn_complete)
            {
                b_any_touching = false;
                self enableInvulnerability();
                foreach(player in getplayers())
                {
                    if(player istouching(getent("submarine_trigger", "targetname")))
                    {
                        b_any_touching = true;
                    }
                }
                wait 1;
            }
            level.is_leviathan_first_spawn_complete = true;
        };

        level.zm_underwater_function_401b78be = @namespace_9d5b5a5a<scripts\zm\zm_underwater.gsc>::function_401b78be;
        compiler::script_detour("scripts/zm/zm_underwater.gsc", 0x9d5b5a5a, 0xec92ed6d, function() =>
        {
            if(isdefined(self.script_noteworthy))
            {
                level endon(self.script_noteworthy + "_unbreached");
                level waittill(self.script_noteworthy + "_zone_breached");
            }
            self.var_a41a6135 = 1;
            while(true)
            {
                self waittill("trigger", entity);
                if(!isdefined(entity.inwater))
                {
                    entity.inwater = 0;
                }
                entity.var_744fd843 = self;
                if(entity.inwater)
                {
                    continue;
                }
                entity [[ level.zm_underwater_function_401b78be ]](1);
            }
        });

        compiler::script_detour("scripts/zm/zm_underwater.gsc", 0x9d5b5a5a, 0xc951516b, function() =>
        {
            // get rid of bubbles
        });

        // mule kick clientfield
        compiler::script_detour("scripts/zm/_zm_perk_additionalprimaryweapon.gsc", 0xC728C6C3, 0x30f4cdf7, function() => 
        {
            self waittill("forever");
        });

        level.function_68483b4f = @namespace_a6513bf4<scripts\zm\zm_leviathan_utility.gsc>::function_68483b4f;
        level.zbr_mine_respawn_wait ??= 3;
        // underwater mines
        compiler::script_detour("scripts/zm/zm_leviathan_events.gsc", 0x66f3819f, 0x412a545c, function() => 
        {
            while(true)
            {
                chains = getentarray(self.target, "targetname");
                self setcandamage(1);
                self show();
                foreach(chain in chains)
                {
                    chain show();
                }

                self.health = 5000;
                health = 500;
                while(health > 0)
                {
                    self waittill("damage", damage, attacker, direction_vec, point, mod);
                    if(damagefeedback::dodamagefeedback(attacker getcurrentweapon(), attacker))
                    {
                        attacker thread damagefeedback::update(mod);
                        attacker playsoundtoplayer("boss_hit_alert", attacker);
                    }
                    health = health - damage;
                }
                [[ level.function_68483b4f ]](level._effect["fx_exp_underwater_lg"], self.origin, 15);
                playsoundatposition("evt_underwater_mine_exp", self.origin);
                level.mine_attacker = attacker;
                self radiusdamage(self.origin, 2500, 150000, 1000, attacker, "MOD_UNKNOWN", getweapon("zombie_knuckle_crack"));
                self radiusdamage(self.origin, 2500, 150000, 1000, undefined, "MOD_UNKNOWN", getweapon("zombie_knuckle_crack"));
                earthquake(0.7, 1, self.origin, 2500);
                wait(0.1);

                self setcandamage(0);
                self hide();
                foreach(chain in chains)
                {
                    chain hide();
                }

                for(i = 0; i < max(1, level.zbr_mine_respawn_wait); i++)
                {
                    level waittill("start_of_round");
                }
                
            }
        });

        level.fn_drown_tracker = @namespace_9d5b5a5a<scripts\zm\zm_underwater.gsc>::function_774654cc;
        compiler::script_detour("scripts/zm/zm_underwater.gsc", 0x9d5b5a5a, 0x7752c5af, function() => 
        {
            self endon(#"hash_133cd406");
            self endon("bled_out");
            self endon("disconnect");
            self endon(#"hash_e5ae6edf");
            if(!isdefined(self.var_310d7881))
            {
                self.var_310d7881 = "";
            }
            if(!isdefined(self.var_78d14d99))
            {
                self.var_78d14d99 = 0;
            }
            self.var_76f0d926 = 0;
            self.var_e415cefe = 0;
            self.drownstage = 0;
            self.var_91b88f7c = 0;
            self.var_69943a38 = 0;
            self clientfield::set_to_player("drown_stage", 0);
            if(!isdefined(self.drown_damage_after_time))
            {
                self.drown_damage_after_time = level.drown_damage_after_time;
            }
            for(;;)
            {
                if(isdefined(self.var_78d14d99) && self.var_78d14d99 || (isdefined(self.var_cef30dbd) && self.var_cef30dbd) || isdefined(self.var_634bdbc8) || (isdefined(level.var_baefdbc5) && level.var_baefdbc5))
                {
                    if(self.var_310d7881 != "zm_underwater" && (isdefined(self.var_ec453214) && self.var_ec453214))
                    {
                        if(self.var_310d7881 == "zm_drown")
                        {
                            visionset_mgr::deactivate("visionset", "zm_drown", self);
                        }
                        wait(0.05);
                        if(!self.var_af07ffb0)
                        {
                            visionset_mgr::activate("visionset", "zm_underwater", self);
                        }
                        self.var_310d7881 = "zm_underwater";
                    }
                    if(isdefined(self.var_634bdbc8) && self.var_634bdbc8.name == "shark_mask" || (isdefined(self.var_cef30dbd) && self.var_cef30dbd))
                    {
                        self setmovespeedscale(1.1);
                    }
                    else
                    {
                        self setmovespeedscale(1);
                    }
                    if(self.var_e415cefe > 0)
                    {
                        self.var_e415cefe = 0;
                    }
                    if(self.var_76f0d926 > 0)
                    {
                        self setnormalhealth(self.health + self.var_76f0d926);
                        self.var_76f0d926 = 0;
                    }
                }
                else
                {
                    if(self.var_310d7881 != "zm_drown")
                    {
                        if(self.var_310d7881 == "zm_underwater")
                        {
                            visionset_mgr::deactivate("visionset", "zm_underwater", self);
                        }
                        wait(0.05);
                        if(!self.var_af07ffb0)
                        {
                            visionset_mgr::activate("visionset", "zm_drown", self);
                        }
                        self.var_310d7881 = "zm_drown";
                    }
                    if(isdefined(self.var_634bdbc8) && self.var_634bdbc8.name == "shark_mask" || (isdefined(self.var_cef30dbd) && self.var_cef30dbd))
                    {
                        self setmovespeedscale(1.1);
                    }
                    else
                    {
                        self setmovespeedscale(1);
                    }
                    self.var_c0d4dadb = 1;
                    self.var_e415cefe = self.var_e415cefe + 0.05;
                    self.hurtagain = self.var_e415cefe > 3;
                    if(!self.var_69943a38)
                    {
                        self thread [[ function() => 
                        {
                            self endon("disconnect");
                            self endon("bled_out");
                            self.var_69943a38 = 1;
                            if(!isdefined(self.drownstage))
                            {
                                self.drownstage = 0;
                            }
                            if(self.drownstage < 4)
                            {
                                self.drownstage++;
                                self clientfield::set_to_player("drown_stage", self.drownstage);
                            }
                            wait(3);
                            self.var_69943a38 = 0;
                        }]]();
                    }
                    if(self.var_e415cefe > 3 && !self.var_91b88f7c)
                    {
                        self thread [[ level.fn_drown_tracker ]]();
                    }
                }
                wait(0.05);
            }
        });

        compiler::erasefunc("scripts/zm/equipment/zm_equipment_hacker.gsc", 0x62c419ac, 0x3075e5bd); // hacker triggers (causing g_spawn)
        compiler::erasefunc("scripts/zm/equipment/zm_equipment_hacker.gsc", 0x62c419ac, 0x32856fc8); // destroy hacker spawns
        compiler::erasefunc("scripts/zm/zm_leviathan.gsc", 0xc1af9c11, 0x3e648c58);

        callback::on_spawned(function() => 
        {
            self clientfield::set_player_uimodel("ImpailedVisibility", 0);
            var_68b7252 = getarraykeys(level.var_7d09fe28);
            playerfields = getarraykeys(self.var_7d09fe28);
            foreach(field in var_68b7252)
            {
                self clientfield::set_player_uimodel(field, level.var_7d09fe28[field]);
            }
            foreach(field in playerfields)
            {
                self clientfield::set_player_uimodel(field, self.var_7d09fe28[field]);
            }
        });

        zm_underwater_clean();

        callback::on_spawned(function() =>
        {
            self endon("disconnect");
            self endon("bled_out");
            self endon("spawned_player");
            self waittill("zbr_spawned");
            self.var_ec453214 = 1;
            self.var_3a1dbca2 = 0;
			self.drownstage = 0;
			self clientfield::set_to_player("drown_stage", self.drownstage);
			self setcharacterbodytype((zm_utility::get_player_index(self) * 2) + 1, 0);
			self setcharacterbodystyle(0);
			self setcharacterhelmetstyle(0);
			level clientfield::set(("player" + self.entity_num) + "wearableItem", 1);
			self clientfield::set_player_uimodel("UnderwaterMaskVisibility", 1);
			self clientfield::set_to_player("WearingPes", 1);
        });

        // pantheon skipping
        fn_pantheon_quest_step_complete = function() =>
        {
            wait 0.05;
            level notify("quest_pantheon_step_complete");
        };
        
        compiler::script_detour("scripts/zm/easteregg/zm_easteregg_pantheon.gsc", 0x78dc7048, 0x63e4bda9, fn_pantheon_quest_step_complete);
        compiler::script_detour("scripts/zm/easteregg/zm_easteregg_pantheon.gsc", 0x78dc7048, 0x875ad440, fn_pantheon_quest_step_complete);
        compiler::script_detour("scripts/zm/easteregg/zm_easteregg_pantheon.gsc", 0x78dc7048, 0xe971b9c3, function() => 
        {
            wait 0.05;
            var_ee095d11 = struct::get("pantheon_skull_struct", "targetname");
            skull = spawn("script_model", (0, 0, 0));
            skull playsound("pantheon_skull_place");
            skull setmodel("tag_origin");
            skull.var_aee79b17 = spawn("script_model", skull.origin);
            skull.var_aee79b17 setmodel("p7_skulls_bones_head_01");
            skull.var_aee79b17 enablelinkto();
            skull.var_aee79b17 linkto(skull);
            skull moveto(var_ee095d11.origin, 0.5, 0.2, 0.2);
            skull rotateto(var_ee095d11.angles, 0.5, 0.2, 0.2);
            level.var_f2a5ebb = skull;
            level notify("quest_pantheon_step_complete");
        });
        compiler::script_detour("scripts/zm/easteregg/zm_easteregg_pantheon.gsc", 0x78dc7048, 0xbfa79e5e, fn_pantheon_quest_step_complete);
        compiler::script_detour("scripts/zm/easteregg/zm_easteregg_pantheon.gsc", 0x78dc7048, 0x68772d, fn_pantheon_quest_step_complete);
        compiler::script_detour("scripts/zm/easteregg/zm_easteregg_pantheon.gsc", 0x78dc7048, 0x910d5612, function() => 
        {
            wait 0.05;
            triggers = getentarray("elysium_damage_trigger", "targetname");
	        array::thread_all(triggers, function(count) => 
            {
                playsoundatposition("ee_statue_exploded", self.origin);
                var_db155bca = struct::get("elysium_podium_struct", "targetname");
                fx = spawn("script_model", self.origin);
                fx setmodel("tag_origin");
                playfxontag(level._effect["fx_pantheon_soul"], fx, "tag_origin");
                fx playloopsound("pantheon_soul_loop");
                fx moveto(var_db155bca.origin, 1);
                wait(1);
                playsoundatposition("pantheon_soul_release", var_db155bca.origin);
                fx delete();
                if(!isdefined(level.var_d8af85c2))
                {
                    level.var_d8af85c2 = 0;
                }
                level.var_d8af85c2++;
                if(level.var_d8af85c2 >= count)
                {
                    level notify("quest_pantheon_step_complete");
                }
            }, triggers.size);
        });
        compiler::script_detour("scripts/zm/easteregg/zm_easteregg_pantheon.gsc", 0x78dc7048, 0x7154ded4, function() => 
        {
            fxstruct = struct::get("collapse_fx_struct", "targetname");
            var_40a2828b = spawn("script_model", fxstruct.origin);
            var_40a2828b setmodel("tag_origin");
            var_40a2828b playloopsound("one_inch_punch_loop");
            circle = getent("elysium_podium_circle", "targetname");
            circle setmodel("p7_zm_zod_magic_circle_ritual_192_emissive_lev");
            var_6d2fd5fb = struct::get("elysium_ground_struct", "targetname");
            trigger = getent("elysium_fall_trigger", "targetname");
            podium = getentarray("elysium_podium", "targetname");
            floor = getent("elysium_floor", "targetname");
            var_3be6886 = getentarray("elysium_floor_damaged", "targetname");
            debris = getentarray("elysium_debris", "targetname");
            level.var_2cd4262f = true;
            playsoundatposition("evt_collapse_rumble", floor.origin);
            earthquake(0.5, 3, trigger.origin, 1000);
            wait(2);
            floor disconnectpaths();
            floor delete();
            wait(0.05);
            foreach(chunk in var_3be6886)
            {
                chunk show();
                if(isdefined(chunk.script_string) && chunk.script_string == "connect")
                {
                    chunk connectpaths();
                }
            }
            wait(8);
            foreach(chunk in podium)
            {
                chunk delete();
            }
            circle delete();
            var_40a2828b delete();
            foreach(chunk in debris)
            {
                chunk show();
            }
            level notify(#"hash_276f4a51");
            thread [[ @namespace_78dc7048<scripts\zm\easteregg\zm_easteregg_pantheon.gsc>::function_9c050a47 ]]();
            level notify("quest_pantheon_step_complete");
        });

        level thread [[ function() => 
        {
            self waittill(#"hash_26f8cebf");
            wait 0.05;
            self notify(#"hash_451e94b0");
        }]]();
            
        level.old_sub_shield_damage = @namespace_acf6e70b<scripts\zm\equipment\zm_equipment_sub_shield.gsc>::function_742b03a;
        compiler::script_detour("scripts/zm/equipment/zm_equipment_sub_shield.gsc", #namespace_acf6e70b, #function_742b03a, function() => 
        {
            self [[ level.old_sub_shield_damage ]]();
            var_f7fd0abf = self getweaponmuzzlepoint();
            var_6979e7c3 = self getweaponforwarddir();
            zombies = array::get_all_closest(var_f7fd0abf, getplayers(), undefined, undefined, 1250);
            foreach(zombie in zombies)
            {
                if(!isdefined(zombie) || !isalive(zombie))
                {
                    continue;
                }
                if(zombie.sessionstate != "playing" || zombie.team == self.team)
                {
                    continue;
                }
                if(!bulletTracePassed(zombie geteye(), self geteye(), false, self))
                {
                    continue;
                }
                zombie dodamage(int(CLAMPED_ROUND_NUMBER * 300), zombie.origin, self, undefined, "none", "MOD_EXPLOSIVE", 0, level.weaponnone);
            }
        });
    }
}

zm_underwater_spawned()
{
    if(isdefined(self.drown_vision_set) && self.drown_vision_set)
    {
        visionset_mgr::deactivate("overlay", "drown_blur", self);
    }
    self.drown_vision_set = 0;
    self.var_ff2ebfda = 0;
    self.var_9e3f5b13 = 0;
    self.lastwaterdamagetime = self getlastoutwatertime();
    self.drownstage = 0;
    if(!isdefined(self.drown_damage_after_time))
    {
        self.drown_damage_after_time = level.drown_damage_after_time;
    }

    self.var_78d14d99 = 1; // wearing PES
    self.var_ec453214 = 1;
    self.drownstage = 0;
    self clientfield::set_to_player("drown_stage", self.drownstage);
    self setcharacterbodytype((zm_utility::get_player_index(self) * 2) + 1, 0);
    self setcharacterbodystyle(0);
    self setcharacterhelmetstyle(0);
    level clientfield::set(("player" + self.entity_num) + "wearableItem", 1);
    self clientfield::set_player_uimodel("UnderwaterMaskVisibility", 1);
	self clientfield::set_to_player("WearingPes", 1);

    if(!isdefined(level.leviathan_set_water_state))
    {
        level.leviathan_set_water_state = @namespace_9d5b5a5a<scripts\zm\zm_underwater.gsc>::function_401b78be;
    }
    self [[ level.leviathan_set_water_state ]](0);

    self thread [[ function() => 
    {
        self endon("bled_out");
        self endon("disconnect");
        self endon("spawned_player");
        pos = self getorigin();
        max = 600 * 600;
        for(;;)
        {
            if(distancesquared(pos, self getorigin()) > max)
            {
                self [[ level.leviathan_set_water_state ]](0);
            }
            pos = self getorigin();
            wait 0.1;
        }
    }]]();
}

zm_underwater_clean()
{
    // gotta clean up some ents because leviathan is way too packed
    getent("escape_trigger", "targetname").origin = ORIGIN_OOB;

    foreach(door in getentarray("zombie_door", "targetname"))
    {
        ent_targets = getentarray(door.target, "targetname");
        foreach(target in ent_targets)
        {
            if(target.script_noteworthy ?& target.script_noteworthy == "clip")
            {
                target delete();
                continue;
            }
            if(target.classname ?& target.classname == "script_brushmodel")
            {
                target ConnectPaths();
                target delete();
                continue;
            }
            target delete();
        }
        door delete();
    }

    fn_kill_airlock = function() =>
    {
        doors = getentarray(self.target, "targetname");
        doors[doors.size] = self;
        array::run_all(doors, serious::connect_and_delete);
    };

    array::run_all(getentarray("dynamic_door_trigger", "targetname"), fn_kill_airlock);
    array::run_all(getentarray("airlock_door_trigger", "targetname"), fn_kill_airlock);
    array::run_all(getentarray("broken_airlock_door", "targetname"), serious::connect_and_delete);
    array::run_all(getentarray("airlock_pes_trigger", "targetname"), sys::delete);
    array::run_all(getentarray("sub_locker_trigger", "targetname"), sys::delete);

    getent("keypad_trigger", "targetname") delete();
    array::run_all(getentarray("keypad_digits", "targetname"), sys::delete);
    getent("keypad_model", "targetname") delete();
    getent("dr_wells_test_tube", "targetname") delete();
    triggers = getentarray("hack_console_trigger", "targetname");
	buttons = getentarray("hack_button_trigger", "targetname");
    index = 0;
    foreach(trigger in triggers)
    {
        getent(trigger.target, "targetname") delete();
        getent(buttons[index].target, "targetname") delete();
        index++;
    }
    array::run_all(triggers, sys::delete);
    array::run_all(buttons, sys::delete);
    array::run_all(getentarray("soul_generator_clip", "targetname"), sys::delete);
	getent("soul_generator_trigger", "targetname") delete();
    array::run_all(getentarray("soul_fluid", "targetname"), sys::delete);

    getent("harpoon_station_trigger", "targetname").origin = ORIGIN_OOB;
}

zm_underwater_init()
{
 
    level.gm_blacklisted[level.gm_blacklisted.size] = "sub_zone";
    unlock_all_debris();
    fix_vigor_rush();

    level.has_vigor_rush_override = function() => 
    {
        return self.var_3a1dbca2 === 1;
    };

    // pantheon
    level.var_b8c9bc05 = true;
    trigger = getent("one_inch_punch_trigger", "targetname");
    foreach(player in level.players)
    {
		trigger setvisibletoplayer(player);
    }

    level.fn_pause_zbr_objective = function() =>
    {
        str_zone = self.zone_name ?? "";
        switch(str_zone)
        {
            case "sub_zone":
                    self.gm_objective_timesurvived = int(max(0, self.gm_objective_timesurvived - 10));
                    wait 5;
                return true;
            case "elysium_arena_zone":
                return true;
            default:
                return false;
        }

        if((isdefined(self.var_9e3f5b13) && self.var_9e3f5b13) || (isdefined(self.var_ff2ebfda) && self.var_ff2ebfda)) // jump pad takes time
        {
            self.gm_objective_timesurvived = int(max(0, self.gm_objective_timesurvived - 10));
            wait 5;
            return true;
        }
        return false;
    };

    compiler::script_detour("scripts/zm/_zm_weapons.gsc", 0x33D4B538, 0x81635A67, function(weapon) => 
    {
        if(weapon == level.weaponnone || weapon == level.weaponzmfists || weapon == getweapon("microwavegun_upgraded") || getweapon("microwavegun") == weapon)
        {
            return false;
        }
        weapontopack = zm_weapons::get_nonalternate_weapon(weapon);
        rootweapon = weapontopack.rootweapon;
        if(!zm_weapons::is_weapon_upgraded(rootweapon))
        {
            return false;
        }
        return true;
    });

    // trap damage
    level.function_e5593950 = @namespace_a8930e6a<scripts\zm\zm_trap_fan.gsc>::function_e5593950;
    compiler::script_detour("scripts/zm/zm_trap_fan.gsc", 0xa8930e6a, 0x2a3bf276, function(var_ca565da1, attacker) => 
    {
        level endon(var_ca565da1 + "_fan_trap_end");
        for(;;)
        {
            wait(0.1);

            foreach(player in getplayers())
            {
                if(player.sessionstate != "playing")
                {
                    continue;
                }
                if(!(player istouching(self)))
                {
                    continue;
                }
                if(player hasPerk("specialty_armorvest"))
                {
                    player dodamage(int(CLAMPED_ROUND_NUMBER * 1000 * 0.1), player.origin, (player == attacker) ? undefined : attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                }
                else
                {
                    player dodamage(int(CLAMPED_ROUND_NUMBER * 3000 * 0.1), player.origin, (player == attacker) ? undefined : attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                }
            }

            foreach(zombie in GetAITeamArray(level.zombie_team))
            {
                if(!isalive(zombie))
                {
                    continue;
                }
                if(!(zombie istouching(self)))
                {
                    continue;
                }
                zombie thread [[ level.function_e5593950 ]](player);
            }
        }
    });

    pap_spot = (385, -4164, -17 + 5);
    pap_angles = (0, 90, 0);
    foreach(pap in GetEntArray("pack_a_punch", "script_noteworthy"))
    {
        if(!isdefined(pap.target))
            continue;
        
        ent = GetEnt(pap.target, "targetname");

        if(!isdefined(ent))
            continue;

        ent.origin = pap_spot;
        ent.angles = pap_angles;
        pap.origin = pap_spot;
        pap.angles = pap_angles;
    }
    
    foreach(pap in GetEntArray("specialty_weapupgrade", "script_noteworthy"))
    {
        if(!isdefined(pap.target))
            continue;
        
        ent = GetEnt(pap.target, "targetname");

        if(!isdefined(ent))
            continue;

        ent.origin = pap_spot;
        ent.angles = pap_angles;
        pap.origin = pap_spot;
        pap.angles = pap_angles;
    }
}

#define ZM_UNDERWATER_CLAYMORE_DMG_PER_ROUND = 3500;
#define ZM_UNDERWATER_IMPACT_CROSSBOW_DMG = 5000;
#define ZM_UNDERWATER_RADIUS_CROSSBOW_DMG = 5000;
zm_underwater_weapons()
{
    // remove_box_weapon("ray_gun");
    // remove_box_weapon("raygun_mark2");
    register_box_weapon("black_hole_bomb", undefined);
    register_box_weapon("hero_trident", undefined);
    register_box_weapon("special_harpoon", "special_harpoon_upgraded");
    register_box_weapon("special_harpoon_crystal", "special_harpoon_crystal_upgraded");

    foreach(weapon in array("special_harpoon", "special_harpoon_crystal", "special_harpoon_upgraded", "special_harpoon_crystal_upgraded"))
    {
        register_weapon_postcalc(weapon, true);
        register_weapon_calculator(weapon, function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) => 
        {
            if(weapon.name == "special_harpoon" || weapon.name == "special_harpoon_crystal")
            {
                return int(CLAMPED_ROUND_NUMBER * 750);
            }
            return int(CLAMPED_ROUND_NUMBER * 1500);
        });
    }

    level.zbr_damage_callbacks[level.zbr_damage_callbacks.size] = function(eInflictor, attacker, result, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime) =>
    {
        if(isdefined(weapon))
        {
            if(weapon.name == "special_harpoon" || weapon.name == "special_harpoon_crystal" || weapon.name == "special_harpoon_upgraded" || weapon.name == "special_harpoon_crystal_upgraded")
            {
                self dodamage(1000, self.origin, attacker, undefined, "none", "MOD_EXPLOSIVE", 0, level.weaponnone);
                return result;
            }

            // this is a mine
            if(weapon == getweapon("zombie_knuckle_crack"))
            {
                if(!isdefined(attacker) && isdefined(level.mine_attacker) && level.mine_attacker != self)
                {
                    return 0;
                }
                if((!level.super_explosives && (self bgb::is_enabled("zm_bgb_danger_closest"))))
                {
                    return 0;
                }
                if(self hasperk("specialty_phdflopper"))
                {
                    return 0;
                }
                return result;
            }
        }

        if(result == 50 || result == 49)
        {
            if(self.electrocuting === true)
            {
                return int(250 * CLAMPED_ROUND_NUMBER);
            }
        }
        return result;
    };

    fn_oip = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        self thread one_inch_punch_dmg(attacker, false);
        return int(result * 0.75);
    };
    register_weapon_calculator("one_inch_punch", fn_oip);
    register_weapon_calculator("one_inch_punch_upgraded", fn_oip);

    claymore_override(true);

    register_weapon_postcalc("launcher_crossbow", true);
    register_weapon_postcalc("launcher_crossbow_upgraded", true);
    fn_launcher_crossbow = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        switch(weapon.rootweapon.name)
        {
            case "launcher_crossbow":
            if(sMeansOfDeath == "MOD_IMPACT")
                return ZM_UNDERWATER_IMPACT_CROSSBOW_DMG;
            return ZM_UNDERWATER_RADIUS_CROSSBOW_DMG;

            case "launcher_crossbow_upgraded":
            if(sMeansOfDeath == "MOD_IMPACT")
                return ZM_UNDERWATER_IMPACT_CROSSBOW_DMG * 2;
            return ZM_UNDERWATER_RADIUS_CROSSBOW_DMG * 2;
        }
        return iDamage;
    };
    register_weapon_calculator("launcher_crossbow", fn_launcher_crossbow);
    register_weapon_calculator("launcher_crossbow_upgraded", fn_launcher_crossbow);

    level.balance_adjust_easy_scalar = 0.3;

    // register_weapon_scalar("ar_m16", "ar_m16_upgraded", 12 * 2);
    // register_weapon_scalar("lmg_hk21", "lmg_hk21_upgraded", 12);
    // register_weapon_scalar("lmg_rpk", "lmg_rpk_upgraded", 8 * 2);
    // register_weapon_scalar("sniper_l96a1", "sniper_l96a1_upgraded", 8 * 1.5);
    // register_weapon_scalar("sniper_dragunov", "sniper_dragunov_upgraded", 2 * 2);
    // register_weapon_scalar("ar_commando", "ar_commando_upgraded", 9);
    // register_weapon_scalar("ar_g11", "ar_g11_upgraded", 6);
    // register_weapon_scalar("ar_fal", "ar_fal_upgraded", 6 * 1.25);
    // register_weapon_scalar("ar_aug", "ar_aug_upgraded", 6 * 2);
    // register_weapon_scalar("ar_galil", "ar_galil_upgraded", 6);
    // register_weapon_scalar("ar_famasa", "ar_famasa_upgraded", 4 * 2);
    // register_weapon_scalar("smg_spectre", "smg_spectre_upgraded", 9 / 2 * 5);
    // register_weapon_scalar("smg_mpl", "smg_mpl_upgraded", 9.2 / 2 * 2);
    // register_weapon_scalar("smg_mp40_1940", "smg_mp40_1940_upgraded", 9 / 2);
    // register_weapon_scalar("smg_ak74u", "smg_ak74u_upgraded", 10 / 2 * 4);
    // register_weapon_scalar("smg_pm63", "smg_pm63_upgraded", 3 * 4);
    // register_weapon_scalar("ar_m14", "ar_m14_upgraded", 30 / 2);
    // register_weapon_scalar("smg_mp5k", "smg_mp5k_upgraded", 10 / 2 * 2);
    // register_weapon_scalar("shotgun_spas12", "shotgun_spas12_upgraded", 4 * 1.5);
    // register_weapon_scalar("shotgun_stakeout", "shotgun_stakeout_upgraded", 9);
    // register_weapon_scalar("shotgun_olympia", "shotgun_olympia_upgraded", 8.6 * 0.65);
    set_level_olympia("shotgun_olympia", "shotgun_olympia_upgraded");
    // register_weapon_scalar("pistol_cz75_dw", "pistol_cz75_dw_upgraded", 2);
    // register_weapon_scalar("pistol_cz75_lh", "pistol_cz75_lh_upgraded", 2);
    // register_weapon_scalar("pistol_cz75", "pistol_cz75_upgraded", 2 * 4);
    // register_weapon_scalar("pistol_python", "pistol_python_upgraded", 3.8);
    // register_weapon_scalar("pistol_c96", "pistol_c96_upgraded", 2);
    // register_weapon_scalar("m203", undefined, 40);
    // register_weapon_postcalc("m203", true);
    // register_weapon_scalar("shotgun_masterkey", undefined, 5);
    // register_weapon_scalar("shotgun_stakeout", "shotgun_stakeout_upgraded", 6);
    level.balance_adjust_easy_scalar = 1;

    // register_weapon_scalar("knife_ballistic_bowie", "knife_ballistic_bowie_upgraded", 10);
    // register_weapon_scalar("knife_ballistic", "knife_ballistic_upgraded", 10);
    // register_weapon_scalar("launcher_china_lake", "launcher_china_lake_upgraded", 17);
    register_weapon_postcalc("launcher_china_lake", true);
    register_weapon_postcalc("launcher_china_lake_upgraded", true);

    register_weapon_postcalc("launcher_law", true);
    register_weapon_postcalc("launcher_law_upgraded", true);
    fn_launcher_law_upgraded = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        if("launcher_law" == weapon.name)
        {
            return int(CLAMPED_ROUND_NUMBER * 300);
        }

        if(!isdefined(attacker) || !isplayer(attacker) || (!isplayer(attacker) && isdefined(inflictor) && !isplayer(inflictor)))
        {
            return int(CLAMPED_ROUND_NUMBER * 1750);
        }

        return int(CLAMPED_ROUND_NUMBER * 750);
    };
    register_weapon_calculator("launcher_law", fn_launcher_law_upgraded);
    register_weapon_calculator("launcher_law_upgraded", fn_launcher_law_upgraded);

    level.function_5032211e = @namespace_1251f287<scripts\zm\weapons\zm_trident.gsc>::function_5032211e;
    level.function_8f3f41da = @namespace_1251f287<scripts\zm\weapons\zm_trident.gsc>::function_8f3f41da;
    level.function_b82995cf = @namespace_1251f287<scripts\zm\weapons\zm_trident.gsc>::function_b82995cf;
    level.function_bdbda7e5 = @namespace_1251f287<scripts\zm\weapons\zm_trident.gsc>::function_bdbda7e5;
    level.function_e60e60c0 = @namespace_1251f287<scripts\zm\weapons\zm_trident.gsc>::function_e60e60c0;
    level.function_ce727ee4 = @namespace_1251f287<scripts\zm\weapons\zm_trident.gsc>::function_ce727ee4;

    compiler::script_detour("scripts/zm/weapons/zm_trident.gsc", 0x1251f287, 0x5175c74, function(origin) => 
    {
        vortex = spawn("script_model", origin);
        vortex.owner = self;
        vortex.angles = self.angles;
        vortex setmodel("tag_origin");
        vortex playsound("evt_trident_vortex_start");
        vortex playloopsound("evt_trident_vortex_loop");
        playfxontag(level._effect["fx_trident_vortex"], vortex, "tag_origin");
        radiusdamage(vortex.origin + vectorscale((0, 0, 1), 24), 150, int(500 * CLAMPED_ROUND_NUMBER), int(500 * CLAMPED_ROUND_NUMBER - 1), self, "MOD_EXPLOSIVE", level.weaponnone);

        lifetime = 10 + (randomfloatrange(-1, 1));
        self thread [[ level.function_5032211e ]](vortex);
        self thread vortex_suck_players(vortex, lifetime, 50);
        vortex endon(#"hash_dbe98664");
        while(lifetime > 0)
        {
            origin = vortex [[ level.function_8f3f41da ]](origin);
            vortex moveto(origin, 0.095);
            earthquake(0.2, 0.1, vortex.origin, 180);
            vortex [[ level.function_b82995cf ]]();
            vortex [[ level.function_bdbda7e5 ]]();
            wait(0.1);
            lifetime = lifetime - 0.1;
        }
        radiusdamage(vortex.origin + vectorscale((0, 0, 1), 24), 150, int(500 * CLAMPED_ROUND_NUMBER), int(500 * CLAMPED_ROUND_NUMBER - 1), self, "MOD_EXPLOSIVE", level.weaponnone);
        vortex thread [[ level.function_e60e60c0 ]]();
    });

    level.old_bhb_pull = @namespace_80fc7efe<scripts\zm\equipment\zm_equipment_gersch.gsc>::function_192038e9;
    compiler::script_detour("scripts/zm/equipment/zm_equipment_gersch.gsc", 0x80fc7efe, 0x192038e9, function(s_bhb) => 
    {
        self thread [[ level.old_bhb_pull ]](s_bhb);
        s_bhb.playerowner thread start_timed_pvp_vortex(s_bhb.model.origin, 2056, 8, undefined, undefined, s_bhb.playerowner, level.var_2f4f03ab, 0, undefined, 0, 0, 0);
    });

    compiler::script_detour("scripts/zm/weapons/zm_trident.gsc", 0x1251f287, 0x1226f8f5, function(weapon) => 
    {
        foreach(zombie in self [[ level.function_ce727ee4 ]]())
        {
            if(isdefined(zombie.archetype) && zombie.archetype == "warlord")
            {
                zombie dodamage(300, zombie.origin, self, self, "none", "MOD_MELEE");
                continue;
            }
            zombie dodamage(zombie.health, zombie.origin, self, self, "none", "MOD_MELEE");
        }
        
        eye = self geteye();
        v_wep_fwd = self getweaponforwarddir();
        endposition = eye + vectorscale(v_wep_fwd, 90);
        foreach(player in getplayers())
        {
            if(player.team == self.team)
            {
                continue;
            }
            if(player.sessionstate != "playing")
            {
                continue;
            }
            if(distancesquared(player.origin, self.origin) > 32400)
            {
                continue;
            }
            centroid = player.origin + (0, 0, 50);
            dist_eye_centroid = distancesquared(eye, centroid);
            if(dist_eye_centroid > 8100)
            {
                continue;
            }
            normal = vectornormalize(centroid - eye);
            dot = vectordot(v_wep_fwd, normal);
            if(0 > dot)
            {
                continue;
            }
            nearest_point = pointonsegmentnearesttopoint(eye, endposition, centroid);
            if(distancesquared(centroid, nearest_point) > 129600)
            {
                continue;
            }
            if(player damageconetrace(eye, self) == 0)
            {
                continue;
            }
            
            player dodamage(500, eye, self, undefined, "none", "MOD_MELEE", 0, level.weaponnone);
            wait 0.05;
            player dodamage(75, eye, self, undefined, "none", "MOD_EXPLOSIVE", 0, level.weaponnone);
        }
    });

    level.function_f08f7183 = @namespace_17f6d38e<scripts\zm\weapons\zm_harpoon.gsc>::function_f08f7183;
    level.function_ce309329 = @namespace_17f6d38e<scripts\zm\weapons\zm_harpoon.gsc>::function_ce309329;
    level.function_d7722329 = @namespace_17f6d38e<scripts\zm\weapons\zm_harpoon.gsc>::function_d7722329;
    level.function_bb6bcc54 = @namespace_17f6d38e<scripts\zm\weapons\zm_harpoon.gsc>::function_bb6bcc54;

    compiler::script_detour("scripts/zm/weapons/zm_harpoon.gsc", 0x17f6d38e, 0x7e3622ec, function(harpoon_one, harpoon_two, isupgraded) => 
    {
        harpoon_one endon(#"hash_853964da");
        harpoon_one endon("death");
        harpoon_two endon(#"hash_853964da");
        harpoon_two endon("death");
        if(isdefined(self.var_6c8f28f2))
        {
            harpoon_one notify(#"hash_473e8ac9");
            harpoon_two notify(#"hash_473e8ac9");
            self.var_6c8f28f2 notify(#"hash_473e8ac9");
        }
        var_ec2b0d4a = (harpoon_one.origin[0] + harpoon_two.origin[0]) / 2;
        var_122d87b3 = (harpoon_one.origin[1] + harpoon_two.origin[1]) / 2;
        minz = min(harpoon_one.origin[2], harpoon_two.origin[2]) - 20;
        midpoint = (var_ec2b0d4a, var_122d87b3, minz);
        height = (abs(harpoon_one.origin[2] - harpoon_two.origin[2])) + 40;
        radius = distance2d(harpoon_one.origin, harpoon_two.origin) / 2;
        self.var_6c8f28f2 = spawn("trigger_radius", midpoint, get_flags_trigger_zbr(), radius, height);
        self.var_6c8f28f2 endon(#"hash_473e8ac9");
        self.var_6c8f28f2 thread [[ level.function_f08f7183 ]](harpoon_one, harpoon_two, self);
        self.var_6c8f28f2.harpoon_one = harpoon_one;
        self.var_6c8f28f2.harpoon_two = harpoon_two;
        playfxontag(level._effect["fx_harpoon_trap_post_spark_loop"], harpoon_one, "j_rope");
        playfxontag(level._effect["fx_harpoon_trap_post_spark_loop"], harpoon_two, "j_rope");
        harpoon_one playloopsound("wpn_harpoon_trap_electric_loop");
        harpoon_two playloopsound("wpn_harpoon_trap_electric_loop");
        harpoon_one thread [[ level.function_ce309329 ]](self.var_6c8f28f2, harpoon_two, self);
        harpoon_two thread [[ level.function_ce309329 ]](self.var_6c8f28f2, harpoon_one, self);
        kills = 0;
        while(isdefined(self.var_6c8f28f2))
        {
            foreach(player in getplayers())
            {
                if(player.sessionstate != "playing")
                {
                    continue;
                }

                if(isdefined(player.electrocuting) && player.electrocuting)
                {
                    continue;
                }

                if(!(player isTouching(self.var_6c8f28f2)))
                {
                    continue;
                }

                if(!(player [[ level.function_d7722329 ]](harpoon_one, harpoon_two)))
                {
                    continue;
                }
                
                player thread [[ function(attacker) => 
                {
                    self endon("disconnect");
                    if(!(isdefined(self.electrocuting) && self.electrocuting) && zm_utility::is_player_valid(self))
                    {
                        self.electrocuting = 1;
                        self setelectrified(1.25);
                        self shellshock("electrocution", 2.5);
                        self playrumbleonentity("damage_heavy");
                        self playsound("wpn_zmb_electrap_zap");
                        self dodamage(int(CLAMPED_ROUND_NUMBER * 500), self.origin, (attacker == self) ? undefined : attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                        wait(0.2);
                        self.electrocuting = 0;
                    }
                }]](self);
            }

            foreach(zombie in GetAITeamArray(level.zombie_team))
            {
                if(!isalive(zombie))
                {
                    continue;
                }
                if(isdefined(zombie.marked_for_death) && zombie.marked_for_death)
                {
                    continue;
                }
                if(!(zombie isTouching(self.var_6c8f28f2)))
                {
                    continue;
                }
                if(!(zombie [[ level.function_d7722329 ]](harpoon_one, harpoon_two)))
                {
                    continue;
                }
                zombie thread [[ level.function_bb6bcc54 ]](self, self.var_6c8f28f2);
            }
            wait 0.1;
        }
    });
}

zm_underwater_threaded()
{
    level notify("pack_a_punch_on");
    level.var_3f37f522 = 999; // address shark crash
    wait 15;
    culled = 0;
    targetname_cull_ents = 
    [
        "pf1_auto1", // p7_zm_moo_console_monitor_trials_off
        "pf2_auto1", // p7_zm_moo_console_monitor_trials_off
        "pf3_auto1", // p7_zm_moo_console_monitor_trials_on
        "pf4_auto1", // 
        "gate_zone_clip",
        "cafeteria_diver_clip",
        "cafeteria_diver_door",
        "catwalk_fan_trap_handle",
        "catwalk_fan_trap_fanModel",
        "pneumatic_canister_2",
        "pneumatic_canister_4",
        "pneumatic_canister_5",
        "pneumatic_canister_1",
        "pneumatic_canister_3",
        "artifact_vril",
        "artifact_machine_parts",
        "artifact_uranium",
        "artifact_crystal",
        "cafeteria_steam_trap_valve",
        "scientist_door",
        "pf188_auto374",
        "pf188_auto376",
        "wells_portrait",
        "pf188_auto72",
        "power_fan",
        "pf241_auto1",
        "soul_generator_railing",
        "generator_steam_trap_valve",
        "crystal_door",
        "crystal_door_clip",
        "gersch_code_monitor",
        "elysium_debris",
        "reception_barrier_clip",
        "kraken_boss",
        "tunnel2_steam_trap_valve",
        "trial_trigger",
        "audio_bump_trigger",
        "excavator_trigger",
        "excavator_control_panel",
        "radio_trigger",
        "power_off_trigger",
        "time_trials_trigger",
        "colored_valve_trigger",
        "ee_cryo_button",
        "test_tube_area_trigger",
        "uranium_deposit_trigger",
        "artifact_machine_trigger",
        "pantheon_place_skull_trigger",
        "steam_trap_trigger",
        "cafeteria_steam_trap_damage",
        "hacker_spawn_trigger",
        "vril_pickup_trigger",
        "portrait_damage_trigger",
        "pressure_door_trigger",
        "harpoon_station_trigger",
        "zm_leaper_spawner",
        "ss_activation_trigger",
        "ss_trigger",
        "zm_diver_spawner",
        "uranium_grab_trigger",
        "mine_release_trigger",
        "elysium_damage_trigger",
        "diver_helmet_trigger",
        "gold_mask_trigger",
        "shark_mask_trigger",
        "kraken_helmet_trigger",
        "leaper_mask_trigger",
        "wearable_teleporter_trigger",
        "no_powerups",
        "tunnel2_steam_trap_damage",
        "qed_garage_trigger"
    ];

    foreach(target in targetname_cull_ents)
    {
        foreach(ent in getEntArray(target, "targetname"))
        {
            culled++;
            ent delete();
        }
    }

    modelname_cull_ents = 
    [
        "p7_zm_der_trap_zapper_coil",
        "p7_zm_moo_door_airlock_heavy_lt_locked",
        "p7_zm_moo_console_button_panel_on",
        "lev_valve_blue",
        "p7_vent_metal_dampers_01",
        "p7_desk_metal_old_01_drawer_large_01_rusty",
        "p7_zm_moo_console_panel_side_off",
        "p7_zm_moo_computer_rocket_launch",
        "p7_mou_console_control_b_lrg_on",
        "p7_zm_moo_console_button_panel",
        "p7_machine_welding_small",
        "p7_zm_moo_console_panel_side_off",
        "p7_animal_plush_shark",
        "world_scuba_mask_gold",
        "c_zom_dlc4_player_apothican_helmet",
        "c_zm_leaper_mask",
        "lev_pressure_gauge_dial",
        "lev_valve_white",
        "c_zom_diver_miniboss_cutscene",
        "lev_submarine_clamp",
        "mini_submarine_cutscene"
    ];

    foreach(ent in getentarray())
    {
        if(!isdefined(ent.model))
        {
            continue;
        }
        if(isinarray(modelname_cull_ents, ent.model))
        {
            culled++;
            ent delete();
        }
    }

    noteworthy_cull_ents = 
    [
        "power_off_barriers",
        "p7_zm_moo_door_airlock_heavy_lt_locked"
    ];

    foreach(note in noteworthy_cull_ents)
    {
        foreach(ent in getEntArray(note, "script_noteworthy"))
        {
            culled++;
            ent delete();
        }
    }

    compiler::nprintln("INFO: ^2Culled ^3" + culled + "^2 entities.");
}
#endregion

#region zm_erosion
autoexec zm_erosion_auto()
{
    if(getdvarstring("mapname") == "zm_erosion_jss")
    {
        compiler::erasefunc("scripts/zm/_hb21_zm_dig_sites.gsc", 0xd9516fa0, 0x5ded3744);
        compiler::erasefunc("scripts/zm/_hb21_zm_dig_sites.gsc", 0xd9516fa0, 0x724676d0);

        compiler::erasefunc("scripts/zm/_zm_ancient_evil_challenges.gsc", 0xecf86d55, 0x9b6abb5);
    }
}

zm_erosion_init()
{
    level.zbr_hide_spawnprotect = true;

    getent("end_game_trig", "targetname").origin = ORIGIN_OOB;
    level.next_dog_round = 999;

    foreach(trig in getentarray("sundial_triggers", "targetname"))
    {
        trig notify("trigger", level.players[0]);
    }
}

zm_erosion_weapons()
{
    register_box_weapon("bo3_melee_boneglass", undefined);

    register_weapon_scalar("iw5_xm25", "iw5_xm25_up", 0.7, 0.25);
    register_weapon_postcalc("iw5_xm25_up", true);
    register_weapon_postcalc("iw5_xm25", true);
    register_weapon_scalar("iw5_stinger", "iw5_stinger_up", 0.7, 0.55);
    register_weapon_postcalc("iw5_stinger_up", true);
    register_weapon_postcalc("iw5_stinger", true);
    register_weapon_scalar("iw5_smaw", "iw5_smaw_up", 0.7, 0.3);
    register_weapon_postcalc("iw5_smaw_up", true);
    register_weapon_postcalc("iw5_smaw", true);
    register_weapon_scalar("iw5_rpg7", "iw5_rpg7_up", 0.7, 0.3);
    register_weapon_postcalc("iw5_rpg7_up", true);
    register_weapon_postcalc("iw5_rpg7", true);

    register_weapon_scalar("iw5_usas12", "iw5_usas12_up", 0.4, 0.15);
    register_weapon_scalar("iw5_ump45", "iw5_ump45_up", 4, 4);
    register_weapon_scalar("iw5_mp5", "iw5_mp5_up", 4, 4);
    register_weapon_scalar("iw5_mp7", "iw5_mp7_up", 11, 11);
    register_weapon_scalar("iw5_p90", "iw5_p90_up", 4, 4);
    register_weapon_scalar("iw5_fad", "iw5_fad_up", 3, 3);
    register_weapon_scalar("iw5_pp90m1", "iw5_pp90m1_up", 5, 5);
    register_weapon_scalar("iw5_type95", "iw5_type95_up", 3, 3);
    register_weapon_scalar("iw5_g36c", "iw5_g36c_up", 3, 3);
    register_weapon_scalar("iw5_cm901", "iw5_cm901_up", 3, 3);
    register_weapon_scalar("iw5_m16a4", "iw5_m16a4_up", 3, 3);
    register_weapon_scalar("iw5_m4a1", "iw5_m4a1_up", 3, 3);
    register_weapon_scalar("iw5_striker", "iw5_striker_up", 0.4, 0.2);
    register_weapon_scalar("iw5_mk14", "iw5_mk14_up", 0.4, 0.2);
    register_weapon_scalar("iw5_spas12", "iw5_spas12_up", 5, 5);
    register_weapon_scalar("iw5_acr", "iw5_acr_up", 5, 5);
    register_weapon_scalar("iw5_scarl", "iw5_scarl_up", 5, 5);
    register_weapon_scalar("iw5_ak74u", "iw5_ak74u_up", 5, 5);
    register_weapon_scalar("iw5_ak47", "iw5_ak47_up", 5, 5);
    register_weapon_scalar("iw5_rsass", "iw5_rsass_up", 0.1, 0.1);
    register_weapon_scalar("iw5_mp412", "iw5_mp412_up", 0.1, 0.1);
    register_weapon_scalar("iw5_dragunov", "iw5_dragunov_up", 0.1, 0.1);
    register_weapon_scalar("iw5_m82a1", "iw5_m82a1_up", 0.1, 0.1);
    register_weapon_scalar("iw5_as50", "iw5_as50_up", 0.1, 0.1);
    register_weapon_scalar("iw5_44magnum_ldw", "iw5_44magnum_ldw_up", 0.2, 0.2);
    register_weapon_scalar("iw5_44magnum_rdw", "iw5_44magnum_rdw_up", 0.2, 0.2);
}
#endregion

#region zm_terminal
autoexec zm_terminal_autoexec()
{
    if(getdvarstring("mapname") == "zm_terminal")
    {
        compiler::erasefunc("scripts/zm/zm_terminal.gsc", 0x2676c9d5, 0x248a6082); // intro function
        compiler::erasefunc("scripts/zm/zm_terminal.gsc", 0x2676c9d5, 0xc1c245d0); // intro function
        compiler::erasefunc("scripts/zm/zm_terminal.gsc", 0x2676c9d5, 0x787a03a9); // intro function

        compiler::erasefunc("scripts/zm/_zm_ai_quad.gsc", 0x1D58B607, 0x5af423f4); // intro function

        level.var_c7979e0a = function () => {}; // no sentinels please!
        level.var_3f4d66b7 = true;
        level.fn_zbr_check_bad_point = function(v_point) =>
        {
            if(is_point_inside_zone(v_point, "start_zone"))
            {
                if(distance2DSquared(v_point, (1902, 3875, 601)) > 90000)
                {
                    return true;
                }
                return false;
            }
            return (v_point[2] < 640) || zm_terminal_isbadpoint(v_point);
        };
    }
}

zm_terminal_init()
{
    level.zbr_hide_spawnprotect = true;
    level.round_prestart_func = undefined;
    level notify(#"hash_32d83299");

    thread [[ 
        function() => 
        {
            wait 5;
            level flag::set("power_on");
            wait 2;
            level notify(#"hash_f8cd2ab1");
            level.var_e9f9dcaa notify("trigger", level.players[0]);
            level.var_f356bc33 notify("trigger", level.players[0]);
            level.var_58d78e1e notify("trigger", level.players[0]);
            level.var_7051017  notify("trigger", level.players[0]);
            level.var_58467cf0 notify("trigger", level.players[0]);
            wait 0.05;
            level.var_d1e03384 delete();
            level.var_93523f80 delete();
        }]]();
    level.var_1a63e98a.origin = ORIGIN_OOB;
    getent("end_game_trig", "targetname").origin = ORIGIN_OOB;

    delete_perk_by_names("specialty_stunprotection", "vending_cryo");
    delete_perk_by_names("specialty_slider", "PhD Slider");
    delete_perk_by_names("specialty_gpsjammer", "vending_snails_pace");
    delete_perk_by_names("specialty_tombstone", "vending_tombstone");
    delete_perk_by_names("specialty_sprintfire", "vending_wind");
    delete_whos_who();

    fix_atomic_liqueur();
    fix_bwb();

    level.gm_oob_monitors[level.gm_oob_monitors.size] = function() =>
    {
        if(self.gm_objective_state)
        {
            ent = BulletTrace((2054, 7179, 1040), self.origin, true, undefined)["entity"];
            if(isdefined(ent) && ent == self)
            {
                return true;
            }
        }
        return zm_terminal_isbadpoint(self.origin);
    };

    setdvar("zombie_unlock_all", 1);
    zombie_doors = GetEntArray("zombie_debris", "targetname");
    n_max = 150 * 150;
    foreach(door in zombie_doors)
    {
        if(distancesquared(door.origin, (4009, 4815, 752)) > n_max)
        {
            continue;
        }
        door notify("trigger", level.players[0], 1);
    }
    wait 0.1;
    setdvar("zombie_unlock_all", 0);

    level.fn_pause_zbr_objective = function() =>
    {
        if((self.zone_name ?? "") == "maint_zone" && self.origin[2] > 1200)
        {
            return true;
        }
        if((self.zone_name ?? "") == "coffee_zone0" && self.origin[2] > 980)
        {
            return true;
        }
        if((self.zone_name ?? "") == "coffee_zone1" && self.origin[2] > 1000)
        {
            return true;
        }
        if((self.zone_name ?? "") == "power_zone" && self.origin[2] > 1280)
        {
            return true;
        }
        if((self.zone_name ?? "") == "spud_zone1" && self.origin[2] > 1000)
        {
            return true;
        }
        if((self.zone_name ?? "") == "spud_zone2" && self.origin[2] > 1000)
        {
            return true;
        }
        if((self.zone_name ?? "") == "right_zone" && self.origin[2] > 1000)
        {
            return true;
        }
        if((self.zone_name ?? "") == "right_zone2" && self.origin[2] > 1000)
        {
            return true;
        }
        return !isdefined(self.zone_name);
    };
}

zm_terminal_weapons()
{
    // weapon balancing for terminal: want moderately powerful snipers (20000), strong ars (25000), strong shotguns (20000)
    // everything else should be fair but not good. (< 10000 dps with doubletap)
    // pistols: (10000)
    // smgs: (13000)
    // mgs: (17000)
    // explosives: (10000)

    // AATs should do less damage on this map because the TTK is lowered significantly
    level.f_aat_scalar = 0.3;

    f_bolt_sniper_damage_boost = 3.25;

    register_weapon_scalar("iw8_vlkrogue", "iw8_vlkrogue_up", 0.106, 0.106);
    register_weapon_scalar("iw8_x16", "iw8_x16_up", 0.682, 0.682);
    register_weapon_scalar("iw8_mini_uzi", "iw8_mini_uzi_up", 0.677, 0.677);
    register_weapon_scalar("iw8_sks", "iw8_sks_up", 0.189, 0.189);
    register_weapon_scalar("iw8_sa87", "iw8_sa87_up", 0.347, 0.347);
    register_weapon_scalar("iw8_rpg7", "iw8_rpg7_up", 0.649, 0.649);
    register_weapon_scalar("iw8_renetti_rdw", "iw8_renetti_rdw_up", 0.066, 0.066);
    register_weapon_scalar("iw8_renetti_ldw", "iw8_renetti_ldw_up", 0.066, 0.066);
    register_weapon_scalar("iw8_ram7", "iw8_ram7_up", 1.59, 1.59);
    register_weapon_scalar("iw8_r90", "iw8_r90_up", 0.135, 0.135);
    register_weapon_scalar("iw8_pkm", "iw8_pkm_up", 0.262, 0.262);
    register_weapon_scalar("iw8_p90", "iw8_p90_up", 0.325, 0.325);
    register_weapon_scalar("iw8_origin12", "iw8_origin12_up", 0.0669, 0.0669);
    register_weapon_scalar("iw8_vks", "iw8_vks_up", 0.075, 0.075);
    register_weapon_scalar("iw8_oden", "iw8_oden_up", 0.318, 0.318);
    register_weapon_scalar("iw8_mp5", "iw8_mp5_up", 0.469, 0.469);
    register_weapon_scalar("iw8_model680", "iw8_model680_up", 0.279, 0.279);
    register_weapon_scalar("iw8_mk2carbine", "iw8_mk2carbine_up", 0.098, 0.098);
    register_weapon_scalar("iw8_minigun", "iw8_minigun_up", 0.25, 0.25);
    register_weapon_scalar("iw8_mg34", "iw8_mg34_up", 0.255, 0.255);
    register_weapon_scalar("iw8_m91", "iw8_m91_up", 0.314, 0.314);
    register_weapon_scalar("iw8_m19", "iw8_m19_up", 1, 0.038);
    register_weapon_scalar("iw8_m13", "iw8_m13_up", 0.709, 0.709);
    register_weapon_scalar("iw8_m4a1_sniper", "iw8_m4a1_sniper_up", 0.107, 0.107);
    register_weapon_scalar("iw8_m4a1_smg", "iw8_m4a1_smg_up", 0.672, 0.672);
    register_weapon_scalar("iw8_m4a1", "iw8_m4a1_up", 1.212, 1.212);
    register_weapon_scalar("iw8_kar98k_irons", "iw8_kar98k_irons_up", f_bolt_sniper_damage_boost * 0.361, f_bolt_sniper_damage_boost * 0.361);
    register_weapon_scalar("iw8_kar98k_scope", "iw8_kar98k_scope_up", f_bolt_sniper_damage_boost * 0.257, f_bolt_sniper_damage_boost * 0.257);
    register_weapon_scalar("iw8_g36k", "iw8_g36k_up", 1.786, 1.786);
    register_weapon_scalar("iw8_holger26", "iw8_holger26_up", 0.769, 0.769);
    register_weapon_scalar("iw8_hdr", "iw8_hdr_up", f_bolt_sniper_damage_boost * 0.15, f_bolt_sniper_damage_boost * 0.15);
    register_weapon_scalar("iw8_grau556", "iw8_grau556_up", 0.371, 0.371);
    register_weapon_scalar("iw8_fr556", "iw8_fr556_up", 1.40, 1.40);
    register_weapon_scalar("iw8_scar17s", "iw8_scar17s_up", 0.781, 0.781);
    register_weapon_scalar("iw8_fal", "iw8_fal_up", 0.045, 0.045);
    register_weapon_scalar("iw8_m21ebr", "iw8_m21ebr_up", 0.094, 0.094);
    register_weapon_scalar("iw8_ebr14", "iw8_ebr14_up", 0.272, 0.272);
    register_weapon_scalar("iw8_dragunov", "iw8_dragunov_up", 0.107, 0.107);
    register_weapon_scalar("iw8_ax50", "iw8_ax50_up", f_bolt_sniper_damage_boost * 0.041, f_bolt_sniper_damage_boost * 0.041);
    register_weapon_scalar("iw8_aug_ar", "iw8_aug_ar_up", 1.95, 1.95);
    register_weapon_scalar("iw8_ak47", "iw8_ak47_up", 1.38, 1.38);
    register_weapon_scalar("iw8_1911_rdw", "iw8_1911_rdw_up", 0.34, 0.34);
    register_weapon_scalar("iw8_1911_ldw", "iw8_1911_ldw_up", 0.34, 0.34);
    register_weapon_scalar("iw8_725", "iw8_725_up", 0.133, 0.133);
    register_weapon_scalar("iw8_357", "iw8_357_up", 0.357, 0.357);
    register_weapon_scalar("iw8_50gs_rdw", "iw8_50gs_rdw_up", 0.06, 0.06);
    register_weapon_scalar("iw8_50gs_ldw", "iw8_50gs_ldw_up", 0.06, 0.06);
    register_weapon_scalar("spudgun_v3", "spudgun_v3_up", 0.131, 0.131);

    register_weapon_postcalc("iw8_rpg7", true);
    register_weapon_postcalc("iw8_rpg7_up", true);
    register_weapon_postcalc("iw8_1911_rdw", true);
    register_weapon_postcalc("iw8_1911_rdw_up", true);
    register_weapon_postcalc("iw8_1911_ldw", true);
    register_weapon_postcalc("iw8_1911_ldw_up", true);

    register_box_weapon("spudgun_v3", "spudgun_v3_up");
    register_box_weapon("spudgun_v2", "spudgun_v2_up");
    register_box_weapon("spudgun", "spudgun_up");
    register_box_weapon("spx_zombie_shield", "spx_zombie_shield_upgraded");

    // These weapons are too powerful for this map
    remove_box_weapon("thundergun", "thundergun_upgraded");
    remove_box_weapon("raygun_mark2", "raygun_mark2_upgraded");
    remove_box_weapon("tesla_gun", "tesla_gun_upgraded");
    remove_box_weapon("hero_gravityspikes_melee");
    remove_box_weapon("hero_annihilator", "hero_annihilator");

    set_level_olympia("iw8_725", "iw8_725_up");
}

zm_terminal_isbadpoint(v_point)
{
    if(!isdefined(v_point))
    {
        return true;
    }

    if(!isdefined(level.zm_terminal_badpoint_origins))
    {
        level.zm_terminal_badpoint_origins = array(
            (3997, 2652, 676),
            (5132, 7004, 627),
            (-53, 9196, 640),
            (350, 6694, 611)
        );
        level.zm_terminal_distmax = distancesquared((2799, 5589, 1174), (-2650, -1320, 1569));
        level.zm_terminal_mapcenter = (2799, 5589, 1174);
    }

    foreach(spot in level.zm_terminal_badpoint_origins)
    {
        ent = BulletTrace(spot, v_point, true, undefined)["entity"];
        if(isdefined(ent) && ent == self)
        {
            return true;
        }
    }

    return distancesquared(v_point, level.zm_terminal_mapcenter) > level.zm_terminal_distmax;
}
#endregion

#region zm_dust_2
zm_dust_2_init()
{
    dust_price_clamping = function() =>
    {
        if(!isdefined(self.zombie_cost))
        {
            return;
        }
        if(self.zombie_cost > 750)
        {
            self.zombie_cost = 750;
            if(self.targetname == "zombie_door")
            {
                self zm_utility::set_hint_string(self, "default_buy_door", self.zombie_cost);
            }
            else
            {
                self zm_utility::set_hint_string(self, "default_buy_debris", self.zombie_cost);
            }
        }
    };
    a_door_buys = getentarray("zombie_door", "targetname");
    array::thread_all(a_door_buys, dust_price_clamping);
    a_debris_buys = getentarray("zombie_debris", "targetname");
    array::thread_all(a_debris_buys, dust_price_clamping);
}
#endregion

#region zm_rainy_death

autoexec zm_rainydeath_autoexec()
{
    if(tolower(getdvarstring("mapname")) == "zm_rainy_death")
    {
        setdvar("elmg_cheats", 0); // really?
        compiler::script_detour("scripts/zm/zm_rainy_death.gsc", 0xa9d5c647, 0x63e03e36, function() =>
        {
            // do nothing, this zombies health changing thing would make zbr a bit too easy
        });

        compiler::script_detour("scripts/zm/_zm_priv_collection_quest.gsc", 0x833523fe, 0xab59e99, function(player, sound_origin) =>
        {
            door_model = getent("sq_privcollection_officedoor", "targetname");
            barrel = getent("sq_privcollection_barrel", "targetname");
            door_model rotateto(vectorscale((0, 1, 0), 277), 0.5);
            barrel moveto((105, -5088, 82), 0.25);
            barrel rotateto((300, 0, -90), 0.25);
            clip = getent("sq_privcollection_officedoorclip", "targetname");
            clip connectpaths();
            clip delete();
            var_f25ac17a = getent("sq_privcollection_vitrinedoor", "targetname");
            var_f25ac17a rotateto(vectorscale((0, 0, 1), 178), 0.5);
            var_f25ac17a moveto(var_f25ac17a.origin + (0, 0, 1), 0.5);
        });

        compiler::script_detour("scripts/zm/_zm_weap_killerwatt.gsc", 0x632680d8, 0x4efdb3d0, serious::zm_rd_killerwatt_fire);
        compiler::script_detour("scripts/zm/_zm_placeable_m15mines.gsc", 0x116f8264, 0x2b7df3ba, serious::zm_rd_tripmine_watch);

        compiler::script_detour("scripts/zm/_zm_trap_elecgen.gsc", 0xe7ba5142, 0x37ebf5db, function() => 
        {
            level endon(#"hash_864c2771");
            function_f2ceb495 = @namespace_e7ba5142<scripts\zm\_zm_trap_elecgen.gsc>::function_f2ceb495;
            for(;;)
            {
                foreach(ent in GetAITeamArray(level.zombie_team))
                {
                    if(!isdefined(ent) || !isalive(ent))
                    {
                        continue;
                    }
                    if(isdefined(ent.animname) && ent.animname == "zombie_boss")
                    {
                        continue;
                    }
                    if(ent istouching(self))
                    {
                        ent thread [[ function_f2ceb495 ]]();
                    }
                }

                foreach(player in level.players)
                {
                    if(player.sessionstate != "playing")
                    {
                        continue;
                    }
                    if(player istouching(self))
                    {
                        player thread [[ function(trig) => 
                        {
                            self endon("death");
                            self endon("bled_out");
                            self endon("disconnect");
                            if(!(isdefined(self.is_burning) && self.is_burning) && zm_utility::is_player_valid(self) && !self laststand::player_is_in_laststand())
                            {
                                self.is_burning = 1;
                                if(isdefined(level.trap_electric_visionset_registered) && level.trap_electric_visionset_registered)
                                {
                                    visionset_mgr::activate("overlay", "zm_trap_electric", self, 1.25, 1.25);
                                }
                                else
                                {
                                    self setelectrified(1.25);
                                }
                                if(isdefined(level.str_elec_damage_shellshock_override))
                                {
                                    str_elec_shellshock = level.str_elec_damage_shellshock_override;
                                }
                                else
                                {
                                    str_elec_shellshock = "electrocution";
                                }
                                self shellshock(str_elec_shellshock, 2.5);
                                self playrumbleonentity("damage_heavy");
                                self playsound("wpn_zmb_electrap_zap");
                                if(!self hasperk("specialty_armorvest"))
                                {
                                    self dodamage(int(self.health + 666), self.origin, undefined, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                                }
                                else
                                {
                                    self dodamage(int(CLAMPED_ROUND_NUMBER * 1000), self.origin, undefined, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                                }
                                wait(0.25);
                                self.is_burning = undefined;
                            }

                        }]](self);
                    }
                }             
                wait(0.1);
            }
        });

        getent("trap_elecgen_triguse", "targetname") thread [[ function() => 
        {
            self endon("death");
            for(;;)
            {
                self waittill("trigger", player);
                getent("trap_elecgen_trighurt", "targetname").owner = player;
            }
        }]]();

        clientfield::register("allplayers", "bl2_aat_slag_fx_plr", 1, 2, "int");
        clientfield::register("allplayers", "bl2_aat_radiation_fx_plr", 1, 1, "int");
        clientfield::register("allplayers", "bl2_aat_incendiary_fx_plr", 1, 2, "int");
        clientfield::register("allplayers", "bl2_aat_cryo_fx_plr", 1, 2, "int");
        clientfield::register("allplayers", "bl2_aat_shock_fx_plr", 1, 2, "int");
    }
}

zm_rainy_death_init()
{
    level.zbr_glow_fx = "custom_fx/fx_loot_tick_legendary";

    // kill their custom hitmarkers
    arrayremovevalue(level.zombie_damage_callbacks, @namespace_7d7fe8fd<scripts\zm\_zm_hitmarkers.gsc>::function_cc82b62a, false);
    zm_spawner::deregister_zombie_death_event_callback(@namespace_7d7fe8fd<scripts\zm\_zm_hitmarkers.gsc>::function_2adc7b38);

    if(isdefined(getent("round_start_trigger", "targetname")))
    {
        getent("round_start_trigger", "targetname").origin = level.players[0].origin;
        level.round_prestart_func = undefined;
    }

    level.fn_zbr_custom_kill_reward = function(victim, iDamage, sMeansOfDeath, weapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration) =>
    {  
        if(!isdefined(self.token))
        {
            self.token = 0;
        }
        self.token += 20;
        self clientfield::set_player_uimodel("kf2_player_tokencount", self.token);
    };
    
    var_ad3aab3d = getent("spawn_target_door", "targetname");
    var_ad3aab3d moveto(var_ad3aab3d.origin + vectorscale((0, 0, 1), 88), 12, 2, 2);
    var_ad3aab3d connectpaths();
    playsoundatposition("sfx_garage_open", var_ad3aab3d.origin);

    // open key rooms
    getent("key_locker_trigger", "targetname").origin = ORIGIN_OOB;
    getent("key_required_trigger", "targetname").origin = ORIGIN_OOB;
    getent("key_locker_door", "targetname").origin = ORIGIN_OOB;
    getent("key_model", "targetname").origin = ORIGIN_OOB;
    getent("key_required_door", "targetname") rotateto(vectorscale((0, 1, 0), 135.6), 1, 0.5, 0.5);
    getent("key_required_door_static", "targetname") delete();
	foreach(clip in getentarray("key_required_clip", "targetname"))
	{
		clip connectpaths();
		clip delete();
	}

    // open pap
    thread [[ function() => 
    {
        getent("pap_entrance_reroute_trigger", "targetname").origin = ORIGIN_OOB;
        getent("pap_entrance_trigger", "targetname").origin = ORIGIN_OOB;
        pap_entrance_gate = getent("pap_entrance_gate", "targetname");
        playsoundatposition("sfx_sewer_drain", pap_entrance_gate.origin);
        pap_entrance_flood = getent("pap_entrance_flood", "targetname");
        pap_entrance_flood moveto(pap_entrance_flood.origin - vectorscale((0, 0, 1), 82), 10, 4, 0);
        wait(8);
        pap_entrance_gate moveto(pap_entrance_gate.origin - vectorscale((0, 0, 1), 150), 6, 1, 0);
        playsoundatposition("sfx_metal_gate_big_open", pap_entrance_gate.origin);
        wait(7);
        pap_entrance_flood delete();
        pap_entrance_gate delete();
        pap_entrance_barricades = getentarray("pap_entrance_barricade", "targetname");
        foreach(barricade in pap_entrance_barricades)
        {
            playsoundatposition("sfx_metal_pipe_down", barricade.origin);
            barricade moveto(barricade.origin - vectorscale((0, 0, 1), 46), 1.5, 0.5);
            barricade connectpaths();
            wait(0.25);
        }
        pap_entrance_clip_instant = getentarray("pap_entrance_clip_instant", "targetname");
        foreach(clip in pap_entrance_clip_instant)
        {
            clip connectpaths();
            clip delete();
        }
        pap_entrance_clip = getentarray("pap_entrance_clip", "targetname");
        foreach(clip in pap_entrance_clip)
        {
            clip moveto(clip.origin - vectorscale((0, 1, 0), 100), 1);
        }
        pap_entrance_blocker = getent("pap_entrance_blocker", "targetname");
        pap_entrance_blocker moveto((150.831, -3368.25, 74.677), 0.5);
        pap_entrance_blocker rotateto((359.612, 269.9, 104.4), 0.5);
        pap_entrance_blocker connectpaths();
        zm_zonemgr::enable_zone("zone_pap_sewers");
        level.var_796d2fd9 = 1;
        if(isdefined(level.var_ab774895))
        {
            if(!isdefined(level.var_ab774895))
            {
                level.var_ab774895 = [];
            }
            else if(!isarray(level.var_ab774895))
            {
                level.var_ab774895 = array(level.var_ab774895);
            }
            level.var_ab774895[level.var_ab774895.size] = "bonfire_sale";
        }
        wait(1.5);
        foreach(clip in pap_entrance_clip)
        {
            clip connectpaths();
            clip delete();
        }
    } ]]();

    // disable side quest
    getent("sq_terminal_conduit_placed_trig", "targetname").origin = ORIGIN_OOB;
    getent("sq_terminal_conduit_pickup_trig", "targetname").origin = ORIGIN_OOB;

    // disable quest to obtain scythe (we will put this in the box)
    zm_spawner::deregister_zombie_death_event_callback(@namespace_37780737<scripts\zm\_zm_shadows_quest.gsc>::function_b4ca3615);

    // diable side quest to obtain kp31 (we will put this in the box)
    level notify(#"hash_1643b2a8");
    wait 0.05;
    waittillframeend;
    getent("sq_privcollection_officedoortrig", "targetname") notify("trigger", level.players[0]);
    getent("sq_privcollection_mainpurchase", "targetname").origin = ORIGIN_OOB;
    
    // make tomahawk available
    thread [[ function() =>
    {
        foreach(ent in getentarray("sq_hatchet_pickup", "targetname"))
        {
            ent delete();
        }

        getent("sq_hatchet_seethis", "targetname") notify("trigger", level.players[0]);
        wait 0.05;
        waittillframeend;

        level thread [[ @namespace_895ccb31<scripts\zm\_zm_hatchet_quest.gsc>::function_c5a0316 ]]();
    }]]();
    
    // get rid of the bank feature
    getent("sharebank_trigger", "targetname").origin = ORIGIN_OOB;
    getent("sharebank_hint_trigger", "targetname").origin = ORIGIN_OOB;

    level._custom_powerups["openfire"].grab_powerup = function(_player) => 
    {
        self thread [[ function(_player) => {
            time = 15;
            if(!isdefined(level.zombie_vars[_player.team]))
            {
                level.zombie_vars[_player.team] = [];
            }
            if(!isdefined(level.zombie_vars[_player.team]["zombie_powerup_openfire_on"]))
            {
                level.zombie_vars[_player.team]["zombie_powerup_openfire_on"] = 0;
                level.zombie_vars[_player.team]["zombie_powerup_openfire_time"] = 0;
            }
            level.zombie_vars[_player.team]["zombie_powerup_openfire_time"] = time;
            level.zombie_vars[_player.team]["zombie_powerup_openfire_on"] = 1;
            temp_ent = spawn("script_origin", (0, 0, 0));
            temp_ent playloopsound("zmb_double_points_loop");
            foreach(player in level.players)
            {
                if(player.team != _player.team)
                {
                    continue;
                }
                player thread [[ function(team) =>
                {
                    self endon("disconnect");
                    self endon("bled_out");
                    self notify("end_rd_infammo" + team);
                    self endon("end_rd_infammo" + team);
                    level endon("end_rd_infammo" + team);
                    time_current = gettime();
                    while((gettime() - time_current) < 15000)
                    {
                        self util::waittill_any_timeout(0.25, "weapon_fired", "grenade_fire", "missile_fire", "weapon_change", "reload");
                        weapon = self getcurrentweapon();
                        if(!isdefined(weapon)) continue;
                        if(weapon != "none")
                        {
                            self setWeaponAmmoClip(weapon, 1337);
                            self giveMaxAmmo(weapon);
                        }
                        if(self getCurrentOffHand() != "none")
                        {
                            self giveMaxAmmo(self getCurrentOffHand());
                        }
                    }
                } ]](player.team);
                player clientfield::set_to_player("kf2_player_infiniteammo", 1);
                primary_weapons = player getweaponslist(1);
                for(x = 0; x < primary_weapons.size; x++)
                {
                    if(zm_utility::is_lethal_grenade(primary_weapons[x]) || zm_utility::is_tactical_grenade(primary_weapons[x]) || zm_utility::is_hero_weapon(primary_weapons[x]))
                    {
                        continue;
                    }
                    if(player hasweapon(primary_weapons[x]))
                    {
                        player setweaponammoclip(primary_weapons[x], 1000);
                        if(isdefined(primary_weapons[x].isdualwield) && primary_weapons[x].isdualwield)
                        {
                            player setweaponammoclip(primary_weapons[x].dualwieldweapon, 1000);
                        }
                    }
                }
            }
            while(level.zombie_vars[_player.team]["zombie_powerup_openfire_time"] > 0)
            {
                wait(0.05);
                level.zombie_vars[_player.team]["zombie_powerup_openfire_time"] = level.zombie_vars[_player.team]["zombie_powerup_openfire_time"] - 0.05;
            }
            foreach(player in level.players)
            {
                if(player.team != _player.team)
                {
                    continue;
                }
                player clientfield::set_to_player("kf2_player_infiniteammo", 0);
                player playlocalsound("zmb_double_points_loop_off");
            }
            level.zombie_vars[_player.team]["zombie_powerup_openfire_on"] = 0;
            level notify("end_rd_infammo" + _player.team);
            temp_ent delete();
        }]](_player);
    };

    // I may come back to this int he future but for now it has to go. It would be far too complicated to support it for the time being. RAINY_DEATH_PERK_SHADOWCIDER
    delete_perk_by_names("specialty_shellshock", "vending_shadowcider");

    getent("rd_gamemodes_machine", "targetname").origin = ORIGIN_OOB;
    getent("gamemode_vendor_trigger", "targetname").origin = ORIGIN_OOB;

    unlock_all_debris();
    open_all_doors();
}

#define ZM_RAINYDEATH_SHOCK_SMALLDMG = 250;
#define ZM_RAINYDEATH_SLAG_HDMGPROC_CHANCE = 33;
#define ZM_RAINYDEATH_THERMITE_DMG_PER_ROUND = 250;
#define ZM_RAINYDEATH_THAWK_IMPACT_PER_ROUND = 3000;
#define ZM_RAINYDEATH_THAWK_EXPLO_PER_ROUND = 1000;
#define ZM_RAINYDEATH_SCYTHE_PER_ROUND = (1250);
#define ZM_RAINYDEATH_HERO_PERROUND = 2000;

rainy_death_reregister_aat(name, percentage, cooldown_time_entity, cooldown_time_attacker, cooldown_time_global, occurs_on_death, result_func, damage_feedback_icon, damage_feedback_sound, validation_func)
{
	level.aat[name].percentage = percentage;
	level.aat[name].cooldown_time_entity = cooldown_time_entity;
	level.aat[name].cooldown_time_attacker = cooldown_time_attacker;
	level.aat[name].cooldown_time_global = cooldown_time_global;
	level.aat[name].cooldown_time_global_start = 0;
	level.aat[name].occurs_on_death = occurs_on_death;
	level.aat[name].result_func = result_func;
	level.aat[name].validation_func = validation_func;
}

zm_rainy_death_weapons()
{
    // map meta design:
    // theory: this map feels pretty close quarters in almost everywhere except the map center. This naturally means that the center will be an arena.
    //         Additionally, the map is really oriented around its AAT system and the creative weapons, so it should be designed around those weapons specifically, with counters laid out after.
    //         The map really has an issue where players are concentrated around the center of the map for most of the game, ignoring the edges. Long lines of sight exist but so too do close quarters fights.
    //         The meta that I believe would fit this map best is the following:
    //         Wonder-weapons: Best (Map Identity)
    //         Snipers: Very Strong (Line of sight role, controls middle map)
    //         Shotguns: Strong (Controls the frequent CQB but ease of use is far greater than SMGs, so needs penalty)
    //         SMGs: Very Strong (Controls CQB)
    //         ARs: Acceptible (These are mid range weapons, the utility for them on this map doesnt really exist)
    //         Explosives: Strong (We should have counters to wonder weapons but they shouldn't dominate the map)
    //         LMGs: Very Strong (Can fight snipers but will be too cumbersome for CQB)
    //         Pistols: Varies (each pistol has a unique identity that will be customized)

    level.customs_zombie_damage_scalar = 3; // weapons dont do enough damage to zombies on this map for ZBR.

    level.rd_playfx = @namespace_66316922<scripts\zm\_hv_utilities.gsc>::play_fx;

    register_box_weapon("smg_kp31", "smg_kp31_upgraded");
	util::clientnotify("include_kp31_in_box");

    register_weapon_calculator("thermite_grenade", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(CLAMPED_ROUND_NUMBER * ZM_RAINYDEATH_THERMITE_DMG_PER_ROUND);
    });

    register_weapon_postcalc("tactical_explo_tomahawk", true);
    register_weapon_calculator("tactical_explo_tomahawk", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        if(sMeansOfDeath == "MOD_IMPACT")
        {
            return int(CLAMPED_ROUND_NUMBER * ZM_RAINYDEATH_THAWK_IMPACT_PER_ROUND);
        }
        return int(CLAMPED_ROUND_NUMBER * ZM_RAINYDEATH_THAWK_EXPLO_PER_ROUND);
    });

    // register_weapon_postcalc("melee_scythe", true);
    // register_weapon_postcalc("melee_scythe_upgraded", true);

    register_box_weapon("melee_scythe", "melee_scythe_upgraded");
    register_box_weapon("pistol_ratking", "pistol_ratking_upgraded");
    register_box_weapon("special_killerwatt", "special_killerwatt_upgraded");
    register_box_weapon("hero_strikers_melee");
    register_box_weapon("special_laserkraftwerk", "special_laserkraftwerk_upgraded");
    register_box_weapon("special_tractor", "special_tractor_upgraded");

    register_weapon_postcalc("special_laserkraftwerk", true);
    register_weapon_postcalc("special_laserkraftwerk_upgraded", true);
    register_weapon_calculator("special_laserkraftwerk", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(CLAMPED_ROUND_NUMBER * 300);
    });

    register_weapon_calculator("special_laserkraftwerk_upgraded", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(CLAMPED_ROUND_NUMBER * 700);
    });

    register_weapon_postcalc("misc_m15mines", true);
    register_weapon_calculator("misc_m15mines", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(CLAMPED_ROUND_NUMBER * 1750);
    });
    
    register_weapon_calculator("pistol_ratking", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        n_num_zombs = attacker?.ratking_zombie_count ?? 0;
        n_num_zombs = min(8, n_num_zombs);
        
        return int((CLAMPED_ROUND_NUMBER * 75) + n_num_zombs * 125) * ((sMeansOfDeath == "MOD_HEAD_SHOT") ? 2 : 1);
    });

    register_weapon_calculator("pistol_ratking_upgraded", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        n_num_zombs = attacker?.ratking_zombie_count ?? 0;
        n_num_zombs = min(8, n_num_zombs);
        
        return int((CLAMPED_ROUND_NUMBER * 150) + n_num_zombs * 250) * ((sMeansOfDeath == "MOD_HEAD_SHOT") ? 2 : 1);
    });

    // Balancing Tables
    
    level.balance_adjust_easy_scalar = 0.3; // I messed up by factoring all this dps as round 20 dps when its actually round 20 so this scalar will fix that
    
    // register_weapon_scalar("launcher_smr", "launcher_smr_upgraded", 10.00, 10.00);
    // register_weapon_scalar("launcher_mk32", "launcher_mk32_upgraded", 9.03, 9.03);
    // register_weapon_scalar("launcher_mk32_lh", "launcher_mk32_lh_upgraded", 9.03, 9.03);
    // register_weapon_scalar("launcher_seekersix", "launcher_seekersix_upgraded", 9.92, 9.92);
    // register_weapon_scalar("launcher_m320", "launcher_m320_upgraded", 15.31, 15.31);

    // register_weapon_scalar("shotgun_sg500", "shotgun_sg500_upgraded", 5.44, 5.44);
    // register_weapon_scalar("shotgun_shg45", "shotgun_shg45_upgraded", 2, 2);
    // register_weapon_scalar("shotgun_goliath", "shotgun_goliath_upgraded", 2, 2);
    // register_weapon_scalar("shotgun_boomstick", "shotgun_boomstick_upgraded", 8.56, 8.56);
    // register_weapon_scalar("shotgun_hz12", "shotgun_hz12_upgraded", 3.75, 3.75);
    // register_weapon_scalar("shotgun_ahnuhld_lh", "shotgun_ahnuhld_lh_upgraded", 3.11, 3.11);
    // register_weapon_scalar("shotgun_ahnuhld", "shotgun_ahnuhld_upgraded", 3.11, 3.11);

    // register_weapon_scalar("sniper_pdp70", "sniper_pdp70_upgraded", 2.07, 2.07);
    // register_weapon_scalar("sniper_m99amr", "sniper_m99amr_upgraded", 2 * 2.21, 2 * 2.21);
    // register_weapon_scalar("sniper_thanatos", "sniper_thanatos_upgraded", 4 * 1, 4 * 1);
    // register_weapon_scalar("sniper_awp", "sniper_awp_upgraded", 4 * 1.48, 4 * 1.48);
    // register_weapon_scalar("sniper_longbow", "sniper_longbow_upgraded", 3.7, 3.7);

    // register_weapon_scalar("lmg_spitfire", "lmg_spitfire_upgraded", 5.85, 5.85);
    // register_weapon_scalar("lmg_k121", "lmg_k121_upgraded", 6.72, 6.72);
    // register_weapon_scalar("lmg_qbb95", "lmg_qbb95_upgraded", 5.88, 5.88);
    // register_weapon_scalar("lmg_minigun", "lmg_minigun_upgraded", 1.5, 1.5);

    // register_weapon_scalar("smg_kp31", "smg_kp31_upgraded", 3.51, 3.51);
    // register_weapon_scalar("smg_r99", "smg_r99_upgraded", 8.00, 8.00);
    // register_weapon_scalar("smg_smg43", "smg_smg43_upgraded", 2.12, 2.12);
    // register_weapon_scalar("smg_mp5ras", "smg_mp5ras_upgraded", 5.74, 5.74);
    // register_weapon_scalar("smg_p90", "smg_p90_upgraded", 5.3, 5.3);
    // register_weapon_scalar("smg_crotzni", "smg_crotzni_upgraded", 5.45, 5.45);
    // register_weapon_scalar("smg_vector", "smg_vector_upgraded", 2.5, 2.5);

    // register_weapon_scalar("ar_asval", "ar_asval_upgraded", 3.61, 3.61);
    // register_weapon_scalar("ar_repeater", "ar_repeater_upgraded", 0.78, 0.78);
    // register_weapon_scalar("ar_commando", "ar_commando_upgraded", 3.33, 3.33);
    // register_weapon_scalar("ar_hemlok", "ar_hemlok_upgraded", 7.81, 7.81);
    // register_weapon_scalar("ar_fnfal", "ar_fnfal_upgraded", 1.82, 1.82);
    // register_weapon_scalar("ar_ak5c", "ar_ak5c_upgraded", 3.27, 3.27);
    // register_weapon_scalar("ar_ar15", "ar_ar15_upgraded", 3.68, 3.68);
    // register_weapon_scalar("ar_groza", "ar_groza_upgraded", 3.68, 3.68);

    // register_weapon_scalar("pistol_re45", "pistol_re45_upgraded", 1.54, 1.54);
    // register_weapon_scalar("pistol_judge", "pistol_judge_upgraded", 2 * 0.161, 0.161);
    // register_weapon_scalar("pistol_judge_lh", "pistol_judge_lh_upgraded", 0.161, 0.161);
    // register_weapon_scalar("pistol_magnum", "pistol_magnum_upgraded", 3.83, 3.83);
    // register_weapon_scalar("pistol_m93r", "pistol_m93r_upgraded", 1.73, 1.73);
    // register_weapon_scalar("pistol_hp_lh_upgraded", "pistol_hp_upgraded", 3.48, 3.48);


    level.balance_adjust_easy_scalar = 1.0;
    // register_weapon_postcalc("launcher_smr", true);
    // register_weapon_postcalc("launcher_smr_upgraded", true);
    // register_weapon_postcalc("launcher_mk32", true);
    // register_weapon_postcalc("launcher_mk32_lh", true);
    // register_weapon_postcalc("launcher_mk32_upgraded", true);
    // register_weapon_postcalc("launcher_mk32_lh_upgraded", true);
    // register_weapon_postcalc("launcher_seekersix", true);
    // register_weapon_postcalc("launcher_seekersix_upgraded", true);
    // register_weapon_postcalc("launcher_m320", true);
    // register_weapon_postcalc("launcher_m320_upgraded", true);
    // register_weapon_postcalc("pistol_hp_upgraded", true);
    // register_weapon_postcalc("pistol_hp_lh_upgraded", true);

    #region AAT
    
    // set this variable so that normal hitmarkers appear since this map has unique AAT behavior
    level.b_should_expect_aat_hitmarkers = false;

    arrayremovevalue(level.zombie_damage_callbacks, @namespace_f4a5782c<scripts\zm\aats\_zm_bl2_aat_system.gsc>::function_d805556f, false);
    zm_spawner::deregister_zombie_death_event_callback(@namespace_f4a5782c<scripts\zm\aats\_zm_bl2_aat_system.gsc>::function_92176b3e);

    callback::on_spawned(function() => 
    {
        self.var_2e629bce = 0; // duration of our slag
        self.var_a1e83b0f = undefined; // lock for aats
    });
    
    // slag

    level.slagme = function(b_islongslag) =>
    {
        self notify("slagme");
        self endon("slagme");
        self endon("disconnect");
        self endon("death");
        self endon("bled_out");
        if(isplayer(self))
        {
            self.var_2e629bce = (self.var_2e629bce ?? 0) + 8 + (b_islongslag * 8);
            self clientfield::set("bl2_aat_slag_fx_plr", 1 + int(self.var_2e629bce > 8));
            wait self.var_2e629bce;
            self.var_2e629bce = undefined;
            self clientfield::set("bl2_aat_slag_fx_plr", 0);
        }
        else
        {
            self.var_2e629bce = (self.var_2e629bce ?? 0) + 8 + (b_islongslag * 8);
            self clientfield::set("bl2_aat_slag_fx", 1 + int(self.var_2e629bce > 8));
            wait(5);
            self.var_2e629bce = undefined;
            self clientfield::set("bl2_aat_slag_fx", 0);
        }
    };

    level.amislagged = function() =>
    {
        return isdefined(self.var_2e629bce) && self.var_2e629bce > 0;
    };

    // str_name, chance, cooldown ent, cooldown attacker, cooldown global, ondeath, result, icon, sound, validate
    rainy_death_reregister_aat("zm_aat_slag", 1.0, 0.05, 0, 0, true, function(victim, death, attacker, mod, weapon) =>
    {
        if(!isdefined(victim))
        {
            return;
        }
        victim endon("disconnect");
        victim endon("death");

        // is_slagged => victim.var_2e629bce
        if(death !== true)
        {
            // reapplying slag
            victim thread [[ level.slagme ]](false);
            return;
        }

        if(victim.var_2e629bce === true && randomfloatrange(0, 1) > 0.25)
        {
            // explode to nearby victims
            ents = ArrayCombine(array::get_all_closest(victim.origin, getplayers(), undefined, undefined, 400), array::get_all_closest(victim.origin, GetAITeamArray(level.zombie_team), undefined, undefined, 400), false, false);

            foreach(ent in ents)
            {
                if(ent == victim)
                {
                    continue;
                }
                if(isplayer(ent))
                {
                    if(ent.sessionstate != "playing" || ent laststand::player_is_in_laststand())
                    {
                        continue;
                    }
                    if(isdefined(attacker) && isdefined(ent.team) && ent.team == attacker.team)
                    {
                        continue;
                    }
                }
                else
                {
                    if(!isAlive(ent) || (isdefined(ent.animname) && ent.animname == "zombie_boss"))
                    {
                        continue;
                    }
                }
                ent thread [[ level.slagme ]](true);
            }
        }
        // else we are not slagged but are dying, and thus we cannot trigger the AAT

    }, "transparent", "null");

    // shock

    level.aat_shockme = function(shock_time = 5) =>
    {
        self endon("death");
        self endon("bled_out");
        self endon("disconnect");
        self notify("stun_zombie");
        self endon("stun_zombie");

        if(isplayer(self))
        {
            self thread electric_cherry_shock_fx();
            self electric_cherry_stun(true);
        }
        else
        {
            if(self.health <= 0 || self.ai_state !== "zombie_think")
            {
                return;
            }
            self clientfield::set("bl2_aat_shock_fx", 1);
            self.zombie_tesla_hit = 1;
            self.ignoreall = 1;
            wait(shock_time);
            if(isdefined(self))
            {
                self.zombie_tesla_hit = 0;
                self.ignoreall = 0;
                self notify("stun_fx_end");
                self clientfield::set("bl2_aat_shock_fx", 0);
            }
        }
    };

    rainy_death_reregister_aat("zm_aat_shock", 1.0, 0.05, 0, 0, true, function(victim, death, attacker, mod, weapon) =>
    {
        if(!isdefined(victim) || !isdefined(attacker))
        {
            return;
        }

        victim endon("death");
        victim endon("disconnect");
        victim endon(#"hash_f4d7c94a");
        // level.amislagged

        if(!isdefined(victim.var_5aa56fb4))
        {
            victim.var_5aa56fb4 = 0;
        }
        
        if(!(isdefined(death) && death) && (!(isdefined(victim.var_a1e83b0f) && victim.var_a1e83b0f)))
        {
            victim.var_5aa56fb4++;
            playfxontag(level._effect["fx_spark_small"], victim, array::random(level.var_d25df719));
            if(victim.var_5aa56fb4 >= 5)
            {
                if(isdefined(victim) && isdefined(attacker))
                {
                    victim dodamage(isPlayer(victim) ? (ZM_RAINYDEATH_SHOCK_SMALLDMG * (attacker get_aat_damage_multiplier())) : (250), isdefined(attacker.origin) ? attacker.origin : victim.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                }
                if(!isdefined(victim) || victim.health <= 0 && isdefined(attacker))
                {
                    return;
                }
                victim.var_a1e83b0f = 1;
                victim.var_5aa56fb4 = 0;
                victim playloopsound("sfx_aat_shock_lp");
                victim [[ level.aat_shockme ]]();
                victim.var_a1e83b0f = undefined;
                victim stoploopsound();
                playsoundatposition("sfx_aat_shock_start", victim.origin);
                return;
            }
            if(victim.var_5aa56fb4 == 1)
            {
                playsoundatposition("sfx_aat_shock_start", victim.origin);
            }
        }
        
        percentage = 5;
        if(victim [[ level.amislagged ]]())
        {
            percentage = ZM_RAINYDEATH_SLAG_HDMGPROC_CHANCE;
        }
        if(randomintrange(0, 100) < percentage)
        {
            foreach(ent in ArrayCombine(array::get_all_closest(victim.origin, getplayers(), undefined, undefined, 150), array::get_all_closest(victim.origin, GetAITeamArray(level.zombie_team), undefined, undefined, 150), false, false))
            {
                if(!isdefined(ent.origin) || !isalive(ent))
                {
                    continue;
                }
                if(isplayer(ent))
                {
                    if(ent.sessionstate != "playing")
                    {
                        continue;
                    }
                    if(isdefined(attacker.team) && isdefined(ent.team) && ent.team == attacker.team)
                    {
                        continue;
                    }
                }
                else
                {
                    if(isdefined(ent.animname) && ent.animname == "zombie_boss")
                    {
                        continue;
                    }
                }
                ent thread [[ function(attacker) => 
                {
                    self notify(#"hash_f4d7c94a");
                    self endon(#"hash_f4d7c94a");
                    self endon("disconnect");
                    self endon("bled_out");
                    self endon("death");
                    self.var_a1e83b0f = 1;
                    if(isplayer(self))
                    {
                        self clientfield::set("bl2_aat_shock_fx_plr", 2);
                        playsoundatposition("sfx_aat_shock_start", self.origin);
                        self dodamage(int(CLAMPED_ROUND_NUMBER * 150 * (attacker get_aat_damage_multiplier())), isdefined(attacker.origin) ? attacker.origin : self.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                        wait 2;
                        self clientfield::set("bl2_aat_shock_fx_plr", 0);
                        self.var_a1e83b0f = undefined;
                    }
                    else
                    {
                        self clientfield::set("bl2_aat_shock_fx", 2);
                        self playloopsound("sfx_aat_shock_lp");
                        self.zombie_tesla_hit = true;
                        self.ignoreall = true;
                        wait 10;
                        if(isdefined(self))
                        {
                            self.zombie_tesla_hit = undefined;
                            self.ignoreall = false;
                            self.var_a1e83b0f = undefined;
                            self clientfield::set("bl2_aat_shock_fx", 0);
                            self stoploopsound();
                            playsoundatposition("sfx_aat_shock_start", self.origin);
                        }
                    }
                }]](attacker);
            }
        }

    }, "transparent", "null");

    // radiation
    level.fn_radfx = @namespace_66316922<scripts\zm\_hv_utilities.gsc>::play_fx;
    rainy_death_reregister_aat("zm_aat_radiation", 1.0, 0.05, 0, 0, true, function(victim, death, attacker, mod, weapon) =>
    {
        if(!isdefined(victim) || !isdefined(attacker))
        {
            return;
        }

        victim endon("death");
        victim endon("bled_out");
        victim endon("disconnect");
        // level.amislagged

        if(!(isdefined(death) && death) && (!(isdefined(victim.var_a1e83b0f) && victim.var_a1e83b0f)))
        {
            victim.var_a1e83b0f = 1;
            if(isplayer(victim))
            {
                victim clientfield::set("bl2_aat_radiation_fx_plr", 1);
            }
            else
            {
                victim clientfield::set("bl2_aat_radiation_fx", 1);
            }
            
            victim playloopsound("sfx_aat_radiation_lp");
            damage = 0;
            for(i = 0; i < 5; i++)
            {
                damage = int(victim.maxhealth * (0.01 * (i + 1)) * (attacker get_aat_damage_multiplier()));
                if(damage < 100)
                {
                    damage = 100;
                }
                if(damage > 2000)
                {
                    damage = 2000;
                }
                if(isdefined(victim))
                {
                    victim dodamage(damage, isdefined(attacker.origin) ? attacker.origin : victim.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                }
                if(!isdefined(victim) || victim.health <= 0 && isdefined(attacker))
                {
                    break;
                }
                wait(1);
            }
            if(isdefined(victim))
            {
                victim.var_a1e83b0f = undefined;
                if(isplayer(victim))
                {
                    victim clientfield::set("bl2_aat_radiation_fx_plr", 0);
                }
                else
                {
                    victim clientfield::set("bl2_aat_radiation_fx", 0);
                }
                victim stoploopsound();
            }
            return;
        }
        percentage = 5;
        if(victim [[ level.amislagged ]]())
        {
            percentage = ZM_RAINYDEATH_SLAG_HDMGPROC_CHANCE;
        }
        if((randomintrange(0, 100) < percentage) && isdefined(attacker))
        {
            victim thread [[function(attacker) =>
            {
                if(isdefined(attacker.var_82863c78) && attacker.var_82863c78)
                {
                    return;
                }
                radiusdamage(self.origin + vectorscale((0, 0, 1), 24), 150, int(250 * CLAMPED_ROUND_NUMBER * (attacker get_aat_damage_multiplier())), int(250 * CLAMPED_ROUND_NUMBER * (attacker get_aat_damage_multiplier()) - 1), attacker, "MOD_EXPLOSIVE", level.weaponnone);
                playsoundatposition("sfx_aat_radiation_exp", self gettagorigin("j_spine4"));
                thread [[ level.fn_radfx ]]("fx_bl2_aat_radiation_exp", 2.5, self gettagorigin("j_spine4"));
            }]](attacker);
        }

    }, "transparent", "null");

    rainy_death_reregister_aat("zm_aat_incendiary", 1.0, 0.05, 0, 0, true, function(victim, death, attacker, mod, weapon) =>
    {
        if(!isdefined(victim) || !isdefined(attacker))
        {
            return;
        }

        victim endon("death");
        victim endon("bled_out");
        victim endon("disconnect");
        victim endon(#"hash_e3fee756");

        if(!(isdefined(victim.death) && victim.death) && (!(isdefined(victim.var_a1e83b0f) && victim.var_a1e83b0f)))
        {
            victim.var_a1e83b0f = 1;
            if(isplayer(victim))
            {
                victim clientfield::set("bl2_aat_incendiary_fx_plr", 1);
            }
            else
            {
                victim clientfield::set("bl2_aat_incendiary_fx", 1);
            }
            victim playloopsound("sfx_aat_incendiary_lp");
            for(i = 0; i < 10; i++)
            {
                damage = int(victim.maxhealth * 0.01 * (attacker get_aat_damage_multiplier()));
                if(damage < 100)
                {
                    damage = 100;
                }
                if(damage > 800)
                {
                    damage = 800;
                }
                if(isdefined(victim))
                {
                    victim dodamage(damage, isdefined(attacker.origin) ? attacker.origin : victim.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                }
                if(victim.health <= 0)
                {
                    break;
                }
                wait(0.25);
            }
            victim.var_a1e83b0f = undefined;
            if(isplayer(victim))
            {
                victim clientfield::set("bl2_aat_incendiary_fx_plr", 0);
            }
            else
            {
                victim clientfield::set("bl2_aat_incendiary_fx", 0);
            }
            victim stoploopsound();
            return;
        }
        percentage = 5;
        if(victim [[ level.amislagged ]]())
        {
            percentage = ZM_RAINYDEATH_SLAG_HDMGPROC_CHANCE;
        }
        if(randomintrange(0, 100) < percentage)
        {
            foreach(ent in ArrayCombine(array::get_all_closest(victim.origin, getplayers(), undefined, undefined, 250), array::get_all_closest(victim.origin, GetAITeamArray(level.zombie_team), undefined, undefined, 250), false, false))
            {
                if(!isdefined(ent.origin) || !isalive(ent))
                {
                    continue;
                }
                if(isplayer(ent))
                {
                    if(ent.sessionstate != "playing")
                    {
                        continue;
                    }
                    if(isdefined(attacker.team) && isdefined(ent.team) && ent.team == attacker.team)
                    {
                        continue;
                    }
                }
                else
                {
                    if(isdefined(ent.animname) && ent.animname == "zombie_boss")
                    {
                        continue;
                    }
                }
                ent thread [[ function(attacker) => 
                {
                    self notify(#"hash_e3fee756");
                    self endon(#"hash_e3fee756");
                    self endon("disconnect");
                    self endon("bled_out");
                    self endon("death");
                    self.var_a1e83b0f = 1;
                    if(isplayer(self))
                    {
                        self clientfield::set("bl2_aat_incendiary_fx_plr", 2);
                    }
                    else
                    {
                        self clientfield::set("bl2_aat_incendiary_fx", 2);
                    }
                    self playloopsound("sfx_aat_incendiary_lp");
                    for(i = 0; i < 20; i++)
                    {
                        damage = int(CLAMPED_ROUND_NUMBER * 20 * (attacker get_aat_damage_multiplier()));
                        if(isdefined(self))
                        {
                            self dodamage(damage, isdefined(attacker.origin) ? attacker.origin : self.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                        }
                        if(self.health <= 0)
                        {
                            break;
                        }
                        wait(0.15);
                    }
                    if(isdefined(self))
                    {
                        self.var_a1e83b0f = undefined;
                        if(isplayer(self))
                        {
                            self clientfield::set("bl2_aat_incendiary_fx_plr", 0);
                        }
                        else
                        {
                            self clientfield::set("bl2_aat_incendiary_fx", 0);
                        }
                        self stoploopsound();
                    }
                }]](attacker);
            }
        }

    }, "transparent", "null");

    rainy_death_reregister_aat("zm_aat_cryo", 1.0, 0.05, 0, 0, true, function(victim, death, attacker, mod, weapon) =>
    {
        if(!isdefined(victim) || !isdefined(attacker))
        {
            return;
        }

        victim endon("death");
        victim endon("bled_out");
        victim endon("disconnect");
        victim endon(#"hash_903fd6a3");

        if(!(isdefined(death) && death) && (!(isdefined(victim.var_a1e83b0f) && victim.var_a1e83b0f)))
        {
            if(isdefined(victim))
            {
                victim dodamage(int(250 * (attacker get_aat_damage_multiplier())), isdefined(attacker.origin) ? attacker.origin : victim.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
            }
            if(!isdefined(victim) || victim.health <= 0 && isdefined(attacker))
            {
                return;
            }
            victim.var_a1e83b0f = 1;
            if(isplayer(victim))
            {
                victim clientfield::set("bl2_aat_cryo_fx_plr", 1);
                victim set_move_speed_scale(0.8, true);
            }
            else
            {
                victim asmsetanimationrate(0.7);
                victim clientfield::set("bl2_aat_cryo_fx", 1);
                victim thread [[ function () => {
                    self util::waittill_either("death", "aat_cryo_resetanimrate");
                    if(isdefined(self))
                    {
                        self asmsetanimationrate(1);
                        self clientfield::set("bl2_aat_cryo_fx", 0);
                    }
                }]]();
            }
            playsoundatposition("sfx_aat_cryo_start", victim.origin);
            victim playloopsound("sfx_aat_cryo_lp");
            wait(5);
            victim notify(#"hash_4330e37a");
            victim.var_a1e83b0f = undefined;
            if(isplayer(victim))
            {
                victim clientfield::set("bl2_aat_cryo_fx_plr", 0);
                victim set_move_speed_scale();
            }
            else
            {
                victim clientfield::set("bl2_aat_cryo_fx", 0);
            }
            playsoundatposition("sfx_aat_cryo_end", victim.origin);
            victim stoploopsound();
            return;
        }
        percentage = 5;
        if(victim [[ level.amislagged ]]())
        {
            percentage = ZM_RAINYDEATH_SLAG_HDMGPROC_CHANCE;
        }
        if(randomintrange(0, 100) < percentage)
        {
            foreach(ent in ArrayCombine(array::get_all_closest(victim.origin, getplayers(), undefined, undefined, 350), array::get_all_closest(victim.origin, GetAITeamArray(level.zombie_team), undefined, undefined, 350), false, false))
            {
                if(!isdefined(ent.origin) || !isalive(ent))
                {
                    continue;
                }
                if(isplayer(ent))
                {
                    if(ent.sessionstate != "playing")
                    {
                        continue;
                    }
                    if(isdefined(attacker.team) && isdefined(ent.team) && ent.team == attacker.team)
                    {
                        continue;
                    }
                }
                else
                {
                    if(isdefined(ent.animname) && ent.animname == "zombie_boss")
                    {
                        continue;
                    }
                }
                ent thread [[ function(attacker) => 
                {
                    self endon("death");
                    self endon("bled_out");
                    self endon("disconnect");
                    if(isdefined(self))
                    {
                        self dodamage(int(50 * CLAMPED_ROUND_NUMBER * (attacker get_aat_damage_multiplier())), isdefined(attacker.origin) ? attacker.origin : self.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                    }
                    if(!isdefined(self) || self.health <= 0 && isdefined(attacker))
                    {
                        return;
                    }
                    self notify(#"hash_903fd6a3");
                    self.var_a1e83b0f = 1;
                    self notify(#"hash_4330e37a");
                    if(isplayer(self))
                    {
                        self clientfield::set("bl2_aat_cryo_fx_plr", 2);
                        self set_move_speed_scale(0.2, true);
                    }
                    else
                    {
                        self asmsetanimationrate(0.01);
                        self clientfield::set("bl2_aat_cryo_fx", 2);
                        self thread [[ function () => {
                            self util::waittill_either("death", "aat_cryo_resetanimrate");
                            if(isdefined(self))
                            {
                                self asmsetanimationrate(1);
                                self clientfield::set("bl2_aat_cryo_fx", 0);
                            }
                        }]]();
                    }
                    playsoundatposition("sfx_aat_cryo_start", self.origin);
                    self playloopsound("sfx_aat_cryo_lp");
                    wait(10);
                    if(isdefined(self))
                    {
                        self notify(#"hash_4330e37a");
                        self.var_a1e83b0f = undefined;
                        if(isplayer(self))
                        {
                            self clientfield::set("bl2_aat_cryo_fx_plr", 0);
                            self set_move_speed_scale();
                        }
                        else
                        {
                            self clientfield::set("bl2_aat_cryo_fx", 0);
                        }
                        playsoundatposition("sfx_aat_cryo_end", self.origin);
                        self stoploopsound();
                    }
                }]](attacker);
            }
        }

    }, "transparent", "null");

    #endregion

}

zm_rd_spawned()
{
    if(!isdefined(level.zm_rd_chop_players))
    {
        level.zm_rd_scythe = getweapon("melee_scythe");
        level.zm_rd_scythe_up = getweapon("melee_scythe_upgraded");
        level.zm_rd_scythe_proj = getweapon("melee_scythe_proj");
        level.zm_rd_scythe_proj_up = getweapon("melee_scythe_proj_upg");
        level.zm_rd_heroweapon = getweapon("hero_strikers_melee");
        level.zm_rd_chop_players = function(weapon, n_damage, str_mod = "MOD_MELEE") =>
        {
            view_pos = self getweaponmuzzlepoint();
            forward_view_angles = self getweaponforwarddir();
            foreach(player in getplayers())
            {
                if(!isdefined(player) || player.sessionstate != "playing" || player.team == self.team)
                {
                    continue;
                }
                test_origin = player.origin + (0, 0, 50);
                dist_sq = distancesquared(view_pos, test_origin);
                dist_to_check = 14400;
                if(dist_sq > dist_to_check)
                {
                    continue;
                }
                normal = vectornormalize(test_origin - view_pos);
                dot = vectordot(forward_view_angles, normal);
                if(dot <= 0)
                {
                    continue;
                }
                if(!player damageconetrace(view_pos, self))
                {
                    continue;
                }
                player dodamage(int(n_damage), self.origin, self, undefined, "none", str_mod, 0, weapon);
                player playlocalsound("wpn_scythe_blade_stab_plr");
	            self playlocalsound("wpn_scythe_blade_stab_plr");
            }
        };
    }

    fn_watch_scythe = function(str_event) => 
    {
        self notify(str_event + "_fn_watch_scythe");
        self endon(str_event + "_fn_watch_scythe");
        self endon("disconnect");
        self endon("bled_out");
        self endon("spawned_player");
        for(;;)
        {
            self waittill(str_event, weapon, weapon_2);
            if(!isdefined(weapon))
            {
                continue;
            }

            if(isweapon(weapon))
            {
                if(weapon == level.zm_rd_scythe || weapon == level.zm_rd_scythe_up)
                {
                    n_mod = int(weapon == level.zm_rd_scythe_up) + 1;
                    n_damage = n_mod * ZM_RAINYDEATH_SCYTHE_PER_ROUND;
                    self [[ level.zm_rd_chop_players ]](weapon, n_damage);
                    continue;
                }

                if(weapon == level.zm_rd_heroweapon)
                {
                    n_damage = ZM_RAINYDEATH_HERO_PERROUND * CLAMPED_ROUND_NUMBER;
                    self [[ level.zm_rd_chop_players ]](weapon, n_damage, "MOD_UNKNOWN");
                }
                continue;
            }

            if(str_event == "missile_fire" && isdefined(weapon_2) && (weapon_2 == level.zm_rd_scythe_proj || level.zm_rd_scythe_proj_up == weapon_2))
            {
                n_mod = int(weapon_2 == level.zm_rd_scythe_up) + 1;
                n_damage = n_mod * ZM_RAINYDEATH_SCYTHE_PER_ROUND * CLAMPED_ROUND_NUMBER;
                missile = weapon;
                wait 0.05;
                if(isdefined(missile.dmg_trig))
                {
                    missile.dmg_trig thread [[ function(attacker, n_damage, weapon) => 
                    {
                        attacker endon("disconnect");
                        self endon("death");
                        attacked = [];
                        while(isdefined(self) && isdefined(self.origin))
                        {
                            foreach(player in getplayers())
                            {
                                if(player.sessionstate != "playing" || player.team == attacker.team)
                                {
                                    continue;
                                }
                                if(isinarray(attacked, player))
                                {
                                    continue;
                                }
                                if(!self isTouching(player))
                                {
                                    continue;
                                }
                                attacked[attacked.size] = player;
                                player dodamage(int(n_damage), self.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, weapon);
                                player playlocalsound("wpn_scythe_blade_stab_plr");
                                attacker playlocalsound("wpn_scythe_blade_stab_plr");
                            }
                            wait 0.05;
                        }
                    } ]](self, n_damage, weapon_2);
                }
            }
        }
    };

    events = ["weapon_melee", "weapon_melee_power", "weapon_melee_power_left", "missile_fire"];

    foreach(evt in events)
    {
        self thread [[ fn_watch_scythe ]](evt);
    }

    self thread [[ function() => 
    {
        self endon("disconnect");
        self endon("bled_out");
        self endon("spawned_player");
        for(;;)
        {
            self.ratking_zombie_count = array::get_all_closest(self.origin, getaiteamarray(level.zombie_team), undefined, 8, 250).size;
            wait 0.75;
        }
    }]]();

    self thread [[ function() => 
    {
        self endon("disconnect");
        self endon("bled_out");
        self endon("spawned_player");
        for(;;)
        {
            self waittill("weapon_fired");
            currentweapon = self getcurrentweapon();
            if(currentweapon == level.var_8c596d66 || currentweapon == level.var_9db2f47d)
            {
                self thread zm_rd_thundergun_fired();
            }
        }
    }]]();
}

zm_rd_thundergun_fired()
{
    view_pos = self getweaponmuzzlepoint();
	zombies = array::get_all_closest(view_pos, getplayers(), undefined, undefined, level.zombie_vars["thundergun_knockdown_range"]);
	if(!isdefined(zombies))
	{
		return;
	}
	knockdown_range_squared = level.zombie_vars["thundergun_knockdown_range"] * level.zombie_vars["thundergun_knockdown_range"];
	gib_range_squared = level.zombie_vars["thundergun_gib_range"] * level.zombie_vars["thundergun_gib_range"];
	fling_range_squared = level.zombie_vars["thundergun_fling_range"] * level.zombie_vars["thundergun_fling_range"];
	cylinder_radius_squared = level.zombie_vars["thundergun_cylinder_radius"] * level.zombie_vars["thundergun_cylinder_radius"];
	forward_view_angles = self getweaponforwarddir();
	end_pos = view_pos + vectorscale(forward_view_angles, level.zombie_vars["thundergun_knockdown_range"]);
    valid_players = [];
    valid_players_fling_vecs = [];
	for(i = 0; i < zombies.size; i++)
	{
		if(!isdefined(zombies[i]) || !isalive(zombies[i]))
		{
			continue;
		}
        if(zombies[i].sessionstate != "playing")
        {
            continue;
        }
        if(zombies[i].team == self.team)
        {
            continue;
        }
		test_origin = zombies[i] getcentroid();
		test_range_squared = distancesquared(view_pos, test_origin);
		if(test_range_squared > knockdown_range_squared)
		{
			return;
		}
		normal = vectornormalize(test_origin - view_pos);
		dot = vectordot(forward_view_angles, normal);
		if(0 > dot)
		{
			continue;
		}
		radial_origin = pointonsegmentnearesttopoint(view_pos, end_pos, test_origin);
		if(distancesquared(test_origin, radial_origin) > cylinder_radius_squared)
		{
			continue;
		}
		if(0 == zombies[i] damageconetrace(view_pos, self))
		{
			continue;
		}
		if(test_range_squared < fling_range_squared)
		{
			valid_players[valid_players.size] = zombies[i];
			dist_mult = (fling_range_squared - test_range_squared) / fling_range_squared;
			fling_vec = vectornormalize(test_origin - view_pos);
			if(5000 < test_range_squared)
			{
				fling_vec = fling_vec + (vectornormalize(test_origin - radial_origin));
			}
			fling_vec = (fling_vec[0], fling_vec[1], abs(fling_vec[2]));
			fling_vec = vectorscale(fling_vec, 600 + (200 * dist_mult));
            fling_vec = (fling_vec[0], fling_vec[1], min(fling_vec[2], 300));
			valid_players_fling_vecs[valid_players_fling_vecs.size] = fling_vec;

            zombies[i] setorigin((zombies[i] getorigin()) + (0, 0, 1));
            zombies[i] setVelocity((zombies[i] getVelocity()) + fling_vec);
            zombies[i].launch_magnitude_extra = 200;
            zombies[i].v_launch_direction_extra = vectorNormalize(fling_vec);
            zombies[i].gm_thundergunned = true;
            zombies[i] dodamage(int(TG_Clamp(TGUN_BASE_DMG_PER_ROUND * 0.75 * CLAMPED_ROUND_NUMBER, zombies[i])), zombies[i].origin, self, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
            zombies[i].gm_thundergunned = false;
            zombies[i] thread [[ level.slagme ]](true);
		}
	}
}

zm_rd_killerwatt_fire(grenade, weapon)
{
    if(!isdefined(grenade) || !isweapon(weapon))
    {
        return;
    }
    grenade waittill("explode", position);
	playsoundatposition("fly_null_ai_stun_impact", position);
	var_b0feb0e2 = spawn("script_model", position);
	var_b0feb0e2 setmodel("tag_origin");
	if(weapon == getweapon("special_killerwatt_upgraded"))
	{
		var_3d03f47d = "fx_killerwatt_proj_exp_upg";
		var_b0feb0e2 clientfield::set("play_killerwatt_proj_fx", 2);
		var_70faa00c = getweapon("special_killerwatt_proj_upg");
	}
	else
	{
		var_3d03f47d = "fx_killerwatt_proj_exp";
		var_b0feb0e2 clientfield::set("play_killerwatt_proj_fx", 1);
		var_70faa00c = getweapon("special_killerwatt_proj");
	}
	wait(0.5);
	missile = [];
    affected = [];
	for(i = 0; i < 10; i++)
	{
		zombies = array::get_all_closest(position, arraycombine(getplayers(), getaispeciesarray("axis"), false, false));
		foreach(zombie in zombies)
		{
            if(!isdefined(zombie))
            {
                continue;
            }
            if(isinarray(affected, zombie))
            {
                continue;
            }
            if(isplayer(zombie))
            {
                if(zombie.sessionstate != "playing")
                {
                    continue;
                }
                if(zombie.team == self.team)
                {
                    continue;
                }
            }
			target = undefined;
			target_pos = zombie gettagorigin("j_spineupper");
			if(!isdefined(target_pos))
			{
				target_pos = zombie.origin;
			}
			if(distance(target_pos, position) <= 768 && isalive(zombie))
			{
                target = zombie;
                if((zombies.size + i) < 10 && isplayer(zombie))
                {
                    break;
                }
                affected[affected.size] = zombie;
				break;
			}
		}
		if(isdefined(target))
		{
			thread [[ level.rd_playfx ]](var_3d03f47d, 2.5, position);
			playsoundatposition("fly_null_ai_stun_impact", position);
			id = missile.size;
			if(isdefined(self))
			{
				missile[id] = magicbullet(var_70faa00c, position, target_pos, self, target);
			}
			else
			{
				missile[id] = magicbullet(var_70faa00c, position, target_pos, undefined, target);
			}
			missile[id] missile_settarget(target);
            if(isplayer(target))
            {
                target thread [[ function(attacker, i) => {
                    self endon("bled_out");
                    self endon("disconnect");
                    self notify("killerwatt_timeout" + i);
                    self endon("killerwatt_timeout" + i);
                    self thread [[ function(i) => 
                    {
                        self endon("disconnect");
                        self endon("killerwatt_timeout" + i);
                        wait 10;
                        self notify("killerwatt_timeout" + i);
                    }]](i);

                    for(;;)
                    {
                        self waittill("damage", n_damage, e_attacker, direction_vec, v_impact_point, damagetype, modelname, tagname, partname, weapon, idflags);
                        if(isweapon(weapon) && (weapon == getweapon("special_killerwatt_proj_upg") || weapon == getweapon("special_killerwatt_proj")))
                        {
                            if(!isdefined(self.last_kw_proj_time))
                            {
                                self.last_kw_proj_time = 0;
                            }
                            amage = CLAMPED_ROUND_NUMBER * ((weapon == getweapon("special_killerwatt_proj_upg")) ? 1000 : 400);
                            if(gettime() - self.last_kw_proj_time < 2000)
                            {
                                amage *= 0.2;
                            }
                            self.last_kw_proj_time = gettime();
                            self dodamage(int(amage), self.origin, e_attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                            return;
                        }
                    }
                }]](self, i);
            }
		}
		wait(0.08);
	}
	playsoundatposition("fly_null_ai_stun_impact", position);
	var_b0feb0e2 clientfield::set("play_killerwatt_proj_fx", 0);
	[[ level.rd_playfx ]](var_3d03f47d, 2.5, var_b0feb0e2.origin);
	var_b0feb0e2 delete();
}

zm_rd_tripmine_watch(mine)
{
    self endon("disconnect");
    if(!isdefined(self.var_ddfdf21b))
    {
        self.var_ddfdf21b = 0;
    }
    self.var_ddfdf21b++;
	mine waittill("stationary");
	playsoundatposition("wpn_mines_plant", mine.origin);
	mine.targetname = self.characterindex + "_m15mine";
	mine.mine_trig = spawn("trigger_radius", mine.origin, get_flags_trigger_zbr(), 100, 50);
    mine.mine_trig TriggerIgnoreTeam();
    mine.mine_trig_damage = spawn("script_model", mine.origin);
    mine.mine_trig_damage setmodel("defaultactor_0_5");
    mine.mine_trig_damage.maxhealth = 100000;
    mine.mine_trig_damage.health = 100000;
    mine.mine_trig_damage setcandamage(true);
    mine.mine_trig_damage solid();
    mine.mine_trig_damage ghost();
    mine.mine_trig_damage thread [[ function(mine) => 
    { 
        self endon("death");
        mine.mine_trig endon(#"hash_f2b6928");
        self waittill("damage");
        mine.mine_trig.mine_triggered = true;
    }]](mine);
    mine.mine_trig.damage_team = self.team;
	mine.mine_trig zm_rd_tripmine_watch_trigger(self.team);
	self.var_ddfdf21b--;
	mine.mine_trig delete();
    mine.mine_trig_damage delete();
	mine detonate();
}

zm_rd_tripmine_watch_trigger(team)
{
    self endon("death");
	self endon(#"hash_f2b6928");
	mine_triggered = 0;
	while(self.mine_triggered is not true)
	{
		zombies = arraycombine(getplayers(), getaiteamarray(level.zombie_team), false, false);
		foreach(zombie in zombies)
		{
            if(!isdefined(zombie) || !isalive(zombie))
            {
                continue;
            }
            if(isplayer(zombie))
            {
                if(zombie.team == team)
                {
                    continue;
                }
                if(zombie.sessionstate != "playing")
                {
                    continue;
                }
            }
			if(zombie istouching(self))
			{
				return;
			}
		}
		wait(0.1);
	}
}
#endregion

#region zm_powerstation
zm_powerstation_autoexec()
{
    if(tolower(getdvarstring("mapname")) == "zm_powerstation")
    {
        level.do_not_apply_rand_lighting = true;
        system::ignore("zm_commandsgui");
        compiler::erasefunc("scripts/sphynx/craftables/_zm_craft_zombie_shield.gsc", 0xbeb7b12, 0x86ea997);
        compiler::erasefunc("scripts/zm/_zm_nonspecific_ee.gsc", 0x698fb9b, 0xF261EBFC);
        compiler::erasefunc("scripts/zm/overload_ee.gsc", 0x195647e, 0x7ABC628F);
        
        foreach(s_button in struct::get_array("pap_button", "targetname"))
        {
            s_button struct::delete();
        }

        getent("level_inducer", "targetname").origin = ORIGIN_OOB;

        callback::on_spawned(function() => 
        {
            self endon("disconnect");
            self endon("bled_out");
            var_4e7bbc60 = level.var_ca72b110.name;
            str_notify = var_4e7bbc60 + "_pickup_from_table";
            for(;;)
            {
                self waittill(str_notify);
                if(isdefined(self.var_1fb415a2) && self.var_1fb415a2)
                {
                    self zm_equipment::buy("spx_zombie_shield_upgraded");
                }
            }
        });
    }
}

zm_powerstation_init()
{
    compiler::erasefunc("scripts/zm/overload_ee.gsc", 0x195647e, 0xbd0f3d0a);

    compiler::script_detour("scripts/zm/_zm_t8_za.gsc", 0xb02b3342, 0xBFCC6CEE, function() =>
    {
        return (self zm_utility::get_current_zone(1)) ?? "none";
    });

    level.var_dab4c271 = 999; // infinite explosives

    level.initial_round_wait_func = function() => {};
    level flag::set("cabin1_to_spawn");

    // kill their custom hitmarkers
    arrayremovevalue(level.zombie_damage_callbacks, @namespace_74571cc1<scripts\__robit\hitmarkers.gsc>::function_9c301f1a, false);
    zm_spawner::deregister_zombie_death_event_callback(@namespace_74571cc1<scripts\__robit\hitmarkers.gsc>::function_5adbafc9);

    level.var_a78effc7 = 999; //fix stalingrad hang
    
    // disable drones
    level._achievement_monitor_func = level.achievement_monitor_func;
    level.achievement_monitor_func = serious::kill_sentinels;

    // level flag::set("power_on");

    // util::wait_network_frame();
	// util::clientnotify("ZPO");
    // util::wait_network_frame();
    // exploder::exploder("master_switch_lgts");

    fix_perk_banana_colada();

    compiler::script_detour("scripts/zm/_zm_airstrike_trap.gsc", 0x2ba47bda, 0x68c2288b, function(player, ground) =>
    {
        playfxontag("smoke/fx_smk_white_md_geotrail", self, "tag_origin");
        wait(0.05);
        self playsound("wpn_rocket_loop_whine");
        wait(2.85);
        playfx("explosions/fx_exp_generic_aerial_lg", self.origin);
        playsoundatposition("exp_dart_rocket", self.origin);
        earthquake(0.35, 7, self.origin, 450);
        ai = getaispeciesarray(level.zombie_team, "all");
        for(i = 0; i < ai.size; i++)
        {
            var_ef46ce20 = distancesquared(ai[i].origin, self.origin);
            if(var_ef46ce20 < 202500)
            {
                ai[i] dodamage(ai[i].health + 666, ai[i].origin, player);
            }
        }
        players = getplayers();
        for(i = 0; i < players.size; i++)
        {
            if(players[i].sessionstate != "playing")
            {
                continue;
            }
            if(players[i].team == player.team)
            {
                continue;
            }
            dist_to_player = distancesquared(players[i].origin, self.origin);
            if(dist_to_player < 202500)
            {
                if(players[i] hasperk("specialty_armorvest"))
                {
                    players[i] dodamage(int(CLAMPED_ROUND_NUMBER * 300), players[i].origin, player, undefined, "none", "MOD_EXPLOSIVE", 0, level.weaponnone);
                    continue;
                }
                players[i] dodamage(players[i].health + 666, players[i].origin, player, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
            }
        }
        self delete();
    });
}

#define POWER_AID_EXPLOSIVE_BONUS = 1.35;
#define POWER_AID_BULLET_BONUS = 1.1;
zm_powerstation_weapons()
{
    remove_box_weapon("ray_gun");
    remove_box_weapon("raygun_mark2");
    zm_powerstation_roundnext();

    // power aid perk bonus damage for explosives and bullets (tuned down for pvp because doubletap exists)
    level.fn_zbr_postdamage_scale = function(eInflictor, attacker, result, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime) =>
    {
        if(!isdefined(attacker))
        {
            return result;
        }
        
        if(attacker hasperk("specialty_tracker"))
        {
            is_explosive = (smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" || smeansofdeath == "MOD_EXPLOSIVE");
            if(is_explosive)
            {
                return int(POWER_AID_EXPLOSIVE_BONUS * result);
            }
            if(sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET")
            {
                return int(POWER_AID_BULLET_BONUS * result);
            }
        }
        return result;
    };

    // potential incindiary targets
    compiler::script_detour("scripts/zm/_incendiary.gsc", 0xFCB56D9F, 0xDD24519F, function(owner) =>
    {
        all_targets = [];
        all_targets = arraycombine(all_targets, level.players, 0, 0);
        all_targets = arraycombine(all_targets, getaiarray(), 0, 0);
        all_targets = arraycombine(all_targets, getvehiclearray(), 0, 0);
        potential_targets = [];
        foreach(target in all_targets)
        {
            if(!isdefined(target))
            {
                continue;
            }
            if(isdefined(owner?.team) && isdefined(target.team))
            {
                if(owner.team == target.team)
                {
                    continue;
                }
            }
            else
            {
                continue;
            }
            if(isplayer(target) && target.sessionstate != "playing")
            {
                continue;
            }
            potential_targets[potential_targets.size] = target;
        }
        return potential_targets;
    });

    level.get_spas_zombies = @namespace_2318571c<scripts\zm\_zm_weap_spas.gsc>::function_d16d83e9;
    level.spas_zombie_effect = @namespace_2318571c<scripts\zm\_zm_weap_spas.gsc>::function_5c8cc76a;
    compiler::script_detour("scripts/zm/_zm_weap_spas.gsc", 0x2318571c, 0x45322a5a, function(struct) =>
    {
        self endon("death");
        struct.owner endon("disconnect");
        struct.owner endon("bled_out");
        self endon(#"hash_44952436");
        weapon = level.var_f46c3401["shotgun_spas12_gb_tuningf_upgraded"];
        excluders = [struct.owner];
        foreach(player in getplayers())
        {
            if(player.team == struct.owner.team)
            {
                excluders[excluders.size] = player;
            }
        }
        for(;;)
        {
            wait(randomintrange(1, 3));
            zombies = [[ level.get_spas_zombies ]](self, 256);
            zombies = arraycombine(zombies, array::get_all_closest(self.origin, getplayers(), excluders, undefined, 256), false, false);
            if(!isdefined(zombies) || zombies.size <= 0)
            {
                continue;
            }
            foreach(zombie in zombies)
            {
                if(!isdefined(zombie) || !isalive(zombie) || (isplayer(zombie) && zombie.sessionstate != "playing"))
                {
                    continue;
                }
                if(!isplayer(zombie))
                {
                    zombie.var_23248ae9 = 1;
                    zombie clientfield::set("spas_beam", 1);
                    wait(randomfloatrange(0.2, 0.3));
                    if(!isdefined(zombie) || !isalive(zombie))
                    {
                        continue;
                    }
                    zombie clientfield::set("spas_beam", 0);
                    zombie dodamage(zombie.health + 1337, struct.owner.origin, struct.owner, weapon, "none", "MOD_PISTOL_BULLET", 0, weapon);
                }
                else
                {
                    excluders[excluders.size] = zombie;
                    zombie dodamage(int(CLAMPED_ROUND_NUMBER * 500), struct.owner.origin, struct.owner, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                }
            }
        }
    });

    compiler::script_detour("scripts/zm/_zm_weap_spas.gsc", 0x2318571c, 0x89b9fb00, function(upgraded, weapon, attacker) =>
    {
        if(!isdefined(attacker))
        {
            return;
        }
        zombies = [[ level.get_spas_zombies ]](self, 124, vectorscale((0, 0, 1), 16));
        excluders = [attacker];
        foreach(player in getplayers())
        {
            if(player.team == attacker.team)
            {
                excluders[excluders.size] = player;
            }
        }
        zombies = arraycombine(zombies, array::get_all_closest(self.origin, getplayers(), excluders, undefined, 256), false, false);
        if(!isdefined(zombies) || zombies.size <= 0)
        {
            return;
        }
        self clientfield::increment(isdefined(upgraded) && (upgraded ? "spas_lightning_upgraded" : "spas_lightning"));
        self playsound("wpn_shotgun_spas12_exp_lightning");
        earthquake(0.4, 0.75, self.origin, 744);
        foreach(zombie in zombies)
        {
            if(isplayer(zombie))
            {
                zombie dodamage(int(CLAMPED_ROUND_NUMBER * 250), attacker.origin, attacker, undefined, "none", "MOD_PROJECTILE_SPLASH", 0, weapon);
            }
            else
            {
                zombie dodamage(int(upgraded ? (1500 + (zombie.maxhealth / 5)) : (500 + (zombie.maxhealth / 10))), attacker.origin, attacker, weapon, "none", "MOD_PROJECTILE_SPLASH", 0, weapon);
                zombie thread [[ level.spas_zombie_effect ]](upgraded);
            }
            
        }
    });

    // its another bo4 weapon meta map :sad:
    // design: per weapon. Everything should target roughly 50K dps.

    level.balance_adjust_easy_scalar = 1;
    
    register_weapon_scalar("shotgun_spas12_gb_tuningf", "shotgun_spas12_gb_tuningf_upgraded", 1.17);
    register_weapon_scalar("shotgun_spas12_gb_tuningf_upgraded1", "shotgun_spas12_gb_tuningf_upgraded2", 0.875);

    level.balance_adjust_easy_scalar = 0.3;
    register_weapon_scalar("t8_welling_up", undefined, 0.02);
    register_weapon_scalar("t8_vendetta", "t8_vendetta_up", 0.13);
    register_weapon_scalar("t8_switchblade_x9", "t8_switchblade_x9_up", 2.76);
    register_weapon_scalar("t8_swat_rft", "t8_swat_rft_up", 1.0);
    register_weapon_scalar("t8_rampage", "t8_rampage_up", 0.16);
    register_weapon_scalar("t8_kap45", "t8_kap45_up", 1.66);
    register_weapon_scalar("t8_grav", "t8_grav_up", 1.86);
    register_weapon_scalar("t8_daemon3xb", "t8_daemon3xb_up", 1.55);
    register_weapon_scalar("t8_vkm750", "t8_vkm750_up", 2);
    register_weapon_scalar("t8_vapr_xkg", "t8_vapr_xkg_up", 1.48);
    register_weapon_scalar("t8_titan", "t8_titan_up", 1.85);
    register_weapon_scalar("t8_swordfish", "t8_swordfish_up", 0.82);
    register_weapon_scalar("t8_strife", "t8_strife_up", 0.82);
    register_weapon_scalar("t8_spitfire", "t8_spitfire_up", 3);
    register_weapon_scalar("t8_sg12", "t8_sg12_up", 0.2);
    register_weapon_scalar("t8_sdm", "t8_sdm_up", 0.09);
    register_weapon_scalar("t8_saug9mm", "t8_saug9mm_up", 3.55);
    register_weapon_scalar("t8_rk7", "t8_rk7_up", 1.74);
    register_weapon_scalar("t8_rampart17", "t8_rampart17_up", 2);
    register_weapon_scalar("t8_paladin_hb50", "t8_paladin_hb50_up", 1.7);
    register_weapon_scalar("t8_outlaw", "t8_outlaw_up", 1.75);
    register_weapon_scalar("t8_mx9", "t8_mx9_up", 2.15);
    register_weapon_scalar("t8_mozu", "t8_mozu_up", 0.16);
    register_weapon_scalar("t8_mog12", "t8_mog12_up", 1.7);
    register_weapon_scalar("t8_maddox_rfb", "t8_maddox_rfb_up", 2.81);
    register_weapon_scalar("t8_m1927", "t8_m1927_up", 3.58);
    register_weapon_scalar("t8_m1897", "t8_m1897_up", 1.81);
    register_weapon_scalar("t8_koshka", "t8_koshka_up", 3.58);
    register_weapon_scalar("t8_kn57", "t8_kn57_up", 2.3);
    register_weapon_scalar("t8_icr7", "t8_icr7_up", 3);
    register_weapon_scalar("t8_hitchcock_m9", "t8_hitchcock_m9_up", 2.63);
    register_weapon_scalar("t8_hellion_salvo", "t8_hellion_salvo_up", 1 / level.balance_adjust_easy_scalar);
    register_weapon_scalar("t8_hades", "t8_hades_up", 3.3);
    register_weapon_scalar("t8_gks", "t8_gks_up", 4.24);
    register_weapon_scalar("t8_zweihander", "t8_zweihander_up", 0.79);
    register_weapon_scalar("t8_essex_m07", "t8_essex_m07_up", 1.73);
    register_weapon_scalar("t8_escargot", "t8_escargot_up", 0.69);
    register_weapon_scalar("t8_cordite", "t8_cordite_up", 1.8);
    register_weapon_scalar("t8_auger_dmr", "t8_auger_dmr_up", 0.41);
    register_weapon_scalar("t8_abr223", "t8_abr223_up", 1.44);

    level.balance_adjust_easy_scalar = 1.0;
    register_weapon_postcalc("t8_hellion_salvo_up", true);
    register_weapon_postcalc("t8_hellion_salvo", true);

    register_box_weapon("shotgun_spas12_gb_tuningf", "shotgun_spas12_gb_tuningf_upgraded");
}

zm_powerstation_roundnext()
{
    level.incendiaryfiredamage = int(CLAMPED_ROUND_NUMBER * 750 / 3);
    level.incendiaryfiredamageticktime = 0.25;
}

zm_powerstation_threaded()
{
    wait 3;
    level notify(#"hash_27731f5f");
    util::wait_network_frame();
    level flag::set("lower_to_pap");
    level flag::set("pap_rock_exploded");
	trigs = getentarray(struct::get("pap_trig").target, "targetname");
    getent("pap_dynamite_01", "targetname") delete();
    getent("pap_debris_clip_01", "targetname") delete();
    foreach(trig in trigs)
    {
        trig delete();
    }
    rubble = getent("pap_rubble", "targetname");
	rubble delete();
    struct::get("pap_trig") zm_unitrigger::unregister_unitrigger(struct::get("pap_trig").s_unitrigger);

    // teleporters
    foreach(trig in getentarray("mines_power_switch", "targetname"))
    {
        wait 0.05;
        level notify(#"hash_647bdb34");
    }
    level flag::set("boot_up_telepads");
	level flag::set("teleporter_active");

    // boards
    foreach(clip in getentarray("breakable_barricade_clip", "targetname"))
    {
        boards = getentarray(clip.target, "targetname");
        foreach(board in boards)
        {
            board notify("damage", 1000, undefined, (0,0,0), (0,0,0), undefined, undefined, undefined, undefined, isdefined(board.script_noteworthy) ? getweapon(board.script_noteworthy) : level.weaponnone);
        }
    }
}
#endregion

#region zm_coast

autoexec zm_coast_autoexec()
{
    if(tolower(getdvarstring("mapname")) == "zm_coast")
    {
        // destroy george for ZBR
        compiler::erasefunc("scripts/planet/ai/pl_ai_george.gsc", 0x8d9370f3, 0x7490d21f);
        compiler::erasefunc("scripts/planet/ai/pl_ai_george.gsc", 0x8d9370f3, 0xdb2d746b);
        compiler::erasefunc("scripts/planet/ai/pl_ai_george.gsc", 0x8d9370f3, 0xb4619296);
        compiler::erasefunc("scripts/planet/ai/pl_ai_george.gsc", 0x8d9370f3, 0xa4250e34);

        // undo vr11 humangun effect
        compiler::erasefunc("scripts/planet/weapons/_zm_weap_humangun.gsc", 0xf5522c15, 0x46D6518A);

        compiler::script_detour("scripts/planet/weapons/_zm_weap_humangun.gsc", #namespace_f5522c15, #function_7b9c2f49, function(origin, angles, player, upgraded) =>
        {
            level endon(#end_game);
            if(level._zombie_human_array.size >= 2)
            {
                player thread [[ @namespace_f5522c15<scripts\planet\weapons\_zm_weap_humangun.gsc>::function_e5c150f2 ]](origin + vectorscale((0, 0, 1), 12), upgraded);
                return;
            }
            actor = zombie_utility::spawn_zombie(level.var_4c9c7081[0]);
            wait(0.05);
            if(!isdefined(actor))
            {
                return;
            }
            level._zombie_human_array[level._zombie_human_array.size] = actor;
            actor ghost();
            actor.team = "allies";
            actor.aiteam = "allies";
            actor.airank = undefined;
            actor.name = undefined;
            actor.activatecrosshair = 0;
            actor pushactors(0);
            actor.has_legs = 1;
            actor.missinglegs = 0;
            actor allowedstances("stand");
            actor.gibbed = 1;
            actor.maxhealth = 999999;
            actor.health = 999999;
            anim_rate = randomfloatrange(0.92, 0.95);
            if(upgraded)
            {
                anim_rate = randomfloatrange(0.92, 0.95);
            }
            actor asmsetanimationrate(anim_rate);
            if(isdefined(player))
            {
                actor.owner = player;
                player thread [[ function(decoy) =>
                {
                    self endon(#death);
                    self endon(#bled_out);
                    level endon(#end_game);
                    decoy endon(#"hash_7eb5d9b7");
                    decoy endon(#death);
                    self endon(#disconnect);
                    for(;;)
                    {
                        wait(1);
                        self zm_score::player_add_points("damage");
                    }
                } ]](actor);
            }
            var_80c61bcf = 1;
            if(upgraded)
            {
                var_80c61bcf = 2;
            }
            actor thread [[ @namespace_f5522c15<scripts\planet\weapons\_zm_weap_humangun.gsc>::function_94a40bf9 ]](var_80c61bcf);
            if(isdefined(level._func_humangun_check))
            {
                actor [[level._func_humangun_check]]();
            }
            actor dontinterpolate();
            actor forceteleport(origin, angles);
            actor show();
            actor playsound("zmb_humangun_prj_oneshot");
            actor playloopsound("zmb_humangun_effect_loop", 0.75);
            actor thread [[ function() =>
            {
                level endon(#end_game);
                self waittill(#death);
                if(!isdefined(self))
                {
                    return;
                }
                self stoploopsound(0.5);
            } ]]();
            actor thread [[ function() =>
            {
                self endon(#death);
                self endon(#"hash_7eb5d9b7");
                variant = undefined;
                var_85388f53 = undefined;
                wait(0.5);
                for(;;)
                {
                    variant = randomintrange(0, 8);
                    if(isdefined(var_85388f53) && variant == var_85388f53)
                    {
                        wait(0.05);
                        continue;
                    }
                    self playsoundwithnotify("vox_zmb_human_scream_" + variant, "screaming_done");
                    var_85388f53 = variant;
                    self waittill(#"hash_aed87105");
                    wait(6);
                }
            } ]]();
            wait(1.2);

            if(isdefined(actor))
            {
                var_14386caa = struct::get_array("humangun_goal", "targetname");
                goal = arraygetclosest(actor.origin, var_14386caa);
                actor setgoalpos(goal.origin);
                if(isdefined(level._humangun_escape_override) && level._humangun_escape_override == 1)
                {
                    arrayremovevalue(level._zombie_human_array, actor);
                    level notify(#"hash_b9099869", actor);
                    return;
                }
                actor thread [[ function(origin, angles) =>
                {
                    playsoundatposition("zmb_zombie_head_gib", origin);
                    fx = playfx("blood/fx_blood_impact_exp_body_lg_zmb", origin, anglestoforward(angles), anglestoup(angles), 0);
                    wait(5);
                    if(isdefined(fx))
                    {
                        fx delete();
                    }
                }]](origin, angles);
                actor thread [[ @namespace_f5522c15<scripts\planet\weapons\_zm_weap_humangun.gsc>::function_496b2577 ]](upgraded);
            }            
        });

        compiler::script_detour("scripts/planet/weapons/_zm_weap_humangun.gsc", #namespace_f5522c15, #function_13188a60, function(max_attract_dist, num_attractors) =>
        {
            level endon(#end_game);
            self endon(#death);
            self endon(#"hash_7eb5d9b7");
            for(;;)
            {
                self zm_utility::create_zombie_point_of_interest(max_attract_dist, num_attractors, 10000);
                wait(0.5);
            }
        });

        compiler::script_detour("scripts/planet/weapons/_zm_weap_humangun.gsc", #namespace_f5522c15, #function_a809512f, function() =>
        {
            self endon(#death);
            self endon(#"hash_7eb5d9b7");
            owner = self.owner;
            for(;;)
            {
                self waittill(#damage, amount, attacker, direction_vec, point, type, tagname, modelname, partname, weapon);
                owner = attacker;
                if(weapon is defined && (level.var_c144e7fd is defined) && (weapon == level.var_c144e7fd))
                {
                    break;
                }
            }
            self.var_74ed856b = 1;
        });

        level.zbr_pulse_damage = @namespace_f5522c15<scripts\planet\weapons\_zm_weap_humangun.gsc>::pulse_damage;
        compiler::script_detour("scripts/planet/weapons/_zm_weap_humangun.gsc", #namespace_f5522c15, #pulse_damage, function(e_owner) =>
        {
            self endon(#death);
            self [[ level.zbr_pulse_damage ]](e_owner);
        });

        level.function_499508c9 = @namespace_f5522c15<scripts\planet\weapons\_zm_weap_humangun.gsc>::function_499508c9;
        compiler::script_detour("scripts/planet/weapons/_zm_weap_humangun.gsc", #namespace_f5522c15, #function_499508c9, function(upgraded) =>
        {
            self endon(#death);
            self [[ level.function_499508c9 ]](upgraded);
        });

        compiler::script_detour("scripts/zm/_zm_lighthouse_mechanics.gsc", #namespace_f922fc5, #function_21b752b1, function() =>
        {
            level endon(#game_ended);
            level waittill(#power_on);
            wait(0.05);
            exploder::exploder("lighthouse_light");
            light_start_point = struct::get("pack_light", "targetname");
            var_ffbb8ec7 = struct::get("lightning_struct", "targetname");
            var_fdd037e3 = struct::get_array("lightning_vista", "targetname");
            burst_fx = util::spawn_model("tag_origin", light_start_point.origin);
            fx = playfxontag("_copforthat/zm_coast_lighthouse/fx_zmb_coast_spotlight_burst", burst_fx, "tag_origin");
            wait(2.5);
            burst_fx delete();
            if(isdefined(fx))
            {
                fx delete();
            }
            lighthouse_light = @namespace_f922fc5<scripts\zm\_zm_lighthouse_mechanics.gsc>::lighthouse_light;
            lightning_flash = @namespace_f922fc5<scripts\zm\_zm_lighthouse_mechanics.gsc>::lightning_flash;
            function_c9205cf1 = @namespace_f922fc5<scripts\zm\_zm_lighthouse_mechanics.gsc>::function_c9205cf1;
            for(;;)
            {
                lighthouse_fx_model = util::spawn_model("tag_origin", light_start_point.origin);
                lighthouse_fx_model clientfield::set("lighthouse_idle", 1);
                lighthouse_fx_model thread [[ lighthouse_light ]]();
                level notify(#"hash_98b2ba56");
                wait(5);
                level notify(#"hash_e2774185");
                level thread [[ lightning_flash ]](var_ffbb8ec7, var_fdd037e3);
                playsoundatposition("zmb_pap_lightning_1", (0, 0, 0));
                wait(3);
                level notify(#"hash_81f620c");
                level thread [[ function_c9205cf1 ]]();
                wait(0.05);
                if(isdefined(level.var_435b9c7b) && level.var_435b9c7b == 1)
                {
                    lighthouse_fx_model movez(130, 0.2);
                    lighthouse_fx_model rotateto((53.306, 234.82, -4.998), 3);
                }
                if(isdefined(level.var_435b9c7b) && level.var_435b9c7b == 2)
                {
                    lighthouse_fx_model movez(130, 0.2);
                    lighthouse_fx_model rotateto((51.04, 98.857, -5.744), 3);
                }
                if(isdefined(level.var_435b9c7b) && level.var_435b9c7b == 3)
                {
                    lighthouse_fx_model rotateto((31.12, 297.867, 7.806), 3);
                }
                level thread [[ lightning_flash ]](var_ffbb8ec7, var_fdd037e3);
                playsoundatposition("zmb_pap_lightning_2", (0, 0, 0));
                wait(5 * 60);
                level flag::wait_till_clear("pack_machine_in_use");
                level notify(#pap_moving);
                lighthouse_fx_model delete();
                wait(0.05);
            }
        });

        compiler::script_detour("scripts/zm/_zm_coast_env.gsc", #namespace_b357bd11, #function_5b43d00c, function() =>
        {
            level util::set_lighting_state(0);
            level flag::wait_till("initial_blackscreen_passed");
            level.var_b74c8bc6 = 0;
            util::clientnotify("fog_blackscreen_passed");
            var_3a6b0fe4 = struct::get_array("blizzard_struct", "targetname");
            foreach(struct in var_3a6b0fe4)
            {
                struct thread [[ function() => 
                {
                    for(;;)
                    {
                        level waittill(#"hash_a6412bad");
                        var_c609021d = util::spawn_model("tag_origin", self.origin, self.angles);
                        var_c609021d playloopsound("amb_wind");
                        level waittill(#"hash_9fdc953");
                        var_c609021d delete();
                        wait(5);
                    }
                }]]();
            }
            players = getplayers();
            wait(3);
            util::clientnotify("fog_reveal");
            wait(4);
            util::clientnotify("beginfog");
            level notify(#"hash_a6412bad");
            level.var_b74c8bc6 = 1;
            wait 5; 
            util::clientnotify("clearfog");
            level.var_b74c8bc6 = 0;
            level notify(#"hash_9fdc953");
        });
    }
}

zm_coast_init()
{
    // // remove all the slowdown triggers in the water
    // foreach(ent in getentarray("slowdown_trigger", "targetname"))
    // {
    //     ent.origin = ORIGIN_OOB;
    // }
}

zm_coast_weapons()
{
    claymore_override(false);

    level.claymore_explode_sfx = "claymore_explode";
    level.claymore_alert_sfx = "claymore_alert";
    level.claymore_fx_explode = level._effect["explosion"];
    
    register_weapon_postcalc("scavenger", true);
    register_weapon_postcalc("scavenger_up", true);

    register_weapon_calculator("scavenger", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(CLAMPED_ROUND_NUMBER * 2000);
    });

    register_weapon_calculator("scavenger_up", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(CLAMPED_ROUND_NUMBER * 4000);
    });

    register_weapon_calculator("sticky_grenade", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        if(sMeansOfDeath == "MOD_IMPACT")
        {
            return int(CLAMPED_ROUND_NUMBER * 1000);
        }
        return int(350 * CLAMPED_ROUND_NUMBER);
    });

    level.zbr_zombie_grenades ??= [];
    level.zbr_zombie_grenades[level.zbr_zombie_grenades.size] = "sticky_grenade";

    // register_weapon_scalar("t5_stakeout", "t5_stakeout_up", 2.5);
    // register_weapon_scalar("t5_spectre", "t5_spectre_up", 0.8);
    // register_weapon_scalar("t5_spas12", "t5_spas12_up", 0.8);
    // register_weapon_scalar("t5_rpk", "t5_rpk_up", 0.5);
    // register_weapon_scalar("t5_python", "t5_python_up", 2.0);
    // register_weapon_scalar("t5_olympia", "t5_olympia_up", 2.0, 0.78 * 1.5);
    set_level_olympia("t5_olympia", "t5_olympia_up");
    // register_weapon_scalar("t5_mpl", "t5_mpl_up", 2.5);
    // register_weapon_scalar("t5_mp40", "t5_mp40_up", 2.5);
    // register_weapon_scalar("t5_mp5k", "t5_mp5k_up", 2.5);
    // register_weapon_scalar("t5_m16a1", "t5_m16a1_up", 0.8);
    // register_weapon_scalar("t5_m14", "t5_m14_up", 1.0);
    // register_weapon_scalar("t5_hs10_ldw", "t5_hs10_ldw_up", 0.6);
    // register_weapon_scalar("t5_hs10_rdw", "t5_hs10_rdw_up", 0.6);
    // register_weapon_scalar("t5_g11", "t5_g11_up", 0.8);
    // register_weapon_scalar("t5_fal", "t5_fal_up", 0.7);
    // register_weapon_scalar("t5_famas", "t5_famas_up", 1.6);
    // register_weapon_scalar("t5_dragunov", "t5_dragunov_up", 1.5);
    // register_weapon_scalar("t5_commando", "t5_commando_up", 1.8);
    // register_weapon_scalar("t5_aug", "t5_aug_up", 1.8);
    // register_weapon_scalar("t5_ak74u", "t5_ak74u_up", 2.5);
    // register_weapon_scalar("t5_ak47", "t5_ak47_up", 1.5);

    level.zbr_cb_zombie_hit = function(eInflictor, attacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime) =>
    {
        if(!isdefined(attacker) || (attacker.cant_afflict_vr11 is true))
        {
            return;
        }
        if(self.zbr_vr11 is true)
        {
            attacker.cant_afflict_vr11 = true;
            self playsound("zmb_humangun_prj_oneshot");
            RadiusDamage(self GetOrigin(), 250, int(CLAMPED_ROUND_NUMBER * 1500 / 2), int(CLAMPED_ROUND_NUMBER * 750 / 2), self.zbr_vr11_player, "MOD_EXPLOSIVE", weapon);
            self playsound("zmb_ignite");
            fx = playfx(level._effect["humangun_explosion_upg"], self GetOrigin(), anglestoforward(self getplayerangles()), anglestoup(self getplayerangles()), 0);
            wait(5);
            if(isdefined(fx))
            {
                fx delete();
            }
        }
    };

    register_weapon_damage_callback("humangun", "humangun_up", function(eInflictor, attacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime) => 
    {
        self endon(#disconnect);
        self endon(#bled_out);
        self notify(#humangun);
        self playsound("zmb_humangun_prj_oneshot");
        self playloopsound("zmb_humangun_effect_loop", 0.75);
        self.zbr_vr11 = true;
        self.zbr_vr11_time = 20;
        self.b_is_designated_target = 1;

        if(isplayer(attacker))
        {
            self.zbr_vr11_player = attacker;
        }

        foreach(ai in getaiteamarray(level.zombie_team))
        {
            if(ai.completed_emerging_into_playable_area is not true)
            {
                continue;
            }
            ai zombie_utility::set_zombie_run_cycle_override_value("super_sprint");
        }

        if(self istestclient())
        {
            self.ignoreme = false;
        }

        self thread [[ function() => 
        {
            fx = playfx(level._effect["humangun_explosion_upg"], self GetOrigin(), anglestoforward(self getplayerangles()), anglestoup(self getplayerangles()), 0);
            wait(5);
            if(isdefined(fx))
            {
                fx delete();
            }
        } ]]();

        self thread [[ function() =>
        {
            self endon(#bled_out);
            self endon(#disconnect);
            self notify(#humangunsound);
            self endon(#humangunsound);
            variant = undefined;
            var_85388f53 = undefined;
            wait(0.5);
            for(;;)
            {
                variant = randomintrange(0, 8);
                if(isdefined(var_85388f53) && variant == var_85388f53)
                {
                    wait(0.05);
                    continue;
                }
                self playsoundwithnotify("vox_zmb_human_scream_" + variant, "screaming_done");
                var_85388f53 = variant;
                self waittill(#"hash_aed87105");
                wait(6);
            }
        }]]();
        
        self notify(#humangun);
        self endon(#humangun);

        visionset_mgr::deactivate("visionset", "zm_bgb_now_you_see_me", self);
        visionset_mgr::deactivate("overlay", "zm_bgb_now_you_see_me", self);

        wait 0.1;

        visionset_mgr::activate("visionset", "zm_bgb_now_you_see_me", self, 0.5, 9, 0.5);
	    visionset_mgr::activate("overlay", "zm_bgb_now_you_see_me", self);
        
        while(self.zbr_vr11_time is defined and self.zbr_vr11_time > 0)
        {
            self.zbr_vr11_time -= 2;
            playfxontag("_custom/weapon/fx_muz_samantha_box_explosion", self, "tag_origin");
		    playsoundatposition("zmb_electrocute_zombie", self getorigin());
            wait 2;
        }

        visionset_mgr::deactivate("visionset", "zm_bgb_now_you_see_me", self);
        visionset_mgr::deactivate("overlay", "zm_bgb_now_you_see_me", self);

        self.zbr_vr11 = false;
        self.b_is_designated_target = false;
        self stoploopsound(0.5);
        self notify(#humangunsound);

        foreach(player in getplayers())
        {
            if(player.zbr_vr11 is true && player.sessionstate == "playing")
            {
                return;
            }
        }

        foreach(ai in getaiteamarray(level.zombie_team))
        {
            if(ai.completed_emerging_into_playable_area is not true)
            {
                continue;
            }
            ai zombie_utility::set_zombie_run_cycle_restore_from_override();
        }
    });
}
#endregion

#region zm_irondragon
autoexec zm_irondragon_auto()
{
    if(tolower(getdvarstring("mapname")) != "zm_irondragon")
    {
        return;
    }

    level.zbr_max_ai_override = 48; // adjusted because of g_spawn issues
    
    compiler::fix_endon_death("scripts/zm/_zm_weap_elemental_bow.gsc", 0x790026D5, 0x59d385a8, 0x100, #disconnect);
	compiler::fix_endon_death("scripts/zm/_zm_weap_elemental_bow.gsc", 0x790026D5, 0x1160e0e9, 0x100, #disconnect);
	compiler::fix_endon_death("scripts/zm/_zm_weap_elemental_bow.gsc", 0x790026D5, 0xa991479f, 0x100, #disconnect);

    system::ignore("hb21_zm_hitmarkers");

    compiler::script_detour("scripts/zm/zm_irondragon.gsc", #namespace_da78430a, #intro_credits, function() => {});
    compiler::script_detour("scripts/zm/zm_irondragon.gsc", #namespace_da78430a, #function_39228c10, function() => {});

    compiler::script_detour("scripts/sphynx/craftables/_zm_craft_origins_shield.gsc", #namespace_76f0519f, #function_f2c8a0b2, function() => 
    {
        self endon(#disconnect);
        self endon(#bled_out);
        var_4e7bbc60 = level.var_d348c661.name;
        str_notify = var_4e7bbc60 + "_pickup_from_table";
        for(;;)
        {
            self waittill(str_notify);
            if(isdefined(self.var_40898dd1) && self.var_40898dd1)
            {
                self zm_equipment::buy("spx_origins_shield_upgraded");
            }
        }
    });

    level.ebg_damage = @electroball_grenade<scripts\zm\_electroball_grenade.gsc>::function_f5b08d03;
    compiler::script_detour("scripts/zm/_electroball_grenade.gsc", #electroball_grenade, #function_f5b08d03, function() => {
        self endon(#bled_out);
        self [[ level.ebg_damage ]]();
    });

    level.vulture_aid_monitor = @namespace_d7595b00<scripts\zm\_zm_perk_vulture_aid.gsc>::function_e46e25dc;
    compiler::script_detour("scripts/zm/_zm_perk_vulture_aid.gsc", #namespace_d7595b00, #function_e46e25dc, function() => {
        self endon(#bled_out);
        self [[ level.vulture_aid_monitor ]]();
    });
}
zm_irondragon_init()
{
    compiler::script_detour("scripts/zm/_hb21_sym_zm_trap_acid.gsc", 0x43042162, 0x1c29044e, function(n_damage, e_trap) =>
    {
        self notify(#"hash_1c29044e");
        self endon(#"hash_1c29044e");
        self endon("bled_out");
        self endon("spawned_player");
        self endon("disconnect");

        if(self hasperk("specialty_armorvest"))
        {
            self dodamage(50, self.origin, e_trap.activated_by_player, e_trap.activated_by_player, "none", "MOD_UNKNOWN", 0, level.weaponnone);
        }
        else
        {
            if(e_trap.activated_by_player is defined and e_trap.activated_by_player == self)
            {
                self dodamage((CLAMPED_ROUND_NUMBER * 1500) as int, self.origin, undefined, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
            }
            else
            {
                self dodamage((CLAMPED_ROUND_NUMBER * 1500) as int, self.origin, e_trap.activated_by_player, e_trap.activated_by_player, "none", "MOD_UNKNOWN", 0, level.weaponnone);
            }
        }
        self.var_d56bb8df = 1;
        wait(0.25);
        self.var_d56bb8df = undefined;
    });

    compiler::script_detour("scripts/zm/_hb21_sym_zm_trap_chain.gsc", 0x6027939c, 0xa37b193a, function() =>
    {
        self endon("trap_done");
        level.fn_hb21_chain_damage_zomb ??= @namespace_6027939c<scripts\zm\_hb21_sym_zm_trap_chain.gsc>::function_59007626;
        while(isdefined(self))
        {
            self waittill("trigger", e_ent);
            if(e_ent.marked_for_death is true || e_ent.var_f7ed1497 is true)
            {
                continue;
            }
            if(isplayer(e_ent))
            {
                if(e_ent isonslide() || e_ent hasperk("specialty_armorvest"))
                {
                    continue;
                }
                playsoundatposition("wpn_thundergun_proj_impact", e_ent.origin);

                if(self.activated_by_player is defined and self.activated_by_player == e_ent)
                {
                    e_ent dodamage((CLAMPED_ROUND_NUMBER * 4500) as int, e_ent.origin, undefined, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                }
                else
                {
                    e_ent dodamage((CLAMPED_ROUND_NUMBER * 4500) as int, e_ent.origin, self.activated_by_player, self.activated_by_player, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                }
            }
            else
            {
                e_ent thread [[ level.fn_hb21_chain_damage_zomb ]](self);
            }
        }
    });

    callback::on_spawned(function() => 
    {
        self.var_d56bb8df = undefined;
    });

    compiler::script_detour("scripts/zm/_zm_weap_elemental_bow_wolf_howl.gsc", #_zm_weap_elemental_bow_wolf_howl, #function_d281053d, function(e_player, projectile_array, v_forward) =>
    {
        if(!isdefined(level.original_function_2abb74b7))
        {
            level.original_function_2abb74b7 = @_zm_weap_elemental_bow_wolf_howl<scripts\zm\_zm_weap_elemental_bow_wolf_howl.gsc>::function_d281053d;
        }

        proj = projectile_array[0];

        if(isdefined(proj))
        {
            proj thread [[ function() => 
            {
                self endon("movedone");
                self endon("mechz_impact");
                self endon("death");

                wait 10; // hardcoded timeout before we are considered 'dead'
                self notify("movedone");
            }]]();
        }

        self thread [[ level.original_function_2abb74b7 ]](e_player, projectile_array, v_forward);
        do_wolfbow_knockback(e_player, projectile_array, v_forward);
    });

    level.fn_pause_zbr_objective = function() => 
    {
        if((self.zone_name ?? "") == "z23")
        {
            return true;
        }
        if((self.zone_name ?? "") == "z15")
        {
            return true;
        }
        if((self.zone_name ?? "") == "z14")
        {
            return true;
        }
        return false;
    };

    level.gm_blacklisted ??= [];
    level.gm_blacklisted[level.gm_blacklisted.size] = "z23";
    level.gm_blacklisted[level.gm_blacklisted.size] = "z15";
    level.gm_blacklisted[level.gm_blacklisted.size] = "z14";
        
    // TODO: tune snails pace slurpee

    // cooldowns
    array::thread_all(getentarray("trig_jump_pad", "targetname"), function() => 
    {
        for(;;)
        {
            self.var_700adf63 = 0.05;
            wait 1;
        }
    });

    getent("end_game_trig", "targetname").origin = ORIGIN_OOB;
    // TODO: TEST storm bow acting weird
    // TODO: demon bow acting weird
}

detour zm_weapons<scripts\zm\_zm_weapons.gsc>::get_upgrade_weapon(weapon, add_attachment)
{
    weapon = zm_weapons::get_nonalternate_weapon(weapon);
	rootweapon = weapon.rootweapon;
	newweapon = rootweapon;
	baseweapon = zm_weapons::get_base_weapon(weapon);
	if(!zm_weapons::is_weapon_upgraded(rootweapon))
	{
		newweapon = level.zombie_weapons[rootweapon].upgrade;
        if(level.zbr_variant_upgrades_array is defined and level.zbr_variant_upgrades_array[rootweapon.name] is defined)
        {
            newweapon = getweapon(array::random(level.zbr_variant_upgrades_array[rootweapon.name]));
        }
	}
	if(isdefined(add_attachment) && add_attachment && zm_pap_util::can_swap_attachments())
	{
		oldatt = "none";
		if(weapon.attachments.size)
		{
			oldatt = weapon.attachments[0];
		}
		att = zm_weapons::random_attachment(baseweapon, oldatt);
		newweapon = getweapon(newweapon.name, att);
	}
	else if(isdefined(level.zombie_weapons[rootweapon]) && isdefined(level.zombie_weapons[rootweapon].default_attachment))
	{
		att = level.zombie_weapons[rootweapon].default_attachment;
		newweapon = getweapon(newweapon.name, att);
	}
	return newweapon;
}

zm_irondragon_weapons()
{
    set_level_olympia("iw8_725", "iw8_725_up");
    level.zbr_variant_upgrades_array ??= [];
    level.zbr_variant_upgrades_array["elemental_bow"] = ["elemental_bow_wolf_howl", "elemental_bow_storm", "elemental_bow_rune_prison"/*, "elemental_bow_demongate" */];
    register_box_weapon("elemental_bow", "elemental_bow");
    level.zombie_weapons_upgraded[getweapon("elemental_bow")] = undefined;
    level.zombie_weapons_upgraded[getweapon("elemental_bow_wolf_howl")] = getweapon("elemental_bow");
    level.zombie_weapons_upgraded[getweapon("elemental_bow_storm")] = getweapon("elemental_bow");
    level.zombie_weapons_upgraded[getweapon("elemental_bow_rune_prison")] = getweapon("elemental_bow");
    level.zombie_weapons_upgraded[getweapon("elemental_bow_demongate")] = getweapon("elemental_bow");
}

zm_irondragon_threaded()
{
    fix_elemental_pop();
    delete_perk_by_names("specialty_whoswho", "vending_whoswho");
    delete_perk_by_names("specialty_tombstone", "vending_tombstone");
    
    level.var_b8662558 = true;
	level.var_7f6824f7 = true;
    level.var_fae13699 = true;
	level.var_62c631a6 = true;
    level.var_31c50477 = true;
	level.var_80d38640 = true;
    level.var_2e2e040a = true;
	level.var_9af2440d = true;
    level.var_ad38163b = true;
	level.var_32a0bc0c = true;
    level.var_cd79d15d = true;
	level.var_d668bf71 = true;
	level.var_36f1f658 = true;
	level.var_a1a11120 = true;
	level.var_8e00ae25 = true;
    level.var_bf17e00a = true;
	level.var_49241ca1 = true;
	level.var_1436c33b = true;
	level.var_60476306 = true;
    level.var_166f1eb3 = true;
	level.var_42734abe = true;
	level.var_f6b724fe = true;
	level.var_cb7a4a73 = true;
    level.var_3ca3b3ec = true;
    level.var_8a138a29 = true;
    level.var_c8c250ed = true;

    getent("key_trigger3", "targetname") notify(#trigger, level.players[0]);
    getent("key_trigger2", "targetname") notify(#trigger, level.players[0]);
    getent("key_trigger4", "targetname") notify(#trigger, level.players[0]);
    getent("key_trigger5", "targetname") notify(#trigger, level.players[0]);
    getent("key_trigger6", "targetname") notify(#trigger, level.players[0]);
    getent("key_trigger", "targetname") notify(#trigger, level.players[0]);
    getent("key_trigger_pad2", "targetname") notify(#trigger, level.players[0]);
    getent("key_trigger", "targetname") notify(#trigger, level.players[0]);
    getent("key_trigger_pad2", "targetname") notify(#trigger, level.players[0]);

    wait 1.0;
	
    foreach(door in getentarray("key_door3", "targetname"))
	{
		door notify(#trigger, level.players[0]);
	}

	foreach(door in getentarray("key_door1", "targetname"))
	{
		door notify(#trigger, level.players[0]);
	}

	foreach(door in getentarray("key_door4", "targetname"))
	{
		door notify(#trigger, level.players[0]);
	}

    foreach(door in getentarray("key_door5", "targetname"))
	{
		door notify(#trigger, level.players[0]);
	}

    foreach(door in getentarray("key_door6", "targetname"))
	{
		door notify(#trigger, level.players[0]);
	}

	foreach(door in getentarray("key_door", "targetname"))
	{
		door notify(#trigger, level.players[0]);
	}

	foreach(door in getentarray("key_door_pad2", "targetname"))
	{
		door notify(#trigger, level.players[0]);
	}

	foreach(door in getentarray("key_door7", "targetname"))
	{
		door notify(#trigger, level.players[0]);
	}

    getent("storm_quest_arrow", "targetname").origin = ORIGIN_OOB;
    getent("wolf_howl_painting1", "targetname").origin = ORIGIN_OOB;
    getent("wolf_howl_painting1_model", "script_noteworthy").origin = ORIGIN_OOB;
    getent("demonwall", "script_noteworthy").origin = ORIGIN_OOB;
    getent("demongate_wall", "targetname").origin = ORIGIN_OOB;
    getent("rune_prison_obelisk", "targetname").origin = ORIGIN_OOB;

	level.mechz_base_health = 3000;
	level.mechz_health = level.mechz_base_health;
	level.var_fa14536d = 1000;
	level.mechz_faceplate_health = level.var_fa14536d;
	level.var_f12b2aa3 = 500;
	level.mechz_powercap_cover_health = level.var_f12b2aa3;
	level.var_e12ec39f = 500;
	level.mechz_powercap_health = level.var_e12ec39f;
	level.var_3f1bf221 = 250;
	level.var_2cbc5b59 = level.var_3f1bf221;
	level.mechz_health_increase = 250;
	level.mechz_shotgun_damage_mod = 1.5;
	level.mechz_damage_percent = 0.6;
	level.mechz_helmet_health_percentage = 0.1;
	level.mechz_explosive_dmg_to_cancel_claw_percentage = 0.1;
	level.mechz_powerplant_destroyed_health_percentage = 0.025;
	level.mechz_powerplant_expose_health_percentage = 0.05;
	level.mechz_custom_goalradius = 48;
	level.mechz_tank_knockdown_time = 5;
	level.mechz_robot_knockdown_time = 10;
	level.mechz_claw_cooldown_time = 7000;
	level.mechz_flamethrower_cooldown_time = 7500;
	level.mechz_jump_delay = 3;
	level.num_mechz_spawned = 0;
	level.mechz_round_count = 0;
	level.mechz_min_round_fq = 3;
	level.mechz_max_round_fq = 4;
	level.mechz_min_round_fq_solo = 4;
	level.mechz_max_round_fq_solo = 6;
	level.mechz_zombie_per_round = 1;
	level.mechz_left_to_spawn = 0;
}

#endregion

#region zm_karma

#define IS_ARCADE_MODE = @namespace_c5407ece<scripts\zm\zm_karma_arcade.gsc>::init is defined;
autoexec zm_karma_autoexec()
{
    if(tolower(getdvarstring("mapname")) != "zm_karma")
    {
        return;
    }

    system::ignore("zm_weapon_flinger");
    
    if(IS_ARCADE_MODE)
    {
        compiler::script_detour("scripts/zm/zm_karma_arcade.gsc", 0xc5407ece, #init, function() =>
        {
            // no arcading today!
        });

        compiler::script_detour("scripts/zm/zm_karma.gsc", 0x3c24b943, 0x35357f0c, function() =>
        {
            // no arcading today!
        });

        compiler::script_detour("scripts/zm/zm_karma.gsc", 0x3c24b943, 0x86cd2222, function(round) =>
        {
            // no arcading today!
        });

        compiler::erasefunc("scripts/zm/ugxmods_timedgp.gsc", 0x26e7b5d9, 0x97b4fac5); // cheat code fix, overwrites function with OP_END
        level.round_wait_func = zm::round_wait;
        level.custom_game_over_hud_elem = serious::end_game_hud; // restore this
    }

    // need to not compile this for release!
    level.zbr_override_cweapons = [
        "karma_b23r", "karma_b23r_up", "karma_b23r_up2",
        "karma_olympia", "karma_olympia_up", "karma_olympia_up2",
        "karma_m14", "karma_m14_up", "karma_m14_up2",
        "karma_kap", "karma_kap_up", "karma_kap_up2",
        "karma_python", "karma_python_up", "karma_python_up2",
        "karma_judge", "karma_judge_up", "karma_judge_up2",
        "karma_m27", "karma_m27_up", "karma_m27_up2",
        "karma_ksg", "karma_ksg_up", "karma_ksg_up2",
        "karma_ks23", "karma_ks23_up", "karma_ks23_up2",
        "karma_s12", "karma_s12_up", "karma_s12_up2",
        "karma_scorpion", "karma_scorpion_up", "karma_scorpion_up2",
        "karma_mp5", "karma_mp5_up", "karma_mp5_up2",
        "karma_kuda", "karma_kuda_up", "karma_kuda_up2",
        "karma_fal", "karma_fal_up", "karma_fal_up2",
        "karma_dsr", "karma_dsr_up", "karma_dsr_up2",
        "karma_svu", "karma_svu_up", "karma_svu_up2",
        "karma_swat", "karma_swat_up", "karma_swat_up2",
        "karma_ak47", "karma_ak47_up", "karma_ak47_up2",
        "karma_an94", "karma_an94_up", "karma_an94_up2",
        "karma_peacekeeper", "karma_peacekeeper_up", "karma_peacekeeper_up2",
        "karma_lsat", "karma_lsat_up", "karma_lsat_up2",
        "karma_rpd", "karma_rpd_up", "karma_rpd_up2",
        "karma_hamr", "karma_hamr_up", "karma_hamr_up2",
        "karma_wonder_weapon_aof",
        "karma_wonder_weapon_trishot",
        "karma_dmr_infect",
        "chaser_gun", // DO NOT INCLUDE IN PROD
        "ray_gun",
        "ray_gun_upgraded"
    ];
}

zm_karma_init()
{
    if(IS_ARCADE_MODE)
    {
        level.var_38a60e71 = false;

        // for arcade
        foreach(trig in getentarray("elevator_button_trigger", "targetname"))
        {
            trig.origin = ORIGIN_OOB;
        }

        level.gm_blacklisted[level.gm_blacklisted.size] = "five_zone";

        for(i = 1; i < 10; i++)
        {
            for(j = 0; j < 3; j++)
            {
                trigname = "room" + i + "abc"[j] + "_button_trigger";
                foreach(trig in getentarray(trigname, "targetname"))
                {
                    trig.origin = ORIGIN_OOB;
                }
            }

            foreach(brush in getentarray("room_" + i + "_brushes", "targetname"))
            {
                brush delete();
            }
        }

        foreach(brush in getentarray("tp_clear", "targetname"))
        {
            brush delete();
        }

        foreach(brush in getentarray("tp_clear", "targetname"))
        {
            brush delete();
        }

        foreach(trig in getentarray("teleport_zombies", "targetname"))
        {
            trig.origin = ORIGIN_OOB;
        }

        foreach(trig in getentarray("teleport_player", "targetname"))
        {
            trig.origin = ORIGIN_OOB;
        }

        foreach(trig in getentarray("activate_pap", "targetname"))
        {
            trig.origin = ORIGIN_OOB;
        }

        foreach(model in getentarray("ds_models", "targetname"))
        {
            model delete();
        }

        level.do_not_apply_rand_lighting = true;
    }
}

zm_karma_weapons()
{
    gm_os_init();
    level.gm_os_upgrade2 = true;    

    set_level_olympia("karma_olympia_up", "karma_olympia_up2"); // NOTE: karma_olympia_up2 is EXPLOSIVE (super cool side effect actually)

    level.zbr_burner_weapons ??= [];
    level.zbr_burner_weapons[level.zbr_burner_weapons.size] = getweapon("karma_m27_up");
    level.zbr_burner_weapons[level.zbr_burner_weapons.size] = getweapon("karma_m27_up2");

    gm_os_register_weapon("ray_gun", "ray_gun_upgraded", "ray_gun_upgraded", GM_OS_RARITY_ULTRARARE, 1.3, 12, true);

    gm_os_register_weapon("karma_wonder_weapon_aof", undefined, undefined, GM_OS_RARITY_ULTRARARE, 1.1, 15, true);
    register_weapon_postcalc("karma_wonder_weapon_aof", true);
    tesla_sniper_calc_dmg = function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(1200 * CLAMPED_ROUND_NUMBER);
    };

    register_weapon_calculator("karma_wonder_weapon_aof", tesla_sniper_calc_dmg);
    
    gm_os_register_weapon("karma_wonder_weapon_trishot", undefined, undefined, GM_OS_RARITY_ULTRARARE, 1.3, 15, true);

    gm_os_mark_spawns(array((-16011.5,2385.27,-190.922), (-15212.4,3046.18,-209.172), (-14662.1,3336.93,-201.512), (-8928.55,-494.738,-228.625), (-8904.27,-1435.62,-232.125), (-8905.34,899.014,-229.125), (-7140.87,1982.77,-269.533), (-7933.47,1718.82,-272.761), (-5927.55,2175.54,-271.696), (-5489.72,666.256,-272.875), (-4389.04,2625.8,-227.372), (-4953.97,4828.89,-227.511), (-5008.77,3772.39,-227.625), (-8187.45,-2748.89,-226.765), (-6892.21,-2394.93,249.235), (-5737.54,-1984.77,249.235), (-5397.76,-3736.18,-229.272), (-5712.13,-3614.58,-44.5253), (-4809.71,-3482.91,-73.875), (-6428.99,-4385.36,105.125), (-7840.42,-4800.7,86.125), (-6232.55,-2832.02,-162.011), (-6516.42,-4135.27,-158.238), (-5641.62,-2802.87,125.441)));
    thread gm_os_run();

    // potential incindiary targets
    compiler::script_detour("scripts/zm/_incendiary.gsc", #incendiary, #getpotentialtargets, function(owner) =>
    {
        all_targets = [];
        all_targets = arraycombine(all_targets, level.players, 0, 0);
        all_targets = arraycombine(all_targets, getaiarray(), 0, 0);
        all_targets = arraycombine(all_targets, getvehiclearray(), 0, 0);
        potential_targets = [];
        foreach(target in all_targets)
        {
            if(!isdefined(target))
            {
                continue;
            }
            if(isdefined(owner?.team) && isdefined(target.team))
            {
                if(owner.team == target.team)
                {
                    continue;
                }
            }
            else
            {
                continue;
            }
            if(isplayer(target) && target.sessionstate != "playing")
            {
                continue;
            }
            potential_targets[potential_targets.size] = target;
        }
        return potential_targets;
    });

    level.zbr_post_loadout = function() =>
    {
        self zm_weapons::weapon_give(getweapon("frag_grenade"), false, false, true, false);
    };

    /// TODO: damage ranges
}

zm_karma_threaded()
{
    apply_lighting(1);

    // foreach(model in getentarray("pap_closed", "targetname"))
    // {
    //     model hide();
    // }
    // fxstruct = struct::get("fx_pap");
    // playfx("magic_box/carra_open_glow", fxstruct.origin);
    // foreach(brush in getentarray("pap_closed_brush", "targetname"))
    // {
    //     brush hide();
    // }

    delete_perk_by_names("specialty_whoswho", "vending_whoswho");
    delete_perk_by_names("specialty_tombstone", "vending_tombstone");
    delete_perk_by_names("specialty_stunprotection", "vending_repulse_elixir");
    delete_perk_by_names("specialty_jetquiet", "vending_profit_potion");
    delete_perk_by_names("specialty_vultureaid", "vending_vulture");

    open_all_doors();
    unlock_all_debris();

    level.zombie_total_set_func = undefined;
    level.soniczombiesenabled = false;
}

#endregion
#region zm_der_riese
autoexec zm_der_riese_auto()
{
    if(tolower(getdvarstring("mapname")) != "zm_der_riese")
    {
        return;
    }
}

zm_der_riese_init()
{
    // getent("shard", "targetname") delete();
    // getent("boss_fight_panel", "targetname") delete();

    // function_cbea0129 = function(group, mode) =>
    // {
    //     if(mode == "show")
    //     {
    //         ents = getentarray(group, "targetname");
    //         foreach(ent in ents)
    //         {
    //             if(ent.classname == "script_brushmodel")
    //             {
    //                 ent movez(2000, 0.05);
    //                 ent connectpaths();
    //             }
    //             ent show();
    //         }
    //     }
    //     else
    //     {
    //         if(mode == "hide")
    //         {
    //             ents = getentarray(group, "targetname");
    //             foreach(ent in ents)
    //             {
    //                 if(ent.classname == "script_brushmodel")
    //                 {
    //                     ent disconnectpaths();
    //                     ent movez(-2000, 0.05);
    //                 }
    //                 ent hide();
    //             }
    //         }
    //         else if(mode == "delete")
    //         {
    //             ents = getentarray(group, "targetname");
    //             foreach(ent in ents)
    //             {
    //                 if(ent.classname == "script_brushmodel")
    //                 {
    //                     ent disconnectpaths();
    //                     ent movez(-2000, 0.05);
    //                 }
    //                 ent delete();
    //             }
    //         }
    //     }
    // };

    // level thread [[function_cbea0129]]("flashback_massacre", "delete");
	// level thread [[function_cbea0129]]("flashback_maxis", "delete");
	// level thread [[function_cbea0129]]("flashback_fluffy_hall", "delete");
	// level thread [[function_cbea0129]]("flashback_fluffy_door", "delete");
	// level thread [[function_cbea0129]]("flashback_fluffy_teleporter", "delete");
	// level thread [[function_cbea0129]]("flashback_catwalk_lockdown", "delete");
	// level thread [[function_cbea0129]]("dark_aether", "delete");
	// level thread [[function_cbea0129]]("quest_shard_lockdown_1_1", "delete");
	// level thread [[function_cbea0129]]("quest_shard_lockdown_1_2", "delete");
	// level thread [[function_cbea0129]]("quest_shard_lockdown_2_1", "delete");
	// level thread [[function_cbea0129]]("quest_shard_lockdown_2_2", "delete");
	// level thread [[function_cbea0129]]("quest_shard_lockdown_2_3", "delete");
	// level thread [[function_cbea0129]]("quest_shard_lockdown_3_1", "delete");
	// level thread [[function_cbea0129]]("quest_shard_lockdown_3_2", "delete");
	// level thread [[function_cbea0129]]("quest_shard_lockdown_catwalk", "delete");
	// level thread [[function_cbea0129]]("lockdown_trap_clip", "delete");

	// foreach(trig in getentarray("timetravel_trig", "script_noteworthy"))
	// {
	// 	trig delete();
	// }
	// foreach(ent in getentarray("quest_tele_c_burn", "script_noteworthy"))
	// {
	// 	ent delete();
	// }
	// foreach(valve in getentarray("teleporter_b_valves", "targetname"))
	// {
	// 	valve delete();
	// }

    // getent("quest_teleporter_a_overload", "targetname") delete();
    // getent("quest_teleporter_b_overload", "targetname") delete();
    // getent("quest_teleporter_c_overload", "targetname") delete();



    // zm_der_riese
    foreach(ent in getentarray("meme_song_pickup", "targetname"))
    {
        ent.origin = ORIGIN_OOB;
    }
    // namespace_46219770::function_6df381be, function_bdad015 doesnt even work lmfao
    // bouncing betties need full rewrite
    // namespace_54020438::on_player_spawned
    // snow egg
    // m2_flamethrower m2_flamethrower_upgraded BALANCING
    // function_3679a65
    // periodic_lightning_strikes
    // flamethrower_swap
}

zm_der_riese_weapons()
{
    set_level_olympia("s2_win21", "s2_win21_upgraded");

    register_box_weapon("t8_tesla_dg1", "t8_tesla_dg1_upgraded");
    register_box_weapon("m2_flamethrower", "m2_flamethrower_upgraded");
}

zm_der_riese_threaded()
{
    ArrayRemoveValue(level.zombie_death_animscript_callbacks, @namespace_e2fe6bfe<scripts\zm\_zm_factory_shard_step.gsc>::function_5d8cbb18, false);
    ArrayRemoveValue(level.var_fffe87ea, @namespace_e2fe6bfe<scripts\zm\_zm_factory_shard_step.gsc>::function_5d8cbb18, false);
    level.zombie_powerups["bonus_points_team"].func_should_drop_with_regular_powerups = function() => { return false; };
}

#endregion

#region zm_prison
autoexec zm_prison_autoexec()
{
    if(tolower(getdvarstring("mapname")) != "zm_prison")
    {
        return;
    }

    level flag::init("afterlife_start_over");
    level.fn_wait_spawned = function() =>
    {
        while(!level flag::get("afterlife_start_over"))
        {
            self.score = 500;
            wait 0.05;
        }
    };

    // TODO: afterlife bodystyle
    level.zbr_uses_afterlife = true;
    level.zbr_afterlife_remove = @zm_afterlife<scripts\zm\_zm_afterlife.gsc>::afterlife_remove;
    level.zbr_afterlife_fake_death = @zm_afterlife<scripts\zm\_zm_afterlife.gsc>::afterlife_fake_death;
    level.zbr_afterlife_spawn_corpse = @zm_afterlife<scripts\zm\_zm_afterlife.gsc>::afterlife_spawn_corpse;
    level.zbr_afterlife_clean_up_on_disconnect = @zm_afterlife<scripts\zm\_zm_afterlife.gsc>::afterlife_clean_up_on_disconnect;
    level.zbr_afterlife_enter = @zm_afterlife<scripts\zm\_zm_afterlife.gsc>::afterlife_enter;
    level.zbr_do_revive_waypoint = @zm_afterlife<scripts\zm\_zm_afterlife.gsc>::function_a8b1589d;
    level.zbr_afterlife_revive_invincible = @zm_afterlife<scripts\zm\_zm_afterlife.gsc>::afterlife_revive_invincible;
    level.zbr_afterlife_doors_close = @zm_afterlife<scripts\zm\_zm_afterlife.gsc>::afterlife_doors_close;
    level.zbr_get_gondola_doors_and_gates = @namespace_bad27ca7<scripts\zm\zm_prison_gondola.gsc>::get_gondola_doors_and_gates;
    level.zbr_afterlife_laststand_cleanup = @zm_afterlife<scripts\zm\_zm_afterlife.gsc>::afterlife_laststand_cleanup;
    level.zbr_reset_all_afterlife_unitriggers = @zm_afterlife<scripts\zm\_zm_afterlife.gsc>::reset_all_afterlife_unitriggers;
    level.zbr_afterlife_reduce_mana = @zm_afterlife<scripts\zm\_zm_afterlife.gsc>::afterlife_reduce_mana;
    level.zbr_afterlife_fake_revive = function() =>
    {
        level notify(#fake_revive);
        self notify(#fake_revive);
        playsoundatposition("zmb_afterlife_spawn_leave", self.origin);
        if(level flag::get("afterlife_start_over"))
        {
            spawnpoint = [[level.afterlife_get_spawnpoint]]();
            self setorigin(spawnpoint.origin);
            self setplayerangles(spawnpoint.angles);
            playsoundatposition("zmb_afterlife_spawn_enter", spawnpoint.origin);
        }
        else
        {
            playsoundatposition("zmb_afterlife_spawn_enter", self.origin);
        }
        self allowstand(1);
        self allowcrouch(0);
        self allowprone(0);
        self freezecontrols(0);
        self.ignoreme = 0;
        self setstance("stand");
        self allowsprint(1);
        self giveweapon(getweapon("t6_xl_shockhands"));
        self switchtoweapon(getweapon("t6_xl_shockhands"));
        wait(1);
    };
    level.zbr_afterlife_leave = function(b_revived = 1) =>
    {
        self clientfield::set("player_afterlife_fx", 0);
        wait(0.05);
        while(self ismantling())
        {
            wait(0.05);
        }
        self util::clientnotify("al_t");
        visionset_mgr::deactivate("overlay", "zm_afterlife", self);
        self thread [[level.zbr_afterlife_doors_close]]();
        self clientfield::set_player_uimodel("afterlife_hud", 0);
        self clientfield::set_to_player("player_in_afterlife", 0);
        self clientfield::set_to_player("clientfield_afterlife_audio", 0);
        self unsetperk("specialty_unlimitedsprint");
        self unsetperk("specialty_fallheight");
        self unsetperk("specialty_lowgravity");
        self allowstand(1);
        self allowcrouch(1);
        self allowprone(1);
        self.ignoreme = 0;
        // self setcharacterbodystyle(0);
        if(self.e_afterlife_corpse.revivetrigger.origin != self.e_afterlife_corpse.origin)
        {
            self setorigin(self.e_afterlife_corpse.revivetrigger.origin);
        }
        else
        {
            self setorigin(self.e_afterlife_corpse.origin);
        }
        if(isdefined(level.gondola))
        {
            a_gondola_doors_gates = [[level.zbr_get_gondola_doors_and_gates]]();
            for(i = 0; i < a_gondola_doors_gates.size; i++)
            {
                if(self.e_afterlife_corpse istouching(a_gondola_doors_gates[i]))
                {
                    if(isdefined(level.gondola.is_moving) && level.gondola.is_moving)
                    {
                        str_location = level.gondola.destination;
                    }
                    else
                    {
                        str_location = level.gondola.location;
                    }
                    a_s_orgs = struct::get_array("gondola_dropped_parts_" + str_location);
                    foreach(struct in a_s_orgs)
                    {
                        if(!positionwouldtelefrag(struct.origin))
                        {
                            self setorigin(struct.origin);
                            break;
                        }
                    }
                    break;
                }
            }
            if(self.e_afterlife_corpse islinkedto(level.gondola) && (isdefined(level.gondola.is_moving) && level.gondola.is_moving))
            {
                self.is_on_gondola = 1;
            }
        }
        self setplayerangles(self.e_afterlife_corpse.angles);
        self.afterlife = 0;
        self.is_drinking = 0;
        self [[level.zbr_afterlife_laststand_cleanup]](self.e_afterlife_corpse);
        if(!b_revived)
        {
            self [[level.zbr_afterlife_remove]](1);
            if(isdefined(self.last_player_attacker))
            {
                self dodamage(int(self.health + 666), self.origin, self.last_player_attacker, self.last_player_attacker, "none", "MOD_UNKNOWN", 0, level.weaponnone);
            }
            else
            {
                self dodamage(int(self.health + 666), self.origin);
            }
        }
        [[level.zbr_reset_all_afterlife_unitriggers]]();
    };

    level.zbr_afterlife_laststand = function(b_electric_chair = 0) =>
    {
        self endon(#disconnect);
        self endon(#afterlife_bleedout);
        level endon(#end_game);
        self.dontspeak = 1;
        // self.health = 1000; dont modify health
        b_has_electric_cherry = 0;
        if(self hasperk("specialty_grenadepulldeath"))
        {
            b_has_electric_cherry = 1;
        }
        self [[level.afterlife_save_loadout]]();
        self [[level.zbr_afterlife_fake_death]]();
        if(isdefined(b_electric_chair) && !b_electric_chair)
        {
            wait(1);
        }
        // TODO: electric cherry
        // if(isdefined(b_has_electric_cherry) && b_has_electric_cherry && (!(isdefined(b_electric_chair) && b_electric_chair)))
        // {
        //     self zm_perk_electric_cherry::electric_cherry_laststand();
        //     wait(2);
        // }
        self clientfield::set_to_player("clientfield_afterlife_audio", 1);
        if(level flag::get("afterlife_start_over"))
        {
            self util::clientnotify("al_t");
            wait(1);
            self thread lui::screen_fade_out(0.5, "white");
            wait(0.5);
        }
        self ghost();
        self.e_afterlife_corpse = self [[level.zbr_afterlife_spawn_corpse]]();
        self thread [[level.zbr_afterlife_clean_up_on_disconnect]]();
        self notify(#player_fake_corpse_created);
        self [[level.zbr_afterlife_fake_revive]]();
        self [[level.zbr_afterlife_enter]]();
        if(level flag::get("afterlife_start_over"))
        {
            self thread lui::screen_fade_in(0.5, "white");
        }
        self.e_afterlife_corpse clientfield::set("player_corpse_id", self getentitynumber() + 1);
        self.e_afterlife_corpse thread [[level.zbr_do_revive_waypoint]](self getentitynumber());
        wait(0.5);
        self show();
        if(!(isdefined(self.hostmigrationcontrolsfrozen) && self.hostmigrationcontrolsfrozen))
        {
            self freezecontrols(0);
        }
        self disableinvulnerability();
        self.e_afterlife_corpse waittill(#player_revived, e_reviver);
        self notify(#player_revived);
        self seteverhadweaponall(1);
        self enableinvulnerability();
        self.afterlife_revived = 1;
        playsoundatposition("zmb_afterlife_spawn_leave", self.e_afterlife_corpse.origin);
        self [[level.zbr_afterlife_leave]]();
        self thread [[level.zbr_afterlife_revive_invincible]]();
        self playsound("zmb_afterlife_revived_gasp");
    };
    level.afterlife_laststand_override = level.zbr_afterlife_laststand;

    level.afterlife_player_damage_override = function(einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime) =>
    {
        return -1;
    };

    compiler::script_detour("scripts/zm/zm_prison_plane_quest.gsc", #namespace_4823994c, #function_b346add1, function(volume_name, volume) => 
    {
        level flag::set("spawn_zombies");
    });

    compiler::script_detour("scripts/zm/zm_prison_plane_quest.gsc", #namespace_4823994c, #plane_flight_thread, function() => 
    {
        level endon(#end_game);
        for(;;)
        {
            m_plane_craftable = getent("plane_craftable", "targetname");
            t_plane_fly = getent("plane_fly_trigger", "targetname");
            veh_plane_flyable = getent("plane_flyable", "targetname");
            veh_plane_flyable setinvisibletoall();
            level flag::wait_till("plane_boarded");
            level util::clientnotify("sndPB");
            t_plane_fly playloopsound("mus_plane_countdown_loop", 0.25);
            for(i = 10; i > 0; i--)
            {
                veh_plane_flyable playsound("zmb_plane_countdown_tick");
                wait(1);
            }
            t_plane_fly stoploopsound(2);
            veh_plane_flyable attachpath(getvehiclenode("zombie_plane_flight_path", "targetname"));
            veh_plane_flyable setspeed(36, 15, 5);
            veh_plane_flyable startpath();
            level flag::set("plane_departed");
            t_plane_fly triggerenable(0);
            m_plane_craftable ghost();
            veh_plane_flyable setvisibletoall();
            level clientfield::set("fog_stage", 1);
            wait(2);
            playfxontag(level._effect["fx_alcatraz_flight_lightning"], veh_plane_flyable, "tag_origin");
            wait(7);
            clientfield::set("scripted_lightning_flash", 1);
            wait(1);
            level flag::set("plane_approach_bridge");
            level clientfield::set("fog_stage", 2);
            playfxontag(level._effect["fx_alcatraz_flight_lightning_zapped"], veh_plane_flyable, "tag_origin");
            veh_plane_flyable attachpath(getvehiclenode("zombie_plane_bridge_approach", "targetname"));
            veh_plane_flyable setspeedimmediate(75, 15, 5);
            veh_plane_flyable startpath();
            wait(6);
            playfxontag(level._effect["fx_alcatraz_flight_lightning"], veh_plane_flyable, "tag_origin");
            clientfield::set("scripted_lightning_flash", 1);
            veh_plane_flyable waittill(#reached_end_node);
            level flag::set("plane_zapped");
            level clientfield::set("fog_stage", 3);
            veh_plane_flyable setinvisibletoall();
            level flag::wait_till("plane_crashed");
            wait(2);
            clientfield::set("scripted_lightning_flash", 1);
            wait(4);
            veh_plane_flyable setvisibletoall();
            playfxontag(level._effect["fx_alcatraz_plane_fire_trail"], veh_plane_flyable, "tag_origin");
            veh_plane_flyable attachpath(getvehiclenode("zombie_plane_bridge_flyby", "targetname"));
            veh_plane_flyable setspeedimmediate(65, 15, 5);
            veh_plane_flyable startpath();
            veh_plane_flyable waittill(#reached_end_node);
            veh_plane_flyable setinvisibletoall();
            wait(1);
            level flag::clear("plane_built");
            level flag::clear("plane_boarded");
            level flag::clear("plane_departed");
            level flag::clear("plane_approach_bridge");
            level flag::clear("plane_zapped");
            level flag::clear("plane_crashed");
            level.n_plane_fuel_count = 5;
            level notify(#plane_fly_over);
        }
    });
    compiler::script_detour("scripts/zm/zm_prison_plane_quest.gsc", #namespace_4823994c, #track_quest_status_thread, function() => 
    {
        level endon(#end_game);
        for(;;)
        {
            level waittill(#plane_fly_over);
            for(i = 1; i <= 5; i++)
            {
                level clientfield::set("ger_jerry_can_0" + i, 1);
            }
            level flag::wait_till("plane_refueled");
            [[ @zm_ai_brutus<scripts\zm\_zm_ai_brutus.gsc>::transfer_plane_trigger ]]("fuel", "fly");
            t_plane_fly = getent("plane_fly_trigger", "targetname");
            t_plane_fly triggerenable(1);
            getent("plane_craftable", "targetname") hide();
        }
    });

    compiler::script_detour("scripts/zm/zm_prison_plane_quest.gsc", #namespace_4823994c, #manage_electric_chairs, function() => 
    {
        level notify(#manage_electric_chairs);
        level endon(#manage_electric_chairs);
        for(i = 1; i < 5; i++)
        {
            str_trigger_targetname = "trigger_electric_chair_" + i;
            t_electric_chair = getent(str_trigger_targetname, "targetname");
            t_electric_chair thread [[ @namespace_4823994c<scripts\zm\zm_prison_plane_quest.gsc>::electric_chair_trigger_thread ]](i);
            t_electric_chair setcursorhint("HINT_NOICON");
            t_electric_chair sethintstring(&"ZM_PRISON_ELECTRIC_CHAIR_ACTIVATE");
            t_electric_chair usetriggerrequirelookat();
            t_electric_chair triggerenable(1);
        }
    });

    compiler::script_detour("scripts/zm/zm_prison_gondola.gsc", #namespace_bad27ca7, #gondola_cooldown, function() => 
    {
        level.gondola.var_e344a588 sethintstring(&"ZM_PRISON_GONDOLA_COOLDOWN");
        foreach(trigger in level.gondola.var_58683892)
        {
            trigger sethintstring(&"ZM_PRISON_GONDOLA_COOLDOWN");
        }
        level.gondola playsound("gondola_cooldown_start");
        level.gondola playloopsound("gondola_cooldown_loop", 1);
        wait(1);
        level.gondola stoploopsound(0.5);
        level.gondola playsound("gondola_cooldown_stop");
        level notify(#"hash_2664d2a8");
        level.gondola.var_e344a588 thread [[ @namespace_bad27ca7<scripts\zm\zm_prison_gondola.gsc>::function_b068ae3e ]]();
        array::thread_all(level.gondola.var_58683892, @namespace_bad27ca7<scripts\zm\zm_prison_gondola.gsc>::function_e7d99598);
        wait(0.2);
        level.gondola playsound("gondola_available");
        foreach(model in getentarray("gondola_light", "targetname"))
        {
            model setmodel("p8_zm_esc_gondola_frame_light_green");
            wait(0.05);
        }
    });

    fn_fan_acid_damage = function() => 
    {
        self endon(#acid_trap_finished);
        self endon(#fan_trap_finished);
        level endon(#end_game);
        for(;;)
        {
            foreach(ent in getaiteamarray(level.zombie_team))
            {
                if(isdefined(ent.is_brutus) && ent.is_brutus)
                {
                    return;
                }
                if(ent istouching(self) && !isdefined(ent.marked_for_death))
                {
                    ent.marked_for_death = 1;
                    ent thread [[ function() => 
                    {
                        self endon(#death);
                        wait(randomfloatrange(0.25, 2));
                        self zombie_utility::gib_random_parts();
                        self dodamage(self.health + 666, self.origin);
                    }]]();
                }
            }
            foreach(player in getplayers())
            {
                if(player.sessionstate != "playing")
                {
                    continue;
                }
                if(player.next_acid_tick is defined and player.next_acid_tick > gettime())
                {
                    continue;
                }
                if(!player istouching(self))
                {
                    continue;
                }
                if(player hasperk("specialty_armorvest"))
                {
                    player dodamage(100, player.origin);
                    player.next_acid_tick = gettime() + 1000;
                    continue;
                }
                player dodamage(player.health + 666, player.origin);
                player.next_acid_tick = gettime() + 1000;
            }
            wait 0.25;
        }
    };

    compiler::script_detour("scripts/zm/zm_prison_traps.gsc", #namespace_89c3cfd, #acid_trap_damage, fn_fan_acid_damage);
    compiler::script_detour("scripts/zm/zm_prison_traps.gsc", #namespace_89c3cfd, #fan_trap_damage, fn_fan_acid_damage);
    compiler::script_detour("scripts/zm/zm_prison_traps.gsc", #namespace_89c3cfd, #activate_tower_trap, function() =>
    {
        self endon(#tower_trap_off);
        self.weapon_name = "tower_trap";
        self.tag_to_target = "J_Head";
        self.trap_reload_time = 0.75;
        e_org = struct::get(self.range_trigger.target, "targetname");
        for(;;)
        {
            wait(0.05);

            zombies = zombie_utility::get_round_enemy_array();
            zombies_sorted = [];
            foreach(zombie in zombies)
            {
                if(!zombie istouching(self.range_trigger))
                {
                    continue;
                }
                v_zombietarget = zombie gettagorigin(self.tag_to_target);
                if(!sighttracepassed(e_org.origin, v_zombietarget, 1, undefined))
                {
                    continue;
                }
                zombies_sorted[zombies_sorted.size] = zombie;
            }

            foreach(player in getplayers())
            {
                if(player.sessionstate != "playing")
                {
                    continue;
                }
                if(!player istouching(self.range_trigger))
                {
                    continue;
                }
                v_zombietarget = player gettagorigin(self.tag_to_target);
                if(!sighttracepassed(e_org.origin, v_zombietarget, 1, undefined))
                {
                    continue;
                }
                zombies_sorted[zombies_sorted.size] = player;
            }

            if(!zombies_sorted.size)
            {
                continue;
            }
            
            e_target = array::random(zombies_sorted);
            v_zombietarget = e_target gettagorigin(self.tag_to_target);
            magicbullet(getweapon(self.weapon_name), e_org.origin, v_zombietarget);
			wait(self.trap_reload_time);
        }
    });

    compiler::script_detour("scripts/zm/_zm_weap_blundersplat.gsc", #namespace_f1f1fe05, #_titus_locate_target, function(is_not_upgraded = 1) =>
    {
        fire_angles = self getplayerangles();
        fire_origin = self getplayercamerapos();
        a_targets = zombie_utility::get_round_enemy_array();
        foreach(player in getplayers())
        {
            if(player == self)
            {
                continue;
            }
            if(player.sessionstate != "playing")
            {
                continue;
            }
            a_targets[a_targets.size] = player;
        }
        a_targets = util::get_array_of_closest(self.origin, a_targets, undefined, undefined, 1500);
        if(is_not_upgraded)
        {
            n_fuse_timer = randomfloatrange(1, 2.5);
        }
        else
        {
            n_fuse_timer = randomfloatrange(3, 4);
        }

        _titus_reset_grenade_fuse = function(n_fuse_timer = randomfloatrange(1, 1.5), is_not_upgraded = 1) =>
        {
            self waittill(#death);
            a_grenades = getentarray("grenade", "classname");
            foreach(e_grenade in a_grenades)
            {
                if(isdefined(e_grenade.model) && e_grenade.model == "t8_wpn_zmb_projectile_blundergat" && !isdefined(e_grenade.fuse_reset))
                {
                    e_grenade.fuse_reset = 1;
                    e_grenade.fuse_time = n_fuse_timer;
                    e_grenade resetmissiledetonationtime(n_fuse_timer);
                    if(is_not_upgraded)
                    {
                        e_grenade zm_utility::create_zombie_point_of_interest(250, 5, 10000);
                    }
                    else
                    {
                        e_grenade zm_utility::create_zombie_point_of_interest(500, 10, 10000);
                    }
                    return;
                }
            }
        };

        foreach(target in a_targets)
        {
            if(util::within_fov(fire_origin, fire_angles, target.origin, cos(30)))
            {
                if(isplayer(target) || (isalive(target) && !isdefined(target.titusmarked)))
                {
                    a_tags = [];
                    a_tags[0] = "j_hip_le";
                    a_tags[1] = "j_hip_ri";
                    a_tags[2] = "j_spine4";
                    a_tags[3] = "j_elbow_le";
                    a_tags[4] = "j_elbow_ri";
                    a_tags[5] = "j_clavicle_le";
                    a_tags[6] = "j_clavicle_ri";
                    str_tag = a_tags[randomint(a_tags.size)];
                    b_trace_pass = bullettracepassed(fire_origin, target gettagorigin(str_tag), 1, self, target);
                    if(b_trace_pass)
                    {
                        target thread [[function() => 
                        {
                            self endon(#death);
                            self.titusmarked = 1;
                            wait(1);
                            self.titusmarked = undefined;
                        }]]();
                        e_dart = magicbullet(getweapon("t8_blundersplat_bullet"), fire_origin, target gettagorigin(str_tag), self);
                        e_dart thread [[_titus_reset_grenade_fuse]](n_fuse_timer, is_not_upgraded);
                        return;
                    }
                }
            }
        }

        vec = anglestoforward(fire_angles);
        trace_end = fire_origin + (vec * 20000);
        trace = bullettrace(fire_origin, trace_end, 1, self);
        offsetpos = trace["position"] + [[ function(n_spread) =>
        {
            n_x = randomintrange(n_spread * -1, n_spread);
            n_y = randomintrange(n_spread * -1, n_spread);
            n_z = randomintrange(n_spread * -1, n_spread);
            return (n_x, n_y, n_z);
        } ]](80);
        e_dart = magicbullet(getweapon("t8_blundersplat_bullet"), fire_origin, offsetpos, self);
        e_dart thread [[_titus_reset_grenade_fuse]](n_fuse_timer);
    });

    compiler::script_detour("scripts/zm/_zm_weap_claymore.gsc", #namespace_15d449fd, #claymore_detonation, function(e_planter) => 
    {
        self endon(#death);
        self playsound("claymore_plant");
        self.angles = e_planter.angles;
        self zm_utility::waittill_not_moving();
        var_e79a372e = 96;
        var_55f0ad85 = spawn("trigger_radius", self.origin, 9, var_e79a372e, var_e79a372e * 2);
        var_55f0ad85 setexcludeteamfortrigger(self.owner.team);
        var_55f0ad85 enablelinkto();
        var_55f0ad85 linkto(self);
        self.var_55f0ad85 = var_55f0ad85;
        self thread [[ function(e_player, e_ent) =>
        {
            self waittill(#death);
            if(isdefined(e_player))
            {
                arrayremovevalue(e_player.placeable_mines, self);
            }
            wait(0.05);
            if(isdefined(e_ent))
            {
                e_ent delete();
            }
        }]](self.owner, var_55f0ad85);
        if(!isdefined(self.owner.placeable_mines))
        {
            self.owner.placeable_mines = [];
        }
        else if(!isarray(self.owner.placeable_mines))
        {
            self.owner.placeable_mines = array(self.owner.placeable_mines);
        }
        self.owner.placeable_mines[self.owner.placeable_mines.size] = self;
        while(isdefined(self))
        {
            wait 0.05;
            e_ent = undefined;
            foreach(ent in getaiteamarray(level.zombie_team))
            {
                if(!isalive(ent) || !ent istouching(var_55f0ad85))
                {
                    continue;
                }
                e_ent = ent;
                break;
            }
            if(!isdefined(e_ent))
            {
                foreach(player in getplayers())
                {
                    if(player.sessionstate != "playing")
                    {
                        continue;
                    }
                    if(player.team == e_planter.team)
                    {
                        continue;
                    }
                    e_ent = player;
                    break;
                }
            }
            if(!isdefined(e_ent))
            {
                continue;
            }

            if(isdefined(self.owner) && e_ent == self.owner)
            {
                continue;
            }

            if(isdefined(e_ent.pers) && isdefined(e_ent.pers["team"]) && e_ent.pers["team"] == self.team)
            {
                continue;
            }
            
            if(isdefined(e_ent.ignore_placeable_mine) && e_ent.ignore_placeable_mine)
            {
                continue;
            }

            if(!e_ent [[ function(e_mine) =>
            {
                n_detonation_dot = cos(70);
                v_pos = self.origin + vectorscale((0, 0, 1), 32);
                var_81e9ae5c = v_pos - e_mine.origin;
                var_71e5fec0 = anglestoforward(e_mine.angles);
                n_dist = vectordot(var_81e9ae5c, var_71e5fec0);
                if(n_dist < 20)
                {
                    return 0;
                }
                var_81e9ae5c = vectornormalize(var_81e9ae5c);
                n_dot = vectordot(var_81e9ae5c, var_71e5fec0);
                return n_dot > n_detonation_dot;
            }]](self))
            {
                continue;
            }
            if(e_ent damageconetrace(self.origin, self) > 0)
            {
                self playsound("claymore_alert");
                wait(0.4);
                playfx(level._effect["explosion"], self.origin);
                self playsound("claymore_explode");
                earthquake(1, 0.4, self.origin, 512);
                if(isdefined(self.owner))
                {
                    self detonate(self.owner);
                }
                else
                {
                    self detonate(undefined);
                }
                return;
            }
        }
    });

    level.zbr_tomahawk_spawn = @namespace_46b7c49b<scripts\zm\_zm_weap_tomahawk.gsc>::tomahawk_spawn;

    compiler::script_detour("scripts/zm/_zm_weap_tomahawk.gsc", #namespace_46b7c49b, #tomahawk_thrown, function(grenade) => 
    {
        self endon(#disconnect);
        grenade endon(#in_hellhole);
        grenade_owner = undefined;
        if(isdefined(grenade.owner))
        {
            grenade_owner = grenade.owner;
        }
        playfxontag(level._effect["tomahawk_charged_trail"], grenade, "tag_origin");
        self clientfield::set_to_player("tomahawk_in_use", 2);
        grenade util::waittill_either("death", "time_out");
        grenade_origin = grenade.origin;
        zombies = zombie_utility::get_round_enemy_array();
        foreach(player in getplayers())
        {
            if(self == player || self.team == player.team)
            {
                continue;
            }
            if(player.sessionstate != "playing")
            {
                continue;
            }
            // if(!sighttracepassed(player geteye(), grenade_origin, false, undefined))
            // {
            //     continue;
            // }
            zombies[zombies.size] = player;
        }
        boss = getaiarchetypearray("brutus");
        a_zombies = arraycombine(zombies, boss, 1, 1);
        n_grenade_charge_power = grenade [[ @namespace_46b7c49b<scripts\zm\_zm_weap_tomahawk.gsc>::get_grenade_charge_power ]](self);
        a_zombies = util::get_array_of_closest(grenade_origin, a_zombies, undefined, undefined, 200);
        a_powerups = util::get_array_of_closest(grenade_origin, level.active_powerups, undefined, undefined, 200);
        if(isdefined(level.a_tomahawk_pickup_funcs))
        {
            var_cd994756 = level.a_tomahawk_pickup_funcs;
            _k243 = getfirstarraykey(var_cd994756);
            while(isdefined(_k243))
            {
                tomahawk_func = var_cd994756[_k243];
                if([[tomahawk_func]](grenade, n_grenade_charge_power))
                {
                    return;
                }
                _k243 = getnextarraykey(var_cd994756, _k243);
            }
        }
        if(isdefined(a_powerups) && a_powerups.size > 0)
        {
            m_tomahawk = [[level.zbr_tomahawk_spawn]](grenade_origin, n_grenade_charge_power);
            m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
            var_75045b94 = a_powerups;
            var_66381bf2 = getfirstarraykey(var_75045b94);
            while(isdefined(var_66381bf2))
            {
                powerup = var_75045b94[var_66381bf2];
                powerup.origin = grenade_origin;
                powerup linkto(m_tomahawk);
                m_tomahawk.a_has_powerup = a_powerups;
                var_66381bf2 = getnextarraykey(var_75045b94, var_66381bf2);
            }
            self thread zm_prison_tomahawk_return_player(m_tomahawk, 0);
            return;
        }
        if(!isdefined(a_zombies))
        {
            m_tomahawk = [[level.zbr_tomahawk_spawn]](grenade_origin, n_grenade_charge_power);
            m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
            self thread zm_prison_tomahawk_return_player(m_tomahawk, 0);
            return;
        }
        foreach(ai_zombie in a_zombies)
        {
            ai_zombie.hit_by_tomahawk = 0;
        }
        if(isdefined(a_zombies[0]) && isalive(a_zombies[0]))
        {
            v_zombiepos = a_zombies[0].origin;
            if(distancesquared(grenade_origin, v_zombiepos) <= 4900)
            {
                a_zombies[0] clientfield::set("play_tomahawk_hit_sound", 1);
                n_tomahawk_damage = zm_prison_calculate_tomahawk_damage(a_zombies[0], n_grenade_charge_power, grenade);
                a_zombies[0] dodamage(n_tomahawk_damage, grenade_origin, self, grenade, "none", "MOD_UNKNOWN", 0, getweapon("t6_bouncing_tomahawk"));
                a_zombies[0].hit_by_tomahawk = 1;
                self zm_score::add_to_player_score(10);
                self thread zm_prison_tomahawk_ricochet_attack(grenade_origin, n_grenade_charge_power);
            }
            else
            {
                m_tomahawk = [[level.zbr_tomahawk_spawn]](grenade_origin, n_grenade_charge_power);
                m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
                self thread zm_prison_tomahawk_return_player(m_tomahawk, 0);
            }
        }
        else
        {
            m_tomahawk = [[level.zbr_tomahawk_spawn]](grenade_origin, n_grenade_charge_power);
            m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
            if(isdefined(grenade))
            {
                grenade delete();
            }
            self thread zm_prison_tomahawk_return_player(m_tomahawk, 0);
        }
    });
}

zm_prison_tomahawk_ricochet_attack(grenade_origin, tomahawk_charge_power)
{
	self endon(#disconnect);
	zombies = zombie_utility::get_round_enemy_array();
	boss = getaiarchetypearray("brutus");
	a_zombies = arraycombine(zombies, boss, 1, 1);
    foreach(player in getplayers())
    {
        if(self == player || self.team == player.team)
        {
            continue;
        }
        if(player.sessionstate != "playing")
        {
            continue;
        }
        // if(!sighttracepassed(player geteye(), grenade_origin, false, undefined))
        // {
        //     continue;
        // }
        a_zombies[a_zombies.size] = player;
    }
	a_zombies = util::get_array_of_closest(grenade_origin, a_zombies, undefined, undefined, 300);
	a_zombies = array::reverse(a_zombies);
	if(!isdefined(a_zombies))
	{
		m_tomahawk = [[level.zbr_tomahawk_spawn]](grenade_origin, tomahawk_charge_power);
		m_tomahawk.n_grenade_charge_power = tomahawk_charge_power;
		self thread zm_prison_tomahawk_return_player(m_tomahawk, 0);
		return;
	}
	m_tomahawk = [[level.zbr_tomahawk_spawn]](grenade_origin, tomahawk_charge_power, self);
	m_tomahawk.n_grenade_charge_power = tomahawk_charge_power;
	self thread zm_prison_tomahawk_attack_zombies(m_tomahawk, a_zombies);
}

zm_prison_tomahawk_attack_zombies(m_tomahawk, a_zombies)
{
	self endon(#disconnect);
	if(!isdefined(a_zombies))
	{
		self thread zm_prison_tomahawk_return_player(m_tomahawk, 0);
		return;
	}
	if(a_zombies.size <= 4)
	{
		n_attack_limit = a_zombies.size;
	}
	else
	{
		n_attack_limit = 4;
	}
	for(i = 0; i < n_attack_limit; i++)
	{
		if(isdefined(a_zombies[i]) && isalive(a_zombies[i]) && (!isplayer(a_zombies[i]) || a_zombies[i].sessionstate == "playing"))
		{
			tag = "J_Head";
			if(a_zombies[i].isdog)
			{
				tag = "J_Spine1";
			}
			if(isdefined(a_zombies[i].hit_by_tomahawk) && !a_zombies[i].hit_by_tomahawk)
			{
				v_target = a_zombies[i] gettagorigin(tag);
				m_tomahawk moveto(v_target, 0.3);
				m_tomahawk util::waittill_any_timeout(3, "movedone");
				if(isdefined(a_zombies[i]) && isalive(a_zombies[i]) && (!isplayer(a_zombies[i]) || a_zombies[i].sessionstate == "playing"))
				{
					if(self.current_tactical_grenade.name == "t6_upgraded_tomahawk")
					{
						playfxontag(level._effect["tomahawk_impact_ug"], a_zombies[i], tag);
					}
					else
					{
						playfxontag(level._effect["tomahawk_impact"], a_zombies[i], tag);
					}
					a_zombies[i] clientfield::set("play_tomahawk_hit_sound", 1);
					n_tomahawk_damage = zm_prison_calculate_tomahawk_damage(a_zombies[i], m_tomahawk.n_grenade_charge_power, m_tomahawk);
					a_zombies[i] dodamage(n_tomahawk_damage, m_tomahawk.origin, self, m_tomahawk, "none", "MOD_UNKNOWN", 0, getweapon("t6_bouncing_tomahawk"));
					a_zombies[i].hit_by_tomahawk = 1;

                    if(isplayer(a_zombies[i]))
                    {
                        a_zombies[i] thread [[ function() =>
                        {
                            self endon(#disconnect);
                            wait 5;
                            self.hit_by_tomahawk = false;
                        }]]();
                    }

					self zm_score::add_to_player_score(10);
				}
			}
		}
		wait(0.2);
	}
	self thread zm_prison_tomahawk_return_player(m_tomahawk, n_attack_limit);
}

zm_prison_calculate_tomahawk_damage(n_target_zombie, n_tomahawk_power, tomahawk)
{
	if(n_tomahawk_power > 2)
	{
        if(isplayer(n_target_zombie))
        {
            return int(CLAMPED_ROUND_NUMBER * 1500);
        }
		return n_target_zombie.health + 1;
	}
	if(level.round_number >= 10 && level.round_number < 13 && tomahawk.low_level_instant_kill_charge <= 3)
	{
         if(isplayer(n_target_zombie))
        {
            return int(CLAMPED_ROUND_NUMBER * 1500);
        }
		tomahawk.low_level_instant_kill_charge = tomahawk.low_level_instant_kill_charge + 1;
		return n_target_zombie.health + 1;
	}
	if(level.round_number >= 13 && level.round_number < 15 && tomahawk.low_level_instant_kill_charge <= 2)
	{
        if(isplayer(n_target_zombie))
        {
            return int(CLAMPED_ROUND_NUMBER * 1500);
        }
		tomahawk.low_level_instant_kill_charge = tomahawk.low_level_instant_kill_charge + 1;
		return n_target_zombie.health + 1;
	}
    if(isplayer(n_target_zombie))
    {
        return int(CLAMPED_ROUND_NUMBER * 1000);
    }
	return 1000 * n_tomahawk_power;
}

zm_prison_tomahawk_hit_zombie(ai_zombie, grenade)
{
	self endon(#disconnect);
	if(isdefined(ai_zombie) && isalive(ai_zombie) && (!isplayer(ai_zombie) || ai_zombie.sessionstate == "playing"))
	{
		tag = "J_Head";
		if(ai_zombie.isdog)
		{
			tag = "J_Spine1";
		}
		v_target = ai_zombie gettagorigin(tag);
		grenade moveto(v_target, 0.3);
		grenade util::waittill_any_timeout(3, "movedone");
		if(isdefined(ai_zombie) && isalive(ai_zombie) && (!isplayer(ai_zombie) || ai_zombie.sessionstate == "playing"))
		{
			if(self.current_tactical_grenade.name == "t6_upgraded_tomahawk")
			{
				playfxontag(level._effect["tomahawk_impact_ug"], ai_zombie, tag);
			}
			else
			{
				playfxontag(level._effect["tomahawk_impact"], ai_zombie, tag);
			}
			ai_zombie clientfield::set("play_tomahawk_hit_sound", 1);
			n_tomahawk_damage = zm_prison_calculate_tomahawk_damage(ai_zombie, grenade.n_grenade_charge_power, grenade);
			ai_zombie dodamage(n_tomahawk_damage, grenade.origin, self, grenade, "none", "MOD_UNKNOWN", 0, getweapon("t6_bouncing_tomahawk"));
			ai_zombie.hit_by_tomahawk = 1;
			self zm_score::add_to_player_score(10);
		}
	}
}

zm_prison_tomahawk_check_for_zombie(grenade)
{
	self endon(#disconnect);
	grenade endon(#death);
	zombies = zombie_utility::get_round_enemy_array();
	boss = getaiarchetypearray("brutus");
	a_zombies = arraycombine(zombies, boss, 1, 1);
    foreach(player in getplayers())
    {
        if(self == player || self.team == player.team)
        {
            continue;
        }
        if(player.sessionstate != "playing")
        {
            continue;
        }
        // if(!sighttracepassed(player geteye(), grenade.origin, false, grenade))
        // {
        //     continue;
        // }
        a_zombies[a_zombies.size] = player;
    }
	a_zombies = util::get_array_of_closest(grenade.origin, a_zombies, undefined, undefined, 100);
	if(isdefined(a_zombies[0]) && distance2dsquared(grenade.origin, a_zombies[0].origin) <= 10000)
	{
		if(isdefined(a_zombies[0].hit_by_tomahawk) && !a_zombies[0].hit_by_tomahawk)
		{
			self zm_prison_tomahawk_hit_zombie(a_zombies[0], grenade);
		}
	}
}

zm_prison_tomahawk_return_player(m_tomahawk, num_zombie_hit)
{
	self endon(#disconnect);
	n_dist = distance2dsquared(m_tomahawk.origin, self.origin);
	if(!isdefined(num_zombie_hit))
	{
		num_zombie_hit = 5;
	}
	while(n_dist > 4096)
	{
		m_tomahawk moveto(self geteye(), 0.25);
		if(num_zombie_hit < 5)
		{
			self zm_prison_tomahawk_check_for_zombie(m_tomahawk);
			num_zombie_hit++;
		}
		wait(0.1);
		n_dist = distance2dsquared(m_tomahawk.origin, self geteye());
	}
	if(isdefined(m_tomahawk.a_has_powerup))
	{
		foreach(powerup in m_tomahawk.a_has_powerup)
		{
			if(isdefined(powerup))
			{
				powerup.origin = self.origin;
			}
		}
	}
	m_tomahawk delete();
	self playsoundtoplayer("wpn_tomahawk_catch_plr", self);
	self playsound("wpn_tomahawk_catch_npc");
	wait(5);
	self playsoundtoplayer("wpn_tomahawk_cooldown", self);
	self givemaxammo(self.current_tomahawk_weapon);
	zombies = zombie_utility::get_round_enemy_array();
	boss = getaiarchetypearray("brutus");
	a_zombies = arraycombine(zombies, boss, 1, 1);
	foreach(ai_zombie in a_zombies)
	{
		ai_zombie.hit_by_tomahawk = 0;
	}
    foreach(player in getplayers())
    {
        player.hit_by_tomahawk = 0;
    }
	self clientfield::set_to_player("tomahawk_in_use", 3);
}

// TODO: test claymore
// TODO: test tomahawk
zm_prison_init()
{

}

#define AFTERLIFE_HP_PER_ROUND = 1000;
zm_prison_weapons()
{
    register_box_weapon("spork_zm_alcatraz", "spork_zm_alcatraz");

    register_weapon_damage_callback("t6_xl_shockhands", undefined, function(eInflictor, attacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime) =>
    {
        if(self.afterlife is true)
        {
            return;
        }
        self thread Try_Respawn(true);
    });

    register_weapon_calculator("t6_xl_shockhands", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) => 
    {
        if(self.afterlife is true)
        {
            return int(CLAMPED_ROUND_NUMBER * AFTERLIFE_HP_PER_ROUND / 2);
        }
        return int(self.maxhealth * 0.12);
    });

    register_weapon_calculator("claymore", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) => 
    {
        return int(CLAMPED_ROUND_NUMBER * 2500);
    });

    set_level_olympia("t6_olympia", "t6_olympia_up");

    level.fn_check_damage_custom = function(eInflictor, attacker, result, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime) => 
    {
        if(weapon == getweapon("tower_trap"))
        {
            if(self hasperk("specialty_armorvest"))
            {
                return 1;
            }
            return self.health + 666;
        }
        return result;
    };

    level.fn_custom_melee_cap_calc = function(weap) =>
    {
        if(weap == "spork_zm_alcatraz")
        {
            return 35000;
        }
        return MAX_MELEE_DAMAGE;
    };

    register_weapon_calculator("t8_shotgun_acidgat_explosive", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) => 
    {
        return int(CLAMPED_ROUND_NUMBER * 500);
    });
}

zm_prison_threaded()
{
    plane_craftable = getent("plane_craftable", "targetname");
    plane_craftable showpart("tag_support_upper");
    plane_craftable showpart("tag_wing_skins_up");
    plane_craftable showpart("tag_engines_up");
    plane_craftable showpart("tag_feul_tanks");
    plane_craftable showpart("tag_control_mechanism");
    plane_craftable showpart("tag_fuel_hose");
    getent("plane_craftable", "targetname") show();
    level flag::set("plane_crafted");
    level flag::set("dreamcatchers_filled");
    level flag::set("key_obtained");
    level clientfield::set("zm_mob_wardens_key_obtained", 1);
    for(i = 1; i < 6; i++)
    {
        level thread [[ @namespace_4823994c<scripts\zm\zm_prison_plane_quest.gsc>::open_custom_door_master_key ]](i, level.players[0]);
    }
    level thread [[ function() => 
    {
        level endon(#end_game);
        for(;;)
        {
            level flag::set("plane_refueled");
            level flag::set("plane_built");
            level.n_plane_fuel_count = 5;
            level.global_brutus_powerup_prevention = 0;
            t_plane_fly = getent("plane_fly_trigger", "targetname");
		    t_plane_fly triggerenable(1);
            getent("plane_craftable", "targetname") show();
            wait 0.05;
        }
    }]]();
    
    // autocraft plane buildable
    foreach(trig in getentarray("afterlife_interact", "targetname"))
    {
        trig notify(#damage, 1, level);
    }
    
    getent("dryer_trigger", "targetname").origin = ORIGIN_OOB;
}
#endregion

autoexec fuck_danny()
{
    if(tolower(getdvarstring("mapname")) == "zm_tranzit_remastered" || tolower(getdvarstring("mapname")) == "zm_tranzit_event")
    {
        compiler::script_detour("scripts/zm/zm_tranzit_remastered.gsc", #namespace_6b68908c, #function_ea8ef366, function() => {});
        compiler::script_detour("scripts/zm/zm_tranzit_event.gsc", #namespace_38736ee2, #function_ea8ef366, function() => {});
    }
}

#endregion
// #pragma lazystrings(off)