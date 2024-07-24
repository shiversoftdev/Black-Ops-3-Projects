grenade_planted_override(grenade, model)
{
    if(!isdefined(grenade.weapon)) return;

    if(isdefined(level.var_25ef5fab) && grenade.weapon == level.var_25ef5fab)
    {
        return self zm_tomb_grenade_planted(grenade, model);
    }

    if(isdefined(level.weaponzmcymbalmonkey) && grenade.weapon == level.weaponzmcymbalmonkey)
    {
        return self cymbal_monkey_planted(grenade, model, false);
    }

    if(isdefined(level.w_cymbal_monkey_upgraded) && grenade.weapon == level.w_cymbal_monkey_upgraded)
    {
        return self cymbal_monkey_planted(grenade, model, true);
    }
}

zm_tomb_grenade_planted(grenade, model)
{
    self endon("disconnect");
    if(!isdefined(model) || !isdefined(grenade)) return;
    if(!isdefined(grenade.weapon)) return;
    if(grenade.weapon != level.var_25ef5fab) return;
    model endon("delete");
    grenade endon("delete");
    grenade endon("death");
    model waittill("beacon_missile_launch");
    wait(0.5);
    wait(3);
    while(!isdefined(model.a_v_land_spots)) wait 0.05;
    wait 0.05 * 5;
    foreach(spot in model.a_v_land_spots)
    {
        model thread wait_and_do_weapon_beacon_damage(spot, grenade);
        util::wait_network_frame();
        wait(0.25);
    }
}

wait_and_do_weapon_beacon_damage(spot, grenade)
{
    wait(3);
    v_damage_origin = spot;

	a_players = getplayers();
    arrayremovevalue(a_players, self.owner, false);
	foreach(enemy in a_players)
	{
        if(enemy.sessionstate != "playing") continue;
		n_distance = distance(enemy.origin, v_damage_origin);
		if(n_distance <= 200)
		{
			n_damage = math::linear_map(n_distance, 200, 0, 7000 * (1 + (CLAMPED_ROUND_NUMBER * .1)), 8000 * (1 + (CLAMPED_ROUND_NUMBER * .1)));
			enemy dodamage(n_damage, enemy.origin, self.owner, self.owner, "none", "MOD_GRENADE_SPLASH", 0, level.var_25ef5fab);
		}
	}
}

cymbal_monkey_planted(grenade, model, upgraded = false)
{
    grenade endon("death");
    if(!isdefined(level.cymbal_monkeys)) level.cymbal_monkeys = [];
    original_size = level.cymbal_monkeys.size;
    while(original_size == level.cymbal_monkeys.size) wait .025;
    self grenade_go_hide(grenade, model);
    if(upgraded)
    {
        self thread monkey_pulse(grenade, model);
    }
}

kill_on_monkey_death(grenade)
{
    self endon("death");
    wait .05; // wait for the move to finish
    playfx(level._effect["teleport_splash"], self.origin);
	playfx(level._effect["teleport_aoe"], self.origin);
    self show();
    if(isdefined(grenade))
    {
        grenade waittill("death");
    }
    self kill_monkey_clone();
}

clone_fx_cleanup(grenade)
{
    self endon("death");
    grenade util::waittill_any_timeout(15, "death");
    if(isdefined(self.fx))
    {
        self.fx delete();
    }
    self delete();
}

kill_monkey_clone()
{
    playfx(level._effect["teleport_splash"], self.origin);
	playfx(level._effect["teleport_aoe"], self.origin);
    if(isdefined(self.clone_fx)) self.clone_fx delete();
    self delete();
}

monkey_clone_player_angles(owner)
{
	self endon("death");
	owner endon("bled_out");
    owner endon("disconnect");
	for(;;)
	{
		self.angles = owner.angles;
		wait(0.05);
	}
}

monkey_clone_damage_func()
{
    self endon("death");
    hitpoints = 10;
    for(;;)
    {
        self waittill("damage", damage, eattacker);
        if(!isdefined(self))
        {
            return;
        }
        if(!isdefined(eattacker))
        {
            continue;
        }
        self.maxhealth = 100000;
        self.health = self.maxhealth;
        if(isplayer(eattacker) && (isdefined(self.owning_player) && self.owning_player != eattacker))
        {
            hitpoints = int(hitpoints) - 1;
        }
        damageStage = int((10 - hitpoints) / 2);
        eattacker PlayHitMarker("mpl_hit_alert", damageStage, undefined, hitpoints <= 0);
        eattacker thread _damage_feedback_growth(self, undefined, undefined, 0, damageStage);
        if(hitpoints <= 0)
        {
            self thread kill_monkey_clone();
            return;
        }
    }
}

