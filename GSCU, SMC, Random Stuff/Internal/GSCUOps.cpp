#include "GSCUOps.h"

void GSCUOpcodes::default_opcodes(tGSCUOpcodeHandler*& opcodes)
{
	opcodes = new tGSCUOpcodeHandler[GSCUOP_COUNT];
	opcodes[GSCUOP_NOP] = &vm_op_nop;
	opcodes[GSCUOP_CreateLocalVariables] = &vm_op_create_locals;
	opcodes[GSCUOP_End] = &vm_op_end;
	opcodes[GSCUOP_PreScriptCall] = &vm_op_prescriptcall;
	opcodes[GSCUOP_GetByte] = &vm_op_getbyte;
	opcodes[GSCUOP_GetZero] = &vm_op_getzero;
	opcodes[GSCUOP_GetOne] = &vm_op_getone;
	opcodes[GSCUOP_GetInteger] = &vm_op_getint;
	opcodes[GSCUOP_GetFloat] = &vm_op_getfloat;
	opcodes[GSCUOP_GetString] = &vm_op_getstring;
	opcodes[GSCUOP_CallBuiltin] = &vm_op_callbuiltin;
	opcodes[GSCUOP_Return] = &vm_op_return;
	opcodes[GSCUOP_DecTop] = &vm_op_dectop;
	opcodes[GSCUOP_CallScriptFunction] = &vm_op_callscriptfunction;
	opcodes[GSCUOP_Wait] = &vm_op_wait;
	opcodes[GSCUOP_GetSelf] = &vm_op_getself;
	opcodes[GSCUOP_ThreadCallBuiltin] = &vm_op_threadcallbuiltin;
	opcodes[GSCUOP_ThreadCallScript] = &vm_op_threadcallscript;
	opcodes[GSCUOP_MethodCallBuiltin] = &vm_op_methodcallbuiltin;
	opcodes[GSCUOP_MethodCallScript] = &vm_op_methodcallscript;
	opcodes[GSCUOP_EvalLocalVariableCached] = &vm_op_evallocalvariablecached;
	opcodes[GSCUOP_AddStruct] = &vm_op_addstruct;
	opcodes[GSCUOP_SetLocalVariable] = &vm_op_setlocalvariable;
	opcodes[GSCUOP_SetVariableField] = &vm_op_setvariablefield;
	opcodes[GSCUOP_EvalVariableField] = &vm_op_evalvariablefield;
	opcodes[GSCUOP_AddArray] = &vm_op_addarray;
	opcodes[GSCUOP_AddUndefined] = &vm_op_addundefined;
	opcodes[GSCUOP_EvalFieldOnStack] = &vm_op_evalfieldonstack;
	opcodes[GSCUOP_GetHash] = &vm_op_gethash;
	opcodes[GSCUOP_MakeVec2] = &vm_op_makevec2;
	opcodes[GSCUOP_MakeVec3] = &vm_op_makevec3;
	opcodes[GSCUOP_MakeVec4] = &vm_op_makevec4;
	opcodes[GSCUOP_SetFieldOnStack] = &vm_op_setfieldonstack;
	opcodes[GSCUOP_ThreadMethodCallScript] = &vm_op_threadmethodcallscript;
	opcodes[GSCUOP_ThreadMethodCallBuiltin] = &vm_op_threadmethodcallbuiltin;
	opcodes[GSCUOP_Endon] = &vm_op_endon;
	opcodes[GSCUOP_Notify] = &vm_op_notify;
	opcodes[GSCUOP_Waittill] = &vm_op_waittill;
	opcodes[GSCUOP_Waitframe] = &vm_op_waitframe;
	opcodes[GSCUOP_GetAPIFunction] = &vm_op_getapifunction;
	opcodes[GSCUOP_GetScriptFunction] = &vm_op_getscriptfunction;
	opcodes[GSCUOP_CallPointer] = &vm_op_callpointer;
	opcodes[GSCUOP_MethodCallPointer] = &vm_op_methodcallpointer;
	opcodes[GSCUOP_ThreadCallPointer] = &vm_op_threadcallpointer;
	opcodes[GSCUOP_ThreadMethodCallPointer] = &vm_op_threadmethodcallpointer;
	opcodes[GSCUOP_BoolNot] = &vm_op_boolnot;
	opcodes[GSCUOP_Jump] = &vm_op_jump;
	opcodes[GSCUOP_JumpOnFalse] = &vm_op_jumponfalse;
	opcodes[GSCUOP_JumpOnTrue] = &vm_op_jumpontrue;
	opcodes[GSCUOP_JumpOnFalseExpr] = &vm_op_jumponfalseexpr;
	opcodes[GSCUOP_JumpOnTrueExpr] = &vm_op_jumpontrueexpr;
	opcodes[GSCUOP_Plus] = &vm_op_plus;
	opcodes[GSCUOP_Minus] = &vm_op_minus;
	opcodes[GSCUOP_Multiply] = &vm_op_multiply;
	opcodes[GSCUOP_Divide] = &vm_op_divide;
	opcodes[GSCUOP_Modulo] = &vm_op_modulo;
	opcodes[GSCUOP_BitShiftLeft] = &vm_op_bitshiftleft;
	opcodes[GSCUOP_BitShiftRight] = &vm_op_bitshiftright;
	opcodes[GSCUOP_BitAnd] = &vm_op_bitand;
	opcodes[GSCUOP_BitOr] = &vm_op_bitor;
	opcodes[GSCUOP_BitXor] = &vm_op_bitxor;
	opcodes[GSCUOP_BitNegate] = &vm_op_bitnegate;
	opcodes[GSCUOP_Equals] = &vm_op_equals;
	opcodes[GSCUOP_NotEquals] = &vm_op_notequals;
	opcodes[GSCUOP_SuperEquals] = &vm_op_superequals;
	opcodes[GSCUOP_SuperNotEquals] = &vm_op_supernotequals;
	opcodes[GSCUOP_GreaterThan] = &vm_op_greaterthan;
	opcodes[GSCUOP_LessThanEqualTo] = &vm_op_lessthanequalto;
	opcodes[GSCUOP_LessThan] = &vm_op_lessthan;
	opcodes[GSCUOP_GreaterThanEqualTo] = &vm_op_greaterthanequalto;
	opcodes[GSCUOP_SizeOf] = &vm_op_sizeof;
	opcodes[GSCUOP_VMTime] = &vm_op_vmtime;
	opcodes[GSCUOP_IncField] = &vm_op_incfield;
	opcodes[GSCUOP_DecField] = &vm_op_decfield;
	opcodes[GSCUOP_IncLocal] = &vm_op_inclocal;
	opcodes[GSCUOP_DecLocal] = &vm_op_declocal;
	opcodes[GSCUOP_IsDefined] = &vm_op_isdefined;
	opcodes[GSCUOP_GetGlobalVariable] = &vm_op_getglobalvariable;
	opcodes[GSCUOP_FirstField] = &vm_op_firstfield;
	opcodes[GSCUOP_NextField] = &vm_op_nextfield;
	opcodes[GSCUOP_GetFieldValue] = &vm_op_getfieldvalue;
	opcodes[GSCUOP_GetFieldKey] = &vm_op_getfieldkey;
	opcodes[GSCUOP_EnterSafeContext] = &vm_op_entersafecontext;
	opcodes[GSCUOP_ExitSafeContext] = &vm_op_exitsafecontext;
	opcodes[GSCUOP_CheckType] = &vm_op_checktype;
	opcodes[GSCUOP_CastTo] = &vm_op_castto;
	opcodes[GSCUOP_DeconstructObject] = &vm_op_deconstructobject;
	opcodes[GSCUOP_FreeObject] = &vm_op_freeobject;
	opcodes[GSCUOP_Switch] = &vm_op_switch;
	opcodes[GSCUOP_AddFieldOnStack] = &vm_op_addfieldonstack;
	opcodes[GSCUOP_AddField] = &vm_op_addfield;
	opcodes[GSCUOP_Breakpoint] = &vm_op_breakpoint;
	opcodes[GSCUOP_RegisterClass] = &vm_op_registerclass;
	opcodes[GSCUOP_SetClassMethod] = &vm_op_setclassmethod;
	opcodes[GSCUOP_GetClassMethod] = &vm_op_getclassmethod;
	opcodes[GSCUOP_CallClassMethod] = &vm_op_callclassmethod;
	opcodes[GSCUOP_CallClassMethodThreaded] = &vm_op_callclassmethodthreaded;
	opcodes[GSCUOP_SpawnClassObject] = &vm_op_spawnclassobject;
	opcodes[GSCUOP_DuplicateParameters] = &vm_op_duplicateparameters;
	opcodes[GSCUOP_PopulateVararg] = &vm_op_populatevararg;
	opcodes[GSCUOP_Unpack] = &vm_op_unpack;
	opcodes[GSCUOP_StackCopy] = &vm_op_stackcopy;
	opcodes[GSCUOP_AddAnonymousFunction] = &vm_op_addanonymousfunction;
	opcodes[GSCUOP_Throw] = &vm_op_throw;
	opcodes[GSCUOP_SetClassPropSetter] = &vm_op_setclasspropsetter;
	opcodes[GSCUOP_SetClassPropGetter] = &vm_op_setclasspropgetter;
	opcodes[GSCUOP_GetClassPropSetter] = &vm_op_getclasspropsetter;
	opcodes[GSCUOP_GetClassPropGetter] = &vm_op_getclasspropgetter;
}

GSCU_Opcodes GSCUOpcodes::calc_import_code(bool is_method, bool is_getfn, bool is_threaded, bool is_native)
{
	if (is_getfn)
	{
		return is_native ? GSCUOP_GetAPIFunction : GSCUOP_GetScriptFunction;
	}
	if (is_method)
	{
		if (is_threaded)
		{
			return is_native ? GSCUOP_ThreadMethodCallBuiltin : GSCUOP_ThreadMethodCallScript;
		}
		return is_native ? GSCUOP_MethodCallBuiltin : GSCUOP_MethodCallScript;
	}
	if (is_threaded)
	{
		return is_native ? GSCUOP_ThreadCallBuiltin : GSCUOP_ThreadCallScript;
	}
	return is_native ? GSCUOP_CallBuiltin : GSCUOP_CallScriptFunction;
}

__int32 GSCUOpcodes::vm_op_nop(GSCUVMContext&)
{
	return 0;
}

// params passed as follows: [begin_params][a3][a2][a1][precodepos][p1][p2][p3][l1][l2][l3]
__int32 GSCUOpcodes::vm_op_create_locals(GSCUVMContext& context)
{
	// this opcode creates new locals and parameters, copying values from the previous stack into the current locals
	// number of non-param locals
	unsigned __int8 num_locals = *(unsigned __int8*)context.thread->fs_pos;

	// number of param only locals
	unsigned __int8 num_params = *(unsigned __int8*)(context.thread->fs_pos + 1);

	context.thread->fs_pos += 2;

	if (!(num_locals + num_params))
	{
		return 0;
	}

	GContext* vmc = (GContext*)context.vmc;

	__int32 start_params = (__int32)context.thread->stack.size() - 2;
	__int32 start_locals = (__int32)context.thread->stack.size();

	context.thread->start_locals = start_locals;

	// initialize variables
	for (int i = 0; i < ((unsigned __int16)num_locals + (unsigned __int16)num_params); i++)
	{
		context.thread->stack.push_back(GSCUStackVariable());
		auto back = &context.thread->stack.back();
		back->type = GSCUVAR_UNDEFINED;
		back->value.int64 = 0;
	}

	// copy params to locals
	for (int i = 0; i < context.thread->num_params && i < num_params; i++)
	{
		auto paramval = &context.thread->stack.at(start_params - i);
		auto local = &context.thread->stack.at(start_locals + i);
		((GContext*)context.vmc)->stack_set(local, paramval->type, paramval->value, context.thread);
	}

	return 0;
}

__int32 GSCUOpcodes::vm_op_end(GSCUVMContext& context)
{
	// this opcode disposes of all stack elements in the current frame, restores the current thread's context, and resumes in the previous fs_pos
	GContext* vmc = (GContext*)context.vmc;
	auto back = &context.thread->stack.back();
	__int64 rfs_pos = 0;

	while (context.thread->stack.size() && (back->type != GSCUVAR_BEGINPARAMS))
	{
		if (back->type == GSCUVAR_PRECODEPOS)
		{
			rfs_pos = back->value.int64;
		}
		vmc->stack_dispose(back, context.thread);
		context.thread->stack.pop_back();
		back = &context.thread->stack.back();
	}

	if (context.thread->stack.size())
	{
		vmc->stack_dispose(back, context.thread);
		context.thread->stack.pop_back();
	}

	context.thread->stack.push_back(GSCUStackVariable());
	back = &context.thread->stack.back();
	back->type = GSCUVAR_UNDEFINED;
	back->value.int32 = 0;

	if (rfs_pos)
	{
		context.thread->fs_pos = rfs_pos;
	}
	else
	{
		context.thread->set_flag(GSCUTF_EXITED);
	}

	return 0;
}

__int32 GSCUOpcodes::vm_op_prescriptcall(GSCUVMContext& context)
{
	// this opcode caches the current stack frame information so that a call to a new function can remember local stack info when it returns
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_BEGINPARAMS;
	back->value.frame.self = context.self;
	back->value.frame.old_num_params = context.thread->num_params;
	back->value.frame.old_start_locals = context.thread->start_locals;
	return 0;
}

__int32 GSCUOpcodes::vm_op_getbyte(GSCUVMContext& context)
{
	// this opcode pushes a byte at the current instruction pointer to the stack
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_INTEGER;
	back->value.int32 = *(unsigned __int8*)context.thread->fs_pos;
	context.thread->fs_pos += 2;
	return 0;
}

__int32 GSCUOpcodes::vm_op_getzero(GSCUVMContext& context)
{
	// this opcode pushes byte 0 to the stack
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_INTEGER;
	back->value.int32 = 0;
	return 0;
}

__int32 GSCUOpcodes::vm_op_getone(GSCUVMContext& context)
{
	// this opcode pushes byte 1 to the stack
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_INTEGER;
	back->value.int32 = 1;
	return 0;
}

__int32 GSCUOpcodes::vm_op_getint(GSCUVMContext& context)
{
	// this opcode gets an integer at the current instruction pointer and pushes it to the stack
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int32));
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_INTEGER;
	back->value.int32 = *(__int32*)context.thread->fs_pos;
	context.thread->fs_pos += sizeof(__int32);
	return 0;
}

__int32 GSCUOpcodes::vm_op_getfloat(GSCUVMContext& context)
{
	// this opcode gets a float at the current instruction pointer and pushes it to the stack
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(float));
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_FLOAT;
	back->value.f = *(float*)context.thread->fs_pos;
	context.thread->fs_pos += sizeof(float);
	return 0;
}

__int32 GSCUOpcodes::vm_op_getstring(GSCUVMContext& context)
{
	// this opcode gets a string, addressed relative to the current instruction pointer, and pushes it to the stack
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int32));
	auto offset = *(__int32*)context.thread->fs_pos;
	context.thread->fs_pos += sizeof(__int32);

	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_STRING;
	back->value.str.str_ref = (char*)(context.thread->fs_pos + offset);
	back->value.str.size = (unsigned __int16)strlen((char*)back->value.str.str_ref);
	back->value.str.max_size = back->value.str.size;
	back->value.str.set_bucket(GSCUSB_NONE);

	return 0;
}

__int32 GSCUOpcodes::callbuiltin_internal(GSCUVMContext& context, tGSCUBuiltinFunction func)
{
	__int32 count = (__int32)context.thread->stack.size() - 1;
	__int32 index = 0;
	__int32 varcount = 0;

	while ((index < count) && context.thread->stack.at(count - index).type != GSCUVAR_BEGINPARAMS)
	{
		index++;
		varcount++;
	}

	// prep for function call
	context.thread->num_params = varcount;
	context.thread->start_locals = 0;
	((GContext*)context.vmc)->thread_push_parent(context.thread->id, context.self);

	// push precodepos and switch to native mode
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_PRECODEPOS;
	back->value.int64 = context.thread->fs_pos;
	context.thread->fs_pos = (__int64)func;
	context.thread->set_flag(GSCUTF_NATIVE);

	return 0;
}

__int32 GSCUOpcodes::vm_op_callbuiltin(GSCUVMContext& context)
{
	// this opcode calls a native function on the current thread with the same self context
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int64));
	tGSCUBuiltinFunction func = *(tGSCUBuiltinFunction*)context.thread->fs_pos;
	context.thread->fs_pos += 8;
	return callbuiltin_internal(context, func);
}

__int32 GSCUOpcodes::vm_op_return(GSCUVMContext& context)
{
	// this opcode caches the top stack element for return, disposes and returns to the original fs_pos, decrements the top of the stack to remove the OP_End undefined, and pushes the return value back to the top of the stack
	GSCUStackVariable back = context.thread->stack.back();
	context.thread->stack.pop_back();
	vm_op_end(context);
	vm_op_dectop(context);
	context.thread->stack.push_back(back);
	return 0;
}

__int32 GSCUOpcodes::vm_op_dectop(GSCUVMContext& context)
{
	// this opcode decrements and disposes of the top stack element
	GContext* vmc = (GContext*)context.vmc;
	auto back = &context.thread->stack.back();
	vmc->stack_dispose(back, context.thread);
	context.thread->stack.pop_back();
	return 0;
}

__int32 GSCUOpcodes::callscriptfunction_internal(GSCUVMContext& context, __int64 fs_pos_new)
{
	__int32 count = (__int32)context.thread->stack.size() - 1;
	__int32 index = 0;
	__int32 varcount = 0;

	// count number of params
	while ((index < count) && context.thread->stack.at(count - index).type != GSCUVAR_BEGINPARAMS)
	{
		index++;
		varcount++;
	}

	// prep thread for function call
	context.thread->num_params = varcount;
	context.thread->start_locals = 0;
	((GContext*)context.vmc)->thread_push_parent(context.thread->id, context.self);

	// push precodepos
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_PRECODEPOS;
	back->value.int64 = context.thread->fs_pos;
	context.thread->fs_pos = (__int64)fs_pos_new;
	return 0;
}

__int32 GSCUOpcodes::vm_op_callscriptfunction(GSCUVMContext& context)
{
	// this opcode calls a script function on the current thread with the same self context
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int64));
	__int64 fs_pos_new = *(__int64*)context.thread->fs_pos;
	context.thread->fs_pos += 8;
	return callscriptfunction_internal(context, fs_pos_new);
}

__int32 GSCUOpcodes::vm_op_wait(GSCUVMContext& context)
{
	// this opcode suspends the current thread and pushes it to the wait queue
	auto back = context.thread->stack.back();

	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	__int32 waitms = 0;
	switch (back.type)
	{
		case GSCUVAR_FLOAT:
			waitms = (__int32)(back.value.f * 1000);
			break;
		case GSCUVAR_INTEGER:
			waitms = (__int32)(back.value.int32 * 1000);
			break;
		default:
			VM_RTERROR(context, GSCU_ERROR_VM_BADWAITPARAM, "Expected a float or an integer for a wait. Instead, got type %d", back.type);
			break;
	}

	if (waitms <= 0)
	{
		VM_RTERROR(context, GSCU_ERROR_VM_BADWAITPARAM, "cannot wait a negative or zero time.");
	}

	((GContext*)context.vmc)->suspend_thread_for_time(context.thread->id, waitms);
	return 0;
}

__int32 GSCUOpcodes::vm_op_getself(GSCUVMContext& context)
{
	// this opcode gets a reference to the current context's self variable and pushes it to the stack
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_REFVAR;
	back->value.int32 = context.self;
	((GContext*)context.vmc)->add_variable_ref(context.self);
	return 0;
}

__int32 GSCUOpcodes::threadcallbuiltin_internal(GSCUVMContext& context, tGSCUBuiltinFunction func)
{
	// count number of params
	__int32 count = (__int32)context.thread->stack.size() - 1;
	__int32 index = 0;
	__int32 varcount = 0;

	while ((index < count) && context.thread->stack.at(count - index).type != GSCUVAR_BEGINPARAMS)
	{
		index++;
		varcount++;
	}

	// copy parameters over to the new thread
	((GContext*)context.vmc)->stack_transfer(((GContext*)context.vmc)->get_main_thread(), context.thread, varcount, true);

	// get rid of the beginparams
	auto back = &context.thread->stack.back();
	((GContext*)context.vmc)->stack_dispose(back, context.thread);
	context.thread->stack.pop_back();

	// create the thread
	auto result = ((GContext*)context.vmc)->create_thread(func, false, context.self, varcount);
	if (result < 0)
	{
		vm_op_addundefined(context);
		return result;
	}

	auto thread_id = result;

	// add a reference early so that the thread isnt disposed of
	((GContext*)context.vmc)->add_variable_ref(thread_id);

	// start new thread
	result = ((GContext*)context.vmc)->vm_execute(result);

	// return a ref to the thread
	context.thread->stack.push_back(GSCUStackVariable());
	back = &context.thread->stack.back();
	back->type = GSCUVAR_REFVAR;
	back->value.int32 = thread_id;

	return 0;
}

