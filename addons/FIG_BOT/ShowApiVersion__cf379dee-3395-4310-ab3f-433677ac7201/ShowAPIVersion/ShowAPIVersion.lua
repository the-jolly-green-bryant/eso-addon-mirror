local addonName = "ShowAPIVersion"

local function PrintAPI()
    d("ESO API Version: " .. tostring(GetAPIVersion()))
end

local function OnAddOnLoaded(event, name)
    if name ~= addonName then return end
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

    -- Print on load
    PrintAPI()

    -- Slash command
    SLASH_COMMANDS["/api"] = function()
        PrintAPI()
    end
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)