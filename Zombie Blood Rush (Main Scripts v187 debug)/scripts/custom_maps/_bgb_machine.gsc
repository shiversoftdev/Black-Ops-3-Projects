cm_bgbmachines_clientfields()
{
    clientfield::register("world", "bgb_update_price", 1, 1, "counter");
}

cm_bgbmachines_init(ignore_count = false)
{
    if(level.cm_bgbmachines_init === true)
    {
        return;
    }

    // only populate fake machines on maps with 1 or less machines
    if(level.var_5081bd63.size > 1 && !ignore_count)
    {
        return;
    }

    level.cm_bgbmachines_init = true;
    level.fake_bgb_machines ??= [];

    num_spawned = 0;
    a_s_boxes = cm_bgbm_get_box_locations();

    foreach(s_box in a_s_boxes)
    {
        s_machine_spawn = cm_bgbm_find_spawn(s_box.origin, s_box.angles);
        if(isdefined(s_machine_spawn))
        {
            cm_bgbm_spawn(s_machine_spawn.origin, s_machine_spawn.angles);
            num_spawned++;
            s_box.b_spawned_machine = true;
        }
        wait 0.05; // we are doing a lot of physics calculation, lets make sure we wait a frame at least
    }

    foreach(perk in level._custom_perks)
    {
        if(!isdefined(perk.radiant_machine_name)) continue;
        ent_array = getentarray(perk.radiant_machine_name, "targetname");
        if(ent_array.size < 1) continue;
        foreach(ent in ent_array)
        {
            if(!isdefined(ent.origin)) 
            {
                continue;
            }
            if(cm_bgbm_consider(ent.origin, ent.angles + V_PERK_ANGLE_OFFSET))
            {
                num_spawned++;
            }
            if(num_spawned > 9)
            {
                return;
            }
        }
    }
}

cm_bgbm_consider(origin, angles)
{
    level.fake_bgb_machines ??= [];

    // find a gobblegum machine within 1000u radius or spawn one near here
    foreach(machine in level.fake_bgb_machines)
    {
        dist = distance2d(machine.sm_gum_machine.original_origin, origin);
        if(dist <= 1000)
        {
            return false; // dont consider this location
        }
    }

    b_result = false;
    s_machine_spawn = cm_bgbm_find_spawn(origin, angles);
    if(isdefined(s_machine_spawn) && (distance2d(s_machine_spawn.origin, origin) > 64))
    {
        cm_bgbm_spawn(s_machine_spawn.origin, s_machine_spawn.angles);
        b_result = true;
    }
    wait 0.05; // we are doing a lot of physics calculation, lets make sure we wait a frame at least

    return b_result;
}

cm_bgbm_activate_all()
{
    if(!isdefined(level.fake_bgb_machines) || !isdefined(level.cm_bgbmachines_init))
    {
        return;
    }
    
    level clientfield::increment("bgb_update_price");
    foreach(s_machine in level.fake_bgb_machines)
    {
        s_machine cm_bgbm_activate(true);
    }
}

#define BGBM_TRIG_RAD = 110;

cm_bgbm_spawn(origin, angles)
{
    level.fake_bgb_machines ??= [];

    s_machine = spawnstruct();
    s_machine.b_is_fake = true;
    s_machine.sm_gum_machine = spawn("script_model", origin);
    s_machine.sm_gum_machine.angles = angles;
    s_machine.sm_gum_machine.original_angles = angles;
    s_machine.sm_gum_machine.original_origin = origin;
    s_machine.sm_gum_machine setmodel("p7_zm_zod_bubblegum_machine_with_lion"); // thanks feb <3
    s_machine.sm_gum_machine solid();
    s_machine.sm_gum_machine disconnectPaths();

    s_machine.sm_gumballs = spawn("script_model", origin);
    s_machine.sm_gumballs.angles = angles;
    s_machine.sm_gumballs setmodel("p7_zm_zod_bubblegum_machine_gumballs"); // thanks feb <3
    s_machine.sm_gumballs linkto(s_machine.sm_gum_machine, "tag_origin");

    s_machine.clip = spawn("script_model", origin, 1);
    s_machine.clip.angles = angles;
    s_machine.clip setmodel("collision_clip_cylinder_32x128"); // thanks feb <3
    s_machine.clip setscale(0.55);
    s_machine.clip ghost();
    s_machine.clip.script_noteworthy = "clip";
    s_machine.clip disconnectpaths();
    s_machine.clip linkto(s_machine.sm_gum_machine, "tag_origin");

    s_machine.trig_holder = spawnstruct();
    s_machine.trig_holder.origin = origin + (0, 0, 70);
    stub = s_machine.trig_holder zm_unitrigger::create_unitrigger("", BGBM_TRIG_RAD, serious::cm_bgbm_visibility_check, serious::cm_bgbm_trigger_think, "unitrigger_radius_use");
    zm_unitrigger::unitrigger_force_per_player_triggers(stub, true);
    stub.s_machine = s_machine;
    s_machine.trig = stub;

    s_machine.base_cost = level.var_f02c5598;
    s_machine.offerring_gum = false;
    s_machine.str_state = "ready";

    array::add(level.fake_bgb_machines, s_machine, false);
    return s_machine;
}

cm_bgbm_visibility_check(player)
{
    if(isdefined(player.wager_bgb_pack)) 
    {
        return false;
    }

    if(DISABLE_GUMS_CM)
	{
		return false;
	}

    self.stub.s_machine.base_cost = level.var_f02c5598;

    can_use = self cm_bgbm_validate_user(player);
	if(isdefined(self.hint_string))
	{
		if(isdefined(self.hint_parm1))
		{
			self sethintstring(self.hint_string, self.hint_parm1);
		}
		else
		{
			self sethintstring(self.hint_string);
		}
	}

    return can_use;
}

cm_bgbm_validate_user(player)
{
    b_result = false;
    state = self.stub.s_machine?.str_state ?? "unavailable";
    if(!isdefined(self.stub.s_machine) || !(self.stub.s_machine cm_bgbm_is_available()))
    {
        if(!isdefined(self.hint_string) || (self.hint_string === "") || (self.hint_string === &""))
        {
            self.hint_string = "";
            self.hint_parm1 = undefined;
            self setcursorhint("HINT_NOICON");
		    self.hint_string = ""; // fill cost from client side on all maps
        }
        return b_result;
    }
	if(!self bgb_trigger_visible_to_player(player))
	{
		return b_result;
	}
	self.hint_parm1 = undefined;
    
	if(state == "offerring_gum")
	{
		str_hint = &"ZOMBIE_BGB_MACHINE_OFFERING";

        if(self.stub.s_machine.out_of_bgb is true)
        {
            str_hint = &"ZOMBIE_BGB_MACHINE_OUT_OF";
        }

		b_result = 1;
		cursor_hint = "HINT_BGB";
		item_index = level.bgb[self.stub.s_machine.var_b287be]?.item_index ?? 0;
		self setcursorhint(cursor_hint, item_index);
		self.hint_string = str_hint;
	}
    else if(state == "selecting_gum")
    {
        self.hint_string = "";
        self.hint_parm1 = undefined;
        self setcursorhint("HINT_NOICON");
        self.hint_string = "";
        return true;
    }
	else
	{
		self setcursorhint("HINT_NOICON");
		self.hint_string = &"ZOMBIE_BGB_MACHINE_AVAILABLE_CFILL"; // fill cost from client side on all maps
        b_result = 1;
	}
	return b_result;
}

