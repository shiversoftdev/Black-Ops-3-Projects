EnableGlobals()

CoD.Zombie = {}
CoD.Zombie.PlayerColors = {}
CoD.Zombie.TeamPlayerCount = 8
local lindex = 1

CoD.Zombie.PlayerColors[1] = {
	r = 1,
	g = 1,
	b = 1,
	a = 1
}
Engine.SetDvar("cg_ScoresColor_Gamertag_" .. (lindex - 1), CoD.Zombie.PlayerColors[lindex].r .. " " .. CoD.Zombie.PlayerColors[lindex].g .. " " .. CoD.Zombie.PlayerColors[lindex].b .. " 1")
lindex = lindex + 1

CoD.Zombie.PlayerColors[lindex] = { -- 2
	r = 0x0A / 0xFF,
	g = 0x4c / 0xFF,
	b = 0xf2 / 0xFF,
	a = 1
}
Engine.SetDvar("cg_ScoresColor_Gamertag_" .. (lindex - 1), CoD.Zombie.PlayerColors[lindex].r + " " .. CoD.Zombie.PlayerColors[lindex].g .. " " .. CoD.Zombie.PlayerColors[lindex].b .. " 1")
lindex = lindex + 1

CoD.Zombie.PlayerColors[lindex] = { -- 3
	r = 0xe6 / 0xFF,
	g = 0xda / 0xFF,
	b = 0x83 / 0xFF,
	a = 1
}
Engine.SetDvar("cg_ScoresColor_Gamertag_" .. (lindex - 1), CoD.Zombie.PlayerColors[lindex].r .. " " .. CoD.Zombie.PlayerColors[lindex].g .. " " .. CoD.Zombie.PlayerColors[lindex].b .. " 1")
lindex = lindex + 1

CoD.Zombie.PlayerColors[lindex] = { -- 4
	r = 0x83 / 0xFF,
	g = 0xe6 / 0xFF,
	b = 0x83 / 0xFF,
	a = 1
}
Engine.SetDvar("cg_ScoresColor_Gamertag_" .. (lindex - 1), CoD.Zombie.PlayerColors[lindex].r .. " " .. CoD.Zombie.PlayerColors[lindex].g .. " " .. CoD.Zombie.PlayerColors[lindex].b .. " 1")
lindex = lindex + 1

CoD.Zombie.PlayerColors[lindex] = { -- 5
	r = 0xff / 0xFF,
	g = 0x00 / 0xFF,
	b = 0xbb / 0xFF,
	a = 1
}
Engine.SetDvar("cg_ScoresColor_Gamertag_" .. (lindex - 1), CoD.Zombie.PlayerColors[lindex].r .. " " .. CoD.Zombie.PlayerColors[lindex].g .. " " .. CoD.Zombie.PlayerColors[lindex].b .. " 1")
lindex = lindex + 1

CoD.Zombie.PlayerColors[lindex] = { -- 6
	r = 0x00 / 0xFF,
	g = 0xe1 / 0xFF,
	b = 0xff / 0xFF,
	a = 1
}
Engine.SetDvar("cg_ScoresColor_Gamertag_" .. (lindex - 1), CoD.Zombie.PlayerColors[lindex].r .. " " .. CoD.Zombie.PlayerColors[lindex].g .. " " .. CoD.Zombie.PlayerColors[lindex].b .. " 1")
lindex = lindex + 1

CoD.Zombie.PlayerColors[lindex] = { -- 7
	r = 0xff / 0xFF,
	g = 0x8c / 0xFF,
	b = 0x00 / 0xFF,
	a = 1
}
Engine.SetDvar("cg_ScoresColor_Gamertag_" .. (lindex - 1), CoD.Zombie.PlayerColors[lindex].r .. " " .. CoD.Zombie.PlayerColors[lindex].g .. " " .. CoD.Zombie.PlayerColors[lindex].b .. " 1")
lindex = lindex + 1

CoD.Zombie.PlayerColors[lindex] = { -- 8
	r = 0x73 / 0xFF,
	g = 0x00 / 0xFF,
	b = 0xff / 0xFF,
	a = 1
}
Engine.SetDvar("cg_ScoresColor_Gamertag_" .. (lindex - 1), CoD.Zombie.PlayerColors[lindex].r .. " " .. CoD.Zombie.PlayerColors[lindex].g .. " " .. CoD.Zombie.PlayerColors[lindex].b .. " 1")
lindex = lindex + 1

