require( "ui.uieditor.widgets.BackgroundFrames.GenericMenuFrame" )
require( "ui.uieditor.widgets.StartMenu.StartMenu_lineGraphics_Options" )
require( "ui.uieditor.widgets.PC.StartMenu.Dropdown.OptionDropdown" )
require( "ui.uieditor.widgets.PC.Utility.OptionInfoWidget" )
require( "ui.uieditor.widgets.StartMenu.StartMenu_Options_Button" )
require( "ui.uieditor.widgets.StartMenu.StartMenu_Options_SliderBar" )

local OptionsZBRGenericDropdownProperties = {
	dropDownItemSelected = CoD.PCUtil.OptionsDropdownItemSelected,
	dropDownRefresh = CoD.PCUtil.OptionsDropdownRefresh,
	dropDownCurrentValue = CoD.PCUtil.OptionsDropdownCurrentValue
}

DataSources.OptionZBRSpawnGuns = DataSourceHelpers.ListSetup( "PC.OptionZBRSpawnGuns", function ( f1_arg0 )
	local f1_local0 = {}
	table.insert( f1_local0, {
		models = {
			value = 0,
			valueDisplay = "RK5"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 1,
			valueDisplay = "Knife"
		}
	} )
	
	return f1_local0
end, true )

DataSources.OptionZBRCharacterIndex = DataSourceHelpers.ListSetup( "PC.OptionZBRCharacterIndex", function ( f1_arg0 )
	local f1_local0 = {}
	table.insert( f1_local0, {
		models = {
			value = -1,
			valueDisplay = "Default"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 0,
			valueDisplay = "Battery"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 1,
			valueDisplay = "Ruin"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 2,
			valueDisplay = "Capybara"
		}
	} )

	table.insert( f1_local0, {
		models = {
			value = -10,
			valueDisplay = "Nero"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = -9,
			valueDisplay = "Jessica"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = -8,
			valueDisplay = "Jack"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = -7,
			valueDisplay = "Floyd"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = -5,
			valueDisplay = "Takeo"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = -4,
			valueDisplay = "Richtofen"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = -3,
			valueDisplay = "Nikolai"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = -2,
			valueDisplay = "Dempsey"
		}
	} )
	return f1_local0
end, true )

DataSources.OptionZBRHat = DataSourceHelpers.ListSetup( "PC.OptionZBRHat", function ( f1_arg0 )
	local f1_local0 = {}
	table.insert( f1_local0, {
		models = {
			value = 0,
			valueDisplay = "None"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 1,
			valueDisplay = "Top Hat"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 2,
			valueDisplay = "Snapback"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 3,
			valueDisplay = "Krusty Krab"
		}
	} )
	
	return f1_local0
end, true )

DataSources.OptionZBRDamageNumberse = DataSourceHelpers.ListSetup( "PC.OptionZBRDamageNumberse", function ( f1_arg0 )
	local f1_local0 = {}
	table.insert( f1_local0, {
		models = {
			value = 0,
			valueDisplay = "Disabled"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 1,
			valueDisplay = "Enabled"
		}
	} )
	
	return f1_local0
end, true )

DataSources.OptionZBRFavoriteEmote = DataSourceHelpers.ListSetup( "PC.OptionZBRFavoriteEmote", function ( f1_arg0 )
	local f1_local0 = {}
	table.insert( f1_local0, {
		models = {
			value = -1,
			valueDisplay = "None"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 0,
			valueDisplay = "Clucked Up"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 1,
			valueDisplay = "Heart Attack"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 2,
			valueDisplay = "Chickens Don't Dance"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 3,
			valueDisplay = "Dip Low"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 4,
			valueDisplay = "Disconnected"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 5,
			valueDisplay = "Finger Wag"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 6,
			valueDisplay = "Gun Show"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 7,
			valueDisplay = "Hail Seizure"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 8,
			valueDisplay = "King Kong"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 9,
			valueDisplay = "Laughing at You"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 10,
			valueDisplay = "Make it Rain"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 11,
			valueDisplay = "Poplock"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 12,
			valueDisplay = "Swervin"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 13,
			valueDisplay = "Shrug"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 14,
			valueDisplay = "So Fresh"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 15,
			valueDisplay = "Three Amigos"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 16,
			valueDisplay = "Yoggin'"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 17,
			valueDisplay = "Bow"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 18,
			valueDisplay = "Bunny Hop"
		}
	} )
	table.insert( f1_local0, {
		models = {
			value = 19,
			valueDisplay = "Back Flip"
		}
	} )
	
	return f1_local0
end, true )


