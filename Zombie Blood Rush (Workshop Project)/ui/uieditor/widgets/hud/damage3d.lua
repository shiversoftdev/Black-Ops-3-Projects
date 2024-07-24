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
    
    local damage3d = LUI.UI3DText.new(
        {
            alpha = 1
        })

    -- table.insert(damage3dlist, damage3d)

    -- if(#damage3dlist > 40) then
    --     table.remove(damage3dlist, 1):close()
    -- end

    local text = event_data.packed_origin
    if event_data.amount < 1 then
        text = text .. "immune"
    else
        text = text .. format_int(event_data.amount)
    end
    
    damage3d:setRGB(color_from_type(event_data.type))
    damage3d:setText(text)
    damage3d:setTTF( "fonts/default.ttf" )

    LUI.roots.UIRootFull:addElement(damage3d)
    damage3d:setLeftRight( true, false, 0, 300 )
	damage3d:setTopBottom( true, false, 0, 0 )
    damage3d:setAlignment(LUI.Alignment.Center)

    damage3d:beginAnimation( "keyframe", 1000, false, false, CoD.TweenType.Linear )
    damage3d:registerEventHandler( "transition_complete_keyframe", function()
        damage3d:close()
        -- local indx = indexOf(damage3dlist, damage3d)
        -- if indx ~= nil then
        --     table.remove(damage3dlist, indx)
        -- end
    end)
end

CoD.LobbyCharacterEvent = function(event_data)
end

CoD.LobbyCharacterEmote = function(event_data)
end

CoD.GametypeUpdateEvent = function(event_data)
end