__int32 GSCUOpcodes::vm_op_threadcallbuiltin(GSCUVMContext& context)
{
	// this opcode calls a native function with self context on a new thread
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int64));
	tGSCUBuiltinFunction func = *(tGSCUBuiltinFunction*)context.thread->fs_pos;
	context.thread->fs_pos += 8;
	return threadcallbuiltin_internal(context, func);
}

__int32 GSCUOpcodes::threadcallscript_internal(GSCUVMContext& context, __int64 fs_pos_new)
{
	// count number of parameters
	__int32 count = (__int32)context.thread->stack.size() - 1;
	__int32 index = 0;
	__int32 varcount = 0;

	while ((index < count) && context.thread->stack.at(count - index).type != GSCUVAR_BEGINPARAMS)
	{
		index++;
		varcount++;
	}

	// copy parameters over to the new thread
	((GContext*)context.vmc)->stack_transfer(((GContext*)context.vmc)->get_main_thread(), context.thread, varcount, true);

	// get rid of the beginparams
	auto back = &context.thread->stack.back();
	((GContext*)context.vmc)->stack_dispose(back, context.thread);
	context.thread->stack.pop_back();

	// create the thread
	auto result = ((GContext*)context.vmc)->create_thread((void*)fs_pos_new, true, context.self, varcount);

	if (result < 0)
	{
		vm_op_addundefined(context);
		return result;
	}

	auto thread_id = result;

	// add a reference early so that the thread isnt disposed of
	((GContext*)context.vmc)->add_variable_ref(thread_id);

	// start the new thread
	result = ((GContext*)context.vmc)->vm_execute(result);

	// return a ref to the new thread
	context.thread->stack.push_back(GSCUStackVariable());
	back = &context.thread->stack.back();
	back->type = GSCUVAR_REFVAR;
	back->value.int32 = thread_id;

	return 0;
}

__int32 GSCUOpcodes::vm_op_threadcallscript(GSCUVMContext& context)
{
	// this opcode calls a script function with self context on a new thread
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int64));
	__int64 fs_pos_new = *(__int64*)context.thread->fs_pos;
	context.thread->fs_pos += 8;
	return threadcallscript_internal(context, fs_pos_new);
}

__int32 GSCUOpcodes::methodcallbuiltin_internal(GSCUVMContext& context, tGSCUBuiltinFunction func)
{
	// start at the number of params
	__int32 count = (__int32)context.thread->stack.size() - 2;
	__int32 index = 0;
	__int32 varcount = 0;

	// count number of params
	while ((index < count) && context.thread->stack.at(count - index).type != GSCUVAR_BEGINPARAMS)
	{
		index++;
		varcount++;
	}

	auto back = &context.thread->stack.back();
	if (back->type != GSCUVAR_REFVAR)
	{
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		context.thread->stack.pop_back();

		// get rid of all params and beginparams
		for (int i = 0; i <= varcount; i++)
		{
			back = &context.thread->stack.back();
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
		}

		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_VM_BADSELF, "method calls must be on ref vars.");
	}

	// pop self, apply self
	context.thread->num_params = varcount;
	context.thread->start_locals = 0;
	((GContext*)context.vmc)->thread_push_parent(context.thread->id, back->value.int32);
	((GContext*)context.vmc)->stack_dispose(back, context.thread);
	context.thread->stack.pop_back();

	// push precodepos for resuming thread
	context.thread->stack.push_back(GSCUStackVariable());
	back = &context.thread->stack.back();
	back->type = GSCUVAR_PRECODEPOS;
	back->value.int64 = context.thread->fs_pos;
	context.thread->fs_pos = (__int64)func;
	context.thread->set_flag(GSCUTF_NATIVE);

	return 0;
}

__int32 GSCUOpcodes::vm_op_methodcallbuiltin(GSCUVMContext& context)
{
	// this opcode changes self context, then calls a native function with new context on the same thread
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int64));
	tGSCUBuiltinFunction func = *(tGSCUBuiltinFunction*)context.thread->fs_pos;
	context.thread->fs_pos += 8;
	return methodcallbuiltin_internal(context, func);
}

__int32 GSCUOpcodes::methodcallscript_internal(GSCUVMContext& context, __int64 fs_pos_new)
{
	// start at numparams
	__int32 count = (__int32)context.thread->stack.size() - 2;
	__int32 index = 0;
	__int32 varcount = 0;

	// count num params
	while ((index < count) && context.thread->stack.at(count - index).type != GSCUVAR_BEGINPARAMS)
	{
		index++;
		varcount++;
	}

	auto back = &context.thread->stack.back();
	if (back->type != GSCUVAR_REFVAR)
	{
		// get rid of self
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		context.thread->stack.pop_back();

		// get rid of all params and beginparams
		for (int i = 0; i <= varcount; i++)
		{
			back = &context.thread->stack.back();
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
		}

		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_VM_BADSELF, "method calls must be on ref vars.");
	}

	// apply self
	context.thread->num_params = varcount;
	context.thread->start_locals = 0;
	((GContext*)context.vmc)->thread_push_parent(context.thread->id, back->value.int32);
	((GContext*)context.vmc)->stack_dispose(back, context.thread);
	context.thread->stack.pop_back();

	// push precodepos
	context.thread->stack.push_back(GSCUStackVariable());
	back = &context.thread->stack.back();
	back->type = GSCUVAR_PRECODEPOS;
	back->value.int64 = context.thread->fs_pos;
	context.thread->fs_pos = (__int64)fs_pos_new;

	return 0;
}

__int32 GSCUOpcodes::vm_op_methodcallscript(GSCUVMContext& context)
{
	// this opcode changes self context, then calls a script function with new context on the same thread
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int64));
	__int64 fs_pos_new = *(__int64*)context.thread->fs_pos;
	context.thread->fs_pos += 8;
	return methodcallscript_internal(context, fs_pos_new);
}

__int32 GSCUOpcodes::vm_op_evallocalvariablecached(GSCUVMContext& context)
{
	// this opcode simply copies the value of a stack variable onto the working stack
	unsigned __int8 index = *(unsigned __int8*)context.thread->fs_pos;
	context.thread->fs_pos += 2;
	if (!context.thread->start_locals)
	{
		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "tried to access a local variable when none exist");
	}

	if ((context.thread->start_locals + index) >= context.thread->stack.size())
	{
		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "tried to access a local variable outside of the boundaries of the stack");
	}

	__int16 stack_index = context.thread->start_locals + index;
	auto local = &context.thread->stack.at(stack_index);
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	((GContext*)context.vmc)->stack_set(back, local->type, local->value, context.thread);
	return 0;
}

__int32 GSCUOpcodes::vm_op_addstruct(GSCUVMContext& context)
{
	// this opcode registers a new struct in the heap and adds a reference to it in the stack
	auto var_id = ((GContext*)context.vmc)->alloc_variable(0, 0);

	if (var_id < 0)
	{
		return var_id;
	}

	((GContext*)context.vmc)->add_variable_ref(var_id);

	auto variable = ((GContext*)context.vmc)->api_get_variable(var_id);

	assert(variable);
	if (!variable)
	{
		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "unable to find the variable allocated in op_addstruct");
	}

	variable->type = GSCUVAR_STRUCT;
	variable->value.s.classname = 0;
	variable->value.s.reserved = 0;
	variable->value.s.native.s = new std::unordered_map<unsigned __int32, unsigned __int32>();

	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_REFVAR;
	back->value.int32 = var_id;
	return 0;
}

__int32 GSCUOpcodes::vm_op_setlocalvariable(GSCUVMContext& context)
{
	// this opcode simply copies the top of the stack into the target local variable
	unsigned __int8 index = *(unsigned __int8*)context.thread->fs_pos;
	context.thread->fs_pos += 2;

	if (!context.thread->start_locals)
	{
		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "tried to access a local variable when none exist");
	}

	if ((context.thread->start_locals + index) >= context.thread->stack.size())
	{
		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "tried to access a local variable outside of the boundaries of the stack");
	}

	__int16 stack_index = context.thread->start_locals + index;
	auto local = &context.thread->stack.at(stack_index);
	auto back = &context.thread->stack.back();
	((GContext*)context.vmc)->stack_set(local, back->type, back->value, context.thread);
	((GContext*)context.vmc)->stack_dispose(back, context.thread);
	context.thread->stack.pop_back();
	return 0;
}

__int32 GSCUOpcodes::setvariablefieldinternal(GSCUVMContext& context, bool remove_parent)
{
	// stack:
	// val
	// owner

	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int32));
	auto field_id = *(__int32*)context.thread->fs_pos;
	context.thread->fs_pos += sizeof(__int32);

	auto owning_object = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto val = &context.thread->stack.back();

	if (owning_object->type != GSCUVAR_REFVAR)
	{
		// dispose of the stack references
		((GContext*)context.vmc)->stack_dispose(val, context.thread);
		context.thread->stack.pop_back();

		if (remove_parent)
		{
			((GContext*)context.vmc)->stack_dispose(owning_object, context.thread);
			context.thread->stack.pop_back();
		}
		
		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "cannot set a field variable on a variable of type %d", owning_object->type);
	}

	auto result = ((GContext*)context.vmc)->set_field_accessor(owning_object->value.int32, field_id, val, context, [context, remove_parent](void* other_thread_ctx)
		{
			auto other_ctx = (GSCUVMContext*)other_thread_ctx;

			// propagate the last error code so safe context also props
			if (other_ctx->thread->exit_code)
			{
				context.thread->exit_code = other_ctx->thread->exit_code;
				((GContext*)context.vmc)->last_error_code = other_ctx->thread->exit_code;
			}

			// dispose of the stack references
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();

			if (remove_parent)
			{
				((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
				context.thread->stack.pop_back();
			}

			// propagate thrown exceptions
			if (other_ctx->thread->has_flag(GSCUTF_RAISE_EXCEPTION))
			{
				context.thread->exit_code = GSCU_ERROR;
				context.thread->set_flag(GSCUTF_RAISE_EXCEPTION);

				context.thread->stack.push_back(GSCUStackVariable());
				context.thread->stack.push_back(GSCUStackVariable());
				context.thread->stack.push_back(GSCUStackVariable());

				for (int i = 0; i < 3; i++)
				{
					auto back_dest = &context.thread->stack.at(context.thread->stack.size() - 1 - i);
					auto back_src = &other_ctx->thread->stack.at(other_ctx->thread->stack.size() - 1 - i);
					((GContext*)context.vmc)->stack_set(back_dest, back_src->type, back_src->value, context.thread);
				}
			}
		});

	if (!result)
	{
		return 0;
	}

	if (result == GSCU_FIELDACCESS_SIMPLE || result < 0)
	{
		goto finished;
	}

	result = ((GContext*)context.vmc)->set_variable_field(owning_object->value.int32, field_id, val);

finished:
	// dispose of the stack references
	((GContext*)context.vmc)->stack_dispose(val, context.thread);
	context.thread->stack.pop_back();

	if (remove_parent)
	{
		((GContext*)context.vmc)->stack_dispose(owning_object, context.thread);
		context.thread->stack.pop_back();
	}

	return result;
}

__int32 GSCUOpcodes::vm_op_setvariablefield(GSCUVMContext& context)
{
	// this opcode does the following:
	//		1. Search for an override accessor for the current variable, if found, call the function and return
	//		2. Search for an existing field variable with the given name, if not found, create a variable
	//		3. Set the field variable's value

	return setvariablefieldinternal(context, true);
}

__int32 GSCUOpcodes::vm_op_evalvariablefield(GSCUVMContext& context)
{
	// this opcode gets the value of a variable field and pushes it to the stack.
	// note that this pulls heap variable data into the stack.

	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int32));
	auto field_id = *(__int32*)context.thread->fs_pos;
	context.thread->fs_pos += sizeof(__int32);

	auto owning_object = &context.thread->stack.back();

	if (owning_object->type == GSCUVAR_VECTOR)
	{
		float val = 0;
		switch (field_id)
		{
			case 0:
			case CONST32("x"):
				val = owning_object->value.vec.x;
				break;

			case 1:
			case CONST32("y"):
				val = owning_object->value.vec.y;
				break;

			case 2:
			case CONST32("z"):
				val = owning_object->value.vec.z;
				break;

			case 3:
			case CONST32("w"):
				val = owning_object->value.vec.w;
				break;

			default:
				// this is different from typical vm behavior because it will make sure that the stack always has something to operate on.
				// dispose of the owning_object
				((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
				context.thread->stack.pop_back();

				vm_op_addundefined(context);

				VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "unable to access field of vector. valid fields are x, y, z, w, 0, 1, 2, 3, and size.");
				break;
		}

		// dispose of the owning_object
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		vm_op_addundefined(context);

		auto back = &context.thread->stack.back();
		back->type = GSCUVAR_FLOAT;
		back->value.f = val;
		return 0;
	}

	if (owning_object->type != GSCUVAR_REFVAR)
	{
		// this is different from typical vm behavior because it will make sure that the stack always has something to operate on.
		// dispose of the owning_object
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "cannot get a field variable on a variable of type %d", owning_object->type);
	}

	GSCUStackVariable var{};
	var.type = GSCUVAR_UNDEFINED;
	var.value.int64 = 0;

	// check if there is a get field accessor for this var
	auto result = ((GContext*)context.vmc)->get_field_accessor(owning_object->value.int32, field_id, &var, context, [context](void* other_thread_ctx)
		{
			auto other_ctx = (GSCUVMContext*)other_thread_ctx;

			// dispose of the owning_object
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();

			// propagate thrown exceptions
			if (other_ctx->thread->has_flag(GSCUTF_RAISE_EXCEPTION))
			{
				context.thread->exit_code = GSCU_ERROR;
				context.thread->set_flag(GSCUTF_RAISE_EXCEPTION);

				context.thread->stack.push_back(GSCUStackVariable());
				context.thread->stack.push_back(GSCUStackVariable());
				context.thread->stack.push_back(GSCUStackVariable());

				for (int i = 0; i < 3; i++)
				{
					auto back_dest = &context.thread->stack.at(context.thread->stack.size() - 1 - i);
					auto back_src = &other_ctx->thread->stack.at(other_ctx->thread->stack.size() - 1 - i);
					((GContext*)context.vmc)->stack_set(back_dest, back_src->type, back_src->value, context.thread);
				}
			}
			else if (other_ctx->thread->exit_code) // propagate the last error code so safe context also props
			{
				context.thread->exit_code = other_ctx->thread->exit_code;
				((GContext*)context.vmc)->last_error_code = other_ctx->thread->exit_code;
			}
			else
			{
				// push the new val back onto the stack
				context.thread->stack.push_back(GSCUStackVariable());
				auto back = &context.thread->stack.back();
				back->type = GSCUVAR_UNDEFINED;

				// copy from other thread
				auto child_back = &other_ctx->thread->stack.back();
				((GContext*)context.vmc)->stack_set(back, child_back->type, child_back->value, context.thread);
			}
		});

	if (!result)
	{
		return 0;
	}

	if (result == GSCU_FIELDACCESS_SIMPLE || result < 0)
	{
		goto finished;
	}
	
	result = ((GContext*)context.vmc)->get_variable_field(owning_object->value.int32, field_id, &var);

	finished:
	// dispose of the owning_object
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// push the new val back onto the stack
	context.thread->stack.push_back(var);
	
	return result;
}

__int32 GSCUOpcodes::vm_op_addarray(GSCUVMContext& context)
{
	// this opcode registers a new array in the heap and adds a reference to it in the stack
	auto var_id = ((GContext*)context.vmc)->alloc_variable(0, 0);
	((GContext*)context.vmc)->add_variable_ref(var_id);

	auto variable = ((GContext*)context.vmc)->api_get_variable(var_id);
	variable->type = GSCUVAR_STRUCT;
	variable->value.s.classname = scr_const::array;
	variable->value.s.reserved = 0;
	variable->value.s.native.a = new std::vector<unsigned __int32>();

	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_REFVAR;
	back->value.int32 = var_id;
	return 0;
}

__int32 GSCUOpcodes::vm_op_addundefined(GSCUVMContext& context)
{
	// this opcode pushes undefined to the stack
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_UNDEFINED;
	back->value.int64 = 0;
	return 0;
}

__int32 GSCUOpcodes::vm_op_evalfieldonstack(GSCUVMContext& context)
{
	// this opcode is basically eval field variable, but it gets the name from the stack.
	// this replaces op_evalarray because in this vm, arrays are just structs with classname array.
	// array structures are hard baked classes with get/set indexers
	// arrays are always associative, and the underlying type contains a pointer to an unordered map structure dynamically allocated on the heap.

	// stack:
	// field
	// owner

	GSCUStackVariable* owning_object = NULL;
	GSCUStackVariable* field_name = NULL;
	
	owning_object = &context.thread->stack.at(context.thread->stack.size() - 2);
	field_name = &context.thread->stack.back();

	unsigned __int32 field_canon = 0;
	auto result = ((GContext*)context.vmc)->stack_to_canon(field_name, field_canon);

	if (result)
	{
		// field
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// owner
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		vm_op_addundefined(context);
		return result;
	}

	if (owning_object->type == GSCUVAR_VECTOR)
	{
		float val = 0;
		switch (field_canon)
		{
			case 0:
			case CONST32("x"):
				val = owning_object->value.vec.x;
				break;

			case 1:
			case CONST32("y"):
				val = owning_object->value.vec.y;
				break;

			case 2:
			case CONST32("z"):
				val = owning_object->value.vec.z;
				break;

			case 3:
			case CONST32("w"):
				val = owning_object->value.vec.w;
				break;

			default:
				// this is different from typical vm behavior because it will make sure that the stack always has something to operate on.

				// field
				((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
				context.thread->stack.pop_back();

				// owner
				((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
				context.thread->stack.pop_back();

				vm_op_addundefined(context);

				VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "unable to access field of vector. valid fields are x, y, z, w, 0, 1, 2, 3, and size.");
				break;
		}

		// field
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// owner
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		vm_op_addundefined(context);

		auto back = &context.thread->stack.back();
		back->type = GSCUVAR_FLOAT;
		back->value.f = val;
		return 0;
	}

	if (owning_object->type != GSCUVAR_REFVAR)
	{
		// this is different from typical vm behavior because it will make sure that the stack always has something to operate on.

		// field
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// owner
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "cannot get a field variable on a variable of type %d", owning_object->type);
	}

	GSCUStackVariable val{};
	val.type = GSCUVAR_UNDEFINED;
	val.value.int64 = 0;

	// check if there is a get field accessor for this var
	result = ((GContext*)context.vmc)->get_field_accessor(owning_object->value.int32, field_canon, &val, context, [context](void* other_thread_ctx)
		{
			auto other_ctx = (GSCUVMContext*)other_thread_ctx;

			// field
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();

			// owner
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();

			// propagate thrown exceptions
			if (other_ctx->thread->has_flag(GSCUTF_RAISE_EXCEPTION))
			{
				context.thread->exit_code = GSCU_ERROR;
				context.thread->set_flag(GSCUTF_RAISE_EXCEPTION);

				context.thread->stack.push_back(GSCUStackVariable());
				context.thread->stack.push_back(GSCUStackVariable());
				context.thread->stack.push_back(GSCUStackVariable());

				for (int i = 0; i < 3; i++)
				{
					auto back_dest = &context.thread->stack.at(context.thread->stack.size() - 1 - i);
					auto back_src = &other_ctx->thread->stack.at(other_ctx->thread->stack.size() - 1 - i);
					((GContext*)context.vmc)->stack_set(back_dest, back_src->type, back_src->value, context.thread);
				}
			}
			else if (other_ctx->thread->exit_code) // propagate the last error code so safe context also props
			{
				context.thread->exit_code = other_ctx->thread->exit_code;
				((GContext*)context.vmc)->last_error_code = other_ctx->thread->exit_code;
			}
			else
			{
				// push the new val back onto the stack
				context.thread->stack.push_back(GSCUStackVariable());
				auto back = &context.thread->stack.back();
				back->type = GSCUVAR_UNDEFINED;

				// copy from other thread
				auto child_back = &other_ctx->thread->stack.back();
				((GContext*)context.vmc)->stack_set(back, child_back->type, child_back->value, context.thread);
			}
		});

	if (!result)
	{
		return 0;
	}

	if (result == GSCU_FIELDACCESS_SIMPLE || result < 0)
	{
		goto finished;
	}

	result = ((GContext*)context.vmc)->get_variable_field(owning_object->value.int32, field_canon, &val);

finished:
	// field
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// owner
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// push the new val back onto the stack
	context.thread->stack.push_back(val);

	return result;
}

__int32 GSCUOpcodes::vm_op_gethash(GSCUVMContext& context)
{
	// this opcode gets a 64 bit integer at the current aligned FS_POS (presumably a hash) and pushes it to the stack
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int64));
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_HASH;
	back->value.int64 = *(__int64*)context.thread->fs_pos;
	context.thread->fs_pos += sizeof(__int64);
	return 0;
}

