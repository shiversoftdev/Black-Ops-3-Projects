WatchMaxAmmo()
{
    self endon("bled_out");
    self endon("spawned_player");
    self endon("disconnect");
    for(;;)
    {
        self waittill("zmb_max_ammo");
        foreach(weapon in self getweaponslist(1))
        {
			if(isdefined(weapon.clipsize) && weapon.clipsize > 0)
            {
				self setWeaponAmmoClip(weapon, weapon.clipsize);
			}
		}
    }
}

max_ammo_regen_point(origin, team)
{
	mod = spawn("script_model", origin);
	mod setmodel("p7_zm_power_up_max_ammo");
	mod clientfield::set("powerup_fx", 4);

	for(i = 0; i < 10; i++)
	{
		wait 1;
		playsoundatposition("zmb_powerup_grabbed", mod.origin);
		playfx(level._effect["powerup_grabbed_caution"], mod.origin);
		foreach(player in getplayers())
		{
			if(player.team != team || player.sessionstate != "playing")
			{
				continue;
			}
			if(distance2d(player.origin, mod.origin) > 150)
			{
				continue;
			}
			
			playsoundatposition("zmb_bgb_alchemical_ammoget", player.origin);
			
			weapon  = player GetCurrentWeapon();
			offhand = player GetCurrentOffhand();
			
			if(weapon != level.weaponNone)
			{
				player SetWeaponAmmoClip(weapon, 1337);
				player givemaxammo(weapon);
			}
			
			if(offhand != level.weaponNone)
			{
				player givemaxammo(offhand);
			}

			foreach(weapon in player getweaponslist(1))
			{
				if(isdefined(weapon.clipsize) && weapon.clipsize > 0)
				{
					player setWeaponAmmoClip(weapon, weapon.clipsize);
				}
				player givemaxammo(weapon);
			}
		}
	}
	
	mod delete();
}

detour zm_powerup_full_ammo<scripts\zm\_zm_powerup_full_ammo.gsc>::grab_full_ammo(player)
{
	level.full_ammo_fn ??= @zm_powerup_full_ammo<scripts\zm\_zm_powerup_full_ammo.gsc>::full_ammo_powerup;
	level thread [[ level.full_ammo_fn ]](self, player);
	if(is_team_enabled_bgb_real("zm_bgb_temporal_gift", player))
	{
		thread max_ammo_regen_point(self.origin, player.team);
	}
}

carpenter_override(player)
{
	self thread start_carpenter_new(self.origin, player);
	foreach(_player in level.players)
	{
		if(_player.team != player.team)
		{
			continue;
		}
		if(_player.sessionstate != "playing")
		{
			continue;
		}
		if(!isdefined(_player.hasriotshield) || !_player.hasriotshield)
		{
			continue;
		}
		damagemax = level.weaponriotshield.weaponstarthitpoints;
		if(isdefined(_player.weaponriotshield))
		{
			damagemax = _player.weaponriotshield.weaponstarthitpoints;
		}
		current_health = _player damageriotshield(0);
		_player damageriotshield(-1 * (damagemax - current_health));
		_player updateriotshieldmodel();
		_player clientfield::set_player_uimodel("zmInventory.shield_health", 1.0f);
		_player giveMaxAmmo(level.weaponriotshield);
	}
}

