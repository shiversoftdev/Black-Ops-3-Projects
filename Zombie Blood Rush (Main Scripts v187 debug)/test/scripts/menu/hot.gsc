#include scripts\codescripts\struct;
#include scripts\shared\callbacks_shared;
#include scripts\shared\clientfield_shared;
#include scripts\shared\math_shared;
#include scripts\shared\system_shared;
#include scripts\shared\util_shared;
// #include scripts\shared\hud_util_shared;
// #include scripts\shared\hud_message_shared;
// #include scripts\shared\hud_shared;
#include scripts\shared\array_shared;
// #include scripts\zm\_zm_weapons;
// #include scripts\zm\_zm_utility;
#include scripts\shared\visionset_mgr_shared;

#namespace serious;

// you need this because this operates like a regular autoexec. If you dont thread your function call its going to pause the vm till it exits which is no good.
autoexec hotload_enter() { self thread main(); }

// level.weapon_scalars_table["pistol_burst"] = 1;

main()
{
    wait 0.05;
	level notify("main_hotload");
    level endon("main_hotload");
	// level.player_out_of_playable_area_monitor = 0;

	// level.weapon_scalars_table["sniper_fastbolt_upgraded"] = 2.5;
	// foreach(player in getplayers())
	// {
	// 	// player.score = 1;
	// 	// player.health = 1;
	// 	// player.bgb = undefined;
	// }
	// setdvar("g_speed", 600);
	//level.players[2] thread magicthread();

	// foreach(spawner in level.zombie_spawners)
	// {
	// 	mdl = spawn("script_model", spawner.origin);
	// 	mdl setmodel("defaultactor");
	// }
	// closest = array::get_all_closest(level.players[0].origin, level.zombie_spawners)[0];
	// level.players[0] notify("stop_player_out_of_playable_area_monitor");
	// level.players[0] setorigin(closest.origin);
	// level.players[0] EnableInvulnerability();
	// level.players[0] PlayerLinkTo(closest);

	// level.players[0] Unlink();
	// level.players[0] setplayergravity(0);
	// // setdvar("g_speed", "600");
	// setdvar("sv_cheats", "1");
	
	// foreach(player in getplayers())
	// {
	// 	player thread magicthread();
	// }
	// setdvar("player_sustainammo", "1");
	// setdvar("g_speed", "700");
	// setdvar("bg_gravity", "200");
	// for(;;)
	// {
	// 	foreach(player in getplayers())
	// 	{
	// 		player.bgb = undefined;
	// 	}
	// 	wait 0.05;
	// }

	// foreach(player in getplayers())
	// {
	// 	// player thread [[ function() => 
	// 	// {	
	// 	// 	for(;;)
	// 	// 	{
	// 	// 		self.ignoreme = 1;
	// 	// 		wait 1;
	// 	// 	}
	// 	// }]]();
	// 	// player thread magicthread();
	// 	if(!(player ishost()))
	// 	{
	// 		player dodamage(player.health, player.origin, undefined);
	// 	}
	// }

	//level.players[0] enableInvulnerability();

	// level.players[0].var_b74a3cd1["level"] = 1000;
	// level.players[0].var_b74a3cd1["prestige"] = 20;
	// level.players[0].pers["highest_total_xpm"] = 0x7FFFFFFF;
	// level.players[0].pers["total_rounds"] = 0x7FFFFFFF;
	// level.players[0].var_9ee9bcc6 = 0x7FFFFFFF;
	// level.players[0].pers["score"] = 0x7FFFFFFF;
	// level.players[0].score = 0x7FFFFFFF;
	// function_7e18304e("spx_end_game_save_data", "end_game_prestige_gained", 20, 1);
	// function_7e18304e("spx_end_game_save_data", "end_game_prestige", 20, 1);
	// function_7e18304e("spx_end_game_save_data", "end_game_level", 9000, 1);
	// level.players[0] luinotifyevent(&"spx_save_data", 2, level.var_ac46587c["savedata"], 1);
	// level.players[0] luinotifyevent(&"spx_end_game_save_data", 2, level.var_5e620cb1["end_game_savedata"], 1);
	// level.players[0] luinotifyevent(&"spx_weapon_save_data", 2, int(level.var_e2a6fd15["savedata"]), 1);
	// self waittill(#"hash_79ef118b", type, amount);

	// machines = getentarray("vending_doubletap", "targetname");
	// level.players[0] iPrintLnBold(machines.size);
	// foreach(player in getplayers())
	// {
	// 	if(isSubStr(player.name, "fss"))
	// 	{
	// 		while(1)
	// 		{
	// 			player setorigin((randomint(10000), randomint(10000), randomint(10000)));
	// 			wait 15;
	// 		}
			
	// 	}
	// }
	// level.players[0] giveWeapon(getweapon("contact_grenade"));
	// level.players[0] giveMaxAmmo(getweapon("contact_grenade"));
	// level.players[0] TakeWeapon(getweapon("contact_grenade"));
	// // level.players[0] TakeWeapon(getweapon("frag_grenade"));
	// level.players[0] zm_utility::set_player_tactical_grenade(level.weaponNone);
	// wait 2;
	// level.players[0] giveweapon(getweapon("contact_grenade"));
	// level.players[0] zm_utility::set_player_tactical_grenade(getweapon("contact_grenade"));
	// level.players[0] giveMaxAmmo(getweapon("contact_grenade"));
	// foreach(player in getplayers())
	// {
	// 	// player TakeWeapon(player zm_utility::get_player_tactical_grenade());
	// 	// player zm_utility::set_player_tactical_grenade(level.weaponNone);
	// 	// wait 2;
	// 	// player giveweapon(getweapon("contact_grenade"));
	// 	// player zm_utility::set_player_tactical_grenade(getweapon("contact_grenade"));
	// 	// player giveMaxAmmo(getweapon("contact_grenade"));
	// 	player.score = 50000;
	// }

	// level.weapon_scalars_table["t9_pistol_semiauto"] = 0.9;
	// level.weapon_scalars_table["t9_pistol_semiauto_up"] = 0.9;
	//setdvar("zbr_tournament_series", "2023i");
	// level.players[0] dodamage(40000, level.players[0].origin);
	// level.players[0].zbr_lock_style = false;
	// level.players[0] setcharacterbodytype(7);
	// level.players[0] setcharacterbodystyle(0);
	// level.players[0] setcharacterhelmetstyle(0);
	// setdvar("g_ai", 0);
	// foreach(player in getplayers())
	// {
	// 	if(player istestclient())
	// 	{
	// 		player.zbr_lock_style = false;
	// 		player takeAllWeapons();
	// 		player setcharacterbodytype(9);
	// 		player setcharacterbodystyle(0);
	// 		player setcharacterhelmetstyle(0);
	// 		wep = getweapon("zombie_knuckle_crack");
	// 		player freezeControls(false);
	// 		player giveweapon(wep);
	// 		player switchtoweapon(wep);
	// 		//player thread freeze_after(2);
	// 		player thread jumpforme();
	// 	}
	// 	// if(player ishost())
	// 	// {
	// 	// 	wep = getweapon("zombie_knuckle_crack");
	// 	// 	player giveweapon(wep);
	// 	// 	player switchtoweapon(wep);
	// 	// 	mdl = spawn("script_model", player.origin);
	// 	// 	mdl setModel("defaultactor");
	// 	// 	mdl setscale(0.2);
	// 	// 	mdl LinkTo(player, "j_boobs", (0, 0, 0), (0, 0, 0));
	// 	// 	mdl = spawn("script_model", player.origin);
	// 	// 	mdl setModel("defaultactor");
	// 	// 	mdl setscale(0.2);
	// 	// 	mdl LinkTo(player, "j_boobs_tip", (0, 0, 0), (0, 0, 0));
	// 	// }
	// }
	// level.zbr_post_loadout = function() =>
    // {
    //     takeaway = [];
    //     foreach(weapon in self getWeaponsListPrimaries())
    //     {
    //         if(!IsInArray(level.zbr_highs_lows_valid, zm_weapons::get_base_weapon(weapon).rootweapon.name))
    //         {
    //             takeaway[takeaway.size] = weapon;
    //         }
    //     }

    //     foreach(weapon in takeaway)
    //     {
    //         self takeWeapon(weapon);
    //     }

    //     if((self getWeaponsListPrimaries()).size < 1)
    //     {
    //         self giveweapon(getweapon("t9_smg_standard"));
    //         self switchtoweapon(getweapon("t9_smg_standard"));
    //         self giveMaxAmmo(getweapon("t9_smg_standard"));
    //     }
    // };

	// zomb = zombie_utility::spawn_zombie(level.zombie_spawners[0], undefined);
	// iPrintLnBold(isdefined(zomb));
	// zomb ForceTeleport(level.players[0].origin, (0,0,0), true, true);

	//thread zm_perks::perk_machine_spawn_init();

	// pap_spot = (-4.8, 1028.8, 151.99);

    // foreach(pap in GetEntArray("pack_a_punch", "script_noteworthy"))
    // {
    //     if(!isdefined(pap.target))
    //         continue;
        
    //     ent = GetEnt(pap.target, "targetname");

    //     if(!isdefined(ent))
    //         continue;

    //     ent.origin = pap_spot;
    //     pap.origin = pap_spot;
    // }
    
    // foreach(pap in GetEntArray("specialty_weapupgrade", "script_noteworthy"))
    // {
    //     if(!isdefined(pap.target))
    //         continue;
        
    //     ent = GetEnt(pap.target, "targetname");

    //     if(!isdefined(ent))
    //         continue;

    //     ent.origin = pap_spot;
    //     pap.origin = pap_spot;
    // }

	// visionsetnaked("zm_zbr_frontend", 0);
	// level.xcam_origin = (-4325.3, 2021.68, 25);
	// level.xcam_angles = (-30, 125 + 96.7579, 42);
	// getplayers()[0] resetfov();
	
	//siPrintLnBold(level.zbr_frontend_characters[0].charactermodel.origin);
	//iPrintLnBold(isdefined(level.zbr_frontend_characters[0].charactermodel));
	// level.zbr_frontend_characters[0].origin = (-4345.3, 2101.68, 33);
	// level.zbr_frontend_characters[0].angles = (0, -90, 0);
	// level.zbr_frontend_characters[0].customization.charactertype = 9;
	// level.zbr_frontend_characters[0].customization.body.selectedindex = 2;
	// level.zbr_frontend_characters[0].customization.anim_name = "pb_cac_brass_knuckles_showcase";
	// level.zbr_frontend_characters[0].customization.showcaseweapon.weaponname = "melee_knuckles_mp";
	// level.zbr_frontend_characters[0].charactermodel.origin = level.zbr_frontend_characters[0].origin;
	// level.zbr_frontend_characters[0].charactermodel.angles = level.zbr_frontend_characters[0].angles;
	//test_fe_ch();

	// if(isdefined(level.zbr_frontend_characters[0].spotlight))
	// {
	// 	KillFX(0, level.zbr_frontend_characters[0].spotlight);
	// }

	// if(isdefined(level.zbr_frontend_characters[0].spotlight2))
	// {
	// 	KillFX(0, level.zbr_frontend_characters[0].spotlight2);
	// }

	// if(isdefined(level.zbr_frontend_characters[0].testmodel))
	// {
	// 	level.zbr_frontend_characters[0].testmodel delete();
	// }

	// level.zbr_frontend_characters[0].spotlight = playfx(0, "light/fx_light_spot_zbr", level.zbr_frontend_characters[0].origin + (-15, -65, 50), level.zbr_frontend_characters[0].angles + (0, 0, 0));
	// level.zbr_frontend_characters[0].spotlight2 = playfx(0, "light/fx_light_spot_zbr", level.zbr_frontend_characters[0].origin + (15, -35, 80), level.zbr_frontend_characters[0].angles + (0, 0, 0));
	//level.zbr_frontend_characters[0].charactermodel show();

	// place = (-4385.3, 2125.68, 33); // +y = move back, +x = move left
	// face = (0, -70, 0);
	// scale = 0.85;
	// if(level.zbr_frontend_characters.size < 2)
	// {
	// 	[[ level.debug_frontend_create_character ]](1, place, face);
	// 	level.zbr_frontend_characters[1].charactermodel setscale(scale);
	// 	level.zbr_frontend_characters[1] thread core_frontend_fx::render_frontend_character();
	// }
	// else
	// {
	// 	level.zbr_frontend_characters[1].charactermodel.origin = place;
	// 	level.zbr_frontend_characters[1].charactermodel.angles = face;
	// 	level.zbr_frontend_characters[1].origin = place;
	// 	level.zbr_frontend_characters[1].angles = face;
	// 	level.zbr_frontend_characters[1].charactermodel setscale(scale);
	// 	level.zbr_frontend_characters[1] thread core_frontend_fx::render_frontend_character();
	// }

	// place = (-4325.3, 2131.68, 33); // +y = move back, +x = move left
	// face = (0, -90, 0);
	// scale = 0.85;
	// if(level.zbr_frontend_characters.size < 3)
	// {
	// 	[[ level.debug_frontend_create_character ]](2, place, face);
	// 	level.zbr_frontend_characters[2].charactermodel setscale(scale);
	// 	level.zbr_frontend_characters[2] thread core_frontend_fx::render_frontend_character();
	// }
	// else
	// {
	// 	level.zbr_frontend_characters[2].charactermodel.origin = place;
	// 	level.zbr_frontend_characters[2].charactermodel.angles = face;
	// 	level.zbr_frontend_characters[2].origin = place;
	// 	level.zbr_frontend_characters[2].angles = face;
	// 	level.zbr_frontend_characters[2].charactermodel setscale(scale);
	// 	level.zbr_frontend_characters[2] thread core_frontend_fx::render_frontend_character();
	// }

	// place = (-4307.3, 2095, 33); // +y = move back, +x = move left
	// face = (0, -100, 0);
	// scale = 0.60;
	// if(level.zbr_frontend_characters.size < 4)
	// {
	// 	[[ level.debug_frontend_create_character ]](3, place, face);
	// 	level.zbr_frontend_characters[3].charactermodel setscale(scale);
	// 	level.zbr_frontend_characters[3] thread core_frontend_fx::render_frontend_character();
	// }
	// else
	// {
	// 	level.zbr_frontend_characters[3].charactermodel.origin = place;
	// 	level.zbr_frontend_characters[3].charactermodel.angles = face;
	// 	level.zbr_frontend_characters[3].origin = place;
	// 	level.zbr_frontend_characters[3].angles = face;
	// 	level.zbr_frontend_characters[3].charactermodel setscale(scale);
	// 	level.zbr_frontend_characters[3] thread core_frontend_fx::render_frontend_character();
	// }

	// place = (-4385.3, 2090, 33); // +y = move back, +x = move left
	// face = (0, -55, 0);
	// scale = 0.6;
	// if(level.zbr_frontend_characters.size < 5)
	// {
	// 	[[ level.debug_frontend_create_character ]](4, place, face);
	// 	level.zbr_frontend_characters[4] thread core_frontend_fx::render_frontend_character();
	// 	level.zbr_frontend_characters[4].charactermodel setscale(scale);
	// }
	// else
	// {
	// 	level.zbr_frontend_characters[4].charactermodel.origin = place;
	// 	level.zbr_frontend_characters[4].charactermodel.angles = face;
	// 	level.zbr_frontend_characters[4].origin = place;
	// 	level.zbr_frontend_characters[4].angles = face;
	// 	level.zbr_frontend_characters[4].charactermodel setscale(scale);
	// 	level.zbr_frontend_characters[4] thread core_frontend_fx::render_frontend_character();
	// }

	// place = (-4323.3, 2075, 33); // +y = move back, +x = move left
	// face = (0, -95, 0);
	// scale = 0.45;
	// if(level.zbr_frontend_characters.size < 6)
	// {
	// 	[[ level.debug_frontend_create_character ]](5, place, face);
	// 	level.zbr_frontend_characters[5] thread core_frontend_fx::render_frontend_character();
	// 	level.zbr_frontend_characters[5].charactermodel setscale(scale);
	// }
	// else
	// {
	// 	level.zbr_frontend_characters[5].charactermodel.origin = place;
	// 	level.zbr_frontend_characters[5].charactermodel.angles = face;
	// 	level.zbr_frontend_characters[5].origin = place;
	// 	level.zbr_frontend_characters[5].angles = face;
	// 	level.zbr_frontend_characters[5].charactermodel setscale(scale);
	// 	level.zbr_frontend_characters[5] thread core_frontend_fx::render_frontend_character();
	// }

	// place = (-4356.3, 2075, 33); // +y = move back, +x = move left
	// face = (0, -65, 0);
	// scale = 0.45;
	// if(level.zbr_frontend_characters.size < 7)
	// {
	// 	[[ level.debug_frontend_create_character ]](6, place, face);
	// 	level.zbr_frontend_characters[6] thread core_frontend_fx::render_frontend_character();
	// 	level.zbr_frontend_characters[6].charactermodel setscale(scale);
	// }
	// else
	// {
	// 	level.zbr_frontend_characters[6].charactermodel.origin = place;
	// 	level.zbr_frontend_characters[6].charactermodel.angles = face;
	// 	level.zbr_frontend_characters[6].origin = place;
	// 	level.zbr_frontend_characters[6].angles = face;
	// 	level.zbr_frontend_characters[6].charactermodel setscale(scale);
	// 	level.zbr_frontend_characters[6] thread core_frontend_fx::render_frontend_character();
	// }

	// place = (-4337.3, 2068.68, 33); // +y = move back, +x = move left
	// face = (0, -90, 0);
	// scale = 0.35;
	// if(level.zbr_frontend_characters.size < 8)
	// {
	// 	[[ level.debug_frontend_create_character ]](7, place, face);
	// 	level.zbr_frontend_characters[7] thread core_frontend_fx::render_frontend_character();
	// 	level.zbr_frontend_characters[7].charactermodel setscale(scale);
	// }
	// else
	// {
	// 	level.zbr_frontend_characters[7].charactermodel.origin = place;
	// 	level.zbr_frontend_characters[7].charactermodel.angles = face;
	// 	level.zbr_frontend_characters[7].origin = place;
	// 	level.zbr_frontend_characters[7].angles = face;
	// 	level.zbr_frontend_characters[7].charactermodel setscale(scale);
	// 	level.zbr_frontend_characters[7] thread core_frontend_fx::render_frontend_character();
	// }
	

	// level.zbr_frontend_characters[0].charactermodel show();
	//model = getcharacterbodymodel(1, 0, 0);
	// level.zbr_frontend_characters[0].charactermodel setmodel(model);
	//iPrintLnBold(model);
	//emote_local_player();
	// foreach(player in getplayers())
	// {
	// 	player thread magicthread();
	// }
	// callback::on_spawned(serious::magicthread);

	level.zbr_cosmetic_hats[3].scale = 0.65;
	level.zbr_cosmetic_hats[3].offset = (2.35, 0, 0); // up/down, forward/back, left/right
}

