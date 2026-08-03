NGear = NGear or {}

local GamepadOptions = NGear.GamepadOptions
local PanelIds = GamepadOptions.PanelIds
local ITEM_CATEGORY_TOOLTIP_KEY = "ui.navigation.item_category_toggle_tooltip"

function GamepadOptions.BuildItemCategoriesOptionsData()
    local options = {}
    local categories = NGear.ItemLocator.BuildCategoryList({})
    for index = 1, #categories do
        local categoryKey = categories[index].key
        local categoryLabel = categories[index].label
        options[index] = GamepadOptions.BuildCheckboxOption(
            PanelIds.ITEM_CATEGORIES,
            index,
            categoryLabel,
            NGear.L(ITEM_CATEGORY_TOOLTIP_KEY),
            function() return NGear.ItemLocator.IsCategoryVisible(categoryKey) end,
            function(value) NGear.ItemLocator.SetCategoryVisible(categoryKey, value) end,
            nil,
            true
        )
    end
    return options
end

function GamepadOptions.ShowItemCategoriesPanel()
    GamepadOptions.ReplacePanel(PanelIds.ITEM_CATEGORIES, GamepadOptions.BuildItemCategoriesOptionsData())
    GamepadOptions.ShowPanel(PanelIds.ITEM_CATEGORIES)
end

function GamepadOptions.BuildItemLocatorOptionsData()
    local panelId = PanelIds.ITEM_LOCATOR
    local locator = NGear.ItemLocator
    return {
        GamepadOptions.BuildPositionSliderOption(
            panelId, 1,
            locator.GetHorizontalPositionLabel(), locator.GetHorizontalPositionTooltip(),
            0, 100, "%.0f", locator.GetHorizontalPosition, locator.SetHorizontalPosition
        ),
        GamepadOptions.BuildPositionSliderOption(
            panelId, 2,
            locator.GetVerticalPositionLabel(), locator.GetVerticalPositionTooltip(),
            0, 100, "%.0f", locator.GetVerticalPosition, locator.SetVerticalPosition
        ),
        GamepadOptions.BuildFiniteListOption(
            panelId, 3,
            locator.GetFontLabel(), locator.GetFontTooltip(),
            locator.GetFontChoices(), locator.GetFontChoiceNames(), locator.GetFont, locator.SetFont
        ),
        GamepadOptions.BuildValueStepSliderOption(
            panelId, 4,
            locator.GetScaleLabel(), locator.GetScaleTooltip(),
            locator.GetScaleMin(), locator.GetScaleMax(), "%.0f%%", locator.GetScale, locator.SetScale, 5
        ),
        GamepadOptions.BuildSliderOption(
            panelId, 5,
            locator.GetBackgroundOpacityLabel(), locator.GetBackgroundOpacityTooltip(),
            locator.GetBackgroundOpacityMin(), locator.GetBackgroundOpacityMax(), "%.0f",
            locator.GetBackgroundOpacity, locator.SetBackgroundOpacity, 1
        ),
    }
end

function GamepadOptions.BuildGearOptionsData()
    local panelId = PanelIds.GEAR
    local gear = NGear.Features.CollectionsGear
    local options = {}
    options[#options + 1] = GamepadOptions.BuildCheckboxOption(
        panelId, 1,
        gear.GetSetCardLabel(), gear.GetSetCardTooltip(), gear.GetSetCard, gear.SetSetCard
    )
    options[#options + 1] = GamepadOptions.BuildCheckboxOption(
        panelId, 2,
        gear.GetShowWatermarkLabel(), gear.GetShowWatermarkTooltip(),
        gear.GetShowWatermark, gear.SetShowWatermark, nil, gear.GetShowWatermarkDefault
    )
    options[#options + 1] = GamepadOptions.BuildPositionSliderOption(
            panelId, 3,
            gear.GetHorizontalPositionLabel(), gear.GetHorizontalPositionTooltip(),
            0, 100, "%.0f", gear.GetHorizontalPosition, gear.SetHorizontalPosition
        )
    options[#options + 1] = GamepadOptions.BuildPositionSliderOption(
            panelId, 4,
            gear.GetVerticalPositionLabel(), gear.GetVerticalPositionTooltip(),
            0, 100, "%.0f", gear.GetVerticalPosition, gear.SetVerticalPosition
        )
    options[#options + 1] = GamepadOptions.BuildFiniteListOption(
            panelId, 5,
            gear.GetFontLabel(), gear.GetFontTooltip(),
            gear.GetFontChoices(), gear.GetFontChoiceNames(), gear.GetFont, gear.SetFont
        )
    options[#options + 1] = GamepadOptions.BuildValueStepSliderOption(
            panelId, 6,
            gear.GetScaleLabel(), gear.GetScaleTooltip(),
            gear.GetScaleMin(), gear.GetScaleMax(), "%.0f%%", gear.GetScale, gear.SetScale, 5
        )
    options[#options + 1] = GamepadOptions.BuildSliderOption(
            panelId, 7,
            gear.GetBackgroundOpacityLabel(), gear.GetBackgroundOpacityTooltip(),
            gear.GetBackgroundOpacityMin(), gear.GetBackgroundOpacityMax(), "%.0f",
            gear.GetBackgroundOpacity, gear.SetBackgroundOpacity, 1
        )
    return options
end
