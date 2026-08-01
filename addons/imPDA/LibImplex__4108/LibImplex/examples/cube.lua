local cubeObjects = LibImplex.Objects('cubeExample')

local Q = LibImplex.Q
local Rotate = Q.RotateVectorByQuaternion
local HALF_PI = math.pi / 2
local PI = math.pi
local COS_QUART_PI = math.cos(PI / 4)

local COLORS = {
    {1, 0, 0},  -- Front face
    {0, 0, 1},  -- Back face
    {1, 0, 1},  -- Top face
    {0, 1, 1},  -- Bottom face
    {0, 1, 0},  -- Right face
    {1, 1, 0},  -- Left face
}

local TEXTURES = {
    'LibImplex/textures/one.dds',
    'LibImplex/textures/two.dds',
    'LibImplex/textures/three.dds',
    'LibImplex/textures/four.dds',
    'LibImplex/textures/five.dds',
    'LibImplex/textures/six.dds',
}

-- ----------------------------------------------------------------------------

local Cube = LibImplex.class()

function Cube:__init(position, orientation, size)
    self.position = LibImplex.Vector(position)
    self.orientation = orientation

    self.size = size

    self:CalculateQ()

    self.objects = {}
    self:Draw()
end

function Cube:CalculateQ()
    self.Q = Q.FromEuler(unpack(self.orientation))

    self.F = self.Q:Rotate({0, 0, 1})
    self.U = self.Q:Rotate({0, 1, 0})
    self.R = self.Q:Rotate({-1, 0, 0})
end

local FACE_ORIENTATION_Q = {
        Q.FromEuler(0, 0, 0),           -- Front
        Q.FromEuler(0, PI, 0),          -- Back  
        Q.FromEuler(-HALF_PI, 0, 0),    -- Top
        Q.FromEuler(HALF_PI, 0, 0),     -- Bottom
        Q.FromEuler(0, -HALF_PI, 0),    -- Right
        Q.FromEuler(0, HALF_PI, 0),     -- Left
    }

function Cube:Draw()
    if #self.objects == 6 then return end

    local halfSize = self.size * 50
    local _size = {self.size, self.size}

    local faceDisplacements = {
         self.F * halfSize,
        -self.F * halfSize,
         self.U * halfSize,
        -self.U * halfSize,
         self.R * halfSize,
        -self.R * halfSize,
    }

    for i = 1, 6 do
        local faceOrientation = {(self.Q * FACE_ORIENTATION_Q[i]):ToEuler()}
        faceOrientation[4] = true

        self.objects[i] = cubeObjects._3D(
            self.position + faceDisplacements[i],
            faceOrientation,
            nil,  -- TEXTURES[i],
            _size,
            COLORS[i]
        )
        -- self.objects[i]:DrawNormal(30)
        self.objects[i].control:SetPixelRoundingEnabled(false)
    end
end

function Cube:Rotate(pitch, yaw, roll)
    self.orientation = {pitch, yaw, roll}
    self:CalculateQ()

    if #self.objects == 0 then
        self:Draw()
    else
        local halfSize = self.size * 50
        local faceDisplacements = {
            self.F * halfSize,
            -self.F * halfSize,
            self.U * halfSize,
            -self.U * halfSize,
            self.R * halfSize,
            -self.R * halfSize,
        }

        for i = 1, 6 do
            self.objects[i]:Move(self.position + faceDisplacements[i])

            local faceOrientation = {(self.Q * FACE_ORIENTATION_Q[i]):ToEuler()}
            self.objects[i]:Orient(faceOrientation)
            -- self.objects[i]:DrawNormal(30)
        end
    end
end

function Cube:Clear()
    for i = 1, #self.objects do
        self.objects[i]:Delete()
        self.objects[i] = nil
    end
end

function Cube:SetColor(color)
    self.color = color

    for i = 1, #self.objects do
        self.objects[i]:SetColor(unpack(color))
    end
end

local IMP_CUBE

local POSITION = LibImplex.Vector({5230, 13460, 155820})
local function cubeExample()
    local cube = Cube(
        POSITION,                       -- position in 3D {x, y, z}
        {0, 0, 0},                      -- orientation {pitch, yaw, roll}
        1                               -- size in meters
    )
    IMP_CUBE = cube
end


do
    EVENT_MANAGER:RegisterForEvent('LIB_IMPLEX_EXAMPLES_CUBE', EVENT_PLAYER_ACTIVATED, cubeExample)

    local speed = 2 * PI / 5000
    local start = GetGameTimeMilliseconds()
    EVENT_MANAGER:RegisterForUpdate('LIB_IMPLEX_EXAMPLES_CUBE', nil, function()
        if IMP_CUBE then
            local progress = ((GetGameTimeMilliseconds() - start) % 5000) * speed
            IMP_CUBE:Rotate(progress, progress, progress)
        end
    end)
end
