NQOL = NQOL or {}
local GamepadOptions = NQOL.GamepadOptions

local PanelIds = GamepadOptions.PanelIds
local ROOT_PANEL_ID = PanelIds.ROOT
local MOUNTS_PANEL_ID = PanelIds.MOUNTS
local ANTIQUITIES_PANEL_ID = PanelIds.ANTIQUITIES
local GEAR_PANEL_ID = PanelIds.GEAR
local PROVISIONING_PANEL_ID = PanelIds.PROVISIONING
local MAP_PANEL_ID = PanelIds.MAP
local UI_PANEL_ID = PanelIds.UI
local ACTIVE_QUEST_PANEL_ID = PanelIds.ACTIVE_QUEST
local CHAT_PANEL_ID = PanelIds.CHAT
local TICKER_PANEL_ID = PanelIds.TICKER
local UTILITY_PANEL_ID = PanelIds.UTILITY
local GROUPING_PANEL_ID = PanelIds.GROUPING
local AUTO_INVITE_PANEL_ID = PanelIds.AUTO_INVITE
local LUA_GC_PANEL_ID = PanelIds.LUA_GC
local AUTO_BOUND_PANEL_ID = PanelIds.AUTO_BOUND
local AUTO_CHARGE_PANEL_ID = PanelIds.AUTO_CHARGE
local AUTO_REPAIR_PANEL_ID = PanelIds.AUTO_REPAIR
local BUFFS_DEBUFFS_PANEL_ID = PanelIds.BUFFS_DEBUFFS
local BUFFS_DEBUFFS_TRACKERS_PANEL_ID = PanelIds.BUFFS_DEBUFFS_TRACKERS
local PROGRESS_PANEL_ID = PanelIds.PROGRESS
local XP_TRACKER_PANEL_ID = PanelIds.XP_TRACKER
local XP_TIMERS_PANEL_ID = PanelIds.XP_TIMERS
local COLLECTIONS_GEAR_PANEL_ID = PanelIds.COLLECTIONS_GEAR
local COLLECTIONS_HOUSING_PANEL_ID = PanelIds.COLLECTIONS_HOUSING
local COLLECTIONS_MOUNTS_PANEL_ID = PanelIds.COLLECTIONS_MOUNTS
local COLLECTIONS_SKINS_PANEL_ID = PanelIds.COLLECTIONS_SKINS
local COLLECTIONS_PETS_PANEL_ID = PanelIds.COLLECTIONS_PETS
local COLLECTIONS_MEMENTOS_PANEL_ID = PanelIds.COLLECTIONS_MEMENTOS
local COLLECTIONS_COMPANIONS_PANEL_ID = PanelIds.COLLECTIONS_COMPANIONS

function GamepadOptions.BuildPlayerFrameOptionsData()
    return {
        GamepadOptions.WithHeader(GamepadOptions.BuildShowNqolPlayerFrameOption(), NQOL.L("ui.headers.frame_91b0658")),
        GamepadOptions.BuildPlayerShowOnlyInCombatOption(),
        GamepadOptions.BuildPlayerBarsShowInSettingsOption(),
        GamepadOptions.BuildPlayerBarsShowTraumaOption(),
        GamepadOptions.BuildPlayerBarsShowNoHealingOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildPlayerBarsPresetOption(), NQOL.L("ui.headers.preset_bca7887")),
        GamepadOptions.BuildClassicEntry(),
        GamepadOptions.BuildPyramidEntry(),
        GamepadOptions.BuildStackEntry(),
        GamepadOptions.BuildVerticalEntry(),
        GamepadOptions.BuildRadialEntry(),
    }
end

function GamepadOptions.BuildRadialOptionsData()
    return {
        GamepadOptions.WithHeader(GamepadOptions.BuildRadialHorizontalPositionOption(), NQOL.L("ui.headers.position_cf1c85a")),
        GamepadOptions.BuildRadialVerticalPositionOption(),
        GamepadOptions.BuildRadialScaleOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildRadialHealthSideOption(), NQOL.L("ui.headers.bar_layout_61bec9a")),
        GamepadOptions.BuildRadialMagickaSideOption(),
        GamepadOptions.BuildRadialStaminaSideOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildRadialStackOption(), NQOL.L("ui.headers.stacking_99cb599")),
        GamepadOptions.BuildRadialStackTypeOption(),
        GamepadOptions.BuildRadialStackPositionOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildRadialFontOption(), NQOL.L("ui.headers.typography_f4beb9a")),
        GamepadOptions.BuildRadialFontSizeOption(),
        GamepadOptions.BuildRadialCurrentValueOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildPresetHealthBarColorOption(GamepadOptions.PLAYER_FRAME_RADIAL_PANEL_ID, 24, "radial"), NQOL.L("ui.headers.appearance_41def7a")),
        GamepadOptions.BuildPresetMagickaBarColorOption(GamepadOptions.PLAYER_FRAME_RADIAL_PANEL_ID, 25, "radial"),
        GamepadOptions.BuildPresetStaminaBarColorOption(GamepadOptions.PLAYER_FRAME_RADIAL_PANEL_ID, 26, "radial"),
        GamepadOptions.BuildPresetTraumaBarColorOption(GamepadOptions.PLAYER_FRAME_RADIAL_PANEL_ID, 27, "radial"),
        GamepadOptions.BuildRadialBorderSizeOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildRadialSmoothTransitionsOption(), NQOL.L("ui.headers.transitions_ab39260")),
        GamepadOptions.BuildRadialTransitionShadowOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildRadialShadowOption(), NQOL.L("ui.headers.shadow_aa0e7e8")),
        GamepadOptions.BuildRadialShadowIntensityOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildRadialFlyingPositiveAnimationOption(), NQOL.L("ui.headers.flying_animation_e2dffe3")),
        GamepadOptions.BuildRadialFlyingNegativeAnimationOption(),
        GamepadOptions.BuildRadialFlyingAnimationFontOption(),
        GamepadOptions.BuildRadialFlyingAnimationFontSizeOption(),
    }
end

function GamepadOptions.BuildClassicOptionsData()
    return {
        GamepadOptions.WithHeader(GamepadOptions.BuildClassicHorizontalPositionOption(), NQOL.L("ui.headers.position_cf1c85a")),
        GamepadOptions.BuildClassicVerticalPositionOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildClassicFontOption(), NQOL.L("ui.headers.typography_f4beb9a")),
        GamepadOptions.BuildClassicFontSizeOption(),
        GamepadOptions.BuildClassicCurrentValueOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildPresetHealthBarColorOption(GamepadOptions.PLAYER_FRAME_CLASSIC_PANEL_ID, 22, "classic"), NQOL.L("ui.headers.appearance_41def7a")),
        GamepadOptions.BuildPresetMagickaBarColorOption(GamepadOptions.PLAYER_FRAME_CLASSIC_PANEL_ID, 23, "classic"),
        GamepadOptions.BuildPresetStaminaBarColorOption(GamepadOptions.PLAYER_FRAME_CLASSIC_PANEL_ID, 24, "classic"),
        GamepadOptions.BuildPresetTraumaBarColorOption(GamepadOptions.PLAYER_FRAME_CLASSIC_PANEL_ID, 25, "classic"),
        GamepadOptions.BuildClassicSmoothTransitionsOption(),
        GamepadOptions.BuildClassicTransitionShadowOption(),
        GamepadOptions.BuildClassicShadowOption(),
        GamepadOptions.BuildClassicShadowIntensityOption(),
        GamepadOptions.BuildClassicBorderSizeOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildClassicBoxHeightOption(), NQOL.L("ui.headers.layout_972ad8d")),
        GamepadOptions.BuildClassicHealthWidthOption(),
        GamepadOptions.BuildClassicMagickaWidthOption(),
        GamepadOptions.BuildClassicStaminaWidthOption(),
        GamepadOptions.BuildClassicSeparationOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildClassicFlyingPositiveAnimationOption(), NQOL.L("ui.headers.flying_animation_e2dffe3")),
        GamepadOptions.BuildClassicFlyingNegativeAnimationOption(),
        GamepadOptions.BuildClassicFlyingAnimationFontOption(),
        GamepadOptions.BuildClassicFlyingAnimationFontSizeOption(),
    }
