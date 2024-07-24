#pragma once
#include "GSCObj.h"
#include "GSCUVars.h"
#include <sys\timeb.h> 
#include <unordered_map>
#include <unordered_set>
#include <stack>
#include <functional>
#include "GSCUHashing.h"
#include "gscu_api.h"

#if defined _DEBUG
// OPTIONAL DEBUG CONFIG VARS
#define DEVELOPMENT

#define VME_DUMP
// #define VME_DEBUG
// #define VME_DUMP_PER_SOP
// #define VME_DUMP_MEM_REFS

// #define LNKINFO

#endif

// time in MS that the vm will wait to tick
#define VM_DEFAULT_TICK_RATE 50
#define GSCU_MAX_GLOBALS 64
#define GSCU_MAX_THREADS 2048
#define BATCH_ALLOC_VARS 2048
#define GSCU_SUCCESS 0
#define GSCU_ERROR 0x80000000
#define GSCU_BADVAR 0xFFFFFFFF
#define GSCU_FIELDACCESS_SIMPLE 1
#define GSCU_FIELDACCESS_FAIL 2

#define GSCU_ERROR_GLINK 0x00010000
#define GSCU_ERROR_GLOAD 0x00020000
#define GSCU_ERROR_RUNTIME 0x00030000
#define GSCU_ERROR_API 0x00040000
#define GSCU_ERROR_VM 0x00050000

// null pointer was passed in a parameter that cannot be null
#define GSCU_ERROR_GLINK_NULLBUFFER (GSCU_ERROR | GSCU_ERROR_GLINK | 0x00)

// script was expected to be loaded and could not be found
#define GSCU_ERROR_GLINK_MISSINGSCRIPT (GSCU_ERROR | GSCU_ERROR_GLINK | 0x01)

// expected a global script loaded by the context but instead found a raw object pointer
#define GSCU_ERROR_GLINK_LOCALBUFFER (GSCU_ERROR | GSCU_ERROR_GLINK | 0x02)

// ran out of globals while linking a new script
#define GSCU_ERROR_GLINK_OUTOFGLOBALS (GSCU_ERROR | GSCU_ERROR_GLINK | 0x03)

// failed to find api imported by script
#define GSCU_ERROR_GLINK_MISSINGAPI (GSCU_ERROR | GSCU_ERROR_GLINK | 0x04)

// null pointer was passed in a parameter that cannot be null
#define GSCU_ERROR_GLOAD_NULLBUFFER (GSCU_ERROR | GSCU_ERROR_GLOAD | 0x00)

// tried to allocate memory for a new buffer but malloc failed
#define GSCU_ERROR_GLOAD_OUTOFMEMORY (GSCU_ERROR | GSCU_ERROR_GLOAD | 0x01)

// ran out of variables at runtime
#define GSCU_ERROR_RUNTIME_OUTOFVARIABLES (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0x00)

// ran out of globals at runtime
#define GSCU_ERROR_RUNTIME_OUTOFGLOBALS (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0x01)

// hit an invalid opcode at runtime
#define GSCU_ERROR_RUNTIME_INVALIDOPCODE (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0x02)

// tried to get a reference to an unknown variable
#define GSCU_ERROR_RUNTIME_UNKNOWNVAR (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0x03)

// tried to perform a field operation on a non-struct variable
#define GSCU_ERROR_RUNTIME_NOTASTRUCT (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0x04)

// a type was unhandled in a strict context
#define GSCU_ERROR_RUNTIME_TYPEESCAPEEXCEPTION (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0x05)

// tried to construct a vector with dimensions not in [2,4]
#define GSCU_ERROR_VM_BADVECDIMENSIONS (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0x06)

// tried to construct a vector with bad components
#define GSCU_ERROR_VM_BADVECCOMPONENTS (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0x07)

// tried to subscribe to events of an unknown parent
#define GSCU_ERROR_RUNTIME_UNKEVENTPARENT (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0x08)

// tried to cast a variable to a type which it cannot be casted to
#define GSCU_ERROR_RUNTIME_INVALIDCAST (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0x09)

// tried to perform a math operation on two operands which are incompatible either with each other or the operator
#define GSCU_ERROR_RUNTIME_INVALIDOPERANDS (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0x0A)

// tried to allocate a string but failed for some reason. This is a fatal error no matter what.
#define GSCU_ERROR_RUNTIME_FAILEDSTRINGALLOC (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0x0B)

// tried to register a class, but something went wrong
#define GSCU_ERROR_RUNTIME_CLASSREGISTERFAILURE (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0x0C)

