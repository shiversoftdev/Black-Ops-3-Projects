add_mine_planted_callback(fn_planted_cb, wpn_name)
{
	if(!isdefined(level.placeable_mine_planted_callbacks[wpn_name]))
	{
		level.placeable_mine_planted_callbacks[wpn_name] = [];
	}
	else if(!isarray(level.placeable_mine_planted_callbacks[wpn_name]))
	{
		level.placeable_mine_planted_callbacks[wpn_name] = array(level.placeable_mine_planted_callbacks[wpn_name]);
	}
	level.placeable_mine_planted_callbacks[wpn_name][level.placeable_mine_planted_callbacks[wpn_name].size] = fn_planted_cb;
}

mine_watch_pvp_damage(e_planter)
{
    self endon(#death);
    e_planter endon("disconnect");
    self zm_utility::waittill_not_moving();
    e_trig = spawn("script_model", self.origin);
    e_trig setmodel("defaultactor_0_5");
    e_trig.maxhealth = 100000;
    e_trig.health = 100000;
    e_trig setcandamage(true);
    e_trig solid();
    e_trig ghost();
    self thread mine_watch_death_cleanup_trigger(e_trig, e_planter);

    e_trig endon("death");
    while(isdefined(e_trig))
    {
        e_trig waittill("damage", damagetaken, attacker, dir, point, dmg_type, model, tag, part, weapon, flags);
        if(isplayer(attacker) && isdefined(attacker.sessionstate) && attacker.sessionstate == "playing")
        {
            attacker PlayHitMarker("mpl_hit_alert", 1, undefined, false);
            attacker thread damagefeedback::damage_feedback_growth(self, dmg_type, weapon);
            damage3d(attacker, point, damagetaken, DAMAGE_TYPE_ZOMBIES);
        }
        if(weapon is defined and (weapon == level.zbr_emp_grenade_zm))
        {
            self delete();
            return;
        }
        self detonate(self.owner);
        break;
    }
}

mine_watch_death_cleanup_trigger(e_trig, e_planter)
{
    e_planter endon("disconnect");
    e_trig endon("death");
    self waittill("death");
    e_trig delete();
}

add_planted_callback(fn_planted_cb, wpn_name)
{
	if(!isdefined(level.placeable_mine_planted_callbacks[wpn_name]))
	{
		level.placeable_mine_planted_callbacks[wpn_name] = [];
	}
	else if(!isarray(level.placeable_mine_planted_callbacks[wpn_name]))
	{
		level.placeable_mine_planted_callbacks[wpn_name] = array(level.placeable_mine_planted_callbacks[wpn_name]);
	}
	level.placeable_mine_planted_callbacks[wpn_name][level.placeable_mine_planted_callbacks[wpn_name].size] = fn_planted_cb;
}