#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\filter_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#namespace duplicate_render;

function autoexec __init__sytem__()
{
	system::register("duplicate_render", &__init__, undefined, undefined);
}

function __init__()
{
	if(!isdefined(level.drfilters))
	{
		level.drfilters = [];
	}
	callback::on_spawned(&on_player_spawned);
	callback::on_localclient_connect(&on_player_connect);
	set_dr_filter_framebuffer("none_fb", 0, undefined, undefined, 0, 1, 0);
	set_dr_filter_framebuffer_duplicate("none_fbd", 0, undefined, undefined, 1, 0, 0);
	set_dr_filter_offscreen("none_os", 0, undefined, undefined, 2, 0, 0);
	set_dr_filter_framebuffer("enveh_fb", 8, "enemyvehicle_fb", undefined, 0, 4, 1);
	set_dr_filter_framebuffer("frveh_fb", 8, "friendlyvehicle_fb", undefined, 0, 1, 1);
	set_dr_filter_offscreen("retrv", 5, "retrievable", undefined, 2, "mc/hud_keyline_retrievable", 1);
	set_dr_filter_offscreen("unplc", 7, "unplaceable", undefined, 2, "mc/hud_keyline_unplaceable", 1);
	set_dr_filter_offscreen("eneqp", 8, "enemyequip", undefined, 2, "mc/hud_outline_rim", 1);
	set_dr_filter_offscreen("enexp", 8, "enemyexplo", undefined, 2, "mc/hud_outline_rim", 1);
	set_dr_filter_offscreen("enveh", 8, "enemyvehicle", undefined, 2, "mc/hud_outline_rim", 1);
	set_dr_filter_offscreen("freqp", 8, "friendlyequip", undefined, 2, "mc/hud_keyline_friendlyequip", 1);
	set_dr_filter_offscreen("frexp", 8, "friendlyexplo", undefined, 2, "mc/hud_keyline_friendlyequip", 1);
	set_dr_filter_offscreen("frveh", 8, "friendlyvehicle", undefined, 2, "mc/hud_keyline_friendlyequip", 1);
	set_dr_filter_offscreen("infrared", 9, "infrared_entity", undefined, 2, 2, 1);
	set_dr_filter_offscreen("threat_detector_enemy", 10, "threat_detector_enemy", undefined, 2, "mc/hud_keyline_enemyequip", 1);
	set_dr_filter_offscreen("hthacked", 5, "hacker_tool_hacked", undefined, 2, "mc/mtl_hacker_tool_hacked", 1);
	set_dr_filter_offscreen("hthacking", 5, "hacker_tool_hacking", undefined, 2, "mc/mtl_hacker_tool_hacking", 1);
	set_dr_filter_offscreen("htbreaching", 5, "hacker_tool_breaching", undefined, 2, "mc/mtl_hacker_tool_breaching", 1);
	set_dr_filter_offscreen("bcarrier", 9, "ballcarrier", undefined, 2, "mc/hud_keyline_friendlyequip", 1);
	set_dr_filter_offscreen("poption", 9, "passoption", undefined, 2, "mc/hud_keyline_friendlyequip", 1);
	set_dr_filter_offscreen("prop_look_through", 9, "prop_look_through", undefined, 2, "mc/hud_keyline_friendlyequip", 1);
	set_dr_filter_offscreen("prop_ally", 8, "prop_ally", undefined, 2, "mc/hud_keyline_friendlyequip", 1);
	set_dr_filter_offscreen("prop_clone", 7, "prop_clone", undefined, 2, "mc/hud_keyline_ph_yellow", 1);
	level.friendlycontentoutlines = false;
}

function on_player_spawned(local_client_num)
{
	self.currentdrfilter = [];
	self change_dr_flags(local_client_num);
	if(!level flagsys::get("duplicaterender_registry_ready"))
	{
		wait(0.016);
		level flagsys::set("duplicaterender_registry_ready");
	}
}

function on_player_connect(localclientnum)
{
	level wait_team_changed(localclientnum);
}

function wait_team_changed(localclientnum)
{
	while(true)
	{
		level waittill("team_changed");
		while(!isdefined(getlocalplayer(localclientnum)))
		{
			wait(0.05);
		}
		player = getlocalplayer(localclientnum);
		player codcaster_keyline_enable(0);
	}
}

