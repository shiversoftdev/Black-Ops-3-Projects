#pragma once
#include <vector>
#include <unordered_map>
#include <functional>
#include "GSCUHashing.h"

// array design:
// we are pretty much guaranteed to need a key/value system such that both a key variable and a value variable exist on the heap.
// we cant just use id and parent because doing this would result in canon name collisions for long and similar strings.
// we can, however, use a specially constructed key/value combination system because we actually have a lot of space available (0xC) outside of varref behavior for struct members.
// theory: arrayelement { key64 : vRef32 : bType : bReserved[3] } => arrayvalue
// it seems as though all struct fields need to adhere to the kvp system and arrays/structs need to just be the same thing
// the only real difference would be the classname allowing structs to basically just be arrays with methods

// foreach pattern going to look something like:
// key = GSCUOP_FirstField(array)
// loop_start:
// value = GSCUOP_GetFieldValue(key);
// if(!isdefined(value)) break;
// code here
// loop_end:
// key = GSCUOP_NextField(key);
// goto loop_start;

// every time a variable is added, check GSCU_ERROR_RUNTIME_TYPEESCAPEEXCEPTION
// TODO GSCUVAR_SEHFRAME

enum GSCUVariableType // DEPENDENT
{
	GSCUVAR_FREE = 0,
	GSCUVAR_THREAD = 1,
	GSCUVAR_BEGINPARAMS = 2,
	GSCUVAR_PRECODEPOS = 3,
	GSCUVAR_UNDEFINED = 4,
	GSCUVAR_REFVAR = 5,
	GSCUVAR_INTEGER = 6,
	GSCUVAR_STRING = 7,
	GSCUVAR_FLOAT = 8,
	GSCUVAR_STRUCT = 9,
	GSCUVAR_HASH = 10,
	GSCUVAR_VECTOR = 11,
	GSCUVAR_ENDON = 12,
	GSCUVAR_WAITTILL = 13,
	GSCUVAR_FUNCTION = 14,
	GSCUVAR_SEHFRAME = 15,
	GSCUVAR_ITERATOR2 = 16,
	GSCUVAR_COUNT
};

enum GSCUCastableVariableType // DEPENDENT
{
	GSCUCVAR_UNDEFINED = GSCUVAR_UNDEFINED,
	GSCUCVAR_INTEGER = GSCUVAR_INTEGER,
	GSCUCVAR_STRING = GSCUVAR_STRING,
	GSCUCVAR_FLOAT = GSCUVAR_FLOAT,
	GSCUCVAR_HASH = GSCUVAR_HASH,
	GSCUCVAR_VECTOR = GSCUVAR_VECTOR,
	GSCUCVAR_FUNCTION = GSCUVAR_FUNCTION,
	GSCUCVAR_STRUCT = GSCUVAR_COUNT,
	GSCUCVAR_ARRAY = GSCUCVAR_STRUCT + 1
};

enum GSCUThreadFlags
{
	GSCUTF_NATIVE = 1,
	GSCUTF_MAIN_THREAD = 2,
	GSCUTF_EXITED = 4,
	GSCUTF_SUSPENDED = 8,
	GSCUTF_RAISE_EXCEPTION = 16
};

struct GSCUStackFrame
{
	unsigned __int32 self;
	unsigned __int16 old_start_locals;
	unsigned __int8 old_num_params;
	unsigned __int8 reserved[9];
};

union GSCUNativeDataStructure
{
	std::unordered_map<unsigned __int32, unsigned __int32>* s;
	std::vector<unsigned __int32>* a;
	unsigned __int64 i64;
};

struct GSUStructInfo
{
	unsigned __int32 classname;
	unsigned __int32 reserved;
	GSCUNativeDataStructure native;
};

struct GSCUEndonMarker
{
	// the hash which will cause this endon to be triggered
	unsigned __int64 condition_hash;
	unsigned __int32 parent_id;
	unsigned __int32 reserved;
};

struct GSCUWaittillMarker
{
	// the hash which will cause this waittill to be triggered
	unsigned __int64 condition_hash;
	unsigned __int32 parent_id;
	unsigned __int32 reserved;
};

