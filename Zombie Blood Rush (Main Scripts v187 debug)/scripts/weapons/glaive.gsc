AdjustPlayerSword(player, type, noprint=false)
{
    if(!isdefined(level.var_15954023.weapons)) level.var_15954023.weapons = [];
    if(!isDefined(level.var_15954023.weapons[player.originalindex])) return;
    
    weapon = level.var_15954023.weapons[player.originalindex][1];
    switch(type)
    {
        case "Normal":
             weapon = level.var_15954023.weapons[player.originalindex][1];
        break;

        case "Upgraded":
            weapon = level.var_15954023.weapons[player.originalindex][2];
        break;

        default:
            player takeWeapon(level.var_15954023.weapons[player.originalindex][1]);
            player takeWeapon(level.var_15954023.weapons[player.originalindex][2]);
            return;
    }

    player.sword_power = 1;
    player notify(#"hash_b29853d8");
    if(isdefined(player.var_c0d25105))
    {
        player.var_c0d25105 notify("returned_to_owner");
    }
    player.var_86a785ad = 1;
    player notify(#"hash_b29853d8");
    player zm_weapons::weapon_give(weapon, 0, 0, 1);
    player GadgetPowerSet(0, 100);
    player.current_sword = player.current_hero_weapon;
}

glaive_pvp_monitor()
{
	if(!isdefined(level.glaive_excalibur_aoe_range)) return;
    self endon("bled_out");
    self endon("spawned_player");
    self endon("disconnect");
    self.wpn_excalibur = self get_correct_sword_for_player_character_at_level(1);
	self.wpn_autokill = self get_correct_sword_for_player_character_at_level(2);
    for(;;)
	{
		self waittill("weapon_change", wpn_cur, wpn_prev);
        if(wpn_cur == self.wpn_excalibur || wpn_cur == self.wpn_autokill)
        {
            self thread watch_pvp_sword_swipe(wpn_cur, wpn_cur == self.wpn_autokill);
            if(wpn_cur != self.wpn_autokill)
                self thread watch_pvp_sword_slam(wpn_cur, wpn_cur == self.wpn_autokill);
        }
	}
}

get_correct_sword_for_player_character_at_level(n_upgrade_level)
{
	str_wpnname = undefined;
	if(n_upgrade_level == 1)
	{
		str_wpnname = "glaive_apothicon";
	}
	else
	{
		str_wpnname = "glaive_keeper";
	}
	str_wpnname = str_wpnname + "_" + self.characterindex;
	wpn = getweapon(str_wpnname);
	return wpn;
}

watch_pvp_sword_swipe(sword, upgraded = false)
{
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");
    self endon("weapon_change");
    self notify("watch_pvp_sword_swipe");
    self endon("watch_pvp_sword_swipe");
	level endon("game_ended");
    for(;;)
    {
        self util::waittill_any("weapon_melee_power", "weapon_melee");
		sword thread swordarc_swipe_pvp(self, upgraded);
    }
}

watch_pvp_sword_slam(sword, upgraded = false)
{
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");
    self endon("weapon_change");
    self notify("watch_pvp_sword_slam");
    self endon("watch_pvp_sword_slam");
	level endon("game_ended");
    for(;;)
    {
        self waittill("weapon_melee_power_left", weapon);
		if(!upgraded) self thread do_excalibur_pvp(weapon);
    }
}

swordarc_swipe_pvp(player, upgraded)
{
	player thread chop_players(1, upgraded, 1, self);
	wait(0.3);
	player thread chop_players(0, upgraded, 1, self);
	wait(0.5);
	player thread chop_players(0, upgraded, 0, self);
}

chop_players(first_time, upgraded, leftswing, weapon = level.weaponnone)
{
	view_pos = self getweaponmuzzlepoint();
	forward_view_angles = self getweaponforwarddir();
	foreach(player in level.players)
	{
		if(player.sessionstate != "playing") continue;
		test_origin = player.origin + (0,0,50);
		dist_sq = distancesquared(view_pos, test_origin);
		dist_to_check = level.glaive_chop_cone_range_sq;
		if(upgraded) dist_to_check = level.var_42894cb8;
		if(dist_sq > dist_to_check) continue;
		normal = vectornormalize(test_origin - view_pos);
		dot = vectordot(forward_view_angles, normal);
		if(dot <= 0) continue;
		if(0 == player damageconetrace(view_pos, self)) continue;
		player.chopped = 1;
		self thread chop_player(player, upgraded, leftswing, weapon);
	}
}

chop_player(player, upgraded, leftswing, weapon = level.weaponnone)
{
	self endon("disconnect");
	if(player.sessionstate != "playing") return;
	if(isdefined(upgraded) && upgraded)
	{
		player dodamage(int(1200 * CLAMPED_ROUND_NUMBER), self.origin, self, self, "none", "MOD_UNKNOWN", 0, weapon);
	}
	player dodamage(int(1200 * CLAMPED_ROUND_NUMBER), self.origin, self, self, "none", "MOD_UNKNOWN", 0, weapon);
	util::wait_network_frame();
}

do_excalibur_pvp(wpn_excalibur)
{
	view_pos = self getweaponmuzzlepoint();
	forward_view_angles = self getweaponforwarddir();
    foreach(player in level.players) lc_flag_hit(player, 0);
	foreach(player in level.players)
	{
		if(player.sessionstate != "playing") continue;
		test_origin = player.origin + (0,0,50);
		dist_sq = distancesquared(view_pos, test_origin);
		if(dist_sq < level.glaive_excalibur_aoe_range_sq)
		{
			self thread electrocute_player(player, wpn_excalibur);
			continue;
		}
		if(dist_sq > level.glaive_excalibur_cone_range_sq) continue;
		normal = vectornormalize(test_origin - view_pos);
		dot = vectordot(forward_view_angles, normal);
		if(0.707 > dot) continue;
		if(!(player damageconetrace(view_pos, self))) continue;
		self thread electrocute_player(player, wpn_excalibur);
	}
}

electrocute_player(player, wpn_excalibur)
{
	self endon("disconnect");
    player endon("disconnect");
	if(player.sessionstate != "playing") return;
	if(!isdefined(self.tesla_enemies_hit)) self.tesla_enemies_hit = 1;
	player notify("bhtn_action_notify", "electrocute");
	player.tesla_death = 0;
    create_default_lp();
	player thread arc_lightning(player.origin, player.origin, self);
}

create_default_lp()
{
	if(isdefined(level.var_ba84a05b)) return;
    level.var_ba84a05b = create_lightning_chain_params(1);
	level.var_ba84a05b.head_gib_chance = 100;
	level.var_ba84a05b.network_death_choke = 4;
	level.var_ba84a05b.should_kill_enemies = 0;
}

arc_lightning(hit_location, hit_origin, player)
{
	player endon("disconnect");
	if(isdefined(self.zombie_tesla_hit) && self.zombie_tesla_hit) return;
	self arc_damage_ent(player, 1, level.var_ba84a05b);
}

create_lightning_chain_params(max_arcs = 5, max_enemies_killed = 10, radius_start = 300, radius_decay = 20, head_gib_chance = 75, arc_travel_time = 0.11, kills_for_powerup = 10, min_fx_distance = 128, network_death_choke = 4, should_kill_enemies = 1, clientside_fx = 1, arc_fx_sound = undefined, no_fx = 0, prevent_weapon_kill_credit = 0)
{
	lcp = spawnstruct();
	lcp.max_arcs = max_arcs;
	lcp.max_enemies_killed = max_enemies_killed;
	lcp.radius_start = radius_start;
	lcp.radius_decay = radius_decay;
	lcp.head_gib_chance = head_gib_chance;
	lcp.arc_travel_time = arc_travel_time;
	lcp.kills_for_powerup = kills_for_powerup;
	lcp.min_fx_distance = min_fx_distance;
	lcp.network_death_choke = network_death_choke;
	lcp.should_kill_enemies = should_kill_enemies;
	lcp.clientside_fx = clientside_fx;
	lcp.arc_fx_sound = arc_fx_sound;
	lcp.no_fx = no_fx;
	lcp.prevent_weapon_kill_credit = prevent_weapon_kill_credit;
	return lcp;
}

arc_damage_ent(player, arc_num, params = level.default_lightning_chain_params)
{
	lc_flag_hit(self, 1);
	self thread lc_do_damage(self, arc_num, player, params);
}

lc_flag_hit(enemy, hit)
{
	if(isdefined(enemy))
	{
		if(isarray(enemy))
		{
			for(i = 0; i < enemy.size; i++)
			{
				if(isdefined(enemy[i]))
				{
					enemy[i].zombie_tesla_hit = hit;
				}
			}
		}
		else if(isdefined(enemy))
		{
			enemy.zombie_tesla_hit = hit;
		}
	}
}

lc_do_damage(source_enemy, arc_num, player, params)
{
	player endon("disconnect");
	player endon("bled_out");
	self endon("bled_out");
    self endon("disconnect");
	if(arc_num > 1) wait(randomfloatrange(0.2, 0.6) * arc_num);
	if(self.sessionstate != "playing") return;
	if(params.clientside_fx)
	{
		if(arc_num > 1) clientfield::set("lc_fx", 2);
		else clientfield::set("lc_fx", 1);
	}
	if(isdefined(source_enemy) && source_enemy != self)
	{
		if(player.tesla_arc_count > 3)
		{
			util::wait_network_frame();
			player.tesla_arc_count = 0;
		}
		player.tesla_arc_count++;
		if(params != level.zm_aat_dead_wire_lightning_chain_params)
			source_enemy lc_play_arc_fx(self, params);
	}
	if(self.sessionstate != "playing") return;
	if(params != level.zm_aat_dead_wire_lightning_chain_params)
	{
		self lc_play_death_fx(arc_num, params);
	}
	else
	{
		self electric_cherry_shock_fx();
		self thread electric_cherry_stun();
	}
	//self.tesla_death = params.should_kill_enemies;
	origin = player.origin;
	if(isdefined(source_enemy) && source_enemy != self) origin = source_enemy.origin;
	if(self.sessionstate != "playing") return;
	weapon = level.weaponnone;
	if(params != level.zm_aat_dead_wire_lightning_chain_params)
    	self dodamage(int(ZM_ZOD_SWORD_SHOCK_DMG * CLAMPED_ROUND_NUMBER), origin, player, undefined, "none", "MOD_UNKNOWN", 0, weapon);
	else
		self dodamage(int(level.f_aat_scalar * AAT_DEADWIRE_PVP_DAMAGE * CLAMPED_ROUND_NUMBER * player get_aat_damage_multiplier()), origin, player, undefined, "none", "MOD_UNKNOWN", 0, weapon);
}

lc_play_arc_fx(target, params)
{
	if(!isdefined(self) || !isdefined(target))
	{
		wait(params.arc_travel_time);
		return;
	}
	tag = "tag_origin";
	target_tag = "J_SpineUpper";
	origin = self gettagorigin(tag);
	target_origin = target gettagorigin(target_tag);
	distance_squared = params.min_fx_distance * params.min_fx_distance;
	if(distancesquared(origin, target_origin) < distance_squared) return;
	fxorg = util::spawn_model("tag_origin", origin);
	fx = playfxontag(level._effect["tesla_bolt"], fxorg, "tag_origin");
	if(isdefined(params.arc_fx_sound)) playsoundatposition(params.arc_fx_sound, fxorg.origin);
	fxorg moveto(target_origin, params.arc_travel_time);
	fxorg waittill("movedone");
	fxorg delete();
	if(isdefined(fx))
	{
		fx delete();
	}
}

lc_play_death_fx(arc_num, params)
{
	tag = "J_SpineUpper";
	fx = "tesla_shock";
	n_fx = 1;
	if(isdefined(self.teslafxtag))
	{
		tag = self.teslafxtag;
	}
	else tag = "tag_origin";
	if(arc_num > 1)
	{
		fx = "tesla_shock_secondary";
		n_fx = 2;
	}
	if(!params.should_kill_enemies)
	{
		fx = "tesla_shock_nonfatal";
		n_fx = 3;
	}
    self thread playFXTimedOnTag(level._effect[fx], tag, 3);
}

glaive_init()
{
	level.zbr_glaives = [];
    level.old_glaive_cb = level.vehicle_main_callback["glaive"];
    level.vehicle_main_callback["glaive"] = serious::glaive_main;
}

glaive_main()
{
	if(isdefined(level.old_glaive_cb))
    {
        self [[ level.old_glaive_cb ]]();
    }
	level.zbr_glaives ??= [];
	array::add(level.zbr_glaives, self, false);
    level thread cleanup_dead_glaive(self);
    self.overridevehicledamage = serious::glaive_callback_damage;
    self.maxhealth = SOE_SWORD_HEALTH;
    self.health = SOE_SWORD_HEALTH;
    self setCanDamage(true);
    self notsolid();
    self.dmg_trigger = spawn("script_model", self.origin);
	self.dmg_trigger setmodel("defaultactor");

	self.dmg_trigger.maxhealth = SOE_SWORD_HEALTH;
	self.dmg_trigger.health = SOE_SWORD_HEALTH;
	self.dmg_trigger setCanDamage(true);
	self.dmg_trigger solid();
	self.dmg_trigger ghost();
    self.dmg_trigger thread fakelinkto(self, (0,0,-20));
    self.dmg_trigger thread kill_dragon_trig_on_death(self);
    self.dmg_trigger thread watch_glaive_damage(self);

	self.state_machines[self.current_role].states["slash"].update_func = serious::glaive_state_slash_update;
}

watch_glaive_damage(glaive)
{
    glaive endon("death");
	glaive endon("returned_to_owner");
    self endon("death");

	self.glaive = glaive;
    
	self.fake_health = SOE_SWORD_HEALTH;
    while(isdefined(self) && isdefined(self.glaive))
    {
        self waittill("damage", damagetaken, attacker, dir, point, dmg_type, model, tag, part, weapon, flags);
		if(!isdefined(attacker) || !isplayer(attacker)) continue;
        if(self.glaive == attacker) continue;
		if(self.glaive.owner == attacker) continue;
		if(isdefined(attacker.team) && attacker.team == self.glaive.owner.team) continue;
		if(isdefined(weapon) && (weapon == level.zbr_emp_grenade_zm))
		{
			damagetaken = 999999;
		}
		
		damageStage = 1;
		attacker PlayHitMarker("mpl_hit_alert", damageStage, undefined, false);
		attacker thread damagefeedback::damage_feedback_growth(self, dmg_type, weapon);
		damage3d(attacker, point, damagetaken, DAMAGE_TYPE_ZOMBIES);
		
        self.health += damagetaken;
        self.attacker = attacker;
        self.glaive dodamage(damagetaken, self.origin, attacker, attacker, "none", dmg_type, flags, weapon);
		self.fake_health -= damagetaken;
		if(self.fake_health < 1)
		{
			self.glaive._glaive_must_return_to_owner = 1;
			self.glaive notify("returned_to_owner");
		}
    }
}

cleanup_dead_glaive(glaive)
{
    level endon("end_game");
    glaive waittill("death");
    if(isdefined(glaive))
    {
        arrayremovevalue(level.zbr_glaives, glaive, 0);
    }
    else
    {
		if(level.zbr_glaives ?& isarray(level.zbr_glaives))
		{
			level.zbr_glaives = array::remove_undefined(level.zbr_glaives, false);
		}
    }
}

glaive_callback_damage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, vdamageorigin, psoffsettime, damagefromunderneath, modelindex, partname, vsurfacenormal)
{
    if(isdefined(eattacker) && isplayer(eattacker) && eattacker.team != self.owner.team)
    {
        damageStage = dragon_damage_feedback_get_stage(self);
        eattacker.hud_damagefeedback.color = (1,1,1);
        eattacker PlayHitMarker("mpl_hit_alert", damageStage, undefined, damagefeedback::damage_feedback_get_dead(self, smeansofdeath, weapon, damageStage));
        eattacker thread damagefeedback::damage_feedback_growth(self, smeansofdeath, weapon);
        return 0;
    }
	return 0;
}

_get_glaive_enemy()
{
	if(!isdefined(self.owner))
	{
		return undefined;
	}

	if(!isdefined(level.glaive_is_enemy_valid))
	{
		level.glaive_is_enemy_valid = @glaive<scripts\shared\vehicles\_glaive.gsc>::is_enemy_valid;
	}

	glaive_enemies = getaiteamarray(level.zombie_team);
	foreach(player in getplayers())
	{
		if(isdefined(self.owner) && isdefined(player.team) && self.owner.team == player.team)
		{
			continue;
		}
		if(!isdefined(player.sessionstate) || player.sessionstate != "playing")
		{
			continue;
		}
		if(isdefined(player._glaive_ignoreme) && player._glaive_ignoreme)
		{
			continue;
		}
		array::add(glaive_enemies, player, false);
	}
	
	arraysortclosest(glaive_enemies, self.owner.origin);

	foreach(glaive_enemy in glaive_enemies)
	{
		if(isPlayer(glaive_enemy))
		{
			return glaive_enemy; // we just checked for them being valid and dont need to worry about the zombie version of the check
		}

		if([[ level.glaive_is_enemy_valid ]](glaive_enemy))
		{
			return glaive_enemy;
		}
	}

	return undefined;
}

detour glaive<scripts\shared\vehicles\_glaive.gsc>::get_glaive_enemy()
{
	return _get_glaive_enemy();
}

glaive_state_slash_update(params)
{
	self endon("change_state");
	self endon("death");

	dist_squared = 128 * 128;
	enemy = self.glaiveenemy;
	should_reevaluate_target = 0;
	sword_anim = self glaive_chooseswordanim(enemy);
	self animscripted("anim_notify", enemy gettagorigin(self._glaive_linktotag), enemy gettagangles(self._glaive_linktotag), sword_anim, "normal", undefined, undefined, 0.3, 0.3);
	self clientfield::set("glaive_blood_fx", 1);
	self waittill("anim_notify");

	if(isalive(enemy) && isdefined(enemy.archetype) && enemy.archetype == "margwa")
	{
		if(isdefined(enemy.chop_actor_cb))
		{
			should_reevaluate_target = 1;
			enemy thread glaive_ignore_cooldown(5);
			self.owner [[enemy.chop_actor_cb]](enemy, self, self.weapon);
		}
	}
	else if(isplayer(enemy) && enemy.sessionstate == "playing")
	{
		should_reevaluate_target = 1;
		enemy thread glaive_ignore_cooldown_2(1);
		enemy dodamage(int(CLAMPED_ROUND_NUMBER * GLAIVE_SEEKER_DAMAGE), self.origin, self, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
	}
	else
	{
		target_enemies = getaiteamarray(level.zombie_team);
		foreach(target in target_enemies)
		{
			if(distance2dsquared(self.origin, target.origin) < dist_squared)
			{
				if(isdefined(target.archetype) && target.archetype == "margwa")
				{
					continue;
				}
				target dodamage(target.health + 100, self.origin, self.owner, self, "none", "MOD_UNKNOWN", 0, self.weapon);
				self playsound("wpn_sword2_imp");
				if(isactor(target))
				{
					target zombie_utility::gib_random_parts();
					target startragdoll();
					target launchragdoll(100 * (vectornormalize(target.origin - self.origin)));
				}
			}
		}
	}

	self waittill("anim_notify", notetrack);
	while(!isdefined(notetrack) || notetrack != "end")
	{
		self waittill("anim_notify", notetrack);
	}

	self clientfield::set("glaive_blood_fx", 0);
	if(should_reevaluate_target)
	{
		target = _get_glaive_enemy();
		self.glaiveenemy = target;
	}

	self vehicle_ai::set_state("combat");
}

glaive_chooseswordanim(enemy)
{
	self endon("change_state");
	self endon("death");
	sword_anim = "o_zombie_zod_sword_projectile_melee_synced_a";
	self._glaive_linktotag = "tag_origin";
	if(isdefined(enemy.archetype))
	{
		switch(enemy.archetype)
		{
			case "parasite":
			{
				sword_anim = "o_zombie_zod_sword_projectile_melee_parasite_synced_a";
				break;
			}
			case "raps":
			{
				sword_anim = "o_zombie_zod_sword_projectile_melee_elemental_synced_a";
				break;
			}
			case "margwa":
			{
				sword_anim = "o_zombie_zod_sword_projectile_melee_margwa_m_synced_a";
				self._glaive_linktotag = "tag_sync";
				break;
			}
		}
	}
	return sword_anim;
}

glaive_ignore_cooldown(duration)
{
	self endon("death");
	self._glaive_ignoreme = 1;
	wait(duration);
	self._glaive_ignoreme = undefined;
}

glaive_ignore_cooldown_2(duration)
{
	self endon("bled_out");
	self._glaive_ignoreme = 1;
	wait(duration);
	self._glaive_ignoreme = undefined;
}