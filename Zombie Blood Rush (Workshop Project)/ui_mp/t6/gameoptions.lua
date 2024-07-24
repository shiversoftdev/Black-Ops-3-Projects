require( "lua.Shared.LuaEnums" )

CoD.GameOptions = {}
CoD.GameOptionsMenu = InheritFrom( CoD.Menu )
CoD.GameOptions.HardcoreSettingChanged = function ( f1_arg0, f1_arg1 )
	if f1_arg0 == 0 then
		Engine.SetGametypeSetting( "allowKillcam", Engine.GetGametypeSetting( "allowKillcam", true ), false )
		Engine.SetGametypeSetting( "allowBattleChatter", Engine.GetGametypeSetting( "allowBattleChatter", true ), false )
		Engine.SetGametypeSetting( "playerMaxHealth", Engine.GetGametypeSetting( "playerMaxHealth", true ), false )
		Engine.SetGametypeSetting( "playerHealthRegenTime", Engine.GetGametypeSetting( "playerHealthRegenTime", true ), false )
		Engine.SetGametypeSetting( "friendlyfiretype", Engine.GetGametypeSetting( "friendlyfiretype", true ), false )
		Engine.SetGametypeSetting( "teamKillPointLoss", Engine.GetGametypeSetting( "teamKillPointLoss", true ), false )
		Engine.SetGametypeSetting( "teamKillPunishCount", Engine.GetGametypeSetting( "teamKillPunishCount", true ), false )
	else
		Engine.SetGametypeSetting( "allowKillcam", 0, false )
		Engine.SetGametypeSetting( "allowBattlechatter", 0, false )
		Engine.SetGametypeSetting( "playerMaxHealth", 30, false )
		Engine.SetGametypeSetting( "playerHealthRegenTime", 0, false )
		Engine.SetGametypeSetting( "friendlyfiretype", 1, false )
		Engine.SetGametypeSetting( "teamKillPointLoss", 1, false )
		Engine.SetGametypeSetting( "teamKillPunishCount", 3, false )
	end
end

local f0_local0 = function ( f2_arg0, f2_arg1 )
	local f2_local0 = f2_arg0.parentSelectorButton
	if f2_arg1 then
		if f2_arg0.value == 0 then
			Engine.SetGametypeSetting( "roundLimit", 0 )
			Engine.SetGametypeSetting( "roundWinLimit", 2 )
			Engine.SetGametypeSetting( "scoreLimit", 3 )
		else
			Engine.SetGametypeSetting( "roundLimit", 2 )
			Engine.SetGametypeSetting( "roundWinLimit", 0 )
			Engine.SetGametypeSetting( "scoreLimit", 0 )
		end
		CoD.GametypeSettingLeftRightSelector.SelectionChanged( f2_arg0 )
		f2_local0:dispatchEventToParent( {
			name = "refresh_settings"
		} )
	else
		CoD.GametypeSettingLeftRightSelector.SelectionChanged( f2_arg0 )
	end
end

local f0_local1 = function ()
	return Engine.GetGametypeSetting( "cumulativeRoundScores" ) == 1
end

local f0_local2 = function ()
	return Engine.GetGametypeSetting( "cumulativeRoundScores" ) == 0
end

local f0_local3 = function ()
	return Engine.GetGametypeSetting( "loadoutKillstreaksEnabled", true ) == 1
end

local f0_local4 = function ()
	return Engine.GetGametypeSetting( "disableCAC" ) == 0
end

