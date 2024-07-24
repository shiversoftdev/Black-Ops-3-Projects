EnableGlobals()

require( "ui.uieditor.widgets.HUD.ZM_Score.ZMScr_ListingLg" )
require( "ui.uieditor.widgets.HUD.ZM_Score.ZMScr_ListingSm" )
require( "ui.uieditor.widgets.HUD.ZM_Score.ZMScr_PlusPointsContainer" )

DataSources.ZMPlayerList = {
	getModel = function ( f1_arg0 )
		return Engine.CreateModel( Engine.GetModelForController( f1_arg0 ), "PlayerList" )
	end
}
local f0_local0 = function ( f2_arg0, f2_arg1, f2_arg2, f2_arg3, f2_arg4, f2_arg5 )
	if f2_arg1 == 0 or f2_arg1 < -10000 or f2_arg1 > 10000 then
		return 
	end
	local f2_local0 = CoD.ZMScr_PlusPointsContainer.new( f2_arg3, f2_arg2 )
	f2_local0.scoreEmitterInfo = f2_arg5
	if 0 < f2_arg1 then
		f2_local0.ZMScrPlusPoints.Label1:setText( "+" .. f2_arg1 )
		f2_local0.ZMScrPlusPoints.Label2:setText( "+" .. f2_arg1 )
		f2_local0.ZMScrPlusPoints:playClip( "DefaultClip" )
	else
		f2_local0.ZMScrPlusPoints.Label1:setText( f2_arg1 )
		f2_local0.ZMScrPlusPoints.Label2:setText( f2_arg1 )
		f2_local0.ZMScrPlusPoints:playClip( "NegativeScore" )
	end
	f2_local0:setLeftRight( f2_arg0:getLocalLeftRight() )
	f2_local0:setTopBottom( f2_arg0:getLocalTopBottom() )
	if f2_arg4 then
		f2_local0:setScale( 0.75 )
	end
	f2_arg0.lastAnim = f2_arg0.lastAnim + 1
	f2_local0:setState( "DefaultState" )
	if not f2_local0:hasClip( "Anim" .. f2_arg0.lastAnim ) then
		f2_arg0.lastAnim = 1
	end
	f2_local0:registerEventHandler( "clip_over", function ( element, event )
		local f3_local0 = element.scoreEmitterInfo
		element:close()
		CoD.perController[f3_local0.controller].scoreEmitterCount[f3_local0.index][f3_local0.type] = CoD.perController[f3_local0.controller].scoreEmitterCount[f3_local0.index][f3_local0.type] - 1
	end )
	local f2_local1 = f2_arg0:getParent()
	f2_local1:addElement( f2_local0 )
	f2_local0:playClip( "Anim" .. f2_arg0.lastAnim )
end

local PreLoadFunc = function ( self, controller )
	local f4_local0 = DataSources.ZMPlayerList.getModel( controller )
	for f4_local1 = 0, 7, 1 do
		local f4_local4 = Engine.CreateModel( f4_local0, f4_local1 )
		Engine.SetModelValue( Engine.CreateModel( f4_local4, "zombieInventoryIcon" ), "blacktransparent" )
		Engine.SetModelValue( Engine.CreateModel( f4_local4, "zombieWearableIcon" ), "blacktransparent" )
	end
end

