#using scripts\shared\duplicaterender_mgr;
#insert scripts/shared/clientfield_shared.gsh;

#namespace clientfield;

// this file basically contains a ton of fixes for the clientfield update feature in the game
// basically a clientfield can be updated with the same value as it was previously if a player switches spectator clients or respawns
// it seems as though many treyarch devs did not understand this feature and left clientfield updates spawning effects that get orphaned
// to combat this, a stateful array is created on objects and the level to manually track and prevent clientfield updates from firing duplicate effect and scene spawns.

function register_cm(str_pool_name, str_name, n_version, n_bits, str_type, func_callback, b_host, b_callback_for_zero_when_new)
{
    switch(tolower(getdvarstring("mapname")))
    {
        case "zm_leviathan":
            switch(str_name)
            {
                REFIELD_SAFETY_WRAP("WearingPes", WearingPes)
                REFIELD_SAFETY_WRAP("Flashlight", Flashlight)
            }
        break;
    }
    return func_callback;
}

function empty_clientfield_callback(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
}

function zombie_zombie_keyline_render_clientfield_cb(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(!isdefined(newval))
	{
		return;
	}
	// if(isdefined(level.debug_keyline_zombies) && level.debug_keyline_zombies)
	// {
	// 	if(newval)
	// 	{
	// 		self duplicate_render::set_dr_flag("keyline_active", 1);
	// 		self duplicate_render::update_dr_filters(localclientnum);
	// 	}
	// 	else
	// 	{
	// 		self duplicate_render::set_dr_flag("keyline_active", 0);
	// 		self duplicate_render::update_dr_filters(localclientnum);
	// 	}
	// }
    // if(self isplayer() && (self != getlocalplayer(localclientnum)))
    // {
    //     self duplicate_render::set_dr_flag("keyline_active", (getlocalplayer(localclientnum).gm_id === self.gm_id) && isdefined(self.gm_id));
	//     self duplicate_render::update_dr_filters(localclientnum);
    // }
}

function laststand_callback(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    if(self isplayer() && self islocalplayer() && !isdemoplaying())
	{
		if(isdefined(self getlocalclientnumber()) && localclientnum == self getlocalclientnumber())
		{
			self sndzmblaststand(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump);
		}
	}
}

function sndzmblaststand(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval)
	{
		playsound(localclientnum, "chr_health_laststand_enter", (0, 0, 0));
		self.inlaststand = 1;
		setsoundcontext("laststand", "active");
		if(!issplitscreen())
		{
			forceambientroom("sndHealth_LastStand");
		}
	}
	else
	{
		if(isdefined(self.inlaststand) && self.inlaststand)
		{
			playsound(localclientnum, "chr_health_laststand_exit", (0, 0, 0));
			self.inlaststand = 0;
			if(!issplitscreen())
			{
				forceambientroom("");
			}
		}
		setsoundcontext("laststand", "");
	}
}

function autoexec setup_doacheck()
{
    level.zbr_is_doa = (tolower(getdvarstring("mapname")) == "cp_doa_bo3");
}

