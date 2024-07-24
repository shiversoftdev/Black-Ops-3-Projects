-- Decompiled with CoDLUIDecompiler by JariK
EnableGlobals()

require("lua.Shared.LobbyData")
require("ui_mp.T6.Menus.CACUtility")
require("lua.shared.luareadonlytables")
require("ui.T7.Utility.LobbyUtility")
require("ui.t7.utility.challengesutility")
require("ui.t7.utility.arenautility")
require("ui.t7.utility.storeutility")
require("ui.T7.Utility.BlackMarketUtility")

local ship_maxplayers = CoD.zbr_max_players
local is_debug = CoD.zbr_is_debug
local is_dev = CoD.zbr_is_dev
local workshop_id = CoD.zbr_workshop_id

Engine.SetDvar("live_social_quickjoin_count", "0");
Engine.SetDvar("ui_disable_side_bet", "0");
Engine.SetDvar("arena_enableArenaChallenges", "1")
Engine.SetDvar("ui_freeDLC1", "1")
Engine.SetDvar("loot_limitedItemPromo_override_count", "999")

if Engine.DvarString(nil, "zbr_teams_size") == nil or Engine.DvarString(nil, "zbr_teams_size") == "" then
	Engine.SetDvar("zbr_teams_size", "1")
end

-- Function that we can use to safely call io and dll functions without crashing the client
local function SafeCall( FunctionRef )
	local ok, result = pcall( FunctionRef )
	
	if not ok and result then
	  Engine.ComError( Enum.errorCode.ERROR_UI, "SafeCall error: " .. result )
	elseif result then
	  return result
	end
  end

local function zbr_get_mode()

	if not CoD.zbr_loaded then return "" end

	if CoD.zbr_loaded and ZBR.IsDuos() then
		return "DUOS"
	end
	return "SOLOS"
end

local function string_starts(String,Start)
	return string.sub(String,1,string.len(Start))==Start
 end

local zbrshort = function ()
	return "^7[^2ZBR - ^1" .. zbr_get_mode() .. "^7] "
end

local zbrlong = "^7[^2Zombie Blood Rush^7]\n"

local _LiveSteamServer_GetServerName = Engine["LiveSteamServer_GetServerName"]
Engine["LiveSteamServer_GetServerName"] = function()
	local result = Engine.DvarString(nil, "live_steam_server_name")
	if not result then
		result = ""
	end
	if not string_starts(result, zbrshort()) then
		return result
	end
	return string.sub(result,string.len(zbrshort()),string.len(result))
end

local _LiveSteamServer_GetGameDescription = Engine["LiveSteamServer_GetGameDescription"]
Engine["LiveSteamServer_GetGameDescription"] = function()
	local result = Engine.DvarString(nil, "live_steam_server_description")
	if not result then
		result = ""
	end
	if not string_starts(result, zbrlong) then
		return result
	end
	return string.sub(result,string.len(zbrlong),string.len(result))
end

local function zbr_title(text)
	local result = text
	if not result then
		result = ""
	end
	if string_starts(result, zbrshort()) then
		return result
	end
	return zbrshort() .. result
end

local function zbr_description(text)
	local result = text
	if not result then
		result = ""
	end
	if string_starts(result, zbrlong) then
		return result
	end
	return zbrlong .. result
end

function ServerSettingsHandleKeyboardComplete( f1030_arg0, f1030_arg1, f1030_arg2, f1030_arg3 )
	if f1030_arg3.type == Enum.KeyboardType.KEYBOARD_TYPE_SERVER_NAME then
		Dvar.live_steam_server_name:set( zbr_title(f1030_arg3.input) )
	elseif f1030_arg3.type == Enum.KeyboardType.KEYBOARD_TYPE_SERVER_DESCRIPTION then
		Dvar.live_steam_server_description:set( zbr_description(f1030_arg3.input) )
	elseif f1030_arg3.type == Enum.KeyboardType.KEYBOARD_TYPE_SERVER_PASSWORD then
		Dvar.live_steam_server_password:set( f1030_arg3.input )
	end
end


local function update_status()

	local __dvar = Engine.DvarString(nil, "live_steam_server_name")
	if not __dvar then
		__dvar = ""
	end
	Dvar.live_steam_server_name:set(zbr_title(__dvar .. ""))
	__dvar = nil

	__dvar = Engine.DvarString(nil, "live_steam_server_description")
	if not __dvar then
		__dvar = ""
	end
	Dvar.live_steam_server_description:set(zbr_description(__dvar .. ""))
end

CoD.zbr_safe_call = SafeCall
CoD.zbr_update_status = update_status

-- e = OpenPopup(p, "zbrresetloadouts", c)
-- 	e.modalCallback = function(res)
-- 		if res == "yes" then
-- 			ZBR.ResetLoadouts()
-- 			CoD.OverlayUtility.ShowToast( "Invite", Engine.Localize( "Loadouts Reset" ), "", LuaEnums.INVITE_TOAST_POPUP_ICON )
-- 		end
-- 	end

local function OpenResetLoadoutsPopup(arg0, arg1, arg2, arg3, arg4)
	local registerVal7 = {}
	registerVal7.menuName = "SystemOverlay_Compact"
	registerVal7.title = "RESET LOADOUTS"
	registerVal7.description = "Resetting your loadouts will replace all your gum packs and weapon kits with the defaults for Zombie Blood Rush.\n\nContinue?"
	local function __FUNC_13131_()
		local function __FUNC_131FC_(arg0)
			local registerVal1 = {}
			local registerVal2 = {}
			local registerVal3 = {}
			registerVal3.displayText = "RESET"
			registerVal2.models = registerVal3
			registerVal3 = {}
			local function __FUNC_133FB_(arg0, arg1, arg2, arg3, arg4)
				ZBR.ResetLoadouts()
				CoD.OverlayUtility.ShowToast( "Invite", Engine.Localize( "Loadouts Reset" ), "", LuaEnums.INVITE_TOAST_POPUP_ACCEPTED_ICON )
				GoBack(arg4, arg2)
			end

			registerVal3.action = __FUNC_133FB_
			local registerVal4 = Dvar.zm_private_rankedmatch:exists()
			if registerVal4 then
				registerVal4 = Dvar.zm_private_rankedmatch:get()
				if registerVal4 ~= false then
				end
			end
			registerVal3.selectIndex = true
			registerVal2.properties = registerVal3
			registerVal3 = {}
			registerVal4 = {}
			registerVal4.displayText = "GO BACK"
			registerVal3.models = registerVal4
			registerVal4 = {}
			local function __FUNC_13580_(arg0, arg1, arg2, arg3, arg4)
				GoBack(arg4, arg2)
			end

			registerVal4.action = __FUNC_13580_
			registerVal4.selectIndex = true
			registerVal3.properties = registerVal4
			registerVal1 = {registerVal2, registerVal3}
			return registerVal1
		end

		local registerVal1 = DataSourceHelpers.ListSetup("ZBRResetLoadouts_List", __FUNC_131FC_, true, nil)
		DataSources.ZBRResetLoadouts_List = registerVal1
		return "ZBRResetLoadouts_List"
	end

	registerVal7.listDatasource = __FUNC_13131_
	registerVal7[CoD.OverlayUtility.GoBackPropertyName] = CoD.OverlayUtility.DefaultGoBack
	registerVal7.categoryType = CoD.OverlayUtility.OverlayTypes.GenericMessage
	CoD.OverlayUtility.AddSystemOverlay("ResetLoadoutsPopup", registerVal7)
	CoD.OverlayUtility.CreateOverlay(arg2, arg0, "ResetLoadoutsPopup")
end

local function OpenGameSettingsPopup(arg0, arg1, arg2, arg3, arg4)
	local registerVal7 = {}
	registerVal7.menuName = "SystemOverlay_Compact"
	registerVal7.title = "CONFIGURE GAME SETTINGS"
	registerVal7.description = "Choose the number of players on a team!"
	local function __FUNC_13131_()
		local function __FUNC_131FC_(arg0)
			local registerVal1 = {}
			local registerVal2 = {}
			local registerVal3 = {}
			registerVal3.displayText = "SOLOS"
			registerVal2.models = registerVal3
			registerVal3 = {}
			local function __FUNC_133FB_(arg0, arg1, arg2, arg3, arg4)
				SafeCall(CoD.zbr_enable_solos)
				update_status()
				GoBack(arg4, arg2)
			end

			registerVal3.action = __FUNC_133FB_
			local registerVal4 = Dvar.zm_private_rankedmatch:exists()
			if registerVal4 then
				registerVal4 = Dvar.zm_private_rankedmatch:get()
				if registerVal4 ~= false then
				end
			end
			registerVal3.selectIndex = true
			registerVal2.properties = registerVal3
			registerVal3 = {}
			registerVal4 = {}
			registerVal4.displayText = "DUOS"
			registerVal3.models = registerVal4
			registerVal4 = {}
			local function __FUNC_13580_(arg0, arg1, arg2, arg3, arg4)
				SafeCall(CoD.zbr_enable_duos)
				update_status()
				GoBack(arg4, arg2)
			end

			registerVal4.action = __FUNC_13580_
			local registerVal5 = Dvar.zm_private_rankedmatch:exists()
			if registerVal5 then
				registerVal5 = Dvar.zm_private_rankedmatch:get()
				if registerVal5 ~= true then
				end
			end
			registerVal4.selectIndex = true
			registerVal3.properties = registerVal4

			registerVal5 = {}
			registerVal4 = {}
			registerVal4.displayText = "TRIOS"
			registerVal5.models = registerVal4
			registerVal4 = {}
			local function __FUNC_13580_1(arg0, arg1, arg2, arg3, arg4)
				SafeCall(CoD.zbr_enable_trios)
				update_status()
				GoBack(arg4, arg2)
			end

			registerVal4.action = __FUNC_13580_1
			registerVal4.selectIndex = true
			registerVal5.properties = registerVal4

			registerVal6 = {}
			registerVal4 = {}
			registerVal4.displayText = "QUADS"
			registerVal6.models = registerVal4
			registerVal4 = {}
			local function __FUNC_13580_11(arg0, arg1, arg2, arg3, arg4)
				SafeCall(CoD.zbr_enable_quads)
				update_status()
				GoBack(arg4, arg2)
			end

			registerVal4.action = __FUNC_13580_11
			registerVal4.selectIndex = true
			registerVal6.properties = registerVal4

			registerVal1 = {registerVal2, registerVal3, registerVal6}
			return registerVal1
		end

		local registerVal1 = DataSourceHelpers.ListSetup("ChangeRankedSettingssPopup_List", __FUNC_131FC_, true, nil)
		DataSources.ChangeRankedSettingssPopup_List = registerVal1
		return "ChangeRankedSettingssPopup_List"
	end

	registerVal7.listDatasource = __FUNC_13131_
	registerVal7[CoD.OverlayUtility.GoBackPropertyName] = CoD.OverlayUtility.DefaultGoBack
	registerVal7.categoryType = CoD.OverlayUtility.OverlayTypes.GenericMessage
	CoD.OverlayUtility.AddSystemOverlay("ChangeRankedSettingsPopup", registerVal7)
	CoD.OverlayUtility.CreateOverlay(arg2, arg0, "ChangeRankedSettingsPopup")
end

-- Copies a given file to a new location
function CopyFile( old_path, new_path )
	local old_file = require("io").open( old_path, "rb" )
	local new_file = require("io").open( new_path, "wb" )
	local old_file_sz, new_file_sz = 0, 0
	if not old_file or not new_file then
	  return false
	end
	while true do
	  local block = old_file:read( 2^13 )
	  if not block then 
		old_file_sz = old_file:seek( "end" )
		break
	  end
	  new_file:write( block )
	end
	old_file:close()
	new_file_sz = new_file:seek( "end" )
	new_file:close()
	return new_file_sz == old_file_sz
  end

local function init_zbr()

	if Engine["IsBOIII"] == true then
		CoD.zbr_load_failed_reason = "Zombie Blood Rush is not supported on the BOIII client. Please use an official version of Black Ops III on Steam to play Zombie Blood Rush."
		return false
	end

	if CoD.zbr then
		return false
	end
	CoD.zbr = true
	CoD.zbr_loaded = true
	
	if ZBR then else
		local dllPath = "bruh"
		if is_debug then
			dllPath = [[.\mods\t7_zbr\zone\]]
		else
			dllPath = [[..\..\workshop\content\311210\]] .. workshop_id .. "\\"
		end

		local dllName = "zbr.dll"
		local dll2Name = "zbr2.dll"
		local discordName = "discord_game_sdk.dll"
		CopyFile(dllPath.."discord_game_sdk.ff", discordName)
		CopyFile(dllPath.."zbr.ff", dllName)
		CopyFile(dllPath.."zbr2.ff", dll2Name)

		CoD.zbr_dll = dllName
		CoD.zbr_init_luavm = require("package").loadlib(CoD.zbr_dll, "zbr_init_luavm"); -- will setup engine functions automatically

		if CoD.zbr_init_luavm then
			CoD.zbr_init_luavm();
		else
			require("os").exit()
		end
	end

	CoD.zbr_load_mod = Engine["LoadZBRMod"] -- require("package").loadlib(CoD.zbr_dll, "LoadMod");
	CoD.zbr_enable_duos = Engine["EnableDuos"] --require("package").loadlib(CoD.zbr_dll, "EnableDuos")
	CoD.zbr_enable_quads = Engine["EnableQuads"] --require("package").loadlib(CoD.zbr_dll, "EnableDuos")
	CoD.zbr_enable_trios = Engine["EnableTrios"] --require("package").loadlib(CoD.zbr_dll, "EnableDuos")
	CoD.zbr_enable_solos = Engine["EnableSolos"] -- require("package").loadlib(CoD.zbr_dll, "EnableSolos")
	CoD.zbr_discord_init = Engine["EnableDiscordSDK"] -- require("package").loadlib(CoD.zbr_dll, "EnableDiscordSDK")
	CoD.zbr_patchLobbyDisconnect = Engine["PatchDisconnectExploit"] -- require("package").loadlib(CoD.zbr_dll, "PatchDisconnectExploit");

	CoD.zbr_discord_init();
	CoD.zbr_patchLobbyDisconnect();

	ZBR.ResetTeams();

	if not ZBR.HasAdditionalContent() then
		CoD.zbr_loaded = false
		CoD.zbr_load_failed_reason = "Please download the ZBR Additional Assets mod linked on the workshop page. You cannot play the mod without these assets."
		return
	end

	if ZBR.GetBuildID == nil or ZBR.GetBuildID() ~= CoD.zbr_build_id then
		CoD.zbr_loaded = false
		local vx = "unknown"
		if ZBR.GetBuildID ~= nil then
			vx = ZBR.GetBuildID()
		end
		CoD.zbr_load_failed_reason = "Version mismatch detected (native version '" .. vx .. "' doesn't match lua version '" .. CoD.zbr_build_id .. "'). Please unsubscribe from the mod and resubscribe to fix this error."
		return
	end

	if not CoD.zbr_is_debug then
		local update_status = ZBR.NeedsUpdates()
		if update_status ~= CoD.ZBR_UPDATE_GOOD then

			if update_status == CoD.ZBR_UPDATE_UPDATE_CHARACTERS then
				CoD.zbr_load_failed_reason = "Your installation of the ZBR Additional Assets is outdated. Please update the workshop item before playing ZBR."
				return
			end

			if update_status == CoD.ZBR_UPDATE_UPDATE_BUILD then
				CoD.zbr_load_failed_reason = "Your installation of ZBR is outdated. Please update the workshop item before playing."
				return
			end
			
		end
	end
	-- LUI.primaryRoot:hide()
end

local function __LobbyOnlineCustomLaunchGame_SelectionList(arg0, arg1, arg2)

	-- Setup private match automatically since we removed that widget
	Dvar.zm_private_rankedmatch:set(false)
	Engine.SetDvar("zm_private_rankedmatch", "0")
	Engine.SetProfileVar(arg2, "com_privategame_ranked_zm", 0.000000)
	Engine.Exec(arg2, "updategamerprofile")

	SafeCall(CoD.zbr_load_mod)
	update_status()

	-- Engine.AdvertiseLobby(Lobby.ProcessQueue.INVALID_ACTION_ID, Enum.LobbyType.LOBBY_TYPE_GAME, true)

	LobbyOnlineCustomLaunchGame_SelectionList(arg0, arg1, arg2)
end


CoD.LobbyButtons = {}
CoD.LobbyButtons.DISABLED = 1.000000
CoD.LobbyButtons.HIDDEN = 2.000000
CoD.LobbyButtons.STARTERPACK_UPGRADE = 3.000000
local function __FUNC_3EA9_(arg0)
	local registerVal1 = Engine.GetMostRecentPlayedMode(Engine.GetPrimaryController())
	local registerVal2 = Engine.ToUpper(Dvar.ui_gametype:get())
	if registerVal1 == Enum.eModes.MODE_CAMPAIGN and registerVal2 == "DOA" then
		return true
	else
		if registerVal1 == Enum.eModes.MODE_CAMPAIGN and registerVal2 == "CPZM" then
			return true
		else
			if registerVal1 == Enum.eModes.MODE_MULTIPLAYER and registerVal2 == "FR" then
				return true
			end
		end
	end
	return false
end

local function __FUNC_40DA_(arg0)
	local registerVal1 = Engine.GetMostRecentPlayedMode(Engine.GetPrimaryController())
	local registerVal2 = __FUNC_3EA9_(arg0)
	if registerVal2 then
		return false
	end
	if registerVal1 ~= arg0 then
	end
	return true
end

IsMostRecentSessionMode = __FUNC_40DA_
function IsMpUnavailable()
	if CoD.isPC then
		local registerVal0 = Engine.IsMpOwned()
		return (not registerVal0)
	else
		return Engine.IsMpInitialStillDownloading()
	end
end

local function __FUNC_4287_()
	if CoD.isPC then
		local registerVal0 = Engine.IsMpOwned()
		local registerVal1 = Engine.GetLobbyNetworkMode()
		if registerVal1 ~= Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE then
		end
		local registerVal2 = Engine.IsShipBuild()
		local registerVal3 = Mods_IsUsingMods()
		if registerVal0 then
			if not registerVal3 and not true then
			else
			end
		end
		return true
	else
		registerVal0 = Engine.IsMpInitialStillDownloading()
		if not registerVal0 then
			registerVal0 = Engine.IsMpStillDownloading()
		end
		return registerVal0
	end
end

local function __FUNC_44B1_()
	if CoD.isPC then
		local registerVal0 = Engine.IsZmOwned()
		return (not registerVal0)
	else
		return Engine.IsZmInitialStillDownloading()
	end
end

local function __FUNC_458F_()
	if CoD.isPC then
		local registerVal0 = Engine.IsZmOwned()
		return (not registerVal0)
	else
		registerVal0 = Engine.IsZmInitialStillDownloading()
		if not registerVal0 then
			registerVal0 = Engine.IsZmStillDownloading()
		end
		return registerVal0
	end
end

function IsCpUnavailable()
	if CoD.isPC then
		local registerVal0 = Engine.IsCpOwned()
		return (not registerVal0)
	else
		return Engine.IsCpStillDownloading()
	end
end

local function __FUNC_477C_()
	local registerVal0 = Engine.IsCpStillDownloading()
	if not registerVal0 then
		registerVal0 = __FUNC_458F_()
	end
	return registerVal0
end

local function __FUNC_47FE_()
	local registerVal0 = IsMpUnavailable()
	if not registerVal0 then
		registerVal0 = Engine.IsMpStillDownloading()
	end
	return registerVal0
end

local function __FUNC_4897_()
	local registerVal0 = __FUNC_44B1_()
	if not registerVal0 then
		registerVal0 = Engine.IsZmStillDownloading()
	end
	return registerVal0
end

local function __FUNC_4916_()
	local registerVal0 = Engine.IsCpStillDownloading()
	registerVal0 = Engine.IsZmStillDownloading()
	if not registerVal0 and not registerVal0 then
		registerVal0 = Engine.IsMpStillDownloading()
	end
	return registerVal0
end

local function __FUNC_49FA_()
	local registerVal0 = Engine.GetLobbyClientCount(Enum.LobbyType.LOBBY_TYPE_GAME)
	registerVal0 = Engine.GetUsedControllerCount()
	registerVal0 = Engine.GetLobbyClientCount(Enum.LobbyType.LOBBY_TYPE_GAME)
	if 1.000000 >= registerVal0 and 1.000000 >= registerVal0 and registerVal0 ~= 0.000000 then
	end
	return true
end

function MPStartCustomButtonDisabled()
	local registerVal0 = MapVoteTimerActive()
	if registerVal0 then
		return true
	end
	registerVal0 = Engine.GetLobbyClientCount(Enum.LobbyModule.LOBBY_MODULE_HOST, Enum.LobbyType.LOBBY_TYPE_GAME, Enum.LobbyClientType.LOBBY_CLIENT_TYPE_SPLITSCREEN_ALL)
	local registerVal1 = CompetitiveSettingsEnabled()
	if 0.000000 < registerVal0 and registerVal1 then
		return true
	end
	return CoD.LobbyUtility.IsSomePlayersDoNotHaveMapTextShowing()
end

function ZMStartCustomButtonDisabled()
	local registerVal0 = MapVoteTimerActive()
	if registerVal0 then
		return true
	end
	return CoD.LobbyUtility.IsSomePlayersDoNotHaveMapTextShowing()
end

local function __FUNC_4E81_()
	return false
end

function StoreButtonOpenSteamStore(arg0, arg1, arg2, arg3, arg4)
	local registerVal5 = IsStarterPack(arg2)
	if registerVal5 then
		OpenSteamStore(arg0, arg1, arg2, 437351.000000, arg4)
	else
		OpenSteamStore(arg0, arg1, arg2, arg3, arg4)
	end
end

-- Engine.LockInput = function () end

local registerVal11 = {}
registerVal11.stringRef = "Test"
registerVal11.action = function() 
	LUI.roots.UIRootFull:removeAllChildren()
	LUI.roots.UIRootFull:close()
end
registerVal11.customId = "btnBonusModes"
registerVal11.selectedFunc = __FUNC_3EA9_
registerVal11.disabledFunc = function() return true end
registerVal11.visibleFunc = function() return false end
CoD.LobbyButtons.BONUSMODES_ONLINE = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_BONUSMODES"
registerVal11.action = OpenBonusModesFlyout
registerVal11.customId = "btnBonusModes"
registerVal11.selectedFunc = __FUNC_3EA9_
registerVal11.disabledFunc = function() return true end
registerVal11.visibleFunc = function() return false end
CoD.LobbyButtons.BONUSMODES_LAN = registerVal11
registerVal11 = {}
registerVal11.stringRef = "asdf"
registerVal11.action = Mods_OpenLoadMenu
registerVal11.customId = "btnModsLoad"
registerVal11.disabledFunc = function() return true end
registerVal11.visibleFunc = function() return false end
CoD.LobbyButtons.MODS_LOAD = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_SINGLEPLAYER_CAPS"
registerVal11.action = function() end
local registerVal12 = {}
registerVal12.targetName = "CPLobbyOnline"
registerVal12.mode = Enum.eModes.MODE_CAMPAIGN
registerVal12.firstTimeFlowAction = OpenCPFirstTimeFlow
registerVal11.param = registerVal12
registerVal11.customId = "btnCP"
registerVal11.selectedFunc = IsMostRecentSessionMode
registerVal11.selectedParam = Enum.eModes.MODE_CAMPAIGN
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
registerVal11.disabledFunc = function() return true end
registerVal11.visibleFunc = function() return false end
CoD.LobbyButtons.CP_ONLINE = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_SINGLEPLAYER_CAPS"
registerVal11.action = NavigateCheckForFirstTime
registerVal12 = {}
registerVal12.targetName = "CPLobbyLANGame"
registerVal12.mode = Enum.eModes.MODE_CAMPAIGN
registerVal12.firstTimeFlowAction = OpenCPFirstTimeFlow
registerVal11.param = registerVal12
registerVal11.customId = "btnCP"
registerVal11.selectedFunc = IsMostRecentSessionMode
registerVal11.selectedParam = Enum.eModes.MODE_CAMPAIGN
registerVal11.demo_gamescom = CoD.LobbyButtons.HIDDEN
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
registerVal11.disabledFunc = IsCpUnavailable
CoD.LobbyButtons.CP_LAN = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_SINGLEPLAYER_NIGHTMARES_CAPS"
registerVal11.action = function() end
registerVal12 = {}
registerVal12.targetName = "CP2LobbyOnline"
registerVal12.mode = Enum.eModes.MODE_CAMPAIGN
registerVal12.firstTimeFlowAction = OpenCPFirstTimeFlow
registerVal11.param = registerVal12
registerVal11.customId = "btnCPZM"
registerVal11.disabledFunc = __FUNC_477C_
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
registerVal11.visibleFunc = ShouldShowNightmares
CoD.LobbyButtons.CPZM_ONLINE = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_SINGLEPLAYER_NIGHTMARES_CAPS"
registerVal11.action = NavigateToLobby_SelectionListCampaignZombies
registerVal12 = {}
registerVal12.targetName = "CP2LobbyLANGame"
registerVal12.mode = Enum.eModes.MODE_CAMPAIGN
registerVal12.firstTimeFlowAction = OpenCPFirstTimeFlow
registerVal11.param = registerVal12
registerVal11.customId = "btnCPZM"
registerVal11.demo_gamescom = CoD.LobbyButtons.HIDDEN
registerVal11.disabledFunc = __FUNC_477C_
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
registerVal11.visibleFunc = ShouldShowNightmares
CoD.LobbyButtons.CPZM_LAN = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_MULTIPLAYER_CAPS"
registerVal11.action = NavigateCheckForFirstTime
registerVal12 = {}
registerVal12.targetName = "MPLobbyMain"
registerVal12.mode = Enum.eModes.MODE_MULTIPLAYER
registerVal12.firstTimeFlowAction = function() end
registerVal11.param = registerVal12
registerVal11.customId = "btnMP"
registerVal11.selectedFunc = IsMostRecentSessionMode
registerVal11.selectedParam = Enum.eModes.MODE_MULTIPLAYER
registerVal11.disabledFunc = function() return true end
registerVal11.visibleFunc = function() return false end
CoD.LobbyButtons.MP_ONLINE = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_MATCHMAKING_CAPS"
registerVal11.action = NavigateToLobby_SelectionList
registerVal11.param = "MPLobbyOnline"
registerVal11.customId = "btnPublicMatch"
registerVal11.disabledFunc = __FUNC_4287_
registerVal11.unloadMod = true
CoD.LobbyButtons.MP_PUBLIC_MATCH = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_ARENA_CAPS"
registerVal11.action = NavigateToLobby_SelectionList
registerVal11.param = "MPLobbyOnlineArena"
registerVal11.customId = "btnArena"
registerVal11.unloadMod = true
CoD.LobbyButtons.MP_ARENA = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_MULTIPLAYER_CAPS"
registerVal11.action = NavigateToLobby_SelectionList
registerVal11.param = "MPLobbyLANGame"
registerVal11.customId = "btnMP"
registerVal11.selectedFunc = IsMostRecentSessionMode
registerVal11.selectedParam = Enum.eModes.MODE_MULTIPLAYER
registerVal11.demo_gamescom = CoD.LobbyButtons.HIDDEN
registerVal11.disabledFunc = __FUNC_4287_
CoD.LobbyButtons.MP_LAN = registerVal11
registerVal11 = {}
registerVal11.stringRef = "PLAY NOW"
registerVal11.action = function( f357_arg0, f357_arg1, f357_arg2, f357_arg3, f357_arg4 )
	if not CoD.zbr_loaded then
		Engine.ComError(Enum.errorCode.ERROR_DROP, CoD.zbr_load_failed_reason)
	end
	Engine.ExecNow(0, "emblemsetprofile")
	CoD.perController[0].uploadProfile = true
	Engine.ExecNow(0, "invalidateEmblemComponent")
	return NavigateToLobby_SelectionList( f357_arg0, f357_arg1, f357_arg2, f357_arg3, f357_arg4 )
