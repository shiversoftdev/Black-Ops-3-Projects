/*
Air Superiority - Planes will periodically enter the battlefield, targeting players, zombies, and bombing points of interest.
Robo-recall - The robots move sporatically. Panzer soldats spawn more often and behave strangely.
*/

#define ZBR_TOURNAMENT_SETTING = "zbr_tournament_series";
#define SERIES_NONE = "none";
#define SERIES_2023_INVITATIONALS = "2023i";
#define SERIES_2024_Z4C = "2024z4c";
#define SERIES_2023_GG_ZOMBIES = "2023ggz";
#define DEBUG_SERIES = SERIES_NONE;

autoexec tournaments_debug()
{
    if(IS_DEBUG)
	{
		setdvar(ZBR_TOURNAMENT_SETTING, DEBUG_SERIES);
	}
}

tournaments_init()
{
    level.tournament_mode = getdvarstring(ZBR_TOURNAMENT_SETTING, SERIES_NONE);
    if(!isdefined(level.tournament_mode) || level.tournament_mode == SERIES_NONE)
    {
        return;
    }

    tournament_register_modifier(SERIES_2023_INVITATIONALS, "zm_stalingrad", serious::tournament_modifier_dragonfire);
    tournament_register_modifier(SERIES_2023_INVITATIONALS, "zm_zod", serious::tournament_modifier_meatballmania);
    tournament_register_modifier(SERIES_2023_INVITATIONALS, "zm_log_kowloon", serious::tournament_modifier_highs_lows);
    tournament_register_modifier(SERIES_2023_INVITATIONALS, "zm_leviathan", serious::tournament_modifier_drown);

    tournament_activate();
}

tournament_register_modifier(series = "none", map = "zm_zbr", fn_enable)
{
    if(!isfunctionptr(fn_enable))
    {
        return;
    }

    if(!isdefined(level.zbr_tournament_conf))
    {
        level.zbr_tournament_conf = [];
    }

    if(!isdefined(level.zbr_tournament_conf[series]))
    {
        level.zbr_tournament_conf[series] = [];
    }

    level.zbr_tournament_conf[series][map] = fn_enable;
}

tournament_activate()
{
    if(!isdefined(level.tournament_mode) || level.tournament_mode == SERIES_NONE)
    {
        return;
    }

    series = level.tournament_mode;

    if(!isdefined(level.zbr_tournament_conf[series]))
    {
        return;
    }

    if(!isfunctionptr(level.zbr_tournament_conf[series][level.script]))
    {
        return;
    }

    level thread [[ level.zbr_tournament_conf[series][level.script] ]]();
}

// Dragon Fire: All dragon-fire locations are active at all times. Players spawn with a shield with reduced ammo.
tournament_modifier_dragonfire()
{
    // TODO: ambience (skybox, fog, lighting)

    level.zbr_post_loadout = function() =>
    {
        self zm_equipment::buy(level.zbr_dragonshield_name);
        self setWeaponAmmoClip(getweapon(level.zbr_dragonshield_name), 1);
    };

    callback::on_spawned(function() => 
    {
        self endon("disconnect");
        self endon("spawned_player");
        wait 1;
        self zm_equipment::buy(level.zbr_dragonshield_name);
        self setWeaponAmmoClip(getweapon(level.zbr_dragonshield_name), 1);
    });

    level flag::wait_till("initial_blackscreen_passed");
    foreach(player in getplayers())
    {
        if(player.sessionstate == "playing")
        {
            player zm_equipment::buy(level.zbr_dragonshield_name);
            player setWeaponAmmoClip(getweapon(level.zbr_dragonshield_name), 1);
        }
    }

    keys = getarraykeys(level.var_973195fc);
    func = @dragon<scripts\zm\zm_stalingrad_dragon.gsc>::function_2dcfeeb9;
    foreach(loc in keys)
    {
        damageent = getent(loc + "_1_damage", "targetname");
	    damageent thread [[ func ]](loc, 24 * 60 * 60); // flames stop after 24 hours, game cant run this long so I dont care.
    }

    level.var_de98a8ad = 0;
    for(;;)
    {
        if(level.var_de98a8ad != 0)
        {
            level.var_de98a8ad = 0;
        }
        wait 0.05;
    }
}

