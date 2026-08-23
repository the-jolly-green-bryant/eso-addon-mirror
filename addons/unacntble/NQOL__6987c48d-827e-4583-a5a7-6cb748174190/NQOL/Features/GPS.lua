NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local GPS = {}

local EVENT_NAMESPACE = "NQOL_GPS"
local UPDATE_INTERVAL_MIN_MS = 50
local UPDATE_INTERVAL_MAX_MS = 1000
local UPDATE_INTERVAL_STEP_MS = 50
local ADVANCED_QR_HEADING_SCALE = 1000
local TEXT_PADDING_X = 18
local TEXT_PADDING_Y = 12
local FONT_SIZE_MIN = 14
local FONT_SIZE_MAX = 72
local QR_SIZE_MIN = 100
local QR_SIZE_MAX = 600
local DRAW_LEVEL = 230
local GAMEPLAY_SCENES = {
    hud = true,
    hudui = true,
    siegeBar = true,
}
local FORMAT_CHOICES = { "qr", "text", "csv" }
local FORMAT_CHOICE_NAMES = NQOL.Lexicon.LocalizedList({
    "features.gps.format_qr",
    "features.gps.format_text",
    "features.gps.format_csv",
})
local VALID_FORMATS = { qr = true, text = true, csv = true }
local ORIENTATION_CHOICES = { "vertical", "horizontal" }
local ORIENTATION_CHOICE_NAMES = NQOL.Lexicon.LocalizedList({
    "features.gps.orientation_vertical",
    "features.gps.orientation_horizontal",
})
local VALID_ORIENTATIONS = { vertical = true, horizontal = true }

local defaults = {
    gps = {
        enabled = false,
        showInSettings = true,
        displayFormat = "text",
        advancedData = false,
        updateInterval = 1000,
        textOrientation = "horizontal",
        font = NQOL.Util.GetDefaultFont(),
        fontSize = 34,
        qrSize = 220,
        opacity = 100,
        color = { r = 0, g = 0, b = 0, a = 1 },
        horizontalPosition = 50,
        verticalPosition = 8,
    },
}

local savedVariables
local initialized = false
local settingsPanelVisible = false
local updateRegistered = false
local registeredUpdateInterval
local sceneCallbackInstalled = false
local control
local lastDisplayFormat
local lastDisplayValue
local lastRenderedCoordinates
local lastRawX
local lastRawY
local lastRawZ
local lastFormattedX
local lastFormattedY
local lastFormattedZ
local lastFormattedCSV
local lastPlayerHeading
local fontStringCache = {}
local layoutRefreshRevision = 0

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round
local StringFormat = string.format

local function NormalizeUpdateInterval(value)
    local interval = Clamp(tonumber(value) or defaults.gps.updateInterval, UPDATE_INTERVAL_MIN_MS, UPDATE_INTERVAL_MAX_MS)
    return Clamp(Round(interval / UPDATE_INTERVAL_STEP_MS) * UPDATE_INTERVAL_STEP_MS, UPDATE_INTERVAL_MIN_MS, UPDATE_INTERVAL_MAX_MS)
end

local function NormalizeColor(settings, defaultSettings, key)
    if type(settings[key]) ~= "table" then
        settings[key] = {}
    end

    local color = settings[key]
    local defaultColor = defaultSettings[key]
    color.r = Clamp(tonumber(color[1]) or tonumber(color.r) or defaultColor.r, 0, 1)
    color.g = Clamp(tonumber(color[2]) or tonumber(color.g) or defaultColor.g, 0, 1)
    color.b = Clamp(tonumber(color[3]) or tonumber(color.b) or defaultColor.b, 0, 1)
    color.a = Clamp(tonumber(color[4]) or tonumber(color.a) or defaultColor.a, 0, 1)
    color[1] = nil
    color[2] = nil
    color[3] = nil
    color[4] = nil