end

function GamepadOptions.BuildPyramidOptionsData()
    return {
        GamepadOptions.WithHeader(GamepadOptions.BuildPyramidHorizontalPositionOption(), NQOL.L("ui.headers.position_cf1c85a")),
        GamepadOptions.BuildPyramidVerticalPositionOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildPyramidFontOption(), NQOL.L("ui.headers.typography_f4beb9a")),
        GamepadOptions.BuildPyramidFontSizeOption(),
        GamepadOptions.BuildPyramidCurrentValueOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildPresetHealthBarColorOption(GamepadOptions.PLAYER_FRAME_PYRAMID_PANEL_ID, 22, "pyramid"), NQOL.L("ui.headers.appearance_41def7a")),
        GamepadOptions.BuildPresetMagickaBarColorOption(GamepadOptions.PLAYER_FRAME_PYRAMID_PANEL_ID, 23, "pyramid"),
        GamepadOptions.BuildPresetStaminaBarColorOption(GamepadOptions.PLAYER_FRAME_PYRAMID_PANEL_ID, 24, "pyramid"),
        GamepadOptions.BuildPresetTraumaBarColorOption(GamepadOptions.PLAYER_FRAME_PYRAMID_PANEL_ID, 25, "pyramid"),
        GamepadOptions.BuildPyramidSmoothTransitionsOption(),
        GamepadOptions.BuildPyramidTransitionShadowOption(),
        GamepadOptions.BuildPyramidShadowOption(),
        GamepadOptions.BuildPyramidShadowIntensityOption(),
        GamepadOptions.BuildPyramidBorderSizeOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildPyramidHealthHeightOption(), NQOL.L("ui.headers.layout_972ad8d")),
        GamepadOptions.BuildPyramidResourceHeightOption(),
        GamepadOptions.BuildPyramidHealthWidthOption(),
        GamepadOptions.BuildPyramidMagickaWidthOption(),
        GamepadOptions.BuildPyramidStaminaWidthOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildPyramidFlyingPositiveAnimationOption(), NQOL.L("ui.headers.flying_animation_e2dffe3")),
        GamepadOptions.BuildPyramidFlyingNegativeAnimationOption(),
        GamepadOptions.BuildPyramidFlyingAnimationFontOption(),
        GamepadOptions.BuildPyramidFlyingAnimationFontSizeOption(),
    }
end

function GamepadOptions.BuildStackOptionsData()
    return {
        GamepadOptions.WithHeader(GamepadOptions.BuildStackHorizontalPositionOption(), NQOL.L("ui.headers.position_cf1c85a")),
        GamepadOptions.BuildStackVerticalPositionOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildStackFontOption(), NQOL.L("ui.headers.typography_f4beb9a")),
        GamepadOptions.BuildStackFontSizeOption(),
        GamepadOptions.BuildStackCurrentValueOption(),
        GamepadOptions.BuildStackReverseOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildPresetHealthBarColorOption(GamepadOptions.PLAYER_FRAME_STACK_PANEL_ID, 23, "stack"), NQOL.L("ui.headers.appearance_41def7a")),
        GamepadOptions.BuildPresetMagickaBarColorOption(GamepadOptions.PLAYER_FRAME_STACK_PANEL_ID, 24, "stack"),
        GamepadOptions.BuildPresetStaminaBarColorOption(GamepadOptions.PLAYER_FRAME_STACK_PANEL_ID, 25, "stack"),
        GamepadOptions.BuildPresetTraumaBarColorOption(GamepadOptions.PLAYER_FRAME_STACK_PANEL_ID, 26, "stack"),
        GamepadOptions.BuildStackSmoothTransitionsOption(),
        GamepadOptions.BuildStackTransitionShadowOption(),
        GamepadOptions.BuildStackShadowOption(),
        GamepadOptions.BuildStackShadowIntensityOption(),
        GamepadOptions.BuildStackBorderSizeOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildStackWidthOption(), NQOL.L("ui.headers.layout_972ad8d")),
        GamepadOptions.BuildStackHealthHeightOption(),
        GamepadOptions.BuildStackMagickaHeightOption(),
        GamepadOptions.BuildStackStaminaHeightOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildStackFlyingPositiveAnimationOption(), NQOL.L("ui.headers.flying_animation_e2dffe3")),
        GamepadOptions.BuildStackFlyingNegativeAnimationOption(),
        GamepadOptions.BuildStackFlyingOrientationOption(),
        GamepadOptions.BuildStackFlyingAnimationFontOption(),
        GamepadOptions.BuildStackFlyingAnimationFontSizeOption(),
    }
end

function GamepadOptions.BuildVerticalOptionsData()
    return {
        GamepadOptions.WithHeader(GamepadOptions.BuildVerticalFontOption(), NQOL.L("ui.headers.typography_f4beb9a")),
        GamepadOptions.BuildVerticalFontSizeOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildPresetHealthBarColorOption(GamepadOptions.PLAYER_FRAME_VERTICAL_PANEL_ID, 37, "vertical"), NQOL.L("ui.headers.appearance_41def7a")),
        GamepadOptions.BuildPresetMagickaBarColorOption(GamepadOptions.PLAYER_FRAME_VERTICAL_PANEL_ID, 38, "vertical"),
        GamepadOptions.BuildPresetStaminaBarColorOption(GamepadOptions.PLAYER_FRAME_VERTICAL_PANEL_ID, 39, "vertical"),
        GamepadOptions.BuildPresetTraumaBarColorOption(GamepadOptions.PLAYER_FRAME_VERTICAL_PANEL_ID, 40, "vertical"),
        GamepadOptions.BuildVerticalSmoothTransitionsOption(),
        GamepadOptions.BuildVerticalTransitionShadowOption(),
        GamepadOptions.BuildVerticalShadowOption(),
        GamepadOptions.BuildVerticalShadowIntensityOption(),
        GamepadOptions.BuildVerticalBorderSizeOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildVerticalFlyingPositiveAnimationOption(), NQOL.L("ui.headers.flying_animation_e2dffe3")),
        GamepadOptions.BuildVerticalFlyingNegativeAnimationOption(),
        GamepadOptions.BuildVerticalFlyingAnimationFontOption(),
        GamepadOptions.BuildVerticalFlyingAnimationFontSizeOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildVerticalHealthWidthOption(), NQOL.L("ui.headers.health_3703cd2")),
        GamepadOptions.BuildVerticalHealthHeightOption(),
        GamepadOptions.BuildVerticalHealthXOption(),
        GamepadOptions.BuildVerticalHealthYOption(),
        GamepadOptions.BuildVerticalHealthFlyingOrientationOption(),
        GamepadOptions.BuildVerticalHealthCurrentValueOption(),
        GamepadOptions.BuildVerticalHealthReverseOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildVerticalMagickaWidthOption(), NQOL.L("ui.headers.magicka_3f9626e")),
        GamepadOptions.BuildVerticalMagickaHeightOption(),
        GamepadOptions.BuildVerticalMagickaXOption(),
        GamepadOptions.BuildVerticalMagickaYOption(),
        GamepadOptions.BuildVerticalMagickaFlyingOrientationOption(),
        GamepadOptions.BuildVerticalMagickaCurrentValueOption(),
        GamepadOptions.BuildVerticalMagickaReverseOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildVerticalStaminaWidthOption(), NQOL.L("ui.headers.stamina_b822361")),
        GamepadOptions.BuildVerticalStaminaHeightOption(),
        GamepadOptions.BuildVerticalStaminaXOption(),
        GamepadOptions.BuildVerticalStaminaYOption(),
        GamepadOptions.BuildVerticalStaminaFlyingOrientationOption(),
        GamepadOptions.BuildVerticalStaminaCurrentValueOption(),
        GamepadOptions.BuildVerticalStaminaReverseOption(),
    }
end

