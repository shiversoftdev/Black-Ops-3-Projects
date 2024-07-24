require("ui.lui.lui3dtext")

local DAMAGE_TYPE_ANY = 0
local DAMAGE_TYPE_EXPLOSIVE = 1
local DAMAGE_TYPE_REDUCED = 2
local DAMAGE_TYPE_KT_MARKED = 3
local DAMAGE_TYPE_ZOMBIES = 4
local DAMAGE_TYPE_CRITICAL = 5

local function color_from_type(dtype)
    if DAMAGE_TYPE_ANY == dtype then
        return "255 255 255"
    end

    if DAMAGE_TYPE_CRITICAL == dtype then
        return "227 189 66"
    end

    if DAMAGE_TYPE_REDUCED == dtype then
        return "255 48 66"
    end

    if DAMAGE_TYPE_ZOMBIES == dtype then
        return "170 170 170"
    end

    if DAMAGE_TYPE_EXPLOSIVE == dtype then
        return "90 190 255"
    end

    return "255 255 255"
end

function format_int(number)

    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
  
    -- reverse the int-string and append a comma to all blocks of 3 digits
    int = int:reverse():gsub("(%d%d%d)", "%1,")
  
    -- reverse the int-string back remove an optional comma and put the 
    -- optional minus and fractional part back
    return minus .. int:reverse():gsub("^,", "") .. fraction
  end

local damage3dlist = {}

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end

  function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

CoD.Damage3dEvent = function(event_data)
end

CoD.LobbyCharacterEvent = function(event_data)
    local str_notify = tostring(event_data.whoami) .. ";" .. tostring(event_data.c0) .. ";" .. tostring(event_data.c1) .. ";" .. tostring(event_data.c2) .. ";" .. tostring(event_data.c3) .. ";" .. tostring(event_data.c4) .. ";" .. tostring(event_data.c5) .. ";" .. tostring(event_data.c6).. ";" .. tostring(event_data.c7);
    Engine.SendClientScriptNotify(controller, "zbr_characterlist_update", str_notify);
end

CoD.LobbyCharacterEmote = function(event_data)
    Engine.SendClientScriptNotify(controller, "zbr_character_emote", tostring(event_data.who) .. ";" .. tostring(event_data.what));
end

CoD.old_zbr_gametype = Engine.DvarString( nil, "zbr_gametype" )
CoD.GametypeUpdateEvent = function(event_data)

    if Engine.DvarString( nil, "zbr_gametype" ) == "zhunt" then
        CoD.teamName[Enum.team_t.TEAM_ALLIES] = Engine.Localize("RUNNERS")
	    CoD.teamName[Enum.team_t.TEAM_AXIS] = Engine.Localize("HUNTERS")
    else
        CoD.teamName[Enum.team_t.TEAM_ALLIES] = Engine.Localize("TEAM 1")
	    CoD.teamName[Enum.team_t.TEAM_AXIS] = Engine.Localize("TEAM 2")
    end

    if CoD.old_zbr_gametype ~= Engine.DvarString( nil, "zbr_gametype" ) then
        CoD.old_zbr_gametype = Engine.DvarString( nil, "zbr_gametype" )
        ZBR.ExecInLobbyVM([[
        if Lobby and Lobby.TeamSelection and Lobby.TeamSelection.Clear then
            Lobby.TeamSelection.Clear()
            Lobby.TeamSelection.SendChanges()
        end
    ]])
    end
    
    Engine.LuiVM_Event( "update_team_selection_buttons", {} )
end