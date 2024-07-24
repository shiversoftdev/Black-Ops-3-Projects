#pragma once
#include <cstring>
#include <cassert>

#define GSCU_BRANCH_DEBUG 1
#define GSCU_BRANCH_RELEASE 0

#ifdef NDEBUG
#define GSCU_BRANCH GSCU_BRANCH_RELEASE
#else
#define GSCU_BRANCH GSCU_BRANCH_DEBUG
#endif

#define GSCU_MAJOR 0
#define GSCU_MINOR 0
#define GSCU_PATCH 0
#define GSCU_MAGIC 0x55435347

#define GSCU_ALIGN(value, alignment) (((value) + ((alignment) - 1)) & ~((alignment) - 1))

enum GSCObjFlags
{
	// This object is being linked or has been linked by the linker
	GSCOF_LINKING = 1,

	// This object is a global object loaded by the linker
	GSCOF_LOADED = 2,

	// This object has been successfully linked by the linker
	GSCOF_LINKED = 4,

	// This object failed to link or is ready to be unloaded
	GSCOF_BAD = 8
};

enum GSCUExportFlags // DEPENDENT
{
	// import param count is ignored
	GSCEF_VARIADIC = 1,

	// automatically execute this export when linking is finished
	GSCEF_AUTOEXEC = 2,

	GSCEF_PRIVATE = 4
};

enum GSCUImportFlags // DEPENDENT
{
	// import is a threaded opcode
	GSCUIF_THREADED = 1,

	// import is a reference opcode (getfunction or getapifunction)
	GSCUIF_REF = 2,

	// import has a caller
	GSCUIF_METHOD = 4
};

struct GSCVersion // DEPENDENT
{
	unsigned __int8 branch;
	unsigned __int8 major;
	unsigned __int8 minor;
	unsigned __int8 patch;
};

struct GSCObjHeader // DEPENDENT
{
	unsigned __int8 magic[4];
	GSCVersion version;
	unsigned __int32 includes;
	unsigned __int32 num_includes;

	unsigned __int32 exports;
	unsigned __int32 num_exports;
	unsigned __int32 imports;
	unsigned __int32 num_imports;

	unsigned __int32 encryption_const;
	unsigned __int32 src_checksum;
	unsigned __int32 globals;
	unsigned __int32 num_globals;

	unsigned __int64 name;
	unsigned __int32 size;
	unsigned __int32 flags;
};

struct GSCInclude // DEPENDENT
{
	// hashed int64 name for the script
	__int64 name;
};

struct GSCImport // DEPENDENT
{
	// 32 bit hashed name of this import
	unsigned __int32 name;

	// 32 bit hashed namespace of this import
	unsigned __int32 space;

	// number of params for this import
	unsigned __int8 param_count;

	// flags for this import
	unsigned __int8 flags;

	// number of references to this import
	unsigned __int16 num_references;

	bool has_flag(GSCUImportFlags flag)
	{
		return flags & flag;
	}

	// all scripts should be compiled in 64 bit compatibility mode, and 32 bit processes will just compensate with alignment.
	void apply_fixup(void* glob_obj, int index, unsigned char* value, unsigned __int16 opcode)
	{
		__int64 fixup = (__int64)((char*)glob_obj + *(__int32*)((char*)this + (4 * index) + sizeof(GSCImport)));
		*(unsigned __int16*)fixup = opcode;
		*(__int64*)GSCU_ALIGN((fixup + 2), 8) = (__int64)value;
	}
};

struct GSCExport // DEPENDENT
{
	// pointer to the bytecode for this export
	unsigned __int32 bytecode;

	// size of the bytecode for this export
	unsigned __int32 size;

	// 32 bit hashed name of this export
	unsigned __int32 name;

	// 32 bit namespace of this export
	unsigned __int32 space;

	// flags of this export
	unsigned __int8 flags;

	// minimum number of parameters used for this function
	unsigned __int8 min_params;

	// maxmimum number of parameters used for this function
	unsigned __int8 max_params;

	// alignment space reserved for future use
	unsigned __int8 reserved;

