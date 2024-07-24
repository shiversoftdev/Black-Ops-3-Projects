autoexec __init__sytem__()
{
	system::register("zm_killcam", serious::killcam__init__, undefined, undefined);
}

killcam__init__()
{
	callback::on_start_gametype(serious::killcam_init);
	level.numplayerswaitingtoenterkillcam = 0;
    level.killcam_record_settings = serious::killcam_record_settings;
    level.killcam_get_killcam_entity_info = serious::killcam_get_killcam_entity_info;
    level.killcam_cancel_on_use = serious::killcam_cancel_on_use;
    level.run_killcam = serious::run_killcam;
}

killcam_init()
{
	level.killcam = true;
	level.finalkillcam = true;
	init_final_killcam();
}

init_final_killcam()
{
	level.finalkillcamsettings = [];
	init_final_killcam_team("none");
	foreach(team in array("allies", "axis", "neutral", "free"))
	{
		init_final_killcam_team(team);
	}
	level.finalkillcam_winner = undefined;
	level.finalkillcam_winnerpicked = undefined;
}

init_final_killcam_team(team)
{
	level.finalkillcamsettings[team] = spawnstruct();
	clear_final_killcam_team(team);
}

clear_final_killcam_team(team)
{
	level.finalkillcamsettings[team].spectatorclient = undefined;
	level.finalkillcamsettings[team].weapon = undefined;
	level.finalkillcamsettings[team].meansofdeath = undefined;
	level.finalkillcamsettings[team].deathtime = undefined;
	level.finalkillcamsettings[team].deathtimeoffset = undefined;
	level.finalkillcamsettings[team].offsettime = undefined;
	level.finalkillcamsettings[team].killcam_entity_info = undefined;
	level.finalkillcamsettings[team].targetentityindex = undefined;
	level.finalkillcamsettings[team].perks = undefined;
	level.finalkillcamsettings[team].killstreaks = undefined;
	level.finalkillcamsettings[team].attacker = undefined;
}

killcam_record_settings(spectatorclient, targetentityindex, weapon, meansofdeath, deathtime, deathtimeoffset, offsettime, killcam_entity_info, perks, killstreaks, attacker)
{
	if(isdefined(attacker) && isdefined(attacker.team) && isdefined(level.teams[attacker.team]))
	{
		team = attacker.team;
		if(!isdefined(level.finalkillcamsettings[team]))
		{
			level.finalkillcamsettings[team] = spawnstruct();
		}
		level.finalkillcamsettings[team].spectatorclient = spectatorclient;
		level.finalkillcamsettings[team].weapon = weapon;
		level.finalkillcamsettings[team].meansofdeath = meansofdeath;
		level.finalkillcamsettings[team].deathtime = deathtime;
		level.finalkillcamsettings[team].deathtimeoffset = deathtimeoffset;
		level.finalkillcamsettings[team].offsettime = offsettime;
		level.finalkillcamsettings[team].killcam_entity_info = killcam_entity_info;
		level.finalkillcamsettings[team].targetentityindex = targetentityindex;
		level.finalkillcamsettings[team].perks = perks;
		level.finalkillcamsettings[team].killstreaks = killstreaks;
		level.finalkillcamsettings[team].attacker = attacker;
	}
	level.finalkillcamsettings["none"].spectatorclient = spectatorclient;
	level.finalkillcamsettings["none"].weapon = weapon;
	level.finalkillcamsettings["none"].meansofdeath = meansofdeath;
	level.finalkillcamsettings["none"].deathtime = deathtime;
	level.finalkillcamsettings["none"].deathtimeoffset = deathtimeoffset;
	level.finalkillcamsettings["none"].offsettime = offsettime;
	level.finalkillcamsettings["none"].killcam_entity_info = killcam_entity_info;
	level.finalkillcamsettings["none"].targetentityindex = targetentityindex;
	level.finalkillcamsettings["none"].perks = perks;
	level.finalkillcamsettings["none"].killstreaks = killstreaks;
	level.finalkillcamsettings["none"].attacker = attacker;
}

killcam_get_killcam_entity_info(attacker, einflictor, weapon)
{
	entity_info = spawnstruct();
	entity_info.entity_indexes = [];
	entity_info.entity_spawntimes = [];
	get_primary_killcam_entity(attacker, einflictor, weapon, entity_info);
	return entity_info;
}

get_primary_killcam_entity(attacker, einflictor, weapon, entity_info)
{
	killcamentity = self get_killcam_entity(attacker, einflictor, weapon);
	killcamentitystarttime = get_killcam_entity_start_time(killcamentity);
	killcamentityindex = -1;
	if(isdefined(killcamentity))
	{
		killcamentityindex = killcamentity getentitynumber();
	}
	entity_info.entity_indexes[entity_info.entity_indexes.size] = killcamentityindex;
	entity_info.entity_spawntimes[entity_info.entity_spawntimes.size] = killcamentitystarttime;
	get_secondary_killcam_entity(killcamentity, entity_info);
}

