// generate spawning unified spawns
#define SU_MAPSPAWNS = 0;
#define SU_PAPSPAWNS = 1; // pap only (and if applicable)
#define SU_PERKSPAWNS = 2; // perks and gums
#define SU_WUGSPAWNS = 3; // boxes and wall weapons
#define SU_OTHERSPAWNS = 4; // doors and other misc locations

#define SU_NEEDSTATE_WEAPONS = 0;
#define SU_NEEDSTATE_PAP_OR_AAT = 1;
#define SU_NEEDSTATE_PERKS_OR_GUMS = 2;
#define SU_NEEDSTATE_OBJECTIVE = 3;

// should be impossible to ever run into not having a need state because respawns intrinsically mean things are not going well for you.

su_generate()
{
    if(isdefined(level.su_generated) && level.su_generated)
    {
        return;
    }

    // step 1: generate all spawns and store them in an array
    //         this code should include all default spawns and all POI spawns
    //         auto-cull all the invalid spawns before we do any spawn logic

    level.su_generated = true;
    level.spawning_unified = spawnstruct();
    level.spawning_unified.spawns = [];
    level.spawning_unified.spawns[SU_MAPSPAWNS] = [];
    level.spawning_unified.spawns[SU_PAPSPAWNS] = [];
    level.spawning_unified.spawns[SU_PERKSPAWNS] = [];
    level.spawning_unified.spawns[SU_WUGSPAWNS] = [];
    level.spawning_unified.spawns[SU_OTHERSPAWNS] = [];
    level.spawning_unified.close_to_pap_spawns = [];

    level.su_last_pap_time = gettime();

    if(!isdefined(level.struct_class_names["targetname"]["poi_spawn_point"]))
    {
        level.struct_class_names["targetname"]["poi_spawn_point"] = [];
    }

    if(!isdefined(level.struct_class_names["targetname"]["player_respawn_point"]))
    {
        level.struct_class_names["targetname"]["player_respawn_point"] = [];
    }

    if(level.zbr_is_multiplayer_map is true)
    {
        su_collect_mp_spawns();
    }
    else
    {
        su_collect_map_spawns();
        su_collect_pap_closeby_spawns();
        su_collect_perk_spawns();
        su_collect_wug_spawns();
        su_collect_other_spawns();
    }

    if(DEBUG_SPAWNING_UNIFIED)
    {
        compiler::nprintln("^6map spawns: ^2" + level.spawning_unified.spawns[SU_MAPSPAWNS].size);
        compiler::nprintln("^6pap spawns: ^2" + level.spawning_unified.spawns[SU_PAPSPAWNS].size);
        compiler::nprintln("^6perk spawns: ^2" + level.spawning_unified.spawns[SU_PERKSPAWNS].size);
        compiler::nprintln("^6weapon spawns: ^2" + level.spawning_unified.spawns[SU_WUGSPAWNS].size);
        compiler::nprintln("^6other spawns: ^2" + level.spawning_unified.spawns[SU_OTHERSPAWNS].size);
    }

    s_respawner = spawnstruct();
    s_respawner.targetname = "player_respawn_point";
    s_respawner.target = "poi_spawn_point";
    s_respawner.origin = (0,0,0);
    if(isarray(level.struct_class_names["targetname"]["player_respawn_point"]))
    {
        array::add(level.struct_class_names["targetname"]["player_respawn_point"], s_respawner, false);
    }
}

su_collect_pap_closeby_spawns()
{
    if(!isdefined(level.su_papcloseby_round))
    {
        level.su_papcloseby_round = 0;
    }

    if(level.su_papcloseby_round && (level.su_papcloseby_round == level.round_number))
    {
        return;
    }

    level.su_papcloseby_round = level.round_number;
    su_find_pap_origin();

    if(isdefined(level.su_pap_origin))
    {
        level.spawning_unified.close_to_pap_spawns = [];
        n_max_dist = (1000 * 1000);

        foreach(n_key in array(SU_PAPSPAWNS, SU_WUGSPAWNS, SU_MAPSPAWNS, SU_PERKSPAWNS))
        {
            foreach(s_spawn in level.spawning_unified.spawns[n_key])
            {
                if(distanceSquared(s_spawn.origin, level.su_pap_origin) <= n_max_dist)
                {
                    level.spawning_unified.close_to_pap_spawns[level.spawning_unified.close_to_pap_spawns.size] = s_spawn;
                }
            }
        }
    }
}

su_collect_map_spawns()
{
    respawn_points = struct::get_array("player_respawn_point", "targetname");
    foreach(point in respawn_points)
    {
        if(!isdefined(point) || !isdefined(point.target))
        {
            continue;
        }

        spawn_array = struct::get_array(point.target, "targetname");

        foreach(spawn in spawn_array)
        {
            if(!isdefined(spawn) || !isdefined(spawn.origin))
            {
                continue;
            }

            su_make_spawn(SU_MAPSPAWNS, spawn.origin, true, true);
        }
    }
}

su_collect_pap_spawns()
{
    if(level.b_no_pap_poi === true)
    {
        return;
    }

    foreach(v_pap_spawn in gm_find_pap_origins())
    {
        su_make_spawn(SU_PAPSPAWNS, v_pap_spawn);
    }
}

