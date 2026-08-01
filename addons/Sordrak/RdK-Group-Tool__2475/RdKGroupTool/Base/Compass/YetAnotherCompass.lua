-- RdK Group Tool Yet another Compass
-- By @s0rdrak (PC / EU)

RdKGTool.compass = RdKGTool.compass or {}
RdKGTool.compass.yacs = RdKGTool.compass.yacs or {}
local RdKGToolYacs = RdKGTool.compass.yacs
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu

RdKGToolYacs.callbackName = RdKGTool.addonName .. "Yacs"
RdKGToolYacs.updateInterval = 10

local wm = GetWindowManager()


RdKGToolYacs.controls = {}

RdKGToolYacs.constants = RdKGToolYacs.constants or {}
RdKGToolYacs.constants.references = RdKGToolYacs.constants.references or {}
RdKGToolYacs.constants.references.YACS_CHECKBOX_ENABLE_ADDON = "YACS_ENABLE_ADDON_CHECKBOX_CONTROL"
RdKGToolYacs.constants.references.YACS_CHECKBOX_PVP = "YACS_CHECKBOX_PVP"
RdKGToolYacs.constants.references.YACS_CHECKBOX_PVE = "YACS_CHECKBOX_PVE"
RdKGToolYacs.constants.references.YACS_CHECKBOX_COMBAT = "YACS_CHECKBOX_COMBAT"
RdKGToolYacs.constants.references.YACS_CHECKBOX_MOVABLE = "YACS_CHECKBOX_MOVABLE"
RdKGToolYacs.constants.references.YACS_DROPDOWN_COMPASS_STYLES = "YACS_DROPDOWN_COMPASS_STYLE"



RdKGToolYacs.config = {}
RdKGToolYacs.config.constants = {}
RdKGToolYacs.config.constants.TLW_NAME = "RdKGroupTool_Compass_YACS_TLW"
RdKGToolYacs.config.constants.COMPASS_NAME = "RdKGroupTool_Compass_YACS_COMPASS"
RdKGToolYacs.compasses = {}
RdKGToolYacs.compasses[1] = {}
RdKGToolYacs.compasses[1].dds = "RdKGroupTool/Art/Compasses/Compass.dds"
RdKGToolYacs.compasses[2] = {}
RdKGToolYacs.compasses[2].dds = "RdKGroupTool/Art/Compasses/Default_Fat_N.dds"
RdKGToolYacs.compasses[3] = {}
RdKGToolYacs.compasses[3].dds = "RdKGroupTool/Art/Compasses/Default_Thin_Lines.dds"
RdKGToolYacs.compasses[4] = {}
RdKGToolYacs.compasses[4].dds = "RdKGroupTool/Art/Compasses/Fancy_Underline_N.dds"
RdKGToolYacs.compasses[5] = {}
RdKGToolYacs.compasses[5].dds = "RdKGroupTool/Art/Compasses/Fat_Underline_N.dds"
RdKGToolYacs.compasses[6] = {}
RdKGToolYacs.compasses[6].dds = "RdKGroupTool/Art/Compasses/Scribble.dds"
RdKGToolYacs.compasses[7] = {}
RdKGToolYacs.compasses[7].dds = "RdKGroupTool/Art/Compasses/Circled1.dds"
RdKGToolYacs.compasses[8] = {}
RdKGToolYacs.compasses[8].dds = "RdKGroupTool/Art/Compasses/Circled2.dds"
RdKGToolYacs.compasses[9] = {}
RdKGToolYacs.compasses[9].dds = "RdKGroupTool/Art/Compasses/Diamond1.dds"
RdKGToolYacs.compasses[10] = {}
RdKGToolYacs.compasses[10].dds = "RdKGroupTool/Art/Compasses/Diamond2.dds"
RdKGToolYacs.compasses[11] = {}
RdKGToolYacs.compasses[11].dds = "RdKGroupTool/Art/Compasses/Dots1.dds"
RdKGToolYacs.compasses[12] = {}
RdKGToolYacs.compasses[12].dds = "RdKGroupTool/Art/Compasses/Dots2.dds"
RdKGToolYacs.compasses[13] = {}
RdKGToolYacs.compasses[13].dds = "RdKGroupTool/Art/Compasses/ELetters1.dds"
RdKGToolYacs.compasses[14] = {}
RdKGToolYacs.compasses[14].dds = "RdKGroupTool/Art/Compasses/ELetters2.dds"
RdKGToolYacs.compasses[15] = {}
RdKGToolYacs.compasses[15].dds = "RdKGroupTool/Art/Compasses/FullArrow1.dds"
RdKGToolYacs.compasses[16] = {}
RdKGToolYacs.compasses[16].dds = "RdKGroupTool/Art/Compasses/FullArrow2.dds"
RdKGToolYacs.compasses[17] = {}
RdKGToolYacs.compasses[17].dds = "RdKGroupTool/Art/Compasses/Needle1.dds"
RdKGToolYacs.compasses[18] = {}
RdKGToolYacs.compasses[18].dds = "RdKGroupTool/Art/Compasses/Needle2.dds"
RdKGToolYacs.compasses[19] = {}
RdKGToolYacs.compasses[19].dds = "RdKGroupTool/Art/Compasses/SmallArrow1.dds"
RdKGToolYacs.compasses[20] = {}
RdKGToolYacs.compasses[20].dds = "RdKGroupTool/Art/Compasses/SmallArrow2.dds"
RdKGToolYacs.compasses[21] = {}
RdKGToolYacs.compasses[21].dds = "RdKGroupTool/Art/Compasses/compass_fr1.dds"
RdKGToolYacs.compasses[22] = {}
RdKGToolYacs.compasses[22].dds = "RdKGroupTool/Art/Compasses/compass_fr2.dds"
RdKGToolYacs.compasses[23] = {}
RdKGToolYacs.compasses[23].dds = "RdKGroupTool/Art/Compasses/compass_fr3.dds"
RdKGToolYacs.compasses[24] = {}
RdKGToolYacs.compasses[24].dds = "RdKGroupTool/Art/Compasses/compass_fr4.dds"
RdKGToolYacs.config.isClampedToScreen = true
RdKGToolYacs.config.backdropColor = {}
RdKGToolYacs.config.backdropColor.r = 0.1
RdKGToolYacs.config.backdropColor.g = 0.1
RdKGToolYacs.config.backdropColor.b = 0.1
RdKGToolYacs.config.backdropColor.a = 0.4


