require( "ui.T6.CoDBase" )
require( "ui.T6.CoDMenu" )

CoD.Migration = {}
LUI.createMenu.migration_ingame = function ( f1_arg0, f1_arg1 )
	local f1_local0 = CoD.Menu.New( "migration_ingame" )
	if Engine.IsInGame() and Engine.IsSplitscreen() then
		f1_local0:sizeToSafeArea( f1_arg0 )
	end
	local self = LUI.UIImage.new()
	self:setLeftRight( false, false, -1280, 1280 )
	self:setTopBottom( false, false, -720, 720 )
	self:setRGB( 0, 0, 0 )
	f1_local0:addElement( self )
	local f1_local2 = 64
	local self = LUI.UIImage.new( {
		shaderVector0 = {
			0,
			0,
			0,
			0
		}
	} )
	self:setLeftRight( false, false, -f1_local2 / 2, f1_local2 / 2 )
	self:setTopBottom( false, false, -f1_local2 / 2, f1_local2 / 2 )
	self:setImage( RegisterMaterial( "lui_loader" ) )
	f1_local0:addElement( self )
	local f1_local4 = f1_local2 / 2 + 10
	local self = LUI.UIText.new()
	self:setLeftRight( true, true, 0, 0 )
	self:setTopBottom( false, false, f1_local4, f1_local4 + CoD.textSize.Condensed )
	self:setFont( CoD.fonts.Condensed )
	self:setAlignment( LUI.Alignment.Center )
	self:setRGB( CoD.offWhite.r, CoD.offWhite.g, CoD.offWhite.b )
	self:setText( Engine.Localize( "MP_MIGRATINGHOSTS_CAPS" ) )
	f1_local0:addElement( self )
	f1_local0.buttonModel = Engine.CreateModel( Engine.GetModelForController( f1_arg0 ), "Migration.buttonPrompts" )
	if CoD.isMultiplayer then
		local VoipContainer = CoD.Voip_Container.new( f1_local0, f1_arg0 )
		VoipContainer:setLeftRight( true, false, 64, 337 )
		VoipContainer:setTopBottom( true, false, 36, 108 )
		VoipContainer:mergeStateConditions( {
			{
				stateName = "HudStart",
				condition = function ( menu, element, event )
					return AlwaysTrue()
				end
			},
			{
				stateName = "ShowForCodCaster",
				condition = function ( menu, element, event )
					return AlwaysFalse()
				end
			}
		} )
		f1_local0:addElement( VoipContainer )
		f1_local0.VoipContainer = VoipContainer
		
	else
		local VoipContainer = LUI.UIList.new( f1_local0, f1_arg0, 5, 0, nil, false, false, 0, 0, false, false )
		VoipContainer:makeFocusable()
		VoipContainer:setLeftRight( false, false, -576, -386 )
		VoipContainer:setTopBottom( true, false, 36, 123 )
		VoipContainer:setDataSource( "LoadingScreenPlayerListTeam1" )
		VoipContainer:setWidgetType( CoD.LoadingScreenTalkerWidgetCPZM )
		VoipContainer:setVerticalCount( 4 )
		VoipContainer:setSpacing( 5 )
		f1_local0:addElement( VoipContainer )
		f1_local0.Team1PlayerList = VoipContainer
	end
	LUI.OverrideFunction_CallOriginalSecond( f1_local0, "close", function ( element )
		Engine.UnsubscribeAndFreeModel( Engine.GetModel( Engine.GetModelForController( f1_arg0 ), "Migration.buttonPrompts" ) )
	end )
	return f1_local0
end

CoD.Loading.FadeInGametype = function ( f20_arg0 )
	f20_arg0.gametypeLabel:beginAnimation( "gametype_fade_in", CoD.Loading.FadeInTime )
	-- f20_arg0.gametypeLabel:setAlpha( 0.6 )
end

CoD.Loading.FadeInMapImage = function ( f22_arg0 )
	f22_arg0.mapImage:beginAnimation( "map_image_fade_in", CoD.Loading.FadeInTime )
	f22_arg0.mapImage:setRGB( 1, 1, 1 )
	f22_arg0.loadingBarContainer:beginAnimation( "loading_bar_fade_in", CoD.Loading.FadeInTime )
	f22_arg0.loadingBarContainer:setAlpha( 1 )
	f22_arg0.dykContainer:beginAnimation( "loading_bar_fade_in", CoD.Loading.FadeInTime )
	f22_arg0.dykContainer:setAlpha( 1 )
	if Engine.IsDemoPlaying() then
		f22_arg0.demoInfoContainer:beginAnimation( "demo_info_fade_in", CoD.Loading.FadeInTime )
		f22_arg0.demoInfoContainer:setAlpha( 1 )
	end
