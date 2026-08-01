-- RdK Group Tool Follow The Crown Warnings
-- By @s0rdrak (PC / EU)

RdKGTool.group.ftcw = RdKGTool.group.ftcw or {}
local RdKGToolFtcw = RdKGTool.group.ftcw
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util or {}
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolGroup = RdKGToolUtil.group


RdKGToolFtcw.callbackName = RdKGTool.addonName .. "FollowTheCrownWarnings"

local wm = GetWindowManager()

RdKGToolFtcw.config = {}
RdKGToolFtcw.config.isClampedToScreen = true
RdKGToolFtcw.config.initialMeterOffset = 100
RdKGToolFtcw.config.updateInterval = 100
RdKGToolFtcw.config.fontDistance = "$(BOLD_FONT)|$(KB_20)soft-shadow-thick"
RdKGToolFtcw.config.fontWarning = "$(BOLD_FONT)|$(KB_40)soft-shadow-thick"

RdKGToolFtcw.controls = {}

RdKGToolFtcw.constants = {}
RdKGToolFtcw.constants.TLW_METER_NAME = "RdKGToolGroupFtcwMeterTLW"
RdKGToolFtcw.constants.TLW_WARNING_NAME = "RdKGToolGroupFtcwWarningTLW"

RdKGToolFtcw.state = {}
RdKGToolFtcw.state.initialized = false
RdKGToolFtcw.state.registeredConsumer = false
RdKGToolFtcw.state.registredActiveConsumers = false
RdKGToolFtcw.state.activeLayerIndex = 1


