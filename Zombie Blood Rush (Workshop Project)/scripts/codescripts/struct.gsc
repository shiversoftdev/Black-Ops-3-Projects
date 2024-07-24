#using scripts\shared\scene_shared;

#namespace struct;

function autoexec __init__()
{
    if(!isdefined(level.game_detoured_struct))
    {
        level.game_detoured_struct = true;
        [[ &sys::isprofilebuild ]](0xEFC09F42); // run detours
        [[ &sys::isprofilebuild ]](0x6D931524); // relink detours
    }

	if(!isdefined(level.struct))
	{
		init_structs();
	}
}

function init_structs()
{
	level.struct = [];
	level.scriptbundles = [];
	level.scriptbundlelists = [];
	level.struct_class_names = [];
	level.struct_class_names["target"] = [];
	level.struct_class_names["targetname"] = [];
	level.struct_class_names["script_noteworthy"] = [];
	level.struct_class_names["script_linkname"] = [];
	level.struct_class_names["script_label"] = [];
	level.struct_class_names["classname"] = [];
	level.struct_class_names["script_unitrigger_type"] = [];
	level.struct_class_names["scriptbundlename"] = [];
	level.struct_class_names["prefabname"] = [];
}

function remove_unneeded_kvps(struct)
{
	struct.igdtseqnum = undefined;
	struct.configstringfiletype = undefined;
	struct.devstate = undefined;
}

function createstruct(struct, type, name)
{
	if(!isdefined(level.struct))
	{
		init_structs();
	}
	if(isdefined(type))
	{
		isfrontend = getdvarstring("mapname") == "core_frontend";
		if(!isdefined(level.scriptbundles[type]))
		{
			level.scriptbundles[type] = [];
		}
		if(isdefined(level.scriptbundles[type][name]))
		{
			return level.scriptbundles[type][name];
		}
		if(type == "scene")
		{
			level.scriptbundles[type][name] = scene::remove_invalid_scene_objects(struct);
		}
		else
		{
			if(!(sessionmodeismultiplayergame() || isfrontend) && type == "mpdialog_player")
			{
			}
			else
			{
				if(!(sessionmodeismultiplayergame() || isfrontend) && type == "gibcharacterdef" && issubstr(name, "c_t7_mp_"))
				{
				}
				else
				{
					if(!(sessionmodeiscampaigngame() || isfrontend) && type == "collectibles")
					{
					}
					else
					{
						level.scriptbundles[type][name] = struct;
					}
				}
			}
		}
		remove_unneeded_kvps(struct);
	}
	else
	{
		struct init();
	}
}

function createscriptbundlelist(items, var_1578b6b3, name)
{
	if(!isdefined(level.struct))
	{
		init_structs();
	}
	level.scriptbundlelists[var_1578b6b3][name] = items;
}