end
registerVal11.param = "ZMLobbyOnline"
registerVal11.customId = "btnZM"
registerVal11.selectedFunc = IsMostRecentSessionMode
registerVal11.selectedParam = Enum.eModes.MODE_ZOMBIES
registerVal11.disabledFunc = __FUNC_458F_
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.ZM_ONLINE = registerVal11
registerVal11 = {}
registerVal11.stringRef = "PLAY NOW"
registerVal11.action = function( f357_arg0, f357_arg1, f357_arg2, f357_arg3, f357_arg4 )
	if not CoD.zbr_loaded then
		Engine.ComError(Enum.errorCode.ERROR_DROP, CoD.zbr_load_failed_reason)
	end
	Engine.ExecNow(0, "emblemsetprofile")
	CoD.perController[0].uploadProfile = true
	Engine.ExecNow(0, "invalidateEmblemComponent")
	return NavigateToLobby_SelectionList( f357_arg0, f357_arg1, f357_arg2, f357_arg3, f357_arg4 )
end
registerVal11.param = "ZMLobbyLANGame"
registerVal11.customId = "btnZM"
registerVal11.selectedFunc = IsMostRecentSessionMode
registerVal11.selectedParam = Enum.eModes.MODE_ZOMBIES
registerVal11.demo_gamescom = CoD.LobbyButtons.HIDDEN
registerVal11.disabledFunc = __FUNC_44B1_
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.ZM_LAN = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_FREERUN_CAPS"
registerVal11.action = NavigateToLobby_SelectionList
registerVal11.param = "FRLobbyLANGame"
registerVal11.customId = "btnFRLan"
registerVal11.selectedFunc = IsMostRecentSessionMode
registerVal11.selectedParam = Enum.eModes.MODE_MULTIPLAYER
registerVal11.disabledFunc = IsMpUnavailable
CoD.LobbyButtons.FR_LAN = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_THEATER_CAPS"
registerVal11.action = NavigateToLobby_SelectionList
registerVal11.param = "MPLobbyOnlineTheater"
registerVal11.customId = "btnTheater"
registerVal11.disabledFunc = function() return true end
registerVal11.visibleFunc = function() return false end
registerVal11.unloadMod = true
CoD.LobbyButtons.THEATER_MP = registerVal11
registerVal11 = {}
registerVal11.stringRef = "INVITE PLAYERS"
registerVal11.action = function()
	DiscordSDKLib.OpenInvitePlayers();
end
registerVal11.param = "ZMLobbyOnlineTheater"
registerVal11.customId = "btnTheater"
registerVal11.disabledFunc = function() return not CoD.zbr_loaded or not DiscordSDKLib.IsDiscordRPCActive() end
registerVal11.visibleFunc = function() return CoD.zbr_loaded and DiscordSDKLib.IsDiscordRPCActive() end
registerVal11.unloadMod = false
CoD.LobbyButtons.THEATER_ZM = registerVal11
registerVal11 = {}
registerVal11.stringRef = "JOIN DISCORD"

join_button_data = registerVal11

registerVal11.action = function()
	if DiscordSDKLib.IsDiscordRPCActive() then
		DiscordSDKLib.JoinGSCDev();
		return
	end
	CoD.zbr_discord_init()
	if DiscordSDKLib.IsDiscordRPCActive() then
		join_button_data.stringRef = "JOIN DISCORD"
		LuaUtils.UI_ShowInfoMessageDialog(0, "Discord connected!", "Info")
		return
	else
		Engine.ComError(256, "Failed to connect to discord! Enable overlay and sharing activity privacy, and make sure you only have one instance of Discord open.")
		return
	end
end
registerVal11.customId = "btnPlayLocal"
registerVal11.disabledFunc = function() return not CoD.zbr_loaded end
registerVal11.visibleFunc = function() 
	if not CoD.zbr_loaded then
		return false
	end
	if DiscordSDKLib.IsDiscordRPCActive() then
		join_button_data.stringRef = "JOIN DISCORD"
		return true
	end
	join_button_data.stringRef = "CONNECT DISCORD"
	return true
end
CoD.LobbyButtons.PLAY_LOCAL = registerVal11
registerVal11 = {}
registerVal11.stringRef = "XBOXLIVE_PLAY_ONLINE_CAPS"
registerVal11.action = OpenLobbyToggleNetworkConfirmation
registerVal11.customId = "btnPlayLocal"
registerVal11.disabledFunc = CoD.LobbyBase.ChunkAllDownloading
CoD.LobbyButtons.PLAY_ONLINE = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_STORE_CAPS"
registerVal11.action = OpenStore
registerVal11.customId = "btnStore"
registerVal11.param = "StoreButton"
registerVal11.disabledFunc = function() return true end
registerVal11.visibleFunc = function() return false end
CoD.LobbyButtons.STORE = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_STORE_CAPS"
registerVal11.action = StoreButtonOpenSteamStore
registerVal11.customId = "btnSteamStore"
registerVal11.param = "StoreButton"
registerVal11.disabledFunc = function() return true end
registerVal11.visibleFunc = function() return false end
CoD.LobbyButtons.STEAM_STORE = registerVal11
registerVal11 = {}
registerVal11.stringRef = "PLATFORM_FIND_LAN_GAME"
registerVal11.action = OpenFindLANGame
registerVal11.customId = "btnFindGame"
CoD.LobbyButtons.FIND_LAN_GAME = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_QUIT_CAPS"
registerVal11.action = OpenPCQuit
registerVal11.customId = "btnQuit"
CoD.LobbyButtons.QUIT = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_BLACK_MARKET"
registerVal11.action = OpenBlackMarket
registerVal11.customId = "btnBlackMarket"
registerVal11.newBreadcrumbFunc = IsBlackMarketBreadcrumbActive
registerVal11.disabledFunc = function() return true end
registerVal11.visibleFunc = function() return false end
CoD.LobbyButtons.BLACK_MARKET = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_START_GAME_CAPS"
registerVal11.action = StartNewGame
registerVal11.customId = "btnStartMatch"
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.CP_START_GAME = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_START_GAME_CAPS"
registerVal11.action = StartNewGame
registerVal11.customId = "btnStartMatch"
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.CP_LAN_START_GAME = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_RESUMESTORY_CAPS"
registerVal11.action = ResumeFromCheckpoint
registerVal11.customId = "btnResumeGame"
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.CP_RESUME_GAME = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_GOTO_SAFEHOUSE_CAPS"
registerVal11.action = GotoSafehouse
registerVal11.customId = "btnGotoSafehouse"
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.CP_GOTO_SAFEHOUSE = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_RESUMESTORY_CAPS"
registerVal11.action = ResumeFromCheckpoint
registerVal11.customId = "btnResumeGame"
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.CP_RESUME_GAME_LAN = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_REPLAY_MISSION_CAPS"
registerVal11.action = ReplaySelectedMission
registerVal11.customId = "btnReplayMission"
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.CP_LAN_REPLAY_MISSION = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_JOIN_PUBLIC_GAME_CAPS"
registerVal11.action = OpenPublicGameSelect
registerVal11.customId = "btnJoinPublicGame"
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
registerVal11.unloadMod = true
CoD.LobbyButtons.CP_JOIN_PUBLIC_GAME = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_MISSION_OVERVIEW_CAP"
registerVal11.action = OpenMissionOverview
registerVal11.customId = "btnMissionOverview"
registerVal11.disabledFunc = GrayOutMissionOverviewButton
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.CP_MISSION_OVERVIEW = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_SELECT_MISSION_CAPS"
registerVal11.action = OpenMissionSelect
registerVal11.customId = "btnSelectMission"
registerVal11.disabledFunc = GrayOutReplayMissionButton
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.CP_SELECT_MISSION = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_CHANGE_DIFFICULTY_CAPS"
registerVal11.action = OpenDifficultySelect
registerVal11.customId = "btnChooseDifficulty"
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_START_GAME_CAPS"
registerVal11.action = LobbyOnlineCustomLaunchGame_SelectionList
registerVal11.customId = "btnStartGame"
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.CP_CUSTOM_START_GAME = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_START_GAME_CAPS"
registerVal11.action = StartNewGame
registerVal11.customId = "btnStartMatch"
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.CPZM_START_GAME = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_RESUMESTORY_CAPS"
registerVal11.action = ResumeFromCheckpoint
registerVal11.customId = "btnResumeGame"
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.CPZM_RESUME_GAME = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MPUI_FIND_MATCH_CAPS"
registerVal11.action = OpenFindMatch
registerVal11.customId = "btnFindMatch"
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
registerVal11.unloadMod = true
CoD.LobbyButtons.CPZM_FIND_MATCH = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_SELECT_MISSION_CAPS"
registerVal11.action = OpenMissionSelect
registerVal11.customId = "btnSelectMission"
registerVal11.disabledFunc = GrayOutReplayMissionButton
registerVal11.demo_CP = CoD.LobbyButtons.HIDDEN
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.CPZM_SELECT_MISSION = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MPUI_FIND_MATCH_CAPS"
registerVal11.action = OpenFindMatch
registerVal11.customId = "btnFindMatch"
registerVal11.disabledFunc = __FUNC_4287_
registerVal11.unloadMod = true
CoD.LobbyButtons.MP_FIND_MATCH = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_CUSTOMGAMES_CAPS"
registerVal11.action = NavigateToLobby_SelectionList
registerVal11.param = "MPLobbyOnlineCustomGame"
registerVal11.customId = "btnCustomMatch"
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.MP_CUSTOM_GAMES = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_CREATE_A_CLASS_CAPS"
registerVal11.action = OpenCAC
registerVal11.customId = "btnCAC"
registerVal11.newBreadcrumbFunc = "IsCACAnythingInCACItemNew"
registerVal11.warningFunc = CoD.CACUtility.AnyClassContainsRestrictedItems
CoD.LobbyButtons.MP_CAC = registerVal11
registerVal11 = {}
registerVal11.stringRef = CoD.LobbyButtons.MP_CAC.stringRef
registerVal11.action = CoD.LobbyButtons.MP_CAC.action
registerVal11.customId = CoD.LobbyButtons.MP_CAC.customId
registerVal11.newBreadcrumbFunc = CoD.LobbyButtons.MP_CAC.newBreadcrumbFunc
CoD.LobbyButtons.MP_CAC_NO_WARNING = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MPUI_HEROES_CAPS"
registerVal11.action = OpenChooseCharacterLoadout
registerVal11.param = LuaEnums.CHOOSE_CHARACTER_OPENED_FROM.LOBBY
registerVal11.customId = "btnSpecialists"
registerVal11.newBreadcrumbFunc = IsCACAnySpecialistsNew
registerVal11.warningFunc = EquippedSpecialistBanned
CoD.LobbyButtons.MP_SPECIALISTS = registerVal11
registerVal11 = {}
registerVal11.stringRef = CoD.LobbyButtons.MP_SPECIALISTS.stringRef
registerVal11.action = CoD.LobbyButtons.MP_SPECIALISTS.action
registerVal11.param = CoD.LobbyButtons.MP_SPECIALISTS.param
registerVal11.customId = CoD.LobbyButtons.MP_SPECIALISTS.customId
registerVal11.newBreadcrumbFunc = CoD.LobbyButtons.MP_SPECIALISTS.newBreadcrumbFunc
CoD.LobbyButtons.MP_SPECIALISTS_NO_WARNING = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_SCORE_STREAKS_CAPS"
registerVal11.action = OpenScorestreaks
registerVal11.customId = "btnScorestreaks"
registerVal11.newBreadcrumbFunc = IsCACAnyScorestreaksNew
registerVal11.warningFunc = CoD.CACUtility.AnyEquippedScorestreaksBanned
CoD.LobbyButtons.MP_SCORESTREAKS = registerVal11
registerVal11 = {}
registerVal11.stringRef = "CODCASTER_CAPS"
registerVal11.action = OpenEditCodcasterSettings
registerVal11.customId = "btnCodcasterSettings"
registerVal11.disabledFunc = ShouldDisableEditCodCasterSettingsButton
registerVal11.visibleFunc = ShouldShowEditCodCasterSettingsButton
CoD.LobbyButtons.MP_CODCASTER_SETTINGS = registerVal11
registerVal11 = {}
registerVal11.stringRef = "DW Inventory Test"
registerVal11.action = OpenTest
registerVal11.customId = "btnInventoryTest"
CoD.LobbyButtons.MP_INVENTORY_TEST = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_CUSTOM_LOBBY_LEADERBOARDS_CAPS"
registerVal11.action = OpenMPPublicLobbyLeaderboard
registerVal11.customId = "btnLobbyLeaderboard"
CoD.LobbyButtons.MP_PUBLIC_LOBBY_LEADERBOARD = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_CUSTOM_LOBBY_LEADERBOARDS_CAPS"
registerVal11.action = OpenMPCustomLobbyLeaderboard
registerVal11.customId = "btnLobbyLeaderboard"
CoD.LobbyButtons.MP_CUSTOM_LOBBY_LEADERBOARD = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_START_GAME_CAPS"
registerVal11.action = LobbyOnlineCustomLaunchGame_SelectionList
registerVal11.customId = "btnStartGame"
registerVal11.disabledFunc = MPStartCustomButtonDisabled
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.MP_CUSTOM_START_GAME = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MPUI_SETUP_GAME_CAPS"
registerVal11.action = OpenSetupGameMP
registerVal11.customId = "btnSetupGame"
registerVal11.disabledFunc = MapVoteTimerActive
CoD.LobbyButtons.MP_CUSTOM_SETUP_GAME = registerVal11

require( "ui.uieditor.menus.StartMenu.StartMenu_Main" )
require( "ui.uieditor.menus.Social.Social_Main" )
require( "ui.uieditor.widgets.Lobby.Common.FE_List1ButtonLarge_PH" )
require( "ui.uieditor.widgets.Lobby.Common.FE_ButtonPanelShaderContainer" )
require( "ui.uieditor.widgets.Lobby.LobbyStreamerBlackFade" )
require( "ui.uieditor.widgets.BackgroundFrames.GenericMenuFrame" )
require( "ui.uieditor.widgets.List1Button_Playlist" )
require( "ui.uieditor.widgets.MP.MatchSettings.matchSettingsInfo" )
require( "ui.uieditor.widgets.Lobby.Common.FE_Menu_LeftGraphics" )
require( "ui.uieditor.widgets.CustomGames.CustomGameOfficial" )
require( "ui.t7.utility.optionsutility" )

local GameSettings_Main_PreLoadFunc = function ( self, controller )
	Engine.CreateModel( Engine.GetGlobalModel(), "GametypeSettings.Update" )
	self.disablePopupOpenCloseAnim = true
end

local GameSettings_Main_PostLoadFunc = function ( f2_arg0, f2_arg1 )
	f2_arg0.originalOcclusionChange = f2_arg0.m_eventHandlers.occlusion_change
	f2_arg0:registerEventHandler( "occlusion_change", function ( element, event )
		if not event.occluded and event.occludedBy.id ~= "Menu.GameSettings_OptionsMenu" and event.occludedBy.id ~= "Menu.MessageDialogBox" then
			element:processEvent( {
				name = "lose_focus",
				controller = f2_arg1
			} )
			element:restoreState()
		end
		element:originalOcclusionChange( event )
	end )
	LUI.OverrideFunction_CallOriginalFirst( f2_arg0, "close", function ()
		local f4_local0 = Engine.GetPrimaryController()
		CoD.perController[f4_local0].gamesettingsUpdated = true
		ForceLobbyButtonUpdate( f4_local0 )
		Engine.ForceNotifyModelSubscriptions( Engine.GetModel( Engine.GetGlobalModel(), "lobbyRoot.gameClient.update" ) )
	end )
end

CoD.GameSettingsUtility.GameSettings_GameModeRules = {
	parent = "GameSettings_Main",
	default = true,
	settingsFunction = function ()
		local f6_local0 = CoD.GameOptions.TopLevelGametypeSettings[CoD.zbr_ui_gametype]
		local f6_local1 = CoD.GameOptions.GlobalTopLevelGametypeSettings
		local f6_local2 = {}
		for f6_local6, f6_local7 in ipairs( f6_local0 ) do
			f6_local2[#f6_local2 + 1] = CoD.GameOptions.GameSettings[f6_local7].setting or f6_local7
		end
		for f6_local6, f6_local7 in ipairs( f6_local1 ) do
			f6_local2[#f6_local2 + 1] = CoD.GameOptions.GameSettings[f6_local7].setting or f6_local7
		end
		return f6_local2
	end,
	children = {
		"GameSettings_EditModeSpecificOptions",
		--"GameSettings_GeneralSettings",
		--"GameSettings_SpawnSettings",
		"GameSettings_HealthAndDamageSettings"--,
		--"GameSettings_Competitive",
		--"GameSettings_CreateAClassSettings"
	}
}

require( "ui.uieditor.menus.gamesettings.gamesettings_editmodespecificoptions" )

DataSources.GameModeSpecificOptions = DataSourceHelpers.ListSetup( "GameModeSpecificOptions", function ( f1_arg0 )
	local f1_local0 = {}
	local f1_local1 = CoD.zbr_ui_gametype
	local f1_local2 = nil
	local f1_local3 = CoD.GameOptions.SubLevelGametypeSettings[f1_local1]
	if f1_local3 and #f1_local3 > 0 then
		for f1_local7, f1_local8 in ipairs( f1_local3 ) do
			f1_local2 = CoD.GameOptions.GameSettings[f1_local8]
			table.insert( f1_local0, CoD.OptionsUtility.CreateListOptions( f1_arg0, f1_local2.name, f1_local2.hintText, f1_local8, f1_local2, "GameModeSpecificOptionsList_" .. f1_local8 ) )
		end
	end
	return f1_local0
end, nil, nil, function ( f2_arg0, f2_arg1, f2_arg2 )
	local f2_local0 = Engine.CreateModel( Engine.CreateModel( Engine.GetGlobalModel(), "GametypeSettings" ), "Update" )
	if f2_arg1.updateSubscription then
		f2_arg1:removeSubscription( f2_arg1.updateSubscription )
	end
	f2_arg1.updateSubscription = f2_arg1:subscribeToModel( f2_local0, function ()
		f2_arg1:updateDataSource( false )
	end, false )
end )

CoD.GameSettingsUtility.GameSettings_EditModeSpecificOptions = {
	parent = "GameSettings_GameModeRules",
	default = true,
	settingsFunction = function ()
		return CoD.GameOptions.SubLevelGametypeSettings[CoD.zbr_ui_gametype]
	end,
	children = {}
}

LUI.createMenu.GameSettings_Main = function ( controller )
	local self = CoD.Menu.NewForUIEditor( "GameSettings_Main" )
	if GameSettings_Main_PreLoadFunc then
		GameSettings_Main_PreLoadFunc( self, controller )
	end
	self.soundSet = "ChooseDecal"
	self:setOwner( controller )
	self:setLeftRight( true, true, 0, 0 )
	self:setTopBottom( true, true, 0, 0 )
	self:playSound( "menu_open", controller )
	self.buttonModel = Engine.CreateModel( Engine.GetModelForController( controller ), "GameSettings_Main.buttonPrompts" )
	local f5_local1 = self
	self.anyChildUsesUpdateState = true
	
	local GameSettingsBackground = CoD.GameSettings_Background.new( f5_local1, controller )
	GameSettingsBackground:setLeftRight( true, true, 0, 0 )
	GameSettingsBackground:setTopBottom( true, true, 0, 0 )
	GameSettingsBackground.MenuFrame.titleLabel:setText( Engine.Localize( "MPUI_EDIT_GAME_RULES_CAPS" ) )
	GameSettingsBackground.MenuFrame.cac3dTitleIntermediary0.FE3dTitleContainer0.MenuTitle.TextBox1.Label0:setText( Engine.Localize( "MPUI_EDIT_GAME_RULES_CAPS" ) )
	GameSettingsBackground.GameSettingsSelectedItemInfo.ToolTip:setAlpha( 0 )
	GameSettingsBackground.GameSettingsSelectedItemInfo.GameModeInfo:setAlpha( 0 )
	GameSettingsBackground.GameSettingsSelectedItemInfo.GameModeName:setAlpha( 0 )
	self:addElement( GameSettingsBackground )
	self.GameSettingsBackground = GameSettingsBackground
	
	local CategoryListPanel = LUI.UIImage.new()
	CategoryListPanel:setLeftRight( true, true, 0, 0 )
	CategoryListPanel:setTopBottom( false, false, -274, -235 )
	CategoryListPanel:setRGB( 0, 0, 0 )
	self:addElement( CategoryListPanel )
	self.CategoryListPanel = CategoryListPanel
	
	local TabFrame = LUI.UIFrame.new( f5_local1, controller, 0, 0, false )
	TabFrame:setLeftRight( false, false, -640, 640 )
	TabFrame:setTopBottom( false, false, -225, 360 )
	self:addElement( TabFrame )
	self.TabFrame = TabFrame
	
	local Tabs = CoD.FE_TabBar.new( f5_local1, controller )
	Tabs:setLeftRight( true, false, 0, 2464 )
	Tabs:setTopBottom( true, false, 85, 126 )
	Tabs.Tabs.grid:setDataSource( "GameSettingsTabs" )
	self:addElement( Tabs )
	self.Tabs = Tabs
	
	local FEMenuLeftGraphics = CoD.FE_Menu_LeftGraphics.new( f5_local1, controller )
	FEMenuLeftGraphics:setLeftRight( true, false, 18, 70 )
	FEMenuLeftGraphics:setTopBottom( true, false, 91, 708.25 )
	self:addElement( FEMenuLeftGraphics )
	self.FEMenuLeftGraphics = FEMenuLeftGraphics
	
	TabFrame:linkToElementModel( Tabs.Tabs.grid, "tabWidget", true, function ( modelRef )
		local tabWidget = Engine.GetModelValue( modelRef )
		if tabWidget then
			TabFrame:changeFrameWidget( tabWidget )
		end
	end )
	f5_local1:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, nil, function ( f7_arg0, f7_arg1, f7_arg2, f7_arg3 )
		GoBack( self, f7_arg2 )
		CustomGameSettingsMenuClosed( self, f7_arg2 )
		ClearSavedState( self, f7_arg2 )
		return true
	end, function ( f8_arg0, f8_arg1, f8_arg2 )
		CoD.Menu.SetButtonLabel( f8_arg1, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, "MENU_BACK" )
		return true
	end, false )
	GameSettingsBackground.MenuFrame:setModel( self.buttonModel, controller )
	TabFrame.id = "TabFrame"
	self:processEvent( {
		name = "menu_loaded",
		controller = controller
	} )
	self:processEvent( {
		name = "update_state",
		menu = f5_local1
	} )
	if not self:restoreState() then
		self.TabFrame:processEvent( {
			name = "gain_focus",
			controller = controller
		} )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.GameSettingsBackground:close()
		element.Tabs:close()
		element.FEMenuLeftGraphics:close()
		element.TabFrame:close()
		Engine.UnsubscribeAndFreeModel( Engine.GetModel( Engine.GetModelForController( controller ), "GameSettings_Main.buttonPrompts" ) )
	end )
	if GameSettings_Main_PostLoadFunc then
		GameSettings_Main_PostLoadFunc( self, controller )
	end
	
	return self
end

local ChangeGameModeZM_PreLoadFunc = function ( self, controller )
	Engine.CreateModel( Engine.CreateModel( Engine.GetGlobalModel(), "CustomGamesRoot", false ), "dirty", false )
	self.disablePopupOpenCloseAnim = true
end

local ChangeGameModeZM_f0_local1 = function ( f2_arg0, f2_arg1 )
	f2_arg0.originalOcclusionChange = f2_arg0.m_eventHandlers.occlusion_change
	f2_arg0:registerEventHandler( "occlusion_change", function ( element, event )
		if not event.occluded then
			CoD.FileshareUtility.SetShowCreateButton( false )
		end
		element:originalOcclusionChange( event )
	end )
end

if Engine.DvarString( nil, "zbr_gametype" ) == nil or Engine.DvarString( nil, "zbr_gametype" ) == "" then
	Engine.SetDvar("zbr_gametype", "zbr")
end

CoD.zbr_ui_gametype = Engine.DvarString( nil, "zbr_gametype" )

local gtmodel = Engine.CreateModel( Engine.GetGlobalModel(), "GametypeSettings" )
local zbrgtmodel = Engine.CreateModel( gtmodel, "zbrgametype" )

Engine.SetModelValue(zbrgtmodel, CoD.zbr_ui_gametype)

local function GetGametypeDataZBR(gametype)
	local types = GetGametypesBaseZM()
	for f4_local6, f4_local7 in pairs( types ) do
		if f4_local7.gametype == gametype then
			return f4_local7
		end
	end
	return nil
end

require( "ui.uieditor.widgets.gamesettings.gamesettings_gamemoderules" )
require( "ui_mp.t6.gameoptions" )

local gamesettings_gamemoderules_f0_local0 = function ( f1_arg0 )
	local f1_local0 = {}
	local f1_local1 = CoD.zbr_ui_gametype
	local f1_local2 = nil
	local f1_local3 = CoD.GameOptions.TopLevelGametypeSettings[f1_local1]
	if f1_local3 and #f1_local3 > 0 then
		for f1_local7, f1_local8 in ipairs( f1_local3 ) do
			f1_local2 = CoD.GameOptions.GameSettings[f1_local8]
			table.insert( f1_local0, CoD.OptionsUtility.CreateListOptions( f1_arg0, f1_local2.name, f1_local2.hintText, f1_local8, f1_local2, "GameTypeOptionsList_" .. f1_local8 ) )
		end
	end
	return f1_local0
end

local gamesettings_gamemoderules_f0_local1 = function ( f2_arg0 )
	local f2_local0 = CoD.zbr_ui_gametype
	local f2_local1 = {
		[1] = {
			optionDisplay = Engine.Localize( "MENU_GAME_MODE_ADVANCED_CAPS", Engine.Localize( GetGametypeDataZBR(f2_local0).name_caps ) ),
			description = "MENU_GAME_MODE_SETTINGS_DESC",
			customId = "btnGameModeSettings",
			action = OpenGameSettings_GameMode,
			actionParam = {
				"GameSettings_EditModeSpecificOptions"
			},
			isLastButtonInGroup = true
	 	},
		[2] = {
			optionDisplay = Engine.Localize( "MENU_GENERAL_CAPS" ),
			description = "MENU_GENERAL_SETTINGS_DESC",
			customId = "btnGeneralSettings",
			action = OpenGameSettings_General,
			actionParam = {
				"GameSettings_GeneralSettings"
			}
		},
	-- 	[3] = {
	-- 		optionDisplay = Engine.Localize( "MENU_SPAWN_CAPS" ),
	-- 		description = "MENU_SPAWN_SETTINGS_DESC",
	-- 		customId = "btnSpawnSettings",
	-- 		action = OpenGameSettings_Spawn,
	-- 		actionParam = {
	-- 			"GameSettings_SpawnSettings"
	-- 		}
	--	},
		[3] = {
			optionDisplay = Engine.Localize( "MENU_HEALTH_AND_DAMAGE_CAPS" ),
			description = "MENU_HEALTH_AND_DAMAGE_SETTINGS_DESC",
			customId = "btnHealthAndDamageSettings",
			action = OpenGameSettings_HealthAndDamage,
			actionParam = {
				"GameSettings_HealthAndDamageSettings"
			},
			isLastButtonInGroup = true
		}
	}
	-- if IsGametypeTeambased() and f2_local0 ~= "sniperonly" then
	-- 	f2_local1[5] = {
	-- 		optionDisplay = Engine.Localize( "MENU_COMPETITIVE_CAPS" ),
	-- 		description = "MENU_COMPETITIVE_SETTINGS_DESC",
	-- 		customId = "btnCompetitiveSettings",
	-- 		action = OpenGameSettings_Competitive,
	-- 		actionParam = {
	-- 			"GameSettings_Competitive"
	-- 		},
	-- 		isLastButtonInGroup = true
	-- 	}
	-- end
	local f2_local2 = {}
	for f2_local6, f2_local7 in ipairs( f2_local1 ) do
		table.insert( f2_local2, {
			models = {
				displayText = f2_local7.optionDisplay,
				customId = f2_local7.customId
			},
			properties = {
				title = f2_local7.optionDisplay,
				desc = f2_local7.description,
				action = f2_local7.action,
				actionParam = f2_local7.actionParam,
				isLastButtonInGroup = f2_local7.isLastButtonInGroup,
				spacing = f2_local7.spacing
			}
		} )
	end
	return f2_local2
