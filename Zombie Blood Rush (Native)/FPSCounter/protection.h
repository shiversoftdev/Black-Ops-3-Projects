#pragma once
#pragma once
#pragma once
#include "framework.h"
#include "ds.hpp"
#include "offset_fixups.h"
#include <unordered_map>

#include <iostream>
#include <windows.h>
#include <cstdint>
#include <functional>

// #define EMERGENCY_PRINTS
// #define NO_NAME
// TODO Cmd_TokenizeInternal 
namespace Iat_hook_
{
	void** find(const char* function, HMODULE module);

	uintptr_t detour_iat_ptr(const char* function, void* newfunction, HMODULE module = 0);
};

typedef unsigned long long(__fastcall* tZwContinue)(PCONTEXT ThreadContext, BOOLEAN RaiseAlert);
typedef int(__fastcall* tI_stricmp)(const char* str1, const char* str2);

enum netsrc_t
{
	NS_NULL = -1,
	NS_CLIENT1 = 0,
	NS_CLIENT2 = 1,
	NS_CLIENT3 = 2,
	NS_CLIENT4 = 3,
	NS_SERVER = 4,
	NS_MAXCLIENTS = 4,
	NS_PACKET = 5
};

struct netadr_t
{
	unsigned char ipv4[4];
	unsigned __int16 port;
	unsigned __int16 pad;
	__int32 type;
	netsrc_t localNetID;
};

enum LobbyModule
{
	LOBBY_MODULE_INVALID = 0xFFFFFFFF,
	LOBBY_MODULE_HOST = 0x0,
	LOBBY_MODULE_CLIENT = 0x1,
	LOBBY_MODULE_PEER_TO_PEER = 0x3,
	LOBBY_MODULE_COUNT = 0x4,
};

enum LobbyType
{
	LOBBY_TYPE_INVALID = 0xFFFFFFFF,
	LOBBY_TYPE_PRIVATE = 0x0,
	LOBBY_TYPE_GAME = 0x1,
	LOBBY_TYPE_TRANSITION = 0x2,
	LOBBY_TYPE_COUNT = 0x3,
	LOBBY_TYPE_FIRST = 0x0,
	LOBBY_TYPE_LAST = 0x2,
	LOBBY_TYPE_AUTO = 0x3,
};

enum LobbyMode
{
	LOBBY_MODE_INVALID = 0xFFFFFFFF,
	LOBBY_MODE_PUBLIC = 0x0,
	LOBBY_MODE_CUSTOM = 0x1,
	LOBBY_MODE_THEATER = 0x2,
	LOBBY_MODE_ARENA = 0x3,
	LOBBY_MODE_FREERUN = 0x4,
	LOBBY_MODE_COUNT = 0x5,
};

enum SessionActive
{
	SESSION_INACTIVE = 0x0,
	SESSION_KEEP_ALIVE = 0x1,
	SESSION_ACTIVE = 0x2,
};

enum NetChanMsgType_e
{
	NETCHAN_INVALID_CHANNEL = 0xFFFFFFFF,
	NETCHAN_SNAPSHOT = 0x0,
	NETCHAN_CLIENTMSG = 0x1,
	NETCHAN_VOICE = 0x2,
	NETCHAN_LOBBY_VOICE = 0x3,
	NETCHAN_LOBBYPRIVATE_STATE = 0x4,
	NETCHAN_LOBBYPRIVATE_HEARTBEAT = 0x5,
	NETCHAN_LOBBYPRIVATE_RELIABLE = 0x6,
	NETCHAN_LOBBYPRIVATE_UNRELIABLE = 0x7,
	NETCHAN_LOBBYPRIVATE_MIGRATE = 0x8,
	NETCHAN_LOBBYGAME_STATE = 0x9,
	NETCHAN_LOBBYGAME_HEARTBEAT = 0xA,
	NETCHAN_LOBBYGAME_RELIABLE = 0xB,
	NETCHAN_LOBBYGAME_UNRELIABLE = 0xC,
	NETCHAN_LOBBYGAME_MIGRATE = 0xD,
	NETCHAN_LOBBY_JOIN = 0xE,
	NETCHAN_PTP = 0xF,
	NETCHAN_CLIENT_CONTENT = 0x10,
	NETCHAN_MAX_CHANNELS = 0x11,
};

struct LobbySession
{
	LobbyModule module;
	LobbyType type;
	LobbyMode mode;
	char pad[0x34];
	SessionActive active;
	char pad2[0x121D4];
};