repair_far_boards(barriers, upgrade, player)
{
	for(i = 0; i < barriers.size; i++)
	{
		barrier = barriers[i];
		player notify(#boarding_window, barrier);
		if(zm_utility::all_chunks_intact(barrier, barrier.barrier_chunks))
		{
			continue;
		}
		if(isdefined(barrier.zbarrier))
		{
			a_pieces = barrier.zbarrier getzbarrierpieceindicesinstate("open");
			if(isdefined(a_pieces))
			{
				for(xx = 0; xx < a_pieces.size; xx++)
				{
					chunk = a_pieces[xx];
					if(upgrade)
					{
						barrier.zbarrier zbarrierpieceuseupgradedmodel(chunk);
						barrier.zbarrier.chunk_health[chunk] = barrier.zbarrier getupgradedpiecenumlives(chunk);
						continue;
					}
					barrier.zbarrier zbarrierpieceusedefaultmodel(chunk);
					barrier.zbarrier.chunk_health[chunk] = 0;
				}
			}
			for(x = 0; x < barrier.zbarrier getnumzbarrierpieces(); x++)
			{
				barrier.zbarrier setzbarrierpiecestate(x, "closed");
				barrier.zbarrier showzbarrierpiece(x);
			}
		}
		if(isdefined(barrier.clip))
		{
			barrier.clip triggerenable(1);
			barrier.clip disconnectpaths();
		}
		else
		{
			zm_blockers::blocker_disconnect_paths(barrier.neg_start, barrier.neg_end);
		}
		if((i % 4) == 0)
		{
			util::wait_network_frame();
		}
	}
}

carpenter_upgrade_tg(window_boards)
{
	self endon(#disconnect);
	b_any_tg = false;
	foreach(player in getplayers())
	{
		if(player.team == self.team && player bgb::is_enabled("zm_bgb_temporal_gift"))
		{
			b_any_tg = true;
			break;
		}
	}
	if(!b_any_tg)
	{
		return;
	}

	endtime = gettime() + 15000;
	next_repair_time = gettime() + 2000;
	while(gettime() < endtime)
	{
		do_repair = gettime() >= next_repair_time;
		if(do_repair)
		{
			next_repair_time = gettime() + 2000;
		}
		foreach(_player in getplayers())
		{
			if(_player.team == self.team)
			{
				if(do_repair)
				{
					thread do_repair_near_boards(get_near_boards_plr(_player, window_boards), _player);
				}

				if(!isdefined(_player.hasriotshield) || !_player.hasriotshield)
				{
					continue;
				}
				damagemax = level.weaponriotshield.weaponstarthitpoints;
				if(isdefined(_player.weaponriotshield))
				{
					damagemax = _player.weaponriotshield.weaponstarthitpoints;
				}
				current_health = _player damageriotshield(0);
				_player damageriotshield(-1 * (damagemax - current_health));
				_player updateriotshieldmodel();
				_player clientfield::set_player_uimodel("zmInventory.shield_health", 1.0f);
				_player giveMaxAmmo(level.weaponriotshield);
			}
		}
		wait 0.05;
	}
}

get_near_boards_plr(player, windows)
{
	boards_near_players = [];
	for(j = 0; j < windows.size; j++)
	{
		origin = windows[j].origin;
		if(isdefined(windows[j].zbarrier))
		{
			origin = windows[j].zbarrier.origin;
		}
		if(distancesquared(player.origin, origin) <= 562500)
		{
			boards_near_players[boards_near_players.size] = windows[j];
		}
	}
	return boards_near_players;
}

do_repair_near_boards(boards_near_players, player)
{
	for(i = 0; i < boards_near_players.size; i++)
	{
		window = boards_near_players[i];
		num_chunks_checked = 0;
		last_repaired_chunk = undefined;
		for(;;)
		{
			if(zm_utility::all_chunks_intact(window, window.barrier_chunks))
			{
				break;
			}
			player notify(#boarding_window, window);
			chunk = zm_utility::get_random_destroyed_chunk(window, window.barrier_chunks);
			if(!isdefined(chunk))
			{
				break;
			}
			window thread zm_blockers::replace_chunk(window, chunk, undefined, zm_powerups::is_carpenter_boards_upgraded(), 1);
			last_repaired_chunk = chunk;
			if(isdefined(window.clip))
			{
				window.clip triggerenable(1);
				window.clip disconnectpaths();
			}
			else
			{
				zm_blockers::blocker_disconnect_paths(window.neg_start, window.neg_end);
			}
			util::wait_network_frame();
			num_chunks_checked++;
			if(num_chunks_checked >= 20)
			{
				break;
			}
		}
		if(isdefined(window.zbarrier))
		{
			if(isdefined(last_repaired_chunk))
			{
				while(window.zbarrier getzbarrierpiecestate(last_repaired_chunk) == "closing")
				{
					wait(0.05);
				}
				if(isdefined(window._post_carpenter_callback))
				{
					window [[window._post_carpenter_callback]]();
				}
			}
			continue;
		}
		while(isdefined(last_repaired_chunk) && last_repaired_chunk.state == "mid_repair")
		{
			wait(0.05);
		}
	}
}

start_carpenter_new(origin, player)
{
	level.carpenter_powerup_active = 1;
	window_boards = struct::get_array("exterior_goal", "targetname");
	if(isdefined(level._additional_carpenter_nodes))
	{
		window_boards = arraycombine(window_boards, level._additional_carpenter_nodes, 0, 0);
	}
	carp_ent = spawn("script_origin", (0, 0, 0));
	carp_ent playloopsound("evt_carpenter");
	boards_near_players = zm_powerup_carpenter::get_near_boards(window_boards);
	boards_far_from_players = zm_powerup_carpenter::get_far_boards(window_boards);

	player thread carpenter_upgrade_tg(window_boards);
	level repair_far_boards(boards_far_from_players, zm_powerups::is_carpenter_boards_upgraded(), player);

	do_repair_near_boards(boards_near_players, player);

	carp_ent stoploopsound(1);
	carp_ent playsoundwithnotify("evt_carpenter_end", "sound_done");
	carp_ent waittill(#sound_done);
	players = getplayers();
	for(i = 0; i < players.size; i++)
	{
		if(players[i].team != player.team)
		{
			continue;
		}
		players[i] zm_score::player_add_points("carpenter_powerup", 200);
	}
	carp_ent delete();
	level notify(#carpenter_finished);
	level.carpenter_powerup_active = undefined;
}

updateriotshieldmodel()
{
	wait(0.05);
	self.hasriotshield = 0;
	self.weaponriotshield = level.weaponnone;
	foreach(weapon in self getweaponslist(1))
	{
		if(weapon.isriotshield)
		{
			self.hasriotshield = 1;
			self.weaponriotshield = weapon;
		}
	}
	current = self getcurrentweapon();
	self.hasriotshieldequipped = current.isriotshield;
	if(self.hasriotshield)
	{
		self clientfield::set_player_uimodel("hudItems.showDpadDown", 1);
		if(self.hasriotshieldequipped)
		{
			self zm_weapons::clear_stowed_weapon();
		}
		else
		{
			self zm_weapons::set_stowed_weapon(self.weaponriotshield);
		}
	}
	else
	{
		self clientfield::set_player_uimodel("hudItems.showDpadDown", 0);
		self setstowedweapon(level.weaponnone);
	}
	self refreshshieldattachment();
}

nuke_exclusion_zone(player)
{
	player endon(#disconnect);
	total_damage = CLAMPED_ROUND_NUMBER / get_round_damage_boost() * 250;
	time = 10;
	tick_damage = total_damage / time;
	for(i = 0; i < time; i++)
	{
		foreach(e_player in getplayers())
		{
			if(e_player.team == player.team)
			{
				continue;
			}
			if(e_player.sessionstate != "playing")
			{
				continue;
			}
			if(!e_player has_active_status_effect(SE_EXCLUSION_ZONE))
			{
				e_player activate_effect(SE_EXCLUSION_ZONE, time - i);
				e_player thread playFXTimedOnTag(level._effect["character_fire_death_torso"], "J_SpineLower", time - i);
				e_player thread playFXTimedOnTag(level._effect["character_fire_death_torso"], "J_Spine1", time - i);
			}
			if(e_player.health > tick_damage)
			{
				e_player dodamage(int(tick_damage), e_player.origin, player, player, undefined, "MOD_UNKNOWN", 0, level.weaponnone);
			}
			else if(e_player.health == 1)
			{
				e_player.health = 2;
				e_player dodamage(1, e_player.origin, player, player, undefined, "MOD_UNKNOWN", 0, level.weaponnone);
			}
			else
			{
				e_player dodamage(int(min(e_player.health - 1, tick_damage)), e_player.origin, player, player, undefined, "MOD_UNKNOWN", 0, level.weaponnone);
			}
		}
		foreach(zombie in getaiteamarray(level.zombie_team))
		{
			zombie doDamage(int(zombie.maxhealth * 0.4), zombie.origin, player);
		}
		wait 1;
	}
}

nuke_override(player)
{
    self thread zm_powerup_nuke::grab_nuke(player);
	if(is_team_enabled_bgb_real("zm_bgb_temporal_gift", player))
	{
		thread nuke_exclusion_zone(player);
	}
    foreach(person in level.players)
    {
        if(person.sessionstate != "playing") continue;
        if(person == player) continue;
		if(person.team == player.team) continue;
		n_nuke_round_min = WIN_NUMPOINTS * NUKE_HEALTH_PERCENT * min(1.0, pow(CLAMPED_ROUND_NUMBER / 20, 1.5));
		dmg = int(min(person.maxhealth - 1, max(n_nuke_round_min, person.maxhealth * NUKE_HEALTH_PERCENT)));

		if(person bgb::is_enabled("zm_bgb_coagulant"))
		{
			if(!isdefined(person.coagulant_damage))
			{
				person.coagulant_damage = 0;
			}
			if(!isdefined(person.coagulent_supercharge))
			{
				person.coagulent_supercharge = 1.0;
			}
			person.coagulent_supercharge *= 1.15;
			person.coagulant_damage += int(dmg * 2);
			person.coagulant_damage = int(person.coagulant_damage * person.coagulent_supercharge);
			continue;
		}

        person dodamage(int(dmg / get_round_damage_boost()), person.origin + vectorNormalize((player geteye()) - (person geteye())) * 16, player, player, undefined, "MOD_EXPLOSIVE", 0, level.weaponnone);
    }
}

player_can_drop_powerups(player, weapon)
{
	if(zm_utility::is_tactical_grenade(weapon) || !level flag::get("zombie_drop_powerups"))
	{
		return false;
	}
	if(isdefined(level.no_powerups) && level.no_powerups)
	{
		return false;
	}
	if(isdefined(level.use_powerup_volumes) && level.use_powerup_volumes)
	{
		volumes = getentarray("no_powerups", "targetname");
		foreach(volume in volumes)
		{
			if(player istouching(volume)) return false;
		}
	}
	return true;
}

powerup_grab_get_players_override()
{
    players = getplayers();
    final = [];
    foreach(player in players)
    {
        if(player.sessionstate != "playing") continue;
		if(isdefined(player.gm_forceprone) && player.gm_forceprone) continue;
        if(!isdefined(player.team) || (player.team == level.zombie_team)) continue;
        if(isdefined(player.no_grab_powerup) && player.no_grab_powerup) continue;
		if(player.do_zbr_cam === true) continue;
		if(player.b_in_death_cutscene is true) continue;
		if(isdefined(self.blood_hunter_points))
		{
			if((self.bh_owner.team == player.team))
			{
				continue;
			}
		}
		else
		{
			if(isdefined(player.wager_powerups) && player.wager_powerups)
			{
				continue;
			}
		}
		if(player is_in_altbody()) continue;
        final[final.size] = player;
        if(isalive(player.var_4bd1ce6b))
		{
			final[final.size] = player.var_4bd1ce6b;
		}
    }

    if(isdefined(level.ai_robot))
	{
		final[final.size] = level.ai_robot;
	}

    if(isdefined(level.ai_companion))
	{
		final[final.size] = level.ai_companion;
	}

    return final;
}

zombie_death_animscript_override()
{
	level.gm_last_killed_ent = self;
}

custom_zombie_powerup_drop(drop_point = (0,0,0))
{
	b_drop_nade = isdefined(level.gm_last_killed_ent) && !isplayer(level.gm_last_killed_ent) && isdefined(level.gm_last_killed_ent.wager_zomb_nades) && level.gm_last_killed_ent.wager_zomb_nades;
	use_pv = isdefined(level.gm_last_killed_ent) && isdefined(level.gm_last_killed_ent.power_vacuum) && level.gm_last_killed_ent.power_vacuum;
	b_drop_nade = b_drop_nade && isdefined(level.gm_last_killed_ent.__attacker) && isplayer(level.gm_last_killed_ent.__attacker);

	team = level.zombie_team;

	if(isdefined(level.gm_last_killed_ent) && isdefined(level.gm_last_killed_ent.__attacker) && isdefined(level.gm_last_killed_ent.__attacker.team))
	{
		team = level.gm_last_killed_ent.__attacker.team;
	}

	if(!isdefined(level.zbr_powerup_drop_count))
	{
		level.zbr_powerup_drop_count = [];
	}

	if(!isdefined(level.zbr_powerup_drop_count[team]))
	{
		level.zbr_powerup_drop_count[team] = 0;
	}

	if(!isdefined(level.zbr_zombie_powerup_index))
	{
		level.zbr_zombie_powerup_index = [];
	}

	if(!isdefined(level.zbr_zombie_powerup_index[team]))
	{
		level.zbr_zombie_powerup_index[team] = 0;
	}

	if(!isdefined(level.zbr_zombie_powerup_array))
	{
		level.zbr_zombie_powerup_array = [];
	}

	if(!isdefined(level.zbr_zombie_powerup_array[team]))
	{
		level.zbr_zombie_powerup_array[team] = array::randomize(level.zombie_powerup_array);
	}

	if(b_drop_nade && (randomIntRange(0, 100) <= WAGER_DROPNADE_CHANCE))
	{
		grenade = get_map_grenade();
		grenade = level.gm_last_killed_ent.__attacker magicgrenadetype(grenade, drop_point, vectorscale((0, 0, 1), 300), 2);
		grenade.is_wager_grenade = true;
		grenade.wager_owner = level.gm_last_killed_ent.__attacker;
	}

	level.powerup_drop_count = level.zbr_powerup_drop_count[team];
	level.zombie_powerup_array = level.zbr_zombie_powerup_array[team];
	level.zombie_powerup_index = level.zbr_zombie_powerup_index[team];

	if(isdefined(level._custom_zombie_powerup_drop))
	{
		b_result = [[level._custom_zombie_powerup_drop]](drop_point);
	}

	if(isdefined(b_result) && b_result)
	{
		level.zbr_powerup_drop_count[team]++;
		level.zbr_zombie_powerup_array[team] = level.zombie_powerup_array;
		level.zbr_zombie_powerup_index[team] = level.zombie_powerup_index;
		return true;
	}

	if(!use_pv && (level.zbr_powerup_drop_count[team] >= level.zbr_maxdrops))
	{
		return true;
	}

	if(!isdefined(level.zombie_include_powerups) || level.zombie_include_powerups.size == 0)
	{
		return true;
	}

	
	rand_drop = randomint(100);
	if(use_pv && rand_drop < 20)
	{
		debug = "zm_bgb_power_vacuum";
	}
	else if(rand_drop > 2)
	{
		if(!level.zombie_vars["zombie_drop_item"])
		{
			return true;
		}
		debug = "score";
	}
	else
	{
		debug = "random";
	}
	
	playable_area = getentarray("player_volume", "script_noteworthy");
	level.zbr_powerup_drop_count[team]++;
	powerup = zm_net::network_safe_spawn("powerup", 1, "script_model", drop_point + vectorscale((0, 0, 1), 40));
	powerup.plr_team = team;
	valid_drop = 0;
	for(i = 0; i < playable_area.size; i++)
	{
		if(powerup istouching(playable_area[i]))
		{
			valid_drop = 1;
			break;
		}
	}
	if(valid_drop && level.rare_powerups_active)
	{
		pos = (drop_point[0], drop_point[1], drop_point[2] + 42);
		if(zm_powerups::check_for_rare_drop_override(pos))
		{
			level.zombie_vars["zombie_drop_item"] = 0;
			valid_drop = 0;
		}
	}
	if(!valid_drop)
	{
		level.zbr_powerup_drop_count[team]--;
		powerup delete();
		return true;
	}


	powerup zm_powerups::powerup_setup();
	level.zbr_zombie_powerup_array[team] = level.zombie_powerup_array;
	level.zbr_zombie_powerup_index[team] = level.zombie_powerup_index;

	powerup thread zm_powerups::powerup_timeout();
	powerup thread zm_powerups::powerup_wobble();
	powerup thread zm_powerups::powerup_grab();
	powerup thread zm_powerups::powerup_move();
	powerup thread zm_powerups::powerup_emp();
	level.zombie_vars["zombie_drop_item"] = 0;
	level notify("powerup_dropped", powerup);
	return true;
}

watch_zombieblood()
{
	level endon("end_game");
	
	for(;;)
	{
		level waittill("player_zombie_blood", player);
		player thread pvp_zombie_blood_invis();
	}
}

pvp_zombie_blood_invis()
{
	self endon("bled_out");
	self endon("disconnect");

	self SetInvisibleToAll();
	self notify(#destroy_cosmetics);
    self SetInvisibleToPlayer(self, false);
	self thread show_owner_on_attack(self, true);
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
	self waittill("zombie_blood_over");
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
	self thread zbr_cosmetics_thread();
	self show();
	self.ignoreme = false;
	wait 2;
	self stoploopsound(1);
	visionset_mgr::deactivate("visionset", "zm_tomb_in_plain_sight", self);
	visionset_mgr::deactivate("overlay", "zm_tomb_in_plain_sight", self);
}

func_grab_fire_sale(player)
{
	cm_bgbm_activate_all();
	if(isdefined(level.zbr_gm_osguns))
	{
		foreach(s_gun in level.zbr_gm_osguns)
		{
			s_gun.next = gettime();
		}
	}
	
	if(isfunctionptr(level._custom_powerups["fire_sale"]._grab_powerup))
	{
		self thread [[ level._custom_powerups["fire_sale"]._grab_powerup ]](player);
	}
}

firesale_chest_is_leaving()
{
	for(i = 0; i < level.chests.size; i++)
	{
		if(i !== level.chest_index)
		{
			if(level.chests[i].zbarrier.state === "leaving" || level.chests[i].zbarrier.state === "open" || level.chests[i].zbarrier.state === "close" || level.chests[i].zbarrier.state === "closing")
			{
				return true;
			}
		}
	}
	return false;
}

detour zm_powerup_fire_sale<scripts\zm\_zm_powerup_fire_sale.gsc>::start_fire_sale(item)
{
	if(!isdefined(level.zm_powerup_fire_sale_toggle_fire_sale_on))
	{
		level.zm_powerup_fire_sale_toggle_fire_sale_on = @zm_powerup_fire_sale<scripts\zm\_zm_powerup_fire_sale.gsc>::toggle_fire_sale_on;
		level.zm_powerup_fire_sale_check_to_clear_fire_sale = @zm_powerup_fire_sale<scripts\zm\_zm_powerup_fire_sale.gsc>::check_to_clear_fire_sale;
	}
	if(isdefined(level.custom_firesale_box_leave) && level.custom_firesale_box_leave)
	{
		while(firesale_chest_is_leaving())
		{
			wait(0.05);
		}
	}
	if(level.zombie_vars["zombie_powerup_fire_sale_time"] > 0 && (isdefined(level.zombie_vars["zombie_powerup_fire_sale_on"]) && level.zombie_vars["zombie_powerup_fire_sale_on"]))
	{
		level.zombie_vars["zombie_powerup_fire_sale_time"] = level.zombie_vars["zombie_powerup_fire_sale_time"] + 30;
		if(bgb::is_team_enabled("zm_bgb_temporal_gift"))
		{
			level.zombie_vars["zombie_powerup_fire_sale_time"] += 60;
		}
		return;
	}
	level notify(#"hash_3b3c2756");
	level endon(#"hash_3b3c2756");
	level thread zm_audio::sndannouncerplayvox("fire_sale");
	level.zombie_vars["zombie_powerup_fire_sale_on"] = 1;
	level.disable_firesale_drop = 1;
	level thread [[ level.zm_powerup_fire_sale_toggle_fire_sale_on ]]();
	level.zombie_vars["zombie_powerup_fire_sale_time"] = 30;
	if(bgb::is_team_enabled("zm_bgb_temporal_gift"))
	{
		level.zombie_vars["zombie_powerup_fire_sale_time"] = level.zombie_vars["zombie_powerup_fire_sale_time"] + 90;
	}
	while(level.zombie_vars["zombie_powerup_fire_sale_time"] > 0)
	{
		wait(0.05);
		level.zombie_vars["zombie_powerup_fire_sale_time"] = level.zombie_vars["zombie_powerup_fire_sale_time"] - 0.05;
	}
	level thread [[level.zm_powerup_fire_sale_check_to_clear_fire_sale]]();
	level.zombie_vars["zombie_powerup_fire_sale_on"] = 0;
	level notify(#fire_sale_off);
}

is_team_enabled_bgb_real(bgb, player)
{
	foreach(p in getplayers())
	{
		if(p.team == player.team && p bgb::is_enabled(bgb))
		{
			return true;
		}
	}
	return false;
}

detour zm_powerup_double_points<scripts\zm\_zm_powerup_double_points.gsc>::double_points_powerup(drop_item, player)
{
	level notify("powerup points scaled_" + player.team);
	level endon("powerup points scaled_" + player.team);
	team = player.team;
	level thread zm_powerups::show_on_hud(team, "double_points");
	level.zombie_vars[team]["zombie_point_scalar"] = 2;
	players = getplayers();
	for(player_index = 0; player_index < players.size; player_index++)
	{
		if(team == players[player_index].team)
		{
			players[player_index] clientfield::set_player_uimodel("hudItems.doublePointsActive", 1);
		}
	}
	n_wait = 30;
	if(is_team_enabled_bgb_real("zm_bgb_temporal_gift", player))
	{
		n_wait = n_wait + 60;
	}
	wait(n_wait);
	level.zombie_vars[team]["zombie_point_scalar"] = 1;
	players = getplayers();
	for(player_index = 0; player_index < players.size; player_index++)
	{
		if(team == players[player_index].team)
		{
			players[player_index] clientfield::set_player_uimodel("hudItems.doublePointsActive", 0);
		}
	}
}

detour zm_powerup_insta_kill<scripts\zm\_zm_powerup_insta_kill.gsc>::insta_kill_powerup(drop_item, player)
{
	level notify("powerup instakill_" + player.team);
	level endon("powerup instakill_" + player.team);
	if(isdefined(level.insta_kill_powerup_override))
	{
		level thread [[level.insta_kill_powerup_override]](drop_item, player);
		return;
	}
	team = player.team;
	level thread zm_powerups::show_on_hud(team, "insta_kill");
	level.zombie_vars[team]["zombie_insta_kill"] = 1;
	n_wait_time = 30;
	if(is_team_enabled_bgb_real("zm_bgb_temporal_gift", player))
	{
		n_wait_time = n_wait_time + 60;
	}
	wait(n_wait_time);
	level.zombie_vars[team]["zombie_insta_kill"] = 0;
	players = getplayers(team);
	for(i = 0; i < players.size; i++)
	{
		if(isdefined(players[i]))
		{
			players[i] notify(#insta_kill_over);
		}
	}
}

detour zm_powerup_weapon_minigun<scripts\zm\_zm_powerup_weapon_minigun.gsc>::minigun_weapon_powerup(ent_player, time)
{
	ent_player endon(#disconnect);
	ent_player endon(#death);
	ent_player endon(#player_downed);
	if(!isdefined(time))
	{
		time = 30;
	}
	if(is_team_enabled_bgb_real("zm_bgb_temporal_gift", ent_player))
	{
		time = 45;
	}
	if(ent_player.zombie_vars["zombie_powerup_minigun_on"] && (level.zombie_powerup_weapon["minigun"] == ent_player getcurrentweapon() || (isdefined(ent_player.has_powerup_weapon["minigun"]) && ent_player.has_powerup_weapon["minigun"])))
	{
		if(ent_player.zombie_vars["zombie_powerup_minigun_time"] < time)
		{
			ent_player.zombie_vars["zombie_powerup_minigun_time"] = time;
		}
		return;
	}
	level._zombie_minigun_powerup_last_stand_func = function() =>
	{
		zm_powerups::weapon_watch_gunner_downed("minigun");
	};
	stance_disabled = 0;
	if(ent_player getstance() === "prone")
	{
		ent_player allowcrouch(0);
		ent_player allowprone(0);
		stance_disabled = 1;
		while(ent_player getstance() != "stand")
		{
			wait(0.05);
		}
	}
	zm_powerups::weapon_powerup(ent_player, time, "minigun", 1);
	if(stance_disabled)
	{
		ent_player allowcrouch(1);
		ent_player allowprone(1);
	}
}

detour zm_powerup_zombie_blood<scripts\zm\_zm_powerup_zombie_blood.gsc>::zombie_blood_powerup(var_bae0d10b, e_player)
{
	e_player notify(#zombie_blood);
	e_player endon(#zombie_blood);
	e_player endon(#disconnect);
	e_player._show_solo_hud = 1;
	if(is_team_enabled_bgb_real("zm_bgb_temporal_gift", e_player))
	{
		var_bf0a128b = 45;
	}
	else
	{
		var_bf0a128b = 15;
	}
	if(!e_player.zombie_vars["zombie_powerup_zombie_blood_on"])
	{
		e_player zm_utility::increment_ignoreme();
	}
	e_player.zombie_vars["zombie_powerup_zombie_blood_time"] = var_bf0a128b;
	e_player.zombie_vars["zombie_powerup_zombie_blood_on"] = 1;
	e_player setcharacterbodystyle(1);
	level notify(#player_zombie_blood, e_player);
	visionset_mgr::activate("visionset", "zm_tomb_in_plain_sight", e_player, 0.5, var_bf0a128b, 0.5);
	visionset_mgr::activate("overlay", "zm_tomb_in_plain_sight", e_player);
	e_player clientfield::set("player_zombie_blood_fx", 1);
	level.a_zombie_blood_entities = array::remove_undefined(level.a_zombie_blood_entities);
	foreach(e_zombie_blood in level.a_zombie_blood_entities)
	{
		if(isdefined(e_zombie_blood.e_unique_player))
		{
			if(e_zombie_blood.e_unique_player == e_player)
			{
				e_zombie_blood setvisibletoplayer(e_player);
			}
			continue;
		}
		e_zombie_blood setvisibletoplayer(e_player);
	}
	if(!isdefined(e_player.m_fx))
	{
		v_origin = e_player gettagorigin("j_eyeball_le");
		v_angles = e_player gettagangles("j_eyeball_le");
		m_fx = spawn("script_model", v_origin);
		m_fx setmodel("tag_origin");
		m_fx.angles = v_angles;
		m_fx linkto(e_player, "j_eyeball_le", (0, 0, 0), (0, 0, 0));
		m_fx thread [[ function(e_player) => 
		{
			self endon(#death);
			e_player waittill(#disconnect);
			self delete();
		}]](e_player);
		playfxontag(level._effect["zombie_blood"], m_fx, "tag_origin");
		e_player.m_fx = m_fx;
		e_player.m_fx playloopsound("zmb_zombieblood_3rd_loop", 1);
	}
	e_player thread [[ function() =>
	{
		self notify(#early_exit_watch);
		self endon(#early_exit_watch);
		self endon(#zombie_blood_over);
		self endon(#disconnect);
		util::waittill_any_ents_two(self, "player_downed", level, "end_game");
		self.zombie_vars["zombie_powerup_zombie_blood_time"] = -0.05;
		self.early_exit = 1;
	}]]();
	while(e_player.zombie_vars["zombie_powerup_zombie_blood_time"] >= 0)
	{
		wait(0.05);
		e_player.zombie_vars["zombie_powerup_zombie_blood_time"] = e_player.zombie_vars["zombie_powerup_zombie_blood_time"] - 0.05;
	}
	e_player setcharacterbodystyle(0);
	e_player notify(#zombie_blood_over);
	if(isdefined(e_player.characterindex))
	{
		e_player playsound((("vox_plr_" + e_player.characterindex) + "_exert_grunt_") + randomintrange(0, 3));
	}
	e_player.m_fx delete();
	visionset_mgr::deactivate("visionset", "zm_tomb_in_plain_sight", e_player);
	visionset_mgr::deactivate("overlay", "zm_tomb_in_plain_sight", e_player);
	e_player.zombie_vars["zombie_powerup_zombie_blood_on"] = 0;
	e_player.zombie_vars["zombie_powerup_zombie_blood_time"] = 30;
	e_player._show_solo_hud = 0;
	e_player clientfield::set("player_zombie_blood_fx", 0);
	e_player zm_utility::decrement_ignoreme();
	level.a_zombie_blood_entities = array::remove_undefined(level.a_zombie_blood_entities);
	foreach(e_zombie_blood in level.a_zombie_blood_entities)
	{
		e_zombie_blood setinvisibletoplayer(e_player);
	}
}