cm_bgbm_trigger_think()
{
    // s_machine = self.stub.s_machine;
    self.purchaser = undefined;
    for(;;)
    {
        self waittill("trigger", user);
        if(!isdefined(user))
        {
            continue;
        }
        if(!(self.stub.s_machine cm_bgbm_is_available()))
        {
            continue;
        }
        var_9bbdff4d = -1;
		if(user.bgb ?& isdefined(level.bgb[user.bgb]))
		{
			var_9bbdff4d = level.bgb[user.bgb].item_index;
		}
        var_5e7af4df = gettime();
		if(self.stub.s_machine.str_state != "ready" && user == level)
		{
			continue;
		}
        if(isplayer(user) && !(user zm_magicbox::can_buy_weapon()))
        {
            wait 0.1;
            continue;
        }
        if(user zm_utility::in_revive_trigger())
		{
			wait 0.1;
			continue;
		}
		if((user.is_drinking ?? 0) > 0)
		{
			wait 0.1;
			continue;
		}
		if(isdefined(self.disabled) && self.disabled)
		{
			wait 0.1;
			continue;
		}
        weapon = user getcurrentweapon();
        if(!isdefined(weapon) || weapon == level.weaponnone)
		{
			wait 0.1;
			continue;
		}

        if(self.stub.s_machine.str_state == "ready")
        {
            self.stub.s_machine.var_625e97d1 = 0;
            cost = bgb_machine::function_6c7a96b4(user, self.stub.s_machine.base_cost);
            if(zm_utility::is_player_valid(user) && user zm_score::can_player_purchase(cost))
            {
                user zm_score::minus_to_player_score(cost);
                self.purchaser = user;
                self.stub.s_machine.var_492b876 = user;
                self.stub.s_machine.current_cost = cost;
                if(user bgb::is_enabled("zm_bgb_shopping_free"))
                {
                    self.stub.s_machine.var_625e97d1 = 1;
                }
                self.stub.s_machine thread cm_bgbm_spawn_gum(self.stub.s_machine, user);
                wait 0.1;
                continue;
            }
            else
            {
                zm_utility::play_sound_at_pos("no_purchase", self.stub.s_machine.sm_gum_machine.origin);
                user zm_audio::create_and_play_dialog("general", "outofmoney");
                continue;
            }
        }
        else if(self.stub.s_machine.str_state == "offerring_gum")
        {
            if(isdefined(level.bgb[self.stub.s_machine.var_b287be]))
            {
                gumballoffered = level.bgb[self.stub.s_machine.var_b287be].item_index;
            }

            if(zm_utility::is_player_valid(user))
            {
                current_weapon = user getcurrentweapon();
            }
            current_weapon ??= level.weaponnone;

            if(self.stub.s_machine.out_of_bgb is true)
            {
                wait 0.1;
                continue;
            }
            
            if(((user.is_drinking ?? 0) <= 0) && !zm_utility::is_placeable_mine(current_weapon) && !zm_equipment::is_equipment(current_weapon) && !(user zm_utility::is_player_revive_tool(current_weapon)) && !(current_weapon.isheroweapon) && !(current_weapon.isgadget))
            {
                self.stub.s_machine notify(#"hash_69873c12");
                // user notify(#"hash_69873c12");
                self.stub.s_machine.str_state = "unavailable";
                gumballtaken = 1;
                user thread cm_bgb_gumball_anim(self.stub.s_machine.var_b287be, 0);
                if(isdefined(self.stub.s_machine.var_492b876))
                {
                    self.stub.s_machine.var_492b876 thread bgb::sub_consumable_bgb(self.stub.s_machine.var_b287be);
                }
                if(isdefined(level.var_361ee139))
                {
                    user thread [[level.var_361ee139]](self.stub.s_machine);
                }
                else
                {
                    user thread bgb_machine::function_acf1c4da(self.stub.s_machine);
                }
                self.stub.s_machine thread cm_bgbm_activate(false);
            }
        }
        
		wait 0.05;
    }
}

bgb_blow_bubble(bgb, activating)
{
	if(!(isdefined(level.bgb[bgb].var_7ca0e2a7) && level.bgb[bgb].var_7ca0e2a7))
	{
		return;
	}
	self.b_is_blowing_bgb = true;
	self util::waittill_any_timeout(2, "bgb_bubble_blow_complete");
	self.b_is_blowing_bgb = false;
}

bgb_get_gumball_anim_weapon(bgb, activating)
{
	if(activating)
	{
		return level.var_c92b3b33;
	}
	return level.var_adfa48c4;
}

bgb_play_gumball_anim_begin(bgb, activating)
{
	self zm_utility::increment_is_drinking();
	self zm_utility::disable_player_move_states(1);
	w_old = self getcurrentweapon();
	weapon = bgb_get_gumball_anim_weapon(bgb, activating);
	self giveweapon(weapon, self calcweaponoptions(level.bgb[bgb].camo_index, 0, 0));
	self switchtoweapon(weapon);
	if(weapon == level.var_adfa48c4)
	{
		self playsound("zmb_bgb_powerup_default");
	}
	if(weapon == level.var_c92b3b33)
	{
		self clientfield::increment_to_player("bgb_blow_bubble");
	}
	return w_old;
}

bgb_validate_gum(var_5827b083 = false)
{
	var_bb1d9487 = isdefined(level.bgb[self.bgb].validation_func) && !self [[level.bgb[self.bgb].validation_func]]();
	var_847ec8da = isdefined(level.var_9cef605e) && !self [[level.var_9cef605e]]();
	if(!var_5827b083 && (isdefined(self.is_drinking) && self.is_drinking) || (isdefined(self.var_aa1915a5) && self.var_aa1915a5) || self laststand::player_is_in_laststand() || var_bb1d9487 || var_847ec8da)
	{
		self clientfield::increment_uimodel("bgb_invalid_use");
		self playlocalsound("zmb_bgb_deny_plr");
		return false;
	}
	return true;
}

bgb_play_gumball_anim_end(var_e3d21ca6, bgb, activating)
{
	self zm_utility::enable_player_move_states();
	weapon = bgb_get_gumball_anim_weapon(bgb, activating);
	if(self laststand::player_is_in_laststand() || (isdefined(self.intermission) && self.intermission))
	{
		self takeweapon(weapon);
		return;
	}
	self takeweapon(weapon);
	if(self zm_utility::is_multiple_drinking())
	{
		self zm_utility::decrement_is_drinking();
		return;
	}
	if(var_e3d21ca6 != level.weaponnone && !zm_utility::is_placeable_mine(var_e3d21ca6) && !zm_equipment::is_equipment_that_blocks_purchase(var_e3d21ca6))
	{
		self zm_weapons::switch_back_primary_weapon(var_e3d21ca6);
		if(zm_utility::is_melee_weapon(var_e3d21ca6))
		{
			self zm_utility::decrement_is_drinking();
			return;
		}
	}
	else
	{
		self zm_weapons::switch_back_primary_weapon();
	}
	self util::waittill_any_timeout(1, "weapon_change_complete");
	if(!self laststand::player_is_in_laststand() && (!(isdefined(self.intermission) && self.intermission)))
	{
		self zm_utility::decrement_is_drinking();
	}
}

cm_bgb_gumball_anim(bgb, activating)
{
	self endon("disconnect");
	level endon("end_game");
    
	if(activating)
	{
		self thread bgb_blow_bubble(bgb);
		self thread zm_audio::create_and_play_dialog("bgb", "eat");
	}

	while(self isswitchingweapons())
	{
		self util::waittill_any_timeout(2, "weapon_change_complete");
	}

	gun = self bgb_play_gumball_anim_begin(bgb, activating);
	evt = self util::waittill_any_timeout(5, "fake_death", "player_downed", "weapon_change_complete", "disconnect");
	succeeded = 0;

	if(isdefined(evt) || evt == "weapon_change_complete")
	{
		succeeded = 1;
		if(activating)
		{
			if(isdefined(level.bgb[bgb].var_7ea552f4) && level.bgb[bgb].var_7ea552f4 || self bgb_validate_gum(1))
			{
				self notify(#"hash_83da9d01", bgb);
				self.var_aa1915a5 = 1;
				self thread [[ @bgb<scripts\zm\_zm_bgb.gsc>::function_eb4b1160 ]](bgb);
			}
			else
			{
				succeeded = 0;
			}
		}
		self notify("bgb_gumball_anim_give", bgb);
		self thread bgb::give(bgb);
		health = 0;
		if(isdefined(self.health))
		{
			health = self.health;
		}
	}
	self bgb_play_gumball_anim_end(gun, bgb, activating);
	return succeeded;
}

cm_bgbm_spawn_gum(s_machine, user)
{
    if(isdefined(level.var_5912cc2e))
	{
		user thread [[level.var_5912cc2e]](); // some gobblegum machine callback I guess?
	}

	user.var_85da8a33 = 1;
	user clientfield::set_to_player("zm_bgb_machine_round_buys", user.var_85da8a33);
	s_machine.var_492b876 = user;
	s_machine.var_bc4509eb = 1;
	s_machine.var_a23dc60f = 0;

    if(level.zombie_vars["zombie_powerup_fire_sale_on"] ?& level.zombie_vars["zombie_powerup_fire_sale_on"])
	{
		s_machine.var_a23dc60f = 1;
	}
	else
	{
		s_machine.uses_at_current_location = (s_machine.uses_at_current_location ?? 0) + 1;
	}

    s_machine.var_16d95df4 = s_machine select_user_gobblegum(user);
    s_machine.str_state = "selecting_gum";
    
    if(isdefined(s_machine.fx_origin))
    {
        s_machine.fx_origin delete();
    }

    s_machine.fx_origin = spawn("script_model", s_machine.sm_gum_machine.origin + (0, 0, 64));
    s_machine.fx_origin setmodel("tag_origin");
    s_machine.fx_origin thread cm_bgbm_flashing();
    s_machine.sm_gum_machine zm_utility::play_sound_at_pos("open_chest", s_machine.sm_gum_machine.origin);
	s_machine.sm_gum_machine zm_utility::play_sound_at_pos("music_chest", s_machine.sm_gum_machine.origin);

    msg = s_machine util::waittill_any_timeout(4, #zbr_emp_gum);

    s_machine.fx_origin delete();

    if(!isstring(msg) || msg != "timeout")
    {
        s_machine thread cm_bgbm_activate(false);
    }
    else
    {
        s_machine thread cm_bgbm_timeout(s_machine, 6);
        s_machine.str_state = "offerring_gum";
    }
}

cm_bgbm_flashing()
{
    self endon("death");

    i = 0;
    index = 0;
    for(;;)
    {
        if(!(i % 3))
        {
            self playsound("zmb_bgb_machine_light_click");
        }

        p_index = index;
        index = randomIntRange(1, 5);

        if(index == p_index)
        {
            index++;
        }

        if(index > 4)
        {
            index = 1;
        }

        self clientfield::set("powerup_fx", index);

        i++;
        wait 0.15;
    }
}

cm_bgbm_timeout(s_machine, time = 0)
{
    for(i = 0; i < (time * 3); i++)
    {
        s_machine.sm_gum_machine playsound("zmb_bgb_machine_light_ready");
        msg = s_machine util::waittill_any_timeout(0.35, #"hash_69873c12", #zbr_emp_gum);

        if(!isstring(msg) || msg != "timeout")
        {
            break;
        }
    }
    s_machine cm_bgbm_activate(false);
}

select_user_gobblegum(player)
{
	if(!player.bgb_pack_randomized.size)
	{
		player.bgb_pack_randomized = array::randomize(player.bgb_pack);

		// foreach(bgb in player.bgb_pack)
		// {
		// 	if(player.var_e610f362[bgb].var_b75c376 >= player.var_e610f362[bgb].var_e0b06b47)
		// 	{
		// 		ArrayRemoveValue(player.bgb_pack_randomized, bgb, false);
		// 	}
		// }

		// if(!player.bgb_pack_randomized.size)
		// {
		// 	player.bgb_pack_randomized[0] = "zmui_bgb_in_plain_sight";
		// }
	}
	self.var_b287be = array::pop_front(player.var_8414308a);
	self.bgb_item_index = level.bgb[self.var_b287be].item_index;
    self.out_of_bgb = false;
    if(player.var_e610f362[self.var_b287be].var_b75c376 >= player.var_e610f362[self.var_b287be].var_e0b06b47)
    {
        self.out_of_bgb = true;
    }

	return true;
}

// activate a machine (spawn it) or deactivate a machine (despawn it)
cm_bgbm_activate(is_active = true)
{
    if(!is_active)
    {
        if(self.str_state == "unavailable_flying")
        {
            return;
        }
        self notify("cm_bgbm_newstate");
        self.str_state = "unavailable_flying";
        self.sm_gumballs ghost();
        self thread cm_bgbm_exit();
    }
    else
    {
        self notify("cm_bgbm_newstate");
        if(self.str_state == "unavailable_flying")
        {
            self thread cm_bgbm_arrive();
            return;
        }
    }
}

cm_bgbm_exit()
{
    self endon("cm_bgbm_newstate");
    self notify("cm_bgbm_exit");
    self.sm_gum_machine thread cm_bgbm_exitsounds();
    self.sm_gum_machine moveTo(self.sm_gum_machine getOrigin() + (0,0,45), 1.7);
    self.sm_gum_machine thread cm_bgbm_scene_spinfast();
    wait 1.75;
    self.sm_gum_machine moveTo(self.sm_gum_machine getOrigin() + (0,0,-15), 0.25);
    wait 0.3;
    playfx(level._effect["poltergeist"], self.sm_gum_machine.origin + (0,0,40), anglestoup(self.sm_gum_machine.angles), anglestoforward(self.sm_gum_machine.angles));
    playfx(level._effect["lght_marker_flare"], self.sm_gum_machine.origin);
    self.sm_gum_machine moveTo(self.sm_gum_machine getOrigin() + (0,0,5000), 1.5);
    wait 1.5;
    self.sm_gum_machine ghost();
    self.sm_gumballs ghost();
    self.clip notsolid();
}

cm_bgbm_exitsounds()
{
    for(i = 0; i < 12; i++)
    {
        self playsound("zmb_bgb_machine_light_leaving");
        wait 0.35;
    }
}

cm_bgbm_scene_spinfast()
{
    self endon("cm_bgbm_newstate");
    n_spins = 6;
    while(n_spins > 0)
    {
        self rotateYaw(self.angles[2] + 360, 0.2, 0, 0);
        wait 0.2;
        n_spins--;
    }
    wait 0.05;
    self rotateYaw(self.angles[2] - self.original_angles[2], 0.2, 0, 0);
}

cm_bgbm_arrive()
{
    foreach(player in getplayers())
    {
        if(distance(self.sm_gum_machine.original_origin, player.origin) <= 100)
        {
            v_diff = player.origin - self.sm_gum_machine.original_origin;
            player setorigin(player getorigin() + (0, 0, 2));
            player setvelocity(vectorscale(vectorNormalize(v_diff), 300));
        }
    }
    self endon("cm_bgbm_newstate");
    self notify("cm_bgbm_arrive");
    self.sm_gum_machine.origin = self.sm_gum_machine.original_origin - (0, 0, 100);
    self.sm_gum_machine.angles = self.sm_gum_machine.original_angles;
    self.clip solid();
    self.sm_gum_machine show();
    self.sm_gumballs show();
    wait 0.05;
    self.sm_gum_machine thread cm_bgbm_exitsounds();
    self.sm_gum_machine moveto(self.sm_gum_machine.original_origin, 2.0);
    wait 2.5;
    self.str_state = "ready";
}

cm_bgbm_is_available()
{
    if(!isdefined(self.str_state))
    {
        return false;
    }
    if(self.str_state == "unavailable")
    {
        return false;
    }
    if(self.str_state == "unavailable_flying")
    {
        return false;
    }
    return true;
}

cm_bgbm_get_box_locations()
{
    a_s_locations = [];
    foreach(box in level.chests)
    {
        v_position = isdefined(box.orig_origin) ? box.orig_origin : box.origin;
        if(!isdefined(box.angles) || !isdefined(v_position)) 
        {
            continue;
        }
        angles = box.angles + V_BOX_ANGLE_OFFSET;
        s_location = spawnstruct();
        s_location.origin = box.origin;
        s_location.angles = angles;
        array::add(a_s_locations, s_location, false);
    }
    return a_s_locations;
}

// cm_bgbm_box_get_spawn(s_box)
// {
//     // 1: Do a perpendicular trace to the box
//     v_trace_start = s_box.origin + vectorscale(anglesToForward(s_box.angles), 25) + (0, 0, 5);
//     v_trace_end = v_trace_start + vectorscale(anglesToForward(s_box.angles), 500); // 500u from start
//     s_trace = height_trace_shortest_distance(v_trace_start, v_trace_end, false, undefined);

//     s_spawn = undefined;

//     n_d2ds = distance2dsquared(s_trace, v_trace_start);
//     b_trace_too_close = (n_d2ds < (72 * 72));

//     if(b_trace_too_close)
//     {
//         // we failed to do a trace in this direction, maybe the two sides will work?
//         return cm_bgbm_box_get_spawn_side(s_spawn);
//     }

//     v_gt_start = v_trace_end;
    
//     s_ground = groundtrace(v_gt_start, v_gt_start - (0, 0, 10000), false, undefined);
//     b_too_high = (abs(v_gt_start[2] - s_ground["position"][2]) >= 150) || (s_ground["position"][2] - s_box.origin[2] > 35); // a trace that ends at a floating position needs to be recalculated
//     b_is_oob = !(util::positionquery_pointarray(s_ground["position"], 0, 100, 150, 50).size);
//     s_fitted_position = cm_bgbm_fit(s_ground["position"] - vectorscale(anglesToForward(s_box.angles), 16), 16, 32);

//     for(i = 0; (i < 4) && (b_too_high || b_is_oob || s_fitted_position.b_failed); i++)
//     {
//         v_gt_start = v_gt_start + vectorscale(v_trace_start - v_gt_start, 0.25);
//         s_ground = groundtrace(v_gt_start, v_gt_start - (0, 0, 10000), false, undefined);
//         s_ground["position"] ??= (v_gt_start - (0, 0, 10000));
//         b_too_high = (abs(v_gt_start[2] - s_ground["position"][2]) >= 150) || (s_ground["position"][2] - s_box.origin[2] > 35); // a trace that ends at a floating position needs to be recalculated
//         b_is_oob = !(util::positionquery_pointarray(s_ground["position"], 0, 100, 150, 50).size);
//         s_fitted_position = cm_bgbm_fit(s_ground["position"] - vectorscale(anglesToForward(s_box.angles), 16), 16, 32);
//     }

//     if(b_too_high || b_is_oob || s_fitted_position.b_failed)
//     {
//         // box seems to be on a ledge... try its sides?
//         return cm_bgbm_box_get_spawn_side(s_box);
//     }

//     v_pos = groundtrace(s_fitted_position.origin, s_fitted_position.origin - (0, 0, 100), false, undefined)["position"] ?? s_fitted_position.origin;

//     n_max_trace_dist = (32 + 16) * 2;
//     n_max_trace_dist_sq = n_max_trace_dist * n_max_trace_dist;
//     v_ideal_direction = undefined;
//     n_ideal_direction_length_sq = n_max_trace_dist_sq;
//     v_ntrace_start = v_pos + (0, 0, 20);
//     for(i = 0; i < 4; i++)
//     {
//         f_pitch = -180 + (90 * i);
//         v_dir = (0,f_pitch,0);
//         v_trace = height_trace_shortest_distance(v_ntrace_start, v_ntrace_start + vectorscale(anglestoforward(v_dir), n_max_trace_dist), false, undefined);

//         dsq = distance2Dsquared(v_trace, v_ntrace_start);

//         if(n_ideal_direction_length_sq < dsq)
//         {
//             continue;
//         }

//         n_ideal_direction_length_sq = dsq;
//         v_ideal_direction = v_dir;
//     }

//     v_desired_angles = undefined;

//     if(isdefined(v_ideal_direction))
//     {
//         a_v_directions = [];
//         a_v_directions[0] = v_ideal_direction + (0, -1, 0);
//         a_v_directions[1] = v_ideal_direction + (0, 1, 0);
        
//         b_cancel = false;
//         a_v_traces = [];
//         for(i = 0; i < 2; i++)
//         {
//             a_v_traces[i] = physicstrace(v_ntrace_start, v_ntrace_start + vectorscale(anglesToForward(a_v_directions[i]), n_max_trace_dist), vectorscale((-1, -1, -1), 4), vectorscale((1, 1, 1), 4), undefined, BGBM_MASK)["position"];

//             if(distance2dsquared(a_v_traces[i], v_ntrace_start) >= (n_max_trace_dist_sq - 1))
//             {
//                 b_cancel = true;
//             }
//         }

//         if(!b_cancel)
//         {
//             v_difference = a_v_traces[0] - a_v_traces[1];
//             v_difference = vectorToAngles(v_difference);

//             if(v_difference[1] >= 0)
//             {
//                 v_difference -= (0, 180, 0);
//             }

//             v_desired_angles = (0, -1 * v_difference[1], 0);
//         }
//     }

//     s_spawn = spawnstruct();
//     s_spawn.origin = v_pos;
//     s_spawn.poi = s_box;
//     s_spawn.desired_angles = v_desired_angles;
    
//     s_result = cm_bgbm_box_finalize_spawn(s_spawn);
//     if(!isdefined(s_result))
//     {
//         // spawn failed for some reason, lets try the sides of the box
//         return cm_bgbm_box_get_spawn_side(s_box);
//     }

//     return s_result;
// }

// cm_bgbm_box_get_spawn_side(s_box)
// {
// }

// cm_bgbm_box_finalize_spawn(s_spawn, b_ignore_boxes = false)
// {
//     if(!isdefined(s_spawn))
//     {
//         return undefined;
//     }

//     if(!isdefined(s_spawn.origin) || !isdefined(s_spawn.poi))
//     {
//         return undefined;
//     }

//     // check that spawn location wont be in the air

//     s_spawn.origin = groundtrace(s_spawn.origin + (0, 0, 10), s_spawn.origin - (0, 0, 500), true, undefined)["position"];
    
//     // check that the spawn location isnt near any other pois
//     n_min_dist = 80 * 80; // trigger distance

//     // check boxes
//     if(!b_ignore_boxes)
//     {
//         foreach(box in level.chests)
//         {
//             if(distanceSquared(box.orig_origin ?? box.origin, s_spawn.origin) <= n_min_dist)
//             {
//                 return undefined;
//             }
//         }
//     }

//     // check doors
//     types = ["zombie_door", "zombie_airlock_buy", "zombie_debris"];
//     foreach(type in types)
//     {
//         zombie_doors = GetEntArray(type, "targetname");
//         foreach(door in zombie_doors)
//         {
//             if(!isdefined(door.origin)) 
//             {
//                 continue;
//             }
//             if(distanceSquared(door.origin, s_spawn.origin) <= n_min_dist)
//             {
//                 return undefined;
//             }
//         }
//     }

//     // check wallbuys

//     spawnable_weapon_spawns = struct::get_array("weapon_upgrade", "targetname");
// 	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("bowie_upgrade", "targetname"), 1, 0);
// 	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("sickle_upgrade", "targetname"), 1, 0);
// 	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("tazer_upgrade", "targetname"), 1, 0);
// 	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("buildable_wallbuy", "targetname"), 1, 0);

// 	if(isdefined(level.use_autofill_wallbuy) && level.use_autofill_wallbuy)
// 	{
// 		spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, level.active_autofill_wallbuys, 1, 0);
// 	}

//     foreach(weapon in spawnable_weapon_spawns)
//     {
//         if(!isdefined(weapon.origin)) 
//         {
//             continue;
//         }
//         if(distanceSquared(weapon.origin, s_spawn.origin) <= n_min_dist)
//         {
//             return undefined;
//         }
//     }

//     // check perk locations
//     foreach(perk in level._custom_perks)
//     {
//         if(!isdefined(perk.radiant_machine_name)) continue;
//         ent_array = getentarray(perk.radiant_machine_name, "targetname");
//         if(ent_array.size < 1) continue;
//         foreach(ent in ent_array)
//         {
//             if(!isdefined(ent.origin)) 
//             {
//                 continue;
//             }
//             if(distanceSquared(ent.origin, s_spawn.origin) <= n_min_dist)
//             {
//                 return undefined;
//             }
//         }
//     }

//     // set orientation angles

//     s_spawn.angles = s_spawn.desired_angles ?? vectorscale(s_spawn.poi.angles, -1);
//     return s_spawn;
// }

// returns a struct: {origin:vector, b_failed:bool}
// cm_bgbm_fit(v_ground_pos, n_radius = 16, n_pad = 32, s_return)
// {
//     // we could do this with a circle perimeter around the zbarrier, taking the intersect between the wall and the circle perimeter.

//     if(!isdefined(s_return))
//     {
//         s_return = spawnstruct();
//         s_return.b_failed = true;
//         s_return.n_iterations_remaining = 2; // one per axis
//         s_return.origin = v_ground_pos;
//     }

//     v_center = s_return.origin + (0, 0, 20);
//     a_f_distances = [];
//     a_i_checks = [];
//     a_v_traces = [];
//     for(i = 0; i < 4; i++)
//     {
//         f_pitch = -180 + (90 * i);
//         v_end = v_center + vectorscale(anglestoforward((0, f_pitch, 0)), (n_pad + n_radius) * 2);
//         s_trace = height_trace_shortest_distance(v_center, v_end, false, undefined);
//         a_v_traces[i] = s_trace;
//         a_f_distances[i] = distance2dsquared(s_trace, v_center);
//         a_i_checks[i] = int(a_f_distances[i] >= n_radius);
//         a_i_checks[i] |= int(a_f_distances[i] >= (n_pad + n_radius)) << 1;
//     }

//     for(i = 0; i < 2; i++)
//     {
//         n_total = a_i_checks[i] + a_i_checks[i + 2];

//         if(n_total == 6 && (4 > abs(a_f_distances[i] - a_f_distances[i + 2])))
//         {
//             continue; // this set of dimensions is perfect!
//         }

//         // this position is squished between two walls, this will never do!
//         if(n_total == 0)
//         {
//             return s_return; // defaults to failed. we need at least 2 * n_radius + n_pad space to place a machine
//         }

//         // machine fits here, but is blocking one side.
//         // best plan of action is to anchor it to the wall at that spot
//         if((s_return.n_iterations_remaining > 0))
//         {
//             n_index = int(int(a_f_distances[i + 2] < a_f_distances[i]) * 2) + i; // grab the lowest distance of the two

//             if(abs(a_f_distances[n_index] - n_radius) <= 4) // close enough
//             {
//                 continue;
//             }

//             if((n_pad + n_radius) > a_f_distances[n_index])
//             {
//                 continue; // dont care because its too far
//             }

//             v_dir = (0, -180 + (90 * n_index), 0);
//             new_origin = a_v_traces[n_index] - vectorscale(anglesToForward(v_dir), n_radius); // move the origin towards the wall
//             trace = ground_trace_shortest_distance(new_origin, false, undefined);

//             // try walking it back off of a ledge (if applicable)
//             for(i = 1; i < 4; i++)
//             {
//                 trace2 = ground_trace_shortest_distance(trace - vectorscale(anglesToForward(v_dir), i * n_radius), false, undefined);
//                 if(abs(trace2[2] - trace[2]) > 75)
//                 {
//                     break;
//                 }
//                 if(trace2[2] < trace[2] && abs(trace2[2] - trace[2]) > 15) // dont walk it back on a slope, it needs to be an actual ledge
//                 {
//                     trace = trace2;
//                     break;
//                 }
//             }

//             s_return.origin = trace;
//         }
//     }
    
//     s_return.b_failed = false;
//     return s_return;
// }

height_trace_shortest_distance(v_start, v_end, hit_players, ignore_ent)
{
    v_best_trace = undefined;
    n_shortest_trace_dist = undefined;
    for(i = 0; i < 4; i++)
    {
        trace = physicstrace(v_start + (0, 0, i * 15), v_end + (0, 0, i * 15), vectorscale((-1, -1, -1), 4), vectorscale((1, 1, 1), 4), ignore_ent, BGBM_MASK)["position"];
        dsq = distance2Dsquared(trace, v_start + (0, 0, i * 15));
        if(!isdefined(n_shortest_trace_dist) || dsq < n_shortest_trace_dist)
        {
            n_shortest_trace_dist = dsq;
            v_best_trace = trace;
        }
    }
    return v_best_trace;
}

ground_trace_shortest_distance(v_start, hit_players, ignore_ent)
{
    v_best_trace = undefined;
    n_shortest_trace_dist = undefined;
    for(i = 0; i < 4; i++)
    {
        trace = groundtrace(v_start + (0, 0, pow(2, i) * 25), v_start + (0, 0, -10000), hit_players, ignore_ent)["position"];
        dist = abs(trace[2] - v_start[2]);
        if(!isdefined(n_shortest_trace_dist) || dist < n_shortest_trace_dist)
        {
            n_shortest_trace_dist = dist;
            v_best_trace = trace;
        }
    }
    return v_best_trace;
}

#define BGBM_RADIUS = 16;
#define BGBM_HEIGHT = 60;

#define BGBM_SS_FAILURE = -2;
#define BGBM_SS_SUCCESS = -1;
#define BGBM_SS_START = 0;
#define BGBM_SS_EVAL = 1;
#define BGM_BACKUP_EVAL = 2;

#define BGBM_ACTION_NONE = 0;
#define BGBM_ACTION_EXTEND_TRACE_BIDIRECTIONAL = 1;
#define BGBM_ACTION_EXTEND_TRACE_TRIDIRECTIONAL = 2;

#define BGBM_MASK = 0x3;

cm_bgbm_find_spawn(origin, angles)
{
    // RAYMARCH STRATEGY
    // SIMPLER IS BETTER

    // 1 march up to 500u
        // 1.1 if hit, check if we fit here
            // 1.1.1 if we fit, rotate and return
            // 1.1.2 don't fit? Check if we can go over the obstacle
                // 1.1.2.1 if we can go over, drop to the ground behind it and check if we fit
                // 1.1.2.2 otherwise, look to the "left" and "right"
                    // 1.1.2.2.1 if we can move, go that direction and go back to 1.1
                    // 1.1.2.2.2 we are stuck! we cant spawn here and should [QUIT]
        // 1.2 no hit? check left, right, and forward in a 250u radius (half of start, this is important)
        // 1.2.1 if hit, go to 1.1
        // 1.2.2 no hit? for each trace result:
            // 1.2.2.X run 1.2 with half radius, min 50u, with 3 direction vectors not matching inverse direction of original trace
            // 1.2.2.X.1 Hit? Run 1.1
            // 1.2.2.X.2 No hit still? We appear to be in a pretty empty place, just spawn the gum machine at the original 500u trace and orient it opposite of the angles of the box
    
    s_spawn = spawnstruct();
    s_spawn.state = BGBM_SS_START;
    s_spawn.origin = origin + (0, 0, 25) + vectorscale(anglesToForward(angles), 15);

    if(IS_DEBUG && DEBUG_BGBM_VISUALS)
    {
        dev_actor(s_spawn.origin, angles);
    }

    s_spawn.march_length = 500;
    s_spawn.completed = false;
    s_spawn.pending_locations = [];
    s_spawn.next_depth_locations = [];
    s_spawn.backup_locations = [];
    n_iteration = 0;
    while((s_spawn.march_length >= 62 || s_spawn.state == BGM_BACKUP_EVAL) && !s_spawn.completed)
    {
        switch(s_spawn.state)
        {
            case BGBM_SS_START: // 1
                array::add(s_spawn.pending_locations, cm_bgbm_march(s_spawn.origin, angles, s_spawn.march_length));
                s_spawn.march_length = int(s_spawn.march_length / 2);
                s_spawn.state = BGBM_SS_EVAL;
                bgbm_print("Initial state: ground_hit " + s_spawn.pending_locations[0].ground_hit + "; trace_hit " +  s_spawn.pending_locations[0].trace_hit);
            break;

            case BGBM_SS_EVAL: // 1.1
                
                foreach(s_result in s_spawn.pending_locations)
                {
                    n_action = cm_bgbm_test_location(s_spawn, s_result);
                    if(!n_action)
                    {
                        bgbm_print("Success! A gum machine is able to spawn!");
                        s_spawn.completed = true;
                        s_spawn.state = BGBM_SS_SUCCESS;
                        s_spawn.angles = s_result.trace_normal;
                        break;
                    }
        
                    // do some more tracing around this spot, we might be able to find a nice place
                    for(i = 0; i < 3 && (62 < s_spawn.march_length); i++)
                    {
                        if(i == 1 && (n_action != BGBM_ACTION_EXTEND_TRACE_TRIDIRECTIONAL))
                        {
                            continue;
                        }

                        switch(n_iteration)
                        {
                            case 1:
                                f_dir_offset = -135 + (i * 135);
                            break;

                            case 0:
                                f_dir_offset = -90 + (i * 90);
                            break;

                            case 2:
                                f_dir_offset = -90 + (i * 90);
                            break;

                            default:
                                f_dir_offset = -45 + (i * 45);
                            break;
                        }
                        
                        v_dir = (0, f_dir_offset + s_result.v_direction[1], 0);
                        s_new_result = cm_bgbm_march(s_result.ground_position + (0, 0, 10), v_dir, s_spawn.march_length);
                        if(IS_DEBUG && DEBUG_BGBM_VISUALS)
                        {
                            dev_actor(s_new_result.ground_position + (0, 0, 80), s_new_result.v_direction);
                        }

                        if(s_new_result.trace_fraction <= 0.01)
                        {
                            continue; 
                        }
                        s_spawn.next_depth_locations[s_spawn.next_depth_locations.size] = s_new_result;
                    }
                    bgbm_print("A pending location failed... " + s_result.ground_position);
                }

                s_spawn.pending_locations = arraycopy(s_spawn.next_depth_locations);
                if(!s_spawn.completed && !s_spawn.next_depth_locations.size)
                {
                    if(s_spawn.backup_locations.size)
                    {
                        s_spawn.state = BGM_BACKUP_EVAL;
                    }
                    else
                    {
                        bgbm_print("No additional locations were found to test. Spawn failed!");
                        s_spawn.completed = true;
                        s_spawn.state = BGBM_SS_FAILURE;
                    }
                }
                s_spawn.next_depth_locations = [];
                s_spawn.march_length = int(s_spawn.march_length / 2);
                n_iteration++;
            break;

            case BGM_BACKUP_EVAL:
                foreach(s_location in s_spawn.backup_locations)
                {
                    // we definitely fit because our physics trace is a box trace, so no need to do any weirdness!
                    b_result = cm_bgbm_check_fit(s_location, BGBM_RADIUS, BGBM_RADIUS * 3);

                    if(!b_result) // blocks traversal
                    {
                        continue;
                    }

                    // we do need to be make sure we are not too close to any triggers
                    cm_bgbm_cache_badlocs();

                    // we arent blocking traversal, but are we too close to another trigger?
                    min_dsq = 80 * 80;
                    b_continue = false;
                    foreach(v_loc in level.bgbm_cache_badlocs)
                    {
                        if(distance2dsquared(s_location.ground_position, v_loc) < min_dsq)
                        {
                            b_continue = true;
                            break; // we hit another trigger, this isnt somewhere we should be
                        }
                    }
                    
                    if(!b_continue) // not in a trigger's way, on the ground, surrounding space is good, sounds like a good place to be!
                    {
                        s_spawn.origin = s_location.ground_position;
                        s_spawn.completed = true;
                        s_spawn.state = BGBM_SS_SUCCESS;
                        break;
                    }
                }
                if(!s_spawn.completed)
                {
                    bgbm_print("No backup locations worked. Spawn failed!");
                    s_spawn.completed = true;
                    s_spawn.state = BGBM_SS_FAILURE;
                }
            break;
        }
    }

    if(!s_spawn.completed || s_spawn.state == BGBM_SS_FAILURE)
    {
        bgbm_print("No locations worked. Spawn failed!");
        return undefined;
    }

    // calc new angles

    n_greatest = 65535;
    for(i = 0; i < 4; i++)
    {
        v_dir = anglesToForward( (0, -180 + (90 * i), 0) );
        v_loc = s_spawn.origin + (0, 0, 25);
        s_trace = physicstrace(v_loc, v_loc + vectorscale(v_dir, 1000), (-0.5, -0.5, 0), (0.5, 0.5, 10), undefined, BGBM_MASK);
        dsq = distance2d(s_trace["position"], v_loc);
        if(dsq < n_greatest)
        {
            s_trace["position"] = (s_trace["position"][0], s_trace["position"][1], s_spawn.origin[2]);
            angles = vectorToAngles(s_trace["position"] - s_spawn.origin);
            n_greatest = dsq;
        }
    }

    s_spawn.angles = -1 * angles;
    return s_spawn;
}

cm_bgbm_march(v_start, v_direction, n_distance)
{
    n_len = 0.7071 * BGBM_RADIUS; // roughly sin(45)

    // do a straight trace with gum machine box
    s_trace = physicstrace(v_start, v_start + vectorscale(anglesToForward(v_direction), n_distance), (-1 * n_len, -1 * n_len, 0), (n_len, n_len, BGBM_HEIGHT), undefined, BGBM_MASK);
    s_result = spawnstruct();
    s_result.trace_hit = (s_trace["fraction"] < 1);
    s_result.trace_position = s_trace["position"];
    s_result.trace_normal = s_trace["normal"];
    s_result.trace_fraction = s_trace["fraction"];

    s_ground = groundtrace(s_trace["position"], s_trace["position"] - (0, 0, 1000), false, undefined);
    s_result.ground_hit = (s_ground["fraction"] < 1);
    s_result.ground_position = s_ground["position"];

    s_result.v_direction = v_direction;
    s_result.v_start = v_start;
    s_result.n_distance = n_distance;

    return s_result;
}

// returns true if the location is spawnable.
// Modifies: s_spawn.next_depth_locations, s_spawn.origin
cm_bgbm_test_location(s_spawn, s_location)
{
    n_action = BGBM_ACTION_NONE;
    if(s_location.trace_hit && s_location.ground_hit)
    {
        // we definitely fit because our physics trace is a box trace, so no need to do any weirdness!
        b_result = cm_bgbm_check_fit(s_location, BGBM_RADIUS, BGBM_RADIUS * 3);
            
        if(!b_result) // this is going to block traversal... we cant be here
        {
            bgbm_print("Traversal blocked... Trying a tri-directional trace");
            n_action = BGBM_ACTION_EXTEND_TRACE_TRIDIRECTIONAL;
        }

        // we do need to be make sure we are not too close to any triggers
        cm_bgbm_cache_badlocs();

        if(!n_action) // we arent blocking traversal, but are we too close to another trigger?
        {
            min_dsq = 80 * 80;
            foreach(v_loc in level.bgbm_cache_badlocs)
            {
                if(distance2dsquared(s_location.ground_position, v_loc) < min_dsq)
                {
                    bgbm_print("Trace is too close to a trigger... Trying a tri-directional trace");
                    n_action = BGBM_ACTION_EXTEND_TRACE_TRIDIRECTIONAL;
                    break; // we hit another trigger, this isnt somewhere we should be
                }
            }
        }
        
        if(!n_action) // not in a trigger's way, on the ground, surrounding space is good, sounds like a good place to be!
        {
            s_spawn.origin = s_location.ground_position;
            return n_action;
        }
    }

    if(!n_action) // no hit at all
    {
        // this location had no hit, but it has a ground hit, which could be used as a backup
        if(s_location.ground_hit)
        {
            s_spawn.backup_locations[s_spawn.backup_locations.size] = s_location;
        }
        n_action = BGBM_ACTION_EXTEND_TRACE_TRIDIRECTIONAL;
    }

    return n_action;
}

cm_bgbm_blacklist_place(origin)
{
    level.bgbm_cache_badlocs ??= [];
    level.bgbm_cache_badlocs[level.bgbm_cache_badlocs.size] = origin;
}

cm_bgbm_cache_badlocs()
{
    if(isdefined(level.bgbm_cache_badlocs_init))
    {
        return;
    }

    level.bgbm_cache_badlocs_init = true;

    level.bgbm_cache_badlocs ??= [];

    // check boxes
    foreach(box in level.chests)
    {
        level.bgbm_cache_badlocs[level.bgbm_cache_badlocs.size] = box.orig_origin ?? box.origin;
    }

    // check doors
    types = ["zombie_door", "zombie_airlock_buy", "zombie_debris"];
    foreach(type in types)
    {
        zombie_doors = GetEntArray(type, "targetname");
        foreach(door in zombie_doors)
        {
            if(!isdefined(door.origin)) 
            {
                continue;
            }
            level.bgbm_cache_badlocs[level.bgbm_cache_badlocs.size] = door.origin;
        }
    }

    // check wallbuys

    spawnable_weapon_spawns = struct::get_array("weapon_upgrade", "targetname");
	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("bowie_upgrade", "targetname"), 1, 0);
	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("sickle_upgrade", "targetname"), 1, 0);
	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("tazer_upgrade", "targetname"), 1, 0);
	spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, struct::get_array("buildable_wallbuy", "targetname"), 1, 0);

	if(isdefined(level.use_autofill_wallbuy) && level.use_autofill_wallbuy)
	{
		spawnable_weapon_spawns = arraycombine(spawnable_weapon_spawns, level.active_autofill_wallbuys, 1, 0);
	}

    foreach(weapon in spawnable_weapon_spawns)
    {
        if(!isdefined(weapon.origin)) 
        {
            continue;
        }
        level.bgbm_cache_badlocs[level.bgbm_cache_badlocs.size] = weapon.origin;
    }

    // check perk locations
    foreach(perk in level._custom_perks)
    {
        if(!isdefined(perk.radiant_machine_name)) continue;
        ent_array = getentarray(perk.radiant_machine_name, "targetname");
        if(ent_array.size < 1) continue;
        foreach(ent in ent_array)
        {
            if(!isdefined(ent.origin)) 
            {
                continue;
            }
            level.bgbm_cache_badlocs[level.bgbm_cache_badlocs.size] = ent.origin;
        }
    }
}