struct JoinPartyMember
{
	__int64 XUID;
	__int64 lobbyID;
	float skillRating;
	float skilVariance;
	__int32 probationTimeRemaining[2];
};

struct FixedClientInfo
{
	__int64 xuid;
	char gamertag[32];
};

struct SessionInfo
{
	bool inSession;
	char pad[7];
	netadr_t netAdr;
	time_t lastMessageSentToPeer;
};

struct ActiveClient
{
	char pad[0x410];
	FixedClientInfo fixedClientInfo;
	SessionInfo sessionInfo[2];
};

struct SessionClient
{
	char pad[0x8];
	ActiveClient* activeClient;
};

enum MsgType
{
	MESSAGE_TYPE_NONE = -1,
	MESSAGE_TYPE_INFO_REQUEST = 0,
	MESSAGE_TYPE_INFO_RESPONSE = 1,
	MESSAGE_TYPE_LOBBY_STATE_PRIVATE = 2,
	MESSAGE_TYPE_LOBBY_STATE_GAME = 3,
	MESSAGE_TYPE_LOBBY_STATE_GAMEPUBLIC = 4,
	MESSAGE_TYPE_LOBBY_STATE_GAMECUSTOM = 5,
	MESSAGE_TYPE_LOBBY_STATE_GAMETHEATER = 6,
	MESSAGE_TYPE_LOBBY_HOST_HEARTBEAT = 7,
	MESSAGE_TYPE_LOBBY_HOST_DISCONNECT = 8,
	MESSAGE_TYPE_LOBBY_HOST_DISCONNECT_CLIENT = 9,
	MESSAGE_TYPE_LOBBY_HOST_LEAVE_WITH_PARTY = 0xA,
	MESSAGE_TYPE_LOBBY_CLIENT_HEARTBEAT = 0xB,
	MESSAGE_TYPE_LOBBY_CLIENT_DISCONNECT = 0xC,
	MESSAGE_TYPE_LOBBY_CLIENT_RELIABLE_DATA = 0xD,
	MESSAGE_TYPE_LOBBY_CLIENT_CONTENT = 0xE,
	MESSAGE_TYPE_LOBBY_MODIFIED_STATS = 0xF,
	MESSAGE_TYPE_JOIN_LOBBY = 0x10,
	MESSAGE_TYPE_JOIN_RESPONSE = 0x11,
	MESSAGE_TYPE_JOIN_AGREEMENT_REQUEST = 0x12,
	MESSAGE_TYPE_JOIN_AGREEMENT_RESPONSE = 0x13,
	MESSAGE_TYPE_JOIN_COMPLETE = 0x14,
	MESSAGE_TYPE_JOIN_MEMBER_INFO = 0x15,
	MESSAGE_TYPE_SERVERLIST_INFO = 0x16,
	MESSAGE_TYPE_PEER_TO_PEER_CONNECTIVITY_TEST = 0x17,
	MESSAGE_TYPE_PEER_TO_PEER_INFO = 0x18,
	MESSAGE_TYPE_LOBBY_MIGRATE_TEST = 0x19,
	MESSAGE_TYPE_MIGRATE_ANNOUNCE_HOST = 0x1A,
	MESSAGE_TYPE_MIGRATE_START = 0x1B,
	MESSAGE_TYPE_INGAME_MIGRATE_TO = 0x1C,
	MESSAGE_TYPE_MIGRATE_NEW_HOST = 0x1D,
	MESSAGE_TYPE_VOICE_PACKET = 0x1E,
	MESSAGE_TYPE_VOICE_RELAY_PACKET = 0x1F,
	MESSAGE_TYPE_DEMO_STATE = 0x20,
	MESSAGE_TYPE_COUNT = MESSAGE_TYPE_DEMO_STATE + 1
};

struct msg_t
{
	bool overflowed; // 0x0
	bool readOnly; // 0x1
	__int16 pad1; // 0x2
	__int32 pad2; // 0x4
	char* data; // 0x8
	char* splitData; // 0x10
	unsigned __int32 maxsize; // 0x18
	unsigned __int32 cursize; // 0x1C
	unsigned __int32 splitSize; // 0x20
	unsigned __int32 readcount; // 0x24
	__int32 bit; // 0x28
	__int32 lastEntityRef; // 0x2C
	__int32 flush; // 0x30
	netsrc_t targetLocalNetID; // 0x34
};