end

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "gps")
    local gpsDefaults = defaults.gps

    NQOL.Settings.Boolean(settings, gpsDefaults, "enabled")
    NQOL.Settings.Boolean(settings, gpsDefaults, "showInSettings")
    NQOL.Settings.Boolean(settings, gpsDefaults, "advancedData")
    NQOL.Settings.Choice(settings, gpsDefaults, "displayFormat", VALID_FORMATS)
    NQOL.Settings.ClampedNumber(settings, gpsDefaults, "updateInterval", UPDATE_INTERVAL_MIN_MS, UPDATE_INTERVAL_MAX_MS, true)
    settings.updateInterval = NormalizeUpdateInterval(settings.updateInterval)
    NQOL.Settings.Choice(settings, gpsDefaults, "textOrientation", VALID_ORIENTATIONS)
    NQOL.Settings.Default(settings, gpsDefaults, "font")
    if not NQOL.Util.IsFontChoice(settings.font) then
        settings.font = gpsDefaults.font
    end
    NQOL.Settings.ClampedNumber(settings, gpsDefaults, "fontSize", FONT_SIZE_MIN, FONT_SIZE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, gpsDefaults, "qrSize", QR_SIZE_MIN, QR_SIZE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, gpsDefaults, "opacity", 0, 100, true)
    NQOL.Settings.ClampedNumber(settings, gpsDefaults, "horizontalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, gpsDefaults, "verticalPosition", 0, 100)
    NormalizeColor(settings, gpsDefaults, "color")

    return settings
end

local function GetLibGPS()
    local library = _G.LibGPS3
    if type(library) ~= "table"
        or type(library.LocalToGlobal) ~= "function"
        or type(library.LocalToWorld) ~= "function"
    then
        return nil
    end
    return library
end

local function GetLibQRC()
    local library = _G.LibQRCode
    if type(library) ~= "table" or type(library.DrawQRCode) ~= "function" then
        return nil
    end
    return library
end

local function GetCurrentSceneName()
    if not SCENE_MANAGER then
        return nil
    end
    if SCENE_MANAGER.GetCurrentSceneName then
        return SCENE_MANAGER:GetCurrentSceneName()
    end
    local scene = SCENE_MANAGER.GetCurrentScene and SCENE_MANAGER:GetCurrentScene()
    return scene and scene.GetName and scene:GetName() or nil
end

local function IsGameplaySceneShowing()
    return not SCENE_MANAGER or GAMEPLAY_SCENES[GetCurrentSceneName()] == true
end

local function ShouldShow()
    if not GetLibGPS() then
        return false
    end
    if settingsPanelVisible then
        return GetSettings().showInSettings == true
    end
    local settings = GetSettings()
    if settings.enabled ~= true then
        return false
    end
    return IsGameplaySceneShowing()
        or (settings.displayFormat == "qr" and settings.advancedData == true)
end

local function EnsureControl()
    if control or not WINDOW_MANAGER or not GuiRoot then
        return control
    end

    local root = WINDOW_MANAGER:CreateTopLevelWindow("NQOLGPS")
    root:SetHidden(true)
    root:SetMouseEnabled(false)
    root:SetClampedToScreen(true)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetDrawLevel(DRAW_LEVEL)

    local background = WINDOW_MANAGER:CreateControl(nil, root, CT_BACKDROP)
    background:SetAnchorFill(root)
    background:SetCenterColor(1, 1, 1, 1)
    background:SetEdgeColor(0, 0, 0, 1)
    background:SetEdgeTexture("EsoUI/Art/Tooltips/Gamepad/gp_tooltip_edge.dds", 32, 4)

    local label = WINDOW_MANAGER:CreateControl(nil, root, CT_LABEL)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local qr = WINDOW_MANAGER:CreateControl("NQOLGPSQRCode", root, CT_TEXTURE)

    control = {
        root = root,
        background = background,
        label = label,
        qr = qr,
    }
    return control
end

local function ApplyPosition()
    local current = EnsureControl()
    if not current or not GuiRoot then
        return
    end

    local settings = GetSettings()
    local screenWidth = (GetScreenWidth and GetScreenWidth()) or (GuiRoot.GetWidth and GuiRoot:GetWidth()) or 1920
    local screenHeight = (GetScreenHeight and GetScreenHeight()) or (GuiRoot.GetHeight and GuiRoot:GetHeight()) or 1080
    local x = (screenWidth - current.root:GetWidth()) * (settings.horizontalPosition / 100)
    local y = (screenHeight - current.root:GetHeight()) * (settings.verticalPosition / 100)

    current.root:ClearAnchors()
    current.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

local function ApplyAppearance()
    local current = EnsureControl()
    if not current then
        return
    end

    local settings = GetSettings()
    local color = settings.color
    current.root:SetAlpha(settings.opacity / 100)
    current.label:SetColor(color.r, color.g, color.b, color.a)
    ApplyPosition()
end

local function ConvertPlayerPosition(library)
    if not DoesCurrentMapMatchMapForPlayerLocation or not DoesCurrentMapMatchMapForPlayerLocation() then
        SetMapToPlayerLocation()
    end
    local localX, localY, playerHeading = GetMapPlayerPosition("player")
    local globalX, globalY = library:LocalToGlobal(localX, localY)
    local _, worldZ = library:LocalToWorld(localX, localY)
    return globalX, globalY, worldZ, playerHeading
end

local function ReadGlobalPosition()
    local library = GetLibGPS()
    if not library or not GetMapPlayerPosition or not SetMapToPlayerLocation then
        return nil, nil, nil
    end
    if library.IsReady and not library:IsReady() then
        return nil, nil, nil
    end
    if library.IsMeasuring and library:IsMeasuring() then
        return nil, nil, nil
    end

    local success, globalX, globalY, worldZ, playerHeading =
        pcall(ConvertPlayerPosition, library)

    if not success
        or type(globalX) ~= "number"
        or type(globalY) ~= "number"
        or type(worldZ) ~= "number"
    then
        return nil, nil, nil
    end
    lastPlayerHeading = playerHeading
    return globalX, globalY, worldZ, playerHeading
end

local function FormatCoordinates(globalX, globalY, worldZ)
    if not globalX or not globalY or not worldZ then
        return nil, nil, nil, nil
    end
    if globalX == lastRawX and globalY == lastRawY and worldZ == lastRawZ then
        return lastFormattedX, lastFormattedY, lastFormattedZ, lastFormattedCSV
    end

    lastRawX = globalX
    lastRawY = globalY
    lastRawZ = worldZ
    lastFormattedX = StringFormat("%.6f", globalX)
    lastFormattedY = StringFormat("%.6f", globalY)
    lastFormattedZ = StringFormat("%.0f", worldZ)
    lastFormattedCSV = StringFormat("%s,%s,%s", lastFormattedX, lastFormattedY, lastFormattedZ)
    return lastFormattedX, lastFormattedY, lastFormattedZ, lastFormattedCSV
end

local function CollectAdvancedQRValue(playerHeading)
    local zoneId, worldX, worldY, worldZ = GetUnitWorldPosition("player")
    local cameraHeading = GetPlayerCameraHeading()

    if type(zoneId) ~= "number"
        or type(worldX) ~= "number"
        or type(worldY) ~= "number"
        or type(worldZ) ~= "number"
        or type(playerHeading) ~= "number"
        or type(cameraHeading) ~= "number"
    then
        return nil
    end

    local encoder = NQOL.GPSAdvancedData
    if type(encoder) ~= "table" or type(encoder.BuildPayload) ~= "function" then
        return nil
    end
    return encoder.BuildPayload(
        zoneId,
        worldX,
        worldY,
        worldZ,
        Round(playerHeading * ADVANCED_QR_HEADING_SCALE),
        Round(cameraHeading * ADVANCED_QR_HEADING_SCALE)
    )
end

local function BuildAdvancedQRValue(playerHeading)
    if type(GetUnitWorldPosition) ~= "function"
        or type(GetPlayerCameraHeading) ~= "function"
    then
        return nil
    end

    local success, value = pcall(CollectAdvancedQRValue, playerHeading)
    return success and value or nil
end

local function GetFont()
    local settings = GetSettings()
    local key = tostring(settings.font) .. ":" .. tostring(settings.fontSize)
    if not fontStringCache[key] then
        fontStringCache[key] = NQOL.Util.CreateFontString(settings.font, settings.fontSize, "ZoFontGamepad34")
    end
    return fontStringCache[key]
end

local function ApplyText(text)
    local current = EnsureControl()
    if not current then
        return
    end

    current.qr:SetHidden(true)
    current.label:SetHidden(false)
    current.label:SetFont(GetFont())
    current.label:SetText("")
    current.label:ClearAnchors()
    current.label:SetDimensions(0, 0)
    current.label:SetDimensions(4096, 600)
    current.label:SetText(text)

    local measuredWidth
    local measuredHeight
    if current.label.GetTextDimensions then
        measuredWidth, measuredHeight = current.label:GetTextDimensions()
    else
        measuredWidth = current.label.GetTextWidth and current.label:GetTextWidth() or 0
        measuredHeight = current.label.GetTextHeight and current.label:GetTextHeight() or 0
    end
    local width = math.ceil(measuredWidth or 0) + (TEXT_PADDING_X * 2)
    local height = math.ceil(measuredHeight or 0) + (TEXT_PADDING_Y * 2)
    current.root:SetDimensions(width, height)
    current.label:ClearAnchors()
    current.label:SetAnchor(TOPLEFT, current.root, TOPLEFT, TEXT_PADDING_X, TEXT_PADDING_Y)
    current.label:SetDimensions(math.ceil(measuredWidth or 0), math.ceil(measuredHeight or 0))
end

local function DrawQRCode(library, qrControl, csvValue)
    library.DrawQRCode(qrControl, csvValue)
end

local function ApplyQRCode(csvValue)
    local current = EnsureControl()
    local library = GetLibQRC()
    if not current or not library then
        return false
    end

    current.label:SetHidden(true)
    current.qr:SetHidden(false)
    local qrSize = GetSettings().qrSize
    current.root:SetDimensions(qrSize, qrSize)
    current.qr:SetDimensions(qrSize, qrSize)
    current.qr:ClearAnchors()
    current.qr:SetAnchorFill(current.root)

    local success = pcall(DrawQRCode, library, current.qr, csvValue)
    if not success then
        return false
    end

    local composite = current.qrComposite or WINDOW_MANAGER:GetControlByName("NQOLGPSQRCodeQRComposite")
    current.qrComposite = composite
    local color = GetSettings().color
    if composite and composite.GetNumSurfaces and composite.SetColor then
        for surfaceIndex = 1, composite:GetNumSurfaces() do
            composite:SetColor(surfaceIndex, color.r, color.g, color.b, color.a)
        end
    end
    return true
end

local function Hide()
    if control and control.root then
        control.root:SetHidden(true)
    end
end

local function RefreshDisplay(force)
    if not ShouldShow() then
        Hide()
        return
    end

    local settings = GetSettings()
    local usesAdvancedQR = settings.displayFormat == "qr" and settings.advancedData
    local xText, yText, zText, csvValue, playerHeading
    if usesAdvancedQR and not IsGameplaySceneShowing() and lastFormattedCSV then
        xText, yText, zText, csvValue, playerHeading =
            lastFormattedX, lastFormattedY, lastFormattedZ, lastFormattedCSV, lastPlayerHeading
    else
        local globalX, globalY, worldZ
        globalX, globalY, worldZ, playerHeading = ReadGlobalPosition()
        xText, yText, zText, csvValue = FormatCoordinates(globalX, globalY, worldZ)
    end
    if not force and csvValue and csvValue == lastRenderedCoordinates and not usesAdvancedQR then
        return
    end
    local displayFormat = settings.displayFormat
    local displayValue

    if not csvValue then
        displayFormat = "message"
        displayValue = NQOL.L("features.gps.location_unavailable")
    elseif displayFormat == "text" then
        if settings.textOrientation == "vertical" then
            displayValue = StringFormat("%s\n%s\n%s",
                NQOL.L("features.gps.coordinate_x_format", xText),
                NQOL.L("features.gps.coordinate_y_format", yText),
                NQOL.L("features.gps.coordinate_z_format", zText)
            )
        else
            displayValue = NQOL.L("features.gps.plain_text_horizontal_format", xText, yText, zText)
        end
    elseif displayFormat == "csv" then
        displayValue = csvValue
    elseif not GetLibQRC() then
        displayFormat = "message"
        displayValue = NQOL.L("features.gps.unavailable_libqrcode")
    else
        displayValue = settings.advancedData
            and BuildAdvancedQRValue(playerHeading)
            or csvValue
        if not displayValue then
            displayFormat = "message"
            displayValue = NQOL.L("features.gps.advanced_data_unavailable")
        end
    end

    if force or displayFormat ~= lastDisplayFormat or displayValue ~= lastDisplayValue then
        if displayFormat ~= "qr" or not ApplyQRCode(displayValue) then
            ApplyText(displayFormat == "qr" and NQOL.L("features.gps.qr_render_failed") or displayValue)
        end
        lastDisplayFormat = displayFormat
        lastDisplayValue = displayValue
        lastRenderedCoordinates = csvValue
    end

    ApplyAppearance()
    EnsureControl().root:SetHidden(false)
end

local function OnUpdate()
    RefreshDisplay(false)
end

local function UpdateRuntime()
    local active = initialized and ShouldShow()
    if active and EVENT_MANAGER then
        local updateInterval = GetSettings().updateInterval
        if not updateRegistered or registeredUpdateInterval ~= updateInterval then
            if updateRegistered then
                EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
            end
            EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE, updateInterval, OnUpdate)
            updateRegistered = true
            registeredUpdateInterval = updateInterval
        end
    elseif not active and updateRegistered and EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
        updateRegistered = false
        registeredUpdateInterval = nil
    end

    if active then
        RefreshDisplay(true)
    else
        Hide()
    end
