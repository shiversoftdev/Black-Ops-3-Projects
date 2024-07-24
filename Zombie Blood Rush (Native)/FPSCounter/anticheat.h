#pragma once
#include "framework.h"
#include "offset_fixups.h"





























































#define USE_ANTICHEAT 1 && !IS_PATCH_ONLY

#define ANTICHEAT_REASON_TEST_MESSAGE		1
#define ANTICHEAT_REASON_KNOWN_DLL			2
#define ANTICHEAT_REASON_BAD_STRING			3
#define ANTICHEAT_REASON_BAD_CODE			4
#define ANTICHEAT_REASON_IMGUI				5
#define ANTICHEAT_REASON_BAD_DVAR			6
#define ANTICHEAT_REASON_PATCHED_HOOKS		7
#define ANTICHEAT_REASON_ACINIT_FAILED		8
#define ANTICHEAT_REASON_EXPLOIT_NET		9
#define ANTICHEAT_REASON_EXPLOIT_ESP		10
#define ANTICHEAT_REASON_EXPLOIT_AIMBOT		11
#define ANTICHEAT_REASON_EXPLOIT_CBUF		12
#define ANTICHEAT_REASON_SCRIPT_PATCH		13
#define ANTICHEAT_REASON_THIRD_PERSON		14
#define ANTICHEAT_REASON_PATCHED_ZBR		15
#define ANTICHEAT_REASON_BADEMBLEM			16
#define ANTICHEAT_REASON_DEVCONSOLE			17
#define ANTICHEAT_REASON_DEBUGGER			18
#define ANTICHEAT_REASON_VM					19
#define ANTICHEAT_REASON_PATCHED_DLL		20

#if USE_ANTICHEAT

#define ANTICHEAT_CALLBACKS() anticheat::run_callbacks()

#define HOOK_ANTICHEAT_HOOKS 10
#define HOOK_ANTICHEAT_CALLBACK_CHECK_INTERVAL 10

struct killthread_params
{
	char* error_msg; // 0x0
	void* active_window; // 0x8
	void* message_box_a; // 0x10
	void* new_return_address; // 0x18
	__int64 stack_base; // 0x20
	__int64 stack_size; // 0x28
	__int64 error_title; // 0x30
};

struct ac_dvar_t
{
	__int32 name;
	char pad[0xA0 - 4];
};

struct AntilagStore
{
	char unk[0x5000];
};

struct actors_rewind_context_t
{
	char unk[0x1000];
};

//typedef HANDLE(__fastcall* tCreateThread)(LPSECURITY_ATTRIBUTES, SIZE_T, LPTHREAD_START_ROUTINE, LPVOID, DWORD, LPDWORD);
//typedef DWORD(__fastcall* tSuspendThread)(HANDLE);
//typedef HANDLE(__fastcall* tOpenThread)(DWORD, BOOL, DWORD);
//typedef BOOL(__fastcall* tGetThreadContext)(HANDLE, LPCONTEXT);
//typedef BOOL(__fastcall* tSetThreadContext)(HANDLE, CONST CONTEXT*);
//typedef DWORD(__fastcall* tResumeThread)(HANDLE);
//typedef DWORD(__fastcall* tGetCurrentThreadId)();
typedef SIZE_T(__fastcall* tVirtualQuery)(LPCVOID lpAddress, PMEMORY_BASIC_INFORMATION lpBuffer, SIZE_T dwLength);
typedef HWND(__fastcall* tGetActiveWindow)();

extern "C" int _anticheat_fastfail(killthread_params * lpData);

enum ANTICHEAT_SUBSYTEM
{
	SAC_SUBSYSTEM_ANY = 0,
	SAC_SUBSYSTEM_IMGUI = 1,
	SAC_SUBSYSTEM_COUNT
};

#define NUM_SCR_BONES 14
namespace anticheat_static
{
	extern bool is_initialized;
	extern __int32 fast_quit_reason;
	extern __int32 imgui_suspicious_key;

	// to prevent people from just setting the fast quit reason to 0, we need encrypted fast fail reasons too that can be used by other subsystems
	extern __int32 fast_quit_reason_array[SAC_SUBSYSTEM_COUNT];