__int32 GSCUOpcodes::vm_op_makevec2(GSCUVMContext& context)
{
	return vm_op_makevector_common(context, 2);
}

__int32 GSCUOpcodes::vm_op_makevec3(GSCUVMContext& context)
{
	return vm_op_makevector_common(context, 3);
}

__int32 GSCUOpcodes::vm_op_makevec4(GSCUVMContext& context)
{
	return vm_op_makevector_common(context, 4);
}

__int32 GSCUOpcodes::vm_op_makevector_common(GSCUVMContext& context, int num_elements)
{
	GSCUStackVariable new_var{};
	new_var.type = GSCUVAR_VECTOR;
	new_var.value.vec.x = new_var.value.vec.y = new_var.value.vec.z = new_var.value.vec.w = 0;

	GSCUStackVariable* curr = &context.thread->stack.back();
	
	bool is_valid = true;
	// notice that the elements must be pushed in reverse order!
	for (int i = 0; i < num_elements; i++)
	{
		curr = &context.thread->stack.back();
		if (!is_valid || (curr->type != GSCUVAR_FLOAT && curr->type != GSCUVAR_INTEGER))
		{
			is_valid = false;
			goto pop;
		}

		if (curr->type == GSCUVAR_FLOAT)
		{
			new_var.value.af[i] = curr->value.f;
		}
		else
		{
			new_var.value.af[i] = (float)curr->value.int32;
		}

		pop:
		((GContext*)context.vmc)->stack_dispose(curr, context.thread);
		context.thread->stack.pop_back();
	}

	if (!is_valid)
	{
		VM_RTERROR(context, GSCU_ERROR_VM_BADVECCOMPONENTS, "invalid components supplied to make vector");
	}

	context.thread->stack.push_back(GSCUStackVariable());
	curr = &context.thread->stack.back();
	curr->type = GSCUVAR_VECTOR;
	curr->value.vec.x = new_var.value.vec.x;
	curr->value.vec.y = new_var.value.vec.y;
	curr->value.vec.z = new_var.value.vec.z;
	curr->value.vec.w = new_var.value.vec.w;

	return 0;
}

__int32 GSCUOpcodes::setfieldonstackinternal(GSCUVMContext& context, bool removeParent)
{
	GSCUStackVariable* owning_object = NULL;
	GSCUStackVariable* field_name = NULL;
	GSCUStackVariable* value_to_set = NULL;

	// stack:
	// value
	// field
	// object

	owning_object = &context.thread->stack.at(context.thread->stack.size() - 3);
	field_name = &context.thread->stack.at(context.thread->stack.size() - 2);
	value_to_set = &context.thread->stack.back();

	if (owning_object->type != GSCUVAR_REFVAR)
	{
		// value
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// field
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		if (removeParent)
		{
			// owner
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();
		}

		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "cannot set a field variable field on a variable of type %d", owning_object->type);
	}

	unsigned __int32 field_canon = 0;
	auto result = ((GContext*)context.vmc)->stack_to_canon(field_name, field_canon);

	if (result)
	{
		// val
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// field
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		if (removeParent)
		{
			// owner
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();
		}

		return result;
	}

	// check if there is a set field accessor for this var
	result = ((GContext*)context.vmc)->set_field_accessor(owning_object->value.int32, field_canon, value_to_set, context, [context, removeParent](void* other_thread_ctx)
		{
			auto other_ctx = (GSCUVMContext*)other_thread_ctx;

			// propagate the last error code so safe context also props
			if (other_ctx->thread->exit_code)
			{
				context.thread->exit_code = other_ctx->thread->exit_code;
				((GContext*)context.vmc)->last_error_code = other_ctx->thread->exit_code;
			}

			// val
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();

			// field
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();

			if (removeParent)
			{
				// owner
				((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
				context.thread->stack.pop_back();
			}

			// propagate thrown exceptions
			if (other_ctx->thread->has_flag(GSCUTF_RAISE_EXCEPTION))
			{
				context.thread->exit_code = GSCU_ERROR;
				context.thread->set_flag(GSCUTF_RAISE_EXCEPTION);

				context.thread->stack.push_back(GSCUStackVariable());
				context.thread->stack.push_back(GSCUStackVariable());
				context.thread->stack.push_back(GSCUStackVariable());

				for (int i = 0; i < 3; i++)
				{
					auto back_dest = &context.thread->stack.at(context.thread->stack.size() - 1 - i);
					auto back_src = &other_ctx->thread->stack.at(other_ctx->thread->stack.size() - 1 - i);
					((GContext*)context.vmc)->stack_set(back_dest, back_src->type, back_src->value, context.thread);
				}
			}
		});

	if (!result)
	{
		return 0;
	}

	if (result == GSCU_FIELDACCESS_SIMPLE || result < 0)
	{
		goto finished;
	}

	result = ((GContext*)context.vmc)->set_variable_field(owning_object->value.int32, field_canon, value_to_set);

finished:
	// val
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// field
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	if (removeParent)
	{
		// owner
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();
	}

	return result;
}

__int32 GSCUOpcodes::vm_op_setfieldonstack(GSCUVMContext& context)
{
	// this opcode is basically set field variable, but it gets the name from the stack.
	return setfieldonstackinternal(context, true);
}

__int32 GSCUOpcodes::threadmethodcallscript_internal(GSCUVMContext& context, __int64 fs_pos_new)
{
	// start past the method caller
	__int32 count = (__int32)context.thread->stack.size() - 2;
	__int32 index = 0;
	__int32 varcount = 0;

	// count the number of parameters
	while ((index < count) && context.thread->stack.at(count - index).type != GSCUVAR_BEGINPARAMS)
	{
		index++;
		varcount++;
	}

	auto back = &context.thread->stack.back();
	if (back->type != GSCUVAR_REFVAR)
	{
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		context.thread->stack.pop_back();

		// get rid of all the params passed to this function + the beginparams
		for (int i = 0; i <= varcount; i++)
		{
			back = &context.thread->stack.back();
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
		}

		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_VM_BADSELF, "method calls must be on ref vars.");
	}

	auto new_parent = back->value.int32;

	// pop the parent off the stack so that the params can get copied correctly
	GSCUStackVariable new_parent_var = context.thread->stack.back();
	context.thread->stack.pop_back();

	// copy parameters over to the new thread
	((GContext*)context.vmc)->stack_transfer(((GContext*)context.vmc)->get_main_thread(), context.thread, varcount, true);

	// get rid of the beginparams
	back = &context.thread->stack.back();
	((GContext*)context.vmc)->stack_dispose(back, context.thread);
	context.thread->stack.pop_back();

	auto result = ((GContext*)context.vmc)->create_thread((void*)fs_pos_new, true, context.self, varcount);

	// decrement parent pointer since it was on the stack previously
	((GContext*)context.vmc)->stack_dispose(&new_parent_var, context.thread);

	if (result < 0)
	{
		vm_op_addundefined(context);
		return result;
	}

	auto thread_id = result;

	// add a reference early so that the thread isnt disposed of
	((GContext*)context.vmc)->add_variable_ref(thread_id);

	// start the thread
	result = ((GContext*)context.vmc)->vm_execute(thread_id);

	// push a reference to the thread onto the stack
	context.thread->stack.push_back(GSCUStackVariable());
	back = &context.thread->stack.back();
	back->type = GSCUVAR_REFVAR;
	back->value.int32 = thread_id;

	return 0;
}

__int32 GSCUOpcodes::vm_op_threadmethodcallscript(GSCUVMContext& context)
{
	// this opcode changes self context, then calls a script function with new context on a new thread
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int64));
	__int64 fs_pos_new = *(__int64*)context.thread->fs_pos;
	context.thread->fs_pos += 8;
	return threadmethodcallscript_internal(context, fs_pos_new);
}

__int32 GSCUOpcodes::threadmethodcallbuiltin_internal(GSCUVMContext& context, tGSCUBuiltinFunction func)
{
	// start past the method caller
	__int32 count = (__int32)context.thread->stack.size() - 2;
	__int32 index = 0;
	__int32 varcount = 0;

	// count the number of parameters
	while ((index < count) && context.thread->stack.at(count - index).type != GSCUVAR_BEGINPARAMS)
	{
		index++;
		varcount++;
	}

	auto back = &context.thread->stack.back();
	if (back->type != GSCUVAR_REFVAR)
	{
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		context.thread->stack.pop_back();

		// get rid of all the params passed to this function + the beginparams
		for (int i = 0; i <= varcount; i++)
		{
			back = &context.thread->stack.back();
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
		}

		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_VM_BADSELF, "method calls must be on ref vars.");
	}

	auto new_parent = back->value.int32;

	// pop the parent off the stack so that the params can get copied correctly
	GSCUStackVariable new_parent_var = context.thread->stack.back();
	context.thread->stack.pop_back();

	// copy parameters over to the new thread
	((GContext*)context.vmc)->stack_transfer(((GContext*)context.vmc)->get_main_thread(), context.thread, varcount, true);

	// get rid of the beginparams
	back = &context.thread->stack.back();
	((GContext*)context.vmc)->stack_dispose(back, context.thread);
	context.thread->stack.pop_back();

	auto result = ((GContext*)context.vmc)->create_thread((void*)func, false, context.self, varcount);

	// decrement parent pointer since it was on the stack previously
	((GContext*)context.vmc)->stack_dispose(&new_parent_var, context.thread);

	if (result < 0)
	{
		vm_op_addundefined(context);
		return result;
	}

	auto thread_id = result;

	// add a reference early so that the thread isnt disposed of
	((GContext*)context.vmc)->add_variable_ref(thread_id);

	// start the thread
	result = ((GContext*)context.vmc)->vm_execute(thread_id);

	// push a reference to the thread onto the stack
	context.thread->stack.push_back(GSCUStackVariable());
	back = &context.thread->stack.back();
	back->type = GSCUVAR_REFVAR;
	back->value.int32 = thread_id;

	return 0;
}

__int32 GSCUOpcodes::vm_op_threadmethodcallbuiltin(GSCUVMContext& context)
{
	// this opcode changes self context, then calls a script function with new context on a new thread
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int64));
	__int64 fs_pos_new = *(__int64*)context.thread->fs_pos;
	context.thread->fs_pos += 8;
	return threadmethodcallbuiltin_internal(context, (tGSCUBuiltinFunction)fs_pos_new);
}

__int32 GSCUOpcodes::vm_op_endon(GSCUVMContext& context)
{
	// this opcode allows a thread to end on a list of events
	unsigned __int8 num_endons = *(unsigned __int8*)context.thread->fs_pos;
	context.thread->fs_pos += 2;

	// event_subscribers<variable, list<thread>>
	// thread dispose removes thread from subscribers list
	// variable dispose removes variable from subscribers list after notifying "delete"
	// ent notify(evt) -> foreach(thread in event_subscribers[ent]) -> thread->notify_event(evt) -> foreach(variable in thread->stack()) -> variable.event_handler? -> (waittill? stack->top().is_waittill) | (find_endon ? thread_dispose))

	// 1. subscribe event
	// 2. push endons to stack with the variable id and the event id

	auto parent_ref = &context.thread->stack.back();
	if (parent_ref->type != GSCUVAR_REFVAR)
	{
		// clear the caller
		((GContext*)context.vmc)->stack_dispose(parent_ref, context.thread);
		context.thread->stack.pop_back();

		// dispose of all the endon parameters
		for (int i = 0; i < num_endons; i++)
		{
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();
		}

		VM_RTERROR(context, GSCU_ERROR_VM_BADSELF, "endon calls must be on ref vars.");
	}

	auto parent_id = parent_ref->value.int32;

	auto result = ((GContext*)context.vmc)->subscribe_events(parent_id, context.thread->id, num_endons);

	// clear the caller
	((GContext*)context.vmc)->stack_dispose(parent_ref, context.thread);
	context.thread->stack.pop_back();
	parent_ref = NULL;

	if (result)
	{
		// dispose of all the endon parameters
		for (int i = 0; i < num_endons; i++)
		{
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();
		}
		return result;
	}

	// convert all the hashes into endon markers
	unsigned __int32 index = (__int32)context.thread->stack.size() - 1;
	for (int i = 0; i < num_endons; i++)
	{
		GSCUVarValue val{};
		auto current = &context.thread->stack.at(index - i);
		result = ((GContext*)context.vmc)->stack_to_canon64(current, val.endon.condition_hash);

		if (result)
		{
			((GContext*)context.vmc)->subscribe_events(parent_id, context.thread->id, i - num_endons);
			break;
		}

		val.endon.parent_id = parent_id;
		((GContext*)context.vmc)->stack_set(current, GSCUVAR_ENDON, val, context.thread);
	}

	if (result)
	{
		// dispose of all the endon parameters and endon markers up to that point
		for (int i = 0; i < num_endons; i++)
		{
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();
		}
	}

	return result;
}

__int32 GSCUOpcodes::vm_op_notify(GSCUVMContext& context)
{
	// this opcode notifies an event to the vm with an optional struct to pass variable data between threads.
	bool has_notify_struct = *(bool*)context.thread->fs_pos;
	context.thread->fs_pos += 2;

	// [caller]
	// [event]
	// [has_notify_struct ? struct]

	auto parent_ref = &context.thread->stack.back();
	if (parent_ref->type != GSCUVAR_REFVAR)
	{
		// clear the caller
		((GContext*)context.vmc)->stack_dispose(parent_ref, context.thread);
		context.thread->stack.pop_back();

		// clear the event
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// clear the notify struct if it exists
		if (has_notify_struct)
		{
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();
		}
		
		VM_RTERROR(context, GSCU_ERROR_VM_BADSELF, "notify calls must be on ref vars.");
	}

	auto parent_id = parent_ref->value.int32;
	GSCUStackVariable parent_val = context.thread->stack.back();

	// clear the caller without ref clearing
	context.thread->stack.pop_back();
	parent_ref = NULL;

	auto current = &context.thread->stack.back();
	unsigned __int64 event_id = 0;
	auto result = ((GContext*)context.vmc)->stack_to_canon64(current, event_id);

	// clear the event
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	if (result)
	{
		// clear parent val reference
		((GContext*)context.vmc)->stack_dispose(&parent_val, context.thread);

		// clear the notify struct if it exists
		if (has_notify_struct)
		{
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();
		}

		return result;
	}

	if (has_notify_struct)
	{
		auto back = &context.thread->stack.back();
		if (back->type != GSCUVAR_REFVAR)
		{
			// clear parent val reference
			((GContext*)context.vmc)->stack_dispose(&parent_val, context.thread);

			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();

			VM_RTERROR(context, GSCU_ERROR_RUNTIME_NOTASTRUCT, "notify argument 2 must be a struct if it is used.");
		}

		auto variable = ((GContext*)context.vmc)->api_get_variable(back->value.int32);

		if (!variable || variable->type != GSCUVAR_STRUCT)
		{
			// clear parent val reference
			((GContext*)context.vmc)->stack_dispose(&parent_val, context.thread);

			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();

			VM_RTERROR(context, GSCU_ERROR_RUNTIME_NOTASTRUCT, "notify argument 2 must be a struct if it is used.");
		}

		if (variable->value.s.classname)
		{
			// clear parent val reference
			((GContext*)context.vmc)->stack_dispose(&parent_val, context.thread);

			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();

			VM_RTERROR(context, GSCU_ERROR_RUNTIME_NOTASTRUCT, "notify argument 2 must be a classless struct");
		}
	}
	else
	{
		result = vm_op_addstruct(context);

		if (result)
		{
			return result;
		}
	}

	auto notify_struct_ref = &context.thread->stack.back();
	auto notify_struct = ((GContext*)context.vmc)->api_get_variable(notify_struct_ref->value.int32);

	GSCUStackVariable event_hash{};
	event_hash.type = GSCUVAR_HASH;
	event_hash.value.int64 = event_id;

	result = ((GContext*)context.vmc)->set_variable_field(notify_struct->id, scr_const::event, &event_hash);

	if (result)
	{
		goto finished;
	}

	result = ((GContext*)context.vmc)->set_variable_field(notify_struct->id, scr_const::object, &parent_val);

	if (result)
	{
		goto finished;
	}

	result = ((GContext*)context.vmc)->notify(parent_id, event_id, notify_struct);

finished:
	// clear parent val reference
	((GContext*)context.vmc)->stack_dispose(&parent_val, context.thread);

	// clear the notify struct
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();
	return result;
}

__int32 GSCUOpcodes::vm_op_waittill(GSCUVMContext& context)
{
	// this opcode suspends this thread and awaits a notify event.
	unsigned __int8 num_events = *(unsigned __int8*)context.thread->fs_pos;
	context.thread->fs_pos += 2;

	// 1. subscribe event
	// 2. push waittills to stack
	// 3. suspend the thread

	// [parent]
	// [events[num_notifies]]

	auto parent_ref = &context.thread->stack.back();
	if (parent_ref->type != GSCUVAR_REFVAR)
	{
		// clear the caller
		((GContext*)context.vmc)->stack_dispose(parent_ref, context.thread);
		context.thread->stack.pop_back();

		// clear the events
		for (int i = 0; i < num_events; i++)
		{
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();
		}

		VM_RTERROR(context, GSCU_ERROR_VM_BADSELF, "waittill calls must be on ref vars.");
	}

	auto parent_id = parent_ref->value.int32;
	GSCUStackVariable parent_val = context.thread->stack.back();

	// subscribe this thread to events
	auto result = ((GContext*)context.vmc)->subscribe_events(parent_id, context.thread->id, num_events);

	if (result)
	{
		// clear the events
		for (int i = 0; i < num_events; i++)
		{
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();
		}
		return result;
	}

	// clear the caller
	((GContext*)context.vmc)->stack_dispose(parent_ref, context.thread);
	context.thread->stack.pop_back();
	parent_ref = NULL;

	// convert all the hashes to waittill markers
	unsigned __int32 index = (__int32)context.thread->stack.size() - 1;
	for (int i = 0; i < num_events; i++)
	{
		GSCUVarValue val{};
		auto current = &context.thread->stack.at(index - i);
		result = ((GContext*)context.vmc)->stack_to_canon64(current, val.waittill.condition_hash);

		if (result)
		{
			((GContext*)context.vmc)->subscribe_events(parent_id, context.thread->id, i - num_events);
			break;
		}

		val.waittill.parent_id = parent_id;
		((GContext*)context.vmc)->stack_set(current, GSCUVAR_WAITTILL, val, context.thread);
	}

	if (result)
	{
		// clear the events
		for (int i = 0; i < num_events; i++)
		{
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();
		}
		return result;
	}

	context.thread->set_flag(GSCUTF_SUSPENDED);
	return 0;
}

__int32 GSCUOpcodes::vm_op_waitframe(GSCUVMContext& context)
{
	// this opcode suspends the current thread and pushes it to the wait queue
	auto back = &context.thread->stack.back();

	__int32 frames = 0;
	switch (back->type)
	{
	case GSCUVAR_FLOAT:
		frames = (__int32)(back->value.f);
		break;
	case GSCUVAR_INTEGER:
		frames = (__int32)(back->value.int32);
		break;
	default:
		VM_RTERROR(context, GSCU_ERROR_VM_BADWAITPARAM, "Expected a float or an integer for a wait. Instead, got type %d", back->type);
		break;
	}

	if (frames <= 0)
	{
		VM_RTERROR(context, GSCU_ERROR_VM_BADWAITPARAM, "cannot wait a negative or zero time.");
	}

	((GContext*)context.vmc)->suspend_thread_for_time(context.thread->id, frames * GContext::api_get_tick_rate((GContext*)context.vmc));
	return 0;
}

__int32 GSCUOpcodes::vm_op_getapifunction(GSCUVMContext& context)
{
	// this opcode gets a function pointer to a builtin api function and pushes it to the stack
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int64));
	__int64 func = *(__int64*)context.thread->fs_pos;
	context.thread->fs_pos += 8;

	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_FUNCTION;
	back->value.fn.func = func;
	back->value.fn.is_script_function = false;
	back->value.fn.captures = 0;

	return 0;
}

