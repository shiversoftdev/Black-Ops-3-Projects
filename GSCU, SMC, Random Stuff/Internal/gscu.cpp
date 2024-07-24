#include "gscu.h"
#include "GSCUOps.h"
#include "GSCUBuiltins.h"
#include <ctype.h>

#if (GSCU_BRANCH == GSCU_BRANCH_DEBUG)
#define GSCU_LNKERROR(error_code, message, ...) sprintf_s(last_link_error, message, __VA_ARGS__); return error_code;
#else
#define GSCU_LNKERROR(error_code, message, ...) sprintf_s(last_link_error, "%X", error_code); return error_code;
#endif

#if (GSCU_BRANCH == GSCU_BRANCH_DEBUG)
#define GSCU_RTERROR(error_code, isFatal, message, ...) sprintf_s(last_runtime_error, message, __VA_ARGS__); last_error_code = error_code; if(isFatal) global()->quit(); return error_code;
#define GSCU_IAPI_RTERROR(vm, error_code, isFatal, message, ...) sprintf_s(vm->last_runtime_error, message, __VA_ARGS__); vm->last_error_code = error_code; if(isFatal) vm->global()->quit(); return error_code;
#else
#define GSCU_RTERROR(error_code, isFatal, message, ...) sprintf_s(last_runtime_error, "%X", error_code); last_error_code = error_code; if(isFatal) global()->quit(); return error_code;
#define GSCU_IAPI_RTERROR(vm, error_code, isFatal, message, ...) sprintf_s(vm->last_runtime_error, "%X", error_code); vm->last_error_code = error_code; if(isFatal) vm->global()->quit(); return error_code;
#endif

#if (GSCU_BRANCH == GSCU_BRANCH_DEBUG)
#define GSCU_RTWARNING(error_code, isFatal, message, ...) sprintf_s(last_runtime_error, message, __VA_ARGS__); last_error_code = error_code; if(isFatal) global()->quit();
#else
#define GSCU_RTWARNING(error_code, isFatal, message, ...) sprintf_s(last_runtime_error, "%X", error_code); last_error_code = error_code; if(isFatal) global()->quit();
#endif

// TODO: string array indexing
// TODO: stack overflow
GContext::GContext(GContext* super)
{
	assert(sizeof(std::vector<unsigned __int32>::iterator) <= 0x10);
	assert(sizeof(std::unordered_map<unsigned __int32, unsigned __int32>::iterator) <= 0x10);

	memset(last_link_error, 0, sizeof(last_link_error));
	memset(last_runtime_error, 0, sizeof(last_runtime_error));
	memset(&suspend_context, 0, sizeof(suspend_context));
	last_error_code = 0;
	has_exited = false;
	is_suspended = false;

	vm_time = 0;
	ftime(&vm_last_tick);

	vm_ms_tick = VM_DEFAULT_TICK_RATE;

	if (super)
	{
		// find the highest context available and make it our global context
		while (super->global() != super)
		{
			super = super->global();
		}
		__global = super;
	}
	else
	{
		__global = this;
		for (unsigned int i = 0; i < GSCU_MAX_GLOBALS; i++)
		{
			globals[i].type = GSCUVAR_STRUCT;
			globals[i].id = i;
			globals[i].name = 0;
			globals[i].parent = 0;
			globals[i].value.s.classname = scr_const::global;
			globals[i].value.s.reserved = 0;
			globals[i].value.s.native.s = new std::unordered_map<unsigned __int32, unsigned __int32>();
			variables[i] = &globals[i];
		}

		current_variable_id = GSCU_MAX_GLOBALS;
		vm = alloc_global(scr_const::vm);
		_globals = alloc_global(scr_const::globals);

		main_thread = threads[create_thread(0, false, vm, 0)];
		main_thread->set_flag(GSCUTF_MAIN_THREAD); // wont be executed and is simply there for special usage by the vm

		// populate the default opcodes into this vm
		GSCUOpcodes::default_opcodes(opcodes);

		// populate the default builtins into this vm
		GSCUBuiltins::register_default_builtins(this);
	}
}

// immutable public accessor
GContext* GContext::global()
{
	return __global;
}

// link the input object and all of its required subsequent object
__int32 GContext::link(GSCObj* obj)
{
	assert(obj != NULL);
	if (!obj)
	{
		return GSCU_ERROR_GLINK_NULLBUFFER;
	}

	GSCObj* glob_buff = NULL;
	int result = 0;

	result = load(obj, glob_buff);
	obj = glob_buff; // prevent any programming errors from here

	GSCU_REQUIRE_SUCCESS(result);

	if (glob_buff->has_flag(GSCOF_BAD))
	{
		GSCU_LNKERROR(GSCU_ERROR_GLINK_MISSINGSCRIPT, "Error linking script '%016llX': unable to link included script because it was marked bad", glob_buff->name());
	}

	if (glob_buff->has_flag(GSCOF_LINKING))
	{
		return GSCU_SUCCESS; // object was already linked or is being linked
	}

	glob_buff->set_flag(GSCOF_LINKING);

	LDPRINT("LNK: Begin link for object '%016llX' @ %p", glob_buff->name(), glob_buff);
	LDPRINT("LNK:['%016llX']: %d includes found.", glob_buff->name(), glob_buff->num_includes());

	// link all includes first
	GSCInclude* current_include = glob_buff->includes();

	for (unsigned int i = 0; i < glob_buff->num_includes(); i++, current_include++)
	{
		if (!(current_include->name & ((unsigned __int64)1 << 63)))
		{
			auto script = scripts.find(current_include->name);

			if (script == scripts.end())
			{
				glob_buff->set_flag(GSCOF_BAD);
				GSCU_LNKERROR(GSCU_ERROR_GLINK_MISSINGSCRIPT, "Error linking script '%016llX': unable to locate included script %016llX", glob_buff->name(), current_include->name);
			}

			if (script->second == obj)
			{
				continue; // prevent stack overflow
			}

			result = link(script->second);
			
			if (result)
			{
				glob_buff->clear_flag(GSCOF_LINKING); // dont want this script marked as being linked because it failed, but the script is not detected as 'bad' yet.
				return result;
			}
		}
		else
		{
			// its an api, look for it
			if (known_apis.find((__int32)current_include->name) == known_apis.end())
			{
				glob_buff->set_flag(GSCOF_BAD);
				GSCU_LNKERROR(GSCU_ERROR_GLINK_MISSINGAPI, "Error linking script '%016llX': unable to locate imported api %X", glob_buff->name(), (__int32)current_include->name);
			}
		}
	}

	LDPRINT("LNK:['%016llX']: Linked includes.", glob_buff->name());
	LDPRINT("LNK:['%016llX']: %d imports found.", glob_buff->name(), glob_buff->num_imports());

	// link all imports
	GSCImport* current_import = glob_buff->imports();
	GSCExport _export{};
	GSCUBuiltinInfo _builtin{};
	GSCObj* parent_script = NULL;
	for (unsigned int i = 0; i < glob_buff->num_imports(); i++)
	{
		if (find_builtin_function(glob_buff, current_import, _builtin))
		{
			LDPRINT("LNK:['%016llX']: %X::%X -> %p N", glob_buff->name(), current_import->space, current_import->name, _builtin.func);
			unsigned __int16 opcode = GSCUOpcodes::calc_import_code(current_import->has_flag(GSCUIF_METHOD), current_import->has_flag(GSCUIF_REF), current_import->has_flag(GSCUIF_THREADED), true);
			for (int j = 0; j < current_import->num_references; j++)
			{
				current_import->apply_fixup(glob_buff, j, (unsigned char*)_builtin.func, opcode);
			}
		}
		else if (find_script_function(glob_buff, current_import, _export, parent_script))
		{
			LDPRINT("LNK:['%016llX']: %X::%X -> %p S", glob_buff->name(), current_import->space, current_import->name, _export.get_bytecode(parent_script));
			unsigned __int16 opcode = GSCUOpcodes::calc_import_code(current_import->has_flag(GSCUIF_METHOD), current_import->has_flag(GSCUIF_REF), current_import->has_flag(GSCUIF_THREADED), false);
			for (int j = 0; j < current_import->num_references; j++)
			{
				current_import->apply_fixup(glob_buff, j, _export.get_bytecode(parent_script), opcode);
			}
		}
		else
		{
			glob_buff->set_flag(GSCOF_BAD);
			GSCU_LNKERROR(GSCU_ERROR_GLINK_MISSINGSCRIPT, "Error linking script '%016llX': unable to locate import %X::%X", glob_buff->name(), current_import->space, current_import->name);
		}

		current_import = (GSCImport*)((__int64)current_import + sizeof(GSCImport) + (sizeof(__int32) * current_import->num_references));
	}

	LDPRINT("LNK:['%016llX']: Linked imports.", glob_buff->name());
	LDPRINT("LNK:['%016llX']: %d globals found.", glob_buff->name(), glob_buff->num_globals());

	GSCGlobal* current_global = glob_buff->globals();
	for (unsigned int i = 0; i < glob_buff->num_globals(); i++)
	{
		int glob = alloc_global(current_global->name);
		GSCUHeapVariable* target_global = &globals[glob];

		if (glob < 0)
		{
			GSCU_LNKERROR(GSCU_ERROR_GLINK_OUTOFGLOBALS, "Error linking script '%016llX': ran out of globals while trying to link the script", glob_buff->name());
		}

		for (unsigned int j = 0; j < current_global->num_references; j++)
		{
			current_global->apply_fixup(glob_buff, j, target_global->id);
		}
	}

	LDPRINT("LNK:['%016llX']: Linked globals.", glob_buff->name());

	GSCExport* current_export = glob_buff->exports();
	for (unsigned int i = 0; i < glob_buff->num_exports(); i++, current_export++)
	{
		if (!current_export->has_flag(GSCEF_AUTOEXEC))
		{
			continue;
		}

		LDPRINT("LNK:['%016llX']: Autoexec %X starting...", glob_buff->name(), current_export->name);

		auto thread_id = create_thread(current_export->get_bytecode(glob_buff), true, _globals, 0);

		LDPRINT("LNK:['%016llX']:[%X]: Thread ID: %d", glob_buff->name(), current_export->name, thread_id);

		if (thread_id < 0)
		{
			GSCU_LNKERROR(thread_id, "Error linking script '%016llX': autoexec function thread could not be created (%X::%X)", glob_buff->name(), current_export->space, current_export->name);
		}

		result = vm_execute(thread_id);

		LDPRINT("LNK:['%016llX']:[%X]: vm_execute result: %d", glob_buff->name(), current_export->name, result);
		
		if (result)
		{
			GSCU_LNKERROR(result, "Error linking script '%016llX': autoexec function failed to execute (%X::%X)", glob_buff->name(), current_export->space, current_export->name);
		}
	}

	LDPRINT("LNK:['%016llX']: Autoexec finished. Object linking complete.", glob_buff->name());

	glob_buff->set_flag(GSCOF_LINKED);
	return GSCU_SUCCESS; // linking was successful
}

// load the input object
__int32 GContext::load(GSCObj* obj, GSCObj*& out_obj)
{
	assert(obj != NULL);
	if (!obj)
	{
		return GSCU_ERROR_GLOAD_NULLBUFFER;
	}

	// check if the script is already loaded
	if (scripts.find(obj->name()) != scripts.end())
	{
		out_obj = scripts.find(obj->name())->second;
		return GSCU_SUCCESS; // loading was successful
	}

	auto size = obj->size();
	GSCObj* glob_obj = (GSCObj*)_aligned_malloc(size, 16);

	assert(glob_obj != 0);
	if (!glob_obj)
	{
		return GSCU_ERROR_GLOAD_OUTOFMEMORY;
	}

	memcpy_s(glob_obj, size, obj, size);

	scripts[glob_obj->name()] = glob_obj;
	out_obj = glob_obj;

	glob_obj->set_flag(GSCOF_LOADED);

	LDPRINT("OBJ: New object registered '%016llX'", glob_obj->name());

	return GSCU_SUCCESS; // loading was successful
}