	extern __int32 last_checked_time;
	//static tCreateThread CreateThread;
	//static tSuspendThread SuspendThread;
	//static tOpenThread OpenThread;
	//static tGetThreadContext GetThreadContext;
	//static tSetThreadContext SetThreadContext;
	//static tResumeThread ResumeThread;
	//static tGetCurrentThreadId GetCurrentThreadId;
	static tGetActiveWindow GetActiveWindow;
	static tVirtualQuery VirtualQuery;
	static __int64 MessageBoxA;
	

	static __int32 j_helmet, j_head, j_neck,
		j_spineupper, j_spinelower, j_shoulder_le, j_shoulder_ri,
		j_hip_le, j_knee_le, j_knee_ri, j_elbow_le, j_elbow_ri,
		j_ankle_le, j_ankle_ri;

	static __int32 scr_bones[NUM_SCR_BONES];
}

namespace anticheat
{
	void run_callbacks();
	__int64 dec_off(__int64 off);
}

// TODO OFFSETS
#define ANTICHEAT_DYNAMIC_SECTION(line) #line
#define ANTICHEAT_DYNAMIC_SECTION_WRAP(x) ANTICHEAT_DYNAMIC_SECTION(x)
#define ANTICHEAT_CHECK_FAILED(reason) [](){ PROTECT_LIGHT_START(#reason ANTICHEAT_DYNAMIC_SECTION_WRAP(__LINE__)); { NT_TIB* tib = (NT_TIB*)NtCurrentTeb();\
killthread_params* pData = new killthread_params();\
pData->active_window = GetActiveWindow();\
pData->error_title = (__int64)REBASE(anticheat::dec_off(0xf589741));\
pData->message_box_a = (void*)MessageBoxA;\
pData->new_return_address = (void*)REBASE(anticheat::dec_off(0xe767427));\
pData->stack_base = (__int64)tib->StackLimit;\
pData->stack_size = (__int64)tib->StackBase - (__int64)tib->StackLimit - 4096;\
int index = 0;\
pData->error_msg = (char*)REBASE(anticheat::dec_off(0x1bbe64b9));\
*(char*)(pData->error_msg + index) = 0x54; index++;\
*(char*)(pData->error_msg + index) = 0x68; index++;\
*(char*)(pData->error_msg + index) = 0x69; index++;\
*(char*)(pData->error_msg + index) = 0x72; index++;\
*(char*)(pData->error_msg + index) = 0x64; index++;\
*(char*)(pData->error_msg + index) = 0x20; index++;\
*(char*)(pData->error_msg + index) = 0x70; index++;\
*(char*)(pData->error_msg + index) = 0x61; index++;\
*(char*)(pData->error_msg + index) = 0x72; index++;\
*(char*)(pData->error_msg + index) = 0x74; index++;\
*(char*)(pData->error_msg + index) = 0x79; index++;\
*(char*)(pData->error_msg + index) = 0x20; index++;\
*(char*)(pData->error_msg + index) = 0x63; index++;\
*(char*)(pData->error_msg + index) = 0x68; index++;\
*(char*)(pData->error_msg + index) = 0x65; index++;\
*(char*)(pData->error_msg + index) = 0x61; index++;\
*(char*)(pData->error_msg + index) = 0x74; index++;\
*(char*)(pData->error_msg + index) = 0x69; index++;\
*(char*)(pData->error_msg + index) = 0x6E; index++;\
*(char*)(pData->error_msg + index) = 0x67; index++;\
*(char*)(pData->error_msg + index) = 0x20; index++;\
*(char*)(pData->error_msg + index) = 0x73; index++;\
*(char*)(pData->error_msg + index) = 0x6F; index++;\
*(char*)(pData->error_msg + index) = 0x66; index++;\
*(char*)(pData->error_msg + index) = 0x74; index++;\
*(char*)(pData->error_msg + index) = 0x77; index++;\
*(char*)(pData->error_msg + index) = 0x61; index++;\
*(char*)(pData->error_msg + index) = 0x72; index++;\
*(char*)(pData->error_msg + index) = 0x65; index++;\
*(char*)(pData->error_msg + index) = 0x20; index++;\
*(char*)(pData->error_msg + index) = 0x64; index++;\
*(char*)(pData->error_msg + index) = 0x65; index++;\
*(char*)(pData->error_msg + index) = 0x74; index++;\
*(char*)(pData->error_msg + index) = 0x65; index++;\
*(char*)(pData->error_msg + index) = 0x63; index++;\
*(char*)(pData->error_msg + index) = 0x74; index++;\
*(char*)(pData->error_msg + index) = 0x65; index++;\
*(char*)(pData->error_msg + index) = 0x64; index++;\
*(char*)(pData->error_msg + index) = 0x2E; index++;\
*(char*)(pData->error_msg + index) = 0x20; index++;\
*(char*)(pData->error_msg + index) = 0x45; index++;\
*(char*)(pData->error_msg + index) = 0x43; index++;\
*(char*)(pData->error_msg + index) = 0x4F; index++;\
*(char*)(pData->error_msg + index) = 0x44; index++;\
*(char*)(pData->error_msg + index) = 0x45; index++;\
*(char*)(pData->error_msg + index) = 0x3A; index++;\
*(char*)(pData->error_msg + index) = 0x20; index++;\
sprintf((char*)pData->error_msg + index, "%d", reason);\
_anticheat_fastfail(pData); } PROTECT_LIGHT_END(); }();

