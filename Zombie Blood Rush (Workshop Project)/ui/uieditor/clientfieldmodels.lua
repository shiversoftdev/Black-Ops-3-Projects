EnableGlobals()
require("ui.cards.invitationals_2021")
require("lua.shared.luareadonlytables")
require("ui.t7.utility.codscoreboardutility")
local f0_local0 = 1
local f0_local1 = 1000
local f0_local2 = 2000
local f0_local3 = 3000
local f0_local4 = 4000
local f0_local5 = 5000
local f0_local6 = 6000
local f0_local7 = 6001
local f0_local8 = 7000
local f0_local9 = 8000
local f0_local10 = 9000
local f0_local11 = 9001
local f0_local12 = 10000
local f0_local13 = 11000
local f0_local14 = 11001
local f0_local15 = 12000
local f0_local16 = 13000
local f0_local17 = 14000
local f0_local18 = 15000
local f0_local19 = 15001
local f0_local20 = 16000
local f0_local21 = 17000
local f0_local22 = 18000
local f0_local23 = 19000
local f0_local24 = 20000
local f0_local25 = 21000
local f0_local26 = 27000
local f0_local27 = f0_local5
local f0_local28 = f0_local10
local f0_local29 = f0_local15
local f0_local30 = f0_local18
local f0_local31 = f0_local25
CoD.isFrontend = Engine.GetCurrentMap() == "core_frontend"

if not CoD.isFrontend then
	require("ui.uieditor.widgets.hud.damage3d")
	require("ui.uieditor.menus.hud.he_zbr_score")
else
	require("ui.uieditor.widgets.hud.lobbycharacters")
end

