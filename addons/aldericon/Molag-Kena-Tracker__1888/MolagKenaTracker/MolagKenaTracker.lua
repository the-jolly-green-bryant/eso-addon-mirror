--[[
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
All rights reserved

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms]]

-- Initialized the addon names
MolagKenaTracker = {}
MolagKenaTracker.name = "MolagKenaTracker"
MolagKenaTracker.version = 12.0

-- Initializes various things; variables aptly named

-- For the addon settings menu
MolagKenaTracker.LAM2 = LibAddonMenu2

-- Saved beyond session variables
MolagKenaTracker.defaults={
	unlocked=true,
	displayLeft=0,
	displayTop=0
}

function MolagKenaTracker:Initialize()
	EVENT_MANAGER:RegisterForEvent(MolagKenaTracker.name, EVENT_ACTION_LAYER_PUSHED, MolagKenaTracker.OnActionLayerChange)
	EVENT_MANAGER:RegisterForEvent(MolagKenaTracker.name, EVENT_ACTION_LAYER_POPPED, MolagKenaTracker.OnActionLayerChange)
	EVENT_MANAGER:RegisterForUpdate(MolagKenaTracker.name, 500, MolagKenaTracker.UpdateWindow)
end

-- When the different layers of the screen are changed - quickslotting, settings, main display, etc.
function MolagKenaTracker.OnActionLayerChange(eventCode, layerIndex, activeLayerIndex)
	MolagKenaTrackerWindow:SetHidden(activeLayerIndex > 2)
end

-- Loads the addon; only hit once
function MolagKenaTracker.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads; but we only care about when our own addon loads.
	if addonName ~= MolagKenaTracker.name then
		return
	end

	MolagKenaTracker.SV = ZO_SavedVars:New("MolagKenaTrackerSettings", 1.0, "Settings", MolagKenaTracker.defaults)
	MolagKenaTracker:InitializeAddonMenu()

	EVENT_MANAGER:UnregisterForEvent(MolagKenaTracker.name, EVENT_ADD_ON_LOADED)

	MolagKenaTracker:Initialize()
	MolagKenaTracker:InitControls()
end

-- Creates the addon settings menu
function MolagKenaTracker:InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Molag Kena Tracker",
		displayName = "|c66ccffMolag Kena Tracker",
		author = "|c4779ce@aldericon|r",
		version = string.format("%.1f", MolagKenaTracker.version),
		registerForRefresh = true,
		registerForDefaults = true
	}

	local optionsPanel = self.LAM2:RegisterAddonPanel("MolagKenaTracker_Companion", panelData)
	local optionsData = {}

	table.insert(optionsData, {
		type = "description",
		text = "A simple tracker for knowing when your Molag Kena procs.",
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

	self.LAM2:RegisterOptionControls("MolagKenaTracker_Companion", optionsData)	
end

-- Saves the positioning of the display window
function MolagKenaTracker.DisplayOnMoveStop()
	MolagKenaTracker.SV.displayLeft = MolagKenaTrackerWindow:GetLeft();
	MolagKenaTracker.SV.displayTop = MolagKenaTrackerWindow:GetTop();
end

-- Setting the positions of the display, popup and purge indicator
function MolagKenaTracker:LoadPositions()
	MolagKenaTrackerWindow:ClearAnchors();
	MolagKenaTrackerWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MolagKenaTracker.SV.displayLeft, MolagKenaTracker.SV.displayTop);

	MolagKenaTrackerWindow:SetMouseEnabled(MolagKenaTracker.SV.unlocked) 
	MolagKenaTrackerWindow:SetMovable(MolagKenaTracker.SV.unlocked)

	MolagKenaTrackerWindow_Timer:SetFont("$(MEDIUM_FONT)|" .. 30)
end

-- As settings are changed, hides or displays various features
function MolagKenaTracker:InitControls()
	MolagKenaTracker:LoadPositions()
end

-- Update th display window
function MolagKenaTracker.UpdateWindow()
	if MolagKenaTracker.SV.unlocked == false then
		MolagKenaTrackerWindow:SetHidden(true)
	end

	for buffIndex = 1, GetNumBuffs('player') do
		local buffName, timeStarted, timeEnding = GetUnitBuffInfo('player', buffIndex)
		local buffName = zo_strformat("<<1>>", buffName)

		if buffName == 'Overkill' then
			local currentTimeStamp = GetGameTimeMilliseconds() / 1000
			local timeLeft = timeEnding - currentTimeStamp

			MolagKenaTrackerWindow_Timer:SetText(string.format("%.0f", timeLeft))

			if timeLeft > 0 then
				MolagKenaTrackerWindow:SetHidden(false)
			else
				MolagKenaTrackerWindow:SetHidden(true)
			end
		end
	end
end

-- Update the display's icons

-- so that ESO can register the addon
EVENT_MANAGER:RegisterForEvent(MolagKenaTracker.name, EVENT_ADD_ON_LOADED, MolagKenaTracker.OnAddOnLoaded)