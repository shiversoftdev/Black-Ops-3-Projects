/*
    serious bo3 utility
    youtube.com/anthonything
    
    Note: Please remember to thread SeriousUtil() in your init function, or some functions will not work correctly.
*/

#include scripts\shared\hud_util_shared;
#include scripts\shared\hud_shared;

#region Defines
    #define SL_BEGIN_ARCHIVE = 19;
    
    #region buttons
    #define SL_BUTTONS_AS_1   = 0x0;
    #define SL_BUTTONS_AS_2   = 0x1;
    #define SL_BUTTONS_AS_3   = 0x2;
    #define SL_BUTTONS_AS_4   = 0x3;
    #define SL_BUTTONS_JUMP   = 0x4;
    #define SL_BUTTONS_STANCE = 0x5;
    #define SL_BUTTONS_SPRINT = 0x6;
    #define SL_BUTTONS_WNEXT  = 0x7;
    #define SL_BUTTONS_USE    = 0x8;
    #define SL_BUTTONS_MELEE  = 0x9;
    #define SL_BUTTONS_ADS    = 0xA;
    #define SL_BUTTONS_ATTACK = 0xB;
    #define SL_BUTTONS_TAC    = 0xC;
    #define SL_BUTTONS_FRAG   = 0xD;
    #endregion
#endregion

#region Functions
    
// [CALLER] Player
// [Name] Option name text. {Name} On, Off
// [OnFunc] Function to invoke when enabled
// [OffFunc] Function to invoke when disabled
// [Entity?] Object to call the functions on.
// [a-e] Optional Target Arguments
// Synchronously toggle a variable on an entity.
SimpleToggle(Name, OnFunc, OffFunc, Entity = self, a, b, c, d, e)
{
    if(!isdefined(Entity.togglevars))
        Entity.togglevars = [];
        
    Entity.togglevars[Name] = !bool(Entity.togglevars[Name]);
    
    Entity thread ExecOption(Entity.togglevars[Name] ? OnFunc : OffFunc, array(a, b, c, d, e));
    self iPrintLnBold(Name + (Entity.togglevars[Name] ? " ^2Enabled" : " ^1Disabled"));
}

// [CALLER] player
// [Name] Name of the option
// Return the toggle state of an option
GetToggleState(Name)
{
    if(!isdefined(self.togglevars))
        return false;
    return bool(self.togglevars[Name]);
}

// [Caller] Entity
// [SYNCHRONOUS]
// [f] Function to invoke
// [a] Args
ExecOption(f, a)
{
    if(!isdefined(f))
        return;
     
    if(!isdefined(a))
        a = [];
        
    if(!isarray(a))
        a = [];
        
    switch(true)
    {
        case isdefined(a[9]): self [[f]](a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9]); break;
        case isdefined(a[8]): self [[f]](a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8]); break;
        case isdefined(a[7]): self [[f]](a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]); break;
        case isdefined(a[6]): self [[f]](a[0], a[1], a[2], a[3], a[4], a[5], a[6]); break;
        case isdefined(a[5]): self [[f]](a[0], a[1], a[2], a[3], a[4], a[5]); break;
        case isdefined(a[4]): self [[f]](a[0], a[1], a[2], a[3], a[4]); break;
        case isdefined(a[3]): self [[f]](a[0], a[1], a[2], a[3]); break;
        case isdefined(a[2]): self [[f]](a[0], a[1], a[2]); break;
        case isdefined(a[1]): self [[f]](a[0], a[1]); break;
        case isdefined(a[0]): self [[f]](a[0]); break;
        default: self [[f]](); break;
    }
}
    