function register(str_pool_name, str_name, n_version, n_bits, str_type, func_callback, b_host, b_callback_for_zero_when_new)
{
    if(!isdefined(str_name))
    {
        return;
    }
    if(!isdefined(level._cscfieldwrappers))
    {
        level._cscfieldwrappers = [];
        level._cscfieldwrapperstates = [];
    }

    if("deadshot_perk" == str_name || "apothicon_player_keyline" == str_name)
    {
        func_callback = &empty_clientfield_callback;
    }

    if("start_destructible_explosion" == str_name && level.zbr_is_doa)
    {
        n_bits = 11;
    }

    if("zombie_keyline_render" == str_name)
    {
        func_callback = &zombie_zombie_keyline_render_clientfield_cb;
    }

    if("zmbLastStand" == str_name)
    {
        func_callback = &laststand_callback;
    }

    switch(tolower(getdvarstring("mapname")))
    {
        case "zm_zod":
            switch(str_name)
            {
                REFIELD_SAFETY_WRAP("junction_crane_state", junction_crane_state)
                REFIELD_SAFETY_WRAP("ee_keeper_boxer_state", ee_keeper_boxer_state)
                REFIELD_SAFETY_WRAP("ee_keeper_detective_state", ee_keeper_detective_state)
                REFIELD_SAFETY_WRAP("ee_keeper_femme_state", ee_keeper_femme_state)
                REFIELD_SAFETY_WRAP("ee_keeper_magician_state", ee_keeper_magician_state)
                REFIELD_SAFETY_WRAP("perk_light_speed_cola", perk_light_speed_cola)
                REFIELD_SAFETY_WRAP("perk_light_juggernog", perk_light_juggernog)
                REFIELD_SAFETY_WRAP("perk_light_doubletap", perk_light_doubletap)
                REFIELD_SAFETY_WRAP("perk_light_quick_revive", perk_light_quick_revive)
                REFIELD_SAFETY_WRAP("perk_light_widows_wine", perk_light_widows_wine)
                REFIELD_SAFETY_WRAP("perk_light_mule_kick", perk_light_mule_kick)
                REFIELD_SAFETY_WRAP("perk_light_staminup", perk_light_staminup)
                REFIELD_SAFETY_WRAP("perk_bottle_speed_cola_fx", perk_bottle_speed_cola_fx)
                REFIELD_SAFETY_WRAP("perk_bottle_juggernog_fx", perk_bottle_juggernog_fx)
                REFIELD_SAFETY_WRAP("perk_bottle_doubletap_fx", perk_bottle_doubletap_fx)
                REFIELD_SAFETY_WRAP("player_stargate_fx", player_stargate_fx)
                REFIELD_SAFETY_WRAP("portal_state_canal", portal_state_canal)
                REFIELD_SAFETY_WRAP("portal_state_slums", portal_state_slums)
                REFIELD_SAFETY_WRAP("portal_state_theater", portal_state_theater)
                REFIELD_SAFETY_WRAP("portal_state_ending", portal_state_ending)
                REFIELD_SAFETY_WRAP("pulse_canal_portal_top", pulse_canal_portal_top)
                REFIELD_SAFETY_WRAP("pulse_canal_portal_bottom", pulse_canal_portal_bottom)
                REFIELD_SAFETY_WRAP("pulse_slums_portal_top", pulse_slums_portal_top)
                REFIELD_SAFETY_WRAP("pulse_slums_portal_bottom", pulse_slums_portal_bottom)
                REFIELD_SAFETY_WRAP("pulse_theater_portal_top", pulse_theater_portal_top)
                REFIELD_SAFETY_WRAP("pulse_theater_portal_bottom", pulse_theater_portal_bottom)
                REFIELD_SAFETY_WRAP("devgui_lightning_test", devgui_lightning_test)
                REFIELD_SAFETY_WRAP("ee_quest_state", ee_quest_state)
                REFIELD_SAFETY_WRAP("ee_shadowman_battle_active", ee_shadowman_battle_active)
                REFIELD_SAFETY_WRAP("ee_superworm_state", ee_superworm_state)
                REFIELD_SAFETY_WRAP("ee_keeper_beam_state", ee_keeper_beam_state)
                REFIELD_SAFETY_WRAP("ritual_state_pap", ritual_state_pap)
                REFIELD_SAFETY_WRAP("keeper_spawn_portals", keeper_spawn_portals)
                REFIELD_SAFETY_WRAP("wallrun_footprints", wallrun_footprints)
                REFIELD_SAFETY_WRAP("keeper_quest_state_0", keeper_quest_state_0)
                REFIELD_SAFETY_WRAP("keeper_quest_state_1", keeper_quest_state_1)
                REFIELD_SAFETY_WRAP("keeper_quest_state_2", keeper_quest_state_2)
                REFIELD_SAFETY_WRAP("keeper_quest_state_3", keeper_quest_state_3)
                REFIELD_SAFETY_WRAP("keeper_egg_location_0", keeper_egg_location_0)
                REFIELD_SAFETY_WRAP("keeper_egg_location_1", keeper_egg_location_1)
                REFIELD_SAFETY_WRAP("keeper_egg_location_2", keeper_egg_location_2)
                REFIELD_SAFETY_WRAP("keeper_egg_location_3", keeper_egg_location_3)
                REFIELD_SAFETY_WRAP("sndTrainVox", sndTrainVox)
                REFIELD_SAFETY_WRAP("ritual_state_boxer", ritual_state_boxer)
                REFIELD_SAFETY_WRAP("ritual_state_detective", ritual_state_detective)
                REFIELD_SAFETY_WRAP("ritual_state_femme", ritual_state_femme)
                REFIELD_SAFETY_WRAP("ritual_state_magician", ritual_state_magician)
                REFIELD_SAFETY_WRAP("set_subway_wall_dissolve", set_subway_wall_dissolve)
                REFIELD_SAFETY_WRAP("magic_circle_state_0", magic_circle_state_0)
                REFIELD_SAFETY_WRAP("magic_circle_state_1", magic_circle_state_1)
                REFIELD_SAFETY_WRAP("magic_circle_state_2", magic_circle_state_2)
                REFIELD_SAFETY_WRAP("magic_circle_state_3", magic_circle_state_3)

                REFIELD_SAFETY_WRAP("robot_switch", robot_switch)
                REFIELD_SAFETY_WRAP("zod_egg_glow", zod_egg_glow)
                REFIELD_SAFETY_WRAP("blood_soul_fx", blood_soul_fx)
                REFIELD_SAFETY_WRAP("sword_statue_glow", sword_statue_glow)
                REFIELD_SAFETY_WRAP("train_switch_light", train_switch_light)
                REFIELD_SAFETY_WRAP("train_map_light", train_map_light)
                REFIELD_SAFETY_WRAP("trap_chain_state", trap_chain_state)
                REFIELD_SAFETY_WRAP("update_fungus_pod_level", update_fungus_pod_level)
                REFIELD_SAFETY_WRAP("pod_sprayer_glint", pod_sprayer_glint)
                REFIELD_SAFETY_WRAP("pod_miasma", pod_miasma)
                REFIELD_SAFETY_WRAP("pod_harvest", pod_harvest)
                REFIELD_SAFETY_WRAP("pod_self_destruct", pod_self_destruct)
                REFIELD_SAFETY_WRAP("shadowman_fx", shadowman_fx)
                REFIELD_SAFETY_WRAP("gateworm_basin_fx", gateworm_basin_fx)
                REFIELD_SAFETY_WRAP("train_callbox_light", train_callbox_light)
            }
        break;
        case "zm_factory":
            switch(str_name)
            {
                REFIELD_SAFETY_WRAP("console_blue", console_blue)
                REFIELD_SAFETY_WRAP("console_green", console_green)
                REFIELD_SAFETY_WRAP("console_red", console_red)
                REFIELD_SAFETY_WRAP("console_start", console_start)
            }
        break;
        case "zm_castle":
            switch(str_name)
            {
                REFIELD_SAFETY_WRAP("snd_low_gravity_state", snd_low_gravity_state)
                REFIELD_SAFETY_WRAP("sndRocketAlarm", sndRocketAlarm)
                REFIELD_SAFETY_WRAP("sndRocketTrap", sndRocketTrap)
                REFIELD_SAFETY_WRAP("snd_tram", snd_tram)

                REFIELD_SAFETY_WRAP("craftable_powerup_fx", craftable_powerup_fx)
                REFIELD_SAFETY_WRAP("craftable_teleport_fx", craftable_teleport_fx)
                REFIELD_SAFETY_WRAP("flinger_flying_postfx", flinger_flying_postfx)
                REFIELD_SAFETY_WRAP("flinger_land_smash", flinger_land_smash)
                REFIELD_SAFETY_WRAP("flinger_pad_active_fx", flinger_pad_active_fx)
                REFIELD_SAFETY_WRAP("player_postfx", player_postfx)
                REFIELD_SAFETY_WRAP("tram_fuse_fx", tram_fuse_fx)
                REFIELD_SAFETY_WRAP("bow_pickup_fx", bow_pickup_fx)
                REFIELD_SAFETY_WRAP("urn_impact_fx", urn_impact_fx)
                REFIELD_SAFETY_WRAP("tower_break_fx", tower_break_fx)
                REFIELD_SAFETY_WRAP("arrow_charge_wolf_fx", arrow_charge_wolf_fx)
            }
        break;
        case "zm_island":
            switch(str_name)
            {
                REFIELD_SAFETY_WRAP("play_dogfight_scenes", play_dogfight_scenes) // goodbye hilarious bug </3
                REFIELD_SAFETY_WRAP("lower_pap_water", lower_pap_water)
                REFIELD_SAFETY_WRAP("power_switch_1_fx", power_switch_1_fx)
                REFIELD_SAFETY_WRAP("power_switch_2_fx", power_switch_2_fx)
                REFIELD_SAFETY_WRAP("penstock_fx_anim", penstock_fx_anim)
                REFIELD_SAFETY_WRAP("skullquest_ritual_1_fx", skullquest_ritual_1_fx)
                REFIELD_SAFETY_WRAP("skullquest_ritual_2_fx", skullquest_ritual_2_fx)
                REFIELD_SAFETY_WRAP("skullquest_ritual_3_fx", skullquest_ritual_3_fx)
                REFIELD_SAFETY_WRAP("skullquest_ritual_4_fx", skullquest_ritual_4_fx)
                REFIELD_SAFETY_WRAP("proptrap_downdraft_rumble", proptrap_downdraft_rumble)
                REFIELD_SAFETY_WRAP("walltrap_draft_rumble", walltrap_draft_rumble)

                REFIELD_SAFETY_WRAP("challenge_glow_fx", challenge_glow_fx)
                REFIELD_SAFETY_WRAP("lightning_shield_fx", lightning_shield_fx)
                REFIELD_SAFETY_WRAP("smoke_trail_fx", smoke_trail_fx)
                REFIELD_SAFETY_WRAP("smoke_smolder_fx", smoke_smolder_fx)
                REFIELD_SAFETY_WRAP("bgb_lightning_fx", bgb_lightning_fx)
                REFIELD_SAFETY_WRAP("perk_lightning_fx", perk_lightning_fx)
                REFIELD_SAFETY_WRAP("show_part", show_part)
                REFIELD_SAFETY_WRAP("plant_growth_siege_anims", plant_growth_siege_anims)
                REFIELD_SAFETY_WRAP("plant_hit_with_ww_fx", plant_hit_with_ww_fx)
                REFIELD_SAFETY_WRAP("plant_watered_fx", plant_watered_fx)
                REFIELD_SAFETY_WRAP("babysitter_plant_fx", babysitter_plant_fx)
                REFIELD_SAFETY_WRAP("trap_plant_fx", trap_plant_fx)
                REFIELD_SAFETY_WRAP("player_cloned_fx", player_cloned_fx)
                REFIELD_SAFETY_WRAP("zombie_or_grenade_spawned_from_minor_cache_plant", zombie_or_grenade_spawned_from_minor_cache_plant)
                REFIELD_SAFETY_WRAP("player_vomit_fx", player_vomit_fx)
                REFIELD_SAFETY_WRAP("golden_bucket_glow_fx", golden_bucket_glow_fx)
                REFIELD_SAFETY_WRAP("skullquest_finish_start_fx", skullquest_finish_start_fx)
                REFIELD_SAFETY_WRAP("skullquest_finish_trail_fx", skullquest_finish_trail_fx)
                REFIELD_SAFETY_WRAP("skullquest_finish_end_fx", skullquest_finish_end_fx)
                REFIELD_SAFETY_WRAP("skullquest_finish_done_glow_fx", skullquest_finish_done_glow_fx)
                REFIELD_SAFETY_WRAP("sewer_current_fx", sewer_current_fx)
                REFIELD_SAFETY_WRAP("proptrap_downdraft_blur", proptrap_downdraft_blur)
                REFIELD_SAFETY_WRAP("walltrap_draft_blur", walltrap_draft_blur)
                REFIELD_SAFETY_WRAP("play_underwater_plant_fx", play_underwater_plant_fx)
                REFIELD_SAFETY_WRAP("play_carrier_fx", play_carrier_fx)
                REFIELD_SAFETY_WRAP("play_vial_fx", play_vial_fx)
                REFIELD_SAFETY_WRAP("spider_bait", spider_bait)
                REFIELD_SAFETY_WRAP("vine_door_play_fx", vine_door_play_fx)
            }
        break;
        case "zm_stalingrad":
            switch(str_name)
            {
                REFIELD_SAFETY_WRAP("tp_water_sheeting", tp_water_sheeting)
                REFIELD_SAFETY_WRAP("pr_g_c_fx", pr_g_c_fx)
            }
        break;
        case "zm_genesis":
            switch(str_name)
            {
                // ent
                REFIELD_SAFETY_WRAP("being_keeper_revived", being_keeper_revived)
                REFIELD_SAFETY_WRAP("keeper_reviving", keeper_reviving)
                REFIELD_SAFETY_WRAP("kc_effects", kc_effects)
                REFIELD_SAFETY_WRAP("flinger_flying_postfx", flinger_flying_postfx)
                REFIELD_SAFETY_WRAP("emit_smoke", emit_smoke)
                REFIELD_SAFETY_WRAP("fire_trap", fire_trap)
            }
        break;
        case "zm_tomb":
            switch(str_name)
            {
                // world

                // ent
                REFIELD_SAFETY_WRAP("glow_biplane_trail_fx", glow_biplane_trail_fx)
                REFIELD_SAFETY_WRAP("element_glow_fx", element_glow_fx)
                REFIELD_SAFETY_WRAP("plane_fx", plane_fx)
                REFIELD_SAFETY_WRAP("zeppelin_fx", zeppelin_fx)
                REFIELD_SAFETY_WRAP("magicbox_open_fx", magicbox_open_fx)
                REFIELD_SAFETY_WRAP("magicbox_amb_fx", magicbox_amb_fx)
            }
        break;

        default:
            func_callback = register_cm(str_pool_name, str_name, n_version, n_bits, str_type, func_callback, b_host, b_callback_for_zero_when_new);
    }

    switch(str_name)
    {
        REFIELD_SAFETY_WRAP("toggle_black_hole_being_pulled", toggle_black_hole_being_pulled)
        REFIELD_SAFETY_WRAP("player_cocooned_fx", player_cocooned_fx)
        REFIELD_SAFETY_WRAP("dragon_strike_flare_fx", dragon_strike_flare_fx)
        REFIELD_SAFETY_WRAP("dragon_strike_spawn_fx", dragon_strike_spawn_fx)
        REFIELD_SAFETY_WRAP("elemental_bow_arrow_impact_fx", elemental_bow_arrow_impact_fx)
        REFIELD_SAFETY_WRAP("elemental_bow4_arrow_impact_fx", elemental_bow4_arrow_impact_fx)
        REFIELD_SAFETY_WRAP("elemental_bow_demongate_arrow_impact_fx", elemental_bow_demongate_arrow_impact_fx)
        REFIELD_SAFETY_WRAP("elemental_bow_demongate4_arrow_impact_fx", elemental_bow_demongate4_arrow_impact_fx)
        REFIELD_SAFETY_WRAP("demongate_portal_fx", demongate_portal_fx)
        REFIELD_SAFETY_WRAP("elemental_bow_rune_prison_arrow_impact_fx", elemental_bow_rune_prison_arrow_impact_fx)
        REFIELD_SAFETY_WRAP("elemental_bow_rune_prison4_arrow_impact_fx", elemental_bow_rune_prison4_arrow_impact_fx)
        REFIELD_SAFETY_WRAP("runeprison_rock_fx", runeprison_rock_fx)
        REFIELD_SAFETY_WRAP("runeprison_explode_fx", runeprison_explode_fx)
        REFIELD_SAFETY_WRAP("runeprison_lava_geyser_fx", runeprison_lava_geyser_fx)
        REFIELD_SAFETY_WRAP("runeprison_lava_geyser_dot_fx", runeprison_lava_geyser_dot_fx)
        REFIELD_SAFETY_WRAP("runeprison_zombie_death_skull", runeprison_zombie_death_skull)
        REFIELD_SAFETY_WRAP("elemental_bow_storm_arrow_impact_fx", elemental_bow_storm_arrow_impact_fx)
        REFIELD_SAFETY_WRAP("elemental_bow_storm4_arrow_impact_fx", elemental_bow_storm4_arrow_impact_fx)
        REFIELD_SAFETY_WRAP("elem_storm_fx", elem_storm_fx)
        REFIELD_SAFETY_WRAP("elem_storm_whirlwind_rumble", elem_storm_whirlwind_rumble)
        REFIELD_SAFETY_WRAP("elem_storm_zap_ambient", elem_storm_zap_ambient)
        REFIELD_SAFETY_WRAP("elemental_bow_wolf_howl_arrow_impact_fx", elemental_bow_wolf_howl_arrow_impact_fx)
        REFIELD_SAFETY_WRAP("elemental_bow_wolf_howl4_arrow_impact_fx", elemental_bow_wolf_howl4_arrow_impact_fx)
        REFIELD_SAFETY_WRAP("wolf_howl_arrow_charged_trail", wolf_howl_arrow_charged_trail)
        REFIELD_SAFETY_WRAP("wolf_howl_arrow_charged_spiral", wolf_howl_arrow_charged_spiral)
        REFIELD_SAFETY_WRAP("gravity_trap_fx", gravity_trap_fx)
        REFIELD_SAFETY_WRAP("gravity_trap_spike_spark", gravity_trap_spike_spark)
        REFIELD_SAFETY_WRAP("gravity_trap_location", gravity_trap_location)
        REFIELD_SAFETY_WRAP("sparky_beam_fx", sparky_beam_fx)
        REFIELD_SAFETY_WRAP("sparky_zombie_fx", sparky_zombie_fx)
        REFIELD_SAFETY_WRAP("sparky_zombie_trail_fx", sparky_zombie_trail_fx)
        REFIELD_SAFETY_WRAP("death_ray_shock_eye_fx", death_ray_shock_eye_fx)
        REFIELD_SAFETY_WRAP("skull_beam_fx", skull_beam_fx)
        REFIELD_SAFETY_WRAP("skull_torch_fx", skull_torch_fx)
        REFIELD_SAFETY_WRAP("skull_beam_3p_fx", skull_beam_3p_fx)
        REFIELD_SAFETY_WRAP("skull_torch_3p_fx", skull_torch_3p_fx)
        REFIELD_SAFETY_WRAP("mirg2000_fire_button_held_sound", mirg2000_fire_button_held_sound)
        REFIELD_SAFETY_WRAP("mirg2000_charge_glow", mirg2000_charge_glow)
        REFIELD_SAFETY_WRAP("octobomb_spores_fx", octobomb_spores_fx)
        REFIELD_SAFETY_WRAP("octobomb_tentacle_hit_fx", octobomb_tentacle_hit_fx)
        REFIELD_SAFETY_WRAP("slow_vortex_fx", slow_vortex_fx)
        REFIELD_SAFETY_WRAP("ai_slow_vortex_fx", ai_slow_vortex_fx)
        REFIELD_SAFETY_WRAP("whirlwind_play_fx", whirlwind_play_fx)
        REFIELD_SAFETY_WRAP("being_robot_revived", being_robot_revived)
        REFIELD_SAFETY_WRAP("lightning_impact_fx", lightning_impact_fx)
        REFIELD_SAFETY_WRAP("lightning_miss_fx", lightning_miss_fx)
        REFIELD_SAFETY_WRAP("lightning_arc_fx", lightning_arc_fx)
        REFIELD_SAFETY_WRAP("staff_blizzard_fx", staff_blizzard_fx)
        REFIELD_SAFETY_WRAP("attach_bullet_model", attach_bullet_model)
        REFIELD_SAFETY_WRAP("staff_shatter_fx", staff_shatter_fx)
        REFIELD_SAFETY_WRAP("vortex_start", vortex_start)
    }
    
	registerclientfield(str_pool_name, str_name, n_version, n_bits, str_type, func_callback, b_host, b_callback_for_zero_when_new);
}

