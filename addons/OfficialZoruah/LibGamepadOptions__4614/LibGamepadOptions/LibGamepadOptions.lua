local MAJOR = "LibGamepadOptions"
local MINOR = 7

local existing = _G[MAJOR]
if existing and existing.version and existing.version >= MINOR then
    return
end

local lib = existing or {}
_G[MAJOR] = lib

lib.name = MAJOR
lib.version = MINOR
lib.panels = lib.panels or {}
lib.panelOrder = lib.panelOrder or {}
lib.rootCategoryName = lib.rootCategoryName or "Add-Ons"

local ROOT_PANEL_ID = 98601
local SYSTEM_ID = SETTING_TYPE_CUSTOM or 5000
local FIRST_DYNAMIC_PANEL_ID = 98610
local DEFAULT_CATEGORY_SORT_ORDER = 110
local CATEGORY_ICON = "esoui/art/options/gamepad/gp_options_addons.dds"

local nextPanelId = lib.nextPanelId or FIRST_DYNAMIC_PANEL_ID
local initialized = false
local categoryRegistered = false
local addonCategoriesRegistered = {}
local invokeHooked = false
local rebuildQueued = false
local navStack = {}

local function ResolveText(value)
    local resolved = value
    local remainingCalls = 3

    while type(resolved) == "function" and remainingCalls > 0 do
        local ok, result = pcall(resolved)
        if not ok then
            return ""
        end

        resolved = result
        remainingCalls = remainingCalls - 1
    end

    if type(resolved) == "number" then
        return GetString(resolved) or ""
    end

    if resolved == nil then
        return ""
    end

    return tostring(resolved)
end

local function StripMarkup(text)
    return tostring(text or ""):gsub("|[cC]%x%x%x%x%x%x", ""):gsub("|[rR]", "")
end

local function MakeTooltip(tooltip)
    if tooltip == nil then
        return nil
    end

    return function(tooltipControl)
        local text = ResolveText(tooltip)
        if text ~= "" and GAMEPAD_TOOLTIPS and GAMEPAD_TOOLTIPS.LayoutTextBlockTooltip then
            GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, text)
        end
    end
end

local function NormalizeDisabled(disabled)
    if type(disabled) == "function" then
        return disabled
    end

    if disabled ~= nil then
        return function()
            return disabled and true or false
        end
    end

    return nil
end

local function ShallowCopy(source)
    local copy = {}
    for key, value in pairs(source) do
        copy[key] = value
    end
    return copy
end

local function AllocatePanelId()
    local panelId = nextPanelId
    nextPanelId = nextPanelId + 1
    lib.nextPanelId = nextPanelId
    return panelId
end

local function ReadyForGamepadOptions()
    return GAMEPAD_OPTIONS
        and GAMEPAD_OPTIONS.RegisterCustomCategory
        and GAMEPAD_SETTINGS_DATA
        and ZO_SharedOptions_SettingsData
        and ZO_SharedOptions
        and ZO_SharedOptions.AddTableToPanel
        and ZO_GamepadEntryData
        and ZO_CreateStringId
        and SCENE_MANAGER
        and ZO_PreHook
        and OPTIONS_INVOKE_CALLBACK
        and OPTIONS_CHECKBOX
        and OPTIONS_SLIDER
        and OPTIONS_FINITE_LIST
end

local function CreatePanelContext(panelId, label)
    if label and label ~= "" and ZO_CreateStringId then
        ZO_CreateStringId("SI_SETTINGSYSTEMPANEL" .. tostring(panelId), label)
    end

    GAMEPAD_SETTINGS_DATA[panelId] = {}
    ZO_SharedOptions_SettingsData[panelId] = nil

    return {
        panelId = panelId,
        nextSettingId = 1,
        sharedOptions = {
            [SYSTEM_ID] = {},
        },
    }
end

