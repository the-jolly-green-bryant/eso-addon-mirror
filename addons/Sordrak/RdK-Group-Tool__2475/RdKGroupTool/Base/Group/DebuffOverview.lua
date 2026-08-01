-- RdK Group Tool Debuff Overview
-- By @s0rdrak (PC / EU)

RdKGTool.group = RdKGTool.group or {}
RdKGTool.group.dbo = RdKGTool.group.dbo or {}
local RdKGToolDbo = RdKGTool.group.dbo
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.fonts = RdKGToolUtil.fonts or {}
local RdKGToolFonts = RdKGToolUtil.fonts
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolGroup = RdKGToolUtil.group

RdKGToolDbo.constants = RdKGToolDbo.constants or {}
RdKGToolDbo.constants.TLW_NAME = "RdKGTool.group.dbo.TLW"

RdKGToolDbo.constants.size = {}
RdKGToolDbo.constants.size.SMALL = 1
RdKGToolDbo.constants.size.BIG = 2

RdKGToolDbo.callbackName = RdKGTool.addonName .. "DebuffOverview"

RdKGToolDbo.config = {}
RdKGToolDbo.config.updateInterval = 100
RdKGToolDbo.config.isClampedToScreen = true
RdKGToolDbo.config.sizes = {}
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL] = {}
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].spacingHeight = 3
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].spacingWidth = 10
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].textWidth = 85
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].debuffWidth = 20
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].width = RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].textWidth + RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].debuffWidth
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].windowWidth = 2 * RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].width + RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].spacingWidth
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].height = 10
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].windowHeight = 12 * RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].height + 11 * RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].spacingHeight
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].fontSize = 12
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG] = {}
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].spacingHeight = 6
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].spacingWidth = 20
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].textWidth = 170
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].debuffWidth = 40
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].width = RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].textWidth + RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].debuffWidth
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].windowWidth = 2 * RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].width + RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].spacingWidth
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].height = 20
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].windowHeight = 12 * RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].height + 11 * RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].spacingHeight
RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].fontSize = 24

RdKGToolDbo.state = {}
RdKGToolDbo.state.initialized = false
RdKGToolDbo.state.foreground = true
RdKGToolDbo.state.registredConsumers = false
RdKGToolDbo.state.registredActiveConsumers = false
RdKGToolDbo.state.activeLayerIndex = 1
RdKGToolDbo.state.colors = {}



RdKGToolDbo.controls = {}

local wm = WINDOW_MANAGER

function RdKGToolDbo.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolDbo.callbackName, RdKGToolDbo.OnProfileChanged)
	
	RdKGToolDbo.CreateUI()
	
	RdKGToolMenu.AddPositionFixedConsumer(RdKGToolDbo.SetDboPositionLocked)
	
	RdKGToolDbo.state.initialized = true
	RdKGToolDbo.SetEnabled(RdKGToolDbo.dboVars.enabled)
	RdKGToolDbo.CalculateColors()
	RdKGToolDbo.SetMovable(not RdKGToolDbo.dboVars.positionLocked)
	RdKGToolDbo.AdjustSize()
	
end

function RdKGToolDbo.CreatePlayerDebuffControl(parent, offsetHeight, offsetWidth, height, labelWidth, countWidth, font)
	local playerDebuffControl = wm:CreateControl(nil, parent, CT_CONTROL)
	playerDebuffControl:SetAnchor(TOPLEFT, parent, TOPLEFT, offsetWidth, offsetHeight)
	playerDebuffControl:SetDimensions(labelWidth + countWidth, height)
	playerDebuffControl:SetHidden(true)
	
	playerDebuffControl.playerLabel = wm:CreateControl(nil, playerDebuffControl, CT_LABEL)
	playerDebuffControl.playerLabel:SetDimensions(labelWidth, height)
	playerDebuffControl.playerLabel:SetAnchor(TOPLEFT, playerDebuffControl, TOPLEFT, 0, 0)
	playerDebuffControl.playerLabel:SetFont(font)
	playerDebuffControl.playerLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT) 
	playerDebuffControl.playerLabel:SetText("")
	
	
	playerDebuffControl.debuffLabel = wm:CreateControl(nil, playerDebuffControl, CT_LABEL)
	playerDebuffControl.debuffLabel:SetDimensions(countWidth, height)
	playerDebuffControl.debuffLabel:SetAnchor(TOPLEFT, playerDebuffControl, TOPLEFT, labelWidth, 0)
	playerDebuffControl.debuffLabel:SetFont(font)
	playerDebuffControl.debuffLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER) 
	playerDebuffControl.debuffLabel:SetText("")
	
	return playerDebuffControl
