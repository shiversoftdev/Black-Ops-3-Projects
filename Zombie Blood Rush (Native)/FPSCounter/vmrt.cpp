#include "vmrt.h"
#include <unordered_map>

vmrt vmrt::inst;
INT64 vmrt::original_dvar_value = NULL;
bool vmrt::are_hooks_enabled = false;
bool vmrt::is_initialized = false;
char vmrt::var_tree[VMRT_SCRVAR_COUNT_TOTAL * 512 + 2048];
char vmrt::var_stats[1024 * 8];
const char* vmrt::var_typename[] = 
{
	"undefined",
	"pointer",
	"string",
	"istring",
	"vector",
	"hash",
	"float",
	"int",
	"uint64",
	"uintptr",
	"entityoffset",
	"codepos",
	"precodepos",
	"apifunction",
	"function",
	"stack",
	"animation",
	"thread",
	"notifythread",
	"timethread",
	"childthread",
	"class",
	"struct",
	"removedentity",
	"entity",
	"array",
	"removedthread",
	"<free>",
	"threadlist",
	"entlist"
};

vmrt::tSL_LookupCanonicalString vmrt::SL_LookupCanonicalString;
vmrt::tScrStr_ConvertToString vmrt::ScrStr_ConvertToString;

void vmrt::install()
{
	if (is_initialized)
	{
		return;
	}

	// MH_Initialize();
	vmrt::setup_hooks();

	is_initialized = true;

	//SL_LookupCanonicalString = (tSL_LookupCanonicalString)PTR_SL_LookupCanonicalString;
	ScrStr_ConvertToString = (tScrStr_ConvertToString)PTR_ScrStr_ConvertToString;
}

void vmrt::disable_hooks_fast()
{
	/*if (vmrt::are_hooks_enabled)
	{
		vmrt::are_hooks_enabled = false;
		MH_DisableHook(MH_ALL_HOOKS);
		vmrt::hooks_disabled();
	}*/
}

void vmrt::enable_hooks_fast()
{
	/*if (!vmrt::are_hooks_enabled)
	{
		vmrt::are_hooks_enabled = true;
		MH_EnableHook(MH_ALL_HOOKS);
		vmrt::hooks_enabled();
	}*/
}

LONG vmrt::catch_vm_restart(_EXCEPTION_POINTERS* ExceptionInfo)
{
	//if (ExceptionInfo->ExceptionRecord->ExceptionCode != EXCEPTION_ACCESS_VIOLATION)
	//{
	//	return EXCEPTION_CONTINUE_SEARCH;
	//}

	//if ((INT64)ExceptionInfo->ExceptionRecord->ExceptionAddress != OFF_VMRT_EXCEPT_LOC)
	//{
	//	return EXCEPTION_CONTINUE_SEARCH;
	//}

	//ExceptionInfo->ContextRecord->Rcx = vmrt::original_dvar_value;
	//ExceptionInfo->ContextRecord->Rip = OFF_VMRT_EXCEPT_LOC;

	//if (!vmrt::original_dvar_value)
	//{
	//	ExceptionInfo->ContextRecord->Rip = OFF_VMRT_EXCEPT_FASTRET;
	//}

	//// 3: when caught, check is ui level, if so, unhook, if not, rehook
	//if (*(bool*)(OFF_VMRT_s_runningUILevel))
	//{
	//	vmrt::disable_hooks_fast();
	//}
	//else
	//{
	//	vmrt::enable_hooks_fast();
	//}

	return EXCEPTION_CONTINUE_EXECUTION;
}

void vmrt::setup_hooks()
{
}

void vmrt::hooks_enabled()
{
}

void vmrt::hooks_disabled()
{
}

void visualize_buff_write(char** inBuffPtr, const char* fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	*inBuffPtr = (*inBuffPtr) + vsnprintf(*inBuffPtr, 512, fmt, args);
	va_end(args);
}

ScrVarIndex_t vmrt::ScrVar_FirstChild(int inst, ScrVarIndex_t parentId)
{
	ScrVar_t* scriptVariables = vmrt::get_vm_variables(inst);
	if (scriptVariables[parentId].value.type < VAR_THREAD || scriptVariables[parentId].value.type > VAR_REMOVEDTHREAD)
	{
		return NULL;
	}
	return scriptVariables[parentId].value.u.stringValue;
}

