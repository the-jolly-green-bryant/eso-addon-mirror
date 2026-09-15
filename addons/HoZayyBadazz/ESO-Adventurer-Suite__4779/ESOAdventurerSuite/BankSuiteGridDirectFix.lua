-- ESO Adventurer Suite
-- v0.29.525 - robust live bank pane takeover.
-- Resolve the actually visible ESO/PerfectPixel bank scroll list at runtime,
-- then anchor the Suite grid to the list parent instead of the list we hide.

local EPC = ESOProgressionCoach
if not EPC or not WINDOW_MANAGER then return end
local M = EPC.BankSuiteGridFix
if not M then return end

local wm = WINDOW_MANAGER
local UPDATE_NAME = (EPC.name or "ESOAdventurerSuite") .. "_BankSuiteGridDirect029525"
local CELL, GAP, HEADER_H, MAX_CELLS = 46, 5, 28, 320

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a, b, c, d
end

local function isVisible(control)
    return control and type(control.IsHidden) == "function" and safe(control.IsHidden, true, control) == false
end

local function atBank()
    if type(GetInteractionType) == "function" then
        local interaction = safe(GetInteractionType, nil)
        if interaction ~= nil and interaction == rawget(_G, "INTERACTION_BANK") then return true end
    end
    local inv = rawget(_G, "PLAYER_INVENTORY")
    if type(inv) == "table" and type(inv.IsBanking) == "function" then
        local ok, value = pcall(inv.IsBanking, inv)
        if ok and value == true then return true end
    end
    return false
end

local function getInventoryList(inventoryType)
    local inv = rawget(_G, "PLAYER_INVENTORY")
    if type(inv) ~= "table" or type(inv.inventories) ~= "table" or inventoryType == nil then return nil end
    local data = inv.inventories[inventoryType]
    if type(data) ~= "table" then return nil end
    return data.listView or data.list or data.scrollList
end

local function entryBag(entry)
    local data = type(entry) == "table" and (entry.data or entry) or nil
    if type(data) ~= "table" then return nil end
    return tonumber(data.bagId or data.bag or data.bagIndex)
end

local function classifyListByRows(list)
    if not list or type(ZO_ScrollList_GetDataList) ~= "function" then return nil end
    local ok, dataList = pcall(ZO_ScrollList_GetDataList, list)
    if not ok or type(dataList) ~= "table" then return nil end
    local backpack, bank = rawget(_G, "BAG_BACKPACK"), rawget(_G, "BAG_BANK")
    local subscriber = rawget(_G, "BAG_SUBSCRIBER_BANK")
    for _, entry in ipairs(dataList) do
        local bag = entryBag(entry)
        if bag ~= nil then
            if bag == bank or bag == subscriber then return "WITHDRAW" end
            if bag == backpack then return "DEPOSIT" end
        end
    end
    return nil
end

