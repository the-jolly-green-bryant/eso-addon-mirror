local defaultData = {
    version = 10,
    campaignBrowserOverview = true,
    resurrectionAutoDecline = true,
    resurrectionAutoDeclineTimeout = 10,
    resurrectionNotifications = true,
    keepClaimFilterAlliance = true,
    keepClaimUpdateTimerFix = true,
    quickslotFix = true,
    quickSlotConsolidateItems = true,
    mapObjectivesTab = true,
    keepStatusNotifications = true,
    killNotifications = true,
    npcKillNotifications = true,
    showObjectiveLevel = true,
    stealthIndicator = true,
    stealthIndicatorAlpha = 50,
    stealthIndicatorHiddenColor = {ZO_ColorDef:New("33AA33"):UnpackRGBA()},
    stealthIndicatorStealthedColor = {ZO_ColorDef:New("33AADD"):UnpackRGBA()},
    abilityLinkMenuEntries = true,
    showCyrodiilMapInGates = true,
    enhanceChampionBarTooltip = true,
-- some modules add their own default settings later (attribute bars)
}

sidWarTools.DEFAULT_SETTINGS = defaultData

local function CreateSettingsDialog(saveData)
    local L = sidWarTools.Localization
    local LAM = LibStub("LibAddonMenu-2.0")
    local REQUIRES_RELOAD = true

    local panelData = {
        type = "panel",
        name = "sidWarTools",
        author = "sirinsidiator",
        slashCommand = "/sidwartools",
        website = "https://www.esoui.com/downloads/info1117-sidWarTools.html",
        feedback = "https://www.esoui.com/portal.php?id=218&a=bugreport",
        donation = "https://www.esoui.com/downloads/info1117-sidWarTools.html#donate",
        version = "0.8",
        registerForRefresh = true,
        registerForDefaults = true
    }
    local panel = LAM:RegisterAddonPanel("sidWarToolsOptions", panelData)

    local optionsData = {}
    local function AddTitle(title)
        optionsData[#optionsData + 1] = {
            type = "header",
            name = title,
        }
    end

    local function AddCheckbox(saveData, defaultData, propertyName, label, tooltip, requiresReload, disabled, callback)
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            name = label,
            tooltip = tooltip,
            getFunc = function() return saveData[propertyName] end,
            setFunc = function(value)
                saveData[propertyName] = value
                if(callback) then callback(saveData, value) end
            end,
            requiresReload = requiresReload,
            disabled = disabled,
            default = defaultData[propertyName]
        }
    end

    local function AddDropdown(saveData, defaultData, propertyName, label, tooltip, choices, choicesValues, choicesTooltips, requiresReload, disabled, isHalf, callback)
        optionsData[#optionsData + 1] = {
            type = "dropdown",
            name = label,
            tooltip = tooltip,
            width = isHalf and "half" or nil,
            choices = choices,
            choicesValues = choicesValues,
            choicesTooltips = choicesTooltips,
            getFunc = function() return saveData[propertyName] end,
            setFunc = function(value)
                saveData[propertyName] = value
                if(callback) then callback(saveData, value) end
            end,
            requiresReload = requiresReload,
            disabled = disabled,
            default = defaultData[propertyName]
        }
    end

    local function AddSlider(saveData, defaultData, propertyName, min, max, label, tooltip, requiresReload, disabled, isHalf, callback)
        optionsData[#optionsData + 1] = {
            type = "slider",
            name = label,
            tooltip = tooltip,
            width = isHalf and "half" or nil,
            min = min,
            max = max,
            getFunc = function() return saveData[propertyName] end,
            setFunc = function(value)
                saveData[propertyName] = value
                if(callback) then callback(saveData, value) end
            end,
            requiresReload = requiresReload,
            disabled = disabled,
            default = defaultData[propertyName]
        }
    end

    local function AddColorPicker(saveData, defaultData, propertyName, label, tooltip, requiresReload, disabled, isHalf, callback)
        optionsData[#optionsData + 1] = {
            type = "colorpicker",
            name = label,
            tooltip = tooltip,
            width = isHalf and "half" or nil,
            getFunc = function() return unpack(saveData[propertyName]) end,
            setFunc = function(r, g, b, a)
                saveData[propertyName] = {r, g, b, a}
                if(callback) then callback(saveData, r, g, b, a) end
            end,
            requiresReload = requiresReload,
            disabled = disabled,
            default = ZO_ColorDef:New(unpack(defaultData[propertyName]))
        }
    end

    AddTitle(L["SETTINGS_CAMPAIGN_BROWSER_TITLE"])
    AddCheckbox(saveData, defaultData, "campaignBrowserOverview", L["SETTINGS_CAMPAIGN_BROWSER_OVERVIEW_LABEL"], L["SETTINGS_CAMPAIGN_BROWSER_OVERVIEW_DESCRIPTION"], REQUIRES_RELOAD)

    AddTitle(L["SETTINGS_RESURRECTION_TITLE"])
    AddCheckbox(saveData, defaultData, "resurrectionAutoDecline", L["SETTINGS_RESURRECTION_AUTO_DECLINE_LABEL"], L["SETTINGS_RESURRECTION_AUTO_DECLINE_DESCRIPTION"], REQUIRES_RELOAD)
    local function ResurrectionAutoDeclineDisabled() return not saveData.resurrectionAutoDecline end
    AddSlider(saveData, defaultData, "resurrectionAutoDeclineTimeout", 0, 59, L["SETTINGS_RESURRECTION_AUTO_DECLINE_TIMEOUT_LABEL"], L["SETTINGS_RESURRECTION_AUTO_DECLINE_TIMEOUT_DESCRIPTION"], nil, ResurrectionAutoDeclineDisabled)
    AddCheckbox(saveData, defaultData, "resurrectionNotifications", L["SETTINGS_RESURRECTION_NOTIFICATIONS_LABEL"], L["SETTINGS_RESURRECTION_NOTIFICATIONS_DESCRIPTION"], REQUIRES_RELOAD)

    AddTitle(L["SETTINGS_ATTRIBUTE_BARS_TITLE"])
    AddCheckbox(saveData.attributeBars, defaultData.attributeBars, "mutationColors", L["SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_LABEL"], L["SETTINGS_ATTRIBUTE_MUTATION_COLORS_DESCRIPTION"], REQUIRES_RELOAD)
    local function MutationColorsDisabled() return not saveData.mutationColors end
    AddColorPicker(saveData.attributeBars, defaultData.attributeBars, "werewolfGradientStart", L["SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_WEREWOLF_START_LABEL"], L["SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_WEREWOLF_START_DESCRIPTION"], nil, MutationColorsDisabled, true, sidWarTools.RefreshMutationColors)
    AddColorPicker(saveData.attributeBars, defaultData.attributeBars, "werewolfGradientEnd", L["SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_WEREWOLF_END_LABEL"], L["SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_WEREWOLF_END_DESCRIPTION"], nil, MutationColorsDisabled, true, sidWarTools.RefreshMutationColors)
    AddColorPicker(saveData.attributeBars, defaultData.attributeBars, "vampireGradientStart", L["SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_VAMPIRE_START_LABEL"], L["SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_VAMPIRE_START_DESCRIPTION"], nil, MutationColorsDisabled, true, sidWarTools.RefreshMutationColors)
    AddColorPicker(saveData.attributeBars, defaultData.attributeBars, "vampireGradientEnd", L["SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_VAMPIRE_END_LABEL"], L["SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_VAMPIRE_END_DESCRIPTION"], nil, MutationColorsDisabled, true, sidWarTools.RefreshMutationColors)
    AddCheckbox(saveData.attributeBars, defaultData.attributeBars, "classIcons", L["SETTINGS_TARGET_FRAME_CLASS_ICON_LABEL"], L["SETTINGS_TARGET_FRAME_CLASS_ICON_DESCRIPTION"], REQUIRES_RELOAD)
    AddCheckbox(saveData.attributeBars, defaultData.attributeBars, "classLeaderBoardRank", L["SETTINGS_TARGET_FRAME_CLASS_LEADERBOARD_RANK_LABEL"], L["SETTINGS_TARGET_FRAME_CLASS_LEADERBOARD_RANK_DESCRIPTION"], REQUIRES_RELOAD, function() return not saveData.attributeBars.classIcons end)
    AddCheckbox(saveData.attributeBars, defaultData.attributeBars, "allianceLeaderBoardRank", L["SETTINGS_TARGET_FRAME_ALLIANCE_LEADERBOARD_RANK_LABEL"], L["SETTINGS_TARGET_FRAME_ALLIANCE_LEADERBOARD_DESCRIPTION"], REQUIRES_RELOAD)

    local ATTRIBUTE_BAR_TEXT_MODE_LABELS = {
        L["SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_PERCENTAGE_LABEL"],
        L["SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_ABSOLUTE_LABEL"],
        L["SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_BOTH_LABEL"],
    }
    local ATTRIBUTE_BAR_TEXT_MODE_VALUES = {1, 2, 3}
    local ATTRIBUTE_BAR_TEXT_MODE_TOOLTIPS = {
        L["SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_PERCENTAGE_TOOLTIP"],
        L["SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_ABSOLUTE_TOOLTIP"],
        L["SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_BOTH_TOOLTIP"],
    }

    local ATTRIBUTE_BAR_TEXT_FORMAT_LABELS = {
        L["SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_RAW_LABEL"],
        L["SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_COMMA_LABEL"],
        L["SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_SHORT_LABEL"],
    }
    local ATTRIBUTE_BAR_TEXT_FORMAT_VALUES = {0, 1, 2}
    local ATTRIBUTE_BAR_TEXT_FORMAT_TOOLTIPS = {
        L["SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_RAW_TOOLTIP"],
        L["SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_COMMA_TOOLTIP"],
        L["SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_SHORT_TOOLTIP"],
    }

    AddTitle(L["SETTINGS_ATTRIBUTE_BAR_MODIFICATIONS_TITLE"])
    AddCheckbox(saveData.attributeBars, defaultData.attributeBars, "enabled", L["SETTINGS_ATTRIBUTE_BAR_MODIFICATIONS_LABEL"], L["SETTINGS_ATTRIBUTE_BAR_MODIFICATIONS_DESCRIPTION"], REQUIRES_RELOAD)
    local function AttributeBarNumbersDisabled()
        return not saveData.attributeBars.enabled
    end
    local function AddSettingsForAttributeBar(attributeBarName, attributeBar)
        local RefreshAttributeBar
        if(attributeBar) then
            RefreshAttributeBar = function()
                -- trick the function into updating even when the actual values didn't change
                attributeBar:UpdateStatusBar(attributeBar.current, attributeBar.max, attributeBar.effectiveMax + 0.0001)
            end
        end
        AddCheckbox(saveData.attributeBars[attributeBarName], defaultData.attributeBars[attributeBarName], "textEnabled", zo_strformat(L["SETTINGS_ATTRIBUTE_BAR_TEXT_ENABLED_TITLE"], L[attributeBarName]), zo_strformat(L["SETTINGS_ATTRIBUTE_BAR_TEXT_ENABLED_DESCRIPTION"], L[attributeBarName]), nil, AttributeBarNumbersDisabled, RefreshAttributeBar)
        local function AttributeBarModeDisabled() return AttributeBarNumbersDisabled() or not saveData.attributeBars[attributeBarName].textEnabled end
        AddDropdown(saveData.attributeBars[attributeBarName], defaultData.attributeBars[attributeBarName], "generalTextMode", zo_strformat(L["SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_TITLE"], L[attributeBarName]), zo_strformat(L["SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_DESCRIPTION"], L[attributeBarName]), ATTRIBUTE_BAR_TEXT_MODE_LABELS, ATTRIBUTE_BAR_TEXT_MODE_VALUES, ATTRIBUTE_BAR_TEXT_MODE_TOOLTIPS, nil, AttributeBarModeDisabled, true, RefreshAttributeBar)
        local function AttributeBarFormatDisabled() return AttributeBarNumbersDisabled() or not saveData.attributeBars[attributeBarName].textEnabled or not saveData.attributeBars[attributeBarName].generalTextMode or saveData.attributeBars[attributeBarName].generalTextMode < 2 end
        AddDropdown(saveData.attributeBars[attributeBarName], defaultData.attributeBars[attributeBarName], "generalTextFormat", zo_strformat(L["SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_TITLE"], L[attributeBarName]), zo_strformat(L["SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_DESCRIPTION"], L[attributeBarName]), ATTRIBUTE_BAR_TEXT_FORMAT_LABELS, ATTRIBUTE_BAR_TEXT_FORMAT_VALUES, ATTRIBUTE_BAR_TEXT_FORMAT_TOOLTIPS, nil, AttributeBarFormatDisabled, true, RefreshAttributeBar)
    end
    AddSettingsForAttributeBar("targetHealthBar")
    AddSettingsForAttributeBar("playerHealthBar", PLAYER_ATTRIBUTE_BARS.bars[1])
    AddSettingsForAttributeBar("playerMagickaBar", PLAYER_ATTRIBUTE_BARS.bars[3])
    AddSettingsForAttributeBar("playerStaminaBar", PLAYER_ATTRIBUTE_BARS.bars[5])

    AddTitle(L["SETTINGS_STEALTH_INDICATOR_TITLE"])
    AddCheckbox(saveData, defaultData, "stealthIndicator", L["SETTINGS_STEALTH_INDICATOR_LABEL"], L["SETTINGS_STEALTH_INDICATOR_DESCRIPTION"], REQUIRES_RELOAD)
    local function StealthIndicatorDisabled() return not saveData.stealthIndicator end
    AddSlider(saveData, defaultData, "stealthIndicatorAlpha", 0, 100, L["SETTINGS_STEALTH_INDICATOR_ALPHA_LABEL"], L["SETTINGS_STEALTH_INDICATOR_ALPHA_DESCRIPTION"], nil, StealthIndicatorDisabled, false, sidWarTools.RefreshStealthIndicatorColors)
    AddColorPicker(saveData, defaultData, "stealthIndicatorHiddenColor", L["SETTINGS_STEALTH_INDICATOR_HIDDEN_COLOR_LABEL"], L["SETTINGS_STEALTH_INDICATOR_HIDDEN_COLOR_DESCRIPTION"], nil, StealthIndicatorDisabled, true, sidWarTools.RefreshStealthIndicatorColors)
    AddColorPicker(saveData, defaultData, "stealthIndicatorStealthedColor", L["SETTINGS_STEALTH_INDICATOR_STEALTHED_COLOR_LABEL"], L["SETTINGS_STEALTH_INDICATOR_STEALTHED_COLOR_DESCRIPTION"], nil, StealthIndicatorDisabled, true, sidWarTools.RefreshStealthIndicatorColors)

    AddTitle(L["SETTINGS_MISC_TITLE"])
    AddCheckbox(saveData, defaultData, "keepClaimFilterAlliance", L["SETTINGS_KEEP_CLAIM_DIALOG_FILTER_ALLIANCE_LABEL"], L["SETTINGS_KEEP_CLAIM_DIALOG_FILTER_ALLIANCE_DESCRIPTION"], REQUIRES_RELOAD)
    AddCheckbox(saveData, defaultData, "keepClaimUpdateTimerFix", L["SETTINGS_KEEP_CLAIM_UPDATE_TIMER_FIX_LABEL"], L["SETTINGS_KEEP_CLAIM_UPDATE_TIMER_FIX_DESCRIPTION"], REQUIRES_RELOAD)
    AddCheckbox(saveData, defaultData, "quickslotFix", L["SETTINGS_QUICKSLOT_FIX_LABEL"], L["SETTINGS_QUICKSLOT_FIX_DESCRIPTION"], REQUIRES_RELOAD)
    AddCheckbox(saveData, defaultData, "quickSlotConsolidateItems", L["SETTINGS_QUICKSLOT_CONSOLIDATE_ITEMS_LABEL"], L["SETTINGS_QUICKSLOT_CONSOLIDATE_ITEMS_DESCRIPTION"], REQUIRES_RELOAD, function()
        return not saveData.quickslotFix
    end)
    AddCheckbox(saveData, defaultData, "mapObjectivesTab", L["SETTINGS_MAP_OBJECTIVES_TAB_LABEL"], L["SETTINGS_MAP_OBJECTIVES_TAB_DESCRIPTION"], REQUIRES_RELOAD)
    AddCheckbox(saveData, defaultData, "showCyrodiilMapInGates", L["SETTINGS_SHOW_CYRODIIL_MAP_IN_GATES_LABEL"], L["SETTINGS_SHOW_CYRODIIL_MAP_IN_GATES_DESCRIPTION"])
    AddCheckbox(saveData, defaultData, "showObjectiveLevel", L["SETTINGS_MAP_OBJECTIVE_LEVEL_LABEL"], L["SETTINGS_MAP_OBJECTIVE_LEVEL_DESCRIPTION"], REQUIRES_RELOAD)
    AddCheckbox(saveData, defaultData, "keepStatusNotifications", L["SETTINGS_KEEP_STATUS_NOTIFICATIONS_LABEL"], L["SETTINGS_KEEP_STATUS_NOTIFICATIONS_DESCRIPTION"], REQUIRES_RELOAD)
    AddCheckbox(saveData, defaultData, "killNotifications", L["SETTINGS_KILL_NOTIFICATIONS_LABEL"], L["SETTINGS_KILL_NOTIFICATIONS_DESCRIPTION"], REQUIRES_RELOAD)
    local function KillNotificationsDisabled() return not saveData.killNotifications end
    AddCheckbox(saveData, defaultData, "npcKillNotifications", L["SETTINGS_NPC_KILL_NOTIFICATIONS_LABEL"], L["SETTINGS_NPC_KILL_NOTIFICATIONS_DESCRIPTION"], nil, KillNotificationsDisabled)
    AddCheckbox(saveData, defaultData, "abilityLinkMenuEntries", L["SETTINGS_ABILITY_LINK_MENU_ENTRIES_LABEL"], L["SETTINGS_ABILITY_LINK_MENU_ENTRIES_DESCRIPTION"], REQUIRES_RELOAD)
    AddCheckbox(saveData, defaultData, "enhanceChampionBarTooltip", L["SETTINGS_ENHANCE_CP_BAR_TOOLTIP_LABEL"], L["SETTINGS_ENHANCE_CP_BAR_TOOLTIP_DESCRIPTION"], REQUIRES_RELOAD)

    LAM:RegisterOptionControls("sidWarToolsOptions", optionsData)

    sidWarTools.OpenSettingsPanel = function()
        LAM:OpenToPanel(panel)
    end
