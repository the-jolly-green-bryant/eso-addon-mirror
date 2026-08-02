NCollections = NCollections or {}

local GamepadOptions = NCollections.GamepadOptions
local PanelIds = GamepadOptions.PanelIds
local POSITION_HEADER_KEY = "ui.headers.position_and_appearance_346f660"
local ITEM_CATEGORY_TOOLTIP_KEY = "ui.navigation.item_category_toggle_tooltip"

function GamepadOptions.BuildItemCategoriesOptionsData()
    local options = {}
    local categories = NCollections.ItemLocator.BuildCategoryList({})
    for index = 1, #categories do
        local categoryKey = categories[index].key
        local categoryLabel = categories[index].label
        options[index] = GamepadOptions.BuildCheckboxOption(
            PanelIds.ITEM_CATEGORIES,
            index,
            categoryLabel,
            NCollections.L(ITEM_CATEGORY_TOOLTIP_KEY),
            function() return NCollections.ItemLocator.IsCategoryVisible(categoryKey) end,
            function(value) NCollections.ItemLocator.SetCategoryVisible(categoryKey, value) end,
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

local function BuildStandardBrowserOptions(panelId, feature)
    return {
        GamepadOptions.WithHeader(
            GamepadOptions.BuildPositionSliderOption(
                panelId, 1,
                feature.GetHorizontalPositionLabel(), feature.GetHorizontalPositionTooltip(),
                0, 100, "%.0f", feature.GetHorizontalPosition, feature.SetHorizontalPosition
            ),
            NCollections.L(POSITION_HEADER_KEY)
        ),
        GamepadOptions.BuildPositionSliderOption(
            panelId, 2,
            feature.GetVerticalPositionLabel(), feature.GetVerticalPositionTooltip(),
            0, 100, "%.0f", feature.GetVerticalPosition, feature.SetVerticalPosition
        ),
        GamepadOptions.BuildFiniteListOption(
            panelId, 3,
            feature.GetFontLabel(), feature.GetFontTooltip(),
            feature.GetFontChoices(), feature.GetFontChoiceNames(), feature.GetFont, feature.SetFont
        ),
        GamepadOptions.BuildValueStepSliderOption(
            panelId, 4,
            feature.GetScaleLabel(), feature.GetScaleTooltip(),
            feature.GetScaleMin(), feature.GetScaleMax(), "%.0f%%", feature.GetScale, feature.SetScale, 5
        ),
        GamepadOptions.BuildSliderOption(
            panelId, 5,
            feature.GetBackgroundOpacityLabel(), feature.GetBackgroundOpacityTooltip(),
            feature.GetBackgroundOpacityMin(), feature.GetBackgroundOpacityMax(), "%.0f",
            feature.GetBackgroundOpacity, feature.SetBackgroundOpacity, 1
        ),
    }
end

function GamepadOptions.BuildExtendedCollectionOptionsData(panelId, feature)
    return BuildStandardBrowserOptions(panelId, feature)
end

function GamepadOptions.BuildHousingOptionsData()
    return BuildStandardBrowserOptions(PanelIds.HOUSING, NCollections.Features.CollectionsHousing)
end

function GamepadOptions.BuildMountsOptionsData()
    return BuildStandardBrowserOptions(PanelIds.MOUNTS, NCollections.Features.CollectionsMounts)
end

function GamepadOptions.BuildSkinsOptionsData()
    return BuildStandardBrowserOptions(PanelIds.SKINS, NCollections.Features.CollectionsSkins)
end

function GamepadOptions.BuildPetsOptionsData()
    return BuildStandardBrowserOptions(PanelIds.PETS, NCollections.Features.CollectionsPets)
end

function GamepadOptions.BuildMementosOptionsData()
    return BuildStandardBrowserOptions(PanelIds.MEMENTOS, NCollections.Features.CollectionsMementos)
end

function GamepadOptions.BuildCompanionsOptionsData()
    return BuildStandardBrowserOptions(PanelIds.COMPANIONS, NCollections.Features.CollectionsCompanions)
end

local function BuildGearOptionsData(panelId, gear, includeSetCard, includeWatermark)
    local options = {}
    if includeSetCard then
        options[#options + 1] = GamepadOptions.BuildCheckboxOption(
            panelId, 1,
            gear.GetSetCardLabel(), gear.GetSetCardTooltip(), gear.GetSetCard, gear.SetSetCard
        )
    end
    if includeWatermark then
        options[#options + 1] = GamepadOptions.BuildCheckboxOption(
            panelId, 2,
            gear.GetShowWatermarkLabel(), gear.GetShowWatermarkTooltip(),
            gear.GetShowWatermark, gear.SetShowWatermark, nil, gear.GetShowWatermarkDefault
        )
    end
    options[#options + 1] = GamepadOptions.WithHeader(
            GamepadOptions.BuildPositionSliderOption(
                panelId, 3,
                gear.GetHorizontalPositionLabel(), gear.GetHorizontalPositionTooltip(),
                0, 100, "%.0f", gear.GetHorizontalPosition, gear.SetHorizontalPosition
            ),
            NCollections.L(POSITION_HEADER_KEY)
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

function GamepadOptions.BuildGearOptionsData()
    return BuildGearOptionsData(PanelIds.GEAR, NCollections.Features.CollectionsGear, true, true)
end

function GamepadOptions.BuildGearCraftedOptionsData()
    return BuildGearOptionsData(PanelIds.GEAR_CRAFTED, NCollections.Features.CollectionsGearCrafted, false, false)
end

function GamepadOptions.BuildRecipesOptionsData(panelId)
    local recipes = NCollections.Features.CollectionsRecipes
    return {
        GamepadOptions.BuildCheckboxOption(
            panelId, 1,
            recipes.GetRecipeCardLabel(), recipes.GetRecipeCardTooltip(), recipes.GetRecipeCard, recipes.SetRecipeCard
        ),
        GamepadOptions.WithHeader(
            GamepadOptions.BuildPositionSliderOption(
                panelId, 2,
                recipes.GetHorizontalPositionLabel(), recipes.GetHorizontalPositionTooltip(),
                0, 100, "%.0f", recipes.GetHorizontalPosition, recipes.SetHorizontalPosition
            ),
            NCollections.L(POSITION_HEADER_KEY)
        ),
        GamepadOptions.BuildPositionSliderOption(
            panelId, 3,
            recipes.GetVerticalPositionLabel(), recipes.GetVerticalPositionTooltip(),
            0, 100, "%.0f", recipes.GetVerticalPosition, recipes.SetVerticalPosition
        ),
        GamepadOptions.BuildFiniteListOption(
            panelId, 4,
            recipes.GetFontLabel(), recipes.GetFontTooltip(),
            recipes.GetFontChoices(), recipes.GetFontChoiceNames(), recipes.GetFont, recipes.SetFont
        ),
        GamepadOptions.BuildValueStepSliderOption(
            panelId, 5,
            recipes.GetScaleLabel(), recipes.GetScaleTooltip(),
            recipes.GetScaleMin(), recipes.GetScaleMax(), "%.0f%%", recipes.GetScale, recipes.SetScale, 5
        ),
        GamepadOptions.BuildSliderOption(
            panelId, 6,
            recipes.GetBackgroundOpacityLabel(), recipes.GetBackgroundOpacityTooltip(),
            recipes.GetBackgroundOpacityMin(), recipes.GetBackgroundOpacityMax(), "%.0f",
            recipes.GetBackgroundOpacity, recipes.SetBackgroundOpacity, 1
        ),
    }
end
