LogToggler = LogToggler or {}

LogToggler.name = "LogToggler"
LogToggler.savedVars = { }

function OnAddOnLoaded(eventCode, addOnName)
	if (addOnName ~= "LogToggler") then return end

    LogToggler.savedVars = ZO_SavedVars:NewAccountWide("LogToggler_Data", 1, nil, {})

	ZO_CreateStringId("SI_BINDING_NAME_LT_TOGGLE_ENCOUNTERLOG", "LogToggler")

    LogToggler.loadSavedData()
    LogToggler.createButton()
    LogToggler.createSettings()

    EVENT_MANAGER:UnregisterForEvent(LogToggler.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(LogToggler.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
