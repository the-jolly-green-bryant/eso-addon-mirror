local abs = math.abs
local Vector = LibImplex.Vector
local Object2D = LibImplex.Objects._2D
local Line = LibImplex.Lines.Line

local function solve3x3(A, b)
    local M = {
        {A[1][1], A[1][2], A[1][3], b[1]},
        {A[2][1], A[2][2], A[2][3], b[2]},
        {A[3][1], A[3][2], A[3][3], b[3]}
    }

    for i = 1, 3 do
        local maxRow = i
        for j = i + 1, 3 do
            if abs(M[j][i]) > abs(M[maxRow][i]) then
                maxRow = j
            end
        end

        M[i], M[maxRow] = M[maxRow], M[i]

        if abs(M[i][i]) < 1e-10 then
            return nil
        end

        for j = i + 1, 3 do
            local factor = M[j][i] / M[i][i]
            for k = i, 4 do
                M[j][k] = M[j][k] - factor * M[i][k]
            end
        end
    end

    local x = {0, 0, 0}
    for i = 3, 1, -1 do
        x[i] = M[i][4]
        for j = i + 1, 3 do
            x[i] = x[i] - M[i][j] * x[j]
        end
        x[i] = x[i] / M[i][i]
    end

    return x
end

local MARKERS_CONTROL_2D = LibImplex_2DMarkers
local MARKERS_CONTROL_2D_NAME = 'LibImplex_2DMarkers'

-- ----------------------------------------------------------------------------

--- @class RayIntersection
local RayIntersection = LibImplex.class()

function RayIntersection:__init()
    self.measurements = {}
    self.intersection = nil
end

function RayIntersection:AddCameraForwardRayToMeasurements()
    Set3DRenderSpaceToCurrentCamera(MARKERS_CONTROL_2D_NAME)

    local cX, cY, cZ = GuiRender3DPositionToWorldPosition(MARKERS_CONTROL_2D:Get3DRenderSpaceOrigin())
    local fX, fY, fZ = MARKERS_CONTROL_2D:Get3DRenderSpaceForward()

    self:AddMeasurement({cX, cY, cZ}, {fX, fY, fZ})
end

function RayIntersection:_findIntersection()
    local measurements = self.measurements

    if #measurements < 2 then
        return nil
    end

    local A = {}
    local b = {}

    for i = 1, #measurements do
        local m = measurements[i]
        local p = m.position
        local d = m.direction

        -- For each ray, we add the equation: (I - d*d^T)P = (I - d*d^T)C
        -- Where I is identity, d is direction, P is our point, C is camera position

        local I_minus_ddT = {
            {1 - d[1] * d[1],    -d[1] * d[2],    -d[1] * d[3]},
            {   -d[2] * d[1], 1 - d[2] * d[2],    -d[2] * d[3]},
            {   -d[3] * d[1],    -d[3] * d[2], 1 - d[3] * d[3]}
        }

        local right_side = {
            I_minus_ddT[1][1] * p[1] + I_minus_ddT[1][2] * p[2] + I_minus_ddT[1][3] * p[3],
            I_minus_ddT[2][1] * p[1] + I_minus_ddT[2][2] * p[2] + I_minus_ddT[2][3] * p[3],
            I_minus_ddT[3][1] * p[1] + I_minus_ddT[3][2] * p[2] + I_minus_ddT[3][3] * p[3]
        }

        -- Add to our linear system
        for row = 1, 3 do
            if not A[(i-1)*3 + row] then
                A[(i-1)*3 + row] = {}
                b[(i-1)*3 + row] = 0
            end

            A[(i-1)*3 + row][1] = I_minus_ddT[row][1]
            A[(i-1)*3 + row][2] = I_minus_ddT[row][2]
            A[(i-1)*3 + row][3] = I_minus_ddT[row][3]
            b[(i-1)*3 + row] = right_side[row]
        end
    end

    -- Solve using least squares: A^T * A * X = A^T * b
    local ATA = {
        {0, 0, 0},
        {0, 0, 0},
        {0, 0, 0}
    }
    local ATb = {0, 0, 0}

    -- Calculate A^T * A and A^T * b
    for i = 1, #b do
        for j = 1, 3 do
            for k = 1, 3 do
                ATA[j][k] = ATA[j][k] + A[i][j] * A[i][k]
            end
            ATb[j] = ATb[j] + A[i][j] * b[i]
        end
    end

    local result = solve3x3(ATA, ATb)

    if result then
        -- df('Closest intersection point: (%.3f, %.3f, %.3f)', result[1], result[2], result[3])
        return Vector(result)
    else
        -- d('Could not find solution')
        return nil
    end
end