cm_bgbm_check_fit(s_location, n_min_radius, n_radius, b_no_adjust = false)
{
    // check the distance from each direction using a 1x1x60 bounds box + 10 from the ground origin
    // if a side has a short distance hit, adjust desired vector (only do this once! choose the shortest side if necessary)
    // if an axis is squished, return false
    // march towards desired vector with cm_bgbm_march, then adjust s_location accordingly

    if(!is_point_playable(s_location.ground_position))
    {
        bgbm_print("Position failed because it is not in the playable area (" + isdefined(s_location.ground_position) + ")");
        return false; // not in a playable area
    }

    a_s_traces = [];
    a_f_distances = [];
    for(i = 0; i < 4; i++)
    {
        v_direction = (0, -180 + (i * 90), 0);
        v_start = s_location.ground_position + (0, 0, 10);
        a_s_traces[i] = physicstrace(v_start, v_start + vectorscale(anglesToForward(v_direction), n_radius), (-0.5, -0.5, 0), (0.5, 0.5, BGBM_HEIGHT), undefined, BGBM_MASK);
        a_f_distances[i] = distance2dsquared(a_s_traces[i]["position"], v_start);
    }

    f_desired_angle = 0;
    n_desired_distance = 0;
    b_can_adjust = !b_no_adjust;
    for(i = 0; i < 2; i++)
    {
        n_sum = a_f_distances[i] + a_f_distances[i + 2];
        if(n_sum < (n_min_radius + n_radius)) // squished! we cant be here :(
        {
            bgbm_print("Position failed because it is squished!");
            return false;
        }

        if(n_sum >= (n_radius * 1.9))
        {
            bgbm_print("Position passed on the " + (i ? "y-axis" : "x-axis"));
            continue; // we are perfect on this axis and do not need to move at all
        }

        if(!b_can_adjust)
        {
            continue;
        }
        
        n_min_index = int((a_f_distances[i + 2] < a_f_distances[i]) * 2) + i;
        n_desired_distance = (a_f_distances[n_min_index] - n_min_radius);
        f_desired_angle = (-180 + (n_min_index * 90));
        b_can_adjust = false;
    }

    if(n_desired_distance == 0)
    {
        bgbm_print("No adjust, good to go.");
        return true; // looks good!
    }

    s_result = cm_bgbm_march(v_start, anglestoforward( (0, f_desired_angle, 0) ), n_desired_distance);

    if(!s_result.ground_hit || abs(s_result.ground_position[2] - s_location.ground_position[2]) > 100)
    {
        bgbm_print("Tried another march, but the new location isnt good so it has been rejected");
        return true; // cant adjust because the new location isnt in a great position
    }
    
    // copy the new location into the old location
    if(cm_bgbm_check_fit(s_result, n_min_radius, n_radius, true))
    {
        bgbm_print("New location fits, copying data to struct and returning true");
        s_location.trace_position =     s_result.trace_position;
        s_location.trace_normal =       s_result.trace_normal;
        s_location.ground_position =    s_result.ground_position;
        s_location.v_direction =        s_result.v_direction;
        s_location.v_start =            s_result.v_start;
        s_location.n_distance =         s_result.n_distance;
    }

    bgbm_print("Adjust considered, returning true");
    return true;
}

bgbm_print(str_s)
{
    if(IS_DEBUG && DEBUG_BGBM_VISUALS)
    {
        compiler::nprintln(str_s);
    }
}