NCollections = NCollections or {}

local GamepadOptions = {}
NCollections.GamepadOptions = GamepadOptions

GamepadOptions.PanelIds = {
    ROOT = 19100,
    GEAR = 19101,
    FOOD_RECIPES = 19102,
    DRINK_RECIPES = 19103,
    PLANS = 19104,
    HOUSING = 19105,
    MOUNTS = 19106,
    SKINS = 19107,
    PETS = 19108,
    MEMENTOS = 19109,
    COMPANIONS = 19110,
    ITEM_CATEGORIES = 19111,
    APPEARANCE = 19112,
    ASSISTANTS = 19113,
    SKILL_STYLES = 19114,
    OUTFIT_STYLES = 19115,
    ANTIQUITIES = 19116,
    DYES = 19117,
    SCRIBING = 19118,
    COLLECTIBLE_FURNISHINGS = 19119,
    EMOTES_AND_ACTIONS = 19120,
    GEAR_CRAFTED = 19121,
}

local PanelIds = GamepadOptions.PanelIds
local ROOT_PANEL_ID = PanelIds.ROOT
local CATEGORY_NAME_KEY = "ui.addons_menu.ncollections_name"
local CATEGORY_ICON = "/esoui/art/options/gamepad/gp_options_addons.dds"
local SHARED_ADDONS_MENU_ENTRY_ID = "LibHarvensAddonSettings"
local FALLBACK_ADDONS_MENU_ENTRY_ID = "NCollections_AddonsRoot"
local MAIN_MENU_ENTRY_ID = "NCollections_Addons"
local DEFERRED_SLIDER_APPLY_MS = 150
local Clamp = NCollections.Util.Clamp
local panelResetInProgress = {}
local panelsRegistered = false
local sharedAddonsMenuHookInstalled = false
local mainMenuWatcherInstalled = false
local backOverrideInstalled = false
local headerVersionHooked = false

local SUBPANEL_PARENT_IDS = {
    [PanelIds.GEAR] = ROOT_PANEL_ID,
    [PanelIds.GEAR_CRAFTED] = ROOT_PANEL_ID,
    [PanelIds.FOOD_RECIPES] = ROOT_PANEL_ID,
    [PanelIds.DRINK_RECIPES] = ROOT_PANEL_ID,
    [PanelIds.PLANS] = ROOT_PANEL_ID,
    [PanelIds.HOUSING] = ROOT_PANEL_ID,
    [PanelIds.MOUNTS] = ROOT_PANEL_ID,
    [PanelIds.SKINS] = ROOT_PANEL_ID,
    [PanelIds.PETS] = ROOT_PANEL_ID,
    [PanelIds.MEMENTOS] = ROOT_PANEL_ID,
    [PanelIds.COMPANIONS] = ROOT_PANEL_ID,
    [PanelIds.ITEM_CATEGORIES] = ROOT_PANEL_ID,
    [PanelIds.APPEARANCE] = ROOT_PANEL_ID,
    [PanelIds.ASSISTANTS] = ROOT_PANEL_ID,
    [PanelIds.SKILL_STYLES] = ROOT_PANEL_ID,
    [PanelIds.OUTFIT_STYLES] = ROOT_PANEL_ID,
    [PanelIds.ANTIQUITIES] = ROOT_PANEL_ID,
    [PanelIds.DYES] = ROOT_PANEL_ID,
    [PanelIds.SCRIBING] = ROOT_PANEL_ID,
    [PanelIds.COLLECTIBLE_FURNISHINGS] = ROOT_PANEL_ID,
    [PanelIds.EMOTES_AND_ACTIONS] = ROOT_PANEL_ID,
}

local PANEL_RESET_PATHS = {
    [ROOT_PANEL_ID] = {},
    [PanelIds.GEAR] = { { "collections", "gearSet" } },
    [PanelIds.GEAR_CRAFTED] = { { "collections", "gearCrafted" } },
    [PanelIds.FOOD_RECIPES] = { { "collections", "recipes" } },
    [PanelIds.DRINK_RECIPES] = { { "collections", "recipes" } },
    [PanelIds.PLANS] = { { "collections", "recipes" } },
    [PanelIds.HOUSING] = { { "collections", "housing" } },
    [PanelIds.MOUNTS] = { { "collections", "mounts" } },
    [PanelIds.SKINS] = { { "collections", "skins" } },
    [PanelIds.PETS] = { { "collections", "pets" } },
    [PanelIds.MEMENTOS] = { { "collections", "mementos" } },
    [PanelIds.COMPANIONS] = { { "collections", "companions" } },
    [PanelIds.ITEM_CATEGORIES] = {},
    [PanelIds.APPEARANCE] = { { "collections", "appearance" } },
    [PanelIds.ASSISTANTS] = { { "collections", "assistants" } },
    [PanelIds.SKILL_STYLES] = { { "collections", "skillStyles" } },
    [PanelIds.OUTFIT_STYLES] = { { "collections", "outfitStyles" } },
    [PanelIds.ANTIQUITIES] = { { "collections", "antiquities" } },
    [PanelIds.DYES] = { { "collections", "dyes" } },
    [PanelIds.SCRIBING] = { { "collections", "scribing" } },
    [PanelIds.COLLECTIBLE_FURNISHINGS] = { { "collections", "collectibleFurnishings" } },
    [PanelIds.EMOTES_AND_ACTIONS] = { { "collections", "emotesAndActions" } },
}

