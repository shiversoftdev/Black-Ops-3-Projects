EnableGlobals()

CoD.ScoreboardUtility = {}
CoD.ScoreboardUtility.MinRowsToShowOnEachTeam = 8
CoD.ScoreboardUtility.MinRowsToShowOnEachTeamForFFA = 8
CoD.ScoreboardUtility.GetScoreboardTeamTable = function ( f1_arg0, f1_arg1 )
	local f1_local0 = Engine.GetTeamPositions( f1_arg0, Engine.GetCurrentTeamCount() )
	if Engine.GetCurrentTeamCount() < 2 and f1_arg1 == 2 then
		return {}
	end
	local f1_local1 = f1_local0[f1_arg1].team
	local f1_local2 = 0
	local f1_local3 = 0
	if f1_local1 ~= Enum.team_t.TEAM_FREE then
		f1_local2 = Engine.GetScoreboardTeamClientCount( Enum.team_t.TEAM_ALLIES )
		f1_local3 = Engine.GetScoreboardTeamClientCount( Enum.team_t.TEAM_AXIS )
	else
		f1_local2 = Engine.GetScoreboardTeamClientCount( Enum.team_t.TEAM_FREE )
	end
	local f1_local4 = CoD.ScoreboardUtility.MinRowsToShowOnEachTeam
	if Engine.GetCurrentTeamCount() < 2 then
		f1_local4 = CoD.ScoreboardUtility.MinRowsToShowOnEachTeamForFFA
	end
	f1_local4 = math.max( f1_local4, math.max( f1_local2, f1_local3 ) )
	local f1_local5 = {}
	for f1_local6 = 1, f1_local4, 1 do
		local f1_local9 = "team: " .. f1_local1 .. " client: " .. f1_local6 - 1
		local f1_local10 = -1
		if Engine.GetScoreboardTeamClientCount( f1_local1 ) < f1_local6 then
			f1_local9 = "team: " .. f1_local1 .. " client: -1"
		else
			f1_local10 = Engine.GetScoreboardPlayerData( f1_local6 - 1, f1_local1, Enum.scoreBoardColumns_e.SCOREBOARD_COLUMN_CLIENTNUM )
		end
		table.insert( f1_local5, {
			models = {
				clientInfo = f1_local9 .. " " .. Engine.milliseconds(),
				clientNum = tonumber( f1_local10 )
			}
		} )
	end
	return f1_local5
end

CoD.ScoreboardUtility.UpdateScoreboardTeamScores = function ( f2_arg0 )
	local f2_local0 = Engine.GetCurrentTeamCount()
	local f2_local1 = Engine.CreateModel( Engine.GetModelForController( f2_arg0 ), "scoreboardInfo" )
	local f2_local2 = Engine.GetTeamPositions( f2_arg0, f2_local0 )
	local f2_local3 = {}
	for f2_local4 = 1, f2_local0, 1 do
		local f2_local7 = {}
		local f2_local8 = f2_local2[f2_local4].team
		f2_local7.FactionName = ""
		f2_local7.FactionIcon = ""
		f2_local7.Score = f2_local2[f2_local4].score
		if f2_local8 ~= Enum.team_t.TEAM_FREE then
			f2_local7.FactionName = CoD.GetTeamNameCaps( f2_local8 )
			f2_local7.FactionIcon = CoD.GetTeamFactionIcon( f2_local8 )
			f2_local7.FactionColor = CoD.GetTeamFactionColor( f2_local8 )
		end
		table.insert( f2_local3, f2_local7 )
	end
	for f2_local12, f2_local7 in ipairs( f2_local3 ) do
		for f2_local9, f2_local10 in pairs( f2_local7 ) do
			Engine.SetModelValue( Engine.CreateModel( f2_local1, "team" .. f2_local12 .. f2_local9 ), f2_local10 )
		end
	end
end

CoD.ScoreboardUtility.GetTeamEnumAndClientIndex = function ( f3_arg0 )
	local f3_local0, f3_local1, f3_local2, f3_local3 = string.match( f3_arg0, "(%a+):%s*(%d+)%s+(%a+):%s*(-*%d+)" )
	return tonumber( f3_local1 ), tonumber( f3_local3 )
end

CoD.ScoreboardUtility.SetNemesisInfoModels = function ( f4_arg0, f4_arg1 )
	local f4_local0 = CoD.GetPlayerStats( f4_arg0 )
	local f4_local1 = f4_local0.AfterActionReportStats
	local f4_local2 = f4_local1.nemesisKills:get()
	local f4_local3 = f4_local1.nemesisKilledBy:get()
	Engine.SetModelValue( Engine.CreateModel( f4_arg1, "nemesisXuid" ), Engine.StringToXUIDDecimal( f4_local1.nemesisXuid:get() ) )
	Engine.SetModelValue( Engine.CreateModel( f4_arg1, "nemesisKills" ), f4_local2 )
	Engine.SetModelValue( Engine.CreateModel( f4_arg1, "nemesisKilledBy" ), f4_local3 )
