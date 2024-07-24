// dllmain.cpp : Defines the entry point for the DLL application.
#include "framework.h"
#include <iostream>
#include <Winternl.h>

#define EXPORT extern "C" __declspec(dllexport)
#define REBASE(x) (*(unsigned __int64*)((unsigned __int64)(NtCurrentTeb()->ProcessEnvironmentBlock) + 0x10) + (unsigned __int64)(x))

EXPORT void dummy_proc()
{

}

DWORD WINAPI watch_ready_inject(_In_ LPVOID lpParameter)
{
    for (;;)
    {
        Sleep(10);
        if (*(__int64*)REBASE(0x168ED8C8))
        {
            break;
        }
    }

    auto hmod = LoadLibraryA("t7patch.dll");
    LoadLibraryA("zbr2.dll");
    ((void(__fastcall*)())GetProcAddress(hmod, "EnableInjectorlessInstall"))();
    ((void(__fastcall*)(const char*))GetProcAddress(hmod, "zbr_run_gamemode_lui"))("serious_anticrash_2023"); // ok intellisense, the first line is bad but this one is ok. thx!
    printf("Loaded t7patch successfully.\n");
    return 0;
}

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
        CreateThread(NULL, NULL, watch_ready_inject, NULL, NULL, NULL);
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

