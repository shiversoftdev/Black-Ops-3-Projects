// dllmain.cpp : Defines the entry point for the DLL application.
#include "framework.h"
#include "..\build\api\cpp\gscu_api.h"
#include <stdio.h>

#if defined _DEBUG
#define DEVELOPMENT
// #define LNKINFO
#endif

#ifdef DEVELOPMENT
#define DPRINT(fmt, ...) printf(fmt "\n", __VA_ARGS__)
#else
#define DPRINT(...) 
#endif

#ifdef LNKINFO
#define LDPRINT(fmt, ...) DPRINT(fmt, __VA_ARGS__)
#else
#define LDPRINT(fmt, ...) 
#endif

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

#define EXPORT extern "C" __declspec(dllexport)

bool api_loaded = false;
gscu_api gscu_inst;
HGSCUVM gscu_vm = NULL;

typedef int(__cdecl* gscu_api_init)(gscu_api&);

__int32 load_api()
{
    gscu_inst.is_valid = false;
    auto mod = LoadLibraryA("gscurt.dll");

    if (mod <= 0)
    {
        return -1;
    }

    auto hApiInit = GetProcAddress(mod, "gscu_api_init");
    
    if (hApiInit <= 0)
    {
        return -2;
    }

    auto result = ((gscu_api_init)hApiInit)(gscu_inst);

    if (result != GSCU_ERR_NOERR)
    {
        return result;
    }

    DPRINT("DBG: GSCU API initialized. %p", &gscu_inst);
    DPRINT("DBG: Creating VM instance.");

    gscu_vm = gscu_inst.create_vm();
    api_loaded = true;

    DPRINT("DBG: VM created.");
    return 0;
}

const char* buffers_list[4096]{};
EXPORT __int32 exec(const char* buffers, __int32* buffer_sizes, __int32 count)
{
    if (count > 4096)
    {
        return -1000;
    }

    if (!api_loaded)
    {
        auto result = load_api();
        if (result)
        {
            DPRINT("DBG: FAILED to load api. %x %d", result, result);
            return result;
        }
    }

    const char* bufferPtr = buffers;
    for (int i = 0; i < count; i++)
    {
        buffers_list[i] = bufferPtr;
        bufferPtr += buffer_sizes[i];

    }

    DPRINT("DBG: Loading objects.");

    auto res = gscu_inst.load(gscu_vm, buffers_list, count);

    if (res)
    {
        DPRINT("DBG: FAILED to load objects %8X.", res);
        return res;
    }

    DPRINT("DBG: Objects loaded.");
    DPRINT("DBG: Linking objects.");

    res = gscu_inst.link(gscu_vm, buffers_list, count);

    if (res)
    {
        char last_error[4096]{};
        gscu_inst.get_last_link_error(gscu_vm, last_error, 4096);
        DPRINT("DBG: FAILED to link objects %X (%s)", res, last_error);
        return res;
    }

    DPRINT("DBG: Objects linked.");

    return 0;
}

EXPORT __int32 tick()
{
    if (!gscu_inst.is_valid || !api_loaded)
    {
        return 0;
    }

    gscu_inst.tick(gscu_vm);

    return 0;
}