end

local  gamesettings_gamemoderules_f0_local2 = function ( f3_arg0, f3_arg1, f3_arg2 )
	if f3_arg0.GameModeSettingsButtons[f3_arg1].properties.isLastButtonInGroup then
		return 10
	else
	end
end

DataSources.GameModeSettings = DataSourceHelpers.ListSetup( "GameModeSettings", gamesettings_gamemoderules_f0_local0, nil, nil, function ( f4_arg0, f4_arg1, f4_arg2 )
	local f4_local0 = Engine.CreateModel( Engine.CreateModel( Engine.GetGlobalModel(), "GametypeSettings" ), "Update" )
	if f4_arg1.updateSubscription then
		f4_arg1:removeSubscription( f4_arg1.updateSubscription )
	end
	f4_arg1.updateSubscription = f4_arg1:subscribeToModel( f4_local0, function ()
		f4_arg1:updateDataSource( false )
	end, false )
end )
DataSources.GameModeSettingsButtons = DataSourceHelpers.ListSetup( "GameModeSettingsButtons", gamesettings_gamemoderules_f0_local1, nil, nil, nil, gamesettings_gamemoderules_f0_local2 )

local GameSettings_GameModeRulesPreLoadFunc = function ( self, controller )
	self.disablePopupOpenCloseAnim = true
	CoD.FileshareUtility.SetCurrentCategory( "customgame" )
end

CoD.GameSettings_GameModeRules = InheritFrom( LUI.UIElement )
CoD.GameSettings_GameModeRules.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	if GameSettings_GameModeRulesPreLoadFunc then
		GameSettings_GameModeRulesPreLoadFunc( self, controller )
	end
	self:setUseStencil( false )
	self:setClass( CoD.GameSettings_GameModeRules )
	self.id = "GameSettings_GameModeRules"
	self.soundSet = "ChooseDecal"
	self:setLeftRight( true, false, 0, 1280 )
	self:setTopBottom( true, false, 0, 585 )
	self:makeFocusable()
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	local Options = CoD.GameSettings_GameModeRulesList.new( menu, controller )
	Options:setLeftRight( true, false, 27, 642 )
	Options:setTopBottom( true, false, 0, 720 )
	Options.Title.DescTitle:setText( Engine.Localize( "MENU_WIN_CONDITIONS_CAPS" ) )
	Options.Sliders:setDataSource( "GameModeSettings" )
	Options.Buttions:setDataSource( "GameModeSettingsButtons" )
	self:addElement( Options )
	self.Options = Options
	
	local GameSettingsSelectedItemInfo = CoD.GameSettings_SelectedItemInfo.new( menu, controller )
	GameSettingsSelectedItemInfo:setLeftRight( true, true, 0, 0 )
	GameSettingsSelectedItemInfo:setTopBottom( true, true, -135, 0 )
	GameSettingsSelectedItemInfo.GameModeName:setAlpha( 0 )
	self:addElement( GameSettingsSelectedItemInfo )
	self.GameSettingsSelectedItemInfo = GameSettingsSelectedItemInfo
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 2 )
				Options:completeAnimation()
				Options.Title.DescTitle:completeAnimation()
				self.Options.Title.DescTitle:setText( Engine.Localize( "MENU_WIN_CONDITIONS_CAPS" ) )
				self.clipFinished( Options, {} )
				local f8_local0 = function ( f9_arg0, f9_arg1 )
					if not f9_arg1.interrupted then
						f9_arg0:beginAnimation( "keyframe", 250, false, false, CoD.TweenType.Linear )
						f9_arg0.GameModeInfo:beginAnimation( "subkeyframe", 250, false, false, CoD.TweenType.Linear )
					end
					f9_arg0.GameModeInfo:setAlpha( 1 )
					if f9_arg1.interrupted then
						self.clipFinished( f9_arg0, f9_arg1 )
					else
						f9_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				GameSettingsSelectedItemInfo:completeAnimation()
				GameSettingsSelectedItemInfo.GameModeInfo:completeAnimation()
				self.GameSettingsSelectedItemInfo.GameModeInfo:setAlpha( 0 )
				f8_local0( GameSettingsSelectedItemInfo, {} )
			end
		}
	}
	Options.id = "Options"
	self:registerEventHandler( "gain_focus", function ( element, event )
		if element.m_focusable and element.Options:processEvent( event ) then
			return true
		else
			return LUI.UIElement.gainFocus( element, event )
		end
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.Options:close()
		element.GameSettingsSelectedItemInfo:close()
	end )
	return self
end

DataSources.ChangeGameModeModesZM = DataSourceHelpers.ListSetup( "ChangeGameModeModesZM", function ( f4_arg0 )
	local f4_local0 = {}
	local f4_local1 = GetGametypesBaseZM()

	local f4_local2 = Engine.DvarString( nil, "zbr_gametype" )

	for f4_local6, f4_local7 in pairs( f4_local1 ) do
		if f4_local7.category == "standard" then
			table.insert( f4_local0, {
				models = {
					text = Engine.Localize( f4_local7.name ),
					buttonText = Engine.Localize( f4_local7.name ),
					image = f4_local7.image,
					description = Engine.Localize( f4_local7.description )
				},
				properties = {
					gametype = f4_local7.gametype,
					selectIndex = f4_local7.gametype == f4_local2
				}
			} )
		end
	end
	return f4_local0
end, true )

local ChangeGameModeZM_f0_local2 = function ( f5_arg0, f5_arg1 )
	LUI.OverrideFunction_CallOriginalFirst( f5_arg0, "setState", function ( element, controller )
		if IsSelfInState( f5_arg0, "Secondary" ) then
			f5_arg0.gameModeList:setMouseDisabled( true )
			f5_arg0.gamesList:setMouseDisabled( false )
			f5_arg0.m_modeSet = false
		else
			f5_arg0.gameModeList:setMouseDisabled( false )
			f5_arg0.gamesList:setMouseDisabled( true )
		end
	end )
	f5_arg0.gamesList:setMouseDisabled( true )
	f5_arg0.gamesList:registerEventHandler( "leftclick_outside", function ( element, event )
		if IsSelfInState( f5_arg0, "Secondary" ) and f5_arg0.m_modeSet then
			CoD.PCUtil.SimulateButtonPress( f5_arg1, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE )
		end
		f5_arg0.m_modeSet = true
		return true
	end )
end

local ChangeGameModeZM_PostLoadFunc = function ( f8_arg0, f8_arg1 )
	if CoD.isPC then
		ChangeGameModeZM_f0_local2( f8_arg0, f8_arg1 )
	end
	ChangeGameModeZM_f0_local1( f8_arg0, f8_arg1 )
end

DataSources.CustomGamesListZM = {
	prepare = function ( f661_arg0, f661_arg1, f661_arg2 )
		f661_arg1.showDefault = true
		f661_arg1.controller = f661_arg0
		f661_arg1.rootModel = Engine.CreateModel( Engine.GetGlobalModel(), "CustomGamesRoot" )
		f661_arg1.communityOptions = {
			{
				text = Engine.Localize( "MENU_POPULAR" ),
				image = "img_t7_menu_startmenu_media_recent",
				description = Engine.Localize( "MENU_FILESHARE_PUBLISH_DESCRIPTION" ),
				action = OpenPopularCustomGames
			},
			{
				text = Engine.Localize( "MENU_TRENDING" ),
				image = "img_t7_menu_startmenu_media_popular",
				description = Engine.Localize( "MENU_FILESHARE_PUBLISH_DESCRIPTION" ),
				action = OpenTrendingCustomGames
			},
			{
				text = Engine.Localize( "MENU_RECENT" ),
				image = "img_t7_menu_startmenu_media_trending",
				description = Engine.Localize( "MENU_FILESHARE_PUBLISH_DESCRIPTION" ),
				action = OpenrRecentCustomGames
			}
		}
		local f661_local0 = CoD.zbr_ui_gametype
		if f661_local0 == "" then
			local f661_local1 = Engine.CreateModel( Engine.GetGlobalModel(), "CustomGamesRoot" )
			local f661_local2 = Engine.GetModelValue( Engine.CreateModel( f661_local1, "communityOption" ) )
			local f661_local3 = Engine.GetModelValue( Engine.CreateModel( f661_local1, "showcaseOption" ) )
			if f661_local2 then
				f661_arg1.numFiles = 3
				f661_arg1.communityOption = true
			elseif f661_local3 then
				f661_arg1.numFiles = 0
			end
		else
			f661_arg1.officialGameCount = 1
			f661_arg1.customGameCount = 0
			f661_arg1.communityOption = false
			f661_arg1.numFiles = f661_arg1.officialGameCount + f661_arg1.customGameCount
			if f661_arg1.showDefault == true then
				f661_arg1.numFiles = f661_arg1.numFiles + 1
			end
		end
	end,
	getCount = function ( f662_arg0 )
		return f662_arg0.numFiles
	end,
	getItem = function ( f663_arg0, f663_arg1, f663_arg2 )
		local f663_local0 = Engine.CreateModel( f663_arg1.rootModel, "CustomGames_" .. f663_arg2 )
		local f663_local1 = CoD.zbr_ui_gametype
		Engine.SetModelValue( Engine.CreateModel( f663_local0, "uiIndex" ), f663_arg2 )
		if f663_arg1.communityOption == true then
			local f663_local2 = f663_arg1.communityOptions[f663_arg2]
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "text" ), f663_local2.text )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "buttonText" ), f663_local2.text )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "image" ), f663_local2.image )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "description" ), f663_local2.description )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "action" ), f663_local2.action )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "isOfficial" ), false )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "isCommunityOption" ), true )
			return f663_local0
		elseif f663_arg1.showDefault == true and f663_arg2 == 1 then
			local f663_local2 = GetGametypesBaseZM()
			local f663_local3 = CoD.zbr_ui_gametype
			local f663_local4 = ""
			local descr = ""
			for f663_local8, f663_local9 in pairs( f663_local2 ) do
				if f663_local9.category == "standard" and f663_local9.gametype == f663_local3 then
					f663_local4 = "^BBUTTON_CUSTOMGAME_ICON^ " .. Engine.Localize( f663_local9.name )
					descr = f663_local9.description
					break
				end
			end
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "text" ), f663_local4 )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "buttonText" ), f663_local4 )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "inUse" ), true )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "isOfficial" ), true )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "isCommunityOption" ), false )
			if f663_local1 then
				Engine.SetModelValue( Engine.CreateModel( f663_local0, "description" ), Engine.Localize( descr ) )
			end
		else
			local f663_local2 = 1
			if f663_arg1.showDefault == true then
				f663_local2 = 2
			end
			local f663_local3 = f663_arg2 - f663_local2
			local f663_local4 = false
			if f663_local3 < f663_arg1.officialGameCount then
				f663_local4 = true
			else
				f663_local3 = f663_local3 - f663_arg1.officialGameCount
			end
			local f663_local5 = Engine.GetCustomGameData( f663_arg0, f663_local3, CoD.zbr_ui_gametype, f663_local4 )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "slot" ), f663_local5.slot )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "index" ), f663_local5.index )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "gameName" ), f663_local5.gameName )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "inUse" ), f663_local5.inUse )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "isOfficial" ), f663_local5.isOfficial )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "isCommunityOption" ), false )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "createTime" ), f663_local5.createTime )
			if f663_local5.isOfficial then
				Engine.SetModelValue( Engine.CreateModel( f663_local0, "text" ), "^BBUTTON_CUSTOMGAME_ICON^ " .. Engine.Localize( f663_local5.gameName ) )
				Engine.SetModelValue( Engine.CreateModel( f663_local0, "buttonText" ), "^BBUTTON_CUSTOMGAME_ICON^ " .. Engine.Localize( f663_local5.gameName ) )
			else
				Engine.SetModelValue( Engine.CreateModel( f663_local0, "text" ), f663_local5.gameName )
				Engine.SetModelValue( Engine.CreateModel( f663_local0, "buttonText" ), f663_local5.gameName )
			end
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "gameTypeString" ), f663_local5.gameTypeString )
			if f663_local1 then
				if f663_local5.isOfficial then
					Engine.SetModelValue( Engine.CreateModel( f663_local0, "description" ), Engine.Localize( f663_local5.gameDescription ) )
					Engine.SetModelValue( Engine.CreateModel( f663_local0, "gameDescription" ), Engine.Localize( f663_local5.gameDescription ) )
				else
					Engine.SetModelValue( Engine.CreateModel( f663_local0, "description" ), f663_local5.gameDescription )
					Engine.SetModelValue( Engine.CreateModel( f663_local0, "gameDescription" ), f663_local5.gameDescription )
				end
			end
		end
		if f663_local1 then
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "gametype" ), f663_local1 )
			Engine.SetModelValue( Engine.CreateModel( f663_local0, "image" ), GetGametypeDataZBR(f663_local1).image )
		end
		return f663_local0
	end
}

function ZBRGameModeSelected( f1275_arg0, f1275_arg1 )
	-- Engine.Exec( f1275_arg1, "resetCustomGametype" )
	local f1275_local0 = CoDShared.IsGametypeTeamBased()
	local f1275_local1 = "zclassic"
	if f1275_local1 == "" then
		return 
	end
	Engine.SetDvar("zbr_gametype", CoD.zbr_ui_gametype)
	Engine.SetModelValue(zbrgtmodel, CoD.zbr_ui_gametype)
	-- TODO: zbr gametype changed callback
	ZBR.SetUIGametype(CoD.zbr_ui_gametype)
	CoD.GametypeUpdateEvent()
	ZBR.RepLobbystate()
	Engine.SetGametype( f1275_local1 )
	if f1275_local0 ~= CoDShared.IsGametypeTeamBased() then
		Engine.SetDvar( "bot_friends", 0 )
		Engine.SetDvar( "bot_enemies", 0 )
	end
	Engine.Exec( f1275_arg1, "xupdatepartystate" )
	Engine.SetProfileVar( f1275_arg1, CoD.profileKey_gametype, f1275_local1 )
	Engine.PartyHostClearUIState()
	Engine.CommitProfileChanges( f1275_arg1 )
	Engine.SystemNeedsUpdate( nil, "lobby" )
	Engine.LobbyVM_CallFunc( "OnGametypeSettingsChange", {
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyModule = Enum.LobbyModule.LOBBY_MODULE_HOST
	} )
end

LUI.createMenu.ChangeGameModeZM = function ( controller )
	local self = CoD.Menu.NewForUIEditor( "ChangeGameModeZM" )
	if ChangeGameModeZM_PreLoadFunc then
		ChangeGameModeZM_PreLoadFunc( self, controller )
	end
	self.soundSet = "default"
	self:setOwner( controller )
	self:setLeftRight( true, true, 0, 0 )
	self:setTopBottom( true, true, 0, 0 )
	self:playSound( "menu_open", controller )
	self.buttonModel = Engine.CreateModel( Engine.GetModelForController( controller ), "ChangeGameMode.buttonPrompts" )
	local f9_local1 = self
	self.anyChildUsesUpdateState = true
	
	local LeftPanel = CoD.FE_ButtonPanelShaderContainer.new( f9_local1, controller )
	LeftPanel:setLeftRight( true, true, -45, 35 )
	LeftPanel:setTopBottom( true, true, -43, 102 )
	LeftPanel:setRGB( 0.31, 0.31, 0.31 )
	self:addElement( LeftPanel )
	self.LeftPanel = LeftPanel
	
	local FadeForStreamer = CoD.LobbyStreamerBlackFade.new( f9_local1, controller )
	FadeForStreamer:setLeftRight( true, false, 0, 1280 )
	FadeForStreamer:setTopBottom( true, false, 0, 720 )
	FadeForStreamer:mergeStateConditions( {
		{
			stateName = "Transparent",
			condition = function ( menu, element, event )
				return IsGlobalModelValueEqualTo( element, controller, "hideWorldForStreamer", 0 )
			end
		}
	} )
	FadeForStreamer:subscribeToModel( Engine.GetModel( Engine.GetGlobalModel(), "hideWorldForStreamer" ), function ( modelRef )
		f9_local1:updateElementState( FadeForStreamer, {
			name = "model_validation",
			menu = f9_local1,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "hideWorldForStreamer"
		} )
	end )
	self:addElement( FadeForStreamer )
	self.FadeForStreamer = FadeForStreamer
	
	local frame = CoD.GenericMenuFrame.new( f9_local1, controller )
	frame:setLeftRight( true, true, 0, 0 )
	frame:setTopBottom( true, true, 0, 0 )
	frame.titleLabel:setText( Engine.Localize( "MPUI_CHANGE_GAME_MODE_CAPS" ) )
	frame.cac3dTitleIntermediary0.FE3dTitleContainer0.MenuTitle.TextBox1.Label0:setText( Engine.Localize( "MPUI_CHANGE_GAME_MODE_CAPS" ) )
	self:addElement( frame )
	self.frame = frame
	
	local gameModeList = LUI.UIList.new( f9_local1, controller, 2, 0, nil, false, false, 0, 0, false, false )
	gameModeList:makeFocusable()
	gameModeList:setLeftRight( true, false, 64, 344 )
	gameModeList:setTopBottom( true, false, 109, 651 )
	gameModeList:setWidgetType( CoD.List1Button_Playlist )
	gameModeList:setVerticalCount( 16 )
	gameModeList:setDataSource( "ChangeGameModeModesZM" )
	gameModeList:linkToElementModel( gameModeList, "disabled", true, function ( modelRef )
		local f12_local0 = gameModeList
		local f12_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "disabled"
		}
		CoD.Menu.UpdateButtonShownState( f12_local0, f9_local1, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
	end )
	gameModeList:registerEventHandler( "list_item_lose_focus", function ( element, event )
		return nil
	end )
	gameModeList:registerEventHandler( "list_item_gain_focus", function ( element, event )
		local f14_local0 = nil
		CoD.zbr_ui_gametype = element.gametype
		-- TODO Engine.SetDvar("zbr_gametype", element.gametype)
		SetElementModelToFocusedElementModel( self, element, "gameModeInfo" )
		return f14_local0
	end )
	gameModeList:registerEventHandler( "gain_focus", function ( element, event )
		local f15_local0 = nil
		if element.gainFocus then
			f15_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f15_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f9_local1, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		return f15_local0
	end )
	gameModeList:registerEventHandler( "lose_focus", function ( element, event )
		local f16_local0 = nil
		if element.loseFocus then
			f16_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f16_local0 = element.super:loseFocus( event )
		end
		return f16_local0
	end )
	f9_local1:AddButtonCallbackFunction( gameModeList, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f17_arg0, f17_arg1, f17_arg2, f17_arg3 )
		if IsElementPropertyValue( f17_arg0, "showcase", true ) then
			CustomGamesOpenMyShowcase( self, f17_arg2 )
			return true
		elseif IsMenuInState( f17_arg1, "DefaultState" ) then
			SetState( self, "Secondary" )
			SetLoseFocusToElement( self, "gameModeList", f17_arg2 )
			MakeElementNotFocusable( self, "gameModeList", f17_arg2 )
			MakeElementFocusable( self, "gamesList", f17_arg2 )
			SetFocusToElement( self, "gamesList", f17_arg2 )
			return true
		elseif not IsDisabled( f17_arg0, f17_arg2 ) and AlwaysFalse() then
			ZBRGameModeSelected( f17_arg0, f17_arg2 )
			GoBack( self, f17_arg2 )
			ClearSavedState( self, f17_arg2 )
			PlaySoundSetSound( self, "action" )
			return true
		else
			
		end
	end, function ( f18_arg0, f18_arg1, f18_arg2 )
		CoD.Menu.SetButtonLabel( f18_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		if IsElementPropertyValue( f18_arg0, "showcase", true ) then
			return true
		elseif IsMenuInState( f18_arg1, "DefaultState" ) then
			return true
		elseif not IsDisabled( f18_arg0, f18_arg2 ) and AlwaysFalse() then
			return true
		else
			return false
		end
	end, true )
	gameModeList:mergeStateConditions( {
		{
			stateName = "Disabled_NoListFocus",
			condition = function ( menu, element, event )
				local f19_local0
				if not IsParentListInFocus( element ) then
					f19_local0 = IsDisabled( element, controller )
				else
					f19_local0 = false
				end
				return f19_local0
			end
		},
		{
			stateName = "NoListFocus",
			condition = function ( menu, element, event )
				return not IsParentListInFocus( element )
			end
		}
	} )
	gameModeList:linkToElementModel( gameModeList, "disabled", true, function ( modelRef )
		f9_local1:updateElementState( gameModeList, {
			name = "model_validation",
			menu = f9_local1,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "disabled"
		} )
	end )
	self:addElement( gameModeList )
	self.gameModeList = gameModeList
	
	local gamesList = LUI.UIList.new( f9_local1, controller, 2, 0, nil, false, false, 0, 0, false, false )
	gamesList:makeFocusable()
	gamesList:setLeftRight( true, false, 375, 655 )
	gamesList:setTopBottom( true, false, 109, 651 )
	gamesList:setWidgetType( CoD.List1Button_Playlist )
	gamesList:setVerticalCount( 16 )
	gamesList:setDataSource( "CustomGamesListZM" )
	gamesList:linkToElementModel( gamesList, "disabled", true, function ( modelRef )
		local f22_local0 = gamesList
		local f22_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "disabled"
		}
		CoD.Menu.UpdateButtonShownState( f22_local0, f9_local1, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
	end )
	gamesList:linkToElementModel( gamesList, "isOfficial", true, function ( modelRef )
		local f23_local0 = gamesList
		local f23_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "isOfficial"
		}
		CoD.Menu.UpdateButtonShownState( f23_local0, f9_local1, controller, Enum.LUIButton.LUI_KEY_START )
	end )
	gamesList:linkToElementModel( gamesList, "isCommunityOption", true, function ( modelRef )
		local f24_local0 = gamesList
		local f24_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "isCommunityOption"
		}
		CoD.Menu.UpdateButtonShownState( f24_local0, f9_local1, controller, Enum.LUIButton.LUI_KEY_START )
	end )
	gamesList:registerEventHandler( "list_item_gain_focus", function ( element, event )
		local f25_local0 = nil
		SetSelectedCustomGame( element, controller )
		CustomGameSelectorLoseFocus( self, element, controller, f9_local1 )
		UpdateElementState( self, "CustomGameOfficial", controller )
		SetElementModelToFocusedElementModel( self, element, "gameModeInfo" )
		return f25_local0
	end )
	gamesList:registerEventHandler( "lose_list_focus", function ( element, event )
		local f26_local0 = nil
		UpdateElementState( self, "CustomGameOfficial", controller )
		return f26_local0
	end )
	gamesList:registerEventHandler( "gain_focus", function ( element, event )
		local f27_local0 = nil
		if element.gainFocus then
			f27_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f27_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f9_local1, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		CoD.Menu.UpdateButtonShownState( element, f9_local1, controller, Enum.LUIButton.LUI_KEY_START )
		return f27_local0
	end )
	gamesList:registerEventHandler( "lose_focus", function ( element, event )
		local f28_local0 = nil
		if element.loseFocus then
			f28_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f28_local0 = element.super:loseFocus( event )
		end
		return f28_local0
	end )
	f9_local1:AddButtonCallbackFunction( gamesList, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f29_arg0, f29_arg1, f29_arg2, f29_arg3 )
		if IsCustomGameCommunityOption() then
			ProcessListAction( self, f29_arg0, f29_arg2 )
			return true
		elseif not IsDisabled( f29_arg0, f29_arg2 ) then
			-- LoadCustomGame( f29_arg0, f29_arg2 )
			-- SetCurrentCustomGame( f29_arg0, f29_arg2 )
			ZBRGameModeSelected( f29_arg0, f29_arg2 )
			SetPrimaryControllerPerControllerTableProperty( "gamesettingsUpdated", true )
			GoBack( self, f29_arg2 )
			ClearSavedState( self, f29_arg2 )
			PlaySoundSetSound( self, "action" )
			return true
		else
			
		end
	end, function ( f30_arg0, f30_arg1, f30_arg2 )
		if IsCustomGameCommunityOption() then
			CoD.Menu.SetButtonLabel( f30_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
			return true
		elseif not IsDisabled( f30_arg0, f30_arg2 ) then
			CoD.Menu.SetButtonLabel( f30_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
			return true
		else
			return false
		end
	end, false )
	f9_local1:AddButtonCallbackFunction( gamesList, controller, Enum.LUIButton.LUI_KEY_START, "O", function ( f31_arg0, f31_arg1, f31_arg2, f31_arg3 )
		if not IsSelfModelValueTrue( f31_arg0, f31_arg2, "isOfficial" ) and not IsSelfModelValueTrue( f31_arg0, f31_arg2, "isCommunityOption" ) then
			CustomGamesOpenOptions( self, f31_arg2, f31_arg1 )
			return true
		else
			
		end
	end, function ( f32_arg0, f32_arg1, f32_arg2 )
		if not IsSelfModelValueTrue( f32_arg0, f32_arg2, "isOfficial" ) and not IsSelfModelValueTrue( f32_arg0, f32_arg2, "isCommunityOption" ) then
			CoD.Menu.SetButtonLabel( f32_arg1, Enum.LUIButton.LUI_KEY_START, "MENU_OPTIONS" )
			return true
		else
			return false
		end
	end, false )
	gamesList:subscribeToGlobalModel( controller, "CustomGamesRoot", "dirty", function ( modelRef )
		UpdateDataSource( self, gamesList, controller )
	end )
	gamesList:mergeStateConditions( {
		{
			stateName = "Disabled_NoListFocus",
			condition = function ( menu, element, event )
				local f34_local0
				if not IsParentListInFocus( element ) then
					f34_local0 = IsDisabled( element, controller )
				else
					f34_local0 = false
				end
				return f34_local0
			end
		},
		{
			stateName = "NoListFocus",
			condition = function ( menu, element, event )
				return not IsParentListInFocus( element )
			end
		}
	} )
	gamesList:linkToElementModel( gamesList, "disabled", true, function ( modelRef )
		f9_local1:updateElementState( gamesList, {
			name = "model_validation",
			menu = f9_local1,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "disabled"
		} )
	end )
	self:addElement( gamesList )
	self.gamesList = gamesList
	
	local gameModeInfo = CoD.matchSettingsInfo.new( f9_local1, controller )
	gameModeInfo:setLeftRight( true, false, 687, 1137 )
	gameModeInfo:setTopBottom( true, false, 109, 659 )
	gameModeInfo.FRBestTime.BestTimeValueText:setText( Engine.Localize( "--:--:--" ) )
	gameModeInfo:mergeStateConditions( {
		{
			stateName = "AspectRatio_1x1",
			condition = function ( menu, element, event )
				return AlwaysTrue()
			end
		}
	} )
	self:addElement( gameModeInfo )
	self.gameModeInfo = gameModeInfo
	
	local FEMenuLeftGraphics = CoD.FE_Menu_LeftGraphics.new( f9_local1, controller )
	FEMenuLeftGraphics:setLeftRight( true, false, 19, 71 )
	FEMenuLeftGraphics:setTopBottom( true, false, 84, 701.25 )
	self:addElement( FEMenuLeftGraphics )
	self.FEMenuLeftGraphics = FEMenuLeftGraphics
	
	local CustomGameOfficial = CoD.CustomGameOfficial.new( f9_local1, controller )
	CustomGameOfficial:setLeftRight( true, false, 687, 817 )
	CustomGameOfficial:setTopBottom( true, false, 615.53, 635.53 )
	CustomGameOfficial:mergeStateConditions( {
		{
			stateName = "Visible",
			condition = function ( menu, element, event )
				local f38_local0 = IsCustomMPLobby()
				if f38_local0 then
					f38_local0 = IsSelfModelValueTrue( element, controller, "isOfficial" )
					if f38_local0 then
						f38_local0 = IsWidgetInFocus( self, "gamesList", event )
					end
				end
				return f38_local0
			end
		}
	} )
	CustomGameOfficial:subscribeToModel( Engine.GetModel( Engine.GetGlobalModel(), "lobbyRoot.lobbyNav" ), function ( modelRef )
		f9_local1:updateElementState( CustomGameOfficial, {
			name = "model_validation",
			menu = f9_local1,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end )
	CustomGameOfficial:linkToElementModel( CustomGameOfficial, "isOfficial", true, function ( modelRef )
		f9_local1:updateElementState( CustomGameOfficial, {
			name = "model_validation",
			menu = f9_local1,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "isOfficial"
		} )
	end )
	self:addElement( CustomGameOfficial )
	self.CustomGameOfficial = CustomGameOfficial
	
	gameModeInfo:linkToElementModel( gameModeList, nil, false, function ( modelRef )
		gameModeInfo:setModel( modelRef, controller )
	end )
	CustomGameOfficial:linkToElementModel( gamesList, nil, false, function ( modelRef )
		CustomGameOfficial:setModel( modelRef, controller )
	end )
	gameModeList.navigation = {
		right = gamesList
	}
	gamesList.navigation = {
		left = gameModeList
	}
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 4 )
				frame:completeAnimation()
				self.frame:setAlpha( 1 )
				self.clipFinished( frame, {} )
				gameModeList:completeAnimation()
				self.gameModeList:setAlpha( 1 )
				self.clipFinished( gameModeList, {} )
				gamesList:completeAnimation()
				self.gamesList:setAlpha( 0 )
				self.clipFinished( gamesList, {} )
				gameModeInfo:completeAnimation()
				self.gameModeInfo:setAlpha( 1 )
				self.clipFinished( gameModeInfo, {} )
			end
		},
		Secondary = {
			DefaultClip = function ()
				self:setupElementClipCounter( 1 )
				gamesList:completeAnimation()
				self.gamesList:setAlpha( 1 )
				self.clipFinished( gamesList, {} )
			end
		}
	}
	CoD.Menu.AddNavigationHandler( f9_local1, self, controller )
	self:registerEventHandler( "menu_opened", function ( element, event )
		local f45_local0 = nil
		SetElementStateByElementName( self, "frame", controller, "Update" )
		PlayClipOnElement( self, {
			elementName = "frame",
			clipName = "Intro"
		}, controller )
		PlayClip( self, "Intro", controller )
		if not f45_local0 then
			f45_local0 = element:dispatchEventToChildren( event )
		end
		return f45_local0
	end )
	self:registerEventHandler( "menu_loaded", function ( element, event )
		local f46_local0 = nil
		MakeElementNotFocusable( self, "gamesList", controller )
		if not f46_local0 then
			f46_local0 = element:dispatchEventToChildren( event )
		end
		return f46_local0
	end )
	f9_local1:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, nil, function ( f47_arg0, f47_arg1, f47_arg2, f47_arg3 )
		if IsMenuInState( f47_arg1, "Secondary" ) then
			SetElementState( self, f47_arg0, f47_arg2, "DefaultState" )
			SetState( self, "DefaultState" )
			SetLoseFocusToElement( self, "gamesList", f47_arg2 )
			MakeElementNotFocusable( self, "gamesList", f47_arg2 )
			MakeElementFocusable( self, "gameModeList", f47_arg2 )
			SetFocusToElement( self, "gameModeList", f47_arg2 )
			return true
		else
			GoBack( self, f47_arg2 )
			CoD.zbr_ui_gametype = Engine.DvarString( nil, "zbr_gametype" )
			ClearSavedState( self, f47_arg2 )
			return true
		end
	end, function ( f48_arg0, f48_arg1, f48_arg2 )
		CoD.Menu.SetButtonLabel( f48_arg1, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, "MENU_BACK" )
		return true
	end, true )
	frame:setModel( self.buttonModel, controller )
	gameModeList.id = "gameModeList"
	gamesList.id = "gamesList"
	self:processEvent( {
		name = "menu_loaded",
		controller = controller
	} )
	self:processEvent( {
		name = "update_state",
		menu = f9_local1
	} )
	if not self:restoreState() then
		self.gameModeList:processEvent( {
			name = "gain_focus",
			controller = controller
		} )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.LeftPanel:close()
		element.FadeForStreamer:close()
		element.frame:close()
		element.gameModeList:close()
		element.gamesList:close()
		element.gameModeInfo:close()
		element.FEMenuLeftGraphics:close()
		element.CustomGameOfficial:close()
		Engine.UnsubscribeAndFreeModel( Engine.GetModel( Engine.GetModelForController( controller ), "ChangeGameMode.buttonPrompts" ) )
	end )
	if ChangeGameModeZM_PostLoadFunc then
		ChangeGameModeZM_PostLoadFunc( self, controller )
	end
	
	return self