end

local function InstallSceneCallbacks()
    if sceneCallbackInstalled then
        return
    end
    sceneCallbackInstalled = true
    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", UpdateRuntime)
    end
    if EVENT_MANAGER and EVENT_SCREEN_RESIZED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_ScreenResized", EVENT_SCREEN_RESIZED, function()
            ApplyPosition()
        end)
    end
end

local function InvalidateDisplayCache()
    lastDisplayFormat = nil
    lastDisplayValue = nil
    lastRenderedCoordinates = nil
end

local function RefreshAfterSetting()
    InvalidateDisplayCache()
    UpdateRuntime()
end

local function RefreshAfterLayoutSetting()
    layoutRefreshRevision = layoutRefreshRevision + 1
    local refreshRevision = layoutRefreshRevision

    RefreshAfterSetting()

    if type(zo_callLater) == "function" then
        zo_callLater(function()
            if refreshRevision ~= layoutRefreshRevision then
                return
            end

            InvalidateDisplayCache()
            UpdateRuntime()
        end, 0)
    end
end

function GPS.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function GPS.Initialize()
    if initialized then
        UpdateRuntime()
        return
    end
    initialized = true
    if NQOL.GPSAdvancedData and NQOL.GPSAdvancedData.Initialize then
        NQOL.GPSAdvancedData.Initialize()
    end
    InstallSceneCallbacks()
    UpdateRuntime()
