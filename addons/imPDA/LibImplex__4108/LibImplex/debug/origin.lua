local originObjects = LibImplex.Objects('origin')

-- ----------------------------------------------------------------------------

local TEXTURE = '/LibImplex/textures/arrow256x256.dds'

local HALF_PI = math.pi * 0.5
local W, H = 1, 1.5

local DEPTH_BUFFER = false

local ORIENTATION = {
    {0,         HALF_PI,    -HALF_PI},
    {0,         0,          0},
    {HALF_PI,   0,          0},
}

local COLOR = {
    {1, 0, 0},
    {0, 1, 0},
    {0, 0, 1},
}

local SYSTEMS = {
    {
        LibImplex.Systems.FollowThePlayer(200, 100, 0)
    },
    {
        LibImplex.Systems.Rotate3DWithCamera,
        LibImplex.Systems.FollowThePlayer(0, 300, 0),
    },
    {
        LibImplex.Systems.FollowThePlayer(0, 100, 200)
    },
}

-- ----------------------------------------------------------------------------

local objects = {}

local function DeleteOrigin()
    for i = 1, #objects do
        objects[i]:Delete()
        objects[i] = nil
    end
end

function LibImplex_ShowOrigin()
    DeleteOrigin()

    for i = 1, 3 do
        local originVector = originObjects._3D()
        for _, system in ipairs(SYSTEMS[i]) do
            originVector:AddSystem(system)
        end
        originVector:SetPosition(0, 0, 0)
        originVector:SetOrientation(unpack(ORIENTATION[i]))
        originVector:SetTexture(TEXTURE)
        originVector:SetDimensions(W, H)
        originVector:SetColor(unpack(COLOR[i]))
        originVector:AddSystem(LibImplex.Systems.DepthBuffer)

        objects[i] = originVector
    end
end

LibImplex_HideOrigin = DeleteOrigin
