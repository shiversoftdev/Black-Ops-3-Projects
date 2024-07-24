#include "arxan_evasion.h"
#include "mh.h"
#include "protection.h"
#include "anticheat.h"

//// TODO
//#define ARXAN_LUA_JMP OFFSET(0x22F27E0)
//#define ARXAN_LUA_JMPTO OFFSET(0x1D122223)
//
//// TODO
//#define ARXAN_SPOT5_JMP OFFSET(0x135C9A0)
//#define ARXAN_SPOT5_JMPTO OFFSET(0x1EFB79C6)

//#define NO_HOOKS

void arxan_evasion::initialize()
{
	// PROTECT_HEAVY_START("Arxan Evasion");
	if (was_initialized)
	{
		return;
	}

	old_return_address_stack.push_back(0);

	was_initialized = true;
	auto hmod = GetModuleHandleA("ntdll.dll");
	if (hmod)
	{
		ZwContinue = (tZwContinue)GetProcAddress(hmod, "ZwContinue");
	}

	HANDLE hThreadSnap = INVALID_HANDLE_VALUE;
	THREADENTRY32 te32;

	hThreadSnap = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
	te32.dwSize = sizeof(THREADENTRY32);

	if (Thread32First(hThreadSnap, &te32))
	{
		do
		{
			if (te32.th32OwnerProcessID == GetCurrentProcessId() && te32.th32ThreadID != GetCurrentThreadId())
			{
				auto hThread = OpenThread(THREAD_ALL_ACCESS, false, te32.th32ThreadID);

				if (hThread)
				{
					SuspendThread(hThread);
					CONTEXT tContext{};
					tContext.ContextFlags = CONTEXT_DEBUG_REGISTERS;
					if (GetThreadContext(hThread, &tContext))
					{
						arxan_evasion::mod_dr1(0, &tContext);

						tContext.ContextFlags = CONTEXT_DEBUG_REGISTERS;
						SetThreadContext(hThread, &tContext);
					}
					ResumeThread(hThread);
					CloseHandle(hThread);
				}
			}
		} while (Thread32Next(hThreadSnap, &te32));
	}

	CloseHandle(hThreadSnap);

	XLOG("^7Thread context initialized\n");

	__int64 off = INT3_2_BO3;
	((void(__fastcall*)())off)(); // force an exception to install the exception handler and setup debug registers

	//register_hook([]()
	//	{
	//		auto offset = ARXAN_LOBBY_JMP;

	//		auto OldProtection = 0ul;
	//		VirtualProtect((__int32*)offset, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
	//		*(char*)offset = 0xCC;
	//		VirtualProtect((__int32*)offset, 1, OldProtection, &OldProtection);

	//		offset = ARXAN_LOAD_JMP;

	//		OldProtection = 0ul;
	//		VirtualProtect((__int32*)offset, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
	//		*(char*)offset = 0xCC;
	//		VirtualProtect((__int32*)offset, 1, OldProtection, &OldProtection);

	//		/*offset = ARXAN_LUA_JMP;

	//		OldProtection = 0ul;
	//		VirtualProtect((__int32*)offset, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
	//		*(char*)offset = 0xCC;
	//		VirtualProtect((__int32*)offset, 1, OldProtection, &OldProtection);*/

	//		offset = ARXAN_SPOT4_JMP;

	//		OldProtection = 0ul;
	//		VirtualProtect((__int32*)offset, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
	//		*(char*)offset = 0xCC;
	//		VirtualProtect((__int32*)offset, 1, OldProtection, &OldProtection);

	//		/*offset = ARXAN_SPOT5_JMP;

	//		OldProtection = 0ul;
	//		VirtualProtect((__int32*)offset, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
	//		*(char*)offset = 0xCC;
	//		VirtualProtect((__int32*)offset, 1, OldProtection, &OldProtection);*/
	//	},
	//	[]()
	//	{
	//		auto offset = ARXAN_LOBBY_JMP;

	//		auto OldProtection = 0ul;
	//		VirtualProtect((__int32*)offset, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
	//		*(char*)offset = 0xE9;
	//		VirtualProtect((__int32*)offset, 1, OldProtection, &OldProtection);

	//		offset = ARXAN_LOAD_JMP;

	//		OldProtection = 0ul;
	//		VirtualProtect((__int32*)offset, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
	//		*(char*)offset = 0xE9;
	//		VirtualProtect((__int32*)offset, 1, OldProtection, &OldProtection);

	//		/*offset = ARXAN_LUA_JMP;

	//		OldProtection = 0ul;
	//		VirtualProtect((__int32*)offset, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
	//		*(char*)offset = 0xE9;
	//		VirtualProtect((__int32*)offset, 1, OldProtection, &OldProtection);
	//		*/

	//		offset = ARXAN_SPOT4_JMP;

	//		OldProtection = 0ul;
	//		VirtualProtect((__int32*)offset, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
	//		*(char*)offset = 0xE9;
	//		VirtualProtect((__int32*)offset, 1, OldProtection, &OldProtection);

	//		/*offset = ARXAN_SPOT5_JMP;

	//		OldProtection = 0ul;
	//		VirtualProtect((__int32*)offset, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
	//		*(char*)offset = 0xE9;
	//		VirtualProtect((__int32*)offset, 1, OldProtection, &OldProtection);*/

	//	}, true);
	// PROTECT_HEAVY_END();
}

