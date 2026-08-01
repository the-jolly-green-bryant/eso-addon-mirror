local ADK = AntiDK2
local M   = {}
ADK.UI.Corrosive = M

local PANEL_W = 480
local PANEL_H = 130

local panel, titleLbl, statusLbl, timerLbl, stackLbl
local fadeHandle = nil

local function SavePos()
    local sv = ADK.savedVars
    sv.corrosivePopupX = panel:GetLeft() + panel:GetWidth()  / 2 - GuiRoot:GetWidth()  / 2
    sv.corrosivePopupY = panel:GetTop()  + panel:GetHeight() / 2 - GuiRoot:GetHeight() / 2
end

local function GetFont(presetKey)
    local sizes = { Small = 28, Medium = 38, Large = 48, XLarge = 60 }
    local preset = ADK.savedVars and ADK.savedVars[presetKey] or "Large"
    return ADK.UI.BoldFont(sizes[preset] or 48)
end

function M.Init()
    local sv = ADK.savedVars
    local c  = ADK.COLORS

    panel = WINDOW_MANAGER:CreateTopLevelWindow("AntiDK2CorrosivePanel")
    panel:SetDimensions(PANEL_W, PANEL_H)
    panel:SetAnchor(CENTER, GuiRoot, CENTER, sv.corrosivePopupX, sv.corrosivePopupY)
    panel:SetMovable(true)
    panel:SetMouseEnabled(true)
    panel:SetClampedToScreen(true)
    panel:SetHidden(true)
    panel:SetScale(sv.corrosiveScale or 1.0)
    panel:SetHandler("OnMoveStop", function() SavePos() end)

    -- No backdrop - pure text

    -- Title: "CORROSIVE ARMOR"
    titleLbl = ADK.UI.MakeLabel("AntiDK2CorrosiveTitle", panel,
        GetFont("corrosiveFontPreset"),
        c.CORROSIVE[1], c.CORROSIVE[2], c.CORROSIVE[3])
    titleLbl:SetText("CORROSIVE ARMOR")
    titleLbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    titleLbl:SetAnchor(TOP, panel, TOP, 0, 0)

    -- Status: "IN RANGE" / "CRITICAL HIT"
    statusLbl = ADK.UI.MakeLabel("AntiDK2CorrosiveStatus", panel,
        ADK.UI.BoldFont(26),
        c.WARN[1], c.WARN[2], c.WARN[3])
    statusLbl:SetText("IN RANGE")
    statusLbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    statusLbl:SetAnchor(TOP, titleLbl, BOTTOM, 0, 2)

    -- Bottom-left: elapsed timer
    timerLbl = ADK.UI.MakeLabel("AntiDK2CorrosiveTimer", panel,
        ADK.UI.BoldFont(22),
        c.WHITE[1], c.WHITE[2], c.WHITE[3])
    timerLbl:SetText("0:00")
    timerLbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    timerLbl:SetAnchor(BOTTOMLEFT, panel, BOTTOMLEFT, 0, 0)

    -- Bottom-right: x2 / x3 multiplier
    stackLbl = ADK.UI.MakeLabel("AntiDK2CorrosiveStack", panel,
        GetFont("corrosiveFontPreset"),
        c.PINK[1], c.PINK[2], c.PINK[3])
    stackLbl:SetText("")
    stackLbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    stackLbl:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, 0, 0)
end

function M.Show(hitCount, isCrit)
    if fadeHandle then zo_removeCallLater(fadeHandle); fadeHandle = nil end

    local c = ADK.COLORS
    stackLbl:SetText(hitCount >= 3 and "|cF5A9B8x3|r" or hitCount == 2 and "|cF5A9B8x2|r" or hitCount == 1 and "|cF5A9B8x1|r" or hitCount >= 4 and "|cF5A9B8x4|r")

    if isCrit then
        statusLbl:SetText("|cFF2020CRITICAL HIT|r")
        statusLbl:SetColor(c.DANGER[1], c.DANGER[2], c.DANGER[3], 1)
    else
        statusLbl:SetText("IN RANGE")
        statusLbl:SetColor(c.WARN[1], c.WARN[2], c.WARN[3], 1)
    end

    panel:SetHidden(false)

    fadeHandle = zo_callLater(function()
        fadeHandle = nil
        M.Hide()
    end, math.max(ADK.savedVars.corrosiveFadeDelay * 1000, 1000))
end

function M.UpdateTimer(formatted)
    if timerLbl then timerLbl:SetText(formatted) end
end

function M.Hide()
    panel:SetHidden(true)
    if timerLbl then timerLbl:SetText("0:00") end
    if stackLbl then stackLbl:SetText("") end
end

function M.GetPanel() return panel end
