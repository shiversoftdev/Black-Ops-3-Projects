#pragma once

#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers
// Windows Header Files
#include <windows.h>
#include <string>
#include <vector>
#include <fstream>
#include <istream>
#include <iostream>
#include <strsafe.h>

#define SystemHandleInformation 16
#include <Windows.h>
#include <iostream>
#include <Winternl.h>

#include <windows.h>
#include <stdio.h>

#define NT_SUCCESS(x) ((x) >= 0)
#define STATUS_INFO_LENGTH_MISMATCH 0xc0000004

#define SystemHandleInformation 16
#define ObjectBasicInformation 0
#define ObjectNameInformation 1
#define ObjectTypeInformation 2

typedef NTSTATUS(NTAPI* _NtQuerySystemInformation)(
	ULONG SystemInformationClass,
	PVOID SystemInformation,
	ULONG SystemInformationLength,
	PULONG ReturnLength
	);
typedef NTSTATUS(NTAPI* _NtDuplicateObject)(
	HANDLE SourceProcessHandle,
	HANDLE SourceHandle,
	HANDLE TargetProcessHandle,
	PHANDLE TargetHandle,
	ACCESS_MASK DesiredAccess,
	ULONG Attributes,
	ULONG Options
	);
typedef NTSTATUS(NTAPI* _NtQueryObject)(
	HANDLE ObjectHandle,
	ULONG ObjectInformationClass,
	PVOID ObjectInformation,
	ULONG ObjectInformationLength,
	PULONG ReturnLength
	);


typedef struct _SYSTEM_HANDLE
{
	ULONG ProcessId;
	BYTE ObjectTypeNumber;
	BYTE Flags;
	USHORT Handle;
	PVOID Object;
	ACCESS_MASK GrantedAccess;
} SYSTEM_HANDLE, * PSYSTEM_HANDLE;

typedef struct _SYSTEM_HANDLE_INFORMATION
{
	ULONG HandleCount;
	SYSTEM_HANDLE Handles[1];
} SYSTEM_HANDLE_INFORMATION, * PSYSTEM_HANDLE_INFORMATION;

typedef enum _POOL_TYPE
{
	NonPagedPool,
	PagedPool,
	NonPagedPoolMustSucceed,
	DontUseThisType,
	NonPagedPoolCacheAligned,
	PagedPoolCacheAligned,
	NonPagedPoolCacheAlignedMustS
} POOL_TYPE, * PPOOL_TYPE;

typedef struct _OBJECT_TYPE_INFORMATION
{
	ULONG TotalNumberOfObjects;
	ULONG TotalNumberOfHandles;
	ULONG TotalPagedPoolUsage;
	ULONG TotalNonPagedPoolUsage;
	ULONG TotalNamePoolUsage;
	ULONG TotalHandleTableUsage;
	ULONG HighWaterNumberOfObjects;
	ULONG HighWaterNumberOfHandles;
	ULONG HighWaterPagedPoolUsage;
	ULONG HighWaterNonPagedPoolUsage;
	ULONG HighWaterNamePoolUsage;
	ULONG HighWaterHandleTableUsage;
	ULONG InvalidAttributes;
	GENERIC_MAPPING GenericMapping;
	ULONG ValidAccess;
	BOOLEAN SecurityRequired;
	BOOLEAN MaintainHandleCount;
	USHORT MaintainTypeList;
	POOL_TYPE PoolType;
	ULONG PagedPoolUsage;
	ULONG NonPagedPoolUsage;
} OBJECT_TYPE_INFORMATION, * POBJECT_TYPE_INFORMATION;

#define EXPORT extern "C" __declspec(dllexport)

constexpr uint32_t fnv_base_32 = 0x4B9ACE2F;

inline uint32_t fnv1a(const char* key) {

	const char* data = key;
	uint32_t hash = 0x4B9ACE2F;
	while (*data)
	{
		hash ^= *data;
		hash *= 0x1000193;
		data++;
	}
	hash *= 0x1000193; // bo3 wtf lol
	return hash;

}

template <unsigned __int32 NUM>
struct canon_const_builtins
{
	static const unsigned __int32 value = NUM;
};

constexpr unsigned __int32 fnv1a_const(const char* input)
{
	const char* data = input;
	uint32_t hash = 0x4B9ACE2F;
	while (*data)
	{
		hash ^= *data;
		hash *= 0x01000193;
		data++;
	}
	hash *= 0x01000193; // bo3 wtf lol
	return hash;
}

#define FNV32(x) canon_const_builtins<fnv1a_const(x)>::value

struct scr_vec3_t
{
	float x;
	float y;
	float z;

	scr_vec3_t operator+(scr_vec3_t const& obj)
	{
		return { x + obj.x, y + obj.y, z + obj.z};
	}

	scr_vec3_t operator-(scr_vec3_t const& obj)
	{
		return { x - obj.x, y - obj.y, z - obj.z };
	}

