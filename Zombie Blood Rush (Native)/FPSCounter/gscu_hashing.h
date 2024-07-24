#pragma once
namespace GSCUHashing
{
	unsigned __int32 canon_hash(const char* input);
	unsigned __int64 canon_hash64(const char* input);
}

constexpr char char_to_lower(const char c)
{
	return (c >= 'A' && c <= 'Z') ? c + ('a' - 'A') : c;
}

constexpr unsigned __int32 const_canon_hash(const char* input)
{
	unsigned __int32 hash = 0x4B9ACE2F;
	const char* _input = input;
	while (*_input)
	{
		char c = char_to_lower(*_input);
		hash = ((c + hash) ^ ((c + hash) << 10)) + (((c + hash) ^ ((c + hash) << 10)) >> 6);
		_input++;
	}
	return 0x8001 * ((9 * hash) ^ ((9 * hash) >> 11));
}

constexpr unsigned __int64 const_notify_hash(const char* input)
{
	unsigned __int64 hash = 14695981039346656037ULL;
	const char* _input = input;
	while (*_input)
	{
		hash = (hash ^ char_to_lower(*_input)) * 1099511628211ULL;
		_input++;
	}
	return 0x7FFFFFFFFFFFFFFF & hash;
}

template <unsigned __int32 NUM>
struct canon_const
{
	static const unsigned __int32 value = NUM;
};

template <unsigned __int64 NUM>
struct notify_const
{
	static const unsigned __int64 value = NUM;
};

#define CONST32(x) canon_const<const_canon_hash(x)>::value
#define CONST64(x) notify_const<const_notify_hash(x)>::value