#include scripts\core\core_frontend_fx;

function emote_local_player()
{
	data_struct = level.zbr_frontend_characters[0];

	param1 = "t7_loot_gesture_goodgame_but_that_flip_though";
	data_struct.currentanimation = param1;
	//end_game_taunts::previewgesture(0, data_struct.charactermodel, data_struct.customization.anim_name, param1);
	//data_struct render_frontend_character();
}

// #include scripts\core\core_frontend_fx;
// #include scripts\shared\end_game_taunts;
test_fe_ch()
{
	//level.zbr_frontend_characters[0] core_frontend_fx::render_frontend_character();
}

// mp_register_perk(specialty, model, origin, angles)
// {
//     stru = spawnStruct();
//     stru.script_noteworthy = specialty;
//     stru.targetname = "zm_perk_machine";
//     stru.script_string = "zclassic_perks_start_room";
//     stru.model = model;
//     stru.origin = origin;
//     stru.angles = angles;
//     struct::createstruct(stru);
// }

// #include scripts\shared\ai\zombie_utility;
// #include scripts\zm\_zm_perks;

#define VTYPE_BOOL = 0;
#define VTYPE_INT = 1;
#define VTYPE_FLOAT = 2;
#define VTYPE_VECTOR = 3;
#define VTYPE_STRING = 4;

