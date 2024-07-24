#include "DiscordRP.h"
#include "Offsets.h"
#include "lua\hapi.h"
#include "lua\lapi.h"
#include "lua\lstate.h"
#include "ds.hpp"
#include <array>
#include "protection.h"
#include "anticheat.h"
#include "arxan_evasion.h"
#include "mh.h"
#include "zbr.h"

#if !IS_PATCH_ONLY
auto ZBR_FIELD_SESSIONID = PACKAGE_FIELD;
char sendLMInfoBuffer[0x20000];
DiscordState DiscordRP::State{};
#endif
bool DiscordRP::_IsAvailable = false;
bool DiscordRP::VEHInstalled = false;
__int64 DiscordRP::OriginalValue;
unsigned __int64 DiscordRP::TickCount;
char DiscordRP::presenceDetailsBuf[256];
char DiscordRP::ActivityID[256];
char DiscordRP::ActivityID_CLIENT[256];
char DiscordRP::XUIDString[64];
__int64 DiscordRP::DiscordPendingJoin = 0;
bool DiscordRP::IsPendingJoin = false;
bool DiscordRP::HasEmblemViolation = false;
#if !IS_PATCH_ONLY
discord::Activity DiscordRP::activity;
#endif
std::unordered_map<unsigned __int32, DelayedCall*> DiscordRP::LocalEvents;

