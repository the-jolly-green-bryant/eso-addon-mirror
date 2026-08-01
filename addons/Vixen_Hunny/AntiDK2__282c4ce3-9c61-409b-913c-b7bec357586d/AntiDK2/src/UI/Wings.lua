local ADK = AntiDK2
local M   = {}
ADK.UI.Wings = M

-- Layout within main panel (no backdrop, pure text):
--   Y=20  : "WING BUFFET" section header
--   Y=38  : enemy rows 1-5 (24px each)
--   Y=158 : "WHIP STACKS" sub-header
-- MoltenStacks at Y=176, PowerLashStacks at Y=200

local MAX_ROWS       = 5
local Y_HDR          = 20
local Y_ROW1         = 38
local ROW_H          = 24
local WING_DURATION  = 4000   -- ms; Wing Buffet stun/stagger duration

local rows = {}   -- { nameLbl, cntLbl, statusBar, tickHandle }

-- Start (or restart) the 4-second draining bar for a given row
local function StartTick(idx, startTime)
    local row = rows[idx]
    if row.tickHandle then
        zo_removeCallLater(row.tickHandle)
        row.tickHandle = nil
    end
    local function Tick()
        local elapsed  = GetFrameTimeMilliseconds() - startTime
        local fraction = math.max(0, 1 - elapsed / WING_DURATION)
        row.statusBar:SetValue(fraction * 100)
        if fraction > 0 then
            row.tickHandle = zo_callLater(Tick, 80)
        else
            row.tickHandle = nil
        end
    end
    Tick()
end

function M.Init()
    local panel = ADK.UI.MainPanel
    local c     = ADK.COLORS
    local bf    = ADK.UI.BoldFont

    -- Section header
    local hdr = ADK.UI.MakeLabel("AntiDK2WingsHdr", panel, bf(12),
        c.GREY[1], c.GREY[2], c.GREY[3])
    hdr:SetText("WINGS")
    hdr:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    hdr:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, Y_HDR)

    -- Enemy rows
    for i = 1, MAX_ROWS do
        local yOff = Y_ROW1 + (i - 1) * ROW_H
        local statusBar = ADK.UI.MakeStatusBar("AntiDK2WingStatus" .. i, panel, 200, ROW_H, c.PINK[1], c.PINK[2], c.PINK[3])
        statusBar:SetAnchor(TOPLEFT, panel, TOPLEFT, 4, yOff)
        rows[i] = { statusBar = statusBar }
        local nameLbl = ADK.UI.MakeLabel("AntiDK2WingName" .. i, panel, bf(17),
            c.WHITE[1], c.WHITE[2], c.WHITE[3])
        nameLbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        nameLbl:SetAnchor(TOPLEFT,  panel, TOPLEFT, 4, yOff)
        nameLbl:SetDimensions(200, ROW_H)
        nameLbl:SetText("")

        local cntLbl = ADK.UI.MakeLabel("AntiDK2WingCnt" .. i, panel, bf(19),
            c.PINK[1], c.PINK[2], c.PINK[3])
        cntLbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        cntLbl:SetAnchor(TOPRIGHT, panel, TOPRIGHT, 0, yOff)
        cntLbl:SetText("")

        rows[i].nameLbl = nameLbl
        rows[i].cntLbl  = cntLbl
        rows[i].tickHandle = nil
    end

    -- Whip stacks sub-header
    local whipHdr = ADK.UI.MakeLabel("AntiDK2WhipHdr", panel, bf(12),
        c.GREY[1], c.GREY[2], c.GREY[3])
    whipHdr:SetText("WHIP STACKS")
    whipHdr:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    whipHdr:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 158)
end

function M.Refresh(activeTargets)
    local list = {}
    for name, e in pairs(activeTargets) do
        list[#list + 1] = { name = name, count = e.count, lastHitTime = e.lastHitTime or 0 }
    end
    table.sort(list, function(a, b) return a.count > b.count end)

    for i = 1, MAX_ROWS do
        local row = rows[i]
        if list[i] then
            row.nameLbl:SetText(list[i].name)
            row.cntLbl:SetText(list[i].count .. "x")
            StartTick(i, list[i].lastHitTime)
        else
            row.nameLbl:SetText("")
            row.cntLbl:SetText("")
            if row.tickHandle then
                zo_removeCallLater(row.tickHandle)
                row.tickHandle = nil
            end
            row.statusBar:SetValue(0)
        end
    end
    -- Show or hide main panel based on whether any Wings target is active
    ADK.UI.SetPanelFlag("wings", next(activeTargets) ~= nil)
end
