-- ESO Adventurer Suite
-- v0.29.528 - Bank grid numeric + nil-constant safety.
-- ESO API helpers can return multiple values, and some enum globals may be nil
-- on specific client/API combinations. This override ensures tonumber() only
-- receives one value and classification never constructs a table with nil keys.

local EPC = ESOProgressionCoach
if not EPC then return end
local M = EPC.BankGridHardOverride
if not M then return end

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a
end

local function numberFirst(fn, fallback, ...)
    local value = first(fn, fallback, ...)
    return tonumber(value)
end

local function equalsAnyGlobal(value, names)
    for _, name in ipairs(names) do
        local enum = rawget(_G, name)
        if enum ~= nil and value == enum then return true end
    end
    return false
end

local function searchText(mode)
    local names = mode == "WITHDRAW"
        and {"ZO_PlayerBankSearchFiltersTextSearchBox", "ZO_PlayerBankSearchFiltersTextSearch"}
        or {"ZO_PlayerInventorySearchFiltersTextSearchBox", "ZO_PlayerInventorySearchFiltersTextSearch"}
    for _, name in ipairs(names) do
        local control = rawget(_G, name)
        if control and type(control.GetText) == "function" then
            return string.lower(tostring(first(control.GetText, "", control) or ""))
        end
    end
    return ""
end

local function classify(link, bag, slot)
    local equip = numberFirst(GetItemLinkEquipType, 0, link) or 0
    local itemType = numberFirst(GetItemType, 0, bag, slot) or 0

    if equalsAnyGlobal(equip, {
        "EQUIP_TYPE_MAIN_HAND", "EQUIP_TYPE_OFF_HAND", "EQUIP_TYPE_TWO_HAND"
    }) then
        return "WEAPONS", 10
    end

    if equalsAnyGlobal(equip, {"EQUIP_TYPE_RING", "EQUIP_TYPE_NECK"}) then
        return "JEWELRY", 30
    end

    if equalsAnyGlobal(equip, {
        "EQUIP_TYPE_HEAD", "EQUIP_TYPE_CHEST", "EQUIP_TYPE_SHOULDERS",
        "EQUIP_TYPE_WAIST", "EQUIP_TYPE_LEGS", "EQUIP_TYPE_FEET", "EQUIP_TYPE_HAND"
    }) then
        return "ARMOR", 20
    end

    if equalsAnyGlobal(itemType, {
        "ITEMTYPE_FOOD", "ITEMTYPE_DRINK", "ITEMTYPE_POTION", "ITEMTYPE_POISON",
        "ITEMTYPE_RECIPE", "ITEMTYPE_CONTAINER"
    }) then
        return "CONSUMABLES", 40
    end

    if equalsAnyGlobal(itemType, {
        "ITEMTYPE_BLACKSMITHING_MATERIAL", "ITEMTYPE_CLOTHIER_MATERIAL",
        "ITEMTYPE_WOODWORKING_MATERIAL", "ITEMTYPE_REAGENT", "ITEMTYPE_RAW_MATERIAL",
        "ITEMTYPE_STYLE_MATERIAL", "ITEMTYPE_TRAIT_MATERIAL",
        "ITEMTYPE_ENCHANTING_RUNE_ASPECT", "ITEMTYPE_ENCHANTING_RUNE_ESSENCE",
        "ITEMTYPE_ENCHANTING_RUNE_POTENCY", "ITEMTYPE_ALCHEMY_BASE"
    }) then
        return "MATERIALS", 50
    end

    return "OTHER", 90
end

