require( "ui.uieditor.widgets.CAC.GridItemBGBGlow" )
require( "ui.uieditor.widgets.CAC.GridItemConsumableLabel" )

local PostLoadFunc = function ( self, controller, menu )
	local f1_local0 = CoD.SafeGetModelValue( self:getModel(), "itemIndex" )
	if f1_local0 then
		Engine.SetModelValue( Engine.GetModel( self:getModel(), "remaining" ), GetConsumableCountFromIndex( controller, f1_local0 ) )
	end
	self.ConsumableLabel:subscribeToGlobalModel( controller, "PerController", "scriptNotify", function ( modelRef )
		if IsParamModelEqualToString( modelRef, "zombie_bgb_used" ) then
			local f2_local0 = CoD.GetScriptNotifyData( modelRef )
			local f2_local1 = CoD.SafeGetModelValue( self:getModel(), "itemIndex" )
			if f2_local1 and f2_local0[1] == f2_local1 then
				local f2_local2 = Engine.GetModel( self:getModel(), "remaining" )
				local f2_local3 = Engine.GetModelValue( f2_local2 )
				if f2_local3 > 0 then
					f2_local3 = f2_local3 - 1
				end
				Engine.SetModelValue( f2_local2, f2_local3 )
			end
		end
	end )
end

CoD.BubbleGumBuffInGame = InheritFrom( LUI.UIElement )
CoD.BubbleGumBuffInGame.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
	self:setUseStencil( false )
	self:setClass( CoD.BubbleGumBuffInGame )
	self.id = "BubbleGumBuffInGame"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 64 )
	self:setTopBottom( true, false, 0, 109 )
	self.anyChildUsesUpdateState = true
	
	local GridItemBGBGlow = CoD.GridItemBGBGlow.new( menu, controller )
	GridItemBGBGlow:setLeftRight( true, true, -10, 10 )
	GridItemBGBGlow:setTopBottom( true, true, -10, -35 )
	GridItemBGBGlow:linkToElementModel( self, nil, false, function ( modelRef )
		GridItemBGBGlow:setModel( modelRef, controller )
	end )
	self:addElement( GridItemBGBGlow )
	self.GridItemBGBGlow = GridItemBGBGlow
	
	local BubbleGumBuffImage = LUI.UIImage.new()
	BubbleGumBuffImage:setLeftRight( false, false, -32, 32 )
	BubbleGumBuffImage:setTopBottom( true, false, 0, 64 )
	BubbleGumBuffImage:setScale( 0.9 )
	self:addElement( BubbleGumBuffImage )
	self.BubbleGumBuffImage = BubbleGumBuffImage
	
	local BubbleGumBuffName = LUI.UIText.new()
	BubbleGumBuffName:setLeftRight( false, false, -32, 32 )
	BubbleGumBuffName:setTopBottom( true, false, 60, 76 )
	BubbleGumBuffName:setTTF( "fonts/default.ttf" )
	BubbleGumBuffName:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	BubbleGumBuffName:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
	self:addElement( BubbleGumBuffName )
	self.BubbleGumBuffName = BubbleGumBuffName
	
	local ConsumableLabel = CoD.GridItemConsumableLabel.new( menu, controller )
	ConsumableLabel:setLeftRight( true, false, 2, 24 )
	ConsumableLabel:setTopBottom( true, false, 5.75, 23.75 )
	ConsumableLabel:setScale( 0.8 )
	ConsumableLabel:linkToElementModel( self, nil, false, function ( modelRef )
		ConsumableLabel:setModel( modelRef, controller )
	end )
	ConsumableLabel:mergeStateConditions( {
		{
			stateName = "Nocomsumable",
			condition = function ( menu, element, event )
				return IsSelfModelValueNilOrZero( element, controller, "remaining" )
			end
		}
	} )
	ConsumableLabel:linkToElementModel( ConsumableLabel, "itemIndex", true, function ( modelRef )
		menu:updateElementState( ConsumableLabel, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "itemIndex"
		} )
	end )
	ConsumableLabel:linkToElementModel( ConsumableLabel, "remaining", true, function ( modelRef )
		menu:updateElementState( ConsumableLabel, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "remaining"
		} )
	end )
	self:addElement( ConsumableLabel )
	self.ConsumableLabel = ConsumableLabel
	
	self.BubbleGumBuffImage:linkToElementModel( self, "itemIndex", true, function ( modelRef )
		local itemIndex = Engine.GetModelValue( modelRef )
		if itemIndex then
			BubbleGumBuffImage:setImage( RegisterImage( GetItemImageFromIndex( itemIndex ) ) )
		end
	end )
	self.BubbleGumBuffName:linkToElementModel( self, "itemIndex", true, function ( modelRef )
		local itemIndex = Engine.GetModelValue( modelRef )
		if itemIndex then
			BubbleGumBuffName:setText( Engine.Localize( GetItemNameFromIndex( itemIndex ) ) )
		end
	end )
	self.ConsumableLabel:linkToElementModel( self, "remaining", true, function ( modelRef )
		local remaining = Engine.GetModelValue( modelRef )
		if remaining then
			ConsumableLabel.ComsumableCountLabel:setText( Engine.Localize( remaining ) )
		end
	end )
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 2 )
				GridItemBGBGlow:completeAnimation()
				self.GridItemBGBGlow:setAlpha( 1 )
				self.clipFinished( GridItemBGBGlow, {} )
				BubbleGumBuffImage:completeAnimation()
				self.BubbleGumBuffImage:setAlpha( 1 )
				self.clipFinished( BubbleGumBuffImage, {} )
			end
		},
		OutOfBubbleGum = {
			DefaultClip = function ()
				self:setupElementClipCounter( 2 )
				GridItemBGBGlow:completeAnimation()
				self.GridItemBGBGlow:setAlpha( 0.25 )
				self.clipFinished( GridItemBGBGlow, {} )
				BubbleGumBuffImage:completeAnimation()
				self.BubbleGumBuffImage:setAlpha( 0.5 )
				self.clipFinished( BubbleGumBuffImage, {} )
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "OutOfBubbleGum",
			condition = function ( menu, element, event )
				local f14_local0 = IsSelfModelValueNilOrZero( element, controller, "remaining" )
				if f14_local0 then
					f14_local0 = IsCACItemConsumable( menu, element, controller )
				end
				return f14_local0
			end
		}
	} )
	self:linkToElementModel( self, "remaining", true, function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "remaining"
		} )
	end )
	self:linkToElementModel( self, "itemIndex", true, function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "itemIndex"
		} )
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.GridItemBGBGlow:close()
		element.ConsumableLabel:close()
		element.BubbleGumBuffImage:close()
		element.BubbleGumBuffName:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end

