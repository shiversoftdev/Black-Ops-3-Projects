// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\cp\_load;
#using scripts\cp\_util;
#using scripts\cp\cp_doa_bo3_fx;
#using scripts\cp\cp_doa_bo3_sound;
#using scripts\cp\doa\_doa_core;
#using scripts\cp\doa\_doa_score;
#using scripts\cp\gametypes\coop;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicles\_quadtank;

// bullshit
#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
// from zm_load
#using scripts\zm\_ambient;
#using scripts\zm\_callbacks;
//#using scripts\zm\_destructible;
#using scripts\cp\_destructible;
#using scripts\zm\_global_fx;
//#using scripts\zm\_radiant_live_update;
//#using scripts\zm\_sticky_grenade;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_magicbox;
//#using scripts\zm\_zm_playerhealth;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_traps;
//#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\gametypes\_weaponobjects;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

//#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
// #using scripts\zm\_zm_perk_additionalprimaryweapon;
// #using scripts\zm\_zm_perk_doubletap2;
// #using scripts\zm\_zm_perk_deadshot;
// #using scripts\zm\_zm_perk_juggernaut;
// #using scripts\zm\_zm_perk_quick_revive;
// #using scripts\zm\_zm_perk_sleight_of_hand;
// #using scripts\zm\_zm_perk_staminup;

//Powerups
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;

//Traps
//#using scripts\zm\_zm_trap_electric;

#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

//#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
// #using scripts\zm\_zm_perk_additionalprimaryweapon;
// #using scripts\zm\_zm_perk_doubletap2;
// #using scripts\zm\_zm_perk_deadshot;
// #using scripts\zm\_zm_perk_juggernaut;
// #using scripts\zm\_zm_perk_quick_revive;
// #using scripts\zm\_zm_perk_sleight_of_hand;
// #using scripts\zm\_zm_perk_staminup;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
#using scripts\zm\_zm_powerup_weapon_minigun;

// Weapons
// #using scripts\zm\_zm_weap_bouncingbetty;
// #using scripts\zm\_zm_weap_cymbal_monkey;
// #using scripts\zm\_zm_weap_tesla;
// #using scripts\zm\_zm_weap_rocketshield;
// #using scripts\zm\_zm_weap_gravityspikes;
// #using scripts\zm\_zm_weap_thundergun;
// #using scripts\zm\_zm_weap_octobomb;
// #using scripts\zm\_zm_weap_raygun_mark3;

// AI

#namespace namespace_bb5d050c;

function main()
{
	setdvar("doa_redins_rally", 0);
	level.var_2eda2d85 = &function_62423327;
	level.var_1f314fb9 = &function_4eb73a5;
	namespace_e8effba5::main();
	namespace_4fca3ee8::main();
	setdvar("bg_friendlyFireMode", 0);
	clientfield::register("world", "redinsExploder", 1, 2, "int", &function_1dd0a889, 0, 0);
	clientfield::register("world", "activateBanner", 1, 3, "int", &function_99e9c8d, 0, 0);
	clientfield::register("world", "pumpBannerBar", 1, 8, "float", &function_98982de8, 0, 0);
	clientfield::register("world", "redinstutorial", 1, 1, "int", &function_c7163a08, 0, 0);
	clientfield::register("world", "redinsinstruct", 1, 12, "int", &function_9cbb849c, 0, 0);
	clientfield::register("scriptmover", "runcowanim", 1, 1, "int", &function_caf96f2d, 0, 0);
	clientfield::register("scriptmover", "runsiegechickenanim", 8000, 2, "int", &function_f9064aec, 0, 0);
	namespace_693feb87::main();
	load::main();

	// bullshit
	level.zbr_is_doa = true;
	zm_usermap::_main();

	//_include_weapons();
	
	util::waitforclient( 0 );
}

