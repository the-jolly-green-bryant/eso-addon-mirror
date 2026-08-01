-- YetAnotherCompass
-- By @s0rdrak, @schorse4044 (PC / EU)

YACS = {}
YACS.addonName = "YetAnotherCompass"
YACS.version = 1
YACS.versionString = "1.5.21"
YACS.updateInterval = 20 -- in ms
YACS.author = "@s0rdrak, @schorse4044 (PC / EU)"
YACS.credits = "@Neltje" 
YACS.slashCmd = "/yacs"

YACS.menu = {}
YACS.menu.name = "YetAnotherCompass"
YACS.controls = {}

YACS.default = {}
YACS.default.color = {}
YACS.default.color.R = 0.0
YACS.default.color.G = 1.0
YACS.default.color.B = 0.25
YACS.default.color.A = 1.0
YACS.default.size = 150
YACS.default.centered = true
YACS.default.position = {}
YACS.default.position.x = 0
YACS.default.position.y = 0

YACS.defaultChar = {}
YACS.defaultChar.isEnabled = true
YACS.defaultChar.pvpEnabled = true
YACS.defaultChar.pveEnabled = true
YACS.defaultChar.combatEnabled = true
YACS.defaultChar.movableCompass = false

YACS.config = {}
YACS.config.constants = {}
YACS.config.constants.TLW_NAME = "YACS_TLW"
YACS.config.constants.COMPASS_NAME = "YACS_COMPASS"
YACS.compasses = {}
YACS.compasses[1] = {}
YACS.compasses[1].dds = "YetAnotherCompass/Compasses/Compass.dds"
YACS.compasses[2] = {}
YACS.compasses[2].dds = "YetAnotherCompass/Compasses/Default_Fat_N.dds"
YACS.compasses[3] = {}
YACS.compasses[3].dds = "YetAnotherCompass/Compasses/Default_Thin_Lines.dds"
YACS.compasses[4] = {}
YACS.compasses[4].dds = "YetAnotherCompass/Compasses/Fancy_Underline_N.dds"
YACS.compasses[5] = {}
YACS.compasses[5].dds = "YetAnotherCompass/Compasses/Fat_Underline_N.dds"
YACS.compasses[6] = {}
YACS.compasses[6].dds = "YetAnotherCompass/Compasses/Scribble.dds"
YACS.compasses[7] = {}
YACS.compasses[7].dds = "YetAnotherCompass/Compasses/Circled1.dds"
YACS.compasses[8] = {}
YACS.compasses[8].dds = "YetAnotherCompass/Compasses/Circled2.dds"
YACS.compasses[9] = {}
YACS.compasses[9].dds = "YetAnotherCompass/Compasses/Diamond1.dds"
YACS.compasses[10] = {}
YACS.compasses[10].dds = "YetAnotherCompass/Compasses/Diamond2.dds"
YACS.compasses[11] = {}
YACS.compasses[11].dds = "YetAnotherCompass/Compasses/Dots1.dds"
YACS.compasses[12] = {}
YACS.compasses[12].dds = "YetAnotherCompass/Compasses/Dots2.dds"
YACS.compasses[13] = {}
YACS.compasses[13].dds = "YetAnotherCompass/Compasses/ELetters1.dds"
YACS.compasses[14] = {}
YACS.compasses[14].dds = "YetAnotherCompass/Compasses/ELetters2.dds"
YACS.compasses[15] = {}
YACS.compasses[15].dds = "YetAnotherCompass/Compasses/FullArrow1.dds"
YACS.compasses[16] = {}
YACS.compasses[16].dds = "YetAnotherCompass/Compasses/FullArrow2.dds"
YACS.compasses[17] = {}
YACS.compasses[17].dds = "YetAnotherCompass/Compasses/Needle1.dds"
YACS.compasses[18] = {}
YACS.compasses[18].dds = "YetAnotherCompass/Compasses/Needle2.dds"
YACS.compasses[19] = {}
YACS.compasses[19].dds = "YetAnotherCompass/Compasses/SmallArrow1.dds"
YACS.compasses[20] = {}
YACS.compasses[20].dds = "YetAnotherCompass/Compasses/SmallArrow2.dds"
YACS.compasses[21] = {}
YACS.compasses[21].dds = "YetAnotherCompass/Compasses/compass_fr1.dds"
YACS.compasses[22] = {}
YACS.compasses[22].dds = "YetAnotherCompass/Compasses/compass_fr2.dds"
YACS.compasses[23] = {}
YACS.compasses[23].dds = "YetAnotherCompass/Compasses/compass_fr3.dds"
YACS.compasses[24] = {}
YACS.compasses[24].dds = "YetAnotherCompass/Compasses/compass_fr4.dds"
YACS.config.isMovable = false
YACS.config.isMouseEnabled = false
YACS.config.isClampedToScreen = true
YACS.config.backdropColor = {}
YACS.config.backdropColor.R = 0.1
YACS.config.backdropColor.G = 0.1
YACS.config.backdropColor.B = 0.1
YACS.config.backdropColor.A = 0.4

