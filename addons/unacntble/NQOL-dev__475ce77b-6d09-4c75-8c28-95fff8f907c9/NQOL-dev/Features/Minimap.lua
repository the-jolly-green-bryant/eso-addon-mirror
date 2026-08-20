NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Minimap = {}

local defaults = {
    minimap = {
        enabled = false,
        showInCombat = false,
        showInSettings = true,
        updateFrequency = "normal",
        harvestMapCompatibility = false,
        horizontalPosition = 99,
        verticalPosition = 10,
        size = 350,
        borderSize = 2,
        borderColor = { 0.5, 0.35, 0, 1 },
        zoneZoom = 100,
        subzoneZoom = 100,
        dungeonZoom = 100,
        mountedZoom = 100,
        zonePlayerPinScale = 100,
        subzonePlayerPinScale = 100,
        dungeonPlayerPinScale = 100,
        mountedPlayerPinScale = 100,
        areaLabelPosition = "right",
        areaLabelFont = NQOL.Util.GetDefaultFont(),
        areaLabelSize = 22,
        wayshrineWayfinder = {
            enabled = false,
            thickness = 5,
            color = { 1, 1, 0, 1 },
        },
    },
}

local UPDATE_NAME = "NQOL_MinimapUpdate"
local MAP_CHECK_INTERVAL_MS = 1000
local VIEW_WIDTH = 360
local VIEW_HEIGHT = 360
local MAP_CONTENT_SIZE = 900
local VIEW_SIZE_MIN = 128
local VIEW_SIZE_MAX = 512
local ZOOM_MIN = 40
local ZOOM_MAX = 300
local PIN_SCALE_FULL_ZOOM = 300
local PLAYER_PIN_SCALE_MIN = 40
local PLAYER_PIN_SCALE_MAX = 200
local AREA_LABEL_SIZE_MIN = 18
local AREA_LABEL_SIZE_MAX = 54
local BORDER_SIZE_MIN = 0
local BORDER_SIZE_MAX = 6
local BORDER_DRAW_LEVEL = 250
local ROUTE_DOT_SPACING = 14
local WAYFINDER_THICKNESS_MIN = 1
local WAYFINDER_THICKNESS_MAX = 10
local OFFSET_CHANGE_EPSILON = 0.01
local PIN_CHANGE_EPSILON = 0.000001
local GAMEPLAY_SCENES = { hud = true, hudui = true }
local UPDATE_FREQUENCY_CHOICES = { "fastest", "fast", "normal", "slow", "slowest" }
local UPDATE_FREQUENCY_CHOICE_NAMES = NQOL.Lexicon.LocalizedList({
    "features.minimap.frequency_fastest",
    "features.minimap.frequency_fast",
    "features.minimap.frequency_normal",
    "features.minimap.frequency_slow",
    "features.minimap.frequency_slowest",
})
local UPDATE_FREQUENCY_INTERVALS = { fastest = 33, fast = 50, normal = 100, slow = 200, slowest = 300 }
local AREA_LABEL_POSITIONS = { "left", "center", "right", "off" }
local AREA_LABEL_POSITION_NAMES = NQOL.Lexicon.LocalizedList({
    "features.minimap.area_left",
    "features.minimap.area_center",
    "features.minimap.area_right",
    "features.minimap.area_hidden",
})
local VALID_AREA_LABEL_POSITIONS = { left = true, center = true, right = true, off = true }

local savedVariables
local viewport
local viewportFragment
local borderOverlay
local borderTextures = {}
local routeDots = {}
local areaLabel
local pinManager
local initialized = false
local runtimeRegistered = false
local sceneCallbackInstalled = false
local gameplayFragmentInstalled = false
local settingsFragmentInstalled = false
local containerAttached = false
local worldMapShowing = false
local lastMapCheckMs = 0
local containerRestore
local activeZoom
local settingsPanelVisible = false
local mounted = false
local inCombat = false
local pinSizeHookInstalled = false
local nativeMapResizeGuardInstalled = false
local nearestWayshrineX
local nearestWayshrineY
local currentOffsetX
local currentOffsetY
local startOffsetX
local startOffsetY
local targetOffsetX
local targetOffsetY
local currentPlayerPinX
local currentPlayerPinY
local startPlayerPinX
local startPlayerPinY
local targetPlayerPinX
local targetPlayerPinY
local interpolationStartMs = 0
local OnViewportUpdate
local activeUpdateIntervalMs = 100
local viewportUpdateActive = false
local routeNeedsRefresh = false
local lastAppliedOffsetX
local lastAppliedOffsetY
local lastAppliedPlayerPinControl
local lastAppliedPlayerPinX
local lastAppliedPlayerPinY
local ownsHarvestMapCompatibility = false
local ownsHarvestMapMode = false
local disabledByVotan = false
local cachedSettings
local ownedMinimapDrawOrders = setmetatable({}, { __mode = "k" })

local function NormalizeSettings(settings)
    NQOL.Settings.Boolean(settings, defaults.minimap, "enabled")
    NQOL.Settings.Boolean(settings, defaults.minimap, "showInCombat")
    NQOL.Settings.Boolean(settings, defaults.minimap, "showInSettings")
    NQOL.Settings.Boolean(settings, defaults.minimap, "harvestMapCompatibility")
    NQOL.Settings.Default(settings, defaults.minimap, "updateFrequency")
    NQOL.Settings.ClampedNumber(settings, defaults.minimap, "horizontalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, defaults.minimap, "verticalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, defaults.minimap, "size", VIEW_SIZE_MIN, VIEW_SIZE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.minimap, "borderSize", BORDER_SIZE_MIN, BORDER_SIZE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.minimap, "zoneZoom", ZOOM_MIN, ZOOM_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.minimap, "subzoneZoom", ZOOM_MIN, ZOOM_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.minimap, "dungeonZoom", ZOOM_MIN, ZOOM_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.minimap, "mountedZoom", ZOOM_MIN, ZOOM_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.minimap, "zonePlayerPinScale", PLAYER_PIN_SCALE_MIN, PLAYER_PIN_SCALE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.minimap, "subzonePlayerPinScale", PLAYER_PIN_SCALE_MIN, PLAYER_PIN_SCALE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.minimap, "dungeonPlayerPinScale", PLAYER_PIN_SCALE_MIN, PLAYER_PIN_SCALE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.minimap, "mountedPlayerPinScale", PLAYER_PIN_SCALE_MIN, PLAYER_PIN_SCALE_MAX, true)
    settings.onFootZoom = nil
    NQOL.Settings.ClampedNumber(settings, defaults.minimap, "areaLabelSize", AREA_LABEL_SIZE_MIN, AREA_LABEL_SIZE_MAX, true)
    local wayfinder = NQOL.Settings.EnsureTable(settings, "wayshrineWayfinder")
    NQOL.Settings.Boolean(wayfinder, defaults.minimap.wayshrineWayfinder, "enabled")
    NQOL.Settings.ClampedNumber(wayfinder, defaults.minimap.wayshrineWayfinder, "thickness", WAYFINDER_THICKNESS_MIN, WAYFINDER_THICKNESS_MAX, true)
    if not VALID_AREA_LABEL_POSITIONS[settings.areaLabelPosition] then
        settings.areaLabelPosition = defaults.minimap.areaLabelPosition
    end
    if not UPDATE_FREQUENCY_INTERVALS[settings.updateFrequency] then
        settings.updateFrequency = defaults.minimap.updateFrequency
    end
    if not NQOL.Util.IsFontChoice(settings.areaLabelFont) then
        settings.areaLabelFont = defaults.minimap.areaLabelFont
    end
    if type(settings.borderColor) ~= "table" then
        settings.borderColor = { 0.5, 0.35, 0, 1 }
    end
    for index = 1, 4 do
        settings.borderColor[index] = NQOL.Util.Clamp(settings.borderColor[index] or defaults.minimap.borderColor[index], 0, 1)
    end
    if type(wayfinder.color) ~= "table" then
        wayfinder.color = { 1, 1, 0, 1 }
    end
    for index = 1, 4 do
        wayfinder.color[index] = NQOL.Util.Clamp(wayfinder.color[index] or defaults.minimap.wayshrineWayfinder.color[index], 0, 1)
    end
end

local function GetSettings()
    if cachedSettings then
        return cachedSettings
    end

    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "minimap")
    NormalizeSettings(settings)
    if savedVariables then
        cachedSettings = settings
    end
    return settings
end