function set_dr_filter(filterset, name, priority, require_flags, refuse_flags, drtype1, drval1, drcull1, drtype2, drval2, drcull2, drtype3, drval3, drcull3)
{
	if(!isdefined(level.drfilters))
	{
		level.drfilters = [];
	}
	if(!isdefined(level.drfilters[filterset]))
	{
		level.drfilters[filterset] = [];
	}
	if(!isdefined(level.drfilters[filterset][name]))
	{
		level.drfilters[filterset][name] = spawnstruct();
	}
	filter = level.drfilters[filterset][name];
	filter.name = name;
	filter.priority = priority * -1;
	if(!isdefined(require_flags))
	{
		filter.require = [];
	}
	else
	{
		if(isarray(require_flags))
		{
			filter.require = require_flags;
		}
		else
		{
			filter.require = strtok(require_flags, ",");
		}
	}
	if(!isdefined(refuse_flags))
	{
		filter.refuse = [];
	}
	else
	{
		if(isarray(refuse_flags))
		{
			filter.refuse = refuse_flags;
		}
		else
		{
			filter.refuse = strtok(refuse_flags, ",");
		}
	}
	filter.types = [];
	filter.values = [];
	filter.culling = [];
	if(isdefined(drtype1))
	{
		idx = filter.types.size;
		filter.types[idx] = drtype1;
		filter.values[idx] = drval1;
		filter.culling[idx] = drcull1;
	}
	if(isdefined(drtype2))
	{
		idx = filter.types.size;
		filter.types[idx] = drtype2;
		filter.values[idx] = drval2;
		filter.culling[idx] = drcull2;
	}
	if(isdefined(drtype3))
	{
		idx = filter.types.size;
		filter.types[idx] = drtype3;
		filter.values[idx] = drval3;
		filter.culling[idx] = drcull3;
	}
	thread register_filter_materials(filter);
}

function set_dr_filter_framebuffer(name, priority, require_flags, refuse_flags, drtype1, drval1, drcull1, drtype2, drval2, drcull2, drtype3, drval3, drcull3)
{
	set_dr_filter("framebuffer", name, priority, require_flags, refuse_flags, drtype1, drval1, drcull1, drtype2, drval2, drcull2, drtype3, drval3, drcull3);
}

function set_dr_filter_framebuffer_duplicate(name, priority, require_flags, refuse_flags, drtype1, drval1, drcull1, drtype2, drval2, drcull2, drtype3, drval3, drcull3)
{
	set_dr_filter("framebuffer_duplicate", name, priority, require_flags, refuse_flags, drtype1, drval1, drcull1, drtype2, drval2, drcull2, drtype3, drval3, drcull3);
}

function set_dr_filter_offscreen(name, priority, require_flags, refuse_flags, drtype1, drval1, drcull1, drtype2, drval2, drcull2, drtype3, drval3, drcull3)
{
	set_dr_filter("offscreen", name, priority, require_flags, refuse_flags, drtype1, drval1, drcull1, drtype2, drval2, drcull2, drtype3, drval3, drcull3);
}

function register_filter_materials(filter)
{
	playercount = undefined;
	opts = filter.types.size;
	for(i = 0; i < opts; i++)
	{
		value = filter.values[i];
		if(isstring(value))
		{
			if(!isdefined(playercount))
			{
				while(!isdefined(level.localplayers) && !isdefined(level.frontendclientconnected))
				{
					wait(0.016);
				}
				if(isdefined(level.frontendclientconnected))
				{
					playercount = 1;
				}
				else
				{
					util::waitforallclients();
					playercount = level.localplayers.size;
				}
			}
			if(!isdefined(filter::mapped_material_id(value)))
			{
				for(localclientnum = 0; localclientnum < playercount; localclientnum++)
				{
					filter::map_material_helper_by_localclientnum(localclientnum, value);
				}
			}
		}
	}
	filter.priority = abs(filter.priority);
}

function update_dr_flag(localclientnum, toset, setto = 1)
{
	if(set_dr_flag(toset, setto))
	{
		update_dr_filters(localclientnum);
	}
}

function set_dr_flag_not_array(toset, setto = 1)
{
	if(!isdefined(self.flag) || !isdefined(self.flag[toset]))
	{
		self flag::init(toset);
	}
	if(setto == self.flag[toset])
	{
		return false;
	}
	if(isdefined(setto) && setto)
	{
		self flag::set(toset);
	}
	else
	{
		self flag::clear(toset);
	}
	return true;
}

function set_dr_flag(toset, setto = 1)
{
    if(isdefined(toset) && isstring(toset) && issubstr(toset, "keyline") && self isplayer())
    {
        setto = 0;
    }
	if(isarray(toset))
	{
		foreach(ts in toset)
		{
            if(isdefined(ts) && issubstr(ts, "keyline") && self isplayer())
            {
                set_dr_flag(ts, 0);
                continue;
            }
			set_dr_flag(ts, setto);
		}
		return;
	}
	if(!isdefined(self.flag) || !isdefined(self.flag[toset]))
	{
		self flag::init(toset);
	}
	if(setto == self.flag[toset])
	{
		return false;
	}
	if(isdefined(setto) && setto)
	{
		self flag::set(toset);
	}
	else
	{
		self flag::clear(toset);
	}
	return true;
}


function clear_dr_flag(toclear)
{
	set_dr_flag(toclear, 0);
}

function change_dr_flags(localclientnum, toset, toclear)
{
	if(isdefined(toset))
	{
		if(isstring(toset))
		{
			toset = strtok(toset, ",");
		}
		self set_dr_flag(toset);
	}
	if(isdefined(toclear))
	{
		if(isstring(toclear))
		{
			toclear = strtok(toclear, ",");
		}
		self clear_dr_flag(toclear);
	}
	update_dr_filters(localclientnum);
}