struct GSCUFunctionPointer
{
	// pointer to the function
	unsigned __int64 func;
	// variable id of stack capture for local functions (if non zero)
	unsigned __int32 captures;
	
	// describes the function's type
	bool is_script_function;

	unsigned __int8 reserved[3];
};

enum GSCUStringBucketType
{
	/// <summary>
	/// Small buckets used for tiny append operations
	/// </summary>
	GSCUSB_32,
	/// <summary>
	/// Medium-small buckets used for slightly larger append operations (largest bucket)
	/// </summary>
	GSCUSB_64,
	/// <summary>
	/// Medium buckets used for strings which overflow the 64 buckets
	/// </summary>
	GSCUSB_256,
	/// <summary>
	/// Large, on demand buckets for strings larger than 256 bytes. Performance with these buckets might be not so nice.
	/// </summary>
	GSCUSB_CUSTOM,
	/// <summary>
	/// Unbucketed string, most likely a user-string or a obj-string. These strings cannot be freed as we do not control their memory space.
	/// </summary>
	GSCUSB_NONE
};

struct GSCUStrBucketEntryHead
{
	/// <summary>
	/// Index of the next free entry in this bucket (or -1 if none, to which the allocater should expand)
	/// </summary>
	__int32 next_free;

	/// <summary>
	/// String length of the current occupant
	/// </summary>
	__int16 current_size;
	__int16 max_size;

	/// <summary>
	/// Number of internal references to this bucket entry. When the ref count is 0 or lower, this bucket will be freed.
	/// </summary>
	__int32 ref_count;

	/// <summary>
	/// 0 if free, 1 if in use
	/// </summary>
	unsigned __int8 in_use;

	// alignment and reserve space
	unsigned __int8 reserved[3];
};

struct GSCUStrBucketEntry_32
{
	GSCUStrBucketEntryHead head;
	char str[32];

	GSCUStrBucketEntry_32()
	{
		memset(str, 0, sizeof(str));
		head.in_use = false;
		head.next_free = -1;
		head.current_size = 0;
		head.max_size = 31;
		head.ref_count = 0;
	}
};

struct GSCUStrBucketEntry_64
{
	GSCUStrBucketEntryHead head;
	char str[64];

	GSCUStrBucketEntry_64()
	{
		memset(str, 0, sizeof(str));
		head.in_use = false;
		head.next_free = -1;
		head.current_size = 0;
		head.max_size = 63;
		head.ref_count = 0;
	}
};

struct GSCUStrBucketEntry_256
{
	GSCUStrBucketEntryHead head;
	char str[256];

	GSCUStrBucketEntry_256()
	{
		memset(str, 0, sizeof(str));
		head.in_use = false;
		head.next_free = -1;
		head.current_size = 0;
		head.max_size = 255;
		head.ref_count = 0;
	}
};

struct GSCUStrBucketEntry_CUSTOM
{
	GSCUStrBucketEntryHead head;
	char* str; // a heap struct pointer that will be managed by the string allocator

	GSCUStrBucketEntry_CUSTOM()
	{
		str = 0;
		head.in_use = false;
		head.next_free = -1;
		head.current_size = 0;
		head.max_size = 0;
		head.ref_count = 0;
	}
};

struct GSCUString
{
	/// <summary>
	/// A handle to the string
	/// </summary>
	char* str_ref;

	/// <summary>
	/// Bucket of the string
	/// </summary>
	unsigned __int8 bucket;

	unsigned __int8 reserved[3];

	/// <summary>
	/// Length of the string
	/// </summary>
	unsigned __int16 size;
	unsigned __int16 max_size;


	GSCUStringBucketType get_bucket()
	{
		return (GSCUStringBucketType)bucket;
	}

	void set_bucket(GSCUStringBucketType btype)
	{
		bucket = (unsigned __int8)btype;
	}
};

struct GSCUStringBucketRef
{
	void* entry;
	GSCUStringBucketType type;
	__int32 index;
};

