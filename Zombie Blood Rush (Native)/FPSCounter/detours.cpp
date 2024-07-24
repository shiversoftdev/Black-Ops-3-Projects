#include "framework.h"
#include "detours.h"
#include "offsets.h"
#include "builtins.h"
#include "ds.hpp"

// Note: Some auto-exec scripts will not get detoured due to the way linking works in the game

struct ReadScriptDetour
{
	INT32 FixupName;
	INT32 ReplaceNamespace;
	INT32 ReplaceFunction;
	INT32 FixupOffset;
	INT32 FixupSize;
};

tScr_GetFunction ScriptDetours::Scr_GetFunction = NULL;
tScr_GetMethod ScriptDetours::Scr_GetMethod = NULL;
tScr_GscObjLink ScriptDetours::Scr_GscObjLink = NULL;
char* ScriptDetours::GSC_OBJ = NULL;

std::vector<ScriptDetour*> ScriptDetours::RegisteredDetours;
std::unordered_map<INT64, ScriptDetour*> ScriptDetours::LinkedDetours;
std::unordered_map<INT64*, INT64> ScriptDetours::AppliedFixups;
tVM_Opcode ScriptDetours::VM_OP_GetFunction_Old = NULL;
tVM_Opcode ScriptDetours::VM_OP_GetAPIFunction_Old = NULL;
tVM_Opcode ScriptDetours::VM_OP_ScriptFunctionCall_Old = NULL;
tVM_Opcode ScriptDetours::VM_OP_ScriptMethodCall_Old = NULL;
tVM_Opcode ScriptDetours::VM_OP_ScriptThreadCall_Old = NULL;
tVM_Opcode ScriptDetours::VM_OP_ScriptMethodThreadCall_Old = NULL;
tVM_Opcode ScriptDetours::VM_OP_CallBuiltin_Old = NULL;
tVM_Opcode ScriptDetours::VM_OP_CallBuiltinMethod_Old = NULL;
bool ScriptDetours::DetoursLinked = false;
bool ScriptDetours::DetoursReset = true;
bool ScriptDetours::DetoursEnabled = false;

void ScriptDetours::ResetDetours()
{
#ifdef DETOUR_LOGGING
	ALOG("Resetting detours...");
#endif
	for (auto it = ScriptDetours::AppliedFixups.begin(); it != ScriptDetours::AppliedFixups.end(); it++)
	{
		if (Offsets::IsBadReadPtr(it->first))
		{
			continue;
		}
		*it->first = it->second;
	}
	ScriptDetours::AppliedFixups.clear();
	ScriptDetours::DetoursReset = true;
	ScriptDetours::DetoursLinked = false;
	ScriptDetours::DetoursEnabled = false;
}

void ScriptDetours::RegisterRuntimeDetour(INT64 hFixup, INT32 replaceFunc, INT32 replaceNS, const char* replaceName, char* fPosOrNull)
{
	ScriptDetour* detour = new ScriptDetour();
	detour->hFixup = hFixup;
	detour->ReplaceFunction = replaceFunc;
	detour->ReplaceNamespace = replaceNS;
	detour->FixupSize = 0;
	memcpy_s(detour->ReplaceScriptName, sizeof(detour->ReplaceScriptName), replaceName, strlen(replaceName) + 1);
	ScriptDetours::RegisteredDetours.push_back(detour);
	if (fPosOrNull)
	{
		LinkedDetours[(INT64)fPosOrNull] = detour; // skip relinking if we dont have to!
	}
}

void RemoveDetours()
{
#ifdef DETOUR_LOGGING
	ALOG("Removing detours...");
#endif
	for (auto it = ScriptDetours::RegisteredDetours.begin(); it != ScriptDetours::RegisteredDetours.end(); it++)
	{
		free(*it);
	}
	ScriptDetours::ResetDetours();
	ScriptDetours::RegisteredDetours.clear();
	ScriptDetours::DetoursLinked = false;
}

