EnableGlobals()

-- WARNING: I think this gets loaded in the lobbyvm too 

CoD.zbr_build_id = "1.11.0187";
CoD.zbr_is_debug = true;
CoD.zbr_is_dev = true;
CoD.zbr_loaded = false;
CoD.zbr_enable_mp = true;
CoD.zbr_enable_hunted = CoD.zbr_is_debug;
CoD.zbr_enable_doa = CoD.zbr_is_debug;
CoD.ZBR_UPDATE_GOOD = 0;
CoD.ZBR_UPDATE_UPDATE_CHARACTERS = 1;
CoD.ZBR_UPDATE_UPDATE_BUILD = 2;
CoD.zbr_load_failed_reason = ""
-- Engine["IsBoiii"] = true

CoD.zbr_supported_maps = {
	"zm_xmas_rust",
	"zm_daybreak",
	"zm_kyassuruz",
	"zm_cove",
	"zm_mori",
	-- "zm_alcatraz_island",
	"zm_ski_resort",
	"zm_log_kowloon",
	"zm_town",
	"zm_mario64_v2",
	"zm_survival",
	"zm_velka",
	"zm_1",
	"zm_westernz", 
	"zm_leviathan",
	"zm_terminal",
	-- TODO "zm_dust_2",
	"zm_rainy_death",
	"zm_powerstation",
	"zm_coast",
	"zm_town_hd",
	"zm_wildwest",
	"zm_karma",
	"zm_irondragon",
	"zm_der_riese",
	"zm_prison"
}

function MakeGametypeName(gt)
	return Engine.Localize( "ZMUI_GAMETYPE_" .. Engine.ToUpper(gt) )
end

function GetGametypesBaseZM()
	local f4_local1 = {}

	table.insert( f4_local1, {
		category = "standard",
		name = MakeGametypeName("zbr"),
		name_caps = Engine.ToUpper(MakeGametypeName("zbr")),
		description = "Classic Zombie Blood Rush. Hold the point limit for the objective time to win, or survive in sudden death.",
		image = "playlist_zbr",
		gametype = "zbr",
		gtid = 0
	} )

	if CoD.zbr_enable_hunted then
		table.insert( f4_local1, {
			category = "standard",
			name = MakeGametypeName("zhunt"),
			name_caps = Engine.ToUpper(MakeGametypeName("zhunt")),
			description = "A team of hunters must prevent the hunted from completing the map's main quest.",
			image = "playlist_zbr",
			gametype = "zhunt",
			gtid = 1
		} )
	end

	return f4_local1
end