function RayIntersection:CalculateAverageDistanceToIntersection()
    local measurements = self.measurements
    local I = self.intersection

    local totalDistance = 0

    for i = 1, #measurements do
        local measurement = measurements[i]
        local P = measurement.position
        local D = measurement.direction

        -- df('Position: %.2f, %.2f, %.2f', P[1], P[2], P[3])
        -- df('Direction: %.2f, %.2f, %.2f', D[1], D[2], D[3])

        local projection = P + D * (I - P):dot(D)

        local perpendicular = I - projection
        local distance = perpendicular:len()

        -- df('Distance: %.2f', distance)

        totalDistance = totalDistance + distance
    end

    return totalDistance / #measurements
end

function RayIntersection:AddMeasurement(position, direction)
    self.measurements[#self.measurements+1] = {
        position=Vector(position),
        direction=Vector(direction):unit(),
    }
    self:_recalculate()
end

function RayIntersection:ClearMeasurements()
    ZO_ClearNumericallyIndexedTable(self.measurements)
    self.intersection = nil
end

function RayIntersection:RemoveLastMeasurement()
    self.measurements[#self.measurements] = nil
    self:_recalculate()
end

function RayIntersection:_recalculate()
    self.intersection = self:_findIntersection()
end

function RayIntersection:GetIntersection()
    return self.intersection
end

-- ----------------------------------------------------------------------------
do
    local RI = RayIntersection()

    RI.textControl = LibImplex_RayIntersection:GetNamedChild('Text')

    RI.intersectionMark = nil
    RI.lines = {}

    local PARTIAL = 'Measurements: %d\nNo intersection'
    local COMPLETE = 'Total measurements: %d\nx: %.2f, y: %.2f, z: %.2f\nAverage distance to rays: %.2f cm'
    local MARK_TEXTURE = '/esoui/art/miscellaneous/gamepad/gp_bullet.dds'
    local MARK_SIZE = 24
    local MARK_COLOR = {1, 1, 0}

    function RI:SetText(text)
        self.textControl:SetText(text)
    end

    function RI:ClearObjects()
        if self.intersectionMark then self.intersectionMark:Delete() end

        for i = 1, #self.lines do
            local line = self.lines[i]
            line:Delete()
        end
        ZO_ClearNumericallyIndexedTable(self.lines)
    end

    function RI:DrawObjects()
        self:ClearObjects()

        local intersection = self.intersection
        if not intersection then return end

        local im = Object2D()
        :SetPosition(unpack(intersection))
        :SetTexture(MARK_TEXTURE)
        :SetColor(unpack(MARK_COLOR))
        :SetDimensions(MARK_SIZE, MARK_SIZE)

        self.intersectionMark = im

        local measurements = self.measurements
        for i = 1, #measurements do
            local measurement = measurements[i]
            local before, after = self:GetPointsAroundProjection(measurement.position, measurement.direction, intersection)
            local l = Line(before[1], before[2], before[3], after[1], after[2], after[3])
            l:SetColor(1, 1, 1, 0.7)
            self.lines[i] = l
        end
    end

    function RI:ChangeText()
        if self.intersection then
            local avgDistance = self:CalculateAverageDistanceToIntersection()
            self:SetText(COMPLETE:format(#self.measurements, self.intersection[1], self.intersection[2], self.intersection[3], avgDistance))
        else
            self:SetText(PARTIAL:format(#self.measurements))
        end
    end

    function RI:GetPointsAroundProjection(rayPoint, direction, point)
        local D = point - rayPoint

        local projectedPoint = rayPoint + direction * D:dot(direction)

        local pointBefore = projectedPoint - direction * 10 * 100
        local pointAfter = projectedPoint + direction * 10 * 100

        return pointBefore, pointAfter
    end

    local function measure()
        RI:AddCameraForwardRayToMeasurements()
        RI:DrawObjects()
        RI:ChangeText()
    end

    LibImplex_RayIntersection:GetNamedChild('Measure'):SetHandler('OnClicked', measure)

    LibImplex_RayIntersection:GetNamedChild('R'):SetHandler('OnClicked', function()
        RI:RemoveLastMeasurement()
        RI:DrawObjects()
        RI:ChangeText()
    end)

    LibImplex_RayIntersection:GetNamedChild('Clear'):SetHandler('OnClicked', function()
        RI:ClearMeasurements()
        RI:DrawObjects()
        RI:ChangeText()
    end)

    local function toggleVisibility()
        local hidden = LibImplex_RayIntersection:IsHidden()
        LibImplex_RayIntersection:SetHidden(not hidden)

        -- if not hidden then
        --     RI:ClearMeasurements()
        --     RI:DrawObjects()
        --     RI:ChangeText()
        -- end
    end

    SLASH_COMMANDS['/rayintersection'] = toggleVisibility

    -- global for keybinds
    LibImplex_RayIntersection_Measure = measure
    LibImplex_RayIntersection_ToggleVisibility = toggleVisibility
end

LibImplex.RayIntersection = RayIntersection
