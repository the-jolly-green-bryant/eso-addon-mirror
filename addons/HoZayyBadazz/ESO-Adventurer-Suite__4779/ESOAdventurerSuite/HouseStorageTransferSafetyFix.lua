-- ESO Adventurer Suite
-- v0.29.615 - House Storage secure transfer bridge.
-- Deposit visuals remain owned by HouseStoragePureNativeFix.lua.
-- Withdraw visuals/interactions remain owned by HouseStorageWithdrawViewportFix.lua.
-- This module only gives the existing Deposit grid a native ESO transfer-dialog handoff.

local EPC = ESOProgressionCoach
if not EPC or not EVENT_MANAGER then return end

local ADDON = EPC.name or "ESOAdventurerSuite"
local NAME = ADDON .. "_HouseStorageTransferSafety029615_"
local MAIN_PREFIX = ADDON .. "_HouseStorageGrid029594"
local MAX_CELLS = 320
local generation = 0

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

local function currentMode()
    if not houseStorageActive() then return nil end

    -- House Storage is fragment-driven. These are authoritative and must win over
    -- PLAYER_INVENTORY.selectedTabType, which can lag during tab transitions.
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

local function currentHouseBag()
    local getBankingBag = rawget(_G, "GetBankingBag")
    if type(getBankingBag) ~= "function" then return nil end

    local ok, bag = pcall(getBankingBag)
    if not ok then return nil end
    bag = tonumber(bag)
    if bag == nil then return nil end

    local isHouseBankBag = rawget(_G, "IsHouseBankBag")
    if type(isHouseBankBag) == "function" then
        local okHouse, yes = pcall(isHouseBankBag, bag)
        if okHouse and yes ~= true then return nil end
    end

    EPC.HouseStorageActiveBag029611 = bag
    return bag
end

local function openNativeTransfer(sourceBag, sourceSlot, targetBag)
    sourceBag = tonumber(sourceBag)
    sourceSlot = tonumber(sourceSlot)
    targetBag = tonumber(targetBag)
    if sourceBag == nil or sourceSlot == nil or targetBag == nil or sourceBag == targetBag then return false end

    local systems = rawget(_G, "SYSTEMS")
    if (type(systems) ~= "table" and type(systems) ~= "userdata") or type(systems.GetObject) ~= "function" then
        return false
    end

    local ok, dialog = pcall(systems.GetObject, systems, "ItemTransferDialog")
    if not ok or not dialog or type(dialog.StartTransfer) ~= "function" then return false end

    -- This only asks ESO's native ItemTransferDialog to own the transfer. The
    -- protected pickup/place operations execute later from ESO's trusted dialog.
    local started = pcall(dialog.StartTransfer, dialog, sourceBag, sourceSlot, targetBag)
    return started == true
end

local function safeMove(item, modeOverride)
    if not houseStorageActive() or type(item) ~= "table" then return false end

    local mode = modeOverride or currentMode()
    local sourceBag = tonumber(item.bag)
    local sourceSlot = tonumber(item.slot)
    if sourceBag == nil or sourceSlot == nil then return false end

    if mode == "WITHDRAW" then
        local backpack = tonumber(rawget(_G, "BAG_BACKPACK"))
        if backpack == nil then return false end
        return openNativeTransfer(sourceBag, sourceSlot, backpack)
    end

    if mode ~= "DEPOSIT" or item.locked == true then return false end

    local targetBag = currentHouseBag()
    if targetBag == nil or targetBag == sourceBag then return false end

    local doesBagHaveSpaceFor = rawget(_G, "DoesBagHaveSpaceFor")
    if type(doesBagHaveSpaceFor) == "function" then
        local ok, hasSpace = pcall(doesBagHaveSpaceFor, targetBag, sourceBag, sourceSlot)
        if ok and hasSpace == false then
            local alert = rawget(_G, "ZO_Alert")
            local category = rawget(_G, "UI_ALERT_CATEGORY_ERROR")
            local fullString = rawget(_G, "SI_INVENTORY_ERROR_INVENTORY_FULL")
            if type(alert) == "function" and category ~= nil and fullString ~= nil then
                pcall(alert, category, nil, fullString)
            end
            return false
        end
    end

    return openNativeTransfer(sourceBag, sourceSlot, targetBag)
end

