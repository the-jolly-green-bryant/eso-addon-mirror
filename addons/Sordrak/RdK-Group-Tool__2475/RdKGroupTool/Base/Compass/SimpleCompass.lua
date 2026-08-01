-- RdK Group Tool Yet another Compass
-- By @s0rdrak (PC / EU)

RdKGTool.compass = RdKGTool.compass or {}
RdKGTool.compass.sc = RdKGTool.compass.sc or {}
local RdKGToolSC = RdKGTool.compass.sc
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.fonts = RdKGToolUtil.fonts or {}
local RdKGToolFonts = RdKGToolUtil.fonts
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem

RdKGToolSC.callbackName = RdKGTool.addonName .. "CompassSC"


RdKGToolSC.controls = {}

RdKGToolSC.constants = RdKGToolSC.constants or {}
RdKGToolSC.constants.TLW_NAME = "RdKGTool.compass.sc.TLW"
RdKGToolSC.constants.DIRECTION_NAME_NORTH = "north"
RdKGToolSC.constants.DIRECTION_NAME_NORTH_EAST = "northEast"
RdKGToolSC.constants.DIRECTION_NAME_EAST = "east"
RdKGToolSC.constants.DIRECTION_NAME_SOUTH_EAST = "southEast"
RdKGToolSC.constants.DIRECTION_NAME_SOUTH = "south"
RdKGToolSC.constants.DIRECTION_NAME_SOUTH_WEST = "southWest"
RdKGToolSC.constants.DIRECTION_NAME_WEST = "west"
RdKGToolSC.constants.DIRECTION_NAME_NORTH_WEST = "northWest"

RdKGToolSC.constants.PREFIX = "SC"

RdKGToolSC.state = {}
RdKGToolSC.state.initialized = false
RdKGToolSC.state.registredConsumers = false
RdKGToolSC.state.foreground = true
RdKGToolSC.state.activeLayerIndex = 1
RdKGToolSC.state.registredActiveConsumers = false
RdKGToolSC.state.calc = {}

RdKGToolSC.config = {}
RdKGToolSC.config.isClampedToScreen = true
RdKGToolSC.config.width = 300
RdKGToolSC.config.height = 50
RdKGToolSC.config.updateInterval = 10
RdKGToolSC.config.borderAlpha = 0.1
RdKGToolSC.config.anchorOffset = 35 --20
RdKGToolSC.config.markerOffset = RdKGToolSC.config.width / 3 * 1.1 --1.25
RdKGToolSC.config.labelWidth = 75
RdKGToolSC.config.markerSize = 15

local wm = GetWindowManager()


function RdKGToolSC.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolSC.callbackName, RdKGToolSC.OnProfileChanged)
	
	RdKGToolSC.CreateUI()
	RdKGToolSC.AdjustColors()
	
	RdKGToolMenu.AddPositionFixedConsumer(RdKGToolSC.SetScPositionLocked)
	
	RdKGToolSC.state.initialized = true
	RdKGToolSC.SetEnabled(RdKGToolSC.scVars.enabled)
	RdKGToolSC.SetPositionLocked(RdKGToolSC.scVars.positionLocked)
	
end

