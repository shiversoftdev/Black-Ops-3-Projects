#define WAGER_MIN_LEVEL = 1;
#define WAGER_MAX_LEVEL = 10;
#define WAGER_GM1_GG_TIME = 10;
#define WAGER_GM2_PTIMER = 5;
#define PERK_PAUSE_TIME = 10;

init_wager_totems()
{
    add_wager_tier(1, "Challenger I",   2.0);
    add_wager_tier(2, "Challenger II",  3.0);
    add_wager_tier(3, "Expert I",       4.0);
    add_wager_tier(4, "Expert II",      5.0);
    add_wager_tier(5, "Master",         10.0);
    add_wager_tier(6, "Grandmaster I",  10.0);
    add_wager_tier(7, "Grandmaster II",  10.0);
    add_wager_tier(8, "Grandmaster III",  10.0);
    add_wager_tier(9, "Grandmaster IV",  10.0);
    add_wager_tier(10, "^1Blood Hunter",  10.0);

    add_wager_modifier(1, "earn fewer points from zombies",                                                                                                                         serious::wager_zm_points);
    add_wager_modifier(1, "take more damage from zombies",                                                                                                                          serious::wager_zm_incoming_damage);
    add_wager_modifier(1, "deal less damage to zombies",                                                                                                                            serious::wager_zm_outgoing_damage);

    add_wager_modifier(2, "earn fewer points from enemy players",                                                                                                                   serious::wager_pvp_points);
    add_wager_modifier(2, "take more damage from enemy players",                                                                                                                    serious::wager_pvp_incoming_damage);
    add_wager_modifier(2, "deal less damage to enemy players",                                                                                                                      serious::wager_pvp_outgoing_damage);
    
    // add_wager_modifier(3, "forfeit the ability to purchase gobblegums",                                                                                                             serious::wager_bgb_pack,                serious::gums_present);
    add_wager_modifier(3, "replace gumball cycling with random selection",                                                                                                          serious::wager_bgb_pack_cycle,          serious::gums_present);
    add_wager_modifier(3, "forfeit a weapon slot (keep current weapon)",                                                                                                            serious::wager_weapon_slot);
    add_wager_modifier(3, "forfeit the ability to use tacticals and specialist weapons",                                                                                            serious::wager_weapon_types);

    add_wager_modifier(4, "inflict no melee damage to enemy players",                                                                                                               serious::wager_pvp_melee_damage);
    add_wager_modifier(4, "forfeit the ability to grab powerups",                                                                                                                   serious::wager_powerups);
    // add_wager_modifier(4, "take 100 points of damage per second while sprinting",                                                                                                serious::wager_sprinting);
    add_wager_modifier(4, "forfeit the ability to slide",                                                                                                                           serious::wager_sliding);

    add_wager_modifier(5, "significantly increase the amount of points required for you to win.\nYou will take much more damage from players while above the normal winning score.",   serious::wager_win);

    add_wager_modifier(6, "be forced to take a copy of any weapon rolled from the box",                                                                                             serious::wager_box_options,             serious::boxes_present,             "Weapons consume ammo half as quickly. Gain an additional Elo transfer bonus.");
    add_wager_modifier(6, "acquire a new weapon after each kill.\nLimited to once per " + WAGER_GM1_GG_TIME + " seconds",                                                           serious::wager_gun_game,                undefined,                          "Weapons consume ammo half as quickly. Gain an additional Elo transfer bonus.");
    add_wager_modifier(6, "acquire a new set of weapons each round",                                                                                                                serious::wager_loadout_rounds,          undefined,                          "Weapons consume ammo half as quickly. Gain an additional Elo transfer bonus.");

    add_wager_modifier(7, "lose a perk " + WAGER_GM2_PTIMER + " minutes after acquiring it",                                                                                        serious::wager_perk_lifetime,           undefined,                          "Downing a player awards you their perks. Gain an additional Elo transfer bonus.");
    add_wager_modifier(7, "toggle a perk on/off when another player acquires it",                                                                                                   serious::wager_perk_toggler,            undefined,                          "Downing a player awards you their perks. Gain an additional Elo transfer bonus.");
    add_wager_modifier(7, "have your perks disabled for " + PERK_PAUSE_TIME + " seconds if you are attacked by a zombie",                                                           serious::wager_perk_disabler,           undefined,                          "Downing a player awards you their perks. Gain an additional Elo transfer bonus.");

    add_wager_modifier(8, "drop live grenades occasionally when zombies die",                                                                                                       serious::wager_zomb_nades,              undefined,                          "Recieve a gold bowie knife which one hit melees forever (against zombies)");
    add_wager_modifier(8, "deal more damage to zombie heads; less to all else",                                                                                                     serious::wager_precision,               undefined,                          "Recieve a gold bowie knife which one hit melees forever (against zombies)");
    add_wager_modifier(8, "award other players some of the points you lose from zombies",                                                                                           serious::wager_bonus_zm_points,         undefined,                          "Recieve a gold bowie knife which one hit melees forever (against zombies)");

    add_wager_modifier(9, "take more damage from enemy players as they get closer to you",                                                                                          serious::wager_proximity,               undefined,                          "Leech points from nearby players");
    add_wager_modifier(9, "occasionally give bonus points to enemy players when you are attacked",                                                                                  serious::wager_bonus_mp_points,         undefined,                          "Leech points from nearby players");
    add_wager_modifier(9, "grant powerups to all players when you grab them",                                                                                                       serious::wager_powerup_all,             serious::powerup_wager_inactive,    "Leech points from nearby players");

    add_wager_modifier(10, "hunt: Players you kill respawn instantly.\nPoints are only awarded on kills and drop as a powerup",                                                     serious::wager_blood_hunter,            undefined,                          "Kills increase damage and movement speed for 1 minute. Stacks up to 10 times.");

    // selects random modifiers for this game
    for(i = WAGER_MIN_LEVEL; i <= WAGER_MAX_LEVEL; i++)
    {
        if(!isdefined(level.wager_modifiers[i]) || !level.wager_modifiers[i].size)
        {
            continue;
        }

        s_tier = get_wager_tier(i);
        if(!isdefined(s_tier))
        {
            continue;
        }

        n_index = randomint(level.wager_modifiers[i].size);
        n_index_original = n_index;
        modifier = level.wager_modifiers[i][n_index];
        while(isdefined(modifier.func_validate) && !(level [[modifier.func_validate]]()))
        {
            n_index++;
            if(n_index >= level.wager_modifiers[i].size)
            {
                n_index = 0;
            }
            if(n_index_original == n_index) // prevent endless loop
            {
                break;
            }
            modifier = level.wager_modifiers[i][n_index];
        }
        s_tier.modifier = modifier;
    }
}

add_wager_tier(tier, text, bonus_currency)
{
    if(!isdefined(level.wager_tiers))
    {
        level.wager_tiers = [];
    }
    s_tier = spawnstruct();
    s_tier.text = text;
    s_tier.bonus_currency = bonus_currency;
    level.wager_tiers[tier] = s_tier;
    return s_tier;
}

get_wager_tier(tier = 0)
{
    return level.wager_tiers[tier];
}

