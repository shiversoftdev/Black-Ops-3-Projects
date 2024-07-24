init_large_map_support()
{
    level.fn_lms_zone_changed = serious::lms_zone_changed;
}

lms_register_cannonical_zones(str_zone1, str_zone2)
{
    if(!isdefined(level.lms_zone_map))
    {
        level.lms_zone_map = [];
    }

    if(!isdefined(level.lms_zone_map[str_zone1]))
    {
        level.lms_zone_map[str_zone1] = [];
    }

    level.lms_zone_map[str_zone1][level.lms_zone_map[str_zone1].size] = str_zone2; // only need to do a one way relationship because the checker for zone changed looks both ways
}

// register the printed title of a zone. zones which are not in this table will be treated as unknown, and a "player has left zone" will be printed
lms_register_zone_title(str_zone, str_location_name)
{
    if(!isdefined(level.lms_zone_titles))
    {
        level.lms_zone_titles = [];
    }

    level.lms_zone_titles[str_zone] = str_location_name;
}

lms_zone_changed(player, str_old_zone, str_new_zone)
{
    if(!(isdefined(str_new_zone) || isdefined(str_old_zone)))
    {
        return; // neither zone is defined, what's the point in checking?
    }

    if(!isdefined(player) || player.sessionstate != "playing")
    {
        return; // player is not in a state where we care about the zone change
    }

    if(player laststand::player_is_in_laststand())
    {
        return; // player should not print zone change on death
    }

    if(isfunctionptr(level.fn_ignore_zone_change) && [[ level.fn_ignore_zone_change ]](player, str_old_zone, str_new_zone))
    {
        player.b_ignore_next_zone_transition = true;
        return; // custom override for things like teleporters
    }

    if(isdefined(str_old_zone) && isdefined(str_new_zone))
    {
        if(level.lms_zone_map[str_old_zone] ?& array::contains(level.lms_zone_map[str_old_zone], str_new_zone))
        {
            return; // still in the same macro-zone
        }

        if(level.lms_zone_map[str_new_zone] ?& array::contains(level.lms_zone_map[str_new_zone], str_old_zone))
        {
            return; // still in the same macro-zone
        }
    }

    // zone is not cannonical. Decide what to do.
    if(str_old_zone ?& !isdefined(str_new_zone))
    {
        // defined zone to undefined
        if(isdefined(level.lms_zone_titles[str_old_zone]))
        {
            lms_print_to_all(player, "^7just ^1exited ^3" + level.lms_zone_titles[str_old_zone] + ".");
        }
        return;
    }

    if(str_new_zone ?& !isdefined(str_old_zone))
    {
        // undefined zone to defined
        if(isdefined(level.lms_zone_titles[str_new_zone]))
        {
            lms_print_to_all(player, "^7just ^2entered ^3" + level.lms_zone_titles[str_new_zone] + ".");
        }
        return;
    }

    // both zones defined, but are their hint messages?
    
    if(level.lms_zone_titles[str_old_zone] ?& isdefined(level.lms_zone_titles[str_new_zone]) && (player.b_ignore_next_zone_transition !== true))
    {
        if(level.lms_zone_titles[str_old_zone] == level.lms_zone_titles[str_new_zone])
        {
            return; // same zone
        }
        // both zones defined
        lms_print_to_all(player, "^7just traveled from ^3" + level.lms_zone_titles[str_old_zone] + " ^7to ^3" + level.lms_zone_titles[str_new_zone]);
        return;
    }

    // undefined zone to defined
    if(isdefined(level.lms_zone_titles[str_new_zone]))
    {
        lms_print_to_all(player, "^7just ^2entered ^3" + level.lms_zone_titles[str_new_zone] + ".");
        return;
    }

    // defined zone to undefined
    if(isdefined(level.lms_zone_titles[str_old_zone]))
    {
        lms_print_to_all(player, "^7just ^1exited ^3" + level.lms_zone_titles[str_old_zone] + ".");
        return;
    }
    
    // both zones are defined but neither zone has a zone title... this only happens when we forget to register a zone mapping.
    // for consistency, we should print a default
    lms_print_to_all(player, "^7is ^3on the move^7!");
}

lms_print_to_all(player, str_message)
{
    player.b_ignore_next_zone_transition = false;
    foreach(e_player in getplayers())
    {
        if(e_player.sessionstate != "playing")
        {
            continue;
        }

        if(e_player == player)
        {
            e_player iprintln("^3" + clean_name(player.name) + " " + str_message);
            continue;
        }

        if(e_player.team == player.team)
        {
            e_player iprintln("^8" + clean_name(player.name) + " " + str_message);
            continue;
        }

        e_player iprintln("^9" + clean_name(player.name) + " " + str_message);
    }
}