CoD.zbr_gametype_settings = {
	zbr_teamsize = {
		name = "Team Size",
		hintText = {
			"The number of players on a team."
		},
		labels = {
			"Solos",
			"Duos",
			"Trios",
			"Quads"
		},
		values = {
			1,
			2,
			3,
			4
		}
	},
	win_numpoints = {
		name = "Score Limit",
		hintText = {
			"The number of points you need to reach to begin the final countdown."
		},
		labels = {
			"ZMUI_X_POINTS"
		},
		values = {
			5000,
			10000,
			20000,
			25000,
			50000,
			75000,
			100000,
			150000,
			200000,
			300000,
			500000,
			1000000
		}
	},
	sudden_death_mode = {
		name = "Sudden Death",
		hintText = {
			"The mode of Sudden Death enabled for the game."
		},
		labels = {
			"Disabled",
			"Rounds Only",
			"Time Only",
			"Time and Rounds"
		},
		values = {
			0,
			1,
			2,
			3
		}
	},
	sudden_death_rounds = {
		name = "Sudden Death Round",
		hintText = {
			"The round number that Sudden Death will kick in. Note: This number decreases automatically based on the number of players in the game (more players results in a lower number)."
		},
		labels = {
			"ZMUI_X_ROUND"
		},
		values = {
			10,
			11,
			12,
			13,
			14,
			15,
			16,
			17,
			18,
			19,
			20,
			21,
			22,
			23,
			24,
			25,
			26,
			27,
			28,
			29,
			30,
			35,
			40,
			45,
			50,
			100,
			200
		}
	},
	sudden_death_time = {
		name = "Sudden Death Time",
		hintText = {
			"The in game time that Sudden Death will kick in."
		},
		labels = {
			"5 Minutes",
			"10 Minutes",
			"15 Minutes",
			"20 Minutes",
			"30 Minutes",
			"45 Minutes",
			"1 Hour",
			"1h15",
			"1h30",
			"1h45",
			"2 Hours",
			"3 Hours"
		},
		values = {
			6,
			11,
			16,
			21,
			31,
			46,
			61,
			76,
			91,
			106,
			121,
			181
		}
	},
	pvp_damage_scalar = {
		name = "PvP Damage",
		hintText = {
			"A global scalar for player versus player damage."
		},
		labels = {
			"0%",
			"5%",
			"10%",
			"15%",
			"20%",
			"25%",
			"30%",
			"40%",
			"50%",
			"60%",
			"70%",
			"75%",
			"80%",
			"85%",
			"90%",
			"95%",
			"100%",
			"125%",
			"150%",
			"200%",
			"300%",
			"400%",
			"500%",
		},
		values = {
			0.0,
			0.05,
			0.10,
			0.15,
			0.20,
			0.25,
			0.30,
			0.40,
			0.50,
			0.60,
			0.70,
			0.75,
			0.80,
			0.85,
			0.90,
			0.95,
			1.00,
			1.25,
			1.50,
			2.00,
			3.00,
			4.00,
			5.00
		}
	},
	outgoing_pve_damage = {
		name = "PvE Damage",
		hintText = {
			"Changes the amount of damage you do to zombies."
		},
		labels = {
			"0%",
			"1%",
			"5%",
			"10%",
			"15%",
			"20%",
			"25%",
			"30%",
			"40%",
			"50%",
			"60%",
			"70%",
			"75%",
			"80%",
			"85%",
			"90%",
			"95%",
			"100%",
			"125%",
			"150%",
			"200%",
			"300%",
			"400%",
			"500%",
		},
		values = {
			0.0,
			0.01,
			0.05,
			0.10,
			0.15,
			0.20,
			0.25,
			0.30,
			0.40,
			0.50,
			0.60,
			0.70,
			0.75,
			0.80,
			0.85,
			0.90,
			0.95,
			1.00,
			1.25,
			1.50,
			2.00,
			3.00,
			4.00,
			5.00
		}
	},
	incoming_pve_damage = {
		name = "Zombie Damage",
		hintText = {
			"Changes the amount of damage you take from zombies."
		},
		labels = {
			"0%",
			"1%",
			"5%",
			"10%",
			"15%",
			"20%",
			"25%",
			"30%",
			"40%",
			"50%",
			"60%",
			"70%",
			"75%",
			"80%",
			"85%",
			"90%",
			"95%",
			"100%",
			"125%",
			"150%",
			"200%",
			"300%",
			"400%",
			"500%",
		},
		values = {
			0.0,
			0.01,
			0.05,
			0.10,
			0.15,
			0.20,
			0.25,
			0.30,
			0.40,
			0.50,
			0.60,
			0.70,
			0.75,
			0.80,
			0.85,
			0.90,
			0.95,
			1.00,
			1.25,
			1.50,
			2.00,
			3.00,
			4.00,
			5.00
		}
	},
	super_sprinters_enabled = {
		name = "Super Sprinters",
		hintText = {
			"Super sprinters are quick zombies that are faster than you. Warning: disabling them may make the game too easy."
		},
		labels = {
			"Disabled",
			"Enabled"
		},
		values = {
			0,
			1
		}
	},
	no_wager_totems = {
		name = "Wager Totems",
		hintText = {
			"Enable or Disable the wager totems, which allow players to wager a more difficult match for themself."
		},
		labels = {
			"Enabled",
			"Disabled"
		},
		values = {
			0,
			1
		}
	},
	dmg_convt_efficiency = {
		name = "Point Efficiency",
		hintText = {
			"The conversion ratio used when converting player damage to points earned. A higher ratio grants more points when dealing damage to players."
		},
		labels = {
			"0%",
			"10%",
			"20%",
			"30%",
			"40%",
			"50%",
			"60%",
			"70%",
			"80%",
			"90%",
			"100%",
			"125%",
			"150%",
			"200%",
			"300%",
			"400%",
			"500%"
		},
		values = {
			0.0,
			0.10,
			0.20,
			0.30,
			0.40,
			0.50,
			0.60,
			0.70,
			0.80,
			0.90,
			1.00,
			1.25,
			1.50,
			2.00,
			3.00,
			4.00,
			5.00
		}
	},
	objective_win_time = {
		name = "Objective Time",
		hintText = {
			"The amount of time that you must hold the score limit to win the game."
		},
		labels = {
			"5 seconds",
			"30 seconds",
			"45 seconds",
			"1 minute",
			"1m30",
			"2 minutes",
			"2m30",
			"3 minutes",
			"4 minutes",
			"5 minutes"
		},
		values = {
			5,
			30,
			45,
			60,
			90,
			120,
			150,
			180,
			240,
			300
		}
	},
	gm_start_round = {
		name = "Starting Round",
		hintText = {
			"The round number that the game will start on."
		},
		labels = {
			"Round 3",
			"Round 5",
			"Round 10",
			"Round 15",
			"Round 20",
			"Round 25",
			"Round 30",
			"Round 40",
			"Round 50",
			"Round 60",
			"Round 70",
			"Round 80",
			"Round 90",
			"Round 100",
			"Round 150",
			"Round 200"
		},
		values = {
			3,
			5,
			10,
			15,
			20,
			25,
			30,
			40,
			50,
			60,
			70,
			80,
			90,
			100,
			150,
			200
		}
	},
	player_midround_respawn_delay = {
		name = "Respawn Delay",
		hintText = {
			"The time that a player must wait to respawn after dying. This time is cut in half for respawning while a player has the objective, and is decreased when more players are in the game."
		},
		labels = {
			"5 seconds",
			"10 seconds",
			"20 seconds",
			"30 seconds",
			"45 seconds",
			"1 minute",
			"1m30",
			"2 minutes",
			"5 minutes"
		},
		values = {
			5,
			10,
			20,
			30,
			45,
			60,
			90,
			120,
			300
		}
	},
	starting_points_cm = {
		name = "Starting Points",
		hintText = {
			"The number of points that a player will start the game with."
		},
		labels = {
			500,
			1000,
			2500,
			5000,
			7500,
			10000,
			15000,
			20000,
			25000,
			30000,
			40000,
			50000,
			75000,
			100000,
			150000,
			200000,
			300000,
			1000000
		},
		values = {
			500,
			1000,
			2500,
			5000,
			7500,
			10000,
			15000,
			20000,
			25000,
			30000,
			40000,
			50000,
			75000,
			100000,
			150000,
			200000,
			300000,
			1000000
		}
	},
	disable_gums_cm = {
		name = "Gobblegums",
		hintText = {
			"Enable or disable the usage of gobblegums."
		},
		labels = {
			"Enabled",
			"Disabled"
		},
		values = {
			0,
			1
		}
	},
	headshots_only = {
		name = "Headshots Only",
		hintText = {
			"When enabled, only headshot damage can be used to attack enemies."
		},
		labels = {
			"Disabled",
			"Players",
			"Zombies",
			"All"
		},
		values = {
			0,
			1,
			2,
			3
		}
	}
}