__int32 GSCUOpcodes::vm_op_getscriptfunction(GSCUVMContext& context)
{
	// this opcode gets a function pointer to a script function and pushes it to the stack
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, sizeof(__int64));
	__int64 func = *(__int64*)context.thread->fs_pos;
	context.thread->fs_pos += 8;

	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_FUNCTION;
	back->value.fn.func = func;
	back->value.fn.is_script_function = true;
	back->value.fn.captures = 0;

	return 0;
}

__int32 GSCUOpcodes::vm_op_callpointer(GSCUVMContext& context)
{
	// this opcode calls a script function or builtin based on the function on the stack
	auto fn = &context.thread->stack.back();
	auto type = fn->type;
	auto value = fn->value;

	// dispose of the function
	((GContext*)context.vmc)->stack_dispose(fn, context.thread);
	context.thread->stack.pop_back();

	if (type != GSCUVAR_FUNCTION)
	{
		// dispose of the arguments
		while (context.thread->stack.size())
		{
			auto back = &context.thread->stack.back();
			auto thistype = back->type;
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
			if (thistype == GSCUVAR_BEGINPARAMS)
			{
				break;
			}
		}

		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_VM_NOTAFUNCTION, "variable type %d is not a function pointer", type);
	}

	if (value.fn.is_script_function)
	{
		return callscriptfunction_internal(context, value.fn.func);
	}

	return callbuiltin_internal(context, (tGSCUBuiltinFunction)value.fn.func);
}

__int32 GSCUOpcodes::vm_op_methodcallpointer(GSCUVMContext& context)
{
	// this opcode calls a script function or builtin based on the function on the stack as a method call
	auto fn = &context.thread->stack.back();
	auto type = fn->type;
	auto value = fn->value;

	// dispose of the function
	((GContext*)context.vmc)->stack_dispose(fn, context.thread);
	context.thread->stack.pop_back();

	if (type != GSCUVAR_FUNCTION)
	{
		// dispose of the arguments
		while (context.thread->stack.size())
		{
			auto back = &context.thread->stack.back();
			auto thistype = back->type;
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
			if (thistype == GSCUVAR_BEGINPARAMS)
			{
				break;
			}
		}

		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_VM_NOTAFUNCTION, "variable type %d is not a function pointer", type);
	}

	if (value.fn.is_script_function)
	{
		return methodcallscript_internal(context, value.fn.func);
	}

	return methodcallbuiltin_internal(context, (tGSCUBuiltinFunction)value.fn.func);
}

__int32 GSCUOpcodes::vm_op_threadcallpointer(GSCUVMContext& context)
{
	// this opcode calls a script function or builtin based on the function on the stack in a new thread with an inherited caller
	auto fn = &context.thread->stack.back();
	auto type = fn->type;
	auto value = fn->value;

	// dispose of the function
	((GContext*)context.vmc)->stack_dispose(fn, context.thread);
	context.thread->stack.pop_back();

	if (type != GSCUVAR_FUNCTION)
	{
		// dispose of the arguments
		while (context.thread->stack.size())
		{
			auto back = &context.thread->stack.back();
			auto thistype = back->type;
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
			if (thistype == GSCUVAR_BEGINPARAMS)
			{
				break;
			}
		}

		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_VM_NOTAFUNCTION, "variable type %d is not a function pointer", type);
	}

	if (value.fn.is_script_function)
	{
		return threadcallscript_internal(context, value.fn.func);
	}

	return threadcallbuiltin_internal(context, (tGSCUBuiltinFunction)value.fn.func);
}

__int32 GSCUOpcodes::vm_op_threadmethodcallpointer(GSCUVMContext& context)
{
	// this opcode calls a script function or builtin based on the function on the stack in a new thread with a new caller
	auto fn = &context.thread->stack.back();
	auto type = fn->type;
	auto value = fn->value;

	// dispose of the function
	((GContext*)context.vmc)->stack_dispose(fn, context.thread);
	context.thread->stack.pop_back();

	if (type != GSCUVAR_FUNCTION)
	{
		// dispose of the arguments
		while (context.thread->stack.size())
		{
			auto back = &context.thread->stack.back();
			auto thistype = back->type;
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
			if (thistype == GSCUVAR_BEGINPARAMS)
			{
				break;
			}
		}

		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_VM_NOTAFUNCTION, "variable type %d is not a function pointer", type);
	}

	if (value.fn.is_script_function)
	{
		return threadmethodcallscript_internal(context, value.fn.func);
	}

	return threadmethodcallbuiltin_internal(context, (tGSCUBuiltinFunction)value.fn.func);
}

__int32 GSCUOpcodes::vm_op_boolnot(GSCUVMContext& context)
{
	// this opcode casts the top of the stack into a bool and negates it, if possible
	// otherwise, a cast exception fires and the function pushes false to the stack
	// the only valid types as of writing this documentation are float and int, both of which must be non-zero to be true.

	GSCUStackVariable top = context.thread->stack.back();

	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	auto result = ((GContext*)context.vmc)->cast_to_bool(&top);
	top.value.int64 = top.value.int64 == 0;
	context.thread->stack.push_back(top);

	return result;
}

__int32 GSCUOpcodes::vm_op_jump(GSCUVMContext& context)
{
	// this opcode changes the instruction pointer by a signed short value directly after the code
	context.thread->fs_pos += (__int64)2 + *(__int16*)context.thread->fs_pos;
	return 0;
}

__int32 GSCUOpcodes::vm_op_jumponfalse(GSCUVMContext& context)
{
	// this opcode consumes a stack variable condition and decides whether to use the jump short value at fspos based on that value.
	__int16 jumpAmount = *(__int16*)context.thread->fs_pos;
	context.thread->fs_pos += 2;

	GSCUStackVariable top = context.thread->stack.back();

	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	auto result = ((GContext*)context.vmc)->cast_to_bool(&top);
	top.value.int64 = top.value.int64 == 0;
	
	if (top.value.int64)
	{
		context.thread->fs_pos += jumpAmount;
	}

	return result;
}

__int32 GSCUOpcodes::vm_op_jumpontrue(GSCUVMContext& context)
{
	// this opcode consumes a stack variable condition and decides whether to use the jump short value at fspos based on that value.
	__int16 jumpAmount = *(__int16*)context.thread->fs_pos;
	context.thread->fs_pos += 2;

	GSCUStackVariable top = context.thread->stack.back();

	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	auto result = ((GContext*)context.vmc)->cast_to_bool(&top);
	top.value.int64 = top.value.int64 != 0;

	if (top.value.int64)
	{
		context.thread->fs_pos += jumpAmount;
	}

	return result;
}

__int32 GSCUOpcodes::vm_op_jumponfalseexpr(GSCUVMContext& context)
{
	// this opcode evaluates a stack variable condition and decides whether to use the jump short value at fspos based on that value.
	__int16 jumpAmount = *(__int16*)context.thread->fs_pos;
	context.thread->fs_pos += 2;

	GSCUStackVariable top = context.thread->stack.back();

	auto result = ((GContext*)context.vmc)->cast_to_bool(&top);
	top.value.int64 = top.value.int64 == 0;

	if (top.value.int64)
	{
		context.thread->fs_pos += jumpAmount;
	}

	return result;
}

__int32 GSCUOpcodes::vm_op_jumpontrueexpr(GSCUVMContext& context)
{
	// this opcode evaluates a stack variable condition and decides whether to use the jump short value at fspos based on that value.
	__int16 jumpAmount = *(__int16*)context.thread->fs_pos;
	context.thread->fs_pos += 2;

	GSCUStackVariable top = context.thread->stack.back();

	auto result = ((GContext*)context.vmc)->cast_to_bool(&top);
	top.value.int64 = top.value.int64 != 0;

	if (top.value.int64)
	{
		context.thread->fs_pos += jumpAmount;
	}

	return result;
}

__int32 GSCUOpcodes::vm_op_plus(GSCUVMContext& context)
{
	// this opcode takes two stack variables and combines them with a plus operation
	// note that this has special implications when either operand is a string and will act as an append operation instead.

	// we define the operation by the operand boxing level UNLESS there is a string operand
	// cast right operator to the required value type or quit. Note that vectors can add single elements by defining a 1D vector even though we dont technically support the underlying type.
	// possible additions:  GSCUVAR_INTEGER32 + GSCUVAR_INTEGER32
	//						GSCUVAR_FLOAT + GSCUVAR_FLOAT
	//						GSCUVAR_VECTOR + GSCUVAR_VECTOR
	//						GSCUVAR_STRING + GSCUVAR_STRING
	// int32 => float => vector => string

	// EXPLICIT ORDER: FIRST + SECOND
	auto first = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto second = &context.thread->stack.back();
	auto type1 = first->type;
	auto type2 = second->type;

	// first, validate the two types. No need to add anything if we are adding invalid types.
	if (!GSCUVars::can_add(type1, type2))
	{
		cant_add:
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// second
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// result (note: we cant return a value because we dont know what was expected in the original context; ie: string + string, int + int, etc.)
		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable types %d and %d are invalid for addition", type1, type2);
	}

	GSCUStackVariable result{};

	// second, check if any strings are present
	// we concatenate in the order first, second (stack.back, stack.back - 1)
	if (type1 == GSCUVAR_STRING || type2 == GSCUVAR_STRING)
	{
		GSCUString out_string;
		if (type1 == type2)
		{
			goto concat;
		}

		// casting work
		{
			auto non_string = first;

			if (type1 == GSCUVAR_STRING)
			{
				non_string = second;
			}

			auto return_value = ((GContext*)context.vmc)->cast_to_string(&result, non_string);

			if (return_value)
			{
				// first
				((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
				context.thread->stack.pop_back();

				// second
				((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
				context.thread->stack.pop_back();

				// result (note: we cant return a value because we dont know what was expected in the original context; ie: string + string, int + int, etc.)
				vm_op_addundefined(context);

				return return_value; // this needs to bubble because its a fatal error.
			}

			// copy the string from the cast into the non-string variable, disposing the original variable in the process
			((GContext*)context.vmc)->stack_set(non_string, result.type, result.value, context.thread);

			// dispose of result reference so we dont leak a reference
			((GContext*)context.vmc)->stack_dispose(&result, context.thread);
		}
		
		concat:
		result.type = GSCUVAR_STRING;

		auto return_value = ((GContext*)context.vmc)->string_append(out_string, &first->value.str, &second->value.str);

		if (return_value)
		{
			// first
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();

			// second
			((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
			context.thread->stack.pop_back();

			// result (note: we cant return a value because we dont know what was expected in the original context; ie: string + string, int + int, etc.)
			vm_op_addundefined(context);

			return return_value; // this needs to bubble because the concatenation failed
		}

		result.value.str = out_string;
		goto finished;
	}

	// third, check if any vectors are present
	if (type1 == GSCUVAR_VECTOR || type2 == GSCUVAR_VECTOR)
	{
		result.type = GSCUVAR_VECTOR;

		if (type1 == type2)
		{
			result.value.vec.x = first->value.vec.x + second->value.vec.x;
			result.value.vec.y = first->value.vec.y + second->value.vec.y;
			result.value.vec.z = first->value.vec.z + second->value.vec.z;
			result.value.vec.w = first->value.vec.w + second->value.vec.w;
			goto finished;
		}

		auto non_vec = first;
		auto vec = second;
		if (type1 == GSCUVAR_VECTOR)
		{
			non_vec = second;
			vec = first;
		}

		auto return_value = ((GContext*)context.vmc)->cast_to_vector(&result, non_vec);

		// this should be impossible but for stability we will consider it.
		if (return_value)
		{
			goto cant_add;
		}

		result.value.vec.x += vec->value.vec.x;
		result.value.vec.y += vec->value.vec.y;
		result.value.vec.z += vec->value.vec.z;
		result.value.vec.w += vec->value.vec.w;

		goto finished;
	}

	// fourth, check if either is a float
	if (type1 == GSCUVAR_FLOAT || type2 == GSCUVAR_FLOAT)
	{
		result.type = GSCUVAR_FLOAT;
		if (type1 == GSCUVAR_INTEGER)
		{
			result.value.f = (float)first->value.int32 + second->value.f;
		}
		else if (type1 == type2)
		{
			result.value.f = second->value.f + first->value.f;
		}
		else
		{
			result.value.f = first->value.f + (float)second->value.int32;
		}

		goto finished;
	}

	// finally, there should only be ints left
	result.type = GSCUVAR_INTEGER;
	result.value.int32 = first->value.int32 + second->value.int32;

finished:
	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type, and if it is a string, the heap manager will handle the references.
	context.thread->stack.push_back(result);
	return 0;
}

__int32 GSCUOpcodes::vm_op_minus(GSCUVMContext& context)
{
	// this opcode takes two stack variables and subtracts them with a minus operation

	// we define the operation by the operand boxing level.
	// Note that vectors can add single elements by defining a 1D vector even though we dont technically support the underlying type.
	// possible subtractions:  GSCUVAR_INTEGER32 - GSCUVAR_INTEGER32
	//						GSCUVAR_FLOAT - GSCUVAR_FLOAT
	//						GSCUVAR_VECTOR - GSCUVAR_VECTOR
	// int32 => float => vector

	// EXPLICIT ORDER: FIRST - SECOND
	auto first = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto second = &context.thread->stack.back();
	auto type1 = first->type;
	auto type2 = second->type;

	// first, validate the two types. No need to subtract anything if we are subtracting invalid types.
	if (!GSCUVars::can_subtract(type1, type2))
	{
	cant_sub:
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// second
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// result (note: we cant return a value because we dont know what was expected in the original context; ie: vec - vec, int - int, etc.)
		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable types %d and %d are invalid for subtraction", type1, type2);
	}

	GSCUStackVariable result{};

	// second, check if any vectors are present
	if (type1 == GSCUVAR_VECTOR || type2 == GSCUVAR_VECTOR)
	{
		result.type = GSCUVAR_VECTOR;

		if (type1 == type2)
		{
			result.value.vec.x = first->value.vec.x - second->value.vec.x;
			result.value.vec.y = first->value.vec.y - second->value.vec.y;
			result.value.vec.z = first->value.vec.z - second->value.vec.z;
			result.value.vec.w = first->value.vec.w - second->value.vec.w;
			goto finished;
		}

		auto non_vec = first;
		auto vec = second;
		if (type1 == GSCUVAR_VECTOR)
		{
			non_vec = second;
			vec = first;
		}

		auto return_value = ((GContext*)context.vmc)->cast_to_vector(&result, non_vec);

		// this should be impossible but for stability we will consider it.
		if (return_value)
		{
			goto cant_sub;
		}

		non_vec->type = result.type;
		non_vec->value = result.value;

		result.value.vec.x = first->value.vec.x - second->value.vec.x;
		result.value.vec.y = first->value.vec.y - second->value.vec.y;
		result.value.vec.z = first->value.vec.z - second->value.vec.z;
		result.value.vec.w = first->value.vec.w - second->value.vec.w;

		goto finished;
	}

	// third, check if either is a float
	if (type1 == GSCUVAR_FLOAT || type2 == GSCUVAR_FLOAT)
	{
		result.type = GSCUVAR_FLOAT;
		if (type1 == GSCUVAR_INTEGER)
		{
			result.value.f = (float)first->value.int32 - second->value.f;
		}
		else if (type1 == type2)
		{
			result.value.f = first->value.f - second->value.f;
		}
		else
		{
			result.value.f = first->value.f - (float)second->value.int32;
		}

		goto finished;
	}

	// finally, there should only be ints left
	result.type = GSCUVAR_INTEGER;
	result.value.int32 = first->value.int32 - second->value.int32;

finished:
	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);
	return 0;
}

__int32 GSCUOpcodes::vm_op_multiply(GSCUVMContext& context)
{
	// this opcode takes two stack variables and multiplies them
	// we define the operation by the operand boxing level.
	// Note that vectors can multiply single elements across all elements in the vector. This is equivalent to vector scaling.
	// Any other vector multiplication will multiply via Hadamard product and vector expansion. IE: vec3 * vec2 => vec4 * vec4 via Hadamard
	
	// possible multiplications:  GSCUVAR_INTEGER32 * GSCUVAR_INTEGER32
	//						GSCUVAR_FLOAT * GSCUVAR_FLOAT
	//						GSCUVAR_VECTOR * GSCUVAR_VECTOR
	//						GSCUVAR_VECTOR * GSCUVAR_FLOAT
	// int32 => float => vector

	// Order independent, however assumed FIRST * SECOND
	auto first = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto second = &context.thread->stack.back();
	auto type1 = first->type;
	auto type2 = second->type;

	// first, validate the two types. No need to mutliply anything if we are multiplying invalid types.
	if (!GSCUVars::can_multiply(type1, type2))
	{
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// second
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// result (note: we cant return a value because we dont know what was expected in the original context; ie: vec * vec, int * int, etc.)
		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable types %d and %d are invalid for multiplication", type1, type2);
	}

	GSCUStackVariable result{};

	// second, check if any vectors are present
	if (type1 == GSCUVAR_VECTOR || type2 == GSCUVAR_VECTOR)
	{
		result.type = GSCUVAR_VECTOR;

		if (type1 == type2)
		{
			result.value.vec.x = first->value.vec.x * second->value.vec.x;
			result.value.vec.y = first->value.vec.y * second->value.vec.y;
			result.value.vec.z = first->value.vec.z * second->value.vec.z;
			result.value.vec.w = first->value.vec.w * second->value.vec.w;
			goto finished;
		}

		auto non_vec = first;
		auto vec = second;
		if (type1 == GSCUVAR_VECTOR)
		{
			non_vec = second;
			vec = first;
		}

		float f_val = non_vec->value.f;
		if (non_vec->type == GSCUVAR_INTEGER)
		{
			f_val = (float)non_vec->value.int32;
		}

		result.value.vec.x = vec->value.vec.x * f_val;
		result.value.vec.y = vec->value.vec.y * f_val;
		result.value.vec.z = vec->value.vec.z * f_val;
		result.value.vec.w = vec->value.vec.w * f_val;

		goto finished;
	}

	// third, check if either is a float
	if (type1 == GSCUVAR_FLOAT || type2 == GSCUVAR_FLOAT)
	{
		result.type = GSCUVAR_FLOAT;
		if (type1 == GSCUVAR_INTEGER)
		{
			result.value.f = (float)first->value.int32 * second->value.f;
		}
		else if (type1 == type2)
		{
			result.value.f = first->value.f * second->value.f;
		}
		else
		{
			result.value.f = first->value.f * (float)second->value.int32;
		}

		goto finished;
	}

	// finally, there should only be ints left
	result.type = GSCUVAR_INTEGER;
	result.value.int32 = first->value.int32 * second->value.int32;

finished:
	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);
	return 0;
}

__int32 GSCUOpcodes::vm_op_divide(GSCUVMContext& context)
{
	// this opcode takes two stack variables and divides them
	// we define the operation by the operand boxing level.
	// Note that vectors can divide single elements across all elements in the vector. This is equivalent to inverse vector scaling.
	// The inverse scaling principle can be applied in opposite operand order too; 4 / (1, 2, 4, 8) => (4, 2, 1, 0.5)
	// Any other vector division will divide via Hadamard product and vector expansion. IE: vec3 / vec2 => vec4 * ([1, 1, 1, 1] / vec4) via Hadamard

	// possible divisions:  GSCUVAR_INTEGER32 / GSCUVAR_INTEGER32
	//						GSCUVAR_FLOAT / GSCUVAR_FLOAT
	//						GSCUVAR_VECTOR / GSCUVAR_VECTOR
	//						GSCUVAR_VECTOR / GSCUVAR_FLOAT
	// int32 => float => vector

	// ORDER EXPLICIT: FIRST / SECOND

	// NOTE: Due to arithmatic complexity around 0, the vm will throw an arithmatic error when trying to divide by zero.

	auto first = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto second = &context.thread->stack.back();
	auto type1 = first->type;
	auto type2 = second->type;

	// first, validate the two types. No need to divide anything if we are dividing invalid types.
	if (!GSCUVars::can_divide(type1, type2))
	{
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// second
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// result (note: we cant return a value because we dont know what was expected in the original context; ie: vec / vec, int / int, etc.)
		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable types %d and %d are invalid for division", type1, type2);
	}

	GSCUStackVariable result{};

	// second, check if any vectors are present
	if (type1 == GSCUVAR_VECTOR || type2 == GSCUVAR_VECTOR)
	{
		result.type = GSCUVAR_VECTOR;
		result.value.vec.x = 0;
		result.value.vec.y = 0;
		result.value.vec.z = 0;
		result.value.vec.w = 0;

		// NOTE: this behavior can be a bit odd because we have to consider vectors who have 0 elems in both positions (ie: vec2 / vec2 => vec2, but elem 2 and 3 are 0 in vec4 struct (0 / 0))
		// The expected behavior of a developer is to disregard those elements and forward to 0.
		// In places where an arithmatic error would happen, for vec / vec ONLY, 0 will be the result (ie: vector downsizing)
		if (type1 == type2)
		{
			vec_div:
			if (second->value.vec.x)
			{
				result.value.vec.x = first->value.vec.x / second->value.vec.x;
			}
			
			if (second->value.vec.y)
			{
				result.value.vec.y = first->value.vec.y / second->value.vec.y;
			}
			
			if (second->value.vec.z)
			{
				result.value.vec.z = first->value.vec.z / second->value.vec.z;
			}
			
			if (second->value.vec.w)
			{
				result.value.vec.w = first->value.vec.w / second->value.vec.w;
			}
			
			goto finished;
		}

		// now we need to consider order dependent scaling
		// the best way to do this is to change the type of the non vector based on its position such that the original vector logic works
		// arithmatic error will get thrown only if we try doing vec / 0i or vec / 0f. 

		if (type2 == GSCUVAR_FLOAT || type2 == GSCUVAR_INTEGER)
		{
			auto fval = (type2 == GSCUVAR_INTEGER) ? (float)second->value.int32 : second->value.f;

			if (fval == 0.0f)
			{
				goto div_by_zero;
			}

			second->type = GSCUVAR_VECTOR;
			second->value.vec.x = fval;
			second->value.vec.y = fval;
			second->value.vec.z = fval;
			second->value.vec.w = fval;

			goto vec_div;
		}

		// guaranteed to have a float or integer as param 1
		// lets simply expand the value to a vector
		auto f1val = (type1 == GSCUVAR_INTEGER) ? (float)first->value.int32 : first->value.f;

		first->type = GSCUVAR_VECTOR;
		first->value.vec.x = f1val;
		first->value.vec.y = f1val;
		first->value.vec.z = f1val;
		first->value.vec.w = f1val;

		goto vec_div;
	}

	// third, check if either is a float
	if (type1 == GSCUVAR_FLOAT || type2 == GSCUVAR_FLOAT)
	{
		result.type = GSCUVAR_FLOAT;
		if (type1 == GSCUVAR_INTEGER)
		{
			if (second->value.f == 0.0f)
			{
				goto div_by_zero;
			}
			result.value.f = (float)first->value.int32 / second->value.f;
		}
		else if (type1 == type2)
		{
			if (second->value.f == 0.0f)
			{
				goto div_by_zero;
			}

			result.value.f = first->value.f / second->value.f;
		}
		else
		{
			if (!second->value.int32)
			{
				goto div_by_zero;
			}

			result.value.f = first->value.f / (float)second->value.int32;
		}

		goto finished;
	}

	// finally, there should only be ints left
	if (!second->value.int32)
	{
		goto div_by_zero;
	}

	// NOTE: all division operations result in a float of some kind
	result.type = GSCUVAR_FLOAT;
	result.value.f = (float)first->value.int32 / (float)second->value.int32;

finished:
	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);
	return 0;

div_by_zero:
	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// result (note: we cant return a value because we dont know what was expected in the original context; ie: vec / vec, int / int, etc.)
	vm_op_addundefined(context);

	VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "arithmatic error: division by 0 detected");
}

__int32 GSCUOpcodes::vm_op_modulo(GSCUVMContext& context)
{
	// this opcode performs a modulo operation on its operands (2 stack variables) -- that is, a division, returning the remainder after. fmod is automatically extrapolated
	// this opcode is extremely similar to the division opcode's behavior

	// we define the operation by the operand boxing level.
	// Note that vectors can divide single elements across all elements in the vector. This is equivalent to inverse vector scaling.
	// The inverse scaling principle can be applied in opposite operand order too; 4 % (1, 2, 4, 8) => (0, 0, 0, 4)
	// Any other vector division will divide via Hadamard product and vector expansion. IE: vec3 % vec2 => vec4 % vec4 via Hadamard

	// possible modolos:    GSCUVAR_INTEGER32 / GSCUVAR_INTEGER32
	//						GSCUVAR_FLOAT / GSCUVAR_FLOAT
	//						GSCUVAR_VECTOR / GSCUVAR_VECTOR
	//						GSCUVAR_VECTOR / GSCUVAR_FLOAT
	// int32 => float => vector

	// ORDER EXPLICIT: FIRST % SECOND

	// NOTE: Due to arithmatic complexity around 0, the vm will throw an arithmatic error when trying to divide by zero.

	auto first = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto second = &context.thread->stack.back();
	auto type1 = first->type;
	auto type2 = second->type;

	// first, validate the two types. No need to divide anything if we are dividing invalid types.
	if (!GSCUVars::can_divide(type1, type2))
	{
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// second
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// result (note: we cant return a value because we dont know what was expected in the original context; ie: vec / vec, int / int, etc.)
		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable types %d and %d are invalid for modulo operations", type1, type2);
	}

	GSCUStackVariable result{};

	// second, check if any vectors are present
	if (type1 == GSCUVAR_VECTOR || type2 == GSCUVAR_VECTOR)
	{
		result.type = GSCUVAR_VECTOR;
		result.value.vec.x = 0;
		result.value.vec.y = 0;
		result.value.vec.z = 0;
		result.value.vec.w = 0;

		// NOTE: this behavior can be a bit odd because we have to consider vectors who have 0 elems in both positions (ie: vec2 / vec2 => vec2, but elem 2 and 3 are 0 in vec4 struct (0 / 0))
		// The expected behavior of a developer is to disregard those elements and forward to 0.
		// In places where an arithmatic error would happen, for vec / vec ONLY, 0 will be the result (ie: vector downsizing)
		if (type1 == type2)
		{
		vec_div:
			if (second->value.vec.x)
			{
				result.value.vec.x = fmod(first->value.vec.x, second->value.vec.x);
			}

			if (second->value.vec.y)
			{
				result.value.vec.y = fmod(first->value.vec.y, second->value.vec.y);
			}

			if (second->value.vec.z)
			{
				result.value.vec.z = fmod(first->value.vec.z, second->value.vec.z);
			}

			if (second->value.vec.w)
			{
				result.value.vec.w = fmod(first->value.vec.w, second->value.vec.w);
			}

			goto finished;
		}

		// now we need to consider order dependent scaling
		// the best way to do this is to change the type of the non vector based on its position such that the original vector logic works
		// arithmatic error will get thrown only if we try doing vec / 0i or vec / 0f. 

		if (type2 == GSCUVAR_FLOAT || type2 == GSCUVAR_INTEGER)
		{
			auto fval = (type2 == GSCUVAR_INTEGER) ? (float)second->value.int32 : second->value.f;

			if (fval == 0.0f)
			{
				goto div_by_zero;
			}

			second->type = GSCUVAR_VECTOR;
			second->value.vec.x = fval;
			second->value.vec.y = fval;
			second->value.vec.z = fval;
			second->value.vec.w = fval;

			goto vec_div;
		}

		// guaranteed to have a float or integer as param 1
		// lets simply expand the value to a vector
		auto f1val = (type1 == GSCUVAR_INTEGER) ? (float)first->value.int32 : first->value.f;

		first->type = GSCUVAR_VECTOR;
		first->value.vec.x = f1val;
		first->value.vec.y = f1val;
		first->value.vec.z = f1val;
		first->value.vec.w = f1val;

		goto vec_div;
	}

	// third, check if either is a float
	if (type1 == GSCUVAR_FLOAT || type2 == GSCUVAR_FLOAT)
	{
		result.type = GSCUVAR_FLOAT;
		if (type1 == GSCUVAR_INTEGER)
		{
			if (second->value.f == 0.0f)
			{
				goto div_by_zero;
			}
			result.value.f = fmod((float)first->value.int32, second->value.f);
		}
		else if (type1 == type2)
		{
			if (second->value.f == 0.0f)
			{
				goto div_by_zero;
			}

			result.value.f = fmod(first->value.f, second->value.f);
		}
		else
		{
			if (!second->value.int32)
			{
				goto div_by_zero;
			}

			result.value.f = fmod(first->value.f, (float)second->value.int32);
		}

		goto finished;
	}

	// finally, there should only be ints left
	if (!second->value.int32)
	{
		goto div_by_zero;
	}

	result.type = GSCUVAR_INTEGER;
	result.value.int32 = first->value.int32 % second->value.int32;

finished:
	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);
	return 0;

div_by_zero:
	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// result (note: we cant return a value because we dont know what was expected in the original context; ie: vec / vec, int / int, etc.)
	vm_op_addundefined(context);

	VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "arithmatic error: division by 0 detected (modulo operation)");
}