	scr_vec3_t operator*(float mp)
	{
		return { x + mp, y + mp, z + mp };
	}

	scr_vec3_t(float _x, float _y, float _z) : x(_x), y(_y), z(_z)
	{

	}

	scr_vec3_t() : x(0), y(0), z(0)
	{

	}
};

enum AssetPool
{
	xasset_physpreset,
	xasset_physconstraints,
	xasset_destructibledef,
	xasset_xanim,
	xasset_xmodel,
	xasset_xmodelmesh,
	xasset_material,
	xasset_computeshaderset,
	xasset_techset,
	xasset_image,
	xasset_sound,
	xasset_sound_patch,
	xasset_col_map,
	xasset_com_map,
	xasset_game_map,
	xasset_map_ents,
	xasset_gfx_map,
	xasset_lightdef,
	xasset_lensflaredef,
	xasset_ui_map,
	xasset_font,
	xasset_fonticon,
	xasset_localize,
	xasset_weapon,
	xasset_weapondef,
	xasset_weaponvariant,
	xasset_weaponfull,
	xasset_cgmediatable,
	xasset_playersoundstable,
	xasset_playerfxtable,
	xasset_sharedweaponsounds,
	xasset_attachment,
	xasset_attachmentunique,
	xasset_weaponcamo,
	xasset_customizationtable,
	xasset_customizationtable_feimages,
	xasset_customizationtablecolor,
	xasset_snddriverglobals,
	xasset_fx,
	xasset_tagfx,
	xasset_klf,
	xasset_impactsfxtable,
	xasset_impactsoundstable,
	xasset_player_character,
	xasset_aitype,
	xasset_character,
	xasset_xmodelalias,
	xasset_rawfile,
	xasset_stringtable,
	xasset_structuredtable,
	xasset_leaderboarddef,
	xasset_ddl,
	xasset_glasses,
	xasset_texturelist,
	xasset_scriptparsetree,
	xasset_keyvaluepairs,
	xasset_vehicle,
	xasset_addon_map_ents,
	xasset_tracer,
	xasset_slug,
	xasset_surfacefxtable,
	xasset_surfacesounddef,
	xasset_footsteptable,
	xasset_entityfximpacts,
	xasset_entitysoundimpacts,
	xasset_zbarrier,
	xasset_vehiclefxdef,
	xasset_vehiclesounddef,
	xasset_typeinfo,
	xasset_scriptbundle,
	xasset_scriptbundlelist,
	xasset_rumble,
	xasset_bulletpenetration,
	xasset_locdmgtable,
	xasset_aimtable,
	xasset_animselectortable,
	xasset_animmappingtable,
	xasset_animstatemachine,
	xasset_behaviortree,
	xasset_behaviorstatemachine,
	xasset_ttf,
	xasset_sanim,
	xasset_lightdescription,
	xasset_shellshock,
	xasset_xcam,
	xasset_bgcache,
	xasset_texturecombo,
	xasset_flametable,
	xasset_bitfield,
	xasset_attachmentcosmeticvariant,
	xasset_maptable,
	xasset_maptableloadingimages,
	xasset_medal,
	xasset_medaltable,
	xasset_objective,
	xasset_objectivelist,
	xasset_umbra_tome,
	xasset_navmesh,
	xasset_navvolume,
	xasset_binaryhtml,
	xasset_laser,
	xasset_beam,
	xasset_streamerhint,
	xasset__string,
	xasset_assetlist,
	xasset_report,
	xasset_depend
};

struct cStaticModel_s
{
	__int64 writable;
	__int64 xmodel;
	__int32 contents;
	scr_vec3_t origin;
	scr_vec3_t invScaledAxis[3];
	scr_vec3_t absmin;
	scr_vec3_t absmax;
	__int32 pad;
	__int64 boneMtxs;
	__int32 numBoneMtxs;
	__int32 targetname;

	cStaticModel_s() : writable(0), xmodel(0), contents(0), origin({ 0, 0, 0 }), invScaledAxis(), absmin(), absmax(), pad(), boneMtxs(0), numBoneMtxs(0), targetname(0)
	{

	}
};

struct GfxPackedPlacement
{
	scr_vec3_t origin;
	scr_vec3_t axis[3];
	float scale;
};

struct GfxStaticModelDrawInst
{
	GfxPackedPlacement placement;
	scr_vec3_t center;
	scr_vec3_t mins;
	scr_vec3_t maxs;
	__int64 model;
	uint16_t flags;
	int16_t umbraGateId;
	float invScaleSq;
	unsigned __int32 smid;
	unsigned __int32 targetname;
	unsigned char hidden;
	unsigned char pad[7];
	__int64 posedBones;
	unsigned __int32 numPosedBones;
	float scaledRadius;
	__int64 _anon_0;
	unsigned char cachedLod[4];
	unsigned char pad2[4];
};

struct GfxVisArray
{
	unsigned __int32 visDataCount;
	unsigned __int32 pad;
	unsigned char* visData;
};