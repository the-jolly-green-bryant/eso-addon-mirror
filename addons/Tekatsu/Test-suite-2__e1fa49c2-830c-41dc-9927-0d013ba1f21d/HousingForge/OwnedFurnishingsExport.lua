HF.OwnedFurnishingsExport = {}

local function EscapeField(value)
    value = tostring(value or "")
    value = string.gsub(value, "\\", "\\\\")
    value = string.gsub(value, "|", "\\p")
    value = string.gsub(value, "\n", "\\n")
    value = string.gsub(value, "\r", "")
    return value
end

local function AddBag(bags, bagId)
    if bagId ~= nil then
        table.insert(bags, bagId)
    end
end

local function BuildBagScanOrder()
    local bags = {}
    AddBag(bags, BAG_BACKPACK)
    AddBag(bags, BAG_BANK)
    AddBag(bags, BAG_SUBSCRIBER_BANK)
    AddBag(bags, BAG_FURNITURE_VAULT)
    AddBag(bags, BAG_HOUSE_BANK_ONE)
    AddBag(bags, BAG_HOUSE_BANK_TWO)
    AddBag(bags, BAG_HOUSE_BANK_THREE)
    AddBag(bags, BAG_HOUSE_BANK_FOUR)
    AddBag(bags, BAG_HOUSE_BANK_FIVE)
    AddBag(bags, BAG_HOUSE_BANK_SIX)
    AddBag(bags, BAG_HOUSE_BANK_SEVEN)
    AddBag(bags, BAG_HOUSE_BANK_EIGHT)
    AddBag(bags, BAG_HOUSE_BANK_NINE)
    AddBag(bags, BAG_HOUSE_BANK_TEN)
    return bags
end

local function IsValidBag(bagId)
    if bagId == nil or not GetBagSize then return false end
    local ok, bagSize = pcall(GetBagSize, bagId)
    return ok and type(bagSize) == "number"
end

local function GetSafeItemName(bagId, slotIndex, itemLink)
    if itemLink and itemLink ~= "" and GetItemLinkName then
        local name = GetItemLinkName(itemLink)
        if name and name ~= "" then
            return zo_strformat and zo_strformat(SI_TOOLTIP_ITEM_NAME, name) or name
        end
    end

    if GetItemName then
        local name = GetItemName(bagId, slotIndex)
        if name and name ~= "" then
            return zo_strformat and zo_strformat(SI_TOOLTIP_ITEM_NAME, name) or name
        end
    end

    return "Unknown Furnishing"
end

local function AddOwnedItem(itemsByKey, item)
    local key = string.format("item:%d:%d:%s", item.furnitureDataId or 0, item.itemId or 0, item.name or "")
    local existing = itemsByKey[key]
    if existing then
        existing.count = existing.count + (item.count or 1)
        return
    end
    itemsByKey[key] = item
end

local function ScanInventoryFurnishings()
    local itemsByKey = {}
    local scannedBags = 0
    local scannedSlots = 0

    for _, bagId in ipairs(BuildBagScanOrder()) do
        if IsValidBag(bagId) then
            scannedBags = scannedBags + 1
            local bagSize = GetBagSize(bagId) or 0
            for slotIndex = 0, bagSize - 1 do
                if HasItemInSlot and HasItemInSlot(bagId, slotIndex) then
                    scannedSlots = scannedSlots + 1
                    local isFurniture = IsItemPlaceableFurniture and IsItemPlaceableFurniture(bagId, slotIndex)
                    local itemType = nil
                    if not isFurniture and GetItemType then
                        itemType = GetItemType(bagId, slotIndex)
                        isFurniture = itemType == ITEMTYPE_FURNISHING
                    end
                    if isFurniture then
                        local furnitureDataId = GetItemFurnitureDataId and GetItemFurnitureDataId(bagId, slotIndex) or 0
                        local itemLink = GetItemLink and GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT) or ""
                        local itemId = GetItemId and GetItemId(bagId, slotIndex) or 0
                        local _, stack = GetItemInfo(bagId, slotIndex)
                        AddOwnedItem(itemsByKey, {
                            source = "inventory",
                            furnitureDataId = furnitureDataId,
                            itemId = itemId or 0,
                            collectibleId = 0,
                            name = GetSafeItemName(bagId, slotIndex, itemLink),
                            count = stack or 1,
                        })
                    end
                end
            end
        end
    end

    return itemsByKey, scannedBags, scannedSlots
