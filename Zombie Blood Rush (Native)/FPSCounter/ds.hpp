#pragma once

#define IS_PATCH_ONLY 1
#define PATCH_DEBUG_PRINTS 0

// 1000 / 128 => 8
#define ZBR_TICKRATE 0x08
#define ZBR_SV_FPS 120
#define OLD_TICKRATE 0x32
#define SIGNATURE_DLL 0xABCDEF69
#define BUFFER_SIZE 2000000
#define TX_SIZE 0x1000
#define TABLE_SIZE 0x1000
#define VM_XOR_KEY 0x6E
#define PID_XOR_KEY 0x4357FC1D
#define VM_CODEMASK 0x14E7
#define TX_MASK 0x7F53EB31FCCBA841
extern char IDENTIFIER[];
extern DWORD TARGET_PID;
extern UINT64 MODULE_HANDLE;
extern DWORD SIGNATURE;
extern char SCRIPT_BUF[BUFFER_SIZE];
extern char CONFIG_BUF[TX_SIZE];
extern INT16 OPCODES[TABLE_SIZE];
extern INT64 HANDLERS[TABLE_SIZE];

//USE_PROTECTION = winlicense
//#define USE_PROTECTION
#define PROTECTION_ALL 3
#define PROTECTION_MAJOR_ONLY 2
#define PROTECTION_STRINGS_ONLY 1
#define PROTECTION_NONE 0
#define PROTECTION_STRIPPED -1

#define USE_CV PROTECTION_STRIPPED
#define USE_VMP PROTECTION_STRIPPED

#define VMP_ISDEBUGGED() false
#define VMP_ISVMPRESENT() false
#define VMP_CHECKINTEGRITY() true
#define VMP_EXTRA_LIGHT_START()
#define VMP_EXTRA_LIGHT_END()
#define VMP_EXTRA_HEAVY_START()
#define VMP_EXTRA_HEAVY_END()

// #define USE_MASKING
// #define USE_NLOG

#if USE_CV > PROTECTION_STRIPPED
#include "CodeVirtualizerSDK/Include/C/VirtualizerSDK.h"
#include "CodeVirtualizerSDK/StealthMode/C/StealthCodeArea/StealthCodeArea_Max.h"
#endif

#if USE_CV > PROTECTION_NONE
#define PROTECT_STRINGS_START(section) VIRTUALIZER_STR_ENCRYPT_START
#define PROTECT_STRINGS_END() VIRTUALIZER_STR_ENCRYPT_END
#define PROTECT_HEAVY_START(section) VIRTUALIZER_STR_ENCRYPT_START
#define PROTECT_HEAVY_END() VIRTUALIZER_STR_ENCRYPT_END
#define PROTECT_LIGHT_START(section) VIRTUALIZER_STR_ENCRYPT_START
#define PROTECT_LIGHT_END() VIRTUALIZER_STR_ENCRYPT_END
#else
#define PROTECT_STRINGS_START(section)
#define PROTECT_STRINGS_END()
#define PROTECT_HEAVY_START(section)
#define PROTECT_HEAVY_END()
#define PROTECT_LIGHT_START(section)
#define PROTECT_LIGHT_END()
#endif

#if USE_CV > PROTECTION_STRINGS_ONLY
#define PROTECT_HEAVY_START(section) VIRTUALIZER_SHARK_WHITE_START
#define PROTECT_HEAVY_END() VIRTUALIZER_SHARK_WHITE_END
#endif

#if USE_CV > PROTECTION_MAJOR_ONLY
#define PROTECT_LIGHT_START(section) VIRTUALIZER_MUTATE_ONLY_START
#define PROTECT_LIGHT_END() VIRTUALIZER_MUTATE_ONLY_END
#endif

#if USE_VMP > PROTECTION_STRIPPED
#include "include\VMProtectSDK.h"
#endif

#if USE_VMP > PROTECTION_NONE
#define PROTECT_STRINGS_START(section) VMProtectBeginMutation(section)
#define PROTECT_STRINGS_END() VMProtectEnd()
#define PROTECT_HEAVY_START(section) VMProtectBeginMutation(section)
#define PROTECT_HEAVY_END() VMProtectEnd()
#define PROTECT_LIGHT_START(section) VMProtectBeginMutation(section)
#define PROTECT_LIGHT_END() VMProtectEnd()
#endif

#if USE_VMP == PROTECTION_MAJOR_ONLY
#define PROTECT_LIGHT_START() 
#define PROTECT_LIGHT_END() 
#endif