CoD.zbr_max_urmegas = 3;
CoD.zbr_max_rmegas = 5;
CoD.zbr_max_megas = 7;
CoD.zbr_max_players = 8;
CoD.zbr_purple = false;
CoD.zbr_purple_shift_r = 0.15;
CoD.zbr_purple_shift_g = 1.4;
CoD.zbr_purple_shift_b = 0.15;

CoD.zbr_workshop_id = '2696008055'
if CoD.zbr_is_dev then 
	CoD.zbr_workshop_id = '2707213241' -- 2929189164 (lex); 2707213241 (dev); 2979165722 z4c
end

local f0_local0 = {
	ReadOnlyTable = function ( f1_arg0 )
		f1_arg0._originalTable = f1_arg0
		return f1_arg0
	end
}
LuaReadOnlyTables = f0_local0:ReadOnlyTable()

zbr_color_r = 0.15
zbr_color_g = 0.55
zbr_color_b = 1

local function closeenough(a, b)
	a = tonumber(a)
	b = tonumber(b)
	if (not a) or (not b) then 
		return false
	end
	return math.abs(a - b) < 0.05
end

-- _setYRot = LUI.UIElement.setYRot
-- LUI.UIElement.setYRot = function(this, rot)

-- 	if Engine.GetCurrentMap() == "core_frontend" then
-- 		_setYRot(this, rot * 2)
-- 		LUI.UIElement.setZRot(this, rot * 2)
-- 		return
-- 	end
-- 	_setYRot(this, rot)
-- end

