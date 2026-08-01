local CC = CombatCoordinates

---------------------------------------------------------------------------
-- FETCH VISUAL SETTINGS (DRY)
---------------------------------------------------------------------------
function CC.GetVisualSettings()
    return CC.SV.standardRadius, CC.SV.standardNumSides, CC.SV.standardLineWidth, CC.SV.standardHeightOffset
end

---------------------------------------------------------------------------
-- DEBUG PRINT FUNCTION
---------------------------------------------------------------------------
function CombatCoordinates.Debug(msg)
    if CombatCoordinates.SV.debugMode then
        d(CombatCoordinates.chat .. " " .. msg)
    end
end

---------------------------------------------------------------------------
-- CALCULATE ROLL ANGLE
---------------------------------------------------------------------------
local function GetRollAngle(dx, dy)
    local angle = math.atan2(dy, dx)
    if (dx < 0) then angle = angle - math.pi end
    return angle
end

---------------------------------------------------------------------------
-- CALCULATE YAW ANGLE
---------------------------------------------------------------------------
local function GetYawAngle(dx, dz)
    return math.atan2(dz, dx)
end

---------------------------------------------------------------------------
-- GET OR CREATE A 3D SEGMENT CONTROL FROM POOL
---------------------------------------------------------------------------
local function GetSegmentFromPool()
    for _, segment in ipairs(CC.segmentPool) do
        if not segment.inUse then
            segment.inUse = true
            if segment.control and not segment.control:Has3DRenderSpace() then
                segment.control:Create3DRenderSpace()
                segment.control:Set3DRenderSpaceUsesDepthBuffer(true)
            end
            return segment
        end
    end

    local index = #CC.segmentPool + 1
    local segmentControl = WINDOW_MANAGER:CreateControl("CC_Segment3D_" .. index, CC.PARENT, CT_TEXTURE)

    segmentControl:Create3DRenderSpace()
    segmentControl:Set3DRenderSpaceUsesDepthBuffer(true)
    segmentControl:SetDrawLevel(3)

    local segment = { control = segmentControl, inUse = true }
    table.insert(CC.segmentPool, segment)

    return segment
end

---------------------------------------------------------------------------
-- DRAW A SINGLE 3D LINE BETWEEN TWO POINTS
---------------------------------------------------------------------------
local function Draw3DLine(x1, y1, z1, x2, y2, z2, color, lineWidth, heightOffset)
    local segment = GetSegmentFromPool()
    local ctrl = segment.control

    local dx, dy, dz = (x2 - x1) / 2, (y2 - y1) / 2, (z2 - z1) / 2
    local mx, my, mz = x1 + dx, y1 + dy, z1 + dz
    local length = math.sqrt(dx*dx + dy*dy + dz*dz)

    local width = length / 50.0
    local height = lineWidth or 0.25
    local lineColor = color or {1, 1, 1, 1}
    local hOffset = heightOffset or 5

    ctrl:Set3DLocalDimensions(width, height)
    ctrl:SetColor(unpack(lineColor))

    -- "my" IS THE VERTICAL Y-AXIS.. TOOK A WHILE BUT ITS ESO IN THE END..
    local worldX, worldY, worldZ = WorldPositionToGuiRender3DPosition(mx, my + hOffset, mz)
    ctrl:Set3DRenderSpaceOrigin(worldX, worldY, worldZ)

    local roll = GetRollAngle(dx, dy)
    local yaw = GetYawAngle(dx, dz)
    ctrl:Set3DRenderSpaceOrientation(math.pi / 2.0, -yaw, roll)

    ctrl:SetHidden(false)
    return segment
end

CC.effectCounter = 0

---------------------------------------------------------------------------
-- DRAW A FULL CIRCLE COMPOSED OF MULTIPLE 3D SEGMENTS
---------------------------------------------------------------------------
function CC.DrawEffectCircle(originX, originY, originZ, radius, color, duration, numSides, lineWidth, heightOffset)
    local segments = {}
    local points = {}

    CC.effectCounter = CC.effectCounter + 1
    local currentId = CC.effectCounter

    local sides = numSides or 24
    local rad = radius or 800

    for i = 1, sides do
        local angle = (2 * math.pi / sides) * (i - 1)
        local x = originX + rad * math.sin(angle)
        local z = originZ + rad * math.cos(angle)
        table.insert(points, {x = x, y = originY, z = z})
    end

    for i = 1, sides do
        local p1 = points[i]
        local p2 = points[(i % sides) + 1]

        local segment = Draw3DLine(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, color, lineWidth, heightOffset)
        table.insert(segments, segment)
    end

    CC.trackedVisuals[currentId] = segments

    -- REMOVE SEGMENTS AFTER DURATION EXPIRES
    zo_callLater(function()
        if CC.trackedVisuals[currentId] then
            for _, segment in ipairs(CC.trackedVisuals[currentId]) do
                segment.inUse = false
                if segment.control then
                    segment.control:SetHidden(true)
                end
            end
            CC.trackedVisuals[currentId] = nil
        end
    end, duration)
end