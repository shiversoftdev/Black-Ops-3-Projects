trap_fire_player()
{
    self endon("bled_out");
	self endon("disconnect");
    if(isdefined(self.is_burning) && self.is_burning) return;
    if(self laststand::player_is_in_laststand()) return;
	self.is_burning = 1;
    self thread set_player_burn(0.1);
    self dodamage(self hasperk("specialty_armorvest") ? int(CLAMPED_ROUND_NUMBER * TRAP_FIRE_ROUND_DAMAGE) : TRAP_FIRE_DEFAULT_DAMAGE, self.origin);
    wait(0.1);
    self playsound("zmb_ignite");
    self.is_burning = undefined;
}

trap_electric_watch_zm()
{
    self endon("trap_done");
    self endon("trap_deactivate");
    self endon("death");
    for(;;)
    {
        foreach(zombie in getaiteamarray(level.zombie_team))
        {
            if(zombie istouching(self))
            {
                self notify("trigger", zombie);
            }
        }
        wait 0.05;
    }
}

detour zm_trap_electric<scripts\zm\_zm_trap_electric.gsc>::trap_activate_electric()
{
    self thread trap_electric_watch_zm();
    fn_original = @zm_trap_electric<scripts\zm\_zm_trap_electric.gsc>::trap_activate_electric;
    self [[ fn_original ]]();
}

detour ctrap<scripts\zm\zm_zod_traps.gsc>::trap_damage()
{
    self endon("trap_done");

    if(!isdefined(level.zm_zod_traps_trap_damage))
    {
        level.zm_zod_traps_trap_damage = @ctrap<scripts\zm\zm_zod_traps.gsc>::trap_damage;
    }
    if(!isdefined(level.zm_zod_traps_trap_damage_nonplayer))
    {
        level.zm_zod_traps_trap_damage_nonplayer = @ctrap<scripts\zm\zm_zod_traps.gsc>::trap_damage_nonplayer;
    }
    thread [[ level.zm_zod_traps_trap_damage ]]();
    
    n_distance = 90;
    n_distance_squared = n_distance * n_distance;
    for(;;)
    {
        foreach(zombie in getaiteamarray(level.zombie_team))
        {
            if(!isdefined(zombie) || !isalive(zombie))
            {
                continue;
            }

            if(isdefined(zombie.marked_for_death))
            {
                continue;
            }

            if(isdefined(zombie.missinglegs) && zombie.missinglegs)
            {
                continue;
            }

            if(isdefined(zombie.var_de36fc8))
            {
                zombie [[zombie.var_de36fc8]](self);
                continue;
            }

            if(isdefined(zombie.trap_damage_cooldown) && zombie.trap_damage_cooldown)
            {
                continue;
            }
            
            if(distanceSquared(zombie.origin, self.m_t_damage.origin) > n_distance_squared)
            {
                continue;
            }

            thread [[ level.zm_zod_traps_trap_damage_nonplayer ]](zombie);
        }
        wait 0.1;
    }
}

detour zm_sumpf_trap_pendulum<scripts\zm\zm_sumpf_trap_pendulum.gsc>::pendamage(parent, who)
{
    self thread 
    [[
        function() =>
        {
            // not my code, this is treyarch's...
            level.my_time = 0;
            while(level.my_time <= 20)
            {
                wait(0.1);
                level.my_time = level.my_time + 0.1;
            }
            wait 3;
            self notify("kill_trap");
        }
    ]]();

    level.zm_sumpf_trap_pendulum_zombiependamage ??= @zm_sumpf_trap_pendulum<scripts\zm\zm_sumpf_trap_pendulum.gsc>::zombiependamage;

    self endon("kill_trap");
    who endon("disconnect");
	while(true)
	{
		foreach(ent in GetAITeamArray(level.zombie_team))
        {
            if(ent IsTouching(self))
            {
                ent thread [[ level.zm_sumpf_trap_pendulum_zombiependamage ]](parent, who);
            }
        }
		foreach(player in level.players)
        {
            if(player.sessionstate != "playing")
            {
                continue;
            }
            if(player istouching(self))
            {
                hasnt_jugg = !(player hasperk("specialty_armorvest"));
                attacker = (who == player) ? self : who;
                player DoDamage(hasnt_jugg ? 100000 : 75, player.origin, attacker, attacker, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                if(hasnt_jugg)
                {
                    if(player laststand::player_is_in_laststand())
                    {
                        continue;
                    }
                    player SetStance("crouch");
                }
            }
        }
        wait 0.1;
	}
}