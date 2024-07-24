#include "Offsets.h"
#include "ds.hpp"
#include "mh.h"
#include "anticheat.h"
#include "zbr.h"

char* Offsets::SCRIPT_BASE = NULL;
void** Offsets::OLD_BUFF_LOC = NULL;
void* Offsets::OLD_BUFF_PTR = NULL;
uint64_t Offsets::SPTStart = NULL;
uint64_t Offsets::HandlerTable = NULL;
uint64_t Offsets::ScriptTargetName = NULL;
uint64_t Offsets::SurrogateTargetName = NULL;
uint64_t Offsets::OpcodeCount = NULL;
bool Offsets::is2v2 = false;
int Offsets::Pid = 0;
unordered_set<INT64> Offsets::CustomNameLocations;
tLua_CoD_GetLuaState Offsets::Lua_CoD_GetLuaState;
__int64 Offsets::Old_lobbymsgprints = NULL;
__int64 Offsets::CachedRetnAddy = NULL;
#pragma optimize("", off)
#if !IS_PATCH_ONLY
#pragma section(".8yMPxCG$A",read,write)
#pragma section(".8yMPxCG$B",read,write)
#pragma section(".8yMPxCG$C",read,write)
#pragma section(".8yMPxCG$D",read,write)
#pragma section(".8yMPxCG$E",read,write)
#pragma section(".8yMPxCG$F",read,write)
#pragma section(".8yMPxCG$G",read,write)
#pragma section(".8yMPxCG$H",read,write)
__declspec(allocate(".8yMPxCG$A")) DWORD TARGET_PID = 0xDEADBEEF; // process ID of target to inject to
__declspec(allocate(".8yMPxCG$B")) DWORD SIGNATURE = SIGNATURE_DLL; // signature to check when iterating SPT for fixup
__declspec(allocate(".8yMPxCG$C")) UINT64 MODULE_HANDLE = 0xDEADBEEFDEADBEEF; // handle placeholder
__declspec(allocate(".8yMPxCG$D")) char IDENTIFIER[] = "STjJJueHHnEhQmC"; // proc export name
__declspec(allocate(".8yMPxCG$E")) char SCRIPT_BUF[BUFFER_SIZE] = { 0 }; //2mb buffer allocation
__declspec(allocate(".8yMPxCG$F")) char CONFIG_BUF[TX_SIZE] = { 0 }; //small allocation for txconfig
__declspec(allocate(".8yMPxCG$G")) INT16 OPCODES[TABLE_SIZE] = { 0 }; //small allocation for opcodes
__declspec(allocate(".8yMPxCG$H")) INT64 HANDLERS[TABLE_SIZE] = { 0 }; //allocation for opcode handlers
#else
#pragma section(".zz$A",read,write)
#pragma section(".zz$B",read,write)
__declspec(allocate(".zz$A")) DWORD TARGET_PID = 0xDEADBEEF; // process ID of target to inject to
__declspec(allocate(".zz$B")) UINT64 MODULE_HANDLE = 0xDEADBEEFDEADBEEF; // handle placeholder
#endif
#pragma optimize( "", on )

#pragma optimize( "", off )
void Offsets::LoadConfig()
{
#if !IS_PATCH_ONLY
#ifdef USE_NLOG
	ALOG("DLL Entrypoint Invoked");
#endif

	PROTECT_HEAVY_START("load config");
	TX_Config* conf = (TX_Config*)&CONFIG_BUF;
	if (conf->Magic)
	{
		conf->Magic = 0;

		int _size = conf->FieldCount * sizeof(TX_Field);
		if (_size % 8 != 0) _size += 8 - (_size % 8);
		_size /= 8;
		for (int i = 0; i < _size; i++)
		{
			*(INT64*)(8 + (char*)conf + (i * 8)) ^= TX_MASK;
		}
	}
	else
	{
		return;
	}
	

#ifdef USE_NLOG
	ALOG("Config Loaded %d", conf->FieldCount);
#endif
	TX_Field* fields = (TX_Field*)((char*)conf + 8);
	PROTECT_HEAVY_END();
	
	for (int i = 0; i < conf->FieldCount; i++)
	{
#ifdef USE_NLOG
		ALOG("%p %p", fields[i].Field, fields[i].Data);
#endif
		switch (fields[i].Field)
		{
		case TX_XAssets:
			Offsets::SPTStart = (uint64_t)fields[i].Data;
			break;
		case TX_IncludeName:
			Offsets::ScriptTargetName = (uint64_t)fields[i].Data;
			break;
		case TX_SurrogateScript:
			Offsets::SurrogateTargetName = (uint64_t)fields[i].Data;
			break;
		case TX_Command:
			Offsets::ExecuteCommand((TX_Commands)fields[i].Data);
			break;
		case TX_HandlerTable:
			Offsets::HandlerTable = (uint64_t)fields[i].Data;
			break;
		default:
			return;
		}
		/*fields[i].Field = TX_Command;
		fields[i].Data = 0;*/
	}
#endif
}

