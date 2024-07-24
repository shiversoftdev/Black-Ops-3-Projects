require( "ui.uieditor.widgets.StartMenu.StartMenu_Background" )
require( "ui.uieditor.widgets.Lobby.Common.FE_Menu_LeftGraphics" )
require( "ui.uieditor.widgets.BackgroundFrames.GenericMenuFrameIdentity" )
require( "ui.uieditor.widgets.StartMenu.StartMenu_Barracks_Button_CP" )
require( "ui.uieditor.menus.Barracks.CombatRecordCP.CombatRecordCP" )
require( "ui.uieditor.menus.Social.Social_InspectPlayerPopupLoading" )
require( "ui.uieditor.widgets.StartMenu.StartMenu_Barracks_Button_MP" )
require( "ui.uieditor.menus.Barracks.CombatRecordMP.CombatRecordMP" )
require( "ui.uieditor.widgets.StartMenu.StartMenu_Barracks_Button_ZM" )
require( "ui.uieditor.menus.Barracks.CombatRecordZM.CombatRecordZM" )

EnableGlobals()

local PreLoadFunc = function ( self, controller )
	self.disablePopupOpenCloseAnim = true
	local f1_local0 = Engine.GetModel( Engine.GetGlobalModel(), "combatRecordMode" )
	if f1_local0 then
		CoD.perController[controller].previousCombatRecordMode = Engine.GetModelValue( f1_local0 )
	end
end