_setRGB = LUI.UIElement.setRGB
LUI.UIElement.setRGB = function(this, r, g, b)

	local original_r = r
	if r ~= nil and (g == nil or b == nil) then
		return _setRGB(this, original_r)
	end

	r = tonumber(r)
	if not r then return _setRGB(this, r, g, b) end
	g = tonumber(g)
	if not g then return _setRGB(this, r, g, b) end
	b = tonumber(b)
	if not b then return _setRGB(this, r, g, b) end

	-- TEXT
	if closeenough(g / r, 0.6) and closeenough(b / r, 0.11) then
		r = r * 0.114 * 3
		if r < 0.2 then r = 0.2 end
		r = math.min(1, r)
		g = r * 2.535
		g = math.min(1, g)
		b = r * 8.71
		b = math.min(1, b)

		if CoD.zbr_purple then
			r = r * CoD.zbr_purple_shift_r
			g = g * CoD.zbr_purple_shift_g
			b = b * CoD.zbr_purple_shift_b
		end

		return _setRGB(this, r, g, b)
	end

	if closeenough(g / r, 0.5) and closeenough(b / r, 0) then
		r = r * 0.114 * 1.6
		if r < 0.2 then r = 0.2 end
		r = math.max(0.114, math.min(1, r))
		g = r * 2.535
		g = math.min(1, g)
		b = r * 8.71
		b = math.min(1, b)

		if CoD.zbr_purple then
			r = r * CoD.zbr_purple_shift_r
			g = g * CoD.zbr_purple_shift_g
			b = b * CoD.zbr_purple_shift_b
		end

		return _setRGB(this, r, g, b)
	end

	if closeenough(g / r, 0.4) and closeenough(b / r, 0) then
		r = r * 0.114 * 1.6
		if r < 0.2 then r = 0.2 end
		r = math.max(0.114, math.min(1, r))
		g = r * 2.535
		g = math.min(1, g)
		b = r * 8.71
		b = math.min(1, b)
		
		if CoD.zbr_purple then
			r = r * CoD.zbr_purple_shift_r
			g = g * CoD.zbr_purple_shift_g
			b = b * CoD.zbr_purple_shift_b
		end

		return _setRGB(this, r, g, b)
	end

	if closeenough(g / r, 88 / 238) and closeenough(b / r, 0) then
		r = r * 0.114 * 1.6
		if r < 0.2 then r = 0.2 end
		r = math.max(0.114, math.min(1, r))
		g = r * 2.535
		g = math.min(1, g)
		b = r * 8.71
		b = math.min(1, b)

		if CoD.zbr_purple then
			r = r * CoD.zbr_purple_shift_r
			g = g * CoD.zbr_purple_shift_g
			b = b * CoD.zbr_purple_shift_b
		end

		return _setRGB(this, r, g, b)
	end

	return _setRGB(this, r, g, b)
end

local _RegisterImage = RegisterImage
local CachedWhite = nil
local CachedImage1 = nil
local CachedImage2 = nil
local CachedImage3 = nil
local CachedImage4 = nil
local CachedImage5 = nil
local CachedImage6 = nil

local CachedImage7 = nil
local CachedImage8 = nil
local CachedImage9 = nil
local CachedImage10 = nil
local CachedImage11 = nil
local CachedImage12 = nil

local FocusOverrideBlue = nil
local TabFullBlue = nil
local ArrowBlue = nil
local LogoBlue = nil
local QuitBlue = nil
local OverlaysBlue = nil
local ConnectBlue = nil
local ControlsBlue = nil
local BarStupidBlue = nil

