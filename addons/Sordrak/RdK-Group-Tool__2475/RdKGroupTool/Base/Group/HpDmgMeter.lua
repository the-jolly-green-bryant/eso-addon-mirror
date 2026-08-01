-- RdK Group Tool Hp Damage Meter
-- By @s0rdrak (PC / EU)

RdKGTool.group = RdKGTool.group or {}
local RdKGToolGroup = RdKGTool.group
RdKGToolGroup.hdm = RdKGToolGroup.hdm or {}
local RdKGToolHdm = RdKGToolGroup.hdm
RdKGToolGroup.dbo = RdKGToolGroup.dbo or {}
local RdKGToolDbo = RdKGToolGroup.dbo
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.networking = RdKGToolUtil.networking or {}
local RdKGToolNetworking = RdKGToolUtil.networking
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolUtilGroup = RdKGToolUtil.group
RdKGToolUtil.fonts = RdKGToolUtil.fonts or {}
local RdKGToolFonts = RdKGToolUtil.fonts
RdKGToolUtil.math = RdKGToolUtil.math or {}
local RdKGToolMath = RdKGToolUtil.math
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem


RdKGToolHdm.constants = RdKGToolHdm.constants or {}
RdKGToolHdm.constants.TLW_HPDMG_METER_NAME = "RdKGTool.group.hdm.hdm_TLW"
RdKGToolHdm.constants.LABEL_VALUE_FORMAT = "%d (%.2f%%)"
RdKGToolHdm.constants.LABEL_VALUE_FORMAT_2 = "%d (0%.2f%%)"

RdKGToolHdm.constants.viewModes = {}
RdKGToolHdm.constants.VIEWMODE_BOTH = 1
RdKGToolHdm.constants.VIEWMODE_HEALING = 2
RdKGToolHdm.constants.VIEWMODE_DAMAGE = 3
RdKGToolHdm.constants.VIEWMODE_BOTH_ON_TOP = 4

RdKGToolHdm.constants.size = {}
RdKGToolHdm.constants.size.SMALL = 1
RdKGToolHdm.constants.size.BIG = 2

RdKGToolHdm.PREFIX = "HDM"

RdKGToolHdm.callbackName = RdKGTool.addonName .. "HpDmgMeter"
RdKGToolHdm.hpCallbackName = RdKGTool.addonName .. "HpDmgMeterHpSendLoop"
RdKGToolHdm.dmgCallbackName = RdKGTool.addonName .. "HpDmgMeterDmgSendLoop"
RdKGToolHdm.uiCallbackName = RdKGTool.addonName .. "HpDmgMeterUILoop"
RdKGToolHdm.updateCallbackName = RdKGTool.addonName .. "HpDmgMeterMessageUpdateLoop"

RdKGToolHdm.controls = {}

RdKGToolHdm.config = {}
RdKGToolHdm.config.isClampedToScreen = true
RdKGToolHdm.config.sizes = {}
RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL] = {}
RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].width = 500
RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].height = 450
RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].spacing = 30
RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].fontSize = 15
RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.BIG] = {}
RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.BIG].width = 750
RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.BIG].height = 720
RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.BIG].spacing = 60
RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.BIG].fontSize = 24
RdKGToolHdm.config.invalidUpdateInterval = 100 --This value shouldn't be used by Group.lua. Yet in case of a bug or later changes, this value is defined
RdKGToolHdm.config.buffUpdateInterval = 100
--RdKGToolHdm.config.titleFont = "$(BOLD_FONT)|$(KB_20)soft-shadow-thick"
RdKGToolHdm.config.titleFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, 20, RdKGToolFonts.constants.WEIGHT_THICK_OUTLINE)
RdKGToolHdm.config.backgroundEven = 0.4
RdKGToolHdm.config.backgroundOdd = 0.2

RdKGToolHdm.state = {}
RdKGToolHdm.state.initialized = false
RdKGToolHdm.state.registredConsumers = false
RdKGToolHdm.state.registredGroupConsumer = false
RdKGToolHdm.state.foreground = true
RdKGToolHdm.state.registredActiveConsumers = false
RdKGToolHdm.state.activeLayerIndex = 1

RdKGToolHdm.state.meter = {}
RdKGToolHdm.state.meter.damage = 0
RdKGToolHdm.state.meter.healing = 0
RdKGToolHdm.state.meter.lastDamageMessage = nil
RdKGToolHdm.state.meter.lastHpMessage = nil

RdKGToolHdm.state.delayedLoopStarting = false
RdKGToolHdm.state.delayedLoopStarted = false
RdKGToolHdm.state.hpDmgUpdateInterval = 3000 --5000 previously
RdKGToolHdm.state.delayInterval = 1000
RdKGToolHdm.state.delayCount = 0

RdKGToolHdm.state.uiUpdateInterval = 500
RdKGToolHdm.state.messageUpdateInterval = 100

local wm = WINDOW_MANAGER

function RdKGToolHdm.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolHdm.callbackName, RdKGToolHdm.OnProfileChanged)
	ZO_CreateStringId("SI_BINDING_NAME_RDKGTOOL_HDM_RESET_METER", RdKGToolHdm.constants.RESET_COUNTER)
	
	RdKGToolHdm.CreateUI()
	
	RdKGToolMenu.AddPositionFixedConsumer(RdKGToolHdm.SetHdmPositionLocked)
	RdKGToolHdm.AdjustAutoClearEnabled()
	
	RdKGToolHdm.state.initialized = true
	RdKGToolHdm.SetEnabled(RdKGToolHdm.hdmVars.enabled)
end

function RdKGToolHdm.SetTlwLocation()
	RdKGToolHdm.controls.hdmTLW:ClearAnchors()
	if RdKGToolHdm.hdmVars.location == nil then
		RdKGToolHdm.controls.hdmTLW:SetAnchor(CENTER, GuiRoot, CENTER, 250, -150)
	else
		RdKGToolHdm.controls.hdmTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolHdm.hdmVars.location.x, RdKGToolHdm.hdmVars.location.y)
	end
end

function RdKGToolHdm.CreateUI()
	RdKGToolHdm.controls.hdmTLW = wm:CreateTopLevelWindow(RdKGToolHdm.constants.TLW_HPDMG_METER_NAME)
	
	RdKGToolHdm.SetTlwLocation()
		
	RdKGToolHdm.controls.hdmTLW:SetClampedToScreen(RdKGToolHdm.config.isClampedToScreen)
	RdKGToolHdm.controls.hdmTLW:SetDrawLayer(0)
	RdKGToolHdm.controls.hdmTLW:SetDrawLevel(0)
	RdKGToolHdm.controls.hdmTLW:SetHandler("OnMoveStop", RdKGToolHdm.SaveHdmWindowLocation)
	RdKGToolHdm.controls.hdmTLW:SetDimensions(RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].width + RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].spacing, RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].height)
	
	RdKGToolHdm.controls.hdmTLW.rootControl = wm:CreateControl(nil, RdKGToolHdm.controls.hdmTLW, CT_CONTROL)
	local rootControl = RdKGToolHdm.controls.hdmTLW.rootControl
	
	rootControl:SetDimensions(RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].width + RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].spacing, RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].height)
	rootControl:SetAnchor(TOPLEFT, RdKGToolHdm.controls.hdmTLW, TOPLEFT, 0, 0)
	
	rootControl.movableBackdrop = wm:CreateControl(nil, rootControl, CT_BACKDROP)
	
	rootControl.movableBackdrop:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	rootControl.movableBackdrop:SetDimensions(RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].width + RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].spacing, RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].height)
	
	rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	
	rootControl.damageControl = RdKGToolHdm.CreateUserControl(rootControl, RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].width / 2, RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].height, 0, RdKGToolHdm.constants.TITLE_DAMAGE)
	rootControl.healingControl = RdKGToolHdm.CreateUserControl(rootControl, RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].width / 2, RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].height, RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].width / 2 + RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].spacing, RdKGToolHdm.constants.TITLE_HEALING)
	
	RdKGToolHdm.SetPositionLocked(RdKGToolHdm.hdmVars.positionLocked)
	RdKGToolHdm.AdjustControlSize()
	RdKGToolHdm.SetControlVisibility()