YACS.savedVars = nil
YACS.savedVarsChar = nil

YACS.addonState = {}
YACS.addonState.foreground = true

local wm = GetWindowManager()

function YACS.YACSOnInitialize(event, addonName)

	if addonName == YACS.addonName then
		EVENT_MANAGER:UnregisterForEvent(YACS.addonName, EVENT_ADD_ON_LOADED)
		YACS.savedVars = ZO_SavedVars:NewAccountWide("YetAnotherCompassVars", YACS.version, nil, YACS.default)
		YACS.savedVarsChar = ZO_SavedVars:New("YetAnotherCompassVars", YACS.version, nil, YACS.defaultChar)
		if YACS.savedVars.compassStyle == nil or YACS.savedVars.compassStyle == 0 or YACS.savedVars.compassStyle > #YACS.compasses then
			YACS.savedVars.compassStyle = 1
		end
		ZO_CreateStringId("SI_BINDING_NAME_YETANOTHERCOMPASS_OPEN", YACS.config.constants.TOGGLE_YACS)
		YACS.menu.Initialize()
		YACS.controls.TLW = wm:CreateTopLevelWindow(YACS.config.constants.TLW_NAME)
		YACS.controls.TLW:SetDimensions(YACS.savedVars.size, YACS.savedVars.size)
		

		
		YACS.controls.TLW:SetClampedToScreen(YACS.config.isClampedToScreen)
		YACS.controls.TLW:SetDrawLayer(0)
		YACS.controls.TLW:SetDrawLevel(0)
		YACS.controls.TLW:SetHandler("OnMoveStop", YACS.SaveFrameLocation)
		
		YACS.controls.compass = wm:CreateControl(YACS.config.constants.COMPASS_NAME, YACS.controls.TLW, CT_TEXTURE)
		
		YACS.controls.compass:SetAnchor(TOPLEFT, YACS.controls.TLW, TOPLEFT, 0, 0)
		YACS.controls.compass:SetColor(YACS.savedVars.color.R, YACS.savedVars.color.G, YACS.savedVars.color.B, YACS.savedVars.color.A)
		YACS.AdjustCompassTexture()

		--if YACS.savedVarsChar.isEnabled == true then
		--	EVENT_MANAGER:RegisterForUpdate(YACS.addonName, YACS.updateInterval, YACS.YACSOnUpdate) 
		--end
		
		YACS.SetEnabled(YACS.savedVarsChar.isEnabled)
		
		YACS.controls.movableBackdrop = wm:CreateControl(nil, YACS.controls.TLW, CT_BACKDROP)
		
		YACS.controls.movableBackdrop:SetAnchor(TOPLEFT, YACS.controls.TLW, TOPLEFT, 0, 0)
		YACS.controls.movableBackdrop:SetHidden(not YACS.savedVarsChar.movableCompass)
		YACS.controls.movableBackdrop:SetCenterColor(YACS.config.backdropColor.R, YACS.config.backdropColor.G, YACS.config.backdropColor.B, YACS.config.backdropColor.A)
		YACS.controls.movableBackdrop:SetEdgeColor(YACS.config.backdropColor.R, YACS.config.backdropColor.G, YACS.config.backdropColor.B, 0.0)
		
		YACS.AdjustConfigSpecificUI()
		
		EVENT_MANAGER:RegisterForEvent(YACS.addonName, EVENT_ACTION_LAYER_POPPED, YACS.SetVisible)
		EVENT_MANAGER:RegisterForEvent(YACS.addonName, EVENT_ACTION_LAYER_PUSHED, YACS.SetVisible)
	end
