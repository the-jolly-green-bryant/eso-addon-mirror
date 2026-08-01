local WorldPositionToGuiRender3DPosition = WorldPositionToGuiRender3DPosition
local GuiRender3DPositionToWorldPosition = GuiRender3DPositionToWorldPosition
local GetWorldDimensionsOfViewFrustumAtDepth = GetWorldDimensionsOfViewFrustumAtDepth
local Set3DRenderSpaceToCurrentCamera = Set3DRenderSpaceToCurrentCamera
-- local GetUnitWorldPosition = GetUnitWorldPosition
local GetUnitRawWorldPosition = GetUnitRawWorldPosition

local TOPLEFT, TOP, TOPRIGHT = TOPLEFT, TOP, TOPRIGHT
local LEFT, CENTER, RIGHT = LEFT, CENTER, RIGHT
local BOTTOMLEFT, BOTTOM, BOTTOMRIGHT = BOTTOMLEFT, BOTTOM, BOTTOMRIGHT
local GuiRoot = GuiRoot

local class = LibImplex.class
local Vector = LibImplex.Vector
local Q = LibImplex.Q
local EM = LibImplex.EVENT_MANAGER
local ComputeRotationMatrix = Q.ComputeRotationMatrix
local ApplyRotationMatrix = Q.ApplyRotationMatrix

local sqrt = math.sqrt
local tbl_remove = table.remove
local tbl_sort = table.sort
local huge = math.huge
local pow = math.pow
local max = math.max

-- local PI_360 = math.pi / 360
-- local function getK()
--     local fov = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW)
--     return 2 * tan(fov * PI_360)  -- 2 * tan(FOV/2 in rad)
-- end

local Line

local function _zero(entity)
    entity[ 1], entity[ 2], entity[ 3],  -- position
    entity[ 4], entity[ 5], entity[ 6],  -- orientation
    entity[ 7],                          -- reserved
    entity[ 8], entity[ 9], entity[10],  -- F
    entity[11], entity[12], entity[13],  -- R
    entity[14], entity[15], entity[16]   -- U
    = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
end

-- ----------------------------------------------------------------------------

local CANVAS = IMP_LibImplex_Canvas
local SECOND_CANVAS = IMP_LibImplex_SecondCanvas
local OBJECT_TEMPLATE_NAME = 'IMP_LibImplex_ObjectTemplate'

-- ----------------------------------------------------------------------------

local pools = {}

local function createNewPool(context, objectTemplateName, prefix)
    prefix = prefix or 'Object'
    objectTemplateName = objectTemplateName or OBJECT_TEMPLATE_NAME

    if not pools[context] then
        local function factoryFunction(objectPool)
            local object = ZO_ObjectPool_CreateNamedControl(('$(parent)_%s_%s'):format(context, prefix), objectTemplateName, objectPool, CANVAS)
            assert(object ~= nil, 'Control was not created!')

            return object
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
local _updateableObjects = setmetatable({}, {__mode = "k"})

local function getUpdateableObjects()
    return _updateableObjects
end

-- ----------------------------------------------------------------------------

local SYSTEM_ID = 1
local SYSTEM_CALLBACK = 2
local SYSTEM_PRIORITY = 3
local SYSTEM_ON_ADD = 4
local SYSTEM_ON_REMOVE = 5

local LOWEST_PRIORITY = 1000
local LOW_PRIORITY = 900
local MEDIUM_PRIORITY = 600
local HIGH_PRIORITY = 100
local HIGHEST_PRIORITY = 0

local System = class()

function System:__init(id, cb, priority, onAdd, onRemove)
    self[SYSTEM_ID] = id
    self[SYSTEM_CALLBACK] = cb
    self[SYSTEM_PRIORITY] = priority or MEDIUM_PRIORITY
    self[SYSTEM_ON_ADD] = onAdd
    self[SYSTEM_ON_REMOVE] = onRemove
end

-- ----------------------------------------------------------------------------

local ENTITY_UPDATE_FUNCTIONS = 17

local Entity = class()

function Entity:__init(pool, ...)
    self.pool = pool

    local control, objectKey = pool:AcquireObject()
    self.objectKey = objectKey
    _controls[self] = control

    if pool ~= DEFAULT_POOL then
        self.control = control
    end

    self.updateFunctions = {}
    self[ENTITY_UPDATE_FUNCTIONS] = {}

    self.systems = {}
    self.registry = {}
    self:AddSystems(...)
