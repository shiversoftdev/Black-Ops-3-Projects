keeper_init()
{
    self thread keeper_init_threaded();
}

keeper_init_threaded()
{
    while(!isdefined(level.var_bfd9ed83) || !isdefined(level.ai_companion))
    {
        wait 1;
    }
    level.ai_companion.team = level.var_bfd9ed83.team;
    level.ai_companion setteam(level.var_bfd9ed83.team);
    wait 4;
    aiutility::addaioverridedamagecallback(level.ai_companion, serious::keepercompaniondamageoverride);
    level.ai_companion.team = level.var_bfd9ed83.team;
    level.ai_companion setteam(level.var_bfd9ed83.team);
    level.ai_companion.maxhealth = int(CLAMPED_ROUND_NUMBER * 250);
    level.ai_companion.health = int(CLAMPED_ROUND_NUMBER * 250);
    for(i = 0; i < 10; i++) // dont ask.
    {
        level.ai_companion setCanDamage(true);
        level.ai_companion solid();
        wait 1;
    }
}

keepercompaniondamageoverride(inflictor, attacker, damage, flags, meansofdeath, weapon, point, dir, hitloc, offsettime, boneindex, modelindex)
{
    if(isdefined(attacker) && isplayer(attacker) && attacker.team != self.team)
    {
        health = self.health - damage;
        damageStage = dragon_damage_feedback_get_stage(self);
        attacker.hud_damagefeedback.color = (1,1,1);
        attacker PlayHitMarker("mpl_hit_alert", damageStage, undefined, health <= 0);
        attacker thread damagefeedback::damage_feedback_growth(self, meansofdeath, weapon);
        if(health <= 0)
        {
            level.ai_companion.time_expired = 1;
            level.ai_companion.var_57376ff1 = 0;
            level.ai_companion.reviving_a_player = 0;
            level notify(#"hash_2d402338");
        }
        return damage;
    }
	return 0;
}

keeper_find_ents(entity, attack_origin, attack_bias)
{
	attack_type = blackboard::getblackboardattribute(self, "_keeper_protector_attack_type");
	attack_range = 500;
	if(attack_type == "combo")
	{
		attack_range = 250;
	}
	attack_range_sq = 700 * 700;
    possible_enemies = arraycombine(getaiteamarray(level.zombie_team), get_zbr_valid_players(), false, false);
	if(attack_bias == "attack_left" || attack_bias == "attack_right")
	{
		zombies = array::get_all_closest(attack_origin, possible_enemies, undefined, int(5), attack_range);
		attack_range_sq = attack_range * attack_range;
	}
	else
	{
		zombies = array::get_all_closest(attack_origin, possible_enemies, undefined, 15, 300);
		attack_range_sq = 300 * 300;
	}
	if(!isdefined(zombies))
	{
		return;
	}
	if(!zombies.size)
	{
		return;
	}
	fov = cos(70);
	if(attack_bias == "attack_left" || attack_bias == "attack_right")
	{
		fov = cos(60);
	}
	entity.var_13833827 = [];
	foreach(zombie in zombies)
	{
		if(!isdefined(zombie) || !isalive(zombie))
		{
			continue;
		}
        if(isplayer(zombie))
        {
            if(zombie.sessionstate != "playing")
            {
                continue;
            }
            if(zombie.team == entity.team)
            {
                continue;
            }
        }
		if(attack_bias != "attack_up")
		{
			tooclose = distancesquared(attack_origin, zombie.origin) <= 64 * 64;
			if(!tooclose && !util::within_fov(attack_origin, entity.angles, zombie.origin, fov))
			{
				continue;
			}
		}
		range_sq = distancesquared(attack_origin, isai(zombie) ? zombie getcentroid() : (zombie.origin + (0, 0, 50)));
		level.var_fb631584[level.var_fb631584.size] = zombie;
		n_scale = attack_range_sq - range_sq / attack_range_sq;
		if(attack_bias == "attack_up")
		{
			v_direction = vectornormalize(zombie.origin - entity.origin + vectorscale((0, 0, 1), 200));
		}
		else
		{
			v_direction = vectornormalize(zombie.origin - entity.origin);
		}
		v_direction = (v_direction[0], v_direction[1], abs(v_direction[2]));
		v_direction = vectorscale(v_direction, 75 + 75 * n_scale);
		level.var_90c9a476[level.var_90c9a476.size] = v_direction;
	}
}

detour namespace_6d577909<scripts\zm\archetype_genesis_keeper_companion.gsc>::function_87727b5b(entity)
{
	enemies = arraycombine(getaiteamarray(level.zombie_team), get_zbr_valid_players(), false, false);
	validenemies = [];
	foreach(enemy in enemies)
	{
		if(enemy.team != entity.team && (entity cansee(enemy) || distancesquared(entity.origin, enemy.origin) <= 350 * 350))
		{
			if(isdefined(enemy.archetype) && enemy.archetype == "zombie" && (!(isdefined(enemy.completed_emerging_into_playable_area) && enemy.completed_emerging_into_playable_area)))
			{
				continue;
			}
			if(enemy ishidden())
			{
				continue;
			}
			if(!isalive(enemy))
			{
				continue;
			}
			if(isdefined(enemy.isteleporting) && enemy.isteleporting)
			{
				continue;
			}
			if(isdefined(enemy.b_teleporting) && enemy.b_teleporting)
			{
				continue;
			}
			validenemies[validenemies.size] = enemy;
		}
	}
	return validenemies;
}

detour namespace_6d577909<scripts\zm\archetype_genesis_keeper_companion.gsc>::function_68cd1247(entity, attack_type)
{
	attack_origin = entity gettagorigin("tag_weapon_right");
	entity thread exec_pending_keeper_attacks(entity, attack_origin, attack_type);
	if(attack_type == "attack_up")
	{
		entity.var_2c553c41 clientfield::increment("keeper_thunderwall_360");
		entity.var_733ed347 = randomintrange(1200, 2100);
		entity.var_733ed347 = gettime() + entity.var_733ed347;
	}
	else
	{
		entity clientfield::increment("keeper_thunderwall");
		entity.var_3e807a19 = randomintrange(1200, 2100);
		entity.var_3e807a19 = gettime() + entity.var_3e807a19;
	}
}

detour namespace_6d577909<scripts\zm\archetype_genesis_keeper_companion.gsc>::keepercompanionmovementservice(entity)
{
    if(isdefined(level.var_bfd9ed83) && (isdefined(level.var_bfd9ed83.eligible_leader) && level.var_bfd9ed83.eligible_leader))
	{
		entity.leader = level.var_bfd9ed83;
	}
	if(isdefined(entity.outro) && entity.outro)
	{
		return;
	}
	if(isdefined(entity.var_2fd11bbd) && entity.var_2fd11bbd == 1)
	{
		return;
	}
	if(!isdefined(entity.var_57e708f6))
	{
		entity.var_57e708f6 = 0;
	}
	if(isdefined(entity.reviving_a_player) && entity.reviving_a_player == 1)
	{
		return;
	}
	if(isdefined(entity.var_53ce2a4e) && entity.var_53ce2a4e == 1 || isdefined(entity.b_teleporting) && entity.b_teleporting == 1)
	{
		return;
	}
	if(isdefined(entity.var_c0e8df41) && entity.var_c0e8df41 == 1)
	{
		return;
	}
	if(isdefined(entity.var_f1e0aeaf) && entity.var_f1e0aeaf == 1)
	{
		return;
	}
	if(isdefined(entity.leader))
	{
		if(isdefined(entity.leader.b_teleporting) && entity.leader.b_teleporting == 1)
		{
            if(!isdefined(level.fn_34117adf))
            {
                level.fn_34117adf = @namespace_6d577909<scripts\zm\archetype_genesis_keeper_companion.gsc>::function_34117adf;
            }
			entity thread [[ level.fn_34117adf ]](entity.leader.teleport_location);
			return;
		}
		if(isdefined(entity.leader.var_122a2dda) && entity.leader.var_122a2dda == 1)
		{
			if(isdefined(entity.leader.var_fa1ecd39))
			{
                if(!isdefined(level.fn_3463b8c2))
                {
                    level.fn_3463b8c2 = @namespace_6d577909<scripts\zm\archetype_genesis_keeper_companion.gsc>::function_3463b8c2;
                }
				entity thread [[ level.fn_3463b8c2 ]](entity.leader.var_fa1ecd39);
			}
			return;
		}
		if(distancesquared(entity.leader.origin, entity.origin) > 490000)
		{
			if(!isdefined(entity.var_539a912c) || gettime() > entity.var_539a912c)
			{
                if(!isdefined(level.fn_469c9511))
                {
                    level.fn_469c9511 = @namespace_6d577909<scripts\zm\archetype_genesis_keeper_companion.gsc>::function_469c9511;
                }
				entity thread [[ level.fn_469c9511 ]](entity);
			}
		}
	}
	if(!isdefined(entity.var_a0c5deb2))
	{
		entity.var_a0c5deb2 = gettime();
	}
	if(gettime() >= entity.var_a0c5deb2 && isdefined(level.active_powerups) && level.active_powerups.size > 0)
	{
		if(!isdefined(entity.var_34a9f1ad))
		{
			entity.var_34a9f1ad = 0;
		}
		foreach(powerup in level.active_powerups)
		{
			if(array::contains(entity.var_fb400bf7, powerup.powerup_name))
			{
				dist = distancesquared(entity.origin, powerup.origin);
				if(dist <= 147456 && randomint(100) < 50 + 10 * entity.var_34a9f1ad)
				{
					entity setgoal(powerup.origin, 1);
					entity.var_a0c5deb2 = gettime() + randomintrange(2500, 3500);
					entity.next_move_time = gettime() + randomintrange(2500, 3500);
					entity.var_34a9f1ad = 0;
					return;
				}
				entity.var_34a9f1ad = entity.var_34a9f1ad + 1;
			}
		}
		entity.var_a0c5deb2 = gettime() + randomintrange(333, 666);
	}
	follow_radius_squared = 256 * 256;
	if(isdefined(entity.leader))
	{
		entity.companion_anchor_point = entity.leader.origin;
	}
	dist_check_start_point = entity.origin;
	if(isdefined(entity.pathgoalpos))
	{
		dist_check_start_point = entity.pathgoalpos;
	}
    if(!isdefined(level.fn_pick_new_movement_point))
    {
        level.fn_pick_new_movement_point = @namespace_6d577909<scripts\zm\archetype_genesis_keeper_companion.gsc>::pick_new_movement_point;
    }
	if(distancesquared(dist_check_start_point, entity.companion_anchor_point) > follow_radius_squared)
	{
		if(isdefined(entity.leader) && entity.companion_anchor_point == entity.leader.origin)
		{
			enemies = arraycombine(getaiteamarray(level.zombie_team), get_zbr_valid_players(), false, false);
			validenemies = [];
			foreach(enemy in enemies)
			{
				if(((isdefined(enemy.completed_emerging_into_playable_area) && enemy.completed_emerging_into_playable_area) || isplayer(enemy)) && entity cansee(entity.leader, 3000) && util::within_fov(entity.leader.origin, entity.leader.angles, enemy.origin, cos(70)))
				{
					validenemies[validenemies.size] = enemy;
				}
			}
			if(isdefined(validenemies) && validenemies.size)
			{
				averagepoint = get_average_origin(validenemies, entity.leader.origin[2]);
				var_be4a51b9 = vectornormalize(averagepoint - entity.leader.origin);
				point = entity.leader.origin + vectorscale(var_be4a51b9, 179.2);
				entity.companion_anchor_point = point + vectorscale(anglestoright(entity.leader.angles), 30);
			}
		}
		entity [[ level.fn_pick_new_movement_point ]]();
	}
	if(gettime() >= entity.next_move_time && (!(isdefined(entity.var_92aa697) && entity.var_92aa697)))
	{
		entity [[ level.fn_pick_new_movement_point ]]();
	}
}

get_average_origin(entities, var_d4653ed3)
{
	var_8a6850c7 = 0;
	var_6465d65e = 0;
	for(i = 0; i < entities.size; i++)
	{
		var_8a6850c7 = var_8a6850c7 + entities[i].origin[0];
		var_6465d65e = var_6465d65e + entities[i].origin[1];
	}
	return (var_8a6850c7 / entities.size, var_6465d65e / entities.size, var_d4653ed3);
}

exec_pending_keeper_attacks(entity, attack_origin, attack_type)
{
	if(!isdefined(level.var_fb631584))
	{
		level.var_fb631584 = [];
		level.var_90c9a476 = [];
	}
	entity keeper_find_ents(entity, attack_origin, attack_type);
	for(i = 0; i < level.var_fb631584.size; i++)
	{
		ai = level.var_fb631584[i];
		ai thread keeper_damage_ent(entity, ai, attack_origin, level.var_90c9a476[i], attack_type);
		wait 0.05;
	}
	level.var_fb631584 = [];
	level.var_90c9a476 = [];
}

keeper_damage_ent(entity, ai, attack_origin, attack_direction, attack_type)
{
	if(!isdefined(ai) || !isalive(ai))
	{
		return;
	}
    if(isplayer(ai))
    {
        if(ai.sessionstate != "playing")
        {
            return;
        }
        if(ai.team == entity.team)
        {
            return;
        }
        if(!entity cansee(ai))
        {
            return;
        }
        if(attack_type == "attack_up")
        {
            ai dodamage(int(CLAMPED_ROUND_NUMBER * DMG_KEEPER_ATK_UP), attack_origin, level.var_bfd9ed83, entity, "none", "MOD_UNKNOWN", 0, level.weaponnone);
        }
        else
        {
            ai dodamage(int(CLAMPED_ROUND_NUMBER * DMG_KEEPER_ATK_ELSE), attack_origin, level.var_bfd9ed83, entity, "none", "MOD_UNKNOWN", 0, level.weaponnone);
        }
        ai playsound("zmb_elec_jib_zombie");
        ai thread playFXTimedOnTag(level._effect["tesla_shock"], "j_head", 2);
        ai SetElectrified(2);
        ai.launch_magnitude_extra = 100;
        ai.v_launch_direction_extra = vectornormalize(attack_direction);
        return;
    }
    if(!isdefined(level.fn_84e1787e))
    {
        level.fn_84e1787e = @namespace_6d577909<scripts\zm\archetype_genesis_keeper_companion.gsc>::function_84e1787e;
    }
	if(ai.archetype == "margwa")
	{
		if([[ level.fn_84e1787e ]](entity, ai))
		{
			if(isdefined(ai.thundergun_fling_func))
			{
				ai thread [[ai.thundergun_fling_func]](entity);
			}
		}
		else
		{
			if(isdefined(ai.canstun) && ai.canstun && gettime() >= ai.var_78f8bb8.var_54c7425)
			{
				ai.reactstun = 1;
				ai.var_78f8bb8.var_54c7425 = gettime() + randomintrange(3000, 5000);
			}
		}
	}
	else if(ai.archetype == "mechz")
	{
		if([[ level.fn_84e1787e ]](entity, ai))
		{
			if(isdefined(ai.thundergun_fling_func))
			{
				ai thread [[ai.thundergun_fling_func]](entity);
			}
		}
		else
		{
			if(isdefined(ai.canstun) && ai.canstun && gettime() >= ai.var_78f8bb8.var_54c7425)
			{
				ai.reactstun = 1;
				ai.var_78f8bb8.var_54c7425 = gettime() + randomintrange(3000, 5000);
			}
		}
	}
	else if(attack_type == "attack_up")
	{
		ai dodamage(20000, attack_origin, entity);
	}
	else
	{
		ai dodamage(17000, attack_origin, entity);
	}
	if(!isalive(ai))
	{
		ai clientfield::set("keeper_ai_death_effect", 1);
		level notify(#"hash_1fe79fb5", ai);
		if(isdefined(entity.leader.var_71148446) && array::contains(entity?.leader?.var_71148446, self.archetype))
		{
			arrayremovevalue(entity.leader.var_71148446, ai.archetype);
			entity.leader notify(#"hash_af442f7c");
		}
		foreach(player in level.players)
		{
			if(player laststand::player_is_in_laststand())
			{
				player notify(#"hash_935cc366");
			}
		}
		if(isdefined(ai.archetype) && ai.archetype == "zombie")
		{
			if(randomint(100) < 30)
			{
				ai zombie_utility::gib_random_parts();
			}
			ai startragdoll();
			ai launchragdoll(attack_direction);
		}
	}
}