struct LobbyMsg
{
	msg_t msg;
	__int32 msgType; // 0x38
	char encodeFlags;
	__int32 packageType;
};

struct bdSecurityID
{
	__int64 id;
};

struct bdSecurityKey
{
	char ab[16];
};

struct SerializedAdr
{
	char valid;
	char addrBuf[37];
};

struct LobbyParams
{
	__int32 networkMode;
	__int32 mainMode;
};

struct InfoResponseLobby
{
	char isValid; // 0x0
	char pad[3];
	__int32 pad2;
	__int64 hostXuid; // 0x8
	char hostName[0x20]; // 0x10
	bdSecurityID secId; // 0x30
	bdSecurityKey secKey; // 0x38
	SerializedAdr serializedAdr; // 0x48
	char pad3[2]; // 0x6E
	LobbyParams lobbyParams; // 0x70
	char ugcName[0x20]; // 0x78
	__int32 ugcVersion; // 0x98
	char pad4[0x4]; // 0x9C
};

struct Msg_InfoResponse
{
	__int32 nonce;
	__int32 uiScreen;
	char natType;
	char pad[3];
	__int32 pad2;
	InfoResponseLobby lobby[2];
};

typedef BOOL(__fastcall* tLobbyMsgRW_PackageInt)(void* lobbyMsg, const char* key, int32_t* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageUChar)(void* lobbyMsg, const char* key, char* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageString)(void* lobbyMsg, const char* key, const char* val, int maxLength);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageXuid)(void* lobbyMsg, const char* key, unsigned __int64* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageBool)(void* lobbyMsg, const char* key, char* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageUInt)(void* lobbyMsg, const char* key, unsigned __int32* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageShort)(void* lobbyMsg, const char* key, __int16* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageUShort)(void* lobbyMsg, const char* key, unsigned __int16* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageUInt64)(void* lobbyMsg, const char* key, unsigned __int64* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageArrayStart)(void* lobbyMsg, const char* key);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageElement)(void* lobbyMsg, BOOL addElement);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageGlob)(void* lobbyMsg, const char* key, const char* val, int maxLength);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageFloat)(void* lobbyMsg, const char* key, float* val);
typedef BOOL(__fastcall* tLobbyMsgRW_PackageChar)(void* lobbyMsg, const char* key, char* val);
typedef BOOL(__fastcall* tLobbyJoin_Reserve)(__int32 controllerIndex, JoinPartyMember* members, int memberCount, __int64 clientJoinNonce, __int64 probedXuid, __int64* outKey);
typedef BOOL(__fastcall* tMsgMutableClientInfo_Package)(void* outRequest, void* lobbyMsg);
typedef BOOL(__fastcall* tProbeLobbyInfo)(int zero1, int zero2, __int64 XUID);
typedef BOOL(__fastcall* tdwInstantHandleLobbyMessage)(__int64 senderID, int controllerIndex, char* message);
typedef BOOL(__fastcall* tdwInstantSendMessage)(__int32 controllerIndex, __int64* recipientUIDs, unsigned __int32 numRecipients, char msgType, const char* message, unsigned __int32 msgSize);
typedef BOOL(__fastcall* tNET_OutOfBandPrint)(netsrc_t netsrc, netadr_t adr, const char* message);
typedef bool(__fastcall* tLobbySession_GetControllingLobbySession)(LobbyModule lMod);
typedef LobbySession* (__fastcall* tLobbySession_GetSession)(unsigned int s);
typedef SessionClient* (__fastcall* tLobbySession_GetClientByClientNum)(LobbySession* session, int m);
typedef netadr_t(__fastcall* tLobbySession_GetClientNetAdrByIndex)(LobbyType type, int clientnum);
typedef int(__fastcall* tI_stricmp)(const char* str1, const char* str2);
typedef void(__fastcall* tdwCommonAddrToNetadr)(netadr_t* const netadr, const void* commonAddrBuf, const void* secID);
typedef void(__fastcall* tdwRegisterSecIDAndKey)(void* bdSecurityID, void* bdSecurityKey);
typedef void(__fastcall* tLobbyMsgTansport_SendOutOfBand)(int controllerIndex, __int64 targetXUID, netadr_t adr, LobbyMsg* msg, int msgType);
typedef bool(__fastcall* tLobbyMsgRW_PrepWriteMsg)(LobbyMsg* lobbyMsg, char* data, int length, int msgType);
typedef void(__fastcall* tMSG_Init)(msg_t* msg, char* data, int length);
typedef void(__fastcall* tMSG_WriteString)(msg_t* msg, const char* data);
typedef void(__fastcall* tMSG_WriteShort)(msg_t* msg, __int16 data);
typedef void(__fastcall* tMSG_WriteByte)(msg_t* msg, unsigned char data);
typedef void(__fastcall* tMSG_WriteData)(msg_t* msg, char* data, __int32 count);
typedef void(__fastcall* tMSG_ReadData)(msg_t* msg, char*, int);
typedef bool(__fastcall* tLobbyMsgRW_PrepReadData)(LobbyMsg*, char*, int);
typedef bool(__fastcall* tMSG_InfoResponse)(void*, LobbyMsg*);
typedef __int32(__fastcall* tCom_ControllerIndex_GetLocalClientNum)(__int32 controllerIndex);
typedef netsrc_t(__fastcall* tCom_LocalClient_GetNetworkID)(__int32 localClientNum);
typedef BOOL(__fastcall* tNET_OutOfBandData)(netsrc_t networkID, netadr_t netadr, char* data, __int32 count);
typedef BOOL(__fastcall* tLobbyMsgTransport_SendToAdr)(int controllerIndex, NetChanMsgType_e channel, LobbyModule destModule, netadr_t adr, uint64_t toXuid, msg_t* msg, MsgType msgType);
typedef const char* (__fastcall* tCL_GetConfigString)(__int32 index);
typedef bool(__fastcall* tCbuf_AddText)(int controllerIndex, const char* input, int alwaysZero);