//#define HOOK_DVAR_RCXDEATH OFFSET(0x22BD946)
//#define HOOK_DVAR OFFSET(0x168EFE00)
#define THE_DEVS __int64 DEVS[] = { 857721923247800331, 581180493832126516, 166155268642570240, 736661405440409729, 140948985580879872, 228410908316139520, 137123044752621569, 140927548346335232, /*ZORO*/ 562043107734978566, 487561455122645012 };
#define THE_COMPETITORS __int64 DEVS[] = { 857721923247800331, 581180493832126516, 736661405440409729, 228410908316139520, 166155268642570240, 140948985580879872 };
#define THE_Z4C_CREW __int64 DEVS[] = { 857721923247800331, 259740440444534785, 619259535609298994, 300691604983906306, 314811186707431425, 264868359974289408, 254608348920545281, 299277833312796672, 106280809631092736, 187080110694727681, 342002935972102144, 802047720222359573, 235134116733911041, 216287983706308618, 279624009040265217, 495634987006296074, 322772125536616450, 643709931891195905, 188329269586296832, 564271413352071198, 266762114272591872, 497409255213629460, 290588666055622657, 258638479825698816, 796499186782437386, 374605885219274766, 343189175589273604, 263484767045943297, 329981586202296329, 392765578500243460, 366859225244237824, 414209256859107329, 199279838807326720, 460189660115763202, 391373612059197441, 179747635467386880, 284480352414728192, 627362171319353376, 1034462404886675507, 256120744919040000, 365248655730671616, 978631180989653013, 614959433700605984, 338671204246224907, 402943450787348482, 429404101802065921, 635280239253258240, 220147849868869632, 210159828826456065, 185968875161124864, 353375661815103499, 191714385071177730, 206584650288594945, 479785324621332507, 1200245923402489987, 744248779083087943, 767939773784260628, 1071234455416602674, 480091105078018048, 824353997225328731, 736661405440409729, 581180493832126516, 166155268642570240, 487561455122645012, 140927548346335232, 692012556474122272, 467726542907244545, 456239810323939330, 529414652468264992, 559915252309819392 };
#define THE_Z4C_2024_WINNERS __int64 DEVS[] = { 264868359974289408, 480091105078018048, 342002935972102144, 199279838807326720 };
#define EMBLEM_SLOT_TARGET 3
//do { CONTEXT context = { 0 }; GetThreadContext(GetCurrentThread(), &context); context.Rip = (INT64)&AllocConsole; NT_TIB *tib = (NT_TIB *)NtCurrentTeb(); memset((void*)context.Rsp, 0, context.Rsp - (__int64)tib->StackBase); context.Rax = X; context.Rbp = 0; context.Rbx = 0; context.Rsi = 0; context.Rdi = 0; context.EFlags = 0; SetThreadContext(GetCurrentThread(), &context); __fastfail(X); } while(*(char*)(-1))
#pragma optimize( "", off )
void DiscordRP::do_anticheat_discord()
{
#if !IS_PATCH_ONLY
    do
    {
        PROTECT_LIGHT_START("discord anticheat callbacks");
        ANTICHEAT_CALLBACKS();
        PROTECT_LIGHT_END();

        PROTECT_LIGHT_START("discord anticheat setup");
        
        __int16* IDPtr = (__int16*)(EMBLEM_ID_PTR);
        __int16 IDValue = *IDPtr;
        __int16 protectedDev = 751;
        __int16 protectedInvitational = 752;
        const char* emblemInfo = "emblemSetProfile";
        PROTECT_LIGHT_END();

        if (IDValue == protectedDev) // DEV
        {
            PROTECT_LIGHT_START("is dev check");
            if (!IsAvailable())
            {
                *IDPtr = 750;
                Cbuf_AddText(0, emblemInfo, 0);
                if (HasEmblemViolation)
                {
                    ANTICHEAT_CHECK_FAILED(ANTICHEAT_REASON_BADEMBLEM);
                }
                HasEmblemViolation = true;
                break;
            }

            THE_DEVS;
            __int64 currentUser = State.currentUser.GetId();
            bool allowedEmblem = false;

            PROTECT_LIGHT_END();
            for (int i = 0; i < (sizeof(DEVS) / sizeof(DEVS[0])); i++)
            {
                PROTECT_LIGHT_START("check dev id");
                    if (currentUser == DEVS[i])
                    {
                        allowedEmblem = true;
                    }
                PROTECT_LIGHT_END();
            }

            PROTECT_LIGHT_START("check if allowed to hold dev id");
            if (!allowedEmblem)
            {
                *IDPtr = 750;
                Cbuf_AddText(0, emblemInfo, 0);
                if (HasEmblemViolation)
                {
                    ANTICHEAT_CHECK_FAILED(ANTICHEAT_REASON_BADEMBLEM);
                }
                HasEmblemViolation = true;
                break;
            }
            PROTECT_LIGHT_END();
        }

        if (IDValue == protectedInvitational) // INVITATIONAL
        {
            PROTECT_LIGHT_START("invitational start");
            if (!IsAvailable())
            {
                *IDPtr = 750;
                Cbuf_AddText(0, emblemInfo, 0);
                if (HasEmblemViolation)
                {
                    ANTICHEAT_CHECK_FAILED(ANTICHEAT_REASON_BADEMBLEM);
                }
                HasEmblemViolation = true;
                break;
            }

            THE_COMPETITORS;
            __int64 currentUser = State.currentUser.GetId();
            bool allowedEmblem = false;
            PROTECT_LIGHT_END();
            for (int i = 0; i < (sizeof(DEVS) / sizeof(DEVS[0])); i++)
            {
                PROTECT_LIGHT_START("check devs invitational");
                if (currentUser == DEVS[i])
                {
                    allowedEmblem = true;
                }
                PROTECT_LIGHT_END();
            }

            PROTECT_LIGHT_START("allowed invitationals emblem");
            if (!allowedEmblem)
            {
                *IDPtr = 750;
                Cbuf_AddText(0, emblemInfo, 0);
                if (HasEmblemViolation)
                {
                    ANTICHEAT_CHECK_FAILED(ANTICHEAT_REASON_BADEMBLEM);
                }
                HasEmblemViolation = true;
                break;
            }
            PROTECT_LIGHT_END();
        }
    } while (false);
#endif
}

#pragma optimize( "", on )

MDT_Define_FASTCALL(CL_DrawScreenOffset, CL_DrawScreen_Hook, void, (__int32 cl))
{
    DiscordRP::DiscordRunEvents();
    MDT_ORIGINAL(CL_DrawScreen_Hook, (cl));
}

