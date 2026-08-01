if not GildedUI then return end

local Addon = GildedUI

Addon:RegisterDefaults({
    showInMenu = false,
    showFPS = true,
    fpsPosX = 5,
    fpsPosY = 1030,
    fpsShowBackground = false,
    fpsShowPadding = true,
    fpsBackgroundOpacity = 0.5,
    fpsFontSize = 16,
    fpsUseColors = true,
    fpsColorGood = { 0.2, 1, 0.4 },
    fpsColorMid = { 1, 0.85, 0.1 },
    fpsColorLow = { 1, 0.2, 0.2 },
})

function Addon:SanitizeFPS()
    local sv = self.state.sv
    local defaults = self.defaults
    local limits = self.limits

    -- Legacy single-pos migration into FPS/Ping.
    if type(sv.fpsPosX) ~= "number" and type(sv.posX) == "number" then
        sv.fpsPosX = sv.posX
        sv.fpsPosY = type(sv.posY) == "number" and sv.posY or defaults.fpsPosY
        local fontSize = type(sv.fpsFontSize) == "number" and sv.fpsFontSize
            or (type(sv.fontSize) == "number" and sv.fontSize or defaults.fpsFontSize)
        sv.pingPosX = sv.posX
        sv.pingPosY = (type(sv.posY) == "number" and sv.posY or defaults.fpsPosY) + fontSize + 7
    end
    if type(sv.fpsFontSize) ~= "number" and type(sv.fontSize) == "number" then
        sv.fpsFontSize = sv.fontSize
    end

    self:ClampSavedNumber("fpsPosX", limits.posX)
    self:ClampSavedNumber("fpsPosY", limits.posY)
    self:ClampSavedNumber("fpsBackgroundOpacity", limits.backgroundOpacity)
    self:RoundSavedOpacity("fpsBackgroundOpacity")
    self:SanitizeSavedFontSize("fpsFontSize")
    self:SanitizeSavedBoolean("showFPS")
    self:SanitizeSavedBoolean("showInMenu")
    self:SanitizeSavedBoolean("fpsUseColors")
    self:SanitizeSavedBoolean("fpsShowBackground")
    self:SanitizeSavedBoolean("fpsShowPadding")
    self:SanitizeSavedColor("fpsColorGood")
    self:SanitizeSavedColor("fpsColorMid")
    self:SanitizeSavedColor("fpsColorLow")
end

function Addon:UpdateFPS()
    local window = self.state.fpsWindow
    local label = self.state.fpsLabel
    if not window or window:IsHidden() or not label then return end

    local fps = zo_floor(GetFramerate() or 0)
    local sv = self.state.sv
    local r, g, b = 1, 1, 1
    if sv.fpsUseColors then
        if fps <= 29 then
            r, g, b = unpack(sv.fpsColorLow)
        elseif fps <= 44 then
            r, g, b = unpack(sv.fpsColorMid)
        else
            r, g, b = unpack(sv.fpsColorGood)
        end
    end

    label:SetColor(r, g, b, 1)
    label:SetText(string.format("%d FPS", fps))
end
