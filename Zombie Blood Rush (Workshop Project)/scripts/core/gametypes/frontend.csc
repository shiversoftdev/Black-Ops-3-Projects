// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\core\_multi_extracam;
#using scripts\shared\_character_customization;
#using scripts\shared\_weapon_customization_icon;
#using scripts\shared\ai\archetype_damage_effects;
#using scripts\shared\ai\systems\destructible_character;
#using scripts\shared\ai\zombie;
#using scripts\shared\animation_shared;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\custom_class;
#using scripts\shared\end_game_taunts;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\music_shared;
#using scripts\shared\player_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#namespace frontend;

function main()
{
	level.mpvignettepostfxactive = 0;
	if(!isdefined(level.str_current_safehouse))
	{
		level.str_current_safehouse = "mobile";
	}
	level.orbis = getdvarstring("orbisGame") == "true";
	level.durango = getdvarstring("durangoGame") == "true";
	clientfield::register("world", "first_time_flow", 1, getminbitcountfornum(1), "int", &first_time_flow, 0, 1);
	clientfield::register("world", "cp_bunk_anim_type", 1, getminbitcountfornum(1), "int", &cp_bunk_anim_type, 0, 1);
	level.cameras_active = 0;
	clientfield::register("actor", "zombie_has_eyes", 1, 1, "int", &zombie_eyes_clientfield_cb, 0, 1);
	clientfield::register("scriptmover", "dni_eyes", 1000, 1, "int", &dni_eyes, 0, 0);
	level._effect["eye_glow"] = "zombie/fx_glow_eye_orange_frontend";
	level._effect["bgb_machine_available"] = "zombie/fx_bgb_machine_available_zmb";
	level._effect["doa_frontend_cigar_lit"] = "fire/fx_cigar_getting_lit";
	level._effect["doa_frontend_cigar_puff"] = "fire/fx_cigar_getting_lit_puff";
	level._effect["doa_frontend_cigar_ash"] = "fire/fx_cigar_ash_emit";
	level._effect["doa_frontend_cigar_ambient"] = "fire/fx_cigar_lit_ambient";
	level._effect["doa_frontend_cigar_exhale"] = "smoke/fx_smk_cigar_exhale";
	level._effect["frontend_special_day"] = "zombie/fx_val_motes_100x100";
	setstreamerrequest(1, "core_frontend");
}

/*
	Name: first_time_flow
	Namespace: frontend
	Checksum: 0x19F30812
	Offset: 0x2508
	Size: 0x3C
	Parameters: 7
	Flags: Linked
*/
function first_time_flow(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
}

/*
	Name: cp_bunk_anim_type
	Namespace: frontend
	Checksum: 0x6B523BB5
	Offset: 0x2550
	Size: 0x3C
	Parameters: 7
	Flags: Linked
*/
function cp_bunk_anim_type(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
}

/*
	Name: setupclientmenus
	Namespace: frontend
	Checksum: 0x22A39EE
	Offset: 0x2598
	Size: 0x127C
	Parameters: 1
	Flags: Linked
*/
function setupclientmenus(localclientnum)
{
}

/*
	Name: zombie_eyes_clientfield_cb
	Namespace: frontend
	Checksum: 0x24C5041A
	Offset: 0x3820
	Size: 0x154
	Parameters: 7
	Flags: Linked
*/
function zombie_eyes_clientfield_cb(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	
}

/*
	Name: get_eyeball_on_luminance
	Namespace: frontend
	Checksum: 0x2BC97A79
	Offset: 0x3980
	Size: 0x1C
	Parameters: 0
	Flags: Linked
*/
function get_eyeball_on_luminance()
{
	if(isdefined(level.eyeball_on_luminance_override))
	{
		return level.eyeball_on_luminance_override;
	}
	return 1;
}

/*
	Name: get_eyeball_off_luminance
	Namespace: frontend
	Checksum: 0x40E8B53
	Offset: 0x39A8
	Size: 0x1A
	Parameters: 0
	Flags: Linked
*/
function get_eyeball_off_luminance()
{
	if(isdefined(level.eyeball_off_luminance_override))
	{
		return level.eyeball_off_luminance_override;
	}
	return 0;
}

/*
	Name: get_eyeball_color
	Namespace: frontend
	Checksum: 0xD46C8CE0
	Offset: 0x39D0
	Size: 0x48
	Parameters: 0
	Flags: Linked
*/
function get_eyeball_color()
{
	val = 0;
	if(isdefined(level.zombie_eyeball_color_override))
	{
		val = level.zombie_eyeball_color_override;
	}
	if(isdefined(self.zombie_eyeball_color_override))
	{
		val = self.zombie_eyeball_color_override;
	}
	return val;
}