void arxan_evasion::register_hook(std::function<void(void)> enable, std::function<void(void)> disable, bool enable_immediate)
{
#ifndef NO_HOOKS
	hooks.push_back(hook_info());
	hooks.back().disable = disable;
	hooks.back().enable = enable;
	hooks.back().id = 0xFFFFFFFF;

	if (enable_immediate)
	{
		if (!hooks_enabled)
		{
			enable_hooks();
		}
		else
		{
			enable();
		}
	}
#endif
}

void arxan_evasion::register_hook_unique(__int64 id, std::function<void(void)> enable, std::function<void(void)> disable, bool enable_immediate)
{
#ifndef NO_HOOKS
	for (auto it = hooks.begin(); it != hooks.end(); it++)
	{
		if (it->id == id)
		{
			return;
		}
	}
	hooks.push_back(hook_info());
	hooks.back().disable = disable;
	hooks.back().enable = enable;
	hooks.back().id = id;
	if (enable_immediate)
	{
		if (!hooks_enabled)
		{
			enable_hooks();
		}
		else
		{
			enable();
		}
	}
#endif
}

bool is_scanning = false;
void arxan_evasion::mod_dr1(PEXCEPTION_RECORD ExceptionRecord, PCONTEXT ContextRecord)
{
	/*if (is_scanning)
	{
		ContextRecord->Dr1 = END_TXT_FUNCS;
		ContextRecord->Dr7 |= (1 << 2) | (1 << 20) | (1 << 21);
	}
	else
	{
		ContextRecord->Dr1 = BEGIN_TXT_FUNCS;
		ContextRecord->Dr7 |= (1 << 2) | (1 << 20) | (1 << 21);
	}*/
	ContextRecord->Dr1 = 0;
	// ContextRecord->Dr7 |= (1 << 2);
}