function GamepadOptions.BuildChatOptionsData()
    return {
        GamepadOptions.BuildChatAddTimestampOption(),
        GamepadOptions.BuildChatSavedMessagesOption(),
        GamepadOptions.BuildChatKeepHudOpenOption(),
        GamepadOptions.BuildChatHudHorizontalPositionOption(),
        GamepadOptions.BuildChatHudVerticalPositionOption(),
        GamepadOptions.BuildChatHudWidthOption(),
        GamepadOptions.BuildChatHudHeightOption(),
        GamepadOptions.BuildChatRemoveBackgroundOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildChatFilterGuildAdsOption(), NQOL.L("ui.headers.filters")),
        GamepadOptions.BuildChatFilterPlusMessagesOption(),
        GamepadOptions.BuildChatFilterWttWtsOption(),
        GamepadOptions.BuildChatFilterZoneItemsOption(),
        GamepadOptions.BuildChatFilterFriendStatusOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildChatWhisperColorOption(), NQOL.L("ui.headers.colors_88d5e4c")),
        GamepadOptions.BuildChatGuildColorsEntry(),
        GamepadOptions.WithHeader(GamepadOptions.BuildChatRemindersEntry(), NQOL.L("ui.headers.reminders_ae8c393")),
        GamepadOptions.WithHeader(GamepadOptions.BuildChatAnnotateMissingItemsEnabledOption(), NQOL.L("ui.headers.annotations_67d00a1")),
        GamepadOptions.BuildChatAnnotateMissingItemsWhisperMessageOption(),
    }
end

function GamepadOptions.BuildChatRemindersOptionsData()
    return {
        GamepadOptions.BuildChatRemindersEnabledOption(),
        GamepadOptions.BuildChatRemindersClearAllOption(),
        GamepadOptions.BuildChatRemindersShowInGameOption(),
        GamepadOptions.BuildChatRemindersShowInSettingsOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildChatRemindersHorizontalPositionOption(), NQOL.L("ui.headers.position_and_appearance_346f660")),
        GamepadOptions.BuildChatRemindersVerticalPositionOption(),
        GamepadOptions.BuildChatRemindersWidthOption(),
        GamepadOptions.BuildChatRemindersFontOption(),
        GamepadOptions.BuildChatRemindersFontSizeOption(),
        GamepadOptions.BuildChatRemindersBackgroundOpacityOption(),
        GamepadOptions.BuildChatRemindersBorderSizeOption(),
        GamepadOptions.BuildChatRemindersHeaderColorOption(),
        GamepadOptions.BuildChatRemindersTextColorOption(),
    }
end

function GamepadOptions.BuildChatGuildColorsOptionsData()
    return {
        GamepadOptions.BuildChatGuildColorsEnabledOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildChatGuildColorOption(1), NQOL.L("ui.headers.public_chat_68d579e")),
        GamepadOptions.BuildChatGuildColorOption(2),
        GamepadOptions.BuildChatGuildColorOption(3),
        GamepadOptions.BuildChatGuildColorOption(4),
        GamepadOptions.BuildChatGuildColorOption(5),
        GamepadOptions.WithHeader(GamepadOptions.BuildChatOfficerColorOption(1), NQOL.L("ui.headers.officers_chat_643c900")),
        GamepadOptions.BuildChatOfficerColorOption(2),
        GamepadOptions.BuildChatOfficerColorOption(3),
        GamepadOptions.BuildChatOfficerColorOption(4),
        GamepadOptions.BuildChatOfficerColorOption(5),
    }
end

