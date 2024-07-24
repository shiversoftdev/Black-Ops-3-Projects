#pragma once
#include "framework.h"
#include "include/MinHook.h"
#include "dll_resources\msdetours.h"
#include "offset_fixups.h"
//#define MH_Install(off, fn_name) MH_CreateHook((LPVOID)off, (LPVOID)fn_name, (LPVOID*)& ## __ ## fn_name); fn_name ## _ptr = (INT64)off
//#define MH_Define_WINAPI(fn_name, fn_return, fn_params) typedef fn_return (WINAPI* __ ## fn_name ## _t)fn_params; \
//__ ## fn_name ## _t __ ## fn_name = NULL;\
//INT64 fn_name ## _ptr = NULL;\
//fn_return WINAPI fn_name ## fn_params
//
//#define MH_Define_FASTCALL(fn_name, fn_return, fn_params) typedef fn_return (__fastcall* __ ## fn_name ## _t)fn_params; \
//__ ## fn_name ## _t __ ## fn_name = NULL;\
//INT64 fn_name ## _ptr = NULL;\
//fn_return __fastcall fn_name ## fn_params

//#define MH_ORIGINAL(fn_name, fn_params) __ ## fn_name fn_params
//#define MH_Activate(fn_name) MH_EnableHook((LPVOID)fn_name ## _ptr)
//#define MH_Deactivate(fn_name) MH_DisableHook((LPVOID)fn_name ## _ptr)
//#define MH_CreateRun(off, fn_name) MH_Install(off, fn_name); MH_Activate(fn_name)

#define MDT_Activate(fn_name) DetourAttach(&(PVOID&)__ ## fn_name, fn_name)
#define MDT_Deactivate(fn_name) DetourDetach(&(PVOID&)__ ## fn_name, fn_name)
#define MDT_ORIGINAL(fn_name, fn_params) __ ## fn_name fn_params
#define MDT_ORIGINAL_PTR(fn_name) __ ## fn_name
#define MDT_Define_FASTCALL(off, fn_name, fn_return, fn_params) typedef fn_return (__fastcall* __ ## fn_name ## _t)fn_params; \
__ ## fn_name ## _t __ ## fn_name = (__ ## fn_name ## _t) off;\
fn_return __fastcall fn_name ## fn_params

#define MDT_Define_FASTCALL_STATIC(off, fn_name, fn_return, fn_params) typedef fn_return (__fastcall* __ ## fn_name ## _t)fn_params; \
static __ ## fn_name ## _t __ ## fn_name = (__ ## fn_name ## _t) off; fn_return __fastcall fn_name ## fn_params

#define MDT_Implement_STATIC(ns, fn_name, fn_return, fn_params) fn_return __fastcall ns::fn_name ## fn_params