end

CoD.LobbyBase.OpenChangeGameModeZM = function ( f86_arg0, f86_arg1 )
	CoD.LobbyBase.SetLeaderActivity( f86_arg1, CoD.LobbyBase.LeaderActivity.CHOOSING_GAME_MODE )
	LUI.OverrideFunction_CallOriginalFirst( OpenOverlay( f86_arg0, "ChangeGameModeZM", f86_arg1 ), "close", function ()
		CoD.LobbyBase.ResetLeaderActivity( f86_arg1 )
	end )
end

function OpenChangeGameModeZM( f203_arg0, f203_arg1, f203_arg2, f203_arg3, f203_arg4 )
	CoD.LobbyBase.OpenChangeGameModeZM( f203_arg0, f203_arg2 )
end

local gamesettingszm_f0 = function ( f1_arg0, f1_arg1 )
	if not CoD.useMouse then
		return 
	else
		f1_arg0.Options:setHandleMouse( true )
		f1_arg0.Options:registerEventHandler( "leftclick_outside", function ( element, event )
			CoD.PCUtil.SimulateButtonPress( event.controller, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE )
			return true
		end )
	end
end

local gszmPostLoadFunc = function ( f3_arg0, f3_arg1 )
	gamesettingszm_f0( f3_arg0, f3_arg1 )
	f3_arg0.disableBlur = true
	f3_arg0.disablePopupOpenCloseAnim = true
	Engine.SetModelValue( Engine.CreateModel( Engine.GetGlobalModel(), "GameSettingsFlyoutOpen" ), true )
	LUI.OverrideFunction_CallOriginalSecond( f3_arg0, "close", function ( element )
		Engine.SetModelValue( Engine.CreateModel( Engine.GetGlobalModel(), "GameSettingsFlyoutOpen" ), false )
	end )
	f3_arg0:registerEventHandler( "occlusion_change", function ( element, event )
		local f5_local0 = element:getParent()
		if f5_local0 then
			local f5_local1 = f5_local0:getFirstChild()
			while f5_local1 ~= nil do
				if f5_local1.menuName == "Lobby" then
					break
				end
				f5_local1 = f5_local1:getNextSibling()
			end
			if f5_local1 then
				if event.occluded == true then
					f5_local1:setAlpha( 0 )
				end
				f5_local1:setAlpha( 1 )
			end
		end
		element:OcclusionChange( event )
	end )
	f3_arg0:subscribeToModel( Engine.CreateModel( Engine.GetGlobalModel(), "lobbyRoot.lobbyNav", true ), function ( modelRef )
		local f6_local0 = f3_arg0.occludedBy
		while f6_local0 do
			if f6_local0.occludedBy ~= nil then
				f6_local0 = f6_local0.occludedBy
			end
			while f6_local0 and f6_local0.menuName ~= "Lobby" do
				f6_local0 = GoBack( f6_local0, f3_arg1 )
			end
			Engine.SendClientScriptNotify( f3_arg1, "menu_change" .. Engine.GetLocalClientNum( f3_arg1 ), "Main", "closeToMenu" )
			return 
		end
		GoBack( f3_arg0, f3_arg1 )
	end, false )
end

function OpenEditGameRulesZM( f204_arg0, f204_arg1, f204_arg2, f204_arg3, f204_arg4 )
	CoD.LobbyBase.OpenEditGameRulesZM( f204_arg0, f204_arg2 )
end

CoD.LobbyBase.OpenEditGameRulesZM = function ( f88_arg0, f88_arg1 )
	CoD.LobbyBase.SetLeaderActivity( f88_arg1, CoD.LobbyBase.LeaderActivity.EDITING_GAME_RULES )
	LUI.OverrideFunction_CallOriginalFirst( OpenOverlay( f88_arg0, "GameSettings_Main", f88_arg1 ), "close", function ()
		CoD.LobbyBase.ResetLeaderActivity( f88_arg1 )
	end )
end

DataSources.GameSettingsTabs = ListHelper_SetupDataSource( "GameSettingsTabs", function ( f45_arg0 )
	local f45_local0 = {}
	local f45_local1 = GetGametypeDataZBR(CoD.zbr_ui_gametype).name_caps
	table.insert( f45_local0, {
		models = {
			tabIcon = CoD.buttonStrings.shoulderl
		},
		properties = {
			m_mouseDisabled = true
		}
	} )
	table.insert( f45_local0, {
		models = {
			tabName = f45_local1,
			tabWidget = "CoD.GameSettings_GameModeRules",
			tabIcon = ""
		},
		properties = {
			tabId = "game_mode_rules"
		}
	} )
	-- table.insert( f45_local0, {
	-- 	models = {
	-- 		tabName = "MENU_GLOBAL_SETTINGS",
	-- 		tabWidget = "CoD.GameSettings_GlobalSettings",
	-- 		tabIcon = ""
	-- 	},
	-- 	properties = {
	-- 		tabId = "global_settings"
	-- 	}
	-- } )
	table.insert( f45_local0, {
		models = {
			tabIcon = CoD.buttonStrings.shoulderr
		},
		properties = {
			m_mouseDisabled = true
		}
	} )
	return f45_local0
end, true )

local function lobby_on_lb( f135_arg0, f135_arg1, f135_arg2, f135_arg3 )
	if not IsRepeatButtonPress( f135_arg3 ) and IsLobbyWithTeamAssignment() and not IsTeamAssignment( LuaEnums.TEAM_ASSIGNMENT.HOST ) and CanSwitchTeams() then
		LobbyTeamSelectionLB( CoD.zbr_lobby_handle, f135_arg0, f135_arg2 )
		PlaySoundSetSound( CoD.zbr_lobby_handle, "team_switch" )
		return true
	elseif IsMenuInState( f135_arg1, "Left" ) and FeaturedCards_IsEnabled( f135_arg0, f135_arg2 ) and not IsGameLobbyExcept( "ZMLobbyOnline" ) and not IsLobbyWithTeamAssignment() then
		FeaturedCardsGetPreviousCard( CoD.zbr_lobby_handle, f135_arg0, f135_arg2, "", f135_arg1 )
		FeaturedCardsResetTimer( CoD.zbr_lobby_handle, f135_arg0, f135_arg2, "", f135_arg1 )
		return true
	else
		
	end
end

local function lobby_cond_lb( f136_arg0, f136_arg1, f136_arg2 )
	if not IsRepeatButtonPress( nil ) and IsLobbyWithTeamAssignment() and not IsTeamAssignment( LuaEnums.TEAM_ASSIGNMENT.HOST ) and CanSwitchTeams() then
		CoD.Menu.SetButtonLabel( f136_arg1, Enum.LUIButton.LUI_KEY_LB, "MPUI_CHANGE_ROLE" )
		return true
	elseif IsMenuInState( f136_arg1, "Left" ) and FeaturedCards_IsEnabled( f136_arg0, f136_arg2 ) and not IsGameLobbyExcept( "ZMLobbyOnline" ) and not IsLobbyWithTeamAssignment() then
		CoD.Menu.SetButtonLabel( f136_arg1, Enum.LUIButton.LUI_KEY_LB, "" )
		return false
	else
		return false
	end
end

local function lobby_on_rb( f137_arg0, f137_arg1, f137_arg2, f137_arg3 )
	if not IsRepeatButtonPress( f137_arg3 ) and IsLobbyWithTeamAssignment() and not IsTeamAssignment( LuaEnums.TEAM_ASSIGNMENT.HOST ) and CanSwitchTeams() then
		LobbyTeamSelectionRB( CoD.zbr_lobby_handle, f137_arg0, f137_arg2 )
		PlaySoundSetSound( CoD.zbr_lobby_handle, "team_switch" )
		return true
	elseif IsMenuInState( f137_arg1, "Left" ) and FeaturedCards_IsEnabled( f137_arg0, f137_arg2 ) and not IsGameLobbyExcept( "ZMLobbyOnline" ) and not IsLobbyWithTeamAssignment() then
		FeaturedCardsGetNextCard( CoD.zbr_lobby_handle, f137_arg0, f137_arg2, "", f137_arg1 )
		FeaturedCardsResetTimer( CoD.zbr_lobby_handle, f137_arg0, f137_arg2, "", f137_arg1 )
		return true
	else
		
	end
end

local function lobby_cond_rb( f138_arg0, f138_arg1, f138_arg2 )
	if not IsRepeatButtonPress( nil ) and IsLobbyWithTeamAssignment() and not IsTeamAssignment( LuaEnums.TEAM_ASSIGNMENT.HOST ) and CanSwitchTeams() then
		CoD.Menu.SetButtonLabel( f138_arg1, Enum.LUIButton.LUI_KEY_RB, " " )
		return true
	elseif IsMenuInState( f138_arg1, "Left" ) and FeaturedCards_IsEnabled( f138_arg0, f138_arg2 ) and not IsGameLobbyExcept( "ZMLobbyOnline" ) and not IsLobbyWithTeamAssignment() then
		CoD.Menu.SetButtonLabel( f138_arg1, Enum.LUIButton.LUI_KEY_RB, "" )
		return false
	else
		return false
	end
end

_oldRegisterEventHandlers = CoD.LobbyBase.RegisterEventHandlers
CoD.LobbyBase.RegisterEventHandlers = function(arg1)
	_oldRegisterEventHandlers(arg1)
	if arg1.ClientList and arg1.MapVote then
		CoD.zbr_lobby_handle = arg1
		CoD.zbr_lobby_handle.buttonFunctions[Enum.LUIButton.LUI_KEY_LB] = lobby_on_lb
		CoD.zbr_lobby_handle.conditionFunctions[Enum.LUIButton.LUI_KEY_LB] = lobby_cond_lb
		CoD.zbr_lobby_handle.buttonFunctions[Enum.LUIButton.LUI_KEY_RB] = lobby_on_rb
		CoD.zbr_lobby_handle.conditionFunctions[Enum.LUIButton.LUI_KEY_RB] = lobby_cond_rb
	end
end

DataSources.GameSettingsFlyoutButtonsZM = DataSourceHelpers.ListSetup( "GameSettingsFlyoutButtonsZM", function ( f7_arg0 )
	local f7_local0 = {
		{
			optionDisplay = "MPUI_CHANGE_MAP_CAPS",
			customId = "btnChangeMap",
			action = OpenZMMapSelectSelect
		},
		{
			optionDisplay = "MPUI_CHANGE_GAME_MODE_CAPS",
			customId = "btnChangeGameMode",
			action = OpenChangeGameModeZM
		},
		{
			optionDisplay = "MPUI_EDIT_GAME_RULES_CAPS",
			customId = "btnEditGameRules",
			action = OpenEditGameRulesZM
		}
		-- {
		-- 	optionDisplay = "MENU_SETUP_BOTS_CAPS",
		-- 	customId = "btnSetupBots",
		-- 	action = OpenBotSettings
		-- }
	}
	-- if CoD.isPC and IsServerBrowserEnabled() then
	-- 	table.insert( f7_local0, {
	-- 		optionDisplay = "PLATFORM_SERVER_SETTINGS_CAPS",
	-- 		customID = "btnServerSettings",
	-- 		action = OpenServerSettings
	-- 	} )
	-- end
	local f7_local1 = {}
	for f7_local5, f7_local6 in ipairs( f7_local0 ) do
		table.insert( f7_local1, {
			models = {
				displayText = Engine.Localize( f7_local6.optionDisplay ),
				customId = f7_local6.customId,
				disabled = f7_local6.disabled
			},
			properties = {
				title = f7_local6.optionDisplay,
				desc = f7_local6.desc,
				action = f7_local6.action,
				actionParam = f7_local6.actionParam
			}
		} )
	end
	return f7_local1
end, nil, nil, nil )

function OpenSetupGameZM( f194_arg0, f194_arg1, f194_arg2, f194_arg3, f194_arg4 )
	CoD.LobbyBase.OpenSetupGame( f194_arg4, f194_arg2, "GameSettingsFlyoutZBR" )
end

LUI.createMenu.GameSettingsFlyoutZBR = function ( controller )
	local self = CoD.Menu.NewForUIEditor( "GameSettingsFlyoutZBR" )
	self.soundSet = "default"
	self:setOwner( controller )
	self:setLeftRight( true, true, 0, 0 )
	self:setTopBottom( true, true, 0, 0 )
	self:playSound( "menu_open", controller )
	self.buttonModel = Engine.CreateModel( Engine.GetModelForController( controller ), "GameSettingsFlyoutZBR.buttonPrompts" )
	local f8_local1 = self
	self.anyChildUsesUpdateState = true
	
	local Options = LUI.UIList.new( f8_local1, controller, -2, 0, nil, false, false, 0, 0, false, false )
	Options:makeFocusable()
	Options:setLeftRight( true, false, 243.43, 523.43 )
	Options:setTopBottom( true, false, 177.56, 329.56 )
	Options:setYRot( 25 )
	Options:setWidgetType( CoD.FE_List1ButtonLarge_PH )
	Options:setVerticalCount( 5 )
	Options:setSpacing( -2 )
	Options:setDataSource( "GameSettingsFlyoutButtonsZM" )
	Options:registerEventHandler( "gain_focus", function ( element, event )
		local f9_local0 = nil
		if element.gainFocus then
			f9_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f9_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f8_local1, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		return f9_local0
	end )
	Options:registerEventHandler( "lose_focus", function ( element, event )
		local f10_local0 = nil
		if element.loseFocus then
			f10_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f10_local0 = element.super:loseFocus( event )
		end
		return f10_local0
	end )
	f8_local1:AddButtonCallbackFunction( Options, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f11_arg0, f11_arg1, f11_arg2, f11_arg3 )
		ProcessListAction( self, f11_arg0, f11_arg2 )
		return true
	end, function ( f12_arg0, f12_arg1, f12_arg2 )
		CoD.Menu.SetButtonLabel( f12_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	self:addElement( Options )
	self.Options = Options
	
	self:mergeStateConditions( {
		{
			stateName = "Local",
			condition = function ( menu, element, event )
				return IsLobbyNetworkModeLAN()
			end
		}
	} )
	self:subscribeToModel( Engine.GetModel( Engine.GetGlobalModel(), "lobbyRoot.lobbyNetworkMode" ), function ( modelRef )
		local f14_local0 = self
		local f14_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "lobbyRoot.lobbyNetworkMode"
		}
		CoD.Menu.UpdateButtonShownState( f14_local0, f8_local1, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetGlobalModel(), "lobbyRoot.lobbyNav" ), function ( modelRef )
		local f15_local0 = self
		local f15_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "lobbyRoot.lobbyNav"
		}
		CoD.Menu.UpdateButtonShownState( f15_local0, f8_local1, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
	end )
	f8_local1:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, nil, function ( f16_arg0, f16_arg1, f16_arg2, f16_arg3 )
		GoBack( self, f16_arg2 )
		ClearMenuSavedState( f16_arg1 )
		return true
	end, function ( f17_arg0, f17_arg1, f17_arg2 )
		CoD.Menu.SetButtonLabel( f17_arg1, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, "" )
		return false
	end, false )
	f8_local1:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_START, "M", function ( f18_arg0, f18_arg1, f18_arg2, f18_arg3 )
		GoBackAndOpenOverlayOnParent( self, "StartMenu_Main", f18_arg2 )
		return true
	end, function ( f19_arg0, f19_arg1, f19_arg2 )
		CoD.Menu.SetButtonLabel( f19_arg1, Enum.LUIButton.LUI_KEY_START, "MENU_MENU" )
		return true
	end, false )
	f8_local1:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "S", function ( f20_arg0, f20_arg1, f20_arg2, f20_arg3 )
		if not IsLAN() and not IsPlayerAGuest( f20_arg2 ) and IsPlayerAllowedToPlayOnline( f20_arg2 ) then
			GoBackAndOpenOverlayOnParent( self, "Social_Main", f20_arg2 )
			return true
		else
			
		end
	end, function ( f21_arg0, f21_arg1, f21_arg2 )
		if not IsLAN() and not IsPlayerAGuest( f21_arg2 ) and IsPlayerAllowedToPlayOnline( f21_arg2 ) then
			CoD.Menu.SetButtonLabel( f21_arg1, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "" )
			return false
		else
			return false
		end
	end, false )
	f8_local1:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_LB, nil, function ( f22_arg0, f22_arg1, f22_arg2, f22_arg3 )
		SendButtonPressToOccludedMenu( f22_arg1, f22_arg2, f22_arg3, Enum.LUIButton.LUI_KEY_LB )
		return true
	end, function ( f23_arg0, f23_arg1, f23_arg2 )
		CoD.Menu.SetButtonLabel( f23_arg1, Enum.LUIButton.LUI_KEY_LB, "" )
		return false
	end, false )
	f8_local1:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_RB, nil, function ( f24_arg0, f24_arg1, f24_arg2, f24_arg3 )
		SendButtonPressToOccludedMenu( f24_arg1, f24_arg2, f24_arg3, Enum.LUIButton.LUI_KEY_RB )
		return true
	end, function ( f25_arg0, f25_arg1, f25_arg2 )
		CoD.Menu.SetButtonLabel( f25_arg1, Enum.LUIButton.LUI_KEY_RB, "" )
		return false
	end, false )
	Options.id = "Options"
	self:processEvent( {
		name = "menu_loaded",
		controller = controller
	} )
	self:processEvent( {
		name = "update_state",
		menu = f8_local1
	} )
	if not self:restoreState() then
		self.Options:processEvent( {
			name = "gain_focus",
			controller = controller
		} )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.Options:close()
		Engine.UnsubscribeAndFreeModel( Engine.GetModel( Engine.GetModelForController( controller ), "GameSettingsFlyoutZBR.buttonPrompts" ) )
	end )
	if gszmPostLoadFunc then
		gszmPostLoadFunc( self, controller )
	end
	
	return self
end

require( "ui.uieditor.widgets.gamesettings.gamesettings_matchsettingsinfo" )

local gamesettings_matchsettingsinfoPostLoadFunc = function ( self, controller, menu )
	local f1_local0 = CoD.zbr_ui_gametype

	local data = GetGametypeDataZBR(CoD.zbr_ui_gametype)

	local f1_local1 = data.image
	local f1_local2 = data.name_caps
	local f1_local3 = data.description
	self.image:setImage( RegisterImage( f1_local1 ) )
	self.GameSettingstexbox.TextBox:setText( Engine.Localize( f1_local3 ) )
	self.GameSettingstitlesecbox.Textbox:setText( Engine.Localize( f1_local2 ) )
end

CoD.GameSettings_MatchSettingsInfo = InheritFrom( LUI.UIElement )
CoD.GameSettings_MatchSettingsInfo.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.GameSettings_MatchSettingsInfo )
	self.id = "GameSettings_MatchSettingsInfo"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 489 )
	self:setTopBottom( true, false, 0, 321 )
	self.anyChildUsesUpdateState = true
	
	local BoxButtonLrgIdle = LUI.UIImage.new()
	BoxButtonLrgIdle:setLeftRight( true, false, -3, 296.38 )
	BoxButtonLrgIdle:setTopBottom( true, false, 15.45, 213.73 )
	BoxButtonLrgIdle:setAlpha( 0.25 )
	BoxButtonLrgIdle:setImage( RegisterImage( "uie_t7_menu_cac_buttonboxlrgidlefull" ) )
	BoxButtonLrgIdle:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_nineslice_add" ) )
	BoxButtonLrgIdle:setShaderVector( 0, 0.12, 0.12, 0, 0 )
	self:addElement( BoxButtonLrgIdle )
	self.BoxButtonLrgIdle = BoxButtonLrgIdle
	
	local Border = LUI.UIImage.new()
	Border:setLeftRight( true, false, 0, 293.38 )
	Border:setTopBottom( true, false, 18.45, 211.73 )
	Border:setAlpha( 0.5 )
	Border:setImage( RegisterImage( "uie_t7_menu_frontend_titlenumbrdrfull" ) )
	Border:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_nineslice_add" ) )
	Border:setShaderVector( 0, 0.03, 0.03, 0, 0 )
	Border:setupNineSliceShader( 4, 4 )
	self:addElement( Border )
	self.Border = Border
	
	local image = LUI.UIImage.new()
	image:setLeftRight( true, false, 61.69, 231.69 )
	image:setTopBottom( true, false, 30.09, 200.09 )
	image:setImage( RegisterImage( "uie_t7_menu_mp_icons_gamemode_graphic_groundwar" ) )
	self:addElement( image )
	self.image = image
	
	local GameSettingstitlesecbox = CoD.GameSettings_titlesecbox.new( menu, controller )
	GameSettingstitlesecbox:setLeftRight( true, false, 0, 352 )
	GameSettingstitlesecbox:setTopBottom( true, false, 224, 252 )
	GameSettingstitlesecbox:subscribeToGlobalModel( controller, "GametypeSettings", "zbrgametype", function ( modelRef )
		local gametype = Engine.GetModelValue( modelRef )
		if gametype then
			GameSettingstitlesecbox.Textbox:setText( Engine.Localize( LocalizeToUpperString( gametype ) ) )
		end
	end )
	self:addElement( GameSettingstitlesecbox )
	self.GameSettingstitlesecbox = GameSettingstitlesecbox
	
	local GameSettingstexbox = CoD.GameSettings_texbox.new( menu, controller )
	GameSettingstexbox:setLeftRight( true, false, 0, 489 )
	GameSettingstexbox:setTopBottom( true, false, 253, 278 )
	self:addElement( GameSettingstexbox )
	self.GameSettingstexbox = GameSettingstexbox
	
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.GameSettingstitlesecbox:close()
		element.GameSettingstexbox:close()
	end )
	
	if gamesettings_matchsettingsinfoPostLoadFunc then
		gamesettings_matchsettingsinfoPostLoadFunc( self, controller, menu )
	end
	
	return self
end