/*
	The string allocator manages all heap bound strings in the VM.
	Typically, a string is going to be sourced from a non-bucketed, readonly source, like the GetString VM operation.
	However, string manipulation cannot operate on read-only strings, so the allocator needs to exist for concatenated and modified strings.
	Any time a string operation modifies a string, a new allocator must spawn. We can reuse slots if there is only one reference to the string and the new string doesnt exceed the current bucket size.
	Buckets reserve space in chunks so that allocation and deallocation doesnt happen often. Each bucket entry has a head describing its contents. The first bucket entry in each bucket acts as both a null string (ref count never 0), and as a pointer to the next free entry in the tree.
*/
struct GSCUStringAllocator
{
	std::vector<GSCUStrBucketEntry_32> Buckets32;
	std::vector<GSCUStrBucketEntry_64> Buckets64;
	std::vector<GSCUStrBucketEntry_256> Buckets256;
	std::unordered_map<char*, GSCUStrBucketEntry_CUSTOM> BucketsCustom;
	std::unordered_map<char*, GSCUStringBucketRef> BucketLookupTable;

	GSCUStringAllocator()
	{
		Buckets32.reserve(2048);
		Buckets64.reserve(2048);
		Buckets256.reserve(1024);

		for (int i = 0; i < 2048; i++)
		{
			Buckets32.push_back(GSCUStrBucketEntry_32());
			Buckets64.push_back(GSCUStrBucketEntry_64());

			Buckets32.back().head.next_free = i + 1;
			Buckets64.back().head.next_free = i + 1;

			if (i < 1024)
			{
				Buckets256.push_back(GSCUStrBucketEntry_256());
				Buckets256.back().head.next_free = i + 1;
			}
		}

		// setup tails of the major buckets
		Buckets32.back().head.next_free = -1;
		Buckets64.back().head.next_free = -1;
		Buckets256.back().head.next_free = -1;

		// setup heads of the major buckets
		Buckets32.at(0).head.in_use = true;
		Buckets32.at(0).head.ref_count = 100;
		Buckets64.at(0).head.in_use = true;
		Buckets64.at(0).head.ref_count = 100;
		Buckets256.at(0).head.in_use = true;
		Buckets256.at(0).head.ref_count = 100;
	}

	/// <summary>
	/// Expands the target bucket by a predetermined amount so that memory allocations are both infrequent and efficient.
	/// </summary>
	/// <param name="bucket_type"></param>
	/// <returns></returns>
	__int32 bucket_expand(GSCUStringBucketType bucket_type)
	{
		switch (bucket_type)
		{
		case GSCUSB_32:
		{
			auto old_size = (__int32)Buckets32.size();
			auto new_size = old_size + 2048;
			Buckets32.reserve(new_size);

			for (__int32 i = old_size; i < new_size; i++)
			{
				Buckets32.push_back(GSCUStrBucketEntry_32());
				Buckets32.back().head.next_free = i + 1;
			}

			Buckets32.back().head.next_free = -1;
			Buckets32.at(0).head.next_free = old_size;
		}
		break;
		case GSCUSB_64:
		{
			auto old_size = (__int32)Buckets64.size();
			auto new_size = old_size + 2048;
			Buckets64.reserve(new_size);

			for (__int32 i = old_size; i < new_size; i++)
			{
				Buckets64.push_back(GSCUStrBucketEntry_64());
				Buckets64.back().head.next_free = i + 1;
			}

			Buckets64.back().head.next_free = -1;
			Buckets64.at(0).head.next_free = old_size;
		}
		break;
		case GSCUSB_256:
		{
			auto old_size = (__int32)Buckets256.size();
			auto new_size = old_size + 1024;
			Buckets256.reserve(new_size);

			for (__int32 i = old_size; i < new_size; i++)
			{
				Buckets256.push_back(GSCUStrBucketEntry_256());
				Buckets256.back().head.next_free = i + 1;
			}

			Buckets256.back().head.next_free = -1;
			Buckets256.at(0).head.next_free = old_size;
		}
		break;
		default:
			return -1; // cant expand an invalid bucket
		}

		return 0;
	}

