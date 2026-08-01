-- local Log = LibImplex_Logger()

local WorldPositionToGuiRender3DPosition = WorldPositionToGuiRender3DPosition
local GuiRender3DPositionToWorldPosition = GuiRender3DPositionToWorldPosition
local GetWorldDimensionsOfViewFrustumAtDepth = GetWorldDimensionsOfViewFrustumAtDepth
local Set3DRenderSpaceToCurrentCamera = Set3DRenderSpaceToCurrentCamera
-- local GetUnitWorldPosition = GetUnitWorldPosition
local GetUnitRawWorldPosition = GetUnitRawWorldPosition

local CENTER = CENTER
local GuiRoot = GuiRoot

local Q = LibImplex.Q

local lerp = zo_lerp
local clampedPercentBetween = zo_clampedPercentBetween
local sqrt = math.sqrt
local tan = math.tan
local floor = math.floor
local abs = math.abs

-- local PI_360 = math.pi / 360
-- local function getK()
--     local fov = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW)
--     return 2 * tan(fov * PI_360)  -- 2 * tan(FOV/2 in rad)
-- end

-- ----------------------------------------------------------------------------

local POOL_CONTROL = LibImplex_MarkersControl
local MARKER_TEMPLATE_NAME = 'LibImplex_MarkerTemplate'

local pools = {}

local function createNewPool(context, markerTemplateName, prefix)
    if not pools[context] then
        local function factoryFunction(objectPool)
            local marker = ZO_ObjectPool_CreateNamedControl(('$(parent)_%s_%s'):format(context, prefix or 'Marker'), markerTemplateName or MARKER_TEMPLATE_NAME, objectPool, POOL_CONTROL)
            assert(marker ~= nil, 'Control was not created!')

            return marker
        end

        local function resetFunction(control)
            for i = 1, control:GetNumChildren() do
                local childControl = control:GetChild(i)
                childControl:SetHidden(true)
            end

            control:SetHidden(true)
        end

        pools[context] = ZO_ObjectPool:New(factoryFunction, resetFunction)
    end

    return pools[context]
end

local function getContextStats()
    local stats = {}
    for context, pool in pairs(pools) do
        stats[context] = {
            pool:GetActiveObjectCount(),
            pool:GetTotalObjectCount(),
        }
    end
    return stats
end

local DEFAULT_POOL_NAME = 'default'
local DEFAULT_POOL = createNewPool(DEFAULT_POOL_NAME)

-- ----------------------------------------------------------------------------

local _controls = {}
local updateableObjects = setmetatable({}, {__mode = "k"})

-- ----------------------------------------------------------------------------

--- @class Marker
--- @field position table|Vector Position
--- @field texture string Texture
--- @field control ZO_Object Control
--- @field updateFunction function|nil Update function
--- @field base Marker Base class
local Marker = LibImplex.class()

--- Constructor for Marker
--- @param position table|Vector X Y Z
--- @param orientation table Pitch Yaw Roll
--- @param texture string Texture
--- @param size table W x H
--- @param color table RGB
--- @param updateFunction function|nil Update function
function Marker:__init(pool, position, orientation, texture, size, color, updateFunction)
    self.position = position
    self[1], self[2], self[3] = position[1], position[2], position[3]
    self.orientation = orientation

    self.pool = pool
    self.Update = updateFunction

    local control, objectKey = self.pool:AcquireObject()
    self.objectKey = objectKey

    control:SetTexture(texture)
    if color then control:SetColor(unpack(color)) end

    _controls[self] = control

    if pool ~= DEFAULT_POOL then
        self.control = control
    end
end

local function getUpdateableObjects()
    return updateableObjects
end

--[[
--- Get distance to point
--- @param point Vector
--- @return number @Distance to point in space
function Marker:DistanceTo(point)
    return (point - self.position):len()
end
--]]

