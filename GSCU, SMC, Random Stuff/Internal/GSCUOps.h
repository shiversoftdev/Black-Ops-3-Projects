#pragma once
#include "GSCUVars.h"
#include "gscu.h"
#include "GSCObj.h"

#if (GSCU_BRANCH == GSCU_BRANCH_DEBUG)
#define VM_RTERROR(context, error_code, fmt, ...) sprintf_s(((GContext*)context.vmc)->last_runtime_error, fmt, __VA_ARGS__); ((GContext*)context.vmc)->last_error_code = error_code; return error_code;
#else
#define VM_RTERROR(context, error_code, fmt, ...) sprintf_s(((GContext*)context.vmc)->last_runtime_error, "%d", error_code); ((GContext*)context.vmc)->last_error_code = error_code; return error_code;
#endif

enum GSCU_Opcodes // DEPENDENT
{
	GSCUOP_NOP,
	GSCUOP_CreateLocalVariables,
	GSCUOP_End,
	GSCUOP_PreScriptCall,
	GSCUOP_GetByte,
	GSCUOP_GetZero,
	GSCUOP_GetOne,
	GSCUOP_GetInteger,
	GSCUOP_GetFloat,
	GSCUOP_GetString,
	GSCUOP_CallBuiltin,
	GSCUOP_Return,
	GSCUOP_DecTop,
	GSCUOP_CallScriptFunction,
	GSCUOP_Wait,
	GSCUOP_GetSelf,
	GSCUOP_ThreadCallBuiltin,
	GSCUOP_ThreadCallScript,
	GSCUOP_MethodCallBuiltin,
	GSCUOP_MethodCallScript,
	GSCUOP_EvalLocalVariableCached,
	GSCUOP_AddStruct,
	GSCUOP_SetLocalVariable,
	GSCUOP_SetVariableField,
	GSCUOP_EvalVariableField,
	GSCUOP_AddArray,
	GSCUOP_AddUndefined,
	GSCUOP_EvalFieldOnStack,
	GSCUOP_GetHash,
	GSCUOP_MakeVec2,
	GSCUOP_MakeVec3,
	GSCUOP_MakeVec4,
	GSCUOP_SetFieldOnStack,
	GSCUOP_ThreadMethodCallScript,
	GSCUOP_ThreadMethodCallBuiltin,
	GSCUOP_Endon,
	GSCUOP_Notify,
	GSCUOP_Waittill,
	GSCUOP_Waitframe,
	GSCUOP_GetAPIFunction,
	GSCUOP_GetScriptFunction,
	GSCUOP_CallPointer,
	GSCUOP_MethodCallPointer,
	GSCUOP_ThreadCallPointer,
	GSCUOP_ThreadMethodCallPointer,
	GSCUOP_BoolNot,
	GSCUOP_Jump,
	GSCUOP_JumpOnFalse,
	GSCUOP_JumpOnTrue,
	GSCUOP_JumpOnFalseExpr,
	GSCUOP_JumpOnTrueExpr,
	GSCUOP_Plus,
	GSCUOP_Minus,
	GSCUOP_Multiply,
	GSCUOP_Divide,
	GSCUOP_Modulo,
	GSCUOP_BitShiftLeft,
	GSCUOP_BitShiftRight,
	GSCUOP_BitAnd,
	GSCUOP_BitOr,
	GSCUOP_BitXor,
	GSCUOP_BitNegate,
	GSCUOP_Equals,
	GSCUOP_NotEquals,
	GSCUOP_SuperEquals,
	GSCUOP_SuperNotEquals,
	GSCUOP_GreaterThan,
	GSCUOP_LessThanEqualTo,
	GSCUOP_LessThan,
	GSCUOP_GreaterThanEqualTo,
	GSCUOP_SizeOf,
	GSCUOP_VMTime,
	GSCUOP_IncField,
	GSCUOP_DecField,
	GSCUOP_IncLocal,
	GSCUOP_DecLocal,
	//GSCUOP_IncStackField,
	//GSCUOP_DecStackField,
	GSCUOP_IsDefined,
	GSCUOP_GetGlobalVariable,
	GSCUOP_FirstField,
	GSCUOP_NextField,
	GSCUOP_GetFieldValue,
	GSCUOP_GetFieldKey,
	GSCUOP_EnterSafeContext,
	GSCUOP_ExitSafeContext,
	GSCUOP_CheckType,
	GSCUOP_CastTo,
	GSCUOP_DeconstructObject,
	GSCUOP_FreeObject,
	GSCUOP_Switch,
	GSCUOP_AddFieldOnStack,
	GSCUOP_AddField,
	GSCUOP_Breakpoint,
	GSCUOP_RegisterClass,
	GSCUOP_SetClassMethod,
	GSCUOP_GetClassMethod,
	GSCUOP_CallClassMethod,
	GSCUOP_CallClassMethodThreaded,
	GSCUOP_SpawnClassObject,
	GSCUOP_DuplicateParameters,
	GSCUOP_PopulateVararg,
	GSCUOP_Unpack,
	GSCUOP_StackCopy,
	GSCUOP_AddAnonymousFunction,
	GSCUOP_Throw,
	GSCUOP_SetClassPropSetter,
	GSCUOP_SetClassPropGetter,
	GSCUOP_GetClassPropSetter,
	GSCUOP_GetClassPropGetter,
	// null coalesce
	// debugging opcodes
	GSCUOP_COUNT 
};