	/// <summary>
	/// Allocate a new string of minimum reserve size and add a reference to it (auto-pin)
	/// </summary>
	/// <param name="reserve_size"></param>
	/// <returns></returns>
	__int32 alloc(unsigned __int32 reserve_size, GSCUString& str_out)
	{
		if (reserve_size < 32)
		{
			auto header = &Buckets32.at(0);

			if (header->head.next_free < 0)
			{
				auto result = bucket_expand(GSCUSB_32);
				if (result)
				{
					return result;
				}
			}

			auto entry = &Buckets32.at(header->head.next_free);
			auto index = header->head.next_free;
			header->head.next_free = entry->head.next_free; // update the bucket to know where the next entry is

			entry->head.next_free = -1;
			entry->head.in_use = true;
			entry->head.ref_count = 1;
			entry->head.max_size = 31;
			entry->head.current_size = 0;
			
			BucketLookupTable[entry->str] = GSCUStringBucketRef();
			BucketLookupTable[entry->str].entry = entry;
			BucketLookupTable[entry->str].type = GSCUSB_32;
			BucketLookupTable[entry->str].index = index;

			str_out.bucket = GSCUSB_32;
			str_out.max_size = entry->head.max_size;
			str_out.size = 0;
			str_out.str_ref = entry->str;

			return 0;
		}

		if (reserve_size < 64)
		{
			auto header = &Buckets64.at(0);

			if (header->head.next_free < 0)
			{
				auto result = bucket_expand(GSCUSB_64);
				if (result)
				{
					return result;
				}
			}

			auto entry = &Buckets64.at(header->head.next_free);
			auto index = header->head.next_free;
			header->head.next_free = entry->head.next_free; // update the bucket to know where the next entry is

			entry->head.next_free = -1;
			entry->head.in_use = true;
			entry->head.ref_count = 1;
			entry->head.max_size = 63;
			entry->head.current_size = 0;

			BucketLookupTable[entry->str] = GSCUStringBucketRef();
			BucketLookupTable[entry->str].entry = entry;
			BucketLookupTable[entry->str].type = GSCUSB_64;
			BucketLookupTable[entry->str].index = index;

			str_out.bucket = GSCUSB_64;
			str_out.max_size = entry->head.max_size;
			str_out.size = 0;
			str_out.str_ref = entry->str;

			return 0;
		}

		if (reserve_size < 256)
		{
			auto header = &Buckets256.at(0);

			if (header->head.next_free < 0)
			{
				auto result = bucket_expand(GSCUSB_256);
				if (result)
				{
					return result;
				}
			}

			auto entry = &Buckets256.at(header->head.next_free);
			auto index = header->head.next_free;
			header->head.next_free = entry->head.next_free; // update the bucket to know where the next entry is

			entry->head.next_free = -1;
			entry->head.in_use = true;
			entry->head.ref_count = 1;
			entry->head.max_size = 255;
			entry->head.current_size = 0;

			BucketLookupTable[entry->str] = GSCUStringBucketRef();
			BucketLookupTable[entry->str].entry = entry;
			BucketLookupTable[entry->str].type = GSCUSB_256;
			BucketLookupTable[entry->str].index = index;

			str_out.bucket = GSCUSB_256;
			str_out.max_size = entry->head.max_size;
			str_out.size = 0;
			str_out.str_ref = entry->str;

			return 0;
		}

		// Custom bucket size. Note that this cannot exceed 65535 and if it does we will clamp it.
		// It is the responsibility of the writer to respect the max size. We do not return non-zero unless something happens in our actual memory allocators (ie: malloc returns 0).

		// this if statement catches potential overflows if somehow we got passed uint_max
		if (reserve_size > 100000)
		{
			reserve_size = 65535;
		}

		// note: we will always give a bit more space than asked for to try to minimize reallocations. strings of this size are special case and are most likely going to get appended to multiple times after this.
		reserve_size += 1024;

		if (reserve_size > 65535)
		{
			reserve_size = 65535;
		}

		char* entry_str = (char*)malloc(reserve_size + 1);

		if (!entry_str)
		{
			return -1;
		}

		BucketsCustom[entry_str] = GSCUStrBucketEntry_CUSTOM();
		auto entry = &BucketsCustom[entry_str];
		entry->head.in_use = true;
		entry->head.next_free = -1;
		entry->head.in_use = true;
		entry->head.ref_count = 1;
		entry->head.max_size = reserve_size;
		entry->head.current_size = 0;
		entry->str = entry_str;
	
		memset(entry->str, 0, reserve_size + 1);

		BucketLookupTable[entry->str] = GSCUStringBucketRef();
		BucketLookupTable[entry->str].entry = entry;
		BucketLookupTable[entry->str].type = GSCUSB_CUSTOM;

		str_out.bucket = GSCUSB_CUSTOM;
		str_out.max_size = entry->head.max_size;
		str_out.size = 0;
		str_out.str_ref = entry->str;

		return 0;
	}