function RdKGToolSC.CreateUI()
	RdKGToolSC.controls.TLW = wm:CreateTopLevelWindow(RdKGToolSC.constants.TLW_NAME)
	
	RdKGToolSC.SetTlwLocation()
	
	RdKGToolSC.controls.TLW:SetClampedToScreen(RdKGToolSC.config.isClampedToScreen)
	RdKGToolSC.controls.TLW:SetHandler("OnMoveStop", RdKGToolSC.SaveWindowLocation)
	RdKGToolSC.controls.TLW:SetDimensions(RdKGToolSC.config.width, RdKGToolSC.config.height)
	
	RdKGToolSC.controls.TLW.rootControl = wm:CreateControl(nil, RdKGToolSC.controls.TLW, CT_CONTROL)
	
	local rootControl = RdKGToolSC.controls.TLW.rootControl
	
	
	rootControl:SetDimensions(RdKGToolSC.config.width, RdKGToolSC.config.height)
	rootControl:SetAnchor(TOPLEFT, RdKGToolSC.controls.TLW, TOPLEFT, 0, 0)
	
	rootControl.movableBackdrop = wm:CreateControl(nil, rootControl, CT_BACKDROP)
	
	rootControl.movableBackdrop:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	rootControl.movableBackdrop:SetDimensions(RdKGToolSC.config.width, RdKGToolSC.config.height)
	
	rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	rootControl.backdrop = wm:CreateControl(nil, rootControl, CT_BACKDROP)
	rootControl.backdrop:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	rootControl.backdrop:SetDimensions(RdKGToolSC.config.width, RdKGToolSC.config.height)
	
	rootControl.backdrop:SetCenterColor(RdKGToolSC.scVars.colors.backdrop.r, RdKGToolSC.scVars.colors.backdrop.g, RdKGToolSC.scVars.colors.backdrop.b, RdKGToolSC.scVars.colors.backdrop.a)
	local borderAlpha = RdKGToolSC.scVars.colors.backdrop.a + RdKGToolSC.config.borderAlpha
	if borderAlpha > 1.0 then
		borderAlpha = 1.0
	end
	rootControl.backdrop:SetEdgeColor(RdKGToolSC.scVars.colors.backdrop.r, RdKGToolSC.scVars.colors.backdrop.g, RdKGToolSC.scVars.colors.backdrop.b, borderAlpha)
	rootControl.backdrop:SetEdgeTexture(nil, 2, 2, 2, 0)
	
	rootControl.compass = wm:CreateControl(nil, rootControl, CT_CONTROL)
	rootControl.compass:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	rootControl.compass:SetDimensions(0, 0)
	--rootControl.compass:SetDimensions(RdKGToolSC.config.width * 4, RdKGToolSC.config.height)
	
	rootControl.compass.anchors = {}
	rootControl.compass.directions = {}
	rootControl.compass.directions.all = {}
	rootControl.compass.directions.north = {}
	rootControl.compass.directions.south = {}
	rootControl.compass.directions.west = {}
	rootControl.compass.directions.east = {}
	rootControl.compass.directions.others = {}
	
	local directions = {}
	directions[1] = {name = RdKGToolSC.constants.DIRECTION_NAME_SOUTH_WEST, category = "others", label = RdKGToolSC.constants.SOUTH_WEST}
	directions[2] = {name = RdKGToolSC.constants.DIRECTION_NAME_WEST, category = "west", label = RdKGToolSC.constants.WEST}
	directions[3] = {name = RdKGToolSC.constants.DIRECTION_NAME_NORTH_WEST, category = "others", label = RdKGToolSC.constants.NORTH_WEST}
	directions[4] = {name = RdKGToolSC.constants.DIRECTION_NAME_NORTH, category = "north", label = RdKGToolSC.constants.NORTH}
	directions[5] = {name = RdKGToolSC.constants.DIRECTION_NAME_NORTH_EAST, category = "others", label = RdKGToolSC.constants.NORTH_EAST}
	directions[6] = {name = RdKGToolSC.constants.DIRECTION_NAME_EAST, category = "east", label = RdKGToolSC.constants.EAST}
	directions[7] = {name = RdKGToolSC.constants.DIRECTION_NAME_SOUTH_EAST, category = "others", label = RdKGToolSC.constants.SOUTH_EAST}
	directions[8] = {name = RdKGToolSC.constants.DIRECTION_NAME_SOUTH, category = "south", label = RdKGToolSC.constants.SOUTH}
	directions[9] = {name = RdKGToolSC.constants.DIRECTION_NAME_SOUTH_WEST, category = "others", label = RdKGToolSC.constants.SOUTH_WEST}
	directions[10] = {name = RdKGToolSC.constants.DIRECTION_NAME_WEST, category = "west", label = RdKGToolSC.constants.WEST}
	directions[11] = {name = RdKGToolSC.constants.DIRECTION_NAME_NORTH_WEST, category = "others", label = RdKGToolSC.constants.NORTH_WEST}
	directions[12] = {name = RdKGToolSC.constants.DIRECTION_NAME_NORTH, category = "north", label = RdKGToolSC.constants.NORTH}
	directions[13] = {name = RdKGToolSC.constants.DIRECTION_NAME_NORTH_EAST, category = "others", label = RdKGToolSC.constants.NORTH_EAST}
	directions[14] = {name = RdKGToolSC.constants.DIRECTION_NAME_EAST, category = "east", label = RdKGToolSC.constants.EAST}
	directions[15] = {name = RdKGToolSC.constants.DIRECTION_NAME_SOUTH_EAST, category = "others", label = RdKGToolSC.constants.SOUTH_EAST}
	
	RdKGToolSC.state.calc.nToNLength = 8 * RdKGToolSC.config.markerOffset
	RdKGToolSC.state.calc.ticks = RdKGToolSC.state.calc.nToNLength / (math.pi * 2)
	RdKGToolSC.state.calc.nOffset = -(RdKGToolSC.config.anchorOffset + RdKGToolSC.config.markerOffset * 3) + RdKGToolSC.config.width / 2 - RdKGToolSC.state.calc.nToNLength
	RdKGToolSC.state.calc.visibleDistance = 2 * (RdKGToolSC.config.width / 2 - RdKGToolSC.config.anchorOffset)
	
	local offset = RdKGToolSC.config.anchorOffset
	font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolSC.config.height - 4, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THICK)
	for i = 1, #directions do
		rootControl.compass.anchors[i] = wm:CreateControl(nil, rootControl.compass, CT_CONTROL)
		rootControl.compass.anchors[i]:SetAnchor(TOPLEFT, rootControl.compass, TOPLEFT, offset, 0)
		rootControl.compass.anchors[i]:SetDimensions(0, 0)
		rootControl.compass.anchors[i].visibleOffsetEnd = -offset + RdKGToolSC.config.anchorOffset + RdKGToolSC.state.calc.visibleDistance
		rootControl.compass.anchors[i].visibleOffsetBegin = -offset + RdKGToolSC.config.anchorOffset
		
		local label = wm:CreateControl(nil, rootControl.compass.anchors[i], CT_LABEL)
		label:SetFont(font)
		label:SetWrapMode(ELLIPSIS)
		label:SetAnchor(TOP, rootControl.compass.anchors[i], TOP, 0, 0)
		label:SetDimensions(RdKGToolSC.config.labelWidth, RdKGToolSC.config.height)
		label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		
		label.directionName = directions[i].name
		label:SetText(directions[i].label)
		table.insert(rootControl.compass.directions[directions[i].category], label)
		table.insert(rootControl.compass.directions.all, label)
		
		offset = offset + RdKGToolSC.config.markerOffset
	end
	rootControl.compass.marker1 = wm:CreateControl(nil, rootControl, CT_TEXTURE)
	rootControl.compass.marker1:SetAnchor(TOP, rootControl, TOP, 0, 1)
	rootControl.compass.marker1:SetDimensions(RdKGToolSC.config.markerSize, RdKGToolSC.config.markerSize)
	rootControl.compass.marker1:SetTexture("RdKGroupTool/Art/Compasses/SimpleCompass/MarkerTop.dds")
	rootControl.compass.marker1:SetColor(RdKGToolSC.scVars.colors.markers.r, RdKGToolSC.scVars.colors.markers.g, RdKGToolSC.scVars.colors.markers.b, RdKGToolSC.scVars.colors.markers.a)
	
	rootControl.compass.marker2 = wm:CreateControl(nil, rootControl, CT_TEXTURE)
	rootControl.compass.marker2:SetAnchor(BOTTOM, rootControl, BOTTOM, 0, 0)
	rootControl.compass.marker2:SetDimensions(RdKGToolSC.config.markerSize, RdKGToolSC.config.markerSize)
	rootControl.compass.marker2:SetTexture("RdKGroupTool/Art/Compasses/SimpleCompass/MarkerBottom.dds")
	rootControl.compass.marker2:SetColor(RdKGToolSC.scVars.colors.markers.r, RdKGToolSC.scVars.colors.markers.g, RdKGToolSC.scVars.colors.markers.b, RdKGToolSC.scVars.colors.markers.a)
