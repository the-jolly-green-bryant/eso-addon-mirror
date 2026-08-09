-- Just Do It Directly
-- Author: @HuahTu

-- Create the addon class object
local myScope = {}

-- Constants
myScope.NAME = "JustDoItDirectly"

-- Semi-global variables
myScope.debug = true

-- Typical crafted item info
-- local name, icon, stack, sellPrice, meetsUsageRequirement, equipType, itemType, itemStyle, displayQuality,
--                                          itemSoundCategory, itemInstanceId = GetLastCraftingResultItemInfo(i)

local function debugLog(message)
    if (not myScope.debug)
    then
        return
    end
    d("|c88FFFF[JustDoItDirectly]|r " .. tostring(message))
end

local function forceLog(message)
    d("|c88FFFF[JustDoItDirectly]|r " .. tostring(message))
end

local function onActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(myScope.NAME, EVENT_PLAYER_ACTIVATED)
    debugLog("2026/8/9 11:01 TAIPEI")
    if ZO_GamepadAlchemy then
        debugLog("ZO_GamepadAlchemy available")
    end
    if GAMEPAD_ALCHEMY_ROOT_SCENE then
        debugLog("GAMEPAD_ALCHEMY_ROOT_SCENE available")
    end
    if GAMEPAD_ALCHEMY then
        debugLog("GAMEPAD_ALCHEMY available")
    end
    debugLog("Check end")
end

EVENT_MANAGER:RegisterForEvent(myScope.NAME, EVENT_PLAYER_ACTIVATED, onActivated)

local function onCraftComplete(event, station)
    if((station ~= CRAFTING_TYPE_ENCHANTING) and (station ~= CRAFTING_TYPE_ALCHEMY)) then
        return
    end
    local numItemsGained, penaltyApplied = GetNumLastCraftingResultItemsAndPenalty()
    if(numItemsGained == 0) then
        return
    end

    for i = 1, numItemsGained do
        local name, _, _, _, _, _, itemType = GetLastCraftingResultItemInfo(i)
        debugLog(name .. " crafted");
        if(itemType == ITEMTYPE_POTION_BASE) then
            debugLog("Potion");
        elseif(itemType == ITEMTYPE_POTION_BASE) then
            debugLog("Potion");
        elseif(itemType == ITEMTYPE_GLYPH_WEAPON) then
            debugLog("GLYPH_WEAPON");
        elseif(itemType == ITEMTYPE_GLYPH_ARMOR) then
            debugLog("GLYPH_ARMOR");
        elseif(itemType == ITEMTYPE_GLYPH_JEWELRY) then
            debugLog("GLYPH_JEWELRY");
        else
            debugLog("Other types");
        end
    end

end

local function selectAndMakePotion(tabData)
    debugLog("selectAndMakePotion")
end

local function setupCraftingHooks()
    EVENT_MANAGER:RegisterForEvent(myScope.NAME, EVENT_CRAFT_COMPLETED, onCraftComplete)
end

local function setupAlchemyPanel()
    debugLog("setupAlchemyPanel")
    local submenu = WINDOW_MANAGER:CreateControl("JDID", ZO_GamepadAlchemyTopLevel, CT_CONTROL)
    submenu:SetAnchorFill(ZO_GamepadAlchemyTopLevel)
    -- submenu:SetHidden(true)
    local fragment = ZO_FadeSceneFragment:New(submenu)
    GAMEPAD_ALCHEMY_ROOT_SCENE:AddFragment(fragment)
end

local function setupAlchemyHooks()
    -- securePostHook(ZO_GamepadAlchemy, "Initialize", setupAlchemyPanel)
    CALLBACK_MANAGER:RegisterCallback("GamepadAlchemyInitialized", setupAlchemyPanel)
end

local function onAddOnLoaded(eventCode, addOnName)
    if(addOnName ~= myScope.NAME) then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(myScope.NAME, EVENT_ADD_ON_LOADED)

    setupCraftingHooks()
    -- setupAlchemyHooks()
    setupAlchemyPanel()
end

EVENT_MANAGER:RegisterForEvent(myScope.NAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)