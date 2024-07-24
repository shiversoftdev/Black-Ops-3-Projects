aat_response(death, inflictor, attacker, damage, flags, mod, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex, surfacetype, name_override)
{
	if(!isplayer(attacker)) return false;
	if(!isdefined(weapon)) return false;
	if(isdefined(inflictor) && (inflictor.b_no_aat is true)) return false;
	if(mod != "MOD_PISTOL_BULLET" && mod != "MOD_RIFLE_BULLET" && mod != "MOD_GRENADE" && mod != "MOD_PROJECTILE" && mod != "MOD_PROJECTILE_SPLASH" && mod != "MOD_EXPLOSIVE" && mod != "MOD_IMPACT" && (!weapon.ismeleeweapon || mod != "MOD_MELEE") && mod != "MOD_GRENADE_SPLASH")
	{
		return false;
	}
	weapon = aat::get_nonalternate_weapon(weapon);
	if(isdefined(weapon.isdualwield) && weapon.isdualwield && isdefined(weapon.inventorytype) && weapon.inventorytype == "dwlefthand")
	{
		weapon = weapon.dualwieldweapon;
	}

	if(!isdefined(name_override))
	{
		if(!isdefined(attacker.aat) || !isarray(attacker.aat)) return false;
		name = attacker.aat[weapon];
	}
	else
	{
		name = name_override;
	}

	if(!isdefined(name_override) && (attacker has_elemental_pop()))
	{
		if(!isdefined(attacker.next_elemental_pop_roll) || (gettime() >= attacker.next_elemental_pop_roll))
		{
			keys = getarraykeys(level.aat);
			elemental_name = array::random(keys);
		}
	}

	if(!isdefined(name)) goto try_elemental_pop;
    if(!isdefined(level.aat[name])) goto try_elemental_pop;
	if(death && !level.aat[name].occurs_on_death) goto try_elemental_pop;
	if(!isdefined(self.archetype) && !isplayer(self)) goto try_elemental_pop;
	if(!isplayer(self) && isdefined(level.aat[name].immune_trigger[self.archetype]) && level.aat[name].immune_trigger[self.archetype]) goto try_elemental_pop;
	now = gettime() / 1000;
	if(isdefined(self.aat_cooldown_start) && isdefined(self.aat_cooldown_start[name]) && now <= (self.aat_cooldown_start[name] + level.aat[name].cooldown_time_entity))
	{
		goto try_elemental_pop;
	}
	if(isdefined(attacker.aat_cooldown_start) && isdefined(attacker.aat_cooldown_start[name]) && now <= (attacker.aat_cooldown_start[name] + level.aat[name].cooldown_time_attacker))
	{
		goto try_elemental_pop;
	}
	if(isdefined(level.aat[name].cooldown_time_global_start) && now <= level.aat[name].cooldown_time_global_start + level.aat[name].cooldown_time_global)
	{
		goto try_elemental_pop;
	}
	if(isdefined(level.aat[name].validation_func) && !(self [[level.aat[name].validation_func]]())) 
    {
try_elemental_pop:
		if(isdefined(elemental_name) && !isdefined(name_override))
		{
			return aat_response(death, inflictor, attacker, damage, flags, mod, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex, surfacetype, elemental_name);
		}
        return false;
    }
	success = 0;
	reroll_icon = undefined;
	percentage = level.aat[name].percentage;
	if(percentage >= randomfloat(1)) success = 1;
	if(weapon.ismeleeweapon && !weapon.isheroweapon)
	{
		success = 1;
	}
	if(weapon.isgrenadeweapon && name == "zm_aat_fire_works")
	{
		success = 1;
	}
	if(zm_utility::is_placeable_mine(weapon))
	{
		success = 1;
	}
	if(!success)
	{
		keys = getarraykeys(level.aat_reroll);
		keys = array::randomize(keys);
		foreach(key in keys)
		{
			if(attacker [[level.aat_reroll[key].active_func]]())
			{
				success = 1;
				reroll_icon = level.aat_reroll[key].damage_feedback_icon;
			}
			if(success) break;
		}
	}
	if(!success) goto try_elemental_pop;

	if(isdefined(name_override))
	{
		attacker.next_elemental_pop_roll = gettime() + 10000;
	}

	level.aat[name].cooldown_time_global_start = now;
	attacker.aat_cooldown_start[name] = now;
	level thread [[level.aat[name].result_func]](self, death, attacker, mod, weapon);
	attacker thread damagefeedback::update_override(level.aat[name].damage_feedback_icon, level.aat[name].damage_feedback_sound, reroll_icon);
	if(!isplayer(self))
	{
		damage3d(attacker, vpoint, damage, DAMAGE_TYPE_ZOMBIES);
	}
    return level.b_should_expect_aat_hitmarkers;
}

