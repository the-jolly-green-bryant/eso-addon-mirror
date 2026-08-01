OpulentOrdealNavigator = OpulentOrdealNavigator or {}

local OON = OpulentOrdealNavigator
local RENDERER_NAME = "OpulentOrdealNavigatorWorldRenderer"
local UPDATE_NAME = RENDERER_NAME .. "Update"
local LINE_TEXTURE = "OpulentOrdealNavigator/assets/shape/route_line.dds"

local Renderer = {}
OON.WorldRenderer = Renderer
Renderer.supportsLabels = true

local activeControls = {}
local nextKey = 1
local root
local camera
local polling = false

local function Atan2(y, x)
    if zo_atan2 then
        return zo_atan2(y, x)
    end
    if math.atan2 then
        return math.atan2(y, x)
    end
    if x > 0 then
        return math.atan(y / x)
    elseif x < 0 and y >= 0 then
        return math.atan(y / x) + math.pi
    elseif x < 0 then
        return math.atan(y / x) - math.pi
    elseif y > 0 then
        return math.pi / 2
    elseif y < 0 then
        return -math.pi / 2
    end
    return 0
end

local function EnsureRoot()
    if root then
        return
    end

    local wm = WINDOW_MANAGER
    root = wm:CreateTopLevelWindow(RENDERER_NAME .. "Root")
    root:SetAnchorFill(GuiRoot)
    root:SetHidden(false)

    camera = wm:CreateControl(RENDERER_NAME .. "Camera", root, CT_CONTROL)
    camera:Create3DRenderSpace()
end

local function MakeKey()
    local key = RENDERER_NAME .. tostring(nextKey)
    nextKey = nextKey + 1
    return key
end

local function ApplyCameraFacing(entry, forwardX, forwardY, forwardZ, rightX, rightY, rightZ, upX, upY, upZ)
    if entry.updateFunc then
        entry.updateFunc(entry)
    end

    if not entry.faceCamera then
        return
    end

    if entry.transformSpace then
        local cameraForwardX, cameraForwardY, cameraForwardZ = GetCameraForward(SPACE_WORLD)
        local yaw = zo_atan2(cameraForwardX, cameraForwardZ) - math.pi
        local pitch = zo_atan2(cameraForwardY, zo_sqrt(cameraForwardX * cameraForwardX + cameraForwardZ * cameraForwardZ))
        entry.control:SetTransformRotation(pitch, yaw, 0)
        return
    end

    entry.control:Set3DRenderSpaceForward(forwardX, forwardY, forwardZ)
    entry.control:Set3DRenderSpaceRight(rightX, rightY, rightZ)
    entry.control:Set3DRenderSpaceUp(upX, upY, upZ)
end

local function UpdateCameraFacing()
    if not next(activeControls) then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
        polling = false
        return
    end

    Set3DRenderSpaceToCurrentCamera(camera:GetName())
    local forwardX, forwardY, forwardZ = camera:Get3DRenderSpaceForward()
    local rightX, rightY, rightZ = camera:Get3DRenderSpaceRight()
    local upX, upY, upZ = camera:Get3DRenderSpaceUp()

    for _, entry in pairs(activeControls) do
        ApplyCameraFacing(entry, forwardX, forwardY, forwardZ, rightX, rightY, rightZ, upX, upY, upZ)
    end
end

local function StartPolling()
    if polling then
        UpdateCameraFacing()
        return
    end

    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 0, UpdateCameraFacing)
    polling = true
    UpdateCameraFacing()
end

local function SetRenderSpace(control, key, x, y, z, width, height, color, useDepthBuffer, faceCamera, updateFunc, orientation)
    control:Create3DRenderSpace()
    control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y, z))
    control:Set3DLocalDimensions(width, height)
    control:Set3DRenderSpaceUsesDepthBuffer(useDepthBuffer == true)
    control:Set3DRenderSpaceOrientation(unpack(orientation or { 0, 0, 0 }))
    if control.SetColor then
        control:SetColor(unpack(color))
    end
    control:SetHidden(false)

    activeControls[key] = {
        control = control,
        faceCamera = faceCamera == true,
        updateFunc = updateFunc,
    }
    StartPolling()
    return key
end

function Renderer.CreatePlacedPositionMarker(texture, x, y, z, size, color)
    EnsureRoot()

    size = size or 100
    color = color or { 1, 1, 1, 0.95 }
    local worldSize = size / 100
    local key = MakeKey()
    local control = WINDOW_MANAGER:CreateControl(key, root, CT_TEXTURE)
    control:SetTexture(texture)

    return SetRenderSpace(control, key, x, y + (size / 2), z, worldSize, worldSize, color, false, true)
end

function Renderer.CreateGroundPositionMarker(texture, x, y, z, size, color, yaw)
    EnsureRoot()

    size = (size or 100) * 3
    color = color or { 1, 1, 1, 0.95 }
    local worldSize = size / 100
    local key = MakeKey()
    local control = WINDOW_MANAGER:CreateControl(key, root, CT_TEXTURE)
    control:SetTexture(texture)

    return SetRenderSpace(
        control,
        key,
        x,
        y - 50,
        z,
        worldSize,
        worldSize,
        color,
        false,
        false,
        nil,
        { -math.pi / 2, yaw or 0, 0 }
    )
end