local EXTENDED_PANEL_FEATURES = {
    [PanelIds.APPEARANCE] = "CollectionsAppearance",
    [PanelIds.ASSISTANTS] = "CollectionsAssistants",
    [PanelIds.SKILL_STYLES] = "CollectionsSkillStyles",
    [PanelIds.OUTFIT_STYLES] = "CollectionsOutfitStyles",
    [PanelIds.ANTIQUITIES] = "CollectionsAntiquities",
    [PanelIds.DYES] = "CollectionsDyes",
    [PanelIds.SCRIBING] = "CollectionsScribing",
    [PanelIds.COLLECTIBLE_FURNISHINGS] = "CollectionsCollectibleFurnishings",
    [PanelIds.EMOTES_AND_ACTIONS] = "CollectionsEmotesAndActions",
}

local function ResolveNumericOptionValue(value)
    if type(value) == "function" then
        value = value()
    end
    return tonumber(value)
end

local function ResolveTextEntry(textEntry, control)
    if type(textEntry) == "function" then
        return textEntry(control)
    elseif type(textEntry) == "number" and GetString then
        return GetString(textEntry)
    end
    return textEntry
end

local function GetNumericValueFormat(valueFormat)
    if type(valueFormat) ~= "string" then
        return "%d"
    end
    return string.match(valueFormat, "(%%[%d%.]*[df])") or "%d"
end

local function FormatSliderLabelValue(value, valueFormat)
    return string.format(GetNumericValueFormat(valueFormat), tonumber(value) or 0)
end

local function BuildSliderLabel(label, valueFormat, getFunc)
    return function(control)
        local labelText = ResolveTextEntry(label, control) or ""
        local value = control and control.data and control.data.ncollectionsLabelValueOverride
        if value == nil then
            value = getFunc()
        end
        return labelText .. " (" .. FormatSliderLabelValue(value, valueFormat) .. ")"
    end
end

local function GetSliderStepPercent(minValue, maxValue, stepSize)
    minValue = ResolveNumericOptionValue(minValue) or 0
    maxValue = ResolveNumericOptionValue(maxValue) or minValue
    local range = maxValue - minValue
    stepSize = tonumber(stepSize)
    if not stepSize or stepSize <= 0 or range <= 0 then
        return nil
    end
    return (stepSize / range) * 100
end

local function SetFeaturePreview(panelId)
    local features = NCollections.Features or {}
    if NCollections.ItemLocator and NCollections.ItemLocator.SetSettingsPanelVisible then
        NCollections.ItemLocator.SetSettingsPanelVisible(false)
    end
    if features.CollectionsGear then
        features.CollectionsGear.SetSettingsPanelVisible(panelId == PanelIds.GEAR)
    end
    if features.CollectionsGearCrafted then
        features.CollectionsGearCrafted.SetSettingsPanelVisible(panelId == PanelIds.GEAR_CRAFTED)
    end
    if features.CollectionsRecipes then
        if panelId == PanelIds.FOOD_RECIPES then
            features.CollectionsRecipes.SetSettingsPanelVisible("food")
        elseif panelId == PanelIds.DRINK_RECIPES then
            features.CollectionsRecipes.SetSettingsPanelVisible("drink")
        elseif panelId == PanelIds.PLANS then
            features.CollectionsRecipes.SetSettingsPanelVisible("plans")
        else
            features.CollectionsRecipes.SetSettingsPanelVisible(nil)
        end
    end
    if features.CollectionsHousing then
        features.CollectionsHousing.SetSettingsPanelVisible(panelId == PanelIds.HOUSING)
    end
    if features.CollectionsMounts then
        features.CollectionsMounts.SetSettingsPanelVisible(panelId == PanelIds.MOUNTS)
    end
    if features.CollectionsSkins then
        features.CollectionsSkins.SetSettingsPanelVisible(panelId == PanelIds.SKINS)
    end
    if features.CollectionsPets then
        features.CollectionsPets.SetSettingsPanelVisible(panelId == PanelIds.PETS)
    end
    if features.CollectionsMementos then
        features.CollectionsMementos.SetSettingsPanelVisible(panelId == PanelIds.MEMENTOS)
    end
    if features.CollectionsCompanions then
        features.CollectionsCompanions.SetSettingsPanelVisible(panelId == PanelIds.COMPANIONS)
    end
    for extendedPanelId, featureName in pairs(EXTENDED_PANEL_FEATURES) do
        local feature = features[featureName]
        if feature then feature.SetSettingsPanelVisible(panelId == extendedPanelId) end
    end
