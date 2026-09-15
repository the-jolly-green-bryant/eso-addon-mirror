-- ESO Adventurer Suite
-- v0.29.532 - authoritative bank grid lifecycle + visual state.
-- Disable older competing bank-grid refresh loops and make this file the single
-- owner of restore -> render -> verify -> suppress ordering.

local EPC = ESOProgressionCoach
if not EPC or not EVENT_MANAGER then return end
local M = EPC.BankGridHardOverride
if not M then return end

local PREFIX = EPC.name or "ESOAdventurerSuite"
local UPDATE_NAME = PREFIX .. "_BankGridAuthoritative029532"

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

-- Stop every older independent bank-grid loop/event registration. They were
-- fighting each other: one could render while another immediately hid/suppressed.
local legacyUpdates = {
    PREFIX .. "_BankGridHardOverride029526",
    PREFIX .. "_BankGridVisibility029529",
    PREFIX .. "_BankGridRecovery029531",
}
for _, name in ipairs(legacyUpdates) do
    EVENT_MANAGER:UnregisterForUpdate(name)
end

local legacyEvents = {
    { PREFIX .. "_BankGridHardOverride029526Open", rawget(_G, "EVENT_OPEN_BANK") },
    { PREFIX .. "_BankGridHardOverride029526Close", rawget(_G, "EVENT_CLOSE_BANK") },
    { PREFIX .. "_BankGridHardOverride029526Slot", rawget(_G, "EVENT_INVENTORY_SINGLE_SLOT_UPDATE") },
    { PREFIX .. "_BankGridVisibility029529Open", rawget(_G, "EVENT_OPEN_BANK") },
    { PREFIX .. "_BankGridVisibility029529Close", rawget(_G, "EVENT_CLOSE_BANK") },
    { PREFIX .. "_BankGridRecovery029531Open", rawget(_G, "EVENT_OPEN_BANK") },
    { PREFIX .. "_BankGridRecovery029531Close", rawget(_G, "EVENT_CLOSE_BANK") },
}
for _, entry in ipairs(legacyEvents) do
    if entry[2] ~= nil then EVENT_MANAGER:UnregisterForEvent(entry[1], entry[2]) end
end

local function bankOpen()
    if M.bankOpen == true then return true end
    local inv = rawget(_G, "PLAYER_INVENTORY")
    if type(inv) == "table" then
        if type(inv.IsBanking) == "function" then
            local ok, v = pcall(inv.IsBanking, inv)
            if ok and v == true then return true end
        end
        if type(inv.IsGuildBanking) == "function" then
            local ok, v = pcall(inv.IsGuildBanking, inv)
            if ok and v == true then return true end
        end
    end
    return false
end

local function inventoryList(invType)
    local inv = rawget(_G, "PLAYER_INVENTORY")
    if type(inv) ~= "table" or type(inv.inventories) ~= "table" or invType == nil then return nil end
    local data = inv.inventories[invType]
    if type(data) ~= "table" then return nil end
    for _, key in ipairs({ "list", "listView", "scrollList" }) do
        local c = data[key]
        if c and type(c.GetLeft) == "function" then return c end
    end
    return nil
end