__int32 GContext::create_thread(void* fs_pos, bool is_script_thread, unsigned __int32 parent_id, unsigned __int8 num_params)
{
	__int32 var = alloc_variable(0, parent_id);

	if (var < 0)
	{
		return var;
	}

	add_variable_ref(var);

	auto variable = variables[var];
	variable->type = GSCUVAR_THREAD;
	variable->parent = parent_id;

	GSCUThreadContext* thread = new GSCUThreadContext();
	thread->id = variable->id;
	thread->fs_pos = (__int64)fs_pos;
	thread->num_params = num_params;
	thread->start_locals = 0;

	if (!is_script_thread)
	{
		thread->set_flag(GSCUTF_NATIVE);
	}

	thread->stack.reserve(128);
	thread->stack.push_back(GSCUStackVariable());
	thread->stack.back().type = GSCUVAR_BEGINPARAMS;
	thread->stack.back().value.frame.self = 0;
	thread->stack.back().value.frame.old_num_params = 0;
	thread->stack.back().value.frame.old_start_locals = 0;

	// copy params from main thread to our thread
	stack_transfer(thread, main_thread, num_params, true);

	thread->stack.push_back(GSCUStackVariable());
	thread->stack.back().type = GSCUVAR_PRECODEPOS;
	thread->stack.back().value.int64 = 0; // nullcodepos signifies end of thread

	threads[variable->id] = thread;
	variable->value.pointer = thread;
	return variable->id;
}

__int32 GContext::thread_pop_parent(unsigned __int32 id, unsigned __int32 parent)
{
	if (variables[id]->parent == parent)
	{
		return 0;
	}

	remove_variable_ref(variables[id]->parent);
	variables[id]->parent = parent;
	return 0;
}

__int32 GContext::thread_push_parent(unsigned __int32 id, unsigned __int32 parent)
{
	if (variables[id]->parent == parent)
	{
		return 0;
	}

	add_variable_ref(parent);
	variables[id]->parent = parent;
	return 0;
}

void GContext::suspend_thread_for_time(unsigned __int32 id, unsigned __int32 wait_ms)
{
	if (threads.find(id) == threads.end())
	{
		return;
	}

	threads[id]->set_flag(GSCUTF_SUSPENDED);
	thread_time_schedule[id] = vm_time + wait_ms;
}

__int32 GContext::vm_execute(__int32 thread_id)
{
	if (has_exited)
	{
		return 0;
	}

	auto thread = threads[thread_id];
	GSCUVMContext context{};
	context.doquit = false;
	context.thread = thread;
	context.vmc = this;

	GSCUCallContext call_context{};
	call_context.thread = thread;
	call_context.doquit = false;
	call_context.vmc = this;

	VME_DPRINT("VME: Executing thread id %d", thread_id);

	if (thread->has_flag(GSCUTF_MAIN_THREAD))
	{
		// cannot execute main thread but this isnt necessarily an error
		return 0;
	}

	// in case this was previously suspended by a wait, we will unsuspend it here.
	thread->clear_flag(GSCUTF_SUSPENDED);

	thread_exec:
	last_error_code = 0;

	while (!thread->has_flag(GSCUTF_EXITED) && !thread->has_flag(GSCUTF_SUSPENDED) && !thread->exit_code)
	{
		// clear last error
		last_error_code = 0;

		// match context self
		context.self = variables[thread->id]->parent;
		call_context.self = variables[thread->id]->parent;

		// TODO track thread execution time/cycles and if crash detected quit thread
		// Additionally, profile memory for leaks. We should never let the process die due to a thread allocating tons of memory
		if (thread->has_flag(GSCUTF_NATIVE))
		{
			VME_DPRINT("VME:[%d]:[%p]:[N]:[%d]: STEP", thread_id, (void*)thread->fs_pos, (__int32)thread->stack.size());

			__int32 stack_size = (__int32)thread->stack.size();
			__int32 result = ((tGSCUBuiltinFunction)(thread->fs_pos))(call_context);

			if (has_exited)
			{
				return 0;
			}

			// thread will have set the runtime error variable so there is no need for us to do this ourselves
			if (result || context.doquit)
			{
				VME_DPRINT("VME:[%d]:[%p]:[N]:[%d]: QUIT", thread_id, (void*)thread->fs_pos, (__int32)thread->stack.size());
				thread->set_flag(GSCUTF_EXITED);
			}

			thread->clear_flag(GSCUTF_NATIVE);

			if (((__int32)thread->stack.size() - stack_size) > 0)
			{
				VME_DPRINT("VME:[%d]:[%p]:[N]:[%d]: RET", thread_id, (void*)thread->fs_pos, (__int32)thread->stack.size());
				GSCUOpcodes::vm_op_return(context);
			}
			else
			{
				VME_DPRINT("VME:[%d]:[%p]:[N]:[%d]: END", thread_id, (void*)thread->fs_pos, (__int32)thread->stack.size());
				GSCUOpcodes::vm_op_end(context);
			}
		}
		else
		{
			thread->fs_pos = GSCU_ALIGN(thread->fs_pos, 2);
			__int16 opcode = *(__int16*)thread->fs_pos;

			VME_DPRINT("VME:[%d]:[%p]:[S]:[%d]: STEP (OP %d)", thread_id, (void*)thread->fs_pos, (__int32)thread->stack.size(), opcode);

			if ((opcode >= GSCUOP_COUNT) || !opcodes[opcode])
			{
				VME_DPRINT("VME:[%d]:[%p]:[S]:[%d]: !!!INVALID OPCODE!!!", thread_id, (void*)thread->fs_pos, (__int32)thread->stack.size());
				thread->set_flag(GSCUTF_EXITED);
				thread_dispose(thread->id);
				GSCU_RTERROR(GSCU_ERROR_RUNTIME_INVALIDOPCODE, false, "Error: Invalid opcode %X at %p", opcode, (void*)thread->fs_pos);
			}

			thread->fs_pos += 2;
			__int32 result = opcodes[opcode](context);

#if defined VME_DUMP_PER_SOP
			suspend_context = context;
			VME_DUMPVM();
#endif

			if (has_exited)
			{
				VME_DPRINT("VME:[%d]:[%p]:[S]:[%d]: FATAL ERROR (1)", thread_id, (void*)thread->fs_pos, (__int32)thread->stack.size());
				return 0;
			}

			// thread will have set the runtime error variable so there is no need for us to do this ourselves
			if (result || context.doquit)
			{
				VME_DPRINT("VME:[%d]:[%p]:[S]:[%d]: THREAD FATAL ERROR (2)", thread_id, (void*)thread->fs_pos, (__int32)thread->stack.size());
				thread->set_flag(GSCUTF_EXITED);
			}
		}
	}

	if (thread->has_flag(GSCUTF_EXITED) || thread->exit_code)
	{
		thread->exit_code = last_error_code;
		if ((last_error_code || thread->has_flag(GSCUTF_RAISE_EXCEPTION)) && thread->safe_context && !has_exited)
		{
			VME_DPRINT("VME:[%d]:[%p]:[S]:[%d]: TRYING TO RECOVER...", thread_id, (void*)thread->fs_pos, (__int32)thread->stack.size());
			thread_recover(context);
			goto thread_exec;
		}

		VME_DPRINT("VME:[%d]:[%p]:[S]:[%d]: DISPOSE", thread_id, (void*)thread->fs_pos, (__int32)thread->stack.size());
		thread_dispose(thread->id);

		if (last_error_code)
		{
			DPRINT("%s", last_runtime_error);
		}
	}
	
	return 0;
}

// needs to be run every frame of your program or else the vm's async features won't work and any suspended threads will lie asleep forever
__int32 GContext::vm_tick()
{
	if (has_exited || is_suspended)
	{
		return 0;
	}

	timeb now;
	ftime(&now);
	__int32 diff = (__int32)(1000.0 * (now.time - vm_last_tick.time) + (now.millitm - vm_last_tick.millitm));
	
	if (diff >= vm_ms_tick)
	{
		vm_time += diff;
		ftime(&vm_last_tick);

		if (thread_time_schedule.size() < 1)
		{
			return 0;
		}

		std::vector<unsigned __int32> safe_keys{};
		safe_keys.reserve(thread_time_schedule.size());

		for (auto &kv : thread_time_schedule)
		{
			safe_keys.push_back(kv.first);
		}

		for(auto it = safe_keys.begin(); it != safe_keys.end(); it++)
		{
			auto thread = *it;

			if (thread_time_schedule.find(thread) == thread_time_schedule.end())
			{
				continue;
			}

			auto time_to_exec = thread_time_schedule[thread];

			if (time_to_exec > vm_time)
			{
				continue;
			}

			// erase it first so that subsequent waits function correctly
			thread_time_schedule.erase(thread);
			
			vm_execute(thread);

			if (is_suspended)
			{
				vm_time -= diff;
				return 0;
			}

			if ((thread_time_schedule.find(thread) != thread_time_schedule.end()) && (thread_time_schedule[thread] <= vm_time))
			{
				// we just executed this thread... it rescheduled for this frame. This is probably a bug and this thread is most likely misbehaving
				// to be safe, lets queue it up for the next frame instead.
				thread_time_schedule[thread] = vm_time + 1;
			}
		}

		// execute any resumed threads after the time queue
		safe_keys.clear();
		safe_keys.reserve(threads.size());

		for (auto& kv : threads)
		{
			safe_keys.push_back(kv.first);
		}

		for(auto it = safe_keys.begin(); it != safe_keys.end(); it++)
		{
			auto thread_id = *it;
			if (threads.find(thread_id) == threads.end())
			{
				continue;
			}
			if (threads[thread_id]->has_flag(GSCUTF_SUSPENDED) || threads[thread_id]->has_flag(GSCUTF_EXITED) || threads[thread_id]->has_flag(GSCUTF_MAIN_THREAD))
			{
				continue;
			}
			vm_execute(thread_id);
		}
	}

	return 0;
}

__int32 GContext::get_time()
{
	timeb now;
	ftime(&now);
	__int32 diff = (__int32)(1000.0 * (now.time - vm_last_tick.time) + (now.millitm - vm_last_tick.millitm));

	return (__int32)vm_time + diff;
}

__int32 GContext::alloc_variable(unsigned __int32 name, unsigned __int32 parent_id)
{
	if (!free_variables.size())
	{
		GSCUHeapVariable* new_variables = (GSCUHeapVariable*)malloc(BATCH_ALLOC_VARS * sizeof(GSCUHeapVariable));

		assert(new_variables);
		if (!new_variables)
		{
			GSCU_RTERROR(GSCU_ERROR_RUNTIME_OUTOFVARIABLES, true, "Error: Ran out of memory for script variables");
		}

		memset(new_variables, 0, BATCH_ALLOC_VARS * sizeof(GSCUHeapVariable));
		
		for (int i = 0; i < BATCH_ALLOC_VARS; i++)
		{
			GSCUHeapVariable* currVariable = &new_variables[i];
			currVariable->type = GSCUVAR_FREE;
			currVariable->id = current_variable_id++;
			variables[currVariable->id] = currVariable;
			free_variables.push(currVariable->id);
		}
	}

	__int32 id = free_variables.top();
	free_variables.pop();

	variables[id]->name = name ? name : id; // anonymous variables are saved by ID until they are renamed
	variables[id]->parent = parent_id;
	add_variable_ref(parent_id);
	return id;
}

GSCUHeapVariable* GContext::api_get_variable(unsigned __int32 id)
{
	if (variables.find(id) == variables.end())
	{
		GSCU_RTWARNING(GSCU_ERROR_RUNTIME_UNKNOWNVAR, false, "Variable %d either doesn't exist or has been freed.", id);
		return NULL;
	}
	return variables[id];
}

void GContext::free_variable(unsigned __int32 id)
{
	if (variables.find(id) == variables.end())
	{
		return;
	}

	auto variable = variables.find(id)->second;
	heap_dispose(variable);

	auto parent = variable->parent;
	variable->refcount = 0;
	variable->name = 0;
	variable->parent = 0;
	variable->type = GSCUVAR_FREE;
	variable->value.ai32[0] = 0;
	variable->value.ai32[1] = 0;
	variable->value.ai32[2] = 0;
	variable->value.ai32[3] = 0;
	free_variables.push(variable->id);

	// free any events tied to this object
	if (event_subscribers.find(variable->id) != event_subscribers.end())
	{
		event_subscribers.erase(variable->id);
	}

	// note: we clear this after we change the parent so that we dont hit infinite recursion with child structs
	remove_variable_ref(parent);
}

