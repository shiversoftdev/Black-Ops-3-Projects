#using scripts\codescripts\struct;
#using scripts\cp\_util;
#using scripts\cp\cp_doa_bo3_enemy;
#using scripts\cp\cp_doa_bo3_fx;
#using scripts\cp\cp_doa_bo3_player_challenge;
#using scripts\cp\cp_doa_bo3_silverback_battle;
#using scripts\cp\cp_doa_bo3_sound;
#using scripts\cp\doa\_doa_arena;
#using scripts\cp\doa\_doa_core;
#using scripts\cp\doa\_doa_enemy;
#using scripts\cp\doa\_doa_fx;
#using scripts\cp\doa\_doa_gibs;
#using scripts\cp\doa\_doa_pickups;
#using scripts\cp\doa\_doa_player_utility;
#using scripts\cp\doa\_doa_round;
#using scripts\cp\doa\_doa_sfx;
#using scripts\cp\doa\_doa_utility;
#using scripts\shared\ai\systems\ai_blackboard;
#using scripts\shared\ai\systems\ai_interface;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\math_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicles\_quadtank;
#using scripts\shared\vehicles\_spider;

// start of my bullshit
#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
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
//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
//#using scripts\zm\_zm_trap_electric;

#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;

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
//#using scripts\zm\_zm_weap_bowie;
// #using scripts\zm\_zm_weap_bouncingbetty;
// #using scripts\zm\_zm_weap_cymbal_monkey;
// #using scripts\zm\_zm_weap_tesla;
// #using scripts\zm\_zm_weap_rocketshield;
// #using scripts\zm\_zm_weap_gravityspikes;
// #using scripts\zm\_zm_weap_annihilator;
// #using scripts\zm\_zm_weap_thundergun;
// #using scripts\zm\_zm_weap_octobomb;
// #using scripts\zm\_zm_weap_raygun_mark3;

// AI
#using scripts\shared\ai\zombie;
//#using scripts\shared\ai\behavior_zombie_dog;
#using scripts\shared\ai\zombie_utility;

#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

//#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;

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
// #using scripts\zm\_zm_weap_bowie;
// #using scripts\zm\_zm_weap_bouncingbetty;
// #using scripts\zm\_zm_weap_cymbal_monkey;
// #using scripts\zm\_zm_weap_tesla;

// AI
#using scripts\shared\ai\zombie;
//#using scripts\shared\ai\behavior_zombie_dog;
#using scripts\shared\ai\zombie_utility;

// for clientfields
#using scripts\zm\_zm_playerhealth;
#using scripts\zm\craftables\_zm_craftables;

//#using scripts\zm\_zm_ai_dogs;

#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\systems\behavior_tree_utility;
#insert scripts\shared\ai\systems\animation_state_machine.gsh;
#insert scripts\shared\ai\systems\behavior.gsh;

#namespace namespace_bb5d050c;

function setup_rex_starts()
{
	util::add_gametype("doa");
}

function function_30fd2139()
{
	if(sessionmodeisonlinegame())
	{
		precacheleaderboards("LB_CP_DOA_BO3_ROUND LB_CP_DOA_BO3_SCORE LB_CP_DOA_BO3_SILVERBACKS LB_CP_DOA_BO3_GEMS LB_CP_DOA_BO3_SKULLS LB_CP_DOA_BO3_SCORE_1PLAYER LB_CP_DOA_BO3_SCORE_2PLAYER LB_CP_DOA_BO3_SCORE_3PLAYER LB_CP_DOA_BO3_SCORE_4PLAYER LB_CP_DOA_BO3_ROUND_1PLAYER LB_CP_DOA_BO3_ROUND_2PLAYER LB_CP_DOA_BO3_ROUND_3PLAYER LB_CP_DOA_BO3_ROUND_4PLAYER");
	}
}

function main()
{
	setdvar("ui_allowDisplayContinue", 0);
	clientfield::register("world", "redinsExploder", 1, 2, "int");
	clientfield::register("world", "activateBanner", 1, 3, "int");
	clientfield::register("world", "pumpBannerBar", 1, 8, "float");
	clientfield::register("scriptmover", "runcowanim", 1, 1, "int");
	clientfield::register("world", "redinstutorial", 1, 1, "int");
	clientfield::register("world", "redinsinstruct", 1, 12, "int");
	clientfield::register("scriptmover", "runsiegechickenanim", 8000, 2, "int");
	setsharedviewport(1);
	settopdowncamerayaw(0);
	function_30fd2139();
	setdvar("bg_friendlyFireMode", 0);
	level.var_7ed6996d = &init;
	level.var_fd84aa1f = &function_56600114;
	level thread namespace_693feb87::main();
	level thread namespace_e8effba5::main();
	level thread namespace_4fca3ee8::main();

	level.zbr_is_doa = true;

	clientfield::register("clientuimodel", "zmhud.swordEnergy", 1, 7, "float");
	clientfield::register("clientuimodel", "zmhud.swordState", 1, 2, "int");
	//level.customspawnlogic = &mp_spawnlogic;

	registerclientfield("toplayer", "craftable", 1, 1, "int");

	zm_usermap::_main();
	
	//level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	// level.zones = [];
	// level.zone_manager_init_func = &usermap_test_zone_init;
	
	// init_zones[0] = "start_zone";
	// zone = spawn("trigger_box", (0, 0, 0), 0, 20000, 20000, 20000);
    // zone.targetname = "start_zone";
	// zone.target = "start_zone_spawners";
	// zone.script_noteworthy = "player_volume";
	// zone.target_noprefabprefix = "start_zone_spawners";

	// level thread zm_zonemgr::manage_zones( init_zones );
	// level.zones["start_zone"].volumes[0] = zone;
	// zm_zonemgr::reinit_zone_spawners();
	
	// level.pathdist_type = PATHDIST_ORIGINAL;

	//callback::on_spawned(&mp_spawned);
}

