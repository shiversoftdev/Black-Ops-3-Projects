#pragma once
#include "anticheat.h"
#include "Offsets.h"
#include "protection.h"
#include "dll_resources/msdetours.h"
#include "mh.h"

namespace anticheat
{
	DECLSPEC_NOINLINE void verify_dvar_values();
}