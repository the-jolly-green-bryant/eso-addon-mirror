-- ESO Adventurer Suite
-- v0.29.595 - House Storage grid interaction bridge.
-- Keeps the Suite icon/category presentation while routing item interaction back
-- through ESO's native inventory slot action system so other addon menu entries
-- are preserved.

local EPC = ESOProgressionCoach
if not EPC or not EVENT_MANAGER then return end

local PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_HouseStorageGrid029594"
local MAX_CELLS = 320
local MAX_HEADERS = 64
local generation = 0

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

local function houseStorageActive()
    if fragmentShown(rawget(_G, "BACKPACK_HOUSE_BANK_LAYOUT_FRAGMENT")) then return true end
    local sm = rawget(_G, "SCENE_MANAGER")
    if sm and type(sm.IsShowing) == "function" then
        local ok, value = pcall(sm.IsShowing, sm, "houseBank")
        if ok and value == true then return true end
    end
    return fragmentShown(rawget(_G, "HOUSE_BANK_FRAGMENT"))
end

local function high(control, level)
    if not control then return end
    if type(control.SetDrawTier) == "function" and rawget(_G, "DT_HIGH") ~= nil then
        pcall(control.SetDrawTier, control, DT_HIGH)
    end
    if type(control.SetDrawLayer) == "function" and rawget(_G, "DL_OVERLAY") ~= nil then
        pcall(control.SetDrawLayer, control, DL_OVERLAY)
    end
    if type(control.SetDrawLevel) == "function" then pcall(control.SetDrawLevel, control, level or 950) end
    if type(control.SetMouseEnabled) == "function" then pcall(control.SetMouseEnabled, control, true) end
end

local function bindNativeSlot(control)
    if not control or type(control.item) ~= "table" then return false end
    local item = control.item
    local bag = tonumber(item.bag)
    local slot = tonumber(item.slot)
    if bag == nil or slot == nil then return false end

    local slotType = rawget(_G, "SLOT_TYPE_ITEM")
    if type(rawget(_G, "IsHouseBankBag")) == "function" then
        local ok, isHouse = pcall(IsHouseBankBag, bag)
        if ok and isHouse then slotType = rawget(_G, "SLOT_TYPE_BANK_ITEM") end
    end
    if slotType == nil then return false end

    if type(rawget(_G, "ZO_Inventory_BindSlot")) == "function" then
        pcall(ZO_Inventory_BindSlot, control, slotType, slot, bag)
    else
        control.slotType = slotType
        control.slotIndex = slot
        control.bagId = bag
    end
    return true
end

local function installCell(control)
    if not control then return end
    high(control, 970)
    if control.bg and type(control.bg.SetMouseEnabled) == "function" then pcall(control.bg.SetMouseEnabled, control.bg, false) end
    if control.icon and type(control.icon.SetMouseEnabled) == "function" then pcall(control.icon.SetMouseEnabled, control.icon, false) end
    if control.count and type(control.count.SetMouseEnabled) == "function" then pcall(control.count.SetMouseEnabled, control.count, false) end
    bindNativeSlot(control)

    if control._easHouseStorageNativeActions029595 then return end
    control._easHouseStorageNativeActions029595 = true

    control:SetHandler("OnMouseUp", function(c, button, upInside)
        if upInside == false or type(c.item) ~= "table" then return end
        bindNativeSlot(c)

        local left = rawget(_G, "MOUSE_BUTTON_INDEX_LEFT")
        local right = rawget(_G, "MOUSE_BUTTON_INDEX_RIGHT")
        if button == right then
            if type(rawget(_G, "ZO_InventorySlot_ShowContextMenu")) == "function" then
                pcall(ZO_InventorySlot_ShowContextMenu, c)
            end
            return
        end

        if button == left then
            if type(rawget(_G, "GetCursorContentType")) == "function"
                and rawget(_G, "MOUSE_CONTENT_EMPTY") ~= nil
                and GetCursorContentType() == MOUSE_CONTENT_EMPTY
                and type(rawget(_G, "ZO_InventorySlot_DoPrimaryAction")) == "function" then
                local ok, performed = pcall(ZO_InventorySlot_DoPrimaryAction, c)
                if ok and performed then return end
            end

            -- Let ESO's generic slot click path handle drag/drop or a cursor-held item.
            if type(rawget(_G, "ZO_InventorySlot_OnSlotClicked")) == "function" then
                pcall(ZO_InventorySlot_OnSlotClicked, c, button)
            end
        end
    end)
end

local function installHeader(control)
    if not control then return end
    high(control, 960)
    -- The base HouseStorage file owns the actual collapse callback. We only make
    -- sure the button remains the top mouse target instead of its backdrop/list.
    local n = type(control.GetNumChildren) == "function" and tonumber(control:GetNumChildren()) or 0
    for i = 1, n do
        local child = control:GetChild(i)
        if child and type(child.SetMouseEnabled) == "function" then pcall(child.SetMouseEnabled, child, false) end
    end
end

local function applyInteractions()
    if not houseStorageActive() then return end

    local root = rawget(_G, PREFIX)
    if root then high(root, 950) end

    for i = 1, MAX_HEADERS do
        local h = rawget(_G, PREFIX .. "Header" .. i)
        if h then installHeader(h) end
    end
    for i = 1, MAX_CELLS do
        local c = rawget(_G, PREFIX .. "Cell" .. i)
        if c then installCell(c) end
    end
end

local function scheduleApply()
    if not houseStorageActive() then return end
    generation = generation + 1
    local mine = generation
    if type(rawget(_G, "zo_callLater")) ~= "function" then applyInteractions(); return end
    for _, delay in ipairs({ 0, 35, 90, 180, 360 }) do
        zo_callLater(function()
            if mine == generation and houseStorageActive() then applyInteractions() end
        end, delay)
    end
end

local manager = rawget(_G, "PLAYER_INVENTORY")
if type(manager) == "table" and type(rawget(_G, "ZO_PostHook")) == "function" then
    for _, methodName in ipairs({ "UpdateList", "ChangeFilter", "ChangeSort" }) do
        if type(manager[methodName]) == "function" then
            pcall(ZO_PostHook, manager, methodName, function()
                if houseStorageActive() then scheduleApply() end
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
                if houseStorageActive() then scheduleApply() end
            end
        end)
    end
end

scheduleApply()