end

function RdKGToolSC.SetTlwLocation()
	if RdKGToolSC.scVars.location == nil then
		RdKGToolSC.controls.TLW:SetAnchor(CENTER, GuiRoot, CENTER, 0, -125)
	else
		RdKGToolSC.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolSC.scVars.location.x, RdKGToolSC.scVars.location.y)
	end
end

function RdKGToolSC.GetDefaults()
	local defaults = {}
	defaults.enabled = false
	defaults.pvpEnabled = true
	defaults.pveEnabled = true
	defaults.positionLocked = true
	defaults.colors = {}
	defaults.colors.backdrop = {}
	defaults.colors.backdrop.r = 0.1
	defaults.colors.backdrop.g = 0.1
	defaults.colors.backdrop.b = 0.1
	defaults.colors.backdrop.a = 0.2
	defaults.colors.north = {}
	defaults.colors.north.r = 0.8
	defaults.colors.north.g = 0.86
	defaults.colors.north.b = 0.74
	defaults.colors.north.a = 1.0
	defaults.colors.south = {}
	defaults.colors.south.r = 0.8
	defaults.colors.south.g = 0.86
	defaults.colors.south.b = 0.74
	defaults.colors.south.a = 1.0
	defaults.colors.west = {}
	defaults.colors.west.r = 0.8
	defaults.colors.west.g = 0.86
	defaults.colors.west.b = 0.74
	defaults.colors.west.a = 1.0
	defaults.colors.east = {}
	defaults.colors.east.r = 0.8
	defaults.colors.east.g = 0.86
	defaults.colors.east.b = 0.74
	defaults.colors.east.a = 1.0
	defaults.colors.others = {}
	defaults.colors.others.r = 0.92
	defaults.colors.others.g = 0.37
	defaults.colors.others.b = 0.0
	defaults.colors.others.a = 0.8
	defaults.colors.markers = {}
	defaults.colors.markers.r = 0.94
	defaults.colors.markers.g = 0.24
	defaults.colors.markers.b = 0.24
	defaults.colors.markers.a = 0.5
	return defaults