// START GENERAL
//

REFIELD_SAFETY_FN_ENT("toggle_black_hole_being_pulled", toggle_black_hole_being_pulled)
REFIELD_SAFETY_FN_ENT("player_cocooned_fx", player_cocooned_fx)
REFIELD_SAFETY_FN_ENT("dragon_strike_flare_fx", dragon_strike_flare_fx)
REFIELD_SAFETY_FN_ENT("dragon_strike_spawn_fx", dragon_strike_spawn_fx)
REFIELD_SAFETY_FN_ENT("elemental_bow_arrow_impact_fx", elemental_bow_arrow_impact_fx)
REFIELD_SAFETY_FN_ENT("elemental_bow4_arrow_impact_fx", elemental_bow4_arrow_impact_fx)
REFIELD_SAFETY_FN_ENT("elemental_bow_demongate_arrow_impact_fx", elemental_bow_demongate_arrow_impact_fx)
REFIELD_SAFETY_FN_ENT("elemental_bow_demongate4_arrow_impact_fx", elemental_bow_demongate4_arrow_impact_fx)
REFIELD_SAFETY_FN_ENT("demongate_portal_fx", demongate_portal_fx)
REFIELD_SAFETY_FN_ENT("elemental_bow_rune_prison_arrow_impact_fx", elemental_bow_rune_prison_arrow_impact_fx)
REFIELD_SAFETY_FN_ENT("elemental_bow_rune_prison4_arrow_impact_fx", elemental_bow_rune_prison4_arrow_impact_fx)
REFIELD_SAFETY_FN_ENT("runeprison_rock_fx", runeprison_rock_fx)
REFIELD_SAFETY_FN_ENT("runeprison_explode_fx", runeprison_explode_fx)
REFIELD_SAFETY_FN_ENT("runeprison_lava_geyser_fx", runeprison_lava_geyser_fx)
REFIELD_SAFETY_FN_ENT("runeprison_lava_geyser_dot_fx", runeprison_lava_geyser_dot_fx)
REFIELD_SAFETY_FN_ENT("runeprison_zombie_death_skull", runeprison_zombie_death_skull)
REFIELD_SAFETY_FN_ENT("elemental_bow_storm_arrow_impact_fx", elemental_bow_storm_arrow_impact_fx)
REFIELD_SAFETY_FN_ENT("elemental_bow_storm4_arrow_impact_fx", elemental_bow_storm4_arrow_impact_fx)
REFIELD_SAFETY_FN_ENT("elem_storm_fx", elem_storm_fx)
REFIELD_SAFETY_FN_ENT("elem_storm_whirlwind_rumble", elem_storm_whirlwind_rumble)
REFIELD_SAFETY_FN_ENT("elem_storm_zap_ambient", elem_storm_zap_ambient)
REFIELD_SAFETY_FN_ENT("elemental_bow_wolf_howl_arrow_impact_fx", elemental_bow_wolf_howl_arrow_impact_fx)
REFIELD_SAFETY_FN_ENT("elemental_bow_wolf_howl4_arrow_impact_fx", elemental_bow_wolf_howl4_arrow_impact_fx)
REFIELD_SAFETY_FN_ENT("wolf_howl_arrow_charged_trail", wolf_howl_arrow_charged_trail)
REFIELD_SAFETY_FN_ENT("wolf_howl_arrow_charged_spiral", wolf_howl_arrow_charged_spiral)
REFIELD_SAFETY_FN_ENT("gravity_trap_fx", gravity_trap_fx)
REFIELD_SAFETY_FN_ENT("gravity_trap_spike_spark", gravity_trap_spike_spark)
REFIELD_SAFETY_FN_ENT("gravity_trap_location", gravity_trap_location)
REFIELD_SAFETY_FN_ENT("sparky_beam_fx", sparky_beam_fx)
REFIELD_SAFETY_FN_ENT("sparky_zombie_fx", sparky_zombie_fx)
REFIELD_SAFETY_FN_ENT("sparky_zombie_trail_fx", sparky_zombie_trail_fx)
REFIELD_SAFETY_FN_ENT("death_ray_shock_eye_fx", death_ray_shock_eye_fx)
REFIELD_SAFETY_FN_ENT("skull_beam_fx", skull_beam_fx)
REFIELD_SAFETY_FN_ENT("skull_torch_fx", skull_torch_fx)
REFIELD_SAFETY_FN_ENT("skull_beam_3p_fx", skull_beam_3p_fx)
REFIELD_SAFETY_FN_ENT("skull_torch_3p_fx", skull_torch_3p_fx)
REFIELD_SAFETY_FN_ENT("mirg2000_fire_button_held_sound", mirg2000_fire_button_held_sound)
REFIELD_SAFETY_FN_ENT("mirg2000_charge_glow", mirg2000_charge_glow)
REFIELD_SAFETY_FN_ENT("octobomb_spores_fx", octobomb_spores_fx)
REFIELD_SAFETY_FN_ENT("octobomb_tentacle_hit_fx", octobomb_tentacle_hit_fx)
REFIELD_SAFETY_FN_ENT("slow_vortex_fx", slow_vortex_fx)
REFIELD_SAFETY_FN_ENT("ai_slow_vortex_fx", ai_slow_vortex_fx)
REFIELD_SAFETY_FN_ENT("whirlwind_play_fx", whirlwind_play_fx)
REFIELD_SAFETY_FN_ENT("being_robot_revived", being_robot_revived)
REFIELD_SAFETY_FN_ENT("lightning_impact_fx", lightning_impact_fx)
REFIELD_SAFETY_FN_ENT("lightning_miss_fx", lightning_miss_fx)
REFIELD_SAFETY_FN_ENT("lightning_arc_fx", lightning_arc_fx)
REFIELD_SAFETY_FN_ENT("staff_blizzard_fx", staff_blizzard_fx)
REFIELD_SAFETY_FN_ENT("attach_bullet_model", attach_bullet_model)
REFIELD_SAFETY_FN_ENT("staff_shatter_fx", staff_shatter_fx)
REFIELD_SAFETY_FN_ENT("vortex_start", vortex_start)
// END GENERAL