end

CoD.Loading.StartLoading = function ( f13_arg0 )
	-- Engine.PrintInfo( Enum.consoleLabel.LABEL_DEFAULT, "Opening loading screen...\n" )
	if f13_arg0.loadingScreenOverlay == nil then
		CoD.Loading.AddNewLoadingScreen( f13_arg0 )
	end
	local f13_local0 = Engine.GetPrimaryController()
	local f13_local1 = string.upper(MapNameToLocalizedMapName( Engine.GetCurrentMap() ))
	local f13_local2 = MapNameToLocalizedMapLocation( Engine.GetCurrentMap() )
	local f13_local3 = Engine.GetCurrentGametypeName( f13_local0 )
	f13_arg0.mapNameLabel:setText( f13_local1 )
	f13_arg0.mapLocationLabel:setText( f13_local2 )
	f13_arg0.gametypeLabel:setText( f13_local3 )
	local f13_local4 = CoD.Loading.GetDidYouKnowString()
	f13_arg0.didYouKnow:setText( f13_local4 )
	f13_arg0.mapNameLabel:beginAnimation( "map_name_fade_in", CoD.Loading.FadeInTime )
	f13_arg0.mapNameLabel:setAlpha( 1 )
end

dykFacts = {
	"Juggernog provides players with armor that protects against zombies and other players.",
	"Doubletap increases your rate of fire and shoots a second bullet every time you pull the trigger.",
	"Widows Wine nullifies incoming melee damage as long as you have a grenade.",
	"Weapons like the Ray Gun and the Wonderwaffe deal more damage with direct impacts.",
	"Holding the objective for longer reduces the time you have to survive next time.",
	"Monkey bombs make you invisible for a short period of time.",
	"Danger Closest negates all explosive damage.",
	"Grenades are highly effective against zombies and players.",
	"Double Points increases the rate at which you steal points from other players.",
	"Juggernog does not protect against headshots, but does protect against Head Drama.",
	"Alternate ammo types are extremely effective against players.",
	"Players keep their weapons when respawning, so getting Pack-a-Punch early is smart.",
	"Players who were recently control-impaired have damage reduction for a short period of time.",
	"Weapons that are stronger against players tend to be weaker against zombies.",
	"Insta-kill increases damage against players.",
	"Traps will instantly kill other players, unless they have Juggernog.",
	"The civil protector can be a valuable asset when trying to survive.",
	"Defensive shields take almost no bullet damage but are weak to explosives.",
	"Offensive shields do a lot of damage but have little defensive utility.",
	"Many gobblegums have new effects. Be sure to try them all out.",
	"The price of weapons, perks, and gobblegums increases as the rounds progress.",
	":zbrsupreme: Check out the LFG channel pins in our Discord for a full list of emotes.",
	"Zombie kills grant more points as the rounds progress.",
	"Explosives provide a bit of knock-back. Experiment with where they can take you.",
	"The Thunderwall AAT is good for displacing enemy players.",
	"The Dead Wire AAT is good for disorienting enemy players.",
	"Sprint to put out Blast Furnace's fire sooner.",
	"The Blast Furnace AAT is good for doing a lot of damage to enemy players.",
	"The Fireworks AAT can roll on melee weapons. Try it out!",
	"The Bullet Boost Gobblegum can apply an AAT to any weapon.",
	"Arm's Grace provides a helpful boost upon respawning, including the essential perks.",
	"Burned Out negates melee damage and applies a deadly burning effect to your attacker.",
	"Gobblegums can be a great way to acquire Pack-a-Punch early on.",
	"Specialist weapons must be recharged when you respawn.",
	"Custom ZBR options, like character selection, can be found in the settings tab.",
	"Suppressors greatly reduce the range of some weapons.",
	"Sniper rifles gain a large damage boost at medium-long range.",
	"EMP grenades can temporarily disable perks and various devices.",
	"Light machine guns have infinite reserve ammo.",
	"The turned AAT temporarily recruits enemy players to collect points for you."
}

-- Engine.GetCurrentMap() for map specific things