__int32 GSCUOpcodes::vm_op_bitshiftleft(GSCUVMContext& context)
{
	// this operation takes two stack variables and performs a bit left shift. both parameters need to be integers

	// explicit ordering: FIRST << SECOND
	auto first = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto second = &context.thread->stack.back();
	auto type1 = first->type;
	auto type2 = second->type;

	if (!((type1 == type2) && type1 == GSCUVAR_INTEGER))
	{
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// second
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// because this is an erroneous bitshift, we arent going to push a default value.
		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable types %d and %d are invalid for bitshift operations", type1, type2);
	}

	GSCUStackVariable result{};
	result.type = GSCUVAR_INTEGER;
	result.value.int32 = first->value.int32 << second->value.int32;

	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);
	return 0;
}

__int32 GSCUOpcodes::vm_op_bitshiftright(GSCUVMContext& context)
{
	// this operation takes two stack variables and performs a bit right shift. both parameters need to be integers

	// explicit ordering: FIRST >> SECOND
	auto first = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto second = &context.thread->stack.back();
	auto type1 = first->type;
	auto type2 = second->type;

	if (!((type1 == type2) && type1 == GSCUVAR_INTEGER))
	{
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// second
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// because this is an erroneous bitshift, we arent going to push a default value.
		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable types %d and %d are invalid for bitshift operations", type1, type2);
	}

	GSCUStackVariable result{};
	result.type = GSCUVAR_INTEGER;
	result.value.int32 = first->value.int32 >> second->value.int32;

	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);
	return 0;
}

__int32 GSCUOpcodes::vm_op_bitand(GSCUVMContext& context)
{
	// this operation takes two stack variables and performs a bitwise and. both parameters need to be integers

	// independent ordering: FIRST & SECOND
	auto first = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto second = &context.thread->stack.back();
	auto type1 = first->type;
	auto type2 = second->type;

	if (!((type1 == type2) && type1 == GSCUVAR_INTEGER))
	{
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// second
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// because this is an erroneous bitand, we arent going to push a default value.
		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable types %d and %d are invalid for bitwise operations", type1, type2);
	}

	GSCUStackVariable result{};
	result.type = GSCUVAR_INTEGER;
	result.value.int32 = first->value.int32 & second->value.int32;

	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);
	return 0;
}

__int32 GSCUOpcodes::vm_op_bitor(GSCUVMContext& context)
{
	// this operation takes two stack variables and performs a bitwise or. both parameters need to be integers

	// independent ordering: FIRST | SECOND
	auto first = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto second = &context.thread->stack.back();
	auto type1 = first->type;
	auto type2 = second->type;

	if (!((type1 == type2) && type1 == GSCUVAR_INTEGER))
	{
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// second
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// because this is an erroneous bitor, we arent going to push a default value.
		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable types %d and %d are invalid for bitwise operations", type1, type2);
	}

	GSCUStackVariable result{};
	result.type = GSCUVAR_INTEGER;
	result.value.int32 = first->value.int32 | second->value.int32;

	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);
	return 0;
}

__int32 GSCUOpcodes::vm_op_bitxor(GSCUVMContext& context)
{
	// this operation takes two stack variables and performs a bitwise xor. both parameters need to be integers

	// independent ordering: FIRST ^ SECOND
	auto first = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto second = &context.thread->stack.back();
	auto type1 = first->type;
	auto type2 = second->type;

	if (!((type1 == type2) && type1 == GSCUVAR_INTEGER))
	{
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// second
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// because this is an erroneous bitxor, we arent going to push a default value.
		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable types %d and %d are invalid for bitwise operations", type1, type2);
	}

	GSCUStackVariable result{};
	result.type = GSCUVAR_INTEGER;
	result.value.int32 = first->value.int32 ^ second->value.int32;

	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);
	return 0;
}

__int32 GSCUOpcodes::vm_op_bitnegate(GSCUVMContext& context)
{
	// this operation takes a single stack variable and performs a bitwise negation. the variable must be an integer

	auto first = &context.thread->stack.back();
	auto type1 = first->type;

	if (type1 != GSCUVAR_INTEGER)
	{
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// because this is an erroneous bitshift, we arent going to push a default value.
		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable type %d is invalid for bitwise negation", type1);
	}

	GSCUStackVariable result{};
	result.type = GSCUVAR_INTEGER;
	result.value.int32 = ~first->value.int32;

	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);
	return 0;
}

bool GSCUOpcodes::equals_internal(GSCUStackVariable* first, GSCUStackVariable* second, bool requireTypeMatch)
{
	auto type1 = first->type;
	auto type2 = second->type;

	if (requireTypeMatch && type1 != type2)
	{
		return false;
	}

	switch (type1)
	{
		case GSCUVAR_UNDEFINED:
			return type2 == GSCUVAR_UNDEFINED;

		case GSCUVAR_STRING:
			if (type2 != GSCUVAR_STRING)
			{
				return false;
			}
			return strcmp(first->value.str.str_ref, second->value.str.str_ref) == 0;

		case GSCUVAR_INTEGER:
			if (type2 == GSCUVAR_FLOAT)
			{
				return (float)first->value.int32 == second->value.f;
			}
			return first->value.int32 == second->value.int32;

		case GSCUVAR_FLOAT:
			if (type2 == GSCUVAR_INTEGER)
			{
				return first->value.f == (float)second->value.int32;
			}
			return first->value.f == second->value.f;

		case GSCUVAR_FUNCTION:
			return first->value.fn.func == second->value.fn.func && first->value.fn.captures == second->value.fn.captures;

		default:
			return !((first->value.di64.a - second->value.di64.a) | (first->value.di64.b - second->value.di64.b));
	}
}

__int32 GSCUOpcodes::vm_op_equals(GSCUVMContext& context)
{
	// this opcode compares equality on two stack variables. behavior for each type is defined in this opcode implementation.
	// if any param is undefined, both must be undefined or this will return false
	// if any param is a string, both must be strings and must have equal values, case sensitively.
	// any other variable must have equal values (all 16 bytes in the value must match)

	// independent ordering: FIRST == SECOND
	auto first = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto second = &context.thread->stack.back();
	

	GSCUStackVariable result{};
	result.type = GSCUVAR_INTEGER;
	result.value.int32 = equals_internal(first, second, false);

	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);

	return 0;
}

__int32 GSCUOpcodes::vm_op_notequals(GSCUVMContext& context)
{
	// this opcode compares equality and negates the return condition
	auto result = vm_op_equals(context);

	if (result)
	{
		return result;
	}

	context.thread->stack.back().value.int32 = context.thread->stack.back().value.int32 == 0;

	return 0;
}

__int32 GSCUOpcodes::vm_op_superequals(GSCUVMContext& context)
{
	// this opcode compares equality on two stack variables. behavior for each type is defined in this opcode implementation.
	// parameters must equal in both type and value.

	// independent ordering: FIRST === SECOND
	auto first = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto second = &context.thread->stack.back();


	GSCUStackVariable result{};
	result.type = GSCUVAR_INTEGER;
	result.value.int32 = equals_internal(first, second, true);

	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);

	return 0;
}

__int32 GSCUOpcodes::vm_op_supernotequals(GSCUVMContext& context)
{
	// this opcode compares super equality and negates the return condition
	auto result = vm_op_superequals(context);

	if (result)
	{
		return result;
	}

	context.thread->stack.back().value.int32 = context.thread->stack.back().value.int32 == 0;

	return 0;
}

__int32 GSCUOpcodes::vm_op_greaterthan(GSCUVMContext& context)
{
	// this opcode compares two values and determines if the first value is greater than the second
	// note that this is only valid on numerical operands. It makes no sense to ask which string is greater, nor does it make sense to ask which thread is greater, etc.

	// note that boxing will occur: int -> float
	
	// explicit ordering: FIRST > SECOND
	auto first = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto second = &context.thread->stack.back();
	auto type1 = first->type;
	auto type2 = second->type;

	if (type1 != GSCUVAR_INTEGER && type1 != GSCUVAR_FLOAT)
	{
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// second
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable type %d is invalid for numerical comparison", type1);
	}

	if (type2 != GSCUVAR_INTEGER && type2 != GSCUVAR_FLOAT)
	{
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// second
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable type %d is invalid for numerical comparison", type2);
	}

	GSCUStackVariable result{};
	result.type = GSCUVAR_INTEGER;
	result.value.int32 = 0;

	if (type1 == GSCUVAR_FLOAT || type2 == GSCUVAR_FLOAT)
	{
		if (type1 == type2)
		{
			result.value.int32 = first->value.f > second->value.f;
			goto success;
		}

		if (type1 == GSCUVAR_FLOAT)
		{
			result.value.int32 = first->value.f > (float)second->value.int32;
			goto success;
		}

		result.value.int32 = (float)first->value.int32 > second->value.f;
		goto success;
	}

	result.value.int32 = first->value.int32 > second->value.int32;
	
	success:
	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);

	return 0;
}

__int32 GSCUOpcodes::vm_op_lessthanequalto(GSCUVMContext& context)
{
	// this opcode compares two values and determines if the first value is less than or equal to second
	auto result = vm_op_greaterthan(context);

	if (result)
	{
		return result;
	}

	context.thread->stack.back().value.int32 = context.thread->stack.back().value.int32 == 0;
	return 0;
}

