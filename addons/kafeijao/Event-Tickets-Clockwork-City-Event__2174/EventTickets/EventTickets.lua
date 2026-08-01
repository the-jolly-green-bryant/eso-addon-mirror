-------------------------------------
-- Addon data.
-------------------------------------
EventTickets = EventTickets or {}
EventTickets.name = "EventTickets"
EventTickets.slashComandName = "/et"

--------------------
-- Witches Festival
--------------------
EventTickets.eventTicketWitchestFestivalCooldown = 72000 --20 hours
EventTickets.goldenPlunderSkullCooldown = 72000 --20 hours
EventTickets.goldenPlunderSkullIds = {
    [141771] = true, -- Arena Final Boss
    [141772] = true, -- Dark Anchor/Geyser Boss
    [141773] = true, -- Delve Boss
    [141774] = true, -- Dungeon Final Boss
    [141775] = true, -- Public Dungeon / Quests Boss
    [141776] = true, -- Trial Final Boss
    [141777] = true, -- World Boss
}
EventTickets.goldenPlunderSkullNames = {
    [141771] = "Arena Final Boss",
    [141772] = "Dark Anchor/Geyser Boss",
    [141773] = "Delve Boss",
    [141774] = "Dungeon Final Boss",
    [141775] = "Public Dungeon / Quests Boss",
    [141776] = "Trial Final Boss",
    [141777] = "World Boss",
}

--------------------
-- Clockwork City Event
--------------------
EventTickets.eventTicketResetSecondsUTCSinceMidnight = 6*60*60 -- 6AM UTC


EventTickets.variableVersion = 2
EventTickets.Default = {
    left = 275,
    top = 25,
    goldenSkullCooldowns = {},
    goldenSkullHidden = true
}


-------------------------------------
-- Initialize the addon.
-------------------------------------
function EventTickets.OnAddOnLoaded(_, addonName)
    if addonName == EventTickets.name then
        EventTickets:Initialize()
        EVENT_MANAGER:UnregisterForEvent(EventTickets.name, EVENT_ADD_ON_LOADED)
    end
end


-------------------------------------
-- Load saved variables and register the event listeners.
-------------------------------------
function EventTickets:Initialize()
    EventTickets.savedVariables = ZO_SavedVars:NewAccountWide("EventTicketsVars", EventTickets.variableVersion, GetWorldName(), EventTickets.Default)

    EVENT_MANAGER:RegisterForEvent(EventTickets.name, EVENT_CURRENCY_UPDATE, EventTickets.onCurrencyUpdate)
    --EVENT_MANAGER:RegisterForEvent(EventTickets.name, EVENT_LOOT_RECEIVED, EventTickets.onLootReceived);

    EventTickets.initiliazeUI()
    EventTickets.initializeSlashCommands()
end


-------------------------------------
-- UI Initializations.
-------------------------------------

-------------------------------------
-- Initializes the main window UI.
-------------------------------------
function EventTickets.initiliazeUI()

    -- Main Window
    EventTicketsWindow:ClearAnchors()
    EventTicketsWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, EventTickets.savedVariables.left, EventTickets.savedVariables.top)
    local fragment = ZO_HUDFadeSceneFragment:New(EventTicketsWindow)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)


    -- Golden Skull Plunder List
    --EventTickets.initializeGoldenPlunderSkullUI()

    -- Start UI updates loop
    local function updateTimers()
        EventTickets.updateEventTicketTimer()
        --EventTickets.updateGoldenPlunderSkullTimer()
    end
    EVENT_MANAGER:RegisterForUpdate('EventTickets_Poll', 1000, updateTimers)
end