end

function YACS.SaveFrameLocation()
	if YACS.savedVarsChar.movableCompass == true then
		YACS.savedVars.centered = false
		YACS.savedVars.position.x = YACS.controls.TLW:GetLeft()
		YACS.savedVars.position.y = YACS.controls.TLW:GetTop()
	end
	
end

function YACS.ChangeTLWMovability(movable)
	if movable == nil or movable == false then
		YACS.controls.TLW:SetMovable(YACS.config.isMovable)
		YACS.controls.TLW:SetMouseEnabled(YACS.config.isMouseEnabled)
	else
		YACS.controls.TLW:SetMovable(true)
		YACS.controls.TLW:SetMouseEnabled(true)
	end
end

function YACS.AdjustCompassTexture()
	if YACS.savedVars.compassStyle ~= nil and YACS.savedVars.compassStyle > 0 and YACS.savedVars.compassStyle <= #YACS.compasses then
		YACS.controls.compass:SetTexture(YACS.compasses[YACS.savedVars.compassStyle].dds)
	end
end

function YACS.YACSOnUpdate()
	local pvpZone = IsPlayerInAvAWorld()
	if ((YACS.savedVarsChar.pvpEnabled == true and pvpZone == true) or (YACS.savedVarsChar.pveEnabled == true and pvpZone == false)) and (YACS.savedVarsChar.combatEnabled == true or YACS.savedVarsChar.combatEnabled == false and IsUnitInCombat("player") == false ) then
		YACS.controls.compass:SetHidden(false)
		YACS.controls.compass:SetTextureRotation(-GetPlayerCameraHeading())
	else
		YACS.controls.compass:SetHidden(true)
	end
end

