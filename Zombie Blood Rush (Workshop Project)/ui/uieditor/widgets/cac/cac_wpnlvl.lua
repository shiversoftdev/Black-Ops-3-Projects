require( "ui.uieditor.widgets.CAC.WeaponMeterBacking" )
require( "ui.uieditor.widgets.Lobby.Common.FE_TitleNumBrdr" )
require( "ui.uieditor.widgets.Lobby.Common.FE_LabelSubHeadingB" )
require( "ui.uieditor.widgets.CAC.cac_WpnLvlMeter" )
require( "ui.uieditor.widgets.CAC.cac_LargePrestigeStars" )

CoD.cac_WpnLvl = InheritFrom( LUI.UIElement )
CoD.cac_WpnLvl.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
	self:setUseStencil( false )
	self:setClass( CoD.cac_WpnLvl )
	self.id = "cac_WpnLvl"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 415 )
	self:setTopBottom( true, false, 0, 40 )
    self:setAlpha(0);
	self.anyChildUsesUpdateState = true
	
	local WeaponMeterBacking = CoD.WeaponMeterBacking.new( menu, controller )
	WeaponMeterBacking:setLeftRight( true, false, 173, 339 )
	WeaponMeterBacking:setTopBottom( true, false, 9, 31 )
    WeaponMeterBacking:setAlpha(0);
	self:addElement( WeaponMeterBacking )
	self.WeaponMeterBacking = WeaponMeterBacking
	
	local levelBoxBg = CoD.FE_TitleNumBrdr.new( menu, controller )
	levelBoxBg:setLeftRight( true, true, 0, -275 )
	levelBoxBg:setTopBottom( false, false, -11, 11 )
    levelBoxBg:setAlpha(0)
	self:addElement( levelBoxBg )
	self.levelBoxBg = levelBoxBg
	
	local levelLabel = CoD.FE_LabelSubHeadingB.new( menu, controller )
	levelLabel:setLeftRight( true, false, 6, 138 )
	levelLabel:setTopBottom( true, false, 10.5, 29.5 )
	levelLabel:setRFTMaterial( LUI.UIImage.GetCachedMaterial( "uie_aberration_no_blur" ) )
	levelLabel:setShaderVector( 0, 0.05, 0, 0, 0 )
	levelLabel:setShaderVector( 1, 0, 0, 0, 0 )
	levelLabel:setShaderVector( 2, 0, 0, 0, 0 )
	levelLabel:setShaderVector( 3, 0, 0, 0, 0 )
	levelLabel:setShaderVector( 4, 0, 0, 0, 0 )
	levelLabel.Label1:setRGB( 0.71, 0.76, 0.77 )
	levelLabel.Label1:setText( Engine.Localize( "MPUI_WEAPON_LEVEL_CAPS" ) )
	levelLabel.Label1:setTTF( "fonts/escom.ttf" )
	levelLabel.Label1:setLetterSpacing( 3.6 )
    levelLabel:setAlpha(0)
	self:addElement( levelLabel )
	self.levelLabel = levelLabel
	
	local levelTextBg = LUI.UIImage.new()
	levelTextBg:setLeftRight( true, false, 142, 174 )
	levelTextBg:setTopBottom( true, false, 4, 36 )
	levelTextBg:setAlpha( 0 )
	levelTextBg:setImage( RegisterImage( "uie_t7_menu_cac_weaponmeterside" ) )
	levelTextBg:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( levelTextBg )
	self.levelTextBg = levelTextBg
	
	local bg = LUI.UIImage.new()
	bg:setLeftRight( false, false, -62.5, -36.5 )
	bg:setTopBottom( false, true, -31, -9 )
	bg:setAlpha( 0.25 )
	self:addElement( bg )
	self.bg = bg
	
	local bg0 = LUI.UIImage.new()
	bg0:setLeftRight( false, false, 132.5, 158.5 )
	bg0:setTopBottom( false, true, -31, -9 )
	bg0:setAlpha( 0.25 )
    bg0:setAlpha(0)
	self:addElement( bg0 )
	self.bg0 = bg0
	
	local currentLevelBacking = LUI.UITightText.new()
	currentLevelBacking:setLeftRight( false, false, -56.5, -42.5 )
	currentLevelBacking:setTopBottom( false, true, -30, -10 )
	currentLevelBacking:setText( Engine.Localize( "12" ) )
	currentLevelBacking:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
    currentLevelBacking:setAlpha(0)
	self:addElement( currentLevelBacking )
	self.currentLevelBacking = currentLevelBacking
	
	local currentLevel = LUI.UIText.new()
	currentLevel:setLeftRight( true, false, 127.5, 188.5 )
	currentLevel:setTopBottom( true, false, 10, 30 )
	currentLevel:setText( Engine.Localize( "12" ) )
	currentLevel:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
	currentLevel:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	currentLevel:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
    currentLevel:setAlpha(0)
	self:addElement( currentLevel )
	self.currentLevel = currentLevel
	
	local topRightDots = LUI.UIImage.new()
	topRightDots:setLeftRight( true, false, 379, 415 )
	topRightDots:setTopBottom( true, false, 4, 8 )
	topRightDots:setAlpha( 0.5 )
	topRightDots:setYRot( -180 )
	topRightDots:setImage( RegisterImage( "uie_t7_menu_frontend_pixelist" ) )
	topRightDots:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
    topRightDots:setAlpha(0)
	self:addElement( topRightDots )
	self.topRightDots = topRightDots
	
	local bottomRightDots = LUI.UIImage.new()
	bottomRightDots:setLeftRight( true, false, 379, 415 )
	bottomRightDots:setTopBottom( true, false, 35, 39 )
	bottomRightDots:setAlpha( 0.5 )
	bottomRightDots:setYRot( -180 )
	bottomRightDots:setImage( RegisterImage( "uie_t7_menu_frontend_pixelist" ) )
	bottomRightDots:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
    bottomRightDots:setAlpha(0)
	self:addElement( bottomRightDots )
	self.bottomRightDots = bottomRightDots
	
	local rightBox = LUI.UIImage.new()
	rightBox:setLeftRight( true, false, 197, 373 )
	rightBox:setTopBottom( true, false, 0, 40 )
	rightBox:setImage( RegisterImage( "uie_t7_menu_cac_weaponmeterframe" ) )
	rightBox:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
    rightBox:setAlpha(0)
	self:addElement( rightBox )
	self.rightBox = rightBox
	
	local cacWpnLvlMeter0 = CoD.cac_WpnLvlMeter.new( menu, controller )
	cacWpnLvlMeter0:setLeftRight( true, false, 170, 339 )
	cacWpnLvlMeter0:setTopBottom( true, false, 4, 36 )
	cacWpnLvlMeter0:setRFTMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	cacWpnLvlMeter0.Meter:setShaderVector( 0, 0.65, 0, 0, 0 )
	cacWpnLvlMeter0.Meter2XP:setShaderVector( 0, 0.65, 0, 0, 0 )
    cacWpnLvlMeter0:setAlpha(0)
	self:addElement( cacWpnLvlMeter0 )
	self.cacWpnLvlMeter0 = cacWpnLvlMeter0
	
	local weaponLevel = LUI.UIText.new()
	weaponLevel:setLeftRight( false, false, -124.5, -88.5 )
	weaponLevel:setTopBottom( false, true, -30, -10 )
	weaponLevel:setRGB( 0, 0, 0 )
	weaponLevel:setAlpha( 0 )
	weaponLevel:setText( Engine.Localize( "MPUI_MAX_CAPS" ) )
	weaponLevel:setTTF( "fonts/default.ttf" )
	weaponLevel:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	weaponLevel:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
    weaponLevel:setAlpha(0)
	self:addElement( weaponLevel )
	self.weaponLevel = weaponLevel
	
	local levelTextBg0 = LUI.UIImage.new()
	levelTextBg0:setLeftRight( true, false, 337, 369 )
	levelTextBg0:setTopBottom( true, false, 4, 36 )
	levelTextBg0:setAlpha( 0 )
	levelTextBg0:setImage( RegisterImage( "uie_t7_menu_cac_weaponmeterside" ) )
	levelTextBg0:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
    levelTextBg0:setAlpha(0)
	self:addElement( levelTextBg0 )
	self.levelTextBg0 = levelTextBg0
	
	local nextLevel = LUI.UIText.new()
	nextLevel:setLeftRight( true, false, 322.81, 383.81 )
	nextLevel:setTopBottom( true, false, 10, 30 )
	nextLevel:setText( Engine.Localize( "13" ) )
	nextLevel:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
	nextLevel:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	nextLevel:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
    nextLevel:setAlpha(0)
	self:addElement( nextLevel )
	self.nextLevel = nextLevel
	
	local cacLargePrestigeStars0 = CoD.cac_LargePrestigeStars.new( menu, controller )
	cacLargePrestigeStars0:setLeftRight( true, false, 373, 389 )
	cacLargePrestigeStars0:setTopBottom( true, false, 4, 36 )
	cacLargePrestigeStars0:setScale( 0.8 )
    cacLargePrestigeStars0:setAlpha(0)
	cacLargePrestigeStars0:linkToElementModel( self, nil, false, function ( modelRef )
		cacLargePrestigeStars0:setModel( modelRef, controller )
	end )
	self:addElement( cacLargePrestigeStars0 )
	self.cacLargePrestigeStars0 = cacLargePrestigeStars0
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				
			end,
			Intro = function ()
				
			end
		},
		DisplayLevel = {
			DefaultClip = function ()
				
			end,
			Intro = function ()
				
			end
		},
		MaxLevel = {
			DefaultClip = function ()
				
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "DisplayLevel",
			condition = function ( menu, element, event )
				local f44_local0 = IsCurrentMenuWeaponType( menu )
				if f44_local0 then
					f44_local0 = IsCACGunLevelExists( self, element, controller )
					if f44_local0 then
						f44_local0 = not IsCACGunLevelMax( self, element, controller )
					end
				end
				return f44_local0
			end
		},
		{
			stateName = "MaxLevel",
			condition = function ( menu, element, event )
				local f45_local0 = IsCurrentMenuWeaponType( menu )
				if f45_local0 then
					f45_local0 = IsCACGunLevelExists( self, element, controller )
					if f45_local0 then
						f45_local0 = IsCACGunLevelMax( self, element, controller )
					end
				end
				return f45_local0
			end
		}
	} )
	self:linkToElementModel( self, "itemIndex", true, function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "itemIndex"
		} )
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.WeaponMeterBacking:close()
		element.levelBoxBg:close()
		element.levelLabel:close()
		element.cacWpnLvlMeter0:close()
		element.cacLargePrestigeStars0:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end

