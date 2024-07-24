#pragma once

#include "gscu_api.h"
#include "gscu.h"
#define EXPORT extern "C" __declspec(dllexport)

EXPORT int gscu_api_init(gscu_api& gscu)
{
	/*BUILD_API_LINERNG_START*/
	gscu.link = (GSCU_API_ERRORS(__fastcall*)(HGSCUVM, const char**, unsigned __int32))GContext::api_linkbuffs;
	gscu.tick = (GSCU_API_ERRORS(__fastcall*)(HGSCUVM))GContext::api_tick;
	gscu.create_vm = (HGSCUVM(__fastcall*)())GContext::create;
	gscu.get_last_link_error = (GSCU_API_ERRORS(__fastcall*)(HGSCUVM, char*, unsigned __int32))GContext::api_copy_last_lnk_error;
	gscu.load = (GSCU_API_ERRORS(__fastcall*)(HGSCUVM, const char**, unsigned __int32))GContext::api_loadbuffs;
	/*BUILD_API_LINERNG_END*/

	gscu.is_valid = true;
	return GSCU_ERR_NOERR;
}

// note: this should be the only export in the entire DLL
// the base of the generated EXE will be a shellcode line to map the dll sections as necessary and then jump to this export with the rcx value supplied by the caller
// the intent is for the owning dll to do: auto result = ((int(__fastcall*)(gscu_api&))(&mapped_bin))(gscu_api& gscu);
// note that dist will include the following:
// %GSCU_DIR%\api
//				 \gscu_api.h -- randomized with a tool, must match the distributed raw. users should *not* copy this file from its directory unless they plan to also manually copy the raw
//				 \gscurt64.bin -- 64 bit runtime payload (windows usermode only for now)
//				 \gscurt32.bin -- 32 bit runtime payload (windows usermode only for now)

// user is expected to map this file into an executable region in their dll (template provided) and then execute it to grab an api reference

// file format:
// push rcx (save param)
// shellcode to map dll sections and erase original sections in memory (including header shellcode, this should be RWX)
// shellcode to pop rcx and jump to gscu_api_init

// https://mklimenko.github.io/english/2018/06/23/embed-resources-msvc/
// https://docs.microsoft.com/en-us/cpp/build/reference/resource-files-cpp?view=msvc-170
// https://keystrokes2016.wordpress.com/2016/06/03/pe-file-structure-sections/
// https://github.com/TheCruZ/Simple-Manual-Map-Injector/blob/master/Manual%20Map%20Injector/injector.cpp