end

local function OpenRootPanel()
    if not GAMEPAD_OPTIONS or not SCENE_MANAGER then return end
    GAMEPAD_OPTIONS.currentCategory = ROOT_PANEL_ID
    SetFeaturePreview(nil)
    SCENE_MANAGER:Push("gamepad_options_panel")
end

function GamepadOptions.ResetSettingToDefault(_, settingData)
    if settingData then
        GamepadOptions.ResetPanelOptionsToDefaults(settingData.panel)
    end
end

function GamepadOptions.ResetPanelOptionsToDefaults(panelId)
    if panelResetInProgress[panelId] then return end
    panelResetInProgress[panelId] = true

    for _, path in ipairs(PANEL_RESET_PATHS[panelId] or {}) do
        NCollections.Settings.ResetPath(path)
    end
    if panelId == PanelIds.ITEM_CATEGORIES and NCollections.ItemLocator then
        NCollections.ItemLocator.ResetCategoryVisibility()
    end
    GamepadOptions.ApplyPanelOptions(panelId)
    panelResetInProgress[panelId] = nil
end

function GamepadOptions.ResetAllPanelsToDefaults()
    NCollections.Settings.ResetAllOptions()
    if NCollections.ItemLocator then
        NCollections.ItemLocator.SetEnabled(false)
        NCollections.ItemLocator.ResetCategoryVisibility()
    end
    for _, panelId in pairs(PanelIds) do
        GamepadOptions.ApplyPanelOptions(panelId)
    end
    GamepadOptions.RefreshCurrentOptionsList()
end

function GamepadOptions.AttachPanelReset(optionsData, panelId)
    if not optionsData or #optionsData == 0 then return end
    if panelId == ROOT_PANEL_ID then
        optionsData[1].customResetToDefaultsFunction = GamepadOptions.ResetAllPanelsToDefaults
    elseif PANEL_RESET_PATHS[panelId] then
        optionsData[1].customResetToDefaultsFunction = function()
            GamepadOptions.ResetPanelOptionsToDefaults(panelId)
        end
    end
end

function GamepadOptions.ApplyPanelOptions(panelId)
    local panelSettings = GAMEPAD_SETTINGS_DATA and GAMEPAD_SETTINGS_DATA[panelId]
    if not panelSettings or not GAMEPAD_OPTIONS or not GAMEPAD_OPTIONS.GetSettingsData then return end
    for _, setting in ipairs(panelSettings) do
        local settingData = GAMEPAD_OPTIONS:GetSettingsData(setting.panel, setting.system, setting.settingId)
        if settingData and settingData.GetSettingOverride and settingData.SetSettingOverride then
            settingData.SetSettingOverride(nil, settingData.GetSettingOverride())
        end
    end
end

function GamepadOptions.IsSubpanel(panelId)
    return SUBPANEL_PARENT_IDS[panelId] ~= nil
end

function GamepadOptions.ReplaceSubpanelBackKeybind()
    GAMEPAD_OPTIONS:ReplaceBackKeybind(function()
        local childPanelId = GAMEPAD_OPTIONS.currentCategory
        GamepadOptions.ShowPanel(ROOT_PANEL_ID, GamepadOptions.parentSelectionByChildPanel[childPanelId])
    end)
end

function GamepadOptions.ShowPanel(panelId, selectedIndex)
    local currentPanelId = GAMEPAD_OPTIONS.currentCategory
    if SUBPANEL_PARENT_IDS[panelId] == currentPanelId then
        local optionsList = GAMEPAD_OPTIONS.optionsList
        if optionsList and optionsList.GetSelectedIndex then
            GamepadOptions.parentSelectionByChildPanel[panelId] = optionsList:GetSelectedIndex()
        end
    end

    if GAMEPAD_OPTIONS.optionsList and GAMEPAD_OPTIONS.DeactivateSelectedControl then
        GAMEPAD_OPTIONS:DeactivateSelectedControl()
    end
    GAMEPAD_OPTIONS.currentCategory = panelId
    GAMEPAD_OPTIONS:RefreshHeader()
    GAMEPAD_OPTIONS:RefreshOptionsList()

    local optionsList = GAMEPAD_OPTIONS.optionsList
    if optionsList and selectedIndex then
        if optionsList.SetSelectedIndexWithoutAnimation then
            optionsList:SetSelectedIndexWithoutAnimation(selectedIndex, true)
        elseif optionsList.SetSelectedIndex then
            optionsList:SetSelectedIndex(selectedIndex, true)
        end
    end

    SetFeaturePreview(panelId)
    if GamepadOptions.IsSubpanel(panelId) then
        GamepadOptions.ReplaceSubpanelBackKeybind()
    else
        GAMEPAD_OPTIONS:RevertBackKeybind()
    end