const char luaPatching[] = "if LobbyVM.patched == nil then\nLobbyVM.patched = true\nLobbyVM.OnDisconnect = function() end\n" "LobbyVM.old_joinablecheck = LobbyVM.JoinableCheck\n\
LobbyVM.JoinableCheck = function(request)\n\
    local result = LobbyVM.old_joinablecheck(request)\n\
    if result ~= Enum.JoinResult.JOIN_RESULT_SUCCESS then\n\
        return result\n\
    end\n\
\n\
    if request.isLocalRequest then\n\
        return result\n\
    end\n\
\n\
    local clientCount = Engine.GetLobbyClientCount( Enum.LobbyType.LOBBY_TYPE_GAME )\n\
    local maxClients = Engine.GetLobbyMaxClients( Enum.LobbyType.LOBBY_TYPE_GAME )\n\
    local maxPlayers = Dvar.party_maxplayers:get()\n\
\n\
    if clientCount == nil then \n\
        clientCount = 1\n\
    end\n\
\n\
    if maxPlayers == nil then \n\
        maxPlayers = maxClients \n\
    end\n\
\n\
    local availableSlots = maxClients - clientCount\n\
\n\
    if availableSlots > (maxPlayers - clientCount) then \n\
        availableSlots = maxPlayers - clientCount\n\
    end\n\
\n\
    if availableSlots <= 0 then\n\
        return Enum.JoinResult.JOIN_RESULT_JOIN_DISABLED\n\
    end\n\
\n\
    local privacy = Engine.GetPartyPrivacy()\n\
    if privacy == Enum.PartyPrivacy.PARTY_PRIVACY_CLOSED then\n\
        return Enum.JoinResult.JOIN_RESULT_NOT_JOINABLE_CLOSED\n\
    end\n\
\n\
    if privacy == Enum.PartyPrivacy.PARTY_PRIVACY_FRIENDS_ONLY then\n\
        local xuid = request.fromXuid\n\
        if xuid == nil then return Enum.JoinResult.JOIN_RESULT_JOIN_DISABLED end\n\
        if Engine.IsFriendFromXUID( Engine.GetPrimaryController(), xuid ) ~= true then\n\
            return Enum.JoinResult.JOIN_RESULT_NOT_JOINABLE_FRIENDS_ONLY\n\
        end\n\
    end\n\
\n\
    return result\n\
end\nend";
#if IS_PATCH_ONLY
int PatchDisconnectExploit()
{
    if (!(*(__int8*)REBASE(0x162E2410) & 1))
    {
        return 0;
    }

    lua_State* lobbyVM = *(lua_State**)REBASE(0x157588D0);

    if (!lobbyVM)
    {
        return 0;
    }

    const char* sourceData = luaPatching;
    *(char*)(*(INT64*)((INT64)lobbyVM + 16) + 472) = HKS_BYTECODE_SHARING_ON;
    HksCompilerSettings hks_compiler_settings;
    int result = hksi_hksL_loadbuffer(lobbyVM, &hks_compiler_settings, sourceData, strlen(sourceData), sourceData);
    if (!result)
    {
        result = hks::vm_call_internal(lobbyVM, 0, 0, 0);
    }

    *(char*)(*(INT64*)((INT64)lobbyVM + 16) + 472) = HKS_BYTECODE_SHARING_SECURE;

    return 1;
}
#endif

