#pragma once

typedef const void* HGSCUVM;
typedef unsigned __int32 HGSCUVMAPI;

enum GSCU_API_ERRORS
{
	/// <summary>
	/// The operation completed successfully
	/// </summary>
	GSCU_ERR_NOERR = 0,
	/// <summary>
	/// The object supplied to link was invalid or null
	/// </summary>
	GSCU_ERR_BADOBJECT = 1,
	/// <summary>
	/// The class being registered was already registered previously
	/// </summary>
	GSCU_ERR_CLASS_ALREADY_REGISTERED = 2,
	/// <summary>
	/// The class being modified was bad, either because it is protected or because it was never registered
	/// </summary>
	GSCU_ERR_BAD_CLASS = 3,
};

// use this to throw your errors
#define GSCU_API_ERROR(e) (0xF0000000 | (unsigned __int32)(e))

// example errors:
#define API_EXAMPLE 0x0F000000
#define GSCU_API_EXAMPLE_ERROR1 GSCU_API_ERROR(API_EXAMPLE | 0x0);
#define GSCU_API_EXAMPLE_ERROR2 GSCU_API_ERROR(API_EXAMPLE | 0x1);

#define GSCU_BADVAR 0xFFFFFFFF

struct gscu_api
{
	GSCU_API_ERRORS(__fastcall* tick)(HGSCUVM vm) = (GSCU_API_ERRORS(__fastcall*)(HGSCUVM))0xFFFFFFFF;
	GSCU_API_ERRORS(__fastcall* get_last_link_error)(HGSCUVM vm, char* buffer, unsigned __int32 sizeofbuffer) = (GSCU_API_ERRORS(__fastcall*)(HGSCUVM, char*, unsigned __int32))0xFFFFFFFF;
	GSCU_API_ERRORS(__fastcall* load)(HGSCUVM vm, const char** buffers, unsigned __int32 count) = (GSCU_API_ERRORS(__fastcall*)(HGSCUVM, const char**, unsigned __int32))0xFFFFFFFF;
	HGSCUVM(__fastcall* create_vm)() = (HGSCUVM(__fastcall*)())0xFFFFFFFF;
	GSCU_API_ERRORS(__fastcall* link)(HGSCUVM vm, const char** buffers, unsigned __int32 count) = (GSCU_API_ERRORS(__fastcall*)(HGSCUVM, const char**, unsigned __int32))0xFFFFFFFF;
	bool is_valid;
};