end

function RdKGToolHdm.CreateUserControl(parent, controlWidth, controlHeight, widthOffset, text)
	local control = wm:CreateControl(nil, parent, CT_CONTROL)
	control:SetDimensions(controlWidth, controlHeight)
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, widthOffset, 0)
	local width = controlWidth
	local height = math.floor((controlHeight - 30) / 24)
	control.title = wm:CreateControl(nil, control, CT_LABEL)
	control.title:SetDimensions(width, 20)
	control.title:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.title:SetFont(RdKGToolHdm.config.titleFont)
	control.title:SetText(text)
	control.title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	control.title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	
	local playerFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	control.playerBlocks = {}
	for i = 1, 24 do
		control.playerBlocks[i] = {}
		control.playerBlocks[i].nameBackdrop = wm:CreateControl(nil, control, CT_BACKDROP)
		control.playerBlocks[i].nameBackdrop:SetDimensions(width / 2, height)
		control.playerBlocks[i].nameBackdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 30 + (i - 1) * height)
		control.playerBlocks[i].nameBackdrop:SetCenterColor(0, 0, 0, 0.0)
		control.playerBlocks[i].nameBackdrop:SetEdgeColor(0, 0, 0, 0.0)
		
		control.playerBlocks[i].name = wm:CreateControl(nil, control, CT_LABEL)
		control.playerBlocks[i].name:SetDimensions(width / 2, height)
		control.playerBlocks[i].name:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 30 + (i - 1) * height)
		control.playerBlocks[i].name:SetFont(playerFont)
		control.playerBlocks[i].name:SetText("")
		control.playerBlocks[i].name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		
		control.playerBlocks[i].valueBackdrop = wm:CreateControl(nil, control, CT_BACKDROP)
		control.playerBlocks[i].valueBackdrop:SetDimensions(width / 2, height)
		control.playerBlocks[i].valueBackdrop:SetAnchor(TOPLEFT, control, TOPLEFT, width / 2, 30 + (i - 1) * height)
		control.playerBlocks[i].valueBackdrop:SetCenterColor(0, 0, 0, 0.0)
		control.playerBlocks[i].valueBackdrop:SetEdgeColor(0, 0, 0, 0.0)
		
		control.playerBlocks[i].value = wm:CreateControl(nil, control, CT_LABEL)
		control.playerBlocks[i].value:SetDimensions(width / 2, height)
		control.playerBlocks[i].value:SetAnchor(TOPLEFT, control, TOPLEFT, width / 2, 30 + (i - 1) * height)
		control.playerBlocks[i].value:SetFont(playerFont)
		control.playerBlocks[i].value:SetText("")
		control.playerBlocks[i].value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		control.playerBlocks[i].value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	end
	return control
end

function RdKGToolHdm.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	defaults.positionLocked = true
	defaults.pvpOnly = true
	defaults.windowEnabled = false
	defaults.aliveColor = {}
	defaults.aliveColor.r = 1
	defaults.aliveColor.g = 1
	defaults.aliveColor.b = 1
	defaults.deadColor = {}
	defaults.deadColor.r = 1
	defaults.deadColor.g = 0
	defaults.deadColor.b = 0
	defaults.backgroundColor = {}
	defaults.backgroundColor.healer = {}
	defaults.backgroundColor.healer.r = 0.2
	defaults.backgroundColor.healer.g = 0.2
	defaults.backgroundColor.healer.b = 0.76
	defaults.backgroundColor.dd = {}
	defaults.backgroundColor.dd.r = 0.76
	defaults.backgroundColor.dd.g = 0.2
	defaults.backgroundColor.dd.b = 0.2
	defaults.backgroundColor.tank = {}
	defaults.backgroundColor.tank.r = 0.3
	defaults.backgroundColor.tank.g = 0.3
	defaults.backgroundColor.tank.b = 0.3
	defaults.backgroundColor.applicant = {}
	defaults.backgroundColor.applicant.r = 0.05
	defaults.backgroundColor.applicant.g = 0.1
	defaults.backgroundColor.applicant.b = 1.0
	defaults.viewMode = RdKGToolHdm.constants.VIEWMODE_BOTH
	defaults.size = RdKGToolHdm.constants.size.SMALL
	
	defaults.autoClear = true
	defaults.useAlpha = true
	defaults.useColors = true
	defaults.highlightApplicant = true
	
	return defaults
end

--[[
function RdKGToolHdm.SetEnabled(value)
	if RdKGToolHdm.state.initialized == true and value ~= nil then
		RdKGToolHdm.hdmVars.enabled = value
		if value == true then
			if RdKGToolHdm.state.registredConsumers == false then
				EVENT_MANAGER:RegisterForEvent(RdKGToolHdm.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolHdm.SetForegroundVisibility)
				EVENT_MANAGER:RegisterForEvent(RdKGToolHdm.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolHdm.SetForegroundVisibility)
				EVENT_MANAGER:RegisterForEvent(RdKGToolHdm.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolHdm.OnPlayerActivated)
				EVENT_MANAGER:RegisterForEvent(RdKGToolHdm.callbackName, EVENT_COMBAT_EVENT, RdKGToolHdm.OnCombatEvent)
				RdKGToolUtilGroup.AddFeature(RdKGToolHdm.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_HP_DMG, RdKGToolHdm.config.invalidUpdateInterval)
				RdKGToolUtilGroup.AddFeature(RdKGToolHdm.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS, RdKGToolHdm.config.buffUpdateInterval)
				--RdKGToolNetworking.AddRawMessageHandler(RdKGToolHdm.callbackName, RdKGToolHdm.HandleRawNetworkMessage)
				EVENT_MANAGER:RegisterForUpdate(RdKGToolHdm.hpCallbackName, RdKGToolHdm.state.hpDmgUpdateInterval, RdKGToolHdm.HpUpdateLoop)
				EVENT_MANAGER:RegisterForUpdate(RdKGToolHdm.uiCallbackName, RdKGToolHdm.state.uiUpdateInterval, RdKGToolHdm.UiLoop)
				EVENT_MANAGER:RegisterForUpdate(RdKGToolHdm.updateCallbackName, RdKGToolHdm.state.messageUpdateInterval, RdKGToolHdm.MessageUpdateLoop)
			end
			if RdKGToolHdm.state.delayedLoopStarted == false and RdKGToolHdm.state.delayedLoopStarting == false then
				RdKGToolHdm.state.delayedLoopStarting = true
				EVENT_MANAGER:RegisterForUpdate(RdKGToolHdm.callbackName, RdKGToolHdm.state.delayInterval, RdKGToolHdm.StartDmgLoop)
			end
			RdKGToolHdm.state.registredConsumers = true
		else
			if RdKGToolHdm.state.registredConsumers == true then
				EVENT_MANAGER:UnregisterForEvent(RdKGToolHdm.callbackName, EVENT_ACTION_LAYER_POPPED)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolHdm.callbackName, EVENT_ACTION_LAYER_PUSHED)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolHdm.callbackName, EVENT_PLAYER_ACTIVATED)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolHdm.callbackName, EVENT_COMBAT_EVENT)
				RdKGToolUtilGroup.RemoveFeature(RdKGToolHdm.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_HP_DMG)
				RdKGToolUtilGroup.RemoveFeature(RdKGToolHdm.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS)
				--RdKGToolNetworking.RemoveRawMessageHandler(RdKGToolHdm.callbackName)
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolHdm.hpCallbackName)
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolHdm.uiCallbackName)
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolHdm.updateCallbackName)
			end
			if RdKGToolHdm.state.delayedLoopStarted == true then
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolHdm.dmgCallbackName)
			end
			if RdKGToolHdm.state.delayedLoopStarting == true then
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolHdm.callbackName)
				RdKGToolHdm.state.delayedLoopStarting = false
			end
			RdKGToolHdm.state.registredConsumers = false
		end
		RdKGToolHdm.SetControlVisibility()
	end
end
]]