__int32 GContext::alloc_global(unsigned __int32 name)
{
	for (int i = 0; i < GSCU_MAX_GLOBALS; i++)
	{
		if (globals[i].name == name)
		{
			return i;
		}
		if (!globals[i].name)
		{
			globals[i].name = name;
			globals[i].refcount += 2; // should never get freed except on vm reset.
			return i;
		}
	}
	GSCU_RTERROR(GSCU_ERROR_RUNTIME_OUTOFGLOBALS, true, "Error: Ran out of globals for script variables");
}

void GContext::add_variable_ref(unsigned __int32 id)
{
	if (variables.find(id) == variables.end())
	{
		return;
	}

	if (id < GSCU_MAX_GLOBALS) // dont track globals
	{
		return;
	}

#if defined VME_DUMP_MEM_REFS
	DPRINT("MEM:ADDREF: %d %X %p", id, id, variables.find(id)->second);
#endif

	variables.find(id)->second->refcount++;
}

void GContext::remove_variable_ref(unsigned __int32 id)
{
	if (variables.find(id) == variables.end())
	{
		return;
	}

	if (id < GSCU_MAX_GLOBALS) // dont track globals
	{
		return;
	}

#if defined VME_DUMP_MEM_REFS
	DPRINT("MEM:DELREF: %d %X %p", id, id, variables.find(id)->second);
#endif

	auto variable = variables.find(id)->second;

	if (variable->refcount <= 0)
	{
		return; // prevents recursive freeing
	}

	variable->refcount--;

	if (!variable->refcount)
	{
#if defined VME_DUMP_MEM_REFS
		DPRINT("MEM:FREE: %d %X", id, id);
#endif
		free_variable(id);
	}
}

void GContext::thread_dispose(unsigned __int32 id)
{
	if (threads.find(id) == threads.end())
	{
		return;
	}

	// cleanup event subscribers
	auto it = event_subscribers.begin();
	while(it != event_subscribers.end())
	{
		if (it->second.find(id) != it->second.end())
		{
			it->second.erase(id);
			if (!it->second.size())
			{
				it = event_subscribers.erase(it);
				continue;
			}
		}
		it++;
	}

	// call terminate events on this thread
	auto thread = threads[id];
	thread->marked_for_death = true;
	for (auto it = thread->terminate_events.begin(); it != thread->terminate_events.end(); it++)
	{
		GSCUVMContext context{};
		context.doquit = false;
		context.self = variables[id]->parent;
		context.vmc = this;
		context.thread = thread;
		(*it)(&context);
	}
	
	// cleanup thread variables
	while (thread->stack.size())
	{
		stack_dispose(&thread->stack.back(), thread);
		thread->stack.pop_back();
	}

	// delete thread variable (theoretically)
	remove_variable_ref(id); 

	// remove thread from the time schedule
	thread_time_schedule.erase(id);

	// delete thread from the threads list
	threads.erase(id);

	delete thread;
}

void GContext::thread_terminate_subscribe(unsigned __int32 id, std::function<void(void*)> fn_event)
{
	if (threads.find(id) == threads.end())
	{
		return;
	}

	// cannot change once this is being iterated
	if (threads[id]->marked_for_death)
	{
		return;
	}

	threads[id]->terminate_events.push_back(fn_event);
}

/// <summary>
/// called by vm_execute to recover a thread at an excception handler location
/// </summary>
/// <param name="context"></param>
/// <param name="new_fs_pos"></param>
void GContext::thread_recover(GSCUVMContext& context)
{
	// capture exception info
	auto exception_loc = context.thread->fs_pos;
	auto error_code = last_error_code;
	char error_msg[sizeof(last_runtime_error)]{ 0 };

	GSCUStackVariable error_obj{};
	error_obj.type = GSCUVAR_UNDEFINED;

	if (context.thread->has_flag(GSCUTF_RAISE_EXCEPTION))
	{
		context.thread->clear_flag(GSCUTF_RAISE_EXCEPTION);

		auto code = &context.thread->stack.back();

		switch (code->type)
		{
			case GSCUVAR_INTEGER:
				error_code = code->value.int32;
				break;
			case GSCUVAR_STRING:
				error_code = atoi(code->value.str.str_ref);
				break;
			case GSCUVAR_FLOAT:
				error_code = (int)code->value.f;
				break;
			case GSCUVAR_HASH:
				error_code = (int)code->value.int64 ^ (int)(code->value.int64 >> 32);
				break;
			default:
				error_code = GSCU_ERROR;
				break;
		}

		stack_dispose(code, context.thread);
		context.thread->stack.pop_back();

		auto msg = &context.thread->stack.back();

		GSCUStackVariable str_out{};
		auto res = cast_to_string(&str_out, msg);

		if (res)
		{
			error_code = res;
		}
		else
		{
			strcpy_s(error_msg, str_out.value.str.str_ref);
			stack_dispose(&str_out, context.thread);
		}

		stack_dispose(msg, context.thread);
		context.thread->stack.pop_back();

		auto obj = &context.thread->stack.back();

		if (obj->type == GSCUVAR_REFVAR && variables.find(obj->value.int32) != variables.end() && variables[obj->value.int32]->type == GSCUVAR_STRUCT && variables[obj->value.int32]->value.s.classname != scr_const::array)
		{
			error_obj.type = obj->type;
			error_obj.value = obj->value;
			add_variable_ref(error_obj.value.int32);
		}

		stack_dispose(obj, context.thread);
		context.thread->stack.pop_back();
	}
	else
	{
		strcpy_s(error_msg, last_runtime_error);
	}
	
	// pop everything off the stack until the top is the safe context marker
	while (context.thread->stack.size() > (context.thread->safe_context + 1))
	{
		stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();
	}

	// make sure the top of the stack is actually the safe context and not below it
	if ((context.thread->stack.size() - 1) != context.thread->safe_context)
	{
		quit();
		return;
	}

	// store the var in this stack frame and pop context stack
	GSCUStackVariable frame = context.thread->stack.back();
	stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// restore previous safe context
	context.thread->safe_context = frame.value.seh.prev_safe_context;

	//  setup structured exception info
	context.thread->stack.push_back(error_obj);
	auto back = &context.thread->stack.back();
	bool b_new = false;

	if (back->type == GSCUVAR_UNDEFINED)
	{
		b_new = true;
		back->type = GSCUVAR_REFVAR;
		back->value.int32 = alloc_variable(0, 0);
		((GContext*)context.vmc)->add_variable_ref(back->value.int32);
	}
	
	// check to make sure its a valid variable
	if (back->value.int32 < 0)
	{
		quit();
		return;
	}

	// setup the struct
	auto stru_id = back->value.int32;
	auto stru = variables[stru_id];

	if (b_new)
	{
		stru->type = GSCUVAR_STRUCT;
		stru->value.s.classname = 0;
		stru->value.s.reserved = 0;
		stru->value.s.native.s = new std::unordered_map<unsigned __int32, unsigned __int32>();
	}

	GSCUStackVariable temp{};
	temp.type = GSCUVAR_STRING;

	// create a gscu string for the error message
	GSCUString str_out{};
	auto str_result = strings.alloc(strlen(error_msg), str_out);

	// catastrophic failure
	if (str_result || !str_out.str_ref)
	{
		quit();
		return;
	}

	sprintf_s(str_out.str_ref, (size_t)str_out.max_size + 1, "%s", error_msg);
	strings.update_size(&str_out);
	temp.type = GSCUVAR_STRING;
	temp.value.str = str_out;
	
	set_variable_field(stru_id, scr_const::error_message, &temp);
	strings.remove_ref(&str_out); // since temp isnt an actual stack ref we need to clear this

	// store the error code in the struct
	temp.type = GSCUVAR_INTEGER;
	temp.value.int32 = error_code;
	set_variable_field(stru_id, scr_const::error_code, &temp);

	// change fs_pos and return
	context.thread->fs_pos = frame.value.seh.base + frame.value.seh.handler;
	context.thread->clear_flag(GSCUTF_EXITED);
	context.thread->exit_code = 0;
}

void GContext::stack_dispose(GSCUStackVariable* stack_var, GSCUThreadContext* thread)
{
	switch (stack_var->type)
	{
		case GSCUVAR_BEGINPARAMS:
		{
			auto back = &thread->stack.back();
			if (back->value.int64)
			{
				thread->num_params = back->value.frame.old_num_params;
				thread->start_locals = back->value.frame.old_start_locals;
				thread_pop_parent(thread->id, back->value.frame.self);
			}
		}
		break;

		case GSCUVAR_REFVAR:
			remove_variable_ref(stack_var->value.int32);
		break;

		case GSCUVAR_WAITTILL:
		case GSCUVAR_ENDON:
			subscribe_events(stack_var->value.endon.parent_id, thread->id, -1);
		break;

		case GSCUVAR_STRING:
			strings.remove_ref(&stack_var->value.str);
		break;

		case GSCUVAR_ITERATOR2:
			remove_variable_ref(stack_var->value.it.var_id);
			if (stack_var->value.it.keys)
			{
				delete stack_var->value.it.keys;
				stack_var->value.it.keys = 0;
			}
			break;

		case GSCUVAR_FUNCTION:
			if (stack_var->value.fn.captures)
			{
				remove_variable_ref(stack_var->value.fn.captures);
			}
			break;

		case GSCUVAR_VECTOR: // doesnt need a dispose handler
		case GSCUVAR_HASH: // doesnt need a dispose handler
		case GSCUVAR_STRUCT: // should never be on the stack to begin with
		case GSCUVAR_FLOAT: // doesnt need a dispose handler
		case GSCUVAR_INTEGER: // doesnt need a dispose handler
		case GSCUVAR_UNDEFINED: // doesnt need a dispose handler
		case GSCUVAR_PRECODEPOS: // doesnt need a dispose handler
		case GSCUVAR_THREAD: // should never be on the stack to begin with
		case GSCUVAR_FREE: // should never be on the stack and stack dispose should ignore it
		case GSCUVAR_SEHFRAME:
			break;

		default:
			GSCU_RTWARNING(GSCU_ERROR_RUNTIME_TYPEESCAPEEXCEPTION, true, "Error: A type handler was not implemented for stack_dispose type %d", stack_var->type);
			break;
	}
}

/// <summary>
/// called after a free on a heap variable!
/// </summary>
/// <param name="variable"></param>
void GContext::heap_dispose(GSCUHeapVariable* variable)
{
	switch (variable->type)
	{
		case GSCUVAR_REFVAR:
			remove_variable_ref(variable->value.int32);
			break;

		case GSCUVAR_STRUCT:
			if (variable->value.s.classname == scr_const::global)
			{
				return; // never call heap_dispose on a global
			}
			if (variable->value.s.classname == scr_const::array)
			{
				if (variable->value.s.native.a)
				{
					for (auto it = variable->value.s.native.a->begin(); it != variable->value.s.native.a->end(); it++)
					{
						if (GSCU_BADVAR != *it)
						{
							remove_variable_ref(*it);
						}
					}
					delete variable->value.s.native.a;
					variable->value.s.native.i64 = NULL;
				}
			}
			else
			{
				if (variable->value.s.native.s)
				{
					for (auto it = variable->value.s.native.s->begin(); it != variable->value.s.native.s->end(); it++)
					{
						if (GSCU_BADVAR != it->second)
						{
							remove_variable_ref(it->second);
						}
					}
					delete variable->value.s.native.s;
					variable->value.s.native.i64 = NULL;
				}
			}
			// TODO need to call destructor here because we dont handle this correctly... vm_op_deconstructobject doesnt handle situations where GC is the reason the struct is destroyed (the dtor still should be called!)
			break;

		case GSCUVAR_STRING:
			strings.remove_ref(&variable->value.str);
			break;

		case GSCUVAR_FUNCTION:
			if (variable->value.fn.captures)
			{
				remove_variable_ref(variable->value.fn.captures);
			}
			break;

		case GSCUVAR_VECTOR: // doesnt need a dispose handler
		case GSCUVAR_HASH: // auto-disposed with the variable
		case GSCUVAR_FLOAT: // auto-disposed with the variable
		case GSCUVAR_INTEGER: // auto-disposed with the variable
		case GSCUVAR_UNDEFINED: // auto-disposed with the variable
		case GSCUVAR_THREAD: // we already handle this in a custom method
		case GSCUVAR_FREE: // already disposed
			break;

		case GSCUVAR_PRECODEPOS: // how did this get to the heap??
		case GSCUVAR_BEGINPARAMS: // how did this get to the heap??
		case GSCUVAR_ENDON: // uh, what?!
		case GSCUVAR_WAITTILL: // this is a super error
		default:
			GSCU_RTWARNING(GSCU_ERROR_RUNTIME_TYPEESCAPEEXCEPTION, true, "Error: A type handler was not implemented for heap_dispose type %d", variable->type);
			break;
	}
}