end

local function AddCollectible(itemsByKey, collectibleId)
    if not collectibleId or collectibleId == 0 then return end
    if IsCollectiblePlaceableFurniture and not IsCollectiblePlaceableFurniture(collectibleId, true) then return end

    local unlocked = false
    if IsCollectibleUnlocked and IsCollectibleUnlocked(collectibleId) then
        unlocked = true
    elseif GetCollectibleUnlockStateById then
        local state = GetCollectibleUnlockStateById(collectibleId)
        unlocked = state == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED
            or state == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_SUBSCRIPTION
            or state == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_TRIAL
    end
    if not unlocked then return end

    local name, _, icon = GetCollectibleInfo(collectibleId)
    local furnitureDataId = GetCollectibleFurnitureDataId and GetCollectibleFurnitureDataId(collectibleId) or 0
    local key = string.format("collectible:%d", collectibleId)
    itemsByKey[key] = {
        source = "collectible",
        furnitureDataId = furnitureDataId or 0,
        itemId = 0,
        collectibleId = collectibleId,
        name = name or "Unknown Collectible Furnishing",
        icon = icon or "",
        count = 1,
    }
end

local function ScanCollectibleFurnishings(itemsByKey)
    if not GetNumCollectibleCategories or not GetCollectibleId or not GetCollectibleInfo then return 0 end

    local scanned = 0
    local categoryCount = GetNumCollectibleCategories() or 0
    for topLevelIndex = 1, categoryCount do
        local subcategoryCount = GetNumSubcategoriesInCollectibleCategory and GetNumSubcategoriesInCollectibleCategory(topLevelIndex) or 0

        local topLevelCollectibles = GetNumCollectiblesInCollectibleCategory(topLevelIndex, nil) or 0
        for collectibleIndex = 1, topLevelCollectibles do
            local collectibleId = GetCollectibleId(topLevelIndex, nil, collectibleIndex)
            scanned = scanned + 1
            AddCollectible(itemsByKey, collectibleId)
        end

        for subCategoryIndex = 1, subcategoryCount do
            local numCollectibles = GetNumCollectiblesInCollectibleCategory(topLevelIndex, subCategoryIndex) or 0
            for collectibleIndex = 1, numCollectibles do
                local collectibleId = GetCollectibleId(topLevelIndex, subCategoryIndex, collectibleIndex)
                scanned = scanned + 1
                AddCollectible(itemsByKey, collectibleId)
            end
        end
    end
    return scanned
end