-- Compatibility exports used by the Withdraw renderer. There is deliberately no
-- private inventory-transfer API referenced anywhere in this file.
EPC.HouseStorageSafeMove029610 = safeMove
EPC.HouseStorageSafeMove029611 = safeMove
EPC.HouseStorageSafeMove029615 = safeMove

local function highMouse(control, level)
    if not control then return end
    local highTier = rawget(_G, "DT_HIGH")
    local overlayLayer = rawget(_G, "DL_OVERLAY")
    if type(control.SetDrawTier) == "function" and highTier ~= nil then
        pcall(control.SetDrawTier, control, highTier)
    end
    if type(control.SetDrawLayer) == "function" and overlayLayer ~= nil then
        pcall(control.SetDrawLayer, control, overlayLayer)
    end
    if type(control.SetDrawLevel) == "function" then
        pcall(control.SetDrawLevel, control, level or 1250)
    end
    if type(control.IsHidden) == "function" and type(control.SetMouseEnabled) == "function" then
        local ok, hidden = pcall(control.IsHidden, control)
        if ok and hidden == false then pcall(control.SetMouseEnabled, control, true) end
    end
end

local function bindDepositSlot(control)
    if not control or type(control.item) ~= "table" then return false end
    local bag = tonumber(control.item.bag)
    local slot = tonumber(control.item.slot)
    local slotType = rawget(_G, "SLOT_TYPE_ITEM")
    if bag == nil or slot == nil or slotType == nil then return false end

    local bindSlot = rawget(_G, "ZO_Inventory_BindSlot")
    if type(bindSlot) == "function" then
        pcall(bindSlot, control, slotType, slot, bag)
    else
        control.slotType, control.slotIndex, control.bagId = slotType, slot, bag
    end
    return true
end

local function depositLabel()
    local stringId = rawget(_G, "SI_ITEM_ACTION_BANK_DEPOSIT")
    local getString = rawget(_G, "GetString")
    if stringId ~= nil and type(getString) == "function" then
        local ok, text = pcall(getString, stringId)
        if ok and tostring(text or "") ~= "" then return tostring(text) end
    end
    return "Deposit"
end

local function patchDepositMenu(control)
    local menu = rawget(_G, "ZO_Menu")
    if (type(menu) ~= "userdata" and type(menu) ~= "table") or type(menu.items) ~= "table" then return end

    local expected = depositLabel()
    for _, entry in ipairs(menu.items) do
        local menuControl = type(entry) == "table" and entry.item or nil
        local label = menuControl and menuControl.nameLabel
        local text = label and type(label.GetText) == "function" and tostring(label:GetText() or "") or ""
        if text == expected then
            local callback = function()
                if type(control.item) == "table" then safeMove(control.item, "DEPOSIT") end
            end
            if type(entry) == "table" then
                entry.callback = callback
                entry.OnSelect = callback
            end
            if menuControl then
                menuControl.callback = callback
                menuControl.OnSelect = callback
                if type(menuControl.SetHandler) == "function" then
                    pcall(menuControl.SetHandler, menuControl, "OnClicked", callback)
                end
            end
            break
        end
    end
end

local function installDepositCell(control)
    if not control then return end
    control._easHouseStorageTransferSafe029615 = true
    highMouse(control, 1250)

    if control.bg and type(control.bg.SetMouseEnabled) == "function" then
        pcall(control.bg.SetMouseEnabled, control.bg, false)
    end
    if control.icon and type(control.icon.SetMouseEnabled) == "function" then
        pcall(control.icon.SetMouseEnabled, control.icon, false)
    end
    if control.count and type(control.count.SetMouseEnabled) == "function" then
        pcall(control.count.SetMouseEnabled, control.count, false)
    end

    bindDepositSlot(control)
    if type(control.SetHandler) ~= "function" then return end

    pcall(control.SetHandler, control, "OnClicked", nil)
    control:SetHandler("OnMouseUp", function(c, button, upInside)
        if upInside == false or type(c.item) ~= "table" then return end
        local left = rawget(_G, "MOUSE_BUTTON_INDEX_LEFT")
        local right = rawget(_G, "MOUSE_BUTTON_INDEX_RIGHT")

        if button == left then
            safeMove(c.item, "DEPOSIT")
            return
        end

        if button == right then
            bindDepositSlot(c)
            local showMenu = rawget(_G, "ZO_InventorySlot_ShowContextMenu")
            if type(showMenu) == "function" then
                local ok = pcall(showMenu, c)
                if ok then patchDepositMenu(c) end
            end
        end
    end)