add_wager_modifier(tier, text, func_accepted, func_validate, override_bonus)
{
    if(!isdefined(level.wager_modifiers))
    {
        level.wager_modifiers = [];
    }
    if(!isdefined(level.wager_modifiers[tier]))
    {
        level.wager_modifiers[tier] = [];
    }
    a_modifiers = level.wager_modifiers[tier];
    s_modifier = spawnstruct();
    s_modifier.func_validate = func_validate;
    s_modifier.tier = tier;
    s_modifier.text = text;
    s_modifier.func_accepted = func_accepted;
    s_modifier.override_bonus = override_bonus;
    a_modifiers[a_modifiers.size] = s_modifier;
    return s_modifier;
}

make_wager_text(tier = 1)
{
    s_tier = get_wager_tier(tier);
    if(!isdefined(s_tier) || !isdefined(s_tier.modifier)) 
    {
        if(IS_DEBUG) return "unknown tier: " + tier;
        return "";
    }
    s_text = "[^2" + s_tier.text + "^7] Hold ^3&&1 ^7to " + s_tier.modifier.text;
    if(isdefined(s_tier.modifier.override_bonus))
    {
        s_text += "\n" + s_tier.modifier.override_bonus;
    }
    else
    {
        s_text += "\nGrants more xp and vials. Makes elo harder to lose, and easier to gain.";
    }
    return s_text;
}

spawn_wager_totem(location, angles, owner)
{
    if(NO_WAGER_TOTEMS) return;
    if(IS_DEBUG && DEBUG_HOST_CM_BGBM) return;
    if(isdefined(owner.wager_totem) || level.round_number > WAGER_COMMIT_ROUND) return;
    if(isdefined(owner.wager_tier) && owner.wager_tier >= WAGER_MAX_LEVEL) return;
    wager_totem = create_wager_totem(location, angles, owner);
    wager_totem endon("wager_totem_exit");
    wager_totem endon("death");
    owner.wager_totem = wager_totem;
    wager_totem thread wager_totem_cleanup(owner);
    if(isdefined(owner.wager_tier))
    {
        wager_totem.wager_level = owner.wager_tier + 1;
    }
    else
    {
        wager_totem.wager_level = WAGER_MIN_LEVEL;
    }
    stub = wager_totem zm_unitrigger::create_unitrigger("", 128, serious::wager_visibility_check, serious::wager_trigger_think, "unitrigger_radius_use");
    zm_unitrigger::unitrigger_force_per_player_triggers(stub, true);
    stub.totem = wager_totem;
    wager_totem.trig = stub;
    owner thread watch_totem_respawn(wager_totem);
    while(level.round_number <= WAGER_COMMIT_ROUND)
    {
        level waittill("wager_check");
    }
    wager_totem thread wager_totem_exit();
}

watch_totem_respawn(wager_totem)
{
    self endon("disconnect");
    wager_totem endon("death");
    self waittill("bled_out");
    level thread kill_wager_totem(self);
}

kill_wager_totem(owner)
{
    if(!isdefined(owner.wager_totem)) return;
    wager_totem = owner.wager_totem;
    wager_totem thread wager_totem_exit();
    owner.wager_totem = undefined;
}

create_wager_totem(location, angles, owner)
{
    w_knife = getweapon("shotgun_pump");
    s_totem = spawnstruct();
    s_totem.challenge_playing = false;
    s_totem.owner = owner;
    s_totem.origin = location + (0,0,20);
    s_totem.angles = angles;
    s_totem.tag_origin = util::spawn_model("tag_origin", location + (0,0,55), (0,0,0));
    s_totem.tag_origin thread rotate_until_death();
    s_totem.skull = util::spawn_model("p7_zm_power_up_insta_kill", location + (0,0,55), (0,0,0));
    s_totem.skull enableLinkTo();
    s_totem.skull SetInvisibleToAll();
    s_totem.skull SetVisibleToPlayer(owner);
    s_totem.skull clientfield::set("powerup_fx", 4);
    s_totem.skull linkTo(s_totem.tag_origin);
    s_totem.skull playloopsound("zmb_spawn_powerup_loop");
    s_totem.l_shotgun = wager_make_weapon(location + (-12,0,40), (-65,180,0), w_knife, owner getbuildkitweaponoptions(w_knife, 15), owner);
    s_totem.l_shotgun setscale(1.25);
    s_totem.l_shotgun linkTo(s_totem.tag_origin, "tag_origin", (-12,0,-15), (-65,180,0));
    s_totem.r_shotgun = wager_make_weapon(location + (12,0,40), (-65,0,0), w_knife, owner getbuildkitweaponoptions(w_knife, 15), owner);
    s_totem.r_shotgun setscale(1.25);
    s_totem.r_shotgun linkTo(s_totem.tag_origin, "tag_origin", (12,0,-15), (-65,0,0));
    s_totem thread wager_await_accept_challenge();
    return s_totem;
}

wager_await_accept_challenge()
{
    self.owner endon("disconnect");
    self endon("death");
    self endon("wager_totem_exit");
    for(;;)
    {
        self waittill("wager_challenge_accepted", tier);
        playsoundatposition("zmb_hellhound_spawn", self.origin);
        self.challenge_playing = true;
        self.l_shotgun thread wager_scene_shotgun_fire(self.owner);
        self.r_shotgun thread wager_scene_shotgun_fire(self.owner);
        self.tag_origin thread wager_scene_spinfast(8);
        self.tag_origin thread playFXTimedOnTag(level._effect["character_fire_death_torso"], "tag_origin", 5);
        Earthquake(0.5, 3.0, self.origin, 256);
        wait 3.75;
        self.challenge_playing = false;
        self.l_shotgun notify("stop_shooting");
        self.r_shotgun notify("stop_shooting");
        self notify("scene_done");
    }
}

wager_scene_shotgun_fire(owner)
{
    self endon("death");
    self endon("stop_shooting");
    for(;;)
    {
        magicbullet(self.weapon, self gettagorigin("tag_flash"), self gettagorigin("tag_flash") + vectorscale(anglestoforward(self.angles), 1000), undefined);
        wait 0.15;
    }
}

wager_scene_spinfast(n_spins = 10)
{
    self notify("wager_challenge_spin");
    self endon("death");
    while(n_spins > 0)
    {
        self rotateYaw(self.angles[2] + 360, 0.5, 0, 0);
        wait 0.45;
        n_spins--;
    }
    self thread rotate_until_death();
}

rotate_until_death()
{
    self endon("death");
    self endon("wager_challenge_spin");
    n_duration = 7;
    for(;;)
    {
        self rotateYaw(self.angles[2] + 360, n_duration, 0, 0);
        wait n_duration - 0.05;
    }
}

wager_totem_cleanup(owner)
{
    self endon("death");
    self endon("wager_totem_exit");
    level endon("game_ended");
    owner waittill("disconnect");
    self thread wager_totem_exit();
}

wager_totem_exit()
{
    self endon("death");

    zm_unitrigger::unregister_unitrigger(self.s_unitrigger);
    wait 2;

    self notify("wager_totem_exit");
    self.challenge_playing = false;

    if(isdefined(self.l_shotgun))
    {
        self.l_shotgun notify("stop_shooting");
        self.r_shotgun notify("stop_shooting");
        self.tag_origin moveTo(self.tag_origin getOrigin() + (0,0,-15), 0.25);
        wait 0.3;
        playfx(level._effect["poltergeist"], self.tag_origin.origin, anglestoup(self.tag_origin.angles), anglestoforward(self.tag_origin.angles));
        playfx(level._effect["lght_marker_flare"], self.tag_origin.origin);
        self.tag_origin moveTo(self.tag_origin getOrigin() + (0,0,5000), 1.5);
        wait 1.5;
    }
    
    if(isdefined(self.skull))
    {
        self.skull delete();
    }

    if(isdefined(self.l_shotgun))
    {
        self.l_shotgun delete();
        self.r_shotgun delete();
        self.tag_origin delete();
    }
}

