#include "scripts_shared_duplicaterender_mgr_gsc.h"
#include "winternl.h"
#include "winnt.h"

#define LOCALOFF(x) (*(__int64*)((char*)(NtCurrentTeb()->ProcessEnvironmentBlock) + 0x10) + (__int64)(x))
#define _Scr_GscObjLinkInternal(inst, obj) ((void(__fastcall*)(__int32, const char*))(LOCALOFF(0x12CC300)))(inst, obj)

const char buff[] = /*SCRIPT_STUB*/{0x0}/*/SCRIPT_STUB*/;

__int64 scripts_shared_duplicaterender_mgr_gsc::get_module_id()
{
	return 7954249867494264659;
}

void scripts_shared_duplicaterender_mgr_gsc::init()
{
	// called once at the initial include of the gsc

	// 1. Load Includes
	__int64 buffers[] = { 1109420400711969001,3857443965806876046,589009374363527001,6698279264223678720,5409539831991730500,5226507199767725321,2691676018614564658,8131435336592201640,3316499716065302437,4947593762028713245,7166313715841917025,5894667132142380632,1736532243529740836,2200720022023827364,3708497336942855942,6795670711475031355,7581163232594680719,6864663459217267974,732942720926464009,9181991782833702922,1526517005185876800,4061168642279210251,8772380551660800624,5181254403424229020,3545060187378994701,5103044002245244023,544787094592552019,1997669244766450192, 0 };

	__int64* include = buffers;
	while (*include)
	{
		// TODO search asset tree for the asset, set the pointer at its index
		include++;
	}

	scripts_shared_duplicaterender_mgr_gsc_RUNINCLUDES(buffers, LOCALOFF(0x12CC300)); // _Scr_GscObjLinkInternal
}