// tried to modify a class, but something went wrong
#define GSCU_ERROR_RUNTIME_CLASSPROPFAILURE (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0x0D)

// array index was out of bounds
#define GSCU_ERROR_RUNTIME_ARRAYOOB (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0xE)

// operation was invalid for supplied operand
#define GSCU_ERROR_RUNTIME_INVALIDOPERATION (GSCU_ERROR | GSCU_ERROR_RUNTIME | 0xF)

// a builtin was registered twice
#define GSCU_ERROR_API_DUPLICATEBUILTIN (GSCU_ERROR | GSCU_ERROR_API | 0x00)

// an api get call was mismatched with the variable on the stack at that index
#define GSCU_ERROR_API_TYPEMISMATCH (GSCU_ERROR | GSCU_ERROR_API | 0x01)

// a builtin was registered with a null action func
#define GSCU_ERROR_API_NULLBUILTIN (GSCU_ERROR | GSCU_ERROR_API | 0x01)

// tried to set the vm tick speed to 0 ms (infinity speed)
#define GSCU_ERROR_API_ZEROTICK (GSCU_ERROR | GSCU_ERROR_API | 0x02)

// used a bad wait parameter
#define GSCU_ERROR_VM_BADWAITPARAM (GSCU_ERROR | GSCU_ERROR_VM | 0x00)

// used a bad self parameter
#define GSCU_ERROR_VM_BADSELF (GSCU_ERROR | GSCU_ERROR_VM | 0x01)

// tried to get a reference to a bad local variable
#define GSCU_ERROR_VM_BADVARREF (GSCU_ERROR | GSCU_ERROR_VM | 0x02)

// tried to call a non-function pointer
#define GSCU_ERROR_VM_NOTAFUNCTION (GSCU_ERROR | GSCU_ERROR_VM | 0x3)

// the stack was found to be in an unexpected state
#define GSCU_ERROR_VM_STACKMISALIGNMENT (GSCU_ERROR | GSCU_ERROR_VM | 0x4)

// the method to be called by the vm was not a class method
#define GSCU_ERROR_VM_INVALIDMETHOD (GSCU_ERROR | GSCU_ERROR_VM | 0x5)

// the class to be constructed does not exist
#define GSCU_ERROR_VM_INVALIDCLASS (GSCU_ERROR | GSCU_ERROR_VM | 0x6)

#define GSCU_REQUIRE_SUCCESS(x) assert(!x); if(x) return x

#define GSCU_LINKFUNC_KEY(name, space) (((__int64)(unsigned __int32)name << 32) | (__int64)(unsigned __int32)space)

// Ensure that the current function is in a success state or stop executing this native and continue executing the thread
#define API_ENSURE_SUCCESS(context) if (context.last_error()) return 0;

// Return the last error as a fatal error
#define API_BUBBLE_WARNING(context) return context.last_error()

// Ensure that the current function is in a success state or stop executing this thread.
#define API_CRITICAL_SUCCESS(context) if (context.last_error()) API_BUBBLE_WARNING(context)

#define API_CALL unsigned __int32 __fastcall

#if defined DEVELOPMENT
#define DPRINT(fmt, ...) printf(fmt "\n", __VA_ARGS__)
#else
#define DPRINT(...) 
#endif

#if defined VME_DUMP || defined VME_DEBUG
#define VME_DUMPVM() dump_vm_stats()
#else
#define VME_DUMPVM()
#endif

#if defined VME_DEBUG
#define VME_DPRINT(fmt, ...) printf(fmt "\n", __VA_ARGS__)
#else
#define VME_DPRINT(...) 
#endif

#ifdef LNKINFO
#define LDPRINT(fmt, ...) DPRINT(fmt, __VA_ARGS__)
#else
#define LDPRINT(fmt, ...) 
#endif

struct GSCUVMContext
{
	GSCUThreadContext* thread;
	void* vmc;
	__int32 self;
	bool doquit;
};

typedef __int32(__cdecl* tGSCUOpcodeHandler)(GSCUVMContext&);

struct GSCUCallContext
{
	GSCUThreadContext* thread;
	void* vmc;
	__int32 self;
	bool doquit;

	__int32 num_params();
	__int32 last_error();
};

typedef __int32(__cdecl* tGSCUBuiltinFunction)(GSCUCallContext&);

struct GSCUBuiltinInfo
{
	unsigned __int32 name;
	unsigned __int32 space;
	unsigned __int8 min_params;
	unsigned __int8 max_params;
	unsigned __int8 reserved[2];
	unsigned __int32 flags;

	tGSCUBuiltinFunction func;