function RdKGToolHdm.SetEnabled(value)
	if RdKGToolHdm.state.initialized == true and value ~= nil then
		RdKGToolHdm.hdmVars.enabled = value
		if value == true then
			if RdKGToolHdm.state.registredConsumers == false then
				
				EVENT_MANAGER:RegisterForEvent(RdKGToolHdm.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolHdm.OnPlayerActivated)
				
			end
			RdKGToolHdm.state.registredConsumers = true
		else
			if RdKGToolHdm.state.registredConsumers == true then
				
				EVENT_MANAGER:UnregisterForEvent(RdKGToolHdm.callbackName, EVENT_PLAYER_ACTIVATED)
				
			end
			RdKGToolHdm.state.registredConsumers = false
		end
		RdKGToolHdm.OnPlayerActivated()
	end
end

function RdKGToolHdm.SetPositionLocked(value)
	RdKGToolHdm.hdmVars.positionLocked = value
	RdKGToolHdm.controls.hdmTLW:SetMovable(not value)
	RdKGToolHdm.controls.hdmTLW:SetMouseEnabled(not value)
	if value == true then
		RdKGToolHdm.controls.hdmTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolHdm.controls.hdmTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	else
		RdKGToolHdm.controls.hdmTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolHdm.controls.hdmTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	end
end

function RdKGToolHdm.SetControlVisibility()
	local enabled = RdKGToolHdm.hdmVars.enabled
	local windowEnabled = RdKGToolHdm.hdmVars.windowEnabled
	local pvpOnly = RdKGToolHdm.hdmVars.pvpOnly
	local setHidden = true
	if enabled ~= nil and windowEnabled ~= nil and pvpOnly ~= nil then

		if enabled == true and (pvpOnly == false or (pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
			if windowEnabled == true then
				setHidden = false
			end
		end
	end
	if setHidden == false then
		if RdKGToolHdm.state.foreground == false then
			RdKGToolHdm.controls.hdmTLW:SetHidden(RdKGToolHdm.state.activeLayerIndex > 2)
		else
			RdKGToolHdm.controls.hdmTLW:SetHidden(false)
		end
	else
		RdKGToolHdm.controls.hdmTLW:SetHidden(setHidden)
	end
end

function RdKGToolHdm.CopyPlayersIncludingTotals(oldPlayers, stat)
	local players = {}
	local total = 0
	if players ~= nil then
		for i = 1, #oldPlayers do
			players[i] = oldPlayers[i]
			if oldPlayers[i].meter ~= nil and oldPlayers[i].meter[stat] ~= nil then
				total = total + oldPlayers[i].meter[stat]
			end
		end
	end
	return players, total
end

function RdKGToolHdm.ComparePlayers(playerA, playerB, stat)
	--d(playerA.meter)
	--d(playerB.meter)
	--d(stat)
	--d("----")
	if playerA.meter == nil or playerA.meter[stat] == nil or
	   playerB.meter == nil or playerB.meter[stat] == nil then
	
		if (playerA.meter == nil or playerA.meter[stat] == nil) and 
		   (playerB.meter ~= nil and playerB.meter[stat] ~= nil) then
			return false
		elseif (playerA.meter ~= nil and playerA.meter[stat] ~= nil) and 
		   (playerB.meter == nil or playerB.meter[stat] == nil) then
			return true
		else
			return playerA.charName < playerB.charName
		end
		
	end
	
	if playerA.meter[stat] < playerB.meter[stat] then
		return false
	elseif playerA.meter[stat] > playerB.meter[stat] then
		return true
	else
		return playerA.charName < playerB.charName
	end
end

function RdKGToolHdm.ComparePlayersByDamage(playerA, playerB)
	return RdKGToolHdm.ComparePlayers(playerA, playerB, "damage")
end

function RdKGToolHdm.ComparePlayersByHealing(playerA, playerB)
	return RdKGToolHdm.ComparePlayers(playerA, playerB, "healing")
end

function RdKGToolHdm.AdjustControlSize()
	RdKGToolHdm.AdjustViewMode()
	local sizeIncrease = RdKGToolHdm.hdmVars.size - RdKGToolHdm.constants.size.SMALL
	local width = (RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].width + (RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.BIG].width - RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].width) * sizeIncrease) / 2
	--local width = RdKGToolHdm.config.sizes[RdKGToolHdm.hdmVars.size].width / 2
	local height = math.floor(((RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].height + (RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.BIG].height - RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].height) * sizeIncrease) - 30) / 24)
	local playerFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, (RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].fontSize + (RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.BIG].fontSize - RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].fontSize) * sizeIncrease), RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	local rootControl = RdKGToolHdm.controls.hdmTLW.rootControl
	local controls = {rootControl.healingControl, rootControl.damageControl}
	for j = 1, #controls do
		local control = controls[j]
		control.title:SetDimensions(width, 20)
		for i = 1, 24 do
			control.playerBlocks[i].nameBackdrop:SetDimensions(width / 2, height)
			control.playerBlocks[i].nameBackdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 30 + (i - 1) * height)
			
			control.playerBlocks[i].name:SetDimensions(width / 2, height)
			control.playerBlocks[i].name:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 30 + (i - 1) * height)
			control.playerBlocks[i].name:SetFont(playerFont)

			control.playerBlocks[i].valueBackdrop:SetDimensions(width / 2, height)
			control.playerBlocks[i].valueBackdrop:SetAnchor(TOPLEFT, control, TOPLEFT, width / 2, 30 + (i - 1) * height)

			control.playerBlocks[i].value:SetDimensions(width / 2, height)
			control.playerBlocks[i].value:SetAnchor(TOPLEFT, control, TOPLEFT, width / 2, 30 + (i - 1) * height)
			control.playerBlocks[i].value:SetFont(playerFont)
		end
	end
end

function RdKGToolHdm.GetCurrentSingleControlHeight(players)
	local sizeIncrease = RdKGToolHdm.hdmVars.size - RdKGToolHdm.constants.size.SMALL
	local height = (RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].height + (RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.BIG].height - RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].height) * sizeIncrease)
	if players ~= nil then
		height = 30 + math.floor(((RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].height + (RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.BIG].height - RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].height) * sizeIncrease) - 30) / 24) * #players
	end
	return height
end

function RdKGToolHdm.AdjustViewMode()
	local rootControl = RdKGToolHdm.controls.hdmTLW.rootControl
	local sizeIncrease = RdKGToolHdm.hdmVars.size - RdKGToolHdm.constants.size.SMALL
	local width = (RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].width + (RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.BIG].width - RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].width) * sizeIncrease)
	local height = (RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].height + (RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.BIG].height - RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].height) * sizeIncrease)
	local spacing = (RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].spacing + (RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.BIG].spacing - RdKGToolHdm.config.sizes[RdKGToolHdm.constants.size.SMALL].spacing) * sizeIncrease)
	if RdKGToolHdm.hdmVars.viewMode == RdKGToolHdm.constants.VIEWMODE_BOTH then
		RdKGToolHdm.controls.hdmTLW:SetDimensions(width + spacing, height)
		rootControl:SetDimensions(width, height)
		rootControl.movableBackdrop:SetDimensions(width + spacing, height)
		rootControl.damageControl:ClearAnchors()
		rootControl.damageControl:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
		rootControl.damageControl:SetHidden(false)
		rootControl.healingControl:ClearAnchors()
		rootControl.healingControl:SetAnchor(TOPLEFT, rootControl, TOPLEFT, width / 2 + spacing, 0)
		rootControl.healingControl:SetHidden(false)
		if RdKGToolHdm.state.registredGroupConsumer == true then
			RdKGToolUtilGroup.RemoveGroupChangedCallback(RdKGToolHdm.callbackName)
			RdKGToolHdm.state.registredGroupConsumer = false
		end
	elseif RdKGToolHdm.hdmVars.viewMode == RdKGToolHdm.constants.VIEWMODE_BOTH_ON_TOP then
		local players = RdKGToolUtilGroup.GetGroupInformation()
		height = RdKGToolHdm.GetCurrentSingleControlHeight(players)
		RdKGToolHdm.controls.hdmTLW:SetDimensions(width / 2, height * 2 + spacing)
		rootControl:SetDimensions(width / 2, height * 2 + spacing)
		rootControl.movableBackdrop:SetDimensions(width / 2, height * 2 + spacing)
		rootControl.damageControl:ClearAnchors()
		rootControl.damageControl:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
		rootControl.damageControl:SetHidden(false)
		rootControl.healingControl:ClearAnchors()
		rootControl.healingControl:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, height + spacing)
		rootControl.healingControl:SetHidden(false)
		if RdKGToolHdm.state.registredGroupConsumer == false then
			RdKGToolUtilGroup.AddGroupChangedCallback(RdKGToolHdm.callbackName, RdKGToolHdm.AdjustViewMode)
			RdKGToolHdm.state.registredGroupConsumer = true
		end
	else
		RdKGToolHdm.controls.hdmTLW:SetDimensions(width / 2, height)
		rootControl:SetDimensions(width / 2, height)
		rootControl.movableBackdrop:SetDimensions(width / 2, height)
		rootControl.damageControl:SetHidden(true)
		rootControl.damageControl:ClearAnchors()
		rootControl.damageControl:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
		rootControl.healingControl:SetHidden(true)
		rootControl.healingControl:ClearAnchors()
		rootControl.healingControl:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
		if RdKGToolHdm.hdmVars.viewMode == RdKGToolHdm.constants.VIEWMODE_HEALING then
			rootControl.healingControl:SetHidden(false)
		elseif RdKGToolHdm.hdmVars.viewMode == RdKGToolHdm.constants.VIEWMODE_DAMAGE then
			rootControl.damageControl:SetHidden(false)
		end
		if RdKGToolHdm.state.registredGroupConsumer == true then
			RdKGToolUtilGroup.RemoveGroupChangedCallback(RdKGToolHdm.callbackName)
			RdKGToolHdm.state.registredGroupConsumer = false
		end
	end
