#pragma once

extern struct lua_State;
extern struct lua_Debug;

typedef __int32(*lua_CFunction)(void*);
typedef void (*lua_Hook)(lua_State*, lua_Debug*);