local function ApplyBorder()
    if not borderTextures[1] then
        return
    end

    local settings = GetSettings()
    local color = settings.borderColor
    local hidden = settings.borderSize <= 0
    for _, border in ipairs(borderTextures) do
        border:SetCenterColor(color[1], color[2], color[3], color[4])
        border:SetHidden(hidden)
    end
    borderTextures[1]:SetHeight(settings.borderSize)
    borderTextures[2]:SetHeight(settings.borderSize)
    borderTextures[3]:SetWidth(settings.borderSize)
    borderTextures[4]:SetWidth(settings.borderSize)
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
    return GAMEPLAY_SCENES[GetCurrentSceneName()] == true
end

local function IsSettingsPreviewShowing()
    return settingsPanelVisible
        and GAMEPAD_OPTIONS_PANEL_SCENE
        and GAMEPAD_OPTIONS_PANEL_SCENE:IsShowing()
end

local function ShouldShowGameplayMinimap()
    local settings = GetSettings()
    return settings.enabled and (settings.showInCombat or not inCombat)
end

local function ShouldShowSettingsPreview()
    return settingsPanelVisible and GetSettings().showInSettings
end

local function ShouldShowMinimap()
    if IsSettingsPreviewShowing() then
        return ShouldShowSettingsPreview()
    end
    return IsGameplaySceneShowing() and ShouldShowGameplayMinimap()
end

local function GetViewSize()
    return GetSettings().size
end

local function GetUpdateIntervalMs()
    return UPDATE_FREQUENCY_INTERVALS[GetSettings().updateFrequency]
end

local function GetActiveZoom()
    local settings = GetSettings()
    if mounted then
        return settings.mountedZoom
    end
    if IsUnitInDungeon("player") then
        return settings.dungeonZoom
    end
    if GetMapType() == MAPTYPE_SUBZONE then
        return settings.subzoneZoom
    end
    return settings.zoneZoom
end

local function GetMapContentSize()
    return math.max(MAP_CONTENT_SIZE * GetActiveZoom() / 100, GetViewSize())
end

local function GetActivePlayerPinScale()
    local settings = GetSettings()
    if mounted then
        return settings.mountedPlayerPinScale
    end
    if IsUnitInDungeon("player") then
        return settings.dungeonPlayerPinScale
    end
    if GetMapType() == MAPTYPE_SUBZONE then
        return settings.subzonePlayerPinScale
    end
    return settings.zonePlayerPinScale
end

local function RegisterOwnedMinimapControl(control)
    ownedMinimapDrawOrders[control] = {
        layer = control:GetDrawLayer(),
        tier = control:GetDrawTier(),
    }
end

local function ApplyOwnedMinimapControlDrawOrder(control)
    local drawOrder = ownedMinimapDrawOrders[control]
    if not drawOrder then
        return
    end

    if IsSettingsPreviewShowing() then
        control:SetDrawLayer(drawOrder.layer)
        control:SetDrawTier(drawOrder.tier)
    else
        control:SetDrawLayer(DL_BACKGROUND)
        control:SetDrawTier(control == areaLabel and DT_HIGH or DT_LOW)
    end
end

local function ApplyOwnedMinimapDrawOrder()
    for control in pairs(ownedMinimapDrawOrders) do
        ApplyOwnedMinimapControlDrawOrder(control)
    end
end

local function ApplyCurrentMinimapDrawOrder()
    ApplyOwnedMinimapDrawOrder()
end

local function ApplyMinimapPinScale(pin)
    if not containerAttached or not pin then
        return
    end

    local control = pin:GetControl()
    if not control then
        return
    end
    if (pin.radius and pin.radius > 0) or pin.polygonBlob then
        return
    end

    local width, height = control:GetDimensions()
    local scale
    if pinManager and pin == pinManager:GetPlayerPin() then
        scale = GetActivePlayerPinScale() / 100
    else
        local effectiveZoom = GetMapContentSize() / MAP_CONTENT_SIZE * 100
        scale = NQOL.Util.Clamp(effectiveZoom / PIN_SCALE_FULL_ZOOM, ZOOM_MIN / PIN_SCALE_FULL_ZOOM, 1)
    end
    control:SetDimensions(width * scale, height * scale)
end

local function InstallPinSizeHook()
    if pinSizeHookInstalled or not ZO_MapPin or not SecurePostHook then
        return
    end

    pinSizeHookInstalled = true
    SecurePostHook(ZO_MapPin, "UpdateSize", ApplyMinimapPinScale)
end

local function InstallNativeMapResizeGuard()
    if nativeMapResizeGuardInstalled
        or not ZO_PreHook
        or not WORLD_MAP_MANAGER
        or type(WORLD_MAP_MANAGER.ResizeAndReanchorMap) ~= "function"
    then
        return
    end

    nativeMapResizeGuardInstalled = true
    -- Native map refreshes target the full world-map window. While its container
    -- belongs to the minimap, NQOL applies the final dimensions itself.
    ZO_PreHook(WORLD_MAP_MANAGER, "ResizeAndReanchorMap", function()
        return containerAttached
    end)
end

local function RefreshPlayerPinSize()
    if not containerAttached or not pinManager then
        return
    end

    local playerPin = pinManager:GetPlayerPin()
    if playerPin then
        playerPin:UpdateSize()
    end
end

local function GetHarvestMapPinScale()
    local effectiveZoom = GetMapContentSize() / MAP_CONTENT_SIZE * 100
    return NQOL.Util.Clamp(effectiveZoom / PIN_SCALE_FULL_ZOOM, ZOOM_MIN / PIN_SCALE_FULL_ZOOM, 1)
end

local function UpdateHarvestMapCompatibility()
    local shouldActivate = GetSettings().harvestMapCompatibility and containerAttached
    if shouldActivate then
        if not VOTANS_MINIMAP then
            VOTANS_MINIMAP = {
                name = "NQOL_Minimap",
                CalculateScale = function()
                    return GetHarvestMapPinScale()
                end,
            }
            ownsHarvestMapCompatibility = true
        end
        if ownsHarvestMapCompatibility then
            VOTANS_MINIMAP.scale = GetHarvestMapPinScale()
            VOTANS_MINIMAP.limitedScale = VOTANS_MINIMAP.scale
        end
        if not MAP_MODE_VOTANS_MINIMAP then
            MAP_MODE_VOTANS_MINIMAP = MAP_MODE_LARGE_CUSTOM
            ownsHarvestMapMode = true
        end
        return
    end

    if ownsHarvestMapCompatibility and VOTANS_MINIMAP and VOTANS_MINIMAP.name == "NQOL_Minimap" then
        VOTANS_MINIMAP = nil
    end
    if ownsHarvestMapMode and MAP_MODE_VOTANS_MINIMAP == MAP_MODE_LARGE_CUSTOM then
        MAP_MODE_VOTANS_MINIMAP = nil
    end
    ownsHarvestMapCompatibility = false
    ownsHarvestMapMode = false
end

local function GetCurrentAreaName()
    local areaName = GetPlayerLocationName and GetPlayerLocationName() or ""
    local zoneName = GetPlayerActiveZoneName and GetPlayerActiveZoneName() or ""
    if areaName == "" and GetPlayerActiveSubzoneName then
        areaName = GetPlayerActiveSubzoneName() or ""
    end
    if zo_strformat then
        areaName = zo_strformat("<<C:1>>", areaName)
        zoneName = zo_strformat("<<C:1>>", zoneName)
    end
    if areaName ~= "" and zoneName ~= "" and areaName ~= zoneName then
        return string.format("%s - %s", areaName, zoneName)
    end
    return areaName ~= "" and areaName or zoneName
end

local function ApplyViewportLayout()
    if not viewport then
        return
    end

    local settings = GetSettings()
    local size = settings.size
    local screenWidth = GuiRoot:GetWidth()
    local screenHeight = GuiRoot:GetHeight()
    local x = (screenWidth - size) * settings.horizontalPosition / 100
    local y = (screenHeight - size) * settings.verticalPosition / 100
    viewport:SetDimensions(size, size)
    viewport:ClearAnchors()
    viewport:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    if borderOverlay then
        borderOverlay:SetDimensions(size, size)
        borderOverlay:ClearAnchors()
        borderOverlay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    end

    areaLabel:SetFont(NQOL.Util.CreateFontString(settings.areaLabelFont, settings.areaLabelSize, "ZoFontGamepad27"))
    areaLabel:SetDimensions(size - 16, settings.areaLabelSize + 8)
    local areaName = GetCurrentAreaName()
    areaLabel:SetText(areaName)
    areaLabel:ClearAnchors()
    if settings.areaLabelPosition == "left" then
        areaLabel:SetAnchor(TOPLEFT, viewport, TOPLEFT, 8, 8)
        areaLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    elseif settings.areaLabelPosition == "right" then
        areaLabel:SetAnchor(TOPRIGHT, viewport, TOPRIGHT, -8, 8)
        areaLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    else
        areaLabel:SetAnchor(TOP, viewport, TOP, 0, 8)
        areaLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end
    areaLabel:SetHidden(settings.areaLabelPosition == "off" or areaName == "")