wager_visibility_check(player)
{
    if(!isdefined(self.stub.totem.owner)) return false;
    b_result = true;
    if(self.stub.totem.owner != player)
    {
        return false;
    }
    if(player.sessionstate != "playing")
    {
        return false;
    }
    if(isdefined(self.stub.totem.exiting) && self.stub.totem.exiting) 
    {
        return false;
    }
    if(isdefined(self.stub.totem.challenge_playing) && self.stub.totem.challenge_playing) 
    {
        return false;
    }
    self sethintstring(make_wager_text(self.stub.totem.wager_level));
    return b_result;
}

wager_trigger_think()
{
    totem = self.stub.totem;
    for(;;)
    {
        self waittill("trigger", player);
        if(totem.owner != player) continue;
        if(player zm_utility::in_revive_trigger())
		{
			continue;
		}
		if(!zm_utility::is_player_valid(player, false, true))
		{
			continue;
		}
        if(totem.challenge_playing)
        {
            continue;
        }
        self TriggerEnable(false);
        totem thread wager_challenge_accepted(player);
        totem waittill("scene_done");
        self TriggerEnable(true);
    }
}

wager_challenge_accepted(player)
{
    tier = self.wager_level;
    s_tier = get_wager_tier(tier);
    if(!isdefined(s_tier.modifier.func_accepted))
    {
        return;
    }
    player.wager_tier = self.wager_level;
    player thread [[ s_tier.modifier.func_accepted ]]();
    player notify("wager_challenge_accepted");
    playfx(level._effect["teleport_splash"], player.origin);
    player playsound("zmb_bgb_fearinheadlights_start");
    player thread wager_activate_visionset();
    playsoundatposition("zmb_hellhound_bolt", player.origin);
    self notify("wager_challenge_accepted", self.wager_level);
    self.wager_level++;
    if(self.wager_level > WAGER_MAX_LEVEL) 
    {
        self thread wager_totem_exit();
    }
}

wager_activate_visionset()
{
    self notify("wager_activate_visionset");
    self endon("wager_activate_visionset");
    self endon("disconnect");
    visionset_mgr::activate("visionset", "zm_bgb_idle_eyes", self, 0.5, 4.5, 0.5);
	visionset_mgr::activate("overlay", "zm_bgb_idle_eyes", self);
    wait 4.5;
    visionset_mgr::deactivate("visionset", "zm_bgb_idle_eyes", self);
    wait(0.5);
    visionset_mgr::deactivate("overlay", "zm_bgb_idle_eyes", self);
}

wager_zm_points()
{
    self.wager_zm_points_mod = 0.85;
    self.wager_zm_points_drop = 5;
}

wager_zm_outgoing_damage()
{
    self.wager_zm_outgoing_damage = 0.85;
}

wager_zm_incoming_damage()
{
    self.wager_zm_incoming_damage = 1.15;
}

wager_pvp_points()
{
    self.wager_pvp_points_mod = 0.85;
}

wager_pvp_incoming_damage()
{
    self.wager_pvp_incoming_damage = 1.15;
}

wager_pvp_outgoing_damage()
{
    self.wager_pvp_outgoing_damage = 0.85;
}

wager_bgb_pack()
{
    self.var_e610f362 = [];
    self.var_98ba48a2 = [];
    self.wager_bgb_pack = true;
}

wager_weapon_slot()
{
    weapons = self getweaponslistprimaries();
    if(weapons.size > 1)
    {
        arrayremovevalue(weapons, self getCurrentWeapon(), false);
        self takeWeapon(weapons[weapons.size - 1]);
    }
    self.wager_weapon_slot = true;
}

wager_weapon_types()
{
    self endon("disconnect");
    for(;;)
    {
        while(self.sessionstate != "playing")
        {
            wait 0.25;
        }
        foreach(weapon in self getweaponslist())
        {
            switch(true)
            {
                case zm_utility::is_hero_weapon(weapon):
                case zm_utility::is_tactical_grenade(weapon):
                    self takeWeapon(weapon);
                    break;
            }
        }
        self util::waittill_any_timeout(5, "weapon_change", "reload", "weapon_give");
    }
}

wager_pvp_melee_damage()
{
    self.wager_pvp_melee_damage = true;
}

wager_powerups()
{
    self.wager_powerups = true;
}

wager_sprinting()
{
    self endon("disconnect");
    for(;;)
    {
        wait 1;
        while(self.sessionstate != "playing")
        {
            wait 0.25;
        }
        if(self issprinting())
        {
            self dodamage(100, self.origin);
        }
    }
}

wager_win()
{
    self.wager_win_dmg_scalar = 1.35;
    self.wager_win_points = int(WIN_NUMPOINTS * 1.5);
}

do_wager_character_effects()
{
    self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
    self thread wager_perk_monitor();
    for(;;)
    {
        tier = self.wager_tier;
        if(isdefined(tier))
        {
            if(tier >= 1)
            {
                self thread wager_fx_challenger_i();
            }
            if(tier >= 2)
            {
                self wager_fx_challenger_ii();
            }
            if(tier >= 3)
            {
                self wager_fx_expert_i();
            }
            if(tier >= 4)
            {
                self wager_fx_expert_ii();
            }
            if(tier >= 5)
            {
                self thread wager_fx_master();
            }
            if(tier >= 6)
            {
                self thread wager_fx_gm1();
                self thread wager_gm1_rewards();
            }
            if(tier >= 7)
            {
                self thread wager_fx_gm2();
                self wager_gm2_rewards();
            }
            if(tier >= 8)
            {
                self wager_gm3_rewards();
            }
            if(tier >= 9)
            {
                self thread wager_gm4_rewards();
            }
            if(tier >= 10)
            {
                self wager_gm5_fx();
            }
        }
        self waittill("wager_challenge_accepted");
    }
}

wager_fx_master()
{
    if(WAGER_FX_DISABLED)
    {
        return;
    }
    self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
    if(isdefined(self.wager_master_fx))
    {
        self.wager_master_fx delete();
    }
    self.wager_master_fx = spawn("script_model", self getTagOrigin("j_helmet"));
    self.wager_master_fx thread fx_kill_on_death_or_disconnect(self);
    self.wager_master_fx setmodel("tag_origin");
    self.wager_master_fx enableLinkTo();
    self.wager_master_fx linkTo(self, "j_helmet", (-2,1,0));
    self.wager_master_fx setscale(0.5);
    self.wager_master_fx SetInvisibleToPlayer(self, true);
    for(;;)
    {
        wager_master_fx_ontag = playFXOnTag(level._effect["character_fire_death_torso"], self.wager_master_fx, "tag_origin");
        wait 10;
        if(isdefined(wager_master_fx_ontag))
        {
            wager_master_fx_ontag delete();
        }
    }
}

fx_kill_on_death_or_disconnect(player)
{
    self endon("death");
    player waittill("disconnect");
    self delete();
}


