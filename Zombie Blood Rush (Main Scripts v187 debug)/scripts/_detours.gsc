#ifdef DETOURS

#region Axis AI Assumption Fixes

detour sys::getaiteamarray(team, team2)
{
    if(isdefined(team) && team == "axis")
    {
        team = level.zombie_team;
    }
	if(isdefined(team2) && team2 == "axis")
	{
		team2 = level.zombie_team;
		return getaiteamarray(team, team2);
	}
    return getaiteamarray(team);
}

detour sys::getvehicleteamarray(team)
{
    if(isdefined(team) && team == "axis")
    {
        team = level.zombie_team;
    }
    return getvehicleteamarray(team);
}

detour sys::getaispeciesarray(team, species)
{
    if(isdefined(team) && team == "axis")
    {
        team = level.zombie_team;
    }
    if(isdefined(species))
    {
        return getaispeciesarray(team, species);
    }
    return getaispeciesarray(team);
}

detour sys::getaiarchetypearray(archetype, team)
{
    if(isdefined(team) && team == "axis")
    {
        team = level.zombie_team;
    }
    if(isdefined(team))
    {
        return getaiarchetypearray(archetype, team);
    }
    return getaiarchetypearray(archetype);
}

detour spawner<scripts\shared\spawner_shared.gsc>::add_global_spawn_function(team, spawn_func, param1, param2, param3, param4, param5)
{
    if(isdefined(team) && team == "axis")
    {
        team = level.zombie_team;
    }
    spawner::add_global_spawn_function(team, spawn_func, param1, param2, param3, param4, param5);
}

#endregion

#region Allies Team Assumption Fixes

detour util<scripts\shared\util_shared.gsc>::any_player_is_touching(ent, str_team)
{
    foreach(player in getplayers())
	{
		if(isalive(player) && player istouching(ent))
		{
			return true;
		}
	}
    return false;
}

detour sys::playsoundtoteam(sound, team)
{
    if(isdefined(team) && team == "allies" && isdefined(level.gm_teams) && sound != "zmb_full_ammo")
    {
        foreach(str_team in level.gm_teams)
        {
            self playsoundtoteam(sound, str_team);
        }
        return;
    }
    self playsoundtoteam(sound, team);
}

#endregion

detour zm_audio<scripts\zm\_zm_audio.gsc>::loadplayervoicecategories(p)
{
	// do nothing
}

detour zm_audio<scripts\zm\_zm_audio.gsc>::zmbvoxadd(category, subcategory, suffix, percentage, response, delaybeforeplayagain)
{
	// do nothing
}

detour zm_audio<scripts\zm\_zm_audio.gsc>::playerexert(exert, notifywait)
{
	// do nothing
}

detour zm_audio<scripts\zm\_zm_audio.gsc>::create_and_play_dialog(category, subcategory, force_variant)
{
	// do nothing
}

detour zm_audio<scripts\zm\_zm_audio.gsc>::do_player_or_npc_playvox(sound_to_play, category, subcategory)
{
	// do nothing
}

// this enables detours on map scripts by doing a post link detour
detour system<scripts\shared\system_shared.gsc>::register(str_system, func_preinit, func_postinit, reqs = [])
{
    if(isdefined(str_system))
    {
		if(issubstr(str_system, "aat"))
		{
			level.aat_in_use = true;
		}
        switch(str_system)
        {
            case "zm_island_side_ee_spore_hallucinations":
                clientfield::register("toplayer", "hallucinate_bloody_walls", 9000, 1, "int");
	            clientfield::register("toplayer", "hallucinate_spooky_sounds", 9000, 1, "int");
                return;
            case "zm_powerup_money":
			case "bo4_features":
            case "zm_island_side_ee_secret_maxammo":
            case "zm_island_side_ee_doppleganger":
				return;
			case "zm_castle_vo":
			case "zm_factory_vo":
			case "zm_stalingrad_vo":
				level.a_e_speakers = [];
                return;
			case "zm_island_vo":
				system::register("zm_island_vo", serious::zm_island_vo_fix, undefined, undefined);
				return;
            case "zm_island_side_ee_good_thrasher":
                var_d1cfa380 = getminbitcountfornum(7);
                var_a15256dd = getminbitcountfornum(3);
                clientfield::register("scriptmover", "side_ee_gt_spore_glow_fx", 9000, 1, "int");
                clientfield::register("scriptmover", "side_ee_gt_spore_cloud_fx", 9000, var_d1cfa380, "int");
                clientfield::register("actor", "side_ee_gt_spore_trail_enemy_fx", 9000, 1, "int");
                clientfield::register("allplayers", "side_ee_gt_spore_trail_player_fx", 9000, var_a15256dd, "int");
                clientfield::register("actor", "good_thrasher_fx", 9000, 1, "int");
                return;
            case "controllable_spider":
            case "zm_castle_weap_quest_upgrade":
            case "zm_zod_robot":
            case "zm_ai_spiders":
            case "zm_zod_ee_side":
            case "zm_factory_teleporter":
            case "zm_genesis_companion":
            case "zm_trap_electric":
            case "zm_island_skullquest":
            case "tomb_magicbox":
			case "zm_genesis_apothican":
            case "zm_weap_black_hole_bomb":
                compiler::relinkdetours();
            break;
        }
    }
    system::register(str_system, func_preinit, func_postinit, reqs);
}

#region zm_island fixes

// disable activating rounds
detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_d2716ad8()
{
}

// disable activating rounds
detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_2a424152()
{
}

detour zm_island_spiders<scripts\zm\zm_island_spiders.gsc>::function_33aa4940()
{
    return 0;
}

detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_f4bd92a2(n_to_spawn, s_spawn_point)
{
    return undefined;
}

detour zm_island<scripts\zm\zm_island.gsc>::on_player_spawned()
{
    if(!isdefined(self.zm_island_on_player_spawned))
    {
        self.zm_island_on_player_spawned = true;
        self thread [[ @zm_island<scripts\zm\zm_island.gsc>::on_player_spawned ]]();
    }
    if(level flag::get("flag_play_outro_cutscene"))
	{
		if(self.characterindex != 2)
		{
			wait(0.1);
			self setcharacterbodystyle(1);
		}
	}
	self.is_ziplining = 0;
	self.no_revive_trigger = 0;
	self.var_90f735f8 = 0;
    self.tesla_network_death_choke = 0;
	self.var_7149fc41 = 0;
	if(isdefined(self.thrasher))
	{
		self.thrasher kill();
	}
}

detour main_quest<scripts\zm\zm_island_main_ee_quest.gsc>::function_85773a07()
{
    // do nothing
}

detour main_quest<scripts\zm\zm_island_main_ee_quest.gsc>::function_aeef1178()
{
    // do nothing
}

detour main_quest<scripts\zm\zm_island_main_ee_quest.gsc>::function_df4d1d4()
{
    // do nothing
}

detour namespace_d9f30fb4<scripts\zm\zm_island_side_ee_golden_bucket.gsc>::function_e6cfa209()
{
    // do nothing
}

detour zm_island_side_ee_spore_hallucinations<scripts\zm\zm_island_side_ee_spore_hallucinations.gsc>::on_player_spawned()
{
    // do nothing
}

detour zm_island_skullquest<scripts\zm\zm_island_skullweapon_quest.gsc>::on_player_spawned()
{
    if(!isdefined(self.zm_island_skullquest_onplayerspawned))
    {
        self.zm_island_skullquest_onplayerspawned = true;
        self thread [[ @zm_island_skullquest<scripts\zm\zm_island_skullweapon_quest.gsc>::on_player_spawned ]]();
    }
}

detour zm_island_skullquest<scripts\zm\zm_island_skullweapon_quest.gsc>::function_940267cd()
{
    // do nothing
}

detour zm_island_skullquest<scripts\zm\zm_island_skullweapon_quest.gsc>::function_ba04e236()
{
    // do nothing
}

detour zm_island_skullquest<scripts\zm\zm_island_skullweapon_quest.gsc>::function_e0075c9f()
{
    // do nothing
}

detour zm_island_vo<scripts\zm\zm_island_vo.gsc>::on_player_spawned()
{
    // do nothing
    if(!isdefined(self.zm_island_vo_on_player_spawned))
    {
        self.zm_island_vo_on_player_spawned = true;
        self thread [[ @zm_island_vo<scripts\zm\zm_island_vo.gsc>::on_player_spawned ]]();
    }
}

detour zm_island_ww_quest<scripts\zm\zm_island_ww_quest.gsc>::function_598781a4()
{
    // do nothing
}

detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_d3c8090f()
{
    if(!isdefined(self.zm_ai_spiders_function_d3c8090f))
    {
        self.zm_ai_spiders_function_d3c8090f = true;
        self thread [[ @zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_d3c8090f ]]();
    }
}

detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_eb951410()
{
    if(!isdefined(self.zm_ai_spiders_function_eb951410))
    {
        self.zm_ai_spiders_function_eb951410 = true;
        self thread [[ @zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_eb951410 ]]();
    }
}

detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_7d50634d()
{
    if(!isdefined(self.zm_ai_spiders_function_7d50634d))
    {
        self.zm_ai_spiders_function_7d50634d = true;
        self thread [[ @zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_7d50634d ]]();
    }
}

detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_83a70ec3()
{
    if(!isdefined(self.zm_ai_spiders_function_83a70ec3))
    {
        self.zm_ai_spiders_function_83a70ec3 = true;
        self thread [[ @zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_83a70ec3 ]]();
    }
}

detour zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_d717ef02()
{
    if(!isdefined(self.zm_ai_spiders_function_d717ef02))
    {
        self.zm_ai_spiders_function_d717ef02 = true;
        self thread [[ @zm_ai_spiders<scripts\zm\_zm_ai_spiders.gsc>::function_d717ef02 ]]();
    }
}

detour controllable_spider<scripts\zm\_zm_weap_controllable_spider.gsc>::function_b2a01f79()
{
    if(!isdefined(self.controllable_spider_function_b2a01f79))
    {
        self.controllable_spider_function_b2a01f79 = true;
        self thread [[ @controllable_spider<scripts\zm\_zm_weap_controllable_spider.gsc>::function_b2a01f79 ]]();
    }
}

detour zm_island_challenges<scripts\zm\zm_island_challenges.gsc>::on_player_disconnect()
{

}

detour zm_island_challenges<scripts\zm\zm_island_challenges.gsc>::on_player_connect()
{

}

detour zm_island_challenges<scripts\zm\zm_island_challenges.gsc>::main()
{
    array::run_all(getentarray("t_lookat_challenge_1", "targetname"), sys::delete);
    array::run_all(getentarray("t_lookat_challenge_2", "targetname"), sys::delete);
    array::run_all(getentarray("t_lookat_challenge_3", "targetname"), sys::delete);
    array::thread_all(struct::get_array("s_challenge_trigger"), struct::delete);
    struct::get("s_challenge_altar") struct::delete();
}

detour zm_island<scripts\zm\zm_island.gsc>::function_3bf2d62a(event_string, var_c57fa913, bunker, var_82860e04)
{

}

detour zm_island<scripts\zm\zm_island.gsc>::function_7b697614(str_vo_alias, n_delay, b_wait_if_busy, n_priority, var_d1295208)
{

}

detour zm_island<scripts\zm\zm_island.gsc>::function_d258c672(var_a907ca47)
{

}

detour zm_island<scripts\zm\zm_island.gsc>::function_1e767f71(e_target, n_min_dist, var_79d0b667, var_b03cc213, var_a099ce87, var_ac3beede, n_duration)
{

}

#endregion

