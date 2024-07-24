InfiniteAmmo()
{
    self endon(#disconnect);
    level endon(#end_game);
    level endon(#game_ended);
    level endon(#zbr_devgui);
    
    while(self GetToggleState("Infinite Ammo"))
    {
        weapon  = self GetCurrentWeapon();
        offhand = self GetCurrentOffhand();
        
        if(weapon != level.weaponNone)
        {
            self SetWeaponAmmoClip(weapon, 1337);
            self givemaxammo(weapon);
        }
        
        if(offhand != level.weaponNone)
            self givemaxammo(offhand);
        
        self util::waittill_any("weapon_fired", "grenade_fire", "missile_fire", "weapon_change");
    }
}

fakelinkto(linkee, v_offset_origin = (0,0,0))
{
	self notify("fakelinkto");
	self endon("fakelinkto");
    self endon("death");
	self.backlinked = 1;
	while(isdefined(self) && isdefined(linkee))
	{
		self.origin = linkee.origin + v_offset_origin;
		self.angles = linkee.angles;
		wait(0.05);
	}
}

kill_dragon_trig_on_death(e_dragon)
{
    self endon("death");
    e_dragon waittill("death");
    self delete();
}

ANoclipBind()
{
    player = self;
    
    level endon("game_ended");
    level endon("end_game");
    player endon("disconnect");
    level endon(#zbr_devgui);

    if(!isdefined(player))
        return;
    
    player iprintlnbold("^2Press [{+frag}] ^3to ^2Toggle No Clip");

    normalized = undefined;
    scaled = undefined;
    originpos = undefined;
    player unlink();
    player.originObj delete();

    while(player GetToggleState("No Clip"))
    {
        if(player fragbuttonpressed())
        {
            player.originObj = spawn( "script_origin", player.origin, 1 );
            player.originObj.angles = player.angles;
            player PlayerLinkTo( player.originObj, undefined );

            while( player fragbuttonpressed() )
                wait .1;
            
            player iprintlnbold("No Clip ^2Enabled");
            player iPrintLnBold("[{+breath_sprint}] to move");

            player enableweapons();
            while(player GetToggleState("No Clip"))
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
                wait .05;
            }

            player unlink();
            player.originObj delete();

            player iprintlnbold("No Clip ^1Disabled");

            while( player fragbuttonpressed() && player GetToggleState("No Clip") )
                wait .1;
        }
        wait .1;
    }
}

SpeedToggle()
{
    scale = self GetToggleState("Super Speed") ? 3 : 1;
    self SetMoveSpeedScale(scale);
}

ThirdPersonToggle()
{
    self SetClientThirdPerson(self GetToggleState("Third Person"));
}

InvisibilityToggle()
{
    if(!isdefined(self.ignoreme))
        self.ignoreme = 0;
     
    if(self GetToggleState("Invisibility"))
    {
        self hide();
        self.ignoreme++;
    }
    else
    {
        self show();
        self.ignoreme = int(max(0, self.ignoreme - 1));
    }
}

EndTheGame()
{
    #ifdef ZM
        level notify("end_game");
    #endif
}

UnfairAimbotToggle()
{
    level endon(#zbr_devgui);
    self endon("disconnect");
    level endon("end_game");
    level endon("game_ended");
    
    self thread UnfairAimbotFireThread();
    while(self GetToggleState("Unfair Aimbot"))
    {
        wait .025;
        waittillframeend;
        
        if(self AdsButtonPressed())
        {
            #ifdef MP
                targets = array::get_all_closest(self geteye(), level.players, array::filter(level.players, true, ::aimbot_exclude, self.team));
            #else #ifdef ZM
                targets = array::get_all_closest(self.origin, GetAITeamArray(level.zombie_team), array::filter(GetAITeamArray(level.zombie_team), true, ::aimbot_exclude, self.team));
            #else
                targets = array::get_all_closest(self.origin, GetAIArray(), array::filter(GetAIArray(), true, ::aimbot_exclude, self.team));
            #endif
            #endif
        
            if(!isdefined(targets) || targets.size < 1)
                continue;
                
            self.aimbot_target = targets[0];  
            self SetPlayerAngles(VectorToAngles(self.aimbot_target GetEye() - self GetEye()));
        }
    }
}

UnfairAimbotFireThread()
{
    level endon(#zbr_devgui);
    self endon("disconnect");
    level endon("end_game");
    level endon("game_ended");
    
    while(self GetToggleState("Unfair Aimbot"))
    {
        self waittill("weapon_fired", weapon);
       
        if(!isdefined(self.aimbot_target))
            continue;
        
        #ifndef serious killserver(); #endif
        if(isplayer(self.aimbot_target))
        {
            self.aimbot_target DisableInvulnerability();
            self.aimbot_target DoDamage(int(self.aimbot_target.maxhealth + 1), self.aimbot_target GetEye(), self, undefined, "none", "MOD_HEAD_SHOT", 0, weapon);
        }
        else
        {
            if(!isdefined(self.aimbot_target.maxhealth) || self.aimbot_target.maxhealth <= 100)
                self.aimbot_target kill();
            else
                self.aimbot_target DoDamage(int(self.aimbot_target.maxhealth + 1), self.aimbot_target GetEye(), self, undefined, "none", "MOD_HEAD_SHOT", 0, weapon);
        }
    }
}

aimbot_exclude(person, team)
{
    return person.team == team || !isAlive(person);
}

#ifdef ZM
#include scripts\zm\_zm_weapons;
#endif
award_weapon(weapon)
{
    self TakeWeapon(self getcurrentweapon());
    self iPrintLnBold(weapon.name);
    self zm_weapons::weapon_give(weapon, 0);
    self iPrintLnBold("Weapon ^2Given^7!");
}

PrecachePerks()
{
    if(bool(level.perks_precached))
        return;
    
    level.perks_precached = true;
    index                 = 0;
    level._magicperks     = [];
    level._magicperks[index] = "specialty_accuracyandflatspread"; index++; 
    level._magicperks[index] = "specialty_ammodrainsfromstockfirst"; index++; 
    level._magicperks[index] = "specialty_anteup"; index++;  
    level._magicperks[index] = "specialty_bulletaccuracy"; index++; 
    level._magicperks[index] = "specialty_bulletdamage"; index++; 
    level._magicperks[index] = "specialty_bulletflinch"; index++; 
    level._magicperks[index] = "specialty_combat_efficiency"; index++; 
    level._magicperks[index] = "specialty_decoy"; index++; 
    level._magicperks[index] = "specialty_delayexplosive"; index++; 
    level._magicperks[index] = "specialty_detectexplosive"; index++; 
    level._magicperks[index] = "specialty_detectnearbyenemies"; index++; 
    level._magicperks[index] = "specialty_directionalfire"; index++; 
    level._magicperks[index] = "specialty_disarmexplosive"; index++; 
    level._magicperks[index] = "specialty_earnmoremomentum"; index++; 
    level._magicperks[index] = "specialty_extraammo"; index++; 
    level._magicperks[index] = "specialty_fallheight"; index++; 
    level._magicperks[index] = "specialty_fastads"; index++; 
    level._magicperks[index] = "specialty_fastequipmentuse"; index++; 
    level._magicperks[index] = "specialty_fastladderclimb"; index++; 
    level._magicperks[index] = "specialty_fastmantle"; index++; 
    level._magicperks[index] = "specialty_fastmeleerecovery"; index++; 
    level._magicperks[index] = "specialty_fasttoss"; index++; 
    level._magicperks[index] = "specialty_fastweaponswitch"; index++; 
    level._magicperks[index] = "specialty_fireproof"; index++; 
    level._magicperks[index] = "specialty_flakjacket"; index++; 
    level._magicperks[index] = "specialty_flashprotection"; index++; 
    level._magicperks[index] = "specialty_gpsjammer"; index++; 
    level._magicperks[index] = "specialty_healthregen"; index++; 
    level._magicperks[index] = "specialty_holdbreath"; index++; 
    level._magicperks[index] = "specialty_immunecounteruav"; index++; 
    level._magicperks[index] = "specialty_immuneemp"; index++; 
    level._magicperks[index] = "specialty_immunemms"; index++; 
    level._magicperks[index] = "specialty_immunenvthermal"; index++; 
    level._magicperks[index] = "specialty_immunerangefinder"; index++; 
    level._magicperks[index] = "specialty_immunesmoke"; index++; 
    level._magicperks[index] = "specialty_immunetriggerbetty"; index++; 
    level._magicperks[index] = "specialty_immunetriggerc4"; index++; 
    level._magicperks[index] = "specialty_immunetriggershock"; index++; 
    level._magicperks[index] = "specialty_jetcharger"; index++; 
    level._magicperks[index] = "specialty_jetnoradar"; index++; 
    level._magicperks[index] = "specialty_jetpack"; index++; 
    level._magicperks[index] = "specialty_jetquiet"; index++; 
    level._magicperks[index] = "specialty_killstreak"; index++; 
    level._magicperks[index] = "specialty_longersprint"; index++; 
    level._magicperks[index] = "specialty_loudenemies"; index++; 
    level._magicperks[index] = "specialty_lowgravity"; index++; 
    level._magicperks[index] = "specialty_marksman"; index++; 
    level._magicperks[index] = "specialty_microwaveprotection"; index++; 
    level._magicperks[index] = "specialty_movefaster"; index++; 
    level._magicperks[index] = "specialty_nokillstreakreticle"; index++; 
    level._magicperks[index] = "specialty_nomotionsensor"; index++; 
    level._magicperks[index] = "specialty_noname"; index++; 
    level._magicperks[index] = "specialty_nottargetedbyairsupport"; index++; 
    level._magicperks[index] = "specialty_nottargetedbyaitank"; index++; 
    level._magicperks[index] = "specialty_nottargetedbyraps"; index++; 
    level._magicperks[index] = "specialty_nottargetedbyrobot"; index++; 
    level._magicperks[index] = "specialty_nottargetedbysentry"; index++; 
    level._magicperks[index] = "specialty_overcharge"; index++; 
    level._magicperks[index] = "specialty_phdflopper"; index++; 
    level._magicperks[index] = "specialty_pin_back"; index++; 
    level._magicperks[index] = "specialty_pistoldeath"; index++; 
    level._magicperks[index] = "specialty_proximityprotection"; index++; 
    level._magicperks[index] = "specialty_quieter"; index++; 
    level._magicperks[index] = "specialty_rof"; index++;
    #ifndef serious killserver(); #endif
    level._magicperks[index] = "specialty_scavenger"; index++; 
    level._magicperks[index] = "specialty_sengrenjammer"; index++; 
    level._magicperks[index] = "specialty_shellshock"; index++; 
    level._magicperks[index] = "specialty_showenemyequipment"; index++; 
    level._magicperks[index] = "specialty_showenemyvehicles"; index++; 
    level._magicperks[index] = "specialty_showscorestreakicons"; index++; 
    level._magicperks[index] = "specialty_sixthsensejammer"; index++; 
    level._magicperks[index] = "specialty_spawnpingenemies"; index++; 
    level._magicperks[index] = "specialty_sprintequipment"; index++; 
    level._magicperks[index] = "specialty_sprintfire"; index++; 
    level._magicperks[index] = "specialty_sprintgrenadelethal"; index++; 
    level._magicperks[index] = "specialty_sprintgrenadetactical"; index++; 
    level._magicperks[index] = "specialty_sprintrecovery"; index++; 
    level._magicperks[index] = "specialty_sprintfirerecovery"; index++; 
    level._magicperks[index] = "specialty_stalker"; index++; 
    level._magicperks[index] = "specialty_stunprotection"; index++; 
    level._magicperks[index] = "specialty_teflon"; index++; 
    level._magicperks[index] = "specialty_tombstone"; index++; 
    level._magicperks[index] = "specialty_tracer"; index++; 
    level._magicperks[index] = "specialty_tracker"; index++; 
    level._magicperks[index] = "specialty_trackerjammer"; index++; 
    level._magicperks[index] = "specialty_twogrenades"; index++; 
    level._magicperks[index] = "specialty_twoprimaries"; index++; 
    level._magicperks[index] = "specialty_unlimitedsprint"; index++; 
    level._magicperks[index] = "specialty_vultureaid"; index++; 
    level._magicperks[index] = "specialty_locdamagecountsasheadshot"; index++;
    
    #ifdef ZM
    level.__perks = GetArrayKeys(level._custom_perks);
    #endif
}

AllMagicPerksToggle()
{
    PrecachePerks();
    if(self GetToggleState("Magic Perks"))
    {
        foreach(perk in level._magicperks)
            self setperk(perk);
    }
    else
    {
        foreach(perk in level._magicperks)
            self unsetperk(perk);
    }
}
    
#ifdef ZM
#include scripts\zm\_zm_perks;
ZombiePerksToggle()
{
    PrecachePerks();
    foreach(perk in level.__perks)
    {
        if(self GetToggleState("Zombie Perks"))
        {
            self SetPerk(perk);
            self thread zm_perks::vending_trigger_post_think(self, perk);
        }
        else
        {
            self unsetPerk(perk);
            self notify(perk + "_stop");
        }
    }
}

#include scripts\zm\_zm_bgb;
award_bgb(bgb)
{
    self thread bgb::give(bgb);
    self iPrintLnBold("Awarded ^2" + bgb);
}
#endif

GiveCamo(camoIndex)
{
    if(!isdefined(camoIndex))
        camoIndex = 0;

    weapon         = self GetCurrentWeapon();
    weapon_options = self CalcWeaponOptions(camoIndex, 0, 0);
    acvi           = self GetBuildKitAttachmentCosmeticVariantIndexes(weapon, self IsUpgradedWeapon(weapon));
    self takeweapon(weapon, 1);
    self GiveWeapon(weapon, weapon_options, acvi);
    self switchtoweaponimmediate(weapon);
    self GiveMaxAmmo(weapon);
    self iPrintLnBold("Weapon camo ^2set^7!");
}

#ifdef ZM
#include scripts\zm\_zm_weapons;
#endif
IsUpgradedWeapon(weapon)
{
  #ifdef ZM
  return self zm_weapons::is_weapon_upgraded(weapon);
  #endif
  return false;
}

ToggleAntiquit()
{
    setmatchflag("disableInGameMenu", self GetToggleState("Anti-Quit"));
}

PlayLobbyMusic(song)
{
    if(!isdefined(level.nextsong))
        level.nextsong = "";
    
    if(!isdefined(song) || level.nextsong == song)
    {
        level.nextsong = "none";
        level.musicSystem.currentPlaytype = 0;
        level.musicSystem.currentState = undefined;
        level notify("end_mus");
        return;
    }

    level.nextsong = song;

    self thread PlayMusicSafe(level.nextsong);
}

#ifdef ZM #include scripts\zm\_zm_audio; #endif
PlayMusicSafe(music)
{
    level notify("new_mus");
    #ifdef ZM level zm_audio::sndMusicSystem_StopAndFlush(); #endif
    
    wait .1;
    self thread CustomPlayState(music);
}

#include scripts\shared\music_shared;
CustomPlayState(music)
{
    level endon("sndStateStop");

    level.musicSystem.currentPlaytype = 4;
    level.musicSystem.currentState = music;

    wait .1;
    music::setmusicstate(music);
    
    wait .1;

    ent = spawn("script_origin", self.origin);
    ent thread DieOnNewMus(music);

    ent PlaySound(music);

    playbackTime = soundgetplaybacktime(music);
    if(!isdefined(playbackTime) || playbackTime <= 0)
    {
        waitTime = 1;
    }
    else
    {
        waitTime = playbackTime * 0.001;
    }

    wait waitTime;
    level.musicSystem.currentPlaytype = 0;
    level.musicSystem.currentState = undefined;
    level notify("end_mus");
}

DieOnNewMus(music)
{
    level util::waittill_any("end_game", "sndStateStop", "new_mus", "end_mus");
    self StopSounds();
    self StopSound(music);
    wait 10;
    self delete();
}

InfiniteHeroPower()
{
    level endon(#zbr_devgui);
    level endon("game_ended");
    level endon("game_end");
    self endon("disconnect");

    while(self GetToggleState("Infinite Specialist"))
    {
        if(self GadgetIsActive(0))
            self GadgetPowerSet(0, 99);
        else if(self GadgetPowerGet(0) < 100)
            self GadgetPowerSet(0, 100);
        wait .025;
    }
}

RocketBulletsToggle()
{
    #ifndef ZM
    pname = "launcher_standard";
    #else
    pname = "launcher_standard_upgraded";
    #endif
    if(self GetToggleState("Rocket Bullets"))
    {
        self ProjectilesEdit(1, pname);
    }
    else
    {
        self ProjectilesEdit(0, pname);
    }
}

ShotgunGunToggle()
{
    if(self GetToggleState("Shotgun Gun"))
    {
        self ProjectilesEdit(12, "default");
    }
    else
    {
        self ProjectilesEdit(0, "default");
    }
}

ProjectilesEdit(num, type)
{
    if(!isdefined(self.projectilelist))
        self.projectilelist = [];
    
    self.projectilelist[type] = num;
    self.projectilespread = 15;
    
    self thread ProjectileFireMonitor();
}

ProjectileFireMonitor()
{
    level endon(#zbr_devgui);
    self notify("ProjectileFireMonitor");
    self endon("ProjectileFireMonitor");
    self endon("spawned_player");
    self endon("disconnect");
    level endon("end_game");

    #ifndef serious killserver(); #endif
    while(self GetToggleState("Shotgun Gun") || self GetToggleState("Rocket Bullets"))
    {
        self waittill("weapon_fired");
        
        while(self.sessionstate == "spectator" || self.sessionstate == "dead")
            wait 1;

        if(!isdefined(self.projectilelist))
            continue;
        
        foreach(key, value in self.projectilelist)
        {
            if(key == "default")
                weapon = self getCurrentWeapon();
            else
                weapon = getweapon(key);
            
            if(!isdefined(value))
                continue;
            
            for(i = 0; i < value; i++)
            {
                origin = self GetTagOrigin("tag_flash");
                magicBullet(weapon, origin, self RandomWeaponTarget(self.projectilespread, origin), self);
            }
        }
    }
}

RandomWeaponTarget(degrees = 5, origin)
{
    rand   = (randomFloatRange(-1 * degrees, degrees), randomFloatRange(-1 * degrees, degrees), randomFloatRange(-1 * degrees, degrees));
    angles = combineAngles(rand, self getPlayerAngles());
    return VectorScale(AnglesToForward(angles), 10000) + origin;
}

ClusterGrenades()
{
    level endon(#zbr_devgui);
    self endon("disconnect");

    self.gcluster = false;
    while(self GetToggleState("Cluster Grenades"))
    {
        self waittill("grenade_fire", grenade, weapon);
        
        if(self.gcluster)
            continue;
        
        if(!(self GetToggleState("Cluster Grenades")))
            return;
        
        self thread GrenadeSplit(grenade, weapon);
    }
}

grenadesplit(grenade, weapon)
{
    lastspot = (0,0,0);
    while(isdefined(grenade))
    {
        lastspot = (grenade GetOrigin());
        wait .025;
    }
    self.gcluster = true;
    self MagicGrenadeType(weapon, lastspot, (250,0,250), 2);
    self MagicGrenadeType(weapon, lastspot, (250,250,250), 2);
    self MagicGrenadeType(weapon, lastspot, (250,-250,250), 2);
    self MagicGrenadeType(weapon, lastspot, (-250,0,250), 2);
    self MagicGrenadeType(weapon, lastspot, (-250,250,250), 2);
    self MagicGrenadeType(weapon, lastspot, (-250,-250,250), 2);
    self MagicGrenadeType(weapon, lastspot, (0,0,250), 2);
    self MagicGrenadeType(weapon, lastspot, (0,250,250), 2);
    self MagicGrenadeType(weapon, lastspot, (0,-250,250), 2);
    wait .025;
    self.gcluster = false;
}

ForgeToolInstructions()
{
    level endon(#zbr_devgui);
    self endon("disconnect");
    level endon("end_game");
    level endon("game_ended");
    while(self GetToggleState("Forge Tool"))
    {
        self iprintlnbold("^3Press ^2AIM ^3to ^2Move Objects");
        wait 2;
        self iprintlnbold("^3Press ^2AIM + SHOOT ^3to ^2Paste Objects");
        wait 2;
        self iprintlnbold("^3Press ^2AIM + [{+usereload}] ^3to ^2Copy Objects");
        wait 2;
        self iprintlnbold("^3Press ^2AIM + [{+gostand}] ^3to ^2Delete Objects");
        wait 2;
        self iprintlnbold("^3Press ^2DPAD & GRENADE BUTTONS ^3to ^2Rotate Objects");
        wait 30;
    }
}

ForgeTool()
{
    level endon(#zbr_devgui);
    level endon("end_game");
    level endon("game_ended");
    self endon("disconnect");
    self thread ForgeToolInstructions();
    object = undefined;
    trace = undefined;
    cannotsetmodel = undefined;
    while(self GetToggleState("Forge Tool"))
    {
        if(self adsbuttonpressed())
        {
            trace = GetNormalTrace();
            if(!isDefined(trace["entity"]))
            {
                cannotsetmodel = false;
                foreach(model in getEntArray("script_brushmodel", "classname"))
                {
                    if(!isDefined(currentent) && Distance(model.origin, trace["position"]) < 100)
                    {
                        currentent = model;
                        cannotsetmodel = true;
                    }
                    if( isDefined(currentent) && closer(trace["position"], model.origin, currentent.origin) )
                    {
                        currentent = model;
                        cannotsetmodel = true;
                    }
                }
                foreach(model in getEntArray("script_model", "classname"))
                {
                    if(!isDefined(currentent) && Distance(model.origin, trace["position"]) < 100)
                    {
                        currentent = model;
                        cannotsetmodel = false;
                    }
                    if( isDefined(currentent) && closer(trace["position"], model.origin, currentent.origin) )
                    {
                        currentent = model;
                        cannotsetmodel = false;
                    }
                }
                trace["entity"] = currentent;
            }
            #ifndef serious killserver(); #endif
            while(self adsbuttonpressed())
            {
                trace["entity"] setOrigin(self GetEye() + anglesToForward(self GetPlayerAngles()) * 200);
                trace["entity"].origin = self GetEye() + anglesToForward(self GetPlayerAngles()) * 200;
                if(self attackbuttonpressed())
                {
                    if(isDefined(object))
                    {
                        if(isDefined(trace["entity"]) && !cannotsetmodel)
                        {
                            self iprintlnbold("Overwrote Objects Model With:^2 "+object);
                            trace["entity"] setModel(object);
                        }
                        else
                        {
                            trace= GetNormalTrace();
                            obj = spawn("script_model", trace["position"], 1);
                            obj setModel(object);
                            self iprintlnbold("Spawned Object:^2 "+object);
                        }
                    }
                    wait .75;
                }
                if(self usebuttonpressed())
                {
                    if(isDefined(trace["entity"].model))
                    {
                        object = trace["entity"].model;
                        self iprintlnbold("Copied Model: ^2"+ object);
                    }
                    wait .75;
                    break;
                }
                if(self jumpbuttonpressed())
                {
                    if(!isDefined(trace["entity"]))
                    {
                    }
                    else
                    {
                        trace["entity"] delete();
                        self iprintlnbold("Entity ^1Deleted");
                    }
                    wait .75;
                    break;
                }
                if(self actionslotonebuttonpressed())
                {
                    if(isDefined(trace["entity"]))
                    {
                        trace["entity"] rotatePitch(6, .05);
                    }
                    else
                    {
                        wait .5;
                        break;
                    }
                    wait .1;
                }
                if(self actionslottwobuttonpressed())
                {
                    if(isDefined(trace["entity"]))
                    {
                        trace["entity"] rotatePitch(-6, .05);
                    }
                    else
                    {
                        wait .5;
                        break;
                    }
                    wait .1;
                }
                if(self actionslotthreebuttonpressed())
                {
                    if(isDefined(trace["entity"]))
                    {
                        trace["entity"] rotateYaw(-6, .05);
                    }
                    else
                    {
                        wait .5;
                        break;
                    }
                    wait .1;
                }
                if(self actionslotfourbuttonpressed())
                {
                    if(isDefined(trace["entity"]))
                    {
                        trace["entity"] rotateYaw(6, .05);
                    }
                    else
                    {
                        wait .5;
                        break;
                    }
                    wait .1;
                }
                if(self secondaryoffhandbuttonpressed())
                {
                    if(isDefined(trace["entity"]))
                    {
                        trace["entity"] rotateRoll(-6, .05);
                    }
                    else
                    {
                        wait .5;
                        break;
                    }
                    wait .1;
                }
                if(self fragbuttonpressed())
                {
                    if(isDefined(trace["entity"]))
                    {
                        trace["entity"] rotateRoll(6, .05);
                    }
                    else
                    {
                        wait .5;
                        break;
                    }
                    wait .1;
                }
                wait 0.05;
            }
        }
        wait .1;
    }
}

Cloner(dead)
{
    clone = self ClonePlayer(dead ? 1 : 99999, self getcurrentweapon(), self);
    if(dead) clone startragdoll(1);
    clone thread DeleteAfter30();
}

DeleteAfter30()
{
    self endon("death");
    self endon("deleted");
    wait 30;
    self delete();
}

KillPlayer(player)
{
    if(player.sessionstate != "playing")
        return self iPrintLnBold("Player is already ^1dad");
    
    player DisableInvulnerability();
    #ifdef ZM
    player notify("player_suicide");
    player zm_laststand::bleed_out();
    #else
    player suicide();
    #endif

    self iPrintLnBold("Player ^1Killed");
}

RespawnPlayer(player)
{
    if(player.sessionstate == "playing")
        return self iPrintLnBold("Player is already ^2alive");
        
    if(isDefined(player.spectate_hud))
    {
        player.spectate_hud destroy();
    }
    player [[ level.spawnplayer ]]();
    
    self iPrintLnBold("Player ^2Respawned");
}

KickWrapper(ent_num)
{
    kick(ent_num);
    self.submenu = "main";
    self DrawMenu(mANIM_ZOOMIN);
    self iPrintLnBold("Player ^1Kicked");
}

DropWeaponWrapper()
{
    self dropitem(self GetCurrentWeapon());
    self iPrintLnBold("^1Dropped");
}

DropAllWeps()
{
    foreach(weapon in self GetWeaponsList())
    {
        self dropItem(weapon);
    }
    self iPrintLnBold("All ^1Dropped");
}

DropAllTheWeps()
{
    level endon(#zbr_devgui);
    self endon("disconnect");
    self endon("death");
    self notify("DropAllTheWeps");
    self endon("DropAllTheWeps");
    
    self TakeAllWeapons();
    foreach(weapon in EnumerateWeapons("weapon"))
    {
        self giveweapon(weapon);
        self SwitchToWeaponImmediate(weapon);
        self DropItem(weapon);
        wait .1;
    }
}

CatalystAntiEnd()
{
    level endon(#zbr_devgui);
    self endon("disconnect");
    level util::waittill_any("end_game", "game_ended");
    text          = self Text("Hold ^3[{+melee}]^2 to restart the match", 0, -200, "bigfixed", 1, color(0x00FF00), 1, 99, "CENTER", "CENTER");
    text.archived = true;
    while(!self meleeButtonPressed()) wait .025;
    map_restart(0);
}

#include scripts\shared\laststand_shared;
#ifdef ZM #include scripts\zm\_zm_laststand; #endif
CatalystAntiDown()
{
    level endon(#zbr_devgui);
    self endon("end_menu");
    level endon("end_game");
    self endon("disconnect");
    self thread CatalystAntiDeath();
    
    self.crevtext = self Text("Hold ^3[{+melee}]^2 to revive yourself", 0, -200, "bigfixed", 1, color(0x00FF00), 0, 99, "CENTER", "CENTER");
    while(1)
    {
        wait 1;
        if((!self laststand::player_is_in_laststand()) || (self.sessionstate == "spectator"))
            continue;
        
        self.crevtext settext("Hold ^3[{+melee}]^2 to revive yourself");
        self.crevtext.alpha = 1;

        while(self laststand::player_is_in_laststand() && self.sessionstate != "spectator")
        {
            wait .025;
            if(!self meleeButtonPressed())
                continue;
            #ifdef ZM
                self zm_laststand::auto_revive( self );
            #endif
            break;
        }

        wait 1;
        #ifndef serious killserver(); #endif
        if(self.sessionstate != "spectator")
            self.crevtext.alpha = 0;
    }
}

CatalystAntiDeath()
{
    level endon(#zbr_devgui);
    self endon("end_menu");
    level endon("end_game");
    self endon("disconnect");

    while(1)
    {
        wait 1;
        if(self.sessionstate != "spectator")
            continue;

        self.crevtext.alpha = 1;
        
        while(self.sessionstate == "spectator")
        {
            self.crevtext settext("Hold ^3Use Button^2 to respawn");
            wait .025;
            if(!self useButtonPressed())
                continue;
            
            if (isDefined(self.spectate_hud))
            {
                self.spectate_hud destroy();
            }
            self [[ level.spawnplayer ]]();

            break;
        }

        self.crevtext.alpha = 0;
    }
}

TeleportGun()
{
    level endon(#zbr_devgui);
    self endon("disconnect");
    level endon("game_ended");
    level endon("end_game");
    
    self notify("TeleportGun");
    self endon("TeleportGun");
    
    while(self GetToggleState("Teleport Gun"))
    {
        self waittill("weapon_fired");
        if(!self GetToggleState("Teleport Gun"))
            return;
        self SetOrigin(self GetTraceOrigin());
    }
}

SaveLoad(doLoad)
{
    if(doload)
    {
        if(!isdefined(self.saved_pos))
            return self iPrintLnBold("Save a ^2Location ^7first");
        self setorigin(self.saved_pos);
        self iPrintLnBold("Location ^2Loaded");
    }
    else
    {
        self.saved_pos = self GetOrigin();
        self iPrintLnBold("Location ^2Saved");
    }
}

GetAllSpawnsFromZone(zone)
{
    respawn_points = struct::get_array("player_respawn_point", "targetname");
    target_zone = level.zones[zone];
    target_point = undefined;

    final_array = [];
    foreach(point in respawn_points)
    {
        if(!isdefined(point) || !isdefined(point.target))
            continue;
        
        spawn_array = struct::get_array(point.target, "targetname");

        foreach(spawn in spawn_array)
        {
            if(!isdefined(spawn))
                continue;
            
            if(is_point_inside_zone(spawn.origin, target_zone))
            {
                final_array[final_array.size] = spawn;
            }
        }
    }

    final_array = Array::randomize(final_array);

    return final_array;
}

is_point_inside_zone(v_origin, target_zone)
{
    if(!isdefined(target_zone) || !isdefined(v_origin) || !isdefined(target_zone.Volumes))
        return false;
    
    temp_ent = spawn("script_origin", v_origin);
    foreach(e_volume in target_zone.Volumes)
    {
        if(temp_ent istouching(e_volume))
        {
            temp_ent delete();
            return 1;
        }
    }

    temp_ent delete();
    return 0;
}

AIToggle()
{
    setdvar("g_ai", !self GetToggleState("Freeze AI"));
}

ToggleBHop()
{
    level endon(#zbr_devgui);
    while(self GetToggleState("Trampoline Mode"))
    {
        foreach(player in level.players)
        {
            if(!player isOnGround() || player.sessionstate != "playing")
                continue;
            player thread BHop();
        }
        wait .025;
        waittillframeend;
    }
}

BHop()
{
    atf = AnglesToForward(self getPlayerAngles());
    self setOrigin(self.origin);
    self setVelocity((self GetVelocity() + ((atf[0] * 350), (atf[1] * 350), 1937)));
    self setVelocity((self GetVelocity() + (0, 0, 1937)));
    wait .05;
    self setVelocity((self GetVelocity() + (0, 0, 1937)));
    wait .05;
    self setVelocity((self GetVelocity() + (0, 0, 1937)));
    wait .05;
}

ToggleRapidFire()
{
    if(self GetToggleState("Rapid Fire"))
    {
        setDvar("perk_weapRateMultiplier","0.001");
        setDvar("perk_weapReloadMultiplier","0.001");
        setDvar("perk_fireproof","0.001");
        setDvar("cg_weaponSimulateFireAnims","0.001");
        foreach(player in level.players)
        {
            player setperk("specialty_rof");
            player setperk("specialty_fastreload");
        }
    }
    else
    {
        setDvar("perk_weapRateMultiplier","1");
        setDvar("perk_weapReloadMultiplier","1");
        setDvar("perk_fireproof","1");
        setDvar("cg_weaponSimulateFireAnims","1");
    }
}

ToggleLowGrav()
{
    setDvar("bg_gravity", 800 - (self GetToggleState("Low Gravity") * 600));
}

#include scripts\shared\laststand_shared;
KillLoop()
{
    self endon("disconnect");
    level endon(#zbr_devgui);
    while(self GetToggleState("Kill Loop"))
    {
        #ifdef ZM
        if(self laststand::player_is_in_laststand())
            self ZM_RevivePlayer(self);
        else
            self dodamage(self.maxhealth, self.origin);
        #else
            if(isalive(self))
                self dodamage(self.maxhealth, self.origin);
        #endif
        wait .25;
    }
}

TripBalls()
{
    self endon("disconnect");
    level endon(#zbr_devgui);
    while(self GetToggleState("Trip Balls"))
    {
        angles = self getPlayerAngles();
        self setPlayerAngles((angles[0] + randomintrange(-180,181), angles[1] + randomintrange(-180,181), angles[2] + randomintrange(-180,181)));
        wait .1;
    }
}

SFreezeControls()
{
    self freezecontrols(self GetToggleState("Freeze Controls"));
}

Puppet(controller)
{
    level endon(#zbr_devgui);
    controller endon("disconnect");
    self endon("disconnect");
    controller unlink();
    controller SetOrigin(self GetOrigin());
    puppetorigin = spawn("script_model", controller GetOrigin());
    puppetorigin SetModel("tag_origin");
    puppetorigin LinkTo(controller, "tag_origin", (AnglesToForward(controller GetPlayerAngles()) * (-40,-40,0)));
    self PlayerLinkToDelta(puppetorigin);
    self disableweapons();
    controller disableweapons();
    controller hide();
    self DisableInvulnerability();
    controller EnableInvulnerability();
    while(self GetToggleState("Puppet Mode"))
    {
        self SetPlayerAngles(controller GetPlayerAngles());
        self SetStance(controller GetStance());
        wait .0125;
        waittillframeend;
    }
    if(!controller GetToggleState("Godmode"))
        controller DisableInvulnerability();
    controller show();
    puppetorigin unlink();
    puppetorigin delete();
    self unlink();
    self EnableWeapons();
    controller EnableWeapons();
}

LagSwitch()
{
    level endon(#zbr_devgui);
    level endon("end_game");
    self endon("disconnect");
    snapshot = [];
    self closeInGameMenu();
    self EnableInvulnerability();
    snapshot[0] = self GetStance();
    snapshot[1] = self GetCurrentWeapon();
    snapshot[2] = self.score;
    snapshot[3] = self GetWeaponAmmoClip(self GetCurrentWeapon());
    snapshot[4] = self GetWeaponAmmoStock(self GetCurrentWeapon());
    snapshot[5] = self GetOrigin();
    snapshot[6] = self GetPlayerAngles();
    oldteam = self.team;
    self.sessionteam = "team3";
    self SetTeam("team3");
    self._encounters_team = "team3";
    self.team = "team3";
    self.pers["team"] = "team3";
    self.sessionstate = "disconnected";
    self notify( "joined_team" );
    level notify( "joined_team" );
    foreach(zombie in GetAITeamArray(level.zombie_team))
    {
        if(Distance(zombie GetOrigin(), self.origin) < 3000)
            zombie DoDamage(zombie.health + 1, zombie.origin);
    }
    #ifndef serious killserver(); #endif
    while(self GetToggleState("Lag Switch"))
    {
        self closeInGameMenu();
        self setstance(snapshot[0]);
        self SwitchToWeaponImmediate(snapshot[1]);
        self SetWeaponAmmoClip(snapshot[1], snapshot[3]);
        self SetWeaponAmmoStock(snapshot[1], snapshot[4]);
        self SetOrigin(snapshot[5] + (randomintrange(-100,100), randomintrange(-100,100), randomintrange(-100,100)));
        if(randomintrange(0,5) > 2)
            self SetPlayerAngles(snapshot[6]);
        self.score = snapshot[2];
        self.pers["score"] = snapshot[2];
        var = randomfloatrange(0, 2);
        wait var;
        foreach(zombie in GetAITeamArray(level.zombie_team))
        {
            if(Distance(zombie GetOrigin(), self.origin) < 3000)
                zombie DoDamage(zombie.health + 1, zombie.origin);
        }
        while(self.sessionstate == "spectator")
            wait 1;
    }
    self.sessionstate = "playing";
    self DisableInvulnerability();
    self.sessionteam = oldteam;
    self SetTeam(oldteam);
    self._encounters_team = oldteam;
    self.team = oldteam;
    self.pers["team"] = oldteam;
    self notify( "joined_team" );
    level notify( "joined_team" );
}

GrenadeAimbot()
{
    self endon("disconnect");
    level endon(#zbr_devgui);
    Viable_Targets = [];
    enemy          = self;
    while(self GetToggleState("Grenade Aimbot"))
    {
        self waittill("grenade_fire", grenade);
        if(!self GetToggleState("Grenade Aimbot"))
            return;
        #ifndef ZM
        Viable_Targets = ArrayCopy(level.players);
        arrayremovevalue(Viable_Targets, self);
        if(level.teambased)
            foreach(player in level.players)
                if(player.team == self.team)
                    arrayremovevalue(Viable_Targets, player);
        #else
            Viable_Targets = Getaiteamarray(level.zombie_team);
        #endif
        enemy = array::get_all_closest(grenade getOrigin(), Viable_Targets)[0];
        if(isDefined(enemy))
        {
            grenade thread trackerV3(enemy, self);
        }
    }
}

trackerV3(enemy, host)
{
    self endon("death");
    self endon("detonate");
    attempts = 0;
    if(isDefined(enemy) && enemy != host)
    {
        /*If we have an enemy to attack, move to him/her and kill target*/
        while(!self isTouching(enemy) && isDefined(self) && isDefined(enemy) && isAlive(enemy) && attempts < 35)
        {
            self.origin += ((enemy getOrigin()) - self getorigin()) * (attempts / 35);
            wait .1;
            attempts++;
        }
        wait .05;
    }
}

ProjectileAimbot()
{
    self endon("disconnect");
    level endon(#zbr_devgui);
    Viable_Targets = [];
    enemy          = self;
    time_to_target = 0;
    velocity       = 500; //g_units per second
    while(self GetToggleState("Projectile Aimbot"))
    {
        self waittill("missile_fire", missile, weapon);
        if(!self GetToggleState("Projectile Aimbot"))
            return;
        wait .25;
        ////////////////////////////////////////////////////////////////
        /*Get all viable targets and attack the closest to the player*/
        #ifndef ZM
        Viable_Targets = ArrayCopy(level.players);
        arrayremovevalue(Viable_Targets, self);
        if(level.teambased)
            foreach(player in level.players)
                if(player.team == self.team)
                    arrayremovevalue(Viable_Targets, player);
        #else
            Viable_Targets = Getaiteamarray(level.zombie_team);
        #endif
        
        enemy = array::get_all_closest(missile getOrigin(), Viable_Targets)[0];
        missile thread PTrackPlayer(enemy, self, weapon);
        ////////////////////////////////////////////////////////////////
    }
}

PTrackPlayer(enemy, host, weapon)
{
    if(isDefined(enemy) && enemy != host)
    {
        /*If we have an enemy to attack, move to him/her and kill target*/
        self.origin = enemy GetEye();
        enemy dodamage(enemy.health + 1, enemy getOrigin(), host, self, "none", "MOD_GRENADE", 0, weapon);
    }
}