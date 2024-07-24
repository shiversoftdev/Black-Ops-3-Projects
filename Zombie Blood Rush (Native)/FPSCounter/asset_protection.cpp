#include "asset_protection.h"

AssetPool protection_assets[] =
{
	xasset_xanim,
	xasset_xmodel,
	xasset_xmodelmesh,
	xasset_material,
	xasset_image,
	xasset_sound,
	xasset_col_map,
	xasset_map_ents,
	xasset_localize,
	xasset_weapon,
	xasset_weaponfull,
	xasset_weaponcamo,
	xasset_fx,
	xasset_tagfx,
	xasset_player_character,
	xasset_character,
	xasset_rawfile,
	xasset_stringtable,
	xasset_scriptparsetree,
	xasset_addon_map_ents,
	xasset_tracer,
	xasset_scriptbundle,
	xasset_animselectortable,
	xasset_animmappingtable,
	xasset_animstatemachine,
	xasset_behaviortree,
	xasset_behaviorstatemachine,
	xasset_xcam,
	xasset_navmesh,
	xasset_sanim,
	xasset_structuredtable,
	xasset_beam
};

char* page_protect = (char*)POINTER_ASSET_BAD;
void asset_protection::protect()
{
#if !IS_PATCH_ONLY
	PROTECT_LIGHT_START("asset protection init");
	for (int i = 0; i < sizeof(protection_assets) / 4; i++)
	{
		__int64* pool_pointer = (__int64*)(ASSETPOOL_BEGIN + (0x20 * protection_assets[i]));
		pointer_fixups[(__int64)page_protect + ((__int64)(protection_assets[i] & 0xFF) << 32)] = *pool_pointer;
		*pool_pointer = (__int64)page_protect + ((__int64)(protection_assets[i] & 0xFF) << 32);
	}
	PROTECT_LIGHT_END();
#endif
}

#ifdef IS_DEV
void asset_protection::unprotect(const char* pass)
{
#if !IS_PATCH_ONLY
	PROTECT_HEAVY_START("asset unprotection");
	if (!pass || strlen(pass) != 8 || pass[0] != 'x' || pass[1] != 'C' || pass[2] != 'a' || pass[3] != 'V' || strcmp(pass + 4, ";@%3"))
	{
		return;
	}
	// strip protection
	for (int i = 0; i < sizeof(protection_assets) / 4; i++)
	{
		__int64* pool_pointer = (__int64*)(ASSETPOOL_BEGIN + (0x20 * protection_assets[i]));
		*pool_pointer = pointer_fixups[(__int64)page_protect + ((__int64)(protection_assets[i] & 0xFF) << 32)];
	}
	PROTECT_HEAVY_END();
#endif
}
#endif

// TODO: check return and inputs on DB_AssetPoolAlloc
// TODO: deal with g_assetEntryPool and DB_GetAllXAssetOfType
// TODO: watch for db_addxasset 141F4C0 hook and remove it
// TODO: check return on DB_FindXAssetHeader
// TODO: test out a secondary fast file embedding system in the dll

bool asset_protection::try_recover(PEXCEPTION_RECORD ExceptionRecord, PCONTEXT ContextRecord)
{
#if !IS_PATCH_ONLY
	__int64 badval = 0;
	for (int i = 0; i < 16; i++)
	{
		auto val = ((__int64*)&ContextRecord->Rax)[i] & 0xFFFFFFFFFF000000;
		if ((val & 0xFFFFFF00FF000000) == (__int64)page_protect)
		{
			badval = val;
			((__int64*)&ContextRecord->Rax)[i] = pointer_fixups[val] + (((__int64*)&ContextRecord->Rax)[i] & ~0xFFFFFFFFFF000000);
		}
	}

	if (badval)
	{
		for (int i = 0; i < 0x30; i++)
		{
			auto val = ((__int64*)ContextRecord->Rsp)[i] & 0xFFFFFFFFFF000000;
			if ((val & 0xFFFFFF00FF000000) == (__int64)page_protect)
			{
				badval = val;
				((__int64*)ContextRecord->Rsp)[i] = pointer_fixups[val] + (((__int64*)ContextRecord->Rsp)[i] & ~0xFFFFFFFFFF000000);
			}
		}
	}
	
	// TODO: do not fix the pointer if it is called by a non-game source (specifically check for external, spoof calling, and regular dll calls)

	return badval != 0;
#else
	return false;
#endif
}