char* vmrt::get_var_tree(bool cached)
{
	if (cached)
	{
		return vmrt::var_tree;
	}

	vmrt::install();

	// clear existing vartree
	memset(vmrt::var_tree, 0, sizeof(vmrt::var_tree));
	char* currentPos = vmrt::var_tree;

	for (int i = 0; i < 2; i++)
	{
		vmrt::ScrVar_VisualizeVarTree(i, &currentPos);
		visualize_buff_write(&currentPos, "\n\n");
	}

	return vmrt::var_tree;
}

char* vmrt::get_var_usage()
{
	vmrt::install();

	std::unordered_map<ScrVarType_t, int32_t> varUsageTracker;
	memset(vmrt::var_stats, 0, sizeof(vmrt::var_stats));
	char* currentPos = vmrt::var_stats;

	for (int inst = 0; inst < 2; inst++)
	{
		ScrVar_t* scriptVariables = vmrt::get_vm_variables(inst);
		int capNumVars = inst ? VMRT_SCRVAR_COUNT_CL : VMRT_SCRVAR_COUNT_SV;
		varUsageTracker.clear();

		for (int i = 0; i < VAR_COUNT; i++)
		{
			varUsageTracker[(ScrVarType_t)i] = 0;
		}

		int numAllocations = 0;
		for (int id = 0; id < capNumVars; id++)
		{
			auto variable = scriptVariables[id];
			varUsageTracker[variable.value.type]++;
			if (variable.value.type != VAR_FREE)
			{
				numAllocations++;
			}
		}

		visualize_buff_write(&currentPos, "%s Variable Statistics:\n", inst ? "CLIENT" : "SERVER");
		visualize_buff_write(&currentPos, "\tVariable Allocations: %d out of %d allocated\n", numAllocations, capNumVars);
		for (int i = 0; i < VAR_COUNT; i++)
		{
			visualize_buff_write(&currentPos, "\tType %s allocated: %d\n", vmrt::var_typename[i], varUsageTracker[(ScrVarType_t)i]);
		}
		visualize_buff_write(&currentPos, "\n\n");
	}

	return vmrt::var_stats;
}

void vmrt::ScrVar_VisualizeVarTree(int inst, char** inBuffPtr)
{
	ScrVarIndex_t visualizeIdStack[1024] = {};
	bool followStack[1024] = {};
	int lineNum = 0;
	ScrVar_t* scriptVariables = vmrt::get_vm_variables(inst);

	visualize_buff_write(inBuffPtr, "+ %s ROOT\n", inst ? "CLIENT" : "SERVER");

	int capNumVars = inst ? VMRT_SCRVAR_COUNT_CL : VMRT_SCRVAR_COUNT_SV;
	for (int i = 0; i < capNumVars; i++)
	{
		*(INT32*)&scriptVariables[i].info = (8 * (*(INT32*)&scriptVariables[i].info >> 3) & 0x1D) | *(INT32*)&scriptVariables[i].info & 0xFFFFFF07;
	}

	int numVarsProcessed = 0;
	for (int i = 0; i < capNumVars; i++)
	{
		if (scriptVariables[i].value.type != VAR_FREE)
		{
			vmrt::ScrVar_VisualizeVarTreeInternal(inst, inBuffPtr, i, &lineNum, 1, visualizeIdStack, followStack);
			numVarsProcessed++;
		}
	}

	for (int i = 0; i < capNumVars; i++)
	{
		*(INT32*)&scriptVariables[i].info = (8 * (*(INT32*)&scriptVariables[i].info >> 3) & 0x1D) | *(INT32*)&scriptVariables[i].info & 0xFFFFFF07;
	}

	visualize_buff_write(inBuffPtr, "\nVar allocations: (%d / %d)\n", numVarsProcessed, capNumVars);
}

