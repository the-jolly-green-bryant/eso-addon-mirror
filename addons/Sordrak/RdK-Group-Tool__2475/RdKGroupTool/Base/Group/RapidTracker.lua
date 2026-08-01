-- RdK Group Rapid Tracker
-- By @s0rdrak (PC / EU)

RdKGTool.group.rt = RdKGTool.group.rt or {}
local RdKGToolRt = RdKGTool.group.rt
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolGroup = RdKGToolUtil.group

RdKGToolRt.constants = RdKGToolRt.constants or {}
RdKGToolRt.constants.TLW_NAME = "RdKGTool.group.tr.TLW"

RdKGToolRt.callbackName = RdKGTool.addonName .. "RapidTracker"

RdKGToolRt.config = {}
RdKGToolRt.config.updateInterval = 100
RdKGToolRt.config.isClampedToScreen = true
RdKGToolRt.config.font = "ZoFontGameSmall"

RdKGToolRt.state = {}
RdKGToolRt.state.initialized = false
RdKGToolRt.state.foreground = true
RdKGToolRt.state.registeredConsumer = false
RdKGToolRt.state.registredActiveConsumers = false
RdKGToolRt.state.activeLayerIndex = 1

RdKGToolRt.controls = {}

local wm = WINDOW_MANAGER

function RdKGToolRt.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolRt.callbackName, RdKGToolRt.OnProfileChanged)
	
	RdKGToolRt.CreateUI()
	
	RdKGToolMenu.AddPositionFixedConsumer(RdKGToolRt.SetRtPositionLocked)
	
	RdKGToolRt.state.initialized = true
	RdKGToolRt.AdjustColors()
	RdKGToolRt.SetEnabled(RdKGToolRt.rtVars.enabled)
	RdKGToolRt.SetMovable(not RdKGToolRt.rtVars.positionLocked)

	--EVENT_MANAGER:RegisterForEvent(RdKGToolRt.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolRt.SetVisible)
	--EVENT_MANAGER:RegisterForEvent(RdKGToolRt.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolRt.SetVisible)

end

function RdKGToolRt.GetDefaults()
	local defaults = {}
	defaults.enabled = false
	defaults.pvponly = true
	defaults.colors = {}
	defaults.colors.inRange = {}
	defaults.colors.inRange.r = 0
	defaults.colors.inRange.g = 1
	defaults.colors.inRange.b = 0
	defaults.colors.outOfRange = {}
	defaults.colors.outOfRange.r = 1
	defaults.colors.outOfRange.g = 1
	defaults.colors.outOfRange.b = 1
	defaults.colors.notInRange = {}
	defaults.colors.notInRange.r = 1
	defaults.colors.notInRange.g = 0
	defaults.colors.notInRange.b = 0
	defaults.colors.rapidOn = {}
	defaults.colors.rapidOn.r = 0
	defaults.colors.rapidOn.g = 1
	defaults.colors.rapidOn.b = 0
	defaults.colors.rapidOff = {}
	defaults.colors.rapidOff.r = 1
	defaults.colors.rapidOff.g = 0
	defaults.colors.rapidOff.b = 0
	defaults.positionLocked = true
	return defaults
end

function RdKGToolRt.SetEnabled(value)
	if RdKGToolRt.state.initialized == true and value ~= nil then
		RdKGToolRt.rtVars.enabled = value
		if value == true then
			if RdKGToolRt.state.registeredConsumer == false then

				EVENT_MANAGER:RegisterForEvent(RdKGToolRt.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolRt.OnPlayerActivated)
				
				RdKGToolRt.state.registeredConsumer = true
			end
		else
			if RdKGToolRt.state.registeredConsumer == true then
				
				EVENT_MANAGER:UnregisterForEvent(RdKGToolRt.callbackName, EVENT_PLAYER_ACTIVATED)
				
				RdKGToolRt.state.registeredConsumer = false
			end
		end
		RdKGToolRt.OnPlayerActivated()
	end
end

