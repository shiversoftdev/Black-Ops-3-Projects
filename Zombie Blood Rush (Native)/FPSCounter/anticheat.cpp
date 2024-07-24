#include "arxan_evasion.h"
#include "Offsets.h"
#include "protection.h"
#include "dll_resources/msdetours.h"
#include "mh.h"
#include "anticheat.h"
#include "anticheat_hooks.h"
#include <thread>
#include "callspoof.h"
#include "gscu_hashing.h"
#include "ntdll.h"
#include "string.h"
#include "vmrt.h"
#include <chrono>
#include <intrin.h>

#pragma intrinsic(_ReturnAddress)





















































#if USE_ANTICHEAT

// TODO: ImGui_ImplDX11_RenderDrawData
// TODO: random ret gadget from loaded dll
// TODO: statics
// TODO: aimbot detection
// https://guidedhacking.com/threads/how-to-get-direct3d11-device-pointer-dummy-device-method.20357/

#define M_PI           3.14159265358979323846  /* pi */

#pragma optimize( "", off )

CRYPT_VALUE_DEF(vHASH_SV_CHEATS, 0xf70e34e1)
CRYPT_OFFSET_DEF(oDVAR_GetVariantString, _DOFFSET(0x22C0570))
CRYPT_OFFSET_DEF(oDVAR_CastValueToInt, _DOFFSET(0x2C3BA0C))
CRYPT_OFFSET_DEF(oDVAR_FindVar, _DOFFSET(0x22BCC40))
CRYPT_OFFSET_DEF(oG_GetPlayerViewDirection, _DOFFSET(0x16980A0))
CRYPT_OFFSET_DEF(oSpoofTrampoline, _DOFFSET(SPOOF_GADGET))
CRYPT_OFFSET_DEF(oScr_AddVec, _DOFFSET(0x12E9E90))
CRYPT_OFFSET_DEF(oFireWeapon, _DOFFSET(0x1BBD6B4))
CRYPT_VALUE_DEF(vFireWeapon, _DOFFSET(0x1BBD630))
CRYPT_OFFSET_DEF(oG_GetWeaponDefBasedOnNumberOfBullets, _DOFFSET(0x1C0C9F0))
CRYPT_OFFSET_DEF(oj_helmet, _DOFFSET(0x2FE9F40))
CRYPT_OFFSET_DEF(oj_head, _DOFFSET(0x2FC8B80))
CRYPT_OFFSET_DEF(oj_neck, _DOFFSET(0x2FC8B88))
CRYPT_OFFSET_DEF(oj_spineupper, _DOFFSET(0x2FC8B90))
CRYPT_OFFSET_DEF(oj_spinelower, _DOFFSET(0x2FA9020))
CRYPT_OFFSET_DEF(oj_shoulder_le, _DOFFSET(0x2FEB200))
CRYPT_OFFSET_DEF(oj_shoulder_ri, _DOFFSET(0x3067210))
CRYPT_OFFSET_DEF(oj_hip_le, _DOFFSET(0x3067230))
CRYPT_OFFSET_DEF(oj_knee_le, _DOFFSET(0x2FC8BF0))
CRYPT_OFFSET_DEF(oj_knee_ri, _DOFFSET(0x2FC8BE0))
CRYPT_OFFSET_DEF(oj_elbow_le, _DOFFSET(0x2FC8BB0))
CRYPT_OFFSET_DEF(oj_elbow_ri, _DOFFSET(0x2FC8BA0))
CRYPT_OFFSET_DEF(oj_ankle_le, _DOFFSET(0x2FC8C10))
CRYPT_OFFSET_DEF(oj_ankle_ri, _DOFFSET(0x2FC8C00))
CRYPT_OFFSET_DEF(oScr_AllocString, _DOFFSET(0x12D8390))
CRYPT_OFFSET_DEF(oG_GetPlayerViewOrigin, _DOFFSET(0x169B6A0))
CRYPT_OFFSET_DEF(oGScr_UpdateTagInternal, _DOFFSET(0x197C810))
CRYPT_OFFSET_DEF(olevel_cachedtagmatrix, _DOFFSET(0xA5511C4))
CRYPT_OFFSET_DEF(oScr_AddFloat, _DOFFSET(0x12E9760))
CRYPT_OFFSET_DEF(oScr_AddInt, _DOFFSET(0x12E9870))
CRYPT_OFFSET_DEF(oactors_rewind_context_t_rewind, _DOFFSET(0x283A3F0))
CRYPT_OFFSET_DEF(oLevel_time, _DOFFSET(0xA5502C4))
CRYPT_OFFSET_DEF(oAdjustMovers, _DOFFSET(0x2822A50))
CRYPT_OFFSET_DEF(oG_AntiLagRewindClientPos, _DOFFSET(0x1BC3290))
CRYPT_OFFSET_DEF(oG_EntIsLinked, _DOFFSET(0x1C21430))
CRYPT_OFFSET_DEF(og_actorAndVehicleAntilag, _DOFFSET(0xA3D16B8))
CRYPT_OFFSET_DEF(oG_AntiLag_RewindActorPos, _DOFFSET(0x1C05D10))
CRYPT_OFFSET_DEF(oG_AntiLag_RewindVehiclePos, _DOFFSET(0x1C05FA0))
CRYPT_OFFSET_DEF(oG_AntiLag_RestoreActorPos, _DOFFSET(0x1BEB320))
CRYPT_OFFSET_DEF(oG_AntiLag_RestoreVehiclePos, _DOFFSET(0x1C04240))
CRYPT_OFFSET_DEF(oG_AntiLag_RestoreClientPos, _DOFFSET(0x1BEB3D0))
CRYPT_OFFSET_DEF(oRestoreMovers, _DOFFSET(0x282E650))
CRYPT_OFFSET_DEF(oactors_rewind_context_t_dtor_actors_rewind_context_t, _DOFFSET(0x283A330))
CRYPT_OFFSET_DEF(oStartConsoleRender, _DOFFSET(0x1339884))
CRYPT_OFFSET_DEF(oACRenderConsole, _DOFFSET(0x13399DF))