#region zm_castle changes

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::elemental_storm_wallrun()
{
    // storm bow step 2
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_be03e13e()
{
    // storm bow step 3
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_292ad7f1()
{
    // fire bow step 2
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_fd254a35()
{
    // fire bow step 3
    e_ball = getent("aq_rp_magma_ball_tag", "targetname");
    fn_monitor_progress = @zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_5f8f4823;
    e_ball thread [[ fn_monitor_progress ]]();
    wait 10;
    e_ball notify("final");
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_5170090a()
{
    // void bow step 2
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::demon_gate_crawlers()
{
    // void bow step 3
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::demon_gate_runes()
{
    // void bow step 4
    level [[ @zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_b9fe51c7 ]]();
    level [[ @zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_695d82fd ]]();
	level.var_ca3b8551 = undefined;
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_37acbc24()
{
    // wolf bow step 2
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::wolf_howl_escort()
{
    // wolf bow step 3
}

detour zm_castle_weap_quest<scripts\zm\zm_castle_weap_quest.gsc>::function_e464049a()
{
	return false; // we never have a bow
}

detour zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_fb704679(e_target_player)
{
	__function_fb704679(e_target_player);
}

__function_fb704679(e_target_player)
{
	if(!isdefined(level.zm_castle_weap_quest_upgrade_init))
	{
		level.zm_castle_weap_quest_upgrade_init = true;
		level.function_3313abd5 = @zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_3313abd5;
		level.function_87cf409b = @zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_87cf409b;
		level.function_4b76cf52 = @zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_4b76cf52;
		level.function_7b6fdb3e = @zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_7b6fdb3e;
		level.function_5facaaf9 = @zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_5facaaf9;
		level.function_971e3797 = @zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_971e3797;
		level.function_cdfce37d = @zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_cdfce37d;
		level.function_8b295d47 = @zm_castle_weap_quest_upgrade<scripts\zm\zm_castle_weap_quest_upgrade.gsc>::function_8b295d47;
	}
	if(isdefined(e_target_player))
	{
		e_target_player notify(#"hash_ea0c887b");
		level notify(#"hash_ea0c887b");
		self [[level.function_3313abd5]](level.function_87cf409b); // setup a unitrigger
	}
	else
	{
		self [[level.function_3313abd5]](level.function_4b76cf52); // setup a unitrigger
	}
	if(!isdefined(level.var_e8a6b6f7))
	{
		level.var_e8a6b6f7 = [];
	}
	else if(!isarray(level.var_e8a6b6f7))
	{
		level.var_e8a6b6f7 = array(level.var_e8a6b6f7);
	}
	level.var_e8a6b6f7[level.var_e8a6b6f7.size] = self.var_67b5dd94;
	var_b4810425 = getweapon(self.script_label);
	for(;;)
	{
		self.var_67b5dd94 waittill(#trigger, e_who);
		if(e_who hasweapon(var_b4810425))
		{
			continue;
		}
		e_target_player = level [[level.function_7b6fdb3e]](self.script_label);
		if(e_who [[level.function_5facaaf9]](e_target_player, self.script_label))
		{
			e_who zm_weapons::weapon_give(var_b4810425, 0, 0, 1);
			if(!isdefined(e_who.bows_obtained))
			{
				e_who.bows_obtained = [];
			}
			if(!isinarray(e_who.bows_obtained, var_b4810425))
			{
				e_who.bows_obtained[e_who.bows_obtained.size] = var_b4810425;
				e_who giveMaxAmmo(var_b4810425);
			}
			e_who switchtoweapon(var_b4810425);
			e_who playsound("zmb_bow_pickup");
			self.var_d4a62e6b hide();
			arrayremovevalue(level.var_e8a6b6f7, self.var_67b5dd94);
			zm_unitrigger::unregister_unitrigger(self.var_67b5dd94);
			level thread function_a4861409(e_who, self);
			self thread [[level.function_971e3797]]();
			e_who thread [[level.function_cdfce37d]](self.script_label);
			return;
		}
	}
}

function_a4861409(e_player, var_285c992d)
{
	str_endon = var_285c992d.script_label + "_returned";
	level endon(str_endon);
	var_bbdf3539 = 0;
	wait 1;
	e_player.var_bec0aa15 = undefined;
	zm_unitrigger::unregister_unitrigger(var_285c992d.var_67b5dd94);
	var_285c992d.var_d4a62e6b show();
	var_285c992d thread __function_fb704679();
	level notify(var_285c992d.script_label + "_stop_tracking");
	level [[level.function_8b295d47]](var_285c992d.script_label);
}

#endregion

#region misc fixes

// fixes an issue where between rounds, you can get 1 shot killed during the health reset
detour zm_perks<scripts\zm\_zm_perks.gsc>::perk_set_max_health_if_jugg(str_perk, set_premaxhealth, clamp_health_to_max_health)
{
    // do nothing, because juggernog works differently in our mode
}

detour zm_weap_black_hole_bomb<scripts\zm\_zm_weap_black_hole_bomb.gsc>::function_1ff5cae1()
{
	// do nothing
}

detour zm_weap_black_hole_bomb<scripts\zm\_zm_weap_black_hole_bomb.gsc>::function_bf9781f8(player)
{
    // player endon("disconnect");
    // player endon("bled_out");
	// while(level.var_4af7fb42.size > 0)
	// {
    //     if(!isdefined(player) || player laststand::player_is_in_laststand())
    //     {
    //         return;
    //     }
	// 	var_a81ad02a = 2147483647;
	// 	foreach(bhb in level.var_4af7fb42)
	// 	{
	// 		curr_dist = distancesquared(player.origin, bhb.origin);
	// 		if(curr_dist < var_a81ad02a)
	// 		{
	// 			var_a81ad02a = curr_dist;
	// 		}
	// 	}
        
    //     if(var_a81ad02a < 0) continue;
	// 	if(var_a81ad02a < 262144)
	// 	{
	// 		visionset_mgr::set_state_active(player, 1 - (var_a81ad02a / 262144));
	// 	}
	// 	wait(0.05);
	// }
}

detour zm<scripts\zm\_zm.gsc>::is_idgun_damage(weapon)
{
    if(!isdefined(weapon))
    {
        return false;
    }
    if(isdefined(level.idgun_weapons))
	{
		if(array::contains(level.idgun_weapons, weapon))
		{
			return true;
		}
	}
	return false;
}

detour idgun<scripts\zm\_zm_weap_idgun.gsc>::is_idgun_damage(weapon)
{
    if(!isdefined(weapon))
    {
        return false;
    }
    if(isdefined(level.idgun_weapons))
	{
		if(array::contains(level.idgun_weapons, weapon))
		{
			return true;
		}
	}
	return false;
}

// detour zm<scripts\zm\_zm.gsc>::spectator_respawn_player()
// {
//     if(self.sessionstate == "spectator")
// 	{
// 		if(!isdefined(level.custom_spawnplayer))
// 		{
// 			level.custom_spawnplayer = zm::spectator_respawn;
// 		}
// 		self respawn_enter_queue();
// 	}
// }

// fixes an incorrect assumption from the devs that a player will only spawn once
detour zm_zod<scripts\zm\zm_zod.gsc>::function_8535c602()
{
    self endon("bled_out");
    self endon("disconnect");
	util::wait_network_frame();
	for(;;)
	{
		if(isdefined(self) && isplayer(self))
		{
			self notify("lightning_strike");
			self clientfield::increment_to_player("devgui_lightning_test", 1);
		}
		wait(12);
	}
}

// fixes an incorrect assumption from the devs that a player will only spawn once
detour zm_zod_ee_side<scripts\zm\zm_zod_ee_side.gsc>::on_player_spawned()
{
    if(isdefined(self.zm_zod_ee_side_on_player_spawned))
    {
        return;
    }
    self.zm_zod_ee_side_on_player_spawned = true;
    self thread [[ @zm_zod_ee_side<scripts\zm\zm_zod_ee_side.gsc>::on_player_spawned ]]();
}

// fixes an incorrect assumption from the devs that a player will only spawn once
detour zm_factory<scripts\zm\zm_factory.gsc>::periodic_lightning_strikes()
{
    if(isdefined(self.zm_factory_periodic_lightning_strikes))
    {
        return;
    }
    self.zm_factory_periodic_lightning_strikes = true;
    self thread [[ @zm_factory<scripts\zm\zm_factory.gsc>::periodic_lightning_strikes ]]();
}

// fixes an incorrect assumption from the devs that a player will only spawn once
detour zm_castle_ee_side<scripts\zm\zm_castle_ee_side.gsc>::function_5c351802()
{
    if(isdefined(self.zm_castle_ee_side_function_5c351802))
    {
        return;
    }
    self.zm_castle_ee_side_function_5c351802 = true;
    self thread [[ @zm_castle_ee_side<scripts\zm\zm_castle_ee_side.gsc>::function_5c351802 ]]();
}

// fixes an incorrect assumption from the devs that a player will only spawn once
detour zm_castle_ee_side<scripts\zm\zm_castle_ee_side.gsc>::function_9daec9e3()
{
    if(isdefined(self.zm_castle_ee_side_function_9daec9e3))
    {
        return;
    }
    self.zm_castle_ee_side_function_9daec9e3 = true;
    self thread [[ @zm_castle_ee_side<scripts\zm\zm_castle_ee_side.gsc>::function_9daec9e3 ]]();
}

// fixes an incorrect assumption from the devs that a player will only spawn once
detour zm_audio<scripts\zm\_zm_audio.gsc>::water_vox()
{
    if(isdefined(self.zm_audio_water_vox))
    {
        return;
    }
    self.zm_audio_water_vox = true;
    self thread [[ @zm_audio<scripts\zm\_zm_audio.gsc>::water_vox ]]();
}

// fixes an incorrect assumption from the devs that a player will only spawn once
detour zm_stalingrad_vo<scripts\zm\zm_stalingrad_vo.gsc>::function_81d644a1()
{
    if(isdefined(self.zm_stalingrad_vo_function_81d644a1))
    {
        return;
    }
    self.zm_stalingrad_vo_function_81d644a1 = true;
    self thread [[ @zm_stalingrad_vo<scripts\zm\zm_stalingrad_vo.gsc>::function_81d644a1 ]]();
}

// fixes an incorrect assumption from the devs that a player will only spawn once
detour zm_genesis_challenges<scripts\zm\zm_genesis_challenges.gsc>::function_a235a040()
{
    if(isdefined(self.zm_genesis_challenges_function_a235a040))
    {
        return;
    }
    self.zm_genesis_challenges_function_a235a040 = true;
    self thread [[ @zm_genesis_challenges<scripts\zm\zm_genesis_challenges.gsc>::function_a235a040 ]]();
}

// fixes an incorrect assumption from the devs that a player will only spawn once
detour zm_genesis_vo<scripts\zm\zm_genesis_vo.gsc>::on_player_spawned()
{
    if(isdefined(self.zm_genesis_vo_on_player_spawned))
    {
        return;
    }
    self.zm_genesis_vo_on_player_spawned = true;
    self thread [[ @zm_genesis_vo<scripts\zm\zm_genesis_vo.gsc>::on_player_spawned ]]();
}

// fixes an incorrect assumption from the devs that a player will only spawn once
detour zm_genesis_zombie<scripts\zm\zm_genesis_zombie.gsc>::function_dc84c8cc()
{
    self endon("bled_out");
	self endon("disconnnect");
	var_c17e74e6 = gettime();
	var_eaacaebf = level.round_number;
	var_e274e0c3 = undefined;
	var_a83e7943 = 900000;
	var_320b8666 = 900000;
	var_ed78383b = 7;
	for(;;)
	{
		self.var_a3d40b8 = undefined;
		foreach(volume in level.var_15ba7eb8)
		{
			if(self istouching(volume))
			{
				var_7da7c388 = gettime() - var_c17e74e6;
				if(var_7da7c388 > var_a83e7943)
				{
					level notify(#"hash_b1d69866", self);
				}
				if(var_7da7c388 > var_320b8666)
				{
					if(isdefined(var_e274e0c3) && var_e274e0c3 == "apothicon_island")
					{
						level notify(#"hash_8dbe1895", self);
					}
				}
				var_42215f9c = level.round_number - var_eaacaebf;
				if(var_42215f9c > var_ed78383b)
				{
					if(isdefined(var_e274e0c3) && var_e274e0c3 == "prototype_island")
					{
						level notify(#"hash_e15c8839", self);
					}
				}
				if(isdefined(var_e274e0c3) && var_e274e0c3 != volume.targetname)
				{
					var_c17e74e6 = gettime();
					var_eaacaebf = level.round_number;
				}
				self.var_a3d40b8 = volume.targetname;
				var_e274e0c3 = self.var_a3d40b8;
				break;
			}
		}
		wait(randomfloatrange(0.5, 1));
	}
}

// detour zm_score<scripts\zm\_zm_score.gsc>::score_cf_increment_info(name)
// {
//     foreach(player in level.players)
// 	{
// 		thread zm_score::wait_score_cf_increment_info(player, (("PlayerList.client" + (self.entity_num % 4)) + ".score_cf_") + name);
// 	}
// }

detour zm_score<scripts\zm\_zm_score.gsc>::add_to_player_score(points, b_add_to_total = 1, str_awarded_by = "")
{
	if(level.zbr_earn_no_points is true)
	{
		return;
	}
	if(self.turned_attacker is defined)
	{
		self.turned_attacker zm_score::add_to_player_score(points, b_add_to_total, str_awarded_by);
		return;
	}
	self zm_score::add_to_player_score(points, b_add_to_total, str_awarded_by);
}

// laststand_update
detour clientfield<scripts\shared\clientfield_shared.gsc>::increment(str_field_name, n_increment_count = 1)
{
	if(!isdefined(str_field_name))
	{
		return; // why is this getting triggered? treyarch? 
	}
    // for 8p we cant be having this
    if(issubstr(str_field_name, "laststand_update"))
    {
        return;
    }
    clientfield::increment(str_field_name, n_increment_count);
}

detour clientfield<scripts\shared\clientfield_shared.gsc>::register(str_pool_name, str_name, n_version, n_bits, str_type)
{
	if(!isdefined(str_name))
	{
		return; // why is this getting triggered? treyarch? 
	}
    // for 8p we cant be having this
    if(issubstr(str_name, "laststand_update"))
    {
        return;
    }
    clientfield::register(str_pool_name, str_name, n_version, n_bits, str_type);
}

detour zm_powerup_full_ammo<scripts\zm\_zm_powerup_full_ammo.gsc>::full_ammo_on_hud(drop_item, player_team)
{
    players = getplayers(player_team);
	players[0] playsoundtoteam("zmb_full_ammo", player_team);
    if(!isdefined(drop_item))
    {
        return;
    }
    foreach(player in players)
    {   
        player luinotifyevent(&"zombie_notification", 1, drop_item.hint);
    }
}

detour zm_score<scripts\zm\_zm_score.gsc>::player_add_points_kill_bonus(mod, hit_location, weapon, player_points = undefined)
{
    if(!isdefined(mod))
    {
        mod = "MOD_UNKNOWN";
    }

    if(mod != "MOD_MELEE")
	{
		if("head" == hit_location || "helmet" == hit_location)
		{
			scoreevents::processscoreevent("headshot", self, undefined, weapon);
		}
		else
		{
			scoreevents::processscoreevent("kill", self, undefined, weapon);
		}
	}

	if(isdefined(level.player_score_override))
	{
		new_points = self [[level.player_score_override]](weapon, player_points);
		if(isdefined(new_points) && new_points > 0 && new_points != player_points)
		{
			return 0;
		}
	}

	if(mod == "MOD_MELEE")
	{
		self zm_score::score_cf_increment_info("death_melee"); // yeah its detoured here but whatever lmfao
		scoreevents::processscoreevent("melee_kill", self, undefined, weapon);
		return level.zombie_vars["zombie_score_bonus_melee"];
	}

    if(mod == "MOD_BURNED")
	{
		self zm_score::score_cf_increment_info("death_torso");
		return level.zombie_vars["zombie_score_bonus_burn"];
	}

	score = 0;
	if(isdefined(hit_location))
	{
		switch(hit_location)
		{
			case "head":
			case "helmet":
            case "neck":
			{
				self zm_score::score_cf_increment_info("death_head");
				score = level.zombie_vars["zombie_score_bonus_head"];
				break;
			}
			default:
			{
				self zm_score::score_cf_increment_info("death_torso");
				score = level.zombie_vars["zombie_score_bonus_torso"];
				break;
			}
		}
	}
	return score;
}

// death_neck gone
// death_normal gone
detour zm_score<scripts\zm\_zm_score.gsc>::score_cf_register_info(name, version, max_count)
{
    if(name == "death_neck" || name == "death_normal")
    {
        return;
    }
    for(i = 0; i < ZBR_MAX_PLAYERS; i++)
	{
		clientfield::register("clientuimodel", (("PlayerList.client" + i) + ".score_cf_") + name, version, getminbitcountfornum(max_count), "counter");
	}
}

detour zm_factory_teleporter<scripts\zm\zm_factory_teleporter.gsc>::teleport_players()
{
    if(!isdefined(level.zm_factory_teleporter_player_is_near_pad))
    {
        level.zm_factory_teleporter_player_is_near_pad = @zm_factory_teleporter<scripts\zm\zm_factory_teleporter.gsc>::player_is_near_pad;
    }
    if(!isdefined(level.zm_factory_teleport_nuke))
    {
        level.zm_factory_teleport_nuke = @zm_factory_teleporter<scripts\zm\zm_factory_teleporter.gsc>::teleport_nuke;
    }
    if(!isdefined(level.zm_factory_teleporter_teleport_aftereffects))
    {
        level.zm_factory_teleporter_teleport_aftereffects = @zm_factory_teleporter<scripts\zm\zm_factory_teleporter.gsc>::teleport_aftereffects;
    }

    player_radius = 16;
	players = getplayers();
	core_pos = [];
	occupied = [];
	image_room = [];
	players_touching = [];
	player_idx = 0;
	prone_offset = vectorscale((0, 0, 1), 49);
	crouch_offset = vectorscale((0, 0, 1), 20);
	stand_offset = (0, 0, 0);
	for(i = 0; i < 4; i++)
	{
		core_pos[i] = getent("origin_teleport_player_" + i, "targetname");
		occupied[i] = 0;
		image_room[i] = getent("teleport_room_" + i, "targetname");
		if(isdefined(players[i]))
		{
			if(self [[ level.zm_factory_teleporter_player_is_near_pad ]](players[i]))
			{
				players[i].b_teleporting = 1;
				players_touching[player_idx] = i;
				player_idx++;
				if(isdefined(image_room[i]))
				{
					visionset_mgr::deactivate("overlay", "zm_trap_electric", players[i]);
					visionset_mgr::activate("overlay", "zm_factory_teleport", players[i]);
					players[i] disableoffhandweapons();
					players[i] disableweapons();
					if(players[i] getstance() == "prone")
					{
						desired_origin = image_room[i].origin + prone_offset;
					}
					else if(players[i] getstance() == "crouch")
					{
						desired_origin = image_room[i].origin + crouch_offset;
					}
					else
					{
						desired_origin = image_room[i].origin + stand_offset;
					}
					players[i].teleport_origin = spawn("script_origin", players[i].origin);
					players[i].teleport_origin.angles = players[i].angles;
					players[i] linkto(players[i].teleport_origin);
					players[i].teleport_origin.origin = desired_origin;
					players[i] freezecontrols(1);
					util::wait_network_frame();
					if(isdefined(players[i]))
					{
						util::setclientsysstate("levelNotify", "black_box_start", players[i]);
						players[i].teleport_origin.angles = image_room[i].angles;
					}
				}
			}
		}
	}

	wait 2;
	core = getent("trigger_teleport_core", "targetname");
	core thread [[ level.zm_factory_teleport_nuke ]](undefined, 300);
	for(i = 0; i < players.size; i++)
	{
		if(isdefined(players[i]))
		{
			for(j = 0; j < 4; j++)
			{
				if(!occupied[j])
				{
					dist = distance2d(core_pos[j].origin, players[i].origin);
					if(dist < player_radius)
					{
						occupied[j] = 1;
					}
				}
			}
			util::setclientsysstate("levelNotify", "black_box_end", players[i]);
		}
	}

	util::wait_network_frame();
	for(i = 0; i < players_touching.size; i++)
	{
		player_idx = players_touching[i];
		player = players[player_idx];
		if(!isdefined(player))
		{
			continue;
		}
		start = 0;
		slot = 0;
		pos_name = "origin_teleport_player_" + slot;
		teleport_core_pos = getent(pos_name, "targetname");
		player unlink();
		player.teleport_origin delete();
		player.teleport_origin = undefined;
		visionset_mgr::deactivate("overlay", "zm_factory_teleport", player);
		player enableweapons();
		player enableoffhandweapons();
		player setorigin(core_pos[slot].origin);
		player setplayerangles(core_pos[slot].angles);
		player freezecontrols(0);
		player thread [[ level.zm_factory_teleporter_teleport_aftereffects ]]();
		player.b_teleporting = 0;
	}
	exploder::exploder_duration("mainframe_arrival", 1.7);
	exploder::exploder_duration("mainframe_steam", 14.6);
}

detour zm_castle_teleporter<scripts\zm\zm_castle_teleporter.gsc>::teleport_players(var_edc2ee2a = 0, var_66f7e6b9 = 0)
{
    if(!isdefined(level.zm_castle_teleporter_player_is_near_pad))
    {
        level.zm_castle_teleporter_player_is_near_pad = @zm_castle_teleporter<scripts\zm\zm_castle_teleporter.gsc>::player_is_near_pad;
    }
    if(!isdefined(level.zm_castle_teleporter_teleport_nuke))
    {
        level.zm_castle_teleporter_teleport_nuke = @zm_castle_teleporter<scripts\zm\zm_castle_teleporter.gsc>::teleport_nuke;
    }
    if(!isdefined(level.zm_castle_teleporter_teleport_aftereffects))
    {
        level.zm_castle_teleporter_teleport_aftereffects = @zm_castle_teleporter<scripts\zm\zm_castle_teleporter.gsc>::teleport_aftereffects;
    }
    if(!isdefined(level.zm_castle_teleporter_function_4a0d1595))
    {
        level.zm_castle_teleporter_function_4a0d1595 = @zm_castle_teleporter<scripts\zm\zm_castle_teleporter.gsc>::function_4a0d1595;
    }

    level flag::set("castle_teleporter_used");
	n_player_radius = 24;
	if(var_edc2ee2a && !var_66f7e6b9)
	{
		var_764d9cb = struct::get_array("past_laboratory_telepoints", "targetname");
	}
	else
	{
		var_764d9cb = struct::get_array(self.target, "targetname");
	}
	var_492a5e1e = struct::get_array("teleport_room_pos", "targetname");
	var_19ff0dfb = [];
	var_daad3c3c = vectorscale((0, 0, 1), 49);
	var_6b55b1c4 = vectorscale((0, 0, 1), 20);
	var_3abe10e2 = (0, 0, 0);
	for(i = 0; i < level.players.size; i++)
	{
		player = level.players[i];
		if(var_edc2ee2a)
		{
			if(var_66f7e6b9)
			{
				level flag::clear("time_travel_teleporter_ready");
			}
		}
		v_dest_origin = var_764d9cb[0].origin;
		var_a9d3e161 = var_764d9cb[0].angles;
		if(var_edc2ee2a || self [[ level.zm_castle_teleporter_player_is_near_pad ]](player))
		{
			if(var_edc2ee2a && var_66f7e6b9)
			{
				player clientfield::set_to_player("ee_quest_back_in_time_postfx", 0);
			}
			if(var_edc2ee2a)
			{
				if(var_66f7e6b9)
				{
					player clientfield::set_to_player("ee_quest_back_in_time_sfx", 0);
				}
				else
				{
					player clientfield::set_to_player("ee_quest_back_in_time_sfx", 1);
				}
			}
			if(isdefined(var_492a5e1e[0]))
			{
				visionset_mgr::deactivate("overlay", "zm_trap_electric", player);
				if(var_edc2ee2a)
				{
					player clientfield::set_to_player("ee_quest_back_in_time_teleport_fx", 1);
				}
				else
				{
					visionset_mgr::activate("overlay", "zm_factory_teleport", player);
				}
				player disableoffhandweapons();
				player disableweapons();
				player.b_teleporting = 1;
				if(player getstance() == "prone")
				{
					desired_origin = var_492a5e1e[0].origin + var_daad3c3c;
				}
				else if(player getstance() == "crouch")
				{
					desired_origin = var_492a5e1e[0].origin + var_6b55b1c4;
				}
				else
				{
					desired_origin = var_492a5e1e[0].origin + var_3abe10e2;
				}
				array::add(var_19ff0dfb, player, 0);
				player.var_601ebf01 = util::spawn_model("tag_origin", player.origin, player.angles);
				player linkto(player.var_601ebf01);
				player dontinterpolate();
				player.var_601ebf01 dontinterpolate();
				player.var_601ebf01.origin = desired_origin;
				player.var_601ebf01.angles = var_492a5e1e[0].angles;
				player freezecontrols(1);
				util::wait_network_frame();
				if(isdefined(player))
				{
					util::setclientsysstate("levelNotify", "black_box_start", player);
					player.var_601ebf01.angles = var_492a5e1e[0].angles;
				}
			}
			continue;
		}
		visionset_mgr::deactivate("overlay", "zm_factory_teleport", player);
	}
	wait(2);
	array::random(var_764d9cb) thread [[ level.zm_castle_teleporter_teleport_nuke ]](undefined, 300);
	for(i = 0; i < level.activeplayers.size; i++)
	{
		util::setclientsysstate("levelNotify", "black_box_end", level.activeplayers[i]);
	}
	util::wait_network_frame();
	for(i = 0; i < var_19ff0dfb.size; i++)
	{
		player = var_19ff0dfb[i];
		if(!isdefined(player))
		{
			continue;
		}
		player unlink();
		if(positionwouldtelefrag(var_764d9cb[0].origin))
		{
			player setorigin(var_764d9cb[0].origin + (randomfloatrange(-16, 16), randomfloatrange(-16, 16), 0));
		}
		else
		{
			player setorigin(var_764d9cb[0].origin);
		}
		player setplayerangles(var_764d9cb[0].angles);
		if(var_edc2ee2a)
		{
			player clientfield::set_to_player("ee_quest_back_in_time_teleport_fx", 0);
		}
		visionset_mgr::deactivate("overlay", "zm_factory_teleport", player);
		player enableweapons();
		player enableoffhandweapons();
		player.b_teleporting = undefined;
		player freezecontrols(0);
		player thread [[ level.zm_castle_teleporter_teleport_aftereffects ]]();
		if(var_edc2ee2a && !var_66f7e6b9)
		{
			player thread [[ level.zm_castle_teleporter_function_4a0d1595 ]]();
		}
		player zm_utility::clear_streamer_hint();
		player.var_601ebf01 delete();
	}
	level.var_47f4765c++;
	if(level.var_47f4765c == 1 || (level.var_47f4765c % 3) == 0)
	{
		playsoundatposition("vox_maxis_teleporter_pa_success_0", var_764d9cb[0].origin);
	}
	exploder::exploder("fxexp_102");
}

autoexec theater_teleporter_auto()
{
	if(tolower(getdvarstring("mapname")) != "zm_theater")
	{
		return;
	}
	level.player_teleporting_fn = @zm_theater_teleporter<scripts\zm\zm_theater_teleporter.gsc>::player_teleporting;
	compiler::script_detour("scripts/zm/zm_theater_teleporter.gsc", #zm_theater_teleporter, #teleport_core_think, function(index) => 
	{
		trigger_name = "trigger_teleport_pad_" + index;
		active = 0;
		user = undefined;
		trigger = getent(trigger_name, "targetname");
		trigger setcursorhint("HINT_NOICON");
		trigger sethintstring("");
		trigger.index = index;
		exploder::exploder("teleporter_light_red");
		if(isdefined(trigger))
		{
			while(!active)
			{
				level flag::wait_till("teleporter_linked");
				exploder::exploder("fxexp_200");
				exploder::kill_exploder("teleporter_light_red");
				exploder::exploder("teleporter_light_green");
				trigger sethintstring(&"ZM_THEATER_USE_TELEPORTER");
				trigger waittill(#trigger, user);
				if(zombie_utility::is_player_valid(user) && user zm_score::can_player_purchase(level.teleport_cost))
				{
					active = 1;
					exploder::kill_exploder("teleporter_light_green");
					exploder::exploder("teleporter_light_red");
					trigger sethintstring("");
					user zm_score::minus_to_player_score(level.teleport_cost);
					exploder::kill_exploder("fxexp_200");
					level clientfield::increment("teleporter_initiate_fx");
					trigger [[ level.player_teleporting_fn ]](trigger.index);
					level.var_4f3df77f clientfield::set("teleporter_link_cable_mtl", 0);
					trigger sethintstring(&"ZOMBIE_TELEPORT_COOLDOWN");
					wait(15);
					active = 0;
					exploder::delete_exploder_on_clients("fxexp_202");
					level flag::clear("teleporter_linked");
					level flag::clear("core_linked");
					exploder::kill_exploder("teleporter_light_red");
					exploder::exploder("teleporter_light_green");
				}
			}
		}
	});
}

detour zm_temple_traps<scripts\zm\zm_temple_traps.gsc>::sprear_trap_activate_spears(audio_counter, player)
{
	// do nothing
}

detour var_6b38abe3<zm\zm_genesis_wearables.gsc>::function_f6b20985(hat, a1, str_tag, a3)
{
    // rest of wearables are non-obtainable
    if(hat == "s_weasels_hat")
    {
        self [[ @var_6b38abe3<zm\zm_genesis_wearables.gsc>::function_f6b20985 ]](hat, a1, str_tag, a3);
    }
}

detour zm_stalingrad_pap<scripts\zm\zm_stalingrad_pap_quest.gsc>::function_6236d848(var_e57afa84, var_7741a4b8, var_ed686791, var_2a448c91, var_16b2096, var_adb8dbea, var_2b71b5b4, var_15eb9a52, var_f92c3865, var_af22dd13, var_ed448d3b, var_e25e1ccc, str_flag1, str_flag2, str_notify_end, var_54939bf3)
{
	// do nothing, makes lockdown never happen on stalingrad
}

detour zm_aat_fire_works<scripts\zm\aats\_zm_aat_fire_works.gsc>::zombie_death_gib(e_attacker, w_weapon, e_owner)
{
	self dodamage(self.health, self.origin, e_owner, w_weapon, "torso_upper");
	self zm_aat_fire_works::zombie_death_gib(e_attacker, w_weapon, e_owner);
}

detour zm_zod_vo<scripts\zm\zm_zod_vo.gsc>::function_17f92643()
{
	// do nothing
}

#endregion

// stop parasite spawns in apothicon
detour zm_genesis_apothican<scripts\zm\zm_genesis_apothican.gsc>::function_1affd18d()
{
	level waittill("forever");
}

// disables random boss spawns in rev
detour zm_genesis_apothican<scripts\zm\zm_genesis_apothican.gsc>::function_fd1e5c6c()
{
	// do nothing
}

detour zm_utility<scripts\zm\_zm_utility.gsc>::get_closest_valid_player(origin, ignore_player = [])
{
	players = GetPlayers();

	if(!isdefined(origin))
	{
		return undefined;
	}

	if(!isarray(ignore_player))
	{
		ignore_player = array(ignore_player);
	}

	if(isdefined(level.get_closest_valid_player_override))
	{
		players = [[ level.get_closest_valid_player_override ]]();
	}
	
	players = array::remove_undefined(players, false);
	
	b_designated_target_exists = false;
	for(i = 0; i < players.size; i++ )
	{
		player = players[i];
		if( player.am_i_valid !== true )
		{
			continue;
		}

		if(isdefined(level.evaluate_zone_path_override))
		{
			if(![[ level.evaluate_zone_path_override ]](player))
			{
				array::add(ignore_player, player);
			}
		}
		
		// is any player a designated target?
		if(player.b_is_designated_target === true)
		{
 			b_designated_target_exists = true;
		}
	}
	
	for(i = 0; i < ignore_player.size; i++ )
	{
		ArrayRemoveValue(players, ignore_player[i]);
	}

	// pre-cull any players that are in last stand or not designated target when a designated target is present
	done = false; 

	acceptible = [];
	foreach(player in players)
	{
		if(!isdefined(player))
		{
			continue;
		}
		if(player.am_i_valid !== true)
		{
			continue;
		}
		if(b_designated_target_exists && player.b_is_designated_target !== true)
		{
			continue;
		}
		acceptible[acceptible.size] = player;
	}

	players = acceptible;

	if(players.size == 0)
	{
		return undefined; 
	}
	
	while(players.size)
	{
		player = undefined; // without this, some conditions can occur which produce an infinite loop

		// find the closest player
		if(isdefined(self.closest_player_override))
		{
			player = [[ self.closest_player_override ]](origin, players);
		}
		else if(isdefined(level.closest_player_override))
		{
			player = [[ level.closest_player_override ]](origin, players);
		}
		else
		{
			player = array::get_all_closest(origin, players)[0];
		} 

		if(!isdefined(player) || players.size == 0)
		{
			return undefined;
		}
		
		if(level.allow_zombie_to_target_ai === true || player.allow_zombie_to_target_ai === true)
		{
			return player;
		}

		// make sure they're not a zombie or in last stand
		if(player.am_i_valid !== true)
		{
			// unlikely to get here unless there is a wait in one of the closest player overrides
			ArrayRemoveValue(players, player); 
			continue;
		}

		return player; 
	}
	
	return undefined; 
}

can_pack_weapon(weapon)
{
	if(level flag::get("pack_machine_in_use"))
	{
		return true;
	}
	weapon = self zm_weapons::get_nonalternate_weapon(weapon);
	if(!zm_weapons::is_weapon_or_base_included(weapon))
	{
		return false;
	}
	if(!self zm_weapons::can_upgrade_weapon(weapon))
	{
		return false;
	}
	return true;
}

can_buy_weapon()
{
	if(isdefined(self.is_drinking) && self.is_drinking > 0)
	{
		return false;
	}
	if(self zm_equipment::hacker_active())
	{
		return false;
	}
	current_weapon = self getcurrentweapon();
	if(zm_utility::is_placeable_mine(current_weapon) || zm_equipment::is_equipment_that_blocks_purchase(current_weapon))
	{
		if(!current_weapon.isriotshield)
		{
			return false;
		}
	}
	if(self zm_utility::in_revive_trigger())
	{
		return false;
	}
	if(current_weapon == level.weaponnone)
	{
		return false;
	}
	if(current_weapon.isheroweapon || current_weapon.isgadget)
	{
		if(!current_weapon.isriotshield)
		{
			return false;
		}
	}
	return true;
}

player_use_can_pack_now()
{
	if(self laststand::player_is_in_laststand() || (isdefined(self.intermission) && self.intermission) || self isthrowinggrenade())
	{
		return false;
	}
	if(self bgb::is_enabled("zm_bgb_disorderly_combat"))
	{
		return false;
	}
	if(!self can_buy_weapon())
	{
		return false;
	}
	if(self zm_equipment::hacker_active())
	{
		return false;
	}
	current_weapon = self getcurrentweapon();
	if(!self can_pack_weapon(current_weapon) && !zm_weapons::weapon_supports_aat(current_weapon))
	{
		return false;
	}
	return true;
}

detour _zm_pack_a_punch<scripts\zm\_zm_pack_a_punch.gsc>::can_pack_weapon(weapon)
{
	return can_pack_weapon(weapon);
}

detour _zm_pack_a_punch<scripts\zm\_zm_pack_a_punch.gsc>::player_use_can_pack_now()
{
	return player_use_can_pack_now();
}

// detour zm<scripts\zm\_zm.gsc>::last_stand_revive()
// {
// 	level endon("between_round_over");
// 	players = getplayers();
// 	laststand_count = 0;
// 	foreach(player in players)
// 	{
// 		if(!zm_utility::is_player_valid(player))
// 		{
// 			laststand_count++;
// 		}
// 	}
// 	if(laststand_count == players.size)
// 	{
// 		for(i = 0; i < players.size; i++)
// 		{
// 			if(players[i] laststand::player_is_in_laststand() && players[i].revivetrigger.beingrevived == 0)
// 			{
// 				if(players[i].b_in_death_cutscene === true)
// 				{
// 					players[i] thread [[ level.spawnplayer ]]();
// 				}
// 				else
// 				{
// 					players[i] zm_laststand::auto_revive(players[i]);
// 				}
// 			}
// 		}
// 	}
// }

// detour zm<scripts\zm\_zm.gsc>::spectators_respawn()
// {
// 	level endon("between_round_over");
// 	if(!isdefined(level.zombie_vars["spectators_respawn"]) || !level.zombie_vars["spectators_respawn"])
// 	{
// 		return;
// 	}
// 	for(;;)
// 	{
// 		players = getplayers();
// 		for(i = 0; i < players.size; i++)
// 		{
// 			e_player = players[i];
// 			if(!isdefined(e_player))
// 			{
// 				continue;
// 			}
// 			if(e_player.b_in_death_cutscene === true)
// 			{
// 				e_player thread [[ level.spawnplayer ]]();
// 			}
// 			else
// 			{
// 				e_player zm::spectator_respawn_player();
// 			}
// 		}
// 		wait(1);
// 	}
// }

detour visionset_mgr<scripts\shared\visionset_mgr_shared.gsc>::lerp_thread_wrapper(func, opt_param_1, opt_param_2, opt_param_3)
{
	if(func == visionset_mgr::ramp_in_out_thread_per_player || func == visionset_mgr::ramp_in_out_thread)
	{
		// ramp_in, full_period, ramp_out
		if(!isdefined(opt_param_1))
		{
			opt_param_1 = 0.1;
		}
		if(!isdefined(opt_param_2))
		{
			opt_param_1 = 100000;
		}
		if(!isdefined(opt_param_3))
		{
			opt_param_3 = 0.1;
		}
	}
	self notify("visionset_mgr_deactivate_all");
	self endon("visionset_mgr_deactivate_all");
	self [[func]](opt_param_1, opt_param_2, opt_param_3);
}

detour visionset_mgr<scripts\shared\visionset_mgr_shared.gsc>::lerp_thread_per_player_wrapper(func, player, opt_param_1, opt_param_2, opt_param_3)
{
	if(func == visionset_mgr::ramp_in_out_thread_per_player || func == visionset_mgr::ramp_in_out_thread)
	{
		// ramp_in, full_period, ramp_out
		if(!isdefined(opt_param_1))
		{
			opt_param_1 = 0.1;
		}
		if(!isdefined(opt_param_2))
		{
			opt_param_1 = 100000;
		}
		if(!isdefined(opt_param_3))
		{
			opt_param_3 = 0.1;
		}
	}
	player_entnum = player getentitynumber();
	self.players[player_entnum] notify("visionset_mgr_deactivate");
	self.players[player_entnum] endon("visionset_mgr_deactivate");
	player endon("disconnect");
	self [[func]](player, opt_param_1, opt_param_2, opt_param_3);
}

detour zm_placeable_mine<scripts\zm\_zm_placeable_mine.gsc>::placeable_mine_damage()
{
	self endon("death");
	self setcandamage(1);
	self.health = 100000;
	self.maxhealth = self.health;
	level notify(#mine_placed_zbr, self);
	attacker = undefined;
	while(true)
	{
		self waittill("damage", amount, attacker);
		if(!isdefined(self))
		{
			return;
		}
		self.health = self.maxhealth;
		if(!isplayer(attacker) && isdefined(attacker))
		{
			continue;
		}
		break;
	}
	if(isdefined(level.satchelexplodethisframe) && level.satchelexplodethisframe)
	{
		wait(0.1 + randomfloat(0.4));
	}
	else
	{
		wait(0.05);
	}
	if(!isdefined(self))
	{
		return;
	}
	level.satchelexplodethisframe = 1;
	self thread [[ function() => 
	{
		wait(0.05);
		level.satchelexplodethisframe = 0;
	} ]]();
	self detonate(attacker);
}

proximityweaponobject_validtriggerentity(watcher, ent)
{
	if(level.weaponobjectdebug != 1)
	{
		if(isdefined(self.owner) && ent == self.owner)
		{
			return false;
		}
		if(isvehicle(ent))
		{
			if(watcher.ignorevehicles)
			{
				return false;
			}
			if(self.owner === ent.owner)
			{
				return false;
			}
		}
		if(!weaponobjects::friendlyfirecheck(self.owner, ent, 0))
		{
			return false;
		}
		if(watcher.ignorevehicles && isai(ent) && (!(isdefined(ent.isaiclone) && ent.isaiclone)))
		{
			return false;
		}
	}
	if(lengthsquared(ent getvelocity()) < 10 && !isdefined(watcher.immediatedetonation))
	{
		return false;
	}
	if(!ent weaponobjects::shouldaffectweaponobject(self, watcher))
	{
		return false;
	}
	if(isdefined(self.stun_fx))
	{
		return false;
	}
	if(isplayer(ent))
	{
		if(!isalive(ent))
		{
			return false;
		}
		if(isdefined(watcher.immunespecialty) && ent hasperk(watcher.immunespecialty))
		{
			return false;
		}
		if(ent.team == self.owner.team)
		{
			return false;
		}
	}
	return true;
}

get_flags_trigger_zbr()
{
	return level.aitriggerspawnflags | level.vehicletriggerspawnflags;
}

proximityweaponobject_createdamagearea(watcher)
{
	damagearea = spawn("trigger_radius", self.origin + (0, 0, 0 - watcher.detonateradius), get_flags_trigger_zbr(), watcher.detonateradius, watcher.detonateradius * 2);
	damagearea TriggerIgnoreTeam();
	damagearea enablelinkto();
	damagearea linkto(self);
	self thread weaponobjects::deleteondeath(damagearea);
	return damagearea;
}

detour weaponobjects<scripts\shared\weapons\_weaponobjects.gsc>::proximityweaponobjectdetonation(watcher)
{
	self endon("death");
	self endon("hacked");
	self endon("kill_target_detection");
	weaponobjects::proximityweaponobject_activationdelay(watcher);
	damagearea = proximityweaponobject_createdamagearea(watcher);
	up = anglestoup(self.angles);
	traceorigin = self.origin + up;

	for(;;)
	{
		foreach(zombie in GetAITeamArray(level.zombie_team))
		{
			if(!isdefined(zombie) || !isalive(zombie))
			{
				continue;
			}
			if(zombie isTouching(damagearea))
			{
				if(!proximityweaponobject_validtriggerentity(watcher, zombie))
				{
					continue;
				}
				if(weaponobjects::proximityweaponobject_isspawnprotected(watcher, zombie))
				{
					continue;
				}
				if(zombie damageconetrace(traceorigin, self) > 0)
				{
					thread weaponobjects::proximityweaponobject_waittillframeendanddodetonation(watcher, zombie, traceorigin);
					return;
				}
			}
		}
		foreach(player in getplayers())
		{
			if(player.sessionstate != "playing")
			{
				continue;
			}
			if(isdefined(self.owner) && isdefined(self.owner.team) && player.team == self.owner.team)
			{
				continue;
			}
			if(isdefined(player.ignoreme) && player.ignoreme > 0)
			{
				continue;
			}
			if(player isTouching(damagearea))
			{
				if(!proximityweaponobject_validtriggerentity(watcher, player))
				{
					continue;
				}
				if(weaponobjects::proximityweaponobject_isspawnprotected(watcher, player))
				{
					continue;
				}
				if(player damageconetrace(traceorigin, self) > 0)
				{
					thread weaponobjects::proximityweaponobject_waittillframeendanddodetonation(watcher, player, traceorigin);
					return;
				}
			}
		}
		wait 0.1;
	}
}

detour zm_tomb_tank<scripts\zm\zm_tomb_tank.gsc>::flamethrower_damage_zombies(n_flamethrower_id, str_tag)
{
	self endon("flamethrower_stop_" + n_flamethrower_id);

	if(!isdefined(level.zm_tomb_utility_do_damage_network_safe))
	{
		level.zm_tomb_utility_do_damage_network_safe = @zm_tomb_utility<scripts\zm\zm_tomb_utility.gsc>::do_damage_network_safe;
	}

	if(!isdefined(level.zm_tomb_utility_zombie_gib_guts))
	{
		level.zm_tomb_utility_zombie_gib_guts = @zm_tomb_utility<scripts\zm\zm_tomb_utility.gsc>::zombie_gib_guts;
	}

	if(!isdefined(level.zm_weap_staff_fire_flame_damage_fx))
	{
		level.zm_weap_staff_fire_flame_damage_fx = @zm_weap_staff_fire<scripts\zm\_zm_weap_staff_fire.gsc>::flame_damage_fx;
	}

	while(true)
	{
		a_targets = tank_flamethrower_get_targets(str_tag, n_flamethrower_id);
		foreach(ai_zombie in a_targets)
		{
			if(isalive(ai_zombie))
			{
				if(isai(ai_zombie) && !isplayer(ai_zombie))
				{
					if(str_tag == "tag_flash")
					{
						ai_zombie [[ level.zm_tomb_utility_do_damage_network_safe ]](self, ai_zombie.health, self.var_8f5473ed, "MOD_BURNED");
						ai_zombie thread [[ level.zm_tomb_utility_zombie_gib_guts ]]();
					}
					else
					{
						ai_zombie thread [[ level.zm_weap_staff_fire_flame_damage_fx ]](self.var_8f5473ed, self);
					}
				}
				
				if(isplayer(ai_zombie))
				{
					if(!isdefined(ai_zombie) || ai_zombie.sessionstate != "playing") continue;
					if(isdefined(ai_zombie.is_on_fire) && ai_zombie.is_on_fire) continue;
					ai_zombie thread flame_damage_fx(getweapon("staff_fire_upgraded3"), undefined, 5);
				}
				
				wait(0.05);
			}
		}
		util::wait_network_frame();
	}
}

tank_flamethrower_get_targets(str_tag, n_flamethrower_id)
{
	a_zombies = getaiteamarray(level.zombie_team);
	a_targets = [];
	v_tag_pos = self gettagorigin(str_tag);
	v_tag_angles = self gettagangles(str_tag);
	v_tag_fwd = anglestoforward(v_tag_angles);
	v_kill_pos = v_tag_pos + (v_tag_fwd * 80);
	foreach(ai_zombie in a_zombies)
	{
		dist_sq = distance2dsquared(ai_zombie.origin, v_kill_pos);
		if(dist_sq > (80 * 80))
		{
			continue;
		}
		if(isdefined(ai_zombie.tank_state))
		{
			if(ai_zombie.tank_state == "climbing" || ai_zombie.tank_state == "jumping_down")
			{
				continue;
			}
		}
		v_to_zombie = vectornormalize(ai_zombie.origin - v_tag_pos);
		n_dot = vectordot(v_tag_fwd, ai_zombie.origin);
		if(n_dot < 0.95)
		{
			continue;
		}
		a_targets[a_targets.size] = ai_zombie;
	}

	foreach(player in getplayers())
	{
		if(player.sessionstate != "playing")
		{
			continue;
		}
		
		dist_sq = distance2dsquared(player.origin, v_kill_pos);
		if(dist_sq > (80 * 80))
		{
			continue;
		}
		v_to_zombie = vectornormalize(player.origin - v_tag_pos);
		n_dot = vectordot(v_tag_fwd, player.origin);
		if(n_dot < 0.95)
		{
			continue;
		}
		a_targets[a_targets.size] = player;
	}

	return a_targets;
}

detour sys::setspeedimmediate(speed, acc, dec)
{
	if(isdefined(dec))
	{
		self SetSpeedImmediate(speed, acc, dec);
		return;
	}

	if(isdefined(acc))
	{
		self SetSpeedImmediate(speed, acc);
		return;
	}

	if(isdefined(speed) && speed == 8 && isdefined(level.script) && level.script == "zm_tomb")
	{
		speed = 5;
	}

	self SetSpeedImmediate(speed);
}

wait_and_adjust_speed()
{
	self endon(#death);
	while(self.completed_emerging_into_playable_area is not true)
	{
		wait 0.25;
	}
	self zombie_utility::set_zombie_run_cycle_override_value("super_sprint");
}

detour zombie_utility<scripts\shared\ai\zombie_utility.gsc>::set_run_speed()
{
	self.zombie_move_speed = "walk";
	if(isdefined(level.zombie_force_run))
	{
		level.zombie_force_run--;
		self.zombie_move_speed = "run";
		if(level.zombie_force_run <= 0)
		{
			level.zombie_force_run = undefined;
		}
		return;
	}

	foreach(player in getplayers())
	{
		if(player.zbr_vr11 is true && player.sessionstate == "playing")
		{
			self.zombie_move_speed = "sprint";
			self.desired_zombie_move_speed = "super_sprint";
			self thread wait_and_adjust_speed();
			return;
		}
	}

	sd_intensity = gm_sd_intensity();
	if(sd_intensity > 0.1)
	{
		chance = randomintrange(int((1.0 - sd_intensity) * 90),  101);
		if(chance < 90)
		{
			self.zombie_move_speed = "sprint";
			if(SUPER_SPRINTERS_ENABLED)
			{
				self.desired_zombie_move_speed = "super_sprint";
				self thread wait_and_adjust_speed();
			}
			return;
		}
		self.zombie_move_speed = "sprint";
		return;
	}

	// calculated as 5 * the round number (for now)
	// at round 10, this is 50
	// at round 15, this is 75
	// at round 20, this is 100
	// we want 0 super sprinters till round 10, then a percentage lerp into 1 in 3 by round 20, and probably all super sprinters after round 30 (150)
	// we want early rounds to not be super slow, so until round 8 (40) all will be runners at least
	// on round 8 (40), we begin to cycle in a small percentage of walkers to screw up training (like bo2)
	// we will also slowly cycle out normal runners into sprinters, and sprinters into super sprinters (super sprint bonus logic happens after)

	if(level.zombie_move_speed < 40)
	{
		rand = randomintrange(0, 100);
		// on round 3 (15) we want roughly 1 in 5 sprinters
		// on round 8 (40) we want roughly 3 in 5 sprinters
		target_val = int(((1 + ((level.zombie_move_speed - 15) / (40 - 15) * 2)) / 5) * 100);
		if(rand <= target_val)
		{
			self.zombie_move_speed = "sprint";
			return;
		}
		self.zombie_move_speed = "run";
		return;
	}

	if(!isdefined(level.spawned_walkers_counter))
	{
		level.spawned_walkers_counter = 0;
	}

	level.spawned_walkers_counter++;
	if(!(level.spawned_walkers_counter % int(10 * ((level.zombie_move_speed > 75) ? 2 : 1)))) // 1 in 10 up to round 15, then 1 in 20 (guaranteed)
	{
		self.zombie_move_speed = "walk";
		return;
	}

	diffmod = ((level.zombie_move_speed - 40) / (100 - 40)) * (30); // percentage of super sprinters (0 to 30% linear lerp)

	rand = randomintrange(0,  100);
	if(rand <= diffmod)
	{
		self.zombie_move_speed = "sprint";
		if(SUPER_SPRINTERS_ENABLED)
		{
			self.desired_zombie_move_speed = "super_sprint";
			self thread wait_and_adjust_speed();
		}
		return;
	}

	rand = (rand - diffmod);
	chance_is_sprinter = (100 - diffmod) * min(0.85, 1 - ((100 - min(level.zombie_move_speed, 100)) / 100)); // always a chance to spawn runners
	b_is_sprinter = rand <= chance_is_sprinter;

	self.zombie_move_speed = b_is_sprinter ? "sprint" : "run";
}


detour sys::getdvarstring(target, default_val)
{
	if(!isdefined(target))
	{
		return "";
	}

	if(target == "fs_game" || target == "fs_mod")
	{
		return "usermaps";
	}

	if(!isdefined(default_val))
	{
		return getdvarstring(target);
	}
	return getdvarstring(target, default_val);
}

detour zm<scripts\zm\_zm.gsc>::update_zone_name()
{
	self endon(#bled_out);
	self endon(#disconnect);
	self.zone_name = zm_utility::get_current_zone();
	if(isdefined(self.zone_name))
	{
		self.previous_zone_name = self.zone_name;
	}
	while(isdefined(self))
	{
		if(isdefined(self.zone_name))
		{
			self.previous_zone_name = self.zone_name;
		}
		self.zone_name = zm_utility::get_current_zone();
		wait(randomfloatrange(0.5, 1));
	}
}

detour zm<scripts\zm\_zm.gsc>::update_is_player_valid()
{
	self endon(#bled_out);
	self endon(#disconnect);
	self.am_i_valid = 1;
	while(isdefined(self))
	{
		self.am_i_valid = zm_utility::is_player_valid(self, 1);
		wait(0.05);
	}
}

detour zm_magicbox<scripts\zm\_zm_magicbox.gsc>::can_buy_weapon()
{
	if(level.zbr_sudden_death_finale is true)
	{
		return false;
	}
	if(self getcurrentweapon() == level.zbr_emote_gun)
	{
		return false;
	}
	return self zm_magicbox::can_buy_weapon();
}

detour zm_ai_quadrotor<scripts\zm\_zm_ai_quadrotor.gsc>::player_in_last_stand_within_range(range)
{
	return undefined;
}

detour zm_behavior<scripts\zm\_zm_behavior.gsc>::zombieshouldmoveawaycondition(behaviortreeentity)
{
	return false;
}

detour zm_utility<scripts\zm\_zm_utility.gsc>::give_start_weapon(b_switch_weapon)
{
	if(!isdefined(self.hascompletedsuperee))
	{
		self.hascompletedsuperee = self zm_stats::get_global_stat("DARKOPS_GENESIS_SUPER_EE") > 0;
	}
	if(self.hascompletedsuperee)
	{
		self zm_weapons::weapon_give(level.start_weapon, 0, 0, 1, 0);
		self givemaxammo(level.start_weapon);
		
		spawnweapon = compiler::getspawnweapon(self getxuid(false));

		switch(spawnweapon)
		{
			case 1:
				self zm_weapons::weapon_give(level.zbr_knife, 0, 0, 1, b_switch_weapon);
			break;
			default:
				self zm_weapons::weapon_give(level.super_ee_weapon, 0, 0, 1, b_switch_weapon);
			break;
		}
	}
	else
	{
		self zm_weapons::weapon_give(level.start_weapon, 0, 0, 1, b_switch_weapon);
	}
}

detour zm_perks<scripts\zm\_zm_perks.gsc>::perk_give_bottle_begin(perk)
{
	self zm_utility::increment_is_drinking();
	self zm_utility::disable_player_move_states(1);
	original_weapon = self getcurrentweapon();
	weapon = undefined;
	if(isdefined(level._custom_perks[perk]) && isdefined(level._custom_perks[perk].perk_bottle_weapon))
	{
		weapon = level._custom_perks[perk].perk_bottle_weapon;
	}
	if(!isdefined(weapon))
	{
		self thread [[ function() => 
		{
			wait 0.05;
			self notify("weapon_change_complete");
		}]]();
		return original_weapon;
	}
	self giveweapon(weapon);
	self switchtoweapon(weapon);
	return original_weapon;
}

detour zm_perks<scripts\zm\_zm_perks.gsc>::perk_give_bottle_end(original_weapon, perk)
{
	self endon("perk_abort_drinking");
	self zm_utility::enable_player_move_states();
	weapon = undefined;
	if(isdefined(level._custom_perks[perk]) && isdefined(level._custom_perks[perk].perk_bottle_weapon))
	{
		weapon = level._custom_perks[perk].perk_bottle_weapon;
	}
	if(isdefined(weapon))
	{
		self takeweapon(weapon);
	}
	if(self laststand::player_is_in_laststand() || (isdefined(self.intermission) && self.intermission))
	{
		return;
	}
	if(self zm_utility::is_multiple_drinking())
	{
		self zm_utility::decrement_is_drinking();
		return;
	}
	if(original_weapon != level.weaponnone && !zm_utility::is_placeable_mine(original_weapon) && !zm_equipment::is_equipment_that_blocks_purchase(original_weapon))
	{
		self zm_weapons::switch_back_primary_weapon(original_weapon);
		if(zm_utility::is_melee_weapon(original_weapon))
		{
			self zm_utility::decrement_is_drinking();
			return;
		}
	}
	else
	{
		self zm_weapons::switch_back_primary_weapon();
	}
	if(isdefined(weapon))
	{
		self util::waittill_any_timeout(1.0, "weapon_change_complete");
	}
	if(!self laststand::player_is_in_laststand() && (!(isdefined(self.intermission) && self.intermission)))
	{
		self zm_utility::decrement_is_drinking();
	}
}
#endif