end

function GamepadOptions.ShowItemLocator()
    SetFeaturePreview(nil)
    if NCollections.ItemLocator and NCollections.ItemLocator.SetSettingsPanelVisible then
        NCollections.ItemLocator.SetSettingsPanelVisible(true)
    end
end

function GamepadOptions.AddChevron(control)
    if control.NCollectionsChevron then
        control.NCollectionsChevron:SetHidden(false)
        return
    end
    local chevron = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    chevron:SetDimensions(24, 24)
    chevron:SetTexture("EsoUI/Art/Buttons/Gamepad/gp_menu_rightArrow.dds")
    chevron:SetAnchor(RIGHT, control, RIGHT, -8, 0)
    control.NCollectionsChevron = chevron
end

function GamepadOptions.HideDivider(control)
    if control.NCollectionsDivider then
        control.NCollectionsDivider:SetHidden(true)
    end
end

function GamepadOptions.InitializeNavigationEntry(control)
    GamepadOptions.HideDivider(control)
    GamepadOptions.AddChevron(control)
end

function GamepadOptions.MakeHeader(text)
    return function() return text end
end

function GamepadOptions.WithHeader(option, text)
    option.header = GamepadOptions.MakeHeader(text)
    return option
end

function GamepadOptions.RefreshCurrentOptionsList()
    if GAMEPAD_OPTIONS and GAMEPAD_OPTIONS.RefreshOptionsList then
        GAMEPAD_OPTIONS:RefreshOptionsList()
    end
end

function GamepadOptions.IsOptionControl(control)
    local data = control and control.data
    return data and data.ncollectionsOption == true and data.SetSettingOverride ~= nil
end

function GamepadOptions.ApplySetting(control, value)
    if not GamepadOptions.IsOptionControl(control) then return false end
    local data = control.data
    data.SetSettingOverride(control, value)
    data.ncollectionsUpdatingControl = true
    ZO_Options_UpdateOption(control)
    data.ncollectionsUpdatingControl = nil
    GamepadOptions.SetOptionControlHandler(control)
    return true
end

function GamepadOptions.RefreshControlLabel(control)
    local data = control and control.data
    if not data or not data.ncollectionsRefreshLabelOnChange then return end
    local labelControl = control.label or control:GetNamedChild("Name") or control:GetNamedChild("Label")
    if not labelControl then return end
    local text = ResolveTextEntry(data.gamepadTextOverride or data.text, control)
    if type(text) == "string" then labelControl:SetText(text) end
end

function GamepadOptions.ApplySliderSetting(control, value)
    if not GamepadOptions.IsOptionControl(control) then return false end
    local data = control.data
    local valueFormat = data.valueFormat or "%d"
    local valueLabelControl = control:GetNamedChild("ValueLabel")
    if data.showValue and valueLabelControl and ZO_Options_GetFormattedSliderValues then
        valueLabelControl:SetText(ZO_Options_GetFormattedSliderValues(data, string.format(valueFormat, value)))
    end

    if data.deferredApply then
        data.ncollectionsDeferredSliderSerial = (data.ncollectionsDeferredSliderSerial or 0) + 1
        local serial = data.ncollectionsDeferredSliderSerial
        zo_callLater(function()
            if data.ncollectionsDeferredSliderSerial == serial then
                data.SetSettingOverride(control, value)
            end
        end, data.deferredApplyDelayMs or DEFERRED_SLIDER_APPLY_MS)
    else
        data.SetSettingOverride(control, value)
    end

    data.ncollectionsLabelValueOverride = value
    GamepadOptions.RefreshControlLabel(control)
    data.ncollectionsLabelValueOverride = nil
    return true
end

function GamepadOptions.OnScrollListSelectionChanged(selectedData, oldData, reselectingDuringRebuild)
    local parentControl = selectedData and selectedData.parentControl
    if parentControl and parentControl.data and parentControl.data.enabled == false then return end
    if oldData ~= nil and reselectingDuringRebuild ~= true and parentControl then
        GamepadOptions.ApplySetting(parentControl, selectedData.value)
    end
end

function GamepadOptions.SetOptionControlHandler(control)
    if not GamepadOptions.IsOptionControl(control) then return end
    local data = control.data
    if data.controlType == OPTIONS_FINITE_LIST and control.horizontalListObject then
        control.horizontalListObject:SetOnSelectedDataChangedCallback(GamepadOptions.OnScrollListSelectionChanged)
    elseif data.controlType == OPTIONS_CHECKBOX then
        local checkBoxControl = control:GetNamedChild("Checkbox")
        if checkBoxControl then
            ZO_CheckButton_SetToggleFunction(checkBoxControl, function(_, checked)
                GamepadOptions.ApplySetting(control, checked)
            end)
        end
    elseif data.controlType == OPTIONS_SLIDER then
        local sliderControl = control:GetNamedChild("Slider")
        if sliderControl then
            sliderControl:SetHandler("OnValueChanged", function(_, value)
                if not data.ncollectionsUpdatingControl then
                    GamepadOptions.ApplySliderSetting(control, value)
                end
            end)
        end
    end
