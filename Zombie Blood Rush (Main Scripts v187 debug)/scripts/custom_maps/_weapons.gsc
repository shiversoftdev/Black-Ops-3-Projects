claymore_detonation()
{
    origin = self.origin;
    owner = self.owner;
    owner endon("disconnect");

    self waittill("death");
    foreach(player in level.players)
    {
        if(player.team == owner.team)
        {
            continue;
        }
        if(player.sessionstate != "playing")
        {
            continue;
        }
        if(player.origin[2] < (origin[2] + 80) && player.origin[2] > (origin[2] - 80) && distancesquared(player.origin, origin) < 40000)
		{
			player dodamage(CLAMPED_ROUND_NUMBER * 100, self.origin, self, undefined, "none", "MOD_UNKNOWN", 0, get_map_grenade());
		}
    }
}

claymore_override(b_playfx = true)
{
	level.claymore_alert_sfx = "wpn_claymore_alert";
	level.claymore_explode_sfx = undefined;
	level.claymore_fx_explode = undefined;

	level.claymore_playfx = b_playfx;
	level.__shouldaffectclaymore = function(zombie) =>
    {
        if(!isalive(zombie))
        {
            return false;
        }
        position = zombie.origin + vectorscale((0, 0, 1), 32);
        dirtopos = position - self.origin;
        claymoreforward = anglestoforward(self.angles);
        dist = vectordot(dirtopos, claymoreforward);
        if(dist < 20 || dist > 200)
        {
            return false;
        }
        dirtopos = vectornormalize(dirtopos);
        dot = vectordot(dirtopos, claymoreforward);
        if(isplayer(zombie))
        {
            if(!isdefined(zombie.ignoreme) || zombie.ignoreme > 0)
            {
                return false;
            }
            if(zombie.team == self.owner.team)
            {
                return false;
            }
            lineofsight = bullettracepassed(self.origin + vectorscale((0, 0, 1), 40), zombie gettagorigin("j_spinelower"), 0, self);
        }
        else
        {
            lineofsight = bullettracepassed(self.origin + vectorscale((0, 0, 1), 40), zombie gettagorigin("j_mainroot"), 0, self);
        }
        return (dot > cos(70)) && lineofsight;
    };

    level.placeable_mine_planted_callbacks["claymore"][level.placeable_mine_planted_callbacks["claymore"].size - 1] = function(owner) =>
    {
        self.angles = self.owner.angles;
        self util::waittillnotmoving();
        self playsound("wpn_claymore_plant");
		if(level.claymore_playfx)
		{
			playfxontag(level._effect["fx_claymore_laster"], self, "tag_fx");
		}
        
        self.detonating = false;
        self thread [[ function(owner) => 
        {
            self endon("picked_up");
            self endon("death");
            trigger = spawn("trigger_radius", self.origin - vectorscale((0, 0, 1), 128), get_flags_trigger_zbr(), 172, 256);
            trigger TriggerIgnoreTeam();
            trigger.detectid = ("trigger" + gettime()) + randomint(1000000);
            trigger enablelinkto();
            trigger linkto(self);

            for(;;)
            {
                foreach(zombie in GetAITeamArray(level.zombie_team))
                {
                    if(!isdefined(zombie) || !isalive(zombie))
                    {
                        continue;
                    }
                    if(zombie isTouching(trigger))
                    {
                        if(self [[ level.__shouldaffectclaymore ]](zombie) && !self.detonating)
                        {
                            self.detonating = 1;
							if(isdefined(level.claymore_alert_sfx))
							{
								self playsound(level.claymore_alert_sfx);
							}
                            wait(0.4);
							if(isdefined(level.claymore_explode_sfx))
							{
								self playsound(level.claymore_explode_sfx);
							}
							if(isdefined(level.claymore_fx_explode))
							{
								playfx(level.claymore_fx_explode, self.origin);
							}
                            self detonate();
                            return;
                        }
                    }
                }
                foreach(player in getplayers())
                {
                    if(player.sessionstate != "playing")
                    {
                        continue;
                    }
                    if(player.team == owner.team)
                    {
                        continue;
                    }
                    if(isdefined(player.ignoreme) && player.ignoreme > 0)
                    {
                        continue;
                    }
                    if(player isTouching(trigger))
                    {
                        if(self [[ level.__shouldaffectclaymore ]](player) && !self.detonating)
                        {
                            self.detonating = 1;
                            if(isdefined(level.claymore_alert_sfx))
							{
								self playsound(level.claymore_alert_sfx);
							}
                            wait(0.4);
							if(isdefined(level.claymore_explode_sfx))
							{
								self playsound(level.claymore_explode_sfx);
							}
							if(isdefined(level.claymore_fx_explode))
							{
								playfx(level.claymore_fx_explode, self.origin);
							}
                            self detonate();
                            return;
                        }
                    }
                }
                wait 0.1;
            }
        }]](owner);
    };

    register_weapon_postcalc("claymore", true);
    register_weapon_calculator("claymore", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor) =>
    {
        return int(CLAMPED_ROUND_NUMBER * ZM_UNDERWATER_CLAYMORE_DMG_PER_ROUND);
    });
}

