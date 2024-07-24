local old_joinablecheck = LobbyVM.JoinableCheck
LobbyVM.JoinableCheck = function(request)
    local result = old_joinablecheck(request)
    if result ~= Enum.JoinResult.JOIN_RESULT_SUCCESS then
        return result
    end

    if request.isLocalRequest then
        return result
    end

    local clientCount = Engine.GetLobbyClientCount( Enum.LobbyType.LOBBY_TYPE_GAME )
    local maxClients = Engine.GetLobbyMaxClients( Enum.LobbyType.LOBBY_TYPE_GAME )
    local maxPlayers = Dvar.party_maxplayers:get()

    if clientCount == nil then 
        clientCount = 1
    end

    if maxPlayers == nil then 
        maxPlayers = maxClients 
    end

    local availableSlots = maxClients - clientCount

    if availableSlots > (maxPlayers - clientCount) then 
        availableSlots = maxPlayers - clientCount
    end

    if availableSlots <= 0 then
        return Enum.JoinResult.JOIN_RESULT_JOIN_DISABLED
    end

    local privacy = Engine.GetPartyPrivacy()
    if privacy == Enum.PartyPrivacy.PARTY_PRIVACY_CLOSED then
        return Enum.JoinResult.JOIN_RESULT_NOT_JOINABLE_CLOSED
    end

    if privacy == Enum.PartyPrivacy.PARTY_PRIVACY_FRIENDS_ONLY then
        local xuid = request.fromXUID
        if Engine.IsFriendFromXUID( Engine.GetPrimaryController(), xuid ) ~= true then
            return Enum.JoinResult.JOIN_RESULT_NOT_JOINABLE_FRIENDS_ONLY
        end
    end

    return result
end

