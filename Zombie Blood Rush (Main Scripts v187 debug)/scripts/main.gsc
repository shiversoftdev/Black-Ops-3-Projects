init()
{
    setdvar("sv_cheats", 0);
    if(isdefined(level.__init_gm))
    {
        return;
    }
    level.__init_gm = true;

    mp_auto_spawns();

    if(DISABLE_ISLAND && level.script == "zm_island")
    {
        killserver();
    }

    thread spawn_queue_monitor();

    level.gm_teams = array::randomize(array("allies", "axis", "team4", "team5", "team6", "team7", "team8", "team9"));

    level.playercount ??= [];
    level.alivecount ??= [];
    level.aliveplayers ??= [];
    level.botscount ??= [];
    level.playerlives ??= [];
    level.deadplayers ??= [];
    
    foreach(team in level.gm_teams)
    {
        level.playercount[team] ??= 0;
        level.alivecount[team] ??= 0;
        level.aliveplayers[team] ??= [];
        level.botscount[team] ??= 0;
        level.playerlives[team] ??= 0;
        level.deadplayers[team] ??= [];
    }

    level.gm_team_colors = [];
    level.gm_id = randomint(level.gm_teams.size); // randomint(level.gm_teams.size)

    if(level.fn_zbr_custom_teamsinit is function)
    {
        [[ level.fn_zbr_custom_teamsinit ]]();
    }

    level.spectatetype = 2;
    level.player_too_many_weapons_monitor = false;
    level.player_too_many_weapons_monitor_func = serious::nullsub; // fix bs with their weapons logic
    if(level.givecustomcharacters ?& !isdefined(level._givecustomcharacters))
    {
        level._givecustomcharacters = level.givecustomcharacters;
        level.givecustomcharacters = serious::give_custom_characters;
    }

    level.bettyactivationdelay = 0.5;
    level.bettydamageheight = 200; // from mp
    setdvar("betty_activation_delay", level.bettyactivationdelay);
    setdvar("betty_damage_cylinder_height", level.bettydamageheight);
    level.bettyjumptime = 0.5;
    setdvar("betty_jump_time", 0.5);

    if(STABILITY_PASS)
    {
        SetDvar("developer", "2");
    }
    
    if(not IS_DEBUG or not DEBUG_REVERT_SPAWNS)
    {
        level.check_for_valid_spawn_near_team_callback = serious::su_select_spawn;
    }

    level.zm_core_maps = [ 
        "zm_island", "zm_genesis", "zm_factory", "zm_castle", "zm_asylum",
        "zm_temple", "zm_sumpf", "zm_stalingrad", "zm_prototype", "zm_moon",
        "zm_zod", "zm_tomb", "zm_theater", "zm_cosmodrome"
    ];

    map = tolower(getdvarstring("mapname"));
    if(isinarray(level.zm_core_maps, map) || StrStartsWith(map, "mp_"))
    {
        compiler::wudev_require("zcore", false);
    }
    else
    {
        compiler::wudev_require(map, true);
    }

    init_custom_map();
    initscoreboard();
}

on_player_connect()
{ 
    setdvar("sv_cheats", 0);
    self.am_i_valid = false;
    init();

    if(isdefined(self.gm_id))
    {
        return;
    }

    calc_zbr_ai_count();
    self.gm_objective_completed ??= false;

    self.gm_id = -1;

    if(level.fn_zbr_select_team_auto is undefined)
    {
        if(is_zbr_teambased() and not (self istestclient()))
        {
            self.gm_id = compiler::getexpectedteam(self getxuid(false));
            
            if(self.gm_id > 0)
            {
                self.gm_id--;
            }

            if(self.gm_id > 2)
            {
                self.gm_id--;
            }
        }

        if(self.gm_id < 0)
        {
            teams = gm_get_free_teams();
            if(teams.size < 1)
            {
                teams[0] = 0; // fallback but wtf?
            }

            foreach(team in teams)
            {
                count = get_num_team_players(team);
                if(count > 0)
                {
                    self.gm_id = team;
                }
                break;
            }
            
            if(self.gm_id < 0)
            {
                self.gm_id = teams[randomint(teams.size)];
            }
        }
    }
    else
    {
        self [[ level.fn_zbr_select_team_auto ]]();
    }

    self.noHitMarkers = false;

    if(!isdefined(level.gm_team_colors[self.gm_id]))
    {
        level.gm_team_colors[self.gm_id] = self getEntityNumber();
    }

    if(getdvarint("com_maxclients", ZBR_MAX_PLAYERS) > ZBR_MAX_PLAYERS)
    {
        level.b_use_poi_spawn_system = true;
    }
    
    if(self ishost())
    {
        initgamemode();
    }

    self thread gm_watch_deaths();
    self thread respawn_enter_queue();
}