end

function GPS.SetSettingsPanelVisible(value)
    settingsPanelVisible = value == true
    UpdateRuntime()
end

function GPS.IsAvailable()
    return GetLibGPS() ~= nil
end

function GPS.IsQRCAvailable()
    return GetLibQRC() ~= nil
end

function GPS.GetCoordinateValues()
    local xText, yText, zText = FormatCoordinates(ReadGlobalPosition())
    return xText, yText, zText
end

function GPS.GetQRPayload()
    local globalX, globalY, worldZ, playerHeading = ReadGlobalPosition()
    local _, _, _, csvValue = FormatCoordinates(globalX, globalY, worldZ)
    if not csvValue or not GetSettings().advancedData then
        return csvValue
    end
    return BuildAdvancedQRValue(playerHeading)
end

function GPS.GetEnabled()
    return GPS.IsAvailable() and GetSettings().enabled
end

function GPS.GetEnabledDefault()
    return defaults.gps.enabled
end

function GPS.SetEnabled(value)
    GetSettings().enabled = value == true and GPS.IsAvailable()
    UpdateRuntime()
end

function GPS.GetShowInSettings()
    return GetSettings().showInSettings
end

function GPS.GetShowInSettingsDefault()
    return defaults.gps.showInSettings
end

function GPS.SetShowInSettings(value)
    GetSettings().showInSettings = value == true
    UpdateRuntime()
