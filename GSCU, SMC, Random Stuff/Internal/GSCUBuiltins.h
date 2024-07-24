#pragma once
#include "gscu.h"

#define GSCU_ERROR_API_INVALID_ARGS GSCU_API_ERROR(0x0FFFF000 | 0x0)

namespace GSCUBuiltins
{
	void register_default_builtins(GContext* context);

	namespace con
	{
		__int32 println(GSCUCallContext& ctx);
	}

	namespace arr
	{
		__int32 add(GSCUCallContext& ctx);
	}
}

class scr_builtin_const
{
public:
	static const __int32 con;
	static const __int32 println;
};