wraith_fire_watch()
{
	level endon("end_game");
	self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");

	level flag::wait_till("initial_blackscreen_passed");
	for(;;)
	{
		self waittill("grenade_fire", grenade, weapon);
		if(!isdefined(grenade))
		{
			continue;
		}
		if(weapon.name == "wraith_fire")
		{
			grenade thread wraith_fire_damage(self);
		}
	}
}

wraith_fire_damage(player)
{
	self waittill("grenade_bounce", pos, normal, ent, surface);
	self setinvisibletoall();
	fire_spot = zm_utility::groundpos(pos);
	wait(0.05);
	self thread watch_pvp_wf_damage(player);
	wait(10.05);
    self notify("kill_pvp_wf_damage");
}

watch_pvp_wf_damage(player)
{
	self endon("death");
	self endon("kill_pvp_wf_damage");
	for(;;)
	{
		zombies = getplayers();
		zombies = util::get_array_of_closest(self.origin, zombies, undefined, 24, 128);
		foreach(zombie in zombies)
		{
			if(zombie.sessionstate != "playing")
            {
                continue;
            }
            if(zombie.team == player.team)
            {
                continue;
            }
            zombie dodamage((MIRG_2000_AOE_TICK_DMG * CLAMPED_ROUND_NUMBER), zombie.origin, player, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
		}
		wait(0.1);
	}
}

#define ACIDGAT_RADIUS = 200;
wait_for_blundersplat_fired()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("spawned_player");

	level.acidgat ??= getweapon("bo2_acidgat");
	level.acidgat_upgraded ??= getweapon("bo2_acidgat_upgraded");
	
	if(!isdefined(level.gib_tags))
	{
		zombie_utility::init_gib_tags();
	}

	for(;;)
	{
		self waittill("weapon_fired");
		w_current = self getcurrentweapon();
		if(w_current == level.acidgat || w_current == level.acidgat_upgraded)
		{
			sm_projectiles = [];
			for(i = 0; i < 3; i++)
			{
				eye = self geteye();
				v_position = bullettrace(eye, eye + vectorscale(anglestoforward(self getplayerangles()), 10000), true, self)["position"];
				sm_projectile = spawn("script_model", v_position);
				sm_projectile setmodel("acidgat_projectile");
				sm_projectile.angles = (90, 0, 0);
				sm_projectile zm_utility::create_zombie_point_of_interest(1536, 96, 10000);

				e_enemy = undefined;
				foreach(player in getplayers())
				{
					if(player.sessionstate != "playing")
					{
						continue;
					}
					if(player == self)
					{
						continue;
					}
					if(!bullettracepassed(v_position, player geteye(), false, sm_projectile))
					{
						continue;
					}
					if(distance2d(player.origin, v_position) <= 40 && abs(player.origin[2] - v_position[2]) <= 70)
					{
						e_enemy = player;
						break;
					}
				}

				if(!isdefined(e_enemy))
				{
					foreach(zombie in getaiteamarray(level.zombie_team))
					{
						if(!isalive(zombie))
						{
							continue;
						}
						if(distance(zombie getCentroid(), v_position) <= 100)
						{
							e_enemy = zombie;
							break;
						}
					}
				}

				if(isdefined(e_enemy))
				{
					sm_projectile EnableLinkTo();
					sm_projectile linkto(e_enemy, tolower(level.gib_tags[randomint(level.gib_tags.size)]), (0, 0, 0));
				}

				sm_projectile.attract_to_origin = 1;
				sm_projectiles[sm_projectiles.size] = sm_projectile;
				util::wait_network_frame();
			}

			self thread destroy_acidgat_projectiles(sm_projectiles, w_current == level.acidgat_upgraded);
		}
		util::wait_network_frame();
	}
}

destroy_acidgat_projectiles(projectiles, b_is_upgraded)
{
	self endon("disconnect");

	wait(b_is_upgraded ? 5 : 2);
	for(i = 0; i < projectiles.size; i++)
	{
		sm_projectile = projectiles[i];
		random = randomintrange(0, 4);
		playsoundatposition("explo_0" + random, sm_projectile.origin);
		sm_projectile.attract_to_origin = 0;
		playfx(level._effect["acid_exp"], sm_projectile.origin);
		earthquake(0.3, 1, sm_projectile.origin, 350);
		sm_projectile hide();

		foreach(ai_target in getaiteamarray(level.zombie_team))
		{
			if(isdefined(ai_target))
			{
				n_distance_to_target = distance(ai_target.origin, sm_projectile.origin);
				if(isdefined(ai_target.is_brutus) && ai_target.is_brutus)
				{
					continue;
				}
				if(n_distance_to_target > ACIDGAT_RADIUS)
				{
					continue;
				}
				ai_target dodamage(ai_target.health + 666, ai_target.origin, self, self, "none", "MOD_EXPLOSIVE", 0, level.acidgat);
				self zm_score::add_to_player_score(50);
			}
		}

		foreach(player in getplayers())
		{
			if(player == self)
			{
				continue;
			}
			if(player.team == self.team)
			{
				continue;
			}
			if(player.sessionstate != "playing")
			{
				continue;
			}
			if(!bullettracepassed(sm_projectile.origin + (0, 0, 10), player geteye(), false, sm_projectile))
			{
				continue;
			}
			n_distance_to_target = distance(player.origin, sm_projectile.origin);
			if(n_distance_to_target > ACIDGAT_RADIUS)
			{
				continue;
			}
			player dodamage(int(ACIDGAT_DAMAGE_PER_ROUND * CLAMPED_ROUND_NUMBER * (1 + int(b_is_upgraded))), player.origin, self, self, "none", "MOD_EXPLOSIVE", 0, level.acidgat);
		}

		n_distance = distance(self.origin, sm_projectile.origin);
		if(n_distance < ACIDGAT_RADIUS)
		{
			self dodamage(75, self.origin, self, self, "none", "MOD_EXPLOSIVE", 0, level.acidgat);
		}

		sm_projectile delete();
		util::wait_network_frame();
	}
}