CoD.Zombie.GAMETYPE_ZCLASSIC = "zclassic"
CoD.Zombie.GAMETYPE_ZSTANDARD = "zstandard"
CoD.Zombie.GAMETYPE_ZGRIEF = "zgrief"
CoD.Zombie.GAMETYPE_ZCLEANSED = "zcleansed"
CoD.Zombie.GAMETYPE_ZMEAT = "zmeat"
CoD.Zombie.GAMETYPE_ZNML = "znml"
CoD.Zombie.GameTypes = {}
CoD.Zombie.GameTypes[1] = CoD.Zombie.GAMETYPE_ZCLASSIC
CoD.Zombie.GameTypes[2] = CoD.Zombie.GAMETYPE_ZSTANDARD
CoD.Zombie.GameTypes[3] = CoD.Zombie.GAMETYPE_ZGRIEF
CoD.Zombie.GameTypes[4] = CoD.Zombie.GAMETYPE_ZCLEANSED
CoD.Zombie.GameTypes[5] = CoD.Zombie.GAMETYPE_ZMEAT
CoD.Zombie.GameTypes[6] = CoD.Zombie.GAMETYPE_ZNML
CoD.Zombie.GAMETYPEGROUP_ZCLASSIC = "zclassic"
CoD.Zombie.GAMETYPEGROUP_ZSURVIVAL = "zsurvival"
CoD.Zombie.GAMETYPEGROUP_ZENCOUNTER = "zencounter"
CoD.Zombie.GameTypeGroups = {}
CoD.Zombie.GameTypeGroups[CoD.Zombie.GAMETYPE_ZCLASSIC] = {
	maxPlayers = 8,
	minPlayers = 2,
	maxLocalPlayers = 2,
	maxLocalSplitScreenPlayers = 4,
	maxTeamPlayers = 2,
	minTeamPlayers = 1
}
CoD.Zombie.GameTypeGroups[CoD.Zombie.GAMETYPE_ZSTANDARD] = {
	maxPlayers = 8,
	minPlayers = 1,
	maxLocalPlayers = 2,
	maxLocalSplitScreenPlayers = 4
}
CoD.Zombie.GameTypeGroups[CoD.Zombie.GAMETYPE_ZGRIEF] = {
	maxPlayers = 8,
	minPlayers = 2,
	maxLocalPlayers = 2,
	maxLocalSplitScreenPlayers = 4,
	maxTeamPlayers = 4,
	minTeamPlayers = 1
}
CoD.Zombie.GameTypeGroups[CoD.Zombie.GAMETYPE_ZCLEANSED] = {
	maxPlayers = 8,
	minPlayers = 2,
	maxLocalPlayers = 2,
	maxLocalSplitScreenPlayers = 4,
	maxTeamPlayers = 1,
	minTeamPlayers = 1
}
CoD.Zombie.GameTypeGroups[CoD.Zombie.GAMETYPE_ZMEAT] = {
	maxPlayers = 8,
	minPlayers = 2,
	maxLocalPlayers = 2,
	maxLocalSplitScreenPlayers = 4,
	maxTeamPlayers = 4,
	minTeamPlayers = 1
}
CoD.Zombie.GameTypeGroups[CoD.Zombie.GAMETYPE_ZNML] = {
	maxPlayers = 8,
	minPlayers = 1,
	maxLocalPlayers = 2,
	maxLocalSplitScreenPlayers = 4,
	maxTeamPlayers = 4,
	minTeamPlayers = 1
}
CoD.Zombie.START_LOCATION_TRANSIT = "transit"
CoD.Zombie.START_LOCATION_FARM = "farm"
CoD.Zombie.START_LOCATION_TOWN = "town"
CoD.Zombie.START_LOCATION_DINER = "diner"
CoD.Zombie.START_LOCATION_TUNNEL = "tunnel"
CoD.Zombie.MAP_ZM_TRANSIT = "zm_transit"
CoD.Zombie.MAP_ZM_NUKED = "zm_nuked"
CoD.Zombie.MAP_ZM_HIGHRISE = "zm_highrise"
CoD.Zombie.MAP_ZM_TRANSIT_DR = "zm_transit_dr"
CoD.Zombie.MAP_ZM_TRANSIT_TM = "zm_transit_tm"
CoD.Zombie.MAP_ZM_PRISON = "zm_prison"
CoD.Zombie.MAP_ZM_BURIED = "zm_buried"
CoD.Zombie.MAP_ZM_TOMB = "zm_tomb"
CoD.Zombie.MAP_ZM_FACTORY = "zm_factory"
CoD.Zombie.MAP_ZM_ZOD = "zm_zod"
CoD.Zombie.Maps = {}
CoD.Zombie.Maps[1] = CoD.Zombie.MAP_ZM_TRANSIT
CoD.Zombie.Maps[2] = CoD.Zombie.MAP_ZM_NUKED
CoD.Zombie.Maps[3] = CoD.Zombie.MAP_ZM_HIGHRISE
CoD.Zombie.Maps[4] = CoD.Zombie.MAP_ZM_PRISON
CoD.Zombie.Maps[5] = CoD.Zombie.MAP_ZM_BURIED
CoD.Zombie.Maps[6] = CoD.Zombie.MAP_ZM_TOMB
CoD.Zombie.Maps[7] = CoD.Zombie.MAP_ZM_ZOD
CoD.Zombie.Maps[8] = CoD.Zombie.MAP_ZM_FACTORY
CoD.Zombie.DLC0Maps = {
	CoD.Zombie.MAP_ZM_NUKED
}
CoD.Zombie.DLC1Maps = {
	CoD.Zombie.MAP_ZM_HIGHRISE
}
CoD.Zombie.DLC2Maps = {
	CoD.Zombie.MAP_ZM_PRISON
}
CoD.Zombie.DLC3Maps = {
	CoD.Zombie.MAP_ZM_BURIED
}
CoD.Zombie.DLC4Maps = {
	CoD.Zombie.MAP_ZM_TOMB
}
CoD.Zombie.AllDLCMaps = {
	CoD.Zombie.MAP_ZM_NUKED,
	CoD.Zombie.MAP_ZM_HIGHRISE,
	CoD.Zombie.MAP_ZM_PRISON,
	CoD.Zombie.MAP_ZM_BURIED,
	CoD.Zombie.MAP_ZM_TOMB
}
CoD.Zombie.SideQuestMaps = {
	CoD.Zombie.MAP_ZM_TRANSIT,
	CoD.Zombie.MAP_ZM_HIGHRISE,
	CoD.Zombie.MAP_ZM_BURIED,
	CoD.Zombie.MAP_ZM_ZOD
}
CoD.Zombie.CharacterNameDisplayMaps = {
	CoD.Zombie.MAP_ZM_PRISON,
	CoD.Zombie.MAP_ZM_BURIED,
	CoD.Zombie.MAP_ZM_TOMB,
	CoD.Zombie.MAP_ZM_ZOD,
	CoD.Zombie.MAP_ZM_FACTORY
}
CoD.Zombie.PlayListCurrentSuperCategoryIndex = nil
CoD.Zombie.miniGameDisabled = true
CoD.Zombie.ZOD_CRAFTABLE_RITUAL_NONE_ENUM = 0
CoD.Zombie.ZOD_CRAFTABLE_RITUAL_BOXER_ENUM = 1
CoD.Zombie.ZOD_CRAFTABLE_RITUAL_DETECTIVE_ENUM = 2
CoD.Zombie.ZOD_CRAFTABLE_RITUAL_FEMME_ENUM = 3
CoD.Zombie.ZOD_CRAFTABLE_RITUAL_MAGICIAN_ENUM = 4
CoD.Zombie.ZOD_CRAFTABLE_RITUAL_BITS = 3
CoD.Zombie.CASTLE_CRAFTABLE_ELEMENT_OWNER_NONE = 0
CoD.Zombie.CASTLE_CRAFTABLE_ELEMENT_OWNER_DEMPSEY = 1
CoD.Zombie.CASTLE_CRAFTABLE_ELEMENT_OWNER_NIKOLAI = 2
CoD.Zombie.CASTLE_CRAFTABLE_ELEMENT_OWNER_RICHTOFEN = 3
CoD.Zombie.CASTLE_CRAFTABLE_ELEMENT_OWNER_TAKEO = 4
CoD.Zombie.CLIENTFIELD_HOLDER_OF_BASE = "holder_of_"
CoD.Zombie.CLIENTFIELD_CHECK_BASE = "check_"
CoD.Zombie.MEMENTO_SUFFIX = "_memento"
CoD.Zombie.ZOD_CRAFTABLE_IDGUN = "idgun"
CoD.Zombie.ZOD_CRAFTABLE_PIECE_IDGUN_HEART = "part_heart"
CoD.Zombie.ZOD_CRAFTABLE_PIECE_IDGUN_SKELETON = "part_skeleton"
CoD.Zombie.ZOD_CRAFTABLE_PIECE_IDGUN_XENOMATTER = "part_xenomatter"
CoD.Zombie.ZOD_CRAFTABLE_SECOND_IDGUN = "second_idgun"
CoD.Zombie.ZOD_CRAFTABLE_PIECE_SECOND_IDGUN_HEART = "part_heart"
CoD.Zombie.ZOD_CRAFTABLE_PIECE_SECOND_IDGUN_SKELETON = "part_skeleton"
CoD.Zombie.ZOD_CRAFTABLE_PIECE_SECOND_IDGUN_XENOMATTER = "part_xenomatter"
CoD.Zombie.ZOD_CRAFTABLE_POLICE_BOX = "police_box"
CoD.Zombie.ZOD_CRAFTABLE_POLICE_BOX_FUSE_1 = "fuse_01"
CoD.Zombie.ZOD_CRAFTABLE_POLICE_BOX_FUSE_2 = "fuse_02"
CoD.Zombie.ZOD_CRAFTABLE_POLICE_BOX_FUSE_3 = "fuse_03"
CoD.Zombie.CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_DOLLY = "piece_riotshield_dolly"
CoD.Zombie.CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_DOOR = "piece_riotshield_door"
CoD.Zombie.CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_CLAMP = "piece_riotshield_clamp"
CoD.Zombie.CLIENTFIELD_ZOD_CRAFTABLE_PIECE_QUEST_KEY = "quest_key"
CoD.Zombie.CLIENTFIELD_QUEST_STATE_BASE = "quest_state_"
CoD.Zombie.CLIENTFIELD_QUEST_OWNER_BASE = "quest_owner_"
CoD.Zombie.CLIENTFIELD_WIDGET_QUEST_BASE = "widget_weap_quest_"
CoD.Zombie.ZOD_NAME_BOXER = "boxer"
CoD.Zombie.ZOD_NAME_DETECTIVE = "detective"
CoD.Zombie.ZOD_NAME_FEMME = "femme"
CoD.Zombie.ZOD_NAME_MAGICIAN = "magician"
CoD.Zombie.ZOD_NAME_PAP = "pap"
CoD.Zombie.CASTLE_NAME_DEMON = "demon"
CoD.Zombie.CASTLE_NAME_RUNE = "rune"
CoD.Zombie.CASTLE_NAME_STORM = "storm"
CoD.Zombie.CASTLE_NAME_WOLF = "wolf"
CoD.Zombie.CLIENTFIELD_ZOD_UI_QUEST_STATE_NEED_MEMENTO = 0
CoD.Zombie.CLIENTFIELD_ZOD_UI_QUEST_STATE_GOT_MEMENTO = 1
CoD.Zombie.CLIENTFIELD_ZOD_UI_QUEST_STATE_USED_MEMENTO = 2
CoD.Zombie.CLIENTFIELD_ZOD_UI_QUEST_STATE_NEED_RELIC = 3
CoD.Zombie.CLIENTFIELD_ZOD_UI_QUEST_STATE_GOT_RELIC = 4
CoD.Zombie.CLIENTFIELD_ZOD_UI_QUEST_STATE_USED_RELIC = 5
CoD.Zombie.CLIENTFIELD_ZOD_UI_QUEST_STATE_COUNT = 6
CoD.Zombie.USED_QUEST_KEY = "used_quest_key"
CoD.Zombie.USED_QUEST_KEY_LOCATION = "used_quest_key_location"
CoD.Zombie.PLAYER_USED_QUEST_KEY_NONE = 0
CoD.Zombie.PLAYER_USED_QUEST_KEY_ZOD_NAME_BOXER = 1
CoD.Zombie.PLAYER_USED_QUEST_KEY_ZOD_NAME_DETECTIVE = 2
CoD.Zombie.PLAYER_USED_QUEST_KEY_ZOD_NAME_FEMME = 3
CoD.Zombie.PLAYER_USED_QUEST_KEY_ZOD_NAME_MAGICIAN = 4
CoD.Zombie.PLAYER_USED_QUEST_KEY_ZOD_NAME_PAP = 5
CoD.Zombie.PLAYER_USED_QUEST_KEY_STATES = 6
CoD.Zombie.POD_SPRAYER_HINT_RANGE = "pod_sprayer_hint_range"
CoD.Zombie.POD_SPRAYER_HELD = "pod_sprayer_held"
CoD.Zombie.PLAYER_CHARACTER_IDENTITY = "player_character_identity"
CoD.Zombie.PLAYER_USING_SPRAYER = "player_using_sprayer"
CoD.Zombie.PLAYER_CRAFTED_FUSEBOX = "player_crafted_fusebox"
CoD.Zombie.PLAYER_CRAFTED_SHIELD = "player_crafted_shield"
CoD.Zombie.PLAYER_CRAFTED_IDGUN = "player_crafted_idgun"
CoD.Zombie.PLAYER_CRAFTED_GRAVITYSPIKES = "player_crafted_gravityspikes"
CoD.Zombie.WIDGET_QUEST_ITEMS = "widget_quest_items"
CoD.Zombie.WIDGET_IDGUN_PARTS = "widget_idgun_parts"
CoD.Zombie.WIDGET_ROCKETSHIELD_PARTS = "widget_shield_parts"
CoD.Zombie.WIDGET_FUSES = "widget_fuses"
CoD.Zombie.WIDGET_EGG = "widget_egg"
CoD.Zombie.WIDGET_SPRAYER = "widget_sprayer"
CoD.Zombie.WIDGET_GRAVITYSPIKE_PARTS = "widget_gravityspike_parts"
CoD.Zombie.PLAYER_SWORD_QUEST_EGG_STATE = "player_sword_quest_egg_state"
CoD.Zombie.PLAYER_SWORD_QUEST_COMPLETED_LEVEL_1 = "player_sword_quest_completed_level_1"
CoD.Zombie.CRAFTABLE_GRAVITYSPIKE = "gravityspike"
CoD.Zombie.CRAFTABLE_PART_GRAVITYSPIKE_BODY = "part_body"
CoD.Zombie.CRAFTABLE_PART_GRAVITYSPIKE_GUARDS = "part_guards"
CoD.Zombie.CRAFTABLE_PART_GRAVITYSPIKE_HANDLE = "part_handle"
CoD.Zombie.BOW_NAME_ICE = "ice"
CoD.Zombie.BOW_NAME_FIRE = "fire"
CoD.Zombie.BOW_NAME_WIND = "wind"
CoD.Zombie.BOW_NAME_LIGHTNING = "lightning"
CoD.Zombie.CRAFTABLE_BUCKET = "bucket"
CoD.Zombie.CRAFTABLE_BUCKET_TYPE = "bucket_type"
CoD.Zombie.CRAFTABLE_BUCKET_WATER_TYPE = "bucket_water_type"
CoD.Zombie.CRAFTABLE_BUCKET_WATER_LEVEL = "bucket_water_level"
CoD.Zombie.WIDGET_BUCKET_PARTS = "widget_bucket_parts"
CoD.Zombie.CRAFTABLE_BUCKET_SEED_1 = "seed_01"
CoD.Zombie.CRAFTABLE_BUCKET_SEED_2 = "seed_02"
CoD.Zombie.CRAFTABLE_BUCKET_SEED_3 = "seed_03"
CoD.Zombie.WIDGET_SEED_PARTS = "widget_seed_parts"
CoD.Zombie.CRAFTABLE_GASMASK = "gaskmask"
CoD.Zombie.CRAFTABLE_PART_GASMASK_MASK = "part_visor"
CoD.Zombie.CRAFTABLE_PART_GASMASK_TUBE = "part_strap"
CoD.Zombie.CRAFTABLE_PART_GASMASK_CANISTER = "part_filter"
CoD.Zombie.WIDGET_GASMASK_PARTS = "widget_gasmask_parts"
CoD.Zombie.GASMASK_PROGRESS = "gasmask_progress"
CoD.Zombie.GASMASK_ACTIVE = "gasmask_active"
CoD.Zombie.CRAFTABLE_MACHINETOOLS = "part_lever"
CoD.Zombie.CRAFTABLE_PART_MACHINETOOLS_WHEEL = "valveone"
CoD.Zombie.CRAFTABLE_PART_MACHINETOOLS_WRENCH = "valvetwo"
CoD.Zombie.CRAFTABLE_PART_MACHINETOOLS_GAUGE = "valvethree"
CoD.Zombie.WIDGET_MACHINETOOLS_PARTS = "widget_machinetools_parts"
CoD.Zombie.CRAFTABLE_WONDERWEAPON = "wonderweapon"
CoD.Zombie.CRAFTABLE_PART_WONDERWEAPON_TUBE = "part_wwi"
CoD.Zombie.CRAFTABLE_PART_WONDERWEAPON_FLASK = "part_wwii"
CoD.Zombie.CRAFTABLE_PART_WONDERWEAPON_PLANT = "part_wwiii"
CoD.Zombie.WIDGET_WONDERWEAPON_PARTS = "widget_wonderweapon_parts"
CoD.Zombie.CRAFTABLE_SKULL = "skull"
CoD.Zombie.CRAFTABLE_SKULL_STATE = "skull_state"
CoD.Zombie.CRAFTABLE_SKULL_TYPE = "skull_type"
CoD.Zombie.WIDGET_SKULL_PARTS = "widget_skull_parts"
CoD.Zombie.UI_EGG_STATE_MISSING = 0
CoD.Zombie.UI_EGG_STATE_ACQUIRED = 1
CoD.Zombie.UI_EGG_STATE_1_CHARGE = 2
CoD.Zombie.UI_EGG_STATE_2_CHARGES = 3
CoD.Zombie.UI_EGG_STATE_3_CHARGES = 4
CoD.Zombie.UI_EGG_STATE_4_CHARGES = 5
CoD.Zombie.UI_EGG_STATE_IN_USE = 6
CoD.Zombie.UI_EGG_STATES = 7
CoD.Zombie.GameOptions = {
	{
		id = "zmDifficulty",
		name = "ZMUI_DIFFICULTY_CAPS",
		hintText = "ZMUI_DIFFICULTY_DESC",
		labels = {
			"ZMUI_DIFFICULTY_EASY_CAPS",
			"ZMUI_DIFFICULTY_NORMAL_CAPS"
		},
		values = {
			0,
			1
		},
		gameTypes = {
			CoD.Zombie.GAMETYPE_ZCLASSIC,
			CoD.Zombie.GAMETYPE_ZSTANDARD,
			CoD.Zombie.GAMETYPE_ZGRIEF
		}
	},
	{
		id = "startRound",
		name = "ZMUI_STARTING_ROUND_CAPS",
		hintText = "ZMUI_STARTING_ROUND_DESC",
		labels = {
			"1",
			"5",
			"10",
			"15",
			"20"
		},
		values = {
			1,
			5,
			10,
			15,
			20
		},
		gameTypes = {
			CoD.Zombie.GAMETYPE_ZSTANDARD,
			CoD.Zombie.GAMETYPE_ZGRIEF
		}
	},
	{
		id = "magic",
		name = "ZMUI_MAGIC_CAPS",
		hintText = "ZMUI_MAGIC_DESC",
		labels = {
			"MENU_ENABLED_CAPS",
			"MENU_DISABLED_CAPS"
		},
		values = {
			1,
			0
		},
		gameTypes = {
			CoD.Zombie.GAMETYPE_ZSTANDARD,
			CoD.Zombie.GAMETYPE_ZGRIEF
		}
	},
	{
		id = "headshotsonly",
		name = "ZMUI_HEADSHOTS_ONLY_CAPS",
		hintText = "ZMUI_HEADSHOTS_ONLY_DESC",
		labels = {
			"MENU_DISABLED_CAPS",
			"MENU_ENABLED_CAPS"
		},
		values = {
			0,
			1
		},
		gameTypes = {
			CoD.Zombie.GAMETYPE_ZSTANDARD,
			CoD.Zombie.GAMETYPE_ZGRIEF
		}
	},
	{
		id = "allowdogs",
		name = "ZMUI_DOGS_CAPS",
		hintText = "ZMUI_DOGS_DESC",
		labels = {
			"MENU_DISABLED_CAPS",
			"MENU_ENABLED_CAPS"
		},
		values = {
			0,
			1
		},
		gameTypes = {
			CoD.Zombie.GAMETYPE_ZSTANDARD
		},
		maps = {
			CoD.Zombie.MAP_ZM_TRANSIT
		}
	},
	{
		id = "cleansedLoadout",
		name = "ZMUI_CLEANSED_LOADOUT_CAPS",
		hintText = "ZMUI_CLEANSED_LOADOUT_DESC",
		labels = {
			"ZMUI_CLEANSED_LOADOUT_SHOTGUN_CAPS",
			"ZMUI_CLEANSED_LOADOUT_GUN_GAME_CAPS"
		},
		values = {
			0,
			1
		},
		gameTypes = {
			CoD.Zombie.GAMETYPE_ZCLEANSED
		}
	}
}
CoD.Zombie.SingleTeamColor = {
	r = 0,
	g = 0.5,
	b = 1
}
CoD.Zombie.FullScreenSize = {
	w = 1280,
	h = 720,
	sw = 960
}
CoD.Zombie.SplitscreenMultiplier = 1.2
CoD.Zombie.OpenMenuEventMenuNames = {}
CoD.Zombie.OpenMenuEventMenuNames.PublicGameLobby = 1
CoD.Zombie.OpenMenuEventMenuNames.PrivateOnlineGameLobby = 1
CoD.Zombie.OpenMenuEventMenuNames.MainLobby = 1
CoD.Zombie.OpenMenuSelfMenuNames = {}
CoD.Zombie.OpenMenuSelfMenuNames.PublicGameLobby = 1
CoD.Zombie.OpenMenuSelfMenuNames.PrivateOnlineGameLobby = 1
CoD.Zombie.PLAYLIST_CATEGORY_FILTER_SOLOMATCH = "solomatch"
CoD.Zombie.GetUIMapName = function ()
	return CoD.Zombie.GetMapName( Engine.DvarString( nil, "ui_mapname" ) )
