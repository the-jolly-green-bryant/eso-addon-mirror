local E = 1000000

local function getCalibration(zoneId, El)
    -- SetMapToMapId(*integer* _mapId_)
    -- local mapId = GetCurrentMapId()

    El = El or E

    local bX, bZ = GetRawNormalizedWorldPosition(zoneId, 0, 0, 0)

    local n1X, n1Z = GetRawNormalizedWorldPosition(zoneId, El, 0, 0)
    local n2X, n2Z = GetRawNormalizedWorldPosition(zoneId, 0, 0, El)
    -- local n3X, n3Z = GetRawNormalizedWorldPosition(zoneId, El, 0, El)

    -- local n0X_nr, n0Z_nr = GetNormalizedWorldPosition(zoneId, 0, 0, 0)
    -- local n1X_nr, n1Z_nr = GetNormalizedWorldPosition(zoneId, El, 0, 0)
    -- local n2X_nr, n2Z_nr = GetNormalizedWorldPosition(zoneId, 0, 0, El)
    -- local n3X_nr, n3Z_nr = GetNormalizedWorldPosition(zoneId, El, 0, El)

    -- Log('n0x: %.4f, n0z: %.4f', bX, bZ)
    -- Log('n1x: %.4f, n1z: %.4f', n1X, n1Z)
    -- Log('n2x: %.4f, n2z: %.4f', n2X, n2Z)
    -- Log('n3x: %.4f, n3z: %.4f', n3X, n3Z)
    -- Log('n0x_nr: %.4f, n0z_nr: %.4f', n0X_nr, n0Z_nr)
    -- Log('n1x_nr: %.4f, n1z_nr: %.4f', n1X_nr, n1Z_nr)
    -- Log('n2x_nr: %.4f, n2z_nr: %.4f', n2X_nr, n2Z_nr)
    -- Log('n3x_nr: %.4f, n3z_nr: %.4f', n3X_nr, n3Z_nr)
    -- Log('------------------------------------------')

    --[[
    if n1X_nr ~= n1X or n1Z_nr ~= n1Z or n2X_nr ~= n2X or n2Z_nr ~= n2Z then
        Log('ACHTUNG! zoneId: %d', zoneId)

        Log('n0x: %.4f, n0z: %.4f', bX, bZ)
        Log('n1x: %.4f, n1z: %.4f', n1X, n1Z)
        Log('n2x: %.4f, n2x: %.4f', n2X, n2Z)

        Log('n1x_nr: %.4f, n1z_nr: %.4f', n1X_nr, n1Z_nr)
        Log('n2x_nr: %.4f, n2z_nr: %.4f', n2X_nr, n2Z_nr)
        Log('------------------------------------------')
    end
    --]]

    local nX, nZ = n1X - bX, n2Z - bZ

    if bX ~= n2X or bZ ~= n1Z then error('Weird calibration') end

    -- return nX, nZ, bX, bZ
    return nX, bX, nZ, bZ
end

local function getWorldCalibration(zoneId, x1, y1, z1, x2, y2, z2)
    --[[
    local bX, bZ = GetNormalizedWorldPosition(zoneId, x1, y1, z1)

    local n1X, n1Z = GetNormalizedWorldPosition(zoneId, x2, y1, z1)
    local n2X, n2Z = GetNormalizedWorldPosition(zoneId, x1, y1, z2)
    -- local n3X, n3Z = GetNormalizedWorldPosition(zoneId, x2, y1, z2)

    local nX, nZ = n1X - bX, n2Z - bZ

    if bX ~= n2X or bZ ~= n1Z then error('Weird world calibration') end

    return nX, bX, nZ, bZ
    --]]

    local n1X, n1Z = GetNormalizedWorldPosition(zoneId, x1, y1, z1)
    local n2X, n2Z = GetNormalizedWorldPosition(zoneId, x2, y2, z2)

    local nX = (n1X - n2X) / (x1 - x2)
    local bX = n1X - x1 * nX

    local nZ = (n1Z - n2Z) / (z1 - z2)
    local bZ = n1Z - z1 * nZ

    return nX, bX, nZ, bZ
end

local function normalizedToWorld(nX, nZ, calibration)
    local wX = E / calibration[1] * (nX - calibration[2])
    local wZ = E / calibration[3] * (nZ - calibration[4])

    return wX, wZ
end

-- ----------------------------------------------------------------------------

-- TODO: refactor calculations
assert(ImperialCartographer)
ImperialCartographer.Coordinates = {
    GetCalibration = getCalibration,
    GetWorldCalibration = getWorldCalibration,
    ConvertNormalizedToWorld = normalizedToWorld,
}