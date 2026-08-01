-- CharacterMarkdown - Inventory Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown
local string_format = string.format
local GetItemLink = GetItemLink
local GetItemName = GetItemName
local GetItemType = GetItemType
local GetItemInfo = GetItemInfo

-- Helper function to collect items from crafting bag using proper API
local function CollectCraftBagItems()
    local items = {}

    -- Craft bag uses BAG_VIRTUAL but requires special iteration
    if ZO_IterateBagSlots then
        CM.DebugPrint("INVENTORY", "Using ZO_IterateBagSlots for craft bag iteration")
        for slotIndex in ZO_IterateBagSlots(BAG_VIRTUAL) do
            local itemLink = CM.SafeCall(GetItemLink, BAG_VIRTUAL, slotIndex)
            if itemLink and itemLink ~= "" then
                local itemName = CM.SafeCall(GetItemName, BAG_VIRTUAL, slotIndex) or "Unknown"
                itemName = itemName:gsub("%^%w+$", "") -- Strip superscript markers

                local success, _, stack, _, _, _, _, _, quality = pcall(GetItemInfo, BAG_VIRTUAL, slotIndex)
                if not success then
                    stack = 1
                    quality = 0
                end

                local itemType = CM.SafeCall(GetItemType, BAG_VIRTUAL, slotIndex)
                local itemTypeName = ""
                if itemType then
                    local success2, typeName = pcall(GetString, "SI_ITEMTYPE", itemType)
                    if success2 and typeName and typeName ~= "" then
                        itemTypeName = typeName
                    end
                end

                table.insert(items, {
                    name = itemName,
                    stack = stack or 1,
                    quality = quality or 0,
                    itemType = itemType,
                    itemTypeName = itemTypeName,
                    slot = slotIndex,
                })
            end
        end
    else
        -- Fallback method (bounded by GetBagSize)
        CM.DebugPrint("INVENTORY", "ZO_IterateBagSlots not available, using fallback method")
        local craftBagUsedSuccess, craftBagUsedResult = pcall(GetNumBagUsedSlots, BAG_VIRTUAL)
        if craftBagUsedSuccess and craftBagUsedResult and craftBagUsedResult > 0 then
            local maxSlots = CM.SafeCall(GetBagSize, BAG_VIRTUAL) or 0
            for slotIndex = 0, maxSlots - 1 do
                local itemLink = CM.SafeCall(GetItemLink, BAG_VIRTUAL, slotIndex)
                if itemLink and itemLink ~= "" then
                    local itemName = CM.SafeCall(GetItemName, BAG_VIRTUAL, slotIndex) or "Unknown"
                    itemName = itemName:gsub("%^%w+$", "")

                    local success, _, stack, _, _, _, _, _, quality = pcall(GetItemInfo, BAG_VIRTUAL, slotIndex)
                    if not success then
                        stack = 1
                        quality = 0
                    end

                    local itemType = CM.SafeCall(GetItemType, BAG_VIRTUAL, slotIndex)
                    local itemTypeName = ""
                    if itemType then
                        local success2, typeName = pcall(GetString, "SI_ITEMTYPE", itemType)
                        if success2 and typeName and typeName ~= "" then
                            itemTypeName = typeName
                        end
                    end

                    table.insert(items, {
                        name = itemName,
                        stack = stack or 1,
                        quality = quality or 0,
                        itemType = itemType,
                        itemTypeName = itemTypeName,
                        slot = slotIndex,
                    })
                end
            end
        end
    end

    -- Sort by name (case-insensitive)
    table.sort(items, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    return items
end

-- Helper function to collect bag items
local function CollectBagItems(bagId)
    local items = {}
    local numSlots = CM.SafeCall(GetBagSize, bagId) or 0

    for slotIndex = 0, numSlots - 1 do
        local itemLink = CM.SafeCall(GetItemLink, bagId, slotIndex)
        if itemLink and itemLink ~= "" then
            local itemName = CM.SafeCall(GetItemName, bagId, slotIndex) or "Unknown"
            itemName = itemName:gsub("%^%w+$", "") -- Strip superscript markers

            local success, _, stack, _, _, _, _, _, quality = pcall(GetItemInfo, bagId, slotIndex)
            if not success then
                stack = 1
                quality = 0
            end

            table.insert(items, {
                name = itemName,
                stack = stack or 1,
                quality = quality or 0,
                slot = slotIndex,
            })
        end
    end

    -- Sort by name (case-insensitive)
    table.sort(items, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    return items
end

-- =====================================================
-- INVENTORY
-- =====================================================

local function CollectInventoryData()
    -- Use API layer granular functions (composition at collector level)
    local backpackStats = CM.api.inventory.GetBagStats(BAG_BACKPACK)
    local hasCraftBag = CM.api.inventory.GetCraftBagAccess()

    local inventory = {}

    -- Transform API data to expected format (backward compatibility)
    inventory.backpackUsed = backpackStats.used or 0
    inventory.backpackMax = backpackStats.size or 0
    inventory.backpackPercent = inventory.backpackMax > 0
            and math.floor((inventory.backpackUsed / inventory.backpackMax) * 100)
        or 0

    -- Collect bag items if requested
    local settings = CM.GetSettings()
    if settings and settings.showBagContents then
        inventory.bagItems = CollectBagItems(BAG_BACKPACK)
    end

    -- Bank data with better error handling
    local bankUsedSuccess, bankUsedResult = pcall(GetNumBagUsedSlots, BAG_BANK)
    local bankMaxSuccess, bankMaxResult = pcall(GetBagSize, BAG_BANK)

    if bankUsedSuccess and bankMaxSuccess then
        inventory.bankUsed = bankUsedResult or 0
        inventory.bankMax = bankMaxResult or 0
        CM.DebugPrint("INVENTORY", string_format("Bank data collected: %d/%d", inventory.bankUsed, inventory.bankMax))
    else
        inventory.bankUsed = 0
        inventory.bankMax = 0
        CM.DebugPrint("INVENTORY", string_format("Warning: Bank API unavailable"))
    end

    -- ESO Plus doubles bank capacity
    local hasESOPlus = CM.api.collectibles.IsESOPlus()

    if inventory.bankMax < inventory.bankUsed then
        if hasESOPlus and inventory.bankMax > 0 then
            local originalMax = inventory.bankMax
            inventory.bankMax = inventory.bankMax * 2
            CM.DebugPrint(
                "INVENTORY",
                string_format("Bank: API returned %d, doubled to %d for ESO Plus", originalMax, inventory.bankMax)
            )
        else
            inventory.bankMax = inventory.bankUsed
        end
    elseif hasESOPlus and inventory.bankMax == 240 and inventory.bankUsed > 0 then
        local originalMax = inventory.bankMax
        inventory.bankMax = inventory.bankMax * 2
        CM.DebugPrint(
            "INVENTORY",
            string_format("Bank: ESO Plus active, doubled base size from %d to %d", originalMax, inventory.bankMax)
        )
    end

    inventory.bankPercent = inventory.bankMax > 0 and math.floor((inventory.bankUsed / inventory.bankMax) * 100) or 0

    -- Collect bank items if requested
    if settings and settings.showBankContents and bankMaxSuccess then
        inventory.bankItems = CollectBagItems(BAG_BANK)
    end

    -- Craft bag access
    inventory.hasCraftingBag = hasCraftBag or false

    -- Collect crafting bag items if requested
    if settings and settings.showCraftingBagContents then
        if inventory.hasCraftingBag then
            CM.DebugPrint("INVENTORY", "Attempting to collect crafting bag items (ESO Plus active)...")
            inventory.craftingBagItems = CollectCraftBagItems()
            if #inventory.craftingBagItems > 0 then
                CM.DebugPrint(
                    "INVENTORY",
                    string_format("Crafting bag: collected %d items", #inventory.craftingBagItems)
                )
            else
                CM.DebugPrint("INVENTORY", "Crafting bag: no items found")
                inventory.craftingBagItems = {}
            end
        else
            CM.DebugPrint("INVENTORY", "Crafting bag: setting enabled but player does not have ESO Plus")
        end
    end

    -- Add computed efficiency metrics
    inventory.efficiency = {
        backpackUsage = inventory.backpackPercent,
        bankUsage = inventory.bankPercent,
        backpackEfficiency = inventory.backpackMax > 0 and math.floor(
            (inventory.backpackUsed / inventory.backpackMax) * 100
        ) or 0,
        bankEfficiency = inventory.bankMax > 0 and math.floor((inventory.bankUsed / inventory.bankMax) * 100) or 0,
    }

    return inventory
end

CM.collectors.CollectInventoryData = CollectInventoryData

-- =====================================================
-- CURRENCY
-- =====================================================

-- Currency collection moved to Economy.lua
-- CM.collectors.CollectCurrencyData is now handled by Economy collector

-- =====================================================
-- SOUL GEMS
-- =====================================================

local function CollectSoulGemData()
    local soulGems = {}

    soulGems.filled = 0
    soulGems.empty = 0

    local function scanBag(bagId)
        local numSlots = CM.SafeCall(GetBagSize, bagId) or 0

        for slotIndex = 0, numSlots - 1 do
            local itemType = CM.SafeCall(GetItemType, bagId, slotIndex)

            if itemType == ITEMTYPE_SOUL_GEM then
                local stackCount = CM.SafeCall(GetSlotStackSize, bagId, slotIndex) or 0
                local itemLink = CM.api.equipment.GetItemLink(bagId, slotIndex)

                local itemName = itemLink and CM.SafeCall(GetItemLinkName, itemLink) or nil
                if itemName and itemName:find("Filled") then
                    soulGems.filled = soulGems.filled + stackCount
                else
                    soulGems.empty = soulGems.empty + stackCount
                end
            end
        end
    end

    scanBag(BAG_BACKPACK)
    scanBag(BAG_BANK)

    return soulGems
end

CM.collectors.CollectSoulGemData = CollectSoulGemData

CM.DebugPrint("COLLECTOR", "Inventory collector module loaded")
