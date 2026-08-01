
EVENT_MANAGER:RegisterForEvent("SurveyZoneListLoad", EVENT_ADD_ON_LOADED, SurveyZoneList.Events.onLoaded)

EVENT_MANAGER:RegisterForEvent("SurveyZoneListLoadScreen", EVENT_PLAYER_ACTIVATED, SurveyZoneList.Events.onLoadScreen)

EVENT_MANAGER:RegisterForEvent("SurveyZoneListMoveItem", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SurveyZoneList.Events.onMoveItem)
EVENT_MANAGER:AddFilterForEvent("SurveyZoneListMoveItem", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
EVENT_MANAGER:AddFilterForEvent("SurveyZoneListMoveItem", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

EVENT_MANAGER:RegisterForEvent("SurveyZoneClientInteractResult", EVENT_CLIENT_INTERACT_RESULT, SurveyZoneList.Events.onClientInteract)
EVENT_MANAGER:RegisterForEvent("SurveyZoneListLootReceived", EVENT_LOOT_RECEIVED, SurveyZoneList.Events.onLootReceived)

EVENT_MANAGER:RegisterForEvent("SurveyZoneListOpenBank", EVENT_OPEN_BANK, SurveyZoneList.Events.onOpenBank)
EVENT_MANAGER:RegisterForEvent("SurveyZoneListOpenBank", EVENT_CLOSE_BANK, SurveyZoneList.Events.onCloseBank)

ZO_PostHook(RETICLE, "TryHandlingInteraction", SurveyZoneList.Events.reticleTryHandlingInteraction)

-- Define slash commands to show/hide the gui
if SLASH_COMMANDS["/szl"] == nil then
    SLASH_COMMANDS["/szl"] = SurveyZoneList.Events.commandToggleGUI
end

SLASH_COMMANDS["/surveyzonelist"] = SurveyZoneList.Events.commandToggleGUI