function RdKGToolRt.CreatePlayerControl(parent, offsetHeight, offsetWidth, height, labelWidth, countWidth)
	local playerControl = wm:CreateControl(nil, parent, CT_CONTROL)
	playerControl:SetAnchor(TOPLEFT, parent, TOPLEFT, offsetWidth, offsetHeight)
	playerControl:SetDimensions(labelWidth + countWidth, height)
	playerControl:SetHidden(true)
	
	playerControl.playerLabel = wm:CreateControl(nil, playerControl, CT_LABEL)
	playerControl.playerLabel:SetDimensions(labelWidth, height)
	playerControl.playerLabel:SetAnchor(TOPLEFT, playerControl, TOPLEFT, 0, 0)
	playerControl.playerLabel:SetFont(RdKGToolRt.config.font)
	playerControl.playerLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT) 
	playerControl.playerLabel:SetText("")
	
	
	playerControl.majorExpeditionStatus = wm:CreateControl(nil, playerControl, CT_BACKDROP)
	playerControl.majorExpeditionStatus:SetDimensions(countWidth, height)
	playerControl.majorExpeditionStatus:SetAnchor(TOPLEFT, playerControl, TOPLEFT, labelWidth, 3)
	
	playerControl.majorExpeditionStatusbar = wm:CreateControl(nil, playerControl, CT_STATUSBAR)
	playerControl.majorExpeditionStatusbar:SetDimensions(countWidth, height)
	playerControl.majorExpeditionStatusbar:SetAnchor(TOPLEFT, playerControl, TOPLEFT, labelWidth, 3)
	playerControl.majorExpeditionStatusbar:SetMinMax(0, 100)
	playerControl.majorExpeditionStatusbar:SetValue(0)
	
	playerControl.minorExpeditionStatus = wm:CreateControl(nil, playerControl, CT_BACKDROP)
	playerControl.minorExpeditionStatus:SetDimensions(countWidth, height)
	playerControl.minorExpeditionStatus:SetAnchor(TOPLEFT, playerControl, TOPLEFT, labelWidth + countWidth * 1 + (2 * 1), 3)
	
	playerControl.minorExpeditionStatusbar = wm:CreateControl(nil, playerControl, CT_STATUSBAR)
	playerControl.minorExpeditionStatusbar:SetDimensions(countWidth, height)
	playerControl.minorExpeditionStatusbar:SetAnchor(TOPLEFT, playerControl, TOPLEFT, labelWidth + countWidth * 1 + (2 * 1), 3)
	playerControl.minorExpeditionStatusbar:SetMinMax(0, 100)
	playerControl.minorExpeditionStatusbar:SetValue(0)
	
	--[[
	playerControl.rapidManeuverStatus = wm:CreateControl(nil, playerControl, CT_BACKDROP)
	playerControl.rapidManeuverStatus:SetDimensions(countWidth, height)
	playerControl.rapidManeuverStatus:SetAnchor(TOPLEFT, playerControl, TOPLEFT, labelWidth + countWidth * 2 + (2 * 2), 3)
	
	playerControl.rapidManeuverStatusbar = wm:CreateControl(nil, playerControl, CT_STATUSBAR)
	playerControl.rapidManeuverStatusbar:SetDimensions(countWidth, height)
	playerControl.rapidManeuverStatusbar:SetAnchor(TOPLEFT, playerControl, TOPLEFT, labelWidth + countWidth * 2 + (2 * 2), 3)
	playerControl.rapidManeuverStatusbar:SetMinMax(0, 100)
	playerControl.rapidManeuverStatusbar:SetValue(0)
	
	playerControl.chargingManeuverMinorStatus = wm:CreateControl(nil, playerControl, CT_BACKDROP)
	playerControl.chargingManeuverMinorStatus:SetDimensions(countWidth, height)
	playerControl.chargingManeuverMinorStatus:SetAnchor(TOPLEFT, playerControl, TOPLEFT, labelWidth + countWidth * 3 + (2 * 3), 3)
	
	playerControl.chargingManeuverMinorStatusbar = wm:CreateControl(nil, playerControl, CT_STATUSBAR)
	playerControl.chargingManeuverMinorStatusbar:SetDimensions(countWidth, height)
	playerControl.chargingManeuverMinorStatusbar:SetAnchor(TOPLEFT, playerControl, TOPLEFT, labelWidth + countWidth * 3 + (2 * 3), 3)
	playerControl.chargingManeuverMinorStatusbar:SetMinMax(0, 100)
	playerControl.chargingManeuverMinorStatusbar:SetValue(0)
	]]
	return playerControl