#pragma optimize( "", on )

#define SPOOFED(a, ...) spoof_call((void*)ao(oSpoofTrampoline), a, __VA_ARGS__)
#define DVAR_GetVariantString(b) ((const char*(__fastcall*)(__int64))ao(oDVAR_GetVariantString))(b)
#define DVAR_GetInt(b) ((__int32(__fastcall*)(const char*))ao(oDVAR_CastValueToInt))(DVAR_GetVariantString(b))
#define DVAR_FindVar(___hash) ((__int64(__fastcall*)(__int32))ao(oDVAR_FindVar))(___hash)

#define G_GetPlayerViewDirection(...) SPOOFED(((void(__fastcall*)(char*, vec3_t*, __int64, __int64))ao(oG_GetPlayerViewDirection)), __VA_ARGS__)
#define G_GetPlayerViewOrigin(clientstate, out_origin) ((void(__fastcall*)(char*, vec3_t*))ao(oG_GetPlayerViewOrigin))(clientstate, out_origin)
#define GScr_UpdateTagInternal(ent, tag, cachedTag) ((bool(__fastcall*)(char*, __int32, __int64))ao(oGScr_UpdateTagInternal))(ent, tag, cachedTag)
#define actors_rewind_context_t_rewind(actors_rewind_context, fromtime, totime, movernum) ((void(__fastcall*)(actors_rewind_context_t*, __int32, __int32, __int32))ao(oactors_rewind_context_t_rewind))(actors_rewind_context, fromtime, totime, movernum)
#define AdjustMovers(...) SPOOFED(((void(__fastcall*)(__int32, __int32, __int32, __int32, char*))ao(oAdjustMovers)), __VA_ARGS__)
#define G_AntiLagRewindClientPos(...) SPOOFED(((void(__fastcall*)(__int32, AntilagStore*))ao(oG_AntiLagRewindClientPos)), __VA_ARGS__)
#define G_EntIsLinked(ent) ((bool(__fastcall*)(char*))ao(oG_EntIsLinked))(ent)
#define G_AntiLag_RewindActorPos(gametime, buff) ((void(__fastcall*)(__int32, char*))ao(oG_AntiLag_RewindActorPos))(gametime, buff)
#define G_AntiLag_RewindVehiclePos(...) SPOOFED(((void(__fastcall*)(__int32, char*))ao(oG_AntiLag_RewindVehiclePos)), __VA_ARGS__)
#define G_AntiLag_RestoreActorPos(buff) ((void(__fastcall*)(char*))ao(oG_AntiLag_RestoreActorPos))(buff)
#define G_AntiLag_RestoreVehiclePos(...) SPOOFED(((void(__fastcall*)(char*))ao(oG_AntiLag_RestoreVehiclePos)), __VA_ARGS__)
#define G_AntiLag_RestoreClientPos(buff) ((void(__fastcall*)(char*))ao(oG_AntiLag_RestoreClientPos))(buff)
#define RestoreMovers(...) SPOOFED(((void(__fastcall*)(__int32, __int32, __int32))ao(oRestoreMovers)), __VA_ARGS__)
#define actors_rewind_context_t_dtor_actors_rewind_context(buff) ((void(__fastcall*)(char*))ao(oactors_rewind_context_t_dtor_actors_rewind_context_t))(buff)

#define ANTICHEAT_DECRYPT(fn, args) ((t ## fn)((__int64)anticheat_static::fn ^ ANTICHEAT_PTR_ENCRYPT_XOR))args

