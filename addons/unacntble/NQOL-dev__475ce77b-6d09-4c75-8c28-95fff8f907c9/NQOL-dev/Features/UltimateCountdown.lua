NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local UltimateCountdown = {}

local EVENT_NAMESPACE = "NQOL_UltimateCountdown"
local UPDATE_INTERVAL_MS = 100
local ULTIMATE_SLOT = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
local FRONT_BAR = "frontBar"
local BACK_BAR = "backBar"
local FONT_SIZE_MIN = 16
local FONT_SIZE_MAX = 144
local SECONDS_MIN = 1
local SECONDS_MAX = 100
local BACKGROUND_OPACITY_MIN = 0
local BACKGROUND_OPACITY_MAX = 100
local SHAPE_SQUARE = "square"
local SHAPE_CIRCLE = "circle"
local SHAPE_DIAMOND = "diamond"
local DRAW_LEVEL = 220
local SQUARE_PADDING_X_RATIO = 0.35
local SQUARE_PADDING_Y_RATIO = 0.18
local TEXTURE_PADDING_RATIO = 0.18
local MIN_BACKGROUND_SIZE_RATIO = 1.2
local GAMEPLAY_SCENES = {
    hud = true,
    hudui = true,
    siegeBar = true,
}
local SHAPE_CHOICES = { SHAPE_SQUARE, SHAPE_CIRCLE, SHAPE_DIAMOND }
local SHAPE_NAMES = NQOL.Lexicon.LocalizedList({ "common.square", "common.circle", "common.diamond" })
local SHAPE_VALID = {
    [SHAPE_SQUARE] = true,
    [SHAPE_CIRCLE] = true,
    [SHAPE_DIAMOND] = true,
}
local SHAPE_TEXTURES = {
    [SHAPE_CIRCLE] = "nqol_countdown_circle.dds",
    [SHAPE_DIAMOND] = "nqol_countdown_diamond.dds",
}

local defaults = {
    ultimateCountdown = {
        frontBar = {
            enabled = false,
            seconds = 30,
            showInSettings = true,
            horizontalPosition = 45,
            verticalPosition = 42,
            font = NQOL.Util.GetDefaultFont(),
            fontSize = 34,
            color = { r = 1, g = 1, b = 1, a = 1 },
            backgroundColor = { r = 0, g = 0, b = 0, a = 1 },
            backgroundOpacity = 0,
            shape = SHAPE_SQUARE,
        },
        backBar = {
            enabled = false,
            seconds = 30,
            showInSettings = true,
            horizontalPosition = 55,
            verticalPosition = 42,
            font = NQOL.Util.GetDefaultFont(),
            fontSize = 34,
            color = { r = 1, g = 1, b = 1, a = 1 },
            backgroundColor = { r = 0, g = 0, b = 0, a = 1 },
            backgroundOpacity = 0,
            shape = SHAPE_SQUARE,
        },
    },
}

local COUNTDOWNS = {
    { key = FRONT_BAR, name = NQOL.L("features.ultimate_countdown.front_bar"), shortName = NQOL.L("features.ultimate_countdown.front_short"), hotbarCategory = HOTBAR_CATEGORY_PRIMARY },
    { key = BACK_BAR, name = NQOL.L("features.ultimate_countdown.back_bar"), shortName = NQOL.L("features.ultimate_countdown.back_short"), hotbarCategory = HOTBAR_CATEGORY_BACKUP },
}
NQOL.Lexicon.RegisterRefreshCallback(function()
    COUNTDOWNS[1].name = NQOL.L("features.ultimate_countdown.front_bar")
    COUNTDOWNS[1].shortName = NQOL.L("features.ultimate_countdown.front_short")
    COUNTDOWNS[2].name = NQOL.L("features.ultimate_countdown.back_bar")
    COUNTDOWNS[2].shortName = NQOL.L("features.ultimate_countdown.back_short")
end)

