raygun_mk3_monitor()
{
    if(!isdefined(level.w_raygun_mark3lh)) return;
    self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
    for(;;)
	{
		self waittill("projectile_impact", w_weapon, v_pos, n_radius, e_projectile, v_normal);
		if(is_slow_raygun(w_weapon))
		{
			self thread acquire_vortex_and_watch_damage(w_weapon);
		}
	}
}

is_slow_raygun(weapon)
{
    if(!isdefined(weapon)) return false;
	return weapon == level.w_raygun_mark3lh || weapon == level.w_raygun_mark3lh_upgraded;
}

mark3_slow(b_upgraded = 0)
{
    self endon("bled_out");
    self endon("disconnect");
    level endon("game_ended");
    self set_move_speed_scale(0.5 / (1 + b_upgraded), true);
    self thread set_player_burn(2.5);
    wait 2.5;
    self set_move_speed_scale(1);
}

acquire_vortex_and_watch_damage(w_weapon)
{
    self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");

    util::wait_network_frame();
    e_target_ball = undefined;
    foreach(model in getentarray("script_model", "className"))
    {
        if(!isdefined(model.model)) continue;
        if(model.model != "p7_fxanim_zm_stal_ray_gun_ball_mod") continue;
        if(isdefined(model.captured) && model.captured) continue;
        model.captured = true;
        e_target_ball = model;
    }
    if(!isdefined(e_target_ball)) return;

    e_target_ball endon("death");
    while(!isdefined(e_target_ball.e_owner) || !isdefined(e_target_ball.n_end_time)) 
    {
        util::wait_network_frame();
    }

	while(isdefined(e_target_ball) && gettime() <= e_target_ball.n_end_time)
	{
		if(e_target_ball.n_damage_type == 1)
		{
			n_radius = 128;
			if(w_weapon == level.w_raygun_mark3lh)
			{
				n_pulse_damage = 50;
			}
			else
			{
				n_pulse_damage = 100;
			}
		}
		else
		{
			n_radius = 128;
			if(w_weapon == level.w_raygun_mark3lh)
			{
				n_pulse_damage = 1000;
			}
			else
			{
				n_pulse_damage = 5000;
			}
		}
		n_radius_squared = n_radius * n_radius;
		a_players = getplayers();
        arrayremovevalue(a_players, self, false);
		foreach(player in a_players)
		{
			if(player.sessionstate != "playing") continue;
			if(distancesquared(e_target_ball.origin, player.origin) <= n_radius_squared)
			{
				player dodamage(int(n_pulse_damage), e_target_ball.origin, self, self, undefined, "MOD_UNKNOWN", 0, w_weapon);
			}
		}
		wait(0.5);
	}
}