--[[
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
All rights reserved

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms]]

-- Initialized the addon names
PriorityBuffAlerts = {}
PriorityBuffAlerts.name = "PriorityBuffAlerts"
PriorityBuffAlerts.version = 12.0

-- Initializes various things; variables aptly named
PriorityBuffAlerts.minorPowerTypeStr1 = nil
PriorityBuffAlerts.majorPowerTypeStr1 = nil
PriorityBuffAlerts.minorPowerTypeStr2 = nil
PriorityBuffAlerts.majorPowerTypeStr2 = nil

PriorityBuffAlerts.minorMending = nil
PriorityBuffAlerts.majorMending = nil
PriorityBuffAlerts.minorVitality = nil
PriorityBuffAlerts.majorVitality = nil

-- For the addon settings menu
PriorityBuffAlerts.LAM2 = LibAddonMenu2

-- Saved beyond session variables
PriorityBuffAlerts.defaults={
	unlocked=true,
	displayLeft=0,
	displayTop=0,
	powerType=1,
	showHealingBuffs=false,
	showText=false,
	fontSize=12,
	redFilter=true,
	showBackground=true
}

function PriorityBuffAlerts:Initialize()
	EVENT_MANAGER:RegisterForEvent(PriorityBuffAlerts.name, EVENT_ACTION_LAYER_PUSHED, PriorityBuffAlerts.OnActionLayerChange)
	EVENT_MANAGER:RegisterForEvent(PriorityBuffAlerts.name, EVENT_ACTION_LAYER_POPPED, PriorityBuffAlerts.OnActionLayerChange)
	EVENT_MANAGER:RegisterForUpdate(PriorityBuffAlerts.name, 500, PriorityBuffAlerts.UpdateWindow)
end

-- When the different layers of the screen are changed - quickslotting, settings, main display, etc.
function PriorityBuffAlerts.OnActionLayerChange(eventCode, layerIndex, activeLayerIndex)
	if PriorityBuffAlerts.SV.unlocked == true then
		PriorityBuffAlertsWindow:SetHidden(false)
		return
	end
	
	PriorityBuffAlertsWindow:SetHidden(activeLayerIndex > 2)
end

-- Loads the addon; only hit once
function PriorityBuffAlerts.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads; but we only care about when our own addon loads.
	if addonName ~= PriorityBuffAlerts.name then
		return
	end

	PriorityBuffAlerts.SV = ZO_SavedVars:New("PriorityBuffAlertsTrackerSettings", 1.1, "Settings", PriorityBuffAlerts.defaults)
	PriorityBuffAlerts:InitializeAddonMenu()

	EVENT_MANAGER:UnregisterForEvent(PriorityBuffAlerts.name, EVENT_ADD_ON_LOADED)

	PriorityBuffAlerts:Initialize()
	PriorityBuffAlerts:InitControls()
end

