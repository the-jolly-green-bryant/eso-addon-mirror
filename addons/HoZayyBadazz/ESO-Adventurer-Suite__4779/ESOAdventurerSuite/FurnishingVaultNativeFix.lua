-- ESO Adventurer Suite
-- v0.29.577 - full Suite-grid Furnishing Vault ownership.
-- The Furnishing Vault uses the same visual grid renderer as the Suite Bank,
-- but its source/destination bags are isolated from normal bank storage.
-- WITHDRAW: BAG_FURNITURE_VAULT -> BAG_BACKPACK
-- DEPOSIT:  BAG_BACKPACK -> BAG_FURNITURE_VAULT

local EPC = ESOProgressionCoach
if not EPC or not EPC.BankGridUnifiedV2 then return end

local U = EPC.BankGridUnifiedV2

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

local function effectivelyShown(control)
    if not control then return false end
    if type(IsControlHidden) == "function" then
        local ok, hidden = pcall(IsControlHidden, control)
        if ok then return hidden == false end
    end
    local current, depth = control, 0
    while current and depth < 8 do
        if type(current.IsHidden) == "function" then
            local ok, hidden = pcall(current.IsHidden, current)
            if ok and hidden == true then return false end
        end
        if type(current.GetParent) ~= "function" then break end
        local ok, parent = pcall(current.GetParent, current)
        if not ok or parent == current then break end
        current = parent
        depth = depth + 1
    end
    return true
end

local function inventoryControl(invType)
    local manager = rawget(_G, "PLAYER_INVENTORY")
    if type(manager) ~= "table" or type(manager.inventories) ~= "table" or invType == nil then return nil end
    local data = manager.inventories[invType]
    if type(data) ~= "table" then return nil end
    for _, key in ipairs({ "list", "listView", "scrollList" }) do
        if data[key] then return data[key] end
    end
    return nil
end

local function vaultVisible()
    for _, name in ipairs({
        "ZO_FurnitureVaultTabs",
        "ZO_FurnitureVaultSearchFilters",
        "ZO_FurnitureVaultSearchFiltersTextSearchBox",
        "ZO_FurnitureVaultInfoBar",
        "ZO_FurnitureVaultInfoBarFreeSlots",
        "ZO_FurnitureVaultList",
    }) do
        if effectivelyShown(rawget(_G, name)) then return true end
    end

    local manager = rawget(_G, "PLAYER_INVENTORY")
    local furnitureType = rawget(_G, "INVENTORY_FURNITURE_VAULT")
    return type(manager) == "table" and furnitureType ~= nil
        and tonumber(manager.selectedTabType) == tonumber(furnitureType)
end

local function vaultMode()
    if not vaultVisible() then return nil end
    local manager = rawget(_G, "PLAYER_INVENTORY")
    if type(manager) ~= "table" then return nil end
    local selected = tonumber(manager.selectedTabType)
    local furnitureType = tonumber(rawget(_G, "INVENTORY_FURNITURE_VAULT"))
    local backpackType = tonumber(rawget(_G, "INVENTORY_BACKPACK"))
    if furnitureType ~= nil and selected == furnitureType then return "WITHDRAW" end
    if backpackType ~= nil and selected == backpackType then return "DEPOSIT" end
    return nil
end

local function restore(control)
    if not control then return end
    if type(control.SetAlpha) == "function" then pcall(control.SetAlpha, control, 1) end
    if type(control.SetMouseEnabled) == "function" then pcall(control.SetMouseEnabled, control, true) end
end

local function getPane(mode)
    if mode == "WITHDRAW" then
        return rawget(_G, "ZO_FurnitureVaultList")
            or inventoryControl(rawget(_G, "INVENTORY_FURNITURE_VAULT"))
    end
    return rawget(_G, "ZO_PlayerInventoryList")
        or inventoryControl(rawget(_G, "INVENTORY_BACKPACK"))
end