end

function RdKGToolRt.SetTlwLocation()
	RdKGToolRt.controls.TLW:ClearAnchors()
	if RdKGToolRt.rtVars.location == nil then
		RdKGToolRt.controls.TLW:SetAnchor(CENTER, GuiRoot, CENTER, 250, 150)
	else
		RdKGToolRt.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolRt.rtVars.location.x, RdKGToolRt.rtVars.location.y)
	end
end

function RdKGToolRt.CreateUI()
	local height = 12 * 10 + 11 * 3
	local width = (2 * 85) + (4 * 20) + 10 + (3 * 2)
	RdKGToolRt.controls.TLW = wm:CreateTopLevelWindow(RdKGToolRt.constants.TLW_NAME)
	
	RdKGToolRt.SetTlwLocation()
	
		
	RdKGToolRt.controls.TLW:SetClampedToScreen(RdKGToolRt.config.isClampedToScreen)
	RdKGToolRt.controls.TLW:SetDrawLayer(0)
	RdKGToolRt.controls.TLW:SetDrawLevel(0)
	RdKGToolRt.controls.TLW:SetHandler("OnMoveStop", RdKGToolRt.SaveWindowLocation)
	RdKGToolRt.controls.TLW:SetDimensions(width, height)
	RdKGToolRt.controls.TLW:SetHidden(not RdKGToolRt.rtVars.enabled)
	
	RdKGToolRt.controls.tlwControl = wm:CreateControl(nil, RdKGToolRt.controls.TLW, CT_CONTROL)
	RdKGToolRt.controls.tlwControl:SetDimensions(width, height)
	RdKGToolRt.controls.tlwControl:SetAnchor(TOPLEFT, RdKGToolRt.controls.TLW, TOPLEFT, 0, 0)
	
	RdKGToolRt.controls.tlwControl.movableBackdrop = wm:CreateControl(nil, RdKGToolRt.controls.tlwControl, CT_BACKDROP)
	
	RdKGToolRt.controls.tlwControl.movableBackdrop:SetAnchor(TOPLEFT, RdKGToolRt.controls.tlwControl, TOPLEFT, 0, 0)
	RdKGToolRt.controls.tlwControl.movableBackdrop:SetDimensions(width, height)
	
	RdKGToolRt.controls.tlwControl.playerControls = {}
	
	for i = 1, 24 do
		local offset = 0
		if i > 12 then
			offset = 141
		end
		local itemIndex = i - 1
		if itemIndex > 11 then
			itemIndex = itemIndex - 12
		end
		RdKGToolRt.controls.tlwControl.playerControls[i] = RdKGToolRt.CreatePlayerControl(RdKGToolRt.controls.tlwControl.movableBackdrop, itemIndex * (10 + 3), offset, 10, 85, 20)
	end
end

