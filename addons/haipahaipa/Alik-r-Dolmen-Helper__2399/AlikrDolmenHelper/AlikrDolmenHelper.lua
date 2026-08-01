local em = GetEventManager()

if ADH == nil then ADH = {} end
local ADH = ADH

ADH.name = "AlikrDolmenHelper"
ADH.version = "0.1.0"

local Wayshrines = {
    [59] = { location= "north", name= "Aswala Stables Wayshrine", clockwise = 60, counterclockwise = 155},
    [60] = { location= "east", name= "Shrikes' Aerie Wayshrine", clockwise = 155, counterclockwise = 59},
    [155] = { location= "south", name= "Goat's Head Oasis Wayshrine", clockwise = 59, counterclockwise = 60}
}

local Directions = {
    clockwise = 1,
    counterclockwise = -1
}

function ADH.Print(message, ...)
    df("[%s] %s", "ADH", message:format(...))
end

function ADH.WayshrineInteractionStart(eventCode, currentWayshrine)
    if Wayshrines[currentWayshrine] then
        if ADH.db.autoTravelActive then
            local nextWayshrine = nil
            if ADH.db.direction == Directions.clockwise then
                nextWayshrine = Wayshrines[currentWayshrine].clockwise
            else
                nextWayshrine = Wayshrines[currentWayshrine].counterclockwise
            end
            FastTravelToNode(nextWayshrine)
        end
    end
end

function ADH.ToggleAutoTravel()
    ADH.db.autoTravelActive = not ADH.db.autoTravelActive
    if ADH.db.autoTravelActive then
        ADH.Print(GetString(SI_ALIKR_DOLMEN_HELPER_TOGGLE_AUTO_TRAVEL_ON))
    else
        ADH.Print(GetString(SI_ALIKR_DOLMEN_HELPER_TOGGLE_AUTO_TRAVEL_OFF))
    end
end

function ADH.ToggleDirection()
    if ADH.db.direction == Directions.clockwise  then
        ADH.db.direction = Directions.counterclockwise 
        ADH.Print(GetString(SI_ALIKR_DOLMEN_HELPER_DIRECTION_COUNTERCLOCKWISE))
    else
        ADH.db.direction = Directions.clockwise 
        ADH.Print(GetString(SI_ALIKR_DOLMEN_HELPER_DIRECTION_CLOCKWISE))
    end
end

function ADH.SlashHandler(option)
    local options = {}
    local searchResult = { string.match(option,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
    
    if #options == 0 or options[1] == "help" then
        ADH.Print(GetString(SI_ALIKR_DOLMEN_HELPER_SLASH_HELP_0).."%s", ADH.version)
        ADH.Print(GetString(SI_ALIKR_DOLMEN_HELPER_SLASH_HELP_1))
        ADH.Print(GetString(SI_ALIKR_DOLMEN_HELPER_SLASH_HELP_2))
        ADH.Print(GetString(SI_ALIKR_DOLMEN_HELPER_SLASH_HELP_3))
        ADH.Print(GetString(SI_ALIKR_DOLMEN_HELPER_SLASH_HELP_4))
    elseif options[1] == "toggle" then
        ADH.ToggleAutoTravel()
    elseif options[1] == "direction" then
        ADH.ToggleDirection()
    end
end

function ADH.Initialize(event, addon)
    if addon ~= ADH.name then return end
    em:UnregisterForEvent(ADH.name, EVENT_ADD_ON_LOADED)

    local defaultSettings = {
        autoTravelActive = false,
        direction = Directions.clockwise
    }
    ADH.db = ZO_SavedVars:NewAccountWide("AlikrDolmenHelper_Save", 1, nil, defaultSettings)

    em:RegisterForEvent(ADH.name, EVENT_START_FAST_TRAVEL_INTERACTION, ADH.WayshrineInteractionStart)
    
    SLASH_COMMANDS["/adh"] = ADH.SlashHandler
end

em:RegisterForEvent(ADH.name, EVENT_ADD_ON_LOADED, ADH.Initialize)