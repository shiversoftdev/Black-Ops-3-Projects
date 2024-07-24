require( "ui.uieditor.widgets.StartMenu.StartMenu_Challenges_Button" )
require( "ui.uieditor.menus.Challenges.Challenges_CP" )
require( "ui.uieditor.menus.Challenges.Challenges" )
require( "ui.uieditor.menus.Challenges.Challenges_ZM" )

local PostLoadFunc = function ( f1_arg0, f1_arg1 )
	local f1_local0 = Engine.GetModel( Engine.GetModelForController( f1_arg1 ), "noNearCompleteCP" )
	if f1_local0 ~= nil and Engine.GetModelValue( f1_local0 ) == true then
		f1_arg0.CP:setState( "NoNearComplete" )
		local f1_local1 = f1_arg0.CP.currentState
	end
	local f1_local1 = Engine.GetModel( Engine.GetModelForController( f1_arg1 ), "noNearCompleteMP" )
	if f1_local1 ~= nil and Engine.GetModelValue( f1_local1 ) == true then
		f1_arg0.MP:setState( "NoNearComplete" )
	end
	local f1_local2 = Engine.GetModel( Engine.GetModelForController( f1_arg1 ), "noNearCompleteZM" )
	if f1_local2 ~= nil and Engine.GetModelValue( f1_local2 ) == true then
		f1_arg0.ZM:setState( "NoNearComplete" )
	end
end

