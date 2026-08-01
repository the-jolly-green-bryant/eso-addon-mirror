-- RdK Group Tool Potion Overview
-- By @s0rdrak (PC / EU)

RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGTool.group = RdKGTool.group or {}
local RdKGToolGroup = RdKGTool.group
RdKGToolGroup.po = RdKGToolGroup.po or {}
local RdKGToolPo = RdKGToolGroup.po
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolUtilGroup = RdKGToolUtil.group
RdKGToolUtil.sound = RdKGToolUtil.sound or {}
local RdKGToolSound = RdKGToolUtil.sound
RdKGToolUtil.fonts = RdKGToolUtil.fonts or {}
local RdKGToolFonts = RdKGToolUtil.fonts

RdKGToolPo.constants = RdKGToolPo.constants or {}
RdKGToolPo.constants.TLW_OVERVIEW = "RdKGTool.group.po.tlw_overview"

RdKGToolPo.constants.COOLDOWN = 45

RdKGToolPo.callbackName = RdKGTool.addonName .. "PotionOverview"

RdKGToolPo.config = {}
RdKGToolPo.config.updateInterval = 100
RdKGToolPo.config.overview = {}
RdKGToolPo.config.overview.isClampedToScreen = true
RdKGToolPo.config.overview.progresswidth = 100
RdKGToolPo.config.overview.width = 120
RdKGToolPo.config.overview.potionProgressHeight = 12
RdKGToolPo.config.overview.potionImmovableHeight = 12
RdKGToolPo.config.overview.height = 24

RdKGToolPo.state = {}
RdKGToolPo.state.initialized = false
RdKGToolPo.state.foreground = true
RdKGToolPo.state.registredConsumers = false
RdKGToolPo.state.soundPlayed = false
RdKGToolPo.state.registredActiveConsumers = false
RdKGToolPo.state.activeLayerIndex = 1

RdKGToolPo.controls = {}

local wm = WINDOW_MANAGER

function RdKGToolPo.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolPo.callbackName, RdKGToolPo.OnProfileChanged)
	
	RdKGToolPo.CreateUI()
	
	RdKGToolPo.state.sounds = RdKGToolSound.GetRestrictedSounds()
	
	RdKGToolMenu.AddPositionFixedConsumer(RdKGToolPo.SetPoPositionLocked)
	
	RdKGToolPo.state.initialized = true
	RdKGToolPo.SetEnabled(RdKGToolPo.poVars.enabled)
end

function RdKGToolPo.SetTlwLocation()
	RdKGToolPo.controls.overviewTLW:ClearAnchors()
	if RdKGToolPo.poVars.overview.location == nil then
		RdKGToolPo.controls.overviewTLW:SetAnchor(CENTER, GuiRoot, CENTER, 125, 125)
	else
		RdKGToolPo.controls.overviewTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolPo.poVars.overview.location.x, RdKGToolPo.poVars.overview.location.y)
	end
end

function RdKGToolPo.CreateUI()

	RdKGToolPo.controls.overviewTLW = wm:CreateTopLevelWindow(RdKGToolPo.constants.TLW_OVERVIEW)
	
	RdKGToolPo.SetTlwLocation()
		
	RdKGToolPo.controls.overviewTLW:SetClampedToScreen(RdKGToolPo.config.overview.isClampedToScreen)
	--RdKGToolPo.controls.overviewTLW:SetDrawLayer(0)
	--RdKGToolPo.controls.overviewTLW:SetDrawLevel(0)
	RdKGToolPo.controls.overviewTLW:SetHandler("OnMoveStop", RdKGToolPo.SaveOverviewWindowLocation)
	RdKGToolPo.controls.overviewTLW:SetDimensions(RdKGToolPo.config.overview.width, RdKGToolPo.config.overview.height * 24)
	
	RdKGToolPo.controls.overviewTLW.rootControl = wm:CreateControl(nil, RdKGToolPo.controls.overviewTLW, CT_CONTROL)
	
	local rootControl = RdKGToolPo.controls.overviewTLW.rootControl
	
	rootControl:SetDimensions(RdKGToolPo.config.overview.width, RdKGToolPo.config.overview.height * 24)
	rootControl:SetAnchor(TOPLEFT, RdKGToolPo.controls.overviewTLW, TOPLEFT, 0, 0)
	
	rootControl.movableBackdrop = wm:CreateControl(nil, rootControl, CT_BACKDROP)
	
	rootControl.movableBackdrop:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	rootControl.movableBackdrop:SetDimensions(RdKGToolPo.config.overview.width, RdKGToolPo.config.overview.height * 24)
	
	rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	rootControl.playerBlocks = RdKGToolPo.CreatePlayerBlocks(rootControl, RdKGToolPo.config.overview.width, RdKGToolPo.config.overview.progresswidth, RdKGToolPo.config.overview.height, RdKGToolPo.config.overview.potionProgressHeight, RdKGToolPo.config.overview.potionImmovableHeight)
	
	RdKGToolPo.SetProgressColors()
	RdKGToolPo.SetPositionLocked(RdKGToolPo.poVars.positionLocked)
	RdKGToolPo.SetControlVisibility()
