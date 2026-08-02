-- Just Do It Again
-- Author: @HuahTu

-- Create the addon class object
local myScope = {}

-- Constants
myScope.NAME = "JustDoItAgain"

-- Semi-global variables
myScope.debug = true

-- Typical CollectibleInfo
-- local name, desc, icon, lockedIcon, unlocked, purchasable, isActive, categoryType, hint = GetCollectibleInfo(collectibleID)

local function debugLog(message)
    if (not myScope.debug)
    then
        return
    end
    d("|c88FFFF[JustDoItAgain]|r " .. tostring(message))
end

local function forceLog(message)
    d("|c88FFFF[JustDoItAgain]|r " .. tostring(message))
end

local function onActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(myScope.NAME, EVENT_PLAYER_ACTIVATED)
    debugLog("2026/8/1 20:22 TAIPEI")
end

EVENT_MANAGER:RegisterForEvent(myScope.NAME, EVENT_PLAYER_ACTIVATED, onActivated)

local function onCraftComplete(event, station)
    if((station ~= CRAFTING_TYPE_ENCHANTING) and (station ~= CRAFTING_TYPE_ALCHEMY))
    then
        return
    end
    local numItemsGained, penaltyApplied = GetNumLastCraftingResultItemsAndPenalty()
    if(numItemsGained == 0)
    then
        return
    end

    for i = 1, numItemsGained do
        local name = GetLastCraftingResultItemInfo(i)
        debugLog(name .. " crafted");
    end

end

local function setupCraftingHooks()
    EVENT_MANAGER:RegisterForEvent(myScope.NAME, EVENT_CRAFT_COMPLETED, onCraftComplete)
end

local function onAddOnLoaded(eventCode, addOnName)
    if(addOnName ~= myScope.NAME)
    then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(myScope.NAME, EVENT_ADD_ON_LOADED)

    setupCraftingHooks()
end

EVENT_MANAGER:RegisterForEvent(myScope.NAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)