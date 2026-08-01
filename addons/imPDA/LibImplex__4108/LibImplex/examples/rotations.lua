local Log = LibImplex_Logger()

local Q = LibImplex.Q
local PI = math.pi
local ABS = math.abs

local fives = LibImplex.Objects('rotationsExample')

local T = 'LibImplex/textures/five.dds'
local S = {1.5, 1.5}

local DEFAULT_TOLERANCE = 0.000000001
local function wtl(v1, v2, tolerance)
    tolerance = tolerance or DEFAULT_TOLERANCE
    return ABS(v1 - v2) <= tolerance
end

local function placeMarkers()
    local m1 = fives._3DStatic({5135, 13500, 153600}, {0, 0, 0}, T, S, {1, 1, 1})
    m1:DrawNormal(50)

    local m2 = fives._3DStatic({5135, 13500, 153800}, {PI/4, 0, 0}, T, S, {1, 0, 0})
    m2:DrawNormal(50)

    local m3 = fives._3DStatic({5135, 13500, 154000}, {0, PI/4, 0}, T, S, {0, 1, 0})
    m3:DrawNormal(50)

    local m4 = fives._3DStatic({5135, 13500, 154200}, {0, 0, PI/4}, T, S, {0, 0, 1})
    m4:DrawNormal(50)

    -- GLOBAL_M1 = m1
    -- GLOBAL_M2 = m2
    -- GLOBAL_M3 = m3
    -- GLOBAL_M4 = m4

    -- 1. Test that identity quaternion gives zero rotations
    do
        Log('--- [1] Identity test ---')
        local identity = Q.FromEuler(0, 0, 0)
        local pitch, yaw, roll = identity:ToEuler()
        if yaw == 0 and pitch == 0 and roll == 0 then
            Log('[v] Identity test PASSED')
        else
            Log('[!] Identity test NOT PASSED')
        end
    end

    -- 2. Test conversion back and forth
    do
        Log('--- [2] Round-trip test ---')
        local test_angles = {PI/4, PI/6, PI/3}  -- 45°, 30°, 60°
        local q = Q.FromEuler(unpack(test_angles))
        local recovered = {q:ToEuler()}
        Log('Original: %.6f', unpack(test_angles))
        Log('Recovered: %.6f', unpack(recovered))
        if wtl(test_angles[1], recovered[1]) and wtl(test_angles[2], recovered[2]) and wtl(test_angles[3], recovered[3]) then
            Log('[v] Round-trip test PASSED')
        else
            Log('[!] Round-trip test NOT PASSED')
        end
    end

    -- 3. Test individual axes
    do
        Log('--- [3] Individual axis tests ---')
        local tests = {
            {PI/2, 0, 0},    -- 90° yaw (X)
            {0, PI/2, 0},    -- 90° pitch (Y)
            {0, 0, PI/2},    -- 90° roll (Z)
        }

        local allGood = true
        for i, angles in ipairs(tests) do
            local q = Q.FromEuler(unpack(angles))
            local recovered = {q:ToEuler()}
            Log(string.format('Test %d: Original %s → Recovered %s', i, table.concat(angles, ', '), table.concat(recovered, ', ')))

            if not wtl(angles[1], recovered[1]) and wtl(angles[2], recovered[2]) and wtl(angles[3], recovered[3]) then
                allGood = false
            end

            if allGood then
                Log('[v] Individual axis tests PASSED')
            else
                Log('[!] Individual axis tests NOT PASSED')
            end
        end
    end

    -- 4. Test that quaternion multiplication works correctly
    do
        Log('--- [4] Q Multiplication test ---')
        local q1 = Q.FromEuler(PI/4, 0, 0)  -- 45° yaw
        local q2 = Q.FromEuler(0, PI/4, 0)  -- 45° pitch

        -- Should be non-commutative
        local q12 = q1 * q2
        local q21 = q2 * q1

        Log('q1 * q2 ≠ q2 * q1')
        Log('q12{w:%.4f %.4f %.4f %.4f}', q12[1], q12[2], q12[3], q12[4])
        Log('q21{w:%.4f %.4f %.4f %.4f}', q21[1], q21[2], q21[3], q21[4])
    end
end

do
    EVENT_MANAGER:RegisterForEvent('LIB_IMPLEX_EXAMPLES_ROTATIONS', EVENT_PLAYER_ACTIVATED, placeMarkers)
end