end

function RdKGToolHdm.GetPlayerDebuffs()
	return RdKGToolDbo.GetPlayerDebuffs()
end

function RdKGToolHdm.AdjustAutoClearEnabled()
	RdKGToolUtilGroup.SetHdmAutoClearEnabled(RdKGToolHdm.hdmVars.autoClear)
end

function RdKGToolGroup.hdm.SlashCmd(param)
	--d(param)
	if #param == 2 then
		if param[2] == "clear" then
			RdKGToolHdm.OnKeyBinding()
			return
		end
	end
	RdKGToolChat.SendChatMessage(RdKGTool.config.constants.CMD_TEXT_MENU, RdKGToolHdm.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL)
end

function RdKGToolHdm.RegisterSpecificCombatEvent(name, sourceType, targetType, resultType, callback)
	EVENT_MANAGER:RegisterForEvent(name, EVENT_COMBAT_EVENT, callback)
	--[[
	if targetType ~= nil then
		EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, targetType)
	end
	EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, sourceType)
	EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, resultType)
	]]
	
	if targetType ~= nil then
		EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, targetType, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, sourceType, REGISTER_FILTER_COMBAT_RESULT, resultType)
	else
		EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, sourceType, REGISTER_FILTER_COMBAT_RESULT, resultType)
	end
	
end

function RdKGToolHdm.RegisterCombatEvents()
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "1"), COMBAT_UNIT_TYPE_PLAYER, nil, ACTION_RESULT_DAMAGE, RdKGToolHdm.OnCombatEventDamage)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "2"), COMBAT_UNIT_TYPE_PLAYER, nil, ACTION_RESULT_CRITICAL_DAMAGE, RdKGToolHdm.OnCombatEventDamage)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "3"), COMBAT_UNIT_TYPE_PLAYER, nil, ACTION_RESULT_DOT_TICK, RdKGToolHdm.OnCombatEventDamage)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "4"), COMBAT_UNIT_TYPE_PLAYER, nil, ACTION_RESULT_DOT_TICK_CRITICAL, RdKGToolHdm.OnCombatEventDamage)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "5"), COMBAT_UNIT_TYPE_PLAYER, nil, ACTION_RESULT_DAMAGE_SHIELDED, RdKGToolHdm.OnCombatEventDamage)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "6"), COMBAT_UNIT_TYPE_PLAYER, nil, ACTION_RESULT_BLOCKED_DAMAGE, RdKGToolHdm.OnCombatEventDamage)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "7"), COMBAT_UNIT_TYPE_PLAYER_PET, nil, ACTION_RESULT_DAMAGE, RdKGToolHdm.OnCombatEventDamage)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "8"), COMBAT_UNIT_TYPE_PLAYER_PET, nil, ACTION_RESULT_CRITICAL_DAMAGE, RdKGToolHdm.OnCombatEventDamage)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "9"), COMBAT_UNIT_TYPE_PLAYER_PET, nil, ACTION_RESULT_DOT_TICK, RdKGToolHdm.OnCombatEventDamage)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "10"), COMBAT_UNIT_TYPE_PLAYER_PET, nil, ACTION_RESULT_DOT_TICK_CRITICAL, RdKGToolHdm.OnCombatEventDamage)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "11"), COMBAT_UNIT_TYPE_PLAYER_PET, nil, ACTION_RESULT_DAMAGE_SHIELDED, RdKGToolHdm.OnCombatEventDamage)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "12"), COMBAT_UNIT_TYPE_PLAYER_PET, nil, ACTION_RESULT_BLOCKED_DAMAGE, RdKGToolHdm.OnCombatEventDamage)
	
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "13"), COMBAT_UNIT_TYPE_PLAYER, nil, ACTION_RESULT_HEAL, RdKGToolHdm.OnCombatEventHealing)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "14"), COMBAT_UNIT_TYPE_PLAYER, nil, ACTION_RESULT_CRITICAL_HEAL, RdKGToolHdm.OnCombatEventHealing)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "15"), COMBAT_UNIT_TYPE_PLAYER, nil, ACTION_RESULT_HOT_TICK, RdKGToolHdm.OnCombatEventHealing)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "16"), COMBAT_UNIT_TYPE_PLAYER, nil, ACTION_RESULT_HOT_TICK_CRITICAL, RdKGToolHdm.OnCombatEventHealing)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "17"), COMBAT_UNIT_TYPE_PLAYER, nil, ACTION_RESULT_HEAL_ABSORBED, RdKGToolHdm.OnCombatEventHealing)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "18"), COMBAT_UNIT_TYPE_PLAYER_PET, nil, ACTION_RESULT_HEAL, RdKGToolHdm.OnCombatEventHealing)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "19"), COMBAT_UNIT_TYPE_PLAYER_PET, nil, ACTION_RESULT_CRITICAL_HEAL, RdKGToolHdm.OnCombatEventHealing)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "20"), COMBAT_UNIT_TYPE_PLAYER_PET, nil, ACTION_RESULT_HOT_TICK, RdKGToolHdm.OnCombatEventHealing)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "21"), COMBAT_UNIT_TYPE_PLAYER_PET, nil, ACTION_RESULT_HOT_TICK_CRITICAL, RdKGToolHdm.OnCombatEventHealing)
	RdKGToolHdm.RegisterSpecificCombatEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "22"), COMBAT_UNIT_TYPE_PLAYER_PET, nil, ACTION_RESULT_HEAL_ABSORBED, RdKGToolHdm.OnCombatEventHealing)
end

function RdKGToolHdm.UnregisterCombatEvents()
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "1"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "2"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "3"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "4"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "5"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "6"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "7"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "8"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "9"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "10"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "11"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "12"), EVENT_COMBAT_EVENT)
	
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "13"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "14"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "15"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "16"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "17"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "18"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "19"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "20"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "21"), EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(string.format("%s.%s", RdKGToolHdm.callbackName, "22"), EVENT_COMBAT_EVENT)
end

--callbacks
function RdKGToolHdm.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolHdm.hdmVars = currentProfile.group.hdm
		if RdKGToolHdm.state.initialized == true then
			RdKGToolHdm.SetControlVisibility()
			RdKGToolHdm.SetPositionLocked(RdKGToolHdm.hdmVars.positionLocked)
			RdKGToolHdm.SetTlwLocation()
			RdKGToolHdm.AdjustControlSize()
			RdKGToolHdm.AdjustAutoClearEnabled()
		end
		RdKGToolHdm.SetEnabled(RdKGToolHdm.hdmVars.enabled)
		
	end