if not CoD.isFrontend and not CoD.isZombie then
	Engine.RegisterClientUIModelField( "hudItems.rejack.activationWindowEntered", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
	Engine.RegisterClientUIModelField( "hudItems.rejack.rejackActivated", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
end
if Engine.IsScrSystemActive( "weaponobjects" ) then
	Engine.RegisterClientUIModelField( "hudItems.proximityAlarm", Enum.UIModelClientFieldType.CF_INT, 2, f0_local0 )
end

local function startswith__(String,Start)
	return string.sub(String,1,string.len(Start))==Start
 end

-- Engine.RegisterClientUIModelField( "hudItems.killcamAllowRespawn", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
if startswith__(Engine.GetCurrentMap(), "mp_") then
	Engine.RegisterClientUIModelField( "hudItems.killcamAllowRespawn", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
end

if CoD.isMultiplayer and not CoD.isFrontend then
	Engine.RegisterClientUIModelField( "hudItems.hideOutcomeUI", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
	Engine.RegisterClientUIModelField( "hudItems.killcamAllowRespawn", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
	Engine.RegisterClientUIModelField( "hudItems.remoteKillstreakActivated", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
	Engine.RegisterClientUIModelField( "hudItems.captureCrateState", Enum.UIModelClientFieldType.CF_INT, 2, f0_local5 )
	Engine.RegisterClientUIModelField( "hudItems.captureCrateTotalTime", Enum.UIModelClientFieldType.CF_INT, 13, f0_local5 )
	if Dvar.ui_gametype:get() == "clean" then
		Engine.RegisterClientUIModelField( "hudItems.cleanCarryCount", Enum.UIModelClientFieldType.CF_INT, 4, f0_local15 )
		Engine.RegisterClientUIModelField( "hudItems.cleanCarryFull", Enum.UIModelClientFieldType.CF_INT, 1, f0_local15 )
	end
end
if CoD.isSafehouse then
	Engine.RegisterClientUIModelField( "safehouse.inClientBunk", Enum.UIModelClientFieldType.CF_INT, 2, f0_local0 )
	Engine.RegisterClientUIModelField( "safehouse.inTrainingSim", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
end
if Engine.IsScrSystemActive( "cybercom" ) then
	Engine.RegisterClientUIModelField( "playerAbilities.inRange", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
end
if CoD.isCampaign and not CoD.isFrontend then
	Engine.RegisterClientUIModelField( "hudItems.cybercoreSelectMenuDisabled", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
	Engine.RegisterClientUIModelField( "hudItems.playerInCombat", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
	Engine.RegisterClientUIModelField( "playerAbilities.repulsorIndicatorDirection", Enum.UIModelClientFieldType.CF_INT, 2, f0_local0 )
	Engine.RegisterClientUIModelField( "playerAbilities.repulsorIndicatorIntensity", Enum.UIModelClientFieldType.CF_INT, 2, f0_local0 )
	Engine.RegisterClientUIModelField( "playerAbilities.proximityIndicatorDirection", Enum.UIModelClientFieldType.CF_INT, 2, f0_local0 )
	Engine.RegisterClientUIModelField( "playerAbilities.proximityIndicatorIntensity", Enum.UIModelClientFieldType.CF_INT, 2, f0_local0 )
	Engine.RegisterClientUIModelField( "serverDifficulty", Enum.UIModelClientFieldType.CF_INT, 3, f0_local0 )
end
if Engine.IsScrSystemActive( "aquifer_util" ) then
	Engine.RegisterClientUIModelField( "vehicle.weaponIndex", Enum.UIModelClientFieldType.CF_INT, 2, f0_local0 )
	Engine.RegisterClientUIModelField( "vehicle.lockOn", Enum.UIModelClientFieldType.CF_FLOAT, 8, f0_local0 )
	Engine.RegisterClientUIModelField( "vehicle.showLandHint", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
	Engine.RegisterClientUIModelField( "vehicle.showAimHint", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
	Engine.RegisterClientUIModelField( "hackUpload.percent", Enum.UIModelClientFieldType.CF_FLOAT, 8, f0_local0 )
end
if not CoD.isFrontend and not CoD.isCampaign and CoD.isZombie then
	Engine.RegisterClientUIModelField( "hudItems.doublePointsActive", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
	Engine.RegisterClientUIModelField( "player_lives", Enum.UIModelClientFieldType.CF_INT, 2, f0_local0 )
	Engine.RegisterClientUIModelField( "zmhud.swordEnergy", Enum.UIModelClientFieldType.CF_FLOAT, 7, f0_local0 )
	Engine.RegisterClientUIModelField( "zmhud.swordState", Enum.UIModelClientFieldType.CF_INT, 2, f0_local0 )
	Engine.RegisterClientUIModelField( "hudItems.showDpadUp", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
	Engine.RegisterClientUIModelField( "hudItems.showDpadDown", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
	Engine.RegisterClientUIModelField( "hudItems.showDpadLeft", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
	Engine.RegisterClientUIModelField( "hudItems.showDpadRight", Enum.UIModelClientFieldType.CF_INT, 1, f0_local0 )
	local f0_local32 = CoD.zbr_max_players
	for f0_local33 = 0, f0_local32 - 1, 1 do
		Engine.RegisterClientUIModelField( "PlayerList.client" .. f0_local33 .. ".score_cf_damage", Enum.UIModelClientFieldType.CF_COUNTER, 3, f0_local0 )
		-- Engine.RegisterClientUIModelField( "PlayerList.client" .. f0_local33 .. ".score_cf_death_normal", Enum.UIModelClientFieldType.CF_COUNTER, 2, f0_local0 )
		Engine.RegisterClientUIModelField( "PlayerList.client" .. f0_local33 .. ".score_cf_death_torso", Enum.UIModelClientFieldType.CF_COUNTER, 2, f0_local0 )
		-- Engine.RegisterClientUIModelField( "PlayerList.client" .. f0_local33 .. ".score_cf_death_neck", Enum.UIModelClientFieldType.CF_COUNTER, 2, f0_local0 )
		Engine.RegisterClientUIModelField( "PlayerList.client" .. f0_local33 .. ".score_cf_death_head", Enum.UIModelClientFieldType.CF_COUNTER, 2, f0_local0 )
		Engine.RegisterClientUIModelField( "PlayerList.client" .. f0_local33 .. ".score_cf_death_melee", Enum.UIModelClientFieldType.CF_COUNTER, 2, f0_local0 )
	end
	if Engine.GetCurrentMap() == "zm_island" then
		Engine.RegisterClientUIModelField( "hudItems.showDpadRight_Spider", Enum.UIModelClientFieldType.CF_INT, 1, f0_local28 )
	end
	if Engine.GetCurrentMap() == "zm_stalingrad" then
		Engine.RegisterClientUIModelField( "trialWidget.icon", Enum.UIModelClientFieldType.CF_INT, 2, f0_local29 )
		Engine.RegisterClientUIModelField( "trialWidget.challenge1state", Enum.UIModelClientFieldType.CF_INT, 2, f0_local29 )
		Engine.RegisterClientUIModelField( "trialWidget.challenge2state", Enum.UIModelClientFieldType.CF_INT, 2, f0_local29 )
		Engine.RegisterClientUIModelField( "trialWidget.challenge3state", Enum.UIModelClientFieldType.CF_INT, 2, f0_local29 )
	end
	if Engine.GetCurrentMap() == "zm_genesis" then
		Engine.RegisterClientUIModelField( "trialWidget.icon", Enum.UIModelClientFieldType.CF_INT, 2, f0_local29 )
	end
	if Engine.GetCurrentMap() == "zm_island" or Engine.GetCurrentMap() == "zm_stalingrad" or Engine.GetCurrentMap() == "zm_genesis" then
		Engine.RegisterClientUIModelField( "trialWidget.visible", Enum.UIModelClientFieldType.CF_INT, 1, f0_local28 )
		Engine.RegisterClientUIModelField( "trialWidget.progress", Enum.UIModelClientFieldType.CF_FLOAT, 7, f0_local28 )
	end
end

CoD.isOnlineGame = function()
	return true
end

setup_team_stuff()

function GetBGBOverrideCount(count, id, ref)

	if Engine.TableLookup(nil, "gamedata/stats/zm/zm_statstable.csv", 0, id, 2) ~= "bubblegum_consumable" then return count end

	local datype = Engine.TableLookup(nil, "gamedata/stats/zm/zm_statstable.csv", 0, id, 16)

	if datype == "1" then return CoD.zbr_max_megas end
	if datype == "2" then return CoD.zbr_max_rmegas end
	if datype == "3" then return CoD.zbr_max_urmegas end

	return count
end

function GetConsumableCountFromIndex( f297_arg0, item_index )
	local controller_index = f297_arg0
	if Engine.IsZombiesGame() then
		if CoD.BubbleGumBuffUtility.UseTestData() then
			return 11
		else
			local f297_local1 = Engine.GetPlayerStats( controller_index )
			local f297_local2 = Engine.GetLootItemQuantity( controller_index, Engine.GetItemRef( item_index ), Enum.eModes.MODE_ZOMBIES )
			
			f297_local2 = GetBGBOverrideCount(f297_local2, item_index, Engine.GetItemRef(item_index))

			if not f297_local2 then
				return 0
			else
				return math.min( 999, math.max( f297_local2, 0 ) )
			end
		end
	else
		return 0
	end
end

if not CoD.isFrontend then

	local function fix_bgb(BubbleGumPackInGame, controller, active_hud)
		local controller = Engine.GetPrimaryController()
	
		-- ill just copy them and override them  but in the correct order
		local original_stroke = BubbleGumPackInGame.BubbleGumPack.BubbleGumPackLabelStroke
		local original_label = BubbleGumPackInGame.BubbleGumPack.BubbleGumPackLabel
	
		local BubbleGumPackLabelStroke = LUI.UITightText.new()
		BubbleGumPackLabelStroke:setLeftRight( true, false, 14, 214 )
		BubbleGumPackLabelStroke:setTopBottom( true, false, 8, 28 )
		BubbleGumPackLabelStroke:setRGB( 0, 0, 0 )
		BubbleGumPackLabelStroke:setTTF( "fonts/escom.ttf" )
		BubbleGumPackLabelStroke:setMaterial( LUI.UIImage.GetCachedMaterial( "sw4_2d_uie_font_cached_glow" ) )
		BubbleGumPackLabelStroke:setShaderVector( 0, 0.08, 0, 0, 0 )
		BubbleGumPackLabelStroke:setShaderVector( 1, 0, 0, 0, 0 )
		BubbleGumPackLabelStroke:setShaderVector( 2, 1, 0, 0, 0 )
		BubbleGumPackLabelStroke:subscribeToGlobalModel( controller, "EquippedBubbleGumPack", "bgbPackIndex", function ( modelRef )
			local bgbPackIndex = Engine.GetModelValue( modelRef )
			if bgbPackIndex then
				BubbleGumPackLabelStroke:setText( GetBubbleGumPackNameFromPackIndex( controller, bgbPackIndex ) )
			end
		end )
		BubbleGumPackInGame.BubbleGumPack:addElement( BubbleGumPackLabelStroke )
		BubbleGumPackInGame.BubbleGumPack.BubbleGumPackLabelStroke = BubbleGumPackLabelStroke
	
		local BubbleGumPackLabel = LUI.UITightText.new()
		BubbleGumPackLabel:setLeftRight( true, false, 14, 214 )
		BubbleGumPackLabel:setTopBottom( true, false, 8, 28 )
		BubbleGumPackLabel:setTTF( "fonts/escom.ttf" )
		BubbleGumPackLabel:subscribeToGlobalModel( controller, "EquippedBubbleGumPack", "bgbPackIndex", function ( modelRef )
			local bgbPackIndex = Engine.GetModelValue( modelRef )
			if bgbPackIndex then
				BubbleGumPackLabel:setText( GetBubbleGumPackNameFromPackIndex( controller, bgbPackIndex ) )
			end
		end )
		BubbleGumPackInGame.BubbleGumPack:addElement( BubbleGumPackLabel )
		BubbleGumPackInGame.BubbleGumPack.BubbleGumPackLabel = BubbleGumPackLabel
	
		local BubbleGumBuffs = LUI.UIList.new( active_hud, controller, 9, 0, nil, false, false, 0, 0, false, false )
		BubbleGumBuffs:makeFocusable()
		BubbleGumBuffs:setLeftRight( true, false, 7, 363 )
		BubbleGumBuffs:setTopBottom( true, false, 46.48, 155.48 )
		BubbleGumBuffs:setWidgetType( CoD.BubbleGumBuffInGame )
		BubbleGumBuffs:setHorizontalCount( 5 )
		BubbleGumBuffs:setSpacing( 9 )
		BubbleGumBuffs:setDataSource( "BubbleGumBuffs" )
		BubbleGumPackInGame.BubbleGumPack:addElement( BubbleGumBuffs )
		BubbleGumPackInGame.BubbleGumPack.BubbleGumBuffs = BubbleGumBuffs
	
		original_label:close()
		original_stroke:close()
	end
	
	local function add_bgb_ui(menu_ref, controller)
		require("ui.uieditor.widgets.HUD.ZM_AmmoWidget.ZmAmmo_BBGumMeterWidget")
		require("ui.uieditor.widgets.HUD.ZM_AmmoWidget.ZmAmmo_DpadIconBgm")
		require("ui.uieditor.widgets.HUD.ZM_AmmoWidget.ZmAmmo_EquipContainer")
		require("ui.uieditor.widgets.BubbleGumBuffs.BubbleGumPackInGame")
		require("ui.uieditor.widgets.HUD.ZM_NotifFactory.ZmNotifBGB_ContainerFactory")
		require("ui.uieditor.widgets.Notifications.Notification")
	
		local position_for_map = 
		{
			["zm_log_kowloon"] = 
			{
				leftAnchor = false, 
				rightAnchor = true,
				topAnchor = false,
				bottomAnchor = true,
				left = (-32 - 53), right = (-32 - 53) + 53,
				-- top = 360 - (53 / 2), bottom = 360 - (53 / 2) + 53
				top = -150 , bottom = -150 + 53
			},
	
			["zm_daybreak"] = 
			{
				leftAnchor = false, 
				rightAnchor = true,
				topAnchor = true,
				bottomAnchor = false,
				left = (-33 - 53), right = (-33 - 53) + 53,
				top = 360 - (53 / 2), bottom = 360 - (53 / 2) + 53
			},
	
			["zm_1"] = 
			{
				leftAnchor = false, 
				rightAnchor = true,
				topAnchor = true,
				bottomAnchor = false,
				left = (-33 - 53), right = (-33 - 53) + 53,
				top = 360 - (53 / 2), bottom = 360 - (53 / 2) + 53
			},
	
			["zm_mori"] = 
			{
				leftAnchor = false, 
				rightAnchor = true,
				topAnchor = false,
				bottomAnchor = true,
				left = (-35 - 53), right = (-35 - 53) + 53,
				top = -180 , bottom = -180 + 53
			},
	
			["zm_powerstation"] = 
			{
				leftAnchor = false, 
				rightAnchor = true,
				topAnchor = true,
				bottomAnchor = false,
				left = (-33 - 53), right = (-33 - 53) + 53,
				top = 360 - (53 / 2), bottom = 360 - (53 / 2) + 53
			},

			["zm_leviathan"] = 
			{
				only_pack = true
			}
	
			-- ["zm_factory"] = {
			-- 	leftAnchor = false, 
			-- 	rightAnchor = true,
			-- 	topAnchor = true,
			-- 	bottomAnchor = false,
			-- 	left = -(20+53), right = -20, 
			-- 	top = 16 + 300, bottom = 69 + 300
			-- },
	
			-- ["default"] = {
			-- 	leftAnchor = true, 
			-- 	rightAnchor = false,
			-- 	topAnchor = true,
			-- 	bottomAnchor = false,
			-- 	left = 320, right = 373, -- default is 53 wide
			-- 	top = 16, bottom = 69   
			-- }
		}
	
		local bgb_position = position_for_map[Engine.GetCurrentMapName()]
		if bgb_position == nil then
			return
		end

		if bgb_position.only_pack == true then
			-- shows your current bgb loadout when you press tab
			local BubbleGumPackInGame = CoD.BubbleGumPackInGame.new(menu_ref, controller)
			BubbleGumPackInGame:setLeftRight( false, false, -184, 184 )
			BubbleGumPackInGame:setTopBottom( true, false, 36, 185 )
			menu_ref:addElement( BubbleGumPackInGame )
			menu_ref.BubbleGumPackInGame = BubbleGumPackInGame
		
			fix_bgb(BubbleGumPackInGame, controller, menu_ref)
			return
		end
	
		if menu_ref.Notifications == nil then
			local Notifications = CoD.Notification.new( menu_ref, controller )
			Notifications:setLeftRight( true, true, 0, 0 )
			Notifications:setTopBottom( true, true, 0, 0 )
			menu_ref:addElement( Notifications )
			menu_ref.Notifications = Notifications
		end
		
		-- notification in the top center of screen when you pick up the gum
		local ZmNotifBGBContainerFactory = CoD.ZmNotifBGB_ContainerFactory.new( menu_ref, controller )
		ZmNotifBGBContainerFactory:setLeftRight( false, false, -156, 156 )
		ZmNotifBGBContainerFactory:setTopBottom( true, false, -6, 247 )
		ZmNotifBGBContainerFactory:setScale( 0.75 )
		ZmNotifBGBContainerFactory:subscribeToGlobalModel( controller, "PerController", "scriptNotify", function ( modelRef )
			local container_widget = ZmNotifBGBContainerFactory
			if IsParamModelEqualToString( modelRef, "zombie_bgb_token_notification" ) then
				AddZombieBGBTokenNotification( menu_ref, container_widget, controller, modelRef )
			elseif IsParamModelEqualToString( modelRef, "zombie_bgb_notification" ) then
				AddZombieBGBNotification( menu_ref, container_widget, modelRef )
			elseif IsParamModelEqualToString( modelRef, "zombie_notification" ) then
				AddZombieNotification( menu_ref, container_widget, modelRef )
			end
		end )
		menu_ref:addElement( ZmNotifBGBContainerFactory )
		menu_ref.ZmNotifBGBContainerFactory = ZmNotifBGBContainerFactory
	
		-- shows your current bgb loadout when you press tab
		local BubbleGumPackInGame = CoD.BubbleGumPackInGame.new(menu_ref, controller)
		BubbleGumPackInGame:setLeftRight( false, false, -184, 184 )
		BubbleGumPackInGame:setTopBottom( true, false, 36, 185 )
		menu_ref:addElement( BubbleGumPackInGame )
		menu_ref.BubbleGumPackInGame = BubbleGumPackInGame
	
		fix_bgb(BubbleGumPackInGame, controller, menu_ref)
				
		-- the current bgb icon and progress meter
		local ZmAmmoBBGumMeterWidget = CoD.ZmAmmo_BBGumMeterWidget.new( menu_ref, controller )
		ZmAmmoBBGumMeterWidget:setLeftRight( bgb_position.leftAnchor, bgb_position.rightAnchor, bgb_position.left, bgb_position.right )
		ZmAmmoBBGumMeterWidget:setTopBottom( bgb_position.topAnchor, bgb_position.bottomAnchor, bgb_position.top, bgb_position.bottom )
		ZmAmmoBBGumMeterWidget:setScale( 1.4 )
		menu_ref:addElement( ZmAmmoBBGumMeterWidget )
		menu_ref.ZmAmmoBBGumMeterWidget = ZmAmmoBBGumMeterWidget
	
		-- uses left text underneath the icon
		local at, ab, t, b = ZmAmmoBBGumMeterWidget:getLocalTopBottom();
		local ar, al, l, r = ZmAmmoBBGumMeterWidget:getLocalLeftRight()
		local bgb_usages_text = LUI.UIText.new()
		
		bgb_usages_text:setLeftRight( ar, al, l-76, r ) -- copy the bgb widget horizontal placement
	
		bgb_usages_text:setTopBottom( at, ab, t + (53/2) - (16/2), t + (53/2) + (16/2) )
		bgb_usages_text:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_CENTER)
		menu_ref:addElement(bgb_usages_text)
		menu_ref.bgb_usages_text = bgb_usages_text
	
		local bgb_usages_text_bg = LUI.UIText.new()
		bgb_usages_text_bg:setLeftRight( ar, al, l-75, r  )
		bgb_usages_text_bg:setTopBottom( at, ab, t + (53/2) - (16/2), t + (53/2) + (16/2) )
		bgb_usages_text_bg:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_CENTER)
		bgb_usages_text_bg:setRGB(0.0, 0.0, 0.0)
		menu_ref:addElement(bgb_usages_text)
		menu_ref.bgb_usages_text_bg = bgb_usages_text_bg
	
		bgb_usages_text:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "bgb_activations_remaining" ), function ( modelRef )
			local usages = Engine.GetModelValue(modelRef)
			if usages then 
				bgb_usages_text:setText(Engine.Localize(usages)) 
				bgb_usages_text_bg:setText(Engine.Localize(usages)) 
				if usages < 1 then 
					bgb_usages_text:setAlpha(0)
					bgb_usages_text_bg:setAlpha(0)
				elseif usages > 1 then
					bgb_usages_text:setAlpha(1)
					bgb_usages_text_bg:setAlpha(1)
				end
			end
	
			menu_ref:updateElementState( bgb_usages_text, {
				name = "model_validation",
				menu = menu_ref,
				modelValue = Engine.GetModelValue( modelRef ),
				modelName = "bgb_activations_remaining"
			} )
	
			LUI.OverrideFunction_CallOriginalSecond(menu_ref, "close", function(element)
				element.bgb_usages_text:close()
				element.bgb_usages_text_bg:close()
				element.ZmAmmoBBGumMeterWidget:close()
				element.BubbleGumPackInGame = BubbleGumPackInGame
				element.ZmNotifBGBContainerFactory:close()
			end)
		end )
	end

	CoD.add_bgb_ui = add_bgb_ui;

	DataSources.EquippedBubbleGumPack = {
		getModel = function ( f227_arg0 )
			local f227_local0 = Engine.CreateModel( Engine.GetModelForController( f227_arg0 ), "EquippedBubbleGumPack" )
			Engine.SetModelValue( Engine.CreateModel( f227_local0, "bgbPackIndex" ), Engine.GetEquippedBubbleGumPack( f227_arg0 ) )
			return f227_local0
		end
	}
	
	DataSources.BubbleGumBuffs = {
		prepare = function ( controller, f228_arg1, f228_arg2 )
			f228_arg1.rootModel = DataSources.BubbleGumBuffs.setupBubbleGumBuffsModel( controller, Engine.GetModelForController( controller ), Engine.GetEquippedBubbleGumPack( controller ) )
		end,
		getCount = function ( f229_arg0 )
			return CoD.BubbleGumBuffs.NumBuffsPerPack
		end,
		getItem = function ( f230_arg0, f230_arg1, f230_arg2 )
			if f230_arg1:getParent() then
				local f230_local0 = f230_arg1:getParent()
				return f230_local0:getModel( f230_arg0, "BubbleGumBuffs." .. f230_arg2 )
			else
				return Engine.CreateModel( Engine.GetModelForController( f230_arg0 ), "BubbleGumBuffs." .. f230_arg2 )
			end
		end,
		setupBubbleGumBuffsModel = function ( controller, modelForController, equippedPack )
			local rootModel = Engine.CreateModel( modelForController, "BubbleGumBuffs" )
			for buff_index = 0, CoD.BubbleGumBuffs.NumBuffsPerPack - 1, 1 do
				local gums_used = Engine.CreateModel( modelForController, "bgb_usage_" .. tostring(buff_index) )
				local num_gums_used = Engine.GetModelValue(gums_used)

				if num_gums_used == nil then 
					num_gums_used = 0
					Engine.SetModelValue(gums_used, 0)
				end

				local slotIndex = Engine.CreateModel( rootModel, buff_index + 1 )
				local itemIndex = Engine.GetBubbleGumBuff( controller, equippedPack, buff_index )
				local dlcIndex = CoD.SafeGetModelValue( Engine.GetGlobalModel(), "Unlockables." .. itemIndex .. ".dlcIndex" )
				Engine.SetModelValue( Engine.CreateModel( slotIndex, "bgbIndex" ), buff_index )
				Engine.SetModelValue( Engine.CreateModel( slotIndex, "itemIndex" ), itemIndex )
				Engine.SetModelValue( Engine.CreateModel( slotIndex, "dlcIndex" ), dlcIndex )
				if IsInGame() then
					Engine.SetModelValue( Engine.CreateModel( slotIndex, "remaining" ), GetConsumableCountFromIndex( controller, itemIndex ) - num_gums_used )
				end
			end
			return rootModel
		end,
		cleanup = function ( f232_arg0 )
			if f232_arg0.rootModel then
				Engine.UnsubscribeAndFreeModel( f232_arg0.rootModel )
				f232_arg0.rootModel = nil
			end
		end
	}
end

require("lua.shared.luareadonlytables")

local ship_maxplayers = CoD.zbr_max_players
local is_debug = CoD.zbr_is_debug
local is_dev = CoD.zbr_is_dev
local workshop_id = CoD.zbr_workshop_id

LobbyData.UITargets.UI_ZMLOBBYONLINE.maxClients = ship_maxplayers
LobbyData.UITargets.UI_ZMLOBBYONLINEPUBLICGAME.maxClients = ship_maxplayers
LobbyData.UITargets.UI_ZMLOBBYONLINECUSTOMGAME.maxClients = ship_maxplayers
LobbyData.UITargets.UI_ZMLOBBYONLINE.room = "mp_arena"
LobbyData.UITargets.UI_ZMLOBBYONLINEPUBLICGAME.room = "mp_arena"
LobbyData.UITargets.UI_ZMLOBBYONLINECUSTOMGAME.room = "mp_arena"
LobbyData.UITargets.UI_ZMLOBBYONLINECUSTOMGAME.title = "ZOMBIE BLOOD RUSH"
LobbyData.UITargets.UI_ZMLOBBYONLINECUSTOMGAME.kicker = "ZOMBIE BLOOD RUSH"

local function init_zbr()
	if Engine["IsBOIII"] == true then
		CoD.zbr_load_failed_reason = "Zombie Blood Rush is not supported on the BOIII client. Please use an official version of Black Ops III on Steam to play Zombie Blood Rush."
		return false
	end

	if CoD.zbr then
		return false
	end
	CoD.zbr = true
	CoD.zbr_loaded = true
	
	if ZBR then else
		local dllPath = "bruh"
		if is_debug then
			dllPath = [[.\mods\t7_zbr\zone\]]
		else
			dllPath = [[..\..\workshop\content\311210\]] .. workshop_id .. "\\"
		end

		local dllName = "zbr.dll"
		local dll2Name = "zbr2.dll"
		local discordName = "discord_game_sdk.dll"
		CopyFile(dllPath..discordName, discordName)
		CopyFile(dllPath..dllName, dllName)
		CopyFile(dllPath..dll2Name, dll2Name)

		CoD.zbr_dll = dllName
		CoD.zbr_init_luavm = require("package").loadlib(CoD.zbr_dll, "zbr_init_luavm"); -- will setup engine functions automatically

		if CoD.zbr_init_luavm then
			CoD.zbr_init_luavm();
		else
			require("os").exit()
		end
	end

	CoD.zbr_load_mod = Engine["LoadZBRMod"] -- require("package").loadlib(CoD.zbr_dll, "LoadMod");
	CoD.zbr_enable_duos = Engine["EnableDuos"] --require("package").loadlib(CoD.zbr_dll, "EnableDuos")
	CoD.zbr_enable_solos = Engine["EnableSolos"] -- require("package").loadlib(CoD.zbr_dll, "EnableSolos")
	CoD.zbr_discord_init = Engine["EnableDiscordSDK"] -- require("package").loadlib(CoD.zbr_dll, "EnableDiscordSDK")
	CoD.zbr_patchLobbyDisconnect = Engine["PatchDisconnectExploit"] -- require("package").loadlib(CoD.zbr_dll, "PatchDisconnectExploit");

	CoD.zbr_discord_init();
	CoD.zbr_patchLobbyDisconnect();

	if not ZBR.HasAdditionalContent() then
		CoD.zbr_loaded = false
		CoD.zbr_load_failed_reason = "Please download the ZBR Additional Assets mod linked on the workshop page. You cannot play the mod without these assets."
		Engine.ComError(Enum.errorCode.ERROR_DROP, CoD.zbr_load_failed_reason)
		return
	end

	if ZBR.GetBuildID == nil or ZBR.GetBuildID() ~= CoD.zbr_build_id then
		CoD.zbr_loaded = false
		local vx = "unknown"
		if ZBR.GetBuildID ~= nil then
			vx = ZBR.GetBuildID()
		end
		CoD.zbr_load_failed_reason = "Version mismatch detected (native version '" .. vx .. "' doesn't match lua version '" .. CoD.zbr_build_id .. "'). Please unsubscribe from the mod and resubscribe to fix this error."
		Engine.ComError(Enum.errorCode.ERROR_DROP, CoD.zbr_load_failed_reason)
		return
	end

	if not CoD.zbr_is_debug then
		local update_status = ZBR.NeedsUpdates()
		if update_status ~= CoD.ZBR_UPDATE_GOOD then

			if update_status == CoD.ZBR_UPDATE_UPDATE_CHARACTERS then
				CoD.zbr_load_failed_reason = "Your installation of the ZBR Additional Assets is outdated. Please update the workshop item before playing ZBR."
				Engine.ComError(Enum.errorCode.ERROR_DROP, CoD.zbr_load_failed_reason)
				return
			end

			if update_status == CoD.ZBR_UPDATE_UPDATE_BUILD then
				CoD.zbr_load_failed_reason = "Your installation of ZBR is outdated. Please update the workshop item before playing."
				Engine.ComError(Enum.errorCode.ERROR_DROP, CoD.zbr_load_failed_reason)
				return
			end
			
		end
	end
end

init_zbr()

function __HUD_StartKillcamHud( f70_arg0, f70_arg1 )
	if f70_arg0.T7HudMenuGameMode and not f70_arg0.killcamHUD and not CoD.isCampaign then
		if Engine.UpdateKillcamUIModels then
			Engine.UpdateKillcamUIModels( f70_arg1.controller, Engine.GetPredictedClientNum( f70_arg1.controller ) )
		end
		f70_arg0.killcamHUD = LUI.createMenu.KillcamMenu( f70_arg1.controller )
		f70_arg0.killcamHUD:addElementBefore( f70_arg0.T7HudMenuGameMode )
	end
end

function __HUD_StopKillcamHud( f71_arg0, f71_arg1 )
	if f71_arg0.killcamHUD then
		f71_arg0.killcamHUD:close()
		f71_arg0.killcamHUD = nil
	end
end

local function __HUD_UpdateRefresh( f72_arg0, f72_arg1 )
	if Engine.IsVisibilityBitSet( f72_arg1.controller, Enum.UIVisibilityBit.BIT_IN_KILLCAM ) then
		__HUD_StartKillcamHud( f72_arg0, f72_arg1 )
	else
		__HUD_StopKillcamHud( f72_arg0, f72_arg1 )
	end
end

function __HUD_SetupEventHandlers_Common( f25_arg0 )
	local f34_arg0 = f25_arg0
	local f34_local0 = f34_arg0:getOwner()
	if f34_local0 == nil then
		f34_local0 = Engine.GetPrimaryController()
	end
	local f34_local1 = function ( f35_arg0 )
		__HUD_UpdateRefresh( f34_arg0, {
			controller = f34_local0
		} )
	end

	local f34_local2 = Engine.GetModelForController( f34_local0 )
	f34_arg0:subscribeToModel( Engine.GetModel( f34_local2, "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SPECTATING_CLIENT ), f34_local1 )
	f34_arg0:subscribeToModel( Engine.GetModel( f34_local2, "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_TEAM_SPECTATOR ), f34_local1 )
	f34_arg0:subscribeToModel( Engine.GetModel( f34_local2, "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_UI_ACTIVE ), f34_local1 )
	f34_arg0:subscribeToModel( Engine.GetModel( f34_local2, "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED ), f34_local1 )
	f34_arg0:subscribeToModel( Engine.GetModel( f34_local2, "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_KILLCAM ), f34_local1 )
	f34_arg0:subscribeToModel( Engine.GetModel( f34_local2, "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_FINAL_KILLCAM ), f34_local1 )
	f34_arg0:subscribeToModel( Engine.GetModel( f34_local2, "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_ROUND_END_KILLCAM ), f34_local1 )
	f34_arg0:subscribeToModel( Engine.GetModel( f34_local2, "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_MIGRATING_HOST ), f34_local1 )

	return result
end

function RedeployRequest(parent, f424_arg1, controller, f1092_arg3, f1092_arg4)
	SendMenuResponse(0, "StartMenu_Main", "kmsr");
	StartMenuGoBack_ListElement(parent, f424_arg1, controller, f1092_arg3, f1092_arg4)
end

function setup_start_menu()
	DataSources.StartMenuGameOptions = ListHelper_SetupDataSource( "StartMenuGameOptions", function ( f89_arg0 )
		local f89_local0 = {}
		if CoD.isZombie then
			table.insert( f89_local0, {
				models = {
					displayText = "MENU_RESUMEGAME_CAPS",
					action = StartMenuGoBack_ListElement
				}
			} )
			table.insert( f89_local0, {
				models = {
					displayText = "SUICIDE",
					action = RedeployRequest
				}
			} )
			if Engine.IsLobbyHost( Enum.LobbyType.LOBBY_TYPE_GAME ) then
				table.insert( f89_local0, {
					models = {
						displayText = "MENU_RESTART_LEVEL_CAPS",
						action = RestartGame
					}
				} )
			end
			if Engine.IsLobbyHost( Enum.LobbyType.LOBBY_TYPE_GAME ) == true then
				table.insert( f89_local0, {
					models = {
						displayText = "MENU_END_GAME_CAPS",
						action = QuitGame_MP
					}
				} )
			else
				table.insert( f89_local0, {
					models = {
						displayText = "MENU_QUIT_GAME_CAPS",
						action = QuitGame_MP
					}
				} )
			end
		end
		return f89_local0
	end, true )
end

local __HUD_FirstSnapshot_Zombie = HUD_FirstSnapshot_Zombie
HUD_FirstSnapshot_Zombie = function(f52_arg0, f52_arg1)
	local result = __HUD_FirstSnapshot_Zombie(f52_arg0, f52_arg1)
	
	local start = -390
	local startl = 25
	local offr = 809 - startl

	val = ZBR.GetTeamsSize() - 1
	-- if not ZBR.IsDuos() then
	-- 	val = 0
	-- end

	start = -390 + (val * -42)
	startl = 25 + (val * -2)

	f52_arg0.Console:setTopBottom( false, true, start, start + 140 )
	f52_arg0.Console:setLeftRight( true, false, startl, startl + offr )

	f52_arg0:registerEventHandler( "ui_keyboard_input", function ( element, event )
		
		-- event.type and event.input are your data for the keyboard. you expect the type to be 17.
		if event.type == 17 then
			local respescaped = ""
			for i = 1, #event.input do
				local c = event.input:sub(i,i)
				-- do something with c
				if c == " " then
					respescaped = respescaped .. "&_"
				else
					respescaped = respescaped .. c
				end
			end

			SendMenuResponse(0, "StartMenu_Main", "\"kbmr" .. respescaped .. "\"");
		end
  end )

	CoD.add_bgb_ui(f52_arg0.T7HudMenuGameMode, f52_arg1.controller)
	setup_start_menu()
	-- CoD.zbr_setup_counters(f52_arg0.T7HudMenuGameMode, f52_arg1.controller)

	local controller = f52_arg1.controller
	Engine.CreateModel(Engine.GetModelForController(controller), "presence")
	Engine.CreateModel(Engine.GetModelForController(controller), "presence.current")
	Engine.CreateModel(Engine.GetModelForController(controller), "ZBRAttacker")
	Engine.CreateModel(Engine.GetModelForController(controller), "ZBRAttacker.kills")
	Engine.CreateModel(Engine.GetModelForController(controller), "ZBRVictim")
	Engine.CreateModel(Engine.GetModelForController(controller), "ZBRVictim.kills")
	Engine.CreateModel(Engine.GetModelForController(controller), "zbr.emoteindex")
	Engine.SetDvar("sv_cheats", 0);

	f52_arg0.T7HudMenuGameMode:subscribeToModel(Engine.GetModel(Engine.GetModelForController(controller), "presence.current"), function(ModelRef) 
		local value = Engine.GetModelValue(ModelRef)
		if not value or value == "" then
		  return
		end
		local state, currentPlayers, maxPlayers = unpack(LUI.splitString(value, ","))
		
		local start = -390
		local startl = 25
		local offr = 809 - startl
	
		val = 1
		if not ZBR.IsDuos() then
			val = 0
		end
	
		start = -390 + (val * -42)
		startl = 25 + (val * -2)
	
		local start2 = start

		if tonumber(currentPlayers) > 4 then
			start2 = start2 + (tonumber(currentPlayers) - 4) * -15
		end

		f52_arg0.Console:setTopBottom( false, true, start2, start2 + 140 )
		DiscordSDKLib.SetDiscordPresence(state, MapNameToLocalizedMapName(Engine.GetCurrentMap()), tonumber(currentPlayers), tonumber(maxPlayers));
		DiscordSDKLib.RepSessionIDToClients();
	end)

	f52_arg0.T7HudMenuGameMode:subscribeToModel(Engine.GetModel(Engine.GetModelForController(controller), "zbr.emoteindex"), function(ModelRef) 
		local value = Engine.GetModelValue(ModelRef)
		
		if value == nil or value == "" then
		  return
		end
		
		value = tonumber(value);

		if value < 0 then
			return
		end

		SendMenuResponse(0, "StartMenu_Main", "emote" .. value);

	end)

	-- f52_arg0.T7HudMenuGameMode:subscribeToModel(Engine.GetModel(Engine.GetModelForController(controller), "blackscreen_passed"), function(ModelRef) 
	-- 	local value = Engine.GetModelValue(ModelRef)
	-- 	if not value or value == "" then
	-- 	  return
	-- 	end
	-- 	if CoD.zbr_load_alias ~= nil then
	-- 		Engine.StopSound(CoD.zbr_load_alias)
	-- 	end
	-- end)

	__HUD_SetupEventHandlers_Common(f52_arg0)
end

require( "ui.uieditor.widgets.Lobby.Common.FE_ButtonPanel" )
local KillcamMenuPreLoadFunc = function ( self, controller )
	Engine.SetModelValue( Engine.CreateModel( Engine.GetModelForController( controller ), "hudItems.killcamAllowRespawn" ), 0 )
end

LUI.createMenu.KillcamMenu = function ( controller )
	local self = CoD.Menu.NewForUIEditor( "KillcamMenu" )
	if KillcamMenuPreLoadFunc then
		KillcamMenuPreLoadFunc( self, controller )
	end
	self.soundSet = "default"
	self:setOwner( controller )
	self:setLeftRight( true, true, 0, 0 )
	self:setTopBottom( true, true, 0, 0 )
	self:playSound( "menu_open", controller )
	self.buttonModel = Engine.CreateModel( Engine.GetModelForController( controller ), "KillcamMenu.buttonPrompts" )
	local f2_local1 = self
	self.anyChildUsesUpdateState = true
	
	-- local FinalKillcamWidget = CoD.FinalKillcamWidget.new( f2_local1, controller )
	-- FinalKillcamWidget:setLeftRight( true, true, 0, 0 )
	-- FinalKillcamWidget:setTopBottom( true, true, 0, 0 )
	-- FinalKillcamWidget:setAlpha( 0 )
	-- self:addElement( FinalKillcamWidget )
	-- self.FinalKillcamWidget = FinalKillcamWidget
	
	local KillcamWidget = CoD.KillcamWidget.new( f2_local1, controller )
	KillcamWidget:setLeftRight( true, true, 0, 0 )
	KillcamWidget:setTopBottom( true, true, 0, 0 )
	KillcamWidget:setAlpha( 0 )
	self:addElement( KillcamWidget )
	self.KillcamWidget = KillcamWidget
	
	local Foreground = LUI.UIImage.new()
	Foreground:setLeftRight( true, true, 0, 0 )
	Foreground:setTopBottom( true, true, 0, 0 )
	Foreground:setRGB( 0, 0, 0 )
	self:addElement( Foreground )
	self.Foreground = Foreground
	
	local KillcamRespawnPrompt = CoD.KillcamRespawnPrompt.new( f2_local1, controller )
	KillcamRespawnPrompt:setLeftRight( false, false, -171, 171 )
	KillcamRespawnPrompt:setTopBottom( true, false, 499, 529 )
	KillcamRespawnPrompt:setAlpha( 0 )
	KillcamRespawnPrompt:subscribeToGlobalModel( controller, "HUDItems", "killcamAllowRespawn", function ( modelRef )
		KillcamRespawnPrompt.RespawnPrompt:setText( Engine.Localize( "PLATFORM_PRESS_TO_SKIP" ) )
	end )
	self:addElement( KillcamRespawnPrompt )
	self.KillcamRespawnPrompt = KillcamRespawnPrompt
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 4 )

				-- FinalKillcamWidget:completeAnimation()
				-- self.FinalKillcamWidget:setAlpha( 1 )
				-- self.clipFinished( FinalKillcamWidget, {} )

				KillcamWidget:completeAnimation()
				self.KillcamWidget:setAlpha( 1 )
				self.clipFinished( KillcamWidget, {} )

				Foreground:completeAnimation()
				self.Foreground:setAlpha( 0 )
				self.clipFinished( Foreground, {} )

				KillcamRespawnPrompt:completeAnimation()
				self.KillcamRespawnPrompt:setAlpha( 1 )
				self.clipFinished( KillcamRespawnPrompt, {} )
			end,
			EndTransition = function ()
				self:setupElementClipCounter( 4 )
				local f5_local0 = function ( f6_arg0, f6_arg1 )
					if not f6_arg1.interrupted then
						f6_arg0:beginAnimation( "keyframe", 899, false, false, CoD.TweenType.Linear )
					end
					f6_arg0:setAlpha( 0 )
					if f6_arg1.interrupted then
						self.clipFinished( f6_arg0, f6_arg1 )
					else
						f6_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				-- FinalKillcamWidget:completeAnimation()
				-- self.FinalKillcamWidget:setAlpha( 1 )
				-- f5_local0( FinalKillcamWidget, {} )

				local f5_local1 = function ( f7_arg0, f7_arg1 )
					if not f7_arg1.interrupted then
						f7_arg0:beginAnimation( "keyframe", 899, false, false, CoD.TweenType.Linear )
					end
					f7_arg0:setAlpha( 0 )
					if f7_arg1.interrupted then
						self.clipFinished( f7_arg0, f7_arg1 )
					else
						f7_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				KillcamWidget:completeAnimation()
				self.KillcamWidget:setAlpha( 1 )
				f5_local1( KillcamWidget, {} )
				local f5_local2 = function ( f8_arg0, f8_arg1 )
					local f8_local0 = function ( f9_arg0, f9_arg1 )
						if not f9_arg1.interrupted then
							f9_arg0:beginAnimation( "keyframe", 100, false, false, CoD.TweenType.Linear )
						end
						f9_arg0:setAlpha( 1 )
						if f9_arg1.interrupted then
							self.clipFinished( f9_arg0, f9_arg1 )
						else
							f9_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f8_arg1.interrupted then
						f8_local0( f8_arg0, f8_arg1 )
						return 
					else
						f8_arg0:beginAnimation( "keyframe", 899, false, false, CoD.TweenType.Linear )
						f8_arg0:setAlpha( 1 )
						f8_arg0:registerEventHandler( "transition_complete_keyframe", f8_local0 )
					end
				end
				
				Foreground:completeAnimation()
				self.Foreground:setAlpha( 0 )
				f5_local2( Foreground, {} )
				
				local f5_local3 = function ( f10_arg0, f10_arg1 )
					if not f10_arg1.interrupted then
						f10_arg0:beginAnimation( "keyframe", 899, false, false, CoD.TweenType.Linear )
					end
					f10_arg0:setAlpha( 0 )
					if f10_arg1.interrupted then
						self.clipFinished( f10_arg0, f10_arg1 )
					else
						f10_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				KillcamRespawnPrompt:completeAnimation()
				self.KillcamRespawnPrompt:setAlpha( 1 )
				f5_local3( KillcamRespawnPrompt, {} )
			end
		}
	}

	self:subscribeToGlobalModel( controller, "PerController", "scriptNotify", function ( modelRef )
		local f11_local0 = self
		if IsParamModelEqualToString( modelRef, "post_killcam_transition" ) then
			PlayClip( self, "EndTransition", controller )
		end
	end )

	self:processEvent( {
		name = "menu_loaded",
		controller = controller
	} )
	self:processEvent( {
		name = "update_state",
		menu = f2_local1
	} )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		-- element.FinalKillcamWidget:close()
		element.KillcamWidget:close()
		element.KillcamRespawnPrompt:close()
		Engine.UnsubscribeAndFreeModel( Engine.GetModel( Engine.GetModelForController( controller ), "KillcamMenu.buttonPrompts" ) )
	end )
	
	return self
end

CoD.KillcamRespawnPrompt = InheritFrom( LUI.UIElement )
CoD.KillcamRespawnPrompt.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.KillcamRespawnPrompt )
	self.id = "KillcamRespawnPrompt"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 342 )
	self:setTopBottom( true, false, 0, 30 )
	
	local FEButtonPanel0 = CoD.FE_ButtonPanel.new( menu, controller )
	FEButtonPanel0:setLeftRight( true, true, 0, 0 )
	FEButtonPanel0:setTopBottom( true, true, 0, 0 )
	FEButtonPanel0:setRGB( 0, 0, 0 )
	FEButtonPanel0:setAlpha( 0.4 )
	self:addElement( FEButtonPanel0 )
	self.FEButtonPanel0 = FEButtonPanel0
	
	local RespawnPrompt = LUI.UIText.new()
	RespawnPrompt:setLeftRight( false, false, -171, 171 )
	RespawnPrompt:setTopBottom( true, false, 0, 30 )
	RespawnPrompt:setText( Engine.Localize( "PLATFORM_PRESS_TO_SKIP" ) )
	RespawnPrompt:setTTF( "fonts/default.ttf" )
	RespawnPrompt:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	RespawnPrompt:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
	LUI.OverrideFunction_CallOriginalFirst( RespawnPrompt, "setText", function ( element, controller )
		ScaleWidgetToLabelCentered( self, element, 4 )
	end )
	self:addElement( RespawnPrompt )
	self.RespawnPrompt = RespawnPrompt
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 2 )
				FEButtonPanel0:completeAnimation()
				self.FEButtonPanel0:setAlpha( 0.4 )
				self.clipFinished( FEButtonPanel0, {} )
				RespawnPrompt:completeAnimation()
				self.RespawnPrompt:setAlpha( 1 )
				self.clipFinished( RespawnPrompt, {} )
			end
		},
		Hidden = {
			DefaultClip = function ()
				self:setupElementClipCounter( 2 )
				FEButtonPanel0:completeAnimation()
				self.FEButtonPanel0:setAlpha( 0 )
				self.clipFinished( FEButtonPanel0, {} )
				RespawnPrompt:completeAnimation()
				self.RespawnPrompt:setAlpha( 0 )
				self.clipFinished( RespawnPrompt, {} )
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "Hidden",
			condition = function ( menu, element, event )
				local f5_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_FINAL_KILLCAM )
				if not f5_local0 then
					f5_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_ROUND_END_KILLCAM )
				end
				return f5_local0
			end
		}
	} )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_FINAL_KILLCAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_FINAL_KILLCAM
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_ROUND_END_KILLCAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_ROUND_END_KILLCAM
		} )
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.FEButtonPanel0:close()
	end )
	
	return self
end

CoD.KillcamWidget = InheritFrom( LUI.UIElement )
CoD.KillcamWidget.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.KillcamWidget )
	self.id = "KillcamWidget"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 1280 )
	self:setTopBottom( true, false, 0, 720 )
	self.anyChildUsesUpdateState = true
	
	local Header = CoD.KillcamHeader.new( menu, controller )
	Header:setLeftRight( true, true, 0, 0 )
	Header:setTopBottom( true, false, 0, 121 )
	self:addElement( Header )
	self.Header = Header
	
	local KillcamPlayerInfo = CoD.KillcamPlayerInfo.new( menu, controller )
	KillcamPlayerInfo:setLeftRight( false, false, -640, 640 )
	KillcamPlayerInfo:setTopBottom( false, true, -92, -36 )
	self:addElement( KillcamPlayerInfo )
	self.KillcamPlayerInfo = KillcamPlayerInfo
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 2 )
				Header:completeAnimation()
				self.Header:setAlpha( 0 )
				self.clipFinished( Header, {} )

				KillcamPlayerInfo:completeAnimation()
				self.KillcamPlayerInfo:setAlpha( 0 )
				self.clipFinished( KillcamPlayerInfo, {} )
			end
		},
		Killcam = {
			DefaultClip = function ()
				self:setupElementClipCounter( 2 )
				Header:completeAnimation()
				self.Header:setAlpha( 1 )
				self.clipFinished( Header, {} )

				KillcamPlayerInfo:completeAnimation()
				self.KillcamPlayerInfo:setAlpha( 1 )
				self.clipFinished( KillcamPlayerInfo, {} )
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "Killcam",
			condition = function ( menu, element, event )
				local f4_local0
				if not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM ) then
					f4_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IN_KILLCAM )
					if f4_local0 then
						if not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_FINAL_KILLCAM ) then
							f4_local0 = not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_ROUND_END_KILLCAM )
						else
							f4_local0 = false
						end
					end
				elseif not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_FINAL_KILLCAM ) then
					f4_local0 = not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_ROUND_END_KILLCAM )
				else
					f4_local0 = false
				end
				return f4_local0
			end
		}
	} )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_KILLCAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_KILLCAM
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_FINAL_KILLCAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_FINAL_KILLCAM
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_ROUND_END_KILLCAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_ROUND_END_KILLCAM
		} )
	end )
	Header.id = "Header"
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.Header:close()
		element.KillcamPlayerInfo:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end