function Marker:DistanceXZ(point)
    local dx = point[1] - self.position[1]
    local dz = point[3] - self.position[3]

    return sqrt(dx * dx + dz * dz)
end

function Marker:Delete()
    self.pool:ReleaseObject(self.objectKey)
end

function Marker:Set3DWorldPosition(x, y, z)
    return _controls[self]:Set3DRenderSpaceOrigin(WorldPositionToGuiRender3DPosition(x, y, z))
end

function Marker:SetUseDepthBuffer(useDepthBuffer)
    return _controls[self]:Set3DRenderSpaceUsesDepthBuffer(useDepthBuffer)
end

function Marker:SetTextureCoords(left, right, top, bottom)
    return _controls[self]:SetTextureCoords(left, right, top, bottom)
end

function Marker:SetDrawLevel(drawLevel)
    return _controls[self]:SetDrawLevel(drawLevel)
end

function Marker:SetAlpha(alpha)
   return _controls[self]:SetAlpha(alpha)
end

function Marker:SetColor(r, g, b, a)
   return _controls[self]:SetColor(r, g, b, a)
end

function Marker:SetHidden(isHidden)
   return _controls[self]:SetHidden(isHidden)
end

function Marker:SetClampedToScreen(isClampedToScreen)
   return _controls[self]:SetClampedToScreen(isClampedToScreen)
end

function Marker:SetClampedToScreenInsets(l, r, t, b)
   return _controls[self]:SetClampedToScreenInsets(l, r, t, b)
end

function Marker:SetHandler(...)
    return _controls[self]:SetHandler(...)
end

function Marker:SetMouseEnabled(isMouseEnabled)
    return _controls[self]:SetMouseEnabled(isMouseEnabled)
end

function Marker:GetDrawLevel()
   return _controls[self]:GetDrawLevel()
end

function Marker:GetAnchor()
   return _controls[self]:GetAnchor()
end

function Marker:IsHidden()
   return _controls[self]:IsHidden()
end

local MARKERS_CONTROL_2D = LibImplex_2DMarkers
local MARKERS_CONTROL_2D_NAME = 'LibImplex_2DMarkers'

local UI_WIDTH, UI_HEIGHT = GuiRoot:GetDimensions()
local NEGATIVE_UI_HEIGHT = -UI_HEIGHT
-- UI_HEIGHT_K = NEGATIVE_UI_HEIGHT / getK()

local cX, cY, cZ = 0, 0, 0
local rX, rY, rZ = 0, 0, 0
local uX, uY, uZ = 0, 0, 0
local fX, fY, fZ = 0, 0, 0
-- local pwX, pwY, pwZ = 0, 0, 0
local prwX, prwY, prwZ = 0, 0, 0
local cPitch, cYaw, cRoll = 0, 0, 0

local function UpdateVectors()
    Set3DRenderSpaceToCurrentCamera(MARKERS_CONTROL_2D_NAME)

    cX, cY, cZ = GuiRender3DPositionToWorldPosition(MARKERS_CONTROL_2D:Get3DRenderSpaceOrigin()) -- RW
    fX, fY, fZ = MARKERS_CONTROL_2D:Get3DRenderSpaceForward()
    rX, rY, rZ = MARKERS_CONTROL_2D:Get3DRenderSpaceRight()
    uX, uY, uZ = MARKERS_CONTROL_2D:Get3DRenderSpaceUp()
    -- TODO: normalize?

    -- _, pwX, pwY, pwZ = GetUnitWorldPosition('player')
    _, prwX, prwY, prwZ = GetUnitRawWorldPosition('player')

    -- cPitch, cYaw, cRoll = MARKERS_CONTROL_2D:Get3DRenderSpaceOrientation()
end

--- @class Marker2D : Marker
local Marker2D = LibImplex.class(Marker)

