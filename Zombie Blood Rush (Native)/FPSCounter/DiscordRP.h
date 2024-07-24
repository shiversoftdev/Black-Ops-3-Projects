#pragma once
#include "framework.h"
#include <functional>
#if !IS_PATCH_ONLY
#include "discord/discord.h"
#endif
#include <unordered_map>

#define DISCORD_CLIENT_ID 954018994657050664
#if !IS_PATCH_ONLY
struct DiscordState 
{
    discord::User currentUser;

    std::unique_ptr<discord::Core> core;
};
#endif

struct DelayedCall
{
public:
    std::function<void(void)> Lambda;
    unsigned __int64 ExecuteTime;
    unsigned __int32 EventID;

    DelayedCall(std::function<void(void)> func) : Lambda(func)
    {

    }
};

static class DiscordRP
{
public:
    static void Initialize();
    static bool IsAvailable();
    static void SetPresence(const char* state, const char* details, int partyCount, int partyMax);
    static __int32 AmIADeveloper(void* luaState);
    static __int32 AmIAZ4CPlayer(void* luaState);
    static __int32 AmIAZ4CWinner(void* luaState);
    static __int32 IsZBRDuos(void* luaState);
    static __int32 AmIA2021Competitor(void* luaState);
    static __int32 SetDiscordPresenceLua(void* luaState);
    static __int32 RepSessionIDToClientsLua(void* luaState);
    static __int32 RepLobbystate(void* luaState);
    static __int32 RepLobbystateReal(unsigned char no_reply);
    static void ReplicateEmoteRequest(unsigned int who, int what);
    static void HandleUpdateActivity(void* lm);
    static const char* GetActivityID();
#if !IS_PATCH_ONLY
    static discord::Activity activity;
#endif
    static bool AmIHost();
    static void BeginActivity();
    static __int32 MarkBeginSessionLua(void* luaState);
    static __int32 JoinGSCDevLua(void* luaState);
    static __int32 IsDiscordRPCActiveLua(void* luaState);
    static __int32 OpenInvitePlayersLua(void* luaState);
    static void do_anticheat_discord();
    static LONG WINAPI DiscordRunEvents();
private:
    static void DispatchFrame();
    static void SetDelay(unsigned __int32 DelayMS, unsigned __int32 EventID, std::function<void()> lambda);
    static unsigned __int64 TickCount;
#if !IS_PATCH_ONLY
    static DiscordState State;
#endif
    static __int64 OriginalValue;
    static std::unordered_map<unsigned __int32, DelayedCall*> LocalEvents;
    static bool _IsAvailable;
    static bool VEHInstalled;
    static char ActivityID[256];
    static char ActivityID_CLIENT[256];
    static char XUIDString[64];
    static __int64 DiscordPendingJoin;
    static bool IsPendingJoin;
    static bool HasEmblemViolation;
    static char presenceDetailsBuf[256];
    typedef void(__fastcall* tLobbyVM_JoinEvent)(int localClientNum, __int64 xuid, int joinType);
    static tLobbyVM_JoinEvent LobbyVM_JoinEvent;
    typedef bool(__fastcall* tDDL_MoveToName)(void* fromState, void* toState, const char* nameValue);
    static tDDL_MoveToName DDL_MoveToName;
    typedef bool(__fastcall* tDDL_MoveToIndex)(void* fromState, void* toState, int nameIndex);
    static tDDL_MoveToIndex DDL_MoveToIndex;
    typedef bool(__fastcall* tDDL_GetInt)(void* fromState, void* fromContext);
    static tDDL_GetInt DDL_GetInt;
    typedef bool(__fastcall* tSetCombatRecordID)(int controllerIndex, unsigned __int64 backgroundID, int backgroundIndex);
    static tSetCombatRecordID SetCombatRecordID;
    typedef bool(__fastcall* tCbuf_AddText)(int controllerIndex, const char* input, int alwaysZero);
    static tCbuf_AddText Cbuf_AddText;
    static int AffinityStage;
    static ULONG_PTR ProcessAffinity;
    static ULONG_PTR SystemAffinity;
};