-- -----------------------------------------------------------------------------
-- Vector3D - 3D vector math library
-- -----------------------------------------------------------------------------

--- @class LibVectorMath
local LibVectorMath = _G.LibVectorMath
LibVectorMath.Vector3D = LibVectorMath.Vector3D

--- @class Vector3DMixin : ZO_InitializingObject
--- @field x number X component of the 3D vector
--- @field y number Y component of the 3D vector
--- @field z number Z component of the 3D vector

-- -----------------------------------------------------------------------------
-- Lua Locals.
-- -----------------------------------------------------------------------------

local cos = zo_cos
local sin = zo_sin
local atan2 = zo_atan2
local asin = math.asin -- no zo_asin :(
local sqrt = zo_sqrt

-- -----------------------------------------------------------------------------

--- Scales a 3D vector by a scalar value
--- @param scalar number The scaling factor
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @param z number The z component of the vector
--- @return number x The scaled x component
--- @return number y The scaled y component
--- @return number z The scaled z component
function LibVectorMath.Vector3D.ScaleBy(scalar, x, y, z)
    return x * scalar, y * scalar, z * scalar
end

--- Divides a 3D vector by a scalar value
--- @param divisor number The divisor
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @param z number The z component of the vector
--- @return number x The divided x component
--- @return number y The divided y component
--- @return number z The divided z component
function LibVectorMath.Vector3D.DivideBy(divisor, x, y, z)
    return x / divisor, y / divisor, z / divisor
end

--- Adds two 3D vectors
--- @param leftX number The x component of the first vector
--- @param leftY number The y component of the first vector
--- @param leftZ number The z component of the first vector
--- @param rightX number The x component of the second vector
--- @param rightY number The y component of the second vector
--- @param rightZ number The z component of the second vector
--- @return number x The x component of the resulting vector
--- @return number y The y component of the resulting vector
--- @return number z The z component of the resulting vector
function LibVectorMath.Vector3D.Add(leftX, leftY, leftZ, rightX, rightY, rightZ)
    return leftX + rightX, leftY + rightY, leftZ + rightZ
end

--- Subtracts the second 3D vector from the first
--- @param leftX number The x component of the first vector
--- @param leftY number The y component of the first vector
--- @param leftZ number The z component of the first vector
--- @param rightX number The x component of the second vector
--- @param rightY number The y component of the second vector
--- @param rightZ number The z component of the second vector
--- @return number x The x component of the resulting vector
--- @return number y The y component of the resulting vector
--- @return number z The z component of the resulting vector
function LibVectorMath.Vector3D.Subtract(leftX, leftY, leftZ, rightX, rightY, rightZ)
    return leftX - rightX, leftY - rightY, leftZ - rightZ
end

--- Calculates the cross product of two 3D vectors
--- @param leftX number The x component of the first vector
--- @param leftY number The y component of the first vector
--- @param leftZ number The z component of the first vector
--- @param rightX number The x component of the second vector
--- @param rightY number The y component of the second vector
--- @param rightZ number The z component of the second vector
--- @return number x The x component of the resulting vector
--- @return number y The y component of the resulting vector
--- @return number z The z component of the resulting vector
function LibVectorMath.Vector3D.Cross(leftX, leftY, leftZ, rightX, rightY, rightZ)
    return leftY * rightZ - leftZ * rightY, leftZ * rightX - leftX * rightZ, leftX * rightY - leftY * rightX
end

--- Calculates the dot product of two 3D vectors
--- @param leftX number The x component of the first vector
--- @param leftY number The y component of the first vector
--- @param leftZ number The z component of the first vector
--- @param rightX number The x component of the second vector
--- @param rightY number The y component of the second vector
--- @param rightZ number The z component of the second vector
--- @return number dot The dot product
function LibVectorMath.Vector3D.Dot(leftX, leftY, leftZ, rightX, rightY, rightZ)
    return leftX * rightX + leftY * rightY + leftZ * rightZ
end

--- Calculates the squared length (magnitude) of a 3D vector
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @param z number The z component of the vector
--- @return number lengthSquared The squared length of the vector
function LibVectorMath.Vector3D.GetLengthSquared(x, y, z)
    return LibVectorMath.Vector3D.Dot(x, y, z, x, y, z)
end

--- Calculates the length (magnitude) of a 3D vector
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @param z number The z component of the vector
--- @return number length The length of the vector
function LibVectorMath.Vector3D.GetLength(x, y, z)
    return sqrt(LibVectorMath.Vector3D.GetLengthSquared(x, y, z))
end

--- Normalizes a 3D vector (makes it unit length)
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @param z number The z component of the vector
--- @return number x The x component of the normalized vector
--- @return number y The y component of the normalized vector
--- @return number z The z component of the normalized vector
function LibVectorMath.Vector3D.Normalize(x, y, z)
    return LibVectorMath.Vector3D.DivideBy(LibVectorMath.Vector3D.GetLength(x, y, z), x, y, z)
end

--- Adds two 3D vector objects and returns a new vector
--- @param left Vector3DMixin The first vector
--- @param right Vector3DMixin The second vector
--- @return Vector3DMixin result A new vector containing the sum
function LibVectorMath.Vector3D.AddVector(left, right)
    local clone = left:Clone()
    clone:Add(right)
    return clone
end

--- Subtracts the second 3D vector object from the first and returns a new vector
--- @param left Vector3DMixin The first vector
--- @param right Vector3DMixin The second vector
--- @return Vector3DMixin result A new vector containing the difference
function LibVectorMath.Vector3D.SubtractVector(left, right)
    local clone = left:Clone()
    clone:Subtract(right)
    return clone
end

--- Normalizes a 3D vector object and returns a new vector
--- @param vector Vector3DMixin The vector to normalize
--- @return Vector3DMixin result A new normalized vector
function LibVectorMath.Vector3D.NormalizeVector(vector)
    local clone = vector:Clone()
    clone:Normalize()
    return clone
end

--- Scales a 3D vector object by a scalar and returns a new vector
--- @param scalar number The scaling factor
--- @param vector Vector3DMixin The vector to scale
--- @return Vector3DMixin result A new scaled vector
function LibVectorMath.Vector3D.ScaleVector(scalar, vector)
    local clone = vector:Clone()
    clone:ScaleBy(scalar)
    return clone
end

--- Calculates a normal vector from yaw and pitch angles
--- @param yaw number The yaw angle in radians
--- @param pitch number The pitch angle in radians
--- @return number x The x component of the normal vector
--- @return number y The y component of the normal vector
--- @return number z The z component of the normal vector
function LibVectorMath.Vector3D.CalculateNormalFromYawPitch(yaw, pitch)
    return cos(-pitch) * cos(yaw),
        cos(-pitch) * sin(yaw),
        sin(-pitch)
end

--- Calculates yaw and pitch angles from a normal vector's components
--- @param x number The x component of the normal vector
--- @param y number The y component of the normal vector
--- @param z number The z component of the normal vector
--- @return number yaw The yaw angle in radians
--- @return number pitch The pitch angle in radians
function LibVectorMath.Vector3D.CalculateYawPitchFromNormal(x, y, z)
    if x ~= 0 or y ~= 0 then
        return atan2(y, x), asin(-z)
    end

    return 0, asin(-z)
end

--- Calculates yaw and pitch angles from a normal vector object
--- @param vector Vector3DMixin The normal vector
--- @return number yaw The yaw angle in radians
--- @return number pitch The pitch angle in radians
function LibVectorMath.Vector3D.CalculateYawPitchFromNormalVector(vector)
    return LibVectorMath.Vector3D.CalculateYawPitchFromNormal(vector:GetXYZ())
end

--- Creates a normal vector object from yaw and pitch angles
--- @param yawRadians number The yaw angle in radians
--- @param pitchRadians number The pitch angle in radians
--- @return Vector3DMixin vector The created normal vector object
function LibVectorMath.Vector3D.CreateNormalVectorFromYawPitch(yawRadians, pitchRadians)
    return LibVectorMath.Vector3D.Create(LibVectorMath.Vector3D.CalculateNormalFromYawPitch(yawRadians, pitchRadians))
end

-- Create the mixin
LibVectorMath.Vector3DMixin = ZO_InitializingObject:Subclass()

--- Creates a new 3D vector
--- @param x number The x component
--- @param y number The y component
--- @param z number The z component
--- @return Vector3DMixin vector The created 3D vector object
function LibVectorMath.Vector3D.Create(x, y, z)
    local vector = setmetatable({}, LibVectorMath.Vector3DMixin)
    vector:Initialize(x, y, z)
    return vector
end

--- Checks if two 3D vectors are equal
--- @param left Vector3DMixin|nil The first vector
--- @param right Vector3DMixin|nil The second vector
--- @return boolean equal True if the vectors are equal
function LibVectorMath.Vector3D.AreEqual(left, right)
    if left and right then
        return left:IsEqualTo(right)
    end
    return left == right
end

--- Initializes a 3D vector with x, y, and z components
--- @param x number The x component
--- @param y number The y component
--- @param z number The z component
function LibVectorMath.Vector3DMixin:Initialize(x, y, z)
    self:SetXYZ(x, y, z)
end

--- Checks if this vector is equal to another vector
--- @param otherVector Vector3DMixin The vector to compare with
--- @return boolean equal True if the vectors are equal
function LibVectorMath.Vector3DMixin:IsEqualTo(otherVector)
    return self.x == otherVector.x
        and self.y == otherVector.y
        and self.z == otherVector.z
end

--- Gets the x, y, and z components of the vector
--- @return number x The x component
--- @return number y The y component
--- @return number z The z component
function LibVectorMath.Vector3DMixin:GetXYZ()
    return self.x, self.y, self.z
end

--- Sets the x, y, and z components of the vector
--- @param x number The x component
--- @param y number The y component
--- @param z number The z component
function LibVectorMath.Vector3DMixin:SetXYZ(x, y, z)
    self.x = x
    self.y = y
    self.z = z
end

--- Scales the vector by a scalar value
--- @param scalar number The scaling factor
--- @return Vector3DMixin self The scaled vector (self)
function LibVectorMath.Vector3DMixin:ScaleBy(scalar)
    self:SetXYZ(LibVectorMath.Vector3D.ScaleBy(scalar, self:GetXYZ()))
    return self
end

--- Divides the vector by a scalar value
--- @param scalar number The divisor
--- @return Vector3DMixin self The divided vector (self)
function LibVectorMath.Vector3DMixin:DivideBy(scalar)
    self:SetXYZ(LibVectorMath.Vector3D.DivideBy(scalar, self:GetXYZ()))
    return self
end

--- Adds another vector to this vector
--- @param other Vector3DMixin The vector to add
--- @return Vector3DMixin self The resulting vector (self)
function LibVectorMath.Vector3DMixin:Add(other)
    self:SetXYZ(LibVectorMath.Vector3D.Add(self.x, self.y, self.z, other:GetXYZ()))
    return self
end

--- Subtracts another vector from this vector
--- @param other Vector3DMixin The vector to subtract
--- @return Vector3DMixin self The resulting vector (self)
function LibVectorMath.Vector3DMixin:Subtract(other)
    self:SetXYZ(LibVectorMath.Vector3D.Subtract(self.x, self.y, self.z, other:GetXYZ()))
    return self
end

--- Calculates the cross product with another vector
--- @param other Vector3DMixin The vector to cross with
--- @return Vector3DMixin self The resulting vector (self)
function LibVectorMath.Vector3DMixin:Cross(other)
    self:SetXYZ(LibVectorMath.Vector3D.Cross(self.x, self.y, self.z, other:GetXYZ()))
    return self
end

--- Calculates the dot product with another vector
--- @param other Vector3DMixin The vector to dot with
--- @return number dot The dot product
function LibVectorMath.Vector3DMixin:Dot(other)
    return LibVectorMath.Vector3D.Dot(self.x, self.y, self.z, other:GetXYZ())
end

--- Gets the squared length (magnitude) of the vector
--- @return number lengthSquared The squared length of the vector
function LibVectorMath.Vector3DMixin:GetLengthSquared()
    return LibVectorMath.Vector3D.GetLengthSquared(self:GetXYZ())
end

--- Gets the length (magnitude) of the vector
--- @return number length The length of the vector
function LibVectorMath.Vector3DMixin:GetLength()
    return LibVectorMath.Vector3D.GetLength(self:GetXYZ())
end

--- Normalizes the vector (makes it unit length)
--- @return Vector3DMixin self The normalized vector (self)
function LibVectorMath.Vector3DMixin:Normalize()
    self:SetXYZ(LibVectorMath.Vector3D.Normalize(self:GetXYZ()))
    return self
end

--- Creates a copy of this vector
--- @return Vector3DMixin clone The cloned vector
function LibVectorMath.Vector3DMixin:Clone()
    return LibVectorMath.Vector3D.Create(self:GetXYZ())
end

return LibVectorMath