	void update_size(GSCUString* entry)
	{
		// note: if this overflows the caller is in bad shape. It may be beneficial to catch this here but this is not really the place to verify this type of behavior.
		auto len = (unsigned __int16)strlen(entry->str_ref);
		entry->size = len;

		if (entry->size > entry->max_size)
		{
			entry->size = entry->max_size;
		}

		if (entry->bucket == GSCUSB_NONE)
		{
			return;
		}

		if (BucketLookupTable.find(entry->str_ref) == BucketLookupTable.end())
		{
			return;
		}

		// yes, we are assuming all buckets cast the same because the head is the first entry and the offsets will be identical
		((GSCUStrBucketEntryHead*)BucketLookupTable[entry->str_ref].entry)->current_size = entry->size;
	}

	void add_ref(GSCUString* entry)
	{
		if (entry->bucket == GSCUSB_NONE)
		{
			return;
		}

		if (BucketLookupTable.find(entry->str_ref) == BucketLookupTable.end())
		{
			return;
		}

		// yes, we are assuming all buckets cast the same because the head is the first entry and the offsets will be identical
		((GSCUStrBucketEntryHead*)BucketLookupTable[entry->str_ref].entry)->ref_count++;
	}

	void remove_ref(GSCUString* entry)
	{
		if (entry->bucket == GSCUSB_NONE)
		{
			return;
		}

		if (BucketLookupTable.find(entry->str_ref) == BucketLookupTable.end())
		{
			return;
		}

		auto head = (GSCUStrBucketEntryHead*)BucketLookupTable[entry->str_ref].entry;
		if (head->ref_count <= 0)
		{
			// already disposed?
			return;
		}

		head->ref_count--;
		if (head->ref_count <= 0)
		{
			head->in_use = false;
			head->current_size = 0;
			
			switch (BucketLookupTable[entry->str_ref].type)
			{
				case GSCUSB_32:
					head->next_free = Buckets32.at(0).head.next_free;
					Buckets32.at(0).head.next_free = BucketLookupTable[entry->str_ref].index;
					BucketLookupTable.erase(entry->str_ref);
					break;
				case GSCUSB_64:
					head->next_free = Buckets64.at(0).head.next_free;
					Buckets64.at(0).head.next_free = BucketLookupTable[entry->str_ref].index;
					BucketLookupTable.erase(entry->str_ref);
					break;
				case GSCUSB_256:
					head->next_free = Buckets256.at(0).head.next_free;
					Buckets256.at(0).head.next_free = BucketLookupTable[entry->str_ref].index;
					BucketLookupTable.erase(entry->str_ref);
					break;
				case GSCUSB_CUSTOM:
					BucketLookupTable.erase(entry->str_ref);
					free(entry->str_ref);
					BucketsCustom.erase(entry->str_ref);
					break;
			}
		}
	}
};

// this matches xmm size but we cant use xmm speed because our structs are not aligned like they should be.
// this may change in the future with optimization. the tradeoff is requiring an extra 0x8 bytes per variable to exist. it probably isnt worth it.
struct GSCUVector
{
	float x;
	float y;
	float z;
	float w;
};

struct GSCUDoubleInt64
{
	__int64 a;
	__int64 b;
};