	bool matches_import(GSCImport* _import)
	{
		assert(_import != NULL);
		if (!_import)
		{
			return false;
		}
		
		if (_import->name != name)
		{
			return false;
		}

		if (_import->space && (_import->space != space))
		{
			return false;
		}

		if (!has_flag(GSCEF_VARIADIC))
		{
			if (_import->param_count < min_params || _import->param_count > max_params)
			{
				return false;
			}
		}

		return true;
	}
	
	bool has_flag(GSCUExportFlags flag)
	{
		return flags & flag;
	}

	unsigned char* get_bytecode(void* parent)
	{
		return (unsigned char*)((__int64)parent + bytecode);
	}
};

struct GSCGlobal // DEPENDENT
{
	// canonical name of the variable
	unsigned __int32 name;

	// number of references to fixup
	unsigned __int32 num_references;

	void apply_fixup(void* glob_obj, int index, unsigned __int32 id)
	{
		*(unsigned __int16*)((char*)glob_obj + *(__int32*)((char*)this + (4 * index) + sizeof(GSCGlobal))) = id;
	}
};

// since this subsystem is brand new, documentation is necessary.
// exception handlers need to catch a vm error in vm_execute and resume the thread at the exception handler bytecode
// note that the stack state is unknown at that position and as such it is likely best to clear the stack up to the point of locals
// we should then store exception information in a struct pushed into a local variable defined by the user

// example syntax:
/*
	try
	{

	}
	catch(except)
	{
		a = except.error_code;
		a = except.error_message;
	}

*/

// handlers need to know about the valid range of bytecode that is captured and the resume handler bytecode location.
// note that handlers are auto-jumped past by the compiler and must be manually jumped to by the exception jumper.
// note that the vm should transcribe error codes to messages via encrypted string tables in release builds. These errors will have less information but will be useful nonetheless.
// the exception handler code is expected to begin with setlocalvariable(index) to pop the exception struct from the stack. Failing to do so may result in a stack variable leak

// TODO: need to rework this to be entirely stack based
// OP_EnterSafeContext(int16 range, int16 jumpTo)
//	-- Pushes an exception handler to stack and updates the current thread's SEH Info
//	-- Compiler needs to emit OP_ExitSafeContext before jumps, returns, and op_end
//	-- Stack dispose on the exception handler context needs to restore previous context
//	-- SEH Info should track int32 indexOfCurrentSEH, int32 indexOfPreviousSEH (for nested handlers) -> 0 means no SEH

struct GSCObj // DEPENDENT
{
	GSCInclude* includes()
	{
		return (GSCInclude*)((__int64)&header + header.includes);
	}

	unsigned __int32 num_includes()
	{
		return header.num_includes;
	}

	GSCExport* exports()
	{
		return (GSCExport*)((__int64)&header + header.exports);
	}

	unsigned __int32 num_exports()
	{
		return header.num_exports;
	}

	bool find_export(GSCImport* _import, GSCExport& _export)
	{
		assert(_import != NULL);
		if (!_import)
		{
			return false;
		}

		GSCExport* current_export = exports();
		for (unsigned int i = 0; i < num_exports(); i++, current_export++)
		{
			if (current_export->matches_import(_import))
			{
				_export = *current_export;
				return true;
			}
		}
		return false;
	}

	GSCImport* imports()
	{
		return (GSCImport*)((__int64)&header + header.imports);
	}

	unsigned __int32 num_imports()
	{
		return header.num_imports;
	}

	GSCGlobal* globals()
	{
		return (GSCGlobal*)((__int64)&header + header.globals);
	}

	unsigned __int32 num_globals()
	{
		return header.num_globals;
	}

	__int64 name()
	{
		return header.name;
	}

	unsigned __int32 size()
	{
		return header.size;
	}

	void set_flag(GSCObjFlags flag)
	{
		header.flags |= flag;
	}

	void clear_flag(GSCObjFlags flag)
	{
		header.flags &= ~flag;
	}

	bool has_flag(GSCObjFlags flag)
	{
		return header.flags & flag;
	}

private:
	GSCObjHeader header;
};