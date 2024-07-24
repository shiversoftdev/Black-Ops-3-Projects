#pragma once
#include "framework.h"
#include "Offsets.h"
#include <functional>
#include <vector>

typedef unsigned long long(__fastcall* tZwContinue)(PCONTEXT ThreadContext, BOOLEAN RaiseAlert);

struct hook_info
{
	std::function<void(void)> enable;
	std::function<void(void)> disable;
	__int64 id;
};

namespace arxan_evasion
{
	// by serious. if you remove this from your source you are a leech.
	void initialize(); // must be called before anything else
	void register_hook(std::function<void(void)> enable, std::function<void(void)> disable, bool enable_immediate);
	void register_hook_unique(__int64 id, std::function<void(void)> enable, std::function<void(void)> disable, bool enable_immediate);
	void dispatch_exceptions(PEXCEPTION_RECORD ExceptionRecord, PCONTEXT ContextRecord); // must be called in your exception handlers
	void uninstall();
	void mod_dr1(PEXCEPTION_RECORD ExceptionRecord, PCONTEXT ContextRecord);

	void disable_hooks();
	void enable_hooks();

	static bool hooks_enabled;
	static __int32 load_index = 0;
	static std::vector<hook_info> hooks;
	static std::vector<__int64> old_return_address_stack;
	static bool was_initialized;
	static tZwContinue ZwContinue;
}