end

function RdKGToolPo.CreatePlayerBlocks(parent, width, progressWidth, height, potionHeight, immovableHeight)
	local playerBlocks = {}
	if parent ~= nil and width ~= nil and progressWidth ~= nil and height ~= nil and potionHeight ~= nil and immovableHeight ~= nil then
		for i = 1, 24 do
			playerBlocks[i] = wm:CreateControl(nil, parent, CT_CONTROL)
			playerBlocks[i]:SetDimensions(width, height)
			playerBlocks[i]:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, (i - 1) * height)
			playerBlocks[i]:SetHidden(true)
			
			playerBlocks[i].backdrop = wm:CreateControl(nil, playerBlocks[i], CT_BACKDROP)
			playerBlocks[i].backdrop:SetAnchor(TOPLEFT, playerBlocks[i], TOPLEFT, 0, 0)
			playerBlocks[i].backdrop:SetDimensions(width, height)
			playerBlocks[i].backdrop:SetEdgeColor(0,0,0,0)
			
			playerBlocks[i].potionBackdrop = wm:CreateControl(nil, playerBlocks[i], CT_BACKDROP)
			playerBlocks[i].potionBackdrop:SetAnchor(TOPLEFT, playerBlocks[i], TOPLEFT, (width - progressWidth) / 2, (height - potionHeight - immovableHeight) / 2)
			playerBlocks[i].potionBackdrop:SetDimensions(progressWidth, potionHeight)
			playerBlocks[i].potionBackdrop:SetEdgeColor(0,0,0,0)
			playerBlocks[i].potionBackdrop:SetAlpha(1)
			
			playerBlocks[i].potionProgress = wm:CreateControl(nil, playerBlocks[i], CT_STATUSBAR)
			playerBlocks[i].potionProgress:SetAnchor(TOPLEFT, playerBlocks[i], TOPLEFT, (width - progressWidth) / 2, (height - potionHeight - immovableHeight) / 2)
			playerBlocks[i].potionProgress:SetDimensions(progressWidth, potionHeight)
			playerBlocks[i].potionProgress:SetMinMax(0, 100)
			playerBlocks[i].potionProgress:SetValue(0)
			
			local potionFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, potionHeight - 2, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
			playerBlocks[i].potionLabel = wm:CreateControl(nil, playerBlocks[i].potionProgress, CT_LABEL)
			playerBlocks[i].potionLabel:SetAnchor(TOPLEFT, playerBlocks[i].potionProgress, TOPLEFT, 0, 0)
			playerBlocks[i].potionLabel:SetFont(potionFont)
			playerBlocks[i].potionLabel:SetWrapMode(ELLIPSIS)
			playerBlocks[i].potionLabel:SetDimensions(progressWidth, potionHeight)
			playerBlocks[i].potionLabel:SetText("")
			playerBlocks[i].potionLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
			--playerBlocks[i].potionLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
			playerBlocks[i].immovableBackdrop = wm:CreateControl(nil, playerBlocks[i], CT_BACKDROP)
			playerBlocks[i].immovableBackdrop:SetAnchor(TOPLEFT, playerBlocks[i], TOPLEFT, (width - progressWidth) / 2, (height - potionHeight - immovableHeight) / 2 + potionHeight)
			playerBlocks[i].immovableBackdrop:SetDimensions(progressWidth, immovableHeight)
			playerBlocks[i].immovableBackdrop:SetEdgeColor(0,0,0,0)
			playerBlocks[i].immovableBackdrop:SetAlpha(1)
			
			playerBlocks[i].immovableProgress = wm:CreateControl(nil, playerBlocks[i], CT_STATUSBAR)
			playerBlocks[i].immovableProgress:SetAnchor(TOPLEFT, playerBlocks[i], TOPLEFT, (width - progressWidth) / 2, (height - potionHeight - immovableHeight) / 2 + potionHeight)
			playerBlocks[i].immovableProgress:SetDimensions(progressWidth, immovableHeight)
			playerBlocks[i].immovableProgress:SetMinMax(0, 100)
			playerBlocks[i].immovableProgress:SetValue(0)
			
			local immovableFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, immovableHeight - 2, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
			playerBlocks[i].immovableLabel = wm:CreateControl(nil, playerBlocks[i].immovableProgress, CT_LABEL)
			playerBlocks[i].immovableLabel:SetAnchor(TOPLEFT, playerBlocks[i].immovableProgress, TOPLEFT, 0, 0)
			playerBlocks[i].immovableLabel:SetFont(immovableFont)
			playerBlocks[i].immovableLabel:SetWrapMode(ELLIPSIS)
			playerBlocks[i].immovableLabel:SetDimensions(progressWidth, immovableHeight)
			playerBlocks[i].immovableLabel:SetText("")
			playerBlocks[i].immovableLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
			--playerBlocks[i].immovableLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			
		end
	end
	return playerBlocks