local PostLoadFunc = function ( self, controller, menu )
	local f5_local0 = 128
	local f5_local1 = 64
	local f5_local2 = CoD.zbr_max_players
	local f5_local3 = {
		damage = 10,
		death_torso = 60,
		death_head = 100,
		death_melee = 130
	}
	local f5_local4 = Engine.GetModelForController( controller )
	CoD.perController[controller].scoreEmitterCount = {}
	for f5_local5 = 0, f5_local2 - 1, 1 do
		local f5_local8 = f5_local5
		local f5_local9 = self["ZMScrPlusPoints" .. f5_local8]
		f5_local9:setAlpha( 0 )
		f5_local9.lastAnim = 0
		CoD.perController[controller].scoreEmitterCount[f5_local8] = {}
		CoD.perController[controller].scoreEmitterCount[f5_local8].delayed = 0
		CoD.perController[controller].scoreEmitterCount[f5_local8].instant = 0
		local f5_local10 = Engine.GetModel( f5_local4, "PlayerList." .. f5_local8 .. ".clientNum" )
		if f5_local10 then
			f5_local10 = Engine.GetModelValue( f5_local10 )
		end
		if f5_local10 ~= nil then
			local f5_local11 = Engine.GetModel( f5_local4, "PlayerList.client" .. f5_local10 )
			if f5_local11 ~= nil then
				for f5_local15, f5_local16 in pairs( f5_local3 ) do
					f5_local9:registerEventHandler( "delayed_score", function ( element, event )
						f0_local0( element, event.score, controller, menu, f5_local8 > 0, {
							controller = controller,
							index = f5_local8,
							type = "delayed"
						} )
					end )
					f5_local9:subscribeToModel( Engine.CreateModel( f5_local11, "score_cf_" .. f5_local15 ), function ( modelRef )
						if Engine.GetModelValue( modelRef ) ~= nil then
							local f7_local0 = f5_local16
							local f7_local1 = Engine.GetModel( f5_local4, "hudItems.doublePointsActive" )
							if f7_local1 ~= nil and Engine.GetModelValue( f7_local1 ) == 1 then
								f7_local0 = f5_local16 * 2
							end
							if f5_local9.accountedForScore ~= nil then
								f5_local9.accountedForScore = f5_local9.accountedForScore + f7_local0
							end
							if CoD.perController[controller].scoreEmitterCount[f5_local8].delayed < f5_local0 then
								CoD.perController[controller].scoreEmitterCount[f5_local8].delayed = CoD.perController[controller].scoreEmitterCount[f5_local8].delayed + 1
								self:addElement( LUI.UITimer.new( 16 * tonumber(Engine.GetModelValue( modelRef ) % 3), {
									name = "delayed_score",
									score = f7_local0
								}, true, f5_local9 ) )
							end
						end
					end )
				end
			end
		end
		local f5_local11 = Engine.GetModel( f5_local4, "PlayerList." .. f5_local8 .. ".playerScore" )
		f5_local9.accountedForScore = Engine.GetModelValue( f5_local11 )
		f5_local9:subscribeToModel( f5_local11, function ( modelRef )
			local modelValue = Engine.GetModelValue( modelRef )
			if f5_local9.accountedForScore == nil then
				f5_local9.accountedForScore = modelValue
			end
			if modelValue ~= f5_local9.accountedForScore then
				if CoD.perController[controller].scoreEmitterCount[f5_local8].instant < f5_local1 then
					CoD.perController[controller].scoreEmitterCount[f5_local8].instant = CoD.perController[controller].scoreEmitterCount[f5_local8].instant + 1
					f0_local0( f5_local9, modelValue - f5_local9.accountedForScore, controller, menu, f5_local8 > 0, {
						controller = controller,
						index = f5_local8,
						type = "instant"
					} )
				end
				f5_local9.accountedForScore = modelValue
			end
		end )
	end
	Engine.CreateModel( f5_local4, "hudItems.doublePointsActive" )
end

