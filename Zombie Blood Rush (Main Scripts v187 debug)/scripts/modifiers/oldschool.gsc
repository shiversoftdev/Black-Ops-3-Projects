#define GM_OS_RARITY_NORMAL = 0; // default
#define GM_OS_RARITY_RARE = 2;
#define GM_OS_RARITY_VERYRARE = 4;
#define GM_OS_RARITY_ULTRARARE = 6;
#define GM_OS_RARITY_DONTDROP = 8;

gm_os_init()
{
    level.zbr_gm_osguns = [];
    level.zbr_gm_osguninfo = [];
}

gm_os_aat(weapon)
{
    s_aatweapon = spawnstruct();
    s_aatweapon.weapon = getweapon(weapon);
    s_aatweapon.is_aat = true;
    return s_aatweapon;
}

gm_os_run()
{
    level endon("end_game");
    for(;;)
    {
        foreach(s_gun in level.zbr_gm_osguns)
        {
            if(s_gun.next <= gettime())
            {
                s_gun gm_os_select_gun();
            }
        }
        wait 1;
    }
}

gm_os_mark_spawns(origins)
{
    foreach(spawn in origins)
    {
        gm_os_try_spawn_osgun(spawn);
    }
}

gm_os_register_weapon(str_weapon, str_upgrade, str_upgrade2, rarityclass = GM_OS_RARITY_NORMAL, pricebias = 1.0, round_enable = 1, b_is_wonder_weapon = false)
{
    if(level.zbr_gm_osguninfo is undefined || (str_weapon is undefined) || (str_weapon is not string))
    {
        return;
    }

    weapon = getweapon(str_weapon);
    upgrade = (str_upgrade is defined) ? getweapon(str_upgrade) : undefined;

    if(isstring(str_upgrade2))
    {
        upgrade2 = (str_upgrade2 is defined) ? getweapon(str_upgrade2) : undefined;
    }
    else
    {
        upgrade2 = str_upgrade2;
    }
    
    level.zbr_gm_osguninfo[weapon] = spawnstruct();
    level.zbr_gm_osguninfo[weapon].upgrades = array(weapon, upgrade, upgrade2);
    level.zbr_gm_osguninfo[weapon].rarity = rarityclass;
    level.zbr_gm_osguninfo[weapon].pricebias = pricebias; 
    level.zbr_gm_osguninfo[weapon].round = round_enable;
    level.zbr_gm_osguninfo[weapon].b_is_wonder_weapon = b_is_wonder_weapon;
}

gm_os_debugmode()
{
    self endon("spawned_player");
    for(;;)
    {
        self waittill("weapon_fired");
        if(self adsButtonPressed())
        {
            v_direction = anglestoforward(self getplayerangles());
            v_forward = vectorscale(v_direction, 1000);
            v_hit = bullettrace(self geteye(), (self geteye()) + v_forward, true, self, true, true)["position"];
            if(v_hit is undefined)
            {
                continue;
            }

            v_hit += (0, 0, 50);

            results = gm_os_try_spawn_osgun(v_hit);
            if(!results["success"])
            {
                gm_os_try_move_osgun(v_hit);
                continue;
            }
            
            results["gun"] gm_os_select_gun();
            
            wait 1;
        }
    }
}

osgun_visibility_check(player)
{
    b_result = true;

    if(self.stub.osgun.b_active is not true)
    {
        self sethintstring("");
        return false;
    }

    if(player.sessionstate != "playing")
    {
        self sethintstring("");
        return false;
    }

    if(!player zm_magicbox::can_buy_weapon())
    {
        self sethintstring("");
        return false;
    }

    self sethintstring("Hold ^3&&1 ^7to purchase weapon [Cost:" + self.stub.osgun.zombie_cost + "]");
    return b_result;
}