local function _update2d(marker)
    local markerControl = _controls[marker]

    local mX, mY, mZ = marker[1], marker[2], marker[3]
    local dX, dY, dZ = mX - cX, mY - cY, mZ - cZ

    local Z = fX * dX + fY * dY + fZ * dZ
    if Z < 0 then
        markerControl:SetHidden(true)
        -- if not marker[4] then
        --     markerControl:SetHidden(true)
        --     marker[4] = true
        -- end
        return
    end

    -- --------------------------------------------------------------------

    local diffX, diffY, diffZ = prwX - mX, prwY - mY, prwZ - mZ
    local distance = sqrt(diffX * diffX + diffY * diffY + diffZ * diffZ)

    local updateFunctions = marker.updateFunctions
    for i = 1, #updateFunctions do
        if updateFunctions[i](marker, distance, prwX, prwY, prwZ, fX, fY, fZ, rX, rY, rZ, uX, uY, uZ) then return end
    end

    -- --------------------------------------------------------------------

    -- local X = rX * dX + rZ * dZ  -- rY * dY can be ignored, rY = 0 because it is vector in XZ plane
    -- local Y = uX * dX + uY * dY + uZ * dZ

    local w, h = GetWorldDimensionsOfViewFrustumAtDepth(Z)
    local offsetX, offsetY = (rX * dX + rZ * dZ) * UI_WIDTH / w, (uX * dX + uY * dY + uZ * dZ) * NEGATIVE_UI_HEIGHT / h
    markerControl:SetAnchor(CENTER, GuiRoot, CENTER, offsetX, offsetY)

    markerControl:SetDrawLevel(-Z)

    marker[5], marker[6], marker[7] = offsetX, offsetY, -Z

    markerControl:SetHidden(false)
    -- if marker[4] then
    --     markerControl:SetHidden(false)
    --     marker[4] = false
    -- end
end

function Marker2D:__init(pool, position, orientation, texture, size, color, ...)
    self.base.__init(self, pool, position, orientation, texture, size, color, _update2d)
    self.updateFunctions = {...}

    -- self.offsetX, self.offsetY = 0, 0
    self[5], self[6] = 0, 0

    local control = _controls[self]

    if size then control:SetDimensions(unpack(size)) end

    self.distanceLabel = control:GetNamedChild('DistanceLabel')

    updateableObjects[self] = true
end

function Marker2D:Delete()
    Marker.Delete(self)
    self.distanceLabel:SetHidden(true)

    updateableObjects[self] = nil
end

--- @class Marker2DWS : Marker
local Marker2DWS = LibImplex.class(Marker)

local function _update2dws(marker)
    local markerControl = _controls[marker]

    local mX, mY, mZ = marker[1], marker[2], marker[3]

    local diffX, diffY, diffZ = prwX - mX, prwY - mY, prwZ - mZ
    local distance = sqrt(diffX * diffX + diffY * diffY + diffZ * diffZ)

    local updateFunctions = marker.updateFunctions
    for i = 1, #updateFunctions do
        if updateFunctions[i](marker, distance, prwX, prwY, prwZ, fX, fY, fZ, rX, rY, rZ, uX, uY, uZ) then return end
    end

    local dX, dY, dZ = mX - cX, mY - cY, mZ - cZ

    -- local F = marker.F
    -- local Fx, Fy, Fz = F[1], F[2], F[3]
    local Fx, Fy, Fz = marker[8], marker[9], marker[10]

    local numerator = Fx * dX + Fy * dY + Fz * dZ
    local denominator = Fx * fX + Fy * fY + Fz * fZ

    -- it is not entirely correct, parallel to the camera texture
    -- should be treated as a special case and draw level
    -- should be calculated other way
    -- but this is "good enough (c)"
    if denominator > 1e-6 and denominator < -1e-6 then
        local t = numerator / denominator
        -- if t < 0 then return end

        local diX, diY, diZ = t * fX, t * fY, t * fZ
        local D = diX * diX + diY * diY + diZ * diZ

        markerControl:SetDrawLevel(-D)
    end