end

local function apply()
    -- Do not touch Withdraw controls here. HouseStorageWithdrawViewportFix.lua
    -- owns their visuals and input handlers completely.
    if currentMode() ~= "DEPOSIT" then return end

    currentHouseBag()
    highMouse(rawget(_G, MAIN_PREFIX), 1200)

    local foundAny, misses = false, 0
    for i = 1, MAX_CELLS do
        local control = rawget(_G, MAIN_PREFIX .. "Cell" .. i)
        if control then
            foundAny, misses = true, 0
            installDepositCell(control)
        elseif foundAny then
            misses = misses + 1
            if misses >= 24 then break end
        end
    end
end

local function scheduleApply()
    if currentMode() ~= "DEPOSIT" then return end
    generation = generation + 1
    local mine = generation
    apply()

    local callLater = rawget(_G, "zo_callLater")
    if type(callLater) ~= "function" then return end
    for _, delay in ipairs({ 0, 35, 90, 180, 360 }) do
        callLater(function()
            if mine == generation and currentMode() == "DEPOSIT" then apply() end
        end, delay)
    end
end

local manager = rawget(_G, "PLAYER_INVENTORY")
local postHook = rawget(_G, "ZO_PostHook")
if type(manager) == "table" and type(postHook) == "function" then
    for _, methodName in ipairs({ "UpdateList", "ChangeFilter", "ChangeSort" }) do
        if type(manager[methodName]) == "function" then
            pcall(postHook, manager, methodName, function()
                if currentMode() == "DEPOSIT" then scheduleApply() end
            end)
        end
    end
end

for _, fragmentName in ipairs({ "HOUSE_BANK_FRAGMENT", "INVENTORY_FRAGMENT", "BACKPACK_HOUSE_BANK_LAYOUT_FRAGMENT" }) do
    local fragment = rawget(_G, fragmentName)
    if fragment and type(fragment.RegisterCallback) == "function" then
        fragment:RegisterCallback("StateChange", function(_, newState)
            if newState == rawget(_G, "SCENE_FRAGMENT_SHOWING") or newState == rawget(_G, "SCENE_FRAGMENT_SHOWN") then
                if currentMode() == "DEPOSIT" then scheduleApply() end
            elseif fragmentName == "HOUSE_BANK_FRAGMENT"
                and (newState == rawget(_G, "SCENE_FRAGMENT_SHOWING") or newState == rawget(_G, "SCENE_FRAGMENT_SHOWN")) then
                generation = generation + 1
            end
        end)
    end
end

local sm = rawget(_G, "SCENE_MANAGER")
if sm and type(sm.GetScene) == "function" then
    local scene = sm:GetScene("houseBank")
    if scene and type(scene.RegisterCallback) == "function" then
        scene:RegisterCallback("StateChange", function(_, newState)
            if newState == rawget(_G, "SCENE_HIDING") or newState == rawget(_G, "SCENE_HIDDEN") then
                generation = generation + 1
            elseif newState == rawget(_G, "SCENE_SHOWING") or newState == rawget(_G, "SCENE_SHOWN") then
                currentHouseBag()
                if currentMode() == "DEPOSIT" then scheduleApply() end
            end
        end)
    end
end

local openBank = rawget(_G, "EVENT_OPEN_BANK")
if openBank ~= nil then
    EVENT_MANAGER:RegisterForEvent(NAME .. "OpenBank", openBank, function()
        currentHouseBag()
        if currentMode() == "DEPOSIT" then scheduleApply() end
    end)
end

for _, eventName in ipairs({ "EVENT_INVENTORY_FULL_UPDATE", "EVENT_INVENTORY_SINGLE_SLOT_UPDATE" }) do
    local eventCode = rawget(_G, eventName)
    if eventCode ~= nil then
        EVENT_MANAGER:RegisterForEvent(NAME .. eventName, eventCode, function()
            if currentMode() == "DEPOSIT" then scheduleApply() end
        end)
    end
end

if type(rawget(_G, "zo_callLater")) == "function" then
    zo_callLater(function()
        if currentMode() == "DEPOSIT" then scheduleApply() end
    end, 0)
end