wager_fx_expert_ii()
{
    if(WAGER_FX_DISABLED)
    {
        return;
    }
    if(isdefined(self.wager_fx_expert_ii))
    {
        self.wager_fx_expert_ii delete();
    }
    self.wager_fx_expert_ii = spawn("script_model", self getTagOrigin("j_helmet"));
    self.wager_fx_expert_ii thread fx_kill_on_death_or_disconnect(self);
    self.wager_fx_expert_ii setmodel("p7_zm_power_up_insta_kill");
    self.wager_fx_expert_ii enableLinkTo();
    self.wager_fx_expert_ii setscale(0.425);
    self.wager_fx_expert_ii linkto(self, "j_helmet", (-5,1,0), (-90,-30,180));
    self.wager_fx_expert_ii SetInvisibleToPlayer(self, true);
}

wager_fx_expert_i()
{
    if(WAGER_FX_DISABLED)
    {
        return;
    }
    if(isdefined(self.wager_fx_expert_i))
    {
        foreach(ent in self.wager_fx_expert_i)
            ent delete();
    }
    self.wager_fx_expert_i = [];

    //j_spineupper
    bowie_1 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_2 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_3 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_4 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_5 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_6 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_7 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_8 = self wager_make_bowie(self getTagOrigin("j_spineupper"));
    bowie_1 linkto(self, "j_spineupper", (12,-5,0), (70,0,0));
    bowie_2 linkto(self, "j_spineupper", (12,-5,0), (-70,180,0));
    bowie_3 linkto(self, "j_spineupper", (12,-5,0), (-25,180,0));
    bowie_4 linkto(self, "j_spineupper", (12,-5,0), (155,0,0));
    bowie_5 linkto(self, "j_spineupper", (12,-5,0), (25,0,0));
    bowie_6 linkto(self, "j_spineupper", (12,-5,0), (-155,180,0));
    bowie_7 linkto(self, "j_spineupper", (12,-5,0), (110,0,0));
    bowie_8 linkto(self, "j_spineupper", (12,-5,0), (-110,180,0));
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_1;
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_2;
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_3;
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_4;
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_5;
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_6;
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_7;
    self.wager_fx_expert_i[self.wager_fx_expert_i.size] = bowie_8;
}

wager_make_bowie(location)
{
    w_knife = getweapon("bowie_knife");
    mdl = spawn("script_model", location);
    mdl useweaponmodel(w_knife, w_knife.worldmodel, self getbuildkitweaponoptions(w_knife, 15));
    mdl enableLinkTo();
    mdl setscale(1.1);
    mdl SetInvisibleToPlayer(self, true);
    mdl thread fx_kill_on_death_or_disconnect(self);
    return mdl;
}

wager_fx_challenger_ii()
{
    if(WAGER_FX_DISABLED)
    {
        return;
    }
    if(isdefined(self.wager_fx_challenger_ii))
    {
        self.wager_fx_challenger_ii delete();
    }
    self.wager_fx_challenger_ii = spawn("script_model", self getTagOrigin("tag_flash"));
    self.wager_fx_challenger_ii thread fx_kill_on_death_or_disconnect(self);
    self.wager_fx_challenger_ii setmodel("p7_zm_power_up_nuke");
    self.wager_fx_challenger_ii enableLinkTo();
    self.wager_fx_challenger_ii setscale(0.2);
    self.wager_fx_challenger_ii linkto(self, "tag_flash", (4,0,0), (0,0,0));
    self.wager_fx_challenger_ii SetInvisibleToPlayer(self, true);
}

wager_show_self_items()
{
    if(isdefined(self.wager_fx_challenger_ii))
    {
        self.wager_fx_challenger_ii SetInvisibleToPlayer(self, false);
    }
    if(isdefined(self.wager_fx_challenger_i))
    {
        self.wager_fx_challenger_i SetInvisibleToPlayer(self, false);
    }
    if(isdefined(self.wager_fx_expert_i))
    {
        foreach(obj in self.wager_fx_expert_i)
            obj SetInvisibleToPlayer(self, false);
    }
    if(isdefined(self.wager_fx_expert_ii))
    {
        self.wager_fx_expert_ii SetInvisibleToPlayer(self, false);
    }
    if(isdefined(self.wager_master_fx))
    {
        self.wager_master_fx SetInvisibleToPlayer(self, false);
    }
    if(isdefined(self.wager_fx_gm2))
    {
        self.wager_fx_gm2 SetInvisibleToPlayer(self, false);
    }
    if(isdefined(self.wager_gm4_fx))
    {
        self.wager_gm4_fx SetInvisibleToPlayer(self, false);
    }
    if(isdefined(self.wager_gm5_fx))
    {
        foreach(fx in self.wager_gm5_fx)
        {
            fx SetInvisibleToPlayer(self, false);
        }
    }
}

wager_fx_challenger_i()
{
    if(WAGER_FX_DISABLED)
    {
        return;
    }
    self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
    if(isdefined(self.wager_fx_challenger_i))
    {
        self.wager_fx_challenger_i delete();
    }
    if(isdefined(self.wager_fx_challenger_i_fx))
    {
        self.wager_fx_challenger_i_fx delete();
    }
    self.wager_fx_challenger_i = spawn("script_model", self getTagOrigin("j_eyeball_le"));
    self.wager_fx_challenger_i thread fx_kill_on_death_or_disconnect(self);
    self.wager_fx_challenger_i setmodel("tag_origin");
    self.wager_fx_challenger_i enableLinkTo();
    self.wager_fx_challenger_i linkTo(self, "j_eyeball_le", (0,-1,0), (0,0,0));
    self.wager_fx_challenger_i SetInvisibleToPlayer(self, true);
    self.wager_fx_challenger_i_fx = playFXOnTag(level._effect["eye_glow"], self.wager_fx_challenger_i, "tag_origin");
}

#define GOLD_INDEX = 15;
wager_fx_gm1()
{
    self endon("bled_out");
    self endon("disconnect");
    self endon("spawned_player");
    self.wager_fx_gm1 = true;
    list_tracked_inventory = [];
    foreach(weapon in self getWeaponsListPrimaries())
    {
        if(isdefined(weapon))
        {
            self wager_force_camo(weapon, GOLD_INDEX, weapon == (self getCurrentWeapon()));
        }
    }
    list_tracked_inventory = arraycopy(self getWeaponsListPrimaries());
    for(;;)
    {
        // saves us from death machine bricks and stuff
        self bgb::function_378bff5d();
        self zm_bgb_disorderly_combat::function_8a5ef15f();
        foreach(weapon in self getWeaponsListPrimaries())
        {
            if(!array::contains(list_tracked_inventory, weapon))
            {
                self wager_force_camo(weapon, GOLD_INDEX, weapon == (self getCurrentWeapon()));
            }
        }
        list_tracked_inventory = arraycopy(self getWeaponsListPrimaries());
        self waittill("weapon_change");
    }
}