if RegisterImage ~= nil then
	CachedWhite = _RegisterImage("white")
	CachedImage1 = _RegisterImage("uie_t7_menu_frontend_barfocussolidfull")
	CachedImage2 = _RegisterImage("uie_t7_cp_hud_enemytarget_glow")
	CachedImage3 = _RegisterImage("uie_t7_menu_frontend_barfocusfull")
	CachedImage4 = _RegisterImage("uie_t7_menu_frontend_buttonfocusfull")
	CachedImage5 = _RegisterImage("uie_t7_menu_cac_buttontabfocusfull")
	CachedImage6 = _RegisterImage("uie_t7_menu_frontend_buttonfocusarrow")

	CachedImage7 = _RegisterImage("uie_img_t7_menu_frontend_asset_bo3logo")
	CachedImage8 = _RegisterImage("t7_icon_quit_overlays_bkg")
	CachedImage9 = _RegisterImage("t7_icon_error_overlays_bkg")
	CachedImage10 = _RegisterImage("t7_icon_connect_overlays_bkg")
	CachedImage11 = _RegisterImage("t7_menu_startmenu_option_pc")
	CachedImage12 = _RegisterImage("uie_img_t7_menu_partyease_focusfooterfull")

	FocusOverrideBlue = _RegisterImage("uie_t7_menu_frontend_buttonfocusfull_1")
	TabFullBlue = _RegisterImage("uie_t7_menu_cac_buttontabfocusfull_1")
	ArrowBlue = _RegisterImage("uie_t7_menu_frontend_buttonfocusarrow_1")
	LogoBlue = _RegisterImage("uie_img_t7_menu_frontend_asset_bo3logo_1")
	QuitBlue = _RegisterImage("t7_icon_quit_overlays_bkg_1")
	OverlaysBlue = _RegisterImage("t7_icon_error_overlays_bkg")
	ConnectBlue = _RegisterImage("t7_icon_connect_overlays_bkg")
	ControlsBlue = _RegisterImage("t7_menu_startmenu_option_pc_1")
	BarStupidBlue = _RegisterImage("uie_img_t7_menu_partyease_focusfooterfull_1")
end



-- RegisterImage = function(image)
-- 	local result = _RegisterImage(image)
-- 	if result == CachedImage1 or result == CachedImage2 or result == CachedImage3 then
-- 		return CachedWhite
-- 	end
-- 	return result
-- end

local _setImage = LUI.UIElement.setImage
LUI.UIElement.setImage = function(element, image)
	if CachedImage1 == image then

		if CoD.zbr_purple then
			LUI.UIElement.setRGB(element, 0.12 * 0.3 * CoD.zbr_purple_shift_r, 0.51 * 0.3 * CoD.zbr_purple_shift_g, 4.0 * 0.3 * CoD.zbr_purple_shift_b)
		else
			LUI.UIElement.setRGB(element, 0.12 * 0.3, 0.51 * 0.3, 4.0 * 0.3)
		end
		
		-- return _setImage(element, CachedWhite)
	end
	if CachedImage3 == image then

		if CoD.zbr_purple then
			LUI.UIElement.setRGB(element, 0.12 * 1.2 * CoD.zbr_purple_shift_r, 0.51 * 1.2 * CoD.zbr_purple_shift_g, 4.0 * CoD.zbr_purple_shift_b)
		else
			LUI.UIElement.setRGB(element, 0.12 * 1.2, 0.51 * 1.2, 4.0)
		end
		
		-- return _setImage(element, CachedWhite)
	end
	if CachedImage2 == image then
		LUI.UIElement.setRGB(element, 0, 1, 0.99)
	end
	if CachedImage4 == image then
		return _setImage(element, FocusOverrideBlue)
	end
	if CachedImage5 == image then
		return _setImage(element, TabFullBlue)
	end
	if CachedImage6 == image then 
		return _setImage(element, ArrowBlue)
	end

	if CachedImage7 == image then 
		return _setImage(element, LogoBlue)
	end

	if CachedImage8 == image then 
		return _setImage(element, QuitBlue)
	end

	if CachedImage9 == image then 
		return _setImage(element, OverlaysBlue)
	end

	if CachedImage10 == image then 
		return _setImage(element, ConnectBlue)
	end

	if CachedImage11 == image then 
		return _setImage(element, ControlsBlue)
	end

	if CachedImage12 == image then 
		return _setImage(element, BarStupidBlue)
	end

	return _setImage(element, image)
end

Engine["ShowPlatformProfile"] = function() end