int DiscordRP::AffinityStage = 0;
ULONG_PTR DiscordRP::ProcessAffinity = 0;
ULONG_PTR DiscordRP::SystemAffinity = 0;
bool has_set_window_text = false;
LONG WINAPI DiscordRP::DiscordRunEvents()
{
    DispatchFrame();

#if IS_PATCH_ONLY
    SetDelay(10000, 11, []()
    {
        PatchDisconnectExploit();
    });
#endif

    if (IsAvailable())
    {
#if !IS_PATCH_ONLY
        SetDelay(50, 0, []()
        {
            if (!IsAvailable())
            {
                return;
            }
            State.core->RunCallbacks();

            if (IsPendingJoin)
            {
                IsPendingJoin = false;
                DiscordRP::LobbyVM_JoinEvent(0, DiscordPendingJoin, 0);
            }
        });
#endif
    }

    if (AffinityStage < 2)
    {
        SetDelay(1000, 5, []()
            {
                switch (AffinityStage)
                {
                    case 0:
                    {
                        
                        ALOG("Attempting to set affinity state...");
                        if (!GetProcessAffinityMask(GetCurrentProcess(), &ProcessAffinity, &SystemAffinity))
                        {
                            ALOG("Unable to get affinity state");
                            break;
                        }

                        if (!ProcessAffinity)
                        {
                            ALOG("Unable to get affinity state (1)");
                            break;
                        }

                        ULONG_PTR affinity = ProcessAffinity & (1 | 2 | 4 | 8);

                        if (!affinity)
                        {
                            break;
                        }

                        if (!SetProcessAffinityMask(GetCurrentProcess(), affinity))
                        {
                            ALOG("Unable to set affinity state");
                            break;
                        }

                        ALOG("Processor affinity set!");
                        AffinityStage++;
                    }
                    break;
                    case 1:
                    {
                        if (!SetProcessAffinityMask(GetCurrentProcess(), ProcessAffinity))
                        {
                            ALOG("Processor affinity failed to reset");
                            break;
                        }

                        ALOG("Processor affinity reset!");
                        AffinityStage++;
                    }
                    break;
                }
            });
    }
#ifndef NO_NAME
    SetDelay(250, 1, []()
    {
        if (!has_set_window_text)
        {
            SetWindowText((HWND) * (__int64*)BO3_HWND, ZBR_WINDOW_TEXT);
            has_set_window_text = true;
        }
        
        if (IsAvailable())
        {
#if !IS_PATCH_ONLY
            const char* username = State.currentUser.GetUsername();
            if (username && *username && (!strcmp(Protection::CustomName, DEFAULT_PLAYERNAME) || !*Protection::CustomName))
            {
                int i = 0;
                for (; i < sizeof(Protection::CustomName) - 1; i++)
                {
                    char c = *(username + i);
                    if (!c)
                    {
                        break;
                    }
                    if (c < 32 || c > 126 || c == '^' || c == '%')
                    {
                        c = '.';
                    }
                    *(Protection::CustomName + i) = c;
                }
                *(Protection::CustomName + i) = 0;
            }
#endif
        }

        // memcpy((void*)OFFSET(0x15E86638), Protection::CustomName, strlen(Protection::CustomName) + 1);
        memcpy((void*)PTR_Name1, Protection::CustomName, strlen(Protection::CustomName) + 1);
        // memcpy((void*)PTR_Name2, Protection::CustomName, strlen(Protection::CustomName) + 1);
        if (!Offsets::IsBadReadPtr((VOID*)s_playerData_ptr) && *(INT64*)s_playerData_ptr)
        {
            memset((void*)(*(INT64*)s_playerData_ptr + 0x8), 0, CUSTOM_NAME_SIZE);
            memcpy((void*)(*(INT64*)s_playerData_ptr + 0x8), Protection::CustomName, strlen(Protection::CustomName) + 1);
        }

        for (auto it = Offsets::CustomNameLocations.begin(); it != Offsets::CustomNameLocations.end(); it++)
        {
            memset((void*)*it, 0, CUSTOM_NAME_SIZE);
            memcpy((void*)*it, Protection::CustomName, strlen(Protection::CustomName) + 1);
        }

    });
#endif
#if !IS_PATCH_ONLY
    SetDelay(15000, 2, do_anticheat_discord);
#endif
    /*SetDelay(5000, 6, []() {
        SetPriorityClass(GetCurrentProcess(), HIGH_PRIORITY_CLASS);
        });*/

    return 0;
}

DiscordRP::tLobbyVM_JoinEvent DiscordRP::LobbyVM_JoinEvent;
DiscordRP::tDDL_MoveToName DiscordRP::DDL_MoveToName;
DiscordRP::tDDL_MoveToIndex DiscordRP::DDL_MoveToIndex;
DiscordRP::tDDL_GetInt DiscordRP::DDL_GetInt;
DiscordRP::tSetCombatRecordID DiscordRP::SetCombatRecordID;
DiscordRP::tCbuf_AddText DiscordRP::Cbuf_AddText;
void DiscordRP::Initialize()
{
    if (DiscordRP::_IsAvailable)
    {
        return;
    }

    if (!DiscordRP::VEHInstalled)
    {
        arxan_evasion::initialize();
        arxan_evasion::register_hook(
            []()
            {
                PROTECT_LIGHT_START("deedeedoodoo");
                DetourTransactionBegin();
                DetourUpdateThread(GetCurrentThread());

                MDT_Activate(CL_DrawScreen_Hook);

                DetourTransactionCommit();
                PROTECT_LIGHT_END();
            },
            []()
            {
                PROTECT_LIGHT_START("googoogaagaa");
                DetourTransactionBegin();
                DetourUpdateThread(GetCurrentThread());

                MDT_Deactivate(CL_DrawScreen_Hook);

                DetourTransactionCommit();
                PROTECT_LIGHT_END();
            }, true);

        TickCount = GetTickCount64();
        DiscordRP::VEHInstalled = true;
        XLOG("VEH installed");
    }
   

    PROTECT_HEAVY_START("init discord function pointers");
    DiscordRP::LobbyVM_JoinEvent = (DiscordRP::tLobbyVM_JoinEvent)(PTR_LobbyVMJoinEvent);
    DiscordRP::DDL_MoveToName = (DiscordRP::tDDL_MoveToName)(PTR_DDL_MoveToName);
    DiscordRP::DDL_MoveToIndex = (DiscordRP::tDDL_MoveToIndex)(PTR_DDL_MoveToIndex);
    DiscordRP::DDL_GetInt = (DiscordRP::tDDL_GetInt)(PTR_DDL_GetInt);
    DiscordRP::SetCombatRecordID = (DiscordRP::tSetCombatRecordID)(PTR_DDL_SetCombatRecordID);
    DiscordRP::Cbuf_AddText = (DiscordRP::tCbuf_AddText)(PTR_Cbuf_AddText);
    PROTECT_HEAVY_END();

    DiscordRP::_IsAvailable = false;
#if !IS_PATCH_ONLY
    discord::Core* core{};
    auto result = discord::Core::Create(DISCORD_CLIENT_ID, DiscordCreateFlags_NoRequireDiscord, &core);
    State.core.reset(core);
    if (!State.core)
    {
        ALOG("Failed to initialize discord! %d", result);
        return;
    }

    XLOG("Discord Initialized.");

    // State.core->ActivityManager().RegisterSteam(311210);
    State.core->ActivityManager().RegisterCommand("steam://run/311210//+set fs_game " WORKSHOP_ID);

    DiscordRP::_IsAvailable = true;

    memset(DiscordRP::ActivityID, 0, sizeof(DiscordRP::ActivityID));
    sprintf_s(DiscordRP::ActivityID, "%p", time(0) ^ State.currentUser.GetId());

    memset(DiscordRP::XUIDString, 0, sizeof(DiscordRP::XUIDString));
    sprintf_s(DiscordRP::XUIDString, "%I64u", Offsets::GetXUID());

    SetPresence("In a Party", "Pregame Lobby", 1, 4);

    XLOG("Presence set.");

    core->UserManager().OnCurrentUserUpdate.Connect([]() 
    {
        State.core->UserManager().GetCurrentUser(&State.currentUser);
    });

    State.core->ActivityManager().OnActivityJoin.Connect(
        [](const char* secret)
        { 
            DiscordPendingJoin = stoull(secret);
            IsPendingJoin = true;
        }
    );
#endif
}