end

local function sortByPriority(left, right)
    return left[SYSTEM_PRIORITY] < right[SYSTEM_PRIORITY]
end

local function conditionalPrioritySorting(systems)
    local function inner(left, right)
        local PL = left[SYSTEM_PRIORITY]
        local PR = right[SYSTEM_PRIORITY]

        if type(PL) == 'function' then PL = PL(systems) end
        if type(PR) == 'function' then PR = PR(systems) end

        return PL < PR
    end

    return inner
end

function Entity:_addSystem(system)
    if not (system and system.isInstance and system:isInstance(System)) then return end

    local id = system[SYSTEM_ID]

    if self.registry[id] then
        -- 'system already registered'
        return
    end

    local systems = self.systems
    systems[#systems+1] = system

    local onAdd = system[4]
    if onAdd then onAdd(self) end

    return self
end

function Entity:_rebuildUpdate()
    local systems = self.systems
    local updateFunctions = self.updateFunctions
    tbl_sort(systems, conditionalPrioritySorting(systems))

    for i = 1, #updateFunctions do
        updateFunctions[i] = nil
    end

    for i = 1, #systems do
        local system_ = systems[i]
        local updateFunction = system_[SYSTEM_CALLBACK]
        if updateFunction then
            local nextIndex = #updateFunctions + 1
            updateFunctions[nextIndex] = updateFunction
            -- self[ENTITY_UPDATE_FUNCTIONS][nextIndex] = system_[SYSTEM_CALLBACK]
            self.registry[system_[SYSTEM_ID]] = nextIndex
        end
    end
end

function Entity:AddSystem(system)
    if self:_addSystem(system) then
        self:_rebuildUpdate()
    end

    return self
end

function Entity:AddSystems(...)
    local systemsToAdd = {...}
    local atLeastOneSystemAdded = false

    for i = 1, #systemsToAdd do
        if self:_addSystem(systemsToAdd[i]) then
            atLeastOneSystemAdded = true
        end
    end

    if atLeastOneSystemAdded then
        self:_rebuildUpdate()
    end

    return self
end

function Entity:RemoveSystem(system)
    local id = system[1]
    local index = self.registry[id]

    if index then
        tbl_remove(self.systems, index)
        tbl_remove(self.updateFunctions, index)
        -- tbl_remove(self[ENTITY_UPDATE_FUNCTIONS][index])
        self.registry[id] = nil
        self:_rebuildUpdate()
    end

    local onRemove = system[5]
    if onRemove then onRemove(self) end
end

function Entity:Update()
    local updateFunctions = self.updateFunctions
    -- local updateFunctions = self[ENTITY_UPDATE_FUNCTIONS]

    for i = 1, #updateFunctions do
        if updateFunctions[i](self) then return end
    end
end

function Entity:Delete()
    self.pool:ReleaseObject(self.objectKey)
end

function Entity:SetColor(r, g, b, a)
    _controls[self]:SetColor(r, g, b, a)
    self.color = {r, g, b, a}

    return self
end

-- ----------------------------------------------------------------------------

local MI_NAME = 'IMP_LibImplex_MI'
local MI = _G[MI_NAME]

local UI_WIDTH, UI_HEIGHT = GuiRoot:GetDimensions()
local NEGATIVE_UI_HEIGHT = -UI_HEIGHT
-- UI_HEIGHT_K = NEGATIVE_UI_HEIGHT / getK()

local cX, cY, cZ = 0, 0, 0
local rX, rY, rZ = 0, 0, 0
local uX, uY, uZ = 0, 0, 0
local fX, fY, fZ = 0, 0, 0
local prwX, prwY, prwZ = 0, 0, 0
-- local pwX, pwY, pwZ = 0, 0, 0
-- local cPitch, cYaw, cRoll = 0, 0, 0

local function tick()
    Set3DRenderSpaceToCurrentCamera(MI_NAME)

    cX, cY, cZ = GuiRender3DPositionToWorldPosition(MI:Get3DRenderSpaceOrigin()) -- RW
    fX, fY, fZ = MI:Get3DRenderSpaceForward()
    rX, rY, rZ = MI:Get3DRenderSpaceRight()
    uX, uY, uZ = MI:Get3DRenderSpaceUp()
    -- TODO: normalize?

    -- _, pwX, pwY, pwZ = GetUnitWorldPosition('player')
    _, prwX, prwY, prwZ = GetUnitRawWorldPosition('player')

    -- cPitch, cYaw, cRoll = MARKERS_CONTROL_2D:Get3DRenderSpaceOrientation()
end

-- ----------------------------------------------------------------------------

-- local Update2DLegacy = System(
--     'update2dlegacy',
--     function(entity, control)
--         local eX, eY, eZ = entity[1], entity[2], entity[3]
--         local dX, dY, dZ = eX - cX, eY - cY, eZ - cZ

--         local Z = fX * dX + fY * dY + fZ * dZ
--         if Z < 0 then
--             control:SetHidden(true)
--             return
--         end

--         local w, h = GetWorldDimensionsOfViewFrustumAtDepth(Z)
--         local offsetX, offsetY = (rX * dX + rZ * dZ) * UI_WIDTH / w, (uX * dX + uY * dY + uZ * dZ) * NEGATIVE_UI_HEIGHT / h

--         control:SetAnchor(CENTER, GuiRoot, CENTER, offsetX, offsetY)

--         control:SetDrawLevel(-Z)

--         entity[5], entity[6], entity[7] = offsetX, offsetY, -Z

--         control:SetHidden(false)
--     end,
--     HIGHEST_PRIORITY
-- )

local CalculateZLegacy = System(
    'calculatezlegacy',
    function(entity)
        local eX, eY, eZ = entity[1], entity[2], entity[3]
        local dX, dY, dZ = eX - cX, eY - cY, eZ - cZ

        local Z = fX * dX + fY * dY + fZ * dZ
        if Z < 0 then
            _controls[entity]:SetHidden(true)
            return true
        end

        entity[7] = Z
    end,
    HIGHEST_PRIORITY
)

local DrawLegacy = System(
    'drawlegacy',
    function(entity)
        local control = _controls[entity]

        local eX, eY, eZ = entity[1], entity[2], entity[3]
        local dX, dY, dZ = eX - cX, eY - cY, eZ - cZ

        local Z = entity[7]

        local w, h = GetWorldDimensionsOfViewFrustumAtDepth(Z)
        local offsetX, offsetY = (rX * dX + rZ * dZ) * UI_WIDTH / w, (uX * dX + uY * dY + uZ * dZ) * NEGATIVE_UI_HEIGHT / h
        control:SetAnchor(CENTER, GuiRoot, CENTER, offsetX, offsetY)

        control:SetDrawLevel(-Z)

        entity[5], entity[6] = offsetX, offsetY

        control:SetHidden(false)
    end,
    LOWEST_PRIORITY
)

local KILOMETERS = '%.1fkm'
local METERS = '%dm'
local UpdateDistanceLabel = System(
    'updatedistancelabel',
    function(entity)
        local distanceLabel = entity.distanceLabel

        local eX, eY, eZ = entity[1], entity[2], entity[3]

        local diffX, diffY, diffZ = prwX - eX, prwY - eY, prwZ - eZ
        local distance = sqrt(diffX * diffX + diffY * diffY + diffZ * diffZ)

        if distance > 100000 then
            distanceLabel:SetText(KILOMETERS:format(distance * 0.00001))
        else
            distanceLabel:SetText(METERS:format(distance * 0.01))
        end

        distanceLabel:SetDrawLevel(entity[7])  -- TODO: inherit draw level automatically?
    end,
    LOW_PRIORITY,
    function(entity)
        entity.distanceLabel:SetHidden(false)
    end,
    function(entity)
        entity.distanceLabel:SetHidden(true)
    end
)

local PRIORITY_FILTER_BY_DISTANCE = HIGHEST_PRIORITY - 1
local FilterByDistance = function(minDistance, maxDistance)
    local minDistance_sq = minDistance * minDistance * 10000
    local maxDistance_sq = maxDistance * maxDistance * 10000
    return System(
        'filterbydistance',
        function(entity)
            local eX, eY, eZ = entity[1], entity[2], entity[3]

            local diffX, diffY, diffZ = prwX - eX, prwY - eY, prwZ - eZ
            local distance_sq = diffX * diffX + diffY * diffY + diffZ * diffZ

            if distance_sq > maxDistance_sq or distance_sq < minDistance_sq then
                _controls[entity]:SetHidden(true)
                return true
            end
        end,
        PRIORITY_FILTER_BY_DISTANCE,
        nil,
        function(entity)
            _controls[entity]:SetHidden(false)
        end
    )
end

local ChangeAlphaWithDistance = function(distance1, alpha1, distance2, alpha2)
    local distance1_sq = distance1 * distance1 * 10000
    local distance2_sq = distance2 * distance2 * 10000

    local k = (alpha2 - alpha1) / (distance2_sq - distance1_sq)
    local b = alpha1 - k * distance1

    return System(
        'changealphawithdistance',
        function(entity)
            local eX, eY, eZ = entity[1], entity[2], entity[3]

            local diffX, diffY, diffZ = prwX - eX, prwY - eY, prwZ - eZ
            local distance_sq = diffX * diffX + diffY * diffY + diffZ * diffZ

            local alpha = distance_sq * k + b

            _controls[entity]:SetAlpha(alpha)
        end,
        LOW_PRIORITY,
        nil,
        function(entity)
            _controls[entity]:SetAlpha(1)
        end
    )
end

local reticleOverEntity, reticleOverCB, reticleOverLabel = nil, nil, nil
local RETICLE_OVER_MIN_DISTANCE_SQ = huge
local PREVIOUS_RETICLE_OVER = nil

local DEFAULT_CB = function() return 'Set reticle over callback or remove it!' end
local DEFAULT_LABEL = IMP_LibImplex_C_OnReticleOverLabel

local OnReticleOver = function(cb, label)
    label = label or DEFAULT_LABEL
    cb = cb or DEFAULT_CB

    return System(
        'reticleover',
        function(entity)
            local offsetX, offsetY = entity[5], entity[6]

            if offsetX > -16 and offsetX < 16 then
                if offsetY > -16 and offsetY < 16 then
                    local eX, eY, eZ = entity[1], entity[2], entity[3]

                    local diffX, diffY, diffZ = prwX - eX, prwY - eY, prwZ - eZ
                    local distance_sq = diffX * diffX + diffY * diffY + diffZ * diffZ

                    if distance_sq < RETICLE_OVER_MIN_DISTANCE_SQ then
                        reticleOverEntity, reticleOverCB, reticleOverLabel = entity, cb, label
                        RETICLE_OVER_MIN_DISTANCE_SQ = distance_sq
                    end
                end
            end
        end,
        LOW_PRIORITY
    )
end

local function registerReticleOverEvents()
    EM.RegisterForEvent('IMP_LibImplex_ReticleOverObject', EM.EVENT_BEFORE_UPDATE, function()
        reticleOverEntity = nil
        RETICLE_OVER_MIN_DISTANCE_SQ = huge
    end)

    EM.RegisterForEvent('IMP_LibImplex_ReticleOverObject', EM.EVENT_AFTER_UPDATE, function()
        if reticleOverEntity ~= PREVIOUS_RETICLE_OVER then
            if reticleOverEntity then
                reticleOverLabel:SetText(reticleOverCB(reticleOverEntity))
                reticleOverLabel:SetHidden(false)
            else
                reticleOverLabel:SetHidden(true)
            end

            PREVIOUS_RETICLE_OVER = reticleOverEntity
        end
    end)
end

local KeepOnPlayersHeight = System(
    'keeponplayersheight',
    function(entity)
        entity[2] = prwY + 200
    end,
    -- PRIORITY_FILTER_BY_DISTANCE - 1
    function(systems)
        for i = 1, #systems do
            if systems[i][SYSTEM_ID] == 'filterbydistance' then
                return PRIORITY_FILTER_BY_DISTANCE - 1
            end
        end

        return MEDIUM_PRIORITY
    end
)

local FollowThePlayer = function(offsetX, offsetY, offsetZ)
    return System(
        'followtheplayer',
        function(entity)
            entity:SetPosition(prwX+offsetX, prwY+offsetY, prwZ+offsetZ)
        end,
        MEDIUM_PRIORITY
    )
end

local Rotate3DWithCamera = System(
    'rotate3dwithcamera',
    function(entity)
        local control = _controls[entity]
        control:Set3DRenderSpaceForward(fX, fY, fZ)
        control:Set3DRenderSpaceRight(rX, rY, rZ)

        entity[ 8], entity[ 9], entity[10] = fX, fY, fZ
        entity[11], entity[12], entity[13] = rX, rY, rZ
    end,
    MEDIUM_PRIORITY
)

-- ----------------------------------------------------------------------------

local Object2D = class(Entity)

function Object2D:__init(pool, ...)
    self[1], self[2], self[3], self[4], self[5], self[6], self[7] = 0, 0, 0, 0, 0, 0, 0

    self.base.__init(self, pool, CalculateZLegacy, ..., DrawLegacy)

    local control = _controls[self]

    self.distanceLabel = control:GetNamedChild('DistanceLabel')

    _updateableObjects[self] = true
end

function Object2D:Delete()
    self.base.Delete(self)
    _updateableObjects[self] = nil
end

function Object2D:SetPosition(x, y, z)
    self[1], self[2], self[3] = x, y, z
    return self
end

function Object2D:SetTexture(texturePath)
    _controls[self]:SetTexture(texturePath)
    return self
end

function Object2D:SetDimensions(w, h)
    _controls[self]:SetDimensions(w, h)
    return self
end

-- ----------------------------------------------------------------------------

local Object2DWS = class(Entity)

local SortByProjectionOnCameraForward = System(
    'sortbyprojectiononcameraforward',
    function(entity)
        local eX, eY, eZ = entity[1], entity[2], entity[3]
        local dX, dY, dZ = eX - cX, eY - cY, eZ - cZ

        local Fx, Fy, Fz = entity[8], entity[9], entity[10]

        local numerator = Fx * dX + Fy * dY + Fz * dZ
        local denominator = Fx * fX + Fy * fY + Fz * fZ

        -- it is not entirely correct, parallel to the camera texture
        -- should be treated as a special case and draw level
        -- should be calculated other way
        -- but this is "good enough (c)"
        if denominator > 1e-6 or denominator < -1e-6 then
            local t = numerator / denominator
            -- if t < 0 then return end

            local diX, diY, diZ = t * fX, t * fY, t * fZ
            local D = diX * diX + diY * diY + diZ * diZ

            _controls[entity]:SetDrawLevel(-D)
        end
    end,
    LOW_PRIORITY,
    nil,
    nil
)

function Object2DWS:__init(pool, ...)
    _zero(self)

    self.base.__init(self, pool, ..., SortByProjectionOnCameraForward)

    local control = _controls[self]

    control:SetTransformNormalizedOriginPoint(0.5, 0.5)
    control:SetAnchor(CENTER, GuiRoot, CENTER)
    control:SetSpace(SPACE_WORLD)

    _updateableObjects[self] = true
end

function Object2DWS:Delete()
    self.base.Delete(self)
    _updateableObjects[self] = nil
end

function Object2DWS:SetPosition(x, y, z)
    self[1], self[2], self[3] = x, y, z  -- TOThink: remember coords?

    local Rx, Ry, Rz = WorldPositionToGuiRender3DPosition(x, y, z)

    local control = _controls[self]
    control:SetTransformOffset(Rx, Ry, Rz)

    return self
end

function Object2DWS:SetRotation(xRad, yRad, zRad)
    -- local q = Q.FromEuler(xRad, yRad, zRad)

    -- TOThink: remember rotations?
    self[ 4], self[ 5], self[ 6] = xRad, yRad, zRad

    local M = ComputeRotationMatrix(xRad, yRad, zRad)
    self[ 8], self[ 9], self[10] = ApplyRotationMatrix(M,  0, 0, 1)
    self[11], self[12], self[13] = ApplyRotationMatrix(M, -1, 0, 0)
    self[14], self[15], self[16] = ApplyRotationMatrix(M,  0, 1, 0)

    local control = _controls[self]
    control:SetTransformRotation(xRad, yRad, zRad)
end

function Object2DWS:SetTexture(texturePath)
    _controls[self]:SetTexture(texturePath)
    return self
end

function Object2DWS:SetDimensions(w, h)
    -- if size then control:SetDimensions(unpack(size)) end
    _controls[self]:SetDimensions(w, h)
    return self
end

-- ----------------------------------------------------------------------------

local Object3DStatic = class(Entity)

function Object3DStatic:__init(pool, ...)
    _zero(self)

    Entity.__init(self, pool, ...)

    local control = _controls[self]
    control:Create3DRenderSpace()
    control:SetHidden(false)

    self.outline = {}
end

function Object3DStatic:Outline()
    self:RemoveOutline()

    local GRPC = self.GetRelativePointCoordinates

    local tlX, ltY, tlZ = GRPC(TOPLEFT)
    local trX, trY, trZ = GRPC(TOPRIGHT)
    local blX, blY, blZ = GRPC(BOTTOMLEFT)
    local brX, brY, brZ = GRPC(BOTTOMRIGHT)

    self.outline[1] = Line(tlX, ltY, tlZ, trX, trY, trZ)
    self.outline[2] = Line(trX, trY, trZ, brX, brY, brZ)
    self.outline[3] = Line(brX, brY, brZ, blX, blY, blZ)
    self.outline[4] = Line(blX, blY, blZ, tlX, ltY, tlZ)
end

function Object3DStatic:RemoveOutline()
    for i = 1, #self.outline do
        self.outline[i]:Delete()
        self.outline[i] = nil
    end
end

function Object3DStatic:SetPosition(x, y, z)
    self[1], self[2], self[3] = x, y, z

    local Rx, Ry, Rz = WorldPositionToGuiRender3DPosition(x, y, z)
	_controls[self]:Set3DRenderSpaceOrigin(Rx, Ry, Rz)

    return self
end

function Object3DStatic:SetOrientation(xRad, yRad, zRad)
    xRad = xRad or 0
    yRad = yRad or 0
    zRad = zRad or 0

    _controls[self]:Set3DRenderSpaceOrientation(xRad, yRad, zRad)

    -- TOThink: remember rotations?
    self[ 4], self[ 5], self[ 6] = xRad, yRad, zRad

    local M = ComputeRotationMatrix(xRad, yRad, zRad)
    self[ 8], self[ 9], self[10] = ApplyRotationMatrix(M,  0, 0, 1)
    self[11], self[12], self[13] = ApplyRotationMatrix(M, -1, 0, 0)
    self[14], self[15], self[16] = ApplyRotationMatrix(M,  0, 1, 0)

    return self
end

function Object3DStatic:CopyOrientation(object)
    self[ 4], self[ 5], self[ 6] = object[ 4], object[ 5], object[ 6]
    self[ 8], self[ 9], self[10] = object[ 8], object[ 9], object[10]
    self[11], self[12], self[13] = object[11], object[12], object[13]
    self[14], self[15], self[16] = object[14], object[15], object[16]

    _controls[self]:Set3DRenderSpaceOrientation(object[4], object[5], object[6])
end

function Object3DStatic:SetTexture(texturePath)
    _controls[self]:SetTexture(texturePath)
    return self
end

function Object3DStatic:SetDimensions(w, h)
    _controls[self]:Set3DLocalDimensions(w, h)
    return self
end

function Object3DStatic:DrawNormal(length)
    -- TODO: optimize
    local P = Vector({self[ 1], self[ 2], self[ 3]})
    local F = Vector({self[ 8], self[ 9], self[10]})
    local N = P + F * length

    if self.normal then
        self.normal:SetPosition(self[1], self[2], self[3], N[1], N[2], N[3])
        return
    end

    length = length or 10
    self.normal = Line(self[1], self[2], self[3], N[1], N[2], N[3])
end

function Object3DStatic:RemoveNormal()
    if not self.normal then return end

    self.normal:Delete()
    self.normal = nil
end

function Object3DStatic:Delete()
    -- TODO: set something to default
    Entity.Delete(self)

    self:RemoveOutline()
    self:RemoveNormal()

    local control = _controls[self]

    control:Destroy3DRenderSpace()
    control:SetDrawLevel(0)
    control:SetAlpha(1)
    control:SetTextureCoords(0, 1, 0, 1)

    _zero(self)
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

function Object3DStatic:GetRelativePointCoordinates(anchorPoint, offsetRight, offsetUp, offsetForward)
    offsetRight = offsetRight or 0
    offsetUp = offsetUp or 0
    offsetForward = offsetForward or 0

    local w, h = _controls[self]:Get3DLocalDimensions()  -- TOThin: store? 
    local targetRight, targetUp = getShift(anchorPoint)

    local width = w * 100
    local height = h * 100

    local totalRight = targetRight * width + offsetRight
    local totalUp = targetUp * height + offsetUp

    -- TODO: optimize
    local P = Vector({self[ 1], self[ 2], self[ 3]})
    local F = Vector({self[ 8], self[ 9], self[10]})
    local R = Vector({self[11], self[12], self[13]})
    local U = Vector({self[14], self[15], self[16]})

    return unpack(P + R * totalRight + U * totalUp + F * offsetForward)
end

-- ----------------------------------------------------------------------------

local Object3D = class(Object3DStatic)

function Object3D:__init(pool, ...)
    Object3DStatic.__init(self, pool, ..., SortByProjectionOnCameraForward)
    _updateableObjects[self] = true
end

function Object3D:Delete()
    Object3DStatic.Delete(self)
    _updateableObjects[self] = nil
end

-- ----------------------------------------------------------------------------

local UpdateLine = System(
    'updateline',
    function(entity)
        local control = _controls[entity]

        local dX1, dY1, dZ1 = entity[1] - cX, entity[2] - cY, entity[3] - cZ
        local Z1 = fX * dX1 + fY * dY1 + fZ * dZ1

        if Z1 < 0 then
            control:SetHidden(true)
            return true
        end

        local dX2, dY2, dZ2 = entity[4] - cX, entity[5] - cY, entity[6] - cZ
        local Z2 = fX * dX2 + fY * dY2 + fZ * dZ2

        if Z2 < 0 then
            control:SetHidden(true)
            return true
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
    end,
    HIGHEST_PRIORITY
)

Line = class(Entity)

local linePool = createNewPool('lines', 'LibImplex_LineTemplate', 'Line')

function Line:__init(x1, y1, z1, x2, y2, z2, ...)
    self.base.__init(self, linePool, ..., UpdateLine)

    self[1], self[2], self[3] = x1, y1, z1
    self[4], self[5], self[6] = x2, y2, z2

    _updateableObjects[self] = true
end

function Line:Delete()
    self.base.Delete(self)

    _updateableObjects[self] = nil
end

function Line:SetPosition(x1, y1, z1, x2, y2, z2)
    self[1], self[2], self[3] = x1, y1, z1
    self[4], self[5], self[6] = x2, y2, z2
end

-- ----------------------------------------------------------------------------
-- TODO: optimize lerp and clamp functions
--]=]

