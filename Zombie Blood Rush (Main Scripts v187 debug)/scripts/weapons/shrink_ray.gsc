monitor_shrink_ray()
{
    if(!isdefined(level.var_f812085) && !isdefined(level.var_92280e77)) return;
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");

	level.var_953f69a0 = getweapon("shrink_ray_upgraded");
	level.var_f812085 = getweapon("shrink_ray");
    for(;;)
	{
		self waittill("weapon_fired", w_weapon);
        if(!isdefined(w_weapon)) continue;
		if(w_weapon == level.var_f812085 || w_weapon == level.var_953f69a0)
		{
			self thread fired_shrink_ray(w_weapon == level.var_953f69a0);
		}
	}
}

fired_shrink_ray(upgraded)
{
	a_e_players = self collect_shrinkable_players(upgraded);
	foreach(player in a_e_players)
    {
        player thread shrink_me(upgraded, self);
    }
}

collect_shrinkable_players(upgraded)
{
	range = 480;
	radius = 60;
	if(upgraded)
	{
		range = 1200;
		radius = 84;
	}
	shrinks = [];
	view_pos = self getweaponmuzzlepoint();
	test_list = getplayers();
    final_list = [];
    foreach(player in test_list)
    {
        if(player.sessionstate != "playing") continue;
        if(player == self) continue;
        final_list[final_list.size] = player;
    }
	players = util::get_array_of_closest(view_pos, test_list, undefined, undefined, range * 1.1);
	if(!isdefined(players)) return;
	range_squared = range * range;
	radius_squared = radius * radius;
	forward_view_angles = self getweaponforwarddir();
	end_pos = view_pos + vectorscale(forward_view_angles, range);
	for(i = 0; i < players.size; i++)
	{
		if(!isdefined(players[i]) || players[i] == self) continue;
		if(isdefined(players[i].shrinked) && players[i].shrinked) continue;
		test_origin = players[i].origin + (0,0,50);
		test_range_squared = distancesquared(view_pos, test_origin);
		if(test_range_squared > range_squared) break;
		normal = vectornormalize(test_origin - view_pos);
		dot = vectordot(forward_view_angles, normal);
		if(0 > dot) continue;
		radial_origin = pointonsegmentnearesttopoint(view_pos, end_pos, test_origin);
		if(distancesquared(test_origin, radial_origin) > radius_squared)
		{
			continue;
		}
		if(!(players[i] damageconetrace(view_pos, self)))
		{
			continue;
		}
		shrinks[shrinks.size] = players[i];
	}
	return shrinks;
}