void DiscordRP::DispatchFrame()
{
    Offsets::RunFrame();

    TickCount = GetTickCount64();
    std::list<unsigned __int32> DispatchedEvents;

    for (auto it = LocalEvents.begin(); it != LocalEvents.end(); it++)
    {
        if (it->second->ExecuteTime > TickCount)
            continue;

        DispatchedEvents.push_back(it->first);
        it->second->Lambda();
    }

    for (auto& i : DispatchedEvents)
    {
        delete LocalEvents.find(i)->second;
        LocalEvents.erase(i);
    }
}

void DiscordRP::SetDelay(unsigned __int32 DelayMS, unsigned __int32 EventID, std::function<void()> lambda)
{
    if (LocalEvents.count(EventID))
        return; // cannot set an event twice

    DelayedCall* NewCallRegistry = new DelayedCall(lambda);
    NewCallRegistry->EventID = EventID;
    NewCallRegistry->ExecuteTime = TickCount + DelayMS;
    LocalEvents.emplace(EventID, NewCallRegistry);
}

bool DiscordRP::AmIHost()
{
    LobbyType sessionType = LobbyType::LOBBY_TYPE_AUTO;

    if (Protection::LobbySession_GetControllingLobbySession(LOBBY_MODULE_CLIENT))
    {
        sessionType = LOBBY_TYPE_GAME;
    }
    else
    {
        sessionType = LOBBY_TYPE_PRIVATE;
    }

    const auto session = Protection::LobbySession_GetSession(sessionType);
    INT64 sessPtr = (INT64)session;

    return *(INT64*)(sessPtr + 0x60) == Offsets::GetXUID();
}

void DiscordRP::BeginActivity()
{
#if !IS_PATCH_ONLY
    if (!IsAvailable())
    {
        return;
    }
    activity.GetTimestamps().SetStart(time(NULL));
    State.core->ActivityManager().UpdateActivity(activity, [](discord::Result result) {});
#endif
}

