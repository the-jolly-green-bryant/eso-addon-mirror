-- ESO Adventurer Suite
-- v0.29.656 - bank jewelry set grouping + authoritative companion classification.
-- Jewelry recovery now preserves set metadata so rings/necklaces group under their
-- actual set headers. Companion classification is stamped after every upstream
-- sorter so companion gear cannot fall back into character Weapons/Armor/Jewelry.

local EPC = ESOProgressionCoach
if not EPC then return end
local U = EPC.BankGridUnifiedV2
if not U or type(U.Collect) ~= "function" then return end

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

local function same(value, ...)
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if v ~= nil and value == v then return true end
    end
    return false
end

local function activeInventory(mode)
    local manager = rawget(_G, "PLAYER_INVENTORY")
    if type(manager) ~= "table" or type(manager.inventories) ~= "table" then return nil end
    local invType
    if mode == "DEPOSIT" then
        invType = rawget(_G, "INVENTORY_BACKPACK")
    elseif type(manager.GetBankInventoryType) == "function" then
        local ok, value = pcall(manager.GetBankInventoryType, manager)
        if ok then invType = value end
    end
    invType = invType or rawget(_G, "INVENTORY_BANK")
    return invType and manager.inventories[invType] or nil
end

local function activeFilter(mode)
    local inventory = activeInventory(mode)
    if type(inventory) == "table" and inventory.currentFilter ~= nil then
        return inventory.currentFilter
    end
    local cache = U._easBankTopFilter029542
    local manager = rawget(_G, "PLAYER_INVENTORY")
    local invType = mode == "DEPOSIT" and rawget(_G, "INVENTORY_BACKPACK") or rawget(_G, "INVENTORY_BANK")
    if type(manager) == "table" and mode ~= "DEPOSIT" and type(manager.GetBankInventoryType) == "function" then
        local ok, value = pcall(manager.GetBankInventoryType, manager)
        if ok and value ~= nil then invType = value end
    end
    return type(cache) == "table" and cache[invType] or nil
end

local function isJewelryFilter(filter)
    return same(filter,
        rawget(_G, "ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY"),
        rawget(_G, "ITEMFILTERTYPE_JEWELRY"),
        rawget(_G, "ITEMFILTERTYPE_JEWELRY_CRAFTING"))
end

local function searchText(mode)
    local names = mode == "WITHDRAW"
        and { "ZO_PlayerBankSearchFiltersTextSearchBox", "ZO_PlayerBankSearchFiltersTextSearch" }
        or { "ZO_PlayerInventorySearchFiltersTextSearchBox", "ZO_PlayerInventorySearchFiltersTextSearch" }
    for _, name in ipairs(names) do
        local control = rawget(_G, name)
        if control and type(control.GetText) == "function" then
            return string.lower(tostring(first(control.GetText, "", control) or ""))
        end
    end
    return ""
end

local function itemLink(bag, slot)
    return tostring(first(GetItemLink, "", bag, slot, rawget(_G, "LINK_STYLE_DEFAULT") or 0) or "")
end

local function actorCategoryFor(bag, slot, link)
    if type(GetItemActorCategory) == "function" then
        local value = first(GetItemActorCategory, nil, bag, slot)
        if value ~= nil then return value end
    end
    local linkFn = rawget(_G, "GetItemLinkActorCategory")
    if type(linkFn) == "function" and tostring(link or "") ~= "" then
        local value = first(linkFn, nil, link)
        if value ~= nil then return value end
    end
    return nil
end

local function isCompanionItem(bag, slot, link)
    local companion = rawget(_G, "GAMEPLAY_ACTOR_CATEGORY_COMPANION")
    if companion == nil then return false end
    return actorCategoryFor(bag, slot, link or itemLink(bag, slot)) == companion
end

local function setMetadata(link)
    if link == "" or type(GetItemLinkSetInfo) ~= "function" then return "", "", false end
    local ok, hasSet, setName = pcall(GetItemLinkSetInfo, link, false)
    if not ok or hasSet ~= true then return "", "", false end
    setName = tostring(setName or "")
    if setName == "" then return "", "", false end
    return string.lower(setName), setName, true
end

local function isJewelry(bag, slot)
    local link = itemLink(bag, slot)
    if link == "" then return false end
    local equip = tonumber(first(GetItemLinkEquipType, 0, link)) or 0
    return same(equip, rawget(_G, "EQUIP_TYPE_RING"), rawget(_G, "EQUIP_TYPE_NECK"))