function RdKGToolFtcw.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolFtcw.callbackName, RdKGToolFtcw.OnProfileChanged)
	--Meter Display
	RdKGToolFtcw.controls.TLW_Meter = wm:CreateTopLevelWindow(RdKGToolFtcw.constants.TLW_RETICLE_NAME)
	RdKGToolFtcw.controls.TLW_Meter:SetDimensions(100, 40)

		
	RdKGToolFtcw.controls.TLW_Meter:SetClampedToScreen(RdKGToolFtcw.config.isClampedToScreen)
	RdKGToolFtcw.controls.TLW_Meter:SetDrawLayer(0)
	RdKGToolFtcw.controls.TLW_Meter:SetDrawLevel(0)
	RdKGToolFtcw.controls.TLW_Meter:SetHandler("OnMoveStop", RdKGToolFtcw.SaveWindowLocation)
	
	RdKGToolFtcw.controls.meter = wm:CreateControl(nil, RdKGToolFtcw.controls.TLW_Meter, CT_CONTROL)
	RdKGToolFtcw.controls.meter:SetDimensions(100, 40)
	RdKGToolFtcw.controls.meter:SetAnchor(TOPLEFT, RdKGToolFtcw.controls.TLW_Meter, TOPLEFT, 0, 0)
	
	RdKGToolFtcw.controls.meter.movableBackdrop = wm:CreateControl(nil, RdKGToolFtcw.controls.meter, CT_BACKDROP)
	
	RdKGToolFtcw.controls.meter.movableBackdrop:SetAnchor(TOPLEFT, RdKGToolFtcw.controls.meter, TOPLEFT, 0, 0)
	RdKGToolFtcw.controls.meter.movableBackdrop:SetDimensions(100, 40)

		
	
	RdKGToolFtcw.controls.meter.label = wm:CreateControl(nil, RdKGToolFtcw.controls.meter.movableBackdrop, CT_LABEL)
	RdKGToolFtcw.controls.meter.label:SetDimensions(80, 26)
	RdKGToolFtcw.controls.meter.label:SetAnchor(CENTER, RdKGToolFtcw.controls.meter, CENTER, 0, 0)
	RdKGToolFtcw.controls.meter.label:SetFont(RdKGToolFtcw.config.fontDistance)
	RdKGToolFtcw.controls.meter.label:SetText("")
	RdKGToolFtcw.controls.meter.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER) 
	RdKGToolFtcw.controls.meter.label:SetColor(RdKGToolFtcw.ftcwVars.distanceColor.r, RdKGToolFtcw.ftcwVars.distanceColor.g, RdKGToolFtcw.ftcwVars.distanceColor.b)
	
	
	
	--Warning Display
	RdKGToolFtcw.controls.TLW_Warning = wm:CreateTopLevelWindow(RdKGToolFtcw.constants.TLW_WARNING_NAME)
	RdKGToolFtcw.controls.TLW_Warning:SetDimensions(600, 60)

		
	RdKGToolFtcw.controls.TLW_Warning:SetClampedToScreen(RdKGToolFtcw.config.isClampedToScreen)
	RdKGToolFtcw.controls.TLW_Warning:SetDrawLayer(0)
	RdKGToolFtcw.controls.TLW_Warning:SetDrawLevel(0)
	RdKGToolFtcw.controls.TLW_Warning:SetHandler("OnMoveStop", RdKGToolFtcw.SaveWindowLocation)
	
	RdKGToolFtcw.controls.warning = wm:CreateControl(nil, RdKGToolFtcw.controls.TLW_Warning, CT_CONTROL)
	RdKGToolFtcw.controls.warning:SetDimensions(600, 60)
	RdKGToolFtcw.controls.warning:SetAnchor(TOPLEFT, RdKGToolFtcw.controls.TLW_Warning, TOPLEFT, 0, 0)
	
	RdKGToolFtcw.controls.warning.movableBackdrop = wm:CreateControl(nil, RdKGToolFtcw.controls.warning, CT_BACKDROP)
	
	RdKGToolFtcw.controls.warning.movableBackdrop:SetAnchor(TOPLEFT, RdKGToolFtcw.controls.warning, TOPLEFT, 0, 0)
	RdKGToolFtcw.controls.warning.movableBackdrop:SetDimensions(600, 60)

	

	RdKGToolFtcw.controls.warning.label = wm:CreateControl(nil, RdKGToolFtcw.controls.warning.movableBackdrop, CT_LABEL)
	RdKGToolFtcw.controls.warning.label:SetDimensions(580, 46)
	RdKGToolFtcw.controls.warning.label:SetAnchor(CENTER, RdKGToolFtcw.controls.warning, CENTER, 0, 0)
	RdKGToolFtcw.controls.warning.label:SetFont(RdKGToolFtcw.config.fontWarning)
	RdKGToolFtcw.controls.warning.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER) 
	RdKGToolFtcw.controls.warning.label:SetText("")
	RdKGToolFtcw.controls.warning.label:SetColor(RdKGToolFtcw.ftcwVars.warningColor.r, RdKGToolFtcw.ftcwVars.warningColor.g, RdKGToolFtcw.ftcwVars.warningColor.b)
	
	RdKGToolFtcw.SetTlwLocation()
	
	RdKGToolMenu.AddPositionFixedConsumer(RdKGToolFtcw.SetFtcwPositionLocked)
	
	RdKGToolFtcw.state.initialized = true
	RdKGToolFtcw.SetEnabled(RdKGToolFtcw.ftcwVars.enabled)
	RdKGToolFtcw.SetMovable(not RdKGToolFtcw.ftcwVars.positionLocked)
end

function RdKGToolFtcw.SetTlwLocation()
	RdKGToolFtcw.controls.TLW_Meter:ClearAnchors()
	if RdKGToolFtcw.ftcwVars.distanceLocation == nil then
		RdKGToolFtcw.controls.TLW_Meter:SetAnchor(CENTER, GuiRoot, CENTER, 0, 150)
	else
		RdKGToolFtcw.controls.TLW_Meter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolFtcw.ftcwVars.distanceLocation.x, RdKGToolFtcw.ftcwVars.distanceLocation.y)
	end
	RdKGToolFtcw.controls.TLW_Warning:ClearAnchors()
	if RdKGToolFtcw.ftcwVars.warningLocation == nil then
		RdKGToolFtcw.controls.TLW_Warning:SetAnchor(CENTER, GuiRoot, CENTER, 250, -250)
	else
		RdKGToolFtcw.controls.TLW_Warning:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolFtcw.ftcwVars.warningLocation.x, RdKGToolFtcw.ftcwVars.warningLocation.y)
	end