__int32 GSCUOpcodes::vm_op_lessthan(GSCUVMContext& context)
{
	// this opcode compares two values and determines if the first value is less than the second
	// note that this is only valid on numerical operands. It makes no sense to ask which string is greater, nor does it make sense to ask which thread is greater, etc.

	// note that boxing will occur: int -> float

	// explicit ordering: FIRST < SECOND
	auto first = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto second = &context.thread->stack.back();
	auto type1 = first->type;
	auto type2 = second->type;

	if (type1 != GSCUVAR_INTEGER && type1 != GSCUVAR_FLOAT)
	{
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// second
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable type %d is invalid for numerical comparison", type1);
	}

	if (type2 != GSCUVAR_INTEGER && type2 != GSCUVAR_FLOAT)
	{
		// first
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		// second
		((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
		context.thread->stack.pop_back();

		vm_op_addundefined(context);

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable type %d is invalid for numerical comparison", type2);
	}

	GSCUStackVariable result{};
	result.type = GSCUVAR_INTEGER;
	result.value.int32 = 0;

	if (type1 == GSCUVAR_FLOAT || type2 == GSCUVAR_FLOAT)
	{
		if (type1 == type2)
		{
			result.value.int32 = first->value.f < second->value.f;
			goto success;
		}

		if (type1 == GSCUVAR_FLOAT)
		{
			result.value.int32 = first->value.f < (float)second->value.int32;
			goto success;
		}

		result.value.int32 = (float)first->value.int32 < second->value.f;
		goto success;
	}

	result.value.int32 = first->value.int32 < second->value.int32;

success:
	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// second
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);

	return 0;
}

__int32 GSCUOpcodes::vm_op_greaterthanequalto(GSCUVMContext& context)
{
	// this opcode compares two values and determines if the first value is greater than or equal to second
	auto result = vm_op_lessthan(context);

	if (result)
	{
		return result;
	}

	context.thread->stack.back().value.int32 = context.thread->stack.back().value.int32 == 0;
	return 0;
}

__int32 GSCUOpcodes::vm_op_sizeof(GSCUVMContext& context)
{
	// this opcode pushes an integer (or float for vector) to the stack based on the input variable about the size of the object.
	// note that this returns 0 for any invalid type and does not throw an error

	auto back = &context.thread->stack.back();

	GSCUStackVariable result{};
	result.type = GSCUVAR_INTEGER;
	result.value.int32 = 0;

	switch (back->type)
	{
		case GSCUVAR_STRING:
			result.value.int32 = back->value.str.size;
		break;

		case GSCUVAR_VECTOR:
			result.type = GSCUVAR_FLOAT;
			result.value.f = GSCUVars::vector_length(back->value.vec);
		break;

		case GSCUVAR_REFVAR:
			((GContext*)context.vmc)->sizeof_variable(back->value.int32, result, context);
		break;

		default:
			break;
	}

	// first
	((GContext*)context.vmc)->stack_dispose(&context.thread->stack.back(), context.thread);
	context.thread->stack.pop_back();

	// no need to manage refs or anything because its guaranteed to be a by-value type
	context.thread->stack.push_back(result);

	return 0;
}

__int32 GSCUOpcodes::vm_op_vmtime(GSCUVMContext& context)
{
	// this opcode pushes the vm time to the stack of the current thread

	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_INTEGER;
	back->value.int32 = ((GContext*)context.vmc)->get_time();

	return 0;
}

__int32 GSCUOpcodes::vm_op_incfield(GSCUVMContext& context)
{
	// this opcode takes an integer input and increases it by 1
	// requires an object on the stack, an i8 argument declaring whether to push to the stack before or after inc, and an i32 fieldname.

	bool shouldPushFirst = *(unsigned __int8*)(context.thread->fs_pos);
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos + 1, 4);

	__int32 field = *(__int32*)context.thread->fs_pos;
	context.thread->fs_pos += 4;

	auto back = &context.thread->stack.back();

	if (back->type != GSCUVAR_REFVAR)
	{
		// owning object
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		back->type = GSCUVAR_UNDEFINED;
		back->value.int64 = 0;

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_NOTASTRUCT, "variable %d is not a struct (increment)", back->type);
	}

	auto var = ((GContext*)context.vmc)->api_get_variable(back->value.int32);

	if (!var || var->type != GSCUVAR_STRUCT)
	{
		// owning object
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		back->type = GSCUVAR_UNDEFINED;
		back->value.int64 = 0;

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_NOTASTRUCT, "variable %d (heap) is not a struct (increment)", var ? var->type : GSCUVAR_FREE);
	}

	if (((GContext*)context.vmc)->is_class_field_prop(var->value.s.classname, field))
	{
		// owning object
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		back->type = GSCUVAR_UNDEFINED;
		back->value.int64 = 0;

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "cannot perform increment on properties and methods");
	}

	GSCUStackVariable out{};

	((GContext*)context.vmc)->get_variable_field(back->value.int32, field, &out);
	
	__int32 val = out.value.int32;
	auto _type = out.type;

	if (_type != GSCUVAR_INTEGER)
	{
		// owning object
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		back->type = GSCUVAR_UNDEFINED;
		back->value.int64 = 0;

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable type %d is invalid for integer increment", _type);
	}
	
	++out.value.int32;

	auto result = ((GContext*)context.vmc)->set_variable_field(back->value.int32, field, &out);

	// owning object
	((GContext*)context.vmc)->stack_dispose(back, context.thread);
	back->type = GSCUVAR_UNDEFINED;
	back->value.int64 = 0;

	if (result)
	{
		return result;
	}

	back->type = GSCUVAR_INTEGER;
	back->value.int32 = shouldPushFirst ? val : out.value.int32;

	return 0;
}

__int32 GSCUOpcodes::vm_op_decfield(GSCUVMContext& context)
{
	// this opcode takes an integer input and decreases it by 1
	// requires an object on the stack, an i8 argument declaring whether to push to the stack before or after dec, and an i32 fieldname.

	bool shouldPushFirst = *(unsigned __int8*)(context.thread->fs_pos);
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos + 1, 4);

	__int32 field = *(__int32*)context.thread->fs_pos;
	context.thread->fs_pos += 4;

	auto back = &context.thread->stack.back();

	if (back->type != GSCUVAR_REFVAR)
	{
		// owning object
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		back->type = GSCUVAR_UNDEFINED;
		back->value.int64 = 0;

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_NOTASTRUCT, "variable %d is not a struct (decrement)", back->type);
	}

	auto var = ((GContext*)context.vmc)->api_get_variable(back->value.int32);

	if (!var || var->type != GSCUVAR_STRUCT)
	{
		// owning object
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		back->type = GSCUVAR_UNDEFINED;
		back->value.int64 = 0;

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_NOTASTRUCT, "variable %d (heap) is not a struct (decrement)", var ? var->type : GSCUVAR_FREE);
	}

	if (((GContext*)context.vmc)->is_class_field_prop(var->value.s.classname, field))
	{
		// owning object
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		back->type = GSCUVAR_UNDEFINED;
		back->value.int64 = 0;

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "cannot perform decrement on properties and methods");
	}

	GSCUStackVariable out{};

	((GContext*)context.vmc)->get_variable_field(back->value.int32, field, &out);

	__int32 val = out.value.int32;
	auto _type = out.type;

	if (_type != GSCUVAR_INTEGER)
	{
		// owning object
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		back->type = GSCUVAR_UNDEFINED;
		back->value.int64 = 0;

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable type %d is invalid for integer decrement", _type);
	}

	--out.value.int32;

	auto result = ((GContext*)context.vmc)->set_variable_field(back->value.int32, field, &out);

	// owning object
	((GContext*)context.vmc)->stack_dispose(back, context.thread);
	back->type = GSCUVAR_UNDEFINED;
	back->value.int64 = 0;

	if (result)
	{
		return result;
	}

	back->type = GSCUVAR_INTEGER;
	back->value.int32 = shouldPushFirst ? val : out.value.int32;

	return 0;
}

__int32 GSCUOpcodes::vm_op_inclocal(GSCUVMContext& context)
{
	// this opcode takes a local variable index as an input and will increment its value
	// the variable must be an integer or the vm will error

	unsigned __int8 index = *(unsigned __int8*)context.thread->fs_pos;
	bool shouldPushFirst = *(unsigned __int8*)(context.thread->fs_pos + 1);

	context.thread->fs_pos += 2;

	if (!context.thread->start_locals)
	{
		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "tried to access a local variable when none exist");
	}

	if ((context.thread->start_locals + index) >= context.thread->stack.size())
	{
		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "tried to access a local variable outside of the boundaries of the stack");
	}

	__int16 stack_index = context.thread->start_locals + index;
	auto local = &context.thread->stack.at(stack_index);
	
	auto b_type = local->type;
	auto b_val = local->value.int32;

	switch (b_type)
	{
		case GSCUVAR_INTEGER:
			b_val = shouldPushFirst ? local->value.int32++ : ++(local->value.int32);
			break;

		default:
			VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable type %d is invalid for integer increment", b_type);
	}

	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = b_type;
	back->value.int32 = b_val;

	return 0;
}

__int32 GSCUOpcodes::vm_op_declocal(GSCUVMContext& context)
{
	// this opcode takes a local variable index as an input and will decrement its value
	// the variable must be an integer or the vm will error

	unsigned __int8 index = *(unsigned __int8*)context.thread->fs_pos;
	bool shouldPushFirst = *(unsigned __int8*)(context.thread->fs_pos + 1);
	context.thread->fs_pos += 2;

	if (!context.thread->start_locals)
	{
		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "tried to access a local variable when none exist");
	}

	if ((context.thread->start_locals + index) >= context.thread->stack.size())
	{
		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "tried to access a local variable outside of the boundaries of the stack");
	}

	__int16 stack_index = context.thread->start_locals + index;
	auto local = &context.thread->stack.at(stack_index);

	auto b_type = local->type;
	auto b_val = local->value.int32;

	switch (b_type)
	{
		case GSCUVAR_INTEGER:
			b_val = shouldPushFirst ? local->value.int32-- : --(local->value.int32);
		break;

		default:
			VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "variable type %d is invalid for integer increment", b_type);
	}

	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = b_type;
	back->value.int32 = b_val;

	return 0;
}

__int32 GSCUOpcodes::vm_op_isdefined(GSCUVMContext& context)
{
	// this opcode checks a stack variable value to see if it is defined
	// the opcode will push the result as an integer to the stack

	auto back = &context.thread->stack.back();
	auto b_type = back->type;
	auto b_val = back->value;

	GSCUStackVariable result{};
	result.type = GSCUVAR_INTEGER;

	switch (b_type)
	{
		case GSCUVAR_FREE:
		case GSCUVAR_UNDEFINED:
			result.value.int32 = false;
			break;

		case GSCUVAR_REFVAR:
		{
			auto hvar = ((GContext*)context.vmc)->api_get_variable(b_val.int32);
			if (!hvar || hvar->type == GSCUVAR_UNDEFINED || hvar->type == GSCUVAR_FREE)
			{
				result.value.int32 = false;
				break;
			}
			result.value.int32 = true;
		}
		break;

		default:
			result.value.int32 = true;
			break;
	}

	((GContext*)context.vmc)->stack_dispose(back, context.thread);
	context.thread->stack.pop_back();

	context.thread->stack.push_back(result);
	return 0;
}

__int32 GSCUOpcodes::vm_op_getglobalvariable(GSCUVMContext& context)
{
	// this opcode will push a reference to a global variable onto the stack
	// note: we never need to eval this... a global variable cant be used like a value type anyways!

	unsigned __int16 id = *(unsigned __int16*)context.thread->fs_pos;
	context.thread->fs_pos += 2;

	GSCUStackVariable result{};
	result.type = GSCUVAR_REFVAR;

	auto hvar = ((GContext*)context.vmc)->api_get_variable(id);

	if (!hvar)
	{
		VM_RTERROR(context, GSCU_ERROR_RUNTIME_UNKNOWNVAR, "tried to get a reference to a non-existant global. this most likely indicates a linking error or a memory corruption");
	}

	((GContext*)context.vmc)->add_variable_ref(id);
	result.value.int32 = id;
	context.thread->stack.push_back(result);

	return 0;
}

__int32 GSCUOpcodes::vm_op_firstfield(GSCUVMContext& context)
{
	// this opcode takes a struct ref from the stack and grabs its first array field, then pushes a ref to that field onto the stack, or undefined if none exists

	auto back = &context.thread->stack.back();

	GSCUStackVariable result{};
	result.type = GSCUVAR_UNDEFINED;
	result.value.int64 = 0;

	if (back->type != GSCUVAR_REFVAR)
	{
		((GContext*)context.vmc)->stack_set(&context.thread->stack.back(), result.type, result.value, context.thread);
		VM_RTERROR(context, GSCU_ERROR_RUNTIME_NOTASTRUCT, "cannot get field of non-ref var");
	}

	auto struct_var = ((GContext*)context.vmc)->api_get_variable(back->value.int32);

	if (!struct_var || struct_var->type != GSCUVAR_STRUCT)
	{
		((GContext*)context.vmc)->stack_set(&context.thread->stack.back(), result.type, result.value, context.thread);
		VM_RTERROR(context, GSCU_ERROR_RUNTIME_NOTASTRUCT, "cannot get field of non-struct var");
	}	

	result.type = GSCUVAR_ITERATOR2;
	result.value.it.var_id = struct_var->id;
	((GContext*)context.vmc)->add_variable_ref(struct_var->id);
	result.value.it.index = 0;

	if (struct_var->value.s.classname != scr_const::array)
	{
		result.value.it.keys = new std::vector<unsigned __int32>();
		result.value.it.keys->reserve(struct_var->value.s.native.s->size());
		for (auto& kv : *struct_var->value.s.native.s)
		{
			result.value.it.keys->push_back(kv.first);
		}
	}

finished:
	((GContext*)context.vmc)->stack_set(&context.thread->stack.back(), result.type, result.value, context.thread);

	return 0;
}

__int32 GSCUOpcodes::vm_op_nextfield(GSCUVMContext& context)
{
	// this opcode takes an existing field and looks for the next field in the context. If not found, returns undefined.

	auto back = &context.thread->stack.back();

	GSCUStackVariable result{};
	result.type = GSCUVAR_UNDEFINED;
	result.value.int64 = 0;

	if (back->type != GSCUVAR_ITERATOR2)
	{
		goto finished;
	}

	{

		auto var = ((GContext*)context.vmc)->api_get_variable(back->value.it.var_id);

		if (var->type != GSCUVAR_STRUCT)
		{
			goto finished;
		}
		
		back->value.it.index++;
		if (var->value.s.classname == scr_const::array)
		{
			if (back->value.it.index >= var->value.s.native.a->size())
			{
				goto finished;
			}
		}
		else
		{
			if (back->value.it.index >= back->value.it.keys->size())
			{
				goto finished;
			}
		}
		return 0; // dont change the back stack because we just ++'d the iterator
	}

	finished:
	((GContext*)context.vmc)->stack_set(&context.thread->stack.back(), result.type, result.value, context.thread);
	return 0;
}

__int32 GSCUOpcodes::vm_op_getfieldvalue(GSCUVMContext& context)
{
	// this opcode tries to follow a field reference and either pushes its value to the stack or pushes undefined

	auto back = &context.thread->stack.back();

	GSCUStackVariable result{};
	result.type = GSCUVAR_UNDEFINED;
	result.value.int64 = 0;

	if (back->type != GSCUVAR_ITERATOR2)
	{
		goto finished;
	}

	{
		GSCUHeapVariable* var_value = NULL;
		
		auto data_structure = ((GContext*)context.vmc)->api_get_variable(back->value.it.var_id);

		if (data_structure->type != GSCUVAR_STRUCT)
		{
			goto finished;
		}

		if(data_structure->value.s.classname == scr_const::array)
		{
			if (data_structure->value.s.native.a->size() <= back->value.it.index)
			{
				goto finished;
			}
			auto id = (*data_structure->value.s.native.a)[back->value.it.index];
			if (id == GSCU_BADVAR)
			{
				goto finished;
			}
			var_value = ((GContext*)context.vmc)->api_get_variable(id);
		}
		else
		{
			auto key = (*back->value.it.keys)[back->value.it.index]; 
			
			if (data_structure->value.s.native.s->find(key) == data_structure->value.s.native.s->end())
			{
				goto finished;
			}

			auto id = (*data_structure->value.s.native.s)[key];
			var_value = ((GContext*)context.vmc)->api_get_variable(id);
		}

		if (var_value)
		{
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			((GContext*)context.vmc)->heap_to_stack(back, var_value);
			return 0;
		}
	}

finished:
	((GContext*)context.vmc)->stack_set(&context.thread->stack.back(), result.type, result.value, context.thread);
	return 0;
}

__int32 GSCUOpcodes::vm_op_getfieldkey(GSCUVMContext& context)
{
	// this opcode tries to get a field key or if it fails pushes undefined

	auto back = &context.thread->stack.back();

	GSCUStackVariable result{};
	result.type = GSCUVAR_UNDEFINED;
	result.value.int64 = 0;

	if (back->type != GSCUVAR_ITERATOR2)
	{
		goto finished;
	}

	{
		auto data_structure = ((GContext*)context.vmc)->api_get_variable(back->value.it.var_id);

		if (data_structure->type != GSCUVAR_STRUCT)
		{
			goto finished;
		}

		if (data_structure->value.s.classname == scr_const::array)
		{
			result.type = GSCUVAR_INTEGER;
			result.value.int32 = back->value.it.index;
		}
		else
		{
			auto fieldid = (*back->value.it.keys)[back->value.it.index];
			result.type = GSCUVAR_HASH;
			result.value.int32 = fieldid;
		}
	}

finished:
	((GContext*)context.vmc)->stack_set(&context.thread->stack.back(), result.type, result.value, context.thread);
	return 0;
}

__int32 GSCUOpcodes::vm_op_entersafecontext(GSCUVMContext& context)
{
	// this opcode protects a range of code from exceptions, jumping to an exception handler if an exception is encountered
	auto rel_handler = *(__int16*)(context.thread->fs_pos);
	context.thread->fs_pos += 2;

	// push frame information
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_SEHFRAME;
	back->value.seh.base = context.thread->fs_pos;
	back->value.seh.handler = rel_handler;
	back->value.seh.prev_safe_context = context.thread->safe_context;

	// apply to the current context
	context.thread->safe_context = (unsigned __int16)(context.thread->stack.size() - 1);

	return 0;
}

__int32 GSCUOpcodes::vm_op_exitsafecontext(GSCUVMContext& context)
{
	// this opcode pops the current safe context and restores the previous context

	if (!context.thread->safe_context)
	{
		// no safe context to exit
		return 0;
	}

	if (context.thread->safe_context != (context.thread->stack.size() - 1))
	{
		context.thread->safe_context = 0;
		VM_RTERROR(context, GSCU_ERROR_VM_STACKMISALIGNMENT, "tried to exit a safe context but the stack was not prepared to do so");
	}

	auto ctx = &context.thread->stack.back();
	context.thread->safe_context = ctx->value.seh.prev_safe_context;

	((GContext*)context.vmc)->stack_dispose(ctx, context.thread);
	context.thread->stack.pop_back();

	return 0;
}

__int32 GSCUOpcodes::vm_op_checktype(GSCUVMContext& context)
{
	// this opcode will push a boolean value based on the top value on the stack's type compared to the input type
	// the input type is encoded in a single byte directly after the opcode, with an inversion byte following it that will invert the result if set

	GSCUCastableVariableType expected_type = (GSCUCastableVariableType)*(unsigned __int8*)context.thread->fs_pos;
	bool negated = *(bool*)(context.thread->fs_pos + 1);

	context.thread->fs_pos += 2;

	auto back = &context.thread->stack.back();
	auto btype = back->type;

	((GContext*)context.vmc)->stack_dispose(back, context.thread);

	back->type = GSCUVAR_INTEGER;
	
	if (expected_type < GSCUCVAR_STRUCT)
	{
		back->value.int32 = expected_type == btype;
	}
	else 
	{
		if (btype != GSCUVAR_REFVAR)
		{
			back->value.int32 = 0;
		}
		else
		{
			auto var = ((GContext*)context.vmc)->api_get_variable(back->value.int32);

			if (!var)
			{
				back->value.int32 = 0;
				return GSCU_ERROR_RUNTIME_UNKNOWNVAR;
			}
			back->value.int32 = (var->value.s.classname == scr_const::array) == (expected_type == GSCUCVAR_ARRAY);
		}
	}

	if (negated)
	{
		back->value.int32 = back->value.int32 == 0;
	}

	return 0;
}

