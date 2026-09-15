-- ESO Adventurer Suite
-- v0.29.607 - House Storage single-owner stable Suite grid.
-- ESO owns filtering/search/sort and secure inventory data. This module alone owns
-- House Storage presentation: it reads native rows, renders the Suite grid, and
-- suppresses only the native row visuals after the data has been captured.

local EPC = ESOProgressionCoach
if not EPC or not WINDOW_MANAGER then return end

local U = EPC.BankGridUnifiedV2
local wm = WINDOW_MANAGER
local NAME = (EPC.name or "ESOAdventurerSuite") .. "_HouseStorageGrid029594"
local CELL, GAP, HEADER_H, MAX_CELLS = 48, 5, 28, 320
local MAX_HEADERS = 64

local root
local cells, headers = {}, {}
local collapsed = { WITHDRAW = {}, DEPOSIT = {} }
local scroll = { WITHDRAW = 0, DEPOSIT = 0 }
local cachedItems = { WITHDRAW = nil, DEPOSIT = nil }
local cachedSignature = { WITHDRAW = nil, DEPOSIT = nil }
local emptyPasses = { WITHDRAW = 0, DEPOSIT = 0 }
local nativeVisualState = setmetatable({}, { __mode = "k" })
local sessionGeneration = 0
local refreshGeneration = 0
local activeNativeList, currentMode
local contentHeight = 0
local render

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d, e = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a, b, c, d, e
end

local function fragmentShown(fragment)
    if not fragment then return false end
    if type(fragment.IsShowing) == "function" then
        local ok, value = pcall(fragment.IsShowing, fragment)
        if ok and value == true then return true end
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

local function controlEffectivelyShown(control)
    if not control then return false end
    if type(rawget(_G, "IsControlHidden")) == "function" then
        local ok, hidden = pcall(IsControlHidden, control)
        if ok then return hidden == false end
    end
    if type(control.IsHidden) == "function" then
        return first(control.IsHidden, true, control) == false
    end
    return false
end

local function houseStorageActive()
    if fragmentShown(rawget(_G, "BACKPACK_HOUSE_BANK_LAYOUT_FRAGMENT")) then return true end
    local sm = rawget(_G, "SCENE_MANAGER")
    if sm and type(sm.IsShowing) == "function" then
        local ok, value = pcall(sm.IsShowing, sm, "houseBank")
        if ok and value == true then return true end
    end
    return fragmentShown(rawget(_G, "HOUSE_BANK_FRAGMENT"))
        or fragmentShown(rawget(_G, "HOUSE_BANK_MENU_FRAGMENT"))
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

local function modeAndList()
    local withdraw = withdrawList()
    local deposit = depositList()
    local manager = rawget(_G, "PLAYER_INVENTORY")
    local selected = type(manager) == "table" and tonumber(manager.selectedTabType) or nil
    local backpackType = tonumber(rawget(_G, "INVENTORY_BACKPACK"))
    local houseType = tonumber(rawget(_G, "INVENTORY_HOUSE_BANK"))

    if selected ~= nil then
        if backpackType ~= nil and selected == backpackType and deposit then
            return "DEPOSIT", deposit
        end
        if houseType ~= nil and selected == houseType and withdraw then
            return "WITHDRAW", withdraw
        end
    end

    local ws = controlEffectivelyShown(withdraw)
    local ds = controlEffectivelyShown(deposit)
    if ds and not ws then return "DEPOSIT", deposit end
    if ws and not ds then return "WITHDRAW", withdraw end

    if fragmentShown(rawget(_G, "INVENTORY_FRAGMENT"))
        and not fragmentShown(rawget(_G, "HOUSE_BANK_FRAGMENT")) then
        return "DEPOSIT", deposit
    end
    if fragmentShown(rawget(_G, "HOUSE_BANK_FRAGMENT")) then
        return "WITHDRAW", withdraw
    end

    if currentMode == "DEPOSIT" and deposit then return "DEPOSIT", deposit end
    return "WITHDRAW", withdraw
end

