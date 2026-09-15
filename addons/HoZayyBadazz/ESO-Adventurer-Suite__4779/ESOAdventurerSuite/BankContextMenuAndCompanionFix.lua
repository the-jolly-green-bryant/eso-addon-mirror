-- ESO Adventurer Suite
-- v0.29.659 - stable full bank right-click compatibility + authoritative companion filtering.
-- Bank grid cells remember the actual mouse-down button so ESO OnClicked calls
-- that omit the button argument cannot misinterpret a right-click as a transfer.

local EPC = ESOProgressionCoach
if not EPC then return end

local U = EPC.BankGridUnifiedV2
local Grid = rawget(_G, "EASInventoryGrid")
if not U then return end

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

local function same(value, ...)
    for i = 1, select("#", ...) do
        local candidate = select(i, ...)
        if candidate ~= nil and value == candidate then return true end
    end
    return false
end

local function itemLink(bag, slot)
    if type(GetItemLink) ~= "function" then return "" end
    return tostring(first(GetItemLink, "", bag, slot, rawget(_G, "LINK_STYLE_DEFAULT") or 0) or "")
end

local function itemTypeFor(bag, slot, link)
    local itemType = tonumber(first(GetItemType, nil, bag, slot))
    if itemType ~= nil then return itemType end
    if link ~= "" and type(GetItemLinkItemType) == "function" then
        return tonumber(first(GetItemLinkItemType, nil, link))
    end
    return nil
end

local function isCompanionItem(bag, slot, link)
    if bag == nil or slot == nil then return false end

    local companionActor = rawget(_G, "GAMEPLAY_ACTOR_CATEGORY_COMPANION")
    if companionActor ~= nil and type(GetItemActorCategory) == "function" then
        local actor = first(GetItemActorCategory, nil, bag, slot)
        if actor == companionActor then return true end
    end

    link = link or itemLink(bag, slot)
    local itemType = itemTypeFor(bag, slot, link)
    if same(itemType,
        rawget(_G, "ITEMTYPE_COMPANION_ARMOR"),
        rawget(_G, "ITEMTYPE_COMPANION_WEAPON")) then
        return true
    end

    return false
end

local function activeInventory(mode)
    local manager = rawget(_G, "PLAYER_INVENTORY")
    if type(manager) ~= "table" or type(manager.inventories) ~= "table" then return nil, nil end

    local invType
    if mode == "DEPOSIT" then
        invType = rawget(_G, "INVENTORY_BACKPACK")
    elseif type(manager.GetBankInventoryType) == "function" then
        local ok, value = pcall(manager.GetBankInventoryType, manager)
        if ok then invType = value end
    end
    invType = invType or rawget(_G, "INVENTORY_BANK")
    return invType and manager.inventories[invType] or nil, invType
end

local function activeFilter(mode)
    local inventory, invType = activeInventory(mode)
    if type(inventory) == "table" and inventory.currentFilter ~= nil then
        return inventory.currentFilter
    end
    local cache = U._easBankTopFilter029542
    return type(cache) == "table" and invType ~= nil and cache[invType] or nil
end

local function isCompanionFilter(filter)
    return same(filter,
        rawget(_G, "ITEM_TYPE_DISPLAY_CATEGORY_COMPANION"),
        rawget(_G, "ITEM_TYPE_DISPLAY_CATEGORY_COMPANION_ITEMS"),
        rawget(_G, "ITEMFILTERTYPE_COMPANION"),
        rawget(_G, "ITEMFILTERTYPE_COMPANION_EQUIPMENT"),
        rawget(_G, "ITEMFILTERTYPE_COMPANION_ITEMS"))
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

local function buildCompanionItem(bag, slot)
    local link = itemLink(bag, slot)
    if link == "" or not isCompanionItem(bag, slot, link) then return nil end

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
        group = "COMPANION",
        order = 35,
        _easCompanion029657 = true,
        _easHasSet029652 = false,
        _easSetName029652 = "",
        _easSetDisplayName029652 = "",
    }
end

