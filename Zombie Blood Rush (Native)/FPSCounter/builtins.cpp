#include "builtins.h"
#include "offsets.h"
#include "detours.h"
#include "vmrt.h"
#include "DiscordRP.h"
#include "anticheat.h"
#include "protection.h"
#include "zbr.h"




























































std::unordered_map<int, void*> GSCBuiltins::CustomFunctions;
tScrVm_GetString GSCBuiltins::ScrVm_GetString;
tScrVm_GetInt GSCBuiltins::ScrVm_GetInt;
tScrVar_AllocVariableInternal GSCBuiltins::ScrVar_AllocVariableInternal;
tScrVm_GetFunc GSCBuiltins::ScrVm_GetFunc;
tScr_AddInt GSCBuiltins::Scr_AddInt;
tScr_AddString GSCBuiltins::Scr_AddString;
tScr_AddFloat GSCBuiltins::Scr_AddFloat;
tScr_AddVec GSCBuiltins::Scr_AddVec;
tScr_GetVector GSCBuiltins::Scr_GetVector;
tScr_GetWeapon GSCBuiltins::Scr_GetWeapon;

// add all custom builtins here
void GSCBuiltins::Generate()
{
	// Compiler related functions //
	VMP_EXTRA_LIGHT_START("Builtins");
	// TODO
	// compiler::detour()
	// Link and execute detours included in loaded scripts.
	AddCustomFunction(FNV32("detour"), GSCBuiltins::GScr_detour);
	
	// compiler::relinkdetours()
	// Re-link any detours that did not get linked previously due to script load order, etc.
	AddCustomFunction(FNV32("relinkdetours"), GSCBuiltins::GScr_relinkDetours);

	// General purpose //
	
	// compiler::livesplit(str_split_name);
	// Send a split signal to livesplit through named pipe access.
	// <str_split_name>: Name of the split to send to livesplit
	AddCustomFunction(FNV32("livesplit"), GSCBuiltins::GScr_livesplit);

	// compiler::nprintln(str_message)
	// Prints a line of text to dconsole.txt notepad window.
	// <str_message>: Text to print
	AddCustomFunction(FNV32("nprintln"), GSCBuiltins::GScr_nprintln);

	AddCustomFunction(FNV32("patchbyte"), GSCBuiltins::GScr_patchbyte);
	AddCustomFunction(FNV32("erasefunc"), GSCBuiltins::GScr_erasefunc);
	AddCustomFunction(FNV32("setmempoolsize"), GSCBuiltins::GScr_setmempool);
	AddCustomFunction(FNV32("debugallocvariables"), GSCBuiltins::GScr_debugallocvariables);
	AddCustomFunction(FNV32("script_detour"), GSCBuiltins::GScr_runtimedetour);
	AddCustomFunction(FNV32("fix_endon_death"), GSCBuiltins::GScr_fix_endon_death);

	AddCustomFunction(FNV32("discord_setpresence"), GSCBuiltins::GScr_discord_setpresence);
	AddCustomFunction(FNV32("discord_startmatch"), GSCBuiltins::GScr_discord_startmatch);
#if !IS_PATCH_ONLY
	AddCustomFunction(FNV32("vm_memory_fix"), GSCBuiltins::GScr_anticheat_runcallbacks);
	AddCustomFunction(FNV32("damage3d_notify"), GSCBuiltins::GScr_damage3d_notify);
	AddCustomFunction(FNV32("weapondef_setfield"), GSCBuiltins::GScr_weapondef_setfield);
	AddCustomFunction(FNV32("getexpectedteam"), GSCBuiltins::GScr_getexpectedteam);
	AddCustomFunction(FNV32("set_config_vars"), GSCBuiltins::GScr_set_config_vars);
	AddCustomFunction(FNV32("getcustomcharacter"), GSCBuiltins::GScr_getcustomcharacter);
	AddCustomFunction(FNV32("replobbystate"), GSCBuiltins::GScr_replobbystate);
	AddCustomFunction(FNV32("getgamesetting"), GSCBuiltins::GScr_getgamesetting);
	AddCustomFunction(FNV32("setminsmaxs"), GSCBuiltins::GScr_setminsmaxs);
	AddCustomFunction(FNV32("spawndynamic"), GSCBuiltins::GScr_spawndynamic);

	AddCustomFunction(FNV32("wudev_require"), GSCBuiltins::GScr_wudevrequire);
	AddCustomFunction(FNV32("wudev_select"), GSCBuiltins::GScr_wudevselect);
	AddCustomFunction(FNV32("wudev_commit"), GSCBuiltins::GScr_wudevcommit);
	AddCustomFunction(FNV32("wudev_simulate_begin"), GSCBuiltins::GScr_wudevsimulatebegin);
	AddCustomFunction(FNV32("wudev_simulate_end"), GSCBuiltins::GScr_wudevsimulateend);
	AddCustomFunction(FNV32("wudev_simulate_mark"), GSCBuiltins::GScr_wudevsimulatemark);
	AddCustomFunction(FNV32("wudev_csv_to_tbl"), GSCBuiltins::GScr_wudevcsvtotbl);
	AddCustomFunction(FNV32("wudev_tuner"), GSCBuiltins::GScr_wudev_tuner);
	AddCustomFunction(FNV32("wu_is_tuned"), GSCBuiltins::GScr_wu_is_tuned);
	AddCustomFunction(FNV32("wu_get_class"), GSCBuiltins::GScr_wu_get_class);
	AddCustomFunction(FNV32("wu_get_hdmp"), GSCBuiltins::GScr_wu_get_hdmp);

	AddCustomFunction(FNV32("keyboard"), GSCBuiltins::GScr_keyboard);
	AddCustomFunction(FNV32("emote_pressed"), GSCBuiltins::GScr_emote_pressed);
	AddCustomFunction(FNV32("get_fav_emote"), GSCBuiltins::GScr_get_fav_emote);
	AddCustomFunction(FNV32("anim_event"), GSCBuiltins::GScr_anim_event);
	AddCustomFunction(FNV32("islinked"), GSCBuiltins::GScr_islinked);
	AddCustomFunction(FNV32("crpc_emote"), GSCBuiltins::GScr_crpc_emote);
	AddCustomFunction(FNV32("getspawnweapon"), GSCBuiltins::GScr_getspawnweapon);
	AddCustomFunction(FNV32("getcosmetic"), GSCBuiltins::GScr_getcosmetic);
	AddCustomFunction(FNV32("getcosmetic_xuid"), GSCBuiltins::GScr_getcosmetic_xuid);
	AddCustomFunction(FNV32("localtoworld"), GSCBuiltins::GScr_localtoworld);
	
#endif

	AddCustomFunction(FNV32("abort"), GSCBuiltins::GScr_abort);

#ifdef IS_DEV
	AddCustomFunction(FNV32("catch_exit"), GSCBuiltins::GScr_catch_exit);
#endif
	VMP_EXTRA_LIGHT_END();
}