end

function RdKGToolDbo.SetTlwLocation()
	RdKGToolDbo.controls.TLW:ClearAnchors()
	if RdKGToolDbo.dboVars.debuffLocation == nil then
		RdKGToolDbo.controls.TLW:SetAnchor(CENTER, GuiRoot, CENTER, 250, 0)
	else
		RdKGToolDbo.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolDbo.dboVars.debuffLocation.x, RdKGToolDbo.dboVars.debuffLocation.y)
	end
end

function RdKGToolDbo.CreateUI()
	local height = 12 * RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].height + 11 * RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].spacingHeight
	local width = (2 * RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].textWidth) + (2 * RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].debuffWidth) + RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].spacingWidth
	local font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	RdKGToolDbo.controls.TLW = wm:CreateTopLevelWindow(RdKGToolDbo.constants.TLW_NAME)
	
	RdKGToolDbo.SetTlwLocation()

		
	RdKGToolDbo.controls.TLW:SetClampedToScreen(RdKGToolDbo.config.isClampedToScreen)
	RdKGToolDbo.controls.TLW:SetDrawLayer(0)
	RdKGToolDbo.controls.TLW:SetDrawLevel(0)
	RdKGToolDbo.controls.TLW:SetHandler("OnMoveStop", RdKGToolDbo.SaveWindowLocation)
	RdKGToolDbo.controls.TLW:SetDimensions(width, height)
	RdKGToolDbo.controls.TLW:SetHidden(not RdKGToolDbo.dboVars.enabled)
	
	RdKGToolDbo.controls.tlwControl = wm:CreateControl(nil, RdKGToolDbo.controls.TLW, CT_CONTROL)
	RdKGToolDbo.controls.tlwControl:SetDimensions(width, height)
	RdKGToolDbo.controls.tlwControl:SetAnchor(TOPLEFT, RdKGToolDbo.controls.TLW, TOPLEFT, 0, 0)
	
	RdKGToolDbo.controls.tlwControl.movableBackdrop = wm:CreateControl(nil, RdKGToolDbo.controls.tlwControl, CT_BACKDROP)
	
	RdKGToolDbo.controls.tlwControl.movableBackdrop:SetAnchor(TOPLEFT, RdKGToolDbo.controls.tlwControl, TOPLEFT, 0, 0)
	RdKGToolDbo.controls.tlwControl.movableBackdrop:SetDimensions(width, height)
	
	RdKGToolDbo.controls.tlwControl.playerDebuffControls = {}
	
	for i = 1, 24 do
		local offset = 0
		if i > 12 then
			offset = RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].textWidth + RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].debuffWidth + RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].spacingWidth
		end
		local itemIndex = i - 1
		if itemIndex > 11 then
			itemIndex = itemIndex - 12
		end
		RdKGToolDbo.controls.tlwControl.playerDebuffControls[i] = RdKGToolDbo.CreatePlayerDebuffControl(RdKGToolDbo.controls.tlwControl, itemIndex * (RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].height + RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].spacingHeight), offset, RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].height, RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].textWidth, RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].debuffWidth, font)
	end
end