__int32 GSCUOpcodes::vm_op_castto(GSCUVMContext& context)
{
	// this opcode will cast the top stack variable to the resultant type if possible. otherwise, will return undefined
	// input type is encoded in a single byte directly after the opcode

	GSCUCastableVariableType expected_type = (GSCUCastableVariableType)*(unsigned __int8*)context.thread->fs_pos;
	context.thread->fs_pos += 2;

	auto back = &context.thread->stack.back();
	auto btype = back->type;

	GSCUStackVariable result{};
	result.type = GSCUVAR_UNDEFINED;
	result.value.int64 = 0;

	switch (expected_type)
	{
		case GSCUCVAR_INTEGER:
		{	
			switch (btype)
			{
				case GSCUVAR_INTEGER:
					result.value = back->value;
					result.type = back->type;
					break;
				case GSCUVAR_STRING:
					result.type = GSCUVAR_INTEGER;
					result.value.int32 = atoi(back->value.str.str_ref);
					break;
				case GSCUVAR_FLOAT:
					result.type = GSCUVAR_INTEGER;
					result.value.int32 = (int)back->value.f;
					break;
				case GSCUVAR_HASH:
					result.type = GSCUVAR_INTEGER;
					result.value.int32 = (int)back->value.int64 ^ (int)(back->value.int64 >> 32);
					break;
				default:
					result.type = GSCUVAR_INTEGER;
					result.value.int32 = 0;
					break;
			}
		}
		break;
		case GSCUCVAR_STRING:
		{
			((GContext*)context.vmc)->cast_to_string(&result, back);
		}
		break;
		case GSCUCVAR_FLOAT:
		{
			switch (btype)
			{
				case GSCUVAR_INTEGER:
					result.type = GSCUVAR_FLOAT;
					result.value.f = (float)back->value.int32;
					break;
				case GSCUVAR_STRING:
					result.type = GSCUVAR_FLOAT;
					result.value.f = (float)atof(back->value.str.str_ref);
					break;
				case GSCUVAR_FLOAT:
					result.type = GSCUVAR_FLOAT;
					result.value.f = back->value.f;
					break;
				default:
					result.type = GSCUVAR_FLOAT;
					result.value.f = 0.0f;
					break;
			}
		}
		break;
		case GSCUCVAR_STRUCT:
		{
			switch (btype)
			{
				case GSCUVAR_REFVAR:
				{
					auto v = ((GContext*)context.vmc)->api_get_variable(back->value.int32);
					if (!v)
					{
						break;
					}
					if (v->value.s.classname == scr_const::array)
					{
						auto new_var = ((GContext*)context.vmc)->array_copy(back->value.int32);

						if (new_var < 0)
						{
							return new_var;
						}

						((GContext*)context.vmc)->add_variable_ref(new_var);
						((GContext*)context.vmc)->array_to_struct(((GContext*)context.vmc)->api_get_variable(new_var));

						result.type = GSCUVAR_REFVAR;
						result.value.int32 = new_var;
					}
					else
					{
						auto new_var = ((GContext*)context.vmc)->struct_copy(back->value.int32);

						if (new_var < 0)
						{
							return new_var;
						}

						((GContext*)context.vmc)->add_variable_ref(new_var);

						v = ((GContext*)context.vmc)->api_get_variable(new_var);
						result.type = GSCUVAR_REFVAR;
						result.value.int32 = new_var;
					}
				}
				break;
				case GSCUVAR_VECTOR:
				{
					auto var_id = ((GContext*)context.vmc)->alloc_variable(0, 0);

					if (var_id < 0)
					{
						return var_id;
					}

					((GContext*)context.vmc)->add_variable_ref(var_id);
					auto variable = ((GContext*)context.vmc)->api_get_variable(var_id);

					variable->type = GSCUVAR_STRUCT;
					variable->value.s.classname = 0;
					variable->value.s.reserved = 0;
					variable->value.s.native.s = new std::unordered_map<unsigned __int32, unsigned __int32>();

					result.type = GSCUVAR_FLOAT;
					result.value.f = back->value.vec.x;
					((GContext*)context.vmc)->set_variable_field(var_id, scr_const::x, &result);

					result.value.f = back->value.vec.y;
					((GContext*)context.vmc)->set_variable_field(var_id, scr_const::y, &result);

					result.value.f = back->value.vec.z;
					((GContext*)context.vmc)->set_variable_field(var_id, scr_const::z, &result);

					result.value.f = back->value.vec.w;
					((GContext*)context.vmc)->set_variable_field(var_id, scr_const::w, &result);

					result.type = GSCUVAR_REFVAR;
					result.value.int32 = var_id;
				}
				break;
				default:
					break;
			}
		}
		break;
		case GSCUCVAR_ARRAY:
		{
			switch (btype)
			{
				case GSCUVAR_REFVAR:
				{
					auto v = ((GContext*)context.vmc)->api_get_variable(back->value.int32);
					if (!v)
					{
						break;
					}
					if (v->value.s.classname == scr_const::array)
					{
						auto new_var = ((GContext*)context.vmc)->array_copy(back->value.int32);

						if (new_var < 0)
						{
							return new_var;
						}

						((GContext*)context.vmc)->add_variable_ref(new_var);

						result.type = GSCUVAR_REFVAR;
						result.value.int32 = new_var;
					}
					else
					{
						auto new_var = ((GContext*)context.vmc)->struct_copy(back->value.int32);

						if (new_var < 0)
						{
							return new_var;
						}

						((GContext*)context.vmc)->add_variable_ref(new_var);
						((GContext*)context.vmc)->struct_to_array(((GContext*)context.vmc)->api_get_variable(new_var));

						result.type = GSCUVAR_REFVAR;
						result.value.int32 = new_var;
					}
				}
				break;
				case GSCUVAR_VECTOR:
				{
					auto var_id = ((GContext*)context.vmc)->alloc_variable(0, 0);

					if (var_id < 0)
					{
						return var_id;
					}

					((GContext*)context.vmc)->add_variable_ref(var_id);
					auto variable = ((GContext*)context.vmc)->api_get_variable(var_id);

					variable->type = GSCUVAR_STRUCT;
					variable->value.s.classname = scr_const::array;
					variable->value.s.reserved = 0;
					variable->value.s.native.a = new std::vector<unsigned __int32>();

					result.type = GSCUVAR_FLOAT;
					result.value.f = back->value.vec.x;
					((GContext*)context.vmc)->set_variable_field(var_id, 0, &result);

					result.value.f = back->value.vec.y;
					((GContext*)context.vmc)->set_variable_field(var_id, 1, &result);

					result.value.f = back->value.vec.z;
					((GContext*)context.vmc)->set_variable_field(var_id, 2, &result);

					result.value.f = back->value.vec.w;
					((GContext*)context.vmc)->set_variable_field(var_id, 3, &result);

					result.type = GSCUVAR_REFVAR;
					result.value.int32 = var_id;
				}
				break;

				// 100 as array is like saying [100]
				case GSCUVAR_INTEGER:
				case GSCUVAR_STRING:
				case GSCUVAR_FLOAT:
				case GSCUVAR_HASH:
				case GSCUVAR_FUNCTION:
				{
					auto var_id = ((GContext*)context.vmc)->alloc_variable(0, 0);

					if (var_id < 0)
					{
						return var_id;
					}

					((GContext*)context.vmc)->add_variable_ref(var_id);
					auto variable = ((GContext*)context.vmc)->api_get_variable(var_id);

					variable->type = GSCUVAR_STRUCT;
					variable->value.s.classname = scr_const::array;
					variable->value.s.reserved = 0;
					variable->value.s.native.a = new std::vector<unsigned __int32>();

					((GContext*)context.vmc)->set_variable_field(var_id, 0, back);

					result.type = GSCUVAR_REFVAR;
					result.value.int32 = var_id;
				}
				break;
				default:
					break;
			}
		}
		break;
		case GSCUCVAR_VECTOR:
		{
			switch (btype)
			{
				case GSCUVAR_REFVAR:
				{
					auto v = ((GContext*)context.vmc)->api_get_variable(back->value.int32);
					if (!v)
					{
						break;
					}
					GSCUStackVariable temp{}, temp2{};
					result.type = GSCUVAR_VECTOR;
					result.value.vec.x = 0;
					result.value.vec.y = 0;
					result.value.vec.z = 0;
					result.value.vec.w = 0;

					temp.type = GSCUVAR_UNDEFINED;

					if (!((GContext*)context.vmc)->get_variable_field(back->value.int32, scr_const::x, &temp) && !((GContext*)context.vmc)->cast_to_float(&temp2, &temp))
					{
						result.value.vec.x = temp2.value.f;
					}
					
					((GContext*)context.vmc)->stack_dispose(&temp, context.thread);
					temp.type = GSCUVAR_UNDEFINED;

					if (!((GContext*)context.vmc)->get_variable_field(back->value.int32, scr_const::y, &temp) && !((GContext*)context.vmc)->cast_to_float(&temp2, &temp))
					{
						result.value.vec.y = temp2.value.f;
					}

					((GContext*)context.vmc)->stack_dispose(&temp, context.thread);
					temp.type = GSCUVAR_UNDEFINED;

					if (!((GContext*)context.vmc)->get_variable_field(back->value.int32, scr_const::z, &temp) && !((GContext*)context.vmc)->cast_to_float(&temp2, &temp))
					{
						result.value.vec.z = temp2.value.f;
					}

					((GContext*)context.vmc)->stack_dispose(&temp, context.thread);
					temp.type = GSCUVAR_UNDEFINED;

					if (!((GContext*)context.vmc)->get_variable_field(back->value.int32, scr_const::w, &temp) && !((GContext*)context.vmc)->cast_to_float(&temp2, &temp))
					{
						result.value.vec.w = temp2.value.f;
					}	

					((GContext*)context.vmc)->stack_dispose(&temp, context.thread);
				}
				break;
				case GSCUVAR_INTEGER:
					result.type = GSCUVAR_VECTOR;
					result.value.vec.x = (float)back->value.int32;
					result.value.vec.y = 0;
					result.value.vec.z = 0;
					result.value.vec.w = 0;
				break;
				case GSCUVAR_FLOAT:
					result.type = GSCUVAR_VECTOR;
					result.value.vec.x = back->value.f;
					result.value.vec.y = 0;
					result.value.vec.z = 0;
					result.value.vec.w = 0;
				break;
				case GSCUVAR_VECTOR:
					result.type = GSCUVAR_VECTOR;
					result.value = back->value;
				break;
			}
		}
		break;
		case GSCUCVAR_HASH:
		{
			if (!((GContext*)context.vmc)->stack_to_canon64(back, result.value.int64))
			{
				result.type = GSCUVAR_HASH;
			}
		}
		break;
		default:
			VM_RTERROR(context, GSCU_ERROR_API_TYPEMISMATCH, "tried to cast a variable of type %d to ctype %d", btype, expected_type);
	}

	((GContext*)context.vmc)->stack_dispose(back, context.thread);

	context.thread->stack.pop_back();
	context.thread->stack.push_back(result);

	return 0;
}

__int32 GSCUOpcodes::dummy_destructor(GSCUCallContext& context)
{
	// copy of vm_op_getself
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_REFVAR;
	back->value.int32 = context.self;
	((GContext*)context.vmc)->add_variable_ref(context.self);
	return 0;
}

__int32 GSCUOpcodes::vm_op_deconstructobject(GSCUVMContext& context)
{
	// this opcode expects a class, struct, or array on the top of the stack (PSC prefixed)
	// if the struct has a destructor, it will be called.

	auto back = &context.thread->stack.back();

	if (back->type != GSCUVAR_REFVAR)
	{
		// caller
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		context.thread->stack.pop_back();

		// prescriptcall
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		context.thread->stack.pop_back();

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_NOTASTRUCT, "delete expects a struct (1)");
	}

	auto var = ((GContext*)context.vmc)->api_get_variable(back->value.int32);

	if (!var || var->type != GSCUVAR_STRUCT)
	{
		// caller
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		context.thread->stack.pop_back();

		// prescriptcall
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		context.thread->stack.pop_back();

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_NOTASTRUCT, "delete expects a struct (2)");
	}

	context.thread->stack.push_back(GSCUStackVariable());
	auto dtor = &context.thread->stack.back();

	((GContext*)context.vmc)->get_class_method(var->value.s.classname, scr_const::dtorauto, dtor);
	
	if (dtor->type != GSCUVAR_FUNCTION)
	{
		dtor->type = GSCUVAR_FUNCTION;
		dtor->value.fn.is_script_function = false;
		dtor->value.fn.func = (__int64)&dummy_destructor;
		dtor->value.fn.captures = 0;
	}

	// cleans up caller 
	return vm_op_methodcallpointer(context);
}

__int32 GSCUOpcodes::vm_op_freeobject(GSCUVMContext& context)
{
	// this opcode expects a class, struct, or array on the top of the stack
	// the object will then have all its fields decref'd and it will be converted into undefined if it has any references. if no references exist, it will be freed

	auto back = &context.thread->stack.back();

	if (back->type != GSCUVAR_REFVAR)
	{
		// caller
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		context.thread->stack.pop_back();

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_NOTASTRUCT, "free expects a struct (1)");
	}

	auto var = ((GContext*)context.vmc)->api_get_variable(back->value.int32);

	// caller
	((GContext*)context.vmc)->stack_dispose(back, context.thread);
	context.thread->stack.pop_back();

	if (!var || var->type != GSCUVAR_STRUCT)
	{
		if (var && var->type == GSCUVAR_FREE)
		{
			return 0;
		}

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_NOTASTRUCT, "free expects a struct (2)");
	}

	// clear all its fields
	((GContext*)context.vmc)->heap_dispose(var);

	if (var->type != GSCUVAR_FREE)
	{
		// still has references, cannot destroy it yet
		var->type = GSCUVAR_UNDEFINED;
		var->value.int64 = 0;
	}

	return 0;
}

__int32 GSCUOpcodes::vm_op_switch(GSCUVMContext& context)
{
	// this opcode is given a hardcoded jumptable as an input and hashes a variable on the stack to compare
	// if the variable is not able to be hashed the opcode will throw a runtime error

	auto num_cases = *(unsigned __int16*)context.thread->fs_pos;
	auto loc_default = *(unsigned __int16*)(context.thread->fs_pos + 2);
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos + 4, 4) + num_cases * 8;

	// note: the vm will check the cases in reverse order so that jumps can be correctly offset

	auto back = &context.thread->stack.back();
	unsigned __int32 canon_val = 0;

	auto result = ((GContext*)context.vmc)->stack_to_canon(back, canon_val);

	((GContext*)context.vmc)->stack_dispose(back, context.thread);
	context.thread->stack.pop_back();

	if (result)
	{
		return result;
	}

	for (unsigned __int16 i = 0; i < num_cases; i++)
	{
		auto val = *(unsigned __int32*)(context.thread->fs_pos - (i * 8) - 4);
		if (val != canon_val)
		{
			continue;
		}
		context.thread->fs_pos += *(unsigned __int16*)(context.thread->fs_pos - (i * 8) - 8);
		return 0;
	}

	context.thread->fs_pos += loc_default;
	return 0;
}

__int32 GSCUOpcodes::vm_op_addfieldonstack(GSCUVMContext& context)
{
	// adds a field to an array or struct on the stack without removing it from the stack
	return setfieldonstackinternal(context, false);
}

__int32 GSCUOpcodes::vm_op_addfield(GSCUVMContext& context)
{
	return setvariablefieldinternal(context, false);
}

__int32 GSCUOpcodes::vm_op_breakpoint(GSCUVMContext& context)
{
	return ((GContext*)context.vmc)->debug_suspend(context);
}

__int32 GSCUOpcodes::vm_op_registerclass(GSCUVMContext& context)
{
	// this opcode expects two function pointers on the stack: the top is the destructor, the second from the top is the constructor
	// if either is undefined, the respective property will be marked undefined as well
	// if either param is not a function pointer and is not undefined, the vm will quit the thread immediately.

	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, 4);
	
	auto classid = *(__int32*)context.thread->fs_pos;
	context.thread->fs_pos += 4;

	auto dtor = &context.thread->stack.back();
	auto ctor = &context.thread->stack.at(context.thread->stack.size() - 2);

	if (dtor->type != GSCUVAR_UNDEFINED && dtor->type != GSCUVAR_FUNCTION)
	{
		((GContext*)context.vmc)->stack_dispose(dtor, context.thread);
		((GContext*)context.vmc)->stack_dispose(ctor, context.thread);
		context.thread->stack.pop_back();
		context.thread->stack.pop_back();

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_CLASSREGISTERFAILURE, "destructor for class %d was invalid", classid);
	}

	if (ctor->type != GSCUVAR_UNDEFINED && ctor->type != GSCUVAR_FUNCTION)
	{
		((GContext*)context.vmc)->stack_dispose(dtor, context.thread);
		((GContext*)context.vmc)->stack_dispose(ctor, context.thread);
		context.thread->stack.pop_back();
		context.thread->stack.pop_back();

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_CLASSREGISTERFAILURE, "constructor for class %d was invalid", classid);
	}

	auto result = ((GContext*)context.vmc)->register_class(classid, ctor, dtor);

	((GContext*)context.vmc)->stack_dispose(dtor, context.thread);
	((GContext*)context.vmc)->stack_dispose(ctor, context.thread);
	context.thread->stack.pop_back();
	context.thread->stack.pop_back();

	return result;
}

__int32 GSCUOpcodes::vm_op_setclassmethod(GSCUVMContext& context)
{
	// this opcode expects a hashable value on the top of stack, with a function pointer below it
	// the opcode will change/register the function associated with a class' method
	
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, 4);

	auto classid = *(__int32*)context.thread->fs_pos;
	context.thread->fs_pos += 4;

	auto method_id = &context.thread->stack.back();
	auto fn = &context.thread->stack.at(context.thread->stack.size() - 2);

	if (fn->type != GSCUVAR_UNDEFINED && fn->type != GSCUVAR_FUNCTION)
	{
		((GContext*)context.vmc)->stack_dispose(method_id, context.thread);
		((GContext*)context.vmc)->stack_dispose(fn, context.thread);
		context.thread->stack.pop_back();
		context.thread->stack.pop_back();

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_CLASSPROPFAILURE, "'%d' is not a function or undefined", method_id->type);
	}

	unsigned __int32 canon_id = 0;
	auto result = ((GContext*)context.vmc)->stack_to_canon(method_id, canon_id);

	if (!result)
	{
		result = ((GContext*)context.vmc)->set_class_method(classid, canon_id, fn);
	}

	((GContext*)context.vmc)->stack_dispose(method_id, context.thread);
	((GContext*)context.vmc)->stack_dispose(fn, context.thread);
	context.thread->stack.pop_back();
	context.thread->stack.pop_back();

	return result;
}

__int32 GSCUOpcodes::vm_op_getclassmethod(GSCUVMContext& context)
{
	// this opcode expects a hashable value on the top of the stack
	// the opcode will return the function registered for the class::method or undefined (unmatching types or non-existant)
	
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, 4);

	auto classid = *(__int32*)context.thread->fs_pos;
	context.thread->fs_pos += 4;

	auto method_id = &context.thread->stack.back();
	
	unsigned __int32 canon_id = 0;
	auto result = ((GContext*)context.vmc)->stack_to_canon(method_id, canon_id);

	((GContext*)context.vmc)->stack_dispose(method_id, context.thread);
	context.thread->stack.pop_back();

	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	
	if (!result)
	{
		result = ((GContext*)context.vmc)->get_class_method(classid, canon_id, back);
	}
	else
	{
		back->value.int64 = 0;
		back->type = GSCUVAR_UNDEFINED;
	}
	
	return result;
}

__int32 GSCUOpcodes::vm_op_callclassmethod(GSCUVMContext& context)
{
	// this opcode takes a i32 function name to call, with a caller at the top of the stack, followed by parameters
	// if the caller is not a struct, the vm will error
	// if the function cannot be found in the corresponding class, the vm will error.
	// this is equivalent functionality to a pointer method call

	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, 4);

	auto methodname = *(unsigned __int32*)context.thread->fs_pos;
	context.thread->fs_pos += 4;

	context.thread->stack.push_back(GSCUStackVariable());

	auto fn = &context.thread->stack.back();
	auto caller = &context.thread->stack.at(context.thread->stack.size() - 2);

	fn->type = GSCUVAR_UNDEFINED;
	fn->value.int64 = 0;

	if (caller->type != GSCUVAR_REFVAR)
	{
		// dispose of the arguments
		while (context.thread->stack.size())
		{
			auto back = &context.thread->stack.back();
			auto thistype = back->type;
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
			if (thistype == GSCUVAR_BEGINPARAMS)
			{
				break;
			}
		}

		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDCAST, "variable type %d is not an object (1)", caller->type);
	}

	auto caller_var = ((GContext*)context.vmc)->api_get_variable(caller->value.int32);

	if (!caller_var)
	{
		// dispose of the arguments
		while (context.thread->stack.size())
		{
			auto back = &context.thread->stack.back();
			auto thistype = back->type;
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
			if (thistype == GSCUVAR_BEGINPARAMS)
			{
				break;
			}
		}

		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_RUNTIME_UNKNOWNVAR, "variable freed before being dereferenced");
	}

	if (caller_var->type != GSCUVAR_STRUCT)
	{
		// dispose of the arguments
		while (context.thread->stack.size())
		{
			auto back = &context.thread->stack.back();
			auto thistype = back->type;
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
			if (thistype == GSCUVAR_BEGINPARAMS)
			{
				break;
			}
		}

		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDCAST, "variable type %d is not an object (2)", caller_var->type);
	}

	((GContext*)context.vmc)->get_class_method(caller_var->value.s.classname, methodname, fn);
	
	auto result = vm_op_methodcallpointer(context);

	if (GSCU_ERROR_VM_NOTAFUNCTION == result)
	{
		VM_RTERROR(context, GSCU_ERROR_VM_INVALIDMETHOD, "class method %X does not exist or is not a method", methodname);
	}

	return result;
}

__int32 GSCUOpcodes::vm_op_callclassmethodthreaded(GSCUVMContext& context)
{
	// this opcode takes a i32 function name to call, with a caller at the top of the stack, followed by parameters
	// if the caller is not a struct, the vm will error
	// if the function cannot be found in the corresponding class, the vm will error.
	// this is equivalent functionality to a threaded pointer method call

	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, 4);

	auto methodname = *(unsigned __int32*)context.thread->fs_pos;
	context.thread->fs_pos += 4;

	context.thread->stack.push_back(GSCUStackVariable());

	auto fn = &context.thread->stack.back();
	auto caller = &context.thread->stack.at(context.thread->stack.size() - 2);

	fn->type = GSCUVAR_UNDEFINED;
	fn->value.int64 = 0;

	if (caller->type != GSCUVAR_REFVAR)
	{
		// dispose of the arguments
		while (context.thread->stack.size())
		{
			auto back = &context.thread->stack.back();
			auto thistype = back->type;
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
			if (thistype == GSCUVAR_BEGINPARAMS)
			{
				break;
			}
		}

		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDCAST, "variable type %d is not an object", caller->type);
	}

	auto caller_var = ((GContext*)context.vmc)->api_get_variable(caller->value.int32);

	if (!caller_var)
	{
		// dispose of the arguments
		while (context.thread->stack.size())
		{
			auto back = &context.thread->stack.back();
			auto thistype = back->type;
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
			if (thistype == GSCUVAR_BEGINPARAMS)
			{
				break;
			}
		}

		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_RUNTIME_UNKNOWNVAR, "variable freed before being dereferenced");
	}

	if (caller_var->type != GSCUVAR_STRUCT)
	{
		// dispose of the arguments
		while (context.thread->stack.size())
		{
			auto back = &context.thread->stack.back();
			auto thistype = back->type;
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
			if (thistype == GSCUVAR_BEGINPARAMS)
			{
				break;
			}
		}

		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDCAST, "variable type %d is not an object", caller_var->type);
	}

	((GContext*)context.vmc)->get_class_method(caller_var->value.s.classname, methodname, fn);

	auto result = vm_op_threadmethodcallpointer(context);

	if (GSCU_ERROR_VM_NOTAFUNCTION == result)
	{
		VM_RTERROR(context, GSCU_ERROR_VM_INVALIDMETHOD, "class method %X does not exist or is not a method", methodname);
	}

	return result;
}

