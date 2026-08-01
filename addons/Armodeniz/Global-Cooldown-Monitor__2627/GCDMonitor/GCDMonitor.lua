-- namespace
GCDM = GCDM or {}
GCDM.name = "GCDMonitor"
GCDM.version = "1.7"
GCDM.variableVersion = 2

-- eventmanager
local EM = GetEventManager()

-- local variable
local defaultSettings = {
	["FrameLeft"] = GuiRoot:GetWidth()/2 + 30,
	["FrameTop"] = GuiRoot:GetHeight()/2 + 30,
	["FrameSize"] = 50,
	["LATime"] = 100,
	["AlertColor"] = {0, 1, 0, 1},
	["CDColor"] = {1, 1, 1, 1},
	["AlertLong"] = false,
	["AutoHide"] = true,
	["cTimeAdd"] = 100,
	["cLATime"] = 100,
	["hideBG"] = false,
}
local defaultSVSetting = {
	["globalSetting"] = false,
}
local showingChanneled = false
local abilitySlotUsed = 3
local alerted = false
local channelStart = 0
local channelFinish = 0
local inCombat = false

-- get the ui element
local gcd = GCDMonitorFrame
local cooldown = gcd:GetNamedChild("Cooldown")
local backdrop = gcd:GetNamedChild("Backdrop")
local backcolor = gcd:GetNamedChild("Colorfill")
GCDM.fragment = ZO_HUDFadeSceneFragment:New(gcd, nil, 0)

-- core utility
local function RefreshCooldown()

	local remain = 0
	local alert = false

	if showingChanneled then
		remain = math.max(channelFinish - GetGameTimeMilliseconds(),0)
		alert = remain >= 0 and remain <GCDM.savedVariables.cLATime
	else
		local duration, global, globalSlotType = 0,0,0,0
		for i = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + ACTION_BAR_SLOTS_PER_PAGE - 1 do
			remain, duration, global, globalSlotType = GetSlotCooldownInfo(i)
			if global == true then 
				alert = remain >= 0 and remain <GCDM.savedVariables.LATime
				break
			end
		end
	end

	if alert ~= false and alerted == false then
		cooldown:SetFillColor(unpack(GCDM.savedVariables.AlertColor))
		alerted = true
	end

	if remain <= 0 then
		cooldown:SetHidden(true)
		cooldown:ResetCooldown()
		gcd:SetHandler("OnUpdate", nil)
		showingChanneled = false

		if GCDM.savedVariables.AlertLong then
			backcolor:SetCenterColor(unpack(GCDM.savedVariables.AlertColor))
			backcolor:SetEdgeColor(unpack(GCDM.savedVariables.AlertColor))
			backcolor:SetHidden(false)
		else
			backcolor:SetHidden(true)
		end
	end
end

local function HandleCooldown(remain, duration, showCooldown)

	cooldown:SetHidden(not showCooldown)
	alerted = false

	if showCooldown then
		backcolor:SetHidden(true)
		cooldown:SetFillColor(unpack(GCDM.savedVariables.CDColor))
		cooldown:StartCooldown(remain, duration, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, NO_LEADING_EDGE)
		cooldown:SetHidden(false)
		gcd:SetHandler("OnUpdate", function() RefreshCooldown() end)
	end
end

local function OnAbilityUsed(slotnum)

	if slotnum < 3 or slotnum > 8 then return end
	abilitySlotUsed = slotnum

	local abilityId = GetSlotBoundId(slotnum)
	local isChanneled, castTime, channelTime = GetAbilityCastInfo(abilityId)
	if isChanneled or castTime > 0 then
		local duration = math.max(castTime, channelTime) +GCDM.savedVariables.cTimeAdd
		duration = math.max(duration, 1000)
		local remain = duration

		showingChanneled = true
		channelStart = GetGameTimeMilliseconds()
		channelFinish = channelStart + duration
		HandleCooldown(remain, duration, true)
	end
end

local function OnCooldownUpdate(eventCode)

	if showingChanneled then return end
	remain, duration, global, globalSlotType = GetSlotCooldownInfo(abilitySlotUsed)
	local isInCooldown = duration > 0
	local showCooldown = isInCooldown and global and globalSlotType == ACTION_TYPE_ABILITY
	--d("Not Channeled")
	HandleCooldown(remain, duration, showCooldown)
end

