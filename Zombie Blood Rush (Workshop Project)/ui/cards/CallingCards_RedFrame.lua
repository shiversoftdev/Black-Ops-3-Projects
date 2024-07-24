CoD.CallingCards_RedFrame = InheritFrom( LUI.UIElement )
CoD.CallingCards_RedFrame.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.CallingCards_RedFrame )
	self.id = "CallingCards_RedFrame"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 480 )
	self:setTopBottom( true, false, 0, 120 )
	
	local frame = LUI.UIImage.new()
	frame:setLeftRight( true, false, 0, 480 )
	frame:setTopBottom( true, false, 0, 120 )
	frame:setImage( RegisterImage( "uie_t7_callingcard_goldframe" ) )
    frame:setRGB(1, 0.15, 0.15)
	frame:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
	self:addElement( frame )
	self.frame = frame
	
	local frameglint = LUI.UIImage.new()
	frameglint:setLeftRight( true, false, 0, 480 )
	frameglint:setTopBottom( true, false, 0, 120 )
	frameglint:setRGB( 1, 0.27, 0.12 )
	frameglint:setImage( RegisterImage( "uie_t7_callingcard_goldframe" ) )
	frameglint:setMaterial( LUI.UIImage.GetCachedMaterial( "sw4_2d_bitchin_glint_reveal" ) )
	frameglint:setShaderVector( 0, 0.13, 0, 0, 0 )
	self:addElement( frameglint )
	self.frameglint = frameglint
	
	local Glow = LUI.UIImage.new()
	Glow:setLeftRight( true, false, 264.33, 254.67 )
	Glow:setTopBottom( true, false, -204.7, 209 )
	Glow:setRGB( 1, 0.59, 0.55 )
	Glow:setZRot( 90 )
	Glow:setImage( RegisterImage( "uie_t7_core_hud_mapwidget_panelglow" ) )
	Glow:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( Glow )
	self.Glow = Glow
	
	local GlowSmallCorner = LUI.UIImage.new()
	GlowSmallCorner:setLeftRight( true, false, 12.67, -3 )
	GlowSmallCorner:setTopBottom( true, false, 107.3, 123 )
	GlowSmallCorner:setRGB( 1, 0.59, 0.55 )
	GlowSmallCorner:setZRot( 90 )
	GlowSmallCorner:setImage( RegisterImage( "uie_t7_core_hud_mapwidget_panelglow" ) )
	GlowSmallCorner:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( GlowSmallCorner )
	self.GlowSmallCorner = GlowSmallCorner
	
	local GlowSmallCorner2 = LUI.UIImage.new()
	GlowSmallCorner2:setLeftRight( true, false, 484, 468.33 )
	GlowSmallCorner2:setTopBottom( true, false, -3, 12.7 )
	GlowSmallCorner2:setRGB( 1, 0.59, 0.55 )
	GlowSmallCorner2:setZRot( 90 )
	GlowSmallCorner2:setImage( RegisterImage( "uie_t7_core_hud_mapwidget_panelglow" ) )
	GlowSmallCorner2:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( GlowSmallCorner2 )
	self.GlowSmallCorner2 = GlowSmallCorner2
	
	local GlowSmallCenter3 = LUI.UIImage.new()
	GlowSmallCenter3:setLeftRight( true, false, 329, 313.33 )
	GlowSmallCenter3:setTopBottom( true, false, -5.7, 10 )
	GlowSmallCenter3:setRGB( 1, 0.59, 0.55 )
	GlowSmallCenter3:setZRot( 90 )
	GlowSmallCenter3:setImage( RegisterImage( "uie_t7_core_hud_mapwidget_panelglow" ) )
	GlowSmallCenter3:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( GlowSmallCenter3 )
	self.GlowSmallCenter3 = GlowSmallCenter3
	
	local GlowSmallCorner4 = LUI.UIImage.new()
	GlowSmallCorner4:setLeftRight( true, false, 484, 468.33 )
	GlowSmallCorner4:setTopBottom( true, false, 107.3, 123 )
	GlowSmallCorner4:setRGB( 1, 0.59, 0.55 )
	GlowSmallCorner4:setAlpha( 0 )
	GlowSmallCorner4:setZRot( 90 )
	GlowSmallCorner4:setScale( 0.2 )
	GlowSmallCorner4:setImage( RegisterImage( "uie_t7_core_hud_mapwidget_panelglow" ) )
	GlowSmallCorner4:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( GlowSmallCorner4 )
	self.GlowSmallCorner4 = GlowSmallCorner4
	
	local GlowSmallCorner5 = LUI.UIImage.new()
	GlowSmallCorner5:setLeftRight( true, false, 12.67, -3 )
	GlowSmallCorner5:setTopBottom( true, false, -3, 12.7 )
	GlowSmallCorner5:setRGB( 1, 0.59, 0.55 )
	GlowSmallCorner5:setAlpha( 0 )
	GlowSmallCorner5:setZRot( 90 )
	GlowSmallCorner5:setScale( 0.5 )
	GlowSmallCorner5:setImage( RegisterImage( "uie_t7_core_hud_mapwidget_panelglow" ) )
	GlowSmallCorner5:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( GlowSmallCorner5 )
	self.GlowSmallCorner5 = GlowSmallCorner5
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 8 )
				frame:completeAnimation()
				self.frame:setAlpha( 1 )
				self.clipFinished( frame, {} )
				local f2_local0 = function ( f3_arg0, f3_arg1 )
					local f3_local0 = function ( f4_arg0, f4_arg1 )
						if not f4_arg1.interrupted then
							f4_arg0:beginAnimation( "keyframe", 100, false, false, CoD.TweenType.Linear )
						end
						f4_arg0:setAlpha( 0 )
						f4_arg0:setMaterial( LUI.UIImage.GetCachedMaterial( "sw4_2d_bitchin_glint_reveal" ) )
						f4_arg0:setShaderVector( 0, 1.2, 0, 0, 0 )
						if f4_arg1.interrupted then
							self.clipFinished( f4_arg0, f4_arg1 )
						else
							f4_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f3_arg1.interrupted then
						f3_local0( f3_arg0, f3_arg1 )
						return 
					else
						f3_arg0:beginAnimation( "keyframe", 839, false, false, CoD.TweenType.Linear )
						f3_arg0:setShaderVector( 0, 1.2, 0, 0, 0 )
						f3_arg0:registerEventHandler( "transition_complete_keyframe", f3_local0 )
					end
				end
				
				frameglint:completeAnimation()
				self.frameglint:setAlpha( 0.4 )
				self.frameglint:setMaterial( LUI.UIImage.GetCachedMaterial( "sw4_2d_bitchin_glint_reveal" ) )
				self.frameglint:setShaderVector( 0, 0, 0, 0, 0 )
				f2_local0( frameglint, {} )
				local f2_local1 = function ( f5_arg0, f5_arg1 )
					local f5_local0 = function ( f6_arg0, f6_arg1 )
						if not f6_arg1.interrupted then
							f6_arg0:beginAnimation( "keyframe", 509, false, false, CoD.TweenType.Linear )
						end
						f6_arg0:setLeftRight( true, false, 420.33, 409.67 )
						f6_arg0:setTopBottom( true, false, -54.7, 60 )
						f6_arg0:setRGB( 1, 0.3, 0.35 )
						f6_arg0:setAlpha( 0 )
						if f6_arg1.interrupted then
							self.clipFinished( f6_arg0, f6_arg1 )
						else
							f6_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f5_arg1.interrupted then
						f5_local0( f5_arg0, f5_arg1 )
						return 
					else
						f5_arg0:beginAnimation( "keyframe", 509, false, false, CoD.TweenType.Linear )
						f5_arg0:setLeftRight( true, false, 299.83, 289.67 )
						f5_arg0:setTopBottom( true, false, -129.7, 134.5 )
						f5_arg0:setAlpha( 1 )
						f5_arg0:registerEventHandler( "transition_complete_keyframe", f5_local0 )
					end
				end
				
				Glow:beginAnimation( "keyframe", 360, false, false, CoD.TweenType.Linear )
				Glow:setLeftRight( true, false, 179.33, 169.67 )
				Glow:setTopBottom( true, false, -204.7, 209 )
				Glow:setRGB( 1, 0.3, 0.35 )
				Glow:setAlpha( 0 )
				Glow:registerEventHandler( "transition_complete_keyframe", f2_local1 )
				local f2_local2 = function ( f7_arg0, f7_arg1 )
					local f7_local0 = function ( f8_arg0, f8_arg1 )
						if not f8_arg1.interrupted then
							f8_arg0:beginAnimation( "keyframe", 339, false, false, CoD.TweenType.Linear )
						end
						f8_arg0:setAlpha( 0 )
						f8_arg0:setScale( 0.5 )
						if f8_arg1.interrupted then
							self.clipFinished( f8_arg0, f8_arg1 )
						else
							f8_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f7_arg1.interrupted then
						f7_local0( f7_arg0, f7_arg1 )
						return 
					else
						f7_arg0:beginAnimation( "keyframe", 79, false, false, CoD.TweenType.Linear )
						f7_arg0:setAlpha( 1 )
						f7_arg0:setScale( 2 )
						f7_arg0:registerEventHandler( "transition_complete_keyframe", f7_local0 )
					end
				end
				
				GlowSmallCorner:completeAnimation()
				self.GlowSmallCorner:setAlpha( 0 )
				self.GlowSmallCorner:setScale( 0.5 )
				f2_local2( GlowSmallCorner, {} )
				local f2_local3 = function ( f9_arg0, f9_arg1 )
					local f9_local0 = function ( f10_arg0, f10_arg1 )
						local f10_local0 = function ( f11_arg0, f11_arg1 )
							if not f11_arg1.interrupted then
								f11_arg0:beginAnimation( "keyframe", 339, false, false, CoD.TweenType.Linear )
							end
							f11_arg0:setAlpha( 0 )
							f11_arg0:setScale( 0.5 )
							if f11_arg1.interrupted then
								self.clipFinished( f11_arg0, f11_arg1 )
							else
								f11_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
							end
						end
						
						if f10_arg1.interrupted then
							f10_local0( f10_arg0, f10_arg1 )
							return 
						else
							f10_arg0:beginAnimation( "keyframe", 79, false, false, CoD.TweenType.Linear )
							f10_arg0:setAlpha( 1 )
							f10_arg0:setScale( 1.3 )
							f10_arg0:registerEventHandler( "transition_complete_keyframe", f10_local0 )
						end
					end
					
					if f9_arg1.interrupted then
						f9_local0( f9_arg0, f9_arg1 )
						return 
					else
						f9_arg0:beginAnimation( "keyframe", 540, false, false, CoD.TweenType.Linear )
						f9_arg0:registerEventHandler( "transition_complete_keyframe", f9_local0 )
					end
				end
				
				GlowSmallCorner2:completeAnimation()
				self.GlowSmallCorner2:setAlpha( 0 )
				self.GlowSmallCorner2:setScale( 0.5 )
				f2_local3( GlowSmallCorner2, {} )
				local f2_local4 = function ( f12_arg0, f12_arg1 )
					local f12_local0 = function ( f13_arg0, f13_arg1 )
						local f13_local0 = function ( f14_arg0, f14_arg1 )
							if not f14_arg1.interrupted then
								f14_arg0:beginAnimation( "keyframe", 340, false, false, CoD.TweenType.Linear )
							end
							f14_arg0:setAlpha( 0 )
							f14_arg0:setScale( 0.2 )
							if f14_arg1.interrupted then
								self.clipFinished( f14_arg0, f14_arg1 )
							else
								f14_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
							end
						end
						
						if f13_arg1.interrupted then
							f13_local0( f13_arg0, f13_arg1 )
							return 
						else
							f13_arg0:beginAnimation( "keyframe", 79, false, false, CoD.TweenType.Linear )
							f13_arg0:setAlpha( 1 )
							f13_arg0:setScale( 0.7 )
							f13_arg0:registerEventHandler( "transition_complete_keyframe", f13_local0 )
						end
					end
					
					if f12_arg1.interrupted then
						f12_local0( f12_arg0, f12_arg1 )
						return 
					else
						f12_arg0:beginAnimation( "keyframe", 970, false, false, CoD.TweenType.Linear )
						f12_arg0:registerEventHandler( "transition_complete_keyframe", f12_local0 )
					end
				end
				
				GlowSmallCenter3:completeAnimation()
				self.GlowSmallCenter3:setAlpha( 0 )
				self.GlowSmallCenter3:setScale( 0.2 )
				f2_local4( GlowSmallCenter3, {} )
				local f2_local5 = function ( f15_arg0, f15_arg1 )
					local f15_local0 = function ( f16_arg0, f16_arg1 )
						local f16_local0 = function ( f17_arg0, f17_arg1 )
							if not f17_arg1.interrupted then
								f17_arg0:beginAnimation( "keyframe", 340, false, false, CoD.TweenType.Linear )
							end
							f17_arg0:setLeftRight( true, false, 484, 468.33 )
							f17_arg0:setTopBottom( true, false, 107.3, 123 )
							f17_arg0:setAlpha( 0 )
							f17_arg0:setScale( 0.5 )
							if f17_arg1.interrupted then
								self.clipFinished( f17_arg0, f17_arg1 )
							else
								f17_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
							end
						end
						
						if f16_arg1.interrupted then
							f16_local0( f16_arg0, f16_arg1 )
							return 
						else
							f16_arg0:beginAnimation( "keyframe", 79, false, false, CoD.TweenType.Linear )
							f16_arg0:setAlpha( 1 )
							f16_arg0:setScale( 1.3 )
							f16_arg0:registerEventHandler( "transition_complete_keyframe", f16_local0 )
						end
					end
					
					if f15_arg1.interrupted then
						f15_local0( f15_arg0, f15_arg1 )
						return 
					else
						f15_arg0:beginAnimation( "keyframe", 1220, false, false, CoD.TweenType.Linear )
						f15_arg0:registerEventHandler( "transition_complete_keyframe", f15_local0 )
					end
				end
				
				GlowSmallCorner4:completeAnimation()
				self.GlowSmallCorner4:setLeftRight( true, false, 484, 468.33 )
				self.GlowSmallCorner4:setTopBottom( true, false, 107.3, 123 )
				self.GlowSmallCorner4:setAlpha( 0 )
				self.GlowSmallCorner4:setScale( 0.5 )
				f2_local5( GlowSmallCorner4, {} )
				local f2_local6 = function ( f18_arg0, f18_arg1 )
					local f18_local0 = function ( f19_arg0, f19_arg1 )
						local f19_local0 = function ( f20_arg0, f20_arg1 )
							if not f20_arg1.interrupted then
								f20_arg0:beginAnimation( "keyframe", 339, false, false, CoD.TweenType.Linear )
							end
							f20_arg0:setAlpha( 0 )
							f20_arg0:setScale( 0.5 )
							if f20_arg1.interrupted then
								self.clipFinished( f20_arg0, f20_arg1 )
							else
								f20_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
							end
						end
						
						if f19_arg1.interrupted then
							f19_local0( f19_arg0, f19_arg1 )
							return 
						else
							f19_arg0:beginAnimation( "keyframe", 80, false, false, CoD.TweenType.Linear )
							f19_arg0:setAlpha( 1 )
							f19_arg0:setScale( 1.3 )
							f19_arg0:registerEventHandler( "transition_complete_keyframe", f19_local0 )
						end
					end
					
					if f18_arg1.interrupted then
						f18_local0( f18_arg0, f18_arg1 )
						return 
					else
						f18_arg0:beginAnimation( "keyframe", 2579, false, false, CoD.TweenType.Linear )
						f18_arg0:registerEventHandler( "transition_complete_keyframe", f18_local0 )
					end
				end
				
				GlowSmallCorner5:completeAnimation()
				self.GlowSmallCorner5:setAlpha( 0 )
				self.GlowSmallCorner5:setScale( 0.5 )
				f2_local6( GlowSmallCorner5, {} )
				self.nextClip = "DefaultClip"
			end
		}
	}
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end

