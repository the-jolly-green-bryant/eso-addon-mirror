-- BonkSimulator.lua
local ADDON_NAME = "BonkSimulator"
local LABEL_NAME = "BonkSimulator_Label"

local trackedAbilities = {
    ["Onslaught"] = "Onslaught",
    ["Berserker Rage"] = "Berserker Rage",
    ["Berserker Strike"] = "Berserker Strike",
}

local defaultSettings = {
    animationType = "pop",
    fontSize = 48,
    scale = 1.2,
    textColor = {1, 0.8, 0, 1},
}

local function InitializeSavedVariables()
    BonkSimulatorSaved = BonkSimulatorSaved or {}
    BonkSimulatorSaved.counts = BonkSimulatorSaved.counts or {}
    BonkSimulatorSaved.settings = BonkSimulatorSaved.settings or {}

    for key, value in pairs(defaultSettings) do
        if BonkSimulatorSaved.settings[key] == nil then
            BonkSimulatorSaved.settings[key] = value
        end
    end

    for _, name in pairs(trackedAbilities) do
        BonkSimulatorSaved.counts[name] = BonkSimulatorSaved.counts[name] or 0
    end
end

local function GetColorValues()
    local color = BonkSimulatorSaved.settings.textColor or defaultSettings.textColor
    return color[1], color[2], color[3], color[4]
end

local function UpdateLabelVisual(label)
    if not label then return end
    local settings = BonkSimulatorSaved.settings
    label:SetFont(string.format("ZoFontGameLarge|%d|soft-shadow-thick", settings.fontSize))
    label:SetColor(settings.textColor[1], settings.textColor[2], settings.textColor[3], settings.textColor[4])
end

local function CreateBonkLabel()
    local win = WINDOW_MANAGER:GetControlByName("BonkSIM_Window")
    if not win then
        win = WINDOW_MANAGER:CreateTopLevelWindow("BonkSIM_Window")
        win:SetDimensions(512, 120)
        win:SetAnchor(CENTER, GuiRoot, CENTER, 0, -80)
    end
    local label = WINDOW_MANAGER:GetControlByName(LABEL_NAME)
    if label then
        UpdateLabelVisual(label)
        return label
    end

    label = WINDOW_MANAGER:CreateControl(LABEL_NAME, win, CT_LABEL)
    label:SetAnchor(CENTER, win, CENTER, 0, 0)
    label:SetDimensions(512, 120)
    label:SetText("BONK!!")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetHidden(true)
    label:SetMouseEnabled(false)
    UpdateLabelVisual(label)
    return label
end

local function CreateBonkAnimation(label)
    if not label then return nil end
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    timeline.animationType = "BonkSimulator_Animation"

    local settings = BonkSimulatorSaved.settings
    local animScale1, animScale2, animAlpha1, animAlpha2, animDelay

    if settings.animationType == "bounce" then
        animScale1, animScale2 = settings.scale * 1.2, settings.scale * 0.8
        animAlpha1, animAlpha2 = 0, 1
        animDelay = 160
    elseif settings.animationType == "fade" then
        animScale1, animScale2 = settings.scale * 0.3, settings.scale * 1.0
        animAlpha1, animAlpha2 = 0, 1
        animDelay = 340
    else
        animScale1, animScale2 = settings.scale * 0.3, settings.scale * 1.2
        animAlpha1, animAlpha2 = 0, 1
        animDelay = 360
    end

    local alphaIn = timeline:InsertAnimation(ANIMATION_ALPHA, label)
    alphaIn:SetAlphaValues(0, 1)
    alphaIn:SetDuration(140)

    local scaleIn = timeline:InsertAnimation(ANIMATION_SCALE, label)
    scaleIn:SetScaleValues(animScale1, animScale2)
    scaleIn:SetDuration(200)
    scaleIn:SetEasingFunction(ZO_EaseOutCubic)

    if settings.animationType == "bounce" then
        local scaleBack = timeline:InsertAnimation(ANIMATION_SCALE, label)
        scaleBack:SetScaleValues(animScale2, settings.scale)
        scaleBack:SetDuration(180)
        scaleBack:SetEasingFunction(ZO_EaseInCubic)
    end
    
    local hold = timeline:InsertAnimation(ANIMATION_ALPHA, label)
    hold:SetAlphaValues(1, 1)
    hold:SetDuration(animDelay)

    local alphaOut = timeline:InsertAnimation(ANIMATION_ALPHA, label)
    alphaOut:SetAlphaValues(1, 0)
    alphaOut:SetDuration(220)

    local scaleOut = timeline:InsertAnimation(ANIMATION_SCALE, label)
    scaleOut:SetScaleValues(settings.scale, 0.3)
    scaleOut:SetDuration(220)
    scaleOut:SetEasingFunction(ZO_EaseInCubic)

    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
    timeline:SetHandler("OnPlay", function()
        label:SetHidden(false)
    end)
    timeline:SetHandler("OnStop", function()
        label:SetHidden(true)
        UpdateLabelVisual(label)
    end)
    return timeline