void GContext::stack_set(GSCUStackVariable* dest, GSCUVariableType source_type, GSCUVarValue source_value, GSCUThreadContext* thread)
{
	assert(source_type != GSCUVAR_BEGINPARAMS);
	if (source_type == GSCUVAR_BEGINPARAMS)
	{
		return;
	}

	assert(source_type != GSCUVAR_PRECODEPOS);
	if (source_type == GSCUVAR_PRECODEPOS)
	{
		return;
	}

	// make sure we clear the destination variable first
	stack_dispose(dest, thread);

	// copy the data
	dest->type = source_type;
	dest->value = source_value;

	// manage any necessary references
	switch (dest->type)
	{
		case GSCUVAR_REFVAR:
			add_variable_ref(dest->value.int32);
			break;

		case GSCUVAR_STRING:
			strings.add_ref(&dest->value.str);
			break;
		
		case GSCUVAR_ITERATOR2:
			add_variable_ref(dest->value.it.var_id);

			if (source_value.it.keys)
			{
				dest->value.it.keys = new std::vector<unsigned __int32>();
				dest->value.it.keys->reserve(source_value.it.keys->size());
				for (auto k : *source_value.it.keys)
				{
					dest->value.it.keys->push_back(k);
				}
			}

			break;

		case GSCUVAR_WAITTILL: // handled by caller
		case GSCUVAR_ENDON: // handled by caller
		case GSCUVAR_VECTOR: // handled
		case GSCUVAR_HASH: // handled
		case GSCUVAR_STRUCT: // should never be on the stack
		case GSCUVAR_FLOAT: // handled
		case GSCUVAR_INTEGER: // handled
		case GSCUVAR_UNDEFINED: // handled
		case GSCUVAR_PRECODEPOS: // should never be copied
		case GSCUVAR_BEGINPARAMS: // should never be copied
		case GSCUVAR_THREAD: // shouldnt be on the stack
		case GSCUVAR_FREE: // shouldnt be on the stack
		case GSCUVAR_FUNCTION: // handled by caller
			break;

		default:
			GSCU_RTWARNING(GSCU_ERROR_RUNTIME_TYPEESCAPEEXCEPTION, true, "Error: A type handler was not implemented for stack_set type %d", dest->type);
			break;
	}
}

void GContext::stack_transfer(GSCUThreadContext* dest_thread, GSCUThreadContext* source_thread, unsigned __int8 num_elems, bool bClearFromSource)
{
	// create placeholder variables
	for (unsigned __int8 i = 0; i < num_elems; i++)
	{
		dest_thread->stack.push_back(GSCUStackVariable());
		dest_thread->stack.back().type = GSCUVAR_UNDEFINED;
	}

	// copy values and dispose when necessary
	for (unsigned __int8 i = 0; i < num_elems; i++)
	{
		auto source = &source_thread->stack.at(source_thread->stack.size() - ((size_t)num_elems - (size_t)i));
		auto dest = &dest_thread->stack.at(dest_thread->stack.size() - ((size_t)num_elems - (size_t)i));
		stack_set(dest, source->type, source->value, dest_thread);

		if (bClearFromSource)
		{
			stack_dispose(source, source_thread);
		}
	}

	if (bClearFromSource)
	{
		for (unsigned __int8 i = 0; i < num_elems; i++)
		{
			source_thread->stack.pop_back();
		}
	}
}

GSCUThreadContext* GContext::get_main_thread()
{
	return main_thread;
}

/// <summary>
///  copies a heap variable to the stack and automatically applies any reference updates as necessary
/// </summary>
/// <param name="dest"></param>
/// <param name="source"></param>
void GContext::heap_to_stack(GSCUStackVariable* dest, GSCUHeapVariable* source)
{
	switch (source->type)
	{
		case GSCUVAR_STRING:
			dest->type = source->type;
			dest->value = source->value;
			strings.add_ref(&dest->value.str);
			break;

		case GSCUVAR_FUNCTION:
		
		case GSCUVAR_FLOAT:
		case GSCUVAR_INTEGER:
		case GSCUVAR_HASH:
		case GSCUVAR_VECTOR:
			dest->type = source->type;
			dest->value = source->value;
			break;

		case GSCUVAR_UNDEFINED: // already undefined
		case GSCUVAR_PRECODEPOS: // how the hell did this happen?!
		case GSCUVAR_BEGINPARAMS: // ?!
		case GSCUVAR_ENDON: // ????
		case GSCUVAR_WAITTILL: // 
		case GSCUVAR_FREE: // leave the out variable undefined because this is a freed variable
			dest->type = GSCUVAR_UNDEFINED;
			dest->value.int64 = 0;
		break;

		case GSCUVAR_REFVAR:
			dest->type = GSCUVAR_REFVAR;
			dest->value.int32 = source->value.int32;
			add_variable_ref(source->value.int32);
		break;

		case GSCUVAR_STRUCT:
		case GSCUVAR_THREAD:
			dest->type = GSCUVAR_REFVAR;
			dest->value.int32 = source->id;
			add_variable_ref(source->id);
		break;

		case GSCUVAR_ITERATOR2:
		default:
			GSCU_RTWARNING(GSCU_ERROR_RUNTIME_TYPEESCAPEEXCEPTION, true, "Error: A type handler was not implemented for heap_to_stack type %d", source->type);
			break;
	}
}

void GContext::stack_to_heap(GSCUHeapVariable* dest, GSCUStackVariable* source)
{
	switch (source->type)
	{
		case GSCUVAR_STRING:
			dest->type = source->type;
			dest->value = source->value;
			strings.add_ref(&dest->value.str);
			break;

		case GSCUVAR_FUNCTION:
		case GSCUVAR_FLOAT:
		case GSCUVAR_INTEGER:
		case GSCUVAR_HASH:
		case GSCUVAR_VECTOR:
			dest->type = source->type;
			dest->value = source->value;
			break;

		case GSCUVAR_UNDEFINED: // already undefined
		case GSCUVAR_FREE: // leave the out variable undefined because this is a freed variable
			dest->type = GSCUVAR_UNDEFINED;
			dest->value.int64 = 0;
			break;

		case GSCUVAR_REFVAR:

			if (variables.find(source->value.int32) == variables.end())
			{
				dest->type = GSCUVAR_UNDEFINED;
				dest->value.int64 = 0;
				break;
			}

			dest->type = GSCUVAR_REFVAR;
			dest->value.int32 = variables[source->value.int32]->id;
			add_variable_ref(variables[source->value.int32]->id);
			break;

		case GSCUVAR_THREAD:
		case GSCUVAR_STRUCT:
		case GSCUVAR_PRECODEPOS:
		case GSCUVAR_BEGINPARAMS:
		case GSCUVAR_ENDON:
		case GSCUVAR_WAITTILL: 

		case GSCUVAR_ITERATOR2:
		default:
			GSCU_RTWARNING(GSCU_ERROR_RUNTIME_TYPEESCAPEEXCEPTION, true, "Error: A type handler was not implemented for stack_to_heap type %d", source->type);
			break;
	}
}

__int32 GContext::stack_to_canon(GSCUStackVariable* source, unsigned __int32& out_canon)
{
	GSCUVariableType type = source->type;
	GSCUVarValue value = source->value;

	try_eval:
	switch (type)
	{
		case GSCUVAR_HASH:
			out_canon = value.int32 ^ (unsigned __int32)(value.int64 >> 32); // fold the hash. granted this means that AAAAAAAABBBBBBBB = BBBBBBBBAAAAAAAA, but this collision chance is incredibly small and if it happens, well, sucks to suck!
			break;
		case GSCUVAR_INTEGER:
			out_canon = value.int32;
			break;
		case GSCUVAR_STRING:
			out_canon = GSCUHashing::canon_hash((const char*)value.str.str_ref);
			break;
		case GSCUVAR_REFVAR: // automatically follow ref vars
			if (variables.find(value.int32) == variables.end())
			{
				GSCU_RTERROR(GSCU_ERROR_RUNTIME_UNKNOWNVAR, false, "Error: Free variable reference hit while trying to follow a stack to evaluate a cannonical value (variable %d)", value.int32);
			}
			type = variables[value.int32]->type;
			value = variables[value.int32]->value;
			goto try_eval;
			break;

		case GSCUVAR_VECTOR: // what are you even trying to do lmao
		case GSCUVAR_FLOAT: // prevents developers from accidentally making big mistakes
		default:
			GSCU_RTERROR(GSCU_ERROR_RUNTIME_TYPEESCAPEEXCEPTION, false, "Error: Cannot cast variable of type %d to a cannonical identifier", source->type);
			break;
	}
	return 0;
}

__int32 GContext::stack_to_canon64(GSCUStackVariable* source, unsigned __int64& out_canon)
{
	GSCUVariableType type = source->type;
	GSCUVarValue value = source->value;

try_eval:
	switch (type)
	{
		case GSCUVAR_HASH:
			out_canon = value.int64;
			break;
		case GSCUVAR_INTEGER:
			out_canon = value.int32;
			break;
		case GSCUVAR_STRING:
			out_canon = GSCUHashing::canon_hash64((const char*)value.str.str_ref);
			break;
		case GSCUVAR_REFVAR: // automatically follow ref vars
			if (variables.find(value.int32) == variables.end())
			{
				GSCU_RTERROR(GSCU_ERROR_RUNTIME_UNKNOWNVAR, false, "Error: Free variable reference hit while trying to follow a stack to evaluate a cannonical value (variable %d)", value.int32);
			}
			type = variables[value.int32]->type;
			value = variables[value.int32]->value;
			goto try_eval;
			break;

		case GSCUVAR_VECTOR: // what are you even trying to do lmao
		case GSCUVAR_FLOAT: // prevents developers from accidentally making big mistakes
		default:
			GSCU_RTERROR(GSCU_ERROR_RUNTIME_TYPEESCAPEEXCEPTION, false, "Error: Cannot cast variable of type %d to a cannonical identifier", source->type);
			break;
	}
	return 0;
}