/*
    Theory and Design:

        Active Detection:
            - Scanning modules and memory regions in the game for suspicious things (strings, values, signatures, etc)
            - Runs slowly and methodically. May not detect some forms of cheats that hide well.

        Passive Detection:
            - Detects cheats which perform actions atypical to normal game functionality
            - Calls to protected functions, pointers to bad or suspicious memory, strange values or known exploits.
            - Very strong against particular exploits but may not catch things like ESP that dont rely on game functions

        Heuristic Detection:
            - Server authoritative logic that determines suspicious behavrior is cheating
            - Damage locs consistently microscopically close to bone indexes, accuracy ratings too high, players within FOV for abnormally large percentages of time
            - Use cheater psychology against them. Cheaters play differently than legitimate players and we can leverage statistical analysis to find and stop cheaters this way.

        Player Detection:
            - Support player reports where players can vote to kick cheaters themselves. No software knows cheaters better than the players.

        Functional Prevention:
            - Stop cheaters from being able to execute on certain features (ie: masking certain critical values or protecting pointers such that cheaters cannot access the data they need)

        Defensive Detection:
            - Check for modifications to the ZBR dll. Players that modify ZBR's code are obviously cheaters and need to be stopped.
            - Debugging and other suspicious behavior indicates signs of malicious intent and can be used offensively.



        Things to check integrity of:
            - Various memory hooks in BO3 memory (check to make sure signature of hooks matches typical zbr hook behavior)
            - Check hooks for QueryPerformanceCounter and GetKeyState

*/

bool anticheat_static::is_initialized = false;
__int32 anticheat_static::fast_quit_reason = 0;
__int32 anticheat_static::imgui_suspicious_key = 0;

// to prevent people from just setting the fast quit reason to 0, we need encrypted fast fail reasons too that can be used by other subsystems
__int32 anticheat_static::fast_quit_reason_array[SAC_SUBSYSTEM_COUNT];
__int32 anticheat_static::last_checked_time = 0;

unsigned __int64 ___lastReturnAddress = 0;
MDT_Define_FASTCALL(&QueryPerformanceCounter, QueryPerformanceCounter_hook, BOOL, (LARGE_INTEGER* lpcounter))
{
    ___lastReturnAddress = (unsigned __int64)_ReturnAddress();    
    return MDT_ORIGINAL(QueryPerformanceCounter_hook, (lpcounter));
}

MDT_Define_FASTCALL(&GetKeyState, GetKeyState_hook, SHORT, (int key))
{
    if ((unsigned __int64)_ReturnAddress() - ___lastReturnAddress < 0x100 )
    {
        anticheat_static::imgui_suspicious_key = key;
    }
    
    return MDT_ORIGINAL(GetKeyState_hook, (key));
}

namespace anticheat
{
    #pragma optimize( "", off )
    PEB* GetPEB()
    {
        return (PEB*)__readgsqword(0x60);
    }

    __int64 dec_off(__int64 off)
    {
        return off ^ 0xc593ed1;
    }

    // update memory sections cache using virtual query
    // tag each section with info about its usage



    std::chrono::time_point next_cache_update = std::chrono::high_resolution_clock::now();
    void update_section_cache()
    {
        /*if (std::chrono::high_resolution_clock::now() < next_cache_update)
        {
            return;
        }
        next_cache_update = std::chrono::high_resolution_clock::now() + std::chrono::milliseconds(1000);
        MEMORY_BASIC_INFORMATION mbi;
        unsigned char* addr = 0;
        while (ANTICHEAT_DECRYPT(VirtualQuery, (addr, &mbi, sizeof(mbi))))
        {
            if (mbi.State == MEM_COMMIT && mbi.Protect != PAGE_NOACCESS && mbi.Protect != PAGE_GUARD)
            {

            }
            addr += mbi.RegionSize;
        }*/
    }

    void update_search_for_badtext()
    {
        VMP_EXTRA_LIGHT_START("badtext");
        if (anticheat_static::fast_quit_reason)
        {
            return;
        }
        // TOOD: continue search for text signatures that we believe are malicious
        VMP_EXTRA_LIGHT_END();
    }

    void update_search_for_imgui()
    {
        VMP_EXTRA_LIGHT_START("imgui");
        if (anticheat_static::fast_quit_reason)
        {
            return;
        }
        // TODO: continue search for imgui signatures
        VMP_EXTRA_LIGHT_END();
    }

    int verify_dvar_values_lck;
    void verify_dvar_values()
    {
        VMP_EXTRA_LIGHT_START("dvars");
        if (verify_dvar_values_lck)
        {
            ANTICHEAT_CHECK_FAILED(ANTICHEAT_REASON_BAD_DVAR);
        }

        // TODO: verify dvar function signatures to prevent hooks

        // dvar size 0xA0
        //auto num_dvars = *(__int32*)OFFSET(0x17AC81CC);
        //ac_dvar_t* s_dvarpool = (ac_dvar_t*)OFFSET(0x17AC8220);
        
        if (DVAR_GetInt(DVAR_FindVar(av(vHASH_SV_CHEATS)))) // f70e34e1
        {
            anticheat_static::fast_quit_reason = ANTICHEAT_REASON_BAD_DVAR;
            verify_dvar_values_lck = 1;
            return;
        }

        // TODO: check certain dvars that cheaters like to mess with:
        // r_fog
        // cg_thirdperson
        VMP_EXTRA_LIGHT_END();
    }

    void verify_hook_integrity()
    {
        if (anticheat_static::fast_quit_reason)
        {
            return;
        }
        // TODO: check all hook memory signatures
    }