end

CoD.Zombie.GetMapName = function ( f2_arg0 )
	if f2_arg0 == nil or f2_arg0 == "" or string.find( f2_arg0, CoD.Zombie.MAP_ZM_TRANSIT ) ~= nil then
		f2_arg0 = CoD.Zombie.MAP_ZM_TRANSIT
	end
	return f2_arg0
end

CoD.Zombie.GetDefaultGameTypeForMap = function ()
	return CoD.Zombie.GAMETYPE_ZCLASSIC
end

CoD.Zombie.GetDefaultGameTypeGroupForMap = function ()
	return CoD.Zombie.GAMETYPEGROUP_ZCLASSIC
end

CoD.Zombie.IsDLCMap = function ( f5_arg0 )
	local f5_local0 = Dvar.ui_mapname:get()
	if f5_local0 then
		if not f5_arg0 then
			f5_arg0 = CoD.Zombie.AllDLCMaps
		end
		for f5_local1 = 1, #f5_arg0, 1 do
			if f5_local0 == f5_arg0[f5_local1] then
				return true
			end
		end
	end
	return false
end

CoD.Zombie.IsSideQuestMap = function ( f6_arg0 )
	if not f6_arg0 then
		f6_arg0 = Dvar.ui_mapname:get()
	end
	if f6_arg0 then
		for f6_local0 = 1, #CoD.Zombie.SideQuestMaps, 1 do
			if f6_arg0 == CoD.Zombie.SideQuestMaps[f6_local0] then
				return true
			end
		end
	end
	return false