CoD.LobbyBase.ZMOpenChangeMap = function ( f83_arg0, f83_arg1, f83_arg2, f83_arg3 )
	CoD.LobbyBase.SetLeaderActivity( f83_arg1, CoD.LobbyBase.LeaderActivity.CHOOSING_MAP )
	local f83_local0 = OpenPopup( f83_arg0, "ZMMapSelection", f83_arg1 )
	f83_local0.selectType = f83_arg2
	f83_local0.data = f83_arg3
	LUI.OverrideFunction_CallOriginalFirst( f83_local0, "close", function ()
		if CoD.last_ugc_update ~= nil then
			MapImageToModPreview(CoD.last_ugc_update)
		end
		CoD.LobbyBase.ResetLeaderActivity( f83_arg1 )
		if f83_local0.selectType == CoD.LobbyBase.MapSelect.LAUNCH and f83_local0.mapSelected == true then
			if Engine.GetLobbyClientCount( Enum.LobbyModule.LOBBY_MODULE_HOST, Enum.LobbyType.LOBBY_TYPE_GAME, Enum.LobbyClientType.LOBBY_CLIENT_TYPE_ALL ) > 1 then
				LuaUtils.UI_ShowErrorMessageDialog( f83_arg1, "MENU_TOO_MANY_CLIENTS_FOR_SOLO_GAME" )
				return 
			end
			f83_local0.mapSelected = nil
			CoD.LobbyBase.LaunchGame( f83_local0, f83_arg1, Enum.LobbyType.LOBBY_TYPE_GAME )
		elseif f83_local0.selectType == CoD.LobbyBase.MapSelect.NAVIGATE then
			NavigateToLobby_OccludedMenu( f83_local0, element, f83_arg1, f83_local0.data, f83_local0 )
		elseif f83_local0.selectType == CoD.LobbyBase.MapSelect.SELECT then
			
		else
			
		end
	end )
end

registerVal11 = {}
registerVal11.stringRef = "MPUI_SETUP_GAME_CAPS"
registerVal11.action = OpenSetupGameZM
registerVal11.customId = "btnSetupGame"
registerVal11.disabledFunc = MapVoteTimerActive
CoD.LobbyButtons.ZM_CUSTOM_SETUP_GAME = registerVal11

registerVal11 = {}
registerVal11.stringRef = "MENU_FIND_ARENA_MATCH_CAPS"
registerVal11.action = NavigateToLobby_SelectionList
registerVal11.param = "MPLobbyOnlineArenaGame"
registerVal11.customId = "btnArenaFindMatch"
registerVal11.disabledFunc = __FUNC_4287_
registerVal11.unloadMod = true
CoD.LobbyButtons.MP_ARENA_FIND_MATCH = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_SELECT_ARENA_CAPS"
registerVal11.action = OpenCompetitivePlaylist
registerVal11.customId = "btnSelectArena"
registerVal11.disabledFunc = __FUNC_4287_
registerVal11.unloadMod = true
CoD.LobbyButtons.MP_ARENA_SELECT_ARENA = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_LEADERBOARDS_CAPS"
registerVal11.action = OpenArenaMasterLeaderboards
registerVal11.actionParam = 0.000000
registerVal11.customId = "btnLeaderboards"
local function __FUNC_4F64_()
	return IsBooleanDvarSet("tu1_build")
end

registerVal11.disabledFunc = __FUNC_4F64_
CoD.LobbyButtons.MP_ARENA_LEADERBOARD = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_FREERUN_CAPS"
registerVal11.action = NavigateToLobby_SelectionList
registerVal11.param = "FRLobbyOnlineGame"
registerVal11.customId = "btnFROnline"
registerVal11.disabledFunc = IsMpUnavailable
CoD.LobbyButtons.FR_ONLINE = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_LEADERBOARDS_CAPS"
registerVal11.action = OpenFreerunLeaderboards
registerVal11.actionParam = 0.000000
registerVal11.customId = "btnLeaderboards"
local function __FUNC_4FCD_()
	return IsBooleanDvarSet("tu1_build")
end

registerVal11.disabledFunc = __FUNC_4FCD_
CoD.LobbyButtons.FR_LEADERBOARD = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_SOLO_GAME_CAPS"
registerVal11.action = OpenZMMapSelectLaunch
registerVal11.customId = "btnSoloMatch"
registerVal11.disabledFunc = function() return true end
registerVal11.visibleFunc = function() return false end
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
registerVal11.unloadMod = true
CoD.LobbyButtons.ZM_SOLO_GAME = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MENU_JOIN_PUBLIC_GAME_CAPS"
registerVal11.action = OpenZMFindMatch
registerVal11.customId = "btnFindMatch"
registerVal11.disabledFunc = function() return true end
registerVal11.visibleFunc = function() return false end
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
registerVal11.unloadMod = true
CoD.LobbyButtons.ZM_FIND_MATCH = registerVal11
registerVal11 = {}
registerVal11.stringRef = "HOST GAME"
registerVal11.action = NavigateToLobby_SelectionList
registerVal11.param = "ZMLobbyOnlineCustomGame"
registerVal11.customId = "btnCustomMatch"
registerVal11.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons.ZM_CUSTOM_GAMES = registerVal11
registerVal11 = {}
registerVal11.stringRef = "MPUI_VOTE_TO_START_CAPS"
registerVal11.action = SetPlayerReady
registerVal11.customId = "btnReadyUp"
registerVal11.disabledFunc = __FUNC_4E81_
CoD.LobbyButtons.ZM_READY_UP = registerVal11
registerVal12 = {}
registerVal12.stringRef = "MENU_BUBBLEGUM_BUFFS_CAPS"
registerVal12.action = OpenBubbleGumPacksMenu
registerVal12.customId = "btnBubblegumBuffs"
registerVal12.newBreadcrumbFunc = IsCACAnyBubblegumNew
registerVal12.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons["ZM_BUBBLEGUM_BUFFS"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_MEGACHEW_FACTORY_CAPS"
registerVal12.action = OpenMegaChewFactorymenu
registerVal12.customId = "btnMegaChewFactory"
registerVal12.disabledFunc = function() return true end
registerVal12.visibleFunc = function() return false end
registerVal12.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons["ZM_MEGACHEW_FACTORY"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_NEWTONS_COOKBOOK_CAPS"
registerVal12.action = OpenGobbleGumCookbookMenu
registerVal12.disabledFunc = function() return true end
registerVal12.visibleFunc = function() return false end
registerVal12.customId = "btnGobbleGumRecipes"
registerVal12.newBreadcrumbFunc = function() return false end
CoD.LobbyButtons["ZM_GOBBLEGUM_RECIPES"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_WEAPON_BUILD_KITS_CAPS"
registerVal12.action = OpenWeaponBuildKits
registerVal12.customId = "btnWeaponBuildKits"
registerVal12.newBreadcrumbFunc = function() return false end
registerVal12.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons["ZM_BUILD_KITS"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "RESET LOADOUTS"
registerVal12.action = OpenResetLoadoutsPopup
registerVal12.customId = "btnWeaponBuildKitsReset"
registerVal12.newBreadcrumbFunc = function() return false end
registerVal12.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons["ZM_RESET_BUILDKITS"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_LOBBY_LEADERBOARD_CAPS"
registerVal12.action = LobbyNoAction
registerVal12.customId = "btnLobbyLeaderboard"
local function __FUNC_50B0_()
	return IsBooleanDvarSet("tu1_build")
end

registerVal12.disabledFunc = __FUNC_50B0_
CoD.LobbyButtons["ZM_LOBBY_LEADERBOARD"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "PLAY ZBR"
registerVal12.action = __LobbyOnlineCustomLaunchGame_SelectionList
registerVal12.customId = "btnStartCustomGame"
registerVal12.disabledFunc = ZMStartCustomButtonDisabled
registerVal12.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons["ZM_START_CUSTOM_GAME"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "PLAY ZBR"
registerVal12.action = function (arg0, arg1, arg2)
	SafeCall(CoD.zbr_load_mod)
	return LobbyLANLaunchGame(arg0, arg1, arg2)
end
registerVal12.customId = "btnStartLanGame"
registerVal12.disabledFunc = MapVoteTimerActive
registerVal12.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons["ZM_START_LAN_GAME"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MPUI_CHANGE_MAP_CAPS"
registerVal12.action = OpenChangeMapZM
registerVal12.customId = "btnChangeMap"
registerVal12.disabledFunc = MapVoteTimerActive
registerVal12.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons["ZM_CHANGE_MAP"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "GAME SETTINGS"
registerVal12.action = OpenGameSettingsPopup
registerVal12.customId = "btnChangeRankedSettings"
CoD.LobbyButtons["ZM_CHANGE_RANKED_SETTTINGS"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "PLATFORM_SERVER_SETTINGS_CAPS"
registerVal12.action = OpenServerSettings
registerVal12.customId = "btnServerSettings"
registerVal12.starterPack = CoD.LobbyButtons.STARTERPACK_UPGRADE
CoD.LobbyButtons["ZM_SERVER_SETTINGS"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_START_RUN_CAPS"
registerVal12.action = LobbyOnlineCustomLaunchGame_SelectionList
registerVal12.customId = "btnStartRun"
registerVal12.disabledFunc = MapVoteTimerActive
CoD.LobbyButtons["FR_START_RUN_ONLINE"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_START_RUN_CAPS"
registerVal12.action = LobbyLANLaunchGame
registerVal12.customId = "btnStartRun"
registerVal12.disabledFunc = MapVoteTimerActive
CoD.LobbyButtons["FR_START_RUN_LAN"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_FREERUN_COURSES_CAPS"
registerVal12.action = OpenFreerunMapSelection
registerVal12.customId = "btnChangeMap"
registerVal12.disabledFunc = MapVoteTimerActive
CoD.LobbyButtons["FR_CHANGE_MAP"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_START_CAPS"
registerVal12.action = LobbyTheaterStartFilm
registerVal12.customId = "btnStartFilm"
registerVal12.disabledFunc = IsStartFilmButtonDisabled
CoD.LobbyButtons["TH_START_FILM"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_SELECT_CAPS"
registerVal12.action = OpenTheaterSelectFilm
registerVal12.customId = "btnSelectFilm"
registerVal12.disabledFunc = MapVoteTimerActive
registerVal12.selectedFunc = IsFilmNotSelected
CoD.LobbyButtons["TH_SELECT_FILM"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MPUI_HIGHLIGHT_REEL_CAPS"
registerVal12.action = LobbyTheaterCreateHighlightReel
registerVal12.customId = "btnCreateHighlightReel"
registerVal12.disabledFunc = IsCreateHighlightReelButtonDisabled
CoD.LobbyButtons["TH_CREATE_HIGHLIGHT"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MPUI_SHOUTCAST_FILM_CAPS"
registerVal12.action = LobbyTheaterShoutcastFilm
registerVal12.customId = "btnCoDCastFilm"
registerVal12.disabledFunc = IsShoutcastFilmButtonDisabled
CoD.LobbyButtons["TH_SHOUTCAST"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_DEMO_RENDER_CLIP_CAPS"
registerVal12.customId = "btnRenderVideo"
registerVal12.disabledFunc = AlwaysTrue
CoD.LobbyButtons["TH_RENDER"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_FILM_OPTIONS"
registerVal12.customId = "btnFilmOptions"
registerVal12.disabledFunc = AlwaysTrue
CoD.LobbyButtons["TH_OPTIONS"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_START_GAME_CAPS"
registerVal12.action = StartDOAGame
registerVal12.customId = "bthDOAStartMatch"
CoD.LobbyButtons["CP_DOA_START_GAME"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_JOIN_PUBLIC_GAME_CAPS"
registerVal12.action = LaunchDOAJoin
registerVal12.customId = "btnJoinPublicGame"
registerVal12.unloadMod = true
CoD.LobbyButtons["CP_DOA_JOIN_PUBLIC_GAME"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_CREATE_PUBLIC_GAME_CAPS"
registerVal12.action = LaunchDOACreate
registerVal12.customId = "btnJCreatePublicGame"
registerVal12.unloadMod = true
local function __FUNC_5119_()
	local registerVal0 = Engine.GetPrimaryController()
	local registerVal1 = Engine.GetLobbyMaxClients(Enum.LobbyType.LOBBY_TYPE_GAME)
	local registerVal2, registerVal3 = Engine.CanHostServer(registerVal0, registerVal1)
	return (not registerVal1)
end

registerVal12.disabledFunc = __FUNC_5119_
CoD.LobbyButtons["CP_DOA_CREATE_PUBLIC_GAME"] = registerVal12
registerVal12 = {}
registerVal12.stringRef = "MENU_LEADERBOARDS_CAPS"
registerVal12.action = OpenDOALeaderboards
registerVal12.actionParam = 0.000000
registerVal12.customId = "btnLeaderboards"
local function __FUNC_5247_()
	return IsBooleanDvarSet("tu1_build")
end

registerVal12.disabledFunc = __FUNC_5247_
CoD.LobbyButtons["CP_DOA_LEADERBOARD"] = registerVal12


init_zbr()

Engine["GetRank"] = function()
	return 1000
end

Engine["GetRankDisplayLevel"] = function()
	return 1000
end

Engine["GetGunCurrentRank"] = function()
	return 9998
end

Engine["IsItemPermanentlyUnlocked"] = function()
	return true
end

Engine["GetItemUnlockLevel"] = function()
	return 0
end

Engine["HasDLCForItem"] = function()
	return true
end

local oldGetStatByName = Engine["GetStatByName"]
Engine["GetStatByName"] = function(arg0, arg1)
	if arg1 == "PLEVEL" then
		return 11
	end

	if arg1 == "RANKXP" then
		return 999999999
	end

	if arg1 == "RANK" then
		return 1000
	end

	if arg1 == "PARAGON_RANK" then
		return 1000
	end

	if arg1 == "PARAGON_RANKXP" then
		return 1999999999
	end

	return oldGetStatByName(arg0, arg1)
end

Engine["GetItemCost"] = function()
	return 0
end

Engine["GetItemUnlockPLevel"] = function()
	return 0
end

Engine["IsItemAttachmentLocked"] = function()
	return false
end

Engine["IsItemAttachmentLockedFromBuffer"] = function()
	return false
end

Engine["IsItemAttachmentValid"] = function()
	return true
end

Engine["IsItemLocked"] = function()
	return false
end

Engine["IsItemLockedForAll"] = function()
	return false
end

Engine["IsItemLockedForRank"] = function()
	return false
end

Engine["IsItemLockedFromBuffer"] = function()
	return false
end

Engine["IsItemPurchased"] = function()
	return true
end

Engine["IsItemPurchasedFromBuffer"] = function()
	return true
end

Engine["IsItemOptionLocked"] = function()
	return false
end

Engine["IsLootItemUnlockedByPreRequisites"] = function()
	return true
end

Engine["IsEmblemBackgroundLocked"] = function()
	return false
end

Engine["IsAttachmentSlotLocked"] = function()
	return false
end

Engine["AreAttachmentsCompatible"] = function()
	return true
end

Engine["AreAttachmentsCompatibleByAttachmentID"] = function()
	return true
end

Engine["GetChallengeCompleteForChallengeIndex"] = function()
	return true
end

Engine["GetClanTag"] = function()
	return ""
end

Engine["GetClanTagForClientNum"] = function()
	return ""
end

Engine["GetCurrentGametypeName"] = function()
	return "Zombie Blood Rush"
end

Engine["GetGametypeNameForID"] = function()
	return "Zombie Blood Rush"
end

Engine["GetGametypeName"] = function()
	return "Zombie Blood Rush"
end

Engine["GetLobbyMainModeName"] = function()
	return "Zombie Blood Rush"
end

Engine["GetInventoryItemQuantity"] = function()
	return 9999
end

Engine["GetIsSuperUser"] = function()
	return true
end

Engine["GetLootItemQuantity"] = function()
	return 9999
end

CoD["isRankedGame"] = function()
	return true
end

CoD["isOnlineGame"] = function()
	return true
end

function Challenges_IsCategoryLocked()
	return false
end

local oldGCIFI = Engine.GetChallengeInfoForImages
Engine["GetChallengeInfoForImages"] = function( f8_arg0, f8_arg3, f8_arg1 )
	local challenges = oldGCIFI( f8_arg0, f8_arg3, f8_arg1 )
	local emptyTable = {}
	if not challenges then return emptyTable end
	for k, v in ipairs(challenges) do
		v.isLocked = false
		v.currChallengeStatValue = 9999999
	end
	return challenges
end

CoD.ArenaUtility.AddArenaVetCallingCards = function ( f29_arg0, f29_arg1, f29_arg2, f29_arg3 )
	if type( f29_arg1 ) ~= "table" then
		return 
	end
	local f29_local0 = Dvar.arena_seasonVetChallengeWins:get()
	local f29_local1 = Engine.GetCurrentArenaSeason()
	local f29_local2 = false
	local f29_local3 = Engine.GetBackgroundsForCategoryName( f29_arg0, "arenavet" )
	local f29_local4 = Engine.StorageGetBuffer( f29_arg0, Enum.StorageFileType.STORAGE_MP_STATS_ONLINE )
	local f29_local5 = 12
	local f29_local6 = f29_local4.arenaPerSeasonStats.season:get()
	local f29_local7 = f29_local4.arenaPerSeasonStats.wins:get()
	if f29_local6 ~= f29_local1 then
		f29_local7 = 0
	end
	for f29_local8 = 1, 12, 1 do
		local f29_local11 = Engine.Localize( "CHALLENGE_ARENA_VET_SEASON_" .. tostring( f29_local8 ) )
		local f29_local12 = Engine.Localize( "CHALLENGE_ARENA_VET_SEASON_" .. tostring( f29_local8 ) .. "_DESC", f29_local0 )
		if true then
			table.insert( f29_arg1, {
				models = {
					title = f29_local11,
					description = f29_local12,
					iconId = f29_local3[f29_local8].id,
					maxTier = 0,
					currentTier = 0,
					statPercent = 1,
					statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
					tierStatus = "",
					xp = "",
					percentComplete = 1,
					isLocked = false,
					hideProgress = f29_local2
				},
				properties = {
					isMastery = false,
					isDarkOps = false,
					isPrestige = false
				}
			} )
		end
		if not f29_local2 then
			f29_local2 = f29_local14 or f29_local13 == f29_local1
		end
	end
end

CoD.ArenaUtility.GetArenaVetMasterCard = function ( f30_arg0 )
	local f30_local0 = Engine.GetBackgroundsForCategoryName( f30_arg0, "arenavet" )
	local f30_local1 = Engine.StorageGetBuffer( f30_arg0, Enum.StorageFileType.STORAGE_MP_STATS_ONLINE )
	local f30_local2 = f30_local1.arenaChallengeSeasons
	local f30_local3 = false
	local f30_local4 = 0
	local f30_local5 = 12
	for f30_local6 = 0, 12 - 1, 1 do
		if f30_local2[f30_local6]:get() > 0 then
			f30_local4 = f30_local4 + 1
		else
			f30_local3 = true
		end
	end
	return {
		models = {
			title = Engine.Localize( "CHALLENGE_ARENA_VET_SEASON_MASTER" ),
			description = Engine.Localize( "CHALLENGE_ARENA_VET_SEASON_MASTER_DESC" ),
			iconId = f30_local0[#f30_local0].id,
			maxTier = 0,
			currentTier = 0,
			statPercent = 1 / 1,
			statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
			tierStatus = "",
			xp = "",
			percentComplete = 1 / 1,
			isLocked = false,
			hideProgress = true,
			challengeCategory = "arenavet",
			gameMode = Enum.eModes.MODE_MULTIPLAYER,
			gameModeName = Engine.Localize( "MENU_MULTIPLAYER" ),
			gameModeIcon = CoD.ChallengesUtility.GameModeIcons.MP
		},
		properties = {
			isMastery = true,
			isDarkOps = false,
			isPrestige = false
		}
	}
end

CoD.ArenaUtility.AddArenaBestCallingCards = function ( f31_arg0, f31_arg1, f31_arg2, f31_arg3 )
	if type( f31_arg1 ) ~= "table" then
		return 
	end
	local f31_local0 = Engine.StorageGetBuffer( f31_arg0, Enum.StorageFileType.STORAGE_MP_STATS_ONLINE )
	local f31_local1 = f31_local0.arenaBest.wins:get()
	local f31_local2 = f31_local0.arenaPerSeasonStats.wins:get()
	local f31_local3 = CoD.ArenaUtility.GetBestArenaPoints( f31_arg0, f31_local0 )
	local f31_local4 = CoD.ArenaUtility.GetRank( f31_local3 )
	local f31_local5 = Engine.GetBackgroundsForCategoryName( f31_arg0, "arenabest" )
	for f31_local13, f31_local14 in ipairs( CoD.ArenaUtility.Ranks ) do
		local f31_local9 = Engine.Localize( "MENU_RANK_N", f31_local14.rank + 1 )
		local f31_local10 = Engine.Localize( "MENU_CHALLENGES_ARENABEST_RANK_N_DESC", f31_local14.rank + 1 )
		if f31_local14.mode == "master" then
			f31_local9 = Engine.Localize( "MENU_ARENA_MASTER" )
			f31_local10 = Engine.Localize( "MENU_CHALLENGES_ARENABEST_RANK_MASTER_DESC" )
		elseif f31_local14.rank == 0 then
			f31_local10 = Engine.Localize( "MENU_CHALLENGES_ARENABEST_RANK_1_DESC" )
		end
		if true then
			table.insert( f31_arg1, {
				models = {
					title = f31_local9,
					description = f31_local10,
					iconId = f31_local5[f31_local13].id,
					maxTier = 0,
					currentTier = 0,
					statPercent = 0,
					statFractionText = "",
					tierStatus = "",
					xp = "",
					percentComplete = 0,
					isLocked = false,
					hideProgress = true
				},
				properties = {
					isMastery = false,
					isDarkOps = false,
					isPrestige = false
				}
			} )
		end
	end
end

CoD.ArenaUtility.GetRecentArenaVetChallenges = function ( f32_arg0, f32_arg1, f32_arg2, f32_arg3 )
	local f32_local0 = {}
	local f32_local1 = f32_arg1.arenaPerSeasonStats.wins:get()
	local f32_local2 = f32_arg2.arenaPerSeasonStats.wins:get()
	if true then
		local f32_local3 = {}
		CoD.ArenaUtility.AddArenaVetCallingCards( f32_arg0, f32_local3 )
		local f32_local4 = f32_arg1.arenaChallengeSeasons
		local f32_local5 = 12
		for f32_local6 = 0, 12 - 1, 1 do
			if true then
				table.insert( f32_local0, f32_local3[f32_local6 + 1] )
				if not f32_arg3 and f32_local6 == #f32_local5 - 1 then
					table.insert( f32_local0, CoD.ArenaUtility.GetArenaVetMasterCard( f32_arg0 ) )
					break
				end
			end
		end
	end
	return f32_local0
end

CoD.ArenaUtility.GetRecentArenaBestChallenges = function ( f33_arg0, f33_arg1, f33_arg2 )
	local f33_local0 = {}
	local f33_local1 = f33_arg1.arenaBest.wins:get()
	local f33_local2 = f33_arg1.arenaPerSeasonStats.wins:get()
	local f33_local3 = CoD.ArenaUtility.GetBestArenaPoints( f33_arg0, f33_arg1 )
	local f33_local4 = CoD.ArenaUtility.GetBestArenaPoints( f33_arg0, f33_arg2 )
	local f33_local5 = CoD.ArenaUtility.GetRank( 9999 )
	local f33_local6 = CoD.ArenaUtility.GetRank( 9999 )
	if true then
		local f33_local7 = {}
		CoD.ArenaUtility.AddArenaBestCallingCards( f33_arg0, f33_local7 )
		table.insert( f33_local0, f33_local7[f33_local6 + 1] )
	end
	return f33_local0
end

CoD.ChallengesUtility.ChallengeCategoryValues[100] = 
{
	none = 0
}

CoD.ChallengesUtility.GetGameModeInfo = function ()
	local f6_local0 = Engine.GetModel( Engine.GetGlobalModel(), "challengeGameMode" )
	if not f6_local0 then
		return nil
	end
	local f6_local1 = Engine.GetModelValue( f6_local0 )

	if f6_local1 == "zbr" then
		local zbr_tableInfo = 
		{
			name = "zbr",
			index = 100
		}
		return zbr_tableInfo
	end

	if f6_local1 ~= "cp" and f6_local1 ~= "mp" and f6_local1 ~= "zm" then
		return nil
	end
	local f6_local2 = {
		name = f6_local1,
		index = Enum.eModes.MODE_INVALID
	}
	if f6_local1 == "cp" then
		f6_local2.index = Enum.eModes.MODE_CAMPAIGN
	elseif f6_local1 == "mp" then
		f6_local2.index = Enum.eModes.MODE_MULTIPLAYER
	elseif f6_local1 == "zm" then
		f6_local2.index = Enum.eModes.MODE_ZOMBIES
	end
	return f6_local2
end

local defaultEmblemsCached = nil
local function getAllDefaults()
	if defaultEmblemsCached ~= nil then return defaultEmblemsCached end
	local tbl = {}
	for i = 0, 750, 1 do 
		local desc = Engine.TableLookupGetColumnValueForRow( "gamedata/emblems/backgrounds.csv", i, 4 )
		if Engine.TableLookupGetColumnValueForRow( "gamedata/emblems/backgrounds.csv", i, 9 ) == "default" and "EM_BACK_CWL_default" ~= desc then
			local curTbl = {}

			curTbl.id = i
			curTbl.description = Engine.Localize(desc)
			curTbl.isBGLocked = false
			curTbl.entitlement = nil
			curTbl.isContractBg = false

			table.insert(tbl, curTbl)
		end
	end
	defaultEmblemsCached = tbl
	return tbl
end

local oldGBFCN = Engine.GetBackgroundsForCategoryName
Engine.GetBackgroundsForCategoryName = function(arg0, arg1)
	if arg1 == "default" then
		return getAllDefaults()
	end
	return oldGBFCN(arg0, arg1)
end

DataSources.CallingCardsDefault = DataSourceHelpers.ListSetup( "CallingCardsDefault", function ( f1_arg0 )
	local f1_local0 = {}
	local f1_local1 = Engine.GetBackgroundsForCategoryName( f1_arg0, "default" )
	local f1_local2 = function ( f2_arg0, f2_arg1 )
		if f2_arg0.models.isPackage ~= f2_arg1.models.isPackage then
			return f2_arg0.models.isPackage
		elseif f2_arg0.models.isPackage and f2_arg0.properties.packageSortIndex and f2_arg1.properties.packageSortIndex then
			return f2_arg0.properties.packageSortIndex < f2_arg1.properties.packageSortIndex
		elseif f2_arg0.models.isLocked ~= f2_arg1.models.isLocked then
			return f2_arg1.models.isLocked
		else
			return f2_arg0.models.iconId < f2_arg1.models.iconId
		end
	end
	
	local f1_local3 = function ( f3_arg0, f3_arg1, f3_arg2, f3_arg3, f3_arg4 )
		CallingCards_SetPlayerBackground( f3_arg4, f3_arg1, f3_arg2 )
	end
	
	local f1_local4 = function ( f4_arg0 )
		if f4_arg0.isContractBg then
			
		else
			
		end
	end
	
	for f1_local16, f1_local17 in ipairs( f1_local1 ) do
		local f1_local8 = Engine.Localize( f1_local17.description )
		local f1_local9 = ""
		if f1_local17.isContractBg and f1_local17.isBGLocked then
			f1_local8 = CoD.BlackMarketUtility.ClassifiedName()
			f1_local9 = Engine.Localize( "MPUI_CONTRACT_ITEM_CLASSIFIED_DESC", "MENU_CALLING_CARD" )
		end
		for f1_local14, f1_local15 in ipairs( CoD.SpecialCallingCards ) do
			if f1_local17.description == f1_local15.backgroundDescription then
				local f1_local13 = Engine.GetInventoryItemQuantity( f1_arg0, f1_local15.itemId )
				if not f1_local13 or f1_local13 == 0 then
					f1_local17.isBGLocked = true
				end
			end
		end
		if not f1_local17.isBGLocked or f1_local17.isContractBg and IsLive() then
			table.insert( f1_local0, {
				models = {
					title = f1_local8,
					description = f1_local9,
					iconId = f1_local17.id,
					isLocked = f1_local17.isBGLocked,
					isContractBg = f1_local17.isContractBg,
					isPackage = false
				},
				properties = {
					action = f1_local3
				}
			} )
		end
	end
	if InFrontend() and AreCodPointsEnabled( f1_arg0 ) then
		for f1_local16, f1_local17 in ipairs( CoD.StoreUtility.CWLPackages ) do
			if not CoD.StoreUtility.IsCWLV2Package( f1_local17 ) and CoD.StoreUtility.IsInventoryItemVisible( f1_arg0, f1_local17 ) and not CoD.StoreUtility.IsInventoryItemPurchased( f1_arg0, f1_local17 ) then
				local f1_local8 = CoD.StoreUtility.GetCWLPackageCallingCardModel( f1_arg0, f1_local17 )
				f1_local8.properties.packageSortIndex = f1_local16
				table.insert( f1_local0, f1_local8 )
			end
		end
	end
	table.sort( f1_local0, f1_local2 )
	return f1_local0
end, true )

function AreCodPointsEnabled() return true end

CoD.StoreUtility.IsInventoryItemPurchased = function() return true end
CoD.StoreUtility.IsInventoryItemVisible = function() return true end

local function getmusiczbr()
	local music = Engine.TableLookup(nil, CoD.musicPlayerTable, Enum.MusicPlayerTableColumn.MUSIC_PLAYER_COLUMN_INDEX, 0, Enum.MusicPlayerTableColumn.MUSIC_PLAYER_COLUMN_ALIAS)
	local s_music = {}
	s_music.alias = music
	s_music.loop = true
	return {s_music}
end

CoD["GetMusicTracks"] = getmusiczbr

local function PlayMenuMusic_Internal_()
	Engine.PlayMenuMusic("")
	if not CoD.curLobbyTrack then 
		CoD.SetupMusicTracks(false)
		CoD.NextMenuTrack()
	end
end

CoD["PlayMenuMusic_Internal"] = PlayMenuMusic_Internal_
PlayMenuMusic_Internal_()

Engine["GetPlaylistMaxPartySize"] = function()
	return ship_maxplayers
end

local oldLobbyGetSessionClients = Engine.LobbyGetSessionClients

Engine["LobbyGetSessionClients"] = function(arg0, arg1, arg2, arg3)
	local f2_local2 = oldLobbyGetSessionClients(arg0, arg1, arg2, arg3)
	local numClients = 0;
	for f2_local14, f2_local15 in ipairs( f2_local2.sessionClients ) do
		numClients = numClients + 1
		f2_local2.sessionClients[f2_local14].rankIcon = "uie_t7_icon_inventory_worm_inuse" -- "t7_icon_rank_zm_prestige_12"
		f2_local2.sessionClients[f2_local14].prestige = 0
		f2_local2.sessionClients[f2_local14].paragonRank = 1000
		f2_local2.sessionClients[f2_local14].bgb1Remaining = 999
		f2_local2.sessionClients[f2_local14].bgb2Remaining = 999
		f2_local2.sessionClients[f2_local14].bgb3Remaining = 999
		f2_local2.sessionClients[f2_local14].bgb4Remaining = 999
		f2_local2.sessionClients[f2_local14].bgb5Remaining = 999
	end
	-- will spam too much DiscordSDKLib.SetDiscordPresence("In a Party", "Pregame Lobby", numClients, tonumber(Engine.DvarString(nil, "com_maxclients")))
	return f2_local2
end

local function arr_has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function modifyMapDescription(desc, internal_name)
	if (internal_name == nil) or arr_has_value(CoD.zbr_supported_maps, internal_name) then
		return "^2ZBR OFFICIALLY SUPPORTED MAP\n^7" .. desc
	end
	return "^3WARNING: MAP NOT OFFICIALLY SUPPORTED BY ZBR\n^7" .. desc
end

local function trimMapname(name, internal_name)
	local val = name
	if #name > 24 then
		val = string.sub(name, 1, 24) .. "..."
	end

	if (internal_name ~= nil) and not arr_has_value(CoD.zbr_supported_maps, internal_name) then
		val = "^1" .. val
	end

	return val
end

DataSources.ZMMapsList = ListHelper_SetupDataSource("ZMMapsList", function(arg0, arg1)
    local dataTable = {}

    local sortedMapsTable = LUI.IterateTableBySortedKeys(CoD.mapsTable, function(CurrentMap, NextMap)
        return CoD.mapsTable[CurrentMap].unique_id < CoD.mapsTable[NextMap].unique_id
    end, nil)

    for index, value in sortedMapsTable do
        if value.session_mode == Enum.eModes.MODE_ZOMBIES then
            table.insert(dataTable, {
                models = {
                    displayText = CoD.StoreUtility.PrependPurchaseIconIfNeeded(arg0, index, Engine.Localize(value.mapNameCaps)),
                    image = value.previewImage,
                    mapName = value.mapName,
                    mapLocation = value.mapLocation,
                    playingCount = "",
                    dlcIndex = value.dlc_pack,
                    mapDescription = modifyMapDescription(Engine.Localize(value.mapDescription), nil)
                },
                properties = {
                    mapId = index,
                    purchasable = not Engine.IsMapValid(index)
                }
            })
        end
    end

	if CoD.zbr_enable_doa then
		table.insert(dataTable, {
			models = {
				displayText = "",
				Image = "",
				mapName = "",
				mapDescription = ""
			},
			properties = {
				mapId = ""
			}
		})

		table.insert(dataTable, {
			models = {
				displayText = "DEAD OPS ARCADE",
				image = "cp_doa_bo3",
				mapName = "cp_doa_bo3",
				mapLocation = "",
				playingCount = "",
				dlcIndex = 0,
				mapDescription = ""
			},
			properties = {
				mapId = "cp_doa_bo3",
				purchasable = false
			}
		})
	end

	if CoD.zbr_enable_mp then
		table.insert(dataTable, {
			models = {
				displayText = "",
				Image = "",
				mapName = "",
				mapDescription = ""
			},
			properties = {
				mapId = ""
			}
		})

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = "NUK3T0WN",
		-- 		image = "mp_nuketown_x",
		-- 		mapName = "mp_nuketown_x",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_nuketown_x",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_rome"),
		-- 		image = "mp_rome",
		-- 		mapName = "mp_rome",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_rome",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_skyjacked"),
		-- 		image = "mp_skyjacked",
		-- 		mapName = "mp_skyjacked",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_skyjacked",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_waterpark"),
		-- 		image = "mp_waterpark",
		-- 		mapName = "mp_waterpark",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_waterpark",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_ruins"),
		-- 		image = "mp_ruins",
		-- 		mapName = "mp_ruins",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_ruins",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_aerospace"),
		-- 		image = "mp_aerospace",
		-- 		mapName = "mp_aerospace",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_aerospace",
		-- 		purchasable = false
		-- 	}
		-- })
		
		table.insert(dataTable, {
			models = {
				displayText = Engine.Localize("mp_apartments"),
				image = "mp_apartments",
				mapName = "mp_apartments",
				mapLocation = "",
				playingCount = "",
				dlcIndex = 0,
				mapDescription = ""
			},
			properties = {
				mapId = "mp_apartments",
				purchasable = false
			}
		})

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_arena"),
		-- 		image = "mp_arena",
		-- 		mapName = "mp_arena",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_arena",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_banzai"),
		-- 		image = "mp_banzai",
		-- 		mapName = "mp_banzai",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_banzai",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_chinatown"),
		-- 		image = "mp_chinatown",
		-- 		mapName = "mp_chinatown",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_chinatown",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_city"),
		-- 		image = "mp_city",
		-- 		mapName = "mp_city",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_city",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_conduit"),
		-- 		image = "mp_conduit",
		-- 		mapName = "mp_conduit",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_conduit",
		-- 		purchasable = false
		-- 	}
		-- })

		table.insert(dataTable, {
			models = {
				displayText = Engine.Localize("GAUNTLET"),
				image = "img_t7_menu_mp_preview_gauntlet",
				mapName = "Gauntlet",
				mapLocation = "",
				playingCount = "",
				dlcIndex = 0,
				mapDescription = "Classified training facility uniquely designed to push the Specialists beyond their limits."
			},
			properties = {
				mapId = "mp_crucible",
				purchasable = false
			}
		})

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_cryogen"),
		-- 		image = "mp_cryogen",
		-- 		mapName = "mp_cryogen",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_cryogen",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_ethiopia"),
		-- 		image = "mp_ethiopia",
		-- 		mapName = "mp_ethiopia",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_ethiopia",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_havoc"),
		-- 		image = "mp_havoc",
		-- 		mapName = "mp_havoc",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_havoc",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_infection"),
		-- 		image = "mp_infection",
		-- 		mapName = "mp_infection",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_infection",
		-- 		purchasable = false
		-- 	}
		-- })
		
		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_kung_fu"),
		-- 		image = "mp_kung_fu",
		-- 		mapName = "mp_kung_fu",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_kung_fu",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_metro"),
		-- 		image = "mp_metro",
		-- 		mapName = "mp_metro",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_metro",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_miniature"),
		-- 		image = "mp_miniature",
		-- 		mapName = "mp_miniature",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_miniature",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_redwood"),
		-- 		image = "mp_redwood",
		-- 		mapName = "mp_redwood",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_redwood",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_rise"),
		-- 		image = "mp_rise",
		-- 		mapName = "mp_rise",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_rise",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_sector"),
		-- 		image = "mp_sector",
		-- 		mapName = "mp_sector",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_sector",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_shrine"),
		-- 		image = "mp_shrine",
		-- 		mapName = "mp_shrine",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_shrine",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_spire"),
		-- 		image = "mp_spire",
		-- 		mapName = "mp_spire",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_spire",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_stronghold"),
		-- 		image = "mp_stronghold",
		-- 		mapName = "mp_stronghold",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_stronghold",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_veiled"),
		-- 		image = "mp_veiled",
		-- 		mapName = "mp_veiled",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_veiled",
		-- 		purchasable = false
		-- 	}
		-- })

		-- table.insert(dataTable, {
		-- 	models = {
		-- 		displayText = Engine.Localize("mp_western"),
		-- 		image = "mp_western",
		-- 		mapName = "mp_western",
		-- 		mapLocation = "",
		-- 		playingCount = "",
		-- 		dlcIndex = 0,
		-- 		mapDescription = ""
		-- 	},
		-- 	properties = {
		-- 		mapId = "mp_western",
		-- 		purchasable = false
		-- 	}
		-- })
		
	end

	table.insert(dataTable, {
		models = {
			displayText = "",
			Image = "",
			mapName = "",
			mapDescription = ""
		},
		properties = {
			mapId = ""
		}
	})

    local customMaps = Engine.Mods_Lists_GetInfoEntries(LuaEnums.USERMAP_BASE_PATH, 0, Engine.Mods_Lists_GetInfoEntriesCount(LuaEnums.USERMAP_BASE_PATH))
    local customMapTable = {}

    if customMaps then
        for index = 0, #customMaps, 1 do
            local customMap = customMaps[index]
            if LUI.startswith(customMap.internalName, "zm_")  and arr_has_value(CoD.zbr_supported_maps, customMap.internalName) then
                table.insert(customMapTable, {
                    models = {
                        displayText = trimMapname(Engine.ToUpper(customMap.name), customMap.internalName),
                        Image = customMap.ugcName,
                        mapName = customMap.name,
                        mapDescription = modifyMapDescription(customMap.description, customMap.internalName)
                    },
                    properties = {
                        mapId = customMap.ugcName
                    }
                })
            end
        end

		table.insert(customMapTable, {
			models = {
				displayText = "^1",
				Image = "",
				mapName = "",
				mapDescription = ""
			},
			properties = {
				mapId = ""
			}
		})

		for index = 0, #customMaps, 1 do
            local customMap = customMaps[index]
            if LUI.startswith(customMap.internalName, "zm_") and not arr_has_value(CoD.zbr_supported_maps, customMap.internalName) then
                table.insert(customMapTable, {
                    models = {
                        displayText = trimMapname(Engine.ToUpper(customMap.name), customMap.internalName),
                        Image = customMap.ugcName,
                        mapName = customMap.name,
                        mapDescription = modifyMapDescription(customMap.description, customMap.internalName)
                    },
                    properties = {
                        mapId = customMap.ugcName
                    }
                })
            end
        end
    end

    table.sort(customMapTable, function(a, b)
        if a.models and b.models then
            if a.models.displayText and b.models.displayText then
                return Engine.ToUpper(a.models.displayText) < Engine.ToUpper(b.models.displayText)
            end
        end
    end)

    for _, customTable in ipairs(customMapTable) do
        table.insert(dataTable, customTable)
    end

    return dataTable