if Engine.GetCurrentMap() == "zm_castle" then
	dykFacts[#dykFacts + 1] = "The bow quests have some steps skipped, for your convenience."
end

CoD.Loading.GetDidYouKnowString = function ()
	return dykFacts[math.random(#dykFacts)]
end

LUI.createMenu.Loading = function ( parentRef )
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
	menuRef:setOwner( parentRef )
	menuRef:registerEventHandler( "start_loading", CoD.Loading.StartLoading )
	menuRef:registerEventHandler( "start_spinner", CoD.Loading.StartSpinner )
	menuRef:registerEventHandler( "fade_in_map_location", CoD.Loading.FadeInMapLocation )
	menuRef:registerEventHandler( "fade_in_gametype", CoD.Loading.FadeInGametype )
	menuRef:registerEventHandler( "fade_in_map_image", CoD.Loading.FadeInMapImage )
	local isCinematicLoad = false
	local currentMap = Engine.GetCurrentMap()
	local currentGametype = Engine.GetCurrentGameType()
	local mapLoadingImage = CoD.GetMapValue( currentMap, "loadingImage", "black" )

	-- CoD.zbr_load_alias = "zbr_load" .. tostring(math.random(0, 1));
	Engine.PlayMenuMusic("zbr_load")
	-- Engine.PlaySound(CoD.zbr_load_alias)
	Engine.SetDvar( "ui_useloadingmovie", 0 )
	if mapLoadingImage == nil or mapLoadingImage == "" or CoD.isMultiplayer then
		mapLoadingImage = "black"
	end

	if Engine.IsLevelPreloaded( currentMap ) then
		menuRef.addLoadingElement = function ( f6_arg0, f6_arg1 )
		end
	else
		menuRef.addLoadingElement = function ( f7_arg0, f7_arg1 )
			f7_arg0:addElement( f7_arg1 )
		end
	end

	menuRef.mapImage = LUI.UIStreamedImage.new()
	menuRef.mapImage.id = "mapImage"
	menuRef.mapImage:setLeftRight( false, false, -640, 640 )
	menuRef.mapImage:setTopBottom( false, false, -360, 360 )
	menuRef.mapImage:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_normal" ) )
	menuRef.mapImage:setImage( RegisterImage( mapLoadingImage ) )
	menuRef.mapImage:setPriority(-1000)
	menuRef:addElement( menuRef.mapImage )

	if isCinematicLoad == true then
		menuRef.mapImage:setShaderVector( 0, 0, 0, 0, 0 )
		menuRef.mapImage.ismp4 = false
	end
	
	local offset10 = 10
	local offset70 = 70
	local bigFont = "Big"
	local fontBig = CoD.fonts[bigFont]
	local bigFontSize = CoD.textSize[bigFont]
	local condensedFont = "Condensed"
	local fontCondensed = CoD.fonts[condensedFont]
	local fontCondensedSize = CoD.textSize[condensedFont]
	menuRef.mapNameLabel = LUI.UIText.new()
	menuRef.mapNameLabel.id = "mapNameLabel"
	menuRef.mapNameLabel:setLeftRight( true, false, offset70, offset70 + 1 )
	menuRef.mapNameLabel:setTopBottom( true, false, offset10, offset10 + bigFontSize )
	menuRef.mapNameLabel:setFont( fontBig )
	menuRef.mapNameLabel:setRGB( CoD.BOIIOrange.r, CoD.BOIIOrange.g, CoD.BOIIOrange.b )
	menuRef.mapNameLabel:setAlpha( 0 )
	menuRef.mapNameLabel:registerEventHandler( "transition_complete_map_name_fade_in", CoD.Loading.MapNameFadeInComplete )
	menuRef:addLoadingElement( menuRef.mapNameLabel )

	offset10 = offset10 + bigFontSize - 5
	menuRef.mapLocationLabel = LUI.UIText.new()
	menuRef.mapLocationLabel.id = "mapLocationLabel"
	menuRef.mapLocationLabel:setLeftRight( true, false, offset70, offset70 + 1 )
	menuRef.mapLocationLabel:setTopBottom( true, false, offset10, offset10 + fontCondensedSize )
	menuRef.mapLocationLabel:setFont( fontCondensed )
	menuRef.mapLocationLabel:setRGB( CoD.offWhite.r, CoD.offWhite.g, CoD.offWhite.b )
	menuRef.mapLocationLabel:setAlpha( 0 )
	menuRef.mapLocationLabel:registerEventHandler( "transition_complete_map_location_fade_in", CoD.Loading.MapLocationFadeInComplete )
	menuRef:addLoadingElement( menuRef.mapLocationLabel )

	offset10 = offset10 + fontCondensedSize - 2
	menuRef.gametypeLabel = LUI.UIText.new()
	menuRef.gametypeLabel.id = "gametypeLabel"
	menuRef.gametypeLabel:setLeftRight( true, false, offset70, offset70 + 1 )
	menuRef.gametypeLabel:setTopBottom( true, false, offset10, offset10 + fontCondensedSize )
	menuRef.gametypeLabel:setFont( fontCondensed )
	menuRef.gametypeLabel:setRGB( CoD.offWhite.r, CoD.offWhite.g, CoD.offWhite.b )
	menuRef.gametypeLabel:setAlpha( 0 )
	menuRef.gametypeLabel:registerEventHandler( "transition_complete_gametype_fade_in", CoD.Loading.GametypeFadeInComplete )
	menuRef:addLoadingElement( menuRef.gametypeLabel )

	offset10 = offset10 + fontCondensedSize + 5
	local currOff = 0
	local offset3 = 3
	local addResult = CoD.Loading.DYKFontHeight + offset3 * 2
	local offset2 = 2
	local addResult2 = addResult + 1 + offset2 + CoD.Loading.DYKFontHeight - offset10
	local subResult = CoD.Menu.Width - 5 * 2
	local offNegative200 = -200
	local off0 = 0
	local off2_2 = 2
	local addResult3 = addResult - off2_2 * 2
	local off6 = 6
	menuRef.loadingBarContainer = LUI.UIElement.new()
	menuRef.loadingBarContainer.id = "loadingBarContainer"
	menuRef.loadingBarContainer:setLeftRight( false, false, -subResult / 2, subResult / 2 )
	menuRef.loadingBarContainer:setTopBottom( false, true, offNegative200 - addResult2, offNegative200 )
	menuRef.loadingBarContainer:setAlpha( 0 )
	menuRef:addElement( menuRef.loadingBarContainer )
	menuRef.dykContainer = LUI.UIElement.new()
	menuRef.dykContainer.id = "dykContainer"
	menuRef.dykContainer:setLeftRight( true, true, 0, 0 )
	menuRef.dykContainer:setTopBottom( true, false, off0, off0 + addResult ) -- 0, 6
	menuRef.dykContainer.containerHeight = addResult -- 6
	menuRef.dykContainer.textAreaWidth = subResult - offset3 - off6 - off2_2 - addResult3 - 1
	CoD.Loading.SetupDYKContainerImages( menuRef.dykContainer )
	menuRef.didYouKnow = LUI.UIText.new()
	menuRef.didYouKnow:setLeftRight( true, true, offset3 + off6, -off2_2 - addResult3 - 1 )
	menuRef.didYouKnow:setTopBottom( true, false, offset3, offset3 + CoD.Loading.DYKFontHeight )
	menuRef.didYouKnow:setRGB( CoD.offWhite.r, CoD.offWhite.g, CoD.offWhite.b )
	menuRef.didYouKnow:setFont( CoD.Loading.DYKFont )
	menuRef.didYouKnow:setAlignment( LUI.Alignment.Left )
	menuRef.didYouKnow:setPriority( 0 )
	menuRef.dykContainer:addElement( menuRef.didYouKnow )
	menuRef.dykContainer:setAlpha( 0 )
	menuRef:addElement( menuRef.dykContainer )

	off0 = off0 + addResult + 1
	menuRef.spinner = LUI.UIImage.new()
	menuRef.spinner.id = "spinner"
	off2_2 = 110
	addResult3 = addResult3 * 5
	menuRef.spinner:setLeftRight( false, true, -(off2_2 + addResult3 / 2), -(off2_2 - addResult3 / 2) )
	menuRef.spinner:setTopBottom( false, true, -(off2_2 + addResult3 / 2), -(off2_2 - addResult3 / 2) )
	menuRef.spinner:setImage( RegisterMaterial( "lui_loader" ) )
	menuRef.spinner:setShaderVector( 0, 0, 0, 0, 0 )
	menuRef.spinner:setAlpha( 0 )
	menuRef.spinner:setPriority( 200 )
	menuRef:addElement( menuRef.spinner )
	local self = LUI.UIImage.new()
	self.id = "loadingBarBackground"
	self:setLeftRight( true, true, 1, -1 )
	self:setTopBottom( true, false, off0, off0 + offset2 )
	self:setRGB( 0.1, 0.1, 0.1 )
	menuRef.loadingBarContainer:addElement( self )
	local self = LUI.UIImage.new()
	self:setLeftRight( true, true, 1, -1 )
	self:setTopBottom( true, false, off0, off0 + offset2 )
	self:setRGB( CoD.BOIIOrange.r, CoD.BOIIOrange.g, CoD.BOIIOrange.b )
	menuRef.loadingBarContainer:addElement( self )
	local off1_235235 = 1
	local self = LUI.UIImage.new()
	self:setLeftRight( true, true, 2, -2 )
	self:setTopBottom( true, false, off0, off0 + off1_235235 )
	self:setRGB( 1, 1, 1 )
	self:setAlpha( 0.5 )
	menuRef.loadingBarContainer:addElement( self )
	menuRef.loadingBarContainer:addElement( menuRef.dykContainer )
	self:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_wipe" ) )
	self:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_wipe" ) )
	self:setShaderVector( 1, 0, 0, 0, 0 )
	self:setShaderVector( 2, 1, 0, 0, 0 )
	self:setShaderVector( 3, 0, 0, 0, 0 )
	self:setShaderVector( 1, 0, 0, 0, 0 )
	self:setShaderVector( 2, 1, 0, 0, 0 )
	self:setShaderVector( 3, 0, 0, 0, 0 )
	self:subscribeToGlobalModel( parentRef, "LoadingScreenTeamInfo", "loadedFraction", function ( modelRef )
		local loadedFraction = Engine.GetModelValue( modelRef )
		if loadedFraction then
			self:setShaderVector( 0, loadedFraction, 0, 0, 0 )
			self:setShaderVector( 0, loadedFraction, 0, 0, 0 )
		end
	end )
	LUI.OverrideFunction_CallOriginalSecond( menuRef, "close", function ( element )
		-- Engine.StopSound(CoD.zbr_load_alias)
		self:close()
	end )
	off0 = off0 + offset2
	menuRef.statusLabel = LUI.UIText.new()
	menuRef.statusLabel:setLeftRight( true, true, offset3 + off6, 0 )
	menuRef.statusLabel:setTopBottom( true, false, off0, off0 + CoD.Loading.DYKFontHeight )
	menuRef.statusLabel:setAlpha( 0.55 )
	menuRef.statusLabel:setFont( CoD.Loading.DYKFont )
	menuRef.statusLabel:setAlignment( LUI.Alignment.Left )
	menuRef.statusLabel:setupLoadingStatusText()
	menuRef.loadingBarContainer:addElement( menuRef.statusLabel )
	CoD.Loading.StartLoading( menuRef )
	menuRef:addElement( LUI.UITimer.new( CoD.Loading.SpinnerDelayTime, "start_spinner", true, menuRef ) )
	return menuRef
end

-- Engine.StopSound(CoD.zbr_load_alias)

CoD.Loading.FadeInMapLocation = function ( f18_arg0 )
	f18_arg0.mapLocationLabel:setText("ZOMBIE BLOOD RUSH")
	f18_arg0.mapLocationLabel:beginAnimation( "map_location_fade_in", CoD.Loading.FadeInTime )
	f18_arg0.mapLocationLabel:setAlpha( 1 )
end

CoD.Loading.SetupDYKContainerImages = function ( f23_arg0 )
	local self = LUI.UIImage.new()
	self:setLeftRight( true, true, 0, 0 )
	self:setTopBottom( true, true, 0, 0 )
	self:setRGB( 0, 0, 0 )
	self:setAlpha( 0.52 )
	self:setPriority( -110 )
	f23_arg0:addElement( self )
	local f23_local1 = CoD.BorderT6.new( 1, 1, 1, 1, 0.05 )
	f23_local1:setPriority( -100 )
	f23_arg0:addElement( f23_local1 )
	local self = LUI.UIImage.new()
	self:setLeftRight( true, true, 2, -2 )
	self:setTopBottom( true, true, 1, -1 )
	self:setImage( RegisterImage( "uie_mp_cac_grad_stretch" ) )
	self:setRGB( 0, 0, 0 )
	self:setAlpha( 0.45 )
	self:setPriority( -80 )
	f23_arg0:addElement( self )
	local self = LUI.UIImage.new()
	self:setLeftRight( true, true, 3, -3 )
	self:setTopBottom( true, false, 3, 23 )
	self:setImage( RegisterImage( "uie_mp_cac_grad_stretch" ) )
	self:setPriority( 100 )
	self:setAlpha( 0.06 )
	f23_arg0:addElement( self )
end

ZBR.SelectTeams();