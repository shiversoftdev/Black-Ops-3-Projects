detour controllable_spider<scripts\zm\_zm_weap_controllable_spider.gsc>::function_4e8bb77d()
{
    self endon("death");
    self thread find_owner_and_watch_damage();
	wait(60);
	self dodamage(self.health + 1000, self.origin);
}

detour controllable_spider<scripts\zm\_zm_weap_controllable_spider.gsc>::function_a21f0b74()
{
    self.var_59bd3c5a endon("death");
	self endon("disconnect");
	for(;;)
	{
		if(self util::use_button_held())
		{
            if(isdefined(self.var_59bd3c5a))
            {
                self.var_59bd3c5a.takedamage = 1;
                self.var_59bd3c5a.owner = undefined;
                self.var_59bd3c5a dodamage(self.var_59bd3c5a.health + 1000, self.var_59bd3c5a.origin);
                self.var_59bd3c5a kill();
                return;
            }
		}
		wait(0.05);
	}
}

find_owner_and_watch_damage()
{
    wait 1;
    owner = undefined;
    foreach(player in getplayers())
    {
        if(isdefined(player.var_59bd3c5a) && player.var_59bd3c5a == self)
        {
            owner = player;
            break;
        }
    }
    if(!isdefined(owner))
    {
        return;
    }
    self setCanDamage(true);
    self setteam(owner.team);
}

weapon_controllable_spider()
{
    if(!isdefined(level.w_controllable_spider))
    {
        return;
    }
    self endon("bled_out");
    self endon("disconnect");
    for(;;)
    {
        self waittill("player_used_controllable_spider");
        wait 3;
        if(isdefined(self.var_cbe49ee))
        {
            self.var_cbe49ee.maxhealth = 100000;
            self.var_cbe49ee.health = 100000;
            self.var_cbe49ee setCanDamage(1);
            self.var_cbe49ee solid();
            self.var_cbe49ee thread weapon_controllable_spider_damage(self);
        }
    }
}

weapon_controllable_spider_damage(player)
{
    self endon("death");
    player endon("disconnect");
    self.owner = player;
    self.health_max = int(CLAMPED_ROUND_NUMBER * 1000);
    self.health_remaining = int(CLAMPED_ROUND_NUMBER * 1000);
    for(;;)
    {
        self waittill("damage", damage, attacker, direction_vec, point, mod);
        if(!isplayer(attacker))
        {
            continue;
        }
        self.health_remaining -= (int(damage) ?? 100);
        damageStage = int((self.health_max - self.health_remaining) / 2);
        attacker PlayHitMarker("mpl_hit_alert", damageStage, undefined, self.health_remaining <= 0);
        attacker thread _damage_feedback_growth(self, undefined, undefined, 0, damageStage);
        damage3d(attacker, point, damage, DAMAGE_TYPE_ZOMBIES);
        if(self.health_remaining <= 0)
        {
            if(isdefined(self.owner.var_59bd3c5a) && isalive(self.owner.var_59bd3c5a))
            {
                self.owner.var_59bd3c5a kill();
            }
            return;
        }
    }
}