wager_force_camo(weapon, camo = 0, swap = true)
{
    if(!isdefined(weapon))
    {
        return;
    }
    if(isdefined(weapon.isaltmode) && weapon.isaltmode)
    {
        return;
    }
    weapon_options = self CalcWeaponOptions(camo, 0, 0);
    acvi = self GetBuildKitAttachmentCosmeticVariantIndexes(weapon, self zm_weapons::is_weapon_upgraded(weapon));
    ammo_clip = self GetWeaponAmmoClip(weapon);
    ammo_stock = self GetWeaponAmmoStock(weapon);
    self takeweapon(weapon, 1);
    self GiveWeapon(weapon, weapon_options, acvi);
    self ShouldDoInitialWeaponRaise(weapon, false);
    if(swap)
    {
        self switchtoweaponimmediate(weapon);
    }
    self SetWeaponAmmoClip(weapon, ammo_clip);
    self SetWeaponAmmoStock(weapon, ammo_stock);
}

wager_gm1_rewards()
{
    self notify("wager_gm1_rewards");
    self endon("wager_gm1_rewards");
    self endon("bled_out");
    self endon("disconnect");
    self endon("spawned_player");
    save_bullet_array = [];
    self setperk("specialty_stalker");
    self.wager_gm1_rewards = true;
    for(;;)
    {
        self waittill("weapon_fired", weapon);
        if(!isdefined(weapon)) continue;
        if(!isdefined(save_bullet_array[weapon]))
        {
            save_bullet_array[weapon] = false;
        }
        save_bullet_array[weapon] = !save_bullet_array[weapon];
        if(save_bullet_array[weapon])
        {
            self SetWeaponAmmoClip(weapon, self GetWeaponAmmoClip(weapon) + 1);
        }
    }
}

wager_gm2_rewards()
{
    self setperk("specialty_unlimitedsprint");
    self.wager_gm2_rewards = true;
}

wager_make_weapon(location, angles, weapon, options, owner)
{
    mdl = spawn("script_model", location);
    mdl.angles = angles;
    mdl.weapon = weapon;
    mdl useweaponmodel(weapon, weapon.worldmodel, options);
    mdl enableLinkTo();
    mdl thread fx_kill_on_death_or_disconnect(owner);
    mdl SetInvisibleToAll();
    mdl SetVisibleToPlayer(owner);
    return mdl;
}

wager_make_icon()
{
    tag = spawn("script_model", self getTagOrigin("j_spineupper"));
    tag setmodel("tag_origin");
    bowie_1 = self wager_make_bowie(tag.origin);
    bowie_2 = self wager_make_bowie(tag.origin);
    bowie_3 = self wager_make_bowie(tag.origin);
    bowie_4 = self wager_make_bowie(tag.origin);
    bowie_5 = self wager_make_bowie(tag.origin);
    bowie_6 = self wager_make_bowie(tag.origin);
    bowie_7 = self wager_make_bowie(tag.origin);
    bowie_8 = self wager_make_bowie(tag.origin);
    bowie_1 linkto(tag, "tag_origin", (0,0,0), (70,0,0));
    bowie_2 linkto(tag, "tag_origin", (0,0,0), (-70,180,0));
    bowie_3 linkto(tag, "tag_origin", (0,0,0), (-25,180,0));
    bowie_4 linkto(tag, "tag_origin", (0,0,0), (155,0,0));
    bowie_5 linkto(tag, "tag_origin", (0,0,0), (25,0,0));
    bowie_6 linkto(tag, "tag_origin", (0,0,0), (-155,180,0));
    bowie_7 linkto(tag, "tag_origin", (0,0,0), (110,0,0));
    bowie_8 linkto(tag, "tag_origin", (0,0,0), (-110,180,0));

    bowie_1 SetInvisibleToPlayer(self, false);
    bowie_2 SetInvisibleToPlayer(self, false);
    bowie_3 SetInvisibleToPlayer(self, false);
    bowie_4 SetInvisibleToPlayer(self, false);
    bowie_5 SetInvisibleToPlayer(self, false);
    bowie_6 SetInvisibleToPlayer(self, false);
    bowie_7 SetInvisibleToPlayer(self, false);
    bowie_8 SetInvisibleToPlayer(self, false);

    bowie_1 setscale(0.75);
    bowie_2 setscale(0.75);
    bowie_3 setscale(0.75);
    bowie_4 setscale(0.75);
    bowie_5 setscale(0.75);
    bowie_6 setscale(0.75);
    bowie_7 setscale(0.75);
    bowie_8 setscale(0.75);

    wager_fx_expert_ii = spawn("script_model", tag.origin);
    wager_fx_expert_ii setmodel("p7_zm_power_up_insta_kill");
    wager_fx_expert_ii enableLinkTo();
    wager_fx_expert_ii setscale(0.425);
    wager_fx_expert_ii linkto(tag, "tag_origin", (-1,0,0), (0,0,0));

    tag2 = spawn("script_model", self getTagOrigin("j_spineupper"));
    tag2 setmodel("tag_origin");
    tag2 enableLinkTo();
    tag2 linkto(tag, "tag_origin", (-2.5,-4,-1), (0,180,0));
    playFXOnTag(level._effect["eye_glow"], tag2, "tag_origin");
}

wager_sliding()
{
    self endon("disconnect");
    for(;;)
    {
        if(self.sessionstate != "playing")
        {
            wait 0.25;
            continue;
        }
        self AllowSlide(false);
        wait 1;
    }
}

wager_box_options()
{
    self.wager_box_options = true;
}

boxes_present()
{
    return isdefined(level.chests) && level.chests.size;
}

wager_func_magicbox_weapon_spawned(box_weapon)
{
    foreach(player in level.players)
    {
        if(player.sessionstate != "playing")
        {
            continue;
        }
        if(!isdefined(player.wager_box_options) || !player.wager_box_options)
        {
            continue;
        }
        player thread wager_transfer_weapon_give(box_weapon);
    }
    if(isdefined(level._func_magicbox_weapon_spawned))
    {
        self [[level._func_magicbox_weapon_spawned]](box_weapon);
    }
}

// awards a player the weapon provided given the same quality and AAT of their current weapon.
wager_transfer_weapon_give(weapon, from_weapon, current_aat, will_trade)
{
    self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
    if(!isdefined(weapon) || weapon == level.weaponnone || (isdefined(level.zombie_powerup_weapon["minigun"]) && level.zombie_powerup_weapon["minigun"] == weapon))
    {
        return;
    }
    if(self zm_weapons::has_weapon_or_upgrade(weapon))
    {
        return;
    }
    if(self is_in_altbody())
    {
        return;
    }
    if(!zm_utility::is_player_valid(self))
    {
        return;
    }

    self bgb::function_378bff5d();
    self zm_bgb_disorderly_combat::function_8a5ef15f();
    if(!self zm_magicbox::can_buy_weapon()) return;
    while(self isMeleeing())
    {
        wait 0.25;
    }

    if(isdefined(from_weapon))
    {
        cw = from_weapon;
    }
    
    while(!isdefined(cw) || (isdefined(level.zombie_powerup_weapon["minigun"]) && level.zombie_powerup_weapon["minigun"] == cw))
    {
        cw = zm_weapons::get_nonalternate_weapon(self getCurrentWeapon());
        wait 0.05;
    }

    primaryweapons = self getweaponslistprimaries();
    weapon_limit = zm_utility::get_player_weapon_limit(self);
    if(!isdefined(will_trade))
    {
        will_trade = (primaryweapons.size >= weapon_limit) && !zm_utility::is_offhand_weapon(cw);
    }

    if(will_trade && zm_weapons::is_weapon_upgraded(cw))
    {
        weapon_ug = zm_weapons::get_upgrade_weapon(weapon);
        if(isdefined(weapon_ug))
        {
            weapon = weapon_ug;
        }
    }

    // swap aat from old weapon to new weapon
    if(will_trade && !isdefined(current_aat) && isdefined(self.AAT[cw]))
    {
        current_aat = self.AAT[cw];
        self.AAT[cw] = undefined;
    }

    switch(true)
    {
        case zm_utility::is_hero_weapon(weapon):
            self zm_weapons::weapon_give(weapon, 0, 0, 1, 0);
            self zm_utility::set_player_hero_weapon(weapon);
        break;
        case zm_utility::is_melee_weapon(weapon):
        case zm_utility::is_lethal_grenade(weapon):
        case zm_utility::is_tactical_grenade(weapon):
        case zm_utility::is_placeable_mine(weapon):
        case zm_utility::is_offhand_weapon(weapon):
            self zm_weapons::weapon_give(weapon, 0, 0, 1, 0);
        break;
        default:
            if(will_trade)
            {
                self takeweapon(cw);
            }
            weapon = self zm_weapons::give_build_kit_weapon(weapon);
            self switchToWeapon(weapon);
            self givestartammo(weapon);
            self playsoundtoplayer("zmb_bgb_disorderly_weap_switch", self);
            if(will_trade && isdefined(current_aat))
            {
                wait 0.1;
                GiveAAT(self, current_aat, false, weapon);
            }
        break;
    }
}