class Protection
{
public:
	static char CustomName[16];
	static __int64 Old_lobbymsgprints;
	static __int64 CachedRetnAddy;
	static __int64 CachedXUID;
	static char requestOut[0x20000];
	static char lobbyMsgCpy[0x50];
	static bool IsFriendsOnly;
	static bool IsMTLPatchEnabled;
	static bool IsInjectorlessInstall;

	static void install();
	static void uninstall();
	static bool IsBadReadPtr(void* p);
	static const char* GetUsernamePtr(INT64 a);
	static const char* GetUsernameXUIDPtr(INT64 a, INT64 b);
	static void SwapSteamAPIPointer(__int64 hLibrary, int vPointerIndex, void* CallFuncReplace);
	static INT64 GetOriginalSteamPtr(__int64 hLibrary, int vtIndex);
	static __int32 CL_SwitchState_Idle_Update(INT64 sw);
	static void SetThreadExceptions(PCONTEXT ThreadContext);
	static void ExceptHook(PEXCEPTION_RECORD ExceptionRecord, PCONTEXT ContextRecord);
	static void InspectLM(PEXCEPTION_RECORD ExceptionRecord, PCONTEXT ContextRecord);
	static int MSG_JoinParty_Package_Inspect(char* _this, char* lobbyMsg);
	static int MSG_LobbyState_Package_Inspect(char* __this, char* lobbyMsg);
	static int MSG_LobbyStateGame_Package_Inspect(char* __this, char* lobbyMsg);
	static int MSG_HostHeartbeat_Inspect(char* __this, char* lobbyMsg);
	static bool CheckPendingInfoRequests(__int64 XUID, msg_t* _msg);
	static bool GetOwnsContent(INT64 a, INT32 b);
	static bool GetOwnsContent2(INT64 a, INT32 b);
	static bool IsVacBanned(INT64 a);
	static void GetDlcDownloadProgress(INT64 a, INT32 b, INT64* c, INT64* d);
	static __int32 GetLobbyChatEntry(INT64 api, INT64 a, INT64 b, INT64 c, INT64 d, INT64 e, INT64 f);
	static bool IsFriendByXUIDUncached(__int64 xuid);
	static __int64 CreateLobby(INT64 api, __int32 a, __int32 b);
	static int MSG_InfoResponseSafe(Msg_InfoResponse* infoResponse, LobbyMsg* lm);
	static void SetNetworkPassword(__int64 pass);

