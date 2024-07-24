is_idgun_damage(weapon)
{
	if(!isdefined(weapon))
	{
		return 0;
	}
	if(isdefined(level.idgun_weapons))
	{
		if(array::contains(level.idgun_weapons, weapon))
		{
			return 1;
		}
	}
	return 0;
}

is_upgraded_idgun(weapon)
{
	if(!isdefined(weapon))
	{
		return false;
	}
	if(is_idgun_damage(weapon) && zm_weapons::is_weapon_upgraded(weapon))
	{
		return true;
	}
	return false;
}

monitor_idgun()
{
    self notify("monitor_idgun");
    self endon("monitor_idgun");
    self endon("bled_out");
    level endon("end_game");
	self endon("disconnect");
    
    if(!isdefined(GetWeapon("idgun").name))
        return;

    if(IS_DEBUG && DEBUG_IDGUN && self ishost())
    {
        wait SPAWN_DELAY;
        self takeAllWeapons();
        self giveWeapon(level.idgun_weapons[0]);
        self switchToWeapon(level.idgun_weapons[0]);
        self giveMaxAmmo(level.idgun_weapons[0]);
    }

	for(;;)
	{
		self waittill("projectile_impact", weapon, position, radius, attacker, normal);
		position = acquire_navigable_point(position + normal * 20);
		if(is_idgun_damage(weapon))
		{
			var_12edbbc6 = radius * 1.8;
			if(is_upgraded_idgun(weapon))
			{
				self thread start_timed_pvp_vortex(position, radius, 9, 9, var_12edbbc6, self, weapon, 1, undefined, 0, 2);
			}
			else
			{
				self thread start_timed_pvp_vortex(position, radius, 5, 5, var_12edbbc6, self, weapon, 1, undefined, 0, 1);
			}
		}
		wait(0.05);
	}
}

acquire_navigable_point(v_vortex_origin)
{
	v_nearest_navmesh_point = GetClosestPointOnNavMesh(v_vortex_origin, 36, 15);
	if(isdefined(v_nearest_navmesh_point))
	{
		f_distance = Distance(v_vortex_origin, v_nearest_navmesh_point);
		if(f_distance < 41)
		{
			v_vortex_origin = v_vortex_origin + VectorScale((0, 0, 1), 36);
		}
	}
	return v_vortex_origin;
}