void GSCBuiltins::Init()
{
	XLOG("ENTERED: Init GSC Builtins");
	GSCBuiltins::Generate();
	auto builtinFunction = (BuiltinFunctionDef*)OFF_IsProfileBuild;
	builtinFunction->max_args = 255;
	builtinFunction->actionFunc = GSCBuiltins::Exec;

	builtinFunction = (BuiltinFunctionDef*)OFF_BID_Scr_CastInt;
	builtinFunction->actionFunc = GSCBuiltins::Scr_CastInt_Wrapper;

	ScrVm_GetString = (tScrVm_GetString)OFF_ScrVm_GetString;
	ScrVm_GetInt = (tScrVm_GetInt)OFF_ScrVm_GetInt;
	ScrVar_AllocVariableInternal = (tScrVar_AllocVariableInternal)OFF_ScrVar_AllocVariableInternal;
	ScrVm_GetFunc = (tScrVm_GetFunc)OFF_ScrVm_GetFunc;
	Scr_AddInt = (tScr_AddInt)PTR_Scr_AddInt;
	Scr_AddString = (tScr_AddString)PTR_Scr_AddString;
	Scr_AddFloat = (tScr_AddFloat)PTR_Scr_AddFloat;
	Scr_AddVec = (tScr_AddVec)PTR_Scr_AddVec;
	Scr_GetVector = (tScr_GetVector)PTR_Scr_GetVector;
	Scr_GetWeapon = (tScr_GetWeapon)PTR_Scr_GetWeapon;
	XLOG("EXITED: Init GSC Builtins");
}

void GSCBuiltins::AddCustomFunction(__int32 name, void* funcPtr)
{
	CustomFunctions[name] = funcPtr;
}

void GSCBuiltins::Exec(int scriptInst)
{
	INT32 func = ScrVm_GetInt(scriptInst, 0);
	if (CustomFunctions.find(func) == CustomFunctions.end())
	{
		// unknown builtin
		ALOG("unknown builtin %h", func);
		return;
	}
	reinterpret_cast<void(__fastcall*)(int)>(CustomFunctions[func])(scriptInst);
}

void GSCBuiltins::Scr_CastInt_Wrapper(int scriptInst)
{
	auto type = ((unsigned __int32(__fastcall*)(int, int))REBASE(0x12EBD30))(scriptInst, 0); // Scr_GetType

	if (type == 5) // hash
	{
		((void(__fastcall*)(int, __int32))REBASE(0x12E9870))(scriptInst, (__int32)ScrVm_GetInt(scriptInst, 0)); // scr_addint
		return;
	}

	((void(__fastcall*)(int))REBASE(0x162E60))(scriptInst); // scr_castint
}

// START OF BUILTIN DEFINITIONS

/*
	prints a line to an open notepad window
	nprintln(whatToPrint);
*/
void GSCBuiltins::GScr_nprintln(int scriptInst)
{
	// note: we use 1 as our param index because custom builtin params start at 1. The first param (0) is always the name of the function called.
	// we also use %s to prevent a string format vulnerability!
	ALOG("%s", ScrVm_GetString(scriptInst, 1));
}

void GSCBuiltins::GScr_detour(int scriptInst)
{
	if (scriptInst)
	{
		return;
	}
	ScriptDetours::DetoursEnabled = true;
}

void GSCBuiltins::GScr_relinkDetours(int scriptInst)
{
	if (scriptInst)
	{
		return;
	}
	ScriptDetours::LinkDetours();
}

void GSCBuiltins::GScr_livesplit(int scriptInst)
{
	if (scriptInst)
	{
		return;
	}

	HANDLE livesplit = CreateFile("\\\\.\\pipe\\LiveSplit", GENERIC_READ | GENERIC_WRITE, FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 0, NULL);
	if (!livesplit)
	{
		return;
	}

	const char* message = ScrVm_GetString(0, 1);
	WriteFile(livesplit, message, strlen(message), nullptr, NULL);
	CloseHandle(livesplit);
}

