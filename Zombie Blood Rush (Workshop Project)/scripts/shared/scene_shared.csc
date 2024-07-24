#using scripts\shared\callbacks_shared;
#using scripts\shared\math_shared;
#using scripts\shared\filter_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\shared\scriptbundle_shared;
#using scripts\shared\scene_debug_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\array_shared;
#using scripts\shared\animation_shared;
#using scripts\codescripts\struct;

#using_animtree("generic");

class csceneobject : cscriptbundleobjectbase
{
	var _n_clientnum;
	var _e_array;
	var _o_bundle;
	var _s;
	var _is_valid;
	var _str_name;
	var _b_spawnonce_used;

	constructor()
	{
		_b_spawnonce_used = 0;
		_is_valid = 1;
	}

	destructor()
	{
	}

	function in_a_different_scene()
	{
		if(isdefined(_n_clientnum))
		{
			if(isdefined(_e_array[_n_clientnum]) && isdefined(_e_array[_n_clientnum].current_scene) && _e_array[_n_clientnum].current_scene != _o_bundle._str_name)
			{
				return true;
			}
		}
		else if(isdefined(_e_array[0]) && isdefined(_e_array[0].current_scene) && _e_array[0].current_scene != _o_bundle._str_name)
		{
			return true;
		}
		return false;
	}

	function is_alive(clientnum)
	{
		return isdefined(_e_array[clientnum]);
	}

	function has_init_state()
	{
        if(!isdefined(_s))
        {
            return false;
        }
		return _s scene::_has_init_state();
	}

	function wait_till_scene_ready()
	{
		[[ scene() ]]->wait_till_scene_ready();
	}

	function get_align_tag()
	{
		if(isdefined(_s.aligntargettag))
		{
			return _s.aligntargettag;
		}
		return _o_bundle._s.aligntargettag;
	}

	function _play_anim(clientnum, animation, n_delay_min = 0, n_delay_max = 0, n_rate = 1, n_blend, str_siege_shot, loop)
	{
		n_delay = n_delay_min;
		if(n_delay_max > n_delay_min)
		{
			n_delay = randomfloatrange(n_delay_min, n_delay_max);
		}
		if(n_delay > 0)
		{
			flagsys::set("ready");
			wait(n_delay);
			_spawn(clientnum);
		}
		else
		{
			_spawn(clientnum);
		}
		if(is_alive(clientnum))
		{
			_e_array[clientnum] show();
			if(isdefined(_s.issiege) && _s.issiege)
			{
				_e_array[clientnum] notify("end");
				_e_array[clientnum] animation::play_siege(animation, str_siege_shot, n_rate, loop);
			}
			else
			{
				align = get_align_ent(clientnum);
				tag = get_align_tag();
				if(align == level)
				{
					align = (0, 0, 0);
					tag = (0, 0, 0);
				}
				_e_array[clientnum] animation::play(animation, align, tag, n_rate, n_blend);
			}
		}
		_is_valid = is_alive(clientnum);
	}

	function _cleanup(clientnum)
	{
		if(isdefined(_e_array[clientnum]) && isdefined(_e_array[clientnum].current_scene))
		{
			_e_array[clientnum] flagsys::clear(_o_bundle._str_name);
			if(_e_array[clientnum].current_scene == _o_bundle._str_name)
			{
				_e_array[clientnum] flagsys::clear("scene");
				_e_array[clientnum].finished_scene = _o_bundle._str_name;
				_e_array[clientnum].current_scene = undefined;
			}
		}
		if(clientnum === _n_clientnum || clientnum == 0)
		{
			if(isdefined(_o_bundle) && (isdefined(_o_bundle.scene_stopped) && _o_bundle.scene_stopped))
			{
				_o_bundle = undefined;
			}
		}
	}