#if USE_VMP >= PROTECTION_ALL
#define PROTECT_HEAVY_START(section) VMProtectBeginVirtualization(section)
#define PROTECT_HEAVY_END() VMProtectEnd()
#define VMP_ISDEBUGGED() VMProtectIsDebuggerPresent(true)
#define VMP_ISVMPRESENT() VMProtectIsVirtualMachinePresent()
#define VMP_CHECKINTEGRITY() VMProtectIsValidImageCRC()
#endif

#define VMP_EXTRA_LIGHT_START(section) PROTECT_LIGHT_START(section)
#define VMP_EXTRA_LIGHT_END() PROTECT_LIGHT_END()
#define VMP_EXTRA_HEAVY_START(section) PROTECT_HEAVY_START(section)
#define VMP_EXTRA_HEAVY_END() PROTECT_HEAVY_END()

#if !IS_PATCH_ONLY
#define IS_DEV
#define ZBR_IS_Z4C_BUILD 0
#define DEV_BYPASS_DVARS 0
#define DEV_DRAWVELOCITY_DEBUG 0
#define ZBR_VERS "1.11"
#define ZBR_BUILDID ".0187"
#define ZBR_ADDITIONAL_ASSETS_VERSION "1.05"
//#define CLIENTFIELD_ERROR_PATCH com_clientfieldsDebug
#define NO_CONSOLE
#define CRASH_LOG_NAME "zbr_crashes.log"
#else
#define CRASH_LOG_NAME "crashes.log"
#endif

#if ZBR_IS_Z4C_BUILD
#define ZBR_CROWD_CONTROL 1
#else
#define ZBR_CROWD_CONTROL 0
#endif
// #define CLIENTFIELD_ERROR_PATCH

#define ZBR_MACROHACK(x) #x
#define ZBR_STRINGIFY(x) ZBR_MACROHACK(x)
#define ZBR_CHARACTERS_CONTENTIDINT 3050131144
#define ZBR_CC_CONTENTIDINT 3270457417
#define ZBR_CHARACTERS_CONTENTID ZBR_STRINGIFY(ZBR_CHARACTERS_CONTENTIDINT)
#define ZBR_CC_CONTENTID ZBR_STRINGIFY(ZBR_CC_CONTENTIDINT)

#ifdef IS_DEV

// lex 2929189164
// dev 2707213241
// z4c 2979165722
#if ZBR_IS_Z4C_BUILD
#define WORKSHOP_ID_INT 2979165722
#else
#define WORKSHOP_ID_INT 2707213241
#endif

#define WORKSHOP_ID ZBR_STRINGIFY(WORKSHOP_ID_INT)

// #define DUMB_SHIT

#else

#define WORKSHOP_ID_INT 2696008055
#define WORKSHOP_ID ZBR_STRINGIFY(WORKSHOP_ID_INT)

#endif

#ifdef IS_DEV
#if ZBR_IS_Z4C_BUILD
#define ZBR_WINDOW_TEXT "Zombie Blood Rush (Z4C 2024)"
#define ZBR_VERSION_FULL "ZBR Z4C 2024"
#else
#define ZBR_WINDOW_TEXT "Zombie Blood Rush (Development Build)"
#define ZBR_VERSION_FULL "ZBR DEV " ZBR_VERS ZBR_BUILDID
#endif

#define ALOG(...) Offsets::Log(__VA_ARGS__)

// emergency debugging logs
// Offsets::Log(__VA_ARGS__)
#define XLOG(...)
#else
#if !IS_PATCH_ONLY
#define ZBR_WINDOW_TEXT "Zombie Blood Rush"
#define ZBR_VERSION_FULL "ZBR OFFICIAL " ZBR_VERS ZBR_BUILDID
#define ALOG(...)
#define XLOG(...)
#else
#define ZBR_WINDOW_TEXT "Call of Duty: Black Ops III (community patch by serious)"
#define ZBR_VERSION_FULL "Patch 2.03 - by serious"
#define ALOG(...)
#define XLOG(...)
#endif
#endif

#if PATCH_DEBUG_PRINTS
#define IS_DEV
#define ALOG(...) Offsets::Log(__VA_ARGS__)
#define XLOG(...) Offsets::Log(__VA_ARGS__)
#endif

template <typename T> void chgmem(__int64 addy, T copy)
{
    DWORD oldprotect;
    VirtualProtect((void*)addy, sizeof(T), PAGE_EXECUTE_READWRITE, &oldprotect);
    *(T*)addy = copy;
    VirtualProtect((void*)addy, sizeof(T), oldprotect, &oldprotect);
}

void chgmem(__int64 addy, __int32 size, void* copy);