__GetScoreBoardColumnName = Engine.GetScoreBoardColumnName
Engine["GetScoreBoardColumnName"] = function(controllerIndex, columnIndex)

	local val = __GetScoreBoardColumnName(controllerIndex, columnIndex)

	if val == "MPUI_DEFUSES" then
		return "Players"
	end

	if val == "MPUI_KILLS" then
		return "Zombies"
	end

	return val
end

local __f0_local2 = function ( f3_arg0, f3_arg1, f3_arg2 )
	return {
		models = {
			displayText = f3_arg1,
			action = function ( f4_arg0, f4_arg1, f4_arg2, f4_arg3, f4_arg4 )
				HUD_IngameMenuClosed()
				SendMenuResponse( f4_arg0, "ChangeTeam", f3_arg2, f4_arg2 )
				if f4_arg4.previousMenuId then
					LUI.savedMenuStates[f4_arg4.previousMenuId] = nil
				end
				local f4_local0 = Engine.CreateModel( Engine.GetModelForController( f4_arg2 ), "factions.isCoDCaster" )
				if f3_arg2 == "spectator" then
					Engine.LockInput( f4_arg2, false )
					Engine.SetUIActive( f4_arg2, false )
					Engine.SetModelValue( f4_local0, true )
				else
					Engine.SetModelValue( f4_local0, false )
				end
				Engine.SetModelValue( Engine.CreateModel( Engine.CreateModel( Engine.GetModelForController( f4_arg2 ), "CodCaster" ), "showCodCasterScoreboard" ), false )
				SetControllerModelValue( f4_arg2, "forceScoreboard", 0 )
			end
			,
			param = {}
		},
		properties = {}
	}
end