su_collect_perk_spawns()
{
    if(level.script == "zm_moon") 
    {
        return []; // prevents spawning on area 51
    }

    keys = getarraykeys(level._custom_perks);
    foreach(perk_name in keys)
    {
        perk = level._custom_perks[perk_name];
        if(!isdefined(perk.radiant_machine_name))
        {
            continue;
        }

        ent_array = getentarray(perk.radiant_machine_name, "targetname");
        if(ent_array.size < 1)
        {
            continue;
        }

        foreach(ent in ent_array)
        {
            if(!isdefined(ent.angles) || !isdefined(ent.origin)) 
            {
                continue;
            }

            angles = ent.angles + V_PERK_ANGLE_OFFSET;
            origin = gm_calc_poi_offset(ent.origin, angles);
            if(IS_DEBUG && DEBUG_PERK_ANGLES)
            {
                dev_actor(origin, angles);
            }

            s_spawn = su_make_spawn(SU_PERKSPAWNS, origin);

            if(isdefined(s_spawn))
            {
                s_spawn.perk_name = perk_name;
            }
        }
    }

    foreach(v_gum in gm_find_gum_origins())
    {
        s_spawn = su_make_spawn(SU_PERKSPAWNS, origin);

        if(isdefined(s_spawn))
        {
            s_spawn.perk_name = "bgb";
        }
    }
}

su_collect_wug_spawns()
{
    foreach(v_box in gm_find_box_origins())
    {
        s_spawn = su_make_spawn(SU_WUGSPAWNS, v_box);

        if(isdefined(s_spawn))
        {
            s_spawn.is_box = true;
        }
    }

    foreach(v_wallbuy in gm_find_wallbuy_origins())
    {
        s_spawn = su_make_spawn(SU_WUGSPAWNS, v_wallbuy);

        if(isdefined(s_spawn))
        {
            s_spawn.is_box = false;
        }
    }
}

su_collect_other_spawns()
{
    foreach(v_origin in gm_find_door_origins())
    {
        su_make_spawn(SU_OTHERSPAWNS, v_origin);
    }
}

// will create a spawn struct for spawning unified if the location is acceptible for spawning
su_make_spawn(n_key, v_origin, b_skip_navquery = false, b_is_registered = false)
{
    if(is_point_in_bad_zone(v_origin))
    {
        // zone is blacklisted
        return undefined;
    }

    if(point_bad_by_location(v_origin))
    {
        // point is blacklisted
        return undefined;
    }

    // if it is a POI spawn, we want to check its position to see if it is valid
    if(!b_skip_navquery)
    {
        points = util::positionquery_pointarray(v_origin, 0, 100, 150, 50); // tightening these parameters produces less variance, but it also makes sure people dont spawn in weird spots.

        if(!isdefined(points) || !points.size)
        {
            return undefined;
        }

        points = array::randomize(points);

        b_found = false;
        foreach(potential in points)
        {
            if(ispointonnavmesh(potential, level.players[0]) && zm_utility::check_point_in_playable_area(potential))
            {
                v_origin = potential;
                b_found = true;
                break;
            }
        }

        if(!b_found)
        {
            // couldnt find a good spot to spawn the player here
            return undefined;
        }
    }

    // create the spawn point struct
    s_spawn = spawnstruct();
    s_spawn.origin = v_origin;
    s_spawn.targetname = "poi_spawn_point";
    s_spawn.last_used_time = 0;

    if(!isdefined(level.su_spawn_id))
    {
        level.su_spawn_id = 0;
    }

    s_spawn.id = level.su_spawn_id;

    level.su_spawn_id++;

    // register spawn as real spawn for things like anywhere but here
    if(!b_is_registered && isarray(level.struct_class_names["targetname"]["poi_spawn_point"]))
    {
        array::add(level.struct_class_names["targetname"]["poi_spawn_point"], s_spawn, false);
    }
    
    // register it in the unified spawns table
    level.spawning_unified.spawns[n_key][level.spawning_unified.spawns[n_key].size] = s_spawn;

    return s_spawn;
}