RdKGToolYacs.state = {}
RdKGToolYacs.state.foreground = true
RdKGToolYacs.state.initialized = false
RdKGToolYacs.state.registredConsumers = false
RdKGToolYacs.state.activeLayerIndex = 1
RdKGToolYacs.state.registredActiveConsumers = false

function RdKGToolYacs.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolYacs.callbackName, RdKGToolYacs.OnProfileChanged)
	
	if RdKGToolYacs.yacsVars.compassStyle == nil or RdKGToolYacs.yacsVars.compassStyle == 0 or RdKGToolYacs.yacsVars.compassStyle > #RdKGToolYacs.compasses then
		RdKGToolYacs.yacsVars.compassStyle = 1
	end
	ZO_CreateStringId("SI_BINDING_NAME_RDKGTOOL_YETANOTHERCOMPASS_OPEN", RdKGToolYacs.config.constants.TOGGLE_YACS)
	
	RdKGToolYacs.controls.TLW = wm:CreateTopLevelWindow(RdKGToolYacs.config.constants.TLW_NAME)
	RdKGToolYacs.controls.TLW:SetDimensions(RdKGToolYacs.yacsVars.size, RdKGToolYacs.yacsVars.size)
	
		
	RdKGToolYacs.controls.TLW:SetClampedToScreen(RdKGToolYacs.config.isClampedToScreen)
	RdKGToolYacs.controls.TLW:SetDrawLayer(0)
	RdKGToolYacs.controls.TLW:SetDrawLevel(0)
	RdKGToolYacs.controls.TLW:SetHandler("OnMoveStop", RdKGToolYacs.SaveFrameLocation)
	
	RdKGToolYacs.controls.compass = wm:CreateControl(RdKGToolYacs.config.constants.COMPASS_NAME, RdKGToolYacs.controls.TLW, CT_TEXTURE)
	
	RdKGToolYacs.controls.compass:SetAnchor(TOPLEFT, RdKGToolYacs.controls.TLW, TOPLEFT, 0, 0)
	RdKGToolYacs.controls.compass:SetColor(RdKGToolYacs.yacsVars.color.r, RdKGToolYacs.yacsVars.color.g, RdKGToolYacs.yacsVars.color.b, RdKGToolYacs.yacsVars.color.a)
	RdKGToolYacs.AdjustCompassTexture()
		
	
	
	RdKGToolYacs.controls.movableBackdrop = wm:CreateControl(nil, RdKGToolYacs.controls.TLW, CT_BACKDROP)
	
	RdKGToolYacs.controls.movableBackdrop:SetAnchor(TOPLEFT, RdKGToolYacs.controls.TLW, TOPLEFT, 0, 0)
	RdKGToolYacs.controls.movableBackdrop:SetHidden(not RdKGToolYacs.yacsVars.movableCompass)
	RdKGToolYacs.controls.movableBackdrop:SetCenterColor(RdKGToolYacs.config.backdropColor.r, RdKGToolYacs.config.backdropColor.g, RdKGToolYacs.config.backdropColor.b, RdKGToolYacs.config.backdropColor.a)
	RdKGToolYacs.controls.movableBackdrop:SetEdgeColor(RdKGToolYacs.config.backdropColor.r, RdKGToolYacs.config.backdropColor.g, RdKGToolYacs.config.backdropColor.b, 0.0)
	
	RdKGToolYacs.AdjustConfigSpecificUI()
	
	RdKGToolMenu.AddPositionFixedConsumer(RdKGToolYacs.SetPositionLocked)
	
	RdKGToolYacs.state.initialized = true
	RdKGToolYacs.SetEnabled(RdKGToolYacs.yacsVars.enabled)
	