// START ZM_ZOD
REFIELD_SAFETY_FN("junction_crane_state", junction_crane_state)
REFIELD_SAFETY_FN("ee_keeper_boxer_state", ee_keeper_boxer_state)
REFIELD_SAFETY_FN("ee_keeper_detective_state", ee_keeper_detective_state)
REFIELD_SAFETY_FN("ee_keeper_femme_state", ee_keeper_femme_state)
REFIELD_SAFETY_FN("ee_keeper_magician_state", ee_keeper_magician_state)
REFIELD_SAFETY_FN("perk_light_speed_cola", perk_light_speed_cola)
REFIELD_SAFETY_FN("perk_light_juggernog", perk_light_juggernog)
REFIELD_SAFETY_FN("perk_light_doubletap", perk_light_doubletap)
REFIELD_SAFETY_FN("perk_light_quick_revive", perk_light_quick_revive)
REFIELD_SAFETY_FN("perk_light_widows_wine", perk_light_widows_wine)
REFIELD_SAFETY_FN("perk_light_mule_kick", perk_light_mule_kick)
REFIELD_SAFETY_FN("perk_light_staminup", perk_light_staminup)
REFIELD_SAFETY_FN("perk_bottle_speed_cola_fx", perk_bottle_speed_cola_fx)
REFIELD_SAFETY_FN("perk_bottle_juggernog_fx", perk_bottle_juggernog_fx)
REFIELD_SAFETY_FN("perk_bottle_doubletap_fx", perk_bottle_doubletap_fx)
REFIELD_SAFETY_FN("player_stargate_fx", player_stargate_fx)
REFIELD_SAFETY_FN("portal_state_canal", portal_state_canal)
REFIELD_SAFETY_FN("portal_state_slums", portal_state_slums)
REFIELD_SAFETY_FN("portal_state_theater", portal_state_theater)
REFIELD_SAFETY_FN("portal_state_ending", portal_state_ending)
REFIELD_SAFETY_FN("pulse_canal_portal_top", pulse_canal_portal_top)
REFIELD_SAFETY_FN("pulse_canal_portal_bottom", pulse_canal_portal_bottom)
REFIELD_SAFETY_FN("pulse_slums_portal_top", pulse_slums_portal_top)
REFIELD_SAFETY_FN("pulse_slums_portal_bottom", pulse_slums_portal_bottom)
REFIELD_SAFETY_FN("pulse_theater_portal_top", pulse_theater_portal_top)
REFIELD_SAFETY_FN("pulse_theater_portal_bottom", pulse_theater_portal_bottom)
REFIELD_SAFETY_FN("devgui_lightning_test", devgui_lightning_test)
REFIELD_SAFETY_FN("ee_quest_state", ee_quest_state)
REFIELD_SAFETY_FN("ee_shadowman_battle_active", ee_shadowman_battle_active)
REFIELD_SAFETY_FN("ee_superworm_state", ee_superworm_state)
REFIELD_SAFETY_FN("ee_keeper_beam_state", ee_keeper_beam_state)
REFIELD_SAFETY_FN("ritual_state_pap", ritual_state_pap)
REFIELD_SAFETY_FN("keeper_spawn_portals", keeper_spawn_portals)
REFIELD_SAFETY_FN("wallrun_footprints", wallrun_footprints)
REFIELD_SAFETY_FN("keeper_quest_state_0", keeper_quest_state_0)
REFIELD_SAFETY_FN("keeper_quest_state_1", keeper_quest_state_1)
REFIELD_SAFETY_FN("keeper_quest_state_2", keeper_quest_state_2)
REFIELD_SAFETY_FN("keeper_quest_state_3", keeper_quest_state_3)
REFIELD_SAFETY_FN("keeper_egg_location_0", keeper_egg_location_0)
REFIELD_SAFETY_FN("keeper_egg_location_1", keeper_egg_location_1)
REFIELD_SAFETY_FN("keeper_egg_location_2", keeper_egg_location_2)
REFIELD_SAFETY_FN("keeper_egg_location_3", keeper_egg_location_3)
REFIELD_SAFETY_FN("sndTrainVox", sndTrainVox)
REFIELD_SAFETY_FN("ritual_state_boxer", ritual_state_boxer)
REFIELD_SAFETY_FN("ritual_state_detective", ritual_state_detective)
REFIELD_SAFETY_FN("ritual_state_femme", ritual_state_femme)
REFIELD_SAFETY_FN("ritual_state_magician", ritual_state_magician)
REFIELD_SAFETY_FN("set_subway_wall_dissolve", set_subway_wall_dissolve)
REFIELD_SAFETY_FN("magic_circle_state_0", magic_circle_state_0)
REFIELD_SAFETY_FN("magic_circle_state_1", magic_circle_state_1)
REFIELD_SAFETY_FN("magic_circle_state_2", magic_circle_state_2)
REFIELD_SAFETY_FN("magic_circle_state_3", magic_circle_state_3)

