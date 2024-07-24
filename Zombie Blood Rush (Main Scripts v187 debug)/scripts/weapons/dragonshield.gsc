dragon_shield_melee(weapon)
{
    ammo = self getammocount(weapon);
	disabled = isdefined(self.var_a0a9409e) && self.var_a0a9409e;
    if(ammo > 0 && !disabled)
    {
        self thread player_burninate(weapon);
    }
    self [[ level._riotshield_melee_power ]](weapon);
}

player_burninate(w_weapon)
{
	if(w_weapon == getweapon(level.zbr_dragonshield_name_upgraded))
	{
		n_clientfield = 2;
	}
	else
	{
		n_clientfield = 1;
	}
	self thread fire_projectile_ds(n_clientfield, w_weapon);
}

fire_projectile_ds(n_clientfield, w_weapon)
{
	if(!isdefined(level._var_2f79fc7))
	{
		level._var_2f79fc7 = [];
		level._var_e4a96ed9 = [];
		level._var_1c1b4cce = [];
        level._var_490f6a0d = [];
	}
	self collect_dragon_info();
	self.var_3a6322f2 = 0;
	level.ds_net_throttle = 0;
	i = 0;
	while(i < level._var_e4a96ed9.size)
	{
		level._var_e4a96ed9[i] thread ds_fling_player(self, w_weapon);
		ds_net_throttle();
		i++;
	}
	for(i = 0; i < level._var_2f79fc7.size; i++)
	{
        level._var_2f79fc7[i] thread ds_gib_player(self, w_weapon);
		ds_net_throttle();
	}
	level._var_2f79fc7 = [];
	level._var_e4a96ed9 = [];
	level._var_1c1b4cce = [];
    level._var_490f6a0d = [];
}

ds_fling_player(player, w_weapon)
{
	delay = self.var_d8486721;
	if(isdefined(delay) && delay > 0.05) wait(delay);
	if(self.sessionstate != "playing") return;
	self dodamage(ZM_DRAGSHIELD_DMG * CLAMPED_ROUND_NUMBER, player.origin, player, player, "none", "MOD_EXPLOSIVE", 0, w_weapon);
}

ds_gib_player(player, w_weapon)
{
    if(self.sessionstate != "playing") return;
	self dodamage(ZM_DRAGSHIELD_DMG * CLAMPED_ROUND_NUMBER * 0.7, player.origin, player, player, "none", "MOD_EXPLOSIVE", 0, w_weapon);
}

ds_net_throttle()
{
	level.ds_net_throttle++;
	if(!(level.ds_net_throttle % 10))
	{
		util::wait_network_frame();
		util::wait_network_frame();
		util::wait_network_frame();
	}
}

