local PostLoadFunc = function ( elem, controller )
	local xmodel = elem:getModel( controller, "x" )
	local ymodel = elem:getModel( controller, "y" )
	local redmodel = elem:getModel( controller, "red" )
	local greenmodel = elem:getModel( controller, "green" )
	local bluemodel = elem:getModel( controller, "blue" )
	elem.red = 1
	elem.green = 1
	elem.blue = 1
    elem.time = 0.0
    elem.alpha = 0.0
	if xmodel then
		elem:subscribeToModel( xmodel, function ( modelRef )
			local modelValue = Engine.GetModelValue( modelRef )
			if modelValue then
				elem.x = modelValue
				-- update position event
			end
		end )
	end
end

LUI.createMenu.ZBRScoreTracker = function ( controller )
	local self = CoD.Menu.NewForUIEditor( "ZBRScoreTracker" )
	if PreLoadFunc then
		PreLoadFunc( self, controller )
	end
	self.soundSet = "default"
	self:setOwner( controller )
	self:setLeftRight( true, true, 0, 0 ) -- TODO
	self:setTopBottom( true, true, 0, 0 ) -- TODO
	local f12_local1 = self
	
	local Timer = LUI.UITightText.new()
	Timer:setLeftRight( true, false, 317.45, 371.45 )
	Timer:setTopBottom( true, false, 324.11, 349.11 )
	Timer:setTTF( "fonts/default.ttf" )
	self:addElement( Timer )
	self.Timer = Timer
	
	self:processEvent( {
		name = "menu_loaded",
		controller = controller
	} )
	self:processEvent( {
		name = "update_state",
		menu = f12_local1
	} )
	LUI.OverrideFunction_CallOriginalSecond( self, "close", function ( element )
		-- Engine.UnsubscribeAndFreeModel( Engine.GetModel( Engine.GetModelForController( controller ), "HudElementTimer.buttonPrompts" ) )
	end )
	
	if PostLoadFunc then
		PostLoadFunc( self, controller )
	end
	
	return self
end