end

function RdKGToolHdm.SaveHdmWindowLocation()
	if RdKGToolHdm.hdmVars.positionLocked == false then
		RdKGToolHdm.hdmVars.location = RdKGToolHdm.hdmVars.location or {}
		RdKGToolHdm.hdmVars.location.x = RdKGToolHdm.controls.hdmTLW:GetLeft()
		RdKGToolHdm.hdmVars.location.y = RdKGToolHdm.controls.hdmTLW:GetTop()
	end
end

function RdKGToolHdm.OnPlayerActivated(eventCode, initial)
	if RdKGToolHdm.hdmVars.enabled == true and (RdKGToolHdm.hdmVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true or RdKGToolHdm.hdmVars.pvpOnly == false) then
		--d("register")
		if RdKGToolHdm.state.registredActiveConsumers == false then
			EVENT_MANAGER:RegisterForEvent(RdKGToolHdm.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolHdm.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForEvent(RdKGToolHdm.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolHdm.SetForegroundVisibility)
			
			RdKGToolHdm.RegisterCombatEvents()
			--EVENT_MANAGER:RegisterForEvent(RdKGToolHdm.callbackName, EVENT_COMBAT_EVENT, RdKGToolHdm.OnCombatEvent)
			RdKGToolUtilGroup.AddFeature(RdKGToolHdm.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_HP_DMG, RdKGToolHdm.config.invalidUpdateInterval)
			RdKGToolUtilGroup.AddFeature(RdKGToolHdm.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS, RdKGToolHdm.config.buffUpdateInterval)
			--RdKGToolNetworking.AddRawMessageHandler(RdKGToolHdm.callbackName, RdKGToolHdm.HandleRawNetworkMessage)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolHdm.hpCallbackName, RdKGToolHdm.state.hpDmgUpdateInterval, RdKGToolHdm.HpUpdateLoop)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolHdm.uiCallbackName, RdKGToolHdm.state.uiUpdateInterval, RdKGToolHdm.UiLoop)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolHdm.updateCallbackName, RdKGToolHdm.state.messageUpdateInterval, RdKGToolHdm.MessageUpdateLoop)
			
			RdKGToolHdm.state.registredActiveConsumers = true
		end
		if RdKGToolHdm.state.delayedLoopStarted == false and RdKGToolHdm.state.delayedLoopStarting == false then
			RdKGToolHdm.state.delayedLoopStarting = true
			EVENT_MANAGER:RegisterForUpdate(RdKGToolHdm.callbackName, RdKGToolHdm.state.delayInterval, RdKGToolHdm.StartDmgLoop)
		end
	else
		--d("unregister")
		if RdKGToolHdm.state.registredActiveConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(RdKGToolHdm.callbackName, EVENT_ACTION_LAYER_POPPED)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolHdm.callbackName, EVENT_ACTION_LAYER_PUSHED)
			
			RdKGToolHdm.UnregisterCombatEvents()
			--EVENT_MANAGER:UnregisterForEvent(RdKGToolHdm.callbackName, EVENT_COMBAT_EVENT)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolHdm.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_HP_DMG)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolHdm.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS)
			--RdKGToolNetworking.RemoveRawMessageHandler(RdKGToolHdm.callbackName)
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolHdm.hpCallbackName)
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolHdm.uiCallbackName)
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolHdm.updateCallbackName)
			
			RdKGToolHdm.state.registredActiveConsumers = false
		end
		if RdKGToolHdm.state.delayedLoopStarting == true then
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolHdm.callbackName)
			RdKGToolHdm.state.delayedLoopStarting = false
		end
	end
	RdKGToolHdm.SetControlVisibility()
end

function RdKGToolHdm.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolHdm.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolHdm.state.foreground = false
	end
	--hack?
	RdKGToolHdm.state.activeLayerIndex = activeLayerIndex
	
	RdKGToolHdm.SetControlVisibility()
end

function RdKGToolHdm.OnCombatEventHealing(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, bLog, sourceUnitId, targetUnitId, abilityId)
	--d("----------------")
	--d("healing")
	--d(sourceType)
	--d(targetType)
	--d(result)
	if sourceName ~= targetName and hitValue > 0 then
		local unit = RdKGToolUtilGroup.GetUnitFromRawCharName(targetName)
		if unit ~= nil then
			RdKGToolHdm.state.meter.healing = RdKGToolHdm.state.meter.healing + hitValue
			--d("----------------")
			--d("new: " .. sourceType)
			--d("new: " .. targetType)
			--d("new: " .. result)
		end
	end
end

function RdKGToolHdm.OnCombatEventDamage(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, bLog, sourceUnitId, targetUnitId, abilityId)
	--d("----------------")
	--d("damage")
	--d("new: " .. sourceType)
	--d("new: " .. targetType)
	--d("new: " .. result)
	if targetType == COMBAT_UNIT_TYPE_OTHER and sourceName ~= targetName and hitValue > 0 then
		--d("----------------")
		--d("damage")
		--d("new: " .. sourceType)
		--d("new: " .. targetType)
		--d("new: " .. result)
		RdKGToolHdm.state.meter.damage = RdKGToolHdm.state.meter.damage + hitValue
	end
end

function RdKGToolHdm.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, bLog, sourceUnitId, targetUnitId, abilityId)
	if eventCode == EVENT_COMBAT_EVENT then
		--d(targetName)
		if sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET then
			--Damage dealt
			--d("----")
			--d(result)
			--d(hitValue)
			if targetType == COMBAT_UNIT_TYPE_OTHER  
			and (result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE 
			or   result == ACTION_RESULT_DOT_TICK or result == ACTION_RESULT_DOT_TICK_CRITICAL
			or   result == ACTION_RESULT_DAMAGE_SHIELDED or result == ACTION_RESULT_BLOCKED_DAMAGE
			) and sourceName ~= targetName and hitValue > 0 then
				--and targetType == COMBAT_UNIT_TYPE_PLAYER
				RdKGToolHdm.state.meter.damage = RdKGToolHdm.state.meter.damage + hitValue
				--d("----------------")
				--d("old: " .. sourceType)
				--d("old: " .. targetType)
				--d("old: " .. result)
				--d("old: " .. hitValue)
			end
			
			--Healing caused
			if (result == ACTION_RESULT_HEAL or result == ACTION_RESULT_CRITICAL_HEAL or result == ACTION_RESULT_HOT_TICK or result == ACTION_RESULT_HOT_TICK_CRITICAL or result == ACTION_RESULT_HEAL_ABSORBED) and
			   sourceName ~= targetName and hitValue > 0 then
			   --d("hv2: " .. hitValue)
				--d(targetName)
				local unit = RdKGToolUtilGroup.GetUnitFromRawCharName(targetName)
				--d(unitTag)
				if unit ~= nil then
					local current, maximum, effectiveMax = GetUnitPower(unit.unitTag, POWERTYPE_HEALTH)
					--d("vals: " .. current .. ", " .. maximum .. ", " .. effectiveMax)
					--if unit.unitTag == "group3" then
					--	d("combat health: " .. unit.lastKnownHealth)
					--	d("combat hit: " .. hitValue)
					--end
					--if unit.lastKnownHealth ~= maximum and unit.lastKnownHealth ~= current then
					-- yes right, fuck ZOS and their API changes. Fucking working around their bugs fixing things and they break it by fixing it.
					-- getting zos'ed all day long
					--	current = unit.lastKnownHealth
					--	local dif = maximum - current
					--	if hitValue < dif then
					--		dif = hitValue
					--	end
						--d(dif)
						RdKGToolHdm.state.meter.healing = RdKGToolHdm.state.meter.healing + hitValue
					--end
					--d("----------------")
					--d("old: " .. sourceType)
					--d("old: " .. targetType)
					--d("old: " .. result)
					--d("old: " .. hitValue)
				end
			end
		end
	end