CoD.ZMScr = InheritFrom( LUI.UIElement )
CoD.ZMScr.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
	self:setUseStencil( false )
	self:setClass( CoD.ZMScr )
	self.id = "ZMScr"
	self.soundSet = "HUD"
	self:setLeftRight( true, false, 0, 134 )
	self:setTopBottom( true, false, 0, 128 )
	self:makeFocusable()
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	local ListingUser = LUI.UIList.new( menu, controller, 2, 0, nil, false, false, 0, 0, false, false )
	ListingUser:makeFocusable()
	ListingUser:setLeftRight( true, false, 0, 134 )
	ListingUser:setTopBottom( true, false, 70, 128 )
	ListingUser:setWidgetType( CoD.ZMScr_ListingLg )
	ListingUser:setDataSource( "PlayerListZM" )
	ListingUser:mergeStateConditions( {
		{
			stateName = "Visible",
			condition = function ( menu, element, event )
				local f10_local0
				if not IsSelfModelValueEqualTo( element, controller, "playerScoreShown", 0 ) then
					f10_local0 = AlwaysTrue()
				else
					f10_local0 = false
				end
				return f10_local0
			end
		}
	} )
	ListingUser:linkToElementModel( ListingUser, "playerScoreShown", true, function ( modelRef )
		menu:updateElementState( ListingUser, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "playerScoreShown"
		} )
	end )
	self:addElement( ListingUser )
	self.ListingUser = ListingUser
	
	local Listing2 = CoD.ZMScr_ListingSm.new( menu, controller )
	Listing2:setLeftRight( true, false, 16.28, 101.28 )
	Listing2:setTopBottom( true, false, 52.12, 87.12 )
	Listing2:subscribeToGlobalModel( controller, "ZMPlayerList", "1", function ( modelRef )
		Listing2:setModel( modelRef, controller )
	end )
	self:addElement( Listing2 )
	self.Listing2 = Listing2
	
	local Listing3 = CoD.ZMScr_ListingSm.new( menu, controller )
	Listing3:setLeftRight( true, false, 16.28, 101.28 )
	Listing3:setTopBottom( true, false, 26.12, 61.12 )
	Listing3:subscribeToGlobalModel( controller, "ZMPlayerList", "2", function ( modelRef )
		Listing3:setModel( modelRef, controller )
	end )
	self:addElement( Listing3 )
	self.Listing3 = Listing3
	
	local Listing4 = CoD.ZMScr_ListingSm.new( menu, controller )
	Listing4:setLeftRight( true, false, 16.28, 101.28 )
	Listing4:setTopBottom( true, false, 0, 35 )
	Listing4:subscribeToGlobalModel( controller, "ZMPlayerList", "3", function ( modelRef )
		Listing4:setModel( modelRef, controller )
	end )
	self:addElement( Listing4 )
	self.Listing4 = Listing4
	
	local ZMScrPlusPoints0 = CoD.ZMScr_PlusPointsContainer.new( menu, controller )
	ZMScrPlusPoints0:setLeftRight( true, false, 87, 172 )
	ZMScrPlusPoints0:setTopBottom( true, false, 62.25, 128 )
	self:addElement( ZMScrPlusPoints0 )
	self.ZMScrPlusPoints0 = ZMScrPlusPoints0
	
	local ZMScrPlusPoints1 = CoD.ZMScr_PlusPointsContainer.new( menu, controller )
	ZMScrPlusPoints1:setLeftRight( true, false, 87, 172 )
	ZMScrPlusPoints1:setTopBottom( true, false, 33.25, 99 )
	ZMScrPlusPoints1:setScale( 0.75 )
	self:addElement( ZMScrPlusPoints1 )
	self.ZMScrPlusPoints1 = ZMScrPlusPoints1
	
	local ZMScrPlusPoints2 = CoD.ZMScr_PlusPointsContainer.new( menu, controller )
	ZMScrPlusPoints2:setLeftRight( true, false, 87, 172 )
	ZMScrPlusPoints2:setTopBottom( true, false, 7.75, 73.5 )
	ZMScrPlusPoints2:setScale( 0.75 )
	self:addElement( ZMScrPlusPoints2 )
	self.ZMScrPlusPoints2 = ZMScrPlusPoints2
	
	local ZMScrPlusPoints3 = CoD.ZMScr_PlusPointsContainer.new( menu, controller )
	ZMScrPlusPoints3:setLeftRight( true, false, 87, 172 )
	ZMScrPlusPoints3:setTopBottom( true, false, -18.38, 47.38 )
	ZMScrPlusPoints3:setScale( 0.75 )
	self:addElement( ZMScrPlusPoints3 )
	self.ZMScrPlusPoints3 = ZMScrPlusPoints3

	for f5_local5 = 4, 7, 1 do

		local ZMScrPlusPoints4 = CoD.ZMScr_PlusPointsContainer.new( menu, controller )
		ZMScrPlusPoints4:setLeftRight( true, false, 87, 172 )
		ZMScrPlusPoints4:setTopBottom( true, false, -18.38 - ((f5_local5 - 4) * 26), 47.38 - ((f5_local5 - 4) * 26))
		ZMScrPlusPoints4:setScale( 0.75 )
		self:addElement( ZMScrPlusPoints4 )
		self["ZMScrPlusPoints" .. f5_local5] = ZMScrPlusPoints4

	end
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 4 )
				ListingUser:completeAnimation()
				self.ListingUser:setAlpha( 0 )
				self.clipFinished( ListingUser, {} )
				Listing2:completeAnimation()
				self.Listing2:setAlpha( 0 )
				self.clipFinished( Listing2, {} )
				Listing3:completeAnimation()
				self.Listing3:setAlpha( 0 )
				self.clipFinished( Listing3, {} )
				Listing4:completeAnimation()
				self.Listing4:setAlpha( 0 )
				self.clipFinished( Listing4, {} )
			end,
			HudStart = function ()
				self:setupElementClipCounter( 4 )
				local f16_local0 = function ( f17_arg0, f17_arg1 )
					if not f17_arg1.interrupted then
						f17_arg0:beginAnimation( "keyframe", 300, false, false, CoD.TweenType.Bounce )
					end
					f17_arg0:setAlpha( 1 )
					if f17_arg1.interrupted then
						self.clipFinished( f17_arg0, f17_arg1 )
					else
						f17_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				ListingUser:completeAnimation()
				self.ListingUser:setAlpha( 0 )
				f16_local0( ListingUser, {} )
				local f16_local1 = function ( f18_arg0, f18_arg1 )
					local f18_local0 = function ( f19_arg0, f19_arg1 )
						if not f19_arg1.interrupted then
							f19_arg0:beginAnimation( "keyframe", 299, false, false, CoD.TweenType.Bounce )
						end
						f19_arg0:setAlpha( 1 )
						if f19_arg1.interrupted then
							self.clipFinished( f19_arg0, f19_arg1 )
						else
							f19_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f18_arg1.interrupted then
						f18_local0( f18_arg0, f18_arg1 )
						return 
					else
						f18_arg0:beginAnimation( "keyframe", 119, false, false, CoD.TweenType.Linear )
						f18_arg0:registerEventHandler( "transition_complete_keyframe", f18_local0 )
					end
				end
				
				Listing2:completeAnimation()
				self.Listing2:setAlpha( 0 )
				f16_local1( Listing2, {} )
				local f16_local2 = function ( f20_arg0, f20_arg1 )
					local f20_local0 = function ( f21_arg0, f21_arg1 )
						if not f21_arg1.interrupted then
							f21_arg0:beginAnimation( "keyframe", 300, false, false, CoD.TweenType.Bounce )
						end
						f21_arg0:setAlpha( 1 )
						if f21_arg1.interrupted then
							self.clipFinished( f21_arg0, f21_arg1 )
						else
							f21_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f20_arg1.interrupted then
						f20_local0( f20_arg0, f20_arg1 )
						return 
					else
						f20_arg0:beginAnimation( "keyframe", 239, false, false, CoD.TweenType.Linear )
						f20_arg0:registerEventHandler( "transition_complete_keyframe", f20_local0 )
					end
				end
				
				Listing3:completeAnimation()
				self.Listing3:setAlpha( 0 )
				f16_local2( Listing3, {} )
				local f16_local3 = function ( f22_arg0, f22_arg1 )
					local f22_local0 = function ( f23_arg0, f23_arg1 )
						if not f23_arg1.interrupted then
							f23_arg0:beginAnimation( "keyframe", 299, false, false, CoD.TweenType.Bounce )
						end
						f23_arg0:setAlpha( 1 )
						if f23_arg1.interrupted then
							self.clipFinished( f23_arg0, f23_arg1 )
						else
							f23_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f22_arg1.interrupted then
						f22_local0( f22_arg0, f22_arg1 )
						return 
					else
						f22_arg0:beginAnimation( "keyframe", 340, false, false, CoD.TweenType.Bounce )
						f22_arg0:registerEventHandler( "transition_complete_keyframe", f22_local0 )
					end
				end
				
				Listing4:completeAnimation()
				self.Listing4:setAlpha( 0 )
				f16_local3( Listing4, {} )
			end
		},
		HudStart = {
			DefaultClip = function ()
				self:setupElementClipCounter( 4 )
				ListingUser:completeAnimation()
				self.ListingUser:setAlpha( 1 )
				self.clipFinished( ListingUser, {} )
				Listing2:completeAnimation()
				self.Listing2:setAlpha( 1 )
				self.clipFinished( Listing2, {} )
				Listing3:completeAnimation()
				self.Listing3:setAlpha( 1 )
				self.clipFinished( Listing3, {} )
				Listing4:completeAnimation()
				self.Listing4:setAlpha( 1 )
				self.clipFinished( Listing4, {} )
			end,
			DefaultState = function ()
				self:setupElementClipCounter( 4 )
				local f25_local0 = function ( f26_arg0, f26_arg1 )
					if not f26_arg1.interrupted then
						f26_arg0:beginAnimation( "keyframe", 300, false, false, CoD.TweenType.Bounce )
					end
					f26_arg0:setAlpha( 0 )
					if f26_arg1.interrupted then
						self.clipFinished( f26_arg0, f26_arg1 )
					else
						f26_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				ListingUser:completeAnimation()
				self.ListingUser:setAlpha( 1 )
				f25_local0( ListingUser, {} )
				local f25_local1 = function ( f27_arg0, f27_arg1 )
					local f27_local0 = function ( f28_arg0, f28_arg1 )
						if not f28_arg1.interrupted then
							f28_arg0:beginAnimation( "keyframe", 300, false, false, CoD.TweenType.Bounce )
						end
						f28_arg0:setAlpha( 0 )
						if f28_arg1.interrupted then
							self.clipFinished( f28_arg0, f28_arg1 )
						else
							f28_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f27_arg1.interrupted then
						f27_local0( f27_arg0, f27_arg1 )
						return 
					else
						f27_arg0:beginAnimation( "keyframe", 159, false, false, CoD.TweenType.Linear )
						f27_arg0:registerEventHandler( "transition_complete_keyframe", f27_local0 )
					end
				end
				
				Listing2:completeAnimation()
				self.Listing2:setAlpha( 1 )
				f25_local1( Listing2, {} )
				local f25_local2 = function ( f29_arg0, f29_arg1 )
					local f29_local0 = function ( f30_arg0, f30_arg1 )
						if not f30_arg1.interrupted then
							f30_arg0:beginAnimation( "keyframe", 299, false, false, CoD.TweenType.Bounce )
						end
						f30_arg0:setAlpha( 0 )
						if f30_arg1.interrupted then
							self.clipFinished( f30_arg0, f30_arg1 )
						else
							f30_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f29_arg1.interrupted then
						f29_local0( f29_arg0, f29_arg1 )
						return 
					else
						f29_arg0:beginAnimation( "keyframe", 270, false, false, CoD.TweenType.Linear )
						f29_arg0:registerEventHandler( "transition_complete_keyframe", f29_local0 )
					end
				end
				
				Listing3:completeAnimation()
				self.Listing3:setAlpha( 1 )
				f25_local2( Listing3, {} )
				local f25_local3 = function ( f31_arg0, f31_arg1 )
					local f31_local0 = function ( f32_arg0, f32_arg1 )
						if not f32_arg1.interrupted then
							f32_arg0:beginAnimation( "keyframe", 299, false, false, CoD.TweenType.Bounce )
						end
						f32_arg0:setAlpha( 0 )
						if f32_arg1.interrupted then
							self.clipFinished( f32_arg0, f32_arg1 )
						else
							f32_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f31_arg1.interrupted then
						f31_local0( f31_arg0, f31_arg1 )
						return 
					else
						f31_arg0:beginAnimation( "keyframe", 340, false, false, CoD.TweenType.Linear )
						f31_arg0:registerEventHandler( "transition_complete_keyframe", f31_local0 )
					end
				end
				
				Listing4:completeAnimation()
				self.Listing4:setAlpha( 1 )
				f25_local3( Listing4, {} )
			end
		}
	}
	ListingUser.id = "ListingUser"
	self:registerEventHandler( "gain_focus", function ( element, event )
		if element.m_focusable and element.ListingUser:processEvent( event ) then
			return true
		else
			return LUI.UIElement.gainFocus( element, event )
		end
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.ListingUser:close()
		element.Listing2:close()
		element.Listing3:close()
		element.Listing4:close()
		element.ZMScrPlusPoints0:close()
		element.ZMScrPlusPoints1:close()
		element.ZMScrPlusPoints2:close()
		element.ZMScrPlusPoints3:close()
		element.ZMScrPlusPoints4:close()
		element.ZMScrPlusPoints5:close()
		element.ZMScrPlusPoints6:close()
		element.ZMScrPlusPoints7:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end