osgun_trigger_think()
{
    for(;;)
    {
        self waittill("trigger", player);
        if(!self.stub.osgun.b_active)
        {
            continue;
        }
        if(player zm_utility::in_revive_trigger())
		{
			continue;
		}
		if(!zm_utility::is_player_valid(player, false, true))
		{
			continue;
		}
        if(!player zm_magicbox::can_buy_weapon())
        {
            continue;
        }
        if(!player zm_score::can_player_purchase(self.stub.osgun.zombie_cost))
        {
            zm_utility::play_sound_at_pos("no_purchase", self.stub.osgun.origin);
            continue;
        }
        player zm_score::minus_to_player_score(self.stub.osgun.zombie_cost);

        if(self.stub.osgun.w_weapon.is_aat is true)
        {
            player zm_weapons::weapon_give(self.stub.osgun.w_weapon.weapon, true, true, false, true);
            player aat::acquire(self.stub.osgun.w_weapon.weapon);
        }
        else
        {
            player zm_weapons::weapon_give(self.stub.osgun.w_weapon, true, true, false, true);
        }
        self.stub.osgun.b_active = false;
        self.stub.osgun.w_weapon = undefined;
        self.stub.osgun setmodel("tag_origin");
        self.stub.osgun stoploopsound("zmb_spawn_powerup_loop");
        playfx(level._effect["powerup_grabbed_caution"], self.stub.osgun.origin);
        self.stub.osgun ghost();
    }
}

gm_os_select_gun()
{
    if(level.zbr_gm_osguninfo is undefined or !level.zbr_gm_osguninfo.size)
    {
        return;
    }

    if(self.b_active is not true)
    {
        self notify("powerup_grabbed");
        self show();
        self.b_active = true;

        self.only_affects_grabber = false;
        self.any_team = true;
        self thread zm_powerups::powerup_wobble();
        self playloopsound("zmb_spawn_powerup_loop");
        
        if(!isdefined(self.trig))
        {
            stub = self zm_unitrigger::create_unitrigger("", 128, serious::osgun_visibility_check, serious::osgun_trigger_think, "unitrigger_radius_use");
            zm_unitrigger::unitrigger_force_per_player_triggers(stub, true);
            stub.osgun = self;
            self.trig = stub;
        }        
    }

    // a_w_existing = [];
    // foreach(s_gun in level.zbr_gm_osguns)
    // {
    //     if(s_gun.w_weapon is undefined)
    //     {
    //         continue;
    //     }
    //     a_w_existing[a_w_existing.size] = zm_weapons::get_base_weapon(s_gun.w_weapon);
    // }
    
    a_w_free = [];
    foreach(gun in getArrayKeys(level.zbr_gm_osguninfo))
    {
        if(level.zbr_gm_osguninfo[gun].round > level.round_number)
        {
            continue;
        }
        for(i = 0; i < (GM_OS_RARITY_DONTDROP - level.zbr_gm_osguninfo[gun].rarity); i++)
        {
            a_w_free[a_w_free.size] = gun;
        }
    }

    w_select = a_w_free[randomint(a_w_free.size)];

    if(randomIntRange(0, 100) < 5)
    {
        w_select = undefined;
    }

    if(w_select is undefined)
    {
        self.w_weapon = undefined;
        self setmodel("tag_origin");
        playfx(level._effect["powerup_grabbed_caution"], self.osgun.origin);
        self ghost();
        self stoploopsound("zmb_spawn_powerup_loop");
        self.next = (gettime() + (randomIntRange(120, 180) * 1000)) as int;
        self.zombie_cost = 0;
        self.b_active = false;
        return;
    }

    i_upgrade_level = gm_os_should_upgrade();

    if(level.zbr_gm_osguninfo[w_select].upgrades[2] is undefined && (i_upgrade_level == 2))
    {
        i_upgrade_level--;
    }

    if(level.zbr_gm_osguninfo[w_select].upgrades[1] is undefined && (i_upgrade_level == 1))
    {
        i_upgrade_level--;
    }

    switch(i_upgrade_level)
    {
        case 0:
            self.only_affects_grabber = true;
            self.any_team = false;
            break;
        case 2:
            self.only_affects_grabber = false;
            self.any_team = true;
            break;
        case 1:
            self.only_affects_grabber = false;
            self.any_team = false;
            self.zombie_grabbable = false;
            break;
    }

    if(level.zbr_gm_osguninfo[w_select].b_is_wonder_weapon)
    {
        self.only_affects_grabber = false;
        self.any_team = false;
        self.zombie_grabbable = true;
    }

    self notify("powerup_grabbed");
    self thread zm_powerups::powerup_wobble();
    self.w_weapon = level.zbr_gm_osguninfo[w_select].upgrades[i_upgrade_level];
    self.zombie_cost = gm_os_calc_cost(level.zbr_gm_osguninfo[w_select].pricebias, i_upgrade_level);
    self.next = (gettime() + (randomIntRange(120, 180) * 1000)) as int;
    options = level.players[randomint(level.players.size)] calcweaponoptions(0, 0, 0);
    self useweaponmodel(w_select, w_select.worldmodel, options);
    playsoundatposition("zmb_spawn_powerup", self.origin);
}