local countdownByHotbar = {
    [HOTBAR_CATEGORY_PRIMARY] = FRONT_BAR,
    [HOTBAR_CATEGORY_BACKUP] = BACK_BAR,
}

local savedVariables
local initialized = false
local settingsPanelKey
local sceneCallbackInstalled = false
local eventRegistered = false
local updateRegistered = false
local fontStringCache = {}
local controls = {}
local endTimes = {}

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round

local function CopyColor(color)
    return {
        r = Clamp(tonumber(color and color.r) or 1, 0, 1),
        g = Clamp(tonumber(color and color.g) or 1, 0, 1),
        b = Clamp(tonumber(color and color.b) or 1, 0, 1),
        a = Clamp(tonumber(color and color.a) or 1, 0, 1),
    }
end

local function GetNowMs()
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end

    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end

    return os and os.time and (os.time() * 1000) or 0
end

local function GetSection()
    return NQOL.Settings.GetSection(savedVariables, defaults, "ultimateCountdown")
end

local function GetCountdownDefaults(countdownKey)
    return defaults.ultimateCountdown[countdownKey]
end

local function GetCountdownSettings(countdownKey)
    local section = GetSection()
    local countdownDefaults = GetCountdownDefaults(countdownKey)

    if type(section[countdownKey]) ~= "table" then
        section[countdownKey] = {}
    end

    local settings = section[countdownKey]
    NQOL.Settings.Boolean(settings, countdownDefaults, "enabled")
    NQOL.Settings.ClampedNumber(settings, countdownDefaults, "seconds", SECONDS_MIN, SECONDS_MAX, true)
    NQOL.Settings.Boolean(settings, countdownDefaults, "showInSettings")
    NQOL.Settings.ClampedNumber(settings, countdownDefaults, "horizontalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, countdownDefaults, "verticalPosition", 0, 100)
    if not NQOL.Util.IsFontChoice(settings.font) then
        settings.font = countdownDefaults.font
    end
    NQOL.Settings.ClampedNumber(settings, countdownDefaults, "fontSize", FONT_SIZE_MIN, FONT_SIZE_MAX, true)
    settings.color = CopyColor(settings.color or countdownDefaults.color)
    settings.backgroundColor = CopyColor(settings.backgroundColor or countdownDefaults.backgroundColor)
    NQOL.Settings.ClampedNumber(settings, countdownDefaults, "backgroundOpacity", BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX, true)
    if SHAPE_VALID[settings.shape] ~= true then
        settings.shape = countdownDefaults.shape
    end

    return settings
end

local function GetCountdownName(countdownKey)
    for _, countdown in ipairs(COUNTDOWNS) do
        if countdown.key == countdownKey then
            return countdown.name
        end
    end

    return NQOL.L("features.ultimate_countdown.ultimate")
end

local function GetCountdownShortName(countdownKey)
    for _, countdown in ipairs(COUNTDOWNS) do
        if countdown.key == countdownKey then
            return countdown.shortName
        end
    end

    return NQOL.L("features.ultimate_countdown.ultimate_short")
end

local function ResolveFont(countdownKey)
    local settings = GetCountdownSettings(countdownKey)
    local cacheKey = settings.font .. "|" .. tostring(settings.fontSize)
    if not fontStringCache[cacheKey] then
        fontStringCache[cacheKey] = NQOL.Util.CreateFontString(settings.font, settings.fontSize, "ZoFontGamepad34")
    end

    return fontStringCache[cacheKey]
end

local function GetCurrentSceneName()
    if not SCENE_MANAGER then
        return nil
    end

    if SCENE_MANAGER.GetCurrentSceneName then
        return SCENE_MANAGER:GetCurrentSceneName()
    end

    if SCENE_MANAGER.GetCurrentScene then
        local scene = SCENE_MANAGER:GetCurrentScene()
        if scene and scene.GetName then
            return scene:GetName()
        end
    end

    return nil
end

local function IsGameplaySceneShowing()
    if not SCENE_MANAGER then
        return true
    end

    return GAMEPLAY_SCENES[GetCurrentSceneName()] == true
end

local function ShouldShowPlaceholder(countdownKey)
    local settings = GetCountdownSettings(countdownKey)
    return settingsPanelKey == countdownKey and settings.showInSettings == true
end

local function HasActiveCountdown()
    local now = GetNowMs()
    for _, countdown in ipairs(COUNTDOWNS) do
        if (endTimes[countdown.key] or 0) > now then
            return true
        end
    end

    return false
end

local function HasEnabledCountdown()
    for _, countdown in ipairs(COUNTDOWNS) do
        if GetCountdownSettings(countdown.key).enabled == true then
            return true
        end
    end

    return false
end

local function MoveControlAbove(control)
    if not control then
        return
    end

    if control.SetDrawLayer and DL_OVERLAY then
        control:SetDrawLayer(DL_OVERLAY)
    end
    if control.SetDrawTier and DT_HIGH then
        control:SetDrawTier(DT_HIGH)
    end
    if control.SetDrawLevel then
        control:SetDrawLevel(DRAW_LEVEL)
    end
end

local function GetAddonTexturePath(textureFile)
    return "/" .. tostring(NQOL.name or "NQOL") .. "/Art/UltimateCountdown/" .. textureFile
end

local function CalculateBackgroundDimensions(settings, textWidth, textHeight)
    local fontSize = Clamp(tonumber(settings.fontSize) or 34, FONT_SIZE_MIN, FONT_SIZE_MAX)
    local minSize = math.ceil(fontSize * MIN_BACKGROUND_SIZE_RATIO)

    if settings.shape == SHAPE_SQUARE then
        local width = textWidth + math.ceil(fontSize * SQUARE_PADDING_X_RATIO * 2)
        local height = textHeight + math.ceil(fontSize * SQUARE_PADDING_Y_RATIO * 2)
        local size = math.max(width, height, minSize)
        return size, size
    end

    local textMax = math.max(textWidth, textHeight)
    local textureSize = textMax + math.ceil(fontSize * TEXTURE_PADDING_RATIO * 2)
    textureSize = math.max(textureSize, minSize)

    if settings.shape == SHAPE_DIAMOND then
        textureSize = math.ceil(textureSize * 1.28)
    end

    return textureSize, textureSize
end

local function GetLabelTextDimensions(label)
    local width = label.GetTextWidth and label:GetTextWidth() or 0
    local height = label.GetTextHeight and label:GetTextHeight() or 0

    if width <= 0 then
        width = label.GetWidth and label:GetWidth() or 34
    end
    if height <= 0 then
        height = label.GetHeight and label:GetHeight() or 34
    end

    return math.max(width, 1), math.max(height, 1)
end

local function EnsureControl(countdownKey)
    if controls[countdownKey] or not WINDOW_MANAGER or not GuiRoot then
        return controls[countdownKey]
    end

    local control = WINDOW_MANAGER:CreateTopLevelWindow("NQOLUltimateCountdown" .. countdownKey)
    control:SetHidden(true)
    control:SetClampedToScreen(true)
    control:SetDimensions(220, 54)
    MoveControlAbove(control)

    local background = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    background:SetAnchorFill(control)
    background:SetCenterColor(0, 0, 0, 0)
    background:SetEdgeColor(0, 0, 0, 0)

    local shapeBackground = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    shapeBackground:SetAnchor(CENTER, control, CENTER, 0, 0)
    shapeBackground:SetColor(0, 0, 0, 0)
    shapeBackground:SetHidden(true)

    local label = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    label:SetAnchor(CENTER, control, CENTER, 0, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(1, 1, 1, 1)

    controls[countdownKey] = {
        root = control,
        background = background,
        shapeBackground = shapeBackground,
        label = label,
    }

    return controls[countdownKey]
end

local function ApplyBackground(countdownKey)
    local control = controls[countdownKey]
    if not control then
        return
    end

    local settings = GetCountdownSettings(countdownKey)
    local opacity = settings.backgroundOpacity / 100
    local color = settings.backgroundColor

    if settings.shape == SHAPE_SQUARE then
        control.background:SetHidden(false)
        control.background:SetCenterColor(color.r, color.g, color.b, opacity)
        control.background:SetEdgeColor(color.r, color.g, color.b, 0)
        control.shapeBackground:SetHidden(true)
    else
        control.background:SetHidden(true)
        control.shapeBackground:SetTexture(GetAddonTexturePath(SHAPE_TEXTURES[settings.shape]))
        control.shapeBackground:SetColor(color.r, color.g, color.b, opacity)
        control.shapeBackground:SetHidden(false)
    end
end

local function ApplyPosition(countdownKey)
    local control = controls[countdownKey]
    if not control or not control.root or not GuiRoot then
        return
    end

    local settings = GetCountdownSettings(countdownKey)
    local screenWidth = (GetScreenWidth and GetScreenWidth()) or (GuiRoot.GetWidth and GuiRoot:GetWidth()) or 1920
    local screenHeight = (GetScreenHeight and GetScreenHeight()) or (GuiRoot.GetHeight and GuiRoot:GetHeight()) or 1080
    local x = (screenWidth - control.root:GetWidth()) * (settings.horizontalPosition / 100)
    local y = (screenHeight - control.root:GetHeight()) * (settings.verticalPosition / 100)

    control.root:ClearAnchors()
    control.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

local function SetCountdownText(countdownKey, text)
    local control = EnsureControl(countdownKey)
    if not control then
        return
    end

    local settings = GetCountdownSettings(countdownKey)
    local color = settings.color
    control.label:SetFont(ResolveFont(countdownKey))
    control.label:SetColor(color.r, color.g, color.b, color.a)
    control.label:SetText(text)

    local textWidth, textHeight = GetLabelTextDimensions(control.label)
    local width, height = CalculateBackgroundDimensions(settings, textWidth, textHeight)
    control.root:SetDimensions(width, height)
    control.shapeBackground:SetDimensions(width, height)
    control.label:SetDimensions(width, height)
    ApplyBackground(countdownKey)
    ApplyPosition(countdownKey)
    control.root:SetHidden(false)
end

local function HideCountdown(countdownKey)
    local control = controls[countdownKey]
    if control and control.root then
        control.root:SetHidden(true)
    end
end

local function FormatCountdownText(countdownKey, remainingSeconds)
    return tostring(remainingSeconds)
end

local function RefreshCountdown(countdownKey)
    local settings = GetCountdownSettings(countdownKey)
    local now = GetNowMs()
    local remainingMs = (endTimes[countdownKey] or 0) - now

    if settings.enabled == true and remainingMs > 0 and IsGameplaySceneShowing() then
        SetCountdownText(countdownKey, FormatCountdownText(countdownKey, math.ceil(remainingMs / 1000)))
    elseif ShouldShowPlaceholder(countdownKey) then
        SetCountdownText(countdownKey, FormatCountdownText(countdownKey, settings.seconds))
    else
        HideCountdown(countdownKey)
    end
end

local function Refresh()
    for _, countdown in ipairs(COUNTDOWNS) do
        RefreshCountdown(countdown.key)
    end
end

local function UpdateLoop()
    Refresh()
    if not HasActiveCountdown() then
        EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
        updateRegistered = false
    end
end

local function RegisterUpdateLoop()
    if updateRegistered or not EVENT_MANAGER then
        return
    end

    updateRegistered = true
    EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE, UPDATE_INTERVAL_MS, UpdateLoop)
end

local function RegisterAbilityEvent()
    if eventRegistered or not EVENT_MANAGER then
        return
    end

    eventRegistered = true
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTION_SLOT_ABILITY_USED, function(_, actionSlotIndex)
        if actionSlotIndex ~= ULTIMATE_SLOT then
            return
        end

        local countdownKey = countdownByHotbar[GetActiveHotbarCategory and GetActiveHotbarCategory() or nil]
        if not countdownKey then
            return
        end

        local settings = GetCountdownSettings(countdownKey)
        if settings.enabled ~= true then
            return
        end

        endTimes[countdownKey] = GetNowMs() + (settings.seconds * 1000)
        RegisterUpdateLoop()
        RefreshCountdown(countdownKey)
    end)