void arxan_evasion::dispatch_exceptions(PEXCEPTION_RECORD ExceptionRecord, PCONTEXT ContextRecord)
{
	PROTECT_LIGHT_START("dispatch arxan exceptions");
	if (!was_initialized)
	{
		return;
	}
	arxan_evasion::mod_dr1(ExceptionRecord, ContextRecord);

	auto addy = (__int64)ExceptionRecord->ExceptionAddress;

	if (addy == ARXAN_LOBBY_JMP)
	{
		//disable_hooks();
		ContextRecord->Rip = ARXAN_LOBBY_JMPTO;
		old_return_address_stack.push_back(*(__int64*)ContextRecord->Rsp);
		*(__int64*)ContextRecord->Rsp = INT3_BO3;
		ZwContinue(ContextRecord, false);
	}

	if (addy == ARXAN_LOAD_JMP)
	{
		//disable_hooks();
		ContextRecord->Rip = ARXAN_LOAD_JMPTO;
		old_return_address_stack.push_back(*(__int64*)ContextRecord->Rsp);
		*(__int64*)ContextRecord->Rsp = INT3_BO3;
		ZwContinue(ContextRecord, false);
	}

	//if (addy == ARXAN_LUA_JMP)
	//{
	//	//disable_hooks();
	//	ContextRecord->Rip = ARXAN_LUA_JMPTO;
	//	old_return_address_stack.push_back(*(__int64*)ContextRecord->Rsp);
	//	load_index = old_return_address_stack.size();
	//	*(__int64*)ContextRecord->Rsp = INT3_BO3;
	//	ZwContinue(ContextRecord, false);
	//}

	if (addy == ARXAN_SPOT4_JMP)
	{
		//disable_hooks();
		ContextRecord->Rip = ARXAN_SPOT4_JMPTO;
		old_return_address_stack.push_back(*(__int64*)ContextRecord->Rsp);
		*(__int64*)ContextRecord->Rsp = INT3_BO3;
		ZwContinue(ContextRecord, false);
	}

	//if (addy == ARXAN_SPOT5_JMP)
	//{
	//	//disable_hooks();
	//	ContextRecord->Rip = ARXAN_SPOT5_JMPTO;
	//	old_return_address_stack.push_back(*(__int64*)ContextRecord->Rsp);
	//	*(__int64*)ContextRecord->Rsp = INT3_BO3;
	//	ZwContinue(ContextRecord, false);
	//}

	if (addy == INT3_BO3)
	{
		//enable_hooks();
		ContextRecord->Rip = old_return_address_stack.back();
		if (load_index == old_return_address_stack.size())
		{
			load_index = 0;
		}
		old_return_address_stack.pop_back();
		ZwContinue(ContextRecord, false);
	}

	if (addy == INT3_2_BO3)
	{
		ContextRecord->Rip = ROP_RETN;
		ZwContinue(ContextRecord, false);
	}

	// .text	000000001AAEC000	000000001FAB0000 arxan
	if (ExceptionRecord->ExceptionCode == STATUS_SINGLE_STEP && addy >= ARXAN_BEGIN && addy <= ARXAN_END) // arxan and we hit a dr for integrity
	{
		if (!is_scanning)
		{
			XLOG("Begin scan...");
			disable_hooks();
			is_scanning = true;
		}
		else
		{
			XLOG("End scan...");
			is_scanning = false;
			enable_hooks();
		}

		mod_dr1(ExceptionRecord, ContextRecord);
		ZwContinue(ContextRecord, false);
	}
	PROTECT_LIGHT_END();
}

void arxan_evasion::uninstall()
{
	PROTECT_LIGHT_START("arxan_evasion::uninstall");
	disable_hooks();
	was_initialized = false;
	PROTECT_LIGHT_END();
}

void arxan_evasion::disable_hooks()
{
	PROTECT_LIGHT_START("Disable Hooks fn");
	if (!hooks_enabled)
	{
		return;
	}
	hooks_enabled = false;
	for (auto it = hooks.begin(); it != hooks.end(); it++)
	{
		it->disable();
	}
	PROTECT_LIGHT_END();
}

void arxan_evasion::enable_hooks()
{
	PROTECT_LIGHT_START("Disable Hooks fn");
	if (hooks_enabled)
	{
		return;
	}
	hooks_enabled = true;
	for (auto it = hooks.begin(); it != hooks.end(); it++)
	{
		it->enable();
	}
	PROTECT_LIGHT_END();
}