-------------------------------------
-- Initializes the Golden Plunder Skull UI.
-------------------------------------
function EventTickets.initializeGoldenPlunderSkullUI()
    EventTicketsWindowSkullListHolder:SetHidden(EventTickets.savedVariables.goldenSkullHidden)
    EventTicketsWindowSkullListHolder.skullLine = {}

    -- Order Golden Plunder Skull IDs
    local ordered_keys = {}
    for k in pairs(EventTickets.goldenPlunderSkullIds) do
        table.insert(ordered_keys, k)
    end
    table.sort(ordered_keys)

    local predecessor
    for i = 1, #ordered_keys do
        local k, _ = ordered_keys[i], EventTickets.goldenPlunderSkullIds[ordered_keys[i]]

        local record = CreateControlFromVirtual("EventTicketsWindowSkullListHolder_Row_", EventTicketsWindowSkullListHolder, "EventTicketsSkullTimerTemplate", k)

        record.timer = record:GetNamedChild("Timer")
        record:GetNamedChild("Name"):SetText(EventTickets.goldenPlunderSkullNames[k])

        if predecessor == nil then
            record:SetAnchor(TOPLEFT, EventTicketsWindowSkullListHolder, TOPLEFT, 0, 0)
            record:SetAnchor(TOPRIGHT, EventTicketsWindowSkullListHolder, TOPRIGHT, 0, 0)
        else
            record:SetAnchor(TOPLEFT, predecessor, BOTTOMLEFT, 0, EventTicketsWindowSkullListHolder.rowHeight)
            record:SetAnchor(TOPRIGHT, predecessor, BOTTOMRIGHT, 0, EventTicketsWindowSkullListHolder.rowHeight)
        end

        EventTicketsWindowSkullListHolder.skullLine[k] = record
        predecessor = record
    end

    EventTicketsWindowSkullListHolder.skullLine[141772].timer:SetText('Available')
end

-------------------------------------
-- Slash commands listeners.
-------------------------------------
function EventTickets.initializeSlashCommands()
    SLASH_COMMANDS[EventTickets.slashComandName] = EventTickets.toggleWindow
    SLASH_COMMANDS[EventTickets.slashComandName .. 'resettimer'] = EventTickets.setSavedVariablesEventTicketTimer
end



-------------------------------------
-- Saved Variables Data Updates.
-------------------------------------

-------------------------------------
-- Updates the Event Ticket timer on the saved variables.
-------------------------------------
function EventTickets.setSavedVariablesEventTicketTimer()
    local seconds_until_utc_midnight = (24*60*60) - EventTickets.GetSecondsSinceUTCMidnight()
    EventTickets.savedVariables.cooldownEventTicket = os.time() + ((seconds_until_utc_midnight + EventTickets.eventTicketResetSecondsUTCSinceMidnight) % (24*60*60))

    -- Witches Festival Skull Event
    --[[ EventTickets.savedVariables.cooldownEventTicket = os.time()]]

    EventTickets.updateEventTicketTimer()
end

-------------------------------------
-- Updates the Golden Plunder skull timer on the saved variables.
-------------------------------------
function EventTickets.setSavedVariablesGoldenPlunderSkullTimer(plunderSkullId)
    EventTickets.savedVariables.goldenSkullCooldowns[plunderSkullId] = os.time()
    EventTickets.updateGoldenPlunderSkullTimer()
end



-------------------------------------
-- EVENT Listeners.
-------------------------------------

-------------------------------------
-- Listen if Event Ticket currency was received.
-------------------------------------
function EventTickets.onCurrencyUpdate(_, currencyType, currencyLocation, newAmount, oldAmount, reason)

    if reason == CURRENCY_CHANGE_REASON_QUESTREWARD and currencyType == CURT_EVENT_TICKETS and currencyLocation == CURRENCY_LOCATION_ACCOUNT and newAmount > oldAmount then
        EventTickets.setSavedVariablesEventTicketTimer()
    end

    -- Witches Festival Skull Event
    --[[ if reason == CURRENCY_CHANGE_REASON_LOOT and currencyType == CURT_EVENT_TICKETS and currencyLocation == CURRENCY_LOCATION_ACCOUNT and newAmount > oldAmount then
        EventTickets.setSavedVariablesEventTicketTimer()
    end ]]
end

-------------------------------------
-- Listen if loot was received.
-------------------------------------
function EventTickets.onLootReceived(_, _, _, _, _, _, self, _, _, itemId)

    -- Witches Festival Skull Event
    --[[if self and EventTickets.goldenPlunderSkullIds[itemId] then
        EventTickets.setSavedVariablesGoldenPlunderSkullTimer(itemId)
    end]]