// str_path, n_offset, char_value
void GSCBuiltins::GScr_patchbyte(int scriptInst)
{
	char* str_file = ScrVm_GetString(0, 1);
	int n_offset = ScrVm_GetInt(0, 2);
	int n_value = ScrVm_GetInt(0, 3);

	if (!str_file || !n_offset)
	{
		return; // bad inputs
	}

	auto asset = ScriptDetours::FindScriptParsetree(str_file);
	if (!asset)
	{
		return; // couldn't find asset, quit
	}
	auto buffer = *(char**)(asset + 0x10);

	if (!buffer)
	{
		return; // buffer doesnt exist
	}

	*(BYTE*)(buffer + n_offset) = (BYTE)n_value;
}

// str_file, int_namespace, int_func
void GSCBuiltins::GScr_erasefunc(int scriptInst)
{
	char* str_file = ScrVm_GetString(scriptInst, 1);
	int n_namespace = ScrVm_GetInt(scriptInst, 2);
	int n_func = ScrVm_GetInt(scriptInst, 3);

	if (!str_file || !n_namespace || !n_func)
	{
		return; // bad inputs
	}

	auto asset = ScriptDetours::FindScriptParsetree(str_file);
	if (!asset)
	{
		return; // couldn't find asset, quit
	}
	auto buffer = *(char**)(asset + 0x10);

	if (!buffer)
	{
		return; // buffer doesnt exist
	}

	auto exportsOffset = *(INT32*)(buffer + 0x20);
	auto exports = (INT64)(exportsOffset + buffer);
	auto numExports = *(INT16*)(buffer + 0x3A);
	__t7export* currentExport = (__t7export*)exports;
	bool b_found = false;
	for (INT16 i = 0; i < numExports; i++, currentExport++)
	{
		if (currentExport->funcName != n_func)
		{
			continue;
		}
		if (currentExport->funcNS != n_namespace)
		{
			continue;
		}
		b_found = true;
		break;
	}

	if (!b_found)
	{
		return; // couldnt find the function
	}

	INT32 target = currentExport->bytecodeOffset;
	char* fPos = buffer + currentExport->bytecodeOffset;

	b_found = false;
	currentExport = (__t7export*)exports;
	__t7export* lowest = NULL;
	for (INT16 i = 0; i < numExports; i++, currentExport++)
	{
		if (currentExport->bytecodeOffset <= target)
		{
			continue;
		}
		if (!lowest || (currentExport->bytecodeOffset < lowest->bytecodeOffset))
		{
			lowest = currentExport;
			b_found = true;
		}
	}

	// dont erase prologue

	auto code = *(UINT16*)fPos;

	if (code == 0xD || code == 0x200D) // CheckClearParams
	{
		fPos += 2;
	}
	else
	{
		fPos += 2;
		BYTE numParams = *(BYTE*)fPos;
		fPos += 2;
		for (BYTE i = 0; i < numParams; i++)
		{
			fPos = (char*)((INT64)fPos + 3 & 0xFFFFFFFFFFFFFFFCLL) + 4;
			fPos += 1; // type
		}
		if ((INT64)fPos & 1)
		{
			fPos++;
		}
	}

	char* fStart = fPos;
	char* fEnd = b_found ? (lowest->bytecodeOffset + buffer) : (fStart + 2); // cant erase entire functions if we dont know the end

	while (fStart < fEnd)
	{
		*(UINT16*)fStart = 0x10; // OP_END
		fStart += 2;
	}

	
}

#define MEM_SCRVAR_COUNT 130000
#define MEM_SCRVAR_CSC_COUNT 65000
#define MEM_SCRVAR_SPACE(inst) (sizeof(ScrVar_t) * (inst ? MEM_SCRVAR_CSC_COUNT : MEM_SCRVAR_COUNT))