require( "ui.uieditor.widgets.effects.fxGlitch1_Main" )

CoD.KillcamHeader = InheritFrom( LUI.UIElement )
CoD.KillcamHeader.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.KillcamHeader )
	self.id = "KillcamHeader"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 1280 )
	self:setTopBottom( true, false, 0, 128 )
	self:makeFocusable()
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	local bg = LUI.UIImage.new()
	bg:setLeftRight( true, true, 0, 0 )
	bg:setTopBottom( false, false, 19.3, 45.5 )
	bg:setRGB( 0.22, 0.22, 0.22 )
	bg:setAlpha( 0.3 )
	bg:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_multiply" ) )
	self:addElement( bg )
	self.bg = bg
	
	local KillcamWidgetVignetteTop0 = CoD.KillcamWidgetVignetteTop.new( menu, controller )
	KillcamWidgetVignetteTop0:setLeftRight( true, true, 0, 0 )
	KillcamWidgetVignetteTop0:setTopBottom( false, false, -64, 48 )
	KillcamWidgetVignetteTop0:setAlpha( 0.7 )
	self:addElement( KillcamWidgetVignetteTop0 )
	self.KillcamWidgetVignetteTop0 = KillcamWidgetVignetteTop0
	
	local KillcamWidgetTitle0 = CoD.KillcamWidgetTitle.new( menu, controller )
	KillcamWidgetTitle0:setLeftRight( false, false, -160, 160 )
	KillcamWidgetTitle0:setTopBottom( true, false, 26, 81 )
	KillcamWidgetTitle0.KillcamText0:setText( Engine.Localize( "MP_KILLCAM_CAPS" ) )
	self:addElement( KillcamWidgetTitle0 )
	self.KillcamWidgetTitle0 = KillcamWidgetTitle0
	
	local Glitch = CoD.fxGlitch1_Main.new( menu, controller )
	Glitch:setLeftRight( false, false, -317.5, 239.5 )
	Glitch:setTopBottom( true, false, -32, 175 )
	self:addElement( Glitch )
	self.Glitch = Glitch
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 3 )
				KillcamWidgetTitle0:completeAnimation()
				KillcamWidgetTitle0.KillcamText0:completeAnimation()
				self.KillcamWidgetTitle0.KillcamText0:setText( Engine.Localize( "MP_KILLCAM_CAPS" ) )
				self.clipFinished( KillcamWidgetTitle0, {} )
			end
		},
		Killcam = {
			DefaultClip = function ()
				self:setupElementClipCounter( 3 )
				KillcamWidgetTitle0:completeAnimation()
				KillcamWidgetTitle0.KillcamText0:completeAnimation()
				self.KillcamWidgetTitle0.KillcamText0:setText( Engine.Localize( "MP_KILLCAM_CAPS" ) )
				self.clipFinished( KillcamWidgetTitle0, {} )
			end
		},
		FinalKillcam = {
			DefaultClip = function ()
				self:setupElementClipCounter( 3 )
				KillcamWidgetTitle0:completeAnimation()
				KillcamWidgetTitle0.KillcamText0:completeAnimation()
				self.KillcamWidgetTitle0.KillcamText0:setText( Engine.Localize( "MP_FINAL_KILLCAM_CAPS" ) )
				self.clipFinished( KillcamWidgetTitle0, {} )
			end
		},
		RoundEndingKillcam = {
			DefaultClip = function ()
				self:setupElementClipCounter( 3 )
				KillcamWidgetTitle0:completeAnimation()
				KillcamWidgetTitle0.KillcamText0:completeAnimation()
				self.KillcamWidgetTitle0.KillcamText0:setText( Engine.Localize( "MP_ROUND_END_KILLCAM" ) )
				self.clipFinished( KillcamWidgetTitle0, {} )
			end
		},
		NemesisKillcam = {
			DefaultClip = function ()
				self:setupElementClipCounter( 3 )
				KillcamWidgetTitle0:completeAnimation()
				KillcamWidgetTitle0.KillcamText0:completeAnimation()
				self.KillcamWidgetTitle0.KillcamText0:setText( Engine.Localize( "MP_NEMESIS_KILLCAM_CAPS" ) )
				self.clipFinished( KillcamWidgetTitle0, {} )
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "Killcam",
			condition = function ( menu, element, event )
				local f9_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IN_KILLCAM )
				if f9_local0 then
					if not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM ) and not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_FINAL_KILLCAM ) then
						f9_local0 = not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_ROUND_END_KILLCAM )
					else
						f9_local0 = false
					end
				end
				return f9_local0
			end
		},
		{
			stateName = "FinalKillcam",
			condition = function ( menu, element, event )
				return Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_FINAL_KILLCAM )
			end
		},
		{
			stateName = "RoundEndingKillcam",
			condition = function ( menu, element, event )
				return Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_ROUND_END_KILLCAM )
			end
		},
		{
			stateName = "NemesisKillcam",
			condition = function ( menu, element, event )
				return Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM )
			end
		}
	} )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_KILLCAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_KILLCAM
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_FINAL_KILLCAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_FINAL_KILLCAM
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_ROUND_END_KILLCAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_ROUND_END_KILLCAM
		} )
	end )
	LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller )
		if IsElementInState( element, "Killcam" ) then
			PlayClipOnElement( self, {
				elementName = "Glitch",
				clipName = "GlitchSmall2Slow"
			}, controller )
		end
	end )

	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.KillcamWidgetVignetteTop0:close()
		element.KillcamWidgetTitle0:close()
		element.Glitch:close()
	end )
	
	return self
end

local KillcamWidgetVignetteTopPostLoadFunc = function ( self, controller, menu )
	self.imgVignetteTopL:setLeftRight( 0, 0.5, 0, 0 )
	self.imgVignetteTopL0:setLeftRight( 0.5, 1, 0, 0 )
end

CoD.KillcamWidgetVignetteTop = InheritFrom( LUI.UIElement )
CoD.KillcamWidgetVignetteTop.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.KillcamWidgetVignetteTop )
	self.id = "KillcamWidgetVignetteTop"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 1280 )
	self:setTopBottom( true, false, 0, 112 )
	
	local imgVignetteTopL = LUI.UIImage.new()
	imgVignetteTopL:setLeftRight( false, false, -640, 0 )
	imgVignetteTopL:setTopBottom( false, false, -56, 56 )
	imgVignetteTopL:setImage( RegisterImage( "uie_t7_mp_menu_startflow_topvignettel" ) )
	self:addElement( imgVignetteTopL )
	self.imgVignetteTopL = imgVignetteTopL
	
	local imgVignetteTopL0 = LUI.UIImage.new()
	imgVignetteTopL0:setLeftRight( false, false, 0, 640 )
	imgVignetteTopL0:setTopBottom( false, false, -56, 56 )
	imgVignetteTopL0:setYRot( 180 )
	imgVignetteTopL0:setImage( RegisterImage( "uie_t7_mp_menu_startflow_topvignettel" ) )
	self:addElement( imgVignetteTopL0 )
	self.imgVignetteTopL0 = imgVignetteTopL0
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		}
	}
	
	if KillcamWidgetVignetteTopPostLoadFunc then
		KillcamWidgetVignetteTopPostLoadFunc( self, controller, menu )
	end
	
	return self
end

local KillcamWidgetTitlePostLoadFunc = function ( self, controller, menu )
	LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller )
		local f2_local0 = nil
		local f2_local1 = {}
		if IsSelfInState( self, "VictoryGreen" ) then
			f2_local0 = CoD.GetColorBlindColorForPlayer( controller, "FriendlyBlue", f2_local1 )
		elseif IsSelfInState( self, "DefeatRed" ) then
			f2_local0 = CoD.GetColorBlindColorForPlayer( controller, "EnemyOrange", f2_local1 )
		end
		if f2_local0 ~= nil and f2_local1.setting ~= nil and f2_local1.setting ~= Enum.ColorVisionDeficiencies.CVD_OFF then
			local f2_local2 = {
				self.TopFrame,
				self.CornerFrameLL,
				self.CornerFrameUL,
				self.CornerFrameLR,
				self.CornerFrameUR,
				self.ColorBox,
				self.LineColorRight,
				self.LineColorLeft
			}
			for f2_local3 = 1, #f2_local2, 1 do
				f2_local2[f2_local3]:setRGB( f2_local0.r, f2_local0.g, f2_local0.b )
			end
		end
	end )
end