end

function GPS.GetDisplayFormat()
    return GetSettings().displayFormat
end

function GPS.GetDisplayFormatDefault()
    return defaults.gps.displayFormat
end

function GPS.SetDisplayFormat(value)
    GetSettings().displayFormat = VALID_FORMATS[value] and value or defaults.gps.displayFormat
    RefreshAfterLayoutSetting()
end

function GPS.GetDisplayFormatChoices()
    return FORMAT_CHOICES
end

function GPS.GetDisplayFormatChoiceNames()
    return FORMAT_CHOICE_NAMES
end

function GPS.GetAdvancedData()
    return GetSettings().advancedData
end

function GPS.GetAdvancedDataDefault()
    return defaults.gps.advancedData
end

function GPS.SetAdvancedData(value)
    GetSettings().advancedData = value == true
    RefreshAfterSetting()
end

function GPS.GetUpdateFrequency()
    return GetSettings().updateInterval
end

function GPS.GetUpdateFrequencyDefault()
    return defaults.gps.updateInterval
end

function GPS.SetUpdateFrequency(value)
    GetSettings().updateInterval = NormalizeUpdateInterval(value)
    UpdateRuntime()
end

function GPS.GetUpdateFrequencyMin() return UPDATE_INTERVAL_MIN_MS end
function GPS.GetUpdateFrequencyMax() return UPDATE_INTERVAL_MAX_MS end
function GPS.GetUpdateFrequencyStep() return UPDATE_INTERVAL_STEP_MS end

