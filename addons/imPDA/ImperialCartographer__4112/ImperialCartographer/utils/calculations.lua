local Log = ImperialCartographer_Logger()

local huge = math.huge
local abs = math.abs
local sqrt = math.sqrt

local EPSILON = 100
local STEP = 1000000000

local ACCURACY_SQ = 0.0001 * 0.0001
local MAX_ITERATIONS = 1000
local function normalizedToWorld(zoneIndex, nX_target, nZ_target)
    local zoneId = GetZoneId(zoneIndex)
    Log('Interpolation of %.6f %.6f in zoneIndex %d (zoneId %d)', nX_target, nZ_target, zoneIndex, zoneId)

    -- local wX_predicted, wY_predicted, wZ_predicted = 0, 0, 0
    local _, wX, wY, wZ = GetUnitRawWorldPosition('player')

    -- local K = 2

    -- local differenceSq = huge
    -- local iterations = 0

    for i = 1, MAX_ITERATIONS do
        local nX, nZ = GetNormalizedWorldPosition(zoneId, wX, wY, wZ)

        local nX_error, nZ_error = nX_target - nX, nZ_target - nZ

        if nX_error * nX_error + nZ_error * nZ_error < ACCURACY_SQ then
            Log('Interpolated coordinates: %.2f, %.2f', wX, wZ, nX_target, nZ_target)
            return wX, wZ
        end

        local dX, dZ = GetNormalizedWorldPosition(zoneId, wX + EPSILON, wY, wZ + EPSILON)

        local gradX = (dX - nX) / EPSILON
        local gradZ = (dZ - nZ) / EPSILON

        wX, wZ = wX + STEP * gradX * nX_error, wZ + STEP * gradZ * nZ_error

        -- local dwX, dwZ = wX / nX * nX_error, wZ / nZ * nZ_error

        -- wX = wX + dwX / K
        -- wZ = wZ + dwZ / K

        Log('Iteration %d: %d, %d', i, wX, wZ)
        Log('%.8f %.8f - %.8f %.8f = %.8f %.8f', nX_target, nZ_target, nX, nZ, nX_error, nZ_error)
        Log('%.8f %.8f', STEP * gradX * nX_error, STEP * gradZ * nZ_error)

        -- local newDifferenceSq = dwX * dwX / K / K + dwZ * dwZ / K / K
        -- if newDifferenceSq > differenceSq then
        --     K = K * 2
        -- end

        -- differenceSq = newDifferenceSq

        -- iterations = iterations + 1
    end

    error('Iterations limit reached')
end

-- ----------------------------------------------------------------------------

local TOLERANCE = 0.1

local function arePointsColinear(x1, z1, x2, z2, x3, z3, tolerance)
    local area = abs(
        (x1 * (z2 - z3) +
         x2 * (z3 - z1) +
         x3 * (z1 - z2)) / 2
    )

    local dx = x2 - x1
    local dz = z2 - z1
    local baseLength = sqrt(dx^2 + dz^2)

    local normalizedArea = baseLength > 0 and (area / baseLength) or 0

    return normalizedArea <= tolerance
end

local function fitLinear(...)
    local points = {...}
    local N = #points / 2

    local sumI, sumJ, sumIJ, sumII = 0, 0, 0, 0
    for n = 1, #points, 2 do
        local i, j = points[n], points[n+1]
        sumI = sumI + i
        sumJ = sumJ + j
        sumIJ = sumIJ + i * j
        sumII = sumII + i * i
    end

    local denominator = N * sumII - sumI * sumI
    if abs(denominator) < 1e-10 then
        local avgI = sumI / N

        return function(i) return nil end, nil, avgI
    else
        local slope = (N * sumIJ - sumI * sumJ) / denominator
        local intercept = (sumJ - slope * sumI) / N

        return function(i) return slope * i + intercept end, slope, intercept
    end
end

local DELTA = 10

local function findLeftEndpoint(zoneId, wX, wY, wZ)
    local left = 0
    local right = wX

    local _, nwZ_reference = GetNormalizedWorldPosition(zoneId, wX, wY, wZ)

    while right - left > DELTA do
        local mid = (left + right) / 2

        local _, nwZ = GetNormalizedWorldPosition(zoneId, mid, wY, wZ)

        if nwZ == nwZ_reference then
            right = mid
        else
            left = mid
        end
    end

    return right
end

local function findRightEndpoint(zoneId, wX, wY, wZ)
    local left = wX
    local right = 1000000

    local _, nwZ_reference = GetNormalizedWorldPosition(zoneId, wX, wY, wZ)

    while right - left > DELTA do
        local mid = (left + right) / 2

        local _, nwZ = GetNormalizedWorldPosition(zoneId, mid, wY, wZ)

        if nwZ == nwZ_reference then
            left = mid
        else
            right = mid
        end
    end

    return left
end

