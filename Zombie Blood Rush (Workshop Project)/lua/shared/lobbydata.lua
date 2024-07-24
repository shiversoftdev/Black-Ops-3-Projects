require( "lua.Shared.LuaEnums" )
require( "lua.Shared.LuaUtils" )

local f0_local0 = {}
local f0_local1 = {
	UI_MAIN = {
		id = 0,
		name = "Main",
		title = "",
		kicker = "",
		room = "room1",
		isPrivate = false,
		isGame = false,
		isAdvertised = false,
		maxClients = 0,
		maxLocalClients = 0,
		maxLocalClientsNetwork = 0,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_INVALID,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_INVALID,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_INVALID,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_INVALID,
		eGameModes = Enum.eGameModes.MODE_GAME_INVALID,
		lobbyTimerType = LuaEnums.TIMER_TYPE.INVALID,
		menuMusic = "titlescreen",
		joinPartyPrivacyCheck = false
	},
	UI_MODESELECT = {
		id = 1,
		name = "ModeSelect",
		title = "",
		kicker = "",
		room = "auto",
		isPrivate = true,
		isGame = false,
		isAdvertised = false,
		maxClients = 18,
		maxLocalClients = 8,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_INVALID,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_INVALID,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_PRIVATE,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_INVALID,
		eGameModes = Enum.eGameModes.MODE_GAME_INVALID,
		lobbyTimerType = LuaEnums.TIMER_TYPE.INVALID,
		menuMusic = "titlescreen",
		joinPartyPrivacyCheck = true
	},
	UI_CPLOBBYONLINE = {
		id = 100,
		name = "CPLobbyOnline",
		title = "MENU_CAMPAIGN_CAPS",
		kicker = "MENU_CAMPAIGN",
		room = "cp",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_CP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_MANUAL,
		lobbyTimerType = LuaEnums.TIMER_TYPE.NONE,
		menuMusic = "cp_frontend",
		joinPartyPrivacyCheck = true
	},
	UI_CPLOBBYONLINEPUBLICGAME = {
		id = 101,
		name = "CPLobbyOnlinePublicGame",
		title = "MENU_CAMPAIGN_CAPS",
		kicker = "MPUI_PUBLIC_MATCH_LOBBY",
		room = "cp",
		isPrivate = true,
		isGame = true,
		isAdvertised = true,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_CP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_PUBLIC,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_PLAYLIST,
		lobbyTimerType = LuaEnums.TIMER_TYPE.AUTO_CP,
		menuMusic = "cp_frontend",
		joinPartyPrivacyCheck = false
	},
	UI_CPLOBBYONLINECUSTOMGAME = {
		id = 102,
		name = "CPLobbyOnlineCustomGame",
		title = "MENU_REPLAY_MISSION_CAPS",
		kicker = "MENU_FILESHARE_CUSTOMGAMES",
		room = "cp",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_CP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_MANUAL,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL_CP,
		menuMusic = "cp_frontend",
		joinPartyPrivacyCheck = true
	},
	UI_CPLOBBYLANGAME = {
		id = 110,
		name = "CPLobbyLANGame",
		title = "MENU_CAMPAIGN_CAPS",
		kicker = "",
		room = "cp",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_CP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LAN,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_INVALID,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL_CP,
		menuMusic = "cp_frontend",
		joinPartyPrivacyCheck = false
	},
	UI_CPLOBBYLANCUSTOMGAME = {
		id = 111,
		name = "CPLobbyLANCustomGame",
		title = "MENU_REPLAY_MISSION_CAPS",
		kicker = "",
		room = "cp",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_CP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LAN,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_INVALID,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL_CP,
		menuMusic = "cp_frontend",
		joinPartyPrivacyCheck = false
	},
	UI_CP2LOBBYONLINE = {
		id = 200,
		name = "CP2LobbyOnline",
		title = "MENU_SINGLEPLAYER_NIGHTMARES_CAPS",
		kicker = "",
		room = "cpzm",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_CP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_MANUAL,
		lobbyTimerType = LuaEnums.TIMER_TYPE.NONE,
		menuMusic = "zm_cp_frontend",
		joinPartyPrivacyCheck = true
	},
	UI_CP2LOBBYONLINEPUBLICGAME = {
		id = 201,
		name = "CP2LobbyOnlinePublicGame",
		title = "MENU_SINGLEPLAYER_NIGHTMARES_CAPS",
		kicker = "MPUI_PUBLIC_MATCH_LOBBY",
		room = "cpzm",
		isPrivate = true,
		isGame = true,
		isAdvertised = true,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_CP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_PUBLIC,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_PLAYLIST,
		lobbyTimerType = LuaEnums.TIMER_TYPE.AUTO_CP,
		menuMusic = "zm_cp_frontend",
		joinPartyPrivacyCheck = false
	},
	UI_CP2LOBBYONLINECUSTOMGAME = {
		id = 202,
		name = "CP2LobbyOnlineCustomGame",
		title = "MENU_CUSTOMGAMES_CAPS",
		kicker = "MENU_FILESHARE_CUSTOMGAMES",
		room = "cpzm",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_CP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_MANUAL,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL_CP,
		menuMusic = "zm_cp_frontend",
		joinPartyPrivacyCheck = true
	},
	UI_CP2LOBBYLANGAME = {
		id = 210,
		name = "CP2LobbyLANGame",
		title = "MENU_SINGLEPLAYER_NIGHTMARES_CAPS",
		kicker = "",
		room = "cpzm",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_CP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LAN,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_INVALID,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL_CP,
		menuMusic = "zm_cp_frontend",
		joinPartyPrivacyCheck = false
	},
	UI_CP2LOBBYLANCUSTOMGAME = {
		id = 211,
		name = "CP2LobbyLANCustomGame",
		title = "MENU_REPLAY_MISSION_CAPS",
		kicker = "",
		room = "cpzm",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_CP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LAN,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_INVALID,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL_CP,
		menuMusic = "zm_cp_frontend",
		joinPartyPrivacyCheck = false
	},
	UI_MPLOBBYMAIN = {
		id = 300,
		name = "MPLobbyMain",
		title = "MENU_MULTIPLAYER_CAPS",
		kicker = "MENU_MULTIPLAYER",
		room = "mp_online",
		isPrivate = true,
		isGame = false,
		isAdvertised = false,
		maxClients = 18,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_MP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_PRIVATE,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_INVALID,
		eGameModes = Enum.eGameModes.MODE_GAME_INVALID,
		lobbyTimerType = LuaEnums.TIMER_TYPE.INVALID,
		menuMusic = "mp_frontend",
		joinPartyPrivacyCheck = true
	},
	UI_MPLOBBYONLINE = {
		id = 301,
		name = "MPLobbyOnline",
		title = "MENU_MATCHMAKING_CAPS",
		kicker = "MPUI_PUBLIC_MATCH_LOBBY",
		room = "mp_online",
		isPrivate = true,
		isGame = false,
		isAdvertised = false,
		maxClients = 18,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_MP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_PRIVATE,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_PUBLIC,
		eGameModes = Enum.eGameModes.MODE_GAME_INVALID,
		lobbyTimerType = LuaEnums.TIMER_TYPE.INVALID,
		menuMusic = "mp_frontend",
		joinPartyPrivacyCheck = true
	},
	UI_MPLOBBYONLINEPUBLICGAME = {
		id = 310,
		name = "MPLobbyOnlinePublicGame",
		title = "MENU_MULTIPLAYER_CAPS",
		kicker = "MPUI_PUBLIC_MATCH_LOBBY",
		room = "mp_online",
		isPrivate = true,
		isGame = true,
		isAdvertised = true,
		maxClients = 18,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_MP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_PUBLIC,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_PLAYLIST,
		lobbyTimerType = LuaEnums.TIMER_TYPE.AUTO_MP,
		menuMusic = "mp_frontend",
		joinPartyPrivacyCheck = false
	},
	UI_MPLOBBYONLINEMODGAME = {
		id = 320,
		name = "MPLobbyOnlineModGame",
		title = "MENU_CUSTOMGAMES_CAPS",
		kicker = "",
		room = "mp_custom",
		isPrivate = true,
		isGame = true,
		isAdvertised = true,
		maxClients = 18,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_MP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_MANUAL_PLAYLIST,
		lobbyTimerType = LuaEnums.TIMER_TYPE.AUTO_MP,
		menuMusic = "mp_frontend",
		joinPartyPrivacyCheck = false
	},
	UI_MPLOBBYONLINECUSTOMGAME = {
		id = 330,
		name = "MPLobbyOnlineCustomGame",
		title = "MENU_CUSTOMGAMES_CAPS",
		kicker = "MENU_FILESHARE_CUSTOMGAMES",
		room = "mp_custom",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 18,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_MP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_MANUAL,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL,
		menuMusic = "mp_frontend",
		joinPartyPrivacyCheck = true
	},
	UI_MPLOBBYONLINETHEATER = {
		id = 340,
		name = "MPLobbyOnlineTheater",
		title = "MENU_THEATER_CAPS",
		kicker = "",
		room = "mp_theater",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 1,
		maxLocalClients = 1,
		maxLocalClientsNetwork = 1,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_MP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_THEATER,
		eGameModes = Enum.eGameModes.MODE_GAME_THEATER,
		lobbyTimerType = LuaEnums.TIMER_TYPE.THEATER,
		menuMusic = "mp_frontend",
		joinPartyPrivacyCheck = true
	},
	UI_MPLOBBYLANGAME = {
		id = 390,
		name = "MPLobbyLANGame",
		title = "MENU_MULTIPLAYER_CAPS",
		kicker = "MENU_MULTIPLAYER",
		room = "mp",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 18,
		maxLocalClients = 4,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_MP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LAN,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_MANUAL,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL,
		menuMusic = "mp_frontend",
		joinPartyPrivacyCheck = false
	},
	UI_MPLOBBYONLINEARENA = {
		id = 350,
		name = "MPLobbyOnlineArena",
		title = "MENU_ARENA_CAPS",
		kicker = "MENU_ARENA_CAPS",
		room = "mp_arena",
		isPrivate = true,
		isGame = false,
		isAdvertised = false,
		maxClients = 18,
		maxLocalClients = 1,
		maxLocalClientsNetwork = 1,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_MP,
		networkmode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_PRIVATE,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_ARENA,
		eGameModes = Enum.eGameModes.MODE_GAME_LEAGUE,
		lobbyTimerType = LuaEnums.TIMER_TYPE.INVALID,
		menuMusic = "mp_frontend",
		joinPartyPrivacyCheck = true
	},
	UI_MPLOBBYONLINEARENAGAME = {
		id = 351,
		name = "MPLobbyOnlineArenaGame",
		title = "MENU_ARENA_CAPS",
		kicker = "MENU_ARENA_CAPS",
		room = "mp_arena",
		isPrivate = true,
		isGame = true,
		isAdvertised = true,
		maxClients = 18,
		maxLocalClients = 1,
		maxLocalClientsNetwork = 1,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_MP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_ARENA,
		eGameModes = Enum.eGameModes.MODE_GAME_LEAGUE,
		lobbyTimerType = LuaEnums.TIMER_TYPE.AUTO_MP,
		menuMusic = "mp_frontend",
		joinPartyPrivacyCheck = true
	},
	UI_FRLOBBYONLINEGAME = {
		id = 500,
		name = "FRLobbyOnlineGame",
		title = "MENU_FREERUN_CAPS",
		kicker = "",
		room = "mp_freerun",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 1,
		maxLocalClients = 1,
		maxLocalClientsNetwork = 1,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_MP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_FREERUN,
		eGameModes = Enum.eGameModes.MODE_GAME_FREERUN,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL,
		menuMusic = "free_run",
		joinPartyPrivacyCheck = true
	},
	UI_FRLOBBYLANGAME = {
		id = 510,
		name = "FRLobbyLANGame",
		title = "MENU_FREERUN_CAPS",
		kicker = "",
		room = "mp_freerun",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 1,
		maxLocalClients = 1,
		maxLocalClientsNetwork = 1,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_MP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LAN,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_FREERUN,
		eGameModes = Enum.eGameModes.MODE_GAME_FREERUN,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL,
		menuMusic = "free_run",
		joinPartyPrivacyCheck = false
	},
	UI_ZMLOBBYONLINE = {
		id = 400,
		name = "ZMLobbyOnline",
		title = "MENU_ZOMBIES_CAPS",
		kicker = "MENU_ZOMBIES",
		room = "zm",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_ZM,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_MANUAL,
		lobbyTimerType = LuaEnums.TIMER_TYPE.NONE,
		menuMusic = "zm_frontend",
		joinPartyPrivacyCheck = true
	},
	UI_ZMLOBBYONLINEPUBLICGAME = {
		id = 401,
		name = "ZMLobbyOnlinePublicGame",
		title = "MENU_ZOMBIES_CAPS",
		kicker = "MPUI_PUBLIC_MATCH_LOBBY",
		room = "zm",
		isPrivate = true,
		isGame = true,
		isAdvertised = true,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_ZM,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_PUBLIC,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_PLAYLIST,
		lobbyTimerType = LuaEnums.TIMER_TYPE.AUTO_ZM,
		menuMusic = "zm_frontend",
		joinPartyPrivacyCheck = false
	},
	UI_ZMLOBBYONLINECUSTOMGAME = {
		id = 402,
		name = "ZMLobbyOnlineCustomGame",
		title = "MENU_PRIVATE_GAME_CAPS",
		kicker = "MENU_FILESHARE_CUSTOMGAMES",
		room = "zm",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_ZM,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_MANUAL,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL,
		menuMusic = "zm_frontend",
		joinPartyPrivacyCheck = true
	},
	UI_ZMLOBBYONLINETHEATER = {
		id = 403,
		name = "ZMLobbyOnlineTheater",
		title = "MENU_THEATER_CAPS",
		kicker = "",
		room = "zm",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 1,
		maxLocalClients = 1,
		maxLocalClientsNetwork = 1,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_ZM,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_THEATER,
		eGameModes = Enum.eGameModes.MODE_GAME_THEATER,
		lobbyTimerType = LuaEnums.TIMER_TYPE.THEATER,
		menuMusic = "zm_frontend",
		joinPartyPrivacyCheck = true
	},
	UI_ZMLOBBYLANGAME = {
		id = 410,
		name = "ZMLobbyLANGame",
		title = "MENU_ZOMBIES_CAPS",
		kicker = "MENU_ZOMBIES",
		room = "zm",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 8,
		maxLocalClients = 4,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_ZM,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LAN,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_MANUAL,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL,
		menuMusic = "zm_frontend",
		joinPartyPrivacyCheck = false
	},
	UI_DOALOBBYONLINE = {
		id = 600,
		name = "CPDOALobbyOnline",
		title = "MENU_DOA2_TITLE",
		kicker = "",
		room = "doa",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_CP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_MANUAL,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL_CP,
		menuMusic = "zm_cp_frontend",
		joinPartyPrivacyCheck = true
	},
	UI_DOALOBBYONLINEPUBLICGAME = {
		id = 601,
		name = "CPDOALobbyOnlinePublicGame",
		title = "MENU_DOA2_TITLE",
		kicker = "MPUI_PUBLIC_MATCH_LOBBY",
		room = "doa",
		isPrivate = true,
		isGame = true,
		isAdvertised = true,
		maxClients = 8,
		maxLocalClients = 2,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_CP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_PUBLIC,
		eGameModes = Enum.eGameModes.MODE_GAME_MATCHMAKING_PLAYLIST,
		lobbyTimerType = LuaEnums.TIMER_TYPE.AUTO_CP,
		menuMusic = "zm_cp_frontend",
		joinPartyPrivacyCheck = false
	},
	UI_DOALOBBYLANGAME = {
		id = 610,
		name = "CPDOALobbyLANGame",
		title = "MENU_DOA2_TITLE",
		kicker = "",
		room = "doa",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 8,
		maxLocalClients = 4,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_CP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LAN,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_INVALID,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL_CP,
		menuMusic = "zm_cp_frontend",
		joinPartyPrivacyCheck = false
	},
	UI_DOALOBBYLANCUSTOMGAME = {
		id = 611,
		name = "CPDOALobbyLANCustomGame",
		title = "MENU_DOA2_TITLE",
		kicker = "",
		room = "doa",
		isPrivate = true,
		isGame = true,
		isAdvertised = false,
		maxClients = 8,
		maxLocalClients = 4,
		maxLocalClientsNetwork = 2,
		mainMode = Enum.LobbyMainMode.LOBBY_MAINMODE_CP,
		networkMode = Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LAN,
		lobbyType = Enum.LobbyType.LOBBY_TYPE_GAME,
		lobbyMode = Enum.LobbyMode.LOBBY_MODE_CUSTOM,
		eGameModes = Enum.eGameModes.MODE_GAME_INVALID,
		lobbyTimerType = LuaEnums.TIMER_TYPE.MANUAL_CP,
		menuMusic = "zm_cp_frontend",
		joinPartyPrivacyCheck = false
	},
	UI_MAIN = nil,
	UI_MAIN = f0_local1.UI_MAIN,
	UI_MODESELECT = f0_local1.UI_MAIN,
	UI_MODESELECT = f0_local1.UI_MODESELECT,
	UI_CPLOBBYLANGAME = f0_local1.UI_MODESELECT,
	UI_CPLOBBYLANGAME = f0_local1.UI_CPLOBBYLANGAME,
	UI_CPLOBBYLANCUSTOMGAME = f0_local1.UI_CPLOBBYLANGAME,
	UI_CPLOBBYLANCUSTOMGAME = f0_local1.UI_CPLOBBYLANGAME,
	UI_CPLOBBYONLINECUSTOMGAME = f0_local1.UI_CPLOBBYONLINE,
	UI_CPLOBBYONLINECUSTOMGAME = f0_local1.UI_CPLOBBYONLINECUSTOMGAME,
	UI_CPLOBBYONLINE = f0_local1.UI_MODESELECT,
	UI_CPLOBBYONLINE = f0_local1.UI_CPLOBBYONLINE,
	UI_CPLOBBYONLINEPUBLICGAME = f0_local1.UI_CPLOBBYONLINE,
	UI_CPLOBBYONLINEPUBLICGAME = f0_local1.UI_CPLOBBYONLINE,
	UI_CPLOBBYONLINECUSTOMGAME = f0_local1.UI_CPLOBBYONLINE,
	UI_CPLOBBYONLINECUSTOMGAME = f0_local1.UI_CPLOBBYONLINECUSTOMGAME,
	UI_CP2LOBBYLANGAME = f0_local1.UI_MODESELECT,
	UI_CP2LOBBYLANGAME = f0_local1.UI_CP2LOBBYLANGAME,
	UI_CP2LOBBYLANCUSTOMGAME = f0_local1.UI_CP2LOBBYLANGAME,
	UI_CP2LOBBYLANCUSTOMGAME = f0_local1.UI_CP2LOBBYLANGAME,
	UI_CP2LOBBYONLINECUSTOMGAME = f0_local1.UI_CP2LOBBYONLINE,
	UI_CP2LOBBYONLINECUSTOMGAME = f0_local1.UI_CP2LOBBYONLINECUSTOMGAME,
	UI_CP2LOBBYONLINE = f0_local1.UI_MODESELECT,
	UI_CP2LOBBYONLINE = f0_local1.UI_CP2LOBBYONLINE,
	UI_CP2LOBBYONLINEPUBLICGAME = f0_local1.UI_CP2LOBBYONLINE,
	UI_CP2LOBBYONLINEPUBLICGAME = f0_local1.UI_CP2LOBBYONLINE,
	UI_CP2LOBBYONLINECUSTOMGAME = f0_local1.UI_CP2LOBBYONLINE,
	UI_CP2LOBBYONLINECUSTOMGAME = f0_local1.UI_CP2LOBBYONLINECUSTOMGAME,
	UI_DOALOBBYLANGAME = f0_local1.UI_MODESELECT,
	UI_DOALOBBYLANGAME = f0_local1.UI_DOALOBBYLANGAME,
	UI_DOALOBBYLANCUSTOMGAME = f0_local1.UI_DOALOBBYLANGAME,
	UI_DOALOBBYLANCUSTOMGAME = f0_local1.UI_DOALOBBYLANGAME,
	UI_DOALOBBYONLINE = f0_local1.UI_MODESELECT,
	UI_DOALOBBYONLINE = f0_local1.UI_DOALOBBYONLINE,
	UI_DOALOBBYONLINEPUBLICGAME = f0_local1.UI_DOALOBBYONLINE,
	UI_DOALOBBYONLINEPUBLICGAME = f0_local1.UI_DOALOBBYONLINE,
	UI_MPLOBBYLANGAME = f0_local1.UI_MODESELECT,
	UI_MPLOBBYLANGAME = f0_local1.UI_MODESELECT,
	UI_MPLOBBYMAIN = f0_local1.UI_MODESELECT,
	UI_MPLOBBYMAIN = f0_local1.UI_MODESELECT,
	UI_MPLOBBYONLINE = f0_local1.UI_MPLOBBYMAIN,
	UI_MPLOBBYONLINE = f0_local1.UI_MPLOBBYONLINE,
	UI_MPLOBBYONLINEPUBLICGAME = f0_local1.UI_MPLOBBYONLINE,
	UI_MPLOBBYONLINEPUBLICGAME = f0_local1.UI_MPLOBBYONLINE,
	UI_MPLOBBYONLINEMODGAME = f0_local1.UI_MPLOBBYMAIN,
	UI_MPLOBBYONLINEMODGAME = f0_local1.UI_MPLOBBYMAIN,
	UI_MPLOBBYONLINECUSTOMGAME = f0_local1.UI_MPLOBBYMAIN,
	UI_MPLOBBYONLINECUSTOMGAME = f0_local1.UI_MPLOBBYONLINECUSTOMGAME,
	UI_MPLOBBYONLINETHEATER = f0_local1.UI_MPLOBBYMAIN,
	UI_MPLOBBYONLINETHEATER = f0_local1.UI_MPLOBBYONLINETHEATER,
	UI_MPLOBBYONLINEARENA = f0_local1.UI_MPLOBBYMAIN,
	UI_MPLOBBYONLINEARENA = f0_local1.UI_MPLOBBYMAIN,
	UI_MPLOBBYONLINEARENAGAME = f0_local1.UI_MPLOBBYONLINEARENA,
	UI_MPLOBBYONLINEARENAGAME = f0_local1.UI_MPLOBBYONLINEARENA,
	UI_ZMLOBBYLANGAME = f0_local1.UI_MODESELECT,
	UI_ZMLOBBYLANGAME = f0_local1.UI_ZMLOBBYLANGAME,
	UI_ZMLOBBYONLINE = f0_local1.UI_MODESELECT,
	UI_ZMLOBBYONLINE = f0_local1.UI_ZMLOBBYONLINE,
	UI_ZMLOBBYONLINEPUBLICGAME = f0_local1.UI_ZMLOBBYONLINE,
	UI_ZMLOBBYONLINEPUBLICGAME = f0_local1.UI_ZMLOBBYONLINE,
	UI_ZMLOBBYONLINECUSTOMGAME = f0_local1.UI_ZMLOBBYONLINE,
	UI_ZMLOBBYONLINECUSTOMGAME = f0_local1.UI_ZMLOBBYONLINECUSTOMGAME,
	UI_ZMLOBBYONLINETHEATER = f0_local1.UI_ZMLOBBYONLINE,
	UI_ZMLOBBYONLINETHEATER = f0_local1.UI_ZMLOBBYONLINETHEATER,
	UI_FRLOBBYONLINEGAME = f0_local1.UI_MODESELECT,
	UI_FRLOBBYONLINEGAME = f0_local1.UI_MODESELECT,
	UI_FRLOBBYLANGAME = f0_local1.UI_MODESELECT,
	UI_FRLOBBYLANGAME = f0_local1.UI_MODESELECT
}
local f0_local2 = {
	LobbyClosed = "uin_lobby_closed",
	ClientsAddedToLobby = "uin_lobby_enter",
	ClientsRemovedFromLobby = "uin_lobby_exit",
	TimerTick = "uin_timer",
	ESportsTimerTick = "uin_timer_esports_beep",
	ESportsTimerTickLast = "uin_timer_esports_last_beep"
}
f0_local0.InitLobbyNav = function ()
	Engine.SetModelValue( Engine.CreateModel( Engine.GetGlobalModel(), "lobbyRoot.lobbyNav", true ), f0_local0.UITargets.UI_MAIN.id )
	Engine.SetModelValue( Engine.CreateModel( Engine.GetGlobalModel(), "lobbyRoot.room", true ), "room1" )
	if LUI then
		LUI.CoDMetrics.LobbyInit()
	end