su_select_spawn(player, return_struct = false, ignore_poi = false)
{
    initmaps();
    player on_player_connect();
    player notify("considering_spawnpoint");
    player gm_fix_killcam_vars();

    if(DEBUG_SPAWNING_UNIFIED)
    {
        compiler::nprintln("^6player ^2" + player.name + " ^6 is selecting a spawn (" + return_struct + ")");
    }

    // step 2.a: if the game has curated spawn locations, use them first.
    //         curated spawns must be setup by the gamemode in the initmaps function, and the game must have 4 or less players
    // step 2.b: otherwise, use POI spawning furthest neighbor
    // 
    // as players progress, they can discover other spawns by being within a radius to them
    // for the first 10 rounds, players will spawn only within places they have been. 
    // for the entire game, the algorithm will greatly favor spawns that give the player progression
    // progression states are as follows:
    //      1. Needs new weapons
    //      2. Needs PAP
    //      3. Needs AAT
    //      4. Needs critical perks (DT, Jugg, etc.)
    //      5. Needs to stop another objective holder
    //      
    // note that a player can bypass a progression state (obtaining pap or AAT before a second weapon will push the player past 'needs new weapons')
    // also note that if a given tier has no available spawns, we may spawn the player in another tier forward, or if none are applicable, we use furthest neighbor as default.
    // 
    // other things to consider when spawning:
    //
    //     - cannot spawn a player in a position that would put them within line of sight of another player
    //     - undesirable to spawn too close to other players
    //     - should not spawn a player in the same place multiple times in a row (unless there is no other choice)
    //     - if in duos, should favor spawning them near their teammate

    // until round SU_RAND_SPAWNS_ROUND, we automatically spawn players in only places they have discovered.

    b_is_curated =  (level.gm_spawns.size >= 4) && (getplayers().size <= 4);

    if(DEBUG_SPAWNING_UNIFIED)
    {
        compiler::nprintln("^6player ^2" + player.name + "^6: curated " + b_is_curated);
    }

    if(!isdefined(player.su_discovered_spawns))
    {
        player.su_discovered_spawns = [];
    }

    a_bad_players = [];
    foreach(_player in getplayers())
    {
        if(_player.team == player.team)
        {
            continue;
        }

        if(_player.sessionstate != "playing")
        {
            continue;
        }

        a_bad_players[a_bad_players.size] = _player;
    }

    // if the map has curated spawns and the player does not have a curated spawn zone set, lets setup that curated zone.
    if(b_is_curated && (!isdefined(player.gmspawn) || !isdefined(player.initial_spawn_fix)))
    {
        spawn_zone = level.gm_spawns[player.gm_id % level.gm_spawns.size];
        player.gmspawn = spawn_zone;
        if(DEBUG_SPAWNING_UNIFIED)
        {
            compiler::nprintln("^6player ^2" + player.name + "^6: selected zone ^3" + spawn_zone);
        }

        foreach(s_spawn in su_all_spawns_in_zone(spawn_zone))
        {
            player.su_discovered_spawns[s_spawn.id] = s_spawn;
        }

        if(DEBUG_SPAWNING_UNIFIED)
        {
            compiler::nprintln("^6player ^2" + player.name + "^6: discovered spawns count ^3" + player.su_discovered_spawns.size);
        }

        foreach(s_spawn in array::randomize(player.su_discovered_spawns))
        {
            if(!(player su_spawn_is_safe(s_spawn, a_bad_players)))
            {
                continue;
            }
            player.last_spawn_succeeded = true;
            // s_spawn.last_used_time = gettime();
            return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
        }
    }
    
    b_desperate = false;
    if(!b_is_curated && (!isdefined(player.su_poi_spawn) || !isdefined(player.initial_spawn_fix)))
    {
        // locate a poi spawn using furthest neighbor and mark it as discovered, making it the only valid spawn to choose from until we discover more
        s_spawn = su_furthest_neighbor_expensive(player, false);

        if(isdefined(s_spawn))
        {
            if(DEBUG_SPAWNING_UNIFIED)
            {
                compiler::nprintln("^6player ^2" + player.name + "^6: ^2found a suitable zone for non-curated map");
            }
            player.su_poi_spawn = true;
            player.last_spawn_succeeded = true;
            player.su_discovered_spawns[s_spawn.id] = s_spawn;
            // s_spawn.last_used_time = gettime();
            return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
        }
        
        if(DEBUG_SPAWNING_UNIFIED)
        {
            compiler::nprintln("^6player ^2" + player.name + "^6: ^1couldnt find a suitable zone for non-curated map");
        }
        b_desperate = true;
    }

    // we now have at minimum a list of home spawns discovered

    // next, see if our teammate is spawned in already (if applicable) and try to spawn near them

    if(is_zbr_teambased())
    {
        teammates = player get_zbr_teammates(true);
        if(DEBUG_SPAWNING_UNIFIED)
        {
            compiler::nprintln("^6player ^2" + player.name + "^6: found teammates count ^3" + teammates.size);
        }
        foreach(teammate in teammates)
        {
            if(isdefined(teammate.initial_spawn_fix) && teammate.initial_spawn_fix && !(isdefined(teammate.gm_in_combat) && teammate.gm_in_combat))
            {
                s_spawn = player su_find_spawn_near_player(teammate, 0, true);

                if(isdefined(s_spawn))
                {
                    if(DEBUG_SPAWNING_UNIFIED)
                    {
                        compiler::nprintln("^6player ^2" + player.name + "^6: found teammate spawn");
                    }
                    s_spawn.last_used_time = gettime();
                    return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
                }
            }
        }
        if(DEBUG_SPAWNING_UNIFIED)
        {
            compiler::nprintln("^6player ^2" + player.name + "^6: ^1didnt find a teammate's spawn");
        }
    }

    // next, determine our need state and walk backwards, checking each spawn list for valid locations. Early game uses discovered locations, end game uses any.

    n_need_state = player su_get_needstate();

    ideal_spawns = [];

    if(DEBUG_SPAWNING_UNIFIED)
    {
        compiler::nprintln("^6player ^2" + player.name + "^6: need state ^3" + n_need_state);
    }

    if(n_need_state >= SU_NEEDSTATE_OBJECTIVE)
    {
        // find the player with the objective that has the most progress and try to spawn near them

        most_progress = 0.0; // percent progress
        plr_progress = undefined;
        foreach(_player in getplayers())
        {
            if(_player.gm_objective_state === true)
            {
                progress = _player.gm_objective_timesurvived / _player get_gm_time_to_win();
                if(progress >= most_progress)
                {
                    plr_progress = _player;
                    most_progress = progress;
                }
            }
        }

        if(isdefined(plr_progress))
        {
            s_spawn = su_find_spawn_near_player(plr_progress, su_min_dist_for_prog(most_progress));

            if(isdefined(s_spawn))
            {
                if(DEBUG_SPAWNING_UNIFIED)
                {
                    compiler::nprintln("^6player ^2" + player.name + "^6: ^2found nearby spawn to attack objective holder");
                }
                s_spawn.last_used_time = gettime();
                return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
                // ideal_spawns[ideal_spawns.size] = s_spawn;
            }
        }

        if(DEBUG_SPAWNING_UNIFIED)
        {
            compiler::nprintln("^6player ^2" + player.name + "^6: ^1couldnt find nearby spot for objective holder");
        }
    }

    if(n_need_state >= SU_NEEDSTATE_PERKS_OR_GUMS)
    {
        other_perks = [];
        foreach(s_spawn in level.spawning_unified.spawns[SU_PERKSPAWNS])
        {
            if(level.round_number < SU_RAND_SPAWNS_ROUND)
            {
                if(!isdefined(player.su_discovered_spawns[s_spawn.id]))
                {
                    continue;
                }
            }

            if(!(player su_spawn_is_safe(s_spawn, a_bad_players)))
            {
                continue;
            }

            if(isdefined(s_spawn.perk_name))
            {
                if(isSubStr(s_spawn.perk_name, "armorvest"))
                {
                    if(DEBUG_SPAWNING_UNIFIED)
                    {
                        compiler::nprintln("^6player ^2" + player.name + "^6: ^2wanted a perk and got jugg spawn");
                    }
                    // s_spawn.last_used_time = gettime();
                    // return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
                    ideal_spawns[ideal_spawns.size] = s_spawn;
                }
                if(isSubStr(s_spawn.perk_name, "doubletap"))
                {
                    if(DEBUG_SPAWNING_UNIFIED)
                    {
                        compiler::nprintln("^6player ^2" + player.name + "^6: ^2wanted a perk and got doubletap spawn");
                    }
                    // s_spawn.last_used_time = gettime();
                    // return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
                    ideal_spawns[ideal_spawns.size] = s_spawn;
                }
            }

            other_perks[other_perks.size] = s_spawn;
        }

        if(other_perks.size && !ideal_spawns.size)
        {
            s_spawn = other_perks[randomint(other_perks.size)];
            // s_spawn.last_used_time = gettime();
            // if(DEBUG_SPAWNING_UNIFIED)
            // {
            //     compiler::nprintln("^6player ^2" + player.name + "^6: ^2wanted a perk and got ^3" + s_spawn.perk_name + "^2 spawn");
            // }
            // return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
            ideal_spawns[ideal_spawns.size] = s_spawn;
        }

        if(DEBUG_SPAWNING_UNIFIED)
        {
            compiler::nprintln("^6player ^2" + player.name + "^6: ^1wanted a perk but had no spawns that they could use");
        }
    }

    if(n_need_state >= SU_NEEDSTATE_PAP_OR_AAT && (gettime() - level.su_last_pap_time) >= 10000)
    {
        foreach(s_spawn in array::randomize(level.spawning_unified.spawns[SU_PAPSPAWNS]))
        {
            if(level.round_number < SU_RAND_SPAWNS_ROUND)
            {
                if(!isdefined(player.su_discovered_spawns[s_spawn.id]))
                {
                    continue;
                }
            }

            if(!(player su_spawn_is_safe(s_spawn, a_bad_players)))
            {
                continue;
            }

            if(DEBUG_SPAWNING_UNIFIED)
            {
                compiler::nprintln("^6player ^2" + player.name + "^6: ^2got a pap origin spawn");
            }
            // s_spawn.last_used_time = gettime();
            // return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
            s_spawn.pap = true;
            ideal_spawns[ideal_spawns.size] = s_spawn;
            break;
        }

        su_collect_pap_closeby_spawns();
        foreach(s_spawn in array::randomize(level.spawning_unified.close_to_pap_spawns))
        {
            if(level.round_number < SU_RAND_SPAWNS_ROUND)
            {
                if(!isdefined(player.su_discovered_spawns[s_spawn.id]))
                {
                    continue;
                }
            }

            if(!(player su_spawn_is_safe(s_spawn, a_bad_players)))
            {
                continue;
            }

            if(DEBUG_SPAWNING_UNIFIED)
            {
                compiler::nprintln("^6player ^2" + player.name + "^6: ^2got a nearby pap spawn");
            }
            // s_spawn.last_used_time = gettime();
            // return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
            s_spawn.pap = true;
            ideal_spawns[ideal_spawns.size] = s_spawn;
            break;
        }

        if(DEBUG_SPAWNING_UNIFIED)
        {
            compiler::nprintln("^6player ^2" + player.name + "^6: ^1wanted pap but couldnt find a spawn nearby");
        }
    }

    if(level.round_number >= SU_RAND_SPAWNS_ROUND)
    {
        // needs weapons or none of the other spawns are valid
        a_other_spawns = [];
        foreach(s_spawn in array::randomize(level.spawning_unified.spawns[SU_WUGSPAWNS]))
        {
            if(level.round_number < SU_RAND_SPAWNS_ROUND)
            {
                if(!isdefined(player.su_discovered_spawns[s_spawn.id]))
                {
                    continue;
                }
            }
            
            if(!(player su_spawn_is_safe(s_spawn, a_bad_players)))
            {
                continue;
            }

            if(s_spawn.is_box === true)
            {
                if(DEBUG_SPAWNING_UNIFIED)
                {
                    compiler::nprintln("^6player ^2" + player.name + "^6: ^2wanted a weapon and got a box spawn");
                }
                // s_spawn.last_used_time = gettime();
                // return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
                ideal_spawns[ideal_spawns.size] = s_spawn;
                break;
            }

            a_other_spawns[a_other_spawns.size] = s_spawn;
        }

        if(a_other_spawns.size)
        {
            if(DEBUG_SPAWNING_UNIFIED)
            {
                compiler::nprintln("^6player ^2" + player.name + "^6: ^2 wanted a weapon and got a wall weapon spawn");
            }
            s_spawn = a_other_spawns[0];
            // s_spawn.last_used_time = gettime();
            // return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
            ideal_spawns[ideal_spawns.size] = s_spawn;
        }
    }
    
    if(ideal_spawns.size)
    {
        s_spawn = su_furthest_neighbor_expensive(player, false, false, ideal_spawns);
        s_spawn.last_used_time = gettime();
        if(s_spawn.pap === true)
        {
            level.su_last_pap_time = gettime();
        }
        return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
    }

    foreach(s_spawn in player.su_discovered_spawns)
    {
        if(!(player su_spawn_is_safe(s_spawn, a_bad_players)))
        {
            continue;
        }

        if(DEBUG_SPAWNING_UNIFIED)
        {
            compiler::nprintln("^6player ^2" + player.name + "^6: ^2 got a discovered spawn");
        }
        s_spawn.last_used_time = gettime();
        return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
    }
    
    if(level.round_number >= SU_RAND_SPAWNS_ROUND)
    {
        foreach(s_spawn in array::randomize(level.spawning_unified.spawns[SU_MAPSPAWNS]))
        {
            if(isdefined(player.su_discovered_spawns[s_spawn.id]))
            {
                continue;
            }

            if(!(player su_spawn_is_safe(s_spawn, a_bad_players)))
            {
                continue;
            }

            if(DEBUG_SPAWNING_UNIFIED)
            {
                compiler::nprintln("^6player ^2" + player.name + "^6: ^2 got a map spawn");
            }
            s_spawn.last_used_time = gettime();
            return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
        }
    }

    // if we find no suitable locations (which is only likely in early game) in our discovered locations, switch to desperate furthest neighbor

    if(!b_desperate)
    {
        if(DEBUG_SPAWNING_UNIFIED)
        {
            compiler::nprintln("^6player ^2" + player.name + "^6: ^3 got a last resort furthest neighbor spawn");
        }
        s_spawn = su_furthest_neighbor_expensive(player, false, false);
        s_spawn.last_used_time = gettime();
        return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
    }

    if(DEBUG_SPAWNING_UNIFIED)
    {
        compiler::nprintln("^6player ^2" + player.name + "^6: ^1 no spawns were valid!");
    }

    // if somehow we fail criteria for every spawn location in the map, choose randomly.
    for(i = 0; i < level.spawning_unified.spawns.size; i++)
    {
        if(!level.spawning_unified.spawns[i].size)
        {
            continue;
        }
        s_spawn = level.spawning_unified.spawns[i][randomint(level.spawning_unified.spawns[i].size)];
        s_spawn.last_used_time = gettime();
        return return_struct ? su_get_best_spawn_angles(s_spawn) : s_spawn.origin;
    }

    // ???????? how do we have no spawn points? what happened?!
    return undefined;
}

