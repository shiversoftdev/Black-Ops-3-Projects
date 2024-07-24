#define ZBR_MAX_MUSIC_INDEX = 6;
GM_KillMusic(b_dont_notify = false)
{
    if(!level.zbr_mus_state)
    {
        return;
    }

    level clientfield::set("zbr_mus_state", 0);
    level.zbr_mus_state = 0;

    level.musicSystem.currentPlaytype = 0;
	level.musicSystem.currentState = undefined;
    level.musicsystemoverride = false;

    if(b_dont_notify)
    {
        return;
    }

    level notify("zbr_end_mus");
}

GM_StartMusic()
{
    if(level.zbr_mus_state)
    {
        return;
    }

    level endon("zbr_end_mus");
    GM_KillMusic(true);

    weighted_mus_indexes = [0, 1, 2, 3, 3, 3, 4, 4, 4, 5];

    level.zbr_mus_state = 1 + weighted_mus_indexes[randomint(weighted_mus_indexes.size)];
    for(;;)
    {
        level zm_audio::sndMusicSystem_StopAndFlush();    
        str_alias = level.zbr_mus_array[level.zbr_mus_state - 1];
        level.musicsystemoverride = true;
        level.musicSystem.currentPlaytype = 4;
        level.musicSystem.currentState = str_alias;
        level clientfield::set("zbr_mus_state", level.zbr_mus_state);
        music::setmusicstate(str_alias);
        
        playbackTime = soundgetplaybacktime(str_alias);
        if(!isdefined(playbackTime) || playbackTime <= 0)
        {
            n_time = 1;
        }
        else
        {
            n_time = playbackTime * 0.001;
        }

        wait n_time + 3;

        level.zbr_mus_state++;
        if(level.zbr_mus_state > ZBR_MAX_MUSIC_INDEX)
        {
            level.zbr_mus_state = 1;
        }
    }
}

zbr_run_fs_music()
{
    level zm_audio::sndMusicSystem_StopAndFlush();    
    level.musicsystemoverride = true;
    level.musicSystem.currentPlaytype = 4;
    level clientfield::set("zbr_mus_state_finalstand", 1);
    level waittill(#end_game);
    wait 2;
    level clientfield::set("zbr_mus_state_finalstand", 0);
}

zbr_snd_init()
{
    clientfield::register("world", "zbr_mus_state", 1, 4, "int");
    clientfield::register("world", "zbr_mus_state_finalstand", 1, 1, "int");
    
    level.zbr_mus_state = 0;
    level.zbr_mus_array = ["mus_115_riddle_oneshot_intro", "mus_abra_macabre_intro", "mus_infection_church_intro", "zbr_mus_reflections", "zbr_mus_zod", "zbr_mus_avagadro"];
    level.zbr_hit_sounds = ["zbr_hit_alert_body_nf_00", "zbr_hit_alert_body_nf_01", "zbr_hit_alert_body_nf_02"];
    level.zbr_head_hit_sounds = ["zbr_hit_alert_head_nf_00", "zbr_hit_alert_head_nf_01", "zbr_hit_alert_head_nf_02"];

    thread [[ function() => 
    {
        level waittill("end_game");
        GM_KillMusic();
    }]]();
}

zbr_get_hitsound(shitloc)
{
    if(!isdefined(shitloc) || shitloc != "head")
    {
        return array::random(level.zbr_hit_sounds);
    }
    return array::random(level.zbr_head_hit_sounds);
}