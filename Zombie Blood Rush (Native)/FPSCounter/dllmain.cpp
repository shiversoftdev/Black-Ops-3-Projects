#pragma comment(lib, "ntdll")
#include "Offsets.h"
#include "builtins.h"
#include "detours.h"
#include "Opcodes.h"
#include <Windows.h>
#include <stdio.h>
#include "ds.hpp"
#include <unordered_map>
#include <string>
#include "crc32.h"
#include "shellapi.h"
#include "vmrt.h"
#include "mh.h"
#include "DiscordRP.h"
#include "lua\hapi.h"
#include "lua\lapi.h"
#include "lua\lstate.h"
#include "protection.h"
#include "arxan_evasion.h"
#include "dll_resources/msdetours.h"
#include "resource.h"
#include "anticheat.h"
#include "asset_protection.h"
#include "lua\lstate.h"
#include <sstream>
#include "gscu_hashing.h"
#include "zbr.h"
#include "callspoof.h"
#include <intrin.h>

#pragma intrinsic(_ReturnAddress)

#define EXPORT extern "C" __declspec(dllexport)

const char zbr_window_text[] = ZBR_WINDOW_TEXT;
bool quitting = false;

using namespace std;

#if USE_CV > PROTECTION_STRIPPED
STEALTH_AUX_FUNCTION
void StealthCB()
{
    STEALTH_AREA_START
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
        STEALTH_AREA_CHUNK
    STEALTH_AREA_END
}
#endif

void chgmem(__int64 addy, __int32 size, void* copy)
{
    DWORD oldprotect;
    VirtualProtect((void*)addy, size, PAGE_EXECUTE_READWRITE, &oldprotect);
    memcpy((void*)addy, copy, size);
    VirtualProtect((void*)addy, size, oldprotect, &oldprotect);
}

typedef LONG(NTAPI* NtSuspendProcess)(IN HANDLE ProcessHandle);
void SuspendProcess()
{
    HANDLE processHandle = OpenProcess(PROCESS_ALL_ACCESS, FALSE, GetCurrentProcessId());

    NtSuspendProcess pfnNtSuspendProcess = (NtSuspendProcess)GetProcAddress(
        GetModuleHandle("ntdll"), "NtSuspendProcess");

    pfnNtSuspendProcess(processHandle);
    CloseHandle(processHandle);
}

void RunGSIParser()
{
#if !IS_PATCH_ONLY
    for (int i = 0; i < BUFFER_SIZE; i++) SCRIPT_BUF[i] ^= (BYTE)VM_XOR_KEY;

    if (*(INT32*)SCRIPT_BUF != 0x43495347)
    {
#ifdef USE_NLOG
        ALOG("Bad Script Magic");
#endif
        return;
    }

    Offsets::SCRIPT_BASE = SCRIPT_BUF;
    while (*(INT64*)Offsets::SCRIPT_BASE != 0x1C000A0D43534780)
    {
        Offsets::SCRIPT_BASE += 0x10;
    }

    INT32 numFields = *(INT32*)(SCRIPT_BUF + 4);
    char* gsicPtr = SCRIPT_BUF + 8;
    while (numFields)
    {
        INT32 fieldType = *(INT32*)gsicPtr;
        gsicPtr += 4;
        switch (fieldType)
        {
            case 0:
            {
                INT32 numDetours = *(INT32*)gsicPtr;
                gsicPtr += 4;
                RegisterDetours(gsicPtr, numDetours, (INT64)Offsets::SCRIPT_BASE);
                gsicPtr += numDetours * 256;
                break;
            }
        }
        numFields--;
    }
    XLOG("GSI Parsed");
#endif
}

void Config2v2()
{
    //auto buffer = Offsets::SCRIPT_BASE;
    //auto exportsOffset = *(INT32*)(buffer + 0x20);
    //auto exports = (INT64)(exportsOffset + buffer);
    //auto numExports = *(INT16*)(buffer + 0x3A);
    //__t7export* currentExport = (__t7export*)exports;
    //for (INT16 i = 0; i < numExports; i++, currentExport++)
    //{
    //    if (currentExport->funcName != 0x2e8c6cbb) // zbr_is_teambased
    //    {
    //        continue;
    //    }
    //    *(char*)(Offsets::SCRIPT_BASE + currentExport->bytecodeOffset + 0x4) = !Offsets::is2v2;
    //    return;
    //}
}

typedef void(__fastcall* tDvar_SetFromStringByName)(const char* dvarName, const char* string, bool createIfMissing);
tDvar_SetFromStringByName Dvar_SetFromStringByName = (tDvar_SetFromStringByName)PTR_Dvar_SetFromStringByName;

bool mod_is_loaded = false;

int LoadZBRMod(void* s)
{
#if !IS_PATCH_ONLY
    VMP_EXTRA_LIGHT_START("Load Mod");
    Dvar_SetFromStringByName("zbr_is_workshop", "1", true);
    mod_is_loaded = true;
    ScriptDetours::ResetDetours();
    //if (!VMP_CHECKINTEGRITY())
    //{
    //    anticheat_static::fast_quit_reason = ANTICHEAT_REASON_PATCHED_DLL;
    //}
    Offsets::LoadConfig();
    DiscordRP::RepLobbystate(s);
    VMP_EXTRA_LIGHT_END();
#endif
    return 1;
}

int GetTeamsSize(void* s)
{
#if !IS_PATCH_ONLY
    lua_pushinteger((lua_State*)s, zbr::lobbystate.team_size);
#endif
    return 1;
}

int EnableQuads(void* s)
{
#if !IS_PATCH_ONLY
    Dvar_SetFromStringByName("zbr_teams_enabled", "1", true);
    Dvar_SetFromStringByName("zbr_teams_size", "4", true);
    zbr::lobbystate.team_size = 4;
    DiscordRP::RepLobbystate(s);
#endif
    return 1;
}

int EnableTrios(void* s)
{
#if !IS_PATCH_ONLY
    Dvar_SetFromStringByName("zbr_teams_enabled", "1", true);
    Dvar_SetFromStringByName("zbr_teams_size", "3", true);
    zbr::lobbystate.team_size = 3;
    DiscordRP::RepLobbystate(s);
#endif
    return 1;
}

int EnableDuos(void* s)
{
#if !IS_PATCH_ONLY
    Dvar_SetFromStringByName("zbr_teams_enabled", "1", true);
    Dvar_SetFromStringByName("zbr_teams_size", "2", true);
    zbr::lobbystate.team_size = 2;
    DiscordRP::RepLobbystate(s);
#endif
    return 1;
}

int EnableSolos(void* s)
{
#if !IS_PATCH_ONLY
    Dvar_SetFromStringByName("zbr_teams_enabled", "0", true);
    Dvar_SetFromStringByName("zbr_teams_size", "1", true);
    zbr::lobbystate.team_size = 1;
    DiscordRP::RepLobbystate(s);
#endif
    return 1;
}

#ifdef IS_DEV
EXPORT __int64 GetDevPipe()
{
    return (__int64)Offsets::hReadConsole;
}
EXPORT void NotifyDebuggerAttached(const char* password)
{
    Offsets::is_attached = true;
    asset_protection::unprotect(password);
}
EXPORT void DEV_Abort()
{
    ((void(__fastcall*)())0)();
}
#endif

struct bufferReaderData
{
    __int64 buff;
    __int64 readerSize;
};

int PatchDisconnectExploit(void* s)
{
    VMP_EXTRA_LIGHT_START("Patch disconnect");
    XLOG("Patching disconnect exploit...");
    lua_State* lobbyVM = *(lua_State**)PTR_LobbyVM;

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

    const char* sourceData = luaPatching;
    *(char*)(*(INT64*)((INT64)lobbyVM + 16) + 472) = HKS_BYTECODE_SHARING_ON;
    HksCompilerSettings hks_compiler_settings;
    int result = hksi_hksL_loadbuffer(lobbyVM, &hks_compiler_settings, sourceData, strlen(sourceData), sourceData);
    if (!result)
    {
        result = hks::vm_call_internal(lobbyVM, 0, 0, 0);
    }
    
    *(char*)(*(INT64*)((INT64)lobbyVM + 16) + 472) = HKS_BYTECODE_SHARING_SECURE;

    XLOG("Disconnect exploit patched.");
    VMP_EXTRA_LIGHT_END();
    return 1;
}

int EnableDiscordSDK(void* s)
{
#if !IS_PATCH_ONLY
    PROTECT_LIGHT_START("EnableDiscordSDK");
    XLOG("Enabling discord sdk...");
    DiscordRP::Initialize();

    const luaL_Reg discordSDKLib[] =
    {
        {"SetDiscordPresence", DiscordRP::SetDiscordPresenceLua},
        {"RepSessionIDToClients", DiscordRP::RepSessionIDToClientsLua},
        {"MarkBeginSession", DiscordRP::MarkBeginSessionLua},
        {"JoinGSCDev", DiscordRP::JoinGSCDevLua},
        {"IsDiscordRPCActive", DiscordRP::IsDiscordRPCActiveLua},
        {"OpenInvitePlayers", DiscordRP::OpenInvitePlayersLua},
        {nullptr, nullptr},
    };
    hksI_openlib((lua_State*)s, "DiscordSDKLib", discordSDKLib, 0, 1);
    XLOG("SDK Initialized");
    PROTECT_LIGHT_END();
#endif
    return 1;
}

struct ScriptFunctionStackFrame
{
    INT64 InstructionPointer;
    INT64 StackTop;
    INT32 ThreadID;
    INT32 LocalVarCount;
    INT64 StartStack;
    INT32 b_nested;
    INT32 Pad24;
};

typedef unsigned long long(__fastcall* ZwContinue_t)(PCONTEXT ThreadContext, BOOLEAN RaiseAlert);
ZwContinue_t ZwContinue = reinterpret_cast<ZwContinue_t>(GetProcAddress(GetModuleHandleA("ntdll.dll"), "ZwContinue"));

// 34120A0 &s_codLuaStates

void dump_script_context(FILE *f)
{
    // dump script context

    INT64* fs = (INT64*)SCRVM_FS;

    ALOG("Last Script Error: %s\n", (char*)SCR_VmErrorString);
    fprintf(f, "Last Script Error: %s\n", (char*)SCR_VmErrorString);
    for (int j = 0; j < 2; j++)
    {
        char* name = NULL;

        auto at = fs[4 * j];

        if (at)
        {
            auto _ip = (INT64*)(at & ~0xF);
            while (*_ip != 0x1C000A0D43534780)
            {
                _ip -= 2;
            }

            name = (char*)((char*)_ip + *(INT32*)(0x34 + (char*)_ip));
            ALOG("%s Script Instruction Pointer at : %s + %p\n\n", (j ? "CSC" : "GSC"), name, at - (INT64)_ip);
            fprintf(f, "%s Script Instruction Pointer at : %s + %p\n\n", (j ? "CSC" : "GSC"), name, at - (INT64)_ip);
            auto vm_function_count = *(__int32*)(SCR_VMContext + (0x8A40 * j));

            for (int i = vm_function_count - 1; i >= 0; --i)
            {
                ScriptFunctionStackFrame* stackFrame = (ScriptFunctionStackFrame*)(SCR_VMContext + 0x30 + (40 * i) + (0x8A40 * j));
                auto ip = (INT64*)(stackFrame->InstructionPointer & ~0xF);
                while (*ip != 0x1C000A0D43534780)
                {
                    ip -= 2;
                }

                name = (char*)((char*)ip + *(INT32*)(0x34 + (char*)ip));

                ALOG("[0x%p] %s + 0x%p\n\tLoad Offset: 0x%p\n", ip, name, stackFrame->InstructionPointer - (INT64)ip, ip);
                fprintf(f, "[0x%p] %s + 0x%p\n\tLoad Offset: 0x%p\n", ip, name, stackFrame->InstructionPointer - (INT64)ip, ip);


                fprintf(f, "\tStack Top: 0x%p\n", stackFrame->StackTop);
                fprintf(f, "\tStack Base: 0x%p\n", stackFrame->StartStack);
                fprintf(f, "\tThreadID: 0x%x\n", stackFrame->ThreadID);
                fprintf(f, "\Local Var Count: 0x%x\n\n\n", stackFrame->LocalVarCount);

                ALOG("\tStack Top: 0x%p\n", stackFrame->StackTop);
                ALOG("\tStack Base: 0x%p\n", stackFrame->StartStack);
                ALOG("\tThreadID: 0x%x\n", stackFrame->ThreadID);
                ALOG("\Local Var Count: 0x%x\n\n\n", stackFrame->LocalVarCount);

            }
            fprintf(f, "\n\n\n");        
        }
    }
}

void SetThreadExceptions(PCONTEXT ThreadContext)
{
    //ThreadContext->Dr0 = <free>;
    //ThreadContext->Dr7 |= (1 << 0);

#ifdef IS_DEV
    // ARXAN DO NOT USE
    /*ThreadContext->Dr1 = OFFSET(0x1000);
    ThreadContext->Dr7 |= (1 << 2) | (1 << 20) | (1 << 21);*/
#endif

    ThreadContext->Dr2 = PTR_CL_DispatchConnectionless;
    ThreadContext->Dr7 |= (1 << 4);

    ThreadContext->Dr3 = INSTANT_DISPATCH;
    ThreadContext->Dr7 |= (1 << 6);
}

char* UILocalizeDefaultText = NULL;

struct debug_msg_info
{
    __int64 timeEmitted;
    __int32 numEmitted;
};

std::unordered_map<INT64, CONTEXT> SavedExceptions;
std::unordered_map<DWORD, bool> EncounteredIPs;
std::unordered_map<DWORD, debug_msg_info> PrevErrors;
#define DMSG_COOLDOWN_TICKS 5000
DWORD lck_dumping = NULL;
char error_msg_buff[1024];
const char clientfield_doesnt_exist[] = "Clientfield does not exist";
bool is_unhooking = false;

void report_script_error(__int32 inst, const char* error_msg, INT64* &ip, const char* &name)
{
    // non fatal
    INT64* fs = (INT64*)SCRVM_FS;

    ip = (INT64*)(fs[(int)inst * 4] & ~0xF);
    while (*ip != 0x1C000A0D43534780)
    {
        ip -= 2;
    }

    name = (const char*)((char*)ip + *(INT32*)(0x34 + (char*)ip));

#ifdef IS_DEV
    auto off = fs[inst * 4] - (INT64)ip;
    if (off == 0x5d58)
    {
        if (!strcmp(name, "scripts/zm/_zm.csc"))
        {
            return;
        }
    }

    if (off == 0x2866 || off == 0x286e || off == 0x2870 || off == 0x2c6a || off == 0x2c7c)
    {
        if (!strcmp(name, "scripts/shared/scene_shared.csc"))
        {
            return;
        }
    }

    {
        snprintf(error_msg_buff, 1024, "^1Script Error: ^3%s^7\n\tat: ^5%s^7+^2%x\n^7", error_msg, name, fs[inst * 4] - (INT64)ip);
        auto mshHash = fnv1a(error_msg_buff);

        bool do_emit = true;
        if (PrevErrors.find(mshHash) != PrevErrors.end())
        {
            if ((GetTickCount64() - PrevErrors[mshHash].timeEmitted) < DMSG_COOLDOWN_TICKS)
            {
                do_emit = false;
                PrevErrors[mshHash].timeEmitted = GetTickCount64();
                PrevErrors[mshHash].numEmitted++;
            }
            else
            {
                PrevErrors[mshHash].timeEmitted = GetTickCount64();
                if (PrevErrors[mshHash].numEmitted > 1)
                {
                    ALOG("^3Message repeated %d times:", PrevErrors[mshHash].numEmitted);
                    PrevErrors[mshHash].numEmitted = 1;
                }
            }
        }
        else
        {
            PrevErrors[mshHash] = debug_msg_info();
            PrevErrors[mshHash].numEmitted = 1;
            PrevErrors[mshHash].timeEmitted = GetTickCount64();
        }

        if (do_emit)
        {
            ALOG("%s", error_msg_buff);
        }
    }
#endif
}

void __nullsub()
{
    return;
}

void ExceptHook(PEXCEPTION_RECORD ExceptionRecord, PCONTEXT ContextRecord)
{
#if !IS_PATCH_ONLY
    if (asset_protection::try_recover(ExceptionRecord, ContextRecord))
    {
        ZwContinue(ContextRecord, false);
        return;
    }

    if (quitting)
    {
        __fastfail(0);
        TerminateProcess(GetCurrentProcess(), 0);
    }
#endif

    if (is_unhooking)
    {
        ContextRecord->Dr7 = 0;
        ContextRecord->Rip = ROP_RETN;
        is_unhooking = false;
        ZwContinue(ContextRecord, false);
    }

    Protection::SetThreadExceptions(ContextRecord);
    SetThreadExceptions(ContextRecord);

    arxan_evasion::dispatch_exceptions(ExceptionRecord, ContextRecord);
    Protection::ExceptHook(ExceptionRecord, ContextRecord);

    if ((INT64)ContextRecord->Rcx == 0xFFEEDDCC44332211)
    {
        return;
    }
    
    if (REBASE(0x234B9BD) == (INT64)ExceptionRecord->ExceptionAddress) // killcam anim crash
    {
        ContextRecord->Rax = 0;
        ContextRecord->Rip = REBASE(0x234D14B);
        ZwContinue(ContextRecord, false);
        return;
    }

    if (REBASE(0x464FEF) == (INT64)ExceptionRecord->ExceptionAddress) // CG_ZBarrierAttachWeapon
    {
        ContextRecord->Rax = 0;
        ContextRecord->Rip = REBASE(0x4651A2);
        ZwContinue(ContextRecord, false);
        return;
    }

    if (REBASE(0x15E4B5A) == (INT64)ExceptionRecord->ExceptionAddress) // asmsetanimationrate
    {
        ContextRecord->Rip = REBASE(0x15E4B83);
        ZwContinue(ContextRecord, false);
        return;
    }
    
    if (ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x12EE4CC)) // weird orphaned thread crash
    {
        ContextRecord->Rip = REBASE(0x12EE5C8);
        ZwContinue(ContextRecord, false);
        return;
    }

    if (ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x234210C)) // character index crash
    {
        ContextRecord->Rip = REBASE(0x2342136);
        ZwContinue(ContextRecord, false);
        return;
    }

    if (ExceptionRecord->ExceptionAddress == (PVOID)LuaCrash1)
    {
        ContextRecord->Rip = LuaCrash1Rip; // LOL FUCK THIS GAME :) :)
        ZwContinue(ContextRecord, false);
        return;
    }

    if (ExceptionRecord->ExceptionAddress == (PVOID)LuaCrash2)
    {
        if (!UILocalizeDefaultText)
        {
            UILocalizeDefaultText = (char*)malloc(4);
            strcpy_s(UILocalizeDefaultText, 4, "");
        }
        ContextRecord->Rdx = (INT64)UILocalizeDefaultText; // TREYARCH WHY AM I FIXING YOUR GAME
        ZwContinue(ContextRecord, false);
        return;
    }

    if (ExceptionRecord->ExceptionAddress == (PVOID)LuaCrash3)
    {
        if (!UILocalizeDefaultText)
        {
            UILocalizeDefaultText = (char*)malloc(4);
            strcpy_s(UILocalizeDefaultText, 4, "");
        }
        ContextRecord->Rsi = (INT64)UILocalizeDefaultText; // TREYARCH WHY AM I FIXING YOUR GAME
        ZwContinue(ContextRecord, false);
        return;
    }

    if (ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x228ED56))
    {
        if (!UILocalizeDefaultText)
        {
            UILocalizeDefaultText = (char*)malloc(4);
            strcpy_s(UILocalizeDefaultText, 4, "");
        }
        ContextRecord->Rcx = (INT64)UILocalizeDefaultText;
        ZwContinue(ContextRecord, false);
        return;
    }

    if (ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x1EAAA27))
    {
        ContextRecord->Rip = REBASE(0x1EAABB3);
        ZwContinue(ContextRecord, false);
        return;
    }

    if (ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x1A6C894)) // non-existent clientfield
    {
        ContextRecord->Rip = REBASE(0x1A6C91B);
        ZwContinue(ContextRecord, false);
        return;
    }

    if (ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x133EC1) || (PVOID)REBASE(0x133EEB) == ExceptionRecord->ExceptionAddress) // non-existent clientfield
    {
        ContextRecord->Rip = REBASE(0x133F12);
        ZwContinue(ContextRecord, false);
        return;
    }

    if (ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x133F31)) // non-existent clientfield
    {
        ContextRecord->Rip = REBASE(0x133F42);
        ZwContinue(ContextRecord, false);
        return;
    }
    
    // CSC
    if (ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0xC15B80) || ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0xC15C50) // non-existent clientfield
        || ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0xC18CF5))
    {
        ContextRecord->Rcx = 1;
        ContextRecord->Rdx = (__int64)clientfield_doesnt_exist;
        ContextRecord->R8 = 0;
        ContextRecord->Rip = REBASE(0x12EA430);
        ZwContinue(ContextRecord, false);
        return;
    }

    // GSC
    if (ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x1A6BD1B) || ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x1A6BE2E) // non-existent clientfield
        || ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x1A6BF2E) || ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x1A6BFCD)
        || ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x1A6C246) || ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x1A6C356)
        || ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x1A6C40D) || ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x1A6C697)
        || ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x1A6C894))
    {
        ContextRecord->Rcx = 0;
        ContextRecord->Rdx = (__int64)clientfield_doesnt_exist;
        ContextRecord->R8 = 0;
        ContextRecord->Rip = REBASE(0x12EA430);
        ZwContinue(ContextRecord, false);
        return;
    }

    // some random crash we got on ZNS
    if (ExceptionRecord->ExceptionAddress == (PVOID)REBASE(0x13591D3))
    {
        ContextRecord->Rip = REBASE(0x13591DA);
        ZwContinue(ContextRecord, false);
        return;
    }

    if (ExceptionRecord->ExceptionAddress == (PVOID)SCRVM_Error)
    {
        ContextRecord->Rip += 4;
        ContextRecord->Rsp -= 0x30;

        bool isFatal = *(bool*)(REBASE(0x51A386B) + 35392 * (BYTE)ContextRecord->Rcx);
        INT64 error_msg_ptr = *(INT64*)(REBASE(0x51A3710) + 0x78 * (BYTE)ContextRecord->Rcx);
        const char* error_msg = "unknown";
        if (error_msg_ptr && *(char*)error_msg_ptr)
        {
            error_msg = (char*)error_msg_ptr;
        }

        if (strstr(error_msg, "Invalid opcode"))
        {
            isFatal = true;
        }

        INT64* ip = 0;
        const char* name = 0;
        INT64* fs = (INT64*)SCRVM_FS;
        report_script_error(ContextRecord->Rcx, error_msg, ip, name);

        if (isFatal) // fatal crash, dump vm
        {

#ifdef USE_NLOG
            ALOG("Script Fatal Exception at : %p\n", fs[(int)ContextRecord->Rcx * 4]);
            ALOG("Error Message: %s", error_msg);
#endif
            FILE* f;
            f = fopen(CRASH_LOG_NAME, "a+"); // a+ (create + append)
            if (!f)
            {
                // we cant log??? fuck.
                ExitProcess(-444);
            }

            fprintf(f, "Script Exception Type: %s", (ContextRecord->Rcx ? "Client" : "Server"));
            fprintf(f, "Script Fatal Exception at : %p\n", fs[(int)ContextRecord->Rcx * 4]);
            fprintf(f, "\t at: %s+%x", name, fs[(int)ContextRecord->Rcx * 4] - (INT64)ip);
            fprintf(f, "Error Message: %s\n", error_msg);

            ALOG("Script Exception Type: %s", (ContextRecord->Rcx ? "Client" : "Server"));
            ALOG("Script Fatal Exception at : %p\n", fs[(int)ContextRecord->Rcx * 4]);
            ALOG("\t at: %s+%x", name, fs[(int)ContextRecord->Rcx * 4] - (INT64)ip);
            ALOG("Error Message: %s\n", error_msg);


            // dump script context
            dump_script_context(f);

            std::fflush(f);
            std::fclose(f);
#if !IS_PATCH_ONLY
            MessageBox(NULL, "Unfortunately, a fatal script error has occured in Zombie Blood Rush. The error has been recorded in steamapps/common/Black Ops III/zbr_crashes.log. Feel free to report this to the developer.", "Fatal Script Error", MB_OK);
#else
            MessageBox(NULL, "Unfortunately, a fatal script error has occured in Black Ops III. The error has been recorded in steamapps/common/Black Ops III/crashes.log.", "Fatal Script Error", MB_OK);
#endif
            exit(0);
        }

        exitLbl:
        ZwContinue(ContextRecord, false);
        return;
    }

    /*if ((INT64)ExceptionRecord->ExceptionAddress == OFFSET(0x1EB0350))
    {
        Offsets::CustomNameLocations.insert(ContextRecord->Rcx);
        memset((void*)ContextRecord->Rcx, 0, CUSTOM_NAME_SIZE);
        memcpy((void*)ContextRecord->Rcx, Protection::CustomName, strlen(Protection::CustomName) + 1);
        memcpy((void*)PTR_Name1, Protection::CustomName, strlen(Protection::CustomName) + 1);
        memcpy((void*)PTR_Name2, Protection::CustomName, strlen(Protection::CustomName) + 1);
        if (!Offsets::IsBadReadPtr((VOID*)s_playerData_ptr) && *(INT64*)s_playerData_ptr)
        {
            memset((void*)(*(INT64*)s_playerData_ptr + 0x8), 0, CUSTOM_NAME_SIZE);
            memcpy((void*)(*(INT64*)s_playerData_ptr + 0x8), Protection::CustomName, strlen(Protection::CustomName) + 1);
        }
        ContextRecord->Rip = OFFSET(0x1EB04C1);
        ZwContinue(ContextRecord, false);
        return;
    }*/

    INT64 faultingModule = 0;
    char module_name[MAX_PATH];

#ifdef IS_DEV
    if (ExceptionRecord->ExceptionAddress != (PVOID)SCRVM_Error)
    {
        RtlPcToFileHeader((PVOID)ExceptionRecord->ExceptionAddress, (PVOID*)&faultingModule);
        GetModuleFileNameA((HMODULE)faultingModule, module_name, MAX_PATH);
        ALOG("^8[THREAD %d][%p] Exception: %p, type: %x; module: %s", GetCurrentThreadId(), faultingModule, ExceptionRecord->ExceptionAddress, ExceptionRecord->ExceptionCode, module_name);
    }