local function isVaultFurnishing(bag, slot, link)
    local furnishingType = rawget(_G, "ITEMTYPE_FURNISHING")
    if furnishingType ~= nil and type(GetItemType) == "function" then
        local itemType = tonumber(first(GetItemType, -1, bag, slot))
        if itemType == tonumber(furnishingType) then return true end
    end

    link = tostring(link or "")
    if link == "" and type(GetItemLink) == "function" then
        link = tostring(first(GetItemLink, "", bag, slot, rawget(_G, "LINK_STYLE_DEFAULT") or 0) or "")
    end
    if link == "" then return false end

    local placeableFn = rawget(_G, "IsItemLinkPlaceableFurniture")
    if type(placeableFn) == "function" then
        local ok, value = pcall(placeableFn, link)
        if ok and value == true then return true end
    end

    local dataFn = rawget(_G, "GetItemLinkFurnitureDataId")
    if type(dataFn) == "function" then
        local ok, dataId = pcall(dataFn, link)
        if ok and (tonumber(dataId) or 0) > 0 then return true end
    end

    return false
end

local function quality(itemBag, itemSlot)
    return tonumber(first(GetItemDisplayQuality, 0, itemBag, itemSlot)) or 0
end

local function collectBag(bag, depositOnly)
    local items = {}
    if bag == nil or type(GetBagSize) ~= "function" then return items end
    local size = tonumber(first(GetBagSize, 0, bag)) or 0
    local style = rawget(_G, "LINK_STYLE_DEFAULT") or 0

    for slot = 0, size - 1 do
        local link = tostring(first(GetItemLink, "", bag, slot, style) or "")
        if link ~= "" and (not depositOnly or isVaultFurnishing(bag, slot, link)) then
            local name = tostring(first(GetItemName, "", bag, slot) or "")
            local icon, stack, _, _, locked, _, _, displayQuality
            if type(GetItemInfo) == "function" then
                local ok
                ok, icon, stack, _, _, locked, _, _, displayQuality = pcall(GetItemInfo, bag, slot)
                if not ok then icon, stack, locked, displayQuality = nil, nil, false, nil end
            end
            stack = tonumber(stack) or tonumber(first(GetSlotStackSize, 1, bag, slot)) or 1
            displayQuality = tonumber(displayQuality) or quality(bag, slot)
            items[#items + 1] = {
                bag = bag,
                slot = slot,
                name = name,
                icon = tostring(icon or ""),
                stack = stack,
                quality = displayQuality,
                locked = locked == true,
                group = "FURNISHINGS",
                order = 10,
            }
        end
    end

    table.sort(items, function(a, b)
        if a.quality ~= b.quality then return a.quality > b.quality end
        return string.lower(a.name) < string.lower(b.name)
    end)
    return items
end

local baseRefresh = U.Refresh
local baseCollect = U.Collect
local baseMove = U.Move

function U:Collect(mode, ...)
    if vaultVisible() then
        local activeMode = vaultMode()
        if activeMode == "WITHDRAW" and mode == "WITHDRAW" then
            self.furnishingVaultDeposit029576 = false
            self.specialStorageNative029558 = nil
            return collectBag(rawget(_G, "BAG_FURNITURE_VAULT"), false)
        elseif activeMode == "DEPOSIT" and mode == "DEPOSIT" then
            self.furnishingVaultDeposit029576 = true
            self.specialStorageNative029558 = nil
            return collectBag(rawget(_G, "BAG_BACKPACK"), true)
        end
        return {}
    end
    if type(baseCollect) == "function" then return baseCollect(self, mode, ...) end
    return {}
end

local function emptySlot(bag)
    if bag == nil or type(FindFirstEmptySlotInBag) ~= "function" then return nil end
    return first(FindFirstEmptySlotInBag, nil, bag)
end

local function requestMove(sourceBag, sourceSlot, destBag, destSlot, count)
    local protected = false
    if type(IsProtectedFunction) == "function" then
        local ok, value = pcall(IsProtectedFunction, "RequestMoveItem")
        protected = ok and value == true
    end
    if protected and type(CallSecureProtected) == "function" then
        pcall(CallSecureProtected, "RequestMoveItem", sourceBag, sourceSlot, destBag, destSlot, count)
    elseif type(RequestMoveItem) == "function" then
        pcall(RequestMoveItem, sourceBag, sourceSlot, destBag, destSlot, count)
    end