	bool has_flag(GSCUExportFlags flag)
	{
		return flags & flag;
	}
};

struct GSCUExceptionDispatcher
{
	unsigned __int64 start_protect;
	unsigned __int64 end_protect;
	unsigned __int64 handler;
};

// Primary VM Context tracker. Manages all runtime information and should act as a singleton for all sub-contexts.
class GContext
{

public:

	char last_link_error[2048];
	char last_runtime_error[2048];
	__int32 last_error_code;

	GContext(GContext* super);

	GContext* global();

	__int32 link(GSCObj* obj);

	// TODO __int32 unload(name) and can only unload if bad, unlinked, or the vm is restarting
	__int32 load(GSCObj* obj, GSCObj*& out_obj);

	__int32 create_thread(void* fs_pos, bool is_script_thread, unsigned __int32 parent_id, unsigned __int8 num_params);
	__int32 thread_pop_parent(unsigned __int32 id, unsigned __int32 parent);
	__int32 thread_push_parent(unsigned __int32 id, unsigned __int32 parent);
	void suspend_thread_for_time(unsigned __int32 id, unsigned __int32 wait_ms);
	__int32 vm_execute(__int32 thread_id);
	__int32 vm_tick();
	__int32 get_time();

	__int32 alloc_variable(unsigned __int32 name, unsigned __int32 parent_id);
	void free_variable(unsigned __int32 id);
	__int32 alloc_global(unsigned __int32 name);
	void add_variable_ref(unsigned __int32 id);
	void remove_variable_ref(unsigned __int32 id);
	void thread_dispose(unsigned __int32 id);
	void thread_terminate_subscribe(unsigned __int32 id, std::function<void(void*)> fn_event);
	void thread_recover(GSCUVMContext& context);
	void stack_dispose(GSCUStackVariable* stack_var, GSCUThreadContext* thread);
	void heap_dispose(GSCUHeapVariable* variable);
	void stack_set(GSCUStackVariable* dest, GSCUVariableType source_type, GSCUVarValue source_value, GSCUThreadContext* thread);
	void stack_transfer(GSCUThreadContext* dest_thread, GSCUThreadContext* source_thread, unsigned __int8 num_elems, bool bClearFromSource);
	GSCUThreadContext* get_main_thread();
	void heap_to_stack(GSCUStackVariable* dest, GSCUHeapVariable* source);
	void stack_to_heap(GSCUHeapVariable* dest, GSCUStackVariable* source);
	__int32 stack_to_canon(GSCUStackVariable* source, unsigned __int32& out_canon);
	__int32 stack_to_canon64(GSCUStackVariable* source, unsigned __int64& out_canon);
	__int32 set_field_accessor(unsigned __int32 parent_id, unsigned __int32 field_name, GSCUStackVariable* value, GSCUVMContext& context, std::function<void(void*)> fn_finished);
	__int32 get_field_accessor(unsigned __int32 parent_id, unsigned __int32 field_name, GSCUStackVariable* out, GSCUVMContext& context, std::function<void(void*)> fn_finished);
	__int32 set_variable_field(unsigned __int32 parent_id, unsigned __int32 field_name, GSCUStackVariable* value);
	__int32 add_variable_field(unsigned __int32 parent_id, unsigned __int32 field_name);
	__int32 clear_variable_field(unsigned __int32 parent_id, unsigned __int32 field_name);
	__int32 get_variable_field(unsigned __int32 parent_id, unsigned __int32 field_name, GSCUStackVariable* out);
	__int32 array_copy(unsigned __int32 parent_id);
	__int32 struct_copy(unsigned __int32 parent_id);
	__int32 subscribe_events(unsigned __int32 parent_id, unsigned __int32 thread_id, int num_subscriptions);
	__int32 notify(unsigned __int32 object_id, unsigned __int64 event_id, GSCUHeapVariable* struct_value);
	__int32 notify_string(unsigned __int32 object_id, unsigned __int64 event_id);
	__int32 register_class(unsigned __int32 classname, GSCUStackVariable* ctor, GSCUStackVariable* dtor);
	bool is_class_registered(unsigned __int32 classname);
	__int32 set_class_method(unsigned __int32 classname, unsigned __int32 fieldname, GSCUStackVariable* fn);
	__int32 get_class_method(unsigned __int32 classname, unsigned __int32 fieldname, GSCUStackVariable* out);
	__int32 set_class_prop(unsigned __int32 classname, unsigned __int32 fieldname, GSCUStackVariable* fn, bool is_setter);
	__int32 get_class_prop(unsigned __int32 classname, unsigned __int32 fieldname, GSCUStackVariable* fn_out, bool is_setter);
	bool is_class_field_prop(unsigned __int32 classname, unsigned __int32 fieldname);