__int32 GContext::set_field_accessor(unsigned __int32 parent_id, unsigned __int32 field_name, GSCUStackVariable* value, GSCUVMContext& context, std::function<void(void*)> fn_finished)
{
	if (variables.find(parent_id) == variables.end())
	{
		GSCU_RTERROR(GSCU_ERROR_RUNTIME_UNKNOWNVAR, false, "Error: tried to set variable field of an unknown variable");
	}

	if (variables[parent_id]->type != GSCUVAR_STRUCT)
	{
		if (variables[parent_id]->type == GSCUVAR_VECTOR)
		{
			GSCUStackVariable temp{};
			auto result = cast_to_float(&temp, value);
			if (result)
			{
				return result;
			}

			switch (field_name)
			{
				case CONST32("x"):
					variables[parent_id]->value.vec.x = temp.value.f;
					return GSCU_FIELDACCESS_SIMPLE;
				case CONST32("y"):
					variables[parent_id]->value.vec.y = temp.value.f;
					return GSCU_FIELDACCESS_SIMPLE;
				case CONST32("z"):
					variables[parent_id]->value.vec.z = temp.value.f;
					return GSCU_FIELDACCESS_SIMPLE;
				case CONST32("w"):
					variables[parent_id]->value.vec.w = temp.value.f;
					return GSCU_FIELDACCESS_SIMPLE;
			}
		}

		GSCU_RTERROR(GSCU_ERROR_RUNTIME_NOTASTRUCT, false, "Error: tried to set variable field of a non-struct variable (type %d)", variables[parent_id]->type);
	}

	auto var = variables[parent_id];
	auto vclass = var->value.s.classname;

	if (field_name == scr_const::classname || field_name == scr_const::size)
	{
		return GSCU_FIELDACCESS_SIMPLE; // blacklisted names
	}

	if (!vclass || vclass == scr_const::array)
	{
		return GSCU_FIELDACCESS_FAIL;
	}

	if (classes.find(vclass) == classes.end())
	{
		return GSCU_FIELDACCESS_FAIL; // no accessor found
	}

	auto classdef = &classes[vclass];
	if (classdef->find(field_name) == classdef->end())
	{
		return GSCU_FIELDACCESS_FAIL; // no accessor found
	}

	auto memberdef = &((*classdef)[field_name]);

	switch (memberdef->type)
	{
		case GSCUCMT_Field:
		{
			if (!memberdef->m.field.set.func)
			{
				return GSCU_FIELDACCESS_SIMPLE; // we found an accessor but this field does not have a setter defined so we will just ignore it
			}

			// copy the target param into the new thread
			context.thread->stack.push_back(GSCUStackVariable());
			stack_set(&context.thread->stack.back(), value->type, value->value, context.thread);
			stack_transfer(main_thread, context.thread, 1, true);

			// create the new thread
			auto result = ((GContext*)context.vmc)->create_thread((void*)memberdef->m.field.set.func, memberdef->m.field.set.is_script_function, parent_id, 1);

			if (result < 0)
			{
				return result;
			}

			auto thread_id = result;

			// suspend our current thread
			context.thread->set_flag(GSCUTF_SUSPENDED);

			// this is a synchronous wait setter. bind a thread exited event for the remote thread id and have it resume on a delegate code callback
			thread_terminate_subscribe(thread_id, [context, this, fn_finished](void* child_context)
			{
				context.thread->clear_flag(GSCUTF_SUSPENDED); // requeue the parent thread for execution. this should end up running at the end of the frame.
				fn_finished(child_context);
			});

			// start the new thread
			result = ((GContext*)context.vmc)->vm_execute(thread_id);
			break;
		}
		break;

		case GSCUCMT_Call:
		{
			if (value->type != GSCUVAR_FUNCTION)
			{
				GSCU_RTERROR(GSCU_ERROR_VM_NOTAFUNCTION, false, "Error: cannot set class method field to a non-function");
			}
			memberdef->m.call.invoke = value->value.fn;
		}
		break;
	}

	return GSCU_FIELDACCESS_SIMPLE; // accessor found
}

__int32 GContext::get_field_accessor(unsigned __int32 parent_id, unsigned __int32 field_name, GSCUStackVariable* out, GSCUVMContext& context, std::function<void(void*)> fn_finished)
{
	if (variables.find(parent_id) == variables.end())
	{
		GSCU_RTERROR(GSCU_ERROR_RUNTIME_UNKNOWNVAR, false, "Error: tried to get variable field of an unknown variable");
	}

	if (variables[parent_id]->type != GSCUVAR_STRUCT)
	{
		GSCU_RTERROR(GSCU_ERROR_RUNTIME_NOTASTRUCT, false, "Error: tried to get variable field of a non-struct variable");
	}

	auto var = variables[parent_id];
	auto vclass = var->value.s.classname;

	if (field_name == scr_const::size)
	{
		out->type = GSCUVAR_INTEGER;
		out->value.int32 = (vclass == scr_const::array) ? var->value.s.native.a->size() : var->value.s.native.s->size();
		return GSCU_FIELDACCESS_SIMPLE;
	}

	if (field_name == scr_const::classname)
	{
		out->type = GSCUVAR_HASH;
		out->value.int64 = vclass;
		return GSCU_FIELDACCESS_SIMPLE;
	}

	if (classes.find(vclass) == classes.end())
	{
		return GSCU_FIELDACCESS_FAIL; // no accessor found
	}

	auto classdef = &classes[vclass];
	if (classdef->find(field_name) == classdef->end())
	{
		return GSCU_FIELDACCESS_FAIL; // no accessor found
	}

	auto memberdef = &((*classdef)[field_name]);

	switch (memberdef->type)
	{
		case GSCUCMT_Field:
		{
			out->type = GSCUVAR_UNDEFINED;
			out->value.int64 = 0;

			if (!memberdef->m.field.get.func)
			{
				return GSCU_FIELDACCESS_SIMPLE; // we found an accessor but this field does not have a getter defined so we will just ignore it
			}

			auto result = ((GContext*)context.vmc)->create_thread((void*)memberdef->m.field.get.func, memberdef->m.field.get.is_script_function, parent_id, 0);

			if (result < 0)
			{
				return result;
			}

			auto thread_id = result;

			// suspend our current thread
			context.thread->set_flag(GSCUTF_SUSPENDED);

			// this is a synchronous wait setter. bind a thread exited event for the remote thread id and have it resume on a delegate code callback
			thread_terminate_subscribe(thread_id, [context, this, fn_finished](void* child_context)
			{
				context.thread->clear_flag(GSCUTF_SUSPENDED); // requeue the parent thread for execution. this should end up running at the end of the frame.
				fn_finished(child_context);
			});

			// start the new thread
			result = ((GContext*)context.vmc)->vm_execute(thread_id);
			break;
		}
		break;

		case GSCUCMT_Call:
		{
			if (!memberdef->m.call.invoke.func)
			{
				out->type = GSCUVAR_UNDEFINED;
				out->value.int64 = 0;
				break;
			}
			out->type = GSCUVAR_FUNCTION;
			out->value.fn = memberdef->m.call.invoke;
		}
		break;
	}

	return GSCU_FIELDACCESS_SIMPLE; // accessor found
}

// The intended usage of this function is to just call it and it will handle all the references on the heap.
// Caller needs to handle stack references.
__int32 GContext::set_variable_field(unsigned __int32 parent_id, unsigned __int32 field_name, GSCUStackVariable* value)
{
	if (variables.find(parent_id) == variables.end())
	{
		GSCU_RTWARNING(GSCU_ERROR_RUNTIME_UNKNOWNVAR, false, "Error: tried to set variable field of an unknown variable");
		return 0;
	}

	if (variables[parent_id]->type != GSCUVAR_STRUCT)
	{
		GSCU_RTWARNING(GSCU_ERROR_RUNTIME_NOTASTRUCT, false, "Error: tried to set variable field of a non-struct variable");
		return 0;
	}

	auto parent = variables[parent_id];

	__int32 result = 0;

	if (parent->value.s.classname == scr_const::array)
	{
		if (field_name > parent->value.s.native.a->size())
		{
			GSCU_RTERROR(GSCU_ERROR_RUNTIME_ARRAYOOB, false, "Error: exceeded the boundaries of the input array");
		}
		if (field_name == parent->value.s.native.a->size())
		{
			// refvars are direct copied for array fields as to make certain vm behaviors work better
			if (value->type == GSCUVAR_REFVAR)
			{
				parent->value.s.native.a->push_back(value->value.int32);
				add_variable_ref(value->value.int32);
			}
			else
			{
				result = add_variable_field(parent_id, field_name);

				if (result)
				{
					return result;
				}

				stack_to_heap(variables[(*parent->value.s.native.a)[field_name]], value);
			}
		}
		else if(value->type == GSCUVAR_UNDEFINED)
		{
			result = clear_variable_field(parent_id, field_name);
		}
		else
		{
			// clear references to old variable
			if ((*parent->value.s.native.a)[field_name] != GSCU_BADVAR)
			{
				remove_variable_ref((*parent->value.s.native.a)[field_name]);
			}

			// refvars are direct copied for array fields as to make certain vm behaviors work better
			if (value->type == GSCUVAR_REFVAR)
			{
				(*parent->value.s.native.a)[field_name] = value->value.int32;
				add_variable_ref(value->value.int32);
			}
			else
			{
				auto id = (*parent->value.s.native.a)[field_name] = alloc_variable(0, 0);

				if (id < 0)
				{
					return id;
				}

				stack_to_heap(variables[id], value);
			}
		}
	}
	else
	{
		if (value->type == GSCUVAR_UNDEFINED)
		{
			if (parent->value.s.native.s->find(field_name) == parent->value.s.native.s->end())
			{
				return 0;
			}

			remove_variable_ref((*parent->value.s.native.s)[field_name]);
			(*parent->value.s.native.s).erase(field_name);
			return 0;
		}
		else if (value->type == GSCUVAR_REFVAR) // refvars are direct copied for struct fields as to make certain vm behaviors work better
		{
			(*parent->value.s.native.s)[field_name] = value->value.int32;
			add_variable_ref(value->value.int32);
			return 0;
		}
		
		auto id = (*parent->value.s.native.s)[field_name] = alloc_variable(0, 0);

		if (id < 0)
		{
			return id;
		}

		stack_to_heap(variables[id], value);
	}

	return 0;
}

__int32 GContext::add_variable_field(unsigned __int32 parent_id, unsigned __int32 field_name)
{
	if (variables.find(parent_id) == variables.end())
	{
		GSCU_RTERROR(GSCU_ERROR_RUNTIME_UNKNOWNVAR, false, "Error: tried to add variable field to an unknown variable");
	}

	auto parent = variables[parent_id];

	if (parent->value.s.classname == scr_const::array)
	{
		parent->value.s.native.a->push_back(alloc_variable(0, 0));
		auto id = parent->value.s.native.a->back();

		if (id < 0)
		{
			return id;
		}

		variables[id]->type = GSCUVAR_UNDEFINED;
		variables[id]->value.int64 = 0;
		add_variable_ref(id);
	}
	else
	{
		auto id = (*parent->value.s.native.s)[field_name] = alloc_variable(0, 0);

		if (id < 0)
		{
			return id;
		}

		add_variable_ref(id);
	}

	return 0;
}

__int32 GContext::clear_variable_field(unsigned __int32 parent_id, unsigned __int32 field_name)
{
	if (variables.find(parent_id) == variables.end())
	{
		GSCU_RTERROR(GSCU_ERROR_RUNTIME_UNKNOWNVAR, false, "Error: tried to clear variable field of an unknown variable");
	}

	auto parent = variables[parent_id];

	if (parent->value.s.classname == scr_const::array)
	{
		if (field_name >= parent->value.s.native.a->size())
		{
			GSCU_RTERROR(GSCU_ERROR_RUNTIME_ARRAYOOB, false, "Error: exceeded the boundaries of the input array");
		}
		auto id = (*parent->value.s.native.a)[field_name];

		if (id == GSCU_BADVAR)
		{
			return 0;
		}

		remove_variable_ref(id);
		(*parent->value.s.native.a)[field_name] = GSCU_BADVAR;
	}
	else
	{
		if (parent->value.s.native.s->find(field_name) == parent->value.s.native.s->end())
		{
			return 0;
		}
		
		auto id = parent->value.s.native.s->find(field_name)->second;
		remove_variable_ref(id);
		parent->value.s.native.s->erase(field_name);
	}

	return 0;
}

__int32 GContext::get_variable_field(unsigned __int32 parent_id, unsigned __int32 field_name, GSCUStackVariable* out)
{
	out->type = GSCUVAR_UNDEFINED;
	out->value.int64 = 0;

	if (variables.find(parent_id) == variables.end())
	{
		GSCU_RTWARNING(GSCU_ERROR_RUNTIME_UNKNOWNVAR, false, "Error: tried to get variable field of an unknown variable");
		return 0;
	}

	if (variables[parent_id]->type != GSCUVAR_STRUCT)
	{
		GSCU_RTWARNING(GSCU_ERROR_RUNTIME_NOTASTRUCT, false, "Error: tried to get variable field of a non-struct variable");
		return 0;
	}

	auto parent = variables[parent_id];
	if (parent->value.s.classname == scr_const::array)
	{
		if (parent->value.s.native.a->size() <= field_name)
		{
			return 0;
		}
		auto id = (*parent->value.s.native.a)[field_name];
		if (id == GSCU_BADVAR)
		{
			return 0;
		}
		heap_to_stack(out, variables[id]);
	}
	else
	{
		if (parent->value.s.native.s->find(field_name) == parent->value.s.native.s->end())
		{
			return 0;
		}
		auto id = (*parent->value.s.native.s)[field_name];
		heap_to_stack(out, variables[id]);
	}

	return 0;
}