end

function GamepadOptions.RunOptionInitialize(control, isKeyboardControl, initializeFunc)
    GamepadOptions.SetOptionControlHandler(control)
    if initializeFunc then initializeFunc(control, isKeyboardControl) end
    local data = control and control.data
    zo_callLater(function()
        if control and control.data == data then
            GamepadOptions.SetOptionControlHandler(control)
            GamepadOptions.RefreshControlLabel(control)
        end
    end, 0)
end

function GamepadOptions.BuildSliderOption(panelId, settingId, label, tooltip, minValue, maxValue, valueFormat, getFunc, setFunc, stepPercent, deferredApply, defaultValue)
    local sliderLabel = BuildSliderLabel(label, valueFormat, getFunc)
    return {
        panel = panelId,
        system = panelId,
        settingId = settingId,
        ncollectionsOption = true,
        controlType = OPTIONS_SLIDER,
        text = sliderLabel,
        gamepadTextOverride = sliderLabel,
        tooltipText = tooltip,
        minValue = minValue,
        maxValue = maxValue,
        valueFormat = valueFormat,
        showValue = true,
        showValueMin = minValue,
        showValueMax = maxValue,
        gamepadValueStepPercent = stepPercent,
        deferredApply = deferredApply == true,
        default = defaultValue,
        ncollectionsRefreshLabelOnChange = true,
        customResetToDefaultsFunction = GamepadOptions.ResetSettingToDefault,
        gamepadCustomTooltipFunction = function(tooltipControl)
            GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, tooltip)
        end,
        onInitializeFunction = GamepadOptions.RunOptionInitialize,
        GetSettingOverride = function() return getFunc() end,
        SetSettingOverride = function(_, value) setFunc(value) end,
    }
end

function GamepadOptions.BuildValueStepSliderOption(panelId, settingId, label, tooltip, minValue, maxValue, valueFormat, getFunc, setFunc, valueStep, deferredApply, defaultValue)
    return GamepadOptions.BuildSliderOption(panelId, settingId, label, tooltip, minValue, maxValue, valueFormat, getFunc, setFunc, GetSliderStepPercent(minValue, maxValue, valueStep), deferredApply, defaultValue)
end

function GamepadOptions.BuildPositionSliderOption(panelId, settingId, label, tooltip, minValue, maxValue, valueFormat, getFunc, setFunc, deferredApply, defaultValue)
    minValue = ResolveNumericOptionValue(minValue) or 0
    maxValue = ResolveNumericOptionValue(maxValue) or minValue
    if valueFormat == "%.0f" then valueFormat = "%.2f" end
    return GamepadOptions.BuildSliderOption(panelId, settingId, label, tooltip, minValue, maxValue, valueFormat, getFunc, setFunc, GetSliderStepPercent(minValue, maxValue, 1), deferredApply, defaultValue)
end

function GamepadOptions.BuildCheckboxOption(panelId, settingId, label, tooltip, getFunc, setFunc, enabledFunc, defaultValue)
    return {
        panel = panelId,
        system = panelId,
        settingId = settingId,
        ncollectionsOption = true,
        controlType = OPTIONS_CHECKBOX,
        text = label,
        gamepadTextOverride = label,
        tooltipText = tooltip,
        enabled = enabledFunc,
        default = defaultValue,
        customResetToDefaultsFunction = GamepadOptions.ResetSettingToDefault,
        gamepadCustomTooltipFunction = function(tooltipControl)
            GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, tooltip)
        end,
        onInitializeFunction = GamepadOptions.RunOptionInitialize,
        GetSettingOverride = function() return getFunc() end,
        SetSettingOverride = function(_, value) setFunc(value) end,
    }
end

function GamepadOptions.BuildFiniteListOption(panelId, settingId, label, tooltip, choices, choiceNames, getFunc, setFunc, defaultValue)
    return {
        panel = panelId,
        system = panelId,
        settingId = settingId,
        ncollectionsOption = true,
        controlType = OPTIONS_FINITE_LIST,
        text = label,
        gamepadTextOverride = label,
        tooltipText = tooltip,
        valid = choices,
        itemText = choiceNames,
        default = defaultValue,
        customResetToDefaultsFunction = GamepadOptions.ResetSettingToDefault,
        gamepadCustomTooltipFunction = function(tooltipControl)
            GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, tooltip)
        end,
        onInitializeFunction = GamepadOptions.RunOptionInitialize,
        GetSettingOverride = function() return getFunc() end,
        SetSettingOverride = function(_, value) setFunc(value) end,
    }
end