su_find_pap_origin()
{
    if(isdefined(level.pap_override_spot))
    {
        level.su_pap_origin = level.pap_override_spot;
        return;
    }
    foreach(pap in GetEntArray("pack_a_punch", "script_noteworthy"))
    {
        if(!isdefined(pap.target))
            continue;
        
        ent = GetEnt(pap.target, "targetname");

        if(!isdefined(ent))
            continue;

        if(!isdefined(ent.angles) || !isdefined(ent.origin)) 
        {
            continue;
        }

        level.su_pap_origin = ent.origin;
        return;
    }
    
    foreach(pap in GetEntArray("specialty_weapupgrade", "script_noteworthy"))
    {
        if(!isdefined(pap.target))
            continue;
        
        ent = GetEnt(pap.target, "targetname");

        if(!isdefined(ent))
            continue;

        if(!isdefined(ent.angles) || !isdefined(ent.origin)) 
        {
            continue;
        }

        level.su_pap_origin = ent.origin;
    }
}

// given a float between 0 and 1, return a lerp of min distance representing the closest that a player may respawn to the objective player based on their progress
su_min_dist_for_prog(n_progress)
{
    return lerpfloat(1600, 600, min(1, max(0, sqrt(n_progress))));
}

// returns an integer representing our needstate
su_get_needstate()
{
    if(gm_any_has_objective())
    {
        return SU_NEEDSTATE_OBJECTIVE;
    }

    weapons = [];

    if(isdefined(self.catalyst_loadout))
    {
        foreach(s_item in self.catalyst_loadout)
        {
            if(isdefined(s_item.weapon) && isweapon(s_item.weapon))
            {
                weapons[weapons.size] = s_item.weapon;
            }
        }
    }
    else
    {
        foreach(w_weapon in self getWeaponsListPrimaries())
        {
            weapons[weapons.size] = w_weapon;
        }
    }

    b_has_upgrade = false;
    foreach(weapon in weapons)
    {
        if(weapon.name == (level.zombie_powerup_weapon["minigun"]?.rootweapon?.name ?? "minigun"))
        {
            continue;
        }

        if(weapon.isheroweapon === true)
        {
            continue;
        }

        switch(true)
        {
            case zm_utility::is_hero_weapon(weapon):
            case zm_utility::is_tactical_grenade(weapon):
            case zm_utility::is_melee_weapon(weapon):
            case zm_utility::is_lethal_grenade(weapon):
            case zm_utility::is_placeable_mine(weapon):
            case zm_utility::is_offhand_weapon(weapon):
            break;

            default:
                if(zm_weapons::is_weapon_upgraded(weapon))
                {
                    b_has_upgrade = true;
                }
            break;
        }

        if(b_has_upgrade && isdefined(self.AAT) && isdefined(self.AAT[weapon]))
        {
            return SU_NEEDSTATE_PERKS_OR_GUMS;
        }
    }

    if(b_has_upgrade)
    {
        return SU_NEEDSTATE_PAP_OR_AAT; // needs aat
    }

    if(isdefined(level.start_weapon) && self hasweapon(level.start_weapon))
    {
        return SU_NEEDSTATE_WEAPONS;
    }

    return SU_NEEDSTATE_PAP_OR_AAT; // needs pap
}