wager_gun_game()
{
    self.wager_gun_game = true;
}

wager_gg_kill(eAttacker)
{
    if(!isdefined(eAttacker) || !isplayer(eAttacker)) return;
    if(eAttacker.sessionstate != "playing") return;
    if(!isdefined(eAttacker.wager_gun_game) || !eAttacker.wager_gun_game) return;
    if(isdefined(self.lastmeansofdeath) && self.lastmeansofdeath == "MOD_MELEE") return;
    eAttacker thread wager_gg_swap();
}

wager_gg_swap()
{
    self endon("disconnect");
    self endon("spawned_player");
    self endon("bled_out");
    self notify("wager_gg_swap");
    self endon("wager_gg_swap");

    self bgb::function_378bff5d();
    self zm_bgb_disorderly_combat::function_8a5ef15f();
    while(self isMeleeing())
    {
        wait 0.25;
    }

    if(!isdefined(self.wager_gg_last))
    {
        self.wager_gg_last = gettime() - (WAGER_GM1_GG_TIME * 1000);
    }
    if((gettime() - self.wager_gg_last) < (WAGER_GM1_GG_TIME * 1000))
    {
        return;
    }

    cw = zm_weapons::get_nonalternate_weapon(self getCurrentWeapon());

    if(isdefined(level.zombie_powerup_weapon["minigun"]) && level.zombie_powerup_weapon["minigun"] == cw)
    {
        return;
    }

    switch(true)
    {
        case zm_utility::is_hero_weapon(cw):
        case zm_utility::is_melee_weapon(cw):
        case zm_utility::is_lethal_grenade(cw):
        case zm_utility::is_tactical_grenade(cw):
        case zm_utility::is_placeable_mine(cw):
        case zm_utility::is_offhand_weapon(cw):
            return;
    }

    self.wager_gg_last = gettime();
    self thread wager_transfer_weapon_give(self wager_get_rand_weap());
}

gums_present()
{
    return true;
}

wager_loadout_rounds()
{
    self.wager_loadout_rounds = true;
}

wager_loadout_rounds_activate()
{
    self util::waittill_any_timeout(5, "loadout_returned");
    list = self getweaponslistprimaries();
    aat_cache = [];
    weapon_limit = zm_utility::get_player_weapon_limit(self);
    index = 0;
    foreach(cw in list)
    {
        // swap aat from old weapon to new weapon
        if(isdefined(cw) && isdefined(self.AAT[cw]))
        {
            aat_cache[index] = self.AAT[cw] + "";
        }

        is_ug = zm_weapons::is_weapon_upgraded(cw);
        index++;
    }

    for(i = 0; i < weapon_limit; i++)
    {
        self thread wager_transfer_weapon_give(self wager_get_rand_weap(), list[i], aat_cache[i], true);
    }        
}

wager_get_random_weapons()
{
    if(isdefined(level.wager_weapons)) return level.wager_weapons;
    level.wager_weapons = [];
    foreach(wep in getarraykeys(level.zombie_weapons))
    {
        if(!isdefined(wep))
        {
            continue;
        }
        if(!isdefined(level.zombie_weapons[wep].is_in_box) || !level.zombie_weapons[wep].is_in_box)
        {
            continue;
        }
        if(!isdefined(level.zombie_include_weapons[wep]) || !level.zombie_include_weapons[wep])
        {
            continue;
        }
        if(wager_exclude_weapon(wep))
        {
            continue;
        }
        level.wager_weapons[level.wager_weapons.size] = wep;
    }
    return level.wager_weapons;
}

wager_exclude_weapon(weapon)
{
    if(isdefined(weapon.isgrenadeweapon) && weapon.isgrenadeweapon)
    {
        return true;
    }
    if(isdefined(weapon.ismeleeweapon) && weapon.ismeleeweapon)
    {
        return true;
    }
    if(weapon.name == "none")
    {
        return true;
    }
    if(issubstr(weapon.name, "idgun") && weapon.name != "idgun_0")
    {
        return true;
    }
	if(isdefined(level.start_weapon) && level.start_weapon == weapon)
	{
		return true;
	}
    if(is_tomb_staff(weapon))
    {
        return true; // upgrades get lost :(
    }
    if(isdefined(level.zbr_wager_exclude_weapons) && isarray(level.zbr_wager_exclude_weapons) && array::contains(level.zbr_wager_exclude_weapons, weapon))
    {
        return true;
    }
	return false;
}

wager_get_rand_weap()
{
    weapons = arraycopy(wager_get_random_weapons());
    w_weapon = array::random(weapons);
    while(self zm_weapons::has_weapon_or_upgrade(w_weapon))
    {
        weapons = array::pop_front(weapons, false);
        w_weapon = array::random(weapons);
    }
    return w_weapon;
}

wager_perk_lifetime()
{
    self endon("disconnect");
    self.wager_perk_lifetime = [];
    for(;;)
    {
        if(self.sessionstate == "playing" && isdefined(self.perks_active)) 
        {
            foreach(perk in self.perks_active)
            {
                if(perk == "specialty_additionalprimaryweapon")
                {
                    continue;
                }
                if(!array::contains(self.wager_perk_lifetime, perk))
                {
                    self thread wager_perk_watchtime(perk);
                }
            }
            self.wager_perk_lifetime = arraycopy(self.perks_active);
        }
        result = self util::waittill_any_return("perk_acquired", "fake_death", "death", "player_downed", "perk_lost");
    }
}

wager_perk_watchtime(perk)
{
    self notify("wager_" + perk);
    self endon("wager_" + perk);
    self endon(perk + "_stop");
    self endon("disconnect");
    self endon("fake_death");
    self endon("bled_out");
    self endon("spawned_player");

    wait WAGER_GM2_PTIMER * 60;
    self notify(perk + "_stop");
}

wager_perk_toggler()
{
    self.wager_perk_toggler = true;
}