	void sizeof_variable(unsigned __int32 id, GSCUStackVariable& var_out, GSCUVMContext& context);
	__int32 cast_to_bool(GSCUStackVariable* castRef);
	__int32 cast_to_float(GSCUStackVariable* dest, GSCUStackVariable* source);
	__int32 cast_to_vector(GSCUStackVariable* dest, GSCUStackVariable* source);
	__int32 cast_to_string(GSCUStackVariable* dest, GSCUStackVariable* source);
	__int32 array_to_struct(GSCUHeapVariable* a);
	__int32 struct_to_array(GSCUHeapVariable* s);

	__int32 string_append(GSCUString& dest, GSCUString* first, GSCUString* second);

	bool find_script_function(GSCObj* glob_obj, GSCImport* _import, GSCExport& _export, GSCObj*& parent);
	bool find_builtin_function(GSCObj* glob_obj, GSCImport* _import, GSCUBuiltinInfo& _builtin);
	__int32 register_builtin_function(unsigned __int32 canon_name, unsigned __int32 canon_space, unsigned __int8 min_params, unsigned __int8 max_params, unsigned __int32 flags, tGSCUBuiltinFunction func);

	// not an actual api function, too late to change!
	GSCUHeapVariable* api_get_variable(unsigned __int32 id);

	__int32 debug_suspend(GSCUVMContext& context);
#if defined VME_DEBUG || defined VME_DUMP
	__int32 dump_vm_stats();
#endif
	

	void quit();
	static GContext* __fastcall create();
	static API_CALL api_loadbuffs(GContext* vm, GSCObj** objects, unsigned __int32 count);
	static API_CALL api_linkbuffs(GContext* vm, GSCObj** objects, unsigned __int32 count);
	static API_CALL api_tick(GContext* vm);
	static API_CALL api_copy_last_lnk_error(GContext* vm, char* buff, __int32 size);

	// TODO not in public api yet
	static API_CALL api_register_class(GContext* vm, unsigned __int32 classname, tGSCUBuiltinFunction fn_ctor, tGSCUBuiltinFunction fn_dtor);
	static API_CALL api_register_class_method(GContext* vm, unsigned __int32 classname, unsigned __int32 methodname, tGSCUBuiltinFunction fn);
	static API_CALL api_set_tick_rate(GContext* vm, unsigned __int32 ms);
	static API_CALL api_get_tick_rate(GContext* vm);
	static API_CALL api_last_error(GContext* vm);
	static API_CALL api_get_num_params(GContext* vm, GSCUThreadContext* thread);
	static API_CALL api_get_string(GContext* vm, GSCUThreadContext* thread, __int32 index, const char*& out);
	static API_CALL api_report_error(GContext* vm, unsigned __int32 error_code, const char* msg);
	static API_CALL api_get_struct(GContext* vm, GSCUThreadContext* thread, unsigned __int32 index, unsigned __int32& out_id);
	static API_CALL api_add_array_element(GContext* vm, GSCUThreadContext* thread, unsigned __int32 struct_id);

private:

	// global super context 
	GContext* __global;
	tGSCUOpcodeHandler* opcodes;
	std::unordered_map<__int64, GSCObj*> scripts;
	std::unordered_map<__int64, GSCUBuiltinInfo*> builtins;
	std::unordered_set<unsigned __int32> known_apis;
	GSCUHeapVariable globals[GSCU_MAX_GLOBALS];
	std::stack<unsigned __int32> free_variables;
	std::unordered_map<unsigned __int32, GSCUHeapVariable*> variables;
	std::unordered_map<unsigned __int32, GSCUThreadContext*> threads;
	std::unordered_map<unsigned __int32, unsigned __int64> thread_time_schedule;
	std::unordered_map<unsigned __int32, std::unordered_map<unsigned __int32, unsigned __int32>> event_subscribers;
	std::unordered_map<unsigned __int32, std::unordered_map<unsigned __int32, GSCUClassMember>> classes;
	GSCUStringAllocator strings;
	GSCUThreadContext* main_thread;
	unsigned __int32 current_variable_id = GSCU_MAX_GLOBALS;
	timeb vm_last_tick;
	unsigned __int32 vm_ms_tick;
	unsigned __int64 vm_time;

	__int32 vm;
	__int32 _globals;

	bool has_exited;
	bool is_suspended;
	GSCUVMContext suspend_context;

	GContext();
};