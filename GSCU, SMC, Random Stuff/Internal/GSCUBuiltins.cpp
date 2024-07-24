#include "GSCUBuiltins.h"
#include "GSCUVars.h"
#include "gscu_api.h"

const __int32 scr_builtin_const::con = CONST32("con");
const __int32 scr_builtin_const::println = CONST32("println");

void GSCUBuiltins::register_default_builtins(GContext* context)
{
	// TODO: vector cross2, cross3, cross4, dot2, dot3, dot4
	
	// TODO: convert to api registration
	context->register_builtin_function(scr_builtin_const::println, scr_builtin_const::con, 0, 1, 0, GSCUBuiltins::con::println);

	// setup array class
	GContext::api_register_class(context, scr_const::array, NULL, NULL);
	GContext::api_register_class_method(context, scr_const::array, scr_const::add, GSCUBuiltins::arr::add);
	// array->append(va...)
	// array->pop()
	// array->insert(index) ?
	// array->remove(index) ? 
	// array->clear()
	// array->remove_undefined()
	// array->clone()
	// array->contains(value)
	// array->filter(fn_predicate) -> new array()
	// array->thread_all(fn_predicate, va...)
	// array->run_all(fn_predicate, va...)
}

__int32 GSCUBuiltins::con::println(GSCUCallContext& ctx)
{
	if (GContext::api_get_num_params((GContext*)ctx.vmc, ctx.thread) < 1)
	{
		printf("\n");
		return GSCU_SUCCESS;
	}

	const char* output_value = NULL;
	auto result = GContext::api_get_string((GContext*)ctx.vmc, ctx.thread, 0, output_value);

	if (!output_value)
	{
		printf("undefined\n");
	}
	else
	{
		printf("%s\n", output_value);
	}
	
	return result;
}

__int32 GSCUBuiltins::arr::add(GSCUCallContext& ctx)
{
	if (GContext::api_get_num_params((GContext*)ctx.vmc, ctx.thread) != 1)
	{
		return GContext::api_report_error((GContext*)ctx.vmc, GSCU_ERROR_API_INVALID_ARGS, "");
	}

	return GContext::api_add_array_element((GContext*)ctx.vmc, ctx.thread, ctx.self);
}
