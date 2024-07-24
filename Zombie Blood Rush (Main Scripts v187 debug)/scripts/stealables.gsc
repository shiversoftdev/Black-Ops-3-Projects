//credits: itsfebiven
bgb_visibility_override(player)
{
    if(isdefined(player.wager_bgb_pack)) 
    {
        return false;
    }

	if(DISABLE_GUMS_CM)
	{
		return false;
	}

    if(level.script != "zm_zod")
    {
        self.stub.trigger_target.base_cost = level.var_f02c5598;
    }
    
    result = self bgb_check_visibility_new(player);
    return result;
}

bgb_check_visibility_new(player)
{
	can_use = self bgb_validate_user(player);
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

bgb_validate_user(player)
{
	b_result = 0;
	if(!self bgb_trigger_visible_to_player(player))
	{
		return b_result;
	}
	self.hint_parm1 = undefined;
	if(isdefined(self.stub.trigger_target.var_a2b01d1d) && self.stub.trigger_target.var_a2b01d1d)
	{
		if(!(isdefined(self.stub.trigger_target.var_16d95df4) && self.stub.trigger_target.var_16d95df4))
		{
			str_hint = &"ZOMBIE_BGB_MACHINE_OUT_OF";
			b_result = 0;
		}
		else
		{
			str_hint = &"ZOMBIE_BGB_MACHINE_OFFERING";
			b_result = 1;
		}
		cursor_hint = "HINT_BGB";
		if(isdefined(self.stub.trigger_target.var_b287be) && isdefined(level.bgb[self.stub.trigger_target.var_b287be]))
		{
			var_562e3c5 = level.bgb[self.stub.trigger_target.var_b287be].item_index;
			self setcursorhint(cursor_hint, var_562e3c5);
			self.hint_string = str_hint;
		}
		else
		{
			self setcursorhint(cursor_hint, 0);
			self.hint_string = str_hint;
		}
	}
	else
	{
		self setcursorhint("HINT_NOICON");
		if(player.var_85da8a33 < level.var_6cb6a683)
		{
			if(isdefined(level.var_42792b8b) && level.var_42792b8b)
			{
				self.hint_string = &"ZOMBIE_BGB_MACHINE_AVAILABLE_CFILL";
			}
			else
			{
				self.hint_string = &"ZOMBIE_BGB_MACHINE_AVAILABLE";
				self.hint_parm1 = bgb_machine::function_6c7a96b4(player, self.stub.trigger_target.base_cost);
			}
			b_result = 1;
		}
		else
		{
			self.hint_string = &"ZOMBIE_BGB_MACHINE_COMEBACK";
			b_result = 0;
		}
	}
	return b_result;
}

bgb_trigger_visible_to_player(player)
{
	self setinvisibletoplayer(player);
	visible = true;
	if(!player zm_magicbox::can_buy_weapon())
	{
		visible = false;
	}
	if(player is_in_altbody())
	{
		return false;
	}
	if(!visible)
	{
		return false;
	}
	self setvisibletoplayer(player);
	return true;
}

bgb_stealable_watch_cancel_early()
{
	self notify("bgb_stealable_watch_cancel_early");
	self endon("bgb_stealable_watch_cancel_early");
	self waittill("user_grabbed_bgb");
	self.cancel_early = true;
}

bgb_stealable_trigger_check()
{
	self thread bgb_stealable_watch_cancel_early();
	self.cancel_early = false;
    while(!self.cancel_early)
    {
        self waittill("trigger", grabber);
		waittillframeend;

        user = self.var_492b876;
        if(!isdefined(self.b_bgb_is_available) || !self.b_bgb_is_available)
        {
            wait(0.1);
            continue;
        }
        if(!isdefined(self.bgb_machine_open) || !self.bgb_machine_open)
        {
            wait(0.1);
            continue;
        }
        if(isdefined(grabber.is_drinking) && grabber.is_drinking > 0)
        {
            wait(0.1);
            continue;
        }
        if(!isdefined(grabber) || !isdefined(user) || grabber == level || grabber == user || (grabber getcurrentweapon()) == level.weaponnone)
        {
            wait(0.1);
            continue;
        }

        if(grabber != user && grabber != level && !self.cancel_early)
        {
            current_weapon = level.weaponnone;
            if(zm_utility::is_player_valid(grabber))
            {
                current_weapon = grabber getcurrentweapon();
            }
            if(zm_utility::is_player_valid(grabber) && !(grabber.is_drinking > 0) && !zm_utility::is_placeable_mine(current_weapon) && !grabber zm_utility::is_player_revive_tool(current_weapon) && !current_weapon.isheroweapon && !current_weapon.isgadget)
            {
                grabber notify("user_grabbed_bgb");
				user notify("user_grabbed_bgb");
				self notify("user_grabbed_bgb");
				
				if(isdefined(self.bgb_machine_user) && isplayer(self.bgb_machine_user))
				{
					self.bgb_machine_user thread bgb::sub_consumable_bgb(self.var_b287be);
				}

                grabber luinotifyevent(&"zombie_bgb_used", 1, level.bgb[self.var_b287be].item_index);
                grabber thread cm_bgb_gumball_anim(self.var_b287be, 0);
                if(isdefined(level.var_361ee139))
                {
                    grabber thread [[level.var_361ee139]](self);
                }
                else
                {
                    grabber thread bgb_machine::function_acf1c4da(self);
                }
                self.var_a2b01d1d = false;
                self.var_b287be = undefined;
                wait 0.05;
                self notify("trigger", level);
                break;
            }
        }
        wait(0.05);
    }
	self thread bgb_stealable_trigger_check();
}

stealable_box_vis_func(player)
{
	can_use = self boxstub_update_prompt(player);
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

boxstub_update_prompt(player)
{
	if(!self box_trigger_visible_to_player(player))
	{
		return false;
	}
	if(player is_in_altbody())
	{
		return false;
	}
	if(isdefined(level.func_magicbox_update_prompt_use_override))
	{
		if([[level.func_magicbox_update_prompt_use_override]]())
		{
			return false;
		}
	}

	if(player bgb::is_enabled("zm_bgb_unbearable"))
	{
		self.stub.trigger_target.zombie_cost_old = self.stub.trigger_target.zombie_cost;
		self.stub.trigger_target.zombie_cost = 100;
		for(i = 0; i < level.chests.size; i++)
		{
			if(level.chests[i] == self)
			{
				level.chest_index = i;
				break;
			}
		}
	}
	else
	{
		if(isdefined(self.stub.trigger_target.zombie_cost_old) && self.stub.trigger_target.zombie_cost == 100)
		{
			self.stub.trigger_target.zombie_cost = self.stub.trigger_target.zombie_cost_old;
		}
	}

	self.hint_parm1 = undefined;
	if(isdefined(self.stub.trigger_target.grab_weapon_hint) && self.stub.trigger_target.grab_weapon_hint)
	{
		cursor_hint = "HINT_WEAPON";
		cursor_hint_weapon = self.stub.trigger_target.grab_weapon;
		self setcursorhint(cursor_hint, cursor_hint_weapon);
		if(isdefined(level.magic_box_check_equipment) && [[level.magic_box_check_equipment]](cursor_hint_weapon))
		{
			self.hint_string = &"ZOMBIE_TRADE_EQUIP_FILL";
		}
		else
		{
			self.hint_string = &"ZOMBIE_TRADE_WEAPON_FILL";
		}
	}
	else
	{
		self setcursorhint("HINT_NOICON");
		self.hint_parm1 = self.stub.trigger_target.zombie_cost;
		self.hint_string = zm_utility::get_hint_string(self, "default_treasure_chest");
	}
	return true;
}

box_trigger_visible_to_player(player)
{
	self setinvisibletoplayer(player);
	visible = 1;
	if(isdefined(self.stub.trigger_target.chest_user) && !isdefined(self.stub.trigger_target.box_rerespun))
	{
		if(zm_utility::is_placeable_mine(player getcurrentweapon()) || player zm_equipment::hacker_active())
		{
			visible = false;
		}
	}
	else if(!player zm_magicbox::can_buy_weapon())
	{
		visible = false;
	}
	if(player bgb::is_enabled("zm_bgb_disorderly_combat"))
	{
		visible = false;
	}
	if(player is_in_altbody())
	{
		visible = false;
	}
	if(!visible)
	{
		return false;
	}
	self setvisibletoplayer(player);
	return true;
}

stealable_vending_weapon_upgrade()
{
    self thread stealable_vwu_visibility();
    for(;;)
    {
        self waittill("trigger", player);
        if(!isdefined(self.pack_player)) continue;
        while(!self flag::get("pap_offering_gun"))
        {
            wait 0.25;
        }
        wait 0.25;
        self setvisibletoall();
    }
}

stealable_vwu_visibility()
{
    self thread kill_original_pap_trig();
    for(;;)
	{
		players = getplayers();
		for(i = 0; i < players.size; i++)
		{
			if(!players[i] player_use_can_pack_now() || players[i] bgb::is_active("zm_bgb_ephemeral_enhancement"))
			{
				self setinvisibletoplayer(players[i], 1);
				continue;
			}
			self setinvisibletoplayer(players[i], 0);
		}
		wait(0.1);
	}
}

kill_original_pap_trig()
{
    self notify("pack_a_punch_trigger_think");
    for(;;)
    {
        self waittill("pack_a_punch_trigger_think");
        wait 0.25;
        self notify("pack_a_punch_trigger_think");
    }
}

stealable_perk_random_visibility_func(player)
{
	can_use = self perk_random_machine_stub_update_prompt(player);
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

perk_random_machine_stub_update_prompt(player)
{
	self setcursorhint("HINT_NOICON");
	if(!self random_perk_trigger_visible_to_player(player))
	{
		return false;
	}
	if(player is_in_altbody())
	{
		return false;
	}
	self.hint_parm1 = undefined;
	n_power_on = is_rng_perk_power_on(self.stub.script_int);
	if(!n_power_on)
	{
		self.hint_string = &"ZOMBIE_NEED_POWER";
		return false;
	}
	if(self.stub.trigger_target.state == "idle" || self.stub.trigger_target.state == "vending")
	{
		n_purchase_limit = player zm_utility::get_player_perk_purchase_limit();
		if(!player zm_utility::can_player_purchase_perk())
		{
			self.hint_string = &"ZOMBIE_RANDOM_PERK_TOO_MANY";
			if(isdefined(n_purchase_limit))
			{
				self.hint_parm1 = n_purchase_limit;
			}
			return false;
		}
		if(isdefined(self.stub.trigger_target.machine_user))
		{
			if(isdefined(self.stub.trigger_target.grab_perk_hint) && self.stub.trigger_target.grab_perk_hint)
			{
				self.hint_string = &"ZOMBIE_RANDOM_PERK_PICKUP";
				return true;
			}
			self.hint_string = "";
			return false;
		}
		n_purchase_limit = player zm_utility::get_player_perk_purchase_limit();
		if(!player zm_utility::can_player_purchase_perk())
		{
			self.hint_string = &"ZOMBIE_RANDOM_PERK_TOO_MANY";
			if(isdefined(n_purchase_limit))
			{
				self.hint_parm1 = n_purchase_limit;
			}
			return false;
		}
		self.hint_string = &"ZOMBIE_RANDOM_PERK_BUY";
		self.hint_parm1 = level._random_zombie_perk_cost;
		return true;
	}
	self.hint_string = &"ZOMBIE_RANDOM_PERK_ELSEWHERE";
	return false;
}

is_rng_perk_power_on(n_power_index)
{
	if(isdefined(n_power_index))
	{
		str_power = "power_on" + n_power_index;
		n_power_on = level flag::get(str_power);
	}
	else if(isdefined(level.zm_custom_perk_random_power_flag))
	{
		n_power_on = level flag::get(level.zm_custom_perk_random_power_flag);
	}
	else
	{
		n_power_on = level flag::get("power_on");
	}
	return n_power_on;
}

random_perk_trigger_visible_to_player(player)
{
	self setinvisibletoplayer(player);
	visible = true;
	if(isdefined(self.stub.trigger_target.machine_user))
	{
		if(zm_utility::is_placeable_mine(player getcurrentweapon()))
		{
			visible = false;
		}
	}
	else if(!player can_buy_rng_perk())
	{
		visible = false;
	}
	if(player is_in_altbody())
	{
		return false;
	}
	if(!visible)
	{
		return false;
	}
	if(player player_has_all_available_perks())
	{
		return false;
	}
	self setvisibletoplayer(player);
	return true;
}

can_buy_rng_perk()
{
	if(isdefined(self.is_drinking) && self.is_drinking > 0)
	{
		return false;
	}
	current_weapon = self getcurrentweapon();
	if(zm_utility::is_placeable_mine(current_weapon) || zm_equipment::is_equipment_that_blocks_purchase(current_weapon))
	{
		return false;
	}
	if(self zm_utility::in_revive_trigger())
	{
		return false;
	}
	if(current_weapon == level.weaponnone)
	{
		return false;
	}
	return true;
}

player_has_all_available_perks()
{
	for(i = 0; i < level._random_perk_machine_perk_list.size; i++)
	{
		if(!self hasperk(level._random_perk_machine_perk_list[i]))
		{
			return false;
		}
	}
	return true;
}

rng_perk_machine_think()
{
    for(;;)
    {
        self waittill("done_cycling");
        if(self.num_time_used >= self.num_til_moved && level.perk_random_machine_count > 1)
        {
            continue;
        }
        wait 0.05;
        waittillframeend;
        perk = get_perk_from_mdl(level.bottle_spawn_location.model);
        self thread rng_perk_grab_check(perk);
    }
}

get_perk_from_mdl(mdl)
{
    foreach(str_perk, s_perk in level.machine_assets)
    {
        if(s_perk.weapon.worldmodel == mdl)
        {
            return str_perk;
        }
    }
	return undefined;
}

rng_perk_grab_check(random_perk)
{
	self endon("time_out_check");
	perk_is_bought = 0;
	while(!perk_is_bought)
	{
		self waittill("trigger", e_triggerer);
		if(isdefined(e_triggerer.is_drinking) && e_triggerer.is_drinking > 0)
        {
            wait(0.1);
            continue;
        }
        if(e_triggerer zm_utility::can_player_purchase_perk())
        {
            perk_is_bought = 1;
        }
        else
        {
            e_triggerer playsound("evt_perk_deny");
            e_triggerer notify("time_out_or_perk_grab");
            return;
        }
	}
	e_triggerer thread monitor_when_player_acquires_perk();
	self notify("grab_check");
	self notify("time_out_or_perk_grab");
    self thread award_player_perk_rng(e_triggerer, random_perk);
    level flag::set("machine_can_reset");
    self notify("time_out_check");
}

award_player_perk_rng(e_triggerer, random_perk)
{
    e_triggerer endon("disconnect");
    e_triggerer notify("perk_purchased", random_perk);
    gun = e_triggerer zm_perks::perk_give_bottle_begin(random_perk);
	evt = e_triggerer util::waittill_any_ex("fake_death", "death", "player_downed", "weapon_change_complete", self);
	if(evt == "weapon_change_complete")
	{
		e_triggerer thread zm_perks::wait_give_perk(random_perk, 1);
	}
	e_triggerer zm_perks::perk_give_bottle_end(gun, random_perk);
	if(!(isdefined(e_triggerer.has_drunk_wunderfizz) && e_triggerer.has_drunk_wunderfizz))
	{
		e_triggerer.has_drunk_wunderfizz = 1;
	}
}

monitor_when_player_acquires_perk()
{
	self util::waittill_any("perk_acquired", "death_or_disconnect", "player_downed");
	level flag::set("machine_can_reset");
}