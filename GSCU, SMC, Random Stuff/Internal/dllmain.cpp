// https://stackoverflow.com/questions/219381/how-to-exclude-files-from-visual-studio-compile/219394
// https://github.com/ntoskrnl7/crtsys
#include "gscu_api_private.h"

#define DLL_PROCESS_ATTACH   1    
#define DLL_THREAD_ATTACH    2    
#define DLL_THREAD_DETACH    3    
#define DLL_PROCESS_DETACH   0   

int __fastcall DllMain( void* hModule, __int32  ul_reason_for_call, void* lpReserved)
{
    switch (ul_reason_for_call)
    {
        case DLL_PROCESS_ATTACH:
        case DLL_THREAD_ATTACH:
        case DLL_THREAD_DETACH:
        case DLL_PROCESS_DETACH:
            break;
    }

    return 1;
}