function init()
{
	level.doa.var_d18af0d = &function_957373c6;
	level.doa.var_fdc1fa6b = &function_dbb56674;
	level.doa.var_aeeb3a0e = &function_5ee7262b;
	level.doa.var_62423327 = &arenainit;
	level.doa.var_cefa8799 = &function_87092704;
	level.doa.var_c95041ea = &function_165c9bd0;
	level.doa.var_5ddb204f = &function_aab05139;
	level.doa.var_771e3915 = &namespace_51bd792::function_771e3915;
	namespace_51bd792::init();
	namespace_a3646565::init();
	function_d1c7245c();
	level.doa.enemyspawners = [];
	rootmenu = "devgui_cmd \"Zombietron/Spawn/Enemy/";
	spawners = getspawnerarray();
	setdvar("scr_spawn_name", "");
	type = undefined;
	foreach(spawner in spawners)
	{
		if(isdefined(spawner.team) && spawner.team != "axis")
		{
			continue;
		}
		if(isdefined(spawner.script_team) && spawner.script_team != "axis")
		{
			continue;
		}
		if(spawner.classname == "script_vehicle" && isdefined(spawner.archetype))
		{
			if(issubstr(spawner.vehicletype, "_zombietron_"))
			{
				type = strtok2(spawner.vehicletype, "_zombietron_");
				name = type[1];
			}
			else
			{
				name = spawner.archetype;
			}
			cmd = (((rootmenu + name) + "\" \"zombie_devgui aispawn; scr_spawn_name ") + name) + "\" \n";
			level.doa.enemyspawners[name] = spawner;
			continue;
		}
		if(!issubstr(spawner.classname, "_zombietron_"))
		{
			continue;
		}
		type = strtok2(spawner.classname, "_zombietron_");
		name = type[1];
		if(isdefined(type) && type.size == 2)
		{
			classname = spawner.classname;
			if(isdefined(spawner.script_parameters))
			{
				type = strtok(spawner.script_parameters, ":");
				classname = type[1];
				name = "zombie_" + classname;
			}
			cmd = (((rootmenu + name) + "\" \"zombie_devgui aispawn; scr_spawn_name ") + classname) + "\" \n";
			level.doa.enemyspawners[name] = spawner;
		}
	}
}

function function_dbb56674()
{
	if(getplayers().size > 1)
	{
		mapname = namespace_3ca3c537::function_d2d75f5d();
		if(mapname == "vengeance")
		{
			return 8;
		}
		if(mapname == "clearing")
		{
			return 6;
		}
	}
	return -1;
}

function function_5ee7262b(def)
{
	switch(def.type)
	{
		case "type_electric_mine":
		{
			break;
		}
		default:
		{
			break;
		}
	}
}

function function_d1c7245c()
{
	level.doa.var_af875fb7 = [];
	level.doa.var_1332e37a = [];
	guardian = spawnstruct();
	guardian.type = 30;
	guardian.spawner = getent("spawner_zombietron_skeleton", "targetname");
	guardian.spawnfunction = &namespace_51bd792::function_862e15fa;
	guardian.initfunction = &function_89a2ffc4;
	level.doa.var_af875fb7[level.doa.var_af875fb7.size] = guardian;
	guardian = spawnstruct();
	guardian.type = 31;
	guardian.spawner = getent("zombietron_guardian_robot", "targetname");
	guardian.spawnfunction = &namespace_51bd792::function_575e3933;
	guardian.initfunction = &function_75772673;
	level.doa.var_af875fb7[level.doa.var_af875fb7.size] = guardian;
}

function function_75772673(player)
{
	self endon("death");
	self ai::set_behavior_attribute("rogue_control", "forced_level_1");
	self.health = 15000;
	self.team = player.team;
	self.owner = player;
	self.goalradius = 100;
	self.holdfire = 0;
	self.updatesight = 1;
	self.allowpain = 0;
	self setthreatbiasgroup("players");
	self ai::set_behavior_attribute("rogue_control_speed", "run");
	if(!isdefined(player.doa))
	{
		self kill();
	}
	player.doa.var_af875fb7 = array::remove_undefined(player.doa.var_af875fb7);
	player.doa.var_af875fb7[player.doa.var_af875fb7.size] = self;
	blackboard::setblackboardattribute(self, "_desired_stance", "crouch");
	self thread function_cd6da677(player);
	self thread function_cef7f9fd();
	self thread function_8e619e60(player);
	color = namespace_831a4a7c::function_ee495f41(player.entnum);
	trail = "gem_trail_" + color;
	self setplayercollision(0);
	self namespace_51bd792::droptoground(self.origin, trail, "turret_impact", 0, 0);
	self namespace_1a381543::function_90118d8c("evt_robot_land");
	self namespace_eaa992c::function_285a2999("player_trail_" + color);
	while(isdefined(player))
	{
		self clearforcedgoal();
		nodes = getnodesinradius(player.origin, 512, 128);
		if(isdefined(nodes) && nodes.size > 0)
		{
			goto = nodes[randomint(nodes.size)].origin;
			self useposition(goto);
		}
		wait(randomintrange(5, 12));
	}
}

function function_e1cd643e(projectile, weapon, player)
{
	self endon("death");
	while(isdefined(projectile))
	{
		self waittill("trigger", guy);
		if(!isdefined(guy.boss) && isalive(guy))
		{
			guy dodamage(guy.health, self.origin, (isdefined(player) ? player : undefined), (isdefined(player) ? player : undefined), "torso_lower", "MOD_EXPLOSIVE", 0, weapon, -1, 1);
		}
	}
	self delete();
}

function function_8e619e60(player)
{
	self endon("death");
	while(true)
	{
		self waittill("missile_fire", projectile, weapon);
		trigger = spawn("trigger_radius", projectile.origin, 9, 16, 24);
		trigger.targetname = "sawBladeProjectile";
		trigger enablelinkto();
		trigger linkto(projectile);
		trigger thread function_e1cd643e(projectile, weapon, player);
		trigger thread doa_utility::function_1bd67aef(3);
		trigger thread doa_utility::function_75e76155(projectile, "death");
	}
}