REFIELD_SAFETY_FN_ENT("robot_switch", robot_switch)
REFIELD_SAFETY_FN_ENT("zod_egg_glow", zod_egg_glow)
REFIELD_SAFETY_FN_ENT("blood_soul_fx", blood_soul_fx)
REFIELD_SAFETY_FN_ENT("sword_statue_glow", sword_statue_glow)
REFIELD_SAFETY_FN_ENT("train_switch_light", train_switch_light)
REFIELD_SAFETY_FN_ENT("train_map_light", train_map_light)
REFIELD_SAFETY_FN_ENT("trap_chain_state", trap_chain_state)
REFIELD_SAFETY_FN_ENT("update_fungus_pod_level", update_fungus_pod_level)
REFIELD_SAFETY_FN_ENT("pod_sprayer_glint", pod_sprayer_glint)
REFIELD_SAFETY_FN_ENT("pod_miasma", pod_miasma)
REFIELD_SAFETY_FN_ENT("pod_harvest", pod_harvest)
REFIELD_SAFETY_FN_ENT("pod_self_destruct", pod_self_destruct)
REFIELD_SAFETY_FN_ENT("shadowman_fx", shadowman_fx)
REFIELD_SAFETY_FN_ENT("gateworm_basin_fx", gateworm_basin_fx)
REFIELD_SAFETY_FN_ENT("train_callbox_light", train_callbox_light)
// END ZM_ZOD