	function _prepare(clientnum)
	{
        if(!isdefined(_s))
        {
            return;
        }
		if(!(isdefined(_s.issiege) && _s.issiege))
		{
			if(!_e_array[clientnum] hasanimtree())
			{
				_e_array[clientnum] useanimtree(#animtree);
			}
		}
		_e_array[clientnum].animname = _str_name;
		_e_array[clientnum].anim_debug_name = _s.name;
		_e_array[clientnum] flagsys::set("scene");
		_e_array[clientnum] flagsys::set(_o_bundle._str_name);
		_e_array[clientnum].current_scene = _o_bundle._str_name;
		_e_array[clientnum].finished_scene = undefined;
	}

	function _spawn(clientnum, b_hide = 1)
	{
        if(!isdefined(_s))
        {
            return;
        }
		if(!isdefined(_e_array[clientnum]))
		{
			b_allows_multiple = [[ scene() ]]->allows_multiple();
			if(cscriptbundleobjectbase::error(b_allows_multiple && (isdefined(_s.nospawn) && _s.nospawn), "Scene that allow multiple instances must be allowed to spawn (uncheck 'Do Not Spawn')."))
			{
				return;
			}
			_e_array[clientnum] = scene::get_existing_ent(clientnum, _str_name);
			if(!isdefined(_e_array[clientnum]) && isdefined(_s.name) && !b_allows_multiple)
			{
				_e_array[clientnum] = scene::get_existing_ent(clientnum, _s.name);
			}
			if(!isdefined(_e_array[clientnum]) && (!(isdefined(_s.nospawn) && _s.nospawn)) && !_b_spawnonce_used)
			{
				_e_align = get_align_ent(clientnum);
				_e_array[clientnum] = util::spawn_model(clientnum, _s.model, _e_align.origin, _e_align.angles);
				if(isdefined(_e_array[clientnum]))
				{
					if(b_hide)
					{
						_e_array[clientnum] hide();
					}
					_e_array[clientnum].scene_spawned = _o_bundle._s.name;
					_e_array[clientnum].targetname = _s.name;
				}
				else
				{
					cscriptbundleobjectbase::error(!(isdefined(_s.nospawn) && _s.nospawn), "No entity exists with matching name of scene object.");
				}
			}
			if(isdefined(_s.spawnonce) && _s.spawnonce && _b_spawnonce_used)
			{
				return;
			}
			if(!(cscriptbundleobjectbase::error(!(isdefined(_s.nospawn) && _s.nospawn) && !isdefined(_e_array[clientnum]), "No entity exists with matching name of scene object. Make sure a model is specified if you want to spawn it.")))
			{
				_prepare(clientnum);
			}
		}
		if(isdefined(_e_array[clientnum]))
		{
			flagsys::set("ready");
			if(isdefined(_s.spawnonce) && _s.spawnonce)
			{
				_b_spawnonce_used = 1;
			}
		}
	}

	function get_orig_name()
	{
		return _s.name;
	}

	function get_name()
	{
		return _str_name;
	}

	function _assign_unique_name()
	{
		if([[ scene() ]]->allows_multiple())
		{
			if(isdefined(_s) && isdefined(_s.name))
			{
				_str_name = (_s.name + "_gen") + level.scene_object_id;
			}
			else
			{
				_str_name = (([[ scene() ]]->get_name()) + "_noname") + level.scene_object_id;
			}
			level.scene_object_id++;
		}
		else
		{
			if(isdefined(_s) && isdefined(_s.name))
			{
				_str_name = _s.name;
			}
			else
			{
				_str_name = (([[ scene() ]]->get_name()) + "_noname") + ([[ scene() ]]->get_object_id());
			}
		}
	}

	function scene()
	{
		return _o_bundle;
	}

	function get_align_ent(clientnum)
	{
		e_align = undefined;
		if(isdefined(_s.aligntarget))
		{
			a_scene_ents = [[ _o_bundle ]]->get_ents();
			if(isdefined(a_scene_ents[clientnum][_s.aligntarget]))
			{
				e_align = a_scene_ents[clientnum][_s.aligntarget];
			}
			else
			{
				e_align = scene::get_existing_ent(clientnum, _s.aligntarget);
			}
			cscriptbundleobjectbase::error(!isdefined(e_align), ("Align target '" + (isdefined(_s.aligntarget) ? "" + _s.aligntarget : "")) + "' doesn't exist for scene object.");
		}
		if(!isdefined(e_align))
		{
			e_align = [[ scene() ]]->get_align_ent(clientnum);
		}
		return e_align;
	}

	function finish_per_client(clientnum, b_clear = 0)
	{
		if(!is_alive(clientnum))
		{
			_cleanup(clientnum);
			_e_array[clientnum] = undefined;
			_is_valid = 0;
		}
		flagsys::set("ready");
		flagsys::set("done");
		if(isdefined(_e_array[clientnum]))
		{
			if(is_alive(clientnum) && (isdefined(_s.deletewhenfinished) && _s.deletewhenfinished || b_clear))
			{
				_e_array[clientnum] delete();
			}
		}
		_cleanup(clientnum);
	}

	function finish(b_clear = 0)
	{
		self notify("new_state");
		if(isdefined(_n_clientnum))
		{
			finish_per_client(_n_clientnum, b_clear);
		}
		else
		{
			for(clientnum = 1; clientnum < getmaxlocalclients(); clientnum++)
			{
				if(isdefined(getlocalplayer(clientnum)))
				{
					finish_per_client(clientnum, b_clear);
				}
			}
			finish_per_client(0, b_clear);
		}
	}

	function play_per_client(clientnum)
	{
        if(!isdefined(_s))
        {
            return;
        }
		self endon("new_state");
		if(isdefined(_s.mainanim))
		{
			_play_anim(clientnum, _s.mainanim, _s.maindelaymin, _s.maindelaymax, 1, _s.mainblend, _s.mainshot);
			flagsys::set("main_done");
			if(is_alive(clientnum))
			{
				if(isdefined(_s.endanim))
				{
					_play_anim(clientnum, _s.endanim, 0, 0, 1, undefined, _s.endshot, 1);
					if(is_alive(clientnum))
					{
						if(isdefined(_s.endanimloop))
						{
							_play_anim(clientnum, _s.endanimloop, 0, 0, 1, undefined, _s.endshotloop, 1);
						}
					}
				}
				else if(isdefined(_s.endanimloop))
				{
					_play_anim(clientnum, _s.endanimloop, 0, 0, 1, undefined, _s.endshotloop, 1);
				}
			}
		}
		thread finish_per_client(clientnum);
	}

	function play()
	{
        if(!isdefined(_s))
        {
            return;
        }
		flagsys::clear("ready");
		flagsys::clear("done");
		flagsys::clear("main_done");
		self notify("new_state");
		self endon("new_state");
		self notify("play");
		waittillframeend;
		if(isdefined(_n_clientnum))
		{
			play_per_client(_n_clientnum);
		}
		else
		{
			for(clientnum = 1; clientnum < getmaxlocalclients(); clientnum++)
			{
				if(isdefined(getlocalplayer(clientnum)))
				{
					thread play_per_client(clientnum);
				}
			}
			play_per_client(0);
		}
	}

	function initialize_per_client(clientnum)
	{
        if(!isdefined(_s))
        {
            return;
        }
		self endon("new_state");
		if(isdefined(_s.firstframe) && _s.firstframe)
		{
			if(!cscriptbundleobjectbase::error(!isdefined(_s.mainanim), "No animation defined for first frame."))
			{
				_play_anim(clientnum, _s.mainanim, 0, 0, 0, undefined, _s.mainshot);
			}
		}
		else
		{
			if(isdefined(_s.initanim))
			{
				_play_anim(clientnum, _s.initanim, _s.initdelaymin, _s.initdelaymax, 1, undefined, _s.initshot);
				if(is_alive(clientnum))
				{
					if(isdefined(_s.initanimloop))
					{
						_play_anim(clientnum, _s.initanimloop, 0, 0, 1, undefined, _s.initshotloop, 1);
					}
				}
			}
			else
			{
				if(isdefined(_s.initanimloop))
				{
					_play_anim(clientnum, _s.initanimloop, _s.initdelaymin, _s.initdelaymax, 1, undefined, _s.initshotloop, 1);
				}
				else
				{
					flagsys::set("ready");
				}
			}
		}
		if(!_is_valid)
		{
			flagsys::set("done");
		}
	}

	function initialize()
	{
        if(!isdefined(_s))
        {
            return;
        }
		if(isdefined(_s.spawnoninit) && _s.spawnoninit)
		{
			if(isdefined(_n_clientnum))
			{
				_spawn(_n_clientnum, isdefined(_s.firstframe) && _s.firstframe || isdefined(_s.initanim) || isdefined(_s.initanimloop));
			}
			else
			{
				_spawn(0, isdefined(_s.firstframe) && _s.firstframe || isdefined(_s.initanim) || isdefined(_s.initanimloop));
				for(clientnum = 1; clientnum < getmaxlocalclients(); clientnum++)
				{
					if(isdefined(getlocalplayer(clientnum)))
					{
						if(isdefined(_s.spawnoninit) && _s.spawnoninit)
						{
							_spawn(clientnum, isdefined(_s.firstframe) && _s.firstframe || isdefined(_s.initanim) || isdefined(_s.initanimloop));
						}
					}
				}
			}
		}
		flagsys::clear("ready");
		flagsys::clear("done");
		flagsys::clear("main_done");
		self notify("new_state");
		self endon("new_state");
		self notify("init");
		waittillframeend;
		if(isdefined(_n_clientnum))
		{
			thread initialize_per_client(_n_clientnum);
		}
		else
		{
			for(clientnum = 1; clientnum < getmaxlocalclients(); clientnum++)
			{
				if(isdefined(getlocalplayer(clientnum)))
				{
					thread initialize_per_client(clientnum);
				}
			}
			initialize_per_client(0);
		}
	}

	function first_init(s_objdef, o_scene, e_ent, localclientnum)
	{
		cscriptbundleobjectbase::init(s_objdef, o_scene, e_ent, localclientnum);
		_assign_unique_name();
		if(isdefined(_e_array) && _e_array.size)
		{
			_prepare(_n_clientnum);
		}
		return self;
	}

}

class cscene : cscriptbundlebase
{
	var _str_state;
	var _a_objects;
	var _s;
	var _e_root;
	var _str_name;
	var scene_stopped;
	var _testing;
	var _str_mode;
	var _n_object_id;