end

CoD.Zombie.IsCharacterNameDisplayMap = function ( f7_arg0 )
	if not f7_arg0 then
		f7_arg0 = Dvar.ui_mapname:get()
	end
	if f7_arg0 then
		for f7_local0 = 1, #CoD.Zombie.CharacterNameDisplayMaps, 1 do
			if f7_arg0 == CoD.Zombie.CharacterNameDisplayMaps[f7_local0] then
				return true
			end
		end
	end
	return false
end

CoD.Zombie.ColorRichtofen = function ( f8_arg0, f8_arg1 )
	f8_arg0:beginAnimation( "color_rich", f8_arg1 )
	f8_arg0:setRGB( CoD.Zombie.SideQuestStoryLine[1].color.r, CoD.Zombie.SideQuestStoryLine[1].color.g, CoD.Zombie.SideQuestStoryLine[1].color.b )
end

CoD.Zombie.ColorMaxis = function ( f9_arg0, f9_arg1 )
	f9_arg0:beginAnimation( "color_maxis", f9_arg1 )
	f9_arg0:setRGB( CoD.Zombie.SideQuestStoryLine[2].color.r, CoD.Zombie.SideQuestStoryLine[2].color.g, CoD.Zombie.SideQuestStoryLine[2].color.b )
end

CoD.Zombie.SideQuestStoryLine = {}
CoD.Zombie.SideQuestStoryLine[1] = {
	name = "Richtofen",
	color = CoD.playerBlue,
	colorFunction = CoD.Zombie.ColorRichtofen
}
CoD.Zombie.SideQuestStoryLine[2] = {
	name = "Maxis",
	color = CoD.BOIIOrange,
	colorFunction = CoD.Zombie.ColorMaxis
}
CoD.PlaylistCategoryFilter = nil
CoD.Zombie.InitInventoryUIModels = function ( f10_arg0 )
	local f10_local0 = Engine.GetCurrentMap()
	local f10_local1 = Engine.CreateModel( Engine.GetModelForController( f10_arg0 ), "zmInventory" )
	Engine.SetModelValue( Engine.CreateModel( f10_local1, "shield_health" ), 1 )
	Engine.SetModelValue( Engine.CreateModel( f10_local1, "super_ee" ), 0 )
	local f10_local2 = DataSources
	f10_local2.ZMInventory = {
		getModel = function ( f11_arg0 )
			return f10_local1
		end
	}
	f10_local2 = function ( f12_arg0, f12_arg1 )
		local f12_local0 = function ( f13_arg0, f13_arg1 )
			if CoD.Zombie.fastRestart or not Engine.GetModel( f13_arg0, f13_arg1 ) then
				Engine.SetModelValue( Engine.CreateModel( f13_arg0, f13_arg1 ), 0 )
			end
		end
		
		local f12_local1 = Engine.CreateModel( Engine.GetModelForController( f12_arg0 ), "sidequestIcons" )
		for f12_local10, f12_local11 in ipairs( f12_arg1 ) do
			if f12_local11.clientfield then
				f12_local0( f12_local1, f12_local11.clientfield .. ".icon" )
				f12_local0( f12_local1, f12_local11.clientfield .. ".notification" )
			end
			for f12_local8, f12_local9 in ipairs( f12_local11 ) do
				f10_local2( f12_arg0, f12_local9 )
			end
		end
	end
	
	if f10_local0 == "zm_castle" then
		CoD.Zombie.InventoryIcon = {
			"t7_icon_inventory_dlc_fuse_small"
		}
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_GRAVITYSPIKE .. "_" .. CoD.Zombie.CRAFTABLE_PART_GRAVITYSPIKE_BODY ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_GRAVITYSPIKE .. "_" .. CoD.Zombie.CRAFTABLE_PART_GRAVITYSPIKE_GUARDS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_GRAVITYSPIKE .. "_" .. CoD.Zombie.CRAFTABLE_PART_GRAVITYSPIKE_HANDLE ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "widget_gravityspike_parts" ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.PLAYER_USING_SPRAYER ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_SPRAYER ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_DOLLY ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_DOOR ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_CLAMP ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_FUSES ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_QUEST_ITEMS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.PLAYER_CHARACTER_IDENTITY ), 0 )
		for f10_local6, f10_local7 in ipairs( {
			CoD.Zombie.CASTLE_NAME_DEMON,
			CoD.Zombie.CASTLE_NAME_RUNE,
			CoD.Zombie.CASTLE_NAME_STORM,
			CoD.Zombie.CASTLE_NAME_WOLF
		} ) do
			Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_QUEST_STATE_BASE .. f10_local7 ), 0 )
			Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_QUEST_OWNER_BASE .. f10_local7 ), 0 )
			Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_WIDGET_QUEST_BASE .. f10_local7 ), 0 )
		end
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.USED_QUEST_KEY ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.USED_QUEST_KEY_LOCATION ), 0 )
		for f10_local3 = 0, Dvar.com_maxclients:get() - 1, 1 do
			Engine.SetModelValue( Engine.CreateModel( f10_local1, "player" .. f10_local3 .. "hasItem" ), 0 )
		end
	elseif f10_local0 == "zm_island" then
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_BUCKET_PARTS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_BUCKET .. "_" .. CoD.Zombie.CRAFTABLE_BUCKET_TYPE ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_BUCKET .. "_" .. CoD.Zombie.CRAFTABLE_BUCKET_WATER_TYPE ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_BUCKET .. "_" .. CoD.Zombie.CRAFTABLE_BUCKET_WATER_LEVEL ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_BUCKET .. "_" .. CoD.Zombie.CRAFTABLE_BUCKET_SEED_1 ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_BUCKET .. "_" .. CoD.Zombie.CRAFTABLE_BUCKET_SEED_2 ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_BUCKET .. "_" .. CoD.Zombie.CRAFTABLE_BUCKET_SEED_3 ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_SEED_PARTS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_DOLLY ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_DOOR ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_CLAMP ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_ROCKETSHIELD_PARTS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_GASMASK .. "_" .. CoD.Zombie.CRAFTABLE_PART_GASMASK_MASK ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_GASMASK .. "_" .. CoD.Zombie.CRAFTABLE_PART_GASMASK_TUBE ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_GASMASK .. "_" .. CoD.Zombie.CRAFTABLE_PART_GASMASK_CANISTER ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_GASMASK_PARTS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_GASMASK .. "_" .. CoD.Zombie.GASMASK_PROGRESS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_GASMASK .. "_" .. CoD.Zombie.GASMASK_ACTIVE ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_PART_MACHINETOOLS_WHEEL .. "_" .. CoD.Zombie.CRAFTABLE_MACHINETOOLS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_PART_MACHINETOOLS_WRENCH .. "_" .. CoD.Zombie.CRAFTABLE_MACHINETOOLS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_PART_MACHINETOOLS_GAUGE .. "_" .. CoD.Zombie.CRAFTABLE_MACHINETOOLS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_MACHINETOOLS_PARTS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_WONDERWEAPON .. "_" .. CoD.Zombie.CRAFTABLE_PART_WONDERWEAPON_TUBE ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_WONDERWEAPON .. "_" .. CoD.Zombie.CRAFTABLE_PART_WONDERWEAPON_FLASK ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_WONDERWEAPON .. "_" .. CoD.Zombie.CRAFTABLE_PART_WONDERWEAPON_PLANT ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_WONDERWEAPON_PARTS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_SKULL .. "_" .. CoD.Zombie.CRAFTABLE_SKULL_STATE ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CRAFTABLE_SKULL .. "_" .. CoD.Zombie.CRAFTABLE_SKULL_TYPE ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_SKULL_PARTS ), 0 )
		DataSources.ZMIslandInventory = {
			getModel = function ( f14_arg0 )
				return f10_local1
			end
		}
	elseif f10_local0 == "zm_stalingrad" then
		CoD.Zombie.WearableItems = {
			"raz",
			"sentinel",
			"wings"
		}
		CoD.Zombie.ChallengeIcons = {
			"uie_t7_icon_dlc3_tomb_challenge_medals_01",
			"uie_t7_icon_dlc3_tomb_challenge_medals_02",
			"uie_t7_icon_dlc3_tomb_challenge_medals_03",
			"uie_t7_icon_dlc3_tomb_challenge_medals_04"
		}
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "widget_shield_parts" ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "piece_riotshield_dolly" ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "piece_riotshield_door" ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "piece_riotshield_clamp" ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "widget_dragon_strike" ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "widget_dragonride_parts" ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "dragonride_part_transmitter" ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "dragonride_part_codes" ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "dragonride_part_map" ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "widget_cylinder" ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "piece_cylinder" ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "widget_egg" ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "piece_egg" ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, "progress_egg" ), 0 )
		for f10_local3 = 0, Dvar.com_maxclients:get() - 1, 1 do
			Engine.SetModelValue( Engine.CreateModel( f10_local1, "player" .. f10_local3 .. "wearableItem" ), 0 )
		end
		DataSources.ZMStalingradInventory = {
			getModel = function ( f15_arg0 )
				return f10_local1
			end
		}
		DataSources.ZMStalingradChallenges = {
			getModel = function ( f16_arg0 )
				return Engine.CreateModel( Engine.GetModelForController( f16_arg0 ), "trialWidget" )
			end
		}
	elseif f10_local0 == "zm_genesis" then
		CoD.Zombie.WearableItems = {
			"weaselhat",
			"helm",
			"apothicon",
			"kinghelm",
			"keeper",
			"margwa",
			"direwolf",
			"fury"
		}
		CoD.Zombie.ChallengeIcons = {
			"uie_t7_icon_dlc4_challenge_medals_01",
			"uie_t7_icon_dlc4_challenge_medals_02",
			"uie_t7_icon_dlc4_challenge_medals_03"
		}
		for f10_local7, f10_local8 in ipairs( {
			"player_apothicon_egg",
			"player_crafted_shield",
			"player_keeper_protector",
			"player_rune_quest",
			"widget_apothicon_egg",
			"widget_shield_parts",
			"widget_keeper_protector_parts",
			"widget_rune_parts",
			"player_apothicon_egg_bg",
			"piece_riotshield_dolly",
			"keeper_callbox_head",
			"gen_rune_electricity",
			"player_gate_worm",
			"piece_riotshield_door",
			"keeper_callbox_totem",
			"gen_rune_fire",
			"widget_gate_worm",
			"piece_riotshield_clamp",
			"keeper_callbox_gem",
			"gen_rune_light",
			"player_gate_worm_bg",
			"gen_rune_shadow",
			"wearable_perk_icons"
		} ) do
			Engine.SetModelValue( Engine.CreateModel( f10_local1, f10_local8 ), 0 )
		end
		for f10_local4 = 0, Dvar.com_maxclients:get() - 1, 1 do
			Engine.SetModelValue( Engine.CreateModel( f10_local1, "player" .. f10_local4 .. "wearableItem" ), 0 )
		end
		for f10_local4 = 1, 3, 1 do
			Engine.CreateModel( Engine.CreateModel( Engine.GetModelForController( f10_arg0 ), "trialWidget" ), "challenge" .. f10_local4 .. "state" )
		end
		DataSources.ZMGenesisInventory = {
			getModel = function ( f17_arg0 )
				return f10_local1
			end
		}
		DataSources.ZMGenesisChallenges = {
			getModel = function ( f18_arg0 )
				return Engine.CreateModel( Engine.GetModelForController( f18_arg0 ), "trialWidget" )
			end
		}
	elseif f10_local0 == "zm_tomb" then
		CoD.Zombie.WearableItems = {
			"gold_helmet"
		}
		for f10_local3 = 0, Dvar.com_maxclients:get() - 1, 1 do
			Engine.SetModelValue( Engine.CreateModel( f10_local1, "player" .. f10_local3 .. "wearableItem" ), 0 )
		end
		CoD.Zombie.InventoryIcon = {
			"uie_t7_zm_icon_hd_shovel",
			"uie_t7_zm_icon_hd_shovel_gold"
		}
		CoD.Zombie.ChallengeIcons = {
			"uie_t7_zm_hd_medal_kill",
			"uie_t7_zm_hd_medal_level",
			"uie_t7_zm_hd_medal_economy",
			"uie_t7_zm_hd_medal_team"
		}
		for f10_local7, f10_local8 in ipairs( {
			"widget_shield_parts",
			"piece_riotshield_dolly",
			"piece_riotshield_door",
			"piece_riotshield_clamp",
			"piece_quadrotor_zm_body",
			"piece_quadrotor_zm_brain",
			"piece_quadrotor_zm_engine",
			"show_maxis_drone_parts_widget",
			"current_gem",
			"piece_record_zm_player",
			"piece_record_zm_vinyl_master",
			"capture_generator_wheel_widget",
			"zone_capture_hud_generator_1",
			"zone_capture_hud_generator_2",
			"zone_capture_hud_generator_3",
			"zone_capture_hud_generator_4",
			"zone_capture_hud_generator_5",
			"zone_capture_hud_generator_6",
			"zc_change_progress_bar_color",
			"challenges.challenge_complete_1",
			"challenges.challenge_complete_2",
			"challenges.challenge_complete_3",
			"challenges.challenge_complete_4",
			"player_tablet_state"
		} ) do
			if CoD.Zombie.fastRestart or not Engine.GetModel( f10_local1, f10_local8 ) then
				Engine.SetModelValue( Engine.CreateModel( f10_local1, f10_local8 ), 0 )
			end
		end
		f10_local4 = {
			"fire_staff",
			"air_staff",
			"lightning_staff",
			"water_staff"
		}
		f10_local5 = {
			"piece_zm_ustaff",
			"piece_zm_mstaff",
			"piece_zm_lstaff",
			"holder",
			"visible"
		}
		for f10_local12, f10_local13 in ipairs( f10_local4 ) do
			for f10_local9, f10_local10 in ipairs( f10_local5 ) do
				Engine.SetModelValue( Engine.CreateModel( f10_local1, f10_local13 .. "." .. f10_local10 ), 0 )
			end
		end
		DataSources.ZMTombInventory = {
			getModel = function ( f19_arg0 )
				return f10_local1
			end
		}
		CoD.Zombie.TOMB_STAFF_QUEST_STATE_NOTHING = 0
		CoD.Zombie.TOMB_STAFF_QUEST_STATE_GOT_RECORD = 1
		CoD.Zombie.TOMB_STAFF_QUEST_STATE_GOT_CRYSTAL = 2
		CoD.Zombie.TOMB_STAFF_QUEST_STATE_MADE_STAFF = 3
		CoD.Zombie.TOMB_STAFF_QUEST_STATE_GOT_UPGRADE = 4
	elseif f10_local0 == "zm_theater" then
		for f10_local7, f10_local8 in ipairs( {
			"widget_shield_parts",
			"piece_riotshield_dolly",
			"piece_riotshield_door",
			"piece_riotshield_clamp"
		} ) do
			if CoD.Zombie.fastRestart or not Engine.GetModel( f10_local1, f10_local8 ) then
				Engine.SetModelValue( Engine.CreateModel( f10_local1, f10_local8 ), 0 )
			end
		end
		CoD.Zombie.SidequestIcons = {
			{
				clientfield = "movieReel",
				icon = "t7_zm_icon_hd_film"
			}
		}
		f10_local2( f10_arg0, CoD.Zombie.SidequestIcons )
	elseif f10_local0 == "zm_moon" then
		CoD.Zombie.WearableItems = {
			"helmet"
		}
		for f10_local3 = 0, Dvar.com_maxclients:get() - 1, 1 do
			Engine.SetModelValue( Engine.CreateModel( f10_local1, "player" .. f10_local3 .. "wearableItem" ), 0 )
		end
		for f10_local7, f10_local8 in ipairs( {
			"widget_shield_parts",
			"piece_riotshield_dolly",
			"piece_riotshield_door",
			"piece_riotshield_clamp"
		} ) do
			if CoD.Zombie.fastRestart or not Engine.GetModel( f10_local1, f10_local8 ) then
				Engine.SetModelValue( Engine.CreateModel( f10_local1, f10_local8 ), 0 )
			end
		end
		CoD.Zombie.SidequestIcons = {
			{
				{
					clientfield = "vril",
					icon = "t7_zm_icon_hd_vril"
				},
				{
					clientfield = "generator",
					icon = "t7_zm_icon_hd_vril_combo"
				},
				{
					clientfield = "cgenerator",
					icon = "t7_zm_icon_hd_vril_combo_glow"
				}
			},
			{
				clientfield = "anti115",
				icon = "t7_zm_icon_hd_meteor"
			},
			{
				clientfield = "wire",
				icon = "t7_zm_icon_hd_wire"
			},
			{
				clientfield = "datalog",
				icon = "t7_zm_icon_hd_film"
			}
		}
		f10_local2( f10_arg0, CoD.Zombie.SidequestIcons )
	elseif f10_local0 == "zm_temple" then
		for f10_local7, f10_local8 in ipairs( {
			"widget_shield_parts",
			"piece_riotshield_dolly",
			"piece_riotshield_door",
			"piece_riotshield_clamp"
		} ) do
			if CoD.Zombie.fastRestart or not Engine.GetModel( f10_local1, f10_local8 ) then
				Engine.SetModelValue( Engine.CreateModel( f10_local1, f10_local8 ), 0 )
			end
		end
		CoD.Zombie.SidequestIcons = {
			{
				clientfield = "vril",
				icon = "t7_zm_icon_hd_vril"
			},
			{
				clientfield = "anti115",
				icon = "t7_zm_icon_hd_meteor"
			},
			{
				clientfield = "dynamite",
				icon = "t7_zm_icon_hd_dynamite"
			}
		}
		f10_local2( f10_arg0, CoD.Zombie.SidequestIcons )
	else
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.ZOD_CRAFTABLE_IDGUN .. "_" .. CoD.Zombie.ZOD_CRAFTABLE_PIECE_IDGUN_HEART ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.ZOD_CRAFTABLE_IDGUN .. "_" .. CoD.Zombie.ZOD_CRAFTABLE_PIECE_IDGUN_SKELETON ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.ZOD_CRAFTABLE_IDGUN .. "_" .. CoD.Zombie.ZOD_CRAFTABLE_PIECE_IDGUN_XENOMATTER ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.ZOD_CRAFTABLE_SECOND_IDGUN .. "_" .. CoD.Zombie.ZOD_CRAFTABLE_PIECE_SECOND_IDGUN_HEART ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.ZOD_CRAFTABLE_SECOND_IDGUN .. "_" .. CoD.Zombie.ZOD_CRAFTABLE_PIECE_SECOND_IDGUN_SKELETON ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.ZOD_CRAFTABLE_SECOND_IDGUN .. "_" .. CoD.Zombie.ZOD_CRAFTABLE_PIECE_SECOND_IDGUN_XENOMATTER ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.ZOD_CRAFTABLE_POLICE_BOX .. "_" .. CoD.Zombie.ZOD_CRAFTABLE_POLICE_BOX_FUSE_1 ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.ZOD_CRAFTABLE_POLICE_BOX .. "_" .. CoD.Zombie.ZOD_CRAFTABLE_POLICE_BOX_FUSE_2 ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.ZOD_CRAFTABLE_POLICE_BOX .. "_" .. CoD.Zombie.ZOD_CRAFTABLE_POLICE_BOX_FUSE_3 ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_DOLLY ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_DOOR ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_CRAFTABLE_PIECE_RIOTSHIELD_CLAMP ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_ZOD_CRAFTABLE_PIECE_QUEST_KEY ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_QUEST_STATE_BASE .. CoD.Zombie.ZOD_NAME_BOXER ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_QUEST_STATE_BASE .. CoD.Zombie.ZOD_NAME_DETECTIVE ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_QUEST_STATE_BASE .. CoD.Zombie.ZOD_NAME_FEMME ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_QUEST_STATE_BASE .. CoD.Zombie.ZOD_NAME_MAGICIAN ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_QUEST_STATE_BASE .. CoD.Zombie.ZOD_NAME_PAP ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_HOLDER_OF_BASE .. CoD.Zombie.ZOD_NAME_BOXER ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_HOLDER_OF_BASE .. CoD.Zombie.ZOD_NAME_DETECTIVE ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_HOLDER_OF_BASE .. CoD.Zombie.ZOD_NAME_FEMME ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_HOLDER_OF_BASE .. CoD.Zombie.ZOD_NAME_MAGICIAN ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_HOLDER_OF_BASE .. CoD.Zombie.ZOD_NAME_PAP ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_CHECK_BASE .. CoD.Zombie.ZOD_NAME_BOXER .. CoD.Zombie.MEMENTO_SUFFIX ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_CHECK_BASE .. CoD.Zombie.ZOD_NAME_DETECTIVE .. CoD.Zombie.MEMENTO_SUFFIX ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_CHECK_BASE .. CoD.Zombie.ZOD_NAME_FEMME .. CoD.Zombie.MEMENTO_SUFFIX ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.CLIENTFIELD_CHECK_BASE .. CoD.Zombie.ZOD_NAME_MAGICIAN .. CoD.Zombie.MEMENTO_SUFFIX ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.USED_QUEST_KEY ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.USED_QUEST_KEY_LOCATION ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.POD_SPRAYER_HINT_RANGE ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.POD_SPRAYER_HELD ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.PLAYER_USING_SPRAYER ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.PLAYER_CHARACTER_IDENTITY ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.PLAYER_CRAFTED_FUSEBOX ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.PLAYER_CRAFTED_SHIELD ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.PLAYER_CRAFTED_IDGUN ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.PLAYER_CRAFTED_GRAVITYSPIKES ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_QUEST_ITEMS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_IDGUN_PARTS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_ROCKETSHIELD_PARTS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_FUSES ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_EGG ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_SPRAYER ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.WIDGET_GRAVITYSPIKE_PARTS ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.PLAYER_SWORD_QUEST_EGG_STATE ), 0 )
		Engine.SetModelValue( Engine.CreateModel( f10_local1, CoD.Zombie.PLAYER_SWORD_QUEST_COMPLETED_LEVEL_1 ), 0 )
	end
