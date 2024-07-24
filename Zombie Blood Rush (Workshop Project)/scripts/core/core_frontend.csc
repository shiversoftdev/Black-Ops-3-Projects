#using scripts\codescripts\struct;
#using scripts\shared\util_shared;
#using scripts\mp\_load;
#using scripts\mp\_util;
#using scripts\core\core_frontend_fx;
#using scripts\core\core_frontend_sound;

#insert scripts\shared\shared.gsh;

function main()
{
	core_frontend_fx::main();
	core_frontend_sound::main();
	
	load::main();

	util::waitforclient( 0 );	// This needs to be called after all systems have been registered.
}
