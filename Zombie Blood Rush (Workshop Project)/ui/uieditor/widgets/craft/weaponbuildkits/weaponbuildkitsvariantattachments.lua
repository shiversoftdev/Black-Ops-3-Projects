require( "ui.uieditor.widgets.CAC.MenuChooseClass.CategoryHeader" )
require( "ui.uieditor.widgets.Craft.WeaponBuildKits.WeaponBuildKitsAttachmentButton" )
require( "ui.uieditor.menus.Craft.WeaponBuildKits.WeaponBuildKitsAttachmentSelect" )
require( "ui.uieditor.menus.Craft.Gunsmith.GunsmithReticleSelect" )
require( "ui.uieditor.menus.Craft.Gunsmith.GunsmithAttachmentVariantSelect" )
require( "ui.uieditor.widgets.Craft.Gunsmith.GunsmithPaintjobButton" )
require( "ui.uieditor.menus.Craft.Gunsmith.GunsmithPaintjobSelect" )
require( "ui.uieditor.menus.Craft.Gunsmith.GunsmithCamoSelect" )

CoD.WeaponBuildKitsVariantAttachments = InheritFrom( LUI.UIElement )
CoD.WeaponBuildKitsVariantAttachments.new = function ( menu, controller )
	local self = LUI.UIElement.new()
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
	self:setUseStencil( false )
	self:setClass( CoD.WeaponBuildKitsVariantAttachments )
	self.id = "WeaponBuildKitsVariantAttachments"
	self.soundSet = "default"
	self:setLeftRight( true, false, 0, 700 )
	self:setTopBottom( true, false, 0, 93 )
	self:makeFocusable()
	self.onlyChildrenFocusable = true
	self.anyChildUsesUpdateState = true
	
	local opticCategoryHeader = CoD.CategoryHeader.new( menu, controller )
	opticCategoryHeader:setLeftRight( true, false, 1, 64 )
	opticCategoryHeader:setTopBottom( true, false, 0, 17 )
	opticCategoryHeader.header:setText( Engine.Localize( "MPUI_OPTICS_CAPS" ) )
	opticCategoryHeader:mergeStateConditions( {
		{
			stateName = "BreadcrumbVisible",
			condition = function ( menu, element, event )
				return Gunsmith_AnyOpticsNew( controller )
			end
		}
	} )
	self:addElement( opticCategoryHeader )
	self.opticCategoryHeader = opticCategoryHeader
	
	local attachCategoryHeader = CoD.CategoryHeader.new( menu, controller )
	attachCategoryHeader:setLeftRight( true, true, 112.67, -246.9 )
	attachCategoryHeader:setTopBottom( true, false, 0, 17 )
	attachCategoryHeader.header:setText( Engine.Localize( "MPUI_ATTACHMENTS_CAPS" ) )
	attachCategoryHeader:mergeStateConditions( {
		{
			stateName = "BreadcrumbVisible",
			condition = function ( menu, element, event )
				return Gunsmith_AnyAttachmentsNew( controller )
			end
		}
	} )
	self:addElement( attachCategoryHeader )
	self.attachCategoryHeader = attachCategoryHeader
	
	local Optic = CoD.WeaponBuildKitsAttachmentButton.new( menu, controller )
	Optic:setLeftRight( true, false, 0, 64 )
	Optic:setTopBottom( true, false, 24, 88 )
	Optic.opticIndicator:setAlpha( 0.41 )
	Optic:linkToElementModel( self, nil, false, function ( modelRef )
		Optic:setModel( modelRef, controller )
	end )
	Optic:linkToElementModel( self, "attachment1", true, function ( modelRef )
		local attachment1 = Engine.GetModelValue( modelRef )
		if attachment1 then
			Optic.attachmentImage:setImage( RegisterImage( GetAttachmentImageFromIndex( controller, "1", attachment1 ) ) )
		end
	end )
	Optic:linkToElementModel( self, nil, false, function ( modelRef )
		Optic.itemHintText:setModel( modelRef, controller )
	end )
	Optic:linkToElementModel( Optic, "attachment1", true, function ( modelRef )
		local f7_local0 = Optic
		local f7_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "attachment1"
		}
		CoD.Menu.UpdateButtonShownState( f7_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( f7_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
	end )
	Optic:registerEventHandler( "gunsmith_remove_item", function ( element, event )
		local f8_local0 = nil
		Gunsmith_ClearAttachmentSlot( self, element, "1", controller )
		EnableMouseButtonOnElement( element, controller )
		if not f8_local0 then
			f8_local0 = element:dispatchEventToChildren( event )
		end
		return f8_local0
	end )
	Optic:registerEventHandler( "gain_focus", function ( element, event )
		local f9_local0 = nil
		if element.gainFocus then
			f9_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f9_local0 = element.super:gainFocus( event )
		end
		Gunsmith_SetSelectedItemName( self, element, "optic", "1", controller )
		SetHintText( self, element, controller )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
		return f9_local0
	end )
	Optic:registerEventHandler( "lose_focus", function ( element, event )
		local f10_local0 = nil
		if element.loseFocus then
			f10_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f10_local0 = element.super:loseFocus( event )
		end
		return f10_local0
	end )
	menu:AddButtonCallbackFunction( Optic, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f11_arg0, f11_arg1, f11_arg2, f11_arg3 )
		Gunsmith_SetWeaponAttachmentType( self, f11_arg0, "optic", "1", "true", f11_arg2 )
		NavigateToMenu( self, "WeaponBuildKitsAttachmentSelect", true, f11_arg2 )
		return true
	end, function ( f12_arg0, f12_arg1, f12_arg2 )
		CoD.Menu.SetButtonLabel( f12_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	menu:AddButtonCallbackFunction( Optic, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "R", function ( f13_arg0, f13_arg1, f13_arg2, f13_arg3 )
		if IsSelfModelValueGreaterThan( f13_arg0, f13_arg2, "attachment1", 0 ) then
			Gunsmith_ClearAttachmentSlot( self, f13_arg0, "1", f13_arg2 )
			return true
		else
			
		end
	end, function ( f14_arg0, f14_arg1, f14_arg2 )
		if IsSelfModelValueGreaterThan( f14_arg0, f14_arg2, "attachment1", 0 ) then
			CoD.Menu.SetButtonLabel( f14_arg1, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "MENU_REMOVE" )
			return true
		else
			return false
		end
	end, false )
	menu:AddButtonCallbackFunction( Optic, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, nil, function ( f15_arg0, f15_arg1, f15_arg2, f15_arg3 )
		if IsSelfModelValueGreaterThan( f15_arg0, f15_arg2, "attachment1", 0 ) and IsGunsmithReticleAllowedForOptic( f15_arg1, f15_arg0, f15_arg2, "attachment1" ) then
			Gunsmith_SetWeaponReticleModel( self, f15_arg0, f15_arg2 )
			NavigateToMenu( self, "GunsmithReticleSelect", true, f15_arg2 )
			return true
		else
			
		end
	end, function ( f16_arg0, f16_arg1, f16_arg2 )
		if IsSelfModelValueGreaterThan( f16_arg0, f16_arg2, "attachment1", 0 ) and IsGunsmithReticleAllowedForOptic( f16_arg1, f16_arg0, f16_arg2, "attachment1" ) then
			CoD.Menu.SetButtonLabel( f16_arg1, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "" )
			return false
		else
			return false
		end
	end, false )
	Optic:mergeStateConditions( {
		{
			stateName = "IsEquipped",
			condition = function ( menu, element, event )
				local f17_local0
				if not IsSelfModelValueEqualTo( element, controller, "attachment1", 0 ) then
					f17_local0 = IsGunsmithReticleAllowedForOptic( menu, element, controller, "attachment1" )
				else
					f17_local0 = false
				end
				return f17_local0
			end
		},
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return IsAttachmentSlotLocked( element, controller, 0 )
			end
		},
		{
			stateName = "IsEquippedNoHintText",
			condition = function ( menu, element, event )
				local f19_local0
				if not IsSelfModelValueEqualTo( element, controller, "attachment1", 0 ) then
					f19_local0 = not IsGunsmithReticleAllowedForOptic( menu, element, controller, "attachment1" )
				else
					f19_local0 = false
				end
				return f19_local0
			end
		}
	} )
	Optic:linkToElementModel( Optic, "attachment1", true, function ( modelRef )
		menu:updateElementState( Optic, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "attachment1"
		} )
	end )
	self:addElement( Optic )
	self.Optic = Optic
	
	local Attachment1 = CoD.WeaponBuildKitsAttachmentButton.new( menu, controller )
	Attachment1:setLeftRight( true, false, 112.67, 176.67 )
	Attachment1:setTopBottom( true, false, 24, 88 )
	Attachment1:linkToElementModel( self, nil, false, function ( modelRef )
		Attachment1:setModel( modelRef, controller )
	end )
	Attachment1:linkToElementModel( self, "attachment2", true, function ( modelRef )
		local attachment2 = Engine.GetModelValue( modelRef )
		if attachment2 then
			Attachment1.attachmentImage:setImage( RegisterImage( GetAttachmentImageFromIndex( controller, "2", attachment2 ) ) )
		end
	end )
	Attachment1:linkToElementModel( self, nil, false, function ( modelRef )
		Attachment1.itemHintText:setModel( modelRef, controller )
	end )
	Attachment1:linkToElementModel( Attachment1, "attachment2", true, function ( modelRef )
		local f24_local0 = Attachment1
		local f24_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "attachment2"
		}
		CoD.Menu.UpdateButtonShownState( f24_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( f24_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
	end )
	Attachment1:registerEventHandler( "gunsmith_remove_item", function ( element, event )
		local f25_local0 = nil
		Gunsmith_ClearAttachmentSlot( self, element, "2", controller )
		EnableMouseButtonOnElement( element, controller )
		if not f25_local0 then
			f25_local0 = element:dispatchEventToChildren( event )
		end
		return f25_local0
	end )
	Attachment1:registerEventHandler( "gain_focus", function ( element, event )
		local f26_local0 = nil
		if element.gainFocus then
			f26_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f26_local0 = element.super:gainFocus( event )
		end
		Gunsmith_SetSelectedItemName( self, element, "attachment", "2", controller )
		SetHintText( self, element, controller )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
		return f26_local0
	end )
	Attachment1:registerEventHandler( "lose_focus", function ( element, event )
		local f27_local0 = nil
		if element.loseFocus then
			f27_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f27_local0 = element.super:loseFocus( event )
		end
		return f27_local0
	end )
	menu:AddButtonCallbackFunction( Attachment1, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f28_arg0, f28_arg1, f28_arg2, f28_arg3 )
		Gunsmith_SetWeaponAttachmentType( self, f28_arg0, "attachment", "2", "true", f28_arg2 )
		NavigateToMenu( self, "WeaponBuildKitsAttachmentSelect", true, f28_arg2 )
		return true
	end, function ( f29_arg0, f29_arg1, f29_arg2 )
		CoD.Menu.SetButtonLabel( f29_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	menu:AddButtonCallbackFunction( Attachment1, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "R", function ( f30_arg0, f30_arg1, f30_arg2, f30_arg3 )
		if IsSelfModelValueGreaterThan( f30_arg0, f30_arg2, "attachment2", 0 ) then
			Gunsmith_ClearAttachmentSlot( self, f30_arg0, "2", f30_arg2 )
			return true
		else
			
		end
	end, function ( f31_arg0, f31_arg1, f31_arg2 )
		if IsSelfModelValueGreaterThan( f31_arg0, f31_arg2, "attachment2", 0 ) then
			CoD.Menu.SetButtonLabel( f31_arg1, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "MENU_REMOVE" )
			return true
		else
			return false
		end
	end, false )
	menu:AddButtonCallbackFunction( Attachment1, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "P", function ( f32_arg0, f32_arg1, f32_arg2, f32_arg3 )
		if IsSelfModelValueGreaterThan( f32_arg0, f32_arg2, "attachment2", 0 ) then
			NavigateToMenu( self, "GunsmithAttachmentVariantSelect", true, f32_arg2 )
			return true
		else
			
		end
	end, function ( f33_arg0, f33_arg1, f33_arg2 )
		if IsSelfModelValueGreaterThan( f33_arg0, f33_arg2, "attachment2", 0 ) then
			CoD.Menu.SetButtonLabel( f33_arg1, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "" )
			return false
		else
			return false
		end
	end, false )
	Attachment1:mergeStateConditions( {
		{
			stateName = "IsEquipped",
			condition = function ( menu, element, event )
				return not IsSelfModelValueEqualTo( element, controller, "attachment2", 0 )
			end
		},
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return IsAttachmentSlotLocked( element, controller, 1 )
			end
		},
		{
			stateName = "IsEquippedNoHintText",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )
	Attachment1:linkToElementModel( Attachment1, "attachment2", true, function ( modelRef )
		menu:updateElementState( Attachment1, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "attachment2"
		} )
	end )
	self:addElement( Attachment1 )
	self.Attachment1 = Attachment1
	
	local Attachment2 = CoD.WeaponBuildKitsAttachmentButton.new( menu, controller )
	Attachment2:setLeftRight( true, false, 180.67, 244.67 )
	Attachment2:setTopBottom( true, false, 24, 88 )
	Attachment2:linkToElementModel( self, nil, false, function ( modelRef )
		Attachment2:setModel( modelRef, controller )
	end )
	Attachment2:linkToElementModel( self, "attachment3", true, function ( modelRef )
		local attachment3 = Engine.GetModelValue( modelRef )
		if attachment3 then
			Attachment2.attachmentImage:setImage( RegisterImage( GetAttachmentImageFromIndex( controller, "3", attachment3 ) ) )
		end
	end )
	Attachment2:linkToElementModel( self, nil, false, function ( modelRef )
		Attachment2.itemHintText:setModel( modelRef, controller )
	end )
	Attachment2:linkToElementModel( Attachment2, "attachment3", true, function ( modelRef )
		local f41_local0 = Attachment2
		local f41_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "attachment3"
		}
		CoD.Menu.UpdateButtonShownState( f41_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( f41_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
	end )
	Attachment2:registerEventHandler( "gunsmith_remove_item", function ( element, event )
		local f42_local0 = nil
		Gunsmith_ClearAttachmentSlot( self, element, "3", controller )
		EnableMouseButtonOnElement( element, controller )
		if not f42_local0 then
			f42_local0 = element:dispatchEventToChildren( event )
		end
		return f42_local0
	end )
	Attachment2:registerEventHandler( "gain_focus", function ( element, event )
		local f43_local0 = nil
		if element.gainFocus then
			f43_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f43_local0 = element.super:gainFocus( event )
		end
		Gunsmith_SetSelectedItemName( self, element, "attachment", "3", controller )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
		return f43_local0
	end )
	Attachment2:registerEventHandler( "lose_focus", function ( element, event )
		local f44_local0 = nil
		if element.loseFocus then
			f44_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f44_local0 = element.super:loseFocus( event )
		end
		return f44_local0
	end )
	menu:AddButtonCallbackFunction( Attachment2, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f45_arg0, f45_arg1, f45_arg2, f45_arg3 )
		Gunsmith_SetWeaponAttachmentType( self, f45_arg0, "attachment", "3", "true", f45_arg2 )
		NavigateToMenu( self, "WeaponBuildKitsAttachmentSelect", true, f45_arg2 )
		return true
	end, function ( f46_arg0, f46_arg1, f46_arg2 )
		CoD.Menu.SetButtonLabel( f46_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	menu:AddButtonCallbackFunction( Attachment2, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "R", function ( f47_arg0, f47_arg1, f47_arg2, f47_arg3 )
		if IsSelfModelValueGreaterThan( f47_arg0, f47_arg2, "attachment3", 0 ) then
			Gunsmith_ClearAttachmentSlot( self, f47_arg0, "3", f47_arg2 )
			return true
		else
			
		end
	end, function ( f48_arg0, f48_arg1, f48_arg2 )
		if IsSelfModelValueGreaterThan( f48_arg0, f48_arg2, "attachment3", 0 ) then
			CoD.Menu.SetButtonLabel( f48_arg1, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "MENU_REMOVE" )
			return true
		else
			return false
		end
	end, false )
	menu:AddButtonCallbackFunction( Attachment2, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "P", function ( f49_arg0, f49_arg1, f49_arg2, f49_arg3 )
		if IsSelfModelValueGreaterThan( f49_arg0, f49_arg2, "attachment3", 0 ) then
			NavigateToMenu( self, "GunsmithAttachmentVariantSelect", true, f49_arg2 )
			return true
		else
			
		end
	end, function ( f50_arg0, f50_arg1, f50_arg2 )
		if IsSelfModelValueGreaterThan( f50_arg0, f50_arg2, "attachment3", 0 ) then
			CoD.Menu.SetButtonLabel( f50_arg1, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "" )
			return false
		else
			return false
		end
	end, false )
	Attachment2:mergeStateConditions( {
		{
			stateName = "IsEquipped",
			condition = function ( menu, element, event )
				return not IsSelfModelValueEqualTo( element, controller, "attachment3", 0 )
			end
		},
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return IsAttachmentSlotLocked( element, controller, 2 )
			end
		},
		{
			stateName = "IsEquippedNoHintText",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )
	Attachment2:linkToElementModel( Attachment2, "attachment3", true, function ( modelRef )
		menu:updateElementState( Attachment2, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "attachment3"
		} )
	end )
	self:addElement( Attachment2 )
	self.Attachment2 = Attachment2
	
	local Attachment3 = CoD.WeaponBuildKitsAttachmentButton.new( menu, controller )
	Attachment3:setLeftRight( true, false, 249.67, 313.67 )
	Attachment3:setTopBottom( true, false, 24, 88 )
	Attachment3:linkToElementModel( self, nil, false, function ( modelRef )
		Attachment3:setModel( modelRef, controller )
	end )
	Attachment3:linkToElementModel( self, "attachment4", true, function ( modelRef )
		local attachment4 = Engine.GetModelValue( modelRef )
		if attachment4 then
			Attachment3.attachmentImage:setImage( RegisterImage( GetAttachmentImageFromIndex( controller, "4", attachment4 ) ) )
		end
	end )
	Attachment3:linkToElementModel( self, nil, false, function ( modelRef )
		Attachment3.itemHintText:setModel( modelRef, controller )
	end )
	Attachment3:linkToElementModel( Attachment3, "attachment4", true, function ( modelRef )
		local f58_local0 = Attachment3
		local f58_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "attachment4"
		}
		CoD.Menu.UpdateButtonShownState( f58_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( f58_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
	end )
	Attachment3:registerEventHandler( "gunsmith_remove_item", function ( element, event )
		local f59_local0 = nil
		Gunsmith_ClearAttachmentSlot( self, element, "4", controller )
		EnableMouseButtonOnElement( element, controller )
		if not f59_local0 then
			f59_local0 = element:dispatchEventToChildren( event )
		end
		return f59_local0
	end )
	Attachment3:registerEventHandler( "gain_focus", function ( element, event )
		local f60_local0 = nil
		if element.gainFocus then
			f60_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f60_local0 = element.super:gainFocus( event )
		end
		Gunsmith_SetSelectedItemName( self, element, "attachment", "4", controller )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
		return f60_local0
	end )
	Attachment3:registerEventHandler( "lose_focus", function ( element, event )
		local f61_local0 = nil
		if element.loseFocus then
			f61_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f61_local0 = element.super:loseFocus( event )
		end
		return f61_local0
	end )
	menu:AddButtonCallbackFunction( Attachment3, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f62_arg0, f62_arg1, f62_arg2, f62_arg3 )
		Gunsmith_SetWeaponAttachmentType( self, f62_arg0, "attachment", "4", "true", f62_arg2 )
		NavigateToMenu( self, "WeaponBuildKitsAttachmentSelect", true, f62_arg2 )
		return true
	end, function ( f63_arg0, f63_arg1, f63_arg2 )
		CoD.Menu.SetButtonLabel( f63_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	menu:AddButtonCallbackFunction( Attachment3, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "R", function ( f64_arg0, f64_arg1, f64_arg2, f64_arg3 )
		if IsSelfModelValueGreaterThan( f64_arg0, f64_arg2, "attachment4", 0 ) then
			Gunsmith_ClearAttachmentSlot( self, f64_arg0, "4", f64_arg2 )
			return true
		else
			
		end
	end, function ( f65_arg0, f65_arg1, f65_arg2 )
		if IsSelfModelValueGreaterThan( f65_arg0, f65_arg2, "attachment4", 0 ) then
			CoD.Menu.SetButtonLabel( f65_arg1, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "MENU_REMOVE" )
			return true
		else
			return false
		end
	end, false )
	menu:AddButtonCallbackFunction( Attachment3, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "P", function ( f66_arg0, f66_arg1, f66_arg2, f66_arg3 )
		if IsSelfModelValueGreaterThan( f66_arg0, f66_arg2, "attachment4", 0 ) then
			NavigateToMenu( self, "GunsmithAttachmentVariantSelect", true, f66_arg2 )
			return true
		else
			
		end
	end, function ( f67_arg0, f67_arg1, f67_arg2 )
		if IsSelfModelValueGreaterThan( f67_arg0, f67_arg2, "attachment4", 0 ) then
			CoD.Menu.SetButtonLabel( f67_arg1, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "" )
			return false
		else
			return false
		end
	end, false )
	Attachment3:mergeStateConditions( {
		{
			stateName = "IsEquipped",
			condition = function ( menu, element, event )
				return not IsSelfModelValueEqualTo( element, controller, "attachment4", 0 )
			end
		},
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return IsAttachmentSlotLocked( element, controller, 3 )
			end
		},
		{
			stateName = "IsEquippedNoHintText",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )
	Attachment3:linkToElementModel( Attachment3, "attachment4", true, function ( modelRef )
		menu:updateElementState( Attachment3, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "attachment4"
		} )
	end )
	self:addElement( Attachment3 )
	self.Attachment3 = Attachment3
	
	local Attachment4 = CoD.WeaponBuildKitsAttachmentButton.new( menu, controller )
	Attachment4:setLeftRight( true, false, 320.1, 384.1 )
	Attachment4:setTopBottom( true, false, 24, 88 )
	Attachment4:linkToElementModel( self, nil, false, function ( modelRef )
		Attachment4:setModel( modelRef, controller )
	end )
	Attachment4:linkToElementModel( self, "attachment5", true, function ( modelRef )
		local attachment5 = Engine.GetModelValue( modelRef )
		if attachment5 then
			Attachment4.attachmentImage:setImage( RegisterImage( GetAttachmentImageFromIndex( controller, "5", attachment5 ) ) )
		end
	end )
	Attachment4:linkToElementModel( self, nil, false, function ( modelRef )
		Attachment4.itemHintText:setModel( modelRef, controller )
	end )
	Attachment4:linkToElementModel( Attachment4, "attachment5", true, function ( modelRef )
		local f75_local0 = Attachment4
		local f75_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "attachment5"
		}
		CoD.Menu.UpdateButtonShownState( f75_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( f75_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
	end )
	Attachment4:registerEventHandler( "gunsmith_remove_item", function ( element, event )
		local f76_local0 = nil
		Gunsmith_ClearAttachmentSlot( self, element, "5", controller )
		EnableMouseButtonOnElement( element, controller )
		if not f76_local0 then
			f76_local0 = element:dispatchEventToChildren( event )
		end
		return f76_local0
	end )
	Attachment4:registerEventHandler( "gain_focus", function ( element, event )
		local f77_local0 = nil
		if element.gainFocus then
			f77_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f77_local0 = element.super:gainFocus( event )
		end
		Gunsmith_SetSelectedItemName( self, element, "attachment", "5", controller )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
		return f77_local0
	end )
	Attachment4:registerEventHandler( "lose_focus", function ( element, event )
		local f78_local0 = nil
		if element.loseFocus then
			f78_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f78_local0 = element.super:loseFocus( event )
		end
		return f78_local0
	end )
	menu:AddButtonCallbackFunction( Attachment4, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f79_arg0, f79_arg1, f79_arg2, f79_arg3 )
		Gunsmith_SetWeaponAttachmentType( self, f79_arg0, "attachment", "5", "true", f79_arg2 )
		NavigateToMenu( self, "WeaponBuildKitsAttachmentSelect", true, f79_arg2 )
		return true
	end, function ( f80_arg0, f80_arg1, f80_arg2 )
		CoD.Menu.SetButtonLabel( f80_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	menu:AddButtonCallbackFunction( Attachment4, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "R", function ( f81_arg0, f81_arg1, f81_arg2, f81_arg3 )
		if IsSelfModelValueGreaterThan( f81_arg0, f81_arg2, "attachment5", 0 ) then
			Gunsmith_ClearAttachmentSlot( self, f81_arg0, "5", f81_arg2 )
			return true
		else
			
		end
	end, function ( f82_arg0, f82_arg1, f82_arg2 )
		if IsSelfModelValueGreaterThan( f82_arg0, f82_arg2, "attachment5", 0 ) then
			CoD.Menu.SetButtonLabel( f82_arg1, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "MENU_REMOVE" )
			return true
		else
			return false
		end
	end, false )
	menu:AddButtonCallbackFunction( Attachment4, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "P", function ( f83_arg0, f83_arg1, f83_arg2, f83_arg3 )
		if IsSelfModelValueGreaterThan( f83_arg0, f83_arg2, "attachment5", 0 ) then
			NavigateToMenu( self, "GunsmithAttachmentVariantSelect", true, f83_arg2 )
			return true
		else
			
		end
	end, function ( f84_arg0, f84_arg1, f84_arg2 )
		if IsSelfModelValueGreaterThan( f84_arg0, f84_arg2, "attachment5", 0 ) then
			CoD.Menu.SetButtonLabel( f84_arg1, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "" )
			return false
		else
			return false
		end
	end, false )
	Attachment4:mergeStateConditions( {
		{
			stateName = "IsEquipped",
			condition = function ( menu, element, event )
				return not IsSelfModelValueEqualTo( element, controller, "attachment5", 0 )
			end
		},
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return IsAttachmentSlotLocked( element, controller, 4 )
			end
		},
		{
			stateName = "IsEquippedNoHintText",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )
	Attachment4:linkToElementModel( Attachment4, "attachment5", true, function ( modelRef )
		menu:updateElementState( Attachment4, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "attachment5"
		} )
	end )
	self:addElement( Attachment4 )
	self.Attachment4 = Attachment4
	
	local Attachment5 = CoD.WeaponBuildKitsAttachmentButton.new( menu, controller )
	Attachment5:setLeftRight( true, false, 389.1, 453.1 )
	Attachment5:setTopBottom( true, false, 24, 88 )
	Attachment5:linkToElementModel( self, nil, false, function ( modelRef )
		Attachment5:setModel( modelRef, controller )
	end )
	Attachment5:linkToElementModel( self, "attachment6", true, function ( modelRef )
		local attachment6 = Engine.GetModelValue( modelRef )
		if attachment6 then
			Attachment5.attachmentImage:setImage( RegisterImage( GetAttachmentImageFromIndex( controller, "6", attachment6 ) ) )
		end
	end )
	Attachment5:linkToElementModel( self, nil, false, function ( modelRef )
		Attachment5.itemHintText:setModel( modelRef, controller )
	end )
	Attachment5:linkToElementModel( Attachment5, "attachment6", true, function ( modelRef )
		local f92_local0 = Attachment5
		local f92_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "attachment6"
		}
		CoD.Menu.UpdateButtonShownState( f92_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( f92_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
	end )
	Attachment5:registerEventHandler( "gunsmith_remove_item", function ( element, event )
		local f93_local0 = nil
		Gunsmith_ClearAttachmentSlot( self, element, "6", controller )
		EnableMouseButtonOnElement( element, controller )
		if not f93_local0 then
			f93_local0 = element:dispatchEventToChildren( event )
		end
		return f93_local0
	end )
	Attachment5:registerEventHandler( "gain_focus", function ( element, event )
		local f94_local0 = nil
		if element.gainFocus then
			f94_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f94_local0 = element.super:gainFocus( event )
		end
		Gunsmith_SetSelectedItemName( self, element, "attachment", "6", controller )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
		return f94_local0
	end )
	Attachment5:registerEventHandler( "lose_focus", function ( element, event )
		local f95_local0 = nil
		if element.loseFocus then
			f95_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f95_local0 = element.super:loseFocus( event )
		end
		return f95_local0
	end )
	menu:AddButtonCallbackFunction( Attachment5, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f96_arg0, f96_arg1, f96_arg2, f96_arg3 )
		Gunsmith_SetWeaponAttachmentType( self, f96_arg0, "attachment", "6", "true", f96_arg2 )
		NavigateToMenu( self, "WeaponBuildKitsAttachmentSelect", true, f96_arg2 )
		return true
	end, function ( f97_arg0, f97_arg1, f97_arg2 )
		CoD.Menu.SetButtonLabel( f97_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	menu:AddButtonCallbackFunction( Attachment5, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "R", function ( f98_arg0, f98_arg1, f98_arg2, f98_arg3 )
		if IsSelfModelValueGreaterThan( f98_arg0, f98_arg2, "attachment6", 0 ) then
			Gunsmith_ClearAttachmentSlot( self, f98_arg0, "6", f98_arg2 )
			return true
		else
			
		end
	end, function ( f99_arg0, f99_arg1, f99_arg2 )
		if IsSelfModelValueGreaterThan( f99_arg0, f99_arg2, "attachment6", 0 ) then
			CoD.Menu.SetButtonLabel( f99_arg1, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "MENU_REMOVE" )
			return true
		else
			return false
		end
	end, false )
	menu:AddButtonCallbackFunction( Attachment5, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "P", function ( f100_arg0, f100_arg1, f100_arg2, f100_arg3 )
		if IsSelfModelValueGreaterThan( f100_arg0, f100_arg2, "attachment6", 0 ) then
			NavigateToMenu( self, "GunsmithAttachmentVariantSelect", true, f100_arg2 )
			return true
		else
			
		end
	end, function ( f101_arg0, f101_arg1, f101_arg2 )
		if IsSelfModelValueGreaterThan( f101_arg0, f101_arg2, "attachment6", 0 ) then
			CoD.Menu.SetButtonLabel( f101_arg1, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "" )
			return false
		else
			return false
		end
	end, false )
	Attachment5:mergeStateConditions( {
		{
			stateName = "IsEquipped",
			condition = function ( menu, element, event )
				return not IsSelfModelValueEqualTo( element, controller, "attachment6", 0 )
			end
		},
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return IsAttachmentSlotLocked( element, controller, 5 )
			end
		},
		{
			stateName = "IsEquippedNoHintText",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )
	Attachment5:linkToElementModel( Attachment5, "attachment6", true, function ( modelRef )
		menu:updateElementState( Attachment5, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "attachment6"
		} )
	end )
	self:addElement( Attachment5 )
	self.Attachment5 = Attachment5

	-- START attach 6

	local Attachment6 = CoD.WeaponBuildKitsAttachmentButton.new( menu, controller )
	Attachment6:setLeftRight( true, false, 458.1, 522.1 )
	Attachment6:setTopBottom( true, false, 24, 88 )
	Attachment6:linkToElementModel( self, nil, false, function ( modelRef )
		Attachment6:setModel( modelRef, controller )
	end )
	Attachment6:linkToElementModel( self, "attachment7", true, function ( modelRef )
		local attachment7 = Engine.GetModelValue( modelRef )
		if not attachment7 then
			attachment7 = 0
		end
		if attachment7 then
			local v = Engine.GetAttachmentUniqueImageByAttachmentIndex(CoD.CraftUtility.GetCraftMode(), CoD.GetCustomization(controller, "weapon_index"), tonumber(attachment7))
			if v and v.image then
				Attachment7.attachmentImage:setImage( RegisterImage( v.image ) )
			end
		end
	end )
	Attachment6:linkToElementModel( self, nil, false, function ( modelRef )
		Attachment6.itemHintText:setModel( modelRef, controller )
	end )
	Attachment6:linkToElementModel( Attachment6, "attachment7", true, function ( modelRef )
		local f92_local0 = Attachment6
		local f92_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "attachment7"
		}
		CoD.Menu.UpdateButtonShownState( f92_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( f92_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
	end )
	Attachment6:registerEventHandler( "gunsmith_remove_item", function ( element, event )
		local f93_local0 = nil
		Gunsmith_ClearAttachmentSlot( self, element, "7", controller )
		EnableMouseButtonOnElement( element, controller )
		if not f93_local0 then
			f93_local0 = element:dispatchEventToChildren( event )
		end
		return f93_local0
	end )
	Attachment6:registerEventHandler( "gain_focus", function ( element, event )
		local f94_local0 = nil
		if element.gainFocus then
			f94_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f94_local0 = element.super:gainFocus( event )
		end
		Gunsmith_SetSelectedItemName( self, element, "attachment", "7", controller )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
		return f94_local0
	end )
	Attachment6:registerEventHandler( "lose_focus", function ( element, event )
		local f95_local0 = nil
		if element.loseFocus then
			f95_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f95_local0 = element.super:loseFocus( event )
		end
		return f95_local0
	end )
	menu:AddButtonCallbackFunction( Attachment6, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f96_arg0, f96_arg1, f96_arg2, f96_arg3 )
		Gunsmith_SetWeaponAttachmentType( self, f96_arg0, "attachment", "7", "true", f96_arg2 )
		NavigateToMenu( self, "WeaponBuildKitsAttachmentSelect", true, f96_arg2 )
		return true
	end, function ( f97_arg0, f97_arg1, f97_arg2 )
		CoD.Menu.SetButtonLabel( f97_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	menu:AddButtonCallbackFunction( Attachment6, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "R", function ( f98_arg0, f98_arg1, f98_arg2, f98_arg3 )
		if IsSelfModelValueGreaterThan( f98_arg0, f98_arg2, "attachment7", 0 ) then
			Gunsmith_ClearAttachmentSlot( self, f98_arg0, "7", f98_arg2 )
			return true
		else
			
		end
	end, function ( f99_arg0, f99_arg1, f99_arg2 )
		if IsSelfModelValueGreaterThan( f99_arg0, f99_arg2, "attachment7", 0 ) then
			CoD.Menu.SetButtonLabel( f99_arg1, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "MENU_REMOVE" )
			return true
		else
			return false
		end
	end, false )
	menu:AddButtonCallbackFunction( Attachment6, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "P", function ( f100_arg0, f100_arg1, f100_arg2, f100_arg3 )
		if IsSelfModelValueGreaterThan( f100_arg0, f100_arg2, "attachment7", 0 ) then
			NavigateToMenu( self, "GunsmithAttachmentVariantSelect", true, f100_arg2 )
			return true
		else
			
		end
	end, function ( f101_arg0, f101_arg1, f101_arg2 )
		if IsSelfModelValueGreaterThan( f101_arg0, f101_arg2, "attachment7", 0 ) then
			CoD.Menu.SetButtonLabel( f101_arg1, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "" )
			return false
		else
			return false
		end
	end, false )
	Attachment6:mergeStateConditions( {
		{
			stateName = "IsEquipped",
			condition = function ( menu, element, event )
				return not IsSelfModelValueEqualTo( element, controller, "attachment7", 0 )
			end
		},
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		},
		{
			stateName = "IsEquippedNoHintText",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )
	local f_1 = function()
		Attachment6:linkToElementModel( Attachment6, "attachment7", true, function ( modelRef )
			menu:updateElementState( Attachment6, {
				name = "model_validation",
				menu = menu,
				modelValue = Engine.GetModelValue( modelRef ),
				modelName = "attachment7"
			} )
		end )
	end
	f_1()
	self:addElement( Attachment6 )
	self.Attachment6 = Attachment6

	-- END attach 6

	-- START attach 7
	local Attachment7 = CoD.WeaponBuildKitsAttachmentButton.new( menu, controller )
	Attachment7:setLeftRight( true, false, 527.1, 591.1 )
	Attachment7:setTopBottom( true, false, 24, 88 )
	Attachment7:linkToElementModel( self, nil, false, function ( modelRef )
		Attachment7:setModel( modelRef, controller )
	end )
	Attachment7:linkToElementModel( self, "attachment8", true, function ( modelRef )
		local attachment8 = Engine.GetModelValue( modelRef )
		if not attachment8 then
			attachment8 = 0
		end
		if attachment8 then
			local v = Engine.GetAttachmentUniqueImageByAttachmentIndex(CoD.CraftUtility.GetCraftMode(), CoD.GetCustomization(controller, "weapon_index"), tonumber(attachment8))
			if v and v.image then
				Attachment7.attachmentImage:setImage( RegisterImage( v.image ) )
			end
		end
	end )
	Attachment7:linkToElementModel( self, nil, false, function ( modelRef )
		Attachment7.itemHintText:setModel( modelRef, controller )
	end )
	Attachment7:linkToElementModel( Attachment7, "attachment8", true, function ( modelRef )
		local f92_local0 = Attachment7
		local f92_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "attachment8"
		}
		CoD.Menu.UpdateButtonShownState( f92_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( f92_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
	end )
	Attachment7:registerEventHandler( "gunsmith_remove_item", function ( element, event )
		local f93_local0 = nil
		Gunsmith_ClearAttachmentSlot( self, element, "8", controller )
		EnableMouseButtonOnElement( element, controller )
		if not f93_local0 then
			f93_local0 = element:dispatchEventToChildren( event )
		end
		return f93_local0
	end )
	Attachment7:registerEventHandler( "gain_focus", function ( element, event )
		local f94_local0 = nil
		if element.gainFocus then
			f94_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f94_local0 = element.super:gainFocus( event )
		end
		Gunsmith_SetSelectedItemName( self, element, "attachment", "8", controller )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE )
		return f94_local0
	end )
	Attachment7:registerEventHandler( "lose_focus", function ( element, event )
		local f95_local0 = nil
		if element.loseFocus then
			f95_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f95_local0 = element.super:loseFocus( event )
		end
		return f95_local0
	end )
	menu:AddButtonCallbackFunction( Attachment7, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f96_arg0, f96_arg1, f96_arg2, f96_arg3 )
		Gunsmith_SetWeaponAttachmentType( self, f96_arg0, "attachment", "8", "true", f96_arg2 )
		NavigateToMenu( self, "WeaponBuildKitsAttachmentSelect", true, f96_arg2 )
		return true
	end, function ( f97_arg0, f97_arg1, f97_arg2 )
		CoD.Menu.SetButtonLabel( f97_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	menu:AddButtonCallbackFunction( Attachment7, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "R", function ( f98_arg0, f98_arg1, f98_arg2, f98_arg3 )
		if IsSelfModelValueGreaterThan( f98_arg0, f98_arg2, "attachment8", 0 ) then
			Gunsmith_ClearAttachmentSlot( self, f98_arg0, "8", f98_arg2 )
			return true
		else
			
		end
	end, function ( f99_arg0, f99_arg1, f99_arg2 )
		if IsSelfModelValueGreaterThan( f99_arg0, f99_arg2, "attachment8", 0 ) then
			CoD.Menu.SetButtonLabel( f99_arg1, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "MENU_REMOVE" )
			return true
		else
			return false
		end
	end, false )
	menu:AddButtonCallbackFunction( Attachment7, controller, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "P", function ( f100_arg0, f100_arg1, f100_arg2, f100_arg3 )
		if IsSelfModelValueGreaterThan( f100_arg0, f100_arg2, "attachment8", 0 ) then
			NavigateToMenu( self, "GunsmithAttachmentVariantSelect", true, f100_arg2 )
			return true
		else
			
		end
	end, function ( f101_arg0, f101_arg1, f101_arg2 )
		if IsSelfModelValueGreaterThan( f101_arg0, f101_arg2, "attachment8", 0 ) then
			CoD.Menu.SetButtonLabel( f101_arg1, Enum.LUIButton.LUI_KEY_XBY_PSTRIANGLE, "" )
			return false
		else
			return false
		end
	end, false )
	Attachment7:mergeStateConditions( {
		{
			stateName = "IsEquipped",
			condition = function ( menu, element, event )
				return not IsSelfModelValueEqualTo( element, controller, "attachment8", 0 )
			end
		},
		{
			stateName = "Locked",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		},
		{
			stateName = "IsEquippedNoHintText",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )
	local f_2 = function()
		Attachment7:linkToElementModel( Attachment7, "attachment8", true, function ( modelRef )
			menu:updateElementState( Attachment7, {
				name = "model_validation",
				menu = menu,
				modelValue = Engine.GetModelValue( modelRef ),
				modelName = "attachment8"
			} )
		end )
	end
	f_2()
	self:addElement( Attachment7 )
	self.Attachment7 = Attachment7

	-- END attach 7
	
	local paintjobCategoryHeader = CoD.CategoryHeader.new( menu, controller )
	paintjobCategoryHeader:setLeftRight( true, false, 639.77, 717.77 )
	paintjobCategoryHeader:setTopBottom( true, false, 0, 17 )
	paintjobCategoryHeader.header:setText( Engine.Localize( "MENU_PAINTSHOP_PAINTJOB" ) )
	paintjobCategoryHeader:mergeStateConditions( {
		{
			stateName = "BreadcrumbVisible",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )
	self:addElement( paintjobCategoryHeader )
	self.paintjobCategoryHeader = paintjobCategoryHeader
	
	local camoCategoryHeader = CoD.CategoryHeader.new( menu, controller )
	camoCategoryHeader:setLeftRight( true, false, 749.44, 813.44 )
	camoCategoryHeader:setTopBottom( true, false, 0, 17 )
	camoCategoryHeader.header:setText( Engine.Localize( "MPUI_CAMO_CAPS" ) )
	camoCategoryHeader:mergeStateConditions( {
		{
			stateName = "BreadcrumbVisible",
			condition = function ( menu, element, event )
				return Gunsmith_AnyCamosNew( controller )
			end
		}
	} )
	self:addElement( camoCategoryHeader )
	self.camoCategoryHeader = camoCategoryHeader
	
	local paintjob = CoD.GunsmithPaintjobButton.new( menu, controller )
	paintjob:setLeftRight( true, false, 639.77, 703.77 )
	paintjob:setTopBottom( true, false, 24, 88 )
	paintjob:linkToElementModel( self, nil, false, function ( modelRef )
		paintjob:setModel( modelRef, controller )
	end )
	paintjob:linkToElementModel( paintjob, "paintjobIndex", true, function ( modelRef )
		local f109_local0 = paintjob
		local f109_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "paintjobIndex"
		}
		CoD.Menu.UpdateButtonShownState( f109_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
	end )
	paintjob:linkToElementModel( paintjob, "paintjobSlot", true, function ( modelRef )
		local f110_local0 = paintjob
		local f110_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "paintjobSlot"
		}
		CoD.Menu.UpdateButtonShownState( f110_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
	end )
	paintjob:registerEventHandler( "gunsmith_remove_item", function ( element, event )
		local f111_local0 = nil
		Gunsmith_ClearVariantPaintjobSlot( self, element, controller )
		if not f111_local0 then
			f111_local0 = element:dispatchEventToChildren( event )
		end
		return f111_local0
	end )
	paintjob:registerEventHandler( "gain_focus", function ( element, event )
		local f112_local0 = nil
		if element.gainFocus then
			f112_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f112_local0 = element.super:gainFocus( event )
		end
		Gunsmith_SetSelectedItemName( self, element, "paintjob", "", controller )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		return f112_local0
	end )
	paintjob:registerEventHandler( "lose_focus", function ( element, event )
		local f113_local0 = nil
		if element.loseFocus then
			f113_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f113_local0 = element.super:loseFocus( event )
		end
		return f113_local0
	end )
	menu:AddButtonCallbackFunction( paintjob, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f114_arg0, f114_arg1, f114_arg2, f114_arg3 )
		if not ShouldHidePaintJobOptionInZM( f114_arg1, f114_arg0, f114_arg2 ) then
			Gunsmith_OpenPaintjobSelector( self, f114_arg0, f114_arg2 )
			NavigateToMenu( self, "GunsmithPaintjobSelect", true, f114_arg2 )
			return true
		else
			
		end
	end, function ( f115_arg0, f115_arg1, f115_arg2 )
		if not ShouldHidePaintJobOptionInZM( f115_arg1, f115_arg0, f115_arg2 ) then
			CoD.Menu.SetButtonLabel( f115_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
			return true
		else
			return false
		end
	end, false )
	menu:AddButtonCallbackFunction( paintjob, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "R", function ( f116_arg0, f116_arg1, f116_arg2, f116_arg3 )
		if not IsSelfModelValueEqualTo( f116_arg0, f116_arg2, "paintjobIndex", 15 ) and not IsSelfModelValueEqualTo( f116_arg0, f116_arg2, "paintjobSlot", 15 ) then
			Gunsmith_ClearVariantPaintjobSlot( self, f116_arg0, f116_arg2 )
			return true
		else
			
		end
	end, function ( f117_arg0, f117_arg1, f117_arg2 )
		if not IsSelfModelValueEqualTo( f117_arg0, f117_arg2, "paintjobIndex", 15 ) and not IsSelfModelValueEqualTo( f117_arg0, f117_arg2, "paintjobSlot", 15 ) then
			CoD.Menu.SetButtonLabel( f117_arg1, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "MENU_REMOVE" )
			return true
		else
			return false
		end
	end, false )
	paintjob:mergeStateConditions( {
		{
			stateName = "NotVisibleOffline",
			condition = function ( menu, element, event )
				return ShouldHidePaintJobOptionInZM( menu, element, controller )
			end
		},
		{
			stateName = "IsEquipped",
			condition = function ( menu, element, event )
				local f119_local0
				if not IsSelfModelValueEqualTo( element, controller, "paintjobSlot", 15 ) then
					f119_local0 = not IsSelfModelValueEqualTo( element, controller, "paintjobIndex", 15 )
				else
					f119_local0 = false
				end
				return f119_local0
			end
		}
	} )
	paintjob:linkToElementModel( paintjob, "paintjobSlot", true, function ( modelRef )
		menu:updateElementState( paintjob, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "paintjobSlot"
		} )
	end )
	paintjob:linkToElementModel( paintjob, "paintjobIndex", true, function ( modelRef )
		menu:updateElementState( paintjob, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "paintjobIndex"
		} )
	end )
	self:addElement( paintjob )
	self.paintjob = paintjob
	
	local Camo = CoD.WeaponBuildKitsAttachmentButton.new( menu, controller )
	Camo:setLeftRight( true, false, 749.44, 813.44 )
	Camo:setTopBottom( true, false, 24, 88 )
	Camo:linkToElementModel( self, nil, false, function ( modelRef )
		Camo:setModel( modelRef, controller )
	end )
	Camo:linkToElementModel( self, "camoIndex", true, function ( modelRef )
		local camoIndex = Engine.GetModelValue( modelRef )
		if camoIndex then
			Camo.attachmentImage:setImage( RegisterImage( GetCamoImageFromIndex( controller, camoIndex ) ) )
		end
	end )
	Camo:linkToElementModel( Camo, "camoIndex", true, function ( modelRef )
		local f124_local0 = Camo
		local f124_local1 = {
			controller = controller,
			name = "model_validation",
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "camoIndex"
		}
		CoD.Menu.UpdateButtonShownState( f124_local0, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
	end )
	Camo:registerEventHandler( "gunsmith_remove_item", function ( element, event )
		local f125_local0 = nil
		Gunsmith_ClearCamo( self, element, controller )
		EnableMouseButtonOnElement( element, controller )
		if not f125_local0 then
			f125_local0 = element:dispatchEventToChildren( event )
		end
		return f125_local0
	end )
	Camo:registerEventHandler( "gain_focus", function ( element, event )
		local f126_local0 = nil
		if element.gainFocus then
			f126_local0 = element:gainFocus( event )
		elseif element.super.gainFocus then
			f126_local0 = element.super:gainFocus( event )
		end
		Gunsmith_SetSelectedItemName( self, element, "camo", "", controller )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS )
		CoD.Menu.UpdateButtonShownState( element, menu, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE )
		return f126_local0
	end )
	Camo:registerEventHandler( "lose_focus", function ( element, event )
		local f127_local0 = nil
		if element.loseFocus then
			f127_local0 = element:loseFocus( event )
		elseif element.super.loseFocus then
			f127_local0 = element.super:loseFocus( event )
		end
		return f127_local0
	end )
	menu:AddButtonCallbackFunction( Camo, controller, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "ENTER", function ( f128_arg0, f128_arg1, f128_arg2, f128_arg3 )
		Gunsmith_SetWeaponCamoModel( self, f128_arg0, f128_arg2 )
		NavigateToMenu( self, "GunsmithCamoSelect", true, f128_arg2 )
		return true
	end, function ( f129_arg0, f129_arg1, f129_arg2 )
		CoD.Menu.SetButtonLabel( f129_arg1, Enum.LUIButton.LUI_KEY_XBA_PSCROSS, "MENU_SELECT" )
		return true
	end, false )
	menu:AddButtonCallbackFunction( Camo, controller, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "R", function ( f130_arg0, f130_arg1, f130_arg2, f130_arg3 )
		if IsSelfModelValueGreaterThan( f130_arg0, f130_arg2, "camoIndex", 0 ) then
			Gunsmith_ClearCamo( self, f130_arg0, f130_arg2 )
			return true
		else
			
		end
	end, function ( f131_arg0, f131_arg1, f131_arg2 )
		if IsSelfModelValueGreaterThan( f131_arg0, f131_arg2, "camoIndex", 0 ) then
			CoD.Menu.SetButtonLabel( f131_arg1, Enum.LUIButton.LUI_KEY_XBX_PSSQUARE, "MENU_REMOVE" )
			return true
		else
			return false
		end
	end, false )
	Camo:mergeStateConditions( {
		{
			stateName = "IsEquipped",
			condition = function ( menu, element, event )
				return not IsSelfModelValueEqualTo( element, controller, "camoIndex", 0 )
			end
		},
		{
			stateName = "IsEquippedNoHintText",
			condition = function ( menu, element, event )
				return AlwaysFalse()
			end
		}
	} )
	Camo:linkToElementModel( Camo, "camoIndex", true, function ( modelRef )
		menu:updateElementState( Camo, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue( modelRef ),
			modelName = "camoIndex"
		} )
	end )
	self:addElement( Camo )
	self.Camo = Camo
	
	Optic.navigation = {
		right = Attachment1
	}
	Attachment1.navigation = {
		left = Optic,
		right = Attachment2
	}
	Attachment2.navigation = {
		left = Attachment1,
		right = Attachment3
	}
	Attachment3.navigation = {
		left = Attachment2,
		right = Attachment4
	}
	Attachment4.navigation = {
		left = Attachment3,
		right = Attachment5
	}
	Attachment5.navigation = {
		left = Attachment4,
		right = Attachment6
	}
	Attachment6.navigation = {
		left = Attachment5,
		right = Attachment7
	}
	Attachment7.navigation = {
		left = Attachment6,
		right = paintjob
	}
	paintjob.navigation = {
		left = Attachment7,
		right = Camo
	}
	Camo.navigation = {
		left = paintjob
	}
	local clipFunc = function ()
		self:setupElementClipCounter( 12 )
		opticCategoryHeader:completeAnimation()
		self.opticCategoryHeader:setLeftRight( true, false, 1, 64 )
		self.opticCategoryHeader:setTopBottom( true, false, 0, 17 )
		self.opticCategoryHeader:setAlpha( 1 )
		self.clipFinished( opticCategoryHeader, {} )
		attachCategoryHeader:completeAnimation()
		self.attachCategoryHeader:setLeftRight( true, true, 112.67, -245.9 )
		self.attachCategoryHeader:setTopBottom( true, false, 0, 17 )
		self.attachCategoryHeader:setAlpha( 1 )
		self.clipFinished( attachCategoryHeader, {} )
		Optic:completeAnimation()
		self.Optic:setLeftRight( true, false, 0, 64 )
		self.Optic:setTopBottom( true, false, 24, 88 )
		self.Optic:setAlpha( 1 )
		self.clipFinished( Optic, {} )
		Attachment1:completeAnimation()
		self.Attachment1:setLeftRight( true, false, 111.67, 175.67 )
		self.Attachment1:setTopBottom( true, false, 24, 88 )
		self.Attachment1:setAlpha( 1 )
		self.clipFinished( Attachment1, {} )
		Attachment2:completeAnimation()
		self.Attachment2:setLeftRight( true, false, 180.67, 244.67 )
		self.Attachment2:setTopBottom( true, false, 24, 88 )
		self.Attachment2:setAlpha( 1 )
		self.clipFinished( Attachment2, {} )
		Attachment3:completeAnimation()
		self.Attachment3:setLeftRight( true, false, 249.67, 313.67 )
		self.Attachment3:setTopBottom( true, false, 24, 88 )
		self.Attachment3:setAlpha( 1 )
		self.clipFinished( Attachment3, {} )
		Attachment4:completeAnimation()
		self.Attachment4:setLeftRight( true, false, 320.1, 384.1 )
		self.Attachment4:setTopBottom( true, false, 24, 88 )
		self.Attachment4:setAlpha( 1 )
		self.clipFinished( Attachment4, {} )
		Attachment5:completeAnimation()
		self.Attachment5:setLeftRight( true, false, 389.1, 453.1 )
		self.Attachment5:setTopBottom( true, false, 24, 88 )
		self.Attachment5:setAlpha( 1 )
		self.clipFinished( Attachment5, {} )
		Attachment6:completeAnimation()
		self.Attachment6:setLeftRight( true, false, 458.1, 522.1 )
		self.Attachment6:setTopBottom( true, false, 24, 88 )
		self.Attachment6:setAlpha( 1 )
		self.clipFinished( Attachment6, {} )
		Attachment7:completeAnimation()
		self.Attachment7:setLeftRight( true, false, 527.1, 591.1 )
		self.Attachment7:setTopBottom( true, false, 24, 88 )
		self.Attachment7:setAlpha( 1 )
		self.clipFinished( Attachment7, {} )
		paintjobCategoryHeader:completeAnimation()
		self.paintjobCategoryHeader:setLeftRight( true, false, 639.77, 717.77) -- 501.77, 579.77
		self.paintjobCategoryHeader:setTopBottom( true, false, 0, 17 )
		self.paintjobCategoryHeader:setAlpha( 1 )
		self.clipFinished( paintjobCategoryHeader, {} )
		camoCategoryHeader:completeAnimation()
		self.camoCategoryHeader:setLeftRight( true, false, 749.44, 813.44 ) -- 611.44, 675.44
		self.camoCategoryHeader:setTopBottom( true, false, 0, 17 )
		self.camoCategoryHeader:setAlpha( 1 )
		self.clipFinished( camoCategoryHeader, {} )
		paintjob:completeAnimation()
		self.paintjob:setLeftRight( true, false, 639.77, 703.77 )
		self.paintjob:setTopBottom( true, false, 24, 88 )
		self.paintjob:setAlpha( 1 )
		self.clipFinished( paintjob, {} )
		Camo:completeAnimation()
		self.Camo:setLeftRight( true, false, 749.44, 813.44 )
		self.Camo:setTopBottom( true, false, 24, 88 )
		self.Camo:setAlpha( 1 )
		self.clipFinished( Camo, {} )
	end
	self.clipsPerState = {
		DefaultState = {
			DefaultClip = clipFunc
		},
		SpecialWeapon = {
			DefaultClip = function ()
				self:setupElementClipCounter( 12 )
				opticCategoryHeader:completeAnimation()
				self.opticCategoryHeader:setAlpha( 0 )
				self.clipFinished( opticCategoryHeader, {} )
				attachCategoryHeader:completeAnimation()
				self.attachCategoryHeader:setAlpha( 0 )
				self.clipFinished( attachCategoryHeader, {} )
				Optic:completeAnimation()
				self.Optic:setAlpha( 0 )
				self.clipFinished( Optic, {} )
				Attachment1:completeAnimation()
				self.Attachment1:setAlpha( 0 )
				self.clipFinished( Attachment1, {} )
				Attachment2:completeAnimation()
				self.Attachment2:setAlpha( 0 )
				self.clipFinished( Attachment2, {} )
				Attachment3:completeAnimation()
				self.Attachment3:setAlpha( 0 )
				self.clipFinished( Attachment3, {} )
				Attachment4:completeAnimation()
				self.Attachment4:setAlpha( 0 )
				self.clipFinished( Attachment4, {} )
				Attachment5:completeAnimation()
				self.Attachment5:setAlpha( 0 )
				self.clipFinished( Attachment5, {} )
				Attachment6:completeAnimation()
				self.Attachment6:setAlpha( 0 )
				self.clipFinished( Attachment6, {} )
				Attachment7:completeAnimation()
				self.Attachment7:setAlpha( 0 )
				self.clipFinished( Attachment7, {} )
				paintjobCategoryHeader:completeAnimation()
				self.paintjobCategoryHeader:setLeftRight( true, false, 1, 79 )
				self.paintjobCategoryHeader:setTopBottom( true, false, 0, 17 )
				self.paintjobCategoryHeader:setAlpha( 1 )
				self.clipFinished( paintjobCategoryHeader, {} )
				camoCategoryHeader:completeAnimation()
				self.camoCategoryHeader:setLeftRight( true, false, 110.67, 176.67 )
				self.camoCategoryHeader:setTopBottom( true, false, 0, 17 )
				self.camoCategoryHeader:setAlpha( 1 )
				self.clipFinished( camoCategoryHeader, {} )
				paintjob:completeAnimation()
				self.paintjob:setLeftRight( true, false, 1, 65 )
				self.paintjob:setTopBottom( true, false, 24, 88 )
				self.paintjob:setAlpha( 1 )
				self.clipFinished( paintjob, {} )
				Camo:completeAnimation()
				self.Camo:setLeftRight( true, false, 110.67, 174.67 )
				self.Camo:setTopBottom( true, false, 24, 88 )
				self.Camo:setAlpha( 1 )
				self.clipFinished( Camo, {} )
			end
		},
		Handguns = {
			DefaultClip = clipFunc
		},
		Snipers = {
			DefaultClip = clipFunc
		}
	}
	self:mergeStateConditions( {
		{
			stateName = "SpecialWeapon",
			condition = function ( menu, element, event )
				return Gunsmith_IsSpecialWeapon( menu, element, controller )
			end
		},
		{
			stateName = "Handguns",
			condition = function ( menu, element, event )
				return Gunsmith_IsHandguns( menu, element, controller )
			end
		},
		{
			stateName = "Snipers",
			condition = function ( menu, element, event )
				return Gunsmith_IsSnipers( menu, element, controller )
			end
		}
	} )
	CoD.Menu.AddNavigationHandler( menu, self, controller )
	LUI.OverrideFunction_CallOriginalFirst( self, "setState", function ( element, controller )
		if IsElementInState( element, "SpecialWeapon" ) then
			MakeElementNotFocusable( self, "Attachment1", controller )
			MakeElementNotFocusable( self, "Attachment2", controller )
			MakeElementNotFocusable( self, "Attachment3", controller )
			MakeElementNotFocusable( self, "Attachment4", controller )
			MakeElementNotFocusable( self, "Attachment5", controller )
			MakeElementNotFocusable( self, "Attachment6", controller )
			MakeElementNotFocusable( self, "Attachment7", controller )
			MakeElementNotFocusable( self, "Optic", controller )
		end
	end )
	Optic.id = "Optic"
	Attachment1.id = "Attachment1"
	Attachment2.id = "Attachment2"
	Attachment3.id = "Attachment3"
	Attachment4.id = "Attachment4"
	Attachment5.id = "Attachment5"
	Attachment6.id = "Attachment6"
	Attachment7.id = "Attachment7"
	paintjob.id = "paintjob"
	Camo.id = "Camo"
	self:registerEventHandler( "gain_focus", function ( element, event )
		if element.m_focusable and element.Optic:processEvent( event ) then
			return true
		else
			return LUI.UIElement.gainFocus( element, event )
		end
	end )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		element.opticCategoryHeader:close()
		element.attachCategoryHeader:close()
		element.Optic:close()
		element.Attachment1:close()
		element.Attachment2:close()
		element.Attachment3:close()
		element.Attachment4:close()
		element.Attachment5:close()
		element.Attachment6:close()
		element.Attachment7:close()
		element.paintjobCategoryHeader:close()
		element.camoCategoryHeader:close()
		element.paintjob:close()
		element.Camo:close()
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller, menu )
	end
	
	return self
end