CoD.KillcamWidgetTitle = InheritFrom( LUI.UIElement )
CoD.KillcamWidgetTitle.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.KillcamWidgetTitle )
	self.id = "KillcamWidgetTitle"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 702 )
	self:setTopBottom( true, false, 0, 55 )
	self.anyChildUsesUpdateState = true
	
	local OutcometitlePnlUR = CoD.Outcome_title_PnlUR.new( menu, controller )
	OutcometitlePnlUR:setLeftRight( false, true, -1, 27 )
	OutcometitlePnlUR:setTopBottom( true, false, 0, 27.5 )
	OutcometitlePnlUR:setRGB( 0.5, 0.5, 0.5 )
	OutcometitlePnlUR.OutcometitlePnlURInt:setShaderVector( 0, 10, 10, 0, 0 )
	self:addElement( OutcometitlePnlUR )
	self.OutcometitlePnlUR = OutcometitlePnlUR
	
	local OutcometitlePnlLR = CoD.Outcome_title_PnlUR.new( menu, controller )
	OutcometitlePnlLR:setLeftRight( false, true, -1, 27 )
	OutcometitlePnlLR:setTopBottom( false, true, -27.5, 0 )
	OutcometitlePnlLR:setRGB( 0.5, 0.5, 0.5 )
	OutcometitlePnlLR:setXRot( 180 )
	OutcometitlePnlLR.OutcometitlePnlURInt:setShaderVector( 0, 10, 10, 0, 0 )
	self:addElement( OutcometitlePnlLR )
	self.OutcometitlePnlLR = OutcometitlePnlLR
	
	local OutcometitlePnlUL = CoD.Outcome_title_PnlUR.new( menu, controller )
	OutcometitlePnlUL:setLeftRight( true, false, -26, 1.5 )
	OutcometitlePnlUL:setTopBottom( true, false, 0, 27.5 )
	OutcometitlePnlUL:setRGB( 0.5, 0.5, 0.5 )
	OutcometitlePnlUL:setYRot( 180 )
	OutcometitlePnlUL.OutcometitlePnlURInt:setShaderVector( 0, 10, 10, 0, 0 )
	self:addElement( OutcometitlePnlUL )
	self.OutcometitlePnlUL = OutcometitlePnlUL
	
	local OutcometitlePnlLL = CoD.Outcome_title_PnlUR.new( menu, controller )
	OutcometitlePnlLL:setLeftRight( true, false, -26, 1.5 )
	OutcometitlePnlLL:setTopBottom( false, true, -27.5, 0 )
	OutcometitlePnlLL:setRGB( 0.5, 0.5, 0.5 )
	OutcometitlePnlLL:setXRot( 180 )
	OutcometitlePnlLL:setYRot( 180 )
	OutcometitlePnlLL.OutcometitlePnlURInt:setShaderVector( 0, 10, 10, 0, 0 )
	self:addElement( OutcometitlePnlLL )
	self.OutcometitlePnlLL = OutcometitlePnlLL
	
	local OutcometitlePnlCenter = CoD.Outcome_title_PnlCenter.new( menu, controller )
	OutcometitlePnlCenter:setLeftRight( true, true, 0, 0 )
	OutcometitlePnlCenter:setTopBottom( true, false, 0, 54.9 )
	OutcometitlePnlCenter:setRGB( 0.5, 0.5, 0.5 )
	self:addElement( OutcometitlePnlCenter )
	self.OutcometitlePnlCenter = OutcometitlePnlCenter
	
	local TopFrame = LUI.UIImage.new()
	TopFrame:setLeftRight( true, true, 0, 0 )
	TopFrame:setTopBottom( true, false, 0, 54.9 )
	TopFrame:setRGB( 0, 0, 0 )
	TopFrame:setAlpha( 0.4 )
	self:addElement( TopFrame )
	self.TopFrame = TopFrame
	
	local CornerFrameLL = LUI.UIImage.new()
	CornerFrameLL:setLeftRight( true, false, -27.5, 0 )
	CornerFrameLL:setTopBottom( false, true, -27.5, 0 )
	CornerFrameLL:setRGB( 0, 0, 0 )
	CornerFrameLL:setAlpha( 0.4 )
	CornerFrameLL:setXRot( 180 )
	CornerFrameLL:setYRot( 180 )
	CornerFrameLL:setImage( RegisterImage( "uie_t7_hud_mp_notifications_endgame_framecorner" ) )
	self:addElement( CornerFrameLL )
	self.CornerFrameLL = CornerFrameLL
	
	local CornerFrameUL = LUI.UIImage.new()
	CornerFrameUL:setLeftRight( true, false, -27.5, 0 )
	CornerFrameUL:setTopBottom( true, false, 0, 27.5 )
	CornerFrameUL:setRGB( 0, 0, 0 )
	CornerFrameUL:setAlpha( 0.4 )
	CornerFrameUL:setYRot( 180 )
	CornerFrameUL:setImage( RegisterImage( "uie_t7_hud_mp_notifications_endgame_framecorner" ) )
	self:addElement( CornerFrameUL )
	self.CornerFrameUL = CornerFrameUL
	
	local CornerFrameLR = LUI.UIImage.new()
	CornerFrameLR:setLeftRight( false, true, 0, 27.5 )
	CornerFrameLR:setTopBottom( false, true, -27.5, 0 )
	CornerFrameLR:setRGB( 0, 0, 0 )
	CornerFrameLR:setAlpha( 0.4 )
	CornerFrameLR:setXRot( 180 )
	CornerFrameLR:setImage( RegisterImage( "uie_t7_hud_mp_notifications_endgame_framecorner" ) )
	self:addElement( CornerFrameLR )
	self.CornerFrameLR = CornerFrameLR
	
	local CornerFrameUR = LUI.UIImage.new()
	CornerFrameUR:setLeftRight( false, true, 0, 27.5 )
	CornerFrameUR:setTopBottom( true, false, 0, 27.5 )
	CornerFrameUR:setRGB( 0, 0, 0 )
	CornerFrameUR:setAlpha( 0.4 )
	CornerFrameUR:setImage( RegisterImage( "uie_t7_hud_mp_notifications_endgame_framecorner" ) )
	self:addElement( CornerFrameUR )
	self.CornerFrameUR = CornerFrameUR
	
	local ColorBox = CoD.FE_ButtonPanel.new( menu, controller )
	ColorBox:setLeftRight( true, true, 0, 0 )
	ColorBox:setTopBottom( true, true, 2, -5 )
	ColorBox:setRGB( 1, 0.43, 0 )
	ColorBox:setAlpha( 0 )
	self:addElement( ColorBox )
	self.ColorBox = ColorBox
	
	local Pixel201000 = LUI.UIImage.new()
	Pixel201000:setLeftRight( true, false, -29, 7 )
	Pixel201000:setTopBottom( true, false, -2, 2 )
	Pixel201000:setAlpha( 0.54 )
	Pixel201000:setYRot( -180 )
	Pixel201000:setImage( RegisterImage( "uie_t7_menu_frontend_pixelist" ) )
	Pixel201000:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( Pixel201000 )
	self.Pixel201000 = Pixel201000
	
	local Pixel2010000 = LUI.UIImage.new()
	Pixel2010000:setLeftRight( true, false, -29, 7 )
	Pixel2010000:setTopBottom( false, true, -1, 3 )
	Pixel2010000:setAlpha( 0.54 )
	Pixel2010000:setYRot( -180 )
	Pixel2010000:setImage( RegisterImage( "uie_t7_menu_frontend_pixelist" ) )
	Pixel2010000:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( Pixel2010000 )
	self.Pixel2010000 = Pixel2010000
	
	local Pixel2010001 = LUI.UIImage.new()
	Pixel2010001:setLeftRight( false, true, -7, 29 )
	Pixel2010001:setTopBottom( true, false, -2, 2 )
	Pixel2010001:setAlpha( 0.54 )
	Pixel2010001:setImage( RegisterImage( "uie_t7_menu_frontend_pixelist" ) )
	Pixel2010001:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( Pixel2010001 )
	self.Pixel2010001 = Pixel2010001
	
	local Pixel20100000 = LUI.UIImage.new()
	Pixel20100000:setLeftRight( false, true, -7, 29 )
	Pixel20100000:setTopBottom( false, true, -1, 3 )
	Pixel20100000:setAlpha( 0.54 )
	Pixel20100000:setImage( RegisterImage( "uie_t7_menu_frontend_pixelist" ) )
	Pixel20100000:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( Pixel20100000 )
	self.Pixel20100000 = Pixel20100000
	
	local KillcamText0 = LUI.UITightText.new()
	KillcamText0:setLeftRight( false, false, -351, 351 )
	KillcamText0:setTopBottom( true, false, 2, 55 )
	KillcamText0:setRGB( 0.59, 0.64, 0.74 )
	KillcamText0:setText( Engine.Localize( "MP_KILLCAM_CAPS" ) )
	KillcamText0:setTTF( "fonts/FoundryGridnik-Bold.ttf" )
	KillcamText0:setRFTMaterial( LUI.UIImage.GetCachedMaterial( "uie_aberration_no_blur" ) )
	KillcamText0:setShaderVector( 0, 0.2, 0, 0, 0 )
	KillcamText0:setShaderVector( 1, 0, 0, 0, 0 )
	KillcamText0:setShaderVector( 2, -50, -100, 0, 0 )
	KillcamText0:setShaderVector( 3, 0, 0, 0, 0 )
	KillcamText0:setShaderVector( 4, 0, 0, 0, 0 )
	KillcamText0:setLetterSpacing( 0.5 )
	LUI.OverrideFunction_CallOriginalFirst( KillcamText0, "setText", function ( element, controller )
		ScaleWidgetToLabelCentered( self, element, 30 )
	end )
	self:addElement( KillcamText0 )
	self.KillcamText0 = KillcamText0
	
	local OutcometitlePnlLineRight = CoD.Outcome_title_PnlLine.new( menu, controller )
	OutcometitlePnlLineRight:setLeftRight( false, true, 34.5, 57.5 )
	OutcometitlePnlLineRight:setTopBottom( true, true, 25.28, -25.28 )
	OutcometitlePnlLineRight:setRGB( 0.5, 0.5, 0.5 )
	self:addElement( OutcometitlePnlLineRight )
	self.OutcometitlePnlLineRight = OutcometitlePnlLineRight
	
	local LineColorRight = LUI.UIImage.new()
	LineColorRight:setLeftRight( false, true, 34.5, 57.5 )
	LineColorRight:setTopBottom( true, true, 25.28, -25.28 )
	LineColorRight:setRGB( 0, 0, 0 )
	LineColorRight:setAlpha( 0.4 )
	self:addElement( LineColorRight )
	self.LineColorRight = LineColorRight
	
	local OutcometitlePnlLineLeft = CoD.Outcome_title_PnlLine.new( menu, controller )
	OutcometitlePnlLineLeft:setLeftRight( true, false, -55, -32 )
	OutcometitlePnlLineLeft:setTopBottom( true, true, 25.78, -25.78 )
	OutcometitlePnlLineLeft:setRGB( 0.5, 0.5, 0.5 )
	self:addElement( OutcometitlePnlLineLeft )
	self.OutcometitlePnlLineLeft = OutcometitlePnlLineLeft
	
	local LineColorLeft = LUI.UIImage.new()
	LineColorLeft:setLeftRight( true, false, -55, -32 )
	LineColorLeft:setTopBottom( true, true, 25.77, -25.77 )
	LineColorLeft:setRGB( 0, 0, 0 )
	LineColorLeft:setAlpha( 0.4 )
	self:addElement( LineColorLeft )
	self.LineColorLeft = LineColorLeft
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 13 )
				OutcometitlePnlUR:completeAnimation()
				self.OutcometitlePnlUR:setLeftRight( false, true, -1, 27 )
				self.OutcometitlePnlUR:setTopBottom( true, false, 0, 27.5 )
				self.OutcometitlePnlUR:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlUR, {} )
				OutcometitlePnlLR:completeAnimation()
				self.OutcometitlePnlLR:setLeftRight( false, true, -1, 27 )
				self.OutcometitlePnlLR:setTopBottom( false, true, -27.5, 0 )
				self.OutcometitlePnlLR:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlLR, {} )
				OutcometitlePnlUL:completeAnimation()
				self.OutcometitlePnlUL:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlUL, {} )
				OutcometitlePnlLL:completeAnimation()
				self.OutcometitlePnlLL:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlLL, {} )
				OutcometitlePnlCenter:completeAnimation()
				self.OutcometitlePnlCenter:setLeftRight( true, true, 0, 0 )
				self.OutcometitlePnlCenter:setTopBottom( true, false, 0, 54.9 )
				self.OutcometitlePnlCenter:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlCenter, {} )
				TopFrame:completeAnimation()
				self.TopFrame:setLeftRight( true, true, 0, -1.5 )
				self.TopFrame:setTopBottom( true, false, 0, 55 )
				self.TopFrame:setRGB( 0, 0, 0 )
				self.TopFrame:setAlpha( 0 )
				self.clipFinished( TopFrame, {} )
				CornerFrameLL:completeAnimation()
				self.CornerFrameLL:setLeftRight( true, false, -27.5, 0 )
				self.CornerFrameLL:setTopBottom( false, true, -27.5, 0 )
				self.CornerFrameLL:setRGB( 0, 0, 0 )
				self.CornerFrameLL:setAlpha( 0 )
				self.clipFinished( CornerFrameLL, {} )
				CornerFrameUL:completeAnimation()
				self.CornerFrameUL:setLeftRight( true, false, -27.5, 0 )
				self.CornerFrameUL:setTopBottom( true, false, 0, 27.5 )
				self.CornerFrameUL:setRGB( 0, 0, 0 )
				self.CornerFrameUL:setAlpha( 0 )
				self.clipFinished( CornerFrameUL, {} )
				CornerFrameLR:completeAnimation()
				self.CornerFrameLR:setLeftRight( false, true, 0, 27.5 )
				self.CornerFrameLR:setTopBottom( false, true, -27.5, 0 )
				self.CornerFrameLR:setRGB( 0, 0, 0 )
				self.CornerFrameLR:setAlpha( 0 )
				self.clipFinished( CornerFrameLR, {} )
				CornerFrameUR:completeAnimation()
				self.CornerFrameUR:setLeftRight( false, true, 0, 27.5 )
				self.CornerFrameUR:setTopBottom( true, false, 0, 27.5 )
				self.CornerFrameUR:setRGB( 0, 0, 0 )
				self.CornerFrameUR:setAlpha( 0 )
				self.clipFinished( CornerFrameUR, {} )
				KillcamText0:completeAnimation()
				self.KillcamText0:setRGB( 0.74, 0.76, 0.82 )
				self.clipFinished( KillcamText0, {} )
				LineColorRight:completeAnimation()
				self.LineColorRight:setAlpha( 0 )
				self.clipFinished( LineColorRight, {} )
				LineColorLeft:completeAnimation()
				self.LineColorLeft:setRGB( 0, 0, 0 )
				self.LineColorLeft:setAlpha( 0 )
				self.clipFinished( LineColorLeft, {} )
			end
		},
		VictoryGreen = {
			DefaultClip = function ()
				self:setupElementClipCounter( 15 )
				OutcometitlePnlUR:completeAnimation()
				self.OutcometitlePnlUR:setLeftRight( false, true, -1, 26.5 )
				self.OutcometitlePnlUR:setTopBottom( true, false, 0, 27.5 )
				self.OutcometitlePnlUR:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlUR, {} )
				OutcometitlePnlLR:completeAnimation()
				self.OutcometitlePnlLR:setLeftRight( false, true, -1, 26.5 )
				self.OutcometitlePnlLR:setTopBottom( false, true, -27.5, 0 )
				self.OutcometitlePnlLR:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlLR, {} )
				OutcometitlePnlUL:completeAnimation()
				self.OutcometitlePnlUL:setLeftRight( true, false, -26, 1.5 )
				self.OutcometitlePnlUL:setTopBottom( true, false, 0, 27.5 )
				self.OutcometitlePnlUL:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlUL, {} )
				OutcometitlePnlLL:completeAnimation()
				self.OutcometitlePnlLL:setLeftRight( true, false, -26, 1.5 )
				self.OutcometitlePnlLL:setTopBottom( false, true, -27.5, 0 )
				self.OutcometitlePnlLL:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlLL, {} )
				OutcometitlePnlCenter:completeAnimation()
				self.OutcometitlePnlCenter:setLeftRight( true, true, 0, 0 )
				self.OutcometitlePnlCenter:setTopBottom( true, false, 0, 54.9 )
				self.OutcometitlePnlCenter:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlCenter, {} )
				TopFrame:completeAnimation()
				self.TopFrame:setLeftRight( true, true, 0, 0 )
				self.TopFrame:setTopBottom( true, false, 0, 55 )
				self.TopFrame:setRGB( 0.36, 1, 0.15 )
				self.TopFrame:setAlpha( 0.4 )
				self.clipFinished( TopFrame, {} )
				CornerFrameLL:completeAnimation()
				self.CornerFrameLL:setLeftRight( true, false, -27.5, 0 )
				self.CornerFrameLL:setTopBottom( false, true, -27.5, 0 )
				self.CornerFrameLL:setRGB( 0.36, 1, 0.15 )
				self.CornerFrameLL:setAlpha( 0.4 )
				self.clipFinished( CornerFrameLL, {} )
				CornerFrameUL:completeAnimation()
				self.CornerFrameUL:setLeftRight( true, false, -27.5, 0 )
				self.CornerFrameUL:setTopBottom( true, false, 0, 27.5 )
				self.CornerFrameUL:setRGB( 0.36, 1, 0.15 )
				self.CornerFrameUL:setAlpha( 0.4 )
				self.clipFinished( CornerFrameUL, {} )
				CornerFrameLR:completeAnimation()
				self.CornerFrameLR:setLeftRight( false, true, 0, 27.8 )
				self.CornerFrameLR:setTopBottom( false, true, -27.5, 0 )
				self.CornerFrameLR:setRGB( 0.36, 1, 0.15 )
				self.CornerFrameLR:setAlpha( 0.4 )
				self.clipFinished( CornerFrameLR, {} )
				CornerFrameUR:completeAnimation()
				self.CornerFrameUR:setLeftRight( false, true, 0, 27.8 )
				self.CornerFrameUR:setTopBottom( true, false, 0, 27.5 )
				self.CornerFrameUR:setRGB( 0.36, 1, 0.15 )
				self.CornerFrameUR:setAlpha( 0.4 )
				self.clipFinished( CornerFrameUR, {} )
				ColorBox:completeAnimation()
				self.ColorBox:setRGB( 0.05, 1, 0 )
				self.ColorBox:setAlpha( 0 )
				self.clipFinished( ColorBox, {} )
				KillcamText0:completeAnimation()
				self.KillcamText0:setRGB( 0.79, 0.82, 0.89 )
				self.clipFinished( KillcamText0, {} )
				OutcometitlePnlLineRight:completeAnimation()
				self.OutcometitlePnlLineRight:setLeftRight( false, true, 34, 57 )
				self.OutcometitlePnlLineRight:setTopBottom( true, true, 25.3, -25.25 )
				self.clipFinished( OutcometitlePnlLineRight, {} )
				LineColorRight:completeAnimation()
				self.LineColorRight:setLeftRight( false, true, 34, 57 )
				self.LineColorRight:setTopBottom( true, true, 25.5, -25.45 )
				self.LineColorRight:setRGB( 0.36, 1, 0.15 )
				self.LineColorRight:setAlpha( 0.4 )
				self.clipFinished( LineColorRight, {} )
				LineColorLeft:completeAnimation()
				self.LineColorLeft:setLeftRight( true, false, -55, -32 )
				self.LineColorLeft:setTopBottom( true, true, 25.5, -25.5 )
				self.LineColorLeft:setRGB( 0.36, 1, 0.15 )
				self.LineColorLeft:setAlpha( 0.4 )
				self.clipFinished( LineColorLeft, {} )
			end
		},
		DefeatRed = {
			DefaultClip = function ()
				self:setupElementClipCounter( 15 )
				OutcometitlePnlUR:completeAnimation()
				self.OutcometitlePnlUR:setLeftRight( false, true, -1, 27 )
				self.OutcometitlePnlUR:setTopBottom( true, false, 0, 27.5 )
				self.OutcometitlePnlUR:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlUR, {} )
				OutcometitlePnlLR:completeAnimation()
				self.OutcometitlePnlLR:setLeftRight( false, true, -1, 27 )
				self.OutcometitlePnlLR:setTopBottom( false, true, -27.5, 0 )
				self.OutcometitlePnlLR:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlLR, {} )
				OutcometitlePnlUL:completeAnimation()
				self.OutcometitlePnlUL:setLeftRight( true, false, -26, 1.5 )
				self.OutcometitlePnlUL:setTopBottom( true, false, 0, 27.5 )
				self.OutcometitlePnlUL:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlUL, {} )
				OutcometitlePnlLL:completeAnimation()
				self.OutcometitlePnlLL:setLeftRight( true, false, -26, 1.5 )
				self.OutcometitlePnlLL:setTopBottom( false, true, -27.5, 0 )
				self.OutcometitlePnlLL:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlLL, {} )
				OutcometitlePnlCenter:completeAnimation()
				self.OutcometitlePnlCenter:setLeftRight( true, true, 0, 0 )
				self.OutcometitlePnlCenter:setTopBottom( true, false, 0, 54.9 )
				self.OutcometitlePnlCenter:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlCenter, {} )
				TopFrame:completeAnimation()
				self.TopFrame:setLeftRight( true, true, 0, 0 )
				self.TopFrame:setTopBottom( true, false, 0.1, 54.9 )
				self.TopFrame:setRGB( 1, 0.01, 0 )
				self.TopFrame:setAlpha( 0.4 )
				self.TopFrame:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_normal" ) )
				self.clipFinished( TopFrame, {} )
				CornerFrameLL:completeAnimation()
				self.CornerFrameLL:setLeftRight( true, false, -27.5, 0 )
				self.CornerFrameLL:setTopBottom( false, true, -27.5, 0 )
				self.CornerFrameLL:setRGB( 1, 0.01, 0 )
				self.CornerFrameLL:setAlpha( 0.4 )
				self.CornerFrameLL:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_normal" ) )
				self.clipFinished( CornerFrameLL, {} )
				CornerFrameUL:completeAnimation()
				self.CornerFrameUL:setLeftRight( true, false, -27.5, 0 )
				self.CornerFrameUL:setTopBottom( true, false, 0, 27.5 )
				self.CornerFrameUL:setRGB( 1, 0.01, 0 )
				self.CornerFrameUL:setAlpha( 0.4 )
				self.CornerFrameUL:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_normal" ) )
				self.clipFinished( CornerFrameUL, {} )
				CornerFrameLR:completeAnimation()
				self.CornerFrameLR:setLeftRight( false, true, 0, 27.5 )
				self.CornerFrameLR:setTopBottom( false, true, -27.5, 0 )
				self.CornerFrameLR:setRGB( 1, 0.01, 0 )
				self.CornerFrameLR:setAlpha( 0.4 )
				self.CornerFrameLR:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_normal" ) )
				self.clipFinished( CornerFrameLR, {} )
				CornerFrameUR:completeAnimation()
				self.CornerFrameUR:setLeftRight( false, true, 0, 27.5 )
				self.CornerFrameUR:setTopBottom( true, false, 0, 27.5 )
				self.CornerFrameUR:setRGB( 1, 0.01, 0 )
				self.CornerFrameUR:setAlpha( 0.4 )
				self.CornerFrameUR:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_normal" ) )
				self.clipFinished( CornerFrameUR, {} )
				ColorBox:completeAnimation()
				self.ColorBox:setRGB( 1, 0.01, 0 )
				self.ColorBox:setAlpha( 0 )
				self.clipFinished( ColorBox, {} )
				KillcamText0:completeAnimation()
				self.KillcamText0:setRGB( 0.79, 0.82, 0.89 )
				self.clipFinished( KillcamText0, {} )
				OutcometitlePnlLineRight:completeAnimation()
				self.OutcometitlePnlLineRight:setLeftRight( false, true, 34, 57 )
				self.OutcometitlePnlLineRight:setTopBottom( true, true, 25.3, -25.25 )
				self.clipFinished( OutcometitlePnlLineRight, {} )
				LineColorRight:completeAnimation()
				self.LineColorRight:setLeftRight( false, true, 34, 57 )
				self.LineColorRight:setTopBottom( true, true, 25.5, -25.4 )
				self.LineColorRight:setRGB( 1, 0.01, 0 )
				self.LineColorRight:setAlpha( 0.4 )
				self.LineColorRight:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_normal" ) )
				self.clipFinished( LineColorRight, {} )
				LineColorLeft:completeAnimation()
				self.LineColorLeft:setLeftRight( true, false, -55, -32 )
				self.LineColorLeft:setTopBottom( true, true, 25.5, -25.5 )
				self.LineColorLeft:setRGB( 1, 0.01, 0 )
				self.LineColorLeft:setAlpha( 0.4 )
				self.LineColorLeft:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_normal" ) )
				self.clipFinished( LineColorLeft, {} )
			end
		},
		OvertimeOrange = {
			DefaultClip = function ()
				self:setupElementClipCounter( 15 )
				OutcometitlePnlUR:completeAnimation()
				self.OutcometitlePnlUR:setLeftRight( false, true, -1, 27 )
				self.OutcometitlePnlUR:setTopBottom( true, false, 0, 27.5 )
				self.OutcometitlePnlUR:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlUR, {} )
				OutcometitlePnlLR:completeAnimation()
				self.OutcometitlePnlLR:setLeftRight( false, true, -1, 27 )
				self.OutcometitlePnlLR:setTopBottom( false, true, -27.5, 0 )
				self.OutcometitlePnlLR:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlLR, {} )
				OutcometitlePnlUL:completeAnimation()
				self.OutcometitlePnlUL:setLeftRight( true, false, -26, 1.5 )
				self.OutcometitlePnlUL:setTopBottom( true, false, 0, 27.5 )
				self.OutcometitlePnlUL:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlUL, {} )
				OutcometitlePnlLL:completeAnimation()
				self.OutcometitlePnlLL:setLeftRight( true, false, -26, 1.5 )
				self.OutcometitlePnlLL:setTopBottom( false, true, -27.5, 0 )
				self.OutcometitlePnlLL:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlLL, {} )
				OutcometitlePnlCenter:completeAnimation()
				self.OutcometitlePnlCenter:setLeftRight( true, true, 0, 0 )
				self.OutcometitlePnlCenter:setTopBottom( true, false, 0, 54.9 )
				self.OutcometitlePnlCenter:setAlpha( 1 )
				self.clipFinished( OutcometitlePnlCenter, {} )
				TopFrame:completeAnimation()
				self.TopFrame:setLeftRight( true, true, 0, -1.5 )
				self.TopFrame:setTopBottom( true, false, 0, 55 )
				self.TopFrame:setRGB( 0, 0, 0 )
				self.TopFrame:setAlpha( 0 )
				self.clipFinished( TopFrame, {} )
				CornerFrameLL:completeAnimation()
				self.CornerFrameLL:setLeftRight( true, false, -27.5, 0 )
				self.CornerFrameLL:setTopBottom( false, true, -27.5, 0 )
				self.CornerFrameLL:setRGB( 0, 0, 0 )
				self.CornerFrameLL:setAlpha( 0 )
				self.clipFinished( CornerFrameLL, {} )
				CornerFrameUL:completeAnimation()
				self.CornerFrameUL:setLeftRight( true, false, -27.5, 0 )
				self.CornerFrameUL:setTopBottom( true, false, 0, 27.5 )
				self.CornerFrameUL:setRGB( 0, 0, 0 )
				self.CornerFrameUL:setAlpha( 0 )
				self.clipFinished( CornerFrameUL, {} )
				CornerFrameLR:completeAnimation()
				self.CornerFrameLR:setLeftRight( false, true, 0, 27.5 )
				self.CornerFrameLR:setTopBottom( false, true, -27.5, 0 )
				self.CornerFrameLR:setRGB( 0, 0, 0 )
				self.CornerFrameLR:setAlpha( 0 )
				self.clipFinished( CornerFrameLR, {} )
				CornerFrameUR:completeAnimation()
				self.CornerFrameUR:setLeftRight( false, true, 0, 27.5 )
				self.CornerFrameUR:setTopBottom( true, false, 0, 27.5 )
				self.CornerFrameUR:setRGB( 0, 0, 0 )
				self.CornerFrameUR:setAlpha( 0 )
				self.clipFinished( CornerFrameUR, {} )
				ColorBox:completeAnimation()
				self.ColorBox:setRGB( 1, 0.52, 0 )
				self.ColorBox:setAlpha( 0 )
				self.clipFinished( ColorBox, {} )
				KillcamText0:completeAnimation()
				self.KillcamText0:setRGB( 0.74, 0.76, 0.82 )
				self.clipFinished( KillcamText0, {} )
				OutcometitlePnlLineRight:completeAnimation()
				self.OutcometitlePnlLineRight:setLeftRight( false, true, 34, 57 )
				self.OutcometitlePnlLineRight:setTopBottom( true, true, 25.3, -25.25 )
				self.clipFinished( OutcometitlePnlLineRight, {} )
				LineColorRight:completeAnimation()
				self.LineColorRight:setLeftRight( false, true, 34, 57 )
				self.LineColorRight:setTopBottom( true, true, 25.3, -25.25 )
				self.LineColorRight:setAlpha( 0 )
				self.clipFinished( LineColorRight, {} )
				LineColorLeft:completeAnimation()
				self.LineColorLeft:setRGB( 0, 0, 0 )
				self.LineColorLeft:setAlpha( 0 )
				self.clipFinished( LineColorLeft, {} )
			end
		}
	}
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.OutcometitlePnlUR:close()
		element.OutcometitlePnlLR:close()
		element.OutcometitlePnlUL:close()
		element.OutcometitlePnlLL:close()
		element.OutcometitlePnlCenter:close()
		element.ColorBox:close()
		element.OutcometitlePnlLineRight:close()
		element.OutcometitlePnlLineLeft:close()
	end )
	
	if KillcamWidgetTitlePostLoadFunc then
		KillcamWidgetTitlePostLoadFunc( self, controller, menu )
	end
	
	return self
end