// [CALLER] player
// [button] The button to check. See Defines->Buttons for the list of buttons available.
// determine if a player has pressed a given button.
IsButtonPressed(button)
{
    // builtins
    switch(button)
    {
        case SL_BUTTONS_AS_1:
            return self ActionSlotOneButtonPressed();
        case SL_BUTTONS_AS_2:
            return self ActionSlotTwoButtonPressed();
        case SL_BUTTONS_AS_3:
            return self ActionSlotThreeButtonPressed();
        case SL_BUTTONS_AS_4:
            return self ActionSlotFourButtonPressed();
        case SL_BUTTONS_JUMP:
            return self JumpButtonPressed();
        case SL_BUTTONS_STANCE:
            return self StanceButtonPressed();
        case SL_BUTTONS_SPRINT:
            return self SprintButtonPressed();
        case SL_BUTTONS_WNEXT:
            return self changeseatbuttonpressed();
        case SL_BUTTONS_USE:
            return self UseButtonPressed();
        case SL_BUTTONS_MELEE:
            return self MeleeButtonPressed();
        case SL_BUTTONS_ADS:
            return self AdsButtonPressed();
        case SL_BUTTONS_ATTACK:
            return self AttackButtonPressed();
        case SL_BUTTONS_TAC:
            return self SecondaryOffhandButtonPressed();
        default:
            return self FragButtonPressed();
    }
    
    // shouldnt be possible but may as well
    return false;
}

// [CALLER] none
// [variable] the variable to convert into a bool
// Safely determine if the input variable is true
bool(variable)
{
    return isdefined(variable) && int(variable);
}

// [CALLER] none
// [variable] the variable to convert to an integer
// Safely convert a variable to an integer (will never return undefined)
integer(variable)
{
    if(!isdefined(int(variable)))
        return 0;
        
    return int(variable);
}

// [CALLER] player
// [shader] The shader to draw (image). Note: This must be precached in init using 'precacheshader' for it to show up correctly.
// [x] X position of the shader (relative to the align input)
// [y] Y position of the shader (relative to the align input)
// [width] Width of the shader
// [height] Height of the shader
// [color] Tint of the shader
// [alpha] The opacity of the shader (0 to 1 scaled, 1 being completely opaque, and 0 being invisible)
// [sort] Z position of the shader (a higher sort will be drawn over a lower sort)
// [?align] The alignment to use when drawing the position of the element relative to its size. (center means to subtract half the width/height from the draw pos)
// [?relative] The relative position to use when placing the element on the screen (ie: TOPRIGHT)
// [?isLevel] Determines if the hud element is to be drawn on a specific client, or for all clients.
// Create an icon and return it.
Icon(shader, x, y, width, height, color, alpha, sort, align = "center", relative = "center", isLevel = false)
{
    if(isLevel)
        icon = hud::createServerIcon(shader, width, height);
    else
        icon = self hud::createIcon(shader, width, height);
    
    icon SetScreenPoint(align, relative, x, y);
    
    icon.color          = color;
    icon.alpha          = alpha;
    icon.sort           = sort;
    
    icon.hideWhenInMenu = true;
    
    self.sl_hudct = integer(self.sl_hudct + 1);
    icon.archived = (self.sl_hudct > SL_BEGIN_ARCHIVE);
    icon thread SLHudRemove(self);
    
    return icon;
}

// [CALLER] player
// [string] The text you want the string to display
// [x] X position of the text (relative to the align input)
// [y] Y position of the text (relative to the align input)
// [font] The font of the text
// [fontscale] The scale of the font for the text
// [color] The color tint of the text
// [alpha] The opacity of the text (0 to 1 scaled, 1 being completely opaque, and 0 being invisible)
// [sort] Z position of the text (a higher sort will be drawn over a lower sort)
// [?align] The alignment to use when drawing the position of the element relative to its size. (center means to subtract half the width/height from the draw pos)
// [?relative] The relative position to use when placing the element on the screen (ie: TOPRIGHT)
// [?isLevel] Determines if the hud element is to be drawn on a specific client, or for all clients.
// Create a text element and return it.
Text(string = "", x, y, font, fontScale, color, alpha, sort, align = "center", relative = "center", isLevel = false)
{
    if(isLevel)
    text = self hud::createServerFontString(font, fontScale);
    else
        text = self hud::createFontString(font, fontScale);
    
    text SetScreenPoint(align, relative, x, y);
    text SetText(string);
    
    text.color          = color;
    text.alpha          = alpha;
    text.sort           = sort;
    
    text.hideWhenInMenu = true;
    
    self.sl_hudct = integer(self.sl_hudct + 1);
    text.archived = (self.sl_hudct > SL_BEGIN_ARCHIVE);
    text thread SLHudRemove(self);

    return text;
}