function GamepadOptions.BuildTickerOptionsData()
    local options = {
        GamepadOptions.BuildTickerEnabledOption(),
        GamepadOptions.BuildTickerShowInSettingsOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildTickerHorizontalPositionOption(), NQOL.L("ui.headers.position_and_appearance_346f660")),
        GamepadOptions.BuildTickerVerticalPositionOption(),
        GamepadOptions.BuildTickerFontOption(),
        GamepadOptions.BuildTickerFontSizeOption(),
        GamepadOptions.BuildTickerColoredIconsOption(),
        GamepadOptions.BuildTickerBackgroundOpacityOption(),
    }

    local entryOptions = {}
    for _, entryDefinition in ipairs(NQOL.Features.Ticker.GetEntries()) do
        entryOptions[#entryOptions + 1] = GamepadOptions.BuildTickerEntryOption(0, entryDefinition)
    end

    table.sort(entryOptions, function(left, right)
        return (left.text or "") < (right.text or "")
    end)

    for index, option in ipairs(entryOptions) do
        if index == 1 then
            GamepadOptions.WithHeader(option, NQOL.L("ui.headers.entries_f056d0d"))
        end
        options[#options + 1] = option
    end

    for index, option in ipairs(options) do
        option.settingId = index
    end

    return options
end

function GamepadOptions.BuildProgressOptionsData()
    return {
        GamepadOptions.BuildArenasEntry(),
        GamepadOptions.BuildBaseDungeonsEntry(),
        GamepadOptions.BuildDlcDungeonsEntry(),
        {
            panel = PROGRESS_PANEL_ID,
            system = PROGRESS_PANEL_ID,
            settingId = 2,
            controlType = OPTIONS_INVOKE_CALLBACK,
            text = NQOL.L("ui.progress_panels.gold_c57604d"),
            gamepadTextOverride = NQOL.L("ui.progress_panels.gold_c57604d"),
            onInitializeFunction = function(control)
                GamepadOptions.InitializeNavigationEntry(control)
            end,
            gamepadCustomTooltipFunction = function(tooltipControl)
                GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, NQOL.L("ui.progress_panels.track_current_gold_recent_gold_gains_and_gold_per_mi_298ad8d"))
            end,
            callback = function()
                GamepadOptions.ShowPanel(GamepadOptions.GOLD_TRACKER_PANEL_ID)
            end,
        },
        GamepadOptions.BuildInfiniteArchiveEntry(),
        GamepadOptions.BuildTrialsEntry(),
        GamepadOptions.BuildXpTrackerEntry(),
    }
end

function GamepadOptions.BuildCollectionsHousingOptionsData()
    local housing = NQOL.Features.CollectionsHousing

    return {
        GamepadOptions.WithHeader(GamepadOptions.BuildPositionSliderOption(COLLECTIONS_HOUSING_PANEL_ID, 1, housing.GetHorizontalPositionLabel(), housing.GetHorizontalPositionTooltip(), 0, 100, "%.0f", housing.GetHorizontalPosition, housing.SetHorizontalPosition), NQOL.L("ui.headers.position_and_appearance_346f660")),
        GamepadOptions.BuildPositionSliderOption(COLLECTIONS_HOUSING_PANEL_ID, 2, housing.GetVerticalPositionLabel(), housing.GetVerticalPositionTooltip(), 0, 100, "%.0f", housing.GetVerticalPosition, housing.SetVerticalPosition),
        GamepadOptions.BuildFiniteListOption(COLLECTIONS_HOUSING_PANEL_ID, 3, housing.GetFontLabel(), housing.GetFontTooltip(), housing.GetFontChoices(), housing.GetFontChoiceNames(), housing.GetFont, housing.SetFont),
        GamepadOptions.BuildValueStepSliderOption(COLLECTIONS_HOUSING_PANEL_ID, 4, housing.GetScaleLabel(), housing.GetScaleTooltip(), housing.GetScaleMin(), housing.GetScaleMax(), "%.0f%%", housing.GetScale, housing.SetScale, 5),
        GamepadOptions.BuildSliderOption(COLLECTIONS_HOUSING_PANEL_ID, 5, housing.GetBackgroundOpacityLabel(), housing.GetBackgroundOpacityTooltip(), housing.GetBackgroundOpacityMin(), housing.GetBackgroundOpacityMax(), "%.0f", housing.GetBackgroundOpacity, housing.SetBackgroundOpacity, 1),
    }
end

function GamepadOptions.BuildCollectionsMountsOptionsData()
    local mounts = NQOL.Features.CollectionsMounts

    return {
        GamepadOptions.WithHeader(GamepadOptions.BuildPositionSliderOption(COLLECTIONS_MOUNTS_PANEL_ID, 1, mounts.GetHorizontalPositionLabel(), mounts.GetHorizontalPositionTooltip(), 0, 100, "%.0f", mounts.GetHorizontalPosition, mounts.SetHorizontalPosition), NQOL.L("ui.headers.position_and_appearance_346f660")),
        GamepadOptions.BuildPositionSliderOption(COLLECTIONS_MOUNTS_PANEL_ID, 2, mounts.GetVerticalPositionLabel(), mounts.GetVerticalPositionTooltip(), 0, 100, "%.0f", mounts.GetVerticalPosition, mounts.SetVerticalPosition),
        GamepadOptions.BuildFiniteListOption(COLLECTIONS_MOUNTS_PANEL_ID, 3, mounts.GetFontLabel(), mounts.GetFontTooltip(), mounts.GetFontChoices(), mounts.GetFontChoiceNames(), mounts.GetFont, mounts.SetFont),
        GamepadOptions.BuildValueStepSliderOption(COLLECTIONS_MOUNTS_PANEL_ID, 4, mounts.GetScaleLabel(), mounts.GetScaleTooltip(), mounts.GetScaleMin(), mounts.GetScaleMax(), "%.0f%%", mounts.GetScale, mounts.SetScale, 5),
        GamepadOptions.BuildSliderOption(COLLECTIONS_MOUNTS_PANEL_ID, 5, mounts.GetBackgroundOpacityLabel(), mounts.GetBackgroundOpacityTooltip(), mounts.GetBackgroundOpacityMin(), mounts.GetBackgroundOpacityMax(), "%.0f", mounts.GetBackgroundOpacity, mounts.SetBackgroundOpacity, 1),
    }
end

function GamepadOptions.BuildCollectionsSkinsOptionsData()
    local skins = NQOL.Features.CollectionsSkins

    return {
        GamepadOptions.WithHeader(GamepadOptions.BuildPositionSliderOption(COLLECTIONS_SKINS_PANEL_ID, 1, skins.GetHorizontalPositionLabel(), skins.GetHorizontalPositionTooltip(), 0, 100, "%.0f", skins.GetHorizontalPosition, skins.SetHorizontalPosition), NQOL.L("ui.headers.position_and_appearance_346f660")),
        GamepadOptions.BuildPositionSliderOption(COLLECTIONS_SKINS_PANEL_ID, 2, skins.GetVerticalPositionLabel(), skins.GetVerticalPositionTooltip(), 0, 100, "%.0f", skins.GetVerticalPosition, skins.SetVerticalPosition),
        GamepadOptions.BuildFiniteListOption(COLLECTIONS_SKINS_PANEL_ID, 3, skins.GetFontLabel(), skins.GetFontTooltip(), skins.GetFontChoices(), skins.GetFontChoiceNames(), skins.GetFont, skins.SetFont),
        GamepadOptions.BuildValueStepSliderOption(COLLECTIONS_SKINS_PANEL_ID, 4, skins.GetScaleLabel(), skins.GetScaleTooltip(), skins.GetScaleMin(), skins.GetScaleMax(), "%.0f%%", skins.GetScale, skins.SetScale, 5),
        GamepadOptions.BuildSliderOption(COLLECTIONS_SKINS_PANEL_ID, 5, skins.GetBackgroundOpacityLabel(), skins.GetBackgroundOpacityTooltip(), skins.GetBackgroundOpacityMin(), skins.GetBackgroundOpacityMax(), "%.0f", skins.GetBackgroundOpacity, skins.SetBackgroundOpacity, 1),
    }
end

local function BuildAdditionalCollectibleOptionsData(panelId, feature)
    return {
        GamepadOptions.WithHeader(GamepadOptions.BuildPositionSliderOption(panelId, 1, feature.GetHorizontalPositionLabel(), feature.GetHorizontalPositionTooltip(), 0, 100, "%.0f", feature.GetHorizontalPosition, feature.SetHorizontalPosition), NQOL.L("ui.headers.position_and_appearance_346f660")),
        GamepadOptions.BuildPositionSliderOption(panelId, 2, feature.GetVerticalPositionLabel(), feature.GetVerticalPositionTooltip(), 0, 100, "%.0f", feature.GetVerticalPosition, feature.SetVerticalPosition),
        GamepadOptions.BuildFiniteListOption(panelId, 3, feature.GetFontLabel(), feature.GetFontTooltip(), feature.GetFontChoices(), feature.GetFontChoiceNames(), feature.GetFont, feature.SetFont),
        GamepadOptions.BuildValueStepSliderOption(panelId, 4, feature.GetScaleLabel(), feature.GetScaleTooltip(), feature.GetScaleMin(), feature.GetScaleMax(), "%.0f%%", feature.GetScale, feature.SetScale, 5),
        GamepadOptions.BuildSliderOption(panelId, 5, feature.GetBackgroundOpacityLabel(), feature.GetBackgroundOpacityTooltip(), feature.GetBackgroundOpacityMin(), feature.GetBackgroundOpacityMax(), "%.0f", feature.GetBackgroundOpacity, feature.SetBackgroundOpacity, 1),
    }
end

function GamepadOptions.BuildCollectionsPetsOptionsData()
    return BuildAdditionalCollectibleOptionsData(COLLECTIONS_PETS_PANEL_ID, NQOL.Features.CollectionsPets)
end

function GamepadOptions.BuildCollectionsMementosOptionsData()
    return BuildAdditionalCollectibleOptionsData(COLLECTIONS_MEMENTOS_PANEL_ID, NQOL.Features.CollectionsMementos)
end

function GamepadOptions.BuildCollectionsCompanionsOptionsData()
    return BuildAdditionalCollectibleOptionsData(COLLECTIONS_COMPANIONS_PANEL_ID, NQOL.Features.CollectionsCompanions)
end

function GamepadOptions.BuildCollectionsOptionsData()
    return {
        GamepadOptions.BuildCollectionsCompanionsEntry(),
        GamepadOptions.BuildCollectionsDrinkRecipesEntry(),
        GamepadOptions.BuildCollectionsFoodRecipesEntry(),
        GamepadOptions.BuildCollectionsGearEntry(),
        GamepadOptions.BuildCollectionsHousingEntry(),
        GamepadOptions.BuildCollectionsMementosEntry(),
        GamepadOptions.BuildCollectionsMountsEntry(),
        GamepadOptions.BuildCollectionsPetsEntry(),
        GamepadOptions.BuildCollectionsPlansEntry(),
        GamepadOptions.BuildCollectionsSkinsEntry(),
    }
end

function GamepadOptions.BuildCollectionsGearOptionsData()
    local gear = NQOL.Features.CollectionsGear

    return {
        GamepadOptions.BuildCheckboxOption(COLLECTIONS_GEAR_PANEL_ID, 3, gear.GetSetCardLabel(), gear.GetSetCardTooltip(), gear.GetSetCard, gear.SetSetCard),
        GamepadOptions.BuildCheckboxOption(COLLECTIONS_GEAR_PANEL_ID, 9, gear.GetShowWatermarkLabel(), gear.GetShowWatermarkTooltip(), gear.GetShowWatermark, gear.SetShowWatermark, nil, gear.GetShowWatermarkDefault),
        GamepadOptions.WithHeader(GamepadOptions.BuildPositionSliderOption(COLLECTIONS_GEAR_PANEL_ID, 4, gear.GetHorizontalPositionLabel(), gear.GetHorizontalPositionTooltip(), 0, 100, "%.0f", gear.GetHorizontalPosition, gear.SetHorizontalPosition), NQOL.L("ui.headers.position_and_appearance_346f660")),
        GamepadOptions.BuildPositionSliderOption(COLLECTIONS_GEAR_PANEL_ID, 5, gear.GetVerticalPositionLabel(), gear.GetVerticalPositionTooltip(), 0, 100, "%.0f", gear.GetVerticalPosition, gear.SetVerticalPosition),
        GamepadOptions.BuildFiniteListOption(COLLECTIONS_GEAR_PANEL_ID, 6, gear.GetFontLabel(), gear.GetFontTooltip(), gear.GetFontChoices(), gear.GetFontChoiceNames(), gear.GetFont, gear.SetFont),
        GamepadOptions.BuildValueStepSliderOption(COLLECTIONS_GEAR_PANEL_ID, 7, gear.GetScaleLabel(), gear.GetScaleTooltip(), gear.GetScaleMin(), gear.GetScaleMax(), "%.0f%%", gear.GetScale, gear.SetScale, 5),
        GamepadOptions.BuildSliderOption(COLLECTIONS_GEAR_PANEL_ID, 8, gear.GetBackgroundOpacityLabel(), gear.GetBackgroundOpacityTooltip(), gear.GetBackgroundOpacityMin(), gear.GetBackgroundOpacityMax(), "%.0f", gear.GetBackgroundOpacity, gear.SetBackgroundOpacity, 1),
    }
end

function GamepadOptions.BuildCollectionsRecipesOptionsData(panelId)
    local recipes = NQOL.Features.CollectionsRecipes

    return {
        GamepadOptions.BuildCheckboxOption(panelId, 5, recipes.GetRecipeCardLabel(), recipes.GetRecipeCardTooltip(), recipes.GetRecipeCard, recipes.SetRecipeCard),
        GamepadOptions.WithHeader(GamepadOptions.BuildPositionSliderOption(panelId, 6, recipes.GetHorizontalPositionLabel(), recipes.GetHorizontalPositionTooltip(), 0, 100, "%.0f", recipes.GetHorizontalPosition, recipes.SetHorizontalPosition), NQOL.L("ui.headers.position_and_appearance_346f660")),
        GamepadOptions.BuildPositionSliderOption(panelId, 7, recipes.GetVerticalPositionLabel(), recipes.GetVerticalPositionTooltip(), 0, 100, "%.0f", recipes.GetVerticalPosition, recipes.SetVerticalPosition),
        GamepadOptions.BuildFiniteListOption(panelId, 8, recipes.GetFontLabel(), recipes.GetFontTooltip(), recipes.GetFontChoices(), recipes.GetFontChoiceNames(), recipes.GetFont, recipes.SetFont),
        GamepadOptions.BuildValueStepSliderOption(panelId, 9, recipes.GetScaleLabel(), recipes.GetScaleTooltip(), recipes.GetScaleMin(), recipes.GetScaleMax(), "%.0f%%", recipes.GetScale, recipes.SetScale, 5),
        GamepadOptions.BuildSliderOption(panelId, 10, recipes.GetBackgroundOpacityLabel(), recipes.GetBackgroundOpacityTooltip(), recipes.GetBackgroundOpacityMin(), recipes.GetBackgroundOpacityMax(), "%.0f", recipes.GetBackgroundOpacity, recipes.SetBackgroundOpacity, 1),
    }
end

function GamepadOptions.BuildBaseDungeonsOptionsData()
    local dungeons = NQOL.Features.ProgressDungeons

    return {
        GamepadOptions.BuildFiniteListOption(GamepadOptions.DUNGEONS_PANEL_ID, 3, dungeons.GetDungeonsDetailLevelLabel(), dungeons.GetDungeonsDetailLevelTooltip(), dungeons.GetDungeonsDetailLevelChoices(), dungeons.GetDungeonsDetailLevelChoiceNames(), dungeons.GetBaseDungeonsDetailLevel, dungeons.SetBaseDungeonsDetailLevel),
        GamepadOptions.BuildCheckboxOption(GamepadOptions.DUNGEONS_PANEL_ID, 4, dungeons.GetDungeonsShowWatermarkLabel(), dungeons.GetDungeonsShowWatermarkTooltip(), dungeons.GetBaseDungeonsShowWatermark, dungeons.SetBaseDungeonsShowWatermark, nil, dungeons.GetBaseDungeonsShowWatermarkDefault),
        GamepadOptions.WithHeader(GamepadOptions.BuildPositionSliderOption(GamepadOptions.DUNGEONS_PANEL_ID, 6, dungeons.GetDungeonsHorizontalPositionLabel(), dungeons.GetBaseDungeonsHorizontalPositionTooltip(), 0, 100, "%.0f", dungeons.GetBaseDungeonsHorizontalPosition, dungeons.SetBaseDungeonsHorizontalPosition), NQOL.L("ui.headers.position_cf1c85a")),
        GamepadOptions.BuildPositionSliderOption(GamepadOptions.DUNGEONS_PANEL_ID, 7, dungeons.GetDungeonsVerticalPositionLabel(), dungeons.GetBaseDungeonsVerticalPositionTooltip(), 0, 100, "%.0f", dungeons.GetBaseDungeonsVerticalPosition, dungeons.SetBaseDungeonsVerticalPosition),
        GamepadOptions.WithHeader(GamepadOptions.BuildFiniteListOption(GamepadOptions.DUNGEONS_PANEL_ID, 9, dungeons.GetDungeonsFontLabel(), dungeons.GetDungeonsFontTooltip(), dungeons.GetDungeonsFontChoices(), dungeons.GetDungeonsFontChoiceNames(), dungeons.GetBaseDungeonsFont, dungeons.SetBaseDungeonsFont), NQOL.L("ui.headers.appearance_41def7a")),
        GamepadOptions.BuildValueStepSliderOption(GamepadOptions.DUNGEONS_PANEL_ID, 10, dungeons.GetDungeonsFontSizeLabel(), dungeons.GetDungeonsFontSizeTooltip(), dungeons.GetDungeonsFontSizeMin(), dungeons.GetDungeonsFontSizeMax(), "%.0f", dungeons.GetBaseDungeonsFontSize, dungeons.SetBaseDungeonsFontSize, 1),
        GamepadOptions.BuildSliderOption(GamepadOptions.DUNGEONS_PANEL_ID, 11, dungeons.GetDungeonsBackgroundOpacityLabel(), dungeons.GetDungeonsBackgroundOpacityTooltip(), dungeons.GetDungeonsBackgroundOpacityMin(), dungeons.GetDungeonsBackgroundOpacityMax(), "%.0f", dungeons.GetBaseDungeonsBackgroundOpacity, dungeons.SetBaseDungeonsBackgroundOpacity, 1, nil, dungeons.GetBaseDungeonsBackgroundOpacityDefault),
    }
end

function GamepadOptions.BuildDlcDungeonsOptionsData()
    local dungeons = NQOL.Features.ProgressDungeons

    return {
        GamepadOptions.BuildFiniteListOption(GamepadOptions.DLC_DUNGEONS_PANEL_ID, 3, dungeons.GetDungeonsDetailLevelLabel(), dungeons.GetDungeonsDetailLevelTooltip(), dungeons.GetDungeonsDetailLevelChoices(), dungeons.GetDungeonsDetailLevelChoiceNames(), dungeons.GetDlcDungeonsDetailLevel, dungeons.SetDlcDungeonsDetailLevel),
        GamepadOptions.BuildCheckboxOption(GamepadOptions.DLC_DUNGEONS_PANEL_ID, 4, dungeons.GetDungeonsShowWatermarkLabel(), dungeons.GetDungeonsShowWatermarkTooltip(), dungeons.GetDlcDungeonsShowWatermark, dungeons.SetDlcDungeonsShowWatermark, nil, dungeons.GetDlcDungeonsShowWatermarkDefault),
        GamepadOptions.WithHeader(GamepadOptions.BuildPositionSliderOption(GamepadOptions.DLC_DUNGEONS_PANEL_ID, 6, dungeons.GetDungeonsHorizontalPositionLabel(), dungeons.GetDlcDungeonsHorizontalPositionTooltip(), 0, 100, "%.0f", dungeons.GetDlcDungeonsHorizontalPosition, dungeons.SetDlcDungeonsHorizontalPosition), NQOL.L("ui.headers.position_cf1c85a")),
        GamepadOptions.BuildPositionSliderOption(GamepadOptions.DLC_DUNGEONS_PANEL_ID, 7, dungeons.GetDungeonsVerticalPositionLabel(), dungeons.GetDlcDungeonsVerticalPositionTooltip(), 0, 100, "%.0f", dungeons.GetDlcDungeonsVerticalPosition, dungeons.SetDlcDungeonsVerticalPosition),
        GamepadOptions.WithHeader(GamepadOptions.BuildFiniteListOption(GamepadOptions.DLC_DUNGEONS_PANEL_ID, 9, dungeons.GetDungeonsFontLabel(), dungeons.GetDungeonsFontTooltip(), dungeons.GetDungeonsFontChoices(), dungeons.GetDungeonsFontChoiceNames(), dungeons.GetDlcDungeonsFont, dungeons.SetDlcDungeonsFont), NQOL.L("ui.headers.appearance_41def7a")),
        GamepadOptions.BuildValueStepSliderOption(GamepadOptions.DLC_DUNGEONS_PANEL_ID, 10, dungeons.GetDungeonsFontSizeLabel(), dungeons.GetDungeonsFontSizeTooltip(), dungeons.GetDungeonsFontSizeMin(), dungeons.GetDungeonsFontSizeMax(), "%.0f", dungeons.GetDlcDungeonsFontSize, dungeons.SetDlcDungeonsFontSize, 1),
        GamepadOptions.BuildSliderOption(GamepadOptions.DLC_DUNGEONS_PANEL_ID, 11, dungeons.GetDungeonsBackgroundOpacityLabel(), dungeons.GetDungeonsBackgroundOpacityTooltip(), dungeons.GetDungeonsBackgroundOpacityMin(), dungeons.GetDungeonsBackgroundOpacityMax(), "%.0f", dungeons.GetDlcDungeonsBackgroundOpacity, dungeons.SetDlcDungeonsBackgroundOpacity, 1, nil, dungeons.GetDlcDungeonsBackgroundOpacityDefault),
    }
end

function GamepadOptions.BuildTrialsOptionsData()
    local trials = NQOL.Features.ProgressTrials

    return {
        GamepadOptions.BuildFiniteListOption(GamepadOptions.TRIALS_PANEL_ID, 3, trials.GetTrialsDetailLevelLabel(), trials.GetTrialsDetailLevelTooltip(), trials.GetTrialsDetailLevelChoices(), trials.GetTrialsDetailLevelChoiceNames(), trials.GetTrialsDetailLevel, trials.SetTrialsDetailLevel),
        GamepadOptions.BuildCheckboxOption(GamepadOptions.TRIALS_PANEL_ID, 4, trials.GetTrialsShowWatermarkLabel(), trials.GetTrialsShowWatermarkTooltip(), trials.GetTrialsShowWatermark, trials.SetTrialsShowWatermark, nil, trials.GetTrialsShowWatermarkDefault),
        GamepadOptions.WithHeader(GamepadOptions.BuildPositionSliderOption(GamepadOptions.TRIALS_PANEL_ID, 6, trials.GetTrialsHorizontalPositionLabel(), trials.GetTrialsHorizontalPositionTooltip(), 0, 100, "%.0f", trials.GetTrialsHorizontalPosition, trials.SetTrialsHorizontalPosition), NQOL.L("ui.headers.position_cf1c85a")),
        GamepadOptions.BuildPositionSliderOption(GamepadOptions.TRIALS_PANEL_ID, 7, trials.GetTrialsVerticalPositionLabel(), trials.GetTrialsVerticalPositionTooltip(), 0, 100, "%.0f", trials.GetTrialsVerticalPosition, trials.SetTrialsVerticalPosition),
        GamepadOptions.WithHeader(GamepadOptions.BuildFiniteListOption(GamepadOptions.TRIALS_PANEL_ID, 9, trials.GetTrialsFontLabel(), trials.GetTrialsFontTooltip(), trials.GetTrialsFontChoices(), trials.GetTrialsFontChoiceNames(), trials.GetTrialsFont, trials.SetTrialsFont), NQOL.L("ui.headers.appearance_41def7a")),
        GamepadOptions.BuildValueStepSliderOption(GamepadOptions.TRIALS_PANEL_ID, 10, trials.GetTrialsFontSizeLabel(), trials.GetTrialsFontSizeTooltip(), trials.GetTrialsFontSizeMin(), trials.GetTrialsFontSizeMax(), "%.0f", trials.GetTrialsFontSize, trials.SetTrialsFontSize, 1),
        GamepadOptions.BuildSliderOption(GamepadOptions.TRIALS_PANEL_ID, 11, trials.GetTrialsBackgroundOpacityLabel(), trials.GetTrialsBackgroundOpacityTooltip(), trials.GetTrialsBackgroundOpacityMin(), trials.GetTrialsBackgroundOpacityMax(), "%.0f", trials.GetTrialsBackgroundOpacity, trials.SetTrialsBackgroundOpacity, 1, nil, trials.GetTrialsBackgroundOpacityDefault),
    }
end

function GamepadOptions.BuildArenasOptionsData()
    local arenas = NQOL.Features.ProgressArenas

    return {
        GamepadOptions.BuildFiniteListOption(GamepadOptions.ARENAS_PANEL_ID, 3, arenas.GetArenasDetailLevelLabel(), arenas.GetArenasDetailLevelTooltip(), arenas.GetArenasDetailLevelChoices(), arenas.GetArenasDetailLevelChoiceNames(), arenas.GetArenasDetailLevel, arenas.SetArenasDetailLevel),
        GamepadOptions.BuildCheckboxOption(GamepadOptions.ARENAS_PANEL_ID, 4, arenas.GetArenasShowWatermarkLabel(), arenas.GetArenasShowWatermarkTooltip(), arenas.GetArenasShowWatermark, arenas.SetArenasShowWatermark, nil, arenas.GetArenasShowWatermarkDefault),
        GamepadOptions.WithHeader(GamepadOptions.BuildPositionSliderOption(GamepadOptions.ARENAS_PANEL_ID, 6, arenas.GetArenasHorizontalPositionLabel(), arenas.GetArenasHorizontalPositionTooltip(), 0, 100, "%.0f", arenas.GetArenasHorizontalPosition, arenas.SetArenasHorizontalPosition), NQOL.L("ui.headers.position_cf1c85a")),
        GamepadOptions.BuildPositionSliderOption(GamepadOptions.ARENAS_PANEL_ID, 7, arenas.GetArenasVerticalPositionLabel(), arenas.GetArenasVerticalPositionTooltip(), 0, 100, "%.0f", arenas.GetArenasVerticalPosition, arenas.SetArenasVerticalPosition),
        GamepadOptions.WithHeader(GamepadOptions.BuildFiniteListOption(GamepadOptions.ARENAS_PANEL_ID, 9, arenas.GetArenasFontLabel(), arenas.GetArenasFontTooltip(), arenas.GetArenasFontChoices(), arenas.GetArenasFontChoiceNames(), arenas.GetArenasFont, arenas.SetArenasFont), NQOL.L("ui.headers.appearance_41def7a")),
        GamepadOptions.BuildValueStepSliderOption(GamepadOptions.ARENAS_PANEL_ID, 10, arenas.GetArenasFontSizeLabel(), arenas.GetArenasFontSizeTooltip(), arenas.GetArenasFontSizeMin(), arenas.GetArenasFontSizeMax(), "%.0f", arenas.GetArenasFontSize, arenas.SetArenasFontSize, 1),
        GamepadOptions.BuildSliderOption(GamepadOptions.ARENAS_PANEL_ID, 11, arenas.GetArenasBackgroundOpacityLabel(), arenas.GetArenasBackgroundOpacityTooltip(), arenas.GetArenasBackgroundOpacityMin(), arenas.GetArenasBackgroundOpacityMax(), "%.0f", arenas.GetArenasBackgroundOpacity, arenas.SetArenasBackgroundOpacity, 1, nil, arenas.GetArenasBackgroundOpacityDefault),
    }
end

function GamepadOptions.BuildInfiniteArchiveOptionsData()
    local archive = NQOL.Features.ProgressInfiniteArchive
    local panelId = GamepadOptions.INFINITE_ARCHIVE_PANEL_ID

    return {
        GamepadOptions.BuildFiniteListOption(panelId, 1, archive.GetDetailLevelLabel(), archive.GetDetailLevelTooltip(), archive.GetDetailLevelChoices(), archive.GetDetailLevelChoiceNames(), archive.GetDetailLevel, archive.SetDetailLevel),
        GamepadOptions.BuildCheckboxOption(panelId, 2, archive.GetShowWatermarkLabel(), archive.GetShowWatermarkTooltip(), archive.GetShowWatermark, archive.SetShowWatermark, nil, archive.GetShowWatermarkDefault),
        GamepadOptions.WithHeader(GamepadOptions.BuildPositionSliderOption(panelId, 3, archive.GetHorizontalPositionLabel(), archive.GetHorizontalPositionTooltip(), 0, 100, "%.0f", archive.GetHorizontalPosition, archive.SetHorizontalPosition), NQOL.L("ui.headers.position_cf1c85a")),
        GamepadOptions.BuildPositionSliderOption(panelId, 4, archive.GetVerticalPositionLabel(), archive.GetVerticalPositionTooltip(), 0, 100, "%.0f", archive.GetVerticalPosition, archive.SetVerticalPosition),
        GamepadOptions.WithHeader(GamepadOptions.BuildFiniteListOption(panelId, 5, archive.GetFontLabel(), archive.GetFontTooltip(), archive.GetFontChoices(), archive.GetFontChoiceNames(), archive.GetFont, archive.SetFont), NQOL.L("ui.headers.appearance_41def7a")),
        GamepadOptions.BuildValueStepSliderOption(panelId, 6, archive.GetFontSizeLabel(), archive.GetFontSizeTooltip(), archive.GetFontSizeMin(), archive.GetFontSizeMax(), "%.0f", archive.GetFontSize, archive.SetFontSize, 1),
        GamepadOptions.BuildSliderOption(panelId, 7, archive.GetBackgroundOpacityLabel(), archive.GetBackgroundOpacityTooltip(), archive.GetBackgroundOpacityMin(), archive.GetBackgroundOpacityMax(), "%.0f", archive.GetBackgroundOpacity, archive.SetBackgroundOpacity, 1, nil, archive.GetBackgroundOpacityDefault),
    }
end

function GamepadOptions.BuildXpTrackerOptionsData()
    local progress = NQOL.Features.Progress

    return {
        GamepadOptions.BuildXpTrackerEnabledOption(),
        GamepadOptions.BuildXpTrackerShowInSettingsOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildXpTrackerHorizontalPositionOption(), NQOL.L("ui.headers.position_and_appearance_346f660")),
        GamepadOptions.BuildXpTrackerVerticalPositionOption(),
        GamepadOptions.BuildXpTrackerFontOption(),
        GamepadOptions.BuildXpTrackerFontSizeOption(),
        GamepadOptions.BuildXpTrackerBackgroundOpacityOption(),
        GamepadOptions.BuildFiniteListOption(XP_TRACKER_PANEL_ID, 10, progress.GetXpProgressEstimatorLabel(), progress.GetXpProgressEstimatorTooltip(), progress.GetXpProgressEstimatorChoices(), progress.GetXpProgressEstimatorChoiceNames(), progress.GetXpProgressEstimator, progress.SetXpProgressEstimator),
        GamepadOptions.WithHeader(GamepadOptions.BuildCheckboxOption(XP_TRACKER_PANEL_ID, 11, progress.GetXpBarVisibleLabel(), progress.GetXpBarVisibleTooltip(), progress.GetXpBarVisible, progress.SetXpBarVisible), NQOL.L("ui.headers.visibility_7d9ff4f")),
        GamepadOptions.BuildCheckboxOption(XP_TRACKER_PANEL_ID, 15, progress.GetXpEnlightenmentVisibleLabel(), progress.GetXpEnlightenmentVisibleTooltip(), progress.GetXpEnlightenmentVisible, progress.SetXpEnlightenmentVisible),
        GamepadOptions.BuildCheckboxOption(XP_TRACKER_PANEL_ID, 12, progress.GetXpGoalVisibleLabel(), progress.GetXpGoalVisibleTooltip(), progress.GetXpGoalVisible, progress.SetXpGoalVisible),
        GamepadOptions.BuildCheckboxOption(XP_TRACKER_PANEL_ID, 13, progress.GetXpTrackersVisibleLabel(), progress.GetXpTrackersVisibleTooltip(), progress.GetXpTrackersVisible, progress.SetXpTrackersVisible),
        GamepadOptions.BuildCheckboxOption(XP_TRACKER_PANEL_ID, 14, progress.GetXpChartVisibleLabel(), progress.GetXpChartVisibleTooltip(), progress.GetXpChartVisible, progress.SetXpChartVisible),
        GamepadOptions.BuildXpTimersEntry(),
        {
            panel = XP_TRACKER_PANEL_ID,
            system = XP_TRACKER_PANEL_ID,
            settingId = 17,
            controlType = OPTIONS_INVOKE_CALLBACK,
            header = GamepadOptions.MakeHeader(NQOL.L("ui.headers.actions_c3cd636")),
            text = progress.GetXpResetTimersLabel(),
            gamepadTextOverride = progress.GetXpResetTimersLabel(),
            onInitializeFunction = GamepadOptions.InitializeDecorativeEntry,
            gamepadCustomTooltipFunction = function(tooltipControl)
                GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, progress.GetXpResetTimersTooltip())
            end,
            callback = function()
                GamepadOptions.ShowResetTimersDialog(
                    GamepadOptions.XP_RESET_TIMERS_DIALOG_NAME,
                    progress.GetXpResetTimersLabel(),
                    NQOL.L("dialogs.reset_xp_session"),
                    progress.ResetXpTimers
                )
            end,
        },
    }
