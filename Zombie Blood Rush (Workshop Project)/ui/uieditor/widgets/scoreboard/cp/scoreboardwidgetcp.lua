require( "ui.uieditor.widgets.Scoreboard.CP.ScoreboardHeaderWidgetCP" )
require( "ui.uieditor.widgets.Scoreboard.ScoreboardFactionScoresList" )
require( "ui.uieditor.widgets.Scoreboard.ScoreboardWidgetButtonContainer" )

local PostLoadFunc = function ( f1_arg0, f1_arg1 )
	f1_arg0.ScoreboardFactionScoresListCP0.Team1:subscribeToModel( Engine.CreateModel( Engine.GetModelForController( f1_arg1 ), "updateScoreboard" ), function ( modelRef )
		CoD.ScoreboardUtility.UpdateScoreboardTeamScores( f1_arg1 )
	end )
	f1_arg0:subscribeToModel( Engine.GetModel( Engine.GetModelForController( f1_arg1 ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN ), function ( modelRef )
		f1_arg0.m_inputDisabled = not Engine.GetModelValue( modelRef )
	end )
end

local PreLoadFunc = function ( self, controller )
	CoD.ScoreboardUtility.SetScoreboardUIModels( controller )
end

CoD.ScoreboardWidgetCP = InheritFrom( LUI.UIElement )
CoD.ScoreboardWidgetCP.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
	self:setUseStencil( false )
	self:setClass( CoD.ScoreboardWidgetCP )
	self.id = "ScoreboardWidgetCP"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 1006 )
	self:setTopBottom( true, false, 0, 526 )
	self:makeFocusable()
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	local ScoreboardHeaderWidgetCP0 = CoD.ScoreboardHeaderWidgetCP.new( menu, controller )
	ScoreboardHeaderWidgetCP0:setLeftRight( true, false, 88, 893.5 )
	ScoreboardHeaderWidgetCP0:setTopBottom( true, false, 10, 47 )
	ScoreboardHeaderWidgetCP0:setAlpha( 0 )
	ScoreboardHeaderWidgetCP0:subscribeToGlobalModel( controller, "Scoreboard", nil, function ( modelRef )
		ScoreboardHeaderWidgetCP0:setModel( modelRef, controller )
	end )
	self:addElement( ScoreboardHeaderWidgetCP0 )
	self.ScoreboardHeaderWidgetCP0 = ScoreboardHeaderWidgetCP0
	
	local ScoreboardFactionScoresListCP0 = CoD.ScoreboardFactionScoresList.new( menu, controller )
	ScoreboardFactionScoresListCP0:setLeftRight( true, false, 88.5, 914.5 )
	ScoreboardFactionScoresListCP0:setTopBottom( true, false, 47, 515 )
	ScoreboardFactionScoresListCP0.Team1:setVerticalCount( 8 )
	ScoreboardFactionScoresListCP0.Team2:setAlpha( 0 )
	ScoreboardFactionScoresListCP0.Team2:setVerticalCount( 1 )
	ScoreboardFactionScoresListCP0:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "forceScoreboard" ), function ( modelRef )
		local f7_local0 = ScoreboardFactionScoresListCP0
		local f7_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "forceScoreboard"
		}
		CoD.Menu.UpdateButtonShownState( f7_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
	end )
	ScoreboardFactionScoresListCP0:registerEventHandler( "list_item_gain_focus", function ( element, event )
		local f8_local0 = nil
		UpdateScoreboardClientMuteButtonPrompt( element, controller )
		return f8_local0
	end )
	ScoreboardFactionScoresListCP0:registerEventHandler( "gain_focus", function ( element, event )
		local f9_local0 = nil
		if element.gainFocus then
			f9_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f9_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		return f9_local0
	end )
	ScoreboardFactionScoresListCP0:registerEventHandler( "lose_focus", function ( element, event )
		local f10_local0 = nil
		if element.loseFocus then
			f10_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f10_local0 = element.super:loseFocus( event )
		end
		return f10_local0
	end )
	menu:AddButtonCallbackFunction( ScoreboardFactionScoresListCP0, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, nil, function ( f11_arg0, f11_arg1, f11_arg2, f11_arg3 )
		if ScoreboardVisible( f11_arg2 ) then
			BlockGameFromKeyEvent( f11_arg2 )
			return true
		else
			
		end
	end, function ( f12_arg0, f12_arg1, f12_arg2 )
		if ScoreboardVisible( f12_arg2 ) then
			CoD.Menu.SetButtonLabel( f12_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "" )
			return false
		else
			return false
		end
	end, false )
	self:addElement( ScoreboardFactionScoresListCP0 )
	self.ScoreboardFactionScoresListCP0 = ScoreboardFactionScoresListCP0
	
	local ScoreboardWidgetButtonContainer = CoD.ScoreboardWidgetButtonContainer.new( menu, controller )
	ScoreboardWidgetButtonContainer:setLeftRight( true, false, 88.5, 533.5 )
	ScoreboardWidgetButtonContainer:setTopBottom( true, false, 152, 184 )
	self:addElement( ScoreboardWidgetButtonContainer )
	self.ScoreboardWidgetButtonContainer = ScoreboardWidgetButtonContainer
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 3 )
				ScoreboardHeaderWidgetCP0:completeAnimation()
				self.ScoreboardHeaderWidgetCP0:setAlpha( 0 )
				self.clipFinished( ScoreboardHeaderWidgetCP0, {} )
				ScoreboardFactionScoresListCP0:completeAnimation()
				self.ScoreboardFactionScoresListCP0:setAlpha( 0 )
				self.clipFinished( ScoreboardFactionScoresListCP0, {} )
				ScoreboardWidgetButtonContainer:completeAnimation()
				self.ScoreboardWidgetButtonContainer:setAlpha( 0 )
				self.clipFinished( ScoreboardWidgetButtonContainer, {} )
			end,
			Intro = function ()
				self:setupElementClipCounter( 2 )
				local f14_local0 = function ( f15_arg0, f15_arg1 )
					if not f15_arg1.interrupted then
						f15_arg0:beginAnimation( "keyframe", 189, false, false, CoD.TweenType.Linear )
					end
					f15_arg0:setAlpha( 1 )
					if f15_arg1.interrupted then
						self.clipFinished( f15_arg0, f15_arg1 )
					else
						f15_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				ScoreboardHeaderWidgetCP0:completeAnimation()
				self.ScoreboardHeaderWidgetCP0:setAlpha( 0 )
				f14_local0( ScoreboardHeaderWidgetCP0, {} )
				local f14_local1 = function ( f16_arg0, f16_arg1 )
					if not f16_arg1.interrupted then
						f16_arg0:beginAnimation( "keyframe", 289, false, false, CoD.TweenType.Bounce )
					end
					f16_arg0:setAlpha( 1 )
					if f16_arg1.interrupted then
						self.clipFinished( f16_arg0, f16_arg1 )
					else
						f16_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				ScoreboardFactionScoresListCP0:beginAnimation( "keyframe", 119, false, false, CoD.TweenType.Linear )
				ScoreboardFactionScoresListCP0:setAlpha( 0 )
				ScoreboardFactionScoresListCP0:registerEventHandler( "transition_complete_keyframe", f14_local1 )
			end
		},
		ArabicZombieAAR = {
			DefaultClip = function ()
				self:setupElementClipCounter( 3 )
				ScoreboardHeaderWidgetCP0:completeAnimation()
				self.ScoreboardHeaderWidgetCP0:setLeftRight( true, false, 152.5, 954.5 )
				self.ScoreboardHeaderWidgetCP0:setTopBottom( true, false, 0, 32 )
				self.ScoreboardHeaderWidgetCP0:setAlpha( 1 )
				self.clipFinished( ScoreboardHeaderWidgetCP0, {} )
				ScoreboardFactionScoresListCP0:completeAnimation()
				self.ScoreboardFactionScoresListCP0:setAlpha( 1 )
				self.clipFinished( ScoreboardFactionScoresListCP0, {} )
				ScoreboardWidgetButtonContainer:completeAnimation()
				self.ScoreboardWidgetButtonContainer:setAlpha( 0 )
				self.clipFinished( ScoreboardWidgetButtonContainer, {} )
			end
		},
		Visible = {
			DefaultClip = function ()
				self:setupElementClipCounter( 3 )
				ScoreboardHeaderWidgetCP0:completeAnimation()
				self.ScoreboardHeaderWidgetCP0:setAlpha( 1 )
				self.clipFinished( ScoreboardHeaderWidgetCP0, {} )
				ScoreboardFactionScoresListCP0:completeAnimation()
				self.ScoreboardFactionScoresListCP0:setAlpha( 1 )
				self.clipFinished( ScoreboardFactionScoresListCP0, {} )
				ScoreboardWidgetButtonContainer:completeAnimation()
				self.ScoreboardWidgetButtonContainer:setAlpha( 1 )
				self.clipFinished( ScoreboardWidgetButtonContainer, {} )
			end
		},
		ForceVisible = {
			DefaultClip = function ()
				self:setupElementClipCounter( 3 )
				ScoreboardHeaderWidgetCP0:completeAnimation()
				self.ScoreboardHeaderWidgetCP0:setAlpha( 1 )
				self.clipFinished( ScoreboardHeaderWidgetCP0, {} )
				ScoreboardFactionScoresListCP0:completeAnimation()
				self.ScoreboardFactionScoresListCP0:setAlpha( 1 )
				self.clipFinished( ScoreboardFactionScoresListCP0, {} )
				ScoreboardWidgetButtonContainer:completeAnimation()
				self.ScoreboardWidgetButtonContainer:setAlpha( 1 )
				self.clipFinished( ScoreboardWidgetButtonContainer, {} )
			end
		},
		Frontend = {
			DefaultClip = function ()
				self:setupElementClipCounter( 3 )
				ScoreboardHeaderWidgetCP0:completeAnimation()
				self.ScoreboardHeaderWidgetCP0:setAlpha( 0 )
				self.clipFinished( ScoreboardHeaderWidgetCP0, {} )
				ScoreboardFactionScoresListCP0:completeAnimation()
				self.ScoreboardFactionScoresListCP0:setAlpha( 1 )
				self.clipFinished( ScoreboardFactionScoresListCP0, {} )
				ScoreboardWidgetButtonContainer:completeAnimation()
				self.ScoreboardWidgetButtonContainer:setAlpha( 1 )
				self.clipFinished( ScoreboardWidgetButtonContainer, {} )
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "ArabicZombieAAR",
			condition = function ( menu, element, event )
				local f21_local0 = IsCurrentLanguageArabic()
				if f21_local0 then
					f21_local0 = IsZombies()
					if f21_local0 then
						f21_local0 = AlwaysFalse()
					end
				end
				return f21_local0
			end
		},
		{
			stateName = "Visible",
			condition = function ( menu, element, event )
				return Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN )
			end
		},
		{
			stateName = "ForceVisible",
			condition = function ( menu, element, event )
				return IsModelValueEqualTo( controller, "forceScoreboard", 1 )
			end
		},
		{
			stateName = "Frontend",
			condition = function ( menu, element, event )
				return not IsInGame()
			end
		}
	} )
	self:subscribeToModel( Engine.GetModel( Engine.GetGlobalModel(), "lobbyRoot.lobbyNav" ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "lobbyRoot.lobbyNav"
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "forceScoreboard" ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "forceScoreboard"
		} )
	end )
	ScoreboardFactionScoresListCP0.id = "ScoreboardFactionScoresListCP0"
	ScoreboardWidgetButtonContainer:setModel( menu.buttonModel, controller )
	self:registerEventHandler( "gain_focus", function ( element, event )
		if element.m_focusable and element.ScoreboardFactionScoresListCP0:processEvent( event ) then
			return true
		else
			return LUI.UIElement.gainFocus( element, event )
		end
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.ScoreboardHeaderWidgetCP0:close()
		element.ScoreboardFactionScoresListCP0:close()
		element.ScoreboardWidgetButtonContainer:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end

