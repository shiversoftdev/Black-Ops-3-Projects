#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\demo_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\gameobjects_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\scoreevents_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_hero_weapon;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#namespace zm_laststand;

function autoexec zm_underwater_systemignores()
{
	if(tolower(getdvarstring("mapname")) == "zm_leviathan")
	{
		system::ignore("zm_kraken");
		system::ignore("zm_diver");
		system::ignore("zm_leaper");
		system::ignore("zm_leviathan_audio");
		system::ignore("zm_trap_steam");
	}
	if(tolower(getdvarstring("mapname")) == "zm_der_riese")
	{
		system::ignore("zm_ai_catalyst_ice");
	}
}

function autoexec __init__sytem__()
{
	system::register("zm_laststand", &__init__, undefined, undefined);
}

function __init__()
{
	laststand_global_init();
	level.weaponsuicide = getweapon("death_self");
	level.primaryprogressbarx = 0;
	level.primaryprogressbary = 110;
	level.primaryprogressbarheight = 4;
	level.primaryprogressbarwidth = 120;
	level.primaryprogressbary_ss = 280;
	if(getdvarstring("revive_trigger_radius") == "")
	{
		setdvar("revive_trigger_radius", "40");
	}
	level.laststandgetupallowed = 0;
	if(!isdefined(level.vsmgr_prio_visionset_zm_laststand))
	{
		level.vsmgr_prio_visionset_zm_laststand = 1000;
	}
	visionset_mgr::register_info("visionset", "zombie_last_stand", 1, level.vsmgr_prio_visionset_zm_laststand, 31, 1, &visionset_mgr::ramp_in_thread_per_player, 0);
	if(!isdefined(level.vsmgr_prio_visionset_zm_death))
	{
		level.vsmgr_prio_visionset_zm_death = 1100;
	}
	visionset_mgr::register_info("visionset", "zombie_death", 1, level.vsmgr_prio_visionset_zm_death, 31, 1, &visionset_mgr::ramp_in_thread_per_player, 0);
}

function laststand_global_init()
{
	level.const_laststand_getup_count_start = 0;
	level.const_laststand_getup_bar_start = 0.5;
	level.const_laststand_getup_bar_regen = 0.0025;
	level.const_laststand_getup_bar_damage = 0.1;
	level.player_name_directive = [];
	level.player_name_directive[0] = &"ZOMBIE_PLAYER_NAME_0";
	level.player_name_directive[1] = &"ZOMBIE_PLAYER_NAME_1";
	level.player_name_directive[2] = &"ZOMBIE_PLAYER_NAME_2";
	level.player_name_directive[3] = &"ZOMBIE_PLAYER_NAME_3";
}

function player_last_stand_stats(einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime, deathanimduration)
{
	if(isdefined(attacker) && isplayer(attacker) && attacker != self)
	{
		if("zcleansed" == level.gametype)
		{
			demo::bookmark("kill", gettime(), attacker, self, 0, einflictor);
		}
		if("zcleansed" == level.gametype)
		{
			if(!(isdefined(attacker.is_zombie) && attacker.is_zombie))
			{
				attacker.kills++;
			}
			else
			{
				attacker.downs++;
			}
		}
		else
		{
			attacker.kills++;
		}
		attacker zm_stats::increment_client_stat("kills");
		attacker zm_stats::increment_player_stat("kills");
		attacker addweaponstat(weapon, "kills", 1);
		if(zm_utility::is_headshot(weapon, shitloc, smeansofdeath))
		{
			attacker.headshots++;
			attacker zm_stats::increment_client_stat("headshots");
			attacker addweaponstat(weapon, "headshots", 1);
			attacker zm_stats::increment_player_stat("headshots");
		}
	}
	self increment_downed_stat();
	if(level flag::get("solo_game") && !self.lives && getnumconnectedplayers() < 2)
	{
		self zm_stats::increment_client_stat("deaths");
		self zm_stats::increment_player_stat("deaths");
		self zm_pers_upgrades_functions::pers_upgrade_jugg_player_death_stat();
	}
}

function increment_downed_stat()
{
	if("zcleansed" != level.gametype)
	{
		self.downs++;
	}
	self zm_stats::increment_global_stat("TOTAL_DOWNS");
	self zm_stats::increment_map_stat("TOTAL_DOWNS");
	self zm_stats::increment_client_stat("downs");
	self add_weighted_down();
	self zm_stats::increment_player_stat("downs");
	zonename = self zm_utility::get_current_zone();
	if(!isdefined(zonename))
	{
		zonename = "";
	}
	self recordplayerdownzombies(zonename);
}

