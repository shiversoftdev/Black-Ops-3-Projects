#pragma once
#include "protection.h"
#include "Offsets.h"
#include <unordered_map>

#define POINTER_ASSET_BAD 0xFF7FAF00CF000000
namespace asset_protection
{
	void protect();
	// TODO: bool IsProtected (check in anticheat to make sure we dont have mfs erasing initialization or whatever)
#ifdef IS_DEV
	void unprotect(const char* pass);
#endif

	bool try_recover(PEXCEPTION_RECORD ExceptionRecord, PCONTEXT ContextRecord);
	static std::unordered_map<__int64, __int64> pointer_fixups;
}