end

local function UpdateAbilityEvent()
    if HasEnabledCountdown() then
        RegisterAbilityEvent()
    elseif eventRegistered and EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ACTION_SLOT_ABILITY_USED)
        eventRegistered = false
    end
end

local function InstallSceneCallback()
    if sceneCallbackInstalled or not SCENE_MANAGER or not SCENE_MANAGER.RegisterCallback then
        return
    end

    sceneCallbackInstalled = true
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", Refresh)

    if EVENT_MANAGER and EVENT_SCREEN_RESIZED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_ScreenResized", EVENT_SCREEN_RESIZED, Refresh)
    end
end

local function UninstallSceneCallback()
    if sceneCallbackInstalled
        and SCENE_MANAGER
        and SCENE_MANAGER.UnregisterCallback
    then
        SCENE_MANAGER:UnregisterCallback("SceneStateChanged", Refresh)
        sceneCallbackInstalled = false
    end

    if EVENT_MANAGER and EVENT_SCREEN_RESIZED then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_ScreenResized", EVENT_SCREEN_RESIZED)
    end
end

local function ShouldRun()
    return HasEnabledCountdown()
        or (settingsPanelKey ~= nil and ShouldShowPlaceholder(settingsPanelKey))
end

local function UpdateRuntime()
    UpdateAbilityEvent()

    if ShouldRun() then
        InstallSceneCallback()
        Refresh()
        return
    end

    if updateRegistered and EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
        updateRegistered = false
    end
    UninstallSceneCallback()
    HideCountdown(FRONT_BAR)
    HideCountdown(BACK_BAR)