__int32 GContext::array_copy(unsigned __int32 parent_id)
{
	if (variables.find(parent_id) == variables.end())
	{
		return GSCU_ERROR_RUNTIME_UNKNOWNVAR;
	}

	auto dest = alloc_variable(0, 0);

	if (dest < 0)
	{
		return dest;
	}

	auto parent_var = variables[parent_id];
	auto dest_var = variables[dest];
	dest_var->type = GSCUVAR_STRUCT;
	dest_var->value.s.classname = scr_const::array;
	dest_var->value.s.reserved = 0;
	dest_var->value.s.native.a = new std::vector<unsigned __int32>();

	dest_var->value.s.native.a->reserve(parent_var->value.s.native.a->size());

	for (int i = 0; i < parent_var->value.s.native.a->size(); i++)
	{
		auto id = (*parent_var->value.s.native.a)[i];
		dest_var->value.s.native.a->push_back(id);
		if (id == GSCU_BADVAR)
		{
			continue;
		}
		add_variable_ref(id);
	}

	return 0;
}

__int32 GContext::struct_copy(unsigned __int32 parent_id)
{
	if (variables.find(parent_id) == variables.end())
	{
		return GSCU_ERROR_RUNTIME_UNKNOWNVAR;
	}

	auto dest = alloc_variable(0, 0);

	if (dest < 0)
	{
		return dest;
	}

	auto parent_var = variables[parent_id];
	auto dest_var = variables[dest];
	dest_var->type = GSCUVAR_STRUCT;
	dest_var->value.s.classname = 0;
	dest_var->value.s.reserved = 0;
	dest_var->value.s.native.s = new std::unordered_map<unsigned __int32, unsigned __int32>();

	for (auto it = parent_var->value.s.native.s->begin(); it != parent_var->value.s.native.s->end(); it++)
	{
		add_variable_ref((*dest_var->value.s.native.s)[it->first] = it->second);
	}

	return 0;
}

// subscribe to all events for this object or remove them
__int32 GContext::subscribe_events(unsigned __int32 parent_id, unsigned __int32 thread_id, int num_subscriptions)
{
	assert(threads.find(thread_id) != threads.end());

	if (threads.find(thread_id) == threads.end())
	{
		GSCU_RTERROR(GSCU_ERROR_RUNTIME_UNKNOWNVAR, true, "Event subscription service caught a thread leak");
	}

	if (variables.find(parent_id) == variables.end())
	{
		GSCU_RTERROR(GSCU_ERROR_RUNTIME_UNKEVENTPARENT, false, "Tried to subscribe to the events of an undefined parent");
	}

	if (event_subscribers.find(parent_id) == event_subscribers.end())
	{
		event_subscribers[parent_id] = std::unordered_map<unsigned __int32, unsigned __int32>();
	}

	if (event_subscribers[parent_id].find(thread_id) == event_subscribers[parent_id].end())
	{
		event_subscribers[parent_id][thread_id] = 0;
	}

	event_subscribers[parent_id][thread_id] += num_subscriptions;

	if (!event_subscribers[parent_id][thread_id])
	{
		event_subscribers[parent_id].erase(thread_id);
	}

	if (!event_subscribers[parent_id].size())
	{
		event_subscribers.erase(parent_id);
	}

	return 0;
}

__int32 GContext::notify(unsigned __int32 object_id, unsigned __int64 event_id, GSCUHeapVariable* struct_value)
{
	if (event_subscribers.find(object_id) == event_subscribers.end())
	{
		// there arent any notify subscriptions for this object so we dont need to dispatch anything
		return 0;
	}

	if (event_subscribers[object_id].size() < 1)
	{
		event_subscribers[object_id].erase(object_id);
		return 0;
	}

	std::vector<unsigned __int32> safe_keys{};
	safe_keys.reserve(event_subscribers[object_id].size());

	for (auto& kv : event_subscribers[object_id])
	{
		safe_keys.push_back(kv.first);
	}

	for(auto thread_id : safe_keys)
	{
		if (event_subscribers.find(object_id) == event_subscribers.end())
		{
			// there arent any remaining notify subscriptions for this object so we dont need to dispatch anything
			return 0;
		}

		if (threads.find(thread_id) == threads.end() || threads[thread_id]->has_flag(GSCUTF_EXITED))
		{
			// thread disposed but was not removed from the event queue
			event_subscribers[object_id].erase(thread_id);

			if (event_subscribers[object_id].size() < 1)
			{
				event_subscribers[object_id].erase(object_id);
				return 0;
			}

			continue;
		}

		auto thread = threads[thread_id];

		// check for endon dispatchers
		for (int i = 0; i < thread->stack.size(); i++)
		{
			auto jit = &thread->stack.at(i);
			if (jit->type != GSCUVAR_ENDON)
			{
				continue;
			}
			if (jit->value.endon.parent_id != object_id)
			{
				continue;
			}
			if (jit->value.endon.condition_hash != event_id)
			{
				continue;
			}

			thread->set_flag(GSCUTF_EXITED);
			event_subscribers[object_id].erase(thread_id);

			if (event_subscribers[object_id].size() < 1)
			{
				event_subscribers[object_id].erase(object_id);
				return 0;
			}

			vm_execute(thread->id);
			goto loop_end;
		}

		// check for waittill dispatchers
		if (!thread->has_flag(GSCUTF_EXITED))
		{
			for (int i = (int)thread->stack.size() - 1; i >= 0; i--)
			{
				auto back = &thread->stack.at(i);
				if (back->type != GSCUVAR_WAITTILL)
				{
					break;
				}
				if (back->value.waittill.parent_id != object_id)
				{
					continue;
				}
				if (back->value.waittill.condition_hash != event_id)
				{
					continue;
				}

				// found a matching marker

				// clear waittill markers
				while (back->type == GSCUVAR_WAITTILL)
				{
					stack_dispose(back, thread);
					thread->stack.pop_back();
					back = &thread->stack.back();
				}

				// push notify struct
				thread->stack.push_back(GSCUStackVariable());
				back = &thread->stack.back();

				back->type = GSCUVAR_REFVAR;
				back->value.int32 = struct_value->id;
				add_variable_ref(struct_value->id);

				// resume the thread
				vm_execute(thread->id);
				break;
			}
		}
	loop_end:;
	}

	return 0;
}

__int32 GContext::notify_string(unsigned __int32 object_id, unsigned __int64 event_id)
{
	auto var = alloc_variable(0, vm);
	if (var < 0)
	{
		GSCU_RTERROR(GSCU_ERROR_RUNTIME_OUTOFVARIABLES, true, "Ran out of variables while attempting to notify a string");
	}

	GSCUStackVariable event_var{};
	event_var.type = GSCUVAR_HASH;
	event_var.value.int64 = event_id;

	variables[var]->type = GSCUVAR_STRUCT;
	variables[var]->value.s.classname = 0;

	auto result = set_variable_field(var, scr_const::event, &event_var);

	if (result)
	{
		return result;
	}

	GSCUStackVariable object_var{};
	object_var.type = GSCUVAR_REFVAR;
	object_var.value.int32 = object_id;

	result = set_variable_field(var, scr_const::object, &object_var);

	if (result)
	{
		return result;
	}

	return notify(object_id, event_id, variables[var]);
}

__int32 GContext::register_class(unsigned __int32 classname, GSCUStackVariable* ctor, GSCUStackVariable* dtor)
{
	if (classes.find(classname) != classes.end())
	{
		GSCU_RTERROR(GSCU_ERROR_RUNTIME_CLASSREGISTERFAILURE, true, "cannot register class %X because it was already registered", classname);
	}

	classes[classname] = std::unordered_map<unsigned __int32, GSCUClassMember>();

	if (ctor && ctor->type == GSCUVAR_FUNCTION)
	{
		classes[classname][scr_const::ctor] = GSCUClassMember();
		classes[classname][scr_const::ctor].type = GSCUCMT_Call;
		classes[classname][scr_const::ctor].m.call.invoke = ctor->value.fn;
	}
	
	if (dtor && dtor->type == GSCUVAR_FUNCTION)
	{
		classes[classname][scr_const::dtor] = GSCUClassMember();
		classes[classname][scr_const::dtor].type = GSCUCMT_Call;
		classes[classname][scr_const::dtor].m.call.invoke = dtor->value.fn;
	}

	return 0;
}

bool GContext::is_class_registered(unsigned __int32 classname)
{
	if (!classname || classname == scr_const::array)
	{
		return true;
	}
	return classes.find(classname) != classes.end();
}

__int32 GContext::set_class_method(unsigned __int32 classname, unsigned __int32 fieldname, GSCUStackVariable* fn)
{
	if (classes.find(classname) == classes.end())
	{
		GSCU_RTERROR(GSCU_ERROR_VM_INVALIDCLASS, true, "cannot modify class %X because it was never registered", classname);
	}

	if (fn->type == GSCUVAR_UNDEFINED)
	{
		if (classes[classname].find(fieldname) == classes[classname].end())
		{
			return 0;
		}
		classes[classname].erase(fieldname);
	}
	else
	{
		if (classes[classname].find(fieldname) == classes[classname].end())
		{
			classes[classname][fieldname] = GSCUClassMember();
		}
		classes[classname][fieldname].type = GSCUCMT_Call;
		classes[classname][fieldname].m.call.invoke = fn->value.fn;
	}

	return 0;
}

__int32 GContext::get_class_method(unsigned __int32 classname, unsigned __int32 fieldname, GSCUStackVariable* out)
{
	out->type = GSCUVAR_UNDEFINED;
	out->value.int64 = 0;

	if (classes.find(classname) == classes.end())
	{
		return 0;
	}

	if (classes[classname].find(fieldname) == classes[classname].end())
	{
		return 0;
	}

	if (classes[classname][fieldname].type != GSCUCMT_Call)
	{
		return 0;
	}

	out->type = GSCUVAR_FUNCTION;
	out->value.fn = classes[classname][fieldname].m.call.invoke;
	return 0;
}

__int32 GContext::set_class_prop(unsigned __int32 classname, unsigned __int32 fieldname, GSCUStackVariable* fn, bool is_setter)
{
	if (classes.find(classname) == classes.end())
	{
		GSCU_RTERROR(GSCU_ERROR_VM_INVALIDCLASS, true, "cannot modify class %X because it was never registered", classname);
	}

	if (fn->type == GSCUVAR_UNDEFINED)
	{
		if (classes[classname].find(fieldname) == classes[classname].end())
		{
			return 0;
		}
		
		if (classes[classname][fieldname].type != GSCUCMT_Field)
		{
			classes[classname].erase(fieldname);

			return 0;
		}

		if (is_setter)
		{
			classes[classname][fieldname].m.field.set.func = 0;
		}
		else
		{
			classes[classname][fieldname].m.field.get.func = 0;
		}

		if (classes[classname][fieldname].m.field.get.func == classes[classname][fieldname].m.field.set.func)
		{
			classes[classname].erase(fieldname);
		}
	}
	else
	{
		if (classes[classname].find(fieldname) == classes[classname].end())
		{
			classes[classname][fieldname] = GSCUClassMember();
		}

		if (classes[classname][fieldname].type != GSCUCMT_Field)
		{
			classes[classname][fieldname].type = GSCUCMT_Field;

			if (is_setter)
			{
				classes[classname][fieldname].m.field.get.func = 0;
			}
			else
			{
				classes[classname][fieldname].m.field.set.func = 0;
			}
		}
		
		if (is_setter)
		{
			classes[classname][fieldname].m.field.set = fn->value.fn;
		}
		else
		{
			classes[classname][fieldname].m.field.get = fn->value.fn;
		}
	}

	return 0;
}