function function_4eb73a5(localclientnum, mapname, var_5fb1dd3e)
{
	if(isdefined(level.weatherfx) && isdefined(level.weatherfx[localclientnum]))
	{
		stopfx(localclientnum, level.weatherfx[localclientnum]);
		level.weatherfx[localclientnum] = 0;
	}
	switch(mapname)
	{
		case "island":
		{
			break;
		}
		case "dock":
		{
			if(var_5fb1dd3e == "night")
			{
				level.weatherfx[localclientnum] = playfxoncamera(localclientnum, level._effect["ambient_rainfall_" + randomintrange(1, 4)], (0, 0, 0), (1, 0, 0), (0, 0, 1));
			}
			break;
		}
		case "farm":
		{
			if(var_5fb1dd3e == "dusk" || var_5fb1dd3e == "night")
			{
				level.weatherfx[localclientnum] = playfxoncamera(localclientnum, level._effect["ambient_snowfall_1"], (0, 0, 0), (1, 0, 0), (0, 0, 1));
			}
			break;
		}
		case "graveyard":
		{
			if(var_5fb1dd3e == "noon")
			{
				level.weatherfx[localclientnum] = playfxoncamera(localclientnum, level._effect["ambient_snowfall_1"], (0, 0, 0), (1, 0, 0), (0, 0, 1));
			}
			else if(var_5fb1dd3e == "night")
			{
				level.weatherfx[localclientnum] = playfxoncamera(localclientnum, level._effect["ambient_rainfall_" + randomintrange(1, 4)], (0, 0, 0), (1, 0, 0), (0, 0, 1));
			}
			break;
		}
		case "temple":
		{
			if(var_5fb1dd3e == "night")
			{
				level.weatherfx[localclientnum] = playfxoncamera(localclientnum, level._effect["ambient_rainfall_" + randomintrange(1, 4)], (0, 0, 0), (1, 0, 0), (0, 0, 1));
			}
			break;
		}
		case "safehouse":
		{
			break;
		}
		case "blood":
		{
			if(var_5fb1dd3e != "dusk")
			{
				level.weatherfx[localclientnum] = playfxoncamera(localclientnum, level._effect["ambient_snowfall_1"], (0, 0, 0), (1, 0, 0), (0, 0, 1));
			}
			break;
		}
		case "cave":
		{
			break;
		}
		case "vengeance":
		{
			if(var_5fb1dd3e == "night")
			{
				level.weatherfx[localclientnum] = playfxoncamera(localclientnum, level._effect["ambient_rainfall_" + randomintrange(1, 4)], (0, 0, 0), (1, 0, 0), (0, 0, 1));
			}
			break;
		}
		case "sgen":
		{
			break;
		}
		case "apartments":
		{
			if(var_5fb1dd3e == "night")
			{
				level.weatherfx[localclientnum] = playfxoncamera(localclientnum, level._effect["ambient_rainfall_" + randomintrange(1, 4)], (0, 0, 0), (1, 0, 0), (0, 0, 1));
			}
			break;
		}
		case "sector":
		{
			break;
		}
		case "metro":
		{
			if(var_5fb1dd3e == "night")
			{
				level.weatherfx[localclientnum] = playfxoncamera(localclientnum, level._effect["ambient_snowfall_1"], (0, 0, 0), (1, 0, 0), (0, 0, 1));
			}
			break;
		}
		case "clearing":
		{
			if(var_5fb1dd3e != "night")
			{
				level.weatherfx[localclientnum] = playfxoncamera(localclientnum, level._effect["ambient_snowfall_1"], (0, 0, 0), (1, 0, 0), (0, 0, 1));
			}
			break;
		}
		case "newworld":
		{
			if(var_5fb1dd3e == "dusk" || var_5fb1dd3e == "night")
			{
				level.weatherfx[localclientnum] = playfxoncamera(localclientnum, level._effect["ambient_snowfall_1"], (0, 0, 0), (1, 0, 0), (0, 0, 1));
			}
			break;
		}
		case "boss":
		{
			if(var_5fb1dd3e == "night")
			{
				level.weatherfx[localclientnum] = playfxoncamera(localclientnum, level._effect["ambient_rainfall_" + randomintrange(1, 4)], (0, 0, 0), (1, 0, 0), (0, 0, 1));
			}
			break;
		}
	}
}