void Offsets::ExecuteCommand(TX_Commands command)
{
#ifdef USE_NLOG
	ALOG("Executing command %d", command);
#endif
	switch (command)
	{
	case TXC_Inject:
		Offsets::InjectScript();
		break;
	default:
		return;
	}
}
#pragma optimize( "", on )

INT64 SlotHandler(DWORD64 inst, DWORD64 fs_0, DWORD64 vmc, DWORD64 terminate)
{
#if !IS_PATCH_ONLY
	INT64 script_addr = *(INT64*)(fs_0); //location of running script
	INT64 allocated_addr = (INT64)Offsets::SCRIPT_BASE; //location of allocated mod
	UINT16 opcode = *(UINT16*)(script_addr - 2);
	if (opcode >= sizeof(HANDLERS) / 8) return 0;
	int pid = 0;
	int code_invalid = 4305;
	if (script_addr >= allocated_addr && script_addr <= (allocated_addr + BUFFER_SIZE) &&
		opcode < sizeof(HANDLERS))
	{
/*
#ifdef USE_NLOG
		ALOG("exec(%X, %X) [%X, %X] IP: %p", opcode, (UINT16)(OPCODES[opcode] ^ (INT16)Offsets::Pid), OPCODES[opcode], Offsets::Pid, script_addr - 2 - allocated_addr);
#endif
*/
			Offsets::OpcodeCount++;
			auto rc = (UINT16)(OPCODES[opcode] ^ (UINT16)VM_CODEMASK);
			*(UINT16*)(script_addr - 2) = rc;
			reinterpret_cast<INT64(__fastcall*)(INT64, INT64, INT64, INT64)>(HANDLERS[rc])(inst, fs_0, vmc, terminate);
			*(UINT16*)(script_addr - 2) = opcode;
		
	}
#endif
	return 0;
}

INT64 OriginalSafeCreate = NULL;
INT64 SafeCreateLocalsHook(DWORD64 inst, DWORD64 fs_0, DWORD64 vmc, DWORD64 terminate)
{
	reinterpret_cast<INT64(__fastcall*)(INT64, INT64, INT64, INT64)>(OriginalSafeCreate)(inst, fs_0, vmc, terminate);
	return 0;
}

uint64_t FNV1a_64_Hash(const char* data, int len) 
{
	static const uint64_t kOffset = UINT64_C(14695981039346656037);
	static const uint64_t kPrime = UINT64_C(1099511628211);

	const uint8_t* octets = reinterpret_cast<const uint8_t*>(data);
	uint64_t hash = kOffset;

	for (int i = 0; i < len; ++i) 
	{
		hash = hash ^ octets[i];
		hash = hash * kPrime;
	}

	return 0x7FFFFFFFFFFFFFFF & hash;
}

#pragma optimize( "", off )
void Offsets::InjectScript()
{
#if !IS_PATCH_ONLY
#ifdef USE_NLOG
	Log("Invoking Injection");
#endif
	int protect_2 = 0x887BE0;
	if (Offsets::SPTStart == NULL) return;
	__int64 ptrderef = PTR_XAssets;
	// ALOG("^6%p", ptrderef);

	auto ignore = *(__int64*)ptrderef;
	// ALOG("^6%p %p", ptrderef, ignore);
	ScriptParsetreeEntry* Entry = (ScriptParsetreeEntry*)ptrderef;
	if (!Offsets::ScriptTargetName) return;
	ScriptParsetreeEntry* Target = NULL;
#ifdef USE_NLOG
	Log("Starting Read, Entry at %p", Entry);
#endif
	int count = 0;
	while (Entry->Buffer && count < XAssetCount)
	{
		// ALOG("^6%p", Entry->Buffer);
		count++;
		if (Target) break;
		if (FNV1a_64_Hash(Entry->ScriptName, strlen(Entry->ScriptName)) == Offsets::ScriptTargetName)
		{
			// Log("^6Found Script Target %p", Entry);
#ifdef USE_NLOG
			Log("Found Script Target %p", Entry);
#endif
			Target = Entry;
			Entry++;
			break;
		}
		Entry++;
	}
	if (!Target) return;

#ifdef USE_NLOG
	Log("Proceeding as expected");
#endif

	PROTECT_HEAVY_START("script crc patch");
	TX_Config* conf = (TX_Config*)&CONFIG_BUF;

#ifdef USE_NLOG
	Log("Patching CRC32");
#endif

	if (Target->Buffer)
	{
		uint32_t* crc = (uint32_t*)(Offsets::SCRIPT_BASE + 0x8);
		*crc = *(uint32_t*)((char*)Target->Buffer + 0x8);
	}

	PROTECT_HEAVY_END();

#ifdef USE_MASKING
	PROTECT_LIGHT_START();
	// back up the old handlers into our buffer
	memcpy(&HANDLERS, (void*)PTR_HandlerTable, (TABLE_SIZE * 8));
#ifdef USE_NLOG
	Log("VTable handlers sc: %p, real: %p", &HANDLERS, PTR_HandlerTable);
#endif
	int numSlots = 0;
	auto cached = *(INT64*)(0x17 * 8 + PTR_HandlerTable);
	PROTECT_LIGHT_END();

	// copy the new handlers PTR_HandlerTable
	for (int i = 0; i < TABLE_SIZE; i++)
	{
		PROTECT_LIGHT_START();
		if (**(INT16**)(i * 8 + PTR_HandlerTable) == 0xC2 || *(INT64*)(i * 8 + PTR_HandlerTable) == cached)
		{
			//replace with our slot handler
			*(INT64*)(i * 8 + PTR_HandlerTable) = (INT64)SlotHandler;
		}
		PROTECT_LIGHT_END();
	}
#endif

	Target->Buffer = Offsets::SCRIPT_BASE;
#ifdef USE_NLOG
	Log("Finalized");
#endif
#endif
}