function RdKGToolRt.AdjustColors()
	for i = 1, #RdKGToolRt.controls.tlwControl.playerControls do
		RdKGToolRt.controls.tlwControl.playerControls[i].majorExpeditionStatus:SetCenterColor(RdKGToolRt.rtVars.colors.rapidOff.r, RdKGToolRt.rtVars.colors.rapidOff.g, RdKGToolRt.rtVars.colors.rapidOff.b)
		RdKGToolRt.controls.tlwControl.playerControls[i].majorExpeditionStatus:SetEdgeColor(RdKGToolRt.rtVars.colors.rapidOff.r, RdKGToolRt.rtVars.colors.rapidOff.g, RdKGToolRt.rtVars.colors.rapidOff.b)
		RdKGToolRt.controls.tlwControl.playerControls[i].minorExpeditionStatus:SetCenterColor(RdKGToolRt.rtVars.colors.rapidOff.r, RdKGToolRt.rtVars.colors.rapidOff.g, RdKGToolRt.rtVars.colors.rapidOff.b)
		RdKGToolRt.controls.tlwControl.playerControls[i].minorExpeditionStatus:SetEdgeColor(RdKGToolRt.rtVars.colors.rapidOff.r, RdKGToolRt.rtVars.colors.rapidOff.g, RdKGToolRt.rtVars.colors.rapidOff.b)
		--[[
		RdKGToolRt.controls.tlwControl.playerControls[i].rapidManeuverStatus:SetCenterColor(RdKGToolRt.rtVars.colors.rapidOff.r, RdKGToolRt.rtVars.colors.rapidOff.g, RdKGToolRt.rtVars.colors.rapidOff.b)
		RdKGToolRt.controls.tlwControl.playerControls[i].rapidManeuverStatus:SetEdgeColor(RdKGToolRt.rtVars.colors.rapidOff.r, RdKGToolRt.rtVars.colors.rapidOff.g, RdKGToolRt.rtVars.colors.rapidOff.b)
		RdKGToolRt.controls.tlwControl.playerControls[i].chargingManeuverMinorStatus:SetCenterColor(RdKGToolRt.rtVars.colors.rapidOff.r, RdKGToolRt.rtVars.colors.rapidOff.g, RdKGToolRt.rtVars.colors.rapidOff.b)
		RdKGToolRt.controls.tlwControl.playerControls[i].chargingManeuverMinorStatus:SetEdgeColor(RdKGToolRt.rtVars.colors.rapidOff.r, RdKGToolRt.rtVars.colors.rapidOff.g, RdKGToolRt.rtVars.colors.rapidOff.b)
		]]
		RdKGToolRt.controls.tlwControl.playerControls[i].majorExpeditionStatusbar:SetColor(RdKGToolRt.rtVars.colors.rapidOn.r, RdKGToolRt.rtVars.colors.rapidOn.g, RdKGToolRt.rtVars.colors.rapidOn.b)
		RdKGToolRt.controls.tlwControl.playerControls[i].minorExpeditionStatusbar:SetColor(RdKGToolRt.rtVars.colors.rapidOn.r, RdKGToolRt.rtVars.colors.rapidOn.g, RdKGToolRt.rtVars.colors.rapidOn.b)
		--[[
		RdKGToolRt.controls.tlwControl.playerControls[i].rapidManeuverStatusbar:SetColor(RdKGToolRt.rtVars.colors.rapidOn.r, RdKGToolRt.rtVars.colors.rapidOn.g, RdKGToolRt.rtVars.colors.rapidOn.b)
		RdKGToolRt.controls.tlwControl.playerControls[i].chargingManeuverMinorStatusbar:SetColor(RdKGToolRt.rtVars.colors.rapidOn.r, RdKGToolRt.rtVars.colors.rapidOn.g, RdKGToolRt.rtVars.colors.rapidOn.b)
		]]
	end
end

function RdKGToolRt.SetMovable(isMovable)
	RdKGToolRt.rtVars.positionLocked = not isMovable
	RdKGToolRt.controls.TLW:SetMovable(isMovable)
	RdKGToolRt.controls.TLW:SetMouseEnabled(isMovable)
	RdKGToolRt.SetBackdropColors()
end


function RdKGToolRt.SetBackdropColors()
	if RdKGToolRt.rtVars.positionLocked == false then
		RdKGToolRt.controls.tlwControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolRt.controls.tlwControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	else
		RdKGToolRt.controls.tlwControl.movableBackdrop:SetCenterColor(0, 0, 0, 0.0)
		RdKGToolRt.controls.tlwControl.movableBackdrop:SetEdgeColor(0, 0, 0, 0.0)	
	end