aat_deadwire(victim, death, attacker, mod, weapon)
{
	if(!isdefined(victim))
	{
		return;
	}
	if(attacker is undefined)
	{
		return;
	}

	victim endon("disconnect");
    attacker.tesla_enemies = undefined;
	attacker.tesla_enemies_hit = 1;
	attacker.tesla_powerup_dropped = 0;
	attacker.tesla_arc_count = 0;
    level.zm_aat_dead_wire_lightning_chain_params.weapon = weapon;
    if(!isplayer(victim) && !isdefined(level.zombie_vars["tesla_head_gib_chance"]))
    {
        zombie_utility::set_zombie_var("tesla_head_gib_chance", 50);
    }
	origin = victim.origin;
	eye = victim geteye();
    if(!isplayer(victim))
    {
        victim lightning_chain::arc_damage(victim, attacker, 1, level.zm_aat_dead_wire_lightning_chain_params);
        foreach(player in level.players)
        {
            if(player.sessionstate != "playing")
			{
				continue;
			}
            if(player == attacker)
			{
				continue;
			}
			if(player.team == attacker.team)
			{
				continue;
			}
            if(distance2d(player.origin, origin) < 300)
			{
				if(!BulletTracePassed(eye, player geteye(), false, player))
				{
					continue;
				}
				player arc_damage_ent(attacker, 1, level.zm_aat_dead_wire_lightning_chain_params);
			} 
        }
    }
    else
    {
        victim arc_damage_ent(attacker, 1, level.zm_aat_dead_wire_lightning_chain_params);
        foreach(zombie in GetAISpeciesArray(level.zombie_team, "all"))
        {
            if(!isdefined(zombie) || !isalive(zombie)) continue;
            if(distance2d(zombie.origin, origin) >= 300) continue;
            zombie lightning_chain::arc_damage(zombie, attacker, 1, level.zm_aat_dead_wire_lightning_chain_params);
        }
    }
}

aat_blast_furnace(victim, death, e_attacker, mod, w_weapon)
{
	if(victim is undefined)
	{
		return;
	}
	if(e_attacker is undefined)
	{
		return;
	}
    a_e_blasted_players = array::get_all_closest(victim.origin, getplayers(), undefined, undefined, 120);
	playsoundatposition("wpn_aat_blastfurnace_explo", victim.origin);
    foreach(player in a_e_blasted_players)
    {
        if(player == e_attacker) continue;
		if(player.team == e_attacker.team) continue;
        if(player.sessionstate != "playing") continue;
		if(!BulletTracePassed(victim geteye(), player geteye(), false, player)) continue;
        player thread blast_furnace_player_burn(e_attacker, w_weapon);
    }
    victim zm_aat_blast_furnace::result(death, e_attacker, mod, w_weapon);
}

