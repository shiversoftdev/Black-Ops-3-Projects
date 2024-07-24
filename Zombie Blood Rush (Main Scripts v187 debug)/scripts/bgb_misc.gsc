bgb_danger_closest_damaged(damage)
{
	if(!isdefined(self.danger_closest_points_remaining))
	{
		return;
	}
	self.danger_closest_points_remaining -= damage;
	if(self.danger_closest_points_remaining < 0)
	{
		self.danger_closest_points_remaining = 0;
	}
	self notify(#danger_closest_points_remaining);
}

blacklist_bgb(bgb)
{
    if(!isdefined(level.bgb_blacklist))
        level.bgb_blacklist = [];
    arrayremoveindex(level.bgb, bgb, true);
    level.bgb_blacklist[level.bgb_blacklist.size] = bgb;
}

fix_bgb_pack()
{
	if(self istestclient()) return;

	if(isdefined(self.bgb_pack_fixed))
	{
		return;
	}

	self.bgb_pack_fixed = true;
	level.bgb_in_use = true;

	self [[ @bgb<scripts\zm\_zm_bgb.gsc>::bgb_player_init ]]();

    if(!isdefined(level.bgb_blacklist))
    {
		level.bgb_blacklist = [];
	}

	self.var_e610f362 ??= [];
	
	// first, purge blacklisted gums from our pack
    // foreach(bgb in level.bgb_blacklist)
    // {
	// 	if(isdefined(self.var_e610f362[bgb]))
	// 	{
	// 		arrayremoveindex(self.var_e610f362, bgb, true);
	// 	}
    //     if(array::contains(self.var_98ba48a2, bgb))
	// 	{
	// 		arrayremovevalue(self.var_98ba48a2, bgb, false);
	// 	}
    // }

	// TODO: THIS WILL FUCK UP THE ORDER, NEED TO FIX THIS BUT FUCK CHEATERS FOR NOW

	// next, purge non-consumable gums from our pack
	bad_gums = [];
	good_gums = [];
	foreach(bgb in self.var_98ba48a2)
	{
		if(!isdefined(level.bgb[bgb]))
		{
			bad_gums[bad_gums.size] = bgb;
			continue;
		}
		if(array::contains(good_gums, bgb)) // duplicate
		{
			continue;
		}
		good_gums[good_gums.size] = bgb;
	}

	self.var_98ba48a2 = arraycopy(good_gums);
	foreach(bgb in bad_gums)
	{
		if(isdefined(self.var_e610f362[bgb]))
		{
			arrayremoveindex(self.var_e610f362, bgb, true);
		}
        if(array::contains(self.var_98ba48a2, bgb))
		{
			arrayremovevalue(self.var_98ba48a2, bgb, false);
		}
	}

	// next, determine suitable fillers for our pack
	possible_fillers = arraycopy(level.bgb);
	bad_gums = [];
	foreach(gum in arraycombine(good_gums, bad_gums, 0, 0))
	{
		arrayremoveindex(possible_fillers, gum, true);
	}

	keys_1 = getArrayKeys(possible_fillers);
	a_keys = array::randomize(keys_1);
	i = 0;
	
	// next, fill our pack back to 5 gums
	while(self.var_98ba48a2.size < 5)
	{
		bgb = a_keys[i];
		s_key = possible_fillers[bgb];
		self.var_e610f362[bgb] = spawnstruct();
		self.var_e610f362[bgb].var_e0b06b47 = bgb_get_start_count(bgb); // quantity of this gum
		self.var_e610f362[bgb].var_b75c376 = 0; // number of times we used it this game
		array::add(self.var_98ba48a2, bgb, false);
		i++;
	}

	i = 0;
	foreach(bgb in self.var_98ba48a2)
	{
		if(!(isdefined(level.bgb[bgb].consumable) && level.bgb[bgb].consumable))
		{
			i++;
			continue;
		}
		self.var_e610f362[bgb].var_e0b06b47 = bgb_get_start_count(bgb);
		self.var_e610f362[bgb].var_b75c376 = 0;
		self SetControllerUIModelValue("bgb_usage_" + i, self.var_e610f362[bgb].var_b75c376);
		i++;
	}

	self thread bgb_watch_consume();
}

detour bgb_machine<scripts\zm\_zm_bgb_machine.gsc>::bgb_machine_select_bgb(player)
{
	if(!player.bgb_pack_randomized.size)
	{
		player.bgb_pack_randomized = array::randomize(player.bgb_pack);

		// foreach(bgb in player.bgb_pack)
		// {
		// 	if(player.var_e610f362[bgb].var_b75c376 >= player.var_e610f362[bgb].var_e0b06b47)
		// 	{
		// 		ArrayRemoveValue(player.bgb_pack_randomized, bgb, false);
		// 	}
		// }

		// if(!player.bgb_pack_randomized.size)
		// {
		// 	player.bgb_pack_randomized[0] = "zm_bgb_in_plain_sight";
		// }
	}
	self.selected_bgb = array::pop_front(player.bgb_pack_randomized);
	clientfield::set("zm_bgb_machine_selection", level.bgb[self.selected_bgb].item_index);
	
	return player bgb::get_bgb_available(self.selected_bgb);
}

bgb_watch_consume()
{
	self endon("disconnect");
	for(;;)
	{
		self waittill("used_consumable");
		i = 0;
		foreach(bgb in self.var_98ba48a2)
		{
			value = 0;
			if(isdefined(self.var_e610f362[bgb]) && isdefined(self.var_e610f362[bgb].var_b75c376))
			{
				value = self.var_e610f362[bgb].var_b75c376;
			}
			self SetControllerUIModelValue("bgb_usage_" + i, value);
			i++;
		}
	}
}

bgb_get_start_count(bgb_name)
{
	if(isdefined(bgb_name) && IsSubStr(bgb_name, "hexed"))
	{
		return 50;
	}
	
	switch(level.bgb[bgb_name].rarity)
	{
		case 1:
			return 7;
		case 2:
			return 5;
		case 3:
			return 3;
		default:
			return 999;
	}
}

free_perk_override(player)
{
	foreach(_player in level.players)
	{
		if(_player.sessionstate != "playing")
		{
			continue;
		}
		if(_player.team != player.team)
		{
			continue;
		}
		free_perk = _player zm_perks::give_random_perk();
		if(isdefined(free_perk) && isdefined(level.perk_bought_func))
		{
			_player [[level.perk_bought_func]](free_perk);
		}
	}
}

bgb_fith_activate()
{
	self endon("disconnect");
	self thread bgb_watch_fith();
	self playsound("zmb_bgb_fearinheadlights_start");
	self playloopsound("zmb_bgb_fearinheadlights_loop");
	self thread zm_bgb_fear_in_headlights::kill_fear_in_headlights();
	self.bgb_fith_active = true;
	self bgb::run_timer(BGB_FITH_ACTIVE_TIME);
	self bgb_fith_terminate();
}

bgb_fith_terminate()
{
	if(self.bgb_fith_active is true)
	{
		self.bgb_fith_active = false;
	}
	self notify("kill_fear_in_headlights");
	foreach(player in level.players)
	{
		player.should_bgb_freeze = false;
	}
	players = getplayers();
	arrayremovevalue(players, self);
	bgb_fith_playersync(players);
}

bgb_watch_fith()
{
	self endon("disconnect");
	self endon("kill_fear_in_headlights");
	n_d_squared = 1200 * 1200;
	for(;;)
	{
		allai = getaiteamarray(level.zombie_team);
		for(i = 0; i < allai.size; i++)
		{
			ai = allai[i];
			if(isfunctionptr(ai?.var_48cabef5) && ai [[ai.var_48cabef5]]())
			{
				continue;
			}
			if(!isdefined(ai))
			{
				continue;
			}
			if(isalive(ai) && !ai ispaused() && (ai.team ?? "") == level.zombie_team && !ai ishidden() && (!(isdefined(ai.bgbignorefearinheadlights) && ai.bgbignorefearinheadlights)))
			{
				pause_ai(ai);
			}
		}
		
		ai_out_of_range = [];
		ai_valid = [];
		for(i = 0; i < allai.size; i++)
		{
			ai = allai[i];
			if(!isdefined(ai))
			{
				continue;
			}
			if(isdefined(ai.aat_turned) && ai.aat_turned && ai ispaused())
			{
				unpause_ai(ai);
				continue;
			}
			if(distance2dsquared(ai.origin, self.origin) >= n_d_squared)
			{
				ai_out_of_range[ai_out_of_range.size] = ai;
				continue;
			}
			ai_valid[ai_valid.size] = ai;
		}
		self check_fith(ai_out_of_range, 1);
		self check_fith(ai_valid, 0, 75);
		self check_player_fith(n_d_squared);
		wait(0.15);
	}
}

pause_ai(ai)
{
	ai notify(#"hash_4e7f43fc");
	ai thread pause_cleanup();
	ai setentitypaused(1);
	ai.var_70a58794 = ai.b_ignore_cleanup;
	ai.b_ignore_cleanup = 1;
	ai.var_7f7a0b19 = ai.is_inert;
	ai.is_inert = 1;
}

pause_cleanup()
{
	self endon(#"hash_4e7f43fc");
	self waittill("death");
	if(isdefined(self) && self ispaused())
	{
		self setentitypaused(0);
		if(!self isragdoll())
		{
			self startragdoll();
		}
	}
}

unpause_ai(ai)
{
	ai notify(#"hash_4e7f43fc");
	ai setentitypaused(0);
	if(isdefined(ai.var_7f7a0b19))
	{
		ai.is_inert = ai.var_7f7a0b19;
	}
	if(isdefined(ai.var_70a58794))
	{
		ai.b_ignore_cleanup = ai.var_70a58794;
	}
	else
	{
		ai.b_ignore_cleanup = 0;
	}
}

check_fith(allai, trace, degree = 45)
{
	a_e_ignore = allai;
	n_cos = cos(degree);
	a_e_ignore = self cantseeentities(a_e_ignore, n_cos, trace);
	foreach(ai in a_e_ignore)
	{
		if(isai(ai) && isalive(ai)) unpause_ai(ai);
	}
}

bgb_rr_activate()
{
    level.var_dfd95560 = 1;
	zm_bgb_round_robbin::function_8824774d(level.round_number + 1);
	foreach(player in level.players)
	{
		if(zm_utility::is_player_valid(player) && player.team == self.team)
		{
			player zm_score::add_to_player_score(5000, 1, "gm_zbr_admin");
		}
	}
}
#define BGB_PS_NUMUSES = 4;
bgb_ps_event()
{
	self endon("disconnect");
	self endon("death");
	self endon("bgb_update");
	self.var_69d5dd7c = BGB_PS_NUMUSES;
	while(self.var_69d5dd7c > 0)
	{
		wait(0.1);
	}
}

attempt_pop_shocks(target)
{
	if(isdefined(self.beastmode) && self.beastmode) return;
    if(!isdefined(self.var_69d5dd7c) || self.var_69d5dd7c <= 0) return;
	self bgb::do_one_shot_use();
	self.var_69d5dd7c = self.var_69d5dd7c - 1;
	self bgb::set_timer(self.var_69d5dd7c, BGB_PS_NUMUSES);
	self playsound("zmb_bgb_popshocks_impact");
	zombie_list = getaiteamarray(level.zombie_team);
	foreach(ai in zombie_list)
	{
		if(!isdefined(ai) || !isalive(ai)) continue;
		test_origin = ai getcentroid();
		dist_sq = distancesquared(target.origin, test_origin);
		if(dist_sq < 16384)
		{
			self thread zm_bgb_pop_shocks::electrocute_actor(ai);
		}
	}
    foreach(enemy in level.players)
    {
        if(enemy == self) continue;
		if(enemy.team == self.team) continue;
        if(enemy.sessionstate != "playing") continue;
        dist_sq = distancesquared(target.origin, enemy.origin + (0,0,50));
        if(dist_sq < 16384)
        {
			if(enemy bgb::is_enabled("zm_bgb_burned_out") || enemy hasperk("specialty_widowswine"))
			{
				enemy dodamage(1, enemy.origin, self, undefined, "none", "MOD_MELEE", 0, level.weaponnone);
				continue;
			}
            self thread pop_shocks_damage(enemy);
        }
    }
}

pop_shocks_damage(player)
{
    player thread electric_cherry_stun();
    player thread electric_cherry_shock_fx();
    player dodamage(int(BGB_POPSHOCKS_PVP_DAMAGE * CLAMPED_ROUND_NUMBER), self.origin, self, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
}

bgb_ps_actordamage(inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex, surfacetype)
{
	if(isdefined(meansofdeath) && meansofdeath == "MOD_MELEE")
	{
		attacker attempt_pop_shocks(self);
	}
	return damage;
}

bgb_ps_vehicledamage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, damagefromunderneath, modelindex, partname, vsurfacenormal)
{
	if(isdefined(smeansofdeath) && smeansofdeath == "MOD_MELEE")
	{
		eattacker attempt_pop_shocks(self);
	}
	return idamage;
}

bgb_burnedout_event()
{
	self endon("disconnect");
	self endon("bgb_update");
	bgb_uses_remaing = BGB_BURNEDOUT_MAX;
	self thread bgb::set_timer(BGB_BURNEDOUT_MAX, BGB_BURNEDOUT_MAX);
	for(;;)
	{
		self waittill("damage", amount, attacker, direction_vec, point, type);
		if("MOD_MELEE" != type) continue;
		self thread bgb_burnedout_result();
		self playsound("zmb_bgb_powerup_burnedout");
		bgb_uses_remaing--;
		self thread bgb::set_timer(bgb_uses_remaing, BGB_BURNEDOUT_MAX);
		self bgb::do_one_shot_use();
		if(!bgb_uses_remaing) return;
		wait(1.5);
	}
}

bgb_burnedout_result()
{
	self clientfield::increment_to_player("zm_bgb_burned_out" + "_1p" + "toplayer");
	self clientfield::increment("zm_bgb_burned_out" + "_3p" + "_allplayers");
	zombies = array::get_all_closest(self.origin, getaiteamarray(level.zombie_team), undefined, undefined, 720);
    players = array::get_all_closest(self.origin, getplayers(), undefined, undefined, 400);
    arrayremovevalue(self, players, false);
    foreach(zombie in zombies)
    {
        if(isdefined(zombie.ignore_nuke) && zombie.ignore_nuke) continue;
        if(isdefined(zombie.marked_for_death) && zombie.marked_for_death) continue;
        if(zm_utility::is_magic_bullet_shield_enabled(zombie)) continue;
        zombie.marked_for_death = 1;
        zombie clientfield::increment("zm_bgb_burned_out" + "_fire_torso" + (isvehicle(zombie) ? "_vehicle" : "_actor"));
        zombie dodamage(zombie.health + 666, zombie.origin, self, self);
        util::wait_network_frame();
    }
    w_weapon = self getCurrentWeapon();
    foreach(player in players)
    {
        if(player.sessionstate != "playing") continue;
        player thread blast_furnace_player_burn(self, w_weapon, BGB_BURNEDOUT_PVP_DAMAGE);
        util::wait_network_frame();
    }
}

bgb_kt_activate()
{
	level notify("bgb_kt_activate");
	level endon("bgb_kt_activate");

	self.kt_ending_time = gettime() + 20000;

	foreach(player in level.players)
	{
		if(player.sessionstate != "playing")
		{
			continue;
		}
		if(player == self) continue;
		if(player.team == self.team) continue;
		player thread bgb_kt_freeze(self);
	}
	level thread watch_kt_players(self);
	
	self zm_bgb_killing_time::activation();
	level notify("kt_end");
}

watch_kt_players(activator)
{
	activator endon("disconnect");
	level endon("kt_end");
	for(;;)
	{
		foreach(player in level.players)
		{
			if(player.sessionstate != "playing")
			{
				continue;
			}
			if(player.team == activator.team)
			{
				continue;
			}
			if(player stalingrad_is_on_dragon())
			{
				continue;
			}
			if(distanceSquared(player getVelocity(), (0, 0, 0)) > 100 || player.bgb_kt_frozen !== true) // if they are moving during killing time, freeze them
			{
				player thread bgb_kt_freeze(activator);
			}
		}
		wait 0.25;
	}
}

bgb_kt_actor_damage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, damagefromunderneath, modelindex, partname)
{
	if(self.archetype !== "zombie")
	{
		return idamage;
	}
	if(isdefined(level.var_48c4b2bf) && (!(isdefined([[level.var_48c4b2bf]](self)) && [[level.var_48c4b2bf]](self))))
	{
		return idamage;
	}
	if(isdefined(self.interdimensional_gun_weapon) && isdefined(self.interdimensional_gun_attacker))
	{
		return idamage;
	}
	if(isplayer(eattacker) && (isdefined(eattacker.forceanhilateondeath) && eattacker.forceanhilateondeath))
	{
		if(isdefined(eattacker.var_d63e841a) && eattacker.var_d63e841a)
		{
			if(!isinarray(eattacker.var_b3258f2e, self))
			{
				eattacker.var_b3258f2e[eattacker.var_b3258f2e.size] = self;
				self thread zombie_utility::zombie_eye_glow_stop();
				self SetPlayerCollision(false);
			}
			return 0;
		}
		self clientfield::set("zombie_instakill_fx", 1);
		return self.health + 1;
	}
	return idamage;
}

bgb_kt_freeze(attacker)
{
	self notify("bgb_kt_freeze");
	self endon("bgb_kt_freeze");
	self endon("disconnect");

	if(self stalingrad_is_on_dragon())
	{
		return;
	}

	self.bgb_kt_frozen = true;
	time = int((attacker.kt_ending_time - gettime()) / 1000);
	activate_effect(SE_KT, time);
	self bgb_freeze_player(true);
	level waittill("kt_end");
	self.bgb_kt_frozen = false;
	if(isdefined(self.bgb_kt_marked) && self.bgb_kt_marked)
	{
		self.bgb_frozen = false;
		self dodamage(int(self.maxhealth * BGB_KILLINGTIME_MARKED_PCT), self.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
		self.bgb_frozen = true;
	}
	self bgb_freeze_player(false);
	self.bgb_kt_marked = false;
}

// delay unset is the buffer window between unfreezing a player and removing their damage reduction
bgb_freeze_player(result, delay_unset = 2.5, b_status_fih = false)
{
	self notify("bgb_freeze_update");
	if(result)
	{
		if(b_status_fih)
		{
			activate_effect(SE_FIH, -1);
		}
		if(isdefined(self.freeze_obj))
		{
			self unlink();
			self.freeze_obj delete();
		}
		if(isdefined(self.var_59bd3c5a) && isalive(self.var_59bd3c5a))
		{
			self.var_59bd3c5a kill(); // kill spider
		}
		if(self laststand::player_is_in_laststand())
		{
			return;
		}
		self freezeControls(true);
		self setentitypaused(true);
		self.bgb_freeze_dmg_protect = false;
		self.bgb_frozen = true;
		self setstance("stand");
		self setvelocity((0,0,0));
		wait 0.05;
		self.freeze_obj = spawn("script_origin", self.origin);
		self.freeze_obj.angles = self getPlayerAngles();
		self linkto(self.freeze_obj);
	}
	else 
	{
		if(b_status_fih)
		{
			clear_effect(SE_FIH);
		}
		self unlink();
		self.bgb_frozen = false;
		self freezeControls(false);
		self setentitypaused(false);
		self thread bgb_unset_frozen_timed(delay_unset);
	}
}

bgb_unset_frozen_timed(time)
{
	self endon("disconnect");
	self endon("bgb_freeze_update");
	self endon("bled_out");
	self.bgb_freeze_dmg_protect = true;
	wait time;
	self.bgb_freeze_dmg_protect = false;
}

bgb_player_frozen()
{
	return isdefined(self.bgb_frozen) && self.bgb_frozen;
}

check_player_fith(distance)
{
	a_p_tofreeze = [];
	players = getplayers();
	arrayremovevalue(players, self);
	foreach(player in players)
	{
		if(player.sessionstate != "playing") continue;
		if(player.team == self.team) continue;
		player.should_bgb_freeze = true;
		if(distance2dsquared(player.origin, self.origin) >= distance) player.should_bgb_freeze = false;
		else a_p_tofreeze[a_p_tofreeze.size] = player;
	}

	group_1 = self cantseeentities(players, cos(45), true);
	group_2 = self cantseeentities(players, cos(75), false);

	foreach(player in arraycombine(group_1, group_2, 0, 0))
	{
		player.should_bgb_freeze = false;
	}
	bgb_fith_playersync(players);
}

bgb_fith_playersync(players)
{
	foreach(player in players)
	{
		if(isdefined(player.bgb_kt_frozen) && player.bgb_kt_frozen) continue;
		res = isdefined(player.should_bgb_freeze) && player.should_bgb_freeze;
		if(res != player bgb_player_frozen())
			player bgb_freeze_player(res, undefined, true);
	}
}

bgb_any_frozen()
{
	return self bgb_player_frozen() || (isdefined(self.bgb_kt_frozen) && self.bgb_kt_frozen);
}

bgb_idle_eyes_activate()
{
	self endon("disconnect");
	players = [self];
	self thread zm_utility::increment_ignoreme();
	self.bgb_idle_eyes_active = 1;
	if(!bgb::function_f345a8ce("zm_bgb_idle_eyes"))
	{
		if(isdefined(level.no_target_override))
		{
			if(!isdefined(level.var_4effcea9))
			{
				level.var_4effcea9 = level.no_target_override;
			}
			level.no_target_override = undefined;
		}
	}
	level thread zm_bgb_idle_eyes::function_1f57344e(self, players);
	self playsound("zmb_bgb_idleeyes_start");
	self playloopsound("zmb_bgb_idleeyes_loop", 1);
	self thread bgb::run_timer(31);
	visionset_mgr::activate("visionset", "zm_bgb_idle_eyes", self, 0.5, 30, 0.5);
	visionset_mgr::activate("overlay", "zm_bgb_idle_eyes", self);
	ret = self util::waittill_any_timeout(30.5, "bgb_about_to_take_on_bled_out", "end_game", "bgb_update", "disconnect");
	self stoploopsound(1);
	self playsound("zmb_bgb_idleeyes_end");
	if(!isdefined(ret) || "timeout" != ret)
	{
		visionset_mgr::deactivate("visionset", "zm_bgb_idle_eyes", self);
	}
	else
	{
		wait(0.5);
	}
	visionset_mgr::deactivate("overlay", "zm_bgb_idle_eyes", self);
	self.bgb_idle_eyes_active = undefined;
	self notify(#"hash_16ab3604");
	zm_bgb_idle_eyes::deactivate(players);
}

bgb_profit_sharing_override(n_points = 0, str_awarded_by = "none", var_1ed9bd9b = false)
{
	if(isdefined(level.intermission) && level.intermission)
	{
		return 0;
	}

	if(!isdefined(n_points))
	{
		return n_points;
	}

	if(str_awarded_by == "zm_bgb_profit_sharing")
	{
		return n_points;
	}

	switch(str_awarded_by)
	{
		case "bgb_machine_ghost_ball":
		case "gm_zbr_admin":
		case "equip_hacker":
		case "magicbox_bear":
		case "reviver":
		{
			return n_points;
		}
		default:
		{
			break;
		}
	}

	if(!var_1ed9bd9b)
	{
		foreach(e_player in level.players)
		{
			if(e_player.sessionstate != "playing")
			{
				continue;
			}
			if(isdefined(e_player) && isdefined(e_player.bgb) && ("zm_bgb_profit_sharing" == e_player.bgb))
			{
				if(e_player.var_6638f10b ?& isarray(e_player.var_6638f10b))
				{
					list = arraycopy(e_player.var_6638f10b);
					if(list ?& array::contains(list, self))
					{
						e_player zm_score::add_to_player_score(n_points, 1, "zm_bgb_profit_sharing");
					}
				}
			}
		}
	}
	else if(isdefined(self.var_6638f10b) && isarray(self.var_6638f10b) && self.var_6638f10b.size > 0)
	{
		foreach(e_player in self.var_6638f10b)
		{
			if(e_player.sessionstate != "playing")
			{
				continue;
			}
			if(isdefined(e_player) && e_player.team == self.team)
			{
				e_player zm_score::add_to_player_score(n_points, 1, "zm_bgb_profit_sharing");
			}
		}
	}
	return n_points;
}

zm_bgb_profit_sharing_enable()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("bgb_update");
	self thread bgb::function_4ed517b9(10000, zm_bgb_profit_sharing::function_ff41ae2d, zm_bgb_profit_sharing::function_3c1690be);
	self thread zm_bgb_profit_sharing::function_677e212b();
}

detour zm_bgb_secret_shopper<scripts\zm\bgbs\_zm_bgb_secret_shopper.gsc>::function_127dc5ca(player)
{
	self notify(#"hash_127dc5ca");
	self endon(#"hash_127dc5ca");
	self endon("kill_trigger");
	self endon(#"hash_a09e2c64");
	player endon("bgb_update");
	player endon("disconnect");
	while(true)
	{
		player waittill("bgb_activation_request");
		if(player.useholdent !== self)
		{
			continue;
		}
		if(!player bgb::is_enabled("zm_bgb_secret_shopper"))
		{
			continue;
		}
		w_current = player.currentweapon;
		n_ammo_cost = player zm_weapons::get_ammo_cost_for_weapon(w_current);
		var_b2860cb0 = 0;
		if(player zm_score::can_player_purchase(n_ammo_cost))
		{
			var_b2860cb0 = player zm_weapons::ammo_give(w_current);
		}
		if(var_b2860cb0)
		{
			player zm_score::minus_to_player_score(n_ammo_cost);
			player bgb::do_one_shot_use(1);
		}
		else
		{
			player bgb::function_ca189700();
		}
		wait(0.05);
	}
}

bgb_mind_blown_activate()
{
	self endon("disconnect");
	self thread bgb_mind_blown_watch();
	self zm_bgb_mind_blown::activation();
}

bgb_mind_blown_watch()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("spawned_player");
	self endon(#"hash_7946ded7");

	n_d_squared = 1200 * 1200;
	targets = [];
	a_e_players = getplayers();
	arrayremovevalue(a_e_players, self, false);
	foreach(player in a_e_players)
	{
		if(player.sessionstate != "playing") continue;
		if(distance2dsquared(player.origin, self.origin) >= n_d_squared)
		{
			continue;
		}
		array::add(targets, player);
	}
	self blow_mind_of_players(targets, 0, 75);
}

blow_mind_of_players(a_e_players, trace, degree = 45)
{
	a_e_ignore = a_e_players;
	players = getplayers();
	n_cos = cos(degree);
	a_e_ignore = self cantseeentities(a_e_ignore, n_cos, trace);
	foreach(player in a_e_players)
	{
		if(array::contains(a_e_ignore, player)) continue;
		self thread blow_mind(player);
	}
}

blow_mind(player)
{
	player shellshock("flashbang", 1.0, 0);
	player arc_damage_ent(self, 1, level.zm_aat_dead_wire_lightning_chain_params);
}

anywhere_but_here_activation()
{
	b_callback_set = false;
	if(level.b_use_poi_spawn_system && (!isdefined(level.var_2c12d9a6) || (level.var_2c12d9a6 != serious::bgb_get_poi_spawn)))
	{
		old_callback = level.var_2c12d9a6;
		level.var_2c12d9a6 = serious::bgb_get_poi_spawn;
		b_callback_set = true;
	}
	self zm_bgb_anywhere_but_here::activation();
	if(b_callback_set)
	{
		level.var_2c12d9a6 = old_callback;
	}
}

bgb_get_poi_spawn()
{
	possible_spawns = arraycopy(level.struct_class_names["targetname"]["poi_spawn_point"] ?? []);
	closest_spawns = array::get_all_closest(self.origin, possible_spawns, undefined, undefined, 10000);
	if(closest_spawns.size < 1)
	{
		return array::random(possible_spawns);
	}
	to_remove = int(min(possible_spawns.size * 0.2, closest_spawns.size));
	if(to_remove < 1 && (possible_spawns.size > 1))
	{
		to_remove = 1;
	}
	for(i = 0; i < to_remove; i++)
	{
		arrayremovevalue(possible_spawns, closest_spawns[i], false);
	}
	return array::random(possible_spawns);
}

bgb_always_done_swiftly_enable()
{
	if(!isdefined(self.bgb_permaperks))
	{
		self.bgb_permaperks = [];
	}
	
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_fastads";
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_stalker";
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_fallheight";
	
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_sprintfire";
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_sprintgrenadelethal";
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_sprintgrenadetactical";
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_unlimitedsprint";
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_sprintrecovery";
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_quieter";

	bgb_permaperks_status_update();
}

detour zm_perks<scripts\zm\_zm_perks.gsc>::give_perk(perk, bought)
{
	self zm_perks::give_perk(perk, bought);
	bgb_permaperks_status_update();
}

perk_lost_func(perk)
{
	bgb_permaperks_status_update();
	if(level._perk_lost_func is function)
	{
		self [[ level._perk_lost_func ]](perk);
	}
}

bgb_permaperks_status_update()
{
	self.bgb_permaperks ??= [];

	b_has_any = false;
	a_str_perks = getarraykeys(level._custom_perks);
	foreach(str_perk in a_str_perks)
	{
		if(self hasperk(str_perk))
		{
			b_has_any = true;
			break;
		}
	}

	if(!b_has_any)
	{
		foreach(perk in self.bgb_permaperks)
		{
			self unsetperk(perk);
		}
	}
	else
	{
		foreach(perk in self.bgb_permaperks)
		{
			self setperk(perk);
		}
	}
}

detour zm_altbody_beast<scripts\zm\_zm_altbody_beast.gsc>::wait_and_appear(no_ignore)
{
	if(!isdefined(level.original_altbody_beast_wait_and_appear))
	{
		level.original_altbody_beast_wait_and_appear = @zm_altbody_beast<scripts\zm\_zm_altbody_beast.gsc>::wait_and_appear;
	}

	if(isdefined(self.bgb_permaperks))
	{
		foreach(perk in self.bgb_permaperks)
		{
			self setperk(perk);
		}
	}

	self [[ level.original_altbody_beast_wait_and_appear ]](no_ignore);
	other = (self IsTestClient()) ? -1 : compiler::getcustomcharacter(self getxuid(false));
    self set_character_for_player(other);
}

bgb_armamental_limit()
{
	// if(!isdefined(self.bgb_permaperks))
	// {
	// 	self.bgb_permaperks = [];
	// }
	
	// self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_fastmeleerecovery";
	// self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_fastequipmentuse";
	// self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_fasttoss";
	// self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_immunetriggerbetty";
	// self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_immunenvthermal";
	// self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_immuneemp";

	// foreach(perk in self.bgb_permaperks)
	// {
	// 	self setperk(perk);
	// }
}

bgb_armamental_enable()
{
	bgb_permaperks = [];
	bgb_permaperks[bgb_permaperks.size] = "specialty_fastmeleerecovery";
	bgb_permaperks[bgb_permaperks.size] = "specialty_fastequipmentuse";
	bgb_permaperks[bgb_permaperks.size] = "specialty_fasttoss";
	bgb_permaperks[bgb_permaperks.size] = "specialty_immunetriggerbetty";
	bgb_permaperks[bgb_permaperks.size] = "specialty_immunenvthermal";
	bgb_permaperks[bgb_permaperks.size] = "specialty_immuneemp";

	foreach(perk in bgb_permaperks)
	{
		self setperk(perk);
	}
}

bgb_armamental_disable()
{
	bgb_permaperks = [];
	bgb_permaperks[bgb_permaperks.size] = "specialty_fastmeleerecovery";
	bgb_permaperks[bgb_permaperks.size] = "specialty_fastequipmentuse";
	bgb_permaperks[bgb_permaperks.size] = "specialty_fasttoss";
	bgb_permaperks[bgb_permaperks.size] = "specialty_immunetriggerbetty";
	bgb_permaperks[bgb_permaperks.size] = "specialty_immunenvthermal";
	bgb_permaperks[bgb_permaperks.size] = "specialty_immuneemp";

	foreach(perk in bgb_permaperks)
	{
		self unsetperk(perk);
	}
}

bgb_sprintfire_enable()
{
	if(!isdefined(self.bgb_permaperks))
	{
		self.bgb_permaperks = [];
	}
	
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_sprintfire";
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_sprintgrenadelethal";
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_sprintgrenadetactical";
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_unlimitedsprint";
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_sprintrecovery";
	self.bgb_permaperks[self.bgb_permaperks.size] = "specialty_quieter";

	bgb_permaperks_status_update();
}

bgb_clear_perks_respawned()
{
	if(!isdefined(self.bgb_permaperks))
	{
		self.bgb_permaperks = [];
	}

	bgb_permaperks_status_update();
}

bgb_crawl_space_activate()
{
	a_ai = getaiarray();
	for(i = 0; i < a_ai.size; i++)
	{
		if(isdefined(a_ai[i]) && isalive(a_ai[i]) && isdefined(a_ai[i].archetype) && a_ai[i].archetype == "zombie" && isdefined(a_ai[i].gibdef))
		{
			var_5a3ad5d6 = distancesquared(self.origin, a_ai[i].origin);
			if(var_5a3ad5d6 < 360000)
			{
				a_ai[i] zombie_utility::makezombiecrawler();
			}
		}
	}

	a_players = getplayers();
	foreach(player in a_players)
	{
		if(player == self) continue;
		if(player.team == self.team) continue;
		if(player.sessionstate != "playing") continue;
		if(distanceSquared(self.origin, player.origin) > 360000) continue;
		player thread prone_for_time(BGB_CRAWL_SPACE_TIME);
		player dodamage(1000, player.origin, self, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
	}
}

prone_for_time(time = 3)
{
	if(self laststand::player_is_in_laststand())
	{
		return;
	}
	activate_effect(SE_CRAWL, time);
	self endon("disconnect");
	self endon("bled_out");
	self notify("prone_for_time");
	self endon("prone_for_time");
	self allowStand(0);
	self allowCrouch(0);
	self allowprone(1);
	self disableusability();
	self disableWeapons();
	self.gm_forceprone = true;
	self setstance("prone");
	wait time;
	self enableWeapons();
	self enableusability();
	self allowStand(1);
	self allowCrouch(1);
	wait 2;
	self.gm_forceprone = false;
}

bgb_phoenix_up_activate()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("bgb_update");
	self.lives = 1;
	self waittill("player_downed");
	while(!isdefined(self.laststandpistol) || ((self getcurrentweapon() ?? level.weaponnone) != self.laststandpistol))
	{
		wait(0.05);
	}
	wait 1.5;
	if(isdefined(self.revivetrigger) && isdefined(self.revivetrigger.beingrevived))
	{
		self.revivetrigger setinvisibletoall();
		self.revivetrigger.beingrevived = 0;
	}
	self bgb::do_one_shot_use();
	self thread bgb::function_7d63d2eb();
	self notify("stop_revive_trigger");
	self zm_laststand::auto_revive(self, false);
	playsoundatposition("zmb_bgb_phoenix_activate", (0, 0, 0));
	self.gm_override_reduce_pts = BGB_PHOENIX_SPAWN_REDUCE_POINTS;
	self restore_earned_points();
	self.gm_override_reduce_pts = 0;
	self.lives = 0;
}

bgb_pup_lost_perk(perk, var_2488e46a = undefined, var_24df4040 = undefined)
{
	self thread bgb::revive_and_return_perk_on_bgb_activation(perk);
	return false;
}

bgb_impatient_event()
{
	self endon("disconnect");
	self endon("bgb_update");
	self waittill("bgb_about_to_take_on_bled_out");
	self thread bgb_impatient_respawn();
}

bgb_impatient_respawn()
{
	self endon("disconnect");
	while(self.sessionstate == "playing" || (self.b_in_death_cutscene is true))
	{
		wait 0.05;
	}
	if(level.zbr_sudden_death_finale is true)
	{
		return;
	}
	msg = self util::waittill_any_timeout(5, "spawned_player");
	if(msg is undefined || msg != "spawned_player")
	{
		self zm::spectator_respawn_player();
	}
	self bgb::do_one_shot_use();
	wait 2;
	self thread bgb::give("zm_bgb_impatient");
}

bgb_extra_credit_activate()
{
	origin = self bgb::function_c219b050();
	self thread spawn_extra_credit(origin);
}

spawn_extra_credit(origin)
{
	self endon("disconnect");
	self endon("bled_out");
	powerup = zm_powerups::specific_powerup_drop("bonus_points_player", origin, undefined, undefined, 0.1);
	powerup.bonus_points_powerup_override = serious::bgb_extra_credit_value;
	level thread powerup_fixup(powerup);
	return powerup;
}

powerup_fixup(powerup)
{
	wait(1);
	if(isdefined(powerup) && (!powerup zm::in_enabled_playable_area() && !powerup zm::in_life_brush()))
	{
		level thread bgb::function_434235f9(powerup);
	}
}

bgb_extra_credit_value()
{
	return BGB_EXTRA_CREDIT_VALUE;
}

bgb_coagulant_activate()
{
	self endon("disconnect");
	self endon("spawned_player");
	self endon("bgb_update");

	self.coagulant_charging = true;
	self.coagulant_damage = 0;
	self thread coagulent_nuke();
	for(;;)
	{
		self waittill("player_downed");
		self.coagulant_exploding = true;
		self notify("coag_damage");
		self.coagulent_nuke.effect_state = 4;
		self.coagulent_nuke clientfield::set("powerup_fx", 4);
		self.coagulent_nuke unlink();
		self.coagulent_nuke.origin = ((self.downed_origin + (0, 0, 70)) ?? (self.origin + (0, 0, 70)));
		self.coagulent_nuke PhysicsLaunch((0, 0, 0), (0, 0, 0));
		wait 0.25;
		self.coagulent_nuke playsound("zbr_coag");
		wait 0.70;
		self bgb_coagulant_do_explode();
		if(isdefined(self.coagulent_nuke))
		{
			self.coagulent_nuke.effect_state = 0;
			self.coagulent_nuke clientfield::set("powerup_fx", 0);
			self.coagulent_nuke linkto(self, "j_helmet", (0,0,20), (0, 0, 0));
		}
		wait 0.05;
		self.coagulant_exploding = false;
		self.coagulant_charging = true;
		self.coagulant_damage = 0;
	}
}

coagulent_nuke()
{
    if(isdefined(self.coagulent_nuke))
    {
        self.coagulent_nuke delete();
    }
    self.coagulent_nuke = spawn("script_model", self getTagOrigin("j_helmet"));
    self.coagulent_nuke thread fx_kill_on_death_or_disconnect(self);
	self.coagulent_nuke thread fx_kill_on_bgb_lost(self);
    self.coagulent_nuke setmodel("p7_zm_power_up_nuke");
    self.coagulent_nuke enableLinkTo();
    self.coagulent_nuke setscale(0.325);
    self.coagulent_nuke linkto(self, "j_helmet", (0,0,20), (0, 0, 0));
    self.coagulent_nuke SetInvisibleToPlayer(self, true);
}

coagulant_gained_damage()
{
	self notify("coag_damage");
	self endon("coag_damage");
	self endon("disconnect");
	self.coagulent_nuke endon("death");

	self bgb::do_one_shot_use();
	// if(self.coagulent_nuke.effect_state !== 3)
	// {
	// 	self.coagulent_nuke.effect_state = 3;
	// 	self.coagulent_nuke clientfield::set("powerup_fx", 3);
	// }
	// wait 0.5;
	// self.coagulent_nuke.effect_state = 0;
	// self.coagulent_nuke clientfield::set("powerup_fx", 0);
}

fx_kill_on_bgb_lost(player)
{
    self endon("death");
	player endon("disconnect");
    while(player.sessionstate == "playing" && player bgb::is_enabled("zm_bgb_coagulant"))
	{
		wait 1;
	}
	self clientfield::set("powerup_fx", 0);
	self delete();
}

bgb_coagulant_do_explode()
{
	radius = max(120, min(400, self.coagulant_damage / 100));
	explosion_point = (self.downed_origin ?? self.origin) + vectorscale((0, 0, 1), 70);

	if(self.coagulent_supercharge is defined and self.coagulent_supercharge > 0)
	{
		radius = int(radius * self.coagulent_supercharge);
	}

	radiusdamage(explosion_point, radius, int(self.coagulant_damage / get_round_damage_boost()), int(self.coagulant_damage / get_round_damage_boost() * 0.75), self, "MOD_EXPLOSIVE", level.weaponnone);
	
	for(i = 0; i < 4; i++)
	{
		grenade = get_map_grenade();
		grenade = self magicgrenadetype(grenade, explosion_point + (cos(i * 90) * radius, sin(i * 90) * radius, 0), vectorscale((0, 0, 1), 1), 0.05);
		grenade.is_fx_grenade = true;
	}

	grenade = get_map_grenade();
	grenade = self magicgrenadetype(grenade, explosion_point, vectorscale((0, 0, 1), 1), 0.05);
	grenade.is_fx_grenade = true;
}

bgb_arms_grace_loadout()
{
	if(isdefined(level.givecustomloadout))
	{
		self [[level.givecustomloadout]]();
	}
}

bgb_arms_grace_dmg()
{
	self endon("bgb_update");
	self.bgb_arms_grace_activation = true;
	level.arms_grace_perks ??= array("specialty_armorvest", "specialty_doubletap2", "specialty_staminup", "specialty_fastreload", "specialty_quickrevive");
	foreach(perk in level.arms_grace_perks)
	{
		if(isdefined(level._custom_perks[perk]))
		{
			self zm_perks::give_perk(perk, false);
		}
	}
	
	// self thread bgb_arms_grace_deactivate();
	self bgb::run_timer(BGB_ARMS_GRACE_DURATION);
	self thread bgb::take();
}

bgb_arms_grace_take()
{
	if(self laststand::player_is_in_laststand() || self.sessionstate != "playing")
	{
		return;
	}

	b_take_perks = self.bgb_arms_grace_activation is true;

	self.bgb_arms_grace_activation = false;
	self.var_e445bfc6 = false;

	wait 1.5;
	if(isdefined(self.bgb) && self.bgb == "zm_bgb_perkaholic")
	{
		return;
	}
	if(self.no_arms_grace_take is true)
	{
		return;
	}
	
	if(b_take_perks)
	{
		foreach(perk in level.arms_grace_perks)
		{
			self.disabled_perks[perk] = 0;
			self notify(perk + "_stop");
		}
	}
}

bgb_arms_grace_deactivate()
{
	self notify("bgb_arms_grace_deactivate");
	self endon("bgb_arms_grace_deactivate");
	self endon("disconnect");
	self endon("bled_out");
	wait BGB_ARMS_GRACE_DURATION + 0.05;
	self bgb::clear_timer();
	self thread bgb_arms_grace_take();
	self thread bgb::take();
}

bgb_ag_active()
{
	return isdefined(self.bgb_arms_grace_activation) && self.bgb_arms_grace_activation;
}

bgb_unquenchable_event()
{
	self endon("disconnect");
	self endon("bgb_update");
	self endon("bled_out");
	for(;;)
	{
		result = self util::waittill_any_return("perk_purchased", "player_downed", "bled_out");
		if(result == "player_downed")
		{
			self bgb::do_one_shot_use(1);
			return;
		}
		self zm_score::add_to_player_score(int(BGB_UNQUENCHABLE_CASHBACK_RD * CLAMPED_ROUND_NUMBER), 0, "gm_zbr_admin");
	}
}

bgb_ips_activate()
{
	self endon("disconnect");
	self notify(#destroy_cosmetics);
	self SetInvisibleToAll();
    self SetInvisibleToPlayer(self, false);
	self thread show_owner_on_attack(self);
	if(isdefined(self.invis_glow))
    {
        self.invis_glow delete();
    }
	if(isdefined(self.invis_mdl_fx))
	{
		self.invis_mdl_fx delete();
	}
    self.invis_glow = spawn("script_model", self.origin);
    self.invis_glow linkto(self);
    self.invis_glow setmodel("tag_origin");
    self.invis_glow thread clone_fx_cleanup(self.invis_glow);
    self.invis_mdl_fx = playfxontag(level.zbr_glow_fx, self.invis_glow, "tag_origin");
	zm_bgb_in_plain_sight::activation();
	self notify("show_owner");
	self setvisibletoall();
	if(isdefined(self.invis_glow))
    {
        self.invis_glow delete();
    }
	if(isdefined(self.invis_mdl_fx))
	{
		self.invis_mdl_fx delete();
	}
	self show();
	self thread zbr_cosmetics_thread();
	self.ignoreme = false;
	self thread delayed_deactivate_ips();
}

delayed_deactivate_ips()
{
	wait 2;
	self stoploopsound(1);
	self playsound("zmb_bgb_plainsight_end");
	visionset_mgr::deactivate("visionset", "zm_bgb_in_plain_sight", self);
	visionset_mgr::deactivate("overlay", "zm_bgb_in_plain_sight", self);
}

bgb_td_activate()
{
	if(!isdefined(level.bgb_td_pvp_prefix))
	{
		return;
	}
	self.__voiceprefix = self.voiceprefix;
	self.voiceprefix = level.bgb_td_pvp_prefix;
    level zm_audio::zmbaivox_playvox(self, "death_whimsy", 1, 10);
	self.voiceprefix = self.__voiceprefix;
}

bgb_btd_enable()
{
	zm_bgb_board_to_death::enable();
	self thread bgb_btd_enable_thread();
}

bgb_btd_enable_thread()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("bgb_update");
	for(;;)
	{
		self waittill("boarding_window", s_window);
		self thread bgb_btd_explode(s_window);
	}
}

bgb_btd_explode(s_window)
{
	wait(0.3);
	a_ai = getplayers();
	a_closest = arraysortclosest(a_ai, s_window.origin, a_ai.size, 0, 240);
	for(i = 0; i < a_closest.size; i++)
	{
		if(a_closest[i] == self) continue;
		if(a_closest[i].sessionstate != "playing") continue;
		a_closest[i] dodamage(int(a_closest[i].health + 100), a_closest[i].origin, self, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
		a_closest[i] playsound("zmb_bgb_boardtodeath_imp");
		wait(randomfloatrange(0.05, 0.2));
	}
}

bgb_umw_speedthread()
{
	self endon("bled_out");
	self endon("disconnect");
	self notify("bgb_umw_speedthread");
	self endon("bgb_umw_speedthread");
	if(!self bgb_opposing_umw())
	{
		return;
	}
	while(self bgb_opposing_umw() && (level.zbr_sudden_death_finale is not true))
	{
		self set_move_speed_scale(0.5, true);
		wait 1;
	}
	self set_move_speed_scale(1, true);
}

bgb_umw_enable()
{
	self __bgb_umw_enable();
	foreach(player in level.players)
	{
		if(player.sessionstate != "playing") continue;
		if(player == self) continue;
		if(player.team == self.team) continue;
		player thread bgb_umw_speedthread();
	}
}

__bgb_umw_enable()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("bgb_update");
	self thread __function_40e95c74();
	if(bgb::function_f345a8ce("zm_bgb_undead_man_walking"))
	{
		return;
	}
	zm_bgb_undead_man_walking::function_b41dc007(1);
	spawner::add_global_spawn_function(level.zombie_team, zm_bgb_undead_man_walking::function_f3d5076d);
}

__function_40e95c74()
{
	self util::waittill_any("disconnect", "bled_out", "bgb_update");
	if(bgb::function_72936116("zm_bgb_undead_man_walking"))
	{
		return;
	}
	spawner::remove_global_spawn_function(level.zombie_team, zm_bgb_undead_man_walking::function_f3d5076d);
	zm_bgb_undead_man_walking::function_b41dc007(0);
}

bgb_opposing_umw()
{
	foreach(player in level.players)
	{
		if(player == self) continue;
		if(player.team == self.team) continue;
		if(player.sessionstate != "playing") continue;
		if(player bgb::is_enabled("zm_bgb_undead_man_walking"))
		{
			return true;
		}
	}
	return false;
}

alchemical_add_to_player_score_override(points = 0, str_awarded_by, var_1ed9bd9b)
{
	if(!(isdefined(self.var_3244073f) && self.var_3244073f))
	{
		return points;
	}

	var_4375ef8a = int(points / 10);
	current_weapon = self getcurrentweapon();
	if(!isdefined(current_weapon))
	{
		return points;
	}

	if(zm_utility::is_offhand_weapon(current_weapon))
	{
		return points;
	}

	if(isdefined(self.is_drinking) && self.is_drinking)
	{
		return points;
	}

	if(current_weapon == level.weaponrevivetool)
	{
		return points;
	}

	var_b8f62d73 = self getweaponammostock(current_weapon);
	var_b8f62d73 = var_b8f62d73 + var_4375ef8a;
	self setweaponammostock(current_weapon, var_b8f62d73);
	self thread alchemical_grant_ammo();
	return 0;
}

alchemical_grant_ammo()
{
	if(!isdefined(self.var_82764e33))
	{
		self.var_82764e33 = 0;
	}
	if(!self.var_82764e33)
	{
		self.var_82764e33 = 1;
		self playsoundtoplayer("zmb_bgb_alchemical_ammoget", self);
		wait(0.5);
		if(isdefined(self))
		{
			self.var_82764e33 = 0;
		}
	}
}

detour bgb<scripts\zm\_zm_bgb.gsc>::function_b616fe7a(var_5827b083 = 0)
{
	var_bb1d9487 = isdefined(level.bgb[self.bgb].validation_func) && !(self [[level.bgb[self.bgb].validation_func]]());
	var_847ec8da = isdefined(level.var_9cef605e) && !self [[level.var_9cef605e]]();
	drinking = (isdefined(self.is_drinking) && self.is_drinking);
	minigun = isdefined(level.zombie_powerup_weapon["minigun"]) && ((self getcurrentweapon()) == level.zombie_powerup_weapon["minigun"]);

	if(self.bgb == "zm_bgb_bullet_boost")
	{
		if(minigun)
		{
			drinking = false;
		}
	}

	if((!var_5827b083 && drinking) || (isdefined(self.bgb_activation_in_progress) && self.bgb_activation_in_progress) || self laststand::player_is_in_laststand() || var_bb1d9487 || var_847ec8da)
	{
		self clientfield::increment_uimodel("bgb_invalid_use");
		self playlocalsound("zmb_bgb_deny_plr");
		return false;
	}
	return true;
}

can_boost_weapon()
{
	if(isdefined(self.is_drinking) && self.is_drinking > 0)
	{
		if(isdefined(level.zombie_powerup_weapon["minigun"]) && ((self getcurrentweapon()) == level.zombie_powerup_weapon["minigun"]))
		{
			return true;
		}
		return false;
	}
	if(self zm_equipment::hacker_active())
	{
		return false;
	}
	if(self zm_utility::in_revive_trigger())
	{
		return false;
	}
	if((self getCurrentWeapon()) == level.weaponnone)
	{
		return false;
	}
	return true;
}

zm_bgb_bullet_boost_validation()
{
	if(self ismeleeing())
	{
		weapon = self zm_utility::get_player_melee_weapon();
		if(isdefined(weapon))
		{
			self.bgb_bullet_boost_weapon = weapon;
		}
		return true;
	}
	if(self isthrowinggrenade())
	{
		if(isdefined(self.grenadepullbackweapon))
		{
			self.bgb_bullet_boost_weapon = self.grenadepullbackweapon;
			return true;
		}
	}
	current_weapon = self getcurrentweapon();
	if(current_weapon == level.weaponnone)
	{
		return false;
	}
	if(!self can_boost_weapon() || self laststand::player_is_in_laststand() || (isdefined(self.intermission) && self.intermission))
	{
		return false;
	}
	if(self isswitchingweapons())
	{
		return false;
	}
	self.bgb_bullet_boost_weapon = current_weapon;
	return true;
}

zm_bgb_bullet_boost_activation()
{
	self endon("bled_out");
	self endon("disconnect");
	self playsoundtoplayer("zmb_bgb_bullet_boost", self);
	self util::waittill_any_timeout(1, "weapon_change_complete", "bled_out", "disconnect");
	current_weapon = self.bgb_bullet_boost_weapon;
	if(current_weapon is undefined)
	{
		current_weapon = self getcurrentweapon();
	}
	current_weapon = self zm_weapons::switch_from_alt_weapon(current_weapon);
	self aat::acquire(current_weapon);
}

zm_bgb_power_vacuum_enable()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("bgb_update");
	level.powerup_drop_count = 0;
	if(!isdefined(level.zbr_powerup_drop_count))
	{
		level.zbr_powerup_drop_count = [];
	}

	for(;;)
	{
		level waittill("powerup_dropped");
		self bgb::do_one_shot_use();
		level.zbr_powerup_drop_count[self.team] = 0;
	}
}