// Meatball Mania: Killing an enemy has a chance to spawn a meatball at its location. Meatballs deal increased damage.
tournament_modifier_meatballmania()
{
    level.raps_spawn_fx = @zm_ai_raps<scripts\zm\_zm_ai_raps.gsc>::raps_spawn_fx;
    
    // zod only
    level.zombie_death_callbacks[level.zombie_death_callbacks.size] = function(e_attacker, str_means_of_death, weapon) => 
    {
        if(!isplayer(e_attacker) || (randomint(100) > 40))
        {
            return; // no meatball for this guy
        }

        if(isdefined(self.mania_zombie))
        {
            return;
        }

        origin = self.origin;
        attacker_origin = e_attacker.origin;
        wait randomfloatrange(0.05, 0.75);

        spawn = spawnstruct();
        spawn.origin = origin;
        spawn.angles = vectortoangles(origin - attacker_origin);
        ai = zombie_utility::spawn_zombie(level.raps_spawners[0]);
        if(isdefined(ai))
        {
            ai endon("death");
            ai.mania_zombie = true;
            ai.mania_modifier = true;
            ai.favoriteenemy = e_attacker;
            spawn thread [[ level.raps_spawn_fx ]](ai, spawn);
        }
    };
}

// Highs and Lows: SMGs, equipment, and wonder-weapons are the only weapons available.
tournament_modifier_highs_lows()
{
    level.zbr_highs_lows_valid = ["t9_smg_fastfire", "t9_smg_handling", "t9_smg_burst", "t9_smg_heavy", "t9_smg_capacity", "t9_smg_standard", "t9_zm_raygun", "contact_grenade", "cymbal_monkey", "t9_zm_rayrifle", "slipgun", "zbr_emp_grenade_zm"];

    level._customrandomweaponweights = level.customrandomweaponweights;

    level.customrandomweaponweights = function(keys) =>
    {
        a_new_keys = [];

        if(IsFunctionPtr(level._customrandomweaponweights))
        {
            keys = [[ level._customrandomweaponweights ]](keys);
        }

        foreach(key in keys)
        {
            if(!IsInArray(level.zbr_highs_lows_valid, key.rootweapon.name))
            {
                continue;
            }
            a_new_keys[a_new_keys.size] = key;
        }
        return a_new_keys;
    };

    level.zbr_post_loadout = function() =>
    {
        takeaway = [];
        foreach(weapon in self getWeaponsListPrimaries())
        {
            if(!IsInArray(level.zbr_highs_lows_valid, zm_weapons::get_base_weapon(weapon).rootweapon.name))
            {
                takeaway[takeaway.size] = weapon;
            }
        }

        foreach(weapon in takeaway)
        {
            self takeWeapon(weapon);
        }

        if((self getWeaponsListPrimaries()).size < 1)
        {
            self giveweapon(getweapon("t9_smg_standard"));
            self switchtoweapon(getweapon("t9_smg_standard"));
            self giveMaxAmmo(getweapon("t9_smg_standard"));
        }
    };

    level flag::wait_till("initial_blackscreen_passed");
    foreach(player in getplayers())
    {
        if(player.sessionstate == "playing")
        {
            player thread [[ level.zbr_post_loadout ]]();
        }
    }

    spawn_list = [];
    spawnable_weapon_spawns = struct::get_array("weapon_upgrade", "targetname");
	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("bowie_upgrade", "targetname"), 1, 0);
	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("sickle_upgrade", "targetname"), 1, 0);
	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("tazer_upgrade", "targetname"), 1, 0);
	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("buildable_wallbuy", "targetname"), 1, 0);
    if(isdefined(level.use_autofill_wallbuy) && level.use_autofill_wallbuy)
	{
		spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, level.active_autofill_wallbuys, 1, 0);
	}
	if(!(isdefined(level.headshots_only) && level.headshots_only))
	{
		spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("claymore_purchase", "targetname"), 1, 0);
	}
	location = level.scr_zm_map_start_location;
	if(location == "default" || location == "" && isdefined(level.default_start_location))
	{
		location = level.default_start_location;
	}
	match_string = level.scr_zm_ui_gametype;
	if("" != location)
	{
		match_string = (match_string + "_") + location;
	}
	match_string_plus_space = " " + match_string;
	for(i = 0; i < spawnable_weapon_spawns.size; i++)
	{
		spawnable_weapon = spawnable_weapon_spawns[i];
		spawnable_weapon.weapon = getweapon(spawnable_weapon.zombie_weapon_upgrade);
		if(isdefined(spawnable_weapon.zombie_weapon_upgrade) && spawnable_weapon.weapon.isgrenadeweapon && (isdefined(level.headshots_only) && level.headshots_only))
		{
			continue;
		}
		if(!isdefined(spawnable_weapon.script_noteworthy) || spawnable_weapon.script_noteworthy == "")
		{
			spawn_list[spawn_list.size] = spawnable_weapon;
			continue;
		}
		matches = strtok(spawnable_weapon.script_noteworthy, ",");
		for(j = 0; j < matches.size; j++)
		{
			if(matches[j] == match_string || matches[j] == match_string_plus_space)
			{
				spawn_list[spawn_list.size] = spawnable_weapon;
			}
		}
	}

    foreach(spawn in spawn_list)
    {
        if(!isdefined(spawn.trigger_stub))
        {
            continue;
        }
        
        if(IsInArray(level.zbr_highs_lows_valid, spawn.weapon.rootweapon.name))
        {
            continue;
        }

        zm_unitrigger::unregister_unitrigger(spawn.trigger_stub);
    }

    weapon_spawns = [];
	weapon_spawns = getentarray("weapon_upgrade", "targetname");
	for(i = 0; i < weapon_spawns.size; i++)
	{
        if(IsInArray(level.zbr_highs_lows_valid, weapon_spawns[i].weapon.rootweapon.name))
        {
            continue;
        }

		weapon_spawns[i] notify("kill_trigger");
		model = getent(weapon_spawns[i].target, "targetname");
		if(isdefined(model))
		{
			model delete();
		}
        weapon_spawns[i].origin = ORIGIN_OOB;
	}
}