local function candidates()
    local out, seen = {}, {}
    local function add(mode, c)
        if not c or seen[c] or type(c.GetLeft) ~= "function" then return end
        seen[c] = true
        out[#out + 1] = { mode = mode, control = c }
    end
    add("WITHDRAW", rawget(_G, "ZO_PlayerBankBackpack"))
    add("DEPOSIT", rawget(_G, "ZO_PlayerInventoryList"))
    add("WITHDRAW", inventoryList(rawget(_G, "INVENTORY_BANK")))
    add("WITHDRAW", inventoryList(rawget(_G, "INVENTORY_HOUSE_BANK")))
    add("WITHDRAW", inventoryList(rawget(_G, "INVENTORY_GUILD_BANK")))
    add("DEPOSIT", inventoryList(rawget(_G, "INVENTORY_BACKPACK")))
    return out
end

local nativeState = setmetatable({}, { __mode = "k" })

local function restoreAll()
    for _, entry in ipairs(candidates()) do
        local c = entry.control
        if c then
            local state = nativeState[c]
            if type(c.SetAlpha) == "function" then pcall(c.SetAlpha, c, state and tonumber(state.alpha) or 1) end
            if type(c.SetMouseEnabled) == "function" then pcall(c.SetMouseEnabled, c, state == nil or state.mouse ~= false) end
        end
    end
end

local function selectedMode()
    local inv = rawget(_G, "PLAYER_INVENTORY")
    local selected = type(inv) == "table" and tonumber(inv.selectedTabType) or nil
    if selected == rawget(_G, "INVENTORY_BACKPACK") then return "DEPOSIT" end
    if selected == rawget(_G, "INVENTORY_BANK")
        or selected == rawget(_G, "INVENTORY_HOUSE_BANK")
        or selected == rawget(_G, "INVENTORY_GUILD_BANK") then
        return "WITHDRAW"
    end
    return nil
end

local function resolveInfo()
    if not bankOpen() then return nil end
    local preferred = selectedMode()
    local best
    for _, entry in ipairs(candidates()) do
        local c = entry.control
        if c and type(c.IsHidden) == "function" and first(c.IsHidden, true, c) == false then
            local l = tonumber(first(c.GetLeft, nil, c))
            local t = tonumber(first(c.GetTop, nil, c))
            local r = tonumber(first(c.GetRight, nil, c))
            local b = tonumber(first(c.GetBottom, nil, c))
            if l and t and r and b then
                local w, h = r - l, b - t
                if w > 250 and h > 150 then
                    local score = w * h + ((preferred == entry.mode) and 100000000 or 0)
                    if not best or score > best.score then
                        best = { mode = entry.mode, control = c, l = l, t = t, w = w, h = h, score = score }
                    end
                end
            end
        end
    end
    return best
end

local function forceVisual(control, level)
    if not control then return end
    if type(control.SetHidden) == "function" then pcall(control.SetHidden, control, false) end
    if type(control.SetAlpha) == "function" then pcall(control.SetAlpha, control, 1) end
    if type(control.SetDrawTier) == "function" and rawget(_G, "DT_HIGH") ~= nil then pcall(control.SetDrawTier, control, DT_HIGH) end
    if type(control.SetDrawLayer) == "function" and rawget(_G, "DL_OVERLAY") ~= nil then pcall(control.SetDrawLayer, control, DL_OVERLAY) end
    if type(control.SetDrawLevel) == "function" then pcall(control.SetDrawLevel, control, level or 3000) end
end

local function forceSuiteVisuals()
    forceVisual(M.frame, 3000)
    forceVisual(M.child, 3001)

    for _, h in ipairs(M.headers or {}) do
        if h and type(h.IsHidden) == "function" and first(h.IsHidden, true, h) == false then
            forceVisual(h, 3010)
            forceVisual(h.bg, 3011)
            forceVisual(h.label, 3012)
            if h.label and type(h.label.SetColor) == "function" then pcall(h.label.SetColor, h.label, 1, 0.82, 0.26, 1) end
        end
    end

    for _, c in ipairs(M.cells or {}) do
        if c and type(c.IsHidden) == "function" and first(c.IsHidden, true, c) == false then
            forceVisual(c, 3020)
            forceVisual(c.bg, 3021)
            forceVisual(c.icon, 3022)
            forceVisual(c.count, 3023)
            if c.icon and type(c.icon.SetColor) == "function" then pcall(c.icon.SetColor, c.icon, 1, 1, 1, 1) end
            if c.count and type(c.count.SetColor) == "function" then pcall(c.count.SetColor, c.count, 1, 1, 1, 1) end
        end
    end
end

local function intersects(a, b)
    if not a or not b then return false end
    local al, at = tonumber(first(a.GetLeft, nil, a)), tonumber(first(a.GetTop, nil, a))
    local ar, ab = tonumber(first(a.GetRight, nil, a)), tonumber(first(a.GetBottom, nil, a))
    local bl, bt = tonumber(first(b.GetLeft, nil, b)), tonumber(first(b.GetTop, nil, b))
    local br, bb = tonumber(first(b.GetRight, nil, b)), tonumber(first(b.GetBottom, nil, b))
    if not al or not at or not ar or not ab or not bl or not bt or not br or not bb then return false end
    return ar > bl and br > al and ab > bt and bb > at
end

local function hasVisibleSuiteControl(info)
    if not M.frame or first(M.frame.IsHidden, true, M.frame) == true then return false end
    if tonumber(first(M.frame.GetAlpha, 0, M.frame)) <= 0 then return false end
    for _, h in ipairs(M.headers or {}) do
        if h and first(h.IsHidden, true, h) == false and tonumber(first(h.GetAlpha, 0, h)) > 0 and intersects(h, info.control) then return true end
    end
    for _, c in ipairs(M.cells or {}) do
        if c and first(c.IsHidden, true, c) == false and tonumber(first(c.GetAlpha, 0, c)) > 0 and intersects(c, info.control) then return true end
    end
    return false
end

local function suppress(control)
    if not control then return end
    if not nativeState[control] then
        nativeState[control] = {
            alpha = type(control.GetAlpha) == "function" and first(control.GetAlpha, 1, control) or 1,
            mouse = type(control.IsMouseEnabled) == "function" and first(control.IsMouseEnabled, true, control) or true,
        }
    end
    if type(control.SetAlpha) == "function" then pcall(control.SetAlpha, control, 0) end
    if type(control.SetMouseEnabled) == "function" then pcall(control.SetMouseEnabled, control, false) end
end

local function refresh()
    restoreAll()

    if not bankOpen() then
        if M.frame and type(M.frame.SetHidden) == "function" then pcall(M.frame.SetHidden, M.frame, true) end
        return
    end

    local info = resolveInfo()
    if not info or type(M.Render) ~= "function" then return end

    local ok, rendered = pcall(M.Render, M, info)
    if not ok or rendered ~= true then
        restoreAll()
        return
    end

    forceSuiteVisuals()
    if not hasVisibleSuiteControl(info) then
        restoreAll()
        if M.frame and type(M.frame.SetHidden) == "function" then pcall(M.frame.SetHidden, M.frame, true) end
        return
    end

    suppress(info.control)
end

EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 120, refresh)

if rawget(_G, "EVENT_OPEN_BANK") then
    EVENT_MANAGER:RegisterForEvent(UPDATE_NAME .. "Open", EVENT_OPEN_BANK, function()
        M.bankOpen = true
        M.dirty = true
        restoreAll()
        if type(zo_callLater) == "function" then zo_callLater(refresh, 25); zo_callLater(refresh, 150) else refresh() end
    end)
end
if rawget(_G, "EVENT_CLOSE_BANK") then
    EVENT_MANAGER:RegisterForEvent(UPDATE_NAME .. "Close", EVENT_CLOSE_BANK, function()
        M.bankOpen = false
        restoreAll()
        if M.frame and type(M.frame.SetHidden) == "function" then pcall(M.frame.SetHidden, M.frame, true) end
    end)
end
if rawget(_G, "EVENT_INVENTORY_SINGLE_SLOT_UPDATE") then
    EVENT_MANAGER:RegisterForEvent(UPDATE_NAME .. "Slot", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
        if bankOpen() then M.dirty = true end
    end)
end

restoreAll()
if type(zo_callLater) == "function" then zo_callLater(refresh, 100) end
