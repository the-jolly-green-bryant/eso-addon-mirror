-- Writcraft 1.1.0
-- Licensed under CC-BY-NC-SA-4.0

local WRITCRAFT = "Writcraft"

local previousQuestTrackerPanelAnchor

function WritCraft_CycleFocusedQuest()
    local IGNORE_SCENE_RESTRICTION = true
    QUEST_TRACKER:AssistNext(IGNORE_SCENE_RESTRICTION)
end

local keybindStripDescriptor = {
    alignment = KEYBIND_STRIP_ALIGN_LEFT,

    {
        -- with API 100018, the quaternary keybind has been coopted by the game
        -- need to find a more future-proof method, like adding a new custom binding
        name = GetString(SI_QUEST_JOURNAL_CYCLE_FOCUSED_QUEST),
        keybind = "WRITCRAFT_CYCLE_FOCUSED_QUEST",

        callback = WritCraft_CycleFocusedQuest,
        visible = function()
            return GetNumJournalQuests() >= 2
        end
    },
}

local function Writcraft_Enable()
    previousQuestTrackerPanelAnchor = {ZO_FocusedQuestTrackerPanel:GetAnchor(0)}
    table.remove(previousQuestTrackerPanelAnchor, 1) -- Remove isValid bool

    ZO_FocusedQuestTrackerPanel:ClearAnchors()
    ZO_FocusedQuestTrackerPanel:SetAnchor(TOPLEFT, ZO_SharedThinLeftPanelBackground, TOPRIGHT, 50, -35)
end

local function Writcraft_Disable()
    ZO_FocusedQuestTrackerPanel:ClearAnchors()
    ZO_FocusedQuestTrackerPanel:SetAnchor(unpack(previousQuestTrackerPanelAnchor))
end

EVENT_MANAGER:RegisterForEvent(WRITCRAFT, EVENT_ADD_ON_LOADED, function(eventCode, addOnName)
    if (addOnName == WRITCRAFT) then
        EVENT_MANAGER:RegisterForEvent(WRITCRAFT, EVENT_CRAFTING_STATION_INTERACT, Writcraft_Enable)
        EVENT_MANAGER:RegisterForEvent(WRITCRAFT, EVENT_END_CRAFTING_STATION_INTERACT, Writcraft_Disable)
        EVENT_MANAGER:UnregisterForEvent(WRITCRAFT, EVENT_ADD_ON_LOADED)

	ZO_CreateStringId("SI_BINDING_NAME_WRITCRAFT_CYCLE_FOCUSED_QUEST", "Cycle Quest")

	local crafting_scenes = { SMITHING_SCENE, ALCHEMY_SCENE, ENCHANTING_SCENE, PROVISIONER_SCENE }
	-- SMITHING_SCENE includes clothing and wood too

	for _i, scene in pairs(crafting_scenes) do
	    scene:AddFragment(FOCUSED_QUEST_TRACKER_FRAGMENT)
	    scene:RegisterCallback("StateChange",
	        function(oldState, newState)
	            if (newState == SCENE_SHOWING) then
	        	KEYBIND_STRIP:AddKeybindButtonGroup(keybindStripDescriptor)
	            elseif (newState == SCENE_HIDDEN) then
	        	KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindStripDescriptor)
	            end
	        end)
	end
    end
end)