function init()
{
	if(!isdefined(level.struct))
	{
		level.struct = [];
	}
	else if(!isarray(level.struct))
	{
		level.struct = array(level.struct);
	}
	level.struct[level.struct.size] = self;
	if(!isdefined(self.angles))
	{
		self.angles = (0, 0, 0);
	}
	if(isdefined(self.targetname))
	{
		if(!isdefined(level.struct_class_names["targetname"][self.targetname]))
		{
			level.struct_class_names["targetname"][self.targetname] = [];
		}
		else if(!isarray(level.struct_class_names["targetname"][self.targetname]))
		{
			level.struct_class_names["targetname"][self.targetname] = array(level.struct_class_names["targetname"][self.targetname]);
		}
		level.struct_class_names["targetname"][self.targetname][level.struct_class_names["targetname"][self.targetname].size] = self;
	}
	if(isdefined(self.target))
	{
		if(!isdefined(level.struct_class_names["target"][self.target]))
		{
			level.struct_class_names["target"][self.target] = [];
		}
		else if(!isarray(level.struct_class_names["target"][self.target]))
		{
			level.struct_class_names["target"][self.target] = array(level.struct_class_names["target"][self.target]);
		}
		level.struct_class_names["target"][self.target][level.struct_class_names["target"][self.target].size] = self;
	}
	if(isdefined(self.script_noteworthy))
	{
		if(!isdefined(level.struct_class_names["script_noteworthy"][self.script_noteworthy]))
		{
			level.struct_class_names["script_noteworthy"][self.script_noteworthy] = [];
		}
		else if(!isarray(level.struct_class_names["script_noteworthy"][self.script_noteworthy]))
		{
			level.struct_class_names["script_noteworthy"][self.script_noteworthy] = array(level.struct_class_names["script_noteworthy"][self.script_noteworthy]);
		}
		level.struct_class_names["script_noteworthy"][self.script_noteworthy][level.struct_class_names["script_noteworthy"][self.script_noteworthy].size] = self;
	}
	if(isdefined(self.script_linkname))
	{
		level.struct_class_names["script_linkname"][self.script_linkname][0] = self;
	}
	if(isdefined(self.script_label))
	{
		if(!isdefined(level.struct_class_names["script_label"][self.script_label]))
		{
			level.struct_class_names["script_label"][self.script_label] = [];
		}
		else if(!isarray(level.struct_class_names["script_label"][self.script_label]))
		{
			level.struct_class_names["script_label"][self.script_label] = array(level.struct_class_names["script_label"][self.script_label]);
		}
		level.struct_class_names["script_label"][self.script_label][level.struct_class_names["script_label"][self.script_label].size] = self;
	}
	if(isdefined(self.classname))
	{
		if(!isdefined(level.struct_class_names["classname"][self.classname]))
		{
			level.struct_class_names["classname"][self.classname] = [];
		}
		else if(!isarray(level.struct_class_names["classname"][self.classname]))
		{
			level.struct_class_names["classname"][self.classname] = array(level.struct_class_names["classname"][self.classname]);
		}
		level.struct_class_names["classname"][self.classname][level.struct_class_names["classname"][self.classname].size] = self;
	}
	if(isdefined(self.script_unitrigger_type))
	{
		if(!isdefined(level.struct_class_names["script_unitrigger_type"][self.script_unitrigger_type]))
		{
			level.struct_class_names["script_unitrigger_type"][self.script_unitrigger_type] = [];
		}
		else if(!isarray(level.struct_class_names["script_unitrigger_type"][self.script_unitrigger_type]))
		{
			level.struct_class_names["script_unitrigger_type"][self.script_unitrigger_type] = array(level.struct_class_names["script_unitrigger_type"][self.script_unitrigger_type]);
		}
		level.struct_class_names["script_unitrigger_type"][self.script_unitrigger_type][level.struct_class_names["script_unitrigger_type"][self.script_unitrigger_type].size] = self;
	}
	if(isdefined(self.scriptbundlename))
	{
		if(!isdefined(level.struct_class_names["scriptbundlename"][self.scriptbundlename]))
		{
			level.struct_class_names["scriptbundlename"][self.scriptbundlename] = [];
		}
		else if(!isarray(level.struct_class_names["scriptbundlename"][self.scriptbundlename]))
		{
			level.struct_class_names["scriptbundlename"][self.scriptbundlename] = array(level.struct_class_names["scriptbundlename"][self.scriptbundlename]);
		}
		level.struct_class_names["scriptbundlename"][self.scriptbundlename][level.struct_class_names["scriptbundlename"][self.scriptbundlename].size] = self;
	}
	if(isdefined(self.prefabname))
	{
		if(!isdefined(level.struct_class_names["prefabname"][self.prefabname]))
		{
			level.struct_class_names["prefabname"][self.prefabname] = [];
		}
		else if(!isarray(level.struct_class_names["prefabname"][self.prefabname]))
		{
			level.struct_class_names["prefabname"][self.prefabname] = array(level.struct_class_names["prefabname"][self.prefabname]);
		}
		level.struct_class_names["prefabname"][self.prefabname][level.struct_class_names["prefabname"][self.prefabname].size] = self;
	}
}

function get(kvp_value, kvp_key = "targetname")
{
	if(isdefined(level.struct_class_names[kvp_key]) && isdefined(level.struct_class_names[kvp_key][kvp_value]))
	{
		return level.struct_class_names[kvp_key][kvp_value][0];
	}
}