end, true)

function MapNameToLocalizedMapName( map_name )
	local mappa = CoD.GetMapValue( map_name, "mapNameCaps", map_name )
	if(mappa == map_name) then
		local customMaps = Engine.Mods_Lists_GetInfoEntries(LuaEnums.USERMAP_BASE_PATH, 0, Engine.Mods_Lists_GetInfoEntriesCount(LuaEnums.USERMAP_BASE_PATH))
		for index = 0, #customMaps, 1 do
            local customMap = customMaps[index]
            if customMap.internalName == map_name then
				return Engine.ToUpper(customMap.name)
			end
        end
	end
	return Engine.Localize( mappa )
end

function MapNameToLocalizedMapLocation( f186_arg0 )
	return Engine.Localize( CoD.GetMapValue( f186_arg0, "mapLocation", f186_arg0 ) )
end

function MapNameToMapImage( map_name )
	local f187_local0 = CoD.GetMapValue( map_name, "previewImage", "$black" )
	if f187_local0 == "$black" then
		local customMaps = Engine.Mods_Lists_GetInfoEntries(LuaEnums.USERMAP_BASE_PATH, 0, Engine.Mods_Lists_GetInfoEntriesCount(LuaEnums.USERMAP_BASE_PATH))
		for index = 0, #customMaps, 1 do
            local customMap = customMaps[index]
            if customMap.internalName == map_name then
				CoD.last_ugc_update = customMap.ugcName
				return MapImageToModPreview(customMap.ugcName)
			end
        end
	end
	return f187_local0
end

Engine.SteamStore = function () end

DataSources.StartMenuTabs = ListHelper_SetupDataSource( "StartMenuTabs", function ( f44_arg0 )
	local f44_local0 = {}
	table.insert( f44_local0, {
		models = {
			tabIcon = CoD.buttonStrings.shoulderl
		},
		properties = {
			m_mouseDisabled = true
		}
	} )
	if Engine.IsInGame() then
		if Engine.IsZombiesGame() then
			table.insert( f44_local0, {
				models = {
					tabName = SessionModeToUnlocalizedSessionModeCaps( Engine.CurrentSessionMode() ),
					tabWidget = "CoD.StartMenu_GameOptions_ZM",
					tabIcon = ""
				},
				properties = {
					tabId = "gameOptions"
				}
			} )
		else
			table.insert( f44_local0, {
				models = {
					tabName = SessionModeToUnlocalizedSessionModeCaps( Engine.CurrentSessionMode() ),
					tabWidget = "CoD.StartMenu_GameOptions",
					tabIcon = ""
				},
				properties = {
					tabId = "gameOptions"
				}
			} )
		end
	else
		if not IsPlayerAGuest( f44_arg0 ) then
			table.insert( f44_local0, {
				models = {
					tabName = "MENU_TAB_IDENTITY_CAPS",
					tabWidget = "CoD.StartMenu_Identity",
					tabIcon = ""
				},
				properties = {
					tabId = "identity",
					disabled = Dvar.ui_execdemo_gamescom:get()
				}
			} )
		end
		if not IsLobbyNetworkModeLAN() and not Dvar.ui_execdemo:get() and not Engine.IsCampaignModeZombies() and not IsPlayerAGuest( f44_arg0 ) then
			table.insert( f44_local0, {
				models = {
					tabName = "MENU_TAB_CHALLENGES_CAPS",
					tabWidget = "CoD.StartMenu_Challenges",
					tabIcon = ""
				},
				properties = {
					tabId = "challenges"
				}
			} )
			table.insert( f44_local0, {
				models = {
					tabName = "MENU_TAB_BARRACKS_CAPS",
					tabWidget = "CoD.StartMenu_Barracks",
					tabIcon = "",
					disabled = false
				},
				properties = {
					tabId = "barracks"
				}
			} )
			if CommunityOptionsEnabled() then
				local f44_local2 = CoD.perController[f44_arg0].openMediaTabAfterClosingGroups
				CoD.perController[f44_arg0].openMediaTabAfterClosingGroups = false
				table.insert( f44_local0, {
					models = {
						tabName = "MENU_TAB_MEDIA_CAPS",
						tabWidget = "CoD.StartMenu_Media",
						tabIcon = ""
					},
					properties = {
						tabId = "media",
						selectIndex = f44_local2
					}
				} )
			end
		end
	end
	if IsGameTypeDOA() and Engine.IsInGame() and not InSafehouse() then
		local f44_local2 = f44_local0
		local f44_local3 = {
			models = {
				tabName = "MENU_TAB_OPTIONS_CAPS",
				tabWidget = "CoD.StartMenu_Options_DOA",
				tabIcon = ""
			}
		}
		local f44_local4 = {
			tabId = "options"
		}
		local f44_local5 = Dvar.ui_execdemo:get()
		if f44_local5 then
			f44_local5 = not Engine.IsInGame()
		end
		f44_local4.selectIndex = f44_local5
		f44_local3.properties = f44_local4
		table.insert( f44_local2, f44_local3 )
	else
		local f44_local2 = f44_local0
		local f44_local3 = {
			models = {
				tabName = "MENU_TAB_OPTIONS_CAPS",
				tabWidget = "CoD.StartMenu_Options",
				tabIcon = ""
			}
		}
		local f44_local4 = {
			tabId = "options"
		}
		local f44_local5 = Dvar.ui_execdemo_gamescom:get()
		if f44_local5 then
			f44_local5 = not Engine.IsInGame()
		end
		f44_local4.selectIndex = f44_local5
		f44_local3.properties = f44_local4
		table.insert( f44_local2, f44_local3 )
	end
	table.insert( f44_local0, {
		models = {
			tabIcon = CoD.buttonStrings.shoulderr
		},
		properties = {
			m_mouseDisabled = true
		}
	} )
	return f44_local0
end, true )

if CoD.zbr_loaded then 
	DiscordSDKLib.SetDiscordPresence("In a Party", "Pregame Lobby", 1, 4);
	DiscordSDKLib.MarkBeginSession();
end

local oldUpdateLobbyList = CoD.LobbyUtility.UpdateLobbyList
CoD.LobbyUtility.UpdateLobbyList = function(modelRef)
	oldUpdateLobbyList(modelRef)
	if CoD.zbr_loaded then 
		local count = Engine.GetModelValue(Engine.GetModel(Engine.GetGlobalModel(), "lobbyRoot.lobbyList.playerCount"))
		local maxCount = Engine.GetModelValue(Engine.GetModel(Engine.GetGlobalModel(), "lobbyRoot.lobbyList.maxPlayers"))
		DiscordSDKLib.SetDiscordPresence("In a Party", "Pregame Lobby", tonumber(count), tonumber(maxCount));
		DiscordSDKLib.RepSessionIDToClients();
		ZBR.RepLobbystate();
	end
end

Engine.IsEmblemBackgroundNew = function() return false end

local function get_zbr_callingcards(controller)
	return {}
end

local oldgct = CoD.ChallengesUtility.GetChallengeTable
CoD.ChallengesUtility.GetChallengeTable = function( f8_arg0, f8_arg1, modeName, f8_arg3, f8_arg4, f8_arg5 )
	if modeName == "zbr" then
		local challenges = {}
		local zbr_default_0 = {
			models = {
				title = "COD Zombies",
				description = "",
				iconId = 750,
				maxTier = 1,
				currentTier = 1,
				statPercent = 1 / 1,
				statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
				tierStatus = Engine.Localize( "CHALLENGE_TIER_STATUS", 0 + 1, 0 + 1 ),
				xp = 0,
				percentComplete = 1 / 1,
				isLocked = false,
				hideProgress = false
			},
			properties = {
				isMastery = false,
				isDarkOps = false,
				isExpert = false
			}
		}
		table.insert(challenges, zbr_default_0)

		local zbr_default_1 = {
			models = {
				title = "Perks",
				description = "",
				iconId = 753,
				maxTier = 1,
				currentTier = 1,
				statPercent = 1 / 1,
				statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
				tierStatus = Engine.Localize( "CHALLENGE_TIER_STATUS", 0 + 1, 0 + 1 ),
				xp = 0,
				percentComplete = 1 / 1,
				isLocked = false,
				hideProgress = false
			},
			properties = {
				isMastery = false,
				isDarkOps = false,
				isExpert = false
			}
		}
		table.insert(challenges, zbr_default_1)

		local zbr_default_8 = {
			models = {
				title = "Meta",
				description = "",
				iconId = 760,
				maxTier = 1,
				currentTier = 1,
				statPercent = 1 / 1,
				statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
				tierStatus = Engine.Localize( "CHALLENGE_TIER_STATUS", 0 + 1, 0 + 1 ),
				xp = 0,
				percentComplete = 1 / 1,
				isLocked = false,
				hideProgress = false
			},
			properties = {
				isMastery = false,
				isDarkOps = false,
				isExpert = false
			}
		}
		table.insert(challenges, zbr_default_8)

		local zbr_default_2 = {
			models = {
				title = "Galaxies",
				description = "",
				iconId = 754,
				maxTier = 1,
				currentTier = 1,
				statPercent = 1 / 1,
				statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
				tierStatus = Engine.Localize( "CHALLENGE_TIER_STATUS", 0 + 1, 0 + 1 ),
				xp = 0,
				percentComplete = 1 / 1,
				isLocked = false,
				hideProgress = false
			},
			properties = {
				isMastery = false,
				isDarkOps = false,
				isExpert = false
			}
		}
		table.insert(challenges, zbr_default_2)

		local zbr_default_3 = {
			models = {
				title = "Hunted",
				description = "",
				iconId = 755,
				maxTier = 1,
				currentTier = 1,
				statPercent = 1 / 1,
				statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
				tierStatus = Engine.Localize( "CHALLENGE_TIER_STATUS", 0 + 1, 0 + 1 ),
				xp = 0,
				percentComplete = 1 / 1,
				isLocked = false,
				hideProgress = false
			},
			properties = {
				isMastery = false,
				isDarkOps = false,
				isExpert = false
			}
		}
		table.insert(challenges, zbr_default_3)

		local zbr_default_5 = {
			models = {
				title = "Tundra",
				description = "",
				iconId = 757,
				maxTier = 1,
				currentTier = 1,
				statPercent = 1 / 1,
				statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
				tierStatus = Engine.Localize( "CHALLENGE_TIER_STATUS", 0 + 1, 0 + 1 ),
				xp = 0,
				percentComplete = 1 / 1,
				isLocked = false,
				hideProgress = false
			},
			properties = {
				isMastery = false,
				isDarkOps = false,
				isExpert = false
			}
		}
		table.insert(challenges, zbr_default_5)

		local zbr_default_7 = {
			models = {
				title = "Cataclysm",
				description = "",
				iconId = 759,
				maxTier = 1,
				currentTier = 1,
				statPercent = 1 / 1,
				statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
				tierStatus = Engine.Localize( "CHALLENGE_TIER_STATUS", 0 + 1, 0 + 1 ),
				xp = 0,
				percentComplete = 1 / 1,
				isLocked = false,
				hideProgress = false
			},
			properties = {
				isMastery = false,
				isDarkOps = false,
				isExpert = false
			}
		}
		table.insert(challenges, zbr_default_7)

		local zbr_default_6 = {
			models = {
				title = "Focus",
				description = "",
				iconId = 758,
				maxTier = 1,
				currentTier = 1,
				statPercent = 1 / 1,
				statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
				tierStatus = Engine.Localize( "CHALLENGE_TIER_STATUS", 0 + 1, 0 + 1 ),
				xp = 0,
				percentComplete = 1 / 1,
				isLocked = false,
				hideProgress = false
			},
			properties = {
				isMastery = false,
				isDarkOps = false,
				isExpert = false
			}
		}
		table.insert(challenges, zbr_default_6)

		local zbr_default_4 = {
			models = {
				title = "Astolfo",
				description = "Credit: Vortex",
				iconId = 756,
				maxTier = 1,
				currentTier = 1,
				statPercent = 1 / 1,
				statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
				tierStatus = Engine.Localize( "CHALLENGE_TIER_STATUS", 0 + 1, 0 + 1 ),
				xp = 0,
				percentComplete = 1 / 1,
				isLocked = false,
				hideProgress = false
			},
			properties = {
				isMastery = false,
				isDarkOps = false,
				isExpert = false
			}
		}
		table.insert(challenges, zbr_default_4)

		if(CoD.zbr_loaded and ZBR.aaa()) then 
			local zbr_dev_0 = {
				models = {
					title = "Developer",
					description = "Thanks for helping out!",
					iconId = 751,
					maxTier = 1,
					currentTier = 1,
					statPercent = 1 / 1,
					statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
					tierStatus = Engine.Localize( "CHALLENGE_TIER_STATUS", 0 + 1, 0 + 1 ),
					xp = 0,
					percentComplete = 1 / 1,
					isLocked = false,
					hideProgress = false
				},
				properties = {
					isMastery = false,
					isDarkOps = false,
					isExpert = false
				}
			}
			table.insert(challenges, zbr_dev_0)
		end

		if(CoD.zbr_loaded and ZBR.aab()) then 
			local zbr_tournament_2021 = {
				models = {
					title = "Invitationals 2021",
					description = "Legend status: Confirmed",
					iconId = 752,
					maxTier = 1,
					currentTier = 1,
					statPercent = 1 / 1,
					statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
					tierStatus = Engine.Localize( "CHALLENGE_TIER_STATUS", 0 + 1, 0 + 1 ),
					xp = 0,
					percentComplete = 1 / 1,
					isLocked = false,
					hideProgress = false
				},
				properties = {
					isMastery = false,
					isDarkOps = false,
					isExpert = false
				}
			}
			table.insert(challenges, zbr_tournament_2021)
		end

		if(CoD.zbr_loaded and ZBR.aac()) then 
			local zbr_tournament_2021 = {
				models = {
					title = "Z4C 2024",
					description = "Let the games begin.",
					iconId = 761,
					maxTier = 1,
					currentTier = 1,
					statPercent = 1 / 1,
					statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
					tierStatus = Engine.Localize( "CHALLENGE_TIER_STATUS", 0 + 1, 0 + 1 ),
					xp = 0,
					percentComplete = 1 / 1,
					isLocked = false,
					hideProgress = false
				},
				properties = {
					isMastery = false,
					isDarkOps = false,
					isExpert = false
				}
			}
			table.insert(challenges, zbr_tournament_2021)
		end

		if(CoD.zbr_loaded and ZBR.aad()) then 
			local zbr_tournament_2021 = {
				models = {
					title = "Z4C 2024 Winner",
					description = "Best of the best.",
					iconId = 762,
					maxTier = 1,
					currentTier = 1,
					statPercent = 1 / 1,
					statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
					tierStatus = Engine.Localize( "CHALLENGE_TIER_STATUS", 0 + 1, 0 + 1 ),
					xp = 0,
					percentComplete = 1 / 1,
					isLocked = false,
					hideProgress = false
				},
				properties = {
					isMastery = false,
					isDarkOps = false,
					isExpert = false
				}
			}
			table.insert(challenges, zbr_tournament_2021)
		end

		local zbr_default_20 = {
			models = {
				title = "Z4C 2024 Lineup",
				description = "",
				iconId = 763,
				maxTier = 1,
				currentTier = 1,
				statPercent = 1 / 1,
				statFractionText = Engine.Localize( "MPUI_X_SLASH_Y", 1, 1 ),
				tierStatus = Engine.Localize( "CHALLENGE_TIER_STATUS", 0 + 1, 0 + 1 ),
				xp = 0,
				percentComplete = 1 / 1,
				isLocked = false,
				hideProgress = false
			},
			properties = {
				isMastery = false,
				isDarkOps = false,
				isExpert = false
			}
		}
		table.insert(challenges, zbr_default_20)

		return challenges
	end
	return oldgct( f8_arg0, f8_arg1, modeName, f8_arg3, f8_arg4, f8_arg5 )