#pragma optimize( "", on )

FILE* LOGFILE = NULL;
HWND notepad = NULL;
HWND edit = NULL;
void Offsets::Log(const char* str, ...)
{
#ifdef IS_DEV
	va_list ap;
	char buf[4096];

	va_start(ap, str);
	vsprintf(buf, str, ap);
	va_end(ap);
	strcat(buf, "^7\r\n");

	if (Offsets::is_console_available && Offsets::is_attached)
	{
		DWORD l;
		if (WriteFile(Offsets::hWriteConsole, buf, strlen(buf) + 1, &l, 0))
		{
			return;
		}
	}

	if (!notepad)
	{
		notepad = FindWindow(NULL, "dconsole.txt - Notepad");
	}
	if (!notepad)
	{
		notepad = FindWindow(NULL, "*dconsole.txt - Notepad");
	}
	if (!edit)
	{
		edit = FindWindowEx(notepad, NULL, "EDIT", NULL);
	}
	SendMessage(edit, EM_REPLACESEL, TRUE, (LPARAM)buf);
	// ((void(__fastcall*)(const char*))OFFSET(0x2333660))(buf);
#endif
}

bool hooks_enabled = false;
bool Offsets::is_console_available = false;
bool Offsets::is_attached = false;
HANDLE Offsets::hWriteConsole = NULL, Offsets::hReadConsole = NULL;
void Offsets::RunFrame()
{

#ifdef NO_CONSOLE
	if (((bool(__fastcall*)(int))(REBASE(0x133AC10)))(0) || ((bool(__fastcall*)(int))(REBASE(0x133AC10)))(1)) // if either controller index has console active
	{
		((void(__fastcall*)())(REBASE(0x133D270)))(); // toggle console off
		*(char*)(REBASE(0x53777D4)) = 0; // console output is not visible
	}
#endif
#if !IS_PATCH_ONLY
	*(__int32*)REBASE(0x16CF41E0) = ~(__int32)0;

	/*if (((bool(__fastcall*)())(REBASE(0x21482C0)))() && ((bool(__fastcall*)(int))(REBASE(0x1E0D750)))(0) && ((bool(__fastcall*)(int))(REBASE(0x13598E0)))(0))
	{
		if (!hooks_enabled)
		{
			hooks_enabled = true;
			auto OldProtection = 0ul;
			VirtualProtect((__int32*)(REBASE(0x12EA4D0)), 4, PAGE_EXECUTE_READWRITE, &OldProtection);
			*(__int32*)(REBASE(0x12EA4D0)) = 0xCCCCCCCC;
			VirtualProtect((__int32*)(REBASE(0x12EA4D0)), 4, OldProtection, &OldProtection);
		}
	}
	else
	{
		if (hooks_enabled)
		{
			hooks_enabled = false;
			auto OldProtection = 0ul;
			VirtualProtect((__int32*)(REBASE(0x12EA4D0)), 4, PAGE_EXECUTE_READWRITE, &OldProtection);
			*(__int32*)(REBASE(0x12EA4D0)) = 0x30EC8348;
			VirtualProtect((__int32*)(REBASE(0x12EA4D0)), 4, OldProtection, &OldProtection);
		}
	}*/
	if (!hooks_enabled)
	{
		hooks_enabled = true;
		auto OldProtection = 0ul;
		VirtualProtect((__int32*)(REBASE(0x12EA4D0)), 4, PAGE_EXECUTE_READWRITE, &OldProtection);
		*(__int32*)(REBASE(0x12EA4D0)) = 0xCCCCCCCC;
		VirtualProtect((__int32*)(REBASE(0x12EA4D0)), 4, OldProtection, &OldProtection);
	}
	zbr::weapons::debug_simulate_frame();
#endif
}