end

function RdKGToolFtcw.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	defaults.distanceEnabled = true
	defaults.distanceBackdropEnabled = true
	defaults.warningsEnabled = true
	defaults.positionLocked = true
	defaults.warningColor = {}
	defaults.warningColor.r = 1
	defaults.warningColor.g = 0
	defaults.warningColor.b = 0
	defaults.distanceColor = {}
	defaults.distanceColor.r = 0
	defaults.distanceColor.g = 0
	defaults.distanceColor.b = 0
	defaults.distanceAlertColor = {}
	defaults.distanceAlertColor.r = 1
	defaults.distanceAlertColor.g = 0
	defaults.distanceAlertColor.b = 0
	defaults.maxDistance = 10
	defaults.ignoreDistance = 100
	defaults.pvpOnly = true
	return defaults
end

function RdKGToolFtcw.SetEnabled(value)
	if RdKGToolFtcw.state.initialized == true and value ~= nil then
		RdKGToolFtcw.ftcwVars.enabled = value
		if value == true then
			if RdKGToolFtcw.state.registredConsumers == false then
				
				EVENT_MANAGER:RegisterForEvent(RdKGToolFtcw.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolFtcw.OnPlayerActivated)
				
			end
			RdKGToolFtcw.state.registredConsumers = true
		else
			if RdKGToolFtcw.state.registredConsumers == true then
				
				EVENT_MANAGER:UnregisterForEvent(RdKGToolFtcw.callbackName, EVENT_PLAYER_ACTIVATED)
				
			end
			RdKGToolFtcw.state.registredConsumers = false
		end
		RdKGToolFtcw.OnPlayerActivated()
	end
end

function RdKGToolFtcw.SetBackdropColors()
	if RdKGToolFtcw.ftcwVars.positionLocked == false then
		RdKGToolFtcw.controls.meter.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolFtcw.controls.meter.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		RdKGToolFtcw.controls.warning.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolFtcw.controls.warning.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	else
		if IsUnitGrouped("player") == true and RdKGToolGroup.IsPlayerGroupLeader() == false then
			if RdKGToolFtcw.ftcwVars.distanceBackdropEnabled == true and ( RdKGToolFtcw.ftcwVars.pvpOnly == false or (RdKGToolFtcw.ftcwVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea()))then
				RdKGToolFtcw.controls.meter.movableBackdrop:SetCenterColor(0.1, 0.1, 0.1, 0.3)
				RdKGToolFtcw.controls.meter.movableBackdrop:SetEdgeColor(0.1, 0.1, 0.1, 0.0)
			else
				RdKGToolFtcw.controls.meter.movableBackdrop:SetCenterColor(0.0, 0.0, 0.0, 0.0)
				RdKGToolFtcw.controls.meter.movableBackdrop:SetEdgeColor(0.0, 0.0, 0.0, 0.0)
			end
		else
			RdKGToolFtcw.controls.meter.movableBackdrop:SetCenterColor(0.0, 0.0, 0.0, 0.0)
			RdKGToolFtcw.controls.meter.movableBackdrop:SetEdgeColor(0.0, 0.0, 0.0, 0.0)
		end
		RdKGToolFtcw.controls.warning.movableBackdrop:SetCenterColor(0, 0, 0, 0.0)
		RdKGToolFtcw.controls.warning.movableBackdrop:SetEdgeColor(0, 0, 0, 0.0)	
	end
end