// returns true or false
su_spawn_is_safe(s_spawn, a_bad_players, b_ignore_time = false, b_ignore_distance = false)
{
    if(!isdefined(s_spawn.last_used_time))
    {
        s_spawn.last_used_time = 0;
    }
    
    if(!b_ignore_time && s_spawn.last_used_time && (((gettime() - s_spawn.last_used_time) / 1000) < 120))
    {
        return false;
    }
    
    foreach(player in a_bad_players)
    {
        dist = distanceSquared(s_spawn.origin, player.origin);
        if(!b_ignore_distance && dist <= 250000) // 500 * 500
        {
            return false;
        }

        if(BulletTracePassed(player geteye(), s_spawn.origin + (0, 0, 5), true, player))
        {
            return false;
        }

        // check FOV to make sure the spawn isnt being looked at
        if(dist <= 1000000) // 1000 squared
        {
            vtemp = s_spawn.origin - player geteye();
            // angle between player eye and the line from the player's eye to the origin
            dot = abs(vectordot(VectorNormalize(AnglesToForward(player GetPlayerAngles())), VectorNormalize(s_spawn.origin - player geteye())));
            if(dot <= 0.95993) // 55 degrees left or right, 110 total
            {
                return false;
            }
        }
    }

    return true;
}

// call on the player who needs the spawn, passing target_player through params
// returns a struct or undefined based on whether it can find a valid spawn point
// discoverability restrictions apply to spawn points (unless the required round has passed)
su_find_spawn_near_player(target_player, n_min_distance = 0, b_ignore_time = false)
{
    s_closest = undefined;
    n_dist = 999999;
    n_min_distance *= n_min_distance;

    a_bad_players = [];
    foreach(player in getplayers())
    {
        if(player.team == self.team)
        {
            continue;
        }

        if(isdefined(target_player) && player == target_player)
        {
            continue;
        }

        if(player.sessionstate != "playing")
        {
            continue;
        }

        a_bad_players[a_bad_players.size] = player;
    }
    
    if(level.round_number < SU_RAND_SPAWNS_ROUND)
    {
        foreach(s_spawn in target_player.su_discovered_spawns)
        {
            n_other_dist = distanceSquared(s_spawn.origin, target_player.origin);

            if(n_min_distance > n_other_dist)
            {
                continue;
            }

            if(!(self su_spawn_is_safe(s_spawn, a_bad_players, b_ignore_time)))
            {
                continue;
            }

            if(!isdefined(s_closest))
            {
                s_closest = s_spawn;              
                continue;
            }

            if(n_other_dist < n_dist)
            {
                n_dist = n_other_dist;
                s_closest = s_spawn;
            }
        }

        return s_closest; // it is ok that this can be undefined
    }

    // check for a close "enough" spot in order of each of these POI types
    foreach(n_key in array(SU_PERKSPAWNS, SU_WUGSPAWNS, SU_MAPSPAWNS, SU_OTHERSPAWNS))
    {
        foreach(s_spawn in level.spawning_unified.spawns[n_key])
        {
            n_other_dist = distanceSquared(s_spawn.origin, target_player.origin);

            if(n_min_distance > n_other_dist)
            {
                continue;
            }

            if(!(self su_spawn_is_safe(s_spawn, a_bad_players, b_ignore_time, true)))
            {
                continue;
            }

            if(!isdefined(s_closest))
            {
                s_closest = s_spawn;              
                continue;
            }

            if(n_other_dist < n_dist)
            {
                n_dist = n_other_dist;
                s_closest = s_spawn;
            }
        }

        n_target_dist = max(400 * 400, n_min_distance);

        // try to find a spawn location within a target distance that is valid for this type of POI (preferred)
        if(((n_target_dist * 1.5) >= n_dist) && isdefined(s_closest))
        {
            return s_closest;
        }
    }

    return s_closest;
}