get_killcam_entity(attacker, einflictor, weapon)
{
	if(!isdefined(einflictor))
	{
		return undefined;
	}
	if(isdefined(self.killcamkilledbyent))
	{
		return self.killcamkilledbyent;
	}
	if(einflictor == attacker)
	{
		if(!isdefined(einflictor.ismagicbullet))
		{
			return undefined;
		}
		if(isdefined(einflictor.ismagicbullet) && !einflictor.ismagicbullet)
		{
			return undefined;
		}
	}
	if(weapon.name == "hero_gravityspikes")
	{
		return undefined;
	}
	if(isdefined(einflictor.killcament))
	{
		if(einflictor.killcament == attacker)
		{
			return undefined;
		}
		return einflictor.killcament;
	}
	if(isdefined(einflictor.killcamentities))
	{
		return get_closest_killcam_entity(attacker, einflictor.killcamentities);
	}
	if(isdefined(einflictor.script_gameobjectname) && einflictor.script_gameobjectname == "bombzone")
	{
		return einflictor.killcament;
	}
	return einflictor;
}

get_closest_killcam_entity(attacker, killcamentities, depth = 0)
{
	closestkillcament = undefined;
	closestkillcamentindex = undefined;
	closestkillcamentdist = undefined;
	origin = undefined;
	foreach(killcamentindex, killcament in killcamentities)
	{
		if(killcament == attacker)
		{
			continue;
		}
		origin = killcament.origin;
		if(isdefined(killcament.offsetpoint))
		{
			origin = origin + killcament.offsetpoint;
		}
		dist = distancesquared(self.origin, origin);
		if(!isdefined(closestkillcament) || dist < closestkillcamentdist)
		{
			closestkillcament = killcament;
			closestkillcamentdist = dist;
			closestkillcamentindex = killcamentindex;
		}
	}
	if(depth < 3 && isdefined(closestkillcament))
	{
		if(!bullettracepassed(closestkillcament.origin, self.origin, 0, self))
		{
			killcamentities[closestkillcamentindex] = undefined;
			betterkillcament = get_closest_killcam_entity(attacker, killcamentities, depth + 1);
			if(isdefined(betterkillcament))
			{
				closestkillcament = betterkillcament;
			}
		}
	}
	return closestkillcament;
}

get_killcam_entity_start_time(killcamentity)
{
	killcamentitystarttime = 0;
	if(isdefined(killcamentity))
	{
		if(isdefined(killcamentity.starttime))
		{
			killcamentitystarttime = killcamentity.starttime;
		}
		else
		{
			killcamentitystarttime = killcamentity.birthtime;
		}
		if(!isdefined(killcamentitystarttime))
		{
			killcamentitystarttime = 0;
		}
	}
	return killcamentitystarttime;
}

get_secondary_killcam_entity(entity, entity_info)
{
	if(!isdefined(entity) || !isdefined(entity.killcamentityindex))
	{
		return;
	}
	entity_info.entity_indexes[entity_info.entity_indexes.size] = entity.killcamentityindex;
	entity_info.entity_spawntimes[entity_info.entity_spawntimes.size] = entity.killcamentitystarttime;
}

killcam_cancel_on_use()
{
	self thread killcam_cancel_on_use_specific_button();
}

killcam_cancel_on_use_specific_button()
{
	self endon("death_delay_finished");
    self endon("bled_out");
	self endon("disconnect");
	level endon("game_ended");
	for(;;)
	{
		if(!self usebuttonpressed())
		{
			wait(0.05);
			continue;
		}
		buttontime = 0;
		while(self usebuttonpressed())
		{
			buttontime = buttontime + 0.05;
			wait(0.05);
		}
		if(buttontime >= 0.5)
		{
			continue;
		}
		buttontime = 0;
		while(!self usebuttonpressed() && buttontime < 0.5)
		{
			buttontime = buttontime + 0.05;
			wait(0.05);
		}
		if(buttontime >= 0.5)
		{
			continue;
		}
		self.cancelkillcam = 1;
		return;
	}
}