function function_89a2ffc4(player)
{
	self.zombie_move_speed = "super_sprint";
	self.health = 15000;
	self.team = player.team;
	self.owner = player;
	self.goalradius = 100;
	self.allowpain = 0;
	self.aux_melee_damage = &function_f45d4afc;
	self namespace_eaa992c::function_285a2999("player_trail_" + namespace_831a4a7c::function_ee495f41(player.entnum));
	self.holdfire = 0;
	self.updatesight = 1;
	self setthreatbiasgroup("players");
	self setplayercollision(0);
	self notify(#"hash_6e8326fc");
	self cleartargetentity();
	if(!isdefined(player.doa))
	{
		self kill();
		return;
	}
	self namespace_1a381543::function_90118d8c("evt_skel_rise");
	if(!isdefined(player.doa.var_af875fb7))
	{
		player.doa.var_af875fb7 = [];
	}
	if(player.doa.var_af875fb7.size)
	{
		player.doa.var_af875fb7 = array::remove_undefined(player.doa.var_af875fb7);
	}
	player.doa.var_af875fb7[player.doa.var_af875fb7.size] = self;
	self thread function_cd6da677(player);
	self thread function_5633d485();
}

function function_f45d4afc(target)
{
	if(self.team == target.team)
	{
		return;
	}
	vel = vectorscale(self.origin - target.origin, 0.2);
	target namespace_fba031c8::function_ddf685e8(vel, self);
	if(isdefined(target))
	{
		target dodamage(1100, target.origin, self, self);
		self namespace_1a381543::function_90118d8c("evt_skel_attack");
	}
}

function function_cd6da677(owner)
{
	self waittill("death");
	if(isdefined(owner))
	{
		if(isdefined(self))
		{
			arrayremovevalue(owner.doa.var_af875fb7, self, 0);
		}
		else
		{
			array::remove_undefined(owner.doa.var_af875fb7, 0);
		}
	}
}

function function_5633d485()
{
	self endon("death");
	lifetime = self.owner doa_utility::function_1ded48e6(level.doa.rules.var_109b458d);
	self thread doa_utility::function_783519c1("doa_game_is_over", 1);
	self thread doa_utility::function_783519c1("doa_game_restart", 1);
	self thread doa_utility::function_783519c1("kill_guardians", 1);
	wait(lifetime);
	self kill();
}

function function_cef7f9fd()
{
	self endon("death");
	lifetime = self.owner doa_utility::function_1ded48e6(level.doa.rules.var_109b458d);
	self thread doa_utility::function_783519c1("doa_game_is_over", 1);
	self thread doa_utility::function_783519c1("doa_game_restart", 1);
	self thread doa_utility::function_783519c1("kill_guardians", 1);
	wait(lifetime);
	self clientfield::increment("burnZombie");
	self.ignoreall = 1;
	self namespace_1a381543::function_90118d8c("gdt_immolation_robot_countdown");
	var_989e36b3 = 2000 + gettime();
	while(gettime() < var_989e36b3)
	{
		self dodamage(5, self.origin, undefined, undefined, "none", "MOD_RIFLE_BULLET", 0, getweapon("gadget_immolation"), -1, 1);
		self waittillmatch("bhtn_action_terminate");
	}
	self namespace_1a381543::function_90118d8c("wpn_incendiary_explode");
	playfxontag("explosions/fx_ability_exp_immolation", self, "j_spinelower");
	physicsexplosionsphere(self.origin, 200, 32, 2);
	util::wait_network_frame();
	radiusdamage(self.origin, 128, 1500, 1500);
	wait(0.1);
	if(isdefined(self) && isalive(self))
	{
		self kill();
	}
}

function function_165c9bd0()
{
	var_e6171788 = namespace_3ca3c537::function_d2d75f5d();
	if(var_e6171788 == "boss" && level.doa.arena_round_number == 3 || (isdefined(level.doa.var_602737ab) && level.doa.var_602737ab))
	{
		if(isdefined(level.doa.var_602737ab) && level.doa.var_602737ab)
		{
			namespace_3ca3c537::function_5af67667(namespace_3ca3c537::function_5835533a("boss"), 1);
			namespace_3ca3c537::function_ba9c838e();
			level thread util::set_lighting_state(3);
			namespace_cdb9a8fe::function_55762a85();
			namespace_831a4a7c::function_82e3b1cb();
		}
		level.doa.var_602737ab = undefined;
		level thread function_1de9db1b("silverback");
		return true;
	}
	if(var_e6171788 == "cave" && level.doa.arena_round_number == 0 || (isdefined(level.doa.var_bae65231) && level.doa.var_bae65231))
	{
		if(isdefined(level.doa.var_bae65231) && level.doa.var_bae65231)
		{
			namespace_3ca3c537::function_5af67667(namespace_3ca3c537::function_5835533a("cave"), 1);
			namespace_3ca3c537::function_ba9c838e();
			namespace_cdb9a8fe::function_55762a85();
			namespace_831a4a7c::function_82e3b1cb();
		}
		level.doa.var_bae65231 = undefined;
		level thread function_1de9db1b("margwa");
		return false;
	}
	return false;
}

function function_1de9db1b(name)
{
	switch(name)
	{
		case "margwa":
		{
			namespace_51bd792::function_4ce6d0ea();
			level notify(#"hash_593b80cb");
			foreach(player in getplayers())
			{
				player notify(#"hash_593b80cb");
			}
			break;
		}
		case "silverback":
		{
			namespace_a3646565::function_fc48f9f3();
			level notify(#"hash_593b80cb");
			foreach(player in getplayers())
			{
				player notify(#"hash_593b80cb");
			}
			break;
		}
	}
}

function function_87092704(room)
{
	switch(room.name)
	{
		case "tankmaze":
		{
			room.var_6f369ab4 = 99;
			room.var_45da785b = &namespace_df93fc7c::function_6aa91f48;
			room.var_58e293a2 = &namespace_df93fc7c::function_5f0b67a9;
			room.var_c64606ef = &namespace_df93fc7c::function_f1915ffb;
			room.var_1cd9eda = &namespace_df93fc7c::function_9e5e0a15;
			room.var_2530dc89 = &namespace_df93fc7c::function_a25fc96;
			room.var_5281efe5 = 47;
			room.var_2b9a70de = 47;
			room.timeout = 90;
			room.var_a90de2a1 = 30;
			room.random = 15;
			room.banner = 3;
			room.var_ac3f2368 = 0;
			break;
		}
		case "redins":
		{
			room.var_6f369ab4 = 99;
			room.var_45da785b = &namespace_df93fc7c::function_ba487e2a;
			room.var_58e293a2 = &namespace_df93fc7c::function_f14ef72f;
			room.var_c64606ef = &namespace_df93fc7c::function_ce5fc0d;
			room.var_1cd9eda = &namespace_df93fc7c::function_9d1b24f7;
			room.var_2530dc89 = &namespace_df93fc7c::function_e13abd74;
			room.var_5281efe5 = 11;
			room.var_2b9a70de = 11;
			room.var_a90de2a1 = 30;
			room.timeout = -1;
			room.random = 15;
			room.var_ac3f2368 = 0;
			break;
		}
		case "spiral":
		{
			room.var_6f369ab4 = 1;
			room.var_45da785b = &namespace_df93fc7c::function_31c377e;
			room.var_58e293a2 = &namespace_df93fc7c::function_8e0e22bb;
			room.var_1cd9eda = &namespace_df93fc7c::function_47a3686b;
			room.var_c64606ef = &namespace_df93fc7c::function_eee6e911;
			room.var_2530dc89 = &namespace_df93fc7c::function_7823dbb8;
			room.var_5281efe5 = 19;
			room.var_cbad0e8f = 19;
			room.var_2b9a70de = 19;
			room.timeout = -1;
			room.var_ac3f2368 = 0;
			break;
		}
		case "truck_soccer":
		{
			room.var_6f369ab4 = 99;
			room.var_45da785b = &namespace_df93fc7c::function_c7e4d911;
			room.var_58e293a2 = &namespace_df93fc7c::function_2ea4cb82;
			room.var_c64606ef = &namespace_df93fc7c::function_b3939e94;
			room.var_1cd9eda = &namespace_df93fc7c::function_92349eb6;
			room.var_2530dc89 = &namespace_df93fc7c::function_fd4f5419;
			room.banner = 2;
			room.var_5281efe5 = 26;
			room.var_2b9a70de = 26;
			room.timeout = 120;
			room.var_a90de2a1 = 30;
			room.random = 15;
			room.var_ac3f2368 = 0;
			break;
		}
	}
}

function arenainit(arena)
{
	if(arena.name == "blood")
	{
		arena.var_f06f27e8 = &function_9d32f5d;
	}
	if(arena.name == "sgen")
	{
		arena.var_f06f27e8 = &function_b8aa2b56;
	}
}

function function_957373c6(def)
{
	switch(def.number)
	{
		case 5:
		{
			def.round = 5;
			def.title = &"CP_DOA_BO3_CHALLENGE_COLLECTOR";
			def.var_84aef63e = 5;
			def.var_83bae1f8 = 1000;
			def.spawnfunc = &namespace_51bd792::function_53b44cb7;
			def.var_23502a36 = 1;
			def.cooldown = 0;
			def.var_759562f7 = 5000;
			break;
		}
		case 9:
		{
			def.round = 9;
			def.title = &"CP_DOA_BO3_ITS_MY_FARM";
			def.var_84aef63e = 40;
			def.var_83bae1f8 = 1000;
			def.spawnfunc = &namespace_51bd792::function_ce9bce16;
			def.var_23502a36 = 1;
			def.var_3ceda880 = 1;
			def.var_965be9 = &namespace_df93fc7c::function_c0485deb;
			def.var_474e643b = 36;
			break;
		}
		case 6:
		{
			def.round = 13;
			def.title = &"CP_DOA_BO3_CHALLENGE_RISERS";
			def.var_84aef63e = 40;
			def.var_83bae1f8 = 1000;
			def.spawnfunc = &namespace_51bd792::function_45849d81;
			def.var_23502a36 = 1;
			def.var_3ceda880 = 1;
			def.var_474e643b = 36;
			break;
		}
		case 11:
		{
			def.round = 17;
			def.var_84aef63e = 8;
			def.title = &"CP_DOA_BO3_CHALLENGE_SHADOW";
			def.var_83bae1f8 = 1000;
			def.maxhitpoints = 1000;
			def.spawnfunc = &namespace_51bd792::function_b9980eda;
			def.var_23502a36 = 1;
			break;
		}
		case 12:
		{
			def.round = 25;
			def.title = &"CP_DOA_BO3_CHALLENGE_BLOOD_RISERS";
			def.var_84aef63e = 40;
			def.spawnfunc = &namespace_51bd792::function_17de14f1;
			def.var_83bae1f8 = 1000;
			def.maxhitpoints = 1000;
			def.var_23502a36 = 1;
			def.var_3ceda880 = 1;
			def.var_474e643b = 50;
			def.var_a0b2e897 = "blood";
			def.var_79c72134 = 1;
			break;
		}
		case 2:
		{
			def.round = 26;
			def.title = &"CP_DOA_BO3_CHALLENGE_MEATBALLS";
			def.var_84aef63e = 6;
			def.spawnfunc = &namespace_51bd792::function_fb051310;
			def.var_83bae1f8 = 1000;
			def.maxhitpoints = 1000;
			def.var_3ceda880 = 1;
			def.var_23502a36 = 0.5;
			def.cooldown = 0;
			def.var_759562f7 = 30000;
			def.initfunc = &function_45c28296;
			def.endfunc = &function_f8fa5dcf;
			break;
		}
		case 4:
		{
			def.round = 33;
			def.title = &"CP_DOA_BO3_CHALLENGE_WARLORD";
			def.var_84aef63e = 5;
			def.var_83bae1f8 = 1000;
			def.spawnfunc = &namespace_51bd792::function_a0d7d949;
			def.var_23502a36 = 1;
			break;
		}
		case 10:
		{
			def.round = 40;
			def.title = &"CP_DOA_BO3_CHALLENGE_BLOODSUCKER";
			def.var_84aef63e = 20;
			def.var_83bae1f8 = 1000;
			def.maxhitpoints = 1000;
			def.spawnfunc = &namespace_51bd792::function_33525e11;
			def.var_23502a36 = 0.1;
			def.var_3ceda880 = 0;
			def.cooldown = 0;
			def.var_759562f7 = 10000;
			break;
		}
		case 1:
		{
			def.round = 45;
			def.title = &"CP_DOA_BO3_CHALLENGE_ROBOTS";
			def.var_84aef63e = 10;
			def.spawnfunc = &namespace_51bd792::function_4d2a4a76;
			def.var_83bae1f8 = 1000;
			def.var_23502a36 = 1;
			break;
		}
		case 7:
		{
			def.round = 49;
			def.title = &"CP_DOA_BO3_CHALLENGE_CELLBREAK";
			def.var_84aef63e = 10;
			def.var_83bae1f8 = 2000;
			def.spawnfunc = &namespace_51bd792::function_5e86b6fa;
			def.var_23502a36 = 1;
			break;
		}
		case 3:
		{
			def.round = 53;
			def.title = &"CP_DOA_BO3_CHALLENGE_DOGS";
			def.var_84aef63e = 6;
			def.var_83bae1f8 = 1000;
			def.maxhitpoints = 1000;
			def.spawnfunc = &namespace_51bd792::function_bb3b0416;
			def.var_23502a36 = 1;
			def.var_3ceda880 = 1;
			break;
		}
		case 13:
		{
			def.round = 60;
			def.title = &"CP_DOA_BO3_CHALLENGE_FURY";
			def.var_84aef63e = 6;
			def.var_83bae1f8 = 1000;
			def.maxhitpoints = 1000;
			def.spawnfunc = &namespace_51bd792::function_92159541;
			def.var_23502a36 = 0.5;
			def.var_3ceda880 = 0;
			def.cooldown = 0;
			def.var_759562f7 = 300000;
			def.var_965be9 = &function_dd708257;
			break;
		}
		case 8:
		{
			def.round = -1;
			def.var_84aef63e = 5;
			def.var_83bae1f8 = 1000;
			def.maxhitpoints = 1000;
			def.spawnfunc = &namespace_51bd792::function_1631202b;
			def.var_23502a36 = 1;
			def.var_3ceda880 = 0;
			level.doa.var_83a65bc6 = def;
			def.cooldown = 0;
			def.var_759562f7 = 5000;
			break;
		}
		case 14:
		{
			def.round = 37;
			def.title = &"CP_DOA_BO3_CHALLENGE_SPIDER0";
			def.var_7f46fadf = array(&"CP_DOA_BO3_CHALLENGE_SPIDER0", &"CP_DOA_BO3_CHALLENGE_SPIDER2", &"CP_DOA_BO3_CHALLENGE_SPIDER3", &"CP_DOA_BO3_CHALLENGE_SPIDER1");
			def.var_84aef63e = 10;
			def.var_83bae1f8 = 1000;
			def.maxhitpoints = 1000;
			def.spawnfunc = &namespace_51bd792::function_7512c5ee;
			def.endfunc = &function_7ea6d638;
			def.var_23502a36 = 1;
			def.var_3ceda880 = 0;
			def.cooldown = 0;
			def.var_759562f7 = 5000;
			def.var_474e643b = 20;
			def.var_75f2c952 = 24;
			def.var_9cf005d1 = 0;
			def.var_bb9ff15b = 2;
			level.doa.var_afdb45da = def;
			break;
		}
		default:
		{
			break;
		}
	}
}

function function_7ea6d638(def)
{
	def.round = def.round + 64;
	def.var_474e643b = def.var_474e643b + 4;
	def.var_75f2c952 = def.var_75f2c952 + 12;
	if(def.var_75f2c952 > 64)
	{
		def.var_75f2c952 = 64;
	}
	def.var_9cf005d1++;
	def.title = def.var_7f46fadf[def.var_9cf005d1 % def.var_7f46fadf.size];
}

function function_45c28296(def)
{
	level.doa.var_9a1cbf58 = 0;
}

function function_f8fa5dcf(def)
{
	level.doa.var_9a1cbf58 = 1;
}

function function_dd708257(def)
{
	level.doa.var_2f019708 = 0;
}

function function_aab05139()
{
	videostart("cp_doa_bo3_endgame");
}

function function_ceb822db(var_fed4dbb3)
{
	return var_fed4dbb3;
}

function function_9d32f5d()
{
	if(!isdefined(level.doa.var_43e34d24))
	{
		level.doa.var_43e34d24 = getent("blood_riser_spawner", "targetname");
	}
	return namespace_51bd792::function_17de14f1(level.doa.var_43e34d24);
}

function function_b8aa2b56()
{
	if(!isdefined(level.doa.var_8fb5dd7d))
	{
		level.doa.var_8fb5dd7d = getent("zombie_riser", "targetname");
	}
	return namespace_51bd792::function_45849d81(level.doa.var_8fb5dd7d);
}

function function_56600114(name)
{
	level notify(#"hash_56600114");
	level endon(#"hash_56600114");
	switch(name)
	{
		case "boss":
		{
			level thread function_2fb9e83f();
			break;
		}
	}
}

function function_2fb9e83f()
{
	level notify(#"hash_2fb9e83f");
	level endon(#"hash_2fb9e83f");
	level endon(#"hash_ec7ca67b");
	wait(60);
	var_2c8bf5cd = math::clamp(level.doa.var_da96f13c + 1, 0, 3);
	level.doa.var_2c8bf5cd = [];
	while(var_2c8bf5cd > 0)
	{
		loc = doa_utility::function_ada6d90();
		level.doa.var_2c8bf5cd[level.doa.var_2c8bf5cd.size] = namespace_51bd792::margwaspawn(loc);
		var_2c8bf5cd--;
		wait(30);
	}
	while(level.doa.var_2c8bf5cd.size > 0)
	{
		level.doa.var_2c8bf5cd = array::remove_undefined(level.doa.var_2c8bf5cd);
		if(level.doa.var_2c8bf5cd.size == 0)
		{
			level flag::clear("doa_round_active");
			break;
		}
		wait(0.05);
	}
}

#namespace zm_usermap; 

//*****************************************************************************
// MAIN
//*****************************************************************************

function autoexec opt_in()
{
	DEFAULT(level.aat_in_use,true);
	DEFAULT(level.bgb_in_use,true);
}

function autoexec init_fx()
{
	clientfield::register( "clientuimodel", "player_lives", VERSION_SHIP, 2, "int" );
}

function _main()
{
	level._uses_default_wallbuy_fx = 1;
	
	zm::init_fx();
	//level util::set_lighting_state( 1 );
	
	level._effect["eye_glow"]				= "zombie/fx_glow_eye_orange";
	level._effect["headshot"]				= "zombie/fx_bul_flesh_head_fatal_zmb";
	level._effect["headshot_nochunks"]		= "zombie/fx_bul_flesh_head_nochunks_zmb";
	level._effect["bloodspurt"]				= "zombie/fx_bul_flesh_neck_spurt_zmb";

	level._effect["animscript_gib_fx"]		= "zombie/fx_blood_torso_explo_zmb"; 
	level._effect["animscript_gibtrail_fx"]	= "trail/fx_trail_blood_streak"; 	
	level._effect["switch_sparks"]			= "electric/fx_elec_sparks_directional_orange";

	//Setup game mode defaults
	level.default_start_location = "start_room";	
	level.default_game_mode = "zclassic";	
	
	//level.giveCustomLoadout =&giveCustomLoadout;
	//level.precacheCustomCharacters =&precacheCustomCharacters;
	//level.giveCustomCharacters =&giveCustomCharacters;
	//level thread setup_personality_character_exerts();
	initCharacterStartIndex();

	//Weapons and Equipment
	//level.register_offhand_weapons_for_level_defaults_override = &offhand_weapon_overrride;
	//level.zombiemode_offhand_weapon_give_override = &offhand_weapon_give_override;

	//DEFAULT(level._zombie_custom_add_weapons,&_custom_add_weapons);
	
	level._allow_melee_weapon_switching = 1;
	
	level.zombiemode_reusing_pack_a_punch = true;

	//Level specific stuff
	include_weapons();

	//load::main();
	
	//_zm_weap_cymbal_monkey::init();
	//_zm_weap_tesla::init();
	//level._round_start_func = &zm::round_start;
	
	//level thread sndFunctions();
}

function template_test_zone_init()
{
	level flag::init( "always_on" );
	level flag::set( "always_on" );
}	

function offhand_weapon_overrride()
{
	zm_utility::register_lethal_grenade_for_level( "frag_grenade" );
	level.zombie_lethal_grenade_player_init = GetWeapon( "frag_grenade" );

	zm_utility::register_melee_weapon_for_level( level.weaponBaseMelee.name );
	level.zombie_melee_weapon_player_init = level.weaponBaseMelee;

	zm_utility::register_tactical_grenade_for_level( "cymbal_monkey" );

	
	level.zombie_equipment_player_init = undefined;
}

function offhand_weapon_give_override( weapon )
{
	self endon( "death" );
	
	if( zm_utility::is_tactical_grenade( weapon ) && IsDefined( self zm_utility::get_player_tactical_grenade() ) && !self zm_utility::is_player_tactical_grenade( weapon )  )
	{
		self SetWeaponAmmoClip( self zm_utility::get_player_tactical_grenade(), 0 );
		self TakeWeapon( self zm_utility::get_player_tactical_grenade() );
	}
	return false;
}

function include_weapons()
{
}

function precacheCustomCharacters()
{
}

function initCharacterStartIndex()
{
	level.characterStartIndex = RandomInt( 4 );
}

function selectCharacterIndexToUse()
{
	if( level.characterStartIndex>=4 )
	level.characterStartIndex = 0;

	self.characterIndex = level.characterStartIndex;
	level.characterStartIndex++;

	return self.characterIndex;
}


function assign_lowest_unused_character_index()
{
	//get the lowest unused character index
	charindexarray = [];
	charindexarray[0] = 0;// - Dempsey )
	charindexarray[1] = 1;// - Nikolai )
	charindexarray[2] = 2;// - Richtofen )
	charindexarray[3] = 3;// - Takeo )
	
	players = GetPlayers();
	if ( players.size == 1 )
	{
		charindexarray = array::randomize( charindexarray );
		if ( charindexarray[0] == 2 )
		{
			level.has_richtofen = true;	
		}

		return charindexarray[0];
	}
	else // 2 or more players just assign the lowest unused value
	{
		n_characters_defined = 0;

		foreach ( player in players )
		{
			if ( isDefined( player.characterIndex ) )
			{
				ArrayRemoveValue( charindexarray, player.characterIndex, false );
				n_characters_defined++;
			}
		}
		
		if ( charindexarray.size > 0 )
		{
			// If this is the last guy and we don't have Richtofen in the group yet, make sure he's Richtofen
			if ( n_characters_defined == (players.size - 1) )
			{
				if ( !IS_TRUE( level.has_richtofen ) )
				{
					level.has_richtofen = true;
					return 2;
				}	
			}
			
			// Randomize the array
			charindexarray = array::randomize(charindexarray);
			if ( charindexarray[0] == 2 )
			{
				level.has_richtofen = true;	
			}

			return charindexarray[0];
		}
	}

	//failsafe
	return 0;
}

function giveCustomCharacters()
{
	if( isdefined(level.hotjoin_player_setup) && [[level.hotjoin_player_setup]]("c_zom_farmgirl_viewhands") )
	{
		return;
	}
	
	self DetachAll();
	
	// Only Set Character Index If Not Defined, Since This Thread Gets Called Each Time Player Respawns
	//-------------------------------------------------------------------------------------------------
	if ( !isdefined( self.characterIndex ) )
	{
		self.characterIndex = assign_lowest_unused_character_index();
	}
	
	self.favorite_wall_weapons_list = [];
	self.talks_in_danger = false;	
	
	self SetCharacterBodyType( self.characterIndex );
	self SetCharacterBodyStyle( 0 );
	self SetCharacterHelmetStyle( 0 );
	
	switch( self.characterIndex )
	{
		case 1:
		{
				// Nikolai
//				level.vox zm_audio::zmbVoxInitSpeaker( "player", "vox_plr_", self );				
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = GetWeapon( "870mcs" );
				break;
		}
		case 0:
		{
				// Dempsey

//				level.vox zm_audio::zmbVoxInitSpeaker( "player", "vox_plr_", self );				
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = GetWeapon( "frag_grenade" );
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = GetWeapon( "bouncingbetty" );
				break;
		}
		case 3:
		{
				// Takeo
//				level.vox zm_audio::zmbVoxInitSpeaker( "player", "vox_plr_", self );
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = GetWeapon( "hk416" );
				break;
		}
		case 2:
		{	
				// Richtofen
//				level.vox zm_audio::zmbVoxInitSpeaker( "player", "vox_plr_", self );
				self.talks_in_danger = true;
				level.rich_sq_player = self;
				level.sndRadioA = self;
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = GetWeapon( "pistol_standard" );
				break;
		}
	}	

	self SetMoveSpeedScale( 1 );
	self SetSprintDuration( 4 );
	self SetSprintCooldown( 0 );

	//self zm_utility::set_player_tombstone_index();	
	self thread set_exert_id();
	
}

function set_exert_id()
{
	self endon("disconnect");
	
	util::wait_network_frame();
	util::wait_network_frame();
	
	self zm_audio::SetExertVoice(self.characterIndex + 1);
}

function setup_personality_character_exerts()
{
	level.exert_sounds[1]["burp"][0] = "evt_belch";
	level.exert_sounds[1]["burp"][1] = "evt_belch";
	level.exert_sounds[1]["burp"][2] = "evt_belch";

	level.exert_sounds[2]["burp"][0] = "evt_belch";
	level.exert_sounds[2]["burp"][1] = "evt_belch";
	level.exert_sounds[2]["burp"][2] = "evt_belch";

	level.exert_sounds[3]["burp"][0] = "evt_belch";
	level.exert_sounds[3]["burp"][1] = "evt_belch";
	level.exert_sounds[3]["burp"][2] = "evt_belch";
	
	level.exert_sounds[4]["burp"][0] = "evt_belch";
	level.exert_sounds[4]["burp"][1] = "evt_belch";
	level.exert_sounds[4]["burp"][2] = "evt_belch";
	

	// medium hit
	level.exert_sounds[1]["hitmed"][0] = "vox_plr_0_exert_pain_0";
	level.exert_sounds[1]["hitmed"][1] = "vox_plr_0_exert_pain_1";
	level.exert_sounds[1]["hitmed"][2] = "vox_plr_0_exert_pain_2";
	level.exert_sounds[1]["hitmed"][3] = "vox_plr_0_exert_pain_3";
	level.exert_sounds[1]["hitmed"][4] = "vox_plr_0_exert_pain_4";
	
	level.exert_sounds[2]["hitmed"][0] = "vox_plr_1_exert_pain_0";
	level.exert_sounds[2]["hitmed"][1] = "vox_plr_1_exert_pain_1";
	level.exert_sounds[2]["hitmed"][2] = "vox_plr_1_exert_pain_2";
	level.exert_sounds[2]["hitmed"][3] = "vox_plr_1_exert_pain_3";
	level.exert_sounds[2]["hitmed"][4] = "vox_plr_1_exert_pain_4";
	
	level.exert_sounds[3]["hitmed"][0] = "vox_plr_2_exert_pain_0";
	level.exert_sounds[3]["hitmed"][1] = "vox_plr_2_exert_pain_1";
	level.exert_sounds[3]["hitmed"][2] = "vox_plr_2_exert_pain_2";
	level.exert_sounds[3]["hitmed"][3] = "vox_plr_2_exert_pain_3";
	level.exert_sounds[3]["hitmed"][4] = "vox_plr_2_exert_pain_4";
	
	level.exert_sounds[4]["hitmed"][0] = "vox_plr_3_exert_pain_0";
	level.exert_sounds[4]["hitmed"][1] = "vox_plr_3_exert_pain_1";
	level.exert_sounds[4]["hitmed"][2] = "vox_plr_3_exert_pain_2";
	level.exert_sounds[4]["hitmed"][3] = "vox_plr_3_exert_pain_3";
	level.exert_sounds[4]["hitmed"][4] = "vox_plr_3_exert_pain_4";

	// large hit
	level.exert_sounds[1]["hitlrg"][0] = "vox_plr_0_exert_pain_0";
	level.exert_sounds[1]["hitlrg"][1] = "vox_plr_0_exert_pain_1";
	level.exert_sounds[1]["hitlrg"][2] = "vox_plr_0_exert_pain_2";
	level.exert_sounds[1]["hitlrg"][3] = "vox_plr_0_exert_pain_3";
	level.exert_sounds[1]["hitlrg"][4] = "vox_plr_0_exert_pain_4";
	
	level.exert_sounds[2]["hitlrg"][0] = "vox_plr_1_exert_pain_0";
	level.exert_sounds[2]["hitlrg"][1] = "vox_plr_1_exert_pain_1";
	level.exert_sounds[2]["hitlrg"][2] = "vox_plr_1_exert_pain_2";
	level.exert_sounds[2]["hitlrg"][3] = "vox_plr_1_exert_pain_3";
	level.exert_sounds[2]["hitlrg"][4] = "vox_plr_1_exert_pain_4";
	
	level.exert_sounds[3]["hitlrg"][0] = "vox_plr_2_exert_pain_0";
	level.exert_sounds[3]["hitlrg"][1] = "vox_plr_2_exert_pain_1";
	level.exert_sounds[3]["hitlrg"][2] = "vox_plr_2_exert_pain_2";
	level.exert_sounds[3]["hitlrg"][3] = "vox_plr_2_exert_pain_3";
	level.exert_sounds[3]["hitlrg"][4] = "vox_plr_2_exert_pain_4";
	
	level.exert_sounds[4]["hitlrg"][0] = "vox_plr_3_exert_pain_0";
	level.exert_sounds[4]["hitlrg"][1] = "vox_plr_3_exert_pain_1";
	level.exert_sounds[4]["hitlrg"][2] = "vox_plr_3_exert_pain_2";
	level.exert_sounds[4]["hitlrg"][3] = "vox_plr_3_exert_pain_3";
	level.exert_sounds[4]["hitlrg"][4] = "vox_plr_3_exert_pain_4";
}

function giveCustomLoadout( takeAllWeapons, alreadySpawned )
{
	self giveWeapon( level.weaponBaseMelee );
	self zm_utility::give_start_weapon( true );
}

function _custom_add_weapons()
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

function perk_init()
{
	level._effect[JUGGERNAUT_MACHINE_LIGHT_FX] = "zombie/fx_perk_juggernaut_factory_zmb";
	level._effect[QUICK_REVIVE_MACHINE_LIGHT_FX] = "zombie/fx_perk_quick_revive_factory_zmb";
	level._effect[SLEIGHT_OF_HAND_MACHINE_LIGHT_FX] = "zombie/fx_perk_sleight_of_hand_factory_zmb";
	level._effect[DOUBLETAP2_MACHINE_LIGHT_FX] = "zombie/fx_perk_doubletap2_factory_zmb";	
	level._effect[DEADSHOT_MACHINE_LIGHT_FX] = "zombie/fx_perk_daiquiri_factory_zmb";
	level._effect[STAMINUP_MACHINE_LIGHT_FX] = "zombie/fx_perk_stamin_up_factory_zmb";
	level._effect[ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX] = "zombie/fx_perk_mule_kick_factory_zmb";
}


function sndFunctions()
{
	level thread setupMusic();
}

#define PLAYTYPE_REJECT 1
#define PLAYTYPE_QUEUE 2
#define PLAYTYPE_ROUND 3
#define PLAYTYPE_SPECIAL 4
#define PLAYTYPE_GAMEEND 5
function setupMusic()
{
	zm_audio::musicState_Create("round_start", PLAYTYPE_ROUND, "roundstart1", "roundstart2", "roundstart3", "roundstart4" );
	zm_audio::musicState_Create("round_start_short", PLAYTYPE_ROUND, "roundstart_short1", "roundstart_short2", "roundstart_short3", "roundstart_short4" );
	zm_audio::musicState_Create("round_start_first", PLAYTYPE_ROUND, "roundstart_first" );
	zm_audio::musicState_Create("round_end", PLAYTYPE_ROUND, "roundend1" );
	zm_audio::musicState_Create("game_over", PLAYTYPE_GAMEEND, "gameover" );
	zm_audio::musicState_Create("dog_start", PLAYTYPE_ROUND, "dogstart1" );
	zm_audio::musicState_Create("dog_end", PLAYTYPE_ROUND, "dogend1" );
	zm_audio::musicState_Create("timer", PLAYTYPE_ROUND, "timer" );
	zm_audio::musicState_Create("power_on", PLAYTYPE_QUEUE, "poweron" );
}

#namespace zm_usermap_ai; 

//*****************************************************************************
//*****************************************************************************

function autoexec __init()
{
	// DEFAULT(level.pathdist_type,PATHDIST_ORIGINAL);
	
	// // INIT BEHAVIORS
	// InitZmFactoryBehaviorsAndASM();

	// SetDvar( "scr_zm_use_code_enemy_selection", 0 );
	// level.closest_player_override = &factory_closest_player;

	// level thread update_closest_player();
	
	// level.move_valid_poi_to_navmesh = true;
}

function private InitZmFactoryBehaviorsAndASM()
{
	// ------- SERVICES -----------//
	BT_REGISTER_API( "ZmFactoryTraversalService", &ZmFactoryTraversalService);
	
	BT_REGISTER_API( "shouldMoveLowg", &shouldMoveLowg );

	ASM_REGISTER_MOCOMP( "mocomp_idle_special_factory", &mocompIdleSpecialFactoryStart, undefined, &mocompIdleSpecialFactoryTerminate );
}

//*****************************************************************************
//*****************************************************************************

function ZmFactoryTraversalService( entity )
{
	if ( isdefined( entity.traverseStartNode ) )
	{
		entity PushActors( false );
		return true;
	}

	return false;
}	

function private mocompIdleSpecialFactoryStart( entity, mocompAnim, mocompAnimBlendOutTime, mocompAnimFlag, mocompDuration )
{
	if( IsDefined( entity.enemyoverride ) && IsDefined( entity.enemyoverride[1] ) )
	{
		entity OrientMode( "face direction", entity.enemyoverride[1].origin - entity.origin );
		entity AnimMode( AI_ANIM_USE_BOTH_DELTAS_ZONLY_PHYSICS, false );
	}
	else
	{
		entity OrientMode( "face current" );
		entity AnimMode( AI_ANIM_USE_BOTH_DELTAS_ZONLY_PHYSICS, false );
	}
}

function private mocompIdleSpecialFactoryTerminate( entity, mocompAnim, mocompAnimBlendOutTime, mocompAnimFlag, mocompDuration )
{
	
}

function shouldMoveLowg( entity )
{
	return IS_TRUE( entity.low_gravity );
}

//*****************************************************************************
//*****************************************************************************

function private factory_validate_last_closest_player( players )
{
	if ( isdefined( self.last_closest_player ) && IS_TRUE( self.last_closest_player.am_i_valid ) )
	{
		return;
	}

	self.need_closest_player = true;

	foreach( player in players )
	{
		if ( IS_TRUE( player.am_i_valid ) )
		{
			self.last_closest_player = player;
			return;
		}
	}

	self.last_closest_player = undefined;
}

function private factory_closest_player( origin, players )
{
	if ( players.size == 0 )
	{
		return undefined;
	}

	if ( IsDefined( self.zombie_poi ) )
	{
		return undefined;
	}

	if ( players.size == 1 )
	{
		self.last_closest_player = players[0];
		return self.last_closest_player;
	}

	if ( !isdefined( self.last_closest_player ) )
	{
		self.last_closest_player = players[0];
	}

	if ( !isdefined( self.need_closest_player ) )
	{
		self.need_closest_player = true;
	}

	if ( isdefined( level.last_closest_time ) && level.last_closest_time >= level.time )
	{
		self factory_validate_last_closest_player( players );
		return self.last_closest_player;
	}

	if ( IS_TRUE( self.need_closest_player ) )
	{
		level.last_closest_time = level.time;

		self.need_closest_player = false;

		closest = players[0];
		closest_dist = self zm_utility::approximate_path_dist( closest );

		if ( !isdefined( closest_dist ) )
		{
			closest = undefined;
		}

		for ( index = 1; index < players.size; index++ )
		{
			dist = self zm_utility::approximate_path_dist( players[ index ] );
			if ( isdefined( dist ) )
			{
				if ( isdefined( closest_dist ) )
				{
					if ( dist < closest_dist )
					{
						closest = players[ index ];
						closest_dist = dist;
					}
				}
				else
				{
					closest = players[ index ];
					closest_dist = dist;
				}
			}
		}

		self.last_closest_player = closest;
	}

	if ( players.size > 1 && isdefined( closest ) )
	{
		self zm_utility::approximate_path_dist( closest );
	}
		
	self factory_validate_last_closest_player( players );
	return self.last_closest_player;
}

function private update_closest_player()
{
	level waittill( "start_of_round" );

	while ( 1 )
	{
		reset_closest_player = true;
		zombies = zombie_utility::get_round_enemy_array();
		foreach( zombie in zombies )
		{
			if ( IS_TRUE( zombie.need_closest_player ) )
			{
				reset_closest_player = false;
				break;
			}
		}

		if ( reset_closest_player )
		{
			foreach( zombie in zombies )
			{
				if ( isdefined( zombie.need_closest_player ) )
				{
					zombie.need_closest_player = true;
				}
			}
		}

		WAIT_SERVER_FRAME;
	}
}