end

function RdKGToolPo.GetDefaults()
	local defaults = {}
	defaults.enabled = false
	defaults.pvpOnly = true
	defaults.positionLocked = false
	defaults.overview = {}
	defaults.overview.noImmovableColor = {}
	defaults.overview.noImmovableColor.r = 1
	defaults.overview.noImmovableColor.g = 0.23
	defaults.overview.noImmovableColor.b = 0.23
	defaults.overview.noImmovableColor.a = 0.6
	defaults.overview.immovableColorFull = {}
	defaults.overview.immovableColorFull.r = 0
	defaults.overview.immovableColorFull.g = 1
	defaults.overview.immovableColorFull.b = 0
	defaults.overview.immovableColorFull.a = 0.6
	defaults.overview.immovableColorLow = {}
	defaults.overview.immovableColorLow.r = 1
	defaults.overview.immovableColorLow.g = 0.5
	defaults.overview.immovableColorLow.b = 0.2
	defaults.overview.immovableColorLow.a = 0.6
	defaults.overview.immovableProgressColor = {}
	defaults.overview.immovableProgressColor.r = 0.2
	defaults.overview.immovableProgressColor.g = 1
	defaults.overview.immovableProgressColor.b = 0.2
	defaults.overview.potionCraftedProgressColor = {}
	defaults.overview.potionCraftedProgressColor.r = 0.2
	defaults.overview.potionCraftedProgressColor.g = 0.2
	defaults.overview.potionCraftedProgressColor.b = 1
	defaults.overview.potionCrownProgressColor = {}
	defaults.overview.potionCrownProgressColor.r = 1
	defaults.overview.potionCrownProgressColor.g = 0
	defaults.overview.potionCrownProgressColor.b = 1
	defaults.overview.potionNonCraftedProgressColor = {}
	defaults.overview.potionNonCraftedProgressColor.r = 1
	defaults.overview.potionNonCraftedProgressColor.g = 0
	defaults.overview.potionNonCraftedProgressColor.b = 0
	defaults.overview.potionAllianceProgressColor = {}
	defaults.overview.potionAllianceProgressColor.r = 1
	defaults.overview.potionAllianceProgressColor.g = 1
	defaults.overview.potionAllianceProgressColor.b = 0
	defaults.overview.immovableLabelColor = {}
	defaults.overview.immovableLabelColor.r = 1
	defaults.overview.immovableLabelColor.g = 1
	defaults.overview.immovableLabelColor.b = 1
	defaults.overview.potionLabelColor = {}
	defaults.overview.potionLabelColor.r = 1
	defaults.overview.potionLabelColor.g = 1
	defaults.overview.potionLabelColor.b = 1
	defaults.overview.immovableBackdrop = {}
	defaults.overview.immovableBackdrop.r = 0
	defaults.overview.immovableBackdrop.g = 0
	defaults.overview.immovableBackdrop.b = 0
	defaults.overview.potionBackdrop = {}
	defaults.overview.potionBackdrop.r = 0
	defaults.overview.potionBackdrop.g = 0
	defaults.overview.potionBackdrop.b = 0
	defaults.soundEnabled = true
	defaults.selectedSound = "BG_CA_AreaCaptured_Moved"
	return defaults
end