run_killcam(attackernum, targetnum, killcam_entity_info, weapon, meansofdeath, deathtime, deathtimeoffset, offsettime, respawn, maxtime, perks, killstreaks, attacker, keep_deathcam)
{
	self endon("disconnect");
	self endon("spawned_player");
	self endon("considering_spawnpoint");
	level endon("game_ended");

	if(attackernum < 0)
	{
		return;
	}

	self thread watch_for_skip_killcam();
	wait(0.05);

	postdeathdelay = (gettime() - deathtime) / 1000;
	predelay = postDeathDelay + deathTimeOffset;
	killcamentitystarttime = 0;
	camtime = 5;
	postdelay = 2;
	killcamlength = camtime + postdelay;
	killcamoffset = camtime + predelay;

	self notify("begin_killcam", gettime());
	self util::clientnotify("sndDEDe");

	killcamstarttime = gettime() - (killcamoffset * 1000);

	self.sessionstate = "spectator";
	self.spectatekillcam = true;
	self.spectatorclient = attackernum;
	self.killcamentity = -1;
	self thread set_killcam_entities( killcam_entity_info, killcamstarttime );

	self.killcamtargetentity = targetnum;
	self.killcamweapon = weapon;
	self.killcammod = meansofdeath;
	self.archivetime = killcamoffset;
	self.killcamlength = killcamlength;
	self.psoffsettime = offsettime;
	
	foreach(team in level.gm_teams)
	{
		self allowspectateteam(team, 1);
	}
	self allowspectateteam("freelook", 1);
	self allowspectateteam("none", 1);


	self thread killcam_check_for_abrupt_end();
	wait 0.05;

	if ( self.archivetime <= predelay )
	{
		self.sessionstate = "spectator";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		self.spectatekillcam = false;
		self notify ("end_killcam");		
		return;
	}

	self.killcam = true;
	// luinotifyevent(&"pre_killcam_transition");
	self thread spawned_killcam_cleanup();
	self thread wait_skip_killcam_button();
	self thread wait_killcam_time();
	self util::waittill_any_timeout(killcamlength, "end_killcam", "end_game");
	self killcam_end(0);

	if(isdefined(keep_deathcam) && keep_deathcam)
	{
		return;
	}

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.spectatekillcam = false;
}

watch_for_skip_killcam()
{
	self endon("begin_killcam");
	self util::waittill_any("disconnect", "spawned");
	wait(0.05);
	// level.numplayerswaitingtoenterkillcam--;
}

get_killcam_entity_info_starttime(entity_info)
{
	if(entity_info.entity_spawntimes.size == 0)
	{
		return 0;
	}
	return entity_info.entity_spawntimes[entity_info.entity_spawntimes.size - 1];
}

killcam_calc_time(weapon, entitystarttime, predelay, respawn, maxtime)
{
	camtime = 0;
	if(!respawn)
    {
        camtime = 5;
    }
    else if(isdefined(weapon) && weapon.isgrenadeweapon)
    {
        camtime = 4.25;
    }
    else
    {
        camtime = 2.5;
    }
	if(isdefined(maxtime))
	{
		if(camtime > maxtime)
		{
			camtime = maxtime;
		}
		if(camtime < 0.05)
		{
			camtime = 0.05;
		}
	}
	return camtime;
}

killcam_calc_post_delay()
{
	return 2;
}

set_killcam_entities(entity_info, killcamstarttime)
{
	for(index = 0; index < entity_info.entity_indexes.size; index++)
	{
		delayms = entity_info.entity_spawntimes[index] - killcamstarttime - 100;
		thread killcam_set_entity(entity_info.entity_indexes[index], delayms);
		if(delayms <= 0)
		{
			return;
		}
	}
}

killcam_set_entity(killcamentityindex, delayms)
{
	self endon("disconnect");
	self endon("end_killcam");
	self endon("spawned");
	if(delayms > 0)
	{
		wait(delayms / 1000);
	}
	self.killcamentity = killcamentityindex;
}

killcam_check_for_abrupt_end()
{
	self endon("disconnect");
    self endon("bled_out");
	self endon("end_killcam");
	for(;;)
	{
		if(self.archivetime <= 0)
		{
			break;
		}
		wait(0.05);
	}
	self notify("end_killcam");
}

spawned_killcam_cleanup()
{
	self endon("end_killcam");
	self endon("disconnect");
	self util::waittill_any("spawned", "bled_out");
	self killcam_end(0);
}

wait_skip_killcam_button()
{
	self endon("disconnect");
    self endon("bled_out");
	self endon("end_killcam");
	while(self usebuttonpressed())
	{
		wait(0.05);
	}
	while(!self usebuttonpressed())
	{
		wait(0.05);
	}
	if(isdefined(self.killcamsskipped))
	{
		self.killcamsskipped++;
	}
	else
	{
		self.killcamsskipped = 1;
	}
	self notify("end_killcam");
	self util::clientnotify("fkce");
}

wait_killcam_time()
{
	self endon("disconnect");
	self endon("end_killcam");
	wait(self.killcamlength - 0.05);
	self notify("end_killcam");
}

killcam_end(final)
{
	if(isdefined(self.kc_skiptext))
	{
		self.kc_skiptext.alpha = 0;
	}
	if(isdefined(self.kc_timer))
	{
		self.kc_timer.alpha = 0;
	}
	self.killcam = undefined;
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.spectatekillcam = false;
}