-- Creates the addon settings menu
function PriorityBuffAlerts:InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Priority Buff Alerts",
		displayName = "|c66ccffPriority Buff Alerts",
		author = "|c4779ce@aldericon|r",
		version = string.format("%.1f", PriorityBuffAlerts.version),
		registerForRefresh = true,
		registerForDefaults = true
	}

	local optionsPanel = self.LAM2:RegisterAddonPanel("PriorityBuffAlerts_Companion", panelData)
	local optionsData = {}

	table.insert(optionsData, {
		type = "description",
		text = "Priority Buff Alerts keeps track of Empower, Force and Berserk for everyone. Once you have chosen your power type, then the tracker will alert you on buffs that are that power-specific. This would be Brutality and  Savagery for Stamina and Sorcery and Prophecy for Magicka. You can choose to have two additional Healing buffs show if wanted: Mending and Vitality. This is meant to be as lightweight as possible for all situations.",
	})
	table.insert(optionsData, {
		type = "header",
		name = "Options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Turn OFF when satisfied with icon's position",
		tooltip = "ON - icon can me moved on the screen by left clicking and dragging, OFF - icon is locked in place and can not be moved",
		default = self.defaults.unlocked,
		getFunc = function() return self.SV.unlocked end,
		setFunc = function(newValue) self.SV.unlocked = newValue self:LoadPositions() end,
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "Choose Power Type:",
		tooltip = 'What type of power do you use?',
		requiresReload = true,
		choices = {"Stamina", "Magicka"},
		getFunc = function() 
			if self.SV.powerType==1 then 
				return "Stamina"
			elseif self.SV.powerType==2 then
				return "Magicka"
			end
		end,
		setFunc = function(newValue)
			if newValue=="Stamina" then 
				self.SV.powerType=1
			elseif newValue=="Magicka" then
				self.SV.powerType=2
			end
		end,
			default = 1,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Display Healing Buffs:",
		tooltip = 'ON - show additiona buffs mending and vitality, OFF - mending and vitality not shown',
		requiresReload = true,
		default = self.defaults.showHealingBuffs,
		getFunc = function() return self.SV.showHealingBuffs end,
		setFunc = function(newValue) self.SV.showHealingBuffs = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Show Buff Text:",
		tooltip = "ON - display buff text below each set of buffs, OFF - display no text",
		default = self.defaults.showText,
		getFunc = function() return self.SV.showText end,
		setFunc = function(newValue) self.SV.showText = newValue self:LoadPositions() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Font Size:",
		tooltip = "Choose font size for text",
		default = 12,
		disabled = function() return not self.SV.showText end,
		min     = 1,
        max     = 24,
        step    = 1,
		getFunc = function() return self.SV.fontSize end,
		setFunc = function(newValue) self.SV.fontSize = newValue self:LoadPositions() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Red Filter:",
		tooltip = "ON - display red filter when buff is half-way done, OFF - display no red filter",
		default = self.defaults.redFilter,
		getFunc = function() return self.SV.redFilter end,
		setFunc = function(newValue) self.SV.redFilter = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Show Background:",
		tooltip = "ON - display background, OFF - display no background",
		default = self.defaults.showBackground,
		getFunc = function() return self.SV.showBackground end,
		setFunc = function(newValue) self.SV.showBackground = newValue self:LoadPositions() end,
	})

	self.LAM2:RegisterOptionControls("PriorityBuffAlerts_Companion", optionsData)	
end

-- Saves the positioning of the display window
function PriorityBuffAlerts.DisplayOnMoveStop()
	PriorityBuffAlerts.SV.displayLeft = PriorityBuffAlertsWindow:GetLeft();
	PriorityBuffAlerts.SV.displayTop = PriorityBuffAlertsWindow:GetTop();
end

