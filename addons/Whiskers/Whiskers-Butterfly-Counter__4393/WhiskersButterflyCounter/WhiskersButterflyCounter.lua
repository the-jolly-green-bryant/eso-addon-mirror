local butterflies  = 0
local wings        = 0
local lastLootTime = 0
local isTracking   = true

local ADDON_NAME   = "WhiskersButterflyCounter"

------------------------------------------------------------
-- Core Loot Processor
------------------------------------------------------------
local function OnLootReceived(_, _, itemLink, quantity)
    if not isTracking or not itemLink then return end

    local itemName = GetItemLinkName(itemLink):lower()
    local currentTime = GetFrameTimeMilliseconds()

    local isWing = string.find(itemName, "butterfly wing")
    local isPart = string.find(itemName, "insect parts")

    if isWing or isPart then
        -- Count the butterfly (throttled)
        if (currentTime - lastLootTime) > 300 then
            butterflies  = butterflies + 1
            lastLootTime = currentTime
        end

        -- Count wings
        if isWing then
            wings = wings + quantity
        end
    end
end

------------------------------------------------------------
-- Reporting & Commands
------------------------------------------------------------
local function PrintSummary()
    if butterflies == 0 then
        d("|cFFD700[Butterfly Counter]|r No insects caught yet this session.")
        return
    end

    d(" ")
    d("|cFFFF00=== SESSION SUMMARY ===|r")
    d(string.format("Insects Looted: %d", butterflies))
    d(string.format("Wings Harvested: %d", wings))

    local rate = (wings / butterflies) * 100
    d(string.format("|c00FF00Harvest Rate:   %.1f%%|r", rate))
    d("|cFFFF00=======================|r")
end

------------------------------------------------------------
-- Player Activation / Deactivation
------------------------------------------------------------
local function OnPlayerDeactivated()
    if isTracking and butterflies > 0 then
        PrintSummary()
    end
end

local function OnPlayerActivated()
    d("|cFFD700[Butterfly Counter]|r Addon loaded. Tracking active. Use /butterflies_stop to finish.")
end

------------------------------------------------------------
-- Initialization & Registration (ESOUI‑compliant)
------------------------------------------------------------
local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    --------------------------------------------------------
    -- Register Slash Commands (required by ESOUI guidelines)
    --------------------------------------------------------
    SLASH_COMMANDS["/butterflies"] = PrintSummary

    SLASH_COMMANDS["/butterflies_start"] = function()
        butterflies  = 0
        wings        = 0
        lastLootTime = 0
        isTracking   = true
        d("|cFFD700[Butterfly Counter]|r Fresh session started! Tracking is now active.")
    end

    SLASH_COMMANDS["/butterflies_stop"] = function()
        if isTracking then
            d("|cFFD700[Butterfly Counter]|r Stopping session...")
            PrintSummary()
            isTracking = false
        else
            d("|cFFD700[Butterfly Counter]|r Tracking is already stopped.")
        end
    end

    --------------------------------------------------------
    -- Register Events (after addon load)
    --------------------------------------------------------
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_LOOT_RECEIVED, OnLootReceived)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_LOOT_RECEIVED, REGISTER_FILTER_IS_LOCAL_PLAYER, true)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, REGISTER_FILTER_IS_LOCAL_PLAYER, true)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_PLAYER_DEACTIVATED, REGISTER_FILTER_IS_LOCAL_PLAYER, true)

    d("|cFFD700[Butterfly Counter]|r Addon initialized successfully.")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