shrink_me(b_upgraded, e_attacker)
{
    self endon("disconnect");
    self endon("bled_out");
    self notify("shrink_me");
    self endon("shrink_me");

    self.shrink_kicked = false;
    if(!isdefined(self.shrinked) || !self.shrinked)
    {
        self.shrinked = true;
        self.ignoreme++;
        playfx(level._effect["teleport_splash"], self.origin);
	    playfx(level._effect["teleport_aoe"], self.origin);
        self ghost();
		self setclientthirdperson(1);
        self.shrink_model = spawn("script_model", self.origin);
        self.shrink_model setmodel(level.cymbal_monkey_model);
        self.shrink_model thread kill_shrink_on_death(self);
        self.shrink_model.angles = self.angles;
        self.shrink_model setscale(level.shrink_clone_scale ?? 1.5);
        self.shrink_model thread fakelinkto(self);
        self.shrink_trigger = spawn("script_model", self.origin);
		self.shrink_trigger setmodel("defaultactor_0_5");
		//self.shrink_trigger setscale(0.55);
		self.shrink_trigger.maxhealth = 100000;
		self.shrink_trigger.health = 100000;
		self.shrink_trigger setCanDamage(true);
		self.shrink_trigger solid();
		self.shrink_trigger ghost();

	    self.shrink_trigger thread fakelinkto(self, (0,0,0));
        self.shrink_trigger thread kill_shrink_on_death(self);
        self.shrink_trigger thread watch_shrink_damage(self);
        self disableWeapons();
        self thread watch_when_kicked();
        self set_move_speed_scale(2.5, true);
        self.shrink_model.fx = playfxontag(level.zbr_glow_fx, self.shrink_model, "tag_origin_animate");
    }
    
    self util::waittill_any_timeout(SHRINK_RAY_SHRINK_TIME, "kicked");
    if(am_i_shrink_kicked())
    {
        self dodamage(int(self.health * 0.5), self.origin, self.shrink_killer, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
        wait 1;
        self.shrink_kicked = false;
    }
    if(self.ignoreme > 0)
    {
        self.ignoreme--;
    }
    self.shrinked = false;
	self setclientthirdperson(0);
    if(!self laststand::player_is_in_laststand())
    {
        self show();
        playfx(level._effect["teleport_splash"], self.origin);
	    playfx(level._effect["teleport_aoe"], self.origin);
    }
    self set_move_speed_scale(1);
    self enableWeapons();
    self notify("unshrink");
}

am_i_shrink_kicked()
{
	return isdefined(self.shrink_kicked) && self.shrink_kicked;
}

kill_shrink_on_death(player)
{
    self endon("death");
    player util::waittill_any_timeout(SHRINK_RAY_SHRINK_TIME, "disconnect", "bled_out", "shrink_me", "unshrink");
	if(isdefined(self.fx))
	{
		self.fx delete();
	}
    self delete();
}

fakelinkto(linkee, v_offset_origin = (0,0,0))
{
	self notify("fakelinkto");
	self endon("fakelinkto");
    self endon("death");
	self.backlinked = 1;
	while(isdefined(self) && isdefined(linkee))
	{
		self.origin = linkee.origin + v_offset_origin;
		self.angles = linkee.angles;
		wait(0.05);
	}
}

watch_shrink_damage(e_player)
{
    e_player endon("bled_out");
    e_player endon("disconnect");
    self endon("death");

    self.owning_player = e_player;
    self.shrink_damage_refract = true;
    for(;;)
    {
        self waittill("damage", damagetaken, attacker, dir, point, dmg_type, model, tag, part, weapon, flags);
        self.health += int(damagetaken);
        self.attacker = attacker;
        self.owning_player dodamage(int(damagetaken), self.origin, self, undefined, "none", dmg_type, 0, weapon);
    }
}

watch_when_kicked()
{
	self endon("death");
    self endon("disconnect");
    self endon("bled_out");
	self endon("unshrink");
    self endon("shrink_me");
	self.shrink_bump = spawn("trigger_radius", self.origin, 0, 30, 24);
	self.shrink_bump sethintstring("");
	self.shrink_bump setcursorhint("HINT_NOICON");
	self.shrink_bump enablelinkto();
	self.shrink_bump linkto(self);
	self.shrink_bump thread kill_shrink_on_death(self);
	self.shrink_bump endon("death");
	for(;;)
	{
		self.shrink_bump waittill("trigger", who);
		if(!isplayer(who)) continue;
        if(who == self) continue;
		movement = who getnormalizedmovement();
		if(length(movement) < 0.1) continue;
		toenemy = self.origin - who.origin;
		toenemy = (toenemy[0], toenemy[1], 0);
		toenemy = vectornormalize(toenemy);
		forward_view_angles = anglestoforward(who.angles);
		dot_result = vectordot(forward_view_angles, toenemy);
		if(dot_result > 0.5 && movement[0] > 0)
		{
            self.shrink_kicked = true;
            self.shrink_killer = who;
			self notify("kicked");
			self thread player_kicked_shrinked(who);
			return;
		}
	}
}

player_kicked_shrinked(killer)
{
    killer endon("disconnect");
    self endon("disconnect");
    playsoundatposition("zmb_mini_kicked", self.origin);
    kickangles = killer.angles;
	kickangles = kickangles + (randomfloatrange(-30, -20), randomfloatrange(-5, 5), 0);
	launchdir = anglestoforward(kickangles);
	if(killer issprinting())
	{
		launchforce = randomfloatrange(350, 400);
	}
	else
	{
		vel = killer getvelocity();
		speed = length(vel);
		scale = math::clamp(speed / 190, 0.1, 1);
		launchforce = randomfloatrange(1250 * scale, 1500 * scale);
	}
    self setOrigin(self getOrigin() + (0,0,5));
	self setVelocity(self getvelocity() + (launchdir * launchforce));
    if(isdefined(self.shrink_bump))
    {
        self.shrink_bump delete();
    }
}