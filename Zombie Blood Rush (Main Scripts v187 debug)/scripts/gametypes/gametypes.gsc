init_gametypes() // called synchronously by autoexec. DO NOT ADD WAITS.
{
    level.zbr_gametype = tolower(getdvarstring("zbr_gametype"));

    if(tolower(getdvarstring("mapname")) == "cp_doa_bo3")
    {
        level.zbr_is_doa = true;
    }

    if(strstartswith(tolower(getdvarstring("mapname")), "mp_"))
    {
        level.zbr_is_mp = true;
    }

    if(level.zbr_is_doa is true)
    {
        zbr_doa_auto();
    }

    switch(level.zbr_gametype)
    {
        case "zhunt":
            zhunt_init_gametype();
        break;
    }
}

detour sys::sessionmodeismultiplayergame()
{
    if(level.zbr_is_mp is true)
    {
        return true;
    }
    return sessionmodeismultiplayergame();
}