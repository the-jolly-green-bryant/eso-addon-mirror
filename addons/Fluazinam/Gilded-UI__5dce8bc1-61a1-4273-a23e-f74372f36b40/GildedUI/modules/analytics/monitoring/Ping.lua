if not GildedUI then return end

local Addon = GildedUI

Addon:RegisterDefaults({
    showPing = true,
    pingPosX = 5,
    pingPosY = 1053,
    pingShowBackground = false,
    pingShowPadding = true,
    pingBackgroundOpacity = 0.5,
    pingFontSize = 16,
    pingUseColors = true,
    pingColorGood = { 0.2, 1, 0.4 },
    pingColorMid = { 1, 0.85, 0.1 },
    pingColorLow = { 1, 0.2, 0.2 },
})

function Addon:SanitizePing()
    local sv = self.state.sv
    local limits = self.limits

    if type(sv.pingFontSize) ~= "number" and type(sv.fontSize) == "number" then
        sv.pingFontSize = sv.fontSize
    end

    self:ClampSavedNumber("pingPosX", limits.posX)
    self:ClampSavedNumber("pingPosY", limits.posY)
    self:ClampSavedNumber("pingBackgroundOpacity", limits.backgroundOpacity)
    self:RoundSavedOpacity("pingBackgroundOpacity")
    self:SanitizeSavedFontSize("pingFontSize")
    self:SanitizeSavedBoolean("showPing")
    self:SanitizeSavedBoolean("pingUseColors")
    self:SanitizeSavedBoolean("pingShowBackground")
    self:SanitizeSavedBoolean("pingShowPadding")
    self:SanitizeSavedColor("pingColorGood")
    self:SanitizeSavedColor("pingColorMid")
    self:SanitizeSavedColor("pingColorLow")
end

function Addon:UpdatePing()
    local window = self.state.pingWindow
    local label = self.state.pingLabel
    if not window or window:IsHidden() or not label then return end

    local ping = GetLatency() or 0
    local sv = self.state.sv
    local r, g, b = 1, 1, 1
    if sv.pingUseColors then
        if ping >= 250 then
            r, g, b = unpack(sv.pingColorLow)
        elseif ping >= 150 then
            r, g, b = unpack(sv.pingColorMid)
        else
            r, g, b = unpack(sv.pingColorGood)
        end
    end

    label:SetColor(r, g, b, 1)
    label:SetText(string.format("%dms", ping))
end