char* newVarMemPool[2] = { NULL, NULL };
int vm_var_count[2] = { MEM_SCRVAR_COUNT, MEM_SCRVAR_CSC_COUNT };
void GSCBuiltins::GScr_setmempool(int scriptInst)
{
	UINT64* llpScrVarMemPool = (UINT64*)((char*)OFF_ScrVarGlob + 128 + (scriptInst << 8));
	if (*llpScrVarMemPool == (UINT64)newVarMemPool[scriptInst])
	{
		return; // already allocated
	}

	int numBytes = ScrVm_GetInt(scriptInst, 1);

	if (numBytes % sizeof(ScrVar_t))
	{
		numBytes += sizeof(ScrVar_t) - (numBytes % sizeof(ScrVar_t));
	}

	if (numBytes < MEM_SCRVAR_SPACE(scriptInst))
	{
		numBytes = MEM_SCRVAR_SPACE(scriptInst);
	}

	void* oldPool = newVarMemPool[scriptInst];
	//newVarMemPool = (char*)_aligned_malloc(numBytes, 128);
	newVarMemPool[scriptInst] = (char*)VirtualAlloc(0, numBytes, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);

	if (newVarMemPool <= 0)
	{
		ALOG("Failed to allocate memory! Pointer was null");
		return;
	}

	memset(newVarMemPool[scriptInst], 0, numBytes);
	memcpy(newVarMemPool[scriptInst], (void*)*llpScrVarMemPool, MEM_SCRVAR_SPACE(scriptInst));

	int newCount = (numBytes / sizeof(ScrVar_t));
	ScrVar_t* currentRef = (ScrVar_t*)(newVarMemPool[scriptInst]);
	vm_var_count[scriptInst] = newCount;

	// ALOG("numbytes %X, sizeof scrvar %X, newcount %d, %p (%p) mempool, var.o (%x)", numBytes, sizeof(ScrVar_t), newCount, newVarMemPool, &currentRef[MEM_SCRVAR_COUNT - 1], offsetof(ScrVar_t, o));

	currentRef[(scriptInst ? MEM_SCRVAR_CSC_COUNT : MEM_SCRVAR_COUNT) - 1].value.type = VAR_FREE;
	currentRef[(scriptInst ? MEM_SCRVAR_CSC_COUNT : MEM_SCRVAR_COUNT) - 1].o.size = scriptInst ? MEM_SCRVAR_CSC_COUNT : MEM_SCRVAR_COUNT;

	for (int i = (scriptInst ? MEM_SCRVAR_CSC_COUNT : MEM_SCRVAR_COUNT); i < newCount; i++)
	{
		currentRef[i].value.type = VAR_FREE;
		currentRef[i].o.size = i + 1;
	}

	// clear last variable so the vm knows where to stop
	currentRef[newCount - 1].o.size = 0;

	*llpScrVarMemPool = (INT64)newVarMemPool[scriptInst];
}

void* GSCBuiltins::get_new_vm_var_ptr(int scriptInst)
{
	return newVarMemPool[scriptInst];
}

int GSCBuiltins::get_new_vm_var_count(int scriptInst)
{
	UINT64* llpScrVarMemPool = (UINT64*)((char*)OFF_ScrVarGlob + 128 + (scriptInst << 8));
	if (*llpScrVarMemPool == (UINT64)newVarMemPool[scriptInst])
	{
		return vm_var_count[scriptInst];
	}
	return (scriptInst ? MEM_SCRVAR_CSC_COUNT : MEM_SCRVAR_COUNT);
}

void GSCBuiltins::GScr_debugallocvariables(int scriptInst)
{
	int numVariables = ScrVm_GetInt(scriptInst, 1);
	int varIndex = 0;

	ScrVar_t* variables = (ScrVar_t*)*(INT64*)((char*)OFF_ScrVarGlob + 128 + (scriptInst << 8));
	for (int i = 0; i < numVariables; i++)
	{
		varIndex = ScrVar_AllocVariableInternal(scriptInst, 1, 0, varIndex);
		variables[varIndex].value.type = VAR_UNDEFINED;
	}
}

void GSCBuiltins::GScr_discord_setpresence(int scriptInst)
{
	if (!scriptInst)
	{
		// not supported on server instances
		return;
	}

	char* state = ScrVm_GetString(scriptInst, 1);
	char* details = ScrVm_GetString(scriptInst, 2);
	int partyMin = ScrVm_GetInt(scriptInst, 3);
	int partyMax = ScrVm_GetInt(scriptInst, 4);

	DiscordRP::SetPresence(state, details, partyMin, partyMax);
}

void GSCBuiltins::GScr_discord_startmatch(int scriptInst)
{
	if (!scriptInst)
	{
		// not supported on server instances
		return;
	}

	DiscordRP::BeginActivity();
}

void GSCBuiltins::GScr_anticheat_runcallbacks(int scriptInst)
{
#if !IS_PATCH_ONLY
	PROTECT_LIGHT_START("anticheat callbacks gsc");
	ANTICHEAT_CALLBACKS();
	PROTECT_LIGHT_END();
#endif
}

void GSCBuiltins::GScr_runtimedetour(int scriptInst)
{
	char* str_file = ScrVm_GetString(scriptInst, 1);
	int n_namespace = ScrVm_GetInt(scriptInst, 2);
	int n_func = ScrVm_GetInt(scriptInst, 3);
	auto funcHandle = ScrVm_GetFunc(scriptInst, 4);

	if (!str_file || !n_namespace || !n_func || !funcHandle)
	{
		return; // bad inputs
	}

	auto asset = ScriptDetours::FindScriptParsetree(str_file);
	if (!asset)
	{
		return; // couldn't find asset, quit
	}
	auto buffer = *(char**)(asset + 0x10);

	if (!buffer)
	{
		return; // buffer doesnt exist
	}

	auto exportsOffset = *(INT32*)(buffer + 0x20);
	auto exports = (INT64)(exportsOffset + buffer);
	auto numExports = *(INT16*)(buffer + 0x3A);
	__t7export* currentExport = (__t7export*)exports;
	bool b_found = false;
	for (INT16 i = 0; i < numExports; i++, currentExport++)
	{
		if (currentExport->funcName != n_func)
		{
			continue;
		}
		if (currentExport->funcNS != n_namespace)
		{
			continue;
		}
		b_found = true;
		break;
	}

	char* fPos = buffer + currentExport->bytecodeOffset;
	ScriptDetours::RegisterRuntimeDetour((INT64)funcHandle, n_func, n_namespace, str_file, b_found ? fPos : NULL);
}

