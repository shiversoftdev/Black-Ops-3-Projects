require( "lua.Shared.LobbyData" )
require( "ui.T6.lobby.lobbymenubuttons" )

EnableGlobals()

function IsServerBrowserEnabled()
    return false
end

CoD.LobbyMenus = {}
CoD.LobbyMenus.History = {}
CoD.LobbyMenus.AddButtons = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3 )
	local f1_local0 = Engine.GetModel( DataSources.LobbyRoot.getModel( f1_arg0 ), f1_arg1 )
	local f1_local1 = nil
	if f1_local0 ~= nil then
		f1_local1 = Engine.GetModelValue( f1_local0 )
	end
	if f1_arg3 ~= nil then
		f1_arg3( f1_arg0, f1_arg2, f1_local1 )
	else
		print( "Error: No function provided to CoD.LobbyMenus.AddButtons" )
	end
end

CoD.LobbyMenus.AddButtonsMPCPZM = function ( f2_arg0, f2_arg1, f2_arg2, f2_arg3, f2_arg4, f2_arg5 )
	if Engine.GetModeName() == "CP" then
		CoD.LobbyMenus.AddButtons( f2_arg0, f2_arg1, f2_arg2, f2_arg4 )
	elseif Engine.GetModeName() == "MP" then
		CoD.LobbyMenus.AddButtons( f2_arg0, f2_arg1, f2_arg2, f2_arg3 )
	elseif Engine.GetModeName() == "ZM" then
		CoD.LobbyMenus.AddButtons( f2_arg0, f2_arg1, f2_arg2, f2_arg5 )
	else
		print( "Error: no mode name set but AddButtonsMPCPZM called." )
	end
end

CoD.LobbyMenus.UpdateHistory = function ( f3_arg0, f3_arg1 )
	CoD.LobbyMenus.History[LobbyData.GetLobbyNav()] = f3_arg1
end

local f0_local0 = function ()
	return Dvar.ui_execdemo_cp:get()
end

local f0_local1 = function ()
	return Dvar.ui_execdemo_gamescom:get()
end

local f0_local2 = function ()
	return Dvar.ui_execdemo_beta:get()
end

local f0_local3 = function ( f7_arg0, f7_arg1 )
	if f7_arg1 == nil then
		return 
	elseif f7_arg1 == CoD.LobbyButtons.DISABLED then
		f7_arg0.disabled = true
	elseif f7_arg1 == CoD.LobbyButtons.HIDDEN then
		f7_arg0.hidden = true
	end
end

local f0_local4 = function ( f8_arg0, f8_arg1, f8_arg2, f8_arg3 )
	f8_arg2.disabled = false
	f8_arg2.hidden = false
	f8_arg2.selected = false
	f8_arg2.warning = false
	if f8_arg2.defaultState ~= nil then
		if f8_arg2.defaultState == CoD.LobbyButtons.DISABLED then
			f8_arg2.disabled = true
		elseif f8_arg2.defaultState == CoD.LobbyButtons.HIDDEN then
			f8_arg2.hidden = true
		end
	end
	if f8_arg2.disabledFunc ~= nil then
		f8_arg2.disabled = f8_arg2.disabledFunc( f8_arg0 )
	end
	if f8_arg2.visibleFunc ~= nil then
		f8_arg2.hidden = not f8_arg2.visibleFunc( f8_arg0 )
	end
	if f0_local2() then
		f0_local3( f8_arg2, f8_arg2.demo_beta )
	elseif f0_local1() then
		f0_local3( f8_arg2, f8_arg2.demo_gamescom )
	end
	if f8_arg2.hidden then
		return 
	end
	local f8_local0 = LobbyData.GetLobbyNav()
	if f8_arg2.selectedFunc ~= nil then
		f8_arg2.selected = f8_arg2.selectedFunc( f8_arg2.selectedParam )
	elseif CoD.LobbyMenus.History[f8_local0] ~= nil then
		f8_arg2.selected = CoD.LobbyMenus.History[f8_local0] == f8_arg2.customId
	end
	if f8_arg2.newBreadcrumbFunc then
		local f8_local1 = f8_arg2.newBreadcrumbFunc
		if type( f8_local1 ) == "string" then
			f8_local1 = LUI.getTableFromPath( f8_local1 )
		end
		if f8_local1 then
			f8_arg2.isBreadcrumbNew = f8_local1( f8_arg0 )
		end
	end
	if f8_arg2.warningFunc ~= nil then
		f8_arg2.warning = f8_arg2.warningFunc( f8_arg0 )
	end
	if f8_arg2.starterPack == CoD.LobbyButtons.STARTERPACK_UPGRADE then
		f8_arg2.starterPackUpgrade = true
		if IsStarterPack() then
			f8_arg2.disabled = false
		end
	end
	table.insert( f8_arg1, {
		optionDisplay = f8_arg2.stringRef,
		action = f8_arg2.action,
		param = f8_arg2.param,
		customId = f8_arg2.customId,
		isLargeButton = f8_arg3,
		isLastButtonInGroup = false,
		disabled = f8_arg2.disabled,
		selected = f8_arg2.selected,
		isBreadcrumbNew = f8_arg2.isBreadcrumbNew,
		warning = f8_arg2.warning,
		requiredChunk = f8_arg2.selectedParam,
		starterPackUpgrade = f8_arg2.starterPackUpgrade,
		unloadMod = f8_arg2.unloadMod
	} )
