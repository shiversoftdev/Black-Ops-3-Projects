EnableGlobals()

require( "ui.uieditor.widgets.EndGameFlow.Top3PlayerScoreBlurBox" )
require( "ui.uieditor.widgets.Lobby.Common.FE_ButtonPanel" )
require( "ui.uieditor.widgets.HelperWidgets.TextWithBg" )
require( "ui.uieditor.widgets.Scoreboard.scoreboardPingBackground" )
require( "ui.uieditor.widgets.Lobby.Common.FE_FocusBarContainer" )



local PostLoadFunc = function ( self, controller, menu )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "factions.isCoDCaster" ), function ( modelRef )
		local f2_local0 = self:getModel( controller, "team" )
		if f2_local0 then
			Engine.ForceNotifyModelSubscriptions( f2_local0 )
		end
	end )
end

local PlayerColors = 
{
	["7"] = {1, 1, 1},
	["1"] = {0x0A / 0xFF, 0x4c / 0xFF, 0xf2 / 0xFF},
	["2"] = {0xe6 / 0xFF, 0xda / 0xFF, 0x83 / 0xFF},
	["3"] = {0x83 / 0xFF, 0xe6 / 0xFF, 0x83 / 0xFF},
	["4"] = {0xff / 0xFF, 0x00       , 0xbb / 0xFF},
	["5"] = {0x00       , 0xe1 / 0xFF, 0xff / 0xFF},
	["6"] = {0xff / 0xFF, 0x8c / 0xFF, 0x00       },
	["0"] = {0x94 / 0xFF, 0x52 / 0xFF, 0xf7 / 0xFF},
}