end

function RdKGToolRt.AdjustRapidControl(control, buff, currentTime)
	
	if buff.active == true then
		local uptimeLeft = buff.ending - currentTime
		if uptimeLeft < 0 then
			uptimeLeft = 0
		end
		--d(buffUp)
		--control:SetCenterColor(RdKGToolRt.rtVars.colors.rapidOn.r, RdKGToolRt.rtVars.colors.rapidOn.g, RdKGToolRt.rtVars.colors.rapidOn.b)
		--control:SetEdgeColor(RdKGToolRt.rtVars.colors.rapidOn.r, RdKGToolRt.rtVars.colors.rapidOn.g, RdKGToolRt.rtVars.colors.rapidOn.b)
		control:SetValue(uptimeLeft / buff.uptime * 100)
		--d(control:GetValue())
	else
		--control:SetCenterColor(RdKGToolRt.rtVars.colors.rapidOff.r, RdKGToolRt.rtVars.colors.rapidOff.g, RdKGToolRt.rtVars.colors.rapidOff.b)
		--control:SetEdgeColor(RdKGToolRt.rtVars.colors.rapidOff.r, RdKGToolRt.rtVars.colors.rapidOff.g, RdKGToolRt.rtVars.colors.rapidOff.b)
		control:SetValue(0)
	end

end

function RdKGToolRt.SetControlVisibility()
	local enabled = RdKGToolRt.rtVars.enabled
	local pvpOnly = RdKGToolRt.rtVars.pvponly
	local setHidden = true
	if enabled ~= nil and pvpOnly ~= nil then

		if enabled == true and (pvpOnly == false or (pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
			setHidden = false
		end
	end
	if setHidden == false then
		if RdKGToolRt.state.foreground == false then
			RdKGToolRt.controls.TLW:SetHidden(RdKGToolRt.state.activeLayerIndex > 2)
		else
			RdKGToolRt.controls.TLW:SetHidden(false)
		end
	else
		RdKGToolRt.controls.TLW:SetHidden(setHidden)
	end
end

--callbacks
function RdKGToolRt.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolRt.rtVars = currentProfile.group.rt
		if RdKGToolRt.state.initialized == true then
			RdKGToolRt.SetMovable(not RdKGToolRt.rtVars.positionLocked)
			RdKGToolRt.SetTlwLocation()
			RdKGToolRt.AdjustColors()
		end
		RdKGToolRt.SetEnabled(RdKGToolRt.rtVars.enabled)
		
	end
end

function RdKGToolRt.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolRt.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolRt.state.foreground = false
	end
	--hack?
	RdKGToolRt.state.activeLayerIndex = activeLayerIndex
	
	RdKGToolRt.SetControlVisibility()
end

function RdKGToolRt.OnPlayerActivated(eventCode, initial)
	if RdKGToolRt.rtVars.enabled == true and (RdKGToolRt.rtVars.pvponly == true and RdKGToolUtil.IsInPvPArea() == true or RdKGToolRt.rtVars.pvponly == false) then
		if RdKGToolRt.state.registredActiveConsumers == false then
			EVENT_MANAGER:RegisterForEvent(RdKGToolRt.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolRt.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForEvent(RdKGToolRt.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolRt.SetForegroundVisibility)
			RdKGToolGroup.AddFeature(RdKGToolRt.callbackName, RdKGToolGroup.features.FEATURE_GROUP_BUFFS, RdKGToolRt.config.updateInterval)
			RdKGToolGroup.AddFeature(RdKGToolRt.callbackName, RdKGToolGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE, RdKGToolRt.config.updateInterval)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolRt.callbackName, RdKGToolRt.config.updateInterval, RdKGToolRt.OnUpdate)
			
			RdKGToolRt.state.registredActiveConsumers = true
		end
	else
		if RdKGToolRt.state.registredActiveConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(RdKGToolRt.callbackName, EVENT_ACTION_LAYER_POPPED)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolRt.callbackName, EVENT_ACTION_LAYER_PUSHED)
			RdKGToolGroup.RemoveFeature(RdKGToolRt.callbackName, RdKGToolGroup.features.FEATURE_GROUP_BUFFS)
			RdKGToolGroup.RemoveFeature(RdKGToolRt.callbackName, RdKGToolGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE)
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolRt.callbackName)
			
			RdKGToolRt.state.registredActiveConsumers = false
		end
	end
	RdKGToolRt.SetControlVisibility()
