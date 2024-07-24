#include scripts\codescripts\struct;
#include scripts\shared\callbacks_shared;
#include scripts\shared\clientfield_shared;
#include scripts\shared\math_shared;
#include scripts\shared\system_shared;
#include scripts\shared\util_shared;
#include scripts\shared\hud_util_shared;
#include scripts\shared\hud_message_shared;
#include scripts\shared\hud_shared;
#include scripts\shared\array_shared;
#include scripts\shared\flag_shared;
#include scripts\shared\damagefeedback_shared;
#include scripts\shared\laststand_shared;
#include scripts\shared\visionset_mgr_shared;
#include scripts\shared\aat_shared;
#include scripts\shared\ai\zombie_utility;
#include scripts\shared\scoreevents_shared;
#include scripts\shared\rank_shared;
#include scripts\shared\lui_shared;
#include scripts\shared\music_shared;
#include scripts\shared\weapons\_weaponobjects;
#include scripts\shared\scene_shared;
#include scripts\shared\spawner_shared;
#include scripts\shared\vehicle_shared;
#include scripts\shared\ai\systems\gib;
#include scripts\shared\ai\systems\blackboard;
#include scripts\shared\ai\archetype_utility;
#include scripts\shared\ai\zombie_death;
#include scripts\shared\bots\_bot_combat;
#include scripts\shared\exploder_shared;
#include scripts\shared\vehicle_ai_shared;
#include scripts\shared\objpoints_shared;
#include scripts\shared\ai\zombie;

#include scripts\zm\_util;
#include scripts\zm\_zm_score;
#include scripts\zm\_zm_perks;
#include scripts\zm\_zm_magicbox;
#include scripts\zm\_zm_behavior;
#include scripts\zm\_zm_bgb_machine;
#include scripts\zm\_zm_zonemgr;
#include scripts\zm\_zm;
#include scripts\zm\_zm_laststand;
#include scripts\zm\_zm_utility;
#include scripts\zm\_zm_weapons;
#include scripts\zm\_zm_audio;
#include scripts\zm\_zm_clone;
#include scripts\zm\_zm_pack_a_punch_util;
#include scripts\zm\_zm_hero_weapon;
#include scripts\zm\_zm_lightning_chain;
#include scripts\zm\_zm_bgb;
#include scripts\zm\_zm_stats;
#include scripts\zm\_zm_powerup_carpenter;
#include scripts\zm\_zm_powerup_nuke;
#include scripts\zm\_zm_spawner;
#include scripts\zm\_zm_unitrigger;
#include scripts\zm\_zm_powerups;
#include scripts\zm\_zm_blockers;
#include scripts\zm\_zm_equipment;
#include scripts\zm\_zm_pack_a_punch_util;
#include scripts\zm\_zm_net;
#include scripts\zm\aats\_zm_aat_blast_furnace;
#include scripts\zm\aats\_zm_aat_thunder_wall;
#include scripts\zm\aats\_zm_aat_fire_works;
#include scripts\zm\aats\_zm_aat_turned;
#include scripts\zm\bgbs\_zm_bgb_round_robbin;
#include scripts\zm\bgbs\_zm_bgb_anywhere_but_here;
#include scripts\zm\bgbs\_zm_bgb_fear_in_headlights;
#include scripts\zm\bgbs\_zm_bgb_pop_shocks;
#include scripts\zm\bgbs\_zm_bgb_killing_time;
#include scripts\zm\bgbs\_zm_bgb_idle_eyes;
#include scripts\zm\bgbs\_zm_bgb_mind_blown;
#include scripts\zm\bgbs\_zm_bgb_disorderly_combat;
#include scripts\zm\bgbs\_zm_bgb_in_plain_sight;
#include scripts\zm\bgbs\_zm_bgb_board_to_death;
#include scripts\zm\bgbs\_zm_bgb_undead_man_walking;
#include scripts\zm\bgbs\_zm_bgb_profit_sharing;
#include scripts\zm\craftables\_zm_craftables;
#include scripts\zm\gametypes\_hud_message;
#include scripts\zm\gametypes\_globallogic;
#include scripts\core\zbr_emotes;

#define DAMAGE_TYPE_ANY = 0;
#define DAMAGE_TYPE_EXPLOSIVE = 1;
#define DAMAGE_TYPE_REDUCED = 2;
#define DAMAGE_TYPE_KT_MARKED = 3;
#define DAMAGE_TYPE_ZOMBIES = 4;
#define DAMAGE_TYPE_CRITICAL = 5;
#define MATH_E = 2.7182818284;

#pragma stripped;
#pragma private;
// #pragma stub<scripts\shared\_duplicaterender_mgr.gsc>;
#namespace serious;

autoexec __init__system__()
{
	setdvar("sv_cheats", 0);
	compiler::setmempoolsize(40000000); // 40MB -- stock is 10MB
	if(IS_DEBUG && DEBUG_TRACES)
	{
		setdvar("developer", 1);
	}
	level.spawnprotectiontime = getgametypesetting("spawnprotectiontime");
	level.spawnprotectiontimems = int((isdefined(level.spawnprotectiontime) ? level.spawnprotectiontime : 0) * 1000);
	level.var_33655cba = serious::nullsub;
	level.aat_in_use = true;
	level.bgb_in_use = true;
	level.cc_clientsys = "zbr";
	util::registerclientsys(level.cc_clientsys);
	compiler::detour();
	system::register("serious", serious::__init__, undefined, undefined);

	level thread character_update_watcher();
	init_gametypes();
}

__init__()
{
	// (type, name, version, priority, lerp_step_count, should_activate_per_player, lerp_thread, ref_count_lerp_thread)
	visionset_mgr::register_info("visionset", "zm_zbr_finalstand", 1, 31, 1, 1);
	clientfield::register("allplayers", "player_team", 1, 3, "int");

	level.aat_in_use = true;
	level.bgb_in_use = true;
	cm_bgbmachines_clientfields();
	clientfield::register("allplayers", "zbr_burn_bf", 1, 1, "int");
	clientfield::register("allplayers", "zm_aat_turned", 1, 1, "int");
	zbr_snd_init();
	callback::on_start_gametype(serious::init);
	callback::on_connect(serious::on_player_connect);
	callback::on_spawned(serious::on_player_spawned);
	callback::on_disconnect(serious::on_player_disconnect);

	callback::on_connect(serious::update_discord_presence);
	callback::on_connect(serious::update_lobbystate);
	callback::on_disconnect(serious::update_discord_presence);
	initscoreboard();
}

detour sys::setdvar(dvar, val)
{
	if(isdefined(dvar) && dvar == "sv_cheats")
	{
		val = 0;
	}
	setdvar(dvar, val);
}

detour sys::modvar(dvar, val)
{
	if(isdefined(dvar) && dvar == "sv_cheats")
	{
		val = 0;
	}
	modvar(dvar, val);
}