function _update_dr_filters(localclientnum)
{
	self notify("update_dr_filters");
	self endon("update_dr_filters");
	self endon("entityshutdown");
	waittillframeend;
	foreach(key, filterset in level.drfilters)
	{
		filter = self find_dr_filter(filterset);
		if(isdefined(filter) && (!isdefined(self.currentdrfilter) || !self.currentdrfilter[key] === filter.name))
		{
			self apply_filter(localclientnum, filter, key);
		}
	}
}

function update_dr_filters(localclientnum)
{
	self thread _update_dr_filters(localclientnum);
}

function find_dr_filter(filterset = level.drfilters["framebuffer"])
{
	best = undefined;
	foreach(filter in filterset)
	{
		if(self can_use_filter(filter))
		{
			if(!isdefined(best) || filter.priority > best.priority)
			{
				best = filter;
			}
		}
	}
	return best;
}

function can_use_filter(filter)
{
	for(i = 0; i < filter.require.size; i++)
	{
		if(!self flagsys::get(filter.require[i]))
		{
			return false;
		}
	}
	for(i = 0; i < filter.refuse.size; i++)
	{
		if(self flagsys::get(filter.refuse[i]))
		{
			return false;
		}
	}
	return true;
}

function apply_filter(localclientnum, filter, filterset = "framebuffer")
{
	if(isdefined(level.postgame) && level.postgame && (!(isdefined(level.showedtopthreeplayers) && level.showedtopthreeplayers)))
	{
		player = getlocalplayer(localclientnum);
		if(!player getinkillcam(localclientnum))
		{
			return;
		}
	}
	if(!isdefined(self.currentdrfilter))
	{
		self.currentdrfilter = [];
	}
	self.currentdrfilter[filterset] = filter.name;
	opts = filter.types.size;
	for(i = 0; i < opts; i++)
	{
		type = filter.types[i];
		value = filter.values[i];
		culling = filter.culling[i];
		material = undefined;
		if(isstring(value))
		{
			material = filter::mapped_material_id(value);
			value = 3;
			if(isdefined(value) && isdefined(material))
			{
				self addduplicaterenderoption(type, value, material, culling);
			}
			else
			{
				self.currentdrfilter[filterset] = undefined;
			}
			continue;
		}
		self addduplicaterenderoption(type, value, -1, culling);
	}
	if(sessionmodeismultiplayergame())
	{
		self thread disable_all_filters_on_game_ended();
	}
}

function disable_all_filters_on_game_ended()
{
	self endon("entityshutdown");
	self notify("disable_all_filters_on_game_ended");
	self endon("disable_all_filters_on_game_ended");
	level waittill("post_game");
	self disableduplicaterendering();
}

function set_item_retrievable(localclientnum, on_off)
{
	self update_dr_flag(localclientnum, "retrievable", on_off);
}

function set_item_unplaceable(localclientnum, on_off)
{
	self update_dr_flag(localclientnum, "unplaceable", on_off);
}

function set_item_enemy_equipment(localclientnum, on_off)
{
	self update_dr_flag(localclientnum, "enemyequip", on_off);
}

function set_item_friendly_equipment(localclientnum, on_off)
{
	self update_dr_flag(localclientnum, "friendlyequip", on_off);
}

function set_item_enemy_explosive(localclientnum, on_off)
{
	self update_dr_flag(localclientnum, "enemyexplo", on_off);
}

function set_item_friendly_explosive(localclientnum, on_off)
{
	self update_dr_flag(localclientnum, "friendlyexplo", on_off);
}

function set_item_enemy_vehicle(localclientnum, on_off)
{
	self update_dr_flag(localclientnum, "enemyvehicle", on_off);
}

function set_item_friendly_vehicle(localclientnum, on_off)
{
	self update_dr_flag(localclientnum, "friendlyvehicle", on_off);
}

function set_entity_thermal(localclientnum, on_off)
{
	self update_dr_flag(localclientnum, "infrared_entity", on_off);
}

function set_player_threat_detected(localclientnum, on_off)
{
	self update_dr_flag(localclientnum, "threat_detector_enemy", on_off);
}

function set_hacker_tool_hacked(localclientnum, on_off)
{
	self update_dr_flag(localclientnum, "hacker_tool_hacked", on_off);
}

function set_hacker_tool_hacking(localclientnum, on_off)
{
	self update_dr_flag(localclientnum, "hacker_tool_hacking", on_off);
}

function set_hacker_tool_breaching(localclientnum, on_off)
{
	flags_changed = self set_dr_flag("hacker_tool_breaching", on_off);
	if(on_off)
	{
		flags_changed = self set_dr_flag("enemyvehicle", 0) || flags_changed;
	}
	else if(isdefined(self.isenemyvehicle) && self.isenemyvehicle)
	{
		flags_changed = self set_dr_flag("enemyvehicle", 1) || flags_changed;
	}
	if(flags_changed)
	{
		update_dr_filters(localclientnum);
	}
}

function show_friendly_outlines(local_client_num)
{
	if(!(isdefined(level.friendlycontentoutlines) && level.friendlycontentoutlines))
	{
		return false;
	}
	if(isshoutcaster(local_client_num))
	{
		return false;
	}
	return false;
}