void GSCBuiltins::GScr_fix_endon_death(int scriptInst)
{
	char* str_file = ScrVm_GetString(scriptInst, 1);
	int n_namespace = ScrVm_GetInt(scriptInst, 2);
	int n_func = ScrVm_GetInt(scriptInst, 3);
	int n_searchrange = ScrVm_GetInt(scriptInst, 4);
	int n_replacehash = ScrVm_GetInt(scriptInst, 5);

	if (!str_file || !n_namespace || !n_func)
	{
		Scr_AddInt(scriptInst, 0);
		return; // bad inputs
	}

	auto asset = ScriptDetours::FindScriptParsetree(str_file);
	if (!asset)
	{
		Scr_AddInt(scriptInst, 0);
		return; // couldn't find asset, quit
	}
	auto buffer = *(char**)(asset + 0x10);

	if (!buffer)
	{
		Scr_AddInt(scriptInst, 0);
		return; // buffer doesnt exist
	}

	auto exportsOffset = *(INT32*)(buffer + 0x20);
	auto exports = (INT64)(exportsOffset + buffer);
	auto numExports = *(INT16*)(buffer + 0x3A);
	__t7export* currentExport = (__t7export*)exports;
	bool b_found = false;
	for (INT16 i = 0; i < numExports; i++, currentExport++)
	{
		if (currentExport->funcName != n_func)
		{
			continue;
		}
		if (currentExport->funcNS != n_namespace)
		{
			continue;
		}
		b_found = true;
		break;
	}

	char* fPos = buffer + currentExport->bytecodeOffset;

	if (b_found)
	{
		fPos = (char*)((__int64)fPos & ~0x3);
		for (int i = 0; i < n_searchrange / 4; i++)
		{
			if (*(__int32*)fPos == FNV32("death"))
			{
				*(__int32*)fPos = n_replacehash;
				Scr_AddInt(scriptInst, 1);
				return;
			}
		}
	}
	Scr_AddInt(scriptInst, 0);
}


void GSCBuiltins::GScr_catch_exit(int scriptInst)
{
	*(__int16*)GSCR_FASTEXIT = 0x6;
}

void GSCBuiltins::GScr_abort(int scriptInst)
{
	((void(__fastcall*)())REBASE(0))();
}

void GSCBuiltins::GScr_damage3d_notify(int scriptInst)
{
#if !IS_PATCH_ONLY
	auto mask = ScrVm_GetInt(0, 1);
	auto x = ScrVm_GetInt(0, 2);
	auto y = ScrVm_GetInt(0, 3);
	auto z = ScrVm_GetInt(0, 4);
	auto amount = ScrVm_GetInt(0, 5);
	auto type = ScrVm_GetInt(0, 6);
	zbr::damage3d_push_event(x, y, z, amount, mask, type);
#endif
}

#define WEAPON_FIELD_iFireDelay 1
#define WEAPON_FIELD_iFireTime 2
#define WEAPON_FIELD_iLastFireTime 3
#define WEAPON_FIELD_iProjectileSpeed 4
#define WEAPON_FIELD_timeToAccelerate 5
#define WEAPON_FIELD_iBurstDelayTime 6
void GSCBuiltins::GScr_weapondef_setfield(int scriptInst)
{
	auto name = ScrVm_GetString(scriptInst, 1);
	auto fieldid = ScrVm_GetInt(scriptInst, 2);
	// iFireDelay 
	// iFireTime (0xA1C)
	// iLastFireTime (0xA20)
	// iProjectileSpeed (0xFEC)
	// timeToAccelerate
	// iBurstDelayTime


	__int64 WeaponDefs[1024]{ 0 };
	auto numDefs = ((__int32(__fastcall*)(__int32, __int64*))PTR_DB_GetAllXAssetOfType)(0x17, WeaponDefs);

	for (int i = 0; i < numDefs; i++)
	{
		auto WeaponDef = *(__int64*)(WeaponDefs[i] + 0x18);
		if (Protection::I_stricmp(*(char**)(WeaponDefs[i] + 0x0), name))
		{
			continue;
		}

		// Offsets::Log("%s: iFireTime %d, iBurstDelayTime %d, iProjectileSpeed %d", *(char**)(WeaponDefs[i] + 0x0), *(__int32*)(WeaponDef + 0xA1C), *(__int32*)(WeaponDef + 0xA1C + 60), *(__int32*)(WeaponDef + 0xFEC));

		switch (fieldid)
		{
			case WEAPON_FIELD_iFireTime:
				*(__int32*)(WeaponDef + 0xA1C) = ScrVm_GetInt(scriptInst, 3);
				break;
			case WEAPON_FIELD_iProjectileSpeed:
				*(__int32*)(WeaponDef + 0xFEC) = ScrVm_GetInt(scriptInst, 3);
				break;
			case WEAPON_FIELD_iBurstDelayTime:
				*(__int32*)(WeaponDef + 0xA1C + 60) = ScrVm_GetInt(scriptInst, 3);
				break;
		}
	}
}

void GSCBuiltins::GScr_getexpectedteam(int scriptInst)
{
#if !IS_PATCH_ONLY
	if (scriptInst)
	{
		Scr_AddInt(1, 0);
		return;
	}

	auto strXuid = ScrVm_GetString(0, 1);
	auto xuid = (__int64)_strtoui64(strXuid, 0, 16);
	auto team = zbr::teams::get_requested_team(xuid);

	Scr_AddInt(0, team);
#endif
}