gm_os_calc_cost(pricebias = 1.0, i_upgrade = 0)
{
    round_biased = (CLAMPED_ROUND_NUMBER * pricebias * pricebias) as int;
    base_biased = (round_biased / ROUND_DELTA_SCALAR) as int;
    base_biased++;
    base_biased = int(min(5, base_biased));
    desired = max((pow(2, base_biased) * (250 * (1 + 3 * i_upgrade))), i_upgrade ? ((i_upgrade > 1) ? 10000: 5000) : 500) as int;
    if(!i_upgrade)
    {
        return int(min(desired, 2500));
    }
    if(i_upgrade == 1)
    {
        return int(min(desired, 10000));
    }
    return int(min(desired, 20000));
}

gm_os_should_upgrade()
{
    if(level.gm_os_upgrade2 is true)
    {
        b_ug1 = randomintrange(min(90, (CLAMPED_ROUND_NUMBER / 15) * 90) as int, 100) >= 90;
        b_ug2 = b_ug1 && (randomintrange(min(90, (CLAMPED_ROUND_NUMBER / 25) * 90) as int, 100) >= 90);
        return b_ug2 + b_ug1;
    }
    return randomintrange(min(90, (CLAMPED_ROUND_NUMBER / 20) * 90) as int, 100) >= 90;
}

gm_os_try_spawn_osgun(origin)
{
    if(gm_os_try_find_nearby_osgun(origin) is defined)
    {
        return associativearray("success", false);
    }
    
    s_osgun = spawn("script_model", origin);
    s_osgun setmodel("tag_origin");
    s_osgun.next = gettime();
    s_osgun.b_active = false;
    s_osgun.zombie_cost = gm_os_calc_cost();
    s_osgun.w_weapon = undefined;

    level.zbr_gm_osguns[level.zbr_gm_osguns.size] = s_osgun;

    gm_os_printguns();

    return associativearray("success", true, "gun", s_osgun);
}

gm_os_try_move_osgun(origin)
{
    nearby = gm_os_try_find_nearby_osgun(origin);
    if(nearby is undefined)
    {
        return false;
    }

    if(distance(nearby.origin, origin) <= 5)
    {
        gm_os_remove_osgun(nearby);
        return;
    }

    nearby.origin = origin;
}

gm_os_try_find_nearby_osgun(origin)
{
    valid = array::get_all_closest(origin, level.zbr_gm_osguns, undefined, 1, 100);
    if(!valid.size)
    {
        return undefined;
    }
    return valid[0];
}

gm_os_remove_osgun(osgun)
{
    ArrayRemoveValue(level.zbr_gm_osguns, osgun, false);
    
    osgun delete();

    gm_os_printguns();
}

gm_os_printguns()
{
    if(IS_DEBUG && DEBUG_GM_OS)
    {
        toprint = "";
        foreach(osg in level.zbr_gm_osguns)
        {
            toprint += "(" + osg.origin[0] + "," + osg.origin[1] + "," + osg.origin[2] + "), ";
        }

        compiler::nprintln(toprint);
    }
}