end

local function RefreshAfterSetting(countdownKey)
    RefreshCountdown(countdownKey)
end

function UltimateCountdown.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetCountdownSettings(FRONT_BAR)
    GetCountdownSettings(BACK_BAR)
end

function UltimateCountdown.Initialize()
    if initialized then
        UpdateRuntime()
        return
    end

    initialized = true
    UpdateRuntime()
end

function UltimateCountdown.SetSettingsPanelVisible(countdownKey)
    if countdownKey == FRONT_BAR or countdownKey == BACK_BAR then
        settingsPanelKey = countdownKey
    else
        settingsPanelKey = nil
    end
    UpdateRuntime()
end

function UltimateCountdown.GetFrontBarKey()
    return FRONT_BAR
end

function UltimateCountdown.GetBackBarKey()
    return BACK_BAR
end

function UltimateCountdown.GetEnabled(countdownKey) return GetCountdownSettings(countdownKey).enabled end
function UltimateCountdown.GetEnabledDefault(countdownKey) return GetCountdownDefaults(countdownKey).enabled end
function UltimateCountdown.SetEnabled(countdownKey, value)
    GetCountdownSettings(countdownKey).enabled = value == true
    if value ~= true then
        endTimes[countdownKey] = nil
    end
    UpdateRuntime()
