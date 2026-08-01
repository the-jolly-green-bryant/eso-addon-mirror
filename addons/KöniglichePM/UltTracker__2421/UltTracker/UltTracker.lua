

local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
-- region AddonInformation
local addon = {
	name = "UltTracker",
	version = "0.1a",
	author = "KöniglichePM",
	DisplayName = "UltTracker",
}

local savedVariables

local Default = {
	left = 100,
	top = 100,
	showOnlyCombat = true,
	showOnlyGrouped = false,
	trackfixedultimatecost = false,
	fixedultimatecost = 0,
	isLocked = false,
}

UltTracker = addon
-- endregion

-- region variables
local ultimate = {}
local hide = true;
local showOnlyCombat = true
local showOnlyGrouped = false
-- endregion



-- region functions
local function UpdateUltimateVisibility()
	if ultimate.pct then
		if ultimate.pct > 1 then
			if (savedVariables.showOnlyCombat and savedVariables.showOnlyGrouped and IsUnitGrouped("player") and IsUnitInCombat("player")) then
				UltTrackerGUI:SetHidden(false)
			elseif (savedVariables.showOnlyCombat and savedVariables.showOnlyGrouped == false and IsUnitInCombat("player")) then
				UltTrackerGUI:SetHidden(false)
			elseif (savedVariables.showOnlyCombat == false and savedVariables.showOnlyGrouped and IsUnitGrouped("player")) then
				UltTrackerGUI:SetHidden(false)
			elseif (savedVariables.showOnlyCombat == false and savedVariables.showOnlyGrouped == false) then
				UltTrackerGUI:SetHidden(false)
			else
				UltTrackerGUI:SetHidden(true)
			end
		else
			UltTrackerGUI:SetHidden(true)
		end
	else
		UltTrackerGUI:SetHidden(true)
	end
end

local function UpdateUltimate(powerValue, powerMax, powerEffectiveMax)
	local cost = 0
	if savedVariables.trackfixedultimatecost then
		cost = savedVariables.fixedultimatecost
	else
		-- get the cost of the slotted ability
		cost, mechType = GetSlotAbilityCost(8)
	end
	-- calc percentage
	local pct = 0
	if cost > 0 then
		pct = zo_roundToNearest((powerValue / cost), 0.01)
	else
		pct = 0.0
	end
	-- show label if ready

	-- update ultimate
	ultimate = { ["current"] = powerValue, ["max"] = powerEffectiveMax, ["pct"] = pct }
	UpdateUltimateVisibility()
end

local function PowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if unitTag == "player" then
		-- Ultimate
		if powerType == POWERTYPE_ULTIMATE then
			UpdateUltimate(powerValue, powerMax, powerEffectiveMax)
		end
	end
end

local function OnPlayerCombatState(event, inCombat)
	UpdateUltimateVisibility()
end

local function GroupState(_,_)
	UpdateUltimateVisibility()
end

function addon.OnIndicatorMoveStop()
	savedVariables.left = UltTrackerGUI:GetLeft()
	savedVariables.top = UltTrackerGUI:GetTop()
end

local function CombatStateDisplay()
	UpdateUltimateVisibility()
end

local function CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "UltTracker",
		displayName = "UltTracker",
		author = addon.author,
		version = addon.version,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("KöniglichePM_UltTracker", panelData)

	local optionsData = {
		[1] = {
			type = "header",
			name = "Visibility",
		},
		[2] = {
			type = "checkbox",
			name = "Lock",
			tooltip = "Locks the UI element at the current position",
			getFunc = function() return savedVariables.isLocked end,
			setFunc = function(isLocked)
				savedVariables.isLocked = isLocked
				UltTrackerGUI:SetMouseEnabled(not isLocked)
			end,
		},
		[3] = {
			type = "checkbox",
			name = "Show only in Combat",
			tooltip = "Only shows the UI in Combat",
			getFunc = function() return savedVariables.showOnlyCombat end,
			setFunc = function(value1)
				savedVariables.showOnlyCombat = value1
				showOnlyCombat = value1
				CombatStateDisplay()
			end,
		},
		[4] = {
			type = "checkbox",
			name = "Show only when you are in a group",
			tooltip = "Only shows the UI when yu are part of a group",
			getFunc = function() return savedVariables.showOnlyGrouped end,
			setFunc = function(value2)
				savedVariables.showOnlyGrouped = value2
				showOnlyGrouped = value2
				GroupState()
			end,
		},
		[5] = {
			type = "header",
			name = "Tracking",
		},
		[6] = {
			type = "checkbox",
			name = "Track fixed ultimate cost",
			tooltip = "When checked the addon will display message when you got the set ultimate points, regardless of the ultimatecost of the slotted ultimate",
			getFunc = function() return savedVariables.trackfixedultimatecost end,
			setFunc = function(value3)
				savedVariables.trackfixedultimatecost = value3
				if (ultimate.pct) then
					UpdateUltimate(ultimate.current, 0, ultimate.max)
				end
			end,
		},
		[7] = {
			type = "slider",
			name = "Ultimate Cost",
			tooltip = "The fixed amount of ultimate points used for tracking, when the above checkbox is checked",
			min = 0,
			max = 500,
			step = 1,
			getFunc = function() return savedVariables.fixedultimatecost end,
			setFunc = function(value4)
				savedVariables.fixedultimatecost = value4
				if (ultimate.pct) then
					UpdateUltimate(ultimate.current, 0, ultimate.max)
				end
			end,
		},
 	}

	LAM2:RegisterOptionControls("KöniglichePM_UltTracker", optionsData)
end

local function WeaponSwapped(eventCode, isHotbarSwap)
	if (isHotbarSwap and ultimate.pct) then
		UpdateUltimate(ultimate.current, 0, ultimate.max)
	end
end
-- endregion

-- region management functions
function addon.RestorePosition()
    UltTrackerGUI:ClearAnchors()
    UltTrackerGUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedVariables.left, savedVariables.top)
end

local function PlayerLoaded(eventCode, initial)
	local current, max, effectivemax = GetUnitPower("player", POWERTYPE_ULTIMATE)
	UpdateUltimate(current, max, effectivemax)
end

local function Initialize()
	--self.inCombat = IsUnitInCombat("player")

    --addon is loaded, so it won't be loaded another time
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
	
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_GROUP_MEMBER_JOINED, GroupState)
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_GROUP_MEMBER_LEFT, GroupState)
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_POWER_UPDATE, PowerUpdate)
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ACTION_SLOTS_FULL_UPDATE, WeaponSwapped)
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, PlayerLoaded)

	UltTrackerGUIText:SetText("Ultimate Ready")

	savedVariables = ZO_SavedVars:New("UltTrackerSavedVariables", 2, nil, Default)
	addon.RestorePosition()
	UltTrackerGUI:SetMouseEnabled(not savedVariables.isLocked)

	local fragment = ZO_HUDFadeSceneFragment:New(UltTrackerGUI)
	HUD_SCENE:AddFragment(fragment)
	HUD_UI_SCENE:AddFragment(fragment)
	GAME_MENU_SCENE:AddFragment(fragment)

	CreateSettingsWindow()
end

local function OnAddonLoaded(event, addonName)
	if addonName == addon.name then
		Initialize()
	end
end
-- endregion

-- region EventManager
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
-- endregion