//union GSCUFieldKeyValue
//{
//	char* StringKey;
//	unsigned __int64 HashKey;
//	unsigned __int32 CanonKey;
//	unsigned __int32 NumberKey;
//};
//
//enum GSCUFieldKeyType
//{
//	GSCUFKT_NUMBER = 0,
//	GSCUFKT_CANON = 1,
//	GSCUFKT_HASH = 2,
//	GSCUFKT_STRING = 3
//};

//struct GSCUFieldElement
//{
//private:
//	GSCUFieldKeyValue key;
//	unsigned __int32 var_ref;
//	unsigned __int32 next_key; // if !next_key, no next key. (note this is guaranteed because vm is id 0 so next_key cant ever be 0)
//
//public:
//	GSCUFieldKeyType key_type()
//	{
//		return (GSCUFieldKeyType)(var_ref >> 31 | ((next_key >> 31) << 1));
//	}
//
//	void set_key_type(GSCUFieldKeyType type)
//	{
//		var_ref = ((var_ref << 1) >> 1) | (type << 31);
//		next_key = ((next_key << 1) >> 1) | ((type >> 1) << 31);
//	}
//
//	void set_var_ref(unsigned __int32 var)
//	{
//		var_ref = ((var << 1) >> 1) | (var_ref & (1 << 31));
//	}
//
//	unsigned __int32 get_var_ref()
//	{
//		return var_ref & ~(1 << 31);
//	}
//
//	unsigned __int32 get_next_key()
//	{
//		return next_key & ~(1 << 31);
//	}
//
//	GSCUFieldKeyValue get_key()
//	{
//		return key;
//	}
//
//	unsigned __int32 get_key32()
//	{
//		switch (key_type())
//		{
//			case GSCUFKT_STRING:
//				return GSCUHashing::canon_hash(key.StringKey);
//
//			case GSCUFKT_HASH:
//				return key.CanonKey ^ (unsigned __int32)(key.HashKey >> 32);
//
//			default:
//				return key.CanonKey;
//		}
//	}
//
//	unsigned __int64 get_key64()
//	{
//		switch (key_type())
//		{
//			case GSCUFKT_STRING:
//				return GSCUHashing::canon_hash64(key.StringKey);
//
//			case GSCUFKT_HASH:
//				return key.HashKey;
//
//			default:
//				return key.CanonKey;
//		}
//	}
//
//	void set_key(GSCUFieldKeyType type, GSCUFieldKeyValue value)
//	{
//		set_key_type(type);
//		key = value;
//	}
//
//	void set_next_key(unsigned __int32 next)
//	{
//		next_key = ((next << 1) >> 1) | (next_key & (1 << 31));
//	}
//
//	bool matches(GSCUFieldKeyType type, GSCUFieldKeyValue value)
//	{
//		switch (type)
//		{
//			case GSCUFKT_NUMBER:
//				return value.NumberKey == key.NumberKey;
//			case GSCUFKT_CANON:
//				return value.CanonKey == key.CanonKey;
//			case GSCUFKT_HASH:
//				return value.HashKey == key.HashKey;
//			case GSCUFKT_STRING:
//				return strcmp(key.StringKey, value.StringKey) == 0;
//		}
//		return false;
//	}
//};

struct GSCUSafeContextMarker
{
	/// <summary>
	/// Base instruction pointer to use to offset the start, end, and handler
	/// </summary>
	unsigned __int64 base;

	__int16 handler;
	unsigned __int16 prev_safe_context;
	__int16 reserved[2];
};

// std::vector<unsigned __int32>::iterator*

struct GSCUIterator
{
	std::vector<unsigned __int32>* keys;
	unsigned __int32 var_id;
	unsigned __int32 index;
};

union GSCUVarValue // size 0x10
{
	unsigned __int8 int8;
	unsigned __int16 int16;
	__int32 int32;
	unsigned __int64 int64;
	float f;
	void* pointer;
	GSCUStackFrame frame;
	GSUStructInfo s;
	unsigned __int8 buff[0x10];
	float af[0x4];
	__int32 ai32[0x4];
	GSCUVector vec;
	GSCUEndonMarker endon;
	GSCUWaittillMarker waittill;
	GSCUFunctionPointer fn;
	GSCUString str;
	GSCUDoubleInt64 di64;
	GSCUIterator it;
	GSCUSafeContextMarker seh;
};