end

function RdKGToolYacs.SaveFrameLocation()
	if RdKGToolYacs.yacsVars.movableCompass == true then
		RdKGToolYacs.yacsVars.centered = false
		RdKGToolYacs.yacsVars.position.x = RdKGToolYacs.controls.TLW:GetLeft()
		RdKGToolYacs.yacsVars.position.y = RdKGToolYacs.controls.TLW:GetTop()
	end
	
end

function RdKGToolYacs.ChangeTLWMovability(movable)
	if movable == nil or movable == false then
		RdKGToolYacs.controls.TLW:SetMovable(false)
		RdKGToolYacs.controls.TLW:SetMouseEnabled(false)
	else
		RdKGToolYacs.controls.TLW:SetMovable(true)
		RdKGToolYacs.controls.TLW:SetMouseEnabled(true)
	end
end

function RdKGToolYacs.AdjustCompassTexture()
	if RdKGToolYacs.yacsVars.compassStyle ~= nil and RdKGToolYacs.yacsVars.compassStyle > 0 and RdKGToolYacs.yacsVars.compassStyle <= #RdKGToolYacs.compasses then
		RdKGToolYacs.controls.compass:SetTexture(RdKGToolYacs.compasses[RdKGToolYacs.yacsVars.compassStyle].dds)
	end
end

function RdKGToolYacs.GetDefaults()
	local defaults = {}
	defaults.color = {}
	defaults.color.r = 0.0
	defaults.color.g = 1.0
	defaults.color.b = 0.25
	defaults.color.a = 1.0
	defaults.size = 160
	defaults.centered = true
	defaults.position = {}
	defaults.position.x = 0
	defaults.position.y = 0
	defaults.enabled = true
	defaults.pvpEnabled = true
	defaults.pveEnabled = true
	defaults.combatEnabled = true
	defaults.movableCompass = false
	defaults.compassStyle = 5
	return defaults
end

function RdKGToolYacs.AdjustConfigSpecificUI()
	RdKGToolYacs.controls.TLW:ClearAnchors()
	if RdKGToolYacs.yacsVars.centered == true then
		RdKGToolYacs.controls.TLW:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	else
		RdKGToolYacs.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolYacs.yacsVars.position.x, RdKGToolYacs.yacsVars.position.y)
	end
	RdKGToolYacs.controls.TLW:SetDimensions(RdKGToolYacs.yacsVars.size, RdKGToolYacs.yacsVars.size)
	RdKGToolYacs.controls.compass:SetDimensions(RdKGToolYacs.yacsVars.size, RdKGToolYacs.yacsVars.size)
	RdKGToolYacs.controls.movableBackdrop:SetDimensions(RdKGToolYacs.yacsVars.size, RdKGToolYacs.yacsVars.size)
	
	RdKGToolYacs.SetMovableState(RdKGToolYacs.yacsVars.movableCompass)
	RdKGToolYacs.AdjustCompassTexture()
	RdKGToolYacs.controls.compass:SetColor(RdKGToolYacs.yacsVars.color.r, RdKGToolYacs.yacsVars.color.g, RdKGToolYacs.yacsVars.color.b, RdKGToolYacs.yacsVars.color.a)