function playerlaststand(einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime, deathanimduration)
{
	self notify("entering_last_stand");
	self disableweaponcycling();
	if(isdefined(level._game_module_player_laststand_callback))
	{
		self [[level._game_module_player_laststand_callback]](einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime, deathanimduration);
	}
	if(self laststand::player_is_in_laststand())
	{
		return;
	}
	if(isdefined(self.in_zombify_call) && self.in_zombify_call)
	{
		return;
	}
	self thread player_last_stand_stats(einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime, deathanimduration);
	if(isdefined(level.playerlaststand_func))
	{
		[[level.playerlaststand_func]](einflictor, attacker, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime, deathanimduration);
	}
	self.health = 1;
	self.laststand = 1;
	self set_ignoreme(1);
	callback::callback(#"hash_6751ab5b");
	self thread gameobjects::on_player_last_stand();
	if(!(isdefined(self.no_revive_trigger) && self.no_revive_trigger))
	{
		self revive_trigger_spawn();
	}
	else
	{
		self undolaststand();
	}
	if(isdefined(self.is_zombie) && self.is_zombie)
	{
		self takeallweapons();
		if(isdefined(attacker) && isplayer(attacker) && attacker != self)
		{
			attacker notify("killed_a_zombie_player", einflictor, self, idamage, smeansofdeath, weapon, vdir, shitloc, psoffsettime, deathanimduration);
		}
	}
	else
	{
		self laststand_disable_player_weapons();
		self laststand_give_pistol();
	}
	if(isdefined(level.playersuicideallowed) && level.playersuicideallowed && getplayers().size > 1)
	{
		if(!isdefined(level.canplayersuicide) || self [[level.canplayersuicide]]())
		{
			self thread suicide_trigger_spawn();
		}
	}
	if(isdefined(self.disabled_perks))
	{
		self.disabled_perks = [];
	}
	if(level.laststandgetupallowed)
	{
		self thread laststand_getup();
	}
	else
	{
		bleedout_time = getdvarfloat("player_lastStandBleedoutTime");
		if(isdefined(self.n_bleedout_time_multiplier))
		{
			bleedout_time = bleedout_time * self.n_bleedout_time_multiplier;
		}
		// level clientfield::increment("laststand_update" + self getentitynumber(), 30);
		self thread laststand_bleedout(bleedout_time);
	}
	demo::bookmark("player_downed", gettime(), self);
	self notify("player_downed");
	self thread refire_player_downed();
	self thread laststand::cleanup_laststand_on_disconnect();
}

function refire_player_downed()
{
	self endon("player_revived");
	self endon("death");
	self endon("disconnect");
	wait(1);
	if(self.num_perks)
	{
		self notify("player_downed");
	}
}

function laststand_disable_player_weapons()
{
	self disableweaponcycling();
	weaponinventory = self getweaponslist(1);
	self.laststandprimaryweapons = self getweaponslistprimaries();
	self.lastactiveweapon = self getcurrentweapon();
	quickswitch = 0;
	if(isdefined(self) && self isswitchingweapons())
	{
		quickswitch = 1;
	}
	if(self isthrowinggrenade() && zm_utility::is_offhand_weapon(self.lastactiveweapon))
	{
		quickswitch = 1;
	}
	if(zm_utility::is_hero_weapon(self.lastactiveweapon))
	{
		quickswitch = 1;
	}
	if(self.lastactiveweapon.isriotshield)
	{
		quickswitch = 1;
	}
	if(quickswitch)
	{
		if(isdefined(self.laststandprimaryweapons) && self.laststandprimaryweapons.size > 0)
		{
			self switchtoweaponimmediate();
		}
		else
		{
			self zm_weapons::give_fallback_weapon(1);
		}
		self util::waittill_any_timeout(1, "weapon_change_complete");
	}
	self.lastactiveweapon = self getcurrentweapon();
	self setlaststandprevweap(self.lastactiveweapon);
	self.laststandpistol = undefined;
	self.hadpistol = 0;
	for(i = 0; i < weaponinventory.size; i++)
	{
		weapon = weaponinventory[i];
		wclass = weapon.weapclass;
		if(weapon.isballisticknife)
		{
			wclass = "knife";
		}
		if(wclass == "pistol" || wclass == "pistol spread" || wclass == "pistolspread" && !isdefined(self.laststandpistol))
		{
			self.laststandpistol = weapon;
			self.hadpistol = 1;
		}
		if(weapon == level.weaponrevivetool || weapon === self.weaponrevivetool)
		{
			self zm_stats::increment_client_stat("failed_sacrifices");
			self zm_stats::increment_player_stat("failed_sacrifices");
		}
		else if(weapon.isperkbottle)
		{
			self takeweapon(weapon);
			self.lastactiveweapon = level.weaponnone;
			continue;
		}
		if(isdefined(zm_utility::get_gamemode_var("item_meat_weapon")))
		{
			if(weapon == zm_utility::get_gamemode_var("item_meat_weapon"))
			{
				self takeweapon(weapon);
				self.lastactiveweapon = level.weaponnone;
				continue;
			}
		}
	}
	if(isdefined(self.hadpistol) && self.hadpistol && isdefined(level.zombie_last_stand_pistol_memory))
	{
		self [[level.zombie_last_stand_pistol_memory]]();
	}
	if(!isdefined(self.laststandpistol))
	{
		if(!isdefined(self.hascompletedsuperee))
		{
			self.hascompletedsuperee = self zm_stats::get_global_stat("DARKOPS_GENESIS_SUPER_EE") > 0;
		}
		if(self.hascompletedsuperee)
		{
			self.laststandpistol = level.super_ee_weapon;
		}
		else
		{
			self.laststandpistol = level.laststandpistol;
		}
	}
	self notify("weapons_taken_for_last_stand");
}

function laststand_enable_player_weapons()
{
	if(self hasperk("specialty_additionalprimaryweapon") && isdefined(self.weapon_taken_by_losing_specialty_additionalprimaryweapon))
	{
		if(isdefined(level.return_additionalprimaryweapon))
		{
			self [[level.return_additionalprimaryweapon]](self.weapon_taken_by_losing_specialty_additionalprimaryweapon);
		}
		else
		{
			self zm_weapons::give_build_kit_weapon(self.weapon_taken_by_losing_specialty_additionalprimaryweapon);
		}
	}
	else if(isdefined(self.weapon_taken_by_losing_specialty_additionalprimaryweapon) && self.lastactiveweapon == self.weapon_taken_by_losing_specialty_additionalprimaryweapon)
	{
		self.lastactiveweapon = level.weaponnone;
	}
	if(isdefined(self.hadpistol) && !self.hadpistol && isdefined(self.laststandpistol))
	{
		self takeweapon(self.laststandpistol);
	}
	if(isdefined(self.hadpistol) && self.hadpistol == 1 && isdefined(level.zombie_last_stand_ammo_return) && isdefined(self.laststandpistol))
	{
		[[level.zombie_last_stand_ammo_return]]();
	}
	self enableweaponcycling();
	self enableoffhandweapons();
	if(self.lastactiveweapon != level.weaponnone && self hasweapon(self.lastactiveweapon) && !zm_utility::is_placeable_mine(self.lastactiveweapon) && !zm_equipment::is_equipment(self.lastactiveweapon) && !zm_utility::is_hero_weapon(self.lastactiveweapon))
	{
		self switchtoweapon(self.lastactiveweapon);
	}
	else
	{
		self switchtoweapon();
	}
	self.laststandpistol = undefined;
}

function laststand_has_players_weapons_returned(e_player)
{
	if(isdefined(e_player.laststandpistol))
	{
		return false;
	}
	return true;
}

function laststand_clean_up_on_disconnect(e_revivee, w_reviver, w_revive_tool)
{
	self endon("do_revive_ended_normally");
	revivetrigger = e_revivee.revivetrigger;
	e_revivee waittill("disconnect");
	if(isdefined(revivetrigger))
	{
		revivetrigger delete();
	}
	self laststand::cleanup_suicide_hud();
	if(isdefined(self.reviveprogressbar))
	{
		self.reviveprogressbar hud::destroyelem();
	}
	if(isdefined(self.revivetexthud))
	{
		self.revivetexthud destroy();
	}
	if(isdefined(w_reviver) && isdefined(w_revive_tool))
	{
		self revive_give_back_weapons(w_reviver, w_revive_tool);
	}
}

function laststand_clean_up_reviving_any(e_revivee)
{
	self endon("do_revive_ended_normally");
	e_revivee util::waittill_any("disconnect", "zombified", "stop_revive_trigger");
	self.is_reviving_any--;
	if(0 > self.is_reviving_any)
	{
		self.is_reviving_any = 0;
	}
	if(isdefined(self.reviveprogressbar))
	{
		self.reviveprogressbar hud::destroyelem();
	}
	if(isdefined(self.revivetexthud))
	{
		self.revivetexthud destroy();
	}
}

function laststand_give_pistol()
{
	if(isdefined(level.zombie_last_stand))
	{
		[[level.zombie_last_stand]]();
	}
	else
	{
		self giveweapon(self.laststandpistol);
		self givemaxammo(self.laststandpistol);
		self switchtoweapon(self.laststandpistol);
	}
	self thread wait_switch_weapon(1, self.laststandpistol);
}

function wait_switch_weapon(n_delay, w_weapon)
{
	self endon("player_revived");
	self endon("player_suicide");
	self endon("zombified");
	self endon("disconnect");
	wait(n_delay);
	self switchtoweapon(w_weapon);
}

function laststand_bleedout(delay)
{
	self endon("player_revived");
	self endon("player_suicide");
	self endon("zombified");
	self endon("disconnect");
	if(isdefined(self.is_zombie) && self.is_zombie || (isdefined(self.no_revive_trigger) && self.no_revive_trigger))
	{
		self notify("bled_out");
		util::wait_network_frame();
		self bleed_out();
		return;
	}
	self clientfield::set("zmbLastStand", 1);
	self.bleedout_time = delay;
	n_default_bleedout_time = getdvarfloat("player_lastStandBleedoutTime");
	n_bleedout_time = self.bleedout_time;
	n_start_time = gettime();
	while(self.bleedout_time > (int(delay * 0.5)))
	{
		if(n_bleedout_time > n_default_bleedout_time && !isdefined(self.n_bleedout_time_multiplier))
		{
			n_current_time = gettime();
			n_total_time = (n_current_time - n_start_time) / 1000;
			if(n_total_time > n_default_bleedout_time)
			{
				delay = 4;
				self.bleedout_time = 2;
				break;
			}
		}
		self.bleedout_time = self.bleedout_time - 1;
		wait(1);
	}
	visionset_mgr::activate("visionset", "zombie_death", self, delay * 0.5);
	while(self.bleedout_time > 0)
	{
		self.bleedout_time = self.bleedout_time - 1;
		// level clientfield::increment("laststand_update" + self getentitynumber(), self.bleedout_time + 1);
		wait(1);
	}
	while(isdefined(self.revivetrigger) && isdefined(self.revivetrigger.beingrevived) && self.revivetrigger.beingrevived == 1)
	{
		wait(0.1);
	}
	self notify("bled_out");
	util::wait_network_frame();
	self bleed_out();
}

function bleed_out()
{
	self laststand::cleanup_suicide_hud();
	if(isdefined(self.revivetrigger))
	{
		self.revivetrigger delete();
	}
	self.revivetrigger = undefined;
	self clientfield::set("zmbLastStand", 0);
	self zm_stats::increment_client_stat("deaths");
	self zm_stats::increment_player_stat("deaths");
	self zm_pers_upgrades_functions::pers_upgrade_jugg_player_death_stat();
	self recordplayerdeathzombies();
	self.last_bleed_out_time = gettime();
	self zm_equipment::take();
	self zm_hero_weapon::take_hero_weapon();
	// level clientfield::increment("laststand_update" + self getentitynumber(), 1);
	demo::bookmark("zm_player_bledout", gettime(), self, undefined, 1);
	level notify("bleed_out", self.characterindex);
	self undolaststand();
	visionset_mgr::deactivate("visionset", "zombie_last_stand", self);
	visionset_mgr::deactivate("visionset", "zombie_death", self);
	if(isdefined(level.is_zombie_level) && level.is_zombie_level)
	{
		self thread [[level.player_becomes_zombie]]();
	}
	else
	{
		if(isdefined(level.is_specops_level) && level.is_specops_level)
		{
			self thread [[level.spawnspectator]]();
		}
		else
		{
			self set_ignoreme(0);
		}
	}
}

function suicide_trigger_spawn()
{
	radius = getdvarint("revive_trigger_radius");
	self.suicideprompt = newclienthudelem(self);
	self.suicideprompt.alignx = "center";
	self.suicideprompt.aligny = "middle";
	self.suicideprompt.horzalign = "center";
	self.suicideprompt.vertalign = "bottom";
	self.suicideprompt.y = -170;
	if(self issplitscreen())
	{
		self.suicideprompt.y = -132;
	}
	self.suicideprompt.foreground = 1;
	self.suicideprompt.font = "default";
	self.suicideprompt.fontscale = 1.5;
	self.suicideprompt.alpha = 1;
	self.suicideprompt.color = (1, 1, 1);
	self.suicideprompt.hidewheninmenu = 1;
	self thread suicide_trigger_think();
}

function suicide_trigger_think()
{
	self endon("disconnect");
	self endon("zombified");
	self endon("stop_revive_trigger");
	self endon("player_revived");
	self endon("bled_out");
	self endon("fake_death");
	level endon("end_game");
	level endon("stop_suicide_trigger");
	self thread laststand::clean_up_suicide_hud_on_end_game();
	self thread laststand::clean_up_suicide_hud_on_bled_out();
	while(self usebuttonpressed())
	{
		wait(1);
	}
	if(!isdefined(self.suicideprompt))
	{
		return;
	}
	while(true)
	{
		wait(0.1);
		if(!isdefined(self.suicideprompt))
		{
			continue;
		}
		self.suicideprompt settext(&"ZOMBIE_BUTTON_TO_SUICIDE");
		if(!self is_suiciding())
		{
			continue;
		}
		self.pre_suicide_weapon = self getcurrentweapon();
		self giveweapon(level.weaponsuicide);
		self switchtoweapon(level.weaponsuicide);
		duration = self docowardswayanims();
		suicide_success = suicide_do_suicide(duration);
		self.laststand = undefined;
		self takeweapon(level.weaponsuicide);
		if(suicide_success)
		{
			self notify("player_suicide");
			util::wait_network_frame();
			self zm_stats::increment_client_stat("suicides");
			self bleed_out();
			return;
		}
		self switchtoweapon(self.pre_suicide_weapon);
		self.pre_suicide_weapon = undefined;
	}
}

function suicide_do_suicide(duration)
{
	level endon("end_game");
	level endon("stop_suicide_trigger");
	suicidetime = duration;
	timer = 0;
	suicided = 0;
	self.suicideprompt settext("");
	if(!isdefined(self.suicideprogressbar))
	{
		self.suicideprogressbar = self hud::createprimaryprogressbar();
	}
	if(!isdefined(self.suicidetexthud))
	{
		self.suicidetexthud = newclienthudelem(self);
	}
	self.suicideprogressbar hud::updatebar(0.01, 1 / suicidetime);
	self.suicidetexthud.alignx = "center";
	self.suicidetexthud.aligny = "middle";
	self.suicidetexthud.horzalign = "center";
	self.suicidetexthud.vertalign = "bottom";
	self.suicidetexthud.y = -173;
	if(self issplitscreen())
	{
		self.suicidetexthud.y = -147;
	}
	self.suicidetexthud.foreground = 1;
	self.suicidetexthud.font = "default";
	self.suicidetexthud.fontscale = 1.8;
	self.suicidetexthud.alpha = 1;
	self.suicidetexthud.color = (1, 1, 1);
	self.suicidetexthud.hidewheninmenu = 1;
	self.suicidetexthud settext(&"ZOMBIE_SUICIDING");
	while(self is_suiciding())
	{
		wait(0.05);
		timer = timer + 0.05;
		if(timer >= suicidetime)
		{
			suicided = 1;
			break;
		}
	}
	if(isdefined(self.suicideprogressbar))
	{
		self.suicideprogressbar hud::destroyelem();
	}
	if(isdefined(self.suicidetexthud))
	{
		self.suicidetexthud destroy();
	}
	if(isdefined(self.suicideprompt))
	{
		self.suicideprompt settext(&"ZOMBIE_BUTTON_TO_SUICIDE");
	}
	return suicided;
}

function can_suicide()
{
	if(!isalive(self))
	{
		return false;
	}
	if(!self laststand::player_is_in_laststand())
	{
		return false;
	}
	if(!isdefined(self.suicideprompt))
	{
		return false;
	}
	if(isdefined(self.is_zombie) && self.is_zombie)
	{
		return false;
	}
	if(isdefined(level.intermission) && level.intermission)
	{
		return false;
	}
	return true;
}

function is_suiciding(revivee)
{
	return self usebuttonpressed() && can_suicide();
}

function revive_trigger_spawn()
{
	if(isdefined(level.revive_trigger_spawn_override_link))
	{
		[[level.revive_trigger_spawn_override_link]](self);
	}
	else
	{
		radius = getdvarint("revive_trigger_radius");
		self.revivetrigger = spawn("trigger_radius", (0, 0, 0), 0, radius, radius);
		self.revivetrigger sethintstring("");
		self.revivetrigger setcursorhint("HINT_NOICON");
		self.revivetrigger setmovingplatformenabled(1);
		self.revivetrigger enablelinkto();
		self.revivetrigger.origin = self.origin;
		self.revivetrigger linkto(self);
		self.revivetrigger setinvisibletoplayer(self);
		self.revivetrigger.beingrevived = 0;
		self.revivetrigger.createtime = gettime();
	}
	self thread revive_trigger_think();
}

function revive_trigger_think(t_secondary)
{
	self endon("disconnect");
	self endon("zombified");
	self endon("stop_revive_trigger");
	level endon("end_game");
	self endon("death");
	while(true)
	{
		wait(0.05);
		if(isdefined(t_secondary))
		{
			t_revive = t_secondary;
		}
		else
		{
			t_revive = self.revivetrigger;
		}
		if(!isdefined(t_revive))
		{
			return;
		}
		t_revive sethintstring("");
		for(i = 0; i < level.players.size; i++)
		{
			n_depth = 0;
			n_depth = self depthinwater();
			if(isdefined(t_secondary))
			{
				if(level.players[i] can_revive(self, 1, 1) && level.players[i] istouching(t_revive) || n_depth > 20)
				{
					t_revive setrevivehintstring(&"ZOMBIE_BUTTON_TO_REVIVE_PLAYER", self.team);
					break;
				}
				continue;
			}
			if(level.players[i] can_revive_via_override(self) || level.players[i] can_revive(self) || n_depth > 20)
			{
				t_revive setrevivehintstring(&"ZOMBIE_BUTTON_TO_REVIVE_PLAYER", self.team);
				break;
			}
		}
		for(i = 0; i < level.players.size; i++)
		{
			e_reviver = level.players[i];
			if(self == e_reviver || !e_reviver is_reviving(self, t_secondary))
			{
				continue;
			}
			if(!isdefined(e_reviver.s_revive_override_used) || e_reviver.s_revive_override_used.b_use_revive_tool)
			{
				w_revive_tool = level.weaponrevivetool;
				if(isdefined(e_reviver.weaponrevivetool))
				{
					w_revive_tool = e_reviver.weaponrevivetool;
				}
				w_reviver = e_reviver getcurrentweapon();
				if(w_reviver == w_revive_tool)
				{
					continue;
				}
				e_reviver giveweapon(w_revive_tool);
				e_reviver switchtoweapon(w_revive_tool);
				e_reviver setweaponammostock(w_revive_tool, 1);
				e_reviver thread revive_give_back_weapons_when_done(w_reviver, w_revive_tool, self);
			}
			else
			{
				w_reviver = undefined;
				w_revive_tool = undefined;
			}
			b_revive_successful = e_reviver revive_do_revive(self, w_reviver, w_revive_tool, t_secondary);
			e_reviver notify("revive_done");
			if(isplayer(self))
			{
				self allowjump(1);
			}
			self.laststand = undefined;
			if(b_revive_successful)
			{
				if(isdefined(level.a_revive_success_perk_func))
				{
					foreach(func in level.a_revive_success_perk_func)
					{
						self [[func]]();
					}
				}
				self thread revive_success(e_reviver);
				self laststand::cleanup_suicide_hud();
				self notify("stop_revive_trigger");
				return;
			}
		}
	}
}

function revive_give_back_weapons_wait(e_reviver, e_revivee)
{
	e_revivee endon("disconnect");
	e_revivee endon("zombified");
	e_revivee endon("stop_revive_trigger");
	level endon("end_game");
	e_revivee endon("death");
	e_reviver waittill("revive_done");
}

function revive_give_back_weapons_when_done(w_reviver, w_revive_tool, e_revivee)
{
	revive_give_back_weapons_wait(self, e_revivee);
	self revive_give_back_weapons(w_reviver, w_revive_tool);
}

function revive_give_back_weapons(w_reviver, w_revive_tool)
{
	self takeweapon(w_revive_tool);
	if(self laststand::player_is_in_laststand())
	{
		return;
	}
	if(isdefined(level.revive_give_back_weapons_custom_func) && self [[level.revive_give_back_weapons_custom_func]](w_reviver))
	{
		return;
	}
	if(w_reviver != level.weaponnone && !zm_utility::is_placeable_mine(w_reviver) && !zm_equipment::is_equipment(w_reviver) && !w_reviver.isflourishweapon && self hasweapon(w_reviver))
	{
		self zm_weapons::switch_back_primary_weapon(w_reviver);
	}
	else
	{
		self zm_weapons::switch_back_primary_weapon();
	}
}

function can_revive(e_revivee, ignore_sight_checks = 0, ignore_touch_checks = 0)
{
	if(!isdefined(e_revivee.revivetrigger))
	{
		return false;
	}
	if(!isalive(self))
	{
		return false;
	}
	if(self laststand::player_is_in_laststand())
	{
		return false;
	}
	if(self.team != e_revivee.team)
	{
		return false;
	}
	if(isdefined(self.is_zombie) && self.is_zombie)
	{
		return false;
	}
	if(self zm_utility::has_powerup_weapon())
	{
		return false;
	}
	if(self zm_utility::has_hero_weapon())
	{
		return false;
	}
	if(isdefined(level.can_revive_use_depthinwater_test) && level.can_revive_use_depthinwater_test && e_revivee depthinwater() > 10)
	{
		return true;
	}
	if(isdefined(level.can_revive) && ![[level.can_revive]](e_revivee))
	{
		return false;
	}
	if(isdefined(level.can_revive_game_module) && ![[level.can_revive_game_module]](e_revivee))
	{
		return false;
	}
	if(!ignore_sight_checks && isdefined(level.revive_trigger_should_ignore_sight_checks))
	{
		ignore_sight_checks = [[level.revive_trigger_should_ignore_sight_checks]](self);
		if(ignore_sight_checks && isdefined(e_revivee.revivetrigger.beingrevived) && e_revivee.revivetrigger.beingrevived == 1)
		{
			ignore_touch_checks = 1;
		}
	}
	if(!ignore_touch_checks)
	{
		if(!self istouching(e_revivee.revivetrigger))
		{
			return false;
		}
	}
	if(!ignore_sight_checks)
	{
		if(!self laststand::is_facing(e_revivee))
		{
			return false;
		}
		if(!sighttracepassed(self.origin + vectorscale((0, 0, 1), 50), e_revivee.origin + vectorscale((0, 0, 1), 30), 0, undefined))
		{
			return false;
		}
		if(!bullettracepassed(self.origin + vectorscale((0, 0, 1), 50), e_revivee.origin + vectorscale((0, 0, 1), 30), 0, undefined))
		{
			return false;
		}
	}
	return true;
}

function is_reviving(e_revivee, t_secondary)
{
	if(self is_reviving_via_override(e_revivee))
	{
		return 1;
	}
	if(isdefined(t_secondary))
	{
		return self usebuttonpressed() && self can_revive(e_revivee, 1, 1) && self istouching(t_secondary);
	}
	return self usebuttonpressed() && can_revive(e_revivee);
}

function is_reviving_any()
{
	return isdefined(self.is_reviving_any) && self.is_reviving_any;
}

function revive_get_revive_time(e_revivee)
{
	revivetime = 3;
	if(self hasperk("specialty_quickrevive"))
	{
		revivetime = revivetime / 2;
	}
	if(self zm_pers_upgrades_functions::pers_revive_active())
	{
		revivetime = revivetime * 0.5;
	}
	if(isdefined(self.get_revive_time))
	{
		revivetime = self [[self.get_revive_time]](e_revivee);
	}
	return revivetime;
}

function revive_do_revive(e_revivee, w_reviver, w_revive_tool, t_secondary)
{
	revivetime = self revive_get_revive_time(e_revivee);
	timer = 0;
	revived = 0;
	e_revivee.revivetrigger.beingrevived = 1;
	name = level.player_name_directive[self getentitynumber()];
	e_revivee.revive_hud settext(&"ZOMBIE_PLAYER_IS_REVIVING_YOU", name);
	e_revivee laststand::revive_hud_show_n_fade(3);
	e_revivee.revivetrigger sethintstring("");
	if(isplayer(e_revivee))
	{
		e_revivee startrevive(self);
	}
	if(!isdefined(self.revivetexthud))
	{
		self.revivetexthud = newclienthudelem(self);
	}
	self thread laststand_clean_up_on_disconnect(e_revivee, w_reviver, w_revive_tool);
	if(!isdefined(self.is_reviving_any))
	{
		self.is_reviving_any = 0;
	}
	self.is_reviving_any++;
	self thread laststand_clean_up_reviving_any(e_revivee);
	if(isdefined(self.reviveprogressbar))
	{
		self.reviveprogressbar hud::updatebar(0.01, 1 / revivetime);
	}
	self.revivetexthud.alignx = "center";
	self.revivetexthud.aligny = "middle";
	self.revivetexthud.horzalign = "center";
	self.revivetexthud.vertalign = "bottom";
	self.revivetexthud.y = -113;
	if(self issplitscreen())
	{
		self.revivetexthud.y = -347;
	}
	self.revivetexthud.foreground = 1;
	self.revivetexthud.font = "default";
	self.revivetexthud.fontscale = 1.8;
	self.revivetexthud.alpha = 1;
	self.revivetexthud.color = (1, 1, 1);
	self.revivetexthud.hidewheninmenu = 1;
	if(self zm_pers_upgrades_functions::pers_revive_active())
	{
		self.revivetexthud.color = (0.5, 0.5, 1);
	}
	self.revivetexthud settext(&"ZOMBIE_REVIVING");
	self thread check_for_failed_revive(e_revivee);
	while(self is_reviving(e_revivee, t_secondary))
	{
		wait(0.05);
		timer = timer + 0.05;
		if(self laststand::player_is_in_laststand())
		{
			break;
		}
		if(isdefined(e_revivee.revivetrigger.auto_revive) && e_revivee.revivetrigger.auto_revive == 1)
		{
			break;
		}
		if(timer >= revivetime)
		{
			revived = 1;
			break;
		}
	}
	if(isdefined(self.reviveprogressbar))
	{
		self.reviveprogressbar hud::destroyelem();
	}
	if(isdefined(self.revivetexthud))
	{
		self.revivetexthud destroy();
	}
	if(isdefined(e_revivee.revivetrigger.auto_revive) && e_revivee.revivetrigger.auto_revive == 1)
	{
	}
	else if(!revived)
	{
		if(isplayer(e_revivee))
		{
			e_revivee stoprevive(self);
		}
	}
	e_revivee.revivetrigger sethintstring(&"ZOMBIE_BUTTON_TO_REVIVE_PLAYER");
	e_revivee.revivetrigger.beingrevived = 0;
	self notify("do_revive_ended_normally");
	self.is_reviving_any--;
	if(!revived)
	{
		e_revivee thread checkforbleedout(self);
	}
	return revived;
}

function checkforbleedout(player)
{
	self endon("player_revived");
	self endon("player_suicide");
	self endon("disconnect");
	player endon("disconnect");
	if(isdefined(player) && zm_utility::is_classic())
	{
		if(!isdefined(player.failed_revives))
		{
			player.failed_revives = 0;
		}
		player.failed_revives++;
		player notify("player_failed_revive");
	}
}

function auto_revive(reviver, dont_enable_weapons)
{
	if(isdefined(self.revivetrigger))
	{
		self.revivetrigger.auto_revive = 1;
		if(self.revivetrigger.beingrevived == 1)
		{
			while(true)
			{
				if(!isdefined(self.revivetrigger) || self.revivetrigger.beingrevived == 0)
				{
					break;
				}
				util::wait_network_frame();
			}
		}
		if(isdefined(self.revivetrigger))
		{
			self.revivetrigger.auto_trigger = 0;
		}
	}
	self reviveplayer();
	self zm_perks::perk_set_max_health_if_jugg("health_reboot", 1, 0);
	self clientfield::set("zmbLastStand", 0);
	self notify("stop_revive_trigger");
	if(isdefined(self.revivetrigger))
	{
		self.revivetrigger delete();
		self.revivetrigger = undefined;
	}
	self laststand::cleanup_suicide_hud();
	visionset_mgr::deactivate("visionset", "zombie_last_stand", self);
	visionset_mgr::deactivate("visionset", "zombie_death", self);
	self notify("clear_red_flashing_overlay");
	self allowjump(1);
	self util::delay(2, "death", &set_ignoreme, 0);
	self.laststand = undefined;
	if(!(isdefined(level.isresetting_grief) && level.isresetting_grief))
	{
		if(isplayer(reviver))
		{
			reviver.revives++;
			reviver zm_stats::increment_client_stat("revives");
			reviver zm_stats::increment_player_stat("revives");
			self recordplayerrevivezombies(reviver);
			demo::bookmark("zm_player_revived", gettime(), reviver, self);
		}
	}
	self notify("player_revived", reviver);
	wait(0.05);
	if(!isdefined(dont_enable_weapons) || dont_enable_weapons == 0)
	{
		self laststand_enable_player_weapons();
	}
}

function remote_revive(reviver)
{
	if(!self laststand::player_is_in_laststand())
	{
		return;
	}
	self playsound("zmb_character_remote_revived");
	self thread auto_revive(reviver);
}

function revive_success(reviver, b_track_stats = 1)
{
	if(!isplayer(self))
	{
		self notify("player_revived", reviver);
		return;
	}
	if(isdefined(b_track_stats) && b_track_stats)
	{
		demo::bookmark("zm_player_revived", gettime(), reviver, self);
	}
	self notify("player_revived", reviver);
	reviver notify("player_did_a_revive", self);
	self reviveplayer();
	self zm_perks::perk_set_max_health_if_jugg("health_reboot", 1, 0);
	if(isdefined(self.pers_upgrades_awarded["perk_lose"]) && self.pers_upgrades_awarded["perk_lose"])
	{
		self thread zm_pers_upgrades_functions::pers_upgrade_perk_lose_restore();
	}
	if(!(isdefined(level.isresetting_grief) && level.isresetting_grief) && (isdefined(b_track_stats) && b_track_stats))
	{
		reviver.revives++;
		reviver zm_stats::increment_client_stat("revives");
		reviver zm_stats::increment_player_stat("revives");
		reviver xp_revive_once_per_round(self);
		self recordplayerrevivezombies(reviver);
		reviver.upgrade_fx_origin = self.origin;
	}
	if(zm_utility::is_classic() && (isdefined(b_track_stats) && b_track_stats))
	{
		zm_pers_upgrades_functions::pers_increment_revive_stat(reviver);
	}
	if(isdefined(b_track_stats) && b_track_stats)
	{
		reviver thread check_for_sacrifice();
	}
	self clientfield::set("zmbLastStand", 0);
	self.revivetrigger delete();
	self.revivetrigger = undefined;
	self laststand::cleanup_suicide_hud();
	self util::delay(2, "death", &set_ignoreme, 0);
	visionset_mgr::deactivate("visionset", "zombie_last_stand", self);
	visionset_mgr::deactivate("visionset", "zombie_death", self);
	wait(0.05);
	self laststand_enable_player_weapons();
}

function xp_revive_once_per_round(player_being_revived)
{
	if(!isdefined(self.number_revives_per_round))
	{
		self.number_revives_per_round = [];
	}
	if(!isdefined(self.number_revives_per_round[player_being_revived.characterindex]))
	{
		self.number_revives_per_round[player_being_revived.characterindex] = 0;
	}
	if(self.number_revives_per_round[player_being_revived.characterindex] == 0)
	{
		scoreevents::processscoreevent("revive_an_ally", self);
	}
	self.number_revives_per_round[player_being_revived.characterindex]++;
}

function set_ignoreme(b_ignoreme)
{
	if(!isdefined(self.laststand_ignoreme))
	{
		self.laststand_ignoreme = 0;
	}
	if(b_ignoreme != self.laststand_ignoreme)
	{
		self.laststand_ignoreme = b_ignoreme;
		if(b_ignoreme)
		{
			self zm_utility::increment_ignoreme();
		}
		else
		{
			self zm_utility::decrement_ignoreme();
		}
	}
}

function revive_force_revive(reviver)
{
	self thread revive_success(reviver);
}

function player_getup_setup()
{
	self.laststand_info = spawnstruct();
	self.laststand_info.type_getup_lives = level.const_laststand_getup_count_start;
}

function laststand_getup()
{
	self endon("player_revived");
	self endon("disconnect");
	self laststand::update_lives_remaining(0);
	self clientfield::set("zmbLastStand", 1);
	self.laststand_info.getup_bar_value = level.const_laststand_getup_bar_start;
	self thread laststand::laststand_getup_hud();
	self thread laststand_getup_damage_watcher();
	while(self.laststand_info.getup_bar_value < 1)
	{
		self.laststand_info.getup_bar_value = self.laststand_info.getup_bar_value + level.const_laststand_getup_bar_regen;
		wait(0.05);
	}
	self auto_revive(self);
	self clientfield::set("zmbLastStand", 0);
}

function laststand_getup_damage_watcher()
{
	self endon("player_revived");
	self endon("disconnect");
	while(true)
	{
		self waittill("damage");
		self.laststand_info.getup_bar_value = self.laststand_info.getup_bar_value - level.const_laststand_getup_bar_damage;
		if(self.laststand_info.getup_bar_value < 0)
		{
			self.laststand_info.getup_bar_value = 0;
		}
	}
}

function check_for_sacrifice()
{
	self util::delay_notify("sacrifice_denied", 1);
	self endon("sacrifice_denied");
	self waittill("player_downed");
	self zm_stats::increment_client_stat("sacrifices");
	self zm_stats::increment_player_stat("sacrifices");
}

function check_for_failed_revive(e_revivee)
{
	self endon("disconnect");
	e_revivee endon("disconnect");
	e_revivee endon("player_suicide");
	self notify("checking_for_failed_revive");
	self endon("checking_for_failed_revive");
	e_revivee endon("player_revived");
	e_revivee waittill("bled_out");
	self zm_stats::increment_client_stat("failed_revives");
	self zm_stats::increment_player_stat("failed_revives");
}

function add_weighted_down()
{
	if(!level.curr_gametype_affects_rank)
	{
		return;
	}
	weighted_down = 1000;
	if(level.round_number > 0)
	{
		weighted_down = int(1000 / (ceil(level.round_number / 5)));
	}
	self addplayerstat("weighted_downs", weighted_down);
}

function register_revive_override(func_is_reviving, func_can_revive = undefined, b_use_revive_tool = 0)
{
	if(!isdefined(self.a_s_revive_overrides))
	{
		self.a_s_revive_overrides = [];
	}
	s_revive_override = spawnstruct();
	s_revive_override.func_is_reviving = func_is_reviving;
	if(isdefined(func_can_revive))
	{
		s_revive_override.func_can_revive = func_can_revive;
	}
	else
	{
		s_revive_override.func_can_revive = func_is_reviving;
	}
	s_revive_override.b_use_revive_tool = b_use_revive_tool;
	self.a_s_revive_overrides[self.a_s_revive_overrides.size] = s_revive_override;
	return s_revive_override;
}

function deregister_revive_override(s_revive_override)
{
	if(isdefined(self.a_s_revive_overrides))
	{
		arrayremovevalue(self.a_s_revive_overrides, s_revive_override);
	}
}

function can_revive_via_override(e_revivee)
{
	if(isdefined(self.a_s_revive_overrides))
	{
		for(i = 0; i < self.a_s_revive_overrides.size; i++)
		{
			if(self [[self.a_s_revive_overrides[i].func_can_revive]](e_revivee))
			{
				return true;
			}
		}
	}
	return false;
}

function is_reviving_via_override(e_revivee)
{
	if(isdefined(self.a_s_revive_overrides))
	{
		for(i = 0; i < self.a_s_revive_overrides.size; i++)
		{
			if(self [[self.a_s_revive_overrides[i].func_is_reviving]](e_revivee))
			{
				self.s_revive_override_used = self.a_s_revive_overrides[i];
				return true;
			}
		}
	}
	self.s_revive_override_used = undefined;
	return false;
}