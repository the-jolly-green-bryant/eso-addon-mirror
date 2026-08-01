local ADDON_NAME = "GCDMonitor"
local ADDON_AUTHOR = "CaffeinatedMayhem, Armondeniz"
local ADDON_VERSION = "2.01"
local ADDON_TITLE = "Global Cooldown Monitor"
local ADDON_TITLE_DISPLAY = "Global Cooldown Monitor"
local ADDON_SAVEDVARS = "GCDMonitor_Settings"
local ADDON_SAVEDVARS_VER = 3

GCDM = {}
local GCDM = GCDM
GCDM.savedVariables = {}

local EM = GetEventManager()

-- LAM not for Console
if IsConsoleUI() then return end
local LAM = LibAddonMenu2

--default settings
local defaultSettings = {
	["FrameLeft"] = GuiRoot:GetWidth()/2 + 30,
	["FrameTop"] = GuiRoot:GetHeight()/2 + 30,
	["FrameSize"] = 50,
	["LATime"] = 100,
	["AlertColor"] = {0, 1, 0, 1},
	["CDColor"] = {1, 1, 1, 1},
	["AlertLong"] = false,
	["AutoHide"] = false,
	["cTimeAdd"] = 100,
	["cLATime"] = 100,
	["hideBG"] = false,
	["globalSetting"] = true,
}

local showingChanneled = false
local abilitySlotUsed = 3
local alerted = false
local channelStart = 0
local channelFinish = 0
local inCombat = false

-- get the monitor frame (ui)
local gcd = GCDMonitorFrame
local cooldown = gcd:GetNamedChild("Cooldown")
local backdrop = gcd:GetNamedChild("Backdrop")
local backcolor = gcd:GetNamedChild("Colorfill")
-- nil here is sus
GCDM.fragment = ZO_HUDFadeSceneFragment:New(gcd, nil, 0)

-- core utility
local function RefreshCooldown()

	local remain = 0
	local alert = false

	if showingChanneled then
		remain = math.max(channelFinish - GetGameTimeMilliseconds(),0)
		alert = remain >= 0 and remain < GCDM.savedVariables.cLATime
	else
		local duration, global, globalSlotType = 0,0,0,0
		for i = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + ACTION_BAR_SLOTS_PER_PAGE - 1 do
			remain, duration, global, globalSlotType = GetSlotCooldownInfo(i)
			if global == true then 
				alert = remain >= 0 and remain < GCDM.savedVariables.LATime
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
		-- the nil here is sus
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

local function OnAbilityUsed(event, slotnum)

	--cancel channel
	if showingChanneled and slotnum == 2 then
		HandleCooldown(0,1000,false)
		return
	end
	
	if slotnum < 3 or slotnum > 8 then return end

	abilitySlotUsed = slotnum

	local abilityId = GetSlotBoundId(slotnum)
	local isChanneled, castTime = GetAbilityCastInfo(abilityId)

	-- standard skill duration is 1000ms(1s)
	local duration = 1000

	if isChanneled and castTime > 1000 then
		duration = castTime + GCDM.savedVariables.cTimeAdd
	end
	
	local remain = math.max(duration, 1000)

	showingChanneled = true
	channelStart = GetGameTimeMilliseconds()
	channelFinish = channelStart + duration
	HandleCooldown(remain, duration, true)

end

local function OnCooldownUpdate(event)

	if showingChanneled then return end
	remain, duration, global, globalSlotType = GetSlotCooldownInfo(abilitySlotUsed)
	local isInCooldown = duration > 0
	local showCooldown = isInCooldown and global and globalSlotType == ACTION_TYPE_ABILITY

	HandleCooldown(remain, duration, showCooldown)
end