wager_perk_monitor()
{
    self endon("bled_out");
    self endon("disconnect");
    self endon("spawned_player");

    for(;;)
    {
        self waittill("perk_acquired");
        if(isdefined(self.no_wpm) && self.no_wpm)
        {
            // prevents back and forth swapping forever
            wait 0.05;
            continue;
        }
        if(!isdefined(self.perks_active) || self.perks_active.size < 1)
        {
            wait 0.05;
            continue;
        }
        foreach(player in level.players)
        {
            if(player.sessionstate != "playing")
            {
                wait 0.05;
                continue;
            }
            if(player == self)
            {
                wait 0.05;
                continue;
            }
            if(isdefined(player.wager_perk_toggler) && player.wager_perk_toggler)
            {
                perk = self.perks_active[self.perks_active.size - 1];
                if(perk == "specialty_additionalprimaryweapon")
                {
                    continue;
                }
                if(player hasperk(perk))
                {
                    player notify(perk + "_stop");
                }
                else
                {
                    player.no_wpm = true;
                    player zm_perks::give_perk(perk, false);
                    wait 0.05;
                    player.no_wpm = false;
                }
            }
        }
    }
}

wager_bgb_pack_cycle()
{
    self endon("disconnect");
    for(;;)
    {
        wait 1;
        if(!isdefined(self.var_8414308a) || !isdefined(self.var_98ba48a2))
        {
            continue;
        }
        if(self.var_8414308a.size != self.var_98ba48a2.size)
        {
            self.var_8414308a = array::randomize(self.var_98ba48a2);
        }
    }
}

wager_perk_disabler()
{
    self.wager_perk_disabler = true;
}

wager_disable_perks()
{
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");
    if(!isdefined(self.perks_active))
    {
        return;
    }
    foreach(perk in self.perks_active)
    {
        if(perk == "specialty_additionalprimaryweapon")
        {
            continue;
        }
        self thread player_perk_pause(perk, PERK_PAUSE_TIME);
    }
}

player_perk_pause(perk, time = 1)
{
    self notify("player_perk_pause_" + perk);
    self endon("player_perk_pause_" + perk);
    self endon(perk + "_stop");
    self endon("disconnect");
    self endon("fake_death");
    self endon("bled_out");
    self endon("spawned_player");

    if(!isdefined(self.disabled_perks))
    {
        self.disabled_perks = [];
    }
    self.disabled_perks[perk] = (isdefined(self.disabled_perks[perk]) && self.disabled_perks[perk]) || self hasperk(perk);
    if(!self.disabled_perks[perk])
    {
        return;
    }
    self unsetperk(perk);
    self zm_perks::set_perk_clientfield(perk, 0);
    if(isdefined(level._custom_perks[perk]) && isdefined(level._custom_perks[perk].player_thread_take))
    {
        self thread [[level._custom_perks[perk].player_thread_take]](1);
    }
    wait time;
    self player_perk_unpause(perk);
}

player_perk_unpause(perk)
{
    if(!isdefined(perk))
	{
		return;
	}
    if(isdefined(self.disabled_perks) && (isdefined(self.disabled_perks[perk]) && self.disabled_perks[perk]))
    {
        self.disabled_perks[perk] = 0;
        self zm_perks::set_perk_clientfield(perk, 1);
        self setperk(perk);
        if(isdefined(level._custom_perks[perk]) && isdefined(level._custom_perks[perk].player_thread_give))
        {
            self thread [[level._custom_perks[perk].player_thread_give]]();
        }
    }
}

wager_fx_gm2()
{
    if(WAGER_FX_DISABLED)
    {
        return;
    }
    self notify("wager_fx_gm2");
    self endon("wager_fx_gm2");
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");

    if(isdefined(self.wager_fx_gm2))
    {
        self.wager_fx_gm2 delete();
    }

    if(isdefined(self.wgm2_mdl))
    {
        self.wgm2_mdl delete();
    }

    if(isdefined(self.wgm2_mdl2))
    {
        self.wgm2_mdl2 delete();
    }

    self.wager_fx_gm2 = spawn("script_model", self getTagOrigin("j_spineupper"));
    self.wager_fx_gm2 setmodel("zombie_pickup_perk_bottle");
    self.wager_fx_gm2 setscale(2);
    self.wager_fx_gm2 enableLinkTo();
    self.wager_fx_gm2 linkto(self, "j_spineupper", (12,-10,0), (90,0,0));
    self.wager_fx_gm2 SetInvisibleToPlayer(self, true);
    self.wager_fx_gm2 thread fx_kill_on_death_or_disconnect(self); 
    self.wager_fx_gm2 thread wager_fx_shoot_bottles(self);

    for(;;)
    {
        while(!self isMeleeing())
        {
            wait 0.05;
        }
        wait 0.1;
        wpn = get_rand_perk_bottle();
        if(!isdefined(wpn)) break;
        if(isdefined(self.wgm2_mdl))
        {
            self.wgm2_mdl delete();
        }
        self.wgm2_mdl = self wager_make_weapon(self getTagOrigin("tag_weapon_left"), (0,0,0), wpn, self calcweaponoptions(0, 0, 0), self);
        self.wgm2_mdl setscale(2);
        self.wgm2_mdl physicsLaunch(self.wgm2_mdl.origin, vectorscale(anglesToForward(self getPlayerAngles()), 50));
        while(self isMeleeing())
        {
            wait 0.05;
        }
    }
}

wager_fx_shoot_bottles(owner)
{
    if(WAGER_FX_DISABLED)
    {
        return;
    }
    self endon("death");
    owner endon("disconnect");
    owner endon("bled_out");

    for(;;)
    {
        if(isdefined(self.wgm2_mdl2))
        {
            self.wgm2_mdl2 delete();
        }
        self.wgm2_mdl2 = spawn("script_model", self.origin);
        self.wgm2_mdl2 setmodel("zombie_pickup_perk_bottle");
        self.wgm2_mdl2 setscale(1.25);
        self.wgm2_mdl2 thread fx_kill_on_death_or_disconnect(owner); 
        v_target = (self.wgm2_mdl2.origin[0] + randomFloatRange(-15, 15), self.wgm2_mdl2.origin[1] + randomFloatRange(-15, 15), self.wgm2_mdl2.origin[2] + 100);
        a_target = anglesToForward(vectortoangles(v_target - self.wgm2_mdl2.origin));
        self.wgm2_mdl2 physicsLaunch(self.wgm2_mdl2.origin, vectorscale(a_target, 15));
        wait randomFloatRange(3, 6);
    }
}

get_rand_perk_bottle()
{
    rng = array::random(level._custom_perks);
    if(!isdefined(rng))
    {
        return undefined;
    }
    return rng.perk_bottle_weapon;
}

wager_zomb_nades()
{
    self.wager_zomb_nades = true;
}

wager_gm3_rewards()
{
    self.wager_gm3_goldknife = true;
    self wager_gm3_bowie();
}

wager_gm3_bowie()
{
    if(!isdefined(self.wager_gm3_goldknife) || !self.wager_gm3_goldknife)
    {
        return;
    }
    self setperk("specialty_fastmeleerecovery");
    self.widows_wine_knife_override = serious::nullsub;
    weapon = getweapon("bowie_knife");
    if(self hasweapon(weapon))
    {
        self takeweapon(weapon);
    }
    weapon_options = self CalcWeaponOptions(GOLD_INDEX, 0, 0);
    acvi = self GetBuildKitAttachmentCosmeticVariantIndexes(weapon, false);
    self GiveWeapon(weapon, weapon_options, acvi);
}