end

function GamepadOptions.BuildXpTimersOptionsData()
    local options = {}
    for index, timer in ipairs(NQOL.Features.Progress.GetXpTimers()) do
        options[#options + 1] = GamepadOptions.BuildXpTimerOption(index, timer)
    end

    return options
end

function GamepadOptions.BuildGoldTrackerOptionsData()
    local gold = NQOL.Features.ProgressGold

    return {
        GamepadOptions.BuildCheckboxOption(GamepadOptions.GOLD_TRACKER_PANEL_ID, 1, gold.GetGoldEnabledLabel(), gold.GetGoldEnabledTooltip(), gold.GetGoldEnabled, gold.SetGoldEnabled),
        GamepadOptions.BuildCheckboxOption(GamepadOptions.GOLD_TRACKER_PANEL_ID, 2, gold.GetGoldShowInSettingsLabel(), gold.GetGoldShowInSettingsTooltip(), gold.GetGoldShowInSettings, gold.SetGoldShowInSettings),
        GamepadOptions.WithHeader(GamepadOptions.BuildPositionSliderOption(GamepadOptions.GOLD_TRACKER_PANEL_ID, 4, gold.GetGoldHorizontalPositionLabel(), gold.GetGoldHorizontalPositionTooltip(), 0, 100, "%.0f", gold.GetGoldHorizontalPosition, gold.SetGoldHorizontalPosition), NQOL.L("ui.headers.position_and_appearance_346f660")),
        GamepadOptions.BuildPositionSliderOption(GamepadOptions.GOLD_TRACKER_PANEL_ID, 5, gold.GetGoldVerticalPositionLabel(), gold.GetGoldVerticalPositionTooltip(), 0, 100, "%.0f", gold.GetGoldVerticalPosition, gold.SetGoldVerticalPosition),
        GamepadOptions.BuildFiniteListOption(GamepadOptions.GOLD_TRACKER_PANEL_ID, 6, gold.GetGoldFontLabel(), gold.GetGoldFontTooltip(), gold.GetGoldFontChoices(), gold.GetGoldFontChoiceNames(), gold.GetGoldFont, gold.SetGoldFont),
        GamepadOptions.BuildValueStepSliderOption(GamepadOptions.GOLD_TRACKER_PANEL_ID, 7, gold.GetGoldFontSizeLabel(), gold.GetGoldFontSizeTooltip(), gold.GetGoldFontSizeMin(), gold.GetGoldFontSizeMax(), "%.0f", gold.GetGoldFontSize, gold.SetGoldFontSize, 1),
        GamepadOptions.BuildSliderOption(GamepadOptions.GOLD_TRACKER_PANEL_ID, 8, gold.GetGoldBackgroundOpacityLabel(), gold.GetGoldBackgroundOpacityTooltip(), gold.GetGoldBackgroundOpacityMin(), gold.GetGoldBackgroundOpacityMax(), "%.0f", gold.GetGoldBackgroundOpacity, gold.SetGoldBackgroundOpacity, 1),
        GamepadOptions.BuildFiniteListOption(GamepadOptions.GOLD_TRACKER_PANEL_ID, 9, gold.GetGoldSourceLabel(), gold.GetGoldSourceTooltip(), gold.GetGoldSourceChoices(), gold.GetGoldSourceChoiceNames(), gold.GetGoldSource, gold.SetGoldSource),
        GamepadOptions.WithHeader(GamepadOptions.BuildCheckboxOption(GamepadOptions.GOLD_TRACKER_PANEL_ID, 11, gold.GetGoldAmountVisibleLabel(), gold.GetGoldAmountVisibleTooltip(), gold.GetGoldAmountVisible, gold.SetGoldAmountVisible), NQOL.L("ui.headers.visibility_7d9ff4f")),
        GamepadOptions.BuildCheckboxOption(GamepadOptions.GOLD_TRACKER_PANEL_ID, 12, gold.GetGoldTrackersVisibleLabel(), gold.GetGoldTrackersVisibleTooltip(), gold.GetGoldTrackersVisible, gold.SetGoldTrackersVisible),
        GamepadOptions.BuildCheckboxOption(GamepadOptions.GOLD_TRACKER_PANEL_ID, 13, gold.GetGoldChartVisibleLabel(), gold.GetGoldChartVisibleTooltip(), gold.GetGoldChartVisible, gold.SetGoldChartVisible),
        {
            panel = GamepadOptions.GOLD_TRACKER_PANEL_ID,
            system = GamepadOptions.GOLD_TRACKER_PANEL_ID,
            settingId = 14,
            controlType = OPTIONS_INVOKE_CALLBACK,
            text = gold.GetGoldTimersLabel(),
            gamepadTextOverride = gold.GetGoldTimersLabel(),
            onInitializeFunction = function(control)
                GamepadOptions.InitializeNavigationEntry(control)
            end,
            gamepadCustomTooltipFunction = function(tooltipControl)
                GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, gold.GetGoldTimersTooltip())
            end,
            callback = function()
                GamepadOptions.ShowPanel(GamepadOptions.GOLD_TIMERS_PANEL_ID)
            end,
        },
        {
            panel = GamepadOptions.GOLD_TRACKER_PANEL_ID,
            system = GamepadOptions.GOLD_TRACKER_PANEL_ID,
            settingId = 16,
            controlType = OPTIONS_INVOKE_CALLBACK,
            header = GamepadOptions.MakeHeader(NQOL.L("ui.headers.actions_c3cd636")),
            text = gold.GetGoldResetTimersLabel(),
            gamepadTextOverride = gold.GetGoldResetTimersLabel(),
            onInitializeFunction = GamepadOptions.InitializeDecorativeEntry,
            gamepadCustomTooltipFunction = function(tooltipControl)
                GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, gold.GetGoldResetTimersTooltip())
            end,
            callback = function()
                GamepadOptions.ShowResetTimersDialog(
                    GamepadOptions.GOLD_RESET_TIMERS_DIALOG_NAME,
                    gold.GetGoldResetTimersLabel(),
                    NQOL.L("dialogs.reset_gold_session"),
                    gold.ResetGoldTimers
                )
            end,
        },
    }
