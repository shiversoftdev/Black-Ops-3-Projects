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

#using scripts\zm\_load;
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
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

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
#using scripts\zm\_zm_trap_electric;

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

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_widows_wine;

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
#using scripts\zm\_zm_weap_bowie;
#using scripts\zm\_zm_weap_bouncingbetty;
#using scripts\zm\_zm_weap_cymbal_monkey;
#using scripts\zm\_zm_weap_tesla;
#using scripts\zm\_zm_weap_rocketshield;
#using scripts\zm\_zm_weap_gravityspikes;
#using scripts\zm\_zm_weap_annihilator;
#using scripts\zm\_zm_weap_thundergun;
#using scripts\zm\_zm_weap_octobomb;
#using scripts\zm\_zm_weap_raygun_mark3;
#using scripts\zm\_zm_weap_idgun;

//Traps
#using scripts\zm\_zm_trap_electric;

// AI
#using scripts\shared\ai\zombie;
#using scripts\shared\ai\behavior_zombie_dog;
#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_zm_ai_dogs;

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

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\mp\killstreaks\_killstreaks;
#using scripts\mp\killstreaks\_ai_tank;
#using scripts\mp\killstreaks\_counteruav;
#using scripts\mp\killstreaks\_dogs;
#using scripts\mp\killstreaks\_drone_strike;
#using scripts\mp\killstreaks\_killstreak_detect;
#using scripts\mp\killstreaks\_placeables;
#using scripts\mp\killstreaks\_rcbomb;
#using scripts\mp\killstreaks\_satellite;
#using scripts\mp\killstreaks\_uav;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

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
#using scripts\zm\_zm_weap_bowie;
#using scripts\zm\_zm_weap_bouncingbetty;
#using scripts\zm\_zm_weap_cymbal_monkey;
#using scripts\zm\_zm_weap_tesla;

//Traps
#using scripts\zm\_zm_trap_electric;

// AI
#using scripts\shared\ai\zombie;
#using scripts\shared\ai\behavior_zombie_dog;
#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_zm_ai_dogs;

#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\systems\behavior_tree_utility;
#insert scripts\shared\ai\systems\animation_state_machine.gsh;
#insert scripts\shared\ai\systems\behavior.gsh;


//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	level.zbr_is_multiplayer_map = true;

	level.customspawnlogic = &mp_spawnlogic;

	zm_usermap::_main();
	
	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	
	init_zones[0] = "start_zone";
	zone = spawn("trigger_box", (0, 0, 0), 0, 20000, 20000, 20000);
    zone.targetname = "start_zone";
	zone.target = "start_zone_spawners";
	zone.script_noteworthy = "player_volume";
	zone.target_noprefabprefix = "start_zone_spawners";

	level thread zm_zonemgr::manage_zones( init_zones );
	level.zones["start_zone"].volumes[0] = zone;
	zm_zonemgr::reinit_zone_spawners();
	
	level.pathdist_type = PATHDIST_ORIGINAL;

	if(isdefined(level.zbr_start_weapon))
	{
		level.start_weapon = level.zbr_start_weapon;
		level.default_laststandpistol = level.zbr_start_weapon;
   		level.default_solo_laststandpistol = level.zbr_start_weapon_upgraded;
	}

	callback::on_spawned(&mp_spawned);
}

function mp_spawned()
{
	setdvar("doublejump_enabled", 1);
	setdvar("wallrun_enabled", 1);
	setdvar("playerEnergy_wallRunEnergyEnabled", 1);
	setdvar("playerEnergy_enabled", 1);
	setdvar("playerEnergy_slideEnergyEnabled", 0);

	setdvar("wallRun_maxTimeMs_zm", 2000);
	setdvar("playerEnergy_maxReserve_zm", 200);
	setdvar("playerEnergy_maxReserve", 200);
	setdvar("wallRun_peakTest_zm", 0);


	self AllowDoubleJump(true);	
	self AllowWallRun(true);	
	self setdoublejumpenergy(200);

	self endon("disconnect");
	self endon("spawned_player");
	self endon("bled_out");
	for(;;)
	{
		if(self isOnGround() || self IsWallRunning())
		{
			self setdoublejumpenergy(200);
		}
		wait 0.05;
	}
}