end

CoD.Zombie.CommonHudRequire = function ()
	require( "ui_mp.T6.Zombie.HudPowerUpsZombie" )
	local f20_local0 = function ()
		local f21_local0 = {
			powerup_instant_kill = "specialty_giant_instakill_zombies",
			powerup_double_points = "specialty_giant_doublepoints_zombies",
			powerup_fire_sale = "specialty_giant_firesale_zombies",
			powerup_mini_gun = "t7_hud_zm_powerup_giant_deathmachine"
		}
		for f21_local1 = 1, #CoD.PowerUps.ClientFieldNames, 1 do
			local f21_local4 = CoD.PowerUps.ClientFieldNames[f21_local1].clientFieldName
			if f21_local4 and f21_local0[f21_local4] then
				CoD.PowerUps.ClientFieldNames[f21_local1].material = RegisterMaterial( f21_local0[f21_local4] )
			end
		end
	end
	
	f20_local0()
end

CoD.Zombie.CommonPreLoadHud = function ( f22_arg0, f22_arg1 )
	local f22_local0 = Engine.GetModelForController( f22_arg1 )
	Engine.CreateModel( f22_local0, "bgb_current" )
	Engine.CreateModel( f22_local0, "bgb_display" )
	Engine.CreateModel( f22_local0, "bgb_timer" )
	Engine.CreateModel( f22_local0, "bgb_activations_remaining" )
	Engine.CreateModel( f22_local0, "bgb_invalid_use" )
	Engine.CreateModel( f22_local0, "bgb_one_shot_use" )
	Engine.CreateModel( f22_local0, "zmhud.swordEnergy" )
	Engine.CreateModel( f22_local0, "zmhud.swordState" )
	Engine.CreateModel( f22_local0, "dragon_strike_invalid_use" )
	f22_arg0:subscribeToModel( Engine.CreateModel( Engine.GetGlobalModel(), "fastRestart" ), function ( modelRef )
		CoD.Zombie.fastRestart = true
		CoD.Zombie.InitInventoryUIModels( f22_arg1 )
		CoD.Zombie.fastRestart = nil
	end, false )
	CoD.Zombie.InitInventoryUIModels( f22_arg1 )
