-- -----------------------------------------------------------------------------
-- Vector4D - 4D vector math library
-- -----------------------------------------------------------------------------

--- @class LibVectorMath
local LibVectorMath = _G.LibVectorMath
LibVectorMath.Vector4D = LibVectorMath.Vector4D

--- @class Vector4DMixin : ZO_InitializingObject
--- @field x number X component of the 4D vector
--- @field y number Y component of the 4D vector
--- @field z number Z component of the 4D vector
--- @field w number W component of the 4D vector

-- -----------------------------------------------------------------------------
-- Lua Locals.
-- -----------------------------------------------------------------------------

local cos = zo_cos
local sin = zo_sin
local atan2 = zo_atan2
local asin = math.asin -- no zo_asin :(
local sqrt = zo_sqrt

-- -----------------------------------------------------------------------------

--- Scales a 4D vector by a scalar value
--- @param scalar number The scaling factor
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @param z number The z component of the vector
--- @param w number The w component of the vector
--- @return number x The scaled x component
--- @return number y The scaled y component
--- @return number z The scaled z component
--- @return number w The scaled w component
function LibVectorMath.Vector4D.ScaleBy(scalar, x, y, z, w)
    return x * scalar, y * scalar, z * scalar, w * scalar
end

--- Divides a 4D vector by a scalar value
--- @param divisor number The divisor
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @param z number The z component of the vector
--- @param w number The w component of the vector
--- @return number x The divided x component
--- @return number y The divided y component
--- @return number z The divided z component
--- @return number w The divided w component
function LibVectorMath.Vector4D.DivideBy(divisor, x, y, z, w)
    return x / divisor, y / divisor, z / divisor, w / divisor
end

--- Adds two 4D vectors
--- @param leftX number The x component of the first vector
--- @param leftY number The y component of the first vector
--- @param leftZ number The z component of the first vector
--- @param leftW number The w component of the first vector
--- @param rightX number The x component of the second vector
--- @param rightY number The y component of the second vector
--- @param rightZ number The z component of the second vector
--- @param rightW number The w component of the second vector
--- @return number x The x component of the resulting vector
--- @return number y The y component of the resulting vector
--- @return number z The z component of the resulting vector
--- @return number w The w component of the resulting vector
function LibVectorMath.Vector4D.Add(leftX, leftY, leftZ, leftW, rightX, rightY, rightZ, rightW)
    return leftX + rightX, leftY + rightY, leftZ + rightZ, leftW + rightW
end

--- Subtracts the second 4D vector from the first
--- @param leftX number The x component of the first vector
--- @param leftY number The y component of the first vector
--- @param leftZ number The z component of the first vector
--- @param leftW number The w component of the first vector
--- @param rightX number The x component of the second vector
--- @param rightY number The y component of the second vector
--- @param rightZ number The z component of the second vector
--- @param rightW number The w component of the second vector
--- @return number x The x component of the resulting vector
--- @return number y The y component of the resulting vector
--- @return number z The z component of the resulting vector
--- @return number w The w component of the resulting vector
function LibVectorMath.Vector4D.Subtract(leftX, leftY, leftZ, leftW, rightX, rightY, rightZ, rightW)
    return leftX - rightX, leftY - rightY, leftZ - rightZ, leftW - rightW
end

--- Calculates the dot product of two 4D vectors
--- @param leftX number The x component of the first vector
--- @param leftY number The y component of the first vector
--- @param leftZ number The z component of the first vector
--- @param leftW number The w component of the first vector
--- @param rightX number The x component of the second vector
--- @param rightY number The y component of the second vector
--- @param rightZ number The z component of the second vector
--- @param rightW number The w component of the second vector
--- @return number dot The dot product
function LibVectorMath.Vector4D.Dot(leftX, leftY, leftZ, leftW, rightX, rightY, rightZ, rightW)
    return leftX * rightX + leftY * rightY + leftZ * rightZ + leftW * rightW
end

--- Calculates the squared length (magnitude) of a 4D vector
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @param z number The z component of the vector
--- @param w number The w component of the vector
--- @return number lengthSquared The squared length of the vector
function LibVectorMath.Vector4D.GetLengthSquared(x, y, z, w)
    return LibVectorMath.Vector4D.Dot(x, y, z, w, x, y, z, w)
end

--- Calculates the length (magnitude) of a 4D vector
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @param z number The z component of the vector
--- @param w number The w component of the vector
--- @return number length The length of the vector
function LibVectorMath.Vector4D.GetLength(x, y, z, w)
    return sqrt(LibVectorMath.Vector4D.GetLengthSquared(x, y, z, w))
end

--- Normalizes a 4D vector (makes it unit length)
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @param z number The z component of the vector
--- @param w number The w component of the vector
--- @return number x The x component of the normalized vector
--- @return number y The y component of the normalized vector
--- @return number z The z component of the normalized vector
--- @return number w The w component of the normalized vector
function LibVectorMath.Vector4D.Normalize(x, y, z, w)
    return LibVectorMath.Vector4D.DivideBy(LibVectorMath.Vector4D.GetLength(x, y, z, w), x, y, z, w)
end

--- Adds two 4D vector objects and returns a new vector
--- @param left Vector4DMixin The first vector
--- @param right Vector4DMixin The second vector
--- @return Vector4DMixin result A new vector containing the sum
function LibVectorMath.Vector4D.AddVector(left, right)
    local clone = left:Clone()
    clone:Add(right)
    return clone
end

--- Subtracts the second 4D vector object from the first and returns a new vector
--- @param left Vector4DMixin The first vector
--- @param right Vector4DMixin The second vector
--- @return Vector4DMixin result A new vector containing the difference
function LibVectorMath.Vector4D.SubtractVector(left, right)
    local clone = left:Clone()
    clone:Subtract(right)
    return clone
end

--- Normalizes a 4D vector object and returns a new vector
--- @param vector Vector4DMixin The vector to normalize
--- @return Vector4DMixin result A new normalized vector
function LibVectorMath.Vector4D.NormalizeVector(vector)
    local clone = vector:Clone()
    clone:Normalize()
    return clone
end

--- Scales a 4D vector object by a scalar and returns a new vector
--- @param scalar number The scaling factor
--- @param vector Vector4DMixin The vector to scale
--- @return Vector4DMixin result A new scaled vector
function LibVectorMath.Vector4D.ScaleVector(scalar, vector)
    local clone = vector:Clone()
    clone:ScaleBy(scalar)
    return clone
end

-- Create the mixin
LibVectorMath.Vector4DMixin = ZO_InitializingObject:Subclass()

--- Creates a new 4D vector
--- @param x number The x component
--- @param y number The y component
--- @param z number The z component
--- @param w number The w component
--- @return Vector4DMixin vector The created 4D vector object
function LibVectorMath.Vector4D.Create(x, y, z, w)
    local vector = setmetatable({}, LibVectorMath.Vector4DMixin)
    vector:Initialize(x, y, z, w)
    return vector
end

--- Checks if two 4D vectors are equal
--- @param left Vector4DMixin|nil The first vector
--- @param right Vector4DMixin|nil The second vector
--- @return boolean equal True if the vectors are equal
function LibVectorMath.Vector4D.AreEqual(left, right)
    if left and right then
        return left:IsEqualTo(right)
    end
    return left == right
end

--- Initializes a 4D vector with x, y, z, and w components
--- @param x number The x component
--- @param y number The y component
--- @param z number The z component
--- @param w number The w component
function LibVectorMath.Vector4DMixin:Initialize(x, y, z, w)
    self:SetXYZW(x, y, z, w)
end

--- Checks if this vector is equal to another vector
--- @param otherVector Vector4DMixin The vector to compare with
--- @return boolean equal True if the vectors are equal
function LibVectorMath.Vector4DMixin:IsEqualTo(otherVector)
    return self.x == otherVector.x
        and self.y == otherVector.y
        and self.z == otherVector.z
        and self.w == otherVector.w
end

--- Gets the x, y, z, and w components of the vector
--- @return number x The x component
--- @return number y The y component
--- @return number z The z component
--- @return number w The w component
function LibVectorMath.Vector4DMixin:GetXYZW()
    return self.x, self.y, self.z, self.w
end

--- Sets the x, y, z, and w components of the vector
--- @param x number The x component
--- @param y number The y component
--- @param z number The z component
--- @param w number The w component
function LibVectorMath.Vector4DMixin:SetXYZW(x, y, z, w)
    self.x = x
    self.y = y
    self.z = z
    self.w = w
end

--- Scales the vector by a scalar value
--- @param scalar number The scaling factor
--- @return Vector4DMixin self The scaled vector (self)
function LibVectorMath.Vector4DMixin:ScaleBy(scalar)
    self:SetXYZW(LibVectorMath.Vector4D.ScaleBy(scalar, self:GetXYZW()))
    return self
end

--- Divides the vector by a scalar value
--- @param scalar number The divisor
--- @return Vector4DMixin self The divided vector (self)
function LibVectorMath.Vector4DMixin:DivideBy(scalar)
    self:SetXYZW(LibVectorMath.Vector4D.DivideBy(scalar, self:GetXYZW()))
    return self
end

--- Adds another vector to this vector
--- @param other Vector4DMixin The vector to add
--- @return Vector4DMixin self The resulting vector (self)
function LibVectorMath.Vector4DMixin:Add(other)
    self:SetXYZW(LibVectorMath.Vector4D.Add(self.x, self.y, self.z, self.w, other:GetXYZW()))
    return self
end

--- Subtracts another vector from this vector
--- @param other Vector4DMixin The vector to subtract
--- @return Vector4DMixin self The resulting vector (self)
function LibVectorMath.Vector4DMixin:Subtract(other)
    self:SetXYZW(LibVectorMath.Vector4D.Subtract(self.x, self.y, self.z, self.w, other:GetXYZW()))
    return self
end

--- Calculates the dot product with another vector
--- @param other Vector4DMixin The vector to dot with
--- @return number dot The dot product
function LibVectorMath.Vector4DMixin:Dot(other)
    return LibVectorMath.Vector4D.Dot(self.x, self.y, self.z, self.w, other:GetXYZW())
end

--- Gets the squared length (magnitude) of the vector
--- @return number lengthSquared The squared length of the vector
function LibVectorMath.Vector4DMixin:GetLengthSquared()
    return LibVectorMath.Vector4D.GetLengthSquared(self:GetXYZW())
end

--- Gets the length (magnitude) of the vector
--- @return number length The length of the vector
function LibVectorMath.Vector4DMixin:GetLength()
    return LibVectorMath.Vector4D.GetLength(self:GetXYZW())
end

--- Normalizes the vector (makes it unit length)
--- @return Vector4DMixin self The normalized vector (self)
function LibVectorMath.Vector4DMixin:Normalize()
    self:SetXYZW(LibVectorMath.Vector4D.Normalize(self:GetXYZW()))
    return self
end

--- Creates a copy of this vector
--- @return Vector4DMixin clone The cloned vector
function LibVectorMath.Vector4DMixin:Clone()
    return LibVectorMath.Vector4D.Create(self:GetXYZW())
end

return LibVectorMath