end

function RdKGToolSC.SetEnabled(enabled)
	if RdKGToolSC.state.initialized == true and enabled ~= nil then
		RdKGToolSC.scVars.enabled = enabled
		if enabled == true then
			if RdKGToolSC.state.registredConsumers == false then
				--EVENT_MANAGER:RegisterForEvent(RdKGToolSC.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolSC.SetForegroundVisibility)
				--EVENT_MANAGER:RegisterForEvent(RdKGToolSC.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolSC.SetForegroundVisibility)
				EVENT_MANAGER:RegisterForEvent(RdKGToolSC.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolSC.OnPlayerActivated)
			end
			RdKGToolSC.state.registredConsumers = true
		else
			if RdKGToolSC.state.registredConsumers == true then
				--EVENT_MANAGER:UnregisterForEvent(RdKGToolSC.callbackName, EVENT_ACTION_LAYER_POPPED)
				--EVENT_MANAGER:UnregisterForEvent(RdKGToolSC.callbackName, EVENT_ACTION_LAYER_PUSHED)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolSC.callbackName, EVENT_PLAYER_ACTIVATED)
			end
			RdKGToolSC.state.registredConsumers = false
			RdKGToolSC.SetControlVisibility()
		end
		RdKGToolSC.OnPlayerActivated()
	end

end

