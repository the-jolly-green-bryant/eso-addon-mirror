-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.StableTimer = EPC.StableTimer or {}
local S = EPC.StableTimer
local wm = WINDOW_MANAGER

local function num(v, fallback) return tonumber(v) or tonumber(fallback) or 0 end
local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a,b,c,d,e,f = pcall(fn, ...)
    if not ok then return fallback end
    return a,b,c,d,e,f
end

local function formatMs(ms)
    ms = math.max(0, num(ms, 0))
    if ms <= 0 then return "0" end
    local seconds = math.ceil(ms / 1000)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then return string.format("%d:%02d:%02d", h, m, s) end
    return string.format("%02d:%02d", m, s)
end

function S:Create()
    local frame = wm:CreateTopLevelWindow("EPC_StableTrainingTimer")
    frame:SetDimensions(190, 34)
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(false)
    frame:SetMovable(false)

    local left = EPC.saved and num(EPC.saved.stableTimerLeft, -1) or -1
    local top = EPC.saved and num(EPC.saved.stableTimerTop, -1) or -1
    if left >= 0 and top >= 0 then frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else frame:SetAnchor(TOP, GuiRoot, TOP, 0, 18) end

    local bg = wm:CreateControl("EPC_StableTrainingTimer_BG", frame, CT_BACKDROP)
    bg:SetAnchorFill(frame)
    bg:SetCenterColor(0.020, 0.026, 0.036, 0.78)
    bg:SetEdgeColor(0.20, 0.23, 0.30, 0.92)
    bg:SetEdgeTexture(nil, 1, 1, 1)

    local title = wm:CreateControl("EPC_StableTrainingTimer_Title", frame, CT_LABEL)
    title:SetFont("ZoFontGameBold")
    title:SetColor(0.91, 0.70, 0.28, 1)
    title:SetAnchorFill(frame)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    frame:SetHandler("OnMoveStop", function(control)
        if EPC.saved then
            EPC.saved.stableTimerLeft = control:GetLeft()
            EPC.saved.stableTimerTop = control:GetTop()
        end
    end)

    self.frame, self.bg, self.title = frame, bg, title
end

function S:IsMaxed()
    if type(GetRidingStats) ~= "function" then return false end
    local inv, maxInv, stam, maxStam, speed, maxSpeed = safe(GetRidingStats, 0)
    return num(maxInv,0) > 0 and num(inv,0) >= num(maxInv,0)
        and num(stam,0) >= num(maxStam,0)
        and num(speed,0) >= num(maxSpeed,0)
end

function S:Refresh()
    if not self.frame or not EPC.saved then return end
    local show = EPC.saved.showStableTimer ~= false
    if self.layoutMode == true then show = true
    elseif EPC.OverlayModeAllows then show = show and EPC:OverlayModeAllows("stableTimerVisibility") end
    if show and self.layoutMode ~= true and EPC.IsGameplayHudSuppressed and EPC:IsGameplayHudSuppressed() then show = false end
    self.frame:SetHidden(not show)
    if not show then return end

    if type(GetTimeUntilCanBeTrained) ~= "function" then
        self.title:SetText("STABLE  --")
        return
    end

    if self:IsMaxed() then
        self.title:SetColor(0.25, 0.72, 0.40, 1)
        self.title:SetText("STABLE  MAX")
        return
    end

    local timeMs = num(safe(GetTimeUntilCanBeTrained, 0), 0)
    if timeMs <= 0 then
        self.title:SetColor(0.25, 0.72, 0.40, 1)
        self.title:SetText("STABLE  0")
    else
        self.title:SetColor(0.91, 0.70, 0.28, 1)
        self.title:SetText("STABLE  " .. formatMs(timeMs))
    end
end

function S:SetLayoutMode(active)
    self.layoutMode = active == true
    if not self.frame then return end
    self.frame:SetMouseEnabled(self.layoutMode)
    self.frame:SetMovable(self.layoutMode)
    self:Refresh()
end

function S:ResetPosition()
    if not self.frame or not EPC.saved then return end
    EPC.saved.stableTimerLeft = -1
    EPC.saved.stableTimerTop = -1
    self.frame:ClearAnchors()
    self.frame:SetAnchor(TOP, GuiRoot, TOP, 0, 18)
end

function S:Initialize()
    self.layoutMode = false
    self:Create()
    self:Refresh()
    EVENT_MANAGER:RegisterForUpdate(EPC.name .. "_StableTrainingTimer", 1000, function() self:Refresh() end)
end