LUI.createMenu.ViewRemoteCombatRecord = function ( controller )
	local self = CoD.Menu.NewForUIEditor( "ViewRemoteCombatRecord" )
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
	self.soundSet = "ChooseDecal"
	self:setOwner( controller )
	self:setLeftRight( true, true, 0, 0 )
	self:setTopBottom( true, true, 0, 0 )
	self:playSound( "menu_open", controller )
	self.buttonModel = Engine.CreateModel( Engine.GetModelForController( controller ), "ViewRemoteCombatRecord.buttonPrompts" )
	local f2_local1 = self
	self.anyChildUsesUpdateState = true
	
	local StartMenuBackground0 = CoD.StartMenu_Background.new( f2_local1, controller )
	StartMenuBackground0:setLeftRight( true, true, 0, 0 )
	StartMenuBackground0:setTopBottom( true, true, 0, 0 )
	StartMenuBackground0:mergeStateConditions( {
		{
			stateName = "InGame",
			condition = function ( menu, element, event )
				return IsInGame()
			end
		}
	} )
	self:addElement( StartMenuBackground0 )
	self.StartMenuBackground0 = StartMenuBackground0
	
	local BlackBG = LUI.UIImage.new()
	BlackBG:setLeftRight( true, true, 0, 0 )
	BlackBG:setTopBottom( true, true, 0, 0 )
	BlackBG:setImage( RegisterImage( "uie_fe_cp_background" ) )
	self:addElement( BlackBG )
	self.BlackBG = BlackBG
	
	local FEMenuLeftGraphics = CoD.FE_Menu_LeftGraphics.new( f2_local1, controller )
	FEMenuLeftGraphics:setLeftRight( true, false, 18, 70 )
	FEMenuLeftGraphics:setTopBottom( true, false, 91, 708.25 )
	self:addElement( FEMenuLeftGraphics )
	self.FEMenuLeftGraphics = FEMenuLeftGraphics
	
	local MenuFrame = CoD.GenericMenuFrameIdentity.new( f2_local1, controller )
	MenuFrame:setLeftRight( true, true, 0, 0 )
	MenuFrame:setTopBottom( true, true, 0, 0 )
	MenuFrame.titleLabel:setText( Engine.Localize( "MENU_VIEW_COMBAT_RECORD" ) )
	MenuFrame.cac3dTitleIntermediary0.FE3dTitleContainer0.MenuTitle.TextBox1.Label0:setText( Engine.Localize( "MENU_VIEW_COMBAT_RECORD" ) )
	self:addElement( MenuFrame )
	self.MenuFrame = MenuFrame
	
	-- local StartMenuBarracksButtonCP = CoD.StartMenu_Barracks_Button_CP.new( f2_local1, controller )
	-- StartMenuBarracksButtonCP:setLeftRight( false, false, -558, -192 )
	-- StartMenuBarracksButtonCP:setTopBottom( false, false, -218.5, 218.5 )
	-- StartMenuBarracksButtonCP.SessionName:setText( Engine.Localize( "MENU_CAMPAIGN_CAPS" ) )
	-- StartMenuBarracksButtonCP.StartMenuIdentitySubTitle0.SubTitle:setText( Engine.Localize( "MENU_BARRACKS_DESC" ) )
	-- StartMenuBarracksButtonCP.TotalKills.Title:setText( Engine.Localize( CombatRecordGetStat( controller, "playerstatslist.kills.statvalue", "888" ) ) )
	-- StartMenuBarracksButtonCP.unlockRequirements:setText( LocalizeIntoString( "CPUI_REQUIRES_LEVEL", "2" ) )
	-- StartMenuBarracksButtonCP:subscribeToGlobalModel( controller, "SocialPlayerInfo", nil, function ( modelRef )
	-- 	StartMenuBarracksButtonCP:setModel( modelRef, controller )
	-- end )
	-- StartMenuBarracksButtonCP:subscribeToGlobalModel( controller, "SocialPlayerInfo", "cpRankIcon", function ( modelRef )
	-- 	local cpRankIcon = Engine.GetModelValue( modelRef )
	-- 	if cpRankIcon then
	-- 		StartMenuBarracksButtonCP.Emblem:setImage( RegisterImage( GetRankIconLarge( cpRankIcon ) ) )
	-- 	end
	-- end )
	-- StartMenuBarracksButtonCP:subscribeToGlobalModel( controller, "SocialPlayerInfo", "cpRank", function ( modelRef )
	-- 	local cpRank = Engine.GetModelValue( modelRef )
	-- 	if cpRank then
	-- 		StartMenuBarracksButtonCP.RankName:setText( Engine.Localize( RankToTitleString( "cp", cpRank ) ) )
	-- 	end
	-- end )
	-- StartMenuBarracksButtonCP:subscribeToGlobalModel( controller, "SocialPlayerInfo", "cpRank", function ( modelRef )
	-- 	local cpRank = Engine.GetModelValue( modelRef )
	-- 	if cpRank then
	-- 		StartMenuBarracksButtonCP.Rank:setText( RankToLevelString( "cp", cpRank ) )
	-- 	end
	-- end )
	-- StartMenuBarracksButtonCP:subscribeToGlobalModel( controller, "CombatRecordCPPercentComplete", "percent", function ( modelRef )
	-- 	local percent = Engine.GetModelValue( modelRef )
	-- 	if percent then
	-- 		StartMenuBarracksButtonCP.PercentComplete.Title:setText( Engine.Localize( percent ) )
	-- 	end
	-- end )
	-- StartMenuBarracksButtonCP:registerEventHandler( "gain_focus", function ( element, event )
	-- 	local f9_local0 = nil
	-- 	if element.gainFocus then
	-- 		f9_local0 = element:gainFocus( event )
	-- 	elseif element.super.gainFocus then
	-- 		f9_local0 = element.super:gainFocus( event )
	-- 	end
	-- 	CoD.Menu.UpdateButtonShownState( element, f2_local1, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
	-- 	return f9_local0
	-- end )
	-- StartMenuBarracksButtonCP:registerEventHandler( "lose_focus", function ( element, event )
	-- 	local f10_local0 = nil
	-- 	if element.loseFocus then
	-- 		f10_local0 = element:loseFocus( event )
	-- 	elseif element.super.loseFocus then
	-- 		f10_local0 = element.super:loseFocus( event )
	-- 	end
	-- 	return f10_local0
	-- end )
	-- f2_local1:AddButtonCallbackFunction( StartMenuBarracksButtonCP, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f11_arg0, f11_arg1, f11_arg2, f11_arg3 )
	-- 	if not IsElementInState( f11_arg0, "Disable" ) then
	-- 		SetGlobalModelValue( "combatRecordMode", "cp" )
	-- 		CombatRecordSetMenuForPostStatsLoad( self, "CombatRecordCP" )
	-- 		CombatRecordSetXUIDFromSelectedFriend( f11_arg2 )
	-- 		OpenPopup( self, "Social_InspectPlayerPopupLoading", f11_arg2, "", "" )
	-- 		CombatRecordReadOtherPlayerStats( f11_arg2 )
	-- 		return true
	-- 	else
			
	-- 	end
	-- end, function ( f12_arg0, f12_arg1, f12_arg2 )
	-- 	if not IsElementInState( f12_arg0, "Disable" ) then
	-- 		CoD.Menu.SetButtonLabel( f12_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
	-- 		return true
	-- 	else
	-- 		return false
	-- 	end
	-- end, false )
	-- StartMenuBarracksButtonCP:mergeStateConditions( {
	-- 	{
	-- 		stateName = "Disable",
	-- 		condition = function ( menu, element, event )
	-- 			return IsCPCombatRecordLockedForSocialPlayerInfo( controller, element )
	-- 		end
	-- 	},
	-- 	{
	-- 		stateName = "NoStats",
	-- 		condition = function ( menu, element, event )
	-- 			return AlwaysTrue()
	-- 		end
	-- 	}
	-- } )
	-- self:addElement( StartMenuBarracksButtonCP )
	-- self.StartMenuBarracksButtonCP = StartMenuBarracksButtonCP
	
	local StartMenuBarracksButtonMP = CoD.StartMenu_Barracks_Button_MP.new( f2_local1, controller )
	StartMenuBarracksButtonMP:setLeftRight( false, false, -183, 183 )
	StartMenuBarracksButtonMP:setTopBottom( false, false, -218.5, 218.44 )
	StartMenuBarracksButtonMP.SessionName:setText( Engine.Localize( "ZOMBIE BLOOD RUSH" ) )
	StartMenuBarracksButtonMP.StartMenuIdentitySubTitle0.SubTitle:setText( Engine.Localize( "MENU_BARRACKS_DESC" ) )
	StartMenuBarracksButtonMP.TotalKills.Title:setText( Engine.Localize( CombatRecordGetStat( controller, "playerstatslist.kills.statvalue", "888" ) ) )
	StartMenuBarracksButtonMP.KD.Title:setText( Engine.Localize( CombatRecordGetTwoStatRatio( controller, "playerstatslist.kills.statvalue", "playerstatslist.deaths.statvalue", "0.93" ) ) )
	StartMenuBarracksButtonMP.SPM.Title:setText( Engine.Localize( CombatRecordGetSPM( controller, "playerstatslist.score.statvalue", "playerstatslist.time_played_total.statvalue", "425" ) ) )
	StartMenuBarracksButtonMP.WL.Title:setText( Engine.Localize( CombatRecordGetTwoStatRatio( controller, "playerstatslist.wins.statvalue", "playerstatslist.losses.statvalue", "0.93" ) ) )
	StartMenuBarracksButtonMP.unlockRequirements:setText( LocalizeIntoString( "CPUI_REQUIRES_LEVEL", "7" ) )
	StartMenuBarracksButtonMP:subscribeToGlobalModel( controller, "SocialPlayerInfo", nil, function ( modelRef )
		StartMenuBarracksButtonMP:setModel( modelRef, controller )
	end )
	StartMenuBarracksButtonMP:subscribeToGlobalModel( controller, "SocialPlayerInfo", "mpRankIcon", function ( modelRef )
		local mpRankIcon = Engine.GetModelValue( modelRef )
		if mpRankIcon then
			StartMenuBarracksButtonMP.Emblem:setImage( RegisterImage( "uie_t7_icon_inventory_worm_inuse" ) ) -- TODO
		end
	end )
	StartMenuBarracksButtonMP:subscribeToGlobalModel( controller, "SocialPlayerInfo", "mpRank", function ( modelRef )
		local mpRank = Engine.GetModelValue( modelRef )
		if mpRank then
			StartMenuBarracksButtonMP.RankName:setText( Engine.Localize( "BLOOD HUNTER" ) ) -- TODO
		end
	end )
	StartMenuBarracksButtonMP:subscribeToGlobalModel( controller, "SocialPlayerInfo", "mpPrestige", function ( modelRef )
		local mpPrestige = 11 -- TODO
		if mpPrestige then
			StartMenuBarracksButtonMP.Rank:setRGB( SetToParagonColorIfPrestigeMasterByPLevel( "mp", 255, 255, 255, mpPrestige ) )
		end
	end )
	StartMenuBarracksButtonMP:subscribeToGlobalModel( controller, "SocialPlayerInfo", "mpRank", function ( modelRef )
		local mpRank = Engine.GetModelValue( modelRef )
		if mpRank then
			StartMenuBarracksButtonMP.Rank:setText( "1000" ) -- TODO
		end
	end )
	StartMenuBarracksButtonMP:subscribeToGlobalModel( controller, "SocialPlayerInfo", "mpPrestige", function ( modelRef )
		local mpPrestige = 11 -- TODO
		if mpPrestige then
			StartMenuBarracksButtonMP.PrestigeMasterTierWidget:setAlpha( ShowIfPrestigeMasterByPLevel( "mp", mpPrestige ) )
		end
	end )
	StartMenuBarracksButtonMP:subscribeToGlobalModel( controller, "SocialPlayerInfo", "mpPrestigeMasterTier", function ( modelRef )
		StartMenuBarracksButtonMP.PrestigeMasterTierWidget.ParagonStars:setHorizontalCount( 11 )
	end )
	StartMenuBarracksButtonMP:registerEventHandler( "gain_focus", function ( element, event )
		local f22_local0 = nil
		if element.gainFocus then
			f22_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f22_local0 = element.super:gainFocus( event )
		end
		CoD.Menu.UpdateButtonShownState( element, f2_local1, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		return f22_local0
	end )
	StartMenuBarracksButtonMP:registerEventHandler( "lose_focus", function ( element, event )
		local f23_local0 = nil
		if element.loseFocus then
			f23_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f23_local0 = element.super:loseFocus( event )
		end
		return f23_local0
	end )
	f2_local1:AddButtonCallbackFunction( StartMenuBarracksButtonMP, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f24_arg0, f24_arg1, f24_arg2, f24_arg3 )
		if not IsElementInState( f24_arg0, "Disable" ) then
			SetGlobalModelValue( "combatRecordMode", "mp" )
			CombatRecordSetMenuForPostStatsLoad( self, "CombatRecordMP" )
			CombatRecordSetXUIDFromSelectedFriend( f24_arg2 )
			OpenPopup( self, "Social_InspectPlayerPopupLoading", f24_arg2, "", "" )
			CombatRecordReadOtherPlayerStats( f24_arg2 )
			return true
		else
			
		end
	end, function ( f25_arg0, f25_arg1, f25_arg2 )
		if not IsElementInState( f25_arg0, "Disable" ) then
			CoD.Menu.SetButtonLabel( f25_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
			return true
		else
			return false
		end
	end, false )
	StartMenuBarracksButtonMP:mergeStateConditions( {
		{
			stateName = "Disable",
			condition = function ( menu, element, event )
				return IsMPCombatRecordLockedForSocialPlayerInfo( controller, element )
			end
		},
		{
			stateName = "NoStats",
			condition = function ( menu, element, event )
				return AlwaysTrue()
			end
		}
	} )
	self:addElement( StartMenuBarracksButtonMP )
	self.StartMenuBarracksButtonMP = StartMenuBarracksButtonMP
	
	-- local StartMenuBarracksButtonZM = CoD.StartMenu_Barracks_Button_ZM.new( f2_local1, controller )
	-- StartMenuBarracksButtonZM:setLeftRight( false, false, 193.5, 559.5 )
	-- StartMenuBarracksButtonZM:setTopBottom( false, false, -218.5, 218.5 )
	-- StartMenuBarracksButtonZM.SessionName:setText( Engine.Localize( "MENU_ZOMBIES_CAPS" ) )
	-- StartMenuBarracksButtonZM.StartMenuIdentitySubTitle0.SubTitle:setText( Engine.Localize( "MENU_BARRACKS_DESC" ) )
	-- StartMenuBarracksButtonZM.TotalKills.Title:setText( Engine.Localize( CombatRecordGetStat( controller, "playerstatslist.kills.statvalue", "888" ) ) )
	-- StartMenuBarracksButtonZM.RoundsSurvived.Title:setText( Engine.Localize( "0" ) )
	-- StartMenuBarracksButtonZM.SPM.Title:setText( Engine.Localize( CombatRecordGetTwoStatRatioRounded( controller, "playerstatslist.total_rounds_survived.statvalue", "playerstatslist.total_games_played.statvalue", "888" ) ) )
	-- StartMenuBarracksButtonZM.unlockRequirements:setText( LocalizeIntoString( "CPUI_REQUIRES_LEVEL", "2" ) )
	-- StartMenuBarracksButtonZM:subscribeToGlobalModel( controller, "SocialPlayerInfo", nil, function ( modelRef )
	-- 	StartMenuBarracksButtonZM:setModel( modelRef, controller )
	-- end )
	-- StartMenuBarracksButtonZM:subscribeToGlobalModel( controller, "SocialPlayerInfo", "zmRankIcon", function ( modelRef )
	-- 	local zmRankIcon = Engine.GetModelValue( modelRef )
	-- 	if zmRankIcon then
	-- 		StartMenuBarracksButtonZM.Emblem:setImage( RegisterImage( GetRankIconLarge( zmRankIcon ) ) )
	-- 	end
	-- end )
	-- StartMenuBarracksButtonZM:subscribeToGlobalModel( controller, "SocialPlayerInfo", "zmRank", function ( modelRef )
	-- 	local zmRank = Engine.GetModelValue( modelRef )
	-- 	if zmRank then
	-- 		StartMenuBarracksButtonZM.RankName:setText( Engine.Localize( RankToTitleStringFromSocialPlayerInfo( controller, "zm", zmRank ) ) )
	-- 	end
	-- end )
	-- StartMenuBarracksButtonZM:subscribeToGlobalModel( controller, "SocialPlayerInfo", "zmPrestige", function ( modelRef )
	-- 	local zmPrestige = Engine.GetModelValue( modelRef )
	-- 	if zmPrestige then
	-- 		StartMenuBarracksButtonZM.Rank:setRGB( SetToParagonColorIfPrestigeMasterByPLevel( "zm", 255, 255, 255, zmPrestige ) )
	-- 	end
	-- end )
	-- StartMenuBarracksButtonZM:subscribeToGlobalModel( controller, "SocialPlayerInfo", "zmRank", function ( modelRef )
	-- 	local zmRank = Engine.GetModelValue( modelRef )
	-- 	if zmRank then
	-- 		StartMenuBarracksButtonZM.Rank:setText( RankToLevelString( "zm", zmRank ) )
	-- 	end
	-- end )
	-- StartMenuBarracksButtonZM:subscribeToGlobalModel( controller, "SocialPlayerInfo", "zmPrestige", function ( modelRef )
	-- 	local zmPrestige = Engine.GetModelValue( modelRef )
	-- 	if zmPrestige then
	-- 		StartMenuBarracksButtonZM.PrestigeMasterTierWidget:setAlpha( ShowIfPrestigeMasterByPLevel( "zm", zmPrestige ) )
	-- 	end
	-- end )
	-- StartMenuBarracksButtonZM:subscribeToGlobalModel( controller, "SocialPlayerInfo", "zmPrestigeMasterTier", function ( modelRef )
	-- 	local zmPrestigeMasterTier = Engine.GetModelValue( modelRef )
	-- 	if zmPrestigeMasterTier then
	-- 		StartMenuBarracksButtonZM.PrestigeMasterTierWidget.ParagonStars:setHorizontalCount( zmPrestigeMasterTier )
	-- 	end
	-- end )
	-- StartMenuBarracksButtonZM:registerEventHandler( "gain_focus", function ( element, event )
	-- 	local f35_local0 = nil
	-- 	if element.gainFocus then
	-- 		f35_local0 = element:gainFocus( event )
	-- 	elseif element.super.gainFocus then
	-- 		f35_local0 = element.super:gainFocus( event )
	-- 	end
	-- 	CoD.Menu.UpdateButtonShownState( element, f2_local1, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
	-- 	return f35_local0
	-- end )
	-- StartMenuBarracksButtonZM:registerEventHandler( "lose_focus", function ( element, event )
	-- 	local f36_local0 = nil
	-- 	if element.loseFocus then
	-- 		f36_local0 = element:loseFocus( event )
	-- 	elseif element.super.loseFocus then
	-- 		f36_local0 = element.super:loseFocus( event )
	-- 	end
	-- 	return f36_local0
	-- end )
	-- f2_local1:AddButtonCallbackFunction( StartMenuBarracksButtonZM, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, nil, function ( f37_arg0, f37_arg1, f37_arg2, f37_arg3 )
	-- 	if not IsElementInState( f37_arg0, "Disable" ) then
	-- 		SetGlobalModelValue( "combatRecordMode", "zm" )
	-- 		CombatRecordSetMenuForPostStatsLoad( self, "CombatRecordZM" )
	-- 		CombatRecordSetXUIDFromSelectedFriend( f37_arg2 )
	-- 		OpenPopup( self, "Social_InspectPlayerPopupLoading", f37_arg2, "", "" )
	-- 		CombatRecordReadOtherPlayerStats( f37_arg2 )
	-- 		return true
	-- 	else
			
	-- 	end
	-- end, function ( f38_arg0, f38_arg1, f38_arg2 )
	-- 	if not IsElementInState( f38_arg0, "Disable" ) then
	-- 		CoD.Menu.SetButtonLabel( f38_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
	-- 		return true
	-- 	else
	-- 		return false
	-- 	end
	-- end, false )
	-- StartMenuBarracksButtonZM:mergeStateConditions( {
	-- 	{
	-- 		stateName = "Disable",
	-- 		condition = function ( menu, element, event )
	-- 			return IsZMCombatRecordLockedForSocialPlayerInfo( controller, element )
	-- 		end
	-- 	},
	-- 	{
	-- 		stateName = "NoStats",
	-- 		condition = function ( menu, element, event )
	-- 			return AlwaysTrue()
	-- 		end
	-- 	}
	-- } )
	-- self:addElement( StartMenuBarracksButtonZM )
	-- self.StartMenuBarracksButtonZM = StartMenuBarracksButtonZM
	
	-- StartMenuBarracksButtonCP.navigation = {
	-- 	right = StartMenuBarracksButtonMP
	-- }
	-- StartMenuBarracksButtonMP.navigation = {
	-- 	left = StartMenuBarracksButtonCP,
	-- 	right = StartMenuBarracksButtonZM
	-- }
	-- StartMenuBarracksButtonZM.navigation = {
	-- 	left = StartMenuBarracksButtonMP
	-- }
	CoD.Menu.AddNavigationHandler( f2_local1, self, controller )
	self:registerEventHandler( "menu_loaded", function ( element, event )
		local f41_local0 = nil
		CombatRecordUpdateSelfIdentityWidget( self, controller )
		if not f41_local0 then
			f41_local0 = element:dispatchEventToChildren( event )
		end
		return f41_local0
	end )
	f2_local1:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, "ESCAPE", function ( f42_arg0, f42_arg1, f42_arg2, f42_arg3 )
		GoBack( self, f42_arg2 )
		ClearMenuSavedState( f42_arg1 )
		return true
	end, function ( f43_arg0, f43_arg1, f43_arg2 )
		CoD.Menu.SetButtonLabel( f43_arg1, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, "MENU_BACK" )
		return true
	end, false )
	LUI.OverrideFunction_CallOriginalFirst( self, "close", function ( element )
		if not IsPerControllerTablePropertyValue( controller, "previousCombatRecordMode", nil ) then
			SetGlobalModelValueArg( "prestigeGameMode", Enum.eModes.MODE_INVALID )
			SetGlobalModelValueArg( "combatRecordMode", CoD.perController[controller].previousCombatRecordMode )
		else
			SetGlobalModelValueArg( "prestigeGameMode", Enum.eModes.MODE_INVALID )
		end
	end )
	MenuFrame:setModel( self.buttonModel, controller )
	-- StartMenuBarracksButtonCP.id = "StartMenuBarracksButtonCP"
	StartMenuBarracksButtonMP.id = "StartMenuBarracksButtonMP"
	-- StartMenuBarracksButtonZM.id = "StartMenuBarracksButtonZM"
	self:processEvent( {
		name = "menu_loaded",
		controller = controller
	} )
	self:processEvent( {
		name = "update_state",
		menu = f2_local1
	} )
	if not self:restoreState() then
		self.StartMenuBarracksButtonMP:processEvent( {
			name = "gain_focus",
			controller = controller
		} )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.StartMenuBackground0:close()
		element.FEMenuLeftGraphics:close()
		element.MenuFrame:close()
		-- element.StartMenuBarracksButtonCP:close()
		element.StartMenuBarracksButtonMP:close()
		-- element.StartMenuBarracksButtonZM:close()
		Engine.UnsubscribeAndFreeModel( Engine.GetModel( Engine.GetModelForController( controller ), "ViewRemoteCombatRecord.buttonPrompts" ) )
	end )
	if PostLoadFunc then
		PostLoadFunc( self, controller )
	end
	
	return self
end

