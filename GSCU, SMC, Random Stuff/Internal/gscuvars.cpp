#include "GSCUVars.h"

const __int32 scr_const::array = CONST32("array");
const __int32 scr_const::vm = CONST32("vm");
const __int32 scr_const::level = CONST32("level");
const __int32 scr_const::global = CONST32("global");
const __int32 scr_const::globals = CONST32("globals");
const __int32 scr_const::event = CONST32("event");
const __int32 scr_const::object = CONST32("object");
const __int32 scr_const::size = CONST32("size");
const __int32 scr_const::x = CONST32("x");
const __int32 scr_const::y = CONST32("y");
const __int32 scr_const::z = CONST32("z");
const __int32 scr_const::w = CONST32("w");
const __int32 scr_const::error_code = CONST32("error_code");
const __int32 scr_const::error_message = CONST32("error_message");
const __int32 scr_const::classname = CONST32("classname");
const __int32 scr_const::ctor = CONST32(".ctor");
const __int32 scr_const::dtor = CONST32(".dtor");
const __int32 scr_const::ctorauto = CONST32(".ctor_auto");
const __int32 scr_const::dtorauto = CONST32(".dtor_auto");
const __int32 scr_const::add = CONST32("add");

const unsigned __int64 scr_notifies::death = CONST64("death");

bool GSCUVars::can_add(GSCUVariableType tx, GSCUVariableType ty)
{
	switch ((tx << 8) | ty)
	{
		case TYPECOMBINE(GSCUVAR_VECTOR, GSCUVAR_VECTOR):
		case TYPECOMBINE(GSCUVAR_FLOAT, GSCUVAR_FLOAT):
		case TYPECOMBINE(GSCUVAR_STRING, GSCUVAR_STRING):
		case TYPECOMBINE(GSCUVAR_INTEGER, GSCUVAR_INTEGER):
		TYPECOMBINECASE(GSCUVAR_INTEGER, GSCUVAR_STRING)
		TYPECOMBINECASE(GSCUVAR_INTEGER, GSCUVAR_FLOAT)
		TYPECOMBINECASE(GSCUVAR_INTEGER, GSCUVAR_VECTOR)
		TYPECOMBINECASE(GSCUVAR_STRING, GSCUVAR_FLOAT)
		TYPECOMBINECASE(GSCUVAR_STRING, GSCUVAR_VECTOR)
		TYPECOMBINECASE(GSCUVAR_FLOAT, GSCUVAR_VECTOR)
		return true;
	}
	return false;
}

bool GSCUVars::can_subtract(GSCUVariableType tx, GSCUVariableType ty)
{
	switch ((tx << 8) | ty)
	{
		case TYPECOMBINE(GSCUVAR_VECTOR, GSCUVAR_VECTOR):
		case TYPECOMBINE(GSCUVAR_FLOAT, GSCUVAR_FLOAT):
		case TYPECOMBINE(GSCUVAR_INTEGER, GSCUVAR_INTEGER):
		TYPECOMBINECASE(GSCUVAR_INTEGER, GSCUVAR_FLOAT)
		TYPECOMBINECASE(GSCUVAR_INTEGER, GSCUVAR_VECTOR)
		TYPECOMBINECASE(GSCUVAR_FLOAT, GSCUVAR_VECTOR)
		return true;
	}
	return false;
}

bool GSCUVars::can_multiply(GSCUVariableType tx, GSCUVariableType ty)
{
	switch ((tx << 8) | ty)
	{
		case TYPECOMBINE(GSCUVAR_VECTOR, GSCUVAR_VECTOR):
		case TYPECOMBINE(GSCUVAR_FLOAT, GSCUVAR_FLOAT):
		case TYPECOMBINE(GSCUVAR_INTEGER, GSCUVAR_INTEGER):
		TYPECOMBINECASE(GSCUVAR_INTEGER, GSCUVAR_FLOAT)
		TYPECOMBINECASE(GSCUVAR_INTEGER, GSCUVAR_VECTOR)
		TYPECOMBINECASE(GSCUVAR_FLOAT, GSCUVAR_VECTOR)
		return true;
	}
	return false;
}

bool GSCUVars::can_divide(GSCUVariableType tx, GSCUVariableType ty)
{
	switch ((tx << 8) | ty)
	{
		case TYPECOMBINE(GSCUVAR_VECTOR, GSCUVAR_VECTOR):
		case TYPECOMBINE(GSCUVAR_FLOAT, GSCUVAR_FLOAT):
		case TYPECOMBINE(GSCUVAR_INTEGER, GSCUVAR_INTEGER):
		TYPECOMBINECASE(GSCUVAR_INTEGER, GSCUVAR_FLOAT)
			TYPECOMBINECASE(GSCUVAR_INTEGER, GSCUVAR_VECTOR)
			TYPECOMBINECASE(GSCUVAR_FLOAT, GSCUVAR_VECTOR)
			return true;
	}
	return false;
}

float GSCUVars::vector_length(GSCUVector& vec)
{
	return sqrt((vec.x * vec.x) + (vec.y * vec.y) + (vec.z * vec.z) + (vec.w * vec.w));
}