__int32 GSCUOpcodes::vm_op_spawnclassobject(GSCUVMContext& context)
{
	// this opcode expects an i32 input classname, along with parameters on the stack (PSC prefixed)
	// the opcode will create a new instance of the class and will push the instance to the stack
	// the opcode will then invoke the constructor of the class with the given arguments from the vm. the autogen constructor is expected to return a reference to the class automatically
	
	context.thread->fs_pos = GSCU_ALIGN(context.thread->fs_pos, 4);

	auto classname = *(unsigned __int32*)context.thread->fs_pos;
	context.thread->fs_pos += 4;
	
	if (!((GContext*)context.vmc)->is_class_registered(classname))
	{
		// dispose of the arguments
		while (context.thread->stack.size())
		{
			auto back = &context.thread->stack.back();
			auto thistype = back->type;
			((GContext*)context.vmc)->stack_dispose(back, context.thread);
			context.thread->stack.pop_back();
			if (thistype == GSCUVAR_BEGINPARAMS)
			{
				break;
			}
		}

		vm_op_addundefined(context);
		VM_RTERROR(context, GSCU_ERROR_VM_INVALIDCLASS, "class %X does not exist", classname);
	}

	auto result = vm_op_addstruct(context);

	if (result)
	{
		return result;
	}

	auto back = &context.thread->stack.back();
	auto s_struct = ((GContext*)context.vmc)->api_get_variable(back->value.int32);
	s_struct->value.s.classname = classname;
	((GContext*)context.vmc)->add_variable_ref(s_struct->id); // pin this object so when the script method call clears stack we dont lose it
	
	// struct is created, now need to call auto-gen constructor

	context.thread->stack.push_back(GSCUStackVariable());
	back = &context.thread->stack.back();

	((GContext*)context.vmc)->get_class_method(classname, scr_const::ctorauto, back);
	return vm_op_methodcallpointer(context);
}

__int32 GSCUOpcodes::vm_op_duplicateparameters(GSCUVMContext& context)
{
	// this opcode copies the parameters from the current function directly to the stack at this point
	
	__int32 precodepos = -1;
	__int32 beginparams = -1;

	for (int index = context.thread->stack.size() - 1; index > -1; index--)
	{
		auto var = &context.thread->stack.at(index);
		if (var->type == GSCUVAR_PRECODEPOS)
		{
			precodepos = index;
			break;
		}
	}

	// couldnt find a previous function call
	if (precodepos == -1)
	{
		return 0;
	}

	for (int index = precodepos - 1; index > -1; index--)
	{
		auto var = &context.thread->stack.at(index);
		if (var->type == GSCUVAR_BEGINPARAMS)
		{
			beginparams = index;
			break;
		}
	}

	// couldnt find the marker for begin params
	if (beginparams == -1)
	{
		return 0;
	}

	// copy all the params (NOTE: this accounts for VA automatically)
	for (int index = beginparams + 1; index < precodepos; index++)
	{
		auto var = &context.thread->stack.at(index);
		context.thread->stack.push_back(GSCUStackVariable());
		
		auto outvar = &context.thread->stack.back();
		outvar->type = GSCUVAR_UNDEFINED;

		((GContext*)context.vmc)->stack_set(outvar, var->type, var->value, context.thread);
	}

	return 0;
}

__int32 GSCUOpcodes::vm_op_populatevararg(GSCUVMContext& context)
{
	// this opcode only spawns in variadic argument functions and will copy all the arguments remaining on the stack into the designated VA argument (the last arg of the function)
	// opcode expects one i8 arg:
	// i8 va_index: number of parameters in the function header, excluding the vararg
	// function will create an array on the stack at the index provided, and will then iterate the stack to determine start and end of arguments required, populating vararg array with respective fields

	auto va_index = *(char*)context.thread->fs_pos;
	context.thread->fs_pos += 2;

	if (!context.thread->start_locals)
	{
		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "tried to populate varargs in a local variable when none exist");
	}

	__int16 stack_index = context.thread->start_locals + va_index;

	if ((stack_index) >= context.thread->stack.size())
	{
		VM_RTERROR(context, GSCU_ERROR_VM_BADVARREF, "tried to populate varargs in a local variable outside of the boundaries of the stack");
	}

	auto local = &context.thread->stack.at(stack_index);
	
	// dispose of old stack variable
	((GContext*)context.vmc)->stack_dispose(local, context.thread);

	// create a new array variable
	auto var_id = ((GContext*)context.vmc)->alloc_variable(0, 0);
	((GContext*)context.vmc)->add_variable_ref(var_id);

	// set up the array
	auto variable = ((GContext*)context.vmc)->api_get_variable(var_id);
	variable->type = GSCUVAR_STRUCT;
	variable->value.s.classname = scr_const::array;
	variable->value.s.reserved = 0;
	variable->value.s.native.a = new std::vector<unsigned __int32>();

	// set up the reference on the stack
	local->type = GSCUVAR_REFVAR;
	local->value.int32 = var_id;

	__int32 precodepos = -1;
	__int32 beginparams = -1;

	for (int index = context.thread->start_locals; index > -1; index--)
	{
		auto var = &context.thread->stack.at(index);
		if (var->type == GSCUVAR_PRECODEPOS)
		{
			precodepos = index;
			break;
		}
	}

	// couldnt find a previous function call
	if (precodepos == -1)
	{
		VM_RTERROR(context, GSCU_ERROR_VM_STACKMISALIGNMENT, "unable to correctly populate variadic arguments for a function (1)");
	}

	for (int index = precodepos - 1; index > -1; index--)
	{
		auto var = &context.thread->stack.at(index);
		if (var->type == GSCUVAR_BEGINPARAMS)
		{
			beginparams = index;
			break;
		}
	}

	// couldnt find the marker for begin params
	if (beginparams == -1)
	{
		VM_RTERROR(context, GSCU_ERROR_VM_STACKMISALIGNMENT, "unable to correctly populate variadic arguments for a function (2)");
	}

	int num_varargs = precodepos - (beginparams + 1) - va_index;

	// note that sometimes the function may accept varargs but doesnt receive enough parameters to populate the array
	// in this case, the array is still defined but it is empty
	if (num_varargs <= 0)
	{
		return 0;
	}

	variable->value.s.native.a->reserve(num_varargs);

	int i = 0;
	for (int index = precodepos - 1 - va_index; index > beginparams; index--, i++)
	{
		auto var = &context.thread->stack.at(index);
		((GContext*)context.vmc)->set_variable_field(var_id, i, var);
	}

	return 0;
}

__int32 GSCUOpcodes::vm_op_unpack(GSCUVMContext& context)
{
	// NOTE: this opcode *must* be PSC prefixed if strict_count is false or things will get really bad really fast!
	// this opcode expects an array on the stack, and two i8 parameters:
	// i8 unpack_count: number of elements to unpack from the array, or 255 if we should extract as many as possible
	// i8 strict_count: if true, respect the number of elements by filling undefined if the limit is not reached. if false, unpack as many elements as the array supports, up to a maximum based on the last PSC marker (dont want > 255 args)
	// this opcode will take an array and push a number of its elements onto the stack in reverse order. the opcode starts from array index 0.
	
	auto unpack_count = *(char*)context.thread->fs_pos;
	auto strict_count = *(char*)(context.thread->fs_pos + 1);
	context.thread->fs_pos += 2;

	auto back = &context.thread->stack.back();
	int failtype = 0;
	if (back->type != GSCUVAR_REFVAR)
	{
		failed:
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		context.thread->stack.pop_back();

		// need to push unpack_count undefined's if strict_count
		if (strict_count)
		{
			for (int i = 0; i < unpack_count; i++)
			{
				context.thread->stack.push_back(GSCUStackVariable());
				back = &context.thread->stack.back();
				back->type = GSCUVAR_UNDEFINED;
				back->value.int64 = 0;
			}
		}

		VM_RTERROR(context, GSCU_ERROR_API_TYPEMISMATCH, "%d is not an array (%d)", back->type, failtype);
	}

	auto var = ((GContext*)context.vmc)->api_get_variable(back->value.int32);

	if (!var)
	{
		failtype = 1;
		goto failed;
	}

	if (var->type != GSCUVAR_STRUCT)
	{
		failtype = 2;
		goto failed;
	}

	if (var->value.s.classname != scr_const::array)
	{
		failtype = 3;
		goto failed;
	}

	int target_count = var->value.s.native.a->size();
	int num_undefined = 0;
	if (strict_count)
	{
		if (unpack_count > target_count)
		{
			num_undefined = unpack_count - target_count;
		}
	}
	else
	{
		int numArgs = 0;
		for (int i = context.thread->stack.size() - 2; i > -1; i--)
		{
			if (context.thread->stack.at(i).type == GSCUVAR_BEGINPARAMS)
			{
				break;
			}
			numArgs++;
		}

		if (numArgs + target_count > 255)
		{
			target_count = 255 - numArgs;
		}
	}

	auto back_copy = context.thread->stack.back();
	context.thread->stack.pop_back();

	for (int i = 0; i < num_undefined; i++)
	{
		context.thread->stack.push_back(GSCUStackVariable());
		back = &context.thread->stack.back();
		back->type = GSCUVAR_UNDEFINED;
		back->value.int64 = 0;
	}

	for (int i = 0; i < target_count; i++)
	{
		context.thread->stack.push_back(GSCUStackVariable());
		back = &context.thread->stack.back();
		((GContext*)context.vmc)->get_variable_field(var->id, i, back);
	}

	((GContext*)context.vmc)->stack_dispose(&back_copy, context.thread);
	return 0;
}

__int32 GSCUOpcodes::vm_op_stackcopy(GSCUVMContext& context)
{
	// this opcode expects an i8 argument that represents the index of the stack element to copy to the front
	// the opcode will take an element at the given position and copy it to the top of the stack
	
	auto move_index = *(char*)context.thread->fs_pos;
	context.thread->fs_pos += 2;

	if (move_index >= context.thread->stack.size())
	{
		VM_RTERROR(context, GSCU_ERROR_VM_STACKMISALIGNMENT, "stack copy requires a valid index inside the boundaries of the stack");
	}

	auto item = &context.thread->stack.at(context.thread->stack.size() - 1 - move_index);
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	((GContext*)context.vmc)->stack_set(back, item->type, item->value, context.thread);

	return 0;
}

// TODO CAPTURES
/*
	Ideas:
		Opcode modification of safecreate? Different opcode entirely that acts like safecreate?
*/
__int32 GSCUOpcodes::vm_op_addanonymousfunction(GSCUVMContext& context)
{
	// this opcode expects an i16 relative jump past the end of the function it represents, with an immediate function following the last operand
	// the opcode also expects an array argument representing the captures for the local. if the array is empty, captures will not be recorded.
	// captures should be the first locals recorded, in between parameters and regular locals.
	
	auto fn_loc = context.thread->fs_pos + 2;
	context.thread->fs_pos += (unsigned __int64)2 + *(unsigned __int16*)context.thread->fs_pos;

	auto back = &context.thread->stack.back();
	if (back->type != GSCUVAR_REFVAR)
	{
		// do not pop because we dont know what this is...
		VM_RTERROR(context, GSCU_ERROR_VM_STACKMISALIGNMENT, "anonymous function push must be preceeded by an array on the stack (1)");
	}

	auto var = ((GContext*)context.vmc)->api_get_variable(back->value.int32);

	if (!var || var->type != GSCUVAR_STRUCT || var->value.s.classname != scr_const::array)
	{
		// do pop because it was a ref var but for some reason the array is broken (GC issues or something)
		((GContext*)context.vmc)->stack_dispose(back, context.thread);
		context.thread->stack.pop_back();

		VM_RTERROR(context, GSCU_ERROR_VM_STACKMISALIGNMENT, "anonymous function push must be preceeded by an array on the stack (2)");
	}

	GSCUStackVariable fn{};
	fn.type = GSCUVAR_FUNCTION;
	fn.value.fn.is_script_function = true;
	fn.value.fn.func = fn_loc;

	// only setup captures if any exist
	if (var->value.s.native.a->size())
	{
		fn.value.fn.captures = var->id;
		((GContext*)context.vmc)->add_variable_ref(var->id);
	}
	else
	{
		fn.value.fn.captures = 0;
	}

	// pop captures and replace with fn
	((GContext*)context.vmc)->stack_set(back, fn.type, fn.value, context.thread);

	return 0;
}

__int32 GSCUOpcodes::vm_op_throw(GSCUVMContext& context)
{
	// this opcode expects 3 objects on the stack: an integer error code, a string message, and a struct error object
	// the opcode forces an exception to be processed in vm_execute

	context.thread->set_flag(GSCUTF_EXITED);
	context.thread->set_flag(GSCUTF_RAISE_EXCEPTION);

	return 0;
}

__int32 GSCUOpcodes::vm_op_setclasspropsetter(GSCUVMContext& context)
{
	// this opcode changes the setter for a class property. note that a class prop must have both a setter and a getter defined to function correctly.
	// changing a class prop to undefined without changing the other may cause undefined behavior
	// expects
	// <top (-1)>: function reference or undefined
	// <-2>: hashable value (fieldname)
	// <-3>: hashable value (classname)

	auto fn = &context.thread->stack.back();
	auto field_name = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto class_name = &context.thread->stack.at(context.thread->stack.size() - 3);

	if (fn->type != GSCUVAR_FUNCTION && fn->type != GSCUVAR_UNDEFINED)
	{
		((GContext*)context.vmc)->stack_dispose(fn, context.thread);
		((GContext*)context.vmc)->stack_dispose(field_name, context.thread);
		((GContext*)context.vmc)->stack_dispose(class_name, context.thread);
		context.thread->stack.pop_back();
		context.thread->stack.pop_back();
		context.thread->stack.pop_back();

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "changing class prop setter requires either a function or undefined as an argument");
	}

	unsigned __int32 field_id = 0;
	unsigned __int32 class_id = 0;
	auto result = ((GContext*)context.vmc)->stack_to_canon(field_name, field_id);

	if (!result)
	{
		result = ((GContext*)context.vmc)->stack_to_canon(class_name, class_id);
	}

	if (result)
	{
		((GContext*)context.vmc)->stack_dispose(fn, context.thread);
		((GContext*)context.vmc)->stack_dispose(field_name, context.thread);
		((GContext*)context.vmc)->stack_dispose(class_name, context.thread);
		context.thread->stack.pop_back();
		context.thread->stack.pop_back();
		context.thread->stack.pop_back();
		return result;
	}

	result = ((GContext*)context.vmc)->set_class_prop(class_id, field_id, fn, true);

	((GContext*)context.vmc)->stack_dispose(fn, context.thread);
	((GContext*)context.vmc)->stack_dispose(field_name, context.thread);
	((GContext*)context.vmc)->stack_dispose(class_name, context.thread);
	context.thread->stack.pop_back();
	context.thread->stack.pop_back();
	context.thread->stack.pop_back();

	return result;
}

__int32 GSCUOpcodes::vm_op_setclasspropgetter(GSCUVMContext& context)
{
	// this opcode changes the getter for a class property. note that a class prop must have both a setter and a getter defined to function correctly.
	// changing a class prop to undefined without changing the other may cause undefined behavior
	// expects
	// <top (-1)>: function reference or undefined
	// <-2>: hashable value (fieldname)
	// <-3>: hashable value (classname)

	auto fn = &context.thread->stack.back();
	auto field_name = &context.thread->stack.at(context.thread->stack.size() - 2);
	auto class_name = &context.thread->stack.at(context.thread->stack.size() - 3);

	if (fn->type != GSCUVAR_FUNCTION && fn->type != GSCUVAR_UNDEFINED)
	{
		((GContext*)context.vmc)->stack_dispose(fn, context.thread);
		((GContext*)context.vmc)->stack_dispose(field_name, context.thread);
		((GContext*)context.vmc)->stack_dispose(class_name, context.thread);
		context.thread->stack.pop_back();
		context.thread->stack.pop_back();
		context.thread->stack.pop_back();

		VM_RTERROR(context, GSCU_ERROR_RUNTIME_INVALIDOPERANDS, "changing class prop getter requires either a function or undefined as an argument");
	}

	unsigned __int32 field_id = 0;
	unsigned __int32 class_id = 0;
	auto result = ((GContext*)context.vmc)->stack_to_canon(field_name, field_id);

	if (!result)
	{
		result = ((GContext*)context.vmc)->stack_to_canon(class_name, class_id);
	}

	if (result)
	{
		((GContext*)context.vmc)->stack_dispose(fn, context.thread);
		((GContext*)context.vmc)->stack_dispose(field_name, context.thread);
		((GContext*)context.vmc)->stack_dispose(class_name, context.thread);
		context.thread->stack.pop_back();
		context.thread->stack.pop_back();
		context.thread->stack.pop_back();
		return result;
	}

	result = ((GContext*)context.vmc)->set_class_prop(class_id, field_id, fn, false);

	((GContext*)context.vmc)->stack_dispose(fn, context.thread);
	((GContext*)context.vmc)->stack_dispose(field_name, context.thread);
	((GContext*)context.vmc)->stack_dispose(class_name, context.thread);
	context.thread->stack.pop_back();
	context.thread->stack.pop_back();
	context.thread->stack.pop_back();

	return result;
}

__int32 GSCUOpcodes::vm_op_getclasspropsetter(GSCUVMContext& context)
{
	// this opcode returns either a function reference to the setter function for the supplied field name and class name, or it returns undefined if the setter function is not configured.
	// expects
	// <top (-1)>: hashable value (fieldname)
	// <(-2)>: hashable value (classname)

	auto field_name = &context.thread->stack.back();
	auto class_name = &context.thread->stack.at(context.thread->stack.size() - 2);

	unsigned __int32 field_id = 0;
	unsigned __int32 class_id = 0;
	auto result = ((GContext*)context.vmc)->stack_to_canon(field_name, field_id);

	if (!result)
	{
		result = ((GContext*)context.vmc)->stack_to_canon(class_name, class_id);
	}

	((GContext*)context.vmc)->stack_dispose(field_name, context.thread);
	((GContext*)context.vmc)->stack_dispose(class_name, context.thread);
	context.thread->stack.pop_back();
	context.thread->stack.pop_back();

	if (result)
	{
		return result;
	}

	// prep getting the value
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_UNDEFINED;

	result = ((GContext*)context.vmc)->get_class_prop(class_id, field_id, back, true);
	return result;
}

__int32 GSCUOpcodes::vm_op_getclasspropgetter(GSCUVMContext& context)
{
	// this opcode returns either a function reference to the getter function for the supplied field name and class name, or it returns undefined if the getter function is not configured.
	// expects
	// <top (-1)>: hashable value (fieldname)
	// <(-2)>: hashable value (classname)

	auto field_name = &context.thread->stack.back();
	auto class_name = &context.thread->stack.at(context.thread->stack.size() - 2);

	unsigned __int32 field_id = 0;
	unsigned __int32 class_id = 0;
	auto result = ((GContext*)context.vmc)->stack_to_canon(field_name, field_id);

	if (!result)
	{
		result = ((GContext*)context.vmc)->stack_to_canon(class_name, class_id);
	}

	((GContext*)context.vmc)->stack_dispose(field_name, context.thread);
	((GContext*)context.vmc)->stack_dispose(class_name, context.thread);
	context.thread->stack.pop_back();
	context.thread->stack.pop_back();

	if (result)
	{
		return result;
	}

	// prep getting the value
	context.thread->stack.push_back(GSCUStackVariable());
	auto back = &context.thread->stack.back();
	back->type = GSCUVAR_UNDEFINED;

	result = ((GContext*)context.vmc)->get_class_prop(class_id, field_id, back, false);
	return result;
}