end

function U:Move(item, ...)
    if vaultVisible() and item then
        local mode = vaultMode()
        if mode == "DEPOSIT" then
            if item.locked or not isVaultFurnishing(item.bag, item.slot) then return end
            local destBag = rawget(_G, "BAG_FURNITURE_VAULT")
            local destSlot = emptySlot(destBag)
            if destBag == nil or destSlot == nil then return end
            local count = tonumber(first(GetSlotStackSize, item.stack or 1, item.bag, item.slot)) or item.stack or 1
            requestMove(item.bag, item.slot, destBag, destSlot, count)
            return
        elseif mode == "WITHDRAW" then
            local destBag = rawget(_G, "BAG_BACKPACK")
            local destSlot = emptySlot(destBag)
            if destBag == nil or destSlot == nil then return end
            local count = tonumber(first(GetSlotStackSize, item.stack or 1, item.bag, item.slot)) or item.stack or 1
            requestMove(item.bag, item.slot, destBag, destSlot, count)
            return
        end
    end
    if type(baseMove) == "function" then return baseMove(self, item, ...) end
end

local function renderVault()
    local mode = vaultMode()
    if not mode then return false end
    local pane = getPane(mode)
    if not pane or type(pane.GetWidth) ~= "function" or type(pane.GetHeight) ~= "function" then return false end

    -- This explicit flag lets the older specialized-storage safety wrapper know
    -- that the Furnishing Vault grid owns both modes and must not be suppressed.
    U.furnishingVaultDeposit029576 = true
    U.furnishingVaultSuiteGrid029577 = true
    U.specialStorageNative029558 = nil

    restore(pane)
    local width = tonumber(first(pane.GetWidth, 0, pane)) or 0
    local height = tonumber(first(pane.GetHeight, 0, pane)) or 0
    if width <= 0 or height <= 0 then return false end

    local info = { mode = mode, control = pane, w = width, h = height }
    local ok, shown = pcall(U.Render, U, info)
    if not ok then return false end

    if shown then
        if U.title and type(U.title.SetText) == "function" then
            U.title:SetText("ESO ADVENTURER SUITE — FURNISHING VAULT — " .. mode)
        end
        if type(pane.SetAlpha) == "function" then pane:SetAlpha(0) end
        if type(pane.SetMouseEnabled) == "function" then pane:SetMouseEnabled(false) end
        return true
    end

    if U.root and type(U.root.SetHidden) == "function" then U.root:SetHidden(true) end
    return false
end

function U:Refresh(...)
    if vaultVisible() then
        if not renderVault() then
            local pane = getPane(vaultMode())
            restore(pane)
            if self.root and type(self.root.SetHidden) == "function" then self.root:SetHidden(true) end
        end
        return
    end

    self.furnishingVaultSuiteGrid029577 = false
    self.furnishingVaultDeposit029576 = false
    if type(baseRefresh) == "function" then return baseRefresh(self, ...) end
end

-- Refresh only on inventory changes/tab transitions in addition to the existing
-- BankGrid 150 ms renderer. No extra high-frequency update loop is added here.
local pending = false
local function requestRefresh()
    if pending then return end
    pending = true
    local function run()
        pending = false
        if U and U.Refresh then U:Refresh() end
    end
    if type(zo_callLater) == "function" then zo_callLater(run, 0) else run() end
end

if EVENT_MANAGER then
    local prefix = (EPC.name or "ESOAdventurerSuite") .. "_FurnitureVaultSuite029577"
    for _, eventName in ipairs({
        "EVENT_INVENTORY_FULL_UPDATE",
        "EVENT_INVENTORY_SINGLE_SLOT_UPDATE",
        "EVENT_PLAYER_ACTIVATED",
    }) do
        local eventCode = rawget(_G, eventName)
        if eventCode ~= nil then EVENT_MANAGER:RegisterForEvent(prefix .. "_" .. eventName, eventCode, requestRefresh) end
    end
end

requestRefresh()
