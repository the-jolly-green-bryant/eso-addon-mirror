-- Keep ONE for Research
-- Author: @HuahTu

-- Create the addon class object
local myScope = {}

-- Constants
myScope.NAME = "KeepOne4Research"
-- 1: Smithing, 2: Clothing, 6: Wooden, 7: Jewelery
myScope.EXTRACT_CRAFTING_TYPES = {1, 2, 6, 7}

-- Semi-global variables
myScope.originalGenerateCraftingInventoryEntryData = nil
myScope.originalNpcGenerateCraftingInventoryEntryData = nil
myScope.deconstructPanelRefreshing = false
myScope.npcDeconstructPanelRefreshing = false
myScope.researchableItems = {}
myScope.debug = false

local function debugLog(message)
    if (not myScope.debug)
    then
        return
    end
    d("|c88FFFF[KeepOne4Research]|r " .. tostring(message))
end

local function forceLog(message)
    d("|c88FFFF[KeepOne4Research]|r " .. tostring(message))
end

local function onActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(myScope.NAME, EVENT_PLAYER_ACTIVATED)
    debugLog("2026/5/10 20:29 TAIPEI")
end

EVENT_MANAGER:RegisterForEvent(myScope.NAME, EVENT_PLAYER_ACTIVATED, onActivated)

local function myGetItemFilterType(bagId, slotIndex)
    local filterType = GetItemFilterTypeInfo(bagId, slotIndex)
    if (filterType == ITEMFILTERTYPE_ARMOR)
    then
        return 1
    elseif (filterTypes == ITEMFILTERTYPE_WEAPONS)
    then
        return 2
    else
        return 3
    end
end

local function getResearchInfoForItem(bagId, slotIndex)
    local craftingType = GetCraftingInteractionType()
    for researchLineIndex = 1, GetNumSmithingResearchLines(craftingType)
    do
        local categoryName, _, numTraits = GetSmithingResearchLineInfo(craftingType, researchLineIndex)
        for traitIndex = 1, numTraits do
            if CanItemBeSmithingTraitResearched(bagId, slotIndex, craftingType, researchLineIndex, traitIndex)
            then
                return researchLineIndex, categoryName, traitIndex
            end
        end
    end
    -- Should never be here
    return nil
end

local function getResearchInfoForItemOfType(craftingType, bagId, slotIndex)
    for researchLineIndex = 1, GetNumSmithingResearchLines(craftingType)
    do
        local categoryName, _, numTraits = GetSmithingResearchLineInfo(craftingType, researchLineIndex)
        for traitIndex = 1, numTraits do
            if CanItemBeSmithingTraitResearched(bagId, slotIndex, craftingType, researchLineIndex, traitIndex)
            then
                return researchLineIndex, categoryName, traitIndex
            end
        end
    end
    return nil
end

local function getGeneralResearchInfoForItem(bagId, slotIndex)
    for ndx = 1, 4
    do
        local craftingType = myScope.EXTRACT_CRAFTING_TYPES[ndx]
        local researchLineIndex, categoryName, traitIndex = getResearchInfoForItemOfType(craftingType, bagId, slotIndex)
        if (researchLineIndex)
        then
            return craftingType, researchLineIndex, categoryName, traitIndex
        end
    end
    return nil
end