local function addUnique(out, seen, control)
    if control == nil or seen[control] then return end
    seen[control] = true
    out[#out + 1] = control
end

local function nativeVisualControls()
    local out, seen = {}, {}
    local manager = rawget(_G, "PLAYER_INVENTORY")

    local function addInventory(inventoryType)
        if type(manager) ~= "table" or type(manager.inventories) ~= "table" or inventoryType == nil then return end
        local data = manager.inventories[inventoryType]
        if type(data) ~= "table" then return end
        addUnique(out, seen, data.listView)
        addUnique(out, seen, data.list)
        addUnique(out, seen, data.scrollList)
    end

    addInventory(rawget(_G, "INVENTORY_HOUSE_BANK"))
    addInventory(rawget(_G, "INVENTORY_BACKPACK"))

    for _, name in ipairs({
        "ZO_HouseBankBackpack",
        "ZO_HouseBankBackpackList",
        "ZO_HouseBankBackpackListContents",
        "ZO_PlayerInventoryList",
        "ZO_PlayerInventoryListList",
        "ZO_PlayerInventoryListContents",
    }) do
        addUnique(out, seen, rawget(_G, name))
    end
    return out
end

local function isRootAncestor(control)
    if not root or not control then return false end
    local node = root
    for _ = 1, 20 do
        if node == control then return true end
        if type(node.GetParent) ~= "function" then break end
        local ok, parent = pcall(node.GetParent, node)
        if not ok or not parent or parent == node then break end
        node = parent
    end
    return false
end

local function suppressNativeVisuals()
    if not houseStorageActive() then return end
    for _, control in ipairs(nativeVisualControls()) do
        if control and not isRootAncestor(control) then
            if nativeVisualState[control] == nil then
                local alpha, mouseEnabled = 1, true
                if type(control.GetAlpha) == "function" then
                    local ok, value = pcall(control.GetAlpha, control)
                    if ok and tonumber(value) then alpha = tonumber(value) end
                end
                if type(control.IsMouseEnabled) == "function" then
                    local ok, value = pcall(control.IsMouseEnabled, control)
                    if ok then mouseEnabled = value == true end
                end
                nativeVisualState[control] = { alpha = alpha, mouseEnabled = mouseEnabled }
            end
            if type(control.SetAlpha) == "function" then pcall(control.SetAlpha, control, 0) end
            if type(control.SetMouseEnabled) == "function" then pcall(control.SetMouseEnabled, control, false) end
        end
    end
end

local function restoreNativeVisuals()
    for control, state in pairs(nativeVisualState) do
        if control and type(control.SetAlpha) == "function" then
            pcall(control.SetAlpha, control, tonumber(state.alpha) or 1)
        end
        if control and type(control.SetMouseEnabled) == "function" then
            pcall(control.SetMouseEnabled, control, state.mouseEnabled == true)
        end
        nativeVisualState[control] = nil
    end
end

local function itemFromEntry(entry)
    local data = type(entry) == "table" and (entry.data or entry) or nil
    if type(data) ~= "table" then return nil end
    if data.easSuiteCategoryHeader029364 or data.easSuiteCategoryHeader029376
        or data.easSuiteHouseStorageHeader029592 or data.easSuiteHouseStorageHeader029594 then
        return nil
    end

    local bag = tonumber(data.bagId or data.bag)
    local slot = tonumber(data.slotIndex or data.slot)
    if bag == nil or slot == nil then return nil end

    local link = tostring(data.itemLink or data.link or data.itemLinkString or "")
    if link == "" and type(rawget(_G, "GetItemLink")) == "function" then
        link = tostring(first(GetItemLink, "", bag, slot, rawget(_G, "LINK_STYLE_DEFAULT") or 0) or "")
    end
    if link == "" then return nil end

    local icon, stack, _, _, locked, _, _, quality
    if type(rawget(_G, "GetItemInfo")) == "function" then
        local ok
        ok, icon, stack, _, _, locked, _, _, quality = pcall(GetItemInfo, bag, slot)
        if not ok then icon, stack, locked, quality = nil, nil, false, nil end
    end

    local name = tostring(first(GetItemName, "", bag, slot) or data.name or "")
    stack = tonumber(stack) or tonumber(data.stackCount) or tonumber(first(GetSlotStackSize, 1, bag, slot)) or 1
    quality = tonumber(quality) or tonumber(data.displayQuality) or tonumber(first(GetItemDisplayQuality, 0, bag, slot)) or 0

    local group = "Other"
    local grid = rawget(_G, "EASInventoryGrid")
    if grid and type(grid.GetExternalGroupName029364) == "function" then
        local ok, value = pcall(grid.GetExternalGroupName029364, grid, link)
        if ok and tostring(value or "") ~= "" then group = tostring(value) end
    end

    return {
        bag = bag, slot = slot, link = link, name = name,
        icon = tostring(icon or data.iconFile or ""), stack = stack,
        quality = quality, locked = locked == true, group = group,
    }
end

local function collectFromNative(list)
    local items = {}
    if not list or type(rawget(_G, "ZO_ScrollList_GetDataList")) ~= "function" then return items end
    local ok, dataList = pcall(ZO_ScrollList_GetDataList, list)
    if not ok or type(dataList) ~= "table" then return items end

    for _, entry in ipairs(dataList) do
        local item = itemFromEntry(entry)
        if item then items[#items + 1] = item end
    end

    table.sort(items, function(a, b)
        if a.group ~= b.group then return string.lower(a.group) < string.lower(b.group) end
        if a.quality ~= b.quality then return a.quality > b.quality end
        return string.lower(a.name) < string.lower(b.name)
    end)
    return items
end

local function itemSignature(items)
    local parts = {}
    for i, item in ipairs(items) do
        parts[i] = tostring(item.bag) .. ":" .. tostring(item.slot) .. ":" .. tostring(item.stack)
            .. ":" .. tostring(item.quality) .. ":" .. tostring(item.group)
    end
    return table.concat(parts, "|")
end

local function qualityColor(q)
    local colorType = rawget(_G, "INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS")
    if type(rawget(_G, "GetInterfaceColor")) == "function" and colorType ~= nil then
        local ok, r, g, b = pcall(GetInterfaceColor, colorType, tonumber(q) or 0)
        if ok and r ~= nil then return r, g, b end
    end
    return .35, .42, .50
end

local function ensureRoot(list)
    if not list then return false end
    local parent = type(list.GetParent) == "function" and list:GetParent() or GuiRoot
    if not parent then parent = GuiRoot end

    if not root then
        root = wm:CreateControl(NAME, parent, CT_CONTROL)
        root:SetMouseEnabled(true)
        if rawget(_G, "DT_HIGH") then root:SetDrawTier(DT_HIGH) end
        if rawget(_G, "DL_OVERLAY") then root:SetDrawLayer(DL_OVERLAY) end
        root:SetDrawLevel(900)
        root._easRenderHouseStorage029606 = function(listArg, modeArg, allowEmptyArg, itemsArg)
            if type(render) == "function" then
                return render(listArg, modeArg, allowEmptyArg, itemsArg)
            end
        end
        root:SetHandler("OnMouseWheel", function(_, delta)
            if not houseStorageActive() or not currentMode then return end
            local rootH = tonumber(first(root.GetHeight, 0, root)) or 0
            local maxScroll = math.max(0, contentHeight - rootH + 4)
            local nextValue = (tonumber(scroll[currentMode]) or 0) - (tonumber(delta) or 0) * 110
            scroll[currentMode] = math.max(0, math.min(nextValue, maxScroll))
            if cachedItems[currentMode] and activeNativeList then
                cachedSignature[currentMode] = nil
                render(activeNativeList, currentMode, true, cachedItems[currentMode])
            end
        end)
    end

    if root._easStorageAnchorList029607 ~= list then
        if type(root.GetParent) == "function" and root:GetParent() ~= parent and type(root.SetParent) == "function" then
            pcall(root.SetParent, root, parent)
        end
        root:ClearAnchors()
        root:SetAnchor(TOPLEFT, list, TOPLEFT, 0, 0)
        root:SetAnchor(BOTTOMRIGHT, list, BOTTOMRIGHT, 0, 0)
        root._easStorageAnchorList029607 = list
    end
    return true
end

local function clearPool()
    for _, h in ipairs(headers) do
        h.group = nil
        if h.label then h.label:SetText("") end
        h:SetMouseEnabled(false)
        h:SetHidden(true)
    end
    for _, c in ipairs(cells) do
        c.item = nil
        if c.count then c.count:SetText("") end
        if c.icon then c.icon:SetTexture(nil) end
        c:SetMouseEnabled(false)
        c:SetHidden(true)
    end
end

local function getHeader(i)
    local h = headers[i]
    if h then return h end
    if i > MAX_HEADERS then return nil end

    h = wm:CreateControl(NAME .. "Header" .. i, root, CT_BUTTON)
    h:SetHeight(HEADER_H)
    h:SetMouseEnabled(true)
    h:SetDrawLevel(920)

    local hb = wm:CreateControl(nil, h, CT_BACKDROP)
    hb:SetAnchorFill(h)
    hb:SetCenterColor(.035, .055, .08, 1)
    hb:SetEdgeColor(.35, .45, .55, 1)
    hb:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 1)

    local label = wm:CreateControl(nil, h, CT_LABEL)
    label:SetAnchor(TOPLEFT, h, TOPLEFT, 8, 3)
    label:SetAnchor(BOTTOMRIGHT, h, BOTTOMRIGHT, -4, -3)
    label:SetFont("ZoFontGameBold")
    label:SetColor(1, .82, .26, 1)
    h.label = label

    h:SetHandler("OnClicked", function(control)
        if not currentMode or not control.group then return end
        collapsed[currentMode][control.group] = not (collapsed[currentMode][control.group] == true)
        cachedSignature[currentMode] = nil
        if activeNativeList and cachedItems[currentMode] then
            render(activeNativeList, currentMode, true, cachedItems[currentMode])
        end
    end)

    headers[i] = h
    return h
end

local function currentHouseBag()
    local house = inventoryData(rawget(_G, "INVENTORY_HOUSE_BANK"))
    if house and type(house.backingBags) == "table" then return house.backingBags[1] end
    return nil
end

local function moveItem(item)
    if not item or not houseStorageActive() then return end
    if currentMode == "DEPOSIT" and item.locked then return end

    local targetBag = currentMode == "WITHDRAW" and rawget(_G, "BAG_BACKPACK") or currentHouseBag()
    if targetBag == nil or type(rawget(_G, "FindFirstEmptySlotInBag")) ~= "function" then return end

    local targetSlot = first(FindFirstEmptySlotInBag, nil, targetBag)
    if targetSlot == nil then return end
    local count = tonumber(first(GetSlotStackSize, 1, item.bag, item.slot)) or item.stack or 1

    local protected = false
    if type(rawget(_G, "IsProtectedFunction")) == "function" then
        local ok, value = pcall(IsProtectedFunction, "RequestMoveItem")
        protected = ok and value == true
    end

    if protected and type(rawget(_G, "CallSecureProtected")) == "function" then
        pcall(CallSecureProtected, "RequestMoveItem", item.bag, item.slot, targetBag, targetSlot, count)
    elseif type(rawget(_G, "RequestMoveItem")) == "function" then
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
    c:SetDrawLevel(930)

    local cb = wm:CreateControl(nil, c, CT_BACKDROP)
    cb:SetAnchorFill(c)
    cb:SetCenterColor(.06, .07, .09, 1)
    cb:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 2)
    c.bg = cb

    local icon = wm:CreateControl(nil, c, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, c, TOPLEFT, 3, 3)
    icon:SetAnchor(BOTTOMRIGHT, c, BOTTOMRIGHT, -3, -3)
    icon:SetTextureCoords(.05, .95, .05, .95)
    c.icon = icon

    local count = wm:CreateControl(nil, c, CT_LABEL)
    count:SetAnchor(BOTTOMRIGHT, c, BOTTOMRIGHT, -2, -1)
    count:SetDimensions(28, 14)
    count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    count:SetFont("ZoFontGameSmall")
    count:SetColor(1, 1, 1, 1)
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
    c:SetHandler("OnClicked", function(control)
        if control.item then moveItem(control.item) end
    end)

    cells[i] = c
    return c