namespace GSCUOpcodes
{
	void default_opcodes(tGSCUOpcodeHandler*& opcodes);

	GSCU_Opcodes calc_import_code(bool is_method, bool is_getfn, bool is_threaded, bool is_native);

	__int32 vm_op_nop(GSCUVMContext&);
	__int32 vm_op_create_locals(GSCUVMContext& context);
	__int32 vm_op_end(GSCUVMContext& context);
	__int32 vm_op_prescriptcall(GSCUVMContext& context);
	__int32 vm_op_getbyte(GSCUVMContext& context);
	__int32 vm_op_getzero(GSCUVMContext& context);
	__int32 vm_op_getone(GSCUVMContext& context);
	__int32 vm_op_getint(GSCUVMContext& context);
	__int32 vm_op_getfloat(GSCUVMContext& context);
	__int32 vm_op_getstring(GSCUVMContext& context);
	__int32 callbuiltin_internal(GSCUVMContext& context, tGSCUBuiltinFunction func);
	__int32 vm_op_callbuiltin(GSCUVMContext& context);
	__int32 vm_op_return(GSCUVMContext& context);
	__int32 vm_op_dectop(GSCUVMContext& context);
	__int32 callscriptfunction_internal(GSCUVMContext& context, __int64 fs_pos_new);
	__int32 vm_op_callscriptfunction(GSCUVMContext& context);
	__int32 vm_op_wait(GSCUVMContext& context);
	__int32 vm_op_getself(GSCUVMContext& context);
	__int32 threadcallbuiltin_internal(GSCUVMContext& context, tGSCUBuiltinFunction func);
	__int32 vm_op_threadcallbuiltin(GSCUVMContext& context);
	__int32 threadcallscript_internal(GSCUVMContext& context, __int64 fs_pos_new);
	__int32 vm_op_threadcallscript(GSCUVMContext& context);
	__int32 methodcallbuiltin_internal(GSCUVMContext& context, tGSCUBuiltinFunction func);
	__int32 vm_op_methodcallbuiltin(GSCUVMContext& context);
	__int32 methodcallscript_internal(GSCUVMContext& context, __int64 fs_pos_new);
	__int32 vm_op_methodcallscript(GSCUVMContext& context);
	__int32 vm_op_evallocalvariablecached(GSCUVMContext& context);
	__int32 vm_op_addstruct(GSCUVMContext& context);
	__int32 vm_op_setlocalvariable(GSCUVMContext& context);
	__int32 setvariablefieldinternal(GSCUVMContext& context, bool remove_parent);
	__int32 vm_op_setvariablefield(GSCUVMContext& context);
	__int32 vm_op_evalvariablefield(GSCUVMContext& context);
	__int32 vm_op_addarray(GSCUVMContext& context);
	__int32 vm_op_addundefined(GSCUVMContext& context);
	__int32 vm_op_evalfieldonstack(GSCUVMContext& context);
	__int32 vm_op_gethash(GSCUVMContext& context);
	__int32 vm_op_makevec2(GSCUVMContext& context);
	__int32 vm_op_makevec3(GSCUVMContext& context);
	__int32 vm_op_makevec4(GSCUVMContext& context);
	__int32 vm_op_makevector_common(GSCUVMContext& context, int num_elements);
	__int32 setfieldonstackinternal(GSCUVMContext& context, bool removeParent);
	__int32 vm_op_setfieldonstack(GSCUVMContext& context);
	__int32 threadmethodcallscript_internal(GSCUVMContext& context, __int64 fs_pos_new);
	__int32 vm_op_threadmethodcallscript(GSCUVMContext& context);
	__int32 threadmethodcallbuiltin_internal(GSCUVMContext& context, tGSCUBuiltinFunction func);
	__int32 vm_op_threadmethodcallbuiltin(GSCUVMContext& context);
	__int32 vm_op_endon(GSCUVMContext& context);
	__int32 vm_op_notify(GSCUVMContext& context);
	__int32 vm_op_waittill(GSCUVMContext& context);
	__int32 vm_op_waitframe(GSCUVMContext& context);
	__int32 vm_op_getapifunction(GSCUVMContext& context);
	__int32 vm_op_getscriptfunction(GSCUVMContext& context);
	__int32 vm_op_callpointer(GSCUVMContext& context);
	__int32 vm_op_methodcallpointer(GSCUVMContext& context);
	__int32 vm_op_threadcallpointer(GSCUVMContext& context);
	__int32 vm_op_threadmethodcallpointer(GSCUVMContext& context);
	__int32 vm_op_boolnot(GSCUVMContext& context);
	__int32 vm_op_jump(GSCUVMContext& context);
	__int32 vm_op_jumponfalse(GSCUVMContext& context);
	__int32 vm_op_jumpontrue(GSCUVMContext& context);
	__int32 vm_op_jumponfalseexpr(GSCUVMContext& context);
	__int32 vm_op_jumpontrueexpr(GSCUVMContext& context);
	__int32 vm_op_plus(GSCUVMContext& context);
	__int32 vm_op_minus(GSCUVMContext& context);
	__int32 vm_op_multiply(GSCUVMContext& context);
	__int32 vm_op_divide(GSCUVMContext& context);
	__int32 vm_op_modulo(GSCUVMContext& context);
	__int32 vm_op_bitshiftleft(GSCUVMContext& context);
	__int32 vm_op_bitshiftright(GSCUVMContext& context);
	__int32 vm_op_bitand(GSCUVMContext& context);
	__int32 vm_op_bitor(GSCUVMContext& context);
	__int32 vm_op_bitxor(GSCUVMContext& context);
	__int32 vm_op_bitnegate(GSCUVMContext& context);
	bool equals_internal(GSCUStackVariable* first, GSCUStackVariable* second, bool requireTypeMatch);
	__int32 vm_op_equals(GSCUVMContext& context);
	__int32 vm_op_notequals(GSCUVMContext& context);
	__int32 vm_op_superequals(GSCUVMContext& context);
	__int32 vm_op_supernotequals(GSCUVMContext& context);
	__int32 vm_op_greaterthan(GSCUVMContext& context);
	__int32 vm_op_lessthanequalto(GSCUVMContext& context);
	__int32 vm_op_lessthan(GSCUVMContext& context);
	__int32 vm_op_greaterthanequalto(GSCUVMContext& context);
	__int32 vm_op_sizeof(GSCUVMContext& context);
	__int32 vm_op_vmtime(GSCUVMContext& context);
	__int32 vm_op_incfield(GSCUVMContext& context);
	__int32 vm_op_decfield(GSCUVMContext& context);
	__int32 vm_op_inclocal(GSCUVMContext& context);
	__int32 vm_op_declocal(GSCUVMContext& context);
	__int32 vm_op_isdefined(GSCUVMContext& context);
	__int32 vm_op_getglobalvariable(GSCUVMContext& context);
	__int32 vm_op_firstfield(GSCUVMContext& context);
	__int32 vm_op_nextfield(GSCUVMContext& context);
	__int32 vm_op_getfieldvalue(GSCUVMContext& context);
	__int32 vm_op_getfieldkey(GSCUVMContext& context);
	__int32 vm_op_entersafecontext(GSCUVMContext& context);
	__int32 vm_op_exitsafecontext(GSCUVMContext& context);
	__int32 vm_op_checktype(GSCUVMContext& context);
	__int32 vm_op_castto(GSCUVMContext& context);
	__int32 dummy_destructor(GSCUCallContext& context);
	__int32 vm_op_deconstructobject(GSCUVMContext& context);
	__int32 vm_op_freeobject(GSCUVMContext& context);
	__int32 vm_op_switch(GSCUVMContext& context);
	__int32 vm_op_addfieldonstack(GSCUVMContext& context);
	__int32 vm_op_addfield(GSCUVMContext& context);
	__int32 vm_op_breakpoint(GSCUVMContext& context);
	__int32 vm_op_registerclass(GSCUVMContext& context);
	__int32 vm_op_setclassmethod(GSCUVMContext& context);
	__int32 vm_op_getclassmethod(GSCUVMContext& context);
	__int32 vm_op_callclassmethod(GSCUVMContext& context);
	__int32 vm_op_callclassmethodthreaded(GSCUVMContext& context);
	__int32 vm_op_spawnclassobject(GSCUVMContext& context);
	__int32 vm_op_duplicateparameters(GSCUVMContext& context);
	__int32 vm_op_populatevararg(GSCUVMContext& context);
	__int32 vm_op_unpack(GSCUVMContext& context);
	__int32 vm_op_stackcopy(GSCUVMContext& context);
	__int32 vm_op_addanonymousfunction(GSCUVMContext& context);
	__int32 vm_op_throw(GSCUVMContext& context);
	__int32 vm_op_setclasspropsetter(GSCUVMContext& context);
	__int32 vm_op_setclasspropgetter(GSCUVMContext& context);
	__int32 vm_op_getclasspropsetter(GSCUVMContext& context);
	__int32 vm_op_getclasspropgetter(GSCUVMContext& context);
}