local function OnPlayerCombatState(event, combatState)

	if combatState ~= inCombat then
		inCombat = combatState
		if combatState then
			gcd:SetHidden(false)
			EM:RegisterForEvent(GCDM.name, EVENT_ACTION_SLOT_ABILITY_USED, function (_, slotnum) OnAbilityUsed(slotnum) end)
			EM:RegisterForEvent(GCDM.name, EVENT_ACTION_UPDATE_COOLDOWNS, OnCooldownUpdate)
		else
			gcd:SetHidden(true)
			EM:UnregisterForEvent(GCDM.name, EVENT_ACTION_SLOT_ABILITY_USED)
			EM:UnregisterForEvent(GCDM.name, EVENT_ACTION_UPDATE_COOLDOWNS)
		end
	end
end

local function ToggleUtility()

	if GCDM.savedVariables.AutoHide == false then
		HUD_SCENE:AddFragment(GCDM.fragment)
		HUD_UI_SCENE:AddFragment(GCDM.fragment)

		EM:UnregisterForEvent(GCDM.name, EVENT_PLAYER_COMBAT_STATE)
		EM:RegisterForEvent(GCDM.name, EVENT_ACTION_SLOT_ABILITY_USED, function (_, slotnum) OnAbilityUsed(slotnum) end)
		EM:RegisterForEvent(GCDM.name, EVENT_ACTION_UPDATE_COOLDOWNS, OnCooldownUpdate)

		gcd:SetHidden(false)
		return
	else
		HUD_SCENE:RemoveFragment(GCDM.fragment)
		HUD_UI_SCENE:RemoveFragment(GCDM.fragment)
		-- Init combat state
		inCombat = IsUnitInCombat('player')
		gcd:SetHidden(not inCombat)
		if inCombat then
			EM:RegisterForEvent(GCDM.name, EVENT_ACTION_SLOT_ABILITY_USED, function (_, slotnum) OnAbilityUsed(slotnum) end)
			EM:RegisterForEvent(GCDM.name, EVENT_ACTION_UPDATE_COOLDOWNS, OnCooldownUpdate)
		end
		EM:RegisterForEvent(GCDM.name, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
	end
end

-- UI setting functions
function GCDM.OnFrameMoveStop()
	GCDM.savedVariables.FrameLeft = gcd:GetLeft()
	GCDM.savedVariables.FrameTop = gcd:GetTop()
end

local function RestorePosition()
	local left = GCDM.savedVariables.FrameLeft
	local top = GCDM.savedVariables.FrameTop

	gcd:ClearAnchors()
	gcd:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function RestoreSize()
	local size = GCDM.savedVariables.FrameSize

	gcd:SetDimensions(size, size)
end

local function RestoreBC()
	backcolor:SetCenterColor(unpack(GCDM.savedVariables.AlertColor))
	backcolor:SetEdgeColor(unpack(GCDM.savedVariables.AlertColor))
end

local function RestoreSettings()
	RestorePosition()
	RestoreSize()
	RestoreBC()

	backcolor:SetHidden(not GCDM.savedVariables.AlertLong)
	backdrop:SetHidden(GCDM.savedVariables.hideBG)
end

-- Menu
local function BuildMenu()
	local LAM = LibAddonMenu2
	local saveData = GCDM.savedVariables -- TODO this should be a reference to your actual saved variables table
	local panelName = "GCDMSettingsPanel" -- TODO the name will be used to create a global variable, pick something unique or you may overwrite an existing variable!

	local panelData = {
		type = "panel",
		name = "GCD Monitor",
		displayName = "Global Cooldown Monitor",
		author = "Armodeniz",
		version = GCDM.version,
		registerForRefresh = true,
	}
	local panel = LAM:RegisterAddonPanel(panelName, panelData)
	local optionsData = {
		[1] = {
			type = "header",
			name = "UI Settings",
			width = "full",
		},
		[2] = {
			type = "checkbox",
			name = "Use Accountwide Settings",
			tooltip = "",
			getFunc = function() return GCDM.svSetting.globalSetting end,
			setFunc = function(value) GCDM.svSetting.globalSetting = value;ReloadUI() end,
			warning = "Will reload UI.",
		},
		[3] = {
			type = "slider",
			name = "Monitor Size",
			min = 10,
			max = 100,
			step = 1,
			getFunc = function() local x,y = gcd:GetDimensions();return x end,
			setFunc = function(value) saveData.FrameSize = value;RestoreSize() end,
			default = defaultSettings.FrameSize,
		},
		[4] = {
			type = "colorpicker",
			name = "Alert Color",
			tooltip = "The color to remind you to do next light attack.",
			getFunc = function() return unpack(saveData.AlertColor) end,
			setFunc = function(r,g,b,a) saveData.AlertColor = {r, g, b, a};RestoreBC() end,
		},
		[5] = {
			type = "colorpicker",
			name = "Cooldown Color",
			tooltip = "The color of the cooldown timer.",
			getFunc = function() return unpack(saveData.CDColor) end,
			setFunc = function(r,g,b,a) saveData.CDColor = {r, g, b, a} end,
		},
		[6] = {
			type = "checkbox",
			name = "Auto hide out of combat",
			tooltip = "",
			getFunc = function() return saveData.AutoHide end,
			setFunc = function(value) saveData.AutoHide = value;ToggleUtility() end,
		},
		[7] = {
			type = "checkbox",
			name = "Hide background",
			tooltip = "",
			getFunc = function() return saveData.hideBG end,
			setFunc = function(value) saveData.hideBG = value;backdrop:SetHidden(value) end,
		},
		[8] = {
			type = "header",
			name = "Normal Ability Settings",
			width = "full",
		},
		[9] = {
			type = "slider",
			name = "Light Attack Alert Time",
			tooltip = "The cooldown timer will change color before its end, to remind you of doing next Light Attack.",
			min = 0,
			max = 500,
			step = 1,
			getFunc = function() return saveData.LATime end,
			setFunc = function(value) saveData.LATime = value end,
			default = defaultSettings.LATime,
		},
		[10] = {
			type = "checkbox",
			name = "Show alert color after cooldown",
			tooltip = "Whether to keep showing alert color after the cooldown's end.",
			getFunc = function() return saveData.AlertLong end,
			setFunc = function(value) saveData.AlertLong = value;backcolor:SetHidden(not value) end,
		},
		[11] = {
			type = "header",
			name = "Channeled Ability Settings",
			width = "full",
		},
		[12] = {
			type = "slider",
			name = "Channel Time Delay",
			tooltip = "The cooldown will be a bit longer than its channel time, to give you time for light attack.",
			min = 0,
			max = 500,
			step = 1,
			getFunc = function() return saveData.cTimeAdd end,
			setFunc = function(value) saveData.cTimeAdd = value end,
			default = defaultSettings.cTimeAdd,
		},
		[13] = {
			type = "slider",
			name = "Channeled Ability Alert Time",
			tooltip = "Light attack alert time for channeled abilities, better to set it equal or shorter than Channel Time Delay.",
			min = 0,
			max = 500,
			step = 1,
			getFunc = function() return saveData.cLATime end,
			setFunc = function(value) saveData.cLATime = value end,
			default = defaultSettings.cLATime,
		},
		[14] = {

			type = "button",
			name = "Reset",
			tooltip = "Set all settings to default value.",
			func = function() 
				for i, v in pairs(defaultSettings) do
					saveData[i] = v
				end
				RestoreSettings() 
			end,
			width = "full",
			warning = "All your settings will LOST!",
		},
	}
	LAM:RegisterOptionControls(panelName, optionsData)
end

-- Init
local function Initialize()
	GCDM.svSetting = ZO_SavedVars:NewAccountWide("GCDMonitorSVSetting", GCDM.variableVersion, nil, defaultSVSetting)
	if GCDM.svSetting.globalSetting == false then
		GCDM.savedVariables = ZO_SavedVars:New("GCDMonitorSavedVariables", GCDM.variableVersion, nil, defaultSettings)
	else
		GCDM.savedVariables = ZO_SavedVars:NewAccountWide("GCDMonitorSavedVariables", GCDM.variableVersion, nil, defaultSettings)
	end
	ToggleUtility()
	RestoreSettings()
	BuildMenu()
end

function GCDM.OnAddonLoaded(event, addonName)
	if addonName == GCDM.name then
		EM:UnregisterForEvent(GCDM.name, EVENT_ADD_ON_LOADED)
		Initialize()
	end
end
-- register load event
EM:RegisterForEvent(GCDM.name, EVENT_ADD_ON_LOADED, GCDM.OnAddonLoaded)