bool RegisterDetours(void* DetourData, int NumDetours, INT64 scriptOffset)
{
	RemoveDetours();
	ScriptDetours::GSC_OBJ = (char*)scriptOffset;
	
#ifdef DETOUR_LOGGING
	ALOG("Registering %d detours in script %p...", NumDetours, scriptOffset);
#endif

	INT64 base = (INT64)DetourData;
	for (int i = 0; i < NumDetours; i++)
	{
		ReadScriptDetour* read_detour = (ReadScriptDetour*)(base + (i * 256));
		ScriptDetour* detour = new ScriptDetour();
		detour->hFixup = read_detour->FixupOffset + scriptOffset;
		detour->ReplaceFunction = read_detour->ReplaceFunction;
		detour->ReplaceNamespace = read_detour->ReplaceNamespace;
		detour->FixupSize = read_detour->FixupSize;
#ifdef DETOUR_LOGGING
		ALOG("Detour Parsed: {FixupName:%x, ReplaceNamespace:%x, ReplaceFunction:%x, FixupOffset:%x, FixupSize:%x} {FixupMin:%p, FixupMax:%p}", read_detour->FixupName, read_detour->ReplaceNamespace, read_detour->ReplaceFunction, read_detour->FixupOffset, read_detour->FixupSize, detour->hFixup, detour->hFixup + detour->FixupSize);
#endif
		memcpy_s(detour->ReplaceScriptName, sizeof(detour->ReplaceScriptName), (void*)((INT64)read_detour + sizeof(ReadScriptDetour)), 256 - sizeof(ReadScriptDetour));
		ScriptDetours::RegisteredDetours.push_back(detour);
	}

	ScriptDetours::DetoursLinked = false;
	return true;
}

void ScriptDetours::InstallHooks()
{
	XLOG("ENTERED: Init Detours");

	// initialize methods
	Scr_GetFunction = (tScr_GetFunction)OFF_Scr_GetFunction;
	Scr_GetMethod = (tScr_GetMethod)OFF_Scr_GetMethod;
	Scr_GscObjLink = (tScr_GscObjLink)OFF_Scr_GscObjLink;

	// opcodes to hook:
	VTableReplace(_DOFFSET(0x12D0890), VM_OP_GetFunction, &VM_OP_GetFunction_Old);
	VTableReplace(_DOFFSET(0x12D0A30), VM_OP_GetAPIFunction, &VM_OP_GetAPIFunction_Old);
	VTableReplace(_DOFFSET(0x12CEE80), VM_OP_ScriptFunctionCall, &VM_OP_ScriptFunctionCall_Old);
	VTableReplace(_DOFFSET(0x12CF1D0), VM_OP_ScriptMethodCall, &VM_OP_ScriptMethodCall_Old);
	VTableReplace(_DOFFSET(0x12CFB10), VM_OP_ScriptThreadCall, &VM_OP_ScriptThreadCall_Old);
	VTableReplace(_DOFFSET(0x12CF570), VM_OP_ScriptMethodThreadCall, &VM_OP_ScriptMethodThreadCall_Old);
	VTableReplace(_DOFFSET(0x12CE460), VM_OP_CallBuiltin, &VM_OP_CallBuiltin_Old);
	VTableReplace(_DOFFSET(0x12CE3A0), VM_OP_CallBuiltinMethod, &VM_OP_CallBuiltinMethod_Old);

	XLOG("EXITED: Init Detours");
}

INT64 ScriptDetours::FindScriptParsetree(char* name)
{
	return DB_FindXAssetHeader(0x36, name, false, 0);
}