hide_owner(owner)
{
    owner notify("hide_owner");
	owner endon("hide_owner");
    owner endon("disconnect");
	owner setperk("specialty_immunemms");
	owner.no_burning_sfx = 1;
	owner notify("stop_flame_sounds");
	owner SetInvisibleToAll();
    owner notify(#destroy_cosmetics);
    owner SetInvisibleToPlayer(owner, false);
	owner.hide_owner = 1;
    owner.ignoreme = 1;
    owner in_plain_sight_effect(true);
    if(isdefined(owner.invis_glow))
    {
        if(isdefined(owner.invis_glow.fx))
        {
            owner.invis_glow.fx delete();
        }
        owner.invis_glow delete();
    }
    owner.invis_glow = spawn("script_model", owner.origin);
    owner.invis_glow linkto(owner);
    owner.invis_glow setmodel("tag_origin");
    owner.invis_glow thread clone_fx_cleanup(owner.invis_glow);
    owner.invis_glow.fx = playfxontag(level.zbr_glow_fx, owner.invis_glow, "tag_origin");
	playfx(level._effect["teleport_splash"], owner.origin);
	self thread show_owner_on_attack(owner);
	evt = self util::waittill_any_ex("explode", "death", "grenade_dud", owner, "hide_owner");
    if(!isdefined(owner)) return;
	owner notify("show_owner");
	owner unsetperk("specialty_immunemms");
    owner in_plain_sight_effect(false);
    owner thread zbr_cosmetics_thread();
    if(owner.sessionstate == "playing")
    {
        playfx(level._effect["teleport_splash"], owner.origin);
        owner show();
    }
    if(isdefined(owner.invis_glow))
    {
        owner.invis_glow delete();
    }
	owner.no_burning_sfx = undefined;
	owner setvisibletoall();
	owner.hide_owner = undefined;
    owner.ignoreme = 0;
}

in_plain_sight_effect(state = false, b_zombieblood = false)
{
    // if(b_zombieblood)
    // {
    //     return;
    // }
    s_effect = b_zombieblood ? "zm_tomb_in_plain_sight" : "zm_bgb_in_plain_sight";
    if(state)
    {
        self playsound("zmb_bgb_plainsight_start");
	    self playloopsound("zmb_bgb_plainsight_loop", 1);
        visionset_mgr::activate("visionset", s_effect, self, 0.5, 30, 0.5);
	    visionset_mgr::activate("overlay", s_effect, self);
    }
    else
    {
        self stoploopsound(1);
	    self playsound("zmb_bgb_plainsight_end");
        visionset_mgr::deactivate("visionset", s_effect, self);
        visionset_mgr::deactivate("overlay", s_effect, self);
    }
}

show_owner_on_attack(owner, b_zombie_blood = false)
{
	owner endon("hide_owner");
    owner endon("bled_out");
    owner endon("disconnect");
	owner endon("show_owner");
	self endon("explode");
	self endon("death");
	self endon("grenade_dud");
	owner.show_for_time = undefined;
    owner.ignoreme = 1;
	while(isdefined(owner))
	{
		owner waittill("weapon_fired");
		owner thread show_briefly(0.5, b_zombie_blood);
	}
}

show_briefly(showtime, b_zombie_blood = false)
{
	self endon("show_owner");
    self endon("bled_out");
    self endon("disconnect");
	if(isdefined(self.show_for_time))
	{
		self.show_for_time = showtime;
		return;
	}
    self.ignoreme = false;
	self.show_for_time = showtime;
	self setvisibletoall();
    self thread zbr_cosmetics_thread();
    self in_plain_sight_effect(false, b_zombie_blood);
    playsoundatposition("evt_appear_3d", self.origin);
	while(self.show_for_time > 0)
	{
		self.show_for_time = self.show_for_time - 0.05;
		wait(0.05);
	}
    self.ignoreme = true;
    self in_plain_sight_effect(true, b_zombie_blood);
    playsoundatposition("evt_disappear_3d", self.origin);
    if(self.sessionstate == "playing")
    {
        self notify(#destroy_cosmetics);
        self SetInvisibleToAll();
        self SetInvisibleToPlayer(self, false);
    }
	self.show_for_time = undefined;
}

octobomb_watcher()
{
    level endon("game_ended");
    if(!isdefined(level.w_octobomb)) return;
    level._octobomb_attack_callback = level.octobomb_attack_callback;
    level.octobomb_attack_callback = serious::octobomb_attack_callback;
    for(;;)
    {
        if(!isdefined(level.octobomb_attack_callback) || level.octobomb_attack_callback != serious::octobomb_attack_callback)
        {
            level._octobomb_attack_callback = level.octobomb_attack_callback;
            level.octobomb_attack_callback = serious::octobomb_attack_callback;
        }
        wait 1;
    }
}

octobomb_attack_callback(e_grenade)
{
    self thread octobomb_planted(e_grenade);
    if(isdefined(level._octobomb_attack_callback))
    {
        self [[ level._octobomb_attack_callback ]](e_grenade);
    }
}

octobomb_planted(grenade)
{
    grenade endon("death");
    if(isdefined(grenade.b_special_octobomb) && grenade.b_special_octobomb) return; // ignore special octobomb
    while(!isdefined(grenade.anim_model)) wait .025;
    self grenade_go_hide(grenade, grenade.anim_model, true);
}

grenade_go_hide(grenade, model, is_octo = false)
{
    self endon("disconnect");
    self endon("bled_out");
    weapons = self getweaponslistprimaries();
    if(weapons.size > 0) weapon = weapons[0];
    else weapon = self getCurrentWeapon();
    if(isdefined(self.monkey_clone))
    {
        self.monkey_clone delete();
    }
    if(isdefined(self.clone_fx))
    {
        if(isdefined(self.clone_fx.fx))
        {
            self.clone_fx.fx delete();
        }
        if(isdefined(self.clone_fx))
        {
            self.clone_fx delete();
        }
    }
    self freezeControls(true);
    wait .025;
    while(!self isOnGround()) wait 0.25;
    if(self laststand::player_is_in_laststand())
	{
        self freezeControls(false);
		return;
	}
    if(!isdefined(grenade))
    {
        return;
    }
    self setstance("stand");
	self setvelocity((0,0,0));
    self zbr_cosmetics_set_visible(true);
    clone = self ClonePlayer(99999, weapon, self);
    wait .025;
    if(!self bgb_any_frozen()) self freezeControls(false);
    self.monkey_clone = clone;
    clone ghost();
    clone.origin = model.origin;
    clone.is_clone = true;
    // clone thread monkey_clone_damage_func();
    clone setCanDamage(true);
    clone.owning_player = self;
    clone.sessionstate = "spectator";
    model.simulacrum = clone;
    if(is_octo) clone.origin = model.origin + (0,0,30);
    else model SetInvisibleToPlayer(self, true);
    clone thread monkey_clone_player_angles(self);
    clone thread kill_on_monkey_death(grenade);
    model thread hide_owner(self);
    clone.isactor = 1;
    clone.team = self.team;
	clone.is_inert = 1;
    clone.maxhealth = 100000;
    clone.health = clone.maxhealth;
	clone.zombie_move_speed = "walk";
	clone.script_noteworthy = "corpse_clone";
    clone.ignoretriggerdamage = 1;
    clone.spawntime = gettime();
    clone.fakefireweapon = weapon;
    if(!is_octo)
    {
        self.clone_fx = spawn("script_model", model.origin);
        clone.clone_fx = self.clone_fx;
        self.clone_fx setmodel("tag_origin");
        self.clone_fx thread clone_fx_cleanup(grenade);
        self.clone_fx.fx = playfxontag(level.zbr_glow_fx, self.clone_fx, "tag_origin");
    }
    if(isdefined(weapon.worldmodel) && weapon.worldmodel != "" && weapon.worldmodel != "none")
    {
        clone attach(weapon.worldmodel, "tag_weapon_right");
    }
}

monkey_pulse(grenade, model)
{
    self endon("disconnect");
    grenade endon("death");
    grenade endon("explode");
	util::wait_network_frame();
	n_damage_origin = grenade.origin + vectorscale((0, 0, 1), 12);
	for(;;)
	{
		a_targets = getplayers();
		foreach(player in a_targets)
		{
            if(!isdefined(player))
            {
                continue;
            }
            if(player.sessionstate != "playing")
            {
                continue;
            }
            if(player.team == self.team)
            {
                continue;
            }
			n_distance_to_target = distance(player.origin, n_damage_origin);
            if(n_distance_to_target > 128)
            {
                continue;
            }
            n_damage = math::linear_map(n_distance_to_target, 0, 128, 250 * CLAMPED_ROUND_NUMBER, 500 * CLAMPED_ROUND_NUMBER);
            player dodamage(int(n_damage), player.origin, self, grenade, "none", "MOD_GRENADE_SPLASH", 0, level.w_cymbal_monkey_upgraded);
		}
		wait(1);
	}
}