wager_precision()
{
    self.wager_precision = true;
}

wager_bonus_zm_points()
{
    self.wager_bonus_zm_points = true;
}

wager_gm3_points_reward(points)
{
    self endon("disconnect");
    if(points > 10)
    {
        foreach(player in level.players)
        {
            if(!isdefined(player))
            {
                continue;
            }
            if(player == self)
            {
                continue;
            }
            if(player.team == self.team)
            {
                continue;
            }
            if(player.sessionstate != "playing")
            {
                continue;
            }
            player zm_score::add_to_player_score(points, 1, "gm_zbr_admin");
            wait 0.1;
        }
    }
}

wager_proximity()
{
    self.wager_proximity = true;
}

wager_gm4_rewards()
{
    self notify("wager_gm4_rewards");
    self endon("wager_gm4_rewards");
    self endon("spawned_player");
    self endon("bled_out");
    self endon("disconnect");

    self setperk("specialty_immunetriggerbetty");
    self wager_gm4_fx();
    while(self.sessionstate == "playing")
    {
        foreach(player in level.players)
        {
            if(player.sessionstate != "playing")
            {
                continue;
            }
            if(player.team == self.team)
            {
                continue;
            }
            if(distanceSquared(self getOrigin(), player getOrigin()) < 62500)
            {
                player dodamage(int(player.health * WAGER_GM4_DOT_PCT), self.origin, self, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);
                wait 0.05;
            }
        }
        wait 1;
    }
}

wager_gm4_fx()
{
    if(WAGER_FX_DISABLED)
    {
        return;
    }
    if(isdefined(self.wager_gm4_fx))
    {
        self.wager_gm4_fx delete();
    }
    if(isdefined(self.wager_gm4_fx_fx))
    {
        self.wager_gm4_fx_fx delete();
    }
    self.wager_gm4_fx = util::spawn_model("tag_origin", self.wager_fx_expert_ii.origin + (0,0,5), (0,0,0));
    self.wager_gm4_fx_fx = playfxontag("zombie/fx_powerup_on_red_zmb", self.wager_gm4_fx, "tag_origin");
    self.wager_gm4_fx linkto(self, "j_helmet", (-5,1,0), (0,0,0));
    self.wager_gm4_fx SetInvisibleToPlayer(self, true);
}

wager_gm5_fx()
{
    if(WAGER_FX_DISABLED)
    {
        return;
    }
    if(isdefined(self.wager_gm4_fx))
    {
        self.wager_gm4_fx delete();
    }

    if(isdefined(self.wager_gm5_fx))
    {
        foreach(fx in self.wager_gm5_fx)
        {
            if(isdefined(fx.fx))
            {
                fx.fx delete();
            }
            fx delete();
        }
    }

    self.wager_gm5_fx = [];
    index = 0;

    self.wager_gm5_fx[index] = util::spawn_model("tag_origin", self.wager_fx_expert_i[0].origin + (0,0,5), (0,0,0));
    self.wager_gm5_fx[index].fx = playfxontag("zombie/fx_powerup_on_red_zmb", self.wager_gm5_fx[index], "tag_origin");
    self.wager_gm5_fx[index] linkto(self, "j_spineupper", (0,0,0), (0,0,0));
    self.wager_gm5_fx[index] SetInvisibleToPlayer(self, true);
    index++;

    self.wager_gm5_fx[index] = util::spawn_model("tag_origin", self.wager_fx_expert_i[0].origin + (0,0,5), (0,0,0));
    self.wager_gm5_fx[index].fx = playfxontag("zombie/fx_powerup_on_red_zmb", self.wager_gm5_fx[index], "tag_origin");
    self.wager_gm5_fx[index] linkto(self, "j_spinelower", (0,0,0), (0,0,0));
    self.wager_gm5_fx[index] SetInvisibleToPlayer(self, true);
    index++;

    self.wager_gm5_fx[index] = util::spawn_model("tag_origin", self.wager_fx_expert_i[0].origin + (0,0,5), (0,0,0));
    self.wager_gm5_fx[index].fx = playfxontag("zombie/fx_powerup_on_red_zmb", self.wager_gm5_fx[index], "tag_origin");
    self.wager_gm5_fx[index] linkto(self, "j_head", (0,0,0), (0,0,0));
    self.wager_gm5_fx[index] SetInvisibleToPlayer(self, true);
    index++;
}

wager_bonus_mp_points()
{
    self.wager_bonus_mp_points = true;
}

powerup_wager_inactive()
{
    return get_wager_tier(4).modifier.func_accepted != serious::wager_powerups;
}

wager_powerup_all()
{
    self.wager_powerup_all = true;
}

powerup_grab_hook()
{
    powerup = self;
    player = powerup.power_up_grab_player;
    if(!isDefined(player) || !isplayer(player) || !isdefined(player.wager_powerup_all) || !player.wager_powerup_all)
    {
        return false;
    }
    if(isdefined(player.no_grab_wager_powerup) && player.no_grab_wager_powerup)
    {
        return false;
    }
    if(!isdefined(powerup.powerup_name))
    {
        return false;
    }
    foreach(_player in level.players)
    {
        if(_player == player)
        {
            continue;
        }
        if(isdefined(_player.no_grab_wager_powerup) && _player.no_grab_wager_powerup)
        {
            continue;
        }
        if(_player.sessionstate != "playing")
        {
            continue;
        }
        if(_player.team == player.team)
        {
            continue;
        }
        if(_player laststand::player_is_in_laststand())
        {
            continue;
        }
        _player.no_grab_wager_powerup = true;
        _player thread cooldown_powerup_grab();
        level thread zm_powerups::specific_powerup_drop(powerup.powerup_name, _player.origin);
    }
    return false;
}

cooldown_powerup_grab()
{
    self endon("disconnect");
    wait 3;
    self.no_grab_wager_powerup = false;
}

wager_blood_hunter()
{
    self.blood_hunter = true;
}

blood_hunter_buff()
{
    self notify("blood_hunter_buff");
    self endon("blood_hunter_buff");
    self endon("disconnect");
    self endon("bled_out");
    self endon("spawned_player");

    self.blood_hunter_timer = 60;
    if(!isdefined(self.blood_hunter_buff))
    {
        self.blood_hunter_buff = 0;
    }
    self.blood_hunter_buff++;
    if(self.blood_hunter_buff > 10)
    {
        self.blood_hunter_buff = 10;
    }
    while(self.blood_hunter_timer > 0)
    {
        self setMoveSpeedScale(1 + (WAGER_BH_MOVESPEED_STACK * self.blood_hunter_buff));
        self.blood_hunter_timer--;
        wait 1;
    }
    self update_gm_speed_boost();
    self.blood_hunter_buff = 0;
}

blood_hunter_points(item, player)
{
    if(!player laststand::player_is_in_laststand() && player.sessionstate == "playing")
	{
		player zm_score::player_add_points("bonus_points_powerup", isdefined(item.blood_hunter_points) ? item.blood_hunter_points : 1000);
	}
}

blood_hunter_powerup_grab(player)
{
    level thread blood_hunter_points(self, player);
	player thread zm_powerups::powerup_vo("bonus_points_solo");
}