-- Setting the positions of the display, popup and purge indicator
function PriorityBuffAlerts:LoadPositions()
	PriorityBuffAlertsWindow:ClearAnchors();
	PriorityBuffAlertsWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PriorityBuffAlerts.SV.displayLeft, PriorityBuffAlerts.SV.displayTop);

	PriorityBuffAlertsWindow:SetMouseEnabled(PriorityBuffAlerts.SV.unlocked) 
	PriorityBuffAlertsWindow:SetMovable(PriorityBuffAlerts.SV.unlocked)

	if PriorityBuffAlerts.SV.showText == false then
		PriorityBuffAlertsWindow_EmpowerLabel:SetHidden(true)
		PriorityBuffAlertsWindow_BerserkLabel:SetHidden(true)
		PriorityBuffAlertsWindow_ForceLabel:SetHidden(true)
		PriorityBuffAlertsWindow_Buff1Label:SetHidden(true)
		PriorityBuffAlertsWindow_Buff2Label:SetHidden(true)
		PriorityBuffAlertsWindow_MendingLabel:SetHidden(true)
		PriorityBuffAlertsWindow_VitalityLabel:SetHidden(true)
	else
		PriorityBuffAlertsWindow_EmpowerLabel:SetHidden(false)
		PriorityBuffAlertsWindow_BerserkLabel:SetHidden(false)
		PriorityBuffAlertsWindow_ForceLabel:SetHidden(false)
		PriorityBuffAlertsWindow_Buff1Label:SetHidden(false)
		PriorityBuffAlertsWindow_Buff2Label:SetHidden(false)
		PriorityBuffAlertsWindow_MendingLabel:SetHidden(false)
		PriorityBuffAlertsWindow_VitalityLabel:SetHidden(false)
	end

	PriorityBuffAlertsWindow_EmpowerLabel:SetFont("$(MEDIUM_FONT)|" .. PriorityBuffAlerts.SV.fontSize)
	PriorityBuffAlertsWindow_BerserkLabel:SetFont("$(MEDIUM_FONT)|" .. PriorityBuffAlerts.SV.fontSize)
	PriorityBuffAlertsWindow_ForceLabel:SetFont("$(MEDIUM_FONT)|" .. PriorityBuffAlerts.SV.fontSize)
	PriorityBuffAlertsWindow_Buff1Label:SetFont("$(MEDIUM_FONT)|" .. PriorityBuffAlerts.SV.fontSize)
	PriorityBuffAlertsWindow_Buff2Label:SetFont("$(MEDIUM_FONT)|" .. PriorityBuffAlerts.SV.fontSize)
	PriorityBuffAlertsWindow_MendingLabel:SetFont("$(MEDIUM_FONT)|" .. PriorityBuffAlerts.SV.fontSize)
	PriorityBuffAlertsWindow_VitalityLabel:SetFont("$(MEDIUM_FONT)|" .. PriorityBuffAlerts.SV.fontSize)

	if PriorityBuffAlerts.SV.showBackground == true then
		PriorityBuffAlertsWindow_Backdrop:SetHidden(false)
	else
		PriorityBuffAlertsWindow_Backdrop:SetHidden(true)
	end
end