CoD.Outcome_title_PnlURInt = InheritFrom( LUI.UIElement )
CoD.Outcome_title_PnlURInt.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.Outcome_title_PnlURInt )
	self.id = "Outcome_title_PnlURInt"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 28 )
	self:setTopBottom( true, false, 0, 28 )
	
	local CornerFrameURBlur = LUI.UIImage.new()
	CornerFrameURBlur:setLeftRight( false, false, -13.5, 14 )
	CornerFrameURBlur:setTopBottom( false, false, -14, 13.5 )
	CornerFrameURBlur:setImage( RegisterImage( "uie_t7_hud_mp_notifications_endgame_framecorner" ) )
	CornerFrameURBlur:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_scene_blur_pass_1" ) )
	CornerFrameURBlur:setShaderVector( 0, 0, 20, 0, 0 )
	self:addElement( CornerFrameURBlur )
	self.CornerFrameURBlur = CornerFrameURBlur
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		VictoryGreen = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		DefeatRed = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		OvertimeOrange = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		}
	}	
	return self
end

CoD.Outcome_title_PnlUR = InheritFrom( LUI.UIElement )
CoD.Outcome_title_PnlUR.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.Outcome_title_PnlUR )
	self.id = "Outcome_title_PnlUR"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 28 )
	self:setTopBottom( true, false, 0, 28 )
	self.anyChildUsesUpdateState = true
	
	local OutcometitlePnlURInt = CoD.Outcome_title_PnlURInt.new( menu, controller )
	OutcometitlePnlURInt:setLeftRight( false, false, -13.5, 14 )
	OutcometitlePnlURInt:setTopBottom( false, false, -14, 13.5 )
	OutcometitlePnlURInt:setRFTMaterial( LUI.UIImage.GetCachedMaterial( "uie_scene_blur_pass_2_highquality" ) )
	OutcometitlePnlURInt:setShaderVector( 0, 10, 10, 0, 0 )
	self:addElement( OutcometitlePnlURInt )
	self.OutcometitlePnlURInt = OutcometitlePnlURInt
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		VictoryGreen = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		DefeatRed = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		OvertimeOrange = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		}
	}
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.OutcometitlePnlURInt:close()
	end )	
	return self
end

CoD.Outcome_title_PnlCenterInt = InheritFrom( LUI.UIElement )
CoD.Outcome_title_PnlCenterInt.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.Outcome_title_PnlCenterInt )
	self.id = "Outcome_title_PnlCenterInt"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 701 )
	self:setTopBottom( true, false, 0, 55 )
	
	local TopFrameBlur = LUI.UIImage.new()
	TopFrameBlur:setLeftRight( true, true, 0, 0 )
	TopFrameBlur:setTopBottom( true, false, 0, 54.9 )
	TopFrameBlur:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_scene_blur_pass_1" ) )
	TopFrameBlur:setShaderVector( 0, 0, 20, 0, 0 )
	self:addElement( TopFrameBlur )
	self.TopFrameBlur = TopFrameBlur
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		VictoryGreen = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		DefeatRed = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		OvertimeOrange = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		}
	}	
	return self
end

CoD.Outcome_title_PnlCenter = InheritFrom( LUI.UIElement )
CoD.Outcome_title_PnlCenter.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.Outcome_title_PnlCenter )
	self.id = "Outcome_title_PnlCenter"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 701 )
	self:setTopBottom( true, false, 0, 55 )
	self.anyChildUsesUpdateState = true
	
	local OutcometitlePnlCenterInt = CoD.Outcome_title_PnlCenterInt.new( menu, controller )
	OutcometitlePnlCenterInt:setLeftRight( true, true, 0, 0 )
	OutcometitlePnlCenterInt:setTopBottom( true, false, 0, 54.9 )
	OutcometitlePnlCenterInt:setRFTMaterial( LUI.UIImage.GetCachedMaterial( "uie_scene_blur_pass_2" ) )
	OutcometitlePnlCenterInt:setShaderVector( 0, 10, 10, 0, 0 )
	self:addElement( OutcometitlePnlCenterInt )
	self.OutcometitlePnlCenterInt = OutcometitlePnlCenterInt
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		VictoryGreen = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		DefeatRed = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		OvertimeOrange = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		}
	}
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.OutcometitlePnlCenterInt:close()
	end )	
	return self
end

CoD.Outcome_title_PnlLineInt = InheritFrom( LUI.UIElement )
CoD.Outcome_title_PnlLineInt.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.Outcome_title_PnlLineInt )
	self.id = "Outcome_title_PnlLineInt"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 23 )
	self:setTopBottom( true, false, 0, 4 )
	
	local LineBlur = LUI.UIImage.new()
	LineBlur:setLeftRight( false, false, -11.5, 11.5 )
	LineBlur:setTopBottom( false, false, -2, 2 )
	LineBlur:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_scene_blur_pass_1" ) )
	LineBlur:setShaderVector( 0, 0, 20, 0, 0 )
	self:addElement( LineBlur )
	self.LineBlur = LineBlur
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		VictoryGreen = {
			DefaultClip = function ()
				self:setupElementClipCounter( 1 )
				LineBlur:completeAnimation()
				self.LineBlur:setRGB( 0.05, 1, 0 )
				self.LineBlur:setAlpha( 0.3 )
				self.clipFinished( LineBlur, {} )
			end
		},
		DefeatRed = {
			DefaultClip = function ()
				self:setupElementClipCounter( 1 )
				LineBlur:completeAnimation()
				self.LineBlur:setRGB( 1, 0.01, 0 )
				self.LineBlur:setAlpha( 0.3 )
				self.clipFinished( LineBlur, {} )
			end
		},
		OvertimeOrange = {
			DefaultClip = function ()
				self:setupElementClipCounter( 1 )
				LineBlur:completeAnimation()
				self.LineBlur:setRGB( 0, 0, 0 )
				self.LineBlur:setAlpha( 0.3 )
				self.clipFinished( LineBlur, {} )
			end
		}
	}
	return self
end

CoD.Outcome_title_PnlLine = InheritFrom( LUI.UIElement )
CoD.Outcome_title_PnlLine.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.Outcome_title_PnlLine )
	self.id = "Outcome_title_PnlLine"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 23 )
	self:setTopBottom( true, false, 0, 4 )
	self.anyChildUsesUpdateState = true
	
	local OutcometitlePnlLineInt = CoD.Outcome_title_PnlLineInt.new( menu, controller )
	OutcometitlePnlLineInt:setLeftRight( false, false, -11.5, 11.5 )
	OutcometitlePnlLineInt:setTopBottom( false, false, -2, 2 )
	OutcometitlePnlLineInt:setRFTMaterial( LUI.UIImage.GetCachedMaterial( "uie_scene_blur_pass_2" ) )
	OutcometitlePnlLineInt:setShaderVector( 0, 10, 10, 0, 0 )
	self:addElement( OutcometitlePnlLineInt )
	self.OutcometitlePnlLineInt = OutcometitlePnlLineInt
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		VictoryGreen = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		DefeatRed = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		OvertimeOrange = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		}
	}
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.OutcometitlePnlLineInt:close()
	end )	
	return self
end

require( "ui.uieditor.widgets.Lobby.Common.FE_ListHeaderGlow" )
require( "ui.uieditor.widgets.StartMenu.StartMenu_frame_noBG" )
require( "ui.uieditor.widgets.Effects.fxGlitch1_Main" )
require( "ui.uieditor.widgets.Lobby.Common.FE_ButtonPanel" )
require( "ui.uieditor.widgets.Lobby.Common.FE_PanelNoBlur" )
require( "ui.uieditor.widgets.Lobby.Common.FE_ButtonPanelShaderContainer" )
require( "ui.uieditor.widgets.EndGameFlow.Top3PlayerScoreBlurBox" )