	constructor()
	{
		_n_object_id = 0;
		_str_state = "";
	}

	destructor()
	{
	}

	function get_state()
	{
		return _str_state;
	}

	function on_error()
	{
		stop();
	}

	function get_valid_objects()
	{
		a_obj = [];
		foreach(obj in _a_objects)
		{
			if(obj._is_valid && !([[ obj ]]->in_a_different_scene()))
			{
				if(!isdefined(a_obj))
				{
					a_obj = [];
				}
				else if(!isarray(a_obj))
				{
					a_obj = array(a_obj);
				}
				a_obj[a_obj.size] = obj;
			}
		}
		return a_obj;
	}

	function wait_till_scene_done()
	{
		array::flagsys_wait(_a_objects, "done");
	}

	function wait_till_scene_ready()
	{
		if(isdefined(_a_objects))
		{
			array::flagsys_wait(_a_objects, "ready");
		}
	}

	function is_looping()
	{
		return isdefined(_s.looping) && _s.looping;
	}

	function allows_multiple()
	{
		return isdefined(_s.allowmultiple) && _s.allowmultiple;
	}

	function get_align_ent(clientnum)
	{
		e_align = _e_root;
		if(isdefined(_s.aligntarget))
		{
			e_gdt_align = scene::get_existing_ent(clientnum, _s.aligntarget);
			if(isdefined(e_gdt_align))
			{
				e_align = e_gdt_align;
			}
		}
		return e_align;
	}

	function get_root()
	{
		return _e_root;
	}

	function get_ents()
	{
		a_ents = [];
		for(clientnum = 0; clientnum < getmaxlocalclients(); clientnum++)
		{
			if(isdefined(getlocalplayer(clientnum)))
			{
				a_ents[clientnum] = [];
				foreach(o_obj in _a_objects)
				{
					ent = [[ o_obj ]]->get_ent(clientnum);
					if(isdefined(o_obj._s.name))
					{
						a_ents[clientnum][o_obj._s.name] = ent;
						continue;
					}
					if(!isdefined(a_ents))
					{
						a_ents = [];
					}
					else if(!isarray(a_ents))
					{
						a_ents = array(a_ents);
					}
					a_ents[a_ents.size] = ent;
				}
			}
		}
		return a_ents;
	}

	function _call_state_funcs(str_state)
	{
		self endon("stopped");
		wait_till_scene_ready();
		if(str_state == "play")
		{
			waittillframeend;
		}
		level notify((_str_name + "_") + str_state);
		if(isdefined(level.scene_funcs) && isdefined(level.scene_funcs[_str_name]) && isdefined(level.scene_funcs[_str_name][str_state]))
		{
			a_all_ents = get_ents();
			foreach(a_ents in a_all_ents)
			{
				foreach(handler in level.scene_funcs[_str_name][str_state])
				{
					func = handler[0];
					args = handler[1];
					switch(args.size)
					{
						case 6:
						{
							_e_root thread [[func]](a_ents, args[0], args[1], args[2], args[3], args[4], args[5]);
							break;
						}
						case 5:
						{
							_e_root thread [[func]](a_ents, args[0], args[1], args[2], args[3], args[4]);
							break;
						}
						case 4:
						{
							_e_root thread [[func]](a_ents, args[0], args[1], args[2], args[3]);
							break;
						}
						case 3:
						{
							_e_root thread [[func]](a_ents, args[0], args[1], args[2]);
							break;
						}
						case 2:
						{
							_e_root thread [[func]](a_ents, args[0], args[1]);
							break;
						}
						case 1:
						{
							_e_root thread [[func]](a_ents, args[0]);
							break;
						}
						case 0:
						{
							_e_root thread [[func]](a_ents);
							break;
						}
					}
				}
			}
		}
	}

	function has_init_state()
	{
		b_has_init_state = 0;
		foreach(o_scene_object in _a_objects)
		{
			if([[ o_scene_object ]]->has_init_state())
			{
				b_has_init_state = 1;
				break;
			}
		}
		return b_has_init_state;
	}

	function stop(b_clear = 0, b_finished = 0)
	{
		self notify("new_state");
		level flagsys::clear(_str_name + "_playing");
		level flagsys::clear(_str_name + "_initialized");
		_str_state = "";
		thread _call_state_funcs("stop");
		scene_stopped = 1;
		foreach(o_obj in _a_objects)
		{
			if(isdefined(o_obj) && !([[ o_obj ]]->in_a_different_scene()))
			{
				thread [[ o_obj ]]->finish(b_clear);
			}
		}
		self notify("stopped", b_finished);
		if(isdefined(level.active_scenes[_str_name]))
		{
			arrayremovevalue(level.active_scenes[_str_name], _e_root);
			if(level.active_scenes[_str_name].size == 0)
			{
				level.active_scenes[_str_name] = undefined;
			}
		}
		if(isdefined(_e_root) && isdefined(_e_root.scenes))
		{
			arrayremovevalue(_e_root.scenes, self);
			if(_e_root.scenes.size == 0)
			{
				_e_root.scenes = undefined;
			}
			_e_root notify("scene_done", _str_name);
			_e_root.scene_played = 1;
		}
	}

	function run_next()
	{
        if(!isdefined(_s))
        {
            return;
        }
		if(isdefined(_s.nextscenebundle) && _s.vmtype != "both")
		{
			self waittill("stopped", b_finished);
			if(b_finished)
			{
				if(_s.scenetype == "fxanim" && _s.nextscenemode === "init")
				{
					if(!cscriptbundlebase::error(!has_init_state(), ("Scene can't init next scene '" + _s.nextscenebundle) + "' because it doesn't have an init state."))
					{
						if(allows_multiple())
						{
							_e_root thread scene::init(_s.nextscenebundle, get_ents());
						}
						else
						{
							_e_root thread scene::init(_s.nextscenebundle);
						}
					}
				}
				else
				{
					if(allows_multiple())
					{
						_e_root thread scene::play(_s.nextscenebundle, get_ents());
					}
					else
					{
						_e_root thread scene::play(_s.nextscenebundle);
					}
				}
			}
		}
	}