end

local function StopUpdating()
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
end

local function SetViewportUpdateActive(active)
    active = active == true
    if not viewport or viewportUpdateActive == active then
        return
    end

    viewportUpdateActive = active
    viewport:SetHandler("OnUpdate", active and OnViewportUpdate or nil)
end

local function SetViewportHidden(hidden)
    viewport:SetHidden(hidden)
    if hidden then
        SetViewportUpdateActive(false)
    end
    if borderOverlay then
        borderOverlay:SetHidden(hidden)
    end
end

local function ApplyContainerOffset(offsetX, offsetY)
    if lastAppliedOffsetX == offsetX and lastAppliedOffsetY == offsetY then
        return
    end

    ZO_WorldMapContainer:ClearAnchors()
    ZO_WorldMapContainer:SetAnchor(TOPLEFT, viewport, TOPLEFT, offsetX, offsetY)
    lastAppliedOffsetX = offsetX
    lastAppliedOffsetY = offsetY
end

local function HasCoordinateChanged(previous, current, epsilon)
    return previous == nil or current == nil or math.abs(previous - current) > epsilon
end

local function CenterContainerOnPlayer(snap)
    if not containerAttached then
        return false
    end

    local viewSize = GetViewSize()
    local mapContentSize = ZO_MAP_CONSTANTS.MAP_WIDTH
    if type(mapContentSize) ~= "number" then
        return false
    end
    local x, y = GetMapPlayerPosition("player")
    local offsetX = (viewSize * 0.5) - (x * mapContentSize)
    local offsetY = (viewSize * 0.5) - (y * mapContentSize)
    offsetX = NQOL.Util.Clamp(offsetX, viewSize - mapContentSize, 0)
    offsetY = NQOL.Util.Clamp(offsetY, viewSize - mapContentSize, 0)
    local changed = HasCoordinateChanged(targetOffsetX, offsetX, OFFSET_CHANGE_EPSILON)
        or HasCoordinateChanged(targetOffsetY, offsetY, OFFSET_CHANGE_EPSILON)
    targetOffsetX = offsetX
    targetOffsetY = offsetY

    if snap or currentOffsetX == nil then
        currentOffsetX = offsetX
        currentOffsetY = offsetY
        startOffsetX = offsetX
        startOffsetY = offsetY
        ApplyContainerOffset(offsetX, offsetY)
        return false
    end

    if not changed then
        return false
    end

    startOffsetX = currentOffsetX
    startOffsetY = currentOffsetY
    return true
end

local function ApplyPlayerPinPosition(normalizedX, normalizedY, force)
    local playerPin = pinManager and pinManager:GetPlayerPin()
    local control = playerPin and playerPin:GetControl()
    if not control then
        return
    end

    local mapContentSize = ZO_MAP_CONSTANTS.MAP_WIDTH
    if type(mapContentSize) ~= "number" then
        return
    end
    if force ~= true
        and lastAppliedPlayerPinControl == control
        and lastAppliedPlayerPinX == normalizedX
        and lastAppliedPlayerPinY == normalizedY
    then
        return
    end

    control:ClearAnchors()
    control:SetAnchor(CENTER, ZO_WorldMapContainer, TOPLEFT, normalizedX * mapContentSize, normalizedY * mapContentSize)
    lastAppliedPlayerPinControl = control
    lastAppliedPlayerPinX = normalizedX
    lastAppliedPlayerPinY = normalizedY
end

local function UpdatePlayerPinTarget(snap)
    local x, y = GetMapPlayerPosition("player")
    if type(x) ~= "number" or x ~= x or type(y) ~= "number" or y ~= y then
        return false
    end

    local changed = HasCoordinateChanged(targetPlayerPinX, x, PIN_CHANGE_EPSILON)
        or HasCoordinateChanged(targetPlayerPinY, y, PIN_CHANGE_EPSILON)
    targetPlayerPinX = x
    targetPlayerPinY = y
    if snap or currentPlayerPinX == nil then
        currentPlayerPinX = x
        currentPlayerPinY = y
        startPlayerPinX = x
        startPlayerPinY = y
        ApplyPlayerPinPosition(x, y)
        return false
    end

    if not changed then
        return false
    end

    startPlayerPinX = currentPlayerPinX
    startPlayerPinY = currentPlayerPinY
    ApplyPlayerPinPosition(currentPlayerPinX, currentPlayerPinY, true)
    return true
end

local function HideRouteDots(firstUnusedIndex)
    for index = firstUnusedIndex, #routeDots do
        local dot = routeDots[index]
        if dot.nqolHidden ~= true then
            dot:SetHidden(true)
            dot.nqolHidden = true
        end
    end
end

local function GetRouteDot(index)
    local dot = routeDots[index]
    if dot then
        return dot
    end

    dot = WINDOW_MANAGER:CreateControl("$(parent)RouteDot" .. index, borderOverlay, CT_BACKDROP)
    dot:SetEdgeColor(0, 0, 0, 0)
    dot:SetDrawLayer(DL_OVERLAY)
    dot:SetDrawTier(DT_HIGH)
    dot:SetDrawLevel(BORDER_DRAW_LEVEL - 1)
    RegisterOwnedMinimapControl(dot)
    ApplyOwnedMinimapControlDrawOrder(dot)
    routeDots[index] = dot
    return dot
end

local function IsValidNormalizedCoordinate(value)
    return type(value) == "number" and value == value and value >= 0 and value <= 1
end

local function IsFiniteCoordinate(value)
    return type(value) == "number" and value == value and math.abs(value) < 1000000
end

local function IsWayshrineWayfinderLocationEligible()
    if (GetCurrentZoneHouseId and GetCurrentZoneHouseId() ~= 0)
        or (IsUnitInDungeon and IsUnitInDungeon("player"))
        or (IsInstanceEndlessDungeon and IsInstanceEndlessDungeon())
        or (IsPlayerInAvAWorld and IsPlayerInAvAWorld())
        or (IsInImperialCity and IsInImperialCity())
        or (IsActiveWorldBattleground and IsActiveWorldBattleground()) then
        return false
    end

    return GetMapContentType and GetMapContentType() == MAP_CONTENT_NONE
end

local function UpdateNearestWayshrine()
    routeNeedsRefresh = true
    nearestWayshrineX = nil
    nearestWayshrineY = nil
    if not GetSettings().wayshrineWayfinder.enabled or not IsWayshrineWayfinderLocationEligible() or not GetNumFastTravelNodes or not GetFastTravelNodeInfo then
        return
    end

    local playerX, playerY = GetMapPlayerPosition("player")
    if not IsFiniteCoordinate(playerX) or not IsFiniteCoordinate(playerY) then
        return
    end
    local nearestDistanceSquared
    for nodeIndex = 1, GetNumFastTravelNodes() do
        local known, _, nodeX, nodeY, _, _, poiType, isLocatedInCurrentMap = GetFastTravelNodeInfo(nodeIndex)
        local validCoordinates = IsValidNormalizedCoordinate(nodeX) and IsValidNormalizedCoordinate(nodeY)
        local insideMap = validCoordinates and (not ZO_WorldMap_IsNormalizedPointInsideMapBounds or ZO_WorldMap_IsNormalizedPointInsideMapBounds(nodeX, nodeY))
        if known and poiType == POI_TYPE_WAYSHRINE and isLocatedInCurrentMap and insideMap then
            local deltaX = nodeX - playerX
            local deltaY = nodeY - playerY
            local distanceSquared = deltaX * deltaX + deltaY * deltaY
            if not nearestDistanceSquared or distanceSquared < nearestDistanceSquared then
                nearestDistanceSquared = distanceSquared
                nearestWayshrineX = nodeX
                nearestWayshrineY = nodeY
            end
        end
    end
end

