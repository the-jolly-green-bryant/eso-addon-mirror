ToggleQuestTracker = {}
local addon = { name = "ToggleQuestTracker" }

--------------------------------------------------------------------------------

local questTrackerHidden = true

--------------------------------------------------------------------------------

local function Initialize()
	ZO_FocusedQuestTrackerPanel:SetHidden(true)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_QUEST_TRACKER", "Show/Hide quest tracker")
	SLASH_COMMANDS['/togglequesttracker'] = function()
		ZO_FocusedQuestTrackerPanel:SetHidden(questTrackerHidden)
		questTrackerHidden = not questTrackerHidden
	end
end

local function OnAddOnLoaded(event, addonName)
	if addonName ~= addon.name then return end
	Initialize()
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)