local function myGenerateCraftingInventoryEntryData(self, bagId, slotIndex, stackCount, slotData)
    local newData = myScope.originalGenerateCraftingInventoryEntryData(self, bagId, slotIndex, stackCount, slotData)
    if (not myScope.deconstructPanelRefreshing)
    then
        return newData
    end

    local itemName = GetItemName(bagId, slotIndex)
    debugLog("newData.name: " .. itemName)
    local researchLine, categoryName, traitIndex = getResearchInfoForItem(bagId, slotIndex)
    -- Consider future extension, max number of traits: 20, max number of researchLine: 20, max quality: 10
    newData.customSortData = newData.customSortData * 4000

    -- No more multi-level sorting for non-researchable items
    if ((not researchLine) or (not traitIndex))
    then
        return newData
    end

    newData.hash = researchLine * 20 + traitIndex

    -- newData.customSortData = newData.customSortData + newData.hash * 10
    -- Higher quality first
    -- newData.customSortData = newData.customSortData + (10 - newData.displayQuality)

    -- Merged above 2 line codes by assumption that, ESO's LUA compiler doesn't optimize them.
    newData.customSortData = newData.customSortData + newData.hash * 10 + (10 - newData.displayQuality)

    if (categoryName and traitIndex)
    then
        debugLog("newData.categoryName: " .. categoryName)
        debugLog("newData.traitIndex: " .. traitIndex)
    end

    myScope.researchableItems[#myScope.researchableItems + 1] = newData

    return newData
end

local function myNpcGenerateCraftingInventoryEntryData(self, bagId, slotIndex, stackCount, slotData)
    local newData = myScope.originalNpcGenerateCraftingInventoryEntryData(self, bagId, slotIndex, stackCount, slotData)
    if (not myScope.npcDeconstructPanelRefreshing)
    then
        return newData
    end

    local itemName = GetItemName(bagId, slotIndex)
    debugLog("newData2.name: " .. itemName)
    local craftingType, researchLine, categoryName, traitIndex = getGeneralResearchInfoForItem(bagId, slotIndex)

    -- Consider future extension, max number of filter types: 5, max number of crafting types: 10,
    -- max number of traits: 20, max number of researchLine: 20, max quality: 10
    newData.customSortData = newData.customSortData * 200000

    -- No more multi-level sorting for non-researchable items
    if ((not researchLine) or (not traitIndex))
    then
        return newData
    end

    local filterType = myGetItemFilterType(bagId, slotIndex)
    newData.hash = craftingType * 400 + researchLine * 20 + traitIndex

    newData.customSortData = newData.customSortData + filterType * 40000
    newData.customSortData = newData.customSortData + newData.hash * 10
    -- Higher quality first
    newData.customSortData = newData.customSortData + (10 - newData.displayQuality)

    myScope.researchableItems[#myScope.researchableItems + 1] = newData

    return newData
end

local function postHandleResearchableItems()
    local traitCnts = {}
    for _, item in pairs(myScope.researchableItems)
    do
        local hash = item.hash
        if (not traitCnts[hash])
        then
            traitCnts[hash] = 1
        else
            traitCnts[hash] = traitCnts[hash] + 1
        end
    end

    for _, item in pairs(myScope.researchableItems)
    do
        local count = traitCnts[item.hash]
        if (count > 1)
        then
            item.text = item.text .. " (" .. count .. ")"
        end
    end

    myScope.researchableItems = {}
end

-- By test, all crafting use the same object and codes for deconstruction
local function setupSmithingDeconstructHooks()
    local extractInventory = SMITHING_GAMEPAD.deconstructionPanel.inventory

    -- By test, SMITHING_GAMEPAD.deconstructionPanel.inventory:Refresh() will be called
    -- 1. When deconstruction panel is opened
    -- 2. When some item(s) is/are deconstructed

    ZO_PreHook(extractInventory, "Refresh", function()
        debugLog("just before Refresh()")
        myScope.deconstructPanelRefreshing = true
        return false
    end)

    myScope.originalGenerateCraftingInventoryEntryData = extractInventory.GenerateCraftingInventoryEntryData
    extractInventory.GenerateCraftingInventoryEntryData = myGenerateCraftingInventoryEntryData

    SecurePostHook(extractInventory, "Refresh", function()
        debugLog("just after Refresh()")
        myScope.deconstructPanelRefreshing = false
        postHandleResearchableItems()
    end)
end

-- This is for deconstruction NPC
local function setupNpcDeconstructHooks()
    ZO_PreHook(ZO_UniversalDeconstructionInventory_Gamepad, "Refresh", function()
        debugLog("just before NPC Refresh()")
        myScope.npcDeconstructPanelRefreshing = true
        return false
    end)

    myScope.originalNpcGenerateCraftingInventoryEntryData = ZO_GamepadCraftingInventory.GenerateCraftingInventoryEntryData
    ZO_GamepadCraftingInventory.GenerateCraftingInventoryEntryData = myNpcGenerateCraftingInventoryEntryData

    SecurePostHook(ZO_UniversalDeconstructionInventory_Gamepad, "Refresh", function()
        debugLog("just after NPC Refresh()")
        myScope.npcDeconstructPanelRefreshing = false
        postHandleResearchableItems()
    end)
end

local function onAddOnLoaded(eventCode, addOnName)
    if(addOnName ~= "KeepOne4Research") then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(myScope.NAME, EVENT_ADD_ON_LOADED)

    setupSmithingDeconstructHooks()
    setupNpcDeconstructHooks()
end

EVENT_MANAGER:RegisterForEvent(myScope.NAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)