CoD.ScoreboardRowWidget = InheritFrom( LUI.UIElement )
CoD.ScoreboardRowWidget.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
	self:setUseStencil( false )
	self:setClass( CoD.ScoreboardRowWidget )
	self.id = "ScoreboardRowWidget"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 853 )
	self:setTopBottom( true, false, 0, 25 )
	self:makeFocusable()
	self:setHandleMouse( true )
	self.anyChildUsesUpdateState = true
	
	local BlackBar = LUI.UIImage.new()
	BlackBar:setLeftRight( true, true, 0, -60 )
	BlackBar:setTopBottom( true, true, 0, 0 )
	BlackBar:setRGB( 0, 0, 0 )
	BlackBar:setAlpha( 0 )
	self:addElement( BlackBar )
	self.BlackBar = BlackBar
	
	local Top3PlayerScoreBlurBox0 = CoD.Top3PlayerScoreBlurBox.new( menu, controller )
	Top3PlayerScoreBlurBox0:setLeftRight( true, true, 0, -60 )
	Top3PlayerScoreBlurBox0:setTopBottom( true, true, 0, 0 )
	Top3PlayerScoreBlurBox0:setRFTMaterial( LUI.UIImage.GetCachedMaterial( "uie_scene_blur_pass_2" ) )
	Top3PlayerScoreBlurBox0:setShaderVector( 0, 10, 10, 0, 0 )
	self:addElement( Top3PlayerScoreBlurBox0 )
	self.Top3PlayerScoreBlurBox0 = Top3PlayerScoreBlurBox0
	
	local VSpanel = CoD.FE_ButtonPanel.new( menu, controller )
	VSpanel:setLeftRight( true, true, 0, -60 )
	VSpanel:setTopBottom( true, true, 0, 0 )
	VSpanel:setRGB( 0, 0, 0 )
	VSpanel:setAlpha( 0.45 )
	self:addElement( VSpanel )
	self.VSpanel = VSpanel
	
	local Rank = LUI.UIText.new()
	Rank:setLeftRight( true, false, 23, 52 )
	Rank:setTopBottom( false, false, -10.5, 11.5 )
	Rank:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
	Rank:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	Rank:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
	Rank:linkToElementModel( self, "clientNum", true, function ( modelRef )
		local clientNum = Engine.GetModelValue( modelRef )
		if clientNum then
			Rank:setRGB( SetToParagonColorIfPrestigeMasterForScoreboard( controller, 255, 255, 255, clientNum ) )
		end
	end )
	Rank:linkToElementModel( self, "clientNum", true, function ( modelRef )
		local clientNum = Engine.GetModelValue( modelRef )
		if clientNum then
			Rank:setText( Engine.Localize( GetScoreboardPlayerRank( controller, clientNum ) ) )
		end
	end )
	self:addElement( Rank )
	self.Rank = Rank
	
	local RankIcon = LUI.UIImage.new()
	RankIcon:setLeftRight( true, false, 52, 76 )
	RankIcon:setTopBottom( false, false, -12, 12 )
	RankIcon:linkToElementModel( self, "clientNum", true, function ( modelRef )
		local clientNum = Engine.GetModelValue( modelRef )
		if clientNum then
			RankIcon:setImage( RegisterImage( GetScoreboardPlayerRankIcon( controller, clientNum ) ) )
		end
	end )
	self:addElement( RankIcon )
	self.RankIcon = RankIcon
	
	local Gamertag = LUI.UIText.new()
	Gamertag:setLeftRight( true, false, 82.41, 335.41 )
	Gamertag:setTopBottom( false, false, -12, 10 )
	Gamertag:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
	Gamertag:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
	Gamertag:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
	Gamertag:linkToElementModel( self, "clientNum", true, function ( modelRef )
		local clientNum = Engine.GetModelValue( modelRef )
		if clientNum then
			Gamertag:setText( GetClientNameAndClanTag( controller, clientNum ) )
			if PlayerColors[clientNum .. ""] then
				Gamertag:setRGB(unpack(PlayerColors[clientNum .. ""]))
			end
		end
	end )
	self:addElement( Gamertag )
	self.Gamertag = Gamertag
	
	local ScoreColumn1 = CoD.TextWithBg.new( menu, controller )
	ScoreColumn1:setLeftRight( false, true, -493.09, -406.09 )
	ScoreColumn1:setTopBottom( true, true, 0, 0 )
	ScoreColumn1.Bg:setAlpha( 0.3 )
	ScoreColumn1.Text:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
	ScoreColumn1.Text:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	ScoreColumn1:linkToElementModel( self, "team", true, function ( modelRef )
		local team = Engine.GetModelValue( modelRef )
		if team then
			ScoreColumn1.Bg:setRGB( GetScoreboardTeamBackgroundColor( controller, team ) )
		end
	end )
	ScoreColumn1:linkToElementModel( self, "clientNumScoreInfoUpdated", true, function ( modelRef )
		local clientNumScoreInfoUpdated = Engine.GetModelValue( modelRef )
		if clientNumScoreInfoUpdated then
			ScoreColumn1.Text:setText( Engine.Localize( GetScoreboardPlayerScoreColumn( controller, 0, clientNumScoreInfoUpdated ) ) )
		end
	end )
	ScoreColumn1:linkToElementModel( self, "clientNum", true, function ( modelRef )
		local clientNum = Engine.GetModelValue( modelRef )
		if clientNum then
			if PlayerColors[clientNum .. ""] then
				ScoreColumn1.Text:setRGB(unpack(PlayerColors[clientNum .. ""]))
			end
		end
	end )
	self:addElement( ScoreColumn1 )
	self.ScoreColumn1 = ScoreColumn1
	
	local ScoreColumn2 = CoD.TextWithBg.new( menu, controller )
	ScoreColumn2:setLeftRight( false, true, -406.09, -319.09 )
	ScoreColumn2:setTopBottom( true, true, 0, 0 )
	ScoreColumn2.Bg:setRGB( 0.3, 0.27, 0.27 )
	ScoreColumn2.Bg:setAlpha( 0 )
	ScoreColumn2.Text:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
	ScoreColumn2.Text:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	ScoreColumn2:linkToElementModel( self, "clientNumScoreInfoUpdated", true, function ( modelRef )
		local clientNumScoreInfoUpdated = Engine.GetModelValue( modelRef )
		if clientNumScoreInfoUpdated then
			ScoreColumn2.Text:setText( Engine.Localize( GetScoreboardPlayerScoreColumn( controller, 1, clientNumScoreInfoUpdated ) ) )
		end
	end )
	ScoreColumn2:linkToElementModel( self, "clientNum", true, function ( modelRef )
		local clientNum = Engine.GetModelValue( modelRef )
		if clientNum then
			if PlayerColors[clientNum .. ""] then
				ScoreColumn2.Text:setRGB(unpack(PlayerColors[clientNum .. ""]))
			end
		end
	end )
	self:addElement( ScoreColumn2 )
	self.ScoreColumn2 = ScoreColumn2
	
	local ScoreColumn3 = CoD.TextWithBg.new( menu, controller )
	ScoreColumn3:setLeftRight( false, true, -319.09, -232.09 )
	ScoreColumn3:setTopBottom( true, true, 0, 0 )
	ScoreColumn3.Bg:setAlpha( 0.3 )
	ScoreColumn3.Text:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
	ScoreColumn3.Text:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	ScoreColumn3:linkToElementModel( self, "team", true, function ( modelRef )
		local team = Engine.GetModelValue( modelRef )
		if team then
			ScoreColumn3.Bg:setRGB( GetScoreboardTeamBackgroundColor( controller, team ) )
		end
	end )
	ScoreColumn3:linkToElementModel( self, "clientNumScoreInfoUpdated", true, function ( modelRef )
		local clientNumScoreInfoUpdated = Engine.GetModelValue( modelRef )
		if clientNumScoreInfoUpdated then
			ScoreColumn3.Text:setText( Engine.Localize( GetScoreboardPlayerScoreColumn( controller, 2, clientNumScoreInfoUpdated ) ) )
		end
	end )
	ScoreColumn3:linkToElementModel( self, "clientNum", true, function ( modelRef )
		local clientNum = Engine.GetModelValue( modelRef )
		if clientNum then
			if PlayerColors[clientNum .. ""] then
				ScoreColumn3.Text:setRGB(unpack(PlayerColors[clientNum .. ""]))
			end
		end
	end )
	self:addElement( ScoreColumn3 )
	self.ScoreColumn3 = ScoreColumn3
	
	local ScoreColumn4 = CoD.TextWithBg.new( menu, controller )
	ScoreColumn4:setLeftRight( false, true, -232.09, -145.09 )
	ScoreColumn4:setTopBottom( true, true, 0, 0 )
	ScoreColumn4.Bg:setRGB( 0.3, 0.27, 0.27 )
	ScoreColumn4.Bg:setAlpha( 0 )
	ScoreColumn4.Text:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
	ScoreColumn4.Text:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	ScoreColumn4:linkToElementModel( self, "clientNumScoreInfoUpdated", true, function ( modelRef )
		local clientNumScoreInfoUpdated = Engine.GetModelValue( modelRef )
		if clientNumScoreInfoUpdated then
			ScoreColumn4.Text:setText( Engine.Localize( GetScoreboardPlayerScoreColumn( controller, 3, clientNumScoreInfoUpdated ) ) )
		end
	end )
	ScoreColumn4:linkToElementModel( self, "clientNum", true, function ( modelRef )
		local clientNum = Engine.GetModelValue( modelRef )
		if clientNum then
			if PlayerColors[clientNum .. ""] then
				ScoreColumn4.Text:setRGB(unpack(PlayerColors[clientNum .. ""]))
			end
		end
	end )
	self:addElement( ScoreColumn4 )
	self.ScoreColumn4 = ScoreColumn4
	
	local ScoreColumn5 = CoD.TextWithBg.new( menu, controller )
	ScoreColumn5:setLeftRight( false, true, -145.09, -62.09 )
	ScoreColumn5:setTopBottom( true, true, 0, 0 )
	ScoreColumn5.Bg:setAlpha( 0.3 )
	ScoreColumn5.Text:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
	ScoreColumn5.Text:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	ScoreColumn5:linkToElementModel( self, "team", true, function ( modelRef )
		local team = Engine.GetModelValue( modelRef )
		if team then
			ScoreColumn5.Bg:setRGB( GetScoreboardTeamBackgroundColor( controller, team ) )
		end
	end )
	ScoreColumn5:linkToElementModel( self, "clientNumScoreInfoUpdated", true, function ( modelRef )
		local clientNumScoreInfoUpdated = Engine.GetModelValue( modelRef )
		if clientNumScoreInfoUpdated then
			ScoreColumn5.Text:setText( Engine.Localize( GetScoreboardPlayerScoreColumn( controller, 4, clientNumScoreInfoUpdated ) ) )
		end
	end )
	ScoreColumn5:linkToElementModel( self, "clientNum", true, function ( modelRef )
		local clientNum = Engine.GetModelValue( modelRef )
		if clientNum then
			if PlayerColors[clientNum .. ""] then
				ScoreColumn5.Text:setRGB(unpack(PlayerColors[clientNum .. ""]))
			end
		end
	end )
	self:addElement( ScoreColumn5 )
	self.ScoreColumn5 = ScoreColumn5
	
	local pvBackground = LUI.UIImage.new()
	pvBackground:setLeftRight( false, true, -60, -24 )
	pvBackground:setTopBottom( true, true, 0, 0 )
	pvBackground:setRGB( 0.35, 0.3, 0.3 )
	pvBackground:setAlpha( GetScoreboardPingValueAlpha( 0.5 ) )
	self:addElement( pvBackground )
	self.pvBackground = pvBackground
	
	local scoreboardPingBackground = CoD.scoreboardPingBackground.new( menu, controller )
	scoreboardPingBackground:setLeftRight( true, false, 793, 829 )
	scoreboardPingBackground:setTopBottom( true, false, 0, 25 )
	scoreboardPingBackground:linkToElementModel( self, "ping", true, function ( modelRef )
		local ping = Engine.GetModelValue( modelRef )
		if ping then
			scoreboardPingBackground:setAlpha( GetScoreboardPingBarAlpha( ping ) )
		end
	end )
	scoreboardPingBackground:linkToElementModel( self, nil, false, function ( modelRef )
		scoreboardPingBackground:setModel( modelRef, controller )
	end )
	self:addElement( scoreboardPingBackground )
	self.scoreboardPingBackground = scoreboardPingBackground
	
	local PingText = LUI.UIText.new()
	PingText:setLeftRight( false, true, -60, -28 )
	PingText:setTopBottom( false, false, -11, 11 )
	PingText:setAlpha( GetScoreboardPingValueAlpha( 1 ) )
	PingText:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
	PingText:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_RIGHT )
	PingText:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
	PingText:linkToElementModel( self, "ping", true, function ( modelRef )
		local ping = Engine.GetModelValue( modelRef )
		if ping then
			PingText:setText( ping )
		end
	end )
	self:addElement( PingText )
	self.PingText = PingText
	
	local VOIPImage = LUI.UIImage.new()
	VOIPImage:setLeftRight( true, false, 342, 363 )
	VOIPImage:setTopBottom( true, false, 2.5, 23.5 )
	VOIPImage:setAlpha( 0 )
	VOIPImage:linkToElementModel( self, "clientNum", true, function ( modelRef )
		local clientNum = Engine.GetModelValue( modelRef )
		if clientNum then
			VOIPImage:setupVoipImage( clientNum )
		end
	end )
	self:addElement( VOIPImage )
	self.VOIPImage = VOIPImage
	
	local ScoreboardRowDeathIcon = LUI.UIImage.new()
	ScoreboardRowDeathIcon:setLeftRight( true, false, 0, 23 )
	ScoreboardRowDeathIcon:setTopBottom( true, false, 1, 24 )
	ScoreboardRowDeathIcon:linkToElementModel( self, "clientNum", true, function ( modelRef )
		local clientNum = Engine.GetModelValue( modelRef )
		if clientNum then
			ScoreboardRowDeathIcon:setupClientStatusImage( clientNum )
		end
	end )
	self:addElement( ScoreboardRowDeathIcon )
	self.ScoreboardRowDeathIcon = ScoreboardRowDeathIcon
	
	local FocusBarB = CoD.FE_FocusBarContainer.new( menu, controller )
	FocusBarB:setLeftRight( true, true, 0, -60 )
	FocusBarB:setTopBottom( false, true, -2, 2 )
	FocusBarB:setAlpha( 0 )
	FocusBarB:setZoom( 1 )
	self:addElement( FocusBarB )
	self.FocusBarB = FocusBarB
	
	local FocusBarT = CoD.FE_FocusBarContainer.new( menu, controller )
	FocusBarT:setLeftRight( true, true, 0, -60 )
	FocusBarT:setTopBottom( true, false, -2, 2 )
	FocusBarT:setAlpha( 0 )
	FocusBarT:setZoom( 1 )
	self:addElement( FocusBarT )
	self.FocusBarT = FocusBarT
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 11 )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setRGB( 1, 1, 1 )
				self.Top3PlayerScoreBlurBox0:setAlpha( 1 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				Rank:completeAnimation()
				self.Rank:setLeftRight( true, false, 23, 52 )
				self.Rank:setTopBottom( false, false, -11, 10 )
				self.clipFinished( Rank, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setRGB( 1, 1, 1 )
				self.clipFinished( RankIcon, {} )
				Gamertag:completeAnimation()
				self.Gamertag:setLeftRight( true, false, 82, 335 )
				self.Gamertag:setTopBottom( false, false, -12, 10 )
				self.Gamertag:setRGB( 1, 1, 1 )
				self.clipFinished( Gamertag, {} )
				ScoreColumn1:completeAnimation()
				ScoreColumn1.Text:completeAnimation()
				self.ScoreColumn1:setRGB( 1, 1, 1 )
				self.ScoreColumn1:setAlpha( 1 )
				self.ScoreColumn1.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn1, {} )
				ScoreColumn2:completeAnimation()
				ScoreColumn2.Text:completeAnimation()
				self.ScoreColumn2:setRGB( 1, 1, 1 )
				self.ScoreColumn2:setAlpha( 1 )
				self.ScoreColumn2.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn2, {} )
				ScoreColumn3:completeAnimation()
				ScoreColumn3.Text:completeAnimation()
				self.ScoreColumn3:setRGB( 1, 1, 1 )
				self.ScoreColumn3:setAlpha( 1 )
				self.ScoreColumn3.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn3, {} )
				ScoreColumn4:completeAnimation()
				ScoreColumn4.Text:completeAnimation()
				self.ScoreColumn4:setRGB( 1, 1, 1 )
				self.ScoreColumn4:setAlpha( 1 )
				self.ScoreColumn4.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn4, {} )
				ScoreColumn5:completeAnimation()
				ScoreColumn5.Text:completeAnimation()
				self.ScoreColumn5:setRGB( 1, 1, 1 )
				self.ScoreColumn5:setAlpha( 1 )
				self.ScoreColumn5.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn5, {} )
				FocusBarB:completeAnimation()
				self.FocusBarB:setAlpha( 0 )
				self.clipFinished( FocusBarB, {} )
				FocusBarT:completeAnimation()
				self.FocusBarT:setAlpha( 0 )
				self.clipFinished( FocusBarT, {} )
			end,
			Focus = function ()
				self:setupElementClipCounter( 11 )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setRGB( 1, 1, 1 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				Rank:completeAnimation()
				self.clipFinished( Rank, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setRGB( 1, 1, 1 )
				self.clipFinished( RankIcon, {} )
				Gamertag:completeAnimation()
				self.Gamertag:setRGB( 1, 1, 1 )
				self.clipFinished( Gamertag, {} )
				ScoreColumn1:completeAnimation()
				ScoreColumn1.Text:completeAnimation()
				self.ScoreColumn1:setRGB( 1, 1, 1 )
				self.ScoreColumn1.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn1, {} )
				ScoreColumn2:completeAnimation()
				ScoreColumn2.Text:completeAnimation()
				self.ScoreColumn2:setRGB( 1, 1, 1 )
				self.ScoreColumn2.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn2, {} )
				ScoreColumn3:completeAnimation()
				ScoreColumn3.Text:completeAnimation()
				self.ScoreColumn3:setRGB( 1, 1, 1 )
				self.ScoreColumn3.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn3, {} )
				ScoreColumn4:completeAnimation()
				ScoreColumn4.Text:completeAnimation()
				self.ScoreColumn4:setRGB( 1, 1, 1 )
				self.ScoreColumn4.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn4, {} )
				ScoreColumn5:completeAnimation()
				ScoreColumn5.Text:completeAnimation()
				self.ScoreColumn5:setRGB( 1, 1, 1 )
				self.ScoreColumn5.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn5, {} )
				FocusBarB:completeAnimation()
				self.FocusBarB:setAlpha( 1 )
				self.clipFinished( FocusBarB, {} )
				FocusBarT:completeAnimation()
				self.FocusBarT:setAlpha( 1 )
				self.clipFinished( FocusBarT, {} )
			end
		},
		GenesisEndGame = {
			DefaultClip = function ()
				self:setupElementClipCounter( 11 )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setRGB( 1, 1, 1 )
				self.Top3PlayerScoreBlurBox0:setAlpha( 0 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				Rank:completeAnimation()
				self.Rank:setLeftRight( true, false, 23, 52 )
				self.Rank:setTopBottom( false, false, -11, 10 )
				self.clipFinished( Rank, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setRGB( 1, 1, 1 )
				self.clipFinished( RankIcon, {} )
				Gamertag:completeAnimation()
				self.Gamertag:setLeftRight( true, false, 82, 335 )
				self.Gamertag:setTopBottom( false, false, -12, 10 )
				self.Gamertag:setRGB( 1, 1, 1 )
				self.clipFinished( Gamertag, {} )
				ScoreColumn1:completeAnimation()
				ScoreColumn1.Text:completeAnimation()
				self.ScoreColumn1:setRGB( 1, 1, 1 )
				self.ScoreColumn1:setAlpha( 1 )
				self.ScoreColumn1.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn1, {} )
				ScoreColumn2:completeAnimation()
				ScoreColumn2.Text:completeAnimation()
				self.ScoreColumn2:setRGB( 1, 1, 1 )
				self.ScoreColumn2:setAlpha( 1 )
				self.ScoreColumn2.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn2, {} )
				ScoreColumn3:completeAnimation()
				ScoreColumn3.Text:completeAnimation()
				self.ScoreColumn3:setRGB( 1, 1, 1 )
				self.ScoreColumn3:setAlpha( 1 )
				self.ScoreColumn3.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn3, {} )
				ScoreColumn4:completeAnimation()
				ScoreColumn4.Text:completeAnimation()
				self.ScoreColumn4:setRGB( 1, 1, 1 )
				self.ScoreColumn4:setAlpha( 1 )
				self.ScoreColumn4.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn4, {} )
				ScoreColumn5:completeAnimation()
				ScoreColumn5.Text:completeAnimation()
				self.ScoreColumn5:setRGB( 1, 1, 1 )
				self.ScoreColumn5:setAlpha( 1 )
				self.ScoreColumn5.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn5, {} )
				FocusBarB:completeAnimation()
				self.FocusBarB:setAlpha( 0 )
				self.clipFinished( FocusBarB, {} )
				FocusBarT:completeAnimation()
				self.FocusBarT:setAlpha( 0 )
				self.clipFinished( FocusBarT, {} )
			end,
			Focus = function ()
				self:setupElementClipCounter( 11 )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setRGB( 1, 1, 1 )
				self.Top3PlayerScoreBlurBox0:setAlpha( 0 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				Rank:completeAnimation()
				self.clipFinished( Rank, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setRGB( 1, 1, 1 )
				self.clipFinished( RankIcon, {} )
				Gamertag:completeAnimation()
				self.Gamertag:setRGB( 1, 1, 1 )
				self.clipFinished( Gamertag, {} )
				ScoreColumn1:completeAnimation()
				ScoreColumn1.Text:completeAnimation()
				self.ScoreColumn1:setRGB( 1, 1, 1 )
				self.ScoreColumn1.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn1, {} )
				ScoreColumn2:completeAnimation()
				ScoreColumn2.Text:completeAnimation()
				self.ScoreColumn2:setRGB( 1, 1, 1 )
				self.ScoreColumn2.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn2, {} )
				ScoreColumn3:completeAnimation()
				ScoreColumn3.Text:completeAnimation()
				self.ScoreColumn3:setRGB( 1, 1, 1 )
				self.ScoreColumn3.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn3, {} )
				ScoreColumn4:completeAnimation()
				ScoreColumn4.Text:completeAnimation()
				self.ScoreColumn4:setRGB( 1, 1, 1 )
				self.ScoreColumn4.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn4, {} )
				ScoreColumn5:completeAnimation()
				ScoreColumn5.Text:completeAnimation()
				self.ScoreColumn5:setRGB( 1, 1, 1 )
				self.ScoreColumn5.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn5, {} )
				FocusBarB:completeAnimation()
				self.FocusBarB:setAlpha( 1 )
				self.clipFinished( FocusBarB, {} )
				FocusBarT:completeAnimation()
				self.FocusBarT:setAlpha( 1 )
				self.clipFinished( FocusBarT, {} )
			end
		},
		IsCoDCaster = {
			DefaultClip = function ()
				self:setupElementClipCounter( 11 )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setRGB( 1, 1, 1 )
				self.Top3PlayerScoreBlurBox0:setAlpha( 1 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				Rank:completeAnimation()
				self.Rank:setLeftRight( true, false, 23, 52 )
				self.Rank:setTopBottom( false, false, -11, 10 )
				self.clipFinished( Rank, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setRGB( 1, 1, 1 )
				self.clipFinished( RankIcon, {} )
				Gamertag:completeAnimation()
				self.Gamertag:setLeftRight( true, false, 82, 335 )
				self.Gamertag:setTopBottom( false, false, -12, 10 )
				self.Gamertag:setRGB( 1, 1, 1 )
				self.clipFinished( Gamertag, {} )
				ScoreColumn1:completeAnimation()
				ScoreColumn1.Text:completeAnimation()
				self.ScoreColumn1:setRGB( 1, 1, 1 )
				self.ScoreColumn1:setAlpha( 1 )
				self.ScoreColumn1.Text:setAlpha( 0 )
				self.clipFinished( ScoreColumn1, {} )
				ScoreColumn2:completeAnimation()
				ScoreColumn2.Text:completeAnimation()
				self.ScoreColumn2:setRGB( 1, 1, 1 )
				self.ScoreColumn2:setAlpha( 1 )
				self.ScoreColumn2.Text:setAlpha( 0 )
				self.clipFinished( ScoreColumn2, {} )
				ScoreColumn3:completeAnimation()
				ScoreColumn3.Text:completeAnimation()
				self.ScoreColumn3:setRGB( 1, 1, 1 )
				self.ScoreColumn3:setAlpha( 1 )
				self.ScoreColumn3.Text:setAlpha( 0 )
				self.clipFinished( ScoreColumn3, {} )
				ScoreColumn4:completeAnimation()
				ScoreColumn4.Text:completeAnimation()
				self.ScoreColumn4:setRGB( 1, 1, 1 )
				self.ScoreColumn4:setAlpha( 1 )
				self.ScoreColumn4.Text:setAlpha( 0 )
				self.clipFinished( ScoreColumn4, {} )
				ScoreColumn5:completeAnimation()
				ScoreColumn5.Text:completeAnimation()
				self.ScoreColumn5:setRGB( 1, 1, 1 )
				self.ScoreColumn5:setAlpha( 1 )
				self.ScoreColumn5.Text:setAlpha( 0 )
				self.clipFinished( ScoreColumn5, {} )
				FocusBarB:completeAnimation()
				self.FocusBarB:setAlpha( 0 )
				self.clipFinished( FocusBarB, {} )
				FocusBarT:completeAnimation()
				self.FocusBarT:setAlpha( 0 )
				self.clipFinished( FocusBarT, {} )
			end
		},
		FrontendArabic = {
			DefaultClip = function ()
				self:setupElementClipCounter( 10 )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setRGB( 1, 1, 1 )
				self.Top3PlayerScoreBlurBox0:setAlpha( 1 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setRGB( 1, 1, 1 )
				self.clipFinished( RankIcon, {} )
				Gamertag:completeAnimation()
				self.Gamertag:setRGB( 1, 1, 1 )
				self.Gamertag:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_RIGHT )
				self.clipFinished( Gamertag, {} )
				ScoreColumn1:completeAnimation()
				ScoreColumn1.Text:completeAnimation()
				self.ScoreColumn1:setRGB( 1, 1, 1 )
				self.ScoreColumn1:setAlpha( 1 )
				self.ScoreColumn1.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn1, {} )
				ScoreColumn2:completeAnimation()
				ScoreColumn2.Text:completeAnimation()
				self.ScoreColumn2:setRGB( 1, 1, 1 )
				self.ScoreColumn2:setAlpha( 1 )
				self.ScoreColumn2.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn2, {} )
				ScoreColumn3:completeAnimation()
				ScoreColumn3.Text:completeAnimation()
				self.ScoreColumn3:setRGB( 1, 1, 1 )
				self.ScoreColumn3:setAlpha( 1 )
				self.ScoreColumn3.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn3, {} )
				ScoreColumn4:completeAnimation()
				ScoreColumn4.Text:completeAnimation()
				self.ScoreColumn4:setRGB( 1, 1, 1 )
				self.ScoreColumn4:setAlpha( 1 )
				self.ScoreColumn4.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn4, {} )
				ScoreColumn5:completeAnimation()
				ScoreColumn5.Text:completeAnimation()
				self.ScoreColumn5:setRGB( 1, 1, 1 )
				self.ScoreColumn5:setAlpha( 1 )
				self.ScoreColumn5.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn5, {} )
				FocusBarB:completeAnimation()
				self.FocusBarB:setAlpha( 0 )
				self.clipFinished( FocusBarB, {} )
				FocusBarT:completeAnimation()
				self.FocusBarT:setAlpha( 0 )
				self.clipFinished( FocusBarT, {} )
			end
		},
		Frontend = {
			DefaultClip = function ()
				self:setupElementClipCounter( 10 )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setRGB( 1, 1, 1 )
				self.Top3PlayerScoreBlurBox0:setAlpha( 1 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setRGB( 1, 1, 1 )
				self.clipFinished( RankIcon, {} )
				Gamertag:completeAnimation()
				self.Gamertag:setRGB( 1, 1, 1 )
				self.clipFinished( Gamertag, {} )
				ScoreColumn1:completeAnimation()
				ScoreColumn1.Text:completeAnimation()
				self.ScoreColumn1:setRGB( 1, 1, 1 )
				self.ScoreColumn1:setAlpha( 1 )
				self.ScoreColumn1.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn1, {} )
				ScoreColumn2:completeAnimation()
				ScoreColumn2.Text:completeAnimation()
				self.ScoreColumn2:setRGB( 1, 1, 1 )
				self.ScoreColumn2:setAlpha( 1 )
				self.ScoreColumn2.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn2, {} )
				ScoreColumn3:completeAnimation()
				ScoreColumn3.Text:completeAnimation()
				self.ScoreColumn3:setRGB( 1, 1, 1 )
				self.ScoreColumn3:setAlpha( 1 )
				self.ScoreColumn3.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn3, {} )
				ScoreColumn4:completeAnimation()
				ScoreColumn4.Text:completeAnimation()
				self.ScoreColumn4:setRGB( 1, 1, 1 )
				self.ScoreColumn4:setAlpha( 1 )
				self.ScoreColumn4.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn4, {} )
				ScoreColumn5:completeAnimation()
				ScoreColumn5.Text:completeAnimation()
				self.ScoreColumn5:setRGB( 1, 1, 1 )
				self.ScoreColumn5:setAlpha( 1 )
				self.ScoreColumn5.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn5, {} )
				FocusBarB:completeAnimation()
				self.FocusBarB:setAlpha( 0 )
				self.clipFinished( FocusBarB, {} )
				FocusBarT:completeAnimation()
				self.FocusBarT:setAlpha( 0 )
				self.clipFinished( FocusBarT, {} )
			end
		},
		IsSelfArabic = {
			DefaultClip = function ()
				self:setupElementClipCounter( 10 )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setRGB( 1, 1, 1 )
				self.Top3PlayerScoreBlurBox0:setAlpha( 1 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setRGB( 1, 1, 1 )
				self.clipFinished( RankIcon, {} )
				Gamertag:completeAnimation()
				self.Gamertag:setRGB( 1, 0.84, 0.04 )
				self.Gamertag:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_RIGHT )
				self.clipFinished( Gamertag, {} )
				ScoreColumn1:completeAnimation()
				ScoreColumn1.Text:completeAnimation()
				self.ScoreColumn1:setRGB( 1, 1, 1 )
				self.ScoreColumn1:setAlpha( 1 )
				self.ScoreColumn1.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn1, {} )
				ScoreColumn2:completeAnimation()
				ScoreColumn2.Text:completeAnimation()
				self.ScoreColumn2:setRGB( 1, 1, 1 )
				self.ScoreColumn2:setAlpha( 1 )
				self.ScoreColumn2.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn2, {} )
				ScoreColumn3:completeAnimation()
				ScoreColumn3.Text:completeAnimation()
				self.ScoreColumn3:setRGB( 1, 1, 1 )
				self.ScoreColumn3:setAlpha( 1 )
				self.ScoreColumn3.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn3, {} )
				ScoreColumn4:completeAnimation()
				ScoreColumn4.Text:completeAnimation()
				self.ScoreColumn4:setRGB( 1, 1, 1 )
				self.ScoreColumn4:setAlpha( 1 )
				self.ScoreColumn4.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn4, {} )
				ScoreColumn5:completeAnimation()
				ScoreColumn5.Text:completeAnimation()
				self.ScoreColumn5:setRGB( 1, 1, 1 )
				self.ScoreColumn5:setAlpha( 1 )
				self.ScoreColumn5.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn5, {} )
				FocusBarB:completeAnimation()
				self.FocusBarB:setAlpha( 0 )
				self.clipFinished( FocusBarB, {} )
				FocusBarT:completeAnimation()
				self.FocusBarT:setAlpha( 0 )
				self.clipFinished( FocusBarT, {} )
			end,
			Focus = function ()
				self:setupElementClipCounter( 11 )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setRGB( 1, 1, 1 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				Rank:completeAnimation()
				self.clipFinished( Rank, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setRGB( 1, 1, 1 )
				self.clipFinished( RankIcon, {} )
				Gamertag:completeAnimation()
				self.Gamertag:setRGB( 1, 0.84, 0.04 )
				self.clipFinished( Gamertag, {} )
				ScoreColumn1:completeAnimation()
				ScoreColumn1.Text:completeAnimation()
				self.ScoreColumn1:setRGB( 1, 1, 1 )
				self.ScoreColumn1.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn1, {} )
				ScoreColumn2:completeAnimation()
				ScoreColumn2.Text:completeAnimation()
				self.ScoreColumn2:setRGB( 1, 1, 1 )
				self.ScoreColumn2.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn2, {} )
				ScoreColumn3:completeAnimation()
				ScoreColumn3.Text:completeAnimation()
				self.ScoreColumn3:setRGB( 1, 1, 1 )
				self.ScoreColumn3.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn3, {} )
				ScoreColumn4:completeAnimation()
				ScoreColumn4.Text:completeAnimation()
				self.ScoreColumn4:setRGB( 1, 1, 1 )
				self.ScoreColumn4.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn4, {} )
				ScoreColumn5:completeAnimation()
				ScoreColumn5.Text:completeAnimation()
				self.ScoreColumn5:setRGB( 1, 1, 1 )
				self.ScoreColumn5.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn5, {} )
				FocusBarB:completeAnimation()
				self.FocusBarB:setAlpha( 1 )
				self.clipFinished( FocusBarB, {} )
				FocusBarT:completeAnimation()
				self.FocusBarT:setAlpha( 1 )
				self.clipFinished( FocusBarT, {} )
			end
		},
		IsSelf = {
			DefaultClip = function ()
				self:setupElementClipCounter( 10 )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setRGB( 1, 1, 1 )
				self.Top3PlayerScoreBlurBox0:setAlpha( 1 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setRGB( 1, 1, 1 )
				self.clipFinished( RankIcon, {} )
				Gamertag:completeAnimation()
				self.Gamertag:setRGB( 1, 0.84, 0.04 )
				self.clipFinished( Gamertag, {} )
				ScoreColumn1:completeAnimation()
				ScoreColumn1.Text:completeAnimation()
				self.ScoreColumn1:setRGB( 1, 1, 1 )
				self.ScoreColumn1:setAlpha( 1 )
				self.ScoreColumn1.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn1, {} )
				ScoreColumn2:completeAnimation()
				ScoreColumn2.Text:completeAnimation()
				self.ScoreColumn2:setRGB( 1, 1, 1 )
				self.ScoreColumn2:setAlpha( 1 )
				self.ScoreColumn2.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn2, {} )
				ScoreColumn3:completeAnimation()
				ScoreColumn3.Text:completeAnimation()
				self.ScoreColumn3:setRGB( 1, 1, 1 )
				self.ScoreColumn3:setAlpha( 1 )
				self.ScoreColumn3.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn3, {} )
				ScoreColumn4:completeAnimation()
				ScoreColumn4.Text:completeAnimation()
				self.ScoreColumn4:setRGB( 1, 1, 1 )
				self.ScoreColumn4:setAlpha( 1 )
				self.ScoreColumn4.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn4, {} )
				ScoreColumn5:completeAnimation()
				ScoreColumn5.Text:completeAnimation()
				self.ScoreColumn5:setRGB( 1, 1, 1 )
				self.ScoreColumn5:setAlpha( 1 )
				self.ScoreColumn5.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn5, {} )
				FocusBarB:completeAnimation()
				self.FocusBarB:setAlpha( 0 )
				self.clipFinished( FocusBarB, {} )
				FocusBarT:completeAnimation()
				self.FocusBarT:setAlpha( 0 )
				self.clipFinished( FocusBarT, {} )
			end,
			Focus = function ()
				self:setupElementClipCounter( 11 )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setRGB( 1, 1, 1 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				Rank:completeAnimation()
				self.clipFinished( Rank, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setRGB( 1, 1, 1 )
				self.clipFinished( RankIcon, {} )
				Gamertag:completeAnimation()
				self.Gamertag:setRGB( 1, 0.84, 0.04 )
				self.clipFinished( Gamertag, {} )
				ScoreColumn1:completeAnimation()
				ScoreColumn1.Text:completeAnimation()
				self.ScoreColumn1:setRGB( 1, 1, 1 )
				self.ScoreColumn1.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn1, {} )
				ScoreColumn2:completeAnimation()
				ScoreColumn2.Text:completeAnimation()
				self.ScoreColumn2:setRGB( 1, 1, 1 )
				self.ScoreColumn2.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn2, {} )
				ScoreColumn3:completeAnimation()
				ScoreColumn3.Text:completeAnimation()
				self.ScoreColumn3:setRGB( 1, 1, 1 )
				self.ScoreColumn3.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn3, {} )
				ScoreColumn4:completeAnimation()
				ScoreColumn4.Text:completeAnimation()
				self.ScoreColumn4:setRGB( 1, 1, 1 )
				self.ScoreColumn4.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn4, {} )
				ScoreColumn5:completeAnimation()
				ScoreColumn5.Text:completeAnimation()
				self.ScoreColumn5:setRGB( 1, 1, 1 )
				self.ScoreColumn5.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn5, {} )
				FocusBarB:completeAnimation()
				self.FocusBarB:setAlpha( 1 )
				self.clipFinished( FocusBarB, {} )
				FocusBarT:completeAnimation()
				self.FocusBarT:setAlpha( 1 )
				self.clipFinished( FocusBarT, {} )
			end
		},
		DefaultStateArabic = {
			DefaultClip = function ()
				self:setupElementClipCounter( 11 )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setRGB( 1, 1, 1 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				Rank:completeAnimation()
				self.Rank:setLeftRight( true, false, 23, 52 )
				self.Rank:setTopBottom( false, false, -11, 10 )
				self.clipFinished( Rank, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setRGB( 1, 1, 1 )
				self.clipFinished( RankIcon, {} )
				Gamertag:completeAnimation()
				self.Gamertag:setLeftRight( true, false, 82, 335 )
				self.Gamertag:setTopBottom( false, false, -12, 10 )
				self.Gamertag:setRGB( 1, 1, 1 )
				self.Gamertag:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_RIGHT )
				self.clipFinished( Gamertag, {} )
				ScoreColumn1:completeAnimation()
				ScoreColumn1.Text:completeAnimation()
				self.ScoreColumn1:setRGB( 1, 1, 1 )
				self.ScoreColumn1:setAlpha( 1 )
				self.ScoreColumn1.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn1, {} )
				ScoreColumn2:completeAnimation()
				ScoreColumn2.Text:completeAnimation()
				self.ScoreColumn2:setRGB( 1, 1, 1 )
				self.ScoreColumn2:setAlpha( 1 )
				self.ScoreColumn2.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn2, {} )
				ScoreColumn3:completeAnimation()
				ScoreColumn3.Text:completeAnimation()
				self.ScoreColumn3:setRGB( 1, 1, 1 )
				self.ScoreColumn3:setAlpha( 1 )
				self.ScoreColumn3.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn3, {} )
				ScoreColumn4:completeAnimation()
				ScoreColumn4.Text:completeAnimation()
				self.ScoreColumn4:setRGB( 1, 1, 1 )
				self.ScoreColumn4:setAlpha( 1 )
				self.ScoreColumn4.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn4, {} )
				ScoreColumn5:completeAnimation()
				ScoreColumn5.Text:completeAnimation()
				self.ScoreColumn5:setRGB( 1, 1, 1 )
				self.ScoreColumn5:setAlpha( 1 )
				self.ScoreColumn5.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn5, {} )
				FocusBarB:completeAnimation()
				self.FocusBarB:setAlpha( 0 )
				self.clipFinished( FocusBarB, {} )
				FocusBarT:completeAnimation()
				self.FocusBarT:setAlpha( 0 )
				self.clipFinished( FocusBarT, {} )
			end,
			Focus = function ()
				self:setupElementClipCounter( 11 )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setRGB( 1, 1, 1 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				Rank:completeAnimation()
				self.clipFinished( Rank, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setRGB( 1, 1, 1 )
				self.clipFinished( RankIcon, {} )
				Gamertag:completeAnimation()
				self.Gamertag:setRGB( 1, 1, 1 )
				self.clipFinished( Gamertag, {} )
				ScoreColumn1:completeAnimation()
				ScoreColumn1.Text:completeAnimation()
				self.ScoreColumn1:setRGB( 1, 1, 1 )
				self.ScoreColumn1.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn1, {} )
				ScoreColumn2:completeAnimation()
				ScoreColumn2.Text:completeAnimation()
				self.ScoreColumn2:setRGB( 1, 1, 1 )
				self.ScoreColumn2.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn2, {} )
				ScoreColumn3:completeAnimation()
				ScoreColumn3.Text:completeAnimation()
				self.ScoreColumn3:setRGB( 1, 1, 1 )
				self.ScoreColumn3.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn3, {} )
				ScoreColumn4:completeAnimation()
				ScoreColumn4.Text:completeAnimation()
				self.ScoreColumn4:setRGB( 1, 1, 1 )
				self.ScoreColumn4.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn4, {} )
				ScoreColumn5:completeAnimation()
				ScoreColumn5.Text:completeAnimation()
				self.ScoreColumn5:setRGB( 1, 1, 1 )
				self.ScoreColumn5.Text:setAlpha( 1 )
				self.clipFinished( ScoreColumn5, {} )
				FocusBarB:completeAnimation()
				self.FocusBarB:setAlpha( 1 )
				self.clipFinished( FocusBarB, {} )
				FocusBarT:completeAnimation()
				self.FocusBarT:setAlpha( 1 )
				self.clipFinished( FocusBarT, {} )
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "GenesisEndGame",
			condition = function ( menu, element, event )
				local f34_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_GAME_ENDED )
				if f34_local0 then
					f34_local0 = IsMapName( "zm_genesis" )
					if f34_local0 then
						f34_local0 = IsGenesisEECompleted( controller )
					end
				end
				return f34_local0
			end
		},
		{
			stateName = "IsCoDCaster",
			condition = function ( menu, element, event )
				return IsScoreboardPlayerCodCaster( controller, element )
			end
		},
		{
			stateName = "FrontendArabic",
			condition = function ( menu, element, event )
				local f36_local0
				if not IsInGame() then
					f36_local0 = IsCurrentLanguageArabic()
				else
					f36_local0 = false
				end
				return f36_local0
			end
		},
		{
			stateName = "Frontend",
			condition = function ( menu, element, event )
				local f37_local0
				if not IsInGame() then
					f37_local0 = not IsCurrentLanguageArabic()
				else
					f37_local0 = false
				end
				return f37_local0
			end
		},
		{
			stateName = "IsSelfArabic",
			condition = function ( menu, element, event )
				local f38_local0 = IsScoreboardPlayerSelf( element, controller )
				if f38_local0 then
					f38_local0 = IsCurrentLanguageArabic()
				end
				return f38_local0
			end
		},
		{
			stateName = "IsSelf",
			condition = function ( menu, element, event )
				local f39_local0 = IsScoreboardPlayerSelf( element, controller )
				if f39_local0 then
					f39_local0 = not IsCurrentLanguageArabic()
				end
				return f39_local0
			end
		},
		{
			stateName = "DefaultStateArabic",
			condition = function ( menu, element, event )
				return IsCurrentLanguageArabic()
			end
		}
	} )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED
		} )
	end )
	self:linkToElementModel( self, "clientNum", true, function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "clientNum"
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "deadSpectator.playerIndex" ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "deadSpectator.playerIndex"
		} )
	end )
	scoreboardPingBackground.id = "scoreboardPingBackground"
	self:registerEventHandler( "gain_focus", function ( element, event )
		if element.m_focusable and element.scoreboardPingBackground:processEvent( event ) then
			return true
		else
			return LUI.UIElement.gainFocus( element, event )
		end
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.Top3PlayerScoreBlurBox0:close()
		element.VSpanel:close()
		element.ScoreColumn1:close()
		element.ScoreColumn2:close()
		element.ScoreColumn3:close()
		element.ScoreColumn4:close()
		element.ScoreColumn5:close()
		element.scoreboardPingBackground:close()
		element.FocusBarB:close()
		element.FocusBarT:close()
		element.Rank:close()
		element.RankIcon:close()
		element.Gamertag:close()
		element.PingText:close()
		element.VOIPImage:close()
		element.ScoreboardRowDeathIcon:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end