function RdKGToolPo.SetProgressColors()
	local playerBlocks = RdKGToolPo.controls.overviewTLW.rootControl.playerBlocks
	for i = 1, 24 do
		playerBlocks[i].immovableProgress:SetColor(RdKGToolPo.poVars.overview.immovableProgressColor.r, RdKGToolPo.poVars.overview.immovableProgressColor.g, RdKGToolPo.poVars.overview.immovableProgressColor.b, 1)
		playerBlocks[i].potionProgress:SetColor(RdKGToolPo.poVars.overview.potionCraftedProgressColor.r, RdKGToolPo.poVars.overview.potionCraftedProgressColor.g, RdKGToolPo.poVars.overview.potionCraftedProgressColor.b, 1)
		playerBlocks[i].potionLabel:SetColor(RdKGToolPo.poVars.overview.potionLabelColor.r, RdKGToolPo.poVars.overview.potionLabelColor.g, RdKGToolPo.poVars.overview.potionLabelColor.b, 1)
		playerBlocks[i].immovableLabel:SetColor(RdKGToolPo.poVars.overview.immovableLabelColor.r, RdKGToolPo.poVars.overview.immovableLabelColor.g, RdKGToolPo.poVars.overview.immovableLabelColor.b, 1)
		playerBlocks[i].potionBackdrop:SetCenterColor(RdKGToolPo.poVars.overview.potionBackdrop.r, RdKGToolPo.poVars.overview.potionBackdrop.g, RdKGToolPo.poVars.overview.potionBackdrop.b ,0.75)
		playerBlocks[i].immovableBackdrop:SetCenterColor(RdKGToolPo.poVars.overview.immovableBackdrop.r, RdKGToolPo.poVars.overview.immovableBackdrop.g, RdKGToolPo.poVars.overview.immovableBackdrop.b, 0.75)
		
	end
end

function RdKGToolPo.SetEnabled(value)
	if RdKGToolPo.state.initialized == true and value ~= nil then
		RdKGToolPo.poVars.enabled = value
		if value == true then
			if RdKGToolPo.state.registredConsumers == false then
				
				EVENT_MANAGER:RegisterForEvent(RdKGToolPo.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolPo.OnPlayerActivated)
				
			end
			RdKGToolPo.state.registredConsumers = true
		else
			if RdKGToolPo.state.registredConsumers == true then
				
				EVENT_MANAGER:UnregisterForEvent(RdKGToolPo.callbackName, EVENT_PLAYER_ACTIVATED)
				
			end
			RdKGToolPo.state.registredConsumers = false
		end
		RdKGToolPo.OnPlayerActivated()
	end
end

function RdKGToolPo.SetControlVisibility()
	local enabled = RdKGToolPo.poVars.enabled
	local pvpOnly = RdKGToolPo.poVars.pvpOnly
	local setHidden = true
	if enabled ~= nil and pvpOnly ~= nil then

		if enabled == true and (pvpOnly == false or (pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
			setHidden = false
		end
	end
	if setHidden == false then
		if RdKGToolPo.state.foreground == false then
			RdKGToolPo.controls.overviewTLW:SetHidden(RdKGToolPo.state.activeLayerIndex > 2)
		else
			RdKGToolPo.controls.overviewTLW:SetHidden(false)
		end
	else
		RdKGToolPo.controls.overviewTLW:SetHidden(setHidden)
	end
end

function RdKGToolPo.SetPositionLocked(value)
	RdKGToolPo.poVars.positionLocked = value
	RdKGToolPo.controls.overviewTLW:SetMovable(not value)
	RdKGToolPo.controls.overviewTLW:SetMouseEnabled(not value)
	
	if value == true then
		RdKGToolPo.controls.overviewTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolPo.controls.overviewTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	else
		RdKGToolPo.controls.overviewTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolPo.controls.overviewTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	end
end

function RdKGToolPo.GetDistanceColorTone(r1, r2, minValue, maxValue, distance)
	local d = maxValue - minValue
	local color = r1
	
	local delta = r2 - r1
	
	if delta > 0 then
		color = r1 + delta * ((distance - minValue) / d)
	elseif delta < 0 then
		color = r2 - delta * (d - (distance - minValue)) / d
	end
	return color
end

--callbacks
function RdKGToolPo.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolPo.poVars = currentProfile.group.po
		if RdKGToolPo.state.initialized == true then
			RdKGToolPo.SetPositionLocked(RdKGToolPo.poVars.positionLocked)
			RdKGToolPo.SetControlVisibility()
			RdKGToolPo.SetProgressColors()
			RdKGToolPo.SetTlwLocation()
		end
		RdKGToolPo.SetEnabled(RdKGToolPo.poVars.enabled)
		
	end
end

function RdKGToolPo.SaveOverviewWindowLocation()
	if RdKGToolPo.poVars.positionLocked == false then
		RdKGToolPo.poVars.overview.location = RdKGToolPo.poVars.overview.location or {}
		RdKGToolPo.poVars.overview.location.x = RdKGToolPo.controls.overviewTLW:GetLeft()
		RdKGToolPo.poVars.overview.location.y = RdKGToolPo.controls.overviewTLW:GetTop()
	end
end

function RdKGToolPo.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolPo.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolPo.state.foreground = false
	end
	--hack?
	RdKGToolPo.state.activeLayerIndex = activeLayerIndex
	
	RdKGToolPo.SetControlVisibility()
end

function RdKGToolPo.OnPlayerActivated(eventCode, initial)
	if RdKGToolPo.poVars.enabled == true and (RdKGToolPo.poVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true or RdKGToolPo.poVars.pvpOnly == false) then
		--d("register")
		if RdKGToolPo.state.registredActiveConsumers == false then
			EVENT_MANAGER:RegisterForEvent(RdKGToolPo.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolPo.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForEvent(RdKGToolPo.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolPo.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolPo.callbackName, RdKGToolPo.config.updateInterval, RdKGToolPo.UiLoop)
			RdKGToolUtilGroup.AddFeature(RdKGToolPo.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS, RdKGToolPo.config.updateInterval)
			RdKGToolPo.state.registredActiveConsumers = true
		end
	else
		--d("unregister")
		if RdKGToolPo.state.registredActiveConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(RdKGToolPo.callbackName, EVENT_ACTION_LAYER_POPPED)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolPo.callbackName, EVENT_ACTION_LAYER_PUSHED)
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolPo.callbackName)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolPo.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS)
			RdKGToolPo.state.registredActiveConsumers = false
		end
	end
	RdKGToolPo.SetControlVisibility()