function GamepadOptions.RegisterSharedOptions(panelId, optionsData)
    if not ZO_SharedOptions or not ZO_SharedOptions.AddTableToPanel then return end
    local sharedOptions = { [panelId] = {} }
    for _, optionData in ipairs(optionsData) do
        sharedOptions[panelId][optionData.settingId] = ZO_ShallowTableCopy(optionData)
    end
    ZO_SharedOptions.AddTableToPanel(panelId, sharedOptions)
end

function GamepadOptions.RegisterPanel(panelId, optionsData)
    GamepadOptions.AttachPanelReset(optionsData, panelId)
    local isRegistered = GAMEPAD_SETTINGS_DATA[panelId] ~= nil
    GAMEPAD_SETTINGS_DATA[panelId] = optionsData
    if not isRegistered then
        GamepadOptions.RegisterSharedOptions(panelId, optionsData)
    end
end

function GamepadOptions.ReplacePanel(panelId, optionsData)
    GamepadOptions.AttachPanelReset(optionsData, panelId)
    GAMEPAD_SETTINGS_DATA[panelId] = optionsData
    if ZO_SharedOptions_SettingsData then ZO_SharedOptions_SettingsData[panelId] = nil end
    GamepadOptions.RegisterSharedOptions(panelId, optionsData)
end

function GamepadOptions.RegisterPanelHeaderStrings()
    local headers = {
        [ROOT_PANEL_ID] = "NCollections",
        [PanelIds.GEAR] = NCollections.L("ui.gamepad_options.gear_def2b5f"),
        [PanelIds.GEAR_CRAFTED] = NCollections.L("ui.gamepad_options.gear_crafted"),
        [PanelIds.FOOD_RECIPES] = NCollections.L("ui.gamepad_options.food_recipes_ccd936f"),
        [PanelIds.DRINK_RECIPES] = NCollections.L("ui.gamepad_options.drink_recipes_3128a30"),
        [PanelIds.PLANS] = NCollections.L("ui.gamepad_options.plans_cf2e5f2"),
        [PanelIds.HOUSING] = NCollections.L("ui.gamepad_options.housing_0ebae7e"),
        [PanelIds.MOUNTS] = NCollections.L("ui.gamepad_options.mounts_9516ba1"),
        [PanelIds.SKINS] = NCollections.L("ui.gamepad_options.skins_3e03229"),
        [PanelIds.PETS] = NCollections.L("ui.gamepad_options.non_combat_pets_8cfb68d"),
        [PanelIds.MEMENTOS] = NCollections.L("ui.gamepad_options.mementos_5f8031a"),
        [PanelIds.COMPANIONS] = NCollections.L("ui.gamepad_options.companions_759f9cd"),
        [PanelIds.ITEM_CATEGORIES] = NCollections.L("ui.navigation.item_categories"),
        [PanelIds.APPEARANCE] = NCollections.L("collections.appearance"),
        [PanelIds.ASSISTANTS] = NCollections.L("collections.assistants"),
        [PanelIds.SKILL_STYLES] = NCollections.L("collections.skill_styles"),
        [PanelIds.OUTFIT_STYLES] = NCollections.L("collections.outfit_styles"),
        [PanelIds.ANTIQUITIES] = NCollections.L("collections.antiquities"),
        [PanelIds.DYES] = NCollections.L("collections.dyes"),
        [PanelIds.SCRIBING] = NCollections.L("collections.scribing"),
        [PanelIds.COLLECTIBLE_FURNISHINGS] = NCollections.L("collections.collectible_furnishings"),
        [PanelIds.EMOTES_AND_ACTIONS] = NCollections.L("collections.emotes_and_actions"),
    }
    for panelId, title in pairs(headers) do
        ZO_CreateStringId("SI_SETTINGSYSTEMPANEL" .. panelId, title)
        SafeAddVersion("SI_SETTINGSYSTEMPANEL" .. panelId, 1)
    end
end

function GamepadOptions.ApplyHeaderVersionSubtitle()
    if not GAMEPAD_OPTIONS or not GAMEPAD_OPTIONS.header or not GAMEPAD_OPTIONS.headerData
        or not ZO_GamepadGenericHeader_RefreshData then return end
    local version = NCollections.version
    GAMEPAD_OPTIONS.headerData.subtitleText = GAMEPAD_OPTIONS.currentCategory == ROOT_PANEL_ID
        and version and version ~= 0 and ("v" .. tostring(version)) or nil
    ZO_GamepadGenericHeader_RefreshData(GAMEPAD_OPTIONS.header, GAMEPAD_OPTIONS.headerData)
end

function GamepadOptions.HookHeaderVersionSubtitle()
    if headerVersionHooked or not GAMEPAD_OPTIONS or type(ZO_PostHook) ~= "function" then return end
    headerVersionHooked = true
    ZO_PostHook(GAMEPAD_OPTIONS, "RefreshHeader", GamepadOptions.ApplyHeaderVersionSubtitle)