end

function RdKGToolRt.OnUpdate()
	
	if RdKGToolRt.rtVars.enabled then
		local pvpZone = RdKGToolUtil.IsInPvPArea()
		if RdKGToolRt.rtVars.pvponly == true and pvpZone == true or RdKGToolRt.rtVars.pvponly == false then
			local players = RdKGToolGroup.GetGroupInformation()
			local currentTime = GetGameTimeMilliseconds() / 1000
			--temp = players
			if players ~= nil then

				for i = 1, #players do
					local buffs = players[i].buffs
					if buffs ~= nil and buffs.specialInformation ~= nil then
						RdKGToolRt.AdjustRapidControl(RdKGToolRt.controls.tlwControl.playerControls[i].majorExpeditionStatusbar, buffs.specialInformation.majorExpeditionOn, currentTime)
						RdKGToolRt.AdjustRapidControl(RdKGToolRt.controls.tlwControl.playerControls[i].minorExpeditionStatusbar, buffs.specialInformation.minorExpeditionOn, currentTime)
						--[[
						RdKGToolRt.AdjustRapidControl(RdKGToolRt.controls.tlwControl.playerControls[i].rapidManeuverStatusbar, buffs.specialInformation.rapidManeuverOn, currentTime)
						RdKGToolRt.AdjustRapidControl(RdKGToolRt.controls.tlwControl.playerControls[i].chargingManeuverMinorStatusbar, buffs.specialInformation.chargingManeuverMinorOn, currentTime)
						]]
						
					end
					
					local distance = players[i].distances.fromPlayer
					if distance == nil then
						distance = 0
					end
					if distance <= 20 then
						RdKGToolRt.controls.tlwControl.playerControls[i].playerLabel:SetColor(RdKGToolRt.rtVars.colors.inRange.r, RdKGToolRt.rtVars.colors.inRange.g, RdKGToolRt.rtVars.colors.inRange.b)
					elseif distance > 20 and distance < 100 then
						RdKGToolRt.controls.tlwControl.playerControls[i].playerLabel:SetColor(RdKGToolRt.rtVars.colors.notInRange.r, RdKGToolRt.rtVars.colors.notInRange.g, RdKGToolRt.rtVars.colors.notInRange.b)
					else
						RdKGToolRt.controls.tlwControl.playerControls[i].playerLabel:SetColor(RdKGToolRt.rtVars.colors.outOfRange.r, RdKGToolRt.rtVars.colors.outOfRange.g, RdKGToolRt.rtVars.colors.outOfRange.b)
						--RdKGToolRt.controls.tlwControl.playerControls[i].majorExpeditionStatus:SetCenterColor(RdKGToolRt.rtVars.colors.outOfRange.r, RdKGToolRt.rtVars.colors.outOfRange.g, RdKGToolRt.rtVars.colors.outOfRange.b)
						--RdKGToolRt.controls.tlwControl.playerControls[i].majorExpeditionStatus:SetEdgeColor(RdKGToolRt.rtVars.colors.outOfRange.r, RdKGToolRt.rtVars.colors.outOfRange.g, RdKGToolRt.rtVars.colors.outOfRange.b)
					end
					RdKGToolRt.controls.tlwControl.playerControls[i].playerLabel:SetText(players[i].name)
					RdKGToolRt.controls.tlwControl.playerControls[i]:SetHidden(false)
				end
				for i = #players + 1, 24 do
					RdKGToolRt.controls.tlwControl.playerControls[i]:SetHidden(true)
					RdKGToolRt.controls.tlwControl.playerControls[i].playerLabel:SetText("")
					--RdKGToolRt.controls.tlwControl.playerControls[i].majorExpeditionStatus:SetCenterColor(RdKGToolRt.rtVars.colors.outOfRange.r, RdKGToolRt.rtVars.colors.outOfRange.g, RdKGToolRt.rtVars.colors.outOfRange.b, 0)
					--RdKGToolRt.controls.tlwControl.playerControls[i].majorExpeditionStatus:SetEdgeColor(RdKGToolRt.rtVars.colors.outOfRange.r, RdKGToolRt.rtVars.colors.outOfRange.g, RdKGToolRt.rtVars.colors.outOfRange.b, 0)
					--RdKGToolRt.controls.tlwControl.playerControls[i].minorExpeditionStatus:SetCenterColor(RdKGToolRt.rtVars.colors.outOfRange.r, RdKGToolRt.rtVars.colors.outOfRange.g, RdKGToolRt.rtVars.colors.outOfRange.b, 0)
					--RdKGToolRt.controls.tlwControl.playerControls[i].minorExpeditionStatus:SetEdgeColor(RdKGToolRt.rtVars.colors.outOfRange.r, RdKGToolRt.rtVars.colors.outOfRange.g, RdKGToolRt.rtVars.colors.outOfRange.b, 0)
					--RdKGToolRt.controls.tlwControl.playerControls[i].rapidManeuverStatus:SetCenterColor(RdKGToolRt.rtVars.colors.outOfRange.r, RdKGToolRt.rtVars.colors.outOfRange.g, RdKGToolRt.rtVars.colors.outOfRange.b, 0)
					--RdKGToolRt.controls.tlwControl.playerControls[i].rapidManeuverStatus:SetEdgeColor(RdKGToolRt.rtVars.colors.outOfRange.r, RdKGToolRt.rtVars.colors.outOfRange.g, RdKGToolRt.rtVars.colors.outOfRange.b, 0)
					--RdKGToolRt.controls.tlwControl.playerControls[i].chargingManeuverMinorStatus:SetCenterColor(RdKGToolRt.rtVars.colors.outOfRange.r, RdKGToolRt.rtVars.colors.outOfRange.g, RdKGToolRt.rtVars.colors.outOfRange.b, 0)
					--RdKGToolRt.controls.tlwControl.playerControls[i].chargingManeuverMinorStatus:SetEdgeColor(RdKGToolRt.rtVars.colors.outOfRange.r, RdKGToolRt.rtVars.colors.outOfRange.g, RdKGToolRt.rtVars.colors.outOfRange.b, 0)
				end
				
				if RdKGToolRt.state.foreground == true then
					RdKGToolRt.controls.TLW:SetHidden(false)
				end
			end
		else
			RdKGToolRt.controls.TLW:SetHidden(true)
		end
	else
		RdKGToolRt.controls.TLW:SetHidden(true)
	end
