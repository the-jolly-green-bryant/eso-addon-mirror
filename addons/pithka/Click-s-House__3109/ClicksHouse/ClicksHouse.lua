ClicksHouse = {}

ClicksHouse.name = "ClicksHouse"
ClicksHouse.version = 2.0

function ClicksHouseOnAddOnLoaded(event, addonName)
    if addonName ~= ClicksHouse.name then return end
    EVENT_MANAGER:UnregisterForEvent(ClicksHouse.name, EVENT_ADD_ON_LOADED)
    SLASH_COMMANDS["/click"] = function() JumpToSpecificHouse('@clicktoselect', 47) end
end
EVENT_MANAGER:RegisterForEvent(ClicksHouse.name, EVENT_ADD_ON_LOADED, ClicksHouseOnAddOnLoaded)