-- ----------------------------------------------------------------------------

local BackFaceCulling = System(
    'backfaceculling',
    function(e)
        local control = _controls[e]

        local dotProduct = e[ 8] *fX + e[ 9] * fY + e[10] * fZ
        if dotProduct > 0 then
            control:SetHidden(true)
            return true
        else
            control:SetHidden(false)  -- TODO: avoid
        end
    end,
    HIGHEST_PRIORITY - 1
)

-- local E = Vector({e[ 1], e[ 2], e[ 3]})
-- local N = Vector({e[ 8], e[ 9], e[10]})
-- local L = (light - E):unit()
-- local diffuse = max(0, L:dot(N))  -- Lambertian
-- local C = Vector({cX, cY, cZ})
-- local V = (C - E):unit()
-- local H = (L + V):unit()
-- specular = pow(max(0, H:dot(N)), shiness)  -- Blinn-Phong
local function Lighting2(light, shiness, baseLighting)
    baseLighting = baseLighting or 0
    return System(
        'lighting2',
        function(e)
            local Lx, Ly, Lz = light[1] - e[1], light[2] - e[2], light[3] - e[3]

            local diffuse = 0
            local specular = 0

            local LdotN = Lx * e[8] + Ly * e[9] + Lz * e[10]
            if LdotN > 0 then
                local Llen = sqrt(Lx * Lx + Ly * Ly + Lz * Lz)
                diffuse = LdotN / Llen  -- Lambertian

                local Vx, Vy, Vz = cX - e[1], cY - e[2], cZ - e[3]
                local Vlen = sqrt(Vx * Vx + Vy * Vy + Vz * Vz)
                Vx, Vy, Vz = Vx / Vlen, Vy / Vlen, Vz / Vlen
                Lx, Ly, Lz = Lx / Llen, Ly / Llen, Lz / Llen

                local Hx, Hy, Hz = Lx + Vx, Ly + Vy, Lz + Vz
                local Hlen = sqrt(Hx * Hx + Hy * Hy + Hz * Hz)
                Hx, Hy, Hz = Hx / Hlen, Hy / Hlen, Hz / Hlen

                local HdotN = Hx * e[8] + Hy * e[9] + Hz * e[10]
                if HdotN > 0 then
                    specular = pow(HdotN, shiness)  -- Blinn-Phong
                end
            end

            local total = specular + diffuse + baseLighting

            local color = e.color
            _controls[e]:SetColor(
                color[1] * total,
                color[2] * total,
                color[3] * total,
                color[4]
            )
        end,
        LOW_PRIORITY
    )