// START ZM_FACTORY
REFIELD_SAFETY_FN("console_blue", console_blue)
REFIELD_SAFETY_FN("console_green", console_green)
REFIELD_SAFETY_FN("console_red", console_red)
REFIELD_SAFETY_FN("console_start", console_start)
// END ZM_FACTORY

// START ZM_CASTLE
REFIELD_SAFETY_FN("snd_low_gravity_state", snd_low_gravity_state)
REFIELD_SAFETY_FN("sndRocketAlarm", sndRocketAlarm)
REFIELD_SAFETY_FN("sndRocketTrap", sndRocketTrap)
REFIELD_SAFETY_FN("snd_tram", snd_tram)

REFIELD_SAFETY_FN_ENT("craftable_powerup_fx", craftable_powerup_fx)
REFIELD_SAFETY_FN_ENT("craftable_teleport_fx", craftable_teleport_fx)
REFIELD_SAFETY_FN_ENT("flinger_flying_postfx", flinger_flying_postfx)
REFIELD_SAFETY_FN_ENT("flinger_land_smash", flinger_land_smash)
REFIELD_SAFETY_FN_ENT("flinger_pad_active_fx", flinger_pad_active_fx)
REFIELD_SAFETY_FN_ENT("player_postfx", player_postfx)
REFIELD_SAFETY_FN_ENT("tram_fuse_fx", tram_fuse_fx)
REFIELD_SAFETY_FN_ENT("bow_pickup_fx", bow_pickup_fx)
REFIELD_SAFETY_FN_ENT("urn_impact_fx", urn_impact_fx)
REFIELD_SAFETY_FN_ENT("tower_break_fx", tower_break_fx)
REFIELD_SAFETY_FN_ENT("arrow_charge_wolf_fx", arrow_charge_wolf_fx)
// END ZM_CASTLE