end

--[[
function RdKGToolRt.SetVisible(eventCode, layerIndex, activeLayerIndex)
	local pvpZone = RdKGToolUtil.IsInPvPArea()
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolRt.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolRt.state.foreground = false
	end
	if RdKGToolRt.rtVars.enabled == true and (RdKGToolRt.rtVars.pvponly == true and pvpZone == true or RdKGToolRt.rtVars.pvponly == false) then
		RdKGToolRt.controls.TLW:SetHidden(activeLayerIndex > 2)
	else
		RdKGToolRt.controls.TLW:SetHidden(true)
	end
end
]]

function RdKGToolRt.SaveWindowLocation()
	if RdKGToolRt.rtVars.positionLocked == false then
		RdKGToolRt.rtVars.location = RdKGToolRt.rtVars.location or {}
		RdKGToolRt.rtVars.location.x = RdKGToolRt.controls.TLW:GetLeft()
		RdKGToolRt.rtVars.location.y = RdKGToolRt.controls.TLW:GetTop()
	end
end

--menu interaction
function RdKGToolRt.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.RT_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RT_ENABLED,
					getFunc = RdKGToolRt.GetRtEnabled,
					setFunc = RdKGToolRt.SetRtEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RT_PVP_ONLY,
					getFunc = RdKGToolRt.GetRtPvpOnly,
					setFunc = RdKGToolRt.SetRtPvpOnly,
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RT_POSITION_FIXED,
					getFunc = RdKGToolRt.GetRtPositionLocked,
					setFunc = RdKGToolRt.SetRtPositionLocked,
				},
				[4] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RT_COLOR_LABEL_IN_RANGE,
					getFunc = RdKGToolRt.GetRtColorLabelInRange,
					setFunc = RdKGToolRt.SetRtColorLabelInRange,
					width = "full"
				},
				[5] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RT_COLOR_LABEL_NOT_IN_RANGE,
					getFunc = RdKGToolRt.GetRtColorLabelNotInRange,
					setFunc = RdKGToolRt.SetRtColorLabelNotInRange,
					width = "full"
				},
				[6] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RT_COLOR_LABEL_OUT_OF_RANGE,
					getFunc = RdKGToolRt.GetRtColorLabelOutOfRange,
					setFunc = RdKGToolRt.SetRtColorLabelOutOfRange,
					width = "full"
				},
				[7] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RT_COLOR_RAPID_ON,
					getFunc = RdKGToolRt.GetRtColorRapidOn,
					setFunc = RdKGToolRt.SetRtColorRapidOn,
					width = "full"
				},
				[8] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RT_COLOR_RAPID_OFF,
					getFunc = RdKGToolRt.GetRtColorRapidOff,
					setFunc = RdKGToolRt.SetRtColorRapidOff,
					width = "full"
				},
			}		
		},
	}
	return menu