end

function Marker2DWS:__init(pool, position, orientation, texture, size, color, ...)
    self.base.__init(self, pool, position, orientation, texture, size, color, _update2dws)
    self.updateFunctions = {...}

    self[5], self[6] = 0, 0

    local control = _controls[self]

    control:SetTransformNormalizedOriginPoint(0.5, 0.5)
    control:SetAnchor(CENTER, GuiRoot, CENTER)
    control:SetSpace(SPACE_WORLD)

    -- control:SetTransformScale(0.01)

    local x, y, z = WorldPositionToGuiRender3DPosition(position[1], position[2], position[3])
    control:SetTransformOffset(x, y, z)
    control:SetTransformRotation(orientation[1], orientation[2], orientation[3])

    if size then control:SetDimensions(unpack(size)) end

    self.distanceLabel = control:GetNamedChild('DistanceLabel')

    local q = Q.FromEuler(orientation[1], orientation[2], orientation[3])

    local F = Q.RotateVectorByQuaternion({0, 0, 1}, q)
    local U = Q.RotateVectorByQuaternion({0, 1, 0}, q)
    local R = Q.RotateVectorByQuaternion({-1, 0, 0}, q)

    self[ 8], self[ 9], self[10] = F[1], F[2], F[3]
    self[11], self[12], self[13] = U[1], U[2], U[3]
    self[14], self[15], self[16] = R[1], R[2], R[3]

    updateableObjects[self] = true
end

function Marker2DWS:Delete()
    Marker.Delete(self)
    self.distanceLabel:SetHidden(true)

    updateableObjects[self] = nil
end

--- @class Marker3DStatic : Marker
local Marker3DStatic = LibImplex.class(Marker)

function Marker3DStatic:__init(pool, position, orientation, texture, size, color)
    Marker.__init(self, pool, position, orientation, texture, size, color)  -- TODO: refactor

    local control = _controls[self]

    size = size or {1, 1}

    control:Create3DRenderSpace()
    control:Set3DLocalDimensions(unpack(size))

    self:Move(position)

    self:Orient(orientation)

    control:Set3DRenderSpaceUsesDepthBuffer(select(4, unpack(orientation)))

    control:SetHidden(false)

    self.outline = {}
end

function Marker3DStatic:Outline()
    self:RemoveOutline()

    local tl = self:GetRelativePointCoordinates(TOPLEFT)
    local tr = self:GetRelativePointCoordinates(TOPRIGHT)
    local br = self:GetRelativePointCoordinates(BOTTOMRIGHT)
    local bl = self:GetRelativePointCoordinates(BOTTOMLEFT)

    self.outline[1] = LibImplex.Lines.Line(tl, tr)
    self.outline[2] = LibImplex.Lines.Line(tr, br)
    self.outline[3] = LibImplex.Lines.Line(br, bl)
    self.outline[4] = LibImplex.Lines.Line(bl, tl)
end

function Marker3DStatic:RemoveOutline()
    for i = 1, #self.outline do
        self.outline[i]:Delete()
        self.outline[i] = nil
    end
end

function Marker3DStatic:Move(position)
    self.position = position
    local rendX, rendY, rendZ = WorldPositionToGuiRender3DPosition(unpack(position))
	_controls[self]:Set3DRenderSpaceOrigin(rendX, rendY, rendZ)
end

function Marker3DStatic:Orient(orientation)
    local pitch, yaw, roll, depthBuffer = unpack(orientation)
    pitch = pitch or 0
    yaw = yaw or 0
    roll = roll or 0

    _controls[self]:Set3DRenderSpaceOrientation(pitch, yaw, roll)

    local q = Q.FromEuler(pitch, yaw, roll)

    self.F = Q.RotateVectorByQuaternion({0, 0, 1}, q)
    self.U = Q.RotateVectorByQuaternion({0, 1, 0}, q)
    self.R = Q.RotateVectorByQuaternion({-1, 0, 0}, q)