end

function GamepadOptions.BuildGoldTimersOptionsData()
    local options = {}
    local gold = NQOL.Features.ProgressGold
    for index, timer in ipairs(gold.GetGoldTimers()) do
        local timerKey = timer.key
        local timerLabel = timer.label
        options[#options + 1] = GamepadOptions.BuildCheckboxOption(GamepadOptions.GOLD_TIMERS_PANEL_ID, index, timerLabel, gold.GetGoldTimerTooltip(timerLabel), function()
            return gold.GetGoldTimerEnabled(timerKey)
        end, function(value)
            gold.SetGoldTimerEnabled(timerKey, value)
        end)
    end

    return options
end

function GamepadOptions.BuildBuffsDebuffsOptionsData()
    return {
        GamepadOptions.BuildBuffsDebuffsEnabledOption(),
        GamepadOptions.BuildBuffsDebuffsShowInSettingsOption(),
        GamepadOptions.WithHeader(GamepadOptions.BuildBuffsDebuffsMajorMonitorOption(), NQOL.L("ui.headers.tracking_and_appearance_d440d31")),
        GamepadOptions.BuildBuffsDebuffsMinorMonitorOption(),
        GamepadOptions.BuildBuffsDebuffsStackOption(),
        GamepadOptions.BuildBuffsDebuffsHorizontalPositionOption(),
        GamepadOptions.BuildBuffsDebuffsVerticalPositionOption(),
        GamepadOptions.BuildBuffsDebuffsUseGameIconsOption(),
        GamepadOptions.BuildBuffsDebuffsFontOption(),
        GamepadOptions.BuildBuffsDebuffsFontSizeOption(),
        GamepadOptions.BuildBuffsDebuffsBackgroundOpacityOption(),
        GamepadOptions.BuildBuffsDebuffsTrackersEntry(),
    }