function setup_team_stuff()
	
	CoDShared.IsGametypeTeamBased = function() 
		return CoD.zbr_loaded and ZBR.IsDuos()
	end

	CoD.GetTeamFactionColor = function ( gah )
		return string.format( "%d %d %d", CoD.teamColor[gah].r * 255, CoD.teamColor[gah].g * 255, CoD.teamColor[gah].b * 255 )
	end
	
	if CoD.zbr_loaded then
		ZBR.ExecInLobbyVM([[Lobby.TeamSelection.GetAllowedTeams = function ( f10_arg0 )
			local f10_local4 = {}

			table.insert( f10_local4, Enum.team_t.TEAM_ALLIES )
			table.insert( f10_local4, Enum.team_t.TEAM_AXIS )

			if Engine.DvarString( nil, "zbr_gametype" ) == "zhunt" then
				Engine.SetGametypeSetting( "teamCount", 2 )
				return f10_local4
			end

			table.insert( f10_local4, Enum.team_t.TEAM_FOUR )
			table.insert( f10_local4, Enum.team_t.TEAM_FIVE )
			table.insert( f10_local4, Enum.team_t.TEAM_SIX )
			table.insert( f10_local4, Enum.team_t.TEAM_SEVEN )
			table.insert( f10_local4, Enum.team_t.TEAM_EIGHT )
			table.insert( f10_local4, Enum.team_t.TEAM_NINE )
			Engine.SetGametypeSetting( "teamCount", 9 )
			return f10_local4
		end]])
	end

	if Engine.GetCurrentMap() == "core_frontend" then
		Engine.SetGametypeSetting( "teamAssignment", LuaEnums.TEAM_ASSIGNMENT.CLIENT )
		Engine.SetGametypeSetting( "allowspectating", false )
		Engine.SetGametypeSetting( "teamCount", 9 )

	else
		Engine.SetGametypeSetting( "teamAssignment", LuaEnums.TEAM_ASSIGNMENT.HOST )
		Engine.SetGametypeSetting( "allowspectating", true )
		Engine.SetGametypeSetting( "teamCount", 9 )
	end

	CoD.GetDefaultTeamName = function ( f139_arg0 )
		return CoD.teamName[f139_arg0]
	end
	
	CoD.GetTeamNameCaps = function ( f156_arg0 )
		local f156_local0 = CoD.GetTeamName( f156_arg0 )
		return Engine.ToUpper( f156_local0 )
	end
	
	if Engine.DvarString( nil, "zbr_gametype" ) == "zhunt" then
		CoD.teamName[Enum.team_t.TEAM_ALLIES] = Engine.Localize("RUNNERS")
		CoD.teamName[Enum.team_t.TEAM_AXIS] = Engine.Localize("HUNTERS")
	else
		CoD.teamName[Enum.team_t.TEAM_ALLIES] = Engine.Localize("TEAM 1")
		CoD.teamName[Enum.team_t.TEAM_AXIS] = Engine.Localize("TEAM 2")
	end

	CoD.teamName[Enum.team_t.TEAM_THREE] = Engine.Localize("ZOMBIES")
	CoD.teamName[Enum.team_t.TEAM_FOUR] = Engine.Localize("TEAM 3")
	CoD.teamName[Enum.team_t.TEAM_FIVE] = Engine.Localize("TEAM 4")
	CoD.teamName[Enum.team_t.TEAM_SIX] = Engine.Localize("TEAM 5")
	CoD.teamName[Enum.team_t.TEAM_SEVEN] = Engine.Localize("TEAM 6")
	CoD.teamName[Enum.team_t.TEAM_EIGHT] = Engine.Localize("TEAM 7")
	CoD.teamName[Enum.team_t.TEAM_NINE] = Engine.Localize("TEAM 8")
	CoD.teamColor[Enum.team_t.TEAM_THREE] = CoD.teamColor[Enum.team_t.TEAM_FREE]
	CoD.teamColor[Enum.team_t.TEAM_FOUR] = {}
	CoD.teamColor[Enum.team_t.TEAM_FOUR].r = 3 / 255.0
	CoD.teamColor[Enum.team_t.TEAM_FOUR].g = 107 / 255.0
	CoD.teamColor[Enum.team_t.TEAM_FOUR].b = 7 / 255.0
	CoD.teamColor[Enum.team_t.TEAM_FIVE] = {}
	CoD.teamColor[Enum.team_t.TEAM_FIVE].r = 171 / 255.0
	CoD.teamColor[Enum.team_t.TEAM_FIVE].g = 103 / 255.0
	CoD.teamColor[Enum.team_t.TEAM_FIVE].b = 2 / 255.0
	CoD.teamColor[Enum.team_t.TEAM_SIX] = {}
	CoD.teamColor[Enum.team_t.TEAM_SIX].r = 71 / 255.0
	CoD.teamColor[Enum.team_t.TEAM_SIX].g = 3 / 255.0
	CoD.teamColor[Enum.team_t.TEAM_SIX].b = 161 / 255.0
	CoD.teamColor[Enum.team_t.TEAM_SEVEN] = {}
	CoD.teamColor[Enum.team_t.TEAM_SEVEN].r = 194 / 255.0
	CoD.teamColor[Enum.team_t.TEAM_SEVEN].g = 2 / 255.0
	CoD.teamColor[Enum.team_t.TEAM_SEVEN].b = 175 / 255.0
	CoD.teamColor[Enum.team_t.TEAM_EIGHT] = {}
	CoD.teamColor[Enum.team_t.TEAM_EIGHT].r = 0
	CoD.teamColor[Enum.team_t.TEAM_EIGHT].g = 0
	CoD.teamColor[Enum.team_t.TEAM_EIGHT].b = 0
	CoD.teamColor[Enum.team_t.TEAM_NINE] = {}
	CoD.teamColor[Enum.team_t.TEAM_NINE].r = 0.8
	CoD.teamColor[Enum.team_t.TEAM_NINE].g = 0.8
	CoD.teamColor[Enum.team_t.TEAM_NINE].b = 0.8

	DataSources.ChangeTeamOptions = DataSourceHelpers.ListSetup( "ChangeTeamOptions", function ( f6_arg0 )
		local f6_local0 = {}
		local f6_local1 = Engine.Team( f6_arg0, "index" )
		local f6_local2
		if Engine.GetGametypeSetting( "spectatetype" ) >= 1 and Engine.GetGametypeSetting( "allowspectating" ) == 1 then
			f6_local2 = not Engine.IsSplitscreen()
		else
			f6_local2 = false
		end
		local f6_local3 = function ( f7_arg0 )
			local f7_local0 = CoD.GetTeamNameCaps( f7_arg0 )
			if f7_local0 == "" then
				f7_local0 = Engine.ToUpper( CoD.GetDefaultTeamName( f7_arg0 ) )
			end
			return f7_local0
		end
		
		if CoDShared.IsGametypeTeamBased() == true and CoD.IsTeamChangeAllowed() then
			if f6_local1 ~= Enum.team_t.TEAM_ALLIES then
				table.insert( f6_local0, __f0_local2( f6_arg0, f6_local3( Enum.team_t.TEAM_ALLIES ), "allies" ) )
			end
			if f6_local1 ~= Enum.team_t.TEAM_AXIS then
				table.insert( f6_local0, __f0_local2( f6_arg0, f6_local3( Enum.team_t.TEAM_AXIS ), "axis" ) )
			end

			if f6_local1 ~= Enum.team_t.TEAM_FOUR then
				table.insert( f6_local0, __f0_local2( f6_arg0, f6_local3( Enum.team_t.TEAM_FOUR ), "team4" ) )
			end
			if f6_local1 ~= Enum.team_t.TEAM_FIVE then
				table.insert( f6_local0, __f0_local2( f6_arg0, f6_local3( Enum.team_t.TEAM_FIVE ), "team5" ) )
			end
			if f6_local1 ~= Enum.team_t.TEAM_SIX then
				table.insert( f6_local0, __f0_local2( f6_arg0, f6_local3( Enum.team_t.TEAM_SIX ), "team6" ) )
			end
			if f6_local1 ~= Enum.team_t.TEAM_SEVEN then
				table.insert( f6_local0, __f0_local2( f6_arg0, f6_local3( Enum.team_t.TEAM_SEVEN ), "team7" ) )
			end
			if f6_local1 ~= Enum.team_t.TEAM_EIGHT then
				table.insert( f6_local0, __f0_local2( f6_arg0, f6_local3( Enum.team_t.TEAM_EIGHT ), "team8" ) )
			end
			if f6_local1 ~= Enum.team_t.TEAM_NINE then
				table.insert( f6_local0, __f0_local2( f6_arg0, f6_local3( Enum.team_t.TEAM_NINE ), "team9" ) )
			end
		end
		if CoDShared.IsGametypeTeamBased() == true or f6_local1 == Enum.team_t.TEAM_SPECTATOR then
			table.insert( f6_local0, __f0_local2( f6_arg0, "MPUI_AUTOASSIGN_CAPS", "autoassign" ) )
		end

		return f6_local0
	end, true )