end

render = function(list, mode, allowEmpty, suppliedItems)
    if not list or not mode then return false end
    local items = suppliedItems or collectFromNative(list)

    if #items == 0 then
        emptyPasses[mode] = (tonumber(emptyPasses[mode]) or 0) + 1
        if allowEmpty ~= true then
            if cachedItems[mode] then
                items = cachedItems[mode]
            else
                -- Do not blank or swap the visible Suite grid during ESO's transient
                -- empty rebuild state. A later settled pass will decide if it is real.
                return false
            end
        elseif emptyPasses[mode] < 2 then
            return false
        elseif cachedItems[mode] and currentMode ~= mode then
            -- On a mode transition prefer the last known stable snapshot for that
            -- mode until ESO has completed at least another settled rebuild.
            items = cachedItems[mode]
        else
            clearPool()
            if root then root:SetHidden(true) end
            activeNativeList, currentMode = list, mode
            cachedItems[mode], cachedSignature[mode] = nil, nil
            return false
        end
    else
        emptyPasses[mode] = 0
        cachedItems[mode] = items
    end

    local sig = itemSignature(items)
    if not ensureRoot(list) then return false end

    if currentMode == mode and activeNativeList == list
        and cachedSignature[mode] == sig and not root:IsHidden() then
        suppressNativeVisuals()
        return true
    end

    activeNativeList, currentMode = list, mode
    cachedSignature[mode] = sig
    clearPool()
    root:SetHidden(false)

    local groups, order = {}, {}
    for _, item in ipairs(items) do
        if not groups[item.group] then
            groups[item.group] = {}
            order[#order + 1] = item.group
        end
        groups[item.group][#groups[item.group] + 1] = item
    end
    table.sort(order, function(a, b) return string.lower(a) < string.lower(b) end)

    local width = tonumber(first(root.GetWidth, 500, root)) or 500
    local rootH = tonumber(first(root.GetHeight, 0, root)) or 0
    local cols = math.max(4, math.floor((width - 16) / (CELL + GAP)))
    local offset = tonumber(scroll[mode]) or 0
    local y, headerIndex, cellIndex = 0, 0, 0

    for _, group in ipairs(order) do
        headerIndex = headerIndex + 1
        local headerY = y - offset
        local h = getHeader(headerIndex)
        if h then
            h.group = group
            h.label:SetText((collapsed[mode][group] and "+  " or "-  ") .. group .. "  (" .. #groups[group] .. ")")
            h:ClearAnchors()
            h:SetAnchor(TOPLEFT, root, TOPLEFT, 4, headerY)
            h:SetWidth(width - 12)
            local visible = rootH <= 0 or (headerY + HEADER_H > 0 and headerY < rootH)
            h:SetHidden(not visible)
            h:SetMouseEnabled(visible)
        end
        y = y + HEADER_H + GAP

        if not collapsed[mode][group] then
            local rows = math.ceil(#groups[group] / cols)
            for i, item in ipairs(groups[group]) do
                cellIndex = cellIndex + 1
                if cellIndex > MAX_CELLS then break end
                local c = getCell(cellIndex)
                if not c then break end

                c.item = item
                local col = (i - 1) % cols
                local row = math.floor((i - 1) / cols)
                local cellY = y + row * (CELL + GAP) - offset
                c:ClearAnchors()
                c:SetAnchor(TOPLEFT, root, TOPLEFT, 4 + col * (CELL + GAP), cellY)
                c.icon:SetTexture(item.icon ~= "" and item.icon or "EsoUI/Art/Icons/icon_missing.dds")
                c.count:SetText(item.stack > 1 and tostring(item.stack) or "")
                local r, g, b = qualityColor(item.quality)
                c.bg:SetEdgeColor(r, g, b, 1)
                local visible = rootH <= 0 or (cellY + CELL > 0 and cellY < rootH)
                c:SetHidden(not visible)
                c:SetMouseEnabled(visible)
            end
            y = y + rows * (CELL + GAP) + GAP
        end
    end

    contentHeight = y
    local maxScroll = math.max(0, contentHeight - rootH + 4)
    if offset > maxScroll then
        scroll[mode] = maxScroll
        cachedSignature[mode] = nil
        return render(list, mode, true, items)
    end

    suppressNativeVisuals()
    return true
end

local function refreshNow(allowEmpty)
    if not houseStorageActive() then return end

    if U then
        U._suiteBankActive029539 = false
        U.specialStorageNative029558 = rawget(_G, "INVENTORY_HOUSE_BANK")
        if U.root and type(U.root.SetHidden) == "function" then pcall(U.root.SetHidden, U.root, true) end
    end

    local mode, list = modeAndList()
    if not list then return end
    render(list, mode, allowEmpty)
    suppressNativeVisuals()
end

local function scheduleRefresh()
    if not houseStorageActive() then return end

    -- Same-call refresh captures ESO's rebuilt data and suppresses the native rows
    -- before they can visually own a full frame.
    refreshNow(false)

    refreshGeneration = refreshGeneration + 1
    local mineRefresh = refreshGeneration
    local mineSession = sessionGeneration
    if type(rawget(_G, "zo_callLater")) ~= "function" then return end

    for _, pass in ipairs({ { 35, false }, { 90, false }, { 180, true }, { 340, true } }) do
        local delay, allowEmpty = pass[1], pass[2]
        zo_callLater(function()
            if mineSession == sessionGeneration and mineRefresh == refreshGeneration and houseStorageActive() then
                refreshNow(allowEmpty)
            end
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

for _, fragmentName in ipairs({
    "HOUSE_BANK_FRAGMENT",
    "INVENTORY_FRAGMENT",
    "BACKPACK_HOUSE_BANK_LAYOUT_FRAGMENT",
}) do
    local fragment = rawget(_G, fragmentName)
    if fragment and type(fragment.RegisterCallback) == "function" then
        fragment:RegisterCallback("StateChange", function(_, newState)
            if newState == rawget(_G, "SCENE_FRAGMENT_SHOWING")
                or newState == rawget(_G, "SCENE_FRAGMENT_SHOWN") then
                if houseStorageActive() then scheduleRefresh() end
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
                sessionGeneration = sessionGeneration + 1
                refreshGeneration = refreshGeneration + 1
                scroll.WITHDRAW, scroll.DEPOSIT = 0, 0
                emptyPasses.WITHDRAW, emptyPasses.DEPOSIT = 0, 0
                scheduleRefresh()
            elseif newState == rawget(_G, "SCENE_HIDING") or newState == rawget(_G, "SCENE_HIDDEN") then
                sessionGeneration = sessionGeneration + 1
                refreshGeneration = refreshGeneration + 1
                restoreNativeVisuals()
                activeNativeList, currentMode = nil, nil
                cachedItems.WITHDRAW, cachedItems.DEPOSIT = nil, nil
                cachedSignature.WITHDRAW, cachedSignature.DEPOSIT = nil, nil
                emptyPasses.WITHDRAW, emptyPasses.DEPOSIT = 0, 0
                clearPool()
                if root then
                    root._easStorageAnchorList029607 = nil
                    root:SetHidden(true)
                end
            end
        end)
    end
end

if EVENT_MANAGER then
    local prefix = NAME .. "Events"
    for _, eventName in ipairs({ "EVENT_INVENTORY_FULL_UPDATE", "EVENT_INVENTORY_SINGLE_SLOT_UPDATE" }) do
        local code = rawget(_G, eventName)
        if code then
            EVENT_MANAGER:RegisterForEvent(prefix .. eventName, code, function()
                if houseStorageActive() then scheduleRefresh() end
            end)
        end
    end
end

scheduleRefresh()