end

function GamepadOptions.RegisterPanels()
    if panelsRegistered then return true end
    if not GAMEPAD_OPTIONS or not GAMEPAD_SETTINGS_DATA or not ZO_GamepadEntryData then return false end

    GamepadOptions.HookHeaderVersionSubtitle()
    GamepadOptions.RegisterPanelHeaderStrings()
    GamepadOptions.RegisterPanel(ROOT_PANEL_ID, GamepadOptions.BuildRootOptionsData())
    GamepadOptions.RegisterPanel(PanelIds.GEAR, GamepadOptions.BuildGearOptionsData())
    GamepadOptions.RegisterPanel(PanelIds.GEAR_CRAFTED, GamepadOptions.BuildGearCraftedOptionsData())
    GamepadOptions.RegisterPanel(PanelIds.FOOD_RECIPES, GamepadOptions.BuildRecipesOptionsData(PanelIds.FOOD_RECIPES))
    GamepadOptions.RegisterPanel(PanelIds.DRINK_RECIPES, GamepadOptions.BuildRecipesOptionsData(PanelIds.DRINK_RECIPES))
    GamepadOptions.RegisterPanel(PanelIds.PLANS, GamepadOptions.BuildRecipesOptionsData(PanelIds.PLANS))
    GamepadOptions.RegisterPanel(PanelIds.HOUSING, GamepadOptions.BuildHousingOptionsData())
    GamepadOptions.RegisterPanel(PanelIds.MOUNTS, GamepadOptions.BuildMountsOptionsData())
    GamepadOptions.RegisterPanel(PanelIds.SKINS, GamepadOptions.BuildSkinsOptionsData())
    GamepadOptions.RegisterPanel(PanelIds.PETS, GamepadOptions.BuildPetsOptionsData())
    GamepadOptions.RegisterPanel(PanelIds.MEMENTOS, GamepadOptions.BuildMementosOptionsData())
    GamepadOptions.RegisterPanel(PanelIds.COMPANIONS, GamepadOptions.BuildCompanionsOptionsData())
    GamepadOptions.RegisterPanel(PanelIds.ITEM_CATEGORIES, GamepadOptions.BuildItemCategoriesOptionsData())
    for extendedPanelId, featureName in pairs(EXTENDED_PANEL_FEATURES) do
        GamepadOptions.RegisterPanel(extendedPanelId, GamepadOptions.BuildExtendedCollectionOptionsData(extendedPanelId, NCollections.Features[featureName]))
    end

    panelsRegistered = true
    return true
end

local function CreateMainMenuEntry(name, icon, id, activatedCallback)
    local entryData = {
        name = name,
        icon = icon,
        activatedCallback = activatedCallback,
    }
    local entry = ZO_GamepadEntryData:New(entryData.name, entryData.icon)
    entry:SetIconTintOnSelection(true)
    entry:SetIconDisabledTintOnSelection(true)
    entry.data = entryData
    entry.id = id
    return entry
end

local function FindMenuEntry(entries, entryId)
    for index, entry in ipairs(entries or {}) do
        if entry.id == entryId then return entry, index end
    end
    return nil, nil
end

local function GetMenuEntryName(entry)
    local name = entry and entry.data and entry.data.name
    if type(name) == "function" then name = name() end
    if name == nil and entry then name = entry.text end
    return tostring(name or "")
end

local function InsertSortedMenuEntry(entries, entry)
    local entryName = GetMenuEntryName(entry)
    local insertIndex = #entries + 1
    for index, existingEntry in ipairs(entries) do
        if entryName < GetMenuEntryName(existingEntry) then
            insertIndex = index
            break
        end
    end
    table.insert(entries, insertIndex, entry)
end

local function RefreshMainMenu()
    if MAIN_MENU_GAMEPAD and MAIN_MENU_GAMEPAD.UpdateEntryEnabledStates then
        MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
    elseif MAIN_MENU_GAMEPAD and MAIN_MENU_GAMEPAD.RefreshMainList then
        MAIN_MENU_GAMEPAD:RefreshMainList()
    end
end

local function AddNCollectionsEntry(addonsEntry)
    if not addonsEntry.subMenu then addonsEntry.subMenu = {} end
    if FindMenuEntry(addonsEntry.subMenu, MAIN_MENU_ENTRY_ID) then return false end

    local entry = CreateMainMenuEntry(
        NCollections.L(CATEGORY_NAME_KEY),
        CATEGORY_ICON,
        MAIN_MENU_ENTRY_ID,
        OpenRootPanel
    )
    InsertSortedMenuEntry(addonsEntry.subMenu, entry)
    return true
end

