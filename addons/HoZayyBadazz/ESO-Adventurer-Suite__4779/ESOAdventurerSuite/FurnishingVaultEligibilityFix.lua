-- ESO Adventurer Suite
-- v0.29.581 - native Furnishing Vault deposit slot-data filter.
-- Use ESO's SHARED_INVENTORY slot.filterData directly. The native Furnishing
-- Vault deposit view filters the backpack with ITEMFILTERTYPE_FURNISHING, and
-- each shared slot already carries the authoritative filterData table.

local EPC = ESOProgressionCoach
if not EPC or not EPC.BankGridUnifiedV2 then return end

local U = EPC.BankGridUnifiedV2

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a
end

local function getInventoryData(invType)
    local manager = rawget(_G, "PLAYER_INVENTORY")
    if type(manager) ~= "table" or type(manager.inventories) ~= "table" or invType == nil then return nil end
    return manager.inventories[invType]
end

local function getBackingBag(invType, fallback)
    local data = getInventoryData(invType)
    if type(data) == "table" and type(data.backingBags) == "table" and data.backingBags[1] ~= nil then
        return data.backingBags[1]
    end
    return fallback
end

local function getNativeSlotData(bag, slot)
    local shared = rawget(_G, "SHARED_INVENTORY")
    if type(shared) ~= "table" or type(shared.GetOrCreateBagCache) ~= "function" then return nil end
    local ok, cache = pcall(shared.GetOrCreateBagCache, shared, bag)
    if not ok or type(cache) ~= "table" then return nil end
    return cache[slot]
end

local function tableHasValue(values, wanted)
    if type(values) ~= "table" or wanted == nil then return false end
    for _, value in pairs(values) do
        if value == wanted then return true end
    end
    return false
end

local function isNativeFurnishing(bag, slot)
    local furnishingFilter = rawget(_G, "ITEMFILTERTYPE_FURNISHING")

    -- Exact native slot-data path. SHARED_INVENTORY builds filterData directly
    -- from GetItemFilterTypeInfo when it creates/updates a bag slot.
    local slotData = getNativeSlotData(bag, slot)
    if slotData and tableHasValue(slotData.filterData, furnishingFilter) then
        return true
    end

    -- If the cache has not been populated yet, ask ESO for the same filter data
    -- directly. This is only a fallback for initialization timing.
    if furnishingFilter ~= nil and type(GetItemFilterTypeInfo) == "function" then
        local filters = { GetItemFilterTypeInfo(bag, slot) }
        if tableHasValue(filters, furnishingFilter) then return true end
    end

    -- Final compatibility fallback for API variants where furniture reports only
    -- its broad item type.
    local furnishingType = rawget(_G, "ITEMTYPE_FURNISHING")
    if furnishingType ~= nil and type(GetItemType) == "function" then
        return tonumber(first(GetItemType, -1, bag, slot)) == tonumber(furnishingType)
    end

    return false
end

local function buildItem(bag, slot)
    local style = rawget(_G, "LINK_STYLE_DEFAULT") or 0
    local link = tostring(first(GetItemLink, "", bag, slot, style) or "")
    if link == "" then return nil end

    local name = tostring(first(GetItemName, "", bag, slot) or "")
    local icon, stack, _, _, locked, _, _, quality
    if type(GetItemInfo) == "function" then
        local ok
        ok, icon, stack, _, _, locked, _, _, quality = pcall(GetItemInfo, bag, slot)
        if not ok then icon, stack, locked, quality = nil, nil, false, nil end
    end

    stack = tonumber(stack) or tonumber(first(GetSlotStackSize, 1, bag, slot)) or 1
    quality = tonumber(quality) or tonumber(first(GetItemDisplayQuality, 0, bag, slot)) or 0

    return {
        bag = bag,
        slot = slot,
        name = name,
        icon = tostring(icon or ""),
        stack = stack,
        quality = quality,
        locked = locked == true,
        group = "FURNISHINGS",
        order = 10,
    }
end

local function collectFromBag(bag, furnishingOnly)
    local items = {}
    if bag == nil or type(GetBagSize) ~= "function" then return items end

    local size = tonumber(first(GetBagSize, 0, bag)) or 0
    for slot = 0, size - 1 do
        if not furnishingOnly or isNativeFurnishing(bag, slot) then
            local item = buildItem(bag, slot)
            if item then items[#items + 1] = item end
        end
    end

    table.sort(items, function(a, b)
        if a.quality ~= b.quality then return a.quality > b.quality end
        return string.lower(a.name) < string.lower(b.name)
    end)
    return items
end

local baseCollect029581 = U.Collect
function U:Collect(mode, ...)
    if self.furnishingVaultSuiteGrid029577 == true then
        local manager = rawget(_G, "PLAYER_INVENTORY")
        local selected = type(manager) == "table" and tonumber(manager.selectedTabType) or nil
        local vaultType = rawget(_G, "INVENTORY_FURNITURE_VAULT")
        local backpackType = rawget(_G, "INVENTORY_BACKPACK")

        if mode == "WITHDRAW" and vaultType ~= nil and selected == tonumber(vaultType) then
            return collectFromBag(getBackingBag(vaultType, rawget(_G, "BAG_FURNITURE_VAULT")), false)
        end

        if mode == "DEPOSIT" and backpackType ~= nil and selected == tonumber(backpackType) then
            -- Keep ESO's own backpack slot cache current before consuming it.
            if type(manager) == "table" and type(manager.RefreshAllInventorySlots) == "function" then
                pcall(manager.RefreshAllInventorySlots, manager, backpackType)
            end
            return collectFromBag(getBackingBag(backpackType, rawget(_G, "BAG_BACKPACK")), true)
        end
    end

    if type(baseCollect029581) == "function" then
        return baseCollect029581(self, mode, ...)
    end
    return {}
end
