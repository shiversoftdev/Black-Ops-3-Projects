widows_wine_zombie_damage_response(str_mod, v_hit_origin, e_player, n_amount, w_weapon, direction_vec)
{
	if((isdefined(w_weapon) && w_weapon == level.w_widows_wine_grenade) || (str_mod == "MOD_MELEE" && isdefined(e_player) && isplayer(e_player) && e_player hasperk("specialty_widowswine") && randomfloat(1) <= 0.5))
	{
        n_dist_sq = distancesquared(self.origin, v_hit_origin);
        if(n_dist_sq <= 10000) self thread widows_wine_cocoon_zombie(e_player);
        else self thread widows_wine_slow_zombie(e_player);
        if(!(isdefined(self.no_damage_points) && self.no_damage_points) && isdefined(e_player))
        {
            damage_type = "damage";
            e_player zm_score::player_add_points(damage_type, str_mod, undefined, 0, undefined, w_weapon);
        }
        return 1;
	}
	return 0;
}

widows_wine_damage_callback(einflictor, eattacker, idamage, idflags, smeansofdeath = "MOD_UNKNOWN", sweapon, vpoint, vdir, shitloc, psoffsettime)
{
	if(level.w_widows_wine_grenade ?& (sweapon ?& sweapon == level.w_widows_wine_grenade))
	{
		return 0;
	}
	if(level.w_widows_wine_grenade ?& (self.current_lethal_grenade ?& self.current_lethal_grenade == level.w_widows_wine_grenade) && self getweaponammoclip(self.current_lethal_grenade) > 0 && !self bgb::is_enabled("zm_bgb_burned_out"))
	{
		if(smeansofdeath == "MOD_MELEE" && (isplayer(eattacker) || isai(eattacker)) || (smeansofdeath == "MOD_EXPLOSIVE" && isvehicle(eattacker)))
		{
			self thread widows_wine_contact_explosion();
			return 0;
		}
	}
	return idamage;
}

widows_wine_contact_explosion()
{
	self magicgrenadetype(self.current_lethal_grenade, self.origin + vectorscale((0, 0, 1), 48), (0, 0, 0), 0);
	self setweaponammoclip(self.current_lethal_grenade, self getweaponammoclip(self.current_lethal_grenade) - 1);
	self clientfield::increment_to_player("widows_wine_1p_contact_explosion", 1);
}

widows_wine_cocoon_zombie(e_player)
{
	self notify("widows_wine_cocoon");
	self endon("widows_wine_cocoon");
	self endon("disconnect");
	if(!(isdefined(self.b_widows_wine_cocoon) && self.b_widows_wine_cocoon))
	{
		self.b_widows_wine_cocoon = 1;
		self.e_widows_wine_player = e_player;
		if(isdefined(self.widows_wine_cocoon_fraction_rate))
		{
			widows_wine_cocoon_fraction_rate = self.widows_wine_cocoon_fraction_rate;
		}
		else
		{
			widows_wine_cocoon_fraction_rate = 0.1;
		}
        self set_move_speed_scale(widows_wine_cocoon_fraction_rate, true);
		//self clientfield::set("widows_wine_wrapping", 1);
        self thread widows_wine_fx_toggle(true);
	}
	if(isdefined(e_player))
	{
		self thread widows_wine_cocoon_zombie_score(e_player, WIDOWS_WINE_COCOON_TIME, 10);
	}
	self util::waittill_any_timeout(WIDOWS_WINE_COCOON_TIME, "bled_out", "widows_wine_cocoon");
	if(!isdefined(self)) return;
    self set_move_speed_scale(1);
	//self clientfield::set("widows_wine_wrapping", 0);
    self thread widows_wine_fx_toggle(false);
	if(self.sessionstate == "playing") self.b_widows_wine_cocoon = 0;
}

widows_wine_cocoon_zombie_score(e_player, duration, max_score)
{
	self notify("widows_wine_cocoon_zombie_score");
	self endon("widows_wine_cocoon_zombie_score");
	self endon("disconnect");
	self endon("bled_out");
	if(!isdefined(self.ww_points_given)) self.ww_points_given = 0;
	start_time = gettime();
	end_time = start_time + duration * 1000;
	while(gettime() < end_time && self.ww_points_given < max_score)
	{
		e_player zm_score::add_to_player_score(10, 1, "gm_zbr_admin");
		wait(duration / max_score);
	}
}