function GamepadOptions.EnsureMainMenuEntry(createFallback)
    if not ZO_MENU_ENTRIES or not ZO_MENU_MAIN_ENTRIES or not ZO_GamepadEntryData
        or not SCENE_MANAGER then return false end

    local sharedAddonsEntry = FindMenuEntry(ZO_MENU_ENTRIES, SHARED_ADDONS_MENU_ENTRY_ID)
    local fallbackAddonsEntry, fallbackIndex = FindMenuEntry(ZO_MENU_ENTRIES, FALLBACK_ADDONS_MENU_ENTRY_ID)

    if sharedAddonsEntry then
        local changed = AddNCollectionsEntry(sharedAddonsEntry)
        if fallbackIndex then
            table.remove(ZO_MENU_ENTRIES, fallbackIndex)
            changed = true
        end
        if changed then RefreshMainMenu() end
        return true
    end

    if fallbackAddonsEntry then
        if AddNCollectionsEntry(fallbackAddonsEntry) then RefreshMainMenu() end
        return true
    end

    if not createFallback then return false end

    local subMenu = {}
    local entryData = {
        name = GetString(SI_GAME_MENU_ADDONS),
        icon = CATEGORY_ICON,
        customTemplate = "ZO_GamepadMenuEntryTemplateWithArrow",
        subMenu = subMenu,
    }
    local entry = ZO_GamepadEntryData:New(entryData.name, entryData.icon)
    entry:SetIconTintOnSelection(true)
    entry:SetIconDisabledTintOnSelection(true)
    entry.data = entryData
    entry.id = FALLBACK_ADDONS_MENU_ENTRY_ID
    entry.subMenu = subMenu
    AddNCollectionsEntry(entry)

    local _, activityFinderIndex = FindMenuEntry(ZO_MENU_ENTRIES, ZO_MENU_MAIN_ENTRIES.ACTIVITY_FINDER)
    if activityFinderIndex then
        table.insert(ZO_MENU_ENTRIES, activityFinderIndex, entry)
    else
        table.insert(ZO_MENU_ENTRIES, entry)
    end

    RefreshMainMenu()
    return true
end

function GamepadOptions.InstallSharedAddonsMenuHook()
    if sharedAddonsMenuHookInstalled then return true end
    if not LibHarvensAddonSettings
        or type(LibHarvensAddonSettings.CreateAddonSettingsPanel) ~= "function"
        or type(ZO_PostHook) ~= "function" then return false end

    ZO_PostHook(LibHarvensAddonSettings, "CreateAddonSettingsPanel", function()
        GamepadOptions.EnsureMainMenuEntry(false)
    end)
    sharedAddonsMenuHookInstalled = true
    GamepadOptions.EnsureMainMenuEntry(false)
    return true
end

function GamepadOptions.InstallMainMenuWatcher()
    if mainMenuWatcherInstalled then return true end
    if not MAIN_MENU_GAMEPAD_SCENE or not MAIN_MENU_GAMEPAD_SCENE.RegisterCallback
        or type(zo_callLater) ~= "function" then return false end

    MAIN_MENU_GAMEPAD_SCENE:RegisterCallback("StateChange", function(_, newState)
        if newState ~= SCENE_SHOWING and newState ~= "showing" then return end
        zo_callLater(function() GamepadOptions.EnsureMainMenuEntry(true) end, 0)
    end)
    mainMenuWatcherInstalled = true
    if MAIN_MENU_GAMEPAD_SCENE.IsShowing and MAIN_MENU_GAMEPAD_SCENE:IsShowing() then
        zo_callLater(function() GamepadOptions.EnsureMainMenuEntry(true) end, 0)
    end
    return true
end

function GamepadOptions.InstallSubpanelBackOverride()
    if backOverrideInstalled or not SCENE_MANAGER then return end
    local panelScene = SCENE_MANAGER:GetScene("gamepad_options_panel")
    if not panelScene then return end
    panelScene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING or newState == "showing" then
            if GAMEPAD_OPTIONS and GamepadOptions.IsSubpanel(GAMEPAD_OPTIONS.currentCategory) then
                GamepadOptions.ReplaceSubpanelBackKeybind()
            end
        elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN or newState == "hiding" or newState == "hidden" then
            SetFeaturePreview(nil)
            if GAMEPAD_OPTIONS then GAMEPAD_OPTIONS:RevertBackKeybind() end
        end
    end)
    backOverrideInstalled = true
end

function GamepadOptions.Initialize()
    GamepadOptions.InstallSubpanelBackOverride()
    local attempts = 0
    local function TryRegister()
        local panelsReady = GamepadOptions.RegisterPanels()
        GamepadOptions.InstallSharedAddonsMenuHook()
        GamepadOptions.EnsureMainMenuEntry(false)
        local mainMenuWatcherReady = GamepadOptions.InstallMainMenuWatcher()
        if panelsReady and mainMenuWatcherReady then return end
        attempts = attempts + 1
        if attempts < 10 then zo_callLater(TryRegister, 1000) end
    end
    TryRegister()
end

GamepadOptions.parentSelectionByChildPanel = {}
