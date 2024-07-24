#define PERK_PAUSE_PLR_EMP = 1;
#define PERK_PAUSE_MACHINE_EMP = 2;
perk_pause_machine(perk)
{
	for(j = 0; j < getplayers().size; j++)
	{
		player = getplayers()[j];
        player pause_perk_single(player, perk, PERK_PAUSE_MACHINE_EMP);
	}
}

pause_perk_single(player, perk, source)
{
    if(!isdefined(player.disabled_perks))
    {
        player.disabled_perks = [];
    }

    if(!isdefined(player.disabled_perks[perk]))
    {
        player.disabled_perks[perk] = 0;
    }

    if(isdefined(player.disabled_perks[perk]) && player.disabled_perks[perk] || player hasperk(perk))
    {
        player.disabled_perks[perk] |= source;
    }
    
    if(player.disabled_perks[perk])
    {
        player unsetperk(perk);
        player zm_perks::set_perk_clientfield(perk, 0);
        if(isdefined(level._custom_perks[perk]) && isdefined(level._custom_perks[perk].player_thread_take))
        {
            player thread [[level._custom_perks[perk].player_thread_take]](1);
        }
        player bgb_permaperks_status_update();
    }
}

resume_perk_single(player, perk, source)
{
    if(isdefined(player.disabled_perks) && (isdefined(player.disabled_perks[perk]) && player.disabled_perks[perk]))
    {
        player.disabled_perks[perk] &= ~source;

        if(player.disabled_perks[perk])
        {
            return;
        }

        player zm_perks::set_perk_clientfield(perk, 1);
        player setperk(perk);
        if(isdefined(level._custom_perks[perk]) && isdefined(level._custom_perks[perk].player_thread_give))
        {
            player thread [[level._custom_perks[perk].player_thread_give]]();
        }
        player bgb_permaperks_status_update();
    }
}

perk_unpause_machine(perk)
{
	if(!isdefined(perk))
	{
		return;
	}
	for(j = 0; j < getplayers().size; j++)
	{
		player = getplayers()[j];
		player resume_perk_single(player, perk, PERK_PAUSE_MACHINE_EMP);
	}
}

get_perk_array()
{
	perk_array = [];
	if(level._custom_perks.size > 0)
	{
		a_keys = getarraykeys(level._custom_perks);
		for(i = 0; i < a_keys.size; i++)
		{
			if(self hasperk(a_keys[i]) || self zm_perks::has_perk_paused(a_keys[i]))
			{
				perk_array[perk_array.size] = a_keys[i];
			}
		}
	}
	return perk_array;
}

pause_all_perks()
{
    foreach(perk in self get_perk_array())
    {
        self pause_perk_single(self, perk, PERK_PAUSE_PLR_EMP);
    }
}

resume_all_perks()
{
    foreach(perk in self get_perk_array())
    {
        self resume_perk_single(self, perk, PERK_PAUSE_PLR_EMP);
    }
}