local function addCandidate(out, seen, control)
    if not control or seen[control] or type(ZO_ScrollList_GetDataList) ~= "function" then return end
    local ok, data = pcall(ZO_ScrollList_GetDataList, control)
    if ok and type(data) == "table" then
        seen[control] = true
        out[#out + 1] = control
    end
end

local function walkVisibleScrollLists(out, seen, root, depth)
    if not root or depth > 7 then return end
    addCandidate(out, seen, root)
    if type(root.GetNumChildren) ~= "function" or type(root.GetChild) ~= "function" then return end
    local count = tonumber(safe(root.GetNumChildren, 0, root)) or 0
    for i = 1, math.min(count, 140) do
        local child = safe(root.GetChild, nil, root, i)
        if child then walkVisibleScrollLists(out, seen, child, depth + 1) end
    end
end

local function resolveLiveModeAndList()
    if not atBank() then return nil, nil end

    local bankList = getInventoryList(rawget(_G, "INVENTORY_BANK")) or rawget(_G, "ZO_PlayerBankBackpack")
    local backpackList = getInventoryList(rawget(_G, "INVENTORY_BACKPACK")) or rawget(_G, "ZO_PlayerInventoryList")

    -- ESO's own visibility is authoritative when available.
    if isVisible(bankList) then return "WITHDRAW", bankList end
    if isVisible(backpackList) then return "DEPOSIT", backpackList end

    -- PerfectPixel/other UI replacements can wrap the stock list. Walk only the
    -- known inventory roots and identify the visible scroll list by its row bags.
    local candidates, seen = {}, {}
    for _, root in ipairs({
        rawget(_G, "ZO_PlayerBank"), rawget(_G, "ZO_PlayerBankTopLevel"),
        rawget(_G, "ZO_PlayerInventory"), rawget(_G, "ZO_PlayerInventoryTopLevel"),
    }) do
        walkVisibleScrollLists(candidates, seen, root, 0)
    end
    for _, list in ipairs(candidates) do
        if isVisible(list) then
            local mode = classifyListByRows(list)
            if mode then return mode, list end
        end
    end
    return nil, nil
end

local function qualityColor(q)
    q = tonumber(q) or 0
    local colorType = rawget(_G, "INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS")
    if type(GetInterfaceColor) == "function" and colorType ~= nil then
        local r, g, b = safe(GetInterfaceColor, nil, colorType, q)
        if r ~= nil then return r, g, b end
    end
    return 0.35, 0.42, 0.50
end

local function findDestination(srcBag, srcSlot, targetBags)
    local linkStyle = rawget(_G, "LINK_STYLE_DEFAULT") or 0
    local srcLink = tostring(safe(GetItemLink, "", srcBag, srcSlot, linkStyle) or "")
    local srcCount = tonumber(safe(GetSlotStackSize, 1, srcBag, srcSlot)) or 1
    for _, bag in ipairs(targetBags) do
        if bag ~= nil and type(GetBagSize) == "function" then
            local size = tonumber(safe(GetBagSize, 0, bag)) or 0
            for slot = 0, size - 1 do
                local link = tostring(safe(GetItemLink, "", bag, slot, linkStyle) or "")
                if srcLink ~= "" and link == srcLink then
                    local count, maxStack = safe(GetSlotStackSize, nil, bag, slot)
                    count, maxStack = tonumber(count), tonumber(maxStack)
                    if count and maxStack and count < maxStack then
                        return bag, slot, math.min(srcCount, maxStack - count)
                    end
                end
            end
            if type(FindFirstEmptySlotInBag) == "function" then
                local empty = safe(FindFirstEmptySlotInBag, nil, bag)
                if empty ~= nil then return bag, empty, srcCount end
            end
        end
    end
    return nil
end

function M:MoveItem(item)
    if not item or not atBank() then return end
    local activeMode = self.liveBankMode029525
    if activeMode ~= "WITHDRAW" and activeMode ~= "DEPOSIT" then return end
    local srcBag, srcSlot = tonumber(item.bag), tonumber(item.slot)
    if srcBag == nil or srcSlot == nil then return end

    local targets = activeMode == "WITHDRAW"
        and { rawget(_G, "BAG_BACKPACK") }
        or { rawget(_G, "BAG_BANK"), rawget(_G, "BAG_SUBSCRIBER_BANK") }
    local dstBag, dstSlot, count = findDestination(srcBag, srcSlot, targets)
    if dstBag == nil or dstSlot == nil then
        if type(ZO_Alert) == "function" then pcall(ZO_Alert, UI_ALERT_CATEGORY_ERROR, nil, "No space available.") end
        return
    end

    local protected = type(IsProtectedFunction) == "function" and safe(IsProtectedFunction, false, "RequestMoveItem") == true
    if protected and type(CallSecureProtected) == "function" then
        pcall(CallSecureProtected, "RequestMoveItem", srcBag, srcSlot, dstBag, dstSlot, count)
    elseif type(RequestMoveItem) == "function" then
        pcall(RequestMoveItem, srcBag, srcSlot, dstBag, dstSlot, count)
    end
    if type(zo_callLater) == "function" then zo_callLater(function() if M then M:Refresh(true) end end, 80) end
end

function M:Refresh(force)
    local activeMode, native = resolveLiveModeAndList()
    if not activeMode or not native then
        if self.frame then self.frame:SetHidden(true) end
        if type(self.RestoreNative) == "function" then self:RestoreNative() end
        self.lastMode, self.liveBankMode029525, self.bankGridActive029525 = nil, nil, false
        return
    end

    self:Create()
    if not self.frame or not self.child then return end

    if self.lastMode ~= activeMode then
        if type(self.RestoreNative) == "function" then self:RestoreNative() end
        self.lastMode = activeMode
        force = true
    end
    self.liveBankMode029525 = activeMode
    self.bankGridActive029525 = true

    -- Capture the list geometry BEFORE hiding it. Anchor the Suite grid to the
    -- visible list's parent, so hiding the list cannot hide/invalidate our frame.
    local parent = type(native.GetParent) == "function" and safe(native.GetParent, nil, native) or nil
    local width = math.max(220, tonumber(safe(native.GetWidth, 500, native)) or 500)
    local height = math.max(180, tonumber(safe(native.GetHeight, 520, native)) or 520)
    local x, y = 0, 0
    if parent and type(native.GetLeft) == "function" and type(parent.GetLeft) == "function" then
        local nl, nt = tonumber(safe(native.GetLeft, 0, native)) or 0, tonumber(safe(native.GetTop, 0, native)) or 0
        local pl, pt = tonumber(safe(parent.GetLeft, 0, parent)) or 0, tonumber(safe(parent.GetTop, 0, parent)) or 0
        x, y = nl - pl, nt - pt
    end

    self.hiddenNative = self.hiddenNative or {}
    if self.hiddenNative[native] == nil and type(native.IsHidden) == "function" then
        self.hiddenNative[native] = safe(native.IsHidden, false, native) == true
    end
    if type(native.SetHidden) == "function" then pcall(native.SetHidden, native, true) end

    self.frame:ClearAnchors()
    if parent then
        self.frame:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
        self.frame:SetDimensions(width, height)
    else
        self.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
        self.frame:SetDimensions(width, height)
    end
    self.frame:SetHidden(false)
    if self.title then self.title:SetText(activeMode == "WITHDRAW" and "WITHDRAW - BANK" or "DEPOSIT - BACKPACK") end

    local items = self:CollectItems(activeMode)
    local cols = math.max(4, math.floor((width - 18) / (CELL + GAP)))
    local grouped, order = {}, {}
    for _, item in ipairs(items) do
        if not grouped[item.group] then grouped[item.group] = {}; order[#order + 1] = item.group end
        grouped[item.group][#grouped[item.group] + 1] = item
    end
    table.sort(order, function(a, b)
        return ((grouped[a][1] and grouped[a][1].order) or 90) < ((grouped[b][1] and grouped[b][1].order) or 90)
    end)

    self.collapsed = self.collapsed or { WITHDRAW = {}, DEPOSIT = {} }
    self.collapsed[activeMode] = self.collapsed[activeMode] or {}

    local yPos, hi, ci = 2, 0, 0
    for _, group in ipairs(order) do
        hi = hi + 1
        local h = self:GetHeader(hi)
        h:SetHidden(false)
        h:ClearAnchors()
        h:SetAnchor(TOPLEFT, self.child, TOPLEFT, 2, yPos)
        h:SetWidth(width - 20)
        h.mode, h.group = activeMode, group
        local collapsed = self.collapsed[activeMode][group] == true
        h.label:SetText((collapsed and "+  " or "-  ") .. group .. "  (" .. tostring(#grouped[group]) .. ")")
        yPos = yPos + HEADER_H + GAP
        if not collapsed then
            for i, item in ipairs(grouped[group]) do
                ci = ci + 1
                if ci > MAX_CELLS then break end
                local c = self:GetCell(ci)
                c:SetHidden(false)
                c.item = item
                c:ClearAnchors()
                local col, row = (i - 1) % cols, math.floor((i - 1) / cols)
                c:SetAnchor(TOPLEFT, self.child, TOPLEFT, 2 + col * (CELL + GAP), yPos + row * (CELL + GAP))
                c.icon:SetTexture(item.icon ~= "" and item.icon or "EsoUI/Art/Icons/icon_missing.dds")
                c.count:SetText(item.stack > 1 and tostring(item.stack) or "")
                local r, g, b = qualityColor(item.quality)
                c.bg:SetEdgeColor(r, g, b, 1)
                c.bg:SetCenterColor(0.05 + r * 0.16, 0.06 + g * 0.16, 0.08 + b * 0.16, 0.985)
            end
            yPos = yPos + math.ceil(#grouped[group] / cols) * (CELL + GAP) + GAP
        end
    end

    for i = hi + 1, #(self.headers or {}) do self.headers[i]:SetHidden(true) end
    for i = ci + 1, #(self.cells or {}) do self.cells[i]:SetHidden(true); self.cells[i].item = nil end
    self.child:SetHeight(math.max(yPos + 8, 100))
end

-- Replace the earlier polling callback with this final implementation.
if EVENT_MANAGER then
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 150, function() M:Refresh(false) end)
end
if type(zo_callLater) == "function" then
    zo_callLater(function() if M then M:Refresh(true) end end, 50)
    zo_callLater(function() if M then M:Refresh(true) end end, 350)
else
    M:Refresh(true)
end