__int32 DiscordRP::RepLobbystateReal(unsigned char no_reply)
{
#if !IS_PATCH_ONLY
    if (!DiscordRP::AmIHost())
    {
        return 1;
    }

    LobbyType sessionType = LobbyType::LOBBY_TYPE_AUTO;

    if (Protection::LobbySession_GetControllingLobbySession(LOBBY_MODULE_CLIENT))
    {
        sessionType = LOBBY_TYPE_GAME;
    }
    else
    {
        sessionType = LOBBY_TYPE_PRIVATE;
    }

    const auto session = Protection::LobbySession_GetSession(sessionType);
    __int64 xuid = 0;

    zbr::lobbystate.whoami = 0;

    for (int i = 0; i < 18; i++)
    {
        const auto client = Protection::LobbySession_GetClientByClientNum(session, i);
        if (client->activeClient)
        {
            const auto adr = Protection::LobbySession_GetClientNetAdrByIndex(sessionType, i);

            if (client->activeClient->fixedClientInfo.xuid == Offsets::GetXUID())
            {
                continue;
            }

            LobbyMsg lobbyMsg{ 0 };
            memset(sendLMInfoBuffer, 0, sizeof(sendLMInfoBuffer));

            //  send the info update to the player
            if (Protection::LobbyMsgRW_PrepWriteMsg(&lobbyMsg, sendLMInfoBuffer, sizeof(sendLMInfoBuffer), MESSAGE_TYPE_ZBR_LOBBYSTATE) && zbr::package_lobbystate(&lobbyMsg, no_reply, i))
            {
                Protection::LobbyMsgTransport_SendToAdr(0, NETCHAN_LOBBYPRIVATE_UNRELIABLE, LOBBY_MODULE_CLIENT, adr, client->activeClient->fixedClientInfo.xuid, &lobbyMsg.msg, (MsgType)MESSAGE_TYPE_ZBR_LOBBYSTATE);
            }
        }
    }

    zbr::lobbystate.whoami = 0;
#endif
    return 1;
}

void DiscordRP::ReplicateEmoteRequest(unsigned int who, int what)
{
#if !IS_PATCH_ONLY
    if (!DiscordRP::AmIHost())
    {
        return;
    }

    LobbyType sessionType = LobbyType::LOBBY_TYPE_AUTO;

    if (Protection::LobbySession_GetControllingLobbySession(LOBBY_MODULE_CLIENT))
    {
        sessionType = LOBBY_TYPE_GAME;
    }
    else
    {
        sessionType = LOBBY_TYPE_PRIVATE;
    }

    const auto session = Protection::LobbySession_GetSession(sessionType);
    __int64 xuid = 0;

    zbr::lobbystate.whoami = 0;

    for (int i = 0; i < 18; i++)
    {
        const auto client = Protection::LobbySession_GetClientByClientNum(session, i);
        if (client->activeClient)
        {
            const auto adr = Protection::LobbySession_GetClientNetAdrByIndex(sessionType, i);

            if (client->activeClient->fixedClientInfo.xuid == Offsets::GetXUID())
            {
                continue;
            }

            LobbyMsg lobbyMsg{ 0 };
            memset(sendLMInfoBuffer, 0, sizeof(sendLMInfoBuffer));

            //  send the info update to the player
            if (Protection::LobbyMsgRW_PrepWriteMsg(&lobbyMsg, sendLMInfoBuffer, sizeof(sendLMInfoBuffer), MESSAGE_TYPE_ZBR_CHARACTERRPC) && zbr::package_clientemoterpc(&lobbyMsg, what, who))
            {
                Protection::LobbyMsgTransport_SendToAdr(0, NETCHAN_LOBBYPRIVATE_UNRELIABLE, LOBBY_MODULE_CLIENT, adr, client->activeClient->fixedClientInfo.xuid, &lobbyMsg.msg, (MsgType)MESSAGE_TYPE_ZBR_CHARACTERRPC);
            }
        }
    }

    zbr::lobbystate.whoami = 0;
#endif
}

__int32 DiscordRP::RepLobbystate(void*)
{
#if !IS_PATCH_ONLY
    return DiscordRP::RepLobbystateReal(false);
#endif
    return 1;
}

bool DiscordRP::IsAvailable()
{
#if !IS_PATCH_ONLY
    return DiscordRP::_IsAvailable && State.core;
#else
    return false;
#endif
}

const char* DiscordRP::GetActivityID()
{
    return AmIHost() ? DiscordRP::ActivityID : DiscordRP::ActivityID_CLIENT;
}