// START ZM_ISLAND
REFIELD_SAFETY_FN("play_dogfight_scenes", play_dogfight_scenes) // goodbye hilarious bug </3
REFIELD_SAFETY_FN("lower_pap_water", lower_pap_water)
REFIELD_SAFETY_FN("power_switch_1_fx", power_switch_1_fx)
REFIELD_SAFETY_FN("power_switch_2_fx", power_switch_2_fx)
REFIELD_SAFETY_FN("penstock_fx_anim", penstock_fx_anim)
REFIELD_SAFETY_FN("skullquest_ritual_1_fx", skullquest_ritual_1_fx)
REFIELD_SAFETY_FN("skullquest_ritual_2_fx", skullquest_ritual_2_fx)
REFIELD_SAFETY_FN("skullquest_ritual_3_fx", skullquest_ritual_3_fx)
REFIELD_SAFETY_FN("skullquest_ritual_4_fx", skullquest_ritual_4_fx)
REFIELD_SAFETY_FN("proptrap_downdraft_rumble", proptrap_downdraft_rumble)
REFIELD_SAFETY_FN("walltrap_draft_rumble", walltrap_draft_rumble)

REFIELD_SAFETY_FN_ENT("challenge_glow_fx", challenge_glow_fx)
REFIELD_SAFETY_FN_ENT("lightning_shield_fx", lightning_shield_fx)
REFIELD_SAFETY_FN_ENT("smoke_trail_fx", smoke_trail_fx)
REFIELD_SAFETY_FN_ENT("smoke_smolder_fx", smoke_smolder_fx)
REFIELD_SAFETY_FN_ENT("bgb_lightning_fx", bgb_lightning_fx)
REFIELD_SAFETY_FN_ENT("perk_lightning_fx", perk_lightning_fx)
REFIELD_SAFETY_FN_ENT("show_part", show_part)
REFIELD_SAFETY_FN_ENT("plant_growth_siege_anims", plant_growth_siege_anims)
REFIELD_SAFETY_FN_ENT("plant_hit_with_ww_fx", plant_hit_with_ww_fx)
REFIELD_SAFETY_FN_ENT("plant_watered_fx", plant_watered_fx)
REFIELD_SAFETY_FN_ENT("babysitter_plant_fx", babysitter_plant_fx)
REFIELD_SAFETY_FN_ENT("trap_plant_fx", trap_plant_fx)
REFIELD_SAFETY_FN_ENT("player_cloned_fx", player_cloned_fx)
REFIELD_SAFETY_FN_ENT("zombie_or_grenade_spawned_from_minor_cache_plant", zombie_or_grenade_spawned_from_minor_cache_plant)
REFIELD_SAFETY_FN_ENT("player_vomit_fx", player_vomit_fx)
REFIELD_SAFETY_FN_ENT("golden_bucket_glow_fx", golden_bucket_glow_fx)
REFIELD_SAFETY_FN_ENT("skullquest_finish_start_fx", skullquest_finish_start_fx)
REFIELD_SAFETY_FN_ENT("skullquest_finish_trail_fx", skullquest_finish_trail_fx)
REFIELD_SAFETY_FN_ENT("skullquest_finish_end_fx", skullquest_finish_end_fx)
REFIELD_SAFETY_FN_ENT("skullquest_finish_done_glow_fx", skullquest_finish_done_glow_fx)
REFIELD_SAFETY_FN_ENT("sewer_current_fx", sewer_current_fx)
REFIELD_SAFETY_FN_ENT("proptrap_downdraft_blur", proptrap_downdraft_blur)
REFIELD_SAFETY_FN_ENT("walltrap_draft_blur", walltrap_draft_blur)
REFIELD_SAFETY_FN_ENT("play_underwater_plant_fx", play_underwater_plant_fx)
REFIELD_SAFETY_FN_ENT("play_carrier_fx", play_carrier_fx)
REFIELD_SAFETY_FN_ENT("play_vial_fx", play_vial_fx)
REFIELD_SAFETY_FN_ENT("spider_bait", spider_bait)
REFIELD_SAFETY_FN_ENT("vine_door_play_fx", vine_door_play_fx)
// END ZM_ISLAND