// function autoexec forfuckssake()
// {
// 	register_cmd("doballs", VTYPE_BOOL, function(oldval, newval) => 
// 	{
// 		// do something based on the old and new vals
// 	});

// 	thread do_commands();
// }

// function do_commands()
// {
// 	level.example_cmds ??= [];
// 	for(;;)
// 	{
// 		foreach(dvar, cmdef in level.example_cmds)
// 		{
// 			cval = getdvarvaluedynamic(dvar, cmdef.type);
// 			if(cmdef.value == cval)
// 			{
// 				continue;
// 			}
// 			thread [[ cmdef.cb_changed ]](cmdef.value, cval);
// 			cmdef.value = cval;
// 		}
// 		wait 0.05;
// 	}
// }

// function getdvarvaluedynamic(dvar, valtype)
// {
// 	switch(valtype)
// 	{
// 		case VTYPE_BOOL:
// 			return !!(getDvarInt(dvar, 0) ?? 0);
// 		case VTYPE_INT:
// 			return getDvarInt(dvar, 0) ?? 0;
// 		case VTYPE_FLOAT:
// 			return getDvarFloat(dvar, 0) ?? 0;
// 		case VTYPE_VECTOR:
// 			return GetDvarVector(dvar, (0, 0, 0)) ?? (0, 0, 0);
// 	}
// 	return GetDvarString(dvar, "") ?? "";
// }

