wait_for_crossbow_dw_fired()
{
    if(getweapon("special_crossbow_upgraded") is undefined || (getweapon("special_crossbow_upgraded") == level.weaponnone))
    {
        return;
    }
    self endon(#disconnect);
    self endon(#player_spawned);
    self endon(#bled_out);
    for(;;)
    {
        self waittill("projectile_impact", weapon, v_position, radius, e_projectile, normal);
        
        if(weapon is undefined)
        {
            continue;
        }

        if(weapon == getweapon("special_crossbow_upgraded") or weapon == getweapon("special_crossbow"))
        {
            radiusdamage(v_position, 200, int(CLAMPED_ROUND_NUMBER * 150), int(CLAMPED_ROUND_NUMBER * 150 * 0.75), self, "MOD_EXPLOSIVE", level.weaponnone);
        }
    }
}