DataSources.OptionGraphicContentPC = DataSourceHelpers.ListSetup( "PC.OptionGraphicContentPC", function ( f3_arg0 )
	local f3_local0 = {}

	if not IsInGame() then
		table.insert( f3_local0, {
			models = {
				label = "Spawn Weapon",
				description = "Choose the second gun you spawn with.",
				profileVarName = "spawnweapon",
				profileType = "function",
				widgetType = "dropdown",
				datasource = "OptionZBRSpawnGuns",
				getFunction = function ( controller )
					return ZBR.GetProfileValue("spawnweapon")
				end,
				setFunction = function ( controller, val )
					ZBR.SetProfileValue("spawnweapon", val)
				end
			},
			properties = OptionsZBRGenericDropdownProperties
		} )
	end

	if not IsInGame() then
		table.insert( f3_local0, {
			models = {
				label = "Custom Character",
				description = "If anything except default, this character will be equipped in all games played.",
				profileVarName = "zbr_character",
				profileType = "function",
				widgetType = "dropdown",
				datasource = "OptionZBRCharacterIndex",
				getFunction = function ( controller )
					return ZBR.GetProfileValue("character")
				end,
				setFunction = function ( controller, val )
					ZBR.SetProfileValue("character", val)
					Engine.SendClientScriptNotify(controller, "zbr_character_change", val);
				end
			},
			properties = OptionsZBRGenericDropdownProperties
		} )
	end

	if not IsInGame() then
		table.insert( f3_local0, {
			models = {
				label = "Hat",
				description = "Select a hat for your character.",
				profileVarName = "zbr_hat",
				profileType = "function",
				widgetType = "dropdown",
				datasource = "OptionZBRHat",
				getFunction = function ( controller )
					return ZBR.GetProfileValue("hat")
				end,
				setFunction = function ( controller, val )
					ZBR.SetProfileValue("hat", val)
					Engine.SendClientScriptNotify(controller, "zbr_character_change", ZBR.GetProfileValue("character"));
				end
			},
			properties = OptionsZBRGenericDropdownProperties
		} )
	end

	table.insert( f3_local0, {
		models = {
			label = "3D Damage Numbers",
			description = "Toggle the 3d damage numbers seen in game.",
			profileVarName = "zbr_3ddmg",
			profileType = "function",
			widgetType = "dropdown",
			datasource = "OptionZBRDamageNumberse",
            getFunction = function ( controller )
				return ZBR.GetProfileValue("b_damagenumbers")
			end,
			setFunction = function ( controller, val )
				ZBR.SetProfileValue("b_damagenumbers", val)
			end
		},
		properties = OptionsZBRGenericDropdownProperties
	} )

	table.insert( f3_local0, {
		models = {
			label = "Favorite Emote",
			description = "Choose the emote bound to your tilde key.",
			profileVarName = "favorite_emote",
			profileType = "function",
			widgetType = "dropdown",
			datasource = "OptionZBRFavoriteEmote",
            getFunction = function ( controller )
				return ZBR.GetProfileValue("favorite_emote")
			end,
			setFunction = function ( controller, val )
				ZBR.SetProfileValue("favorite_emote", val)
			end
		},
		properties = OptionsZBRGenericDropdownProperties
	} )

	table.insert( f3_local0, {
		models = {
			label = "Emote 1 [7]",
			description = "Choose the emote bound to the '7' key.",
			profileVarName = "emote1",
			profileType = "function",
			widgetType = "dropdown",
			datasource = "OptionZBRFavoriteEmote",
            getFunction = function ( controller )
				return ZBR.GetProfileValue("emote1")
			end,
			setFunction = function ( controller, val )
				ZBR.SetProfileValue("emote1", val)
			end
		},
		properties = OptionsZBRGenericDropdownProperties
	} )

	table.insert( f3_local0, {
		models = {
			label = "Emote 2 [8]",
			description = "Choose the emote bound to the '8' key.",
			profileVarName = "emote2",
			profileType = "function",
			widgetType = "dropdown",
			datasource = "OptionZBRFavoriteEmote",
            getFunction = function ( controller )
				return ZBR.GetProfileValue("emote2")
			end,
			setFunction = function ( controller, val )
				ZBR.SetProfileValue("emote2", val)
			end
		},
		properties = OptionsZBRGenericDropdownProperties
	} )

	table.insert( f3_local0, {
		models = {
			label = "Emote 3 [9]",
			description = "Choose the emote bound to the '9' key.",
			profileVarName = "emote3",
			profileType = "function",
			widgetType = "dropdown",
			datasource = "OptionZBRFavoriteEmote",
            getFunction = function ( controller )
				return ZBR.GetProfileValue("emote3")
			end,
			setFunction = function ( controller, val )
				ZBR.SetProfileValue("emote3", val)
			end
		},
		properties = OptionsZBRGenericDropdownProperties
	} )

	table.insert( f3_local0, {
		models = {
			label = "Emote 4 [0]",
			description = "Choose the emote bound to the '0' key.",
			profileVarName = "emote4",
			profileType = "function",
			widgetType = "dropdown",
			datasource = "OptionZBRFavoriteEmote",
            getFunction = function ( controller )
				return ZBR.GetProfileValue("emote4")
			end,
			setFunction = function ( controller, val )
				ZBR.SetProfileValue("emote4", val)
			end
		},
		properties = OptionsZBRGenericDropdownProperties
	} )

	return f3_local0
end, true )