-- As settings are changed, hides or displays various features
function PriorityBuffAlerts:InitControls()
	PriorityBuffAlerts:LoadPositions()

	if PriorityBuffAlerts.SV.powerType == 1 then
		PriorityBuffAlertsWindow_MinorBuff1:SetTexture('esoui/art/icons/ability_buff_minor_brutality.dds')
		PriorityBuffAlertsWindow_MajorBuff1:SetTexture('esoui/art/icons/ability_buff_major_brutality.dds')
		PriorityBuffAlertsWindow_MinorBuff2:SetTexture('esoui/art/icons/ability_buff_minor_savagery.dds')
		PriorityBuffAlertsWindow_MajorBuff2:SetTexture('esoui/art/icons/ability_buff_major_savagery.dds')
		
		PriorityBuffAlerts.minorPowerTypeStr1 = 'Minor Brutality'
		PriorityBuffAlerts.majorPowerTypeStr1 = 'Major Brutality'
		PriorityBuffAlerts.minorPowerTypeStr2 = 'Minor Savagery'
		PriorityBuffAlerts.majorPowerTypeStr2 = 'Major Savagery'

		PriorityBuffAlertsWindow_Buff1Label:SetText('Brutality')
		PriorityBuffAlertsWindow_Buff2Label:SetText('Savagery')
	elseif PriorityBuffAlerts.SV.powerType == 2 then
		PriorityBuffAlertsWindow_MinorBuff1:SetTexture('esoui/art/icons/ability_buff_minor_sorcery.dds')
		PriorityBuffAlertsWindow_MajorBuff1:SetTexture('esoui/art/icons/ability_buff_major_sorcery.dds')
		PriorityBuffAlertsWindow_MinorBuff2:SetTexture('esoui/art/icons/ability_buff_minor_prophecy.dds')
		PriorityBuffAlertsWindow_MajorBuff2:SetTexture('esoui/art/icons/ability_buff_major_prophecy.dds')
		
		PriorityBuffAlerts.minorPowerTypeStr1 = 'Minor Sorcery'
		PriorityBuffAlerts.majorPowerTypeStr1 = 'Major Sorcery'
		PriorityBuffAlerts.minorPowerTypeStr2 = 'Minor Prophecy'
		PriorityBuffAlerts.majorPowerTypeStr2 = 'Major Prophecy'

		PriorityBuffAlertsWindow_Buff1Label:SetText('Sorcery')
		PriorityBuffAlertsWindow_Buff2Label:SetText('Prophecy')
	end

	if PriorityBuffAlerts.SV.showHealingBuffs == true then
		local defaultWidth = 1200
		local defaultHeight = 176

		PriorityBuffAlertsWindow_Backdrop:SetDimensions(defaultHeight, defaultWidth+500)

		local offset = -40

		PriorityBuffAlertsWindow_Empower:SetAnchor(CENTER,PriorityBuffAlertsWindow_Backdrop,CENTER, 0, -80+offset)
		PriorityBuffAlertsWindow_MinorBerserk:SetAnchor(CENTER,PriorityBuffAlertsWindow_Backdrop,CENTER, -20, -40+offset)
		PriorityBuffAlertsWindow_MajorBerserk:SetAnchor(CENTER,PriorityBuffAlertsWindow_Backdrop,CENTER, 20, -40+offset)

		local wm = GetWindowManager()

		PriorityBuffAlerts.minorMending = wm:CreateControl("_MinorMending", PriorityBuffAlertsWindow, CT_TEXTURE)
		PriorityBuffAlerts.minorMending:SetDimensions(31,31)
		PriorityBuffAlerts.minorMending:SetAnchor(CENTER, PriorityBuffAlertsWindow_MinorBuff2, CENTER, 0, 40)
		PriorityBuffAlerts.minorMending:SetTexture('esoui/art/icons/ability_buff_minor_mending.dds')

		PriorityBuffAlerts.majorMending = wm:CreateControl("_MajorMending", PriorityBuffAlertsWindow, CT_TEXTURE)
		PriorityBuffAlerts.majorMending:SetDimensions(31,31)
		PriorityBuffAlerts.majorMending:SetAnchor(CENTER, PriorityBuffAlertsWindow_MajorBuff2, CENTER, 0, 40)
		PriorityBuffAlerts.majorMending:SetTexture('esoui/art/icons/ability_buff_major_mending.dds')

		PriorityBuffAlerts.minorVitality = wm:CreateControl("_MinorVitality", PriorityBuffAlertsWindow, CT_TEXTURE)
		PriorityBuffAlerts.minorVitality:SetDimensions(31,31)
		PriorityBuffAlerts.minorVitality:SetAnchor(CENTER, PriorityBuffAlerts.minorMending, CENTER, 0, 40)
		PriorityBuffAlerts.minorVitality:SetTexture('esoui/art/icons/ability_buff_minor_vitality.dds')

		PriorityBuffAlerts.majorVitality = wm:CreateControl("_MajorVitality", PriorityBuffAlertsWindow, CT_TEXTURE)
		PriorityBuffAlerts.majorVitality:SetDimensions(31,31)
		PriorityBuffAlerts.majorVitality:SetAnchor(CENTER, PriorityBuffAlerts.majorMending, CENTER, 0, 40)
		PriorityBuffAlerts.majorVitality:SetTexture('esoui/art/icons/ability_buff_major_vitality.dds')

		PriorityBuffAlertsWindow_MendingLabel:SetText('Mending')
		PriorityBuffAlertsWindow_VitalityLabel:SetText('Vitality')
	else
		PriorityBuffAlertsWindow_MendingLabel:SetHidden(true)
		PriorityBuffAlertsWindow_VitalityLabel:SetHidden(true)
	end
end