end

function Marker3DStatic:DrawNormal(length)
    if self.normal then
        return self.normal:Move(self.position, self.position + self.F * length)
    end

    length = length or 10
    self.normal = LibImplex.Lines.Line(self.position, self.position + self.F * length)
end

function Marker3DStatic:RemoveNormal()
    if not self.normal then return end

    self.normal:Delete()
    self.normal = nil
end

function Marker3DStatic:Delete()
    -- TODO: set something to default
    Marker.Delete(self)

    self:RemoveOutline()

    local control = _controls[self]

    control:Destroy3DRenderSpace()
    control:SetDrawLevel(0)
    control:SetAlpha(1)
    control:SetTextureCoords(0, 1, 0, 1)

    self.R = nil
    self.U = nil
    self.F = nil
end

local function getShift(anchor)
    -- center => anchor

    local right, up = 0, 0

    if     anchor == TOPLEFT     then  right = -0.5 up = 0.5
    elseif anchor == TOP         then  right = 0    up = 0.5
    elseif anchor == TOPRIGHT    then  right = 0.5  up = 0.5
    elseif anchor == LEFT        then  right = -0.5 up = 0
    elseif anchor == CENTER      then  right = 0    up = 0
    elseif anchor == RIGHT       then  right = 0.5  up = 0
    elseif anchor == BOTTOMLEFT  then  right = -0.5 up = -0.5
    elseif anchor == BOTTOM      then  right = 0    up = -0.5
    elseif anchor == BOTTOMRIGHT then  right = 0.5  up = -0.5
    else
        error('Bad anchor')
    end

    return right, up
end

function Marker3DStatic:GetRelativePointCoordinates(anchorPoint, offsetRight, offsetUp, offsetForward)
    offsetRight = offsetRight or 0
    offsetUp = offsetUp or 0
    offsetForward = offsetForward or 0

    local w, h = _controls[self]:Get3DLocalDimensions()
    local targetRight, targetUp = getShift(anchorPoint)

    local width = w * 100
    local height = h * 100

    local totalRight = targetRight * width + offsetRight
    local totalUp = targetUp * height + offsetUp

    return self.position + self.R * totalRight + self.U * totalUp + self.F * offsetForward
end

-- ----------------------------------------------------------------------------

--- @class Marker3D : Marker3DStatic
local Marker3D = LibImplex.class(Marker3DStatic)

-- local cache = setmetatable({}, {__mode = 'k'})
-- local function ClearCache()
--     for k, _ in pairs(cache) do
--         cache[k] = nil
--     end
-- end

local function _update3d(marker)
    local markerControl = _controls[marker]

    local x, y, z = marker.position[1], marker.position[2], marker.position[3]

    local diffX = prwX - x
    local diffY = prwY - y
    local diffZ = prwZ - z
    local distance = sqrt(diffX * diffX + diffY * diffY + diffZ * diffZ)

    local updateFunctions = marker.updateFunctions
    for i = 1, #updateFunctions do
        if updateFunctions[i](marker, distance, prwX, prwY, prwZ, fX, fY, fZ, rX, rY, rZ, uX, uY, uZ) then return end
    end

    local dX, dY, dZ = x - cX, y - cY, z - cZ

    --[[
    local Z = fX * dX + fY * dY + fZ * dZ
    if Z < 0 then return end
    markerControl:SetDrawLevel(-Z)  -- "2D" way
    --]]

    ---[[
    local F = marker.F
    local Fx, Fy, Fz = F[1], F[2], F[3]

    -- if cache[F] then
    --     markerControl:SetDrawLevel(cache[F])
    --     return
    -- end

    local numerator = Fx * dX + Fy * dY + Fz * dZ
    local denominator = Fx * fX + Fy * fY + Fz * fZ

    -- it is not entirely correct, parallel to the camera texture
    -- should be treated as a special case and draw level
    -- should be calculated other way
    -- but this is "good enough (c)"
    if denominator < 1e-6 and denominator > -1e-6 then
        -- cache[F] = markerControl:GetDrawLevel()
        return
    else
        local t = numerator / denominator
        -- if t < 0 then return end

        local diX, diY, diZ = t * fX, t * fY, t * fZ

        local D = diX * diX + diY * diY + diZ * diZ

        markerControl:SetDrawLevel(-D)
        -- cache[F] = -D
    end
    --]]