function RdKGToolFtcw.SetMovable(isMovable)
	RdKGToolFtcw.ftcwVars.positionLocked = not isMovable
	RdKGToolFtcw.controls.TLW_Meter:SetMovable(isMovable)
	RdKGToolFtcw.controls.TLW_Meter:SetMouseEnabled(isMovable)
	RdKGToolFtcw.controls.TLW_Warning:SetMovable(isMovable)
	RdKGToolFtcw.controls.TLW_Warning:SetMouseEnabled(isMovable)
	RdKGToolFtcw.SetBackdropColors()
end

function RdKGToolFtcw.SetControlVisibility()
	local enabled = RdKGToolFtcw.ftcwVars.enabled
	local pvpOnly = RdKGToolFtcw.ftcwVars.pvpOnly
	local setHidden = true
	if enabled ~= nil and pvpOnly ~= nil then

		if enabled == true and (pvpOnly == false or (pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
			setHidden = false
		end
	end
	if setHidden == false then
		if RdKGToolFtcw.state.foreground == false then
			RdKGToolFtcw.controls.TLW_Meter:SetHidden(RdKGToolFtcw.state.activeLayerIndex > 2)
			RdKGToolFtcw.controls.TLW_Warning:SetHidden(RdKGToolFtcw.state.activeLayerIndex > 2)
		else
			RdKGToolFtcw.controls.TLW_Meter:SetHidden(false)
			RdKGToolFtcw.controls.TLW_Warning:SetHidden(false)
		end
	else
		RdKGToolFtcw.controls.TLW_Meter:SetHidden(setHidden)
		RdKGToolFtcw.controls.TLW_Warning:SetHidden(setHidden)
	end
	if RdKGToolFtcw.ftcwVars.distanceEnabled == false then
		RdKGToolFtcw.controls.TLW_Meter:SetHidden(true)
	end
	if RdKGToolFtcw.ftcwVars.warningsEnabled == false then
		RdKGToolFtcw.controls.TLW_Warning:SetHidden(true)
	end
end

--callbacks
function RdKGToolFtcw.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		--RdKGToolFtcw.SetEnabled(false)
		RdKGToolFtcw.ftcwVars = currentProfile.group.ftcw
		if RdKGToolFtcw.controls.meter ~= nil and RdKGToolFtcw.controls.warning ~= nil then
			RdKGToolFtcw.controls.meter.label:SetColor(RdKGToolFtcw.ftcwVars.distanceColor.r, RdKGToolFtcw.ftcwVars.distanceColor.g, RdKGToolFtcw.ftcwVars.distanceColor.b)
			RdKGToolFtcw.controls.warning.label:SetColor(RdKGToolFtcw.ftcwVars.warningColor.r, RdKGToolFtcw.ftcwVars.warningColor.g, RdKGToolFtcw.ftcwVars.warningColor.b)
			RdKGToolFtcw.SetMovable(not RdKGToolFtcw.ftcwVars.positionLocked)
			RdKGToolFtcw.SetTlwLocation()
		end
		
		RdKGToolFtcw.SetEnabled(RdKGToolFtcw.ftcwVars.enabled)
		
	end
end

function RdKGToolFtcw.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolFtcw.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolFtcw.state.foreground = false
	end
	--hack?
	RdKGToolFtcw.state.activeLayerIndex = activeLayerIndex
	
	RdKGToolFtcw.SetControlVisibility()
end

function RdKGToolFtcw.OnPlayerActivated(eventCode, initial)
	if RdKGToolFtcw.ftcwVars.enabled == true and (RdKGToolFtcw.ftcwVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true or RdKGToolFtcw.ftcwVars.pvpOnly == false) then
		if RdKGToolFtcw.state.registredActiveConsumers == false then
			EVENT_MANAGER:RegisterForEvent(RdKGToolFtcw.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolFtcw.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForEvent(RdKGToolFtcw.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolFtcw.SetForegroundVisibility)
			RdKGTool.util.group.AddFeature(RdKGToolFtcw.callbackName, RdKGTool.util.group.features.FEATURE_GROUP_LEADER_DISTANCE, RdKGToolFtcw.config.updateInterval)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolFtcw.callbackName, RdKGToolFtcw.config.updateInterval, RdKGToolFtcw.OnUpdate)
			RdKGToolFtcw.state.registredActiveConsumers = true
		end
	else
		if RdKGToolFtcw.state.registredActiveConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(RdKGToolFtcw.callbackName, EVENT_ACTION_LAYER_POPPED)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolFtcw.callbackName, EVENT_ACTION_LAYER_PUSHED)
			RdKGTool.util.group.RemoveFeature(RdKGToolFtcw.callbackName, RdKGTool.util.group.features.FEATURE_GROUP_LEADER_DISTANCE)
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolFtcw.callbackName)
			RdKGToolFtcw.state.registredActiveConsumers = false
		end
	end
	RdKGToolFtcw.SetControlVisibility()
