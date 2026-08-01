-- -----------------------------------------------------------------------------
-- Vector2D - 2D vector math library
-- -----------------------------------------------------------------------------

-- Create a local table for our library
--- @class LibVectorMath
local LibVectorMath = _G.LibVectorMath
LibVectorMath.Vector2D = LibVectorMath.Vector2D

--- @class Vector2DMixin : ZO_InitializingObject
--- @field x number X component of the 2D vector
--- @field y number Y component of the 2D vector

-- -----------------------------------------------------------------------------
-- Lua Locals.
-- -----------------------------------------------------------------------------

local cos =zo_cos
local sin = zo_sin
local atan2 = zo_atan2
local sqrt = zo_sqrt

-- -----------------------------------------------------------------------------

--- Scales a 2D vector by a scalar value
--- @param scalar number The scaling factor
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @return number x The scaled x component
--- @return number y The scaled y component
function LibVectorMath.Vector2D.ScaleBy(scalar, x, y)
    return x * scalar, y * scalar
end

--- Divides a 2D vector by a scalar value
--- @param divisor number The divisor
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @return number x The divided x component
--- @return number y The divided y component
function LibVectorMath.Vector2D.DivideBy(divisor, x, y)
    return x / divisor, y / divisor
end

--- Adds two 2D vectors
--- @param leftX number The x component of the first vector
--- @param leftY number The y component of the first vector
--- @param rightX number The x component of the second vector
--- @param rightY number The y component of the second vector
--- @return number x The x component of the resulting vector
--- @return number y The y component of the resulting vector
function LibVectorMath.Vector2D.Add(leftX, leftY, rightX, rightY)
    return leftX + rightX, leftY + rightY
end

--- Subtracts the second 2D vector from the first
--- @param leftX number The x component of the first vector
--- @param leftY number The y component of the first vector
--- @param rightX number The x component of the second vector
--- @param rightY number The y component of the second vector
--- @return number x The x component of the resulting vector
--- @return number y The y component of the resulting vector
function LibVectorMath.Vector2D.Subtract(leftX, leftY, rightX, rightY)
    return leftX - rightX, leftY - rightY
end

--- Calculates the cross product of two 2D vectors
--- @param leftX number The x component of the first vector
--- @param leftY number The y component of the first vector
--- @param rightX number The x component of the second vector
--- @param rightY number The y component of the second vector
--- @return number cross The cross product (scalar in 2D)
function LibVectorMath.Vector2D.Cross(leftX, leftY, rightX, rightY)
    return leftX * rightY - leftY * rightX
end

--- Calculates the dot product of two 2D vectors
--- @param leftX number The x component of the first vector
--- @param leftY number The y component of the first vector
--- @param rightX number The x component of the second vector
--- @param rightY number The y component of the second vector
--- @return number dot The dot product
function LibVectorMath.Vector2D.Dot(leftX, leftY, rightX, rightY)
    return leftX * rightX + leftY * rightY
end

--- Calculates the squared length (magnitude) of a 2D vector
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @return number lengthSquared The squared length of the vector
function LibVectorMath.Vector2D.GetLengthSquared(x, y)
    return LibVectorMath.Vector2D.Dot(x, y, x, y)
end

--- Calculates the length (magnitude) of a 2D vector
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @return number length The length of the vector
function LibVectorMath.Vector2D.GetLength(x, y)
    return sqrt(LibVectorMath.Vector2D.GetLengthSquared(x, y))
end

--- Normalizes a 2D vector (makes it unit length)
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @return number x The x component of the normalized vector
--- @return number y The y component of the normalized vector
function LibVectorMath.Vector2D.Normalize(x, y)
    return LibVectorMath.Vector2D.DivideBy(LibVectorMath.Vector2D.GetLength(x, y), x, y)
end

--- Calculates the angle between two 2D vectors in radians
--- @param leftX number The x component of the first vector
--- @param leftY number The y component of the first vector
--- @param rightX number The x component of the second vector
--- @param rightY number The y component of the second vector
--- @return number angle The angle between the vectors in radians
function LibVectorMath.Vector2D.CalculateAngleBetween(leftX, leftY, rightX, rightY)
    return atan2(LibVectorMath.Vector2D.Cross(leftX, leftY, rightX, rightY), LibVectorMath.Vector2D.Dot(leftX, leftY, rightX, rightY))
end

--- Rotates a 2D vector by the given angle in radians
--- @param rotationRadians number The rotation angle in radians
--- @param x number The x component of the vector
--- @param y number The y component of the vector
--- @return number x The x component of the rotated vector
--- @return number y The y component of the rotated vector
function LibVectorMath.Vector2D.RotateDirection(rotationRadians, x, y)
    local cosValue = cos(rotationRadians)
    local sinValue = sin(rotationRadians)
    return x * cosValue - y * sinValue, x * sinValue + y * cosValue
end

-- Create the mixin
LibVectorMath.Vector2DMixin = ZO_InitializingObject:Subclass()