end

function RdKGToolRt.GetRtEnabled()
	return RdKGToolRt.rtVars.enabled
end

function RdKGToolRt.SetRtEnabled(value)
	RdKGToolRt.SetEnabled(value)
end

function RdKGToolRt.GetRtPvpOnly()
	return RdKGToolRt.rtVars.pvponly
end

function RdKGToolRt.SetRtPvpOnly(value)
	RdKGToolRt.rtVars.pvponly = value
end

function RdKGToolRt.GetRtPositionLocked()
	return RdKGToolRt.rtVars.positionLocked
end

function RdKGToolRt.SetRtPositionLocked(value)
	RdKGToolRt.SetMovable(not value)
end

function RdKGToolRt.GetRtColorLabelInRange()
	return RdKGToolMenu.GetRGBColor(RdKGToolRt.rtVars.colors.inRange)
end

function RdKGToolRt.SetRtColorLabelInRange(r, g, b)
	RdKGToolRt.rtVars.colors.inRange = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolRt.GetRtColorLabelNotInRange()
	return RdKGToolMenu.GetRGBColor(RdKGToolRt.rtVars.colors.notInRange)
end

function RdKGToolRt.SetRtColorLabelNotInRange(r, g, b)
	RdKGToolRt.rtVars.colors.notInRange = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolRt.GetRtColorLabelOutOfRange()
	return RdKGToolMenu.GetRGBColor(RdKGToolRt.rtVars.colors.outOfRange)
end

function RdKGToolRt.SetRtColorLabelOutOfRange(r, g, b)
	RdKGToolRt.rtVars.colors.outOfRange = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolRt.GetRtColorRapidOn()
	return RdKGToolMenu.GetRGBColor(RdKGToolRt.rtVars.colors.rapidOn)
end

function RdKGToolRt.SetRtColorRapidOn(r, g, b)
	RdKGToolRt.rtVars.colors.rapidOn = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolRt.AdjustColors()
end

function RdKGToolRt.GetRtColorRapidOff()
	return RdKGToolMenu.GetRGBColor(RdKGToolRt.rtVars.colors.rapidOff)
end

function RdKGToolRt.SetRtColorRapidOff(r, g, b)
	RdKGToolRt.rtVars.colors.rapidOff = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolRt.AdjustColors()
end