#endif

    bool b_fatal = false;
    if ((ExceptionRecord->ExceptionCode == EXCEPTION_ACCESS_VIOLATION) || (ExceptionRecord->ExceptionFlags & EXCEPTION_NONCONTINUABLE)/* || (strstr(module_name, "blackops3.exe") && STATUS_ILLEGAL_INSTRUCTION == ExceptionRecord->ExceptionCode)*/)
    {
        if (lck_dumping)
        {
            INT64 addy = (INT64)ExceptionRecord->ExceptionAddress;
            SavedExceptions[addy] = *ContextRecord;
        }
        else
        {
            lck_dumping = GetCurrentThreadId();

            FILE* f;
            f = fopen(CRASH_LOG_NAME, "a+"); // a+ (create + append)
            if (!f)
            {
#ifdef USE_NLOG
                ALOG("File not opened");
#endif
                // we cant log??? fuck.
                ExitProcess(-444);
            }

            ALOG("Crash log %p\n\n", time(NULL));
            fprintf(f, "Crash log %p\n\n", time(NULL));
            INT64 addy = (INT64)ExceptionRecord->ExceptionAddress;
            SavedExceptions[addy] = *ContextRecord;
            while (SavedExceptions.size())
            {
                auto kvp = *SavedExceptions.begin();
                RtlPcToFileHeader((PVOID)kvp.first, (PVOID*)&faultingModule);
                if (faultingModule)
                {
                    GetModuleFileNameA((HMODULE)faultingModule, module_name, MAX_PATH);
                }
                else
                {
                    strcpy_s(module_name, "<Unknown Module>");
                }

                ALOG("Game: %p\n", (void*)REBASE(0x0));
                fprintf(f, "Game: %p\n", (void*)REBASE(0x0));

                ALOG("Module: %s\n", module_name);
                fprintf(f, "Module: %s\n", module_name);

                ALOG("[%p]Exception at (%p) (RIP:%p) (Rsp:%p) (RBP: %p)\n", faultingModule, kvp.first - faultingModule, kvp.second.Rip, kvp.second.Rsp, kvp.second.Rbp);
                fprintf(f, "[%p]Exception at (%p) (RIP:%p) (Rsp: %p)\n", faultingModule, kvp.first - faultingModule, kvp.second.Rip, kvp.second.Rsp, kvp.second.Rbp);

                ALOG("[%p]Rcx: (%p) Rdx: (%p) R8: (%p) R9: (%p)\n", kvp.first, kvp.second.Rcx, kvp.second.Rdx, kvp.second.R8, kvp.second.R9);
                fprintf(f, "[%p]Rcx: (%p) Rdx: (%p) R8: (%p) R9: (%p)\n", kvp.first, kvp.second.Rcx, kvp.second.Rdx, kvp.second.R8, kvp.second.R9);

                ALOG("[%p]Rax: (%p) Rbx: (%p) Rsi: (%p) Rdi: (%p)\n", kvp.first, kvp.second.Rax, kvp.second.Rbx, kvp.second.Rsi, kvp.second.Rdi);
                fprintf(f, "[%p]Rax: (%p) Rbx: (%p) Rsi: (%p) Rdi: (%p)\n", kvp.first, kvp.second.Rax, kvp.second.Rbx, kvp.second.Rsi, kvp.second.Rdi);

                ALOG("[%p]R10: (%p) R11: (%p) R12: (%p) R13: (%p)\n", kvp.first, kvp.second.R10, kvp.second.R11, kvp.second.R12, kvp.second.R13);
                fprintf(f, "[%p]R10: (%p) R11: (%p) R12: (%p) R13: (%p)\n", kvp.first, kvp.second.R10, kvp.second.R11, kvp.second.R12, kvp.second.R13);

                ALOG("[%p]Rbp: (%p) R14: (%p) R15: (%p) Dr7: (%p)\n", kvp.first, kvp.second.Rbp, kvp.second.R14, kvp.second.R15, kvp.second.Dr7);
                fprintf(f, "[%p]Rbp: (%p) R14: (%p) R15: (%p) Dr7: (%p)\n", kvp.first, kvp.second.Rbp, kvp.second.R14, kvp.second.R15, kvp.second.Dr7);

                ALOG("[%p]Dr0: (%p) Dr1: (%p) Dr2: (%p) Dr3: (%p)\n", kvp.first, kvp.second.Dr0, kvp.second.Dr1, kvp.second.Dr2, kvp.second.Dr3);
                fprintf(f, "[%p]Dr0: (%p) Dr1: (%p) Dr2: (%p) Dr3: (%p)\n", kvp.first, kvp.second.Dr0, kvp.second.Dr1, kvp.second.Dr2, kvp.second.Dr3);
                
                for (int i = 0; i < ((STATUS_ILLEGAL_INSTRUCTION == ExceptionRecord->ExceptionCode) ? 0x1200 : 0x400); i += 0x10)
                {
                    ALOG("[%p] %p %p\n", kvp.second.Rsp + i, *(int64_t*)(kvp.second.Rsp + i), *(int64_t*)(kvp.second.Rsp + i + 8));
                    fprintf(f, "[%p] %p %p\n", kvp.second.Rsp + i, *(int64_t*)(kvp.second.Rsp + i), *(int64_t*)(kvp.second.Rsp + i + 8));
                }
                SavedExceptions.erase(kvp.first);
            }

            // dump script context
            dump_script_context(f);

            std::fflush(f);
            std::fclose(f);
            lck_dumping = NULL;
        }

        if (STATUS_ILLEGAL_INSTRUCTION != ExceptionRecord->ExceptionCode)
        {
            b_fatal = true;
        }
    }

    if (b_fatal)
    {
        if (lck_dumping && lck_dumping != GetCurrentThreadId())
        {
            HANDLE hThread = OpenThread(THREAD_ALL_ACCESS, FALSE, GetCurrentThreadId());
            ContextRecord->Rip = (INT64)SuspendThread;
            ContextRecord->Rcx = (INT64)hThread;
            ZwContinue(ContextRecord, false);
        }
        else
        {
            SuspendProcess();
        }
    }
}

__int64 __fn_ptr_hook = 0;
#define HOOK_SIZE_WINE 0x1B
unsigned __int8 old_data[HOOK_SIZE_WINE];
unsigned __int8 new_data[HOOK_SIZE_WINE] = { 0x48, 0xB8, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x48, 0x89, 0xE2, 0x48, 0x8D, 0x8C, 0x24, 0xF0, 0x04, 0x00, 0x00, 0xFF, 0xD0, 0x90, 0x90, 0x90, 0x90 };
void wine_installhook(void* func, __int64 kiuserexceptiondispatcher)
{
    // We have 0x1A (26 bytes) of space to work with. we need to mov rdx, rsp and lea rcx, [rsp+arg_4E8], then mov rax, call and call rax
    auto begin_write = kiuserexceptiondispatcher + 0xB;

    // grab old asm
    memcpy(old_data, (void*)begin_write, HOOK_SIZE_WINE);

    // prep new_data by inserting pointer to func
    __int64 addy = (__int64)func;
    *(__int64*)(new_data + 2) = addy;

    auto OldProtection = 0ul;
    VirtualProtect(reinterpret_cast<void*>(begin_write), HOOK_SIZE_WINE, PAGE_EXECUTE_READWRITE, &OldProtection);
    memcpy((void*)begin_write, new_data, HOOK_SIZE_WINE);
    VirtualProtect(reinterpret_cast<void*>(begin_write), HOOK_SIZE_WINE, OldProtection, &OldProtection);
}

void wine_uninstallhook(__int64 kiuserexceptiondispatcher)
{
    auto begin_write = kiuserexceptiondispatcher + 0xB;

    auto OldProtection = 0ul;
    VirtualProtect(reinterpret_cast<void*>(begin_write), HOOK_SIZE_WINE, PAGE_EXECUTE_READWRITE, &OldProtection);
    memcpy((void*)begin_write, old_data, HOOK_SIZE_WINE);
    VirtualProtect(reinterpret_cast<void*>(begin_write), HOOK_SIZE_WINE, OldProtection, &OldProtection);
}

void old_windows_installhook(void* func, __int64 kiuserexceptiondispatcher)
{
    // TODO
}

void old_windows_uninstallhook(__int64 kiuserexceptiondispatcher)
{
    // TODO
}

void InstallHook(void* func)
{
    auto kiuserexceptiondispatcher = (__int64)GetProcAddress(GetModuleHandleA("ntdll.dll"), "KiUserExceptionDispatcher");

    if (kiuserexceptiondispatcher)
    {
        if (*(__int32*)kiuserexceptiondispatcher == 0x58B48FC)
        {
            auto distance = *(DWORD*)(kiuserexceptiondispatcher + 4);
            auto ptr = (kiuserexceptiondispatcher + 8) + distance;
            __fn_ptr_hook = ptr;

            auto OldProtection = 0ul;
            VirtualProtect(reinterpret_cast<void*>(ptr), 8, PAGE_EXECUTE_READWRITE, &OldProtection);
            *reinterpret_cast<void**>(ptr) = func;
            VirtualProtect(reinterpret_cast<void*>(ptr), 8, OldProtection, &OldProtection);
        }
        else if (*(__int32*)kiuserexceptiondispatcher == 0x248C8B48)
        {
            wine_installhook(func, kiuserexceptiondispatcher);
        }
        else
        {
            old_windows_installhook(func, kiuserexceptiondispatcher);
        }
    }
}

void UninstallHook()
{
    // unload current thread's dr7
    __int64 off = INT3_2_BO3;
    ((void(__fastcall*)())off)(); // force an exception to install the exception handler and setup debug registers

    auto kiuserexceptiondispatcher = (__int64)GetProcAddress(GetModuleHandleA("ntdll.dll"), "KiUserExceptionDispatcher");

    if (kiuserexceptiondispatcher)
    {
        if (*(__int32*)kiuserexceptiondispatcher == 0x58B48FC)
        {
            if (__fn_ptr_hook)
            {
                auto ptr = __fn_ptr_hook;
                auto OldProtection = 0ul;
                VirtualProtect(reinterpret_cast<void*>(ptr), 8, PAGE_EXECUTE_READWRITE, &OldProtection);
                *reinterpret_cast<void**>(ptr) = __nullsub;
                VirtualProtect(reinterpret_cast<void*>(ptr), 8, OldProtection, &OldProtection);
            }
        }
        else if (*(__int32*)kiuserexceptiondispatcher == 0x248C8B48)
        {
            wine_uninstallhook(kiuserexceptiondispatcher);
        }
        else
        {
            old_windows_uninstallhook(kiuserexceptiondispatcher);
        }
    }
}

void nullsub()
{
    return;
}

