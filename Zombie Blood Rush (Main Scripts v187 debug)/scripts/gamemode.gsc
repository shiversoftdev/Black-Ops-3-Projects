initgamemode()
{
    if(isdefined(level.game_mode_init_entered) && level.game_mode_init_entered)
    {
        return;
    }

    level.game_mode_init_entered = true;

    if(isdefined(level.game_mode_init) && level.game_mode_init)
    {
        return;
    }

    init_emotes();
    init_status_effects();
    setup_environment();
    setup_bots();
    generate_weapons_table();
    apply_aat_changes();
    apply_bgb_changes();
    apply_powerup_changes();
    apply_trap_changes();
    init_wager_totems();
    setup_boxes_and_perks();
    initmaps();
    initscoreboard();
    tournaments_init();

    level.game_mode_init = true;

    level thread PointAddedDispatcher();
    level thread initdev();

    if(!IS_DEBUG || !DEBUG_NO_GM_THREADED)
    {
        level thread initgamemodethreaded();
    }

    if(IS_DEBUG)
    {
        level.zbr_moveround = serious::gm_moveround;   
    }

    level.zbr_createhud = serious::GM_CreateHUD;
    level.zbr_destroyhud = serious::GM_DestroyHUD;
    level.zbr_send_client_rpc = serious::send_client_rpc;
    level.zbr_get_keyboard_response = serious::get_keyboard_response;

    zbr_responsemonitor = function() => 
    {
        self notify(#zbr_responsemonitor);
        self endon(#zbr_responsemonitor);
        self endon(#disconnect);
        for(;;)
        {
            self waittill(#menuresponse, menu, response);
            if(strstartswith(response, "kbmr"))
            {
                self notify(#kbmr, getsubstr(response, 4));
            }
            if(strstartswith(response, "kmsr"))
            {
                if(self.sessionstate != "playing")
                {
                    continue;
                }

                self bgb::take();

                a_str_perks = getarraykeys(level._custom_perks);
                foreach(str_perk in a_str_perks)
                {
                    self unsetperk(str_perk);
                    self notify(str_perk + "_stop");
                }
                
                self disableInvulnerability();
                self doDamage(self.health + 666, self.origin);
            }
            if(StrStartsWith(response, "emote"))
            {
                index = int(getsubstr(response, 5));
                if(isdefined(index))
                {
                    self thread do_zbr_emote(index);
                }
            }
        }
    };

    array::thread_all(getplayers(), zbr_responsemonitor);
    callback::on_connect(zbr_responsemonitor);
}

initscoreboard()
{
    setscoreboardcolumns("score", "defuses", "kills", "headshots", "deaths");
}

initgamemodethreaded()
{
    level flag::wait_till("begin_spawning");
    level.game_mode_init_time = gettime();
    level thread gm_sudden_death_timer();

    level.limited_weapons = []; // clear weapon limits so all players can obtain what they want
    level.zombie_init_done = serious::Event_ZombieInitDone;
    level thread zm_island_fix();
    level thread zm_round_failsafe();

    zm_moon_fixes();
    enable_power();
    apply_perk_changes();
    apply_door_prices();
    setup_weapons();
    thread cm_bgbmachines_init();
    thread custom_gm_threaded();

    if(level.do_not_apply_rand_lighting !== true)
    {
        rand = randomIntRange(0, 2);
        high = level.script == "zm_zod" ? 3 : 1;
        if(level.script == "zm_castle") high = 0;
        apply_lighting((rand * high) as int);
    }

    // start the first game mode round
    gm_moveround(IS_DEBUG ? DEBUG_START_ROUND : GM_START_ROUND);
    setdvar("sv_cheats", 0);

    level.gm_finished_threading = true;
}

gm_moveround(target)
{
    level.round_number = target;
    level.player_weapon_boost += (level.round_number - 3) * WEP_DMG_BOOST_PER_ROUND;
    // level.player_weapon_boost_wu = [[ level.fn_zbr_standard_boost_wu ]]();
    level.zombie_vars["zombie_move_speed_multiplier"] = GM_ZM_SPEED_MULT;
    level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];
    SetRoundsPlayed(level.round_number);
    world.var_48b0db18 = level.round_number ^ 115;
    level.skip_alive_at_round_end_xp = true;
    calc_zbr_ai_count(level.round_number + 1);
    level.zombie_vars["zombie_spawn_delay"] = [[level.func_get_zombie_spawn_delay]](level.round_number + 1);
    thread zm_bgb_round_robbin::function_8824774d(level.round_number + 1);
}

setup_boxes_and_perks()
{
    foreach(box in level.chests) 
    {
        box thread one_box_hit_monitor();
        box.unitrigger_stub.prompt_and_visibility_func = serious::stealable_box_vis_func;
    }

    vending_weapon_upgrade_trigger = zm_pap_util::get_triggers();
	if(isarray(vending_weapon_upgrade_trigger) && vending_weapon_upgrade_trigger.size >= 1)
	{
		array::thread_all(vending_weapon_upgrade_trigger, serious::stealable_vending_weapon_upgrade);
	}

    if(isdefined(level.custom_random_perk_weights) && REMOVE_MULEKICK)
    {
        level._custom_random_perk_weights = level.custom_random_perk_weights;
        level.custom_random_perk_weights = function() =>
        {
            val = self [[ level._custom_random_perk_weights ]]();
            if(isarray(level._random_perk_machine_perk_list))
            {
                ArrayRemoveValue(level._random_perk_machine_perk_list, "specialty_additionalprimaryweapon", 0);
            }
            return getarraykeys(level._random_perk_machine_perk_list);
        };
    }
}

setup_weapons()
{
    // unlimit all equipment
    level._limited_equipment = [];
    str_riotshield = level.weaponriotshield?.name ?? "";
    if(str_riotshield == level.zbr_dragonshield_name)
    {
        level._riotshield_melee_power = level.riotshield_melee_power;
        level.riotshield_melee_power = serious::dragon_shield_melee;
    }

    foreach(w in getArrayKeys(level.zombie_weapons))
    {
        level.zombie_weapons[w].force_attachments = [];
    }

    if(str_riotshield != level.zbr_dragonshield_name)
    {
        if(!isdefined(level.__riotshield_damage))
        {
            level.__riotshield_damage = @riotshield<scripts\zm\_zm_weap_riotshield.gsc>::player_damage_shield;
        }

        level.riotshield_damage_callback = function(idamage, bheld, fromcode = 0, smod = "MOD_UNKNOWN") => 
        {
            shielddamage = idamage;
            if(isdefined(self.lastshieldattacker) && isplayer(self.lastshieldattacker))
            {
                b_staff = isdefined(self.shield_damage_last_weapon) && is_tomb_staff(self.shield_damage_last_weapon);
                b_weaponnone = isdefined(self.shield_damage_last_weapon) && (self.shield_damage_last_weapon == level.weaponnone);
                if(!b_staff && !b_weaponnone && (smod == "MOD_PROJECTILE_SPLASH" || smod == "MOD_GRENADE" || smod == "MOD_GRENADE_SPLASH" || smod == "MOD_EXPLOSIVE"))
                {
                    newhealth = self damageriotshield(int(2 * shielddamage));
                }
                else
                {
                    healAmt = shielddamage * 0.95;
                    if(shielddamage - healAmt > 150)
                    {
                        healAmt = shielddamage - 150;
                    }
                    newhealth = self damageriotshield(int(-1 * healAmt)); // ugh this game is so dumb LMAO
                }
            }
            else if(smod == "MOD_EXPLOSIVE")
            {
                shielddamage = int(shielddamage + (idamage * 2));
            }

            if(isdefined(level.__riotshield_damage))
            {
                self [[ level.__riotshield_damage ]](shielddamage, bheld, fromcode, smod);
            }
        };

        level.zbr_rsdcb = level.riotshield_damage_callback;

        level._should_shield_absorb_damage = level.should_shield_absorb_damage;
        level.should_shield_absorb_damage = function(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime) =>
        {
            self.player_shield_apply_damage = level.zbr_rsdcb;
            self.shield_damage_last_weapon = weapon;
            self.lastshieldattacker = eattacker;
            if(isdefined(level._should_shield_absorb_damage))
            {
                return self [[ level._should_shield_absorb_damage ]](einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime);
            }
            return 1;
        };
    }
    
    if(level.craftable_shield_weapon ?& level.craftable_shield_weapon == level.zbr_dragonshield_name)
    {
        foreach(ut_craftable in level.a_uts_craftables)
        {
            if(ut_craftable.weaponname == getweapon(level.zbr_dragonshield_name)) // yes... .weaponname is a weapon object, not a string...
            {
                ut_craftable._prompt_and_visibility_func = ut_craftable.prompt_and_visibility_func;
                ut_craftable.prompt_and_visibility_func = serious::dragonshield_prompt_and_visibility_func;
            }
        }

        level.zombie_include_craftables["craft_shield_zm"]._onbuyweapon = level.zombie_include_craftables["craft_shield_zm"].onbuyweapon;
        level.zombie_include_craftables["craft_shield_zm"].onbuyweapon = serious::on_buy_dragonshield;
    }

    if(getweapon("hero_gravityspikes_melee") ?& isdefined(level._hero_weapons[getweapon("hero_gravityspikes_melee")]?.wield_fn))
    {
        level.old_gs_wield_fn = level._hero_weapons[getweapon("hero_gravityspikes_melee")].wield_fn;
        level.old_gs_unwield_fn = level._hero_weapons[getweapon("hero_gravityspikes_melee")].unwield_fn;
        level._hero_weapons[getweapon("hero_gravityspikes_melee")].wield_fn = serious::wield_gravityspikes;
        level._hero_weapons[getweapon("hero_gravityspikes_melee")].unwield_fn = serious::unwield_gravityspikes;
    }

    if(level.idgun_weapons ?& isarray(level.idgun_weapons) && level.idgun_weapons.size > 0)
    {
        level.zombie_include_weapons[level.idgun_weapons[0]] = 1;
        level.zombie_weapons[level.idgun_weapons[0]].is_in_box = 1;
        level.zombie_weapons[level.idgun_weapons[0]].upgrade = (level.script == "zm_genesis") ? getweapon("idgun_genesis_0_upgraded") : getweapon("idgun_upgraded_0");
        level.zombie_weapons_upgraded[level.zombie_weapons[level.idgun_weapons[0]].upgrade] = level.idgun_weapons[0];
    }

    if(isdefined(level.var_32bc7eba))
    {
        tomb_staff_init();
    }

    if(isdefined(level.glaive_chop_cone_range))
    {
        glaive_init();
    }

    dragon_whelp_init();
    custom_aat_fix();
    custom_weapon_init();
    
    if(isdefined(level.placeable_mine_planted_callbacks))
    {
        foreach(wpn_name, value in level.placeable_mine_planted_callbacks)
        {
            add_mine_planted_callback(serious::mine_watch_pvp_damage, wpn_name);
        }
    }
    level thread octobomb_watcher();
    quantum_bomb_init();
}

// will attempt to repair aat functionality for maps who disable it through certain means.
custom_aat_fix()
{
    keys = getarraykeys(level.aat_exemptions);
    foreach(weapon in keys)
    {
        switch(true)
        {
            case zm_utility::is_lethal_grenade(weapon):
            case zm_utility::is_tactical_grenade(weapon):
            case zm_utility::is_placeable_mine(weapon):
            case zm_utility::is_offhand_weapon(weapon):
            case zm_utility::is_melee_weapon(weapon):
            case zm_utility::is_hero_weapon(weapon):
            break;

            default:
                arrayremoveindex(level.aat_exemptions, weapon, true);
            break;
        }
    }
}

apply_lighting(setting = 0)
{
    level util::set_lighting_state(setting);
    if(isdefined(level.var_1b3f87f7))
	{
		level.var_1b3f87f7 delete();
	}
	level.var_1b3f87f7 = createstreamerhint(level.activeplayers[0].origin, 1, !setting);
	level.var_1b3f87f7 setlightingonly(1);
}

setup_environment()
{
    #region Bool
    level.player_too_many_weapons_monitor = false;
    level.b_allow_idgun_pap = true;
    level.force_solo_quick_revive = true;
    level.pack_a_punch.grabbable_by_anyone = true;
    level.wasp_rounds_enabled = false;  // fix SOE crash
    level.raps_rounds_enabled = false;  // fix SOE crash
    level.var_1821d194 = true; // zm_island anti-spider fix
    level.drawfriend = false;
    level.custom_firesale_box_leave = false;
    level.zombiemode_reusing_pack_a_punch = true; // attempt to circumvent anti-double pap on custom maps
    level.var_b426c9 = true; // disables zm_island seeds
    level.forceallallies = false;
    level.ondeadevent = undefined;
    level.allies = function() => {};
    level.onlinegame = true;
    level.rankedmatch = true;
    level.rankenabled = true;
    level.player_too_many_players_check = false;
    level.passed_introscreen = true;
    level.actorbookmarkparamsinitialized = undefined;
    level.super_explosives ??= false;
    level.should_watch_for_emp = true;
    #endregion

    #region Scalar
    level.max_astro_zombies = 0;
    level.astro_round_start = 999;
    level.next_astro_round = 999;
    level.zombies_left_before_astro_spawn = 0x7FFFFFFF;
    level.perk_purchase_limit = 99;
    level._random_zombie_perk_cost = 1500;
    level.chest_moves = 1; // allows firesales to be dropped by the game

    level.next_wasp_round = 999;  // fix SOE crash
    level.n_next_raps_round = 999;  // fix SOE crash
    level.solo_lives_given = -9999;
    level.max_solo_lives = 9999;
    level._race_team_double_points = undefined;
    level.zbr_minigun_scalar ??= 1.0;
    define_zombie_vars();
    #endregion

    #region misc
    level.zombie_team = "team3";
    level.zombie_team_index = 3;
    level.zbr_player_loadouts = [];
    level.zbr_dragonshield_name ??= "dragonshield";
    level.zbr_dragonshield_name_upgraded ??= "dragonshield_upgraded";
    #endregion

    #region Callbacks and Overrides
    level._custom_intermission = level.custom_intermission;
    level.custom_intermission = serious::custom_intermission;
    level._callbackActorDamage = level.callbackActorDamage;
    level._overridePlayerDamage = level.overridePlayerDamage;
    level._callbackPlayerLastStand = level.callbackPlayerLastStand;
    level.__black_hole_bomb_poi_override = level._black_hole_bomb_poi_override;
    level.callbackActorDamage = serious::_actor_damage_override_wrapper;
    level.overridePlayerDamage = serious::_player_damage_override;
    level.callbackPlayerLastStand = serious::PlayerDownedCallback;
    level.deathcard_spawn_func = serious::PlayerDiedCallback;
    level._check_quickrevive_hotjoin = level.check_quickrevive_hotjoin;
    level.check_quickrevive_hotjoin = serious::quick_revive_hook;
    level.custom_spectate_permissions = serious::on_joined_spectator;
    level.custom_game_over_hud_elem = serious::end_game_hud;
    level._black_hole_bomb_poi_override = serious::bhb_hook;
    level.zombie_init_done = serious::Event_ZombieInitDone;
    level.func_get_zombie_spawn_delay = serious::Calc_ZombieSpawnDelay;
    level.grenade_planted = serious::grenade_planted_override;
    level._player_score_override = level.player_score_override;
    level.player_score_override = serious::player_score_override;
    level.get_player_weapon_limit = serious::get_player_weapon_limit;
    level.zombie_death_animscript_override = serious::zombie_death_animscript_override;
    level._func_magicbox_weapon_spawned = level.func_magicbox_weapon_spawned;
    level.func_magicbox_weapon_spawned = serious::wager_func_magicbox_weapon_spawned;
    level._perk_lost_func = level.perk_lost_func;
    level.perk_lost_func = serious::perk_lost_func;

    level._zombiemode_check_firesale_loc_valid_func = serious::check_firesale_valid_loc;
    level.player_intersection_tracker_override = serious::true_one_arg;
    level.player_out_of_playable_area_monitor_callback = serious::nullsub;
    level.player_too_many_players_check_func = serious::nullsub;
    level._game_module_game_end_check = serious::nullsub;
    level.powerup_vo_available = serious::powerup_grab_hook;
    level.custom_magic_box_selection_logic = function(weapon, player, paptriggers) => { return true; };
    level._behaviortreescriptfunctions["zombiefindfleshservice"] = serious::find_flesh_verify;
    level._notetrack_handler["zombie_melee"] = serious::_zombienotetrackmeleefire;

    level.customSpawnLogic = undefined; //fix verruckt
    level.check_valid_spawn_override = undefined; //fix shang
    level.prevent_player_damage = undefined; // fix team damage issue
    level.player_too_many_weapons_monitor_func = serious::nullsub; // fix bs with their weapons logic
    level.gm_bowie_knife = getweapon("bowie_knife");

    if(level.givecustomcharacters ?& !isdefined(level._givecustomcharacters))
    {
        level._givecustomcharacters = level.givecustomcharacters;
        level.givecustomcharacters = serious::give_custom_characters;
    }

    if(level.script != "zm_moon")
    {
        level.zombie_round_change_custom = serious::Event_RoundNext;
    }
    else
    {
        level.round_start_custom_func = serious::Event_RoundNext;
    }

    zm_spawner::register_zombie_death_event_callback(serious::wager_gg_kill);
    level.zbr_damage_callbacks = [];

    level._audio_custom_response_line = function(player, category, subcategory) => {};

    level.dont_unset_perk_when_machine_paused = false;
    level.zbr_emp_cb = function(enable) =>
    {
        self.zbr_emp = enable;
        self gm_hud_set_visible(!enable, true);

        if(enable)
        {
            self pause_all_perks();
        }
        else
        {
            if(self.sessionstate == "playing")
            {
                self resume_all_perks();
            }
        }
    };

    level.zbr_emp_explode = function(owner, weapon, origin, radius, damageplayers) =>
    {
        foreach(zombie in GetAITeamArray(level.zombie_team))
        {
            if(distanceSquared(zombie.origin, origin) <= 160000)
            {
                // if(isdefined(zombie.emp_time))
                // {
                //     zombie doDamage(zombie.health + 666, zombie.origin, owner);
                //     continue;
                // }
                // zombie.emp_time = gettime() + 15000;
                // zombie pushactors(0);
                // zombie.enablepushtime = zombie.emp_time;
                // zombie clearpath();
                // zombie.v_zombie_custom_goal_pos = zombie.origin;
                // zombie.n_zombie_custom_goal_radius = 100;
                // zombie.zombie_do_not_update_goal = true;
                // zombie.is_inert = true;
                // zombie.ignoremelee = true;
                // zombie.blockingpain = true;
                // zombie setgoal(zombie.origin);
                // zombie zombie_utility::zombie_eye_glow_stop();
                zombie doDamage(zombie.health + 666, zombie.origin, owner);
            }
        }

        foreach(machine in getentarray("zombie_vending", "targetname"))
        {
            if(distanceSquared(machine.origin, origin) > 122500)
            {
                continue;
            }

            if(machine.script_noteworthy is defined)
            {
                machine thread [[ function() => {
                    self notify(#perk_pause_machine);
                    self endon(#perk_pause_machine);
                    perk_pause_machine(self.script_noteworthy);
                    level notify(level._custom_perks[self.script_noteworthy].alias + "_off");
                    self sethintstring("");
                    playfx("electric/fx_elec_sparks_burst_xsm_omni_blue_os", self.origin);
                    playsoundatposition("zmb_cherry_explode", self.origin);
                    wait 30;
                    level notify(level._custom_perks[self.script_noteworthy].alias + "_on");
                    self zm_perks::reset_vending_hint_string();
                    perk_unpause_machine(self.script_noteworthy);
                } ]]();
            }
        }

        if(isdefined(level.missileentities))
        {
            foreach(missile in level.missileentities)
            {
                if(missile.origin is undefined)
                {
                    continue;
                }

                d = distanceSquared(missile.origin, origin);

                if(d > 122500)
                {
                    continue;
                }

                if(missile.weapon is defined and (missile.weapon == level.zbr_emp_grenade_zm))
                {
                    if(d < 5)
                    {
                        continue;
                    }
                }

                playfx("electric/fx_elec_sparks_burst_xsm_omni_blue_os", missile.origin);
                missile delete();
            }
        }

        level.fake_bgb_machines ??= [];
        foreach(machine in ArrayCombine(level.fake_bgb_machines, level.var_5081bd63, false, false))
        {
            if(machine.origin is undefined)
            {
                continue;
            }

            d = distanceSquared(machine.origin, origin);

            if(d > 122500)
            {
                continue;
            }

            playfx("electric/fx_elec_sparks_burst_xsm_omni_blue_os", machine.origin);
            playsoundatposition("zmb_box_poof", machine.origin);
            machine notify(#user_grabbed_bgb);
            machine notify(#zbr_emp_gum);
            machine notify(#trigger, level);
        }

        trigs = [];
        if(isdefined(level.pack_a_punch) && isdefined(level.pack_a_punch.triggers))
        {
            trigs = ArrayCombine(trigs, level.pack_a_punch.triggers, false, false);
        }
        trigs = ArrayCombine(trigs, getentarray("zombie_vending_upgrade", "targetname"), false, true);

        foreach(trig in trigs)
        {
            if(trig.origin is undefined)
            {
                continue;
            }

            d = distanceSquared(trig.origin, origin);

            if(d > 122500)
            {
                continue;
            }

           // level notify(#pack_a_punch_off);
            trig notify(#pap_timeout);
            trig notify(#pap_player_disconnected);
            playsoundatposition("zmb_box_poof", trig.origin);
            playfx("electric/fx_elec_sparks_burst_xsm_omni_blue_os", trig.origin + (0, 0, 30));
            
            // thread [[ function() => 
            // {
            //     wait 5;
            //     level notify(#pack_a_punch_on);
            // }]]();
        }

        level.perk_random_machines ??= [];
        foreach(machine in level.perk_random_machines)
        {
            if(machine.origin is undefined)
            {
                continue;
            }

            d = distanceSquared(machine.origin, origin);

            if(d > 122500)
            {
                continue;
            }

            playsoundatposition("zmb_box_poof", machine.origin);
            machine notify(#time_out_check);
            playfx("electric/fx_elec_sparks_burst_xsm_omni_blue_os", machine.origin + (0, 0, 25));
        }
    };

    level.zbr_grenade_emp_watcher = function(owner, weapon) =>
    {
        self.health = 10000;
        self.maxhealth = 10000;
        self setcandamage(true);
        self solid();
        self thread [[ 
            function(grenade, owner, weapon) => 
            {
                self.grenade = grenade;
                self.owner = owner;
                self.grenade endon(#death);
                self.grenade setcandamage(true);
                for(;;)
                {
                    self waittill("damage", damage, attacker, dir, point, dmg_type, model, tag, part, weapon, flags);
                    self.health = 0;
                    self.maxhealth = 1;
                    if(attacker is undefined or !isplayer(attacker) or (self.owner == attacker and weapon is defined and (weapon == level.zbr_emp_grenade_zm)))
                    {
                        continue;
                    }
                    damageStage = 1;
                    attacker PlayHitMarker("mpl_hit_alert", damageStage, undefined, false);
                    attacker thread damagefeedback::damage_feedback_growth(self, dmg_type, weapon);
                    damage3d(attacker, point, damage, DAMAGE_TYPE_ZOMBIES);
                    playsoundatposition("zmb_box_poof", self.grenade.origin);
                    playfx("electric/fx_elec_sparks_burst_xsm_omni_blue_os", self.grenade.origin);
                    self.grenade delete();
                    return;
                }
        } ]](self, owner, weapon);
    };

    level._zombielevelspecifictargetcallback = level.zombielevelspecifictargetcallback;
    level.zombielevelspecifictargetcallback = function() =>
    {
        if(isdefined(self.emp_time) && (self.emp_time - gettime()) <= 13000)
        {
            // check alert by player being too close to us
            foreach(player in getplayers())
            {
                if(player.sessionstate == "playing" && distanceSquared(player.origin, self.origin) <= 900)
                {
                    self.emp_time = gettime();
                    break;
                }
            }
        }

        if(isdefined(self.emp_time) && self.emp_time <= gettime())
        {
            self.emp_time = undefined;
            self.blockingpain = false;
            self.v_zombie_custom_goal_pos = undefined;
            self.n_zombie_custom_goal_radius = undefined;
            self.zombie_do_not_update_goal = false;
            self.is_inert = false;
            self.ignoremelee = false;
            self zombie_utility::zombie_eye_glow();
        }

        if(isdefined(level._zombielevelspecifictargetcallback))
        {
            return [[ level._zombielevelspecifictargetcallback ]]();
        }
        return undefined;
    };
    #endregion

    #region Gamemode Variables
    level.first_spawn = true;
    level.playing_song = false;

    level.zombieDamageScalar = 1;
    level.gm_zombie_dmg_scalar = 1.0f;
    level.gm_rubber_banding_scalar = 1.0f;
    level.boxCost = 950;
    level.player_weapon_boost = 0;
    level.b_is_zod = (level.script == "zm_zod");
    level.b_is_stalingrad = (level.script == "zm_stalingrad");
    level.winning_musics = ["mus_115_riddle_oneshot_intro", "mus_abra_macabre_intro", "mus_infection_church_intro"];
    level.customs_zombie_damage_scalar = 1.0;
    if(ZBR_IS_WORKSHOP)
    {
        level.winning_musics[level.winning_musics.size] = "zbr_mus_reflections";
        level.winning_musics[level.winning_musics.size] = "zbr_mus_zod";
        level.winning_musics[level.winning_musics.size] = "zbr_mus_avagadro";
    }

    // Moon damage adjust for the bhb
    if(isdefined(level.var_453e74a0))
    {
        level.start_vortex_damage_radius = BLACKHOLEBOMB_MIN_DMG_RADIUS;
    }
    level.zbr_glow_fx = level._effect["monkey_glow"];
    level.zbr_death_callbacks = [];

    level.fn_zbr_standard_boost_wu = function(weapon) =>
    {
        if(!isdefined(weapon))
        {
            return 1.0;
        }

        if(level.round_number < 21)
        {
            if(weapon.issniperweapon)
            {
                return LerpFloat(1.3, 2.0, pow((level.round_number - 3) / 17, 1.1));
            }
            return LerpFloat(0.8, 2.0, pow((level.round_number - 3) / 17, 1.1));
        }

        return LerpFloat(2.0, 2.5, min(1, pow((level.round_number - 20) / 10, 1.3)));
    };

    // level.player_weapon_boost_wu = [[ level.fn_zbr_standard_boost_wu ]]();
    #endregion

    setdvar("sv_cheats", 0);
}

define_zombie_vars()
{
    if(!isdefined(level.zombie_vars["allies"]) || !isarray(level.zombie_vars["allies"]))
        level.zombie_vars["allies"] = [];
    
    for(i = 3; i < 12; i++)
    {
        if(!isdefined(level.zombie_vars["team" + i]) || !isarray(level.zombie_vars["team" + i]))
            level.zombie_vars["team" + i] = [];
        level.zombie_vars["team" + i]["zombie_point_scalar"] = 1;
    }

    foreach(team in level.gm_teams)
    {
        if(!isdefined(level.zombie_vars[team]) || !isarray(level.zombie_vars[team]))
            level.zombie_vars[team] = [];
        level.zombie_vars[team]["zombie_point_scalar"] = 1;
        level.zombie_vars[team]["zombie_insta_kill"] = 0;
        level.zombie_vars[team]["zombie_powerup_insta_kill_on"] = 0;
        level.zombie_vars[team]["zombie_powerup_insta_kill_time"] = 0;
        level.zombie_vars[team]["zombie_powerup_double_points_time"] = 0;
        level.zombie_vars[team]["zombie_powerup_double_points_on"] = 0;
        
        foreach(powerup in level.zombie_powerups)
        {
            if(isdefined(powerup.time_name))
            {
                level.zombie_vars[team][powerup.time_name] = 0;
            }
            if(isdefined(powerup.on_name))
            {
                level.zombie_vars[team][powerup.on_name] = 0;
            }
        }

        level.zombie_vars[team]["zombie_powerup_fire_sale_time"] = undefined;
        level.zombie_vars[team]["zombie_powerup_fire_sale_on"] = undefined;
    }

    level.zombie_vars["allies"]["zombie_point_scalar"] = 1;
    level.zombie_vars["zombie_move_speed_multiplier"] = GM_ZM_SPEED_MULT;
    level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];
    level.zombie_vars[ "penalty_no_revive" ] = 0;
    level.zombie_vars[ "penalty_died" ] = 0;
    level.zombie_vars[ "penalty_downed" ] = 0;
    level.zombie_vars[ "zombie_between_round_time" ] = GM_BETWEEN_ROUND_DELAY_START;
}

apply_bgb_changes()
{
    level.bgb["zm_bgb_fear_in_headlights"].activation_func = serious::bgb_fith_activate;
    level.bgb["zm_bgb_round_robbin"].activation_func = serious::bgb_rr_activate;
    level.bgb["zm_bgb_pop_shocks"].var_d99aa464 = serious::bgb_ps_actordamage;
    level.bgb["zm_bgb_pop_shocks"].var_bfbb61c1 = serious::bgb_ps_vehicledamage;
    level.bgb["zm_bgb_pop_shocks"].limit = serious::bgb_ps_event;
    level.bgb["zm_bgb_burned_out"].limit = serious::bgb_burnedout_event;
    level.bgb["zm_bgb_killing_time"].activation_func = serious::bgb_kt_activate;
    level.bgb["zm_bgb_killing_time"].var_d99aa464 = serious::bgb_kt_actor_damage;
    level.bgb["zm_bgb_idle_eyes"].activation_func = serious::bgb_idle_eyes_activate;
    level.bgb["zm_bgb_mind_blown"].activation_func = serious::bgb_mind_blown_activate;
    level.bgb["zm_bgb_profit_sharing"].var_e25efdfd = serious::bgb_profit_sharing_override;
    level.bgb["zm_bgb_anywhere_but_here"].activation_func = serious::anywhere_but_here_activation;
    level.bgb["zm_bgb_head_drama"].limit_type = "event";
    level.bgb["zm_bgb_head_drama"].limit = function() => 
    {
        self endon("disconnect");
        self endon("bled_out");
        self endon("bgb_update");
        limit = 3;
        count = limit;
        while(count)
        {
            self bgb::set_timer(count, limit);
            self util::waittill_any("zbr_next_round", "zbr_killed_player");
            count--;
        }
    };

    level.bgb["zm_bgb_perkaholic"].limit = function() => 
    {
        self endon("disconnect");
        self endon("bgb_update");

        self.no_arms_grace_take = true;
        wait(0.05);
        self zm_utility::give_player_all_perks();
        self bgb::do_one_shot_use(1);
        wait(0.05);
    };

    level.bgb["zm_bgb_near_death_experience"].limit_type = "event";
    level.bgb["zm_bgb_near_death_experience"].enable_func = undefined; // get rid of old near death experience
    level.bgb["zm_bgb_near_death_experience"].limit = function() => 
    {
        self endon("disconnect");
        self endon("bled_out");
        self endon("bgb_update");

        self thread zm_perks::give_perk("specialty_quickrevive", false); // because of a dumb bug with pistols and not having quick-revive when revived.

        limit = 5;
        count = limit;
        while(count)
        {
            self bgb::set_timer(count, limit);
            res = self util::waittill_any_return("zbr_next_round", "player_downed");
            count--;

            if(!count && res == "player_downed")
            {
                self bgb::set_timer(0, limit);
                wait 2;
                while(self laststand::player_is_in_laststand())
                {
                    wait 1;
                }
                wait 4;
            }
        }
    };

    level.bgb["zm_bgb_profit_sharing"].enable_func = serious::zm_bgb_profit_sharing_enable;
    level.bgb["zm_bgb_power_vacuum"].limit = 1;
    level.bgb["zm_bgb_power_vacuum"].enable_func = serious::zm_bgb_power_vacuum_enable;
    level.bgb["zm_bgb_armamental_accomplishment"].disable_func = serious::bgb_armamental_enable;
    level.bgb["zm_bgb_armamental_accomplishment"].enable_func = serious::bgb_armamental_disable;
    level.bgb["zm_bgb_armamental_accomplishment"].limit = function() => 
    {
        self endon(#disconnect);
        self endon(#bled_out);
        self endon(#bgb_update);
        self waittill(#bgb_update);
    };
    level.bgb["zm_bgb_armamental_accomplishment"].limit_type = "event";
    level.bgb["zm_bgb_crawl_space"].activation_func = serious::bgb_crawl_space_activate;
    level.bgb["zm_bgb_extra_credit"].activation_func = serious::bgb_extra_credit_activate;
    level.bgb["zm_bgb_impatient"].limit = serious::bgb_impatient_event;
    level.bgb["zm_bgb_coagulant"].disable_func = undefined;
    level.bgb["zm_bgb_coagulant"].enable_func = undefined;
    level.bgb["zm_bgb_bullet_boost"].validation_func = serious::zm_bgb_bullet_boost_validation;
    level.bgb["zm_bgb_bullet_boost"].activation_func = serious::zm_bgb_bullet_boost_activation;
    level.bgb["zm_bgb_coagulant"].limit_type = "event";
    level.bgb["zm_bgb_coagulant"].limit = serious::bgb_coagulant_activate;
    level.bgb["zm_bgb_always_done_swiftly"].disable_func = undefined;
    level.bgb["zm_bgb_always_done_swiftly"].enable_func = undefined;
    level.bgb["zm_bgb_always_done_swiftly"].limit = serious::bgb_always_done_swiftly_enable;
    level.bgb["zm_bgb_always_done_swiftly"].limit_type = "event";
    level.bgb["zm_bgb_firing_on_all_cylinders"].disable_func = undefined;
    level.bgb["zm_bgb_firing_on_all_cylinders"].enable_func = undefined;
    level.bgb["zm_bgb_firing_on_all_cylinders"].limit = serious::bgb_sprintfire_enable;
    level.bgb["zm_bgb_firing_on_all_cylinders"].limit_type = "event";
    level.bgb["zm_bgb_phoenix_up"].limit_type = "event";
    level.bgb["zm_bgb_phoenix_up"].limit = serious::bgb_phoenix_up_activate;
    level.bgb["zm_bgb_unquenchable"].limit = serious::bgb_unquenchable_event;
    level.bgb["zm_bgb_in_plain_sight"].activation_func = serious::bgb_ips_activate;
    level.bgb["zm_bgb_board_to_death"].enable_func = serious::bgb_btd_enable;
    level.bgb["zm_bgb_undead_man_walking"].enable_func = serious::bgb_umw_enable;
    level.bgb["zm_bgb_undead_man_walking"].limit = 60;
    level.bgb["zm_bgb_alchemical_antithesis"].var_e25efdfd = serious::alchemical_add_to_player_score_override;
    level.bgb["zm_bgb_sword_flay"].limit_type = "rounds";
    level.bgb["zm_bgb_sword_flay"].limit = 1;
    level.bgb["zm_bgb_reign_drops"].limit = 1;
    level.bgb["zm_bgb_fatal_contraption"].limit = 1;
    level.bgb["zm_bgb_lucky_crit"].limit = 2;
    level.bgb["zm_bgb_cache_back"].limit = 2;
    level.bgb["zm_bgb_round_robbin"].limit = 2;
    level.bgb["zm_bgb_danger_closest"].enable_func = function() =>
    {
        self.danger_closest_points_remaining = int(DANGERCLOSEST_HP * 4);
    };
    level.bgb["zm_bgb_danger_closest"].disable_func = function() =>
    {
        self.danger_closest_points_remaining = undefined;
    };
    level.bgb["zm_bgb_danger_closest"].limit_type = "event";
    level.bgb["zm_bgb_danger_closest"].limit = function() =>
    {
        self endon(#disconnect);
        self endon(#bled_out);
        self endon(#bgb_update);
        while(isdefined(self.danger_closest_points_remaining) && self.danger_closest_points_remaining > 0)
        {
            self waittill(#danger_closest_points_remaining);
            self bgb::set_timer(self.danger_closest_points_remaining, int(DANGERCLOSEST_HP * 4));
        }
    };

    level.bgb["zm_bgb_now_you_see_me"].activation_func = function() =>
    {
        self endon("disconnect");
        time = 60;
        KillHeadIcons(self);
        EntityHeadKillIcon(self, self GetTagOrigin("j_head") - self GetOrigin(), (6,6,0), (1,0,0));
        self.b_is_designated_target = 1;
        self thread bgb::run_timer(time);
        self playsound("zmb_bgb_nysm_start");
        self playloopsound("zmb_bgb_nysm_loop", 1);
        visionset_mgr::activate("visionset", "zm_bgb_now_you_see_me", self, 0.5, 9, 0.5);
        visionset_mgr::activate("overlay", "zm_bgb_now_you_see_me", self);
        ret = self util::waittill_any_timeout(time - 0.5, "bgb_about_to_take_on_bled_out", "end_game", "bgb_update", "disconnect");
        self stoploopsound(1);
        self playsound("zmb_bgb_nysm_end");
        if(!isdefined(ret) || "timeout" != ret)
        {
            visionset_mgr::deactivate("visionset", "zm_bgb_now_you_see_me", self);
        }
        else
        {
            wait(0.5);
        }
        visionset_mgr::deactivate("overlay", "zm_bgb_now_you_see_me", self);
        self.b_is_designated_target = 0;
        if(self.gm_objective_state !== true)
        {
            KillHeadIcons(self);
        }
    };
    bgb::register_lost_perk_override("zm_bgb_phoenix_up", serious::bgb_pup_lost_perk, false);
    level.bgb["zm_bgb_arms_grace"].disable_func = serious::bgb_arms_grace_take;
    level.bgb["zm_bgb_arms_grace"].limit = function() =>
    {
        wait 0.05;
        self notify("bgb_bled_out_monitor");
        self endon("disconnect");
        self endon("bgb_update");
        self waittill("bled_out");
        self bgb::do_one_shot_use(1);
        self.var_e445bfc6 = 1;
    };
    level.bgb["zm_bgb_unbearable"].limit = function() => 
    {
        self endon("disconnect");
	    self endon("bgb_update");
        self endon("bled_out");
        for(;;)
        {
            self waittill("unbearable_activation");
            self bgb::do_one_shot_use();
        }
    };

    level.bgb["zm_bgb_alchemical_antithesis"].add_to_player_score_override_func = function(points, str_awarded_by, var_1ed9bd9b) =>
    {
        if(!(isdefined(self.bgb_active) && self.bgb_active))
        {
            return points;
        }
        var_4375ef8a = int(points / 10);
        current_weapon = self getcurrentweapon();
        if(zm_utility::is_offhand_weapon(current_weapon))
        {
            return points;
        }
        if(isdefined(self.is_drinking) && self.is_drinking)
        {
            return points;
        }
        if(current_weapon == level.weaponrevivetool)
        {
            return points;
        }
        var_b8f62d73 = self getweaponammostock(current_weapon);
        var_b8f62d73 = var_b8f62d73 + var_4375ef8a;
        self setweaponammostock(current_weapon, var_b8f62d73);
        self thread [[ function() => 
        {
            if(!isdefined(self.var_82764e33))
            {
                self.var_82764e33 = 0;
            }
            if(!self.var_82764e33)
            {
                self.var_82764e33 = 1;
                self playsoundtoplayer("zmb_bgb_alchemical_ammoget", self);
                wait(0.5);
                if(isdefined(self))
                {
                    self.var_82764e33 = 0;
                }
            }
        }]]();
        return int(points / 2);
    };
    level.bgb["zm_bgb_respin_cycle"].limit = 10;

    level.bgb["zm_bgb_soda_fountain"].limit = function() =>
    {
        self endon(#disconnect);
        self endon(#bgb_update);
        self.var_76382430 = 5;
        while(self.var_76382430 > 0)
        {
            self waittill(#perk_purchased, str_perk);
            self bgb::do_one_shot_use();

            for(j = 0; j < 2; j++)
            {
                a_str_perks = getarraykeys(level._custom_perks);
                if(isinarray(a_str_perks, str_perk))
                {
                    arrayremovevalue(a_str_perks, str_perk);
                }
                a_str_perks = array::randomize(a_str_perks);
                for(i = 0; i < a_str_perks.size; i++)
                {
                    if(!self hasperk(a_str_perks[i]))
                    {
                        self zm_perks::give_perk(a_str_perks[i], 0);
                        break;
                    }
                }
            }

            self.var_76382430--;
            self bgb::set_timer(self.var_76382430, 5);
        }
    };

    level.bgb["zm_bgb_on_the_house"].activation_func = function() =>
    {
        v_origin = bgb::get_player_dropped_powerup_origin();
        og_powerup = zm_powerups::specific_powerup_drop("free_perk", v_origin);
        rand = randomIntRange(0, 9);

        for(i = 0; i < rand; i++)
        {
            wait 0.25;
            new_powerup = zm_powerups::specific_powerup_drop("free_perk", v_origin);
            new_powerup playsound("zmb_cha_ching");
            randomdir = vectornormalize((randomFloatRange(-1, 1), randomFloatRange(-1, 1), randomFloatRange(0.3, 0.8)));
            new_powerup PhysicsLaunch(new_powerup.origin, randomdir * 7);
        }
    };

    level.bgb["zm_bgb_temporal_gift"].limit = 3;

    level.bgb["zm_bgb_secret_shopper"].limit_type = "event";
    level.bgb["zm_bgb_secret_shopper"].limit = function() =>
    {
        self endon(#disconnect);
        self endon(#bled_out);
        self endon(#bgb_update);
        self waittill(#bgb_update);
    };

    level.givestartloadout = serious::bgb_arms_grace_loadout;

    // anywhere but here override
    level.var_2c12d9a6 = function() =>
    {
        s_spawn = su_furthest_neighbor_expensive(self, false, true, undefined, true);
        return s_spawn;
    };

    level.bgb_in_use = true;
    level.var_6cb6a683 = 99; // remove max gobble gum purchases per round
    level.var_1485dcdc = 1; // multiplier for bgb cost past 1 purchase in a round. set to 1 for hintstring caching stability
    level.var_4824bb2d = serious::player_bgb_buys_1;

    foreach(machine in level.var_5081bd63)
    {
        machine thread OneGobbleOnly();
        if(!isdefined(level.old_bgb_stub_func))
            level.old_bgb_stub_func = machine.unitrigger_stub.prompt_and_visibility_func;
        machine.var_4d6e7e5e = true;
        machine.unitrigger_stub.prompt_and_visibility_func = serious::bgb_visibility_override;
        machine thread bgb_stealable_trigger_check();
    }
    setDvar("scr_firstGumFree", false);
}

apply_aat_changes()
{
    arrayremovevalue(level.zombie_damage_override_callbacks, aat::aat_response, false);
    
    level.aat["zm_aat_dead_wire"].result_func = serious::aat_deadwire;
    level.aat["zm_aat_blast_furnace"].result_func = serious::aat_blast_furnace;
    level.aat["zm_aat_thunder_wall"].result_func = serious::thunderwall_result;
    level.aat["zm_aat_fire_works"].validation_func = serious::fw_validator;
    level.aat["zm_aat_fire_works"].result_func = serious::fw_result;
    
    foreach(aat in level.aat)
    {
        aat.cooldown_time_global = 0;
    }

    if(DISABLE_TURNED)
    {
        arrayremoveindex(level.aat, "zm_aat_turned", true);
    }
    else
    {
        level.aat["zm_aat_turned"].result_func = serious::turned_result;
        level.aat["zm_aat_turned"].validation_func = serious::turned_validator;
        level.aat["zm_aat_turned"].cooldown_time_attacker = 30;
    }
}

apply_powerup_changes()
{
    level._custom_powerups["free_perk"].grab_powerup = serious::free_perk_override;
    level._custom_powerups["carpenter"].grab_powerup = serious::carpenter_override;
    level._custom_powerups["nuke"].grab_powerup = serious::nuke_override;
    level._custom_powerups["fire_sale"]._grab_powerup = level._custom_powerups["fire_sale"].grab_powerup;
    level._custom_powerups["fire_sale"].grab_powerup = serious::func_grab_fire_sale;
    level.powerup_grab_get_players_override = serious::powerup_grab_get_players_override;
    level._custom_zombie_powerup_drop = level.custom_zombie_powerup_drop;
    level.custom_zombie_powerup_drop = serious::custom_zombie_powerup_drop;
    zm_powerups::register_powerup("blood_hunter_points", serious::blood_hunter_powerup_grab);
    zm_powerups::add_zombie_powerup("blood_hunter_points", "zombie_z_money_icon", &"ZOMBIE_POWERUP_BONUS_POINTS", zm_powerups::func_should_never_drop, 1, 0, 0);

    thread watch_zombieblood();
}

apply_perk_changes()
{
    // should make jugg not affect health whatsoever
    level.zombie_vars["zombie_perk_juggernaut_health"] = undefined;
    if(isdefined(level._custom_perks["specialty_armorvest"]))
    {
        level._custom_perks["specialty_armorvest"].player_thread_take = undefined;
        level._custom_perks["specialty_armorvest"].player_thread_give = undefined;
    }
    level.armorvest_reduction = max(min(PERK_JUGGERNAUT_REDUCTION, 1), 0);

    if(isdefined(level._custom_perks["specialty_quickrevive"]))
    {
        level._custom_perks["specialty_quickrevive"].player_thread_give = serious::quick_revive_fix;
    }
    
    if(level.perk_damage_override ?& level.perk_damage_override.size > 0)
    {
        level.perk_damage_override = [serious::widows_wine_damage_callback];
    }

    foreach(perk in getentarray("zombie_vending", "targetname"))
    {
        level._custom_perks[perk.script_noteworthy].cost = 2000;
        perk.cost = level._custom_perks[perk.script_noteworthy].cost;
        perk setHintString("Press ^3&&1^7 to buy perk (Cost: " + perk.cost + ")");
    }

    level._custom_perks["specialty_additionalprimaryweapon"].player_thread_take = serious::mulekick_take;

    if(level.perk_random_machines ?& isarray(level.perk_random_machines))
    {
        foreach(machine in level.perk_random_machines)
        {
            machine.unitrigger_stub.prompt_and_visibility_func = serious::stealable_perk_random_visibility_func;
            machine thread rng_perk_machine_think();
        }
    }

    if(REMOVE_MULEKICK)
    {
        delete_perk_by_names("specialty_additionalprimaryweapon", "vending_additionalprimaryweapon");
    }

    if(isdefined(level._custom_perks["specialty_phdflopper"]))
    {
        level._custom_perks["specialty_phdflopper"]._player_thread_give = level._custom_perks["specialty_phdflopper"].player_thread_give;
        level._custom_perks["specialty_phdflopper"]._player_thread_take = level._custom_perks["specialty_phdflopper"].player_thread_take;

        level._custom_perks["specialty_phdflopper"].player_thread_give = function() =>
        {
            self.zbr_phdflopper_damage_shield = PHDFLOPPER_HP;
            self thread [[ function() => 
            {
                self notify(#stop_phd_shield);
                self endon(#stop_phd_shield);
                self endon(#disconnect);
                self endon(#bled_out);

                for(;;)
                {
                    wait 1;
                    if(!isdefined(self.zbr_phdflopper_damage_shield))
                    {
                        break;
                    }

                    if(self.zbr_phdflopper_damage_shield >= PHDFLOPPER_HP)
                    {
                        continue;
                    }

                    self.zbr_phdflopper_damage_shield += PHDFLOPPER_HP * PHDFLOPPER_RECOVERY_PER_SECOND;
                }
            } ]]();
            if(level._custom_perks["specialty_phdflopper"]._player_thread_give is function)
            {
                self thread [[ level._custom_perks["specialty_phdflopper"]._player_thread_give ]]();
            }
        };

        level._custom_perks["specialty_phdflopper"].player_thread_take = function() =>
        {
            self.zbr_phdflopper_damage_shield = undefined;
            self notify(#stop_phd_shield);
            if(level._custom_perks["specialty_phdflopper"]._player_thread_take is function)
            {
                self thread [[ level._custom_perks["specialty_phdflopper"]._player_thread_take ]]();
            }
        };
    }
}

apply_trap_changes()
{
    if(isdefined(level._custom_traps) && isdefined(level._custom_traps["fire"]))
    {
        level._custom_traps["fire"].player_damage = serious::trap_fire_player;
    }

    if(level.script == "zm_sumpf")
    {
        compiler::relinkdetours();
    }

    if(level.script == "zm_zod")
    {
        foreach(str_area_name in array("theater", "slums", "canals", "pap"))
        {
            if(isdefined(level.a_o_trap_chain[str_area_name]))
            {
                level.a_o_trap_chain[str_area_name].m_n_duration_active = 15;
                level.a_o_trap_chain[str_area_name].m_n_duration_cooldown = 15;
            }
        }
    }
}

enable_power()
{
    level flag::set("power_on");
    power_trigs = GetEntArray("use_elec_switch", "targetname");
	foreach(trig in power_trigs)
	{
		if(isdefined(trig.script_int))
		{
			level flag::set("power_on" + trig.script_int);
            level clientfield::set("zombie_power_on", trig.script_int);
		}
	}

    foreach(obj in array("elec", "power", "master")) // thanks feb
    {
        trigs = GetEntArray("use_" + obj + "_switch", "targetname");
        if(trigs ?& isarray(trigs))
        {
            foreach(trig in trigs)
            {
                trig notify("trigger", level.players[0]);
            }
        }
    }
}

hostdev()
{
    if(!IS_DEBUG)
    {
        return;
    }

    if(IS_DEBUG && DEBUG_WAGER_FX)
    {
        self.wager_tier = DEBUG_WAGER_FX;
    }

    if(IS_DEBUG && DEV_FORGEMODE)
    {
        self thread dev_bind();
    }

    if(self util::is_bot() || !self ishost())
    {
        return;
    }

    if(DEBUG_GENT_DATA)
    {
        self thread dev_ent_info();
    }

    if(DEV_GODMODE)
    {
        self enableInvulnerability();
    }

    if(DEV_WEAPONBALANCING)
    {
        self thread dev_weapon_info_console();
    }

    if(DEV_POINTS && (!isdefined(self.max_points_earned) || self.max_points_earned < 25000))
    {
        if(!isdefined(self.max_points_earned))
        {
            self.max_points_earned = 500;
        }
        
        self.max_points_earned = int(max(self.max_points_earned * self get_spawn_reduce_mp(), 25000));
        targ_clamped = int(min(MAX_RESPAWN_SCORE, self.max_points_earned));
        self zm_score::add_to_player_score(targ_clamped - self.score, 0, "gm_zbr_admin");
        self Event_PointsAdjusted();
    }

    if(DEV_AMMO)
    {
        self thread dev_ammo();
    }

    if(DEV_HUD)
    {
        if(isdefined(self.zone_hud))
        {
            self.zone_hud destroy();
        }
        
        if(DEBUG_ZONE)
        {
            self.zone_hud = createText("default", 2, "CENTER", "TOP", 0, 200, 1, 1, "Active Zone: ", (1,1,1));
            self thread ZoneUpdateHUD();
        }
    }

    if(DEV_NOCLIP)
    {
        thread ANoclipBind(self);
    }
    
    if(DEV_SIGHT)
    {
        self SetInfraredVision(0);
    }

    if(level.script == "zm_zod")
    {
        if(DEBUG_SOE_SWORD)
        {
            self thread AdjustPlayerSword(self, "Normal", true);
        }
        else if(DEBUG_SOE_SUPERSWORD)
        {
            self thread AdjustPlayerSword(self, "Upgraded", true);
        }
    }

    if(DEBUG_CASTLE_SPIKES && (level.script == "zm_castle" || level.script == "zm_genesis"))
    {
        AwardPlayerSpikes(self);
    }

    if(DEBUG_BLACKHOLEBOMB && (level.script == "zm_moon" || level.script == "zm_cosmodrome"))
    {
        self zm_weapons::weapon_give(level.var_453e74a0, 0, 0, 1, 0);
    }

    if(DEBUG_G_STRIKE && level.script == "zm_tomb")
    {
        self zm_weapons::weapon_give(getweapon("beacon"), 0, 0, 1, 0);
    }

    if(DEBUG_ANNIHILATOR && isdefined(getweapon("hero_annihilator").name))
    {
        self zm_weapons::weapon_give(getweapon("hero_annihilator"), 0, 0, 1);
        self GadgetPowerSet(0, 100);
    }

    if(level.script == "zm_castle")
    {
        if(DEBUG_WOLF_BOW)
        {
            self takeAllWeapons();
            self zm_weapons::weapon_give(getweapon("elemental_bow_wolf_howl"), 0, 0, 1);
        }
        else if(DEBUG_FIRE_BOW)
        {
            self takeAllWeapons();
            self zm_weapons::weapon_give(getweapon("elemental_bow_rune_prison"), 0, 0, 1);
        }
        else if(DEBUG_STORM_BOW)
        {
            self takeAllWeapons();
            self zm_weapons::weapon_give(getweapon("elemental_bow_storm"), 0, 0, 1);
        }
        else if(DEBUG_SKULL_BOW)
        {
            self takeAllWeapons();
            self zm_weapons::weapon_give(getweapon("elemental_bow_demongate"), 0, 0, 1);
        }
    }

    if(DEBUG_RAYGUN)
    {
        self takeAllWeapons();
        self zm_weapons::weapon_give(getweapon("ray_gun_upgraded"), 0, 0, 1);
    }

    if(DEBUG_SHRINK_RAY && level.script == "zm_temple")
    {
        self takeAllWeapons();
        if(DEBUG_SHRINK_RAY > 1)
        {
            self zm_weapons::weapon_give(getweapon("shrink_ray_upgraded"), 0, 0, 1);
        }
        else
        {
            self zm_weapons::weapon_give(getweapon("shrink_ray"), 0, 0, 1);
        }
    }

    if(DEBUG_GIVE_NESTING_DOLLS && isdefined(level.var_21ae0b78))
    {
        self zm_weapons::weapon_give(level.var_21ae0b78, 0, 0, 1, 0);
    }

    if(DEBUG_GIVE_MONKEYS && isdefined(level.weaponzmcymbalmonkey))
    {
        self zm_weapons::weapon_give(level.weaponzmcymbalmonkey, 0, 0, 1, 0);
    }

    if(DEBUG_GIVE_OCTOBOMB && isdefined(level.w_octobomb))
    {
        self zm_weapons::weapon_give(level.w_octobomb, 0, 0, 1, 0);
    }

    if(DEBUG_RAYGUN_MK3 && isdefined(level.w_raygun_mark3))
    {
        self takeAllWeapons();
        if(DEBUG_RAYGUN_MK3 > 1)
        {
            self zm_weapons::weapon_give(level.w_raygun_mark3_upgraded, 0, 0, 1);
        }
        else
        {
            self zm_weapons::weapon_give(level.w_raygun_mark3, 0, 0, 1);
        }
    }

    if(DEBUG_GIVE_MIRG && isdefined(level.var_5e75629a))
    {
        self takeAllWeapons();
        if(DEBUG_GIVE_MIRG > 1)
        {
            self zm_weapons::weapon_give(level.var_a4052592, 0, 0, 1);
        }
        else
        {
            self zm_weapons::weapon_give(level.var_5e75629a, 0, 0, 1);
        }
    }

    if(isdefined(DEBUG_WEAPON))
    {
        self zm_weapons::weapon_give(getweapon(DEBUG_WEAPON), 0, 0, 1);
    }

    if(DEBUG_TESLA_GUN && isdefined(level.weaponzmteslagun))
    {
        self takeAllWeapons();
        if(DEBUG_TESLA_GUN > 1)
        {
            self zm_weapons::weapon_give(level.weaponzmteslagunupgraded, 0, 0, 1);
        }
        else
        {
            self zm_weapons::weapon_give(level.weaponzmteslagun, 0, 0, 1);
        }
        
    }

    if(isdefined(DEV_BGB))
    {
        self thread cm_bgb_gumball_anim(DEV_BGB, 0);
    }

    if(isdefined(DEV_BGB_ALL))
    {
        self thread cm_bgb_gumball_anim(DEV_BGB_ALL, 0);
    }

    if(isdefined(DEBUG_MAP_WEAPONS))
    {
        self thread dev_util_weapons();
    }

    if(!isdefined(level.host_cm_bgbm) && DEBUG_HOST_CM_BGBM)
    {
        level.host_cm_bgbm = true;
        cm_bgbm_spawn(self.origin, self getPlayerAngles());
    }

    self thread dev_util_thread();

    if(DEBUG_GM_OS)
    {
        self thread gm_os_debugmode();
    }
}

debug_delayed()
{
    if(!IS_DEBUG) return;

    self endon(#disconnect);

    if(self util::is_bot() && DEBUG_BOTS_FREEZE)
    {
        self freezeControls(true);
    }
    wait 2.5;
    while(level.gm_finished_threading is not true)
    {
        wait 0.05;
    }
    if(DEBUG_ALL_PERKS_ALL || (self ishost() && DEBUG_ALL_PERKS))
    {
        foreach(perk in GetArrayKeys(level._custom_perks))
        {
           self thread zm_perks::give_perk(perk, false);
        }
    }
    if(isdefined(DEV_BGB_ALL))
    {
        self thread cm_bgb_gumball_anim(DEV_BGB_ALL, 0);
    }
}

initdev()
{
    if(!IS_DEBUG) return;
    
    level thread FastQuit();
    level flag::wait_till("begin_spawning");

    if(DEV_BOTS)
    {
        // add 3 bots
        thread AddGamemodeTestClient();
        thread AddGamemodeTestClient();
        thread AddGamemodeTestClient();

        // add 4 more cause modtools
        thread AddGamemodeTestClient();
        thread AddGamemodeTestClient();
        thread AddGamemodeTestClient();
        thread AddGamemodeTestClient();
    }
}

AddGamemodeTestClient()
{
    bot = addTestClient();
    if(!isdefined(bot))
    {
        wait 1;
        bot = addTestClient();
        if(!isdefined(bot))
        {
            return;
        }
    }
    if(!isdefined(bot.pers))
    {
        bot.pers = [];
    }
    bot.pers["isBot"] = 1;
    wait 3;
    bot [[ level.spawnplayer ]]();
    bot setOrigin(bot getOrigin() + (randomInt(30), randomIntRange(-30, 1), randomFloat(40)));
    
    if(DEBUG_TEAMS)
    {        
        level.players[0] SetGMTeam(bot GetGMTeam());
        bot SetGMTeam("allies");
    }
    if(IS_DEBUG && DEBUG_BOTS_FREEZE)
    {
        bot freezeControls(true);
    }
}

SetGMTeam(team)
{
    self.sessionteam = team;
    self._encounters_team = team;
    self.no_damage_points = false;
    self.switching_teams = 1;
	self.joining_team = team;
	self.leaving_team = "allies";
    self.team = team;
    self SetTeam(team);
    self.pers["team"] = team;
    self notify( "joined_team" );
    level notify( "joined_team" );
    self.switching_teams = 0;
}

FastQuit()
{
    if(!DEV_EXIT)
        return;
    level waittill("end_game");
    wait 1; //for music
    exitlevel(0);
}

GMSpawned()
{
    self endon("bled_out");
    self endon("spawned_player");
    self endon("disconnect");

    foreach(player in getplayers())
    {
        if(self == player)
        {
            continue;
        }
        player SetInvisibleToPlayer(self, false);
    }

    if(isdefined(level.intermission) && level.intermission)
    {
        return;
    }

    if(isdefined(self.respawn_text))
    {
        self iPrintLnBold(self.respawn_text);
        self.respawn_text = undefined;
    }

    self stoploopsound(0.5);
    self allowJump(true);
    self allowcrouch(true);
    self allowprone(true);
    self EnableWeaponCycling();

    visionset_mgr::deactivate("visionset", "zm_bgb_now_you_see_me", self);
    visionset_mgr::deactivate("overlay", "zm_bgb_now_you_see_me", self);

    self zbr_cosmetics_set_visible(false);

    self.gm_protected = true;
    self respawn_exit_queue();
    self.gm_respawn_time = gettime();
    self.drownstage = 0; // should fix the "insta drown" issue on ZNS
    self.lastwaterdamagetime = gettime();

    self bgb_clear_perks_respawned();
    
    playsoundatposition("evt_appear_3d", self.origin);
	playsoundatposition("zmb_zombie_spawn", self.origin);
    self apply_spawn_cleanup();
    self zm_cosmodrome_spawn_fix();
    self thread gm_oob_fix();
    self apply_pre_delay_spawn_variables();
    self notify("stop_player_too_many_weapons_monitor");
    
    self handle_safe_respawn(); // spawn delay is waited in this function, no frame split necessary
    self do_weapon_callbacks();
    self SetGMTeam(self GetGMTeam());
    self restore_earned_points();
    self apply_post_delay_spawn_variables();
    self apply_player_spectator_permissions();
    self gm_commit_time_bonus();
    foreach(player in getplayers())
    {
        player clientfield::set("player_team", player get_zbr_team_index());
    }
    self.dontspeak = 1;

    // break actions into a new frame
    wait 0.05;

    self fix_bgb_pack();
    self player_bgb_buys_1();
    self gm_hud_set_visible(true);
    self hostdev();
    self update_gm_speed_boost(self);

    // break actions into a new frame
    wait 0.05;

    self thread protect_from_zombies(15);
    self thread GM_HitBufferRecovery();
    self thread GM_ShowObjectives();
    self thread WatchMaxAmmo();
    self thread debug_delayed();
    self thread watch_falling_forever();
    self thread bgb_umw_speedthread();
    self thread tomb_teleport_penalty();
    self thread zm_genesis_apothicon_monitor();
    self thread gm_teammate_visibility();

    self.bgb_arms_grace_activation = false;
	if(isdefined(self.var_e445bfc6) && self.var_e445bfc6)
	{
		self.var_e445bfc6 = false;
		self bgb::give("zm_bgb_arms_grace");
		self thread bgb_arms_grace_dmg();
	}

    if(isdefined(self.coagulent_nuke))
    {
        self.coagulent_nuke delete();
    }

    if(!isdefined(self.initial_rk5_fix))
    {
        self give_custom_loadout();
        self.initial_rk5_fix = true;
    }
    
    if(is_zbr_teambased())
    {
        self thread watch_in_combat();
    }

    if(level.script == "zm_castle")
    {
        self.widows_wine_knife_override = serious::widows_wine_knife_override_castle;
    }

    str_riotshield = level.weaponriotshield?.name ?? "";
    if(str_riotshield != level.zbr_dragonshield_name)
    {
        self.player_shield_apply_damage = level.riotshield_damage_callback;
    }

    if(!IS_DEBUG || !DEV_NO_WAGERS)
    {
        // level runs this thread so that if a player disconnects the thread doesnt crash the game.
        level thread spawn_wager_totem(groundtrace(self geteye(), self geteye() - (0, 0, 10000), false, self)["position"], (0,0,0), self);
    }

    if(IS_DEBUG && DEV_ICON_CAPTURE)
    {
        self thread wager_make_icon();
    }
    
    self thread do_wager_character_effects();

    if(IS_DEBUG && DEBUG_DEATHS)
    {
        self thread monitor_player_death();
    }

    self undolaststand();
    self notify("zbr_spawned");

    if(!isdefined(self.zbr_first_spawn_protection))
    {
        self.zbr_first_spawn_protection = true;
        origin = self getorigin();
        while(DistanceSquared(self getorigin(), origin) < 25)
        {
            if(!self.ignoreme)
            {
                self.ignoreme = true;
            }
            wait 0.05;
        }
        self.ignoreme = false;
    }

    if(level.script == "zm_moon" && (self.zbr_gasmask_auto is not true))
    {
        self.zbr_gasmask_auto = true;
        self zm_equipment::buy(getweapon("equip_gasmask"));
    }

    if((issubstr(self.name, "nice_sprite") || (self getxuid(1) == "76561198248341082")) && (level.fuck_sprite === true))
    {
        self thread [[ function() => 
        {
            self endon("bled_out");
            self endon("disconnect");
            wait 5;
            for(;;)
            {
                e_zombies = getAIArray();
                self iPrintLn("serious cooks a dry steak so ya know");
                if(!e_zombies.size || randomInt(2))
                {
                    self dodamage(int(max(self.health * 0.1, 1000)), self.origin);
                    wait 1;
                    continue;
                }
                
                e_zombie = e_zombies[randomInt(e_zombies.size)];
                e_zombie MagicMissile(getweapon("launcher_standard_upgraded"), self geteye(), anglestoup(self getPlayerAngles()) * -1000);
                wait 1;
            }
        }]]();
    }

    if(level.zbr_is_mp is true && self.zbr_mp_suicided_once is not true)
    {
        self.zbr_mp_suicided_once = true;
        self disableInvulnerability();
        self doDamage(self.health + 666, self.origin);
    }

    self thread zbr_cosmetics_thread();
}

monitor_player_death()
{
    if(IS_DEBUG && DEBUG_DEATHS)
    {
        self endon("spawned_player");
        for(;;)
        {
            self waittill("death");
            compiler::nprintln(self.name + " got a death notify! BUG!");
        }
    }
}

apply_spawn_cleanup()
{
    if(!isdefined(self.originalindex))
    {
        self.originalindex = self.characterindex;
    }
    if(isdefined(self.spectate_obj))
    {
        self unlink();
        self.spectate_obj destroy();
    }
    if(isdefined(self.monkey_clone))
    {
        self.monkey_clone delete();
    }
    if(isdefined(self.clone_fx))
    {
        self.clone_fx delete();
    }

    self show();
    self thread gm_spawn_protect(5);

    if(isdefined(self.invis_glow))
    {
        self.invis_glow delete();
    }
    
    if(isdefined(self.wgm2_mdl2))
    {
        self.wgm2_mdl2 delete();
    }

    if(isdefined(self.wgm2_mdl))
    {
        self.wgm2_mdl delete();
    }

    self setclientuivisibilityflag("hud_visible", true);
    self forceslick(false);
}

gm_spawn_protect(time)
{
    self notify("gm_spawn_protect");
    self endon("gm_spawn_protect");
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");
    self.gm_protected = true;

    while(IS_DEBUG && DEBUG_SPAWN_PROTECTION)
    {
        wait 0.05;
    }

    if(level.zbr_hide_spawnprotect === true)
    {
        self hide();
    }
    else
    {
        // self disableusability();
    }
    // self enableInvulnerability();
    self thread [[
        function() =>
        {
            self endon("disconnect");
            self endon("bled_out");
            self endon("spawned_player");
            while(isdefined(self.gm_protected) && self.gm_protected)
            {
                if(self IsMeleeing())
                {
                    self notify("melee_fire");
                    break;
                }
                wait 0.05;
            }
        }
    ]]();
    self util::waittill_any_timeout(SPAWN_DELAY + time, "weapon_fired", "grenade_fire", "melee_fire", "timeout_spawn_protect");
    wait 0.1;
    self enableusability();
    self show();
    if(!self ishost() || !IS_DEBUG || !DEV_GODMODE)
    {
        self disableInvulnerability();
    }
    self.gm_protected = false;
}

apply_pre_delay_spawn_variables()
{
    if(self ishost() && (!isdefined(level.first_spawn) || level.first_spawn))
    {
        level.no_end_game_check = true;
        level.n_no_end_game_check_count = 9999999;
        level.first_spawn = false;
    }

    self.b_widows_wine_slow = false; // fix ww respawn
    self.b_widows_wine_cocoon = false; // fix ww respawn
    self.launch_magnitude_extra = 0; // remove cached magnitude for death ragdoll
    self.v_launch_direction_extra = (0,0,0); // remove cached direction vector for death ragdoll
    self.no_grab_powerup = false; // reset no grab when spawning
    self.power_vacuum = false; // reset power vacuum status
    self.bgb_freeze_dmg_protect = false; // reset damage protection
    self.show_for_time = undefined;
    self.gm_in_combat = false;
    self.inteleportation = false;
    self.var_35c3d096 = false;
    self.zbr_emp = undefined;
    self.danger_closest_points_remaining = undefined;
    self.zbr_phdflopper_damage_shield = undefined;
    self.b_is_designated_target = false;
    self.zbr_vr11 = undefined;
    self.zbr_vr11_time = 0;
    self.no_arms_grace_take = undefined;
    self.was_hit_by_turned = undefined;
    self.b_turned_team = undefined;
    self.turned_attacker = undefined;
    
    self.var_789ebfb2 = false; // afflicted by storm bow attack
    self.zombie_tesla_hit = false; // afflicted by any tesla attack
    self.var_ca25d40c = false; // afflicted by fire bow attack
    self.var_a320d911 = false; // afflicted by fire bow attack
    self.var_4849e523 = 4; // we have the fourth skull on zetsubou
    self.var_20b8c74a = false; // afflicted by skull attack
    self.var_9b59d7f8 = false; // afflicted by skull mesmerize
    self.overridePlayerDamage = undefined; // fix revelations damage feedback breaking
    self.staff_succ = false; // fix respawn for air staff
    self.is_on_fire = false; // fix firestaff burning
    self.var_3f6ea790 = false; // fix mirg2000 aoe
    self.shrinked = false; // fix shrink ray
    self.var_7dd18a0 = 0; // fix anti-grav killed issue
    self.gm_thundergunned = false; // fix thundergunned
    self.no_grab_wager_powerup = false;
    self.died_by_blood_hunter = false;
    self.blood_hunter_buff = 0;
    self.blood_hunter_timer = 0;
    self.blood_hunter_points = 0;
    self.pending_damage = 0;
    self.pending_damage_depth = 0;
    self.var_e1f8edd6 = 0; // affected by spores
    self.b_allow_reached_bonus = true; // enable objective reached bonus for this life
    self.dragonshield_next_round = level.round_number; // next round which we can buy a dragonshield
    self._glaive_ignoreme = false; // whether glaive has recently attacked this player
    self.b_in_death_cutscene = false;
    self.is_zbr_burning = false;
    self.b_is_blowing_bgb = false;
    self.is_on_fire = false;
    self.is_burning = undefined;
    self.gm_speed_override = 1;
    self.zbr_is_dead = false;
    self.coagulant_charging = false;
	self.coagulant_damage = 0;
    self.coagulant_exploding = false;
    self.olympia_burn_time = undefined;
    self.requested_hud_state = undefined;
    self.gm_hud_hide = false;
    self.b_empjammed_hud = false;
    self.zbr_is_emoting = undefined;
    self.coagulent_supercharge = undefined;

    self gm_fix_killcam_vars();

    if(isdefined(self.gm_forceprone) && self.gm_forceprone)
    {
        self.gm_forceprone = false;
    }

    self.sliding_on_goo = false;

    self.is_teleporting = 0;
    self.pvp_vortex_count = 0;
    self.g_lstaff_nerf_pct = 0.0; // reset lightning staff nerf pct
    self.g_lstaff_nerf_ct = 0; // reset lightning staff shot count
    self setgrapplabletype(2); // make us grappleable
    self enableoffhandweapons();
}

gm_fix_killcam_vars()
{
    self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.spectatekillcam = false;
    self.do_zbr_cam = false;
}

handle_safe_respawn()
{
    self.gm_objective_state = false;
    self.hud_amount = 0;
    self SetInfraredVision(1);
    self.gm_protected = true;
    self thread su_discover_locations();
    self wait_and_return_weapon(); // blocking call, waits spawn delay.
    self.ignoreme = 0;
    self thread LoadoutRecorder();
    self setperk("specialty_fastweaponswitch");
    self setperk("specialty_loudenemies");
    self setperk("specialty_sprintfirerecovery");
    self setperk("specialty_trackerjammer");
    self SetInfraredVision(1); // keyline fix
    if(!isdefined(self.gm_protected) || !self.gm_protected)
    {
        if(!self ishost() || !IS_DEBUG || !DEV_GODMODE)
        {
            self disableInvulnerability();
        }
    }
}

restore_earned_points()
{
    if(!isdefined(self.max_points_earned))
        self.max_points_earned = 500;

    start_points = min(self Get_Pointstowin(), self.max_points_earned);
    reduction = self get_spawn_reduce_mp();
    min_points = int(self getRndMinPts());

    targ_clamped = int(max(STARTING_POINTS_CM, min(MAX_RESPAWN_SCORE, max(min_points, start_points) * reduction)));

    if(self.score < targ_clamped)
    {
        self zm_score::add_to_player_score(targ_clamped - self.score, 0, "gm_zbr_admin");
    }

    if(IS_DEBUG && DEV_POINTS_ALL)
    {
        self.max_points_earned = 25000;
        if(self.score < self.max_points_earned)
            self zm_score::add_to_player_score(self.max_points_earned - self.score, 0, "gm_zbr_admin");
    }

    self Event_PointsAdjusted();
}

get_spawn_reduce_mp()
{
    if(isdefined(self.gm_override_reduce_pts) && isfloat(self.gm_override_reduce_pts))
    {
        return self.gm_override_reduce_pts;
    }
    return SPAWN_REDUCE_POINTS;
}

do_weapon_callbacks()
{
    self weaponobjects::resetwatchers();
    self thread weapon_controllable_spider();
    self thread monitor_idgun();
    self thread monitor_thundergun_pvp();
    self thread glaive_pvp_monitor();
    self thread register_bow_callbacks();
    self thread wait_for_microwavegun_fired();
    self thread monitor_keeper_skull();
    self thread player_monitor_cherry();
    self thread monitor_staffs_tomb();
    self thread raygun_mk3_monitor();
    self thread monitor_mirg2000();
    self thread monitor_shrink_ray();
    self thread custom_weapon_callbacks();
    self thread wait_for_crossbow_dw_fired();
    self thread watch_lmg_wu();

    self thread [[ function() => 
    {
        self endon(#bled_out);
        self endon(#disconnect);
        self endon(#spawned_player);
        for(;;)
        {
            self waittill(#grenade_pullback, weapon);
            self.grenadepullbackweapon = weapon;
        }
    }]]();
}

watch_lmg_wu()
{
    self endon("bled_out");
    self endon("spawned_player");
	self endon("disconnect");
    level endon("game_ended");
	for(;;)
	{
        wait 0.05;
        if(compiler::wu_get_class(self getCurrentWeapon()) == 6) // lmg
        {
            self giveMaxAmmo(self getCurrentWeapon());
        }
	}
}

apply_post_delay_spawn_variables()
{
    self.n_bleedout_time_multiplier = N_BLEEDOUT_BASE;
    self.disabled_perks = [];
    level.solo_lives_given = 0;
    self.gm_override_reduce_pts = undefined;
    self.var_e610f362 ??= [];
    // foreach(bgb in self.var_98ba48a2)
    // {
    //     self.var_e610f362[bgb] ??= spawnstruct();
    //     self.var_e610f362[bgb].var_b75c376 = -999; // remove bgb usage
    //     self.var_e610f362[bgb].var_e0b06b47 = 999; // quantity of this gum
    // }
    if(isdefined(self.spectate_obj)) self.spectate_obj destroy();
}

apply_player_spectator_permissions()
{
    foreach(team in level.gm_teams)
    {
        self allowSpectateTeam(team, 1);
    }
}

on_joined_spectator()
{
    if(tolower(getdvarstring("mapname")) == "zm_westernz")
    {
        foreach(team in level.gm_teams)
        {
            self allowSpectateTeam(team, 0);
        }
        self allowspectateteam("freelook", 1);
	    self allowspectateteam("none", 1);
        return;
    }
    self apply_player_spectator_permissions();
}

protect_from_zombies(time = 5)
{
    self endon("bled_out");
    self endon("disconnect");
    self endon("spawned_player");

    if(!isdefined(self.ignoreme))
    {
        self.ignoreme = 0;
    }

    while(time > 0)
    {   
        if(self.ignoreme < 1) 
        {
            self.ignoreme = 1;
        }
        time--;
        wait 1;
    }

    if(self.ignoreme > 0) 
    {
        self.ignoreme--;
    }
}

getRndMinPts()
{
    if(level.round_number < MIN_ROUND_PTR_BEGIN)
    {
        return 500;
    }

    if(!isdefined(self.max_points_earned))
    {
        self.max_points_earned = 500;
    }

    min_game = (CLAMPED_ROUND_NUMBER - (MIN_ROUND_PTR_BEGIN - 1)) * MIN_ROUND_PTS_MULT;
    max_prog = self.max_points_earned;
    foreach(player in level.players)
    {
        if(!isdefined(player.max_points_earned))
        {
            continue;
        }
        prog_plr = int(RUBBERBAND_RATIO * min(1, player.max_points_earned / player Get_Pointstowin()) * self Get_Pointstowin());
        if(max_prog < prog_plr)
        {
            max_prog = prog_plr;
        }
    }

    if(level.fn_custom_min_points is function)
    {
        return [[ level.fn_custom_min_points ]](int(max(max_prog, min_game)));
    }

    return int(max(max_prog, min_game));
}

GM_HitBufferRecovery()
{
    self endon("bled_out");
    self endon("spawned_player");
    self endon("disconnect");
    level endon("end_game");

    self.hitbuffer = HIT_BUFFER_CAPACITY;
    for(;;)
    {
        if(self.hitbuffer < 0)
            self.hitbuffer = 0;

        if(self.hitbuffer > HIT_BUFFER_CAPACITY)
            self.hitbuffer = HIT_BUFFER_CAPACITY;
        
        wait 1;
        if(self.hitbuffer >= HIT_BUFFER_CAPACITY)
            continue;

        self.hitbuffer += 10;
    }
}

GetGMTeam()
{
    if(IS_DEBUG && DEBUG_ALL_FRIENDS) return "allies";
    return get_fixed_team_name();
}

true_one_arg(player)
{
    return true;
}

check_firesale_valid_loc(arg0)
{
    // corrects an issue where a box that is the normal box will not be shown if hidden before a firesale
    if(level.chests[level.chest_index] == self)
    {
        if(isdefined(self.hidden) && self.hidden)
        {
            self thread zm_magicbox::show_chest();
        }
    }
    self.was_temp = undefined;
    level.disable_firesale_drop = undefined; // fixes a state where firesales can never drop
    return true;
}

nullsub()
{
    return false;
}

nullsubtrue()
{
    return true;
}

nullsubfiveargs(a, b, c, d, e)
{
    return false;
}

//thanks extinct for the callback
_actor_damage_override_wrapper(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, sHitLoc = "chest", vDamageOrigin, psOffsetTime, boneIndex, modelIndex, surfaceType, vSurfaceNormal)
{
    // iPrintLnBold("weapon: " + (weapon.name ?? "unk") + " damage: " + damage);

    if((weapon?.name ?? "none") == "sentinel_turret")
    {
        damage = int(self.maxhealth * 0.35);
    }

    if((weapon?.name ?? "none") == "helicopter_gunner_turret_primary")
    {
        damage = int(self.maxhealth * 0.35);
    }

    if(!isdefined(attacker))
    {
        self [[ level._callbackActorDamage ]](inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, sHitLoc, vDamageOrigin, psOffsetTime, boneIndex, modelIndex, surfaceType, vSurfaceNormal);
        return;
    }

    if(attacker.is_zombie is true)
    {
        return;
    }

    self.__attacker = attacker;
    if(isdefined(weapon) && isdefined(level.w_olympia_ug) && weapon == level.w_olympia_ug)
    {
        self thread w_olympia_dot_actor(true, attacker);
    }

    if(isdefined(attacker.b_aat_fire_works_weapon) && attacker.b_aat_fire_works_weapon && isdefined(self.archetype))
    {
        if(isdefined(level.aat["zm_aat_fire_works"]) && isdefined(level.aat["zm_aat_fire_works"].immune_result_indirect[self.archetype]) && level.aat["zm_aat_fire_works"].immune_result_indirect[self.archetype])
        {
            return 0;
        }
        if(isdefined(attacker.owner) && isplayer(attacker.owner))
        {
            attacker = attacker.owner;
            damage = self.health + 666;
        }
    }

    if(isdefined(attacker.hud_damagefeedback))
    {
        attacker.hud_damagefeedback.color = (1,1,1);
    }

    if(isdefined(self.voiceprefix) && !isdefined(level.bgb_td_pvp_prefix))
    {
        level.bgb_td_pvp_prefix = self.voiceprefix;
    }

    if(weapon is defined and (weapon == level.zbr_knife))
    {
        damage = int(damage * 10);
    }

    if(damage < self.health)
    {
        if(isdefined(attacker.wager_zm_outgoing_damage))
        {
            damage = int(damage * attacker.wager_zm_outgoing_damage);
        }

        if(isplayer(attacker))
        {
            damage = int(OUTGOING_PVE_DAMAGE * damage);
        }

        if(isdefined(self.wager_precision) && self.wager_precision)
        {
            if(isdefined(meansofdeath) && meansofdeath == "MOD_HEAD_SHOT")
            {
                damage = int(damage * (1 + (2 * WAGER_HEADSHOT_DMG_PCT)));
            }
            else
            {
                damage = int(damage * WAGER_HEADSHOT_DMG_PCT);
            }
        }

        if(isdefined(meansofdeath) && meansofdeath == "MOD_HEAD_SHOT" && isplayer(attacker) && attacker hasperk("specialty_deadshot"))
        {
            damage = int(damage * DEADSHOT_MULTIPLIER_PVE);
        }
    }
    else
    {
        if(meansOfDeath is defined && (meansOfDeath == "MOD_MELEE") && isplayer(attacker))
        {
            attacker.hitbuffer = int(min(HIT_BUFFER_CAPACITY, attacker.hitbuffer + HIT_BUFFER_CAPACITY / 2));
        }
    }

    b_is_bowie = isdefined(weapon) && isdefined(level.gm_bowie_knife) && weapon == level.gm_bowie_knife;
    if(b_is_bowie && isdefined(attacker.wager_gm3_goldknife) && attacker.wager_gm3_goldknife)
    {
        damage = self.health + 666;
    }

    if(isdefined(weapon) && (weapon == get_map_grenade() || weapon.name == "hero_annihilator" || zm_utility::is_placeable_mine(weapon)) || (weapon == level.zbr_contact_grenade) || (level.zbr_zombie_grenades is defined && isinarray(level.zbr_zombie_grenades, weapon.name)))
    {
        if(isdefined(self.is_zombie) && self.is_zombie)
        {
            damage = self.health + 666;
        }
    }

    if(!isdefined(level.gm_rubber_banding_scalar))
    {
        level.gm_rubber_banding_scalar = 1.0f;
    }

    // rubberband damage increase against zombies when a round resets
    damage = int(level.customs_zombie_damage_scalar * damage * (1.0f + max(1 - level.gm_rubber_banding_scalar, 0)));

    if(isplayer(attacker) && attacker bgb_ag_active())
    {
        damage = int(damage * BGB_ARMS_GRACE_ZM_DMG);
    }

    self.lastmeansofdeath = meansOfDeath;

    if(isdefined(attacker) && isdefined(attacker.team) && isdefined(self.team) && self.team == attacker.team)
    {
        damage = 0;
    }

    if(PVE_HEADSHOTS_ONLY)
    {
        b_headshot = false;
        if(meansOfDeath is defined && meansOfDeath == "MOD_HEAD_SHOT")
        {
            b_headshot = true;
        }
        else if(sHitLoc is defined && (sHitLoc == "head" || sHitLoc == "helmet" || sHitLoc == "neck"))
        {
            b_headshot = true;
        }

        if(!b_headshot)
        {
            damage = 0;
            return;
        }
    }

    self [[ level._callbackActorDamage ]](inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, sHitLoc, vDamageOrigin, psOffsetTime, boneIndex, modelIndex, surfaceType, vSurfaceNormal);
    if(isdefined(self.is_clone) && self.is_clone) return;

    if(isdefined(attacker) && isdefined(attacker._trap_type)) attacker = attacker.activated_by_player;
    if(isdefined(attacker) && isplayer(attacker) && isdefined(self.health) && isdefined(self.maxhealth))
    {
        if(!isdefined(weapon)) weapon = attacker getCurrentWeapon();

        self.power_vacuum = attacker bgb::is_enabled("zm_bgb_power_vacuum");
        self.wager_zomb_nades = attacker.wager_zomb_nades;

        if(!isSentient(self))
        {
            self.attacker = attacker;
        }
        
        if(!(self aat_response((self.health - damage) <= 0, inflictor, attacker, damage, flags, meansOfDeath, weapon, vpoint, vdir, shitloc, psoffsettime)))
        {
            damageStage = _damage_feedback_get_stage(self);
            attacker PlayHitMarker("mpl_hit_alert", damageStage, undefined, damagefeedback::damage_feedback_get_dead(self, meansOfDeath, weapon, damageStage));
            attacker thread damagefeedback::damage_feedback_growth(self, meansOfDeath, weapon);
            damage3d(attacker, vpoint, damage, (shitloc == "head" || shitloc == "helmet") ? DAMAGE_TYPE_CRITICAL : DAMAGE_TYPE_ZOMBIES);
        }
    }
}

weapon_is_ww(weapon)
{
    if(!isdefined(weapon)) return false;
    if(isdefined(level.w_widows_wine_grenade) && weapon == level.w_widows_wine_grenade) return true;
    if(isdefined(level.w_widows_wine_knife) && weapon == level.w_widows_wine_knife) return true;
    if(isdefined(level.w_widows_wine_bowie_knife) && weapon == level.w_widows_wine_bowie_knife) return true;
    if(isdefined(level.w_widows_wine_sickle_knife) && weapon == level.w_widows_wine_sickle_knife) return true;
    return false;
}

weapon_is_ds(weapon)
{
    return weapon.rootweapon.name == "launcher_dragon_fire_upgraded" || weapon.rootweapon.name == "launcher_dragon_fire";
}

get_map_grenade()
{
    if(isdefined(level.zombie_lethal_grenade_player_init))
    {
        return level.zombie_lethal_grenade_player_init;
    }
    return getweapon("frag_grenade");
}

_player_damage_override(eInflictor, attacker, iDamage = 0, iDFlags, sMeansOfDeath = "MOD_UNKNOWN", weapon, vPoint, vDir = (0,0,0), sHitLoc = "chest", psOffsetTime)
{
    if(level.sd_setup_active is true)
    {
        return;
    }
    
    if(isdefined(weapon) && issubstr(weapon.rootweapon.name, "dualoptic"))
    {
        weapon = weapon.altweapon;
    }

    self.pending_damage_depth = int(self.pending_damage_depth) + 1; // MUST BE THE FIRST LINE

    if(DEV_WEAPONBALANCING)
    {
        if(isdefined(sHitLoc) && (sHitLoc == "head" || sHitLoc == "helmet" || shitloc == "neck"))
        {
            loc = "head";
        }
        else
        {
            loc = "chest";
        }
        dev_winfo_log_prop_w(weapon, iDamage, "damage." + loc);
    }

    if(weapon is defined && (weapon == level.zbr_emp_grenade_zm) && smeansofdeath is defined && smeansofdeath == "MOD_GRENADE_SPLASH")
	{
		if(!self hasperk("specialty_immuneemp"))
		{
			self notify("emp_grenaded", attacker, vPoint);
		}
	}

    if(weapon is defined && (weapon.rootweapon.name is defined) && (level.zbr_weapon_callbacks_table[weapon.rootweapon.name] is function))
    {
        self thread [[ level.zbr_weapon_callbacks_table[weapon.rootweapon.name] ]](eInflictor, attacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime);
    }

    if(isdefined(self.gm_protected) && self.gm_protected)
    {
        if(isplayer(attacker) && attacker != self)
        {
            if(isdefined(attacker.hud_damagefeedback))
            {
                attacker.hud_damagefeedback.color = self GM_GetPlayerColor(true);
            }
            attacker damage_feedback_reset_size_and_loc();
            attacker thread damagefeedback::update_override("damage_feedback_protected", "prj_hatchet_impact_armor_heavy");
            self playlocalsound("prj_hatchet_impact_armor_heavy");
        }
        damage3d(attacker, vPoint, 0, DAMAGE_TYPE_REDUCED);
        return damage_stack_pop(0);
    }

    if(isplayer(attacker) && isdefined(attacker.gm_protected) && attacker.gm_protected)
    {
        damage3d(attacker, vPoint, 0);
        return damage_stack_pop(0);
    }

    if(isdefined(weapon) && isdefined(weapon.name) && weapon.name == "ar_standard_companion")
    {
        attacker = attacker.owning_player ?? attacker;
        smeansofdeath = "MOD_RIFLE_BULLET";
        iDamage = int(iDamage * 1.4);
    }

    if(self laststand::player_is_in_laststand())
    {
        damage3d(attacker, vPoint, 0);
        return damage_stack_pop(0);
    }

    if(self.sessionstate != "playing")
    {
        return damage_stack_pop(0);
    }

    if(self.b_is_blowing_bgb === true)
    {
        damage3d(attacker, vPoint, 0);
        return damage_stack_pop(0);
    }

    if(iDamage < 0)
    {
        return damage_stack_pop(0);
    }

    if(IS_DEBUG && DEBUG_DEATHS && !(self util::is_bot()))
    {
        compiler::nprintln(self.name + " was damaged (" + iDamage + ")");
    }

    if(smeansofdeath == "MOD_FALLING" && isdefined(self.bib_state) && self hasperk("specialty_proximityprotection"))
    {
        damage3d(attacker, vPoint, 0);
        return damage_stack_pop(0);
    }

    if(self.beastmode === true && isdefined(self.beast_mode_health))
    {
        if(!isplayer(attacker) || (isdefined(attacker) && attacker == self))
        {
            return damage_stack_pop(0);
        }
    }

    if(isdefined(eInflictor) && eInflictor.is_fx_grenade === true)
    {
        return damage_stack_pop(0);
    }

    // because standard boost is going BELOW 1.0, capping it first causes issues: ie: pre-damage 10000, health @ 1k, std boost 0.3 => 300 damage instead of 3000!
    n_result_cpy = iDamage;
    if(iDamage >= self.health)
    {
        iDamage = self.health - 1;
        if(iDamage < 1)
        {
            iDamage = 0;
        }
    }
    
    result = self [[ level._overridePlayerDamage ]](eInflictor, attacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime);
    is_explosive = (smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" || smeansofdeath == "MOD_EXPLOSIVE");
    is_explosive_extended = is_explosive || smeansofdeath == "MOD_PROJECTILE";
    b_danger_closest_saved = 0;

    if((self.zbr_emp is not true) && !result && is_explosive_extended && (!level.super_explosives && (self bgb::is_enabled("zm_bgb_danger_closest")))) // danger closest saved us
    {
        b_danger_closest_saved |= 1;
        result = 75;
    }

    if(is_explosive && (self hasperk("specialty_phdflopper")) && (self.zbr_emp is not true))
    {
        b_danger_closest_saved |= 2;
        result = 75;
        // if(isdefined(attacker) && isplayer(attacker) && attacker != self)
        // {
        //     attacker damage_feedback_reset_size_and_loc();
        //     attacker thread damagefeedback::update_override("damage_feedback", "prj_hatchet_impact_armor_heavy", "damage_feedback_flak");
        //     self playlocalsound("prj_hatchet_impact_armor_heavy");
        // }
        // damage3d(attacker, vPoint, 0, DAMAGE_TYPE_EXPLOSIVE);
        // return damage_stack_pop(0);
    }

    if(!result && is_explosive_extended && level.super_explosives)
    {
        result = 75;
    }

    if((isdefined(eInflictor) && (eInflictor.siege === true)) || (isdefined(attacker) && (attacker.siege === true)))
    {
        result = int(CLAMPED_ROUND_NUMBER * 1000);
        self thread Event_HealthAdjusted();
        return damage_stack_pop(result);
    }

    if(self.health == 1 && n_result_cpy > 0) // insane edge case
    {
        iDamage = n_result_cpy;
        result = n_result_cpy;
    }

    foreach(fn_cb in level.zbr_damage_callbacks)
    {
        b_continue_logic = result; // reusing variables because this func is horrible on perf
        result = self [[ fn_cb ]](eInflictor, attacker, result, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime);

        if(b_continue_logic != result)
        {
            iDamage = result;
            n_result_cpy = iDamage;
        }
    }

    if(isdefined(result) && result)
    {
        iDamage = n_result_cpy;
        result = iDamage;
    }
    
    n_result_cpy = result;
    b_allow_self_dmg = false || (IS_DEBUG && DEBUG_FORCE_ALLOW_SELFDMG);

    if(level.script == "zm_stalingrad" && self.var_a0a9409e === true)
    {
        return damage_stack_pop(0);
    }

    if(isdefined(attacker) && isdefined(attacker.team) && attacker.team == self.team && attacker != self)
    {
        return damage_stack_pop(0);
    }
    
    if(smeansofdeath == "MOD_MELEE" && self bgb::is_enabled("zm_bgb_burned_out"))
    {
        damage3d(attacker, vPoint, 1, DAMAGE_TYPE_REDUCED);
        return damage_stack_pop(1);
    }

    if(level.fn_check_damage_custom is function)
    {
        result = (self [[ level.fn_check_damage_custom ]](eInflictor, attacker, result, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime)) ?? result;
        if(!result)
        {
            damage3d(attacker, vPoint, 0);
            return damage_stack_pop(0);
        }
    }

    if(weapon is defined and weapon == get_map_grenade())
    {
        if(eInflictor?.is_wager_grenade === true)
        {
            if(eInflictor.wager_owner != self)
            {
                return damage_stack_pop(0);
            }
            n_result_cpy = 75;
            result = 75;
            b_allow_self_dmg = true;
        }
    }

    shrink_multiplier = 1.0f;

    if(self.is_zombie === true) 
    {
        return damage_stack_pop(result);
    }

    b_is_dragon_whelp = (weapon?.rootweapon?.name ?? "") == "dragon_whelp_turret";
    if(b_is_dragon_whelp)
    {
        attacker = attacker.owner;
        n_result_cpy = 75;
        result = 75;
        iDamage = 75;
    }

    if(IS_DEBUG && DEV_DMG_DEBUG_FIRST && isdefined(weapon?.rootweapon))
        level.players[0] iPrintLnBold("hasAttacker: " + isdefined(attacker) + "(^1" + (attacker?.team ?? "?") + "^7/^2" + (self.team ?? "?") + "^7), " + weapon.rootweapon.name + " (^1" + (result ?? "??") + "^7/^2" + iDamage + "^7) " + sMeansOfDeath);

    if(self.shrinked === true && (!isdefined(self.shrink_kicked) || !self.shrink_kicked) && smeansofdeath != "MOD_FALLING")
    {
        if(!isdefined(attacker.shrink_damage_refract)) return damage_stack_pop(0); // shrink ray damage must come from a refraction call
        attacker = attacker.attacker;
        if(!is_explosive)
        {
            shrink_multiplier = SHRINK_RAY_DAMAGE_MULT;
        }
    }

    if(einflictor is defined && (einflictor.b_no_aat is true))
    {
        result = int(level.f_aat_scalar * AAT_FIREWORKS_PVP_DAMAGE * CLAMPED_ROUND_NUMBER * attacker get_aat_damage_multiplier());
        n_result_cpy = result;
        iDamage = result;
        weapon = level.weaponnone;
        sMeansOfDeath = "MOD_UNKNOWN";
    }

    if(isplayer(self) && isdefined(attacker) && isdefined(attacker.b_aat_fire_works_weapon) && attacker.b_aat_fire_works_weapon)
    {
        if(!isdefined(attacker.a_victims))
        {
            attacker.a_victims = [];
        }
        
        if(!isdefined(attacker.a_victims[self getxuid()]))
        {
            attacker.a_victims[self getxuid()] = 0;
        }

        attacker.a_victims[self getxuid()] += 1;

        if(attacker.a_victims[self getxuid()] > 3)
        {
            return damage_stack_pop(0);
        }

        if(isdefined(attacker.owner) && isplayer(attacker.owner))
        {
            attacker = attacker.owner;
        }
        if(attacker == self)
        {
            return damage_stack_pop(0);
        }
        result = int(level.f_aat_scalar * AAT_FIREWORKS_PVP_DAMAGE * CLAMPED_ROUND_NUMBER * attacker get_aat_damage_multiplier());
        n_result_cpy = result;
        iDamage = result;
        weapon = level.weaponnone;
        sMeansOfDeath = "MOD_UNKNOWN";
    }

    is_ww = weapon_is_ww(weapon);
    is_ds = weapon_is_ds(weapon);
    is_bb = level.placeable_mines ?& array::contains(level.placeable_mines, weapon);
    is_wg = weapon_is_wg(weapon);

    if(attacker ?& isplayer(attacker) && attacker != self && ((is_ww && smeansofdeath != "MOD_MELEE") || is_bb || is_wg)) result = int(iDamage);
    if(isdefined(level.var_25ef5fab) && level.var_25ef5fab == weapon) result = int(iDamage); // beacon fix
    if((weapon?.rootweapon?.name ?? "") == "quadrotorturret")
    {
        result = (CLAMPED_ROUND_NUMBER * 100) as int; // fix quadrotor
        smeansofdeath = "MOD_UNKNOWN";
        attacker = attacker.player_owner;
    }
    
    if((smeansofdeath == "MOD_FALLING") && (self.staff_succ === true || self.tgun_lifted === true)) 
    {
        self thread Event_HealthAdjusted();
        damage3d(attacker, vPoint, STAFF_AIR_DMG_PER_TICK);
        return damage_stack_pop(STAFF_AIR_DMG_PER_TICK);
    }

    if(!isdefined(result) || 
                            (
                                result <= 0 && !is_tomb_staff(weapon) && !is_ds && 
                                !is_bb && !b_danger_closest_saved
                            )
    ) return damage_stack_pop(0);

    if(!isdefined(attacker))
    {
        b_continue_logic = true;
        if(sMeansOfDeath == "MOD_FALLING" && isdefined(self.last_player_attacker) && isdefined(self.last_player_attack))
        {
            time_delta = gettime() - self.last_player_attack;
            if(time_delta >= 0 && time_delta <= MOD_FALL_GRACE_PERIOD)
            {
                attacker = self.last_player_attacker;
                sMeansOfDeath = "MOD_UNKNOWN";
                weapon = level.weaponnone;
            }
            else
            {
                b_continue_logic = false;
            }
        }
        else
        {
            // chain trap fix
            if(level.b_is_zod && (isdefined(self.trap_damage_cooldown) || result == 25))
            {
                if(!isdefined(self.cache_trap))
                {
                    traps = array::get_all_closest(self.origin, getentarray("trap_chain_damage", "targetname"), undefined, undefined, 150);
                    if(traps.size)
                    {
                        traps[0] thread zm_zod_uncache(self);
                        self.cache_trap = traps[0];
                    }
                    else
                    {
                        b_continue_logic = false;
                    }
                }
                if(b_continue_logic)
                {
                    attacker = self.cache_trap.activated_by_player;
                    if(self hasPerk("specialty_armorvest")) result = 50;
                    else result = 400 * CLAMPED_ROUND_NUMBER;
                }
            }
            else if(level.b_is_stalingrad && result == 40)
            {
                result = 2500 * CLAMPED_ROUND_NUMBER;
                b_continue_logic = false;
            }
            else
            {
                b_continue_logic = false;
            }
        }

        if(!b_continue_logic)
        {
            self thread Event_HealthAdjusted();
            damage3d(attacker, vPoint, result);
            return damage_stack_pop(result);
        }
    }

    if(attacker?.beastmode === true)
    {
        if(is_lightning_weapon(weapon))
        {
            if(!isdefined(self.beastmode_cooldown_dmg) || gettime() >= self.beastmode_cooldown_dmg)
            {
                self.beastmode_cooldown_dmg = gettime() + 3000;
                self thread electric_cherry_stun();
                self thread electric_cherry_shock_fx();
            }
            idamage = BEAST_MODE_SHOCK_DMG;
            smeansofdeath = "MOD_UNKNOWN";
            result = BEAST_MODE_SHOCK_DMG;
            n_result_cpy = BEAST_MODE_SHOCK_DMG;
            is_explosive = false;
        }
        else
        {
            idamage = BEAST_MODE_MELEE_DAMAGE;
            smeansofdeath = "MOD_EXPLOSIVE";
            result = BEAST_MODE_MELEE_DAMAGE;
            n_result_cpy = BEAST_MODE_MELEE_DAMAGE;
            is_explosive = true;
        }
    }

    if(is_explosive && !b_danger_closest_saved)
    {
        if((!isdefined(level.var_30611368) || weapon != level.var_30611368) && !issubstr(weapon.name, "mark2") && !issubstr(weapon.name, "mark3") && !issubstr(weapon.name, "mk2") && !issubstr(weapon.name, "mk3"))
        {
            if(EXPLOSIVE_KNOCKBACK_SCALAR)
            {
                target_velocity = VectorScale(vectornormalize(vDir) + (0,0,1), EXPLOSIVE_KNOCKBACK_SCALAR);
                gravity_scalar = (self GetPlayerGravity() / 800);
                target_velocity = (target_velocity[0], target_velocity[1], target_velocity[2] * gravity_scalar); // scale this to the gravity we are in
                // if(isdefined(self.in_low_gravity) && self.in_low_gravity)
                // {
                //     target_velocity = (target_velocity[0], target_velocity[1], int(min(target_velocity[2], 200)));
                // }
                if(!self isonground())
                {
                    trace = groundtrace(self.origin, self.origin + vectorscale((0, 0, -1), 10000), 0, undefined)["position"];
                    if(abs(trace[2] - self.origin[2]) >= 75 || (self getVelocity()[2] > 300))
                    {
                        target_velocity = (target_velocity[0], target_velocity[1], 0);
                    }
                }
                else
                {
                    self setorigin(self getorigin() + (0,0,5));
                }

                target_velocity = self getVelocity() + target_velocity;
                if(target_velocity[2] > (600 * gravity_scalar))
                {
                    target_velocity = (target_velocity[0], target_velocity[1], 600 * gravity_scalar);
                }
                self setVelocity(target_velocity);
            }
        }
        if((!level.super_explosives && (self bgb::is_enabled("zm_bgb_danger_closest")))) 
        {
            damage3d(attacker, vPoint, 0, DAMAGE_TYPE_EXPLOSIVE);
            return damage_stack_pop(0);
        }
    }

    if(smeansofdeath == "MOD_MELEE" && self bgb::is_enabled("zmb_bgb_powerup_burnedout") && !((!isdefined(attacker.is_zombie) || !attacker.is_zombie) && attacker bgb::is_enabled("zm_bgb_pop_shocks")))
    {
        damage3d(attacker, vPoint, 0, DAMAGE_TYPE_REDUCED);
        return damage_stack_pop(0);
    }
    
    if(IS_DEBUG && DEV_HEALTH_DEBUG)
        self iprintlnbold("Health: " + self.health + ", Max: " + self.maxhealth + ", DMG: " + result + ", Score: " + self.score);
    b_is_zombie = (isdefined(attacker.is_zombie) && attacker.is_zombie);
    if(b_is_zombie && !isplayer(attacker))
    {
        if(IS_DEBUG && DEV_BOTS_IGNORE_ZM_DMG && self util::is_bot())
        {
            self.ignoreme = true;
            return damage_stack_pop(0);
        }

        if(is_explosive_extended && b_danger_closest_saved)
        {
            return damage_stack_pop(0);
        }

        self.last_player_attacker = undefined;
        self.last_player_attack = undefined;

        if(!isdefined(self.hitbuffer))
            self.hitbuffer = 0;

        if(attacker.aat_turned is true)
        {
            result = HIT_BUFFER_CAPACITY;
        }

        if(self hasperk("specialty_armorvest"))
        {
            result *= 1 - level.armorvest_reduction;
            result = int(result);
            self playlocalsound("prj_hatchet_impact_armor_heavy");
        }
        
        if(self.hitbuffer - result < 0)
        {
            self.hitbuffer = 0;

            if(!isdefined(level.zombieDamageScalar))
                level.zombieDamageScalar = 1;

            if(!isdefined(self.max_points_earned))
                self.max_points_earned = 500;

            // set basis scaled damage
            target = level.zombieDamageScalar * level.gm_zombie_dmg_scalar * result * CLAMPED_ROUND_NUMBER * level.gm_rubber_banding_scalar;

            if(isdefined(self.wager_zm_incoming_damage))
                target *= self.wager_zm_incoming_damage;

            // cannot be faster than 3 hit down
            target = int(min(target, self.max_points_earned * 0.34));
            target = int(min(target, MAX_HIT_VALUE));
            target = int(max(target, ZOMBIE_BASE_DMG));
            target = int(target * INCOMING_PVE_DAMAGE);

            if(attacker.aat_turned is true)
            {
                target = int(min(1250 * CLAMPED_ROUND_NUMBER, self.max_points_earned * 0.25));
                if(self hasperk("specialty_armorvest"))
                {
                    target *= 1 - level.armorvest_reduction;
                    target = int(target);
                }
                attacker = attacker.owner;
                weapon = level.weaponnone;
                target = int(target / get_round_damage_boost());
                self.was_hit_by_turned = true;
            }

            if(target == 0)
            {
                return damage_stack_pop(0);
            }

            if(attacker.mania_modifier === true)
            {
                result *= 4;
            }
        }
        else
        {
            self.hitbuffer -= result;
            target = int(min(100, result));
            if(attacker.aat_turned is true)
            {
                attacker = attacker.owner;
                weapon = level.weaponnone;
                target = int(target / get_round_damage_boost());
                self.was_hit_by_turned = true;
            }
        }

        if(isdefined(self.wager_perk_disabler) && self.wager_perk_disabler)
        {
            self thread wager_disable_perks();
        }

        result = target;

        if(result > 45 && isdefined(self.wager_bonus_zm_points) && self.wager_bonus_zm_points && level.players.size > 1)
        {
            points = int(result / (level.players.size - 1));
            self thread wager_gm3_points_reward(points);
        }

        if(isdefined(level.zbr_cb_zombie_hit))
        {
            self thread [[ level.zbr_cb_zombie_hit ]](eInflictor, attacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime);
        }
    }

    if(is_ds)
    {
        attacker = attacker.player;
    }
    is_trap = false;
    if(isdefined(attacker) && isdefined(attacker._trap_type))
    {
        attacker = attacker.activated_by_player;
        is_trap = true;
        if(smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" || smeansofdeath == "MOD_EXPLOSIVE")
            result = self hasperk("specialty_armorvest") ? 100 : TRAP_DEFAULT_DAMAGE;
    }

    if(isdefined(attacker) && attacker == self && is_explosive && !b_allow_self_dmg)
    {
        self thread Event_HealthAdjusted();
        return damage_stack_pop(75);
    }

    if(isdefined(weapon) && ((isdefined(level.w_olympia_ug) && weapon.rootweapon.name == level.w_olympia_ug.name) || is_ol_burning_weapon(weapon)) && !b_danger_closest_saved)
    {
        self thread w_olympia_dot_player(true, attacker);
    }

    if(isplayer(attacker) && (b_allow_self_dmg || (attacker != self)))
    {
        if((attacker != self) && attacker.team == self.team) return damage_stack_pop(0);
        if(isdefined(attacker.wager_pvp_melee_damage) && isdefined(sMeansOfDeath) && sMeansOfDeath == "MOD_MELEE") return damage_stack_pop(0);
        if(attacker laststand::player_is_in_laststand() && (attacker.coagulant_exploding !== true) && !(attacker bgb::is_enabled("zm_bgb_self_medication")) && (attacker.b_in_death_cutscene !== true) && (attacker.zbr_is_dead !== true)) return damage_stack_pop(0);
        if(!isDefined(weapon))
        {
            weapon = attacker getCurrentWeapon();
        }

        if(self.bgb_kt_frozen === true)
        {
            if(self.bgb_kt_marked !== true)
            {
                self.bgb_kt_marked = true;
                attacker LUINotifyEvent(&"score_event", 2, &"ZMUI_ZBR_PLAYER_MARKED", 10);
            }
            else
            {
                return damage_stack_pop(0);
            }
        }

        if(self.beastmode === true)
        {
            self.beastmana -= min(1, result / (CLAMPED_ROUND_NUMBER * BEAST_MODE_HEALTH));

            if(self.beastmana < 0)
            {
                self.beastmana = 0;
            }
        }

        if((self.beastmode === true) || (self.bgb_kt_frozen === true))
        {
            damageStage = attacker _damage_feedback_get_stage(self, result);
            if(isdefined(attacker.hud_damagefeedback))
            {
                attacker.hud_damagefeedback.color = (self.health - result > 0)? self GM_GetPlayerColor(true): (1,1,1);
            }
            attacker PlayHitMarker(zbr_get_hitsound(sHitLoc), damageStage, undefined, damagefeedback::damage_feedback_get_dead(self, smeansOfDeath, weapon, damageStage));
            attacker thread _damage_feedback_growth(self, sMeansOfDeath, weapon, result);
            return damage_stack_pop(0);
        }

        if(!b_is_dragon_whelp && isdefined(sMeansOfDeath) && sMeansOfDeath != "MOD_UNKNOWN")
        {
            if(compiler::wu_is_tuned(weapon))
            {
                result *= [[ level.fn_zbr_standard_boost_wu ]](weapon);
            }
            else
            {
                result *= get_round_damage_boost();
            }
        }
        
        if(self.was_hit_by_turned is not true)
        {
            result = int(self GM_AdjustWeaponDamage(weapon, result, n_result_cpy, idamage, sMeansOfDeath, attacker, eInflictor) * shrink_multiplier);
        }        

        if(isdefined(level.zombie_vars[attacker.team]["zombie_insta_kill"]) && level.zombie_vars[attacker.team]["zombie_insta_kill"] && !am_i_shrink_kicked())
        {
            result = int(result * INSTAKILL_DMG_PVP_MULTIPLIER);
        }

        if(attacker bgb_ag_active() && !am_i_shrink_kicked())
        {
            result = int(result * BGB_ARMS_GRACE_PVP_DMG);
        }

        if(isdefined(self.wager_proximity) && self.wager_proximity && isdefined(attacker.sessionstate) && attacker.sessionstate == "playing")
        {
            n_dist = distance(self getOrigin(), attacker GetOrigin());
            f_progress = min(max(n_dist, WAGER_PROXIMITY_START_DIST), WAGER_PROXIMITY_END_DIST);
            f_progress = (f_progress - WAGER_PROXIMITY_START_DIST) / (WAGER_PROXIMITY_END_DIST - WAGER_PROXIMITY_START_DIST);
            result = int(result * lerpfloat(1.0, WAGER_PROXIMITY_BOOST, 1 - f_progress));
        }

        b_frozen_reduce = (self bgb_any_frozen() || (isdefined(self.bgb_freeze_dmg_protect) && self.bgb_freeze_dmg_protect) || (self.gm_forceprone === true)) ?? false;
        if(b_frozen_reduce)
        {
            result = int(result * BGB_FROZEN_DAMAGE_REDUX);
        }

        if(isdefined(level.var_653c9585) && !b_danger_closest_saved)
        {
            switch(weapon)
            {
                case level.var_75ef78a0: // upgraded
                case level.var_653c9585: // normal
                    self thread one_inch_punch_dmg(attacker, false);
                    break;
                case level.var_4f241554: // fire
                case getweapon("staff_fire"):
                case getweapon("staff_fire_upgraded"):
                    self thread flame_damage_fx(weapon, attacker);
                    break;
                case level.var_af96dd85: // ice
                case getweapon("staff_water"):
                case getweapon("staff_water_upgraded"):
                    self thread ice_affect_zombie(weapon, attacker);
                    break;
                case level.var_e27d2514: // air
                case getweapon("staff_air"):
                case getweapon("staff_air_upgraded"):
                    self thread staff_air_knockback(weapon, attacker);
                    break;
                case level.var_590c486e: // lightning
                case getweapon("staff_lightning"):
                case getweapon("staff_lightning_upgraded"):
                    self thread staff_lightning_stun_player();
                    break;
                default: break;
            }
        }

        if(isdefined(level.w_raygun_mark3lh) && !b_danger_closest_saved)
        {
            if(isdefined(weapon))
            {
                if(weapon == level.w_raygun_mark3lh || (isdefined(level.w_raygun_mark3lh_upgraded) && (weapon == level.w_raygun_mark3lh_upgraded)))
                {
                    self thread mark3_slow(level.w_raygun_mark3lh_upgraded is defined && (weapon == level.w_raygun_mark3lh_upgraded));
                }
            }
        }

        juggStrength = self armor_damage_protection(weapon, smeansofdeath, shitloc, attacker);

        if(isdefined(self.wager_pvp_incoming_damage) && !am_i_shrink_kicked())
        {
            result = int(result * self.wager_pvp_incoming_damage);
        }

        if(isdefined(attacker.wager_pvp_outgoing_damage))
        {
            result = int(result * attacker.wager_pvp_outgoing_damage);
        }

        for(i = 0; i < juggStrength; i++)
        {
            result = int(result * (1 - level.armorvest_reduction));
        }

        if(isdefined(smeansofdeath) && smeansofdeath == "MOD_HEAD_SHOT" && isplayer(attacker) && attacker hasperk("specialty_deadshot"))
        {
            result = int(result * DEADSHOT_MULTIPLIER_PVP);
        }

        if(isdefined(weapon) && isdefined(attacker) && isdefined(shitloc) && (shitloc == "head" || shitloc == "helmet" || shitloc == "neck"))
        {
            if(attacker HasPerk("specialty_locdamagecountsasheadshot"))
            {
                if((!compiler::wu_is_tuned(weapon)) && isdefined(level.hd_scalars_table[weapon.rootweapon.name]))
                {
                    result = int(result * level.hd_scalars_table[weapon.rootweapon.name]);
                }
                else if(compiler::wu_is_tuned(weapon))
                {
                    hdmp = compiler::wu_get_hdmp(weapon);
                    if(abs(hdmp) > 0.001 && hdmp != 1.0)
                    {
                        result = int(result * hdmp);
                    }
                }
            }
            else if((!compiler::wu_is_tuned(weapon)) && isdefined(level.head_scalars_table[weapon.rootweapon.name]))
            {
                result = int(result * level.head_scalars_table[weapon.rootweapon.name]);
            }
        }

        if(isdefined(attacker.blood_hunter_timer) && attacker.blood_hunter_timer && isdefined(attacker.blood_hunter_buff))
        {
            result = int(result * (1 + (0.015 * attacker.blood_hunter_buff)));
        }

        if(IsFunctionPtr(level.fn_zbr_postdamage_scale))
        {
            result = self [[ level.fn_zbr_postdamage_scale ]](eInflictor, attacker, result, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime);
        }

        if(level.fn_zbr_gametype_postdamage_scale is function)
        {
            result = self [[ level.fn_zbr_gametype_postdamage_scale ]](eInflictor, attacker, result, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime);
        }

        if(isdefined(self.gm_thundergunned) && self.gm_thundergunned)
        {
            result = int(min(self.health - 1, result));
            if(result < 0)
            {
                result = 0;
            }
        }

        if(isdefined(self.var_2e629bce) && self.var_2e629bce > 0)
        {
            if(!(isdefined(attacker) && isdefined(weapon) && isdefined(attacker.aat) && isdefined(attacker.aat[weapon]) && attacker.aat[weapon] == "zm_aat_slag"))
            {
                result = int(result * 1.15); // slag
            }
        }

        result = int(result * PVP_DAMAGE_SCALAR);

        if(weapon is defined and weapon.issniperweapon and attacker is defined)
        {
            result = int(result * lerpfloat(1.0, 1.5, cos(90 * min(1, abs(700 - distance(attacker geteye(), self geteye())) / 200))));
            // level.players[0] iPrintLn("SNIPER: " + (distance(attacker geteye(), self geteye())) + " " + cos(90 * min(1, abs(700 - distance(attacker geteye(), self geteye())) / 200)));
        }

        if(PVP_HEADSHOTS_ONLY)
        {
            if(!(shitloc == "head" || shitloc == "helmet" || shitloc == "neck"))
            {
                result = 0;
            }
        }

        if(b_danger_closest_saved)
        {
            // saved by phd flopper, reduce the explosive amount
            if(b_danger_closest_saved & 2 && (self.zbr_phdflopper_damage_shield is defined))
            {
                reduced_multiplier = LerpFloat(1 - PHDFLOPPER_REDUXMIN, 0.0, self.zbr_phdflopper_damage_shield / PHDFLOPPER_HP);
                self.zbr_phdflopper_damage_shield -= result;
                self.zbr_phdflopper_damage_shield = int(max(0, self.zbr_phdflopper_damage_shield));

                result = int(result * reduced_multiplier);
            }

            if(isdefined(attacker) && isplayer(attacker) && attacker != self)
            {
                attacker damage_feedback_reset_size_and_loc();
                attacker thread damagefeedback::update_override("damage_feedback", "prj_hatchet_impact_armor_heavy", "damage_feedback_flak");
                self playlocalsound("prj_hatchet_impact_armor_heavy");
                damage3d(attacker, vPoint, result, DAMAGE_TYPE_REDUCED);
            }

            if(b_danger_closest_saved & 1)
            {
                self bgb_danger_closest_damaged(result);
                return damage_stack_pop(0);
            }
        }

        if(IS_DEBUG && DEV_DMG_DEBUG_FINAL && isdefined(weapon?.rootweapon))
            level.players[0] iPrintLnBold("^5hasAttacker: " + isdefined(attacker) + "(^1" + (attacker?.team ?? "?") + "^7/^2" + (self.team ?? "?") + "^7), " + weapon.rootweapon.name + " (^1" + (result ?? "??") + "^7/^2" + iDamage + "^7) " + sMeansOfDeath);

        if(isdefined(weapon.isriotshield) && weapon.isriotshield)
        {
            self setorigin(self getorigin() + (0,0,5));
            self setVelocity(self getVelocity() + VectorScale(vectornormalize(vDir) + (0,0,0.5), 400));
        }

        if(is_ww)
        {
            self widows_wine_zombie_damage_response(sMeansOfDeath, vPoint, attacker, result, weapon, vDir);
        }
       
        mod_pointscalar = DOUBLEPOINTS_PVP_SCALAR;
        if(!isdefined(attacker.team) || !isdefined(level.zombie_vars[attacker.team]["zombie_point_scalar"]) || level.zombie_vars[attacker.team]["zombie_point_scalar"] <= 1)
        {
            mod_pointscalar = 1;
        }

        mod_pointscalar *= DMG_CONVT_EFFICIENCY;
        if(isdefined(self.wager_win_dmg_scalar) && self.score >= WIN_NUMPOINTS)
        {
            mod_pointscalar *= self.wager_win_dmg_scalar;
        }
        else if(isdefined(attacker.wager_pvp_points_mod))
        {
            mod_pointscalar *= attacker.wager_pvp_points_mod;
        }

        if(attacker != self)
        {
            self.last_player_attacker = attacker;
            self.last_player_attack = gettime();
            
            points_award = mod_pointscalar * min(result, self.maxhealth);
            if(isdefined(self.wager_bonus_mp_points))
            {
                if(randomInt(100) <= WAGER_BONUSMP_CHANCE)
                {
                    points_award *= WAGER_BONUSMP_PCT + 1;
                }
            }

            if(isdefined(attacker.blood_hunter) && attacker.blood_hunter)
            {
                if(!isdefined(self.blood_hunter_points))
                {
                    self.blood_hunter_points = 0;
                }
                self.blood_hunter_points += int(points_award);
            }
            else
            {
                if(points_award < 0)
                {
                    points_award = 0;
                }
                if(points_award)
                {
                    attacker zm_score::add_to_player_score(int(points_award), 1, "gm_zbr_admin");
                }
            }
            if(!self aat_response((self.health - result) <= 0, eInflictor, attacker, result, iDFlags, sMeansOfDeath, weapon, vpoint, vdir, shitloc, psoffsettime))
            {
                damageStage = attacker _damage_feedback_get_stage(self, result);
                if(juggStrength) 
                {
                    if(isdefined(attacker.hud_damagefeedback))
                    {
                        attacker.hud_damagefeedback.color = self GM_GetPlayerColor(true);
                    }
                    attacker thread damagefeedback::update_override("damage_feedback", "prj_hatchet_impact_armor_heavy", "damage_feedback_armor");
                    self playlocalsound("prj_hatchet_impact_armor_heavy");
                }
                else 
                {
                    if(isdefined(attacker.hud_damagefeedback))
                    {
                        attacker.hud_damagefeedback.color = (self.health - result > 0)? self GM_GetPlayerColor(true): (1,1,1);
                    }
                    attacker PlayHitMarker(zbr_get_hitsound(sHitLoc), damageStage, undefined, damagefeedback::damage_feedback_get_dead(self, smeansOfDeath, weapon, damageStage));
                    attacker thread _damage_feedback_growth(self, sMeansOfDeath, weapon, result);
                }
            }
        }
    }

    if(isdefined(attacker) && attacker != self && self bgb::is_enabled("zm_bgb_coagulant"))
    {
        if(!isdefined(self.coagulant_damage))
        {
            self.coagulant_damage = 0;
        }
        self.coagulant_damage += int(result);
        self thread coagulant_gained_damage();
    }
    
    self thread Event_HealthAdjusted();
    damage3d(attacker, vPoint, result, (b_frozen_reduce is true) ? DAMAGE_TYPE_REDUCED : (is_explosive_extended ? DAMAGE_TYPE_EXPLOSIVE : ((shitloc == "head" || shitloc == "helmet" || shitloc == "neck") ? DAMAGE_TYPE_CRITICAL : DAMAGE_TYPE_ANY)));
    return damage_stack_pop(result);
}

// recursive dodamage fix
damage_stack_pop(damage = 0)
{
    damage = int(damage);
    self.pending_damage_depth = int(self.pending_damage_depth) - 1;

    if(self.pending_damage_depth <= 0)
    {
        damage += int(self.pending_damage);
        self.pending_damage = 0;
        self.pending_damage_depth = 0;

        if(level.zbr_uses_afterlife is true and self.afterlife is true)
        {
            // 200 is base mana
            manadamage = int(200 * (damage / (CLAMPED_ROUND_NUMBER * AFTERLIFE_HP_PER_ROUND)));
            self [[ level.zbr_afterlife_reduce_mana ]](manadamage);
            self util::clientnotify("al_d");
            return 0;
        }

        if(damage >= self.health)
        {
            self thread zm::clear_path_timers();
            if(level.intermission)
            {
                level waittill("forever");
            }
            if(level.zbr_uses_afterlife is true)
            {
                if(self.lives > 0 && (self.afterlife is not true))
                {
                    // self playsoundtoplayer("zmb_afterlife_death", self);
                    // self [[ level.zbr_afterlife_remove ]]();
                    // self.afterlife = 1;
                    // self.is_drinking = 1;
                    // self thread [[ level.zbr_afterlife_laststand ]]();
                    // if(self.health <= 1)
                    // {
                    //     self.health = 2;
                    // }
                    // damage = self.health - 1;
                    self.lives = 0;
                }
            }
        }

        return damage;
    }

    self.pending_damage = int(self.pending_damage) + int(damage);
    return 0;
}

is_lightning_weapon(weapon)
{
	if(!isdefined(weapon))
	{
		return false;
	}
	if(weapon == getweapon("zombie_beast_lightning_dwl") || weapon == getweapon("zombie_beast_lightning_dwl2") || weapon == getweapon("zombie_beast_lightning_dwl3"))
	{
		return true;
	}
	return false;
}

lightning_weapon_level(weapon)
{
	if(!isdefined(weapon))
	{
		return 0;
	}
	if(weapon == getweapon("zombie_beast_lightning_dwl"))
	{
		return 1;
	}
	if(weapon == getweapon("zombie_beast_lightning_dwl2"))
	{
		return 2;
	}
	if(weapon == getweapon("zombie_beast_lightning_dwl3"))
	{
		return 3;
	}
	return 0;
}

armor_damage_protection(weapon, smeansofdeath = "MOD_UNKNOWN", shitloc = "none", attacker)
{
    if(!self hasperk("specialty_armorvest"))
    {
        return 0;
    }

    if(shitloc == "head" || shitloc == "helmet" || shitloc == "neck")
    {
        if(attacker HasPerk("specialty_locdamagecountsasheadshot"))
        {
            return 2;
        }
        return 0;
    }

    switch(smeansofdeath)
    {
        case "MOD_EXPLOSIVE":
        case "MOD_GRENADE":
        case "MOD_PROJECTILE_SPLASH":
		case "MOD_GRENADE_SPLASH":
        case "MOD_PROJECTILE":
            return 2;

        case "MOD_BURNED":
		case "MOD_CRUSH":
		case "MOD_DROWN":
		case "MOD_FALLING":
		case "MOD_HIT_BY_OBJECT":
		case "MOD_MELEE":
		case "MOD_MELEE_WEAPON_BUTT":
		case "MOD_SUICIDE":
		case "MOD_TELEFRAG":
		case "MOD_TRIGGER_HURT":
            return 0;
    }

    return 1;
}

is_tomb_staff(weapon)
{
    if(!isdefined(level.a_elemental_staffs))
        return false;
    
    if(!isdefined(weapon))
        return false;

    foreach(s_staff in level.a_elemental_staffs)
        if(weapon == s_staff.w_weapon)
            return true;
    
    return is_upgraded_tomb_staff(weapon);
}

is_upgraded_tomb_staff(weapon)
{
    if(!isdefined(level.a_elemental_staffs_upgraded))
        return false;

    if(!isdefined(weapon))
        return false;
    
    foreach(s_staff in level.a_elemental_staffs_upgraded)
        if(weapon == s_staff.w_weapon)
            return true;
    return false;
}


GM_AdjustWeaponDamage(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath = "MOD_NONE", attacker, inflictor)
{
    if(!isdefined(weapon) || !isdefined(weapon.rootweapon))
        return result;
    
    if(!isdefined(weapon.rootweapon.name))
        return result;

    if(!isdefined(level.weapon_scalars_table))
    {
        level.weapon_scalars_table = [];
    }

    if(!isdefined(level.weapon_calc_table))
    {
        level.weapon_calc_table = [];
    }

    b_has_scalar = (!compiler::wu_is_tuned(weapon.rootweapon)) && isdefined(level.weapon_scalars_table[weapon.rootweapon.name]);
    b_has_function = (!compiler::wu_is_tuned(weapon.rootweapon)) && isdefined(level.weapon_calc_table[weapon.rootweapon.name]);
    b_do_postcalc = (!compiler::wu_is_tuned(weapon.rootweapon)) && weapon_is_postcalc(weapon.rootweapon.name);
    b_is_melee = sMeansOfDeath == "MOD_MELEE";

    if(b_is_melee)
    {
        b_no_cap = false;
        n_custom_cap = 0;
        if(!b_do_postcalc)
        {
            switch(weapon.rootweapon.name)
            {
                case "staff_air_upgraded":
                case "staff_water_upgraded":
                case "staff_fire_upgraded":
                case "staff_lightning_upgraded":
                    result = 1700;
                    break;
                case level.zbr_dragonshield_name:
                case "tomb_shield":
                case "zod_riotshield":
                case "island_riotshield":
                    result = 1000;
                    break;
                case "dragon_gauntlet":
                    result = 2250;
                    break;
                case "knife_plunger":
                    result = 1250;
                    b_no_cap = true;
                    break;
                case "melee_katana":
                    n_custom_cap = 30000;
                    break;
                case "bowie_knife":
                    n_custom_cap = 25000;
                    break;
                default:
                    if(isdefined(level.fn_custom_melee_cap_calc))
                    {
                        n_custom_cap = [[ level.fn_custom_melee_cap_calc ]](weapon.rootweapon.name);
                    }
                    result = max(result, 250) * MELEE_DMG_SCALAR;
                    break;
            }
        }
        else
        {
            b_no_cap = true;
        }

        if(weapon == level.zbr_knife)
        {
            n_custom_cap = int(MAX_MELEE_DAMAGE * 0.6);
        }
        
        result = min(result * CLAMPED_ROUND_NUMBER, n_custom_cap ? n_custom_cap : (b_no_cap ? (result * CLAMPED_ROUND_NUMBER) : MAX_MELEE_DAMAGE));
        if(isdefined(attacker) && attacker bgb::is_enabled("zm_bgb_sword_flay"))
        {
            if(result < (MAX_MELEE_DAMAGE / 2))
            {
                result = (MAX_MELEE_DAMAGE / 2);
            }
            result *= 2;
        }
        if(attacker ?& attacker bgb::is_enabled("zm_bgb_pop_shocks") && attacker.beastmode !== true && isdefined(weapon) && weapon != level.weaponnone)
            attacker thread attempt_pop_shocks(self);

        if(!b_do_postcalc) // melee needs to be postcalc if it wants to scale past the limit
        {
            return result;
        }
    }

    if(IS_DEBUG && DEV_DMG_DEBUG && isdefined(weapon) && isdefined(weapon.rootweapon))
        level.players[0] iPrintLnBold(weapon.rootweapon.name + " " + result + " " + sMeansOfDeath);

    if(b_has_scalar && !b_do_postcalc)
    {
        return result * level.weapon_scalars_table[weapon.rootweapon.name];
    }

    if(b_has_function && !b_do_postcalc)
    {
        return [[ level.weapon_calc_table[weapon.rootweapon.name] ]](weapon, result, n_mod_dmg, iDamage, sMeansOfDeath, attacker, inflictor);
    }

    frag_map = get_map_grenade() ?? level.weaponnone;
    frag_map = frag_map.rootweapon.name;
    if(frag_map == "none")
    {
        frag_map = "frag_grenade";
    }
    
    minigun = level.zombie_powerup_weapon["minigun"]?.rootweapon?.name ?? "minigun";
    switch(weapon.rootweapon.name)
    {
        case "hero_annihilator":
            return result * (1 + (CLAMPED_ROUND_NUMBER * ANNIHILATOR_DMG_PERCENT_PER_ROUND));

        case minigun:
            return int(80 * CLAMPED_ROUND_NUMBER * level.zbr_minigun_scalar);

        case "dragon_whelp_turret":
            return CLAMPED_ROUND_NUMBER * DRAGON_WHELP_DMG;

        case "otg_bo4_ray_gun":
        case "ray_gun":
            if(sMeansOfDeath == "MOD_PROJECTILE")
                return 0.95 * 525 * CLAMPED_ROUND_NUMBER;
            return 0.95 * 300 * CLAMPED_ROUND_NUMBER;

        case "otg_bo4_ray_gun_up":
            if(sMeansOfDeath == "MOD_PROJECTILE")
                return 0.85 * 500 * CLAMPED_ROUND_NUMBER;
            return 0.85 * 200 * CLAMPED_ROUND_NUMBER;

        case "otg_bo4_ray_gun_upgraded":
        case "ray_gun_upgraded":
            if(sMeansOfDeath == "MOD_PROJECTILE")
                return 0.95 * 1025 * CLAMPED_ROUND_NUMBER;
            return 0.95 * 400 * CLAMPED_ROUND_NUMBER;

        case frag_map:
        case "frag_grenade":
            if(sMeansOfDeath == "MOD_IMPACT")
            {
                return int(result);
            }
            return int(7 * ((result / n_mod_dmg) * 70) * CLAMPED_ROUND_NUMBER); 

        case level.zbr_contact_grenade.rootweapon.name:
            return int(5 * ((result / n_mod_dmg) * 70) * CLAMPED_ROUND_NUMBER);

        case "frag_grenade_slaughter_slide":
            return int(4 * ((result / n_mod_dmg) * 75) * CLAMPED_ROUND_NUMBER);

        case "nesting_dolls_single":
            return int(5 * ((result / n_mod_dmg) * 75) * CLAMPED_ROUND_NUMBER);
    
        case "tesla_gun":
            if(sMeansOfDeath == "MOD_PROJECTILE")
            {
                return 6000 + 0.75 * (500 * CLAMPED_ROUND_NUMBER);
            }
            return 0.65 * (1000 + (350 * CLAMPED_ROUND_NUMBER));

        case "tesla_gun_upgraded":
            if(sMeansOfDeath == "MOD_PROJECTILE")
            {
                return 6000 + 0.75 * (1500 * CLAMPED_ROUND_NUMBER);
            }
            return 0.65 * (2000 + (750 * CLAMPED_ROUND_NUMBER));

        case "sticky_grenade_widows_wine":
            if(IS_DEBUG && DEBUG_WW_DAMAGE) return 1;
            if(sMeansOfDeath == "MOD_GRENADE_SPLASH")
                return int(100 * CLAMPED_ROUND_NUMBER);
            return result;

        case "elemental_bow":
        case "elemental_bow2":
        case "elemental_bow3":
        case "elemental_bow4":
            if(sMeansOfDeath == "MOD_PROJECTILE_SPLASH")
                return ((result / idamage) * 75) * 2.5 * CLAMPED_ROUND_NUMBER;
            return 1200 * CLAMPED_ROUND_NUMBER;

        // this bow does two impacts
        case "elemental_bow_demongate4":
            if(sMeansOfDeath == "MOD_EXPLOSIVE") return ((result / idamage) * 75);
            return 750 * CLAMPED_ROUND_NUMBER;
        
        case "elemental_bow_demongate":
        case "elemental_bow_rune_prison":
        case "elemental_bow_wolf_howl":
        case "elemental_bow_storm":
            if(sMeansOfDeath == "MOD_EXPLOSIVE") return ((result / idamage) * 75);
            return 300 * CLAMPED_ROUND_NUMBER;

        case "elemental_bow_demongate1":
        case "elemental_bow_rune_prison1":
        case "elemental_bow_wolf_howl1":
        case "elemental_bow_storm1":
            if(sMeansOfDeath == "MOD_EXPLOSIVE") return ((result / idamage) * 75);
            return 400 * CLAMPED_ROUND_NUMBER;

        case "elemental_bow_demongate2":
        case "elemental_bow_rune_prison2":
        case "elemental_bow_wolf_howl2":
        case "elemental_bow_storm2":
            if(sMeansOfDeath == "MOD_EXPLOSIVE") return ((result / idamage) * 75);
            return 600 * CLAMPED_ROUND_NUMBER;

        case "elemental_bow_demongate3":
        case "elemental_bow_rune_prison3":
        case "elemental_bow_wolf_howl3":
        case "elemental_bow_storm3":
            if(sMeansOfDeath == "MOD_EXPLOSIVE") return ((result / idamage) * 75);
            return 800 * CLAMPED_ROUND_NUMBER;

        case "elemental_bow_rune_prison4":
            if(sMeansOfDeath == "MOD_EXPLOSIVE") return ((result / idamage) * 75);
            if(isdefined(self.var_a320d911) && self.var_a320d911)
            {
                return 500 * CLAMPED_ROUND_NUMBER; // do far less impact damage when frozen burning
            }
            return 1000 * CLAMPED_ROUND_NUMBER;

        case "elemental_bow_wolf_howl4":
        case "elemental_bow_storm4":
            if(sMeansOfDeath == "MOD_EXPLOSIVE") return ((result / idamage) * 75);
            return 1000 * CLAMPED_ROUND_NUMBER;

        case "hero_mirg2000":
            return 250 * CLAMPED_ROUND_NUMBER;
        case "hero_mirg2000_1":
            return 500 * CLAMPED_ROUND_NUMBER;
        case "hero_mirg2000_2":
            return 750 * CLAMPED_ROUND_NUMBER;
        
        case "hero_mirg2000_upgraded":
            return 1000 * CLAMPED_ROUND_NUMBER;
        case "hero_mirg2000_upgraded_1":
            return 1500 * CLAMPED_ROUND_NUMBER;
        case "hero_mirg2000_upgraded_2":
            return 2500 * CLAMPED_ROUND_NUMBER;

        case "octobomb":
        case "octobomb_upgraded":
            return 2500 + CLAMPED_ROUND_NUMBER * 100;

        case "launcher_dragon_fire_upgraded":
            return 30000;

        case "launcher_dragon_fire":
            return 15000;

        case "bouncingbetty_devil":
        case "bouncingbetty_holly":
        case "bouncingbetty":
            if(sMeansOfDeath == "MOD_IMPACT")
            {
                return int(idamage);
            }
            return CLAMPED_ROUND_NUMBER * ((result / idamage) * 1000);

        case "spider_turret_player":
            if(sMeansOfDeath == "MOD_PROJECTILE")
            {
                return int(CLAMPED_ROUND_NUMBER * 1000);
            }
            return int(CLAMPED_ROUND_NUMBER * 500);

        default:

            if(!is_tomb_staff(weapon))
            {
                result = gm_adjust_custom_weapon(weapon, result, n_mod_dmg, iDamage, sMeansOfDeath, attacker);

                if(b_has_scalar && b_do_postcalc)
                {
                    return result * level.weapon_scalars_table[weapon.rootweapon.name];
                }

                if(b_has_function && b_do_postcalc)
                {
                    return [[ level.weapon_calc_table[weapon.rootweapon.name] ]](weapon, result, n_mod_dmg, iDamage, sMeansOfDeath, attacker, inflictor);
                }
                return result;
            }
            
            n_result = CLAMPED_ROUND_NUMBER * 1500 * 0.65;

            if(!is_upgraded_tomb_staff(weapon))
                n_result = CLAMPED_ROUND_NUMBER * 1000 * 0.65;

            if(isSubStr(weapon.name, "water"))
            {
                n_result /= 2;
            }

            if(isSubStr(weapon.name, "air"))
            {
                n_result /= 1.65;
            }

            if(weapon.rootweapon.name == "staff_lightning_upgraded" || weapon.rootweapon.name == "staff_lightning")
            {
                n_result = int(attacker get_effective_ls_mp() * n_result);
            }

            if(weapon.rootweapon.name == "staff_fire" || weapon.rootweapon.name == "staff_fire_upgraded")
            {
                n_result = int(n_result * FIRE_STAFF_DMG_REDUCTION);
            }

        return int(n_result);
    }
}

_damage_feedback_get_stage(victim, damage = 0)
{
    if(!isdefined(victim) || !isdefined(victim.health) || !isdefined(victim.maxhealth))
        return 1;
    
    result = float(victim.health - damage);
    rval = result / victim.maxhealth;

    if(isplayer(victim) && (victim laststand::player_is_in_laststand() || victim.sessionstate != "playing"))
        return 5;

    if(rval > 0.74)
	{
		return 1;
	}
	else if(rval > 0.49)
	{
		return 2;
	}
	else if(rval > 0.24)
	{
		return 3;
	}
	else if(rval > 0)
	{
		return 4;
	}

	return 5;
}

damage_feedback_reset_size_and_loc()
{
    if(!isdefined(self.hud_damagefeedback))
    {
        return;
    }
    self.hud_damagefeedback.x = -11;
    self.hud_damagefeedback.y = -11;
    size_x = 22;
    size_y = size_x * 2;
}

_damage_feedback_growth(victim, mod, weapon, damage = 0, stage = undefined)
{
	if(isdefined(self.hud_damagefeedback))
	{
        if(!isdefined(stage)) 
        {
            stage = _damage_feedback_get_stage(victim, damage);
        }
		self.hud_damagefeedback.x = -11 + -1 * stage;
		self.hud_damagefeedback.y = -11 + -1 * stage;
		size_x = 22 + 2 * stage;
		size_y = size_x * 2;
		self.hud_damagefeedback SetShader("damage_feedback", size_x, size_y);
		if(stage == 5)
		{
			self.hud_damagefeedback SetShader("damage_feedback_glow_orange", size_x, size_y);
			self thread damagefeedback::kill_hitmarker_fade();
		}
		else
		{
			self.hud_damagefeedback SetShader("damage_feedback", size_x, size_y);
			self.hud_damagefeedback.alpha = 1;
			self.hud_damagefeedback fadeOverTime(1);
			self.hud_damagefeedback.alpha = 0;
		}
	}
}

PointAddedDispatcher()
{
    level thread PointRemovedDispatcher();
    for(;;)
    {
        level waittill("earned_points", player);

        if(!isdefined(player))
            continue;

        player thread Event_PointsAdjusted();
    }
}

PointRemovedDispatcher()
{
    for(;;)
    {
        level waittill("spent_points", player);

        if(!isdefined(player))
            continue;

        player thread Event_PointsAdjusted();
    }
}

Event_PointsAdjusted()
{
    if(self.sessionstate != "playing")
    {
        return;
    }

    if(isdefined(level.intermission) && level.intermission)
    {
        return;
    }

    max = self.gm_objective_completed ? (self Get_Pointstowin()) : (self Get_Pointstowin() * 3);

    if(level.zbr_sudden_death is true)
    {
        max = (self Get_Pointstowin() * 3);
    }

    if(MAX_POINTS_OVERRIDE != 0)
    {
        max = MAX_POINTS_OVERRIDE;
    }

    if(self.score > max)
    {
        self.score = int(max);
    }

    if(!isdefined(self.max_points_earned))
        self.max_points_earned = self.score;
    
    if(!isdefined(self.gm_objective_state))
        self.gm_objective_state = false;
    
    self.max_points_earned = int(Max(self.max_points_earned, self.score));

    if(self.maxhealth > self.score)
        self fakedamagefrom((0,0,0));

    self.maxhealth = int(Max(1, self.score));
    self.health = self.maxhealth;

    self Check_GMObjectiveState();
}

Check_GMObjectiveState()
{
    if(isdefined(level.intermission) && level.intermission)
    {
        return;
    }

    foreach(player in level.players)
        player thread UpdateGMProgress(self);

    if(!isdefined(self.gm_objective_state)) 
        self.gm_objective_state = false;

    if(self.gm_objective_completed === true)
    {
        return;
    }

    if(level.zbr_sudden_death is true)
    {
        return;
    }

    if(level.fn_override_win_condition is function)
    {
        self thread [[ level.fn_override_win_condition ]]();
        return;
    }
    
    if((self.score >= self Get_Pointstowin()) != self.gm_objective_state)
    {
        self.gm_objective_state = self.score >= self Get_Pointstowin();

        if(self.gm_objective_state)
        {
            self thread GM_BeginCountdown();
        }
    }
}

update_gm_speed_boost(ignore_entity = self, n_value = 1, b_force = false)
{
    if(isdefined(self.blood_hunter_timer) && self.blood_hunter_timer)
    {
        return;
    }
    
    if(self.gm_speed_override != 1)
    {
        self SetMoveSpeedScale(self.gm_speed_override);
        return;
    }

    b_any_objective = false;
    foreach(player in level.players)
    {
        if(isdefined(ignore_entity) && player == ignore_entity)
        {
            continue;
        }
        if(isdefined(player.gm_objective_state) && player.gm_objective_state && (level.zbr_sudden_death is not true))
        {
            b_any_objective = true;
        }
    }

    b_use_speed_boost = b_any_objective && !(isdefined(self.gm_objective_state) && self.gm_objective_state);
    b_boosted = self getmovespeedscale() >= GM_MOVESPEED_BOOSTER_MP;
    if(b_use_speed_boost != b_boosted || b_force)
    {
        self setMoveSpeedScale(b_use_speed_boost ? GM_MOVESPEED_BOOSTER_MP : n_value);
    }
}

Get_Pointstowin()
{
    if(IS_DEBUG && DEV_USE_PTW)
        return DEV_POINTS_TO_WIN;
    if(isdefined(self.wager_win_points)) return self.wager_win_points;
    return WIN_NUMPOINTS;
}

Event_HealthAdjusted()
{
    if(isdefined(level.intermission) && level.intermission)
    {
        return;
    }

    self notify("Event_HealthAdjusted");
    self endon("Event_HealthAdjusted");
    self endon("spawned_player");
    self endon("disconnect");
    self waittill("damage");

    self.score = int(self.health);
	self.pers["score"] = int(self.score);
    self.maxhealth = int(self.score);

    self Check_GMObjectiveState();
}

set_bgb_env()
{
    level.var_e1dee7ba = ROUND_DELTA_SCALAR; // number of rounds between price increase
    level.var_8ef45dc2 = 30; // clamp for round exponent
    level.var_a3e3127d = 1.15; // exponent
    level.var_f02c5598 = 2500; // base cost  
}

Round_PointScaling()
{
    zvars = 
    [
        "zombie_score_kill_4player", "zombie_score_kill_3player", "zombie_score_kill_2player",
        "zombie_score_kill_1player", "zombie_score_bonus_melee", "zombie_score_bonus_head", "zombie_score_bonus_torso"
    ];

    foreach(v in zvars)
        if(isdefined(level.zombie_vars[v]))
            level.zombie_vars[v] = int(level.zombie_vars[v] * EXPONENT_SCOREINC);

    if(!isdefined(level.zombieDamageScalar))
        level.zombieDamageScalar = 1;

    level.zombieDamageScalar = EXPONENT_DMGINC;

    if(level.script != "zm_zod")
    {
        if(level.round_number % ROUND_DELTA_SCALAR) return;
        
        foreach(perk in getentarray("zombie_vending", "targetname"))
        {
            if(!isdefined(level._custom_perks[perk.script_noteworthy].cost))
                level._custom_perks[perk.script_noteworthy].cost = 2000;
            
            if(!isdefined(perk.cost))
                perk.cost = level._custom_perks[perk.script_noteworthy].cost;
            
            for(i = 0; i < ROUND_DELTA_SCALAR; i++)
                perk.cost = int(perk.cost * EXPONENT_PURCHASE_COST_INC);
            
            level._custom_perks[perk.script_noteworthy].cost = perk.cost;
            perk setHintString("Press ^3&&1^7 to buy perk [Cost: " + perk.cost + "]");
        }

        for(i = 0; i < ROUND_DELTA_SCALAR; i++)
            level.boxCost *= EXPONENT_PURCHASE_COST_INC;

        level.zombie_treasure_chest_cost = Int(level.boxCost);
        if(isdefined(level._random_zombie_perk_cost))
        {
            for(i = 0; i < ROUND_DELTA_SCALAR; i++)
                level._random_zombie_perk_cost = int(level._random_zombie_perk_cost * EXPONENT_PURCHASE_COST_INC);
        }
    }

    set_bgb_env();

    // rubber band correction for zombie damage
    level.gm_rubber_banding_scalar = min(1.0f, GM_ZDMG_RUBBERBAND_PERCENT + level.gm_rubber_banding_scalar);
}

award_contact_grenades_for_survivors()
{
	players = getplayers();
	for(i = 0; i < players.size; i++)
	{
		if(!players[i].is_zombie && (!(isdefined(players[i].altbody) && players[i].altbody)) && !players[i] laststand::player_is_in_laststand())
		{
			tactical_grenade = players[i] zm_utility::get_player_tactical_grenade();
            if(!isdefined(tactical_grenade) || (tactical_grenade.rootweapon.name != level.zbr_contact_grenade.rootweapon.name))
            {
                continue;
            }
			if(!players[i] hasweapon(tactical_grenade))
			{
				continue;
			}
			frac = players[i] getfractionmaxammo(tactical_grenade);
			if(frac < 0.35)
			{
				players[i] setweaponammoclip(tactical_grenade, 2);
				continue;
			}
			if(frac < 0.70)
			{
				players[i] setweaponammoclip(tactical_grenade, 4);
				continue;
			}
			players[i] setweaponammoclip(tactical_grenade, 6);
		}
	}
}

Event_RoundNext()
{
    if(IS_DEBUG && DEBUG_NO_ROUNDNEXT)
    {
        return;
    }

    if(isdefined(level.intermission) && level.intermission)
    {
        return;
    }

    thread zm_round_failsafe();
    setdvar("sv_cheats", 0);
    
    if(!isdefined(level.zbr_powerup_drop_count))
	{
		level.zbr_powerup_drop_count = [];
	}

    foreach(team in level.gm_teams)
    {
        level.zbr_powerup_drop_count[team] = 0;
    }

    level.zombie_vars["zombie_powerup_drop_max_per_round"] = int(MAX_POWERUPS_PER_ROUND * get_zbr_teamsize());
    level.zbr_maxdrops = int(MAX_POWERUPS_PER_ROUND * get_zbr_teamsize());

    // scale points if we didnt restart
    if(!isdefined(level.gm_lastround))
        level.gm_lastround = level.round_number;

    if(!isdefined(level.player_weapon_boost))
        level.player_weapon_boost = 0;

    if(level.gm_lastround < level.round_number)
    {
        foreach(player in level.players)
        {
            if(isdefined(player.wager_loadout_rounds) && player.wager_loadout_rounds)
            {
                player thread wager_loadout_rounds_activate();
            }
        }
        award_contact_grenades_for_survivors();
        Round_PointScaling();
        if(level.round_number <= 33)
        {
            level.player_weapon_boost += WEP_DMG_BOOST_PER_ROUND;
        }
        // level.player_weapon_boost_wu = [[ level.fn_zbr_standard_boost_wu ]]();
        level.gm_lastround = level.round_number;
    }

    calc_zbr_ai_count();

    foreach(player in getplayers())
    {
        if(isdefined(player.danger_closest_points_remaining))
        {
            player.danger_closest_points_remaining -= DANGERCLOSEST_HP;
            player.danger_closest_points_remaining = int(player.danger_closest_points_remaining / DANGERCLOSEST_HP) * DANGERCLOSEST_HP;
            if(player.danger_closest_points_remaining < 0)
            {
                player.danger_closest_points_remaining = 0;
            }
            player notify(#danger_closest_points_remaining);
        }
        player thread Event_PointsAdjusted();
        player notify("zbr_next_round");
    }

    if(level.perk_purchase_limit < 99)
    {
        level.perk_purchase_limit = 99; // fixes the custom maps that limit after spawning 
    }

    level.skip_alive_at_round_end_xp = false;
    level.zombie_vars[ "zombie_between_round_time" ] = (float(GM_ROUND_DELAY_FULL_RND - min(GM_ROUND_DELAY_FULL_RND, level.round_number)) / GM_ROUND_DELAY_FULL_RND * GM_BETWEEN_ROUND_DELAY_START) + 0.05;

    // reset all boxes
    level.magic_box_grab_by_anyone = true;
    level flag::clear("moving_chest_enabled");
    level.chest_min_move_usage = 999;

    if(!(level.zombie_vars["zombie_powerup_fire_sale_on"] ?? 0))
    {
        foreach(chest in level.chests)
        {
            if(chest._box_open === true)
            {
                continue;
            }
            chest.hidden = 0;
            chest.zombie_cost = Int(level.boxCost);
            chest thread [[level.pandora_show_func]]();
            chest.zbarrier zm_magicbox::set_magic_box_zbarrier_state("initial");
        }
        // reset all gobble machines
        for(i = 0; i < level.var_5081bd63.size; i++)
        {
            if(!level.var_5081bd63[i].var_4d6e7e5e) // if not already showing
            {
                level.var_5081bd63[i].var_4d6e7e5e = true;
                level.var_5081bd63[i] thread bgb_machine::func_13565590(); // show it
            }
        }
    }   

    cm_bgbm_activate_all();

    // force all players into stage 1 of bgb purchasing
    foreach(player in level.players)
    {
        player player_bgb_buys_1();
        player.dragonshield_next_round = level.round_number;
    }

    if(isdefined(level.elo_round_next))
        level thread [[ level.elo_round_next ]]();

    level notify("wager_check");

    level flag::set("teleporter_used");
    thread zm_island_fix();
    zm_genesis_fix();
    zm_cosmodrome_fix();
    zm_dogs_fix();
    thread zm_mechz_roundNext();
    custom_round_next();
    zm_stalingrad_round_next();
    gm_check_sudden_death();
}

Event_ZombieInitDone()
{
    if(!isdefined(self))
    {
        return;
    }
    self thread KillOnTimeout();
}

KillOnTimeout()
{
    self endon("death");
    self endon("enemy_cleaned_up");
    self endon("deleted");
    self endon(#turned);
    wait ZOMBIE_MAXLIFETIME;

    if(level.zbr_sudden_death is true)
    {
        wait 15;
    }

    if(isdefined(self) && isalive(self) && isdefined(self.health) && isdefined(self.origin))
    {
        self DoDamage(self.health + 10000, self.origin);
    }
}

Calc_ZombieSpawnDelay(n_round)
{

    if(level.zbr_sudden_death is true)
    {
        return 0.05;
    }

    if(n_round > 30)
	{
		n_round = 30;
	}

    if(n_round < 5)
    {
        n_round = 5;
    }

	n_multiplier = EXPONENT_SPAWN_DELAY_MULT;

	switch(level.players.size)
	{
		case 1:
		{
			n_delay = 2;
			break;
		}
		case 2:
		{
			n_delay = 1.5;
			break;
		}
		case 3:
		{
			n_delay = 0.89;
			break;
		}
		default:
		{
			n_delay = 0.67;
			break;
		}
	}

	for(i = 0; i < n_round; i++)
	{
		n_delay = n_delay * n_multiplier;
		if(n_delay <= 0.05)
		{
			n_delay = 0.05;
			break;
		}
	}

	return n_delay;
}

one_box_hit_monitor()
{
    level endon("end_game");
    self thread [[
        function() => 
        {
            level endon("end_game");
            for(;;)
            {
                self.zbarrier waittill("weapon_grabbed");
                if(isplayer(self.chest_user) && self.chest_user bgb::is_enabled("zm_bgb_unbearable"))
                {
                    self.chest_user notify("unbearable_activation");
                    self.unbearable_respin_zbr = true;
                    for(i = 0; i < level.chests.size; i++)
                    {
                        if(level.chests[i] == self)
                        {
                            level.chest_index = i;
                            break;
                        }
                    }
                }
            }
        }
    ]]();
    for(;;)
    {
        self waittill("chest_accessed");
        if((!isdefined(level.zombie_vars["zombie_powerup_fire_sale_on"]) || !level.zombie_vars["zombie_powerup_fire_sale_on"]) && self.unbearable_respin_zbr !== true)
        {
            self thread zm_magicbox::hide_chest();
        }
        if(isdefined(self.unbearable_respin_zbr))
        {
            self.unbearable_respin_zbr = undefined;
        }
        level.chest_accessed = 0;
    }
}

OneGobbleOnly()
{
    level endon("end_game");
    self.base_cost = 2500;
    for(;;)
    {
        self waittill(#"62124c1e");
        self.var_4d6e7e5e = 0; // showing = 0
        self thread bgb_machine::func_3f75d3b(false);
    }
}

player_bgb_buys_1()
{
    self.var_85da8a33 = 1;
    if(level flag::get("initial_blackscreen_passed"))
    {
	    self clientfield::set_to_player("zm_bgb_machine_round_buys", self.var_85da8a33);
    }
    
    return false;
}

PlayerDiedCallback()
{
    self endon("disconnect");
    if(IS_DEBUG && DEBUG_DEATHS)
    {
        compiler::nprintln(self.name + " was killed");
    }

    self clear_all_effects();
    self.ignoreme++;
    self.am_i_valid = false;

    if(self.v_gm_cached_position is defined)
    {
        self.origin = self.v_gm_cached_position;
    }
    
    self setclientuivisibilityflag("hud_visible", true);
    self gm_hud_set_visible(false); // we shouldn't see other player's bars along with our own
    self cameraactivate(0);
    self setclientthirdperson(0);

    foreach(player in level.players)
        player UpdateGMProgress(self, true);

    self.gm_death_time = gettime();

    if(isdefined(level.zbr_death_callbacks))
    {
        if(isarray(level.zbr_death_callbacks))
        {
            foreach(cb in level.zbr_death_callbacks)
            {
                self thread [[ cb ]]();
            }
        }
        if(isfunctionptr(level.zbr_death_callbacks))
        {
            self thread [[ level.zbr_death_callbacks ]]();
        }
    }

    if(self.do_zbr_cam === true)
    {
        if(isdefined(level.killcam_cancel_on_use))
        {
            self thread [[ level.killcam_cancel_on_use ]]();
        }
        if(isdefined(level.run_killcam))
        {
            self SetControllerUIModelValue("ZBRAttacker.kills", self.killcam_params.eAttacker.zbr_kills[self getentitynumber()] + "");
            self SetControllerUIModelValue("ZBRVictim.kills", self.zbr_kills[self.killcam_params.eAttacker getentitynumber()] + "");
            wait 0.05;
            self [[ level.run_killcam ]](self.killcam_params.lpattacknum, self getentitynumber(), self.killcam_params.killcam_entity_info, self.killcam_params.weapon, self.killcam_params.smeansofdeath, self.killcam_params.deathtime, 0, 0, false, 10, array(), array(), self.killcam_params.eAttacker, false);
        }
        self.do_zbr_cam = false;
    }

    self.b_in_death_cutscene = false;
    self notify("delayed_respawn_ready");
    
    foreach(player in level.players)
    {
        if(player == self)
            continue;

        if(player.sessionstate == "playing")
            return;
    }

    level thread restart_round(self);
}

restart_round(last_player)
{
    for(;;)
    {
        if(!isdefined(last_player))
        {
            break;
        }
        
        if(last_player.sessionstate != "playing")
            break;

        wait 0.1;
    }

    level.gm_rubber_banding_scalar = max(0.25f, level.gm_rubber_banding_scalar - GM_ZDMG_RUBBERBAND_PERCENT);
    wait 1;
    goto_round(level.round_number);
}

goto_round(round)
{
    playsoundatposition("zmb_bgb_round_robbin", (0, 0, 0));
    level.skip_alive_at_round_end_xp = true;
    zm_utility::zombie_goto_round(round);
	level notify("kill_round");
}

zod_return_sprayer()
{
    self clientfield::set_to_player("pod_sprayer_held", 1);
    self.var_abe77dc0 = 1;
}

wait_and_return_weapon()
{
    self endon("disconnect");
    self endon("bled_out");
    wait SPAWN_DELAY;

    if(!isdefined(self.catalyst_loadout) && isdefined(level.zbr_player_loadouts[self getxuid()]))
    {
        self.catalyst_loadout = level.zbr_player_loadouts[self getxuid()].loadout;
        self.max_points_earned = level.zbr_player_loadouts[self getxuid()].score;
        self.wager_tier = level.zbr_player_loadouts[self getxuid()].wager_tier;
        self.kills = level.zbr_player_loadouts[self getxuid()].zkills;
        self.pers["kills"] = self.kills;
        self.defuses = level.zbr_player_loadouts[self getxuid()].pkills;
        self.pers["defuses"] = self.defuses;
        self.headshots = level.zbr_player_loadouts[self getxuid()].headshots;
        self.pers["headshots"] = self.headshots;
        self.deaths = level.zbr_player_loadouts[self getxuid()].deaths;
        self.pers["deaths"] = self.deaths;
        self.gm_objective_completed = level.zbr_player_loadouts[self getxuid()].gm_objective_completed;
        self.win_bonus_time = level.zbr_player_loadouts[self getxuid()].win_bonus_time;
        if(level.zbr_player_loadouts[self getxuid()].var_abe77dc0 is true)
        {
            self zod_return_sprayer();
        }
        if(self.gm_objective_completed is true)
        {
            // TODO: check if all teammates have objective
        }
    }

    self GiveCatalystLoadout();
    self thread GM_FairRespawn();
}

gm_calc_respawn_delay()
{
    return int(max(PLAYER_MIDROUND_RESPAWN_DELAY * 2 / 3, PLAYER_MIDROUND_RESPAWN_DELAY - (PLAYER_MIDROUND_RESPAWN_DELAY / 10 * (4 - min(4, level.players.size)))));
}

GM_FairRespawn()
{
    self notify("fair_respawn");
    self endon("fair_respawn");
    self endon("spawned_player");
    self endon("disconnect");
    level endon("end_game");
    self util::waittill_any("bled_out", "spawned_spectator");
    if(level.zbr_sudden_death is true)
    {
        return;
    }
    if(level.zbr_no_respawn is true)
    {
        return;
    }
    if(isdefined(self.died_by_blood_hunter) && self.died_by_blood_hunter)
    {
        self.died_by_blood_hunter = false;
        wait 3;
        self thread wait_and_revive_player();
        return;
    }
    if(!USE_MIDROUND_SPAWNS || gm_any_has_objective())
    {
        wait PLAYER_RESPAWN_DELAY;
        if(gm_any_has_objective())
        {
            self thread wait_and_revive_player();
        }
    }
    else
    {
        wait gm_calc_respawn_delay();
        self thread wait_and_revive_player();
    }
}

gm_any_has_objective()
{
    foreach(player in level.players)
    {
        if(isdefined(player.gm_objective_state) && player.gm_objective_state)
        {
            return true;
        }
    }
    return false;
}

LoadoutRecorder()
{
    self notify("loadout_record");
    self endon("loadout_record");
    self endon("spawned_player");
    self endon("disconnect");
    self endon("bled_out");
    level endon("end_game");

    if(IS_DEBUG && DEBUG_NO_LOADOUTS) return;
    for(;;)
    {
        self util::waittill_any_timeout(2, "weapon_change", "weapon_give");
        if(self laststand::player_is_in_laststand())
        {
            continue;
        }

        if(self.sessionstate == "spectator")
        {
            continue;
        }

        w_current = self getCurrentWeapon();

        if(isdefined(w_current))
        {
            if(w_current.isflourishweapon)
            {
                continue;
            }
            if(self zm_utility::is_player_revive_tool(w_current))
            {
                continue;
            }

            if(isdefined(level.var_c92b3b33) && level.var_c92b3b33 == w_current)
            {
                continue;
            }

            if(isdefined(level.var_adfa48c4) && level.var_adfa48c4 == w_current)
            {
                continue;
            }
        }

        if(isdefined(self.is_drinking) && self.is_drinking > 0)
        {
            continue;
        }

        // fix emphemeral enhancement
        w_ignore_weapon = undefined;
        if(isdefined(self.var_fb11234e))
        {
            w_ignore_weapon = zm_weapons::get_upgrade_weapon(self.var_fb11234e);
        }

        self.catalyst_loadout = [];
        foreach(weapon in self GetWeaponsList())
        {
            if(!isdefined(weapon))
            {
                continue;
            }

            if(weapon == level.zbr_emote_gun)
            {
                continue;
            }
            
            if(weapon.name == (level.zombie_powerup_weapon["minigun"]?.rootweapon?.name ?? "minigun"))
            {
                continue;
            }

            if(isdefined(level.w_widows_wine_grenade) && weapon.name == level.w_widows_wine_grenade.name)
            {
                continue;
            }

            if(weapon.inventorytype == "dwlefthand")
            {
                continue;
            }

            if(isdefined(w_ignore_weapon) && isdefined(w_ignore_weapon) && weapon == w_ignore_weapon)
            {
                weapon = self.var_fb11234e;
            }
            
            struct = spawnstruct();
            struct.weapon = weapon;
            struct.aat = self.AAT[weapon];
            struct.options = self GetWeaponOptions(weapon);
            self.catalyst_loadout[self.catalyst_loadout.size] = struct;

            if(!isdefined(level.zbr_player_loadouts[self getxuid()]))
            {
                level.zbr_player_loadouts[self getxuid()] = spawnstruct();
            }
            level.zbr_player_loadouts[self getxuid()].loadout = self.catalyst_loadout;
            level.zbr_player_loadouts[self getxuid()].score = self.max_points_earned;
            level.zbr_player_loadouts[self getxuid()].wager_tier = self.wager_tier ?? 0;
            level.zbr_player_loadouts[self getxuid()].zkills = self.kills;
            level.zbr_player_loadouts[self getxuid()].pkills = self.defuses;
            level.zbr_player_loadouts[self getxuid()].headshots = self.headshots;
            level.zbr_player_loadouts[self getxuid()].deaths = self.deaths;
            level.zbr_player_loadouts[self getxuid()].gm_objective_completed = self.gm_objective_completed;
            level.zbr_player_loadouts[self getxuid()].win_bonus_time = self.win_bonus_time;
            if(level.script == "zm_zod")
            {
                level.zbr_player_loadouts[self getxuid()].var_abe77dc0 = self.var_abe77dc0;
            }
        }
    }
}

detour sys::getWeaponsListPrimaries() // ... for some reason the hero weapons are counting as primaries???? I just dont understand this game anymore.
{
    weapons = [];
    foreach(weapon in self getWeaponsListPrimaries())
    {
        if(weapon.isheroweapon === true || zm_utility::is_hero_weapon(weapon))
        {
            continue;
        }
        weapons[weapons.size] = weapon;
    }
    return weapons;
}

GiveCatalystLoadout()
{  
    self endon("disconnect");
    if(IS_DEBUG && DEBUG_NO_LOADOUTS) return;
    if(!isdefined(self.catalyst_loadout))
        return;

    if(self.sessionstate != "playing")
        return;
    
    foreach(weapon in self getWeaponsListPrimaries())
    {
        self takeWeapon(weapon);
    }

    num_given = 0;

    foreach(item in self.catalyst_loadout)
    {
        weapon = item.weapon;
        options = item.options;

        if(!isdefined(weapon))
        {
            continue;
        }

        if(weapon == level.zbr_emote_gun)
        {
            continue;
        }

        if(weapon.name == (level.zombie_powerup_weapon["minigun"]?.rootweapon?.name ?? "minigun"))
        {
            continue;
        }

        if(weapon.isheroweapon === true)
        {
            continue;
        }

        if(isdefined(level.w_microwavegun) && weapon == level.w_microwavegun)
        {
            weapon = level.w_microwavegundw;
        }

         if(isdefined(level.w_microwavegun_upgraded) && weapon == level.w_microwavegun_upgraded)
        {
            weapon = level.w_microwavegundw_upgraded;
        }

        switch(true)
        {
            case zm_utility::is_hero_weapon(weapon):
            break;
            case zm_utility::is_tactical_grenade(weapon):
                self zm_weapons::weapon_give(weapon, 0, 0, 1, 0);
                if(isdefined(weapon.maxammo))
                {
                    if(level.zbr_contact_grenade == weapon || level.zbr_emp_grenade_zm == weapon)
                    {
                        self SetWeaponAmmoStock(weapon, 1);
                    }
                    else
                    {
                        self SetWeaponAmmoStock(weapon, int(max(1, weapon.maxammo - TAC_GRENADE_REDUCTION)));
                    }
                }
            break;
            case zm_utility::is_melee_weapon(weapon):
            case zm_utility::is_lethal_grenade(weapon):
            case zm_utility::is_placeable_mine(weapon):
            case zm_utility::is_offhand_weapon(weapon):
                self zm_weapons::weapon_give(weapon, 0, 0, 1, 0);
            break;

            default:
                if(zbr_count_weapons(self getWeaponsListPrimaries()) < zm_utility::get_player_weapon_limit(self))
                {
                    if(is_upgraded_tomb_staff(weapon))
                    {
                        if(isdefined(level.var_2b2f83e5))
                        {
                            self giveweapon(level.var_2b2f83e5);
                            self setactionslot(3, "weapon", level.var_2b2f83e5);
                            self clientfield::set_player_uimodel("hudItems.showDpadLeft_Staff", 1);
                            self thread tomb_revive_staff_monitor();
                        }
                    }
                    
                    if(weapon.inventorytype == "dwlefthand")
                    {
                        break;
                    }

                    acvi = self GetBuildKitAttachmentCosmeticVariantIndexes(weapon, zm_weapons::is_weapon_upgraded(weapon));
                    self GiveWeapon(weapon, options, acvi);
                    self switchtoweaponimmediate(weapon);
                    GiveAAT(self, item.aat, false, weapon);
                    wait 0.05;
                }
            break;
        }
    }

    if(isdefined(level.zbr_post_loadout))
    {
        self [[ level.zbr_post_loadout ]]();
    }

    // give hero last
    foreach(item in self.catalyst_loadout)
    {
        weapon = item.weapon;
        options = item.options;

        if(!isdefined(weapon))
        {
            continue;
        }

        if(weapon == level.zbr_emote_gun)
        {
            continue;
        }

        if(weapon.name == (level.zombie_powerup_weapon["minigun"]?.rootweapon?.name ?? "minigun"))
        {
            continue;
        }

        if(zm_utility::is_hero_weapon(weapon))
        {
            self give_hero_weapon(weapon);
            break;
        }
    }

    self wager_gm3_bowie();

    if(zbr_count_weapons(self getWeaponsListPrimaries()) < 1)
    {
        wpn = (level.round_number < 10) ? level.default_laststandpistol : level.default_solo_laststandpistol;
        self giveWeapon(wpn);
        self giveMaxAmmo(wpn);
        self switchToWeapon(wpn);
    }

    self notify("loadout_returned");
}

zbr_count_weapons(list)
{
    count = 0;
    foreach(weapon in list)
    {
        b_invalid = zm_utility::is_tactical_grenade(weapon) || zm_utility::is_hero_weapon(weapon) || (weapon.isheroweapon === 1);
        b_invalid = b_invalid || zm_utility::is_offhand_weapon(weapon) || zm_utility::is_melee_weapon(weapon);
        b_invalid = b_invalid || zm_utility::is_lethal_grenade(weapon) || zm_utility::is_placeable_mine(weapon) || (weapon == level.zbr_emote_gun);
        if(!b_invalid)
        {
            count++;
        }
    }
    return count;
}

detour zm_hero_weapon<scripts\zm\_zm_hero_weapon.gsc>::watch_hero_power(weapon)
{
    self thread watch_hero_power(weapon);
}

watch_hero_power(w_weapon)
{
	self notify("watch_hero_power");
	self endon("watch_hero_power");
	self endon("disconnect");
	if(!isdefined(self.hero_power_prev))
	{
		self.hero_power_prev = -1;
	}

	while(true)
	{
        self.hero_power = self gadgetpowerget(0);
		if(self.hero_power != self.hero_power_prev)
		{
		    self clientfield::set_player_uimodel("zmhud.swordEnergy", self.hero_power / 100);
			self.hero_power_prev = self.hero_power;
			if(self.hero_power >= 100)
			{
				self [[level._hero_weapons[w_weapon].power_full_fn]](w_weapon);
			}
			else if(self.hero_power <= 0)
			{
				self [[level._hero_weapons[w_weapon].power_empty_fn]](w_weapon);
			}
		}
		wait(0.05);
	}
}

give_hero_weapon(weapon)
{
    self endon("disconnect");
    if(!isdefined(weapon))
    {
        return;
    }

    if(isdefined(level.var_ae0fff53))
    {
        if(weapon == level.var_ae0fff53)
        {
            weapon = level.weapon_dragon_gauntlet;
        }
    }

    self.b_in_hero_return = true;
    if(!self hasWeapon(weapon))
    {
        self zm_weapons::weapon_give(weapon, 0, 0, 1);
        wait 0.05;
    }

    self [[ level._hero_weapons[weapon].power_full_fn ]](weapon);
    self [[ level._hero_weapons[weapon].wield_fn ]](weapon);
    wait 0.05;

    self [[ level._hero_weapons[weapon].unwield_fn ]](weapon);
    self [[ level._hero_weapons[weapon].power_empty_fn ]](weapon);
    wait 0.05;

    self.current_hero_weapon = weapon;
    self.hero_power_prev = -1;
    self.current_sword = self.current_hero_weapon;  
	self.sword_power = 0;
    self.sword_allowed = false;
    self.usingsword = false;
    self.autokill_glaive_active = false;
    self gadgetpowerset(0, 0);
    self.hero_power = 0;
    self clientfield::set_player_uimodel("zmhud.swordEnergy", self.hero_power / 100);
	self clientfield::increment_uimodel("zmhud.swordChargeUpdate");

    self thread watch_hero_power(weapon);

    self zm_hero_weapon::set_hero_weapon_state(weapon, 1); // set the weapon to be acquired but uncharged
    
    if(isdefined(weapon.clipsize) && weapon.clipsize > 0)
    {
        self SetWeaponAmmoStock(weapon, 0);
        self SetWeaponAmmoClip(weapon, 0);
    }

    self.var_fd007e55 = 1; // krovi dragon
    self.var_8afc8427 = 0;

    if(isdefined(level.var_c003f5b) && level.var_c003f5b == weapon)
    {
        // it would have been nice if treyarch used their own hero weapon system for this
        self flag::set("has_skull");
        self.var_118ab24e = 0;
        self.var_230f31ae = 0;
        self.var_b319e777 = 1;
        self clientfield::set_to_player("skull_skull_state", 3);
        self thread zm_craftables::player_show_craftable_parts_ui(undefined, "zmInventory.widget_skull_parts", 1);
    }

    zm_weapons::switch_back_primary_weapon(undefined, 1);
    self.b_in_hero_return = false;
}

detour zm_hero_weapon<scripts\zm\_zm_hero_weapon.gsc>::watch_for_glitches(slot, weapon)
{
	self notify("watch_for_glitches");
	self endon("watch_for_glitches");
	self endon("disconnect");
	for(;;)
	{
		self waittill("weapon_change", w_current, w_previous);
		if(self.sessionstate != "playing" || self.b_in_hero_return === true)
		{
			continue;
		}
		slot = self gadgetgetslot(weapon);
		if(isdefined(w_current) && zm_utility::is_hero_weapon(w_current))
		{
			self.hero_power = self gadgetpowerget(slot);
            if(level.script == "zm_leviathan")
            {
                if(self.hero_power < 88)
                {
                    self SetWeaponAmmoStock(weapon, 0);
                    self SetWeaponAmmoClip(weapon, 0);
                    wait 0.05;
                    waittillframeend;
                    zm_weapons::switch_back_primary_weapon(undefined, 1);
                }
                continue;
            }
			if(self.hero_power < 100)
			{
				self SetWeaponAmmoStock(weapon, 0);
        		self SetWeaponAmmoClip(weapon, 0);
				wait 0.05;
				waittillframeend;
				zm_weapons::switch_back_primary_weapon(undefined, 1);
			}
		}
	}
}

GiveAAT(player, aat, print=true, weapon)
{
    if(!isdefined(player) || !isdefined(aat))
        return;

    if(!isdefined(weapon))
        weapon = AAT::get_nonalternate_weapon(player zm_weapons::switch_from_alt_weapon(player GetCurrentWeapon()));

    player.AAT[weapon] = aat;
    player clientfield::set_to_player("aat_current", level.AAT[ player.AAT[weapon] ].var_4851adad);
}

PlayerDownedCallback(eInflictor, eAttacker, iDamage, sMeansOfDeath, weapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
    self endon("disconnect");
    self clientfield::set("zbr_burn_bf", 0);
    self.gm_objective_state = false;
    self thread stop_egg_killstreak();
    self.downed_origin = self.origin;

    if(self.zbr_is_dead)
    {
        return;
    }

    if(eAttacker is defined && (eAttacker.aat_turned is true))
    {
        eAttacker = eAttacker.owner;
    }

    if((weapon?.rootweapon?.name ?? "") == "quadrotorturret")
    {
        smeansofdeath = "MOD_HEAD_SHOT";
        eAttacker = eAttacker.player_owner;
    }

    if(isdefined(weapon) && isdefined(weapon.name) && weapon.name == "ar_standard_companion")
    {
        eAttacker = eAttacker.owning_player ?? eAttacker;
        smeansofdeath = "MOD_RIFLE_BULLET";
    }

    if(isdefined(einflictor) && isdefined(einflictor.dragon_owner))
    {
        eattacker = einflictor.dragon_owner;
    }

    if(isdefined(eAttacker?.b_aat_fire_works_weapon) && eAttacker.b_aat_fire_works_weapon)
    {
        if(isdefined(eAttacker.owner) && isplayer(eAttacker.owner))
        {
            eAttacker = eAttacker.owner;
        }
    }

    if(isdefined(eAttacker?.shrink_damage_refract) && eAttacker.shrink_damage_refract)
    {
        if(isdefined(eAttacker.attacker) && isplayer(eAttacker.attacker))
        {
            eAttacker = eAttacker.attacker;
        }
        else if(isdefined(eAttacker.owning_player) && isplayer(eAttacker.owning_player))
        {
            eAttacker = eAttacker.owning_player;
        }
    }

    if(isdefined(eattacker) && isplayer(eattacker) && eattacker != self)
    {
        if(eAttacker.sessionstate == "playing" && isdefined(eattacker.wager_gm2_rewards) && eattacker.wager_gm2_rewards)
        {
            if(isdefined(self.perks_active))
            {
                foreach(perk in self.perks_active)
                {
                    if(eattacker hasPerk(perk))
                    {
                        if(isdefined(eattacker.wager_perk_lifetime))
                        {
                            eattacker thread wager_perk_watchtime(perk); // reset the timer on losing this perk
                        }
                        continue;
                    }
                    eattacker thread zm_perks::give_perk(perk, false);
                }
            }
        }
    }

    if(IS_DEBUG && DEBUG_DEATHS)
    {
        compiler::nprintln(self.name + " was downed");
    }

    if((self.zbr_emp is not true) && (self hasperk("specialty_quickrevive") || self bgb::is_enabled("zm_bgb_self_medication") || 
        self bgb::is_enabled("zm_bgb_phoenix_up") || self bgb::is_enabled("zm_bgb_near_death_experience")))
    {
        self.n_bleedout_time_multiplier = 1;
        level.solo_lives_given = 0;
        self thread fix_bleedout();
        if(self bgb::is_enabled("zm_bgb_phoenix_up"))
        {
            self unlink();
            self thread hide_while_downed();
            self thread wait_and_clear_revive();
            self thread anywhere_but_here_activation();
        }
        else
        {
            if(self bgb::is_enabled("zm_bgb_self_medication"))
            {
                self thread wait_and_clear_revive();
            }
            else
            {
                self thread hide_while_downed();
                self thread zm::wait_and_revive();
                self unlink();
                self thread anywhere_but_here_activation();
            }
        }

        if(isplayer(eAttacker) && eAttacker != self)
        {
            eAttacker LUINotifyEvent(&"score_event", 2, &"ZMUI_ZBR_PLAYER_DOWNED", 100);
        }

        foreach(player in getplayers())
        {
            if(player.sessionstate != "playing")
            {
                continue;
            }

            base = clean_name(self.name) + "^7 ";
            
            if(isdefined(eattacker) && isdefined(eattacker.team))
            {
                if(eattacker.team == level.zombie_team)
                {
                    base += "was downed by ^1zombies";
                }
                else if(eattacker == self)
                {
                    base += "downed themself";
                }
                else if(eattacker == player)
                {
                    base += "was downed by ^3" + clean_name(eattacker.name);
                }
                else if(eattacker.team == self.team)
                {
                    base += "was downed by ^8" + clean_name(eattacker.name);
                }
                else
                {
                    base += "was downed by ^9" + clean_name(eattacker.name);
                }
            }
            else
            {
                base += "was downed";
            }

            if(player == self)
            {
                player iPrintLn("^3" + base);
            }
            else if(player.team == self.team)
            {
                player iPrintLn("^8" + base);
            }
            else
            {
                player iPrintLn("^9" + base);
            }
        }

        if(isdefined(level.fn_downed_reviving_cb))
        {
            self thread [[ level.fn_downed_reviving_cb ]]();
        }
    }
    else
    {
        if(isfunctionptr(level.fn_player_died_zbr))
        {
            self thread [[ level.fn_player_died_zbr ]](eInflictor, eAttacker, iDamage, sMeansOfDeath, weapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
        }
        self.zbr_is_dead = true;
        self thread player_downed_async(eInflictor, eAttacker, iDamage, sMeansOfDeath, weapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
    }
    self [[ level._callbackPlayerLastStand ]](eInflictor, eAttacker, iDamage, sMeansOfDeath, weapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
}

hide_while_downed()
{
    self endon("bled_out");
    self endon("disconnect");
    wait 0.05;
    while(self laststand::player_is_in_laststand())
    {
        self hide();
        msg = self util::waittill_any_timeout(0.1, "player_revived");
        if(isdefined(msg) && msg == "player_revived")
        {
            break;
        }
    }
    self show();
    self.gm_override_reduce_pts = QUICKREVIVE_REDUCE_POINTS;
    self restore_earned_points();
    self.gm_override_reduce_pts = 0;
    distance = 400 * 400;
    foreach(zombie in GetAITeamArray(level.zombie_team))
    {
        if(!isdefined(zombie) || !isalive(zombie))
        {
            continue;
        }
        if(distancesquared(zombie.origin, self.origin) > distance)
        {
            continue;
        }
        zombie dodamage(zombie.health + 666, zombie.origin);
    }
}

wait_and_clear_revive()
{
    self endon("disconnect");
    wait 1;
    self notify("remote_revive");
    self update_gm_speed_boost();
}

player_downed_async(eInflictor, eAttacker, iDamage, sMeansOfDeath = "MOD_UNKNOWN", weapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
    self endon("disconnect");
    if(isdefined(eAttacker) && isdefined(eAttacker._trap_type))
    {
        eAttacker = eAttacker.activated_by_player;
    }

    if(eAttacker.b_aat_fire_works_weapon === true)
    {
        if(isdefined(eAttacker.owner) && isplayer(eAttacker.owner))
        {
            eAttacker = eAttacker.owner;
        }
    }

    if(weapon_is_ds(weapon))
    {
        eAttacker = eAttacker.player;
    }

    self zbr_cosmetics_set_visible(true);

    self.gm_death_time = gettime();

    if(isdefined(eAttacker) && isplayer(eAttacker) && eAttacker != self)
    {
        if(eAttacker.sessionstate == "playing" && isdefined(eAttacker.wager_gun_game) && eAttacker.wager_gun_game)
        {
            eAttacker thread wager_gg_swap();
        }

        if(!isdefined(eAttacker.egg_killstreak))
        {
            eAttacker.egg_killstreak = 0;
        }
        eAttacker.egg_killstreak++;

        if(IS_DEBUG && DEBUG_EE_KILLSTREAK)
        {
            eAttacker.egg_killstreak = 10;
        }

        if(isdefined(eattacker.blood_hunter) && eattacker.blood_hunter)
        {
            eattacker thread blood_hunter_buff();
            self.died_by_blood_hunter = true;
        }
        self.power_vacuum = eAttacker bgb::is_enabled("zm_bgb_power_vacuum");
        level.gm_last_killed_ent = self;
        if(eAttacker bgb::is_enabled("zm_bgb_self_medication"))
        {
            eAttacker thread bgb::function_7d63d2eb();
            eAttacker notify(#"hash_935cc366");
        }
        eAttacker notify("zbr_killed_player");
        eAttacker AddRankXp("kill", weapon, undefined, false, true, 100);

        if(!isdefined(eAttacker.pers["defuses"]))
        {
            eAttacker.pers["defuses"] = 0;
        }
        eAttacker.pers["defuses"]++;
        eAttacker.defuses = eAttacker.pers["defuses"];
        eAttacker.pers["kills"]--;
        eAttacker.kills = eAttacker.pers["kills"];
        eAttacker.last_killed_player = self;
        eAttacker.last_killed_player_time = gettime();
        eAttacker.last_killed_player_location = self.origin;
        
        any_hero = zm_utility::is_hero_weapon(weapon) || zm_utility::is_hero_weapon(eattacker getCurrentWeapon()) || eattacker zm_hero_weapon::is_hero_weapon_in_use();
        if(eattacker.sessionstate == "playing" && !any_hero)
        {
            power = eattacker gadgetpowerget(0);
            if(isdefined(power) && power < 100)
            {
                eattacker.hero_power = int(max(0, min(100, power + GADGET_PWR_PER_KILL)));
                eattacker GadgetPowerSet(0, eattacker.hero_power);
                eattacker clientfield::set_player_uimodel("zmhud.swordEnergy", eattacker.hero_power / 100);
				eattacker clientfield::increment_uimodel("zmhud.swordChargeUpdate");
            }
        }
        else if(any_hero)
        {
            // take energy. we will just have to hardcode behavior and default to energy consumption. A player kill should take 40% energy/ammo.
            power = eattacker gadgetpowerget(0);
            switch(weapon.name)
            {
                case "hero_annihilator":
                    eattacker setWeaponAmmoClip(weapon, int(max(0, eattacker getWeaponAmmoClip(weapon) - int((weapon.weaponClipSize ?? 20) * 0.4))));
                    eattacker.hero_power = int(max(0, power - 40));
                    eattacker GadgetPowerSet(0, eattacker.hero_power);
                break;
                case "skull_gun":
                case "skull_gun1":
                    // already functions this way
                break;
                default:
                    eattacker.hero_power = int(max(0, power - 40));
                    eattacker GadgetPowerSet(0, eattacker.hero_power);
                break;  
            }
        }

        if(IsFunctionPtr(level.fn_zbr_custom_kill_reward))
        {
            eAttacker [[ level.fn_zbr_custom_kill_reward ]](self, iDamage, sMeansOfDeath, weapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
        }

        eAttacker LUINotifyEvent(&"score_event", 2, &"ZMUI_ZBR_PLAYER_KILLED", 1000);

        if(isdefined(sHitLoc) && sHitLoc == "head")
        {
            eAttacker playsoundtoplayer("zbr_headshot", eAttacker);
        }
        else
        {
            eAttacker playsoundtoplayer("zbr_kill", eAttacker);
        }
    }

    if(isdefined(level.bgb_td_pvp_prefix) && bgb::is_team_enabled("zm_bgb_tone_death"))
    {
        self thread bgb_td_activate();
    }

    if(eAttacker?.team ?& eAttacker.team == level.zombie_team)
    {
        foreach(player in getplayers())
        {
            if(player.sessionstate != "playing")
            {
                continue;
            }
            base = clean_name(self.name) + "^7 was killed by ^1zombies";
            if(player == self)
            {
                player iPrintLn("^3" + base);
            }
            else if(player.team == self.team)
            {
                player iPrintLn("^8" + base);
            }
            else
            {
                player iPrintLn("^9" + base);
            }
        }
    }
    else
    {
        if(sHitLoc ?& (sHitLoc == "head" || shitloc == "helmet" || shitloc == "neck") && sMeansOfDeath != "MOD_UNKNOWN" && sMeansOfDeath != "MOD_MELEE" && sMeansOfDeath != "MOD_EXPLOSIVE")
        {
            smeansofdeath = "MOD_HEAD_SHOT";
        }

        // attacker.b_aat_fire_works_weapon
        obituary(self, eAttacker, weapon, smeansofdeath);
    }

    KillHeadIcons(self, true);
    CleanupMusicCheck();
    self.score = 1;
    self.maxhealth = 1;
    self.b_in_death_cutscene = true;
    self Check_GMObjectiveState();
    self set_death_launch_velocity(eAttacker, weapon, sMeansOfDeath, vDir);

    n_launch_magnitude = min(10, int(iDamage / 1000)) * 25;
    if(isdefined(self.launch_magnitude_extra)) 
    {
        n_launch_magnitude += self.launch_magnitude_extra;
    }

    v_launch_direction_extra = (0,0,0);
    if(isdefined(self.v_launch_direction_extra))
    {
        v_launch_direction_extra = self.v_launch_direction_extra;
    }

    self wager_show_self_items();
    clone = self ClonePlayer(1, weapon, eattacker);
    origin = self.origin;

    self.do_zbr_cam = false;
    if(gm_using_killcams())
    {
        wasteamkill = isdefined(eAttacker) && isdefined(eAttacker.team) && eAttacker.team == self.team;
        wasplayer = isplayer(eattacker);
        lpattacknum = eAttacker getentitynumber();
        deathtime = GetTime();
        do_cam = wasplayer && !self util::is_bot() && !wasteamkill && (smeansofdeath != "MOD_SUICIDE") && !(!isdefined(eAttacker) || eAttacker.classname == "trigger_hurt" || eAttacker.classname == "worldspawn" || eAttacker == self || ((eAttacker.team ?? "") == level.zombie_team));
        if(do_cam)
        {
            self.n_bleedout_time_multiplier = 0.01;
            self.do_zbr_cam = true;
            if(!isdefined(self.killcam_params))
            {
                self.killcam_params = spawnStruct();
            }
            self.cancelkillcam = 0;
            self.killcam_params.eInflictor = eInflictor;
            self.killcam_params.eAttacker = eAttacker;
            self.killcam_params.iDamage = iDamage;
            self.killcam_params.sMeansOfDeath = sMeansOfDeath;
            self.killcam_params.weapon = weapon;
            self.killcam_params.vDir = vDir;
            self.killcam_params.sHitLoc = sHitLoc;
            self.killcam_params.psOffsetTime = 0;
            self.killcam_params.deathAnimDuration = deathAnimDuration;
            self.killcam_params.lpattacknum = lpattacknum;
            self.killcam_params.deathtime = deathtime;

            if(!isdefined(eAttacker.zbr_kills))
            {
                eAttacker.zbr_kills = [];
            }

            if(!isdefined(eAttacker.zbr_kills[self GetEntityNumber()]))
            {
                eAttacker.zbr_kills[self GetEntityNumber()] = 0;
            }

            eAttacker.zbr_kills[self GetEntityNumber()]++;

             if(!isdefined(self.zbr_kills))
            {
                self.zbr_kills = [];
            }

            if(!isdefined(self.zbr_kills[eAttacker GetEntityNumber()]))
            {
                self.zbr_kills[eAttacker GetEntityNumber()] = 0;
            }

            if(isdefined(level.killcam_record_settings) && isdefined(level.killcam_get_killcam_entity_info))
            {
                self.killcam_params.killcam_entity_info = [[ level.killcam_get_killcam_entity_info ]](eAttacker, einflictor, weapon);
                level thread [[ level.killcam_record_settings ]](lpattacknum, -1, weapon, smeansofdeath, deathtime, 0, 0, self.killcam_params.killcam_entity_info, array(), array(), eAttacker);
            }
        }
        else
        {
            self cameraactivate(1);
            self CameraSetPosition(self geteye());
            self CameraSetLookAt(clone);
        }
    }
    else
    {
        self cameraactivate(1);
        self CameraSetPosition(self geteye());
        self CameraSetLookAt(clone);
    }

    clone.ignoreme = true;
    clone.team = "allies";
    clone setteam("allies");
    clone startragdoll(1);
    clone launchragdoll(vectornormalize(vDir + v_launch_direction_extra) * n_launch_magnitude);
    clone thread DeleteAfter30();
    self.ignoreme++;
    self.no_grab_powerup = true;
    self hide();
    self setclientuivisibilityflag("hud_visible", false);
    self gm_hud_set_visible(false);
    trace = groundtrace(origin + vectorscale((0, 0, 1), 5), origin + vectorscale((0, 0, -1), 300), 0, undefined);
    origin = trace["position"];
    if(player_can_drop_powerups(self, weapon))
    {
        level zm_spawner::zombie_delay_powerup_drop(origin);
        self widows_wine_drop_grenade(eattacker, weapon);
    }

    self.v_gm_cached_position = origin;
    if(!self.do_zbr_cam)
    {
        self setorigin(level.gm_override_downed_spot ?? (0,0,30000));
        wait 0.05;
    }

    if(self.blood_hunter_points is defined && (self.blood_hunter_points > 0))
    {
        mdl = zm_powerups::specific_powerup_drop("blood_hunter_points", origin, undefined, undefined, 0.1);
        mdl.blood_hunter_points = int(max(0, min(WAGER_MAX_BH_POINTS, self.blood_hunter_points)));
        mdl.bh_owner = self;
        mdl clientfield::set("powerup_fx", 0);
        mdl_fx = playfxontag("zombie/fx_powerup_on_red_zmb", mdl, "tag_origin");
        if(isdefined(mdl_fx))
        {
            mdl_fx thread [[ function(owner) => { self endon("death"); owner waittill("death"); if(isdefined(self)) self delete(); }]]();
        }
        // level thread powerup_fixup(mdl);
    }

    self.blood_hunter_points = 0;

    wait 0.05;
    self DisableWeapons(true);
    self thread [[ function() => 
    {
        self endon("bled_out");
        self endon("spawned_player");
        wait 10;
        if(self.b_in_death_cutscene === true)
        {
            if((!(self laststand::player_is_in_laststand())) && self.sessionstate == "playing")
            {
                self.b_in_death_cutscene = false;
                self notify("end_killcam");
                self zm_laststand::bleed_out();
                self notify("bled_out");
            }
        }
    }]]();
}

set_death_launch_velocity(e_attacker, w_weapon, sMeansOfDeath = "MOD_UNKNOWN", vDir)
{
    if(sMeansOfDeath == "MOD_UNKNOWN") return; // dont set up launch parameters for unk because it will be a wonder weapon or other misc damage
    if(!isdefined(w_weapon) || w_weapon == level.weaponnone) return; // dont setup launch parameters for unknown weapons or weapon none, most likely wonder weapon, etc.

    if(isdefined(level.var_653c9585))
    {
        switch(w_weapon)
        {
            case level.var_e27d2514: // air
            case getweapon("staff_air"):
            case getweapon("staff_air_upgraded"):
            case level.var_75ef78a0: // upgraded
            case level.var_653c9585: // normal
                return;
            default: break;
        }
    }
    
    self.launch_magnitude_extra = 0;
    self.v_launch_direction_extra = (0,0,0);

    if(smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" || smeansofdeath == "MOD_EXPLOSIVE")
    {
        self.launch_magnitude_extra += 250;
    }

    if(w_weapon?.isriotshield === true)
    {
        self.launch_magnitude_extra = 200;
        self.v_launch_direction_extra = (0,0,0.7);
        return;
    }

    if(w_weapon.rootweapon.name == "dragon_gauntlet" && smeansofdeath == "MOD_MELEE")
    {
        self.launch_magnitude_extra = 50;
        self.v_launch_direction_extra = (0,0,0.7);
        return;
    }
}

fix_bleedout()
{
    self endon("bled_out");
    self waittill("player_revived");
    self.n_bleedout_time_multiplier = N_BLEEDOUT_BASE;
    self zm_score::add_to_player_score(500, 0, "gm_zbr_admin");
    self Event_PointsAdjusted();
}

DeleteAfter30()
{
    self endon("death");
    self endon("deleted");
    wait 30;
    self delete();
}

GM_BeginCountdown()
{
    self endon("bled_out");
    self endon("disconnect");
    self notify("GM_BeginCountdown");
    self endon("GM_BeginCountdown");
    level endon("end_game");

    if(self.gm_objective_completed)
    {
        return;
    }

    if(level.zbr_sudden_death is true)
    {
        return;
    }

    self.gm_objective_timesurvived = 0;

    // players may only recieve 1 objective reached bonus per life. This prevents cheating with zombie hordes.
    if(isdefined(self.b_allow_reached_bonus) && self.b_allow_reached_bonus)
    {
        self inc_gm_time_bonus(GM_TIMEBONUS_OBJ_REACHED);
        self.b_allow_reached_bonus = false;
    }
    

    if(!isdefined(self.gm_objective_state))
    {
        self.gm_objective_state = false;
    }

    EntityHeadKillIcon(self, self GetTagOrigin("j_head") - self GetOrigin(), (6,6,0), (1,0,0));

    // respawn players when someone reaches score limit so they can hunt them down
    foreach(player in getplayers())
    {
        prefixCol = (player == self) ? "^2" : "^1";
        player thread wait_and_revive_player(prefixCol + clean_name(self.name) + "^7 has reached the score limit!");
    }

    CleanupMusicCheck();
    level thread GM_StartMusic();

    while(self.gm_objective_state)
    {
        clear_effect(SE_RESTRICTED_AREA);
        clear_effect(SE_RESTRICTED_ACTION);
        wait 1;

        while(bgb::is_team_active("zm_bgb_killing_time") || bgb::is_team_active("zm_bgb_fear_in_headlights"))
        {
            wait 0.25;
        }

        while(isfunctionptr(level.fn_pause_zbr_objective) && self [[ level.fn_pause_zbr_objective ]]())
        {
            activate_effect(SE_RESTRICTED_AREA, -1);
            wait 0.25;
        }

        while(isdefined(self.beastmode) && self.beastmode)
        {
            activate_effect(SE_RESTRICTED_ACTION, -1);
            wait 0.25;
        }

        while(isdefined(self.var_59bd3c5a) && isalive(self.var_59bd3c5a)) // zns controllable spider
        {
            activate_effect(SE_RESTRICTED_ACTION, -1);
            wait 0.25;
        }
        
        if(level.script == "zm_theater" && isdefined(self.is_teleporting) && self.is_teleporting)
        {
            while((distance2d(self.origin, (-7, -285, 320)) < 200) || (isdefined(self.is_teleporting) && self.is_teleporting))
            {
                activate_effect(SE_RESTRICTED_AREA, -1);
                wait 1;
            }
        }

        if(level.script == "zm_zod")
        {
            zone = self zm_zonemgr::get_player_zone();
            while(isdefined(zone) && (zone == "zone_train_rail"))
            {
                activate_effect(SE_RESTRICTED_AREA, -1);
                wait 1;
                zone = self zm_zonemgr::get_player_zone();
            }
        }

        if(level.script == "zm_stalingrad")
        {
            zone = self zm_zonemgr::get_player_zone();
            while(isdefined(zone) && (zone == "pavlovs_C_zone" || zone == "pavlovs_B_zone" || zone == "pavlovs_A_zone"))
            {
                activate_effect(SE_RESTRICTED_AREA, -1);
                wait 1;
                zone = self zm_zonemgr::get_player_zone();
            }

            while(isdefined(self.var_a0a9409e) && self.var_a0a9409e)
            {
                activate_effect(SE_RESTRICTED_ACTION, -1);
                wait 1;
            }

            while(isdefined(level.var_163a43e4) && isinarray(level.var_163a43e4, self))
            {
                activate_effect(SE_RESTRICTED_ACTION, -1);
                wait 1; // while on the dragon
            }
        }

        if(level.script == "zm_castle")
        {
            zone = self zm_zonemgr::get_player_zone();
            b_rocket_firing = isdefined(level flag::get("rocket_firing")) && level flag::get("rocket_firing");
            b_at_pad = isdefined(zone) && (zone == "zone_v10_pad" || zone == "zone_v10_pad_door" || zone == "zone_v10_pad_exterior");
            while(b_rocket_firing && b_at_pad)
            {
                activate_effect(SE_RESTRICTED_AREA, -1);
                wait 1;
                zone = self zm_zonemgr::get_player_zone();
                b_rocket_firing = isdefined(level flag::get("rocket_firing")) && level flag::get("rocket_firing");
                b_at_pad = isdefined(zone) && (zone == "zone_v10_pad" || zone == "zone_v10_pad_door" || zone == "zone_v10_pad_exterior");
            }
        }

        if(level.script == "zm_genesis")
        {
            zone = self zm_zonemgr::get_player_zone();
            while(isdefined(zone) && zone == "apothicon_interior_zone")
            {
                activate_effect(SE_RESTRICTED_AREA, -1);
                wait 1;
                zone = self zm_zonemgr::get_player_zone();
            }
        }

        if(!self.gm_objective_state || (level.zbr_sudden_death is true))
        {
            if(level.zbr_sudden_death is true)
            {
                self.gm_objective_state = false;
                self.gm_objective_timesurvived = 0;
                self.gm_objective_completed = false;
            }
            break;
        }
        
        self.gm_objective_timesurvived++;
        foreach(player in level.players)
        {
            player UpdateGMProgress(self);
            player update_gm_speed_boost(player);
        }

        if(self.gm_objective_timesurvived >= self get_gm_time_to_win())
        {
            self.gm_objective_completed = true;
            break;
        }
    }

    clear_effect(SE_RESTRICTED_AREA);
    clear_effect(SE_RESTRICTED_ACTION);

    foreach(player in level.players)
    {
        player UpdateGMProgress(self);
        player update_gm_speed_boost(player);
    }

    KillHeadIcons(self);
    CleanupMusicCheck();

    num_ticks_hit = min(4, int((self.gm_objective_timesurvived / self get_gm_time_to_win()) / 0.2));
    self inc_gm_time_bonus(int(GM_TIMEBONUS_OBJ_HELD * num_ticks_hit));

    if(self.gm_objective_timesurvived >= self get_gm_time_to_win())
    {
        self.gm_objective_completed = true;
        self.gm_objective_timesurvived = 0;
        self.gm_objective_state = false;

        if(is_zbr_teambased())
        {
            do_return = false;
            foreach(mate in self get_zbr_teammates())
            {
                if(mate.gm_objective_completed !== true)
                {
                    do_return = true;
                    mate inc_gm_time_bonus(int(OBJECTIVE_WIN_TIME / (ZBR_TEAMSIZE - 1)));
                    mate iPrintLn("^8" + clean_name(self.name) + " ^7completed the objective. Objective time requirement decreased.");
                    if(mate.gm_objective_state !== true)
                    {
                        mate gm_commit_time_bonus();
                    }
                }
            }

            count = (self get_zbr_teammates()).size;
            count += 1;

            if(do_return || (count < ZBR_TEAMSIZE))
            {
                self LUINotifyEvent(&"score_event", 2, &"ZMUI_ZBR_OBJECTIVE_COMPLETE", 10000);
                CleanupMusicCheck();
                return;
            }
        }

        self LUINotifyEvent(&"score_event", 2, &"ZMUI_ZBR_OBJECTIVE_COMPLETE", 10000);
        self gm_endgame_commit();
        return;
    }

    self gm_commit_time_bonus();
}

gm_endgame_commit(b_no_winner = false)
{
    if(!b_no_winner)
    {
        self.gm_winner = true;
        if(!isdefined(level.gm_winner))
        {
            level.gm_winner = self;
        }

        calc_player_lb_ranks();
        foreach(player in level.players)
        {
            if(is_zbr_teambased() && player.gm_id == self.gm_id)
            {
                player.gm_winner = true;
            }
            if(player == self)
            {
                continue;
            }
            player.max_points_earned = int(min(player.max_points_earned, self.max_points_earned - 1));
        }
    }
    
    level.elo_game_finished = true;
    GM_KillMusic();
    level notify("end_game");
}

gm_reduce_objective_time(penalty = 20)
{
    self.gm_objective_timesurvived = int(max((self.gm_objective_timesurvived ?? 0) - 20, 0));
}

get_gm_time_to_win()
{
    if(OBJECTIVE_WIN_TIME <= int(OBJECTIVE_WIN_TIME / 4))
    {
        return OBJECTIVE_WIN_TIME;
    }

    if(!isdefined(self.win_bonus_time))
    {
        return OBJECTIVE_WIN_TIME;
    }

    return OBJECTIVE_WIN_TIME - int(max(0, min(OBJECTIVE_WIN_TIME - int(OBJECTIVE_WIN_TIME / 4), self.win_bonus_time)));
}

get_gm_time_bonus()
{
    // if(OBJECTIVE_WIN_TIME <= 30)
    // {
    //     return 0;
    // }

    if(!isdefined(self.gm_objective_timesurvived))
    {
        return 0;
    }

    if(!isdefined(self.win_bonus_time))
    {
        self.win_bonus_time = 0;
        return 0;
    }

    return int(max(0, min(OBJECTIVE_WIN_TIME - int(OBJECTIVE_WIN_TIME / 4), self.win_bonus_time)));
}

inc_gm_time_bonus(time = 0)
{
    if(!isdefined(self.pending_win_bonus_time))
    {
        self.pending_win_bonus_time = 0;
    }
    self.pending_win_bonus_time += time;
}

gm_commit_time_bonus()
{
    if(!isdefined(self.pending_win_bonus_time))
    {
        self.pending_win_bonus_time = 0;
    }

    if(!isdefined(self.win_bonus_time))
    {
        self.win_bonus_time = 0;
    }

    self.win_bonus_time += self.pending_win_bonus_time;
    self.pending_win_bonus_time = 0;
}

calc_player_lb_ranks()
{
    level.zbr_leaderboard = [];
    level.zbr_leaderboard[0] = level.gm_winner;
    players = getplayers();
    arrayremovevalue(players, level.gm_winner, false);
    
    // max_points_earned
    while(players.size)
    {
        highest = undefined;
        
        if(is_zbr_teambased())
        {
            foreach(player in players)
            {
                if(player.gm_id == level.gm_winner.gm_id)
                {
                    highest = player;
                    break;
                }
            }
        }

        if(!isdefined(highest))
        {
            foreach(player in players)
            {
                if(!isdefined(highest))
                {
                    highest = player;
                    continue;
                }

                if(!isdefined(player.max_points_earned))
                {
                    player.max_points_earned = 0;
                }

                if(highest.max_points_earned < player.max_points_earned)
                {
                    highest = player;
                }
            }
        }

        ArrayRemoveValue(players, highest, false);
        level.zbr_leaderboard[level.zbr_leaderboard.size] = highest;
    }
}

get_player_lb_rank()
{
    if(!isdefined(level.zbr_leaderboard))
    {
        return 0;
    }
    for(i = 0; i < level.zbr_leaderboard.size; i++)
    {
        if(level.zbr_leaderboard[i] == self)
        {
            return i;
        }
    }
    return 255;
}

wait_and_revive_player(text) // players killed right when objective is completed will now respawn properly
{
    self notify("wait_and_revive_player");
    self endon("wait_and_revive_player");
    self endon("disconnect");

    if(level.zbr_no_respawn is true)
    {
        return;
    }

    if(self.sessionstate != "playing")
    {
        self.respawn_text = text;
        self thread respawn_enter_queue();
        // self thread wait_and_return_weapon();
    }
    else
    {
        if(isdefined(text))
        {
            self iPrintLnBold(text);
        }
    }
}

respawn_enter_queue()
{
    self endon("disconnect");
    self notify("respawn_enter_queue");
    self endon("respawn_enter_queue");
    if(!level flag::get("initial_blackscreen_passed"))
    {
        return;
    }

    wait 2;

    if((isdefined(self.b_in_death_cutscene) && self.b_in_death_cutscene) || (isdefined(self.spectatekillcam) && self.spectatekillcam))
    {
        self endon("fair_respawn");
        self endon("spawned_player");
        self endon("disconnect");
        self util::waittill_any_timeout(5, "delayed_respawn_ready", "end_killcam");
        while((isdefined(self.spectatekillcam) && self.spectatekillcam) || (isdefined(self.b_in_death_cutscene) && self.b_in_death_cutscene) || self.killcam)
        {
            wait 0.1;
        }
        wait 2;
    }

    if(isdefined(self.kc_skiptext))
	{
		self.kc_skiptext.alpha = 0;
	}
	if(isdefined(self.kc_timer))
	{
		self.kc_timer.alpha = 0;
	}

	self.killcam = undefined;
    self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.spectatekillcam = false;
    wait 0.05;

    if(level.zbr_no_respawn is true)
    {
        return;
    }

    self.gm_respawn_time = gettime();
    self [[ level.spawnplayer ]]();
}

spawn_queue_monitor()
{
    level notify("spawn_queue_monitor");
    level endon("spawn_queue_monitor");
    level endon("end_game");
    if(!isdefined(level.zbr_spawn_queue))
    {
        level.zbr_spawn_queue = [];
    }

    for(;;)
    {
        wait SPAWN_THROTTLE_QUEUE_TIME;

        // while(level.zbr_spawn_queue.size && (!isdefined(level.zbr_spawn_queue[0]) || !isplayer(level.zbr_spawn_queue[0])))
        // {
        //     arrayremovevalue(level.zbr_spawn_queue, level.zbr_spawn_queue[0], false);
        // }

        foreach(player in getplayers())
        {
            if(!isdefined(player.gm_death_time))
            {
                continue;
            }

            if(player.sessionstate == "playing")
            {
                continue;
            }

            if(IsInArray(level.zbr_spawn_queue, player))
            {
                continue;
            }

            if(isdefined(player.spectatekillcam) && player.spectatekillcam)
            {
                continue;
            }

            if(isdefined(player.b_in_death_cutscene) && player.b_in_death_cutscene)
            {
                continue;
            }

            // if(isdefined(player.gm_respawn_time) && isdefined(player.gm_death_time) && player.gm_respawn_time > player.gm_death_time)
            // {
            //     continue;
            // }

            if(((gettime() - player.gm_death_time) / 1000) >= (PLAYER_RESPAWN_DELAY + 5)) // player escaped the spawn queue somehow
            {
                player.gm_death_time = gettime() - 1;
                player.gm_respawn_time = gettime();
                player thread respawn_enter_queue();
            }
        }
    }
}

respawn_exit_queue()
{
    if(isdefined(level.zbr_spawn_queue))
    {
        arrayremovevalue(level.zbr_spawn_queue, self, false);
    }
}

CleanupMusicCheck()
{
    foreach(player in level.players)
    {
        if(player.sessionstate == "playing" && isdefined(player.gm_objective_state) && player.gm_objective_state)
        {
            return;
        }
    }
    GM_KillMusic();
}

EntityHeadKillIcon(entity, offset, size, color)
{
    if(!isDefined(entity) || !isdefined(entity.sessionstate))
        return;
    
    if(entity.sessionstate != "playing")
        return;

    if(entity.b_is_designated_target === true && (entity bgb::is_enabled("zm_bgb_now_you_see_me")))
    {
        return;
    }
    
    shader = "t7_hud_zm_aat_turned";
	headicon = newHudElem();
	headicon.archived = 1;
	headicon.x = offset[0];
	headicon.y = offset[1];
	headicon.z = offset[2];
    headicon.color = color;
	headicon.alpha = 0.8;
	headicon SetShader(shader, int(size[0]), int(size[1]));
	headicon setWaypoint(false, shader, true, false);
	headicon SetTargetEnt(entity);

    if(!isdefined(entity.entityheadicons))
        entity.entityheadicons = [];

	entity.entityheadicons[entity.entityheadicons.size] = headicon;
}

KillHeadIcons(entity, force = false)
{
    if(!isdefined(entity))
    {
        return;
    }

    if(!force && (entity.sessionstate == "playing"))
    {
        if(entity.b_is_designated_target === true && (entity bgb::is_enabled("zm_bgb_now_you_see_me")))
        {
            return;
        }
    }

    if(!isdefined(entity.entityheadicons))
    {
        entity.entityheadicons = [];
    }

    foreach(icon in entity.entityheadicons)
    {
        icon destroy();
    }

    entity.entityheadicons = [];
}

end_game_hud(player, game_over, survived)
{
    player GM_DestroyHUD();
    game_over.alignX = "center";
    game_over.alignY = "middle";
    game_over.horzAlign = "center";
    game_over.vertAlign = "middle";
    game_over.y = game_over.y - 130;
    game_over.foreground = 1;
    game_over.fontscale = 3;
    game_over.alpha = 0;
    game_over.color = (1, 1, 1);
    game_over.hidewheninmenu = 1;

    tPrefix = (isdefined(level.gm_winner) && level.gm_winner.team == player.team) ? "^2" : "^1";

    if(isdefined(level.gm_winner))
        game_over setText(tPrefix + (is_zbr_teambased() ? toupper(level.gm_winner get_zbr_team_color_name()) : toupper(clean_name(level.gm_winner.name))) + " ^7WINS");
    else
        game_over setText("ROUND DRAW");
    
    game_over fadeOverTime(1);
    game_over.alpha = 1;
    if(player IsSplitscreen())
    {
        game_over.fontscale = 2;
        game_over.y = game_over.y + 40;
    }

    survived.alignX = "center";
    survived.alignY = "middle";
    survived.horzAlign = "center";
    survived.vertAlign = "middle";
    survived.y = survived.y - 100;
    survived.foreground = 1;
    survived.fontscale = 2;
    survived.alpha = 0;
    survived.color = (1, 1, 1);
    survived.hidewheninmenu = 1;
    if(player IsSplitscreen())
    {
        survived.fontscale = 1.5;
        survived.y = survived.y + 40;
    }

    // if(isdefined(level.gm_winner))
    // {
    //     nvials = player GM_MBVIALS();
    //     mbtext = "MATCH BONUS: ^2" + player GM_MBXP() + " ^3XP, ^2" + nvials + " ^3VIAL" + (nvials == 1 ? "" : "S");
    //     mbt = player createText("default", 2, "CENTER", "BOTTOM", 0, -190, 1, 1, mbtext, (1,1,1));
    //     mbt.hidewheninmenu = 1;
    //     mbt.foreground = true;
    // }
    
    if(!is_zbr_teambased())
    {
        other_players = player createText("default", 1.25, "CENTER", "BOTTOM", 0, -30, 1, 1, player gm_get_losers(), (1,1,1));
        other_players.hidewheninmenu = 1;
        other_players.foreground = true;
        other_players thread KillOnIntermission(survived);
    }

    credits = player createText("default", 1.25, "CENTER", "BOTTOM", 0, -50, 1, 0.5, "Thank you for playing Zombie Blood Rush, by Serious", (1,1,1));
    credits.hidewheninmenu = 1;
    credits.foreground = true;

    // if(isdefined(mbt))
    // {
    //     mbt thread KillOnIntermission(survived);
    // }
    credits thread KillOnIntermission(survived);
}

gm_get_losers()
{
    str_placements = "";
    places = ["^72nd", "^73rd", "^74th"];
    level.zbr_leaderboard ??= [];
    for(i = 1; i < level.zbr_leaderboard.size && i < 4; i++)
    {
        player = level.zbr_leaderboard[i];
        place = places[i - 1];
        str_placements += place + ": " + ((player == self) ? "^2" : "^7") + clean_name(player.name);
        if((i + 1) != level.zbr_leaderboard.size)
        {
            str_placements += "^7, ";
        }
    }
    return str_placements;
}

KillOnIntermission(h)
{
    h waittill("death");
    self destroy();
}

GM_MBXP()
{
    if(!isdefined(self.max_points_earned))
        self.max_points_earned = 500;

    if(self.max_points_earned < 0)
        self.max_points_earned = 0;
        
    max_points_earned = self.max_points_earned;
    if(max_points_earned > WIN_NUMPOINTS || (isdefined(self.gm_winner) && self.gm_winner))
        max_points_earned = WIN_NUMPOINTS;

    n_reward = max_points_earned / 50;
    s_wager = get_wager_tier(self.wager_tier);
    if(isdefined(s_wager) && isdefined(s_wager.bonus_currency))
    {
        n_reward *= s_wager.bonus_currency;
    }

    self AddRankXp("kill", undefined, undefined, false, true, int(n_reward));
    return int(n_reward);
}

GM_MBVIALS()
{
    if(!isdefined(self.max_points_earned))
        self.max_points_earned = 500;

    if(self.max_points_earned < 0)
        self.max_points_earned = 0;
        
    max_points_earned = self.max_points_earned;
    if(max_points_earned > WIN_NUMPOINTS || (isdefined(self.gm_winner) && self.gm_winner))
        max_points_earned = WIN_NUMPOINTS;

    numvials = int(max_points_earned / int(WIN_NUMPOINTS / 5));
    s_wager = get_wager_tier(self.wager_tier);
    if(isdefined(s_wager) && isdefined(s_wager.bonus_currency))
    {
        numvials = int(numvials * s_wager.bonus_currency);
    }

    self ReportLootReward("3", numvials);
    for(i = 0; i < numvials; i++)
        self incrementbgbtokensgained();

    self.var_f191a1fc += numvials;
    return numvials;
}

gm_spectator()
{
    self notify("gm_spectator");
    self endon("gm_spectator");
    self endon("disconnect");
    self endon("spawned_player");
    level endon("end_game");
    self waittill("spawned_spectator");
    
    wait 1;
    if(self.sessionstate == "playing") return;

    if(isdefined(self.spectate_obj))
        self.spectate_obj destroy();

    self.spectate_obj = spawn("script_origin", self.origin, 1);
    self PlayerLinkTo(self.spectate_obj, undefined);
    self enableweapons();
}

#define BASE_OFFSET = 110;
#define CLIENT_WHITE = 7;
#define CLIENT_BLUE = 1;
#define CLIENT_YELLOW = 2;
#define CLIENT_GREEN = 3;
#define CLIENT_PINK = 4;
#define CLIENT_CYAN = 5;
#define CLIENT_ORANGE = 6;
#define CLIENT_PURPLE = 0;
#define TEAM_BOX_BORDER_SIZE = 2;
#define HUD_BOX_HEIGHT = 8;
GM_CreateHUD()
{
    self notify("GM_CreateHUD");
    self endon("GM_CreateHUD");
    if(!(isdefined(self.objectives_shown_finished) && self.objectives_shown_finished))
    {
        return;
    }

    if(level.zbr_sudden_death is true)
    {
        return;
    }

    if(IS_DEBUG && DEBUG_NO_GM_HUD)
    {
        return;
    }
    
    if(self util::is_bot())
    {
        return;
    }

    if(!isdefined(self.sessionstate) || self.sessionstate != "playing")
    {
        return;
    }

    if(!USE_NEW_HUD)
    {
        if(!isdefined(self._bars))
            self._bars = [];

        if(!isdefined(self._team_bgs))
        {
            self._team_bgs = [];
        }

        if(!isdefined(self.gm_hud_hide))
            self.gm_hud_hide = false;

        if(level.fn_gm_createhud_gametype is function)
        {
            return self [[ level.fn_gm_createhud_gametype ]]();
        }

        if(is_zbr_teambased())
        {
            teammates = self get_zbr_teammates();
        }
        
        y_pos_base = ((self issplitscreen()) ? (BASE_OFFSET - 55) : BASE_OFFSET) + (is_zbr_teambased() ? ((get_zbr_teamsize() - 1) * -15) : 0);
        if(!isdefined(self._bars[self GetEntityNumber()]))
        {
            self._bars[self GetEntityNumber()] = self CreateProgressBar("LEFT", "LEFT", 17, y_pos_base, 50, HUD_BOX_HEIGHT, self GM_GetPlayerColor(), 1);
            self._bars[self GetEntityNumber()].player = self;
            self._bars[self GetEntityNumber()].box = self CreateCheckBox("LEFT", "LEFT", 69, y_pos_base, HUD_BOX_HEIGHT, self GM_GetPlayerColor(true), 1);
        }
        
        self UpdateGMProgress(self);

        // start at base offset, our team is always the bottom
        teams = gm_get_all_teams();
        team_offsets = [];
        team_offsets[self getgmteam()] = 0;

        // calc preallocated spaces for other teams
        previous_team = team_offsets[self getgmteam()];
        foreach(team in teams)
        {
            if(team == (self getgmteam())) continue;
            team_offsets[team] = previous_team + ((is_zbr_teambased() ? get_zbr_teamsize() : 1) * -10) + int(is_zbr_teambased() * -5);
            previous_team = team_offsets[team];
        }

        team_offsets[self getgmteam()] -= 10;

        foreach(player in level.players)
        {
            if(player == self) continue;
            if(!isdefined(self._bars[player GetEntityNumber()]))
            {
                y_pos = y_pos_base + team_offsets[player getgmteam()];
                self._bars[player GetEntityNumber()] = self CreateProgressBar("LEFT", "LEFT", 17, y_pos, 50, HUD_BOX_HEIGHT, player GM_GetPlayerColor(), 1);
                self._bars[player GetEntityNumber()].player = player;
                self._bars[player GetEntityNumber()].box = self CreateCheckBox("LEFT", "LEFT", 69, y_pos, HUD_BOX_HEIGHT, player GM_GetPlayerColor(true), 1);
            }
            team_offsets[player getgmteam()] += -10;
            self UpdateGMProgress(player);
        }

        if(is_zbr_teambased() && (get_zbr_teamsize() > 1) && getplayers().size < 5)
        {
            foreach(team in teams)
            {
                if(isdefined(self._team_bgs[team]))
                {
                    continue;
                }
                
                upper = self gm_find_highest_y_box(team);
                lower = self gm_find_lowest_y_box(team);

                if(!isdefined(upper) || !isdefined(lower))
                {
                    continue;
                }

                upper.y += int(HUD_BOX_HEIGHT / 2);
                lower.y -= int(HUD_BOX_HEIGHT / 2);

                box_w = lower.x - upper.x + HUD_BOX_HEIGHT;
                box_h = upper.y - lower.y;

                box_x = upper.x;
                box_y = upper.y - int((upper.y - lower.y) / 2);
                
                self._team_bgs[team] = self createRectangle("LEFT", "LEFT", box_x - TEAM_BOX_BORDER_SIZE, box_y, int(box_w + (TEAM_BOX_BORDER_SIZE * 2)), int(box_h + (TEAM_BOX_BORDER_SIZE * 2)), lower.player GM_GetPlayerColor(true, true), "white", 0, 1);
            }
        }

        return;
    }

    
}

gm_find_highest_y_box(team = self.team)
{
    if(!isdefined(self._bars))
    {
        return undefined;
    }

    y_pos = undefined;
    x_pos = undefined;
    foreach(bar in self._bars)
    {
        if(!isdefined(bar.player)) continue;
        if(bar.player.team != team) continue;
        if(!isdefined(y_pos) || bar.bg.y > y_pos)
        {
            y_pos = bar.bg.y;
            x_pos = bar.bg.x;
        }
    }

    if(!isdefined(x_pos))
    {
        return undefined;
    }

    stru = spawnStruct();
    stru.x = x_pos;
    stru.y = y_pos;
    return stru;
}

gm_find_lowest_y_box(team)
{
    if(!isdefined(self._bars))
    {
        return undefined;
    }

    y_pos = undefined;
    x_pos = undefined;
    __player = undefined;
    foreach(bar in self._bars)
    {
        if(!isdefined(bar.player)) continue;
        if(bar.player.team != team) continue;
        if(!isdefined(y_pos) || bar.box.bg.y < y_pos)
        {
            y_pos = bar.box.bg.y;
            x_pos = bar.box.bg.x;
            __player = bar.player;
        }
    }

    if(!isdefined(x_pos))
    {
        return undefined;
    }

    stru = spawnStruct();
    stru.x = x_pos;
    stru.y = y_pos;
    stru.player = __player;
    return stru;
}

gm_get_all_teams()
{
    teams = [];
    foreach(player in level.players)
    {
        array::add(teams, player getgmteam(), false);
    }
    return teams;
}

gm_hud_set_visible(visible = true, is_emp = false)
{
    if(IS_DEBUG && DEBUG_NO_GM_HUD) return;
    
    if(self util::is_bot())
        return;

    if(!USE_NEW_HUD)
    {
        if(!isdefined(self._bars))
            return;
    
        if(is_emp is true)
        {
            self.b_empjammed_hud = !visible;
            if(visible)
            {
                visible = self.requested_hud_state;
            }
        }
        else
        {
            if(self.b_empjammed_hud is true)
            {
                self.requested_hud_state = visible;
                visible = false;
            }
        }

        self.gm_hud_hide = !visible;
        foreach(bar in self._bars) 
        {
            self UpdateGMProgress(bar);
        }

        if(isdefined(self._team_bgs))
        {
            foreach(bg in self._team_bgs)
            {
                bg.alpha = visible;
                bg fadeOverTime(0.1);
            }
        }
        return;
    }
}

GM_GetPlayerColor(nored = false, teamcolor = false)
{
    if(!isdefined(self.score))
        self.score = 0;
    
    if(!nored && (self.gm_objective_completed || self.score >= self Get_PointsToWin()))
        return color(0xc90e0e);
    
    ent_index = (teamcolor && is_zbr_teambased()) ? (self get_zbr_team_color_index()) : (self getEntityNumber());
    // ent_index = self getEntityNumber();
    switch(ent_index)
    {
        case CLIENT_BLUE:
            return color(0x0a4cf2);

        case CLIENT_GREEN:
            return color(0x83e683);

        case CLIENT_YELLOW:
            return color(0xe6da83);

        case CLIENT_PINK:
            return color(0xff00bb);

        case CLIENT_CYAN:
            return color(0x00e1ff);

        case CLIENT_ORANGE:
            return color(0xff8c00);

        case CLIENT_PURPLE:
            return color(0x9452f7);
        
        default:
            return color(0xAAAAAA);
    }
}

get_zbr_team_color_index()
{
    return level.gm_team_colors[self.gm_id];
}

get_zbr_team_color_name()
{
    switch(level.gm_team_colors[self.gm_id])
    {
        case CLIENT_BLUE: return "Blue Team";
        case CLIENT_GREEN: return "Green Team";
        case CLIENT_YELLOW: return "Yellow Team";
        case CLIENT_PINK: return "Pink Team";
        case CLIENT_CYAN: return "Cyan Team";
        case CLIENT_ORANGE: return "Orange Team";
        case CLIENT_PURPLE: return "Purple Team";
        default: return "White Team";
    }
    return "White Team";
}

UpdateGMProgress(player_or_bar, dead = false)
{
    self endon("disconnect");

    if(self util::is_bot())
    {
        return;
    }

    if(level.zbr_sudden_death is true)
    {
        return;
    }

    if(!USE_NEW_HUD)
    {
        if(!isdefined(player_or_bar))
        {
            return;
        }

        if(!isdefined(self._bars))
        {
            self._bars = [];
        }

        if(isplayer(player_or_bar))
        {
            player = player_or_bar;
            bar = self._bars[player GetEntityNumber()];
        }
        else
        {
            bar = player_or_bar;
            player = bar.player;
        }

        if(!isdefined(bar))
        {
            return;
        }

        score = 0;
        ptw = WIN_NUMPOINTS;
        alive = false;
        objective_state = undefined;
        if(isdefined(player))
        {
            player endon("disconnect");
            if(!isdefined(player.gm_objective_state))
            {
                player.gm_objective_state = false;
            }
            if(!isdefined(player.score))
            {
                player.score = 0;
            }
            bar.dimmed = level.zbr_sudden_death is not true && (player.gm_objective_state || player.gm_objective_completed);
            bar.primarycolor = player GM_GetPlayerColor(true);
            bar.secondarycolor = player GM_GetPlayerColor();
            score = player.score;
            ptw = player Get_PointsToWin();
            alive = player.sessionstate == "playing";
            objective_state = level.zbr_sudden_death is not true && (player.gm_objective_state || player.gm_objective_completed);    

            if(!isdefined(player.gm_hud_hide))
            {
                player.gm_hud_hide = false;
            }  

            if(isdefined(player._team_bgs))
            {
                foreach(bg in player._team_bgs)
                {
                    bg.alpha = !player.gm_hud_hide;
                    bg fadeOverTime(0.1);
                }
            }  
        }

        SetProgressbarPercent(bar, float(score) / ptw);

        if(isdefined(bar.box))
        {
            SetChecked(bar.box, alive && !dead);
        }

        if(!isdefined(objective_state) || !objective_state)
        {
            SetProgressbarSecondaryPercent(bar, 0);
            return;
        }

        // player will be defined here because objective_state is undefined otherwise, which returns in the previous check
        if(!isdefined(player.gm_objective_timesurvived))
        {
            player.gm_objective_timesurvived = 0;
        }

        SetProgressbarSecondaryPercent(bar, ((level.zbr_sudden_death is true or player.gm_objective_completed) ? (float(score) / ptw) : (player.gm_objective_timesurvived / player get_gm_time_to_win())));
        return;
    }
    
}

on_player_disconnect()
{
    bgb_fith_terminate();
    ent = self getEntityNumber();
    foreach(player in level.players)
    {
        if(player == self) continue;
        player update_gm_speed_boost(self);

        if(!isdefined(player._bars)) continue;
        bar = player._bars[ent];
        if(!isdefined(bar)) continue;
        bar.dimmed = false;
        bar.primarycolor = (0,0,0);
        bar.secondarycolor = (0,0,0);
        player SetProgressbarSecondaryPercent(bar, 0);
        player thread SetProgressbarPercent(bar, 0);
        if(isdefined(bar.box))
        {
            player thread SetChecked(bar.box, false);
        }
    }
}

color(value)
{
    return
    (
    (value & 0xFF0000) / 0xFF0000,
    (value & 0x00FF00) / 0x00FF00,
    (value & 0x0000FF) / 0x0000FF
    );
}

GM_DestroyHUD()
{
    if(self util::is_bot())
        return;

    if(!USE_NEW_HUD)
    {
        if(!isdefined(self._bars))
            self._bars = [];

        foreach(hud in self._bars)
        {
            if(isdefined(hud.bg))
            {
                hud.bg destroy();
            }
            
            if(isdefined(hud.fill))
            {
                hud.fill destroy();
            }
            
            if(isdefined(hud.bgfill))
                hud.bgfill destroy();

            if(isdefined(hud.box))
            {
                if(isdefined(hud.box.bg))
                    hud.box.bg destroy();

                if(isdefined(hud.box.fill))
                    hud.box.fill destroy();
            }
        }
        self._bars = [];
        if(self._team_bgs is defined)
        {
            foreach(hud in self._team_bgs)
            {
                hud destroy();
            }
            self._team_bgs = [];
        }
        return;
    }
}

gm_get_objective_points_string()
{
    points_str = "" + WIN_NUMPOINTS;
    final_str = "";
    counter = 0;
    for(i = points_str.size - 1; i > -1; i--)
    {
        if(counter && !(counter % 3))
        {
            final_str = "," + final_str;
        }
        final_str = points_str[i] + final_str;
        counter++;
    }
    return final_str;
}

gm_get_objective_win_string()
{
    time = OBJECTIVE_WIN_TIME;
    minutes = int(OBJECTIVE_WIN_TIME / 60);
    seconds = int(time - minutes * 60);
    if(!minutes)
    {
        return seconds + " seconds";
    }
    if(!seconds)
    {
        if(minutes == 1)
        {
            return "1 minute";
        }
        return minutes + " minutes";
    }
    if(minutes == 1)
    {
        return "1 minute" + " and " + seconds + " seconds";
    }
    return minutes + " minutes" + " and " + seconds + " seconds";
}

#define OBJECTIVE_HUD_OFF_Y = 50;
#define OBJECTIVE_Y_SPACE = 20;
GM_ShowObjectives()
{
    self endon("disconnect");
    if(isdefined(self.objectives_shown))
    {
        self GM_CreateHUD();
        return;
    } 
    
    self.objectives_shown = true;

    level flag::wait_till("initial_blackscreen_passed");
    
    if(level.fn_zbr_custom_objectives is defined)
    {
        obj = self [[ level.fn_zbr_custom_objectives ]]();
    }
    else
    {
        obj = 
        [
            "Your points are now your health",
            "Kill zombies and other players to gain points",
            "Hold " + gm_get_objective_points_string() + " points for " + gm_get_objective_win_string() + " to win"
        ];
    }

    i = 0;
    foreach(o in obj)
    {
        hud = self createText("objective", 2, "TOPLEFT", "TOPLEFT", 25, OBJECTIVE_HUD_OFF_Y + i * OBJECTIVE_Y_SPACE, 1, 1, o, (.75,.75,1));
        hud setCOD7DecodeFX(int(OBJECTIVE_DECODE_TIME * 1000 / o.size), (OBJECTIVE_SHOW_TIME - 1) * 1000, 500);
        hud thread KillObjective();
        wait .5;
        i++;
    }

    wait OBJECTIVE_SHOW_TIME;
    self.objectives_shown_finished = true;
    wait .1;
    self GM_CreateHUD();
}

KillObjective()
{
    wait OBJECTIVE_SHOW_TIME;
    self destroy();
}

apply_door_prices()
{
    a_door_buys = getentarray("zombie_door", "targetname");
    array::thread_all(a_door_buys, serious::door_price_reduction);
    a_debris_buys = getentarray("zombie_debris", "targetname");
    array::thread_all(a_debris_buys, serious::door_price_reduction);
}

door_price_reduction()
{
    if(!isdefined(self.zombie_cost))
    {
        return;
    }
	if(self.zombie_cost >= DOOR_REDUCE_MIN_PRICE)
	{
		if(self.zombie_cost >= DOOR_REDUCE_TWICE_MIN_PRICE) // do it twice for doors which are this expensive
		{
			self.zombie_cost = self.zombie_cost - DOOR_REDUCE_AMOUNT;
		}
        self.zombie_cost = self.zombie_cost - DOOR_REDUCE_AMOUNT;
		if(self.targetname == "zombie_door")
		{
			self zm_utility::set_hint_string(self, "default_buy_door", self.zombie_cost);
		}
		else
		{
			self zm_utility::set_hint_string(self, "default_buy_debris", self.zombie_cost);
		}
	}
}

// fixes an issue where the game resets players health to 100 each round
quick_revive_hook()
{
    if(isdefined(level._check_quickrevive_hotjoin))
    {
        self [[ level._check_quickrevive_hotjoin ]]();
    }

    level flag::clear("solo_game");

	foreach(player in getplayers())
    {
        player thread Event_PointsAdjusted();
    }
}

player_score_override(damage_weapon, n_score)
{
    if(isdefined(level._player_score_override))
    {
        n_score = self [[level._player_score_override]](damage_weapon, n_score);
    }
    if(isdefined(n_score) && isdefined(self.wager_zm_points_mod) && isdefined(self.wager_zm_points_drop))
    {
        if(n_score == 10 || n_score == 20)
        {
            self.wager_zm_points_drop = (self.wager_zm_points_drop + 1) % 4;
            if(!self.wager_zm_points_drop)
            {
                return 0;
            }
        }
        n_score = int(n_score * self.wager_zm_points_mod);
    }
    return n_score;
}

get_player_weapon_limit(player, no_perk = false)
{
    weapon_limit = 2;
    if(isdefined(player.wager_weapon_slot))
    {
        weapon_limit--;
    }
	if(!no_perk && (player hasperk("specialty_additionalprimaryweapon")))
	{
		weapon_limit++;
	}
    return weapon_limit;
}

mulekick_take(b_pause, str_perk, str_result)
{
    if(b_pause || str_result == str_perk)
	{
		self take_additionalprimaryweapon();
	}
}

take_additionalprimaryweapon()
{
	weapon_to_take = level.weaponnone;
	if(isdefined(self._retain_perks) && self._retain_perks || (isdefined(self._retain_perks_array) && (isdefined(self._retain_perks_array["specialty_additionalprimaryweapon"]) && self._retain_perks_array["specialty_additionalprimaryweapon"])))
	{
		return weapon_to_take;
	}
	primary_weapons_that_can_be_taken = [];
	primaryweapons = self getweaponslistprimaries();
	for(i = 0; i < primaryweapons.size; i++)
	{
		if(zm_weapons::is_weapon_included(primaryweapons[i]) || zm_weapons::is_weapon_upgraded(primaryweapons[i]))
		{
			primary_weapons_that_can_be_taken[primary_weapons_that_can_be_taken.size] = primaryweapons[i];
		}
	}
	self.weapons_taken_by_losing_specialty_additionalprimaryweapon = [];
	pwtcbt = primary_weapons_that_can_be_taken.size;
	while(pwtcbt > get_player_weapon_limit(self))
	{
		weapon_to_take = primary_weapons_that_can_be_taken[pwtcbt - 1];
		self.weapons_taken_by_losing_specialty_additionalprimaryweapon[weapon_to_take] = zm_weapons::get_player_weapondata(self, weapon_to_take);
		pwtcbt--;
		if(weapon_to_take == self getcurrentweapon())
		{
			self switchtoweapon(primary_weapons_that_can_be_taken[0]);
		}
		self takeweapon(weapon_to_take);
	}
	return weapon_to_take;
}

watch_falling_forever()
{
    self endon("bled_out");
    self endon("spawned_player");
    self endon("disconnect");

    for(;;)
    {
        wait 1;
        origin = self.origin;
        if(!isdefined(origin)) continue;
        if(origin[2] <= -20000)
        {
            self doDamage(int(self.maxhealth + 1), self.origin);
        }
    }
}

zm_round_failsafe()
{
    level notify("_zm_round_failsafe");
    level endon("_zm_round_failsafe");
    level endon("game_ended");
    for(;;)
    {
        if(level.zbr_sudden_death is true)
        {
            return;
        }
        i = 0;
        while(getaiteamarray(level.zombie_team).size < 5 && i < ROUND_NO_AI_TIMEOUT)
        {
            i++;
            wait 1;
        }
        if(ROUND_NO_AI_TIMEOUT <= i)
        {
            goto_round(level.round_number + 1);
            wait 25;
        }
        wait 5;
    }
}

quick_revive_fix()
{
    if(zm_perks::use_solo_revive())
    {
        self.lives = 1;
    }
}

is_zbr_teambased()
{
    return ZBR_TEAMS /*|| (getdvarint("com_maxclients", 4) > 4)*/;
}

get_zbr_teamsize()
{
    n_teamsize = int(max(2, min(ZBR_TEAMSIZE, 8)));
    // if(getdvarint("com_maxclients", 4) > 4)
    // {
    //     // we literally dont have enough game teams for > 4 teams
    //     return int(max(2, n_teamsize));
    // }
    return n_teamsize;
}

get_zbr_teammates(b_check_alive = false)
{
    teammates = [];
    if(!isdefined(self.gm_id))
    {
        return teammates;
    }
    foreach(player in level.players)
    {
        if(player == self)
        {
            continue;
        }
        if((player.gm_id ?? -1) != self.gm_id)
        {
            continue;
        }
        if(b_check_alive && (player.sessionstate != "playing" || player laststand::player_is_in_laststand()))
        {
            continue;
        }
        array::add(teammates, player, false);
    }
    return teammates;
}

get_zbr_enemies(b_check_alive = false)
{
    enemies = [];
    if(!isdefined(self.gm_id))
    {
        return enemies;
    }
    foreach(player in level.players)
    {
        if(player == self)
        {
            continue;
        }
        if((player.gm_id ?? -1) == self.gm_id)
        {
            continue;
        }
        if(b_check_alive && (player.sessionstate != "playing" || player laststand::player_is_in_laststand()))
        {
            continue;
        }
        array::add(enemies, player, false);
    }
    return enemies;
}

get_zbr_team_players(team, b_check_alive = false)
{
    plrs = [];
    foreach(player in level.players)
    {
        if(player getgmteam() != team)
        {
            continue;
        }
        if(b_check_alive && (player.sessionstate != "playing" || player laststand::player_is_in_laststand()))
        {
            continue;
        }
        array::add(plrs, player, false);
    }
    return plrs;
}

get_zbr_team_index()
{
    return self.gm_id;
}

_zombienotetrackmeleefire(entity)
{
	if(isdefined(entity.aat_turned) && entity.aat_turned)
	{
		if(isdefined(entity.enemy))
		{
            if(isplayer(entity.enemy))
            {
                if(entity.enemy.team == entity.team)
                {
                    return;
                }
                if(entity.enemy.bgb_in_plain_sight_active is true)
                {
                    return;
                }
                if(entity.enemy.bgb_idle_eyes_active is true)
                {
                    return;
                }
                entity melee();
                return;
            }
			if(entity.enemy.archetype == "zombie" && (isdefined(entity.enemy.allowdeath) && entity.enemy.allowdeath))
			{
				gibserverutils::gibhead(entity.enemy);
				entity.enemy zombie_utility::gib_random_parts();
				entity.enemy dodamage(entity.enemy.health + 666, entity.enemy.origin + (0, 0, 50), entity.owner);
                foreach(ent in getaiteamarray(level.zombie_team))
                {
                    if(!isalive(ent))
                    {
                        continue;
                    }
                    if(entity.enemy == ent)
                    {
                        continue;
                    }
                    if(entity == ent)
                    {
                        continue;
                    }
                    if(distancesquared(ent.origin, entity.origin) <= 22500)
                    {
                        gibserverutils::gibhead(ent);
                        ent zombie_utility::gib_random_parts();
                        ent dodamage(ent.health + 666, ent.origin + (0, 0, 50), entity.owner);
                    }
                }
				entity.n_aat_turned_zombie_kills++;
			}
			else
			{
				if(entity.enemy.archetype == "zombie_quad" || entity.enemy.archetype == "spider" && (isdefined(entity.enemy.allowdeath) && entity.enemy.allowdeath))
				{
					entity.enemy dodamage(entity.enemy.health + 666, entity.origin, entity.owner);
					entity.n_aat_turned_zombie_kills++;
				}
				else if(isdefined(entity.enemy.canbetargetedbyturnedzombies) && entity.enemy.canbetargetedbyturnedzombies)
				{
					entity melee();
				}
			}
		}
        return;
	}
	zombiebehavior::zombienotetrackmeleefire(entity);
}

find_flesh_verify(behaviortreeentity)
{
    self endon("death");
    if(!isdefined(behaviortreeentity))
    {
        return;
    }
    if(isdefined(behaviortreeentity.enablepushtime))
	{
		if(gettime() >= behaviortreeentity.enablepushtime)
		{
			behaviortreeentity pushactors(1);
			behaviortreeentity.enablepushtime = undefined;
		}
	}
	if(getdvarint("scr_zm_use_code_enemy_selection", 0))
	{
		zombiefindfleshcode(behaviortreeentity);
		return;
	}
	if(level.intermission)
	{
		return;
	}
	if(behaviortreeentity getpathmode() == "dont move")
	{
		return;
	}
	behaviortreeentity.ignoreme = 0;
	behaviortreeentity.ignore_player = [];
	behaviortreeentity.goalradius = 30;
	if(isdefined(behaviortreeentity.ignore_find_flesh) && behaviortreeentity.ignore_find_flesh)
	{
		return;
	}
	if(behaviortreeentity.team != level.zombie_team)
	{
		behaviortreeentity zbr_findzombieenemy();
		return;
	}
    self zm_behavior::zombiefindflesh(behaviortreeentity);
}

// TODO: note: this is probably the gersch zm_moon issue
zombiefindfleshcode(behaviortreeentity)
{
	aiprofile_beginentry("zombieFindFleshCode");
	if(level.intermission)
	{
		aiprofile_endentry();
		return;
	}
	behaviortreeentity.ignore_player = [];
	behaviortreeentity.goalradius = 30;
	if(behaviortreeentity.team != level.zombie_team)
	{
		behaviortreeentity zbr_findzombieenemy();
		aiprofile_endentry();
		return;
	}
	if(level.zombie_poi_array.size > 0)
	{
		zombie_poi = behaviortreeentity zm_utility::get_zombie_point_of_interest(behaviortreeentity.origin);
	}
	behaviortreeentity zombie_utility::run_ignore_player_handler();
	zm_utility::update_valid_players(behaviortreeentity.origin, behaviortreeentity.ignore_player);
	if(!isdefined(behaviortreeentity.enemy) && !isdefined(zombie_poi))
	{
		if(isdefined(level.no_target_override))
		{
			[[level.no_target_override]](behaviortreeentity);
		}
		else
		{
			behaviortreeentity setgoal(behaviortreeentity.origin);
		}
		aiprofile_endentry();
		return;
	}
	behaviortreeentity.enemyoverride = zombie_poi;
	if(isdefined(behaviortreeentity.enemyoverride) && isdefined(behaviortreeentity.enemyoverride[1]))
	{
		behaviortreeentity.has_exit_point = undefined;
		goalpos = behaviortreeentity.enemyoverride[0];
		queryresult = positionquery_source_navigation(goalpos, 0, 48, 36, 4);
		foreach(point in queryresult.data)
		{
			goalpos = point.origin;
			break;
		}
		behaviortreeentity setgoal(goalpos);
	}
	else if(isdefined(behaviortreeentity.enemy))
	{
		behaviortreeentity.has_exit_point = undefined;
		if(isdefined(level.enemy_location_override_func))
		{
			goalpos = [[level.enemy_location_override_func]](behaviortreeentity, behaviortreeentity.enemy);
			if(isdefined(goalpos))
			{
				behaviortreeentity setgoal(goalpos);
			}
			else
			{
				behaviortreeentity zm_behavior::zombieupdategoalcode();
			}
		}
		else if(isdefined(behaviortreeentity.enemy.last_valid_position))
		{
			behaviortreeentity zm_behavior::zombieupdategoalcode();
		}
	}
	aiprofile_endentry();
}

update_valid_players_custom(origin, ignore_player)
{
	valid_player_found = 0;
	players = arraycopy(level.players);
	foreach(player in players)
	{
		self setignoreent(player, 1);
	}
	b_designated_target_exists = undefined;
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if(!player.am_i_valid)
		{
            array::add(ignore_player, player);
			continue;
		}
        if(player.team == self.team)
        {
            array::add(ignore_player, player);
            continue;
        }
		if(isdefined(level.evaluate_zone_path_override))
		{
			if(![[level.evaluate_zone_path_override]](player))
			{
				array::add(ignore_player, player);
			}
		}
		if(isdefined(player.b_is_designated_target) && player.b_is_designated_target)
		{
			b_designated_target_exists = player;
		}
	}
	if(isdefined(ignore_player))
	{
		for(i = 0; i < ignore_player.size; i++)
		{
			arrayremovevalue(players, ignore_player[i]);
		}
	}
    if(isdefined(b_designated_target_exists))
    {
        players = array(b_designated_target_exists);
    }
    else
    {
        players = array::get_all_closest(self.origin, players, undefined, undefined, 1000);
    }
	
	foreach(player in players)
	{
		self setignoreent(player, 0);
		self getperfectinfo(player);
	}

    if(players.size)
    {
        return players[0];
    }

    return undefined;
}

zbr_findzombieenemy()
{
    zombies = getaispeciesarray(level.zombie_team, "all");
	zombie_enemy = undefined;
	closest_dist = undefined;

    if(isdefined(self.owner))
    {
        self.ignore_player ??= [];
        zombie_enemy = update_valid_players_custom(self.origin, self.ignore_player);
    }

    if(zombie_enemy is undefined)
    {
        foreach(zombie in zombies)
        {
            if(isalive(zombie) && (isdefined(zombie.completed_emerging_into_playable_area) && zombie.completed_emerging_into_playable_area) && !zm_utility::is_magic_bullet_shield_enabled(zombie) && (zombie.archetype == "zombie" || (isdefined(zombie.canbetargetedbyturnedzombies) && zombie.canbetargetedbyturnedzombies)))
            {
                dist = distancesquared(self.origin, zombie.origin);
                if(!isdefined(closest_dist) || dist < closest_dist)
                {
                    closest_dist = dist;
                    zombie_enemy = zombie;
                }
            }
        }
    }

	self.favoriteenemy = zombie_enemy;
	if(isdefined(self.favoriteenemy))
	{
		self setgoal(self.favoriteenemy.origin);
	}
	else
	{
		self setgoal(self.origin);
	}
}

gm_teammate_visibility()
{
    if(!is_zbr_teambased())
    {
        return;
    }
    if(isdefined(self.zbr_team_visibility))
    {
        self.zbr_team_visibility delete();
    }
    self.zbr_team_visibility = spawn("script_model", self geteye());
    self.zbr_team_visibility setmodel("tag_origin");
    self.zbr_team_visibility linkto(self, "j_helmet");
    self.zbr_team_visibility setinvisibletoplayer(self, true);
    self.zbr_team_visibility clientfield::set("powerup_fx", 2);
    foreach(player in level.players)
    {
        if(player == self)
        {
            continue;
        }
        if(player.team != self.team)
        {
            self.zbr_team_visibility setinvisibletoplayer(player, true);
            if(isdefined(player.zbr_team_visibility))
            {
                player.zbr_team_visibility setinvisibletoplayer(self, true);
            }
        }
        else
        {
            self.zbr_team_visibility setinvisibletoplayer(player, false);
            if(isdefined(player.zbr_team_visibility))
            {
                player.zbr_team_visibility setinvisibletoplayer(self, false);
            }
        }
    }
}

get_zbr_valid_players()
{
    players = [];
    foreach(player in getplayers())
    {
        if(player.sessionstate == "playing")
        {
            players[players.size] = player;
        }
    }
    return players;
}

watch_in_combat()
{
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");

    self.gm_in_combat = false;
    for(;;)
    {
        msg = self util::waittill_any_timeout(5, "damage", "weapon_fired", "grenade_fire", "bulletwhizby");
        self.gm_in_combat = (!isdefined(msg) || msg != "timeout");
    }
}

custom_intermission()
{
    self thread [[ level._custom_intermission ]]();
    wait 0.05;
    self.score = isdefined(self.max_points_earned) ? self.max_points_earned : self.score;
}

gm_using_killcams()
{
    return level.zbr_disable_killcams !== true; //IS_DEBUG && DEBUG_USE_KILLCAMS;
}

zm_custom_spawn_location_selection(a_spots = [])
{
    if(!isarray(a_spots))
    {
        a_spots = [];
    }
    
    s_spot = undefined;
    if(isdefined(level._zm_custom_spawn_location_selection))
    {
        s_spot = self [[ level._zm_custom_spawn_location_selection ]](a_spots);
    }

    if(!isdefined(s_spot))
    {
        if(isdefined(a_spots.size) && a_spots.size)
        {
            return array::random(a_spots);
        }
    }

    // this is *really* bad edge case lmao. we override level.move_spawn_func so that if this is undefined the game doesnt panic crash
    return s_spot;
}

move_spawn_func(spot)
{
    if(!isdefined(spot))
    {
        if(isdefined(self.spawn_pos))
        {
            self notify("risen", self.spawn_pos.script_string);
            return;
        }

        e_zomb = undefined;
        foreach(ent in getaiteamarray(level.zombie_team))
        {
            if(ent == self)
            {
                continue;
            }
            if(!isdefined(ent.spawn_pos))
            {
                continue;
            }
            e_zomb = ent;
            break;
        }

        if(!isdefined(e_zomb))
        {
            self delete();
            return;
        }

        spot = e_zomb.spawn_pos; // copy another zombie's spawn pos
    }
    self [[ level._move_spawn_func ]](spot);
}

give_custom_loadout()
{
    self giveweapon(level.weaponbasemelee);
    self zm_weapons::weapon_give(level.start_weapon, 0, 0, 1, 0);
    self givemaxammo(level.start_weapon);

    spawnweapon = compiler::getspawnweapon(self getxuid(false));
    switch(spawnweapon)
    {
        case 1:
            self zm_weapons::weapon_give(level.zbr_knife, 0, 0, 1, true);
        break;
        default:
            self zm_weapons::weapon_give(level.super_ee_weapon, 0, 0, 1, true);
            self givemaxammo(level.super_ee_weapon);
        break;
    }
}

set_max_ai(n_num = 24)
{
    if(n_num > 56)
    {
        n_num = 56; // leave at least 8 sentient vehicle spots
    }
    if(n_num < 24)
    {
        n_num = 24;
    }
    if(isdefined(level.zbr_max_ai_override) && n_num > level.zbr_max_ai_override)
    {
        n_num = level.zbr_max_ai_override;
    }

    n_num = int(n_num);

    // too lazy to figure out if the PDB is mismatched from the game so ill just set it to 3 different acceptible capacities. If one exceeds harcoded cap, it will silent error and fallback to the previous.
    SetAILimit(64);
    SetAILimit(80);
    SetAILimit(85);

    level.zombie_ai_limit = n_num;
    level.zombie_actor_limit = n_num + 8;
    return n_num;
}

calc_zbr_ai_count(round = level.round_number)
{
    if(!isdefined(round))
    {
        return;
    }

    n_players = getplayers().size;
    n_round = round;
    n_min_ai = 24;
    n_max_ai = int(n_min_ai + (8 * 4)); // 56

    n_current = n_min_ai;
    n_current += int(max(0, n_players - 1) * 4); // add 4 additional zombies per player in the lobby at start of game

    n_fifths = max(0, int((level.round_number - 5) / 5)); // every fifth round after round 5
    n_current += int(n_players * n_fifths); // add another zombie to the total ai count for each player in the game

    n_ai = int(min(n_current, n_max_ai));
    return set_max_ai(n_ai);
}

clean_name(str_playername)
{
    str_cleaned = "";

    if(!isdefined(str_playername))
    {
        return "unknown";
    }

    for(i = 0; i < str_playername.size; i++)
    {
        switch(str_playername[i])
        {
            case "^":
            case "{":
            case "}":
            case "&":
            case "%":
            break;
            default:
                str_cleaned += str_playername[i];
            break;
        }
    }

    return str_cleaned;
}

register_zombie_damage_callback(func)
{
	if(!isdefined(level.zombie_damage_callbacks))
	{
		level.zombie_damage_callbacks = [];
	}
	level.zombie_damage_callbacks = arraycombine(array(func), level.zombie_damage_callbacks, false, false);
}

register_zombie_death_animscript_callback(func)
{
	if(!isdefined(level.zombie_death_animscript_callbacks))
	{
		level.zombie_death_animscript_callbacks = [];
	}
	level.zombie_death_animscript_callbacks = arraycombine(array(func), level.zombie_death_animscript_callbacks, false, false);
}

set_player_burn(time)
{
    self endon("disconnect");
    self endon("death");
    self endon("bled_out");
    if(self.is_zbr_burning)
    {
        return;
    }
    self.is_zbr_burning = true;
    self clientfield::set("zbr_burn_bf", 1);
    result = self util::waittill_any_timeout(time, "bled_out", "disconnect", "player_downed", "stop_burning");
    if(isdefined(result) && result == "disconnect")
    {
        return;
    }
    self clientfield::set("zbr_burn_bf", 0);
    self.is_zbr_burning = false;
}

update_discord_presence()
{
    self notify("update_discord_presence");
    self endon("update_discord_presence");
    wait 5;
    switch(level.zbr_gametype)
    {
        case "zbr":
            result = is_zbr_teambased() ? ((ZBR_TEAMSIZE == 2) ? "Duos" : ((ZBR_TEAMSIZE == 3) ? "Trios" : "Quads")) : "Solos";
        break;
        default:
            result = MakeLocalizedString("ZMUI_GAMETYPE_" + toupper(level.zbr_gametype));
        break;
    }
    result += "," + getplayers().size;
    result += "," + (GetDvarInt("com_maxclients", 4) ?? "4");
    foreach(player in getplayers())
    {
        player SetControllerUIModelValue("presence.current", result);
    }
}

spawn_player_hook()
{
    self notify("spawn_player_hook");
    self endon("spawn_player_hook");
    self endon("disconnect");

    while(isdefined(self.b_in_death_cutscene) && self.b_in_death_cutscene)
    {
        wait 1;
    }

    wait 1;

    if(IsFunctionPtr(level._spawnplayer))
    {
        return self [[ level._spawnplayer ]]();
    }
}

get_aat_damage_multiplier()
{
    return self bgb::is_active("zm_bgb_lucky_crit") ? AAT_INCREASED_DAMAGE_SCALAR : 1;
}

atan2( y, x )
{
    if( x > 0 )
        return ATan( y / x );
    if( x < 0 && y >= 0 )
        return ATan( y / x ) + 180;
    if( x < 0 && y < 0 )
        return ATan( y / x ) - 180;
    if( x == 0 && y > 0 )
        return 90;
    if( x == 0 && y < 0 )
        return -90;
    return 0;
}

vortex_suck_players(vortex, lifespan_left, damage = 250)
{
    self endon("disconnect");
    vortex endon("death");

    spin_tangential_velocity = 400;
    dist_to_center = 150;
    n_target_height = 40;
    max = dist_to_center * dist_to_center;
    
    i = 0;
    for(;;)
    {
        lifespan_left = max(0.1, lifespan_left - 0.05);
        foreach(player in getplayers())
        {
            if(player.team == self.team)
            {
                continue;
            }

            if(player.sessionstate != "playing")
            {
                continue;
            }

            if(distancesquared(player.origin, vortex.origin) > max + 100)
            {
                continue;
            }

            // calc centripital velocity
            mid_pull_vector = vortex.origin - player.origin;
            mid_pull_vector = (mid_pull_vector[0], mid_pull_vector[1], 0);
            r = distance(mid_pull_vector, (0, 0, 0));
            v_centripital_magnitude = r / min(1.0, lifespan_left);
            mid_pull_final = v_centripital_magnitude * vectorNormalize(mid_pull_vector);
            
            // calculate tangential velocity
            angle = atan2(-1 * mid_pull_vector[1], -1 * mid_pull_vector[0]) + 90;
            x_t_comp = cos(angle) * spin_tangential_velocity;
            y_t_comp = sin(angle) * spin_tangential_velocity;
            tan_velocity = (x_t_comp, y_t_comp, 0);

            // calc final velocity
            final_velocity = mid_pull_final + tan_velocity + (0, 0, ((vortex.origin[2] + n_target_height - player.origin[2]) / 0.2) + (player GetPlayerGravity() * 0.05 * 0.05));

            // adjust for low grav
            final_velocity = (final_velocity[0], final_velocity[1], final_velocity[2] * (player GetPlayerGravity() / 800));

            if(player isOnGround())
            {
                player setorigin(player getorigin() + (0,0,5));
            }

            player setVelocity(final_velocity);
        }

        if(!(i % 10))
        {
            radiusdamage(vortex.origin + vectorscale((0, 0, 1), 24), 150, int(damage * CLAMPED_ROUND_NUMBER), int(damage * CLAMPED_ROUND_NUMBER - 1), self, "MOD_UNKNOWN", level.weaponnone);
        }

        wait 0.05;
        i++;
    }
}

damage3d(attacker, point = (0, 0, 0), amount = 0, type = DAMAGE_TYPE_ANY)
{
    if(!isplayer(attacker))
    {
        return;
    }
    
    if(amount < 0)
    {
        return;
    }

    clientIndex = attacker GetEntityNumber();
    mask = 1 << clientIndex;

    // foreach(player in getplayers())
    // {
    //     if(isdefined(player.archivetime) && player.archivetime != 0)
    //     {
    //         continue;
    //     }
    //     if(player.spectatorclient == clientIndex)
    //     {
    //         mask |= 1 << (player GetEntityNumber());
    //     }
    // }

    compiler::damage3d_notify(mask, int(point[0]), int(point[1]), int(point[2]), int(amount), int(type));
}

get_round_damage_boost()
{
    return 1 + level.player_weapon_boost;
}

character_update_watcher()
{
    level endon("end_game");
    for(;;)
    {
        level waittill("zbr_character_update", who, character);
        
        if(!isdefined(who))
        {
            continue;
        }

        foreach(player in getplayers())
        {
            if((player getxuid(true)) != who)
            {
                continue;
            }
            player set_character_for_player(character);
        }
    }
}

get_sudden_death_round_goal()
{
    if(getplayers().size < 4)
    {
        return SUDDEN_DEATH_ROUNDS;
    }
    return SUDDEN_DEATH_ROUNDS - (getplayers().size - 3);
}

gm_check_sudden_death()
{
    if(SUDDEN_DEATH_MODE == SUDDEN_DEATH_DISABLED)
    {
        return;
    }

    if(level.zbr_sudden_death is true)
    {
        return;
    }

    if(level.zbr_no_sudden_death_debug is true)
    {
        return;
    }

    b_should_run_sd = false;

    if(SUDDEN_DEATH_MODE & SUDDEN_DEATH_ROUNDBASED)
    {
        if(level.round_number < get_sudden_death_round_goal())
        {
            if((level.zbr_sudden_death_warned is not true) && (get_sudden_death_round_goal() - level.round_number == 1))
            {
                foreach(player in getplayers())
                {
                    player iPrintLnBold("^1WARNING: SUDDEN DEATH APPROACHING");
                }
                level.zbr_sudden_death_warned = true;
            }
        }
        else
        {
            b_should_run_sd = true;
        }
    }

    if(SUDDEN_DEATH_MODE & SUDDEN_DEATH_TIMEBASED)
    {
        if(level.game_mode_init_time is undefined)
        {
            level.game_mode_init_time = gettime();
        }
        if((gettime() - level.game_mode_init_time) < (SUDDEN_DEATH_TIME * 1000 * 60))
        {
            if((level.zbr_sudden_death_warned is not true) && ((SUDDEN_DEATH_TIME * 1000 * 60) - (gettime() - level.game_mode_init_time)) < (1 * 1000 * 60))
            {
                level.zbr_sudden_death_warned = true;
                foreach(player in getplayers())
                {
                    player iPrintLnBold("^1WARNING: SUDDEN DEATH APPROACHING");
                    player iPrintLn("^1One minute remains.");
                }
            }
        }
        else
        {
            b_should_run_sd = true;
        }
    }
    
    if(b_should_run_sd)
    {
        level thread gm_start_sudden_death();
    }
}

gm_sudden_death_timer()
{
    if(!(SUDDEN_DEATH_MODE & SUDDEN_DEATH_TIMEBASED))
    {
        return;
    }
    
    level endon("end_game");
    level endon("stop_zbr_sd_check");
    last_warned_time = -1;
    while(!level.players.size || (level.players[0].objectives_shown_finished is not true)) wait 0.25;
    for(;;)
    {
        gm_check_sudden_death();

        if(level.zbr_sudden_death is true)
        {
            return;
        }

        if(SUDDEN_DEATH_MODE & SUDDEN_DEATH_TIMEBASED)
        {
            time_remaining = int(((SUDDEN_DEATH_TIME * 60 * 1000) - (gettime() - level.game_mode_init_time)) / 1000 / 60);
            if(last_warned_time == -1 || (time_remaining > 0 && time_remaining != last_warned_time && !(time_remaining % 5)))
            {
                last_warned_time = time_remaining;
                time_remaining = int(time_remaining);
                foreach(player in getplayers())
                {
                    player iPrintLn(time_remaining + " minutes remain.");
                }
            }
        }

        wait 0.5;
    }
}

gm_start_sudden_death()
{
    if(level.zbr_sudden_death is true)
    {
        return;
    }

    level notify("stop_zbr_sd_check");
    level.zbr_sudden_death = true;
    level.zbr_sudden_death_timepassed = 0;
    level.zbr_sudden_death_timegoal = (3 * 60 + 10) as int;

    if(isdefined(level.zbr_sd_started))
    {
        thread [[ level.zbr_sd_started ]]();
    }

    gm_sd_setup();
    level.zbr_sudden_death_finale = true;

    level.zombie_total_set_func = function() => 
    {
        level.zombie_total = 99999;
    };

    // disable undead man walking on zombies
    level.var_9e59cb5b = function(guy) => 
    {
        return false;
    };
    
    level flag::clear("zombie_drop_powerups");
    level.zombie_vars["zombie_spawn_delay"] = 0.05;
    level thread gm_moveround(30);
    calc_zbr_ai_count(30);
    level.fn_custom_round_ai_spawn = undefined;
    level waittill("zombie_total_set");
    GM_KillMusic();
    level thread zm_powerup_nuke::nuke_flash();

    foreach(player in getplayers())
    {
        player thread try_respawn(false);
        player disableInvulnerability();
        player.ready_for_score_events = false;
        player visionset_mgr::activate("visionset", "zm_zbr_finalstand", player);
        player thread sd_watch_fairplay();
        player.ignoreme = false;
    }

    level.zombie_total = 99999;
    
    level flag::set("spawn_zombies");
    level.zbrgs_pvp_damage_scalar = level._zbrgs_pvp_damage_scalar;
    level thread zbr_run_fs_music();
    visionsetnaked("zm_zbr_finalstand", 0.1);

    // impatient disabled
    // aftertaste isnt an issue because buying perks will be disabled
    // idle eyes will have 3 activations which is 1m30 of being invis to zombies... could be an issue
    // undeadman walking disabled
    // killing time during setup should not work (dont allow activation)
    // round robbin should be disabled during this stage

    // TODO: fog CScr_SetLitFogBank
    // TODO: blood rain (red_rain)  dlc5/tomb/fx_weather_rain_camera weather/fx_rain_system_hvy_runner
    
    // TODO: if not in playable area or zombies cant path to them, damage them
    
    level.zombie_vars["spectators_respawn"] = false;

    // timer runs
    x = 610;
    y = 30;
    h = 60;
    level thread sudden_death_winner_monitor();
    foreach(player in getplayers())
    {
        player thread lui::timer(level.zbr_sudden_death_timegoal, "sudden_death_winner", x, y, h); // 1280 (640)
    }
    level util::waittill_notify_or_timeout("sudden_death_winner", level.zbr_sudden_death_timegoal);
    level notify(#sd_finished);
    foreach(player in getplayers())
    {
        player enableInvulnerability();
        player.ignoreme = true;
        player FreezeControlsAllowLook(true);
    }

    if(is_zbr_teambased())
    {
        team_score_array = [];
        foreach(team in level.gm_teams)
        {
            team_score_array[team] = 0;
        }

        foreach(player in getplayers())
        {
            if(player.sessionstate != "playing")
            {
                continue;
            }
            team_score_array[player getgmteam()] += player.score;
        }

        highest_team = undefined;
        highest_score = 0;
        ties = [];
        foreach(team in level.gm_teams)
        {
            if(team_score_array[team] == 0)
            {
                continue;
            }
            if(highest_team is undefined)
            {
                highest_team = team;
                highest_score = team_score_array[team];
                continue;
            }
            if(team_score_array[team] > highest_score)
            {
                highest_team = team;
                highest_score = team_score_array[team];
                ties = [];
                continue;
            }
            if(team_score_array[team] == highest_score)
            {
                ties[ties.size] = team;
            }
        }

        if(highest_team is undefined)
        {
            return gm_endgame_commit(true); // no winner
        }

        if(!ties.size)
        {
            foreach(player in getplayers())
            {
                if(player getgmteam() == highest_team)
                {
                    return player gm_endgame_commit(false);
                }
            }
            return gm_endgame_commit(true); // no winner
        }
        ties[ties.size] = highest_team;

        highest_player = undefined;
        any_ties = false;
        foreach(team in ties)
        {
            foreach(player in getplayers())
            {
                if(player getgmteam() == team)
                {
                    if(highest_player is undefined || highest_player.score < player.score)
                    {
                        highest_player = player;
                        any_ties = false;
                        continue;
                    }
                    if(highest_player.score == player.score)
                    {
                        any_ties = true;
                        continue;
                    }
                }
            }
        }

        if(any_ties)
        {
            return gm_endgame_commit(true); // no winner
        }
        return highest_player gm_endgame_commit(false);
    }
    else
    {
        // 2.1. if it is solos, the player with the highest score wins. If there is a tied score, the match is a draw.

        winner = undefined;
        ties = [];
        foreach(player in getplayers())
        {
            if(player.sessionstate != "playing")
            {
                continue;
            }
            if(winner is undefined)
            {
                winner = player;
                ties = [];
                continue;
            }
            if(winner.score < player.score)
            {
                winner = player;
                ties = [];
                continue;
            }
            if(winner.score == player.score)
            {
                ties[ties.size] = player;
                continue;
            }
        }

        if(ties.size || (winner is undefined))
        {
            return gm_endgame_commit(true); // no winner
        }
        return winner gm_endgame_commit(false);
    }
}

sd_watch_fairplay()
{
    self endon(#bled_out);
    self endon(#disconnect);
    origin = self.origin;
    time_cheating = 0;
    tick_speed = 0.1;
    for(;;)
    {
        wait tick_speed;

        if(self.zone_name is undefined || self.zone_name == "none")
        {
            self activate_effect(SE_SD_CHEATING_AREA, -1);
            time_cheating += tick_speed;
        }
        // else if(distanceSquared(origin, self.origin) <= 10000)
        // {
        //     time_cheating += tick_speed;
        // }
        else
        {
            self clear_effect(SE_SD_CHEATING_AREA);
            origin = self.origin;
            time_cheating = 0;
        }

        if(time_cheating >= 3.0) // 3 seconds
        {
            self dodamage(5000, self.origin);
            time_cheating = 0;
        }
    }
}

#define SD_OBJECTIVE_HUD_OFF_Y = 50;
#define SD_OBJECTIVE_Y_SPACE = 20;
#define SD_OBJECTIVE_SHOW_TIME = 50;
SD_ShowObjectives()
{
    self endon(#disconnect);

    obj = 
    [
        "Earning points is now disabled.",
        "Survive and hold the most points as a team at the end to win.",
        "Use this time to prepare. ^1Sudden death begins soon..."
    ];

    i = 0;
    huds = [];
    foreach(o in obj)
    {
        hud = self createText("objective", 2, "TOPLEFT", "TOPLEFT", 25, SD_OBJECTIVE_HUD_OFF_Y + i * SD_OBJECTIVE_Y_SPACE, 1, 1, o, (1,1,1));
        hud setCOD7DecodeFX(int(OBJECTIVE_DECODE_TIME * 1000 / o.size), (SD_OBJECTIVE_SHOW_TIME - 1) * 1000, 500);
        huds[huds.size] = hud;
        wait 0.5;
        i++;
    }

    wait SD_OBJECTIVE_SHOW_TIME;
    foreach(hud in huds)
    {
        hud destroy();
    }
}

sudden_death_winner_monitor()
{
    level endon(#end_game);
    level endon(#sd_finished);
    for(;;)
    {
        n_alive = 0;
        foreach(player in getplayers())
        {
            if(player.sessionstate == "playing")
            {
                n_alive++;
            }
        }
        if(n_alive == 1)
        {
            success:
            foreach(player in getplayers())
            {
                player notify("sudden_death_winner");
            }
            level notify("sudden_death_winner");
            return;
        }
        if(n_alive > 1)
        {
            team = undefined;
            all_same = true;
            foreach(player in getplayers())
            {
                if(player.sessionstate != "playing")
                {
                    continue;
                }
                if(team is undefined)
                {
                    team = player getgmteam();
                    continue;
                }
                if(team == player getgmteam())
                {
                    continue;
                }
                all_same = false;
                break;
            }
            if(all_same)
            {
                goto success;
            }
        }
        wait 0.05;
    }
}

gm_sd_setup()
{
    // stop spawning ai
    level flag::clear("spawn_zombies");

    old_kt_validate = level.var_9f5c2c50;
    level.var_9f5c2c50 = function() => { return false; }; // deactivate killing time
    level.var_35efa94c = function() => { return false; }; // deactivate round robbin

    level.sd_setup_active = true;
    
    // kill all active ai
    foreach(zombie in GetAITeamArray(level.zombie_team))
    {
        if(!isdefined(zombie) || !isalive(zombie))
        {
            continue;
        }
        zombie dodamage(zombie.health + 666, zombie.origin);
    }

    level thread zm_powerup_nuke::nuke_flash();

    // disable pvp damage
    level._zbrgs_pvp_damage_scalar = level.zbrgs_pvp_damage_scalar;
    level.zbrgs_pvp_damage_scalar = 0.0;

    // spawn all players
    foreach(player in getplayers())
    {
        if(player.sessionstate != "playing")
        {
            player thread wait_and_revive_player();
            player.next_sd_respawn_try = gettime() + 5000;
        }
    }

    b_any_dead = true;
    while(b_any_dead)
    {
        b_any_dead = false;
        foreach(player in getplayers())
        {
            if(player.sessionstate == "playing" && (player.b_in_death_cutscene is not true))
            {
                player enableInvulnerability();
            }
            else
            {
                if(player.sessionstate != "playing" && (!isdefined(player.next_sd_respawn_try) || (player.next_sd_respawn_try <= gettime())))
                {
                    player thread wait_and_revive_player();
                    player.next_sd_respawn_try = gettime() + 5000;
                }
                b_any_dead = true;
            }
        }
        wait 0.05;
    }

    foreach(zombie in GetAITeamArray(level.zombie_team))
    {
        if(!isdefined(zombie) || !isalive(zombie))
        {
            continue;
        }
        zombie dodamage(zombie.health + 666, zombie.origin);
    }

    wait 3;

    foreach(player in getplayers())
    {
        player notify("timeout_spawn_protect");
        //player iPrintLnBold("^1SUDDEN DEATH BEGINS IN 60 SECONDS.");
        player activate_effect(SE_SD_PREP, 60);
        player GM_DestroyHUD();
        player thread SD_ShowObjectives();
        
        // restore points for all applicable players
        player restore_earned_points();

        if(player.gm_objective_completed is true && player.score < 100000)
        {
            player zm_score::add_to_player_score(100000 - player.score, 0, "gm_zbr_admin");
        }

        time = player get_gm_time_bonus();
        if(time is undefined or time < 0)
        {
            time = 0;
        }
        bonus_points = int(500 * time);
        player zm_score::add_to_player_score(bonus_points, 0, "gm_zbr_admin");

        foreach(weapon in player getweaponslist(1))
        {
			if(isdefined(weapon.clipsize) && weapon.clipsize > 0)
            {
				player setWeaponAmmoClip(weapon, weapon.clipsize);
			}
            player giveMaxAmmo(weapon);
		}
    }

    level.players[0] playsound("zmb_bgb_fearinheadlights_start");
    level.zbr_earn_no_points = true;
    level.zbr_no_respawn = true;

    fn_firesale = @zm_powerup_fire_sale<scripts\zm\_zm_powerup_fire_sale.gsc>::start_fire_sale;
    if(fn_firesale is defined)
    {
        level thread [[ fn_firesale ]]();
    }
    level thread cm_bgbm_activate_all();
    wait 31;

    if(fn_firesale is defined)
    {
        level thread [[ fn_firesale ]]();
    }
    level thread cm_bgbm_activate_all();
    wait 29;

    level.var_9f5c2c50 = old_kt_validate;
    level.sd_setup_active = false;
}

// 0.0 to 1.0 based on time elapsed in sd. 0.0 means no time and thus regular round spawns
gm_sd_intensity()
{
    if(level.zbr_sudden_death is not true)
    {
        return 0.0;
    }
    return level.zbr_sudden_death_timepassed / level.zbr_sudden_death_timegoal;
}

// call on a player, token must not be present in any arguments
send_client_rpc(token, command, args)
{
    if(token is not string)
    {
        return false;
    }

    if(token.size != 1)
    {
        return false;
    }

    if(command is not string)
    {
        return false;
    }

    if(args is not array)
    {
        return false;
    }

    str_sv = command;
    foreach(arg in args)
    {
        if(arg is defined)
        {
            arg = arg + "";
        }

        if(arg is undefined)
        {
            arg = "undefined";
        }

        if(arg is not string)
        {
            continue;
        }

        str_sv += token + arg;
    }

    util::setclientsysstate("zbr", token + str_sv, self);
    return true;
}

get_keyboard_response(title, defaulttext, size)
{
    self notify(#get_keyboard_response);
    self endon(#get_keyboard_response);
    self endon(#disconnect);
    self openmenu(game["menu_start_menu"]);
    self [[ level.zbr_send_client_rpc ]](",", "keyboard", array(title, defaulttext, size));
    self waittill(#kbmr, response);
    response_adj = "";
    for(i = 0; i < response.size; i++)
    {
        if(response[i] == "&" && i < response.size - 1 && response[i + 1] == "_")
        {
            i += 1;
            response_adj += " ";
            continue;
        }
        response_adj += response[i];
    }
    self closemenu(game["menu_start_menu"]);
    return response_adj;
}

init_emotes()
{
    level.zbr_emote_gun = getweapon("zbr_emote_animset_1");

    level.zbr_emote_actionids = [];
    // DEATH 1, FIRE 2
    level.zbr_emote_actionids["t7_loot_gesture_threaten_heart_attack"] = 3; // FIREWEAPON_ALT
    level.zbr_emote_actionids["t7_loot_gesture_boast_chickens_dont_dance_vol1"] = 4; // HOLDFIRE
    level.zbr_emote_actionids["t7_loot_gesture_boast_dip_low"] = 5; // HOLDFIRELOOP
    level.zbr_emote_actionids["t7_loot_gesture_boast_disconnected"] = 6; // HOLDFIRECANCEL
    level.zbr_emote_actionids["t7_loot_gesture_boast_finger_wag"] = 7; // JUMP
    level.zbr_emote_actionids["t7_loot_gesture_boast_gun_show"] = 8; // JUMP_LEAP
    level.zbr_emote_actionids["t7_loot_gesture_boast_hail_seizure"] = 9; // JUMP_LADDER
    level.zbr_emote_actionids["t7_loot_gesture_boast_king_kong"] = 10; // LAND
    level.zbr_emote_actionids["t7_loot_gesture_boast_laughing_at_you"] = 11; // LAND_LEAP
    level.zbr_emote_actionids["t7_loot_gesture_boast_make_it_rain"] = 12; // LAND_GLASS
    // 13 DROPWEAPON, 14 RAISEWEAPON, 15 FIRSTRAISEWEAPON, 
    // TEST FIX WARNING poplock is getting cut short (probably because of reload anim timers)
    level.zbr_emote_actionids["t7_loot_gesture_boast_poplock"] = 20; // PRONE_TO_CROUCH // 16; // RELOAD (NOTE: DONT USE RELOAD)
    level.zbr_emote_actionids["t7_loot_gesture_boast_see_me_swervin"] = 17; // RELOAD_EMPTY
    level.zbr_emote_actionids["t7_loot_gesture_boast_shoulder_shrug"] = 18; // RECHAMBER
    level.zbr_emote_actionids["t7_loot_gesture_boast_so_fresh"] = 19; // CROUCH_TO_PRONE
    
    level.zbr_emote_actionids["t7_loot_gesture_boast_three_amigos"] = 21; // STAND_TO_CROUCH
    level.zbr_emote_actionids["t7_loot_gesture_boast_yogging"] = 22; // CROUCH_TO_STAND
    level.zbr_emote_actionids["t7_loot_gesture_goodgame_bow"] = 23; // PRONE_TO_STAND
    level.zbr_emote_actionids["t7_loot_gesture_goodgame_bunny_hop"] = 24; // PRONE_TO_SPRINT
    level.zbr_emote_actionids["t7_loot_gesture_goodgame_but_that_flip_though"] = 25; // LADDER_TO_STAND

    level.zbr_emote_actionids["t7_loot_gesture_boast_clucked_up"] = 59; // laststand_to_prone
    
    level.zbr_emote_announce_data = []; // {0} is me, {1} is them
    level.zbr_emote_announce_data["t7_loot_gesture_boast_clucked_up"] = array("{0} clucks at {1}.", "{0} clucks like a chicken.");
    level.zbr_emote_announce_data["t7_loot_gesture_threaten_heart_attack"] = array("{1} give(s) {0} a heart attack.", "{0} has a heart attack.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_chickens_dont_dance_vol1"] = array("{0} dances like a chicken with {1}.", "{0} dances like a chicken.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_dip_low"] = array("{0} dips low at {1}.", "{0} dips down low.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_disconnected"] = array("{0} slides on {1}.", "{0} slides on 'em.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_finger_wag"] = array("{0} wags their finger at {1}.", "{0} wags their finger.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_gun_show"] = array("{0} shows off to {1}.", "{0} shows off their guns.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_hail_seizure"] = array("{0} seizes at {1}.", "{0} seizes up.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_king_kong"] = array("{0} beats their chest at {1}.", "{0} beats their chest.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_laughing_at_you"] = array("{0} laughs at {1}.", "{0} laughs.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_make_it_rain"] = array("{0} makes it rain on {1}.", "{0} makes it rain.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_poplock"] = array("{0} pops and locks with {1}.", "{0} pops it and locks it.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_see_me_swervin"] = array("{0} swerves on {1}.", "{0} swerves.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_shoulder_shrug"] = array("{0} shrugs at {1}.", "{0} shrugs.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_so_fresh"] = array("{0} is fresh with {1}.", "{0} is so fresh.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_three_amigos"] = array("{0} does a little dance with {1}.", "{0} does a little dance.");
    level.zbr_emote_announce_data["t7_loot_gesture_boast_yogging"] = array("{0} is yoggin at {1}.", "{0} is yoggin.");
    level.zbr_emote_announce_data["t7_loot_gesture_goodgame_bow"] = array("{0} bows for {1}.", "{0} bows.");
    level.zbr_emote_announce_data["t7_loot_gesture_goodgame_bunny_hop"] = array("{0} hops like a bunny with {1}.", "{0} hops like a bunny.");
    level.zbr_emote_announce_data["t7_loot_gesture_goodgame_but_that_flip_though"] = array("{0} does a backflip at {1}.", "{0} does a backflip.");
}

get_association_string(entity)
{
    if(entity is undefined)
    {
        return "^1unknown^7";
    }
    if(isPlayer(entity))
    {
        if(entity.team == self.team)
        {
            if(entity == self)
            {
                return "^3" + clean_name(entity.name) + "^7";
            }
            return "^8" + clean_name(entity.name) + "^7";
        }
        return "^9" + clean_name(entity.name) + "^7";
    }
    return "^1zombies^7";
}

find_associated_object()
{
    view_pos = self getweaponmuzzlepoint();
	forward_view_angles = self getweaponforwarddir();
    highdot = 0;
    highplayer = undefined;

    if(isdefined(self.last_killed_player) && ((gettime() - self.last_killed_player_time) <= 5000))
    {
        test_origin = self.last_killed_player_location + (0,0,50);
		dist_sq = distancesquared(view_pos, test_origin);
		dist_to_check = 1500 * 1500;
		if(dist_sq > dist_to_check) goto skip;
		normal = vectornormalize(test_origin - view_pos);
		dot = vectordot(forward_view_angles, normal);
		if(dot <= 0) goto skip;
        highplayer = self.last_killed_player;
        highdot = dot;
    }

    skip:

	foreach(player in level.players)
	{
		if(player.sessionstate != "playing") continue;
        if(player == self) continue;
		test_origin = player.origin + (0,0,50);
		dist_sq = distancesquared(view_pos, test_origin);
		dist_to_check = 1500 * 1500;
		if(dist_sq > dist_to_check) continue;
		normal = vectornormalize(test_origin - view_pos);
		dot = vectordot(forward_view_angles, normal);
		if(dot <= 0) continue;
		if(0 == player damageconetrace(view_pos, self)) continue;
		if(highplayer is undefined)
        {
            highplayer = player;
            highdot = dot;
            continue;
        }
        if(dot > highdot)
        {
            highplayer = player;
            highdot = dot;
            continue;
        }
	}
    if(highplayer is defined)
    {
        return highplayer;
    }
    foreach(zombie in GetAITeamArray(level.zombie_team))
    {
        if(!isdefined(zombie) || !isAlive(zombie)) continue;
		test_origin = zombie.origin + (0,0,50);
		dist_sq = distancesquared(view_pos, test_origin);
		dist_to_check = 500 * 500;
		if(dist_sq > dist_to_check) continue;
		normal = vectornormalize(test_origin - view_pos);
		dot = vectordot(forward_view_angles, normal);
		if(dot <= 0) continue;
		if(0 == zombie damageconetrace(view_pos, self)) continue;
        return zombie;
    }
    return undefined;
}

emote_announce(emote)
{
    if(!isdefined(self.zbr_emote_last_used))
    {
        self.zbr_emote_last_used = gettime() - 15000;
        self.zbr_emote_last_used_count = 0;
    }

    if(self.zbr_emote_last_used > (gettime() - 15000)) // was used in the last 15 seconds
    {
        if(self.zbr_emote_last_used_count >= 2) // too many prints, dont print
        {
            return;
        }
        self.zbr_emote_last_used_count++; // we now have 2 uses
    }
    else
    {
        self.zbr_emote_last_used = gettime(); // mark the first emote
        self.zbr_emote_last_used_count = 1;
    }

    if(!isdefined(level.zbr_emote_announce_data[emote]))
    {
        unknown:
        name = clean_name(self.name);
        foreach(player in getplayers())
        {
            player iPrintLn(sprintf("{0} emotes.", player get_association_string(self)));
        }
        return;
    }

    data = level.zbr_emote_announce_data[emote];
    obj = self find_associated_object();

    if(!isdefined(obj))
    {
        if(!isdefined(data[1]))
        {
            goto unknown;
        }
        foreach(player in getplayers())
        {
            player iPrintLn(sprintf(data[1], player get_association_string(self)));
        }
        return;
    }

    foreach(player in getplayers())
    {
        player iPrintLn(sprintf(data[0], player get_association_string(self), player get_association_string(obj)));
    }
}

zbr_can_emote()
{
    if(self.sessionstate != "playing")
    {
        return false;
    }
    if(self.b_in_death_cutscene is true)
    {
        return false;
    }
    if(self laststand::player_is_in_laststand())
    {
        return false;
    }
    if(self arecontrolsfrozen())
    {
        return false;
    }
    if(compiler::islinked(self getentitynumber()))
    {
        return false;
    }
    if(self bgb_any_frozen())
    {
        return false;
    }
    if(self.zbr_is_emoting is true)
    {
        return false;
    }
    if(!(self zm_magicbox::can_buy_weapon()))
    {
        return false;
    }
    if(self.gm_forceprone is true)
    {
        return false;
    }
    if(!(self isOnGround()))
    {
        return false;
    }
    if(self.shrinked is true)
    {
        return false;
    }
    if(self iswallrunning())
    {
        return false;
    }
    if(self isinvehicle())
    {
        return false;
    }
    if(self.afterlife is true)
    {
        return false;
    }
    if(self issliding())
    {
        return false;
    }
    return true;
}

do_zbr_emote(index)
{
    self endon(#disconnect);

    if(!zbr_can_emote())
    {
        return;
    }

    if(index < 0 || level.zbr_emote_array.size <= index)
    {
        return;
    }

    emote = level.zbr_emote_array[index];
    action_id = level.zbr_emote_actionids[emote];

    if(!isdefined(action_id))
    {
        return;
    }

    timeout = GetAnimLength(emote) + 0.05;

    if(!isdefined(timeout))
    {
        return;
    }

    self.zbr_is_emoting = true;

    self zbr_cosmetics_set_visible(true);
    wait 0.05;

    self giveWeapon(level.zbr_emote_gun);
    self switchToWeapon(level.zbr_emote_gun);
    self SetClientThirdPerson(true);
    self DisableUsability();
    self allowJump(false);
    self allowstand(true);
    self allowcrouch(false);
    self allowprone(false);
    self setstance("stand");
    max_time = 2.0;
    while(level.zbr_emote_gun != self getCurrentWeapon())
    {
        wait 0.05;
        max_time -= 0.05;
        if(max_time <= 0.0)
        {
            break;
        }
    }
    msg = undefined;
    if(level.zbr_emote_gun == self getCurrentWeapon())
    {
        self DisableWeaponCycling();
        // self DisableOffhandSpecial();
        // self DisableOffhandWeapons();
        
        self emote_announce(emote);
        self thread emote_watch_movement();
        compiler::anim_event(self getEntityNumber(), action_id);
        msg = self util::waittill_any_timeout(timeout, "bled_out", "emote_cancelled", "weapon_fire", undefined, undefined);
    }
    self.zbr_is_emoting = undefined;
    self allowJump(true);
    self allowcrouch(true);
    self allowprone(true);
    self EnableUsability();
    self SetClientThirdPerson(false);
    self zbr_cosmetics_set_visible(false);
    self EnableWeaponCycling();
    self notify(#emote_watch_movement);
    self takeweapon(level.zbr_emote_gun);
    if(msg is defined && msg != "timeout" && msg != "bled_out")
    {
        while(self getcurrentweapon() == level.zbr_emote_gun)
        {
            wait 0.05;
        }
        compiler::anim_event(self getEntityNumber(), 2); // fire weapon to clear the anim state
        self ResetAnimations();
    }
}

emote_watch_movement()
{
    self endon(#disconnect);
    self endon(#bled_out);
    self notify(#emote_watch_movement);
    self endon(#emote_watch_movement);
    origin = self.origin;
    distance_sq = 30 * 30;
    for(;;)
    {
        if(distanceSquared(origin, self.origin) >= distance_sq)
        {
            self notify(#emote_cancelled);
            return;
        }
        wait 0.05;
    }
}

zbr_cosmetics_thread()
{
    self notify(#zbr_cosmetics_thread);

    if(self IsTestClient())
    {
        return;
    }

    if(isdefined(self.zbr_cosmetics_array))
    {
        foreach(cosmetic in self.zbr_cosmetics_array)
        {
            cosmetic delete();
        }
    }

    self.zbr_cosmetics_array = [];

    self zbr_cosmetic_hat();

    self util::waittill_any("zbr_cosmetics_thread", "disconnect", "bled_out", "destroy_cosmetics");
    foreach(cosmetic in self.zbr_cosmetics_array)
    {
        cosmetic delete();
    }
}

zbr_cosmetic_hat()
{
    cosmetic = compiler::getcosmetic_xuid(self getxuid(false));
    if(cosmetic is undefined)
    {
        return;
    }
    if(cosmetic.hat <= 0)
    {
        return;
    }

    data = self get_character_data();
    hat = zbr_cosmetics::get_hat(cosmetic.hat, data.body, data.character);

    if(hat is undefined)
    {
        return;
    }

    mdl = spawn("script_model", self.origin);

    mdl setmodel(hat.model);
    mdl setscale(hat.scale);
    mdl enablelinkto();

    mdl linkto(self, hat.tag, hat.offset, hat.angles);
    mdl setinvisibletoplayer(self, !(self.zbr_cosmetics_visible is true));

    self.zbr_cosmetics_array["hat"] = mdl;
}

zbr_cosmetics_set_visible(visible)
{
    if(!isdefined(self.zbr_cosmetics_array))
    {
        return;
    }
    self.zbr_cosmetics_visible = visible;
    foreach(mdl in self.zbr_cosmetics_array)
    {
        mdl setinvisibletoplayer(self, !visible);
    }
}

#region core_fixup
autoexec core_fixup()
{
    compiler::script_detour("scripts/zm/_zm_weap_staff_air.gsc", #zm_weap_staff_air, #onplayerspawned, function() =>
    {
        if(!isdefined(self.zm_weap_staff_air_onplayerspawned))
        {
            self.zm_weap_staff_air_onplayerspawned = true;
            self thread [[ @zm_weap_staff_air<scripts\zm\_zm_weap_staff_air.gsc>::onplayerspawned ]]();
        }
    });

    compiler::script_detour("scripts/zm/_zm_weap_staff_lightning.gsc", #zm_weap_staff_lightning, #onplayerspawned, function() =>
    {
        if(!isdefined(self.zm_weap_staff_lightning_onplayerspawned))
        {
            self.zm_weap_staff_lightning_onplayerspawned = true;
            self thread [[ @zm_weap_staff_lightning<scripts\zm\_zm_weap_staff_lightning.gsc>::onplayerspawned ]]();
        }
    });

    compiler::script_detour("scripts/zm/_zm_weap_staff_revive.gsc", #zm_weap_staff_revive, #onplayerspawned, function() =>
    {
        if(!isdefined(self.zm_weap_staff_revive_onplayerspawned))
        {
            self.zm_weap_staff_revive_onplayerspawned = true;
            self thread [[ @zm_weap_staff_revive<scripts\zm\_zm_weap_staff_revive.gsc>::onplayerspawned ]]();
        }
    });

    compiler::script_detour("scripts/zm/_zm_weap_staff_water.gsc", #zm_weap_staff_water, #onplayerspawned, function() =>
    {
        if(!isdefined(self.zm_weap_staff_water_onplayerspawned))
        {
            self.zm_weap_staff_water_onplayerspawned = true;
            self thread [[ @zm_weap_staff_water<scripts\zm\_zm_weap_staff_water.gsc>::onplayerspawned ]]();
        }
    });

    compiler::script_detour("scripts/zm/zm_factory.gsc", #zm_factory, #on_player_spawned, function() =>
    {
        if(!isdefined(self.zm_factory_on_player_spawned))
        {
            self.zm_factory_on_player_spawned = true;
            self thread [[ @zm_factory<scripts\zm\zm_factory.gsc>::on_player_spawned ]]();
        }
    });
}

detour dragon_strike<scripts\zm\_zm_weap_dragon_strike.gsc>::on_player_spawned()
{
    if(isdefined(self.dragon_strike_on_player_spawned))
    {
        return;
    }
    self.dragon_strike_on_player_spawned = true;
    self thread [[ @dragon_strike<scripts\zm\_zm_weap_dragon_strike.gsc>::on_player_spawned ]]();
}

detour electroball_grenade<scripts\zm\_electroball_grenade.gsc>::on_player_spawned()
{
    if(isdefined(self.electroball_grenade_on_player_spawned))
    {
        return;
    }
    self.electroball_grenade_on_player_spawned = true;
    self thread [[ @electroball_grenade<scripts\zm\_electroball_grenade.gsc>::on_player_spawned ]]();
}

detour zm_altbody_beast<scripts\zm\_zm_altbody_beast.gsc>::update_kiosk_effects()
{
    self endon(#bled_out);
    self endon(#disconnect);
	self [[ @zm_altbody_beast<scripts\zm\_zm_altbody_beast.gsc>::update_kiosk_effects ]]();
}

detour zm_equip_gasmask<scripts\zm\_zm_equip_gasmask.gsc>::remove_gasmask_on_game_over()
{
    if(isdefined(self.zm_equip_gasmask_remove_gasmask_on_game_over))
    {
        return;
    }
    self.zm_equip_gasmask_remove_gasmask_on_game_over = true;
    self thread [[ @zm_equip_gasmask<scripts\zm\_zm_equip_gasmask.gsc>::remove_gasmask_on_game_over ]]();
}

detour zm_equip_gasmask<scripts\zm\_zm_equip_gasmask.gsc>::remove_gasmask_on_player_bleedout()
{
    if(isdefined(self.zm_equip_gasmask_remove_gasmask_on_player_bleedout))
    {
        return;
    }
    self.zm_equip_gasmask_remove_gasmask_on_player_bleedout = true;
    self thread [[ @zm_equip_gasmask<scripts\zm\_zm_equip_gasmask.gsc>::remove_gasmask_on_player_bleedout ]]();
}

detour zm_weap_shrink_ray<scripts\zm\_zm_weap_shrink_ray.gsc>::function_37ce705e()
{
    if(isdefined(self.zm_weap_shrink_ray_function_37ce705e))
    {
        return;
    }
    self.zm_weap_shrink_ray_function_37ce705e = true;
    self thread [[ @zm_weap_shrink_ray<scripts\zm\_zm_weap_shrink_ray.gsc>::function_37ce705e ]]();
}

detour _zm_weap_tesla<scripts\zm\_zm_weap_tesla.gsc>::on_player_spawned()
{
    if(isdefined(self._zm_weap_tesla_on_player_spawned))
    {
        return;
    }
    self._zm_weap_tesla_on_player_spawned = true;
    self thread [[ @_zm_weap_tesla<scripts\zm\_zm_weap_tesla.gsc>::on_player_spawned ]]();
}

detour audio<scripts\shared\audio_shared.gsc>::missilelockwatcher()
{
    if(isdefined(self.audio_missilelockwatcher))
    {
        return;
    }
    self.audio_missilelockwatcher = true;
    self thread [[ @audio<scripts\shared\audio_shared.gsc>::missilelockwatcher ]]();
}

detour audio<scripts\shared\audio_shared.gsc>::missilefirewatcher()
{
    if(isdefined(self.audio_missilefirewatcher))
    {
        return;
    }
    self.audio_missilefirewatcher = true;
    self thread [[ @audio<scripts\shared\audio_shared.gsc>::missilefirewatcher ]]();
}

detour drown<scripts\shared\drown.gsc>::watch_player_drowning()
{
    if(isdefined(self.drown_watch_player_drowning))
    {
        return;
    }
    self.drown_watch_player_drowning = true;
    self thread [[ @drown<scripts\shared\drown.gsc>::watch_player_drowning ]]();
}

detour drown<scripts\shared\drown.gsc>::watch_game_ended()
{
    if(isdefined(self.drown_watch_game_ended))
    {
        return;
    }
    self.drown_watch_game_ended = true;
    self thread [[ @drown<scripts\shared\drown.gsc>::watch_game_ended ]]();
}

detour drown<scripts\shared\drown.gsc>::watch_player_drown_death()
{
    self endon(#disconnect);
	self endon(#game_ended);
	self waittill(#bled_out);
	self.drownstage = 0;
	self clientfield::set_to_player("drown_stage", 0);
	if(!isdefined(self.drown_vision_set) || self.drown_vision_set)
	{
		visionset_mgr::deactivate("overlay", "drown_blur", self);
		self.drown_vision_set = 0;
	}
}

detour gameobjects<scripts\shared\gameobjects_shared.gsc>::on_death()
{
    level.gameobjects_dropped ??= @gameobjects<scripts\shared\gameobjects_shared.gsc>::gameobjects_dropped;
    level endon(#game_ended);
	self endon(#killondeathmonitor);
    self endon(#disconnect);
	self waittill(#bled_out);
	self thread [[ level.gameobjects_dropped ]]();
}

detour ability_player<scripts\shared\abilities\_ability_player.gsc>::gadgets_wait_for_death()
{
    level.gadget_power_save_fn ??= @ability_player<scripts\shared\abilities\_ability_player.gsc>::gadgets_save_power;
    self endon(#disconnect);
	self.pers["held_gadgets_power"] = [];
	self waittill(#bled_out);
	if(!isdefined(self._gadgets_player))
	{
		return;
	}
	self [[ level.gadget_power_save_fn ]](0);
}

detour hacker_tool<scripts\shared\weapons\_hacker_tool.gsc>::on_player_spawned()
{
    // destroy the hacker, dont need it
}

detour riotshield<scripts\shared\weapons\_riotshield.gsc>::watch_riot_shield_use()
{
    level.watch_riotshield_use_fn ??= @riotshield<scripts\shared\weapons\_riotshield.gsc>::watch_riot_shield_use;
    self endon(#bled_out);
    self [[ level.watch_riotshield_use_fn ]]();
}

detour weapons<scripts\shared\weapons\_weapons.gsc>::watch_grenade_usage()
{
    level.watch_grenade_usage_fn ??= @weapons<scripts\shared\weapons\_weapons.gsc>::watch_grenade_usage;
    self endon(#bled_out);
    self [[ level.watch_grenade_usage_fn ]]();
}

detour weapons<scripts\shared\weapons\_weapons.gsc>::watch_usage()
{
    level.watch_usage_fn ??= @weapons<scripts\shared\weapons\_weapons.gsc>::watch_usage;
    self endon(#bled_out);
    self [[ level.watch_usage_fn ]]();
}

detour weapons<scripts\shared\weapons\_weapons.gsc>::watch_for_throwbacks()
{
    level.watch_for_throwbacks_fn ??= @weapons<scripts\shared\weapons\_weapons.gsc>::watch_for_throwbacks;
    self endon(#bled_out);
    self [[ level.watch_for_throwbacks_fn ]]();
}

detour weapons<scripts\shared\weapons\_weapons.gsc>::watch_missile_usage()
{
    level.watch_missile_usage_fn ??= @weapons<scripts\shared\weapons\_weapons.gsc>::watch_missile_usage;
    self endon(#bled_out);
    self [[ level.watch_missile_usage_fn ]]();
}

detour weapons<scripts\shared\weapons\_weapons.gsc>::watch_weapon_change()
{
    level.watch_weapon_change_fn ??= @weapons<scripts\shared\weapons\_weapons.gsc>::watch_weapon_change;
    self endon(#bled_out);
    self [[ level.watch_weapon_change_fn ]]();
}

detour weapons<scripts\shared\weapons\_weapons.gsc>::track()
{
    // do nothing
}

detour spawning<scripts\zm\gametypes\_spawning.gsc>::on_player_spawned()
{
    // nah, do not do any of this shit. this is INSANE
    // level.enable_player_influencers_fn ??= @spawning<scripts\zm\gametypes\_spawning.gsc>::enable_player_influencers;
    // level.create_friendly_influencer_fn ??= @spawning<scripts\zm\gametypes\_spawning.gsc>::create_friendly_influencer;
    // self [[ level.enable_player_influencers_fn ]](1);
    // self endon(#disconnect);
	// level endon(#game_ended);
	// self waittill(#bled_out);
	// self [[level.enable_player_influencers_fn]](0);
	// level [[level.create_friendly_influencer_fn]]("friend_dead", self.origin, self.team);
}

detour zm_challenges_tomb<scripts\zm\zm_challenges_tomb.gsc>::onplayerspawned()
{
    if(isdefined(self.zm_challenges_tomb_onplayerspawned))
    {
        return;
    }
    self.zm_challenges_tomb_onplayerspawned = true;
    self thread [[ @zm_challenges_tomb<scripts\zm\zm_challenges_tomb.gsc>::onplayerspawned ]]();
}

#endregion