end

function RdKGToolPo.UiLoop()
	if RdKGToolPo.poVars.pvpOnly == false or (RdKGToolPo.poVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true) then
		local players = RdKGToolUtilGroup.GetGroupInformation()
		local playerBlocks = RdKGToolPo.controls.overviewTLW.rootControl.playerBlocks
		local timeStamp = GetGameTimeMilliseconds() / 1000
		if players ~= nil then
			for i = 1, #players do
				playerBlocks[i]:SetHidden(false)
				playerBlocks[i].potionLabel:SetText(players[i].name)
				if players[i].buffs ~= nil and players[i].buffs.specialInformation ~= nil and players[i].buffs.specialInformation.potion ~= nil and players[i].buffs.specialInformation.potion.started ~= nil and players[i].buffs.specialInformation.potion.started + RdKGToolPo.constants.COOLDOWN > timeStamp then
					--d("potted")
					if players[i].isLeader == true and RdKGToolPo.poVars.soundEnabled == true and RdKGToolPo.state.soundPlayed == false then
						RdKGToolSound.PlaySoundByName(RdKGToolPo.poVars.selectedSound)
						RdKGToolPo.state.soundPlayed = true
					end
					local potion = players[i].buffs.specialInformation.potion
					-- U30+ Change (Temporary Fix)
					--[[
					if potion.type == RdKGToolUtilGroup.constants.potionTypes.CRAFTED then
						playerBlocks[i].potionProgress:SetColor(RdKGToolPo.poVars.overview.potionCraftedProgressColor.r, RdKGToolPo.poVars.overview.potionCraftedProgressColor.g, RdKGToolPo.poVars.overview.potionCraftedProgressColor.b, 1)
					elseif potion.type == RdKGToolUtilGroup.constants.potionTypes.CROWN then
						playerBlocks[i].potionProgress:SetColor(RdKGToolPo.poVars.overview.potionCrownProgressColor.r, RdKGToolPo.poVars.overview.potionCrownProgressColor.g, RdKGToolPo.poVars.overview.potionCrownProgressColor.b, 1)
					elseif potion.type == RdKGToolUtilGroup.constants.potionTypes.NON_CRAFTED then
						playerBlocks[i].potionProgress:SetColor(RdKGToolPo.poVars.overview.potionNonCraftedProgressColor.r, RdKGToolPo.poVars.overview.potionNonCraftedProgressColor.g, RdKGToolPo.poVars.overview.potionNonCraftedProgressColor.b, 1)
					elseif potion.type == RdKGToolUtilGroup.constants.potionTypes.ALLIANCE then
						playerBlocks[i].potionProgress:SetColor(RdKGToolPo.poVars.overview.potionAllianceProgressColor.r, RdKGToolPo.poVars.overview.potionAllianceProgressColor.g, RdKGToolPo.poVars.overview.potionAllianceProgressColor.b, 1)
					end
					]]
					playerBlocks[i].potionProgress:SetColor(RdKGToolPo.poVars.overview.potionCraftedProgressColor.r, RdKGToolPo.poVars.overview.potionCraftedProgressColor.g, RdKGToolPo.poVars.overview.potionCraftedProgressColor.b, 1)
					
					playerBlocks[i].potionProgress:SetValue(100 - (timeStamp - potion.started) / RdKGToolPo.constants.COOLDOWN * 100)
					if potion.immovableStart ~= nil and potion.immovableEnd ~= nil then
						local percent = 100 - (timeStamp - potion.immovableStart) / (potion.immovableEnd - potion.immovableStart) * 100
						playerBlocks[i].immovableProgress:SetValue(percent)
						playerBlocks[i].immovableLabel:SetText(string.format("%.1f",potion.immovableEnd - timeStamp))
						local color = {}
						color.r = RdKGToolPo.GetDistanceColorTone(RdKGToolPo.poVars.overview.immovableColorLow.r, RdKGToolPo.poVars.overview.immovableColorFull.r, 0, 100, percent)
						color.g = RdKGToolPo.GetDistanceColorTone(RdKGToolPo.poVars.overview.immovableColorLow.g, RdKGToolPo.poVars.overview.immovableColorFull.g, 0, 100, percent)
						color.b = RdKGToolPo.GetDistanceColorTone(RdKGToolPo.poVars.overview.immovableColorLow.b, RdKGToolPo.poVars.overview.immovableColorFull.b, 0, 100, percent)
						color.a = RdKGToolPo.GetDistanceColorTone(RdKGToolPo.poVars.overview.immovableColorLow.a, RdKGToolPo.poVars.overview.immovableColorFull.a, 0, 100, percent)
						playerBlocks[i].backdrop:SetCenterColor(color.r, color.g, color.b, color.a)
					else
						playerBlocks[i].immovableProgress:SetValue(0)
						playerBlocks[i].immovableLabel:SetText("")
						playerBlocks[i].backdrop:SetCenterColor(RdKGToolPo.poVars.overview.noImmovableColor.r, RdKGToolPo.poVars.overview.noImmovableColor.g, RdKGToolPo.poVars.overview.noImmovableColor.b, RdKGToolPo.poVars.overview.noImmovableColor.a)
					end
				else
					if players[i].isLeader == true then
						RdKGToolPo.state.soundPlayed = false
					end
					playerBlocks[i].potionProgress:SetValue(0)
					playerBlocks[i].immovableProgress:SetValue(0)
					playerBlocks[i].immovableLabel:SetText("")
					playerBlocks[i].backdrop:SetCenterColor(RdKGToolPo.poVars.overview.noImmovableColor.r, RdKGToolPo.poVars.overview.noImmovableColor.g, RdKGToolPo.poVars.overview.noImmovableColor.b, RdKGToolPo.poVars.overview.noImmovableColor.a)
				end
			end
			for i = #players + 1, 24 do
				playerBlocks[i]:SetHidden(true)
			end
		else
			for i = 1, 24 do
				playerBlocks[i]:SetHidden(true)
			end
		end
		--RdKGToolPo.SetControlVisibility()
	end