collect_dragon_info()
{
	view_pos = self getweaponmuzzlepoint();
	players = array::get_all_closest(view_pos, getplayers(), undefined, undefined, level.zombie_vars["dragonshield_knockdown_range"]);
	if(!isdefined(players)) return;
    arrayremovevalue(players, self, true);
    players = array::filter(players, 0, serious::gravityspikes_target_filtering);
    if(!players.size) return;
	knockdown_range_squared = level.zombie_vars["dragonshield_knockdown_range"] * level.zombie_vars["dragonshield_knockdown_range"];
	gib_range_squared = level.zombie_vars["dragonshield_gib_range"] * level.zombie_vars["dragonshield_gib_range"];
	fling_range_squared = level.zombie_vars["dragonshield_fling_range"] * level.zombie_vars["dragonshield_fling_range"];
	cylinder_radius_squared = level.zombie_vars["dragonshield_cylinder_radius"] * level.zombie_vars["dragonshield_cylinder_radius"];
	var_26ce68e3 = level.zombie_vars["dragonshield_proximity_knockdown_radius"] * level.zombie_vars["dragonshield_proximity_knockdown_radius"];
	var_36f73bb5 = level.zombie_vars["dragonshield_proximity_fling_radius"] * level.zombie_vars["dragonshield_proximity_fling_radius"];
	forward_view_angles = self getweaponforwarddir();
	end_pos = view_pos + vectorscale(forward_view_angles, level.zombie_vars["dragonshield_knockdown_range"]);
	for(i = 0; i < players.size; i++)
	{
		test_origin = players[i].origin + (0,0,50);
		test_range_squared = distancesquared(view_pos, test_origin);
		if(test_range_squared > knockdown_range_squared) return;
		normal = vectornormalize(test_origin - view_pos);
		dot = vectordot(forward_view_angles, normal);
		if(test_range_squared < var_36f73bb5)
		{
			level._var_e4a96ed9[level._var_e4a96ed9.size] = players[i];
			dist_mult = 1;
			fling_vec = vectornormalize(test_origin - view_pos);
			fling_vec = (fling_vec[0], fling_vec[1], abs(fling_vec[2]));
			fling_vec = vectorscale(fling_vec, 50 + 50 * dist_mult);
			level._var_1c1b4cce[level._var_1c1b4cce.size] = fling_vec;
			continue;
		}
		else if(test_range_squared < var_26ce68e3 && 0 > dot)
		{
			if(!isdefined(players[i].var_e1dbd63))
			{
				players[i].var_e1dbd63 = level.var_337d1ed2;
			}
			level._var_2f79fc7[level._var_2f79fc7.size] = players[i];
			level._var_490f6a0d[level._var_490f6a0d.size] = 0;
			continue;
		}
		if(0 > dot) continue;
		radial_origin = pointonsegmentnearesttopoint(view_pos, end_pos, test_origin);
		if(distancesquared(test_origin, radial_origin) > cylinder_radius_squared) continue;
		if(0 == players[i] damageconetrace(view_pos, self)) continue;
		var_6ce0bf79 = level.zombie_vars["dragonshield_projectile_lifetime"];
		players[i].var_d8486721 = var_6ce0bf79 * sqrt(test_range_squared) / level.zombie_vars["dragonshield_knockdown_range"];
		if(test_range_squared < fling_range_squared)
		{
			level._var_e4a96ed9[level._var_e4a96ed9.size] = players[i];
			dist_mult = fling_range_squared - test_range_squared / fling_range_squared;
			fling_vec = vectornormalize(test_origin - view_pos);
			if(5000 < test_range_squared)
			{
				fling_vec = fling_vec + vectornormalize(test_origin - radial_origin);
			}
			fling_vec = (fling_vec[0], fling_vec[1], abs(fling_vec[2]));
			fling_vec = vectorscale(fling_vec, 50 + 50 * dist_mult);
			level._var_1c1b4cce[level._var_1c1b4cce.size] = fling_vec;
			continue;
		}
		if(test_range_squared < gib_range_squared)
		{
			if(!isdefined(players[i].var_e1dbd63))
			{
				players[i].var_e1dbd63 = level.var_337d1ed2;
			}
			level._var_2f79fc7[level._var_2f79fc7.size] = players[i];
			level._var_490f6a0d[level._var_490f6a0d.size] = 1;
			continue;
		}
		if(!isdefined(players[i].var_e1dbd63))
		{
			players[i].var_e1dbd63 = level.var_337d1ed2;
		}
		level._var_2f79fc7[level._var_2f79fc7.size] = players[i];
		level._var_490f6a0d[level._var_490f6a0d.size] = 0;
	}
}

dragonshield_prompt_and_visibility_func(player)
{
	can_use = self.stub zm_craftables::craftablestub_update_prompt(player);

	if(can_use)
	{
		if(isdefined(player.dragonshield_next_round) && player.dragonshield_next_round > level.round_number)
		{
			can_use = false;
			self.stub.hint_string = &"ZOMBIE_BGB_MACHINE_COMEBACK";
		}
	}

	self sethintstring(self.stub.hint_string);
	return can_use;
}

on_buy_dragonshield(player)
{
	if(isdefined(level.zombie_include_craftables["craft_shield_zm"]._onbuyweapon))
	{
		self [[ level.zombie_include_craftables["craft_shield_zm"]._onbuyweapon ]](player);
	}
	player.dragonshield_next_round = level.round_number + 1;
}