CoD.KillcamPlayerInfo = InheritFrom( LUI.UIElement )
CoD.KillcamPlayerInfo.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.KillcamPlayerInfo )
	self.id = "KillcamPlayerInfo"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 1280 )
	self:setTopBottom( true, false, 0, 56 )
	self.anyChildUsesUpdateState = true
	
	local NemesisShadow = LUI.UIImage.new()
	NemesisShadow:setLeftRight( true, false, 493, 787 )
	NemesisShadow:setTopBottom( true, false, -123, 64 )
	NemesisShadow:setRGB( 0, 0, 0 )
	NemesisShadow:setAlpha( 0.23 )
	NemesisShadow:setImage( RegisterImage( "uie_t7_core_hud_mapwidget_panelglow" ) )
	self:addElement( NemesisShadow )
	self.NemesisShadow = NemesisShadow
	
	local NemesisLine2 = LUI.UIImage.new()
	NemesisLine2:setLeftRight( false, false, -686.78, -60 )
	NemesisLine2:setTopBottom( false, false, -71, -47 )
	NemesisLine2:setYRot( 180 )
	NemesisLine2:setImage( RegisterImage( "uie_t7_cp_hud_weakpoint_newreddash" ) )
	NemesisLine2:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_tile_scroll" ) )
	NemesisLine2:setShaderVector( 0, 200, 4.83, 0, 0 )
	NemesisLine2:setShaderVector( 1, 6.02, 0, 0, 0 )
	self:addElement( NemesisLine2 )
	self.NemesisLine2 = NemesisLine2
	
	local NemesisImageNormal = LUI.UIImage.new()
	NemesisImageNormal:setLeftRight( true, false, 578.22, 701.78 )
	NemesisImageNormal:setTopBottom( true, false, -71, 9 )
	NemesisImageNormal:setAlpha( 0.6 )
	NemesisImageNormal:setImage( RegisterImage( "uie_t7_hud_mp_notifications_endgame_nemesis" ) )
	self:addElement( NemesisImageNormal )
	self.NemesisImageNormal = NemesisImageNormal
	
	local NemesisImageAdd = LUI.UIImage.new()
	NemesisImageAdd:setLeftRight( true, false, 578.22, 701.78 )
	NemesisImageAdd:setTopBottom( true, false, -71, 9 )
	NemesisImageAdd:setImage( RegisterImage( "uie_t7_hud_mp_notifications_endgame_nemesis" ) )
	NemesisImageAdd:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( NemesisImageAdd )
	self.NemesisImageAdd = NemesisImageAdd
	
	local NemesisGlow = LUI.UIImage.new()
	NemesisGlow:setLeftRight( true, false, 546, 740 )
	NemesisGlow:setTopBottom( true, false, -97, 31 )
	NemesisGlow:setRGB( 0.29, 0.01, 0 )
	NemesisGlow:setImage( RegisterImage( "uie_t7_core_hud_mapwidget_panelglow" ) )
	NemesisGlow:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( NemesisGlow )
	self.NemesisGlow = NemesisGlow
	
	local NemesLine1 = LUI.UIImage.new()
	NemesLine1:setLeftRight( false, false, 59, 649.5 )
	NemesLine1:setTopBottom( false, false, -71, -47 )
	NemesLine1:setImage( RegisterImage( "uie_t7_cp_hud_weakpoint_newreddash" ) )
	NemesLine1:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_tile_scroll" ) )
	NemesLine1:setShaderVector( 0, 200, 4.83, 0, 0 )
	NemesLine1:setShaderVector( 1, 6.02, 0, 0, 0 )
	self:addElement( NemesLine1 )
	self.NemesLine1 = NemesLine1
	
	local LeftPanelR = CoD.KillcamWidgetPnlRT.new( menu, controller )
	LeftPanelR:setLeftRight( true, false, -35, 640 )
	LeftPanelR:setTopBottom( true, false, -12, 68 )
	LeftPanelR:setRGB( 0.5, 0.5, 0.5 )
	LeftPanelR.KillcamWidgetPnlRTInt0:setShaderVector( 0, 0, 3, 0, 0 )
	self:addElement( LeftPanelR )
	self.LeftPanelR = LeftPanelR
	
	local LeftPanelR0 = CoD.KillcamWidgetPnlRT.new( menu, controller )
	LeftPanelR0:setLeftRight( true, false, 640, 1315 )
	LeftPanelR0:setTopBottom( true, false, -12, 68 )
	LeftPanelR0:setRGB( 0.5, 0.5, 0.5 )
	LeftPanelR0:setYRot( 180 )
	LeftPanelR0.KillcamWidgetPnlRTInt0:setShaderVector( 0, 0, 3, 0, 0 )
	self:addElement( LeftPanelR0 )
	self.LeftPanelR0 = LeftPanelR0
	
	local YouAndKillerWidget0 = CoD.YouAndKiller_Widget.new( menu, controller )
	YouAndKillerWidget0:setLeftRight( true, false, 864, 1088 )
	YouAndKillerWidget0:setTopBottom( true, false, -15, 11 )
	YouAndKillerWidget0.KillerYouLabels:setText( Engine.Localize( "MENU_YOU_CAPS" ) )
	self:addElement( YouAndKillerWidget0 )
	self.YouAndKillerWidget0 = YouAndKillerWidget0
	
	local YouAndKillerWidget00 = CoD.YouAndKiller_Widget.new( menu, controller )
	YouAndKillerWidget00:setLeftRight( true, false, 287, 505 )
	YouAndKillerWidget00:setTopBottom( true, false, -15, 11 )
	YouAndKillerWidget00.KillerYouLabels:setText( Engine.Localize( LocalizeToUpperString( "MPUI_KILLER" ) ) )
	self:addElement( YouAndKillerWidget00 )
	self.YouAndKillerWidget00 = YouAndKillerWidget00
	
	local VictimPlayerCard = CoD.PlayerCard.new( menu, controller )
	VictimPlayerCard:setLeftRight( true, false, 779, 1098 )
	VictimPlayerCard:setTopBottom( true, false, 3, 62 )
	VictimPlayerCard:subscribeToGlobalModel( controller, "Victim", nil, function ( modelRef )
		VictimPlayerCard:setModel( modelRef, controller )
	end )
	VictimPlayerCard:subscribeToGlobalModel( controller, "KillcamInfo", "victimFactionColor", function ( modelRef )
		local victimFactionColor = Engine.GetModelValue( modelRef )
		if victimFactionColor then
			VictimPlayerCard.TeamColor:setRGB( victimFactionColor )
		end
	end )
	VictimPlayerCard:linkToElementModel( self, "heading", true, function ( modelRef )
		local heading = Engine.GetModelValue( modelRef )
		if heading then
			VictimPlayerCard.CalloutHeading:setText( Engine.Localize( heading ) )
		end
	end )
	self:addElement( VictimPlayerCard )
	self.VictimPlayerCard = VictimPlayerCard
	
	local AttackerPlayerCard = CoD.PlayerCard.new( menu, controller )
	AttackerPlayerCard:setLeftRight( true, false, 198, 521 )
	AttackerPlayerCard:setTopBottom( true, false, 3, 62 )
	AttackerPlayerCard:subscribeToGlobalModel( controller, "Attacker", nil, function ( modelRef )
		AttackerPlayerCard:setModel( modelRef, controller )
	end )
	AttackerPlayerCard:linkToElementModel( self, "heading", true, function ( modelRef )
		local heading = Engine.GetModelValue( modelRef )
		if heading then
			AttackerPlayerCard.CalloutHeading:setText( Engine.Localize( heading ) )
		end
	end )
	self:addElement( AttackerPlayerCard )
	self.AttackerPlayerCard = AttackerPlayerCard
	
	local KillsLabel2 = LUI.UIText.new()
	KillsLabel2:setLeftRight( true, false, 689, 736 )
	KillsLabel2:setTopBottom( true, false, 0, 16 )
	KillsLabel2:setRGB( 0.83, 0.87, 0.95 )
	KillsLabel2:setText( Engine.Localize( "MENU_KILLS_CAPS" ) )
	KillsLabel2:setTTF( "fonts/escom.ttf" )
	KillsLabel2:setLetterSpacing( 1 )
	KillsLabel2:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	KillsLabel2:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
	self:addElement( KillsLabel2 )
	self.KillsLabel2 = KillsLabel2
	
	local KillsLabel1 = LUI.UIText.new()
	KillsLabel1:setLeftRight( true, false, 546.72, 593.72 )
	KillsLabel1:setTopBottom( true, false, 0, 16 )
	KillsLabel1:setRGB( 0.83, 0.87, 0.95 )
	KillsLabel1:setText( Engine.Localize( "MENU_KILLS_CAPS" ) )
	KillsLabel1:setTTF( "fonts/escom.ttf" )
	KillsLabel1:setLetterSpacing( 1 )
	KillsLabel1:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	KillsLabel1:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
	self:addElement( KillsLabel1 )
	self.KillsLabel1 = KillsLabel1
	
	local AttackerKillsNew = CoD.KillcamWidgetNumbers.new( menu, controller )
	AttackerKillsNew:setLeftRight( false, false, -130.78, -10.78 )
	AttackerKillsNew:setTopBottom( false, false, -17, 37 )
	AttackerKillsNew:subscribeToModel(Engine.GetModel(Engine.GetModelForController(controller), "ZBRAttacker.kills"), function ( modelRef )
		local kills = Engine.GetModelValue( modelRef )
		if kills then
			AttackerKillsNew.Numbers:setText( Engine.Localize( kills ) )
		end
	end )
	self:addElement( AttackerKillsNew )
	self.AttackerKillsNew = AttackerKillsNew
	
	local VictimKillsNew = CoD.KillcamWidgetNumbers.new( menu, controller )
	VictimKillsNew:setLeftRight( false, false, 12.22, 132.22 )
	VictimKillsNew:setTopBottom( false, false, -17, 37 )
	VictimKillsNew:subscribeToModel(Engine.GetModel(Engine.GetModelForController(controller), "ZBRVictim.kills"), function ( modelRef )
		local kills = Engine.GetModelValue( modelRef )
		if kills then
			VictimKillsNew.Numbers:setText( Engine.Localize( kills ) )
		end
	end )
	self:addElement( VictimKillsNew )
	self.VictimKillsNew = VictimKillsNew
	
	local VSBanner = CoD.FE_ListHeaderGlow.new( menu, controller )
	VSBanner:setLeftRight( true, false, 619.5, 660.5 )
	VSBanner:setTopBottom( true, false, 14, 42 )
	self:addElement( VSBanner )
	self.VSBanner = VSBanner
	
	local VSLabel = LUI.UITightText.new()
	VSLabel:setLeftRight( false, false, -13.5, 17.5 )
	VSLabel:setTopBottom( true, false, 16, 41 )
	VSLabel:setRGB( 0, 0, 0 )
	VSLabel:setText( Engine.Localize( "MP_VERSUS" ) )
	VSLabel:setTTF( "fonts/escom.ttf" )
	VSLabel:setLetterSpacing( 2 )
	self:addElement( VSLabel )
	self.VSLabel = VSLabel
	
	local Glitch = CoD.fxGlitch1_Main.new( menu, controller )
	Glitch:setLeftRight( true, false, 159, 1127 )
	Glitch:setTopBottom( true, false, -83.5, 138.5 )
	self:addElement( Glitch )
	self.Glitch = Glitch
	
	local KillsLabel20 = LUI.UIText.new()
	KillsLabel20:setLeftRight( true, false, 578.22, 697.72 )
	KillsLabel20:setTopBottom( true, false, -39, -23 )
	KillsLabel20:setRGB( 0, 0, 0 )
	KillsLabel20:setText( Engine.Localize( "MPUI_NEMESIS_TITLE_CAPS" ) )
	KillsLabel20:setTTF( "fonts/escom.ttf" )
	KillsLabel20:setLetterSpacing( 1 )
	KillsLabel20:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	KillsLabel20:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
	self:addElement( KillsLabel20 )
	self.KillsLabel20 = KillsLabel20
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 19 )
				NemesisShadow:completeAnimation()
				self.NemesisShadow:setAlpha( 0 )
				self.clipFinished( NemesisShadow, {} )
				NemesisLine2:completeAnimation()
				self.NemesisLine2:setLeftRight( false, false, -63.78, -60 )
				self.NemesisLine2:setTopBottom( false, false, -71, -47 )
				self.NemesisLine2:setAlpha( 0 )
				self.clipFinished( NemesisLine2, {} )
				NemesisImageNormal:completeAnimation()
				self.NemesisImageNormal:setAlpha( 0 )
				self.clipFinished( NemesisImageNormal, {} )
				NemesisImageAdd:completeAnimation()
				self.NemesisImageAdd:setAlpha( 0 )
				self.clipFinished( NemesisImageAdd, {} )
				NemesisGlow:completeAnimation()
				self.NemesisGlow:setAlpha( 0 )
				self.clipFinished( NemesisGlow, {} )
				NemesLine1:completeAnimation()
				self.NemesLine1:setLeftRight( false, false, 59, 79.5 )
				self.NemesLine1:setTopBottom( false, false, -71, -47 )
				self.NemesLine1:setAlpha( 0 )
				self.clipFinished( NemesLine1, {} )
				LeftPanelR:completeAnimation()
				self.LeftPanelR:setLeftRight( true, false, 356, 500 )
				self.LeftPanelR:setTopBottom( true, false, -12, 68 )
				self.LeftPanelR:setAlpha( 0 )
				self.clipFinished( LeftPanelR, {} )
				LeftPanelR0:completeAnimation()
				self.LeftPanelR0:setLeftRight( true, false, 790, 934 )
				self.LeftPanelR0:setTopBottom( true, false, -12, 68 )
				self.LeftPanelR0:setAlpha( 0 )
				self.clipFinished( LeftPanelR0, {} )
				YouAndKillerWidget0:completeAnimation()
				self.YouAndKillerWidget0:setAlpha( 0 )
				self.clipFinished( YouAndKillerWidget0, {} )
				YouAndKillerWidget00:completeAnimation()
				self.YouAndKillerWidget00:setAlpha( 0 )
				self.clipFinished( YouAndKillerWidget00, {} )
				VictimPlayerCard:completeAnimation()
				self.VictimPlayerCard:setLeftRight( true, false, 929, 1205 )
				self.VictimPlayerCard:setTopBottom( true, false, -2, 57 )
				self.VictimPlayerCard:setAlpha( 0 )
				self.clipFinished( VictimPlayerCard, {} )
				AttackerPlayerCard:completeAnimation()
				self.AttackerPlayerCard:setLeftRight( true, false, 93.36, 360.36 )
				self.AttackerPlayerCard:setTopBottom( true, false, -2, 57 )
				self.AttackerPlayerCard:setAlpha( 0 )
				self.clipFinished( AttackerPlayerCard, {} )
				KillsLabel2:completeAnimation()
				self.KillsLabel2:setAlpha( 0 )
				self.clipFinished( KillsLabel2, {} )
				KillsLabel1:completeAnimation()
				self.KillsLabel1:setAlpha( 0 )
				self.clipFinished( KillsLabel1, {} )
				AttackerKillsNew:completeAnimation()
				self.AttackerKillsNew:setAlpha( 0 )
				self.clipFinished( AttackerKillsNew, {} )
				VictimKillsNew:completeAnimation()
				self.VictimKillsNew:setAlpha( 0 )
				self.clipFinished( VictimKillsNew, {} )
				VSBanner:completeAnimation()
				self.VSBanner:setAlpha( 0 )
				self.clipFinished( VSBanner, {} )
				VSLabel:completeAnimation()
				self.VSLabel:setAlpha( 0 )
				self.clipFinished( VSLabel, {} )
				KillsLabel20:completeAnimation()
				self.KillsLabel20:setAlpha( 0 )
				self.clipFinished( KillsLabel20, {} )
			end
		},
		Killcam = {
			DefaultClip = function ()
				self:setupElementClipCounter( 19 )
				NemesisShadow:completeAnimation()
				self.NemesisShadow:setAlpha( 0 )
				self.clipFinished( NemesisShadow, {} )
				NemesisLine2:completeAnimation()
				self.NemesisLine2:setLeftRight( false, false, -63.78, -60 )
				self.NemesisLine2:setTopBottom( false, false, -71, -47 )
				self.NemesisLine2:setAlpha( 0 )
				self.clipFinished( NemesisLine2, {} )
				NemesisImageNormal:completeAnimation()
				self.NemesisImageNormal:setAlpha( 0 )
				self.clipFinished( NemesisImageNormal, {} )
				NemesisImageAdd:completeAnimation()
				self.NemesisImageAdd:setAlpha( 0 )
				self.clipFinished( NemesisImageAdd, {} )
				NemesisGlow:completeAnimation()
				self.NemesisGlow:setAlpha( 0 )
				self.clipFinished( NemesisGlow, {} )
				NemesLine1:completeAnimation()
				self.NemesLine1:setLeftRight( false, false, 59, 79.5 )
				self.NemesLine1:setTopBottom( false, false, -71, -47 )
				self.NemesLine1:setAlpha( 0 )
				self.clipFinished( NemesLine1, {} )
				local f10_local0 = function ( f11_arg0, f11_arg1 )
					if not f11_arg1.interrupted then
						f11_arg0:beginAnimation( "keyframe", 699, false, true, CoD.TweenType.Bounce )
					end
					f11_arg0:setLeftRight( true, false, -35, 640 )
					f11_arg0:setTopBottom( true, false, -12, 68 )
					f11_arg0:setAlpha( 1 )
					if f11_arg1.interrupted then
						self.clipFinished( f11_arg0, f11_arg1 )
					else
						f11_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				LeftPanelR:completeAnimation()
				self.LeftPanelR:setLeftRight( true, false, -31, 500 )
				self.LeftPanelR:setTopBottom( true, false, -12, 68 )
				self.LeftPanelR:setAlpha( 0 )
				f10_local0( LeftPanelR, {} )
				local f10_local1 = function ( f12_arg0, f12_arg1 )
					if not f12_arg1.interrupted then
						f12_arg0:beginAnimation( "keyframe", 699, false, true, CoD.TweenType.Bounce )
					end
					f12_arg0:setLeftRight( true, false, 640, 1315 )
					f12_arg0:setTopBottom( true, false, -12, 68 )
					f12_arg0:setAlpha( 1 )
					if f12_arg1.interrupted then
						self.clipFinished( f12_arg0, f12_arg1 )
					else
						f12_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				LeftPanelR0:completeAnimation()
				self.LeftPanelR0:setLeftRight( true, false, 790, 1311 )
				self.LeftPanelR0:setTopBottom( true, false, -12, 68 )
				self.LeftPanelR0:setAlpha( 0 )
				f10_local1( LeftPanelR0, {} )
				local f10_local2 = function ( f13_arg0, f13_arg1 )
					if not f13_arg1.interrupted then
						f13_arg0:beginAnimation( "keyframe", 699, true, true, CoD.TweenType.Bounce )
					end
					f13_arg0:setLeftRight( true, false, 863, 1087 )
					f13_arg0:setTopBottom( true, false, -13, 13 )
					f13_arg0:setAlpha( 1 )
					if f13_arg1.interrupted then
						self.clipFinished( f13_arg0, f13_arg1 )
					else
						f13_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				YouAndKillerWidget0:completeAnimation()
				self.YouAndKillerWidget0:setLeftRight( true, false, 1020, 1237 )
				self.YouAndKillerWidget0:setTopBottom( true, false, -13, 13 )
				self.YouAndKillerWidget0:setAlpha( 0 )
				f10_local2( YouAndKillerWidget0, {} )
				local f10_local3 = function ( f14_arg0, f14_arg1 )
					if not f14_arg1.interrupted then
						f14_arg0:beginAnimation( "keyframe", 699, true, true, CoD.TweenType.Bounce )
					end
					f14_arg0:setLeftRight( true, false, 283, 506 )
					f14_arg0:setTopBottom( true, false, -13, 13 )
					f14_arg0:setAlpha( 1 )
					if f14_arg1.interrupted then
						self.clipFinished( f14_arg0, f14_arg1 )
					else
						f14_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				YouAndKillerWidget00:completeAnimation()
				self.YouAndKillerWidget00:setLeftRight( true, false, 184, 401 )
				self.YouAndKillerWidget00:setTopBottom( true, false, -13, 13 )
				self.YouAndKillerWidget00:setAlpha( 0 )
				f10_local3( YouAndKillerWidget00, {} )
				local f10_local4 = function ( f15_arg0, f15_arg1 )
					if not f15_arg1.interrupted then
						f15_arg0:beginAnimation( "keyframe", 699, true, true, CoD.TweenType.Bounce )
					end
					f15_arg0:setLeftRight( true, false, 779, 1098 )
					f15_arg0:setTopBottom( true, false, 6, 65 )
					f15_arg0:setAlpha( 1 )
					if f15_arg1.interrupted then
						self.clipFinished( f15_arg0, f15_arg1 )
					else
						f15_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				VictimPlayerCard:completeAnimation()
				self.VictimPlayerCard:setLeftRight( true, false, 929, 1205 )
				self.VictimPlayerCard:setTopBottom( true, false, 6, 65 )
				self.VictimPlayerCard:setAlpha( 0 )
				f10_local4( VictimPlayerCard, {} )
				local f10_local5 = function ( f16_arg0, f16_arg1 )
					if not f16_arg1.interrupted then
						f16_arg0:beginAnimation( "keyframe", 699, true, true, CoD.TweenType.Bounce )
					end
					f16_arg0:setLeftRight( true, false, 198, 521 )
					f16_arg0:setTopBottom( true, false, 6, 65 )
					f16_arg0:setAlpha( 1 )
					if f16_arg1.interrupted then
						self.clipFinished( f16_arg0, f16_arg1 )
					else
						f16_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				AttackerPlayerCard:completeAnimation()
				self.AttackerPlayerCard:setLeftRight( true, false, 93, 360 )
				self.AttackerPlayerCard:setTopBottom( true, false, 6, 65 )
				self.AttackerPlayerCard:setAlpha( 0 )
				f10_local5( AttackerPlayerCard, {} )
				local f10_local6 = function ( f17_arg0, f17_arg1 )
					local f17_local0 = function ( f18_arg0, f18_arg1 )
						if not f18_arg1.interrupted then
							f18_arg0:beginAnimation( "keyframe", 280, false, false, CoD.TweenType.Bounce )
						end
						f18_arg0:setAlpha( 1 )
						if f18_arg1.interrupted then
							self.clipFinished( f18_arg0, f18_arg1 )
						else
							f18_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f17_arg1.interrupted then
						f17_local0( f17_arg0, f17_arg1 )
						return 
					else
						f17_arg0:beginAnimation( "keyframe", 509, false, false, CoD.TweenType.Linear )
						f17_arg0:registerEventHandler( "transition_complete_keyframe", f17_local0 )
					end
				end
				
				KillsLabel2:completeAnimation()
				self.KillsLabel2:setAlpha( 0 )
				f10_local6( KillsLabel2, {} )
				local f10_local7 = function ( f19_arg0, f19_arg1 )
					local f19_local0 = function ( f20_arg0, f20_arg1 )
						if not f20_arg1.interrupted then
							f20_arg0:beginAnimation( "keyframe", 280, false, false, CoD.TweenType.Bounce )
						end
						f20_arg0:setAlpha( 1 )
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
						f19_arg0:beginAnimation( "keyframe", 509, false, false, CoD.TweenType.Linear )
						f19_arg0:registerEventHandler( "transition_complete_keyframe", f19_local0 )
					end
				end
				
				KillsLabel1:completeAnimation()
				self.KillsLabel1:setAlpha( 0 )
				f10_local7( KillsLabel1, {} )
				local f10_local8 = function ( f21_arg0, f21_arg1 )
					local f21_local0 = function ( f22_arg0, f22_arg1 )
						if not f22_arg1.interrupted then
							f22_arg0:beginAnimation( "keyframe", 280, false, false, CoD.TweenType.Bounce )
						end
						f22_arg0:setAlpha( 1 )
						if f22_arg1.interrupted then
							self.clipFinished( f22_arg0, f22_arg1 )
						else
							f22_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f21_arg1.interrupted then
						f21_local0( f21_arg0, f21_arg1 )
						return 
					else
						f21_arg0:beginAnimation( "keyframe", 439, false, false, CoD.TweenType.Linear )
						f21_arg0:registerEventHandler( "transition_complete_keyframe", f21_local0 )
					end
				end
				
				AttackerKillsNew:completeAnimation()
				self.AttackerKillsNew:setAlpha( 0 )
				f10_local8( AttackerKillsNew, {} )
				local f10_local9 = function ( f23_arg0, f23_arg1 )
					local f23_local0 = function ( f24_arg0, f24_arg1 )
						if not f24_arg1.interrupted then
							f24_arg0:beginAnimation( "keyframe", 280, false, false, CoD.TweenType.Bounce )
						end
						f24_arg0:setAlpha( 1 )
						if f24_arg1.interrupted then
							self.clipFinished( f24_arg0, f24_arg1 )
						else
							f24_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f23_arg1.interrupted then
						f23_local0( f23_arg0, f23_arg1 )
						return 
					else
						f23_arg0:beginAnimation( "keyframe", 509, false, false, CoD.TweenType.Linear )
						f23_arg0:registerEventHandler( "transition_complete_keyframe", f23_local0 )
					end
				end
				
				VictimKillsNew:completeAnimation()
				self.VictimKillsNew:setAlpha( 0 )
				f10_local9( VictimKillsNew, {} )
				local f10_local10 = function ( f25_arg0, f25_arg1 )
					local f25_local0 = function ( f26_arg0, f26_arg1 )
						if not f26_arg1.interrupted then
							f26_arg0:beginAnimation( "keyframe", 279, false, false, CoD.TweenType.Bounce )
						end
						f26_arg0:setAlpha( 1 )
						if f26_arg1.interrupted then
							self.clipFinished( f26_arg0, f26_arg1 )
						else
							f26_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f25_arg1.interrupted then
						f25_local0( f25_arg0, f25_arg1 )
						return 
					else
						f25_arg0:beginAnimation( "keyframe", 600, false, false, CoD.TweenType.Linear )
						f25_arg0:registerEventHandler( "transition_complete_keyframe", f25_local0 )
					end
				end
				
				VSBanner:completeAnimation()
				self.VSBanner:setAlpha( 0 )
				f10_local10( VSBanner, {} )
				local f10_local11 = function ( f27_arg0, f27_arg1 )
					local f27_local0 = function ( f28_arg0, f28_arg1 )
						if not f28_arg1.interrupted then
							f28_arg0:beginAnimation( "keyframe", 280, false, false, CoD.TweenType.Bounce )
						end
						f28_arg0:setAlpha( 1 )
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
						f27_arg0:beginAnimation( "keyframe", 649, false, false, CoD.TweenType.Linear )
						f27_arg0:registerEventHandler( "transition_complete_keyframe", f27_local0 )
					end
				end
				
				VSLabel:completeAnimation()
				self.VSLabel:setAlpha( 0 )
				f10_local11( VSLabel, {} )
				KillsLabel20:completeAnimation()
				self.KillsLabel20:setAlpha( 0 )
				self.clipFinished( KillsLabel20, {} )
			end
		},
		NemesisKillcam = {
			DefaultClip = function ()
				self:setupElementClipCounter( 18 )
				local f29_local0 = function ( f30_arg0, f30_arg1 )
					if not f30_arg1.interrupted then
						f30_arg0:beginAnimation( "keyframe", 699, false, false, CoD.TweenType.Linear )
					end
					f30_arg0:setAlpha( 0.23 )
					if f30_arg1.interrupted then
						self.clipFinished( f30_arg0, f30_arg1 )
					else
						f30_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				NemesisShadow:completeAnimation()
				self.NemesisShadow:setAlpha( 0 )
				f29_local0( NemesisShadow, {} )
				local f29_local1 = function ( f31_arg0, f31_arg1 )
					if not f31_arg1.interrupted then
						f31_arg0:beginAnimation( "keyframe", 699, false, false, CoD.TweenType.Linear )
					end
					f31_arg0:setLeftRight( false, false, -686.78, -60 )
					f31_arg0:setTopBottom( false, false, -71, -47 )
					f31_arg0:setAlpha( 1 )
					if f31_arg1.interrupted then
						self.clipFinished( f31_arg0, f31_arg1 )
					else
						f31_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				NemesisLine2:completeAnimation()
				self.NemesisLine2:setLeftRight( false, false, -63.78, -60 )
				self.NemesisLine2:setTopBottom( false, false, -71, -47 )
				self.NemesisLine2:setAlpha( 0 )
				f29_local1( NemesisLine2, {} )
				local f29_local2 = function ( f32_arg0, f32_arg1 )
					local f32_local0 = function ( f33_arg0, f33_arg1 )
						if not f33_arg1.interrupted then
							f33_arg0:beginAnimation( "keyframe", 190, false, false, CoD.TweenType.Bounce )
						end
						f33_arg0:setAlpha( 0.6 )
						if f33_arg1.interrupted then
							self.clipFinished( f33_arg0, f33_arg1 )
						else
							f33_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f32_arg1.interrupted then
						f32_local0( f32_arg0, f32_arg1 )
						return 
					else
						f32_arg0:beginAnimation( "keyframe", 79, false, false, CoD.TweenType.Linear )
						f32_arg0:registerEventHandler( "transition_complete_keyframe", f32_local0 )
					end
				end
				
				NemesisImageNormal:completeAnimation()
				self.NemesisImageNormal:setAlpha( 0 )
				f29_local2( NemesisImageNormal, {} )
				local f29_local3 = function ( f34_arg0, f34_arg1 )
					if not f34_arg1.interrupted then
						f34_arg0:beginAnimation( "keyframe", 519, false, false, CoD.TweenType.Bounce )
					end
					f34_arg0:setAlpha( 1 )
					if f34_arg1.interrupted then
						self.clipFinished( f34_arg0, f34_arg1 )
					else
						f34_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				NemesisImageAdd:completeAnimation()
				self.NemesisImageAdd:setAlpha( 0 )
				f29_local3( NemesisImageAdd, {} )
				local f29_local4 = function ( f35_arg0, f35_arg1 )
					if not f35_arg1.interrupted then
						f35_arg0:beginAnimation( "keyframe", 699, false, false, CoD.TweenType.Linear )
					end
					f35_arg0:setAlpha( 1 )
					if f35_arg1.interrupted then
						self.clipFinished( f35_arg0, f35_arg1 )
					else
						f35_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				NemesisGlow:completeAnimation()
				self.NemesisGlow:setAlpha( 0 )
				f29_local4( NemesisGlow, {} )
				local f29_local5 = function ( f36_arg0, f36_arg1 )
					if not f36_arg1.interrupted then
						f36_arg0:beginAnimation( "keyframe", 699, false, false, CoD.TweenType.Linear )
					end
					f36_arg0:setLeftRight( false, false, 59, 649.5 )
					f36_arg0:setTopBottom( false, false, -71, -47 )
					f36_arg0:setAlpha( 1 )
					if f36_arg1.interrupted then
						self.clipFinished( f36_arg0, f36_arg1 )
					else
						f36_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				NemesLine1:completeAnimation()
				self.NemesLine1:setLeftRight( false, false, 59, 79.5 )
				self.NemesLine1:setTopBottom( false, false, -71, -47 )
				self.NemesLine1:setAlpha( 0 )
				f29_local5( NemesLine1, {} )
				local f29_local6 = function ( f37_arg0, f37_arg1 )
					if not f37_arg1.interrupted then
						f37_arg0:beginAnimation( "keyframe", 699, true, true, CoD.TweenType.Bounce )
					end
					f37_arg0:setLeftRight( true, false, -35, 640 )
					f37_arg0:setTopBottom( true, false, -12, 68 )
					f37_arg0:setAlpha( 1 )
					if f37_arg1.interrupted then
						self.clipFinished( f37_arg0, f37_arg1 )
					else
						f37_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				LeftPanelR:completeAnimation()
				self.LeftPanelR:setLeftRight( true, false, -31, 500 )
				self.LeftPanelR:setTopBottom( true, false, -12, 68 )
				self.LeftPanelR:setAlpha( 0 )
				f29_local6( LeftPanelR, {} )
				local f29_local7 = function ( f38_arg0, f38_arg1 )
					if not f38_arg1.interrupted then
						f38_arg0:beginAnimation( "keyframe", 699, true, true, CoD.TweenType.Bounce )
					end
					f38_arg0:setLeftRight( true, false, 640, 1315 )
					f38_arg0:setTopBottom( true, false, -12, 68 )
					f38_arg0:setAlpha( 1 )
					if f38_arg1.interrupted then
						self.clipFinished( f38_arg0, f38_arg1 )
					else
						f38_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				LeftPanelR0:completeAnimation()
				self.LeftPanelR0:setLeftRight( true, false, 790, 1311 )
				self.LeftPanelR0:setTopBottom( true, false, -12, 68 )
				self.LeftPanelR0:setAlpha( 0 )
				f29_local7( LeftPanelR0, {} )
				local f29_local8 = function ( f39_arg0, f39_arg1 )
					if not f39_arg1.interrupted then
						f39_arg0:beginAnimation( "keyframe", 699, true, true, CoD.TweenType.Bounce )
					end
					f39_arg0:setLeftRight( true, false, 867, 1087 )
					f39_arg0:setTopBottom( true, false, -13, 13 )
					f39_arg0:setAlpha( 1 )
					if f39_arg1.interrupted then
						self.clipFinished( f39_arg0, f39_arg1 )
					else
						f39_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				YouAndKillerWidget0:completeAnimation()
				self.YouAndKillerWidget0:setLeftRight( true, false, 1020, 1237 )
				self.YouAndKillerWidget0:setTopBottom( true, false, -13, 13 )
				self.YouAndKillerWidget0:setAlpha( 0 )
				f29_local8( YouAndKillerWidget0, {} )
				local f29_local9 = function ( f40_arg0, f40_arg1 )
					if not f40_arg1.interrupted then
						f40_arg0:beginAnimation( "keyframe", 699, true, true, CoD.TweenType.Bounce )
					end
					f40_arg0:setLeftRight( true, false, 287, 505 )
					f40_arg0:setTopBottom( true, false, -13, 13 )
					f40_arg0:setAlpha( 1 )
					if f40_arg1.interrupted then
						self.clipFinished( f40_arg0, f40_arg1 )
					else
						f40_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				YouAndKillerWidget00:completeAnimation()
				self.YouAndKillerWidget00:setLeftRight( true, false, 184, 401 )
				self.YouAndKillerWidget00:setTopBottom( true, false, -13, 13 )
				self.YouAndKillerWidget00:setAlpha( 0 )
				f29_local9( YouAndKillerWidget00, {} )
				local f29_local10 = function ( f41_arg0, f41_arg1 )
					if not f41_arg1.interrupted then
						f41_arg0:beginAnimation( "keyframe", 699, true, true, CoD.TweenType.Bounce )
					end
					f41_arg0:setLeftRight( true, false, 779, 1098 )
					f41_arg0:setTopBottom( true, false, 6, 65 )
					f41_arg0:setAlpha( 1 )
					if f41_arg1.interrupted then
						self.clipFinished( f41_arg0, f41_arg1 )
					else
						f41_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				VictimPlayerCard:completeAnimation()
				self.VictimPlayerCard:setLeftRight( true, false, 929, 1205 )
				self.VictimPlayerCard:setTopBottom( true, false, 6, 65 )
				self.VictimPlayerCard:setAlpha( 0 )
				f29_local10( VictimPlayerCard, {} )
				local f29_local11 = function ( f42_arg0, f42_arg1 )
					if not f42_arg1.interrupted then
						f42_arg0:beginAnimation( "keyframe", 699, true, true, CoD.TweenType.Bounce )
					end
					f42_arg0:setLeftRight( true, false, 198, 521 )
					f42_arg0:setTopBottom( true, false, 6, 65 )
					f42_arg0:setAlpha( 1 )
					if f42_arg1.interrupted then
						self.clipFinished( f42_arg0, f42_arg1 )
					else
						f42_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				AttackerPlayerCard:completeAnimation()
				self.AttackerPlayerCard:setLeftRight( true, false, 93, 360 )
				self.AttackerPlayerCard:setTopBottom( true, false, 6, 65 )
				self.AttackerPlayerCard:setAlpha( 0 )
				f29_local11( AttackerPlayerCard, {} )
				local f29_local12 = function ( f43_arg0, f43_arg1 )
					local f43_local0 = function ( f44_arg0, f44_arg1 )
						if not f44_arg1.interrupted then
							f44_arg0:beginAnimation( "keyframe", 280, false, false, CoD.TweenType.Linear )
						end
						f44_arg0:setAlpha( 1 )
						if f44_arg1.interrupted then
							self.clipFinished( f44_arg0, f44_arg1 )
						else
							f44_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f43_arg1.interrupted then
						f43_local0( f43_arg0, f43_arg1 )
						return 
					else
						f43_arg0:beginAnimation( "keyframe", 509, false, false, CoD.TweenType.Linear )
						f43_arg0:registerEventHandler( "transition_complete_keyframe", f43_local0 )
					end
				end
				
				KillsLabel2:completeAnimation()
				self.KillsLabel2:setAlpha( 0 )
				f29_local12( KillsLabel2, {} )
				local f29_local13 = function ( f45_arg0, f45_arg1 )
					local f45_local0 = function ( f46_arg0, f46_arg1 )
						if not f46_arg1.interrupted then
							f46_arg0:beginAnimation( "keyframe", 280, false, false, CoD.TweenType.Linear )
						end
						f46_arg0:setAlpha( 1 )
						if f46_arg1.interrupted then
							self.clipFinished( f46_arg0, f46_arg1 )
						else
							f46_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f45_arg1.interrupted then
						f45_local0( f45_arg0, f45_arg1 )
						return 
					else
						f45_arg0:beginAnimation( "keyframe", 509, false, false, CoD.TweenType.Linear )
						f45_arg0:registerEventHandler( "transition_complete_keyframe", f45_local0 )
					end
				end
				
				KillsLabel1:completeAnimation()
				self.KillsLabel1:setAlpha( 0 )
				f29_local13( KillsLabel1, {} )
				local f29_local14 = function ( f47_arg0, f47_arg1 )
					local f47_local0 = function ( f48_arg0, f48_arg1 )
						if not f48_arg1.interrupted then
							f48_arg0:beginAnimation( "keyframe", 280, false, false, CoD.TweenType.Linear )
						end
						f48_arg0:setAlpha( 1 )
						if f48_arg1.interrupted then
							self.clipFinished( f48_arg0, f48_arg1 )
						else
							f48_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f47_arg1.interrupted then
						f47_local0( f47_arg0, f47_arg1 )
						return 
					else
						f47_arg0:beginAnimation( "keyframe", 439, false, false, CoD.TweenType.Linear )
						f47_arg0:registerEventHandler( "transition_complete_keyframe", f47_local0 )
					end
				end
				
				AttackerKillsNew:completeAnimation()
				self.AttackerKillsNew:setAlpha( 0 )
				f29_local14( AttackerKillsNew, {} )
				local f29_local15 = function ( f49_arg0, f49_arg1 )
					local f49_local0 = function ( f50_arg0, f50_arg1 )
						if not f50_arg1.interrupted then
							f50_arg0:beginAnimation( "keyframe", 280, false, false, CoD.TweenType.Linear )
						end
						f50_arg0:setAlpha( 1 )
						if f50_arg1.interrupted then
							self.clipFinished( f50_arg0, f50_arg1 )
						else
							f50_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f49_arg1.interrupted then
						f49_local0( f49_arg0, f49_arg1 )
						return 
					else
						f49_arg0:beginAnimation( "keyframe", 509, false, false, CoD.TweenType.Linear )
						f49_arg0:registerEventHandler( "transition_complete_keyframe", f49_local0 )
					end
				end
				
				VictimKillsNew:completeAnimation()
				self.VictimKillsNew:setAlpha( 0 )
				f29_local15( VictimKillsNew, {} )
				local f29_local16 = function ( f51_arg0, f51_arg1 )
					local f51_local0 = function ( f52_arg0, f52_arg1 )
						if not f52_arg1.interrupted then
							f52_arg0:beginAnimation( "keyframe", 279, false, false, CoD.TweenType.Linear )
						end
						f52_arg0:setAlpha( 1 )
						if f52_arg1.interrupted then
							self.clipFinished( f52_arg0, f52_arg1 )
						else
							f52_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f51_arg1.interrupted then
						f51_local0( f51_arg0, f51_arg1 )
						return 
					else
						f51_arg0:beginAnimation( "keyframe", 600, false, false, CoD.TweenType.Linear )
						f51_arg0:registerEventHandler( "transition_complete_keyframe", f51_local0 )
					end
				end
				
				VSBanner:completeAnimation()
				self.VSBanner:setAlpha( 0 )
				f29_local16( VSBanner, {} )
				local f29_local17 = function ( f53_arg0, f53_arg1 )
					local f53_local0 = function ( f54_arg0, f54_arg1 )
						if not f54_arg1.interrupted then
							f54_arg0:beginAnimation( "keyframe", 280, false, false, CoD.TweenType.Linear )
						end
						f54_arg0:setAlpha( 1 )
						if f54_arg1.interrupted then
							self.clipFinished( f54_arg0, f54_arg1 )
						else
							f54_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
						end
					end
					
					if f53_arg1.interrupted then
						f53_local0( f53_arg0, f53_arg1 )
						return 
					else
						f53_arg0:beginAnimation( "keyframe", 649, false, false, CoD.TweenType.Linear )
						f53_arg0:registerEventHandler( "transition_complete_keyframe", f53_local0 )
					end
				end
				
				VSLabel:completeAnimation()
				self.VSLabel:setAlpha( 0 )
				f29_local17( VSLabel, {} )
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "Killcam",
			condition = function ( menu, element, event )
				local f55_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IN_KILLCAM )
				if f55_local0 then
					f55_local0 = not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM )
				end
				return f55_local0
			end
		},
		{
			stateName = "NemesisKillcam",
			condition = function ( menu, element, event )
				return Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM )
			end
		}
	} )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_KILLCAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_KILLCAM
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM
		} )
	end )
	LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller )
		if IsElementInState( element, "Killcam" ) then
			PlayClipOnElement( self, {
				elementName = "Glitch",
				clipName = "GlitchSmall1"
			}, controller )
		elseif IsElementInState( element, "NemesisKillcam" ) then
			PlayClipOnElement( self, {
				elementName = "Glitch",
				clipName = "GlitchSmall2"
			}, controller )
		end
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.LeftPanelR:close()
		element.LeftPanelR0:close()
		element.YouAndKillerWidget0:close()
		element.YouAndKillerWidget00:close()
		element.VictimPlayerCard:close()
		element.AttackerPlayerCard:close()
		element.AttackerKillsNew:close()
		element.VictimKillsNew:close()
		element.VSBanner:close()
		element.Glitch:close()
	end )	
	return self
