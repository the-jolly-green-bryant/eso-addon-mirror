if not GildedUI then return end

local Addon = GildedUI

Addon:RegisterDefaults({
    showBank = true,
    bankPosX = 1700,
    bankPosY = 28,
    bankShowBackground = false,
    bankShowPadding = true,
    bankBackgroundOpacity = 0.5,
    bankFontSize = 16,
    bankIcon = 1,
    bankWarnThreshold = 80,
})

Addon.bankIconPickerChoices = {
    "/esoui/art/addons/gamepad/gp_mod_listing_category_bankandinventory.dds",
    "/esoui/art/tooltips/icon_bank.dds",
    "/esoui/art/tooltips/icon_house_bank.dds",
    "/esoui/art/icons/icon_emptyslot.dds", -- None (last entry)
}
Addon.BANK_ICON_NONE_INDEX = #Addon.bankIconPickerChoices

function Addon:GetBankIconPath()
    return self:GetIconPathForKey("bankIcon", self.bankIconPickerChoices, self.BANK_ICON_NONE_INDEX)
end

function Addon:BankIconPathToIndex(path)
    return self:IconPathToIndex(path, self.bankIconPickerChoices, self.defaults.bankIcon)
end

function Addon:SanitizeBank()
    local sv = self.state.sv
    local limits = self.limits

    self:ClampSavedNumber("bankPosX", limits.posX)
    self:ClampSavedNumber("bankPosY", limits.posY)
    self:ClampSavedNumber("bankBackgroundOpacity", limits.backgroundOpacity)
    self:ClampSavedNumber("bankWarnThreshold", limits.spaceWarnThreshold)
    self:RoundSavedOpacity("bankBackgroundOpacity")
    self:SanitizeSavedFontSize("bankFontSize")
    self:SanitizeSavedBoolean("showBank")
    self:SanitizeSavedBoolean("bankShowBackground")
    self:SanitizeSavedBoolean("bankShowPadding")
    if type(sv.bankIcon) == "string" then
        sv.bankIcon = self:BankIconPathToIndex(sv.bankIcon)
    end
    self:SanitizeIconIndex("bankIcon", #self.bankIconPickerChoices)
end

function Addon:GetBankSpaceUsedAndMax()
    local bankUsed = GetNumBagUsedSlots(BAG_BANK)
    local bankMax = GetBagSize(BAG_BANK)
    local subscriberUsed = GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK)
    local subscriberMax = GetBagUseableSize(BAG_SUBSCRIBER_BANK)

    return bankUsed + subscriberUsed, bankMax + subscriberMax
end

function Addon:UpdateBankSpace()
    local window = self.state.bankWindow
    local label = self.state.bankLabel
    if not window or window:IsHidden() or not label then return end

    local used, maximum = self:GetBankSpaceUsedAndMax()
    local sv = self.state.sv
    self:ApplySpaceFillColor(label, used, maximum, sv and sv.bankWarnThreshold)
    label:SetText(string.format("%d / %d", used, maximum))
end

function Addon:ApplyBankPosition()
    local sv = self.state.sv
    if not sv then return end
    self:ApplyReadoutPosition(self.state.bankWindow, sv.bankPosX, sv.bankPosY)
end

function Addon:ApplyBankIcon()
    local sv = self.state.sv
    if not sv then return end

    self:ApplyReadoutLayout(
        self.state.bankBackdrop,
        self.state.bankContent,
        self.state.bankLabel,
        self.state.bankIcon,
        sv.bankShowBackground,
        sv.bankShowPadding,
        sv.bankBackgroundOpacity,
        self:GetBankIconPath(),
        sv.bankFontSize
    )
end

function Addon:SetBankEnabled(enabled)
    self.state.sv.showBank = enabled
    self:UpdateVisibility()
end

function Addon:CreateBankOverlay(wm)
    local sv = self.state.sv
    local font = self:GetReadoutFont(sv.bankFontSize)
    self.state.bankWindow, self.state.bankBackdrop, self.state.bankLabel, self.state.bankIcon, self.state.bankContent = self:CreateReadout(
        wm, self.name .. "_Bank", font, 1, 1, 1, "-- / --", sv.bankPosX, sv.bankPosY, true
    )
end