function GPS.GetTextOrientation()
    return GetSettings().textOrientation
end

function GPS.GetTextOrientationDefault()
    return defaults.gps.textOrientation
end

function GPS.SetTextOrientation(value)
    GetSettings().textOrientation = VALID_ORIENTATIONS[value] and value or defaults.gps.textOrientation
    RefreshAfterLayoutSetting()
end

function GPS.GetTextOrientationChoices()
    return ORIENTATION_CHOICES
end

function GPS.GetTextOrientationChoiceNames()
    return ORIENTATION_CHOICE_NAMES
end

function GPS.GetFont()
    return GetSettings().font
end

function GPS.SetFont(value)
    GetSettings().font = NQOL.Util.IsFontChoice(value) and value or defaults.gps.font
    RefreshAfterLayoutSetting()
end

function GPS.GetFontChoices()
    return NQOL.Util.GetFontChoices()
end

function GPS.GetFontChoiceNames()
    return NQOL.Util.GetFontChoiceNames()
end

function GPS.GetFontSize()
    return GetSettings().fontSize
end

function GPS.GetFontSizeDefault()
    return defaults.gps.fontSize
end

function GPS.SetFontSize(value)
    GetSettings().fontSize = Clamp(Round(value), FONT_SIZE_MIN, FONT_SIZE_MAX)
    RefreshAfterLayoutSetting()
end

function GPS.GetFontSizeMin() return FONT_SIZE_MIN end
function GPS.GetFontSizeMax() return FONT_SIZE_MAX end

function GPS.GetQRCodeSize()
    return GetSettings().qrSize
end

function GPS.GetQRCodeSizeDefault()
    return defaults.gps.qrSize
end

function GPS.SetQRCodeSize(value)
    GetSettings().qrSize = Clamp(Round(value), QR_SIZE_MIN, QR_SIZE_MAX)
    RefreshAfterLayoutSetting()
end

function GPS.GetQRCodeSizeMin() return QR_SIZE_MIN end
function GPS.GetQRCodeSizeMax() return QR_SIZE_MAX end

function GPS.GetOpacity()
    return GetSettings().opacity
end

function GPS.GetOpacityDefault()
    return defaults.gps.opacity
end

function GPS.SetOpacity(value)
    GetSettings().opacity = Clamp(Round(value), 0, 100)
    RefreshAfterSetting()
end

function GPS.GetColor()
    local color = GetSettings().color
    return color.r, color.g, color.b, color.a
end

function GPS.SetColor(red, green, blue, alpha)
    local color = GetSettings().color
    color.r = Clamp(tonumber(red) or defaults.gps.color.r, 0, 1)
    color.g = Clamp(tonumber(green) or defaults.gps.color.g, 0, 1)
    color.b = Clamp(tonumber(blue) or defaults.gps.color.b, 0, 1)
    color.a = Clamp(tonumber(alpha) or defaults.gps.color.a, 0, 1)
    RefreshAfterSetting()
