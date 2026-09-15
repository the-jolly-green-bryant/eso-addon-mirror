-- ESO Adventurer Suite
-- v0.29.621 - House Storage Deposit header interaction repair.
-- Deposit layout/rendering remains owned by HouseStoragePureNativeFix.lua.
-- This file only ensures category headers are the mouse target. The renderer's
-- existing CT_BUTTON OnClicked handler is allowed to fire exactly once.

local EPC = ESOProgressionCoach
if not EPC or not EVENT_MANAGER then return end

local ADDON = EPC.name or "ESOAdventurerSuite"
local PREFIX = ADDON .. "_HouseStorageGrid029594"
local MAX_HEADERS = 64
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

local function depositActive()
    if not fragmentShown(rawget(_G, "BACKPACK_HOUSE_BANK_LAYOUT_FRAGMENT")) then
        local sm = rawget(_G, "SCENE_MANAGER")
        if not (sm and type(sm.IsShowing) == "function" and sm:IsShowing("houseBank")) then return false end
    end
    return fragmentShown(rawget(_G, "INVENTORY_FRAGMENT"))
        and not fragmentShown(rawget(_G, "HOUSE_BANK_FRAGMENT"))
end

local function high(control, level)
    if not control then return end
    local tier = rawget(_G, "DT_HIGH")
    local layer = rawget(_G, "DL_OVERLAY")
    if tier ~= nil and type(control.SetDrawTier) == "function" then pcall(control.SetDrawTier, control, tier) end
    if layer ~= nil and type(control.SetDrawLayer) == "function" then pcall(control.SetDrawLayer, control, layer) end
    if type(control.SetDrawLevel) == "function" then pcall(control.SetDrawLevel, control, level or 1220) end
end

local function patchHeader(header)
    if not header then return false end

    high(header, 1220)
    if type(header.SetMouseEnabled) == "function" then pcall(header.SetMouseEnabled, header, true) end

    -- HouseStoragePureNativeFix.lua owns the real collapse state through the
    -- header's original OnClicked handler. Do not forward OnMouseUp into it:
    -- CT_BUTTON already dispatches OnClicked, and forwarding causes a double
    -- toggle (collapse immediately followed by expand).
    if type(header.SetHandler) == "function" then
        pcall(header.SetHandler, header, "OnMouseUp", nil)
    end

    if header.label and type(header.label.SetMouseEnabled) == "function" then
        pcall(header.label.SetMouseEnabled, header.label, false)
    end

    -- The renderer creates an unnamed backdrop plus the label as children.
    -- Neither child may intercept the click from the CT_BUTTON header.
    if type(header.GetNumChildren) == "function" and type(header.GetChild) == "function" then
        local ok, count = pcall(header.GetNumChildren, header)
        count = ok and tonumber(count) or 0
        for i = 1, count do
            local okChild, child = pcall(header.GetChild, header, i)
            if okChild and child and type(child.SetMouseEnabled) == "function" then
                pcall(child.SetMouseEnabled, child, false)
            end
        end
    end

    -- Only report success when the renderer's real collapse callback exists.
    if type(header.GetHandler) == "function" then
        local ok, original = pcall(header.GetHandler, header, "OnClicked")
        return ok and type(original) == "function"
    end
    return false
end

local function apply()
    if not depositActive() then return 0 end
    local root = rawget(_G, PREFIX)
    if root then
        high(root, 1200)
        if type(root.SetMouseEnabled) == "function" then pcall(root.SetMouseEnabled, root, true) end
    end

    local patched = 0
    for i = 1, MAX_HEADERS do
        local header = rawget(_G, PREFIX .. "Header" .. i)
        if header and patchHeader(header) then patched = patched + 1 end
    end
    return patched
end

local function schedule()
    if not depositActive() then return end
    generation = generation + 1
    local mine = generation

    -- The main House Storage renderer has settled passes through 340 ms. Keep a
    -- finite repair burst beyond that point so the final visible headers always
    -- have child mouse input disabled. No permanent OnUpdate loop is used.
    local delays = { 0, 40, 120, 260, 380, 520, 750, 1000 }
    if type(rawget(_G, "zo_callLater")) ~= "function" then apply(); return end
    for _, delay in ipairs(delays) do
        zo_callLater(function()
            if mine == generation and depositActive() then apply() end
        end, delay)
    end
end

for _, fragmentName in ipairs({ "INVENTORY_FRAGMENT", "BACKPACK_HOUSE_BANK_LAYOUT_FRAGMENT" }) do
    local fragment = rawget(_G, fragmentName)
    if fragment and type(fragment.RegisterCallback) == "function" then
        fragment:RegisterCallback("StateChange", function(_, newState)
            if newState == rawget(_G, "SCENE_FRAGMENT_SHOWING")
                or newState == rawget(_G, "SCENE_FRAGMENT_SHOWN") then
                schedule()
            end
        end)
    end
end

for _, eventName in ipairs({
    "EVENT_OPEN_BANK",
    "EVENT_INVENTORY_FULL_UPDATE",
    "EVENT_INVENTORY_SINGLE_SLOT_UPDATE",
}) do
    local code = rawget(_G, eventName)
    if code ~= nil then
        EVENT_MANAGER:RegisterForEvent(PREFIX .. "HeaderMouse" .. eventName, code, function()
            if depositActive() then schedule() end
        end)
    end
end

schedule()