end

--menu interaction
function RdKGToolPo.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.PO_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.PO_ENABLED,
					getFunc = RdKGToolPo.GetPoEnabled,
					setFunc = RdKGToolPo.SetPoEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.PO_POSITION_FIXED,
					getFunc = RdKGToolPo.GetPoPositionLocked,
					setFunc = RdKGToolPo.SetPoPositionLocked
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.PO_PVP_ONLY,
					getFunc = RdKGToolPo.GetPoPvpOnly,
					setFunc = RdKGToolPo.SetPoPvpOnly
				},
				[4] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PO_COLOR_BACKGROUND_NO_IMMOVABLE,
					getFunc = RdKGToolPo.GetPoBgColorNoImmovable,
					setFunc = RdKGToolPo.SetPoBgColorNoImmovable,
					width = "full"
				},
				[5] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PO_COLOR_BACKGROUND_IMMOVABLE_FULL,
					getFunc = RdKGToolPo.GetPoBgColorImmovableFull,
					setFunc = RdKGToolPo.SetPoBgColorImmovableFull,
					width = "full"
				},
				[6] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PO_COLOR_BACKGROUND_IMMOVABLE_LOW,
					getFunc = RdKGToolPo.GetPoBgColorImmovableLow,
					setFunc = RdKGToolPo.SetPoBgColorImmovableLow,
					width = "full"
				},
				[7] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PO_COLOR_PROGRESS_IMMOVABLE,
					getFunc = RdKGToolPo.GetPoProgressColorImmovable,
					setFunc = RdKGToolPo.SetPoProgressColorImmovable,
					width = "full"
				},
				[8] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PO_COLOR_CRAFTED_PROGRESS_POTION,
					getFunc = RdKGToolPo.GetPoCraftedProgressColorPotion,
					setFunc = RdKGToolPo.SetPoCraftedProgressColorPotion,
					width = "full"
				},
				-- U30+ Change (Temporary Fix)
				--[[
				[9] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PO_COLOR_CROWN_PROGRESS_POTION,
					getFunc = RdKGToolPo.GetPoCrownProgressColorPotion,
					setFunc = RdKGToolPo.SetPoCrownProgressColorPotion,
					width = "full"
				},
				[10] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PO_COLOR_NON_CRAFTED_PROGRESS_POTION,
					getFunc = RdKGToolPo.GetPoNonCraftedProgressColorPotion,
					setFunc = RdKGToolPo.SetPoNonCraftedProgressColorPotion,
					width = "full"
				},
				[11] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PO_COLOR_ALLIANCE_PROGRESS_POTION,
					getFunc = RdKGToolPo.GetPoAllianceProgressColorPotion,
					setFunc = RdKGToolPo.SetPoAllianceProgressColorPotion,
					width = "full"
				},
				]]
				[9] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PO_COLOR_LABEL_IMMOVABLE,
					getFunc = RdKGToolPo.GetPoProgressLabelColorImmovable,
					setFunc = RdKGToolPo.SetPoProgressLabelColorImmovable,
					width = "full"
				},
				[10] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PO_COLOR_LABEL_POTION,
					getFunc = RdKGToolPo.GetPoProgressLabelColorPotion,
					setFunc = RdKGToolPo.SetPoProgressLabelColorPotion,
					width = "full"
				},
				[11] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PO_COLOR_BACKDROP_IMMOVABLE,
					getFunc = RdKGToolPo.GetPoProgressBackdropColorImmovable,
					setFunc = RdKGToolPo.SetPoProgressBackdropColorImmovable,
					width = "full"
				},
				[12] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PO_COLOR_BACKDROP_POTION,
					getFunc = RdKGToolPo.GetPoProgressBackdropColorPotion,
					setFunc = RdKGToolPo.SetPoProgressBackdropColorPotion,
					width = "full"
				},
				[13] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.PO_SOUND_ENABLED,
					getFunc = RdKGToolPo.GetPoSoundEnabled,
					setFunc = RdKGToolPo.SetPoSoundEnabled
				},
				[14] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.PO_SELECTED_SOUND,
					choices = RdKGToolPo.GetPoAvailableSounds(),
					getFunc = RdKGToolPo.GetPoSelectedSound,
					setFunc = RdKGToolPo.SetPoSelectedSound,
					width = "full"
				}
			}
		}
	}
	return menu