	function play(b_testing = 0, str_mode = "")
	{
		level endon("demo_jump");
		self notify("new_state");
		self endon("new_state");
		_testing = b_testing;
		_str_mode = str_mode;
		if(get_valid_objects().size > 0)
		{
			foreach(o_obj in _a_objects)
			{
				thread [[ o_obj ]]->play();
			}
			level flagsys::set(_str_name + "_playing");
			_str_state = "play";
			wait_till_scene_ready();
			thread _call_state_funcs("play");
			wait_till_scene_done();
			array::flagsys_wait_any_flag(_a_objects, "done", "main_done");
			if(isdefined(_e_root))
			{
				_e_root notify("scene_done", _str_name);
				thread _call_state_funcs("done");
			}
			array::flagsys_wait(_a_objects, "done");
			if(is_looping() || _str_mode == "loop")
			{
				if(has_init_state())
				{
					level flagsys::clear(_str_name + "_playing");
					thread initialize();
				}
				else
				{
					level flagsys::clear(_str_name + "_initialized");
					thread play(b_testing, str_mode);
				}
			}
			else
			{
				thread run_next();
				thread stop(0, 1);
			}
		}
		else
		{
			thread stop(0, 1);
		}
	}

	function get_object_id()
	{
		_n_object_id++;
		return _n_object_id;
	}

	function initialize(b_playing = 0)
	{
		self notify("new_state");
		self endon("new_state");
		if(get_valid_objects().size > 0)
		{
			level flagsys::set(_str_name + "_initialized");
			_str_state = "init";
			foreach(o_obj in _a_objects)
			{
				thread [[ o_obj ]]->initialize();
			}
			if(!b_playing)
			{
				thread _call_state_funcs("init");
			}
		}
		wait_till_scene_done();
		thread stop();
	}

	function get_valid_object_defs()
	{
		a_obj_defs = [];
		foreach(s_obj in _s.objects)
		{
			if(_s.vmtype == "client" || s_obj.vmtype == "client")
			{
				if(isdefined(s_obj.name) || isdefined(s_obj.model) || isdefined(s_obj.initanim) || isdefined(s_obj.mainanim))
				{
					if(!(isdefined(s_obj.disabled) && s_obj.disabled))
					{
						if(!isdefined(a_obj_defs))
						{
							a_obj_defs = [];
						}
						else if(!isarray(a_obj_defs))
						{
							a_obj_defs = array(a_obj_defs);
						}
						a_obj_defs[a_obj_defs.size] = s_obj;
					}
				}
			}
		}
		return a_obj_defs;
	}