function RdKGToolSC.SetControlVisibility()
	local enabled = RdKGToolSC.scVars.enabled
	local isInPvp = RdKGToolUtil.IsInPvPArea()
	local setHidden = true
	if enabled ~= nil and enabled == true and ((RdKGToolSC.scVars.pvpEnabled == true and isInPvp == true) or (RdKGToolSC.scVars.pveEnabled == true and isInPvp == false)) then
		setHidden = false
	end
	if setHidden == false then
		if RdKGToolSC.state.foreground == false then
			RdKGToolSC.controls.TLW:SetHidden(RdKGToolSC.state.activeLayerIndex > 2)
		else
			RdKGToolSC.controls.TLW:SetHidden(false)
		end
	else
		RdKGToolSC.controls.TLW:SetHidden(setHidden)
	end
end

function RdKGToolSC.SetPositionLocked(value)
	RdKGToolSC.scVars.positionLocked = value
	
	RdKGToolSC.controls.TLW:SetMovable(not value)
	RdKGToolSC.controls.TLW:SetMouseEnabled(not value)
	if value == true then
		RdKGToolSC.controls.TLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolSC.controls.TLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	else
		RdKGToolSC.controls.TLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolSC.controls.TLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	end
end

function RdKGToolSC.AdjustColors()
	local controls = RdKGToolSC.controls.TLW.rootControl.compass.directions.all
	for i = 1, #controls do
		local color = RdKGToolSC.scVars.colors.others
		if controls[i].directionName == RdKGToolSC.constants.DIRECTION_NAME_NORTH then
			color = RdKGToolSC.scVars.colors.north
		elseif controls[i].directionName == RdKGToolSC.constants.DIRECTION_NAME_EAST then
			color = RdKGToolSC.scVars.colors.east
		elseif controls[i].directionName == RdKGToolSC.constants.DIRECTION_NAME_SOUTH then
			color = RdKGToolSC.scVars.colors.south
		elseif controls[i].directionName == RdKGToolSC.constants.DIRECTION_NAME_WEST then
			color = RdKGToolSC.scVars.colors.west
		end
		controls[i]:SetColor(color.r, color.g, color.b, color.a)
	end
	RdKGToolSC.controls.TLW.rootControl.backdrop:SetCenterColor(RdKGToolSC.scVars.colors.backdrop.r, RdKGToolSC.scVars.colors.backdrop.g, RdKGToolSC.scVars.colors.backdrop.b, RdKGToolSC.scVars.colors.backdrop.a)
	local borderAlpha = RdKGToolSC.scVars.colors.backdrop.a + RdKGToolSC.config.borderAlpha
	if borderAlpha > 1.0 then
		borderAlpha = 1.0
	end
	RdKGToolSC.controls.TLW.rootControl.backdrop:SetEdgeColor(RdKGToolSC.scVars.colors.backdrop.r, RdKGToolSC.scVars.colors.backdrop.g, RdKGToolSC.scVars.colors.backdrop.b, borderAlpha)
	RdKGToolSC.controls.TLW.rootControl.backdrop:SetEdgeTexture(nil, 2, 2, 2, 0)
	RdKGToolSC.controls.TLW.rootControl.compass.marker1:SetColor(RdKGToolSC.scVars.colors.markers.r, RdKGToolSC.scVars.colors.markers.g, RdKGToolSC.scVars.colors.markers.b, RdKGToolSC.scVars.colors.markers.a)
	RdKGToolSC.controls.TLW.rootControl.compass.marker2:SetColor(RdKGToolSC.scVars.colors.markers.r, RdKGToolSC.scVars.colors.markers.g, RdKGToolSC.scVars.colors.markers.b, RdKGToolSC.scVars.colors.markers.a)
end

--callbacks
function RdKGToolSC.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolSC.scVars = currentProfile.compass.sc
		RdKGToolSC.SetEnabled(RdKGToolSC.scVars.enabled)
		if RdKGToolSC.state.initialized == true then
			RdKGToolSC.SetPositionLocked(RdKGToolSC.scVars.positionLocked)
			RdKGToolSC.AdjustColors()
		end
	end
end