// START ZM_STALINGRAD
REFIELD_SAFETY_FN_ENT("tp_water_sheeting", tp_water_sheeting)
REFIELD_SAFETY_FN_ENT("pr_g_c_fx", pr_g_c_fx)
// END ZM_STALINGRAD

// START ZM_GENESIS
REFIELD_SAFETY_FN_ENT("being_keeper_revived", being_keeper_revived)
REFIELD_SAFETY_FN_ENT("keeper_reviving", keeper_reviving)
REFIELD_SAFETY_FN_ENT("kc_effects", kc_effects)
REFIELD_SAFETY_FN_ENT("emit_smoke", emit_smoke)
REFIELD_SAFETY_FN_ENT("fire_trap", fire_trap)
// END ZM_GENESIS

// START ZM_TOMB
REFIELD_SAFETY_FN_ENT("glow_biplane_trail_fx", glow_biplane_trail_fx)
REFIELD_SAFETY_FN_ENT("element_glow_fx", element_glow_fx)
REFIELD_SAFETY_FN_ENT("plane_fx", plane_fx)
REFIELD_SAFETY_FN_ENT("zeppelin_fx", zeppelin_fx)
REFIELD_SAFETY_FN_ENT("magicbox_open_fx", magicbox_open_fx)
REFIELD_SAFETY_FN_ENT("magicbox_amb_fx", magicbox_amb_fx)
// END ZM_TOMB

// START ZM_LEVIATHAN
REFIELD_SAFETY_FN_ENT("WearingPes", WearingPes)
REFIELD_SAFETY_FN_ENT("Flashlight", Flashlight)
// END ZM_LEVIATHAN

function get(field_name)
{
	if(self == level)
	{
		return codegetworldclientfield(field_name);
	}
	return codegetclientfield(self, field_name);
}

function get_to_player(field_name)
{
	return codegetplayerstateclientfield(self, field_name);
}

function get_player_uimodel(field_name)
{
	return codegetuimodelclientfield(self, field_name);
}