su_get_best_spawn_angles(s_spawn)
{
    // Do 8 bullet traces in a pitch circle, from origin + 70 and take the furthest result as the angles for the spawner
    // This should automatically make the player look away from walls, etc.

    if(isdefined(s_spawn.angles))
    {
        return s_spawn;
    }
    
    i_max = 0;
    d_max = 0;
    for(i = 0; i < 8; i++)
    {
        n_angle = (i * (360 / 8)) - 180;
        trace = bullettrace(s_spawn.origin + (0, 0, 70), s_spawn.origin + (0, 0, 70) + VectorScale(anglesToForward((0, n_angle, 0)), 10000), 0, undefined);
        n_dist = distance2d(trace["position"], s_spawn.origin + (0, 0, 70));
        if(n_dist > d_max)
        {
            d_max = n_dist;
            i_max = i;
        }
    }

    n_angle = (i_max * (360 / 8)) - 180;
    s_spawn.angles = (0, n_angle, 0);
    
    return s_spawn;
}

su_furthest_neighbor_expensive(target_player, b_use_discovered_spawns = false, b_no_doors = true, points_override, b_consider_target_player = false)
{
    remaining_points = [];
    if(isdefined(points_override))
    {
        remaining_points = points_override;
    }
    else if(b_use_discovered_spawns)
    {
        foreach(s_spawn in target_player.su_discovered_spawns)
        {
            remaining_points[remaining_points.size] = s_spawn;
        }
    }
    else
    {
        a_n_keys = array(SU_MAPSPAWNS, SU_PAPSPAWNS, SU_PERKSPAWNS, SU_WUGSPAWNS);

        if(!b_no_doors)
        {
            a_n_keys[a_n_keys.size] = SU_OTHERSPAWNS;
        }

        foreach(n_key in a_n_keys)
        {
            foreach(s_spawn in level.spawning_unified.spawns[n_key])
            {
                remaining_points[remaining_points.size] = s_spawn;
            }
        }
    }

    if(!remaining_points.size)
    {
        return undefined;
    }

    solution_set = [];
    foreach(player in array::randomize(getplayers()))
    {
        if(player == target_player && !b_consider_target_player) continue;
        if(player.sessionstate != "playing") continue;
        solution_set[solution_set.size] = player.origin;
    }

    if(solution_set.size < 1)
    {
        solution_set[0] = remaining_points[randomint(remaining_points.size)].origin;
    }

    a_n_distances = [];
    foreach(s_spawn in remaining_points)
    {
        a_n_distances[a_n_distances.size] = int(distancesquared(solution_set[0], s_spawn.origin));
    }

    foreach(k_point, s_spawn in remaining_points)
    {
        foreach(k_ans, v_ans in solution_set)
        {
            a_n_distances[k_point] = int(min(a_n_distances[k_point], distancesquared(s_spawn.origin, v_ans)));
        }
    }

    i_max = 0;
    v_max = 0;
    foreach(k, v in a_n_distances)
    {
        if(v > v_max)
        {
            v_max = v;
            i_max = k;
        }
    }
    
    return remaining_points[i_max];
}

