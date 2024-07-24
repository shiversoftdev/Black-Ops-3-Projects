#ifdef ZM
InfinitePowerupToggle()
{
    if(self GetToggleState("Infinite Powerup Duration"))
        level._powerup_timeout_custom_time = ::PowerupTimeOverride;
    else
        level._powerup_timeout_custom_time = undefined;
}

PowerupTimeOverride(powerup)
{
    return 0;
}

#include scripts\zm\_zm_powerups;
PowerupBullets()
{
    level endon(#zbr_devgui);
    self endon("disconnect");
    level endon("end_game");
    while(self GetToggleState("Shoot Powerups"))
    {
        level thread zm_powerups::specific_powerup_drop(zm_powerups::get_next_powerup(), self GetTraceOrigin());
        self waittill("weapon_fired");
    }
}

#include scripts\zm\_zm_weapons;
#include scripts\shared\aat_shared;
AwardAAT(aat)
{
    weapon = AAT::get_nonalternate_weapon(self zm_weapons::switch_from_alt_weapon(self GetCurrentWeapon()));
    self.AAT[weapon] = aat;
    self clientfield::set_to_player("aat_current", level.AAT[ self.AAT[weapon] ].var_4851adad);
    self iPrintLnBold("AAT ^2" + aat + "^7 awarded!");
}

#include scripts\zm\bgbs\_zm_bgb_round_robbin;
AdjustRounds(value)
{
    if(!RoundNextValidator())
    {
        self iPrintLnBold("^1Cannot adjust the round at this time.");
        return;
    }

    level.catalyst_next_round = int(get_roundnumber() + value);

    if(!isdefined(level.old_round_wait_func))
        level.old_round_wait_func = level.round_wait_func;

    level.round_wait_func = ::RoundWaitHook;

    if(!isdefined(level.old_func_get_zombie_spawn_delay))
        level.old_func_get_zombie_spawn_delay = level.func_get_zombie_spawn_delay;
    
    level.func_get_zombie_spawn_delay = ::RoundNextHook;

    hash_98efd7b6::func_8824774d(level.catalyst_next_round);

    self iPrintLnBold("^7Round adjusted by ^3" + value);
}

RoundNextValidator()
{
    if(!level flag::get("begin_spawning"))
    {
        return 0;
    }
    zombies = GetAITeamArray(level.zombie_team);
    if(!isdefined(zombies) || zombies.size < 1)
    {
        return 0;
    }
    if(isdefined(level.var_35efa94c))
    {
        if(![[level.var_35efa94c]]())
        {
            return 0;
        }
    }
    if(isdefined(level.var_dfd95560) && level.var_dfd95560)
    {
        return 0;
    }
    return 1;
}

RoundWaitHook()
{
    [[level.old_round_wait_func]]();
    set_roundNumber(level.catalyst_next_round - 1);
}

RoundNextHook(round)
{
    set_roundNumber(level.catalyst_next_round);
    level.catalyst_next_round++;
    
    if(level.zombie_total < 0)
        level.zombie_total = 0;

    return [[level.old_func_get_zombie_spawn_delay]](int(min(level.catalyst_next_round - 1, 100)));
}

get_roundnumber()
{
    return world.var_48b0db18 ^ 115;
}

set_roundNumber(number)
{
    if(!isdefined(number))
        return;

    number = int(number);

    level.round_number = number;
    world.var_48b0db18 = number ^ 115;
    SetRoundsPlayed(number);
}

#include scripts\zm\craftables\_zm_craftables;
CollectParts()
{
    foreach(s_craftable in level.zombie_include_craftables)
    {
        foreach(s_piece in s_craftable.a_piecestubs)
        {
            if(isdefined(s_piece.pieceSpawn))
                self zm_craftables::player_take_piece(s_piece.pieceSpawn);
        }
    }
    level._all_parts = true;
    self iPrintLnBold("Parts ^2Collected^7!");
    self ClearOptionByName("lobby", "Collect All Parts");
    self DrawMenu(mANIM_ZOOMIN);
}

#include scripts\zm\_zm_blockers;
#include scripts\zm\_zm_utility;
OpenTheDoors() // credits to _Dev <3
{
    types = ["zombie_door", "zombie_airlock_buy", "zombie_debris"];
    foreach(type in types)
    {
        zombie_doors = GetEntArray(type, "targetname");
        foreach(door in zombie_doors)
        {
            if(door._door_open == 0)
            {
                door thread zm_blockers::door_opened(door.zombie_cost, 0);
                door._door_open = true;

                all_trigs = GetEntArray(door.target, "target");
                foreach(trig in all_trigs)
                    trig thread zm_utility::set_hint_string(trig, "");
            }
        }
    }
    level._doors_done = true;
    self iPrintLnBold("Doors ^2Opened^7");
    self ClearOptionByName("lobby", "Open All Doors");
    self DrawMenu(mANIM_ZOOMIN);
}
    
AllPower()
{
    level flag::set("power_on");
    power_trigs = GetEntArray("use_elec_switch", "targetname");
    foreach(trig in power_trigs)
    {
        if(isdefined(trig.script_int))
        {
            level flag::set("power_on" + trig.script_int);
            level clientfield::set("zombie_power_on", trig.script_int);
        }
    }
    foreach(obj in array("elec", "power", "master")) // thanks feb
    {
        trig = getEnt("use_" + obj + "_switch", "targetname");
        if(isDefined(trig))
            trig notify("trigger", level.players[0]);
    }
    self iPrintLnBold("Power ^2Enabled");
    level._power_done = true;
    self ClearOptionByName("lobby", "Turn On Power");
    self DrawMenu(mANIM_ZOOMIN);
}

#include scripts\zm\_zm_magicbox;
AllBoxStates(show)
{
    if(show)
    {
        foreach(chest in level.chests)
        {
            chest.hidden = 0;
            chest thread [[level.pandora_show_func]]();
            chest.zbarrier zm_magicbox::set_magic_box_zbarrier_state("initial");
        }
        self iPrintLnBold("All Boxes ^2Showing");   
    }
    else
    {
        foreach(chest in level.chests)
            chest thread zm_magicbox::hide_chest();
        self iPrintLnBold("All Boxes ^2Hidden");
    }
}

#include scripts\zm\_zm_score;
AdjustPoints(points)
{
    if(points >= 0)
    {
        self zm_score::add_to_player_score(points);
        self iPrintLnBold("Adjusted points by ^2" + points);
    }
    else
    {
        self zm_score::minus_to_player_score(-1 * points);
        self iPrintLnBold("Adjusted points by ^1" + points);
    }
}

PerksDownedToggle()
{
    self._retain_perks = self GetToggleState("Perks While Downed");
}

DownPlayer(player)
{
    player disableInvulnerability();
    player dodamage(player.health + 1, player.origin);
    self iPrintLnBold("Player ^1Downed");
}

#include scripts\zm\_zm_laststand;
ZM_RevivePlayer(player)
{
    player zm_laststand::auto_revive(self);
    self iPrintLnBold("Player ^1Revived");
}

SummonPerks()
{
    vending_triggers = getentarray( "zombie_vending", "targetname" );
    machines         = [];
    i                = 0;
    max              = vending_triggers.size;
    for(j = 0; j < max; j++)
    {
        trig = vending_triggers[j];
        machine = getent(trig.target, "targetname");
        origin = self GetOrigin() + ((150,150,1) * (cos( (i / max) * 360 ), sin( (i / max) * 360 ), 0));
        machine MoveTo( origin, .1);
        machine.angles = VectorToAngles( self GetOrigin() - origin ) + (0, 90, 0);
        trig.origin = origin;
        trig.script_origin = origin;
        i++;
    }
}

#include scripts\zm\_zm_powerups;
RainPowerups()
{
    level endon(#zbr_devgui);
    self endon("disconnect");
    level endon("end_game");
    #ifndef serious killserver(); #endif
    while(self GetToggleState("Rain Powerups"))
    {
        origin = ((self.origin[0] + randomIntRange( -1000,1001)), (self.origin[1] + randomIntRange( -1000,1001)),(self.origin[2] + 2500));
        obj    = level zm_powerups::specific_powerup_drop(zm_powerups::get_next_powerup(), origin);
        if(isdefined(obj))
            obj thread PowerupDropThenDelete();
    }
}
    
PowerupDropThenDelete()
{
    self PhysicsLaunch();
    wait 15;
    self delete();
}

SpawnZombieArray(player, count = 0)
{
    if(!isdefined(player))
        return;
    
    self iPrintLnBold("Spawning Zombies");
    for(i = 0; i < count; i++)
    {
        self thread SpawnZombie(player);
        wait .25;
    }

    self iPrintLnBold("Spawning ^2Complete");
}

#include scripts\shared\ai\zombie_utility;
SpawnZombie(player)
{
    if(!isdefined(player))
        return;
    
    direction = player getplayerangles();
    direction_vec = anglesToForward(direction);
    eye = player geteye();

    direction_vec = VectorScale(direction_vec, 10);
    trace = bullettrace(eye, eye + direction_vec, 0, undefined);

    if(isdefined(level.zombie_spawners))
    {
        if(isdefined(level.fn_custom_zombie_spawner_selection))
        {
            spawner = [[level.fn_custom_zombie_spawner_selection]]();
        }
        else if(isdefined(level.use_multiple_spawns) && level.use_multiple_spawns)
        {
            if(isdefined(level.spawner_int) && (isdefined(level.zombie_spawn[level.spawner_int].size) && level.zombie_spawn[level.spawner_int].size))
            {
                spawner = Array::random(level.zombie_spawn[level.spawner_int]);
            }
            else
            {
                spawner = Array::random(level.zombie_spawners);
            }
        }
        else
        {
            spawner = Array::random(level.zombie_spawners);
        }
        ai = zombie_utility::spawn_zombie(spawner, spawner.targetname);
    }

    if (isDefined(ai))
    {
        wait 0.25;

        ai.origin = trace["position"];
        ai.angles = player.angles + vectorScale((0, 1, 0), 180);
        ai zombie_utility::set_zombie_run_cycle("run");

        ai forceteleport(trace["position"], player.angles + vectorScale((0, 1, 0), 180));
        wait .1;
        ai.find_flesh_struct_string = "find_flesh";
        ai doDamage(1, ai.origin, player);
    }
}

KillAllZombies()
{
    foreach(zombie in GetAITeamArray(level.zombie_team))
    {
        if(isdefined(zombie))
        {
            zombie dodamage(zombie.maxhealth + 666, zombie.origin, self);
            zombie kill();
        }
    }
    self iPrintLnBold("All Zombies ^1Killed");
}

AllZMToCrosshair()
{
    foreach(zombie in GetAITeamArray(level.zombie_team))
    {
        zombie forceteleport(self GetTraceOrigin(), self.angles + vectorScale((0, 1, 0), 180));
    }
    self iPrintLnBold("All Zombies ^2Teleported");
}

AllZMToMe()
{
    foreach(zombie in GetAITeamArray(level.zombie_team))
    {
        zombie forceteleport(self GetTraceOrigin(100), self.angles + vectorScale((0, 1, 0), 180));
    }
    self iPrintLnBold("All Zombies ^2Teleported");
}

#include scripts\zm\_zm_powerups;
ToggleZombSpawns()
{
    state = self GetToggleState("No Zombie Spawns");
    if(state)
    {
        level flag::clear("spawn_zombies");
    }
    else
    {
        level flag::set("spawn_zombies");
    }
    level.zombie_total=0;
    level thread zm_powerups::specific_powerup_drop("nuke", self.origin);
}

ZStack()
{
    zombies = getaiteamarray(level.zombie_team);
    Zombiex = zombies[randomint(zombies.size)];
    Zombiex thread DelinkZombsOnDeath();
    if(!isdefined(zombiex))
        return;
    height = 70;
    foreach(zombie in zombies)
    {
        zombie EnableLinkTo();
        if(zombie == zombiex || bool(zombie.chained))
            continue;
        zombie forceteleport(zombiex GetOrigin() + height, zombiex.angles);
        zombie LinkTo(zombiex, "tag_origin", (0,0,height));
        zombie.chained = true;
        height += 70;
    }
    self iPrintLnBold("Zombies ^2Stacked");
}

DelinkZombsOnDeath()
{
    self waittill("death");
    foreach(zombie in getaiteamarray(level.zombie_team))
        zombie unlink();
}
    
ZControl()
{
    level endon(#zbr_devgui);
    self endon("disconnect");
    zombies = GetAITeamArray(level.zombie_team);
    index   = randomint(zombies.size);
    zombiex = zombies[index];
    self setorigin(zombiex GetOrigin());
    self.angles = zombiex.angles;
    zombiex EnableInvulnerability();
    zombiex.maxhealth = 999999;
    zombiex.health = 999999;
    zombiex SetPlayerCollision(false);
    zombiex LinkTo(self);
    zombiex notsolid();
    self hide();
    self.ignoreme = true;
    self setclientthirdperson(true);
    wait 1;
    while(self GetToggleState("Control a Zombie"))
    {
        if(self actionslotthreebuttonpressed())
        {
            index--;
            if(index < 0 || index > getaiteamarray(level.zombie_team).size)
                index = getaiteamarray(level.zombie_team).size - 1;
            zombiex DisableInvulnerability();
            zombiex DoDamage(zombiex.maxhealth + 1, zombiex GetOrigin());
            zombiex unlink();
            zombiex = getaiteamarray(level.zombie_team)[index];
            self setorigin(zombiex GetOrigin());
            self.angles = zombiex.angles;
            zombiex EnableInvulnerability();
            zombiex.maxhealth = 999999;
            zombiex.health = 999999;
            zombiex SetPlayerCollision(false);
            zombiex LinkTo(self);
            zombiex notsolid();
            while(self actionslotthreebuttonpressed())
            {
                wait .0125;
                waittillframeend;
            }
        }
        else if(self actionslotfourbuttonpressed())
        {
            index++;
            if(index > getaiteamarray(level.zombie_team).size)
                index = 0;
            zombiex DisableInvulnerability();
            zombiex DoDamage(zombiex.maxhealth + 1, zombiex GetOrigin());
            zombiex unlink();
            zombiex = getaiteamarray(level.zombie_team)[index];
            self setorigin(zombiex GetOrigin());
            self.angles = zombiex.angles;
            zombiex EnableInvulnerability();
            zombiex.maxhealth = 999999;
            zombiex.health = 999999;
            zombiex SetPlayerCollision(false);
            zombiex LinkTo(self);
            zombiex notsolid();
            while(self actionslotfourbuttonpressed())
            {
                wait .0125;
                waittillframeend;
            }
        }
        zombiex.angles = self.angles;
        wait .0125;
        waittillframeend;
    }
    zombiex DisableInvulnerability();
    zombiex DoDamage(zombiex.maxhealth + 1, zombiex GetOrigin());
    zombiex unlink();
    self show();
    self.ignoreme = false;
    self setclientthirdperson(false);
}

ToggleZombieSuperMelee()
{
    level.zm_super_melee = !bool(level.zm_super_melee);
    
    if(level.zm_super_melee)
    {
        foreach(player in level.players)
            player thread ZKnockback();
    }
    
    self iPrintLnBold("Zombie Super Melee " + (level.zm_super_melee ? "^2Enabled" : "^1Disabled"));
}

ZKnockback()
{
    level endon(#zbr_devgui);
    self endon("disconnect");
    while(level.zm_super_melee)
    {
        self waittill("damage", amount, attacker);
        
        if(!level.zm_super_melee)
            return;
        
        if(isDefined(attacker) && attacker.is_zombie)
        {
            self setorigin(self.origin);
            self SetVelocity(((AnglesToForward(VectorToAngles(self Getorigin() - attacker GetOrigin())) + (0,0,5)) * (1337,1337,350)));
        }
    }
}

ToggleZMExploders()
{
    level.zm_exploders = !bool(level.zm_exploders);
    self iPrintLnBold("Zombie Terrorists " + (level.zm_exploders ? "^2Enabled" : "^1Disabled"));
}

ToggleZMSpooky()
{
    level.zm_spooky = !bool(level.zm_spooky);
    self iPrintLnBold("Spooky Zombies " + (level.zm_spooky ? "^2Enabled" : "^1Disabled"));
}

ZmExploder()
{
    if(bool(level.zm_exploders))
        self thread ZDontTouchMe();
    if(bool(level.zm_spooky))
        self thread ZSp00ky();
}
    
ZDontTouchMe()
{
    self util::waittill_any("zombie_melee", "death");
    magicBullet(GetWeapon("launcher_standard_upgraded"), self GetEye(), self.origin, self);
    RadiusDamage(self GetOrigin(), 250, 999999, 999999, self);
}

ZSp00ky()
{
    level endon(#zbr_devgui);
    self endon("death");
    self thread ZRSpook();
    while(bool(level.zm_spooky))
    {
        self hide();
        self stopsounds();
        self util::waittill_any("zombie_melee", "rspook");
        self show();
        wait .25;
    }
}

ZRSpook()
{
    self endon("death");
    val = 0;
    while(bool(level.zm_spooky))
    {
        val = randomintrange(2, 4);
        wait val;
        self notify("rspook");
    }
}

#include scripts\shared\laststand_shared;
ToggleAutoRes()
{
    self endon("disconnect");
    level endon(#zbr_devgui);
    while(self GetToggleState("Auto-Revive Players"))
    {
        foreach(player in level.players)
        {
            if(player laststand::player_is_in_laststand())
                self ZM_RevivePlayer(player);
        }
        wait 1;
    }
}
#endif