end

f0_local0.GetLobbyNavModel = function ()
	return Engine.GetModel( Engine.GetGlobalModel(), "lobbyRoot.lobbyNav" )
end

f0_local0.GetLobbyNav = function ()
	return Engine.GetModelValue( f0_local0.GetLobbyNavModel() )
end

f0_local0.GetCurrentMenuTarget = function ()
	return LobbyData:UITargetFromId( Engine.GetLobbyUIScreen() )
end

f0_local0.SetLobbyNav = function ( f5_arg0 )
	local f5_local0 = f0_local0.GetLobbyNavModel()
	if not f5_local0 then
		f0_local0.InitLobbyNav()
		f5_local0 = f0_local0.GetLobbyNavModel()
	end
	Engine.PrintInfo( Enum.consoleLabel.LABEL_LOBBY, "LobbyData.SetLobbyNav. From: " .. tostring( Engine.GetModelValue( f5_local0 ) ) .. " To: " .. tostring( f5_arg0.id ) .. "\n" )
	Engine.SetModelValue( f5_local0, f5_arg0.id )
	Engine.SetModelValue( Engine.CreateModel( Engine.GetGlobalModel(), "lobbyRoot.lobbyTitle" ), f5_arg0.title )
	local f5_local1 = Engine.CreateModel( Engine.GetGlobalModel(), "lobbyRoot.headingKickerMode" )
	local f5_local2 = Engine.SetModelValue
	local f5_local3 = f5_local1
	if f5_arg0.kicker then
		local f5_local4 = f5_arg0.kicker
		local f5_local5 = Engine.Localize( f5_arg0.kicker )
	end
	f5_local2( f5_local3, f5_local4 and f5_local5 or "" )
	Engine.CreateModel( Engine.GetGlobalModel(), "lobbyRoot.headingKickerText" )