DataSources.OptionGraphicContentPC.getWidgetTypeForItem = function ( f4_arg0, f4_arg1, f4_arg2 )
	if f4_arg1 then
		local f4_local0 = Engine.GetModelValue( Engine.GetModel( f4_arg1, "widgetType" ) )
		if f4_local0 == "dropdown" then
			return CoD.OptionDropdown
		elseif f4_local0 == "slider" then
			return CoD.StartMenu_Options_SliderBar
		elseif f4_local0 == "button" then
			return CoD.StartMenu_Options_Button
		end
	end
	return nil
end

local PostLoadFunc = function ( f5_arg0, f5_arg1 )
	f5_arg0:dispatchEventToChildren( {
		name = "options_refresh",
		controller = f5_arg1
	} )
	f5_arg0.graphicsList.m_managedItemPriority = true
	f5_arg0:registerEventHandler( "dropdown_triggered", function ( element, event )
		for f6_local0 = 1, element.graphicsList.requestedRowCount, 1 do
			local f6_local3 = element.graphicsList:getItemAtPosition( f6_local0, 1 )
			f6_local3.m_inputDisabled = nil
			if event.inUse then
				if f6_local3 ~= event.widget then
					f6_local3.m_inputDisabled = true
				end
			end
		end
	end )
end