end

CoD.KillcamWidgetPnlRTInt = InheritFrom( LUI.UIElement )
CoD.KillcamWidgetPnlRTInt.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.KillcamWidgetPnlRTInt )
	self.id = "KillcamWidgetPnlRTInt"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 144 )
	self:setTopBottom( true, false, 0, 80 )
	
	local Image0 = LUI.UIImage.new()
	Image0:setLeftRight( true, false, 0, 40 )
	Image0:setTopBottom( false, false, -40, 40 )
	Image0:setImage( RegisterImage( "uie_t7_mp_hud_engame_killcam_vsrightl" ) )
	Image0:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_scene_blur_pass_1" ) )
	Image0:setShaderVector( 0, 0, 20, 0, 0 )
	self:addElement( Image0 )
	self.Image0 = Image0
	
	local Image00 = LUI.UIImage.new()
	Image00:setLeftRight( true, true, 40, -32 )
	Image00:setTopBottom( false, false, -40, 40 )
	Image00:setImage( RegisterImage( "uie_t7_mp_hud_engame_killcam_vsrightm" ) )
	Image00:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_scene_blur_pass_1" ) )
	Image00:setShaderVector( 0, 0, 20, 0, 0 )
	self:addElement( Image00 )
	self.Image00 = Image00
	
	local Image1 = LUI.UIImage.new()
	Image1:setLeftRight( false, true, -32, 0 )
	Image1:setTopBottom( false, false, -40, 40 )
	Image1:setImage( RegisterImage( "uie_t7_mp_hud_engame_killcam_vsrightr" ) )
	Image1:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_scene_blur_pass_1" ) )
	Image1:setShaderVector( 0, 0, 20, 0, 0 )
	self:addElement( Image1 )
	self.Image1 = Image1
		
	return self
end

CoD.KillcamWidgetPnlRT = InheritFrom( LUI.UIElement )
CoD.KillcamWidgetPnlRT.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.KillcamWidgetPnlRT )
	self.id = "KillcamWidgetPnlRT"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 144 )
	self:setTopBottom( true, false, 0, 80 )
	
	local KillcamWidgetPnlRTInt0 = CoD.KillcamWidgetPnlRTInt.new( menu, controller )
	KillcamWidgetPnlRTInt0:setLeftRight( true, true, 0, 0 )
	KillcamWidgetPnlRTInt0:setTopBottom( false, false, -40, 40 )
	KillcamWidgetPnlRTInt0:setRFTMaterial( LUI.UIImage.GetCachedMaterial( "uie_scene_blur_pass_2_highquality" ) )
	KillcamWidgetPnlRTInt0:setShaderVector( 0, 0, 3, 0, 0 )
	self:addElement( KillcamWidgetPnlRTInt0 )
	self.KillcamWidgetPnlRTInt0 = KillcamWidgetPnlRTInt0
	
	local FactionColorBar = LUI.UIImage.new()
	FactionColorBar:setLeftRight( true, true, 36, -30 )
	FactionColorBar:setTopBottom( false, false, -40, -35 )
	FactionColorBar:setRGB( ColorSet.BadgeText.r, ColorSet.BadgeText.g, ColorSet.BadgeText.b )
	self:addElement( FactionColorBar )
	self.FactionColorBar = FactionColorBar
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 2 )
				FactionColorBar:completeAnimation()
				self.FactionColorBar:setAlpha( 0 )
				self.clipFinished( FactionColorBar, {} )
			end
		},
		CodCaster = {
			DefaultClip = function ()
				self:setupElementClipCounter( 2 )
				FactionColorBar:completeAnimation()
				self.FactionColorBar:setAlpha( 1 )
				self.clipFinished( FactionColorBar, {} )
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "CodCaster",
			condition = function ( menu, element, event )
				return Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_TEAM_SPECTATOR )
			end
		}
	} )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_TEAM_SPECTATOR ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_TEAM_SPECTATOR
		} )
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.KillcamWidgetPnlRTInt0:close()
	end )
	
	return self
end

CoD.YouAndKiller_Widget = InheritFrom( LUI.UIElement )
CoD.YouAndKiller_Widget.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.YouAndKiller_Widget )
	self.id = "YouAndKiller_Widget"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 200 )
	self:setTopBottom( true, false, 0, 26 )
	
	local topbarbg = LUI.UIImage.new()
	topbarbg:setLeftRight( true, true, 0, 0 )
	topbarbg:setTopBottom( true, true, 0, 0 )
	topbarbg:setImage( RegisterImage( "uie_img_t7_hud_widget_playercard_topbar_bg" ) )
	self:addElement( topbarbg )
	self.topbarbg = topbarbg
	
	local KillerYouLabels = LUI.UIText.new()
	KillerYouLabels:setLeftRight( true, false, 8, 195 )
	KillerYouLabels:setTopBottom( true, false, 5, 23 )
	KillerYouLabels:setText( Engine.Localize( "MENU_NEW" ) )
	KillerYouLabels:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
	KillerYouLabels:setLetterSpacing( 1 )
	KillerYouLabels:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	KillerYouLabels:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
	self:addElement( KillerYouLabels )
	self.KillerYouLabels = KillerYouLabels
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		Killcam = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		NemesisKillcam = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "Killcam",
			condition = function ( menu, element, event )
				local f5_local0 = Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_IN_KILLCAM )
				if f5_local0 then
					f5_local0 = not Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM )
				end
				return f5_local0
			end
		},
		{
			stateName = "NemesisKillcam",
			condition = function ( menu, element, event )
				return Engine.IsVisibilityBitSet( controller, Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM )
			end
		}
	} )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_KILLCAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_KILLCAM
		} )
	end )
	self:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM ), function ( modelRef )
		menu:updateElementState( self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_NEMESIS_KILLCAM
		} )
	end )	
	return self
end

CoD.KillcamWidgetNumbers = InheritFrom( LUI.UIElement )
CoD.KillcamWidgetNumbers.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.KillcamWidgetNumbers )
	self.id = "KillcamWidgetNumbers"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 160 )
	self:setTopBottom( true, false, 0, 70 )
	
	local Numbers = LUI.UIText.new()
	Numbers:setLeftRight( false, false, -80, 80 )
	Numbers:setTopBottom( true, true, 0, 0 )
	Numbers:setRGB( 0.59, 0.64, 0.74 )
	Numbers:setText( Engine.Localize( "0" ) )
	Numbers:setTTF( "fonts/FoundryGridnik-Bold.ttf" )
	Numbers:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	Numbers:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
	self:addElement( Numbers )
	self.Numbers = Numbers
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 0 )
			end,
			Start = function ()
				self:setupElementClipCounter( 1 )
				local f3_local0 = function ( f4_arg0, f4_arg1 )
					if not f4_arg1.interrupted then
						f4_arg0:beginAnimation( "keyframe", 259, false, false, CoD.TweenType.Linear )
					end
					f4_arg0:setAlpha( 1 )
					if f4_arg1.interrupted then
						self.clipFinished( f4_arg0, f4_arg1 )
					else
						f4_arg0:registerEventHandler( "transition_complete_keyframe", self.clipFinished )
					end
				end
				
				Numbers:completeAnimation()
				self.Numbers:setAlpha( 0 )
				f3_local0( Numbers, {} )
			end
		},
		WinTime = {
			DefaultClip = function ()
				self:setupElementClipCounter( 1 )
				Numbers:completeAnimation()
				self.Numbers:setRGB( 0.05, 1, 0 )
				self.Numbers:setAlpha( 0.7 )
				self.clipFinished( Numbers, {} )
			end
		},
		LossTime = {
			DefaultClip = function ()
				self:setupElementClipCounter( 1 )
				Numbers:completeAnimation()
				self.Numbers:setRGB( 1, 0.01, 0 )
				self.Numbers:setAlpha( 0.7 )
				self.clipFinished( Numbers, {} )
			end
		}
	}	
	return self
end