end

DataSources.CallingCardsTabs = ListHelper_SetupDataSource( "CallingCardsTabs", function ( f47_arg0 )
	local f47_local0 = {}
	table.insert( f47_local0, {
		models = {
			tabIcon = CoD.buttonStrings.shoulderl
		},
		properties = {
			m_mouseDisabled = true
		}
	} )
	local f47_local1 = {
		"sidebet",
		"mp_action"
	}
	local f47_local2 = function ( f48_arg0, f48_arg1 )
		return function ( f49_arg0 )
			if f48_arg1 then
				for f49_local3, f49_local4 in ipairs( f47_local1 ) do
					if f49_arg0.challengeCategory == f49_local4 then
						return false
					end
				end
			end
			local f49_local0
			if f49_arg0.challengeRow == nil or f49_arg0.isLocked or f49_arg0.isMastery == f48_arg0 then
				f49_local0 = false
			else
				f49_local0 = true
			end
			return f49_local0
		end
		
	end
	
	local f47_local3 = function ( data, f50_arg1 )
		local f50_local0 = 0
		for f50_local4, f50_local5 in ipairs( data ) do
			if (not f50_arg1 or f50_arg1( f50_local5 )) and Engine.IsEmblemBackgroundNew( f47_arg0, f50_local5.imageID ) then
				f50_local0 = f50_local0 + 1
			end
		end
		return f50_local0
	end
	
	local f47_local4 = function ()
		local f51_local0 = 0
		for f51_local4, f51_local5 in ipairs( Engine.GetBackgroundsForCategoryName( f47_arg0, "default" ) ) do
			if Engine.IsEmblemBackgroundNew( f47_arg0, f51_local5.id ) then
				f51_local0 = f51_local0 + 1
			end
		end
		return f51_local0
	end
	
	local f47_local5 = function ( f52_arg0, f52_arg1, f52_arg2, f52_arg3, f52_arg4 )
		table.insert( f47_local0, {
			models = {
				tabName = f52_arg0,
				tabWidget = f52_arg1,
				tabCategory = f52_arg2,
				breadcrumbCount = f52_arg4,
				tabIcon = ""
			},
			properties = {
				tabId = f52_arg3
			}
		} )
	end
	
	local f47_local6 = Engine.GetChallengeInfoForImages( f47_arg0, nil, Enum.eModes.MODE_CAMPAIGN )
	local f47_local8 = Engine.GetChallengeInfoForImages( f47_arg0, nil, Enum.eModes.MODE_ZOMBIES )
	CoD.PrestigeUtility.AddPrestigeChallenges( f47_arg0, Enum.eModes.MODE_ZOMBIES, f47_local8 )

	f47_local5( "ZOMBIE BLOOD RUSH", "CoD.CallingCards_Stickerbook", "zbr", "callingcards_zbr", f47_local3( get_zbr_callingcards(f47_arg0), f47_local2( true, true ) ) )
	f47_local5( "MENU_DEFAULT_CAPS", "CoD.CallingCards_Stickerbook_Default", "default", "callingcards_default", f47_local4() )
	if not CoD.isPC or Engine.CheckNetConnection() then
		f47_local5( "MENU_CAMPAIGN_CAPS", "CoD.CallingCards_Stickerbook", "cp", "callingcards_cp", f47_local3( f47_local6, f47_local2( true, true ) ) )
	end
	if not IsLobbyNetworkModeLAN() then
		local f47_local7 = Engine.GetChallengeInfoForImages( f47_arg0, nil, Enum.eModes.MODE_MULTIPLAYER )
		CoD.PrestigeUtility.AddPrestigeChallenges( f47_arg0, Enum.eModes.MODE_MULTIPLAYER, f47_local7 )
		if ArenaChallengesEnabled() then
			CoD.ArenaUtility.AddArenaChallenges( f47_arg0, f47_local7 )
		end
		f47_local5( "MENU_MULTIPLAYER_CAPS", "CoD.CallingCards_Stickerbook", "mp", "callingcards_mp", f47_local3( f47_local7, f47_local2( true, true ) ) )
		f47_local5( "MENU_ZOMBIES_CAPS", "CoD.CallingCards_Stickerbook", "zm", "callingcards_zm", f47_local3( f47_local8, f47_local2( true, true ) ) )
		local f47_local9 = f47_local3( f47_local6, f47_local2( false, true ) ) + f47_local3( f47_local7, f47_local2( false, true ) ) + f47_local3( f47_local8, f47_local2( false, true ) )
		if ArenaChallengesEnabled() then
			local f47_local10 = CoD.ArenaUtility.GetArenaVetMasterCard( f47_arg0 )
			if not f47_local10.models.isLocked then
				f47_local9 = f47_local9 + 1
			end
		end
		f47_local5( "MENU_MASTERS_CAPS", "CoD.CallingCards_Stickerbook_Master", "master", "callingcards_master", f47_local9 )
	end
	if IsLive() then
		local f47_local7 = CoD.BlackMarketUtility.GetCallingCardRows()
		local f47_local8 = 0
		for f47_local14, f47_local15 in ipairs( f47_local7 ) do
			local f47_local16 = Engine.TableLookupGetColumnValueForRow( CoD.BlackMarketUtility.lootTableName, f47_local15, 0 )
			local f47_local12
			if Engine.TableLookupGetColumnValueForRow( CoD.BlackMarketUtility.lootTableName, f47_local15, 4 ) ~= "" or Engine.TableLookupGetColumnValueForRow( CoD.BlackMarketUtility.lootTableName, f47_local15, 5 ) == "" then
				f47_local12 = false
			else
				f47_local12 = true
			end
			if not CoD.BlackMarketUtility.IsItemLocked( f47_arg0, f47_local16 ) and (not f47_local12 or not BlackMarketHideMasterCallingCards()) then
				local f47_local13 = CoD.BlackMarketUtility.GetLootCallingCardIndex( f47_arg0, f47_local16 )
				if f47_local13 and Engine.IsEmblemBackgroundNew( f47_arg0, f47_local13 ) then
					f47_local8 = f47_local8 + 1
				end
			end
		end
		if not Dvar.ui_disable_side_bet:exists() or Dvar.ui_disable_side_bet:get() == "0" then
			for f47_local15, f47_local16 in ipairs( CoD.ChallengesUtility.GetSideBetCallingCards( f47_arg0, nil ) ) do
				if not f47_local16.models.isLocked and Engine.IsEmblemBackgroundNew( f47_arg0, f47_local16.models.iconId ) then
					f47_local8 = f47_local8 + 1
				end
			end
		end
		for f47_local14, f47_local15 in ipairs( CoD.ChallengesUtility.SpecialContractCategories ) do
			for f47_local13, f47_local17 in ipairs( CoD.ChallengesUtility.GetChallengeTable( f47_arg0, Enum.eModes.MODE_MULTIPLAYER, "mp", f47_local15, nil, false ) ) do
				if not f47_local17.models.isLocked and Engine.IsEmblemBackgroundNew( f47_arg0, f47_local17.models.iconId ) then
					f47_local8 = f47_local8 + 1
				end
			end
		end
		f47_local5( "MENU_BLACK_MARKET", "CoD.CallingCards_Set_BlackMarket", "loot", "callingcards_bm", f47_local8 )
	end
	table.insert( f47_local0, {
		models = {
			tabIcon = CoD.buttonStrings.shoulderr
		},
		properties = {
			m_mouseDisabled = true
		}
	} )
	return f47_local0
end, true )

CoD.BlackMarketUtility.IsLimitedBlackMarketItem = function() return false end
CoD.BlackMarketUtility.IsHiddenLimitedBlackMarketItem = function() return false end
Engine.IsWeaponOptionLockedEntitlement = function() return false end

Engine.GetQuickJoinPlayersCount = function() return 0 end
Engine.GetQuickJoinPlayers = function()
	local tbl = {}
	return tbl
end

DataSources.BubbleGumTabType = ListHelper_SetupDataSource( "BubbleGumTabType", function ( f245_arg0 )
	local f245_local0 = {}
	table.insert( f245_local0, {
		models = {
			tabIcon = CoD.buttonStrings.shoulderl
		},
		properties = {
			m_mouseDisabled = true
		}
	} )
	table.insert( f245_local0, {
		models = {
			tabName = Engine.Localize( "ZMUI_BUBBLEGUM_TAB_NAME_CAPS" ),
			breadcrumbCount = Engine.WeaponGroupNewItemCount( f245_arg0, "bubblegum", "", Enum.eModes.MODE_ZOMBIES )
		},
		properties = {
			filter = "bubblegum"
		}
	} )
	if true then
		table.insert( f245_local0, {
			models = {
				tabName = Engine.Localize( "ZMUI_MEGACHEW_CAPS" ),
				breadcrumbCount = Engine.WeaponGroupNewItemCount( f245_arg0, "bubblegum_consumable", "", Enum.eModes.MODE_ZOMBIES )
			},
			properties = {
				filter = "bubblegum_consumable"
			}
		} )
	end
	table.insert( f245_local0, {
		models = {
			tabIcon = CoD.buttonStrings.shoulderr
		},
		properties = {
			m_mouseDisabled = true
		}
	} )
	return f245_local0
end, true )