end

function RdKGToolFtcw.OnUpdate()
	if IsUnitGrouped("player") == true and RdKGToolGroup.IsPlayerGroupLeader() == false and ( RdKGToolFtcw.ftcwVars.pvpOnly == false or (RdKGToolFtcw.ftcwVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea())) then
		local distance = RdKGTool.util.group.GetLeaderDistance()
		--d(distance)
		if distance ~= nil then
			if distance > RdKGToolFtcw.ftcwVars.maxDistance and distance < RdKGToolFtcw.ftcwVars.ignoreDistance then
				RdKGToolFtcw.controls.warning.label:SetText(RdKGToolFtcw.constants.FTCW_MAX_DISTANCE)
				RdKGToolFtcw.controls.meter.label:SetColor(RdKGToolFtcw.ftcwVars.distanceAlertColor.r, RdKGToolFtcw.ftcwVars.distanceAlertColor.g, RdKGToolFtcw.ftcwVars.distanceAlertColor.b)
			else
				RdKGToolFtcw.controls.warning.label:SetText("")
				RdKGToolFtcw.controls.meter.label:SetColor(RdKGToolFtcw.ftcwVars.distanceColor.r, RdKGToolFtcw.ftcwVars.distanceColor.g, RdKGToolFtcw.ftcwVars.distanceColor.b)
			end
			local unit = "m"
			if distance >= 1000 then
				distance = distance / 1000
				unit = "km"
			end
			RdKGToolFtcw.controls.meter.label:SetText(string.format("%.1f %s", distance, unit))
		end
	else
		RdKGToolFtcw.controls.meter.label:SetText("")
		RdKGToolFtcw.controls.warning.label:SetText("")
	end
	RdKGToolFtcw.SetBackdropColors()
end

function RdKGToolFtcw.SaveWindowLocation()
	if RdKGToolFtcw.ftcwVars.positionLocked == false then
		RdKGToolFtcw.ftcwVars.warningLocation = RdKGToolFtcw.ftcwVars.warningLocation or {}
		RdKGToolFtcw.ftcwVars.warningLocation.x = RdKGToolFtcw.controls.TLW_Warning:GetLeft()
		RdKGToolFtcw.ftcwVars.warningLocation.y = RdKGToolFtcw.controls.TLW_Warning:GetTop()
		
		RdKGToolFtcw.ftcwVars.distanceLocation = RdKGToolFtcw.ftcwVars.distanceLocation or {}
		RdKGToolFtcw.ftcwVars.distanceLocation.x = RdKGToolFtcw.controls.TLW_Meter:GetLeft()
		RdKGToolFtcw.ftcwVars.distanceLocation.y = RdKGToolFtcw.controls.TLW_Meter:GetTop()
	end
end