#define TOMAHAWK_IMPACT_DMG = 115;
tomahawk_init(fn_tomahawk_spawn, fn_tomahawk_return_player, fx_package, w_tomahawk)
{
	level.tomahawk_spawn = fn_tomahawk_spawn;
	level.tomahawk_return_player = fn_tomahawk_return_player;
	level.tomahawk_fx_package = fx_package;
	level.w_tomahawk = w_tomahawk;
}

watch_for_tomahawk_throw()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("spawned_player");

	while(true)
	{
		self waittill("grenade_fire", grenade, weapname);
		
		if(!issubstr(weapname.name, "tomahawk"))
		{
			continue;
		}

		grenade.use_grenade_special_bookmark = 1;
		grenade.grenade_multiattack_bookmark_count = 1;
		grenade.low_level_instant_kill_charge = 1;
		grenade.owner = self;

		if(isdefined(self.n_tomahawk_cooking_time))
		{
			grenade.n_cookedtime = grenade.birthtime - self.n_tomahawk_cooking_time;
		}
		else
		{
			grenade.n_cookedtime = 0;
		}

		self thread tomahawk_thrown(grenade, weapname);
	}
}

tomahawk_thrown(grenade, w_weapon)
{
	self endon("disconnect");
	grenade endon("in_hellhole");

	if(level.script == "zm_alcatraz_island")
	{
		self clientfield::set_to_player("tomahawk_in_use", 2);
	}
	else if(level.script == "zm_westernz")
	{
		fx = playfxontag("harry/tomahawk/fx_tomahawk_charged_trail", grenade, "tag_origin");
		fx thread [[ function(grenade) => 
		{
			self endon("death");
			grenade waittill("death");
			self delete();
		}]](grenade);
	}

	grenade util::waittill_either("death", "time_out");
	grenade_origin = grenade.origin;
	n_grenade_charge_power = grenade get_tomahawk_charge_power(self);

	a_zombies = getaispeciesarray(level.zombie_team, "all");
	a_players = [];
	foreach(player in getplayers())
	{
		if(player.sessionstate != "playing")
		{
			continue;
		}
		if(player.team == self.team)
		{
			continue;
		}
		if(!bullettracepassed(grenade_origin, player geteye(), false, grenade))
		{
			continue;
		}
		a_players[a_players.size] = player;
	}

	a_enemies = util::get_array_of_closest(grenade_origin, arraycombine(a_players, a_zombies, false, false), undefined, undefined, 200);
	a_powerups = util::get_array_of_closest(grenade_origin, level.active_powerups, undefined, undefined, 200);

	if(isdefined(a_powerups) && a_powerups.size > 0)
	{
		m_tomahawk = [[ level.tomahawk_spawn ]](grenade_origin, n_grenade_charge_power);
		m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
		foreach(powerup in a_powerups)
		{
			powerup.origin = grenade_origin;
			powerup linkto(m_tomahawk);
			m_tomahawk.a_has_powerup = a_powerups;
		}
		return self [[ level.tomahawk_return_player ]](m_tomahawk, 0);
	}

	foreach(enemy in a_enemies)
	{
		enemy.hit_by_tomahawk = 0;
	}

	b_ricochet = false;
	if(isdefined(a_enemies[0]) && isalive(a_enemies[0]))
	{
		v_zombiepos = a_enemies[0].origin;
		if(isai(a_enemies[0]) && isdefined(level.tomahawk_fx_package.cf_hit))
		{
			a_enemies[0] clientfield::set(level.tomahawk_fx_package.cf_hit, 1);
		}

		if(isplayer(a_enemies[0]))
		{
			n_tomahawk_damage = int(n_grenade_charge_power * TOMAHAWK_IMPACT_DMG * CLAMPED_ROUND_NUMBER);
		}
		else
		{
			n_tomahawk_damage = a_enemies[0].health + 666;
		}

		a_enemies[0] dodamage(n_tomahawk_damage, grenade_origin, self, grenade, "none", "MOD_IMPACT", 0, w_weapon);
		a_enemies[0].hit_by_tomahawk = 1;

		a_enemies = util::get_array_of_closest(grenade_origin, arraycombine(a_players, a_zombies, false, false), undefined, undefined, 300);
		b_ricochet = true;
	}

	m_tomahawk = [[ level.tomahawk_spawn ]](grenade_origin, n_grenade_charge_power);
	m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;

	if(isdefined(grenade))
	{
		grenade delete();
	}

	if(!b_ricochet)
	{
		self thread [[ level.tomahawk_return_player ]](m_tomahawk, 0);
	}

	num_attacked = 0;
	for(i = a_enemies.size - 1; i > -1; i--)
	{
		if(!isdefined(a_enemies[i]) || !isalive(a_enemies[i]))
		{
			continue;
		}

		if(a_enemies[i].hit_by_tomahawk === true)
		{
			continue;
		}

		if(isplayer(a_enemies[i]) && a_enemies[i].sessionstate != "playing")
		{
			continue;
		}

		if(isplayer(a_enemies[i]))
		{
			if(!bullettracepassed(grenade_origin, player geteye(), false, m_tomahawk))
			{
				continue;
			}
		}

		tag = "j_head";
		if(isdefined(a_enemies[i].isdog) && a_enemies[i].isdog)
		{
			tag = "j_spine1";
		}

		v_target = a_enemies[i] gettagorigin(tag);
		m_tomahawk moveto(v_target, 0.3);
		m_tomahawk waittill("movedone");

		if(!(isdefined(a_enemies[i]) && isalive(a_enemies[i])))
		{
			continue;
		}

		if(isplayer(a_enemies[i]) && a_enemies[i].sessionstate != "playing")
		{
			continue;
		}

		if(issubstr(self.current_tactical_grenade.name, "upgraded"))
		{
			thawk_fx = playfxontag(level.tomahawk_fx_package.impact_upgraded, a_enemies[i], tag);
		}
		else
		{
			thawk_fx = playfxontag(level.tomahawk_fx_package.impact_regular, a_enemies[i], tag);
		}

		if(isdefined(level._effect["tomahawk_fire_dot"]))
		{
			thawk_fx2 = playfxontag(level._effect["tomahawk_fire_dot"], a_enemies[i], "j_spineupper");
		}

		if(isdefined(thawk_fx2))
		{
			thawk_fx2 thread [[ function() => { self endon("death"); wait 1; self delete(); } ]]();
		}

		if(isdefined(thawk_fx))
		{
			thawk_fx thread [[ function() => { self endon("death"); wait 1; self delete(); } ]]();
		}
		
		if(isai(a_enemies[i]))
		{
			a_enemies[i] clientfield::set(level.tomahawk_fx_package.cf_hit, 1);
		}

		if(isplayer(a_enemies[i]))
		{
			n_tomahawk_damage = int(n_grenade_charge_power * TOMAHAWK_IMPACT_DMG * CLAMPED_ROUND_NUMBER);
		}
		else
		{
			n_tomahawk_damage = a_enemies[i].health + 666;
		}

		a_enemies[i] dodamage(n_tomahawk_damage, grenade_origin, self, m_tomahawk, "none", "MOD_IMPACT", 0, w_weapon);
		a_enemies[i].hit_by_tomahawk = 1;

		num_attacked++;
		wait(0.2);
	}

	self thread [[ level.tomahawk_return_player ]](m_tomahawk, num_attacked);
}