end



-------------------------------------
-- UI Updates.
-------------------------------------

-------------------------------------
-- Update the UI info for the event ticket cooldown.
-------------------------------------
function EventTickets.updateEventTicketTimer()
    local cooldown = EventTickets.savedVariables.cooldownEventTicket

    local output = ""

    if cooldown == nil then -- If there is no data from previous
        output = output .. " |cffcc00--|r:|cffcc00--|r:|cffcc00--|r"

    else
        local cooldownRemainingSeconds = os.difftime(cooldown, os.time())

        -- Witches Festival Skull Event
        --[[local cooldownRemainingSeconds = os.difftime(cooldown + EventTickets.eventTicketWitchestFestivalCooldown, os.time())]]

        if cooldownRemainingSeconds <= 0 then -- If the event ticket is out of cooldown
            output = output .. " |c77FF00Available|r"

        else -- If the event ticket is on cooldown
            local timediff, _ = FormatTimeSeconds(cooldownRemainingSeconds, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)

            output = output .. "|cE9C62A" .. timediff
        end
    end

    EventTicketsWindowLabel:SetText(output)
end

-------------------------------------
-- Update the UI info for the witches festival golden plunder skulls cooldown.
-------------------------------------
function EventTickets.updateGoldenPlunderSkullTimer()
    for k in pairs(EventTickets.goldenPlunderSkullIds) do
        local cooldown = EventTickets.savedVariables.goldenSkullCooldowns[k]

        local output = ""

        if cooldown == nil then -- If there is no data from previous
            output = output .. " |cffcc00--|r:|cffcc00--|r:|cffcc00--|r"

        else
            local cooldownRemainingSeconds = os.difftime(cooldown + EventTickets.goldenPlunderSkullCooldown, os.time())

            if cooldownRemainingSeconds <= 0 then -- If the golden plunder skull is out of cooldown
                output = output .. " |c77FF00Available|r"

            else -- If the golden plunder skull is on cooldown
                local timediff, _ = FormatTimeSeconds(cooldownRemainingSeconds, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)

                output = output .. "|cE9C62A" .. timediff
            end
        end

        EventTicketsWindowSkullListHolder.skullLine[k].timer:SetText(output)
    end
end



-------------------------------------
-- UI Functions.
-------------------------------------

-------------------------------------
-- UI Window toggle.
-------------------------------------
function EventTickets.toggleWindow()
    EventTicketsWindow:SetHidden(not EventTicketsWindow:IsHidden())
end

-------------------------------------
-- UI golden plunder skulls toggle.
-------------------------------------
function EventTickets.toggleDropdown()

    -- Witches Festival Skull Event
    --[[EventTicketsWindowSkullListHolder:SetHidden(not EventTicketsWindowSkullListHolder:IsHidden())
    EventTickets.savedVariables.goldenSkullHidden = EventTicketsWindowSkullListHolder:IsHidden()]]
end

-------------------------------------
-- Updates the UI coordinates to the saved variables.
-------------------------------------
function EventTickets.SaveUICoordinates()
    EventTickets.savedVariables.left = EventTicketsWindow:GetLeft()
    EventTickets.savedVariables.top = EventTicketsWindow:GetTop()
end



-------------------------------------
-- Util Functions.
-------------------------------------

-------------------------------------
-- Get the seconds since the timezone UTC's midnight.
-------------------------------------
function EventTickets.GetSecondsSinceUTCMidnight()
    local now = os.time()
    local timezone = os.difftime(now, os.time(os.date("!*t", now)))
    local utcdate = os.date("!*t", timezone)
    local localdate = os.date("*t", timezone)
    localdate.isdst = false
    local offset = os.difftime(os.time(localdate), os.time(utcdate))
    local seconds_since_utc_midnight = ((GetSecondsSinceMidnight() + offset) + 86400) % 86400
    return seconds_since_utc_midnight
end



-------------------------------------
-- Initialization Register.
-------------------------------------
EVENT_MANAGER:RegisterForEvent(EventTickets.name, EVENT_ADD_ON_LOADED, EventTickets.OnAddOnLoaded)