    void update_hook_signatures()
    {
        if (anticheat_static::fast_quit_reason)
        {
            return;
        }
        // TODO: set all hook memory signatures
    }

    void* get_proc_address(HMODULE module, __int64 proc_name)
    {
        char* modb = (char*)module;

        IMAGE_DOS_HEADER* dos_header = (IMAGE_DOS_HEADER*)modb;
        IMAGE_NT_HEADERS* nt_headers = (IMAGE_NT_HEADERS*)(modb + dos_header->e_lfanew);
        IMAGE_OPTIONAL_HEADER* opt_header = &nt_headers->OptionalHeader;
        IMAGE_DATA_DIRECTORY* exp_entry = (IMAGE_DATA_DIRECTORY*)
            (&opt_header->DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT]);
        IMAGE_EXPORT_DIRECTORY* exp_dir = (IMAGE_EXPORT_DIRECTORY*)(modb + exp_entry->VirtualAddress);
        DWORD* func_table = (DWORD*)(modb + exp_dir->AddressOfFunctions);
        WORD* ord_table = (WORD*)(modb + exp_dir->AddressOfNameOrdinals);
        DWORD* name_table = (DWORD*)(modb + exp_dir->AddressOfNames);
        void* address = NULL;

        DWORD i;

        /* is ordinal? */
        if (((DWORD)proc_name >> 16) == 0) {
            WORD ordinal = LOWORD(proc_name);
            DWORD ord_base = exp_dir->Base;
            /* is valid ordinal? */
            if (ordinal < ord_base || ordinal > ord_base + exp_dir->NumberOfFunctions)
                return NULL;

            /* taking ordinal base into consideration */
            address = (void*)(modb + (DWORD)func_table[ordinal - ord_base]);
        }
        else {
            /* import by name */
            for (i = 0; i < exp_dir->NumberOfNames; i++) {
                /* name table pointers are rvas */
                if (proc_name == GSCUHashing::canon_hash64(modb + name_table[i]))
                    address = (void*)(modb + (DWORD)func_table[ord_table[i]]);
            }
        }
        /* is forwarded? */
        if ((char*)address >= (char*)exp_dir &&
            (char*)address < (char*)exp_dir + exp_entry->Size) {
            char* dll_name, * func_name;
            HMODULE frwd_module;
            dll_name = _strdup((char*)address);
            if (!dll_name)
                return NULL;
            address = NULL;
            func_name = strchr(dll_name, '.');
            *func_name++ = 0;

            /* is already loaded? */
            frwd_module = GetModuleHandle(dll_name);
            if (!frwd_module)
                frwd_module = LoadLibrary(dll_name);

            if (frwd_module)
                address = get_proc_address(frwd_module, GSCUHashing::canon_hash64(func_name));

            free(dll_name);
        }
        return address;
    }

    __int64 get_function(__int64 dllName, __int64 functionName)
    {
        char cstr[256];
        LDR_DATA_TABLE_ENTRY* modEntry = nullptr;

        PEB* peb = GetPEB();

        LIST_ENTRY head = peb->Ldr->InMemoryOrderModuleList;

        LIST_ENTRY curr = head;

        for (auto curr = head; curr.Flink != &peb->Ldr->InMemoryOrderModuleList; curr = *curr.Flink)
        {
            LDR_DATA_TABLE_ENTRY* mod = (LDR_DATA_TABLE_ENTRY*)CONTAINING_RECORD(curr.Flink, LDR_DATA_TABLE_ENTRY, InMemoryOrderLinks);

            if ((*(_UNICODE_STRING*)((char*)mod + 0x058)).Buffer)
            {             
                size_t converted;
                wcstombs_s(&converted, cstr, (*(_UNICODE_STRING*)((char*)mod + 0x058)).Buffer, 255);
                auto result = GSCUHashing::canon_hash64(cstr);
                if (result == dllName)
                {
                    return (__int64)get_proc_address((HMODULE)mod->DllBase, functionName);
                }
            }
        }
        return 0;
    }

    void init_static_values()
    {
        VMP_EXTRA_HEAVY_START("init_static_values");
        // TODO: convert these all to externs
        anticheat_static::scr_bones[0] = anticheat_static::j_helmet = ((__int32(__fastcall*)(const char*))ao(oScr_AllocString))((const char*)ao(oj_helmet));
        anticheat_static::scr_bones[1] = anticheat_static::j_head = ((__int32(__fastcall*)(const char*))ao(oScr_AllocString))((const char*)ao(oj_head));
        anticheat_static::scr_bones[2] = anticheat_static::j_neck = ((__int32(__fastcall*)(const char*))ao(oScr_AllocString))((const char*)ao(oj_neck));
        anticheat_static::scr_bones[3] = anticheat_static::j_spineupper = ((__int32(__fastcall*)(const char*))ao(oScr_AllocString))((const char*)ao(oj_spineupper));
        anticheat_static::scr_bones[4] = anticheat_static::j_spinelower = ((__int32(__fastcall*)(const char*))ao(oScr_AllocString))((const char*)ao(oj_spinelower));
        anticheat_static::scr_bones[5] = anticheat_static::j_shoulder_le = ((__int32(__fastcall*)(const char*))ao(oScr_AllocString))((const char*)ao(oj_shoulder_le));
        anticheat_static::scr_bones[6] = anticheat_static::j_shoulder_ri = ((__int32(__fastcall*)(const char*))ao(oScr_AllocString))((const char*)ao(oj_shoulder_ri));
        anticheat_static::scr_bones[7] = anticheat_static::j_hip_le = ((__int32(__fastcall*)(const char*))ao(oScr_AllocString))((const char*)ao(oj_hip_le));
        anticheat_static::scr_bones[8] = anticheat_static::j_knee_le = ((__int32(__fastcall*)(const char*))ao(oScr_AllocString))((const char*)ao(oj_knee_le));
        anticheat_static::scr_bones[9] = anticheat_static::j_knee_ri = ((__int32(__fastcall*)(const char*))ao(oScr_AllocString))((const char*)ao(oj_knee_ri));
        anticheat_static::scr_bones[10] = anticheat_static::j_elbow_le = ((__int32(__fastcall*)(const char*))ao(oScr_AllocString))((const char*)ao(oj_elbow_le));
        anticheat_static::scr_bones[11] = anticheat_static::j_elbow_ri = ((__int32(__fastcall*)(const char*))ao(oScr_AllocString))((const char*)ao(oj_elbow_ri));
        anticheat_static::scr_bones[12] = anticheat_static::j_ankle_le = ((__int32(__fastcall*)(const char*))ao(oScr_AllocString))((const char*)ao(oj_ankle_le));
        anticheat_static::scr_bones[13] = anticheat_static::j_ankle_ri = ((__int32(__fastcall*)(const char*))ao(oScr_AllocString))((const char*)ao(oj_ankle_ri));

        for (int i = 0; i < (int)SAC_SUBSYSTEM_COUNT; i++)
        {
            anticheat_static::fast_quit_reason_array[i] = 0;
        }
        VMP_EXTRA_HEAVY_END();
    }
    
    void init_function_references()
    {
        // anticheat::CreateThread = (tCreateThread)get_function(CONST64("Kernel32.dll"), CONST64("CreateThread"));
        // anticheat::SuspendThread = (tSuspendThread)get_function(CONST64("Kernel32.dll"), CONST64("SuspendThread"));
        // anticheat::OpenThread = (tOpenThread)get_function(CONST64("Kernel32.dll"), CONST64("OpenThread"));
        // anticheat::GetThreadContext = (tGetThreadContext)get_function(CONST64("Kernel32.dll"), CONST64("GetThreadContext"));
        // anticheat::SetThreadContext = (tSetThreadContext)get_function(CONST64("Kernel32.dll"), CONST64("SetThreadContext"));
        // anticheat::ResumeThread = (tResumeThread)get_function(CONST64("Kernel32.dll"), CONST64("ResumeThread"));
        // anticheat::GetCurrentThreadId = (tGetCurrentThreadId)get_function(CONST64("Kernel32.dll"), CONST64("GetCurrentThreadId"));
        VMP_EXTRA_HEAVY_START("init function refs");
        anticheat_static::GetActiveWindow = (tGetActiveWindow)((__int64)&GetActiveWindow ^ ANTICHEAT_PTR_ENCRYPT_XOR);
        anticheat_static::MessageBoxA = (__int64)&MessageBoxA ^ ANTICHEAT_PTR_ENCRYPT_XOR;
        anticheat_static::VirtualQuery = (tVirtualQuery)((__int64)&VirtualQuery ^ ANTICHEAT_PTR_ENCRYPT_XOR);
        VMP_EXTRA_HEAVY_END();
    }

    void initialize()
    {
        VMP_EXTRA_LIGHT_START("anticheat ii");
        
        if (anticheat_static::is_initialized)
        {
            return;
        }

        anticheat_static::is_initialized = true;
        
        init_function_references();
        init_static_values();
        // TODO: destroy cbuf add function and encrypt the pointer to the table
        // TODO: Cmd_AddCommandInternal, also, walk the chain for pointers to non-bo3 regions
        // TODO LdrRegisterDllNotification so we can find out when new dlls are loaded and check against ones we dont like (lazy detection)
        DetourTransactionBegin();
        DetourUpdateThread(GetCurrentThread());
        MDT_Activate(QueryPerformanceCounter_hook);
        MDT_Activate(GetKeyState_hook);
        DetourTransactionCommit();
        XLOG("Anticheat initialized");
        VMP_EXTRA_LIGHT_END();
    }

    #define NUM_PARAMS_WEAPON_FIRE 8
    AntilagStore antilag_store{};
    actors_rewind_context_t actors_rewind_context{};
    MDT_Define_FASTCALL(REBASE(av(vFireWeapon)), FireWeapon_Hook, bool, (char* ent, __int32 gametime, __int32 _event, int shotCount))
    {
        auto v8 = ((__int64(__fastcall*)(__int32, __int64, __int32))ao(oG_GetWeaponDefBasedOnNumberOfBullets))(shotCount, *(__int64*)(ent + 440), (unsigned int)(gametime - 32) <= 1);

        if (v8 && (v8 & 0x1FF)) // valid weapon
        {
            // this is a player firing their weapon. We need to push better context info for the anticheat
            // size of g_entity: 0x4F8
            // ent + 0x250 is client pointer, if it exists, it is a player
            __int32 ent_num = *(__int32*)ent; // grab ent number so we can find g_entities
            char* g_entities = ent - (ent_num * 0x4F8);

            *(__int32*)((char*)&actors_rewind_context + 0x600) = 0;
            if (*(__int64*)(ent + 0x250))
            {
                actors_rewind_context_t_rewind(&actors_rewind_context, *(__int32*)ao(oLevel_time), gametime, 1023);
                AdjustMovers(1, 0, gametime, 1, ent);
            }

            G_AntiLagRewindClientPos(gametime, &antilag_store);
            bool isLinked = G_EntIsLinked(ent);

            if (DVAR_GetInt(*(__int64*)ao(og_actorAndVehicleAntilag)) && !isLinked)
            {
                G_AntiLag_RewindActorPos(gametime, ((char*)&antilag_store) + 0x29B0);
                G_AntiLag_RewindVehiclePos(gametime, ((char*)&antilag_store) + 0x2FF0);
            }

            vec3_t forward{};
            vec3_t eye{};
            G_GetPlayerViewDirection(ent, &forward, (__int64)0, (__int64)0);
            G_GetPlayerViewOrigin((char*)*(__int64*)(ent + 0x250), &eye);


            // clients are always the first 18 entities

            float smallest_angle = 400;
            __int32 closest_tag_index = -1;
            __int32 ent_index = -1;
            float cached_dist_to_tag = 0;
            vec3_t closest_bone_loc{};

            float sum_fwd = (forward.v.x * forward.v.x) + (forward.v.y * forward.v.y) + (forward.v.z * forward.v.z); // vector length squared
            float dist_to_eye = sqrt(sum_fwd);

            char* closest_client = NULL;
            for (int i = 0; i < 18; i++)
            {
                char* client = g_entities + i * 0x4F8;
                if (client == ent)
                {
                    continue;
                }

                if (!*(__int64*)(client + 0x250))
                {
                    continue; // invalid entity
                }

                if (*(__int64*)(client + 600)) // ent->actor
                {
                    if (!*(__int32*)(*(__int64*)(client + 600) + 1976))
                    {
                        continue;
                    }
                }
                else
                {
                    if (*(__int32*)(client + 712) <= 0) // ent->health
                    {
                        continue;
                    }
                }

                // check sessionstate
                auto sessionstate = *(__int32*)(*(__int64*)(client + 0x250) + 0x16AE0);
                
                if (sessionstate != 0) // sessionstate != playing
                {
                    continue;
                }

                // player is alive and valid, lets grab information about their position relative to our ads
                // we want to find the smallest dot product we can calculate while iterating all known aimbot target tags and getting the direction vec from our view origin
                // update this tag info in a local array, storing dot result AND origin of the tag

                for (int j = 0; j < NUM_SCR_BONES; j++)
                {
                    auto bone = anticheat_static::scr_bones[j];

                    if (!GScr_UpdateTagInternal(client, bone, ao(olevel_cachedtagmatrix)))
                    {
                        continue; // bone unavailable. maybe they are invis, in last stand, etc?
                    }

                    vec3_t bone_origin = *(vec3_t*)(ao(olevel_cachedtagmatrix) + 0x30);
                    vec3_t dir_eye_to_bone{};
                    dir_eye_to_bone.v.x = bone_origin.v.x - eye.v.x;
                    dir_eye_to_bone.v.y = bone_origin.v.y - eye.v.y;
                    dir_eye_to_bone.v.z = bone_origin.v.z - eye.v.z;
                    
                    float dot_product = (forward.v.x * dir_eye_to_bone.v.x) + (forward.v.y * dir_eye_to_bone.v.y) + (forward.v.z * dir_eye_to_bone.v.z); // (a.x * b.x) + (a.y * b.y) + (a.z * b.z)
                    float sum_to_bone = (dir_eye_to_bone.v.x * dir_eye_to_bone.v.x) + (dir_eye_to_bone.v.y * dir_eye_to_bone.v.y) + (dir_eye_to_bone.v.z * dir_eye_to_bone.v.z); // vector length squared
                    float dist_to_bone = sqrt(sum_to_bone);
         
                    float prod = dist_to_eye * dist_to_bone;

                    if (prod == 0)
                    {
                        continue; // somehow we got a 0 length vector?
                    }

                    float cos_ang = dot_product / prod; // ABcos(theta) / AB => cos(theta)
                    float ang_rad = acos(cos_ang); // acos(cos(theta)) => theta (in rad)
                    float ang_deg = ang_rad * 180 / (float)M_PI; // angle in degrees between the attacker's look vector and the bone 

                    ang_deg = abs(ang_deg);
                    if (smallest_angle > ang_deg)
                    {
                        ent_index = *(__int32*)(client);
                        closest_tag_index = j;
                        closest_bone_loc = bone_origin;
                        smallest_angle = ang_deg;
                        cached_dist_to_tag = dist_to_bone;
                    }
                }
            }

            
            if (DVAR_GetInt(*(__int64*)ao(og_actorAndVehicleAntilag)) && !isLinked)
            {
                G_AntiLag_RestoreActorPos(((char*)&antilag_store) + 0x29B0);
                G_AntiLag_RestoreVehiclePos(((char*)&antilag_store) + 0x2FF0);
            }
            
            G_AntiLag_RestoreClientPos((char*)&antilag_store);

            if (*(__int64*)(ent + 0x250))
            {
                RestoreMovers(1, 0, 1);
            }

            actors_rewind_context_t_dtor_actors_rewind_context((char*)&actors_rewind_context);

            // lets just do this calculation in C because it should be more performant

            auto h = cached_dist_to_tag / (sin((90 - smallest_angle) * M_PI / 180)); // law of sines
            
            vec3_t normalized_eye = forward;
            normalized_eye.v.x /= dist_to_eye;
            normalized_eye.v.y /= dist_to_eye;
            normalized_eye.v.z /= dist_to_eye;

            vec3_t final_position = eye;
            final_position.v.x += normalized_eye.v.x * h;
            final_position.v.y += normalized_eye.v.y * h;
            final_position.v.z += normalized_eye.v.z * h;

            vec3_t delta;
            delta.v.x = final_position.v.x - closest_bone_loc.v.x;
            delta.v.y = final_position.v.y - closest_bone_loc.v.y;
            delta.v.z = final_position.v.z - closest_bone_loc.v.z;

            // push calculated delta vector. we could just do this logic in the vm but its faster to do it here
            ((void(__fastcall*)(int, vec3_t*))ao(oScr_AddVec))(0, &delta);

            // push victim ent num
            ((void(__fastcall*)(int, int))ao(oScr_AddInt))(0, ent_index);

            // push tag index
            ((void(__fastcall*)(int, int))ao(oScr_AddInt))(0, closest_tag_index);

            // push angle
            ((void(__fastcall*)(int, float))ao(oScr_AddFloat))(0, smallest_angle);

            // push closest bone origin
            ((void(__fastcall*)(int, vec3_t*))ao(oScr_AddVec))(0, &closest_bone_loc);

            // push player view origin
            ((void(__fastcall*)(int, vec3_t*))ao(oScr_AddVec))(0, &eye);

            // push player angles
            ((void(__fastcall*)(int, vec3_t*))ao(oScr_AddVec))(0, &forward);
        }

        return MDT_ORIGINAL(FireWeapon_Hook, (ent, gametime, _event, shotCount));
    }

    char old_cons_data[0x4E];
    void run_callbacks()
    {
        VMP_EXTRA_LIGHT_START("anticheat callbacks run");
        initialize();
        if ((time(NULL) - anticheat_static::last_checked_time) >= HOOK_ANTICHEAT_CALLBACK_CHECK_INTERVAL)
        {
            /*Offsets::Log("CHECKING... %d %p", anticheat_static::fast_quit_reason, &anticheat_static::fast_quit_reason);*/
            // fast_quit_reason = ANTICHEAT_REASON_THIRD_PERSON;
            if (anticheat_static::fast_quit_reason)
            {
                ANTICHEAT_CHECK_FAILED(anticheat_static::fast_quit_reason);
                return;
            }

            if (anticheat_static::imgui_suspicious_key == 17 || anticheat_static::imgui_suspicious_key == 16 || anticheat_static::imgui_suspicious_key == 18)
            {
                ANTICHEAT_CHECK_FAILED(ANTICHEAT_REASON_IMGUI);
            }

            for (int i = 0; i < (int)SAC_SUBSYSTEM_COUNT; i++)
            {
                if (anticheat_static::fast_quit_reason_array[i])
                {
                    anticheat_static::fast_quit_reason = anticheat_static::fast_quit_reason_array[i];
                    ANTICHEAT_CHECK_FAILED(anticheat_static::fast_quit_reason);
                    return;
                }
            }

            if (VMP_ISVMPRESENT())
            {
                ANTICHEAT_CHECK_FAILED(ANTICHEAT_REASON_VM);
            }

            /*if (VMP_ISDEBUGGED())
            {
                ANTICHEAT_CHECK_FAILED(ANTICHEAT_REASON_DEBUGGER);
            }*/
            
            arxan_evasion::register_hook_unique(HOOK_ANTICHEAT_HOOKS,
                []()
                {
                    VMP_EXTRA_LIGHT_START("anticheat hook enabler");
                    // TODO: remove console enabling functions. look at sub_1339870 for the visibility and render calls and make sure that if it is ever force set we kill the game
                    // TODO hook and immediate value search (note: immediate value searching probably not a great idea since there are the dumbass versions)
                    // RegisterTag
                    // Com_GetClientDObj
                    // AimTarget_IsTargetVisible
                    // CG_DObjGetWorldTagPosInternal
                    // CG_GetPlayerViewOrigin (spoofed call)
                    // DDL_MoveToPath
                    // DDL_SetUInt
                    // LobbyMsgRW_PrepWriteMsg
                    // LobbyMsgRW_PackageInt
                    // dwInstantSendMessage
                    // LobbyMsgTransport_SendToAdr
                    // SV_GameSendServerCommand
                    // Detect manual lua compilation at runtime
                    // These hooks should basically implement an extremely fast checker that fires on certain conditions so that we dont tank performance
                    // Walk stack and check for executable regions. memory regions are cached and marked with flags related to what action they were discovered in, ie: ACTION_CBUF_ADDTEXT, ACTION_GETTAGPOSINTERNAL
                    // Use contextual information about the memory regions to determine potential cheat actions
                    // additionally, check heap allocators for certain pass by reference variables. for stack vars, verify on stack. for heap vars, verify on game heap.

                   /* DetourTransactionBegin();
                    DetourUpdateThread(GetCurrentThread());
                    MDT_Activate(FireWeapon_Hook);
                    DetourTransactionCommit();

                    auto OldProtection = 0ul;
                    VirtualProtect((__int32*)ao(oFireWeapon), 4, PAGE_EXECUTE_READWRITE, &OldProtection);
                    *(__int32*)ao(oFireWeapon) = NUM_PARAMS_WEAPON_FIRE;
                    VirtualProtect((__int32*)ao(oFireWeapon), 4, OldProtection, &OldProtection);*/

                    // destroy console renderer 1339884-13398D2 (nop)
                    auto OldProtection = 0ul;
                    VirtualProtect((__int32*)ao(oStartConsoleRender), 0x4E, PAGE_EXECUTE_READWRITE, &OldProtection);
                    memcpy(old_cons_data, (void*)ao(oStartConsoleRender), 0x4E);
                    memset((void*)ao(oStartConsoleRender), 0x90, 0x4E);
                    VirtualProtect((__int32*)ao(oStartConsoleRender), 0x4E, OldProtection, &OldProtection);

                    // set a trap ud2 for anyone who manually calls the render
                    VirtualProtect((__int32*)ao(oACRenderConsole), 0x2, PAGE_EXECUTE_READWRITE, &OldProtection);
                    *(__int16*)ao(oACRenderConsole) = 0x0B0F; // ud2
                    VirtualProtect((__int32*)ao(oACRenderConsole), 0x2, OldProtection, &OldProtection);

                    update_hook_signatures();
                    VMP_EXTRA_LIGHT_END();
                },
                []()
                {
                    VMP_EXTRA_LIGHT_START("anticheat hook disabler");
                    verify_hook_integrity(); // arxan is doing it, why shouldnt we!
                    /*DetourTransactionBegin();
                    DetourUpdateThread(GetCurrentThread());
                    MDT_Deactivate(FireWeapon_Hook);
                    DetourTransactionCommit();

                    auto OldProtection = 0ul;
                    VirtualProtect((__int32*)ao(oFireWeapon), 4, PAGE_EXECUTE_READWRITE, &OldProtection);
                    *(__int32*)ao(oFireWeapon) = 1;
                    VirtualProtect((__int32*)ao(oFireWeapon), 4, OldProtection, &OldProtection);*/

                    auto OldProtection = 0ul;
                    VirtualProtect((__int32*)ao(oStartConsoleRender), 0x4E, PAGE_EXECUTE_READWRITE, &OldProtection);
                    memcpy((void*)ao(oStartConsoleRender), old_cons_data, 0x4E);
                    VirtualProtect((__int32*)ao(oStartConsoleRender), 0x4E, OldProtection, &OldProtection);

                    VirtualProtect((__int32*)ao(oACRenderConsole), 0x2, PAGE_EXECUTE_READWRITE, &OldProtection);
                    *(__int16*)ao(oACRenderConsole) = 0x44f3;
                    VirtualProtect((__int32*)ao(oACRenderConsole), 0x2, OldProtection, &OldProtection);

                    VMP_EXTRA_LIGHT_END();
                }, true);

            anticheat_static::last_checked_time = time(NULL);

            // verification subroutines need to run in the scheduled queue because they are lightweight relatively speaking
            verify_hook_integrity();
            verify_dvar_values();
            // TODO verify ZBR DLL integrity
            // TODO verify ZBR script integrity
            // TODO detect gsc injection
            // TODO detect IL script injection
            // TODO walk VEH chain for suspicious handlers (check immediate values and such)
        }

        // search updaters can run out of loop bounds because they are heavyweight relatively speaking and will run batch style, but need more frequent event pushes
        // TOOD multithread this update_section_cache();
        update_search_for_imgui();
        update_search_for_badtext();
        VMP_EXTRA_LIGHT_END();
    }
    #pragma optimize("", on)
}

#else
#pragma optimize("", off)
void anticheat::run_callbacks()
{
    int a = 0x11223344;
    a += 0x44332211;
}
#pragma optimize("", on)
#endif