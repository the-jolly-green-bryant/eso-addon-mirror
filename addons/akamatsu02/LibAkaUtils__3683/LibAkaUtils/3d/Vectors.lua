Vector = Vector or {}

function Vector.new(self, x, y, z)
	local vector = {
		x = x,
		y = y,
		z = z
	}
    setmetatable(vector, self)
    self.__index = self
    return vector
end

function Vector.normalize(self)
	local length = self:length()
	self.x = self.x / length
	self.y = self.y / length
	self.z = self.z / length
	return self
end

function Vector.isEqual(self, vector)
	return self.x == vector.x and self.y == vector.y and self.z == vector.z
end

function Vector.tostring(self)
	return "(" .. self.x .. ", " .. self.y .. ", " .. self.z .. ")"
end

function Vector.length(self)
	return math.sqrt(self:lengthSquared())
end

function Vector.lengthSquared(self)
	return self.x * self.x + self.y * self.y + self.z * self.z
end

function Vector.mul(self, value)
	if type(value) ~= "number" then return self end
	self.x = self.x * value
	self.y = self.y * value
	self.z = self.z * value
	return self
end

function Vector.div(self, value)
	if type(value) ~= "number" then return self end
	self.x = self.x / value
	self.y = self.y / value
	self.z = self.z / value
	return self
end

function Vector.add(self, value)
	if type(value) ~= "number" then return self end
	self.x = self.x + value
	self.y = self.y + value
	self.z = self.z + value
	return self
end

function Vector.sub(self, value)
	if type(value) ~= "number" then return self end
	self.x = self.x - value
	self.y = self.y - value
	self.z = self.z - value
	return self
end

function Vector.addVector(self, value)
	self.x = self.x + value.x
	self.y = self.y + value.y
	self.z = self.z + value.z
	return self
end

function Vector.subVector(self, value)
	self.x = self.x - value.x
	self.y = self.y - value.y
	self.z = self.z - value.z
	return self
end