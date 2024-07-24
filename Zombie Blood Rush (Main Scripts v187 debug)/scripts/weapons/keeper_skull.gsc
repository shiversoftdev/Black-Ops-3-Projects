monitor_keeper_skull()
{
    if(!isdefined(level.var_c003f5b)) return;
    self thread watch_skull_attack(); // attack
    self thread watch_skull_mesmerize(); // mesmerize
}

watch_skull_attack()
{
	self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");
    level endon("game_ended");

	for(;;)
	{
        wait(0.05);
		self util::waittill_attack_button_pressed();
        while(self attackbuttonpressed() && self is_using_keeper_skull() && !self.var_e1f8edd6 && self.var_118ab24e) // var_118ab24e hero energy
        {
            self keeper_skull_attack();
            wait(0.05);
        }
	}
}

is_using_keeper_skull()
{
	return self getcurrentweapon() == level.var_c003f5b;
}

keeper_skull_attack()
{
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");
    level endon("game_ended");
    
	a_players = getplayers();
    arrayremovevalue(a_players, self, false);
	a_targets = util::get_array_of_closest(self.origin, a_players, undefined, 8, 500);

    foreach(player in a_targets)
    {
        if(player.sessionstate != "playing") continue;
        if(isdefined(player.var_20b8c74a) && player.var_20b8c74a) continue;
        if(!self is_valid_skull_target(player)) continue;
        if(!BulletTracePassed(player geteye(), self geteye(), false, player))
        {
            continue;
        }
        if(isdefined(player.thrasherconsumed) && player.thrasherconsumed) continue;
        player.var_20b8c74a = 1;
        self thread keeper_skull_damage(player);
        wait(0.05);
    }
}

is_valid_skull_target(player)
{
    if(player.team == self.team)
    {
        return false;
    }
	if(self util::is_player_looking_at(player.origin, 0.85, 0))
	{
		return true;
	}
	if(self util::is_player_looking_at(player.origin + (0,0,50), 0.85, 0))
	{
		return true;
	}
	return false;
}

keeper_skull_damage(e_player)
{
    if(!isdefined(e_player)) return;
    
	self endon("disconnect");
    self endon("bled_out");
    level endon("game_ended");
    e_player endon("disconnect");
	e_player endon("bled_out");

    e_player playsound("zmb_elec_jib_zombie");
	var_9ae6d5f2 = 0;
	while(self attackbuttonpressed() && self is_using_keeper_skull() && !self.var_e1f8edd6 && self.var_118ab24e)
	{
		e_player.var_20b8c74a = 1;
        wait(0.25);
        e_player thread playFXTimedOnTag(level._effect["tesla_shock"], "j_head", 0.25);
        self skull_consume_hero_power(5);
        e_player dodamage(int(SKULL_DMG_PER_TICK * CLAMPED_ROUND_NUMBER), e_player.origin, self, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
        e_player set_move_speed_scale(0.75, true);
        if(!e_player util::is_bot()) e_player SetElectrified(0.25);
	}
	e_player.var_20b8c74a = 0;
    e_player set_move_speed_scale(1.0);
}

skull_consume_hero_power(n_power_consumed)
{
	if(self.var_118ab24e >= n_power_consumed)
	{
		self gadgetpowerset(0, self.var_118ab24e - n_power_consumed);
        self.var_118ab24e -= n_power_consumed;
        if(self.var_118ab24e < 0)
        {
            self.var_118ab24e = 0;
        }
	}
	else
	{
		self gadgetpowerset(0, 0);
		self.var_230f31ae = 0;
	}
}

//function_e703c25f watch_skull_mesmerize
watch_skull_mesmerize()
{
	self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");
    level endon("game_ended");

	for(;;)
	{
        wait(0.05);
		if(!self util::ads_button_held()) continue;
        if(!self.var_118ab24e || self.var_e1f8edd6) continue; // dont have hero energy or afflicted by spores
        if(self attackbuttonpressed() || self ismeleeing()) continue;
        if(!self is_using_keeper_skull()) continue;
        a_players = getplayers();
        arrayremovevalue(a_players, self, false);
        a_targets = util::get_array_of_closest(self.origin, a_players, undefined, undefined, 500);
        foreach(e_player in a_targets)
        {
            if(e_player.sessionstate != "playing") continue;
            if(isdefined(e_player.var_9b59d7f8) && e_player.var_9b59d7f8) continue;
            if(isdefined(e_player.thrasherconsumed) && e_player.thrasherconsumed) continue;
            if(isdefined(e_player.var_3f6ea790) && e_player.var_3f6ea790) continue;
            self thread mesmerize_player(e_player);
        }
        wait(0.05);
	}
}

mesmerize_player(e_player)
{
    if(!isdefined(e_player)) return;
	self endon("disconnect");
	e_player endon("bled_out");
    e_player endon("disconnect");
	while(self util::ads_button_held() && self.var_118ab24e && self is_within_skull_range(e_player) && !self.var_9adfaccf && self is_using_keeper_skull() && self.sessionstate == "playing")
	{
        wait(0.05);
		if(isdefined(e_player.var_9b59d7f8) && e_player.var_9b59d7f8) continue;

        e_player.var_9b59d7f8 = 1;
        e_player thread player_mesmerize_refresh(self);
	}
	e_player.var_9b59d7f8 = 0;
}

player_mesmerize_refresh(e_attacker)
{
    self endon("bled_out");
	self endon("disconnect");
    e_attacker endon("disconnect");
    while(self.var_9b59d7f8)
    {
        self disableWeapons();
        self disableusability();
        self thread playFXTimedOnTag(level._effect["tesla_shock"], "j_head", 0.25);
        self set_move_speed_scale(0.25, true);
        if(!self util::is_bot()) self SetElectrified(0.25);
        e_attacker zm_score::add_to_player_score(SKULL_MESMERIZE_SCORE_PER_TICK, 1, "gm_zbr_admin");
        e_attacker skull_consume_hero_power(2);
        wait 0.25;
    }
    self enableWeapons();
    self enableusability();
    self set_move_speed_scale(1);
}

is_within_skull_range(e_player)
{
	if(distance2dsquared(self.origin, e_player.origin) <= 250000)
	{
		return true;
	}
	return false;
}

detour zm_island_skullquest<scripts\zm\zm_island_skullweapon_quest.gsc>::function_c7a0c111(b_success = 1, var_bf49654c = 1)
{
	self endon("death");
	self notify(#"hash_eb13d3a5");
	if(!(isdefined(self.var_3f6ea790) && self.var_3f6ea790))
	{
		self setgoal(self.origin);
		if(isdefined(var_bf49654c) && var_bf49654c)
		{
			wait(randomfloatrange(0.05, 0.25));
		}
        if(!isdefined(self))
        {
            return;
        }
		if(isdefined(b_success) && b_success)
		{
			if(isdefined(self.archetype) && self.archetype == "zombie")
			{
				self thread zombie_utility::zombie_eye_glow_stop();
				self clientfield::set("death_ray_shock_eye_fx", 1);
				self scene::play("cin_zm_dlc1_zombie_dth_deathray_04", self);
				self clientfield::set("death_ray_shock_eye_fx", 0);
				self zombie_utility::zombie_head_gib(self);
			}
			if(isdefined(self.archetype) && self.archetype != "spider")
			{
				util::wait_network_frame();
				self thread zombie_utility::zombie_gut_explosion();
			}
		}
		self dodamage(self.health * 2, self.origin);
	}
}

detour zm_island_skullquest<scripts\zm\zm_island_skullweapon_quest.gsc>::function_80794095()
{

}