end

function UltimateCountdown.GetSeconds(countdownKey) return GetCountdownSettings(countdownKey).seconds end
function UltimateCountdown.SetSeconds(countdownKey, value)
    GetCountdownSettings(countdownKey).seconds = Clamp(Round(value), SECONDS_MIN, SECONDS_MAX)
    RefreshAfterSetting(countdownKey)
end

function UltimateCountdown.GetShowInSettings(countdownKey) return GetCountdownSettings(countdownKey).showInSettings end
function UltimateCountdown.SetShowInSettings(countdownKey, value)
    GetCountdownSettings(countdownKey).showInSettings = value == true
    UpdateRuntime()
end

function UltimateCountdown.GetHorizontalPosition(countdownKey) return GetCountdownSettings(countdownKey).horizontalPosition end
function UltimateCountdown.SetHorizontalPosition(countdownKey, value)
    GetCountdownSettings(countdownKey).horizontalPosition = Clamp(value, 0, 100)
    RefreshAfterSetting(countdownKey)
end

function UltimateCountdown.GetVerticalPosition(countdownKey) return GetCountdownSettings(countdownKey).verticalPosition end
function UltimateCountdown.SetVerticalPosition(countdownKey, value)
    GetCountdownSettings(countdownKey).verticalPosition = Clamp(value, 0, 100)
    RefreshAfterSetting(countdownKey)