end

function GPS.GetHorizontalPosition()
    return GetSettings().horizontalPosition
end

function GPS.GetHorizontalPositionDefault()
    return defaults.gps.horizontalPosition
end

function GPS.SetHorizontalPosition(value)
    GetSettings().horizontalPosition = Clamp(tonumber(value) or defaults.gps.horizontalPosition, 0, 100)
    ApplyPosition()
end

function GPS.GetVerticalPosition()
    return GetSettings().verticalPosition
end

function GPS.GetVerticalPositionDefault()
    return defaults.gps.verticalPosition
end

function GPS.SetVerticalPosition(value)
    GetSettings().verticalPosition = Clamp(tonumber(value) or defaults.gps.verticalPosition, 0, 100)
    ApplyPosition()
end

function GPS.GetName() return NQOL.L("features.gps.name") end
function GPS.GetEntryTooltip()
    if not GPS.IsAvailable() then
        return NQOL.L("features.gps.unavailable_libgps")
    end
    return NQOL.L("features.gps.entry_tooltip")
end
function GPS.GetEnabledLabel() return NQOL.L("features.gps.enabled_label") end
function GPS.GetEnabledTooltip()
    if not GPS.IsAvailable() then
        return NQOL.L("features.gps.unavailable_libgps")
    end
    return NQOL.L("features.gps.enabled_tooltip")
end
function GPS.GetShowInSettingsLabel() return NQOL.L("features.gps.show_in_settings_label") end
function GPS.GetShowInSettingsTooltip() return NQOL.L("features.gps.show_in_settings_tooltip") end
function GPS.GetDisplayFormatLabel() return NQOL.L("features.gps.display_format_label") end
function GPS.GetDisplayFormatTooltip() return NQOL.L("features.gps.display_format_tooltip") end
function GPS.GetUpdateFrequencyLabel() return NQOL.L("features.gps.update_frequency_label") end
function GPS.GetUpdateFrequencyTooltip() return NQOL.L("features.gps.update_frequency_tooltip") end
function GPS.GetUpdateFrequencyValueFormat() return NQOL.L("features.gps.update_frequency_value_format") end
function GPS.GetTextSectionLabel() return NQOL.L("features.gps.section_text") end
function GPS.GetTextOrientationLabel() return NQOL.L("features.gps.orientation_label") end
function GPS.GetTextOrientationTooltip() return NQOL.L("features.gps.orientation_tooltip") end
function GPS.GetFontLabel() return NQOL.L("features.gps.font_label") end
function GPS.GetFontTooltip() return NQOL.L("features.gps.font_tooltip") end
function GPS.GetFontSizeLabel() return NQOL.L("features.gps.font_size_label") end
function GPS.GetFontSizeTooltip() return NQOL.L("features.gps.font_size_tooltip") end
function GPS.GetQRCodeSectionLabel() return NQOL.L("features.gps.section_qr_code") end
function GPS.GetAdvancedDataLabel() return NQOL.L("features.gps.advanced_data_label") end
function GPS.GetAdvancedDataTooltip() return NQOL.L("features.gps.advanced_data_tooltip") end
function GPS.GetQRCodeSizeLabel() return NQOL.L("features.gps.qr_size_label") end
function GPS.GetQRCodeSizeTooltip() return NQOL.L("features.gps.qr_size_tooltip") end
function GPS.GetOpacityLabel() return NQOL.L("features.gps.opacity_label") end
function GPS.GetOpacityTooltip() return NQOL.L("features.gps.opacity_tooltip") end
function GPS.GetColorLabel() return NQOL.L("features.gps.color_label") end
function GPS.GetColorTooltip() return NQOL.L("features.gps.color_tooltip") end
function GPS.GetHorizontalPositionLabel() return NQOL.L("features.gps.horizontal_position_label") end
function GPS.GetHorizontalPositionTooltip() return NQOL.L("features.gps.horizontal_position_tooltip") end
function GPS.GetVerticalPositionLabel() return NQOL.L("features.gps.vertical_position_label") end
function GPS.GetVerticalPositionTooltip() return NQOL.L("features.gps.vertical_position_tooltip") end

NQOL.Features.GPS = GPS