	function init(str_scenedef, s_scenedef, e_align, a_ents, b_test_run)
	{
        if(!isdefined(_s))
        {
            return;
        }
		cscriptbundlebase::init(str_scenedef, s_scenedef, b_test_run);
		if(!isdefined(a_ents))
		{
			a_ents = [];
		}
		else if(!isarray(a_ents))
		{
			a_ents = array(a_ents);
		}
		if(!cscriptbundlebase::error(a_ents.size > _s.objects.size, "Trying to use more entities than scene supports."))
		{
			_e_root = e_align;
			if(!isdefined(level.active_scenes[_str_name]))
			{
				level.active_scenes[_str_name] = [];
			}
			else if(!isarray(level.active_scenes[_str_name]))
			{
				level.active_scenes[_str_name] = array(level.active_scenes[_str_name]);
			}
			level.active_scenes[_str_name][level.active_scenes[_str_name].size] = _e_root;
			if(!isdefined(_e_root.scenes))
			{
				_e_root.scenes = [];
			}
			else if(!isarray(_e_root.scenes))
			{
				_e_root.scenes = array(_e_root.scenes);
			}
			_e_root.scenes[_e_root.scenes.size] = self;
			a_objs = get_valid_object_defs();
			foreach(str_name, e_ent in arraycopy(a_ents))
			{
				foreach(i, s_obj in arraycopy(a_objs))
				{
					if(s_obj.name === (isdefined(str_name) ? "" + str_name : ""))
					{
						cscriptbundlebase::add_object([[ new csceneobject() ]]->first_init(s_obj, self, e_ent, _e_root.localclientnum));
						arrayremoveindex(a_ents, str_name);
						arrayremoveindex(a_objs, i);
						break;
					}
				}
			}
			foreach(s_obj in a_objs)
			{
				cscriptbundlebase::add_object([[ new csceneobject() ]]->first_init(s_obj, self, array::pop(a_ents), _e_root.localclientnum));
			}
			self thread initialize();
		}
	}

}

#namespace scene;

function player_scene_animation_skip(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	anim_name = self getcurrentanimscriptedname();
	if(isdefined(anim_name) && anim_name != "")
	{
		is_looping = isanimlooping(localclientnum, anim_name);
		if(!is_looping)
		{
			self setanimtimebyname(anim_name, 1, 1);
		}
	}
}

function player_scene_skip_completed(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	flushsubtitles(localclientnum);
	setdvar("r_graphicContentBlur", 0);
	setdvar("r_makeDark_enable", 0);
}

function get_existing_ent(clientnum, str_name)
{
	e = getent(clientnum, str_name, "animname");
	if(!isdefined(e))
	{
		e = getent(clientnum, str_name, "script_animname");
		if(!isdefined(e))
		{
			e = getent(clientnum, str_name, "targetname");
			if(!isdefined(e))
			{
				e = struct::get(str_name, "targetname");
			}
		}
	}
	return e;
}

function autoexec __init__sytem__()
{
	system::register("scene", &__init__, &__main__, undefined);
}

function __init__()
{
	a_scenedefs = struct::get_script_bundles("scene");
	level.server_scenes = [];
	foreach(s_scenedef in a_scenedefs)
	{
		s_scenedef.editaction = undefined;
		s_scenedef.newobject = undefined;
		if(s_scenedef is_igc())
		{
			level.server_scenes[s_scenedef.name] = s_scenedef;
			continue;
		}
		if(s_scenedef.vmtype == "both")
		{
			n_clientbits = getminbitcountfornum(3);
			clientfield::register("world", s_scenedef.name, 1, n_clientbits, "int", &cf_server_sync, 0, 0);
		}
	}
	clientfield::register("toplayer", "postfx_igc", 1, 2, "counter", &postfx_igc, 0, 0);
	clientfield::register("world", "in_igc", 1, 4, "int", &in_igc, 0, 0);
	clientfield::register("toplayer", "player_scene_skip_completed", 1, 2, "counter", &player_scene_skip_completed, 0, 0);
	clientfield::register("allplayers", "player_scene_animation_skip", 1, 2, "counter", &player_scene_animation_skip, 0, 0);
	clientfield::register("actor", "player_scene_animation_skip", 1, 2, "counter", &player_scene_animation_skip, 0, 0);
	clientfield::register("vehicle", "player_scene_animation_skip", 1, 2, "counter", &player_scene_animation_skip, 0, 0);
	clientfield::register("scriptmover", "player_scene_animation_skip", 1, 2, "counter", &player_scene_animation_skip, 0, 0);
	level.scene_object_id = 0;
	level.active_scenes = [];
	callback::on_localclient_shutdown(&on_localplayer_shutdown);
}

function in_igc(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	player = getlocalplayer(localclientnum);
	n_entnum = player getentitynumber();
	b_igc_active = 0;
	if(newval & (1 << n_entnum))
	{
		b_igc_active = 1;
	}
	igcactive(localclientnum, b_igc_active);
}

function private on_localplayer_shutdown(localclientnum)
{
	localplayer = self;
	codelocalplayer = getlocalplayer(localclientnum);
	if(isdefined(localplayer) && isdefined(localplayer.localclientnum) && isdefined(codelocalplayer) && localplayer == codelocalplayer)
	{
		filter::disable_filter_base_frame_transition(localplayer, 5);
		filter::disable_filter_sprite_transition(localplayer, 5);
		filter::disable_filter_frame_transition(localplayer, 5);
		localplayer.postfx_igc_on = undefined;
		localplayer.pstfx_world_construction = 0;
	}
}

function postfx_igc(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	self endon("entityshutdown");
	if(isdefined(self.postfx_igc_on) && self.postfx_igc_on)
	{
		return;
	}
	if(sessionmodeiszombiesgame())
	{
		postfx_igc_zombies(localclientnum);
		return;
	}
	if(newval == 3)
	{
		self thread postfx_igc_short(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump);
		return;
	}
	self.postfx_igc_on = 1;
	codeimagename = "postfx_igc_image" + localclientnum;
	createscenecodeimage(localclientnum, codeimagename);
	captureframe(localclientnum, codeimagename);
	filter::init_filter_base_frame_transition(self);
	filter::init_filter_sprite_transition(self);
	filter::init_filter_frame_transition(self);
	setfilterpasscodetexture(localclientnum, 5, 0, 0, codeimagename);
	setfilterpasscodetexture(localclientnum, 5, 1, 0, codeimagename);
	setfilterpasscodetexture(localclientnum, 5, 2, 0, codeimagename);
	filter::enable_filter_base_frame_transition(self, 5);
	filter::enable_filter_sprite_transition(self, 5);
	filter::enable_filter_frame_transition(self, 5);
	filter::set_filter_base_frame_transition_warp(self, 5, 1);
	filter::set_filter_base_frame_transition_boost(self, 5, 0.5);
	filter::set_filter_base_frame_transition_durden(self, 5, 1);
	filter::set_filter_base_frame_transition_durden_blur(self, 5, 1);
	filter::set_filter_sprite_transition_elapsed(self, 5, 0);
	filter::set_filter_sprite_transition_octogons(self, 5, 1);
	filter::set_filter_sprite_transition_blur(self, 5, 0);
	filter::set_filter_sprite_transition_boost(self, 5, 0);
	filter::set_filter_frame_transition_light_hexagons(self, 5, 0);
	filter::set_filter_frame_transition_heavy_hexagons(self, 5, 0);
	filter::set_filter_frame_transition_flare(self, 5, 0);
	filter::set_filter_frame_transition_blur(self, 5, 0);
	filter::set_filter_frame_transition_iris(self, 5, 0);
	filter::set_filter_frame_transition_saved_frame_reveal(self, 5, 0);
	filter::set_filter_frame_transition_warp(self, 5, 0);
	filter::set_filter_sprite_transition_move_radii(self, 5, 0, 0);
	filter::set_filter_base_frame_transition_warp(self, 5, 1);
	filter::set_filter_base_frame_transition_boost(self, 5, 1);
	n_hex = 0;
	b_streamer_wait = 1;
	i = 0;
	while(i < 2000)
	{
		st = i / 1000;
		if(b_streamer_wait && st >= 0.65)
		{
			n_streamer_time_total = 0;
			while(!isstreamerready() && n_streamer_time_total < 5000)
			{
				n_streamer_time = gettime();
				j = 650;
				while(j < 1150)
				{
					jt = j / 1000;
					filter::set_filter_frame_transition_heavy_hexagons(self, 5, mapfloat(0.65, 1.15, 0, 1, jt));
					wait(0.016);
					j = j + 16;
				}
				j = 1150;
				while(j < 650)
				{
					jt = j / 1000;
					filter::set_filter_frame_transition_heavy_hexagons(self, 5, mapfloat(0.65, 1.15, 0, 1, jt));
					wait(0.016);
					j = j - 16;
				}
				n_streamer_time_total = n_streamer_time_total + (gettime() - n_streamer_time);
			}
			b_streamer_wait = 0;
		}
		if(st <= 0.5)
		{
			filter::set_filter_frame_transition_iris(self, 5, mapfloat(0, 0.5, 0, 1, st));
		}
		else
		{
			if(st > 0.5 && st <= 0.85)
			{
				filter::set_filter_frame_transition_iris(self, 5, 1 - mapfloat(0.5, 0.85, 0, 1, st));
			}
			else
			{
				filter::set_filter_frame_transition_iris(self, 5, 0);
			}
		}
		if(newval == 2)
		{
			if(st > 1 && (!(isdefined(self.pstfx_world_construction) && self.pstfx_world_construction)))
			{
				self thread postfx::playpostfxbundle("pstfx_world_construction");
				self.pstfx_world_construction = 1;
			}
		}
		if(st > 0.5 && st <= 1)
		{
			n_hex = mapfloat(0.5, 1, 0, 1, st);
			filter::set_filter_frame_transition_light_hexagons(self, 5, n_hex);
			if(st >= 0.8)
			{
				filter::set_filter_frame_transition_flare(self, 5, mapfloat(0.8, 1, 0, 1, st));
			}
		}
		else
		{
			if(st > 1 && st < 1.5)
			{
				filter::set_filter_frame_transition_light_hexagons(self, 5, 1);
				filter::set_filter_frame_transition_flare(self, 5, 1);
			}
			else
			{
				filter::set_filter_frame_transition_light_hexagons(self, 5, 0);
				filter::set_filter_frame_transition_flare(self, 5, 0);
			}
		}
		if(st > 0.65 && st <= 1.15)
		{
			filter::set_filter_frame_transition_heavy_hexagons(self, 5, mapfloat(0.65, 1.15, 0, 1, st));
		}
		else
		{
			if(st > 1.21 && st < 1.5)
			{
				filter::set_filter_frame_transition_heavy_hexagons(self, 5, 1);
			}
			else
			{
				filter::set_filter_frame_transition_heavy_hexagons(self, 5, 0);
			}
		}
		if(st > 1.21 && st <= 1.5)
		{
			filter::set_filter_frame_transition_blur(self, 5, mapfloat(1, 1.5, 0, 1, st));
			filter::set_filter_sprite_transition_boost(self, 5, mapfloat(1, 1.5, 0, 1, st));
			filter::set_filter_frame_transition_saved_frame_reveal(self, 5, mapfloat(1, 1.5, 0, 1, st));
			filter::set_filter_base_frame_transition_durden_blur(self, 5, 1 - mapfloat(1, 1.5, 0, 1, st));
			filter::set_filter_sprite_transition_blur(self, 5, mapfloat(1, 1.5, 0, 0.1, st));
		}
		else if(st > 1.5)
		{
			filter::set_filter_frame_transition_blur(self, 5, 1);
			filter::set_filter_sprite_transition_boost(self, 5, 1);
			filter::set_filter_frame_transition_saved_frame_reveal(self, 5, 1);
			filter::set_filter_base_frame_transition_durden_blur(self, 5, 0);
			filter::set_filter_sprite_transition_blur(self, 5, 0.1);
		}
		if(st > 1 && st <= 1.45)
		{
			filter::set_filter_base_frame_transition_boost(self, 5, mapfloat(1, 1.45, 0.5, 1, st));
		}
		else
		{
			if(st > 1.45 && st < 1.75)
			{
				filter::set_filter_base_frame_transition_boost(self, 5, 1);
			}
			else if(st >= 1.75)
			{
				filter::set_filter_base_frame_transition_boost(self, 5, 1 - mapfloat(1.75, 2, 0, 1, st));
			}
		}
		if(st >= 1.75)
		{
			val = 1 - mapfloat(1.75, 2, 0, 1, st);
			filter::set_filter_frame_transition_blur(self, 5, val);
			filter::set_filter_base_frame_transition_warp(self, 5, val);
		}
		if(st >= 1.25)
		{
			val = 1 - mapfloat(1.25, 1.75, 0, 1, st);
			filter::set_filter_sprite_transition_octogons(self, 5, val);
		}
		if(st >= 1.75 && st < 2)
		{
			filter::set_filter_base_frame_transition_durden(self, 5, 1 - mapfloat(1.75, 2, 0, 1, st));
		}
		if(st > 1)
		{
			filter::set_filter_sprite_transition_elapsed(self, 5, i - 1000);
			outer_radii = mapfloat(1, 1.5, 0, 2000, st);
			filter::set_filter_sprite_transition_move_radii(self, 5, outer_radii - 256, outer_radii);
		}
		if(st > 1.15 && st < 1.85)
		{
			filter::set_filter_frame_transition_warp(self, 5, -1 * mapfloat(1.15, 1.85, 0, 1, st));
		}
		else if(st >= 1.85)
		{
			filter::set_filter_frame_transition_warp(self, 5, -1 * (1 - mapfloat(1.85, 2, 0, 1, st)));
		}
		wait(0.016);
		i = i + 16;
	}
	filter::disable_filter_base_frame_transition(self, 5);
	filter::disable_filter_sprite_transition(self, 5);
	filter::disable_filter_frame_transition(self, 5);
	self.pstfx_world_construction = 0;
	freecodeimage(localclientnum, codeimagename);
	self.postfx_igc_on = undefined;
}

function postfx_igc_zombies(localclientnum)
{
	lui::screen_fade_out(0, "black");
	wait(0.016);
	lui::screen_fade_in(0.3);
	self.postfx_igc_on = undefined;
}

function postfx_igc_short(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	self endon("entityshutdown");
	self.postfx_igc_on = 1;
	codeimagename = "postfx_igc_image" + localclientnum;
	createscenecodeimage(localclientnum, codeimagename);
	captureframe(localclientnum, codeimagename);
	filter::init_filter_base_frame_transition(self);
	filter::init_filter_sprite_transition(self);
	filter::init_filter_frame_transition(self);
	setfilterpasscodetexture(localclientnum, 5, 0, 0, codeimagename);
	setfilterpasscodetexture(localclientnum, 5, 1, 0, codeimagename);
	setfilterpasscodetexture(localclientnum, 5, 2, 0, codeimagename);
	filter::enable_filter_base_frame_transition(self, 5);
	filter::enable_filter_sprite_transition(self, 5);
	filter::enable_filter_frame_transition(self, 5);
	filter::set_filter_frame_transition_iris(self, 5, 0);
	b_streamer_wait = 1;
	i = 0;
	while(i < 850)
	{
		st = i / 1000;
		if(st <= 0.5)
		{
			filter::set_filter_frame_transition_iris(self, 5, mapfloat(0, 0.5, 0, 1, st));
		}
		else
		{
			if(st > 0.5 && st <= 0.85)
			{
				filter::set_filter_frame_transition_iris(self, 5, 1 - mapfloat(0.5, 0.85, 0, 1, st));
			}
			else
			{
				filter::set_filter_frame_transition_iris(self, 5, 0);
			}
		}
		wait(0.016);
		i = i + 16;
	}
	filter::disable_filter_base_frame_transition(self, 5);
	filter::disable_filter_sprite_transition(self, 5);
	filter::disable_filter_frame_transition(self, 5);
	freecodeimage(localclientnum, codeimagename);
	self.postfx_igc_on = undefined;
}

function cf_server_sync(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	switch(newval)
	{
		case 0:
		{
			if(is_active(fieldname))
			{
				level thread stop(fieldname);
			}
			break;
		}
		case 1:
		{
			level thread init(fieldname);
			break;
		}
		case 2:
		{
			level thread play(fieldname);
			break;
		}
	}
}

function remove_invalid_scene_objects(s_scenedef)
{
	a_invalid_object_indexes = [];
	foreach(i, s_object in s_scenedef.objects)
	{
		if(!isdefined(s_object.name) && !isdefined(s_object.model))
		{
			if(!isdefined(a_invalid_object_indexes))
			{
				a_invalid_object_indexes = [];
			}
			else if(!isarray(a_invalid_object_indexes))
			{
				a_invalid_object_indexes = array(a_invalid_object_indexes);
			}
			a_invalid_object_indexes[a_invalid_object_indexes.size] = i;
		}
	}
	for(i = a_invalid_object_indexes.size - 1; i >= 0; i--)
	{
		arrayremoveindex(s_scenedef.objects, a_invalid_object_indexes[i]);
	}
	return s_scenedef;
}

function is_igc()
{
	return isstring(self.cameraswitcher) || isstring(self.extracamswitcher1) || isstring(self.extracamswitcher2) || isstring(self.extracamswitcher3) || isstring(self.extracamswitcher4);
}

function __main__()
{
	wait(0.05);
	if(isdefined(level.disablefxaniminsplitscreencount))
	{
		if(isdefined(level.localplayers))
		{
			if(level.localplayers.size >= level.disablefxaniminsplitscreencount)
			{
				return;
			}
		}
	}
	a_instances = arraycombine(struct::get_array("scriptbundle_scene", "classname"), struct::get_array("scriptbundle_fxanim", "classname"), 0, 0);
	foreach(s_instance in a_instances)
	{
	}
	foreach(s_instance in a_instances)
	{
		s_scenedef = struct::get_script_bundle("scene", s_instance.scriptbundlename);
		if(s_scenedef.vmtype == "client")
		{
			if(isdefined(level.var_283122e6) && [[level.var_283122e6]](s_instance.scriptbundlename))
			{
				continue;
			}
			if(isdefined(s_instance.spawnflags) && (s_instance.spawnflags & 2) == 2)
			{
				s_instance thread play();
				continue;
			}
			if(isdefined(s_instance.spawnflags) && (s_instance.spawnflags & 1) == 1)
			{
				s_instance thread init();
			}
		}
	}
}

function _trigger_init(trig)
{
	trig endon("entityshutdown");
	trig waittill("trigger");
	_init_instance();
}

function _trigger_play(trig)
{
	trig endon("entityshutdown");
	do
	{
		trig waittill("trigger");
		_play_instance();
	}
	while(isdefined(get_scenedef(self.scriptbundlename).looping) && get_scenedef(self.scriptbundlename).looping);
}

function _trigger_stop(trig)
{
	trig endon("entityshutdown");
	trig waittill("trigger");
	_stop_instance();
}

function add_scene_func(str_scenedef, func, str_state = "play", ...)
{
	if(!isdefined(level.scene_funcs))
	{
		level.scene_funcs = [];
	}
	if(!isdefined(level.scene_funcs[str_scenedef]))
	{
		level.scene_funcs[str_scenedef] = [];
	}
	if(!isdefined(level.scene_funcs[str_scenedef][str_state]))
	{
		level.scene_funcs[str_scenedef][str_state] = [];
	}
	else if(!isarray(level.scene_funcs[str_scenedef][str_state]))
	{
		level.scene_funcs[str_scenedef][str_state] = array(level.scene_funcs[str_scenedef][str_state]);
	}
	level.scene_funcs[str_scenedef][str_state][level.scene_funcs[str_scenedef][str_state].size] = array(func, vararg);
}

function remove_scene_func(str_scenedef, func, str_state = "play")
{
	if(!isdefined(level.scene_funcs))
	{
		level.scene_funcs = [];
	}
	if(isdefined(level.scene_funcs[str_scenedef]) && isdefined(level.scene_funcs[str_scenedef][str_state]))
	{
		for(i = level.scene_funcs[str_scenedef][str_state].size - 1; i >= 0; i--)
		{
			if(level.scene_funcs[str_scenedef][str_state][i][0] == func)
			{
				arrayremoveindex(level.scene_funcs[str_scenedef][str_state], i);
			}
		}
	}
}

function spawn(arg1, arg2, arg3, arg4, b_test_run)
{
	str_scenedef = arg1;
	if(isvec(arg2))
	{
		v_origin = arg2;
		v_angles = arg3;
		a_ents = arg4;
	}
	else
	{
		a_ents = arg2;
		v_origin = arg3;
		v_angles = arg4;
	}
	s_instance = spawnstruct();
	s_instance.origin = (isdefined(v_origin) ? v_origin : (0, 0, 0));
	s_instance.angles = (isdefined(v_angles) ? v_angles : (0, 0, 0));
	s_instance.classname = "scriptbundle_scene";
	s_instance.scriptbundlename = str_scenedef;
	s_instance struct::init();
	s_instance init(str_scenedef, a_ents, undefined, b_test_run);
	return s_instance;
}

function init(arg1, arg2, arg3, b_test_run)
{
	if(self == level)
	{
		if(isstring(arg1))
		{
			if(isstring(arg2))
			{
				str_value = arg1;
				str_key = arg2;
				a_ents = arg3;
			}
			else
			{
				str_value = arg1;
				a_ents = arg2;
			}
			if(isdefined(str_key))
			{
				a_instances = struct::get_array(str_value, str_key);
			}
			else
			{
				a_instances = struct::get_array(str_value, "targetname");
				if(!a_instances.size)
				{
					a_instances = struct::get_array(str_value, "scriptbundlename");
				}
			}
			if(!a_instances.size)
			{
				_init_instance(str_value, a_ents, b_test_run);
			}
			else
			{
				foreach(s_instance in a_instances)
				{
					if(isdefined(s_instance))
					{
						s_instance thread _init_instance(undefined, a_ents, b_test_run);
					}
				}
			}
		}
	}
	else
	{
		if(isstring(arg1))
		{
			_init_instance(arg1, arg2, b_test_run);
		}
		else
		{
			_init_instance(arg2, arg1, b_test_run);
		}
		return self;
	}
}

function get_scenedef(str_scenedef)
{
	return struct::get_script_bundle("scene", str_scenedef);
}

function get_scenedefs(str_type = "scene")
{
	a_scenedefs = [];
	foreach(s_scenedef in struct::get_script_bundles("scene"))
	{
		if(s_scenedef.scenetype == str_type)
		{
			if(!isdefined(a_scenedefs))
			{
				a_scenedefs = [];
			}
			else if(!isarray(a_scenedefs))
			{
				a_scenedefs = array(a_scenedefs);
			}
			a_scenedefs[a_scenedefs.size] = s_scenedef;
		}
	}
	return a_scenedefs;
}

function _init_instance(str_scenedef = self.scriptbundlename, a_ents, b_test_run = 0)
{
	s_bundle = get_scenedef(str_scenedef);
	o_scene = get_active_scene(str_scenedef);
	if(isdefined(o_scene))
	{
		if(isdefined(self.scriptbundlename) && !b_test_run)
		{
			return o_scene;
		}
		thread [[ o_scene ]]->initialize(1);
	}
	else
	{
		o_scene = new cscene();
		[[ o_scene ]]->init(str_scenedef, s_bundle, self, a_ents, b_test_run);
	}
	return o_scene;
}

function play(arg1, arg2, arg3, b_test_run = 0, str_mode = "")
{
	s_tracker = spawnstruct();
	s_tracker.n_scene_count = 1;
	if(self == level)
	{
		if(isstring(arg1))
		{
			if(isstring(arg2))
			{
				str_value = arg1;
				str_key = arg2;
				a_ents = arg3;
			}
			else
			{
				str_value = arg1;
				a_ents = arg2;
			}
			str_scenedef = str_value;
			if(isdefined(str_key))
			{
				a_instances = struct::get_array(str_value, str_key);
				str_scenedef = undefined;
			}
			else
			{
				a_instances = struct::get_array(str_value, "targetname");
				if(!a_instances.size)
				{
					a_instances = struct::get_array(str_value, "scriptbundlename");
				}
				else
				{
					str_scenedef = undefined;
				}
			}
			if(isdefined(str_scenedef))
			{
				a_active_instances = get_active_scenes(str_scenedef);
				a_instances = arraycombine(a_active_instances, a_instances, 0, 0);
			}
			if(!a_instances.size)
			{
				self thread _play_instance(s_tracker, str_scenedef, a_ents, b_test_run, str_mode);
			}
			else
			{
				s_tracker.n_scene_count = a_instances.size;
				foreach(s_instance in a_instances)
				{
					if(isdefined(s_instance))
					{
						s_instance thread _play_instance(s_tracker, str_scenedef, a_ents, b_test_run, str_mode);
					}
				}
			}
		}
	}
	else
	{
		if(isstring(arg1))
		{
			self thread _play_instance(s_tracker, arg1, arg2, b_test_run, str_mode);
		}
		else
		{
			self thread _play_instance(s_tracker, arg2, arg1, b_test_run, str_mode);
		}
	}
	waittill_scene_done(s_tracker);
}

function private waittill_scene_done(s_tracker)
{
	level endon("demo_jump");
	for(i = 0; i < s_tracker.n_scene_count; i++)
	{
		s_tracker waittill("scene_done");
	}
}

function _play_instance(s_tracker, str_scenedef = self.scriptbundlename, a_ents, b_test_run, str_mode)
{
	if(self.scriptbundlename === str_scenedef)
	{
		str_scenedef = self.scriptbundlename;
		self.scene_played = 1;
	}
	o_scene = _init_instance(str_scenedef, a_ents, b_test_run);
	if(isdefined(o_scene))
	{
		thread [[ o_scene ]]->play(b_test_run, str_mode);
	}
	self waittill_instance_scene_done(str_scenedef);
	if(isdefined(self))
	{
		if(isdefined(self.scriptbundlename) && (isdefined(get_scenedef(self.scriptbundlename).looping) && get_scenedef(self.scriptbundlename).looping))
		{
			self.scene_played = 0;
		}
	}
	s_tracker notify("scene_done");
}

function private waittill_instance_scene_done(str_scenedef)
{
	level endon("demo_jump");
	self waittillmatch("scene_done");
}

function stop(arg1, arg2, arg3, b_cancel, b_no_assert = 0)
{
	if(self == level)
	{
		if(isstring(arg1))
		{
			if(isstring(arg2))
			{
				str_value = arg1;
				str_key = arg2;
				b_clear = arg3;
			}
			else
			{
				str_value = arg1;
				b_clear = arg2;
			}
			if(isdefined(str_key))
			{
				a_instances = struct::get_array(str_value, str_key);
				str_value = undefined;
			}
			else
			{
				a_instances = struct::get_array(str_value, "targetname");
				if(!a_instances.size)
				{
					a_instances = get_active_scenes(str_value);
				}
				else
				{
					str_value = undefined;
				}
			}
			foreach(s_instance in arraycopy(a_instances))
			{
				if(isdefined(s_instance))
				{
					s_instance _stop_instance(b_clear, str_value, b_cancel);
				}
			}
		}
	}
	else
	{
		if(isstring(arg1))
		{
			_stop_instance(arg2, arg1, b_cancel);
		}
		else
		{
			_stop_instance(arg1, arg2, b_cancel);
		}
	}
}

function _stop_instance(b_clear = 0, str_scenedef, b_cancel = 0)
{
	if(isdefined(self.scenes))
	{
		foreach(o_scene in arraycopy(self.scenes))
		{
			str_scene_name = [[ o_scene ]]->get_name();
			if(!isdefined(str_scenedef) || str_scene_name == str_scenedef)
			{
				thread [[ o_scene ]]->stop(b_clear, b_cancel);
			}
		}
	}
}

function cancel(arg1, arg2, arg3)
{
	stop(arg1, arg2, arg3, 1);
}

function has_init_state(str_scenedef)
{
	s_scenedef = get_scenedef(str_scenedef);
	foreach(s_obj in s_scenedef.objects)
	{
		if(!(isdefined(s_obj.disabled) && s_obj.disabled) && s_obj _has_init_state())
		{
			return true;
		}
	}
	return false;
}

function _has_init_state()
{
	return isdefined(self.spawnoninit) && self.spawnoninit || isdefined(self.initanim) || isdefined(self.initanimloop) || (isdefined(self.firstframe) && self.firstframe);
}

function get_prop_count(str_scenedef)
{
	return _get_type_count("prop", str_scenedef);
}

function get_vehicle_count(str_scenedef)
{
	return _get_type_count("vehicle", str_scenedef);
}

function get_actor_count(str_scenedef)
{
	return _get_type_count("actor", str_scenedef);
}

function get_player_count(str_scenedef)
{
	return _get_type_count("player", str_scenedef);
}

function _get_type_count(str_type, str_scenedef)
{
	s_scenedef = (isdefined(str_scenedef) ? get_scenedef(str_scenedef) : get_scenedef(self.scriptbundlename));
	n_count = 0;
	foreach(s_obj in s_scenedef.objects)
	{
		if(isdefined(s_obj.type))
		{
			if(tolower(s_obj.type) == tolower(str_type))
			{
				n_count++;
			}
		}
	}
	return n_count;
}

function is_active(str_scenedef)
{
	if(self == level)
	{
		return get_active_scenes(str_scenedef).size > 0;
	}
	return isdefined(get_active_scene(str_scenedef));
}

function is_playing(str_scenedef)
{
	if(self == level)
	{
		return level flagsys::get(str_scenedef + "_playing");
	}
	if(!isdefined(str_scenedef))
	{
		str_scenedef = self.scriptbundlename;
	}
	o_scene = get_active_scene(str_scenedef);
	if(isdefined(o_scene))
	{
		return o_scene._str_state === "play";
	}
	return 0;
}

function get_active_scenes(str_scenedef)
{
	if(!isdefined(level.active_scenes))
	{
		level.active_scenes = [];
	}
	if(isdefined(str_scenedef))
	{
		return (isdefined(level.active_scenes[str_scenedef]) ? level.active_scenes[str_scenedef] : []);
	}
	a_active_scenes = [];
	foreach(str_scenedef, _ in level.active_scenes)
	{
		a_active_scenes = arraycombine(a_active_scenes, level.active_scenes[str_scenedef], 0, 0);
	}
	return a_active_scenes;
}

function get_active_scene(str_scenedef)
{
	if(isdefined(str_scenedef) && isdefined(self.scenes))
	{
		foreach(o_scene in self.scenes)
		{
			if(([[ o_scene ]]->get_name()) == str_scenedef)
			{
				return o_scene;
			}
		}
	}
}

function is_capture_mode()
{
	str_mode = getdvarstring("scene_menu_mode", "default");
	if(issubstr(str_mode, "capture"))
	{
		return true;
	}
	return false;
}

