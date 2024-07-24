#using scripts\codescripts\struct;
#using scripts\shared\ai\animation_selector_table_evaluators;
#using scripts\shared\ai\archetype_cover_utility;
#using scripts\shared\ai\archetype_damage_effects;
#using scripts\shared\ai\archetype_locomotion_utility;
#using scripts\shared\ai\archetype_mocomps_utility;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\behavior_state_machine_planners_utility;
#using scripts\shared\ai\zombie;
#using scripts\shared\animation_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\math_shared;
#using scripts\shared\player_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\util_shared;

#namespace core_frontend_fx;
#using_animtree("all_player");

function private autoexec precache_anims()
{
}

function main()
{
	level.xcam_origin = (-4325.3, 2021.68, 25);
	level.xcam_angles = (-30, 125 + 96.7579, 42);
	//visionset_mgr::register_info("visionset", "zm_zbr_frontend", 1, 31, 1, 1);
    thread test_frontend();

	thread frontend_vision();
}

function frontend_vision()
{
	for(;;)
	{
		players = getplayers();
		if(players.size > 0)
		{
			break;
		}
		wait 0.05;
	}

	visionsetnaked("zm_zbr_frontend", 0);
}

function private test_frontend()
{
    //wait 10;
    while(true)
    {
        wait 0.05;
        players = getplayers();
        if(players.size < 1)
        {
            continue;
        }
		// players[0] spawn(level.xcam_origin, level.xcam_angles);
        players[0] thread test_host();
        break;
    }
}

function private test_host()
{
	self endon("disconnect");
	self endon("joined_spectators");
	self notify("spawned");
	level notify("player_spawned");
	self notify("end_respawn");
	self luinotifyevent(&"player_spawned", 0);
	self.sessionteam = self.team;
	hadspawned = self.hasspawned;
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.statusicon = "";
	self.damagedplayers = [];
	self.maxhealth = 100;
	self.health = self.maxhealth;
	self.friendlydamage = undefined;
	self.hasspawned = 1;
	self.spawntime = gettime();
	self.afk = 0;
	self.laststand = undefined;
	self.revivingteammate = 0;
	self.burning = undefined;
	self.nextkillstreakfree = undefined;
	self.activeuavs = 0;
	self.activecounteruavs = 0;
	self.activesatellites = 0;
	self.deathmachinekills = 0;
	self.disabledweapon = 0;
	self.diedonvehicle = undefined;
	self setdepthoffield(0, 0, 512, 512, 4, 0);
	self resetfov();
	if(isdefined(level.playerspawnedcb))
	{
		self [[level.playerspawnedcb]]();
	}
	self.sensorgrenadedata = undefined;

	self setcharacterbodytype(4);
	self setcharacterbodystyle(0);
	self setcharacterhelmetstyle(0);
	self setmovespeedscale(1);
	self setsprintduration(4);
	self setsprintcooldown(0);

    self disableWeapons();
    self freezeControls(false);
	
	self notify("spawned_player");
	if(!getdvarint("art_review", 0))
	{
		callback::callback(#"hash_bc12b61f");
	}

	setdvar("scr_selecting_location", "");

	self util::set_lighting_state();
	self util::set_sun_shadow_split_distance();
	self util::streamer_wait(undefined, 0, 5);
	self setorigin(level.xcam_origin);
	self setPlayerAngles(level.xcam_angles);
	self SetPlayerGravity(0);
	self.originObj = spawn( "script_origin", self.origin, 1 );
	self.originObj.angles = self.angles;
	self PlayerLinkTo( self.originObj, undefined );

	for(;;)
	{
		self setPlayerAngles(level.xcam_angles);
		self resetfov();
		self.originObj.origin = level.xcam_origin;
		wait 0.05;
	}
	// self spawn(self.origin, self.angles);
    // self thread no_clip();
}

function private no_clip()
{
    self thread print_origin_angles();
    level endon("game_ended");
    level endon("end_game");
    
    player = self;
    player endon("disconnect");
    player endon("bled_out");

    if(!isdefined(player))
        return;
    
	player iprintlnbold("^2Press [{+frag}] ^3to ^2Toggle No Clip");

	normalized = undefined;
	scaled = undefined;
	originpos = undefined;
	player unlink();

    if(isdefined(player.originObj))
    {
        player.originObj delete();
    }

    // foreach(ent in getentarray())
    // {
    //     data = "";
    //     if(isdefined(ent.name))
    //     {
    //         data += "name: " + ent.name + " ";
    //     }
    //     if(isdefined(ent.script_noteworthy))
    //     {
    //         data += "sn: " + ent.script_noteworthy+ " ";
    //     }
    //     if(isdefined(ent.targetname))
    //     {
    //         data += "tn: " + ent.targetname+ " ";
    //     }
    //     if(isdefined(ent.target))
    //     {
    //         data += "t: " + ent.target + " ";
    //     }
    //     if(isdefined(ent.script_string))
    //     {
    //         data += "ss: " + ent.script_string + " ";
    //     }
    //     iPrintLnBold(data);
    // }

	for(;;)
	{
		if(player fragbuttonpressed())
		{
			player.originObj = spawn( "script_origin", player.origin, 1 );
    		player.originObj.angles = player.angles;
			player PlayerLinkTo( player.originObj, undefined );

			while( player fragbuttonpressed() )
				wait 0.05;
			
            player iprintlnbold("No Clip ^2Enabled");
            player iPrintLnBold("[{+breath_sprint}] to move");

			player disableWeapons();
            player EnableWeaponCycling();
            player giveWeapon(getweapon("sniper_fastbolt"));
            player giveMaxAmmo(getweapon("sniper_fastbolt"));
            player switchToWeapon(getweapon("sniper_fastbolt"));
			for(;;)
			{
				if( player fragbuttonpressed() )
					break;
                
				if( player SprintButtonPressed() )
				{
					normalized = AnglesToForward(player getPlayerAngles());
					scaled = vectorScale( normalized, 60 );
					originpos = player.origin + scaled;
					player.originObj.origin = originpos;
				}
				wait 0.05;
			}

			player unlink();
			player.originObj delete();

			player iprintlnbold("No Clip ^1Disabled");

			while( player fragbuttonpressed() )
				wait 0.05;
		}
		wait 0.05;
	}
}

function private print_origin_angles()
{
    self endon("disconnect");
    self endon("bled_out");
    level endon("game_ended");
    level endon("end_game");

    for(;;)
    {
        if(self meleeButtonPressed())
        {
            iPrintLnBold("" + (self getPlayerAngles()));
            iPrintLnBold("" + (self getorigin()));
            while(self meleeButtonPressed())
            {
                wait 0.05;
            }
        }
        wait 0.05;
    }
}
