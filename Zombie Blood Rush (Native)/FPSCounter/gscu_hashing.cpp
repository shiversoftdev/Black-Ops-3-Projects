#include "gscu_hashing.h"
#include <ctype.h>

unsigned __int32 GSCUHashing::canon_hash(const char* input)
{
	unsigned __int32 hash = 0x4B9ACE2F;
	const char* _input = input;
	while (*_input)
	{
		char c = tolower(*_input);
		hash = ((c + hash) ^ ((c + hash) << 10)) + (((c + hash) ^ ((c + hash) << 10)) >> 6);
		_input++;
	}
	return 0x8001 * ((9 * hash) ^ ((9 * hash) >> 11));
}

unsigned __int64 GSCUHashing::canon_hash64(const char* input)
{
	static const unsigned __int64 offset = 14695981039346656037ULL;
	static const unsigned __int64 prime = 1099511628211ULL;

	unsigned __int64 hash = offset;
	const char* _input = input;

	while (*_input)
	{
		hash = (hash ^ tolower(*_input)) * prime;
		_input++;
	}

	return 0x7FFFFFFFFFFFFFFF & hash;
}