function YACS.SetVisible(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		YACS.addonState.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		YACS.addonState.foreground = false
	end
	if YACS.savedVarsChar.isEnabled == true then
		YACS.controls.TLW:SetHidden(activeLayerIndex > 2)
	end
end

EVENT_MANAGER:RegisterForEvent(YACS.addonName, EVENT_ADD_ON_LOADED, YACS.YACSOnInitialize)

function YACS.SetEnabled(value)
	YACS.savedVarsChar.isEnabled = value
	if YACS.addonState.foreground == true then
		YACS.controls.TLW:SetHidden(not YACS.savedVarsChar.isEnabled)
	end
	if YACS.savedVarsChar.isEnabled == true then
		EVENT_MANAGER:RegisterForUpdate(YACS.addonName, YACS.updateInterval, YACS.YACSOnUpdate)
	else
		EVENT_MANAGER:UnregisterForUpdate(YACS.addonName, YACS.updateInterval)
	end
end

function YACS.GetEnabled()
	return YACS.savedVarsChar.isEnabled
end

function YACS.GetPvpState()
	return YACS.savedVarsChar.pvpEnabled
end

function YACS.SetPvpState(value)
	YACS.savedVarsChar.pvpEnabled = value
end

function YACS.GetPveState()
	return YACS.savedVarsChar.pveEnabled
end

function YACS.SetPveState(value)
	YACS.savedVarsChar.pveEnabled = value
end

function YACS.GetCombatState()
	return YACS.savedVarsChar.combatEnabled
end

function YACS.SetCombatState(value)
	YACS.savedVarsChar.combatEnabled = value
end

function YACS.SetCompassColor(color)
	YACS.savedVars.color = color
	YACS.controls.compass:SetColor(YACS.savedVars.color.R, YACS.savedVars.color.G, YACS.savedVars.color.B, YACS.savedVars.color.A)
end

function YACS.GetCompassColor()
	return YACS.savedVars.color
end

function YACS.SetCompassSize(size)
	YACS.savedVars.size = size
	YACS.AdjustConfigSpecificUI()
end

function YACS.GetCompassSize()
	return YACS.savedVars.size
end

function YACS.GetCurrentCompassStyle()
	return YACS.compasses[YACS.savedVars.compassStyle].name
end

function YACS.SetCurrentCompassStyle(style)
	local id = 0
	for i = 1, #YACS.compasses do
		if style == YACS.compasses[i].name then
			id = i
			break
		end
	end
	YACS.savedVars.compassStyle = id
	YACS.AdjustCompassTexture()
end

function YACS.GetCompassStyles()
	local compassNames = {}
	for i = 1, #YACS.compasses do
		compassNames[i] = YACS.compasses[i].name
	end
	return compassNames
end

function YACS.GetMovableState()
	return YACS.savedVarsChar.movableCompass
end

function YACS.SetMovableState(value)
	YACS.savedVarsChar.movableCompass = value
	YACS.ChangeTLWMovability(value)
	YACS.controls.movableBackdrop:SetHidden(not YACS.savedVarsChar.movableCompass)
end

function YACS.AdjustConfigSpecificUI()
	if YACS.savedVars.centered == true then
		YACS.controls.TLW:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	else
		YACS.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, YACS.savedVars.position.x, YACS.savedVars.position.y)
	end
	YACS.controls.TLW:SetDimensions(YACS.savedVars.size, YACS.savedVars.size)
	YACS.controls.compass:SetDimensions(YACS.savedVars.size, YACS.savedVars.size)
	YACS.controls.movableBackdrop:SetDimensions(YACS.savedVars.size, YACS.savedVars.size)
	
	YACS.ChangeTLWMovability(YACS.savedVarsChar.movableCompass)
	YACS.AdjustCompassTexture()
end

function YACS.RestoreDefaults()
	local accVars = YACS.savedVars
	local charVars = YACS.savedVarsChar
	accVars.size = YACS.default.size
	accVars.color = YACS.default.color
	accVars.centered = YACS.default.centered
	accVars.position = YACS.default.position
	
	charVars.isEnabled = YACS.defaultChar.isEnabled
	charVars.pvpEnabled = YACS.defaultChar.pvpEnabled
	charVars.pveEnabled = YACS.defaultChar.pveEnabled
	charVars.combatEnabled = YACS.defaultChar.combatEnabled
	charVars.movableCompass = YACS.defaultChar.movableCompass
	YACS.controls.movableBackdrop:SetHidden(not YACS.savedVarsChar.movableCompass)
	
	YACS.AdjustConfigSpecificUI()

	YACS.menu.UpdateAddonState()
end

function YACS.OnKeyBinding()
	YACS.SetEnabled(not YACS.savedVarsChar.isEnabled)
	YACS.menu.UpdateAddonState()
end

SLASH_COMMANDS[YACS.slashCmd] = function(param)
	d(string.format("%s %s", YACS.slashCmd, param))
	param = zo_strtrim(param)
	if param == "on" then
		YACS.SetEnabled(true)
		YACS.menu.UpdateAddonState()
	elseif param == "off" then
		YACS.SetEnabled(false)
		YACS.menu.UpdateAddonState()
	elseif param == "menu" then
		YACS.menu.OpenMenu()
	else
		d(YACS.config.constants.CMD_TEXT_ON_OFF)
		d(YACS.config.constants.CMD_TEXT_MENU)
	end
end