end

function RdKGToolPo.GetPoEnabled()
	return RdKGToolPo.poVars.enabled
end

function RdKGToolPo.SetPoEnabled(value)
	RdKGToolPo.SetEnabled(value)
end

function RdKGToolPo.GetPoPositionLocked()
	return RdKGToolPo.poVars.positionLocked
end

function RdKGToolPo.SetPoPositionLocked(value)
	RdKGToolPo.SetPositionLocked(value)
end

function RdKGToolPo.GetPoPvpOnly()
	return RdKGToolPo.poVars.pvpOnly
end

function RdKGToolPo.SetPoPvpOnly(value)
	RdKGToolPo.poVars.pvpOnly = value
	RdKGToolPo.SetControlVisibility()
end

function RdKGToolPo.GetPoBgColorNoImmovable()
	return RdKGToolMenu.GetRGBAColor(RdKGToolPo.poVars.overview.noImmovableColor)
end

function RdKGToolPo.SetPoBgColorNoImmovable(r, g, b, a)
	RdKGToolPo.poVars.overview.noImmovableColor = RdKGToolMenu.GetColorFromRGB(r, g, b, a)
end

function RdKGToolPo.GetPoBgColorImmovableFull()
	return RdKGToolMenu.GetRGBAColor(RdKGToolPo.poVars.overview.immovableColorFull)
end

function RdKGToolPo.SetPoBgColorImmovableFull(r, g, b, a)
	RdKGToolPo.poVars.overview.immovableColorFull = RdKGToolMenu.GetColorFromRGB(r, g, b, a)
end

function RdKGToolPo.GetPoBgColorImmovableLow()
	return RdKGToolMenu.GetRGBAColor(RdKGToolPo.poVars.overview.immovableColorLow)