end

f0_local0.UITargetFromName = function ( f6_arg0, f6_arg1 )
	for f6_local3, f6_local4 in pairs( f6_arg0.UITargets._originalTable ) do
		if f6_local4.name == f6_arg1 then
			return f6_local4
		end
	end
	print( "Lobby VM: No valid ui target found for menu name: " .. f6_arg1 )
	return nil
end

f0_local0.UITargetFromId = function ( f7_arg0, f7_arg1 )
	for f7_local3, f7_local4 in pairs( f7_arg0.UITargets._originalTable ) do
		if f7_local4.id == f7_arg1 then
			return f7_local4
		end
	end
	print( "Lobby VM: No valid ui target found for menu id: " .. (f7_arg1 or "nil") )
	return nil
end

f0_local0.PartyPrivacyToString = function ( f8_arg0 )
	local f8_local0 = "MENU_PARTY_PRIVACY_CLOSED"
	if f8_arg0 == Enum.PartyPrivacy.PARTY_PRIVACY_OPEN then
		f8_local0 = "MENU_PARTY_PRIVACY_OPEN"
	elseif f8_arg0 == Enum.PartyPrivacy.PARTY_PRIVACY_FRIENDS_ONLY then
		f8_local0 = "MENU_PARTY_PRIVACY_FRIENDS_ONLY"
	elseif f8_arg0 == Enum.PartyPrivacy.PARTY_PRIVACY_INVITE_ONLY then
		f8_local0 = "MENU_PARTY_PRIVACY_INVITE_ONLY"
	elseif f8_arg0 == Enum.PartyPrivacy.PARTY_PRIVACY_CLOSED then
		f8_local0 = "MENU_PARTY_PRIVACY_CLOSED"
	end
	return Engine.Localize( f8_local0 )