end

local function LoadSettings()
    sidWarTools_Data = sidWarTools_Data or {}
    local saveData = sidWarTools_Data[GetDisplayName()] or ZO_DeepTableCopy(defaultData)
    sidWarTools_Data[GetDisplayName()] = saveData

    local function UpgradeSettings(saveData)
        if(saveData.version == 1) then
            saveData.resurrectionReceivedNotification = defaultData.resurrectionReceivedNotification
            saveData.resurrectionAcceptedNotification = defaultData.resurrectionAcceptedNotification
            saveData.resurrectionDeclinedNotification = defaultData.resurrectionDeclinedNotification
            saveData.version = 2
        end
        if(saveData.version == 2) then
            saveData.campaignBonusTooltipFix = defaultData.campaignBonusTooltipFix
            saveData.version = 3
        end
        if(saveData.version == 3) then
            saveData.attributeBars.mutationColors = defaultData.attributeBars.mutationColors
            saveData.attributeBars.werewolfGradientStart = defaultData.attributeBars.werewolfGradientStart
            saveData.attributeBars.werewolfGradientEnd = defaultData.attributeBars.werewolfGradientEnd
            saveData.attributeBars.vampireGradientStart = defaultData.attributeBars.vampireGradientStart
            saveData.attributeBars.vampireGradientEnd = defaultData.attributeBars.vampireGradientEnd
            saveData.attributeBars.classIcons = defaultData.attributeBars.classIcons
            saveData.resurrectionReceivedNotification = nil
            saveData.resurrectionAcceptedNotification = nil
            saveData.resurrectionDeclinedNotification = nil
            saveData.resurrectionNotifications = defaultData.resurrectionNotifications
            saveData.killNotifications = defaultData.killNotifications
            saveData.showObjectiveLevel = defaultData.showObjectiveLevel
            saveData.version = 4
        end
        if(saveData.version == 4) then
            saveData.attributeBars.classLeaderBoardRank = defaultData.attributeBars.classLeaderBoardRank
            saveData.attributeBars.allianceLeaderBoardRank = defaultData.attributeBars.allianceLeaderBoardRank
            saveData.stealthIndicator = defaultData.stealthIndicator
            saveData.stealthIndicatorAlpha = defaultData.stealthIndicatorAlpha
            saveData.stealthIndicatorHiddenColor = defaultData.stealthIndicatorHiddenColor
            saveData.stealthIndicatorStealthedColor = defaultData.stealthIndicatorStealthedColor
            saveData.version = 5
        end
        if(saveData.version == 5) then
            saveData.npcKillNotifications = defaultData.npcKillNotifications
            saveData.version = 6
        end
        if(saveData.version == 6) then
            saveData.abilityLinkMenuEntries = defaultData.abilityLinkMenuEntries
            saveData.showCyrodiilMapInGates = defaultData.showCyrodiilMapInGates
            saveData.version = 7
        end
        if(saveData.version == 7) then
            saveData.campaignBonusTooltipFix = nil
            saveData.version = 8
        end
        if(saveData.version == 8) then
            saveData.attributeBars.targetHealthBar.textEnabled = defaultData.attributeBars.targetHealthBar.textEnabled
            saveData.attributeBars.targetHealthBar.dividerTextFormat = defaultData.attributeBars.targetHealthBar.dividerTextFormat
            saveData.attributeBars.targetHealthBar.generalTextFormat = defaultData.attributeBars.targetHealthBar.generalTextFormat
            saveData.attributeBars.playerHealthBar.textEnabled = defaultData.attributeBars.playerHealthBar.textEnabled
            saveData.attributeBars.playerHealthBar.dividerTextFormat = defaultData.attributeBars.playerHealthBar.dividerTextFormat
            saveData.attributeBars.playerHealthBar.generalTextFormat = defaultData.attributeBars.playerHealthBar.generalTextFormat
            saveData.attributeBars.playerMagickaBar.textEnabled = defaultData.attributeBars.playerMagickaBar.textEnabled
            saveData.attributeBars.playerMagickaBar.dividerTextFormat = defaultData.attributeBars.playerMagickaBar.dividerTextFormat
            saveData.attributeBars.playerMagickaBar.generalTextFormat = defaultData.attributeBars.playerMagickaBar.generalTextFormat
            saveData.attributeBars.playerStaminaBar.textEnabled = defaultData.attributeBars.playerStaminaBar.textEnabled
            saveData.attributeBars.playerStaminaBar.dividerTextFormat = defaultData.attributeBars.playerStaminaBar.dividerTextFormat
            saveData.attributeBars.playerStaminaBar.generalTextFormat = defaultData.attributeBars.playerStaminaBar.generalTextFormat
            saveData.enhanceChampionBarTooltip = defaultData.enhanceChampionBarTooltip
            saveData.version = 9
        end
        if(saveData.version == 9) then
            saveData.shieldFix = nil
            saveData.campaignQueueAutoJoin = nil
            saveData.campaignQueueAutoJoinTimeout = nil
            saveData.campaignQueueSuppressConfirmDialog = nil
            saveData.version = 10
        end
    end

    UpgradeSettings(saveData)
    CreateSettingsDialog(saveData)

    return saveData
end

sidWarTools.LoadSettings = LoadSettings