end

function UltimateCountdown.GetFontChoices() return NQOL.Util.GetFontChoices() end
function UltimateCountdown.GetFontChoiceNames() return NQOL.Util.GetFontChoiceNames() end
function UltimateCountdown.GetFont(countdownKey) return GetCountdownSettings(countdownKey).font end
function UltimateCountdown.SetFont(countdownKey, value)
    if not NQOL.Util.IsFontChoice(value) then
        value = NQOL.Util.GetDefaultFont()
    end
    GetCountdownSettings(countdownKey).font = value
    fontStringCache = {}
    RefreshAfterSetting(countdownKey)
end

function UltimateCountdown.GetFontSize(countdownKey) return GetCountdownSettings(countdownKey).fontSize end
function UltimateCountdown.SetFontSize(countdownKey, value)
    GetCountdownSettings(countdownKey).fontSize = Clamp(Round(value), FONT_SIZE_MIN, FONT_SIZE_MAX)
    fontStringCache = {}
    RefreshAfterSetting(countdownKey)
end

function UltimateCountdown.GetColor(countdownKey)
    local color = GetCountdownSettings(countdownKey).color
    return color.r, color.g, color.b, color.a
end

function UltimateCountdown.SetColor(countdownKey, red, green, blue, alpha)
    GetCountdownSettings(countdownKey).color = CopyColor({
        r = red,
        g = green,
        b = blue,
        a = alpha or 1,
    })
    RefreshAfterSetting(countdownKey)
end

function UltimateCountdown.GetBackgroundOpacity(countdownKey) return GetCountdownSettings(countdownKey).backgroundOpacity end
function UltimateCountdown.SetBackgroundOpacity(countdownKey, value)
    GetCountdownSettings(countdownKey).backgroundOpacity = Clamp(Round(value), BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX)
    RefreshAfterSetting(countdownKey)
end

function UltimateCountdown.GetBackgroundColor(countdownKey)
    local color = GetCountdownSettings(countdownKey).backgroundColor
    return color.r, color.g, color.b, color.a
end

function UltimateCountdown.SetBackgroundColor(countdownKey, red, green, blue, alpha)
    GetCountdownSettings(countdownKey).backgroundColor = CopyColor({
        r = red,
        g = green,
        b = blue,
        a = alpha or 1,
    })
    RefreshAfterSetting(countdownKey)
end

function UltimateCountdown.GetShapeChoices() return SHAPE_CHOICES end
function UltimateCountdown.GetShapeChoiceNames() return SHAPE_NAMES end
function UltimateCountdown.GetShape(countdownKey) return GetCountdownSettings(countdownKey).shape end
function UltimateCountdown.GetShapeDefault(countdownKey) return GetCountdownDefaults(countdownKey).shape end
function UltimateCountdown.SetShape(countdownKey, value)
    if SHAPE_VALID[value] ~= true then
        value = GetCountdownDefaults(countdownKey).shape
    end

    GetCountdownSettings(countdownKey).shape = value
    RefreshAfterSetting(countdownKey)
end