end

function Marker3D:__init(pool, position, orientation, texture, size, color, ...)
    Marker3DStatic.__init(self, pool, position, orientation, texture, size, color)

    self.Update = _update3d
    self.updateFunctions = {...}

    --[[
    local control = _controls[self]

    size = size or {1, 1}

    control:Create3DRenderSpace()
    control:Set3DLocalDimensions(unpack(size))

    local pitch, yaw, roll, depthBuffer = unpack(orientation)
    pitch = pitch or 0
    yaw = yaw or 0
    roll = roll or 0

    local rendX, rendY, rendZ = WorldPositionToGuiRender3DPosition(unpack(position))

	control:Set3DRenderSpaceOrigin(rendX, rendY, rendZ)
	control:Set3DRenderSpaceOrientation(pitch, yaw, roll)
    control:Set3DRenderSpaceUsesDepthBuffer(depthBuffer)

    control:SetHidden(false)
    --]]

    updateableObjects[self] = true
end

function Marker3D:Delete()
    Marker3DStatic.Delete(self)

    updateableObjects[self] = nil
end

-- ----------------------------------------------------------------------------

local Line = LibImplex.class()

local linePool = createNewPool('lines', 'LibImplex_LineTemplate', 'Line')

function Line:__init(endpoint1, endpoint2, color)
    self.x1, self.y1, self.z1 = unpack(endpoint1)
    self.x2, self.y2, self.z2 = unpack(endpoint2)

    self.pool = linePool

    local control, objectKey = self.pool:AcquireObject()

    self.objectKey = objectKey

    if color then control:SetColor(unpack(color)) end

    _controls[self] = control
    updateableObjects[self] = true
end

function Line:Delete()
    self.pool:ReleaseObject(self.objectKey)
    _controls[self] = nil

    updateableObjects[self] = nil
end

function Line:Update()
    local control = _controls[self]

    local dX1, dY1, dZ1 = self.x1 - cX, self.y1 - cY, self.z1 - cZ
    local Z1 = fX * dX1 + fY * dY1 + fZ * dZ1
    if Z1 < 0 then
        control:SetHidden(true)
        return
    end

    -- ------------------------------------------------------------------------

    local dX2, dY2, dZ2 = self.x2 - cX, self.y2 - cY, self.z2 - cZ
    local Z2 = fX * dX2 + fY * dY2 + fZ * dZ2
    if Z2 < 0 then
        control:SetHidden(true)
        return
    end

    -- --------------------------------------------------------------------

    local X1 = rX * dX1 + rZ * dZ1
    local Y1 = uX * dX1 + uY * dY1 + uZ * dZ1

    local w1, h1 = GetWorldDimensionsOfViewFrustumAtDepth(Z1)
    local scaleW1 = UI_WIDTH / w1
    local scaleH1 = NEGATIVE_UI_HEIGHT / h1

    control:SetAnchor(TOPLEFT, GuiRoot, CENTER, X1 * scaleW1, Y1 * scaleH1)

    -- ------------------------------------------------------------------------

    local X2 = rX * dX2 + rZ * dZ2
    local Y2 = uX * dX2 + uY * dY2 + uZ * dZ2

    local w2, h2 = GetWorldDimensionsOfViewFrustumAtDepth(Z2)
    local scaleW2 = UI_WIDTH / w2
    local scaleH2 = NEGATIVE_UI_HEIGHT / h2

    control:SetAnchor(BOTTOMRIGHT, GuiRoot, CENTER, X2 * scaleW2, Y2 * scaleH2)

    -- lineControl:SetDrawLevel(-Z1)
    control:SetHidden(false)
