#using scripts\shared\util_shared;

#namespace flag;

function init(str_flag, b_val = 0, b_is_trigger = 0)
{
	if(!isdefined(self.flag))
	{
		self.flag = [];
	}
	self.flag[str_flag] = b_val;
}

function exists(str_flag)
{
	return isdefined(self.flag) && isdefined(self.flag[str_flag]);
}

function set(str_flag)
{
	self.flag[str_flag] = 1;
	self notify(str_flag);
}

function delay_set(n_delay, str_flag, str_cancel)
{
	self thread _delay_set(n_delay, str_flag, str_cancel);
}

function _delay_set(n_delay, str_flag, str_cancel)
{
	if(isdefined(str_cancel))
	{
		self endon(str_cancel);
	}
	self endon("death");
	wait(n_delay);
	set(str_flag);
}

function set_for_time(n_time, str_flag)
{
	self notify("__flag::set_for_time__" + str_flag);
	self endon("__flag::set_for_time__" + str_flag);
	set(str_flag);
	wait(n_time);
	clear(str_flag);
}

function clear(str_flag)
{
	if(self.flag[str_flag])
	{
		self.flag[str_flag] = 0;
		self notify(str_flag);
	}
}

function toggle(str_flag)
{
	if(get(str_flag))
	{
		clear(str_flag);
	}
	else
	{
		set(str_flag);
	}
}

function get(str_flag)
{
    if(!isdefined(self.flag) || !isdefined(self.flag[str_flag]))
    {
        init(str_flag);
    }
	return self.flag[str_flag];
}

function wait_till(str_flag)
{
	self endon("death");
	while(!get(str_flag))
	{
		self waittill(str_flag);
	}
}

function wait_till_timeout(n_timeout, str_flag)
{
	if(isdefined(n_timeout))
	{
		__s = spawnstruct();
		__s endon("timeout");
		__s util::delay_notify(n_timeout, "timeout");
	}
	wait_till(str_flag);
}

function wait_till_all(a_flags)
{
	self endon("death");
	for(i = 0; i < a_flags.size; i++)
	{
		str_flag = a_flags[i];
		if(!get(str_flag))
		{
			self waittill(str_flag);
			i = -1;
		}
	}
}

function wait_till_all_timeout(n_timeout, a_flags)
{
	if(isdefined(n_timeout))
	{
		__s = spawnstruct();
		__s endon("timeout");
		__s util::delay_notify(n_timeout, "timeout");
	}
	wait_till_all(a_flags);
}

function wait_till_any(a_flags)
{
	self endon("death");
	foreach(flag in a_flags)
	{
		if(get(flag))
		{
			return flag;
		}
	}
	util::waittill_any_array(a_flags);
}

function wait_till_any_timeout(n_timeout, a_flags)
{
	if(isdefined(n_timeout))
	{
		__s = spawnstruct();
		__s endon("timeout");
		__s util::delay_notify(n_timeout, "timeout");
	}
	wait_till_any(a_flags);
}

function wait_till_clear(str_flag)
{
	self endon("death");
	while(get(str_flag))
	{
		self waittill(str_flag);
	}
}

function wait_till_clear_timeout(n_timeout, str_flag)
{
	if(isdefined(n_timeout))
	{
		__s = spawnstruct();
		__s endon("timeout");
		__s util::delay_notify(n_timeout, "timeout");
	}
	wait_till_clear(str_flag);
}

function wait_till_clear_all(a_flags)
{
	self endon("death");
	for(i = 0; i < a_flags.size; i++)
	{
		str_flag = a_flags[i];
		if(get(str_flag))
		{
			self waittill(str_flag);
			i = -1;
		}
	}
}

function wait_till_clear_all_timeout(n_timeout, a_flags)
{
	if(isdefined(n_timeout))
	{
		__s = spawnstruct();
		__s endon("timeout");
		__s util::delay_notify(n_timeout, "timeout");
	}
	wait_till_clear_all(a_flags);
}

function wait_till_clear_any(a_flags)
{
	self endon("death");
	while(true)
	{
		foreach(flag in a_flags)
		{
			if(!get(flag))
			{
				return flag;
			}
		}
		util::waittill_any_array(a_flags);
	}
}

function wait_till_clear_any_timeout(n_timeout, a_flags)
{
	if(isdefined(n_timeout))
	{
		__s = spawnstruct();
		__s endon("timeout");
		__s util::delay_notify(n_timeout, "timeout");
	}
	wait_till_clear_any(a_flags);
}

function delete(str_flag)
{
    if(!isdefined(self.flag))
    {
        return;
    }
	if(isdefined(self.flag[str_flag]))
	{
		self.flag[str_flag] = undefined;
	}
}

