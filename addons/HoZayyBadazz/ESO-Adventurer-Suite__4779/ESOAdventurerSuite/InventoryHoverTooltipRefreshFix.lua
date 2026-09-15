-- ESO Adventurer Suite
-- v0.29.656 - Refresh stale Suite inventory tooltips after item moves.
-- Event-driven only: no permanent polling loop.
-- ESO controls are userdata, so never use rawget() against a control object.

local EPC = ESOProgressionCoach
if not EPC or not EVENT_MANAGER then return end

local EM = EVENT_MANAGER
local NAME = (EPC.name or "ESOAdventurerSuite") .. "_InventoryHoverTooltipRefresh029656"
local UPDATE = NAME .. "_Deferred"

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

local function safeField(object, key)
    if object == nil then return nil end
    local ok, value = pcall(function() return object[key] end)
    if ok then return value end
    return nil
end

local function tooltipVisible()
    local tooltip = rawget(_G, "ItemTooltip")
    if not tooltip then return false end
    if type(tooltip.IsHidden) == "function" then
        return first(tooltip.IsHidden, true, tooltip) == false
    end
    return true
end

local function mouseControl()
    local wm = rawget(_G, "WINDOW_MANAGER")
    if wm and type(wm.GetMouseOverControl) == "function" then
        return first(wm.GetMouseOverControl, nil, wm)
    end
    if type(GetMouseOverControl) == "function" then
        return first(GetMouseOverControl, nil)
    end
    return nil
end

local function controlName(control)
    if not control or type(control.GetName) ~= "function" then return "" end
    return tostring(first(control.GetName, "", control) or "")
end

local function isSuiteControl(control)
    local depth = 0
    while control and depth < 6 do
        local name = controlName(control)
        if name:find("EAS", 1, true) == 1 or name:find("ESOAdventurerSuite", 1, true) == 1 then
            return true
        end
        if type(control.GetParent) ~= "function" then break end
        control = first(control.GetParent, nil, control)
        depth = depth + 1
    end
    return false
end

local function hasCurrentItem(control)
    if not control then return false end

    -- Bank grid cells store the bound item on control.item. Main Suite inventory
    -- cells store bagId/slotIndex directly. Read userdata fields through protected
    -- indexing instead of rawget(), which only accepts Lua tables.
    local item = safeField(control, "item") or safeField(control, "data") or safeField(control, "entry")
    if type(item) == "table" then
        local bag = item.bag or item.bagId
        local slot = item.slot or item.slotIndex
        if bag ~= nil and slot ~= nil then return true end
    end

    local bag = safeField(control, "bagId")
    local slot = safeField(control, "slotIndex")
    if bag ~= nil and slot ~= nil then return true end

    -- Quest-item cells do not have a backpack bag/slot but still own a valid tip.
    if safeField(control, "questItem") == true then return true end
    return false
end

local function clearTooltip()
    local tooltip = rawget(_G, "ItemTooltip")
    if tooltip and type(ClearTooltip) == "function" then
        pcall(ClearTooltip, tooltip)
    end
end

local function rerunHoverHandler(control)
    if not control or not isSuiteControl(control) then return false end

    local current = control
    local depth = 0
    while current and depth < 6 do
        if type(current.GetHandler) == "function" then
            local handler = first(current.GetHandler, nil, current, "OnMouseEnter")
            if type(handler) == "function" then
                if not hasCurrentItem(current) then
                    clearTooltip()
                    return true
                end
                clearTooltip()
                local ok = pcall(handler, current)
                return ok
            end
        end
        if type(current.GetParent) ~= "function" then break end
        current = first(current.GetParent, nil, current)
        depth = depth + 1
    end
    return false
end

local function refreshHoveredTooltip()
    if not tooltipVisible() then return end
    local control = mouseControl()
    if not control or not isSuiteControl(control) then return end
    rerunHoverHandler(control)
end

local function scheduleRefresh()
    -- Coalesce the burst of source/destination slot events from one transfer.
    EM:UnregisterForUpdate(UPDATE)
    EM:RegisterForUpdate(UPDATE, 80, function()
        EM:UnregisterForUpdate(UPDATE)
        refreshHoveredTooltip()
    end)
end

if rawget(_G, "EVENT_INVENTORY_SINGLE_SLOT_UPDATE") ~= nil then
    EM:RegisterForEvent(NAME .. "_Slot", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, scheduleRefresh)
end
if rawget(_G, "EVENT_INVENTORY_FULL_UPDATE") ~= nil then
    EM:RegisterForEvent(NAME .. "_Full", EVENT_INVENTORY_FULL_UPDATE, scheduleRefresh)
end
if rawget(_G, "EVENT_BANKED_CURRENCY_UPDATE") ~= nil then
    EM:RegisterForEvent(NAME .. "_Bank", EVENT_BANKED_CURRENCY_UPDATE, scheduleRefresh)
end

EPC.inventoryHoverTooltipRefresh029656 = true