// function register_cmd(dvar = "", valtype, cb_changed)
// {
// 	if(dvar is not string)
// 	{
// 		return;
// 	}

// 	if(valtype is not int or valtype < VTYPE_BOOL or valtype > VTYPE_STRING)
// 	{
// 		valtype = VTYPE_STRING;
// 	}

// 	if(cb_changed is not function and cb_changed is defined)
// 	{
// 		return;
// 	}

// 	level.example_cmds ??= [];
// 	level.example_cmds[dvar] ??= spawnstruct();
// 	level.example_cmds[dvar].cb_changed = cb_changed;
// 	level.example_cmds[dvar].type = valtype;

// 	switch(valtype)
// 	{
// 		case VTYPE_BOOL:
// 		case VTYPE_INT:
// 		case VTYPE_FLOAT:
// 			setdvar(dvar, 0);
// 			level.example_cmds[dvar].value = 0;
// 			break;
// 		case VTYPE_VECTOR:
// 			setdvar(dvar, (0, 0, 0));
// 			level.example_cmds[dvar].value = (0, 0, 0);
// 			break;
// 		default:
// 			setdvar(dvar, "");
// 			level.example_cmds[dvar].value = "";
// 			break;
// 	}
// }

// function jumpforme()
// {
// 	self endon("bled_out");
// 	self bottakemanualcontrol();
// 	for(;;)
// 	{
// 		self bottapbutton(10);
// 		self botsetgoal(self.origin);
// 		self.is_inert = true;
// 		wait 1;
// 	}
// }