start_timed_pvp_vortex(v_vortex_origin, n_vortex_radius = 400, vortex_pull_duration, vortex_effect_duration, n_vortex_explosion_radius, eAttacker, weapon, should_shellshock_player, visionset_func, should_shield, effect_version, should_explode, vortex_projectile)
{
	if(!isdefined(should_shellshock_player))
	{
		should_shellshock_player = 0;
	}
	if(!isdefined(visionset_func))
	{
		visionset_func = undefined;
	}
	if(!isdefined(should_shield))
	{
		should_shield = 0;
	}
	if(!isdefined(effect_version))
	{
		effect_version = 0;
	}
	if(!isdefined(should_explode))
	{
		should_explode = 1;
	}
	if(!isdefined(vortex_projectile))
	{
		vortex_projectile = undefined;
	}

	self endon("bled_out");
    self endon("spawned_player");
	self endon("disconnect");

	n_starttime = GetTime();
	n_currtime = GetTime() - n_starttime;
	a_e_players = GetPlayers();

	if(!isdefined(n_vortex_explosion_radius))
	{
		n_vortex_explosion_radius = n_vortex_radius * 1.5;
	}

	n_vortex_time_sv = vortex_pull_duration;
	n_vortex_time_cl = vortex_pull_duration;
	n_vortex_time = n_vortex_time_sv * 1000;
	dmg = IDGUN_PVP_EXPLODE_DMG_PER_ROUND * CLAMPED_ROUND_NUMBER;
	is_idgun = (!isdefined(level.w_black_hole_bomb) || weapon != level.w_black_hole_bomb) && is_idgun_damage(weapon);
    idgun_mp = (is_idgun && is_upgraded_idgun(weapon)) ? IDGUN_SCALAR_UPGRADED : 1;
	idgun_mp_2 = idgun_mp;
	if(is_idgun)
	{
		idgun_mp_2 *= 1 + (IDGUN_DMG_BOOST_PER_ROUND * CLAMPED_ROUND_NUMBER);
	}

	// if(!isdefined(self.pvp_vortex_count))
	// {
	// 	self.pvp_vortex_count = 0;
	// }

	if(!isdefined(self.pvp_vortex_id))
	{
		self.pvp_vortex_id = -1;
		self.pvp_vortexes = [];
		self.pvp_vortexes[0] = -1;
		self.pvp_vortexes[1] = -1;
	}

	self.pvp_vortex_id++;

	my_id = self.pvp_vortex_id;
	oldest_index = 0;
	for(i = 1; i < self.pvp_vortexes.size; i++)
	{
		if(self.pvp_vortexes[i] < self.pvp_vortexes[oldest_index])
		{
			oldest_index = i;
		}
	}

	self.pvp_vortexes[oldest_index] = my_id;

	// if(self.pvp_vortex_count >= MAX_IDGUN_VORTEX_COUNT)
	// {
	// 	if(!should_explode) return;

	// 	foreach(player in getplayers())
	// 	{
	// 		if(!isdefined(player) || !isdefined(player.origin)) continue;
	// 		if(player == self) continue;
	// 		if(player.sessionstate != "playing") continue;
	// 		if(player laststand::player_is_in_laststand()) continue;
	// 		if(distance(player.origin, v_vortex_origin) > n_vortex_explosion_radius) continue;
	// 		player.launch_magnitude_extra = 100;
	// 		player.v_launch_direction_extra = (0,0,0.75);
	// 		player DoDamage(int(dmg * idgun_mp * 0.25), player.origin, self, self, "none", "MOD_UNKNOWN", 0, level.weaponNone);
	// 	}
	// 	return;
	// }

	//self.pvp_vortex_count++;

	arrayremovevalue(a_e_players, self, false);
	is_idgun = isdefined(weapon) && issubstr(weapon.name, "idgun");
	pv = is_idgun ? (IDGUN_PULL_VELOCITY_PER_FRAME * 2.25) : IDGUN_PULL_VELOCITY_PER_FRAME;
	while(n_currtime <= n_vortex_time && (self.pvp_vortexes[oldest_index] == my_id))
	{
		foreach(player in a_e_players)
		{
			if(!isdefined(player) || (player.sessionstate != "playing") || (player == self && (!IS_DEBUG || !DEBUG_SELF_PULL)))
                continue;

			if(player laststand::player_is_in_laststand())
			{
				continue;
			}

			if(distance(player.origin, v_vortex_origin) > n_vortex_radius) continue;
            
            d = distance2d(player getorigin(), v_vortex_origin);
            iv = v_vortex_origin - player getorigin();
            da = 1 - min(1, d / n_vortex_radius);
            db = da;
            if(isdefined(level.start_vortex_damage_radius))
            {
                db = 1 - min(1, d / level.start_vortex_damage_radius);
            }
            org = player getorigin();
            if(player isonground())
                org = org + (0,0,10);
            
            player setorigin(org);
			if(isdefined(weapon) && issubstr(weapon.name, "idgun"))
            player setvelocity(player getVelocity() + (vectornormalize(iv) * da * pv));
            player DoDamage(int(IDGUN_DMG_PER_FRAME * db * idgun_mp_2), player.origin, self, self, "none", "MOD_UNKNOWN", 0, level.weaponNone);
		}

		wait 0.05;
		n_currtime = GetTime() - n_starttime;
	}

    wait 0.1;
    if(!should_explode || (self.pvp_vortexes[oldest_index] != my_id)) return;

    foreach(player in getplayers())
    {
		if(!isdefined(player)) continue;
        if(player == self) continue;
        if(player.sessionstate != "playing") continue;
		if(player laststand::player_is_in_laststand()) continue;
		if(distance(player.origin, v_vortex_origin) > n_vortex_explosion_radius) continue;
        player.launch_magnitude_extra = 100;
        player.v_launch_direction_extra = (0,0,0.75);
        player DoDamage(int(dmg * idgun_mp), player.origin, self, self, "none", "MOD_UNKNOWN", 0, level.weaponNone);
    }	

	//self.pvp_vortex_count--;
}