end

local function buildItem(bag, slot)
    local link = itemLink(bag, slot)
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

    local companion = isCompanionItem(bag, slot, link)
    local setKey, setDisplay, hasSet = setMetadata(link)
    if companion then
        setKey, setDisplay, hasSet = "", "", false
    end

    return {
        bag = bag,
        slot = slot,
        name = name,
        icon = tostring(icon or ""),
        stack = stack,
        quality = quality,
        locked = locked == true,
        group = companion and "COMPANION" or "JEWELRY",
        order = companion and 35 or 30,
        _easSetName029652 = setKey,
        _easSetDisplayName029652 = setDisplay,
        _easHasSet029652 = hasSet,
        _easCompanion029656 = companion,
    }
end

local function enforceAuthoritativeClassification(item)
    if type(item) ~= "table" or item.bag == nil or item.slot == nil then return end
    local link = itemLink(item.bag, item.slot)
    local companion = isCompanionItem(item.bag, item.slot, link)
    item._easCompanion029656 = companion

    if companion then
        item.group = "COMPANION"
        item.order = 35
        item._easHasSet029652 = false
        item._easSetName029652 = ""
        item._easSetDisplayName029652 = ""
        return
    end

    -- Preserve/repair player gear set metadata after all previous collectors have
    -- run. This is especially important for Jewelry rebuilt by the fallback path.
    if item.group == "WEAPONS" or item.group == "ARMOR" or item.group == "JEWELRY" then
        local setKey, setDisplay, hasSet = setMetadata(link)
        item._easSetName029652 = setKey
        item._easSetDisplayName029652 = setDisplay
        item._easHasSet029652 = hasSet
    end
end

local baseCollect = U.Collect
function U:Collect(mode, ...)
    local items = baseCollect(self, mode, ...)
    if type(items) ~= "table" then items = {} end

    for _, item in ipairs(items) do
        enforceAuthoritativeClassification(item)
    end

    -- Jewelry recovery path. ESO can leave the hidden bank list empty when the
    -- top tab reports a descriptor rather than the display-category enum. Rebuild
    -- from source bags, but preserve complete set/actor metadata this time.
    if isJewelryFilter(activeFilter(mode)) then
        local bags = mode == "WITHDRAW"
            and { rawget(_G, "BAG_BANK"), rawget(_G, "BAG_SUBSCRIBER_BANK") }
            or { rawget(_G, "BAG_BACKPACK") }
        local search = searchText(mode)
        local rebuilt = {}
        for _, bag in ipairs(bags) do
            if bag ~= nil and type(GetBagSize) == "function" then
                local size = tonumber(first(GetBagSize, 0, bag)) or 0
                for slot = 0, size - 1 do
                    if isJewelry(bag, slot) then
                        local item = buildItem(bag, slot)
                        if item and (search == "" or string.find(string.lower(item.name), search, 1, true)) then
                            rebuilt[#rebuilt + 1] = item
                        end
                    end
                end
            end
        end
        table.sort(rebuilt, function(a, b)
            local ac, bc = a._easCompanion029656 == true, b._easCompanion029656 == true
            if ac ~= bc then return not ac end
            local ah, bh = a._easHasSet029652 == true, b._easHasSet029652 == true
            if ah ~= bh then return ah end
            if ah and bh then
                local as, bs = tostring(a._easSetName029652 or ""), tostring(b._easSetName029652 or "")
                if as ~= bs then return as < bs end
            end
            if a.quality ~= b.quality then return a.quality > b.quality end
            return string.lower(a.name or "") < string.lower(b.name or "")
        end)
        return rebuilt
    end

    table.sort(items, function(a, b)
        local ac, bc = a and a._easCompanion029656 == true, b and b._easCompanion029656 == true
        if ac ~= bc then return not ac end
        local ao, bo = tonumber(a and a.order) or 90, tonumber(b and b.order) or 90
        if ao ~= bo then return ao < bo end
        local aq, bq = tonumber(a and a.quality) or 0, tonumber(b and b.quality) or 0
        if aq ~= bq then return aq > bq end
        return string.lower(tostring(a and a.name or "")) < string.lower(tostring(b and b.name or ""))
    end)
    return items
end

U._easBankClassification029656 = true
