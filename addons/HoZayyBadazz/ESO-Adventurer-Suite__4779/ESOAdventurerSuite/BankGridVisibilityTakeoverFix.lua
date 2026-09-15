-- ESO Adventurer Suite
-- v0.29.529 - Bank grid visibility takeover.
-- Ensure the Suite bank icon grid actually becomes the visible/interactable bank
-- surface even when ESO/PerfectPixel renders native rows on a higher draw tier.

local EPC = ESOProgressionCoach
if not EPC then return end
local M = EPC.BankGridHardOverride
if not M then return end

local UPDATE_NAME = (EPC.name or "ESOAdventurerSuite") .. "_BankGridVisibility029529"
local suppressed = setmetatable({}, { __mode = "k" })

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

local function isVisible(control)
    return control and type(control.IsHidden) == "function" and first(control.IsHidden, true, control) == false
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
        local control = data[key]
        if control and type(control.GetLeft) == "function" then return control end
    end
    return nil
end

local function candidates()
    local out, seen = {}, {}
    local function add(mode, control)
        if not control or seen[control] or type(control.GetLeft) ~= "function" then return end
        seen[control] = true
        out[#out + 1] = { mode = mode, control = control }
    end

    add("WITHDRAW", rawget(_G, "ZO_PlayerBankBackpack"))
    add("DEPOSIT", rawget(_G, "ZO_PlayerInventoryList"))
    add("WITHDRAW", inventoryList(rawget(_G, "INVENTORY_BANK")))
    add("WITHDRAW", inventoryList(rawget(_G, "INVENTORY_HOUSE_BANK")))
    add("WITHDRAW", inventoryList(rawget(_G, "INVENTORY_GUILD_BANK")))
    add("DEPOSIT", inventoryList(rawget(_G, "INVENTORY_BACKPACK")))
    return out
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

local function resolveVisibleList()
    if not bankOpen() then return nil end
    local preferred = selectedMode()
    local best

    for _, entry in ipairs(candidates()) do
        local c = entry.control
        if isVisible(c) then
            local l = tonumber(first(c.GetLeft, nil, c))
            local t = tonumber(first(c.GetTop, nil, c))
            local r = tonumber(first(c.GetRight, nil, c))
            local b = tonumber(first(c.GetBottom, nil, c))
            if l and t and r and b then
                local w, h = r - l, b - t
                if w > 250 and h > 150 then
                    local score = w * h
                    if preferred == entry.mode then score = score + 100000000 end
                    if not best or score > best.score then
                        best = { mode = entry.mode, control = c, l = l, t = t, w = w, h = h, score = score }
                    end
                end
            end
        end
    end
    return best
end

local function raiseSuiteFrame()
    local frame = M.frame
    if not frame then return end
    if type(frame.SetDrawTier) == "function" and rawget(_G, "DT_HIGH") ~= nil then
        pcall(frame.SetDrawTier, frame, DT_HIGH)
    end
    if type(frame.SetDrawLayer) == "function" and rawget(_G, "DL_OVERLAY") ~= nil then
        pcall(frame.SetDrawLayer, frame, DL_OVERLAY)
    end
    if type(frame.SetDrawLevel) == "function" then pcall(frame.SetDrawLevel, frame, 1000) end
    if type(frame.SetMouseEnabled) == "function" then pcall(frame.SetMouseEnabled, frame, true) end
end

local function suppress(control)
    if not control or suppressed[control] then return end
    local state = {}
    if type(control.GetAlpha) == "function" then state.alpha = first(control.GetAlpha, 1, control) end
    if type(control.IsMouseEnabled) == "function" then state.mouse = first(control.IsMouseEnabled, true, control) end
    suppressed[control] = state
    -- Use alpha instead of SetHidden so the control keeps its geometry for ESO,
    -- PerfectPixel, and the Suite's own pane sizing.
    if type(control.SetAlpha) == "function" then pcall(control.SetAlpha, control, 0) end
    if type(control.SetMouseEnabled) == "function" then pcall(control.SetMouseEnabled, control, false) end
end

local function restoreAll()
    for control, state in pairs(suppressed) do
        if control then
            if type(control.SetAlpha) == "function" then pcall(control.SetAlpha, control, tonumber(state.alpha) or 1) end
            if type(control.SetMouseEnabled) == "function" then pcall(control.SetMouseEnabled, control, state.mouse ~= false) end
        end
        suppressed[control] = nil
    end
end

local function forceTakeover()
    if not bankOpen() then
        restoreAll()
        return
    end

    local info = resolveVisibleList()
    if not info then return end

    -- Render first while native geometry is still intact, then suppress only the
    -- row surface that the Suite has successfully covered.
    if type(M.Render) == "function" then
        local ok = pcall(M.Render, M, info)
        if not ok then return end
    end

    raiseSuiteFrame()
    if M.frame and type(M.frame.SetHidden) == "function" then pcall(M.frame.SetHidden, M.frame, false) end
    suppress(info.control)
end

-- Wrap the normal tick so every bank refresh reasserts the Suite as the topmost
-- visible surface without adding another high-frequency independent loop.
local baseTick = M.Tick
function M:Tick(...)
    if type(baseTick) == "function" then pcall(baseTick, self, ...) end
    forceTakeover()
end

if EVENT_MANAGER then
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 200, function()
        if bankOpen() then forceTakeover() else restoreAll() end
    end)

    if rawget(_G, "EVENT_OPEN_BANK") then
        EVENT_MANAGER:RegisterForEvent(UPDATE_NAME .. "Open", EVENT_OPEN_BANK, function()
            M.bankOpen = true
            M.dirty = true
            if type(zo_callLater) == "function" then
                zo_callLater(forceTakeover, 50)
                zo_callLater(forceTakeover, 250)
            else
                forceTakeover()
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

if type(zo_callLater) == "function" then zo_callLater(forceTakeover, 300) end