--menu interaction
function RdKGToolFtcw.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.FTCW_HEADER,
			--width = "full",
			controls = {

				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.FTCW_ENABLED,
					getFunc = RdKGToolFtcw.GetFtcwEnabled,
					setFunc = RdKGToolFtcw.SetFtcwEnabled,
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.FTCW_PVP_ONLY,
					getFunc = RdKGToolFtcw.GetFtcwPvpOnly,
					setFunc = RdKGToolFtcw.SetFtcwPvpOnly,
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.FTCW_WARNINGS_ENABLED,
					getFunc = RdKGToolFtcw.GetFtcwWarningsEnabled,
					setFunc = RdKGToolFtcw.SetFtcwWarningsEnabled,
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.FTCW_DISTANCE_ENABLED,
					getFunc = RdKGToolFtcw.GetFtcwDistanceEnabled,
					setFunc = RdKGToolFtcw.SetFtcwDistanceEnabled,
				},
				[5] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.FTCW_DISTANCE_BACKDROP_ENABLED,
					getFunc = RdKGToolFtcw.GetFtcwDistanceBackdropEnabled,
					setFunc = RdKGToolFtcw.SetFtcwDistanceBackdropEnabled,
				},
				[6] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.FTCW_POSITION_FIXED,
					getFunc = RdKGToolFtcw.GetFtcwPositionLocked,
					setFunc = RdKGToolFtcw.SetFtcwPositionLocked,
				},
				[7] = {
					type = "slider",
					name = RdKGToolMenu.constants.FTCW_DISTANCE,
					min = 0,
					max = 25,
					step = 1,
					getFunc = RdKGToolFtcw.GetFtcwMaxDistance,
					setFunc = RdKGToolFtcw.SetFtcwMaxDistance,
					width = "full",
					default = 8
				},
				[8] = {
					type = "slider",
					name = RdKGToolMenu.constants.FTCW_IGNORE_DISTANCE,
					min = 100,
					max = 1000,
					step = 1,
					getFunc = RdKGToolFtcw.GetFtcwIgnoreDistance,
					setFunc = RdKGToolFtcw.SetFtcwIgnoreDistance,
					width = "full",
					default = 100
				},
				[9] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.FTCW_WARNING_COLOR,
					getFunc = RdKGToolFtcw.GetFtcwWarningColor,
					setFunc = RdKGToolFtcw.SetFtcwWarningColor,
					width = "full"
				},
				[10] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.FTCW_DISTANCE_COLOR_NORMAL,
					getFunc = RdKGToolFtcw.GetFtcwDistanceColor,
					setFunc = RdKGToolFtcw.SetFtcwDistanceColor,
					width = "full"
				},
				[11] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.FTCW_DISTANCE_COLOR_ALERT,
					getFunc = RdKGToolFtcw.GetFtcwDistanceAlertColor,
					setFunc = RdKGToolFtcw.SetFtcwDistanceAlertColor,
					width = "full"
				}
			}
		}
	}
	return menu
end

function RdKGToolFtcw.GetFtcwEnabled()
	return RdKGToolFtcw.ftcwVars.enabled
end

function RdKGToolFtcw.SetFtcwEnabled(value)
	RdKGToolFtcw.SetEnabled(value)
end

function RdKGToolFtcw.GetFtcwPvpOnly()
	return RdKGToolFtcw.ftcwVars.pvpOnly
end

function RdKGToolFtcw.SetFtcwPvpOnly(value)
	RdKGToolFtcw.ftcwVars.pvpOnly = value
	RdKGToolFtcw.SetEnabled(RdKGToolFtcw.ftcwVars.enabled)
end

function RdKGToolFtcw.GetFtcwWarningsEnabled()
	return RdKGToolFtcw.ftcwVars.warningsEnabled
end

function RdKGToolFtcw.SetFtcwWarningsEnabled(value)
	RdKGToolFtcw.ftcwVars.warningsEnabled = value
	RdKGToolFtcw.SetEnabled(RdKGToolFtcw.ftcwVars.enabled)
end