end

function Line:Move(endpoint1, endpoint2)
    self.x1, self.y1, self.z1 = unpack(endpoint1)
    self.x2, self.y2, self.z2 = unpack(endpoint2)
end

-- ----------------------------------------------------------------------------
-- TODO: optimize lerp and clamp functions

local function ChangeAlphaWithDistance(minAlpha, maxAlpha, minDistance, maxDistance)
    local function inner(marker, distance)
        marker:SetAlpha(lerp(minAlpha, maxAlpha, clampedPercentBetween(minDistance, maxDistance, distance)))
    end

    return inner
end

local function Change3DLocalDimensionsWithDistance(minDimensions, maxDimensions, minDistance, maxDistance)
    local function inner(marker, distance)
        local d = lerp(minDimensions, maxDimensions, clampedPercentBetween(minDistance, maxDistance, distance))
        marker:Set3DLocalDimensions(d, d)
    end

    return inner
end

local function HideIfTooFar(maxDistance)
    local function inner(marker, distance)
        marker:SetHidden(distance > maxDistance)
    end

    return inner
end

local function HideIfTooClose(minDistance)
    local function inner(marker, distance)
        marker:SetHidden(distance < minDistance)
    end

    return inner
end

-- ----------------------------------------------------------------------------

LibImplex = LibImplex or {}

LibImplex.GetUpdateableObjects = getUpdateableObjects

LibImplex.Context = {
    GetContextStats = getContextStats
}

-- LibImplex.ClearCache = ClearCache

LibImplex.Marker = {
    subclass = function() return LibImplex.class(Marker) end,

    UpdateVectors = UpdateVectors,
}

local DefaultMarkers = {
    Marker2D = Marker2D,
    Marker3D = Marker3D,
    Marker3DStatic = Marker3DStatic,
    Marker2DWS = Marker2DWS,

    _2D = Marker2D,
    _3D = Marker3D,
    _3DStatic = Marker3DStatic,
    _2DWS = Marker2DWS
}

local contextMeta = {
    __index = function(tbl, key)
        local marker = DefaultMarkers[key]

        if marker then
            return function(...)
                return marker(tbl._pool, ...)
            end
        end
    end
}

local markerMeta = {
    __index = function(_, key)
        local marker = DefaultMarkers[key]

        if marker then
            return function(...)
                return marker(DEFAULT_POOL, ...)
            end
        end
    end,

    __call = function(self, context)
        local context_table = {
            _pool = createNewPool(context or DEFAULT_POOL_NAME)
        }

        setmetatable(context_table, contextMeta)

        return context_table
    end
}

setmetatable(LibImplex.Marker, markerMeta)

-- LibImplex.Player = {
--     GetVector = GetPlayerVector,
--     GetVector = function() return VP end,
--     GetCoordinates = function() return VP[1], VP[2], VP[3] end,
--     GetOnScreenCoordinates = GetPlayerOnScreenCoordinates,
-- }

local function calculateEulerAngles()
    local pitch = math.asin(-fY)
    local yaw = math.atan2(fX, fZ)
    local roll = math.atan2(rY, uY)

    return pitch, yaw, roll
end

LibImplex.Camera = {
    GetOrientation = calculateEulerAngles
}

LibImplex.UpdateFunction = {
    HideIfTooFar = HideIfTooFar,
    HideIfTooClose = HideIfTooClose,
    ChangeAlphaWithDistance = ChangeAlphaWithDistance,
    ChangeSize3DWithDistance = Change3DLocalDimensionsWithDistance,
}

LibImplex.Lines = {
    Line = Line,
    GetUpdateableLines = getUpdateableLines
}