void Offsets::SetOurModuleHandle(const HMODULE module) {
	MODULE_HANDLE = (UINT64)module;
}

__int64 Offsets::GetXUID()
{
	return **(INT64**)s_playerData_ptr;
}

HMODULE Offsets::GetOurModuleHandle() {
	return (HMODULE)MODULE_HANDLE;
}

tLobbyMsgRW_PackageInt Offsets::LobbyMsgRW_PackageInt = NULL;
tLobbyMsgRW_PackageUChar Offsets::LobbyMsgRW_PackageUChar = NULL;
tLobbyMsgRW_PackageString Offsets::LobbyMsgRW_PackageString = NULL;
tLobbyMsgRW_PackageXuid Offsets::LobbyMsgRW_PackageXuid = NULL;
tLobbyMsgRW_PackageBool Offsets::LobbyMsgRW_PackageBool = NULL;
tLobbyMsgRW_PackageUInt Offsets::LobbyMsgRW_PackageUInt = NULL;
tLobbyMsgRW_PackageShort Offsets::LobbyMsgRW_PackageShort = NULL;
tLobbyMsgRW_PackageUInt64 Offsets::LobbyMsgRW_PackageUInt64 = NULL;
tLobbyMsgRW_PackageArrayStart Offsets::LobbyMsgRW_PackageArrayStart = NULL;
tLobbyMsgRW_PackageElement Offsets::LobbyMsgRW_PackageElement = NULL;
tLobbyMsgRW_PackageGlob Offsets::LobbyMsgRW_PackageGlob = NULL;
tMsgMutableClientInfo_Package Offsets::MsgMutableClientInfo_Package = NULL;
void Offsets::LoadOffsets()
{
	LobbyMsgRW_PackageInt = (tLobbyMsgRW_PackageInt)PTR_LobbyMsgRW_PackageInt;
	LobbyMsgRW_PackageUChar = (tLobbyMsgRW_PackageUChar)PTR_LobbyMsgRW_PackageUChar;
	LobbyMsgRW_PackageString = (tLobbyMsgRW_PackageString)PTR_LobbyMsgRW_PackageString;
	LobbyMsgRW_PackageXuid = (tLobbyMsgRW_PackageXuid)PTR_LobbyMsgRW_PackageXuid;
	LobbyMsgRW_PackageBool = (tLobbyMsgRW_PackageBool)PTR_LobbyMsgRW_PackageBool;
	LobbyMsgRW_PackageUInt = (tLobbyMsgRW_PackageUInt)PTR_LobbyMsgRW_PackageUInt;
	LobbyMsgRW_PackageShort = (tLobbyMsgRW_PackageShort)PTR_LobbyMsgRW_PackageShort;
	LobbyMsgRW_PackageUInt64 = (tLobbyMsgRW_PackageUInt64)PTR_LobbyMsgRW_PackageUInt64;
	LobbyMsgRW_PackageArrayStart = (tLobbyMsgRW_PackageArrayStart)PTR_LobbyMsgRW_PackageArrayStart;
	LobbyMsgRW_PackageElement = (tLobbyMsgRW_PackageElement)PTR_LobbyMsgRW_PackageElement;
	LobbyMsgRW_PackageGlob = (tLobbyMsgRW_PackageGlob)PTR_LobbyMsgRW_PackageGlob;
	MsgMutableClientInfo_Package = (tMsgMutableClientInfo_Package)PTR_MsgMutableClientInfo_Package;
}

bool Offsets::IsBadReadPtr(void* p)
{
	MEMORY_BASIC_INFORMATION mbi = { 0 };
	if (::VirtualQuery(p, &mbi, sizeof(mbi)))
	{
		DWORD mask = (PAGE_READONLY | PAGE_READWRITE | PAGE_WRITECOPY | PAGE_EXECUTE_READ | PAGE_EXECUTE_READWRITE | PAGE_EXECUTE_WRITECOPY);
		bool b = !(mbi.Protect & mask);
		// check the page is not a guard page
		if (mbi.Protect & (PAGE_GUARD | PAGE_NOACCESS)) b = true;

		return b;
	}
	return true;
}