end

function GamepadOptions.BuildBuffsDebuffsTrackersOptionsData()
    local effectNames = {}
    for _, baseName in ipairs(NQOL.Features.BuffsDebuffs.GetEffectNames()) do
        effectNames[#effectNames + 1] = baseName
    end
    table.sort(effectNames)

    local options = {
        GamepadOptions.BuildBuffsDebuffsTrackerModeOption(),
    }

    local buffsHeaderAdded = false
    for _, baseName in ipairs(effectNames) do
        local option = GamepadOptions.BuildBuffsDebuffsSelectedBuffOption(baseName)
        if not buffsHeaderAdded then
            option.header = GamepadOptions.MakeHeader(NQOL.L("ui.headers.buffs_dbe23ae"))
            buffsHeaderAdded = true
        end
        options[#options + 1] = option
    end

    local debuffsHeaderAdded = false
    for _, baseName in ipairs(effectNames) do
        local option = GamepadOptions.BuildBuffsDebuffsSelectedDebuffOption(baseName)
        if not debuffsHeaderAdded then
            option.header = GamepadOptions.MakeHeader(NQOL.L("ui.headers.debuffs_f3cf6ed"))
            debuffsHeaderAdded = true
        end
        options[#options + 1] = option
    end

    for index, option in ipairs(options) do
        option.settingId = index
    end

    return options
end

function GamepadOptions.BuildUtilityOptionsData()
    return {
        GamepadOptions.BuildAutoClaimTomePointsOption(),
        GamepadOptions.BuildAutoClaimGoldenPursuitsOption(),
        GamepadOptions.BuildTransmuteWatchOption(),
        GamepadOptions.BuildSkipLogoutConfirmationOption(),
        GamepadOptions.BuildLuaGcEntry(),
    }
end

function GamepadOptions.BuildLuaGcOptionsData()
    local luaGc = NQOL.Features.LuaGc

    return {
        GamepadOptions.BuildLuaGcOption(),
        GamepadOptions.BuildLuaGcDebugOutputOption(),
        {
            panel = LUA_GC_PANEL_ID,
            system = LUA_GC_PANEL_ID,
            settingId = 3,
            controlType = OPTIONS_INVOKE_CALLBACK,
            text = luaGc.GetRunFullCleanupLabel(),
            gamepadTextOverride = luaGc.GetRunFullCleanupLabel(),
            tooltipText = luaGc.GetRunFullCleanupTooltip(),
            onInitializeFunction = GamepadOptions.InitializeDecorativeEntry,
            gamepadCustomTooltipFunction = function(tooltipControl)
                GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, luaGc.GetRunFullCleanupTooltip())
            end,
            callback = function()
                luaGc.RunFullCleanup()
            end,
        },
    }
end