/*
	Name: createzombieeyes
	Namespace: frontend
	Checksum: 0x9B2D9986
	Offset: 0x3A20
	Size: 0x24
	Parameters: 1
	Flags: Linked
*/
function createzombieeyes(localclientnum)
{
	
}

/*
	Name: deletezombieeyes
	Namespace: frontend
	Checksum: 0x94B0992B
	Offset: 0x3A50
	Size: 0x60
	Parameters: 1
	Flags: Linked
*/
function deletezombieeyes(localclientnum)
{
	
}

/*
	Name: createzombieeyesinternal
	Namespace: frontend
	Checksum: 0x2CC84229
	Offset: 0x3AB8
	Size: 0x102
	Parameters: 1
	Flags: Linked
*/
function createzombieeyesinternal(localclientnum)
{
	
}

/*
	Name: dni_eyes
	Namespace: frontend
	Checksum: 0x42851BED
	Offset: 0x3BC8
	Size: 0x7C
	Parameters: 7
	Flags: Linked
*/
function dni_eyes(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
	
}

/*
	Name: blackscreen_watcher
	Namespace: frontend
	Checksum: 0xEDF1D3D6
	Offset: 0x3C50
	Size: 0x140
	Parameters: 0
	Flags: Linked
*/
function blackscreen_watcher()
{
	
}

/*
	Name: streamer_change
	Namespace: frontend
	Checksum: 0x72781E51
	Offset: 0x3D98
	Size: 0x5E
	Parameters: 2
	Flags: Linked
*/
function streamer_change(hint, data_struct)
{
	
}

/*
	Name: plaympherovignettecam
	Namespace: frontend
	Checksum: 0x8E560517
	Offset: 0x3E00
	Size: 0x124
	Parameters: 3
	Flags: Linked
*/
function plaympherovignettecam(localclientnum, data_struct, changed)
{
	
}

/*
	Name: handle_inspect_player
	Namespace: frontend
	Checksum: 0x1F5F2BDD
	Offset: 0x3F30
	Size: 0x78
	Parameters: 1
	Flags: Linked
*/
function handle_inspect_player(localclientnum)
{
	
}

/*
	Name: update_inspection_character
	Namespace: frontend
	Checksum: 0x3BC5A391
	Offset: 0x3FB0
	Size: 0x4D4
	Parameters: 2
	Flags: Linked
*/
function update_inspection_character(localclientnum, xuid)
{
}

/*
	Name: entityspawned
	Namespace: frontend
	Checksum: 0xB3EADC6B
	Offset: 0x4490
	Size: 0xC
	Parameters: 1
	Flags: Linked
*/
function entityspawned(localclientnum)
{
}

/*
	Name: localclientconnect
	Namespace: frontend
	Checksum: 0xD891A47A
	Offset: 0x44A8
	Size: 0x2C8
	Parameters: 1
	Flags: Linked
*/
function localclientconnect(localclientnum)
{
	
}

/*
	Name: onprecachegametype
	Namespace: frontend
	Checksum: 0x99EC1590
	Offset: 0x4778
	Size: 0x4
	Parameters: 0
	Flags: None
*/
function onprecachegametype()
{
}

/*
	Name: onstartgametype
	Namespace: frontend
	Checksum: 0x99EC1590
	Offset: 0x4788
	Size: 0x4
	Parameters: 0
	Flags: None
*/
function onstartgametype()
{
}

/*
	Name: open_choose_class
	Namespace: frontend
	Checksum: 0x2D0BC83D
	Offset: 0x4798
	Size: 0x4C
	Parameters: 2
	Flags: Linked
*/
function open_choose_class(localclientnum, menu_data)
{
	
}

/*
	Name: close_choose_class
	Namespace: frontend
	Checksum: 0x808CAFE9
	Offset: 0x47F0
	Size: 0x58
	Parameters: 2
	Flags: Linked
*/
function close_choose_class(localclientnum, menu_data)
{
	
}

/*
	Name: open_zm_buildkits
	Namespace: frontend
	Checksum: 0xFDBFF992
	Offset: 0x4850
	Size: 0x34
	Parameters: 2
	Flags: Linked
*/
function open_zm_buildkits(localclientnum, menu_data)
{
	
}

/*
	Name: close_zm_buildkits
	Namespace: frontend
	Checksum: 0xC4F33B46
	Offset: 0x4890
	Size: 0x34
	Parameters: 2
	Flags: Linked
*/
function close_zm_buildkits(localclientnum, menu_data)
{
	
}

/*
	Name: open_zm_bgb
	Namespace: frontend
	Checksum: 0xD5C9B0CD
	Offset: 0x48D0
	Size: 0xBC
	Parameters: 2
	Flags: Linked
*/
function open_zm_bgb(localclientnum, menu_data)
{
	
}