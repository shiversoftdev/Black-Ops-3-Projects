#region banana colada
fix_perk_banana_colada()
{
    if(!isdefined(level._custom_perks["specialty_immunecounteruav"]))
    {
        return;
    }
    level._custom_perks["specialty_immunecounteruav"].player_thread_give = serious::perk_banana_colada_give;
}

perk_banana_colada_give()
{
    self notify("specialty_immunecounteruav_start");

    self endon(#"hash_a1c25eea");
    self endon("disconnect"); // original author should have done this but they dont... 
    self endon("bled_out");
    
	while(self hasperk("specialty_immunecounteruav"))
	{
		if(self isonslide())
		{
			if(!isdefined(self.var_2092cddf))
			{
				self playlocalsound("bc_slide_squish");
				self thread perk_bc_push();
			}

            // original logic threads the sub function...
            // this is really bad because we basically run a new server effect every frame, in combination with tons of needless threads
			level thread perk_bc_affect_enemies(self.origin, self);
            while(self isonslide())
            {
                wait 0.05;
            }
		}
		wait(0.05);
	}
}

perk_bc_push()
{
    self.var_2092cddf = true;
    angles = self getplayerangles();
	angles_forward = anglestoforward(angles);
	push = vectorscale(angles_forward, 400);
	while(self isonslide())
	{
		self setvelocity(push);
		wait(0.05);
	}
    self.var_2092cddf = undefined;
}

perk_bc_affect_enemies(start, player)
{
    player endon("disconnect");
    player endon("bled_out");

    end_time = gettime() + 5000;
    angles = player getplayerangles();
	angles_forward = anglestoforward(angles);

    a_tracks = []; // you will slide roughly like 200u, generate a start, middle, and end, then check all 3 for zombies and players
    for(i = 0; i < 3; i++)
    {
        a_tracks[i] = start + vectorscale(angles_forward, i * 100);
        v_pos = groundtrace(a_tracks[i] + (0, 0, 100), a_tracks[i] - (0, 0, 1000), false, undefined)["position"];
        if(isdefined(v_pos))
        {
            playfx("madgaz/banana_colada/banana_spill", v_pos);
            a_tracks[i] = v_pos;
        }
    }

    if(!isdefined(level.slip_id))
    {
        level.slip_id = 0;
    }

    slip_id = level.slip_id;
    level.slip_id++;

    n_dsq = 75 * 75; // 75 radius, spread out 100 units, overlap should make a good wrap
	while(gettime() < end_time)
	{
		ai_enemies = getaispeciesarray(level.zombie_team);
        ai_enemies = arraycombine(ai_enemies, getplayers(), false, false);
		foreach(ai in ai_enemies)
        {
            if(!isalive(ai))
            {
                continue;
            }
            if(isplayer(ai))
            {
                if(player.team == ai.team)
                {
                    continue;
                }
                if(player.sessionstate != "playing")
                {
                    continue;
                }
            }
            if(isdefined(ai.sliding_on_goo) && ai.sliding_on_goo)
            {
                continue;
            }
            b_is_close = false;
            v_track = undefined;
            foreach(track in a_tracks)
            {
                if(distance2dsquared(ai.origin, track) <= n_dsq)
                {
                    b_is_close = true;
                    v_track = track;
                    break;
                }
            }
            if(b_is_close)
			{
				ai thread bc_affect_enemy(player, a_tracks, slip_id);
			}
        }
		wait(0.1);
	}

    level notify("slip_finished" + slip_id);
}

bc_affect_enemy(player, a_tracks, slip_id)
{
    self endon("slip_finished" + slip_id);
    if(isai(self))
    {
        self thread bc_affect_ai(player);
    }
    else
    {
        self thread bc_affect_player(player, a_tracks);
        level waittill("slip_finished" + slip_id);
        self.sliding_on_goo = false;
        self forceslick(false);
    }
}

bc_affect_player(attacker, a_tracks, slip_id)
{
    self endon("disconnect");
    self endon("bled_out");
    self endon("slip_finished" + slip_id);
    n_dsq = 75 * 75; // 75 radius, spread out 100 units, overlap should make a good wrap
    while(b_continue_slipping)
    {
        if(self.sliding_on_goo !== true)
        {
            self.sliding_on_goo = true;
            self forceslick(true);
        }
        self DoDamage(int(PERK_BC_DOT_PER_SEC * 0.1 * CLAMPED_ROUND_NUMBER), self.origin, attacker, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
        b_continue_slipping = false;
        foreach(track in a_tracks)
        {
            if(distance2dsquared(self.origin, track) <= n_dsq)
            {
                b_continue_slipping = true;
                break;
            }
        }
        wait 0.1;
    }
    self.sliding_on_goo = false;
    self forceslick(false);
    self notify("slip_finished" + slip_id);
}

bc_affect_ai(player)
{
	self endon(#"hash_810f0438");
    self endon("death");
	if(isdefined(self.sliding_on_goo) && self.sliding_on_goo)
	{
		return;
	}
	if(isdefined(self.isdog) && self.isdog)
	{
		return;
	}
	self.sliding_on_goo = 1;
	if(isdefined(self.missinglegs) && self.missinglegs)
	{
		int = randomint(2);
		if(int)
		{
			anim_to_play = "mg_ai_zombie_crawl_slipslide_recover";
		}
		else
		{
			anim_to_play = "mg_ai_zombie_crawl_slipslide_slow";
			if(self.zombie_move_speed == "sprint" || self.zombie_move_speed == "run")
			{
				anim_to_play = "mg_ai_zombie_crawl_slipslide_fast";
			}
		}
	}
	else
	{
		int = randomint(2);
		if(int)
		{
			anim_to_play = "mg_ai_zombie_stand_slipslide_recover";
		}
		else
		{
			int = randomint(2);
			if(int)
			{
				anim_to_play = "mg_ai_zombie_slipslide_collapse";
			}
			else
			{
				int = randomint(2);
				if(self.zombie_move_speed == "sprint")
				{
					if(int)
					{
						anim_to_play = "mg_ai_zombie_sprint_slipslide_a";
					}
					else
					{
						anim_to_play = "mg_ai_zombie_sprint_slipslide";
					}
				}
				else if(self.zombie_move_speed == "run")
				{
					if(int)
					{
						anim_to_play = "mg_ai_zombie_run_slipslide_a";
					}
					else
					{
						anim_to_play = "mg_ai_zombie_run_slipslide";
					}
				}
				else if(int)
				{
					anim_to_play = "mg_ai_zombie_walk_slipslide_a";
				}
				else
				{
					anim_to_play = "mg_ai_zombie_walk_slipslide";
				}
			}
			end_pos = zombie_utility::getanimendpos(anim_to_play);
			trace_pos = playerphysicstrace(self.origin, end_pos);
			int = randomint(100);
			if(int < 25 || self.health < 500 || end_pos != trace_pos)
			{
				anim_to_play = "mg_ai_zombie_slipslide_collapse";
			}
		}
	}

    time = getanimlength(anim_to_play);
    var_47a0dd6 = getnotetracktimes(anim_to_play, "fly_zmb_goo_fall");
	if(isdefined(var_47a0dd6[0]))
	{
		delay = var_47a0dd6[0] * time;
	}
	else
	{
		delay = time / 2;
	}

	self thread scene::play(anim_to_play, self);
	wait(delay);
    if(self.health <= 500)
	{
		self startragdoll();
        delay += 0.05;
		wait(0.05);
		self dodamage(500, self.origin, player, player, "none");
	}
	else
	{
		self dodamage(500, self.origin, player, player, "none");
	}
    if(time > delay)
    {
        wait(time - delay);
    }
	self thread scene::stop(anim_to_play, self);
	self.sliding_on_goo = undefined;
	self.is_on_goo = undefined;
}
#endregion

#region bull ice blast
fix_perk_bull_ice_blast()
{
    if(!isdefined(level._custom_perks["specialty_proximityprotection"]))
    {
        return;
    }
    level._custom_perks["specialty_proximityprotection"].player_thread_give = function() =>
    {
        self notify("specialty_proximityprotection_start");
        self thread perk_bib_think();
    };
}

perk_bib_think()
{
	self endon(#"hash_4b450298");
	self endon("disconnect");
    self endon("bled_out");

    self.bib_state = "ground";
	for(;;)
	{
        self update_bib_state();

        if(self.bib_state == "air_double_jump")
        {
            earthquake(0.4, 0.5, self.origin, 100);
            vel = self getvelocity();
            self setvelocity(vel + vectorscale((0, 0, 1), 575 + (int(self hasperk("specialty_staminup")) * 200)));
            self.bib_state = "air_jumped";
            while(self jumpbuttonpressed())
            {
                wait 0.05;
            }
        }

        if(self.bib_state == "air_slamming")
        {
            vel = self getvelocity();
            self setvelocity(vel - vectorscale((0, 0, 1), 500));
        }

        if(self.bib_state == "air_do_slam")
        {
            earthquake(0.25, 3, self.origin, 50);
            playfx(level._effect["slam_ice_impact"], self.origin);
            rand = randomintrange(0, 3);
            playsoundatposition("slam_ice_impact_0" + rand, self.origin);
            if(self laststand::player_is_in_laststand())
            {
                return;
            }
            self setstance("stand");
            enemies = arraycombine(getaispeciesarray(level.zombie_team, "all"), getplayers(), false, true);
            enemies = util::get_array_of_closest(self.origin, enemies, undefined, undefined, 128);
            self thread do_bib_slam(enemies);
            self.bib_state = "ground";
        }

		wait(0.05);
	}
}

do_bib_slam(enemies)
{
    foreach(e_enemy in enemies)
    {
        if(isplayer(e_enemy))
        {
            if(e_enemy.team == self.team)
            {
                continue;
            }
            if(e_enemy.sessionstate != "playing")
            {
                continue;
            }
            e_enemy thread ice_affect_zombie(self getCurrentWeapon(), self);
        }
        if(isai(e_enemy))
        {
            if(!isalive(e_enemy))
            {
                continue;
            }
            if(isdefined(e_enemy.bib_effect) && e_enemy.bib_effect)
            {
                continue;
            }
            e_enemy.bib_effect = true;
            e_enemy thread bib_freeze_zombie(self);
        }

    }
}

bib_freeze_zombie(attacker)
{
    self endon("death");
    if(isdefined(self.slam_fx))
    {
        if(isdefined(self.slam_fx.fx))
        {
            self.slam_fx.fx delete();
        }
        self.slam_fx delete();
    }
    if(isdefined(self.var_599e2fb8))
    {
        self.var_599e2fb8 delete();
    }

    rand = randomintrange(0, 3);
	playsoundatposition("slam_ice_freeze_0" + rand, self.origin);

	fx = spawn("script_model", self.origin + vectorscale((0, 0, 1), 35));
	fx setmodel("tag_origin");
	fx.fx = playfxontag(level._effect["slam_ice_idle"], fx, "tag_origin");
	fx linkto(self);
	self.slam_fx = fx;
    self.slam_fx thread kill_on_death_or_unfreeze(self);

    block = spawn("script_model", self.origin + vectorscale((0, 0, 1), 35));
	block setmodel("p_zombie_ice_chunk_01");
	block linkto(self);
	self.var_599e2fb8 = block;
    self.var_599e2fb8 thread kill_on_death_or_unfreeze(self);

    old_health = self.health;
	self.health = 1;
    self thread bib_death_effects();

    for(i = 0; i < level.var_7d05fd0a; i++)
    {
	    self setmovespeedscale(0);
        wait 1;
    }
    
    self notify("bib_unfreeze");

	self setmovespeedscale(1);
    self.health = old_health;

    playfx(level._effect["slam_ice_break"], self.origin + vectorscale((0, 0, 1), 35));
	rand = randomintrange(0, 3);
	playsoundatposition("slam_ice_shatter_0" + rand, self.origin);
	if(isdefined(self.var_599e2fb8))
	{
		self.var_599e2fb8 delete();
	}
}

bib_death_effects()
{
    self endon("bib_unfreeze");
    self waittill("death");
    if(isdefined(self.var_599e2fb8))
	{
		self.var_599e2fb8 delete();
	}
	self.slam_fx delete();
	self setmovespeedscale(1);
	rand = randomintrange(0, 3);
	playsoundatposition("slam_ice_shatter_0" + rand, self.origin);
	playfx(level._effect["slam_ice_break"], self.origin + vectorscale((0, 0, 1), 35));
	self startragdoll();
}

kill_on_death_or_unfreeze(zombie)
{
    self endon("death");
    zombie util::waittill_any("bib_unfreeze");
    if(isdefined(self.fx))
    {
        self.fx delete();
    }
    self delete();
}

bib_check_height()
{
    v_ground = groundtrace(self.origin, self.origin - (0,0, 1000), 0, undefined)["position"];
    if(!isdefined(v_ground))
    {
        return true;
    }
    return distanceSquared(self.origin, v_ground) > 100;
}

update_bib_state()
{
    if(self.bib_state != "ground")
    {
        if(self isOnGround()) // on ground now
        {
            if(self.bib_state == "air_slamming")
            {
                self.bib_state = "air_do_slam";
                return;
            }
            self.bib_state = "ground";
            return;
        }

        if(self.bib_state == "air_initial")
        {
            if(!bib_check_height())
            {
                wait 0.1; // wait a bit to trace again
                return;
            }
            
            self.bib_state = "air_primed";
        }

        if(self jumpbuttonpressed() && self.bib_state == "air_primed") // high enough in the air
        {
            if(!bib_check_height())
            {
                wait 0.05; // wait a bit to trace again
                return;
            }
            self.bib_state = "air_double_jump";
        }

        if(self jumpbuttonpressed() && self.bib_state == "air_jumped") // high enough in the air and we already double jumped
        {
            if(!bib_check_height())
            {
                wait 0.05; // wait a bit to trace again
                return;
            }
            self.bib_state = "air_slamming";
        }
        return;
    }

    if(!self isOnGround()) // state is ground but we are in the air
    {
        self.bib_state = "air_initial";
        while(self jumpbuttonpressed() && !self isOnGround())
        {
            wait 0.05; // wait for the player to release their button press
        }
    }
}
#endregion

#region crusaders ale
delete_perk_crusaders_ale()
{
    delete_perk_by_names("specialty_flashprotection", "vending_crusaders_ale");
}
#endregion

#region madgaz moonshine
fix_madgaz_moonshine()
{
    if(!isdefined(level._custom_perks["specialty_flakjacket"]))
    {
        return;
    }
    level._custom_perks["specialty_flakjacket"]._player_thread_give = level._custom_perks["specialty_flakjacket"].player_thread_give;
    level._custom_perks["specialty_flakjacket"].player_thread_give = function() =>
    {
        if(isfunctionptr(level._custom_perks["specialty_flakjacket"]._player_thread_give))
        {
            self thread [[ level._custom_perks["specialty_flakjacket"]._player_thread_give ]]();
        }
        self thread watch_mgm_pvp();
    };
}

watch_mgm_pvp()
{
    self notify("watch_mgm_pvp");
    self endon("watch_mgm_pvp");
    self endon(#"hash_d972bd0b");
    self endon("bled_out");
    self endon("disconnect");
    while(self hasperk("specialty_flakjacket"))
    {
        while(self isonslide())
		{
			wait(0.05);
			if(!self isonslide())
			{
                if(!isdefined(self.var_a440ec))
                {
                    self.var_a440ec = 25;
                }
                self.var_a440ec++; // limiting usage is pretty dumb with no indicator...
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
                    if(distance(player.origin, self.origin) <= 100)
                    {
                        player blast_furnace_player_burn(self, level.weaponnone, AAT_BLASTFURNACE_PVP_DAMAGE / 10);
                    }
                }
			}
		}
        wait 0.05;
    }
}
#endregion

#region elemental_pop
fix_elemental_pop()
{
    if(DISABLE_TURNED)
    {
        arrayremovevalue(level.var_b3051fe, "zm_aat_turned", false);
    }
    aat::register_reroll("elemental_pop", 2, serious::has_elemental_pop, undefined);
}
has_elemental_pop()
{
    return self hasperk("specialty_combat_efficiency");
}
#endregion

#region ICU
fix_perk_ICU(fn_laststand)
{
    if(!isdefined(level._custom_perks["specialty_immunecounteruav"]))
    {
        return;
    }

    if(isdefined(fn_laststand))
    {
        for(i = 0; i < level._callbacks[#"hash_6751ab5b"].size; i++)
        {
            if(fn_laststand == level._callbacks[#"hash_6751ab5b"][i][0])
            {
                arrayremoveindex(level._callbacks[#"hash_6751ab5b"], i, false);
                break;
            }
        }
    }

    level._custom_perks["specialty_immunecounteruav"].player_thread_give = function() =>
    {
        self notify("specialty_immunecounteruav_start");
        self endon("specialty_immunecounteruav_stop");
        self endon("disconnect");
        self endon("player_suicide");
        self endon("bled_out");

        icu_cleanup = function () =>
        {
            self endon("disconnect");
            self endon("player_suicide");
            self endon("bled_out");
            self waittill("specialty_immunecounteruav_stop");
            self update_gm_speed_boost();
        };

        self thread [[ icu_cleanup ]]();
        
        rapid_damage = 0;
        last_damaged = gettime();
        b_boosted = false;
        for(;;)
        {
            self waittill("damage", damage, attacker, dir, point, mod, model, tag, part, weapon, flags, inflictor, chargelevel);
            if(!isdefined(damage))
            {
                continue;
            }
            if((last_damaged - gettime()) > 1000)
            {
                rapid_damage = 0;
            }
            last_damaged = gettime();
            rapid_damage += damage;
            if(rapid_damage >= (self.maxhealth / 4))
            {
                rapid_damage = 0;
                self update_gm_speed_boost(self, 1.6, true);
                wait 3;
                self update_gm_speed_boost();
                wait 5;
            }
        }
    };
}
#endregion

#region Vigor Rush

has_vigor_rush()
{
    if(isdefined(level.has_vigor_rush_override))
    {
        return self [[ level.has_vigor_rush_override ]]();
    }
    return self hasperk("specialty_directionalfire");
}

fix_vigor_rush()
{
    level.zbr_damage_callbacks[level.zbr_damage_callbacks.size] = function(einflictor, eattacker, idamage = 0, idflags, smeansofdeath = "MOD_UNKNOWN", sweapon, vpoint, vdir, shitloc, psoffsettime) => 
    {
        if(!isdefined(eattacker) || !isplayer(eattacker) || !(eattacker has_vigor_rush()) || idamage < 10)
        {
            return idamage;
        }

        if(smeansofdeath is undefined)
        {
            return;
        }

        // if(randomint(100) > 25)
        // {
        //     return idamage;
        // }

        if(smeansofdeath == "MOD_PROJECTILE" || smeansofdeath == "MOD_EXPLOSIVE")
        {
            return int(idamage * 1.1);
        }
        
        if(smeansofdeath == "MOD_BULLET" || smeansofdeath == "MOD_PISTOL_BULLET" || smeansofdeath == "MOD_RIFLE_BULLET")
        {
            var_960d2e99 = util::spawn_model("tag_origin", vpoint, (0, 0, 0));
	        n_fx = playfxontag(level._effect["exp_directionalfire"], var_960d2e99, "tag_origin");
            foreach(player in getplayers())
            {
                if(player.team == eattacker.team)
                {
                    continue;
                }
                if(distancesquared(player.origin, vpoint) > 10000)
                {
                    continue;
                }
                if(player.last_vr_burst is defined and ((gettime() - player.last_vr_burst) < 200))
                {
                    continue;
                }
                player.last_vr_burst = gettime();
                player dodamage(int(idamage * 0.1), vpoint, eattacker, undefined, "none", "MOD_PROJECTILE_SPLASH", 0, level.weaponnone);
            }
            foreach(zomb in getaiteamarray("axis"))
            {
                if(!isalive(zomb))
                {
                    continue;
                }
                if(distancesquared(zomb.origin, vpoint) < 4096)
                {
                    zomb dodamage(int(idamage * 0.2), vpoint, eattacker);
                }
            }
            var_960d2e99 thread [[ function(n_fx) => { wait 0.5; n_fx delete(); self delete(); } ]](n_fx);
        }
        return idamage;
    };
}
#endregion

#region Atomic Liquor
fix_atomic_liqueur()
{
    if(!isdefined(level._custom_perks["specialty_nottargetedbyairsupport"]))
    {
        return;
    }

    level._custom_perks["specialty_nottargetedbyairsupport"].player_thread_give = function() =>
    {
        self notify("specialty_nottargetedbyairsupport_start");
        self.cooldown = 0;
        self endon("specialty_nottargetedbyairsupport_stop");

        dmg_func_1 = @namespace_ae1417ff<scripts\zm\_zm_perk_atomic_liqueur.gsc>::function_1d4e159e;

        for(;;)
        {
            if(isdefined(self ismeleeing()) && self ismeleeing() && !self.cooldown)
            {
                self thread [[ dmg_func_1 ]](5, 300, self);

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
                    if(distanceSquared(player.origin, self.origin) > 90000)
                    {
                        continue;
                    }
                    if(!BulletTracePassed(self geteye(), player.origin + (0,0,50), false, self))
                    {
                        continue;
                    }
                    player thread ThundergunKnockback(self, level.weaponnone, 250);
                }

                self thread [[ function(time, sound_alias) => {
                    self endon("specialty_nottargetedbyairsupport_stop");
                    self.cooldown = 1;
                    wait(time);
                    self.cooldown = 0;
                    self playsoundtoplayer("atomic_knife_ready", sound_alias);
                }]](15, self);

                self playsoundtoplayer("atomic_knife_explode", self);
            }
            wait 0.05;
        }
    };
}
#endregion

#region Blood Wolf Bite
fix_bwb()
{
    compiler::script_detour("scripts/zm/_zm_perk_blood_wolf_bite.gsc", 0xe6205b53, 0xba2d0cac, function(owner) =>
    {
        owner endon("disconnect");
        owner endon("bled_out");
        self clientfield::set("LUNA", 1);
        self setmodel("blood_wolf_luna");
        wait(0.05);
        self.script_string = "riser";
        wait(0.05);
        self notify("no_rise");
        wait(0.05);
        self stopanimscripted();
        self forceteleport((self.origin[0], self.origin[1], self.origin[2] + 40));
        self thread zm_spawner::zombie_complete_emerging_into_playable_area();
        self thread zm_spawner::zombie_setup_attack_properties();
        self.goalradius = 32;
        self.in_the_ground = undefined;
        or = owner.origin;
        playfx(level._effect["lightning_dog_spawn"], or);
        playsoundatposition("zmb_hellhound_prespawn", or);
        wait(1.5);
        playsoundatposition("zmb_hellhound_bolt", or);
        self forceteleport(or);
        self.team = owner.team;
        self.aat_turned = 1;
        self.allowdeath = 0;
        self.allowpain = 0;
        self.no_gib = 1;
        self.disablearrivals = 1;
        self.disableexits = 1;
        self.zombie_move_speed = "sprint";
        while(isdefined(self) && isdefined(owner) && isdefined(owner.origin))
        {
            if(distance(owner.origin, self.origin) > 3000)
            {
                self forceteleport(owner.origin);
            }
            else
            {
                if(distance(owner.origin, self.origin) > 200 && !isdefined(self.favoriteenemy))
                {
                    self setgoal(owner.origin);
                }
                else if(distance(owner.origin, self.origin) < 200 && !isdefined(self.favoriteenemy))
                {
                    self setgoal(self.origin);
                }
            }
            wait(0.1);
        }
    });
}
#endregion

delete_perk_by_names(str_specialty, str_radiant_name)
{
    arrayremoveindex(level._custom_perks, str_specialty, true);
    machines = getentarray(str_radiant_name, "targetname");
    foreach(machine in machines)
    {
        machine_triggers = getentarray(str_radiant_name, "target");
        foreach(trig in machine_triggers)
        {
            trig delete();
        }
        machine delete();
    }

    if(isarray(level._random_perk_machine_perk_list))
    {
        arrayremovevalue(level._random_perk_machine_perk_list, str_specialty, false);
    }

    level notify(str_specialty + "_power_thread_end");
}

delete_whos_who(v1 = false)
{
    if(!v1)
    {
        thread delete_whos_who(true);
        return;
    }
    level flag::wait_till("initial_blackscreen_passed");
    delete_perk_by_names("specialty_whoswho", "vending_whoswho");
    level.whoswho_laststand_func = undefined;
}

clone_perk_machine(str_specialty, str_radiant_name, new_origin, new_angles)
{
    og_machine = getentarray(str_radiant_name, "targetname")[0];
	s_spawn_pos = spawnstruct();
    s_spawn_pos.script_noteworthy = str_specialty;
    s_spawn_pos.model = og_machine.model;
    s_spawn_pos.origin = new_origin;
    s_spawn_pos.angles = new_angles;
    
    perk = s_spawn_pos.script_noteworthy;

    if(isdefined(perk) && isdefined(s_spawn_pos.model))
    {
        t_use = spawn("trigger_radius_use", s_spawn_pos.origin + vectorscale((0, 0, 1), 60), 0, 40, 80);
        t_use.targetname = "zombie_vending";
        t_use.script_noteworthy = perk;
        t_use triggerignoreteam();
        perk_machine = spawn("script_model", s_spawn_pos.origin);
        if(!isdefined(s_spawn_pos.angles))
        {
            s_spawn_pos.angles = (0, 0, 0);
        }
        perk_machine.angles = s_spawn_pos.angles;
        perk_machine setmodel(s_spawn_pos.model);
        if(isdefined(level._no_vending_machine_bump_trigs) && level._no_vending_machine_bump_trigs)
        {
            bump_trigger = undefined;
        }
        else
        {
            bump_trigger = spawn("trigger_radius", s_spawn_pos.origin + vectorscale((0, 0, 1), 20), 0, 40, 80);
            bump_trigger.script_activated = 1;
            bump_trigger.script_sound = "zmb_perks_bump_bottle";
            bump_trigger.targetname = "audio_bump_trigger";
        }
        if(isdefined(level._no_vending_machine_auto_collision) && level._no_vending_machine_auto_collision)
        {
            collision = undefined;
        }
        else
        {
            collision = spawn("script_model", s_spawn_pos.origin, 1);
            collision.angles = s_spawn_pos.angles;
            collision setmodel("zm_collision_perks1");
            collision.script_noteworthy = "clip";
            collision disconnectpaths();
        }
        t_use.clip = collision;
        t_use.machine = perk_machine;
        t_use.bump = bump_trigger;
        perk_machine.script_notify = og_machine.script_notify;
        perk_machine.target = og_machine.target;
        perk_machine.blocker_model = og_machine.blocker_model;
        perk_machine.script_int = og_machine.script_int;
        perk_machine.turn_on_notify = og_machine.turn_on_notify;
        t_use.script_sound = "mus_perks_speed_jingle";
        t_use.script_string = "speedcola_perk";
        t_use.script_label = "mus_perks_speed_sting";
        t_use.target = "vending_sleight";
        perk_machine.script_string = "speedcola_perk";
        perk_machine.targetname = "vending_sleight";
        if(isdefined(bump_trigger))
        {
            bump_trigger.script_string = "speedcola_perk";
        }
        if(isdefined(level._custom_perks[perk]) && isdefined(level._custom_perks[perk].perk_machine_set_kvps))
        {
            [[level._custom_perks[perk].perk_machine_set_kvps]](t_use, perk_machine, bump_trigger, collision);
        }

        t_use thread zm_perks::vending_trigger_think();
        t_use thread zm_perks::electric_perks_dialog();
        t_use.power_on = 1;
        
        perk_machine setmodel(level.machine_assets[perk].on_model);
        perk_machine vibrate(vectorscale((0, -1, 0), 100), 0.3, 0.4, 3);
        perk_machine playsound("zmb_perks_power_on");
        perk_machine thread zm_perks::perk_fx(level._custom_perks[perk].machine_light_effect);
        perk_machine thread zm_perks::play_loop_on_machine();

        if(isdefined(level.machine_assets[perk].power_on_callback))
        {
            perk_machine thread [[ level.machine_assets[perk].power_on_callback ]]();
        }

        wait 0.15;
        level notify(perk + "_power_on");
    }
}