end

function RdKGToolHdm.StartDmgLoop()
	if RdKGToolHdm.state.delayCount == 1 then
		RdKGToolHdm.state.delayedLoopStarting = false
		RdKGToolHdm.state.delayedLoopStarted = true
		EVENT_MANAGER:UnregisterForUpdate(RdKGToolHdm.callbackName)
		EVENT_MANAGER:RegisterForUpdate(RdKGToolHdm.dmgCallbackName, RdKGToolHdm.state.hpDmgUpdateInterval, RdKGToolHdm.DmgUpdateLoop)
	else
		RdKGToolHdm.state.delayCount = RdKGToolHdm.state.delayCount + 1
	end
end

function RdKGToolHdm.MessageUpdateLoop()
	if RdKGToolHdm.hdmVars.pvpOnly == false or (RdKGToolHdm.hdmVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true) then
		if RdKGToolHdm.state.meter.lastDamageMessage ~= nil and RdKGToolHdm.state.meter.lastDamageMessage.sent == false then
			local message = RdKGToolHdm.state.meter.lastDamageMessage
			local damage = RdKGToolNetworking.DecodeInt24(message.b1, message.b2, message.b3)
			
			local damageValue = RdKGToolHdm.state.meter.damage
			damage = RdKGToolMath.Int24ToArray(damage)
			damage[22] = 0
			damage[23] = 0
			damage[24] = 0
			damage = RdKGToolMath.ArrayToInt24(damage)
			damageValue = damageValue + damage
			if damageValue > 2097151 then
				damageValue = 2097151
			end
			damageValue = RdKGToolMath.Int24ToArray(damageValue)
			local debuffs = RdKGToolHdm.GetPlayerDebuffs()
			if debuffs > 7 then
				debuffs = 7
			end
			debuffs = RdKGToolMath.DecodeBitArrayHelper(debuffs)
			damageValue[22] = debuffs[1]
			damageValue[23] = debuffs[2]
			damageValue[24] = debuffs[3]
			damageValue = RdKGToolMath.ArrayToInt24(damageValue)
			
			
			RdKGToolHdm.state.meter.damage = 0
			--Ignore the fact that this value could exceed 24bit => 16'777'215 but this should be hardly the case and therefore for simplicity ignored.
			--Ignore the fact that it is only 2097151 now
			message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeInt24(damageValue)
		end
		
		if RdKGToolHdm.state.meter.lastHpMessage ~= nil and RdKGToolHdm.state.meter.lastHpMessage.sent == false then
			local message = RdKGToolHdm.state.meter.lastHpMessage
			local healing = RdKGToolNetworking.DecodeInt24(message.b1, message.b2, message.b3)
			
			local healingValue = RdKGToolHdm.state.meter.healing
			healing = RdKGToolMath.Int24ToArray(healing)
			healing[22] = 0
			healing[23] = 0
			healing[24] = 0
			healing = RdKGToolMath.ArrayToInt24(healing)
			healingValue = healingValue + healing
			if healingValue > 2097151 then
				healingValue = 2097151
			end
			healingValue = RdKGToolMath.Int24ToArray(healingValue)
			local debuffs = RdKGToolHdm.GetPlayerDebuffs()
			if debuffs > 7 then
				debuffs = 7
			end
			debuffs = RdKGToolMath.DecodeBitArrayHelper(debuffs)
			healingValue[22] = debuffs[1]
			healingValue[23] = debuffs[2]
			healingValue[24] = debuffs[3]
			healingValue = RdKGToolMath.ArrayToInt24(healingValue)
			
			RdKGToolHdm.state.meter.healing = 0
			--Ignore the fact that this value could exceed 24bit => 16'777'215 but this should be hardly the case and therefore for simplicity ignored.
			message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeInt24(healingValue)
		end
	end
end