function RdKGToolDbo.GetDefaults()
	local defaults = {}
	defaults.enabled = false
	defaults.pvponly = true
	defaults.criticalAmount = 3
	defaults.colors = {}
	defaults.colors.okay = {}
	defaults.colors.okay.r = 0
	defaults.colors.okay.g = 1
	defaults.colors.okay.b = 0
	defaults.colors.critical = {}
	defaults.colors.critical.r = 1
	defaults.colors.critical.g = 0
	defaults.colors.critical.b = 0
	defaults.colors.notOkay = {}
	defaults.colors.notOkay.r = 1
	defaults.colors.notOkay.g = 1
	defaults.colors.notOkay.b = 0
	defaults.colors.outOfRange = {}
	defaults.colors.outOfRange.r = 1
	defaults.colors.outOfRange.g = 1
	defaults.colors.outOfRange.b = 1
	defaults.positionLocked = true
	defaults.size = RdKGToolDbo.constants.size.SMALL
	return defaults
end

function RdKGToolDbo.SetEnabled(value)
	if RdKGToolDbo.state.initialized == true and value ~= nil then
		RdKGToolDbo.dboVars.enabled = value
		if value == true then
			if RdKGToolDbo.state.registredConsumers == false then
				
				EVENT_MANAGER:RegisterForEvent(RdKGToolDbo.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolDbo.OnPlayerActivated)
				
			end
			RdKGToolDbo.state.registredConsumers = true
		else
			if RdKGToolDbo.state.registredConsumers == true then
				
				EVENT_MANAGER:UnregisterForEvent(RdKGToolDbo.callbackName, EVENT_PLAYER_ACTIVATED)
				
			end
			RdKGToolDbo.state.registredConsumers = false
		end
		RdKGToolDbo.OnPlayerActivated()
	end
end