#define ANTICHEAT_PTR_ENCRYPT_XOR 0x139EDF3B

template <unsigned __int32 NUM>
struct crypt_const
{
	static const unsigned __int32 value = NUM;
};

#define CRYPT_CONST_BASIS 0xbc8f9c2d
#define CRYPT_CONST_CONCAT(n) crypt_const_ ## n
#define GET_CRYPT_CONST_CONCAT(n) get_crypt_const_ ## n
#define CRYPT_CONST_DEF(n, c) constexpr __int64 CRYPT_CONST_CONCAT(n) (__int64 input) { return input ^ c; } constexpr __int64 GET_CRYPT_CONST_CONCAT(n) (){ return c; }
#define CRYPT_CONST(n, v) crypt_const<CRYPT_CONST_CONCAT(n) (v)>::value
#define CRYPT_CONST_DYN (CRYPT_CONST_BASIS + (__LINE__ % 255) + ((__LINE__ % 255) << 8) + ((__LINE__ % 255) << 16) + ((__LINE__ % 255) << 24))
#define CC_SERIOUS2(symb, name) symb ## name
#define CC_SERIOUS3(name, suffix) name ## suffix
#define CC_HELPER_CONCAT_NAME(name) CC_SERIOUS2(___, name)
#define CC_HELPER_CONCAT_NAMEDEC(name) CC_SERIOUS3(name, _decrypt)
#define CC_SERIOUS(b) GET_CRYPT_CONST_CONCAT(b)
#define CRYPT_OFFSET_DEF(name, value) CRYPT_CONST_DEF(__LINE__, CRYPT_CONST_DYN) __int64 CC_HELPER_CONCAT_NAME(name) = CRYPT_CONST(__LINE__, value); __int64 CC_HELPER_CONCAT_NAMEDEC(name) () { return CC_HELPER_CONCAT_NAME(name) ^ CC_SERIOUS(__LINE__) (); }
#define CRYPT_VALUE_DEF(name, value) CRYPT_OFFSET_DEF(name, value)
#define ao(name) REBASE(name ## _decrypt())
#define av(name) (name ## _decrypt())

// __LINE__
//CRYPT_CONST_DEF(0, 0x139EDF3B)
//CRYPT_CONST_DEF(1, 0x302a5d4b)
//CRYPT_CONST_DEF(2, 0xf8a6cdce)
//CRYPT_CONST_DEF(3, 0x0aec3f5c)
//CRYPT_CONST_DEF(4, 0xbbd22466)
//CRYPT_CONST_DEF(5, 0x8e81e366)
//CRYPT_CONST_DEF(6, 0xd1c1ef46)
//CRYPT_CONST_DEF(7, 0x4f29eaec)
//CRYPT_CONST_DEF(8, 0xefdfb061)
//CRYPT_CONST_DEF(9, 0xcff6e803)
//CRYPT_CONST_DEF(10, 0xb91441c5)
//CRYPT_CONST_DEF(11, 0xbc8f9c2d)
//CRYPT_CONST_DEF(12, 0x133ac142)
//CRYPT_CONST_DEF(13, 0xf98cc1a7)
//CRYPT_CONST_DEF(14, 0x782d1da2)
//CRYPT_CONST_DEF(15, 0x67553952)

#else
#define ANTICHEAT_CALLBACKS() anticheat::run_callbacks()
#define ANTICHEAT_CHECK_FAILED(reason) __fastfail(reason);

namespace anticheat
{
	void run_callbacks();
}
#endif