local function RenderWayshrineRoute()
    routeNeedsRefresh = false
    local wayfinder = GetSettings().wayshrineWayfinder
    if not wayfinder.enabled or not IsWayshrineWayfinderLocationEligible() or not containerAttached or not nearestWayshrineX then
        HideRouteDots(1)
        return
    end

    local viewSize = GetViewSize()
    local mapContentSize = GetMapContentSize()
    local playerX, playerY = GetMapPlayerPosition("player")
    if not IsFiniteCoordinate(playerX) or not IsFiniteCoordinate(playerY)
        or not IsValidNormalizedCoordinate(nearestWayshrineX) or not IsValidNormalizedCoordinate(nearestWayshrineY) then
        nearestWayshrineX = nil
        nearestWayshrineY = nil
        HideRouteDots(1)
        return
    end
    local worldMapLeft = ZO_WorldMapContainer:GetLeft()
    local worldMapTop = ZO_WorldMapContainer:GetTop()
    local viewportLeft = viewport:GetLeft()
    local viewportTop = viewport:GetTop()
    if not IsFiniteCoordinate(worldMapLeft) or not IsFiniteCoordinate(worldMapTop)
        or not IsFiniteCoordinate(viewportLeft) or not IsFiniteCoordinate(viewportTop) then
        HideRouteDots(1)
        return
    end
    local containerLeft = worldMapLeft - viewportLeft
    local containerTop = worldMapTop - viewportTop
    local startX = containerLeft + playerX * mapContentSize
    local startY = containerTop + playerY * mapContentSize
    local endX = containerLeft + nearestWayshrineX * mapContentSize
    local endY = containerTop + nearestWayshrineY * mapContentSize
    if not IsFiniteCoordinate(startX) or not IsFiniteCoordinate(startY)
        or not IsFiniteCoordinate(endX) or not IsFiniteCoordinate(endY) then
        HideRouteDots(1)
        return
    end
    local deltaX = endX - startX
    local deltaY = endY - startY
    local distance = math.sqrt(deltaX * deltaX + deltaY * deltaY)
    if distance <= 0 then
        HideRouteDots(1)
        return
    end

    local dotCount = math.floor(distance / ROUTE_DOT_SPACING)
    local usedDots = 0
    for index = 1, dotCount do
        local progress = index * ROUTE_DOT_SPACING / distance
        local x = startX + deltaX * progress
        local y = startY + deltaY * progress
        if x >= 0 and x <= viewSize and y >= 0 and y <= viewSize then
            usedDots = usedDots + 1
            local dot = GetRouteDot(usedDots)
            if dot.nqolThickness ~= wayfinder.thickness then
                dot:SetDimensions(wayfinder.thickness, wayfinder.thickness)
                dot.nqolThickness = wayfinder.thickness
            end
            local color = wayfinder.color
            if dot.nqolRed ~= color[1]
                or dot.nqolGreen ~= color[2]
                or dot.nqolBlue ~= color[3]
                or dot.nqolAlpha ~= color[4]
            then
                dot:SetCenterColor(color[1], color[2], color[3], color[4])
                dot.nqolRed = color[1]
                dot.nqolGreen = color[2]
                dot.nqolBlue = color[3]
                dot.nqolAlpha = color[4]
            end
            if dot.nqolX ~= x or dot.nqolY ~= y then
                dot:ClearAnchors()
                dot:SetAnchor(CENTER, borderOverlay, TOPLEFT, x, y)
                dot.nqolX = x
                dot.nqolY = y
            end
            if dot.nqolHidden ~= false then
                dot:SetHidden(false)
                dot.nqolHidden = false
            end
        end
    end
    HideRouteDots(usedDots + 1)
end

local function ApplyContainerDimensions()
    local mapContentSize = GetMapContentSize()
    activeZoom = GetActiveZoom()
    ZO_MAP_CONSTANTS.MAP_WIDTH = mapContentSize
    ZO_MAP_CONSTANTS.MAP_HEIGHT = mapContentSize
    ZO_WorldMapContainer:SetDimensions(mapContentSize, mapContentSize)
    UpdateHarvestMapCompatibility()

    if ZO_WorldMapContainerBackground then
        ZO_WorldMapContainerBackground:SetDimensions(mapContentSize * 2, mapContentSize * 2)
    end
end

local function ApplyContainerLayout(mapTilesAlreadyLaidOut)
    if not containerAttached then
        return
    end

    SetViewportUpdateActive(false)
    ApplyContainerDimensions()

    lastAppliedOffsetX = nil
    lastAppliedOffsetY = nil
    lastAppliedPlayerPinControl = nil
    lastAppliedPlayerPinX = nil
    lastAppliedPlayerPinY = nil
    if not mapTilesAlreadyLaidOut then
        WORLD_MAP_TILES_MANAGER:LayoutTiles()
    end
    pinManager:UpdatePinsForMapSizeChange()
    pinManager:UpdateMovingPins()
    UpdatePlayerPinTarget(true)
    WORLD_MAP_MANAGER:UpdateBlobs()
    CenterContainerOnPlayer(true)
    UpdateNearestWayshrine()
    RenderWayshrineRoute()
    ApplyCurrentMinimapDrawOrder()
end

local function FlushNativeMapRefreshQueue()
    local control = WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.control
    local onUpdate = control and control:GetHandler("OnUpdate")
    if onUpdate then
        onUpdate(control, GetFrameTimeSeconds())
    end
end

local function RefreshPlayerMap(forceRefresh)
    if not containerAttached then
        return false
    end

    local mapChanged = false
    if not DoesCurrentMapMatchMapForPlayerLocation() then
        mapChanged = SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED
    end
    if not mapChanged and forceRefresh ~= true then
        return false
    end

    ZO_WorldMapContainer:SetHidden(true)
    -- UpdateTextures can now lay out the new tiles once at their final size.
    ApplyContainerDimensions()
    if mapChanged then
        CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
    else
        ZO_WorldMap_UpdateMap()
    end
    FlushNativeMapRefreshQueue()
    ApplyContainerLayout(true)
    ZO_WorldMapContainer:SetHidden(false)
    return true
end

local function AttachContainer()
    if containerAttached or worldMapShowing or not ShouldShowMinimap() then
        return false
    end

    ZO_WorldMap:SetHidden(true)
    containerRestore = {
        parent = ZO_WorldMapContainer:GetParent(),
        mapWidth = ZO_MAP_CONSTANTS.MAP_WIDTH,
        mapHeight = ZO_MAP_CONSTANTS.MAP_HEIGHT,
        mouseEnabled = ZO_WorldMapContainer:IsMouseEnabled(),
    }

    ZO_WorldMapContainer:SetHidden(true)
    ZO_WorldMapContainer:SetParent(viewport)
    ZO_WorldMapContainer:SetMouseEnabled(false)
    containerAttached = true
    lastAppliedOffsetX = nil
    lastAppliedOffsetY = nil
    lastAppliedPlayerPinControl = nil
    lastAppliedPlayerPinX = nil
    lastAppliedPlayerPinY = nil
    ApplyCurrentMinimapDrawOrder()
    UpdateHarvestMapCompatibility()
    RefreshPlayerMap(true)
    return true
end

local function RestoreContainer()
    if not containerAttached then
        return
    end

    StopUpdating()
    SetViewportHidden(true)
    ZO_WorldMapContainer:SetHidden(true)

    local restore = containerRestore
    local parent = restore and restore.parent or ZO_WorldMapScroll
    ZO_WorldMapContainer:SetParent(parent)
    ZO_WorldMapContainer:ClearAnchors()
    ZO_WorldMapContainer:SetAnchor(CENTER, parent, CENTER, 0, 0)
    ZO_WorldMapContainer:SetMouseEnabled(not restore or restore.mouseEnabled)

    if restore then
        ZO_MAP_CONSTANTS.MAP_WIDTH = restore.mapWidth
        ZO_MAP_CONSTANTS.MAP_HEIGHT = restore.mapHeight
        ZO_WorldMapContainer:SetDimensions(restore.mapWidth, restore.mapHeight)
    end

    containerAttached = false
    containerRestore = nil
    lastAppliedOffsetX = nil
    lastAppliedOffsetY = nil
    lastAppliedPlayerPinControl = nil
    lastAppliedPlayerPinX = nil
    lastAppliedPlayerPinY = nil
    UpdateHarvestMapCompatibility()

    if not WORLD_MAP_MANAGER.inSpecialMode then
        WORLD_MAP_MANAGER:SetToMode(MAP_MODE_LARGE_CUSTOM)
    end
    ZO_WorldMap_UpdateMap()
    ZO_WorldMapContainer:SetHidden(false)
end

local function BeginViewportInterpolation()
    if not containerAttached or viewport:IsHidden() then
        return
    end

    startOffsetX = currentOffsetX
    startOffsetY = currentOffsetY
    startPlayerPinX = currentPlayerPinX
    startPlayerPinY = currentPlayerPinY
    interpolationStartMs = GetFrameTimeMilliseconds()
    SetViewportUpdateActive(true)