function RdKGToolDbo.SetControlVisibility()
	local enabled = RdKGToolDbo.dboVars.enabled
	local pvpOnly = RdKGToolDbo.dboVars.pvponly
	local setHidden = true
	if enabled ~= nil and pvpOnly ~= nil then

		if enabled == true and (pvpOnly == false or (pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
			setHidden = false
		end
	end
	if setHidden == false then
		if RdKGToolDbo.state.foreground == false then
			RdKGToolDbo.controls.TLW:SetHidden(RdKGToolDbo.state.activeLayerIndex > 2)
		else
			RdKGToolDbo.controls.TLW:SetHidden(false)
		end
	else
		RdKGToolDbo.controls.TLW:SetHidden(setHidden)
	end
end

function RdKGToolDbo.GetColorTone(r1, r2, distance)
	local d = RdKGToolDbo.dboVars.criticalAmount - 1
	local color = r1
	
	local delta = r2 - r1
	
	if delta > 0 then
		color = r1 + delta * (distance / d)
	elseif delta < 0 then
		color = r2 - delta * (d - (distance)) / d
	end
	return color
end

function RdKGToolDbo.SetBackdropColors()
	if RdKGToolDbo.dboVars.positionLocked == false then
		RdKGToolDbo.controls.tlwControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolDbo.controls.tlwControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	else
		RdKGToolDbo.controls.tlwControl.movableBackdrop:SetCenterColor(0, 0, 0, 0.0)
		RdKGToolDbo.controls.tlwControl.movableBackdrop:SetEdgeColor(0, 0, 0, 0.0)	
	end
end

function RdKGToolDbo.SetMovable(isMovable)
	RdKGToolDbo.dboVars.positionLocked = not isMovable
	RdKGToolDbo.controls.TLW:SetMovable(isMovable)
	RdKGToolDbo.controls.TLW:SetMouseEnabled(isMovable)
	RdKGToolDbo.SetBackdropColors()
end

function RdKGToolDbo.CalculateColors()
	--r1 = okay, r2 = ciritical
	RdKGToolDbo.state.colors[1] = {}
	RdKGToolDbo.state.colors[1].r = RdKGToolDbo.dboVars.colors.okay.r
	RdKGToolDbo.state.colors[1].g = RdKGToolDbo.dboVars.colors.okay.g
	RdKGToolDbo.state.colors[1].b = RdKGToolDbo.dboVars.colors.okay.b
	for i = 2, 11 do
		RdKGToolDbo.state.colors[i] = {}
		RdKGToolDbo.state.colors[i].r = RdKGToolDbo.GetColorTone(RdKGToolDbo.dboVars.colors.notOkay.r, RdKGToolDbo.dboVars.colors.critical.r, i - 2)
		RdKGToolDbo.state.colors[i].g = RdKGToolDbo.GetColorTone(RdKGToolDbo.dboVars.colors.notOkay.g, RdKGToolDbo.dboVars.colors.critical.g, i - 2)
		RdKGToolDbo.state.colors[i].b = RdKGToolDbo.GetColorTone(RdKGToolDbo.dboVars.colors.notOkay.b, RdKGToolDbo.dboVars.colors.critical.b, i - 2)
	end
end

function RdKGToolDbo.GetPlayerDebuffs()
	local debuffs = 0
	local players = RdKGToolGroup.GetGroupInformation()
	if players ~= nil then
		for i = 1, #players do
			if players[i].isPlayer == true then
				local buffs = players[i].buffs
				if buffs ~= nil and buffs.numPurgableBuffs ~= nil then
					debuffs = buffs.numPurgableBuffs
					--d("Player Debuffs")
					--d(debuffs)
				end
				break
			end
		end
	end
	return debuffs
end

function RdKGToolDbo.AdjustSize()
	local sizeIncrease = RdKGToolDbo.dboVars.size - RdKGToolDbo.constants.size.SMALL
	local spacingHeight = (RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].spacingHeight + (RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].spacingHeight - RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].spacingHeight) * sizeIncrease)
	local spacingWidth = (RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].spacingWidth + (RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].spacingWidth - RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].spacingWidth) * sizeIncrease)
	local textWidth = (RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].textWidth + (RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].textWidth - RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].textWidth) * sizeIncrease)
	local debuffWidth = (RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].debuffWidth + (RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].debuffWidth - RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].debuffWidth) * sizeIncrease)
	local width = textWidth + debuffWidth
	local windowWidth = 2 * width + spacingWidth
	local height = (RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].height + (RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].height - RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].height) * sizeIncrease)
	local windowHeight = 12 * height + 11 * spacingHeight
	local fontSize = (RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].fontSize + (RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.BIG].fontSize - RdKGToolDbo.config.sizes[RdKGToolDbo.constants.size.SMALL].fontSize) * sizeIncrease)
	local font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)

	
	RdKGToolDbo.controls.TLW:SetDimensions(windowWidth, windowHeight)
	RdKGToolDbo.controls.tlwControl:SetDimensions(windowWidth, windowHeight)
	RdKGToolDbo.controls.tlwControl.movableBackdrop:SetDimensions(windowWidth, windowHeight)
	
	
	local playerDebuffControls = RdKGToolDbo.controls.tlwControl.playerDebuffControls
	
	for i = 1, #playerDebuffControls do
		local offset = 0
		if i > 12 then
			offset = textWidth + debuffWidth + spacingWidth
		end
		local itemIndex = i - 1
		if itemIndex > 11 then
			itemIndex = itemIndex - 12
		end
		
		playerDebuffControls[i]:ClearAnchors()
		playerDebuffControls[i]:SetAnchor(TOPLEFT, RdKGToolDbo.controls.tlwControl, TOPLEFT, offset, itemIndex * (height + spacingHeight))
		playerDebuffControls[i]:SetDimensions(textWidth + debuffWidth, height)
		
		
		playerDebuffControls[i].playerLabel:SetDimensions(textWidth, height)
		playerDebuffControls[i].playerLabel:SetFont(font)
		
		
		playerDebuffControls[i].debuffLabel:SetDimensions(debuffWidth, height)
		playerDebuffControls[i].debuffLabel:ClearAnchors()
		playerDebuffControls[i].debuffLabel:SetAnchor(TOPLEFT, playerDebuffControls[i], TOPLEFT, textWidth, 0)
		playerDebuffControls[i].debuffLabel:SetFont(font)
		
	end
end