local function AddOption(context, optionData)
    optionData.panel = context.panelId
    optionData.system = SYSTEM_ID
    optionData.settingId = optionData.settingId or context.nextSettingId
    context.nextSettingId = math.max(context.nextSettingId, optionData.settingId + 1)

    GAMEPAD_SETTINGS_DATA[context.panelId][#GAMEPAD_SETTINGS_DATA[context.panelId] + 1] = optionData
    context.sharedOptions[SYSTEM_ID][optionData.settingId] = ShallowCopy(optionData)
end

local function CommitPanel(context)
    ZO_SharedOptions.AddTableToPanel(context.panelId, context.sharedOptions)
end

local function RefreshCurrentPanel()
    if not GAMEPAD_OPTIONS then
        return
    end

    local currentCategory = GAMEPAD_OPTIONS.currentCategory
    if not (currentCategory and GAMEPAD_SETTINGS_DATA and GAMEPAD_SETTINGS_DATA[currentCategory]) then
        return
    end

    if GAMEPAD_OPTIONS.RefreshHeader then
        GAMEPAD_OPTIONS:RefreshHeader()
    end

    if GAMEPAD_OPTIONS.RefreshOptionsList then
        GAMEPAD_OPTIONS:RefreshOptionsList()
    end
end

local function DeactivateSelectedControl()
    if not GAMEPAD_OPTIONS then
        return
    end

    if type(GAMEPAD_OPTIONS.DeactivateSelectedControl) == "function" then
        GAMEPAD_OPTIONS:DeactivateSelectedControl()
    end
end

local function ClearNavigation()
    navStack = {}

    if GAMEPAD_OPTIONS then
        GAMEPAD_OPTIONS.overrideBackCallback = nil
        GAMEPAD_OPTIONS.overrideBackName = nil
    end
end

local function PushPanel(panelId)
    if not GAMEPAD_OPTIONS then
        return
    end

    DeactivateSelectedControl()

    local selectedIndex = 1
    if GAMEPAD_OPTIONS.optionsList and GAMEPAD_OPTIONS.optionsList.GetSelectedIndex then
        selectedIndex = GAMEPAD_OPTIONS.optionsList:GetSelectedIndex() or 1
    end

    navStack[#navStack + 1] = {
        panelId = GAMEPAD_OPTIONS.currentCategory,
        selectedIndex = selectedIndex,
    }

    GAMEPAD_OPTIONS.overrideBackCallback = function()
        DeactivateSelectedControl()

        local previous = table.remove(navStack)
        if not previous then
            ClearNavigation()
            return
        end

        GAMEPAD_OPTIONS.currentCategory = previous.panelId
        if #navStack == 0 then
            GAMEPAD_OPTIONS.overrideBackCallback = nil
            GAMEPAD_OPTIONS.overrideBackName = nil
        else
            GAMEPAD_OPTIONS.overrideBackName = GetString(SI_GAMEPAD_BACK_OPTION)
        end

        RefreshCurrentPanel()

        if previous.selectedIndex and GAMEPAD_OPTIONS.optionsList and GAMEPAD_OPTIONS.optionsList.SetSelectedIndexWithoutAnimation then
            GAMEPAD_OPTIONS.optionsList:SetSelectedIndexWithoutAnimation(previous.selectedIndex, true)
        end
    end
    GAMEPAD_OPTIONS.overrideBackName = GetString(SI_GAMEPAD_BACK_OPTION)
    GAMEPAD_OPTIONS.currentCategory = panelId

    RefreshCurrentPanel()

    if GAMEPAD_OPTIONS.optionsList and GAMEPAD_OPTIONS.optionsList.SetFirstIndexSelected then
        GAMEPAD_OPTIONS.optionsList:SetFirstIndexSelected()
    end
end

local BuildPanel

local function ChainCallbacks(first, second)
    if first and second then
        return function(...)
            first(...)
            second(...)
        end
    end

    return first or second
end

local function FormatSliderValue(value, decimals)
    local numberValue = tonumber(value)
    if not numberValue then
        return ResolveText(value)
    end

    if decimals <= 0 then
        return tostring(math.floor(numberValue + 0.5))
    end

    return string.format("%." .. tostring(decimals) .. "f", numberValue)
end

local function MakeSliderShowValueFunc(decimals)
    return function(value)
        return FormatSliderValue(value, decimals)
    end
end

local function CreateSliderLabel(control, suffix, width, alignment)
    local label = control:GetNamedChild(suffix)
    if label then
        return label
    end

    if not control.GetName then
        return nil
    end

    label = WINDOW_MANAGER:CreateControl(control:GetName() .. suffix, control, CT_LABEL)
    label:SetFont("ZoFontGamepad22")
    label:SetDimensions(width, 24)
    label:SetHorizontalAlignment(alignment)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetMouseEnabled(false)
    return label
end

local function ApplySliderLabelColor(control)
    local nameLabel = control:GetNamedChild("Name")
    local r, g, b, a = 1, 1, 1, 1
    if nameLabel and nameLabel.GetColor then
        r, g, b, a = nameLabel:GetColor()
    end

    local labelSuffixes = { "ValueLabel", "MinValueLabel", "MaxValueLabel" }
    for _, suffix in ipairs(labelSuffixes) do
        local label = control:GetNamedChild(suffix)
        if label then
            label:SetColor(r, g, b, a)
        end
    end
end

local function RefreshSliderRangeLabels(control)
    local data = control.data
    if not (data and data.showValue ~= false and ZO_Options_GetFormattedSliderValues) then
        return
    end

    local currentValue
    if data.GetSettingOverride then
        currentValue = data.GetSettingOverride(control)
    elseif data.minValue then
        currentValue = data.minValue
    end

    local _, minValue, maxValue = ZO_Options_GetFormattedSliderValues(data, currentValue)
    local minLabel = control:GetNamedChild("MinValueLabel")
    local maxLabel = control:GetNamedChild("MaxValueLabel")

    if minLabel then
        minLabel:SetText(tostring(minValue or ""))
    end

    if maxLabel then
        maxLabel:SetText(tostring(maxValue or ""))
    end
end

local function SetupGamepadSliderValueLabels(control)
    if not control or not control.GetNamedChild then
        return
    end

    local slider = control:GetNamedChild("Slider")
    if not slider then
        return
    end

    local valueLabel = CreateSliderLabel(control, "ValueLabel", 120, TEXT_ALIGN_CENTER)
    local minLabel = CreateSliderLabel(control, "MinValueLabel", 110, TEXT_ALIGN_LEFT)
    local maxLabel = CreateSliderLabel(control, "MaxValueLabel", 110, TEXT_ALIGN_RIGHT)

    if valueLabel then
        valueLabel:ClearAnchors()
        valueLabel:SetAnchor(TOP, slider, BOTTOM, 0, 2)
    end

    if minLabel then
        minLabel:ClearAnchors()
        minLabel:SetAnchor(TOPLEFT, slider, BOTTOMLEFT, 0, 2)
    end

    if maxLabel then
        maxLabel:ClearAnchors()
        maxLabel:SetAnchor(TOPRIGHT, slider, BOTTOMRIGHT, 0, 2)
    end

    control.GetHeight = function(row)
        local rowLabel = row:GetNamedChild("Name")
        local rowSlider = row:GetNamedChild("Slider")
        local rowValueLabel = row:GetNamedChild("ValueLabel")

        local labelHeight = rowLabel and rowLabel:GetTextHeight() or 0
        local sliderHeight = rowSlider and rowSlider:GetHeight() or 0
        local valueHeight = rowValueLabel and rowValueLabel:GetTextHeight() or 0

        return labelHeight + sliderHeight + valueHeight + 12
    end

    RefreshSliderRangeLabels(control)
    ApplySliderLabelColor(control)
end

local function WrapSetter(setFunc)
    return function(control, value)
        if setFunc then
            setFunc(value)
        end

        CALLBACK_MANAGER:FireCallbacks(MAJOR .. "-SettingChanged", control and control.data, value)
    end
end

local function BuildOption(option, allocateNestedPanel)
    local optionType = option.type
    local text = ResolveText(option.name or option.title or option.text)
    local result

    if optionType == "description" then
        result = {
            controlType = OPTIONS_INVOKE_CALLBACK,
            text = text,
            gamepadTextOverride = text,
            disabled = function()
                return true
            end,
            canSelect = false,
        }
    elseif optionType == "checkbox" then
        result = {
            controlType = OPTIONS_CHECKBOX,
            text = text,
            gamepadTextOverride = text,
            GetSettingOverride = option.getFunc,
            SetSettingOverride = WrapSetter(option.setFunc),
            disabled = NormalizeDisabled(option.disabled),
        }
    elseif optionType == "slider" then
        local minValue = option.min or 0
        local maxValue = option.max or 1
        local decimals = tonumber(option.decimals) or 0

        result = {
            controlType = OPTIONS_SLIDER,
            text = text,
            gamepadTextOverride = text,
            minValue = minValue,
            maxValue = maxValue,
            showValue = option.showValue ~= false,
            GetSettingOverride = option.getFunc,
            SetSettingOverride = WrapSetter(option.setFunc),
            disabled = NormalizeDisabled(option.disabled),
        }

        result.showValueFunc = option.showValueFunc or (not option.valueTextFormatter and MakeSliderShowValueFunc(decimals))
        result.valueTextFormatter = option.valueTextFormatter
        result.showValueMin = option.showValueMin
        result.showValueMax = option.showValueMax
        result.onInitializeFunction = ChainCallbacks(option.onInitializeFunction, SetupGamepadSliderValueLabels)

        if decimals > 0 then
            result.valueFormat = "%." .. tostring(decimals) .. "f"
        end

        if option.step and option.step > 0 and maxValue > minValue then
            result.gamepadValueStepPercent = (option.step / (maxValue - minValue)) * 100
        end
    elseif optionType == "dropdown" then
        result = {
            controlType = OPTIONS_FINITE_LIST,
            text = text,
            gamepadTextOverride = text,
            valid = option.choicesValues or option.choices or {},
            itemText = option.choices or {},
            GetSettingOverride = option.getFunc,
            SetSettingOverride = WrapSetter(option.setFunc),
            disabled = NormalizeDisabled(option.disabled),
        }
    elseif optionType == "button" then
        result = {
            controlType = OPTIONS_INVOKE_CALLBACK,
            text = text,
            gamepadTextOverride = text,
            callback = option.func,
            disabled = NormalizeDisabled(option.disabled),
        }
    elseif optionType == "submenu" then
        local nestedPanelId = allocateNestedPanel()
        BuildPanel(nestedPanelId, text, option.controls or {})

        result = {
            controlType = OPTIONS_INVOKE_CALLBACK,
            text = text,
            gamepadTextOverride = text,
            callback = function()
                PushPanel(nestedPanelId)
            end,
            disabled = NormalizeDisabled(option.disabled),
        }
    else
        result = {
            controlType = OPTIONS_INVOKE_CALLBACK,
            text = text ~= "" and text or "Unsupported option",
            gamepadTextOverride = text ~= "" and text or "Unsupported option",
            disabled = function()
                return true
            end,
        }
    end

    if option.onInitializeFunction and not result.onInitializeFunction then
        result.onInitializeFunction = option.onInitializeFunction
    end

    result.gamepadCustomTooltipFunction = MakeTooltip(option.tooltip)

    if option.default ~= nil and option.setFunc then
        result.customResetToDefaultsFunction = function()
            local defaultValue = type(option.default) == "function" and option.default() or option.default
            option.setFunc(defaultValue)
        end
    end

    return result
end

BuildPanel = function(panelId, label, options)
    local context = CreatePanelContext(panelId, label)
    local pendingHeader

    for _, option in ipairs(options or {}) do
        if option.type == "header" then
            pendingHeader = ResolveText(option.name or option.title)
        elseif option.type == "divider" then
            pendingHeader = nil
        else
            local gamepadOption = BuildOption(option, AllocatePanelId)
            if pendingHeader and pendingHeader ~= "" then
                local headerText = pendingHeader
                gamepadOption.header = function()
                    return headerText
                end
                pendingHeader = nil
            end

            AddOption(context, gamepadOption)
        end
    end

    CommitPanel(context)
end

local function InstallInvokeHook()
    if invokeHooked then
        return
    end

    invokeHooked = true
    ZO_PreHook("ZO_Options_InvokeCallback", function(control)
        local data = control and control.data
        if data and data.system == SYSTEM_ID and data.callback then
            data.callback(control)
            return true
        end

        return false
    end)
end

local function RegisterRootCategory()
    if categoryRegistered then
        return
    end

    categoryRegistered = true

    local categoryName = ResolveText(lib.rootCategoryName)
    if categoryName == "" then
        categoryName = "Add-Ons"
    end

    local categoryData = ZO_GamepadEntryData:New(categoryName, CATEGORY_ICON)
    categoryData.sortOrder = DEFAULT_CATEGORY_SORT_ORDER
    categoryData.panelId = ROOT_PANEL_ID
    categoryData.callback = function()
        lib:OpenRoot()
    end

    if categoryData.SetIconTintOnSelection then
        categoryData:SetIconTintOnSelection(true)
    end

    ZO_CreateStringId("SI_SETTINGSYSTEMPANEL" .. tostring(ROOT_PANEL_ID), categoryName)
    GAMEPAD_OPTIONS:RegisterCustomCategory(categoryData)
end

local function RegisterAddonCategory(addonId, registration)
    if addonCategoriesRegistered[addonId] then
        return
    end

    local panelData = registration.panelData or {}
    if not (panelData.categoryName or panelData.showCategory == true) then
        return
    end

    local categoryName = ResolveText(panelData.categoryName or panelData.displayName or panelData.name or addonId)
    if categoryName == "" then
        categoryName = addonId
    end

    addonCategoriesRegistered[addonId] = true

    local categoryData = ZO_GamepadEntryData:New(categoryName, panelData.categoryIcon or CATEGORY_ICON)
    categoryData.sortOrder = tonumber(panelData.categorySortOrder) or tonumber(panelData.sortOrder) or DEFAULT_CATEGORY_SORT_ORDER
    categoryData.panelId = registration.panelId
    categoryData.callback = function()
        if panelData.directOpen == false then
            lib:OpenRoot()
        else
            lib:OpenPanel(addonId)
        end
    end

    if categoryData.SetIconTintOnSelection then
        categoryData:SetIconTintOnSelection(true)
    end

    GAMEPAD_OPTIONS:RegisterCustomCategory(categoryData)
end

local function SortedPanelIds()
    local ids = {}
    for _, addonId in ipairs(lib.panelOrder) do
        if lib.panels[addonId] and lib.panels[addonId].options and #lib.panels[addonId].options > 0 then
            ids[#ids + 1] = addonId
        end
    end

    table.sort(ids, function(a, b)
        local panelA = lib.panels[a].panelData or {}
        local panelB = lib.panels[b].panelData or {}
        local sortA = tonumber(panelA.sortOrder) or 1000
        local sortB = tonumber(panelB.sortOrder) or 1000

        if sortA ~= sortB then
            return sortA < sortB
        end

        local nameA = StripMarkup(ResolveText(panelA.displayName or panelA.name or a)):lower()
        local nameB = StripMarkup(ResolveText(panelB.displayName or panelB.name or b)):lower()
        if nameA == nameB then
            return tostring(a) < tostring(b)
        end

        return nameA < nameB
    end)

    return ids
end

local function Rebuild()
    if not ReadyForGamepadOptions() then
        return false
    end

    InstallInvokeHook()

    local rootContext = CreatePanelContext(ROOT_PANEL_ID)
    local rootOptionCount = 0

    for _, addonId in ipairs(SortedPanelIds()) do
        local registration = lib.panels[addonId]
        local panelData = registration.panelData or {}
        local panelId = registration.panelId or AllocatePanelId()
        registration.panelId = panelId

        local displayName = ResolveText(panelData.displayName or panelData.name or addonId)
        local tooltip = panelData.tooltip or panelData.description

        BuildPanel(panelId, StripMarkup(displayName), registration.options)
        RegisterAddonCategory(addonId, registration)

        local showInRoot = panelData.showInRoot
        if showInRoot == nil then
            showInRoot = panelData.directOpen == false or not (panelData.categoryName or panelData.showCategory == true)
        end

        if showInRoot then
            rootOptionCount = rootOptionCount + 1
            AddOption(rootContext, {
                controlType = OPTIONS_INVOKE_CALLBACK,
                text = displayName,
                gamepadTextOverride = displayName,
                callback = function()
                    PushPanel(panelId)
                end,
                gamepadCustomTooltipFunction = MakeTooltip(tooltip),
            })
        end
    end

    if rootOptionCount > 0 then
        RegisterRootCategory()
        CommitPanel(rootContext)
    end

    initialized = true
    RefreshCurrentPanel()
    return true
end

local function QueueRebuild()
    if rebuildQueued then
        return
    end

    rebuildQueued = true
    local function Run()
        rebuildQueued = false
        Rebuild()
    end

    zo_callLater(Run, 100)
end

function lib:RegisterPanel(addonId, panelData)
    if type(addonId) ~= "string" or addonId == "" then
        return false
    end

    if not self.panels[addonId] then
        self.panels[addonId] = {}
        self.panelOrder[#self.panelOrder + 1] = addonId
    end

    self.panels[addonId].panelData = panelData or {}
    QueueRebuild()
    return true
end

function lib:RegisterOptions(addonId, options)
    if type(addonId) ~= "string" or addonId == "" then
        return false
    end

    if not self.panels[addonId] then
        self.panels[addonId] = {}
        self.panelOrder[#self.panelOrder + 1] = addonId
    end

    self.panels[addonId].options = options or {}
    QueueRebuild()
    return true
end

function lib:RegisterAddon(addonId, panelData, options)
    self:RegisterPanel(addonId, panelData)
    self:RegisterOptions(addonId, options)
    return true
end

function lib:SetRootCategoryName(name)
    self.rootCategoryName = ResolveText(name)
    return true
end

function lib:SetOpenSingleAddonDirectly(enabled)
    self.openSingleAddonDirectly = enabled == true
    return true
end

function lib:OpenRoot()
    if not initialized then
        Rebuild()
    end

    if not GAMEPAD_OPTIONS or not SCENE_MANAGER then
        return false
    end

    ClearNavigation()

    local targetPanelId = ROOT_PANEL_ID
    if self.openSingleAddonDirectly then
        local panelIds = SortedPanelIds()
        if #panelIds == 1 then
            local registration = self.panels[panelIds[1]]
            if registration and registration.panelId then
                targetPanelId = registration.panelId
            end
        end
    end

    GAMEPAD_OPTIONS.currentCategory = targetPanelId
    SCENE_MANAGER:Push("gamepad_options_panel")
    return true
end

function lib:OpenPanel(addonId)
    if not initialized then
        Rebuild()
    end

    local registration = self.panels[addonId]
    if not registration or not registration.panelId then
        return false
    end

    if GAMEPAD_OPTIONS and SCENE_MANAGER then
        ClearNavigation()
        GAMEPAD_OPTIONS.currentCategory = registration.panelId
        SCENE_MANAGER:Push("gamepad_options_panel")
        return true
    end

    return false
end

local function TryInitialize()
    Rebuild()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= MAJOR then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(MAJOR .. "Loaded", EVENT_ADD_ON_LOADED)

    zo_callLater(TryInitialize, 500)
end

EVENT_MANAGER:RegisterForEvent(MAJOR .. "Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(MAJOR .. "Activated", EVENT_PLAYER_ACTIVATED, TryInitialize)