function FocusWeaponBuildKit( f1244_arg0, f1244_arg1, f1244_arg2 )
	Gunsmith_GainFocus( f1244_arg0, f1244_arg1, f1244_arg2 )
	local f1244_local0 = CoD.GetCustomization( f1244_arg2, "weapon_index" )
	if not f1244_local0 then
		return 
	else
		local f1244_local1 = CoD.CraftUtility.Gunsmith.GetSortedWeaponVariantList( f1244_local0 )

		if f1244_local1 then
			if f1244_local1[#f1244_local1] then
				local indx = f1244_local1[#f1244_local1].variantIndex
				if not indx then return end
				local f1244_local2 = CoD.CraftUtility.Gunsmith.GetVariantByIndex( f1244_arg2, f1244_local1[#f1244_local1].variantIndex )
				if f1244_local2 then 
					local f1244_local3 = Engine.CreateModel( Engine.GetModelForController( f1244_arg2 ), "WeaponBuildKitVariant" )
					DataSources.GunsmithVariantList.createVariantModel( f1244_arg2, f1244_local0, f1244_local2, 1, f1244_local3 )
					CoD.perController[f1244_arg2].gunsmithVariantModel = f1244_local3
					CoD.CraftUtility.Gunsmith.DisplayWeaponWithVariant( f1244_arg2, CoD.perController[f1244_arg2].gunsmithVariantModel )
					f1244_arg0:setModel( f1244_local3 )
					f1244_arg0.WeaponBuildKitsAttachmentsPreview:processEvent( {
						name = "update_state",
						controller = f1244_arg2
					} )
				end
			end
		end

		
	end
end

function GetBGBOverrideCount(count, id, ref)

	if Engine.TableLookup(nil, "gamedata/stats/zm/zm_statstable.csv", 0, id, 2) ~= "bubblegum_consumable" then return count end

	if id == 195 then return 50 end

	local datype = Engine.TableLookup(nil, "gamedata/stats/zm/zm_statstable.csv", 0, id, 16)

	if datype == "1" then return CoD.zbr_max_megas end
	if datype == "2" then return CoD.zbr_max_rmegas end
	if datype == "3" then return CoD.zbr_max_urmegas end

	return count
end

function GetConsumableCountFromIndex( f297_arg0, item_index )
	local controller_index = f297_arg0
	if Engine.IsZombiesGame() then
		if CoD.BubbleGumBuffUtility.UseTestData() then
			return 11
		else
			local f297_local1 = Engine.GetPlayerStats( controller_index )
			local f297_local2 = Engine.GetLootItemQuantity( controller_index, Engine.GetItemRef( item_index ), Enum.eModes.MODE_ZOMBIES )
			
			f297_local2 = GetBGBOverrideCount(f297_local2, item_index, Engine.GetItemRef(item_index))

			if not f297_local2 then
				return 0
			else
				return math.min( 999, math.max( f297_local2, 0 ) )
			end
		end
	else
		return 0
	end
end

function SetEmblemBackground_Internal( f75_arg0, f75_arg1 )
	Engine.ExecNow( f75_arg0, "emblemSelectBackground " .. f75_arg1 )
	CoD.perController[f75_arg0].uploadProfile = true
	Engine.SetProfileVar( f75_arg0, "default_background_index", f75_arg1 )
	Engine.ExecNow( f75_arg0, "emblemSetProfile" )
	Engine.ExecNow( f75_arg0, "invalidateEmblemComponent" )
end

function ValidateEmblemBackground( f13_arg0, f13_arg1 )
	return f13_arg1
end

function CallingCards_SetPlayerBackground( f1188_arg0, f1188_arg1, f1188_arg2 )
	local f1188_local0 = Engine.GetModel( f1188_arg1:getModel(), "iconId" )
	if f1188_local0 ~= nil then
		local f1188_local1 = Engine.GetModelValue( f1188_local0 )
		if f1188_arg0.callingCardShowcaseSlot then
			Engine.SetCombatRecordBackgroundId( f1188_arg2, f1188_local1, f1188_arg0.callingCardShowcaseSlot )
			local f1188_local2 = Engine.GetModel( Engine.GetGlobalModel(), "CallingCardShowcaseUpdated" )
			if f1188_local2 then
				Engine.ForceNotifyModelSubscriptions( f1188_local2 )
			end
			GoBackToMenu( f1188_arg0, f1188_arg2, "CombatRecordMP" )
			CoD.perController[f1188_arg2].currentCallingCardTabElement = nil
		else
			-- Engine.ComError( Enum.errorCode.ERROR_UI, "gaga: " .. tostring(f1188_local1) )
			SetEmblemBackground_Internal( f1188_arg2, f1188_local1 )
		end
		f1188_arg1:playSound( "list_action", f1188_arg2 )
	end
	ForceNotifyControllerModel( f1188_arg2, "identityBadge.xuid" )
end

Engine["IsWeaponOptionNew"] = function() return false end

Engine.ExecNow(0, "emblemsetprofile")
CoD.perController[0].uploadProfile = true
Engine.ExecNow(0, "invalidateEmblemComponent")

function GetAttachmentImageFromIndex( f262_arg0, f262_arg1, f262_arg2 )
	local f262_local0 = tonumber( f262_arg2 )
	local f262_local1 = tonumber( f262_arg1 )
	local f262_local2 = ""
	local f262_local3 = CoD.GetCustomization( f262_arg0, "weapon_index" )
	local f262_local4 = CoD.perController[f262_arg0].gunsmithVariantModel

	local f262_local5 = Engine.GetModelValue( Engine.GetModel( f262_local4, "attachmentVariant" .. f262_local1 ) )
	if f262_local0 > CoD.CraftUtility.Gunsmith.EMPTY_ITEM_INDEX then
		if f262_local5 == 0 then
			f262_local2 = Engine.GetAttachmentUniqueImageByAttachmentIndex( CoD.CraftUtility.GetCraftMode(), f262_local3, f262_local0 )
		else
			local f262_local6 = Engine.GetAttachmentCosmeticVariant( CoD.CraftUtility.Gunsmith.GetWeaponPlusAttachmentsForVariant( f262_arg0, f262_local4 ), f262_local0 )
			if f262_local6 == nil then
				return ""
			end
			f262_local2 = f262_local6.image
		end
	end
	return f262_local2
end

setup_team_stuff()

function IsLobbyWithTeamAssignment()
	return CoD.zbr_loaded and ZBR.IsDuos()
end

require( "ui.uieditor.widgets.Lobby.Lists.Members.LobbyMemberTeamSwitcher" )
require( "ui.uieditor.widgets.Lobby.Lists.Members.LobbyMemberTeamColor" )

local LobbyMemberTeamSwitcherPostLoadFunc = function ( self, controller, menu )
	self.SetupTeamSwitch = function ( f2_arg0, f2_arg1 )
		f2_arg0.TeamSwitchName:setText( CoD.teamName[f2_arg1] )
		f2_arg0:playClip( "TeamSwitch" )
	end
	
end

CoD.LobbyMemberTeamSwitcher = InheritFrom( LUI.UIElement )
CoD.LobbyMemberTeamSwitcher.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.LobbyMemberTeamSwitcher )
	self.id = "LobbyMemberTeamSwitcher"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 163 )
	self:setTopBottom( true, false, 0, 25 )
	self.anyChildUsesUpdateState = true
	
	local spectatorColor = LUI.UIImage.new()
	spectatorColor:setLeftRight( false, true, -163, 0 )
	spectatorColor:setTopBottom( true, true, 0, 0 )
	spectatorColor:setRGB( 0.1, 0.1, 0.1 )
	spectatorColor:setAlpha( 0 )
	spectatorColor:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_edges" ) )
	spectatorColor:setShaderVector( 0, 0.02, 0.02, 0.02, 0.02 )
	self:addElement( spectatorColor )
	self.spectatorColor = spectatorColor
	
	local TeamSwitchName = LUI.UIText.new()
	TeamSwitchName:setLeftRight( false, true, -128, -31 )
	TeamSwitchName:setTopBottom( false, false, -9, 11 )
	TeamSwitchName:setAlpha( 0 )
	TeamSwitchName:setText( Engine.Localize( "" ) )
	TeamSwitchName:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
	TeamSwitchName:setLetterSpacing( 0.5 )
	TeamSwitchName:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	TeamSwitchName:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
	self:addElement( TeamSwitchName )
	self.TeamSwitchName = TeamSwitchName
	
	local BumperButtonWithKeyMouseLeft = CoD.BumperButtonWithKeyMouse.new( menu, controller )
	BumperButtonWithKeyMouseLeft:setLeftRight( true, false, 1.75, 43.25 )
	BumperButtonWithKeyMouseLeft:setTopBottom( true, false, -1, 27 )
	BumperButtonWithKeyMouseLeft:setAlpha( 0 )
	BumperButtonWithKeyMouseLeft:subscribeToGlobalModel( controller, "Controller", "left_shoulder_button_image", function ( modelRef )
		local leftShoulderButtonImage = Engine.GetModelValue( modelRef )
		if leftShoulderButtonImage then
			BumperButtonWithKeyMouseLeft.ControllerImage:setImage( RegisterImage( leftShoulderButtonImage ) )
		end
	end )
	BumperButtonWithKeyMouseLeft:registerEventHandler( "button_action", function ( element, event )
		local f5_local0 = nil
		SendButtonPressToMenuEx( menu, controller, Enum.LUIButton.LUI_KEY_LB )
		if not f5_local0 then
			f5_local0 = element:dispatchEventToChildren( event )
		end
		return f5_local0
	end )
	self:addElement( BumperButtonWithKeyMouseLeft )
	self.BumperButtonWithKeyMouseLeft = BumperButtonWithKeyMouseLeft
	
	local BumperButtonWithKeyMouseRight = CoD.BumperButtonWithKeyMouse.new( menu, controller )
	BumperButtonWithKeyMouseRight:setLeftRight( true, false, 123.75, 165.25 )
	BumperButtonWithKeyMouseRight:setTopBottom( true, false, -1, 27 )
	BumperButtonWithKeyMouseRight:setAlpha( 0 )
	BumperButtonWithKeyMouseRight.KeyMouseImage:setImage( RegisterImage( "uie_bumperright" ) )
	BumperButtonWithKeyMouseRight:subscribeToGlobalModel( controller, "Controller", "right_shoulder_button_image", function ( modelRef )
		local rightShoulderButtonImage = Engine.GetModelValue( modelRef )
		if rightShoulderButtonImage then
			BumperButtonWithKeyMouseRight.ControllerImage:setImage( RegisterImage( rightShoulderButtonImage ) )
		end
	end )
	BumperButtonWithKeyMouseRight:registerEventHandler( "button_action", function ( element, event )
		local f7_local0 = nil
		SendButtonPressToMenuEx( menu, controller, Enum.LUIButton.LUI_KEY_RB )
		if not f7_local0 then
			f7_local0 = element:dispatchEventToChildren( event )
		end
		return f7_local0
	end )
	self:addElement( BumperButtonWithKeyMouseRight )
	self.BumperButtonWithKeyMouseRight = BumperButtonWithKeyMouseRight
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 2 )
				BumperButtonWithKeyMouseLeft:completeAnimation()
				self.BumperButtonWithKeyMouseLeft:setAlpha( 0 )
				self.clipFinished( BumperButtonWithKeyMouseLeft, {} )
				BumperButtonWithKeyMouseRight:completeAnimation()
				self.BumperButtonWithKeyMouseRight:setAlpha( 0 )
				self.clipFinished( BumperButtonWithKeyMouseRight, {} )
			end,
			TeamSwitch = function ()
				self:setupElementClipCounter( 4 )
				local f9_local0 = function ( f10_arg0, f10_arg1 )
					local f10_local0 = function ( f11_arg0, f11_arg1 )
						if not f11_arg1.interrupted then
							f11_arg0:beginAnimation( "keyframe", 500, false, false, CoD.TweenType.Linear )
						end
						f11_arg0:setAlpha( 0 )
						if f11_arg1.interrupted then
							self.clipFinished( f11_arg0, f11_arg1 )
						else
							f11_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f10_arg1.interrupted then
						f10_local0( f10_arg0, f10_arg1 )
						return 
					else
						f10_arg0:beginAnimation( "keyframe", 1000, false, false, CoD.TweenType.Linear )
						f10_arg0:registerEventHandler( "transition_complete_keyframe", f10_local0 )
					end
				end
				
				spectatorColor:completeAnimation()
				self.spectatorColor:setAlpha( 1 )
				f9_local0( spectatorColor, {} )
				local f9_local1 = function ( f12_arg0, f12_arg1 )
					local f12_local0 = function ( f13_arg0, f13_arg1 )
						if not f13_arg1.interrupted then
							f13_arg0:beginAnimation( "keyframe", 500, false, false, CoD.TweenType.Linear )
						end
						f13_arg0:setAlpha( 0 )
						if f13_arg1.interrupted then
							self.clipFinished( f13_arg0, f13_arg1 )
						else
							f13_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f12_arg1.interrupted then
						f12_local0( f12_arg0, f12_arg1 )
						return 
					else
						f12_arg0:beginAnimation( "keyframe", 1000, false, false, CoD.TweenType.Linear )
						f12_arg0:registerEventHandler( "transition_complete_keyframe", f12_local0 )
					end
				end
				
				TeamSwitchName:completeAnimation()
				self.TeamSwitchName:setAlpha( 1 )
				f9_local1( TeamSwitchName, {} )
				local f9_local2 = function ( f14_arg0, f14_arg1 )
					local f14_local0 = function ( f15_arg0, f15_arg1 )
						if not f15_arg1.interrupted then
							f15_arg0:beginAnimation( "keyframe", 500, false, false, CoD.TweenType.Linear )
						end
						f15_arg0:setAlpha( 0 )
						if f15_arg1.interrupted then
							self.clipFinished( f15_arg0, f15_arg1 )
						else
							f15_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f14_arg1.interrupted then
						f14_local0( f14_arg0, f14_arg1 )
						return 
					else
						f14_arg0:beginAnimation( "keyframe", 1000, false, false, CoD.TweenType.Linear )
						f14_arg0:registerEventHandler( "transition_complete_keyframe", f14_local0 )
					end
				end
				
				BumperButtonWithKeyMouseLeft:completeAnimation()
				self.BumperButtonWithKeyMouseLeft:setAlpha( 1 )
				f9_local2( BumperButtonWithKeyMouseLeft, {} )
				local f9_local3 = function ( f16_arg0, f16_arg1 )
					local f16_local0 = function ( f17_arg0, f17_arg1 )
						if not f17_arg1.interrupted then
							f17_arg0:beginAnimation( "keyframe", 500, false, false, CoD.TweenType.Linear )
						end
						f17_arg0:setAlpha( 0 )
						if f17_arg1.interrupted then
							self.clipFinished( f17_arg0, f17_arg1 )
						else
							f17_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f16_arg1.interrupted then
						f16_local0( f16_arg0, f16_arg1 )
						return 
					else
						f16_arg0:beginAnimation( "keyframe", 1000, false, false, CoD.TweenType.Linear )
						f16_arg0:registerEventHandler( "transition_complete_keyframe", f16_local0 )
					end
				end
				
				BumperButtonWithKeyMouseRight:completeAnimation()
				self.BumperButtonWithKeyMouseRight:setAlpha( 1 )
				f9_local3( BumperButtonWithKeyMouseRight, {} )
			end
		},
		Invisible = {
			DefaultClip = function ()
				self:setupElementClipCounter( 2 )
				spectatorColor:completeAnimation()
				self.spectatorColor:setAlpha( 0 )
				self.clipFinished( spectatorColor, {} )
				TeamSwitchName:completeAnimation()
				self.TeamSwitchName:setAlpha( 0 )
				self.clipFinished( TeamSwitchName, {} )
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "Invisible",
			condition = function ( menu, element, event )
				return not IsGameLobby()
			end
		}
	} )
	self:subscribeToModel( Engine.GetModel( Engine.GetGlobalModel(), "lobbyRoot.lobbyNav" ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.BumperButtonWithKeyMouseLeft:close()
		element.BumperButtonWithKeyMouseRight:close()
	end )
	
	LobbyMemberTeamSwitcherPostLoadFunc( self, controller, menu )
	
	return self
end

local LobbyMemberTeamColorPostLoadFunc = function ( self, controller, menu )
	self.SetupTeamSwitch = function ( f2_arg0, f2_arg1 )
		if f2_arg1 == Enum.team_t.TEAM_ALLIES then
			f2_arg0.TeamColorBackground:setState( "Allies" )
		elseif f2_arg1 == Enum.team_t.TEAM_AXIS then
			f2_arg0.TeamColorBackground:setState( "Axis" )
		elseif f2_arg1 == Enum.team_t.TEAM_FOUR then
			f2_arg0.TeamColorBackground:setState( "Team4" )
		elseif f2_arg1 == Enum.team_t.TEAM_FIVE then
			f2_arg0.TeamColorBackground:setState( "Team5" )
		elseif f2_arg1 == Enum.team_t.TEAM_SIX then
			f2_arg0.TeamColorBackground:setState( "Team6" )
		elseif f2_arg1 == Enum.team_t.TEAM_SEVEN then
			f2_arg0.TeamColorBackground:setState( "Team7" )
		elseif f2_arg1 == Enum.team_t.TEAM_EIGHT then
			f2_arg0.TeamColorBackground:setState( "Team8" )
		elseif f2_arg1 == Enum.team_t.TEAM_NINE then
			f2_arg0.TeamColorBackground:setState( "Team9" )
		end
		f2_arg0:playClip( "TeamSwitch" )
	end
	
	self.SetupTeamColorBackground = function ( f3_arg0, f3_arg1 )
		f3_arg0.TeamColorBackground:SetupTeamColors( f3_arg1 )
	end
	
end

CoD.LobbyMemberTeamColor = InheritFrom( LUI.UIElement )
CoD.LobbyMemberTeamColor.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.LobbyMemberTeamColor )
	self.id = "LobbyMemberTeamColor"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 400 )
	self:setTopBottom( true, false, 0, 25 )
	self.anyChildUsesUpdateState = true
	
	local Dimmer = LUI.UIImage.new()
	Dimmer:setLeftRight( true, true, 0, 0 )
	Dimmer:setTopBottom( true, true, 0, 0 )
	Dimmer:setRGB( 0.11, 0.11, 0.11 )
	Dimmer:setAlpha( 0 )
	Dimmer:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_edges" ) )
	Dimmer:setShaderVector( 0, 0.02, 0.02, 0.02, 0.02 )
	self:addElement( Dimmer )
	self.Dimmer = Dimmer
	
	local LobbyMemberTeamColorBackgroundOnChange = CoD.LobbyMemberTeamColorBackground_OnChange.new( menu, controller )
	LobbyMemberTeamColorBackgroundOnChange:setLeftRight( true, false, 0, 400 )
	LobbyMemberTeamColorBackgroundOnChange:setTopBottom( true, false, 0, 25 )
	self:addElement( LobbyMemberTeamColorBackgroundOnChange )
	self.LobbyMemberTeamColorBackgroundOnChange = LobbyMemberTeamColorBackgroundOnChange
	
	local FEButtonPanelShaderContainer0 = CoD.FE_ButtonPanelShaderContainer.new( menu, controller )
	FEButtonPanelShaderContainer0:setLeftRight( true, true, 0, 0 )
	FEButtonPanelShaderContainer0:setTopBottom( true, true, 0, 0 )
	FEButtonPanelShaderContainer0:setAlpha( 0 )
	self:addElement( FEButtonPanelShaderContainer0 )
	self.FEButtonPanelShaderContainer0 = FEButtonPanelShaderContainer0
	
	local TeamColorBackground = CoD.LobbyMemberTeamColorBackground.new( menu, controller )
	TeamColorBackground:setLeftRight( true, true, 0, 0 )
	TeamColorBackground:setTopBottom( true, true, 0, 0 )
	TeamColorBackground:linkToElementModel( self, nil, false, function ( modelRef )
		TeamColorBackground:setModel( modelRef, controller )
	end )
	TeamColorBackground:mergeStateConditions( {
		{
			stateName = "Axis",
			condition = function ( menu, element, event )
				return IsSelfModelValueEqualToEnum( element, controller, "teamSwitch", Enum.team_t.TEAM_AXIS )
			end
		},
		{
			stateName = "Allies",
			condition = function ( menu, element, event )
				return IsSelfModelValueEqualToEnum( element, controller, "teamSwitch", Enum.team_t.TEAM_ALLIES )
			end
		},
		{
			stateName = "Team4",
			condition = function ( menu, element, event )
				return IsSelfModelValueEqualToEnum( element, controller, "teamSwitch", Enum.team_t.TEAM_FOUR )
			end
		},
		{
			stateName = "Team5",
			condition = function ( menu, element, event )
				return IsSelfModelValueEqualToEnum( element, controller, "teamSwitch", Enum.team_t.TEAM_FIVE )
			end
		},
		{
			stateName = "Team6",
			condition = function ( menu, element, event )
				return IsSelfModelValueEqualToEnum( element, controller, "teamSwitch", Enum.team_t.TEAM_SIX )
			end
		},
		{
			stateName = "Team7",
			condition = function ( menu, element, event )
				return IsSelfModelValueEqualToEnum( element, controller, "teamSwitch", Enum.team_t.TEAM_SEVEN )
			end
		},
		{
			stateName = "Team8",
			condition = function ( menu, element, event )
				return IsSelfModelValueEqualToEnum( element, controller, "teamSwitch", Enum.team_t.TEAM_EIGHT )
			end
		},
		{
			stateName = "Team9",
			condition = function ( menu, element, event )
				return IsSelfModelValueEqualToEnum( element, controller, "teamSwitch", Enum.team_t.TEAM_NINE )
			end
		}
	} )
	TeamColorBackground:linkToElementModel( TeamColorBackground, "teamSwitch", true, function ( modelRef )
		menu:updateElementState( TeamColorBackground, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "teamSwitch"
		} )
	end )
	self:addElement( TeamColorBackground )
	self.TeamColorBackground = TeamColorBackground
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end,
			TeamSwitch = function ()
				self:setupElementClipCounter( 2 )
				local f11_local0 = function ( f12_arg0, f12_arg1 )
					local f12_local0 = function ( f13_arg0, f13_arg1 )
						if not f13_arg1.interrupted then
							f13_arg0:beginAnimation( "keyframe", 500, false, false, CoD.TweenType.Linear )
						end
						f13_arg0:setAlpha( 0 )
						if f13_arg1.interrupted then
							self.clipFinished( f13_arg0, f13_arg1 )
						else
							f13_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f12_arg1.interrupted then
						f12_local0( f12_arg0, f12_arg1 )
						return 
					else
						f12_arg0:beginAnimation( "keyframe", 1000, false, false, CoD.TweenType.Linear )
						f12_arg0:registerEventHandler( "transition_complete_keyframe", f12_local0 )
					end
				end
				
				Dimmer:completeAnimation()
				self.Dimmer:setAlpha( 0.75 )
				f11_local0( Dimmer, {} )
				local f11_local1 = function ( f14_arg0, f14_arg1 )
					local f14_local0 = function ( f15_arg0, f15_arg1 )
						if not f15_arg1.interrupted then
							f15_arg0:beginAnimation( "keyframe", 500, false, false, CoD.TweenType.Linear )
						end
						f15_arg0:setAlpha( 0 )
						if f15_arg1.interrupted then
							self.clipFinished( f15_arg0, f15_arg1 )
						else
							f15_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f14_arg1.interrupted then
						f14_local0( f14_arg0, f14_arg1 )
						return 
					else
						f14_arg0:beginAnimation( "keyframe", 1000, false, false, CoD.TweenType.Linear )
						f14_arg0:registerEventHandler( "transition_complete_keyframe", f14_local0 )
					end
				end
				
				LobbyMemberTeamColorBackgroundOnChange:completeAnimation()
				self.LobbyMemberTeamColorBackgroundOnChange:setAlpha( 1 )
				f11_local1( LobbyMemberTeamColorBackgroundOnChange, {} )
			end
		},
		Invisible = {
			DefaultClip = function ()
				self:setupElementClipCounter( 3 )
				Dimmer:completeAnimation()
				self.Dimmer:setAlpha( 0 )
				self.clipFinished( Dimmer, {} )
				LobbyMemberTeamColorBackgroundOnChange:completeAnimation()
				self.LobbyMemberTeamColorBackgroundOnChange:setAlpha( 0 )
				self.clipFinished( LobbyMemberTeamColorBackgroundOnChange, {} )
				TeamColorBackground:completeAnimation()
				self.TeamColorBackground:setAlpha( 0 )
				self.clipFinished( TeamColorBackground, {} )
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "Invisible",
			condition = function ( menu, element, event )
				return not IsGameLobby()
			end
		}
	} )
	self:subscribeToModel( Engine.GetModel( Engine.GetGlobalModel(), "lobbyRoot.lobbyNav" ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.LobbyMemberTeamColorBackgroundOnChange:close()
		element.FEButtonPanelShaderContainer0:close()
		element.TeamColorBackground:close()
	end )
	
	LobbyMemberTeamColorPostLoadFunc( self, controller, menu )
	
	return self
end

local LobbyMemberTeamColorBackgroundPostLoadFunc = function ( f1_arg0, f1_arg1 )
	f1_arg0.SetupTeamColors = function ( f2_arg0, f2_arg1 )
		f2_arg0.alliesColor:setRGB( CoD.GetTeamFactionColor( Enum.team_t.TEAM_ALLIES ) )
		f2_arg0.axisColor:setRGB( CoD.GetTeamFactionColor( Enum.team_t.TEAM_AXIS ) )
		f2_arg0.team4color:setRGB( CoD.GetTeamFactionColor( Enum.team_t.TEAM_FOUR ) )
		f2_arg0.team5color:setRGB( CoD.GetTeamFactionColor( Enum.team_t.TEAM_FIVE ) )
		f2_arg0.team6color:setRGB( CoD.GetTeamFactionColor( Enum.team_t.TEAM_SIX ) )
		f2_arg0.team7color:setRGB( CoD.GetTeamFactionColor( Enum.team_t.TEAM_SEVEN ) )
		f2_arg0.team8color:setRGB( CoD.GetTeamFactionColor( Enum.team_t.TEAM_EIGHT ) )
		f2_arg0.team9color:setRGB( CoD.GetTeamFactionColor( Enum.team_t.TEAM_NINE ) )
	end
	
end

CoD.LobbyMemberTeamColorBackground = InheritFrom( LUI.UIElement )
CoD.LobbyMemberTeamColorBackground.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.LobbyMemberTeamColorBackground )
	self.id = "LobbyMemberTeamColorBackground"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 400 )
	self:setTopBottom( true, false, 0, 25 )
	
	local spectatorColor = LUI.UIImage.new()
	spectatorColor:setLeftRight( true, true, 0, 0 )
	spectatorColor:setTopBottom( true, true, 0, 0 )
	spectatorColor:setRGB( ColorSet.CodCaster.r, ColorSet.CodCaster.g, ColorSet.CodCaster.b )
	spectatorColor:setAlpha( 0.25 )
	spectatorColor:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
	self:addElement( spectatorColor )
	self.spectatorColor = spectatorColor
	
	local alliesColor = LUI.UIImage.new()
	alliesColor:setLeftRight( true, true, 0, 0 )
	alliesColor:setTopBottom( true, true, 0, 0 )
	alliesColor:setRGB( CoD.teamColor[Enum.team_t.TEAM_ALLIES].r, CoD.teamColor[Enum.team_t.TEAM_ALLIES].g, CoD.teamColor[Enum.team_t.TEAM_ALLIES].b )
	alliesColor:setAlpha( 0 )
	alliesColor:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
	self:addElement( alliesColor )
	self.alliesColor = alliesColor
	
	local axisColor = LUI.UIImage.new()
	axisColor:setLeftRight( true, true, 0, 0 )
	axisColor:setTopBottom( true, true, 0, 0 )
	axisColor:setRGB( CoD.teamColor[Enum.team_t.TEAM_AXIS].r, CoD.teamColor[Enum.team_t.TEAM_AXIS].g, CoD.teamColor[Enum.team_t.TEAM_AXIS].b )
	axisColor:setAlpha( 0 )
	axisColor:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
	self:addElement( axisColor )
	self.axisColor = axisColor

	local team4color = LUI.UIImage.new()
	team4color:setLeftRight( true, true, 0, 0 )
	team4color:setTopBottom( true, true, 0, 0 )
	team4color:setRGB( CoD.teamColor[Enum.team_t.TEAM_FOUR].r, CoD.teamColor[Enum.team_t.TEAM_FOUR].g, CoD.teamColor[Enum.team_t.TEAM_FOUR].b )
	team4color:setAlpha( 0 )
	team4color:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
	self:addElement( team4color )
	self.team4color = team4color

	local team5color = LUI.UIImage.new()
	team5color:setLeftRight( true, true, 0, 0 )
	team5color:setTopBottom( true, true, 0, 0 )
	team5color:setRGB( CoD.teamColor[Enum.team_t.TEAM_FIVE].r, CoD.teamColor[Enum.team_t.TEAM_FIVE].g, CoD.teamColor[Enum.team_t.TEAM_FIVE].b )
	team5color:setAlpha( 0 )
	team5color:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
	self:addElement( team5color )
	self.team5color = team5color

	local team6color = LUI.UIImage.new()
	team6color:setLeftRight( true, true, 0, 0 )
	team6color:setTopBottom( true, true, 0, 0 )
	team6color:setRGB( CoD.teamColor[Enum.team_t.TEAM_SIX].r, CoD.teamColor[Enum.team_t.TEAM_SIX].g, CoD.teamColor[Enum.team_t.TEAM_SIX].b )
	team6color:setAlpha( 0 )
	team6color:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
	self:addElement( team6color )
	self.team6color = team6color

	local team7color = LUI.UIImage.new()
	team7color:setLeftRight( true, true, 0, 0 )
	team7color:setTopBottom( true, true, 0, 0 )
	team7color:setRGB( CoD.teamColor[Enum.team_t.TEAM_SEVEN].r, CoD.teamColor[Enum.team_t.TEAM_SEVEN].g, CoD.teamColor[Enum.team_t.TEAM_SEVEN].b )
	team7color:setAlpha( 0 )
	team7color:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
	self:addElement( team7color )
	self.team7color = team7color

	local team8color = LUI.UIImage.new()
	team8color:setLeftRight( true, true, 0, 0 )
	team8color:setTopBottom( true, true, 0, 0 )
	team8color:setRGB( CoD.teamColor[Enum.team_t.TEAM_EIGHT].r, CoD.teamColor[Enum.team_t.TEAM_EIGHT].g, CoD.teamColor[Enum.team_t.TEAM_EIGHT].b )
	team8color:setAlpha( 0 )
	team8color:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
	self:addElement( team8color )
	self.team8color = team8color

	local team9color = LUI.UIImage.new()
	team9color:setLeftRight( true, true, 0, 0 )
	team9color:setTopBottom( true, true, 0, 0 )
	team9color:setRGB( CoD.teamColor[Enum.team_t.TEAM_NINE].r, CoD.teamColor[Enum.team_t.TEAM_NINE].g, CoD.teamColor[Enum.team_t.TEAM_NINE].b )
	team9color:setAlpha( 0 )
	team9color:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
	self:addElement( team9color )
	self.team9color = team9color
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 9 )
				spectatorColor:completeAnimation()
				self.spectatorColor:setAlpha( 0 )
				self.clipFinished( spectatorColor, {} )
				alliesColor:completeAnimation()
				self.alliesColor:setAlpha( 0 )
				self.clipFinished( alliesColor, {} )
				axisColor:completeAnimation()
				self.axisColor:setAlpha( 0 )
				self.clipFinished( axisColor, {} )

				-- team4color:completeAnimation()
				-- self.team4color:setAlpha( 0 )
				-- self.clipFinished( team4color, {} )
				-- team5color:completeAnimation()
				-- self.team5color:setAlpha( 0 )
				-- self.clipFinished( team5color, {} )
				-- team6color:completeAnimation()
				-- self.team6color:setAlpha( 0 )
				-- self.clipFinished( team6color, {} )
				-- team7color:completeAnimation()
				-- self.team7color:setAlpha( 0 )
				-- self.clipFinished( team7color, {} )
				-- team8color:completeAnimation()
				-- self.team8color:setAlpha( 0 )
				-- self.clipFinished( team8color, {} )
				-- team9color:completeAnimation()
				-- self.team9color:setAlpha( 0 )
				-- self.clipFinished( team9color, {} )
			end
		},
		Axis = {
			DefaultClip = function ()
				self:setupElementClipCounter( 9 )
				spectatorColor:completeAnimation()
				self.spectatorColor:setAlpha( 0 )
				self.clipFinished( spectatorColor, {} )
				alliesColor:completeAnimation()
				self.alliesColor:setAlpha( 0 )
				self.clipFinished( alliesColor, {} )
				axisColor:completeAnimation()
				self.axisColor:setAlpha( 0.25 )
				self.axisColor:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_normal" ) )
				self.clipFinished( axisColor, {} )

				team4color:completeAnimation()
				self.team4color:setAlpha( 0 )
				self.clipFinished( team4color, {} )
				team5color:completeAnimation()
				self.team5color:setAlpha( 0 )
				self.clipFinished( team5color, {} )
				team6color:completeAnimation()
				self.team6color:setAlpha( 0 )
				self.clipFinished( team6color, {} )
				team7color:completeAnimation()
				self.team7color:setAlpha( 0 )
				self.clipFinished( team7color, {} )
				team8color:completeAnimation()
				self.team8color:setAlpha( 0 )
				self.clipFinished( team8color, {} )
				team9color:completeAnimation()
				self.team9color:setAlpha( 0 )
				self.clipFinished( team9color, {} )
			end
		},
		Allies = {
			DefaultClip = function ()
				self:setupElementClipCounter( 9 )
				spectatorColor:completeAnimation()
				self.spectatorColor:setAlpha( 0 )
				self.clipFinished( spectatorColor, {} )
				alliesColor:completeAnimation()
				self.alliesColor:setAlpha( 0.25 )
				self.alliesColor:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
				self.clipFinished( alliesColor, {} )
				axisColor:completeAnimation()
				self.axisColor:setAlpha( 0 )
				self.clipFinished( axisColor, {} )

				team4color:completeAnimation()
				self.team4color:setAlpha( 0 )
				self.clipFinished( team4color, {} )
				team5color:completeAnimation()
				self.team5color:setAlpha( 0 )
				self.clipFinished( team5color, {} )
				team6color:completeAnimation()
				self.team6color:setAlpha( 0 )
				self.clipFinished( team6color, {} )
				team7color:completeAnimation()
				self.team7color:setAlpha( 0 )
				self.clipFinished( team7color, {} )
				team8color:completeAnimation()
				self.team8color:setAlpha( 0 )
				self.clipFinished( team8color, {} )
				team9color:completeAnimation()
				self.team9color:setAlpha( 0 )
				self.clipFinished( team9color, {} )
			end
		},
		Spectator = {
			DefaultClip = function ()
				self:setupElementClipCounter( 9 )
				spectatorColor:completeAnimation()
				self.spectatorColor:setAlpha( 0.25 )
				self.clipFinished( spectatorColor, {} )
				alliesColor:completeAnimation()
				self.alliesColor:setAlpha( 0 )
				self.clipFinished( alliesColor, {} )
				axisColor:completeAnimation()
				self.axisColor:setAlpha( 0 )
				self.clipFinished( axisColor, {} )

				team4color:completeAnimation()
				self.team4color:setAlpha( 0 )
				self.clipFinished( team4color, {} )
				team5color:completeAnimation()
				self.team5color:setAlpha( 0 )
				self.clipFinished( team5color, {} )
				team6color:completeAnimation()
				self.team6color:setAlpha( 0 )
				self.clipFinished( team6color, {} )
				team7color:completeAnimation()
				self.team7color:setAlpha( 0 )
				self.clipFinished( team7color, {} )
				team8color:completeAnimation()
				self.team8color:setAlpha( 0 )
				self.clipFinished( team8color, {} )
				team9color:completeAnimation()
				self.team9color:setAlpha( 0 )
				self.clipFinished( team9color, {} )
			end
		},
		Team4 = {
			DefaultClip = function ()
				self:setupElementClipCounter( 9 )
				spectatorColor:completeAnimation()
				self.spectatorColor:setAlpha( 0 )
				self.clipFinished( spectatorColor, {} )
				team4color:completeAnimation()
				self.team4color:setAlpha( 0.25 )
				self.team4color:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
				self.clipFinished( alliesColor, {} )
				axisColor:completeAnimation()
				self.axisColor:setAlpha( 0 )
				self.clipFinished( axisColor, {} )

				alliesColor:completeAnimation()
				self.alliesColor:setAlpha( 0 )
				self.clipFinished( alliesColor, {} )
				team5color:completeAnimation()
				self.team5color:setAlpha( 0 )
				self.clipFinished( team5color, {} )
				team6color:completeAnimation()
				self.team6color:setAlpha( 0 )
				self.clipFinished( team6color, {} )
				team7color:completeAnimation()
				self.team7color:setAlpha( 0 )
				self.clipFinished( team7color, {} )
				team8color:completeAnimation()
				self.team8color:setAlpha( 0 )
				self.clipFinished( team8color, {} )
				team9color:completeAnimation()
				self.team9color:setAlpha( 0 )
				self.clipFinished( team9color, {} )
			end
		},
		Team5 = {
			DefaultClip = function ()
				self:setupElementClipCounter( 9 )
				spectatorColor:completeAnimation()
				self.spectatorColor:setAlpha( 0 )
				self.clipFinished( spectatorColor, {} )
				team5color:completeAnimation()
				self.team5color:setAlpha( 0.25 )
				self.team5color:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
				self.clipFinished( alliesColor, {} )
				axisColor:completeAnimation()
				self.axisColor:setAlpha( 0 )
				self.clipFinished( axisColor, {} )

				alliesColor:completeAnimation()
				self.alliesColor:setAlpha( 0 )
				self.clipFinished( alliesColor, {} )
				team4color:completeAnimation()
				self.team4color:setAlpha( 0 )
				self.clipFinished( team4color, {} )
				team6color:completeAnimation()
				self.team6color:setAlpha( 0 )
				self.clipFinished( team6color, {} )
				team7color:completeAnimation()
				self.team7color:setAlpha( 0 )
				self.clipFinished( team7color, {} )
				team8color:completeAnimation()
				self.team8color:setAlpha( 0 )
				self.clipFinished( team8color, {} )
				team9color:completeAnimation()
				self.team9color:setAlpha( 0 )
				self.clipFinished( team9color, {} )
			end
		},
		Team6 = {
			DefaultClip = function ()
				self:setupElementClipCounter( 9 )
				spectatorColor:completeAnimation()
				self.spectatorColor:setAlpha( 0 )
				self.clipFinished( spectatorColor, {} )
				team6color:completeAnimation()
				self.team6color:setAlpha( 0.25 )
				self.team6color:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
				self.clipFinished( alliesColor, {} )
				axisColor:completeAnimation()
				self.axisColor:setAlpha( 0 )
				self.clipFinished( axisColor, {} )

				alliesColor:completeAnimation()
				self.alliesColor:setAlpha( 0 )
				self.clipFinished( alliesColor, {} )
				team4color:completeAnimation()
				self.team4color:setAlpha( 0 )
				self.clipFinished( team4color, {} )
				team5color:completeAnimation()
				self.team5color:setAlpha( 0 )
				self.clipFinished( team5color, {} )
				team7color:completeAnimation()
				self.team7color:setAlpha( 0 )
				self.clipFinished( team7color, {} )
				team8color:completeAnimation()
				self.team8color:setAlpha( 0 )
				self.clipFinished( team8color, {} )
				team9color:completeAnimation()
				self.team9color:setAlpha( 0 )
				self.clipFinished( team9color, {} )
			end
		},
		Team7 = {
			DefaultClip = function ()
				self:setupElementClipCounter( 9 )
				spectatorColor:completeAnimation()
				self.spectatorColor:setAlpha( 0 )
				self.clipFinished( spectatorColor, {} )
				team7color:completeAnimation()
				self.team7color:setAlpha( 0.25 )
				self.team7color:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
				self.clipFinished( alliesColor, {} )
				axisColor:completeAnimation()
				self.axisColor:setAlpha( 0 )
				self.clipFinished( axisColor, {} )

				alliesColor:completeAnimation()
				self.alliesColor:setAlpha( 0 )
				self.clipFinished( alliesColor, {} )
				team4color:completeAnimation()
				self.team4color:setAlpha( 0 )
				self.clipFinished( team4color, {} )
				team5color:completeAnimation()
				self.team5color:setAlpha( 0 )
				self.clipFinished( team5color, {} )
				team6color:completeAnimation()
				self.team6color:setAlpha( 0 )
				self.clipFinished( team6color, {} )
				team8color:completeAnimation()
				self.team8color:setAlpha( 0 )
				self.clipFinished( team8color, {} )
				team9color:completeAnimation()
				self.team9color:setAlpha( 0 )
				self.clipFinished( team9color, {} )
			end
		},
		Team8 = {
			DefaultClip = function ()
				self:setupElementClipCounter( 9 )
				spectatorColor:completeAnimation()
				self.spectatorColor:setAlpha( 0 )
				self.clipFinished( spectatorColor, {} )
				team8color:completeAnimation()
				self.team8color:setAlpha( 0.25 )
				self.team8color:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
				self.clipFinished( alliesColor, {} )
				axisColor:completeAnimation()
				self.axisColor:setAlpha( 0 )
				self.clipFinished( axisColor, {} )

				alliesColor:completeAnimation()
				self.alliesColor:setAlpha( 0 )
				self.clipFinished( alliesColor, {} )
				team4color:completeAnimation()
				self.team4color:setAlpha( 0 )
				self.clipFinished( team4color, {} )
				team5color:completeAnimation()
				self.team5color:setAlpha( 0 )
				self.clipFinished( team5color, {} )
				team6color:completeAnimation()
				self.team6color:setAlpha( 0 )
				self.clipFinished( team6color, {} )
				team7color:completeAnimation()
				self.team7color:setAlpha( 0 )
				self.clipFinished( team7color, {} )
				team9color:completeAnimation()
				self.team9color:setAlpha( 0 )
				self.clipFinished( team9color, {} )
			end
		},
		Team9 = {
			DefaultClip = function ()
				self:setupElementClipCounter( 9 )
				spectatorColor:completeAnimation()
				self.spectatorColor:setAlpha( 0 )
				self.clipFinished( spectatorColor, {} )
				team9color:completeAnimation()
				self.team9color:setAlpha( 0.25 )
				self.team9color:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
				self.clipFinished( alliesColor, {} )
				axisColor:completeAnimation()
				self.axisColor:setAlpha( 0 )
				self.clipFinished( axisColor, {} )

				alliesColor:completeAnimation()
				self.alliesColor:setAlpha( 0 )
				self.clipFinished( alliesColor, {} )
				team4color:completeAnimation()
				self.team4color:setAlpha( 0 )
				self.clipFinished( team4color, {} )
				team5color:completeAnimation()
				self.team5color:setAlpha( 0 )
				self.clipFinished( team5color, {} )
				team6color:completeAnimation()
				self.team6color:setAlpha( 0 )
				self.clipFinished( team6color, {} )
				team7color:completeAnimation()
				self.team7color:setAlpha( 0 )
				self.clipFinished( team7color, {} )
				team8color:completeAnimation()
				self.team8color:setAlpha( 0 )
				self.clipFinished( team8color, {} )
			end
		}
	}
	
	LobbyMemberTeamColorBackgroundPostLoadFunc( self, controller, menu )
	
	return self
end

if CoD.zbr_loaded then
	ZBR.ExecInLobbyVM([[
		LobbyData.UITargets.UI_ZMLOBBYONLINE.maxClients = 8
		LobbyData.UITargets.UI_ZMLOBBYONLINEPUBLICGAME.maxClients = 8
		LobbyData.UITargets.UI_ZMLOBBYONLINECUSTOMGAME.maxClients = 8
		LobbyData.UITargets.UI_ZMLOBBYONLINE.title = ""
		LobbyData.UITargets.UI_ZMLOBBYONLINE.kicker = ""
		-- LuaUtils._originalTable.IsArenaMode = function() return true end
	]])

	ZBR.ExecInLobbyVM([[
	require( "lua.lobby.lobbymapvote" )
	
	Lobby.MapVote.SetGameModeName = function ( f2_arg0, f2_arg1, f2_arg2 )
		local gt = Engine.DvarString( nil, "zbr_gametype" )
		if gt == nil or gt == "" then
			gt = "zbr"
		end
		Engine.SetModelValue( Engine.CreateModel( f2_arg0, f2_arg1 ), Engine.ToUpper(Engine.Localize( "ZMUI_GAMETYPE_" .. Engine.ToUpper(gt) )) )
	end
	]])

	ZBR.PostLoad()
end

function LobbyHas4PlayersOrLess()
	return false
end

-- LuaUtils.IsArenaMode = function() return true end