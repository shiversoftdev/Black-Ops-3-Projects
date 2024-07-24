#using scripts\codescripts\struct;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\callbacks_shared;
#using scripts\zm\_zm_utility;

#precache("material", "damage_feedback_protected");

#precache("string", "ZMUI_ZBR_PLAYER_KILLED");
#precache("string", "ZMUI_ZBR_PLAYER_DOWNED");
#precache("string", "ZMUI_ZBR_PLAYER_MARKED");
#precache("string", "ZMUI_ZBR_OBJECTIVE_COMPLETE");
#precache("lui_menu_data", "presence.current");

#precache("lui_menu_data", "ZBRAttacker.kills");
#precache("lui_menu_data", "ZBRVictim.kills");

#precache("lui_menu_data", "ZBR_Score.p0.progress_percent");
#precache("lui_menu_data", "ZBR_Score.p0.respawn_timer");
#precache("lui_menu_data", "ZBR_Score.p0.objective_progress");
#precache("lui_menu_data", "ZBR_Score.p0.visible");

#precache("lui_menu_data", "ZBR_Score.p1.progress_percent");
#precache("lui_menu_data", "ZBR_Score.p1.respawn_timer");
#precache("lui_menu_data", "ZBR_Score.p1.objective_progress");
#precache("lui_menu_data", "ZBR_Score.p1.visible");

#precache("lui_menu_data", "ZBR_Score.p2.progress_percent");
#precache("lui_menu_data", "ZBR_Score.p2.respawn_timer");
#precache("lui_menu_data", "ZBR_Score.p2.objective_progress");
#precache("lui_menu_data", "ZBR_Score.p2.visible");

#precache("lui_menu_data", "ZBR_Score.p3.progress_percent");
#precache("lui_menu_data", "ZBR_Score.p3.respawn_timer");
#precache("lui_menu_data", "ZBR_Score.p3.objective_progress");
#precache("lui_menu_data", "ZBR_Score.p3.visible");

#precache("lui_menu_data", "ZBR_Score.p4.progress_percent");
#precache("lui_menu_data", "ZBR_Score.p4.respawn_timer");
#precache("lui_menu_data", "ZBR_Score.p4.objective_progress");
#precache("lui_menu_data", "ZBR_Score.p4.visible");

#precache("lui_menu_data", "ZBR_Score.p5.progress_percent");
#precache("lui_menu_data", "ZBR_Score.p5.respawn_timer");
#precache("lui_menu_data", "ZBR_Score.p5.objective_progress");
#precache("lui_menu_data", "ZBR_Score.p5.visible");

#precache("lui_menu_data", "ZBR_Score.p6.progress_percent");
#precache("lui_menu_data", "ZBR_Score.p6.respawn_timer");
#precache("lui_menu_data", "ZBR_Score.p6.objective_progress");
#precache("lui_menu_data", "ZBR_Score.p6.visible");

#precache("lui_menu_data", "ZBR_Score.p7.progress_percent");
#precache("lui_menu_data", "ZBR_Score.p7.respawn_timer");
#precache("lui_menu_data", "ZBR_Score.p7.objective_progress");
#precache("lui_menu_data", "ZBR_Score.p7.visible");

#precache("lui_menu_data", "bgb_usage_0");
#precache("lui_menu_data", "bgb_usage_1");
#precache("lui_menu_data", "bgb_usage_2");
#precache("lui_menu_data", "bgb_usage_3");
#precache("lui_menu_data", "bgb_usage_4");

#precache( "fx", "electric/fx_elec_sparks_burst_xsm_omni_blue_os" );

#namespace zm_ffotd;

function main_start() {}

function main_end()
{
	difficulty = 1;
	column = int(difficulty) + 1;
	zombie_utility::set_zombie_var("zombie_move_speed_multiplier", 4, 0, column);
}

function optimize_for_splitscreen()
{
	if(getdvarint("splitscreen_playerCount") >= 3)
	{
		return true;
	}
	return false;
}