get_tomahawk_charge_power(player)
{
	if(!isdefined(self.n_cookedtime))
	{
		return 1;
	}

	if(self.n_cookedtime >= 3000)
	{
		return 3;
	}

	if(self.n_cookedtime >= 2000)
	{
		return 6;
	}

	if(self.n_cookedtime >= 1000)
	{
		return 4;
	}

	return 1;
}

tomahawk_return_player(m_tomahawk, num_zombie_hit)
{
	self endon("disconnect");
	self endon("bled_out");
	self playsoundtoplayer("wpn_tomahawk_incoming", self);
	n_dist = distance2dsquared(m_tomahawk.origin, self.origin);
	if(!isdefined(num_zombie_hit))
	{
		num_zombie_hit = 5;
	}

	n_time = 0;
	while(n_dist > 4096 && n_time < 3)
	{
		m_tomahawk moveto(self geteye(), 0.25);
		if(num_zombie_hit < 5)
		{
			a_zombies = getaispeciesarray(level.zombie_team, "all");
			a_players = [];
			foreach(player in getplayers())
			{
				if(player.sessionstate != "playing")
				{
					continue;
				}
				if(player.team == self.team)
				{
					continue;
				}
				if(!bullettracepassed(m_tomahawk.origin, player geteye(), false, m_tomahawk))
				{
					continue;
				}
				a_players[a_players.size] = player;
			}

			a_enemies = util::get_array_of_closest(m_tomahawk.origin, arraycombine(a_players, a_zombies, false, false), undefined, undefined, 128);
			if(a_enemies.size)
			{
				e_enemy = a_enemies[0];
				for(i = 0; i < a_enemies.size; i++)
				{
					e_enemy = a_enemies[i];
					if(!isdefined(e_enemy) || !isalive(e_enemy))
					{
						continue;
					}
					if(e_enemy.hit_by_tomahawk === true)
					{
						continue;
					}
				}
				if(!isdefined(e_enemy) || !isalive(e_enemy) || (e_enemy.hit_by_tomahawk === true))
				{
					num_zombie_hit = 5;
					wait(0.1);
					n_dist = distance2dsquared(m_tomahawk.origin, self geteye());
					continue;
				}
				tag = "j_head";
				if(isdefined(e_enemy.isdog) && e_enemy.isdog)
				{
					tag = "j_spine1";
				}

				v_target = e_enemy gettagorigin(tag);
				m_tomahawk moveto(v_target, 0.3);
				m_tomahawk waittill("movedone");
				if(isdefined(e_enemy) && isalive(e_enemy) && (!isplayer(e_enemy) || e_enemy.sessionstate == "playing"))
				{
					if(issubstr(self.current_tactical_grenade.name, "upgraded"))
					{
						thawk_fx = playfxontag(level.tomahawk_fx_package.impact_upgraded, e_enemy, tag);
					}
					else
					{
						thawk_fx = playfxontag(level.tomahawk_fx_package.impact_regular, e_enemy, tag);
					}

					if(isdefined(thawk_fx))
					{
						thawk_fx thread [[ function() => { self endon("death"); wait 1; self delete(); } ]]();
					}
					
					if(isai(e_enemy))
					{
						e_enemy clientfield::set(level.tomahawk_fx_package.cf_hit, 1);
					}

					if(isplayer(e_enemy))
					{
						n_tomahawk_damage = int(2 * TOMAHAWK_IMPACT_DMG * CLAMPED_ROUND_NUMBER);
					}
					else
					{
						n_tomahawk_damage = e_enemy.health + 666;
					}

					e_enemy dodamage(n_tomahawk_damage, m_tomahawk.origin, self, m_tomahawk, "none", "MOD_UNKNOWN", 0, level.w_tomahawk);
					e_enemy.hit_by_tomahawk = 1;
				}
			}
			
			num_zombie_hit++;
		}
		wait(0.1);
		n_time += 0.1;
		n_dist = distance2dsquared(m_tomahawk.origin, self geteye());
	}

	if(isdefined(m_tomahawk.a_has_powerup))
	{
		foreach(powerup in m_tomahawk.a_has_powerup)
		{
			powerup.origin = self.origin;
		}
	}

	foreach(player in getplayers())
	{
		player.hit_by_tomahawk = undefined;
	}

	foreach(zombie in getaiteamarray(level.zombie_team))
	{
		zombie.hit_by_tomahawk = undefined;
	}

	m_tomahawk delete();
	self playsoundtoplayer("wpn_tomahawk_catch_plr", self);
	self playsound("wpn_tomahawk_catch_npc");
	wait(5);
	self playsoundtoplayer("wpn_tomahawk_cooldown", self);
	self givemaxammo(self.current_tactical_grenade);
	if(level.script == "zm_alcatraz_island")
	{
		self clientfield::set_to_player("tomahawk_in_use", 3);
	}
}