end

f0_local0.PS4SkuList = {
	{
		name = "SceaEnFr",
		langs = {
			"en",
			"fr"
		},
		region = 0
	},
	{
		name = "SceaMsEn",
		langs = {
			"ms",
			"en"
		},
		region = 0
	},
	{
		name = "SceaBpEn",
		langs = {
			"bp",
			"en",
			"tc",
			"sc"
		},
		region = 0
	},
	{
		name = "SceeEnFr",
		langs = {
			"en",
			"fr"
		},
		region = 1
	},
	{
		name = "SceeGeEn",
		langs = {
			"ge",
			"en"
		},
		region = 1
	},
	{
		name = "SceeSpIt",
		langs = {
			"es",
			"it"
		},
		region = 1
	},
	{
		name = "SceeRuPo",
		langs = {
			"ru",
			"po"
		},
		region = 1
	},
	{
		name = "SceeArEa",
		langs = {
			"ar",
			"ea"
		},
		region = 1
	},
	{
		name = "ScejFjJa",
		langs = {
			"fj",
			"ja"
		},
		region = 2
	}
}
f0_local0.XBOXSkuList = {
	{
		name = "XboxEnFr",
		langs = {
			"en",
			"fr"
		},
		region = 0
	},
	{
		name = "XboxMsEn",
		langs = {
			"ms",
			"en"
		},
		region = 0
	},
	{
		name = "XboxBpEn",
		langs = {
			"bp",
			"en",
			"tc",
			"sc"
		},
		region = 0
	},
	{
		name = "XboxGeEn",
		langs = {
			"ge",
			"en"
		},
		region = 0
	},
	{
		name = "XboxSpIt",
		langs = {
			"es",
			"it"
		},
		region = 0
	},
	{
		name = "XboxRuPo",
		langs = {
			"ru",
			"po"
		},
		region = 0
	},
	{
		name = "XboxArEa",
		langs = {
			"ar",
			"ea"
		},
		region = 0
	},
	{
		name = "XboxFjJa",
		langs = {
			"fj",
			"ja"
		},
		region = 0
	},
	{
		name = "XboxInvalid",
		langs = {
			"en",
			"fr",
			"it",
			"de",
			"pt",
			"pl",
			"ru",
			"ja",
			"es",
			"zm"
		},
		region = 0
	}
}
for f0_local6, f0_local7 in ipairs( f0_local0.PS4SkuList ) do
	table.sort( f0_local7.langs )
end
for f0_local6, f0_local7 in ipairs( f0_local0.XBOXSkuList ) do
	table.sort( f0_local7.langs )
end
f0_local0.ButtonStates_ReevaluateDisabledState = function ()
	local f9_local0 = Engine.GetModel( Engine.GetGlobalModel(), "ButtonStates.ReevaluateDisabledStates" )
	if f9_local0 then
		Engine.SetModelValue( f9_local0, not Engine.GetModelValue( f9_local0 ) )
	end
end

f0_local0.Sounds = LuaReadOnlyTables.ReadOnlyTable( f0_local2 )
f0_local0.UITargets = LuaReadOnlyTables.ReadOnlyTable( f0_local1 )
LobbyData = LuaReadOnlyTables.ReadOnlyTable( f0_local0 )