// function freeze_after(time)
// {
// 	wait time;
// 	self freezeControls(true);
// }

// function_7e18304e(type, var_bd058c01, value = 0, overwrite = 0)
// {
// 	if(!isdefined(self.var_84298650))
// 	{
// 		self.var_84298650 = [];
// 	}
// 	if(isdefined(self.var_84298650[var_bd058c01]))
// 	{
// 		self.var_84298650[var_bd058c01].value = value;
// 	}
// 	else
// 	{
// 		var_535f7585 = spawnstruct();
// 		var_535f7585.type = type;
// 		var_535f7585.var_bd058c01 = var_bd058c01;
// 		var_535f7585.value = value;
// 		var_535f7585.overwrite = overwrite;
// 		self.var_84298650[var_bd058c01] = var_535f7585;
// 	}
// }

magicthread()
{
	self endon(#disconnect);
	self endon(#bled_out);
	self notify(#magicthread1);
	self endon(#magicthread1);
	// for(;;)
	// {
	// 	self waittill("weapon_fired");
	// 	//MagicBullet(getweapon("ray_gun"), self geteye(), self geteye() + vectorscale(anglestoforward(self getplayerangles()), 10000), self);
	// 	//MagicBullet(getweapon("ray_gun_upgraded"), self geteye(), self geteye() + vectorscale(anglestoforward(self getplayerangles()), 10000), self);
	// 	//MagicBullet(getweapon("sniper_fastbolt_upgraded"), self geteye(), self geteye() + vectorscale(anglestoforward(self getplayerangles()), 10000), self);
	// 	//MagicBullet(getweapon("hero_annihilator"), self geteye(), self geteye() + vectorscale(anglestoforward(self getplayerangles()), 10000), self);
	// 	//MagicBullet(getweapon("launcher_standard_upgraded"), self geteye(), self geteye() + vectorscale(anglestoforward(self getplayerangles()), 10000), self);
	// }
	// setdvar("doublejump_enabled", 1);
	// setdvar("wallrun_enabled", 1);
	// setdvar("playerEnergy_wallRunEnergyEnabled", 1);
	// setdvar("playerEnergy_enabled", 1);
	// setdvar("playerEnergy_slideEnergyEnabled", 0);

	// setdvar("wallRun_maxTimeMs_zm", 2000);
	// setdvar("playerEnergy_maxReserve_zm", 200);
	// setdvar("playerEnergy_maxReserve", 200);
	// setdvar("wallRun_peakTest_zm", 0);


	// self AllowDoubleJump(true);	
	// self AllowWallRun(true);	
	// self setdoublejumpenergy(200);

	// self endon("disconnect");
	// self endon("spawned_player");
	// self endon("bled_out");
	// for(;;)
	// {
	// 	if(self isOnGround() || self IsWallRunning())
	// 	{
	// 		self setdoublejumpenergy(200);
	// 	}
	// 	wait 0.05;
	// }

	
}

// GrenadeAimbot()
// {
// 	self endon(#bled_out);
// 	self endon(#disconnect);
//     Viable_Targets = [];
//     enemy          = self;
//     for(;;)
//     {
//         self waittill("grenade_fire", grenade);
//         Viable_Targets = ArrayCopy(level.players);
//         arrayremovevalue(Viable_Targets, self);
// 		foreach(player in level.players)
// 			if(player.team == self.team)
// 				arrayremovevalue(Viable_Targets, player);
//         enemy = array::get_all_closest(grenade getOrigin(), Viable_Targets)[0];
//         if(isDefined(enemy))
//         {
//             grenade thread trackerV3(enemy, self);
//         }
//     }
// }

// trackerV3(enemy, host)
// {
//     self endon("death");
//     self endon("detonate");
//     attempts = 0;
//     if(isDefined(enemy) && enemy != host)
//     {
//         /*If we have an enemy to attack, move to him/her and kill target*/
//         while(!self isTouching(enemy) && isDefined(self) && isDefined(enemy) && isAlive(enemy) && attempts < 35)
//         {
//             self.origin += ((enemy getOrigin()) - self getorigin()) * (attempts / 35);
//             wait .1;
//             attempts++;
//         }
//         wait .05;
//     }
// }

// ProjectilesEdit(num, type)
// {
//     if(!isdefined(self.projectilelist))
//         self.projectilelist = [];
    
//     self.projectilelist[type] = num;
//     self.projectilespread = 15;
    
//     self thread ProjectileFireMonitor();
// }

// ProjectileFireMonitor()
// {
//     self notify("ProjectileFireMonitor");
//     self endon("ProjectileFireMonitor");
//     self endon("spawned_player");
//     self endon("disconnect");
//     level endon("end_game");

// 	self thread ClusterGrenades();
//     for(;;)
//     {
//         self waittill("weapon_fired");
        
//         while(self.sessionstate == "spectator" || self.sessionstate == "dead")
//             wait 1;

//         if(!isdefined(self.projectilelist))
//             continue;
        
//         foreach(key, value in self.projectilelist)
//         {
//             if(key == "default")
//                 weapon = self getCurrentWeapon();
//             else
//                 weapon = getweapon(key);
            
//             if(!isdefined(value))
//                 continue;
            
//             for(i = 0; i < value; i++)
//             {
//                 origin = self GetTagOrigin("tag_flash");
//                 magicBullet(weapon, origin, self RandomWeaponTarget(self.projectilespread, origin), self);
//             }
//         }
//     }
// }

// RandomWeaponTarget(degrees = 5, origin)
// {
//     rand   = (randomFloatRange(-1 * degrees, degrees), randomFloatRange(-1 * degrees, degrees), randomFloatRange(-1 * degrees, degrees));
//     angles = combineAngles(rand, self getPlayerAngles());
//     return VectorScale(AnglesToForward(angles), 10000) + origin;
// }

// ClusterGrenades()
// {
// 	self endon(#bled_out);
// 	self notify(#ClusterGrenades);
// 	self endon(#ClusterGrenades);
//     self.gcluster = false;
//     for(;;)
//     {
//         self waittill("grenade_fire", grenade, weapon);
        
//         if(self.gcluster)
//             continue;
        
//         self thread GrenadeSplit(grenade, weapon);
//     }
// }

// grenadesplit(grenade, weapon)
// {
//     lastspot = (0,0,0);
//     while(isdefined(grenade))
//     {
//         lastspot = (grenade GetOrigin());
//         wait .025;
//     }
//     self.gcluster = true;
//     self MagicGrenadeType(weapon, lastspot, (250,0,250), 2);
//     self MagicGrenadeType(weapon, lastspot, (250,250,250), 2);
//     self MagicGrenadeType(weapon, lastspot, (250,-250,250), 2);
//     self MagicGrenadeType(weapon, lastspot, (-250,0,250), 2);
//     // self MagicGrenadeType(weapon, lastspot, (-250,250,250), 2);
//     // self MagicGrenadeType(weapon, lastspot, (-250,-250,250), 2);
//     // self MagicGrenadeType(weapon, lastspot, (0,0,250), 2);
//     // self MagicGrenadeType(weapon, lastspot, (0,250,250), 2);
//     // self MagicGrenadeType(weapon, lastspot, (0,-250,250), 2);
//     wait .025;
//     self.gcluster = false;
// }

// dada()
// {
//     self setdstat("freerunTrackTimes", "track", level.frgame.trackindex, "mapUniqueId", level.frgame.mapuniqueid);
// 	self setdstat("freerunTrackTimes", "track", level.frgame.trackindex, "mapVersion", level.frgame.mapversion);
// 	for(slot = 0; slot < 3; slot++)
// 	{
// 		set_high_score_stat(level.frgame.trackindex, slot, "time", 0);
// 		set_high_score_stat(level.frgame.trackindex, slot, "faults", 0x80000000);
// 		set_high_score_stat(level.frgame.trackindex, slot, "retries", 0x80000000);
// 		set_high_score_stat(level.frgame.trackindex, slot, "bulletPenalty", 0x80000000);
// 	}
// 	trackscompleted = self getdstat("freerunTracksCompleted");
// 	if(trackscompleted < level.frgame.trackindex)
// 	{
// 		self setdstat("freerunTracksCompleted", level.frgame.trackindex);
// 	}
// 	level clientfield::set("freerun_finishTime", 0);
// 	level clientfield::set("freerun_state", 2);
// 	level notify("finished_track");
// 	setlocalprofilevar("com_firsttime_freerun", 1);
// 	highest_track = getlocalprofileint("freerunHighestTrack");
// 	if(highest_track < level.frgame.trackindex)
// 	{
// 		setlocalprofilevar("freerunHighestTrack", level.frgame.trackindex);
// 	}
// 	wait(1.5);
//     uploadstats(self);
// 	self recordgameevent("completion");
// 	self freerunsethighscores(0, 0, 0);
// 	self uploadleaderboards();
// 	IPrintLnBold("DONE");
// }

// set_high_score_stat(trackindex, slot, stat, value)
// {
// 	self setdstat("freerunTrackTimes", "track", trackindex, "topTimes", slot, stat, value);
// }