#define SLIPGUN_IMPACT_DMG = 1000;
enable_slipgun(fn_add_slippery_spot)
{
	register_box_weapon("slipgun", "slipgun_upgraded");
	level.fn_add_slippery_spot = fn_add_slippery_spot;
	register_zombie_death_animscript_callback(serious::slipgun_zombie_death);

	register_weapon_calculator("slipgun", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_UNKNOWN", attacker, inflictor) =>
    {
		if(sMeansOfDeath == "MOD_EXPLOSIVE")
		{
			return int(CLAMPED_ROUND_NUMBER * SLIPGUN_IMPACT_DMG / 8);
		}
        return int(CLAMPED_ROUND_NUMBER * SLIPGUN_IMPACT_DMG / 2);
    });

	register_weapon_calculator("slipgun_upgraded", function(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath, attacker, inflictor) =>
    {
		if(sMeansOfDeath == "MOD_EXPLOSIVE")
		{
			return int(CLAMPED_ROUND_NUMBER * SLIPGUN_IMPACT_DMG / 4);
		}
        return int(CLAMPED_ROUND_NUMBER * SLIPGUN_IMPACT_DMG);
    });

	level.fn_player_died_zbr = function (eInflictor, eAttacker, iDamage, sMeansOfDeath, weapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration) =>
	{
		if(weapon?.name ?& (weapon.name == "slipgun" || weapon.name == "slipgun_upgraded"))
		{
			self slipgun_explode_into_goo(eAttacker, weapon, 0);
		}
	};
}

slipgun_zombie_death()
{
	attacker = self.attacker;
	weapon = self.damageweapon;
	mod = self.damagemod;
	hit_location = self.damagelocation;
	if(!isdefined(weapon) || !(weapon?.name ?& (weapon.name == "slipgun" || weapon.name == "slipgun_upgraded")) || (mod != "MOD_IMPACT" && mod != "MOD_PROJECTILE" && mod != "MOD_PROJECTILE_SPLASH"))
	{
		return false;
	}

	level zm_spawner::zombie_death_points(self.origin, mod, hit_location, attacker, self);
	self thread slipgun_explode_into_goo(attacker, weapon, 0);
	return true;
}

