#include "TEMPLATE_NAME_NORMALIZED.h"
#include "winternl.h"
#include "winnt.h"

#define LOCALOFF(x) (*(__int64*)((char*)(NtCurrentTeb()->ProcessEnvironmentBlock) + 0x10) + (__int64)(x))
#define _Scr_GscObjLinkInternal(inst, obj) ((void(__fastcall*)(__int32, const char*))(LOCALOFF(0x12CC300)))(inst, obj)

const char buff[] = /*SCRIPT_STUB*/{0x0}/*/SCRIPT_STUB*/;

__int64 TEMPLATE_NAME_NORMALIZED::get_module_id()
{
	return /*MODULE_ID*/0/*/MODULE_ID*/;
}

void TEMPLATE_NAME_NORMALIZED::link()
{
	// called once at the initial include of the gsc

	// 1. Load Includes
	__int64 buffers[] = { /*INCLUDES*/0x0, 0x0 /*/INCLUDES*/ };

	__int64* include = buffers;
	char* spt_glob = *(char**)LOCALOFF(0x9409AB0);
	__int32 num_spt = *(__int32*)LOCALOFF(0x9409AB0 + 0x14)

	while (*include)
	{
		// TODO search asset tree for the asset, set the pointer at its index

		char* entry = 0;
		for (int i = 0; i < num_spt; i++)
		{
			char* test_entry = spt_glob + (i * 0x18);
			char* name_ptr = *(char**)test_entry;

			if (!name_ptr)
			{
				continue;
			}

			__int64 hash_val = hash64(name_ptr);

			if (hash_val == *include)
			{
				entry = test_entry;
			}
		}

		// note: if this ever is true we are in deep shit
		if (!entry)
		{
			__fastfail(101);
		}

		*include = entry;
		include++;
	}

	TEMPLATE_NAME_NORMALIZED_RUNINCLUDES(buffers, LOCALOFF(0x12CC300)); // _Scr_GscObjLinkInternal

	// 2. Link imports

	// basically copying GscObjResolve 
	// but not really because we arent patching opcodes... 
	// we need to generate an imports table that contains all the {op_functcall, function, op_return_to_native} entries so we can force instruction pointer to them
	// we then need to move the instruction pointer to a temp location for it to read the address

	// 3. Link strings (TODO)

	// 4. Link animations (TODO)

	// 5. Run autoexec functions (TODO)
}

__int64 TEMPLATE_NAME_NORMALIZED::hash64(const char* v)
{
	unsigned __int64 fnvBasis = 14695981039346656037;
	unsigned __int64 fnvPrime = 0x100000001b3;
	unsigned __int64 hash = fnvBasis;

	for (auto i = 0; i < strlen(v); i++)
	{
		if (!v[i])
		{
			break;
		}
		hash = hash ^ v[i];
		hash *= fnvPrime;
	}

	return 0x7FFFFFFFFFFFFFFF & hash;
}