end

local f0_local5 = function ( f9_arg0, f9_arg1, f9_arg2 )
	f0_local4( f9_arg0, f9_arg1, f9_arg2, true )
end

local f0_local6 = function ( f10_arg0, f10_arg1, f10_arg2 )
	f0_local4( f10_arg0, f10_arg1, f10_arg2, false )
end

local f0_local7 = function ( f11_arg0 )
	if 0 < #f11_arg0 then
		f11_arg0[#f11_arg0].isLastButtonInGroup = true
	end
end

CoD.LobbyMenus.ModeSelect = function ( f12_arg0, f12_arg1, f12_arg2 )
	if Engine.GetLobbyNetworkMode() == Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE then
		if f12_arg2 == 1 then
			if LuaUtils.IsGamescomBuild() then
				f0_local7( f12_arg1 )
				f0_local6( f12_arg0, f12_arg1, CoD.LobbyButtons.PLAY_LOCAL )
				f0_local7( f12_arg1 )
			else
				Lobby_SetMaxLocalPlayers( 2 )
				f0_local5( f12_arg0, f12_arg1, CoD.LobbyButtons.CP_ONLINE )
				f0_local5( f12_arg0, f12_arg1, CoD.LobbyButtons.MP_ONLINE )
				f0_local5( f12_arg0, f12_arg1, CoD.LobbyButtons.ZM_ONLINE )
				f0_local5( f12_arg0, f12_arg1, CoD.LobbyButtons.BONUSMODES_ONLINE )
				f0_local7( f12_arg1 )
				f0_local6( f12_arg0, f12_arg1, CoD.LobbyButtons.PLAY_LOCAL )
				f0_local7( f12_arg1 )
			end
		end
		if CoD.isPC then
			f0_local6( f12_arg0, f12_arg1, CoD.LobbyButtons.STEAM_STORE )
		else
			f0_local6( f12_arg0, f12_arg1, CoD.LobbyButtons.STORE )
		end
	else
		if f12_arg2 == 1 then
			if LuaUtils.IsGamescomBuild() and not Dvar.ui_disable_lan:get() then
				f0_local5( f12_arg0, f12_arg1, CoD.LobbyButtons.MP_LAN )
				f0_local6( f12_arg0, f12_arg1, CoD.LobbyButtons.FIND_LAN_GAME )
				f0_local7( f12_arg1 )
			else
				Lobby_SetMaxLocalPlayers( 4 )
				f0_local5( f12_arg0, f12_arg1, CoD.LobbyButtons.CP_LAN )
				f0_local5( f12_arg0, f12_arg1, CoD.LobbyButtons.MP_LAN )
				f0_local5( f12_arg0, f12_arg1, CoD.LobbyButtons.ZM_LAN )
				f0_local5( f12_arg0, f12_arg1, CoD.LobbyButtons.BONUSMODES_LAN )
				f0_local7( f12_arg1 )
				if not Dvar.ui_disable_lan:get() then
					f0_local6( f12_arg0, f12_arg1, CoD.LobbyButtons.FIND_LAN_GAME )
					f0_local7( f12_arg1 )
				end
				f0_local6( f12_arg0, f12_arg1, CoD.LobbyButtons.PLAY_ONLINE )
				f0_local7( f12_arg1 )
			end
		end
		if CoD.isPC then
			f0_local6( f12_arg0, f12_arg1, CoD.LobbyButtons.STEAM_STORE )
		end
	end
	if CoD.isPC then
		if Mods_Enabled() and f12_arg2 == 1 then
			f0_local5( f12_arg0, f12_arg1, CoD.LobbyButtons.MODS_LOAD )
		end
		f0_local6( f12_arg0, f12_arg1, CoD.LobbyButtons.QUIT )
	end
end

CoD.LobbyMenus.DOAButtonsOnline = function ( f13_arg0, f13_arg1, f13_arg2 )
	if f13_arg2 == 1 then
		f0_local5( f13_arg0, f13_arg1, CoD.LobbyButtons.CP_DOA_START_GAME )
		f0_local5( f13_arg0, f13_arg1, CoD.LobbyButtons.CP_DOA_JOIN_PUBLIC_GAME )
		f0_local5( f13_arg0, f13_arg1, CoD.LobbyButtons.CP_DOA_CREATE_PUBLIC_GAME )
		f0_local7( f13_arg1 )
		f0_local5( f13_arg0, f13_arg1, CoD.LobbyButtons.CP_DOA_LEADERBOARD )
	else
		f0_local5( f13_arg0, f13_arg1, CoD.LobbyButtons.CP_DOA_LEADERBOARD )
	end
end

CoD.LobbyMenus.DOAButtonsPublicGame = function ( f14_arg0, f14_arg1, f14_arg2 )
	f0_local5( f14_arg0, f14_arg1, CoD.LobbyButtons.ZM_READY_UP )
	f0_local5( f14_arg0, f14_arg1, CoD.LobbyButtons.CP_DOA_LEADERBOARD )
end

CoD.LobbyMenus.DOAButtonsLAN = function ( f15_arg0, f15_arg1, f15_arg2 )
	if f15_arg2 == 1 then
		f0_local5( f15_arg0, f15_arg1, CoD.LobbyButtons.CP_DOA_START_GAME )
	end
end

CoD.LobbyMenus.CPZMButtonsOnline = function ( f16_arg0, f16_arg1, f16_arg2 )
	if IsStarterPack() then
		f0_local6( f16_arg0, f16_arg1, CoD.LobbyButtons.QUIT )
		return 
	elseif f16_arg2 == 1 then
		if Engine.IsCPInProgress() then
			f0_local5( f16_arg0, f16_arg1, CoD.LobbyButtons.CP_RESUME_GAME )
		else
			f0_local5( f16_arg0, f16_arg1, CoD.LobbyButtons.CP_START_GAME )
		end
		f0_local5( f16_arg0, f16_arg1, CoD.LobbyButtons.CP_JOIN_PUBLIC_GAME )
		f0_local5( f16_arg0, f16_arg1, CoD.LobbyButtons.CP_SELECT_MISSION )
		f0_local5( f16_arg0, f16_arg1, CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY )
	else
		f0_local5( f16_arg0, f16_arg1, CoD.LobbyButtons.CP_MISSION_OVERVIEW )
	end
end

CoD.LobbyMenus.CPZMButtonsPublicGame = function ( f17_arg0, f17_arg1, f17_arg2 )
	f0_local6( f17_arg0, f17_arg1, CoD.LobbyButtons.CP_MISSION_OVERVIEW )
end

CoD.LobbyMenus.CPZMButtonsLAN = function ( f18_arg0, f18_arg1, f18_arg2 )
	if IsStarterPack() then
		f0_local6( f18_arg0, f18_arg1, CoD.LobbyButtons.QUIT )
		return 
	elseif f18_arg2 == 1 then
		if Engine.IsCPInProgress() then
			f0_local5( f18_arg0, f18_arg1, CoD.LobbyButtons.CP_RESUME_GAME )
		else
			f0_local5( f18_arg0, f18_arg1, CoD.LobbyButtons.CP_START_GAME )
		end
		f0_local5( f18_arg0, f18_arg1, CoD.LobbyButtons.CP_SELECT_MISSION )
		f0_local5( f18_arg0, f18_arg1, CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY )
	end
end

CoD.LobbyMenus.CP2ButtonsLANCUSTOM = function ( f19_arg0, f19_arg1, f19_arg2 )
	if IsStarterPack() then
		f0_local6( f19_arg0, f19_arg1, CoD.LobbyButtons.QUIT )
		return 
	elseif f19_arg2 == 1 then
		f0_local6( f19_arg0, f19_arg1, CoD.LobbyButtons.CP_CUSTOM_START_GAME )
		f0_local7( f19_arg1 )
		f0_local6( f19_arg0, f19_arg1, CoD.LobbyButtons.CP_MISSION_OVERVIEW )
		f0_local5( f19_arg0, f19_arg1, CoD.LobbyButtons.CP_SELECT_MISSION )
		f0_local5( f19_arg0, f19_arg1, CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY )
	else
		f0_local6( f19_arg0, f19_arg1, CoD.LobbyButtons.CP_MISSION_OVERVIEW )
	end
end

CoD.LobbyMenus.CPButtonsOnline = function ( f20_arg0, f20_arg1, f20_arg2 )
	if IsStarterPack() then
		f0_local6( f20_arg0, f20_arg1, CoD.LobbyButtons.QUIT )
		return 
	elseif f20_arg2 == 1 then
		if Engine.IsCPInProgress() then
			f0_local5( f20_arg0, f20_arg1, CoD.LobbyButtons.CP_RESUME_GAME )
		else
			f0_local5( f20_arg0, f20_arg1, CoD.LobbyButtons.CP_START_GAME )
		end
		f0_local7( f20_arg1 )
		f0_local5( f20_arg0, f20_arg1, CoD.LobbyButtons.CP_JOIN_PUBLIC_GAME )
		if HighestMapReachedGreaterThan( f20_arg0, 1 ) then
			f0_local5( f20_arg0, f20_arg1, CoD.LobbyButtons.CP_GOTO_SAFEHOUSE )
		end
		f0_local5( f20_arg0, f20_arg1, CoD.LobbyButtons.CP_SELECT_MISSION )
		f0_local5( f20_arg0, f20_arg1, CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY )
	else
		f0_local5( f20_arg0, f20_arg1, CoD.LobbyButtons.CP_MISSION_OVERVIEW )
	end
end

CoD.LobbyMenus.CPButtonsPublicGame = function ( f21_arg0, f21_arg1, f21_arg2 )
	f0_local6( f21_arg0, f21_arg1, CoD.LobbyButtons.CP_MISSION_OVERVIEW )
end

CoD.LobbyMenus.CPButtonsCustomGame = function ( f22_arg0, f22_arg1, f22_arg2 )
	if IsStarterPack() then
		f0_local6( f22_arg0, f22_arg1, CoD.LobbyButtons.QUIT )
		return 
	elseif f22_arg2 == 1 then
		f0_local6( f22_arg0, f22_arg1, CoD.LobbyButtons.CP_CUSTOM_START_GAME )
		f0_local7( f22_arg1 )
		f0_local6( f22_arg0, f22_arg1, CoD.LobbyButtons.CP_MISSION_OVERVIEW )
		f0_local5( f22_arg0, f22_arg1, CoD.LobbyButtons.CP_SELECT_MISSION )
		f0_local5( f22_arg0, f22_arg1, CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY )
	else
		f0_local6( f22_arg0, f22_arg1, CoD.LobbyButtons.CP_MISSION_OVERVIEW )
	end
end

CoD.LobbyMenus.CPButtonsLAN = function ( f23_arg0, f23_arg1, f23_arg2 )
	if IsStarterPack() then
		f0_local6( f23_arg0, f23_arg1, CoD.LobbyButtons.QUIT )
		return 
	elseif f23_arg2 == 1 then
		if Engine.IsCPInProgress() then
			f0_local5( f23_arg0, f23_arg1, CoD.LobbyButtons.CP_RESUME_GAME_LAN )
		else
			f0_local5( f23_arg0, f23_arg1, CoD.LobbyButtons.CP_LAN_START_GAME )
		end
		f0_local7( f23_arg1 )
		if HighestMapReachedGreaterThan( f23_arg0, 1 ) then
			f0_local5( f23_arg0, f23_arg1, CoD.LobbyButtons.CP_GOTO_SAFEHOUSE )
		end
		f0_local5( f23_arg0, f23_arg1, CoD.LobbyButtons.CP_SELECT_MISSION )
		f0_local5( f23_arg0, f23_arg1, CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY )
	else
		f0_local6( f23_arg0, f23_arg1, CoD.LobbyButtons.CP_MISSION_OVERVIEW )
	end
end

CoD.LobbyMenus.CPButtonsLANCUSTOM = function ( f24_arg0, f24_arg1, f24_arg2 )
	if IsStarterPack() then
		f0_local6( f24_arg0, f24_arg1, CoD.LobbyButtons.QUIT )
		return 
	elseif f24_arg2 == 1 then
		f0_local6( f24_arg0, f24_arg1, CoD.LobbyButtons.CP_CUSTOM_START_GAME )
		f0_local7( f24_arg1 )
		f0_local6( f24_arg0, f24_arg1, CoD.LobbyButtons.CP_MISSION_OVERVIEW )
		f0_local5( f24_arg0, f24_arg1, CoD.LobbyButtons.CP_SELECT_MISSION )
		f0_local5( f24_arg0, f24_arg1, CoD.LobbyButtons.CP_CHOOSE_DIFFICULTY )
	else
		f0_local6( f24_arg0, f24_arg1, CoD.LobbyButtons.CP_MISSION_OVERVIEW )
	end
end

CoD.LobbyMenus.MPButtonsMain = function ( f25_arg0, f25_arg1, f25_arg2 )
	if f25_arg2 == 1 then
		f0_local5( f25_arg0, f25_arg1, CoD.LobbyButtons.MP_PUBLIC_MATCH )
		f0_local5( f25_arg0, f25_arg1, CoD.LobbyButtons.MP_ARENA )
		f0_local5( f25_arg0, f25_arg1, CoD.LobbyButtons.MP_CUSTOM_GAMES )
		f0_local5( f25_arg0, f25_arg1, CoD.LobbyButtons.THEATER_MP )
	end
	f0_local7( f25_arg1 )
	if CoD.isPC then
		f0_local5( f25_arg0, f25_arg1, CoD.LobbyButtons.STEAM_STORE )
	else
		f0_local5( f25_arg0, f25_arg1, CoD.LobbyButtons.STORE )
	end
end

CoD.LobbyMenus.MPButtonsOnline = function ( f26_arg0, f26_arg1, f26_arg2 )
	if f26_arg2 == 1 then
		f0_local5( f26_arg0, f26_arg1, CoD.LobbyButtons.MP_FIND_MATCH )
		f0_local7( f26_arg1 )
	end
	f0_local5( f26_arg0, f26_arg1, CoD.LobbyButtons.MP_CAC_NO_WARNING )
	f0_local5( f26_arg0, f26_arg1, CoD.LobbyButtons.MP_SPECIALISTS_NO_WARNING )
	f0_local5( f26_arg0, f26_arg1, CoD.LobbyButtons.MP_SCORESTREAKS )
	if (Dvar.ui_execdemo_beta:get() or IsStarterPack()) and IsStoreAvailable() then
		if CoD.isPC then
			f0_local5( f26_arg0, f26_arg1, CoD.LobbyButtons.STEAM_STORE )
		else
			f0_local5( f26_arg0, f26_arg1, CoD.LobbyButtons.STORE )
		end
	end
	if Engine.DvarBool( nil, "inventory_test_button_visible" ) then
		f0_local5( f26_arg0, f26_arg1, CoD.LobbyButtons.MP_INVENTORY_TEST )
	end
	f0_local7( f26_arg1 )
	if not DisableBlackMarket() then
		f0_local6( f26_arg0, f26_arg1, CoD.LobbyButtons.BLACK_MARKET )
	end
end

CoD.LobbyMenus.MPButtonsOnlinePublic = function ( f27_arg0, f27_arg1, f27_arg2 )
	f0_local5( f27_arg0, f27_arg1, CoD.LobbyButtons.MP_CAC )
	f0_local5( f27_arg0, f27_arg1, CoD.LobbyButtons.MP_SPECIALISTS )
	f0_local5( f27_arg0, f27_arg1, CoD.LobbyButtons.MP_SCORESTREAKS )
	if Engine.DvarBool( nil, "inventory_test_button_visible" ) then
		f0_local5( f27_arg0, f27_arg1, CoD.LobbyButtons.MP_INVENTORY_TEST )
	end
	local f27_local0 = Engine.GetPlaylistInfoByID( Engine.GetPlaylistID() )
	if f27_local0 then
		local f27_local1 = f27_local0.playlist.category
		if f27_local1 == Engine.GetPlaylistCategoryIdByName( "core" ) or f27_local1 == Engine.GetPlaylistCategoryIdByName( "hardcore" ) then
			f0_local7( f27_arg1 )
			f0_local6( f27_arg0, f27_arg1, CoD.LobbyButtons.MP_PUBLIC_LOBBY_LEADERBOARD )
		end
	end
	if not DisableBlackMarket() then
		f0_local7( f27_arg1 )
		f0_local6( f27_arg0, f27_arg1, CoD.LobbyButtons.BLACK_MARKET )
	end
end

CoD.LobbyMenus.MPButtonsModGame = function ( f28_arg0, f28_arg1, f28_arg2 )
	if Engine.IsStarterPack() then
		f0_local6( f28_arg0, f28_arg1, CoD.LobbyButtons.QUIT )
		return 
	else
		f0_local5( f28_arg0, f28_arg1, CoD.LobbyButtons.MP_CAC )
		f0_local5( f28_arg0, f28_arg1, CoD.LobbyButtons.MP_SPECIALISTS )
		f0_local5( f28_arg0, f28_arg1, CoD.LobbyButtons.MP_SCORESTREAKS )
	end
end

CoD.LobbyMenus.MPButtonsCustomGame = function ( f29_arg0, f29_arg1, f29_arg2 )
	if IsStarterPack() then
		f0_local6( f29_arg0, f29_arg1, CoD.LobbyButtons.QUIT )
		return 
	elseif f29_arg2 == 1 then
		f0_local6( f29_arg0, f29_arg1, CoD.LobbyButtons.MP_CUSTOM_START_GAME )
		f0_local6( f29_arg0, f29_arg1, CoD.LobbyButtons.MP_CUSTOM_SETUP_GAME )
		f0_local7( f29_arg1 )
	end
	f0_local5( f29_arg0, f29_arg1, CoD.LobbyButtons.MP_CAC )
	f0_local5( f29_arg0, f29_arg1, CoD.LobbyButtons.MP_SPECIALISTS )
	f0_local5( f29_arg0, f29_arg1, CoD.LobbyButtons.MP_SCORESTREAKS )
	f0_local7( f29_arg1 )
	f0_local5( f29_arg0, f29_arg1, CoD.LobbyButtons.MP_CODCASTER_SETTINGS )
	if Engine.DvarBool( nil, "inventory_test_button_visible" ) then
		f0_local5( f29_arg0, f29_arg1, CoD.LobbyButtons.MP_INVENTORY_TEST )
	end
	f0_local7( f29_arg1 )
	f0_local6( f29_arg0, f29_arg1, CoD.LobbyButtons.MP_CUSTOM_LOBBY_LEADERBOARD )
end

CoD.LobbyMenus.MPButtonsArena = function ( f30_arg0, f30_arg1, f30_arg2 )
	if f30_arg2 == 1 then
		f0_local5( f30_arg0, f30_arg1, CoD.LobbyButtons.MP_ARENA_FIND_MATCH )
		f0_local5( f30_arg0, f30_arg1, CoD.LobbyButtons.MP_ARENA_SELECT_ARENA )
		f0_local7( f30_arg1 )
	end
	f0_local5( f30_arg0, f30_arg1, CoD.LobbyButtons.MP_CAC )
	f0_local5( f30_arg0, f30_arg1, CoD.LobbyButtons.MP_SPECIALISTS )
	f0_local5( f30_arg0, f30_arg1, CoD.LobbyButtons.MP_SCORESTREAKS )
	if not DisableBlackMarket() then
		f0_local7( f30_arg1 )
		f0_local6( f30_arg0, f30_arg1, CoD.LobbyButtons.BLACK_MARKET )
	end
end

CoD.LobbyMenus.MPButtonsArenaGame = function ( f31_arg0, f31_arg1, f31_arg2 )
	f0_local5( f31_arg0, f31_arg1, CoD.LobbyButtons.MP_CAC )
	f0_local5( f31_arg0, f31_arg1, CoD.LobbyButtons.MP_SPECIALISTS )
	f0_local5( f31_arg0, f31_arg1, CoD.LobbyButtons.MP_SCORESTREAKS )
	if not DisableBlackMarket() then
		f0_local7( f31_arg1 )
		f0_local6( f31_arg0, f31_arg1, CoD.LobbyButtons.BLACK_MARKET )
	end
end

CoD.LobbyMenus.MPButtonsLAN = function ( f32_arg0, f32_arg1, f32_arg2 )
	if IsStarterPack() then
		f0_local6( f32_arg0, f32_arg1, CoD.LobbyButtons.QUIT )
		return 
	elseif f32_arg2 == 1 then
		f0_local6( f32_arg0, f32_arg1, CoD.LobbyButtons.MP_CUSTOM_START_GAME )
		f0_local6( f32_arg0, f32_arg1, CoD.LobbyButtons.MP_CUSTOM_SETUP_GAME )
		f0_local7( f32_arg1 )
	end
	f0_local5( f32_arg0, f32_arg1, CoD.LobbyButtons.MP_CAC )
	f0_local5( f32_arg0, f32_arg1, CoD.LobbyButtons.MP_SPECIALISTS )
	f0_local5( f32_arg0, f32_arg1, CoD.LobbyButtons.MP_SCORESTREAKS )
	f0_local7( f32_arg1 )
	f0_local5( f32_arg0, f32_arg1, CoD.LobbyButtons.MP_CODCASTER_SETTINGS )
	if Engine.DvarBool( nil, "inventory_test_button_visible" ) then
		f0_local5( f32_arg0, f32_arg1, CoD.LobbyButtons.MP_INVENTORY_TEST )
	end
end

CoD.LobbyMenus.ZMButtonsOnline = function ( f33_arg0, f33_arg1, f33_arg2 )
	if IsStarterPack() then
		f0_local6( f33_arg0, f33_arg1, CoD.LobbyButtons.QUIT )
		return 
	elseif f33_arg2 == 1 then
		f0_local5( f33_arg0, f33_arg1, CoD.LobbyButtons.ZM_SOLO_GAME )
		f0_local5( f33_arg0, f33_arg1, CoD.LobbyButtons.ZM_FIND_MATCH )
		f0_local5( f33_arg0, f33_arg1, CoD.LobbyButtons.ZM_CUSTOM_GAMES )
		f0_local5( f33_arg0, f33_arg1, CoD.LobbyButtons.THEATER_ZM )
		f0_local7( f33_arg1 )
	end
	f0_local5( f33_arg0, f33_arg1, CoD.LobbyButtons.ZM_BUBBLEGUM_BUFFS )
	f0_local5( f33_arg0, f33_arg1, CoD.LobbyButtons.ZM_MEGACHEW_FACTORY )
	f0_local5( f33_arg0, f33_arg1, CoD.LobbyButtons.ZM_GOBBLEGUM_RECIPES )
	f0_local5( f33_arg0, f33_arg1, CoD.LobbyButtons.ZM_BUILD_KITS )
    f0_local5( f33_arg0, f33_arg1, CoD.LobbyButtons.ZM_RESET_BUILDKITS )
end

CoD.LobbyMenus.ZMButtonsPublicGame = function ( f34_arg0, f34_arg1 )
	if IsStarterPack() then
		f0_local6( f34_arg0, f34_arg1, CoD.LobbyButtons.QUIT )
		return 
	else
		f0_local5( f34_arg0, f34_arg1, CoD.LobbyButtons.ZM_READY_UP )
		f0_local5( f34_arg0, f34_arg1, CoD.LobbyButtons.ZM_BUBBLEGUM_BUFFS )
		f0_local5( f34_arg0, f34_arg1, CoD.LobbyButtons.ZM_BUILD_KITS )
        f0_local5( f33_arg0, f33_arg1, CoD.LobbyButtons.ZM_RESET_BUILDKITS )
	end
end

CoD.LobbyMenus.ZMButtonsCustomGame = function ( f35_arg0, f35_arg1, f35_arg2 )
	if IsStarterPack() then
		f0_local6( f35_arg0, f35_arg1, CoD.LobbyButtons.QUIT )
		return 
	elseif f35_arg2 == 1 then
		f0_local5( f35_arg0, f35_arg1, CoD.LobbyButtons.ZM_START_CUSTOM_GAME )
		f0_local5( f35_arg0, f35_arg1, CoD.LobbyButtons.ZM_CUSTOM_SETUP_GAME )
		-- f0_local5( f35_arg0, f35_arg1, CoD.LobbyButtons.ZM_CHANGE_MAP )
		-- f0_local7( f35_arg1 )
		-- f0_local5( f35_arg0, f35_arg1, CoD.LobbyButtons.ZM_CHANGE_RANKED_SETTTINGS )
		-- if CoD.isPC and IsServerBrowserEnabled() then
		-- 	f0_local5( f35_arg0, f35_arg1, CoD.LobbyButtons.ZM_SERVER_SETTINGS )
		-- end
		f0_local7( f35_arg1 )
		if CoD.zbr_loaded == true and DiscordSDKLib.IsDiscordRPCActive() then
			f0_local5( f35_arg0, f35_arg1, CoD.LobbyButtons.THEATER_ZM )
			f0_local7( f35_arg1 )
		end
	end
	f0_local5( f35_arg0, f35_arg1, CoD.LobbyButtons.ZM_BUBBLEGUM_BUFFS )
	f0_local5( f35_arg0, f35_arg1, CoD.LobbyButtons.ZM_BUILD_KITS )
    f0_local5( f35_arg0, f35_arg1, CoD.LobbyButtons.ZM_RESET_BUILDKITS )
end

CoD.LobbyMenus.ZMButtonsLAN = function ( f36_arg0, f36_arg1, f36_arg2 )
	if IsStarterPack() then
		f0_local6( f36_arg0, f36_arg1, CoD.LobbyButtons.QUIT )
		return 
	elseif f36_arg2 == 1 then
		f0_local5( f36_arg0, f36_arg1, CoD.LobbyButtons.ZM_START_LAN_GAME )
		f0_local5( f36_arg0, f36_arg1, CoD.LobbyButtons.ZM_CHANGE_MAP )
		f0_local7( f36_arg1 )
	end
	f0_local5( f36_arg0, f36_arg1, CoD.LobbyButtons.ZM_BUBBLEGUM_BUFFS )
	f0_local5( f36_arg0, f36_arg1, CoD.LobbyButtons.ZM_BUILD_KITS )
end

CoD.LobbyMenus.FRButtonsOnlineGame = function ( f37_arg0, f37_arg1, f37_arg2 )
	f0_local5( f37_arg0, f37_arg1, CoD.LobbyButtons.FR_START_RUN_ONLINE )
	f0_local5( f37_arg0, f37_arg1, CoD.LobbyButtons.FR_CHANGE_MAP )
	f0_local7( f37_arg1 )
	f0_local5( f37_arg0, f37_arg1, CoD.LobbyButtons.FR_LEADERBOARD )
end

CoD.LobbyMenus.FRButtonsLANGame = function ( f38_arg0, f38_arg1, f38_arg2 )
	f0_local5( f38_arg0, f38_arg1, CoD.LobbyButtons.FR_START_RUN_LAN )
	f0_local5( f38_arg0, f38_arg1, CoD.LobbyButtons.FR_CHANGE_MAP )
end

CoD.LobbyMenus.ButtonsTheaterGame = function ( f39_arg0, f39_arg1, f39_arg2 )
	if f39_arg2 == 1 then
		f0_local6( f39_arg0, f39_arg1, CoD.LobbyButtons.TH_START_FILM )
		f0_local6( f39_arg0, f39_arg1, CoD.LobbyButtons.TH_SELECT_FILM )
		f0_local6( f39_arg0, f39_arg1, CoD.LobbyButtons.TH_CREATE_HIGHLIGHT )
	end
end

local f0_local8 = {
	[LobbyData.UITargets.UI_MAIN.id] = CoD.LobbyMenus.ModeSelect,
	[LobbyData.UITargets.UI_MODESELECT.id] = CoD.LobbyMenus.ModeSelect,
	[LobbyData.UITargets.UI_CPLOBBYLANGAME.id] = CoD.LobbyMenus.CPButtonsLAN,
	[LobbyData.UITargets.UI_CPLOBBYLANCUSTOMGAME.id] = CoD.LobbyMenus.CPButtonsLANCUSTOM,
	[LobbyData.UITargets.UI_CPLOBBYONLINE.id] = CoD.LobbyMenus.CPButtonsOnline,
	[LobbyData.UITargets.UI_CPLOBBYONLINEPUBLICGAME.id] = CoD.LobbyMenus.CPButtonsPublicGame,
	[LobbyData.UITargets.UI_CPLOBBYONLINECUSTOMGAME.id] = CoD.LobbyMenus.CPButtonsCustomGame,
	[LobbyData.UITargets.UI_CP2LOBBYLANGAME.id] = CoD.LobbyMenus.CPZMButtonsLAN,
	[LobbyData.UITargets.UI_CP2LOBBYLANCUSTOMGAME.id] = CoD.LobbyMenus.CPButtonsLANCUSTOM,
	[LobbyData.UITargets.UI_CP2LOBBYONLINE.id] = CoD.LobbyMenus.CPZMButtonsOnline,
	[LobbyData.UITargets.UI_CP2LOBBYONLINEPUBLICGAME.id] = CoD.LobbyMenus.CPZMButtonsPublicGame,
	[LobbyData.UITargets.UI_CP2LOBBYONLINECUSTOMGAME.id] = CoD.LobbyMenus.CPButtonsCustomGame,
	[LobbyData.UITargets.UI_DOALOBBYLANGAME.id] = CoD.LobbyMenus.DOAButtonsLAN,
	[LobbyData.UITargets.UI_DOALOBBYONLINE.id] = CoD.LobbyMenus.DOAButtonsOnline,
	[LobbyData.UITargets.UI_DOALOBBYONLINEPUBLICGAME.id] = CoD.LobbyMenus.DOAButtonsPublicGame,
	[LobbyData.UITargets.UI_MPLOBBYLANGAME.id] = CoD.LobbyMenus.MPButtonsLAN,
	[LobbyData.UITargets.UI_MPLOBBYMAIN.id] = CoD.LobbyMenus.MPButtonsMain,
	[LobbyData.UITargets.UI_MPLOBBYONLINE.id] = CoD.LobbyMenus.MPButtonsOnline,
	[LobbyData.UITargets.UI_MPLOBBYONLINEPUBLICGAME.id] = CoD.LobbyMenus.MPButtonsOnlinePublic,
	[LobbyData.UITargets.UI_MPLOBBYONLINEMODGAME.id] = CoD.LobbyMenus.MPButtonsModGame,
	[LobbyData.UITargets.UI_MPLOBBYONLINECUSTOMGAME.id] = CoD.LobbyMenus.MPButtonsCustomGame,
	[LobbyData.UITargets.UI_MPLOBBYONLINEARENA.id] = CoD.LobbyMenus.MPButtonsArena,
	[LobbyData.UITargets.UI_MPLOBBYONLINEARENAGAME.id] = CoD.LobbyMenus.MPButtonsArenaGame,
	[LobbyData.UITargets.UI_FRLOBBYONLINEGAME.id] = CoD.LobbyMenus.FRButtonsOnlineGame,
	[LobbyData.UITargets.UI_FRLOBBYLANGAME.id] = CoD.LobbyMenus.FRButtonsLANGame,
	[LobbyData.UITargets.UI_ZMLOBBYLANGAME.id] = CoD.LobbyMenus.ZMButtonsLAN,
	[LobbyData.UITargets.UI_ZMLOBBYONLINE.id] = CoD.LobbyMenus.ZMButtonsOnline,
	[LobbyData.UITargets.UI_ZMLOBBYONLINEPUBLICGAME.id] = CoD.LobbyMenus.ZMButtonsPublicGame,
	[LobbyData.UITargets.UI_ZMLOBBYONLINECUSTOMGAME.id] = CoD.LobbyMenus.ZMButtonsCustomGame,
	[LobbyData.UITargets.UI_MPLOBBYONLINETHEATER.id] = CoD.LobbyMenus.ButtonsTheaterGame,
	[LobbyData.UITargets.UI_ZMLOBBYONLINETHEATER.id] = CoD.LobbyMenus.ButtonsTheaterGame
}
CoD.LobbyMenus.AddButtonsForTarget = function ( f40_arg0, f40_arg1 )
	local f40_local0 = f0_local8[f40_arg1]
	local f40_local1 = nil
	if Engine.IsLobbyActive( Enum.LobbyType.LOBBY_TYPE_GAME ) then
		f40_local1 = Engine.GetModel( DataSources.LobbyRoot.getModel( f40_arg0 ), "gameClient.isHost" )
	else
		f40_local1 = Engine.GetModel( DataSources.LobbyRoot.getModel( f40_arg0 ), "privateClient.isHost" )
	end
	local f40_local2 = nil
	if f40_local1 ~= nil then
		f40_local2 = Engine.GetModelValue( f40_local1 )
	else
		f40_local2 = 1
	end
	local f40_local3 = {}
	f40_local0( f40_arg0, f40_local3, f40_local2 )
	return f40_local3
end