local function findBottomEndpoint(zoneId, wX, wY, wZ)
    local top = wZ
    local bottom = 1000000

    local nwX_reference, _ = GetNormalizedWorldPosition(zoneId, wX, wY, wZ)

    while bottom - top > DELTA do
        local mid = (top + bottom) / 2

        local nwX, _ = GetNormalizedWorldPosition(zoneId, wX, wY, mid)

        if nwX == nwX_reference then
            top = mid
        else
            bottom = mid
        end
    end

    return top
end

local function findTopEndpoint(zoneId, wX, wY, wZ)
    local top = 0
    local bottom = wZ

    local nwX_reference, _ = GetNormalizedWorldPosition(zoneId, wX, wY, wZ)

    while bottom - top > DELTA do
        local mid = (top + bottom) / 2

        local nwX, _ = GetNormalizedWorldPosition(zoneId, wX, wY, mid)

        if nwX == nwX_reference then
            bottom = mid
        else
            top = mid
        end
    end

    return bottom
end

local function findBoundaries(zoneId, rwX, rwY, rwZ)
    local L = findLeftEndpoint(zoneId, rwX, rwY, rwZ)
    local R = findRightEndpoint(zoneId, rwX, rwY, rwZ)
    local T = findTopEndpoint(zoneId, rwX, rwY, rwZ)
    local B = findBottomEndpoint(zoneId, rwX, rwY, rwZ)

    return L, R, T, B
end

local function getNWToRNWConversionFunctions(zoneId, rwX, rwY, rwZ)
    local L, R, T, B = findBoundaries(zoneId, rwX, rwY, rwZ)

    local nwX1, _ = GetNormalizedWorldPosition(zoneId, L, rwY, rwZ)
    local nwX2, _ = GetNormalizedWorldPosition(zoneId, rwX, rwY, rwZ)
    local nwX3, _ = GetNormalizedWorldPosition(zoneId, R, rwY, rwZ)

    local rnwX1, _ = GetRawNormalizedWorldPosition(zoneId, L, rwY, rwZ)
    local rnwX2, _ = GetRawNormalizedWorldPosition(zoneId, rwX, rwY, rwZ)
    local rnwX3, _ = GetRawNormalizedWorldPosition(zoneId, R, rwY, rwZ)

    local _, nwZ1 = GetNormalizedWorldPosition(zoneId, rwX, rwY, T)
    local _, nwZ2 = GetNormalizedWorldPosition(zoneId, rwX, rwY, rwZ)
    local _, nwZ3 = GetNormalizedWorldPosition(zoneId, rwX, rwY, B)

    local _, rnwZ1 = GetRawNormalizedWorldPosition(zoneId, rwX, rwY, T)
    local _, rnwZ2 = GetRawNormalizedWorldPosition(zoneId, rwX, rwY, rwZ)
    local _, rnwZ3 = GetRawNormalizedWorldPosition(zoneId, rwX, rwY, B)

    local linX, kX, bX = fitLinear(nwX1, rnwX1, nwX2, rnwX2, nwX3, rnwX3)
    local linZ, kZ, bZ = fitLinear(nwZ1, rnwZ1, nwZ2, rnwZ2, nwZ3, rnwZ3)

    Log('zoneId: %d, kX: %f, bX: %f', zoneId, kX, bX)
    Log('zoneId: %d, kZ: %f, bZ: %f', zoneId, kZ, bZ)

    return linX, linZ
end

local CALIBRATIONS = {}

local function clearCalibrations()
    ZO_ClearTable(CALIBRATIONS)
end

local function getCalibrations(zoneId)
    if not CALIBRATIONS[zoneId] then
        local zoneId_, rwX, rwY, rwZ = GetUnitRawWorldPosition('player')

        CONV_X, CONV_Z = getNWToRNWConversionFunctions(zoneId_, rwX, rwY, rwZ)
        CALIBRATION = {ImperialCartographer.Coordinates.GetCalibration(zoneId)}

        CALIBRATIONS[zoneId] = {
            CONV_X, CONV_Z, CALIBRATION
        }
    end

    return unpack(CALIBRATIONS[zoneId])
end

local function convertWtoRW(zoneId, wX, wY, wZ)
    local nwX, nwZ = GetNormalizedWorldPosition(zoneId, wX, wY, wZ)
    local rnwX_, rnwZ_ = GetRawNormalizedWorldPosition(zoneId, wX, wY, wZ)

    local CONV_X, CONV_Z, CALIBRATION = getCalibrations(zoneId)

    -- Log('A: %f %f', nwX, nwZ)
    -- Log('B: %f %f', rnwX_, rnwZ_)

    local rnwX = CONV_X(nwX)
    local rnwZ = CONV_Z(nwZ)

    local rwX, rwZ = ImperialCartographer.Coordinates.ConvertNormalizedToWorld(rnwX, rnwZ, CALIBRATION)

    return rwX, wY, rwZ
end

-- ----------------------------------------------------------------------------

ImperialCartographer = ImperialCartographer or {}
ImperialCartographer.Calculations = {
    -- NormalizedToWorld = normalizedToWorld,
    ClearCalibrations = clearCalibrations,
    ConvertWtoRW = convertWtoRW,
    GetNWToRNWConversionFunctions = getNWToRNWConversionFunctions,
}