void DiscordRP::SetPresence(const char* state, const char* details, int partyCount, int partyMax)
{
#if !IS_PATCH_ONLY
    if (!IsAvailable())
    {
        return;
    }

    activity.SetDetails(details);
    activity.GetParty().GetSize().SetCurrentSize(partyCount);
    activity.GetParty().GetSize().SetMaxSize(partyMax);
    activity.GetParty().SetId(GetActivityID());
    activity.SetState(state);
    activity.GetSecrets().SetJoin(DiscordRP::XUIDString);
    activity.GetAssets().SetSmallImage("zbr2");
    activity.GetAssets().SetSmallText("ZBR");
    activity.GetAssets().SetLargeImage("zbr2");
    activity.GetAssets().SetLargeText("Zombie Blood Rush");
    activity.SetType(discord::ActivityType::Playing);
    State.core->ActivityManager().UpdateActivity(activity, [](discord::Result result) {});
#endif
}

#pragma optimize( "", off )
__int32 DiscordRP::AmIADeveloper(void* luaState)
{
#if !IS_PATCH_ONLY
    PROTECT_LIGHT_START("check if dev for lua");
    lua_State* s = (lua_State*)luaState;
    if (!IsAvailable())
    {
        lua_pushboolean(s, false);
        return 1;
    }

    THE_DEVS
    __int64 currentUser = State.currentUser.GetId();

    for (int i = 0; i < (sizeof(DEVS) / sizeof(DEVS[0])); i++)
    {
        if (currentUser == DEVS[i])
        {
            lua_pushboolean(s, true);
            return 1;
        }
    }

    lua_pushboolean(s, false);
    return 1;
    PROTECT_LIGHT_END();
#else
    return false;
#endif
}

__int32 DiscordRP::AmIAZ4CPlayer(void* luaState)
{
#if !IS_PATCH_ONLY
    PROTECT_LIGHT_START("check if player for lua");
    lua_State* s = (lua_State*)luaState;

    if (ZBR_IS_Z4C_BUILD)
    {
        lua_pushboolean(s, true);
        return 1;
    }
    
    if (!IsAvailable())
    {
        lua_pushboolean(s, false);
        return 1;
    }

    THE_Z4C_CREW
    __int64 currentUser = State.currentUser.GetId();

    for (int i = 0; i < (sizeof(DEVS) / sizeof(DEVS[0])); i++)
    {
        if (currentUser == DEVS[i])
        {
            lua_pushboolean(s, true);
            return 1;
        }
    }

    lua_pushboolean(s, false);
    return 1;
    PROTECT_LIGHT_END();
#else
    return false;
#endif
}

__int32 DiscordRP::AmIAZ4CWinner(void* luaState)
{
#if !IS_PATCH_ONLY
    PROTECT_LIGHT_START("check if player for lua");
    lua_State* s = (lua_State*)luaState;

    if (!IsAvailable())
    {
        lua_pushboolean(s, false);
        return 1;
    }

    THE_Z4C_2024_WINNERS
    __int64 currentUser = State.currentUser.GetId();

    for (int i = 0; i < (sizeof(DEVS) / sizeof(DEVS[0])); i++)
    {
        if (currentUser == DEVS[i])
        {
            lua_pushboolean(s, true);
            return 1;
        }
    }

    lua_pushboolean(s, false);
    return 1;
    PROTECT_LIGHT_END();
#else
    return false;
#endif
}

__int32 DiscordRP::AmIA2021Competitor(void* luaState)
{
#if !IS_PATCH_ONLY
    PROTECT_LIGHT_START("check if competitior for lua");
    lua_State* s = (lua_State*)luaState;
    if (!IsAvailable())
    {
        lua_pushboolean(s, false);
        return 1;
    }

    THE_COMPETITORS;
    __int64 currentUser = State.currentUser.GetId();

    for (int i = 0; i < (sizeof(DEVS) / sizeof(DEVS[0])); i++)
    {
        if (currentUser == DEVS[i])
        {
            lua_pushboolean(s, true);
            return 1;
        }
    }

    lua_pushboolean(s, false);
    return 1;
    PROTECT_LIGHT_END();
#else
    return false;
#endif
}
#pragma optimize( "", on )

__int32 DiscordRP::SetDiscordPresenceLua(void* luaState)
{
#if !IS_PATCH_ONLY
    if (!IsAvailable())
    {
        return 1;
    }

    lua_State* s = (lua_State*)luaState;
    const char* state = lua_tostring(s, -4);
    const char* details = lua_tostring(s, -3);
    float numCurrent = lua_tonumber(s, -2);
    float numMax = lua_tonumber(s, -1);

    if (state && details)
    {
        memset(DiscordRP::presenceDetailsBuf, 0, sizeof(DiscordRP::presenceDetailsBuf));
        
        if (*details == 0x15)
        {
            strcpy_s(DiscordRP::presenceDetailsBuf, 255, details + 1);
            DiscordRP::presenceDetailsBuf[strlen(DiscordRP::presenceDetailsBuf) - 1] = (char)0;
        }
        else
        {
            strcpy_s(DiscordRP::presenceDetailsBuf, 255, details);
        }

        SetPresence(state, DiscordRP::presenceDetailsBuf, (int)numCurrent, (int)numMax);
    }
#endif
    return 1;
}

