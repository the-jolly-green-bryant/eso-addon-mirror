-- ESO Adventurer Suite
-- v0.29.613 - House Storage Withdraw-only renderer correction.
-- Deposit stays owned by HouseStoragePureNativeFix.lua. Withdraw follows ESO's
-- HOUSE_BANK_FRAGMENT first, then reads ESO's filtered list/cache and finally the
-- active GetBankingBag() directly so the Suite grid cannot remain blank.

local EPC = ESOProgressionCoach
if not EPC or not WINDOW_MANAGER or not EVENT_MANAGER then return end

local wm = WINDOW_MANAGER
local ADDON = EPC.name or "ESOAdventurerSuite"
local NAME = ADDON .. "_HouseStorageWithdrawGrid029609"
local MAIN_PREFIX = ADDON .. "_HouseStorageGrid029594"
local CELL, GAP, HEADER_H = 48, 5, 28
local MAX_CELLS, MAX_HEADERS = 320, 64

local root
local cells, headers = {}, {}
local collapsed = {}
local scroll = 0
local contentHeight = 0
local generation = 0
local activeHouseBag

local function call1(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

local function fragmentShown(fragment)
    if not fragment then return false end
    if type(fragment.IsShowing) == "function" then
        local ok, shown = pcall(fragment.IsShowing, fragment)
        if ok and shown == true then return true end
    end
    if type(fragment.GetState) == "function" then
        local ok, state = pcall(fragment.GetState, fragment)
        if ok then
            return state == rawget(_G, "SCENE_FRAGMENT_SHOWING")
                or state == rawget(_G, "SCENE_FRAGMENT_SHOWN")
        end
    end
    return false
end

local function houseStorageActive()
    if fragmentShown(rawget(_G, "BACKPACK_HOUSE_BANK_LAYOUT_FRAGMENT")) then return true end
    if fragmentShown(rawget(_G, "HOUSE_BANK_FRAGMENT")) then return true end
    local sm = rawget(_G, "SCENE_MANAGER")
    if sm and type(sm.IsShowing) == "function" then
        local ok, shown = pcall(sm.IsShowing, sm, "houseBank")
        if ok and shown == true then return true end
    end
    return false
end

local function inventoryData(inventoryType)
    local manager = rawget(_G, "PLAYER_INVENTORY")
    if type(manager) ~= "table" or type(manager.inventories) ~= "table" or inventoryType == nil then return nil end
    local data = manager.inventories[inventoryType]
    return type(data) == "table" and data or nil
end

local function inventoryList(inventoryType, fallback)
    local data = inventoryData(inventoryType)
    if data then return data.listView or data.list or data.scrollList or rawget(_G, fallback) end
    return rawget(_G, fallback)
end

local function withdrawList()
    return inventoryList(rawget(_G, "INVENTORY_HOUSE_BANK"), "ZO_HouseBankBackpack")
end

local function depositList()
    return inventoryList(rawget(_G, "INVENTORY_BACKPACK"), "ZO_PlayerInventoryList")
end

local function currentMode()
    if not houseStorageActive() then return nil end

    -- ESO's House Bank tabs are fragment-driven. HOUSE_BANK_FRAGMENT is the
    -- authoritative Withdraw signal and must win over stale selectedTabType.
    if fragmentShown(rawget(_G, "HOUSE_BANK_FRAGMENT")) then return "WITHDRAW" end
    if fragmentShown(rawget(_G, "INVENTORY_FRAGMENT")) then return "DEPOSIT" end

    local manager = rawget(_G, "PLAYER_INVENTORY")
    local selected = type(manager) == "table" and tonumber(manager.selectedTabType) or nil
    local house = tonumber(rawget(_G, "INVENTORY_HOUSE_BANK"))
    local backpack = tonumber(rawget(_G, "INVENTORY_BACKPACK"))
    if selected ~= nil and house ~= nil and selected == house then return "WITHDRAW" end
    if selected ~= nil and backpack ~= nil and selected == backpack then return "DEPOSIT" end
    return nil
end

local function isHouseBag(bag)
    bag = tonumber(bag)
    if bag == nil then return false end
    if type(rawget(_G, "IsHouseBankBag")) == "function" then
        local ok, yes = pcall(IsHouseBankBag, bag)
        if ok then return yes == true end
    end
    local firstBag = tonumber(rawget(_G, "BAG_HOUSE_BANK_ONE"))
    local lastBag = tonumber(rawget(_G, "BAG_HOUSE_BANK_TEN"))
    return firstBag ~= nil and lastBag ~= nil and bag >= firstBag and bag <= lastBag
end

local function currentHouseBag()
    if type(rawget(_G, "GetBankingBag")) == "function" then
        local ok, bag = pcall(GetBankingBag)
        if ok and isHouseBag(bag) then
            activeHouseBag = tonumber(bag)
            EPC.HouseStorageActiveBag029611 = activeHouseBag
            return activeHouseBag
        end
    end

    local shared = tonumber(EPC.HouseStorageActiveBag029611)
    if isHouseBag(shared) then activeHouseBag = shared; return shared end
    if isHouseBag(activeHouseBag) then return activeHouseBag end

    local inventory = inventoryData(rawget(_G, "INVENTORY_HOUSE_BANK"))
    if inventory and type(inventory.backingBags) == "table" then
        for _, bag in ipairs(inventory.backingBags) do
            if isHouseBag(bag) then
                activeHouseBag = tonumber(bag)
                return activeHouseBag
            end
        end
    end
    return nil
end

local function groupFor(link)
    local grid = rawget(_G, "EASInventoryGrid")
    if grid and type(grid.GetExternalGroupName029364) == "function" then
        local ok, value = pcall(grid.GetExternalGroupName029364, grid, link)
        if ok and tostring(value or "") ~= "" then return tostring(value) end
    end
    return "Other"
end

local function safeStackCount(bag, slot, fallback)
    if type(rawget(_G, "GetSlotStackSize")) == "function" then
        local ok, value = pcall(GetSlotStackSize, bag, slot)
        if ok then
            value = tonumber(value)
            if value and value > 0 then return value end
        end
    end
    return math.max(1, tonumber(fallback) or 1)
end

local function itemFromData(data, fallbackBag, fallbackSlot)
    if type(data) ~= "table" then return nil end
    if data.easSuiteCategoryHeader029364 or data.easSuiteCategoryHeader029376
        or data.easSuiteHouseStorageHeader029592 or data.easSuiteHouseStorageHeader029594 then
        return nil
    end

    local bag = tonumber(data.bagId or data.bag or fallbackBag)
    local slot = tonumber(data.slotIndex or data.slot or fallbackSlot)
    if bag == nil or slot == nil then return nil end

    local link = tostring(data.itemLink or data.link or data.itemLinkString or "")
    if link == "" and type(rawget(_G, "GetItemLink")) == "function" then
        link = tostring(call1(GetItemLink, "", bag, slot, rawget(_G, "LINK_STYLE_DEFAULT") or 0) or "")
    end
    if link == "" then return nil end

    local icon = tostring(data.iconFile or data.icon or "")
    local stack = tonumber(data.stackCount) or safeStackCount(bag, slot, 1)
    local quality = tonumber(data.displayQuality or data.quality)
    local locked = data.locked == true or data.isPlayerLocked == true

    if type(rawget(_G, "GetItemInfo")) == "function" then
        local ok, i, s, _, _, l, _, _, q = pcall(GetItemInfo, bag, slot)
        if ok then
            if icon == "" then icon = tostring(i or "") end
            if not stack or stack <= 0 then stack = tonumber(s) or 1 end
            if quality == nil then quality = tonumber(q) end
            if l == true then locked = true end
        end
    end

    local name = tostring(data.name or "")
    if name == "" and type(rawget(_G, "GetItemName")) == "function" then
        name = tostring(call1(GetItemName, "", bag, slot) or "")
    end

    return {
        bag = bag,
        slot = slot,
        link = link,
        name = name,
        icon = icon,
        stack = tonumber(stack) or 1,
        quality = tonumber(quality) or 0,
        locked = locked,
        group = groupFor(link),
    }
end

local function passesNativeFilter(inventory, slotData)
    local manager = rawget(_G, "PLAYER_INVENTORY")
    if type(manager) ~= "table" or type(manager.ShouldAddSlotToList) ~= "function" then return true end
    if type(slotData) ~= "table" then return true end
    local ok, allowed = pcall(manager.ShouldAddSlotToList, manager, inventory, slotData)
    if not ok then return true end
    return allowed == true
end

local function sortItems(items)
    table.sort(items, function(a, b)
        if a.group ~= b.group then return string.lower(a.group) < string.lower(b.group) end
        if a.quality ~= b.quality then return a.quality > b.quality end
        return string.lower(a.name) < string.lower(b.name)
    end)
    return items
end

local function collectFromNativeList()
    local items = {}
    local list = withdrawList()
    if not list or type(rawget(_G, "ZO_ScrollList_GetDataList")) ~= "function" then return items end
    local ok, dataList = pcall(ZO_ScrollList_GetDataList, list)
    if not ok or type(dataList) ~= "table" then return items end

    for _, entry in ipairs(dataList) do
        local data = type(entry) == "table" and (entry.data or entry) or nil
        local item = itemFromData(data)
        if item then items[#items + 1] = item end
    end
    return sortItems(items)
end

local function collectFromInventoryCache(bag, inventory)
    local items = {}
    local slotTable = inventory and inventory.slots and inventory.slots[bag]
    if type(slotTable) ~= "table" then return items end

    for slotIndex, slotData in pairs(slotTable) do
        if type(slotData) == "table" and passesNativeFilter(inventory, slotData) then
            local item = itemFromData(slotData, bag, slotIndex)
            if item then items[#items + 1] = item end
        end
    end
    return sortItems(items)
end

local function filterIsDefault(inventory)
    if not inventory then return true end
    local all = rawget(_G, "ITEM_TYPE_DISPLAY_CATEGORY_ALL")
    if all ~= nil and inventory.currentFilter ~= nil and inventory.currentFilter ~= all then return false end
    local box = inventory.searchBox
    if box and type(box.GetText) == "function" then
        local ok, text = pcall(box.GetText, box)
        if ok and tostring(text or "") ~= "" then return false end
    end
    return true
end

local function collectFromBag(bag, inventory)
    local filtered, rawItems = {}, {}
    local shared = rawget(_G, "SHARED_INVENTORY")

    local function addSlot(slot)
        local data
        if type(shared) == "table" and type(shared.GenerateSingleSlotData) == "function" then
            local ok, value = pcall(shared.GenerateSingleSlotData, shared, bag, slot)
            if ok and type(value) == "table" then data = value end
        end
        local item = itemFromData(data or {}, bag, slot)
        if not item then return end
        rawItems[#rawItems + 1] = item
        if not data or passesNativeFilter(inventory, data) then filtered[#filtered + 1] = item end
    end

    if type(rawget(_G, "ZO_IterateBagSlots")) == "function" then
        for slot in ZO_IterateBagSlots(bag) do addSlot(slot) end
    elseif type(rawget(_G, "GetBagSize")) == "function" then
        local size = tonumber(call1(GetBagSize, 0, bag)) or 0
        for slot = 0, size - 1 do addSlot(slot) end
    end

    if #filtered > 0 then return sortItems(filtered) end
    if filterIsDefault(inventory) then return sortItems(rawItems) end
    return filtered
end

local function collectWithdraw()
    -- First use ESO's already filtered list when it is populated.
    local items = collectFromNativeList()
    if #items > 0 then return items end

    local bag = currentHouseBag()
    local inventory = inventoryData(rawget(_G, "INVENTORY_HOUSE_BANK"))
    if bag == nil or not inventory then return items end

    -- ESO's scene initializes inventory.slots[GetBankingBag()] before showing
    -- Withdraw. Prefer that cache because it contains ESO's filter/search data.
    items = collectFromInventoryCache(bag, inventory)
    if #items > 0 then return items end

    -- Final fallback: enumerate the actual opened storage bag directly.
    return collectFromBag(bag, inventory)
end

local function high(control, level)
    if not control then return end
    if type(control.SetDrawTier) == "function" and rawget(_G, "DT_HIGH") ~= nil then
        pcall(control.SetDrawTier, control, DT_HIGH)
    end
    if type(control.SetDrawLayer) == "function" and rawget(_G, "DL_OVERLAY") ~= nil then
        pcall(control.SetDrawLayer, control, DL_OVERLAY)
    end
    if type(control.SetDrawLevel) == "function" then pcall(control.SetDrawLevel, control, level or 1200) end
end

local renderWithdraw

local function ensureRoot()
    local list = withdrawList()
    if not list then return false end
    local parent = type(list.GetParent) == "function" and call1(list.GetParent, GuiRoot, list) or GuiRoot
    parent = parent or GuiRoot

    if not root then
        root = wm:CreateControl(NAME, parent, CT_CONTROL)
        root:SetMouseEnabled(true)
        high(root, 1200)
        root:SetHandler("OnMouseWheel", function(_, delta)
            local height = tonumber(call1(root.GetHeight, 0, root)) or 0
            local maxScroll = math.max(0, contentHeight - height + 4)
            scroll = math.max(0, math.min(maxScroll, scroll - (tonumber(delta) or 0) * 110))
            if currentMode() == "WITHDRAW" and type(renderWithdraw) == "function" then renderWithdraw() end
        end)
    elseif type(root.GetParent) == "function" and root:GetParent() ~= parent and type(root.SetParent) == "function" then
        pcall(root.SetParent, root, parent)
    end

    root:ClearAnchors()
    root:SetAnchor(TOPLEFT, list, TOPLEFT, 0, 0)
    root:SetAnchor(BOTTOMRIGHT, list, BOTTOMRIGHT, 0, 0)
    high(root, 1200)
    root._easRenderWithdraw029612 = renderWithdraw
    root._easRenderWithdraw029613 = renderWithdraw
    return true
end

local function clearPool()
    for _, h in ipairs(headers) do
        h.group = nil
        h:SetHidden(true)
        h:SetMouseEnabled(false)
    end
    for _, c in ipairs(cells) do
        c.item = nil
        c:SetHidden(true)
        c:SetMouseEnabled(false)
    end
end

local function getHeader(i)
    local h = headers[i]
    if h then return h end
    if i > MAX_HEADERS then return nil end

    h = wm:CreateControl(NAME .. "Header" .. i, root, CT_BUTTON)
    h:SetHeight(HEADER_H)
    high(h, 1220)

    local bg = wm:CreateControl(nil, h, CT_BACKDROP)
    bg:SetAnchorFill(h)
    bg:SetCenterColor(.035, .055, .08, 1)
    bg:SetEdgeColor(.35, .45, .55, 1)
    bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 1)
    bg:SetMouseEnabled(false)

    local label = wm:CreateControl(nil, h, CT_LABEL)
    label:SetAnchor(TOPLEFT, h, TOPLEFT, 8, 3)
    label:SetAnchor(BOTTOMRIGHT, h, BOTTOMRIGHT, -4, -3)
    label:SetFont("ZoFontGameBold")
    label:SetColor(1, .82, .26, 1)
    label:SetMouseEnabled(false)
    h.label = label

    h:SetHandler("OnClicked", function(control)
        if not control.group then return end
        collapsed[control.group] = not (collapsed[control.group] == true)
        scroll = 0
        if type(renderWithdraw) == "function" then renderWithdraw() end
    end)
    headers[i] = h
    return h
end

local function localWithdraw(item)
    if type(EPC.HouseStorageSafeMove029611) == "function" then
        local ok = pcall(EPC.HouseStorageSafeMove029611, item, "WITHDRAW")
        if ok then return end
    end
    if type(EPC.HouseStorageSafeMove029610) == "function" then
        local ok = pcall(EPC.HouseStorageSafeMove029610, item, "WITHDRAW")
        if ok then return end
    end

    local targetBag = rawget(_G, "BAG_BACKPACK")
    if targetBag == nil or type(rawget(_G, "FindFirstEmptySlotInBag")) ~= "function" then return end
    local targetSlot = call1(FindFirstEmptySlotInBag, nil, targetBag)
    if targetSlot == nil then return end
    local count = safeStackCount(item.bag, item.slot, item.stack)

    if type(rawget(_G, "IsProtectedFunction")) == "function" then
        local ok, protected = pcall(IsProtectedFunction, "RequestMoveItem")
        if ok and protected == true and type(rawget(_G, "CallSecureProtected")) == "function" then
            pcall(CallSecureProtected, "RequestMoveItem", item.bag, item.slot, targetBag, targetSlot, count)
            return
        end
    end
    if type(rawget(_G, "RequestMoveItem")) == "function" then
        pcall(RequestMoveItem, item.bag, item.slot, targetBag, targetSlot, count)
    end
end

local function getCell(i)
    local c = cells[i]
    if c then return c end
    if i > MAX_CELLS then return nil end

    c = wm:CreateControl(NAME .. "Cell" .. i, root, CT_BUTTON)
    c:SetDimensions(CELL, CELL)
    c:SetMouseEnabled(true)
    high(c, 1250)

    local bg = wm:CreateControl(nil, c, CT_BACKDROP)
    bg:SetAnchorFill(c)
    bg:SetCenterColor(.06, .07, .09, 1)
    bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 2)
    bg:SetMouseEnabled(false)
    c.bg = bg

    local icon = wm:CreateControl(nil, c, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, c, TOPLEFT, 3, 3)
    icon:SetAnchor(BOTTOMRIGHT, c, BOTTOMRIGHT, -3, -3)
    icon:SetTextureCoords(.05, .95, .05, .95)
    icon:SetMouseEnabled(false)
    c.icon = icon

    local count = wm:CreateControl(nil, c, CT_LABEL)
    count:SetAnchor(BOTTOMRIGHT, c, BOTTOMRIGHT, -2, -1)
    count:SetDimensions(28, 14)
    count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    count:SetFont("ZoFontGameSmall")
    count:SetColor(1, 1, 1, 1)
    count:SetMouseEnabled(false)
    c.count = count

    c:SetHandler("OnMouseEnter", function(control)
        if control.item and ItemTooltip and type(rawget(_G, "InitializeTooltip")) == "function" then
            InitializeTooltip(ItemTooltip, control, LEFT, -8, 0, RIGHT)
            if type(ItemTooltip.SetBagItem) == "function" then
                pcall(ItemTooltip.SetBagItem, ItemTooltip, control.item.bag, control.item.slot)
            end
        end
    end)
    c:SetHandler("OnMouseExit", function()
        if ItemTooltip and type(rawget(_G, "ClearTooltip")) == "function" then pcall(ClearTooltip, ItemTooltip) end
    end)
    c:SetHandler("OnMouseUp", function(control, button, inside)
        if inside == false or type(control.item) ~= "table" then return end
        local left = rawget(_G, "MOUSE_BUTTON_INDEX_LEFT")
        if button == left then localWithdraw(control.item) end
    end)

    cells[i] = c
    return c
end

local function qualityColor(q)
    local colorType = rawget(_G, "INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS")
    if type(rawget(_G, "GetInterfaceColor")) == "function" and colorType ~= nil then
        local ok, r, g, b = pcall(GetInterfaceColor, colorType, tonumber(q) or 0)
        if ok and r ~= nil then return r, g, b end
    end
    return .35, .42, .50
end

local function hideNativeWithdrawList()
    local list = withdrawList()
    if not list then return end
    if type(list.SetAlpha) == "function" then pcall(list.SetAlpha, list, 0) end
    if type(list.SetMouseEnabled) == "function" then pcall(list.SetMouseEnabled, list, false) end
end

renderWithdraw = function()
    if currentMode() ~= "WITHDRAW" then
        if root then root:SetHidden(true) end
        return false
    end
    if not ensureRoot() then return false end

    local mainRoot = rawget(_G, MAIN_PREFIX)
    if mainRoot and type(mainRoot.SetHidden) == "function" then pcall(mainRoot.SetHidden, mainRoot, true) end

    local items = collectWithdraw()
    clearPool()
    root:SetHidden(false)
    root:SetAlpha(1)
    root:SetMouseEnabled(true)
    high(root, 1200)

    local groups, order = {}, {}
    for _, item in ipairs(items) do
        if not groups[item.group] then
            groups[item.group] = {}
            order[#order + 1] = item.group
        end
        groups[item.group][#groups[item.group] + 1] = item
    end
    table.sort(order, function(a, b) return string.lower(a) < string.lower(b) end)

    local width = tonumber(call1(root.GetWidth, 500, root)) or 500
    local height = tonumber(call1(root.GetHeight, 0, root)) or 0
    local cols = math.max(4, math.floor((width - 16) / (CELL + GAP)))
    local y, hi, ci = 0, 0, 0

    for _, group in ipairs(order) do
        hi = hi + 1
        local headerY = y - scroll
        local h = getHeader(hi)
        if h then
            h.group = group
            h.label:SetText((collapsed[group] and "+  " or "-  ") .. group .. "  (" .. tostring(#groups[group]) .. ")")
            h:ClearAnchors()
            h:SetAnchor(TOPLEFT, root, TOPLEFT, 4, headerY)
            h:SetWidth(width - 12)
            local visible = headerY >= 0 and (headerY + HEADER_H) <= height
            h:SetHidden(not visible)
            h:SetMouseEnabled(visible)
            high(h, 1220)
        end
        y = y + HEADER_H + GAP

        if not collapsed[group] then
            local rows = math.ceil(#groups[group] / cols)
            for i, item in ipairs(groups[group]) do
                ci = ci + 1
                if ci > MAX_CELLS then break end
                local c = getCell(ci)
                if not c then break end

                c.item = item
                local col = (i - 1) % cols
                local row = math.floor((i - 1) / cols)
                local cellY = y + row * (CELL + GAP) - scroll
                c:ClearAnchors()
                c:SetAnchor(TOPLEFT, root, TOPLEFT, 4 + col * (CELL + GAP), cellY)
                c.icon:SetTexture(item.icon ~= "" and item.icon or "EsoUI/Art/Icons/icon_missing.dds")
                c.count:SetText(item.stack > 1 and tostring(item.stack) or "")
                local r, g, b = qualityColor(item.quality)
                c.bg:SetEdgeColor(r, g, b, 1)

                local visible = cellY >= 0 and (cellY + CELL) <= height
                c:SetHidden(not visible)
                c:SetMouseEnabled(visible)
                high(c, 1250)
            end
            y = y + rows * (CELL + GAP) + GAP
        end
    end

    contentHeight = y
    local maxScroll = math.max(0, contentHeight - height + 4)
    if scroll > maxScroll then
        scroll = maxScroll
        return renderWithdraw()
    end

    hideNativeWithdrawList()
    return true
end

-- Deposit containment below is intentionally kept as-is; Deposit remains owned
-- by HouseStoragePureNativeFix.lua.
local function geometry(control)
    if not control then return nil end
    local l = tonumber(call1(control.GetLeft, nil, control))
    local t = tonumber(call1(control.GetTop, nil, control))
    local r = tonumber(call1(control.GetRight, nil, control))
    local b = tonumber(call1(control.GetBottom, nil, control))
    if not l or not t or not r or not b then return nil end
    return l, t, r, b
end

local function clipDepositGrid()
    if currentMode() ~= "DEPOSIT" then return end
    local viewport = depositList()
    local vl, vt, vr, vb = geometry(viewport)
    if not vl then return end

    for i = 1, MAX_HEADERS do
        local c = rawget(_G, MAIN_PREFIX .. "Header" .. i)
        if c and c.group ~= nil then
            local l, t, r, b = geometry(c)
            if l then
                local contained = l >= vl and r <= vr and t >= vt and b <= vb
                if type(c.SetHidden) == "function" then c:SetHidden(not contained) end
                if type(c.SetMouseEnabled) == "function" then c:SetMouseEnabled(contained) end
            end
        end
    end

    for i = 1, MAX_CELLS do
        local c = rawget(_G, MAIN_PREFIX .. "Cell" .. i)
        if c and c.item ~= nil then
            local l, t, r, b = geometry(c)
            if l then
                local contained = l >= vl and r <= vr and t >= vt and b <= vb
                if type(c.SetHidden) == "function" then c:SetHidden(not contained) end
                if type(c.SetMouseEnabled) == "function" then c:SetMouseEnabled(contained) end
            end
        end
    end
end

local function installDepositWheelClip()
    local mainRoot = rawget(_G, MAIN_PREFIX)
    if not mainRoot or mainRoot._easHouseStorageHardClip029612 then return end
    mainRoot._easHouseStorageHardClip029612 = true
    if type(rawget(_G, "ZO_PostHookHandler")) == "function" then
        pcall(ZO_PostHookHandler, mainRoot, "OnMouseWheel", function()
            if type(rawget(_G, "zo_callLater")) == "function" then zo_callLater(clipDepositGrid, 0) else clipDepositGrid() end
        end)
    end
end

local function refresh()
    if not houseStorageActive() then return end
    installDepositWheelClip()
    if currentMode() == "WITHDRAW" then
        renderWithdraw()
    else
        if root then root:SetHidden(true) end
        clipDepositGrid()
    end
end

local function scheduleRefresh()
    if not houseStorageActive() then return end
    generation = generation + 1
    local mine = generation
    refresh()
    if type(rawget(_G, "zo_callLater")) ~= "function" then return end
    for _, delay in ipairs({ 0, 35, 90, 180, 340 }) do
        zo_callLater(function()
            if mine == generation and houseStorageActive() then refresh() end
        end, delay)
    end
end

local manager = rawget(_G, "PLAYER_INVENTORY")
if type(manager) == "table" and type(rawget(_G, "ZO_PostHook")) == "function" then
    for _, methodName in ipairs({ "UpdateList", "ChangeFilter", "ChangeSort" }) do
        if type(manager[methodName]) == "function" then
            pcall(ZO_PostHook, manager, methodName, function()
                if houseStorageActive() then scheduleRefresh() end
            end)
        end
    end
end

for _, fragmentName in ipairs({ "HOUSE_BANK_FRAGMENT", "INVENTORY_FRAGMENT", "BACKPACK_HOUSE_BANK_LAYOUT_FRAGMENT" }) do
    local fragment = rawget(_G, fragmentName)
    if fragment and type(fragment.RegisterCallback) == "function" then
        fragment:RegisterCallback("StateChange", function(_, newState)
            if newState == rawget(_G, "SCENE_FRAGMENT_SHOWING") or newState == rawget(_G, "SCENE_FRAGMENT_SHOWN") then
                scroll = 0
                currentHouseBag()
                scheduleRefresh()
            end
        end)
    end
end

local sm = rawget(_G, "SCENE_MANAGER")
if sm and type(sm.GetScene) == "function" then
    local scene = sm:GetScene("houseBank")
    if scene and type(scene.RegisterCallback) == "function" then
        scene:RegisterCallback("StateChange", function(_, newState)
            if newState == rawget(_G, "SCENE_SHOWING") or newState == rawget(_G, "SCENE_SHOWN") then
                activeHouseBag = nil
                scroll = 0
                currentHouseBag()
                scheduleRefresh()
            elseif newState == rawget(_G, "SCENE_HIDING") or newState == rawget(_G, "SCENE_HIDDEN") then
                generation = generation + 1
                activeHouseBag = nil
                scroll = 0
                if root then root:SetHidden(true) end
            end
        end)
    end
end

if rawget(_G, "EVENT_OPEN_BANK") ~= nil then
    EVENT_MANAGER:RegisterForEvent(NAME .. "OpenBank", EVENT_OPEN_BANK, function()
        activeHouseBag = nil
        currentHouseBag()
        scroll = 0
        if houseStorageActive() then scheduleRefresh() end
    end)
end

for _, eventName in ipairs({ "EVENT_INVENTORY_FULL_UPDATE", "EVENT_INVENTORY_SINGLE_SLOT_UPDATE" }) do
    local code = rawget(_G, eventName)
    if code ~= nil then
        EVENT_MANAGER:RegisterForEvent(NAME .. eventName, code, function()
            if currentMode() == "WITHDRAW" then scheduleRefresh() end
        end)
    end
end

if type(rawget(_G, "zo_callLater")) == "function" then
    zo_callLater(function()
        if houseStorageActive() then
            currentHouseBag()
            refresh()
        end
    end, 0)
end