function Renderer.CreateLine(x1, y1, z1, x2, y2, z2, width, color)
    EnsureRoot()

    local deltaX = x2 - x1
    local deltaY = y2 - y1
    local deltaZ = z2 - z1
    local horizontalDistance = math.sqrt(deltaX * deltaX + deltaZ * deltaZ)
    local distance = math.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
    if distance <= 0 then
        return nil
    end

    local originX = (x1 + x2) / 2
    local originY = (y1 + y2) / 2 + 3
    local originZ = (z1 + z2) / 2
    local pitch = math.pi / 2 - Atan2(deltaY, horizontalDistance)
    local yaw = math.pi / 2 - Atan2(deltaZ, deltaX)
    local key = MakeKey()
    local control = WINDOW_MANAGER:CreateControl(key, root, CT_TEXTURE)
    control:SetTexture(LINE_TEXTURE)

    return SetRenderSpace(
        control,
        key,
        originX,
        originY,
        originZ,
        width or 0.22,
        distance / 100,
        color or { 1, 1, 1, 0.5 },
        false,
        false,
        nil,
        { pitch, yaw, 0 }
    )
end

function Renderer.RemoveLine(key)
    Renderer.RemoveWorldTexture(key)
end

function Renderer.RemovePlacedPositionMarker(key)
    Renderer.RemoveWorldTexture(key)
end

function Renderer.CreateAttachedUnitMarker(unitTag, texture, size, color, yOffset)
    EnsureRoot()

    if not unitTag or not DoesUnitExist(unitTag) or not GetUnitRawWorldPosition then
        return nil
    end

    size = size or 90
    color = color or { 1, 1, 1, 0.95 }
    yOffset = yOffset or 320

    local _, x, y, z = GetUnitRawWorldPosition(unitTag)
    if not x or not y or not z then
        return nil
    end

    local worldSize = size / 100
    local key = MakeKey()
    local control = WINDOW_MANAGER:CreateControl(key, root, CT_TEXTURE)
    control:SetTexture(texture)

    local function UpdateUnitPosition(entry)
        if not DoesUnitExist(unitTag) then
            entry.control:SetHidden(true)
            return
        end

        local _, ux, uy, uz = GetUnitRawWorldPosition(unitTag)
        if ux and uy and uz then
            entry.control:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(ux, uy + yOffset, uz))
            entry.control:SetHidden(false)
        else
            entry.control:SetHidden(true)
        end
    end

    return SetRenderSpace(control, key, x, y + yOffset, z, worldSize, worldSize, color, false, true, UpdateUnitPosition)
end

function Renderer.RemoveAttachedUnitMarker(key)
    Renderer.RemoveWorldTexture(key)
end

function Renderer.CreateSpaceLabel(text, x, y, z, fontSize, color, faceCamera, options)
    EnsureRoot()

    text = tostring(text or "")
    fontSize = tonumber(fontSize) or 34
    color = color or { 1, 1, 1, 1 }
    options = type(options) == "table" and options or {}
    local labelFontSize = math.max(20, math.floor(fontSize / 2))
    local labelScale = options.labelScale or (fontSize > 50 and 2 or 4)

    local key = MakeKey()
    local control = WINDOW_MANAGER:CreateControl(key, root, CT_CONTROL)
    control:SetDimensions(1000, 300)
    control:SetSpace(SPACE_WORLD)
    control:SetAnchor(CENTER, GuiRoot, CENTER)
    control:SetScale(0.01)
    control:SetTransformNormalizedOriginPoint(0.5, 0.5)
    control:SetTransformScale(1)
    control:SetTransformOffset(WorldPositionToGuiRender3DPosition(x, y, z))

    local font = string.format("$(BOLD_FONT)|%d|soft-shadow-thick", labelFontSize)
    local function CreateLabelLayer(offsetX, offsetY, layerColor)
        local label = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        label:SetAnchor(TOPLEFT, control, TOPLEFT, offsetX or 0, offsetY or 0)
        label:SetDimensions(1000, 300)
        label:SetFont(font)
        label:SetScale(labelScale)
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetText(text)
        label:SetColor(unpack(layerColor))
        return label
    end

    if options.outline == true then
        local alpha = options.shadowAlpha or 0.85
        local shadowColor = { 0, 0, 0, alpha }
        CreateLabelLayer(-4, 0, shadowColor)
        CreateLabelLayer(4, 0, shadowColor)
        CreateLabelLayer(0, -4, shadowColor)
        CreateLabelLayer(0, 4, shadowColor)
        CreateLabelLayer(-3, -3, shadowColor)
        CreateLabelLayer(3, -3, shadowColor)
        CreateLabelLayer(-3, 3, shadowColor)
        CreateLabelLayer(3, 3, shadowColor)
    end

    local label = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    label:SetAnchorFill(control)
    label:SetFont(font)
    label:SetScale(labelScale)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetText(text)
    label:SetColor(unpack(color))

    control:SetHidden(false)
    activeControls[key] = {
        control = control,
        faceCamera = faceCamera ~= false,
        transformSpace = true,
    }
    StartPolling()
    return key
end

function Renderer.ReleaseSpaceControl(key)
    Renderer.RemoveWorldTexture(key)
end

function Renderer.RemoveWorldTexture(key)
    local entry = key and activeControls[key]
    if not entry then
        return
    end

    entry.control:SetHidden(true)
    if not entry.transformSpace and entry.control.Destroy3DRenderSpace then
        entry.control:Destroy3DRenderSpace()
    end
    entry.control:SetParent(nil)
    activeControls[key] = nil

    if not next(activeControls) then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
        polling = false
    end
end

EVENT_MANAGER:RegisterForEvent(RENDERER_NAME, EVENT_PLAYER_DEACTIVATED, function()
    for key in pairs(activeControls) do
        Renderer.RemoveWorldTexture(key)
    end
    OON.routeLineControls = {}
    OON.activeMarkerControls = {}
end)