__int32 DiscordRP::RepSessionIDToClientsLua(void* luaState)
{
#if !IS_PATCH_ONLY
    if (!IsAvailable())
    {
        return 1;
    }

    if (!AmIHost())
    {
        return 1;
    }

    lua_State* s = (lua_State*)luaState;

    LobbyType sessionType = LobbyType::LOBBY_TYPE_AUTO;

    if (Protection::LobbySession_GetControllingLobbySession(LOBBY_MODULE_CLIENT))
    {
        sessionType = LOBBY_TYPE_GAME;
    }
    else
    {
        sessionType = LOBBY_TYPE_PRIVATE;
    }
    const auto session = Protection::LobbySession_GetSession(sessionType);
    __int64 xuid = 0;

    for (int i = 0; i < 18; i++)
    {
        const auto client = Protection::LobbySession_GetClientByClientNum(session, i);
        if (client->activeClient)
        {
            const auto adr = Protection::LobbySession_GetClientNetAdrByIndex(sessionType, i);
            
            if (client->activeClient->fixedClientInfo.xuid == Offsets::GetXUID())
            {
                continue;
            }

            LobbyMsg lobbyMsg {0};
            memset(sendLMInfoBuffer, 0, sizeof(sendLMInfoBuffer));

            //  send the info update to the player
            if (Protection::LobbyMsgRW_PrepWriteMsg(&lobbyMsg, sendLMInfoBuffer, sizeof(sendLMInfoBuffer), MESSAGE_TYPE_ZBR_LOBBYINFO_RESPONSE))
            {
                Protection::LobbyMsgRW_PackageString(&lobbyMsg, ZBR_FIELD_SESSIONID, DiscordRP::ActivityID, 256);
                Protection::LobbyMsgTransport_SendToAdr(0, NETCHAN_LOBBYPRIVATE_UNRELIABLE, LOBBY_MODULE_CLIENT, adr, client->activeClient->fixedClientInfo.xuid, &lobbyMsg.msg, (MsgType)MESSAGE_TYPE_ZBR_LOBBYINFO_RESPONSE);
            }
        }
    }
#endif
    return 1;
}

__int32 DiscordRP::JoinGSCDevLua(void* luaState)
{
#if !IS_PATCH_ONLY
    if (!IsAvailable())
    {
        return 1;
    }
    State.core->OverlayManager().OpenGuildInvite("ce53WMvQbv", [](discord::Result result) {});
#endif
    return 1;
}

__int32 DiscordRP::OpenInvitePlayersLua(void* luaState)
{
#if !IS_PATCH_ONLY
    if (!IsAvailable())
    {
        return 1;
    }
    State.core->OverlayManager().OpenActivityInvite(discord::ActivityActionType::Join, [](discord::Result result) {});
#endif
    return 1;
}

__int32 DiscordRP::IsDiscordRPCActiveLua(void* luaState)
{
    lua_State* s = (lua_State*)luaState;
    lua_pushboolean(s, IsAvailable());
    return 1;
}

__int32 DiscordRP::MarkBeginSessionLua(void* luaState)
{
#if !IS_PATCH_ONLY
    if (!IsAvailable())
    {
        return 1;
    }

    BeginActivity();
#endif
    return 1;
}

void DiscordRP::HandleUpdateActivity(void* lm)
{
#if !IS_PATCH_ONLY
    if (!IsAvailable())
    {
        return;
    }

    LobbyMsg* lobbyMsg = (LobbyMsg*)lm;
    if (Protection::LobbyMsgRW_PackageString(lobbyMsg, ZBR_FIELD_SESSIONID, DiscordRP::ActivityID_CLIENT, 256))
    {
        SetPresence(activity.GetState(), activity.GetDetails(), activity.GetParty().GetSize().GetCurrentSize(), activity.GetParty().GetSize().GetMaxSize());
    }
#endif
}

__int32 DiscordRP::IsZBRDuos(void* luaState)
{
#if !IS_PATCH_ONLY
    lua_pushboolean((lua_State*)luaState, zbr::is_duos());
#endif
    return 1;
}