// damage per round applied to players who are near an affected zombie
#define SLIPGUN_DAMAGE_CHAIN = 1000;

// damage per second of the slipgun multiplied by the round number
#define SLIPGUN_DOT_PER_SEC = 250;
slipgun_explode_into_goo(player, weapon, chain_depth)
{
	if(isdefined(self.marked_for_insta_upgraded_death))
	{
		return;
	}

	tag = "J_SpineLower";
	if(isdefined(self.isdog) && self.isdog)
	{
		tag = "tag_origin";
	}

	self.guts_explosion = 1;
	self playsound("wpn_slipgun_zombie_explode");
	playfx(level._effect[(weapon.name == "slipgun_upgraded") ? "slipgun_explode_upgraded" : "slipgun_explode"], self gettagorigin(tag));
	wait(0.1);
	self ghost();

	if(!isdefined(self.goo_chain_depth))
	{
		self.goo_chain_depth = chain_depth;
	}

	origin = self.origin;
	chain_depth = self.goo_chain_depth;
	if(level.zombie_vars["slipgun_max_kill_chain_depth"] > 0 && chain_depth > level.zombie_vars["slipgun_max_kill_chain_depth"])
	{
		return;
	}

	players = [];
	foreach(_player in getplayers())
	{
		if(_player.team == player.team)
		{
			continue;
		}
		if(_player.sessionstate != "playing")
		{
			continue;
		}
		players[players.size] = _player;
	}

	enemies = arraycombine(players, zombie_utility::get_round_enemy_array(), false, false);
	minchainwait = level.zombie_vars["slipgun_chain_wait_min"];
	maxchainwait = level.zombie_vars["slipgun_chain_wait_max"];
	chain_radius = level.zombie_vars["slipgun_chain_radius"];
	rsquared = chain_radius * chain_radius;
	enemies = array::get_all_closest(origin, enemies, undefined, undefined, chain_radius);
	marked_zombies = [];

	for(i = 0; i < enemies.size; i++)
	{
		enemy = enemies[i];
		if(isalive(enemy) && isai(enemy) && (!(isdefined(enemy.guts_explosion) && enemy.guts_explosion)) && (!(isdefined(enemy.nuked) && enemy.nuked)) && !isdefined(enemy.slipgun_sizzle))
		{
			if(bullettracepassed(origin + vectorscale((0, 0, 1), 50), enemy.origin + vectorscale((0, 0, 1), 50), 0, undefined))
			{
				enemy.slipgun_sizzle = playfxontag(level._effect[(weapon.name == "slipgun_upgraded") ? "slipgun_simmer_upgraded" : "slipgun_simmer"], enemy, "J_Head");
				enemy.slipgun_sizzle thread [[ function(enemy) => { self endon("death"); enemy waittill("death"); self delete(); } ]](enemy);
				marked_zombies[marked_zombies.size] = enemy;
			}
		}
		else if(isplayer(enemy))
		{
			marked_zombies[marked_zombies.size] = enemy;
		}
	}
	
	keys = getarraykeys(marked_zombies);
	for(i = 0; i < keys.size; i++)
	{
		enemy = marked_zombies[keys[i]];
		if(!isdefined(enemy) || !isalive(enemy) || (isdefined(enemy.guts_explosion) && enemy.guts_explosion) || (isdefined(enemy.nuked) && enemy.nuked))
		{
			continue;
		}
		wait(randomfloatrange(minchainwait, maxchainwait));
		if(!isdefined(enemy.goo_chain_depth))
		{
			enemy.goo_chain_depth = chain_depth;
		}
		if(!isdefined(enemy) || !isalive(enemy) || (isdefined(enemy.guts_explosion) && enemy.guts_explosion) || (isdefined(enemy.nuked) && enemy.nuked))
		{
			continue;
		}
		if(isai(enemy))
		{
			if(player zm_powerups::is_insta_kill_active())
			{
				enemy.health = 1;
			}
			enemy dodamage(level.slipgun_damage, enemy.origin, player, undefined, "none", "MOD_UNKNOWN", 0, weapon);
		}
		else if(isplayer(enemy))
		{
			enemy dodamage((SLIPGUN_DAMAGE_CHAIN * CLAMPED_ROUND_NUMBER), enemy.origin, player, undefined, "none", "MOD_UNKNOWN", 0, weapon);
		}
		if(level.slippery_spot_count < level.zombie_vars["slipgun_reslip_max_spots"])
		{
			if(level.zombie_vars["slipgun_reslip_rate"] > 0 && randomint(level.zombie_vars["slipgun_reslip_rate"]) == 0)
			{
				if(weapon.name == "slipgun_upgraded")
				{
					level thread [[ level.fn_add_slippery_spot ]](enemy.origin, 36, origin, level._effect["slipgun_splatter_upgraded"]);
				}
				else
				{
					level thread [[ level.fn_add_slippery_spot ]](enemy.origin, 24, origin, level._effect["slipgun_splatter"]);
				}
			}
		}
	}
}

