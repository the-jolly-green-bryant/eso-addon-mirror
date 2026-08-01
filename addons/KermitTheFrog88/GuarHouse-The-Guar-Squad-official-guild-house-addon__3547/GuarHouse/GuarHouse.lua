GuarHouse = {}

GuarHouse.name = "GuarHouse"
GuarHouse.version = 1.0

function GuarHouseOnAddOnLoaded(event, addonName)
    if addonName ~= GuarHouse.name then return end
    EVENT_MANAGER:UnregisterForEvent(GuarHouse.name, EVENT_ADD_ON_LOADED)
    SLASH_COMMANDS["/guar"] = function() JumpToSpecificHouse('@CaptainPanic', 91) end
end
EVENT_MANAGER:RegisterForEvent(GuarHouse.name, EVENT_ADD_ON_LOADED, GuarHouseOnAddOnLoaded)