--callbacks
function RdKGToolDbo.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		--RdKGToolDbo.SetEnabled(false)
		RdKGToolDbo.dboVars = currentProfile.group.dbo
		if RdKGToolDbo.state.initialized == true then
			RdKGToolDbo.CalculateColors()
			RdKGToolDbo.SetMovable(not RdKGToolDbo.dboVars.positionLocked)
			RdKGToolDbo.SetTlwLocation()
			RdKGToolDbo.AdjustSize()
			--RdKGToolDbo.OnPlayerActivated()
		end
		RdKGToolDbo.SetEnabled(RdKGToolDbo.dboVars.enabled)
		
	end
end

function RdKGToolDbo.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolDbo.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolDbo.state.foreground = false
	end
	--hack?
	RdKGToolDbo.state.activeLayerIndex = activeLayerIndex
	
	RdKGToolDbo.SetControlVisibility()
end

function RdKGToolDbo.OnPlayerActivated(eventCode, initial)
	if RdKGToolDbo.dboVars.enabled == true and (RdKGToolDbo.dboVars.pvponly == true and RdKGToolUtil.IsInPvPArea() == true or RdKGToolDbo.dboVars.pvponly == false) then
		if RdKGToolDbo.state.registredActiveConsumers == false then
			EVENT_MANAGER:RegisterForEvent(RdKGToolDbo.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolDbo.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForEvent(RdKGToolDbo.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolDbo.SetForegroundVisibility)
			RdKGToolGroup.AddFeature(RdKGToolDbo.callbackName, RdKGToolGroup.features.FEATURE_GROUP_BUFFS, RdKGToolDbo.config.updateInterval)
			RdKGToolGroup.AddFeature(RdKGToolDbo.callbackName, RdKGToolGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE, RdKGToolDbo.config.updateInterval)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolDbo.callbackName, RdKGToolDbo.config.updateInterval, RdKGToolDbo.OnUpdate)
			RdKGToolDbo.state.registredActiveConsumers = true
		end
	else
		if RdKGToolDbo.state.registredActiveConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(RdKGToolDbo.callbackName, EVENT_ACTION_LAYER_POPPED)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolDbo.callbackName, EVENT_ACTION_LAYER_PUSHED)
			RdKGToolGroup.RemoveFeature(RdKGToolDbo.callbackName, RdKGToolGroup.features.FEATURE_GROUP_BUFFS)
			RdKGToolGroup.RemoveFeature(RdKGToolDbo.callbackName, RdKGToolGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE)
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolDbo.callbackName)
			RdKGToolDbo.state.registredActiveConsumers = false
		end
	end
	RdKGToolDbo.SetControlVisibility()
end