function function_62423327(arena)
{
	switch(arena.name)
	{
		case "redins":
		{
			arena.var_f3114f93 = &function_787f2b69;
			arena.var_aad78940 = 99;
			arena.var_f4f1abf3 = 1;
			arena.var_dd94482c = (1 + 8) + 4;
			arena.var_ecf7ec70 = 0;
			break;
		}
		case "tankmaze":
		{
			arena.var_f3114f93 = &function_52612667;
			arena.var_aad78940 = 99;
			arena.var_dd94482c = 1 + 4;
			arena.var_ecf7ec70 = 2;
			break;
		}
		case "spiral":
		{
			arena.var_aad78940 = 2;
			arena.var_dd94482c = 1;
			arena.var_ecf7ec70 = 0;
			break;
		}
		case "truck_soccer":
		{
			arena.var_f3114f93 = &function_b5e8546d;
			arena.var_aad78940 = 99;
			arena.var_dd94482c = (1 + 8) + 4;
			arena.var_ecf7ec70 = 2;
			break;
		}
		case "alien_armory":
		case "armory":
		case "bomb_storage":
		case "coop":
		case "hangar":
		case "vault":
		case "wolfhole":
		{
			arena.var_dd94482c = 4;
			arena.var_ecf7ec70 = 2;
			break;
		}
		case "apartments":
		{
			arena.var_bfa5d6ae = 1;
			break;
		}
		default:
		{
			break;
		}
	}
}

function function_98982de8(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	setuimodelvalue(getuimodel(level.var_7e2a814c, "gpr0"), newval);
}

function function_99e9c8d(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	setuimodelvalue(createuimodel(level.var_7e2a814c, "gbanner"), "");
	switch(newval)
	{
		case 6:
		{
			setuimodelvalue(getuimodel(level.var_7e2a814c, "gbanner"), &"CP_DOA_BO3_BOSS_CYBERSILVERBACK_MECH");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "gpr0"), 1);
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb1"), "255 0 0");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb2"), "255 128 0");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb3"), "255 0 32");
			break;
		}
		case 5:
		{
			setuimodelvalue(getuimodel(level.var_7e2a814c, "gbanner"), &"CP_DOA_BO3_BOSS_CYBERSILVERBACK");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "gpr0"), 1);
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb1"), "255 0 0");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb2"), "255 128 0");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb3"), "255 0 32");
			break;
		}
		case 4:
		{
			setuimodelvalue(getuimodel(level.var_7e2a814c, "gbanner"), &"CP_DOA_BO3_BOSS_MARGWA");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "gpr0"), 1);
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb1"), "255 0 0");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb2"), "255 128 0");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb3"), "255 0 32");
			break;
		}
		case 1:
		{
			setuimodelvalue(getuimodel(level.var_7e2a814c, "gbanner"), &"CP_DOA_BO3_BOSS_STONEGUARDIAN");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "gpr0"), 1);
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb1"), "255 0 0");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb2"), "255 128 0");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb3"), "255 0 32");
			break;
		}
		case 2:
		{
			setuimodelvalue(getuimodel(level.var_7e2a814c, "gbanner"), &"CP_DOA_BO3_BANNER_CHICKENBOWL");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "gpr0"), 1);
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb1"), "128 128 128");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb2"), "255 255 255");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb3"), "128 128 128");
			break;
		}
		case 3:
		{
			setuimodelvalue(getuimodel(level.var_7e2a814c, "gbanner"), &"CP_DOA_BO3_BANNER_TANKMAZE");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "gpr0"), 1);
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb1"), "16 16 16");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb2"), "31 10 255");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "grgb3"), "255 255 0");
			break;
		}
		default:
		{
			setuimodelvalue(createuimodel(level.var_7e2a814c, "gbanner"), "");
			setuimodelvalue(getuimodel(level.var_7e2a814c, "gpr0"), 0);
			break;
		}
	}
}

