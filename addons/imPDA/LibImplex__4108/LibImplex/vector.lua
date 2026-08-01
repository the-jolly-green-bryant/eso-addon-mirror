local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos

local mt = {
    __call = function(cls, obj)
        return setmetatable(obj, cls)
    end
}

--- @class Vector
local Vector = setmetatable({}, mt)
Vector.__index = Vector

function Vector.len(v)
    return sqrt(v:dot(v))
end

function Vector.add(v1, v2)
    return Vector({
        v1[1] + v2[1],
        v1[2] + v2[2],
        v1[3] + v2[3]
    })
end

function Vector.sub(v1, v2)
    return Vector({
        v1[1] - v2[1],
        v1[2] - v2[2],
        v1[3] - v2[3]
    })
end

function Vector.negate(v)
    return Vector({-v[1], -v[2], -v[3]})
end

function Vector.multiply(v, scalar)
    -- TODO: get rid of assertion
    -- assert(type(scalar) == 'number', 'Scalar must be numeric type value, got %s instead', type(scalar))
    return Vector({v[1] * scalar, v[2] * scalar, v[3] * scalar})
end

function Vector.dot(v1, v2)
    return v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]
end

function Vector.cross(v1, v2)
    return Vector({
        v1[2] * v2[3] - v1[3] * v2[2],
        v1[3] * v2[1] - v1[1] * v2[3],
        v1[1] * v2[2] - v1[2] * v2[1]
    })
end

function Vector.unit(v)
    local inverse_length = 1 / v:len()
    return v * inverse_length
end

function Vector.coordinates(v)
    return v[1], v[2], v[3]
end

-- function Vector.lt(v1, v2)
--     return v1:dot(v1) < v2:dot(v2)
-- end

-- function Vector.le(v1, v2)
--     return v1:dot(v1) <= v2:dot(v2)
-- end

function Vector.eq(v1, v2)
    return v1[1] == v2[1] and v1[2] == v2[2] and v1[3] == v2[3]
end

Vector.__eq = Vector.eq
Vector.__len = Vector.len
Vector.__add = Vector.add
Vector.__sub = Vector.sub
Vector.__unm = Vector.negate
Vector.__mul = Vector.multiply
-- Vector.__lt = Vector.lt
-- Vector.__le = Vector.le

-- ----------------------------------------------------------------------------

--- @class Quaternion
local Quaternion = setmetatable({}, mt)
Quaternion.__index = Quaternion

function Quaternion.FromEuler(roll, pitch, yaw)
    local hr = roll/2
    local hp = pitch/2
    local hy = yaw/2

    local cr = cos(hr)
    local sr = sin(hr)
    local cp = cos(hp)
    local sp = sin(hp)
    local cy = cos(hy)
    local sy = sin(hy)

    return Quaternion({
        --[[w]] cr * cp * cy + sr * sp * sy,
        --[[i]] sr * cp * cy - cr * sp * sy,
        --[[j]] cr * sp * cy + sr * cp * sy,
        --[[k]] cr * cp * sy - sr * sp * cy,
    })
end

local function copysign(x, y)
    return (y >= 0 and math.abs(x)) or -math.abs(x)
end

function Quaternion.ToEuler(q)
    local w, x, y, z = q[1], q[2], q[3], q[4]

    -- Roll (Z-axis rotation)
    local sinr_cosp = 2 * (w * z + x * y)
    local cosr_cosp = 1 - 2 * (y * y + z * z)
    local roll = math.atan2(sinr_cosp, cosr_cosp)

    -- Yaw (Y-axis rotation)
    local siny_cosp = 2 * (w * y - z * x)
    local yaw
    if math.abs(siny_cosp) >= 1 then
        yaw = copysign(math.pi / 2, siny_cosp)
    else
        yaw = math.asin(siny_cosp)
    end

    -- Pitch (X-axis rotation)
    local sinp_cosp = 2 * (w * x + y * z)
    local cosp_cosp = 1 - 2 * (x * x + y * y)
    local pitch = math.atan2(sinp_cosp, cosp_cosp)

    return pitch, yaw, roll
end

local function RotateVectorByQuaternion(v, q)
    local v_quat = Quaternion({0, v[1], v[2], v[3]})
    local q_conj = Quaternion({q[1], -q[2], -q[3], -q[4]})

    local result_quat = q * v_quat * q_conj

    return Vector({result_quat[2], result_quat[3], result_quat[4]})
end

local function ComputeRotationMatrix(roll, pitch, yaw)
    local cr, sr = cos(roll), sin(roll)
    local cp, sp = cos(pitch), sin(pitch)
    local cy, sy = cos(yaw), sin(yaw)

    return {
        cy * cp, cy * sp * sr - sy * cr, cy * sp * cr + sy * sr,
        sy * cp, sy * sp * sr + cy * cr, sy * sp * cr - cy * sr,
        -sp,     cp * sr,                  cp * cr
    }
end

local function ApplyRotationMatrix(M, vx, vy, vz)
    local rx = M[1] * vx + M[2] * vy + M[3] * vz
    local ry = M[4] * vx + M[5] * vy + M[6] * vz
    local rz = M[7] * vx + M[8] * vy + M[9] * vz

    return rx, ry, rz
end

local function RotateVectorByEuler(vx, vy, vz, roll, pitch, yaw)
    local cr, sr = cos(roll), sin(roll)
    local cp, sp = cos(pitch), sin(pitch)
    local cy, sy = cos(yaw), sin(yaw)

    -- XYZ order: Rz * Ry * Rx
    local r11 = cy * cp
    local r12 = cy * sp * sr - sy * cr
    local r13 = cy * sp * cr + sy * sr
    local r21 = sy * cp
    local r22 = sy * sp * sr + cy * cr
    local r23 = sy * sp * cr - cy * sr
    local r31 = -sp
    local r32 = cp * sr
    local r33 = cp * cr

    local rx = r11 * vx + r12 * vy + r13 * vz
    local ry = r21 * vx + r22 * vy + r23 * vz
    local rz = r31 * vx + r32 * vy + r33 * vz

    return rx, ry, rz
end

Quaternion.RotateVectorByQuaternion = RotateVectorByQuaternion
Quaternion.RotateVectorByEuler = RotateVectorByEuler
Quaternion.ComputeRotationMatrix = ComputeRotationMatrix
Quaternion.ApplyRotationMatrix = ApplyRotationMatrix

function Quaternion:Rotate(v)
    return RotateVectorByQuaternion(v, self)
end

function Quaternion.multiply(q1, q2)
    return Quaternion({
        --[[w]] q1[1] * q2[1] - q1[2] * q2[2] - q1[3] * q2[3] - q1[4] * q2[4],
        --[[i]] q1[1] * q2[2] + q1[2] * q2[1] + q1[3] * q2[4] - q1[4] * q2[3],
        --[[j]] q1[1] * q2[3] - q1[2] * q2[4] + q1[3] * q2[1] + q1[4] * q2[2],
        --[[k]] q1[1] * q2[4] + q1[2] * q2[3] - q1[3] * q2[2] + q1[4] * q2[1],
    })
end

Quaternion.__mul = Quaternion.multiply
-- ----------------------------------------------------------------------------

LibImplex = LibImplex or {}

LibImplex.Vector = Vector

LibImplex.Q = Quaternion