--- Creates a new 2D vector
--- @param x number The x component
--- @param y number The y component
--- @return Vector2DMixin vector The created 2D vector object
function LibVectorMath.Vector2D.Create(x, y)
    local vector = setmetatable({}, LibVectorMath.Vector2DMixin)
    vector:Initialize(x, y)
    return vector
end

--- Checks if two 2D vectors are equal
--- @param left Vector2DMixin|nil The first vector
--- @param right Vector2DMixin|nil The second vector
--- @return boolean equal True if the vectors are equal
function LibVectorMath.Vector2D.AreEqual(left, right)
    if left and right then
        return left:IsEqualTo(right)
    end
    return left == right
end

--- Initializes a 2D vector with x and y components
--- @param x number The x component
--- @param y number The y component
function LibVectorMath.Vector2DMixin:Initialize(x, y)
    self:SetXY(x, y)
end

--- Checks if this vector is equal to another vector
--- @param otherVector Vector2DMixin The vector to compare with
--- @return boolean equal True if the vectors are equal
function LibVectorMath.Vector2DMixin:IsEqualTo(otherVector)
    return self.x == otherVector.x
        and self.y == otherVector.y
end

--- Gets the x and y components of the vector
--- @return number x The x component
--- @return number y The y component
function LibVectorMath.Vector2DMixin:GetXY()
    return self.x, self.y
end

--- Sets the x and y components of the vector
--- @param x number The x component
--- @param y number The y component
function LibVectorMath.Vector2DMixin:SetXY(x, y)
    self.x = x
    self.y = y
end

--- Scales the vector by a scalar value
--- @param scalar number The scaling factor
--- @return Vector2DMixin self The scaled vector (self)
function LibVectorMath.Vector2DMixin:ScaleBy(scalar)
    self:SetXY(LibVectorMath.Vector2D.ScaleBy(scalar, self:GetXY()))
    return self
end

--- Divides the vector by a scalar value
--- @param scalar number The divisor
--- @return Vector2DMixin self The divided vector (self)
function LibVectorMath.Vector2DMixin:DivideBy(scalar)
    self:SetXY(LibVectorMath.Vector2D.DivideBy(scalar, self:GetXY()))
    return self
end

--- Adds another vector to this vector
--- @param other Vector2DMixin The vector to add
--- @return Vector2DMixin self The resulting vector (self)
function LibVectorMath.Vector2DMixin:Add(other)
    self:SetXY(LibVectorMath.Vector2D.Add(self.x, self.y, other:GetXY()))
    return self
end

--- Subtracts another vector from this vector
--- @param other Vector2DMixin The vector to subtract
--- @return Vector2DMixin self The resulting vector (self)
function LibVectorMath.Vector2DMixin:Subtract(other)
    self:SetXY(LibVectorMath.Vector2D.Subtract(self.x, self.y, other:GetXY()))
    return self
end

--- Calculates the cross product with another vector
--- @param other Vector2DMixin The vector to cross with
--- @return Vector2DMixin self The resulting vector (self)
function LibVectorMath.Vector2DMixin:Cross(other)
    self:SetXY(LibVectorMath.Vector2D.Cross(self.x, self.y, other:GetXY()))
    return self
end

--- Calculates the dot product with another vector
--- @param other Vector2DMixin The vector to dot with
--- @return number dot The dot product
function LibVectorMath.Vector2DMixin:Dot(other)
    return LibVectorMath.Vector2D.Dot(self.x, self.y, other:GetXY())
end

--- Checks if the vector is zero (both components are 0)
--- @return boolean isZero True if the vector is zero
function LibVectorMath.Vector2DMixin:IsZero()
    return self.x == 0 and self.y == 0
end

--- Gets the squared length (magnitude) of the vector
--- @return number lengthSquared The squared length of the vector
function LibVectorMath.Vector2DMixin:GetLengthSquared()
    return LibVectorMath.Vector2D.GetLengthSquared(self:GetXY())
end

--- Gets the length (magnitude) of the vector
--- @return number length The length of the vector
function LibVectorMath.Vector2DMixin:GetLength()
    return LibVectorMath.Vector2D.GetLength(self:GetXY())
end

--- Normalizes the vector (makes it unit length)
--- @return Vector2DMixin self The normalized vector (self)
function LibVectorMath.Vector2DMixin:Normalize()
    self:SetXY(LibVectorMath.Vector2D.Normalize(self:GetXY()))
    return self
end

--- Rotates the vector by the given angle in radians
--- @param rotationRadians number The rotation angle in radians
--- @return Vector2DMixin self The rotated vector (self)
function LibVectorMath.Vector2DMixin:RotateDirection(rotationRadians)
    self:SetXY(LibVectorMath.Vector2D.RotateDirection(rotationRadians, self:GetXY()))
    return self
end

--- Creates a copy of this vector
--- @return Vector2DMixin clone The cloned vector
function LibVectorMath.Vector2DMixin:Clone()
    return LibVectorMath.Vector2D.Create(self:GetXY())
end

return LibVectorMath