function UltimateCountdown.GetSecondsMin() return SECONDS_MIN end
function UltimateCountdown.GetSecondsMax() return SECONDS_MAX end
function UltimateCountdown.GetFontSizeMin() return FONT_SIZE_MIN end
function UltimateCountdown.GetFontSizeMax() return FONT_SIZE_MAX end
function UltimateCountdown.GetBackgroundOpacityMin() return BACKGROUND_OPACITY_MIN end
function UltimateCountdown.GetBackgroundOpacityMax() return BACKGROUND_OPACITY_MAX end

function UltimateCountdown.GetEntryLabel(countdownKey) return NQOL.L("features.ultimate_countdown.entry_label_dynamic", GetCountdownName(countdownKey)) end
function UltimateCountdown.GetEntryTooltip(countdownKey) return NQOL.L("features.ultimate_countdown.entry_tooltip", NQOL.Util.Lower(GetCountdownName(countdownKey))) end
function UltimateCountdown.GetEnabledLabel() return NQOL.L("features.ultimate_countdown.enabled_label") end
function UltimateCountdown.GetEnabledTooltip(countdownKey) return NQOL.L("features.ultimate_countdown.enabled_tooltip_dynamic", NQOL.Util.Lower(GetCountdownName(countdownKey))) end
function UltimateCountdown.GetSecondsLabel() return NQOL.L("features.ultimate_countdown.seconds_label") end
function UltimateCountdown.GetSecondsTooltip() return NQOL.L("features.ultimate_countdown.seconds_tooltip") end
function UltimateCountdown.GetShowInSettingsLabel() return NQOL.L("features.ultimate_countdown.show_in_settings_label") end
function UltimateCountdown.GetShowInSettingsTooltip(countdownKey) return NQOL.L("features.ultimate_countdown.show_tooltip_dynamic", NQOL.Util.Lower(GetCountdownName(countdownKey))) end
function UltimateCountdown.GetHorizontalPositionLabel() return NQOL.L("features.ultimate_countdown.horizontal_position_label") end
function UltimateCountdown.GetHorizontalPositionTooltip(countdownKey) return NQOL.L("features.ultimate_countdown.horizontal_tooltip_dynamic", NQOL.Util.Lower(GetCountdownName(countdownKey))) end
function UltimateCountdown.GetVerticalPositionLabel() return NQOL.L("features.ultimate_countdown.vertical_position_label") end
function UltimateCountdown.GetVerticalPositionTooltip(countdownKey) return NQOL.L("features.ultimate_countdown.vertical_tooltip_dynamic", NQOL.Util.Lower(GetCountdownName(countdownKey))) end
function UltimateCountdown.GetFontLabel() return NQOL.L("features.ultimate_countdown.font_label") end
function UltimateCountdown.GetFontTooltip() return NQOL.L("features.ultimate_countdown.font_tooltip") end
function UltimateCountdown.GetFontSizeLabel() return NQOL.L("features.ultimate_countdown.font_size_label") end
function UltimateCountdown.GetFontSizeTooltip() return NQOL.L("features.ultimate_countdown.font_size_tooltip") end
function UltimateCountdown.GetColorLabel() return NQOL.L("features.ultimate_countdown.color_label") end
function UltimateCountdown.GetColorTooltip() return NQOL.L("features.ultimate_countdown.color_tooltip") end
function UltimateCountdown.GetBackgroundOpacityLabel() return NQOL.L("features.ultimate_countdown.background_opacity_label") end
function UltimateCountdown.GetBackgroundOpacityTooltip() return NQOL.L("features.ultimate_countdown.background_opacity_tooltip") end
function UltimateCountdown.GetBackgroundColorLabel() return NQOL.L("features.ultimate_countdown.background_color_label") end
function UltimateCountdown.GetBackgroundColorTooltip() return NQOL.L("features.ultimate_countdown.background_color_tooltip") end
function UltimateCountdown.GetShapeLabel() return NQOL.L("features.ultimate_countdown.shape_label") end
function UltimateCountdown.GetShapeTooltip() return NQOL.L("features.ultimate_countdown.shape_tooltip") end

NQOL.Features.UltimateCountdown = UltimateCountdown