local function SerializeOwned(record, items)
    local parts = {}
    table.insert(parts, "HFOWNED|1")
    table.insert(parts, table.concat({
        "META",
        EscapeField(record.id),
        EscapeField(record.name),
        EscapeField(record.author),
        tostring(record.timestamp or 0),
        tostring(record.inventoryCount or 0),
        tostring(record.collectibleCount or 0),
        tostring(#items),
    }, "|"))

    table.sort(items, function(a, b)
        return (a.name or "") < (b.name or "")
    end)

    for _, item in ipairs(items) do
        table.insert(parts, table.concat({
            "ITEM",
            EscapeField(item.source),
            tostring(item.furnitureDataId or 0),
            tostring(item.itemId or 0),
            tostring(item.collectibleId or 0),
            tostring(item.count or 1),
            EscapeField(item.name),
        }, "|"))
    end

    return table.concat(parts, "\n")
end

local activeScan = nil
local SLOTS_PER_TICK = 5
local TICK_DELAY_MS = 10
local PROGRESS_INTERVAL = 200

local function FinishExport(state)
    local items = {}
    local inventoryCount = 0
    local collectibleCount = 0

    for _, item in pairs(state.itemsByKey) do
        table.insert(items, item)
        if item.source == "collectible" then
            collectibleCount = collectibleCount + 1
        else
            inventoryCount = inventoryCount + 1
        end
    end

    local displayName = GetDisplayName and GetDisplayName() or "player"
    local timestamp = GetTimeStamp()
    local record = {
        id = string.format("owned-%s-%d", string.gsub(displayName, "[^%w_%-]", ""), timestamp),
        name = "Owned Furnishings",
        author = displayName,
        houseId = 0,
        houseName = "Owned Furnishings",
        timestamp = timestamp,
        inventoryCount = inventoryCount,
        collectibleCount = collectibleCount,
    }

    HF.Chat(string.format("Scanned %d bags and %d occupied slots.", state.scannedBags or 0, state.scannedSlots or 0))
    HF.Chat(string.format("Owned furnishings: %d inventory types. Collectibles skipped for this export.", inventoryCount))
    activeScan = nil
    HF.Chat("Preparing owned furnishings export...")
    return HF.LayoutExport.ExportPayloadAsync("owned", record, function()
        return SerializeOwned(record, items)
    end, "owned furnishings")
end

local function ScanSlot(state, bagId, slotIndex)
    if not HasItemInSlot or not HasItemInSlot(bagId, slotIndex) then return end

    state.scannedSlots = state.scannedSlots + 1
    local itemType = GetItemType and GetItemType(bagId, slotIndex) or nil
    local isFurniture = itemType == ITEMTYPE_FURNISHING
    if not isFurniture then return end

    local furnitureDataId = GetItemFurnitureDataId and GetItemFurnitureDataId(bagId, slotIndex) or 0
    local itemLink = GetItemLink and GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT) or ""
    local itemId = GetItemId and GetItemId(bagId, slotIndex) or 0
    local _, stack = GetItemInfo(bagId, slotIndex)
    AddOwnedItem(state.itemsByKey, {
        source = "inventory",
        furnitureDataId = furnitureDataId or 0,
        itemId = itemId or 0,
        collectibleId = 0,
        name = GetSafeItemName(bagId, slotIndex, itemLink),
        count = stack or 1,
    })
end

local function ProcessScanTick()
    local state = activeScan
    if not state then return end

    local ok, err = pcall(function()
        local processed = 0
        while processed < SLOTS_PER_TICK do
            local bagId = state.bags[state.bagIndex]
            if not bagId then
                if zo_callLater then
                    zo_callLater(function() FinishExport(state) end, 100)
                else
                    FinishExport(state)
                end
                return
            end

            if not state.currentBagChecked then
                state.currentBagChecked = true
                if IsValidBag(bagId) then
                    state.currentBagSize = GetBagSize(bagId) or 0
                    state.scannedBags = state.scannedBags + 1
                else
                    state.currentBagSize = 0
                end
            end

            if state.slotIndex >= state.currentBagSize then
                state.bagIndex = state.bagIndex + 1
                state.slotIndex = 0
                state.currentBagChecked = false
                state.currentBagSize = 0
            else
                ScanSlot(state, bagId, state.slotIndex)
                state.slotIndex = state.slotIndex + 1
                processed = processed + 1
                state.processedSlots = (state.processedSlots or 0) + 1
                if (state.processedSlots % PROGRESS_INTERVAL) == 0 then
                    HF.Chat(string.format("Owned export scan progress: %d slots checked, %d occupied.", state.processedSlots, state.scannedSlots or 0))
                end
            end
        end
    end)

    if not ok then
        activeScan = nil
        HF.Chat("Owned furnishings export failed: " .. tostring(err))
        return
    end

    if activeScan and zo_callLater then
        zo_callLater(ProcessScanTick, TICK_DELAY_MS)
    elseif activeScan then
        ProcessScanTick()
    end
end

function HF.OwnedFurnishingsExport.Export()
    if activeScan then
        HF.Chat("Owned furnishings export is already scanning.")
        return false
    end

    activeScan = {
        bags = BuildBagScanOrder(),
        bagIndex = 1,
        slotIndex = 0,
        currentBagChecked = false,
        currentBagSize = 0,
        itemsByKey = {},
        scannedBags = 0,
        scannedSlots = 0,
        processedSlots = 0,
    }

    HF.Chat("Scanning owned furnishings in batches...")
    if zo_callLater then
        zo_callLater(ProcessScanTick, TICK_DELAY_MS)
    else
        ProcessScanTick()
    end
    return true
end
