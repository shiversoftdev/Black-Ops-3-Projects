require( "ui.uieditor.widgets.Craft.WeaponBuildKits.WeaponBuildKitsVariantAttachments" )
require( "ui.uieditor.widgets.CAC.cac_WpnLvl" )

CoD.WeaponBuildKitsVariantAttachmentList = InheritFrom( LUI.UIElement )
CoD.WeaponBuildKitsVariantAttachmentList.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
	self:setUseStencil( false )
	self:setClass( CoD.WeaponBuildKitsVariantAttachmentList )
	self.id = "WeaponBuildKitsVariantAttachmentList"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 1280 )
	self:setTopBottom( true, false, 0, 720 )
	self:makeFocusable()
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	local variantAttachments = CoD.WeaponBuildKitsVariantAttachments.new( menu, controller )
	variantAttachments:setLeftRight( false, false, -566.47, 240.87 )
	variantAttachments:setTopBottom( false, true, -181.87, -81.87 )
	variantAttachments:linkToElementModel( self, nil, false, function ( modelRef )
		variantAttachments:setModel( modelRef, controller )
	end )
	self:addElement( variantAttachments )
	self.variantAttachments = variantAttachments
	
	local cacWpnLvl = CoD.cac_WpnLvl.new( menu, controller )
	cacWpnLvl:setLeftRight( true, false, 99999.87, 99999.87 )
	cacWpnLvl:setTopBottom( false, true, 1, 1 )
	cacWpnLvl.levelLabel.Label1:setText( Engine.Localize( "MPUI_WEAPON_LEVEL_CAPS" ) )
	cacWpnLvl.levelLabel.Label1:setTTF( "fonts/escom.ttf" )
	self:addElement( cacWpnLvl )
	self.cacWpnLvl = cacWpnLvl
	
	variantAttachments.id = "variantAttachments"
	self:registerEventHandler( "gain_focus", function ( element, event )
		if element.m_focusable and element.variantAttachments:processEvent( event ) then
			return true
		else
			return LUI.UIElement.gainFocus( element, event )
		end
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.variantAttachments:close()
		element.cacWpnLvl:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end