void ScriptDetours::LinkDetours()
{
	LinkedDetours.clear();
	for (auto it = RegisteredDetours.begin(); it != RegisteredDetours.end(); it++)
	{
		auto detour = *it;
		if (detour->ReplaceScriptName[0]) // not a builtin
		{
#ifdef DETOUR_LOGGING
			ALOG("Linking replacement %x<%s>::%x...", detour->ReplaceNamespace, detour->ReplaceScriptName, detour->ReplaceFunction);
#endif
			// locate the script to replace
			auto asset = FindScriptParsetree(detour->ReplaceScriptName);
			if (!asset)
			{
#ifdef DETOUR_LOGGING
				ALOG("Failed to locate %s...", detour->ReplaceScriptName);
#endif
				continue;
			}

#ifdef DETOUR_LOGGING
			ALOG("Located xAssetHeader...");
#endif
			// locate the target export to link
			auto buffer = *(char**)(asset + 0x10);
			auto exportsOffset = *(INT32*)(buffer + 0x20);
			auto exports = (INT64)(exportsOffset + buffer);
			auto numExports = *(INT16*)(buffer + 0x3A);
			__t7export* currentExport = (__t7export*)exports;
			for (INT16 i = 0; i < numExports; i++, currentExport++)
			{
				if (currentExport->funcName != detour->ReplaceFunction)
				{
					continue;
				}
				if (currentExport->funcNS != detour->ReplaceNamespace)
				{
					continue;
				}
#ifdef DETOUR_LOGGING
				ALOG("Found export at %p!", (INT64)buffer + currentExport->bytecodeOffset);
#endif
				LinkedDetours[(INT64)buffer + currentExport->bytecodeOffset] = detour;
				break;
			}
		}
		else
		{
#ifdef DETOUR_LOGGING
			ALOG("Linking replacement for builtin %x...", detour->ReplaceFunction);
#endif
			INT32 discardType;
			INT32 discardMinParams;
			INT32 discardMaxParams;
			auto hReplace = Scr_GetFunction(detour->ReplaceFunction, &discardType, &discardMinParams, &discardMaxParams);
			if (!hReplace)
			{
				hReplace = Scr_GetMethod(detour->ReplaceFunction, &discardType, &discardMinParams, &discardMaxParams);
			}
			if (hReplace)
			{
#ifdef DETOUR_LOGGING
				ALOG("Found function definition at %p!", hReplace);
#endif
				LinkedDetours[hReplace] = detour;
			}
		}
	}
	DetoursLinked = true;
}

void ScriptDetours::VTableReplace(INT32 sub_offset, tVM_Opcode ReplaceFunc, tVM_Opcode* OutOld)
{
	INT64 stub_final = REBASE(sub_offset);
	INT64 handler_table = OFF_ScrVm_Opcodes;
	*OutOld = (tVM_Opcode)stub_final;
	for (int i = 0; i < 0x2000; i++)
	{
		if (*(INT64*)(handler_table + (i * 8)) == stub_final)
		{
			*(INT64*)(handler_table + (i * 8)) = (INT64)ReplaceFunc;
		}
	}

	handler_table = OFF_ScrVm_Opcodes2;

	for (int i = 0; i < 0x2000; i++)
	{
		if (*(INT64*)(handler_table + (i * 8)) == stub_final)
		{
			*(INT64*)(handler_table + (i * 8)) = (INT64)ReplaceFunc;
		}
	}
}

void ScriptDetours::VM_OP_GetFunction(INT32 inst, INT64* fs_0, INT64 vmc, bool* terminate)
{
	CheckDetour(inst, fs_0);
	VM_OP_GetFunction_Old(inst, fs_0, vmc, terminate);
}

void ScriptDetours::VM_OP_GetAPIFunction(INT32 inst, INT64* fs_0, INT64 vmc, bool* terminate)
{
	CheckDetour(inst, fs_0);
	VM_OP_GetAPIFunction_Old(inst, fs_0, vmc, terminate);
}

void ScriptDetours::VM_OP_ScriptFunctionCall(INT32 inst, INT64* fs_0, INT64 vmc, bool* terminate)
{
	CheckDetour(inst, fs_0, 1);
	VM_OP_ScriptFunctionCall_Old(inst, fs_0, vmc, terminate);
}