function M:Collect(mode)
    local bags = mode == "WITHDRAW"
        and {rawget(_G, "BAG_BANK"), rawget(_G, "BAG_SUBSCRIBER_BANK")}
        or {rawget(_G, "BAG_BACKPACK")}
    local search = searchText(mode)
    local items = {}

    for _, bag in ipairs(bags) do
        if bag ~= nil and type(GetBagSize) == "function" then
            local size = numberFirst(GetBagSize, 0, bag) or 0
            for slot = 0, size - 1 do
                local link = tostring(first(GetItemLink, "", bag, slot, rawget(_G, "LINK_STYLE_DEFAULT") or 0) or "")
                if link ~= "" then
                    local name = tostring(first(GetItemName, "", bag, slot) or "")
                    if search == "" or string.find(string.lower(name), search, 1, true) then
                        local icon, stack, _, _, locked, _, _, quality
                        if type(GetItemInfo) == "function" then
                            local ok
                            ok, icon, stack, _, _, locked, _, _, quality = pcall(GetItemInfo, bag, slot)
                            if not ok then icon, stack, locked, quality = nil, nil, false, nil end
                        end
                        stack = tonumber(stack) or numberFirst(GetSlotStackSize, 1, bag, slot) or 1
                        quality = tonumber(quality) or numberFirst(GetItemDisplayQuality, 0, bag, slot) or 0
                        local group, order = classify(link, bag, slot)
                        items[#items + 1] = {
                            bag = bag,
                            slot = slot,
                            link = link,
                            name = name,
                            icon = tostring(icon or ""),
                            stack = stack,
                            quality = quality,
                            locked = locked == true,
                            group = group,
                            order = order,
                        }
                    end
                end
            end
        end
    end

    table.sort(items, function(a, b)
        if a.order ~= b.order then return a.order < b.order end
        if a.quality ~= b.quality then return a.quality > b.quality end
        return string.lower(a.name) < string.lower(b.name)
    end)
    return items
end

local function findDestination(srcBag, srcSlot, targetBags)
    local srcLink = tostring(first(GetItemLink, "", srcBag, srcSlot, rawget(_G, "LINK_STYLE_DEFAULT") or 0) or "")
    local srcCount = numberFirst(GetSlotStackSize, 1, srcBag, srcSlot) or 1

    for _, bag in ipairs(targetBags) do
        if bag ~= nil and type(GetBagSize) == "function" then
            local size = numberFirst(GetBagSize, 0, bag) or 0
            for slot = 0, size - 1 do
                local link = tostring(first(GetItemLink, "", bag, slot, rawget(_G, "LINK_STYLE_DEFAULT") or 0) or "")
                if srcLink ~= "" and link == srcLink and type(GetSlotStackSize) == "function" then
                    local ok, count, maxStack = pcall(GetSlotStackSize, bag, slot)
                    if ok then
                        count, maxStack = tonumber(count), tonumber(maxStack)
                        if count and maxStack and count < maxStack then
                            return bag, slot, math.min(srcCount, maxStack - count)
                        end
                    end
                end
            end
            if type(FindFirstEmptySlotInBag) == "function" then
                local empty = first(FindFirstEmptySlotInBag, nil, bag)
                if empty ~= nil then return bag, empty, srcCount end
            end
        end
    end
    return nil
end

function M:Move(item)
    if not item then return end
    if item.locked and self.mode == "DEPOSIT" then return end

    local targets = self.mode == "WITHDRAW"
        and {rawget(_G, "BAG_BACKPACK")}
        or {rawget(_G, "BAG_BANK"), rawget(_G, "BAG_SUBSCRIBER_BANK")}

    local dstBag, dstSlot, count = findDestination(item.bag, item.slot, targets)
    if dstBag == nil then
        if type(ZO_Alert) == "function" then
            pcall(ZO_Alert, UI_ALERT_CATEGORY_ERROR, nil, "No space available.")
        end
        return
    end

    local moveCount = tonumber(count) or tonumber(item.stack) or 1
    local protected = false
    if type(IsProtectedFunction) == "function" then
        local ok, value = pcall(IsProtectedFunction, "RequestMoveItem")
        protected = ok and value == true
    end

    if protected and type(CallSecureProtected) == "function" then
        pcall(CallSecureProtected, "RequestMoveItem", item.bag, item.slot, dstBag, dstSlot, moveCount)
    elseif type(RequestMoveItem) == "function" then
        pcall(RequestMoveItem, item.bag, item.slot, dstBag, dstSlot, moveCount)
    end
    self.dirty = true
end

M.dirty = true
