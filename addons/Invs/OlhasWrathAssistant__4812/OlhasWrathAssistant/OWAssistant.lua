OWAssistant = {}
OWAssistant.name = "OWAssistant"

local ADDON_NAME = "OlhasWrathAssistant"

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_ADD_ON_LOADED
    )

    OWA_Assistant_Initialize()
end

ZO_CreateStringId(
    "SI_BINDING_NAME_OWA_DECONSTRUCT",
    "Deconstruct"
)

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)