gm_watch_deaths()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("bled_out");
        self.deaths++;
        self.pers["deaths"] = self.deaths;
    }
}

gm_get_free_teams()
{
    free_teams = [];
    players_cap = (is_zbr_teambased() ? get_zbr_teamsize() : 1);
    max_players = getdvarint("com_maxclients", ZBR_MAX_PLAYERS);
    num_teams = 8;

    for(i = 0; i < num_teams; i++)
    {
        n_players = get_num_team_players(i);
        if(n_players >= players_cap)
        {
            continue;
        }
        free_teams[free_teams.size] = i;
    }

    return free_teams;
}

get_num_team_players(gm_id = 0)
{
    n_count = 0;
    foreach(player in getplayers())
    {
        if(isdefined(player.gm_id) && player.gm_id == gm_id)
        {
            n_count++;
        }
    }
    return n_count;
}

GetSpawnTeamID()
{
    return self.gm_id + 3;
}

get_fixed_team_name()
{
    return level.gm_teams[self.gm_id % level.gm_teams.size];
}

on_player_spawned()
{
    setdvar("sv_cheats", 0);
    self endon("disconnect");
    self on_player_connect();
    
    self SetGMTeam(self GetGMTeam());

    if(FORCE_HOST && self ishost())
    {
        SetDvar("excellentPing", 3);
        SetDvar("goodPing", 4);
        SetDvar("terriblePing", 5);
        SetDvar("migration_forceHost", 1);
        SetDvar("migration_minclientcount", 12);
        SetDvar("party_connectToOthers", 0);
        SetDvar("party_dedicatedOnly", 0);
        SetDvar("party_dedicatedMergeMinPlayers", 12);
        SetDvar("party_forceMigrateAfterRound", 0);
        SetDvar("party_forceMigrateOnMatchStartRegression", 0);
        SetDvar("party_joinInProgressAllowed", 1);
        SetDvar("allowAllNAT", 1);
        SetDvar("party_keepPartyAliveWhileMatchmaking", 1);
        SetDvar("party_mergingEnabled", 0);
        SetDvar("party_neverJoinRecent", 1);
        SetDvar("party_readyPercentRequired", 0.25);
        SetDvar("partyMigrate_disabled", 1);
        SetDvar("party_connectToOthers" , "0");
        SetDvar("partyMigrate_disabled" , "1");
        SetDvar("party_mergingEnabled" , "0");
    }

    if(!self ishost())
    {
        while(!isdefined(level.game_mode_init) || !level.game_mode_init)
        {
            wait 0.5;
        }
    }

    if(level.script == "zm_cosmodrome" && !isdefined(level.cosmodrome_lander_initial_wait))
    {
        level flag::wait_till("lander_grounded");
        level.cosmodrome_lander_initial_wait = true;
    }

    if(level.fn_wait_spawned is function)
    {
        self [[ level.fn_wait_spawned ]]();
    }

    self thread GMSpawned();

    wait 0.1;
    self notify("stop_player_too_many_weapons_monitor");
    self notify("stop_player_out_of_playable_area_monitor");

    if(self.initial_spawn_fix is undefined)
    {
        waittillframeend;
        wait 0.05;
        self Try_Respawn();
        self.initial_spawn_fix = true;
    }

    foreach(player in level.players) player GM_CreateHUD();
}

update_lobbystate()
{
    level notify("update_lobbystate");
    level endon("update_lobbystate");
    wait 2;
    compiler::replobbystate();
}