end

local function UpdateMinimap()
    if worldMapShowing or not ShouldShowMinimap() or not containerAttached then
        return
    end

    if activeZoom ~= GetActiveZoom() then
        ApplyContainerLayout()
    end

    local nowMs = GetFrameTimeMilliseconds()
    if nowMs - lastMapCheckMs >= MAP_CHECK_INTERVAL_MS then
        lastMapCheckMs = nowMs
        if not DoesCurrentMapMatchMapForPlayerLocation() then
            RefreshPlayerMap(false)
            return
        end
        UpdateNearestWayshrine()
    end

    pinManager:UpdateMovingPins()
    local pinChanged = UpdatePlayerPinTarget(false)
    local containerChanged = CenterContainerOnPlayer(false)
    if pinChanged or containerChanged then
        BeginViewportInterpolation()
    elseif routeNeedsRefresh then
        RenderWayshrineRoute()
    end
end

OnViewportUpdate = function()
    if not containerAttached or viewport:IsHidden() or currentOffsetX == nil or targetOffsetX == nil then
        SetViewportUpdateActive(false)
        return
    end

    local elapsedMs = GetFrameTimeMilliseconds() - interpolationStartMs
    local progress = NQOL.Util.Clamp(elapsedMs / activeUpdateIntervalMs, 0, 1)
    currentOffsetX = startOffsetX + (targetOffsetX - startOffsetX) * progress
    currentOffsetY = startOffsetY + (targetOffsetY - startOffsetY) * progress
    ApplyContainerOffset(currentOffsetX, currentOffsetY)

    if currentPlayerPinX ~= nil and targetPlayerPinX ~= nil then
        currentPlayerPinX = startPlayerPinX + (targetPlayerPinX - startPlayerPinX) * progress
        currentPlayerPinY = startPlayerPinY + (targetPlayerPinY - startPlayerPinY) * progress
        ApplyPlayerPinPosition(currentPlayerPinX, currentPlayerPinY)
    end

    if GetSettings().wayshrineWayfinder.enabled then
        RenderWayshrineRoute()
    end

    if progress >= 1 then
        currentOffsetX = targetOffsetX
        currentOffsetY = targetOffsetY
        startOffsetX = targetOffsetX
        startOffsetY = targetOffsetY
        ApplyContainerOffset(targetOffsetX, targetOffsetY)
        if targetPlayerPinX ~= nil and targetPlayerPinY ~= nil then
            currentPlayerPinX = targetPlayerPinX
            currentPlayerPinY = targetPlayerPinY
            startPlayerPinX = targetPlayerPinX
            startPlayerPinY = targetPlayerPinY
            ApplyPlayerPinPosition(targetPlayerPinX, targetPlayerPinY)
        end
        SetViewportUpdateActive(false)
    end
end

local function ShowMinimap()
    if not ShouldShowMinimap() or worldMapShowing then
        SetViewportHidden(true)
        return
    end

    AttachContainer()
    if not containerAttached then
        SetViewportHidden(true)
        return
    end

    ApplyViewportLayout()
    ApplyContainerLayout()
    SetViewportHidden(false)
    activeUpdateIntervalMs = GetUpdateIntervalMs()
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, activeUpdateIntervalMs, UpdateMinimap)
end

local function SetGameplayFragmentInstalled(shouldInstall)
    if shouldInstall == gameplayFragmentInstalled then
        return
    end

    gameplayFragmentInstalled = shouldInstall
    local methodName = shouldInstall and "AddFragment" or "RemoveFragment"
    HUD_SCENE[methodName](HUD_SCENE, viewportFragment)
    HUD_UI_SCENE[methodName](HUD_UI_SCENE, viewportFragment)
end

local function SetSettingsFragmentInstalled(shouldInstall)
    if shouldInstall == settingsFragmentInstalled then
        return
    end

    settingsFragmentInstalled = shouldInstall
    local methodName = shouldInstall and "AddFragment" or "RemoveFragment"
    GAMEPAD_OPTIONS_PANEL_SCENE[methodName](GAMEPAD_OPTIONS_PANEL_SCENE, viewportFragment)
end

local function RefreshEnabledState()
    SetGameplayFragmentInstalled(ShouldShowGameplayMinimap())
    SetSettingsFragmentInstalled(ShouldShowSettingsPreview())

    if ShouldShowMinimap() then
        ShowMinimap()
    else
        SetViewportHidden(true)
        RestoreContainer()
    end
end

local function OnViewportFragmentStateChanged(_, newState)
    if newState == SCENE_FRAGMENT_SHOWING or newState == SCENE_FRAGMENT_SHOWN then
        ShowMinimap()
    elseif newState == SCENE_FRAGMENT_HIDING or newState == SCENE_FRAGMENT_HIDDEN then
        StopUpdating()
        SetViewportHidden(true)
    end
end

local function OnWorldMapSceneStateChanged(_, newState)
    if newState == SCENE_SHOWING then
        worldMapShowing = true
        RestoreContainer()
    elseif newState == SCENE_HIDDEN then
        worldMapShowing = false
        ZO_WorldMap:SetHidden(true)
        ShowMinimap()
    end
end

local function OnPlayerActivated()
    mounted = IsMounted()
    inCombat = IsUnitInCombat("player")
    if ShouldShowMinimap() and not worldMapShowing then
        ShowMinimap()
    end
end

local function OnCombatStateChanged(_, isInCombat)
    inCombat = isInCombat == true
    RefreshEnabledState()
end

local function OnMountedStateChanged(_, isMounted)
    mounted = isMounted == true
    if containerAttached then
        ApplyContainerLayout()
    end
end

local function OnLocationChanged()
    if viewport and not viewport:IsHidden() then
        ApplyViewportLayout()
    end
end

local function OnSubzoneChanged()
    OnLocationChanged()
    if zo_callLater then
        zo_callLater(RefreshPlayerMap, 0)
    else
        RefreshPlayerMap(false)
    end
end

local function RegisterSceneCallback(scene)
    if scene then
        scene:RegisterCallback("StateChange", OnWorldMapSceneStateChanged)
    end
end

local function UnregisterSceneCallback(scene)
    if scene and scene.UnregisterCallback then
        scene:UnregisterCallback("StateChange", OnWorldMapSceneStateChanged)
    end
end

local function OnSceneStateChanged(_, _, newState)
    if newState ~= SCENE_SHOWING and newState ~= SCENE_SHOWN and newState ~= SCENE_HIDDEN then
        return
    end

    if zo_callLater then
        zo_callLater(RefreshEnabledState, 0)
    else
        RefreshEnabledState()
    end
end