function RdKGToolSC.SaveWindowLocation()
	if RdKGToolSC.scVars.positionLocked == false then
		RdKGToolSC.scVars.location = RdKGToolSC.scVars.location or {}
		RdKGToolSC.scVars.location.x = RdKGToolSC.controls.TLW:GetLeft()
		RdKGToolSC.scVars.location.y = RdKGToolSC.controls.TLW:GetTop()
	end
end

function RdKGToolSC.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolSC.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolSC.state.foreground = false
	end
	RdKGToolSC.state.activeLayerIndex = activeLayerIndex
	
	RdKGToolSC.SetControlVisibility()
end

function RdKGToolSC.OnPlayerActivated(eventCode, initial)
	local isInPvp = RdKGToolUtil.IsInPvPArea()
	if RdKGToolSC.scVars.enabled == true and ((RdKGToolSC.scVars.pvpEnabled == true and isInPvp == true) or (RdKGToolSC.scVars.pveEnabled == true and isInPvp == false)) then
		if RdKGToolSC.state.registredActiveConsumers == false then
			EVENT_MANAGER:RegisterForUpdate(RdKGToolSC.callbackName, RdKGToolSC.config.updateInterval, RdKGToolSC.UiLoop)
			EVENT_MANAGER:RegisterForEvent(RdKGToolSC.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolSC.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForEvent(RdKGToolSC.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolSC.SetForegroundVisibility)
			RdKGToolSC.state.registredActiveConsumers = true
		end
	else
		if RdKGToolSC.state.registredActiveConsumers == true then
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolSC.callbackName)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolSC.callbackName, EVENT_ACTION_LAYER_POPPED)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolSC.callbackName, EVENT_ACTION_LAYER_PUSHED)
			RdKGToolSC.state.registredActiveConsumers = false
		end
	end
	RdKGToolSC.SetControlVisibility()
end

function RdKGToolSC.UiLoop()
	if RdKGToolSC.scVars.enabled == true then
		local rootControl = RdKGToolSC.controls.TLW.rootControl
		local compass = rootControl.compass
		local anchors = compass.anchors
		local offset = RdKGToolSC.state.calc.nOffset + (RdKGToolSC.state.calc.ticks * GetPlayerCameraHeading())
		compass:ClearAnchors()
		compass:SetAnchor(TOPLEFT, rootControl, TOPLEFT, offset, 0)
		for i = 1, #anchors do
			if anchors[i].visibleOffsetBegin < offset and anchors[i].visibleOffsetEnd > offset then
				anchors[i]:SetHidden(false)
			else
				anchors[i]:SetHidden(true)
			end
		end
	else
		RdKGToolChat.SendChatMessage("UI Loop: Not enabled!", RdKGToolSC.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
	end
end

--menu interaction
function RdKGToolSC.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.COMPASS_SC_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.COMPASS_SC_ENABLED,
					getFunc = RdKGToolSC.GetCsEnabled,
					setFunc = RdKGToolSC.SetCsEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.COMPASS_SC_PVP,
					getFunc = RdKGToolSC.GetCsPvpEnabled,
					setFunc = RdKGToolSC.SetCsPvpEnabled
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.COMPASS_SC_PVE,
					getFunc = RdKGToolSC.GetCsPveEnabled,
					setFunc = RdKGToolSC.SetCsPveEnabled
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.COMPASS_SC_POSITION_FIXED,
					getFunc = RdKGToolSC.GetScPositionLocked,
					setFunc = RdKGToolSC.SetScPositionLocked
				},
				[5] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.COMPASS_SC_COLOR_BACKDROP,
					getFunc = RdKGToolSC.GetScColorBackdrop,
					setFunc = RdKGToolSC.SetScColorBackdrop,
					width = "full"
				},
				[6] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_NORTH,
					getFunc = RdKGToolSC.GetScColorNorth,
					setFunc = RdKGToolSC.SetScColorNorth,
					width = "full"
				},
				[7] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_SOUTH,
					getFunc = RdKGToolSC.GetScColorSouth,
					setFunc = RdKGToolSC.SetScColorSouth,
					width = "full"
				},
				[8] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_WEST,
					getFunc = RdKGToolSC.GetScColorWest,
					setFunc = RdKGToolSC.SetScColorWest,
					width = "full"
				},
				[9] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_EAST,
					getFunc = RdKGToolSC.GetScColorEast,
					setFunc = RdKGToolSC.SetScColorEast,
					width = "full"
				},
				[10] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.COMPASS_SC_COLOR_DIRECTION_OTHERS,
					getFunc = RdKGToolSC.GetScColorOthers,
					setFunc = RdKGToolSC.SetScColorOthers,
					width = "full"
				},
				[11] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.COMPASS_SC_COLOR_MARKERS,
					getFunc = RdKGToolSC.GetScColorMarkers,
					setFunc = RdKGToolSC.SetScColorMarkers,
					width = "full"
				},
			}
		},
	}
	return menu