end

function RdKGToolYacs.OnKeyBinding()
	RdKGToolYacs.SetEnabled(not RdKGToolYacs.yacsVars.enabled)
	RdKGToolYacs.UpdateYacsState()
end

--[[
SLASH_COMMANDS[RdKGToolYacs.slashCmd] = function(param)
	d(string.format("%s %s", RdKGToolYacs.slashCmd, param))
	param = zo_strtrim(param)
	if param == "on" then
		RdKGToolYacs.SetEnabled(true)
		RdKGToolYacs.menu.UpdateAddonState()
	elseif param == "off" then
		RdKGToolYacs.SetEnabled(false)
		RdKGToolYacs.menu.UpdateAddonState()
	elseif param == "menu" then
		RdKGToolYacs.menu.OpenMenu()
	else
		d(RdKGToolYacs.config.constants.CMD_TEXT_ON_OFF)
		d(RdKGToolYacs.config.constants.CMD_TEXT_MENU)
	end
end
]]
function RdKGToolYacs.SetPositionLocked(value)
	RdKGToolYacs.SetMovableState(not value)
end

function RdKGToolYacs.SetControlVisibility()
	local enabled = RdKGToolYacs.yacsVars.enabled
	local pvpEnabled = RdKGToolYacs.yacsVars.pvpEnabled
	local pveEnabled = RdKGToolYacs.yacsVars.pveEnabled
	local setHidden = true
	if enabled ~= nil and pvpEnabled ~= nil and pveEnabled ~= nil then
		local isInPvPArea = RdKGToolUtil.IsInPvPArea()
		if enabled == true and ((pvpEnabled == true and isInPvPArea == true) or (pveEnabled == true and isInPvPArea == false)) then
			setHidden = false
		end
	end
	if setHidden == false then
		if RdKGToolYacs.state.foreground == false then
			RdKGToolYacs.controls.TLW:SetHidden(RdKGToolYacs.state.activeLayerIndex > 2)
		else
			RdKGToolYacs.controls.TLW:SetHidden(false)
		end
	else
		RdKGToolYacs.controls.TLW:SetHidden(setHidden)
	end
end

--callbacks
function RdKGToolYacs.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolYacs.yacsVars = currentProfile.compass.yacs
		RdKGToolYacs.SetEnabled(RdKGToolYacs.yacsVars.enabled)
		if RdKGToolYacs.state.initialized == true then
			RdKGToolYacs.AdjustConfigSpecificUI()
			
		end
	end
end

function RdKGToolYacs.OnUpdate()
	local pvpZone = RdKGToolUtil.IsInPvPArea()
	
	if ((RdKGToolYacs.yacsVars.pvpEnabled == true and pvpZone == true) or (RdKGToolYacs.yacsVars.pveEnabled == true and pvpZone == false)) and (RdKGToolYacs.yacsVars.combatEnabled == true or RdKGToolYacs.yacsVars.combatEnabled == false and IsUnitInCombat("player") == false ) then
		RdKGToolYacs.controls.compass:SetHidden(false)
		RdKGToolYacs.controls.compass:SetTextureRotation(-GetPlayerCameraHeading())
	else
		RdKGToolYacs.controls.compass:SetHidden(true)
	end
end

function RdKGToolYacs.OnPlayerActivated(eventCode, initial)
	local isInPvPArea = RdKGToolUtil.IsInPvPArea()
	if RdKGToolYacs.yacsVars.enabled and ((RdKGToolYacs.yacsVars.pvpEnabled == true and isInPvPArea == true) or (RdKGToolYacs.yacsVars.pveEnabled == true and isInPvPArea == false)) then
		if RdKGToolYacs.state.registredActiveConsumers == false then
			EVENT_MANAGER:RegisterForEvent(RdKGToolYacs.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolYacs.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForEvent(RdKGToolYacs.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolYacs.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolYacs.callbackName, RdKGToolYacs.updateInterval, RdKGToolYacs.OnUpdate)
			RdKGToolYacs.state.registredActiveConsumers = true
		end
	else
		if RdKGToolYacs.state.registredActiveConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(RdKGToolYacs.callbackName, EVENT_ACTION_LAYER_POPPED)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolYacs.callbackName, EVENT_ACTION_LAYER_PUSHED)
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolYacs.callbackName)
			RdKGToolYacs.state.registredActiveConsumers = false
		end
	end
	RdKGToolYacs.SetControlVisibility()