struct GSCUHeapVariable // size 0x28
{
	// variable type
	GSCUVariableType type;

	// variable unique identifier.
	unsigned __int32 id;

	// variable parent id
	unsigned __int32 parent;

	// variable cannonical hash name
	unsigned __int32 name;

	// value of variable
	GSCUVarValue value; // size 0x10

	// number of references to the variable in the vm environment
	unsigned __int32 refcount;
	unsigned __int32 reserved;
};

struct GSCUStackVariable // size 0x18
{
	// value of variable
	GSCUVarValue value;

	// variable type
	GSCUVariableType type;
	unsigned __int32 reserved;

	GSCUStackVariable()
	{
		type = GSCUVAR_UNDEFINED;
		value.di64.a = 0;
		value.di64.b = 0;
		reserved = 0;
	}
};

struct GSCUThreadContext
{
	unsigned __int64 fs_pos;
	unsigned __int32 id;
	unsigned __int32 flags;

	unsigned __int16 safe_context; // stack index of the current safe context pointer
	unsigned __int16 start_locals;
	unsigned __int8 num_params;
	unsigned __int8 marked_for_death;
	unsigned __int8 va_index; // relative index from the start of the locals to the variadic argument array
	unsigned __int8 reserved;

	unsigned __int32 exit_code;
	unsigned __int32 reserved1;


	std::vector<std::function<void(void*)>> terminate_events;
	std::vector<GSCUStackVariable> stack;

	void set_flag(GSCUThreadFlags flag)
	{
		flags |= flag;
	}

	void clear_flag(GSCUThreadFlags flag)
	{
		flags &= ~flag;
	}

	bool has_flag(GSCUThreadFlags flag)
	{
		return flags & flag;
	}

	GSCUThreadContext()
	{
		fs_pos = 0;
		id = 0;
		flags = 0;
		start_locals = 0;
		num_params = 0;
		safe_context = 0;
		marked_for_death = 0;
		va_index = 0;
		reserved = 0;
		exit_code = 0;
		reserved1 = 0;
	}
};

struct GSCUFieldAccessorDef
{
	GSCUFunctionPointer get;
	GSCUFunctionPointer set;
};

struct GSCUClassCallDef
{
	GSCUFunctionPointer invoke;
	unsigned __int32 reserved[4];
};

union GSCUClassMemberValue
{
	GSCUClassCallDef call;
	GSCUFieldAccessorDef field;
};

enum GSCUClassMemberType
{
	GSCUCMT_Field,
	GSCUCMT_Call
};

struct GSCUClassMember
{
	GSCUClassMemberValue m;
	GSCUClassMemberType type;
};

class scr_const
{
public:
	static const __int32 array;
	static const __int32 vm;
	static const __int32 level;
	static const __int32 global;
	static const __int32 globals;
	static const __int32 event;
	static const __int32 object;
	static const __int32 size;
	static const __int32 x;
	static const __int32 y;
	static const __int32 z;
	static const __int32 w;
	static const __int32 error_code;
	static const __int32 error_message;
	static const __int32 classname;
	static const __int32 ctor;
	static const __int32 dtor;
	static const __int32 ctorauto;
	static const __int32 dtorauto;
	static const __int32 add;
};

class scr_notifies
{
public:
	static const unsigned __int64 death;
};

#define TYPECOMBINE(typex, typey) ((typex << 8) | typey)
#define TYPECOMBINECASE(typex, typey) case TYPECOMBINE(typex, typey): case TYPECOMBINE(typey, typex):

namespace GSCUVars
{
	bool can_add(GSCUVariableType tx, GSCUVariableType ty);
	bool can_subtract(GSCUVariableType tx, GSCUVariableType ty);
	bool can_multiply(GSCUVariableType tx, GSCUVariableType ty);
	bool can_divide(GSCUVariableType tx, GSCUVariableType ty);
	float vector_length(GSCUVector& vec);
}