LUI.createMenu.StartMenu_Options_GraphicContent_PC = function ( controller )
	local self = CoD.Menu.NewForUIEditor( "StartMenu_Options_GraphicContent_PC" )
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
	self.soundSet = "ChooseDecal"
	self:setOwner( controller )
	self:setLeftRight( true, true, 0, 0 )
	self:setTopBottom( true, true, 0, 0 )
	self:playSound( "menu_open", controller )
	self.buttonModel = Engine.CreateModel( Engine.GetModelForController( controller ), "StartMenu_Options_GraphicContent_PC.buttonPrompts" )
	self.anyChildUsesUpdateState = true
	
	local Background = LUI.UIImage.new()
	Background:setLeftRight( true, false, 0, 1280 )
	Background:setTopBottom( true, false, 0, 720 )
	Background:setRGB( 0.06, 0.06, 0.06 )
	self:addElement( Background )
	self.Background = Background
	
	local MenuFrame = CoD.GenericMenuFrame.new( self, controller )
	MenuFrame:setLeftRight( true, true, 0, 0 )
	MenuFrame:setTopBottom( true, true, 0, 0 )
	MenuFrame.titleLabel:setText( Engine.Localize( LocalizeToUpperString( "MENU_CONTENT_FILTER" ) ) )
	MenuFrame.cac3dTitleIntermediary0.FE3dTitleContainer0.MenuTitle.TextBox1.Label0:setText( Engine.Localize( LocalizeToUpperString( "MENU_CONTENT_FILTER" ) ) )
	MenuFrame.cac3dTitleIntermediary0.FE3dTitleContainer0.MenuTitle.TextBox1.FeatureIcon:setImage( RegisterImage( "uie_t7_mp_icon_header_option" ) )
	self:addElement( MenuFrame )
	self.MenuFrame = MenuFrame
	
	local CategoryListLine = LUI.UIImage.new()
	CategoryListLine:setLeftRight( true, false, -11, 1293 )
	CategoryListLine:setTopBottom( true, false, 80, 88 )
	CategoryListLine:setRGB( 0.9, 0.9, 0.9 )
	CategoryListLine:setImage( RegisterImage( "uie_t7_menu_cac_tabline" ) )
	self:addElement( CategoryListLine )
	self.CategoryListLine = CategoryListLine
	
	local StartMenulineGraphicsOptions0 = CoD.StartMenu_lineGraphics_Options.new( self, controller )
	StartMenulineGraphicsOptions0:setLeftRight( true, false, 1, 69 )
	StartMenulineGraphicsOptions0:setTopBottom( true, false, -13, 657 )
	self:addElement( StartMenulineGraphicsOptions0 )
	self.StartMenulineGraphicsOptions0 = StartMenulineGraphicsOptions0
	
	local graphicsList = LUI.UIList.new( self, controller, 0, 0, nil, false, false, 0, 0, false, false )
	graphicsList:makeFocusable()
	graphicsList:setLeftRight( true, false, 64, 564 )
	graphicsList:setTopBottom( true, false, 132, 608 )
	graphicsList:setDataSource( "OptionGraphicContentPC" )
	graphicsList:setWidgetType( CoD.OptionDropdown )
	graphicsList:setVerticalCount( 14 )
	graphicsList:setSpacing( 0 )
	self:addElement( graphicsList )
	self.graphicsList = graphicsList
	
	local optionInfo = CoD.OptionInfoWidget.new( self, controller )
	optionInfo:setLeftRight( true, false, 640, 1040 )
	optionInfo:setTopBottom( true, false, 132, 432 )
	self:addElement( optionInfo )
	self.optionInfo = optionInfo
	
	optionInfo:linkToElementModel( graphicsList, "description", true, function ( model )
		local description = Engine.GetModelValue( model )
		if description then
			optionInfo.description:setText( Engine.Localize( description ) )
		end
	end )
	optionInfo:linkToElementModel( graphicsList, "label", true, function ( model )
		local label = Engine.GetModelValue( model )
		if label then
			optionInfo.title.itemName:setText( Engine.Localize( label ) )
		end
	end )
	self:registerEventHandler( "menu_loaded", function ( self, event )
		local f10_local0 = nil
		ShowHeaderIconOnly( self )
		if not f10_local0 then
			f10_local0 = self:dispatchEventToChildren( event )
		end
		return f10_local0
	end )
	self:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, nil, function ( element, menu, controller, model )
		GoBack( self, controller )
		UpdateGamerprofile( self, element, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_XBB_PSCIRCLE, "MENU_BACK" )
		return true
	end, false )
	self:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_START, "M", function ( element, menu, controller, model )
		CloseStartMenu( menu, controller )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_START, "MENU_DISMISS_MENU" )
		return true
	end, false )
	self:AddButtonCallbackFunction( self, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, nil, function ( element, menu, controller, model )
		return true
	end, function ( element, menu, controller )
		CoD.Menu.SetButtonLabel( menu, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	MenuFrame:setModel( self.buttonModel, controller )
	graphicsList.id = "graphicsList"
	self:processEvent( {
		name = "menu_loaded",
		controller = controller
	} )
	self:processEvent( {
		name = "update_state",
		menu = self
	} )
	if not self:restoreState() then
		self.graphicsList:processEvent( {
			name = "gain_focus",
			controller = controller
		} )
	end
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.MenuFrame:close()
		element.StartMenulineGraphicsOptions0:close()
		element.graphicsList:close()
		element.optionInfo:close()
		Engine.UnsubscribeAndFreeModel( Engine.GetModel( Engine.GetModelForController( controller ), "StartMenu_Options_GraphicContent_PC.buttonPrompts" ) )
	end )
	if PostLoadFunc then
		PostLoadFunc( self, controller )
	end
	
	return self
end

-- OptionsGenericDropdownProperties