-- Update th display window
function PriorityBuffAlerts.UpdateWindow()
	local currentTimeStamp = GetGameTimeMilliseconds() / 1000

	PriorityBuffAlertsWindow_Empower:SetColor(0.1,0.1,0.1,0.5)
	PriorityBuffAlertsWindow_MinorBerserk:SetColor(0.1,0.1,0.1,0.5)
	PriorityBuffAlertsWindow_MajorBerserk:SetColor(0.1,0.1,0.1,0.5)
	PriorityBuffAlertsWindow_MinorForce:SetColor(0.1,0.1,0.1,0.5)
	PriorityBuffAlertsWindow_MajorForce:SetColor(0.1,0.1,0.1,0.5)
	PriorityBuffAlertsWindow_MinorBuff1:SetColor(0.1,0.1,0.1,0.5)
	PriorityBuffAlertsWindow_MajorBuff1:SetColor(0.1,0.1,0.1,0.5)
	PriorityBuffAlertsWindow_MinorBuff2:SetColor(0.1,0.1,0.1,0.5)
	PriorityBuffAlertsWindow_MajorBuff2:SetColor(0.1,0.1,0.1,0.5)

	if PriorityBuffAlerts.SV.showHealingBuffs == true then
		PriorityBuffAlerts.minorMending:SetColor(0.1,0.1,0.1,0.5)
		PriorityBuffAlerts.majorMending:SetColor(0.1,0.1,0.1,0.5)
		PriorityBuffAlerts.minorVitality:SetColor(0.1,0.1,0.1,0.5)
		PriorityBuffAlerts.majorVitality:SetColor(0.1,0.1,0.1,0.5)
	end

	for buffIndex = 1, GetNumBuffs('player') do
		local buffName, timeStarted, timeEnding = GetUnitBuffInfo('player', buffIndex)

		local totalTime = timeEnding - timeStarted
		local timeLeft = timeEnding - currentTimeStamp
		local buffName = zo_strformat("<<1>>", buffName)

		-- for those buffs that are unlimited
		if timeStarted == timeEnding then
			timeLeft = 9999999
		end

		--[[d("Buff Name: "..buffName)
		d("Time Started: "..timeStarted)
		d("Time Ending: "..timeEnding)
		d("Time Left: "..timeLeft)
		d("Time Total: "..totalTime)]]

		local control = nil

		if buffName == 'Minor Berserk' then
			control = PriorityBuffAlertsWindow_MinorBerserk
		elseif buffName == 'Major Berserk' then
			control = PriorityBuffAlertsWindow_MajorBerserk
		elseif buffName == 'Minor Force' then
			control = PriorityBuffAlertsWindow_MinorForce
		elseif buffName == 'Major Force' then
			control = PriorityBuffAlertsWindow_MajorForce
		elseif buffName == PriorityBuffAlerts.minorPowerTypeStr1 then
			control = PriorityBuffAlertsWindow_MinorBuff1
		elseif buffName == PriorityBuffAlerts.majorPowerTypeStr1 then
			control = PriorityBuffAlertsWindow_MajorBuff1
		elseif buffName == PriorityBuffAlerts.minorPowerTypeStr2 then
			control = PriorityBuffAlertsWindow_MinorBuff2
		elseif buffName == PriorityBuffAlerts.majorPowerTypeStr2 then
			control = PriorityBuffAlertsWindow_MajorBuff2
		elseif buffName == 'Empower' then
			control = PriorityBuffAlertsWindow_Empower
		elseif PriorityBuffAlerts.SV.showHealingBuffs == true then
			if buffName == 'Minor Mending' then
				control = PriorityBuffAlerts.minorMending
			elseif buffName == 'Major Mending' then
				control = PriorityBuffAlerts.majorMending
			elseif buffName == 'Minor Vitality' then
				control = PriorityBuffAlerts.minorVitality
			elseif buffName == 'Major Vitality' then
				control = PriorityBuffAlerts.majorVitality
			end
		end

		if control ~= nil then
			PriorityBuffAlerts.UpdateIconStatus(control, timeLeft, totalTime)
		end
	end
end

-- Update the display's icons
function PriorityBuffAlerts.UpdateIconStatus(control, timeLeft, totalTime)
	if timeLeft <= 0 then
		control:SetColor(0.1,0.1,0.1,0.5)
	elseif timeLeft <= (totalTime / 2) and timeLeft >= 0 then
		if PriorityBuffAlerts.SV.redFilter == true then
			control:SetColor(255, 0, 0, 255)
		else
			control:SetColor(1,1,1,1)
		end
	else
		control:SetColor(1,1,1,1)
	end
end

-- so that ESO can register the addon
EVENT_MANAGER:RegisterForEvent(PriorityBuffAlerts.name, EVENT_ADD_ON_LOADED, PriorityBuffAlerts.OnAddOnLoaded)