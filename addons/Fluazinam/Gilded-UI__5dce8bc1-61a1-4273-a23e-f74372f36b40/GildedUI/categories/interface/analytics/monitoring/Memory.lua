if not GildedUI then return end

local Addon = GildedUI

Addon:RegisterDefaults({
    showMemory = true,
    memPosX = 5,
    memPosY = 1076,
    memShowBackground = false,
    memShowPadding = true,
    memBackgroundOpacity = 0.5,
    memFontSize = 16,
    memUseColors = true,
    memColorGood = { 0.2, 1, 0.4 },
    memColorMid = { 1, 0.85, 0.1 },
    memColorLow = { 1, 0.2, 0.2 },
})

function Addon:SanitizeMemory()
    local limits = self.limits

    self:ClampSavedNumber("memPosX", limits.posX)
    self:ClampSavedNumber("memPosY", limits.posY)
    self:ClampSavedNumber("memBackgroundOpacity", limits.backgroundOpacity)
    self:RoundSavedOpacity("memBackgroundOpacity")
    self:SanitizeSavedFontSize("memFontSize")
    self:SanitizeSavedBoolean("showMemory")
    self:SanitizeSavedBoolean("memUseColors")
    self:SanitizeSavedBoolean("memShowBackground")
    self:SanitizeSavedBoolean("memShowPadding")
    self:SanitizeSavedColor("memColorGood")
    self:SanitizeSavedColor("memColorMid")
    self:SanitizeSavedColor("memColorLow")
end

function Addon:UpdateMemory()
    local window = self.state.memoryWindow
    local label = self.state.memoryLabel
    if not window or window:IsHidden() or not label then return end

    local memory = 0
    if type(GetTotalUserAddOnMemoryPoolUsageMB) == "function" then
        memory = GetTotalUserAddOnMemoryPoolUsageMB() or 0
    end

    local sv = self.state.sv
    local r, g, b = 1, 1, 1
    if sv.memUseColors then
        if memory >= 70 then
            r, g, b = unpack(sv.memColorLow)
        elseif memory >= 50 then
            r, g, b = unpack(sv.memColorMid)
        else
            r, g, b = unpack(sv.memColorGood)
        end
    end

    label:SetColor(r, g, b, 1)
    label:SetText(string.format("%.1f MB", memory))
end
