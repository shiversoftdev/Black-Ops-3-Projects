#pragma once
#include "framework.h"
#include <filesystem>
#include <fstream>
#include <string>
#include <vector>
#include <stdio.h>
#include <iostream>
#include <Windows.h>
#include <filesystem>
#include <TlHelp32.h>
#include <unordered_set>
#include "offset_fixups.h"

namespace fs = std::filesystem;
using namespace std;

#ifdef retard_injection
#define PATH_Script "C:\\txscript\\script.tx"
#define PATH_Config "C:\\txscript\\tx.conf"
#endif

#define UseSafeInjector

#ifdef UseSafeInjector
#define UseSetwindowHandleEx
#endif

class WinArg {
public:
	WinArg(int argc, const char* argv[]) {
		this->tokens = std::vector<std::string>(argv, argv + argc);
	}

	const std::string& GetOption(const std::string& option, const std::string& alias = "") {
		static const std::string empty_string("");

		auto itr = std::find(this->tokens.begin(), this->tokens.end(), option);

		if (itr != this->tokens.end() && ++itr != this->tokens.end())
			return *itr;

		if (alias != "")
			return GetOption(alias);

		return empty_string;
	}

	bool OptionExists(const std::string& option, const std::string& alias = "") {
		return std::find(this->tokens.begin(), this->tokens.end(), option) != this->tokens.end() || (alias != "" && OptionExists(alias));
	}

private:
	std::vector<std::string> tokens;
};

enum TX_FIELDS : int32_t
{
	TX_Command = 0,
	TX_XAssets = 1,
	TX_Cbuff = 2,
	TX_IncludeName = 3,
	TX_SurrogateScript = 4,
	TX_HandlerTable = 5,
};

// remember to update debug info prints
enum MsgType_z
{
	MESSAGE_TYPE_ZBR_LOBBYINFO_REQUEST = 0x21, // UNUSED
	MESSAGE_TYPE_ZBR_LOBBYINFO_RESPONSE = 0x22,
	MESSAGE_TYPE_ZBR_LOBBYSTATE = 0x23,
	MESSAGE_TYPE_ZBR_CLIENTRELIABLE = 0x24,
	MESSAGE_TYPE_ZBR_CHARACTERRPC = 0x25,
	MESSAGE_TYPE_ZBR_COUNT
};

enum TX_Commands : int32_t
{
	TXC_Inject = 0
};


struct TX_Config
{
	uint16_t Magic;
	char VM;
	char Pad;
	uint32_t FieldCount;
};

#pragma pack(2)
struct TX_Field
{
	TX_FIELDS Field;
	uint64_t Data;
};

struct ScriptParsetreeEntry
{
	char* ScriptName;
	int32_t buffSize;
	int32_t pad;
	char* Buffer;
};

struct DDLState
{
	__int32 isValid;
	__int32 offset;
	__int32 arrayIndex;
	__int32 padding;
	void* member;
	void* ddlDef;
};

struct vec3_coords
{
	float x;
	float y;
	float z;
};

struct vec3_array
{
	float v[3];
};

union vec3_t
{
	vec3_coords v;
	vec3_array a;
};

struct vec4_coords
{
	float x;
	float y;
	float z;
	float w;
};

struct vec4_array
{
	float v[4];
};

union vec4_t
{
	vec4_coords v;
	vec4_array a;
};

static std::vector<char> ReadAllBytes(char const* filename)
{
	ifstream ifs(filename, ios::binary | ios::ate);
	ifstream::pos_type pos = ifs.tellg();
	std::vector<char>  result(pos);
	ifs.seekg(0, ios::beg);
	ifs.read(&result[0], pos);
	return result;
}

typedef BOOL(__fastcall* tLobbyMsgRW_PackageInt)(void* lobbyMsg, const char* key, int32_t* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageUChar)(void* lobbyMsg, const char* key, char* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageString)(void* lobbyMsg, const char* key, const char* val, int maxLength);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageXuid)(void* lobbyMsg, const char* key, unsigned __int64* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageBool)(void* lobbyMsg, const char* key, char* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageUInt)(void* lobbyMsg, const char* key, unsigned __int32* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageShort)(void* lobbyMsg, const char* key, __int16* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageUInt64)(void* lobbyMsg, const char* key, unsigned __int64* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageArrayStart)(void* lobbyMsg, const char* key);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageElement)(void* lobbyMsg, BOOL addElement);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageGlob)(void* lobbyMsg, const char* key, const char* val, int maxLength);
typedef BOOL(__fastcall* tMsgMutableClientInfo_Package)(void* outRequest, void* lobbyMsg);

typedef INT64(__fastcall* tLua_CoD_GetLuaState)(int VM);
#define CUSTOM_NAME_SIZE 16
class Offsets
{
public:
	static bool is2v2;
	static char* SCRIPT_BASE;
	static unordered_set<INT64> CustomNameLocations;
	static void** OLD_BUFF_LOC;
	static void* OLD_BUFF_PTR;
	static uint64_t SPTStart;
	static uint64_t HandlerTable;
	static uint64_t ScriptTargetName;
	static uint64_t SurrogateTargetName;
	static uint64_t OpcodeCount;
	static tLua_CoD_GetLuaState Lua_CoD_GetLuaState;
	static int Pid;
	static void LoadConfig();
	static void ExecuteCommand(TX_Commands command);
	static void InjectScript();
	static void Log(const char* str, ...);
	static void RunFrame();
	static void SetOurModuleHandle(const HMODULE module);
	static __int64 GetXUID();
	static __int64 Old_lobbymsgprints;
	static __int64 CachedRetnAddy;
	static HMODULE GetOurModuleHandle();
	static void LoadOffsets();
	static bool IsBadReadPtr(void* p);


	static tLobbyMsgRW_PackageInt LobbyMsgRW_PackageInt;
	static tLobbyMsgRW_PackageUChar LobbyMsgRW_PackageUChar;
	static tLobbyMsgRW_PackageString LobbyMsgRW_PackageString;
	static tLobbyMsgRW_PackageXuid LobbyMsgRW_PackageXuid;
	static tLobbyMsgRW_PackageBool LobbyMsgRW_PackageBool;
	static tLobbyMsgRW_PackageUInt LobbyMsgRW_PackageUInt;
	static tLobbyMsgRW_PackageShort LobbyMsgRW_PackageShort;
	static tLobbyMsgRW_PackageUInt64 LobbyMsgRW_PackageUInt64;
	static tLobbyMsgRW_PackageArrayStart LobbyMsgRW_PackageArrayStart;
	static tLobbyMsgRW_PackageElement LobbyMsgRW_PackageElement;
	static tLobbyMsgRW_PackageGlob LobbyMsgRW_PackageGlob;
	static tMsgMutableClientInfo_Package MsgMutableClientInfo_Package;
	static bool is_console_available;
	static bool is_attached;
	static HANDLE hWriteConsole, hReadConsole;
};

#define PTR_XAssets *(uint64_t*)REBASE(Offsets::SPTStart)
#define XAssetCount *(uint32_t*)(REBASE(Offsets::SPTStart) + 0xC)
#define PTR_HandlerTable REBASE(Offsets::HandlerTable)

// dont mess with these because when I add new games, these macros will change

#define XASSETTYPE_SCRIPTPARSETREE 0x36u

#define DEFAULT_PLAYERNAME "ZBR Player"
// 1EF8030 -- 