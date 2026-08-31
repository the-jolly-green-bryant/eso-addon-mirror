if not GildedUI then return end

local Addon = GildedUI

function Addon:SanitizeIndicators()
    self:SanitizeBag()
    self:SanitizeBank()
end

function Addon:BuildIndicatorsMenu(H)
    local sv = self.state.sv
    local limits = self.limits

    local bagControls = {
        H.Toggle(
            "Enable Bag Space",
            function() return sv.showBag end,
            function(v) Addon:SetBagEnabled(v) end,
            Addon.defaults.showBag
        ),
        H.FontSizeDropdown("bagFontSize"),
        H.IconPicker("bagIcon", Addon.bagIconPickerChoices, function() Addon:ApplyBagIcon() end),
        H.Slider(
            "Warn at % full",
            limits.spaceWarnThreshold.min,
            limits.spaceWarnThreshold.max,
            5,
            function() return sv.bagWarnThreshold end,
            function(v)
                sv.bagWarnThreshold = v
                Addon:UpdateBagSpace()
            end,
            Addon.defaults.bagWarnThreshold
        ),
    }
    H.Append(bagControls, H.BackgroundControls("bagShowBackground", "bagShowPadding", "bagBackgroundOpacity"))
    H.Append(bagControls, H.PositionSliders(
        "Bag X Position", "Bag Y Position", "bagPosX", "bagPosY",
        function() Addon:ApplyBagPosition() end
    ))

    local bankControls = {
        H.Toggle(
            "Enable Bank Space",
            function() return sv.showBank end,
            function(v) Addon:SetBankEnabled(v) end,
            Addon.defaults.showBank
        ),
        H.FontSizeDropdown("bankFontSize"),
        H.IconPicker("bankIcon", Addon.bankIconPickerChoices, function() Addon:ApplyBankIcon() end),
        H.Slider(
            "Warn at % full",
            limits.spaceWarnThreshold.min,
            limits.spaceWarnThreshold.max,
            5,
            function() return sv.bankWarnThreshold end,
            function(v)
                sv.bankWarnThreshold = v
                Addon:UpdateBankSpace()
            end,
            Addon.defaults.bankWarnThreshold
        ),
    }
    H.Append(bankControls, H.BackgroundControls("bankShowBackground", "bankShowPadding", "bankBackgroundOpacity"))
    H.Append(bankControls, H.PositionSliders(
        "Bank X Position", "Bank Y Position", "bankPosX", "bankPosY",
        function() Addon:ApplyBankPosition() end
    ))

    return {
        {
            type = "section",
            name = "Indicators",
            options = {
                {
                    type = "submenu",
                    name = "Bag Space",
                    options = bagControls,
                },
                {
                    type = "submenu",
                    name = "Bank Space",
                    options = bankControls,
                },
            },
        },
    }
end