function RdKGToolHdm.UiLoop()
	if RdKGToolHdm.hdmVars.pvpOnly == false or (RdKGToolHdm.hdmVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true) then
		local players = RdKGToolUtilGroup.GetGroupInformation()
		local damageControl = RdKGToolHdm.controls.hdmTLW.rootControl.damageControl.playerBlocks
		local healingControl = RdKGToolHdm.controls.hdmTLW.rootControl.healingControl.playerBlocks
		if players ~= nil then
			local damageList, totalDamage = RdKGToolHdm.CopyPlayersIncludingTotals(players, "damage")
			local healingList, totalHealing = RdKGToolHdm.CopyPlayersIncludingTotals(players, "healing")
			--d(totalDamage)
			
			table.sort(damageList, RdKGToolHdm.ComparePlayersByDamage)
			table.sort(healingList, RdKGToolHdm.ComparePlayersByHealing)
			for i = 1, #damageList do
				--Dmg
				
				if damageList[i].meter ~= nil and damageList[i].meter.damage ~= nil then
					local isDps, isHealer, isTank = GetGroupMemberRoles(damageList[i].unitTag)
					local alpha = RdKGToolHdm.config.backgroundEven
					if RdKGToolHdm.hdmVars.useAlpha == true then
						if i % 2 == 1 then
							alpha = RdKGToolHdm.config.backgroundOdd
						end
					end
					local color = {r = 0, g = 0, b = 0}
					if RdKGToolHdm.hdmVars.useColors == true then
						if isDps == true then
							color = RdKGToolHdm.hdmVars.backgroundColor.dd
						elseif isHealer == true then
							color = RdKGToolHdm.hdmVars.backgroundColor.healer
						elseif isTank == true then
							color = RdKGToolHdm.hdmVars.backgroundColor.tank
						end
					end
					if RdKGToolHdm.hdmVars.highlightApplicant == true then
						if damageList[i].role == RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT then
							color = RdKGToolHdm.hdmVars.backgroundColor.applicant
						end
					end
					damageControl[i].nameBackdrop:SetCenterColor(color.r, color.g, color.b, alpha)
					damageControl[i].nameBackdrop:SetEdgeColor(color.r, color.g, color.b,0)
					damageControl[i].valueBackdrop:SetCenterColor(color.r, color.g, color.b, alpha)
					damageControl[i].valueBackdrop:SetEdgeColor(color.r, color.g, color.b,0)
					
					damageControl[i].name:SetText(damageList[i].name)
					local damagePercent = 100 / (totalDamage / damageList[i].meter.damage)
					if damageList[i].meter.damage == 0 then
						damagePercent = 0
					end
					local formatString = RdKGToolHdm.constants.LABEL_VALUE_FORMAT
					if damagePercent < 10 then
						formatString = RdKGToolHdm.constants.LABEL_VALUE_FORMAT_2
					end
					damageControl[i].value:SetText(string.format(formatString, damageList[i].meter.damage, damagePercent))
					if IsUnitDead(damageList[i].unitTag) == true then
						damageControl[i].name:SetColor(RdKGToolHdm.hdmVars.deadColor.r, RdKGToolHdm.hdmVars.deadColor.g, RdKGToolHdm.hdmVars.deadColor.b)
						damageControl[i].value:SetColor(RdKGToolHdm.hdmVars.deadColor.r, RdKGToolHdm.hdmVars.deadColor.g, RdKGToolHdm.hdmVars.deadColor.b)
					else
						damageControl[i].name:SetColor(RdKGToolHdm.hdmVars.aliveColor.r, RdKGToolHdm.hdmVars.aliveColor.g, RdKGToolHdm.hdmVars.aliveColor.b)
						damageControl[i].value:SetColor(RdKGToolHdm.hdmVars.aliveColor.r, RdKGToolHdm.hdmVars.aliveColor.g, RdKGToolHdm.hdmVars.aliveColor.b)
					end
				else
					damageControl[i].name:SetText("")
					damageControl[i].value:SetText("")
				end
				--Hp
				if healingList[i].meter ~= nil and healingList[i].meter.healing ~= nil then
					local isDps, isHealer, isTank = GetGroupMemberRoles(healingList[i].unitTag)
					local alpha = RdKGToolHdm.config.backgroundEven
					if RdKGToolHdm.hdmVars.useAlpha == true then
						if i % 2 == 1 then
							alpha = RdKGToolHdm.config.backgroundOdd
						end
					end
					local color = {r = 0, g = 0, b = 0}
					if RdKGToolHdm.hdmVars.useColors == true then
						if isDps == true then
							color = RdKGToolHdm.hdmVars.backgroundColor.dd
						elseif isHealer == true then
							color = RdKGToolHdm.hdmVars.backgroundColor.healer
						elseif isTank == true then
							color = RdKGToolHdm.hdmVars.backgroundColor.tank
						end
					end
					if RdKGToolHdm.hdmVars.highlightApplicant == true then
						if healingList[i].role == RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT then
							color = RdKGToolHdm.hdmVars.backgroundColor.applicant
						end
					end
					healingControl[i].nameBackdrop:SetCenterColor(color.r, color.g, color.b, alpha)
					healingControl[i].nameBackdrop:SetEdgeColor(color.r, color.g, color.b,0)
					healingControl[i].valueBackdrop:SetCenterColor(color.r, color.g, color.b, alpha)
					healingControl[i].valueBackdrop:SetEdgeColor(color.r, color.g, color.b,0)
					
					healingControl[i].name:SetText(healingList[i].name)
					local healingPercent = 100 / (totalHealing / healingList[i].meter.healing)
					if healingList[i].meter.healing == 0 then
						healingPercent = 0
					end
					local formatString = RdKGToolHdm.constants.LABEL_VALUE_FORMAT
					if healingPercent < 10 then
						formatString = RdKGToolHdm.constants.LABEL_VALUE_FORMAT_2
					end
					healingControl[i].value:SetText(string.format(formatString, healingList[i].meter.healing, healingPercent))
					if IsUnitDead(healingList[i].unitTag) == true then
						healingControl[i].name:SetColor(RdKGToolHdm.hdmVars.deadColor.r, RdKGToolHdm.hdmVars.deadColor.g, RdKGToolHdm.hdmVars.deadColor.b)
						healingControl[i].value:SetColor(RdKGToolHdm.hdmVars.deadColor.r, RdKGToolHdm.hdmVars.deadColor.g, RdKGToolHdm.hdmVars.deadColor.b)
					else
						healingControl[i].name:SetColor(RdKGToolHdm.hdmVars.aliveColor.r, RdKGToolHdm.hdmVars.aliveColor.g, RdKGToolHdm.hdmVars.aliveColor.b)
						healingControl[i].value:SetColor(RdKGToolHdm.hdmVars.aliveColor.r, RdKGToolHdm.hdmVars.aliveColor.g, RdKGToolHdm.hdmVars.aliveColor.b)
					end
				else
					healingControl[i].name:SetText("")
					healingControl[i].value:SetText("")
				end
			end
			for i = #damageList + 1, 24 do
				damageControl[i].name:SetText("")
				damageControl[i].value:SetText("")
				damageControl[i].nameBackdrop:SetCenterColor(0,0,0,0)
				damageControl[i].nameBackdrop:SetEdgeColor(0,0,0,0)
				damageControl[i].valueBackdrop:SetCenterColor(0,0,0,0)
				damageControl[i].valueBackdrop:SetEdgeColor(0,0,0,0)
				healingControl[i].name:SetText("")
				healingControl[i].value:SetText("")
				healingControl[i].nameBackdrop:SetCenterColor(0,0,0,0)
				healingControl[i].nameBackdrop:SetEdgeColor(0,0,0,0)
				healingControl[i].valueBackdrop:SetCenterColor(0,0,0,0)
				healingControl[i].valueBackdrop:SetEdgeColor(0,0,0,0)
			end
		else
			for i = 1, 24 do
				damageControl[i].name:SetText("")
				damageControl[i].value:SetText("")
				damageControl[i].nameBackdrop:SetCenterColor(0,0,0,0)
				damageControl[i].nameBackdrop:SetEdgeColor(0,0,0,0)
				damageControl[i].valueBackdrop:SetCenterColor(0,0,0,0)
				damageControl[i].valueBackdrop:SetEdgeColor(0,0,0,0)
				healingControl[i].name:SetText("")
				healingControl[i].value:SetText("")
				healingControl[i].nameBackdrop:SetCenterColor(0,0,0,0)
				healingControl[i].nameBackdrop:SetEdgeColor(0,0,0,0)
				healingControl[i].valueBackdrop:SetCenterColor(0,0,0,0)
				healingControl[i].valueBackdrop:SetEdgeColor(0,0,0,0)
			end
		end
	end
end

function RdKGToolHdm.HpUpdateLoop()
	if RdKGToolHdm.hdmVars.pvpOnly == false or (RdKGToolHdm.hdmVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true) then
		--d("hp loop")
		if RdKGToolHdm.state.meter.lastHpMessage == nil or RdKGToolHdm.state.meter.lastHpMessage.sent == true then
			if RdKGToolHdm.state.meter.healing > 0 then
				local message = {}
				message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_HP
				
				local healValue = RdKGToolHdm.state.meter.healing
				if healValue > 2097151 then
					healValue = 2097151
				end
				healValue = RdKGToolMath.Int24ToArray(healValue)
				local debuffs = RdKGToolHdm.GetPlayerDebuffs()
				if debuffs > 7 then
					debuffs = 7
				end
				debuffs = RdKGToolMath.DecodeBitArrayHelper(debuffs)
				healValue[22] = debuffs[1]
				healValue[23] = debuffs[2]
				healValue[24] = debuffs[3]
				healValue = RdKGToolMath.ArrayToInt24(healValue)
				
				message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeInt24(healValue)
				RdKGToolHdm.state.meter.healing = 0
				message.sent = false
				RdKGToolNetworking.SendMessage(message, RdKGToolNetworking.constants.priorities.MEDIUM)
				RdKGToolHdm.state.meter.lastHpMessage = message
			else
				RdKGToolHdm.state.meter.lastHpMessage = nil
			end
		end
	end
end

function RdKGToolHdm.DmgUpdateLoop()
	if RdKGToolHdm.hdmVars.pvpOnly == false or (RdKGToolHdm.hdmVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true) then
		--d("dmg loop")
		if RdKGToolHdm.state.meter.lastDamageMessage == nil or RdKGToolHdm.state.meter.lastDamageMessage.sent == true then
			if RdKGToolHdm.state.meter.damage > 0 then
				local message = {}
				message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_DMG
				
				local damageValue = RdKGToolHdm.state.meter.damage
				if damageValue > 2097151 then
					damageValue = 2097151
				end
				damageValue = RdKGToolMath.Int24ToArray(damageValue)
				local debuffs = RdKGToolHdm.GetPlayerDebuffs()
				if debuffs > 7 then
					debuffs = 7
				end
				debuffs = RdKGToolMath.DecodeBitArrayHelper(debuffs)
				damageValue[22] = debuffs[1]
				damageValue[23] = debuffs[2]
				damageValue[24] = debuffs[3]
				damageValue = RdKGToolMath.ArrayToInt24(damageValue)
				
				message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeInt24(damageValue)
				RdKGToolHdm.state.meter.damage = 0
				message.sent = false
				RdKGToolNetworking.SendMessage(message, RdKGToolNetworking.constants.priorities.MEDIUM)
				RdKGToolHdm.state.meter.lastDamageMessage = message
			else
				RdKGToolHdm.state.meter.lastDamageMessage = nil
			end
		end
	end
end

function RdKGToolHdm.OnKeyBinding()
	RdKGToolUtilGroup.ClearDamageHealingMeter()
end

