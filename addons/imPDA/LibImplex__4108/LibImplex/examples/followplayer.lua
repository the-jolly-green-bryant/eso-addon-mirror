local TEXTURE = 'EsoUI/Art/TargetMarkers/Target_Blue_Square_64.dds'

local function followPlayer(marker, distance, prwX, prwY, prwZ, fX, fY, fZ, rX, rY, rZ, uX, uY, uZ)
    marker:Set3DWorldPosition(prwX, prwY, prwZ)
end

local function followAbovePlayer(marker, distance, prwX, prwY, prwZ, fX, fY, fZ, rX, rY, rZ, uX, uY, uZ)
    marker:Set3DWorldPosition(prwX, prwY + 250, prwZ)
end

local function activateCircle()
    LibImplex.Objects()._3D(
        {0, 0, 0},  -- position (does not matter now, position will be updated every frame)
        {math.pi / 2, 0, 0, true},  -- rotate to make horizontal
        TEXTURE,  -- texture filename
        {6, 6}, -- W x H in meters
        nil,  -- color (optional) in {r, g, b}, 0 <= r, g, b <= 1
        followPlayer  -- special function to follow player position
    )

    LibImplex.Objects._3D(
        {0, 0, 0},
        {math.pi / 2, 0, 0, true},
        TEXTURE,
        {6, 6},
        nil,
        followAbovePlayer
    )
end


do
    EVENT_MANAGER:RegisterForEvent('LIB_IMPLEX_EXAMPLES_FOLLOW_PLAYER', EVENT_PLAYER_ACTIVATED, activateCircle)
end