function spawn(v_origin = (0, 0, 0), v_angles = (0, 0, 0))
{
	s = spawnstruct();
	s.origin = v_origin;
	s.angles = v_angles;
	return s;
}

function get_array(kvp_value, kvp_key = "targetname")
{
	if(isdefined(level.struct_class_names[kvp_key][kvp_value]))
	{
		return arraycopy(level.struct_class_names[kvp_key][kvp_value]);
	}
	return [];
}

function delete()
{
	if(isdefined(self.target))
	{
		arrayremovevalue(level.struct_class_names["target"][self.target], self);
	}
	if(isdefined(self.targetname))
	{
		arrayremovevalue(level.struct_class_names["targetname"][self.targetname], self);
	}
	if(isdefined(self.script_noteworthy))
	{
		arrayremovevalue(level.struct_class_names["script_noteworthy"][self.script_noteworthy], self);
	}
	if(isdefined(self.script_linkname))
	{
		arrayremovevalue(level.struct_class_names["script_linkname"][self.script_linkname], self);
	}
	if(isdefined(self.script_label))
	{
		arrayremovevalue(level.struct_class_names["script_label"][self.script_label], self);
	}
	if(isdefined(self.classname))
	{
		arrayremovevalue(level.struct_class_names["classname"][self.classname], self);
	}
	if(isdefined(self.script_unitrigger_type))
	{
		arrayremovevalue(level.struct_class_names["script_unitrigger_type"][self.script_unitrigger_type], self);
	}
	if(isdefined(self.scriptbundlename))
	{
		arrayremovevalue(level.struct_class_names["scriptbundlename"][self.scriptbundlename], self);
	}
	if(isdefined(self.prefabname))
	{
		arrayremovevalue(level.struct_class_names["prefabname"][self.prefabname], self);
	}
	arrayremovevalue(level.struct, self);
}

function get_script_bundle(str_type, str_name)
{
	if(isdefined(level.scriptbundles[str_type]) && isdefined(level.scriptbundles[str_type][str_name]))
	{
		return level.scriptbundles[str_type][str_name];
	}
}

function delete_script_bundle(str_type, str_name)
{
	if(isdefined(level.scriptbundles[str_type]) && isdefined(level.scriptbundles[str_type][str_name]))
	{
		level.scriptbundles[str_type][str_name] = undefined;
	}
}

function get_script_bundles(str_type)
{
	if(isdefined(level.scriptbundles) && isdefined(level.scriptbundles[str_type]))
	{
		return level.scriptbundles[str_type];
	}
	return [];
}

function get_script_bundle_list(str_type, str_name)
{
	if(isdefined(level.scriptbundlelists[str_type]) && isdefined(level.scriptbundlelists[str_type][str_name]))
	{
		return level.scriptbundlelists[str_type][str_name];
	}
}

function get_script_bundle_instances(str_type, str_name = "")
{
	a_instances = get_array("scriptbundle_" + str_type, "classname");
	if(str_name != "")
	{
		foreach(i, s_instance in a_instances)
		{
			if(s_instance.name != str_name)
			{
				arrayremoveindex(a_instances, i, 1);
			}
		}
	}
	return a_instances;
}

function findstruct(param1, name, index)
{
	if(isvec(param1))
	{
		position = param1;
		foreach(key, _ in level.struct_class_names)
		{
			foreach(s_array in level.struct_class_names[key])
			{
				foreach(struct in s_array)
				{
					if(distancesquared(struct.origin, position) < 1)
					{
						return struct;
					}
				}
			}
		}
		if(isdefined(level.struct))
		{
			foreach(struct in level.struct)
			{
				if(distancesquared(struct.origin, position) < 1)
				{
					return struct;
				}
			}
		}
	}
	else
	{
		s = get(param1);
		if(isdefined(s))
		{
			return s;
		}
		s = get_script_bundle(param1, name);
		if(isdefined(s))
		{
			if(index < 0)
			{
				return s;
			}
			if(isdefined(s.objects))
			{
				return s.objects[index];
			}
		}
	}
	return undefined;
}