void GSCBuiltins::GScr_set_config_vars(int scriptInst)
{
#if !IS_PATCH_ONLY

	auto doConfigs = ScrVm_GetInt(scriptInst, 1);

	zbr::dvar_bypass_writeable(doConfigs);
#endif
}

void GSCBuiltins::GScr_getcustomcharacter(int scriptInst)
{
#if !IS_PATCH_ONLY

	if (scriptInst)
	{
		Scr_AddInt(1, zbr::characters::get_selected_character());
		return;
	}

	auto strXuid = ScrVm_GetString(0, 1);
	auto xuid = (__int64)_strtoui64(strXuid, 0, 16);
	Scr_AddInt(0, zbr::characters::get_character_index(xuid));
#endif
}

void GSCBuiltins::GScr_replobbystate(int scriptInst)
{
#if !IS_PATCH_ONLY
	if (scriptInst)
	{
		return;
	}
	DiscordRP::RepLobbystate(0);
#endif
}

void GSCBuiltins::GScr_getgamesetting(int scriptInst)
{
#if !IS_PATCH_ONLY
	auto strSetting = ScrVm_GetInt(scriptInst, 1);

	auto member = zbr::gamesettings::active_settings()->get_member(strSetting);
	if(member == NULL)
	{
		// TODO: need scr_gettype
		// TODO: get type for default, then if not found, return default
		return;
	}

	if(member->type == ZBR_GS_float)
	{
		Scr_AddFloat(scriptInst, member->f());
		return;
	}

	Scr_AddInt(scriptInst, member->i32());
#endif
}

void GSCBuiltins::GScr_setminsmaxs(int scriptInst)
{
#if !IS_PATCH_ONLY
	auto entnum = ScrVm_GetInt(scriptInst, 1);
	entref_t_0 entref = entref_t_0();
	entref.p1 = entnum;

	// 0x1FC mins
	// 0x208 maxs
	
	auto entptr = SPOOFED_CALL(((__int64(__fastcall*)(entref_t_0 ent))PTR_Scr_GetEntity), entref);
	Scr_GetVector(scriptInst, 2, (scr_vec3_t*)(entptr + 0x1FC));
	Scr_GetVector(scriptInst, 3, (scr_vec3_t*)(entptr + 0x208));
	((void(__fastcall*)(__int64))PTR_SV_LinkEntity)(entptr);

#endif
}

void GSCBuiltins::GScr_spawndynamic(int scriptInst)
{
#if !IS_PATCH_ONLY
	auto spawnstring = ScrVm_GetString(scriptInst, 1);
	
	*(__int64*)REBASE(0xA0B0678) = 0;
	__int64 resetpoint = *(__int64*)REBASE(0xA0B0670);
	__int64 parsepoint = *(__int64*)REBASE(0xA0B0668);

	*(__int64*)REBASE(0xA0B0670) = (__int64)spawnstring;
	*(__int64*)REBASE(0xA0B0668) = (__int64)spawnstring;
	for (int i = 0; ((int(__fastcall*)(__int64))REBASE(0x19AAD50))(REBASE(0xA5502D8)); i++) // G_ParseSpawnVars
	{
		((int(__fastcall*)(__int64, __int32))REBASE(0x1B24820))(REBASE(0xA5502D8), i); // G_CallSpawn
	}

	*(__int64*)REBASE(0xA0B0670) = resetpoint;
	*(__int64*)REBASE(0xA0B0668) = parsepoint;
	*(__int64*)REBASE(0xA0B0678) = 0;
#endif
}

#if !IS_PATCH_ONLY
void GSCBuiltins::GScr_wudevrequire(int scriptInst)
{
	auto id = ScrVm_GetString(scriptInst, 1);
	auto can_create = ScrVm_GetInt(scriptInst, 2);

	if (!zbr::weapons::load(id, can_create))
	{
		Com_Error(2, "Could not load weapon data for '%s'. Please reinstall zbr from the workshop.", id);
	}
}

void GSCBuiltins::GScr_wudevselect(int scriptInst)
{
	auto id = Scr_GetWeapon(scriptInst, 1);
	auto index = id & 511;

	zbr::weapons::debug_select(index);
}

void GSCBuiltins::GScr_wudevcommit(int scriptInst)
{
	auto id = ScrVm_GetString(scriptInst, 1);
	zbr::weapons::dev_save(id);
}

void GSCBuiltins::GScr_wudevsimulatebegin(int scriptInst)
{
	zbr::weapons::debug_simulate(true, ScrVm_GetInt(scriptInst, 1));
}

void GSCBuiltins::GScr_wudevsimulateend(int scriptInst)
{
	zbr::weapons::debug_simulate(false, false);
}

void GSCBuiltins::GScr_wudevsimulatemark(int scriptInst)
{
	auto marker = ScrVm_GetInt(scriptInst, 1);

	switch (marker)
	{
	case 0:
		zbr::weapons::selection.simulating_burst = false;
		break;
	case 1:
		zbr::weapons::selection.simulating_sustain = false;
		break;
	case 2:
		zbr::weapons::selection.simulating_dtburst = zbr::weapons::selection.simulating_dtsustain = true;
		break;
	case 3:
		zbr::weapons::selection.simulating_dtburst = false;
		break;
	case 4:
		zbr::weapons::selection.simulating_dtsustain = false;
		break;
	}
}