int CopyDirectory(const std::string& refcstrSourceDirectory,
    const std::string& refcstrDestinationDirectory)
{
    std::string     strSource;               // Source file
    std::string     strDestination;          // Destination file
    std::string     strPattern;              // Pattern
    HANDLE          hFile;                   // Handle to file
    WIN32_FIND_DATA FileInformation;         // File information


    strPattern = refcstrSourceDirectory + "\\*.*";

    hFile = ::FindFirstFile(strPattern.c_str(), &FileInformation);
    if (hFile != INVALID_HANDLE_VALUE)
    {
        do
        {
            if (FileInformation.cFileName[0] != '.')
            {
                strSource.erase();
                strDestination.erase();

                strSource = refcstrSourceDirectory + "\\" + FileInformation.cFileName;
                strDestination = refcstrDestinationDirectory + "\\" + FileInformation.cFileName;

                if (FileInformation.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
                {
                    // Copy subdirectory
                    CopyDirectory(strSource, strDestination);
                }
                else
                {
                    // Copy file
                    CopyFile(strSource.c_str(), strDestination.c_str(), false);
                }
            }
        } while (::FindNextFile(hFile, &FileInformation) == TRUE);

        // Close handle
        ::FindClose(hFile);

        DWORD dwError = ::GetLastError();
        if (dwError != ERROR_NO_MORE_FILES)
            return dwError;
    }

    return 0;
}

void CopyDefaultProfile(bool loadoutOnly)
{
#if !IS_PATCH_ONLY
    if (loadoutOnly)
    {
        CopyFile(PATH_ZONE_DEFAULTSTATS, PATH_MODSTATS_ZM, false);
    }
    else
    {
        CreateDirectoryA(PATH_MODSTATS_ROOT, NULL);
        CopyDirectory(PATH_ZONE_DEFAULTPROFILE, PATH_MODSTATS_ROOT);
    }

    //char* ptr_storage_cache = (char*)OFFSET(0x1790F9C0) + 35160;

    // force stats to reload for loadouts
   // *(__int32*)(ptr_storage_cache + 8) = 0;

    //// reset storage
    //((void(__fastcall*)())(OFFSET(0x22777C0)))();
    
    ((void(__fastcall*)(int, const char*, int))(PTR_Cbuf_AddText))(0, "storageClearAll", 0);
#endif
}

void LoadCustomFiles()
{
#if !IS_PATCH_ONLY
    // load playername
    memset(Protection::CustomName, 0, sizeof(Protection::CustomName));
    if (zbr::fs::exists(PATH_NAMEFILE))
    {
#ifdef USE_NLOG
        ALOG("reading playername file");
#endif
        std::ifstream namefile(PATH_NAMEFILE, ios::in | ios::binary);

        namefile.seekg(0, std::ios::end);
        size_t fileSize = namefile.tellg();
        namefile.seekg(0, std::ios::beg);

        if (fileSize > (CUSTOM_NAME_SIZE - 1))
        {
            fileSize = CUSTOM_NAME_SIZE - 1;
        }

        namefile.read(Protection::CustomName, fileSize);

#ifdef USE_NLOG
        ALOG("playername read done!");
#endif
    }
    else
    {
        std::ofstream namefile;

        namefile.open(PATH_NAMEFILE, ios::out | ios::trunc | ios::binary);

        namefile << DEFAULT_PLAYERNAME;

        namefile.close();

        strcpy_s(Protection::CustomName, DEFAULT_PLAYERNAME);
    }


    if (zbr::fs::exists(PATH_MODSTATS_ZM)) // check default loadouts and replace
    {
//#ifdef USE_NLOG
//        ALOG("reading modstats");
//#endif
//        std::ifstream namefile(PATH_MODSTATS_ZM, ios::in | ios::binary);
//
//        namefile.seekg(0, std::ios::end);
//        size_t fileSize = namefile.tellg();
//        namefile.seekg(0, std::ios::beg);
//
//        if (fileSize <= 0)
//        {
//            goto newProfile;
//        }
//
//        char* fBuff = (char*)malloc(fileSize);
//        namefile.read(fBuff, fileSize);
//
//#ifdef USE_NLOG
//        ALOG("starting crc32");
//#endif
//        
//        uint32_t table[256];
//        crc32::generate_table(table);
//        auto crc = crc32::update(table, 0, fBuff, fileSize);
//
//        
//#ifdef USE_NLOG
//        ALOG("%d crc result", crc);
//#endif

        if (!zbr::fs::exists(PATH_MODSTATS_ZM_VERSION1) && !zbr::fs::exists(PATH_MODSTATS_ZM_VERSION1_1))
        {
            CopyDefaultProfile(false);
        }

        //if (crc == DEFAULT_LOADOUTS_CRC32) // this is a default loadout
        //{
            // CopyDefaultProfile(true);
        //}

        // free(fBuff);
    }
    else // no profile exists, copy default
    {
    newProfile:
        CopyDefaultProfile(false);
    }

    zbr::profile::profile_init();
    XLOG("Files copied");
#endif
}

//#define ZBR_PREFIX_BYTE 0x53

MDT_Define_FASTCALL(REBASE(0x1EF6A30), LobbyMsgRW_PrepWriteMsg_Hook, bool, (__int64 lobbyMsg, __int64 data, int length, int msgType))
{
    PROTECT_LIGHT_START("prepwrite start");
    if (MDT_ORIGINAL(LobbyMsgRW_PrepWriteMsg_Hook, (lobbyMsg, data, length, msgType)))
    {
        // ALOG("sending pkt %d", msgType);
        if (ZBR_PREFIX_BYTE)
        {
            ((void(__fastcall*)(__int64, unsigned char))PTR_MSG_WriteByte)(lobbyMsg, ZBR_PREFIX_BYTE);
            ((void(__fastcall*)(__int64, unsigned char))PTR_MSG_WriteByte)(lobbyMsg, ZBR_PREFIX_BYTE2);
        }
        return true;
    }
    PROTECT_LIGHT_END();
    return false;
}

MDT_Define_FASTCALL(REBASE(0x1EF7990), LobbyMsgRW_PrepReadMsg_Hook, bool, (__int64 lm))
{
    PROTECT_LIGHT_START("prepread start");

    if (MDT_ORIGINAL(LobbyMsgRW_PrepReadMsg_Hook, (lm)) && (!ZBR_PREFIX_BYTE || ((((unsigned char(__fastcall*)(__int64))PTR_MSG_ReadByte)(lm) == ZBR_PREFIX_BYTE) && (((unsigned char(__fastcall*)(__int64))PTR_MSG_ReadByte)(lm) == ZBR_PREFIX_BYTE2)) ))
    {
        // ALOG("valid pkt %d", *(__int32*)(lm + 0x38));
        return true;
    }
    PROTECT_LIGHT_END();
    // ALOG("invalid pkt %d", *(__int32*)(lm + 0x38));
    return true;
}

int get_num_connected_players()
{
    __int64 svsclients = *(__int64*)REBASE(0x176F9318);
    int count = 0;
    for (int i = 0; i < 18; ++i)
    {
        if (*(__int32*)(svsclients + (0xE5170 * i)) == 5)
        {
            ++count;
        }
    }
    return count;
}

#define Sys_Checksum(msg, size) ((unsigned __int16(__fastcall*)(const unsigned char*, __int32))REBASE(0x2177810))(msg, size)
#define BigShort(val) ((__int16(__fastcall*)(__int16))REBASE(0x22E7EB0))(val)
MDT_Define_FASTCALL(REBASE(0x2177980), Sys_VerifyPacketChecksum_Hook, __int64, (const char* payload, __int32 payloadLen))
{
    if (payloadLen >= 2)
    {
        auto newLen = payloadLen - 2;
        auto checksum = (unsigned __int16)Protection::PrivatePassword[1] ^ Sys_Checksum((unsigned __int8*)payload, payloadLen - 2);
        if (*(unsigned __int16*)(newLen + payload) == (unsigned __int16)checksum)
        {
            return newLen;
        }
        else
        {
            // check if the last time we updated the private password was within the past second
            if (GetTickCount64() <= Protection::PrivatePassword[2] + 1500)
            {
                checksum = checksum ^ (unsigned __int16)Protection::PrivatePassword[1] ^ (unsigned __int16)Protection::PrivatePassword[0];
                if (*(unsigned __int16*)(newLen + payload) == (unsigned __int16)checksum)
                {
                    return newLen;
                }
            }

            //if (arxan_evasion::load_index || (*(__int32*)(LOCAL_CLIENT_CONSTATE + 8) < 0xB) || (DiscordRP::AmIHost() && (((int(__fastcall*)(int, int))Scr_GetNumExpectedPlayers)(1, 0) > get_num_connected_players()))) // note: this lets loading remote crashes happen, so we may want to add security in other places, ie: no LMs while loading.
            //{
            //    if (*(unsigned __int16*)(newLen + payload) == ((unsigned __int16)checksum ^ (unsigned __int16)Protection::PrivatePassword[1]))
            //    {
            //        return newLen;
            //    }
            //}
        }
        ALOG("^6Dropping packet checksum %d != %d\n\n\n\n", checksum, *(__int16*)(newLen + payload));
    }
    return -1;
}

MDT_Define_FASTCALL(REBASE(0x21778E0), Sys_ChecksumCopy_Hook, unsigned __int16, (const char* desta, const char* srca, __int32 length))
{
    auto val = MDT_ORIGINAL(Sys_ChecksumCopy_Hook, (desta, srca, length));
    /*if ((*(__int32*)(LOCAL_CLIENT_CONSTATE + 8) >= 0xB))
    {
        val ^= (__int16)Protection::PrivatePassword[1];
    }*/
    val ^= (unsigned __int16)Protection::PrivatePassword[1];
    return val;
}

MDT_Define_FASTCALL(__report_gsfailure, __report_gsfailure_hook, void, (__int64 security_cookie))
{
    *(__int64*)(0x17) = 0;
}

MDT_Define_FASTCALL(REBASE(0x20EF280), COD_GetBuildTitle_Hook, const char*, ())
{
    return zbr_window_text;
}

MDT_Define_FASTCALL(REBASE(0x1E0DA90), Live_SystemInfo_Hook, bool, (int controllerIndex, int infoType, char* outputString, const int outputLen))
{
    if (infoType)
    {
        return MDT_ORIGINAL(Live_SystemInfo_Hook, (controllerIndex, infoType, outputString, outputLen));
    }

    strcpy_s(outputString, outputLen, ZBR_VERSION_FULL);
    return true;
}

MDT_Define_FASTCALL(LoadCursorA, LoadCursorA_Hook, HCURSOR, (HINSTANCE instance, LPCSTR cursorName))
{
    if ((__int16)cursorName == 0x83)
    {
        return MDT_ORIGINAL(LoadCursorA_Hook, (Offsets::GetOurModuleHandle(), MAKEINTRESOURCE(IDC_CURSOR3)));
    }
    return MDT_ORIGINAL(LoadCursorA_Hook, (Offsets::GetOurModuleHandle(), MAKEINTRESOURCE(IDC_CURSOR3)));
}

MDT_Define_FASTCALL(REBASE(0x1EEBD10), LobbyTypes_GetMsgTypeName_Hook, const char*, (__int32 index))
{
    if (index < -1)
    {
        return "invalid";
    }
    if (index > MESSAGE_TYPE_DEMO_STATE)
    {
        if (index >= MESSAGE_TYPE_ZBR_COUNT)
        {
            return "invalid";
        }
#if !IS_PATCH_ONLY
        switch (index)
        {
            case MESSAGE_TYPE_ZBR_LOBBYINFO_REQUEST:
                return "33";
            case MESSAGE_TYPE_ZBR_LOBBYINFO_RESPONSE:
                return "34";
            case MESSAGE_TYPE_ZBR_LOBBYSTATE:
                return "35";
            case MESSAGE_TYPE_ZBR_CLIENTRELIABLE:
                return "36";
            case MESSAGE_TYPE_ZBR_CHARACTERRPC:
                return "37";
        }
#endif
        return "invalid";
    }
    return MDT_ORIGINAL(LobbyTypes_GetMsgTypeName_Hook, (index));
}

MDT_Define_FASTCALL(REBASE(0x1F334C0), UI_DoModelStringReplacement_Hook, bool, (__int32 controllerIndex, char* element, const char* source, char* dest, unsigned int destSize))
{
    char input[4096]{};
    strcpy_s(input, source);
    input[4095] = 0;
    int max = strlen(input);

    bool b_replace = false;
    for (int i = 0; i < max; i++)
    {
        if (input[i] != '$' || (i + 1) >= max)
        {
            continue;
        }
        if (input[i + 1] != '(')
        {
            continue;
        }
        bool b_found = false;
        int j = i + 2;
        for (; j < max; j++)
        {
            if (input[j] == ')')
            {
                b_found = true;
                break;
            }
        }
        if (!b_found)
        {
            b_replace = true;
            input[i] = '.';
            input[i + 1] = '.';
            i++;
        }
        else
        {
            i = j;
        }
    }

    if (b_replace)
    {
        strcpy_s(dest, destSize, input);
        *(dest + destSize - 1) = 0;
        return true;
    }

    return MDT_ORIGINAL(UI_DoModelStringReplacement_Hook, (controllerIndex, element, input, dest, destSize));
}

MDT_Define_FASTCALL(REBASE(0x2C3D960), qmemcpy_Hook, __int64, (char* dest, char* source, __int32 size))
{
    if (size < 0)
    {
        *dest = 0;
        *source = 0;
        return 0;
    }
    return MDT_ORIGINAL(qmemcpy_Hook, (dest, source, size));
}

MDT_Define_FASTCALL(REBASE(0x2148C00), Com_MessagePrintHook, void, (int channel, int consoleType, const char* message, int other))
{
    ALOG("%s", message);
    MDT_ORIGINAL(Com_MessagePrintHook, (channel, consoleType, message, other));
}

#define NUM_EMOJIS 31
#if !IS_PATCH_ONLY
const char *emoji_ids[NUM_EMOJIS] = { ":zbrrevive:", ":zbrtroll:", ":zbrclown:", ":zbrpog:", ":zbrpepega:",
":zbrdumb:", ":zbrcheck:", ":zbrx:", ":zbrtrade:", ":zbrrespect:", ":zbrsupreme:", ":zbregg:", 
":zbrgasp:", ":zbrbruh:", ":zbrsus:", ":zbrsmile:", ":zbrsad:", ":zbrdead:", ":zbrevil:", ":zbrpoint:", ":zbrsmug:",
":zbrelephant:", ":zbrread:", ":zbrkai:" , ":zbrlove:" , ":zbrpetah:" , ":zbrsip:" , ":zbrthinking:" , ":zbrbased:" , ":zbrchair:" , ":zbrfly:" };
#endif

MDT_Define_FASTCALL(REBASE(0x22792F0), SEH_ReplaceDirectiveInStringWithBinding_Hook, const char*, (int localClientNum, const char* translatedString, char* finalString))
{
    char input[4096];

    if (!translatedString)
    {
        translatedString = "";
    }

    if (strlen(translatedString) > 4095)
    {
        return 0;
    }

    if (!finalString)
    {
        return 0;
    }

    strcpy_s(input, translatedString);
    input[4095] = 0;
    int max = strlen(input);

    for (int i = 0; i < max; i++)
    {
        if (input[i] != '^' || (i + 1) >= max)
        {
            continue;
        }
        if (input[i + 1] != 'B')
        {
            continue;
        }
        bool b_found = false;
        int j = i + 2;
        int count = 0;
        for (; j < max; j++, count++)
        {
            if (input[j] == '^')
            {
                b_found = true;
                if (count >= 0x40)
                {
                    b_found = false;
                }
                break;
            }
        }
        if (!b_found)
        {
            input[i] = '.';
            i++;
        }
        else
        {
            i = j;
        }
    }

    auto tokenPos = strstr(input, "[{");
    while (tokenPos)
    {
        auto endTokenPos = strstr(tokenPos + 2, "}]");
        if (!endTokenPos || (endTokenPos - tokenPos) >= 0x100)
        {
            *tokenPos = '.';
            *(tokenPos + 1) = '.';
        }
        tokenPos = strstr(tokenPos + 2, "[{");
    }

#if !IS_PATCH_ONLY
    char* c = input;
    //bool replaced = false;
    while (*c)
    {
        c = strstr(c, ":zbr");

        if (!c)
        {
            break;
        }

        char* token = NULL;

        for (int i = 0; i < NUM_EMOJIS; i++)
        {
            token = strstr(c, emoji_ids[i]);
            if (token == c)
            {
                break;
            }
            token = NULL;
        }

        if (!token)
        {
            c++;
            continue;
        }

        *c++ = '^';
        *c++ = 'H';
        *c++ = (char)0x2A;
        *c++ = (char)0x2A;

        char* next = c;
        while (*next != ':') next++;

        char* previous = next - 1;

        char length = 0;
        while (next != c)
        {
            length++;
            *next = *previous;
            next--;
            previous--;
        }

        *c = (char)length;
        c += length;
        //replaced = true;
    }
#endif

    /*if (replaced)
    {
        ALOG("replaced: %s", input);
    }*/

    return MDT_ORIGINAL(SEH_ReplaceDirectiveInStringWithBinding_Hook, (localClientNum, input, finalString));
}

MDT_Define_FASTCALL(PTR_LobbyMsgRW_PackageInt, LobbyMsgRW_PackageInt_Hook, bool, (LobbyMsg* lobbyMsg, const char* key, __int32* val))
{
    /*if ((*(__int32*)(LOCAL_CLIENT_CONSTATE + 8) < 0xB))
    {
        return false;
    }*/
    bool result = MDT_ORIGINAL(LobbyMsgRW_PackageInt_Hook, (lobbyMsg, key, val));
    if (result && (!Protection::I_stricmp(key, "lobbytype") || !Protection::I_stricmp(key, "srclobbytype") || !Protection::I_stricmp(key, "destlobbytype")))
    {
        if (*val < 0 || *val > 1)
        {
            XLOG("DROP LOBBYTYPE");
            return false;
        }
    }
    return result;
}

MDT_Define_FASTCALL(PTR_LobbyMsgRW_PackageUInt, LobbyMsgRW_PackageUInt_Hook, bool, (LobbyMsg* lobbyMsg, const char* key, unsigned __int32* val))
{
    /*if ((*(__int32*)(LOCAL_CLIENT_CONSTATE + 8) < 0xB))
    {
        return false;
    }*/

    bool result = MDT_ORIGINAL(LobbyMsgRW_PackageUInt_Hook, (lobbyMsg, key, val));

    if (result && (!Protection::I_stricmp(key, "lobbytype") || !Protection::I_stricmp(key, "srclobbytype") || !Protection::I_stricmp(key, "destlobbytype")))
    {
        if (*val > 1)
        {
            XLOG("DROP LOBBYTYPE 2");
            return false;
        }
    }

    if (result && (!Protection::I_stricmp(key, "datamask")))
    {
        __int32 state = *(__int32*)REBASE(0x168ED7F4);
        state = state << 28 >> 28;
        if (state)
        {
            return result;
        }
        return !(*val & 512);
    }
    return result;
}

MDT_Define_FASTCALL(PTR_LobbyMsgRW_PackageUChar, LobbyMsgRW_PackageUChar_Hook, bool, (LobbyMsg* lobbyMsg, const char* key, unsigned char* val))
{
    bool result = MDT_ORIGINAL(LobbyMsgRW_PackageUChar_Hook, (lobbyMsg, key, val));

    if (result && !Protection::I_stricmp(key, "paragoniconid"))
    {
        if (*val > 47) // zm is 55 or something but this is easiest
        {
            *val = 47;
        }
    }
    return result;
}

MDT_Define_FASTCALL(REBASE(0x1EB6050), LiveSteam_InitServer_Hook, void, ())
{
}

#define SV_Cmd_ArgvBuffer(index, outBuf, sizeBuf) ((void(__fastcall*)(__int32, char*, __int32))REBASE(0x20EF090))(index, outBuf, sizeBuf)
#define BG_Cache_GetScriptMenuNameForIndex(inst, index) ((const char*(__fastcall*)(__int32, __int32))REBASE(0xA7DE0))(inst, index)
#define BG_Cache_GetEventStringNameForIndex(inst, index) ((const char*(__fastcall*)(__int32, __int32))REBASE(0xA78A0))(inst, index)
#define LobbyHost_IsHost(lobbyType) ((bool(__fastcall*)(__int32))REBASE(0x1ED9110))(lobbyType)
#define Scr_AddString(inst, strValue) ((void(__fastcall*)(__int32, const char*))REBASE(0x12E9A30))(inst, strValue)
#define Scr_ExecEntThread(pent, fn, pcount) ((__int32(__fastcall*)(void*, void*, __int32))REBASE(0x1B2C650))(pent, fn, pcount)
#define Scr_FreeThread(inst, thread) ((void(__fastcall*)(__int32, __int32))REBASE(0x12EAB50))(inst, thread)
#define SV_Cmd_ConcatArgs(start) ((const char*(__fastcall*)(__int32))REBASE(0x1972B80))(start)

const char* bad_str = "bad";

MDT_Define_FASTCALL(REBASE(0xA7DE0), BG_Cache_GetScriptMenuNameForIndex_Hook, const char*, (unsigned __int32 inst, unsigned __int32 index))
{
    if (index >= 64u) // max assets for this type
    {
        return bad_str;
    }
    return (const char*)(REBASE(0x36D5B20) + 0x45FE00 * inst + 0x408 * index);
}

MDT_Define_FASTCALL(REBASE(0xA78A0), BG_Cache_GetEventStringNameForIndex_Hook, const char*, (unsigned __int32 inst, unsigned __int32 index))
{
    if (index >= 256u) // max assets for this type
    {
        return bad_str;
    }
    return (const char*)(REBASE(0x39EBD20) + 0x45FE00 * inst + 0x408 * index);
}

MDT_Define_FASTCALL(REBASE(0xA7BC0), BG_Cache_GetModelForIndex_Hook, const char*, (unsigned __int32 inst, unsigned __int32 index))
{
    if (index >= 4096u) // max assets for this type
    {
        return bad_str;
    }
    return ((const char**)0x36841F0)[2 * (0x45FE00 * inst + index)];
}

MDT_Define_FASTCALL(REBASE(0xA7AB0), BG_Cache_GetLocStringNameForIndex_hook, const char*, (unsigned __int32 inst, unsigned __int32 index))
{
    if (index >= 2048u) // max assets for this type
    {
        return bad_str;
    }
    return (const char*)(REBASE(0x3766D20) + 0x45FE00 * inst + 0x408 * index);
}

MDT_Define_FASTCALL(REBASE(0xA7A00), BG_Cache_GetLUIMenuForIndex_hook, const char*, (unsigned __int32 inst, unsigned __int32 index))
{
    if (index >= 64u) // max assets for this type
    {
        return bad_str;
    }
    return (const char*)(REBASE(0x3AABCF0) + 0x45FE00 * inst + 0x408 * index);
}

MDT_Define_FASTCALL(REBASE(0xA7990), BG_Cache_GetLUIMenuDataForIndex_hook, const char*, (unsigned __int32 inst, unsigned __int32 index))
{
    if (index >= 128u) // max assets for this type
    {
        return bad_str;
    }
    return (const char*)(REBASE(0x3ABBEF0) + 0x45FE00 * inst + 0x408 * index);
}

MDT_Define_FASTCALL(REBASE(0x195F0E0), CMD_MenuResponse_f_hook, void, (char* ent))
{
    char mres[1024]{};
    char szMenuName[1024]{};

    // cant call original cause arxan pointer decryption routines, but its fine we can just recreate and omit some other useless stuff while we are at it.
    int nesting = *(__int32*)REBASE(0x1689AE30); // REBASE(0x1689AE94)
    int num_args = ((__int32*)REBASE(0x1689AE94))[nesting];
    int menuIndex = 0;

    PROTECT_LIGHT_START("CMD_MenuResponse_f_hook");
    if (num_args != 4)
    {
        strcpy_s(mres, "bad");
    }
    else
    {
        SV_Cmd_ArgvBuffer(1, szMenuName, 1024);
        auto svId = atoi(szMenuName);
        if (svId != *(__int32*)REBASE(0x176F8500))
        {
            return; // unamused
        }
        SV_Cmd_ArgvBuffer(2, szMenuName, 1024);
        menuIndex = atoi(szMenuName);
        if ((unsigned __int32)menuIndex > 0x3Fu)
        {
            szMenuName[0] = 0;
        }
        else
        {
            strcpy_s(szMenuName, BG_Cache_GetScriptMenuNameForIndex(0, menuIndex));
        }
        SV_Cmd_ArgvBuffer(3, mres, 1024);
    }

    if (!Protection::I_stricmp(mres, "badspawn"))
    {
        return;
    }

    if (*(__int32*)ent) // not host
    {
        if (!(Protection::I_stricmp(mres, "killserverpc") && Protection::I_stricmp(mres, "endgame") && Protection::I_stricmp(mres, "endround") && Protection::I_stricmp(mres, "restart_level_zm")))
        {
            // someone who is not host tried to end the game
            snprintf(mres, 1024, "tempBanClient %i\n", *(__int32*)ent); // kick them
            Protection::Cbuf_AddText(0, mres, 0);
            return;
        }
    }

    if (Protection::I_stricmp(mres, "killserverpc") && Protection::I_stricmp(mres, "endgame") && Protection::I_stricmp(mres, "endround")
        || LobbyHost_IsHost(1u))
    {
        Scr_AddString(0, mres);
        Scr_AddString(0, szMenuName);
        __int32 thread = Scr_ExecEntThread(ent, (void*)*(__int64*)REBASE(0xA625800), 2);
        Scr_FreeThread(0, thread);
    }
    else
    {
        // someone who is not host tried to end the game
        snprintf(mres, 1024, "tempBanClient %i\n", *(__int32*)ent); // kick them
        Protection::Cbuf_AddText(0, mres, 0);
        return;
    }
    PROTECT_LIGHT_END();
}

MDT_Define_FASTCALL(REBASE(0x195EF80), CMD_MenuResponseCached_f_hook, void, (char* ent))
{
    char mres[1024]{};
    char szMenuName[1024]{};

    // cant call original cause arxan pointer decryption routines, but its fine we can just recreate and omit some other useless stuff while we are at it.
    int nesting = *(__int32*)REBASE(0x1689AE30);
    int num_args = ((__int32*)REBASE(0x1689AE94))[nesting];
    int menuIndex = 0;

    PROTECT_LIGHT_START("CMD_MenuResponseCached_f_hook");
    if (num_args != 4)
    {
        strcpy_s(mres, "bad");
    }
    else
    {
        SV_Cmd_ArgvBuffer(1, szMenuName, 1024);
        auto svId = atoi(szMenuName);
        if (svId != *(__int32*)REBASE(0x176F8500))
        {
            return; // unamused
        }
        SV_Cmd_ArgvBuffer(2, szMenuName, 1024);
        menuIndex = atoi(szMenuName);
        if ((unsigned __int32)menuIndex > 0x3Fu)
        {
            szMenuName[0] = 0;
        }
        else
        {
            strcpy_s(szMenuName, BG_Cache_GetScriptMenuNameForIndex(0, menuIndex));
        }
        SV_Cmd_ArgvBuffer(3, mres, 1024);
        auto eventIndex = (unsigned int)atoi(mres);
        strcpy_s(mres, BG_Cache_GetEventStringNameForIndex(0, eventIndex));
    }

    if (!Protection::I_stricmp(mres, "badspawn"))
    {
        return;
    }

    if (*(__int32*)ent) // not host
    {
        if (!(Protection::I_stricmp(mres, "killserverpc") && Protection::I_stricmp(mres, "endgame") && Protection::I_stricmp(mres, "endround") && Protection::I_stricmp(mres, "restart_level_zm")))
        {
            // someone who is not host tried to end the game
            snprintf(mres, 1024, "tempBanClient %i\n", *(__int32*)ent); // kick them
            Protection::Cbuf_AddText(0, mres, 0);
            return;
        }
    }

    if (Protection::I_stricmp(mres, "killserverpc") && Protection::I_stricmp(mres, "endgame") && Protection::I_stricmp(mres, "endround")
        || LobbyHost_IsHost(1u))
    {
        Scr_AddString(0, mres);
        Scr_AddString(0, szMenuName);
        __int32 thread = Scr_ExecEntThread(ent, (void*)*(__int64*)REBASE(0xA625800), 2);
        Scr_FreeThread(0, thread);
    }
    else
    {
        // someone who is not host tried to end the game
        snprintf(mres, 1024, "tempBanClient %i\n", *(__int32*)ent); // kick them
        Protection::Cbuf_AddText(0, mres, 0);
        return;
    }
    PROTECT_LIGHT_END();
}

//MDT_Define_FASTCALL(OFFSET(0xF97920), CG_TeamOpsSetProgress_hook, void, (int clientNum, int team, int progress))
//{
//    // DO NOT CALL ORIGINAL; ARXAN DECRYPTION
//}

MDT_Define_FASTCALL(REBASE(0x2018FC0), UI_Model_GetModelFromPath_0_hook, __int32, (__int64 parentNodeIndex, const char* path))
{
    if (!path)
    {
        return 0;
    }

    int len = strlen(path);
    int keySize = 0;
    for (int i = 0; i < len; i++)
    {
        if (path[i] != '.')
        {
            keySize++;
        }
        else
        {
            if (keySize >= 64)
            {
                return 0;
            }
            keySize = 0;
        }
    }
    if (keySize >= 64)
    {
        return 0;
    }

    return MDT_ORIGINAL(UI_Model_GetModelFromPath_0_hook, (parentNodeIndex, path));
}

MDT_Define_FASTCALL(REBASE(0x2019670), UI_Model_GetModelFromPath_hook, __int32, (__int64 parentNodeIndex, const char* path))
{
    if (!path)
    {
        return 0;
    }

    int len = strlen(path);
    int keySize = 0;
    for (int i = 0; i < len; i++)
    {
        if (path[i] != '.')
        {
            keySize++;
        }
        else
        {
            if (keySize >= 64)
            {
                return 0;
            }
            keySize = 0;
        }
    }
    if (keySize >= 64)
    {
        return 0;
    }

    return MDT_ORIGINAL(UI_Model_GetModelFromPath_hook, (parentNodeIndex, path));
}

MDT_Define_FASTCALL(REBASE(0x2019080), UI_Model_CreateModelFromPath_0_hook, __int32, (__int64 parentNodeIndex, const char* path))
{
    if (!path)
    {
        return 0;
    }

    int len = strlen(path);
    int keySize = 0;
    for (int i = 0; i < len; i++)
    {
        if (path[i] != '.')
        {
            keySize++;
        }
        else
        {
            if (keySize >= 64)
            {
                return 0;
            }
            keySize = 0;
        }
    }
    if (keySize >= 64)
    {
        return 0;
    }

    return MDT_ORIGINAL(UI_Model_CreateModelFromPath_0_hook, (parentNodeIndex, path));
}

MDT_Define_FASTCALL(REBASE(0x2018DC0), UI_Model_AllocateNode_hook, __int32, (__int32 ancestorIndex, const char* path, bool persistent))
{
    if (!path)
    {
        return 0;
    }

    if (!*(__int16*)REBASE(0x163120D0)) // out of model paths to use (TODO: should we instead back this off and restart the UI?)
    {
        return 0;
    }

    if (strlen(path) >= 64)
    {
        return 0;
    }

    return MDT_ORIGINAL(UI_Model_AllocateNode_hook, (ancestorIndex, path, persistent));
}

#define Lua_CoD_RegisterEngineFunction(state, fname, ffunc) ((void(__fastcall*)(void*, const char*, void*))REBASE(0x1F10A90))(state, fname, ffunc)
#if !IS_PATCH_ONLY

__int32 ResetLoadouts(void* luaState)
{
#if !IS_PATCH_ONLY
    CopyDefaultProfile(false);
    ((void(__fastcall*)())REBASE(0x266CFA0))();
#endif
    return 1;
}

__int32 ExecInLobbyVM(void* luaState)
{
#if !IS_PATCH_ONLY
    lua_State* s = (lua_State*)luaState;
    const char* code = lua_tostring(s, -1);
    lua_State* lobbyVM = *(lua_State**)PTR_LobbyVM;
    *(char*)(*(INT64*)((INT64)lobbyVM + 16) + 472) = HKS_BYTECODE_SHARING_ON;
    HksCompilerSettings hks_compiler_settings;
    int result = hksi_hksL_loadbuffer(lobbyVM, &hks_compiler_settings, code, strlen(code), code);
    if (!result)
    {
        result = hks::vm_call_internal(lobbyVM, 0, 0, 0);
    }
    *(char*)(*(INT64*)((INT64)lobbyVM + 16) + 472) = HKS_BYTECODE_SHARING_SECURE;
#endif
    return 1;
}

__int32 ResetTeams(void* luaState)
{
#if !IS_PATCH_ONLY
    zbr::teams::reset();
#endif
    return 1;
}

__int32 SetUIGametype(void* luaState)
{
#if !IS_PATCH_ONLY
    lua_State* s = (lua_State*)luaState;
    const char* gt = lua_tostring(s, -1);
    strcpy_s(zbr::lobbystate.gamemode, gt);
    zbr::gamesettings::on_gametype_changed();
#endif
    return 1;
}

__int32 SelectTeams(void* luaState)
{
#if !IS_PATCH_ONLY
    if (DiscordRP::AmIHost())
    {
        zbr::teams::autobalance();
    }
#endif
    return 1;
}

struct LUIElementFunction
{
    const char* name;
    __int64 subroutine;
    __int64 next;
};

struct LUIPosData
{
    int pOff;
    int circle;
};

LUIElementFunction setupUI3dText;

float flerp(float a, float b, float f)
{
    return a * (1.0 - f) + (b * f);
}

// LUIElement* element
// LUIElement* root
std::unordered_map<__int64, LUIPosData> elementRootPositionMatrix;
int sideCounter = 0;
int leftSide = 0;
void __cdecl UIElement_UI3DTextUncachedRender(const __int32 localClientNum, __int64 element, __int64 root, float red, float green, float blue, float alpha, lua_State* luaVM)
{
    // if the textref is null
    auto text_handle = *(unsigned int*)(element + 340);
    if (text_handle == -2)
    {
        return;
    }

    // get string at top of vm
    auto luavm = (__int64)luaVM;
    auto v11 = *(__int64*)(luavm + 72);
    ((void(__fastcall*)(__int64, __int64, __int32, __int64))REBASE(0x1D4B510))(luavm, *(__int64*)(luavm + 16) + 480, text_handle, v11);
    *(__int64*)(luavm + 72) = v11 + 16;
    const char* text = 0;
    if (v11 >= *(__int64*)(luavm + 80))
        text = ((const char*(__fastcall*)(__int64, __int64, __int64))REBASE(0x1D4B6C0))(luavm, v11, 0);

    if (!text)
    {
        return;
    }
    
    float wrapWidth = -1;
    if (*(__int32*)(element + 220))
        wrapWidth = *(float*)(element + 368) - *(float*)(element + 360);
    
    
    *(char*)PTR_s_immediateRender = 1;
    float pos[3]{ 0 };
    float screenPos[2]{ 0 };
    bool in_view = true;
    /*if (elementRootPositionMatrix.find(element) == elementRootPositionMatrix.end())
    {
        zbr::damage3d_unpack_origin(text, pos);
        in_view = SPOOFED_CALL(((bool(__fastcall*)(__int32, float*, float*))PTR_UI_WorldPosToLUIPos), localClientNum, pos, screenPos);

        if (in_view)
        {
            elementRootPositionMatrix[element] = LUIVec2();
            elementRootPositionMatrix[element].x = screenPos[0];
            elementRootPositionMatrix[element].y = screenPos[1];
        }
    }
    else
    {
        screenPos[0] = elementRootPositionMatrix[element].x;
        screenPos[1] = elementRootPositionMatrix[element].y;
    }*/

    zbr::damage3d_unpack_origin(text, pos);
    in_view = SPOOFED_CALL(((bool(__fastcall*)(__int32, float*, float*))PTR_UI_WorldPosToLUIPos), localClientNum, pos, screenPos);

    alpha = 1;

    float lerpAlpha = 0;
    float xOffset = 0;
    float yOffset = 0;
    float scaleOffset = 0;
    __int32 animationDuration = *(__int32*)(element + (87 * 4));
    __int32 animationTimeLeft = *(__int32*)(element + (86 * 4));

    if (animationTimeLeft < 0)
    {
        animationTimeLeft = 0;
    }
    
    // animationDuration and animationTimeLeft
    if (in_view && animationDuration > 0)
    {
        lerpAlpha = 1.0 - ((float)animationTimeLeft / (float)animationDuration);
        float sqrtlerpAlpha = sqrt(lerpAlpha);
        float scaleAlpha = min(lerpAlpha / 0.2, 1.0);
        float transitionalProgress = min(flerp(0, 1.0, sqrtlerpAlpha) / 0.425, 1.0);

        if (elementRootPositionMatrix.find(element) == elementRootPositionMatrix.end())
        {
            elementRootPositionMatrix[element] = LUIPosData();
            elementRootPositionMatrix[element].pOff = leftSide * 180;
            elementRootPositionMatrix[element].circle = (sideCounter / 5);
            sideCounter++;

            if (sideCounter >= 10)
            {
                sideCounter = 0;
                leftSide = !leftSide;
            }
        }

        // pointer to element is the seed for the random choice (deterministic choice that can be regenerated without storing it)
        srand((unsigned int)element);
        int degrees = (((rand() % 30) + 0) - 15) + elementRootPositionMatrix[element].pOff;
        float rads = degrees * 0.01745331111;

        int circleIndex = elementRootPositionMatrix[element].circle;
        xOffset = cos(rads) * transitionalProgress * (60 + (30 * circleIndex));
        yOffset = -(sin(rads) * transitionalProgress * (60 + (30 * circleIndex)));
        scaleOffset = flerp(-13.0, -1.0, scaleAlpha);
        alpha = flerp(0, 1.0, min(lerpAlpha / 0.1, 1.0));
    }
    else
    {
        alpha = 0;
    }

    ((void(__fastcall*)(__int32, __int64, __int64, float, float, float, float, float, float, const char*, __int64, float, __int32, __int64, float))PTR_UI_CustomDrawText)(
        localClientNum,
        element,
        root,
        screenPos[0] + xOffset,
        screenPos[1] + yOffset,
        red,
        green,
        blue,
        alpha,
        text + 12,
        *(__int64*)(element + 8), // font
        (22.0 + scaleOffset), // fontHeight
        0x12, // align
        luavm,
        -1.0 // wrap
        );
    
    *(char*)PTR_s_immediateRender = 0;
    *(__int64*)(luavm + 72) -= 16; // pop vm
}

void __cdecl UIElement_UI3DTextUncachedClosed(__int64 element)
{
    elementRootPositionMatrix.erase(element);
}

int UI_LuaCall_UIElement_setupUI3dText(lua_State* luaVM)
{
    // element->render = func
    *(__int64*)(((__int64(__fastcall*)(__int64, __int64))PTR_UI_ToElement)((__int64)luaVM, 1) + 0x118) = (__int64)UIElement_UI3DTextUncachedRender;
    *(__int64*)(((__int64(__fastcall*)(__int64, __int64))PTR_UI_ToElement)((__int64)luaVM, 1) + 0x128) = (__int64)UIElement_UI3DTextUncachedClosed;
    return 0;
}

int PostLoad(void* s)
{
#if !IS_PATCH_ONLY
    // zbr::zone::load_custom_from_disk(ZBR_ZONE_CHARACTERS_DEFAULT, ZBR_ZONE_CHARACTERS_CONTENTID);
#endif
    return 1;
}

//EXPORT void TEST()
//{
//    zbr::zone::load_custom_from_disk(ZBR_ZONE_CHARACTERS_DEFAULT, ZBR_ZONE_CHARACTERS_CONTENTID);
//}

EXPORT int zbr_init_luavm(void* luaState)
{
    PROTECT_LIGHT_START("zbr_init_luavm");
    Lua_CoD_RegisterEngineFunction(luaState, "LoadZBRMod", LoadZBRMod);
    Lua_CoD_RegisterEngineFunction(luaState, "EnableDuos", EnableDuos);
    Lua_CoD_RegisterEngineFunction(luaState, "EnableTrios", EnableTrios);
    Lua_CoD_RegisterEngineFunction(luaState, "EnableQuads", EnableQuads);
    Lua_CoD_RegisterEngineFunction(luaState, "EnableSolos", EnableSolos);
    Lua_CoD_RegisterEngineFunction(luaState, "EnableDiscordSDK", EnableDiscordSDK);
    Lua_CoD_RegisterEngineFunction(luaState, "PatchDisconnectExploit", PatchDisconnectExploit);

    setupUI3dText.name = "setupUI3DText";
    setupUI3dText.subroutine = (__int64)UI_LuaCall_UIElement_setupUI3dText;

    if (((LUIElementFunction*)PTR_LUIElementFunctionEntryHook)->next != (__int64)&setupUI3dText)
    {
        setupUI3dText.next = ((LUIElementFunction*)PTR_LUIElementFunctionEntryHook)->next;
        ((LUIElementFunction*)PTR_LUIElementFunctionEntryHook)->next = (__int64)&setupUI3dText;
    }

    const luaL_Reg statsLib[] =
    {
        {"aaa", DiscordRP::AmIADeveloper},
        {"aab", DiscordRP::AmIA2021Competitor},
        {"RepLobbystate", DiscordRP::RepLobbystate},
        {"IsDuos", DiscordRP::IsZBRDuos},
        {"ResetLoadouts", ResetLoadouts},
        {"ExecInLobbyVM", ExecInLobbyVM},
        {"ResetTeams", ResetTeams},
        {"SelectTeams", SelectTeams},
        {"GetTeamsSize", GetTeamsSize},
        {"PostLoad", PostLoad},
        {"GetProfileValue", zbr::profile::lget},
        {"SetProfileValue", zbr::profile::lset},
        {"HasAdditionalContent", zbr::zone::lhascontent},
        {"GetBuildID", zbr::lget_buildid},
        {"NeedsUpdates", zbr::lcheck_updates},
        {"aac", DiscordRP::AmIAZ4CPlayer},
        {"aad", DiscordRP::AmIAZ4CWinner},
        {"GetGameSetting", zbr::gamesettings::lget},
        {"SetGameSetting", zbr::gamesettings::lset},
        {"SetUIGametype", SetUIGametype},
        {nullptr, nullptr},
    };

    hksI_openlib((lua_State*)luaState, "ZBR", statsLib, 0, 1);
    hksI_openlib(*(lua_State**)PTR_LobbyVM, "ZBR", statsLib, 0, 1);

    PROTECT_LIGHT_END();
    return 1;
}
#endif
#if !IS_PATCH_ONLY
MDT_Define_FASTCALL(REBASE(0x1F10B90), Lua_CoD_RegisterEngineFunctions_hook, void, (void* luaState))
{
    MDT_ORIGINAL(Lua_CoD_RegisterEngineFunctions_hook, (luaState));
    zbr_init_luavm(luaState);
}
#endif
#if !IS_PATCH_ONLY

int hks_nullsub(void* s)
{
    return 1;
}

int hks_nullsub_int(void* s)
{
    lua_pushinteger((lua_State*)s, 0);
    return 1;
}

int hks_nullsub_nil(void* s)
{
    lua_pushnil((lua_State*)s);
    return 1;
}

MDT_Define_FASTCALL(REBASE(0x1D49440), hksI_openlib_hook, void, (lua_State* s, const char* libname, const luaL_Reg l[], int nup, int isHksFunc))
{
    if (libname)
    {
        if (!Protection::I_stricmp(libname, "io"))
        {
            const luaL_Reg ioLib[] =
            {
                {"close", hks_nullsub_int},
                {"flush", hks_nullsub},
                {"input", hks_nullsub_int},
                {"lines", hks_nullsub_nil},
                {"open", hks_nullsub_nil},
                {"output", hks_nullsub_int},
                {"popen", hks_nullsub_int},
                {"read", hks_nullsub_nil},
                {"tmpfile", hks_nullsub_int},
                {"type", hks_nullsub_int},
                {"write", hks_nullsub_nil},
                {nullptr, nullptr}
            };
            MDT_ORIGINAL(hksI_openlib_hook, (s, libname, ioLib, nup, isHksFunc));
            return;
        }
        else if (!Protection::I_stricmp(libname, "package"))
        {
            const luaL_Reg packageLib[] =
            {
                {"cpath", hks_nullsub_int},
                {"loaded", hks_nullsub_int},
                {"loaders", hks_nullsub_int},
                {"loadlib", hks_nullsub_nil},
                {"path", hks_nullsub_int},
                {"preload", hks_nullsub_int},
                {"seeall", hks_nullsub_int},
                {nullptr, nullptr}
            };
            MDT_ORIGINAL(hksI_openlib_hook, (s, libname, packageLib, nup, isHksFunc));
            return;
        }
        else if (!Protection::I_stricmp(libname, "debug"))
        {
            const luaL_Reg debugLib[] =
            {
                {nullptr, nullptr}
            };
            MDT_ORIGINAL(hksI_openlib_hook, (s, libname, debugLib, nup, isHksFunc));
            return;
        }
        else if (!Protection::I_stricmp(libname, "os"))
        {
            const luaL_Reg osLib[] =
            {
                {"clock", hks_nullsub_int},
                {"exit", hks_nullsub},
                {"remove", hks_nullsub},
                {"rename", hks_nullsub},
                {"date", hks_nullsub_int},
                {"time", hks_nullsub_int},
                {"difftime", hks_nullsub_int},
                {"setlocale", hks_nullsub},
                {"rawclock", hks_nullsub_int},
                {"clockpersecond", hks_nullsub_int},
                {"tmpname", hks_nullsub},
                {"sleep", hks_nullsub},
                {"execute", hks_nullsub},
                {"getenv", hks_nullsub},
                {nullptr, nullptr}
            };
            MDT_ORIGINAL(hksI_openlib_hook, (s, libname, osLib, nup, isHksFunc));
            return;
        }
    }
    MDT_ORIGINAL(hksI_openlib_hook, (s, libname, l, nup, isHksFunc));
}
#endif

const char migrateString[] = "connectResponseMigration";
const char rconString[] = "rcon";
const char requestStatsString[] = "requeststats";

MDT_Define_FASTCALL(REBASE(0x1EF6E40), LobbyMsgRW_PrintMessage_Hook, void, ())
{
    // do nothing, bugged function
}

MDT_Define_FASTCALL(REBASE(0x1EF6B80), LobbyMsgRW_PrintDebugMessage_Hook, __int32, ())
{
    return 0;
}

MDT_Define_FASTCALL(REBASE(0x1F04B20), ExecLuaCMD_hook, void, ())
{
    // do nothing, dangerous function
}

MDT_Define_FASTCALL(DBX_AuthLoad_ValidateSignature_Try, DBX_AuthLoad_ValidateSignature_Try_hook, bool, ())
{
    return true;
}

//MDT_Define_FASTCALL(OFFSET(0x1F054E0), Lua_CmdParseArgs_hook, void, ())
//{
//    // do nothing, dangerous function
//}

MDT_Define_FASTCALL(REBASE(0x1EF65C0), LobbyMsgRW_PackageElement_hook, bool, (__int64 lobbyMsg, bool addElement))
{
    bool res = MDT_ORIGINAL(LobbyMsgRW_PackageElement_hook, (lobbyMsg, addElement)) && addElement;
    if (!res)
    {
        XLOG("DROPPING PACKELEM");
    }
    return res;
}

char tempReportBuff[2048];
MDT_Define_FASTCALL(REBASE(0x1F11DA0), Lua_CoD_LuaStateManager_Error_hook, void, (const char* error, __int64* luaVM))
{
    const char* error_stack = NULL;
    if ((luaVM[9] - 16) >= luaVM[10])
    {
        error_stack = ((const char* (__fastcall*)(__int64*, __int64, __int64))REBASE(0x1D4B6C0))(luaVM, (luaVM[9] - 16), 0);
    }

    __int32 error_hash = 0;
    if (error_stack)
    {
        error_hash = fnv1a(error_stack);
    }

    if (!error_stack)
    {
        error_stack = "<stack unknown>";
    }

    bool is_ui = *(__int64**)REBASE(0x19C76D88) == luaVM;
    const char* error_loc = is_ui ? "EXE_UI_ERROR" : "EXE_LOBBYVM_ERROR";
    // SEH_SafeTranslateString
    const char* translated = ((const char* (__fastcall*)(const char*))REBASE(0x2279510))(error_loc);

#ifdef IS_DEV
    snprintf(tempReportBuff, 2048, "^1%s ^7%X\n%s", translated, error_hash, error_stack);
    Offsets::Log("%s", tempReportBuff);

    FILE* f;
    f = fopen(CRASH_LOG_NAME, "a+"); // a+ (create + append)
    if (f)
    {
        fprintf(f, "\nLUA ERROR: %s\n", tempReportBuff);

        std::fflush(f);
        std::fclose(f);
    }
#endif

    // com_error
    ((void(__fastcall*)(const char*, __int32, __int32, const char*, const char*, __int32, const char*))REBASE(0x20F8170))("", 0, 512, "^1%s ^7%X\n%s", translated, error_hash, error_stack);
}

// function is hks::cclosure
int lua_getinfo_cfunction(__int64 s, __int64 function, __int64 record, const char* what)
{
    // we know that nSl is the only "what" we ever get, so lets just hardcode the body stuff
    
    // first, lets find the c function name
    __int64 c_closure_function = *(__int64*)(function + 16);
    // Offsets::Log("^6 HEY DUMBASS %p %p %p", c_closure_function, *(__int64*)(function + 8), *(__int64*)(function + 16));
    __int64 found_function = 0;

    __int64 f = *(__int64*)PTR_luaenginefunction_list;
    while (f)
    {
        if (*(__int64*)(f + 0x8) == c_closure_function)
        {
            found_function = *(__int64*)(f);
            break;
        }
        f = *(__int64*)(f + 0x18);
    }

    if (found_function)
    {
        *(__int64*)(record + 8) = found_function;
    }
    else
    {
        *(const char**)(record + 8) = "(luaC_unknown)";
    }

    // next, we need to add 'source', but in this case we will do nothing because theres no source in a luaC function
    // finally, we would do line number, but again, luaC has no line number to give.
    return 1;
}

// hksclosure* function
char function_hash_temp[128]{ 0 };
int lua_getinfo_ifunction(__int64 s, __int64 function, __int64 record, const char* what)
{
    auto m = *(__int64*)(function + 16);

    if (!m)
    {
        return 1;
    }


    auto m_debug = *(__int64*)(m + 80);
    auto m_hash = *(__int32*)(m + 16);
    auto m_numParams = *(__int8*)(m + 0x18);
    auto pc = ((__int64(__fastcall*)(__int64, __int64))PTR_getPC)(s, record);
    *(__int32*)(record + 40) = -1;

    // we know that nSl is the only "what" we ever get, so lets just hardcode the body stuff

    // line info will be the same (instruction offset)
    if (m_debug && *(__int32*)(m_debug + 8) && *(__int32*)(record + 576) != -1)
    {
        auto v16 = *(int**)(m_debug + 16);
        if (pc)
            *(__int32*)(record + 40) = v16[(pc - *(__int64*)(m + 40)) >> 2]; // record-currentLine
        else
            *(__int32*)(record + 40) = *v16; // record-currentLine
    }
    else if (*(__int32*)(m + 16) && *(__int32*)(record + 576) != -1)
    {
        if (pc)
            *(__int32*)(record + 40) = (pc - *(__int64*)(m + 40)) >> 2; // record-currentLine
        else
            *(__int32*)(record + 40) = 0; // record-currentLine
    }

    // name of function will be the same except we will use the hash instead of stripped
    ((void(__fastcall*)(__int64, __int64))PTR_getFunctionName)(s, record);
    
    if (!*(const char**)(record + 8) || !**(const char**)(record + 8)) // name
    {
        *(const char**)(record + 8) = ".";
    }

    if (!*(const char**)(record + 16) || !**(const char**)(record + 16)) // namewhat
    {
        *(const char**)(record + 16) = ".";
    }

    if (m_debug)
    {
        auto v13 = *(__int64*)(m_debug + 48);
        if (v13)
            *(__int64*)(record + 8) = v13 + 20;
        if (!*(__int64*)(record + 8))
            *(const char**)(record + 8) = "(anonymous)"; // record->name
    }
    else
    {
        memset(function_hash_temp, 0, sizeof(function_hash_temp));
        if (m_hash)
        {
            sprintf(function_hash_temp, "func_%X(%d)^2[^6%s^7:^1%s^2]", m_hash, m_numParams, *(const char**)(record + 8), *(const char**)(record + 16));
            *(const char**)(record + 8) = function_hash_temp; // record->name
        }
        else
        {
            *(const char**)(record + 8) = "(*stripped)"; // record->name
        }
    }

    // short source will be the filepath instead

    if (!pc)
    {
        if (m_hash)
            sprintf((char*)(record + 64), "func_%X", m_hash); // record->short_src
        else
            sprintf((char*)(record + 64), "func_???"); // record->short_src
        *(__int64*)(record + 32) = record + 64; // record->source
        return 1;
    }
    
    auto temp_pc = pc & ~0xF; // clear these bits so we are aligned
    while (*(__int32*)temp_pc != 0x61754C1B) temp_pc -= 0x10;

    __int64 RawFiles[4096]{ 0 };
    __int64 target = 0;
    auto numFiles = ((__int32(__fastcall*)(__int32, __int64*))PTR_DB_GetAllXAssetOfType)(47, RawFiles);

    for (int i = 0; i < numFiles; i++)
    {
        __int64 entry = RawFiles[i];
        if (*(__int64*)(entry + 0x10) == temp_pc)
        {
            target = entry;
            break;
        }
    }

    if (!target)
    {
        numFiles = *(__int32*)(PTR_XAssetPool_LuaRawFiles_2 + 0x14);
        auto base = *(__int64*)PTR_XAssetPool_LuaRawFiles_2;
        for (int i = 0; i < numFiles; i++)
        {
            __int64 entry = base + i * 0x18;
            if (*(__int64*)(entry + 0x10) == temp_pc)
            {
                target = entry;
                break;
            }
        }
    }

    if (!target)
    {
        sprintf((char*)(record + 64), ">%p", pc); // record->short_src
        *(__int64*)(record + 32) = record + 64; // record->source
        return 1;
    }

    sprintf((char*)(record + 64), "%s", *(const char**)(target)); // record->short_src
    *(__int64*)(record + 32) = record + 64; // record->source

    return 1;
}

MDT_Define_FASTCALL(PTR_hksi_lua_getinfo, hksi_lua_getinfo_hook, __int32, (__int64 s, const char* what, __int64 ar))
{
    bool other_return = false;
    if ((__int64)_ReturnAddress() != REBASE(0x1D4CB3F))
    {
        if ((__int64)_ReturnAddress() != REBASE(0x1D4D3E0))
        {
            return MDT_ORIGINAL(hksi_lua_getinfo_hook, (s, what, ar));
        }
        other_return = true;
    }

    // We really dont care about the what or anything because we are guaranteeing that it is only called with nSl
    if (*(__int32*)(ar + 580)) // if its a tail call
    {
        return MDT_ORIGINAL(hksi_lua_getinfo_hook, (s, what, ar));
    }

    // inlined hks::CallStack::getFunction
    auto v16 = *(__int64*)(s + 24);
    auto v17 = *(int*)(ar + 576);
    __int64 v18;
    if ((__int32)v17 == (unsigned int)((*(__int64*)(s + 40) - v16) / 24))
        v18 = *(__int64*)(s + 80);
    else
        v18 = *(__int64*)(v16 + 24 * (v17 + 1));
    auto v10 = *(__int64*)(v18 - 16);
    auto _function = *(__int64*)(v18 - 8);

    auto v19 = (v10 & 0xF) - 9;

    int result = 0;
    if (!v19)
    {
        result = lua_getinfo_ifunction(s, _function, ar, what);
    }
    else if (v19 == 1)
    {
        result = lua_getinfo_cfunction(s, _function, ar, what);
    }
    else
    {
        return 0;
    }

    if (!result)
    {
        return 0;
    }

    if (other_return)
    {
        ((void(__fastcall*)(__int64, const char*, ...))PTR_hksi_lua_pushfstring)(s, "Error Message: ^1");
        *(__int64*)_AddressOfReturnAddress() = REBASE(0x1D4D412); // skip their trashy error reporting method since we just did stuff ourself
        return 1; // irrelevant but MSVC will complain
    }

    if (v19 == 1)
    {
        // push c closure info to stack trace
        ((void(__fastcall*)(__int64, const char*, ...))PTR_hksi_lua_pushfstring)(s, "\n\t<^1native^7>: in function '^3%s^7'", *(const char**)(ar + 8));
    }
    else
    {
        // push other info to stack trace
        
        // \n\tfilename:
        ((void(__fastcall*)(__int64, const char*, ...))PTR_hksi_lua_pushfstring)(s, "\n\t^5%s^7:", *(const char**)(ar + 32));

        if (*(__int32*)(ar + 40) > -1) // line number
        {
            // %d:
            ((void(__fastcall*)(__int64, const char*, ...))PTR_hksi_lua_pushfstring)(s, "^2%X^7:", *(__int32*)(ar + 40));
        }
        
        if (*(const char**)(ar + 8) && **(const char**)(ar + 8)) // record->name
        {
            ((void(__fastcall*)(__int64, const char*, ...))PTR_hksi_lua_pushfstring)(s, " in function '^3%s^7'", *(const char**)(ar + 8));
        }
        else
        {
            ((void(__fastcall*)(__int64, const char*, ...))PTR_hksi_lua_pushfstring)(s, " ^1??^7");
        }
    }

    *(__int64*)_AddressOfReturnAddress() = REBASE(0x1D4CBE6); // skip their trashy error reporting method since we just did stuff ourself
    return 1; // irrelevant but MSVC will complain
}

#if !IS_PATCH_ONLY
__int64 currentReliableXUID = 0;
MDT_Define_FASTCALL(PTR_Msg_ClientReliableData_Package, Msg_ClientReliableData_Package_hook, bool, (__int64 msgData, __int64 lobbyMsg))
{
    auto result = MDT_ORIGINAL(Msg_ClientReliableData_Package_hook, (msgData, lobbyMsg));
    if ((__int64)_ReturnAddress() != PTR_ClientReliableReturn)
    {
        return result;
    }

    auto datamask = *(__int32*)msgData;
    auto team = *(__int32*)(msgData + 40);

    if ((datamask & 0x20))
    {
        zbr::teams::update_requested_team(currentReliableXUID, team);
    }

    return result;
}

MDT_Define_FASTCALL(PTR_HandleClientReliableData, HandleClientReliableData_hook, void, (__int32 controllerIndex, netadr_t fromAdr, __int64 fromXUID, __int64 lobbyMsg))
{
    currentReliableXUID = fromXUID;
    MDT_ORIGINAL(HandleClientReliableData_hook, (controllerIndex, fromAdr, fromXUID, lobbyMsg));
}

MDT_Define_FASTCALL(REBASE(0x225B990), SV_SnapshotRateHeuristic_hook, __int32, ())
{
    *(__int32*)REBASE(0x176F9BC8) = 1;
    return ZBR_TICKRATE;
}

damage3d_event events_cache[ZBR_MAX_3DDAMAGE_EVENTS];

MDT_Define_FASTCALL(PTR_CL_ParseSnapshot, CL_ParseSnapshot_hook, void, (__int32 localClientNum, msg_t* msg))
{
    unsigned char res = ((unsigned char(__fastcall*)(__int64))PTR_MSG_ReadByte)((__int64)msg);
    if (res != 0x9A)
    {
        *(__int32*)((char*)msg + 36) = *(__int32*)((char*)msg + 36) - 1; // unread this byte, we somehow ended up with a snapshot without our expected prefix
        SPOOFED_CALL(((void(__fastcall*)(__int32 localClientNum, msg_t * msg))MDT_ORIGINAL_PTR(CL_ParseSnapshot_hook)), localClientNum, msg);
        return;
    }

    unsigned char numEntries = ((unsigned char(__fastcall*)(__int64))PTR_MSG_ReadByte)((__int64)msg);
    unsigned char remaining = 0;
    if (numEntries > ZBR_MAX_3DDAMAGE_EVENTS)
    {
        remaining = numEntries - ZBR_MAX_3DDAMAGE_EVENTS;
        numEntries = ZBR_MAX_3DDAMAGE_EVENTS;
    }

    ((void(__fastcall*)(__int64, void*, int))PTR_MSG_ReadData)((__int64)msg, events_cache, numEntries * sizeof(damage3d_event));
    zbr::damage3d_handle_snapshot(localClientNum, events_cache, numEntries);

    if (remaining)
    {
        ((void(__fastcall*)(__int64, void*, int))PTR_MSG_ReadData)((__int64)msg, events_cache, remaining * sizeof(damage3d_event));
    }
    
    unsigned char result = ((unsigned char(__fastcall*)(__int64))PTR_MSG_ReadByte)((__int64)msg); // read original prefix 12
    if (result != 12)
    {
        return;
    }

    SPOOFED_CALL(((void(__fastcall*)(__int32 localClientNum, msg_t * msg))MDT_ORIGINAL_PTR(CL_ParseSnapshot_hook)), localClientNum, msg);
}

MDT_Define_FASTCALL(PTR_SV_WriteSnapshotToClient, SV_WriteSnapshotToClient_hook, void, (void* client, msg_t* msg, const bool sendEntities, const bool writeClientsAndOtherData))
{
    ((void(__fastcall*)(__int64, unsigned char))PTR_MSG_WriteByte)((__int64)msg, (unsigned char)12);
    ((void(__fastcall*)(__int64, unsigned char))PTR_MSG_WriteByte)((__int64)msg, (unsigned char)0x9A);

    unsigned int count = 0;
    int cindex = ((__int64)client - *(__int64*)PTR_SvsStaticClients) / 0xE5170;
    zbr::damage3d_get_events(events_cache, count, cindex);

    ((void(__fastcall*)(__int64, unsigned char))PTR_MSG_WriteByte)((__int64)msg, (unsigned char)count);

    if (count)
    {
        ((void(__fastcall*)(msg_t*, void*, int))PTR_MSG_WriteData)(msg, events_cache, count * sizeof(damage3d_event));
    }

    MDT_ORIGINAL(SV_WriteSnapshotToClient_hook, (client, msg, sendEntities, writeClientsAndOtherData));
}
#endif

MDT_Define_FASTCALL(PTR_LiveStats_AreStatsDeltasValid, LiveStats_AreStatsDeltasValid_hook, int, ())
{
    return 0;
}

MDT_Define_FASTCALL(PTR_LiveStats_DoSecurityChecksCmd, LiveStats_DoSecurityChecksCmd_hook, void, ())
{
    // dont do security checks
}

MDT_Define_FASTCALL(PTR_Jump_ApplySlowdown, Jump_ApplySlowdown_hook, void, ())
{
    // dont
}

MDT_Define_FASTCALL(REBASE(0x1F120F0), Lua_CoD_LuaStateManager_HKSLog_hook, void, (lua_State* luaVM, const char* formatString, ...))
{
    va_list argptr;
    va_start(argptr, formatString);
    ALOG(formatString, argptr);
    va_end(argptr);
}

MDT_Define_FASTCALL(REBASE(0x1D49180), hksDefaultLogger_hook, void, (lua_State* luaVM, const char* formatString, ...))
{
    va_list argptr;
    va_start(argptr, formatString);
    ALOG(formatString, argptr);
    va_end(argptr);
}

MDT_Define_FASTCALL(REBASE(0xA7570), BG_Cache_CheckForChecksumMismatchForClient_hook, void, (unsigned int clientnum))
{

}

// TODO: trigger_high_performance_gpu_switch
//MDT_Define_FASTCALL(OFFSET(0x1AEF870), Scr_AreTexturesLoaded_hook, __int64, ())
//{
//    // TODO: enable/disable and scr_addint(0, 1)
//    return 0;
//}

class registry_key
{
public:
    registry_key() = default;

    registry_key(HKEY key)
        : key_(key)
    {
    }

    registry_key(const registry_key&) = delete;
    registry_key& operator=(const registry_key&) = delete;

    registry_key(registry_key&& obj) noexcept
        : registry_key()
    {
        this->operator=(std::move(obj));
    }

    registry_key& operator=(registry_key&& obj) noexcept
    {
        if (this != obj.GetRef())
        {
            this->~registry_key();
            this->key_ = obj.key_;
            obj.key_ = nullptr;
        }

        return *this;
    }

    ~registry_key()
    {
        if (this->key_)
        {
            RegCloseKey(this->key_);
        }
    }

    operator HKEY() const
    {
        return this->key_;
    }

    operator bool() const
    {
        return this->key_ != nullptr;
    }

    HKEY* operator&()
    {
        return &this->key_;
    }

    registry_key* GetRef()
    {
        return this;
    }

    const registry_key* GetRef() const
    {
        return this;
    }

private:
    HKEY key_{};
};

std::vector<std::string> str_split(const std::string& s, const char delim)
{
    std::stringstream ss(s);
    std::string item;
    std::vector<std::string> elems;

    while (std::getline(ss, item, delim))
    {
        elems.push_back(item); // elems.push_back(std::move(item)); // if C++11 (based on comment from @mchiasson)
    }

    return elems;
}

registry_key open_or_create_registry_key(const HKEY base, const std::string& input)
{
    const auto parts = str_split(input, '\\');

    registry_key current_key = base;

    for (const auto& part : parts)
    {
        registry_key new_key{};
        if (RegOpenKeyExA(current_key, part.data(), 0,
            KEY_ALL_ACCESS, &new_key) == ERROR_SUCCESS)
        {
            current_key = std::move(new_key);
            continue;
        }

        if (RegCreateKeyExA(current_key, part.data(), 0, nullptr, REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS,
            nullptr, &new_key, nullptr) != ERROR_SUCCESS)
        {
            return {};
        }

        current_key = std::move(new_key);
    }

    return current_key;
}

#define ScrVar_AllocArray(inst) ((__int32(__fastcall*)(__int32))REBASE(0x12D9480))(inst)
#define ScrVar_Type(inst, top_id) ((__int32(__fastcall*)(__int32, __int32))REBASE(0x12E0CF0))(inst, top_id)
#define ScrVar_ReleaseValue(inst, value_ptr) ((void(__fastcall*)(__int32, __int64))REBASE(0x12E0010))(inst, value_ptr)
#define ScrVar_AddRefVariable(inst, var) ((void(__fastcall*)(__int32, __int32))REBASE(0x12D93C0))(inst, var)
#define ScrVar_ReleaseVariable(inst, var) ((void(__fastcall*)(__int32, __int32))REBASE(0x12E0170))(inst, var)
void VM_SafeCreateLocalVariablesArrayHook(__int32 inst, __int32 top_id, __int64 fs_0, __int32 testCond)
{
    __int64* returnAddy = (__int64*)_AddressOfReturnAddress();
    *returnAddy = REBASE(0x12CEA03);

    if (testCond == 1 && ScrVar_Type(inst, top_id) == 25)
    {
        return;
    }

#ifdef IS_DEV
    INT64* ip = 0;
    const char* name = 0;
    report_script_error(inst, "non-array passed to reference parameter. defaulting to empty array", ip, name);
#endif

    __int32 var_index = ScrVar_AllocArray(inst);
    ScrVar_ReleaseValue(inst, *(__int64*)(fs_0 + 8));
    *(__int64*)(fs_0 + 8) -= 16;
    *(__int32*)(*(__int64*)(fs_0 + 8) + 24) = 1;
    *(__int32*)(*(__int64*)(fs_0 + 8) + 16) = var_index;
    ScrVar_AddRefVariable(inst, var_index);
    *(__int64*)(fs_0 + 8) += 16;
    ScrVar_ReleaseVariable(inst, var_index);
}

typedef unsigned char _BYTE;
typedef unsigned __int64 _QWORD;
typedef unsigned __int32 _DWORD;
#define PM_Accelerate(a1, a2, a3, a4, a5) ((void(__fastcall*)(__int64, __int64, vec3_t, float, float))PM_Accelerate_f)(a1, a2, a3, a4, a5)
MDT_Define_FASTCALL(PM_DoSlideAdjustments_f, PM_DoSlideAdjustments_hook, void, (__int64 a1, __int64 a2))
{
    float v4; // xmm7_4
    float v5; // xmm8_4
    float v6; // xmm0_4
    float v7; // xmm2_4
    float v8; // xmm3_4
    float v9; // xmm7_4
    float v10; // xmm8_4
    float v11; // xmm9_4
    float v12; // xmm11_4
    float v13; // xmm0_4
    float v14; // xmm0_4
    float v15; // xmm8_4
    float v16; // xmm7_4
    float v17; // xmm9_4
    float v18; // xmm11_4
    float v19; // xmm0_4
    vec3_t v20; // [rsp+30h] [rbp-88h] BYREF

    vec3_t ps_vel_copy;
    ps_vel_copy.v.x = *(float*)(a1 + 60);
    ps_vel_copy.v.y = *(float*)(a1 + 64);
    ps_vel_copy.v.z = *(float*)(a1 + 68);

    if ((*(_BYTE*)(a2 + 84) & 2) != 0)
    {
        v4 = *(float*)(a2 + 64);
        v5 = *(float*)(a2 + 68);
        v6 = sqrtf((float)((float)(v5 * v5) + (float)(v4 * v4)) + (float)(0.0 * 0.0));
        v7 = v6;
        if ((float)-v6 >= 0.0)
            v7 = 1.0;
        v20.v.z = (float)(1.0 / v7) * 0.0;
        v20.v.x = v4 * (float)(1.0 / v7);
        v20.v.y = v5 * (float)(1.0 / v7);
        v8 = 300.0f; // player_sliding_wishspeed (doesnt do shit? sprint_capSpeedEnabled)
        PM_Accelerate(a1, a2, v20, v8, 2.0f);
    }
    else
    {
        if ((*(_QWORD*)(a1 + 16) & 0x8000000000000ll) == 0 || !*(_DWORD*)(a2 + 100))
            return;
        v9 = *(float*)(a2 + 64);
        v10 = *(float*)(a2 + 68);
        v11 = *(float*)(a1 + 60) * 0.0066666668;
        v12 = *(float*)(a1 + 64) * 0.0066666668;
        v13 = sqrtf((float)((float)(v10 * v10) + (float)(v9 * v9)) + (float)(0.0 * 0.0));
        if ((float)-v13 >= 0.0)
            v13 = 1.0;
        v20.v.z = (float)((float)((float)((float)(1.0 / v13) * 0.0) * 2.0) + 0.0) * 0.333;
        v20.v.x = (float)((float)((float)(v9 * (float)(1.0 / v13)) * 2.0) + v11) * 0.333;
        v20.v.y = (float)((float)((float)(v10 * (float)(1.0 / v13)) * 2.0) + v12) * 0.333;
        PM_Accelerate(a1, a2, v20, 1000.0, 0.25);
        v14 = 300.0f; // player_sliding_velocity_cap
        v15 = *(float*)(a1 + 64);
        v16 = *(float*)(a1 + 60);
        v17 = *(float*)(a1 + 68);
        v18 = v14;
        v19 = sqrtf((float)((float)(v16 * v16) + (float)(v15 * v15)) + (float)(v17 * v17));
        if (v19 > (float)(v18 * v18))
        {
            *(float*)(a1 + 60) = ps_vel_copy.v.x;
            *(float*)(a1 + 68) = ps_vel_copy.v.z;
            *(float*)(a1 + 64) = ps_vel_copy.v.y;
        }
    }
    //v14 = 500.0f; // player_sliding_velocity_cap
    //v15 = *(float*)(a1 + 64);
    //v16 = *(float*)(a1 + 60);
    //v17 = *(float*)(a1 + 68);
    //v18 = v14;
    //v19 = sqrtf((float)((float)(v16 * v16) + (float)(v15 * v15)) + (float)(v17 * v17));
    //if (v19 > (float)(v18 * v18))
    //{
    //    *(float*)(a1 + 60) = ps_vel_copy.v.x;
    //    *(float*)(a1 + 68) = ps_vel_copy.v.z;
    //    *(float*)(a1 + 64) = ps_vel_copy.v.y;
    //}
}

__int64 __cached__pm = 0;
float __cached_cmdscale = 0.0f;
char __cached_cmd[2];
float cached_debug_value = 0.0f;
MDT_Define_FASTCALL(PM_CmdScale_f, PM_CmdScale_hook, float, (__int64 ps, __int64 cmd)) // ps cmd
{
    auto r = MDT_ORIGINAL(PM_CmdScale_hook, (ps, cmd));
    if ((__int64)_ReturnAddress() != REBASE(0x26882D7))
    {
        return r;
    }
    // (pmove_t_32 *pm, usercmd_t *cmd)
    __cached_cmdscale = ((float(__fastcall*)(__int64, __int64))REBASE(0x268A7A0))(__cached__pm, cmd); // this is the issue, cached_pm has an invalid playerstate or something
    return r; // pm cmd
}

MDT_Define_FASTCALL(PM_AirMove_f, PM_AirMove_hook, void, (__int64 pm, __int64 pml))
{
    __cached__pm = pm;
    __cached_cmd[0] = *((char*)pm + 64);
    __cached_cmd[1] = *((char*)pm + 65);
    MDT_ORIGINAL(PM_AirMove_hook, (pm, pml));
}

std::unordered_map<__int64, unsigned __int64> player_jumping_times;
MDT_Define_FASTCALL(PM_Accelerate_f, PM_Accelerate_hook, void, (__int64 ps, __int64 pml, vec3_t wishdir, float wishspeed, float accel))
{
    if ((__int64)_ReturnAddress() != REBASE(0x2688490))
    {
        if ((__int64)_ReturnAddress() != REBASE(0x2693845))
        {
            MDT_ORIGINAL(PM_Accelerate_hook, (ps, pml, wishdir, wishspeed, accel));
            return;
        }

        MDT_ORIGINAL(PM_Accelerate_hook, (ps, pml, wishdir, wishspeed, accel * (10 / 9)));
        return;
    }

    vec3_t* cv = (vec3_t*)(ps + 60);
    auto speed = sqrt(cv->v.x * cv->v.x + cv->v.y * cv->v.y);
    auto faccel = accel;
    auto wishspeed2 = wishspeed;
    if (speed < 150 && (*(char*)(ps + 16) >= 0))
    {
        faccel *= 4;
        wishspeed2 = wishspeed + 170;
    }

    MDT_ORIGINAL(PM_Accelerate_hook, (ps, pml, wishdir, wishspeed2, faccel));
}

MDT_Define_FASTCALL(REBASE(0x268C6B0), PM_Friction_hook, void, (__int64 pml, __int64 pm))
{
    __cached__pm = pm;
    auto ps = *(__int64*)__cached__pm;
    auto pm_flags = *(__int64*)(ps + 16);
    bool is_in_air = ((bool(__fastcall*)(__int64, __int64))REBASE(0x268D9D0))(pm, pml); // isinair
    if (is_in_air)
    {
        player_jumping_times[ps] = GetTickCount64();
    }
    MDT_ORIGINAL(PM_Friction_hook, (pml, pm));
}

#if !IS_PATCH_ONLY
MDT_Define_FASTCALL(REBASE(0x267D010), BG_GetFriction_hook, float, ())
{
    if ((__int64)_ReturnAddress() != REBASE(0x268C842) || !__cached__pm)
    {
        return 5.5;
    }

    auto ps = *(__int64*)__cached__pm;
    vec3_t* cv = (vec3_t*)(ps + 60);

    if (*(char*)(ps + 16) < 0)
    {
        return 5.5;
    }

    if (cv->v.x * cv->v.x + cv->v.y * cv->v.y < ZBR_BHOP_FRICTION_MIN_VELSQ)
    {
        return 5.5;
    }

    if (player_jumping_times.find(ps) == player_jumping_times.end())
    {
        return 5.5;
    }

    auto now = GetTickCount64();
    if (now - player_jumping_times[ps] > ZBR_BHOP_GRACE)
    {
        return 5.5;
    }

    return 0.0;
}

MDT_Define_FASTCALL(PM_ClampViewAngles_f, PM_ClampViewAngles_hook, void, (__int64 a1, __int64 a2, __int64 a3, __int32 a4))
{
    if (a4 == 20)
    {
        return;
    }
    MDT_ORIGINAL(PM_ClampViewAngles_hook, (a1, a2, a3, a4));
}

MDT_Define_FASTCALL(Jump_ReduceFriction_f, Jump_ReduceFriction_hook, float, (__int64 a1))
{
    if (*(int*)(a1 + 36) > 1000)
    {
        *(_QWORD*)(a1 + 16) &= 0xFFFFFFFFFFFBFFFFu;
        *(_DWORD*)(a1 + 276) = 0;
    }
    return 1.0;
}

MDT_Define_FASTCALL(REBASE(0x268ABA0), PM_CrashLand_hook, void, (__int64 pm, __int64 pml))
{
    auto ps = *(__int64*)pm;
    vec3_t cv = *(vec3_t*)(ps + 60);
    cv.v.z = 0;
    MDT_ORIGINAL(PM_CrashLand_hook, (pm, pml));
    *(vec3_t*)(ps + 60) = cv;
}

MDT_Define_FASTCALL(REBASE(0x2687880), BG_GetViewDip_hook, int, (__int64 a1, float a2))
{
    return 0;
}

#if DEV_DRAWVELOCITY_DEBUG
char dev_playervel_buff[512]{ 0 };

MDT_Define_FASTCALL(REBASE(0x2698B70), Pmove_1_hook, __int64, (__int64 pm))
{
    auto r = MDT_ORIGINAL(Pmove_1_hook, (pm));
    auto ps = *(__int64*)pm;
    auto client = *(__int32*)ps;

    if (!client)
    {
        vec3_t* cv = (vec3_t*)(ps + 60);
        sprintf(dev_playervel_buff, "velocity: %f (%f, %f, %f) -- %f :: target: %f :: pm_flags %p", sqrtf(cv->v.x * cv->v.x + cv->v.y * cv->v.y + cv->v.z * cv->v.z), cv->v.x, cv->v.y, cv->v.z, __cached_cmdscale, cached_debug_value, *(__int64*)(pm + 16));
    }

    return r;
}
#endif

MDT_Define_FASTCALL(REBASE(0x1CDAE90), R_EndFrame_hook, void, ())
{
#if DEV_DRAWVELOCITY_DEBUG
    unsigned __int64 font1 = ((unsigned __int64 (__fastcall*)())REBASE(0x1CAC8E0))();
    if (!font1) return;
    float scale = 0.45f;
    float color[4] = { 0.0f, 1.0f, 0.0f, 1.0f };
    ((void(__fastcall*)(const char*, unsigned __int32, unsigned __int64, float, float, float, float, float, const float*, unsigned __int32))REBASE(0x1CD98D0))(dev_playervel_buff, 0x7FFFFFFF, font1, 40.0, (float)((__int32*)(font1))[2] * scale + 180.0, scale, scale, 0.0f, color, 0);
#endif

    zbr::weapons::debug_draw();

    MDT_ORIGINAL(R_EndFrame_hook, ());
}

bool b_enable_clamped_hvel = false;
MDT_Define_FASTCALL(REBASE(0x26761B0), Jump_ClampHorizontalVelocity_hook, void, (__int64 pm))
{
    if (b_enable_clamped_hvel)
    {
        MDT_ORIGINAL(Jump_ClampHorizontalVelocity_hook, (pm));
    }
}

MDT_Define_FASTCALL(REBASE(0x2676830), Jump_Start_hook, void, (__int64 pm, __int64 pml, float height))
{
    auto ps = *(__int64*)pm;
    b_enable_clamped_hvel = *(char*)(ps + 16) < 0;
    MDT_ORIGINAL(Jump_Start_hook, (pm, pml, height));
}

#endif

void trigger_high_performance_gpu_switch()
{
#if !IS_PATCH_ONLY
    const auto key = open_or_create_registry_key(HKEY_CURRENT_USER, R"(Software\Microsoft\DirectX\UserGpuPreferences)");
    if (!key)
    {
        return;
    }

    char path_name[MAX_PATH];
    GetModuleFileName(0, path_name, MAX_PATH);
    if (RegQueryValueEx(key, path_name, nullptr, nullptr, nullptr, nullptr) != ERROR_FILE_NOT_FOUND)
    {
        return;
    }

    RegSetValueEx(key, path_name, 0, REG_SZ, (const BYTE*)"GpuPreference=2;", strlen("GpuPreference=2;") + 1);
#endif
}

MDT_Define_FASTCALL(REBASE(0x12DF3C0), ScrVar_InitVariables_hook, void, (int scriptInst))
{
    if (REBASE(0x12E0C30) == (__int64)_ReturnAddress())
    {
        return; // why do they free variables when they are shutting down the process??? it makes NO SENSE LMAO
    }

    MDT_ORIGINAL(ScrVar_InitVariables_hook, (scriptInst));

    UINT64* llpScrVarMemPool = (UINT64*)((char*)OFF_ScrVarGlob + 128 + (scriptInst << 8));
    int count = GSCBuiltins::get_new_vm_var_count(scriptInst);
    memset((void*)*llpScrVarMemPool, 0, sizeof(ScrVar_t) * count);
    ScrVar_t* currentRef = (ScrVar_t*)(*llpScrVarMemPool);
    for (int i = 0; i < count; i++)
    {
        currentRef->value.type = VAR_FREE;
        currentRef[i].o.size = i + 1;
        currentRef++;
    }
    currentRef--;
    currentRef->o.size = 0;
}

MDT_Define_FASTCALL(REBASE(0x2C468FC), ExitProcessFatal_hook, void, (unsigned __int32 errorcode))
{
    if (errorcode)
    {
        *(__int32*)0x20 = 0;
        __debugbreak();
    }
    ALOG("Exit requested with 0 error code");
    MDT_ORIGINAL(ExitProcessFatal_hook, (errorcode));
}

MDT_Define_FASTCALL(REBASE(0x2C468B8), ExitProcessFatal_hook2, void, (unsigned __int32 errorcode))
{
    if (errorcode)
    {
        *(__int32*)0x21 = 0;
        __debugbreak();
    }
    ALOG("Exit requested with 0 error code");
    MDT_ORIGINAL(ExitProcessFatal_hook2, (errorcode));
}

MDT_Define_FASTCALL(REBASE(0x2C5AFF4), ExitProcessFatal_hook3, void, (unsigned __int32 errorcode))
{
    if (errorcode)
    {
        *(__int32*)0x22 = 0;
        __debugbreak();
    }
    ALOG("Exit requested with 0 error code");
    MDT_ORIGINAL(ExitProcessFatal_hook3, (errorcode));
}

#if !IS_PATCH_ONLY
MDT_Define_FASTCALL(REBASE(0x20D5020), mods_is_mod_loaded_hook, bool, (__int32 a1))
{
    if ((__int64)_ReturnAddress() != REBASE(0x142508A))
    {
        return MDT_ORIGINAL(mods_is_mod_loaded_hook, (0));
    }
    auto res = MDT_ORIGINAL(mods_is_mod_loaded_hook, (0));
    if (!a1 && zbr::zone::loading_custom_zone)
    {
        zbr::zone::loading_custom_zone--;
        return res;
    }
    return (a1 & 0x140) && res;
}

MDT_Define_FASTCALL(REBASE(0x1421570), DB_FreeUnusedResources_hook, void, (bool a1, bool a2))
{
    MDT_ORIGINAL(DB_FreeUnusedResources_hook, (a1, a2));
    if (!zbr::zone::unloading_custom_zone)
    {
        return;
    }
    zbr::zone::unloading_custom_zone--;
    ((void(__fastcall*)(__int32, __int32))REBASE(0x1425950))(ZBR_ZONE_FREEFLAGS_HACK, ZBR_ZONE_FREEFLAGS_HACK); // DB_UnloadXAssetsMemoryForZone
}

MDT_Define_FASTCALL(REBASE(0x14236A0), DB_LoadXAssets_hook, void, (__int64* zoneInfo, __int32 count, __int32 a3, __int32 a4))
{
    MDT_ORIGINAL(DB_LoadXAssets_hook, (zoneInfo, count, a3, a4));
    zbr::zone::load_custom_assets_initial();
}

const char* lc_include_maps[] = { "zm_tomb" };
MDT_Define_FASTCALL(REBASE(0x1423A50), DB_LoadXZone_hook, void, (__int64 _zoneinfo, unsigned __int32 zonecount))
{
    for (int i = 0; i < zonecount; i++)
    {
        auto zi = (0x28 * i) + _zoneinfo;
            
        /*if (*(char**)zi)
        {
            ALOG("^5DEBUG: %s %d", *(char**)zi, *(char*)OFF_s_runningUILevel);
        }*/

        /*if (*(char**)zi && (strstr(*(char**)zi, "zm_") == *(char**)zi) && !*(char*)OFF_s_runningUILevel && !strstr(*(char**)zi, "_patch") && !strstr(*(char**)zi, "levelcommon"))
        {
            auto var = Dvar_FindVar("mapname");

            if (var)
            {
                const char* mapname = Dvar_GetVariantString(var);
                auto map = fnv1a(mapname);
                switch (map)
                {
                    case FNV32("zm_outbreak_mechanics"):
                        ALOG("^5DEBUG: VAE VICTIS SOUND EXPAND");
                        zbr::zone::expand_sounds();
                    break;
                }
            }
        }*/

        // (strstr(*(char**)zi, "zm_tomb") == *(char**)zi)
        if (*(char**)zi && (((strstr(*(char**)zi, "mp_") == *(char**)zi) && !strstr(*(char**)zi, "mp_common") && !strstr(*(char**)zi, "mp_patch"))))
        {
            ALOG("^5DEBUG: LOADING LEVELCOMMON");
            __int64 zoneinfo[7 * 2]{ 0 };
            zoneinfo[0] = (__int64)"zm_levelcommon";
            zoneinfo[1] = 0x20000200;

            zbr::zone::expand_sounds();

            ((void(__fastcall*)(__int64*, __int32, __int32, __int32))REBASE(0x14236A0))(zoneinfo, 1, 1, 0); // DB_LoadXAssets
        }
        if (*(char**)zi && (((strstr(*(char**)zi, "mp_") == *(char**)zi) && !strstr(*(char**)zi, "mp_common") && !strstr(*(char**)zi, "mp_patch"))))
        {
            ALOG("^5DEBUG: LOADING MPCOMMON");
            __int64 zoneinfo[7 * 2]{ 0 };
            zoneinfo[0] = (__int64)"mp_patch";
            zoneinfo[1] = 0x4000000;

            ((void(__fastcall*)(__int64*, __int32, __int32, __int32))REBASE(0x14236A0))(zoneinfo, 1, 1, 0); // DB_LoadXAssets
        }
        if (*(char**)zi && (((strstr(*(char**)zi, "mp_") == *(char**)zi) && !strstr(*(char**)zi, "mp_common") && !strstr(*(char**)zi, "mp_patch"))))
        {
            ALOG("^5DEBUG: LOADING MPCOMMON");
            __int64 zoneinfo[7 * 2]{ 0 };
            zoneinfo[0] = (__int64)"mp_common";
            zoneinfo[1] = 0x2000000;

            ((void(__fastcall*)(__int64*, __int32, __int32, __int32))REBASE(0x14236A0))(zoneinfo, 1, 1, 0); // DB_LoadXAssets
        }
        //if (*(char**)zi && (strstr(*(char**)zi, "zm_") == *(char**)zi) && !*(char*)OFF_s_runningUILevel && !strstr(*(char**)zi, "_patch") && !strstr(*(char**)zi, "levelcommon"))
        //{
        //    ALOG("^5DEBUG: LOADING");
        //    __int64 zoneinfo[7 * 2]{ 0 };
        //    zoneinfo[0] = (__int64)"core_specialists";
        //    zoneinfo[1] = 0x8002000;

        //    ((void(__fastcall*)(__int64*, __int32, __int32, __int32))REBASE(0x14236A0))(zoneinfo, 1, 1, 0); // DB_LoadXAssets
        //}
        if (*(char**)zi && (strstr(*(char**)zi, "cp_doa_bo3") == *(char**)zi) && !*(char*)OFF_s_runningUILevel && !strstr(*(char**)zi, "_patch") && !strstr(*(char**)zi, "levelcommon"))
        {
            ALOG("^5DEBUG: LOADING CPPATCH");
            __int64 zoneinfo[7 * 2]{ 0 };
            zoneinfo[0] = (__int64)"cp_patch";
            zoneinfo[1] = 0x4000000;

            ((void(__fastcall*)(__int64*, __int32, __int32, __int32))REBASE(0x14236A0))(zoneinfo, 1, 1, 0); // DB_LoadXAssets
        }
        if (*(char**)zi && (strstr(*(char**)zi, "cp_doa_bo3") == *(char**)zi) && !*(char*)OFF_s_runningUILevel && !strstr(*(char**)zi, "_patch") && !strstr(*(char**)zi, "levelcommon"))
        {
            ALOG("^5DEBUG: LOADING LEVELCOMMON");
            __int64 zoneinfo[7 * 2]{ 0 };
            zoneinfo[0] = (__int64)"zm_levelcommon";
            zoneinfo[1] = 0x20000200;

            ((void(__fastcall*)(__int64*, __int32, __int32, __int32))REBASE(0x14236A0))(zoneinfo, 1, 1, 0); // DB_LoadXAssets
        }
        if (*(char**)zi && (strstr(*(char**)zi, "cp_doa_bo3") == *(char**)zi) && !*(char*)OFF_s_runningUILevel && !strstr(*(char**)zi, "_patch") && !strstr(*(char**)zi, "levelcommon"))
        {
            ALOG("^5DEBUG: LOADING CPCOMMON");
            __int64 zoneinfo[7 * 2]{ 0 };
            zoneinfo[0] = (__int64)"cp_common";
            zoneinfo[1] = 0x2000000;

            ((void(__fastcall*)(__int64*, __int32, __int32, __int32))REBASE(0x14236A0))(zoneinfo, 1, 1, 0); // DB_LoadXAssets
        }
    }

    MDT_ORIGINAL(DB_LoadXZone_hook, (_zoneinfo, zonecount));
}

MDT_Define_FASTCALL(REBASE(0x1421E70), DB_GetZonePriority_hook, __int64, (__int32 a1))
{
    if (!a1)
    {
        return 1411;
    }
    if (a1 == 0x8000040)
    {
        return 1411;
    }
    return MDT_ORIGINAL(DB_GetZonePriority_hook, (a1));
}

MDT_Define_FASTCALL(REBASE(0x2149110), Com_Quit_hook, void, ())
{
    quitting = true;
    zbr::profile::profile_flush();
    MDT_ORIGINAL(Com_Quit_hook, ());
}

MDT_Define_FASTCALL(PTR_BG_GetCustomizationTableNameForSessionMode, BG_GetCustomizationTableNameForSessionMode_hook, const char*, (int a1))
{
    auto r = MDT_ORIGINAL(BG_GetCustomizationTableNameForSessionMode_hook, (a1));
    if (strstr(r, "zm"))
    {
        return "zm_character_customization";
    }
    return r;
}

MDT_Define_FASTCALL(PTR_Sys_Error, Sys_Error_hook, void, (const char* fmt, ...))
{
    va_list args;
    va_start(args, fmt);
    char buff[4096]{ 0 };

    vsnprintf(buff, 4096, fmt, args);
    ALOG("^1CRITICAL ERROR: %s", buff);

    zbr::dvar_bypass_writeable(true);
    Dvar_SetFromStringByName("com_disable_popups", "0", true);
    zbr::dvar_bypass_writeable(false);

    MDT_ORIGINAL(Sys_Error_hook, (buff));
}

MDT_Define_FASTCALL(OFF_Dvar_SetFloat, Dvar_SetFloat_hook, void, (__int64 ptr, float value))
{
    if (ptr == *(__int64*)REBASE(0x4A31A78) && *(unsigned char*)OFF_s_runningUILevel)
    {
        value = 120.0;
    }
    SPOOFED_CALL(((void(__fastcall*)(__int64, float))MDT_ORIGINAL_PTR(Dvar_SetFloat_hook)), ptr, value);
}

MDT_Define_FASTCALL(REBASE(0x858800), GetDefaultFOV_hook, float, (int a1))
{
    if (*(unsigned char*)OFF_s_runningUILevel)
    {
        return 120.0;
    }
    return MDT_ORIGINAL(GetDefaultFOV_hook, (a1));
}

// TODO: hook sd_alloc and sd_free such that when sd_alloc fails we return our own allocator management and sd_free does our own free

MDT_Define_FASTCALL(PTR_CG_UpdatePlayerDObj, CG_UpdatePlayerDObj_hook, void, (int localClientNum, __int64 cent))
{
    SPOOFED_CALL(((void(__fastcall*)(__int32, __int64))MDT_ORIGINAL_PTR(CG_UpdatePlayerDObj_hook)), localClientNum, cent);
    auto dobj = ((__int64(__fastcall*)(__int32, __int32))PTR_Com_GetClientDObj)(*(__int16*)(cent + 1504), localClientNum);
    if (dobj)
    {
        if (!*(unsigned __int8*)(cent + 48))
        {
            ((void(__fastcall*)(__int64, __int64, __int64))PTR_CG_UpdatePhysConstraintTags)(cent, cent, dobj);
        }
    }
}

MDT_Define_FASTCALL(PTR_CM_LoadMap, CM_LoadMap_hook, void, (char* mapname, int* checksum))
{
    if (strstr(mapname, "maps/zm/mp"))
    {
        mapname[5] = 'm';
        mapname[6] = 'p';
    }

    if (strstr(mapname, "maps/zm/cp"))
    {
        mapname[5] = 'c';
        mapname[6] = 'p';
    }

    MDT_ORIGINAL(CM_LoadMap_hook, (mapname, checksum));
}

MDT_Define_FASTCALL(PTR_Com_SessionModeOrCore_GetPath, Com_SessionModeOrCore_GetPath_hook, const char*, (char* str, int len, const char* prependPath, const char* appendPath, const char* file, const char* extension))
{
    auto ret = MDT_ORIGINAL(Com_SessionModeOrCore_GetPath_hook, (str, len, prependPath, appendPath, file, extension));

    if (strstr(str, "maps/zm/mp_"))
    {
        str[5] = 'm';
        str[6] = 'p';
    }

    if (strstr(str, "maps/zm/cp_"))
    {
        str[5] = 'c';
        str[6] = 'p';
    }

    if (strstr(str, "scripts/zm/mp_"))
    {
        if (strstr(str, ".csc"))
        {
            strcpy_s(str, len, "scripts/zm/mp_mapname.csc");
        }
        else if(strstr(str, ".gsc"))
        {
            strcpy_s(str, len, "scripts/zm/mp_mapname.gsc");
        }
        else
        {
            strcpy_s(str, len, "scripts/zm/mp_mapname");
        }
    }

    if (strstr(str, "scripts/zm/cp_doa_bo3"))
    {
        if (strstr(str, ".csc"))
        {
            strcpy_s(str, len, "scripts/cp/cp_doa_bo3.csc");
        }
        else if (strstr(str, ".gsc"))
        {
            strcpy_s(str, len, "scripts/cp/cp_doa_bo3.gsc");
        }
        else
        {
            strcpy_s(str, len, "scripts/cp/cp_doa_bo3");
        }
    }

    return ret;
}

MDT_Define_FASTCALL(REBASE(0x20F6A20), Com_SessionMode_GetLevelScriptsFile_hook, const char*, (__int32 inst, char* str, __int32 len, const char* file))
{
    auto ret = MDT_ORIGINAL(Com_SessionMode_GetLevelScriptsFile_hook, (inst, str, len, file));
    
    if (strstr(str, "scripts/zm/mp_"))
    {
        if (strstr(str, ".csc"))
        {
            strcpy_s(str, len, "scripts/zm/mp_mapname.csc");
        }
        else if (strstr(str, ".gsc"))
        {
            strcpy_s(str, len, "scripts/zm/mp_mapname.gsc");
        }
        else
        {
            strcpy_s(str, len, "scripts/zm/mp_mapname");
        }
    }

    if (strstr(str, "scripts/zm/cp_doa_bo3"))
    {
        if (strstr(str, ".csc"))
        {
            strcpy_s(str, len, "scripts/cp/cp_doa_bo3.csc");
        }
        else if (strstr(str, ".gsc"))
        {
            strcpy_s(str, len, "scripts/cp/cp_doa_bo3.gsc");
        }
        else
        {
            strcpy_s(str, len, "scripts/cp/cp_doa_bo3");
        }
    }

    return ret;
}

__int64 previous_str = 0;
char* my_str_changes = 0;
MDT_Define_FASTCALL(REBASE(0x19AB150), G_ResetEntityParsePoint_hook, void, ())
{
    const char* current = ((const char*(__fastcall*)())REBASE(0x20D8DD0))();
    if (current != (const char*)previous_str)
    {
        previous_str = (__int64)current;
        if (my_str_changes)
        {
            free(my_str_changes);
            my_str_changes = 0;
        }

        if (!previous_str)
        {
            *(__int32*)REBASE(0xA0B0678) = 0;
            *(const char**)REBASE(0xA0B0668) = 0;
            *(const char**)REBASE(0xA0B0670) = 0;
            return;
        }

        const char* bonus = zbr::get_map_bonus_ents();
        auto poolsize = strlen(current) + strlen(bonus) + 1;
        my_str_changes = (char*)malloc(poolsize);
        memset(my_str_changes, 0, poolsize);

        strcat_s(my_str_changes, poolsize, current);
        strcat_s(my_str_changes, poolsize, bonus);
    }

    *(__int32*)REBASE(0xA0B0678) = 0;
    *(const char**)REBASE(0xA0B0668) = my_str_changes;
    *(const char**)REBASE(0xA0B0670) = my_str_changes;
}

MDT_Define_FASTCALL(REBASE(0x1B256E0), G_SpawnEntitiesFromString_hook, void, ())
{
    ((void(__fastcall*)())REBASE(0x19AB150))();
    MDT_ORIGINAL(G_SpawnEntitiesFromString_hook, ());
}

MDT_Define_FASTCALL(PTR_CM_LinkAllStaticModels, CM_LinkAllStaticModels_hook, void, ())
{
    zbr::dynamicmap::mod_static_models();
    MDT_ORIGINAL(CM_LinkAllStaticModels_hook, ());
}

MDT_Define_FASTCALL(PTR_R_UseWorld, R_UseWorld_hook, void, (__int64 world, __int32* checksum, __int64 savegame))
{
    zbr::dynamicmap::mod_gfx_static_models();
    MDT_ORIGINAL(R_UseWorld_hook, (world, checksum, savegame));
}

MDT_Define_FASTCALL(PTR_CL_KeyEvent, CL_KeyEvent_hook, void, (__int32 localclientnum, unsigned __int32 evt1, unsigned __int32 evt2, unsigned __int32 time))
{
    SPOOFED_CALL(((void(__fastcall*)(__int32 localclientnum, unsigned __int32 evt1, unsigned __int32 evt2, unsigned __int32 time))MDT_ORIGINAL_PTR(CL_KeyEvent_hook)), localclientnum, evt1, evt2, time);
}

MDT_Define_FASTCALL(PTR_Fire_Weapon, Fire_Weapon_hook, void, (__int64 gent, int gametime, int _event, int shotcount))
{
    if (zbr::weapons::selection.simulation_active)
    {
        zbr::weapons::debug_simulate_fired(gent, gametime, _event, shotcount);
    }
    MDT_ORIGINAL(Fire_Weapon_hook, (gent, gametime, _event, shotcount));
}

//MDT_Define_FASTCALL(PTR_GetWeaponDamageForRange1, GetWeaponDamageForRange1_hook, __int32, (__int64 wep, __int64 scr_vec3_t*, __int64 scr_vec3_t*))
//{
//    
//}

MDT_Define_FASTCALL(PTR_G_GetWeaponHitLocationMultiplier, G_GetWeaponHitLocationMultiplier_hook, float, (hitLocation_t hitLoc, __int64 weapon))
{
    if ((__int64)_ReturnAddress() != PTR_G_GetWeaponHitLocationMultiplier_RETN)
    {
        return MDT_ORIGINAL(G_GetWeaponHitLocationMultiplier_hook, (hitLoc, weapon));
    }

    if (hitLoc >= HITLOC_NUM || hitLoc < 0 || !((unsigned short)(weapon & 511)))
    {
        return 1.0;
    }

    auto modref = zbr::weapons::mods.find((unsigned short)(weapon & 511));

    if (modref == zbr::weapons::mods.end())
    {
        return MDT_ORIGINAL(G_GetWeaponHitLocationMultiplier_hook, (hitLoc, weapon));
    }

    float base = modref->second.hitloc[hitLoc];
    if (hitLoc == HITLOC_NECK || hitLoc == HITLOC_HEAD || hitLoc == HITLOC_HELMET)
    {
        base *= modref->second.headmod * ZBR_GLOBAL_WU_SCALAR;
    }
    else
    {
        base *= modref->second.bodymod * ZBR_GLOBAL_WU_SCALAR;
    }

    return base;
}
#endif

// EvalFieldVariableRef fix
// NOTE this doesnt work on customs i bet.
MDT_Define_FASTCALL(*(__int64*)(PTR_ScriptErrorHandlers + 8 * 0x11), VM_OP_EvalFieldVariableRef_ErrRecovery_hook, void, (__int32 inst, INT64* fs_0, volatile void* vmc, bool* terminate))
{
    MDT_ORIGINAL(VM_OP_EvalFieldVariableRef_ErrRecovery_hook, (inst, fs_0, vmc, terminate));
    INT64 base = (*fs_0 + 3) & 0xFFFFFFFFFFFFFFFCLL;
    *fs_0 = base + 0x4; // move past the data
}

std::vector<unsigned __int64> vm_exectimes;
MDT_Define_FASTCALL(PTR_vm_execute, vm_execute_hook, unsigned int, (__int32 inst))
{
    vm_exectimes.push_back(GetTickCount64());
    auto res = MDT_ORIGINAL(vm_execute_hook, (inst));
    vm_exectimes.pop_back();
    return res;
}

__int64 last_termination_vm_execute = 0;
void vm_execute_timer(INT32 inst, INT64* fs_0, INT64 vmc, bool* terminate, __int64 unknown, __int64 rax)
{
    //auto curr = vm_exectimes.back();
    //if (GetTickCount64() - curr >= 2000)
    //{
    //    if (GetTickCount64() - last_termination_vm_execute >= 3000)
    //    {
    //        FILE* f;
    //        f = fopen(CRASH_LOG_NAME, "a+"); // a+ (create + append)
    //        if (!f)
    //        {
    //            // we cant log??? fuck.
    //            ExitProcess(-444);
    //        }

    //        INT64* ip = 0;
    //        const char* name = 0;
    //        INT64* fs = (INT64*)SCRVM_FS;

    //        fprintf(f, "Script Exception Type: %s", (inst ? "Client" : "Server"));
    //        fprintf(f, "Script Fatal Exception at : %p\n", fs[inst * 4]);
    //        fprintf(f, "\t at: %s+%x", name, fs[inst * 4] - (INT64)ip);
    //        fprintf(f, "Error Message: %s\n", "WARNING: THREAD TERMINATED DUE TO EXCESSIVELY LONG VM_EXECUTE TIMING");

    //        // dump script context
    //        dump_script_context(f);

    //        std::fflush(f);
    //        std::fclose(f);
    //    }

    //    ALOG("^1WARNING: THREAD TERMINATED DUE TO EXCESSIVELY LONG VM_EXECUTE TIMING");

    //    // kill the thread, shes looped to death.
    //    //*terminate = true;

    //    while ((*(__int16*)(*fs_0) & 0xDFFF) != 0x10)
    //    {
    //        *fs_0 = *fs_0 + 2;
    //    }

    //    for (int i = 0; i < vm_exectimes.size(); i++)
    //    {
    //        vm_exectimes[i] = GetTickCount64();
    //    }
    //    last_termination_vm_execute = GetTickCount64();

    //    return;
    //}

    if (rax & 0x2000)
    {
        ((void(__fastcall*)(INT32 inst, INT64 * fs_0, INT64 vmc, bool* terminate)) * (__int64*)(REBASE(0x3306350) + 0x8 * ((__int32)rax & 0xDFFF)))(inst, fs_0, vmc, terminate);
    }
    else
    {
        ((void(__fastcall*)(INT32 inst, INT64 * fs_0, INT64 vmc, bool* terminate)) * (__int64*)(REBASE(0x32E6350) + 0x8 * ((__int32)rax & 0xFFFF)))(inst, fs_0, vmc, terminate);
    }
}

MDT_Define_FASTCALL(PTR_vm_execute_error_handler, vm_execute_error_handler_hook, void, (__int32 inst, INT64* fs_0, void* vmc))
{
    vm_exectimes[vm_exectimes.size() - 1] = GetTickCount64();
    MDT_ORIGINAL(vm_execute_error_handler_hook, (inst, fs_0, vmc));
}

MDT_Define_FASTCALL(GetProcAddress(GetModuleHandle("ntdll.dll"), "RtlRaiseException"), RtlRaiseException_hook, void, (PEXCEPTION_RECORD ExceptionRecord))
{
    if (ExceptionRecord->ExceptionFlags & EXCEPTION_NONCONTINUABLE)
    {
        *(__int64*)0x17 = (__int64)ExceptionRecord;
    }
    MDT_ORIGINAL(RtlRaiseException_hook, (ExceptionRecord));
}

MDT_Define_FASTCALL(REBASE(0x270AB60), UI_LuaCall_UIElement_setRGB_hook, __int32, (__int64 luaVM))
{
    auto v4 = *(_QWORD*)(luaVM + 80);
    auto v2 = *(_QWORD*)(luaVM + 72);
    auto v7 = v4 + 16;
    if (v7 >= v2)
    {
        return 0;
    }
    else
    {
        typedef const char* hks_obj_tolstring_t(__int64, __int64, __int64);
        auto f = (hks_obj_tolstring_t*)(REBASE(0x1D4B6C0));
        auto res = f(luaVM, v7, 0);
        if (!res)
        {
            return 0;
        }
    }
    return MDT_ORIGINAL(UI_LuaCall_UIElement_setRGB_hook, (luaVM));
}

//MDT_Define_FASTCALL(REBASE(0x1D4B6C0), hks_obj_tolstring_hook, const char*, (void* s, void* obj, size_t* len))
//{
//    auto res = MDT_ORIGINAL(hks_obj_tolstring_hook, (s, obj, len));
//
//    if (!res)
//    {
//        return "";
//    }
//
//    return res;
//}

#if !IS_PATCH_ONLY
MDT_Define_FASTCALL(REBASE(0xA85A0), BG_Cache_LoadTables, void, (unsigned __int32 inst))
{
    MDT_ORIGINAL(BG_Cache_LoadTables, (inst));

    auto index = zbr::zone::get_zone_id(ZBR_ZONE_CHARACTERS_CONTENTID);

    if (index < 0)
    {
        return;
    }

    zbr::zone::load_bg_cache(inst, index);
}

MDT_Define_FASTCALL(REBASE(0xACCA0), BG_Cache_LoadAssets_hook, char, (__int64 a1, __int64* a2, unsigned int* a3))
{
    if (zbr::zone::__DEBUG__)
    {
        ALOG("CALLED BG_CACHE_LOADASSETS %p %p %X", a1, *a2, *a3);
    }
    return MDT_ORIGINAL(BG_Cache_LoadAssets_hook, (a1, a2, a3));
}

MDT_Define_FASTCALL(REBASE(0x4D9570), CG_CalcFOV_hook, void, (int localclientnum, float fov))
{
    if (*(unsigned char*)OFF_s_runningUILevel)
    {
        SPOOFED_CALL(((void(__fastcall*)(__int32, float))MDT_ORIGINAL_PTR(CG_CalcFOV_hook)), localclientnum, 120.0f);
        return;
    }
    SPOOFED_CALL(((void(__fastcall*)(__int32, float))MDT_ORIGINAL_PTR(CG_CalcFOV_hook)), localclientnum, fov);
}
#endif

#if ZBR_EXTEND_CLIENTFX
#define BG_CACHE_SIZE 0x45FE00
#define CLIENTFX_EXT_SIZE 2048

struct FxEffectDef
{
    const char* name;
};

typedef const FxEffectDef* FxEffectDefHandle;

struct bgCachedFX
{
    FxEffectDefHandle def;
    int nameHash;
    unsigned char refCount;
    unsigned char pad[3];
};

bgCachedFX new_bg_cache_server[CLIENTFX_EXT_SIZE]{ 0 };
bgCachedFX new_bg_cache_client[CLIENTFX_EXT_SIZE]{ 0 };

bool already_moved_clientfx = false;
void move_old_clientfx()
{
    if (already_moved_clientfx)
    {
        return;
    }
    already_moved_clientfx = true;

    bgCachedFX* serverbase = (bgCachedFX*)REBASE(0x36C7DF0);
    bgCachedFX* clientbase = (bgCachedFX*)REBASE(0x36C7DF0 + 0x45FE00);

    for (int i = 0; i < 1024; i++)
    {
        new_bg_cache_server[i] = serverbase[i];
        new_bg_cache_client[i] = clientbase[i];
    }
}

// probably BG_Cache_Unregister_clientfx
MDT_Define_FASTCALL(REBASE(0xA4550), clientfx_function_1_hook, __int64, (int inst, char* a2))
{
    __int64* v2; // rbx
    __int64 result; // rax
    __int64 v4; // rcx
    bool v5; // zf

    bgCachedFX* hnd_fx = new_bg_cache_server;
    if (inst)
    {
        hnd_fx = new_bg_cache_client;
    }

    v2 = (__int64*)hnd_fx;
    result = ((__int64(__fastcall*)(int, int, __int64, int, char*, unsigned char))REBASE(0xA4860))(inst, 27, (__int64)hnd_fx, CLIENTFX_EXT_SIZE, a2, 0);
    v4 = 2i64 * (int)result;

    hnd_fx[result].refCount--;
    if (!hnd_fx[result].refCount)
    {
        result = 0;
        v2[v4] = 0;
        v2[v4 + 1] = 0;
    }
    return result;
}

// probably BG_Cache_GetClientFxForIndex
MDT_Define_FASTCALL(REBASE(0xA7710), clientfx_function_2_hook, __int64, (int a1, int a2))
{
    if (a1)
    {
        return (__int64)new_bg_cache_client[a2].def;
    }
    return (__int64)new_bg_cache_server[a2].def;
}

// idfk, some wrapper
MDT_Define_FASTCALL(REBASE(0xA7730), clientfx_function_3_hook, __int64, (__int64 inst, char* a2))
{
    bgCachedFX* hnd_fx = new_bg_cache_server;
    if (inst)
    {
        hnd_fx = new_bg_cache_client;
    }
    return ((__int64(__fastcall*)(int, int, __int64, int, char*, unsigned char))REBASE(0xA4860))(inst, 27, (__int64)hnd_fx, CLIENTFX_EXT_SIZE, a2, 0);
}

// BG_Cache_GetDefNameForIndex
MDT_Define_FASTCALL(REBASE(0xA7770), clientfx_function_4_hook, const char*, (int inst, int a2))
{
    if (a2 >= CLIENTFX_EXT_SIZE || a2 < 0)
    {
        return "";
    }
    bgCachedFX* hnd_fx = new_bg_cache_server;
    if (inst)
    {
        hnd_fx = new_bg_cache_client;
    }
    if (!hnd_fx[a2].def)
    {
        return "";
    }
    return hnd_fx[a2].def->name;
}

// TODO: bg cache printing function wont work with expanded pool.
MDT_Define_FASTCALL(REBASE(0xA8310), bg_cache_init_hook, void, (int inst))
{
    bgCachedFX* hnd_fx = new_bg_cache_server;
    if (inst)
    {
        hnd_fx = new_bg_cache_client;
    }

    for (int i = 0; i < CLIENTFX_EXT_SIZE; i++)
    {
        hnd_fx[i].def = 0;
        hnd_fx[i].nameHash = 0;
        hnd_fx[i].refCount = 0;
        hnd_fx[i].pad[0] = 0;
        hnd_fx[i].pad[1] = 0;
        hnd_fx[i].pad[2] = 0;
    }

    MDT_ORIGINAL(bg_cache_init_hook, (inst));
}

// BG_Cache_RegisterAndGetClientFxIndex
MDT_Define_FASTCALL(REBASE(0xA9F20), clientfx_function_5_hook, void, (int inst, const char* a2))
{
    __int64 v2; // rdi
    const char* v3; // rbx
    __int64 v4; // rax
    const char* v5; // r8
    unsigned int v6; // ecx
    __int64 result; // rax

    v3 = a2;
    v4 = DB_FindXAssetHeader(38, a2, 1, -1);
    
    bgCachedFX* hnd_fx = new_bg_cache_server;
    if (inst)
    {
        hnd_fx = new_bg_cache_client;
    }

    if (v4)
    {
        auto result = ((__int64(__fastcall*)(int, int, __int64, int, __int64, __int64))REBASE(0xA5D60))(inst, 27, (__int64)hnd_fx, CLIENTFX_EXT_SIZE, (__int64)v3, v4);
        if ((int)result > 0)
            return;
        v5 = "Unable to register client fx %s\n";
        v6 = 8;
    }
    else
    {
        v5 = "Couldn't find asset '%s'\n";
        v6 = 7;
    }
    ((__int64(__fastcall*)(unsigned int a1, unsigned int a2, const char* a3, ...))REBASE(0x2148F60))(v6, 23u, v5, v3); // Com_PrintError
}
#endif

struct GSC_STRINGTABLE_ITEM
{
    uint32_t string;
    uint8_t num_address;
    uint8_t type;
    uint8_t pad[2];
};

tVM_Opcode VM_OP_GetString_Old = NULL;
tVM_Opcode VM_OP_GetIString_Old = NULL;
tVM_Opcode VM_OP_Switch_Old = NULL;
void VM_OP_GetString(INT32 inst, INT64* fs_0, INT64 vmc, bool* terminate)
{
    INT64 base = (*fs_0 + 3) & 0xFFFFFFFFFFFFFFFCLL;
    UINT32 ptr = *(UINT32*)base;

    if (ptr & 0x80000000)
    {
        ptr &= ~0x80000000;

        //ALOG("FIXING LAZY STRING");
        
        // base + ptr should be item
        auto item = (GSC_STRINGTABLE_ITEM*)(base + ptr);
        auto str = (__int32)item->string + (const char*)item;

        //ALOG("str: %s", str);

        auto str_ref = ((unsigned __int32(__fastcall*)(const char*, unsigned int, unsigned int))REBASE(0x12D7B20))(str, 0, 0x18u); // SL_getstring
        ((void(__fastcall*)(unsigned __int32, __int32))REBASE(0x12D8C60))(str_ref, 1);

        //ALOG("ADDED TO SL 0x%x", str_ref);

        for (unsigned int i = 0; i < item->num_address; i++)
        {
            auto off = ((int32_t*)((unsigned char*)item + 8))[i];
            *(unsigned __int32*)(off + (char*)item) = str_ref;
        }

        //ALOG("ITEMS FIXED");
    }

    VM_OP_GetString_Old(inst, fs_0, vmc, terminate);
}

void VM_OP_GetIString(INT32 inst, INT64* fs_0, INT64 vmc, bool* terminate)
{
    INT64 base = (*fs_0 + 3) & 0xFFFFFFFFFFFFFFFCLL;
    UINT32 ptr = *(UINT32*)base;

    if (ptr & 0x80000000)
    {
        ptr &= ~0x80000000;

        //ALOG("FIXING LAZY STRING");

        // base + ptr should be item
        auto item = (GSC_STRINGTABLE_ITEM*)(base + ptr);
        auto str = (__int32)item->string + (const char*)item;

        //ALOG("str: %s", str);

        auto str_ref = ((unsigned __int32(__fastcall*)(const char*, unsigned int, unsigned int))REBASE(0x12D7B20))(str, 0, 0x18u); // SL_getstring
        ((void(__fastcall*)(unsigned __int32, __int32))REBASE(0x12D8C60))(str_ref, 1);

        //ALOG("ADDED TO SL 0x%x", str_ref);

        for (unsigned int i = 0; i < item->num_address; i++)
        {
            auto off = ((int32_t*)((unsigned char*)item + 8))[i];
            *(unsigned __int32*)(off + (char*)item) = str_ref;
        }

        //ALOG("ITEMS FIXED");
    }

    VM_OP_GetIString_Old(inst, fs_0, vmc, terminate);
}

void VM_OP_Switch(INT32 inst, INT64* fs_0, INT64 vmc, bool* terminate)
{
    auto type = *(__int32*)(fs_0[1] + 8);

    if (type != 2)
    {
        VM_OP_Switch_Old(inst, fs_0, vmc, terminate);
        return;
    }

    INT64 base = (*fs_0 + 3) & 0xFFFFFFFFFFFFFFFCLL;
    INT64 lpSwitchCount = (base + 4 + *(UINT32*)base);
    INT64 switchcount = *(UINT32*)(lpSwitchCount);
    
    base = lpSwitchCount + 4;
    for (int j = 0; j < switchcount; j++)
    {
        UINT32 ptr = *(UINT32*)base;
        if (ptr & 0x80000000)
        {
            ptr &= ~0x80000000;

            //ALOG("FIXING LAZY STRING");

            // base + ptr should be item
            auto item = (GSC_STRINGTABLE_ITEM*)(base + ptr);
            auto str = (__int32)item->string + (const char*)item;

            //ALOG("str: %s", str);

            auto str_ref = ((unsigned __int32(__fastcall*)(const char*, unsigned int, unsigned int))REBASE(0x12D7B20))(str, 0, 0x18u); // SL_getstring
            ((void(__fastcall*)(unsigned __int32, __int32))REBASE(0x12D8C60))(str_ref, 1);

            //ALOG("ADDED TO SL 0x%x", str_ref);

            for (unsigned int i = 0; i < item->num_address; i++)
            {
                auto off = ((int32_t*)((unsigned char*)item + 8))[i];
                *(unsigned __int32*)(off + (char*)item) = str_ref;
            }

            //ALOG("ITEMS FIXED");
        }

        base += 8;
    }

    VM_OP_Switch_Old(inst, fs_0, vmc, terminate);
}

__int64 patch_lazy_string_ref(GSC_STRINGTABLE_ITEM* item, unsigned char* prime_obj)
{
    //ALOG("PATCH LAZY STRING CALLED");

    auto itemoffset = (uint32_t)((unsigned __int64)item - (unsigned __int64)prime_obj);

    if (!(item->string & 0x80000000))
    {
        *(__int32*)&item->string = (__int32)(((__int64)prime_obj + item->string) - ((__int64)item));
    }

    for (unsigned int i = 0; i < item->num_address; i++)
    {
        auto off = ((uint32_t*)((unsigned char*)item + 8))[i];

        if (!(off & 0x80000000))
        {
            ((__int32*)((unsigned char*)item + 8))[i] = (__int32)((__int64)(prime_obj + off) - (__int64)item);
        }
        else
        {
            off = (unsigned __int32)((unsigned __int64)((__int64)item + (__int32)off) - (unsigned __int64)prime_obj);
        }

        auto rel_off = itemoffset - off;
        *(uint32_t*)(prime_obj + off) = rel_off | 0x80000000; // store the relative offset to the string table fixup
    }

    //ALOG("PATCH LAZY STRING FINISHED");
    return (__int64)item + 8 + (unsigned __int32)item->num_address * 4;
}

// WARNING: the code section must come before the ref section for this all to work!
void do_lazy_strings()
{
#if ZBR_LAZYSTRINGS
    ScriptDetours::VTableReplace(_DOFFSET(0x12CD480), VM_OP_GetString, &VM_OP_GetString_Old);
    ScriptDetours::VTableReplace(_DOFFSET(0x12CD360), VM_OP_GetIString, &VM_OP_GetIString_Old);  
    ScriptDetours::VTableReplace(_DOFFSET(0x12CDD80), VM_OP_Switch, &VM_OP_Switch_Old);

    //ALOG("INSTALLED HOOK");
    // 12CCB59 to 12CCBB5 (0x39 size)
    auto size = 0x12CCBB5 - 0x12CCB59;
    unsigned char shellcode[] = { 0x48, 0x89, 0xD9, 0x48, 0x89, 0xFA, 0x48, 0xB8, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0xFF, 0xD0, 0x48, 0x89, 0xC1 };
    auto size_shellcode = 21;
    *(__int64*)(shellcode + 8) = (__int64)patch_lazy_string_ref;
    chgmem(REBASE(0x12CCB59), size_shellcode, shellcode);
    
    //ALOG("WROTE SHELLCODE");

    for (int i = size_shellcode; i < size; i++)
    {
        chgmem<unsigned char>(REBASE(0x12CCB59) + i, (unsigned char)0x90);
    }

    //ALOG("NOPPED");

    FlushInstructionCache(GetCurrentProcess(), (LPCVOID)REBASE(0x12CCB59), size);

    //ALOG("INSTRUCTIONS FLUSHED");
#endif
}

MDT_Define_FASTCALL(REBASE(0x1B56180), SpawnSystem_LoadInfluencerPresets_hook, void, ())
{
    ((void(__fastcall*)())REBASE(0x1B4F300))(); //SpawnSystem_ClearInfluencerPresets
    auto mode = ((__int32(__fastcall*)())REBASE(0x20F6D30))(); // Com_SessionMode_GetMode
    if (mode != 3)
    {
        auto var = Dvar_FindVar("mapname");

        if (var)
        {
            const char* mapname = Dvar_GetVariantString(var);

            if (!strcmp(mapname, "cp_doa_bo3"))
            {
                mode = 2; // campaign
                // ALOG("SWITCHED MODE TO CAMPAIGN FOR SPAWN INFLUENCERS");
            }
            if (strstr(mapname, "mp_") == mapname)
            {
                mode = 1; // mp
                // ALOG("SWITCHED MODE TO CAMPAIGN FOR SPAWN INFLUENCERS");
            }
        }

        auto abbrev = ((const char*(__fastcall*)(__int32))REBASE(0x20F67E0))(mode); // Com_SessionMode_GetAbbreviationForMode
        auto influencers = ((const char* (__fastcall*)(const char*, ...))REBASE(0x22E9B70))("%s_%s", abbrev, "spawn_influencers"); // va

        // s_spawnInfluencersTable
        *(__int64*)REBASE(0xA625930) = ((__int64(__fastcall*)(const char*))REBASE(0x22AF4F0))(influencers); // StructuredTable_GetTableByName

        influencers = ((const char* (__fastcall*)(const char*, ...))REBASE(0x22E9B70))("%s_%s", abbrev, "spawn_influencers_override"); // va

        // s_spawnInfluencersOverrideTable
        *(__int64*)REBASE(0xA625938) = ((__int64(__fastcall*)(const char*))REBASE(0x22AF4F0))(influencers); // StructuredTable_GetTableByName

        if (*(__int64*)REBASE(0xA625930))
        {
            ((void(__fastcall*)(__int64, const char*, __int64, __int64))REBASE(0x22AF1D0))(*(__int64*)REBASE(0xA625930), "id", REBASE(0x1B4D050), 0);
        }

        if (*(__int64*)REBASE(0xA625938))
        {
            ((void(__fastcall*)(__int64, const char*, __int64, __int64))REBASE(0x22AF1D0))(*(__int64*)REBASE(0xA625938), "id", REBASE(0x1B4CE80), 0);
        }
    }
}

MDT_Define_FASTCALL(REBASE(0x2814EA0), UI_CustomDrawRectRot_1_hook, void, (__int64 a1/*ele*/, __int64 a2/*roo*/, float a3/*lef*/, float a4/*top*/, float a5/*rig*/, float a6/*bot*/, float a7/*red*/, float a8/*gre*/, float a9/*blu*/, float a10/*alpha*/, __int64 a11/*mat*/, float a12/*zRot*/, __int64 a13/*luavm*/))
{
    if (!a11)
    {
        return;
    }
    MDT_ORIGINAL(UI_CustomDrawRectRot_1_hook, (a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13));
}

void bypass_dev_calls()
{
    chgmem<unsigned char>(REBASE(0x12CA4E3 + 2), 0x71);
    FlushInstructionCache(GetCurrentProcess(), (LPCVOID)REBASE(0x12CA4E3), 0x10);

    chgmem<unsigned char>(REBASE(0x12CAA36 + 2), 0x71);
    FlushInstructionCache(GetCurrentProcess(), (LPCVOID)REBASE(0x12CAA36), 0x10);

    chgmem<unsigned char>(REBASE(0x12CA6EE + 2), 0x71);
    FlushInstructionCache(GetCurrentProcess(), (LPCVOID)REBASE(0x12CA6EE), 0x10);
}

struct hkArrayBase
{
    void* m_data;
    int m_size;
    int m_capacityAndFlags;
};

struct alignas(8) hkDisplaySerializeOStream
{
    unsigned char dontcare[0x20];
};

struct hkStructureLayout
{
    unsigned char m_bytesInPointer;
    unsigned char m_littleEndian;
    unsigned char m_reusePaddingOptimization;
    unsigned char m_emptyBaseClassOptimization;
};

enum hkObjectCopier_ObjectCopierFlagBits : __int32
{
    FLAG_NONE = 0x0,
    FLAG_APPLY_DEFAULT_IF_SERIALIZE_IGNORED = 0x1,
    FLAG_RESPECT_SERIALIZE_IGNORED = 0x2,
};

void old_dumpa()
{
    // lets use the navmesh settings as a POC
    auto object_handle = *(__int64*)REBASE(0x10C42218);

    auto var = Dvar_FindVar("mapname");
    const char* mapname = Dvar_GetVariantString(var);
    char xassetname[256]{ 0 };
    sprintf_s(xassetname, "maps/mp/%s_navmesh", mapname);

    auto header = DB_FindXAssetHeader(97, xassetname, 1, -1);
    auto size_navmesh_settings = *(unsigned int*)(header + 8);

    // TtgetNearbyBoundariesFlood
    // Class signatures not up to date. (hkNativePackfileUtils::load+)

    // now create a havok array
    hkArrayBase arr{ 0 };
    arr.m_capacityAndFlags = 0x80000000;


    // allocate
    // char idk = 0;
    /*((void(__fastcall*)(char&, __int64, hkArrayBase&, unsigned int, __int64))REBASE(0x2994E90))(idk, REBASE(0x365DF50), arr, size_navmesh_settings, 1);
    arr.m_size = size_navmesh_settings;*/

    // create an out stream
    hkDisplaySerializeOStream stream{ 0 };
    ((void(__fastcall*)(hkDisplaySerializeOStream&, hkArrayBase&))REBASE(0x2A61EC0))(stream, arr); // hkDisplaySerializeOStream::hkDisplaySerializeOStream "MSVC" (will be different on mac)

    // mac layout
    hkStructureLayout targetLayout;
    targetLayout.m_bytesInPointer = 8;
    targetLayout.m_littleEndian = 1;
    targetLayout.m_reusePaddingOptimization = 1;
    targetLayout.m_emptyBaseClassOptimization = 1;

    // writeObject "LtWrite Object"
    //hkObjectSerialize::writeObject(hkDisplaySerializeOStream *stream, hkReferencedObject *object, bool writePacketSize, bool writePackfile, hkStructureLayout layout, hkPlatformObjectWriter::Cache_0 *cache, hkObjectCopier::ObjectCopierFlags flags)
    ((void(__fastcall*)(hkDisplaySerializeOStream & stream, void* object, bool writePacket, bool writePackFile, hkStructureLayout layout, __int64, hkObjectCopier_ObjectCopierFlagBits))REBASE(0x2A66E70))(stream, (void*)object_handle, false, true, targetLayout, NULL, FLAG_RESPECT_SERIALIZE_IGNORED);

    if (!arr.m_size)
    {
        ALOG("COULDNT ALLOC. SOMETHING WENT WRONG");
        return;
    }

    if (arr.m_size > 0x20000000)
    {
        ALOG("TOO BIG. SOMETHING WENT WRONG");
        return;
    }

    std::ofstream ofs;
    ofs.open("test.dat", std::ofstream::out | std::ofstream::binary);
    ofs.write((const char*)arr.m_data, arr.m_size);
    ofs.close();
}

void DumpHKObjectForMac(hkArrayBase& arr, void* obj)
{
    // create an out stream
    hkDisplaySerializeOStream stream{ 0 };
    ((void(__fastcall*)(hkDisplaySerializeOStream&, hkArrayBase&))REBASE(0x2A61EC0))(stream, arr); // hkDisplaySerializeOStream::hkDisplaySerializeOStream "MSVC" (will be different on mac)

    // mac layout
    hkStructureLayout targetLayout;
    targetLayout.m_bytesInPointer = 8;
    targetLayout.m_littleEndian = 1;
    targetLayout.m_reusePaddingOptimization = 1;
    targetLayout.m_emptyBaseClassOptimization = 1;

    ((void(__fastcall*)(hkDisplaySerializeOStream & stream, void* object, bool writePacket, bool writePackFile, hkStructureLayout layout, __int64, hkObjectCopier_ObjectCopierFlagBits))REBASE(0x2A66E70))(stream, obj, false, true, targetLayout, NULL, FLAG_RESPECT_SERIALIZE_IGNORED);
}

__int64 navmesh_metadata = 0;
void Dump_Navmesh()
{
    auto var = Dvar_FindVar("mapname");
    const char* mapname = Dvar_GetVariantString(var);
    char xassetname[256]{ 0 };
    sprintf_s(xassetname, "maps/zm/%s_navmesh", mapname);

    std::ofstream ofs;
    ofs.open("navmesh.hkt", std::ofstream::out | std::ofstream::binary);

    auto header = DB_FindXAssetHeader(97, xassetname, 1, -1);
    
    // navmeshsettings
    hkArrayBase navMeshArray{ 0 };
    navMeshArray.m_capacityAndFlags = 0x80000000;
    DumpHKObjectForMac(navMeshArray, (void*)*(__int64*)REBASE(0x10C42218));
    ofs.write((const char*)(5 + (char*)navMeshArray.m_data), navMeshArray.m_size - 5);

    // useredgepairs
    hkArrayBase useredgepairs{ 0 };
    useredgepairs.m_capacityAndFlags = 0x80000000;
    DumpHKObjectForMac(useredgepairs, (void*)*(__int64*)REBASE(0x10C42230));
    ofs.write((const char*)(5 + (char*)useredgepairs.m_data), useredgepairs.m_size - 5);

    // clustergraph
    hkArrayBase clustergraph{ 0 };
    clustergraph.m_capacityAndFlags = 0x80000000;
    DumpHKObjectForMac(clustergraph, (void*)*(__int64*)REBASE(0x10C42228));
    ofs.write((const char*)(5 + (char*)clustergraph.m_data), clustergraph.m_size - 5);

    // mediator
    hkArrayBase mediator{ 0 };
    mediator.m_capacityAndFlags = 0x80000000;
    DumpHKObjectForMac(mediator, (void*)*(__int64*)REBASE(0x10C42220));
    ofs.write((const char*)(5 + (char*)mediator.m_data), mediator.m_size - 5);

    // metadata
    hkArrayBase metadata{ 0 };
    metadata.m_capacityAndFlags = 0x80000000;
    DumpHKObjectForMac(metadata, (void*)navmesh_metadata);
    ofs.write((const char*)(5 + (char*)metadata.m_data), metadata.m_size - 5);

    // clearance
    hkArrayBase clearance{ 0 };
    clearance.m_capacityAndFlags = 0x80000000;

    std::ofstream ofs2;
    ofs2.open("navmesh.debug2", std::ofstream::out | std::ofstream::binary);
    ofs2.write(*(char**)(header + 96), *(unsigned int*)(header + 88));
    ofs2.close();

    DumpHKObjectForMac(clearance, (void*)*(__int64*)REBASE(0x10C42238));
    ofs.write((const char*)(5 + (char*)clearance.m_data), clearance.m_size - 5);
    
    ofs.close();
}

void Dump_Navvolume()
{
    auto var = Dvar_FindVar("mapname");
    const char* mapname = Dvar_GetVariantString(var);
    char xassetname[256]{ 0 };
    sprintf_s(xassetname, "maps/zm/%s_navvolume", mapname);

    std::ofstream ofs;
    ofs.open("navvolume.hkt", std::ofstream::out | std::ofstream::binary);

    auto header = DB_FindXAssetHeader(98, xassetname, 1, -1);

    if (header)
    {
        // nvsettings(0)
        hkArrayBase nvsettings{ 0 };
        nvsettings.m_capacityAndFlags = 0x80000000;
        DumpHKObjectForMac(nvsettings, (void*)*(__int64*)REBASE(0x10C42260));
        ofs.write((const char*)(5 + (char*)nvsettings.m_data), nvsettings.m_size - 5);

        // nvmediator(0)
        hkArrayBase nvmediator{ 0 };
        nvmediator.m_capacityAndFlags = 0x80000000;
        DumpHKObjectForMac(nvmediator, (void*)*(__int64*)REBASE(0x10C42268));
        ofs.write((const char*)(5 + (char*)nvmediator.m_data), nvmediator.m_size - 5);

        // nvsettings(1)
        hkArrayBase nvsettings1{ 0 };
        nvsettings1.m_capacityAndFlags = 0x80000000;
        DumpHKObjectForMac(nvsettings1, (void*)*(__int64*)REBASE(0x10C42280));
        ofs.write((const char*)(5 + (char*)nvsettings1.m_data), nvsettings1.m_size - 5);

        // nvmediator(1)
        hkArrayBase nvmediator1{ 0 };
        nvmediator1.m_capacityAndFlags = 0x80000000;
        DumpHKObjectForMac(nvmediator1, (void*)*(__int64*)REBASE(0x10C42288));
        ofs.write((const char*)(5 + (char*)nvmediator1.m_data), nvmediator1.m_size - 5);
    }
    else
    {
        ALOG("NO NAV VOLUME FOR THIS LEVEL");
    }

    ofs.close();
}

MDT_Define_FASTCALL(REBASE(0x29EC330), loadInPlace_hook, __int64, (void* p, __int32 s, __int64 r, __int64 e))
{
    auto ret = MDT_ORIGINAL(loadInPlace_hook, (p, s, r, e));

    if ((__int64)_ReturnAddress() == REBASE(0x1DDD1AF))
    {
        navmesh_metadata = ret;
    }

    return ret;
}

MDT_Define_FASTCALL(PTR_getnattype, bdGetNatType_hook, int, (__int64 dw))
{
    *(__int32*)(dw + 0xA8) = 1;
    return 1; // open
}

//EXPORT void the_dumpa()
//{
//    Dump_Navmesh();
//    Dump_Navvolume();
//}

MDT_Define_FASTCALL(REBASE(0x1DF8E30), LiveFriends_GetFriendByXUID_hook, __int64, (int controllerIndex, __int64 xuid))
{
    if ((__int64)_ReturnAddress() == REBASE(0x1FE671A)) // lua IsFriendFromXUID
    {
        return Protection::IsFriendByXUIDUncached(xuid); // NOTE: this is SUPER STUPID because this function is SUPPOSED to return a pointer, but because of how this lua function works, its fine for now.
    }
    return MDT_ORIGINAL(LiveFriends_GetFriendByXUID_hook, (controllerIndex, xuid));
}


#if ZBR_DEBUG_POOL_OVERRUNS 
MDT_Define_FASTCALL(REBASE(0xA8FB0), BG_Cache_PrintValuesForType_hook, void, (int inst, int type, bool showloc))
{
    *(__int64*)(0x8) = 0;
}
#endif

#define ZBR_DEBUGGER_PTR (void*)1

void RunPatching()
{
    PROTECT_LIGHT_START("runpatching start");

    SetPriorityClass(GetCurrentProcess(), ABOVE_NORMAL_PRIORITY_CLASS);
#if !IS_PATCH_ONLY
    ((void(__fastcall*)(__int32, const char*, float, float, float, float, __int64, const char*))PTR_Dvar_Register_Color)(0x782D3B36, "", 1.0, 1.0, 1.0, 1.0, 0, ""); // 4
    ((void(__fastcall*)(__int32, const char*, float, float, float, float, __int64, const char*))PTR_Dvar_Register_Color)(0x9E2FB59F, "", 1.0, 1.0, 1.0, 1.0, 0, ""); // 5
    ((void(__fastcall*)(__int32, const char*, float, float, float, float, __int64, const char*))PTR_Dvar_Register_Color)(0x2C284664, "", 1.0, 1.0, 1.0, 1.0, 0, ""); // 6
    ((void(__fastcall*)(__int32, const char*, float, float, float, float, __int64, const char*))PTR_Dvar_Register_Color)(0x522AC0CD, "", 1.0, 1.0, 1.0, 1.0, 0, ""); // 7

#endif

    MH_Initialize();
    if (!*Protection::CustomName)
    {
        time_t now = time(nullptr) % 86400;
#if !IS_PATCH_ONLY
        snprintf(Protection::CustomName, 16, DEFAULT_PLAYERNAME);
#else
        snprintf(Protection::CustomName, 16, "Unknown Soldier");
#endif
        XLOG("Name initialized");
    }
    
#ifndef NO_NAME
    // memcpy((void*)OFFSET(0x15E86638), Protection::CustomName, strlen(Protection::CustomName) + 1);
    memcpy((void*)PTR_Name1, Protection::CustomName, strlen(Protection::CustomName) + 1);
    // memcpy((void*)PTR_Name2, Protection::CustomName, strlen(Protection::CustomName) + 1);
    if (!Offsets::IsBadReadPtr((VOID*)s_playerData_ptr) && *(INT64*)s_playerData_ptr)
    {
        memset((void*)(*(INT64*)s_playerData_ptr + 0x8), 0, CUSTOM_NAME_SIZE);
        memcpy((void*)(*(INT64*)s_playerData_ptr + 0x8), Protection::CustomName, strlen(Protection::CustomName) + 1);
    }
#endif

    Offsets::LoadOffsets();
    XLOG("Offsets loaded.");
    InstallHook(ExceptHook);
    Protection::install();
    XLOG("Protection installed.");
#if !IS_PATCH_ONLY
    trigger_high_performance_gpu_switch();
#else
    DiscordRP::Initialize();
#endif
#if !IS_PATCH_ONLY
    asset_protection::protect();
#endif
    XLOG("Assets protected.");
    PROTECT_LIGHT_END();
    arxan_evasion::initialize();
    XLOG("AE installed");

    arxan_evasion::register_hook(
        []()
        {
            PROTECT_LIGHT_START("Main arxan hooks enable");
            XLOG("AE activating...");
            DetourTransactionBegin();
            DetourUpdateThread(GetCurrentThread());

            MDT_Activate(LobbyMsgRW_PrepWriteMsg_Hook);
            MDT_Activate(LobbyMsgRW_PrepReadMsg_Hook);
            MDT_Activate(COD_GetBuildTitle_Hook);
            MDT_Activate(Live_SystemInfo_Hook);
            MDT_Activate(LobbyTypes_GetMsgTypeName_Hook);
            MDT_Activate(qmemcpy_Hook);
            MDT_Activate(Com_MessagePrintHook);
            MDT_Activate(SEH_ReplaceDirectiveInStringWithBinding_Hook);
            MDT_Activate(LobbyMsgRW_PackageInt_Hook);
            MDT_Activate(LobbyMsgRW_PackageUInt_Hook);
            MDT_Activate(LobbyMsgRW_PackageUChar_Hook);
            MDT_Activate(UI_DoModelStringReplacement_Hook);
            MDT_Activate(LiveSteam_InitServer_Hook);  
            MDT_Activate(CMD_MenuResponse_f_hook);
            MDT_Activate(CMD_MenuResponseCached_f_hook);
            MDT_Activate(BG_Cache_GetScriptMenuNameForIndex_Hook);
            MDT_Activate(BG_Cache_GetEventStringNameForIndex_Hook);
            MDT_Activate(UI_Model_GetModelFromPath_0_hook);
            MDT_Activate(UI_Model_GetModelFromPath_hook);
            MDT_Activate(UI_Model_CreateModelFromPath_0_hook);
            MDT_Activate(UI_Model_AllocateNode_hook);
            //MDT_Activate(BG_Cache_GetLocStringNameForIndex_hook);
            MDT_Activate(BG_Cache_GetLUIMenuForIndex_hook);
            MDT_Activate(BG_Cache_GetLUIMenuDataForIndex_hook);
            MDT_Activate(hksi_lua_getinfo_hook);
            MDT_Activate(LiveFriends_GetFriendByXUID_hook);
#if !IS_PATCH_ONLY
            MDT_Activate(Lua_CoD_RegisterEngineFunctions_hook);
            MDT_Activate(hksI_openlib_hook);
            MDT_Activate(CL_ParseSnapshot_hook);
            MDT_Activate(SV_WriteSnapshotToClient_hook);
            MDT_Activate(Msg_ClientReliableData_Package_hook);
            MDT_Activate(HandleClientReliableData_hook);
            MDT_Activate(LiveStats_AreStatsDeltasValid_hook);
            MDT_Activate(LiveStats_DoSecurityChecksCmd_hook);
            MDT_Activate(DBX_AuthLoad_ValidateSignature_Try_hook);
            MDT_Activate(UI_LuaCall_UIElement_setRGB_hook);
            MDT_Activate(BG_Cache_LoadTables);
            MDT_Activate(CG_CalcFOV_hook);
            //MDT_Activate(BG_Cache_CheckForChecksumMismatchForClient_hook);
            MDT_Activate(SpawnSystem_LoadInfluencerPresets_hook);
            MDT_Activate(UI_CustomDrawRectRot_1_hook);

#if ZBR_EXTEND_CLIENTFX
            move_old_clientfx();
            MDT_Activate(clientfx_function_1_hook);
            MDT_Activate(clientfx_function_2_hook);
            MDT_Activate(clientfx_function_3_hook);
            MDT_Activate(clientfx_function_4_hook);
            MDT_Activate(clientfx_function_5_hook);
            MDT_Activate(bg_cache_init_hook);
#endif
#if ZBR_DEBUG_POOL_OVERRUNS
            MDT_Activate(BG_Cache_PrintValuesForType_hook);
#endif

            /*MDT_Activate(Dvar_SetFloat_hook);
            MDT_Activate(GetDefaultFOV_hook);*/
            //MDT_Activate(hks_obj_tolstring_hook);
            
            auto ptr = EncodePointer(ZBR_DEBUGGER_PTR);
            ((void(__fastcall*)(PVOID))REBASE(0x2C53760))(ptr);
            ((void(__fastcall*)(PVOID))REBASE(0x2C5385C))(ptr);
            ((void(__fastcall*)(PVOID))REBASE(0x2C53724))(ptr);
            ((void(__fastcall*)(PVOID))REBASE(0x2C5F650))(ptr);
            ((void(__fastcall*)(PVOID))REBASE(0x2C5F668))(ptr);

            chgmem<unsigned char>(REBASE(0x69D91D), 0x75); // draw overhead names relative in zombies
            chgmem<unsigned char>(REBASE(0x69D6B5) + 1, 0x0); // draw overhead names relative in zombies
            // TODO: 2C560B0

#if DEV_DRAWVELOCITY_DEBUG
            MDT_Activate(Pmove_1_hook);
#endif
            MDT_Activate(R_EndFrame_hook);
#if ZBR_PATCH_JUMPSLOWDOWN
            MDT_Activate(Jump_ApplySlowdown_hook);
#endif
#if ZBR_PATCH_SLIDE_PRESERVE_MOMENTUM
            MDT_Activate(PM_DoSlideAdjustments_hook);
#endif

#endif
            MDT_Activate(Sys_VerifyPacketChecksum_Hook);
            MDT_Activate(Sys_ChecksumCopy_Hook);
            MDT_Activate(LobbyMsgRW_PrintMessage_Hook);
            MDT_Activate(LobbyMsgRW_PrintDebugMessage_Hook);
            // MDT_Activate(LobbyMsgRW_PackageElement_hook);
            MDT_Activate(ExecLuaCMD_hook);
            MDT_Activate(Lua_CoD_LuaStateManager_Error_hook);

#if !IS_PATCH_ONLY
            MDT_Activate(SV_SnapshotRateHeuristic_hook);
#endif
            
            auto OldProtection = 0ul;
#if !IS_PATCH_ONLY
            VirtualProtect((__int32*)REBASE(0x228CDE0), 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)REBASE(0x228CDE0) = 0xC3;
            VirtualProtect((__int32*)REBASE(0x228CDE0), 1, OldProtection, &OldProtection);

            unsigned char values[] = { 0x41, 0x89, 0xC1, 0x49, 0x89, 0xD8, 0x8B, 0x11, 0x89, 0xF1, 0x48, 0xB8, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0xFF, 0xD0 };
            *((__int64*)(values + 12)) = (__int64)VM_SafeCreateLocalVariablesArrayHook;
            VirtualProtect((__int32*)REBASE(0x12CE9DF), 22, PAGE_EXECUTE_READWRITE, &OldProtection);
            memcpy((__int32*)REBASE(0x12CE9DF), values, 22);
            VirtualProtect((__int32*)REBASE(0x12CE9DF), 22, OldProtection, &OldProtection);

#if ZBR_PATCH_JUMPSLOWDOWN
            //VirtualProtect((__int32*)REBASE(0x26767BE), 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            //*(char*)REBASE(0x26767BE) = 0xEB; // player jump slowdown
            //VirtualProtect((__int32*)REBASE(0x26767BE), 1, OldProtection, &OldProtection);
            MDT_Activate(Jump_ReduceFriction_hook);

            VirtualProtect((__int32*)REBASE(0x2676933), 2, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(unsigned __int16*)REBASE(0x2676933) = 0x9090; // player jump slowdown
            VirtualProtect((__int32*)REBASE(0x2676933), 2, OldProtection, &OldProtection);

            MDT_Activate(BG_GetViewDip_hook);
            
            MDT_Activate(PM_CrashLand_hook);
            MDT_Activate(Jump_ClampHorizontalVelocity_hook);
            MDT_Activate(Jump_Start_hook);
#endif

#if ZBR_PATCH_FAST_SPRINTLEAP
            chgmem<unsigned __int16>(REBASE(0x2676897), ZBR_FAST_SPRINTLEAP_MS);
            chgmem<unsigned __int16>(REBASE(0x26769BA), ZBR_FAST_SPRINTLEAP_MS);
#endif

#if ZBR_PATCH_FAST_SPRINTLERPIN
            chgmem<unsigned __int16>(REBASE(0x268A64A), ZBR_FAST_SPRINTLERPIN_MS);
#endif
#if ZBR_PATCH_SLIDESLOWDOWN
            chgmem<unsigned char>(REBASE(0x268A6E5), 0xEB);
            chgmem<unsigned __int32>(REBASE(0x268C864 + 0x4), 0x9117a8 + 0x4D);
            chgmem<float>(REBASE(0x2F9E061), 0.0);
            // 0.001 friction chgmem<unsigned __int32>(REBASE(0x16894B + 4), 0x2E2AF45);
#endif
#if ZBR_PATCH_CANSLIDETHENSPRINT
            chgmem<unsigned __int16>(REBASE(0x268F0EE + 0), 0x9090);
            chgmem<unsigned __int16>(REBASE(0x268F0EE + 2), 0x9090);
            chgmem<unsigned __int16>(REBASE(0x268F0EE + 4), 0x9090);
#endif
#if ZBR_PATCH_INSTANT_SLIDE
            chgmem<unsigned char>(REBASE(0x168534), 0xEB);
#endif
#if ZBR_PATCH_FASTSWAP
            chgmem<unsigned __int32>(REBASE(0x26E4C6B + 0x4), 0x8b062d - 4);
            chgmem<unsigned __int32>(REBASE(0x44F415 + 0x4), 0x2b45e83 - 4);
            chgmem<unsigned __int32>(REBASE(0x460E74 + 0x4), 0x2b34424 - 4);

            chgmem<float>(REBASE(0x2F952A0 - 4), ZBR_FASTSWAP_MULTIPLIER);
#endif
#if ZBR_PATCH_FASTADS
            chgmem<unsigned __int32>(REBASE(0x26D7485 + 0x4), 0x8bc2c3 + 0xC);

            chgmem<float>(REBASE(0x2F9375C), ZBR_FASTADS_MULTIPLIER);

            chgmem<unsigned __int16>(REBASE(0x26D7474), 0x9090);
            chgmem<unsigned __int16>(REBASE(0x26D7483), 0x9090);
#endif
#if ZBR_PATCH_FASTJUMP
            chgmem<unsigned __int32>(REBASE(0x2675FC2), 1);
            //MDT_Activate(PM_CmdScale_hook);
            MDT_Activate(PM_AirMove_hook);
            MDT_Activate(PM_Accelerate_hook);
            MDT_Activate(PM_Friction_hook);
            MDT_Activate(BG_GetFriction_hook);
#endif
#if ZBR_PATCH_SLIDEANGLES
            chgmem<unsigned char>(REBASE(0x169268), 0xEB);
            MDT_Activate(PM_ClampViewAngles_hook);
#endif

#if ZBR_PATCH_DEADSHOT
            chgmem<float>(REBASE(0x2FA2623), ZBR_DEADSHOT_REDUCE_SPREAD);
            chgmem<unsigned __int32>(REBASE(0x26D0892 + 4), 0x8d1d1a + 0x6F);
            chgmem<unsigned __int32>(REBASE(0x26D08A2 + 4), 0x8d1d0a + 0x6F);
#endif
            chgmem<unsigned __int32>(REBASE(0xA15E9A), 0x000001b8); // mov eax, 1
            chgmem<unsigned __int32>(REBASE(0xA15E9A + 4), 0x90909000);

            chgmem<unsigned __int32>(REBASE(0xA15E70), 0x000001b8); // mov eax, 1
            chgmem<unsigned __int32>(REBASE(0xA15E70 + 4), 0x90909000);

            MDT_Activate(ScrVar_InitVariables_hook);

            unsigned char fastfile_hook[8] = { 0x89, 0xd9, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90 }; // mov ecx, ebx
            chgmem(REBASE(0x142507D), 8, fastfile_hook);

            MDT_Activate(mods_is_mod_loaded_hook);
            MDT_Activate(DB_GetZonePriority_hook);
            MDT_Activate(DB_LoadXAssets_hook);
            MDT_Activate(Com_Quit_hook);
            MDT_Activate(BG_GetCustomizationTableNameForSessionMode_hook);
            MDT_Activate(CG_UpdatePlayerDObj_hook);
            MDT_Activate(CM_LoadMap_hook);
            MDT_Activate(DB_LoadXZone_hook);
            MDT_Activate(Com_SessionModeOrCore_GetPath_hook);
            MDT_Activate(Com_SessionMode_GetLevelScriptsFile_hook);
            MDT_Activate(G_ResetEntityParsePoint_hook);
            MDT_Activate(G_SpawnEntitiesFromString_hook);
            MDT_Activate(CM_LinkAllStaticModels_hook);
            MDT_Activate(R_UseWorld_hook);
            MDT_Activate(Fire_Weapon_hook);
            MDT_Activate(G_GetWeaponHitLocationMultiplier_hook);
            MDT_Activate(VM_OP_EvalFieldVariableRef_ErrRecovery_hook);
            MDT_Activate(BG_Cache_LoadAssets_hook);
            MDT_Activate(loadInPlace_hook);

            // fix player die calls 198E63D 198E67F
            {
                auto lsize = (0x198E67F - 0x198E63D);
                for (int i = 0; i < lsize; i++)
                {
                    chgmem<unsigned char>(REBASE(0x198E63D) + i, 0x90);
                }

                FlushInstructionCache(GetCurrentProcess(), (LPCVOID)REBASE(0x198E63D), lsize);
            }
            

            // MDT_Activate(vm_execute_hook);
            // MDT_Activate(vm_execute_error_handler_hook);
            
            // vm_execute function invoker
            //for (__int64 it = REBASE(0x12EDD05); it < REBASE(0x12EDD1E); it++)
            //{
            //    chgmem<unsigned char>(it, 0x90);
            //}
            //
            //// call an intermediate function
            //unsigned char patchdata[] = { 0x50, 0x48, 0x83, 0xEC, 0x28, 0x48, 0xB8, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0xFF, 0xD0, 0x48, 0x83, 0xC4, 0x28, 0x58 };
            //*(__int64*)(patchdata + 0x7) = (__int64)&vm_execute_timer;
            //chgmem(REBASE(0x12EDD05), 22, patchdata);

            // MDT_Activate(CL_KeyEvent_hook);

            // fix loading mp spawns
            for (__int64 it = REBASE(0x1B248D1); it < REBASE(0x1B248DF); it++)
            {
                chgmem<unsigned char>(it, 0x90);
            }
#endif

            // SL fix (nop out the calls to com_error)
            VirtualProtect((__int32*)REBASE(0x1964746), 5, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(__int32*)REBASE(0x1964746) = 0x90909090;
            *(char*)(REBASE(0x1964746) + 4) = 0x90;
            VirtualProtect((__int32*)REBASE(0x1964746), 5, OldProtection, &OldProtection);

            // SL fix (nop out the calls to com_error)
            VirtualProtect((__int32*)REBASE(0x1964687), 5, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(__int32*)REBASE(0x1964687) = 0x90909090;
            *(char*)(REBASE(0x1964687) + 4) = 0x90;
            VirtualProtect((__int32*)REBASE(0x1964687), 5, OldProtection, &OldProtection);

            VirtualProtect((__int32*)REBASE(0x1EF71F2), 4, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)REBASE(0x1EF71F2 + 1) = 0xB7; // fix movsx issue with package readglob
            VirtualProtect((__int32*)REBASE(0x1EF71F2), 4, OldProtection, &OldProtection);

            VirtualProtect((__int32*)PTR_Cmp_TokenizeStringInternal, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)PTR_Cmp_TokenizeStringInternal = 0x2F;
            VirtualProtect((__int32*)PTR_Cmp_TokenizeStringInternal, 1, OldProtection, &OldProtection);

            // process priority
            VirtualProtect((__int32*)REBASE(0x2334C7D), 4, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(__int32*)REBASE(0x2334C7D) = 0x00008000; // above normal
            VirtualProtect((__int32*)REBASE(0x2334C7D), 4, OldProtection, &OldProtection);

            VirtualProtect((__int32*)REBASE(0x2334C82), 4, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(__int32*)REBASE(0x2334C82) = 0x00008000; // above normal
            VirtualProtect((__int32*)REBASE(0x2334C82), 4, OldProtection, &OldProtection);
            

#ifdef CLIENTFIELD_ERROR_PATCH
            // TODO: offsets are old!
           /* VirtualProtect((__int32*)OFFSET(0x13436F), 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)OFFSET(0x13436F) = 0xEB;
            VirtualProtect((__int32*)OFFSET(0x13436F), 1, OldProtection, &OldProtection);

            VirtualProtect((__int32*)OFFSET(0x136DBB), 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)OFFSET(0x136DBB) = 0xEB;
            VirtualProtect((__int32*)OFFSET(0x136DBB), 1, OldProtection, &OldProtection);

            VirtualProtect((__int32*)OFFSET(0x136E8C), 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)OFFSET(0x136E8C) = 0xEB;
            VirtualProtect((__int32*)OFFSET(0x136E8C), 1, OldProtection, &OldProtection);*/
#endif
            // movsx -> movzx
            VirtualProtect((__int32*)REBASE(0x1F2DFB8), 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)REBASE(0x1F2DFB8) = 0xb6;
            VirtualProtect((__int32*)REBASE(0x1F2DFB8), 1, OldProtection, &OldProtection);

            // movsx -> movzx
            VirtualProtect((__int32*)REBASE(0x1CB1054), 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)REBASE(0x1CB1054) = 0xb6;
            VirtualProtect((__int32*)REBASE(0x1CB1054), 1, OldProtection, &OldProtection);

#if !IS_PATCH_ONLY
#if ZBR_TICKRATE != OLD_TICKRATE
            // Tickrate
            __int64 off = REBASE(0x2261943) + 2;
            VirtualProtect((__int32*)off, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)off = ZBR_TICKRATE;
            VirtualProtect((__int32*)off, 1, OldProtection, &OldProtection);

            off = REBASE(0x225B8BD) + 6;
            VirtualProtect((__int32*)off, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)off = ZBR_SV_FPS;
            VirtualProtect((__int32*)off, 1, OldProtection, &OldProtection);

            off = REBASE(0x2257124) + 2;
            VirtualProtect((__int32*)off, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)off = ZBR_TICKRATE;
            VirtualProtect((__int32*)off, 1, OldProtection, &OldProtection);

            off = REBASE(0x225714B) + 2;
            VirtualProtect((__int32*)off, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)off = ZBR_TICKRATE;
            VirtualProtect((__int32*)off, 1, OldProtection, &OldProtection);

            // TODO: check dobjupdateservertime dtime

#endif

#endif
            MDT_Activate(Lua_CoD_LuaStateManager_HKSLog_hook);
            MDT_Activate(hksDefaultLogger_hook);
            MDT_Activate(ExitProcessFatal_hook);
            MDT_Activate(ExitProcessFatal_hook2);
            MDT_Activate(ExitProcessFatal_hook3);
            MDT_Activate(bdGetNatType_hook);
            // MDT_Activate(RtlRaiseException_hook);
            XLOG("AE Activated");
            DetourTransactionCommit();
            PROTECT_LIGHT_END();
        },
        []()
        {
            PROTECT_LIGHT_START("Main arxan hooks disable");
            XLOG("AE disabling...");
            DetourTransactionBegin();
            DetourUpdateThread(GetCurrentThread());

            MDT_Deactivate(LobbyMsgRW_PrepWriteMsg_Hook);
            MDT_Deactivate(LobbyMsgRW_PrepReadMsg_Hook);
            MDT_Deactivate(COD_GetBuildTitle_Hook);
            MDT_Deactivate(Live_SystemInfo_Hook);
            MDT_Deactivate(LobbyTypes_GetMsgTypeName_Hook);
            MDT_Deactivate(qmemcpy_Hook);
            MDT_Deactivate(Com_MessagePrintHook);
            MDT_Deactivate(SEH_ReplaceDirectiveInStringWithBinding_Hook);
            MDT_Deactivate(LobbyMsgRW_PackageInt_Hook);
            MDT_Deactivate(LobbyMsgRW_PackageUInt_Hook);
            MDT_Deactivate(LobbyMsgRW_PackageUChar_Hook);
            MDT_Deactivate(UI_DoModelStringReplacement_Hook);
            MDT_Deactivate(LiveSteam_InitServer_Hook);
            MDT_Deactivate(CMD_MenuResponse_f_hook);
            MDT_Deactivate(CMD_MenuResponseCached_f_hook);
            MDT_Deactivate(BG_Cache_GetScriptMenuNameForIndex_Hook);
            MDT_Deactivate(BG_Cache_GetEventStringNameForIndex_Hook);
            MDT_Deactivate(UI_Model_GetModelFromPath_0_hook);
            MDT_Deactivate(UI_Model_GetModelFromPath_hook);
            MDT_Deactivate(UI_Model_CreateModelFromPath_0_hook);
            MDT_Deactivate(UI_Model_AllocateNode_hook);
            //MDT_Deactivate(BG_Cache_GetLocStringNameForIndex_hook);
            MDT_Deactivate(BG_Cache_GetLUIMenuForIndex_hook);
            MDT_Deactivate(BG_Cache_GetLUIMenuDataForIndex_hook);
            MDT_Deactivate(hksi_lua_getinfo_hook);
#if !IS_PATCH_ONLY
            MDT_Deactivate(Lua_CoD_RegisterEngineFunctions_hook);
            MDT_Deactivate(hksI_openlib_hook);
            MDT_Deactivate(CL_ParseSnapshot_hook);
            MDT_Deactivate(SV_WriteSnapshotToClient_hook);
            MDT_Deactivate(Msg_ClientReliableData_Package_hook);
            MDT_Deactivate(HandleClientReliableData_hook);
            MDT_Deactivate(LiveStats_AreStatsDeltasValid_hook);
            MDT_Deactivate(LiveStats_DoSecurityChecksCmd_hook);
            MDT_Deactivate(DBX_AuthLoad_ValidateSignature_Try_hook);
#endif
            MDT_Deactivate(Sys_VerifyPacketChecksum_Hook);
            MDT_Deactivate(Sys_ChecksumCopy_Hook);
            MDT_Deactivate(LobbyMsgRW_PrintMessage_Hook);
            MDT_Deactivate(LobbyMsgRW_PrintDebugMessage_Hook);
            // MDT_Deactivate(LobbyMsgRW_PackageElement_hook);
            MDT_Deactivate(ExecLuaCMD_hook);
            MDT_Deactivate(Lua_CoD_LuaStateManager_Error_hook);
#if !IS_PATCH_ONLY
            MDT_Deactivate(SV_SnapshotRateHeuristic_hook);
#endif

            auto OldProtection = 0ul;
#if !IS_PATCH_ONLY
            VirtualProtect((__int32*)REBASE(0x228CDE0), 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)REBASE(0x228CDE0) = 0x48;
            VirtualProtect((__int32*)REBASE(0x228CDE0), 1, OldProtection, &OldProtection);
#endif

            // SL fix (nop out the calls to com_error)
            VirtualProtect((__int32*)REBASE(0x1964746), 5, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(__int32*)REBASE(0x1964746) = 0x793A25E8;
            *(char*)(REBASE(0x1964746) + 4) = 0x00;
            VirtualProtect((__int32*)REBASE(0x1964746), 5, OldProtection, &OldProtection);

            // SL fix (nop out the calls to com_error)
            VirtualProtect((__int32*)REBASE(0x1964687), 5, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(__int32*)REBASE(0x1964687) = 0x793AE4E8;
            *(char*)(REBASE(0x1964687) + 4) = 0x00;
            VirtualProtect((__int32*)REBASE(0x1964687), 5, OldProtection, &OldProtection);

            VirtualProtect((__int32*)REBASE(0x1EF71F2), 4, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)REBASE(0x1EF71F2 + 1) = 0xBF; // fix movzx issue with package readglob
            VirtualProtect((__int32*)REBASE(0x1EF71F2), 4, OldProtection, &OldProtection);

            VirtualProtect((__int32*)PTR_Cmp_TokenizeStringInternal, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)PTR_Cmp_TokenizeStringInternal = 0x30;
            VirtualProtect((__int32*)PTR_Cmp_TokenizeStringInternal, 1, OldProtection, &OldProtection);

#ifdef CLIENTFIELD_ERROR_PATCH
            // TODO: offsets are old!
            /*VirtualProtect((__int32*)OFFSET(0x13436F), 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)OFFSET(0x13436F) = 0x74;
            VirtualProtect((__int32*)OFFSET(0x13436F), 1, OldProtection, &OldProtection);

            VirtualProtect((__int32*)OFFSET(0x136DBB), 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)OFFSET(0x136DBB) = 0x74;
            VirtualProtect((__int32*)OFFSET(0x136DBB), 1, OldProtection, &OldProtection);

            VirtualProtect((__int32*)OFFSET(0x136E8C), 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)OFFSET(0x136E8C) = 0x74;
            VirtualProtect((__int32*)OFFSET(0x136E8C), 1, OldProtection, &OldProtection);*/
#endif
            // movzx -> movsx
            VirtualProtect((__int32*)REBASE(0x1F2DFB8), 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)REBASE(0x1F2DFB8) = 0xbe;
            VirtualProtect((__int32*)REBASE(0x1F2DFB8), 5, OldProtection, &OldProtection);

            // movzx -> movsx
            VirtualProtect((__int32*)REBASE(0x1CB1054), 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)REBASE(0x1CB1054) = 0xbe;
            VirtualProtect((__int32*)REBASE(0x1CB1054), 5, OldProtection, &OldProtection);
#if !IS_PATCH_ONLY
#if ZBR_TICKRATE != OLD_TICKRATE
            // Tickrate
            __int64 off = REBASE(0x2261943) + 2;
            VirtualProtect((__int32*)off, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)off = OLD_TICKRATE;
            VirtualProtect((__int32*)off, 1, OldProtection, &OldProtection);

            off = REBASE(0x225B8BD) + 6;
            VirtualProtect((__int32*)off, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)off = 20;
            VirtualProtect((__int32*)off, 1, OldProtection, &OldProtection);

            off = REBASE(0x2257124) + 2;
            VirtualProtect((__int32*)off, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)off = OLD_TICKRATE;
            VirtualProtect((__int32*)off, 1, OldProtection, &OldProtection);

            off = REBASE(0x225714B) + 2;
            VirtualProtect((__int32*)off, 1, PAGE_EXECUTE_READWRITE, &OldProtection);
            *(char*)off = OLD_TICKRATE;
            VirtualProtect((__int32*)off, 1, OldProtection, &OldProtection);
#endif
#endif
            XLOG("AE deactivated.");
            DetourTransactionCommit();
            PROTECT_LIGHT_END();
        }, true);
    PROTECT_LIGHT_START("runpatching start2");

    DetourTransactionBegin();
    DetourUpdateThread(GetCurrentThread());

    MDT_Activate(__report_gsfailure_hook);
#if !IS_PATCH_ONLY
    MDT_Activate(LoadCursorA_Hook);
#endif

    DetourTransactionCommit();
#if !IS_PATCH_ONLY
    auto curs = LoadCursor(Offsets::GetOurModuleHandle(), MAKEINTRESOURCE(IDC_CURSOR3));
    auto curs2 = LoadCursor(Offsets::GetOurModuleHandle(), MAKEINTRESOURCE(IDC_CURSOR3));
    *(__int64*)REBASE(0x17E76430) = (__int64)curs;
    *(__int64*)REBASE(0x17E76440) = (__int64)curs2;
    SetCursor(curs);
#endif
    XLOG("Cursor Changed");
#if !IS_PATCH_ONLY
    auto icon = LoadIcon(Offsets::GetOurModuleHandle(), MAKEINTRESOURCE(IDI_ICON1));
    SendMessage((HWND) * (__int64*)REBASE(0x17E763D0), WM_SETICON, ICON_SMALL, (LPARAM)icon);
    SendMessage((HWND) * (__int64*)REBASE(0x17E763D0), WM_SETICON, ICON_BIG, (LPARAM)icon);
#endif

    XLOG("Icon Changed");
#if !IS_PATCH_ONLY
    Protection::handle_packet_callbacks[MESSAGE_TYPE_ZBR_LOBBYINFO_RESPONSE] = [](__int32* lobbyMsgTypePtr, __int64 lobbyMsg)
    {
        DiscordRP::HandleUpdateActivity((void*)lobbyMsg);
    };

    Protection::handle_packet_callbacks[MESSAGE_TYPE_ZBR_LOBBYSTATE] = [](__int32* lobbyMsgTypePtr, __int64 lobbyMsg)
    {
        zbr::handle_lobbystate((LobbyMsg*)lobbyMsg);
    };

    Protection::handle_packet_callbacks[MESSAGE_TYPE_ZBR_CLIENTRELIABLE] = [](__int32* lobbyMsgTypePtr, __int64 lobbyMsg)
    {
        zbr::handle_clientreliable((LobbyMsg*)lobbyMsg);
    };

    Protection::handle_packet_callbacks[MESSAGE_TYPE_ZBR_CHARACTERRPC] = [](__int32* lobbyMsgTypePtr, __int64 lobbyMsg)
    {
        zbr::handle_emoterpc((LobbyMsg*)lobbyMsg);
    };
#endif

    INT64 ptrDvar = *(INT64*)(REBASE(0x168EDCA0));
    *(DWORD*)(ptrDvar + 0x18) = 0; // clear flags

    Dvar_SetFromStringByName("ui_error_callstack_ship", "1", true);

    ptrDvar = *(INT64*)(REBASE(0xA3D15D8));
    *(DWORD*)(ptrDvar + 0x18) = 0; // clear flags

    Dvar_SetFromStringByName("g_allowvote", "0", true);
    Dvar_SetFromStringByName("sv_mapswitch", "0", true);
    Dvar_SetFromStringByName("maxvoicepacketsperframe", "0", true);

#if !IS_PATCH_ONLY
    ptrDvar = *(INT64*)(REBASE(0x177C5908));
    *(DWORD*)(ptrDvar + 0x18) = 0; // clear flags

    ptrDvar = *(INT64*)(REBASE(0x177C5898));
    *(DWORD*)(ptrDvar + 0x18) = 0; // clear flags
    
    //ptrDvar = *(INT64*)(REBASE(0x36841D0));
    //*(DWORD*)(ptrDvar + 0x18) = 0; // clear flags

    Dvar_SetFromStringByName("sv_maxRate", "50000", true);
    Dvar_SetFromStringByName("sv_network_fps", "125", true);
#endif

    XLOG("Dvars updated");
#if !IS_PATCH_ONLY
    // emblems reset
    ((void(__fastcall*)())REBASE(0x266CFA0))();
#endif

    XLOG("Emblems reset");

#if !IS_PATCH_ONLY
    zbr::zone::extend_xasset_pool(xasset_playerfxtable, 16);
    zbr::zone::extend_xasset_pool(xasset_surfacesounddef, 256);
    zbr::zone::extend_xasset_pool(xasset_locdmgtable, 2);
    zbr::zone::extend_xasset_pool(xasset_bulletpenetration, 2);
    zbr::zone::extend_xasset_pool(xasset_scriptparsetree, 2000);
    zbr::zone::extend_xasset_pool(xasset_bitfield, 100);

    zbr::dvar_bypass_writeable(true);
    Dvar_SetFromStringByName("com_disable_popups", "0", true);
    //Dvar_SetFromStringByName("bgcache_loaddevitems", "1", true);
    zbr::dvar_bypass_writeable(false);

    do_lazy_strings();
    bypass_dev_calls();

    zbr::testing::dotests();

    MDT_Activate(Sys_Error_hook);

#ifdef IS_DEV
#if DEV_BYPASS_DVARS
    zbr::dvar_bypass_writeable(true);
#endif
#endif

#endif

    PROTECT_LIGHT_END();
}

#pragma optimize( "", off )
BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
#ifdef USE_NLOG
    ALOG("%p process %X, reason %d", hModule, GetCurrentProcessId(), ul_reason_for_call);
#endif
    int result = 0;
    int vm_isProtected = 0;
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
        VMP_EXTRA_HEAVY_START("Entrypoint");
#if !IS_PATCH_ONLY
        {
            auto hndl = GetModuleHandle("t7patch");
            if (hndl && GetProcAddress(hndl, "Unload"))
            {
                ((void(__fastcall*)())GetProcAddress(hndl, "Unload"))();
            }
        }
#endif

        std::srand(time(NULL));
        *(__int32*)REBASE(0x112EFA14) = rand();

#if !IS_PATCH_ONLY
        LoadLibraryA("zbr2.dll");
#endif

#ifdef IS_DEV
        SECURITY_ATTRIBUTES sa;
        sa.nLength = sizeof(SECURITY_ATTRIBUTES);
        sa.bInheritHandle = 1;
        sa.lpSecurityDescriptor = 0;
        Offsets::is_console_available = CreatePipe(&Offsets::hReadConsole, &Offsets::hWriteConsole, &sa, 0xF4240);
        ALOG("^2ZBR Dev Console Ready!");
#endif

#if USE_CV > PROTECTION_STRIPPED
        if ((void*)&GetModuleHandleA == (void*)&Sleep)
        {
            StealthCB();
        }
#endif
        #if USE_CV == PROTECTION_NONE
        VIRTUALIZER_MUTATE_ONLY_START
        #endif
        Offsets::SetOurModuleHandle(hModule);
        #if USE_CV == PROTECTION_NONE
        VIRTUALIZER_MUTATE_ONLY_END
#endif
        Offsets::Pid = TARGET_PID;
        TARGET_PID = 0;
        Offsets::is2v2 = *(char*)((INT64)hModule + 0x5C);
#if !IS_PATCH_ONLY
        GSCBuiltins::Init();
        ScriptDetours::InstallHooks();
        LazyLink::Init();
#endif

#if !IS_PATCH_ONLY
        RunGSIParser();
        LoadCustomFiles();
        RunPatching();     
        vmrt::install();
        zbr::network::init();
#endif
        VMP_EXTRA_HEAVY_END();
            
        return TRUE;
    case DLL_THREAD_ATTACH:
        break;
    case DLL_THREAD_DETACH:
        break;
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

#pragma optimize( "", on )

#if IS_PATCH_ONLY
EXPORT void zbr_run_gamemode_lui(const char* input)
{
    VMP_EXTRA_HEAVY_START("activator");
    if (CONST32("serious_anticrash_2023") == GSCUHashing::canon_hash(input))
    {
        RunPatching();
    }
    VMP_EXTRA_HEAVY_END();
}

EXPORT void EnableInjectorlessInstall() // must be called BEFORE loading the patch via zbr_run_gamemode_lui
{
    Protection::IsInjectorlessInstall = true;
}

EXPORT void Unload()
{
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
                        tContext.Dr7 = 0;
                        tContext.ContextFlags = CONTEXT_DEBUG_REGISTERS;
                        SetThreadContext(hThread, &tContext);
                    }
                    CloseHandle(hThread);
                }
            }
        } while (Thread32Next(hThreadSnap, &te32));
    }

    CloseHandle(hThreadSnap);

    arxan_evasion::uninstall();
    Protection::uninstall();
    is_unhooking = true;
    XLOG("Uninstalling hook...");
    UninstallHook();
    XLOG("Hook uninstalled!");

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
                    ResumeThread(hThread);
                    CloseHandle(hThread);
                }
            }
        } while (Thread32Next(hThreadSnap, &te32));
    }

    CloseHandle(hThreadSnap);
}
#endif
#if !IS_PATCH_ONLY
struct UnifiedWeaponData
{
    char name[64];
    int damage;
    int fireType;
    int weaponType;
    int weapClass;
    int weaponIndex;
    int altWeaponIndex;
    int weapProjExplosion;
    int innerExplodamage;
    int outerExplodamage;
    float damageDuration;
    float damageInterval;
    int shotCount;
    int bRifleBullet;
    int bIsDualWield;
    int chargeMaxTime;
    int chargeMaxLevel;
    int iHoldFireTime;
    int bIsBoltAction;
    int numShotsBeforeRechamber;
    int stackFire;
    int burstCount;
    int iBurstDelayTime;
    int bUseAsMelee;
    int bIsSegmentedReload;
    int iReloadStartTime;
    int iClipSize;
    int iReloadAmmoAdd;
    int bFuelTankWeapon;
    int fuelTankTime;
    int dwIndex;
    int iFireTime;
    int bUnlimitedAmmo;
    int damages[6];
    float ranges[6];
    float hitloc[HITLOC_NUM];
};

