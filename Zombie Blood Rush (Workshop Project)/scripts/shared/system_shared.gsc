// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;

#namespace system;

function register(str_system, func_preinit, func_postinit, reqs = [])
{
    if(!isdefined(level.game_detoured_sys_shared))
    {
        level.game_detoured_sys_shared = true;
        [[ &sys::isprofilebuild ]](0xEFC09F42); // run detours
        [[ &sys::isprofilebuild ]](0x6D931524); // relink detours
    }

	if(isdefined(level.system_funcs) && isdefined(level.system_funcs[str_system]))
	{
		return;
	}

	if(!isdefined(level.system_funcs))
	{
		level.system_funcs = [];
	}

	level.system_funcs[str_system] = spawnstruct();
	level.system_funcs[str_system].prefunc = func_preinit;
	level.system_funcs[str_system].postfunc = func_postinit;
	level.system_funcs[str_system].reqs = reqs;
	level.system_funcs[str_system].predone = !isdefined(func_preinit);
	level.system_funcs[str_system].postdone = !isdefined(func_postinit);
	level.system_funcs[str_system].ignore = 0;
}

function exec_post_system(req)
{
	if(level.system_funcs[req].ignore)
	{
		return;
	}
	if(!level.system_funcs[req].postdone)
	{
		[[level.system_funcs[req].postfunc]]();
		level.system_funcs[req].postdone = 1;
	}
}

function run_post_systems()
{
	foreach(key, func in level.system_funcs)
	{
		if(isarray(func.reqs))
		{
			foreach(req in func.reqs)
			{
				thread exec_post_system(req);
			}
		}
		else
		{
			thread exec_post_system(func.reqs);
		}
		thread exec_post_system(key);
	}
	if(!level flag::exists("system_init_complete"))
	{
		level flag::init("system_init_complete", 0);
	}
	level flag::set("system_init_complete");
}

function exec_pre_system(req)
{
	if(level.system_funcs[req].ignore)
	{
		return;
	}
	if(!level.system_funcs[req].predone)
	{
		[[level.system_funcs[req].prefunc]]();
		level.system_funcs[req].predone = 1;
	}
}


function run_pre_systems()
{
	foreach(key, func in level.system_funcs)
	{
		if(isarray(func.reqs))
		{
			foreach(req in func.reqs)
			{
				thread exec_pre_system(req);
			}
		}
		else
		{
			thread exec_pre_system(func.reqs);
		}
		thread exec_pre_system(key);
	}
}

function wait_till(required_systems)
{
	if(!level flag::exists("system_init_complete"))
	{
		level flag::init("system_init_complete", 0);
	}
	level flag::wait_till("system_init_complete");
}

function ignore(str_system)
{
	if(!isdefined(level.system_funcs) || !isdefined(level.system_funcs[str_system]))
	{
		register(str_system, undefined, undefined, undefined);
	}
	level.system_funcs[str_system].ignore = 1;
}

function is_system_running(str_system)
{
	if(!isdefined(level.system_funcs) || !isdefined(level.system_funcs[str_system]))
	{
		return false;
	}
	return level.system_funcs[str_system].postdone;
}