end

CoD.Zombie.CommonPostLoadHud = function ( f24_arg0, f24_arg1 )
	local f24_local0 = DataSources.WorldSpaceIndicators.getModel( f24_arg1 )
	CoD.TacticalModeUtility.CreateShooterSpottedWidgets( f24_arg0, f24_arg1 )
	if f24_local0 then
		local f24_local1 = function ( f25_arg0 )
			local f25_local0 = f25_arg0:getFirstChild()
			while f25_local0 do
				if LUI.startswith( f25_local0.id, "bleedOutItem" ) then
					local f25_local1 = f25_local0:getModel( f24_arg1, "playerName" )
					if f25_local1 then
						Engine.SetModelValue( f25_local1, Engine.GetGamertagForClient( f24_arg1, f25_local0.bleedOutClient ) )
					end
				end
				f25_local0 = f25_local0:getNextSibling()
			end
		end
		
		local f24_local2 = 0
		local f24_local3 = true
		while f24_local3 do
			local f24_local4 = Engine.CreateModel( f24_local0, "bleedOutModel" .. f24_local2 )
			Engine.SetModelValue( Engine.CreateModel( f24_local4, "playerName" ), Engine.GetGamertagForClient( f24_arg1, f24_local2 ) )
			Engine.SetModelValue( Engine.CreateModel( f24_local4, "prompt" ), "ZMUI_REVIVE" )
			Engine.SetModelValue( Engine.CreateModel( f24_local4, "clockPercent" ), 0 )
			Engine.SetModelValue( Engine.CreateModel( f24_local4, "bleedOutPercent" ), 0 )
			Engine.SetModelValue( Engine.CreateModel( f24_local4, "stateFlags" ), 0 )
			Engine.SetModelValue( Engine.CreateModel( f24_local4, "arrowAngle" ), 0 )
			local f24_local5 = CoD.ZM_Revive.new( f24_arg0, f24_arg1 )
			f24_local5.bleedOutClient = f24_local2
			f24_local5.id = "bleedOutItem" .. f24_local2
			f24_local5:setLeftRight( true, false, 0, 0 )
			f24_local5:setTopBottom( true, false, 0, 0 )
			f24_local5:setModel( f24_local4 )
			f24_local3 = f24_local5:setupBleedOutWidget( f24_arg1, f24_local2 )
			f24_local5:processEvent( {
				name = "update_state",
				menu = f24_arg0
			} )
			f24_arg0.fullscreenContainer:addElement( f24_local5 )
			f24_arg0.fullscreenContainer:subscribeToModel( Engine.GetModel( Engine.GetModelForController( f24_arg1 ), "playerConnected" ), function ( modelRef )
				f24_local1( f24_arg0.fullscreenContainer )
			end )
			f24_local2 = f24_local2 + 1
		end
	end
	f24_arg0.m_inputDisabled = true
	if LUI.DEV ~= nil then
		if LUI.DEVHideButtonPrompts then
			f24_arg0.CursorHint:setAlpha( 0 )
		end
		f24_arg0:registerEventHandler( "hide_button_prompts", function ( element, event )
			element.CursorHint:setAlpha( event.show and 1 or 0 )
		end )
	end
end

CoD.Zombie.GetCharacterEnumString = function ( f28_arg0 )
	if f28_arg0 == 0 then
		return "ZOD_CRAFTABLE_RITUAL_NONE_ENUM"
	elseif f28_arg0 == 1 then
		return "ZOD_CRAFTABLE_RITUAL_BOXER_ENUM"
	elseif f28_arg0 == 2 then
		return "ZOD_CRAFTABLE_RITUAL_DETECTIVE_ENUM"
	elseif f28_arg0 == 3 then
		return "ZOD_CRAFTABLE_RITUAL_FEMME_ENUM"
	elseif f28_arg0 == 4 then
		return "ZOD_CRAFTABLE_RITUAL_MAGICIAN_ENUM"
	else
		
	end
end