-- LobbyVM.JoinableCheck = function ( request )
--     local f138_local0 = request.joinRequest
--     local f138_local1 = request.joinResponse
--     local f138_local2 = LobbyData.GetCurrentMenuTarget()
--     if Engine.IsDedicatedServer() == false and Engine.IsProcessingJoin() == true and f138_local2.lobbyType == Enum.LobbyType.LOBBY_TYPE_GAME and (f138_local2.lobbyMode == Enum.LobbyMode.LOBBY_MODE_PUBLIC or f138_local2.lobbyMode == Enum.LobbyMode.LOBBY_MODE_ARENA) then
--         if f138_local2.mainMode == Enum.LobbyMainMode.LOBBY_MAINMODE_CP and Engine.DvarBool( nil, "cpProcessingJoinCheck" ) then
--             return Enum.JoinResult.JOIN_RESULT_VM_FAILURE_1
--         elseif f138_local2.mainMode == Enum.LobbyMainMode.LOBBY_MAINMODE_MP and Engine.DvarBool( nil, "mpProcessingJoinCheck" ) then
--             return Enum.JoinResult.JOIN_RESULT_VM_FAILURE_1
--         elseif f138_local2.mainMode == Enum.LobbyMainMode.LOBBY_MAINMODE_ZM and Engine.DvarBool( nil, "zmProcessingJoinCheck" ) then
--             return Enum.JoinResult.JOIN_RESULT_VM_FAILURE_1
--         end
--     end
--     if Engine.IsInGame() or LobbyVM.IsHostLaunching() or Engine.GetCurrentMap() ~= "core_frontend" or Engine.SessionMode_IsPublicOnlineGame() then
--         local f138_local3 = Engine.LobbyGetSessionClients( Enum.LobbyModule.LOBBY_MODULE_HOST, Enum.LobbyType.LOBBY_TYPE_GAME )
--         local f138_local4 = LobbyVM.GetNeededDLCBits()
--         Engine.PrintInfo( Enum.consoleLabel.LABEL_LOBBY, "Incoming client dlc bits are " .. f138_local0.dlcBits .. " while our needed bits are " .. f138_local4 .. "\n" )
--         if Engine.IsZombiesGame() then
--             f138_local0.dlcBits = LuaUtils.UpdateZMDLCBits( f138_local0.dlcBits )
--         end
--         if not LobbyVM.CheckDLCBit( f138_local0.dlcBits, f138_local4 ) then
--             Engine.PrintWarning( Enum.consoleLabel.LABEL_LOBBY, "Rejecting client due to incompatible dlc bits.\n" )
--             if LobbyVM.CheckDLCBit( f138_local4, Enum.ContentFlagBits.CONTENT_DLC6 ) then
--                 return Enum.JoinResult.JOIN_RESULT_BAD_MPHD_BITS
--             else
--                 return Enum.JoinResult.JOIN_RESULT_BAD_DLC_BITS
--             end
--         end
--     end
--     if f138_local1.response == Enum.JoinResult.JOIN_RESULT_SUCCESS then
--         if Engine.IsMultiplayerGame() then
--             if LuaUtils.IsArenaMode() then
--                 if ((Engine.GetGametypeSetting( "pregameItemVoteEnabled" ) == 1) or Engine.GetGametypeSetting( "pregameDraftEnabled" ) == 1) and Engine.IsInGame() and Engine.SessionMode_IsPublicOnlineGame() then
--                     return Enum.JoinResult.JOIN_RESULT_NO_JOIN_IN_PROGRESS
--                 elseif request.joinRequest.splitscreenClients ~= nil and request.joinRequest.splitscreenClients > 0 then
--                     return Enum.JoinResult.JOIN_RESULT_SPLITSCREEN_NOT_ALLOWED
--                 elseif Lobby.Timer.LobbyIsLocked() then
--                     return Enum.JoinResult.JOIN_RESULT_NO_JOIN_IN_PROGRESS
--                 elseif Engine.GetLobbyPregameState() ~= Enum.LobbyPregameState.LOBBY_PREGAME_STATE_IDLE then
--                     return Enum.JoinResult.JOIN_RESULT_NO_JOIN_IN_PROGRESS
--                 end
--                 local f138_local5 = Lobby.Timer.GetTimerStatus()
--                 if f138_local5 == Lobby.Timer.LOBBY_STATUS.POST_GAME or f138_local5 == Lobby.Timer.LOBBY_STATUS.FIND_NEW_LOBBY then
--                     return Enum.JoinResult.JOIN_RESULT_NO_JOIN_IN_PROGRESS
--                 elseif Engine.DvarBool( 0, "probation_league_enabled" ) and f138_local2.lobbyType == Enum.LobbyType.LOBBY_TYPE_GAME then
--                     for f138_local9, f138_local10 in pairs( f138_local0.members ) do
--                         if f138_local10.arenaProbation > 0 then
--                             return Enum.JoinResult.JOIN_RESULT_IN_ARENA_PROBATION
--                         end
--                     end
--                 end
--             elseif Engine.DvarBool( 0, "probation_public_enabled" ) and f138_local2.lobbyType == Enum.LobbyType.LOBBY_TYPE_GAME then
--                 for f138_local5, f138_local6 in pairs( f138_local0.members ) do
--                     if f138_local6.publicProbation > 0 then
--                         return Enum.JoinResult.JOIN_RESULT_IN_PUBLIC_PROBATION
--                     end
--                 end
--             end
--         end
--         if Engine.IsZombiesGame() then
--             local f138_local3 = false
--             if Dvar.zm_private_rankedmatch:get() then
--                 f138_local3 = true
--             end
--             if LobbyVM.IsInTheaterLobby() then
--                 return Enum.JoinResult.JOIN_RESULT_JOIN_DISABLED
--             elseif LobbyData.UITargets.UI_ZMLOBBYONLINE.id == Engine.GetLobbyUIScreen() and (Engine.IsInGame() or LobbyVM.IsHostLaunching() or Engine.GetCurrentMap() ~= "core_frontend") then
--                 return Enum.JoinResult.JOIN_RESULT_NOT_JOINABLE_SOLO_MODE
--             elseif (Engine.IsInGame() or LobbyVM.IsHostLaunching()) and Engine.SessionMode_IsOnlineGame() and f138_local3 then
--                 return Enum.JoinResult.JOIN_RESULT_NO_JOIN_IN_PROGRESS
--             elseif (Engine.IsInGame() or LobbyVM.IsHostLaunching()) and Engine.SessionMode_IsPublicOnlineGame() then
--                 return Enum.JoinResult.JOIN_RESULT_NO_JOIN_IN_PROGRESS
--             end
--         end
--         if LuaUtils.isPC and LobbyVM.CheckStarterPack( f138_local0 ) then
--             return Enum.JoinResult.JOIN_RESULT_STARTER_PACK_RESTRICT
--         elseif LuaUtils.isPC then
--             if not request.isLocalRequest and Engine.IsLobbyHost( Enum.LobbyType.LOBBY_TYPE_GAME ) then
--                 local f138_local4 = Engine.LiveSteamServer_GetServerPassword()
--                 if f138_local4 and string.len( f138_local4 ) > 0 and request.joinRequest.password ~= f138_local4 then
--                     return Enum.JoinResult.JOIN_RESULT_INVALID_PASSWORD
--                 end
--             end
--         end
--         local f138_local3 = Engine.GetLobbyMainMode()
--         if Engine.GetLobbyNetworkMode() == Enum.LobbyNetworkMode.LOBBY_NETWORKMODE_LIVE then
--             if not request.isLocalRequest then
--                 if f138_local1.lobbyType == Enum.LobbyType.LOBBY_TYPE_GAME then
--                     local f138_local4 = LobbyVM.DoChunksAllowJoin( f138_local0, f138_local3 )
--                     if f138_local4 ~= Enum.JoinResult.JOIN_RESULT_SUCCESS then
--                         return f138_local4
--                     end
--                 elseif f138_local1.lobbyType == Enum.LobbyType.LOBBY_TYPE_PRIVATE then
--                     if LuaUtils.isPC then
--                         local f138_local4 = LobbyVM.DoChunksAllowJoin( f138_local0, f138_local3 )
--                         if f138_local4 ~= Enum.JoinResult.JOIN_RESULT_SUCCESS then
--                             return f138_local4
--                         end
--                     end
--                     for f138_local4 = 0, Enum.LobbyMainMode.LOBBY_MAINMODE_COUNT - 1, 1 do
--                         local f138_local7 = LobbyVM.DoChunksAllowJoin( f138_local0, f138_local4 )
--                         if f138_local7 ~= Enum.JoinResult.JOIN_RESULT_SUCCESS then
--                             return f138_local7
--                         end
--                     end
--                 end
--             end
--         elseif not request.isLocalRequest then
--             local f138_local4 = LobbyVM.DoChunksAllowJoin( f138_local0, f138_local3 )
--             if f138_local4 ~= Enum.JoinResult.JOIN_RESULT_SUCCESS then
--                 return f138_local4
--             end
--         end
--     end
--     return f138_local1.response
-- end