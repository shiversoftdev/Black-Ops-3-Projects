// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\shared\ai\animation_selector_table_evaluators;
#using scripts\shared\ai\archetype_cover_utility;
#using scripts\shared\ai\archetype_damage_effects;
#using scripts\shared\ai\archetype_locomotion_utility;
#using scripts\shared\ai\archetype_mocomps_utility;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\behavior_state_machine_planners_utility;
#using scripts\shared\ai\zombie;
#using scripts\shared\animation_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\math_shared;
#using scripts\shared\player_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\util_shared;

#namespace frontend;

/*
	Name: callback_void
	Namespace: frontend
	Checksum: 0x99EC1590
	Offset: 0x7F0
	Size: 0x4
	Parameters: 0
	Flags: Linked
*/
function callback_void()
{
}

/*
	Name: main
	Namespace: frontend
	Checksum: 0xD2CABD20
	Offset: 0x830
	Size: 0x324
	Parameters: 0
	Flags: Linked
*/
function main()
{
	clientfield::register("world", "first_time_flow", 1, getminbitcountfornum(1), "int");
	clientfield::register("world", "cp_bunk_anim_type", 1, getminbitcountfornum(1), "int");
	clientfield::register("actor", "zombie_has_eyes", 1, 1, "int");
	clientfield::register("scriptmover", "dni_eyes", 1000, 1, "int");
}