function RdKGToolDbo.OnUpdate()
	--d("DBO onUpdate")
	if RdKGToolDbo.dboVars.enabled then
		local pvpZone = RdKGToolUtil.IsInPvPArea()
		if RdKGToolDbo.dboVars.pvponly == true and pvpZone == true or RdKGToolDbo.dboVars.pvponly == false then
			local players = RdKGToolGroup.GetGroupInformation()
			--temp = players
			if players ~= nil then

				for i = 1, #players do
					local buffs = players[i].buffs
					if buffs ~= nil and buffs.numPurgableBuffs ~= nil then
						local colorIndex = buffs.numPurgableBuffs
						colorIndex = colorIndex + 1
						if colorIndex < 1 then
							colorIndex = 1
						elseif colorIndex > 11 then
							colorIndex = 11
						end
						local distance =  players[i].distances.fromPlayer
						if distance == nil then
							distance = 0
						end
						if distance > 18 then
							RdKGToolDbo.controls.tlwControl.playerDebuffControls[i].playerLabel:SetColor(RdKGToolDbo.dboVars.colors.outOfRange.r, RdKGToolDbo.dboVars.colors.outOfRange.g, RdKGToolDbo.dboVars.colors.outOfRange.b)
							RdKGToolDbo.controls.tlwControl.playerDebuffControls[i].debuffLabel:SetColor(RdKGToolDbo.dboVars.colors.outOfRange.r, RdKGToolDbo.dboVars.colors.outOfRange.g, RdKGToolDbo.dboVars.colors.outOfRange.b)
						else
							RdKGToolDbo.controls.tlwControl.playerDebuffControls[i].playerLabel:SetColor(RdKGToolDbo.state.colors[colorIndex].r, RdKGToolDbo.state.colors[colorIndex].g, RdKGToolDbo.state.colors[colorIndex].b)
							RdKGToolDbo.controls.tlwControl.playerDebuffControls[i].debuffLabel:SetColor(RdKGToolDbo.state.colors[colorIndex].r, RdKGToolDbo.state.colors[colorIndex].g, RdKGToolDbo.state.colors[colorIndex].b)
						end
						if players[i].isPlayer == true then
							RdKGToolDbo.controls.tlwControl.playerDebuffControls[i].debuffLabel:SetText(players[i].buffs.numPurgableBuffs)
							--d("DBO")
							--d(players[i].buffs.numPurgableBuffs)
						else
							--d("DBO")
							--d(players[i].buffs.numPurgableBuffs)
							if players[i].buffs.numPurgableBuffs > 6 then
								RdKGToolDbo.controls.tlwControl.playerDebuffControls[i].debuffLabel:SetText("6+")
							else
								RdKGToolDbo.controls.tlwControl.playerDebuffControls[i].debuffLabel:SetText(players[i].buffs.numPurgableBuffs)
							end
						end
						RdKGToolDbo.controls.tlwControl.playerDebuffControls[i].playerLabel:SetText(players[i].name)
						RdKGToolDbo.controls.tlwControl.playerDebuffControls[i]:SetHidden(false)
					end
				end
				for i = #players + 1, 24 do
					RdKGToolDbo.controls.tlwControl.playerDebuffControls[i]:SetHidden(true)
					RdKGToolDbo.controls.tlwControl.playerDebuffControls[i].playerLabel:SetText("")
					RdKGToolDbo.controls.tlwControl.playerDebuffControls[i].debuffLabel:SetText("")
				end
				
				--if RdKGToolDbo.state.foreground == true then
				--	RdKGToolDbo.controls.TLW:SetHidden(false)
				--end
			end
		else
			--RdKGToolDbo.controls.TLW:SetHidden(true)
		end
	else
		--RdKGToolDbo.controls.TLW:SetHidden(true)
	end
end

function RdKGToolDbo.SaveWindowLocation()
	if RdKGToolDbo.dboVars.positionLocked == false then
		RdKGToolDbo.dboVars.debuffLocation = RdKGToolDbo.dboVars.debuffLocation or {}
		RdKGToolDbo.dboVars.debuffLocation.x = RdKGToolDbo.controls.TLW:GetLeft()
		RdKGToolDbo.dboVars.debuffLocation.y = RdKGToolDbo.controls.TLW:GetTop()
	end
end

