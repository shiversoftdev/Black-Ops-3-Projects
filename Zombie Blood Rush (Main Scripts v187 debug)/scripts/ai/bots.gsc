setup_bots()
{
    // level.onbotdamage = serious::on_bot_damage;
    // level.botcombat = serious::bot_combat_think;
    // level.getbotsettings = serious::get_bot_settings;
    // level.botgetthreats = serious::bot_get_threats;
    // level.botignorethreat = serious::bot_ignore_threat;
}

on_bot_damage()
{

}

get_bot_settings()
{
    setdvar("bot_maxMantleHeight", 20);
    settings = struct::get_script_bundle("botsettings", "bot_default");
    settings.allowmelee = true;
    settings.allowgrenades = true;
    settings.allowkillstreaks = false;
    settings.allowherogadgets = false;
    settings.fov = 120;
    settings.fovads = 75;
    settings.fovads = 75;
    settings.thinkinterval = 10;
    return settings;
}

bot_combat_think()
{
    if(isdefined(self.bot.threat.entity))
	{
		if(self bot_threat_is_alive())
		{
			self bot_combat::update_threat(false);
		}
		else
		{
			self.bot.threat.entity = undefined;
            self bot_combat::clear_threat_aim();
            self botlookforward();
		}
	}
	if(!isdefined(self.bot.threat.entity) && !self bot_combat::get_new_threat())
	{
		return;
	}
	if(isdefined(self.bot.threat.entity))
	{
		if(!(self bot_combat::threat_visible()) || (self.bot.threat.lastdistancesq > level.botsettings.threatradiusmaxsq))
		{
			self bot_combat::get_new_threat(level.botsettings.threatradiusmin);
		}
	}
	if(self bot_combat::threat_visible())
	{
		self thread [[level.botupdatethreatgoal]]();
		self thread [[level.botthreatengage]]();
	}
	else
	{
		self thread [[level.botthreatlost]]();
	}
}

bot_threat_is_alive(ent = self.bot.threat.entity)
{
    if(!isdefined(ent))
    {
        return false;
    }
    
    if(isplayer(ent))
    {
        return ent.sessionstate == "playing";
    }

    return isalive(ent);
}

bot_get_threats(maxdistance = 1000)
{
    a_e_threats = [];

    foreach(ent in getaiteamarray(level.zombie_team))
    {
        if(!isalive(ent))
        {
            continue;
        }
        a_e_threats[a_e_threats.size] = ent;
    }

    foreach(player in getplayers())
    {
        if(player.team == self.team)
        {
            continue;
        }
        if(player.sessionstate != "playing")
        {
            continue;
        }
        if(player == self)
        {
            continue;
        }
        a_e_threats[a_e_threats.size] = player;
    }

    return array::get_all_closest(self.origin, a_e_threats, undefined, undefined, maxdistance);
}

bot_ignore_threat(entity)
{
    return !bot_threat_is_alive(entity);
}