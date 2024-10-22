#pragma once
#include "framework.h"
#include <Windows.h>
//#define OFFSET(x) (*(__int64*)((char*)(NtCurrentTeb()->ProcessEnvironmentBlock) + 0x10) + (__int64)(x))
//#define DOFFSET(x) x

//inline unsigned long long operator"" _g(const unsigned long long val)
//{
//	return (*(unsigned long long*)((char*)(NtCurrentTeb()->ProcessEnvironmentBlock) + 0x10) + val);
//}

//inline unsigned long long REBASE(unsigned long long val)
//{
//	return (*(unsigned long long*)((char*)(NtCurrentTeb()->ProcessEnvironmentBlock) + 0x10) + val);
//}

#define REBASE(x) (*(unsigned __int64*)((unsigned __int64)(NtCurrentTeb()->ProcessEnvironmentBlock) + 0x10) + (unsigned __int64)(x))

#define _DOFFSET(x) x
#define ARXAN_LOBBY_JMP REBASE(0x283AD20)
#define ARXAN_LOBBY_JMPTO REBASE(0x1B385BED)
#define ARXAN_LOAD_JMP REBASE(0x134D5A0)
#define ARXAN_LOAD_JMPTO REBASE(0x1D3E0B71)
#define ARXAN_SPOT4_JMP REBASE(0x22F4E60)
#define ARXAN_SPOT4_JMPTO REBASE(0x1DB375E7)
#define INT3_BO3 REBASE(0x1173)
#define INT3_2_BO3 REBASE(0x1059)
#define END_TXT_FUNCS REBASE(0x2F7C4B0)
#define BEGIN_TXT_FUNCS REBASE(0x1060)
#define ROP_RETN REBASE(0x1048)
#define ARXAN_BEGIN REBASE(0x1AAEA000)
#define ARXAN_END REBASE(0x1FAB7000)
#define ASSETPOOL_BEGIN REBASE(0x94073F0)
#define OFF_ScrVarGlob REBASE(0x51A3500)
#define GSCR_FASTEXIT REBASE(0x2C53903)
#define CL_DrawScreenOffset REBASE(0x13CFBF0)
#define EMBLEM_ID_PTR REBASE(0x343E250)
#define BO3_HWND REBASE(0x17E763D0)
#define s_playerData_ptr REBASE(0x340F180)
#define PTR_LobbyVMJoinEvent REBASE(0x1EEF890)
#define PTR_DDL_MoveToName REBASE(0x2522460)
#define PTR_DDL_MoveToIndex REBASE(0x2522450)
#define PTR_DDL_GetInt REBASE(0x2522450)
#define PTR_DDL_SetCombatRecordID REBASE(0x1E1E870)
#define PTR_Cbuf_AddText REBASE(0x20EC010)
#define PTR_Dvar_SetFromStringByName REBASE(0x22C7500)
#define PTR_LobbyVM REBASE(0x157588D0)
#define PTR_CL_DispatchConnectionless REBASE(0x134CDAD)
#define PTR_MigrationVTable REBASE(0x2FB9EB0)
#define SCRVM_Error REBASE(0x12EA4D0)
#define OFF_SCRVM_RuntimeError REBASE(0x12EA4C0)
#define SCRVM_FS REBASE(0x51C4F30)
#define LuaCrash1 REBASE(0x1CAB4F1)
#define LuaCrash1Rip REBASE(0x1CAB69E)
#define LuaCrash2 REBASE(0x2279323)
#define LuaCrash3 REBASE(0x2278B96)
#define SCR_VmErrorString REBASE(0x52E50F0)
#define SCR_VMContext REBASE(0x51A3850)
#define INSTANT_DISPATCH REBASE(0x143A661)
#define OFF_IsProfileBuild REBASE(0x32D7D70)
#define OFF_ScrVm_GetInt REBASE(0x12EB7F0)
#define OFF_ScrVm_GetString REBASE(0x12EBAA0)
#define OFF_ScrVm_GetFunc REBASE(0x12EB730)
#define OFF_ScrVm_Opcodes REBASE(0x32E6350)
#define OFF_ScrVm_Opcodes2 REBASE(0x3306350)
#define OFF_Scr_GetFunction REBASE(0x1AF7820)
#define OFF_Scr_GetMethod REBASE(0x1AF79B0)
#define OFF_DB_FindXAssetHeader REBASE(0x1420ED0)
#define DB_FindXAssetHeader(type, name, errorIfMissing, waitTime) ((__int64(__fastcall*)(int, const char*, int, int))OFF_DB_FindXAssetHeader)(type, name, errorIfMissing, waitTime)
#define OFF_s_runningUILevel REBASE(0x168ED91E)
#define OFF_Scr_GscObjLink REBASE(0x12CC300)
#define OFF_ScrVar_AllocVariableInternal REBASE(0x12D9A60)
#define PTR_Name1 REBASE(0x114238E0)
#define PTR_Name2 REBASE(0x11423860)
#define PTR_Lua_CoD_GetLuaState REBASE(0x1F119E0)
#define PTR_LobbyMsgRW_PackageInt REBASE(0x1EF66D0)
#define PTR_LobbyMsgRW_PackageUChar REBASE(0x1EF6800)
#define PTR_LobbyMsgRW_PackageString REBASE(0x1EF6770)
#define PTR_LobbyMsgRW_PackageXuid REBASE(0x1EF6940)
#define PTR_LobbyMsgRW_PackageBool REBASE(0x1EF6580)
#define PTR_LobbyMsgRW_PackageUInt REBASE(0x1EF68A0)
#define PTR_LobbyMsgRW_PackageShort REBASE(0x1EF6750)
#define PTR_LobbyMsgRW_PackageUInt64 REBASE(0x1EF6820)
#define PTR_LobbyMsgRW_PackageArrayStart REBASE(0x1EF6510)
#define PTR_LobbyMsgRW_PackageElement REBASE(0x1EF65C0)
#define PTR_LobbyMsgRW_PackageGlob REBASE(0x1EF66B0)
#define PTR_MsgMutableClientInfo_Package REBASE(0x1ED47D0)
#define PTR_lobbymsgprints REBASE(0x1574D840)
#define PTR_saveLobbyMsgExceptAddy REBASE(0x1EF8034)
#define PTR_UpdatePreloadIdleFN REBASE(0x33265A8)
#define PTR_I_stricmp REBASE(0x22E9530)
#define PTR_LobbyMsgRW_PackageChar REBASE(0x1EF65A0)
#define PTR_LobbyMsgRW_PackageFloat REBASE(0x1EF6630)
#define PTR_MsgMutableClientInfo_Package REBASE(0x1ED47D0)
#define PTR_dwInstantHandleLobbyMessage REBASE(0x143A780)
#define PTR_ProbeLobbyInfo REBASE(0x1EE67C0)
#define PTR_NET_OutOfBandPrint REBASE(0x2173710)
#define PTR_dwCommonAddrToNetadr REBASE(0x143C360)
#define PTR_dwRegisterSecIDAndKey REBASE(0x143E120)
#define PTR_LobbyMsgTansport_SendOutOfBand REBASE(0x1EF8420)
#define PTR_LobbyMsgRW_PrepWriteMsg REBASE(0x1EF6A30)
#define PTR_LobbyMsgRW_PackageUShort REBASE(0x1EF6920)
#define PTR_sPlayerData s_playerData_ptr
#define PTR_MSG_Init REBASE(0x2154F80)
#define PTR_MSG_WriteString REBASE(0x2158220)
#define PTR_MSG_WriteShort REBASE(0x21726D0)
#define PTR_MSG_WriteByte REBASE(0x21577C0)
#define PTR_MSG_WriteData REBASE(0x21577E0)
#define PTR_Com_ControllerIndex_GetLocalClientNum REBASE(0x20EF7C0)
#define PTR_Com_LocalClient_GetNetworkID REBASE(0x20EF950)
#define PTR_NET_OutOfBandData REBASE(0x2173600)
#define PTR_LobbyMsgTransport_SendToAdr REBASE(0x1EF8800)
#define PTR_MSG_ReadData REBASE(0x21554B0)
#define PTR_LobbyMsgRW_PrepReadData REBASE(0x1EF69C0)
#define PTR_MSG_InfoResponse REBASE(0x1EE1E60)
#define PTR_I_stricmp REBASE(0x22E9530)
#define PTR_dwInstantSendMessage REBASE(0x143A810)
#define PTR_LobbySession_GetControllingLobbySession REBASE(0x1ECC170)
#define PTR_LobbySession_GetSession REBASE(0x1ECDA20)
#define PTR_SL_LookupCanonicalString REBASE(0x12CBB90)
#define PTR_ScrStr_ConvertToString REBASE(0x12D7160)
#define PTR_LobbySession_GetClientByClientNum REBASE(0x1F00070)
#define PTR_LobbySession_GetClientNetAdrByIndex REBASE(0x1ECC090)
#define PTR_LobbyJoin_Reserve REBASE(0x1EE7CB0)
#define PTR_CL_GetConfigString REBASE(0x1321110)
#define PTR_LiveFriends_IsFriendByXUID REBASE(0x1DF93A0)
#define PTR_ConnectionlessResume REBASE(0x134CE00)
#define PTR_s_Join REBASE(0x1574A640)
#define STEAMAPI_STEAMUSER REBASE(0x10BBCBA0)
#define STEAMAPI_INTERFACE REBASE(0x10BBCBC0)
#define STEAMAPI_FRIENDS REBASE(0x10BBCBA0)
#define STEAMAPI_MATCHMAKING REBASE(0x10BBCBB0)
#define LOCAL_CLIENT_CONSTATE REBASE(0x53D8BC0)
#define Scr_GetNumExpectedPlayers REBASE(0x1ED8AC0)
// UI_WorldPosToLUIPos 2819320 (needs spoof call)
#define PTR_UI_WorldPosToLUIPos REBASE(0x2819320)
// CL_ParseSnapshot 1366FF0 (needs spoof call)
#define PTR_CL_ParseSnapshot REBASE(0x1366FF0)
#define PTR_SV_WriteSnapshotToClient REBASE(0x2262300)
// linked list entry for setupUITextUncached: 365C718 (const char* name, const subroutine* sub, const __int64 nextEntry)
#define PTR_UI_ToElement REBASE(0x270DEB0)
#define SPOOF_GADGET 0x13412B9
#define SPOOF_TRAMP REBASE(SPOOF_GADGET)
#define PTR_MSG_ReadByte REBASE(0x2155450)
#define PTR_MSG_WriteByte REBASE(0x21577C0)
#define PTR_LUIElementFunctionEntryHook REBASE(0x365C718)
#define PTR_LuaScopedEvent_ctor REBASE(0x1F048E0)
#define PTR_LuaScoredEvent_dtor REBASE(0x1F04AF0)
#define PTR_UI_luaVM REBASE(0x19C76D88)
#define PTR_Lua_SetTableInt REBASE(0x1F066E0)
#define PTR_Lua_SetTableString REBASE(0x1F06800)
#define PTR_s_immediateRender REBASE(0x19C76D92)
#define PTR_UI_Interface_DrawText REBASE(0x1F34920)
#define PTR_UI_AlignWidgetToScreenPosition REBASE(0x28142F0)
#define PTR_UI_CustomDrawText REBASE(0x2814F80)
#define PTR_SvsStaticClients REBASE(0x17906580)
#define PTR_DB_GetAllXAssetOfType REBASE(0x22ABCA0)
#define PTR_XAssetPool_LuaRawfiles REBASE(0x94C7BA8)
#define PTR_XAssetPool_LuaRawFiles_2 REBASE(0x94079D0)
#define PTR_hksi_hks_traceback REBASE(0x1D4C960)
#define PTR_hksi_lua_getinfo REBASE(0x1D4D8D0)
#define PTR_luaenginefunction_list REBASE(0x365C5E0)
#define PTR_getPC REBASE(0x1D46310)
#define PTR_getFunctionName REBASE(0x1D457D0)
#define PTR_hksi_lua_pushfstring REBASE(0x1D4E570)
#define PTR_Dvar_Register_Color REBASE(0x22D0920)
#define PTR_Msg_ClientReliableData_Package REBASE(0x1ED4E60)
#define PTR_ClientReliableReturn REBASE(0x1EDF620)
#define PTR_HandleClientReliableData REBASE(0x1EDF590)
#define PTR_Scr_AddInt REBASE(0x12E9870)
#define PTR_LobbyHostData_GetSession REBASE(0x1EDCDD0)
#define PTR_LiveStats_AreStatsDeltasValid REBASE(0x1E98940)
#define PTR_LiveStats_DoSecurityChecksCmd REBASE(0x1E9A3B0)
#define PTR_Cmp_TokenizeStringInternal REBASE(0x20EEAFE + 0x3)
#define PTR_Dvar_CanSetConfigDvar REBASE(0x22B8890)
#define PTR_Dvar_ValueInDomain REBASE(0x22CB2B0)
#define PTR_Dvar_CanChangeValue REBASE(0x22B84D0)
#define DBX_AuthLoad_ValidateSignature_Try REBASE(0x13EC500)
#define PTR_Jump_ApplySlowdown REBASE(0x2675EE0)
#define PM_Accelerate_f REBASE(0x2687E40)
#define PM_DoSlideAdjustments_f REBASE(0x268B360)
#define PM_ClampViewAngles_f REBASE(0x2691700)
#define PM_CmdScale_f REBASE(0x268A0F0)
#define PM_AirMove_f REBASE(0x2688170)
#define Jump_ReduceFriction_f REBASE(0x26767A0)
#define CL_DrawTextPhysicalWithEffects(text, maxChars, font, x, y, w, xScale, yScale, color, style, glowColor, fxMaterial, fxMaterialGlow, fxBirthTime, fxLetterTime, fxDecayStartTime, fxDecayDuration) ((void(__fastcall*)(const char*, int, __int64, float, float, float, float, float, __int64, int, __int64, __int64, __int64, __int64, __int64, __int64, __int64))REBASE(0x134DDC0))(text, maxChars, font, x, y, w, xScale, yScale, color, style, glowColor, fxMaterial, fxMaterialGlow, fxBirthTime, fxLetterTime, fxDecayStartTime, fxDecayDuration)
#define UI_DrawTextPadding(localClientNum, scrPlace, text, maxChars, font, x, y, horzAlign, vertAlign, scale, color, style, padding) ((void(__fastcall*)(int, __int64, const char*, int, __int64, float, float, int, int, float, __int64, int, int))REBASE(0x228D100))(localClientNum, scrPlace, text, maxChars, font, x, y, horzAlign, vertAlign, scale, color, style, padding)
// void __cdecl UI_DrawTextPadding(LocalClientNum_t localClientNum, const ScreenPlacement *scrPlace, const char *text, int maxChars, FontHandle font, float x, float y, int horzAlign, int vertAlign, float scale, const vec4_t *color, int style, float padding)
#define g_zonecount *(__int32*)REBASE(0x941097C)
#define getframetime() ((unsigned __int32(__fastcall*)())REBASE(0x2332870))()
#define LobbyNetChan_GetLobbyChannel(lobbyType, lobbyChannel) ((unsigned __int32(__fastcall*)(unsigned __int32, unsigned __int32))REBASE(0x1EF8F20))(lobbyType, lobbyChannel)
#define LobbyMsgTransport_SendToHostReliably(controllerIndex, lobbySession, destModule, msg, msgType, netchanChannel, msgConfig) ((bool(__fastcall*)(__int32, __int64, LobbyModule, msg_t*, MsgType, __int32, __int32*))REBASE(0x1EF8CA0))(controllerIndex, lobbySession, destModule, msg, msgType, netchanChannel, msgConfig)
#define Scr_NotifyLevelWithArgs(vm, hash_id, amount) ((void(__fastcall*)(__int32, __int32, __int32, __int32, __int32))REBASE(0x12EC9D0))(vm, *(__int32*)REBASE(0x342155C), *(__int32*)REBASE(0x51A372C), hash_id, amount)
#define PTR_Scr_AddString REBASE(0x12E9A30)
#define PTR_BG_GetCustomizationTableNameForSessionMode REBASE(0xADDB0)
#define PTR_Sys_Error REBASE(0x22F4A00)
#define PTR_CG_UpdatePlayerDObj REBASE(0x98C590)
#define PTR_CG_UpdatePhysConstraintTags REBASE(0x1F9D70)
#define PTR_Com_GetClientDObj REBASE(0x214E140)
#define PTR_Scr_AddFloat REBASE(0x12E9760)
#define PTR_getnattype REBASE(0x2900970)
#define PTR_CM_LoadMap REBASE(0x20D8930)
#define PTR_Com_SessionModeOrCore_GetPath REBASE(0x20F6470)
#define PTR_Scr_AddVec REBASE(0x12E9E90)
#define PTR_Scr_GetVector REBASE(0x12EBF90)
#define PTR_Scr_GetEntity REBASE(0x15F5A50)
#define PTR_SV_LinkEntity REBASE(0x22633E0)
#define Dvar_FindVar(str_name) ((__int64(__fastcall*)(const char*))REBASE(0x22BCCD0))(str_name)
#define Dvar_GetVariantString(dvar) ((const char*(__fastcall*)(__int64))REBASE(0x22C0570))(dvar)
#define PTR_CM_LinkAllStaticModels REBASE(0x20EAA30)
#define PTR_R_UseWorld REBASE(0x1C8B1D0)
#define AxisToAngles(axis, angles) ((void(__fastcall*)(scr_vec3_t*, scr_vec3_t*))REBASE(0x22A52A0))(axis, angles)
#define AnglesToAxis(angles, axis) ((void(__fastcall*)(scr_vec3_t*, scr_vec3_t*))REBASE(0x22AB140))(angles, axis)
#define Com_Error(type, fmt, ...) ((void(__fastcall*)(__int64, __int32, __int32, const char*, ...))REBASE(0x20F8170))((__int64)"", 0, type, fmt, __VA_ARGS__)
#define PTR_Scr_GetWeapon REBASE(0x12EC0F0)
#define PTR_WeaponDefVariants (__int64*)REBASE(0x19C73290)
#define BG_GetNumWeaponsResult (unsigned int)((*(__int32*)REBASE(0x19C74294)) + 1)
#define PTR_CL_KeyEvent REBASE(0x1342200)
// #define CL_KeyEvent(localclientnum, evt1, evt2, time) ((void(__fastcall*)(__int32, unsigned __int32, unsigned __int32, unsigned __int32))PTR_CL_KeyEvent)(localclientnum, evt1, evt2, time)
#define PTR_Fire_Weapon REBASE(0x1BBD630)
#define PTR_GetWeaponDamageForRange1 REBASE(0x26F2BE0)
#define PTR_Bullet_GetDamage_RETN REBASE(0x1580FF9)
#define PTR_G_GetWeaponHitLocationMultiplier REBASE(0x19873C0)
#define PTR_G_GetWeaponHitLocationMultiplier_RETN REBASE(0x1984927)
#define PTR_ScriptErrorHandlers REBASE(0x32F6350)
#define PTR_vm_execute REBASE(0x12EDB10)
#define PTR_vm_execute_error_handler REBASE(0x12EE0D0)
#define PTR_ScrVm_GetFloat REBASE(0x12EB5C0)
#define ScrVm_GetFloat(inst, indx) ((float(__fastcall*)(__int32, __int32))PTR_ScrVm_GetFloat)(inst, indx)
#define SPOOFED_CALL(a, ...) spoof_call((void*)SPOOF_TRAMP, a, __VA_ARGS__)
#define OFF_BID_Scr_CastInt REBASE(0x32D71A0)
#define OFF_Dvar_SetFloat REBASE(0x22C6DC0)