// 26EF810 BG_GetFireType
struct WeaponsUnifiedOutput
{
    int size;
    int count;
    void* data;
};


EXPORT int GetWeaponsUnifiedDump(WeaponsUnifiedOutput& output)
{
    std::vector<UnifiedWeaponData> collected_data;

    __int64* weaponvariants = PTR_WeaponDefVariants;
    int numDefs = BG_GetNumWeaponsResult;

    for (int i = 0; i < numDefs; i++)
    {
        if (strstr(*(char**)(weaponvariants[i] + 0x0), "dualoptic"))
        {
            continue;
        }
        auto WeaponDef = *(__int64*)(weaponvariants[i] + 0x18);
        collected_data.push_back(UnifiedWeaponData());
        auto back = &collected_data.back();

        strcpy_s(back->name, *(char**)(weaponvariants[i] + 0x0));
        back->damage = *(__int32*)(WeaponDef + 0x928); // range is 0x940 
        back->fireType = *(__int32*)(WeaponDef + 0x80);
        back->weaponType = *(__int32*)(WeaponDef + 0x6C);
        back->weapClass = *(__int32*)(WeaponDef + 0x70);
        back->weaponIndex = i;
        back->altWeaponIndex = *(__int32*)(weaponvariants[i] + 0x180);
        back->weapProjExplosion = *(__int32*)(WeaponDef + 0x1020);
        back->innerExplodamage = *(__int32*)(WeaponDef + 0xFB4);
        back->outerExplodamage = *(__int32*)(WeaponDef + 0xFB4 + 0xC);
        back->damageDuration = *(float*)(WeaponDef + 0x98C);
        back->damageInterval = *(float*)(WeaponDef + 0x990);
        back->shotCount = *(__int32*)(WeaponDef + 0x900);
        back->bRifleBullet = *(unsigned char*)(WeaponDef + 0xE65);
        back->bIsDualWield = *(unsigned char*)(WeaponDef + 0xE8C);
        back->chargeMaxTime = *(__int32*)(WeaponDef + 0xD50);
        back->chargeMaxLevel = *(__int32*)(WeaponDef + 0xD4C);
        back->iHoldFireTime = *(__int32*)(WeaponDef + 0xA30);
        back->bIsBoltAction = *(unsigned char*)(WeaponDef + 0xE68);
        back->numShotsBeforeRechamber = *(__int32*)(WeaponDef + 0xF78);
        back->stackFire = *(__int32*)(WeaponDef + 0xD30);
        back->burstCount = *(__int32*)(WeaponDef + 0xEF8);
        back->iBurstDelayTime = *(__int32*)(WeaponDef + 0xA58);
        back->bUseAsMelee = *(unsigned char*)(WeaponDef + 0x1169);
        back->bIsSegmentedReload = *(unsigned char*)(WeaponDef + 0xF45);
        back->iReloadStartTime = *(__int32*)(WeaponDef + 0xAF0);
        back->iClipSize = *(__int32*)(weaponvariants[i] + 0x194);
        back->iReloadAmmoAdd = *(__int32*)(WeaponDef + 0xF48);
        back->bFuelTankWeapon = *(unsigned char*)(WeaponDef + 0x2CD);
        back->fuelTankTime = *(__int32*)(WeaponDef + 0x2D0);
        back->dwIndex = *(__int32*)(WeaponDef + 0xF60);
        back->iFireTime = *(__int32*)(WeaponDef + 0xA1C);
        back->bUnlimitedAmmo = *(unsigned char*)(WeaponDef + 0x918);

        // 0x1258 fAdsSpread

        for (int j = 0; j < 6; j++)
        {
            back->damages[j] = ((__int32*)(WeaponDef + 0x928))[j];
            back->ranges[j] = ((float*)(WeaponDef + 0x940))[j];
        }

        for (int j = 0; j < HITLOC_NUM; j++)
        {
            back->hitloc[j] = (*(float**)(WeaponDef + 0x13B0))[j];
        }
        // TODO: PM_Weapon_ChargeShot chargeShotMinTime
        // TODO: need bIsLeftHand property (or inventory type)
        // TODO: need iscliponly property
    }

    output.size = sizeof(UnifiedWeaponData);
    output.count = collected_data.size();
    output.data = malloc(output.size * output.count);

    int index = 0;
    for (auto it = collected_data.begin(); it != collected_data.end(); it++)
    {
        ((UnifiedWeaponData*)output.data)[index++] = *it;
    }

    return 0;
}
#endif