local function OnPlayerCombatState(event, combatState)

	if combatState ~= inCombat then
		inCombat = combatState
		if combatState then
			gcd:SetHidden(false)
			EM:RegisterForEvent(GCDM.name, EVENT_ACTION_SLOT_ABILITY_USED, OnAbilityUsed)
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
		EM:RegisterForEvent(GCDM.name, EVENT_ACTION_SLOT_ABILITY_USED, OnAbilityUsed)
		EM:RegisterForEvent(GCDM.name, EVENT_ACTION_UPDATE_COOLDOWNS, OnCooldownUpdate)
		gcd:SetHidden(false)
		return
	else
		HUD_SCENE:RemoveFragment(GCDM.fragment)
		HUD_UI_SCENE:RemoveFragment(GCDM.fragment)
		-- Init combat state
		inCombat = IsUnitInCombat("player")
		gcd:SetHidden(not inCombat)
		if inCombat then
			EM:RegisterForEvent(GCDM.name, EVENT_ACTION_SLOT_ABILITY_USED, OnAbilityUsed)
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

	local panelData = {
		type = "panel",
		name = ADDON_NAME,
		displayName = ADDON_TITLE_DISPLAY,
		author = ADDON_AUTHOR,
		version = ADDON_VERSION,
		registerForRefresh = true,
	}

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
			requiresReload = true,
			getFunc = function() return GCDM.savedVariables.globalSetting end,
			setFunc = function(value) GCDM.savedVariables.globalSetting = value end,
		},
		[3] = {
			type = "slider",
			name = "Monitor Size",
			min = 10,
			max = 100,
			step = 1,
			getFunc = function() local x,y = gcd:GetDimensions();return x end,
			setFunc = function(value) GCDM.savedVariables.FrameSize = value;RestoreSize() end,
			default = defaultSettings.FrameSize,
		},
		[4] = {
			type = "colorpicker",
			name = "Alert Color",
			tooltip = "The color to remind you to do next light attack.",
			getFunc = function() return unpack(GCDM.savedVariables.AlertColor) end,
			setFunc = function(r,g,b,a) GCDM.savedVariables.AlertColor = {r, g, b, a};RestoreBC() end,
		},
		[5] = {
			type = "colorpicker",
			name = "Cooldown Color",
			tooltip = "The color of the cooldown timer.",
			getFunc = function() return unpack(GCDM.savedVariables.CDColor) end,
			setFunc = function(r,g,b,a) GCDM.savedVariables.CDColor = {r, g, b, a} end,
		},
		[6] = {
			type = "checkbox",
			name = "Auto hide out of combat",
			tooltip = "",
			getFunc = function() return GCDM.savedVariables.AutoHide end,
			setFunc = function(value) GCDM.savedVariables.AutoHide = value;ToggleUtility() end,
		},
		[7] = {
			type = "checkbox",
			name = "Hide background",
			tooltip = "",
			getFunc = function() return GCDM.savedVariables.hideBG end,
			setFunc = function(value) GCDM.savedVariables.hideBG = value;backdrop:SetHidden(value) end,
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
			getFunc = function() return GCDM.savedVariables.LATime end,
			setFunc = function(value) GCDM.savedVariables.LATime = value end,
			default = defaultSettings.LATime,
		},
		[10] = {
			type = "checkbox",
			name = "Show alert color after cooldown",
			tooltip = "Whether to keep showing alert color after the cooldown's end.",
			getFunc = function() return GCDM.savedVariables.AlertLong end,
			setFunc = function(value) GCDM.savedVariables.AlertLong = value;backcolor:SetHidden(not value) end,
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
			getFunc = function() return GCDM.savedVariables.cTimeAdd end,
			setFunc = function(value) GCDM.savedVariables.cTimeAdd = value end,
			default = defaultSettings.cTimeAdd,
		},
		[13] = {
			type = "slider",
			name = "Channeled Ability Alert Time",
			tooltip = "Light attack alert time for channeled abilities, better to set it equal or shorter than Channel Time Delay.",
			min = 0,
			max = 500,
			step = 1,
			getFunc = function() return GCDM.savedVariables.cLATime end,
			setFunc = function(value) GCDM.savedVariables.cLATime = value end,
			default = defaultSettings.cLATime,
		},
		[14] = {

			type = "button",
			name = "Reset",
			tooltip = "Set all settings to default value.",
			func = function() 
				for i, v in pairs(defaultSettings) do
					GCDM.savedVariables[i] = v
				end
				RestoreSettings() 
			end,
			width = "full",
			warning = "All your settings will be LOST!",
		},
	}

	LAM:RegisterAddonPanel("GCDMPanel", panelData)
	LAM:RegisterOptionControls("GCDMPanel", optionsData)
end

-- Init
function OnAddonLoaded(event, addonName)

	if addonName ~= ADDON_NAME then return end

	GCDM.savedVariables = ZO_SavedVars:NewAccountWide(ADDON_SAVEDVARS, ADDON_SAVEDVARS_VER, "Settings", defaultSettings)

	if GCDM.savedVariables.globalSetting == false then
		GCDM.savedVariables = ZO_SavedVars:NewCharacterIdSettings(ADDON_SAVEDVARS,ADDON_SAVEDVARS_VER, "Settings", defaultSettings)
	end

	ToggleUtility()
	RestoreSettings()
	BuildMenu()

	EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

-- register load event
EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)