blast_furnace_player_burn(e_attacker, w_weapon, damage_base = (level.f_aat_scalar * AAT_BLASTFURNACE_PVP_DAMAGE * e_attacker get_aat_damage_multiplier()))
{
	self endon("bled_out");
    self endon("disconnect");
	self endon("player_downed");
    level endon("game_ended");
	self clientfield::increment_to_player("zm_bgb_burned_out" + "_1p" + "toplayer");
	self clientfield::increment("zm_bgb_burned_out" + "_3p" + "_allplayers");

	n_ticks = 50;
	n_tick_delay = 0.1;
	n_burn_time = n_tick_delay * n_ticks;
	n_damage = damage_base * CLAMPED_ROUND_NUMBER / n_ticks;
	i = 0;
	self thread playFXTimedOnTag(level._effect["character_fire_death_torso"], "J_SpineLower", 3);
	self thread playFXTimedOnTag(level._effect["character_fire_death_torso"], "J_Spine1", 3);

	self thread set_player_burn(n_burn_time);
	while(i <= n_ticks)
	{
		self dodamage(int(n_damage), self.origin + (RandomFloatRange(-10, 10), RandomFloatRange(-10, 10), RandomInt(2) ? 0 : 80), e_attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
		if(self IsSprinting() || self IsSliding())
		{
			i += 5;
		}
		else
		{
			i++;
		}
		wait(n_tick_delay);
	}
	self notify("stop_burning");
}

thunderwall_result(victim, death, attacker, mod, weapon)
{
	if(!isdefined(victim))
	{
		return;
	}
	if(!isdefined(attacker))
	{
		return;
	}
    v_thunder_wall_blast_pos = victim.origin;
    v_attacker_facing_forward_dir = vectortoangles(v_thunder_wall_blast_pos - attacker.origin);
	v_attacker_facing = attacker getweaponforwarddir();
	v_attacker_orientation = attacker.angles;
    f_thunder_wall_range_sq = 32400;
	f_thunder_wall_effect_area_sq = 291600;
	end_pos = v_thunder_wall_blast_pos + vectorscale(v_attacker_facing, 180);
	a_e_players = array::get_all_closest(v_thunder_wall_blast_pos, getplayers(), undefined, undefined, 360);
    arrayremovevalue(a_e_players, attacker, false);
    foreach(player in a_e_players)
    {
        if(player.sessionstate != "playing") continue;
		if(player.team == attacker.team) continue;
		if(!BulletTracePassed(player geteye(), attacker geteye(), false, player))
		{
			continue;
		}
        player dodamage(int(level.f_aat_scalar * AAT_THUNDERWALL_PVP_DAMAGE * CLAMPED_ROUND_NUMBER * attacker get_aat_damage_multiplier()), player.origin, attacker, attacker, "none", "MOD_UNKNOWN", 0, level.weaponnone);
        n_random_x = randomfloatrange(-3, 3);
        n_random_y = randomfloatrange(-3, 3);
		scale_z = (player GetPlayerGravity() / 800);
		target_velocity = (750 * vectornormalize(player.origin - v_thunder_wall_blast_pos + (n_random_x, n_random_y, 15)));
		target_velocity = (target_velocity[0], target_velocity[1], scale_z * target_velocity[2]);
		final_velocity = player getVelocity() + target_velocity;
		victim.launch_magnitude_extra = 100;
    	victim.v_launch_direction_extra = vectorNormalize(final_velocity);
        player setOrigin(player getOrigin() + (0,0,1));
        player setVelocity(final_velocity);
    }
    victim zm_aat_thunder_wall::result(death, attacker, mod, weapon);
}

fw_validator()
{
    if(isplayer(self))
	{
		return true;
	}
	if(isdefined(self.barricade_enter) && self.barricade_enter)
	{
		return false;
	}
	if(isdefined(self.is_traversing) && self.is_traversing)
	{
		return false;
	}
	if(!(isdefined(self.completed_emerging_into_playable_area) && self.completed_emerging_into_playable_area) && !isdefined(self.first_node))
	{
		return false;
	}
	if(isdefined(self.is_leaping) && self.is_leaping)
	{
		return false;
	}
	return true;
}

zombie_death_gib(e_attacker, w_weapon, e_owner)
{
	self dodamage(self.health, self.origin, e_owner, w_weapon, "torso_upper");
	self zm_aat_fire_works::zombie_death_gib(e_attacker, w_weapon, e_owner);
}

turned_local_blast(attacker)
{
	self endon(#death);
	v_turned_blast_pos = self.origin;
	a_ai_zombies = array::get_all_closest(v_turned_blast_pos, getaiteamarray(level.zombie_team), undefined, undefined, 90);
	if(!isdefined(a_ai_zombies))
	{
		return;
	}
	f_turned_range_sq = 8100;
	n_flung_zombies = 0;
	for(i = 0; i < a_ai_zombies.size; i++)
	{
		if(!isdefined(a_ai_zombies[i]) || !isalive(a_ai_zombies[i]))
		{
			continue;
		}
		if(isdefined(level.aat["zm_aat_turned"].immune_result_indirect[a_ai_zombies[i].archetype]) && level.aat["zm_aat_turned"].immune_result_indirect[a_ai_zombies[i].archetype])
		{
			continue;
		}
		if(a_ai_zombies[i] == self)
		{
			continue;
		}
		v_curr_zombie_origin = a_ai_zombies[i] getcentroid();
		if(distancesquared(v_turned_blast_pos, v_curr_zombie_origin) > f_turned_range_sq)
		{
			continue;
		}
		a_ai_zombies[i] dodamage(a_ai_zombies[i].health, v_curr_zombie_origin, attacker, attacker, "none", "MOD_IMPACT");
		n_random_x = randomfloatrange(-3, 3);
		n_random_y = randomfloatrange(-3, 3);
		a_ai_zombies[i] startragdoll(1);
		a_ai_zombies[i] launchragdoll(60 * (vectornormalize((v_curr_zombie_origin - v_turned_blast_pos) + (n_random_x, n_random_y, 10))), "torso_lower");
		n_flung_zombies++;
		if(n_flung_zombies >= 7)
		{
			break;
		}
	}
	foreach(player in getplayers())
	{
		if(player.team == attacker.team)
		{
			continue;
		}
		if(player.sessionstate != "playing")
		{
			continue;
		}
		if(distancesquared(v_turned_blast_pos, player.origin) > f_turned_range_sq)
		{
			continue;
		}
		if(!BulletTracePassed(v_turned_blast_pos + (0, 0, 50), player.origin + (0, 0, 50), false, undefined))
		{
			continue;
		}
		player dodamage(int(AAT_TURNED_PVP_DAMAGE * CLAMPED_ROUND_NUMBER), player.origin, attacker, attacker, "none", "MOD_UNKNOWN");
	}
}

set_turned_team(team)
{
	if(team is defined)
	{
		self.turned_team = team;
		foreach(player in getplayers())
		{
			if(self == player)
			{
				continue;
			}
			if(player getgmteam() == team)
			{
				player SetInvisibleToPlayer(self, true);
			}
		}
	}
	else
	{
		team = self getgmteam();
		self.turned_team = undefined;
		foreach(player in getplayers())
		{
			if(self == player)
			{
				continue;
			}
			player SetInvisibleToPlayer(self, false);
		}
	}

    self.sessionteam = team;
	self._encounters_team = team;
	self.no_damage_points = false;
	self.switching_teams = 1;
	self.joining_team = team;
	self.leaving_team = self.team;
	self.team = team;
	self SetTeam(team);
	self.pers["team"] = team;
	self notify( "joined_team" );
	level notify( "joined_team" );
	self.switching_teams = 0;
}

#define TURNED_TIME = 10;
aat_turned_pvp(attacker)
{
	self endon(#disconnect);
	self.b_turned_team = true;
	self.turned_attacker = attacker;
	self clientfield::set("zm_aat_turned", 1);
	self set_turned_team(attacker.team);
	self playsound("zmb_zombie_spawn");
    playfx(level._effect["teleport_splash"], self.origin);
	self activate_effect(SE_TURNED, TURNED_TIME);
	self util::waittill_any_timeout(TURNED_TIME, "player_downed", "bled_out");
	self clientfield::set("zm_aat_turned", 0);
	self playsound("evt_disappear_3d");
    playfx(level._effect["teleport_splash"], self.origin);
	self set_turned_team();
	self.b_turned_team = undefined;
	self.turned_attacker = undefined;
}

turned_result(victim, death, attacker, mod, weapon)
{
	if(isplayer(victim))
	{
		victim thread aat_turned_pvp(attacker);
		return;
	}
	victim notify(#turned);
	victim thread clientfield::set("zm_aat_turned", 1);
	victim thread zm_aat_turned::zombie_death_time_limit(attacker);
	victim.team = attacker.team;
	victim.owner = attacker;
	victim.aat_turned = 1;
	victim.n_aat_turned_zombie_kills = 0;
	victim.maxhealth = int(1050 * pow(1.1, CLAMPED_ROUND_NUMBER + 5));
	victim.health = victim.maxhealth;
	// victim.allowdeath = 0;
	victim.allowpain = 0;
	victim.no_gib = 1;
	victim zombie_utility::set_zombie_run_cycle("super_sprint");
	if(math::cointoss())
	{
		if(victim.zombie_arms_position == "up")
		{
			victim.variant_type = 6;
		}
		else
		{
			victim.variant_type = 7;
		}
	}
	else
	{
		if(victim.zombie_arms_position == "up")
		{
			victim.variant_type = 7;
		}
		else
		{
			victim.variant_type = 8;
		}
	}
	victim thread turned_local_blast(attacker);
}

turned_validator()
{
    if(isplayer(self) && (self.b_turned_team is not true))
	{
		return true;
	}
	if(isdefined(level.aat["zm_aat_turned"].immune_result_direct[self.archetype]) && level.aat["zm_aat_turned"].immune_result_direct[self.archetype])
	{
		return false;
	}
	if(isdefined(self.barricade_enter) && self.barricade_enter)
	{
		return false;
	}
	if(isdefined(self.is_traversing) && self.is_traversing)
	{
		return false;
	}
	if(!(isdefined(self.completed_emerging_into_playable_area) && self.completed_emerging_into_playable_area))
	{
		return false;
	}
	if(isdefined(self.is_leaping) && self.is_leaping)
	{
		return false;
	}
	if(isdefined(level.zm_aat_turned_validation_override) && !self [[level.zm_aat_turned_validation_override]]())
	{
		return false;
	}
	return true;
}

fw_result(victim, death, e_player, mod, w_weapon)
{
	if(e_player is undefined)
	{
		return;
	}
	if(!isplayer(e_player))
	{
		return;
	}
	if(victim is undefined)
	{
		return;
	}
	e_player endon("disconnect");
    w_summoned_weapon = w_weapon ?? (player getcurrentweapon());
	v_target_zombie_origin = victim.origin;
	if(!isplayer(victim) && !(isdefined(level.aat["zm_aat_fire_works"].immune_result_direct[victim.archetype]) && level.aat["zm_aat_fire_works"].immune_result_direct[victim.archetype]))
	{
		victim thread zombie_death_gib(e_player, w_weapon, e_player);
	}
	v_firing_pos = v_target_zombie_origin + vectorscale((0, 0, 1), 56);
	v_start_yaw = vectortoangles(v_firing_pos - v_target_zombie_origin);
	v_start_yaw = (0, v_start_yaw[1], 0);
	mdl_weapon = zm_utility::spawn_weapon_model(w_summoned_weapon, undefined, v_target_zombie_origin, v_start_yaw);
	mdl_weapon.owner = e_player;
	mdl_weapon.b_aat_fire_works_weapon = 1;
	mdl_weapon.allow_zombie_to_target_ai = 1;
	mdl_weapon thread clientfield::set("zm_aat_fire_works", 1);
	mdl_weapon moveto(v_firing_pos, 0.5);
	mdl_weapon waittill("movedone");

	a_ai_zombies = getaiteamarray(level.zombie_team);
    a_players = getplayers();
	foreach(player in level.players)
	{
		if(!isdefined(player))
		{
			continue;
		}
		if(player.team == e_player.team)
		{
			arrayremovevalue(a_players, player, false);
			continue;
		}
		if(player.sessionstate != "playing")
		{
			arrayremovevalue(a_players, player, false);
			continue;
		}
	}
   //  a_ai_zombies = ArrayCombine(a_players, a_ai_zombies, 0, 0);
    a_ai_zombies = array::get_all_closest(v_target_zombie_origin, a_ai_zombies);

	is_mover_weapon = zm_utility::is_placeable_mine(w_weapon) || w_weapon.ismeleeweapon || w_weapon.isgrenadeweapon;

	a_attacked_players = [];
    
	n_shotatplayer = 0;
	n_max = 1024 * 1024;
	for(i = 0; i < 20; i++)
	{
		zombie = undefined;
        los_checks = 0;

		foreach(player in getplayers())
		{
			if(player.sessionstate != "playing" || e_player.team == player.team)
			{
				continue;
			}
			if(isdefined(a_attacked_players[player getxuid()]) && a_attacked_players[player getxuid()] > (is_mover_weapon ? 1 : 2))
			{
				continue;
			}
			if(DistanceSquared(player.origin + (0, 0, 50), mdl_weapon.origin) > n_max)
			{
				continue;
			}
			if(!(player damageconetrace(mdl_weapon.origin)))
			{
				continue;
			}
			if(!(e_player damageconetrace(player GetCentroid())))
			{
				continue;
			}
			if((isdefined(player.ignoreme) && player.ignoreme))
			{
				continue;
			}
			if(!isdefined(a_attacked_players[player getxuid()]))
			{
				a_attacked_players[player getxuid()] = 0;
			}
			
			a_attacked_players[player getxuid()] += 1;
			zombie = player;
			break;
		}

		if(!isdefined(zombie))
		{
			for(j = 0; j < a_ai_zombies.size; j++)
			{
				zombie_test = a_ai_zombies[j];
				if(!isdefined(zombie_test) || !isalive(zombie_test) || !isdefined(zombie_test.origin))
				{
					continue;
				}
				test_origin = isai(zombie_test) ? zombie_test getcentroid() : (zombie_test.origin + (0,0,50));
				if(distancesquared(mdl_weapon.origin, test_origin) > n_max) continue;
				if(los_checks < 3 && !(zombie_test damageconetrace(mdl_weapon.origin)))
				{
					los_checks++;
					continue;
				}
				zombie = zombie_test;
				break;
			}
		}
        

        if(!isdefined(zombie) && a_ai_zombies.size)
		{
			zombie = a_ai_zombies[0];
		}

        if(isdefined(zombie))
		{
			if(!isplayer(zombie))
			{
				arrayremovevalue(a_ai_zombies, zombie, false);
				if(distancesquared(mdl_weapon.origin, zombie getcentroid()) > n_max)
				{
					zombie = undefined;
				}
			}
		}
		if(!isdefined(zombie))
		{
			v_curr_yaw = (0, randomintrange(0, 360), 0);
			v_target_pos = mdl_weapon.origin + vectorscale(anglestoforward(v_curr_yaw), 40);
		}
		else
		{
			v_target_pos = isai(zombie) ? zombie getcentroid() : (zombie.origin + (0,0,50));
		}
		mdl_weapon.angles = vectortoangles(v_target_pos - mdl_weapon.origin);
		v_flash_pos = (mdl_weapon gettagorigin("tag_flash")) ?? (mdl_weapon.origin);
		if(is_mover_weapon)
		{
			mdl_weapon clientfield::set("powerup_fx", 4);
		}
		else
		{
			mdl_weapon dontinterpolate();
		}
		if(w_weapon.isprojectileweapon && (w_weapon.rootweapon.name != "launcher_multi") && (w_weapon.rootweapon.name != "launcher_multi_upgraded"))
		{
			if(isdefined(zombie) && isAlive(zombie)) // ugh this vm is a meme
			{
				e_player MagicMissile(w_weapon, v_flash_pos, vectorNormalize(mdl_weapon.angles) * 1000, zombie);
			}
			else
			{
				e_player MagicMissile(w_weapon, v_flash_pos, vectorNormalize(mdl_weapon.angles) * 1000);
			}

			util::wait_network_frame();
			i++;
		}
		else if(is_mover_weapon)
		{
			mdl_weapon moveto(v_target_pos, 0.1);
			mdl_weapon waittill("movedone");
			if(!isdefined(zombie) || !isalive(zombie) || (isPlayer(zombie) && zombie.sessionstate != "playing"))
			{
				continue;
			}

			if(w_weapon.ismeleeweapon || zm_utility::is_placeable_mine(w_weapon))
			{
				zombie dodamage(zombie.health + 666, v_target_pos, mdl_weapon, undefined, "none", "MOD_RIFLE_BULLET", 0, w_weapon);
			}
			else if(w_weapon.isgrenadeweapon)
			{
				nade = e_player magicgrenadetype(w_weapon, v_target_pos, (0, 0, 0), 0.05);
				nade.b_no_aat = true;
			}
			
			mdl_weapon playsound("zmb_ignite");
			wait 0.1;
		}
		else
		{
			magicbullet(w_summoned_weapon, v_flash_pos, v_target_pos, mdl_weapon);
			util::wait_network_frame();
		}
	}
	mdl_weapon moveto(v_target_zombie_origin, 0.5);
	mdl_weapon waittill("movedone");
	mdl_weapon clientfield::set("zm_aat_fire_works", 0);
	util::wait_network_frame();
	util::wait_network_frame();
	util::wait_network_frame();
	mdl_weapon delete();
	wait(0.25);
}