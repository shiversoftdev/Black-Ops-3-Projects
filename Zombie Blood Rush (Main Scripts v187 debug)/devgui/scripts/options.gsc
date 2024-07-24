#include scripts\shared\hud_message_shared;
#include scripts\shared\popups_shared;
#include scripts\zm\_util;
#include scripts\shared\lui_shared;

precacheoptions()
{
    AddMenu("none", "main", "ZBR Devgui");
    
    if(!isdefined(self.submenu) || self.submenu == "none")
        return;
        
    menuId = self GetMenu().i;
    switch(menuId)
    {
        case "main":
            AddSubmenu(menuId, "zbr", "Development Options");
            AddSubmenu(menuId, "personal", "Personal Options");
            AddSubmenu(menuId, "weapons", "Weaponry");
            AddSubmenu(menuId, "fun", "Fun Options", undefined, 2);
            AddSubmenu(menuId, "zombies", "Zombie Options", undefined, 2);
            AddSubmenu(menuId, "lobby", "Lobby Options", undefined, 4);
            AddSubmenu(menuId, "clients", "Client Options", 3);
            break;
        
        case "zbr":
            // AddOption(menuId, "Dev Option", function() => 
            // {
            //     // level.serious_example = [];
            //     // level.serious_example[0] = spawn("script_model", (0, 0, 0));
            //     // wait 0.25;
            //     // level.serious_example[0] delete();
            //     // level.serious_example[0].damage_state = true; // should crash the vm
            //     // wait 0.05;
            //     // level.serious_example[0].damage_state = true; // should crash the vm x2
            //     // for(;;)
            //     // {
                    
            //     // }

            //     // zbr_responsemonitor = function() => 
            //     // {
            //     //     self notify(#zbr_responsemonitor);
            //     //     self endon(#zbr_responsemonitor);
            //     //     self endon(#disconnect);
            //     //     for(;;)
            //     //     {
            //     //         self waittill(#menuresponse, menu, response);
            //     //         self iPrintLn(response);
            //     //         if(strstartswith(response, "kbmr"))
            //     //         {
            //     //             self notify(#kbmr, getsubstr(response, 4));
            //     //         }
            //     //     }
            //     // };

            //     // array::thread_all(getplayers(), zbr_responsemonitor);

            //     // if(level.zbr_get_keyboard_response is function)
            //     // {
            //     //     response = self [[ level.zbr_get_keyboard_response ]]("Test Keyboard", "input", 128);
            //     // }
            // });

            AddSubmenu(menuId, "wu", "Weapons Unified");
            AddSubmenu(menuId, "mb", "Mapbuilding");
            AddOption(menuId, "Lock Objective", serious::SimpleToggle, "Lock Objective", function() =>
            {
                self endon(#disconnect);
                level endon(#end_game);
                level endon(#game_ended);
                level endon(#zbr_devgui);
                
                while(self GetToggleState("Lock Objective"))
                {
                    self.gm_objective_timesurvived = 0;
                    wait 0.05;
                }
            });
            AddOption(menuId, "Disable sudden death", serious::SimpleToggle, "Disable sudden death", function() => { level.zbr_no_sudden_death_debug = self GetToggleState("Disable sudden death"); });
            AddOption(menuId, "Damage Testers", serious::SimpleToggle, "Damage Testers", function() =>
            {
                self endon(#disconnect);
                level endon(#end_game);
                level endon(#game_ended);
                level endon(#zbr_devgui);
                
                while(self GetToggleState("Damage Testers"))
                {
                    foreach(player in getplayers())
                    {
                        if(player IsTestClient() && player.sessionstate == "playing" && player.score < 50000)
                        {
                            player zm_score::add_to_player_score(50000 - player.score, true);
                        }
                    }
                    wait 0.05;
                }
            });
            AddOption(menuId, "Goto Round", function() =>
            {
                rnd = int(self [[ level.zbr_get_keyboard_response ]]("Enter Round Number", "0", 128));
                if(level.zbr_moveround is function)
                {
                    [[ level.zbr_moveround ]](rnd);
                }
            });

            AddOption(menuId, "Testa", function() =>
            {
                level endon(#zbr_devgui);
                // self hud_message::oldnotifymessage("WARNING", "Sudden death approaching...", undefined, (1,0,0), "mp_last_stand", 10);
                // level.players[0].entnum = level.players[0] getEntityNumber();
                // popups::displayteammessagetoall(&"ZMUI_ZBR_PLAYER_KILLED", level.players[0]);
                // self.lowermessage.glowcolor = (1, 0, 0);
                // self.lowermessage.color = (1, 0, 0);
                // self.lowermessage.glowalpha = 1;
                // self util::setlowermessage("test timer", 15, false);
                // wait 15;
                // lui::timer(75, "bled_out", 20, 5, 20);

                //self zm_powerups::specific_powerup_drop("nuke", self.origin);
                // level.killstreaksenabled = true;
                // self thread killstreaks::killstreak_waiter();

                // compiler::script_detour("scripts/mp/killstreaks/_killstreakrules.gsc", #killstreakrules, #iskillstreakallowed, function(asdf, team) => { return true; });
                // self killstreaks::usekillstreak("microwave_turret", 0);
            });

            // foreach(ks in array("ai_tank_drop", "dart", "drone_strike", "emp", "helicopter_comlink", "helicopter_gunner", "minigun", "microwave_turret", "planemortar", "raps", "rcbomb", "remote_missile", "sentinel", "supply_drop", "autoturret"))
            // {
            //     AddOption(menuId, "Give " + ks, function(ks) =>
            //     {
            //         level endon(#zbr_devgui);
            //         // self hud_message::oldnotifymessage("WARNING", "Sudden death approaching...", undefined, (1,0,0), "mp_last_stand", 10);
            //         // level.players[0].entnum = level.players[0] getEntityNumber();
            //         // popups::displayteammessagetoall(&"ZMUI_ZBR_PLAYER_KILLED", level.players[0]);
            //         // self.lowermessage.glowcolor = (1, 0, 0);
            //         // self.lowermessage.color = (1, 0, 0);
            //         // self.lowermessage.glowalpha = 1;
            //         // self util::setlowermessage("test timer", 15, false);
            //         // wait 15;
            //         // lui::timer(75, "bled_out", 20, 5, 20);

            //         //self zm_powerups::specific_powerup_drop("nuke", self.origin);
            //         level.killstreaksenabled = true;
            //         level.usingmomentum = true;
            //         self.selectinglocation = false;
            //         self killstreaks::give(ks);
            //         self killstreaks::usekillstreak(ks);

            //         if(isdefined(level.killstreaks[ks].usefunction))
            //         {
            //             self [[ level.killstreaks[ks].usefunction ]]();
            //         }
            //     }, ks);
            // }
            
        break;
        case "wu":
            wudev_load();
            AddSubmenu(menuId, "wuws", "Select Weapon");
            AddOption(menuId, "Collect Data", serious::wudev_collect);

            AddSubmenu(menuId, "wuwt", "Tune Weapon");

            AddOption(menuId, "Regen Classes", serious::wudev_regen, "classes");
            AddOption(menuId, "Regen Roles", serious::wudev_regen, "roles");
            AddOption(menuId, "Save Data", serious::wudev_save);
        break;
        case "mb":
            AddSubmenu(menuId, "mbs", "Select an Object");
            AddOption(menuId, "Object Placer", serious::SimpleToggle, "Object Placer", serious::mb_perkplacer);
            AddOption(menuId, "Change Pitch", serious::mb_changepitch);
            AddOption(menuId, "Change Model", serious::mb_changemodel);
        break;
        case "mbs":
            mb_init();
            AddOption(menuId, "Clear Object Selection", function() => { 
                mb_clear();
                self iPrintlnbold("Cleared.");
            });
            for(i = 0; i < self.mb_item_perms.size; i++)
            {
                if(!isdefined(self.mb_item_perms[i]) || isString(self.mb_item_perms[i]))
                {
                    continue;
                }
                AddOption(menuId, "Object " + i, serious::mb_retrieve, i);
            }
        break;
        case "wuwt":
            AddOption(menuId, "Body Multiplier", serious::wudev_tune, WU_TUNE_BMP);
            AddOption(menuId, "Head Multiplier", serious::wudev_tune, WU_TUNE_HMP);
            AddOption(menuId, "Weapon Class", serious::wudev_tune, WU_TUNE_CLASS);
            AddOption(menuId, "Weapon Role", serious::wudev_tune, WU_TUNE_ROLE);
        break;
        case "wuws":
            AddOption(menuId, "Manual Selection", function() =>
            {
                name = self [[ level.zbr_get_keyboard_response ]]("Enter Weapon Name", "none", 128);
                if(getweapon(name) == level.weaponnone)
                {
                    return;
                }
                serious::wudev_adjust(getweapon(name));
            });
            foreach(weapon in arraycombine(EnumerateWeapons("weapon"), EnumerateWeapons("weaponfull"), 0, 0))
            {
                if(issubstr(weapon.name, "dualoptic"))
                {
                    continue;
                }

                if(issubstr(weapon.name, "upgraded") || issubstr(weapon.name, "_up"))
                    continue;

                name = weapon.name; // isdefined(weapon.displayname) ? MakeLocalizedString(weapon.displayname) : "";
                if(name == "") name = weapon.name;
                
                AddOption(menuId, name, serious::wudev_adjust, weapon);
            }

            foreach(weapon in arraycombine(EnumerateWeapons("weapon"), EnumerateWeapons("weaponfull"), 0, 0))
            {
                if(issubstr(weapon.name, "dualoptic"))
                {
                    continue;
                }

                if(!(issubstr(weapon.name, "upgraded") || issubstr(weapon.name, "_up")))
                    continue;

                name = weapon.name; // isdefined(weapon.displayname) ? MakeLocalizedString(weapon.displayname) : "";
                if(name == "") name = weapon.name;
                
                AddOption(menuId, name, serious::wudev_adjust, weapon);
            }
        break;
        case "personal":
            AddOption(menuId, "Godmode", serious::SimpleToggle, "Godmode", sys::EnableInvulnerability, sys::DisableInvulnerability);
            AddOption(menuId, "Infinite Ammo", serious::SimpleToggle, "Infinite Ammo", serious::InfiniteAmmo);
            AddOption(menuId, "No Clip", serious::SimpleToggle, "No Clip", serious::ANoclipBind);
            AddOption(menuId, "Infinite Specialist", serious::SimpleToggle, "Infinite Specialist", serious::InfiniteHeroPower);
            AddOption(menuId, "Unfair Aimbot", serious::SimpleToggle, "Unfair Aimbot", serious::UnfairAimbotToggle);
            AddOption(menuId, "Grenade Aimbot", serious::SimpleToggle, "Grenade Aimbot", serious::GrenadeAimbot);
            AddOption(menuId, "Projectile Aimbot", serious::SimpleToggle, "Projectile Aimbot", serious::ProjectileAimbot);
            AddOption(menuId, "Super Speed", serious::SimpleToggle, "Super Speed", serious::SpeedToggle, serious::SpeedToggle);
            AddOption(menuId, "Third Person", serious::SimpleToggle, "Third Person", serious::ThirdPersonToggle, serious::ThirdPersonToggle);
            AddOption(menuId, "Invisibility", serious::SimpleToggle, "Invisibility", serious::InvisibilityToggle, serious::InvisibilityToggle);
            AddOption(menuId, "Magic Perks", serious::SimpleToggle, "Magic Perks", serious::AllMagicPerksToggle, serious::AllMagicPerksToggle);
            AddOption(menuId, "Zombie Perks", serious::SimpleToggle, "Zombie Perks", serious::ZombiePerksToggle, serious::ZombiePerksToggle);
            AddSubmenu(menuId, "give_points", "Adjust Points");
            break;
            
         case "give_points":
                AddOption(menuId, "Give 100 Points", serious::AdjustPoints, 100);
                AddOption(menuId, "Give 1000 Points", serious::AdjustPoints, 1000);
                AddOption(menuId, "Give 10000 Points", serious::AdjustPoints, 10000);
                AddOption(menuId, "Give 100000 Points", serious::AdjustPoints, 100000);
                AddOption(menuId, "Give 1000000 Points", serious::AdjustPoints, 1000000);
                AddOption(menuId, "Give Max Points", serious::AdjustPoints, 10000000);
                AddOption(menuId, "Take Max Points", serious::AdjustPoints, -10000000);
                AddOption(menuId, "Take 1000000 Points", serious::AdjustPoints, -1000000);
                AddOption(menuId, "Take 100000 Points", serious::AdjustPoints, -100000);
                AddOption(menuId, "Take 10000 Points", serious::AdjustPoints, -10000);
                AddOption(menuId, "Take 1000 Points", serious::AdjustPoints, -1000);
                AddOption(menuId, "Take 100 Points", serious::AdjustPoints, -100);
            break;

         case "weapons":
            AddSubmenu(menuId, "give_weapons", "Give Weapon");
            AddSubmenu(menuId, "give_weapons_upgraded", "Give Upgraded Weapon");
            AddSubmenu(menuId, "give_camo", "Give Camo");
            AddSubmenu(menuId, "give_gums", "Give Gobblegum");
            AddSubmenu(menuId, "give_aat", "Give AAT");
            AddOption(menuId, "Shotgun Gun", serious::SimpleToggle, "Shotgun Gun", serious::ShotgunGunToggle, serious::ShotgunGunToggle);
            AddOption(menuId, "Rocket Bullets", serious::SimpleToggle, "Rocket Bullets", serious::RocketBulletsToggle, serious::RocketBulletsToggle);
            AddOption(menuId, "Cluster Grenades", serious::SimpleToggle, "Cluster Grenades", serious::ClusterGrenades);
            AddOption(menuId, "Drop Current Weapon", serious::DropWeaponWrapper);
            AddOption(menuId, "Drop All Your Weapons", serious::DropAllWeps);
            AddOption(menuId, "Drop All The Weapons", serious::DropAllTheWeps);
         case "give_weapons":
            AddOption(menuId, "Manual Selection", function() =>
            {
                name = self [[ level.zbr_get_keyboard_response ]]("Enter Weapon Name", "none", 128);
                if(getweapon(name) == level.weaponnone)
                {
                    return;
                }
                serious::award_weapon(getweapon(name));
            });
            foreach(weapon in arraycombine(EnumerateWeapons("weapon"), EnumerateWeapons("weaponfull"), 0, 0))
            {
                if(issubstr(weapon.name, "upgraded") || issubstr(weapon.name, "_up"))
                    continue;

                if(issubstr(weapon.name, "dualoptic"))
                {
                    continue;
                }
                
                name = isdefined(weapon.displayname) ? MakeLocalizedString(weapon.displayname) : "";
                if(name == "") name = weapon.name;
                
                AddOption(menuId, name, serious::award_weapon, weapon);
            }
            break;
        case "give_weapons_upgraded":
            foreach(weapon in arraycombine(EnumerateWeapons("weapon"), EnumerateWeapons("weaponfull"), 0, 0))
            {
                if(!(issubstr(weapon.name, "upgraded") or issubstr(weapon.name, "_up")))
                    continue;

                if(issubstr(weapon.name, "dualoptic"))
                {
                    continue;
                }
                    
                name = isdefined(weapon.displayname) ? MakeLocalizedString(weapon.displayname) : "";
                if(name == "") name = weapon.name;
                AddOption(menuId, name, serious::award_weapon, weapon);
            }
            break;
        case "give_camo":
            foreach(k, v in level._camos_)
            {
                AddOption(menuId, k, serious::GiveCamo, v);
            }
            break;
        case "give_aat":
            #ifdef ZM
                foreach(aat in getArrayKeys(level.AAT))
                    AddOption(menuId, "Give " + MakeLocalizedString(aat), serious::AwardAAT, aat);
            #endif
        break;
        case "fun":
            AddOption(menuId, "Forge Tool", serious::SimpleToggle, "Forge Tool", serious::ForgeTool);
            AddOption(menuId, "Teleport Gun", serious::SimpleToggle, "Teleport Gun", serious::TeleportGun);
            AddOption(menuId, "Save Location", serious::SaveLoad, false);
            AddOption(menuId, "Load Location", serious::SaveLoad, true);
            break;
        case "give_gums":
            foreach(bgb in getArrayKeys(level.bgb))
            {
                #ifdef ZM AddOption(menuId, MakeLocalizedString(bgb), serious::award_bgb, bgb); #endif
            }
            break;
        case "clients":
            for(i = 0; i < 18; i++)
            {
                player = level.players[i];
                if(isdefined(player))
                    AddSubmenu(menuId, mToClient("client", i), player.name, player);
                else
                    ClearOption(menuId, i);
            }
            break;
        case "lobby":
            AddOption(menuId, "Add Bot", sys::AddTestClient);
            AddSubmenu(menuId, "play_music", "Play Music");
            #ifdef ZM 
                if(!bool(level._all_parts))
                    AddOption(menuId, "Collect All Parts", serious::CollectParts);
                if(!bool(level._doors_done))
                    AddOption(menuId, "Open All Doors", serious::OpenTheDoors);
                if(!bool(level._power_done))
                    AddOption(menuId, "Turn On Power", serious::AllPower);
                AddOption(menuId, "No Zombie Spawns", serious::SimpleToggle, "No Zombie Spawns", serious::ToggleZombSpawns, serious::ToggleZombSpawns);
                AddOption(menuId, "Auto-Revive Players", serious::SimpleToggle, "Auto-Revive Players", serious::ToggleAutoRes);
            #endif
            AddOption(menuId, "Freeze AI", serious::SimpleToggle, "Freeze AI", serious::AIToggle, serious::AIToggle);
            AddOption(menuId, "Anti-Quit", serious::SimpleToggle, "Anti-Quit", serious::ToggleAntiquit, serious::ToggleAntiquit);
            #ifndef SP AddOption(menuId, "End Game", serious::EndTheGame); #endif
            AddOption(menuId, "Fast Restart", sys::map_restart, 0);
            AddOption(menuId, "Exit Level", sys::ExitLevel, 0);
            break;
            
        case "play_music":
            foreach(k, v in level._cmusic)
            {
                AddOption(menuId, MakeLocalizedString(v), serious::PlayLobbyMusic, k);
            }
            break;
        case "teleport":
            foreach(k, v in level._teleto)
            {
                AddOption(menuId, k, sys::SetOrigin, v.origin);
            }
            break;
            
        #ifdef ZM
        case "zombies":
            AddOption(menuId, "Spawn a Zombie", serious::SpawnZombieArray, self, 1);
            AddOption(menuId, "Spawn 20 Zombies", serious::SpawnZombieArray, self, 20);
            AddOption(menuId, "Kill All Zombies", serious::KillAllZombies);
            AddOption(menuId, "All to Crosshair", serious::AllZMToCrosshair);
            AddOption(menuId, "All to Me", serious::AllZMToMe);
        break;
        #endif
        default:
            if(IsSubStr(menuId, ";"))
                AddClientMenu(menuId);
            break;
    }
}
    
mToClient(menu, cl)
{
    return menu + ";" + cl;
}
        
AddClientMenu(menu)
{
    player = self GetMenu(menu).player;
    if(!isdefined(player))
        return;
    
    split  = strtok(menu, ";");
    menuId = split[0];
    client = split[1];
    
    switch(menuId)
    {
        case "client":
            AddOption(menu, "Godmode", serious::SimpleToggle, "Godmode", sys::EnableInvulnerability, sys::DisableInvulnerability, player);
            AddOption(menu, "Infinite Ammo", serious::SimpleToggle, "Infinite Ammo", serious::InfiniteAmmo, undefined, player);
            AddSubmenu(menu, mToClient("troll", client), "Troll Menu", player);
            AddSubmenu(menu, mToClient("access", client), "Menu Access", player);
            #ifdef ZM AddOption(menu, "Down Player", serious::DownPlayer, player); #endif
            #ifdef ZM AddOption(menu, "Revive Player", serious::ZM_RevivePlayer, player); #endif
            AddOption(menu, "Kill Player", serious::KillPlayer, player);
            AddOption(menu, "Spawn Player", serious::RespawnPlayer, player);
            AddOption(menu, "Kick Player", serious::KickWrapper, player GetEntityNumber());
            #ifdef ZM
            AddOption(menu, "Spawn a Zombie", serious::SpawnZombieArray, player, 1);
            AddOption(menu, "Spawn 20 Zombies", serious::SpawnZombieArray, player, 20);
            #endif
            break;
        case "troll":
            AddOption(menu, "Kill Loop", serious::SimpleToggle, "Kill Loop", serious::KillLoop, undefined, player);
            AddOption(menu, "Trip Balls", serious::SimpleToggle, "Trip Balls", serious::TripBalls, undefined, player);
            AddOption(menu, "Freeze Controls", serious::SimpleToggle, "Freeze Controls", serious::SFreezeControls, undefined, player);
            AddOption(menu, "Puppet Mode", serious::SimpleToggle, "Puppet Mode", serious::Puppet, undefined, player, self);
            AddOption(menu, "Lag Switch", serious::SimpleToggle, "Lag Switch", serious::LagSwitch, undefined, player);
            break;
        case "access":
        for(i = 0; i < level.status_strings.size && i < self.access; i++)
                AddOption(menu, "Status: " + level.status_strings[i], serious::SetAccess, i, player);
            break;
    }
}