function function_b5e8546d(localclientnum)
{
	level.var_81528e19 = 2;
	setuimodelvalue(createuimodel(level.var_7e2a814c, "driving"), 1);
	level thread function_caffcc1d(localclientnum);
}

function function_caffcc1d(localclientnum)
{
	level waittill(#"hash_ec7ca67b");
	level.var_81528e19 = undefined;
	setuimodelvalue(createuimodel(level.var_7e2a814c, "driving"), 0);
}

function function_c8020bd9(localclientnum)
{
	level waittill(#"hash_ec7ca67b");
	level.var_81528e19 = undefined;
	setuimodelvalue(createuimodel(level.var_7e2a814c, "redins"), "");
	setuimodelvalue(createuimodel(level.var_7e2a814c, "gtxt0"), "");
	setuimodelvalue(createuimodel(level.var_7e2a814c, "gpr0"), 0);
	setuimodelvalue(createuimodel(level.var_7e2a814c, "gpr1"), 0);
	setuimodelvalue(createuimodel(level.var_7e2a814c, "gpr2"), 0);
	setuimodelvalue(createuimodel(level.var_7e2a814c, "gpr3"), 0);
	foreach(player in getplayers(localclientnum))
	{
		setuimodelvalue(getuimodel(level.var_b9d30140[player getentitynumber()], "generic_txt"), "");
	}
	setdvar("doa_redins_rally", 0);
	setuimodelvalue(createuimodel(level.var_7e2a814c, "driving"), 0);
}

function function_7183a31d(fieldname, diff)
{
	level notify(#"hash_7183a31d");
	level endon(#"hash_7183a31d");
	setuimodelvalue(createuimodel(level.var_7e2a814c, "gtxt0"), ("+") + diff);
	wait(2);
	setuimodelvalue(createuimodel(level.var_7e2a814c, "gtxt0"), "");
}

function function_ec984567()
{
	level endon(#"hash_ec7ca67b");
	while(true)
	{
		level waittill(#"hash_48152b36", fieldname, diff);
		if(diff > 0)
		{
			level thread function_7183a31d(fieldname, diff);
		}
	}
}

function function_1dd0a889(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	switch(newval)
	{
		case 0:
		{
			exploder::kill_exploder("fx_exploder_rally_ramp_fireworks");
			exploder::kill_exploder("fx_exploder_rally_winner_fireworks");
			break;
		}
		case 1:
		{
			exploder::exploder("fx_exploder_rally_ramp_fireworks");
			break;
		}
		case 2:
		{
			exploder::exploder("fx_exploder_rally_winner_fireworks");
			break;
		}
	}
}

function function_9cbb849c(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval)
	{
		var_a923fad3 = newval & 15;
		seconds = newval >> 4;
		text = sprintf(&"CP_DOA_BO3_REDINS_INSTRUCTION", var_a923fad3, seconds);
		setuimodelvalue(createuimodel(level.var_7e2a814c, "instruct"), text);
	}
	else
	{
		setuimodelvalue(createuimodel(level.var_7e2a814c, "instruct"), "");
	}
}

function function_c7163a08(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval == 1 && (!(isdefined(level.var_f64ff200) && level.var_f64ff200)))
	{
		if(!isdefined(level.var_8c2ba713))
		{
			level.var_8c2ba713 = createluimenu(localclientnum, "DOA_ControlsMenu");
		}
		if(isdefined(level.var_8c2ba713))
		{
			openluimenu(localclientnum, level.var_8c2ba713);
			level.var_f64ff200 = 1;
			string = "CP_DOA_BO3_REDINS_HINT" + randomint(8);
			setuimodelvalue(createuimodel(level.var_7e2a814c, "hint"), istring(string));
			while(true)
			{
				level waittill("countdown", val);
				if(val <= 1)
				{
					break;
				}
			}
			closeluimenu(localclientnum, level.var_8c2ba713);
			level.var_8c2ba713 = undefined;
			level.var_f64ff200 = undefined;
		}
	}
}

function function_96abee17(localclientnum)
{
	level waittill(#"hash_ec7ca67b");
	level.var_81528e19 = undefined;
}

function function_52612667(localclientnum)
{
	level endon(#"hash_ec7ca67b");
	if(isdefined(level.weatherfx) && isdefined(level.weatherfx[localclientnum]))
	{
		stopfx(localclientnum, level.weatherfx[localclientnum]);
		level.weatherfx[localclientnum] = 0;
	}
	level.var_81528e19 = 2;
	level thread function_96abee17(localclientnum);
}

function function_787f2b69(localclientnum)
{
	level endon(#"hash_ec7ca67b");
	if(isdefined(level.weatherfx) && isdefined(level.weatherfx[localclientnum]))
	{
		stopfx(localclientnum, level.weatherfx[localclientnum]);
		level.weatherfx[localclientnum] = 0;
	}
	level.var_81528e19 = 2;
	level thread function_c8020bd9(localclientnum);
	setuimodelvalue(getuimodel(level.var_7e2a814c, "redins"), "1");
	setuimodelvalue(createuimodel(level.var_7e2a814c, "driving"), 1);
	setdvar("doa_redins_rally", 1);
	level thread function_ec984567();
	while(true)
	{
		for(i = 0; i < 4; i++)
		{
			setuimodelvalue(getuimodel(level.var_b9d30140[i], "name"), "");
			setuimodelvalue(getuimodel(level.var_b9d30140[i], "generic_txt"), "");
		}
		foreach(player in getplayers(localclientnum))
		{
			setuimodelvalue(getuimodel(level.var_b9d30140[player getentitynumber()], "name"), "");
			setuimodelvalue(getuimodel(level.var_b9d30140[player getentitynumber()], "generic_txt"), (isdefined(player.name) ? player.name : ""));
			switch(player getentitynumber())
			{
				case 0:
				{
					rgb = "0 255 0";
					break;
				}
				case 1:
				{
					rgb = "0 0 255";
					break;
				}
				case 2:
				{
					rgb = "255 0 0";
					break;
				}
				case 3:
				{
					rgb = "255 255 0";
					break;
				}
			}
			setuimodelvalue(getuimodel(level.var_b9d30140[player getentitynumber()], "gpr_rgb"), rgb);
		}
		wait(0.1);
	}
}

#using_animtree("critter");
function function_a8eb710()
{
	self endon("entityshutdown");
	self useanimtree(#animtree);
	self.animation = (randomint(2) ? %a_water_buffalo_run_a : %a_water_buffalo_run_b);
	self setanim(self.animation, 1, 0, 1);
}

function function_caf96f2d(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	if(newval)
	{
		self thread function_a8eb710();
	}
}

#using_animtree("chicken_mech");
function function_27542390(localclientnum, state)
{
	self endon("entityshutdown");
	self notify("animstate");
	self endon("animstate");
	self.animstate = state;
	self useanimtree(#animtree);
	while(true)
	{
		switch(self.animstate)
		{
			case 0:
			{
				if(isdefined(self.animation))
				{
					self clearanim(self.animation, 0);
					self.animation = undefined;
				}
				break;
			}
			case 1:
			{
				self.animation = %a_chicken_mech_idle;
				self setanim(self.animation, 1, 0.2, 1);
				break;
			}
			case 2:
			{
				self.animation = %a_chicken_mech_lay_egg;
				self setanimrestart(self.animation, 1, 0.2, 1);
				break;
			}
			case 3:
			{
				break;
			}
		}
		if(isdefined(self.animation))
		{
			time = getanimlength(self.animation);
			wait(time);
		}
		else
		{
			return;
		}
	}
}

function function_f9064aec(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	self thread function_27542390(localclientnum, newval);
}

// bullshit

#namespace zm_usermap; 

// #precache( "client_fx", "zombie/fx_glow_eye_orange" );
// #precache( "client_fx", "zombie/fx_bul_flesh_head_fatal_zmb" );
// #precache( "client_fx", "zombie/fx_bul_flesh_head_nochunks_zmb" );
// #precache( "client_fx", "zombie/fx_bul_flesh_neck_spurt_zmb" );
// #precache( "client_fx", "zombie/fx_blood_torso_explo_zmb" );
// #precache( "client_fx", "trail/fx_trail_blood_streak" );
// #precache( "client_fx", "dlc0/factory/fx_snow_player_os_factory" );

function autoexec opt_in()
{
	DEFAULT(level.aat_in_use,true);
	DEFAULT(level.bgb_in_use,true);
}

function _main()
{
	// custom client side exert sounds for the special characters
	//level.setupCustomCharacterExerts = &setup_personality_character_exerts;
	
	level._effect["eye_glow"]				= "zombie/fx_glow_eye_orange";
	level._effect["headshot"]				= "zombie/fx_bul_flesh_head_fatal_zmb";
	level._effect["headshot_nochunks"]		= "zombie/fx_bul_flesh_head_nochunks_zmb";
	level._effect["bloodspurt"]				= "zombie/fx_bul_flesh_neck_spurt_zmb";

	level._effect["animscript_gib_fx"]		= "zombie/fx_blood_torso_explo_zmb"; 
	level._effect["animscript_gibtrail_fx"]	= "trail/fx_trail_blood_streak"; 	

	//If enabled then the zombies will get a keyline round them so we can see them through walls
	level.debug_keyline_zombies = false;

	//include_weapons();
	include_perks();

	//load::main();
	
	//_zm_weap_cymbal_monkey::init();
	//_zm_weap_tesla::init();
	
}

function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

#define JUGGERNAUT_MACHINE_LIGHT_FX				"jugger_light"		
#define QUICK_REVIVE_MACHINE_LIGHT_FX			"revive_light"		
#define STAMINUP_MACHINE_LIGHT_FX				"marathon_light"	
#define WIDOWS_WINE_FX_MACHINE_LIGHT				"widow_light"
#define SLEIGHT_OF_HAND_MACHINE_LIGHT_FX				"sleight_light"		
#define DOUBLETAP2_MACHINE_LIGHT_FX				"doubletap2_light"		
#define DEADSHOT_MACHINE_LIGHT_FX				"deadshot_light"		
#define ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX					"additionalprimaryweapon_light"

function include_perks()
{
	level._effect[JUGGERNAUT_MACHINE_LIGHT_FX] = "zombie/fx_perk_juggernaut_factory_zmb";
	level._effect[QUICK_REVIVE_MACHINE_LIGHT_FX] = "zombie/fx_perk_quick_revive_factory_zmb";
	level._effect[SLEIGHT_OF_HAND_MACHINE_LIGHT_FX] = "zombie/fx_perk_sleight_of_hand_factory_zmb";
	level._effect[DOUBLETAP2_MACHINE_LIGHT_FX] = "zombie/fx_perk_doubletap2_factory_zmb";
	level._effect[DEADSHOT_MACHINE_LIGHT_FX] = "zombie/fx_perk_daiquiri_factory_zmb";
	level._effect[STAMINUP_MACHINE_LIGHT_FX] = "zombie/fx_perk_stamin_up_factory_zmb";
	level._effect[ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX] = "zombie/fx_perk_mule_kick_factory_zmb";	
}

function setup_personality_character_exerts()
{
	// falling damage
	level.exert_sounds[1]["falldamage"][0] = "vox_plr_0_exert_pain_0";
	level.exert_sounds[1]["falldamage"][1] = "vox_plr_0_exert_pain_1";
	level.exert_sounds[1]["falldamage"][2] = "vox_plr_0_exert_pain_2";
	level.exert_sounds[1]["falldamage"][3] = "vox_plr_0_exert_pain_3";
	level.exert_sounds[1]["falldamage"][4] = "vox_plr_0_exert_pain_4";
	
	level.exert_sounds[2]["falldamage"][0] = "vox_plr_1_exert_pain_0";
	level.exert_sounds[2]["falldamage"][1] = "vox_plr_1_exert_pain_1";
	level.exert_sounds[2]["falldamage"][2] = "vox_plr_1_exert_pain_2";
	level.exert_sounds[2]["falldamage"][3] = "vox_plr_1_exert_pain_3";
	level.exert_sounds[2]["falldamage"][4] = "vox_plr_1_exert_pain_4";
	
	level.exert_sounds[3]["falldamage"][0] = "vox_plr_2_exert_pain_0";
	level.exert_sounds[3]["falldamage"][1] = "vox_plr_2_exert_pain_1";
	level.exert_sounds[3]["falldamage"][2] = "vox_plr_2_exert_pain_2";
	level.exert_sounds[3]["falldamage"][3] = "vox_plr_2_exert_pain_3";
	level.exert_sounds[3]["falldamage"][4] = "vox_plr_2_exert_pain_4";
	
	level.exert_sounds[4]["falldamage"][0] = "vox_plr_3_exert_pain_0";
	level.exert_sounds[4]["falldamage"][1] = "vox_plr_3_exert_pain_1";
	level.exert_sounds[4]["falldamage"][2] = "vox_plr_3_exert_pain_2";
	level.exert_sounds[4]["falldamage"][3] = "vox_plr_3_exert_pain_3";
	level.exert_sounds[4]["falldamage"][4] = "vox_plr_3_exert_pain_4";
	
	// melee swipe
	level.exert_sounds[1]["meleeswipesoundplayer"][0] = "vox_plr_0_exert_melee_0";
	level.exert_sounds[1]["meleeswipesoundplayer"][1] = "vox_plr_0_exert_melee_1";
	level.exert_sounds[1]["meleeswipesoundplayer"][2] = "vox_plr_0_exert_melee_2";
	level.exert_sounds[1]["meleeswipesoundplayer"][3] = "vox_plr_0_exert_melee_3";
	level.exert_sounds[1]["meleeswipesoundplayer"][4] = "vox_plr_0_exert_melee_4";
	
	level.exert_sounds[2]["meleeswipesoundplayer"][0] = "vox_plr_1_exert_melee_0";
	level.exert_sounds[2]["meleeswipesoundplayer"][1] = "vox_plr_1_exert_melee_1";
	level.exert_sounds[2]["meleeswipesoundplayer"][2] = "vox_plr_1_exert_melee_2";
	level.exert_sounds[2]["meleeswipesoundplayer"][3] = "vox_plr_1_exert_melee_3";
	level.exert_sounds[2]["meleeswipesoundplayer"][4] = "vox_plr_1_exert_melee_4";
	
	level.exert_sounds[3]["meleeswipesoundplayer"][0] = "vox_plr_2_exert_melee_0";
	level.exert_sounds[3]["meleeswipesoundplayer"][1] = "vox_plr_2_exert_melee_1";
	level.exert_sounds[3]["meleeswipesoundplayer"][2] = "vox_plr_2_exert_melee_2";
	level.exert_sounds[3]["meleeswipesoundplayer"][3] = "vox_plr_2_exert_melee_3";
	level.exert_sounds[3]["meleeswipesoundplayer"][4] = "vox_plr_2_exert_melee_4";	
	
	level.exert_sounds[4]["meleeswipesoundplayer"][0] = "vox_plr_3_exert_melee_0";
	level.exert_sounds[4]["meleeswipesoundplayer"][1] = "vox_plr_3_exert_melee_1";
	level.exert_sounds[4]["meleeswipesoundplayer"][2] = "vox_plr_3_exert_melee_2";
	level.exert_sounds[4]["meleeswipesoundplayer"][3] = "vox_plr_3_exert_melee_3";
	level.exert_sounds[4]["meleeswipesoundplayer"][4] = "vox_plr_3_exert_melee_4";	
}