--menu interaction
function RdKGToolDbo.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.DBO_HEADER,
			controls = {
				[1] = {
					type = "description",
					text = RdKGToolMenu.constants.DBO_DESCRIPTION
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.DBO_ENABLED,
					getFunc = RdKGToolDbo.GetDboEnabled,
					setFunc = RdKGToolDbo.SetDboEnabled
				},				
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.DBO_PVP_ONLY,
					getFunc = RdKGToolDbo.GetDboPvpOnly,
					setFunc = RdKGToolDbo.SetDboPvpOnly,
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.DBO_POSITION_FIXED,
					getFunc = RdKGToolDbo.GetDboPositionLocked,
					setFunc = RdKGToolDbo.SetDboPositionLocked,
				},
				[5] = {
					type = "slider",
					name = RdKGToolMenu.constants.DBO_CRITICAL_AMOUNT,
					min = 1,
					max = 10,
					step = 1,
					getFunc = RdKGToolDbo.GetDboCriticalAmount,
					setFunc = RdKGToolDbo.SetDboCriticalAmount,
					width = "full",
					default = 3
				},
				[6] = {
					type = "slider",
					name = RdKGToolMenu.constants.DBO_SIZE,
					min = 1.0,
					max = 2.0,
					step = 0.01,
					getFunc = RdKGToolDbo.GetDboSize,
					setFunc = RdKGToolDbo.SetDboSelectedSize,
					width = "full",
					decimals = 2,
					default = 1.0
				},
				[7] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.DBO_COLOR_OKAY,
					getFunc = RdKGToolDbo.GetDboColorOkay,
					setFunc = RdKGToolDbo.SetDboColorOkay,
					width = "full"
				},
				[8] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.DBO_COLOR_NOT_OKAY,
					getFunc = RdKGToolDbo.GetDboColorNotOkay,
					setFunc = RdKGToolDbo.SetDboColorNotOkay,
					width = "full"
				},
				[9] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.DBO_COLOR_CRITICAL,
					getFunc = RdKGToolDbo.GetDboColorCritical,
					setFunc = RdKGToolDbo.SetDboColorCritical,
					width = "full"
				},
				[10] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.DBO_COLOR_OUT_OF_RANGE,
					getFunc = RdKGToolDbo.GetDboColorOutOfRange,
					setFunc = RdKGToolDbo.SetDboColorOutOfRange,
					width = "full"
				}
			}
		}
	}
	return menu
end

function RdKGToolDbo.GetDboEnabled()
	return RdKGToolDbo.dboVars.enabled
end

function RdKGToolDbo.SetDboEnabled(value)
	RdKGToolDbo.SetEnabled(value)
end

function RdKGToolDbo.GetDboPvpOnly()
	return RdKGToolDbo.dboVars.pvponly
end

function RdKGToolDbo.SetDboPvpOnly(value)
	RdKGToolDbo.dboVars.pvponly = value
	RdKGToolDbo.SetEnabled(RdKGToolDbo.dboVars.enabled)
end

function RdKGToolDbo.GetDboPositionLocked()
	return RdKGToolDbo.dboVars.positionLocked
end

function RdKGToolDbo.SetDboPositionLocked(value)
	RdKGToolDbo.SetMovable(not value)
end

function RdKGToolDbo.GetDboCriticalAmount()
	return RdKGToolDbo.dboVars.criticalAmount
end

function RdKGToolDbo.SetDboCriticalAmount(value)
	RdKGToolDbo.dboVars.criticalAmount = value
	RdKGToolDbo.CalculateColors()
end

function RdKGToolDbo.GetDboSize()
	return RdKGToolDbo.dboVars.size
end

function RdKGToolDbo.SetDboSelectedSize(value)
	RdKGToolDbo.dboVars.size = value
	RdKGToolDbo.AdjustSize()
end

function RdKGToolDbo.GetDboColorOkay()
	return RdKGToolMenu.GetRGBColor(RdKGToolDbo.dboVars.colors.okay)
end

function RdKGToolDbo.SetDboColorOkay(r, g, b)
	RdKGToolDbo.dboVars.colors.okay = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolDbo.CalculateColors()
end

function RdKGToolDbo.GetDboColorNotOkay()
	return RdKGToolMenu.GetRGBColor(RdKGToolDbo.dboVars.colors.notOkay)
end

function RdKGToolDbo.SetDboColorNotOkay(r, g, b)
	RdKGToolDbo.dboVars.colors.notOkay = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolDbo.CalculateColors()
end

function RdKGToolDbo.GetDboColorCritical()
	return RdKGToolMenu.GetRGBColor(RdKGToolDbo.dboVars.colors.critical)
end

function RdKGToolDbo.SetDboColorCritical(r, g, b)
	RdKGToolDbo.dboVars.colors.critical = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolDbo.CalculateColors()
end

function RdKGToolDbo.GetDboColorOutOfRange()
	return RdKGToolMenu.GetRGBColor(RdKGToolDbo.dboVars.colors.outOfRange)
end

function RdKGToolDbo.SetDboColorOutOfRange(r, g, b)
	RdKGToolDbo.dboVars.colors.outOfRange = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolDbo.CalculateColors()
end