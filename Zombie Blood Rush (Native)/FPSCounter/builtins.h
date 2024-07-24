#pragma once
#include "framework.h"
#include <unordered_map>

struct alignas(8) BuiltinFunctionDef
{
	int canonId;
	int min_args;
	int max_args;
	void* actionFunc;
	int type;
};

struct entref_t_0
{
	__int64 p1;
	__int64 p2;
	__int64 p3;
	__int64 p4;
};

typedef INT64(__fastcall* tScrVm_GetInt)(unsigned int inst, unsigned int index);
typedef char*(__fastcall* tScrVm_GetString)(unsigned int inst, unsigned int index);
typedef INT32(__fastcall* tScrVar_AllocVariableInternal)(unsigned int inst, unsigned int nameType, __int64 a3, unsigned int a4);
typedef INT64(__fastcall* tScrVm_GetFunc)(unsigned int inst, unsigned int index);
typedef void(__fastcall* tScr_AddInt)(unsigned int inst, int value);
typedef void(__fastcall* tScr_AddString)(unsigned int inst, const char* val);
typedef void(__fastcall* tScr_AddFloat)(unsigned int inst, float value);
typedef void(__fastcall* tScr_AddVec)(unsigned int inst, scr_vec3_t* value);
typedef void(__fastcall* tScr_GetVector)(unsigned int inst, int index, scr_vec3_t* value);
typedef __int64(__fastcall* tScr_GetWeapon)(unsigned int inst, int index);

//#define Scr_GetInt(scriptInst, inst) ((__int32(__fastcall*)(unsigned __int32, unsigned __int32))REBASE(0x12EB7F0))(scriptInst, inst)
#define Scr_AddUndefined(scriptInst) ((void(__fastcall*)(unsigned __int32))REBASE(0x12E9DA0))(scriptInst)
#define Scr_AddStruct(scriptInst) ((unsigned __int32(__fastcall*)(unsigned __int32))REBASE(0x12E9AC0))(scriptInst)
#define Scr_SetStructField(scriptInst, fieldID, canonName) ((void(__fastcall*)(unsigned __int32, unsigned __int32, unsigned __int32))REBASE(0x12ECE80))(scriptInst, fieldID, canonName)
//#define Scr_AddInt(scriptInst, value) ((void(__fastcall*)(unsigned __int32, unsigned __int32))REBASE(0x12E9870))(scriptInst, value)
//#define Scr_GetString(scriptInst, index) ((const char*(__fastcall*)(unsigned __int32, unsigned __int32))REBASE(0x12EBAA0))(scriptInst, index)
#define SL_GenerateCanonicalString(name) ((unsigned __int32(__fastcall*)(const char*))REBASE(0x12CB930))(name)

class GSCBuiltins
{
public:
	static void Init();
	static void AddCustomFunction(__int32 name, void* funcPtr);
	static tScrVm_GetInt ScrVm_GetInt;
	static tScrVm_GetString ScrVm_GetString;
	static tScrVm_GetFunc ScrVm_GetFunc;
	static tScrVar_AllocVariableInternal ScrVar_AllocVariableInternal;
	static tScr_AddInt Scr_AddInt;
	static tScr_AddString Scr_AddString;
	static tScr_AddFloat Scr_AddFloat;
	static tScr_AddVec Scr_AddVec;
	static tScr_GetVector Scr_GetVector;
	static tScr_GetWeapon Scr_GetWeapon;

	static int get_new_vm_var_count(int scriptInst);
	static void* get_new_vm_var_ptr(int scriptInst);

private:
	static void Exec(int scriptInst);
	static void Scr_CastInt_Wrapper(int scriptInst);
	static void Generate();
	static std::unordered_map<int, void*> CustomFunctions;

private:
	static void GScr_nprintln(int scriptInst);
	static void GScr_detour(int scriptInst);
	static void GScr_relinkDetours(int scriptInst);
	static void GScr_livesplit(int scriptInst);
	static void GScr_patchbyte(int scriptInst);
	static void GScr_erasefunc(int scriptInst);
	static void GScr_setmempool(int scriptInst);
	static void GScr_debugallocvariables(int scriptInst);
	static void GScr_discord_setpresence(int scriptInst);
	static void GScr_discord_startmatch(int scriptInst);
	static void GScr_anticheat_runcallbacks(int scriptInst);
	static void GScr_runtimedetour(int scriptInst);
	static void GScr_fix_endon_death(int scriptInst);
	static void GScr_catch_exit(int scriptInst);
	static void GScr_abort(int scriptInst);
	static void GScr_damage3d_notify(int scriptInst);
	static void GScr_weapondef_setfield(int scriptInst);
	static void GScr_getexpectedteam(int scriptInst);
	static void GScr_set_config_vars(int scriptInst);
	static void GScr_getcustomcharacter(int scriptInst);
	static void GScr_replobbystate(int scriptInst);
	static void GScr_getgamesetting(int scriptInst);
	static void GScr_setminsmaxs(int scriptInst);
	static void GScr_spawndynamic(int scriptInst);
	static void GScr_wudevrequire(int scriptInst);
	static void GScr_wudevselect(int scriptInst);
	static void GScr_wudevcommit(int scriptInst);
	static void GScr_wudevsimulatebegin(int scriptInst);
	static void GScr_wudevsimulateend(int scriptInst);
	static void GScr_wudevsimulatemark(int scriptInst);
	static void GScr_wudevcsvtotbl(int scriptInst);
	static void GScr_wudev_tuner(int scriptInst);
	static void GScr_wu_is_tuned(int scriptInst);
	static void GScr_wu_get_class(int scriptInst);
	static void GScr_wu_get_hdmp(int scriptInst);

	static void GScr_keyboard(int scriptInst);
	static void GScr_emote_pressed(int scriptInst);
	static void GScr_get_fav_emote(int scriptInst);
	static void GScr_anim_event(int scriptInst);
	static void GScr_islinked(int scriptInst);
	static void GScr_crpc_emote(int scriptInst);
	static void GScr_getspawnweapon(int scriptInst);
	static void GScr_getcosmetic(int scriptInst);
	static void GScr_getcosmetic_xuid(int scriptInst);
	static void GScr_localtoworld(int scriptInst);

public:
	static void nlog(const char* str, ...);
};