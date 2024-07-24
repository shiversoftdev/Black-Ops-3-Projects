#define WU_TUNE_BMP = 0;
#define WU_TUNE_HMP = 1;
#define WU_TUNE_CLASS = 2;
#define WU_TUNE_ROLE = 3;

wudev_tune(setting)
{
    if(level.wudev?.current is undefined)
    {
        self iPrintLnBold("Please select a weapon first.");
        return;
    }

    response = self [[ level.zbr_get_keyboard_response ]]("Enter Tuning Value", "0", 128);

    switch(setting)
    {
        case WU_TUNE_CLASS:
        case WU_TUNE_ROLE:
            compiler::wudev_tuner(setting, int(response));
        break;
        default:
            compiler::wudev_tuner(setting, float(response));
    }
}

wudev_adjust(weapon)
{
    wudev_load();
    compiler::wudev_select(weapon);
    self serious::award_weapon(weapon);
    level.wudev.current = weapon;
}

wudev_load()
{
    if(level.wudev is defined)
    {
        return;
    }
    level.wudev = spawnstruct();
    if(isinarray(level.zm_core_maps, level.script))
    {
        compiler::wudev_require("zcore", true);
    }
    else
    {
        compiler::wudev_require(level.script, true);
    }
}

wudev_save()
{
    if(isinarray(level.zm_core_maps, level.script))
    {
        compiler::wudev_commit("zcore");
    }
    else
    {
        compiler::wudev_commit(level.script);
    }
    self iPrintLnBold("Saved data!");
}

wudev_infinite_ammo()
{
    self endon(#disconnect);
    level endon(#end_game);
    level endon(#game_ended);
    self endon(#wudev_infinite_ammo_end);
    level endon(#zbr_devgui);
    
    for(;;)
    {
        weapon  = self GetCurrentWeapon();
        offhand = self GetCurrentOffhand();
        
        if(weapon != level.weaponNone)
        {
            self SetWeaponAmmoClip(weapon, 1337);
            self givemaxammo(weapon);
        }

        if(weapon.isdualwield)
        {
            self SetWeaponAmmoClip(weapon.dualwieldweapon, 1337);
            self givemaxammo(weapon.dualwieldweapon);
        }
        
        if(offhand != level.weaponNone)
            self givemaxammo(offhand);
        
        self util::waittill_any("weapon_fired", "grenade_fire", "missile_fire", "weapon_change");
    }
}

wudev_collect()
{
    level endon(#zbr_devgui);

    if(level.wudev?.current is undefined)
    {
        self iPrintLnBold("Please select a weapon first.");
        return;
    }

    wudev_load();
    compiler::wudev_select(level.wudev.current);

    is_left = false;
    if(level.wudev.current.isdualwield)
    {
        response = self [[ level.zbr_get_keyboard_response ]]("Tune left hand", "false", 128);

        if(tolower(response) == "true")
        {
            compiler::wudev_select(level.wudev.current.dualwieldweapon);
            is_left = true;
        }
    }
    
    foreach(player in getplayers())
    {
        if(player != self)
        {
            player freezeControls(true);
            player disableWeapons();
        }
    }

    setdvar("g_ai", 0);

    self switchToWeapon(level.wudev.current);

    while(self IsSwitchingWeapons()) wait 0.05;
    
    self DisableWeaponCycling();

    if(level.wudev.current.isdualwield)
    {
        self SetWeaponAmmoClip(level.wudev.current.dualwieldweapon, 1337);
        self givemaxammo(level.wudev.current.dualwieldweapon);
    }

    self SetWeaponAmmoClip(level.wudev.current, 1337);
    self givemaxammo(level.wudev.current);

    self unsetperk("specialty_doubletap2");
    
    compiler::wudev_simulate_begin(is_left);
    self thread wudev_infinite_ammo();
    wait 4;
    self notify(#wudev_infinite_ammo_end);
    compiler::wudev_simulate_mark(0);
    wait 8;
    compiler::wudev_simulate_mark(1);

    while(self IsReloading()) wait 0.05;
    
    if(level.wudev.current.isdualwield)
    {
        self SetWeaponAmmoClip(level.wudev.current.dualwieldweapon, 1337);
        self givemaxammo(level.wudev.current.dualwieldweapon);
    }

    self SetWeaponAmmoClip(level.wudev.current, 1337);
    self givemaxammo(level.wudev.current);

    self setperk("specialty_doubletap2");
    compiler::wudev_simulate_mark(2);
    self thread wudev_infinite_ammo();
    wait 4;
    self notify(#wudev_infinite_ammo_end);
    compiler::wudev_simulate_mark(3);
    wait 8;
    compiler::wudev_simulate_mark(4);

    compiler::wudev_simulate_end();

    setdvar("g_ai", 1);
    // foreach(player in getplayers())
    // {
    //     if(player != self)
    //     {
    //         player freezeControls(false);
    //         player enableWeapons();
    //     }
    // }
    self EnableWeaponCycling();
}

wudev_regen(type)
{
    res = compiler::wudev_csv_to_tbl(type);
    if(res)
    {
        self iPrintLnBold("Sucessfully regenerated table");
    }
    else
    {
        self iPrintLnBold("Failed to regenerated table");
    }
}

// function autoexec treyarch_did_this_to_themselves()
// {
//     thread pmod_threaded(); // because autoexecs are dumb in engine
// }

// function pmod_threaded()
// {
//     level endon("end_game");

//     array::thread_all(getplayers(), ::pmod_initializer);
//     callback::on_connect(::pmod_initializer);

//     wait 0.05;
//     for(;;)
//     {
//         foreach(s_challenge in struct::get_array("s_challenge_trigger"))
//         {
//             if(!isdefined(s_challenge.var_30ff0d6c) || s_challenge.var_30ff0d6c.n_challenge !== 3)
//             {
//                 continue;
//             }

//             s_challenge.var_30ff0d6c.n_challenge = 4;
//         }
//         wait 0.05;
//     }
// }

// function pmod_initializer()
// {
//     self endon("disconnect");

//     self flag::init("flag_player_collected_reward_" + 4);
//     // self flag::set("flag_player_completed_challenge_3"); // uncomment this line if you want to test

//     self flag::wait_till("flag_player_collected_reward_" + 4);
//     self flag::set("flag_player_collected_reward_" + 3);
//     self clientfield::set_to_player(("challenge" + 3) + "state", 2);

//     // mess with the logic here!
// 	self zm_perks::give_perk("specialty_widowswine", 0);
// }