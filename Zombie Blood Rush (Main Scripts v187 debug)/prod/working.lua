local __f0_local1 = {
	theater = {}
}

local __f0_local2 = {

}

LUI.createMenu.Loading = function ( parentMenu )
	local menuRef = CoD.Menu.NewFromState( "Loading", {
		leftAnchor = true,
		rightAnchor = true,
		left = 0,
		right = 0,
		topAnchor = true,
		bottomAnchor = true,
		top = 0,
		bottom = 0
	} )
	menuRef.id = "loadingMenu"
	menuRef:setOwner( parentMenu )
	menuRef:registerEventHandler( "start_loading", CoD.Loading.StartLoading )
	menuRef:registerEventHandler( "start_spinner", CoD.Loading.StartSpinner )
	menuRef:registerEventHandler( "fade_in_map_location", CoD.Loading.FadeInMapLocation )
	menuRef:registerEventHandler( "fade_in_gametype", CoD.Loading.FadeInGametype )
	menuRef:registerEventHandler( "fade_in_map_image", CoD.Loading.FadeInMapImage )
	local isCinematicLoad = false
	local currentMap = Engine.GetCurrentMap()
	local currentGametype = Engine.GetCurrentGameType()
	local mapLoadingImage = CoD.GetMapValue( currentMap, "loadingImage", "black" )

	if currentMap ~= nil and currentMap == "zm_island" and IsJapaneseSku() and CoD.LANGUAGE_JAPANESE == Dvar.loc_language:get() then
		isCinematicLoad = false
	elseif currentMap ~= nil and (currentMap == "zm_asylum" or currentMap == "zm_cosmodrome" or currentMap == "zm_moon" or currentMap == "zm_sumpf" or currentMap == "zm_temple") then
		isCinematicLoad = false
	elseif Engine.IsDemoPlaying() or Engine.IsSplitscreen() then
		isCinematicLoad = false
	else
		isCinematicLoad = false
	end
	if not isCinematicLoad then
		Engine.PlayMenuMusic( "load_" .. currentMap ) -- TODO loading music maybe?
	end
	
	if isCinematicLoad then
		if CoD.GetMapValue( currentMap, "fadeToWhite" ) == 1 then
			local loadImageWhite = "$white"
		end
		mapLoadingImage = loadImageWhite or "black"
	else
		Engine.SetDvar( "ui_useloadingmovie", 0 )
		if mapLoadingImage == nil or mapLoadingImage == "" or CoD.isMultiplayer then
			mapLoadingImage = "black"
		end
	end
	if Engine.IsLevelPreloaded( currentMap ) then
		menuRef.addLoadingElement = function ( a, b )
		end
		
	else
		menuRef.addLoadingElement = function ( a, b )
			a:addElement( b )
		end
	end
	menuRef.mapImage = LUI.UIStreamedImage.new()
	menuRef.mapImage.id = "mapImage"
	menuRef.mapImage:setLeftRight( false, false, -640, 640 )
	menuRef.mapImage:setTopBottom( false, false, -360, 360 )
	menuRef.mapImage:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_normal" ) )
	menuRef.mapImage:setImage( RegisterImage( mapLoadingImage ) )
	menuRef:addElement( menuRef.mapImage )
	if isCinematicLoad == true then
		menuRef.mapImage:setShaderVector( 0, 0, 0, 0, 0 )
		menuRef.mapImage.ismp4 = false
	end
	local offset10 = 10
	local offset70 = 70
	local big = "Big"
	local bigFont = CoD.fonts[big]
	local bigTextSize = CoD.textSize[big]
	local condensed = "Condensed"
	local condensedFont = CoD.fonts[condensed]
	local condensedTextSize = CoD.textSize[condensed]
	menuRef.mapNameLabel = LUI.UIText.new()
	menuRef.mapNameLabel.id = "mapNameLabel"
	menuRef.mapNameLabel:setLeftRight( true, false, offset70, offset70 + 1 )
	menuRef.mapNameLabel:setTopBottom( true, false, offset10, offset10 + bigTextSize )
	menuRef.mapNameLabel:setFont( bigFont )
	menuRef.mapNameLabel:setRGB( CoD.BOIIOrange.r, CoD.BOIIOrange.g, CoD.BOIIOrange.b )
	menuRef.mapNameLabel:setAlpha( 0 )
	menuRef.mapNameLabel:registerEventHandler( "transition_complete_map_name_fade_in", CoD.Loading.MapNameFadeInComplete )
	menuRef:addLoadingElement( menuRef.mapNameLabel )
	offset10 = offset10 + bigTextSize - 5
	menuRef.mapLocationLabel = LUI.UIText.new()
	menuRef.mapLocationLabel.id = "mapLocationLabel"
	menuRef.mapLocationLabel:setLeftRight( true, false, offset70, offset70 + 1 )
	menuRef.mapLocationLabel:setTopBottom( true, false, offset10, offset10 + condensedTextSize )
	menuRef.mapLocationLabel:setFont( condensedFont )
	menuRef.mapLocationLabel:setRGB( CoD.offWhite.r, CoD.offWhite.g, CoD.offWhite.b )
	menuRef.mapLocationLabel:setAlpha( 0 )
	menuRef.mapLocationLabel:registerEventHandler( "transition_complete_map_location_fade_in", CoD.Loading.MapLocationFadeInComplete )
	menuRef:addLoadingElement( menuRef.mapLocationLabel )
	offset10 = offset10 + condensedTextSize - 2
	menuRef.gametypeLabel = LUI.UIText.new()
	menuRef.gametypeLabel.id = "gametypeLabel"
	menuRef.gametypeLabel:setLeftRight( true, false, offset70, offset70 + 1 )
	menuRef.gametypeLabel:setTopBottom( true, false, offset10, offset10 + condensedTextSize )
	menuRef.gametypeLabel:setFont( condensedFont )
	menuRef.gametypeLabel:setRGB( CoD.offWhite.r, CoD.offWhite.g, CoD.offWhite.b )
	menuRef.gametypeLabel:setAlpha( 0 )
	menuRef.gametypeLabel:registerEventHandler( "transition_complete_gametype_fade_in", CoD.Loading.GametypeFadeInComplete )
	menuRef:addLoadingElement( menuRef.gametypeLabel )
	offset10 = offset10 + condensedTextSize + 5
	local titleCaps = Engine.Localize( "MPUI_TITLE_CAPS" ) .. ":"
	local textDims1 = {}
	textDims1 = GetTextDimensions( titleCaps, condensedFont, condensedTextSize )
	local durationCaps = Engine.Localize( "MPUI_DURATION_CAPS" ) .. ":"
	local textDims2 = {}
	textDims2 = GetTextDimensions( durationCaps, condensedFont, condensedTextSize )
	local authorCaps = Engine.Localize( "MPUI_AUTHOR_CAPS" ) .. ":"
	local textDims3 = {}
	textDims3 = GetTextDimensions( authorCaps, condensedFont, condensedTextSize )
	local maxDims = math.max( textDims1[3], textDims2[3], textDims3[3] ) + 10
	local yPos = 0
	if not Engine.IsLevelPreloaded( currentMap ) then
		menuRef.demoInfoContainer = LUI.UIElement.new()
		menuRef.demoInfoContainer:setLeftRight( true, false, offset70, 600 )
		menuRef.demoInfoContainer:setTopBottom( true, false, offset10, offset10 + 600 )
		menuRef.demoInfoContainer:setAlpha( 0 )
		menuRef:addLoadingElement( menuRef.demoInfoContainer )
		menuRef.demoTitleTitle = LUI.UIText.new()
		menuRef.demoTitleTitle:setLeftRight( true, true, 0, 0 )
		menuRef.demoTitleTitle:setTopBottom( true, false, yPos, yPos + condensedTextSize )
		menuRef.demoTitleTitle:setFont( condensedFont )
		menuRef.demoTitleTitle:setRGB( CoD.BOIIOrange.r, CoD.BOIIOrange.g, CoD.BOIIOrange.b )
		menuRef.demoTitleTitle:setAlignment( LUI.Alignment.Left )
		menuRef.demoTitleTitle:setText( titleCaps )
		SetupAutoHorizontalAlignArabicText( menuRef.demoTitleTitle )
		menuRef.demoInfoContainer:addElement( menuRef.demoTitleTitle )
		menuRef.demoTitleLabel = LUI.UIText.new()
		menuRef.demoTitleLabel:setLeftRight( true, true, maxDims, 0 )
		menuRef.demoTitleLabel:setTopBottom( true, false, yPos, yPos + condensedTextSize )
		menuRef.demoTitleLabel:setFont( condensedFont )
		menuRef.demoTitleLabel:setRGB( CoD.offWhite.r, CoD.offWhite.g, CoD.offWhite.b )
		menuRef.demoTitleLabel:setAlignment( LUI.Alignment.Left )
		SetupAutoHorizontalAlignArabicText( menuRef.demoTitleLabel )
		menuRef.demoInfoContainer:addElement( menuRef.demoTitleLabel )
		yPos = yPos + condensedTextSize - 2
		menuRef.demoDurationTitle = LUI.UIText.new()
		menuRef.demoDurationTitle:setLeftRight( true, true, 0, 0 )
		menuRef.demoDurationTitle:setTopBottom( true, false, yPos, yPos + condensedTextSize )
		menuRef.demoDurationTitle:setFont( condensedFont )
		menuRef.demoDurationTitle:setRGB( CoD.BOIIOrange.r, CoD.BOIIOrange.g, CoD.BOIIOrange.b )
		menuRef.demoDurationTitle:setAlignment( LUI.Alignment.Left )
		menuRef.demoDurationTitle:setText( durationCaps )
		SetupAutoHorizontalAlignArabicText( menuRef.demoDurationTitle )
		menuRef.demoInfoContainer:addElement( menuRef.demoDurationTitle )
		menuRef.demoDurationLabel = LUI.UIText.new()
		menuRef.demoDurationLabel:setLeftRight( true, true, maxDims, 0 )
		menuRef.demoDurationLabel:setTopBottom( true, false, yPos, yPos + condensedTextSize )
		menuRef.demoDurationLabel:setFont( condensedFont )
		menuRef.demoDurationLabel:setRGB( CoD.offWhite.r, CoD.offWhite.g, CoD.offWhite.b )
		menuRef.demoDurationLabel:setAlignment( LUI.Alignment.Left )
		SetupAutoHorizontalAlignArabicText( menuRef.demoDurationLabel )
		menuRef.demoInfoContainer:addElement( menuRef.demoDurationLabel )
		yPos = yPos + condensedTextSize - 2
		menuRef.demoAuthorTitle = LUI.UIText.new()
		menuRef.demoAuthorTitle:setLeftRight( true, true, 0, 0 )
		menuRef.demoAuthorTitle:setTopBottom( true, false, yPos, yPos + condensedTextSize )
		menuRef.demoAuthorTitle:setFont( condensedFont )
		menuRef.demoAuthorTitle:setRGB( CoD.BOIIOrange.r, CoD.BOIIOrange.g, CoD.BOIIOrange.b )
		menuRef.demoAuthorTitle:setAlignment( LUI.Alignment.Left )
		menuRef.demoAuthorTitle:setText( authorCaps )
		SetupAutoHorizontalAlignArabicText( menuRef.demoAuthorTitle )
		menuRef.demoInfoContainer:addElement( menuRef.demoAuthorTitle )
		menuRef.demoAuthorLabel = LUI.UIText.new()
		menuRef.demoAuthorLabel:setLeftRight( true, true, maxDims, 0 )
		menuRef.demoAuthorLabel:setTopBottom( true, false, yPos, yPos + condensedTextSize )
		menuRef.demoAuthorLabel:setFont( condensedFont )
		menuRef.demoAuthorLabel:setRGB( CoD.offWhite.r, CoD.offWhite.g, CoD.offWhite.b )
		menuRef.demoAuthorLabel:setAlignment( LUI.Alignment.Left )
		SetupAutoHorizontalAlignArabicText( menuRef.demoAuthorLabel )
		menuRef.demoInfoContainer:addElement( menuRef.demoAuthorLabel )
	end
	local currentMap2 = 3
	local currentMap3 = CoD.Loading.DYKFontHeight + currentMap2 * 2
	local currentMap4 = 2
	local currentMap5 = currentMap3 + 1 + currentMap4 + CoD.Loading.DYKFontHeight - offset10
	local currentMap6 = CoD.Menu.Width - 5 * 2
	local currentMap7 = -200
	local currentMap8 = 0
	local currentMap9 = 2
	local currentGametype0 = currentMap3 - currentMap9 * 2
	local currentGametype1 = 6
	menuRef.loadingBarContainer = LUI.UIElement.new()
	menuRef.loadingBarContainer.id = "loadingBarContainer"
	menuRef.loadingBarContainer:setLeftRight( false, false, -currentMap6 / 2, currentMap6 / 2 )
	menuRef.loadingBarContainer:setTopBottom( false, true, currentMap7 - currentMap5, currentMap7 )
	menuRef.loadingBarContainer:setAlpha( 0 )
	menuRef:addElement( menuRef.loadingBarContainer )
	menuRef.dykContainer = LUI.UIElement.new()
	menuRef.dykContainer.id = "dykContainer"
	menuRef.dykContainer:setLeftRight( true, true, 0, 0 )
	menuRef.dykContainer:setTopBottom( true, false, currentMap8, currentMap8 + currentMap3 )
	menuRef.dykContainer.containerHeight = currentMap3
	menuRef.dykContainer.textAreaWidth = currentMap6 - currentMap2 - currentGametype1 - currentMap9 - currentGametype0 - 1
	CoD.Loading.SetupDYKContainerImages( menuRef.dykContainer )
	menuRef.didYouKnow = LUI.UIText.new()
	menuRef.didYouKnow:setLeftRight( true, true, currentMap2 + currentGametype1, -currentMap9 - currentGametype0 - 1 )
	menuRef.didYouKnow:setTopBottom( true, false, currentMap2, currentMap2 + CoD.Loading.DYKFontHeight )
	menuRef.didYouKnow:setRGB( CoD.offWhite.r, CoD.offWhite.g, CoD.offWhite.b )
	menuRef.didYouKnow:setFont( CoD.Loading.DYKFont )
	menuRef.didYouKnow:setAlignment( LUI.Alignment.Left )
	menuRef.didYouKnow:setPriority( 0 )
	currentMap8 = currentMap8 + currentMap3 + 1
	menuRef.spinner = LUI.UIImage.new()
	menuRef.spinner.id = "spinner"
	currentMap9 = 110
	currentGametype0 = currentGametype0 * 5
	menuRef.spinner:setLeftRight( false, true, -(currentMap9 + currentGametype0 / 2), -(currentMap9 - currentGametype0 / 2) )
	menuRef.spinner:setTopBottom( false, true, -(currentMap9 + currentGametype0 / 2), -(currentMap9 - currentGametype0 / 2) )
	menuRef.spinner:setImage( RegisterMaterial( "lui_loader" ) )
	menuRef.spinner:setShaderVector( 0, 0, 0, 0, 0 )
	menuRef.spinner:setAlpha( 0 )
	menuRef.spinner:setPriority( 200 )
	menuRef:addElement( menuRef.spinner )
	local self = LUI.UIImage.new()
	self.id = "loadingBarBackground"
	self:setLeftRight( true, true, 1, -1 )
	self:setTopBottom( true, false, currentMap8, currentMap8 + currentMap4 )
	self:setRGB( 0.1, 0.1, 0.1 )
	menuRef.loadingBarContainer:addElement( self )
	local self = LUI.UIImage.new()
	self:setLeftRight( true, true, 1, -1 )
	self:setTopBottom( true, false, currentMap8, currentMap8 + currentMap4 )
	self:setRGB( CoD.BOIIOrange.r, CoD.BOIIOrange.g, CoD.BOIIOrange.b )
	menuRef.loadingBarContainer:addElement( self )
	local currentGametype4 = 1
	local self = LUI.UIImage.new()
	self:setLeftRight( true, true, 2, -2 )
	self:setTopBottom( true, false, currentMap8, currentMap8 + currentGametype4 )
	self:setRGB( 1, 1, 1 )
	self:setAlpha( 0.5 )
	menuRef.loadingBarContainer:addElement( self )
	self:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_wipe" ) )
	self:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_wipe" ) )
	self:setShaderVector( 1, 0, 0, 0, 0 )
	self:setShaderVector( 2, 1, 0, 0, 0 )
	self:setShaderVector( 3, 0, 0, 0, 0 )
	self:setShaderVector( 1, 0, 0, 0, 0 )
	self:setShaderVector( 2, 1, 0, 0, 0 )
	self:setShaderVector( 3, 0, 0, 0, 0 )
	self:subscribeToGlobalModel( parentMenu, "LoadingScreenTeamInfo", "loadedFraction", function ( modelRef )
		local loadedFraction = Engine.GetModelValue( modelRef )
		if loadedFraction then
			self:setShaderVector( 0, loadedFraction, 0, 0, 0 )
			self:setShaderVector( 0, loadedFraction, 0, 0, 0 )
		end
	end )
	LUI.OverrideFunction_CallOriginalSecond( menuRef, "close", function ( element )
		self:close()
	end )
	currentMap8 = currentMap8 + currentMap4
	menuRef.statusLabel = LUI.UIText.new()
	menuRef.statusLabel:setLeftRight( true, true, currentMap2 + currentGametype1, 0 )
	menuRef.statusLabel:setTopBottom( true, false, currentMap8, currentMap8 + CoD.Loading.DYKFontHeight )
	menuRef.statusLabel:setAlpha( 0.55 )
	menuRef.statusLabel:setFont( CoD.Loading.DYKFont )
	menuRef.statusLabel:setAlignment( LUI.Alignment.Left )
	menuRef.statusLabel:setupLoadingStatusText()
	menuRef.loadingBarContainer:addElement( menuRef.statusLabel )
	if isCinematicLoad == true then
		CoD.Loading.AddNewLoadingScreen( menuRef )
		menuRef.cinematicSubtitles = CoD.MovieSubtitles.new( menuRef, parentMenu )
		menuRef.cinematicSubtitles:setLeftRight( false, false, -640, 640 )
		menuRef.cinematicSubtitles:setTopBottom( false, false, -360, 360 )
		menuRef:addElement( menuRef.cinematicSubtitles )
		menuRef.mapImage:registerEventHandler( "loading_updateimage", f0_local0 )
		menuRef.mapImage.id = "loadingMenu.mapImage"
		menuRef:addElement( LUI.UITimer.new( 16, "loading_updateimage", false, menuRef.mapImage ) )
		Engine.SetDvar( "ui_useloadingmovie", 1 )
		local currentGametype6 = 15
		local currentGametype7 = 15
		local currentGametype8, currentGametype9 = Engine.GetUserSafeArea()
		menuRef.buttonModel = Engine.CreateModel( Engine.GetModelForController( parentMenu ), "Loading.buttonPrompts" )
		LUI.OverrideFunction_CallOriginalSecond( menuRef, "close", function ( element )
			Engine.UnsubscribeAndFreeModel( Engine.GetModel( Engine.GetModelForController( parentMenu ), "LoadingScreenOverlayForTeamGames.buttonPrompts" ) )
		end )
		menuRef.continueButton = LUI.UIButton.new()
		menuRef.continueButton:setLeftRight( false, false, -currentGametype8, currentGametype8 / 2 - currentGametype6 )
		menuRef.continueButton:setTopBottom( false, false, currentGametype9 / 2 - CoD.textSize.Condensed - currentGametype7, currentGametype9 / 2 - currentGametype7 )
		menuRef.continueButton:setAlignment( LUI.Alignment.Right )
		menuRef.continueButton:setAlpha( 0 )
		menuRef.continueButton:setActionSFX( "uin_mov_skip" )
		menuRef:addElement( menuRef.continueButton )
		menuRef.continueButton:setActionEventNameNewStyle( menuRef, parentMenu, "loading_startplay" )
		menuRef.continueButton:addElement( CoD.ButtonPrompt.new( "start", "", menuRef, "loading_startplay", true ) )
		menuRef.continueButton.label = LUI.UIText.new()
		menuRef.continueButton.label:setLeftRight( true, true, 0, 0 )
		menuRef.continueButton.label:setTopBottom( true, true, 0, 0 )
		menuRef.continueButton.label:setFont( CoD.fonts.Condensed )
		menuRef.continueButton.label:setAlignment( LUI.Alignment.Right )
		menuRef.continueButton:addElement( menuRef.continueButton.label )
		menuRef.continueButton.label:setText( Engine.Localize( "PLATFORM_SKIP" ) )
		menuRef.continueButton:setHandleMouse( false )
		if CoD.isPC then
			menuRef:setForceMouseEventDispatch( true )
			menuRef.continueButtonContainer = LUI.UIElement.new()
			menuRef.continueButtonContainer:setLeftRight( true, true, 0, 0 )
			menuRef.continueButtonContainer:setTopBottom( true, true, 0, 0 )
			menuRef.continueButtonContainer:setAlpha( 1 )
			menuRef.continueButtonContainer.id = "continueButtonContainer"
			menuRef.continueButtonContainer:setHandleMouse( true )
			menuRef:addElement( menuRef.continueButtonContainer )
			menuRef.continueButtonContainer:registerEventHandler( "button_action", function ( element, event )
				SendButtonPressToMenuEx( menuRef, event.controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
			end )
		end
		menuRef:registerEventHandler( "loading_displaycontinue", __f0_local1 )
		menuRef:registerEventHandler( "loading_startplay", __f0_local2 )
		if Engine.GetCurrentMap() == "zm_theater" then
			CoD.Loading.StartLoading( menuRef )
			CoD.Loading.StartSpinner( menuRef )
			menuRef:registerEventHandler( "fade_in_map_image", nil )
		end
	else
		CoD.Loading.StartLoading( menuRef )
		menuRef:addElement( LUI.UITimer.new( CoD.Loading.SpinnerDelayTime, "start_spinner", true, menuRef ) )
	end
	return menuRef
end

CoD.Loading.FadeInGametype = function ( f20_arg0 )
	f20_arg0.gametypeLabel:setText("Zombie Blood Rush")
	f20_arg0.gametypeLabel:beginAnimation( "gametype_fade_in", CoD.Loading.FadeInTime )
	f20_arg0.gametypeLabel:setAlpha( 0.6 )
end

CoD.Loading.StartLoading = function ( f13_arg0 )
	Engine.PrintInfo( Enum.consoleLabel.LABEL_DEFAULT, "Opening loading screen...\n" )
	if f13_arg0.loadingScreenOverlay == nil then
		CoD.Loading.AddNewLoadingScreen( f13_arg0 )
	end
	if Engine.IsMultiplayerGame() then
		return 
	end
	local f13_local0 = Engine.GetPrimaryController()
	local f13_local1 = MapNameToLocalizedMapName( Engine.GetCurrentMap() )
	local f13_local2 = MapNameToLocalizedMapLocation( Engine.GetCurrentMap() )
	local f13_local3 = Engine.GetCurrentGametypeName( f13_local0 )
	f13_arg0.mapNameLabel:setText( f13_local1 )
	f13_arg0.mapLocationLabel:setText( f13_local2 )
	f13_arg0.gametypeLabel:setText( f13_local3 )
	if Engine.IsDemoPlaying() then
		local f13_local4 = Dvar.ls_demotitle:get()
		local f13_local5 = Dvar.ls_demoduration:get()
		local f13_local6 = ""
		if f13_local5 > 0 then
			f13_local6 = Engine.SecondsAsTime( Dvar.ls_demoduration:get() )
		end
		local f13_local7 = Dvar.ls_demoauthor:get()
		f13_arg0.demoTitleLabel:setText( f13_local4 )
		f13_arg0.demoDurationLabel:setText( f13_local6 )
		f13_arg0.demoAuthorLabel:setText( f13_local7 )
		if f13_local7 == "" then
			f13_arg0.demoAuthorTitle:setAlpha( 0 )
		end
		if f13_local6 == "" then
			f13_arg0.demoDurationTitle:setAlpha( 0 )
		end
	end
	local f13_local4 = CoD.Loading.GetDidYouKnowString()
	local f13_local5 = {}
	f13_local5 = GetTextDimensions( f13_local4, CoD.Loading.DYKFont, CoD.Loading.DYKFontHeight )
	if f13_arg0.dykContainer.textAreaWidth < f13_local5[3] then
		f13_arg0.dykContainer:setTopBottom( true, false, -CoD.Loading.DYKFontHeight, f13_arg0.dykContainer.containerHeight )
	end
	f13_arg0.didYouKnow:setText( f13_local4 )
	f13_arg0.mapNameLabel:beginAnimation( "map_name_fade_in", CoD.Loading.FadeInTime )
	f13_arg0.mapNameLabel:setAlpha( 1 )
end

CoD.Loading.GetDidYouKnowString = function ()
	index = math.random( 1 )
	return Engine.Localize( "THIS IS A TEST! DID YOU KNOW?" )
end