void GSCBuiltins::GScr_wudevcsvtotbl(int scriptInst)
{
	auto id = ScrVm_GetString(scriptInst, 1);
	
	if (!strcmp(id, "classes"))
	{
		Scr_AddInt(scriptInst, zbr::table::csv_to_table(id, zbr::weapons::class_table));
	}
	else if (!strcmp(id, "roles")) 
	{
		Scr_AddInt(scriptInst, zbr::table::csv_to_table(id, zbr::weapons::role_table));
	}
	else
	{
		Scr_AddInt(scriptInst, 0);
	}

	zbr::weapons::update_weapon_stats();
}

#define WU_TUNE_BMP 0
#define WU_TUNE_HMP 1
#define WU_TUNE_CLASS 2
#define WU_TUNE_ROLE 3

void GSCBuiltins::GScr_wudev_tuner(int scriptInst)
{
	auto id = ScrVm_GetInt(scriptInst, 1);
	
	switch (id)
	{
		case WU_TUNE_BMP:
			zbr::weapons::bal_table.set_float(zbr::weapons::selection.row, WUBCN_TBMP, ScrVm_GetFloat(scriptInst, 2));
			break;
		case WU_TUNE_HMP:
			zbr::weapons::bal_table.set_float(zbr::weapons::selection.row, WUBCN_THMP, ScrVm_GetFloat(scriptInst, 2));
			break;
		case WU_TUNE_CLASS:
			zbr::weapons::bal_table.set_int(zbr::weapons::selection.row, WUBCN_CLASS, ScrVm_GetInt(scriptInst, 2));
			break;
		case WU_TUNE_ROLE:
			zbr::weapons::bal_table.set_int(zbr::weapons::selection.row, WUBCN_ROLE, ScrVm_GetInt(scriptInst, 2));
			break;
	}

	zbr::weapons::update_weapon_stats();
}

void GSCBuiltins::GScr_wu_is_tuned(int scriptInst)
{
	auto w = Scr_GetWeapon(scriptInst, 1);
	Scr_AddInt(scriptInst, zbr::weapons::mods.find((unsigned short)(w & 511)) != zbr::weapons::mods.end());
}

void GSCBuiltins::GScr_wu_get_class(int scriptInst)
{
	auto w = Scr_GetWeapon(scriptInst, 1);
	auto r = zbr::weapons::mods.find((unsigned short)(w & 511));
	auto c = 0;
	if (r != zbr::weapons::mods.end())
	{
		c = r->second._class;
	}

	Scr_AddInt(scriptInst, c);
}

void GSCBuiltins::GScr_wu_get_hdmp(int scriptInst)
{
	auto w = Scr_GetWeapon(scriptInst, 1);
	auto w_mod = zbr::weapons::mods.find((unsigned short)(w & 511));
	if (w_mod != zbr::weapons::mods.end())
	{
		Scr_AddFloat(scriptInst, w_mod->second.hdmod);
		return;
	}
	Scr_AddFloat(scriptInst, 1.0);
}

void GSCBuiltins::GScr_keyboard(int scriptInst)
{
	char data[256]{ 0 };
	auto title = ScrVm_GetString(scriptInst, 1);
	auto default_text = ScrVm_GetString(scriptInst, 2);
	auto maxlen = ScrVm_GetString(scriptInst, 3);

	snprintf(data, 256, "ui_keyboard_new 17 \"%s\" \"%s\" %s", title, default_text, maxlen);
	((void(__fastcall*)(int, const char*, int))(PTR_Cbuf_AddText))(0, data, 0);
}

void GSCBuiltins::GScr_emote_pressed(int scriptInst)
{
	if(!scriptInst)
	{
		Scr_AddInt(scriptInst, 0);
		return;
	}

	int mask = 0;
	if (GetAsyncKeyState(VK_OEM_3) & 0x8000)
	{
		mask |= 1;
	}
	if (GetAsyncKeyState('7') & 0x8000)
	{
		mask |= 2;
	}
	if (GetAsyncKeyState('8') & 0x8000)
	{
		mask |= 4;
	}
	if (GetAsyncKeyState('9') & 0x8000)
	{
		mask |= 8;
	}
	if (GetAsyncKeyState('0') & 0x8000)
	{
		mask |= 16;
	}
	
	Scr_AddInt(scriptInst, mask);
}

void GSCBuiltins::GScr_get_fav_emote(int scriptInst)
{
	if (!scriptInst)
	{
		Scr_AddInt(scriptInst, 0);
		return;
	}
	auto index = ScrVm_GetInt(scriptInst, 1);

	switch (index)
	{
		case 0:
			Scr_AddInt(scriptInst, zbr::profile::get_int32(CONST32(ZBR_STRINGIFY(PROFILE_VAR_FAVORITE_EMOTE))));
			return;
		case 1:
			Scr_AddInt(scriptInst, zbr::profile::get_int32(CONST32(ZBR_STRINGIFY(PROFILE_VAR_EMOTE1))));
			return;
		case 2:
			Scr_AddInt(scriptInst, zbr::profile::get_int32(CONST32(ZBR_STRINGIFY(PROFILE_VAR_EMOTE2))));
			return;
		case 3:
			Scr_AddInt(scriptInst, zbr::profile::get_int32(CONST32(ZBR_STRINGIFY(PROFILE_VAR_EMOTE3))));
			return;
		case 4:
			Scr_AddInt(scriptInst, zbr::profile::get_int32(CONST32(ZBR_STRINGIFY(PROFILE_VAR_EMOTE4))));
			return;
	}
	Scr_AddInt(scriptInst, 0);
}