end

CoD.ScoreboardUtility.SetScoreboardUIModels = function ( f5_arg0 )
	local f5_local0 = Engine.GetCurrentTeamCount()
	local f5_local1 = Engine.GetModelForController( f5_arg0 )
	local f5_local2 = Engine.CreateModel( f5_local1, "scoreboardInfo" )
	local f5_local3 = Engine.CreateModel( Engine.GetModelForController( 0 ), "scoreboardInfo" )
	if not Engine.GetModel( f5_local1, "forceScoreboard" ) then
		Engine.SetModelValue( Engine.CreateModel( f5_local1, "forceScoreboard" ), 0 )
	end
	Engine.SetModelValue( Engine.CreateModel( Engine.GetModelForController( f5_arg0 ), "updateClientDeadStatus" ), 0 )
	Engine.SetModelValue( Engine.CreateModel( f5_local2, "muteButtonPromptVisible" ), false )
	Engine.SetModelValue( Engine.CreateModel( f5_local2, "muteButtonPromptText" ), "" )
	local f5_local4 = CoD.GetMapValue( Engine.GetCurrentMapName(), "mapNameCaps", "" )
	Engine.SetModelValue( Engine.CreateModel( f5_local2, "mapName" ), f5_local4 )
	Engine.SetModelValue( Engine.CreateModel( f5_local3, "mapName" ), f5_local4 )
	if Engine.IsMultiplayerGame() then
		if not Engine.IsInGame() then
			CoD.ScoreboardUtility.SetNemesisInfoModels( f5_arg0, f5_local2 )
		end
		local f5_local5 = Engine.GetTeamPositions( f5_arg0, f5_local0 )
		local f5_local6 = {}
		for f5_local7 = 1, f5_local0, 1 do
			local f5_local10 = {}
			local f5_local11 = f5_local5[f5_local7].team
			f5_local10.FactionName = ""
			f5_local10.FactionIcon = ""
			f5_local10.Score = f5_local5[f5_local7].score
			if f5_local11 ~= Enum.team_t.TEAM_FREE then
				f5_local10.FactionName = CoD.GetTeamNameCaps( f5_local11 )
				f5_local10.FactionIcon = CoD.GetTeamFactionIcon( f5_local11 )
				f5_local10.FactionColor = CoD.GetTeamFactionColor( f5_local11 )
			end
			table.insert( f5_local6, f5_local10 )
		end
		for f5_local15, f5_local10 in ipairs( f5_local6 ) do
			for f5_local12, f5_local13 in pairs( f5_local10 ) do
				Engine.SetModelValue( Engine.CreateModel( f5_local2, "team" .. f5_local15 .. f5_local12 ), f5_local13 )
			end
		end
		f5_local7 = Engine.StructTableLookupString( CoDShared.gametypesStructTable, "name", Engine.GetCurrentGameType(), "name_ref_caps" )
		Engine.SetModelValue( Engine.CreateModel( f5_local2, "gameType" ), f5_local7 )
		Engine.SetModelValue( Engine.CreateModel( f5_local3, "gameType" ), f5_local7 )
		if f5_local0 < 2 then
			f5_local8 = Engine.GetModel( f5_local1, "gameScore.playerScore" )
			if f5_local8 then
				Engine.SetModelValue( Engine.CreateModel( f5_local2, "team1Score" ), Engine.GetModelValue( f5_local8 ) )
			else
				local f5_local5 = 5
				for f5_local6 = 1, f5_local5, 1 do
					Engine.SetModelValue( Engine.CreateModel( f5_local2, "column" .. f5_local6 .. "Header" ), Engine.GetScoreboardColumnHeader( f5_arg0, f5_local6 - 1 ) )
				end
			end
		else
			local f5_local5 = 5
			for f5_local6 = 1, f5_local5, 1 do
				Engine.SetModelValue( Engine.CreateModel( f5_local2, "column" .. f5_local6 .. "Header" ), Engine.GetScoreboardColumnHeader( f5_arg0, f5_local6 - 1 ) )
			end
		end
	end
	local f5_local5 = 5
	for f5_local6 = 1, f5_local5, 1 do
		Engine.SetModelValue( Engine.CreateModel( f5_local2, "column" .. f5_local6 .. "Header" ), Engine.GetScoreboardColumnHeader( f5_arg0, f5_local6 - 1 ) )
	end
end

