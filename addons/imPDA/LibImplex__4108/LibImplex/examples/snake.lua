local snakeObjects = LibImplex.Objects('snakeExample')

local Q = LibImplex.Q
local HALF_PI = math.pi * 0.5
local PI = math.pi

-- ----------------------------------------------------------------------------

local LightPosition = LibImplex.Vector({5270, 13500+3000, 155120})
local RoomCenter = LibImplex.Vector({5270, 13500, 155120})

local SHINESS = 16
local BP = LibImplex.Systems.Lighting2(LightPosition, SHINESS, 0.1)

-- ----------------------------------------------------------------------------

local Cube = LibImplex.class()

function Cube:__init(position, orientation, size, color)
    self.position = LibImplex.Vector(position)
    self.orientation = orientation

    -- self.orientation[4] = true

    self.size = size
    self.color = LibImplex.Vector(color)

    self.Q = Q.FromEuler(unpack(orientation))

    self.top = {Q.ToEuler(Q.FromEuler(-HALF_PI, 0, 0) * self.Q)}
    self.bottom = {Q.ToEuler(Q.FromEuler(HALF_PI, 0, 0) * self.Q)}
    self.right = {Q.ToEuler(Q.FromEuler(0, HALF_PI, 0) * self.Q)}
    self.left = {Q.ToEuler(Q.FromEuler(0, -HALF_PI, 0) * self.Q)}
    self.front = orientation
    self.back = {Q.ToEuler(Q.FromEuler(0, PI, 0) * self.Q)}

    self.F = self.Q:Rotate({0, 0, 1})
    self.U = self.Q:Rotate({0, 1, 0})
    self.R = self.Q:Rotate({1, 0, 0})

    self.faces = {}
    self:Draw()
end

local FRU = {
    { 1,  0,  0},
    {-1,  0,  0},
    { 0,  1,  0},
    { 0, -1,  0},
    { 0,  0,  1},
    { 0,  0, -1},
}

local ORIENTATION = {
    'front',
    'back',
    'right',
    'left',
    'top',
    'bottom',
}

function Cube:Draw()
    local halfSize = self.size * 0.5 * 100
    local position = self.position
    local F = self.F
    local R = self.R
    local U = self.U

    for i = 1, 6 do
        local face = snakeObjects._3D()
        local f, r, u = unpack(FRU[i])

        face:SetPosition(unpack(position + F * halfSize * f + R * halfSize * r + U * halfSize * u))
        face:SetOrientation(unpack(self[ORIENTATION[i]]))
        face:SetDimensions(self.size, self.size)

        -- local N = LibImplex.Vector({wall[ 8], wall[ 9], wall[10]})
        -- local P = LibImplex.Vector({wall[ 1], wall[ 2], wall[ 3]})
        -- local L = (LightPosition - P):unit()
        -- local theta = math.max(0, L:dot(N))  -- Lambertian

        -- wall:SetColor(unpack(self.color * theta))
        face:SetColor(unpack(self.color))

        face:AddSystem(LibImplex.Systems.DepthBuffer)
        face:AddSystem(BP)
        face:AddSystem(LibImplex.Systems.BackFaceCulling)

        if i <= 4 then
            face.control:SetVertexUV(VERTEX_POINTS_TOPLEFT, 0.0, 1.0)
            face.control:SetVertexUV(VERTEX_POINTS_TOPRIGHT, 1.0, 1.0)
            face.control:SetVertexUV(VERTEX_POINTS_BOTTOMLEFT, 0.0, 0.3)
            face.control:SetVertexUV(VERTEX_POINTS_BOTTOMRIGHT, 1.0, 0.3)
        end

        self.faces[i] = face
    end

    -- self:DrawNormals()
end

function Cube:DrawNormals()
    for i = 1, #self.faces do
        self.faces[i]:DrawNormal(10)
    end
end

function Cube:Clear()
    for i = 1, #self.faces do
        self.faces[i]:Delete()
        self.faces[i] = nil
    end
end

function Cube:SetColor(color)
    self.color = color

    for i = 1, #self.faces do
        self.faces[i]:SetColor(unpack(color))
    end
end

local function snakeExample()
    local startPosition = LibImplex.Vector({5230, 13460, 155820})
    local f = LibImplex.Vector({0, 0, 60})
    local s = LibImplex.Vector({60, 0, 0})

    local changes = {
        {0, 0},
        {1, 0},
        {1, 0},
        {1, 0},
        {0, 1},
        {1, 0},
        {1, 0},
        {0, -1},
        {0, -1},
        {0, -1},
        {0, -1},
        {1, 0},
        {1, 0},
        {1, 0},
        {1, 0},
        {0, 1},
        {0, 1},
        {0, 1},
        {0, 1},
        {0, 1},
        {0, 1},
    }

    local position = startPosition

    local body = {}
    for i = 1, #changes do
        position = position + f * changes[i][1] + s * changes[i][2]
        body[i] = Cube(
            position,  -- position in 3D {x, y, z}
            {0, 0, 0},  -- orientation {yaw, pitch, roll}
            0.5,  -- size in meters
            {50 / 255, 200 / 255, 50 / 255}  -- color {r, g, b, a}
        )
    end

    -- body[1]:SetColor(50 / 255, 150 / 255, 0)

    local lightSource = snakeObjects._2D()
    lightSource:SetPosition(unpack(LightPosition))
    lightSource:SetTexture('/esoui/art/miscellaneous/gamepad/gp_bullet.dds')
    lightSource:SetDimensions(32, 32)

    -- local direction = -1
    -- local speed = 100 / 100  -- cm / ms
    -- EVENT_MANAGER:RegisterForUpdate('IMP_SNAKE_EVENT_NAMESPACE', 0, function()
    --     if LightPosition[2] < 13500 - 3000 or LightPosition[2] > 13500 + 3000 then
    --         direction = direction * -1
    --     end
    --     LightPosition[2] = LightPosition[2] + direction * GetFrameDeltaMilliseconds() * speed
    --     lightSource:SetPosition(unpack(LightPosition))
    -- end)

    local phi = 0
    local speed = PI / 2 / 3000  -- rad / ms
    local RADIUS = 3000
    EVENT_MANAGER:RegisterForUpdate('IMP_SNAKE_EVENT_NAMESPACE', 0, function()
        phi = phi + GetFrameDeltaMilliseconds() * speed
        LightPosition[1] = RoomCenter[1] + RADIUS * math.cos(phi)
        LightPosition[2] = RoomCenter[2] + RADIUS * math.sin(phi)
        lightSource:SetPosition(unpack(LightPosition))
    end)
end


do
    EVENT_MANAGER:RegisterForEvent('LIB_IMPLEX_EXAMPLES_SNAKE', EVENT_PLAYER_ACTIVATED, snakeExample)
end
