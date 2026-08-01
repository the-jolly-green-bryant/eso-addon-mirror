local ADK = AntiDK2
local M   = {}
ADK.UI.Stuns = M

local PANEL_W   = 480
local SLOT_H    = 52
local MAX_SLOTS = 4

local panel
local slots = {}

local function SavePos()
    local sv = ADK.savedVars
    sv.avoidPopupX = panel:GetLeft() + panel:GetWidth()  / 2 - GuiRoot:GetWidth()  / 2
    sv.avoidPopupY = panel:GetTop()  + panel:GetHeight() / 2 - GuiRoot:GetHeight() / 2
end

local function AnyVisible()
    for _, sl in ipairs(slots) do
        if sl.visible then return true end
    end
    return false
end

local function GetFont(presetKey)
    local sizes = { Small = 24, Medium = 32, Large = 40, XLarge = 52 }
    local preset = ADK.savedVars and ADK.savedVars[presetKey] or "Large"
    return ADK.UI.BoldFont(sizes[preset] or 40)
end

function M.Init()
    local sv = ADK.savedVars
    local c  = ADK.COLORS

    panel = WINDOW_MANAGER:CreateTopLevelWindow("AntiDK2StunPanel")
    panel:SetDimensions(PANEL_W, MAX_SLOTS * SLOT_H)
    panel:SetAnchor(CENTER, GuiRoot, CENTER, sv.avoidPopupX, sv.avoidPopupY)
    panel:SetMovable(true)
    panel:SetMouseEnabled(true)
    panel:SetClampedToScreen(true)
    panel:SetHidden(true)
    panel:SetScale(sv.avoidScale or 1.0)
    panel:SetHandler("OnMoveStop", function() SavePos() end)

    -- No backdrop - pure floating text labels, one per slot
    for i = 1, MAX_SLOTS do
        local lbl = WINDOW_MANAGER:CreateControl("AntiDK2StunLbl" .. i, panel, CT_LABEL)
        lbl:SetFont(GetFont("avoidFontPreset"))
        lbl:SetColor(c.DANGER[1], c.DANGER[2], c.DANGER[3], 1)
        lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        lbl:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, (i - 1) * SLOT_H)
        lbl:SetDimensions(PANEL_W, SLOT_H)
        lbl:SetHidden(true)
        lbl:SetText("")

        slots[i] = { lbl = lbl, visible = false, fadeHandle = nil, rollHandle = nil }
    end
end

function M.ShowAvoid(abilityName)
    local duration = ADK.savedVars.avoidFadeDelay

    local slot
    for i = 1, MAX_SLOTS do
        if not slots[i].visible then slot = slots[i]; break end
    end
    if not slot then
        slot = slots[1]
        if slot.fadeHandle then zo_removeCallLater(slot.fadeHandle); slot.fadeHandle = nil end
    end

    local c = ADK.COLORS
    -- Ability name in white, AVOID in red
    slot.lbl:SetText("|cFFFFFF" .. abilityName .. "|r  |cFF2020AVOID|r")
    slot.lbl:SetHidden(false)
    slot.visible = true
    panel:SetHidden(false)

    if slot.fadeHandle then zo_removeCallLater(slot.fadeHandle) end
    slot.fadeHandle = zo_callLater(function()
        slot.fadeHandle = nil
        slot.visible    = false
        slot.lbl:SetText("")
        slot.lbl:SetHidden(true)
        if not AnyVisible() then panel:SetHidden(true) end
    end, duration * 1000)
end

-- ShowAvoidWithRoll: phase 1 = AVOID, phase 2 = ROLL NOW at 0.7s
function M.ShowAvoidWithRoll(abilityName)
    local duration = ADK.savedVars.avoidFadeDelay

    local slot
    for i = 1, MAX_SLOTS do
        if not slots[i].visible then slot = slots[i]; break end
    end
    if not slot then
        slot = slots[1]
        if slot.fadeHandle then zo_removeCallLater(slot.fadeHandle); slot.fadeHandle = nil end
        if slot.rollHandle  then zo_removeCallLater(slot.rollHandle);  slot.rollHandle  = nil end
    end

    -- Phase 1: AVOID
    slot.lbl:SetText("|cFFFFFF" .. abilityName .. "|r  |cFF2020AVOID|r")
    slot.lbl:SetHidden(false)
    slot.visible = true
    panel:SetHidden(false)

    if slot.fadeHandle then zo_removeCallLater(slot.fadeHandle); slot.fadeHandle = nil end
    if slot.rollHandle  then zo_removeCallLater(slot.rollHandle);  slot.rollHandle  = nil end

    -- Phase 2: swap to ROLL NOW at 0.7s
    slot.rollHandle = zo_callLater(function()
        slot.rollHandle = nil
        if slot.visible then
            slot.lbl:SetText("|cFFFFFF" .. abilityName .. "|r  |cFFFF00ROLL NOW|r")
        end
    end, 700)

    -- Phase 3: hide
    slot.fadeHandle = zo_callLater(function()
        slot.fadeHandle = nil
        slot.visible    = false
        slot.lbl:SetText("")
        slot.lbl:SetHidden(true)
        if not AnyVisible() then panel:SetHidden(true) end
    end, duration * 1000)
end

function M.Reset()
    for _, sl in ipairs(slots) do
        if sl.fadeHandle then zo_removeCallLater(sl.fadeHandle); sl.fadeHandle = nil end
        if sl.rollHandle  then zo_removeCallLater(sl.rollHandle);  sl.rollHandle  = nil end
        sl.visible = false
        sl.lbl:SetText("")
        sl.lbl:SetHidden(true)
    end
    panel:SetHidden(true)
end

function M.GetPanel() return panel end