--menu interactions
function RdKGToolHdm.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.HDM_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.HDM_ENABLED,
					getFunc = RdKGToolHdm.GetHdmEnabled,
					setFunc = RdKGToolHdm.SetHdmEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.HDM_POSITION_FIXED,
					getFunc = RdKGToolHdm.GetHdmPositionLocked,
					setFunc = RdKGToolHdm.SetHdmPositionLocked
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.HDM_PVP_ONLY,
					getFunc = RdKGToolHdm.GetHdmPvpOnly,
					setFunc = RdKGToolHdm.SetHdmPvpOnly
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.HDM_WINDOW_ENABLED,
					getFunc = RdKGToolHdm.GetHdmWindowEnabled,
					setFunc = RdKGToolHdm.SetHdmWindowEnabled
				},
				[5] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.HDM_USING_ALPHA,
					getFunc = RdKGToolHdm.GetHdmUsingAlphaEnabled,
					setFunc = RdKGToolHdm.SetHdmUsingAlphaEnabled
				},
				[6] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.HDM_USING_COLORS,
					getFunc = RdKGToolHdm.GetHdmUsingColorsEnabled,
					setFunc = RdKGToolHdm.SetHdmUsingColorsEnabled
				},
				[7] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.HDM_USING_HIGHLIGHT_APPLICANT,
					getFunc = RdKGToolHdm.GetHdmUsingApplicantHighlightEnabled,
					setFunc = RdKGToolHdm.SetHdmUsingApplicantHighlightEnabled
				},
				[8] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.HDM_AUTO_RESET,
					getFunc = RdKGToolHdm.GetHdmAutoReset,
					setFunc = RdKGToolHdm.SetHdmAutoReset
				},
				[9] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.HDM_SELECTED_VIEWMODE,
					choices = RdKGToolHdm.GetHdmAvailableViewModes(),
					getFunc = RdKGToolHdm.GetHdmSelectedViewMode,
					setFunc = RdKGToolHdm.SetHdmSelectedViewMode,
					width = "full"
				},
				[10] = {
					type = "slider",
					name = RdKGToolMenu.constants.HDM_SIZE,
					min = 1.0,
					max = 2.0,
					step = 0.01,
					getFunc = RdKGToolHdm.GetHdmSelectedSize,
					setFunc = RdKGToolHdm.SetHdmSelectedSize,
					width = "full",
					decimals = 2,
					default = 1.0
				},
				[11] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.HDM_ALIVE_COLOR,
					getFunc = RdKGToolHdm.GetHdmAliveColor,
					setFunc = RdKGToolHdm.SetHdmAliveColor,
					width = "full"
				},
				[12] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.HDM_DEAD_COLOR,
					getFunc = RdKGToolHdm.GetHdmDeadColor,
					setFunc = RdKGToolHdm.SetHdmDeadColor,
					width = "full"
				},
				[13] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.HDM_BACKGROUND_COLOR_HEALER,
					getFunc = RdKGToolHdm.GetHdmHealerColor,
					setFunc = RdKGToolHdm.SetHdmHealerColor,
					width = "full"
				},
				[14] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.HDM_BACKGROUND_COLOR_DD,
					getFunc = RdKGToolHdm.GetHdmDDColor,
					setFunc = RdKGToolHdm.SetHdmDDColor,
					width = "full"
				},
				[15] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.HDM_BACKGROUND_COLOR_TANK,
					getFunc = RdKGToolHdm.GetHdmTankColor,
					setFunc = RdKGToolHdm.SetHdmTankColor,
					width = "full"
				},
				[16] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.HDM_BACKGROUND_COLOR_APPLICANT,
					getFunc = RdKGToolHdm.GetHdmApplicantColor,
					setFunc = RdKGToolHdm.SetHdmApplicantColor,
					width = "full"
				},
			}
		}
	}
	return menu
end

function RdKGToolHdm.GetHdmEnabled()
	return RdKGToolHdm.hdmVars.enabled
end

function RdKGToolHdm.SetHdmEnabled(value)
	RdKGToolHdm.SetEnabled(value)
end

function RdKGToolHdm.GetHdmPositionLocked()
	return RdKGToolHdm.hdmVars.positionLocked
end

function RdKGToolHdm.SetHdmPositionLocked(value)
	RdKGToolHdm.SetPositionLocked(value)
end

function RdKGToolHdm.GetHdmPvpOnly()
	return RdKGToolHdm.hdmVars.pvpOnly
end

function RdKGToolHdm.SetHdmPvpOnly(value)
	RdKGToolHdm.hdmVars.pvpOnly = value
	RdKGToolHdm.SetControlVisibility()
end

function RdKGToolHdm.GetHdmWindowEnabled()
	return RdKGToolHdm.hdmVars.windowEnabled
end

function RdKGToolHdm.SetHdmWindowEnabled(value)
	RdKGToolHdm.hdmVars.windowEnabled = value
	RdKGToolHdm.SetControlVisibility()
end

function RdKGToolHdm.GetHdmUsingAlphaEnabled()
	return RdKGToolHdm.hdmVars.useAlpha
end

function RdKGToolHdm.SetHdmUsingAlphaEnabled(value)
	RdKGToolHdm.hdmVars.useAlpha = value
end

function RdKGToolHdm.GetHdmUsingColorsEnabled()
	return RdKGToolHdm.hdmVars.useColors
end

function RdKGToolHdm.SetHdmUsingColorsEnabled(value)
	RdKGToolHdm.hdmVars.useColors = value
end

function RdKGToolHdm.GetHdmUsingApplicantHighlightEnabled()
	return RdKGToolHdm.hdmVars.highlightApplicant
end

function RdKGToolHdm.SetHdmUsingApplicantHighlightEnabled(value)
	RdKGToolHdm.hdmVars.highlightApplicant = value
end

function RdKGToolHdm.GetHdmAutoReset()
	return RdKGToolHdm.hdmVars.autoClear
end

function RdKGToolHdm.SetHdmAutoReset(value)
	RdKGToolHdm.hdmVars.autoClear = value
	RdKGToolHdm.AdjustAutoClearEnabled()
end

function RdKGToolHdm.GetHdmAvailableViewModes()
	return RdKGToolHdm.constants.viewModes
end

function RdKGToolHdm.GetHdmSelectedViewMode()
	return RdKGToolHdm.constants.viewModes[RdKGToolHdm.hdmVars.viewMode]
end

function RdKGToolHdm.SetHdmSelectedViewMode(value)
	if value ~= nil then
		for i = 1, #RdKGToolHdm.constants.viewModes do
			if RdKGToolHdm.constants.viewModes[i] == value then
				RdKGToolHdm.hdmVars.viewMode = i
			end
		end
	end
	RdKGToolHdm.AdjustViewMode()
end

function RdKGToolHdm.GetHdmSelectedSize()
	return RdKGToolHdm.hdmVars.size
end

function RdKGToolHdm.SetHdmSelectedSize(value)
	if value ~= nil and value >= RdKGToolHdm.constants.size.SMALL and value <= RdKGToolHdm.constants.size.BIG then
		RdKGToolHdm.hdmVars.size = value
		RdKGToolHdm.AdjustControlSize()
	end
end

function RdKGToolHdm.GetHdmAliveColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolHdm.hdmVars.aliveColor)
end

function RdKGToolHdm.SetHdmAliveColor(r, g, b)
	RdKGToolHdm.hdmVars.aliveColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolHdm.GetHdmDeadColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolHdm.hdmVars.deadColor)
end

function RdKGToolHdm.SetHdmDeadColor(r, g, b)
	RdKGToolHdm.hdmVars.deadColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolHdm.GetHdmHealerColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolHdm.hdmVars.backgroundColor.healer)
end

function RdKGToolHdm.SetHdmHealerColor(r, g, b)
	RdKGToolHdm.hdmVars.backgroundColor.healer = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolHdm.GetHdmDDColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolHdm.hdmVars.backgroundColor.dd)
end

function RdKGToolHdm.SetHdmDDColor(r, g, b)
	RdKGToolHdm.hdmVars.backgroundColor.dd = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolHdm.GetHdmTankColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolHdm.hdmVars.backgroundColor.tank)
end

function RdKGToolHdm.SetHdmTankColor(r, g, b)
	RdKGToolHdm.hdmVars.backgroundColor.tank = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolHdm.GetHdmApplicantColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolHdm.hdmVars.backgroundColor.applicant)
end

function RdKGToolHdm.SetHdmApplicantColor(r, g, b)
	RdKGToolHdm.hdmVars.backgroundColor.applicant = RdKGToolMenu.GetColorFromRGB(r, g, b)
end