end

-- local function Lighting2Static(light, shiness, baseLighting)
--     baseLighting = baseLighting or 0
--     return System(
--         'lighting2',
--         function(e)
--             local E = Vector({e[ 1], e[ 2], e[ 3]})
--             local N = Vector({e[ 8], e[ 9], e[10]})
--             local C = Vector({cX, cY, cZ})

--             local L = (light - E):unit()
--             local V = (C - E):unit()

--             local H = (L + V):unit()

--             local diffuse = max(0, L:dot(N))  -- Lambertian
--             local specular = pow(max(0, H:dot(N)), shiness)  -- Blinn-Phong

--             local total = specular + diffuse + baseLighting

--             local color = e.color
--             control:SetColor(
--                 color[1] * total,
--                 color[2] * total,
--                 color[3] * total,
--                 color[4]
--             )
--         end,
--         LOW_PRIORITY
--     )
-- end

local DepthBuffer = System(
    'depthBuffer',
    nil,
    LOWEST_PRIORITY,
    function(e)
        local control = _controls[e]
        control:SetParent(SECOND_CANVAS)
        control:Set3DRenderSpaceUsesDepthBuffer(true)
    end,
    function(e)
        local control = _controls[e]
        control:SetParent(CANVAS)
        control:Set3DRenderSpaceUsesDepthBuffer(false)
    end
)

