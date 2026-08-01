local CT = ControllerTweaks

local Tooltips = CT_Plugin:Subclass()

local showTTTCPriceOption = {
    settingKey = "ShowTTCPrice",
    type = "checkbox",
    name = "Show TTC Price",
    tooltip = "Shows TTC Price on item popup.",
    width = "full",
    default = true
}

local showExpandedTTCPriceInfo = {
    settingKey = "ShowExpandedTTCPrice",
    type = "checkbox",
    name = "Show Expanded TTC Price Info",
    tooltip = "Shows all TTC info like suggested %, min, max, and listings.",
    width = "full",
    default = false
}

Tooltips.options = { showTTTCPriceOption, showExpandedTTCPriceInfo }

local function AddExpandedPriceInfo(tooltip, itemLink, name, priceInfo)
    if not CT.Settings[showExpandedTTCPriceInfo.settingKey] then
        return
    end

    local bottomStyle =
    {
        customSpacing = 10,
        childSpacing = 10,
        widthPercent = 100,
        fontColorField = GENERAL_COLOR_OFF_WHITE,
        fontFace = "$(GAMEPAD_LIGHT_FONT)",
    }

    local bottomSection = tooltip:AcquireSection(bottomStyle)
    bottomSection:AddLine(string.format("Min:%s Avg:%s Max:%s", ZO_CurrencyControl_FormatCurrency(priceInfo.Min, true, nil), ZO_CurrencyControl_FormatCurrency(priceInfo.Avg, true, nil), ZO_CurrencyControl_FormatCurrency(priceInfo.Max, true, nil)))
    bottomSection:AddLine(string.format("%s listings", priceInfo.EntryCount))
    tooltip:AddSection(bottomSection)
end

local function AddPriceLine(tooltip, itemLink, name)
    if not CT.Settings[showTTTCPriceOption.settingKey] then
        return
    end

    local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
    if priceInfo then
        --Add suggested price before the item name
        local style = {
            layoutPrimaryDirection = "right",
            layoutSecondaryDirection = "down",
            widthPercent = 100,
            childSpacing = 10,
            fontSize = "$(GP_34)",
            height = 32,
            fontColorField = GENERAL_COLOR_WHITE,
        }

        local section = tooltip:AcquireSection(style)
        local suggested = priceInfo.SuggestedPrice or priceInfo.Min
        section:AddLine("TTC " .. ZO_CurrencyControl_FormatCurrency(suggested, true, nil))
        tooltip:AddSection(section)

        AddExpandedPriceInfo(tooltip, itemLink, name, priceInfo)
    end
end

function Tooltips:Init()
    if not TamrielTradeCentrePrice then
        return
    end
    ZO_PostHook(GAMEPAD_TOOLTIPS:GetAndInitializeTooltipContainerTip(GAMEPAD_LEFT_TOOLTIP).tooltip, "AddTopSection", AddPriceLine)
end

CT.Tooltips = Tooltips