CoD.GameOptions.EnabledDisabledLabels = {
	"MENU_ENABLED",
	"MENU_DISABLED"
}
CoD.GameOptions.EnabledDisabledValues = {
	1,
	0
}
CoD.GameOptions.GameSettings = {
	allowAnnouncer = {
		name = "MENU_ANNOUNCER",
		hintText = {
			"MENU_ANNOUNCER_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	allowBattleChatter = {
		name = "MENU_BATTLECHATTER",
		hintText = {
			"MENU_BATTLECHATTER_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	allowhitmarkers = {
		name = "MENU_HIT_MARKERS",
		hintText = {
			"MENU_HIT_MARKERS_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_OFF_FOR_TACTICALS",
			"MENU_ENABLED"
		},
		values = {
			0,
			1,
			2
		}
	},
	allowInGameTeamChange = {
		name = "MENU_INGAME_TEAM_CHANGE",
		hintText = {
			"MENU_INGAME_TEAM_CHANGE_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	allowKillcam = {
		name = "MENU_ALLOW_KILLCAM",
		hintText = {
			"MENU_ALLOW_KILLCAM_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	allowMapScripting = {
		name = "MENU_ALLOW_MP_MAP_SCRIPTING",
		hintText = {
			"MENU_ALLOW_MP_MAP_SCRIPTING_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	allowProne = {
		name = "MENU_PRONE",
		hintText = {
			"MENU_PRONE_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	allowSpectating = {
		name = "MENU_ALLOW_SHOUTCASTING",
		hintText = {
			"MENU_ALLOW_SHOUTCASTING_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	autoDestroyTime = {
		name = "MENU_AUTO_DESTROY_TIME",
		hintText = {
			"MENU_AUTO_DESTROY_TIME_HINT"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_1_MINUTE",
			"MENU_1_5_MINUTES",
			"MENU_2_MINUTES",
			"MENU_2_5_MINUTES",
			"MENU_3_MINUTES",
			"MENU_5_MINUTES"
		},
		values = {
			0,
			30,
			45,
			60,
			90,
			120,
			150,
			180,
			300
		}
	},
	ballCount = {
		setting = "ballCount",
		name = "MENU_BALL_COUNT",
		hintText = {
			"MENU_BALL_COUNT_HINT"
		},
		labels = {
			"MENU_1_BALL",
			"MENU_X_BALLS"
		},
		values = {
			1,
			2,
			3,
			4,
			5
		}
	},
	bootTime = {
		setting = "bootTime",
		name = "MENU_BOOT_TIME",
		hintText = {
			"MENU_BOOT_TIME_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS"
		},
		values = {
			0,
			5,
			10,
			15,
			20,
			30
		}
	},
	teamAssignment = {
		name = "MENU_TEAM_ASSIGNMENT",
		hintText = {
			"MENU_TEAM_ASSIGNMENT_CLIENT_HINT",
			"MENU_TEAM_ASSIGNMENT_HOST_HINT",
			"MENU_TEAM_ASSIGNMENT_AUTO_HINT"
		},
		labels = {
			"MENU_TEAM_ASSIGNMENT_CLIENT",
			"MENU_TEAM_ASSIGNMENT_HOST",
			"MENU_TEAM_ASSIGNMENT_AUTO"
		},
		values = {
			LuaEnums.TEAM_ASSIGNMENT.CLIENT,
			LuaEnums.TEAM_ASSIGNMENT.HOST,
			LuaEnums.TEAM_ASSIGNMENT.AUTO
		}
	},
	bombTimer = {
		name = "MENU_BOMB_TIMER",
		hintText = {
			"MENU_BOMB_TIMER_HINT"
		},
		labels = {
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_1_MINUTE",
			"MENU_1_5_MINUTES",
			"MENU_2_MINUTES",
			"MENU_2_5_MINUTES"
		},
		values = {
			2.5,
			5,
			7.5,
			10,
			15,
			20,
			30,
			45,
			60,
			90,
			120,
			150
		}
	},
	carrierArmor = {
		setting = "carrierArmor",
		name = "MENU_CARRIER_ARMOR",
		hintText = {
			"MENU_CARRIER_ARMOR_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_NORMAL",
			"MENU_DOUBLE",
			"MENU_HALF"
		},
		values = {
			0,
			100,
			200,
			50
		}
	},
	carryScore = {
		setting = "carryScore",
		name = "MENU_CARRY_SCORE",
		hintText = {
			"MENU_CARRY_SCORE_HINT"
		},
		labels = {
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9
		}
	},
	destroyTime = {
		name = "MENU_DESTROY_TIME",
		hintText = {
			"MENU_DESTROY_TIME_HINT"
		},
		labels = {
			"MENU_1_SECOND",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_1_MINUTE"
		},
		values = {
			1,
			2.5,
			5,
			7.5,
			10,
			15,
			20,
			30,
			60
		}
	},
	captureTime = {
		name = "MENU_CAPTURE_TIME",
		hintText = {
			"MENU_CAPTURE_TIME_HINT"
		},
		labels = {
			"MENU_1_SECOND",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_1_MINUTE"
		},
		values = {
			1,
			2.5,
			5,
			7.5,
			10,
			15,
			20,
			30,
			60
		}
	},
	captureTime_koth = {
		setting = "captureTime",
		name = "MENU_CAPTURE_TIME",
		hintText = {
			"MENU_CAPTURE_TIME_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_1_SECOND",
			"MENU_X_SECONDS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10
		}
	},
	captureTime_ctf = {
		setting = "captureTime",
		name = "MENU_PICKUP_TIME",
		hintText = {
			"MENU_PICKUP_TIME_HINT"
		},
		labels = {
			"MENU_INSTANT",
			"MENU_X_SECONDS",
			"MENU_1_SECOND",
			"MENU_X_SECONDS"
		},
		values = {
			0,
			0.5,
			1,
			1.5,
			2,
			2.5,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10
		}
	},
	defuseTime = {
		name = "MENU_DEFUSE_TIME",
		hintText = {
			"MENU_DEFUSE_TIME_HINT"
		},
		labels = {
			"MENU_1_SECOND",
			"MENU_X_SECONDS"
		},
		values = {
			1,
			2.5,
			3,
			3.5,
			4,
			4.5,
			5,
			5.5,
			6,
			6.5,
			7,
			7.5,
			8,
			8.5,
			9,
			9.5,
			10
		}
	},
	disableCAC = {
		name = "MENU_DISABLE_CAC",
		hintText = {
			"MENU_DISABLE_CAC_HINT"
		},
		labels = {
			"MENU_ENABLED",
			"MENU_DISABLED"
		},
		values = {
			0,
			1
		}
	},
	disableThirdPersonSpectating = {
		name = "MENU_DISABLE_THIRD_PERSON_SPECTATING",
		hintText = {
			"MENU_DISABLE_THIRD_PERSON_SPECTATING_HINT"
		},
		labels = {
			"MENU_ENABLED",
			"MENU_DISABLED"
		},
		values = {
			0,
			1
		}
	},
	disableVehicleSpawners = {
		name = "MENU_VEHICLE_SPAWNERS",
		hintText = {
			"MENU_VEHICLE_SPAWNERS_HINT"
		},
		labels = {
			"MENU_ENABLED",
			"MENU_DISABLED"
		},
		values = {
			0,
			1
		}
	},
	droppedTagRespawn = {
		name = "MENU_DOG_TAGS",
		hintText = {
			"MENU_DOG_TAGS_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	enemyCarrierVisible = {
		name = "MENU_ENEMY_CARRIER",
		hintText = {
			"MENU_ENEMY_CARRIER_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_ENABLED",
			"MENU_DELAYED"
		},
		values = {
			0,
			1,
			2
		}
	},
	extraTime = {
		name = "MENU_EXTRA_TIME",
		hintText = {
			"MENU_EXTRA_TIME_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_30_SECONDS",
			"MENU_1_MINUTE",
			"MENU_X_MINUTES"
		},
		values = {
			0,
			0.5,
			1,
			1.5,
			2,
			2.5,
			3,
			3.5,
			4,
			4.5,
			5
		}
	},
	flagCaptureCondition = {
		name = "MENU_FLAG_CAPTURE_CONDITION",
		hintText = {
			"MENU_FLAG_CAPTURE_CONDITION_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_FLAG_AT_BASE"
		},
		values = {
			0,
			1
		}
	},
	flagCanBeNeutralized = {
		setting = "flagCanBeNeutralized",
		name = "MENU_FLAG_CAN_BE_NEUTRALIZED",
		hintText = {
			"MENU_FLAG_CAN_BE_NEUTRALIZED_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	flagRespawnTime = {
		name = "MENU_FLAG_RESPAWN_TIME",
		hintText = {
			"MENU_FLAG_RESPAWN_TIME_HINT"
		},
		labels = {
			"MENU_1_SECOND",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_1_MINUTE"
		},
		values = {
			1,
			5,
			10,
			15,
			20,
			30,
			40,
			50,
			60
		}
	},
	forceRadar = {
		name = "MENU_RADAR_ALWAYS_ON",
		hintText = {
			"MENU_RADAR_ALWAYS_ON_HINT"
		},
		labels = {
			"MENU_NORMAL",
			"MENU_SWEEPING",
			"MENU_CONSTANT"
		},
		values = {
			0,
			1,
			2
		}
	},
	friendlyfiretype = {
		name = "MENU_FRIENDLYFIRE",
		hintText = {
			"MENU_FRIENDLYFIRE_HINT",
			"MENU_FRIENDLYFIRE_HINT",
			"MENU_FRIENDLYFIRE_REFLECT_HINT",
			"MENU_FRIENDLYFIRE_SHARED_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_ENABLED",
			"MPUI_REFLECT",
			"MENU_SHARED"
		},
		values = {
			0,
			1,
			2,
			3
		},
		shouldShow = CoDShared.IsGametypeTeamBased
	},
	gunSelection = {
		name = "MENU_GUNLIST",
		hintText = {
			"MENU_GUNLIST_NORMAL_HINT",
			"MENU_GUNLIST_CQB_HINT",
			"MENU_GUNLIST_MARKSMAN_HINT",
			"MENU_GUNLIST_RANDOM_HINT"
		},
		labels = {
			"MENU_GUNLIST_NORMAL",
			"MENU_GUNLIST_CQB",
			"MENU_GUNLIST_MARKSMAN",
			"MENU_GUNLIST_RANDOM"
		},
		values = {
			0,
			1,
			2,
			3
		}
	},
	gunSelection_sas = {
		setting = "gunSelection",
		name = "MENU_SETBACK_WEAPON",
		hintText = {
			"MENU_SETBACK_WEAPON_HINT"
		},
		labels = {
			"MENU_NONE",
			"WEAPON_HATCHET",
			"WEAPON_CROSSBOW",
			"WEAPON_KNIFE_BALLISTIC"
		},
		values = {
			0,
			1,
			2,
			3
		}
	},
	hardcoreMode = {
		name = "MENU_RULES_HARDCORE",
		hintText = {
			"MENU_RULES_HARDCORE_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues,
		callback = HardcoreSettingChanged
	},
	idleFlagResetTime = {
		name = "MENU_FLAG_RETURN_TIME",
		hintText = {
			"MENU_FLAG_RETURN_TIME_HINT"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_1_MINUTE"
		},
		values = {
			0,
			5,
			10,
			15,
			20,
			30,
			40,
			50,
			60
		}
	},
	incrementalSpawnDelay = {
		name = "MENU_INCREMENTAL_SPAWN_DELAY",
		hintText = {
			"MENU_INCREMENTAL_SPAWN_DELAY_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_1_SECOND",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_1_MINUTE"
		},
		values = {
			0,
			1,
			2,
			2.5,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			15,
			30,
			40,
			50,
			60
		}
	},
	idleFlagResetTime_ball = {
		setting = "idleFlagResetTime",
		name = "MENU_BALL_RETURN_TIME",
		hintText = {
			"MENU_BALL_RETURN_TIME_HINT"
		},
		labels = {
			"MENU_INSTANT",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_1_MINUTE"
		},
		values = {
			0,
			5,
			10,
			15,
			30,
			45,
			60
		}
	},
	killEventScoreMultiplier = {
		name = "MENU_SCORE_MULTIPLIER",
		hintText = {
			"MENU_SCORE_MULTIPLIER_HINT"
		},
		values = {
			1,
			1.5,
			2,
			2.5,
			3,
			3.5,
			4,
			4.5,
			5
		}
	},
	loadoutKillstreaksEnabled = {
		name = "MENU_SCORESTREAKS",
		hintText = {
			"MENU_SCORESTREAKS_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues,
		shouldShow = f0_local3
	},
	killstreaksGiveGameScore = {
		name = "MENU_SCORESTREAK_TEAM_SCORING",
		hintText = {
			"MENU_SCORESTREAK_TEAM_SCORING_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	maxAllocation = {
		name = "MENU_MAX_ALLOCATION",
		hintText = {
			"MENU_MAX_ALLOCATION_HINT"
		},
		values = {
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			11,
			12,
			13,
			14,
			15,
			16,
			17
		},
		shouldShow = f0_local4
	},
	multiBomb = {
		name = "MENU_MULTI_BOMB",
		hintText = {
			"MENU_MULTI_BOMB_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	objectiveSpawnTime = {
		name = "MENU_OBJECTIVE_SPAWN_TIME",
		hintText = {
			"MENU_OBJECTIVE_SPAWN_TIME_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_1_MINUTE"
		},
		values = {
			0,
			5,
			10,
			15,
			30,
			45,
			60
		}
	},
	onlyHeadshots = {
		name = "MENU_HEADSHOTSONLY",
		hintText = {
			"MENU_HEADSHOTSONLY_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	OvertimetimeLimit = {
		name = "MENU_OVERTIME_TIME_LIMIT1",
		hintText = {
			"MENU_OVERTIME_TIME_LIMIT_HINT"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_1_MINUTE",
			"MENU_X_MINUTES"
		},
		values = {
			0,
			1,
			1.5,
			2,
			2.5,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			11,
			12,
			13,
			14,
			15,
			20,
			30
		}
	},
	plantTime = {
		name = "MENU_PLANT_TIME",
		hintText = {
			"MENU_PLANT_TIME_HINT"
		},
		labels = {
			"MENU_1_SECOND",
			"MENU_X_SECONDS"
		},
		values = {
			1,
			2.5,
			3,
			3.5,
			4,
			4.5,
			5,
			5.5,
			6,
			6.5,
			7,
			7.5,
			8,
			8.5,
			9,
			9.5,
			10
		}
	},
	playerForceRespawn = {
		name = "MENU_FORCE_RESPAWN",
		hintText = {
			"MENU_FORCE_RESPAWN_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	playerHealthRegenTime = {
		name = "MENU_HEALTH_REGENERATION",
		hintText = {
			"MENU_HEALTH_REGENERATION_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_SLOW",
			"MENU_NORMAL",
			"MENU_FAST"
		},
		values = {
			0,
			10,
			5,
			2
		}
	},
	playerMaxHealth = {
		name = "CGAME_HEALTH",
		hintText = {
			"MENU_HEALTH_HINT"
		},
		labels = {
			"MENU_HEALTH_X_PERCENT"
		},
		values = {
			30,
			35,
			40,
			45,
			50,
			55,
			60,
			65,
			70,
			75,
			80,
			85,
			90,
			95,
			100,
			110,
			120,
			125,
			130,
			140,
			150,
			160,
			170,
			175,
			180,
			190,
			200
		}
	},
	playerNumLives = {
		name = "MENU_NUMBER_OF_LIVES",
		hintText = {
			"MENU_NUMBER_OF_LIVES_HINT"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_1_LIFE",
			"MENU_X_LIVES"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			15,
			20,
			25
		}
	},
	playerRespawnDelay = {
		name = "MENU_RESPAWN_DELAY",
		hintText = {
			"MENU_RESPAWN_DELAY_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_1_SECOND",
			"MENU_X_SECONDS"
		},
		values = {
			0,
			1,
			2,
			2.5,
			3,
			4,
			5,
			6,
			7,
			7.5,
			8,
			9,
			10,
			15,
			20,
			30
		}
	},
	pointsForSurvivalBonus = {
		name = "MENU_POINTS_FOR_SURVIVAL_BONUS",
		hintText = {
			"MENU_POINTS_FOR_SURVIVAL_BONUS_HINT"
		},
		labels = {
			"MENU_X_POINTS",
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			10,
			15,
			20,
			25
		}
	},
	pointsPerPrimaryKill = {
		name = "MENU_POINTS_PER_PRIMARY_KILL",
		hintText = {
			"MENU_POINTS_PER_PRIMARY_KILL_HINT"
		},
		labels = {
			"MENU_X_POINTS",
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			10,
			25
		}
	},
	pointsPerSecondaryKill = {
		name = "MENU_POINTS_PER_SECONDARY_KILL",
		hintText = {
			"MENU_POINTS_PER_SECONDARY_KILL_HINT"
		},
		labels = {
			"MENU_X_POINTS",
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			10,
			25
		}
	},
	pointsPerPrimaryGrenadeKill = {
		name = "MENU_POINTS_PER_PRIMARY_GRENADE_KILL",
		hintText = {
			"MENU_POINTS_PER_PRIMARY_GRENADE_KILL_HINT"
		},
		labels = {
			"MENU_X_POINTS",
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			10,
			25
		}
	},
	pointsPerMeleeKill = {
		name = "MENU_POINTS_PER_MELEE_KILL",
		hintText = {
			"MENU_POINTS_PER_MELEE_KILL_HINT"
		},
		labels = {
			"MENU_X_POINTS",
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			10,
			15,
			20,
			25
		}
	},
	pointsPerWeaponKill = {
		name = "MENU_POINTS_PER_WEAPON_KILL",
		hintText = {
			"MENU_POINTS_PER_WEAPON_KILL_HINT"
		},
		labels = {
			"MENU_X_POINTS",
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			10,
			15,
			20,
			25
		}
	},
	prematchrequirement = {
		name = "MENU_PREMATCH_REQUIREMENT",
		hintText = {
			"MENU_PREMATCH_REQUIREMENT_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_1_PLAYER",
			"MENU_X_PLAYERS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9
		}
	},
	prematchrequirementtime = {
		name = "MENU_PREMATCH_REQUIREMENT_TIME",
		hintText = {
			"MENU_PREMATCH_REQUIREMENT_TIME_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_X_SECONDS"
		},
		values = {
			0,
			15,
			30,
			45,
			60
		}
	},
	prematchperiod = {
		name = "MENU_PREMATCH_TIMER",
		hintText = {
			"MENU_PREMATCH_TIMER_HINT"
		},
		labels = {
			"MENU_X_SECONDS"
		},
		values = {
			15,
			30,
			45,
			60
		}
	},
	preroundperiod = {
		name = "MENU_PREROUND_TIMER",
		hintText = {
			"MENU_PREROUND_TIMER_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_1_SECOND",
			"MENU_X_SECONDS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			12,
			15,
			18,
			20,
			25,
			30
		}
	},
	presetClassesPerTeam = {
		name = "MENU_PRESET_CLASSES_PER_TEAM",
		hintText = {
			"MENU_PRESET_CLASSES_PER_TEAM_HINT"
		},
		labels = {
			"MENU_GLOBAL",
			"MENU_PER_TEAM"
		},
		values = {
			0,
			1
		}
	},
	randomObjectiveLocations = {
		name = "MENU_RANDOM_OBJECTIVE_LOCATIONS",
		hintText = {
			"MENU_RANDOM_OBJECTIVE_LOCATIONS_HINT"
		},
		labels = {
			"MENU_LINEAR",
			"MENU_RANDOM_AFTER_FIRST",
			"MENU_RANDOM"
		},
		values = {
			0,
			2,
			1
		}
	},
	randomObjectiveLocations_koth = {
		setting = "randomObjectiveLocations",
		name = "MENU_RANDOM_OBJECTIVE_LOCATIONS",
		hintText = {
			"MENU_RANDOM_OBJECTIVE_LOCATIONS_HINT"
		},
		labels = {
			"MENU_LINEAR",
			"MENU_RANDOM_AFTER_FIRST"
		},
		values = {
			0,
			2
		}
	},
	rebootPlayers = {
		setting = "rebootPlayers",
		name = "MENU_REBOOT_PLAYERS",
		hintText = {
			"MENU_REBOOT_AUTO_HINT",
			"MENU_REBOOT_INTERACTIVE_HINT"
		},
		labels = {
			"MENU_AUTO",
			"MENU_INTERACTIVE"
		},
		values = {
			0,
			1
		}
	},
	rebootTime = {
		setting = "rebootTime",
		name = "MENU_REBOOT_TIME",
		hintText = {
			"MENU_REBOOT_TIME_HINT"
		},
		labels = {
			"MENU_X_SECONDS"
		},
		values = {
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			15,
			20,
			25,
			30,
			45,
			60
		}
	},
	robotSpeed = {
		setting = "robotSpeed",
		name = "MENU_ROBOT_SPEED",
		hintText = {
			"MENU_ROBOT_SPEED_HINT"
		},
		labels = {
			"MENU_SLOW",
			"MENU_NORMAL",
			"MENU_FAST"
		},
		values = {
			0,
			1,
			2
		}
	},
	roundLimit = {
		name = "MENU_ROUND_LIMIT1",
		hintText = {
			"MENU_ROUND_LIMIT_HINT"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_1_ROUND",
			"MENU_X_ROUNDS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9
		}
	},
	cumulativeRoundScores = {
		name = "MENU_WIN_RULE",
		hintText = {
			"MENU_TOTAL_FLAG_CAPS_HINT",
			"MENU_CTF_ROUND_WINS_HINT"
		},
		labels = {
			"MENU_TOTAL_FLAG_CAPTURES",
			"MENU_ROUND_WINS"
		},
		values = CoD.GameOptions.EnabledDisabledValues,
		callback = f0_local0
	},
	roundswitch = {
		name = "MENU_ROUND_SWITCH",
		hintText = {
			"MENU_ROUND_SWITCH_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_EVERY_ROUND",
			"MENU_EVERY_X_ROUNDS"
		},
		values = {
			0,
			1,
			2,
			3,
			4
		}
	},
	roundStartExplosiveDelay = {
		name = "MENU_EXPLOSIVE_DELAY",
		hintText = {
			"MENU_EXPLOSIVE_DELAY_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_1_SECOND",
			"MENU_X_SECONDS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			12,
			15,
			20,
			25,
			30,
			45,
			60
		}
	},
	roundStartKillstreakDelay = {
		name = "MENU_KILLSTREAK_DELAY",
		hintText = {
			"MENU_KILLSTREAK_DELAY_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_1_SECOND",
			"MENU_X_SECONDS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			12,
			15,
			20,
			25,
			30,
			45,
			60
		}
	},
	roundWinLimit = {
		name = "MENU_ROUND_WIN_LIMIT",
		hintText = {
			"MENU_ROUND_WIN_LIMIT_HINT"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_X_ROUNDS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9
		}
	},
	roundWinLimit_ctf = {
		setting = "roundWinLimit",
		name = "MENU_ROUND_WIN_LIMIT",
		hintText = {
			"MENU_ROUND_WIN_LIMIT_HINT"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_1_ROUND",
			"MENU_X_ROUNDS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9
		},
		shouldShow = f0_local2
	},
	roundWinLimit_dm = {
		setting = "roundWinLimit",
		name = "MENU_ROUND_WIN_LIMIT",
		hintText = {
			"MENU_ROUND_WIN_LIMIT_HINT_DM"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_1_ROUND",
			"MENU_X_ROUNDS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9
		},
		shouldShow = f0_local2
	},
	roundWinLimit_escort = {
		setting = "roundWinLimit",
		name = "MENU_ROUND_WIN_LIMIT",
		hintText = {
			"MENU_ROUND_WIN_LIMIT_HINT"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_1_ROUND",
			"MENU_X_ROUNDS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			12,
			24
		}
	},
	scoreLimit = {
		name = "MENU_SCORE_LIMIT",
		hintText = {
			"MENU_SCORE_LIMIT_OPTION"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_X_POINTS"
		},
		values = {
			0,
			5,
			10,
			15,
			20,
			25,
			30,
			35,
			40,
			45,
			50,
			55,
			60,
			65,
			70,
			75,
			80,
			85,
			90,
			95,
			100,
			125,
			150,
			175,
			200,
			225,
			250,
			275,
			300,
			350,
			400,
			450,
			500,
			550,
			600,
			650,
			700,
			750,
			800,
			850,
			900,
			950,
			1000
		}
	},
	scoreLimit_sd_dem = {
		setting = "scoreLimit",
		name = "MENU_ROUND_WIN_LIMIT",
		hintText = {
			"MENU_ROUND_WIN_LIMIT_HINT"
		},
		labels = {
			"MENU_1_ROUND",
			"MENU_X_ROUNDS"
		},
		values = {
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			12,
			24
		}
	},
	scoreLimit_dom = {
		setting = "scoreLimit",
		name = "MENU_SCORE_LIMIT",
		hintText = {
			"MENU_SCORE_LIMIT_OPTION"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_X_POINTS"
		},
		values = {
			0,
			50,
			100,
			110,
			120,
			130,
			140,
			150,
			200,
			250,
			300,
			350,
			400,
			450,
			500,
			750,
			1000,
			1500,
			2000
		}
	},
	scoreLimit_ctf = {
		setting = "scoreLimit",
		name = "MENU_CAPTURE_LIMIT",
		hintText = {
			"MENU_CAPTURE_LIMIT_HINT"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_1_FLAG",
			"MENU_X_FLAGS"
		},
		values = {
			0,
			1,
			3,
			5,
			10,
			15,
			30
		},
		shouldShow = f0_local1
	},
	scoreLimit_ctfRound = {
		setting = "scoreLimit",
		name = "MENU_CAPTURE_LIMIT",
		hintText = {
			"MENU_ROUND_CAPTURE_LIMIT_HINT"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_1_FLAG",
			"MENU_X_FLAGS"
		},
		values = {
			0,
			1,
			3,
			5,
			10,
			15,
			30
		},
		shouldShow = f0_local2
	},
	scoreResetOnDeath = {
		name = "MENU_SCORE_RESET_ON_DEATH",
		hintText = {
			"MENU_SCORE_RESET_ON_DEATH_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	roundScoreLimit = {
		name = "MENU_ROUND_SCORE_LIMIT",
		hintText = {
			"MENU_ROUND_SCORE_LIMIT_OPTION"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_X_POINTS"
		},
		values = {
			0,
			5,
			10,
			15,
			20,
			25,
			30,
			35,
			40,
			45,
			50,
			55,
			60,
			65,
			70,
			75,
			80,
			85,
			90,
			95,
			100,
			150,
			200,
			250,
			300,
			350,
			400,
			450,
			500,
			550,
			600,
			650,
			700,
			750,
			800,
			850,
			900,
			950,
			1000
		}
	},
	roundScoreLimit_dom = {
		setting = "scoreLimit",
		name = "MENU_ROUND_SCORE_LIMIT",
		hintText = {
			"MENU_ROUND_SCORE_LIMIT_OPTION"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_X_POINTS"
		},
		values = {
			0,
			25,
			50,
			55,
			60,
			65,
			70,
			75,
			100,
			125,
			150,
			175,
			200,
			225,
			250,
			375,
			500,
			750,
			1000
		}
	},
	scorePerPlayer = {
		name = "MENU_SCORING",
		hintText = {
			"MENU_SCORING_HINT"
		},
		labels = {
			"MENU_CONSTANT",
			"MENU_PLAYER_ADDITIVE"
		},
		values = {
			0,
			1
		},
		shouldShow = f0_local1
	},
	setbacks = {
		name = "MENU_SETBACKS",
		hintText = {
			"MENU_SETBACKS_HINT"
		},
		labels = {
			"MENU_X_WEAPONS",
			"MENU_X_WEAPON",
			"MENU_X_WEAPONS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10
		}
	},
	setbacks_sas = {
		setting = "setbacks",
		name = "MENU_SETBACKS",
		hintText = {
			"MENU_SETBACKS_SAS_HINT"
		},
		labels = {
			"MENU_ALL_POINTS",
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			10,
			15,
			25,
			50
		}
	},
	shutdownDamage = {
		setting = "shutdownDamage",
		name = "MENU_SHUTDOWN_DAMAGE",
		hintText = {
			"MENU_SHUTDOWN_DAMAGE_HINT"
		},
		labels = {
			"MENU_INVULNERABLE",
			"MENU_LOW",
			"MENU_NORMAL",
			"MENU_HIGH"
		},
		values = {
			0,
			1,
			2,
			3
		}
	},
	silentPlant = {
		name = "MENU_SILENT_PLANT",
		hintText = {
			"MENU_SILENT_PLANT_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	spawnsuicidepenalty = {
		name = "MENU_SPAWN_SUICIDE_PENALTY",
		hintText = {
			"MENU_SPAWN_SUICIDE_PENALTY_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_1_SECOND",
			"MENU_X_SECONDS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			12,
			14,
			15,
			16,
			18,
			20
		}
	},
	spawnteamkilledpenalty = {
		name = "MENU_SPAWN_TEAMKILLED_PENALTY",
		hintText = {
			"MENU_SPAWN_TEAMKILLED_PENALTY_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_X_SECONDS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			12,
			14,
			15,
			16,
			18,
			20
		}
	},
	cleanDepositOnlineTime = {
		name = "MENU_CLEAN_DEPOSIT_ONLINE_TIME",
		hintText = {
			"MENU_CLEAN_DEPOSIT_ONLINE_TIME_HINT"
		},
		labels = {
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_X_SECONDS",
			"MENU_1_MINUTE",
			"MENU_1_5_MINUTES",
			"MENU_2_MINUTES"
		},
		values = {
			15,
			30,
			45,
			60,
			90,
			120
		}
	},
	cleanDepositRotation = {
		name = "MENU_CLEAN_DEPOSIT_ROTATION",
		hintText = {
			"MENU_CLEAN_DEPOSIT_ROTATION_HINT"
		},
		labels = {
			"MENU_IN_ORDER",
			"MENU_FIXED_START_RANDOM",
			"MENU_RANDOM"
		},
		values = {
			0,
			1,
			2
		}
	},
	teamKillPunishCount = {
		name = "MENU_TEAMKILL_KICK",
		hintText = {
			"MENU_TEAMKILL_KICK_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_1_KILL",
			"MENU_X_KILLS"
		},
		values = {
			0,
			1,
			2,
			3,
			4
		},
		shouldShow = CoDShared.IsGametypeTeamBased
	},
	teamNumLives = {
		name = "MENU_NUMBER_OF_TEAM_LIVES",
		hintText = {
			"MENU_NUMBER_OF_TEAM_LIVES_HINT"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_1_LIFE",
			"MENU_X_LIVES"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			15,
			20,
			25
		}
	},
	teamScorePerDeath = {
		name = "MENU_TEAM_SCORE_PER_DEATH",
		hintText = {
			"MENU_TEAM_SCORE_PER_DEATH_HINT"
		},
		labels = {
			"MENU_X_POINTS",
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			10,
			15,
			20,
			25
		}
	},
	teamScorePerDeath_dm = {
		setting = "teamScorePerDeath",
		name = "MENU_TEAM_SCORE_PER_DEATH",
		hintText = {
			"MENU_TEAM_SCORE_PER_DEATH_HINT_DM"
		},
		labels = {
			"MENU_X_POINTS",
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			10,
			15,
			20,
			25
		}
	},
	teamScorePerHeadshot = {
		name = "MENU_TEAM_SCORE_PER_HEADSHOT",
		hintText = {
			"MENU_TEAM_SCORE_PER_HEADSHOT_HINT"
		},
		labels = {
			"MENU_X_POINTS",
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			10,
			15,
			20,
			25
		}
	},
	teamScorePerKill = {
		name = "MENU_TEAM_SCORE_PER_KILL",
		hintText = {
			"MENU_TEAM_SCORE_PER_KILL_HINT"
		},
		labels = {
			"MENU_X_POINTS",
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			10,
			15,
			20,
			25
		}
	},
	teamScorePerKillConfirmed = {
		name = "MENU_TEAM_SCORE_PER_KILL_CONFIRMED",
		hintText = {
			"MENU_TEAM_SCORE_PER_KILL_CONFIRMED_HINT"
		},
		labels = {
			"MENU_X_POINTS",
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			10,
			15,
			20,
			25
		}
	},
	teamScorePerKillDenied = {
		name = "MENU_TEAM_SCORE_PER_KILL_DENIED",
		hintText = {
			"MENU_TEAM_SCORE_PER_KILL_DENIED_HINT"
		},
		labels = {
			"MENU_X_POINTS",
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			10,
			15,
			20,
			25
		}
	},
	teamScorePerCleanDeposit = {
		name = "MENU_TEAM_SCORE_PER_CLEAN_DEPOSIT",
		hintText = {
			"MENU_TEAM_SCORE_PER_CLEAN_DEPOSIT_HINT"
		},
		labels = {
			"MENU_X_POINTS",
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			0,
			1,
			2,
			3,
			4,
			5,
			10,
			15,
			20,
			25
		}
	},
	throwScore = {
		setting = "throwScore",
		name = "MENU_THROW_SCORE",
		hintText = {
			"MENU_THROW_SCORE_HINT"
		},
		labels = {
			"MENU_1_POINT",
			"MENU_X_POINTS"
		},
		values = {
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8,
			9
		}
	},
	timeLimit = {
		name = "MENU_TIME_LIMIT1",
		hintText = {
			"MENU_TIME_LIMIT_HINT"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_1_MINUTE",
			"MENU_X_MINUTES"
		},
		values = {
			0,
			1,
			1.5,
			2,
			2.5,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			11,
			12,
			13,
			14,
			15,
			20,
			30
		}
	},
	timeLimit_dom = {
		setting = "timeLimit",
		name = "MENU_ROUND_TIME_LIMIT1",
		hintText = {
			"MENU_ROUND_TIME_LIMIT_HINT"
		},
		labels = {
			"MENU_UNLIMITED",
			"MENU_1_MINUTE",
			"MENU_X_MINUTES"
		},
		values = {
			0,
			1,
			1.5,
			2,
			2.5,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			11,
			12,
			13,
			14,
			15,
			20,
			30
		}
	},
	timePausesWhenInZone = {
		name = "MENU_TIME_PAUSE",
		hintText = {
			"MENU_TIME_PAUSE_DESC"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	touchReturn = {
		setting = "defuseTime",
		name = "MENU_TOUCH_RETURN",
		hintText = {
			"MENU_TOUCH_RETURN_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_INSTANT",
			"MENU_X_SECONDS",
			"MENU_1_SECOND",
			"MENU_X_SECONDS"
		},
		values = {
			63,
			0,
			0.5,
			1,
			1.5,
			2,
			2.5,
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10
		}
	},
	voipKillersHearVictim = {
		name = "MENU_VOIP_KILLERS_HEAR_VICTIM",
		hintText = {
			"MENU_VOIP_KILLERS_HEAR_VICTIM_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	useEmblemInsteadOfFactionIcon = {
		name = "MENU_EMBLEMS_INSTEAD_OF_FACTIONS",
		hintText = {
			"MENU_EMBLEMS_INSTEAD_OF_FACTIONS_HINT"
		},
		labels = CoD.GameOptions.EnabledDisabledLabels,
		values = CoD.GameOptions.EnabledDisabledValues
	},
	waveRespawnDelay = {
		name = "MENU_WAVE_SPAWN_DELAY",
		hintText = {
			"MENU_WAVE_SPAWN_DELAY_HINT"
		},
		labels = {
			"MENU_DISABLED",
			"MENU_X_SECONDS"
		},
		values = {
			0,
			2.5,
			5,
			7.5,
			10,
			15,
			20,
			30
		}
	},
	weaponTimer = {
		name = "MENU_SHRP_WEAPON_TIMER",
		hintText = {
			"MENU_SHRP_WEAPON_TIMER_HINT"
		},
		labels = {
			"MENU_X_SECONDS"
		},
		values = {
			10,
			15,
			20,
			25,
			30,
			35,
			40,
			45,
			50,
			55,
			60,
			90,
			120
		}
	},
	weaponCount = {
		name = "MENU_SHRP_WEAPON_NUMBER",
		hintText = {
			"MENU_SHRP_WEAPON_NUMBER_HINT"
		},
		labels = {
			5,
			6,
			7,
			8,
			9,
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
			20
		},
		values = {
			5,
			6,
			7,
			8,
			9,
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
			20
		}
	}
}

for k, v in pairs(CoD.zbr_gametype_settings) do
	CoD.GameOptions.GameSettings[k] = v
end

CoD.GameOptions.GlobalSettings = {
	"teamAssignment",
	"allowInGameTeamChange",
	"allowSpectating",
	"disableThirdPersonSpectating",
	"allowMapScripting",
	"voipKillersHearVictim",
	"allowBattleChatter",
	"allowAnnouncer"
}
CoD.GameOptions.GeneralSettings = {
	-- "prematchrequirement",
	-- "prematchrequirementtime",
	-- "prematchperiod",
	-- "preroundperiod",
	-- "forceRadar",
	-- "roundStartExplosiveDelay",
	-- "allowKillcam",
	-- "roundStartKillstreakDelay",
	-- "killEventScoreMultiplier",
	-- "disableVehicleSpawners"
	"super_sprinters_enabled",
	"gm_start_round",
	"player_midround_respawn_delay",
	"starting_points_cm",
	"disable_gums_cm"
}
CoD.GameOptions.HealthAndDamageSettings = {
	-- "playerMaxHealth",
	-- "playerHealthRegenTime",
	-- "friendlyfiretype",
	-- "teamKillPunishCount",
	-- "onlyHeadshots",
	-- "allowhitmarkers"
	"pvp_damage_scalar",
	"outgoing_pve_damage",
	"incoming_pve_damage",
	"dmg_convt_efficiency",
	"headshots_only"
}
CoD.GameOptions.SpawnSettings = {
	"playerRespawnDelay",
	"incrementalSpawnDelay",
	"playerForceRespawn",
	"waveRespawnDelay",
	"spawnsuicidepenalty",
	"spawnteamkilledpenalty"
}
CoD.GameOptions.CustomClassSettings = {
	"disableCAC",
	"maxAllocation"
}
CoD.GameOptions.PresetClassSettings = {
	"presetClassesPerTeam"
}
CoD.GameOptions.TopLevelGametypeSettings = {
	ball = {
		"timeLimit_dom",
		"roundScoreLimit"
	},
	clean = {
		"timeLimit",
		"scoreLimit"
	},
	conf = {
		"timeLimit",
		"scoreLimit"
	},
	ctf = {
		"cumulativeRoundScores",
		"timeLimit"
	},
	dem = {
		"timeLimit",
		"scoreLimit_sd_dem"
	},
	dm = {
		"timeLimit",
		"scoreLimit"
	},
	dom = {
		"timeLimit_dom",
		"roundScoreLimit"
	},
	escort = {
		"timeLimit",
		"roundWinLimit_escort"
	},
	gun = {
		"timeLimit"
	},
	hack = {
		"timeLimit",
		"scoreLimit"
	},
	hq = {
		"timeLimit",
		"scoreLimit"
	},
	infect = {
		"timeLimit"
	},
	koth = {
		"timeLimit",
		"scoreLimit"
	},
	oneflag = {
		"cumulativeRoundScores",
		"timeLimit"
	},
	prop = {
		"timeLimit"
	},
	sas = {
		"timeLimit",
		"scoreLimit"
	},
	sd = {
		"timeLimit",
		"scoreLimit_sd_dem"
	},
	shrp = {
		"scoreLimit"
	},
	sniperonly = {
		"timeLimit",
		"scoreLimit"
	},
	tdm = {
		"timeLimit",
		"scoreLimit"
	},
    zbr = {
		"zbr_teamsize",
		"win_numpoints",
		"objective_win_time",
		"sudden_death_mode",
		"sudden_death_rounds",
		"sudden_death_time"
	},
	zhunt = {
		
	}
}
CoD.GameOptions.GlobalTopLevelGametypeSettings = {
	"hardcoreMode"
}
CoD.GameOptions.SubLevelGametypeSettings = {
    zbr = {
		"no_wager_totems"
	},
	zhunt = {

	},
	ball = {
		"roundLimit",
		"carrierArmor",
		"carryScore",
		"throwScore",
		"enemyCarrierVisible",
		"idleFlagResetTime_ball",
		"ballCount"
	},
	clean = {
		"teamScorePerCleanDeposit",
		"cleanDepositRotation",
		"cleanDepositOnlineTime"
	},
	conf = {
		"teamScorePerKillConfirmed",
		"teamScorePerKillDenied",
		"teamScorePerKill",
		"playerNumLives",
		"teamNumLives"
	},
	ctf = {
		"scoreLimit_ctfRound",
		"roundLimit",
		"roundWinLimit_ctf",
		"enemyCarrierVisible",
		"idleFlagResetTime",
		"flagCaptureCondition",
		"captureTime_ctf",
		"touchReturn"
	},
	dem = {
		"bombTimer",
		"plantTime",
		"defuseTime",
		"extraTime",
		"OvertimetimeLimit",
		"silentPlant",
		"droppedTagRespawn"
	},
	dom = {
		"roundLimit",
		"captureTime",
		"flagCanBeNeutralized",
		"roundswitch"
	},
	dm = {
		"teamScorePerKill",
		"teamScorePerDeath_dm",
		"teamScorePerHeadshot",
		"playerNumLives",
		"roundLimit",
		"roundWinLimit_dm",
		"roundScoreLimit",
		"killstreaksGiveGameScore"
	},
	escort = {
		"roundLimit",
		"shutdownDamage",
		"bootTime",
		"rebootTime",
		"rebootPlayers"
	},
	gun = {
		"setbacks",
		"gunSelection"
	},
	infect = {
		"roundLimit"
	},
	koth = {
		"autoDestroyTime",
		"captureTime_koth",
		"objectiveSpawnTime",
		"randomObjectiveLocations_koth",
		"scorePerPlayer",
		"timePausesWhenInZone"
	},
	prop = {
		"roundLimit"
	},
	sas = {
		"gunSelection_sas",
		"setbacks_sas",
		"pointsPerPrimaryKill",
		"pointsPerSecondaryKill",
		"pointsPerPrimaryGrenadeKill",
		"pointsPerMeleeKill"
	},
	sd = {
		"bombTimer",
		"plantTime",
		"defuseTime",
		"multiBomb",
		"roundswitch",
		"silentPlant",
		"droppedTagRespawn",
		"playerNumLives"
	},
	sniperonly = {
		"teamScorePerKill",
		"teamScorePerDeath",
		"teamScorePerHeadshot",
		"playerNumLives",
		"roundLimit",
		"roundWinLimit",
		"droppedTagRespawn",
		"roundScoreLimit"
	},
	tdm = {
		"teamScorePerKill",
		"teamScorePerDeath",
		"teamScorePerHeadshot",
		"playerNumLives",
		"roundLimit",
		"roundWinLimit",
		"droppedTagRespawn",
		"roundScoreLimit",
		"killstreaksGiveGameScore"
	}
}
CoD.GameOptions.ShowStarForGametypeSettings = function ( f7_arg0, f7_arg1 )
	for f7_local4, f7_local3 in ipairs( f7_arg1 ) do
		local f7_local5 = CoD.GameOptions.GameSettings[f7_local3]
		if not f7_local5.shouldShow or f7_local5.shouldShow() then
			if f7_local5.setting then
				f7_local3 = f7_local5.setting
			end
			if not Engine.IsGametypeSettingDefault( f7_local3 ) then
				f7_arg0:showStarIcon( true )
				return true
			end
		end
	end
	f7_arg0:showStarIcon( false )
	return false
end

CoD.GameOptions.Button_AddChoices = function ( f8_arg0, f8_arg1, f8_arg2, f8_arg3 )
	if f8_arg2 == nil or #f8_arg2 == 0 then
		return 
	end
	for f8_local0 = 1, #f8_arg2, 1 do
		f8_arg1:addChoice( f8_arg0, Engine.Localize( f8_arg2[f8_local0] ), f8_arg3[f8_local0] )
	end
end

CoD.GameOptions.AddSelectorButtons = function ( f9_arg0, f9_arg1, f9_arg2, f9_arg3 )
	if f9_arg2 == nil or #f9_arg2 == 0 then
		return 0
	end
	for f9_local0 = 1, #f9_arg2, 1 do
		local f9_local3 = nil
		if f9_arg2[f9_local0].hintText ~= nil then
			f9_local3 = f9_arg0.buttonList:addGametypeSettingLeftRightSelector( f9_arg0, f9_arg1, Engine.Localize( f9_arg2[f9_local0].label ), f9_arg2[f9_local0].settingName, Engine.Localize( f9_arg2[f9_local0].hintText ) )
		else
			f9_local3 = f9_arg0.buttonList:addGametypeSettingLeftRightSelector( f9_arg0, f9_arg1, Engine.Localize( f9_arg2[f9_local0].label ), f9_arg2[f9_local0].settingName )
		end
		CoD.GameOptions.Button_AddChoices( f9_arg1, f9_local3, f9_arg2[f9_local0].strings, f9_arg2[f9_local0].values )
		if f9_arg3 == false then
			f9_local3:disableCycling()
		end
	end
	return #f9_arg2
end

CoD.GameOptions.Button_DemoRecording_AddChoices = function ( f10_arg0, f10_arg1 )
	CoD.GameOptions.Button_AddChoices( f10_arg1, f10_arg0, {
		"MENU_DISABLED_CAPS",
		"MENU_ENABLED_CAPS"
	}, {
		0,
		1
	} )
end

CoD.GameOptions.Button_EnabledDisabled_AddChoices = function ( f11_arg0, f11_arg1, f11_arg2, f11_arg3 )
	local f11_local0 = {
		"MENU_DISABLED_CAPS",
		"MENU_ENABLED_CAPS"
	}
	local f11_local1 = {
		0,
		1
	}
	local f11_local2 = f11_arg0.buttonList:addGametypeSettingLeftRightSelector( f11_arg0, f11_arg1, Engine.Localize( f11_arg2 ), f11_arg3 )
	CoD.GameOptions.Button_AddChoices( f11_arg1, f11_local2, f11_local0, f11_local1 )
	return f11_local2
end

CoD.GameOptions.AreAnyAttachmentsRestricted = function ()
	local f12_local0 = 1
	while true do
		if Engine.GetAttachmentNameByIndex( f12_local0 ) == "" then
			
		elseif Engine.GetAttachmentAllocationCost( f12_local0 ) >= 0 then
			return true
		end
		f12_local0 = f12_local0 + 1
	end
end

CoD.GameOptionsMenu.New = function ( f13_arg0, f13_arg1 )
	local f13_local0 = CoD.Menu.New( f13_arg1 )
	f13_local0:setClass( CoD.GameOptionsMenu )
	f13_local0:setOwner( f13_arg0 )
	f13_local0:addLargePopupBackground()
	f13_local0:addSelectButton()
	f13_local0.buttonModel = Engine.CreateModel( Engine.GetModelForController( f13_arg0 ), f13_arg1 .. ".buttonPrompts" )
	f13_local0:AddButtonCallbackFunction( f13_local0, f13_arg0, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, nil, function ( f14_arg0, f14_arg1, f14_arg2, f14_arg3 )
		GoBack( f13_local0, f14_arg2 )
	end, function ( f15_arg0, f15_arg1, f15_arg2 )
		CoD.Menu.SetButtonLabel( f15_arg1, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, "MENU_BACK" )
		return true
	end, false )
	CoD.Menu.AddNavigationHandler( f13_local0, f13_local0, f13_arg0 )
	local f13_local1 = 325
	f13_local0.infoPane = LUI.UIElement.new()
	f13_local0.infoPane:setLeftRight( false, true, -f13_local1 + 45, 0 )
	f13_local0.infoPane:setTopBottom( true, true, CoD.Menu.TitleHeight, 0 )
	f13_local0:addElement( f13_local0.infoPane )
	f13_local0.infoPaneTitle = LUI.UIText.new()
	f13_local0.infoPaneTitle:setLeftRight( true, false, 0, 0 )
	f13_local0.infoPaneTitle:setTopBottom( true, false, 0, CoD.textSize.Condensed )
	f13_local0.infoPaneTitle:setRGB( CoD.offWhite.r, CoD.offWhite.g, CoD.offWhite.b )
	f13_local0.infoPaneTitle:setTTF( "fonts/escom.ttf" )
	f13_local0.infoPane:addElement( f13_local0.infoPaneTitle )
	f13_local0.infoPaneDefaultText = LUI.UIText.new()
	f13_local0.infoPaneDefaultText:setLeftRight( true, false, 0, 0 )
	f13_local0.infoPaneDefaultText:setTopBottom( true, false, 30, 30 + CoD.textSize.Default )
	f13_local0.infoPaneDefaultText:setRGB( CoD.offWhite.r, CoD.offWhite.g, CoD.offWhite.b )
	f13_local0.infoPaneDefaultText:setTTF( "fonts/escom.ttf" )
	f13_local0.infoPane:addElement( f13_local0.infoPaneDefaultText )
	f13_local0.infoPaneDescription = LUI.UIText.new()
	f13_local0.infoPaneDescription:setupUITextUncached()
	f13_local0.infoPaneDescription:setLeftRight( true, true, 0, 0 )
	f13_local0.infoPaneDescription:setTopBottom( true, false, 70, 70 + CoD.textSize.Default )
	f13_local0.infoPaneDescription:setAlignment( LUI.Alignment.Left )
	f13_local0.infoPaneDescription:setRGB( CoD.offWhite.r, CoD.offWhite.g, CoD.offWhite.b )
	f13_local0.infoPaneDescription:setTTF( "fonts/escom.ttf" )
	f13_local0.infoPane:addElement( f13_local0.infoPaneDescription )
	local f13_local2 = RegisterMaterial( Engine.StructTableLookupString( CoDShared.gametypesStructTable, "name", Dvar.ui_gametype:get(), "image" ) )
	local f13_local3 = f13_local1
	f13_local0.gametypeIcon = LUI.UIImage.new()
	f13_local0.gametypeIcon:setLeftRight( false, false, -f13_local3 / 2, f13_local3 / 2 )
	f13_local0.gametypeIcon:setTopBottom( false, false, -CoD.Menu.TitleHeight / 2 - f13_local3 / 2, -CoD.Menu.TitleHeight / 2 + f13_local3 / 2 )
	f13_local0.gametypeIcon:setImage( f13_local2 )
	f13_local0.gametypeIcon:setAlpha( 0.25 )
	f13_local0.infoPane:addElement( f13_local0.gametypeIcon )
	f13_local0.buttonList = CoD.ButtonList.new()
	f13_local0.buttonList:setLeftRight( true, false, 0, CoD.ButtonList.DefaultWidth )
	f13_local0.buttonList:setTopBottom( true, true, CoD.Menu.TitleHeight, 0 )
	f13_local0.buttonList.id = f13_local0.id .. "ButtonList"
	f13_local0.buttonList.hintText:close()
	f13_local0[f13_local0.buttonList.id] = f13_local0.buttonList
	f13_local0:addElement( f13_local0.buttonList )
	return f13_local0
end

CoD.GameOptionsMenu.addGametypeSetting = function ( f16_arg0, f16_arg1, f16_arg2, f16_arg3 )
	local f16_local0 = CoD.GameOptions.GameSettings[f16_arg2]
	if not f16_arg3 and f16_local0.shouldShow and not f16_local0.shouldShow() then
		return 
	elseif f16_local0.setting then
		f16_arg2 = f16_local0.setting
	end
	local f16_local1 = f16_local0.hintText
	if f16_local1 then
		f16_local1 = Engine.Localize( f16_local1 )
	end
	local f16_local2 = f16_arg0.buttonList:addGametypeSettingLeftRightSelector( f16_arg0, f16_arg1, Engine.Localize( f16_local0.name ), f16_arg2, f16_local1 )
	for f16_local7, f16_local8 in ipairs( f16_local0.values ) do
		local f16_local6 = f16_local8
		if f16_local0.labels then
			f16_local6 = f16_local0.labels[f16_local7]
			if not f16_local6 then
				f16_local6 = f16_local0.labels[#f16_local0.labels]
			end
			f16_local6 = Engine.Localize( f16_local6, f16_local8 )
		end
		f16_local2:addChoice( f16_arg1, f16_local6, f16_local8, nil, f16_local0.callback )
	end
	return f16_local2
end

CoD.GameOptionsMenu.ButtonGainedFocus = function ( f17_arg0, f17_arg1 )
	local f17_local0 = f17_arg1.button
	if f17_local0.labelString and (f17_local0.hintText or f17_local0.m_settingName) then
		f17_arg0.infoPaneTitle:setText( f17_local0.labelString )
	else
		f17_arg0.infoPaneTitle:setText( "" )
	end
	local f17_local1 = ""
	if f17_local0.m_settingName then
		local f17_local2 = Engine.GetGametypeSetting( f17_local0.m_settingName, true )
		for f17_local6, f17_local7 in ipairs( f17_local0.m_choices ) do
			if f17_local7.params.value == f17_local2 then
				f17_local1 = Engine.Localize( "MENU_DEFAULT" ) .. ": " .. f17_local7.label
				break
			end
		end
	end
	f17_arg0.infoPaneDefaultText:setText( f17_local1 )
	if f17_local0.hintText then
		f17_arg0.infoPaneDescription:setText( f17_local0.hintText )
	else
		f17_arg0.infoPaneDescription:setText( "" )
	end
end

CoD.GameOptionsMenu.ButtonPromptBack = function ( f18_arg0, f18_arg1 )
	f18_arg0.buttonList:saveState()
	Engine.LobbyVM_CallFunc( "OnGametypeSettingsChange", {
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyModule = Enum.LobbyModule.LOBBY_MODULE_HOST
	} )
	CoD.Menu.ButtonPromptBack( f18_arg0, f18_arg1 )
end

CoD.GameOptionsMenu.RefreshSettings = function ( f19_arg0, f19_arg1 )
	f19_arg0:processEvent( {
		name = "button_update"
	} )
end

CoD.GameOptionsMenu:registerEventHandler( "button_gained_focus", CoD.GameOptionsMenu.ButtonGainedFocus )
CoD.GameOptionsMenu:registerEventHandler( "button_prompt_back", CoD.GameOptionsMenu.ButtonPromptBack )
CoD.GameOptionsMenu:registerEventHandler( "refresh_settings", CoD.GameOptionsMenu.RefreshSettings )
local f0_local5 = function ( f20_arg0, f20_arg1 )
	Engine.PartyHostClearUIState()
	CoD.GameOptionsMenu.ButtonPromptBack( f20_arg0, f20_arg1 )
end