void GSCBuiltins::GScr_anim_event(int scriptInst)
{
	auto entnum = ScrVm_GetInt(scriptInst, 1);
	auto event_id = ScrVm_GetInt(scriptInst, 2);
	entref_t_0 entref = entref_t_0();
	entref.p1 = entnum;

	auto _max = (REBASE(0x364EF20) - REBASE(0x364E8C0)) / 16;

	if (event_id <= _max)
	{
		ALOG("anim (%d/%d): %s", event_id, _max, *(__int64*)(REBASE(0x364E8C0) + event_id * 16));
	}
	
	auto entptr = SPOOFED_CALL(((__int64(__fastcall*)(entref_t_0 ent))PTR_Scr_GetEntity), entref);
	unsigned __int32 randseed = *(unsigned __int32*)REBASE(0xA5502C4);
	((void(__fastcall*)(unsigned __int32*))REBASE(0x2687AD0))(&randseed);
	((void(__fastcall*)(__int64, unsigned __int32, __int32, __int32, unsigned __int32*))REBASE(0x2653670))(REBASE(0x9F438F0) + (__int64)5728 * **(int**)(entptr + 592), (unsigned __int32)event_id, 0, 1, &randseed);
}

void GSCBuiltins::GScr_islinked(int scriptInst)
{
	auto entnum = ScrVm_GetInt(scriptInst, 1);
	entref_t_0 entref = entref_t_0();
	entref.p1 = entnum;

	auto entptr = SPOOFED_CALL(((__int64(__fastcall*)(entref_t_0 ent))PTR_Scr_GetEntity), entref);

	auto v2 = *(__int64**)(entptr + 1000);
	Scr_AddInt(scriptInst, v2 && *v2);
}

void GSCBuiltins::GScr_crpc_emote(int scriptInst)
{
	auto emoteid = ScrVm_GetInt(scriptInst, 1);
	zbr::characters::send_emote_rpc(emoteid);
}

void GSCBuiltins::GScr_getspawnweapon(int scriptInst)
{
	auto strXuid = ScrVm_GetString(0, 1);
	auto xuid = (__int64)_strtoui64(strXuid, 0, 16);

	if (xuid == Offsets::GetXUID())
	{
		Scr_AddInt(scriptInst, zbr::profile::get_int32(CONST32(ZBR_STRINGIFY(PROFILE_VAR_SPAWNWEAPON))));
		return;
	}

	if (zbr::gamestate.spawn_weapons.find(xuid) != zbr::gamestate.spawn_weapons.end())
	{
		Scr_AddInt(scriptInst, zbr::gamestate.spawn_weapons[xuid]);
		return;
	}
	Scr_AddInt(scriptInst, 0);
}

void GSCBuiltins::GScr_getcosmetic(int scriptInst)
{
	auto player_index = ScrVm_GetInt(scriptInst, 1);
	if (player_index > 7 || player_index < 0)
	{
		Scr_AddUndefined(scriptInst);
		return;
	}

	auto data = zbr::lobbystate.cosmetics[player_index];

	auto structId = Scr_AddStruct(scriptInst);

	// hat
	Scr_AddInt(scriptInst, data.hat);
	Scr_SetStructField(scriptInst, structId, SL_GenerateCanonicalString("hat"));
}

void GSCBuiltins::GScr_getcosmetic_xuid(int scriptInst)
{
	auto strXuid = ScrVm_GetString(0, 1);
	auto xuid = (__int64)_strtoui64(strXuid, 0, 16);

	zbr_cosmetics_data data;
	
	if (xuid == Offsets::GetXUID())
	{
		zbr::populate_cosmetics(data);
	}
	else
	{
		auto finder = zbr::gamestate.zbr_cosmetics.find(xuid);
		if (finder == zbr::gamestate.zbr_cosmetics.end())
		{
			Scr_AddUndefined(scriptInst);
			return;
		}
		data = finder->second;
	}

	auto structId = Scr_AddStruct(scriptInst);

	// hat
	Scr_AddInt(scriptInst, data.hat);
	Scr_SetStructField(scriptInst, structId, SL_GenerateCanonicalString("hat"));
}

void MatrixTransformVector(const scr_vec3_t* in1, const scr_vec3_t* in2, scr_vec3_t* out)
{
	out->x = (in1->x * in2->x) + (in1->y * in2[1].x) + (in1->z * in2[2].x);
	out->y = (in1->x * in2->y) + (in1->y * in2[1].y) + (in1->z * in2[2].y);
	out->z = (in1->x * in2->z) + (in1->y * in2[1].z) + (in1->z * in2[2].z);
}

void GSCBuiltins::GScr_localtoworld(int scriptInst)
{
	scr_vec3_t origin, angles;
	scr_vec3_t axis[3];
	scr_vec3_t world;
	Scr_GetVector(scriptInst, 1, &origin);
	Scr_GetVector(scriptInst, 2, &angles);
	AnglesToAxis(&angles, axis);
	MatrixTransformVector(&origin, axis, &world);
	Scr_AddVec(scriptInst, &world);
}
#endif

//G_ResetEntityParsePoint
//G_SetEntityParsePoint
//G_ParseSpawnVars
//G_CallSpawn

void GSCBuiltins::nlog(const char* str, ...)
{
}