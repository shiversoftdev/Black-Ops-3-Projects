#define SE_NONE = -1;
#define SE_CRAWL = 0;
#define SE_FIH = 1;
#define SE_KT = 2;
#define SE_SD_PREP = 3;
#define SE_SD_CHEATING_AREA = 4;
#define SE_SD_CHEATING_MOVEMENT = 5;
#define SE_RESTRICTED_AREA = 6;
#define SE_RESTRICTED_ACTION = 7;
#define SE_EXCLUSION_ZONE = 8;
#define SE_TURNED = 9;

init_status_effects()
{
    level.zbr_status_priority ??= 0;
    level.zbr_status_effect_priorities ??= [];
    register_status_effect(SE_EXCLUSION_ZONE, "Nuclear Fallout");
    register_status_effect(SE_TURNED, "Turned");
    register_status_effect(SE_RESTRICTED_AREA, "RESTRICTED AREA. OBJECTIVE PAUSED.");
    register_status_effect(SE_RESTRICTED_ACTION, "OBJECTIVE PROGRESS PAUSED.");
    register_status_effect(SE_CRAWL, "Crawl Space");
    register_status_effect(SE_FIH, "Fear in Headlights");
    register_status_effect(SE_KT, "Killing Time");

    register_status_effect(SE_SD_PREP, "Prepare for sudden death...");
    register_status_effect(SE_SD_CHEATING_AREA, "Return to playable area...");
    register_status_effect(SE_SD_CHEATING_MOVEMENT, "Start moving or die...");

    callback::on_connect(serious::tick_status_effects);
    foreach(player in getplayers())
    {
        player thread tick_status_effects();
    }
}

register_status_effect(id, text)
{
    struct = spawnstruct();
    struct.text = text;
    struct.id = id;
    struct.priority = level.zbr_status_priority;
    level.zbr_status_priority++;
    level.zbr_status_effect_priorities[id] = struct;
}

has_active_status_effect(id)
{
    if(!isdefined(self.zbr_status_effects))
    {
        return false;
    }
    
    effect = self.zbr_status_effects[id];
    if(effect.endtime is defined and effect.endtime == -1)
    {
        return true;
    }
    
    if(effect.time is defined and effect.time > 0)
    {
        return true;
    }

    return false;
}

activate_effect(id, time)
{
    self.zbr_status_effects ??= [];

    if(isdefined(self.zbr_status_effects[id]))
    {
        clear_effect(id);
    }

    struct = spawnstruct();
    struct.id = id;
    struct.time = time;

    if(time == -1)
    {
        struct.endtime = -1;
    }
    else
    {
        struct.endtime = gettime() + int(time * 1000);
    }

    struct.data = level.zbr_status_effect_priorities[id];
    self.zbr_status_effects[id] = struct;
    update_status_effects();
}

clear_effect(id)
{
    self.zbr_status_effects ??= [];

    if(isdefined(self.zbr_status_effects[id]))
    {
        self.zbr_status_effects[id].time = 0;
        self.zbr_status_effects[id].endtime = 0;
    }
}

clear_all_effects()
{
    self.zbr_status_effects ??= [];
    foreach(effect in self.zbr_status_effects)
    {
        clear_effect(effect.id);
    }
}

update_status_effects()
{
    switch(self.se_render_status)
    {
        case SE_RS_HIDDEN:
            if(self.sessionstate == "playing" && has_any_active_status_effect())
            {
                self render_active_status_effect(true);
                self.se_render_status = SE_RS_RENDERING;
                break;
            }
        break;
        case SE_RS_RENDERING:
            if(self.sessionstate != "playing")
            {
                clear_active_status_effect_hud();
                break;
            }
            self render_active_status_effect(false);
        break;
    }
}

clear_active_status_effect_hud()
{
    self util::clearlowermessage(0.1);
    self.lowermessage.color = (1, 1, 1);
    self.last_effect_id = SE_NONE;
    self.se_render_status = SE_RS_HIDDEN;
}

render_active_status_effect(b_force)
{
    self.zbr_status_effects ??= [];
    self.last_effect_id ??= SE_NONE;

    if(b_force)
    {
        self.last_effect_id = SE_NONE;
    }
    
    previous_effect = (self.last_effect_id == SE_NONE) ? undefined : self.zbr_status_effects[self.last_effect_id];
    best_effect = previous_effect;

    if(best_effect is defined && (best_effect.endtime <= gettime()) && (best_effect.endtime != -1))
    {
        best_effect = undefined;
    }

    foreach(effect in self.zbr_status_effects)
    {
        if((effect.endtime != -1) && effect.endtime <= gettime())
        {
            continue;
        }
        if(best_effect is undefined or effect.data.priority > best_effect.data.priority)
        {
            best_effect = effect;
        }
    }

    if(best_effect is undefined)
    {
        clear_active_status_effect_hud();
        return;
    }

    if(previous_effect is defined && (best_effect.id == previous_effect.id))
    {
        return;
    }

    self.lowermessage.glowcolor = (1, 0, 0);
    self.lowermessage.color = (1, 0, 0);
    self.lowermessage.glowalpha = 1;
    self _setlowermessage(best_effect.data.text, (effect.endtime == -1) ? -1 : int(max(0, best_effect.time)), false);
}

_setlowermessage(text, time, combinemessageandtimer)
{
	if(!isdefined(self.lowermessage))
	{
		return;
	}
	if(isdefined(self.lowermessageoverride) && text != (&""))
	{
		text = self.lowermessageoverride;
		time = undefined;
	}
	self notify(#lower_message_set);
	self.lowermessage settext(text);
	if(isdefined(time) && time >= 0)
	{
		if(!isdefined(combinemessageandtimer) || !combinemessageandtimer)
		{
			self.lowertimer.label = &"";
		}
		else
		{
			self.lowermessage settext("");
			self.lowertimer.label = text;
		}
		self.lowertimer settimer(time);
	}
	else
	{
		self.lowertimer settext("");
		self.lowertimer.label = &"";
	}
	if(self issplitscreen())
	{
		self.lowermessage.fontscale = 1.4;
	}
	self.lowermessage fadeovertime(0.05);
	self.lowermessage.alpha = 1;
	self.lowertimer fadeovertime(0.05);
	self.lowertimer.alpha = 1;
}

has_any_active_status_effect()
{
    self.zbr_status_effects ??= [];
    foreach(effect in self.zbr_status_effects)
    {
        if(effect.endtime > gettime() || (effect.endtime == -1))
        {
            return true;
        }
    }
    return false;
}

#define SE_RS_HIDDEN = 0;
#define SE_RS_RENDERING = 1;
tick_status_effects()
{
    self notify(#tick_status_effects);
    self endon(#tick_status_effects);
    self endon(#disconnect);

    self.zbr_status_effects ??= [];
    self.se_render_status = SE_RS_HIDDEN;
    for(;;)
    {
        wait 0.05;

        // tick active effects
        foreach(effect in self.zbr_status_effects)
        {
            if(effect.time > 0)
            {
                effect.time -= 0.05;
            }
        }

        update_status_effects();
    }
}