__int32 GContext::get_class_prop(unsigned __int32 classname, unsigned __int32 fieldname, GSCUStackVariable* fn_out, bool is_setter)
{
	fn_out->type = GSCUVAR_UNDEFINED;

	if (classes.find(classname) == classes.end())
	{
		return 0;
	}

	if (classes[classname].find(fieldname) == classes[classname].end())
	{
		return 0;
	}

	if (classes[classname][fieldname].type != GSCUCMT_Field)
	{
		return 0;
	}

	if (is_setter && classes[classname][fieldname].m.field.set.func)
	{
		fn_out->type = GSCUVAR_FUNCTION;
		fn_out->value.fn = classes[classname][fieldname].m.field.set;
	}
	
	if (!is_setter && classes[classname][fieldname].m.field.get.func)
	{
		fn_out->type = GSCUVAR_FUNCTION;
		fn_out->value.fn = classes[classname][fieldname].m.field.get;
	}

	return 0;
}

bool GContext::is_class_field_prop(unsigned __int32 classname, unsigned __int32 fieldname)
{
	if (fieldname == scr_const::size || fieldname == scr_const::classname)
	{
		return true;
	}

	if (classes.find(classname) == classes.end())
	{
		return false;
	}

	if (classname == scr_const::array)
	{
		return false;
	}

	return classes[classname].find(fieldname) != classes[classname].end();
}

void GContext::sizeof_variable(unsigned __int32 id, GSCUStackVariable& var_out, GSCUVMContext& context)
{
	var_out.type = GSCUVAR_INTEGER;
	var_out.value.int32 = 0;

	if (variables.find(id) == variables.end())
	{
		return;
	}

	switch (variables[id]->type)
	{
		case GSCUVAR_STRING:
			var_out.value.int32 = variables[id]->value.str.size;
			break;

		case GSCUVAR_VECTOR:
			var_out.type = GSCUVAR_FLOAT;
			var_out.value.f = GSCUVars::vector_length(variables[id]->value.vec);
			break;

		case GSCUVAR_STRUCT:
			get_field_accessor(id, scr_const::size, &var_out, context, [](void*) {});
			break;
	}

	return;
}

// TODO: make this source/dest like all the other casts
__int32 GContext::cast_to_bool(GSCUStackVariable* castRef)
{
	auto newValue = 0;
	auto result = 0;
	try_cast:
	switch (castRef->type)
	{
		case GSCUVAR_INTEGER:
			newValue = castRef->value.int32 != 0;
		break;
		case GSCUVAR_FLOAT:
			newValue = ((int)castRef->value.f) != 0;
		break;
		case GSCUVAR_REFVAR:
			if (variables.find(castRef->value.int32) == variables.end())
			{
				castRef->type = GSCUVAR_FREE;
				goto try_cast;
			}
			castRef->type = variables[castRef->value.int32]->type;
			castRef->value = variables[castRef->value.int32]->value;
			goto try_cast;
		default:
			result = GSCU_ERROR_RUNTIME_INVALIDCAST;
			GSCU_RTWARNING(GSCU_ERROR_RUNTIME_INVALIDCAST, false, "Cannot cast type %d to bool", castRef->type);
		break;
	}

	castRef->type = GSCUVAR_INTEGER;
	castRef->value.int64 = newValue;
	return result;
}

__int32 GContext::cast_to_float(GSCUStackVariable* dest, GSCUStackVariable* source)
{
	auto sourceType = source->type;
	auto sourceValue = source->value;
	auto result = 0;

	dest->value.int64 = 0;
	dest->type = GSCUVAR_UNDEFINED;

	try_cast:
	switch (sourceType)
	{
		case GSCUVAR_REFVAR:
			if (variables.find(sourceValue.int32) == variables.end())
			{
				sourceType = GSCUVAR_FREE;
				goto try_cast;
			}
			sourceType = variables[sourceValue.int32]->type;
			sourceValue = variables[sourceValue.int32]->value;
			goto try_cast;

		case GSCUVAR_FLOAT:
			dest->type = sourceType;
			dest->value = sourceValue;
			break;

		case GSCUVAR_STRING:
			dest->type = GSCUVAR_FLOAT;
			dest->value.f = (float)atof(sourceValue.str.str_ref);
			break;

		case GSCUVAR_INTEGER:
			dest->type = GSCUVAR_FLOAT;
			dest->value.f = (float)sourceValue.int32;
			break;

		default:
			result = GSCU_ERROR_RUNTIME_INVALIDCAST;
			GSCU_RTWARNING(GSCU_ERROR_RUNTIME_INVALIDCAST, false, "Cannot cast type %d to float", sourceType);
			break;
	}

	return result;
}

__int32 GContext::cast_to_vector(GSCUStackVariable* dest, GSCUStackVariable* source)
{
	dest->type = GSCUVAR_VECTOR;
	dest->value.vec.x = 0;
	dest->value.vec.y = 0;
	dest->value.vec.z = 0;
	dest->value.vec.w = 0;

	auto sourceType = source->type;
	auto sourceValue = source->value;
	__int32 result = 0;

try_cast:
	switch (sourceType)
	{
		case GSCUVAR_VECTOR:
			dest->value = sourceValue;
		break;
		case GSCUVAR_INTEGER:
			dest->value.vec.x = (float)sourceValue.int32;
			break;
		case GSCUVAR_FLOAT:
			dest->value.vec.x = sourceValue.f;
			break;
		case GSCUVAR_REFVAR:
			if (variables.find(sourceValue.int32) == variables.end())
			{
				sourceType = GSCUVAR_FREE;
				goto try_cast;
			}
			sourceType = variables[sourceValue.int32]->type;
			sourceValue = variables[sourceValue.int32]->value;
			goto try_cast;
			break;
		default:
			result = GSCU_ERROR_RUNTIME_INVALIDCAST;
			GSCU_RTWARNING(GSCU_ERROR_RUNTIME_INVALIDCAST, false, "Cannot cast type %d to vector", sourceType);
			break;
	}
	return result;
}

__int32 GContext::cast_to_string(GSCUStackVariable* dest, GSCUStackVariable* source)
{
	auto sourceType = source->type;
	auto sourceValue = source->value;
	__int32 result = 0;

	dest->type = GSCUVAR_UNDEFINED;
	dest->value.int64 = 0;

	try_cast:
	switch (sourceType)
	{
		case GSCUVAR_INTEGER:
		{
			GSCUString str_out{};
			auto str_result = strings.alloc(31, str_out);
			if (str_result || !str_out.str_ref)
			{
				// catastrophic failure
				GSCU_RTERROR(GSCU_ERROR_RUNTIME_FAILEDSTRINGALLOC, true, "Failed to allocate a string while trying to cast");
			}

			sprintf_s(str_out.str_ref, (size_t)str_out.max_size + 1, "%d", sourceValue.int32);
			strings.update_size(&str_out);
			dest->type = GSCUVAR_STRING;
			dest->value.str = str_out;
		}
		break;

		case GSCUVAR_FLOAT:
		{
			GSCUString str_out{};
			auto str_result = strings.alloc(31, str_out);
			if (str_result || !str_out.str_ref)
			{
				// catastrophic failure
				GSCU_RTERROR(GSCU_ERROR_RUNTIME_FAILEDSTRINGALLOC, true, "Failed to allocate a string while trying to cast");
			}

			sprintf_s(str_out.str_ref, (size_t)str_out.max_size + 1, "%f", sourceValue.f);
			strings.update_size(&str_out);
			dest->type = GSCUVAR_STRING;
			dest->value.str = str_out;
		}
		break;

		case GSCUVAR_STRING:
			dest->type = source->type;
			dest->value = source->value;
			strings.add_ref(&dest->value.str);
			break;

		case GSCUVAR_HASH:
		{
			GSCUString str_out{};
			auto str_result = strings.alloc(31, str_out);
			if (str_result || !str_out.str_ref)
			{
				// catastrophic failure
				GSCU_RTERROR(GSCU_ERROR_RUNTIME_FAILEDSTRINGALLOC, true, "Failed to allocate a string while trying to cast");
			}
			sprintf_s(str_out.str_ref, (size_t)str_out.max_size + 1, "%llX", sourceValue.int64);
			strings.update_size(&str_out);
			dest->type = GSCUVAR_STRING;
			dest->value.str = str_out;
		}
		break;

		case GSCUVAR_VECTOR:
		{
			GSCUString str_out{};
			auto str_result = strings.alloc(256, str_out);
			if (str_result || !str_out.str_ref)
			{
				// catastrophic failure
				GSCU_RTERROR(GSCU_ERROR_RUNTIME_FAILEDSTRINGALLOC, true, "Failed to allocate a string while trying to cast");
			}
			sprintf_s(str_out.str_ref, (size_t)str_out.max_size + 1, "(%f, %f, %f, %f)", sourceValue.vec.x, sourceValue.vec.y, sourceValue.vec.z, sourceValue.vec.w);
			strings.update_size(&str_out);
			dest->type = GSCUVAR_STRING;
			dest->value.str = str_out;
		}
		break;

		case GSCUVAR_REFVAR:
			if (variables.find(sourceValue.int32) == variables.end())
			{
				sourceType = GSCUVAR_FREE;
				goto try_cast;
			}
			sourceType = variables[sourceValue.int32]->type;
			sourceValue = variables[sourceValue.int32]->value;
			goto try_cast;
			break;

		case GSCUVAR_UNDEFINED:
		{
			GSCUString str_out{};
			auto str_result = strings.alloc(31, str_out);
			if (str_result || !str_out.str_ref)
			{
				// catastrophic failure
				GSCU_RTERROR(GSCU_ERROR_RUNTIME_FAILEDSTRINGALLOC, true, "Failed to allocate a string while trying to cast");
			}
			sprintf_s(str_out.str_ref, (size_t)str_out.max_size + 1, "undefined");
			strings.update_size(&str_out);
			dest->type = GSCUVAR_STRING;
			dest->value.str = str_out;
		}
		break;

		default:
			result = GSCU_ERROR_RUNTIME_INVALIDCAST;
			GSCU_RTWARNING(GSCU_ERROR_RUNTIME_INVALIDCAST, false, "Cannot cast type %d to string", sourceType);
			break;
	}
	return result;
}

__int32 GContext::array_to_struct(GSCUHeapVariable* a)
{
	if (a->type != GSCUVAR_STRUCT || a->value.s.classname != scr_const::array)
	{
		GSCU_RTERROR(GSCU_ERROR_RUNTIME_INVALIDCAST, false, "Cannot cast type %d to struct", a->type);
	}

	auto ref = new std::unordered_map<unsigned __int32, unsigned __int32>();

	int index = 0;
	for (auto it = a->value.s.native.a->begin(); it != a->value.s.native.a->end(); it++)
	{
		if (*it == GSCU_BADVAR)
		{
			continue;
		}
		(*ref)[index] = *it;
		index++;
	}

	delete a->value.s.native.a;
	a->value.s.native.s = ref;

	return 0;
}

__int32 GContext::struct_to_array(GSCUHeapVariable* s)
{
	if (s->type != GSCUVAR_STRUCT || s->value.s.classname == scr_const::array)
	{
		GSCU_RTERROR(GSCU_ERROR_RUNTIME_INVALIDCAST, false, "Cannot cast type %d to array", s->type);
	}

	auto ref = new std::vector<unsigned __int32>();

	for (auto it = s->value.s.native.s->begin(); it != s->value.s.native.s->end(); it++)
	{
		ref->push_back(it->second);
	}

	delete s->value.s.native.s;
	s->value.s.native.a = ref;

	return 0;
}

__int32 GContext::string_append(GSCUString& dest, GSCUString* first, GSCUString* second)
{
	auto final_size = (unsigned __int32)first->size + (unsigned __int32)second->size;
	auto str_result = strings.alloc(final_size, dest);
	if (str_result)
	{
		// catastrophic failure
		GSCU_RTERROR(GSCU_ERROR_RUNTIME_FAILEDSTRINGALLOC, true, "Failed to allocate a string while trying to append");
	}
	sprintf_s(dest.str_ref, (size_t)dest.max_size + 1, "%s%s", first->str_ref, second->str_ref);
	strings.update_size(&dest);
	return 0;
}