void vmrt::ScrVar_VisualizeVarTreeInternal(int inst, char** inBuffPtr, ScrVarIndex_t id, int* lineNum, int depth, ScrVarIndex_t* visualizeIdStack, bool* followStack)
{
	int capNumVars = inst ? VMRT_SCRVAR_COUNT_CL : VMRT_SCRVAR_COUNT_SV;
	ScrVar_t* scriptVariables = vmrt::get_vm_variables(inst);
	ScrVarIndex_t parentId = scriptVariables[id].parentId;

	if (((*(uint32_t*)&scriptVariables[id].info) >> 3) & 2)
	{
		visualize_buff_write(inBuffPtr, "      ");
	}
	else
	{
		visualize_buff_write(inBuffPtr, "%6d", *lineNum);
		++*lineNum;
	}

	for (int i = 0; i < depth; i++)
	{
		if (followStack[i])
		{
			visualize_buff_write(inBuffPtr, "|  ");
		}
		else
		{
			visualize_buff_write(inBuffPtr, "   ");
		}
	}

	visualize_buff_write(inBuffPtr, "|__%X::%d::%s::", id, *(uint32_t*)&scriptVariables[id].info >> 8, vmrt::var_typename[scriptVariables[id].value.type]);

	switch (*(INT32*)&scriptVariables[id].info & 7)
	{
		case 1:
		{
			if (scriptVariables[parentId].value.type - VAR_CLASS > 2)
			{
				visualize_buff_write(inBuffPtr, "(integer)%ld::", scriptVariables[id].nameIndex);
			}
			else if (scriptVariables[id].nameIndex == capNumVars + 0x20000) // TODO: verify that this const is still the same in BO3 (it's likely not)
			{
				visualize_buff_write(inBuffPtr, "(integer)%s::", "OBJECT_NOTIFY_LIST ");
			}
			else if (scriptVariables[id].nameIndex == capNumVars + 0x20001) // TODO: verify that this const is still the same in BO3 (it's likely not)
			{
				visualize_buff_write(inBuffPtr, "(integer)%s::", "OBJECT_STACK ");
			}
			else
			{
				visualize_buff_write(inBuffPtr, "(integer)%ld::", scriptVariables[id].nameIndex);
			}
		}
		break;
		case 2:
		{
			ScrVarCannonicalName_t canonicalName = scriptVariables[id].nameIndex;
			char* name = SL_LookupCanonicalString(canonicalName);
			if (name)
			{
				visualize_buff_write(inBuffPtr, "(canonic)%s::", name);
			}
		}
		break;
		case 3:
		{
			const char* strVal = ScrStr_ConvertToString(scriptVariables[id].nameIndex);
			if (!strVal)
			{
				strVal = "(null)";
			}
			visualize_buff_write(inBuffPtr, "(string )\"%s\"::", strVal);
		}
		break;
		case 4:
		{
			visualize_buff_write(inBuffPtr, "(name   )%ld::", scriptVariables[id].nameIndex);
		}
		break;
		case 5:
		{
			visualize_buff_write(inBuffPtr, "(weapon )%ld::", scriptVariables[id].nameIndex);
		}
		break;
		default:
		{
			visualize_buff_write(inBuffPtr, "!!ERROR!!::");
		}
		break;
	}

	switch (scriptVariables[id].value.type)
	{
		case VAR_UNDEFINED:
		{
			visualize_buff_write(inBuffPtr, " ");
		}
		break;
		case VAR_POINTER:
		{
			visualize_buff_write(inBuffPtr, "%08X ", scriptVariables[id].value.u.pointerValue);
		}
		break;
		case VAR_STRING:
		case VAR_ISTRING:
		{
			const char* strVal = ScrStr_ConvertToString(scriptVariables[id].value.u.stringValue);
			if (!strVal)
			{
				strVal = "(null)";
			}
			visualize_buff_write(inBuffPtr, "\"%s\" ", strVal);
		}
		break;
		case VAR_VECTOR:
		{
			float x = scriptVariables[id].value.u.vectorValue[0];
			float y = scriptVariables[id].value.u.vectorValue[1];
			float z = scriptVariables[id].value.u.vectorValue[2];
			visualize_buff_write(inBuffPtr, "(%0.1f,%0.1f,%0.1f) ", x, y, z);
		}
		break;
		case VAR_HASH:
		{
			visualize_buff_write(inBuffPtr, "%04X ", scriptVariables[id].value.u.hashValue);
		}
		break;
		case VAR_FLOAT:
		{
			visualize_buff_write(inBuffPtr, "%0.1f ", scriptVariables[id].value.u.floatValue);
		}
		break;
		case VAR_INTEGER:
		{
			visualize_buff_write(inBuffPtr, "%ld ", scriptVariables[id].value.u.intValue);
		}
		break;
		case VAR_UINT64:
		case VAR_UINTPTR:
		case VAR_CODEPOS:
		case VAR_PRECODEPOS:
		case VAR_FUNCTION:
		case VAR_STACK:
		case VAR_ANIMATION:
		{
			visualize_buff_write(inBuffPtr, "%016llX ", scriptVariables[id].value.u.intValue);
		}
		break;
		case VAR_THREAD:
		case VAR_NOTIFYTHREAD:
		case VAR_TIMETHREAD:
		case VAR_CHILDTHREAD:
		{
			visualize_buff_write(inBuffPtr, "%08X ", scriptVariables[id].o.size);
		}
		break;
		case VAR_CLASS:
		case VAR_STRUCT:
		case VAR_REMOVEDENTITY:
		case VAR_ENTITY:
		case VAR_ARRAY:
		case VAR_REMOVEDTHREAD:
		case VAR_FREE:
		{
			visualize_buff_write(inBuffPtr, " ");
		}
		break;
		default:
		{
			/*
				VAR_ENTITYOFFSET
				VAR_APIFUNCTION
				VAR_THREADLIST
				VAR_ENTLIST
			*/
			visualize_buff_write(inBuffPtr, "<??> ");
		}
		break;
	}

	if ((*(INT32*)&scriptVariables[id].info >> 3) & 2)
	{
		visualize_buff_write(inBuffPtr, " ...\n");
	}
	else
	{
		visualize_buff_write(inBuffPtr, "\n");
		*(INT32*)&scriptVariables[id].info = (8 * (((*(INT32*)&scriptVariables[id].info >> 3) & 0x1F | 2) & 0x1F)) | *(INT32*)&scriptVariables[id].info & 0xFFFFFF07;
		visualizeIdStack[depth] = id;
		
		if (scriptVariables[id].value.type == VAR_POINTER)
		{
			bool doFollowStack = 1;
			if ((*(INT32*)&scriptVariables[id].info & 7) != 4)
			{
				doFollowStack = ScrVar_FirstChild(inst, id) != NULL;
			}
			followStack[depth + 1] = doFollowStack;
			ScrVar_VisualizeVarTreeInternal(inst, inBuffPtr, scriptVariables[id].value.u.pointerValue, lineNum, depth + 1, visualizeIdStack, followStack);
		}

		if ((*(INT32*)&scriptVariables[id].info & 7) == 4)
		{
			followStack[depth + 1] = ScrVar_FirstChild(inst, id) != NULL;
			ScrVarIndex_t tempId = scriptVariables[id].nameIndex;
			ScrVar_VisualizeVarTreeInternal(inst, inBuffPtr, tempId, lineNum, depth + 1, visualizeIdStack, followStack);
		}

		for (ScrVarIndex_t childId = ScrVar_FirstChild(inst, id); childId; childId = scriptVariables[childId].nextSibling)
		{
			followStack[depth + 1] = scriptVariables[childId].nextSibling != NULL;
			ScrVar_VisualizeVarTreeInternal(inst, inBuffPtr, childId, lineNum, depth + 1, visualizeIdStack, followStack);
		}
	}
}

ScrVar_t* vmrt::get_vm_variables(int inst)
{
	return (ScrVar_t*)*(INT64*)((char*)OFF_ScrVarGlob + 128 + (inst << 8));
}


#pragma region exports
EXPORT char* VMRT_VisualizeVarTree()
{
	return vmrt::get_var_tree(false);
}

EXPORT char* VMRT_GetVarUsage()
{
	return vmrt::get_var_usage();
}
#pragma endregion