end

function RdKGToolPo.SetPoBgColorImmovableLow(r, g, b, a)
	RdKGToolPo.poVars.overview.immovableColorLow = RdKGToolMenu.GetColorFromRGB(r, g, b, a)
end

function RdKGToolPo.GetPoProgressColorImmovable()
	return RdKGToolMenu.GetRGBColor(RdKGToolPo.poVars.overview.immovableProgressColor)
end

function RdKGToolPo.SetPoProgressColorImmovable(r, g, b)
	RdKGToolPo.poVars.overview.immovableProgressColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPo.SetProgressColors()
end

function RdKGToolPo.GetPoCraftedProgressColorPotion()
	return RdKGToolMenu.GetRGBColor(RdKGToolPo.poVars.overview.potionCraftedProgressColor)
end

function RdKGToolPo.SetPoCraftedProgressColorPotion(r, g, b)
	RdKGToolPo.poVars.overview.potionCraftedProgressColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPo.SetProgressColors()
end

function RdKGToolPo.GetPoCrownProgressColorPotion()
	return RdKGToolMenu.GetRGBColor(RdKGToolPo.poVars.overview.potionCrownProgressColor)
end

function RdKGToolPo.SetPoCrownProgressColorPotion(r, g, b)
	RdKGToolPo.poVars.overview.potionCrownProgressColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPo.SetProgressColors()
end

function RdKGToolPo.GetPoNonCraftedProgressColorPotion()
	return RdKGToolMenu.GetRGBColor(RdKGToolPo.poVars.overview.potionNonCraftedProgressColor)
end

function RdKGToolPo.SetPoNonCraftedProgressColorPotion(r, g, b)
	RdKGToolPo.poVars.overview.potionNonCraftedProgressColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPo.SetProgressColors()
end

function RdKGToolPo.GetPoAllianceProgressColorPotion()
	return RdKGToolMenu.GetRGBColor(RdKGToolPo.poVars.overview.potionAllianceProgressColor)
end

function RdKGToolPo.SetPoAllianceProgressColorPotion(r, g, b)
	RdKGToolPo.poVars.overview.potionAllianceProgressColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPo.SetProgressColors()
end

function RdKGToolPo.GetPoProgressLabelColorImmovable()
	return RdKGToolMenu.GetRGBColor(RdKGToolPo.poVars.overview.immovableLabelColor)
end

function RdKGToolPo.SetPoProgressLabelColorImmovable(r, g, b)
	RdKGToolPo.poVars.overview.immovableLabelColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPo.SetProgressColors()
end

function RdKGToolPo.GetPoProgressLabelColorPotion()
	return RdKGToolMenu.GetRGBColor(RdKGToolPo.poVars.overview.potionLabelColor)
end

function RdKGToolPo.SetPoProgressLabelColorPotion(r, g, b)
	RdKGToolPo.poVars.overview.potionLabelColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPo.SetProgressColors()
end

function RdKGToolPo.GetPoProgressBackdropColorImmovable()
	return RdKGToolMenu.GetRGBColor(RdKGToolPo.poVars.overview.immovableBackdrop)
end

function RdKGToolPo.SetPoProgressBackdropColorImmovable(r, g, b)
	RdKGToolPo.poVars.overview.immovableBackdrop = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPo.SetProgressColors()
end

function RdKGToolPo.GetPoProgressBackdropColorPotion()
	return RdKGToolMenu.GetRGBColor(RdKGToolPo.poVars.overview.potionBackdrop)
end

function RdKGToolPo.SetPoProgressBackdropColorPotion(r, g, b)
	RdKGToolPo.poVars.overview.potionBackdrop = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPo.SetProgressColors()
end

function RdKGToolPo.GetPoSoundEnabled()
	return RdKGToolPo.poVars.soundEnabled
end

function RdKGToolPo.SetPoSoundEnabled(value)
	RdKGToolPo.poVars.soundEnabled = value
end

function RdKGToolPo.GetPoAvailableSounds()
	local sounds = {}
	for i = 1, #RdKGToolPo.state.sounds do
		sounds[i] = RdKGToolPo.state.sounds[i].name
	end
	return sounds
end

function RdKGToolPo.GetPoSelectedSound()
	return RdKGToolPo.poVars.selectedSound
end

function RdKGToolPo.SetPoSelectedSound(value)
	if value ~= nil then
		RdKGToolPo.poVars.selectedSound = value
		RdKGToolSound.PlaySoundByName(value)
	end
end