local function RegisterRuntime()
    if runtimeRegistered then
        return
    end

    runtimeRegistered = true
    RegisterSceneCallback(WORLD_MAP_SCENE)
    RegisterSceneCallback(GAMEPAD_WORLD_MAP_SCENE)
    RegisterSceneCallback(SCRYING_SCENE)
    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", OnSceneStateChanged)
        sceneCallbackInstalled = true
    end
    EVENT_MANAGER:RegisterForEvent("NQOL_MinimapPlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent("NQOL_MinimapMountedStateChanged", EVENT_MOUNTED_STATE_CHANGED, OnMountedStateChanged)
    EVENT_MANAGER:RegisterForEvent("NQOL_MinimapCombatStateChanged", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    EVENT_MANAGER:RegisterForEvent("NQOL_MinimapZoneChanged", EVENT_ZONE_CHANGED, OnSubzoneChanged)
    EVENT_MANAGER:RegisterForEvent("NQOL_MinimapSubzoneListChanged", EVENT_CURRENT_SUBZONE_LIST_CHANGED, OnSubzoneChanged)
    EVENT_MANAGER:RegisterForEvent("NQOL_MinimapLinkedPositionChanged", EVENT_LINKED_WORLD_POSITION_CHANGED, OnLocationChanged)
    EVENT_MANAGER:RegisterForEvent("NQOL_MinimapScreenResized", EVENT_SCREEN_RESIZED, ApplyViewportLayout)
end

local function UnregisterRuntime()
    if not runtimeRegistered then
        return
    end

    UnregisterSceneCallback(WORLD_MAP_SCENE)
    UnregisterSceneCallback(GAMEPAD_WORLD_MAP_SCENE)
    UnregisterSceneCallback(SCRYING_SCENE)
    if sceneCallbackInstalled
        and SCENE_MANAGER
        and SCENE_MANAGER.UnregisterCallback
    then
        SCENE_MANAGER:UnregisterCallback("SceneStateChanged", OnSceneStateChanged)
        sceneCallbackInstalled = false
    end
    EVENT_MANAGER:UnregisterForEvent("NQOL_MinimapPlayerActivated", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent("NQOL_MinimapMountedStateChanged", EVENT_MOUNTED_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("NQOL_MinimapCombatStateChanged", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent("NQOL_MinimapZoneChanged", EVENT_ZONE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("NQOL_MinimapSubzoneListChanged", EVENT_CURRENT_SUBZONE_LIST_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("NQOL_MinimapLinkedPositionChanged", EVENT_LINKED_WORLD_POSITION_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("NQOL_MinimapScreenResized", EVENT_SCREEN_RESIZED)
    runtimeRegistered = false
end

local function CreateViewport()
    viewport = WINDOW_MANAGER:CreateTopLevelWindow("NQOL_MinimapViewport")
    viewport:SetDimensions(VIEW_WIDTH, VIEW_HEIGHT)
    viewport:SetAutoRectClipChildren(true)
    viewport:SetMouseEnabled(false)
    RegisterOwnedMinimapControl(viewport)
    SetViewportHidden(true)

    local background = WINDOW_MANAGER:CreateControl("$(parent)Background", viewport, CT_BACKDROP)
    background:SetAnchorFill()
    background:SetCenterColor(0, 0, 0, 1)
    background:SetEdgeColor(0, 0, 0, 0)
    RegisterOwnedMinimapControl(background)

    areaLabel = WINDOW_MANAGER:CreateControl("$(parent)AreaLabel", viewport, CT_LABEL)
    areaLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    areaLabel:SetDrawLayer(DL_OVERLAY)
    areaLabel:SetDrawTier(DT_HIGH)
    areaLabel:SetDrawLevel(BORDER_DRAW_LEVEL + 1)
    RegisterOwnedMinimapControl(areaLabel)

    borderOverlay = WINDOW_MANAGER:CreateTopLevelWindow("NQOL_MinimapBorderOverlay")
    borderOverlay:SetDrawLayer(DL_OVERLAY)
    borderOverlay:SetDrawTier(DT_HIGH)
    borderOverlay:SetDrawLevel(BORDER_DRAW_LEVEL)
    borderOverlay:SetMouseEnabled(false)
    borderOverlay:SetHidden(true)
    RegisterOwnedMinimapControl(borderOverlay)

    for index = 1, 4 do
        local border = WINDOW_MANAGER:CreateControl("$(parent)Border" .. index, borderOverlay, CT_BACKDROP)
        border:SetEdgeColor(0, 0, 0, 0)
        border:SetDrawLayer(DL_OVERLAY)
        border:SetDrawTier(DT_HIGH)
        border:SetDrawLevel(BORDER_DRAW_LEVEL)
        RegisterOwnedMinimapControl(border)
        borderTextures[index] = border
    end
    borderTextures[1]:SetAnchor(TOPLEFT, borderOverlay, TOPLEFT, 0, 0)
    borderTextures[1]:SetAnchor(TOPRIGHT, borderOverlay, TOPRIGHT, 0, 0)
    borderTextures[2]:SetAnchor(BOTTOMLEFT, borderOverlay, BOTTOMLEFT, 0, 0)
    borderTextures[2]:SetAnchor(BOTTOMRIGHT, borderOverlay, BOTTOMRIGHT, 0, 0)
    borderTextures[3]:SetAnchor(TOPLEFT, borderOverlay, TOPLEFT, 0, 0)
    borderTextures[3]:SetAnchor(BOTTOMLEFT, borderOverlay, BOTTOMLEFT, 0, 0)
    borderTextures[4]:SetAnchor(TOPRIGHT, borderOverlay, TOPRIGHT, 0, 0)
    borderTextures[4]:SetAnchor(BOTTOMRIGHT, borderOverlay, BOTTOMRIGHT, 0, 0)
    ApplyOwnedMinimapDrawOrder()
    ApplyBorder()

    ApplyViewportLayout()

    viewportFragment = ZO_SimpleSceneFragment:New(viewport)
    viewportFragment:RegisterCallback("StateChange", OnViewportFragmentStateChanged)
end

local function IsVotansMinimapActive()
    return type(VOTANS_MINIMAP) == "table"
        and VOTANS_MINIMAP.name == "VotansMiniMap"
        and type(VOTANS_MINIMAP.account) == "table"
        and VOTANS_MINIMAP.account.enableMap == true
end

local function ShouldInitialize()
    local settings = GetSettings()
    return settings.enabled == true
        or (settingsPanelVisible and settings.showInSettings == true)
end

local function RefreshRuntime()
    if not initialized then
        return
    end

    if ShouldInitialize() then
        RegisterRuntime()
        RefreshEnabledState()
    else
        RefreshEnabledState()
        UnregisterRuntime()
    end
end

function Minimap.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    cachedSettings = nil
    GetSettings()
end

function Minimap.Initialize()
    if disabledByVotan then
        return
    end

    if initialized then
        RefreshRuntime()
        return
    end

    if not ShouldInitialize() then
        return
    end

    if IsVotansMinimapActive() then
        disabledByVotan = true
        if GetSettings().enabled then
            GetSettings().enabled = false
            NQOL.Chat.Message(NQOL.L("features.minimap.votan_s_minimap_is_active_nqol_s_minimap_has_been_di_ac4c656"), NQOL.L("common.feature.minimap"))
        end
        return
    end

    initialized = true
    mounted = IsMounted()
    inCombat = IsUnitInCombat("player")
    activeUpdateIntervalMs = GetUpdateIntervalMs()
    pinManager = ZO_WorldMap_GetPinManager()
    InstallPinSizeHook()
    InstallNativeMapResizeGuard()
    CreateViewport()
    RefreshRuntime()
end

function Minimap.GetEnabled()
    return not disabledByVotan and GetSettings().enabled
end

function Minimap.CanEnable()
    return not disabledByVotan and not IsVotansMinimapActive()
end

function Minimap.GetEnabledDefault()
    return defaults.minimap.enabled
end

function Minimap.SetEnabled(value)
    if value == true and not Minimap.CanEnable() then
        GetSettings().enabled = false
        return
    end
    GetSettings().enabled = value == true

    Minimap.Initialize()
end

function Minimap.GetShowInCombat()
    return GetSettings().showInCombat
end

function Minimap.GetShowInCombatDefault()
    return defaults.minimap.showInCombat
end

function Minimap.SetShowInCombat(value)
    GetSettings().showInCombat = value == true
    if initialized then
        RefreshEnabledState()
    end
end

function Minimap.SetSettingsPanelVisible(visible)
    settingsPanelVisible = visible == true
    Minimap.Initialize()
end

function Minimap.GetShowInSettings()
    return GetSettings().showInSettings
end

function Minimap.GetShowInSettingsDefault()
    return defaults.minimap.showInSettings
end

function Minimap.SetShowInSettings(value)
    GetSettings().showInSettings = value == true
    Minimap.Initialize()
end

function Minimap.GetUpdateFrequency()
    return GetSettings().updateFrequency
end

function Minimap.GetUpdateFrequencyDefault()
    return defaults.minimap.updateFrequency
end

function Minimap.SetUpdateFrequency(value)
    GetSettings().updateFrequency = UPDATE_FREQUENCY_INTERVALS[value] and value or defaults.minimap.updateFrequency
    activeUpdateIntervalMs = GetUpdateIntervalMs()
    if initialized and containerAttached and not viewport:IsHidden() then
        StopUpdating()
        EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, activeUpdateIntervalMs, UpdateMinimap)
    end
end

function Minimap.GetUpdateFrequencyChoices()
    return UPDATE_FREQUENCY_CHOICES
end

function Minimap.GetUpdateFrequencyChoiceNames()
    return UPDATE_FREQUENCY_CHOICE_NAMES
end

function Minimap.GetHarvestMapCompatibility()
    return GetSettings().harvestMapCompatibility
end

function Minimap.GetHarvestMapCompatibilityDefault()
    return defaults.minimap.harvestMapCompatibility
end

function Minimap.SetHarvestMapCompatibility(value)
    GetSettings().harvestMapCompatibility = value == true
    if initialized then
        UpdateHarvestMapCompatibility()
        if containerAttached then
            RefreshPlayerMap(true)
        end
    end
end

function Minimap.GetHorizontalPosition()
    return GetSettings().horizontalPosition
end

function Minimap.GetHorizontalPositionDefault()
    return defaults.minimap.horizontalPosition
end

function Minimap.SetHorizontalPosition(value)
    GetSettings().horizontalPosition = NQOL.Util.Clamp(value, 0, 100)
    if initialized then
        ApplyViewportLayout()
    end
end

function Minimap.GetVerticalPosition()
    return GetSettings().verticalPosition
end

function Minimap.GetVerticalPositionDefault()
    return defaults.minimap.verticalPosition
end

function Minimap.SetVerticalPosition(value)
    GetSettings().verticalPosition = NQOL.Util.Clamp(value, 0, 100)
    if initialized then
        ApplyViewportLayout()
    end
end

function Minimap.GetSize()
    return GetSettings().size
end

function Minimap.GetSizeDefault()
    return defaults.minimap.size
end

function Minimap.SetSize(value)
    GetSettings().size = NQOL.Util.Clamp(NQOL.Util.Round(value), VIEW_SIZE_MIN, VIEW_SIZE_MAX)
    if initialized then
        ApplyViewportLayout()
        ApplyContainerLayout()
    end
end

function Minimap.GetSizeMin()
    return VIEW_SIZE_MIN
end

function Minimap.GetSizeMax()
    return VIEW_SIZE_MAX
end

function Minimap.GetBorderSize()
    return GetSettings().borderSize
end

function Minimap.GetBorderSizeDefault()
    return defaults.minimap.borderSize
end

function Minimap.SetBorderSize(value)
    GetSettings().borderSize = NQOL.Util.Clamp(NQOL.Util.Round(value), BORDER_SIZE_MIN, BORDER_SIZE_MAX)
    ApplyBorder()
end

function Minimap.GetBorderSizeMin()
    return BORDER_SIZE_MIN
end

function Minimap.GetBorderSizeMax()
    return BORDER_SIZE_MAX
end

function Minimap.GetBorderColor()
    local color = GetSettings().borderColor
    return color[1], color[2], color[3], color[4]
end

function Minimap.SetBorderColor(red, green, blue, alpha)
    GetSettings().borderColor = {
        NQOL.Util.Clamp(red, 0, 1),
        NQOL.Util.Clamp(green, 0, 1),
        NQOL.Util.Clamp(blue, 0, 1),
        NQOL.Util.Clamp(alpha or 1, 0, 1),
    }
    ApplyBorder()
end

function Minimap.GetWayshrineWayfinderEnabled()
    return GetSettings().wayshrineWayfinder.enabled
end

function Minimap.GetWayshrineWayfinderEnabledDefault()
    return defaults.minimap.wayshrineWayfinder.enabled
end

function Minimap.SetWayshrineWayfinderEnabled(value)
    GetSettings().wayshrineWayfinder.enabled = value == true
    if initialized then
        UpdateNearestWayshrine()
        RenderWayshrineRoute()
    end
end

function Minimap.GetWayshrineWayfinderThickness()
    return GetSettings().wayshrineWayfinder.thickness
end

function Minimap.GetWayshrineWayfinderThicknessDefault()
    return defaults.minimap.wayshrineWayfinder.thickness
end

function Minimap.SetWayshrineWayfinderThickness(value)
    GetSettings().wayshrineWayfinder.thickness = NQOL.Util.Clamp(NQOL.Util.Round(value), WAYFINDER_THICKNESS_MIN, WAYFINDER_THICKNESS_MAX)
    if initialized then
        RenderWayshrineRoute()
    end
end

function Minimap.GetWayshrineWayfinderThicknessMin()
    return WAYFINDER_THICKNESS_MIN
end

function Minimap.GetWayshrineWayfinderThicknessMax()
    return WAYFINDER_THICKNESS_MAX
end

function Minimap.GetWayshrineWayfinderColor()
    local color = GetSettings().wayshrineWayfinder.color
    return color[1], color[2], color[3], color[4]
end

function Minimap.SetWayshrineWayfinderColor(red, green, blue, alpha)
    GetSettings().wayshrineWayfinder.color = {
        NQOL.Util.Clamp(red, 0, 1),
        NQOL.Util.Clamp(green, 0, 1),
        NQOL.Util.Clamp(blue, 0, 1),
        NQOL.Util.Clamp(alpha or 1, 0, 1),
    }
    if initialized then
        RenderWayshrineRoute()
    end
end

function Minimap.GetEnabledLabel()
    return NQOL.L("features.minimap.enabled_label")
end

function Minimap.GetEnabledTooltip()
    if IsVotansMinimapActive() then
        return NQOL.L("features.minimap.unavailable_votan")
    end
    return NQOL.L("features.minimap.enabled_tooltip_dynamic")
end

function Minimap.GetZoneZoom()
    return GetSettings().zoneZoom
end

function Minimap.GetZoneZoomDefault()
    return defaults.minimap.zoneZoom
end

function Minimap.SetZoneZoom(value)
    GetSettings().zoneZoom = NQOL.Util.Clamp(NQOL.Util.Round(value), ZOOM_MIN, ZOOM_MAX)
    if initialized and containerAttached and not mounted and not IsUnitInDungeon("player") and GetMapType() ~= MAPTYPE_SUBZONE then
        ApplyContainerLayout()
    end
end

function Minimap.GetSubzoneZoom()
    return GetSettings().subzoneZoom
end

function Minimap.GetSubzoneZoomDefault()
    return defaults.minimap.subzoneZoom
end

function Minimap.SetSubzoneZoom(value)
    GetSettings().subzoneZoom = NQOL.Util.Clamp(NQOL.Util.Round(value), ZOOM_MIN, ZOOM_MAX)
    if initialized and containerAttached and not mounted and not IsUnitInDungeon("player") and GetMapType() == MAPTYPE_SUBZONE then
        ApplyContainerLayout()
    end
end

function Minimap.GetDungeonZoom()
    return GetSettings().dungeonZoom
end

function Minimap.GetDungeonZoomDefault()
    return defaults.minimap.dungeonZoom
end

function Minimap.SetDungeonZoom(value)
    GetSettings().dungeonZoom = NQOL.Util.Clamp(NQOL.Util.Round(value), ZOOM_MIN, ZOOM_MAX)
    if initialized and containerAttached and not mounted and IsUnitInDungeon("player") then
        ApplyContainerLayout()
    end
end

function Minimap.GetMountedZoom()
    return GetSettings().mountedZoom
end

function Minimap.GetMountedZoomDefault()
    return defaults.minimap.mountedZoom
end

function Minimap.SetMountedZoom(value)
    GetSettings().mountedZoom = NQOL.Util.Clamp(NQOL.Util.Round(value), ZOOM_MIN, ZOOM_MAX)
    if initialized and containerAttached and mounted then
        ApplyContainerLayout()
    end
end

function Minimap.GetZonePlayerPinScale()
    return GetSettings().zonePlayerPinScale
end

function Minimap.GetZonePlayerPinScaleDefault()
    return defaults.minimap.zonePlayerPinScale
end

function Minimap.SetZonePlayerPinScale(value)
    GetSettings().zonePlayerPinScale = NQOL.Util.Clamp(NQOL.Util.Round(value), PLAYER_PIN_SCALE_MIN, PLAYER_PIN_SCALE_MAX)
    RefreshPlayerPinSize()
end

function Minimap.GetSubzonePlayerPinScale()
    return GetSettings().subzonePlayerPinScale
end

function Minimap.GetSubzonePlayerPinScaleDefault()
    return defaults.minimap.subzonePlayerPinScale
end

function Minimap.SetSubzonePlayerPinScale(value)
    GetSettings().subzonePlayerPinScale = NQOL.Util.Clamp(NQOL.Util.Round(value), PLAYER_PIN_SCALE_MIN, PLAYER_PIN_SCALE_MAX)
    RefreshPlayerPinSize()
end

function Minimap.GetDungeonPlayerPinScale()
    return GetSettings().dungeonPlayerPinScale
end

function Minimap.GetDungeonPlayerPinScaleDefault()
    return defaults.minimap.dungeonPlayerPinScale
end

function Minimap.SetDungeonPlayerPinScale(value)
    GetSettings().dungeonPlayerPinScale = NQOL.Util.Clamp(NQOL.Util.Round(value), PLAYER_PIN_SCALE_MIN, PLAYER_PIN_SCALE_MAX)
    RefreshPlayerPinSize()
end

function Minimap.GetMountedPlayerPinScale()
    return GetSettings().mountedPlayerPinScale
end

function Minimap.GetMountedPlayerPinScaleDefault()
    return defaults.minimap.mountedPlayerPinScale
end

function Minimap.SetMountedPlayerPinScale(value)
    GetSettings().mountedPlayerPinScale = NQOL.Util.Clamp(NQOL.Util.Round(value), PLAYER_PIN_SCALE_MIN, PLAYER_PIN_SCALE_MAX)
    RefreshPlayerPinSize()
end

function Minimap.GetPlayerPinScaleMin()
    return PLAYER_PIN_SCALE_MIN
end

function Minimap.GetPlayerPinScaleMax()
    return PLAYER_PIN_SCALE_MAX
end

function Minimap.GetZoomMin()
    return ZOOM_MIN
end

function Minimap.GetZoomMax()
    return ZOOM_MAX
end

function Minimap.GetZoneZoomLabel()
    return NQOL.L("features.minimap.zone_zoom_label")
end

function Minimap.GetZoneZoomTooltip()
    return NQOL.L("features.minimap.zone_zoom_tooltip")
end

function Minimap.GetSubzoneZoomLabel()
    return NQOL.L("features.minimap.subzone_zoom_label")
end

function Minimap.GetSubzoneZoomTooltip()
    return NQOL.L("features.minimap.subzone_zoom_tooltip")
end

function Minimap.GetDungeonZoomLabel()
    return NQOL.L("features.minimap.dungeon_zoom_label")
end

function Minimap.GetDungeonZoomTooltip()
    return NQOL.L("features.minimap.dungeon_zoom_tooltip")
end

function Minimap.GetMountedZoomLabel()
    return NQOL.L("features.minimap.mounted_zoom_label")
end

function Minimap.GetMountedZoomTooltip()
    return NQOL.L("features.minimap.mounted_zoom_tooltip")
end

function Minimap.GetZonePlayerPinScaleLabel()
    return NQOL.L("features.minimap.zone_player_pin_scale_label")
end

function Minimap.GetZonePlayerPinScaleTooltip()
    return NQOL.L("features.minimap.zone_player_pin_scale_tooltip")
end

function Minimap.GetSubzonePlayerPinScaleLabel()
    return NQOL.L("features.minimap.subzone_player_pin_scale_label")
end

function Minimap.GetSubzonePlayerPinScaleTooltip()
    return NQOL.L("features.minimap.subzone_player_pin_scale_tooltip")
end

function Minimap.GetDungeonPlayerPinScaleLabel()
    return NQOL.L("features.minimap.dungeon_player_pin_scale_label")
end

function Minimap.GetDungeonPlayerPinScaleTooltip()
    return NQOL.L("features.minimap.dungeon_player_pin_scale_tooltip")
end

function Minimap.GetMountedPlayerPinScaleLabel()
    return NQOL.L("features.minimap.mounted_player_pin_scale_label")
end

function Minimap.GetMountedPlayerPinScaleTooltip()
    return NQOL.L("features.minimap.mounted_player_pin_scale_tooltip")
end

function Minimap.GetAreaLabelPosition()
    return GetSettings().areaLabelPosition
end

function Minimap.GetAreaLabelPositionDefault()
    return defaults.minimap.areaLabelPosition
end

function Minimap.SetAreaLabelPosition(value)
    GetSettings().areaLabelPosition = VALID_AREA_LABEL_POSITIONS[value] and value or defaults.minimap.areaLabelPosition
    if initialized then
        ApplyViewportLayout()
    end
end

function Minimap.GetAreaLabelPositionChoices()
    return AREA_LABEL_POSITIONS
end

function Minimap.GetAreaLabelPositionChoiceNames()
    return AREA_LABEL_POSITION_NAMES
end

function Minimap.GetAreaLabelFont()
    return GetSettings().areaLabelFont
end

function Minimap.GetAreaLabelFontDefault()
    return defaults.minimap.areaLabelFont
end

function Minimap.SetAreaLabelFont(value)
    GetSettings().areaLabelFont = NQOL.Util.IsFontChoice(value) and value or defaults.minimap.areaLabelFont
    if initialized then
        ApplyViewportLayout()
    end
end

function Minimap.GetAreaLabelFontChoices()
    return NQOL.Util.GetFontChoices()
end

function Minimap.GetAreaLabelFontChoiceNames()
    return NQOL.Util.GetFontChoiceNames()
end

function Minimap.GetAreaLabelSize()
    return GetSettings().areaLabelSize
end

function Minimap.GetAreaLabelSizeDefault()
    return defaults.minimap.areaLabelSize
end

function Minimap.SetAreaLabelSize(value)
    GetSettings().areaLabelSize = NQOL.Util.Clamp(NQOL.Util.Round(value), AREA_LABEL_SIZE_MIN, AREA_LABEL_SIZE_MAX)
    if initialized then
        ApplyViewportLayout()
    end
end

function Minimap.GetAreaLabelSizeMin()
    return AREA_LABEL_SIZE_MIN
end

function Minimap.GetAreaLabelSizeMax()
    return AREA_LABEL_SIZE_MAX
end

function Minimap.GetShowInSettingsLabel()
    return NQOL.L("features.minimap.show_in_settings_label")
end

function Minimap.GetShowInCombatLabel()
    return NQOL.L("features.minimap.show_in_combat_label")
end

function Minimap.GetShowInCombatTooltip()
    return NQOL.L("features.minimap.show_in_combat_tooltip")
end

function Minimap.GetUpdateFrequencyLabel()
    return NQOL.L("features.minimap.update_frequency_label")
end

function Minimap.GetUpdateFrequencyTooltip()
    return NQOL.L("features.minimap.update_frequency_tooltip")
end

function Minimap.GetHarvestMapCompatibilityLabel()
    return NQOL.L("features.minimap.harvest_map_compatibility_label")
end

function Minimap.GetHarvestMapCompatibilityTooltip()
    return NQOL.L("features.minimap.harvest_map_compatibility_tooltip")
end

function Minimap.GetShowInSettingsTooltip()
    return NQOL.L("features.minimap.show_in_settings_tooltip")
end

function Minimap.GetHorizontalPositionLabel()
    return NQOL.L("features.minimap.horizontal_position_label")
end

function Minimap.GetHorizontalPositionTooltip()
    return NQOL.L("features.minimap.horizontal_position_tooltip")
end

function Minimap.GetVerticalPositionLabel()
    return NQOL.L("features.minimap.vertical_position_label")
end

function Minimap.GetVerticalPositionTooltip()
    return NQOL.L("features.minimap.vertical_position_tooltip")
end

function Minimap.GetSizeLabel()
    return NQOL.L("features.minimap.size_label")
end

function Minimap.GetSizeTooltip()
    return NQOL.L("features.minimap.size_tooltip")
end

function Minimap.GetBorderSizeLabel()
    return NQOL.L("features.minimap.border_size_label")
end

function Minimap.GetBorderSizeTooltip()
    return NQOL.L("features.minimap.border_size_tooltip")
end

function Minimap.GetBorderColorLabel()
    return NQOL.L("features.minimap.border_color_label")
end

function Minimap.GetBorderColorTooltip()
    return NQOL.L("features.minimap.border_color_tooltip")
end

function Minimap.GetWayshrineWayfinderEnabledLabel()
    return NQOL.L("features.minimap.wayshrine_wayfinder_enabled_label")
end

function Minimap.GetWayshrineWayfinderEnabledTooltip()
    return NQOL.L("features.minimap.wayshrine_wayfinder_enabled_tooltip")
end

function Minimap.GetWayshrineWayfinderThicknessLabel()
    return NQOL.L("features.minimap.wayshrine_wayfinder_thickness_label")
end

function Minimap.GetWayshrineWayfinderThicknessTooltip()
    return NQOL.L("features.minimap.wayshrine_wayfinder_thickness_tooltip")
end

function Minimap.GetWayshrineWayfinderColorLabel()
    return NQOL.L("features.minimap.wayshrine_wayfinder_color_label")
end

function Minimap.GetWayshrineWayfinderColorTooltip()
    return NQOL.L("features.minimap.wayshrine_wayfinder_color_tooltip")
end

function Minimap.GetAreaLabelPositionLabel()
    return NQOL.L("features.minimap.area_label_position_label")
end

function Minimap.GetAreaLabelPositionTooltip()
    return NQOL.L("features.minimap.area_label_position_tooltip")
end

function Minimap.GetAreaLabelFontLabel()
    return NQOL.L("features.minimap.area_label_font_label")
end

function Minimap.GetAreaLabelFontTooltip()
    return NQOL.L("features.minimap.area_label_font_tooltip")
end

function Minimap.GetAreaLabelSizeLabel()
    return NQOL.L("features.minimap.area_label_size_label")
end

function Minimap.GetAreaLabelSizeTooltip()
    return NQOL.L("features.minimap.area_label_size_tooltip")
end

NQOL.Features.Minimap = Minimap