// [CALLER] none
// [value] The RGB color component to convert
// Convert a hex integer into a color vector
color(value)
{
    /*
        Size constraints comment:
        
        Why is this better than rgb = (r,g,b) => return (r/255, g/255, b/255)?
        
        This will emit PSC, GetInt, align(4), value, SFT, align(1 + pos, 4), 4
        rgb... emits PSC, {GetInt, align(4), value}[3], SFT, align(1 + pos, 4), 4
        Vector emits Vec, align(4), r as float, b as float, g as float 
        
        color:  Min: 14, Max: 17
        rgb:    Min: 30, Max: 33
        vector: Min: 13, Max: 16
    */

    return
    (
    (value & 0xFF0000) / 0xFF0000,
    (value & 0x00FF00) / 0x00FF00,
    (value & 0x0000FF) / 0x0000FF
    );
}

// [CALLER] Hud Element
// [point] The alignment to use when drawing the position of the element relative to its size. (center means to subtract half the width/height from the draw pos)
// [relativePoint] The relative position to use when placing the element on the screen (ie: TOPRIGHT)
// [xOffset] Horizontal position relative to the element's parent
// [yOffset] Vertical position relative to the element's parent
// [moveTime] Time that the element will take to reach its destination
// Setpoint, but without being relative adjustable
SetScreenPoint(point, relativePoint, xOffset, yOffset, moveTime)
{
    self hud::setPoint(point, relativePoint, xOffset, yOffset, moveTime);
}

// [CALLER] none
// [array] array to modify
// [item] item to add to the array
// [?allow_dupes] if false, the element will only be added if it is not already in the array
// Add an element to an array and return the new array.  
ArrayAdd(array, item, allow_dupes = 1)
{
    if(isdefined(item))
    {
        if(allow_dupes || !IsInArray(array, item))
        {
            array[array.size] = item;
        }
    }
    return array;
}

// [CALLER] none
// [array] array to clean
// Remove any undefined values from an array and return the new array.
ArrayRemoveUndefined(array)
{
    a_new = [];
    foreach(elem in array)
        if(isdefined(elem))
            a_new[a_new.size] = elem;
            
    return a_new;
}

// [CALLER] none
// [array] array to clean
// [value] value to remove from the array
// Remove all instances of value in array
ArrayRemove(array, value)
{
    a_new = [];
    
    foreach(elem in array)
        if(value != elem)
            a_new[a_new.size] = elem;
            
    return a_new;
}

// [CALLER] none
// [array] array to change
// [index] index to use to insert the value
// [value] value to insert into the array
// Insert a value into an array
ArrayInsertValue(array, index, value)
{
    a_new = [];
    
    for(i = 0; i < index; i++)
    {
        a_new[i] = array[i];
    }
    
    a_new[index] = value;
    
    for(i = index + 1; i <= array.size; i++)
    {
        a_new[i] = array[i - 1];
    }
    
    return a_new;
}

// [CALLER] none
// [array] array to search
// [value] value to search for
// Find the index of a value in an array. If the value isnt found, return -1
ArrayIndexOf(array, value)
{
     for(i = 0; i < array.size; i++)
        if(isdefined(array[i]) && value == array[i])
            return i;
            
    return -1;
}
#endregion

#region Internal
// [INTERNAL] - should not be called manually
// [CALLER] level
// the main method of the serious util. this must be called in init()
SeriousUtil()
{
    if(isdefined(level.sinit))
        return;
    
    level.sinit = true;
}

// [INTERNAL] -- should not be called manually
// [CALLER] hud element
// [player] Owning player for the calling hud
// when the caller is deleted, decrements the player sl hud counter
SLHudRemove(player)
{
    player endon("disconnect");
    self waittill("death");
    
    if(!isdefined(player.sl_hudct))
        return;
    
    player.sl_hudct--;
}
#endregion