end

function RdKGToolYacs.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolYacs.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolYacs.state.foreground = false
	end
	--hack?
	RdKGToolYacs.state.activeLayerIndex = activeLayerIndex
	
	RdKGToolYacs.SetControlVisibility()
end

--menu interaction
function RdKGToolYacs.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.YACS_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.YACS_CHK_ADDON_ENABLED,
					getFunc = RdKGToolYacs.GetEnabled,
					setFunc = RdKGToolYacs.SetEnabled,
					reference = RdKGToolYacs.constants.references.YACS_CHECKBOX_ENABLE_ADDON
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.YACS_CHK_PVP,
					getFunc = RdKGToolYacs.GetPvpState,
					setFunc = RdKGToolYacs.SetPvpState,
					reference = RdKGToolYacs.constants.references.YACS_CHECKBOX_PVP
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.YACS_CHK_PVE,
					getFunc = RdKGToolYacs.GetPveState,
					setFunc = RdKGToolYacs.SetPveState,
					reference = RdKGToolYacs.constants.references.YACS_CHECKBOX_PVE
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.YACS_CHK_COMBAT,
					getFunc = RdKGToolYacs.GetCombatState,
					setFunc = RdKGToolYacs.SetCombatState,
					reference = RdKGToolYacs.constants.references.YACS_CHECKBOX_COMBAT
				},
				[5] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.YACS_CHK_MOVABLE,
					getFunc = RdKGToolYacs.GetMovableState,
					setFunc = RdKGToolYacs.SetMovableState,
					reference = RdKGToolYacs.constants.references.YACS_CHECKBOX_MOVABLE
				},
				[6] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.YACS_COLOR_COMPASS,
					getFunc = RdKGToolYacs.GetCompassColor,
					setFunc = RdKGToolYacs.SetCompassColor,
					width = "full"
				},
				[7] = {
					type = "slider",
					name = RdKGToolMenu.constants.YACS_COMPASS_SIZE,
					tooltip = RdKGToolMenu.constants.YACS_COMPASS_SIZE_TOOLTIPE,
					min = 10,
					max = 500,
					step = 1,
					getFunc = RdKGToolYacs.GetCompassSize,
					setFunc = RdKGToolYacs.SetCompassSize,
					width = "full",
					default = RdKGToolYacs.GetCompassSize()
				},
				[8] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.YACS_COMPASS_STYLE,
					tooltip = RdKGToolMenu.constants.YACS_COMPASS_STYLE_TOOLTIP,
					choices = RdKGToolYacs.GetCompassStyles(),
					getFunc = RdKGToolYacs.GetCurrentCompassStyle,
					setFunc = RdKGToolYacs.SetCurrentCompassStyle,
					reference = RdKGToolYacs.constants.references.YACS_DROPDOWN_COMPASS_STYLES
				},
				[9] = {
					type = "button",
					name = RdKGToolMenu.constants.YACS_RESTORE_DEFAULTS,
					func = RdKGToolYacs.RestoreDefaults,
					width = "full"
				}
			}
		},
	}
	return menu
end

function RdKGToolYacs.SetEnabled(value)
	if RdKGToolYacs.state.initialized == true then
		RdKGToolYacs.yacsVars.enabled = value
		
		
		if value == true then
			if RdKGToolYacs.state.registredConsumers == false then
				
				EVENT_MANAGER:RegisterForEvent(RdKGToolYacs.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolYacs.OnPlayerActivated)
				
			end
			RdKGToolYacs.state.registredConsumers = true
		else
			if RdKGToolYacs.state.registredConsumers == true then
				
				EVENT_MANAGER:UnregisterForEvent(RdKGToolYacs.callbackName, EVENT_PLAYER_ACTIVATED)
				
			end
			RdKGToolYacs.state.registredConsumers = false
		end
		RdKGToolYacs.OnPlayerActivated()
	end
end

function RdKGToolYacs.GetEnabled()
	return RdKGToolYacs.yacsVars.enabled
end