-- ----------------------------------------------------------------------------

LibImplex = LibImplex or {}

LibImplex.GetUpdateableObjects = getUpdateableObjects

LibImplex.Context = {
    GetContextStats = getContextStats
}

LibImplex.UpdateVectors = tick

local DefaultObjects = {
    Marker2D = Object2D,
    Marker3D = Object3D,
    Marker3DStatic = Object3DStatic,
    Marker2DWS = Object2DWS,

    _2D = Object2D,
    _3D = Object3D,
    _3DStatic = Object3DStatic,
    _2DWS = Object2DWS
}

local contextMeta = {
    __index = function(tbl, key)
        local marker = DefaultObjects[key]

        if marker then
            return function(...)
                return marker(tbl._pool, ...)
            end
        end
    end
}

local objectsMeta = {
    __index = function(_, key)
        local objects = DefaultObjects[key]

        if objects then
            return function(...)
                return objects(DEFAULT_POOL, ...)
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

LibImplex.Objects = {}
setmetatable(LibImplex.Objects, objectsMeta)


local function calculateEulerAngles()
    local pitch = math.asin(-fY)
    local yaw = math.atan2(fX, fZ)
    local roll = math.atan2(rY, uY)

    return pitch, yaw, roll
end

LibImplex.Camera = {
    GetOrientation = calculateEulerAngles
}

LibImplex.Lines = {
    Line = Line,
    -- GetUpdateableLines = getUpdateableLines
}

LibImplex.System = System
LibImplex.Systems = {
    -- Update2DLegacy = Update2DLegacy,
    UpdateDistanceLabel = UpdateDistanceLabel,
    NewFilterByDistanceSystem = FilterByDistance,
    NewChangeAlphaWithDistanceSystem = ChangeAlphaWithDistance,
    OnReticleOver = OnReticleOver,
    KeepOnPlayersHeight = KeepOnPlayersHeight,
    FollowThePlayer = FollowThePlayer,
    Rotate3DWithCamera = Rotate3DWithCamera,
    Lighting2 = Lighting2,
    BackFaceCulling = BackFaceCulling,
    DepthBuffer = DepthBuffer,
}

LibImplex.RegisterReticleOverEvents = registerReticleOverEvents