void ScriptDetours::VM_OP_ScriptMethodCall(INT32 inst, INT64* fs_0, INT64 vmc, bool* terminate)
{
	CheckDetour(inst, fs_0, 1);
	VM_OP_ScriptMethodCall_Old(inst, fs_0, vmc, terminate);
}

void ScriptDetours::VM_OP_ScriptThreadCall(INT32 inst, INT64* fs_0, INT64 vmc, bool* terminate)
{
	CheckDetour(inst, fs_0, 1);
	VM_OP_ScriptThreadCall_Old(inst, fs_0, vmc, terminate);
}

void ScriptDetours::VM_OP_ScriptMethodThreadCall(INT32 inst, INT64* fs_0, INT64 vmc, bool* terminate)
{
	CheckDetour(inst, fs_0, 1);
	VM_OP_ScriptMethodThreadCall_Old(inst, fs_0, vmc, terminate);
}

void ScriptDetours::VM_OP_CallBuiltin(INT32 inst, INT64* fs_0, INT64 vmc, bool* terminate)
{
	if (CheckDetour(inst, fs_0, 1))
	{
		// spoof opcode to ScriptFunctionCall (because we are no longer calling a builtin)
		*(INT16*)(*fs_0 - 2) = 0x203;
		VM_OP_ScriptFunctionCall_Old(inst, fs_0, vmc, terminate);
		return;
	}
	VM_OP_CallBuiltin_Old(inst, fs_0, vmc, terminate);
}

void ScriptDetours::VM_OP_CallBuiltinMethod(INT32 inst, INT64* fs_0, INT64 vmc, bool* terminate)
{
	if (CheckDetour(inst, fs_0, 1))
	{
		// spoof opcode to ScriptMethodCall (because we are no longer calling a builtin)
		*(INT16*)(*fs_0 - 2) = 0x207;
		VM_OP_ScriptMethodCall_Old(inst, fs_0, vmc, terminate);
		return;
	}
	VM_OP_CallBuiltinMethod_Old(inst, fs_0, vmc, terminate);
}

bool ScriptDetours::CheckDetour(INT32 inst, INT64* fs_0, INT32 offset)
{
	if (!DetoursEnabled)
	{
		return false;
	}
	// detours are not supported in UI level
	if (*(BYTE*)(OFF_s_runningUILevel))
	{
		if (!ScriptDetours::DetoursReset)
		{
			ResetDetours();
		}
		return false;
	}
	if (inst)
	{
		// csc is not supported at this time
		return false;
	}
	bool fixupApplied = false;
	if (!DetoursLinked)
	{
		LinkDetours();
	}
	INT64 ptrval = *(INT64*)((*fs_0 + 7 + offset) & 0xFFFFFFFFFFFFFFF8);
	if (LinkedDetours.find(ptrval) != LinkedDetours.end() && LinkedDetours[ptrval]->hFixup)
	{
		INT64 fs_pos = *fs_0;
		// if pointer is below fixup or above it, the pointer is not within the detour and thus can be fixed up
		if (LinkedDetours[ptrval]->hFixup > fs_pos || ((LinkedDetours[ptrval]->hFixup + LinkedDetours[ptrval]->FixupSize) <= fs_pos))
		{
#ifdef DETOUR_LOGGING
			ALOG("Replaced call at %p to fixup %p! Opcode: %x", (INT64)((*fs_0 + 7 + offset) & 0xFFFFFFFFFFFFFFF8), LinkedDetours[ptrval]->hFixup, *(INT16*)(*fs_0 - 2));
#endif
			AppliedFixups[(INT64*)((*fs_0 + 7 + offset) & 0xFFFFFFFFFFFFFFF8)] = ptrval;
			*(INT64*)((*fs_0 + 7 + offset) & 0xFFFFFFFFFFFFFFF8) = LinkedDetours[ptrval]->hFixup;
			DetoursReset = false;
			fixupApplied = true;
		}
	}
	return fixupApplied;
}
