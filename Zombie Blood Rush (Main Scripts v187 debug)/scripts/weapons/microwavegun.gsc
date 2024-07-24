wait_for_microwavegun_fired()
{
	if(!isdefined(level.w_microwavegun))
	{
		if(level.script != "zm_leviathan")
		{
			return;
		}
		level.w_microwavegun = getweapon("microwavegun");
		level.w_microwavegun_upgraded = getweapon("microwavegun_upgraded");
		level.w_microwavegundw = getweapon("microwavegundw");
		level.w_microwavegundw_upgraded = getweapon("microwavegundw_upgraded");
	}
    self endon("spawned_player");
    self endon("bled_out");
    self endon("disconnect");
    level endon("game_ended");
    for(;;)
	{
		self waittill("weapon_fired", weapon);
		if(weapon_is_wg(weapon))
        {
            self thread microwavegun_fired(weapon == level.var_6ae86bb, weapon);
        }
	}
}

weapon_is_wg(weapon)
{
	if(!isdefined(level.w_microwavegun))
	{
		return false;
	}
    return (weapon == level.var_12fcda98) || (weapon == level.var_6ae86bb);
}

microwavegun_fired(upgraded, weapon)
{
	data = self microwavegun_get_players_in_range(upgraded);
	foreach(player in data.sizzled_players)
	{
		player dodamage(int(MOON_WAVEGUN_ALTFIRE_DMG * CLAMPED_ROUND_NUMBER), player.origin, self, self, "none", "MOD_UNKNOWN", 0, level.weaponNone);
	}
}

microwavegun_get_players_in_range(upgraded)
{
    data = spawnstruct();
    data.sizzled_players = [];
    data.sizzled_vecs = [];
	view_pos = self getweaponmuzzlepoint();
	test_list = [];
	range = level.zombie_vars["microwavegun_sizzle_range"];
	cylinder_radius = level.zombie_vars["microwavegun_cylinder_radius"];
	test_list = getplayers();
	players = util::get_array_of_closest(view_pos, test_list, undefined, undefined, range);
	if(!isdefined(players)) return data;
    arrayremovevalue(players, self, false);
	sizzle_range_squared = range * range;
	cylinder_radius_squared = cylinder_radius * cylinder_radius;
	forward_view_angles = self getweaponforwarddir();
	end_pos = view_pos + vectorscale(forward_view_angles, range);
	foreach(player in players)
	{
		if(player.sessionstate != "playing") continue;
		test_origin = player.origin + (0,0,50);
		test_range_squared = distancesquared(view_pos, test_origin);
		if(test_range_squared > sizzle_range_squared) return data;
		normal = vectornormalize(test_origin - view_pos);
		dot = vectordot(forward_view_angles, normal);
		if(0 > dot) continue;
		radial_origin = pointonsegmentnearesttopoint(view_pos, end_pos, test_origin);
		if(distancesquared(test_origin, radial_origin) > cylinder_radius_squared) continue;
		if(!(player damageconetrace(view_pos, self))) continue;
		data.sizzled_players[data.sizzled_players.size] = player;
        dist_mult = sizzle_range_squared - test_range_squared / sizzle_range_squared;
        sizzle_vec = vectornormalize(test_origin - view_pos);
        if(5000 < test_range_squared)
        {
            sizzle_vec = sizzle_vec + vectornormalize(test_origin - radial_origin);
        }
        sizzle_vec = (sizzle_vec[0], sizzle_vec[1], abs(sizzle_vec[2]));
        sizzle_vec = vectorscale(sizzle_vec, 100 + 100 * dist_mult);
        data.sizzled_vecs[data.sizzled_vecs.size] = sizzle_vec;
	}
    return data;
}