-- ESO Adventurer Suite
-- v0.29.531 - bank grid recovery + verified takeover.
-- Always restore native bank rows before attempting a Suite render. Suppress them
-- only after the Suite frame and at least one category/item have valid on-screen
-- geometry. This prevents a failed later refresh from leaving the bank blank.

local EPC = ESOProgressionCoach
if not EPC then return end
local M = EPC.BankGridHardOverride
if not M then return end

local UPDATE_NAME = (EPC.name or "ESOAdventurerSuite") .. "_BankGridRecovery029531"
local nativeState = setmetatable({}, { __mode = "k" })

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

local function bankOpen()
    if M.bankOpen == true then return true end
    local inv = rawget(_G, "PLAYER_INVENTORY")
    if type(inv) == "table" then
        if type(inv.IsBanking) == "function" then
            local ok, value = pcall(inv.IsBanking, inv)
            if ok and value == true then return true end
        end
        if type(inv.IsGuildBanking) == "function" then
            local ok, value = pcall(inv.IsGuildBanking, inv)
            if ok and value == true then return true end
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

local function candidateLists()
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

local function restore(control)
    if not control then return end
    local state = nativeState[control]
    if type(control.SetAlpha) == "function" then
        pcall(control.SetAlpha, control, state and tonumber(state.alpha) or 1)
    end
    if type(control.SetMouseEnabled) == "function" then
        pcall(control.SetMouseEnabled, control, state == nil or state.mouse ~= false)
    end
end

local function restoreAll()
    -- Restore both controls remembered by this fix and any candidate that an older
    -- takeover file may have left transparent before this file loaded.
    for control in pairs(nativeState) do restore(control) end
    for _, entry in ipairs(candidateLists()) do
        local c = entry.control
        if c then
            if type(c.SetAlpha) == "function" and tonumber(first(c.GetAlpha, 1, c)) == 0 then
                pcall(c.SetAlpha, c, 1)
            end
            if type(c.SetMouseEnabled) == "function" then pcall(c.SetMouseEnabled, c, true) end
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
    for _, entry in ipairs(candidateLists()) do
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

local function intersects(a, b)
    if not a or not b then return false end
    local al, at = tonumber(first(a.GetLeft, nil, a)), tonumber(first(a.GetTop, nil, a))
    local ar, ab = tonumber(first(a.GetRight, nil, a)), tonumber(first(a.GetBottom, nil, a))
    local bl, bt = tonumber(first(b.GetLeft, nil, b)), tonumber(first(b.GetTop, nil, b))
    local br, bb = tonumber(first(b.GetRight, nil, b)), tonumber(first(b.GetBottom, nil, b))
    if not al or not at or not ar or not ab or not bl or not bt or not br or not bb then return false end
    return ar > bl and br > al and ab > bt and bb > at
end

local function suiteRenderIsActuallyVisible(info)
    local frame = M.frame
    if not frame or type(frame.IsHidden) ~= "function" or first(frame.IsHidden, true, frame) == true then return false end
    if tonumber(first(frame.GetAlpha, 1, frame)) <= 0 then return false end

    local function visibleControl(c)
        return c
            and type(c.IsHidden) == "function"
            and first(c.IsHidden, true, c) == false
            and intersects(c, frame)
            and intersects(c, info.control)
    end

    for _, c in ipairs(M.headers or {}) do if visibleControl(c) then return true end end
    for _, c in ipairs(M.cells or {}) do if visibleControl(c) then return true end end
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

local function refreshVerified()
    -- Critical ordering: native first, Suite second, suppression last.
    restoreAll()

    if not bankOpen() then
        if M.frame and type(M.frame.SetHidden) == "function" then pcall(M.frame.SetHidden, M.frame, true) end
        return
    end

    local info = resolveInfo()
    if not info then
        if M.frame and type(M.frame.SetHidden) == "function" then pcall(M.frame.SetHidden, M.frame, true) end
        return
    end

    if type(M.Render) ~= "function" then return end
    local ok, rendered = pcall(M.Render, M, info)
    if not ok or rendered ~= true or not suiteRenderIsActuallyVisible(info) then
        restoreAll()
        if M.frame and type(M.frame.SetHidden) == "function" then pcall(M.frame.SetHidden, M.frame, true) end
        return
    end

    suppress(info.control)
end

-- Replace the prior visibility takeover's effective loop with a verified loop.
-- It is loaded last, so this continually restores any unsafe suppression before
-- deciding whether the Suite is truly visible.
if EVENT_MANAGER then
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 120, refreshVerified)

    if rawget(_G, "EVENT_OPEN_BANK") then
        EVENT_MANAGER:RegisterForEvent(UPDATE_NAME .. "Open", EVENT_OPEN_BANK, function()
            M.bankOpen = true
            M.dirty = true
            restoreAll()
            if type(zo_callLater) == "function" then
                zo_callLater(refreshVerified, 50)
                zo_callLater(refreshVerified, 250)
            else
                refreshVerified()
            end
        end)
    end

    if rawget(_G, "EVENT_CLOSE_BANK") then
        EVENT_MANAGER:RegisterForEvent(UPDATE_NAME .. "Close", EVENT_CLOSE_BANK, function()
            M.bankOpen = false
            restoreAll()
            if M.frame and type(M.frame.SetHidden) == "function" then pcall(M.frame.SetHidden, M.frame, true) end
        end)
    end
end

restoreAll()
if type(zo_callLater) == "function" then zo_callLater(refreshVerified, 100) end
