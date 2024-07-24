AwardPlayerSpikes(player)
{
    if(isdefined(player.gravityspikes_state) && player.gravityspikes_state == 0)
	{
		wpn_gravityspikes = getweapon("hero_gravityspikes_melee");
		player zm_weapons::weapon_give(wpn_gravityspikes, 0, 1);
		player gadgetpowerset(player gadgetgetslot(wpn_gravityspikes), 100);
		player.gravityspikes_state = 2;
		player playrumbleonentity("zm_castle_interact_rumble");
	}
}

wield_gravityspikes(wpn_gravityspikes)
{
    create_default_lp();
    self thread gravityspikes_attack_watcher(wpn_gravityspikes);
	self thread gravityspikes_swipe_watcher(wpn_gravityspikes);
    self [[ level.old_gs_wield_fn ]](wpn_gravityspikes);
}

unwield_gravityspikes(wpn_gravityspikes)
{
    if(isdefined(self.b_gravity_trap_spikes_in_ground) && self.b_gravity_trap_spikes_in_ground)
    {
        self thread gravity_trap_loop(self.v_gravity_trap_pos, wpn_gravityspikes);
    }
    self [[ level.old_gs_unwield_fn ]](wpn_gravityspikes);
}

gravityspikes_swipe_watcher(wpn_gravityspikes)
{
	self endon("gravityspikes_attack_watchers_end");
	self endon("disconnect");
	self endon("bled_out");
	self endon("spawned_player");
	self endon("death");
	self endon("gravity_spike_expired");
	level endon("game_ended");
	for(;;)
	{
		self waittill("weapon_melee", weapon);
		weapon thread spikesarc_swipe(self);
	}
}

spikesarc_swipe(player)
{
	player thread chop_players_gs(1, 1, self);
	wait(0.3);
	player thread chop_players_gs(0, 1, self);
	wait(0.5);
	player thread chop_players_gs(0, 0, self);
}

chop_players_gs(first_time, leftswing, weapon)
{
	if(!isdefined(weapon)) weapon = level.weaponnone;
	view_pos = self getweaponmuzzlepoint();
	forward_view_angles = self getweaponforwarddir();
	foreach(player in level.players)
	{
		if(player.sessionstate != "playing") continue;
		if(first_time) player.chopped = 0;
		else if(isdefined(player.chopped) && player.chopped) continue;
		test_origin = player.origin + (0,0,50);
		dist_sq = distancesquared(view_pos, test_origin);
		dist_to_check = level.spikes_chop_cone_range_sq;
		if(dist_sq > dist_to_check) continue;
		normal = vectornormalize(test_origin - view_pos);
		dot = vectordot(forward_view_angles, normal);
		if(dot <= 0) continue;
		if(!(player damageconetrace(view_pos, self))) continue;
		player.chopped = 1;
		self thread chop_player_gs(player, leftswing, weapon);
	}
}

chop_player_gs(player, leftswing, weapon = level.weaponnone)
{
	self endon("disconnect");
	if(player.sessionstate != "playing") return;
	if(3594 >= player.health) player.ignoremelee = 1;
	player zombie_slam_direction(self, ZM_CASTLE_THROWBACK_MAJOR);
	player dodamage(int(3594 * (CLAMPED_ROUND_NUMBER * 0.5)), self.origin, self, self, "none", "MOD_UNKNOWN", 0, weapon);
	util::wait_network_frame();
}

gravityspikes_attack_watcher(wpn_gravityspikes)
{
	self endon("gravityspikes_attack_watchers_end");
	self endon("disconnect");
	self endon("bled_out");
	self endon("death");
	self endon("gravity_spike_expired");
	for(;;)
	{
		self waittill("weapon_melee_power", weapon);
		if(weapon == wpn_gravityspikes)
        {
			self thread knockdown_zombies_slam();
		}
	}
}

knockdown_zombies_slam()
{
	v_forward = anglestoforward(self getplayerangles());
	v_pos = self.origin + vectorscale(v_forward, 24);
	a_players = array::filter(getplayers(), 0, serious::gravityspikes_target_filtering);
    arrayremovevalue(a_players, self, true);
	a_megahurt_players = arraysortclosest(a_players, v_pos, a_players.size, 0, 200);
	array::thread_all(a_megahurt_players, serious::grav_spike_megahurt, v_pos, self);
	a_slam_players = arraysortclosest(a_players, v_pos, a_players.size, 200, 400);
	array::thread_all(a_slam_players, serious::zombie_slam_direction, self);
}

gravityspikes_target_filtering(player)
{
	return player.sessionstate == "playing" && !laststand::player_is_in_laststand();
}

grav_spike_megahurt(v_position, player)
{
	n_gravity_spike_melee_radius_sq = 40000;
	if(self check_for_range_and_los(v_position, 96, n_gravity_spike_melee_radius_sq))
	{
		self arc_lightning(self.origin, self.origin, player);
        self zombie_slam_direction(player, ZM_CASTLE_THROWBACK_MAJOR);
		self dodamage(int(ZM_SPIKES_SLAM_DMG * CLAMPED_ROUND_NUMBER), player.origin, player, player, "none", "MOD_EXPLOSIVE", 0, player getCurrentWeapon());
	}
}

check_for_range_and_los(v_attack_source, n_allowed_z_diff, n_radius_sq)
{
    n_z_diff = self.origin[2] - v_attack_source[2];
    if(abs(n_z_diff) < n_allowed_z_diff)
    {
        if(distance2dsquared(self.origin, v_attack_source) < n_radius_sq)
        {
            v_offset = vectorscale((0, 0, 1), 50);
            if(bullettracepassed(self.origin + v_offset, v_attack_source + v_offset, 0, self))
            {
                return 1;
            }
        }
    }
	return 0;
}

zombie_slam_direction(player, scale = ZM_CASTLE_THROWBACK_MINOR)
{
    self setOrigin(self.origin + (0,0,1));
	vec_throw = vectorNormalize(self geteye() - player getTagOrigin("tag_weapon_right") + (0,0,150));
    self setVelocity(self getVelocity() + VectorScale(vec_throw, scale));
	self.launch_magnitude_extra = scale;
    self.v_launch_direction_extra = vec_throw;
}

gravity_trap_loop(v_gravity_trap_pos, wpn_gravityspikes)
{
	self endon("gravity_trap_spikes_retrieved");
	self endon("disconnect");
	self endon("bled_out");
	self endon("death");
	is_gravity_trap_fx_on = 1;
	while(self zm_hero_weapon::is_hero_weapon_in_use() && self.hero_power > 0)
	{
		a_players = array::filter(getplayers(), 0, ::gravityspikes_target_filtering);
        arrayremovevalue(a_players, self, true);
		array::thread_all(a_players, serious::gravity_trap_check, self, wpn_gravityspikes);
		wait ZM_SPIKES_TICKDELAY;
	}
}

gravity_trap_check(player, wpn_gravityspikes)
{
	player endon("gravity_trap_spikes_retrieved");
	player endon("disconnect");
	player endon("bled_out");
	player endon("death");
    self endon("disconnect");
    self endon("bled_out");
	n_gravity_trap_radius_sq = 16384;
	v_gravity_trap_origin = player.mdl_gravity_trap_fx_source.origin;
	if(player.sessionstate != "playing") return;
	if(self check_for_range_and_los(v_gravity_trap_origin, 96, n_gravity_trap_radius_sq))
	{
		self dodamage(ZM_SPIKES_DPS * ZM_SPIKES_TICKDELAY, v_gravity_trap_origin, player, undefined, "none", "MOD_UNKNOWN", 0, wpn_gravityspikes);
	}
}