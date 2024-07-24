require( "ui.cards.CallingCards_RedFrame" )

CoD.CallingCards_ZBR_Invitationals_2021 = InheritFrom( LUI.UIElement )
CoD.CallingCards_ZBR_Invitationals_2021.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( true )
	self:setClass( CoD.CallingCards_ZBR_Invitationals_2021 )
	self.id = "CallingCards_ZBR_Invitationals_2021"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 480 )
	self:setTopBottom( true, false, 0, 120 )
	self.anyChildUsesUpdateState = true
	
	local Image0 = LUI.UIImage.new()
	Image0:setLeftRight( true, false, 0, 480 )
	Image0:setTopBottom( true, false, 0, 120 )
	Image0:setImage( RegisterImage( "t7_zbr_callingcard_invite_2021" ) )
	self:addElement( Image0 )
	self.Image0 = Image0
	
	local CallingCards_RedFrame = CoD.CallingCards_RedFrame.new( menu, controller )
	CallingCards_RedFrame:setLeftRight( true, true, 0, 0 )
	CallingCards_RedFrame:setTopBottom( true, true, 0, 0 )
	self:addElement( CallingCards_RedFrame )
	self.CallingCards_RedFrame = CallingCards_RedFrame
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 6 )
				
				CallingCards_RedFrame:completeAnimation()
				self.CallingCards_RedFrame:setAlpha( 1 )
				self.clipFinished( CallingCards_RedFrame, {} )
				self.nextClip = "DefaultClip"
			end
		}
	}
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.CallingCards_RedFrame:close()
	end )	
	return self
end

CoD.CallingCards_ZBR_Z4C_2024 = InheritFrom( LUI.UIElement )
CoD.CallingCards_ZBR_Z4C_2024.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( true )
	self:setClass( CoD.CallingCards_ZBR_Z4C_2024 )
	self.id = "CallingCards_ZBR_Z4C_2024"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 480 )
	self:setTopBottom( true, false, 0, 120 )
	self.anyChildUsesUpdateState = true
	
	local Image0 = LUI.UIImage.new()
	Image0:setLeftRight( true, false, 0, 480 )
	Image0:setTopBottom( true, false, 0, 120 )
	Image0:setImage( RegisterImage( "t7_zbr_callingcard_z4c_0" ) )
	self:addElement( Image0 )
	self.Image0 = Image0
	
	local CallingCards_RedFrame = CoD.CallingCards_RedFrame.new( menu, controller )
	CallingCards_RedFrame:setLeftRight( true, true, 0, 0 )
	CallingCards_RedFrame:setTopBottom( true, true, 0, 0 )
	self:addElement( CallingCards_RedFrame )
	self.CallingCards_RedFrame = CallingCards_RedFrame
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 6 )
				
				CallingCards_RedFrame:completeAnimation()
				self.CallingCards_RedFrame:setAlpha( 1 )
				self.clipFinished( CallingCards_RedFrame, {} )
				self.nextClip = "DefaultClip"
			end
		}
	}
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.CallingCards_RedFrame:close()
	end )	
	return self
end

CoD.CallingCards_ZBR_Z4C_2024_WINNER = InheritFrom( LUI.UIElement )
CoD.CallingCards_ZBR_Z4C_2024_WINNER.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( true )
	self:setClass( CoD.CallingCards_ZBR_Z4C_2024_WINNER )
	self.id = "CallingCards_ZBR_Z4C_2024_WINNER"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 480 )
	self:setTopBottom( true, false, 0, 120 )
	self.anyChildUsesUpdateState = true
	
	local Image0 = LUI.UIImage.new()
	Image0:setLeftRight( true, false, 0, 480 )
	Image0:setTopBottom( true, false, 0, 120 )
	Image0:setImage( RegisterImage( "t7_zbr_callingcard_z4c_1" ) )
	self:addElement( Image0 )
	self.Image0 = Image0
	
	local CallingCards_RedFrame = CoD.CallingCards_RedFrame.new( menu, controller )
	CallingCards_RedFrame:setLeftRight( true, true, 0, 0 )
	CallingCards_RedFrame:setTopBottom( true, true, 0, 0 )
	self:addElement( CallingCards_RedFrame )
	self.CallingCards_RedFrame = CallingCards_RedFrame
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 6 )
				
				CallingCards_RedFrame:completeAnimation()
				self.CallingCards_RedFrame:setAlpha( 1 )
				self.clipFinished( CallingCards_RedFrame, {} )
				self.nextClip = "DefaultClip"
			end
		}
	}
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.CallingCards_RedFrame:close()
	end )	
	return self
end