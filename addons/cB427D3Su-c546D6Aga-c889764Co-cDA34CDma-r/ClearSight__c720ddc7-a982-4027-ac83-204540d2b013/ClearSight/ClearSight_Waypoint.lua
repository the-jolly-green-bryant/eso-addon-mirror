local CS = ClearSight

local TWO_PI = math.pi * 2
local PI = math.pi

local function NormalizeRadians(value)
    while value > PI do value = value - TWO_PI end
    while value < -PI do value = value + TWO_PI end
    return value
end

local function Degrees(value)
    return math.abs(value * 180 / PI)
end

local function SetSolidColor(control, color, alpha)
    control:SetCenterColor(color[1], color[2], color[3], alpha or color[4] or 1)
end

local function GetPlayerWaypointColor(self)
    if not GetSetting
        or not SETTING_TYPE_ACCESSIBILITY
        or not ACCESSIBILITY_SETTING_PLAYER_WAYPOINT_ICON_COLOR
        or not ZO_ColorDef then
        return nil
    end

    local settingValue = GetSetting(SETTING_TYPE_ACCESSIBILITY, ACCESSIBILITY_SETTING_PLAYER_WAYPOINT_ICON_COLOR)
    if not settingValue or settingValue == "" then
        return nil
    end

    -- Avoid rebuilding the colour object every 100ms while still reacting if the
    -- player changes their Accessibility > Player Waypoint colour in settings.
    if self.cachedWaypointColorSetting ~= settingValue then
        local color = ZO_ColorDef:New(settingValue)
        if color then
            local r, g, b = color:UnpackRGB()
            self.cachedWaypointColor = { r, g, b, 1 }
            self.cachedWaypointColorSetting = settingValue
        end
    end

    return self.cachedWaypointColor
end

function CS:InitializeWaypoint()
    -- Preserve the stock PLAYER_WAYPOINT compass pin because ESO owns its
    -- distance readout. ClearSight acts as an adaptive high-visibility layer
    -- at longer range, then hands navigation back to ESO near the destination.

    local root = WINDOW_MANAGER:CreateTopLevelWindow("ClearSightWaypointOverlay")
    root:SetDimensions(600, 80)
    root:SetMouseEnabled(false)
    root:SetDrawTier(DT_HIGH)

    if ZO_Compass then
        root:SetAnchor(CENTER, ZO_Compass, CENTER, 0, 0)
    elseif ZO_CompassFrame then
        root:SetAnchor(CENTER, ZO_CompassFrame, CENTER, 0, 0)
    else
        root:SetAnchor(TOP, GuiRoot, TOP, 0, 28)
    end

    local marker = WINDOW_MANAGER:CreateControl("ClearSightWaypointMarker", root, CT_BACKDROP)
    marker:SetAnchor(CENTER, root, CENTER, 0, 0)
    marker:SetCenterColor(0.1, 1, 0.2, 1)
    marker:SetEdgeColor(0, 0, 0, 1)

    self.waypointRoot = root
    self.waypointMarker = marker
end

function CS:GetWaypointNavigationData()
    if not GetMapPlayerWaypoint or not GetMapPlayerPosition or not GetPlayerCameraHeading then
        return nil
    end

    local wx, wz = GetMapPlayerWaypoint()
    if not wx or not wz or (wx == 0 and wz == 0) then
        return nil
    end

    local px, pz, _, shown = GetMapPlayerPosition("player")
    if not shown then
        return nil
    end

    local dx = wx - px
    local dz = wz - pz
    local distance = math.sqrt((dx * dx) + (dz * dz))

    if distance < 0.000001 then
        return 0, 0
    end

    local waypointBearing = math.atan2(dx, dz)
    local cameraHeading = GetPlayerCameraHeading()

    -- ESO's normalized map axes and compass heading run in opposite orientation
    -- for this bearing calculation. Rotate the calculated bearing by 180 degrees
    -- so ClearSight follows the same destination direction as the stock waypoint.
    local relative = NormalizeRadians(waypointBearing - cameraHeading + PI)

    return relative, distance
end

function CS:UpdateWaypoint()
    if not self.waypointRoot or not self.waypointMarker then return end

    local s = self.saved.waypoint
    if not s.enabled then
        self.waypointRoot:SetHidden(true)
        return
    end

    local relative, distance = self:GetWaypointNavigationData()
    if relative == nil then
        self.waypointRoot:SetHidden(true)
        return
    end

    -- Handoff to ESO's stock waypoint close to the destination. The normalized
    -- thresholds are based on the same console calibration used by the previous
    -- close/arrival behaviour: ~0.006 corresponded to roughly 100m.
    local hideOverlayDistance = s.hideOverlayDistance or 0.0090
    local waypointColorDistance = math.max(s.waypointColorDistance or 0.0180, hideOverlayDistance + 0.0001)

    -- At roughly 150m, remove ClearSight's diamond completely. This leaves one
    -- unambiguous icon to follow and prevents the player chasing two nearby pins.
    if distance <= hideOverlayDistance then
        self.waypointRoot:SetHidden(true)
        return
    end

    self.waypointRoot:SetHidden(false)

    -- Match the actual compass width where possible. This reduces the visual
    -- separation between ClearSight's accessibility layer and ESO's stock pin.
    local compassWidth = nil
    if ZO_Compass and ZO_Compass.GetWidth then
        compassWidth = ZO_Compass:GetWidth()
    elseif ZO_CompassFrame and ZO_CompassFrame.GetWidth then
        compassWidth = ZO_CompassFrame:GetWidth()
    end
    if compassWidth and compassWidth > 100 then
        self.waypointRoot:SetWidth(compassWidth)
    end

    local degrees = Degrees(relative)
    local targetSize, targetColor
    if degrees <= s.greenThresholdDegrees then
        targetSize, targetColor = s.baseSize, s.greenColor
    elseif degrees <= s.amberThresholdDegrees then
        targetSize, targetColor = s.amberSize, s.amberColor
    else
        targetSize, targetColor = s.redSize, s.redColor
    end

    -- Near roughly 300m, stop changing the diamond's colour by heading error and
    -- adopt the player's own Accessibility waypoint colour. Size and position still
    -- communicate course correction until the overlay disappears around 150m.
    if distance <= waypointColorDistance then
        targetColor = GetPlayerWaypointColor(self) or targetColor
    end

    local visibleHalfAngle = math.rad(90)
    local normalized = zo_clamp(relative / visibleHalfAngle, -1, 1)

    local halfWidth = (self.waypointRoot:GetWidth() / 2) - (targetSize / 2)
    local x = normalized * halfWidth

    self.waypointMarker:ClearAnchors()
    self.waypointMarker:SetDimensions(targetSize, targetSize)
    self.waypointMarker:SetAnchor(CENTER, self.waypointRoot, CENTER, x, 0)
    SetSolidColor(self.waypointMarker, targetColor, s.opacity)

    if self.waypointMarker.SetTransformRotationZ then
        self.waypointMarker:SetTransformRotationZ(math.rad(45))
    end
end