end

Engine["GetCurrentTeamCount"] = function() return 9 end

local old_getgametypesetting = Engine["GetGametypeSetting"]
Engine["GetGametypeSetting"] = function(setting, isdefault)
	
	if isdefault == nil then
		isdefault = false
	end

	if CoD.zbr_gametype_settings[setting] ~= nil then
		if not CoD.zbr_loaded then
			return 0
		end

		if "zbr_teamsize" == setting then
			if isdefault then
				return 1
			end
			if Engine.DvarString(nil, "zbr_teams_size") == nil or Engine.DvarString(nil, "zbr_teams_size") == "" then
				return 1
			end
			return tonumber(Engine.DvarString(nil, "zbr_teams_size"))
		end

		return ZBR.GetGameSetting(setting, isdefault)
	end
	
	return old_getgametypesetting(setting, isdefault)
end

local old_setgametypesetting = Engine["SetGametypeSetting"]
Engine["SetGametypeSetting"] = function(setting, value)
	if CoD.zbr_gametype_settings[setting] ~= nil then
		if not CoD.zbr_loaded then
			return
		end
		if value == nil then
			value = 0
		end
		
		if "zbr_teamsize" == setting then

			if value == 1 then
				CoD.zbr_safe_call(CoD.zbr_enable_solos)
				CoD.zbr_update_status()
			end
			
			if value == 2 then
				CoD.zbr_safe_call(CoD.zbr_enable_duos)
				CoD.zbr_update_status()
			end

			if value == 3 then
				CoD.zbr_safe_call(CoD.zbr_enable_trios)
				CoD.zbr_update_status()
			end

			if value == 4 then
				CoD.zbr_safe_call(CoD.zbr_enable_quads)
				CoD.zbr_update_status()
			end

			return
		end

		ZBR.SetGameSetting(setting, value)
		return
	end
	old_setgametypesetting(setting, value)
end