if not GildedUI then return end

local Addon = GildedUI

Addon.SPACE_COLOR_WARN = { 1, 0.85, 0.1 }
Addon.SPACE_COLOR_FULL = { 1, 0.2, 0.2 }

Addon:RegisterDefaults({
    showBag = true,
    bagPosX = 1700,
    bagPosY = 5,
    bagShowBackground = false,
    bagShowPadding = true,
    bagBackgroundOpacity = 0.5,
    bagFontSize = 16,
    bagIcon = 1,
    bagWarnThreshold = 80,
})

Addon.bagIconPickerChoices = {
    "/esoui/art/inventory/gamepad/gp_inventory_icon_all.dds",
    "/esoui/art/tooltips/icon_bag.dds",
    "/esoui/art/icons/icon_emptyslot.dds", -- None (last entry)
}
Addon.BAG_ICON_NONE_INDEX = #Addon.bagIconPickerChoices

function Addon:GetBagIconPath()
    return self:GetIconPathForKey("bagIcon", self.bagIconPickerChoices, self.BAG_ICON_NONE_INDEX)
end

function Addon:BagIconPathToIndex(path)
    return self:IconPathToIndex(path, self.bagIconPickerChoices, self.defaults.bagIcon)
end

function Addon:SanitizeBag()
    local sv = self.state.sv
    local limits = self.limits

    self:ClampSavedNumber("bagPosX", limits.posX)
    self:ClampSavedNumber("bagPosY", limits.posY)
    self:ClampSavedNumber("bagBackgroundOpacity", limits.backgroundOpacity)
    self:ClampSavedNumber("bagWarnThreshold", limits.spaceWarnThreshold)
    self:RoundSavedOpacity("bagBackgroundOpacity")
    self:SanitizeSavedFontSize("bagFontSize")
    self:SanitizeSavedBoolean("showBag")
    self:SanitizeSavedBoolean("bagShowBackground")
    self:SanitizeSavedBoolean("bagShowPadding")
    if type(sv.bagIcon) == "string" then
        sv.bagIcon = self:BagIconPathToIndex(sv.bagIcon)
    end
    self:SanitizeIconIndex("bagIcon", #self.bagIconPickerChoices)
end

function Addon:ApplySpaceFillColor(label, used, maximum, thresholdPercent)
    local r, g, b = 1, 1, 1
    if maximum and maximum > 0 then
        if used >= maximum then
            r, g, b = unpack(self.SPACE_COLOR_FULL)
        elseif (used / maximum) * 100 >= (thresholdPercent or 80) then
            r, g, b = unpack(self.SPACE_COLOR_WARN)
        end
    end
    label:SetColor(r, g, b, 1)
end

function Addon:GetBagSpaceUsedAndMax()
    local used = GetNumBagUsedSlots(BAG_BACKPACK)
    local maximum = GetBagSize(BAG_BACKPACK)
    return used, maximum
end

function Addon:UpdateBagSpace()
    local window = self.state.bagWindow
    local label = self.state.bagLabel
    if not window or window:IsHidden() or not label then return end

    local used, maximum = self:GetBagSpaceUsedAndMax()
    local sv = self.state.sv
    self:ApplySpaceFillColor(label, used, maximum, sv and sv.bagWarnThreshold)
    label:SetText(string.format("%d / %d", used, maximum))
end

function Addon:ApplyBagPosition()
    local sv = self.state.sv
    if not sv then return end
    self:ApplyReadoutPosition(self.state.bagWindow, sv.bagPosX, sv.bagPosY)
end

function Addon:ApplyBagIcon()
    local sv = self.state.sv
    if not sv then return end

    self:ApplyReadoutLayout(
        self.state.bagBackdrop,
        self.state.bagContent,
        self.state.bagLabel,
        self.state.bagIcon,
        sv.bagShowBackground,
        sv.bagShowPadding,
        sv.bagBackgroundOpacity,
        self:GetBagIconPath(),
        sv.bagFontSize
    )
end

function Addon:SetBagEnabled(enabled)
    self.state.sv.showBag = enabled
    self:UpdateVisibility()
end

function Addon:CreateBagOverlay(wm)
    local sv = self.state.sv
    local font = self:GetReadoutFont(sv.bagFontSize)
    self.state.bagWindow, self.state.bagBackdrop, self.state.bagLabel, self.state.bagIcon, self.state.bagContent = self:CreateReadout(
        wm, self.name .. "_Bag", font, 1, 1, 1, "-- / --", sv.bagPosX, sv.bagPosY, true
    )
end