// Siege of the Sea - The submarine will ocasionally fire rockets at players it sees. Mines respawn every round. PHD flopper and danger closest are disabled.
tournament_modifier_drown()
{
    level.zbr_mine_respawn_wait = 1;
    level.super_explosives = true;
    level flag::wait_till("initial_blackscreen_passed");
    remove_box_weapon("launcher_china_lake", "launcher_china_lake_upgraded");
    remove_box_weapon("microwavegun", "microwavegun_upgraded");
    remove_box_weapon("microwavegundw", "microwavegundw_upgraded");
    foreach(perk in getentarray("perk_elevator_trigger", "targetname"))
    {
        if(perk.script_string == "specialty_phdflopper")
        {
            perk.elevator.origin = ORIGIN_OOB;
        }
        perk.origin = ORIGIN_OOB;
    }
    arrayremoveindex(level._custom_perks, "specialty_phdflopper", true);
    if(isarray(level._random_perk_machine_perk_list))
    {
        arrayremovevalue(level._random_perk_machine_perk_list, "specialty_phdflopper", false);
    }
    level notify("specialty_phdflopper" + "_power_thread_end");

    subattack = function(ent, index) => 
    {
        ent endon("death");
        level endon("end_game");
        ent.siege = true;
        for(;;)
        {
            targets = [];
            foreach(player in array::get_all_closest(ent getorigin(), getplayers(), undefined, 8, 2000))
            {
                if(player.sessionstate != "playing")
                {
                    continue;
                }
                if(BulletTracePassed(player geteye(), ent getorigin(), false, ent, player, false, true) && BulletTracePassed(ent getorigin(), player geteye(), false, ent, player, false, true))
                {
                    targets[targets.size] = player;
                }
            }

            num_fired = 0;
            foreach(target in targets)
            {
                if(!isdefined(target.submissiletime))
                {
                    target.submissiletime = array(0, 0);
                }

                if(gettime() - target.submissiletime[index] > 5000)
                {
                    if(!isdefined(target.attractor_handle))
                    {
                        target.attractor_handle = Missile_CreateAttractorEnt(target, 100, 300, false, 1000);
                    }
                    start = (ent GetOrigin()) - (0, 0, 10 + (num_fired * 5));
                    vel = vectornormalize(start - (target getorigin())) * 500;
                    p = ent MagicMissile(getweapon("launcher_law_upgraded"), (ent GetOrigin()) - (0, 0, 10 + (num_fired * 5)), vel, target);

                    if(!isdefined(p))
                    {
                        continue;
                    }
                    p.siege = true;
                    p.target_plr = target;
                    p thread [[ function() => 
                    {
                        self waittill("death");
                        if(!isdefined(self.target_plr) || !isdefined(self.target_plr.attractor_handle))
                        {
                            return;
                        }
                        Missile_DeleteAttractor(self.target_plr.attractor_handle);
                        self.target_plr.attractor_handle = undefined;
                        earthquake(0.5, 0.5, self.origin, 250);
                    }]]();

                    p thread [[ function() => 
                    {
                        self endon("death");
                        self.target_plr endon("disconnect");
                        self.target_plr endon("bled_out");
                        for(;;)
                        {
                            if(!isdefined(self.target_plr))
                            {
                                return;
                            }

                            if(distance(self.origin, self.target_plr.origin) < 30)
                            {
                                self detonate();
                            }

                            wait 0.05;
                        }
                    }]]();

                    target.submissiletime[index] = gettime();
                    num_fired++;
                    wait randomFloatRange(0.15, 0.3);
                }
            }

            wait num_fired * 0.25 + randomFloatRange(0.5, 1.0);
        }
    };
    
    ent = getvehiclearray("vehicle_submarine", "targetname")[0];
    while(!isdefined(ent))
    {
        ent = getvehiclearray("vehicle_submarine", "targetname")[0];
        wait 1;
    }

    level thread [[ subattack ]](ent, 0);

    ent = getvehiclearray("uranium_submarine", "targetname")[0];
    while(!isdefined(ent))
    {
        ent = getvehiclearray("uranium_submarine", "targetname")[0];
        wait 1;
    }

    level thread [[ subattack ]](ent, 1);
}