CoD.PlayerCard = InheritFrom( LUI.UIElement )
CoD.PlayerCard.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.PlayerCard )
	self.id = "PlayerCard"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 308 )
	self:setTopBottom( true, false, 0, 60 )
	self.anyChildUsesUpdateState = true
	
	local CallingCardsFrameWidget = CoD.CallingCards_FrameWidget.new( menu, controller )
	CallingCardsFrameWidget:setLeftRight( true, false, 92, 304 )
	CallingCardsFrameWidget:setTopBottom( true, false, 2, 57 )
	CallingCardsFrameWidget.CardIconFrame:setScale( 0.44 )
	CallingCardsFrameWidget:linkToElementModel( self, nil, false, function ( modelRef )
		CallingCardsFrameWidget:setModel( modelRef, controller )
	end )
	self:addElement( CallingCardsFrameWidget )
	self.CallingCardsFrameWidget = CallingCardsFrameWidget
	
	local LeftPanel = CoD.FE_ButtonPanelShaderContainer.new( menu, controller )
	LeftPanel:setLeftRight( true, false, 0, 91 )
	LeftPanel:setTopBottom( true, false, 2, 57 )
	LeftPanel:setRGB( 0.5, 0.5, 0.5 )
	self:addElement( LeftPanel )
	self.LeftPanel = LeftPanel
	
	local Top3PlayerScoreBlurBox0 = CoD.Top3PlayerScoreBlurBox.new( menu, controller )
	Top3PlayerScoreBlurBox0:setLeftRight( true, false, 0, 91 )
	Top3PlayerScoreBlurBox0:setTopBottom( true, false, 2, 57 )
	Top3PlayerScoreBlurBox0:setRFTMaterial( LUI.UIImage.GetCachedMaterial( "uie_scene_blur_pass_2" ) )
	Top3PlayerScoreBlurBox0:setShaderVector( 0, 10, 10, 0, 0 )
	self:addElement( Top3PlayerScoreBlurBox0 )
	self.Top3PlayerScoreBlurBox0 = Top3PlayerScoreBlurBox0
	
	local VSpanel = CoD.FE_ButtonPanel.new( menu, controller )
	VSpanel:setLeftRight( true, false, 0, 91 )
	VSpanel:setTopBottom( true, false, 2, 57 )
	VSpanel:setRGB( 0, 0, 0 )
	VSpanel:setAlpha( 0.5 )
	self:addElement( VSpanel )
	self.VSpanel = VSpanel
	
	local Panel = CoD.FE_PanelNoBlur.new( menu, controller )
	Panel:setLeftRight( true, false, 92.41, 136.41 )
	Panel:setTopBottom( true, false, 27, 47 )
	Panel:setRGB( 0, 0, 0 )
	Panel:setAlpha( 0.6 )
	self:addElement( Panel )
	self.Panel = Panel
	
	local GamerTag = CoD.PlayerCard_Label.new( menu, controller )
	GamerTag:setLeftRight( true, false, 92.41, 300.41 )
	GamerTag:setTopBottom( true, false, 5, 25 )
	GamerTag.Panel:setAlpha( 0.6 )
	GamerTag:linkToElementModel( self, "playerName", true, function ( modelRef )
		local playerName = Engine.GetModelValue( modelRef )
		if playerName then
			GamerTag:setAlpha( HideIfEmptyString( playerName ) )
		end
	end )
	GamerTag:linkToElementModel( self, nil, false, function ( modelRef )
		GamerTag:setModel( modelRef, controller )
	end )
	GamerTag:linkToElementModel( self, "playerName", true, function ( modelRef )
		local playerName = Engine.GetModelValue( modelRef )
		if playerName then
			GamerTag.itemName:setText( playerName )
		end
	end )
	LUI.OverrideFunction_CallOriginalFirst( GamerTag, "setText", function ( element, controller )
		ScaleWidgetToLabel( self, element, 1 )
	end )
	GamerTag:mergeStateConditions( {
		{
			stateName = "PlayerYellow",
			condition = function ( menu, element, event )
				return IsSelfModelValueMyXuidOrAnyLocalPlayerOnGameOver( element, controller, "xuid" )
			end
		}
	} )
	GamerTag:linkToElementModel( GamerTag, "xuid", true, function ( modelRef )
		menu:updateElementState( GamerTag, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "xuid"
		} )
	end )
	GamerTag:subscribeToModel( Engine.GetModel( Engine.GetModelForController( controller ), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED ), function ( modelRef )
		menu:updateElementState( GamerTag, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED
		} )
	end )
	self:addElement( GamerTag )
	self.GamerTag = GamerTag
	
	local ClanTag = CoD.PlayerCard_Label.new( menu, controller )
	ClanTag:setLeftRight( true, false, 92.41, 139.41 )
	ClanTag:setTopBottom( true, false, 26, 46 )
	ClanTag.Panel:setAlpha( 0.6 )
	ClanTag:linkToElementModel( self, "clanTag", true, function ( modelRef )
		local clanTag = Engine.GetModelValue( modelRef )
		if clanTag then
			ClanTag:setAlpha( HideIfEmptyString( clanTag ) )
		end
	end )
	ClanTag:linkToElementModel( self, "clanTag", true, function ( modelRef )
		local clanTag = Engine.GetModelValue( modelRef )
		if clanTag then
			ClanTag.itemName:setText( StringAsClanTag( clanTag ) )
		end
	end )
	LUI.OverrideFunction_CallOriginalFirst( ClanTag, "setText", function ( element, controller )
		ScaleWidgetToLabel( self, element, 1 )
	end )
	self:addElement( ClanTag )
	self.ClanTag = ClanTag
	
	local HeroBacking = LUI.UIImage.new()
	HeroBacking:setLeftRight( true, false, -2, 62 )
	HeroBacking:setTopBottom( true, false, -8, 64 )
	HeroBacking:setAlpha( 0 )
	HeroBacking:setImage( RegisterImage( "uie_img_t7_hud_widget_playercard_playerbacking" ) )
	HeroBacking:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
	self:addElement( HeroBacking )
	self.HeroBacking = HeroBacking
	
	local TeamColor = LUI.UIImage.new()
	TeamColor:setLeftRight( true, false, 31, 95 )
	TeamColor:setTopBottom( true, false, 2, 49 )
	TeamColor:setRGB( ColorSet.FriendlyBlue.r, ColorSet.FriendlyBlue.g, ColorSet.FriendlyBlue.b )
	TeamColor:setAlpha( 0 )
	TeamColor:setImage( RegisterImage( "uie_img_t7_hud_widget_playercard_playerbackingelements" ) )
	TeamColor:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
	self:addElement( TeamColor )
	self.TeamColor = TeamColor
	
	local HeroLobbyClientExtraCamRender = LUI.UIImage.new()
	HeroLobbyClientExtraCamRender:setLeftRight( true, false, 1, 59 )
	HeroLobbyClientExtraCamRender:setTopBottom( true, false, -9, 49 )
	HeroLobbyClientExtraCamRender:setAlpha( 0 )
	HeroLobbyClientExtraCamRender:linkToElementModel( self, "xuid", true, function ( modelRef )
		local xuid = Engine.GetModelValue( modelRef )
		if xuid then
			HeroLobbyClientExtraCamRender:setupCharacterExtraCamRenderForLobbyClient( xuid )
		end
	end )
	self:addElement( HeroLobbyClientExtraCamRender )
	self.HeroLobbyClientExtraCamRender = HeroLobbyClientExtraCamRender
	
	local RankIcon = LUI.UIImage.new()
	RankIcon:setLeftRight( true, false, 115.66, 131.66 )
	RankIcon:setTopBottom( true, false, 29, 45 )
	RankIcon:setAlpha( 0 )
	RankIcon:linkToElementModel( self, "rankIcon", true, function ( modelRef )
		local rankIcon = Engine.GetModelValue( modelRef )
		if rankIcon then
			RankIcon:setImage( RegisterImage( rankIcon ) )
		end
	end )
	self:addElement( RankIcon )
	self.RankIcon = RankIcon
	
	local Rank = LUI.UIText.new()
	Rank:setLeftRight( true, false, 94.41, 114.41 )
	Rank:setTopBottom( true, false, 26, 46 )
	Rank:setAlpha( 0 )
	Rank:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
	Rank:setLetterSpacing( 0.5 )
	Rank:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	Rank:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
	Rank:linkToElementModel( self, "rank", true, function ( modelRef )
		local rank = Engine.GetModelValue( modelRef )
		if rank then
			Rank:setText( Engine.Localize( rank ) )
		end
	end )
	self:addElement( Rank )
	self.Rank = Rank
	
	local CalloutHeading = LUI.UIText.new()
	CalloutHeading:setLeftRight( true, false, 94.41, 322 )
	CalloutHeading:setTopBottom( true, false, -16, 2 )
	CalloutHeading:setTTF( "fonts/escom.ttf" )
	CalloutHeading:setLetterSpacing( 0.5 )
	CalloutHeading:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
	CalloutHeading:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
	CalloutHeading:linkToElementModel( self, "heading", true, function ( modelRef )
		local heading = Engine.GetModelValue( modelRef )
		if heading then
			CalloutHeading:setText( Engine.Localize( heading ) )
		end
	end )
	self:addElement( CalloutHeading )
	self.CalloutHeading = CalloutHeading
	
	local PlayerEmblem = LUI.UIImage.new()
	PlayerEmblem:setLeftRight( true, false, 0, 91 )
	PlayerEmblem:setTopBottom( true, false, 2, 57 )
	PlayerEmblem:linkToElementModel( self, "xuid", true, function ( modelRef )
		local xuid = Engine.GetModelValue( modelRef )
		if xuid then
			PlayerEmblem:setupPlayerEmblemByXUID( xuid )
		end
	end )
	self:addElement( PlayerEmblem )
	self.PlayerEmblem = PlayerEmblem
	
	local StartMenuframenoBG0 = CoD.StartMenu_frame_noBG.new( menu, controller )
	StartMenuframenoBG0:setLeftRight( true, false, -2.59, 93.41 )
	StartMenuframenoBG0:setTopBottom( true, false, 0, 59 )
	StartMenuframenoBG0:setAlpha( 0.6 )
	self:addElement( StartMenuframenoBG0 )
	self.StartMenuframenoBG0 = StartMenuframenoBG0
	
	local StartMenuframenoBG1 = CoD.StartMenu_frame_noBG.new( menu, controller )
	StartMenuframenoBG1:setLeftRight( true, false, 88.41, 306.41 )
	StartMenuframenoBG1:setTopBottom( true, false, 0, 59 )
	StartMenuframenoBG1:setAlpha( 0.6 )
	self:addElement( StartMenuframenoBG1 )
	self.StartMenuframenoBG1 = StartMenuframenoBG1
	
	local Image00001 = LUI.UIImage.new()
	Image00001:setLeftRight( true, false, -19, -3 )
	Image00001:setTopBottom( true, false, -3, 5 )
	Image00001:setImage( RegisterImage( "uie_t7_menu_cac_pixelblurred" ) )
	Image00001:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( Image00001 )
	self.Image00001 = Image00001
	
	local Image2 = LUI.UIImage.new()
	Image2:setLeftRight( true, false, -19, -3 )
	Image2:setTopBottom( true, false, 53, 61 )
	Image2:setImage( RegisterImage( "uie_t7_menu_cac_pixelblurred" ) )
	Image2:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( Image2 )
	self.Image2 = Image2
	
	local Image000010 = LUI.UIImage.new()
	Image000010:setLeftRight( true, false, 306, 322 )
	Image000010:setTopBottom( true, false, -2, 6 )
	Image000010:setZRot( 180 )
	Image000010:setImage( RegisterImage( "uie_t7_menu_cac_pixelblurred" ) )
	Image000010:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( Image000010 )
	self.Image000010 = Image000010
	
	local Image20 = LUI.UIImage.new()
	Image20:setLeftRight( true, false, 306, 322 )
	Image20:setTopBottom( true, false, 53, 61 )
	Image20:setZRot( 180 )
	Image20:setImage( RegisterImage( "uie_t7_menu_cac_pixelblurred" ) )
	Image20:setMaterial( LUI.UIImage.GetCachedMaterial( "ui_add" ) )
	self:addElement( Image20 )
	self.Image20 = Image20
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 8 )
				CallingCardsFrameWidget:completeAnimation()
				self.CallingCardsFrameWidget:setLeftRight( true, false, 92, 304 )
				self.CallingCardsFrameWidget:setTopBottom( true, false, 2, 57 )
				self.clipFinished( CallingCardsFrameWidget, {} )
				HeroBacking:completeAnimation()
				self.HeroBacking:setAlpha( 0 )
				self.clipFinished( HeroBacking, {} )
				HeroLobbyClientExtraCamRender:completeAnimation()
				self.HeroLobbyClientExtraCamRender:setAlpha( 0 )
				self.clipFinished( HeroLobbyClientExtraCamRender, {} )
				CalloutHeading:completeAnimation()
				self.CalloutHeading:setLeftRight( true, false, 93.41, 365 )
				self.CalloutHeading:setTopBottom( true, false, -16, 2 )
				self.clipFinished( CalloutHeading, {} )
				PlayerEmblem:completeAnimation()
				self.PlayerEmblem:setAlpha( 1 )
				self.clipFinished( PlayerEmblem, {} )
				StartMenuframenoBG1:completeAnimation()
				self.StartMenuframenoBG1:setLeftRight( true, false, 89.41, 305.41 )
				self.StartMenuframenoBG1:setTopBottom( true, false, 0, 59 )
				self.clipFinished( StartMenuframenoBG1, {} )
				Image000010:completeAnimation()
				self.Image000010:setLeftRight( true, false, 306, 322 )
				self.Image000010:setTopBottom( true, false, -2, 6 )
				self.clipFinished( Image000010, {} )
				Image20:completeAnimation()
				self.Image20:setLeftRight( true, false, 306, 322 )
				self.Image20:setTopBottom( true, false, 53, 61 )
				self.clipFinished( Image20, {} )
			end,
			Side = function ()
				self:setupElementClipCounter( 0 )
			end
		},
		Emblem = {
			DefaultClip = function ()
				self:setupElementClipCounter( 13 )
				CallingCardsFrameWidget:completeAnimation()
				self.CallingCardsFrameWidget:setLeftRight( true, false, 92, 304 )
				self.CallingCardsFrameWidget:setTopBottom( true, false, 2, 57 )
				self.clipFinished( CallingCardsFrameWidget, {} )
				LeftPanel:completeAnimation()
				self.LeftPanel:setLeftRight( true, false, 0, 91 )
				self.LeftPanel:setTopBottom( true, false, 2.5, 56.5 )
				self.LeftPanel:setAlpha( 1 )
				self.clipFinished( LeftPanel, {} )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setAlpha( 1 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				VSpanel:completeAnimation()
				self.VSpanel:setAlpha( 0.5 )
				self.clipFinished( VSpanel, {} )
				Panel:completeAnimation()
				self.Panel:setAlpha( 0 )
				self.clipFinished( Panel, {} )
				HeroBacking:completeAnimation()
				self.HeroBacking:setAlpha( 0 )
				self.clipFinished( HeroBacking, {} )
				TeamColor:completeAnimation()
				self.TeamColor:setAlpha( 0 )
				self.clipFinished( TeamColor, {} )
				HeroLobbyClientExtraCamRender:completeAnimation()
				self.HeroLobbyClientExtraCamRender:setLeftRight( true, false, 8, 66 )
				self.HeroLobbyClientExtraCamRender:setTopBottom( true, false, -9, 49 )
				self.HeroLobbyClientExtraCamRender:setAlpha( 0 )
				self.clipFinished( HeroLobbyClientExtraCamRender, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setAlpha( 0 )
				self.clipFinished( RankIcon, {} )
				PlayerEmblem:completeAnimation()
				self.PlayerEmblem:setAlpha( 1 )
				self.clipFinished( PlayerEmblem, {} )
				StartMenuframenoBG1:completeAnimation()
				self.StartMenuframenoBG1:setLeftRight( true, false, 89.41, 306 )
				self.StartMenuframenoBG1:setTopBottom( true, false, 0, 59 )
				self.clipFinished( StartMenuframenoBG1, {} )
				Image000010:completeAnimation()
				self.Image000010:setLeftRight( true, false, 306, 322 )
				self.Image000010:setTopBottom( true, false, -2, 6 )
				self.clipFinished( Image000010, {} )
				Image20:completeAnimation()
				self.Image20:setLeftRight( true, false, 306, 322 )
				self.Image20:setTopBottom( true, false, 53, 61 )
				self.clipFinished( Image20, {} )
			end
		},
		Calingcard = {
			DefaultClip = function ()
				self:setupElementClipCounter( 20 )
				CallingCardsFrameWidget:completeAnimation()
				self.CallingCardsFrameWidget:setLeftRight( true, false, 1.59, 213.59 )
				self.CallingCardsFrameWidget:setTopBottom( true, false, 2, 57 )
				self.clipFinished( CallingCardsFrameWidget, {} )
				LeftPanel:completeAnimation()
				self.LeftPanel:setAlpha( 0 )
				self.clipFinished( LeftPanel, {} )
				Top3PlayerScoreBlurBox0:completeAnimation()
				self.Top3PlayerScoreBlurBox0:setAlpha( 0 )
				self.clipFinished( Top3PlayerScoreBlurBox0, {} )
				VSpanel:completeAnimation()
				self.VSpanel:setAlpha( 0 )
				self.clipFinished( VSpanel, {} )
				Panel:completeAnimation()
				self.Panel:setLeftRight( true, false, 91, 135 )
				self.Panel:setTopBottom( true, false, 27, 47 )
				self.Panel:setAlpha( 0 )
				self.clipFinished( Panel, {} )
				GamerTag:completeAnimation()
				self.GamerTag:setLeftRight( true, false, 2, 205 )
				self.GamerTag:setTopBottom( true, false, 5, 25 )
				self.clipFinished( GamerTag, {} )
				ClanTag:completeAnimation()
				self.ClanTag:setLeftRight( true, false, 2, 49 )
				self.ClanTag:setTopBottom( true, false, 26, 46 )
				self.clipFinished( ClanTag, {} )
				HeroBacking:completeAnimation()
				self.HeroBacking:setLeftRight( true, false, -3.41, 60.59 )
				self.HeroBacking:setTopBottom( true, false, -8, 64 )
				self.HeroBacking:setAlpha( 0 )
				self.clipFinished( HeroBacking, {} )
				TeamColor:completeAnimation()
				self.TeamColor:setLeftRight( true, false, 29.59, 93.59 )
				self.TeamColor:setTopBottom( true, false, 2, 49 )
				self.TeamColor:setAlpha( 0 )
				self.clipFinished( TeamColor, {} )
				HeroLobbyClientExtraCamRender:completeAnimation()
				self.HeroLobbyClientExtraCamRender:setLeftRight( true, false, -0.41, 57.59 )
				self.HeroLobbyClientExtraCamRender:setTopBottom( true, false, -9, 49 )
				self.HeroLobbyClientExtraCamRender:setAlpha( 0 )
				self.clipFinished( HeroLobbyClientExtraCamRender, {} )
				RankIcon:completeAnimation()
				self.RankIcon:setLeftRight( true, false, 114.25, 130.25 )
				self.RankIcon:setTopBottom( true, false, 29, 45 )
				self.RankIcon:setAlpha( 0 )
				self.clipFinished( RankIcon, {} )
				Rank:completeAnimation()
				self.Rank:setLeftRight( true, false, 5, 25 )
				self.Rank:setTopBottom( true, false, 26, 46 )
				self.Rank:setAlpha( 0 )
				self.clipFinished( Rank, {} )
				CalloutHeading:completeAnimation()
				self.CalloutHeading:setLeftRight( true, false, 2, 213.59 )
				self.CalloutHeading:setTopBottom( true, false, -17, 1 )
				self.clipFinished( CalloutHeading, {} )
				PlayerEmblem:completeAnimation()
				self.PlayerEmblem:setAlpha( 0 )
				self.clipFinished( PlayerEmblem, {} )
				StartMenuframenoBG0:completeAnimation()
				self.StartMenuframenoBG0:setLeftRight( true, false, -4, 92 )
				self.StartMenuframenoBG0:setTopBottom( true, false, 0, 59 )
				self.StartMenuframenoBG0:setAlpha( 0 )
				self.clipFinished( StartMenuframenoBG0, {} )
				StartMenuframenoBG1:completeAnimation()
				self.StartMenuframenoBG1:setLeftRight( true, false, -1, 215.59 )
				self.StartMenuframenoBG1:setTopBottom( true, false, 0, 59 )
				self.clipFinished( StartMenuframenoBG1, {} )
				Image00001:completeAnimation()
				self.Image00001:setLeftRight( true, false, -15.41, 0.59 )
				self.Image00001:setTopBottom( true, false, -3, 5 )
				self.clipFinished( Image00001, {} )
				Image2:completeAnimation()
				self.Image2:setLeftRight( true, false, -15.41, 0.59 )
				self.Image2:setTopBottom( true, false, 53, 61 )
				self.clipFinished( Image2, {} )
				Image000010:completeAnimation()
				self.Image000010:setLeftRight( true, false, 215.59, 231.59 )
				self.Image000010:setTopBottom( true, false, -2, 6 )
				self.clipFinished( Image000010, {} )
				Image20:completeAnimation()
				self.Image20:setLeftRight( true, false, 215.59, 231.59 )
				self.Image20:setTopBottom( true, false, 53, 61 )
				self.clipFinished( Image20, {} )
			end
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "Emblem",
			condition = function ( menu, element, event )
				return AlwaysTrue()
			end
		},
		{
			stateName = "Calingcard",
			condition = function ( menu, element, event )
				return true
			end
		}
	} )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.CallingCardsFrameWidget:close()
		element.LeftPanel:close()
		element.Top3PlayerScoreBlurBox0:close()
		element.VSpanel:close()
		element.Panel:close()
		element.GamerTag:close()
		element.ClanTag:close()
		element.StartMenuframenoBG0:close()
		element.StartMenuframenoBG1:close()
		element.HeroLobbyClientExtraCamRender:close()
		element.RankIcon:close()
		element.Rank:close()
		element.CalloutHeading:close()
		element.PlayerEmblem:close()
	end )
	
	return self
end

CoD.PlayerCard_Label = InheritFrom( LUI.UIElement )
CoD.PlayerCard_Label.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.PlayerCard_Label )
	self.id = "PlayerCard_Label"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 86 )
	self:setTopBottom( true, false, 0, 20 )
	
	local Panel = CoD.FE_PanelNoBlur.new( menu, controller )
	Panel:setLeftRight( true, true, 0, 0 )
	Panel:setTopBottom( true, true, 0, 0 )
	Panel:setRGB( 0, 0, 0 )
	Panel:setAlpha( 0.4 )
	self:addElement( Panel )
	self.Panel = Panel
	
	local itemName = LUI.UIText.new()
	itemName:setLeftRight( true, false, 4.18, 270 )
	itemName:setTopBottom( false, false, -10, 10 )
	itemName:setTTF( "fonts/RefrigeratorDeluxe-Regular.ttf" )
	itemName:setLetterSpacing( 0.5 )
	itemName:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_LEFT )
	itemName:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_TOP )
	itemName:linkToElementModel( self, "name", true, function ( modelRef )
		local name = Engine.GetModelValue( modelRef )
		if name then
			itemName:setText( name )
		end
	end )
	LUI.OverrideFunction_CallOriginalFirst( itemName, "setText", function ( element, controller )
		ScaleWidgetToLabel( self, element, 1 )
	end )
	self:addElement( itemName )
	self.itemName = itemName
	
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = function ()
				self:setupElementClipCounter( 1 )
				itemName:completeAnimation()
				self.itemName:setRGB( 1, 1, 1 )
				self.clipFinished( itemName, {} )
			end
		},
		PlayerYellow = {
			DefaultClip = function ()
				self:setupElementClipCounter( 1 )
				itemName:completeAnimation()
				self.itemName:setRGB( ColorSet.PlayerYellow.r, ColorSet.PlayerYellow.g, ColorSet.PlayerYellow.b )
				self.clipFinished( itemName, {} )
			end
		}
	}
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.Panel:close()
		element.itemName:close()
	end )	
	return self
end

local CallingCards_FrameWidgetPostLoadFunc = function ( self, controller, menu )
	local f1_local0 = {
		"iconId",
		"emblemBacking",
		"backgroundId",
		"selectedBg",
		"identityBadge.xuid"
	}
	self.CardIconFrame.m_preventFromBeingActive = true
	self.CardIconFrame:linkToElementModel( self, nil, true, function ( modelRef )
		if self.backingSubscription ~= nil then
			self:removeSubscription( self.backingSubscription )
		end
		for f2_local0 = 1, #f1_local0, 1 do
			local f2_local3 = f1_local0[f2_local0]
			local f2_local4 = Engine.GetModel( modelRef, f2_local3 )
			if f2_local4 then
				self.backingSubscription = self:subscribeToModel( f2_local4, function ( modelRef )
					local modelValue = Engine.GetModelValue( modelRef )
					if f2_local3 == "identityBadge.xuid" then
						modelValue = GetPlayerBackground( controller, modelValue )
					end
					if modelValue then
						CoD.ChallengesUtility.SetCallingCardForWidget( self.CardIconFrame, GetBackgroundByID( modelValue ), menu.id )
					end
				end )
				break
			end
		end
	end )
end

CoD.CallingCards_FrameWidget = InheritFrom( LUI.UIElement )
CoD.CallingCards_FrameWidget.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.CallingCards_FrameWidget )
	self.id = "CallingCards_FrameWidget"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 480 )
	self:setTopBottom( true, false, 0, 120 )
	self.anyChildUsesUpdateState = true
	
	local CardIconFrame = LUI.UIFrame.new( menu, controller, 0, 0, false )
	CardIconFrame:setLeftRight( false, false, -240, 240 )
	CardIconFrame:setTopBottom( false, false, -60, 60 )
	CardIconFrame:changeFrameWidget( CoD.CallingCards_BasicImage )
	CardIconFrame:linkToElementModel( self, nil, false, function ( modelRef )
		CardIconFrame:setModel( modelRef, controller )
	end )
	self:addElement( CardIconFrame )
	self.CardIconFrame = CardIconFrame
	
	CardIconFrame.id = "CardIconFrame"
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.CardIconFrame:close()
	end )
	
	if CallingCards_FrameWidgetPostLoadFunc then
		CallingCards_FrameWidgetPostLoadFunc( self, controller, menu )
	end
	
	return self
end

CoD.CallingCards_BasicImage = InheritFrom( LUI.UIElement )
CoD.CallingCards_BasicImage.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	self:setUseStencil( false )
	self:setClass( CoD.CallingCards_BasicImage )
	self.id = "CallingCards_BasicImage"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 480 )
	self:setTopBottom( true, false, 0, 120 )
	
	local CardIcon = LUI.UIImage.new()
	CardIcon:setLeftRight( true, true, 0, 0 )
	CardIcon:setTopBottom( true, true, 0, 0 )
	CardIcon:setImage( RegisterImage( "uie_t7_icon_callingcard_temp2_lrg" ) )
	CardIcon:setMaterial( LUI.UIImage.GetCachedMaterial( "uie_feather_blend" ) )
	self:addElement( CardIcon )
	self.CardIcon = CardIcon
	
	return self
end


if not CoD.isFrontend then

	CoD.zbr_setup_counters = function(active_hud, controller)
		require( "ui.uieditor.widgets.HUD.ZM_Revive.ZM_ReviveBleedoutRedEyeGlow" )
		require( "ui.uieditor.widgets.HUD.core_AmmoWidget.AmmoWidget_AbilityGlow" )
	end

end

CoD.ScoreboardUtility.SetScoreboardUIModels = function ( f5_arg0 )
	local f5_local0 = Engine.GetCurrentTeamCount()
	local f5_local1 = Engine.GetModelForController( f5_arg0 )
	local f5_local2 = Engine.CreateModel( f5_local1, "scoreboardInfo" )
	local f5_local3 = Engine.CreateModel( Engine.GetModelForController( 0 ), "scoreboardInfo" )
	if not Engine.GetModel( f5_local1, "forceScoreboard" ) then
		Engine.SetModelValue( Engine.CreateModel( f5_local1, "forceScoreboard" ), 0 )
	end
	Engine.SetModelValue( Engine.CreateModel( Engine.GetModelForController( f5_arg0 ), "updateClientDeadStatus" ), 0 )
	Engine.SetModelValue( Engine.CreateModel( f5_local2, "muteButtonPromptVisible" ), false )
	Engine.SetModelValue( Engine.CreateModel( f5_local2, "muteButtonPromptText" ), "" )
	local f5_local4 = "ZOMBIE BLOOD RUSH" -- CoD.GetMapValue( Engine.GetCurrentMapName(), "mapNameCaps", "" )
	Engine.SetModelValue( Engine.CreateModel( f5_local2, "mapName" ), f5_local4 )
	Engine.SetModelValue( Engine.CreateModel( f5_local3, "mapName" ), f5_local4 )
	if Engine.IsMultiplayerGame() then
		if not Engine.IsInGame() then
			CoD.ScoreboardUtility.SetNemesisInfoModels( f5_arg0, f5_local2 )
		end
		local f5_local5 = Engine.GetTeamPositions( f5_arg0, f5_local0 )
		local f5_local6 = {}
		for f5_local7 = 1, f5_local0, 1 do
			local f5_local10 = {}
			local f5_local11 = f5_local5[f5_local7].team
			f5_local10.FactionName = ""
			f5_local10.FactionIcon = ""
			f5_local10.Score = f5_local5[f5_local7].score
			if f5_local11 ~= Enum.team_t.TEAM_FREE then
				f5_local10.FactionName = CoD.GetTeamNameCaps( f5_local11 )
				f5_local10.FactionIcon = CoD.GetTeamFactionIcon( f5_local11 )
				f5_local10.FactionColor = CoD.GetTeamFactionColor( f5_local11 )
			end
			table.insert( f5_local6, f5_local10 )
		end
		for f5_local15, f5_local10 in ipairs( f5_local6 ) do
			for f5_local12, f5_local13 in pairs( f5_local10 ) do
				Engine.SetModelValue( Engine.CreateModel( f5_local2, "team" .. f5_local15 .. f5_local12 ), f5_local13 )
			end
		end
		f5_local7 = Engine.StructTableLookupString( CoDShared.gametypesStructTable, "name", Engine.GetCurrentGameType(), "name_ref_caps" )
		Engine.SetModelValue( Engine.CreateModel( f5_local2, "gameType" ), f5_local7 )
		Engine.SetModelValue( Engine.CreateModel( f5_local3, "gameType" ), f5_local7 )
		if f5_local0 < 2 then
			f5_local8 = Engine.GetModel( f5_local1, "gameScore.playerScore" )
			if f5_local8 then
				Engine.SetModelValue( Engine.CreateModel( f5_local2, "team1Score" ), Engine.GetModelValue( f5_local8 ) )
			else
				local f5_local5 = 5
				for f5_local6 = 1, f5_local5, 1 do
					Engine.SetModelValue( Engine.CreateModel( f5_local2, "column" .. f5_local6 .. "Header" ), Engine.GetScoreboardColumnHeader( f5_arg0, f5_local6 - 1 ) )
				end
			end
		else
			local f5_local5 = 5
			for f5_local6 = 1, f5_local5, 1 do
				Engine.SetModelValue( Engine.CreateModel( f5_local2, "column" .. f5_local6 .. "Header" ), Engine.GetScoreboardColumnHeader( f5_arg0, f5_local6 - 1 ) )
			end
		end
	end
	local f5_local5 = 5
	for f5_local6 = 1, f5_local5, 1 do
		Engine.SetModelValue( Engine.CreateModel( f5_local2, "column" .. f5_local6 .. "Header" ), Engine.GetScoreboardColumnHeader( f5_arg0, f5_local6 - 1 ) )
	end
end

Engine.SetDvar("sv_cheats", 0);

LocalizeToUpperStringOld = LocalizeToUpperString
function LocalizeToUpperString(str)
	if str == "MENU_CONTENT_FILTER" then
		return "ZOMBIE BLOOD RUSH"
	end
	return LocalizeToUpperStringOld(str)
end