slipgun_pvp()
{
	self endon("disconnect");
	self endon("spawned_player");
	self endon("bled_out");
	
	for(;;)
	{
		self waittill("missile_fire", missile, weapon);
		if(weapon?.name ?& (weapon.name == "slipgun" || weapon.name == "slipgun_upgraded"))
		{
			b_is_upgraded = weapon.name == "slipgun_upgraded";
			missile thread slipgun_slip_bolt(self, b_is_upgraded, weapon.name, level._effect[b_is_upgraded ? "slipgun_splatter_upgraded" : "slipgun_splatter"]);
		}
	}
}

slipgun_slip_bolt(player, upgraded, weapon, effect)
{
	player endon("disconnect");
	player endon("bled_out");
	startpos = player getweaponmuzzlepoint();
	self waittill("death");
	origin = self.origin;
	duration = 24;
	if(upgraded)
	{
		duration = 36;
	}
	while(duration > 0)
	{
		foreach(_player in getplayers())
		{
			if(_player.team == player.team)
			{
				continue;
			}
			if(_player.sessionstate != "playing")
			{
				continue;
			}
			if(BulletTrace(_player geteye(), origin, false, undefined)["fraction"] < 0.7)
			{
				continue;
			}
			if(DistanceSquared(_player.origin, origin) < 4900)
			{
				_player DoDamage(int(SLIPGUN_DOT_PER_SEC * 0.1 * CLAMPED_ROUND_NUMBER), origin, player, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
			}
		}
		duration -= 0.1;
		wait 0.1;
	}
}

#region magmagat
magmagat_fired(b_upgraded, attacker)
{
	self util::waittill_any("stationary", "death", "explode", "projectile_impact");
	start_turned_on = 1;
	poi_start_func = undefined;
	v_pos = zm_utility::groundpos(self.origin);
	v_angles = self.angles;
	mg_projectile = util::spawn_model("tag_origin", v_pos, v_angles);
	mg_projectile magmagat_is_on_navmesh();
	b_valid_poi = zm_utility::check_point_in_enabled_zone(mg_projectile.origin, undefined, undefined);
	if(isdefined(level.check_b_valid_poi))
	{
		b_valid_poi = mg_projectile [[level.check_b_valid_poi]](b_valid_poi);
	}
	if(b_valid_poi && mg_projectile.navmesh_check)
	{
		mg_projectile magmagat_move_away_from_edges();
		if(isdefined(b_upgraded) && b_upgraded)
		{
			mg_projectile zm_utility::create_zombie_point_of_interest(500, 10, 10000, start_turned_on, poi_start_func);
		}
		else
		{
			mg_projectile zm_utility::create_zombie_point_of_interest(250, 5, 10000, start_turned_on, poi_start_func);
		}
		mg_projectile thread zm_utility::create_zombie_point_of_interest_attractor_positions(4, 10);
		mg_projectile thread zm_utility::wait_for_attractor_positions_complete();
		mg_projectile thread magmagat_pooloffire(attacker);
	}
	else
	{
		mg_projectile delete();
	}
}

// multiplied by round number, ticks 5 times
#define MAGMAGAT_DMG_PER_TICK = 300;
magmagat_pooloffire(attacker)
{
	self endon(#"hash_2b7cd2b1");
	effectarea = spawn("trigger_radius", self.origin, 0, level.var_342a4409, level.var_b0fd8226);
	loopwaittime = 1;
	n_duration = 9;
	n_damage_origin = self.origin + vectorscale((0, 0, 1), 12);
	if(!isdefined(level.ai_magma_burn_fn))
	{
		level.ai_magma_burn_fn = @namespace_60798961<scripts\zm\_zm_weap_magmagat.gsc>::function_fb6444d2;
	}
	while(n_duration > 0)
	{
		foreach(player in level.players)
		{
			if(player.team == attacker.team)
			{
				continue;
			}
			if(player.sessionstate != "playing")
			{
				continue;
			}
			n_distance_to_target = distance(player.origin, n_damage_origin);
			if(n_distance_to_target > 120)
			{
				continue;
			}
			if(player.is_magma_burning !== true)
			{
				player thread [[ function(attacker) => 
				{
					self endon("disconnect");
					self.is_magma_burning = true;
					self [[ @burnplayer<scripts\shared\_burnplayer.gsc>::setplayerburning ]](1.25, 0.05, 0);
					for(i = 0; i < 5; i++)
					{
						self dodamage(int(MAGMAGAT_DMG_PER_TICK * CLAMPED_ROUND_NUMBER * 0.3), self.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
						wait 0.25;
					}
					self.is_magma_burning = false;
				}]](attacker);
			}
			player dodamage(int(MAGMAGAT_DMG_PER_TICK * CLAMPED_ROUND_NUMBER), self.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone); // extra damage for staying near the projectile
		}
		a_ai_targets = getaiteamarray(level.zombie_team);
		foreach(ai_target in a_ai_targets)
		{
			if(isdefined(ai_target) && !isdefined(ai_target.marked_for_death))
			{
				n_distance_to_target = distance(ai_target.origin, n_damage_origin);
				if(n_distance_to_target > 120)
				{
					continue;
				}
				ai_target thread [[ level.ai_magma_burn_fn ]](attacker);
			}
		}
		wait(loopwaittime);
		n_duration = n_duration - loopwaittime;
	}
	start_turned_on = 0;
	self zm_utility::deactivate_zombie_point_of_interest();
	self notify(#"hash_2b7cd2b1");
	effectarea delete();
	self delete();
}

magmagat_is_on_navmesh()
{
	if(ispointonnavmesh(self.origin, 60) == 1)
	{
		self.navmesh_check = 1;
		return;
	}
	v_valid_point = getclosestpointonnavmesh(self.origin, 100);
	if(isdefined(v_valid_point))
	{
		n_z_correct = 0;
		if(self.origin[2] > v_valid_point[2])
		{
			n_z_correct = self.origin[2] - v_valid_point[2];
		}
		self.origin = v_valid_point + (0, 0, n_z_correct);
		self.navmesh_check = 1;
		return;
	}
	self.navmesh_check = 0;
}

magmagat_move_away_from_edges()
{
	v_orig = self.origin;
	n_angles = self.angles;
	n_z_correct = 0;
	queryresult = positionquery_source_navigation(self.origin, 0, 200, 100, 2, 20);
	if(queryresult.data.size)
	{
		foreach(point in queryresult.data)
		{
			if(bullettracepassed(point.origin + vectorscale((0, 0, 1), 20), v_orig + vectorscale((0, 0, 1), 20), 0, self, undefined, 0, 0))
			{
				if(self.origin[2] > queryresult.origin[2])
				{
					n_z_correct = self.origin[2] - queryresult.origin[2];
				}
				self.origin = point.origin + (0, 0, n_z_correct);
				self.angles = n_angles;
				break;
			}
		}
	}
}
#endregion

set_level_olympia(str_regular, str_upgraded)
{
	level.w_olympia = getweapon(str_regular);
	level.w_olympia_ug = getweapon(str_upgraded);
}

w_olympia_dot_actor(b_is_upgraded = false, e_attacker)
{
	self endon("death");

	if(!b_is_upgraded)
	{
		return;
	}

	if(isdefined(self.olympia_burn_time) && self.olympia_burn_time > 0)
	{
		if(self.olympia_burn_time > 2.5)
		{
			self.olympia_burn_damage += CLAMPED_ROUND_NUMBER * 50 / 3;
			return;
		}
		self.olympia_burn_time += (3.0 - self.olympia_burn_time);
		self.olympia_burn_damage += CLAMPED_ROUND_NUMBER * 50 / 6;
		return;
	}

	self.olympia_burn_time = 3.0;
	self.olympia_burn_damage = CLAMPED_ROUND_NUMBER * 50 / 6;

	while(self.olympia_burn_time > 0)
	{
		self DoDamage(int(self.olympia_burn_damage), self getCentroid() + (randomFloatRange(-20, 20), randomFloatRange(-20, 20), randomFloatRange(-20, 20)), e_attacker, undefined, "none", "MOD_BURNED", 0, level.weaponnone);
		wait 0.5;
		self.olympia_burn_time -= 0.5;
	}
	self.olympia_burn_time = undefined;
}

is_ol_burning_weapon(weapon)
{
	return isdefined(weapon) && isdefined(level.zbr_burner_weapons) && isinarray(level.zbr_burner_weapons, weapon);
}

w_olympia_dot_player(b_is_upgraded = false, e_attacker)
{
	if(!isplayer(e_attacker))
	{
		return;
	}

	e_attacker endon("disconnect");
	self endon("bled_out");
	self endon("disconnect");
	self notify("w_olympia_dot_player");
	self endon("w_olympia_dot_player");

	if(!isdefined(self.last_fire_fx_olympia) || (self.last_fire_fx_olympia - gettime() > 3000))
	{
		self.last_fire_fx_olympia = gettime();
		self thread playFXTimedOnTag(level._effect["character_fire_death_torso"], "J_SpineLower", 3);
		self thread playFXTimedOnTag(level._effect["character_fire_death_torso"], "J_Spine1", 3);
	}

	if(isdefined(self.olympia_burn_time) && self.olympia_burn_time > 0)
	{
		if(self.olympia_burn_time > 1.5)
		{
			self.olympia_burn_damage += CLAMPED_ROUND_NUMBER * 20 / 4;
		}
		self.olympia_burn_time += (2.5 - self.olympia_burn_time);
		self.olympia_burn_damage += CLAMPED_ROUND_NUMBER * 20 / 6;
	}
	else
	{
		self.olympia_burn_time = 2.5;
		self.olympia_burn_damage = CLAMPED_ROUND_NUMBER * 20 / 8;
	}

	self.olympia_burn_damage = min(self.olympia_burn_damage, 2500);
	
	while(self.olympia_burn_time > 0 && isdefined(e_attacker) && isplayer(e_attacker))
	{
		wait 0.25;
		self DoDamage(int(self.olympia_burn_damage), self.origin + (0, 0, 50) + (randomFloatRange(-20, 20), randomFloatRange(-20, 20), randomFloatRange(-20, 20)), e_attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
		self.olympia_burn_time -= 0.25;
	}
	self.olympia_burn_time = undefined;
}