function RdKGToolFtcw.GetFtcwDistanceEnabled()
	return RdKGToolFtcw.ftcwVars.distanceEnabled
end

function RdKGToolFtcw.SetFtcwDistanceEnabled(value)
	RdKGToolFtcw.ftcwVars.distanceEnabled = value
	RdKGToolFtcw.SetEnabled(RdKGToolFtcw.ftcwVars.enabled)
end

function RdKGToolFtcw.GetFtcwDistanceBackdropEnabled()
	return RdKGToolFtcw.ftcwVars.distanceBackdropEnabled
end

function RdKGToolFtcw.SetFtcwDistanceBackdropEnabled(value)
	RdKGToolFtcw.ftcwVars.distanceBackdropEnabled = value
	RdKGToolFtcw.SetEnabled(RdKGToolFtcw.ftcwVars.enabled)
end

function RdKGToolFtcw.GetFtcwPositionLocked()
	return RdKGToolFtcw.ftcwVars.positionLocked
end

function RdKGToolFtcw.SetFtcwPositionLocked(value)
	RdKGToolFtcw.SetMovable(not value)
end

function RdKGToolFtcw.GetFtcwMaxDistance()
	return RdKGToolFtcw.ftcwVars.maxDistance
end

function RdKGToolFtcw.SetFtcwMaxDistance(value)
	RdKGToolFtcw.ftcwVars.maxDistance = value
end

function RdKGToolFtcw.GetFtcwIgnoreDistance()
	return RdKGToolFtcw.ftcwVars.ignoreDistance
end

function RdKGToolFtcw.SetFtcwIgnoreDistance(value)
	RdKGToolFtcw.ftcwVars.ignoreDistance = value
end

function RdKGToolFtcw.GetFtcwWarningColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolFtcw.ftcwVars.warningColor)
end

function RdKGToolFtcw.SetFtcwWarningColor(r, g, b)
	RdKGToolFtcw.ftcwVars.warningColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolFtcw.controls.warning.label:SetColor(r, g, b)
end

function RdKGToolFtcw.GetFtcwDistanceColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolFtcw.ftcwVars.distanceColor)
end

function RdKGToolFtcw.SetFtcwDistanceColor(r, g, b)
	RdKGToolFtcw.ftcwVars.distanceColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolFtcw.controls.meter.label:SetColor(r, g, b)
end

function RdKGToolFtcw.GetFtcwDistanceAlertColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolFtcw.ftcwVars.distanceAlertColor)
end

function RdKGToolFtcw.SetFtcwDistanceAlertColor(r, g, b)
	RdKGToolFtcw.ftcwVars.distanceAlertColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
end



--Follow The Crown Warnings

--[[
function RdKGToolMenu.GetFtcwWarningColor()
	local color = RdKGToolFtcw.GetFtcwWarningColor()
	return color.r, color.g, color.b
end

function RdKGToolMenu.SetFtcwWarningColor(r, g, b, a)
	local color = {}
	color.r = r
	color.g = g
	color.b = b
	RdKGToolFtcw.SetFtcwWarningColor(color)
end

function RdKGToolMenu.GetFtcwDistanceColor()
	local color = RdKGToolFtcw.GetFtcwDistanceColor()
	return color.r, color.g, color.b
end

function RdKGToolMenu.SetFtcwDistanceColor(r, g, b, a)
	local color = {}
	color.r = r
	color.g = g
	color.b = b
	RdKGToolFtcw.SetFtcwDistanceColor(color)
end

function RdKGToolMenu.GetFtcwDistanceAlertColor()
	local color = RdKGToolFtcw.GetFtcwDistanceAlertColor()
	return color.r, color.g, color.b
end

function RdKGToolMenu.SetFtcwDistanceAlertColor(r, g, b, a)
	local color = {}
	color.r = r
	color.g = g
	color.b = b
	RdKGToolFtcw.SetFtcwDistanceAlertColor(color)
end
]]