widows_wine_slow_zombie(e_player)
{
	self notify("widows_wine_slow");
	self endon("widows_wine_slow");
	self endon("disconnect");
	if(isdefined(self.b_widows_wine_cocoon) && self.b_widows_wine_cocoon)
	{
		self thread widows_wine_cocoon_zombie(e_player);
		return;
	}
	if(isdefined(e_player))
	{
		self thread widows_wine_cocoon_zombie_score(e_player, WIDOWS_WINE_SLOW_TIME, 6);
	}
	if(!(isdefined(self.b_widows_wine_slow) && self.b_widows_wine_slow))
	{
		if(isdefined(self.widows_wine_slow_fraction_rate))
		{
			widows_wine_slow_fraction_rate = self.widows_wine_slow_fraction_rate;
		}
		else
		{
			widows_wine_slow_fraction_rate = 0.7;
		}
		self.b_widows_wine_slow = 1;
        self set_move_speed_scale(widows_wine_slow_fraction_rate, true);
        self thread widows_wine_fx_toggle(true);
	}
	self util::waittill_any_timeout(WIDOWS_WINE_SLOW_TIME, "bled_out", "widows_wine_slow");
	if(!isdefined(self)) return;
    self set_move_speed_scale(1);
    self thread widows_wine_fx_toggle(false);
	if(self.sessionstate == "playing") self.b_widows_wine_slow = 0;
}

widows_wine_fx_toggle(on = false)
{
    if(on == isdefined(self.ww_fx)) return;
    if(on) 
    {
        self.ww_fx = spawn("script_model", self getTagOrigin("j_spineupper"));
        self.ww_fx setmodel("tag_origin");
        self.ww_fx.fx = playFXOnTag(level._effect["widows_wine_wrap"], self.ww_fx, "tag_origin");
        self.ww_fx enableLinkTo();
        self.ww_fx linkTo(self, "j_spineupper", (0,0,0), (0,0,90));
    }
    else if(isdefined(self.ww_fx)) 
    {
		if(isdefined(self.ww_fx.fx))
		{
			self.ww_fx.fx delete();
		}

		if(isdefined(self.ww_fx))
		{
			self.ww_fx delete();
        	self.ww_fx = undefined;
		}
    }
}

widows_wine_drop_grenade(attacker, weapon = level.weaponnone)
{
	if(!isdefined(attacker)) return;
	if(!isplayer(attacker)) return;
	if(!attacker hasperk("specialty_widowswine")) return;

	cocooned = isdefined(self.b_widows_wine_cocoon) && self.b_widows_wine_cocoon;
	slowed = isdefined(self.b_widows_wine_slow) && self.b_widows_wine_slow;
    if(!cocooned && !slowed) return;
	switch(weapon)
	{
		case level.w_widows_wine_grenade:
			chance = 0.33;
			break;
		case level.w_widows_wine_knife:
		case level.w_widows_wine_bowie_knife:
		case level.w_widows_wine_sickle_knife:
			chance = 2.0f;
			break;
		default:
			chance = 0.5;
			break;
	}
	if(randomfloat(1) <= chance)
	{
		level._powerup_timeout_override = serious::powerup_widows_wine_timeout;
		level thread zm_powerups::specific_powerup_drop("ww_grenade", self.origin, undefined, undefined, undefined, attacker);
		level._powerup_timeout_override = undefined;
	}
	
}

powerup_widows_wine_timeout()
{
	self endon("powerup_grabbed");
	self endon("death");
	self endon("powerup_reset");
	self zm_powerups::powerup_show(1);
	wait_time = 1;
	if(isdefined(level._powerup_timeout_custom_time))
	{
		time = [[level._powerup_timeout_custom_time]](self);
		if(time == 0) return;
		wait_time = time;
	}
	wait(wait_time);
	for(i = 20; i > 0; i--)
	{
		self zm_powerups::powerup_show(!(i % 2));
		if(i > 15)
		{
			wait(0.3);
		}
		if(i > 10)
		{
			wait(0.25);
			continue;
		}
		if(i > 5)
		{
			wait(0.15);
			continue;
		}
		wait(0.1);
	}
	self notify("powerup_timedout");
	self zm_powerups::powerup_delete();
}