bool GContext::find_script_function(GSCObj* glob_obj, GSCImport* _import, GSCExport& _export, GSCObj*& parent)
{
	memset(&_export, 0, sizeof(GSCExport));
	parent = NULL;

	assert(glob_obj != NULL);
	if (!glob_obj)
	{
		return false;
	}

	assert(_import != NULL);
	if (!_import)
	{
		return false;
	}

	assert(glob_obj->has_flag(GSCOF_LOADED));
	if (!_import)
	{
		return false;
	}

	if (glob_obj->find_export(_import, _export))
	{
		parent = glob_obj;
		return _export.bytecode != NULL;
	}

	auto current_include = glob_obj->includes();
	for (unsigned int j = 0; j < glob_obj->num_includes(); j++, current_include++)
	{
		if (current_include->name & ((__int64)1 << 63)) // api import
		{
			continue;
		}

		auto script = scripts.find(current_include->name)->second;
		if (!script->find_export(_import, _export))
		{
			continue;
		}
		parent = script;
		break;
	}

	return _export.bytecode != NULL;
}

bool GContext::find_builtin_function(GSCObj* glob_obj, GSCImport* _import, GSCUBuiltinInfo& _builtin)
{
	memset(&_builtin, 0, sizeof(GSCUBuiltinInfo));
	GSCUBuiltinInfo* builtin = NULL;

	// explicitly called
	if (_import->space)
	{
		unsigned __int64 key = GSCU_LINKFUNC_KEY(_import->name, _import->space);
		auto result = builtins.find(key);

		if (result == builtins.end())
		{
			return false;
		}

		builtin = result->second;

		if (!builtin->has_flag(GSCEF_VARIADIC))
		{
			if (_import->param_count > builtin->max_params || _import->param_count < builtin->min_params)
			{
				return false;
			}
		}
	}
	else
	{
		// implicitly called
		for (auto it = known_apis.begin(); it != known_apis.end(); it++)
		{
			unsigned __int64 key = GSCU_LINKFUNC_KEY(_import->name, (*it));
			auto result = builtins.find(key);

			if (result == builtins.end())
			{
				continue;
			}

			if (!result->second->has_flag(GSCEF_VARIADIC))
			{
				if (_import->param_count > result->second->max_params || _import->param_count < result->second->min_params)
				{
					continue;
				}
			}

			builtin = result->second;
			break;
		}
	}

	if (!builtin)
	{
		return false;
	}

	_builtin = *builtin;
	return true;
}

__int32 GContext::register_builtin_function(unsigned __int32 canon_name, unsigned __int32 canon_space, unsigned __int8 min_params, unsigned __int8 max_params, unsigned __int32 flags, tGSCUBuiltinFunction func)
{
	auto key = GSCU_LINKFUNC_KEY(canon_name, canon_space);
	if (builtins.find(key) != builtins.end())
	{
		return GSCU_ERROR_API_DUPLICATEBUILTIN;
	}

	assert(func);
	if (!func)
	{
		return GSCU_ERROR_API_NULLBUILTIN;
	}

	known_apis.insert(canon_space);

	builtins[key] = new GSCUBuiltinInfo();
	builtins[key]->flags = flags;
	builtins[key]->name = canon_name;
	builtins[key]->space = canon_space;
	builtins[key]->min_params = min_params;
	builtins[key]->max_params = max_params;
	builtins[key]->func = func;
	return 0;
}

API_CALL GContext::api_set_tick_rate(GContext* vm, unsigned __int32 ms)
{
	if (!ms)
	{
		GSCU_IAPI_RTERROR(vm, GSCU_ERROR_API_ZEROTICK, false, "Error: Cannot set tickrate of the vm to 0!");
	}

	vm->vm_ms_tick = ms;
	return vm->vm_tick();
}

API_CALL GContext::api_get_tick_rate(GContext* vm)
{
	return vm->vm_ms_tick;
}

API_CALL GContext::api_last_error(GContext* vm)
{
	return vm->last_error_code;
}

API_CALL GContext::api_copy_last_lnk_error(GContext* vm, char* buff, __int32 size)
{
	strcpy_s(buff, size, vm->last_link_error);
	return 0;
}

API_CALL GContext::api_get_num_params(GContext* vm, GSCUThreadContext* thread)
{
	return thread->num_params;
}

API_CALL GContext::api_get_string(GContext* vm, GSCUThreadContext* thread, __int32 index, const char*& out)
{
	// in the interest of speed, index range checking is left to api users
	auto var = &thread->stack.at(thread->stack.size() - 2 - index);
	if (var->type != GSCUVAR_STRING)
	{
		out = NULL;
		GSCU_IAPI_RTERROR(vm, GSCU_ERROR_API_TYPEMISMATCH, false, "Error: Variable at index %d is not a string", index);
	}
	out = (const char*)var->value.str.str_ref;
	return GSCU_SUCCESS;
}

API_CALL GContext::api_report_error(GContext* vm, unsigned __int32 error_code, const char* msg)
{
	vm->last_error_code = error_code;
	sprintf_s(vm->last_runtime_error, "%s", msg);
	return error_code;
}

API_CALL GContext::api_get_struct(GContext* vm, GSCUThreadContext* thread, unsigned __int32 index, unsigned __int32& out_id)
{
	// in the interest of speed, index range checking is left to api users
	auto var = &thread->stack.at(thread->stack.size() - 2 - index);
	if (var->type != GSCUVAR_REFVAR)
	{
		out_id = GSCU_BADVAR;
		GSCU_IAPI_RTERROR(vm, GSCU_ERROR_API_TYPEMISMATCH, false, "Error: Variable at index %d is not a struct", index);
	}

	out_id = var->value.int32;

	if (vm->variables[out_id]->type != GSCUVAR_STRUCT)
	{
		out_id = GSCU_BADVAR;
		GSCU_IAPI_RTERROR(vm, GSCU_ERROR_API_TYPEMISMATCH, false, "Error: Variable at index %d is not a struct", index);
	}

	return 0;
}

API_CALL GContext::api_add_array_element(GContext* vm, GSCUThreadContext* thread, unsigned __int32 struct_id)
{
	auto var = vm->variables[struct_id];
	auto size = (var->value.s.classname == scr_const::array) ? var->value.s.native.a->size() : var->value.s.native.s->size();
	return vm->set_variable_field(struct_id, size, &thread->stack.at(thread->stack.size() - 2));
}

void GContext::quit()
{
	// kill all threads
	for (auto it = threads.begin(); it != threads.end(); it++)
	{
		it->second->set_flag(GSCUTF_EXITED);
		it->second->marked_for_death = true;
	}

	// tell the vm to exit here. vm_execute and vm_tick will no longer do anything while the vm is suspended.
	has_exited = true;
	is_suspended = true;

#if _DEBUG
#if (GSCU_BRANCH == GSCU_BRANCH_DEBUG)
	// if in a debug build, throw a real exception so that we can figure out what happened
	if (last_error_code)
	{
		printf("%s", last_runtime_error);
		__debugbreak();
	}
#endif
#endif
}

GContext* __fastcall GContext::create()
{
	return new GContext(NULL);
}

API_CALL GContext::api_loadbuffs(GContext* vm, GSCObj** objects, unsigned __int32 count)
{
	if (!objects)
	{
		return GSCU_ERR_BADOBJECT;
	}

	GSCObj* _;
	for (unsigned __int32 i = 0; i < count; i++)
	{
		__int32 result = vm->load(objects[i], _);
		if (result)
		{
			return GSCU_ERR_BADOBJECT;
		}
	}

	return GSCU_SUCCESS;
}

API_CALL GContext::api_linkbuffs(GContext* vm, GSCObj** objects, unsigned __int32 count)
{
	if (!objects)
	{
		return GSCU_ERR_BADOBJECT;
	}

	for (unsigned __int32 i = 0; i < count; i++)
	{
		__int32 result = vm->link(objects[i]);
		if (result)
		{
			return GSCU_ERR_BADOBJECT;
		}
	}

	return GSCU_SUCCESS;
}

API_CALL GContext::api_tick(GContext* vm)
{
	if (vm)
	{
		vm->vm_tick();
	}
	return GSCU_SUCCESS;
}

API_CALL GContext::api_register_class(GContext* vm, unsigned __int32 classname, tGSCUBuiltinFunction fn_ctor, tGSCUBuiltinFunction fn_dtor)
{
	GSCUStackVariable ctor{};
	GSCUStackVariable dtor{};

	ctor.type = GSCUVAR_UNDEFINED;
	dtor.type = GSCUVAR_UNDEFINED;

	if (fn_ctor)
	{
		ctor.type = GSCUVAR_FUNCTION;
		ctor.value.fn.func = (unsigned __int64)fn_ctor;
		ctor.value.fn.is_script_function = false;
		ctor.value.fn.captures = 0;
	}

	if (fn_dtor)
	{
		dtor.type = GSCUVAR_FUNCTION;
		dtor.value.fn.func = (unsigned __int64)fn_dtor;
		dtor.value.fn.is_script_function = false;
		dtor.value.fn.captures = 0;
	}

	auto result = vm->register_class(classname, &ctor, &dtor);

	if (result == GSCU_ERROR_RUNTIME_CLASSREGISTERFAILURE)
	{
		return GSCU_ERR_CLASS_ALREADY_REGISTERED;
	}

	return GSCU_SUCCESS;
}

API_CALL GContext::api_register_class_method(GContext* vm, unsigned __int32 classname, unsigned __int32 methodname, tGSCUBuiltinFunction fn)
{
	GSCUStackVariable stack_fn{};
	stack_fn.type = GSCUVAR_UNDEFINED;

	if (fn)
	{
		stack_fn.type = GSCUVAR_FUNCTION;
		stack_fn.value.fn.func = (unsigned __int64)fn;
		stack_fn.value.fn.is_script_function = false;
		stack_fn.value.fn.captures = 0;
	}

	auto result = vm->set_class_method(classname, methodname, &stack_fn);

	if (result == GSCU_ERROR_VM_INVALIDCLASS)
	{
		return GSCU_ERR_BAD_CLASS;
	}

	return GSCU_SUCCESS;
}

__int32 GContext::debug_suspend(GSCUVMContext& context)
{
	is_suspended = true;
	context.thread->set_flag(GSCUTF_SUSPENDED);
	suspend_context = context;
	VME_DUMPVM();

	return GSCU_SUCCESS;
}

#if defined VME_DEBUG || defined VME_DUMP
__int32 GContext::dump_vm_stats()
{
	DPRINT("VME:DUMP:START");
	DPRINT("");
	DPRINT("VME:STACK: size %d", suspend_context.thread->stack.size());

	for (int i = 0; i < suspend_context.thread->stack.size(); i++)
	{
		auto stackval = suspend_context.thread->stack.at(suspend_context.thread->stack.size() - 1 - i);

		DPRINT("VME:STACK:[top - %02d]: type(%02d) value(%02X %02X %02X %02X  %02X %02X %02X %02X  %02X %02X %02X %02X  %02X %02X %02X %02X)", i, (int)stackval.type, (int)stackval.value.buff[0], (int)stackval.value.buff[1],
			(int)stackval.value.buff[2], (int)stackval.value.buff[3], (int)stackval.value.buff[4], (int)stackval.value.buff[5], (int)stackval.value.buff[6], (int)stackval.value.buff[7], (int)stackval.value.buff[8],
			(int)stackval.value.buff[9], (int)stackval.value.buff[10], (int)stackval.value.buff[11], (int)stackval.value.buff[12], (int)stackval.value.buff[13], (int)stackval.value.buff[14], (int)stackval.value.buff[15]);
	}

	DPRINT("");
	DPRINT("VME:DUMP:END");
	return 0;
}
#endif

__int32 GSCUCallContext::num_params()
{
	return GContext::api_get_num_params((GContext*) vmc, thread);
}

__int32 GSCUCallContext::last_error()
{
	return GContext::api_last_error((GContext*)vmc);
}