CoD.StartMenu_Challenges = InheritFrom( LUI.UIElement )
CoD.StartMenu_Challenges.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
	self:setUseStencil( false )
	self:setClass( CoD.StartMenu_Challenges )
	self.id = "StartMenu_Challenges"
	self.soundSet = "ChooseDecal"
	self:setLeftRight( true, false, 0, 1150 )
	self:setTopBottom( true, false, 0, 520 )
	self:makeFocusable()
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	local CP = CoD.StartMenu_Challenges_Button.new( menu, controller )
	CP:setLeftRight( true, false, 9, 375 )
	CP:setTopBottom( true, true, 13, -179 )
	CP.SessionName:setText( Engine.Localize( "MENU_CAMPAIGN_CAPS" ) )
	CP.StartMenuIdentitySubTitle0.SubTitle:setText( Engine.Localize( "MENU_COMPLETE_CAMPAIGN_CHALLENGES" ) )
	CP:subscribeToGlobalModel( controller, "ChallengesCPNearCompletion", nil, function ( modelRef )
		CP:setModel( modelRef, controller )
	end )
	CP:subscribeToGlobalModel( controller, "ChallengesCPCategoryStats", "cp", function ( modelRef )
		local cp = Engine.GetModelValue( modelRef )
		if cp then
			CP.PercentComplete.percentCompleteCircle:setAlpha( HideIfNumEqualTo( 0, cp ) )
		end
	end )
	CP:subscribeToGlobalModel( controller, "ChallengesCPCategoryStats", "cp", function ( modelRef )
		local cp = Engine.GetModelValue( modelRef )
		if cp then
			CP.PercentComplete.percentCompleteCircle:setShaderVector( 0, CoD.GetVectorComponentFromString( cp, 1 ), CoD.GetVectorComponentFromString( cp, 2 ), CoD.GetVectorComponentFromString( cp, 3 ), CoD.GetVectorComponentFromString( cp, 4 ) )
		end
	end )
	CP:subscribeToGlobalModel( controller, "ChallengesCPCategoryStats", "cp", function ( modelRef )
		local cp = Engine.GetModelValue( modelRef )
		if cp then
			CP.PercentComplete.percentText:setText( Engine.Localize( NumberAsPercentRounded( cp ) ) )
		end
	end )
	CP:subscribeToGlobalModel( controller, "ChallengesCPNearCompletion", "statPercent", function ( modelRef )
		local statPercent = Engine.GetModelValue( modelRef )
		if statPercent then
			CP.NearCompletionWidget.ProgressBar:setShaderVector( 0, CoD.GetVectorComponentFromString( statPercent, 1 ), CoD.GetVectorComponentFromString( statPercent, 2 ), CoD.GetVectorComponentFromString( statPercent, 3 ), CoD.GetVectorComponentFromString( statPercent, 4 ) )
		end
	end )
	CP:subscribeToGlobalModel( controller, "ChallengesCPNearCompletion", "statFractionText", function ( modelRef )
		local statFractionText = Engine.GetModelValue( modelRef )
		if statFractionText then
			CP.NearCompletionWidget.ProgressFraction:setText( Engine.Localize( statFractionText ) )
		end
	end )
	CP:subscribeToGlobalModel( controller, "ChallengesCPNearCompletion", "iconId", function ( modelRef )
		local iconId = Engine.GetModelValue( modelRef )
		if iconId then
			CP.NearCompletionWidget.ChallengeIcon.Image:setImage( RegisterImage( GetBackgroundByID( iconId ) ) )
		end
	end )
	CP:subscribeToGlobalModel( controller, "ChallengesCPNearCompletion", "title", function ( modelRef )
		local title = Engine.GetModelValue( modelRef )
		if title then
			CP.NearCompletionWidget.ChallengeTitle.textBox:setText( Engine.Localize( title ) )
		end
	end )
	CP:subscribeToGlobalModel( controller, "ChallengesCPNearCompletion", "description", function ( modelRef )
		local description = Engine.GetModelValue( modelRef )
		if description then
			CP.NearCompletionWidget.ChallengeDescription.textBox:setText( Engine.Localize( description ) )
		end
	end )
	CP:registerEventHandler( "gain_focus", function ( element, event )
		local f12_local0 = nil
		if element.gainFocus then
			f12_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f12_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		return f12_local0
	end )
	CP:registerEventHandler( "lose_focus", function ( element, event )
		local f13_local0 = nil
		if element.loseFocus then
			f13_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f13_local0 = element.super:loseFocus( event )
		end
		return f13_local0
	end )
	menu:AddButtonCallbackFunction( CP, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f14_arg0, f14_arg1, f14_arg2, f14_arg3 )
		if not IsElementInState( f14_arg0, "Disabled" ) then
			SetGlobalModelValue( "challengeGameMode", "cp" )
			OpenOverlay( self, "Challenges_CP", f14_arg2, "", "" )
			return true
		else
			
		end
	end, function ( f15_arg0, f15_arg1, f15_arg2 )
		CoD.Menu.SetButtonLabel( f15_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		if not IsElementInState( f15_arg0, "Disabled" ) then
			return true
		else
			return false
		end
	end, false )
	CP:mergeStateConditions( {
		{
			stateName = "Disable",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		},
		{
			stateName = "NoNearComplete",
			condition = function ( menu, element, event )
				return IsElementInState( element, "NoNearComplete" )
			end
		}
	} )
	-- self:addElement( CP )
	self.CP = CP
	
	local MP = CoD.StartMenu_Challenges_Button.new( menu, controller )
	MP:setLeftRight( true, false, 384, 750 )
	MP:setTopBottom( true, true, 13, -179 )
	MP.SessionName:setText( Engine.Localize( "MENU_MULTIPLAYER_CAPS" ) )
	MP.StartMenuIdentitySubTitle0.SubTitle:setText( Engine.Localize( "MENU_COMPLETE_MULTIPLAYER_CHALLENGES" ) )
	MP:subscribeToGlobalModel( controller, "ChallengesMPNearCompletion", nil, function ( modelRef )
		MP:setModel( modelRef, controller )
	end )
	MP:subscribeToGlobalModel( controller, "ChallengesMPCategoryStats", "mp", function ( modelRef )
		local mp = Engine.GetModelValue( modelRef )
		if mp then
			MP.PercentComplete.percentCompleteCircle:setAlpha( HideIfNumEqualTo( 0, mp ) )
		end
	end )
	MP:subscribeToGlobalModel( controller, "ChallengesMPCategoryStats", "mp", function ( modelRef )
		local mp = Engine.GetModelValue( modelRef )
		if mp then
			MP.PercentComplete.percentCompleteCircle:setShaderVector( 0, CoD.GetVectorComponentFromString( mp, 1 ), CoD.GetVectorComponentFromString( mp, 2 ), CoD.GetVectorComponentFromString( mp, 3 ), CoD.GetVectorComponentFromString( mp, 4 ) )
		end
	end )
	MP:subscribeToGlobalModel( controller, "ChallengesMPCategoryStats", "mp", function ( modelRef )
		local mp = Engine.GetModelValue( modelRef )
		if mp then
			MP.PercentComplete.percentText:setText( Engine.Localize( NumberAsPercentRounded( mp ) ) )
		end
	end )
	MP:subscribeToGlobalModel( controller, "ChallengesMPNearCompletion", "statPercent", function ( modelRef )
		local statPercent = Engine.GetModelValue( modelRef )
		if statPercent then
			MP.NearCompletionWidget.ProgressBar:setShaderVector( 0, CoD.GetVectorComponentFromString( statPercent, 1 ), CoD.GetVectorComponentFromString( statPercent, 2 ), CoD.GetVectorComponentFromString( statPercent, 3 ), CoD.GetVectorComponentFromString( statPercent, 4 ) )
		end
	end )
	MP:subscribeToGlobalModel( controller, "ChallengesMPNearCompletion", "statFractionText", function ( modelRef )
		local statFractionText = Engine.GetModelValue( modelRef )
		if statFractionText then
			MP.NearCompletionWidget.ProgressFraction:setText( Engine.Localize( statFractionText ) )
		end
	end )
	MP:subscribeToGlobalModel( controller, "ChallengesMPNearCompletion", "iconId", function ( modelRef )
		local iconId = Engine.GetModelValue( modelRef )
		if iconId then
			MP.NearCompletionWidget.ChallengeIcon.Image:setImage( RegisterImage( GetBackgroundByID( iconId ) ) )
		end
	end )
	MP:subscribeToGlobalModel( controller, "ChallengesMPNearCompletion", "title", function ( modelRef )
		local title = Engine.GetModelValue( modelRef )
		if title then
			MP.NearCompletionWidget.ChallengeTitle.textBox:setText( Engine.Localize( title ) )
		end
	end )
	MP:subscribeToGlobalModel( controller, "ChallengesMPNearCompletion", "description", function ( modelRef )
		local description = Engine.GetModelValue( modelRef )
		if description then
			MP.NearCompletionWidget.ChallengeDescription.textBox:setText( Engine.Localize( description ) )
		end
	end )
	MP:registerEventHandler( "gain_focus", function ( element, event )
		local f27_local0 = nil
		if element.gainFocus then
			f27_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f27_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		return f27_local0
	end )
	MP:registerEventHandler( "lose_focus", function ( element, event )
		local f28_local0 = nil
		if element.loseFocus then
			f28_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f28_local0 = element.super:loseFocus( event )
		end
		return f28_local0
	end )
	menu:AddButtonCallbackFunction( MP, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f29_arg0, f29_arg1, f29_arg2, f29_arg3 )
		if not IsElementInState( f29_arg0, "Disabled" ) then
			SetGlobalModelValue( "challengeGameMode", "mp" )
			OpenOverlay( self, "Challenges", f29_arg2, "", "" )
			return true
		else
			
		end
	end, function ( f30_arg0, f30_arg1, f30_arg2 )
		CoD.Menu.SetButtonLabel( f30_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		if not IsElementInState( f30_arg0, "Disabled" ) then
			return true
		else
			return false
		end
	end, false )
	MP:mergeStateConditions( {
		{
			stateName = "Disable",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		},
		{
			stateName = "NoNearComplete",
			condition = function ( menu, element, event )
				return IsElementInState( element, "NoNearComplete" )
			end
		}
	} )
	-- self:addElement( MP )
	self.MP = MP
	
	local ZM = CoD.StartMenu_Challenges_Button.new( menu, controller )
	ZM:setLeftRight( true, false, 384, 750 )
	ZM:setTopBottom( true, true, 13, -179 )
	ZM.SessionName:setText( Engine.Localize( "ZOMBIE BLOOD RUSH" ) )
	ZM.StartMenuIdentitySubTitle0.SubTitle:setText( Engine.Localize( "Complete ZBR Challenges" ) )
	ZM:subscribeToGlobalModel( controller, "ChallengesZMNearCompletion", nil, function ( modelRef )
		ZM:setModel( modelRef, controller )
	end )
	ZM:subscribeToGlobalModel( controller, "ChallengesZMCategoryStats", "zm", function ( modelRef )
		local zm = Engine.GetModelValue( modelRef )
		if zm then
			ZM.PercentComplete.percentCompleteCircle:setAlpha( HideIfNumEqualTo( 0, zm ) )
		end
	end )
	ZM:subscribeToGlobalModel( controller, "ChallengesZMCategoryStats", "zm", function ( modelRef )
		local zm = Engine.GetModelValue( modelRef )
		if zm then
			ZM.PercentComplete.percentCompleteCircle:setShaderVector( 0, CoD.GetVectorComponentFromString( zm, 1 ), CoD.GetVectorComponentFromString( zm, 2 ), CoD.GetVectorComponentFromString( zm, 3 ), CoD.GetVectorComponentFromString( zm, 4 ) )
		end
	end )
	ZM:subscribeToGlobalModel( controller, "ChallengesZMCategoryStats", "zm", function ( modelRef )
		local zm = Engine.GetModelValue( modelRef )
		if zm then
			ZM.PercentComplete.percentText:setText( Engine.Localize( NumberAsPercentRounded( zm ) ) )
		end
	end )
	ZM:subscribeToGlobalModel( controller, "ChallengesZMNearCompletion", "statPercent", function ( modelRef )
		local statPercent = Engine.GetModelValue( modelRef )
		if statPercent then
			ZM.NearCompletionWidget.ProgressBar:setShaderVector( 0, CoD.GetVectorComponentFromString( statPercent, 1 ), CoD.GetVectorComponentFromString( statPercent, 2 ), CoD.GetVectorComponentFromString( statPercent, 3 ), CoD.GetVectorComponentFromString( statPercent, 4 ) )
		end
	end )
	ZM:subscribeToGlobalModel( controller, "ChallengesZMNearCompletion", "statFractionText", function ( modelRef )
		local statFractionText = Engine.GetModelValue( modelRef )
		if statFractionText then
			ZM.NearCompletionWidget.ProgressFraction:setText( Engine.Localize( statFractionText ) )
		end
	end )
	ZM:subscribeToGlobalModel( controller, "ChallengesZMNearCompletion", "iconId", function ( modelRef )
		local iconId = Engine.GetModelValue( modelRef )
		if iconId then
			ZM.NearCompletionWidget.ChallengeIcon.Image:setImage( RegisterImage( GetBackgroundByID( iconId ) ) )
		end
	end )
	ZM:subscribeToGlobalModel( controller, "ChallengesZMNearCompletion", "title", function ( modelRef )
		local title = Engine.GetModelValue( modelRef )
		if title then
			ZM.NearCompletionWidget.ChallengeTitle.textBox:setText( Engine.Localize( title ) )
		end
	end )
	ZM:subscribeToGlobalModel( controller, "ChallengesZMNearCompletion", "description", function ( modelRef )
		local description = Engine.GetModelValue( modelRef )
		if description then
			ZM.NearCompletionWidget.ChallengeDescription.textBox:setText( Engine.Localize( description ) )
		end
	end )
	ZM:registerEventHandler( "gain_focus", function ( element, event )
		local f42_local0 = nil
		if element.gainFocus then
			f42_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f42_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		return f42_local0
	end )
	ZM:registerEventHandler( "lose_focus", function ( element, event )
		local f43_local0 = nil
		if element.loseFocus then
			f43_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f43_local0 = element.super:loseFocus( event )
		end
		return f43_local0
	end )
	menu:AddButtonCallbackFunction( ZM, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f44_arg0, f44_arg1, f44_arg2, f44_arg3 )
		if not IsElementInState( f44_arg0, "Disabled" ) then
			SetGlobalModelValue( "challengeGameMode", "zm" )
			OpenOverlay( self, "Challenges_ZM", f44_arg2, "", "" )
			return true
		else
			
		end
	end, function ( f45_arg0, f45_arg1, f45_arg2 )
		CoD.Menu.SetButtonLabel( f45_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		if not IsElementInState( f45_arg0, "Disabled" ) then
			return true
		else
			return false
		end
	end, false )
	ZM:mergeStateConditions( {
		{
			stateName = "Disable",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		},
		{
			stateName = "NoNearComplete",
			condition = function ( menu, element, event )
				return IsElementInState( element, "NoNearComplete" )
			end
		}
	} )
	self:addElement( ZM )
	self.ZM = ZM
	
	-- CP.navigation = {
	-- 	right = MP
	-- }
	-- MP.navigation = {
	-- 	left = CP,
	-- 	right = ZM
	-- }
	-- ZM.navigation = {
	-- 	left = MP
	-- }
	CoD.Menu.AddNavigationHandler( menu, self, controller )
	CP.id = "CP"
	MP.id = "MP"
	ZM.id = "ZM"
	self:registerEventHandler( "gain_focus", function ( element, event )
		if element.m_focusable and element.MP:processEvent( event ) then
			return true
		else
			return LUI.UIElement.gainFocus( element, event )
		end
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.CP:close()
		element.MP:close()
		element.ZM:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end