	static tZwContinue ZwContinue;
	static tI_stricmp I_stricmp;
	static char* UILocalizeDefaultText;

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
	static tProbeLobbyInfo ProbeLobbyInfo;
	static tdwInstantHandleLobbyMessage dwInstantHandleLobbyMessage;
	static tNET_OutOfBandPrint NET_OutOfBandPrint;
	static tdwCommonAddrToNetadr dwCommonAddrToNetadr;
	static tdwRegisterSecIDAndKey dwRegisterSecIDAndKey;
	static tLobbyMsgRW_PrepWriteMsg LobbyMsgRW_PrepWriteMsg;
	static tLobbyMsgRW_PackageUShort LobbyMsgRW_PackageUShort;
	static tLobbyMsgRW_PackageFloat LobbyMsgRW_PackageFloat;
	static tMSG_Init MSG_Init;
	static tMSG_WriteString MSG_WriteString;
	static tMSG_WriteShort MSG_WriteShort;
	static tMSG_WriteByte MSG_WriteByte;
	static tMSG_WriteData MSG_WriteData;
	static tCom_ControllerIndex_GetLocalClientNum Com_ControllerIndex_GetLocalClientNum;
	static tCom_LocalClient_GetNetworkID Com_LocalClient_GetNetworkID;
	static tNET_OutOfBandData NET_OutOfBandData;
	static tLobbyMsgTransport_SendToAdr LobbyMsgTransport_SendToAdr;
	static tMSG_ReadData MSG_ReadData;
	static tLobbyMsgRW_PrepReadData LobbyMsgRW_PrepReadData;
	static tMSG_InfoResponse MSG_InfoResponse;
	static tLobbyMsgRW_PackageChar LobbyMsgRW_PackageChar;
	static tdwInstantSendMessage dwInstantSendMessage;
	static tLobbySession_GetControllingLobbySession LobbySession_GetControllingLobbySession;
	static tLobbySession_GetSession LobbySession_GetSession;
	static tLobbySession_GetClientByClientNum LobbySession_GetClientByClientNum;
	static tLobbySession_GetClientNetAdrByIndex LobbySession_GetClientNetAdrByIndex;
	static tLobbyJoin_Reserve LobbyJoin_Reserve;
	static tCL_GetConfigString CL_GetConfigString;
	static tCbuf_AddText Cbuf_AddText;
	static __int64 PrivatePassword[3];
	static bool EnableRWProtection;
	static std::unordered_map<__int64, std::unordered_map<int, __int64>> SteamHAPIHooks;
	static std::unordered_map<BYTE, std::function<void(__int32* lobbyMsgTypePtr, __int64 lobbyMsg)>> handle_packet_callbacks;
	static const char* LOBBYTYPESTRING;
};

#define STEAMVTO(x) (x / 8)

#define STEAMAPI_STEAMUSER_GETUSERNAME STEAMVTO(0)
#define STEAMAPI_STEAMUSER_GETUSERID STEAMVTO(0x10)
#define STEAMAPI_STEAMUSER_GETUSERPROP STEAMVTO(0xE8)
#define STEAMAPI_INTERFACE_IS_VAC_BANNED STEAMVTO(0x18)
#define STEAMAPI_INTERFACE_CHECK_OWNS_CONTENT2 STEAMVTO(0x30)
#define STEAMAPI_INTERFACE_CHECK_OWNS_CONTENT STEAMVTO(0x38)
#define STEAMAPI_INTERFACE_GET_DLC_DOWNLOAD_PROGRESS STEAMVTO(0xB0)
#define STEAMAPI_MATCHMAKING_GETLOBBYCHATENTRY STEAMVTO(0xD8)
#define STEAMAPI_MATCHMAKING_CREATELOBBY STEAMVTO(0x68)

// steamapi, who, inviteArg
#define STEAMAPI_STEAMUSER_SENDINVITE STEAMVTO(0x188)
#define STEAMAPI_STEAMUSER_VT_NAMEBYXUID STEAMVTO(0x38)
#define IHOOK_HEADER(fn_name, fn_return, fn_args) using fn_name ## _fn = fn_return ## (__stdcall*)fn_args; \
fn_name ## _fn o ## fn_name; \
fn_return WINAPI __ ## fn_name fn_args
#define IHOOK_INSTALL(fn_name, module__) o ## fn_name = (fn_name ## _fn)Iat_hook_::detour_iat_ptr(#fn_name, (void*)__ ## fn_name, module__);
#define IHOOK_ORIGINAL(fn_name, fn_args) o ## fn_name fn_args

#define ZBR_PREFIX_BYTE (unsigned char)((Protection::PrivatePassword[1] & 0xFF0000) >> 16)
#define ZBR_PREFIX_BYTE2 (unsigned char)((Protection::PrivatePassword[1] & 0xFF000000) >> 24)