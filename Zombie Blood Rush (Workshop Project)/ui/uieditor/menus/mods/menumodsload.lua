require( "ui.uieditor.widgets.backgrounds.MP_Background" )
require( "ui.uieditor.widgets.Lobby.Common.FE_TabIdle" )
require( "ui.uieditor.widgets.Mods.WidgetModsLoad" )
require( "ui.uieditor.widgets.Lobby.Common.FE_Menu_LeftGraphics" )
require( "ui.uieditor.widgets.BackgroundFrames.GenericMenuFrame" )

local PreLoadFunc = function ( self, controller )
	Engine.Mods_Lists_UpdateMods()
end

LUI.createMenu.MenuModsLoad = function ( controller )
	Engine.ComError( Enum.errorCode.ERROR_UI, "Zombie Blood Rush cannot be unloaded manually. Please restart your game.")
	return nil
end