su_discover_locations()
{
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");

    v_origin = self.origin;
    n_max_move_dist_sq = 150 * 150;
    n_max_discover_dist_sq = 300 * 300;
    if(!isdefined(self.su_discovered_spawns))
    {
        self.su_discovered_spawns = [];
    }

    for(;;)
    {
        wait 2;
        if(!isdefined(self.origin))
        {
            continue;
        }
        if(distanceSquared(v_origin, self.origin) <= n_max_move_dist_sq)
        {
            continue;
        }

        v_origin = self.origin;
        foreach(n_key in array(SU_MAPSPAWNS, SU_PAPSPAWNS, SU_PERKSPAWNS, SU_WUGSPAWNS))
        {
            foreach(s_spawn in level.spawning_unified.spawns[n_key])
            {
                if(isdefined(self.su_discovered_spawns[s_spawn.id]))
                {
                    continue;
                }
                if(distanceSquared(s_spawn.origin, v_origin) <= n_max_discover_dist_sq)
                {
                    self.su_discovered_spawns[s_spawn.id] = s_spawn;
                }
            }
        }
    }
}

// returns array of struct spawns that are within the specified zone
su_all_spawns_in_zone(str_zone)
{
    a_s_final_array = [];
    target_zone = level.zones[str_zone];
    foreach(n_key in array(SU_MAPSPAWNS, SU_PAPSPAWNS, SU_PERKSPAWNS, SU_WUGSPAWNS))
    {
        foreach(s_spawn in level.spawning_unified.spawns[n_key])
        {
            if(is_point_inside_zone(s_spawn.origin, target_zone))
            {
                a_s_final_array[a_s_final_array.size] = s_spawn;
            }
        }
    }
    return a_s_final_array;
}

// called when a player needs to be spawned again (corrective action)
try_respawn(no_initial = false)
{
    if(IS_DEBUG && DEBUG_REVERT_SPAWNS) return;
    
    spawn = su_select_spawn(self, true);
    
    if(isdefined(spawn))
    {
        self setVelocity((0,0,0));
        self SetOrigin(spawn.origin);
        self Setplayerangles(spawn.angles);
    }
}