function mp_spawnlogic(predictedspawn)
{
	all_spawns = arraycombine(struct::get_array("info_player_start", "targetname"), struct::get_array("mp_dm_spawn", "targetname"), true, false);

	spawnpoint = all_spawns[randomint(all_spawns.size)];

	model = spawn("script_origin", (0, 0, 0));
	while(all_spawns.size)
	{
		model.origin = spawnpoint.origin;

        b_allowed = true;
        foreach(vol in getentarray("trigger_out_of_bounds", "classname"))
        {
            if(model istouching(vol))
            {
                b_allowed = false;
                break;
            }
        }

        if(b_allowed)
        {
            break;
        }

		ArrayRemoveValue(all_spawns, spawnpoint, false);
		spawnpoint = all_spawns[randomint(all_spawns.size)];
	}
	model delete();

	if(!isdefined(spawnpoint))
	{
		self spawn((0, 0, 0), (0, 0, 0), "zsurvival");
		return;
	}

	self.spawned_once_zbr = true;
	self spawn(spawnpoint.origin, spawnpoint.angles, "zsurvival");
}

function usermap_test_zone_init()
{
	level flag::init( "always_on" );
	level flag::set( "always_on" );
}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

#precache( "fx", "misc/fx_zombie_eye_single" );
#precache( "fx", "impacts/fx_flesh_hit" );
#precache( "fx", "misc/fx_zombie_bloodsplat" );
#precache( "fx", "misc/fx_zombie_bloodspurt" );
#precache( "fx", "weapon/bullet/fx_flesh_gib_fatal_01" );
#precache( "fx", "trail/fx_trail_blood_streak" );
#precache( "fx", "zombie/fx_glow_eye_orange" );
#precache( "fx", "zombie/fx_bul_flesh_head_fatal_zmb" );
#precache( "fx", "zombie/fx_bul_flesh_head_nochunks_zmb" );
#precache( "fx", "zombie/fx_bul_flesh_neck_spurt_zmb" );
#precache( "fx", "zombie/fx_blood_torso_explo_zmb" );
#precache( "fx", "trail/fx_trail_blood_streak" );
#precache( "fx", "electric/fx_elec_sparks_directional_orange" );


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

	clientfield::register("world", "game_ended", 1, 1, "int");
	clientfield::register("world", "post_game", 1, 1, "int");
	clientfield::register("playercorpse", "firefly_effect", 1, 2, "int");
	clientfield::register("playercorpse", "annihilate_effect", 1, 1, "int");
	clientfield::register("playercorpse", "pineapplegun_effect", 1, 1, "int");
	clientfield::register("actor", "annihilate_effect", 1, 1, "int");
	clientfield::register("actor", "pineapplegun_effect", 1, 1, "int");
}

function _main()
{
	level._uses_default_wallbuy_fx = 1;
	
	zm::init_fx();
	level util::set_lighting_state( 1 );
	
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
	
	level.giveCustomLoadout =&giveCustomLoadout;
	level.precacheCustomCharacters =&precacheCustomCharacters;
	level.giveCustomCharacters =&giveCustomCharacters;
	level thread setup_personality_character_exerts();
	initCharacterStartIndex();

	//Weapons and Equipment
	level.register_offhand_weapons_for_level_defaults_override = &offhand_weapon_overrride;
	level.zombiemode_offhand_weapon_give_override = &offhand_weapon_give_override;

	DEFAULT(level._zombie_custom_add_weapons,&_custom_add_weapons);
	
	level._allow_melee_weapon_switching = 1;
	
	level.zombiemode_reusing_pack_a_punch = true;

	//Level specific stuff
	include_weapons();

	load::main();

	// DEFAULT(level.dog_rounds_allowed,1);
	// if( level.dog_rounds_allowed )
	// {
	// 	zm_ai_dogs::enable_dog_rounds();
	// }
	
	_zm_weap_cymbal_monkey::init();
	_zm_weap_tesla::init();
	level._round_start_func = &zm::round_start;
	
	level thread sndFunctions();
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

	zm_utility::register_melee_weapon_for_level("bowie_knife");

	zm_utility::register_tactical_grenade_for_level("cymbal_monkey");
	zm_utility::register_tactical_grenade_for_level("octobomb");
	zm_utility::register_tactical_grenade_for_level("octobomb_upgraded");
	
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

function autoexec init()
{
	DEFAULT(level.pathdist_type,PATHDIST_ORIGINAL);
	
	// INIT BEHAVIORS
	InitZmFactoryBehaviorsAndASM();

	SetDvar( "scr_zm_use_code_enemy_selection", 0 );
	level.closest_player_override = &factory_closest_player;

	level thread update_closest_player();
	
	level.move_valid_poi_to_navmesh = true;
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