end

local function ShowBonkVisual()
    local label = CreateBonkLabel()
    if not label then return end
    UpdateLabelVisual(label)
    label.bonkTimeline = CreateBonkAnimation(label)
    if label.bonkTimeline then
        label.bonkTimeline:PlayFromStart()
    end
end

local function ResetBonkCounts()
    BonkSimulatorSaved.counts = {}
    for _, name in pairs(trackedAbilities) do
        BonkSimulatorSaved.counts[name] = 0
    end
end

local function PrintStats()
    d("--- Bonk Stats ---")
    for _, name in pairs(trackedAbilities) do
        d(string.format("%s: %d", name, BonkSimulatorSaved.counts[name] or 0))
    end
end

local function SetupOptions()
    local LAM = LibAddonMenu2 and LibAddonMenu2 or (LibStub and LibStub("LibAddonMenu-2.0", true))
    if not LAM then
        return
    end

    local panelData = {
        type = "panel",
        name = "BonkSimulator",
        displayName = "BonkSimulator",
        author = "Vixen Hunny",
        version = "1.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(ADDON_NAME .. "_Options", panelData)

    local function GetAnimationType()
        return BonkSimulatorSaved.settings.animationType
    end
    local function SetAnimationType(value)
        BonkSimulatorSaved.settings.animationType = value
    end
    local function GetFontSize()
        return BonkSimulatorSaved.settings.fontSize
    end
    local function SetFontSize(value)
        BonkSimulatorSaved.settings.fontSize = value
        UpdateLabelVisual(WINDOW_MANAGER:GetControlByName(LABEL_NAME))
    end
    local function GetScale()
        return BonkSimulatorSaved.settings.scale
    end
    local function SetScale(value)
        BonkSimulatorSaved.settings.scale = value
        UpdateLabelVisual(WINDOW_MANAGER:GetControlByName(LABEL_NAME))
    end
    local function GetColor()
        return unpack(BonkSimulatorSaved.settings.textColor)
    end
    local function SetColor(r, g, b, a)
        BonkSimulatorSaved.settings.textColor = {r, g, b, a}
        UpdateLabelVisual(WINDOW_MANAGER:GetControlByName(LABEL_NAME))
    end

    local optionsTable = {
        {
            type = "description",
            text = "Use these settings to control the bonk text animation, font size, scale, and color.",
        },
        {
            type = "dropdown",
            name = "Animation style",
            choices = {"Pop Out", "Bounce", "Fade"},
            choicesValues = {"pop", "bounce", "fade"},
            getFunc = GetAnimationType,
            setFunc = SetAnimationType,
            width = "full",
        },
        {
            type = "slider",
            name = "Font size",
            min = 24,
            max = 96,
            step = 1,
            getFunc = GetFontSize,
            setFunc = SetFontSize,
            width = "half",
        },
        {
            type = "slider",
            name = "Scale",
            min = 0.5,
            max = 3.0,
            step = 0.05,
            getFunc = GetScale,
            setFunc = SetScale,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "Text color",
            getFunc = GetColor,
            setFunc = SetColor,
            width = "half",
            alpha = true,
        },
        {
            type = "button",
            name = "Test bonk",
            func = ShowBonkVisual,
            width = "half",
        },
    }

    LAM:RegisterOptionControls(ADDON_NAME .. "_Options", optionsTable)
end

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end
    if not abilityName then
        return
    end
    if result ~= ACTION_RESULT_CRITICAL_DAMAGE and result ~= ACTION_RESULT_DAMAGE and result ~= ACTION_RESULT_BLOCKED_DAMAGE and result ~= ACTION_RESULT_DAMAGE_SHIELDED then
        return
    end
    for key, name in pairs(trackedAbilities) do
        if string.find(abilityName, key) then
            BonkSimulatorSaved.counts[name] = (BonkSimulatorSaved.counts[name] or 0) + 1
            d(string.format("Bonk! %s total: %d", name, BonkSimulatorSaved.counts[name]))
            ShowBonkVisual()
            return
        end
    end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    InitializeSavedVariables()
    SetupOptions()

    SLASH_COMMANDS["/bonkstats"] = PrintStats
    SLASH_COMMANDS["/bonkreset"] = function()
        ResetBonkCounts()
        d("Bonk stats reset.")
    end
    SLASH_COMMANDS["/bonktest"] = ShowBonkVisual
    SLASH_COMMANDS["/bonkconfig"] = function()
        local LAM = LibStub and LibStub("LibAddonMenu-2.0", true)
        if LAM then
            LAM:OpenToPanel(ADDON_NAME .. "_Options")
        else
            d("BonkSimulator: LibAddonMenu-2.0 not found.")
        end
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT, OnCombatEvent)
    d("BonkSimulator loaded. Use /bonkstats, /bonkreset, /bonktest, /bonkconfig.")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
