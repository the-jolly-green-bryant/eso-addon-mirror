NCollections = NCollections or {}

local GamepadOptions = NCollections.GamepadOptions
local PanelIds = GamepadOptions.PanelIds
local ROOT_PANEL_ID = PanelIds.ROOT

local function Resolve(value)
    if type(value) == "function" then return value() end
    return value
end

local function BuildEntry(panelId, settingId, label, tooltip, callback)
    return {
        panel = ROOT_PANEL_ID,
        system = ROOT_PANEL_ID,
        settingId = settingId,
        controlType = OPTIONS_INVOKE_CALLBACK,
        text = label,
        gamepadTextOverride = label,
        onInitializeFunction = function(control)
            GamepadOptions.InitializeNavigationEntry(control)
        end,
        gamepadCustomTooltipFunction = function(tooltipControl)
            GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, Resolve(tooltip))
        end,
        callback = callback or function() GamepadOptions.ShowPanel(panelId) end,
    }
end

function GamepadOptions.BuildItemLocatorEntry()
    return BuildEntry(
        nil,
        11,
        NCollections.L("ui.navigation.item_locator"),
        NCollections.ItemLocator.GetRosterTooltip,
        GamepadOptions.ShowItemLocator
    )
end

function GamepadOptions.BuildScanItemsOption()
    return GamepadOptions.BuildCheckboxOption(
        ROOT_PANEL_ID,
        12,
        NCollections.L("ui.navigation.scan_items"),
        NCollections.L("ui.navigation.scan_items_tooltip"),
        NCollections.ItemLocator.IsEnabled,
        NCollections.ItemLocator.SetEnabled,
        nil,
        false
    )
end

function GamepadOptions.BuildItemCategoriesEntry()
    return BuildEntry(
        PanelIds.ITEM_CATEGORIES,
        13,
        NCollections.L("ui.navigation.item_categories"),
        NCollections.L("ui.navigation.item_categories_tooltip"),
        GamepadOptions.ShowItemCategoriesPanel
    )
end

function GamepadOptions.BuildGearEntry()
    return BuildEntry(
        PanelIds.GEAR,
        1,
        NCollections.L("ui.navigation.gear_def2b5f"),
        NCollections.L("ui.navigation.browse_every_reconstructable_gear_set_and_its_collec_86e2576")
    )
end

function GamepadOptions.BuildGearCraftedEntry()
    return BuildEntry(
        PanelIds.GEAR_CRAFTED,
        23,
        NCollections.L("ui.navigation.gear_crafted"),
        NCollections.L("ui.navigation.gear_crafted_tooltip")
    )
end

function GamepadOptions.BuildFoodRecipesEntry()
    return BuildEntry(
        PanelIds.FOOD_RECIPES,
        2,
        NCollections.L("features.collections_recipes.food_recipes_ccd936f"),
        NCollections.L("ui.navigation.food_recipes_tooltip")
    )
end

function GamepadOptions.BuildDrinkRecipesEntry()
    return BuildEntry(
        PanelIds.DRINK_RECIPES,
        3,
        NCollections.L("features.collections_recipes.drink_recipes_3128a30"),
        NCollections.L("ui.navigation.drink_recipes_tooltip")
    )
end

function GamepadOptions.BuildPlansEntry()
    return BuildEntry(
        PanelIds.PLANS,
        4,
        NCollections.L("features.collections_recipes.plans_cf2e5f2"),
        NCollections.L("ui.navigation.plans_tooltip")
    )
end

function GamepadOptions.BuildHousingEntry()
    return BuildEntry(
        PanelIds.HOUSING,
        5,
        NCollections.L("ui.navigation.housing_0ebae7e"),
        NCollections.L("ui.navigation.browse_every_available_house_acquisition_status_deta_80760fd")
    )
end

function GamepadOptions.BuildMountsEntry()
    return BuildEntry(
        PanelIds.MOUNTS,
        6,
        NCollections.L("ui.navigation.mounts_9516ba1"),
        NCollections.L("ui.navigation.browse_every_available_mount_acquisition_status_coll_ab4bab6")
    )
end

function GamepadOptions.BuildSkinsEntry()
    return BuildEntry(
        PanelIds.SKINS,
        7,
        NCollections.L("ui.navigation.skins_3e03229"),
        NCollections.L("ui.navigation.browse_every_available_skin_acquisition_status_colle_5ad4d50")
    )
end

function GamepadOptions.BuildPetsEntry()
    return BuildEntry(
        PanelIds.PETS,
        8,
        NCollections.L("ui.navigation.non_combat_pets"),
        NCollections.L("ui.navigation.non_combat_pets_tooltip")
    )
end

function GamepadOptions.BuildMementosEntry()
    return BuildEntry(
        PanelIds.MEMENTOS,
        9,
        NCollections.L("ui.navigation.mementos"),
        NCollections.L("ui.navigation.mementos_tooltip")
    )
end

function GamepadOptions.BuildCompanionsEntry()
    return BuildEntry(
        PanelIds.COMPANIONS,
        10,
        NCollections.L("ui.navigation.companions"),
        NCollections.L("ui.navigation.companions_tooltip")
    )
end

local function BuildExtendedCollectionEntry(panelId, settingId, pluralKey)
    local label = NCollections.L(pluralKey)
    return BuildEntry(
        panelId,
        settingId,
        label,
        NCollections.L("ui.navigation.dynamic_collection_tooltip", NCollections.Util.Lower(label))
    )
end

function GamepadOptions.BuildRootOptionsData()
    return {
        GamepadOptions.WithHeader(
            GamepadOptions.BuildScanItemsOption(),
            GetString(SI_INVENTORY_MODE_ITEMS)
        ),
        GamepadOptions.BuildItemLocatorEntry(),
        GamepadOptions.BuildItemCategoriesEntry(),
        GamepadOptions.WithHeader(
            BuildExtendedCollectionEntry(PanelIds.ANTIQUITIES, 18, "collections.antiquities"),
            GetString(SI_MAIN_MENU_COLLECTIONS)
        ),
        BuildExtendedCollectionEntry(PanelIds.APPEARANCE, 14, "collections.appearance"),
        BuildExtendedCollectionEntry(PanelIds.ASSISTANTS, 15, "collections.assistants"),
        BuildExtendedCollectionEntry(PanelIds.COLLECTIBLE_FURNISHINGS, 21, "collections.collectible_furnishings"),
        GamepadOptions.BuildCompanionsEntry(),
        GamepadOptions.BuildDrinkRecipesEntry(),
        BuildExtendedCollectionEntry(PanelIds.DYES, 19, "collections.dyes"),
        BuildExtendedCollectionEntry(PanelIds.EMOTES_AND_ACTIONS, 22, "collections.emotes_and_actions"),
        GamepadOptions.BuildFoodRecipesEntry(),
        GamepadOptions.BuildGearEntry(),
        GamepadOptions.BuildGearCraftedEntry(),
        GamepadOptions.BuildHousingEntry(),
        GamepadOptions.BuildMementosEntry(),
        GamepadOptions.BuildMountsEntry(),
        GamepadOptions.BuildPetsEntry(),
        BuildExtendedCollectionEntry(PanelIds.OUTFIT_STYLES, 17, "collections.outfit_styles"),
        GamepadOptions.BuildPlansEntry(),
        BuildExtendedCollectionEntry(PanelIds.SCRIBING, 20, "collections.scribing"),
        BuildExtendedCollectionEntry(PanelIds.SKILL_STYLES, 16, "collections.skill_styles"),
        GamepadOptions.BuildSkinsEntry(),
    }
end