if type(U.Collect) == "function" and not U._easCompanionAuthoritative029657 then
    U._easCompanionAuthoritative029657 = true
    local baseCollect = U.Collect
    function U:Collect(mode, ...)
        if isCompanionFilter(activeFilter(mode)) then
            local bags = mode == "WITHDRAW"
                and { rawget(_G, "BAG_BANK"), rawget(_G, "BAG_SUBSCRIBER_BANK") }
                or { rawget(_G, "BAG_BACKPACK") }
            local search = searchText(mode)
            local rebuilt = {}
            for _, bag in ipairs(bags) do
                if bag ~= nil and type(GetBagSize) == "function" then
                    local size = tonumber(first(GetBagSize, 0, bag)) or 0
                    for slot = 0, math.max(0, size - 1) do
                        local item = buildCompanionItem(bag, slot)
                        if item and (search == "" or string.find(string.lower(item.name), search, 1, true)) then
                            rebuilt[#rebuilt + 1] = item
                        end
                    end
                end
            end
            table.sort(rebuilt, function(a, b)
                local aq, bq = tonumber(a.quality) or 0, tonumber(b.quality) or 0
                if aq ~= bq then return aq > bq end
                return string.lower(a.name or "") < string.lower(b.name or "")
            end)
            return rebuilt
        end

        local items = baseCollect(self, mode, ...)
        if type(items) ~= "table" then return items end
        for _, item in ipairs(items) do
            if item and item.bag ~= nil and item.slot ~= nil then
                local link = itemLink(item.bag, item.slot)
                if isCompanionItem(item.bag, item.slot, link) then
                    item.group = "COMPANION"
                    item.order = 35
                    item._easCompanion029657 = true
                    item._easHasSet029652 = false
                    item._easSetName029652 = ""
                    item._easSetDisplayName029652 = ""
                end
            end
        end
        return items
    end
end

-- ESO can invoke OnClicked without a mouse-button argument. Record the real
-- gesture on mouse-down so a right-click can never be mistaken for left-click.
if type(U.GetCell) == "function" and not U._easFullBankContextMenu029657 then
    U._easFullBankContextMenu029657 = true
    local baseGetCell = U.GetCell
    function U:GetCell(index)
        local cell = baseGetCell(self, index)
        if cell and not cell._easFullContextMenu029657 and type(cell.SetHandler) == "function" then
            cell._easFullContextMenu029657 = true

            cell:SetHandler("OnMouseDown", function(control, button)
                control._easBankGestureButton029659 = button
            end)

            cell:SetHandler("OnClicked", function(control, button)
                local left = rawget(_G, "MOUSE_BUTTON_INDEX_LEFT")
                local gesture = control._easBankGestureButton029659
                if button ~= nil then gesture = button end
                if left == nil or gesture ~= left then return end
                if control.item then self:Move(control.item) end
            end)

            cell:SetHandler("OnMouseUp", function(control, button, upInside)
                local right = rawget(_G, "MOUSE_BUTTON_INDEX_RIGHT")
                if upInside == false or button ~= right then
                    if type(zo_callLater) == "function" then
                        zo_callLater(function()
                            if control then control._easBankGestureButton029659 = nil end
                        end, 0)
                    end
                    return
                end

                local item = control.item
                if not item or item.bag == nil or item.slot == nil then return end

                control.bagId = item.bag
                control.slotIndex = item.slot
                control.slotType = rawget(_G, "SLOT_TYPE_ITEM")

                local grid = rawget(_G, "EASInventoryGrid") or Grid
                if type(grid) == "table" and type(grid.ShowCompatibleItemMenu) == "function" then
                    grid:ShowCompatibleItemMenu(control)
                elseif type(ZO_InventorySlot_ShowContextMenu) == "function" then
                    pcall(ZO_InventorySlot_ShowContextMenu, control)
                end

                local enchantPlus = rawget(_G, "EASEnchantPlus")
                if type(enchantPlus) == "table" and type(enchantPlus.SuppressNativeEnchantEntry) == "function" then
                    pcall(enchantPlus.SuppressNativeEnchantEntry)
                    if type(zo_callLater) == "function" then
                        zo_callLater(function()
                            pcall(enchantPlus.SuppressNativeEnchantEntry)
                        end, 0)
                    end
                end

                -- Clear only after ESO has had a chance to dispatch OnClicked.
                if type(zo_callLater) == "function" then
                    zo_callLater(function()
                        if control then control._easBankGestureButton029659 = nil end
                    end, 25)
                end
            end)
        end
        return cell
    end
end

EPC.bankContextMenuAndCompanionFix029657 = true
