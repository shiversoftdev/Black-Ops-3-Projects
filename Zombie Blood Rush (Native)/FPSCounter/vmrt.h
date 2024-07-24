#pragma once
#include "framework.h"
#include "mh.h"
#include "offset_fixups.h"

//#define OFF_VMRT_EXCEPT_LOC OFFSET(0x22c8955)
//#define OFF_VMRT_EXCEPT_FASTRET OFFSET(0x22c8c87)
//#define OFF_VMRT_DVAR_LOC OFFSET(0x177c7818)
//#define OFF_VMRT_s_runningUILevel OFFSET(0x168ef91e)

#define VMRT_SCRVAR_COUNT_SV 130000
#define VMRT_SCRVAR_COUNT_CL 65000
#define VMRT_SCRVAR_COUNT_TOTAL (VMRT_SCRVAR_COUNT_SV + VMRT_SCRVAR_COUNT_CL)


typedef uint32_t ScrVarIndex_t;
typedef uint32_t ScrString_t;
typedef uint64_t ScrVarNameIndex_t;
typedef uint32_t ScrVarCannonicalName_t;

enum ScrVarType_t
{
	VAR_UNDEFINED = 0,
	VAR_POINTER = 1,
	VAR_STRING = 2,
	VAR_ISTRING = 3,
	VAR_VECTOR = 4,
	VAR_HASH = 5,
	VAR_FLOAT = 6,
	VAR_INTEGER = 7,
	VAR_UINT64 = 8,
	VAR_UINTPTR = 9,
	VAR_ENTITYOFFSET = 10,
	VAR_CODEPOS = 11,
	VAR_PRECODEPOS = 12,
	VAR_APIFUNCTION = 13,
	VAR_FUNCTION = 14,
	VAR_STACK = 15,
	VAR_ANIMATION = 16,
	VAR_THREAD = 17,
	VAR_NOTIFYTHREAD = 18,
	VAR_TIMETHREAD = 19,
	VAR_CHILDTHREAD = 20,
	VAR_CLASS = 21,
	VAR_STRUCT = 22,
	VAR_REMOVEDENTITY = 23,
	VAR_ENTITY = 24,
	VAR_ARRAY = 25,
	VAR_REMOVEDTHREAD = 26,
	VAR_FREE = 27,
	VAR_THREADLIST = 28,
	VAR_ENTLIST = 29,
	VAR_COUNT = 30
};

struct ScrVarChildPair_t
{
	ScrVarIndex_t firstChild;
	ScrVarIndex_t lastChild;
};

struct ScrVarStackBuffer_t
{
	BYTE* pos;
	BYTE* creationPos;
	unsigned __int16 size;
	unsigned __int16 bufLen;
	ScrVarIndex_t threadId;
	BYTE buf[1];
};

union ScrVarValueUnion_t
{
	int64_t intValue;
	int32_t hashValue;
	uintptr_t uintptrValue;
	float floatValue;
	ScrString_t stringValue;
	const float* vectorValue;
	BYTE* codePosValue;
	ScrVarIndex_t pointerValue;
	ScrVarStackBuffer_t* stackValue;
	ScrVarChildPair_t childPair;
};

__declspec(align(8)) struct ScrVarValue_t
{
	ScrVarValueUnion_t u;
	ScrVarType_t type;
	uint32_t pad;
};

struct ScrVarRuntimeInfo_t
{
	unsigned __int32 nameType : 3;
	unsigned __int32 flags : 5;
	unsigned __int32 refCount : 24;
};

union EntRefUnion
{
	uint64_t val;
};

__declspec(align(8)) union ScrVarObjectInfo_t
{
	uint64_t object_o;
	unsigned int size;
	EntRefUnion entRefUnion;
	ScrVarIndex_t nextEntId;
	ScrVarIndex_t self;
	ScrVarIndex_t free;
};

struct ScrVarEntityInfo_t
{
	unsigned __int16 classNum;
	unsigned __int16 clientNum;
};

union ScrVarObjectW_t
{
	uint32_t object_w;
	ScrVarEntityInfo_t varEntityInfo;
	ScrVarIndex_t stackId;
};

struct ScrVar_t
{
	ScrVarValue_t value; // 0 (size 10)
	ScrVarRuntimeInfo_t info; // 10 (size 4)
	ScrVarObjectInfo_t o; // 18 (size 8)
	ScrVarObjectW_t w; // 20 (size 4)
	ScrVarNameIndex_t nameIndex; // 28 (size 8)
	ScrVarIndex_t nextSibling; // 30 (size 4)
	ScrVarIndex_t prevSibling; // 34 (size 4)
	ScrVarIndex_t parentId; // 38 (size 4)
	ScrVarIndex_t nameSearchHashList; // 3C (size 4)
};

class vmrt
{
public:
	static vmrt inst;
	static void install();
	static void disable_hooks_fast();
	static void enable_hooks_fast();
	static LONG catch_vm_restart(_EXCEPTION_POINTERS* ExceptionInfo);
	static char* get_var_tree(bool cached);
	static char* get_var_usage();

private:
	static INT64 original_dvar_value;
	static bool are_hooks_enabled;
	static bool is_initialized;
	static const char* var_typename[];

	static void setup_hooks();
	static void hooks_enabled();
	static void hooks_disabled();
	static ScrVar_t* get_vm_variables(int inst);

	static void ScrVar_VisualizeVarTree(int inst, char** inBuffPtr);
	static void ScrVar_VisualizeVarTreeInternal(int inst, char** inBuffPtr, ScrVarIndex_t id, int* lineNum, int depth, ScrVarIndex_t* visualizeIdStack, bool* followStack);
	static ScrVarIndex_t ScrVar_FirstChild(int inst, ScrVarIndex_t parentId);

	typedef char* (__fastcall* tSL_LookupCanonicalString)(ScrVarCannonicalName_t index);
	static tSL_LookupCanonicalString SL_LookupCanonicalString;
	typedef char* (__fastcall* tScrStr_ConvertToString)(ScrString_t str);
	static tScrStr_ConvertToString ScrStr_ConvertToString;

	static char var_tree[VMRT_SCRVAR_COUNT_TOTAL * 512 + 2048];
	static char var_stats[1024 * 8];
};