#region OLD SPAWNING
//should only be used at game start
// DEPRECATED DO NOT CALL
GetRandomMapSpawn(player, return_struct = false, ignore_poi = false)
{
    initmaps();

    player on_player_connect();

    if(level.zbr_is_mp is true)
    {
        if(player.spawned_once_zbr is not true)
        {
            player spawn((0, 0, 0), (0, 0, 0), "zsurvival");
            player.spawned_once_zbr = true;
        }
    }

    b_use_poi = !ignore_poi && (isdefined(level.b_use_poi_spawn_system) && level.b_use_poi_spawn_system);

    if((isdefined(player.gmspawn) || b_use_poi) && is_zbr_teambased())
    {
        teammates = player get_zbr_teammates(true);
        if(isdefined(teammates) && isdefined(teammates.size) && teammates.size > 0)
        {
            foreach(teammate in teammates)
            {
                if(isdefined(teammate.initial_spawn_fix) && teammate.initial_spawn_fix && !(isdefined(teammate.gm_in_combat) && teammate.gm_in_combat))
                {
                    spawn = get_player_spawnable_point(teammate, return_struct, ignore_poi);
                    if(isdefined(spawn))
                    {
                        if(return_struct)
                        {
                            spawn.angles ??= player getPlayerAngles();
                        }
                        
                        return spawn;
                    }
                }
            }
        }
    }

    if(b_use_poi)
    {
        spawn = gm_select_poi_spawn(player, return_struct);
        if(spawn ?& return_struct)
        {
            spawn.angles ??= player getPlayerAngles();
        }
        return spawn;
    }

    if(!isdefined(level.gm_spawns) || level.gm_spawns.size < 1)
    {
        player.last_spawn_succeeded = false;
        return undefined;
    }

    if(isdefined(player.gmspawn))
    {
        spawn = GetGMSpawn(player, return_struct);
    }
    
    if(!isdefined(spawn))
    {
        spawn = GetRandStartZone(player, return_struct);
    }
    
    player.last_spawn_succeeded = isdefined(spawn);
    if(spawn ?& return_struct)
    {
        spawn.angles ??= player getPlayerAngles();
    }
    
    return spawn;
}

GetRandStartZone(player, return_struct)
{
    if(!isdefined(level.gm_spawns))
        level.gm_spawns = [];

    if(!isdefined(player.gm_id))
    {
        player on_player_connect();
    }
    
    if(level.gm_spawns.size < 1 && !isdefined(player.gmspawn))
    {
        return GetGMSpawn(player, return_struct, true);
    }
    
    spawn_zone = level.gm_spawns[player.gm_id % level.gm_spawns.size];
    player.gmspawn = spawn_zone;

    if(!isdefined(player.visited_zones))
    {
        player.visited_zones = [];
    }

    return GetSpawnFromZone(player, return_struct, spawn_zone);
}

get_player_spawnable_point(player, return_struct = false, ignore_poi = false)
{
    if(!isdefined(player))
    {
        return undefined;
    }
    
    // 1: check if poi spawns are enabled, if so, find one close to here
    if(!ignore_poi && isdefined(level.b_use_poi_spawn_system) && level.b_use_poi_spawn_system)
    {
        gm_generate_poi_spawns();

        v_closest = undefined;
        n_closest = undefined;
        foreach(v_spawn in level.a_v_poi_spawns)
        {
            n_dist = distancesquared(v_spawn, player.origin);
            if(!isdefined(n_closest) || n_closest > n_dist)
            {
                n_closest = n_dist;
                v_closest = v_spawn;
            }
        }

        if(isdefined(v_closest))
        {
            return return_struct ? gm_poi_get_best_spawn(v_closest) : v_closest;
        }
    }

    // 2: if not, return a zone spawn in the same zone (if it exists)
    zone = player zm_utility::get_current_zone(false);
    if(isdefined(zone))
    {
        spawns = GetAllSpawnsFromZone(zone);
        if(isdefined(spawns) && isdefined(spawns.size) && spawns.size > 0)
        {
            return return_struct ? gm_poi_get_best_spawn(spawns[0].origin) : spawns[0].origin;
        }
    }

    // 3: finally, if still no spawn, return the player's origin, only if it is within the playable space
    if(!zm_utility::check_point_in_playable_area(player getorigin()))
    {
        return GetGMSpawn(self, true, true);
    }

    return return_struct ? gm_poi_get_best_spawn(player getorigin()) : (player getorigin());
}

su_collect_mp_spawns()
{
    all_spawns = arraycombine(struct::get_array("info_player_start", "targetname"), struct::get_array("mp_dm_spawn", "targetname"), true, false);
    model = spawn("script_origin", (0, 0, 0));
    foreach(spawn in all_spawns)
    {
        if(spawn.disabled is true)
        {
            continue;
        }
        
        model.origin = spawn.origin;

        b_allowed = true;
        foreach(vol in getentarray("trigger_out_of_bounds", "classname"))
        {
            if(model istouching(vol))
            {
                b_allowed = false;
                break;
            }
        }

        if(!b_allowed)
        {
            continue;
        }

        spawn spawnpoint_init();
        su_make_spawn(SU_MAPSPAWNS, spawn.origin, true, false);
    }
    model delete();
}

spawnpoint_init()
{
	spawnpoint = self;
	origin = spawnpoint.origin;
	if(level.spawnminsmaxsprimed is not true)
	{
		level.spawnmins = origin;
		level.spawnmaxs = origin;
		level.spawnminsmaxsprimed = true;
	}
	else
	{
		level.spawnmins = math::expand_mins(level.spawnmins, origin);
		level.spawnmaxs = math::expand_maxs(level.spawnmaxs, origin);
	}
	spawnpoint.forward = anglestoforward(spawnpoint.angles);
	spawnpoint.sighttracepoint = spawnpoint.origin + vectorscale((0, 0, 1), 50);
	spawnpoint.inited = true;
}
#endregion