function RdKGToolYacs.GetPvpState()
	return RdKGToolYacs.yacsVars.pvpEnabled
end

function RdKGToolYacs.SetPvpState(value)
	RdKGToolYacs.yacsVars.pvpEnabled = value
	RdKGToolYacs.SetEnabled(RdKGToolYacs.yacsVars.enabled)
end

function RdKGToolYacs.GetPveState()
	return RdKGToolYacs.yacsVars.pveEnabled
end

function RdKGToolYacs.SetPveState(value)
	RdKGToolYacs.yacsVars.pveEnabled = value
	RdKGToolYacs.SetEnabled(RdKGToolYacs.yacsVars.enabled)
end

function RdKGToolYacs.GetCombatState()
	return RdKGToolYacs.yacsVars.combatEnabled
end

function RdKGToolYacs.SetCombatState(value)
	RdKGToolYacs.yacsVars.combatEnabled = value
end

function RdKGToolYacs.SetCompassColor(r, g, b, a)
	RdKGToolYacs.yacsVars.color = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
	RdKGToolYacs.controls.compass:SetColor(r, g, b, a)
end

function RdKGToolYacs.GetCompassColor()
	return RdKGToolMenu.GetRGBAColor(RdKGToolYacs.yacsVars.color)
end

function RdKGToolYacs.SetCompassSize(size)
	RdKGToolYacs.yacsVars.size = size
	RdKGToolYacs.AdjustConfigSpecificUI()
end

function RdKGToolYacs.GetCompassSize()
	return RdKGToolYacs.yacsVars.size
end

function RdKGToolYacs.GetCurrentCompassStyle()
	return RdKGToolYacs.compasses[RdKGToolYacs.yacsVars.compassStyle].name
end

function RdKGToolYacs.SetCurrentCompassStyle(style)
	local id = 0
	for i = 1, #RdKGToolYacs.compasses do
		if style == RdKGToolYacs.compasses[i].name then
			id = i
			break
		end
	end
	RdKGToolYacs.yacsVars.compassStyle = id
	RdKGToolYacs.AdjustCompassTexture()
end

function RdKGToolYacs.GetCompassStyles()
	local compassNames = {}
	for i = 1, #RdKGToolYacs.compasses do
		compassNames[i] = RdKGToolYacs.compasses[i].name
	end
	return compassNames
end

function RdKGToolYacs.GetMovableState()
	return RdKGToolYacs.yacsVars.movableCompass
end

function RdKGToolYacs.SetMovableState(value)
	RdKGToolYacs.yacsVars.movableCompass = value
	RdKGToolYacs.ChangeTLWMovability(value)
	RdKGToolYacs.controls.movableBackdrop:SetHidden(not RdKGToolYacs.yacsVars.movableCompass)
end

function RdKGToolYacs.RestoreDefaults()
	local defaults = RdKGToolYacs.GetDefaults()
	for key, value in pairs(defaults) do
		RdKGToolYacs.yacsVars[key] = value
	end
	 
	RdKGToolYacs.controls.movableBackdrop:SetHidden(not RdKGToolYacs.yacsVars.movableCompass)
	
	RdKGToolYacs.AdjustConfigSpecificUI()

	RdKGToolYacs.UpdateYacsState()
	--RdKGToolYacs.SetEnabled(RdKGToolYacs.yacsVars.enabled)
end

function RdKGToolYacs.UpdateYacsState()
	RdKGToolMenu.UpdateCheckbox(wm:GetControlByName(RdKGToolYacs.constants.references.YACS_CHECKBOX_ENABLE_ADDON))
	RdKGToolMenu.UpdateCheckbox(wm:GetControlByName(RdKGToolYacs.constants.references.YACS_CHECKBOX_PVP))
	RdKGToolMenu.UpdateCheckbox(wm:GetControlByName(RdKGToolYacs.constants.references.YACS_CHECKBOX_PVE))
	RdKGToolMenu.UpdateCheckbox(wm:GetControlByName(RdKGToolYacs.constants.references.YACS_CHECKBOX_COMBAT))
	RdKGToolMenu.UpdateCheckbox(wm:GetControlByName(RdKGToolYacs.constants.references.YACS_CHECKBOX_MOVABLE))
	RdKGToolMenu.UpdateControl(wm:GetControlByName(RdKGToolYacs.constants.references.YACS_DROPDOWN_COMPASS_STYLES))
end