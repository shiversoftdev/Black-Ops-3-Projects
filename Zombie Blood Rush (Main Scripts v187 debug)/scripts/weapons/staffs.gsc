monitor_staffs_tomb()
{
	if(!isdefined(level.var_32bc7eba)) return;
    self thread monitor_fire_tomb();
    self thread monitor_lightning_tomb();
    self thread watch_staff_water_impact();
    self thread watch_staff_air_impact();
}

tomb_staff_init()
{
	/*
	if(!isdefined(level.a_elemental_staffs))
	{
		return;
	}
	thread tomb_staffs_fix_persistence();
	array::thread_all(level.a_elemental_staffs, serious::kill_s_staff_weapon_tracker);
	*/
}

tomb_staffs_fix_persistence()
{
	/*
	if(!isdefined(level.zombie_craftable_persistent_weapon))
	{
		return;
	}
	level._zombie_craftable_persistent_weapon = level.zombie_craftable_persistent_weapon;
	level.zombie_craftable_persistent_weapon = serious::tomb_staff_notrack;
	*/
}

kill_s_staff_weapon_tracker()
{
}

tomb_staff_notrack(player)
{
}

tomb_revive_staff_monitor()
{
	self notify(#"hash_38af9e8e");
	self endon(#"hash_38af9e8e");
	self endon(#"hash_75edd128");
	self endon("disconnect");
	self endon("bled_out");
	for(;;)
	{
		ammo = self getammocount(level.var_2b2f83e5);
		self clientfield::set_player_uimodel("hudItems.dpadLeftAmmo", ammo);
		wait(0.05);
	}
}

no_track_staff_weapon_respawn()
{
}

monitor_fire_tomb()
{
    self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
    level endon("game_ended");
    for(;;)
    {
        self waittill("grenade_fire", e_projectile, w_weapon);
		if(w_weapon.name == "staff_fire_upgraded2" || w_weapon.name == "staff_fire_upgraded3")
		{
			e_projectile thread fire_staff_area_of_effect(self, w_weapon);
		}
    }
}

fire_staff_area_of_effect(e_attacker, w_weapon)
{
    e_attacker endon("disconnect");
    e_attacker endon("spawned_player");
    e_attacker endon("bled_out");
    level endon("game_ended");

	self waittill("explode", v_pos);
	n_alive_time = 5;
	aoe_radius = 80;
	if(w_weapon.name == "staff_fire_upgraded3")
	{
		aoe_radius = 100;
	}
	n_step_size = 0.2;
	while(n_alive_time > 0)
	{
		if(n_alive_time - n_step_size <= 0)
		{
			aoe_radius = aoe_radius * 2;
		}
		a_targets = getplayers();
        arrayremovevalue(a_targets, e_attacker, false);
		a_targets = util::get_array_of_closest(v_pos, a_targets, undefined, undefined, aoe_radius);
		wait(n_step_size);
		n_alive_time = n_alive_time - n_step_size;
		foreach(e_target in a_targets)
		{
			if(!isdefined(e_target) || e_target.sessionstate != "playing") continue;
            if(isdefined(e_target.is_on_fire) && e_target.is_on_fire) continue;
            e_target thread flame_damage_fx(w_weapon, e_attacker);
		}
	}
}

flame_damage_fx(damageweapon, e_attacker, pct_damage = 1)
{
    self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");

    if(isdefined(self.is_on_fire) && self.is_on_fire) return;

    self.is_on_fire = 1;
    wait(0.5);
    self thread flame_damage_over_time(e_attacker, damageweapon, pct_damage);
    wait 8;
    self.is_on_fire = 0;
}

flame_damage_over_time(e_attacker, damageweapon, pct_damage)
{
	self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
	
	if(isplayer(e_attacker))
	{
		e_attacker endon("disconnect");
		e_attacker endon("spawned_player");
		e_attacker endon("bled_out");
	}
    
	n_damage = get_damage_per_second(damageweapon) * CLAMPED_ROUND_NUMBER;
	n_duration = STAFF_FIRE_DMG_DURATION;
	n_damage = n_damage * pct_damage;
	self thread playFXTimedOnTag(level._effect["character_fire_death_torso"], "J_SpineLower", STAFF_FIRE_DMG_DURATION);
	while(n_duration > 0)
	{
		self dodamage(int(n_damage), self.origin, e_attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
		self thread set_player_burn(1);
		wait(1);
        n_duration -= 1;
	}
}

get_damage_per_second(damageweapon)
{
	str_name = damageweapon.name;
	switch(str_name)
	{
		case "staff_fire":
		{
			return 75;
		}
		case "staff_fire_upgraded":
		{
			return 150;
		}
		case "staff_fire_upgraded2":
		{
			return 300;
		}
		case "staff_fire_upgraded3":
		{
			return 450;
		}
		case "one_inch_punch_fire":
		{
			return 250;
		}
		default:
		{
			return 0;
		}
	}
}

monitor_lightning_tomb()
{
	self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
	for(;;)
	{
		self waittill("missile_fire", e_projectile, str_weapon);
		if(str_weapon.name == "staff_lightning_upgraded" || str_weapon.name == "staff_lightning")
		{
			self.g_lstaff_nerf_ct = int(min(self.g_lstaff_nerf_ct + 1, STAFF_LIGHTNING_NERF_NUMSHOTS));
			self.g_lstaff_nerf_pct = STAFF_LIGHTNING_NERF_PCT_STEP * self.g_lstaff_nerf_ct;
			self thread lightning_tomb_reset_nerf();
		}
		if(str_weapon.name == "staff_lightning_upgraded2" || str_weapon.name == "staff_lightning_upgraded3")
		{
			wait .025;
            ent_lightning_ball = undefined;
            foreach(ent in getentarray("script_model", "className"))
            {
                if(!isdefined(ent.str_weapon.name) || ent.str_weapon.name != str_weapon.name) continue;
                if(isdefined(ent.collected)) continue; // prevent from collecting balls twice
                ent.collected = true;
                ent_lightning_ball = ent;
                break;
            }
            if(!isdefined(ent_lightning_ball)) continue;
            ent_lightning_ball thread lightning_ball_pvp(self);
		}
	}
}

lightning_tomb_reset_nerf()
{
	self endon("disconnect");
	self endon("bled_out");
	self notify("lightning_tomb_reset_nerf");
	self endon("lightning_tomb_reset_nerf");
	wait STAFF_LIGHTNING_NERF_REGEN_DELAY;
	self.g_lstaff_nerf_ct = 0;
	self.g_lstaff_nerf_pct = 0;
}

get_effective_ls_mp()
{
	if(!isdefined(self.g_lstaff_nerf_pct))
		return 1.0;
	return 1.0 - max(min(1.0, self.g_lstaff_nerf_pct), 0);
}

lightning_ball_pvp(e_attacker)
{
	self endon("death");
	self endon("stop_killing");
    e_attacker endon("disconnect");
	for(;;)
	{
		a_players = self staff_lightning_get_valid_targets(e_attacker, self.origin);
		if(isdefined(a_players))
		{
			foreach(player in a_players)
			{
				if(staff_lightning_is_target_valid(player))
				{
					e_attacker thread staff_lightning_arc_fx(self, player);
					wait(0.2);
				}
			}
		}
		wait(0.5);
	}
}

staff_lightning_get_valid_targets(player, v_source)
{
	player endon("disconnect");
    a_enemies_final = [];
	a_enemies = getplayers();
    arrayremovevalue(a_enemies, player, false);
	a_enemies = util::get_array_of_closest(v_source, a_enemies, undefined, undefined, self.n_range);
	if(isdefined(a_enemies))
	{
		foreach(enemy in a_enemies)
		{
			if(staff_lightning_is_target_valid(enemy))
			{
				a_enemies_final[a_enemies_final.size] = enemy;
			}
		}
	}
	return a_enemies_final;
}

staff_lightning_is_target_valid(player)
{
	if(!isdefined(player)) return false;
	if(isdefined(player.is_being_zapped) && player.is_being_zapped) return false;
	if(player.sessionstate != "playing") return false;
	return true;
}

staff_lightning_arc_fx(e_source, player)
{
	self endon("disconnect");
	if(!isdefined(player)) return;
    if(!bullettracepassed(e_source.origin + (0,0,5), player.origin + (0,0,50), 0, player))
    {
        return;
    }
	if(isdefined(e_source) && isdefined(player) && player.sessionstate == "playing")
	{
		level thread staff_lightning_ball_damage_over_time(e_source, player, self);
	}
}

staff_lightning_ball_damage_over_time(e_source, e_target, e_attacker)
{
    e_target endon("disconnect");
	e_attacker endon("disconnect");
    e_source endon("death");
	e_attacker thread lightning_ball_fire_shot_fx(e_source, e_target);
	n_range_sq = e_source.n_range * e_source.n_range;
	e_target.is_being_zapped = 1;
	wait(0.5);
    if(!isdefined(e_source)) return;
	n_damage_per_pulse = e_source.n_damage_per_sec;
	while(isdefined(e_source) && e_target.sessionstate == "playing")
	{
		e_target thread staff_lightning_stun_player();
		wait(1);
		if(!(isdefined(e_source) && e_target.sessionstate == "playing")) break;
		n_dist_sq = distancesquared(e_source.origin, e_target.origin);
		if(n_dist_sq > n_range_sq) break;
        e_target dodamage(int(n_damage_per_pulse * STAFF_LIGHTNING_DMG_SCALAR), e_target.origin, e_attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
	}
	if(isdefined(e_target))
	{
		e_target.is_being_zapped = 0;
	}
}

lightning_ball_fire_shot_fx(e_source, player_target)
{
    level endon("game_ended");
    if(!isdefined(e_source) || !isdefined(player_target)) return;
    model = spawn("script_model", e_source.origin);
    model setmodel("script_origin");
    model.fx = playFXOnTag(level._effect["tesla_bolt"], model, "tag_origin");
    model moveTo(player_target getTagOrigin("J_SpineUpper"), 0.1);
    wait 0.15;
	if(isdefined(model.fx))
	{
		model.fx delete();
	}
    model delete();
}

staff_lightning_stun_player()
{
    self endon("bled_out");
    self endon("disconnect");
	self notify("stun_zombie");
	self endon("stun_zombie");

    self thread playFXTimedOnTag(level._effect["tesla_shock"], "J_SpineUpper", 1);
	if(self.sessionstate != "playing" || self.health <= 0) return;
    self set_move_speed_scale(0.5, true);
    if(!self util::is_bot()) self SetElectrified(1);
    wait 1;
    self set_move_speed_scale(1);
}

watch_staff_water_impact()
{
	self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
    level endon("game_ended");
	for(;;)
	{
		self waittill("projectile_impact", str_weapon, v_explode_point, n_radius, str_name, n_impact);
		if(str_weapon.name == "staff_water_upgraded2" || str_weapon.name == "staff_water_upgraded3")
		{
			n_lifetime = 6;
			if(str_weapon.name == "staff_water_upgraded3")
			{
				n_lifetime = 9;
			}
			self thread staff_water_position_source(v_explode_point, n_lifetime, str_weapon);
		}
		if(str_weapon.name == "staff_water")
		{
			self radiusdamage(v_explode_point + (0, 0, 10), 150, 2, 1, self, "MOD_EXPLOSIVE", str_weapon);
		}
		if(str_weapon.name == "staff_water_upgraded2" || str_weapon.name == "staff_water_upgraded3" || str_weapon.name == "staff_water_upgraded")
		{
			self radiusdamage(v_explode_point + (0, 0, 10), 150, 2, 1, self, "MOD_EXPLOSIVE", str_weapon);
		}
	}
}

staff_water_position_source(v_detonate, n_lifetime_sec, str_weapon)
{
	self endon("disconnect");
	if(isdefined(v_detonate))
	{
		e_fx = spawn("script_model", v_detonate + vectorscale((0, 0, 1), 33));
		e_fx setmodel("tag_origin");
        e_fx endon("death");
		wait(1);
		e_fx thread ice_staff_blizzard_do_kills(self, str_weapon);
		e_fx thread ice_staff_blizzard_timeout(n_lifetime_sec);
		e_fx util::waittill_any("death", "blizzard_off");
		if(isdefined(e_fx))
		{
			e_fx delete();
		}
	}
}

ice_staff_blizzard_do_kills(player, str_weapon)
{
	player endon("disconnect");
	self endon("blizzard_off");
    self endon("death");
	for(;;)
	{
		a_players = getplayers();
		foreach(enemy in a_players)
		{
            if(enemy == player) continue;
			if(enemy.team == player.team) continue;
            if(enemy.sessionstate != "playing") continue;
            if(distancesquared(self.origin, enemy.origin) > 30625) continue;
            enemy thread ice_affect_zombie(str_weapon, player);
		}
		wait(0.1);
	}
}

ice_staff_blizzard_timeout(n_time)
{
	self endon("death");
	self endon("blizzard_off");
	wait(n_time);
	self notify("blizzard_off");
}

ice_affect_zombie(str_weapon = getweapon("staff_water"), e_player, n_mod_override = 1)
{
	self endon("death");
    self endon("bled_out");
    self endon("disconnect");
    self notify("ice_affect_zombie");
    self endon("ice_affect_zombie");
    e_player endon("disconnect");
    level endon("game_ended");

	n_damage = STAFF_WATER_DPS * CLAMPED_ROUND_NUMBER * 0.1 * n_mod_override;
	if(str_weapon.name == "staff_water_upgraded" || str_weapon.name == "staff_water_upgraded2" || str_weapon.name == "staff_water_upgraded3")
	{
		n_damage *= 1.35;
	}
	else if(str_weapon.name == "one_inch_punch_ice")
	{
		n_damage *= 3;
	}
	n_speed = 0.07;
	self set_move_speed_scale(n_speed, true);
	for(i = 0; i < 20; i++)
	{
		self dodamage(int(n_damage), self.origin, e_player, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
		wait(0.1);
	}
	self.ice_damage_mp = 1;
    self set_move_speed_scale(1);
}

watch_staff_air_impact()
{
	self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
    level endon("game_ended");
	for(;;)
	{
		self waittill("projectile_impact", w_weapon, v_explode_point, n_radius, projectile);
		if(w_weapon.name == "staff_air_upgraded2" || w_weapon.name == "staff_air_upgraded3")
		{
			self thread staff_air_find_source(v_explode_point, w_weapon);
		}
		if(w_weapon.name == "staff_air")
		{
			self radiusdamage(v_explode_point + (0, 0, 10), 150, 2, 1, self, "MOD_EXPLOSIVE", w_weapon);
		}
		if(w_weapon.name == "staff_air_upgraded2" || w_weapon.name == "staff_air_upgraded3" || w_weapon.name == "staff_air_upgraded")
		{
			self radiusdamage(v_explode_point + (0, 0, 10), 150, 2, 1, self, "MOD_EXPLOSIVE", w_weapon);
		}
	}
}

staff_air_find_source(v_detonate, w_weapon)
{
	self endon("disconnect");
	if(!isdefined(v_detonate)) return;
	a_players = getplayers();
	a_players = util::get_array_of_closest(v_detonate, a_players);
	if(a_players.size)
	{
		for(i = 0; i < a_players.size; i++)
		{
			if(a_players[i].sessionstate != "playing") continue;
            if(a_players[i] == self) continue;
			if(isdefined(a_players[i].staff_succ) && a_players[i].staff_succ) continue;
            dist_good = distance2dsquared(v_detonate, a_players[i].origin) <= 10000;
            self thread staff_air_position_source(dist_good ? a_players[0].origin : v_detonate, w_weapon);
            return;
		}
	}
	else
	{
		self thread staff_air_position_source(v_detonate, w_weapon);
	}
}

staff_air_position_source(v_detonate, w_weapon)
{
	self endon("disconnect");
	if(!isdefined(v_detonate)) return;
	n_time = self.chargeshotlevel * 1.25;
	e_whirlwind = spawn("script_model", v_detonate + vectorscale((0, 0, 1), 100));
	e_whirlwind setmodel("tag_origin");
	e_whirlwind.angles = vectorscale((-1, 0, 0), 90);
	e_whirlwind moveto(zm_utility::groundpos_ignore_water_new(e_whirlwind.origin), 0.05);
	e_whirlwind waittill("movedone");
	e_whirlwind clientfield::set("whirlwind_play_fx", 1);
	e_whirlwind thread whirlwind_rumble_nearby_players("whirlwind_active");
	e_whirlwind thread whirlwind_timeout(n_time, self);
	wait(0.5);
	e_whirlwind.player_owner = self;
	self thread vortex_suck_players(e_whirlwind, n_time, 10);
	e_whirlwind thread whirlwind_seek_players(self.chargeshotlevel, w_weapon);
}

whirlwind_rumble_nearby_players(str_active_flag)
{
	range_sq = 90000;
	while(isdefined(self) && level flag::get(str_active_flag))
	{
		a_players = getplayers();
		foreach(player in a_players)
		{
			dist_sq = distancesquared(self.origin, player.origin);
			if(dist_sq < range_sq)
			{
				player thread whirlwind_rumble_player(self, str_active_flag);
			}
		}
		util::wait_network_frame();
	}
}

whirlwind_rumble_player(e_whirlwind, str_active_flag)
{
	if(isdefined(self.whirlwind_rumble_on) && self.whirlwind_rumble_on)
	{
		return;
	}
	self.whirlwind_rumble_on = 1;
	n_rumble_level = 1;
	self clientfield::set_to_player("player_rumble_and_shake", 4);
	dist_sq = distancesquared(self.origin, e_whirlwind.origin);
	range_inner_sq = 10000;
	range_sq = 90000;
	while(dist_sq < range_sq)
	{
		wait(0.05);
		if(!isdefined(e_whirlwind))
		{
			break;
		}
		if(isdefined(str_active_flag))
		{
			if(!level flag::get(str_active_flag))
			{
				break;
			}
		}
		dist_sq = distancesquared(self.origin, e_whirlwind.origin);
		if(n_rumble_level == 1 && dist_sq < range_inner_sq)
		{
			n_rumble_level = 2;
			self clientfield::set_to_player("player_rumble_and_shake", 5);
		}
		else if(n_rumble_level == 2 && dist_sq >= range_inner_sq)
		{
			n_rumble_level = 1;
			self clientfield::set_to_player("player_rumble_and_shake", 4);
		}
	}
	self clientfield::set_to_player("player_rumble_and_shake", 0);
	self.whirlwind_rumble_on = 0;
}

whirlwind_timeout(n_time, owner)
{
	self endon("death");
	self util::waittill_any_timeout(n_time, "whirlwind_stopped");
	self notify("whirlwind_stopped");
	self clientfield::set("whirlwind_play_fx", 0);
	self notify("stop_debug_position");
	wait(1.5);
	self delete();
}

whirlwind_seek_players(n_level, w_weapon)
{
	self endon("death");
    self endon("whirlwind_stopped");
    self.player_owner endon("disconnect");
	self.b_found_zombies = 0;
	n_range = (n_level == 1) ? 500 : 750;
	for(;;)
	{
		a_players = self staff_air_players_in_range(self.origin, n_range);
		if(a_players.size)
		{
			self MoveTo(a_players[0].origin, 200 / distance(a_players[0].origin, self.origin), 0.1, 0.1);
			self waittill("movedone");
		}
		wait(0.1);
	}
}

staff_air_players_in_range(v_source, n_range)
{
	a_enemies = [];
	a_players = getplayers();
    arrayremovevalue(a_players, self.player_owner, false);
	a_players = util::get_array_of_closest(v_source, a_players);
	n_range_sq = n_range * n_range;
	if(isdefined(a_players))
	{
		for(i = 0; i < a_players.size; i++)
		{
			if(!isdefined(a_players[i])) continue;
            if(a_players[i].sessionstate != "playing") continue;
			if(isdefined(a_players[i].staff_succ) && a_players[i].staff_succ == 1) continue;
			dsq = distancesquared(v_source, a_players[i].origin);
			if(dsq > n_range_sq || dsq <= (175 * 175)) continue;
			if(!BulletTracePassed(v_source + (0, 0, 5), a_players[i] GetCentroid(), false, a_players[i])) continue;
			a_enemies[a_enemies.size] = a_players[i];
		}
	}
	return a_enemies;
}

whirlwind_kill_players(n_level, w_weapon, a_players)
{
	self endon("death");
    self.player_owner endon("disconnect");
	n_range = n_level == 1 ? 100 : 250;
	self.n_charge_level = n_level;
	for(;;)
	{
		for(i = 0; i < a_players.size; i++)
		{
			if(!isdefined(a_players[i])) continue;
			if(a_players[i].sessionstate != "playing") continue;
			v_offset = (10, 10, 32);
			if(!bullettracepassed(self.origin + v_offset, a_players[i].origin + (0,0,50), 0, a_players[i])) continue;
			a_players[i] thread whirlwind_drag_player(self, w_weapon);
			wait(0.5);
		}
		util::wait_network_frame();
	}
}

whirlwind_drag_player(e_whirlwind, w_weapon)
{
    self endon("disconnect");
    e_whirlwind.player_owner endon("disconnect");
    self endon("bled_out");
    level endon("game_ended");

    self.staff_succ = true;
    const_scalar = (1 + (CLAMPED_ROUND_NUMBER * STAFF_AIR_DMG_BONUS_PER_ROUND));
    dmg_last = 0;
	while(isdefined(e_whirlwind))
    {
        target = e_whirlwind.origin + (0,0,50);
        d = distance2d(self getorigin(), target);
        iv = target - self getorigin();
        da = 1 - min(1, d / STAFF_AIR_SUCC_RADIUS);
        org = self getorigin();
        if(self isonground()) org = org + (0,0,5);
        self setorigin(org);
        self setvelocity(self getVelocity() + (vectornormalize(iv) * da * STAFF_AIR_PULL_VELOCITY_PER_FRAME));
        dmg_last++;
        if(!(dmg_last % 10))
        {
            self DoDamage(int(STAFF_AIR_DMG_PER_TICK * da * const_scalar), self.origin, e_whirlwind.player_owner, undefined, "none", "MOD_UNKNOWN", 0, level.weaponNone);
        }
        wait 0.05;
    }
    self.staff_succ = false;
}

staff_air_knockback(weapon, attacker)
{
    velocity = WIND_STAFF_LAUNCH_VELOCITY;
    angles = VectorNormalize(anglesToForward(attacker getPlayerAngles()));
    final_velocity = angles * velocity;
    final_velocity_clamped = (final_velocity[0], final_velocity[1], min(max(final_velocity[2], 300), -300));

    self setOrigin(self getOrigin() + (0,0,10));
    self setVelocity(final_velocity_clamped);
	self.launch_magnitude_extra = 200;
    self.v_launch_direction_extra = vectorNormalize(final_velocity_clamped);
    self thread TG_ImpactDamage(attacker);
}

get_staff_info_from_element_index(n_index)
{
	foreach(s_staff in level.a_elemental_staffs)
	{
		if(s_staff.enum == n_index)
		{
			return s_staff;
		}
	}
	return undefined;
}

get_staff_info_from_weapon_name(w_weapon, b_base_info_only = 1)
{
	str_name = w_weapon.name;
	foreach(var_b4ab863f, s_staff in level.a_elemental_staffs)
	{
		if(s_staff.weapname == str_name || s_staff.upgrade.weapname == str_name)
		{
			if(s_staff.charger.is_charged && !b_base_info_only)
			{
				return s_staff.upgrade;
			}
			return s_staff;
		}
	}
	return undefined;
}