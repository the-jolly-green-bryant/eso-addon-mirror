if not GildedUI then return end

local Addon = GildedUI

function Addon:CreateAnalyticsOverlay()
    local sv = self.state.sv
    local wm = WINDOW_MANAGER
    local fpsFont = self:GetReadoutFont(sv.fpsFontSize)
    local pingFont = self:GetReadoutFont(sv.pingFontSize)
    local memFont = self:GetReadoutFont(sv.memFontSize)
    local fpsR, fpsG, fpsB = 1, 1, 1
    local pingR, pingG, pingB = 1, 1, 1
    local memR, memG, memB = 1, 1, 1

    if sv.fpsUseColors then
        fpsR, fpsG, fpsB = unpack(sv.fpsColorGood)
    end
    if sv.pingUseColors then
        pingR, pingG, pingB = unpack(sv.pingColorGood)
    end
    if sv.memUseColors then
        memR, memG, memB = unpack(sv.memColorGood)
    end

    self.state.fpsWindow, self.state.fpsBackdrop, self.state.fpsLabel = self:CreateReadout(
        wm, self.name .. "_FPS", fpsFont, fpsR, fpsG, fpsB, "-- FPS", sv.fpsPosX, sv.fpsPosY
    )
    self.state.pingWindow, self.state.pingBackdrop, self.state.pingLabel = self:CreateReadout(
        wm, self.name .. "_Ping", pingFont, pingR, pingG, pingB, "--ms", sv.pingPosX, sv.pingPosY
    )
    self.state.memoryWindow, self.state.memoryBackdrop, self.state.memoryLabel = self:CreateReadout(
        wm, self.name .. "_Memory", memFont, memR, memG, memB, "-- MB", sv.memPosX, sv.memPosY
    )
end

function Addon:ApplyFPSPosition()
    local sv = self.state.sv
    if not sv then return end
    self:ApplyReadoutPosition(self.state.fpsWindow, sv.fpsPosX, sv.fpsPosY)
end

function Addon:ApplyPingPosition()
    local sv = self.state.sv
    if not sv then return end
    self:ApplyReadoutPosition(self.state.pingWindow, sv.pingPosX, sv.pingPosY)
end

function Addon:ApplyMemoryPosition()
    local sv = self.state.sv
    if not sv then return end
    self:ApplyReadoutPosition(self.state.memoryWindow, sv.memPosX, sv.memPosY)
end

function Addon:ApplyAnalyticsFont()
    local sv = self.state.sv
    if not sv then return end

    self:ApplyReadoutFont(self.state.fpsLabel, sv.fpsFontSize)
    self:ApplyReadoutFont(self.state.pingLabel, sv.pingFontSize)
    self:ApplyReadoutFont(self.state.memoryLabel, sv.memFontSize)
end

function Addon:ApplyAnalyticsBackground()
    local sv = self.state.sv
    if not sv then return end

    self:ApplyReadoutBackground(self.state.fpsBackdrop, self.state.fpsLabel, sv.fpsShowBackground, sv.fpsShowPadding, sv.fpsBackgroundOpacity)
    self:ApplyReadoutBackground(self.state.pingBackdrop, self.state.pingLabel, sv.pingShowBackground, sv.pingShowPadding, sv.pingBackgroundOpacity)
    self:ApplyReadoutBackground(self.state.memoryBackdrop, self.state.memoryLabel, sv.memShowBackground, sv.memShowPadding, sv.memBackgroundOpacity)
end

function Addon:SetFPSEnabled(enabled)
    self.state.sv.showFPS = enabled
    self:UpdateVisibility()
end

function Addon:SetPingEnabled(enabled)
    self.state.sv.showPing = enabled
    self:UpdateVisibility()
end

function Addon:SetMemoryEnabled(enabled)
    self.state.sv.showMemory = enabled
    self:UpdateVisibility()
end

function Addon:ApplyAnalyticsDefaults()
    self:ApplyFPSPosition()
    self:ApplyPingPosition()
    self:ApplyMemoryPosition()
    self:ApplyAnalyticsFont()
    self:ApplyAnalyticsBackground()
end