end

function RdKGToolSC.GetCsEnabled()
	return RdKGToolSC.scVars.enabled
end

function RdKGToolSC.SetCsEnabled(value)
	RdKGToolSC.SetEnabled(value)
end

function RdKGToolSC.GetCsPvpEnabled()
	return RdKGToolSC.scVars.pvpEnabled
end

function RdKGToolSC.SetCsPvpEnabled(value)
	RdKGToolSC.scVars.pvpEnabled = value
end

function RdKGToolSC.GetCsPveEnabled()
	return RdKGToolSC.scVars.pveEnabled
end

function RdKGToolSC.SetCsPveEnabled(value)
	RdKGToolSC.scVars.pveEnabled = value
end

function RdKGToolSC.GetScPositionLocked()
	return RdKGToolSC.scVars.positionLocked
end

function RdKGToolSC.SetScPositionLocked(value)
	RdKGToolSC.SetPositionLocked(value)
end

function RdKGToolSC.GetScColorBackdrop()
	return RdKGToolMenu.GetRGBAColor(RdKGToolSC.scVars.colors.backdrop)
end

function RdKGToolSC.SetScColorBackdrop(r, g, b, a)
	RdKGToolSC.scVars.colors.backdrop = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
	RdKGToolSC.AdjustColors()
end

function RdKGToolSC.GetScColorNorth()
	return RdKGToolMenu.GetRGBAColor(RdKGToolSC.scVars.colors.north)
end

function RdKGToolSC.SetScColorNorth(r, g, b, a)
	RdKGToolSC.scVars.colors.north = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
	RdKGToolSC.AdjustColors()
end

function RdKGToolSC.GetScColorSouth()
	return RdKGToolMenu.GetRGBAColor(RdKGToolSC.scVars.colors.south)
end

function RdKGToolSC.SetScColorSouth(r, g, b, a)
	RdKGToolSC.scVars.colors.south = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
	RdKGToolSC.AdjustColors()
end

function RdKGToolSC.GetScColorWest()
	return RdKGToolMenu.GetRGBAColor(RdKGToolSC.scVars.colors.west)
end

function RdKGToolSC.SetScColorWest(r, g, b, a)
	RdKGToolSC.scVars.colors.west = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
	RdKGToolSC.AdjustColors()
end

function RdKGToolSC.GetScColorEast()
	return RdKGToolMenu.GetRGBAColor(RdKGToolSC.scVars.colors.east)
end

function RdKGToolSC.SetScColorEast(r, g, b, a)
	RdKGToolSC.scVars.colors.east = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
	RdKGToolSC.AdjustColors()
end

function RdKGToolSC.GetScColorOthers()
	return RdKGToolMenu.GetRGBAColor(RdKGToolSC.scVars.colors.others)
end

function RdKGToolSC.SetScColorOthers(r, g, b, a)
	RdKGToolSC.scVars.colors.others = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
	RdKGToolSC.AdjustColors()
end

function RdKGToolSC.GetScColorMarkers()
	return RdKGToolMenu.GetRGBAColor(RdKGToolSC.scVars.colors.markers)
end

function RdKGToolSC.SetScColorMarkers(r, g, b, a)
	RdKGToolSC.scVars.colors.markers = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
	RdKGToolSC.AdjustColors()
end