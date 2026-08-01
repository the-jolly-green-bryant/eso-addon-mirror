Int = Int or {}

local function copyTable(t, withoutMeta)
    local t2 = {}
    for k,v in pairs(t) do
        if type(v) == "table" then
            t2[k] = copyTable(v)
        else
            t2[k] = v
        end
    end
    if withoutMeta ~= true then
        setmetatable(t2, getmetatable(t))
    end
    return t2
end

local function getIndexOfHighestPowerOf2(value)
    for i = 1, value.bits, 1 do
        if value.bitArray[i] == 1 then
            return i
        end
    end
    return nil
end

function Int.new(self, bits, isSigned, value)
    if bits == nil then bits = 32 end
    if isSigned == nil then isSigned = true end
    local new = {
		bits = bits,
		isSigned = isSigned,
		bitArray = {}
	}
    for i = 1,bits,1 do 
        new.bitArray[i] = 0
    end
    setmetatable(new, self)
    self.__index = self
    if value ~= nil then
        new:parse(value)
    end
    return new
end

function Int.fromArray(self, value, isSigned)
    if type(value) ~= "table" then
        error("Value is not a Table.")
    end
    local bits = #value
    if isSigned == nil then isSigned = true end
    local new = {
		bits = bits,
		isSigned = isSigned,
		bitArray = copyTable(value, true)
	}
    setmetatable(new, self)
    self.__index = self
    return new
end

function Int.checkBoundsForValue(self, value)
    local min = 0
    local max = 0
    if self.isSigned == true then
        min = -math.pow(2, self.bits-1)
        max = math.pow(2, self.bits-1) - 1
    else
        min = 0
        max = math.pow(2, self.bits) - 1
    end
    if value < min or value > max then
        error("Int value is out of bounds.")
    end
end

function Int.parse(self, value)
    if value == nil then 
        error("Int.parse failed, input is nil.")
    end
    if type(value) == "string" then
        value = tonumber(value)
        if value == nil then 
            error("Int.parse failed, input is not a number or hex value.")
        end
    else 
        if type(value) ~= "number" then
            error("Int.parse failed, input is not a valid format.")
        end
    end
    local cutOff = value % 1
    if cutOff ~= 0 then
        value = value - cutOff
    end
    self:checkBoundsForValue(value)
    if self.isSigned == false then
        local index = self.bits
        while (value ~= 0) do
            local rest = value % 2;
            value = (value - rest) / 2;
            self.bitArray[index] = rest;
            index = index - 1;
        end
    else
        if value < 0 then
            self.bitArray[1] = 1
            value = math.pow(2, self.bits - 1) + value
        else
            self.bitArray[1] = 0
        end
        local index = self.bits - 1
        while (value ~= 0) do
            local rest = value % 2;
            value = (value - rest) / 2;
            self.bitArray[index + 1] = rest;
            index = index - 1;
        end
    end
end

function Int.IsNull(self)
    for i = 1,self.bits,1 do 
        if self.bitArray[i] == 1 then
            return false
        end
    end
    return true
end

function Int.IsSignedNegative(self)
    if self.isSigned == false then
        return false
    end
    return self.bitArray[1] == 1
end

function Int.GetValue(self)
    local output = 0
    if self.isSigned == false then
        for i = 1,self.bits,1 do 
            output = output + self.bitArray[i] * math.pow(2, self.bits - i)
        end
    else
        local isNegative = self:IsSignedNegative()
        local temp = 0
        for i = 2,self.bits,1 do 
            temp = temp + self.bitArray[i] * math.pow(2, self.bits - i)
        end
        if isNegative == true then
            output = temp - math.pow(2, self.bits - 1)
        else
            output = temp
        end
    end
    return output
end

function Int.checkType(self, value2)
    if value2.bits ~= self.bits or value2.isSigned ~= self.isSigned then 
        error("Cannot perform calculations on different integer types!") 
    end
end

function Int.ToSigned(self)
    if self.isSigned == true then 
        return self
    end
    self.bitArray[1] = 0
    self.isSigned = true 
    return self
end

function Int.ToUnsigned(self)
    if self.isSigned == false then 
        return self
    end
    self = self:Abs()
    self.isSigned = false 
    return self
end

function Int.Abs(self)
    if self.isSigned == false then 
        return self
    end
    if self:IsSignedNegative() == true then
        self = self:Neg()
    end
    return self
end

function Int.Neg(self)
    if self.isSigned == false then 
        return self
    end
    self:Not()
    self = self:Increase()
    return self
end

function Int.Increase(self)
    self = self:Add(self:CopyType(1))
    return self
end

function Int.Decrease(self)
    self = self:Sub(self:CopyType(1))
    return self
end

function Int.Copy(self)
    return copyTable(self)
end

function Int.CopyType(self, value)
    return Int:new(self.bits, true, value)
end

function Int.IsEqualTo(self, value2)
    self:checkType(value2)
    for i = 1, self.bits, 1 do
        if self.bitArray[i] ~= value2.bitArray[i] then
            return false
        end
    end
    return true
end

function Int.IsSmallerThan(self, value2)
    self:checkType(value2)
    if self:IsSignedNegative() == true and value2:IsSignedNegative() == false then
        return true
    elseif self:IsSignedNegative() == false and value2:IsSignedNegative() == true then
        return false
    end
    self = self:Abs()
    value2 = value2:Abs()
    for i = 1, self.bits, 1 do
        if self.bitArray[i] ~= value2.bitArray[i] then
            if self.bitArray[i] == 1 then
                return true
            elseif value2.bitArray[i] == 1 then
                return false
            end
        end
    end
    return false
end

function Int.IsGreaterThan(self, value2)
    self:checkType(value2)
    if self:IsSignedNegative() == true and value2:IsSignedNegative() == false then
        return false
    elseif self:IsSignedNegative() == false and value2:IsSignedNegative() == true then
        return true
    end
    self = self:Abs()
    value2 = value2:Abs()
    for i = 1, self.bits, 1 do
        if self.bitArray[i] ~= value2.bitArray[i] then
            if self.bitArray[i] == 1 then
                return false
            elseif value2.bitArray[i] == 1 then
                return true
            end
        end
    end
    return false
end

function Int.ToMaxValue(self)
    if self.isSigned == false then 
        for i = 1, self.bits, 1 do
            self.bitArray[i] = 1
        end
    else
        self.bitArray[1] = 0
        for i = 2, self.bits, 1 do
            self.bitArray[i] = 1
        end
    end
    return self
end

function Int.ToMinValue(self)
    if self.isSigned == false then 
        for i = 1, self.bits, 1 do
            self.bitArray[i] = 0
        end
    else
        self.bitArray[1] = 1
        for i = 2, self.bits, 1 do
            self.bitArray[i] = 0
        end
    end
    return self
end

function Int.Add(self, value2)
    self:checkType(value2)
    if self:IsNull() == true then 
        self = value2
        return value2
    end
    local selfCopy = self:Copy()
    local value2Copy = value2:Copy()
    while value2Copy:IsNull() == false do
        local carry = selfCopy:Copy():And(value2Copy)
        selfCopy:Xor(value2Copy)
        value2Copy = carry:Lshift(1)
    end
    self.bitArray = selfCopy.bitArray
    return self
end

function Int.Sub(self, value2)
    self = self:Add(value2:Neg())
    return self
end

function Int.Mul(self, value2)
    self:checkType(value2)
    if self:IsNull() == true then
        return self
    end
    if value2:IsNull() == true then
        self = self:CopyType()
        return self
    end

    local makeNegative = self:IsSignedNegative() ~= value2:IsSignedNegative()
    self = self:Abs()
    value2 = value2:Abs()
    
    local calcCopy = self:Copy()
    self = self:CopyType()
    while true do
        local n = getIndexOfHighestPowerOf2(value2)
        local selfCopy = calcCopy:Copy()
        if n == nil then 
            break
        else
            local bitsToShift = selfCopy.bits-n
            if bitsToShift ~= 0 then 
                selfCopy:Lshift(bitsToShift)
            end
            self = self:Add(selfCopy)
            value2.bitArray[n] = 0
            if bitsToShift == 0 then 
                break 
            end
        end
    end

    if makeNegative == true then
        self = self:Neg()
    end
    return self
end

function Int.Div(self, value2)
    self:checkType(value2)
    if self:IsNull() == true then 
        self = self:CopyType()
        return self
    end
    if value2:IsNull() == true then 
        error("Cannot divide by 0!") 
    end
    local value = self:GetValue() / value2:GetValue()
    self:parse(value)
    --[[local makeNegative = self:IsSignedNegative() ~= value2:IsSignedNegative()
    self = self:Abs()
    value2 = value2:Abs()
    local copy = self:CopyType()
    local q = self:CopyType()

    for i = self.bits, 1, -1 do
        copy:Lshift(1)
        copy.bitArray[self.bits] = self.bitArray[i]
        if copy:IsLargerThan(value2) or copy:IsEqualTo(value2) then
            copy = copy:Sub(value2)
            q.bitArray[i] = 1
        end
    end
    self = q]]--
    return self
end

function Int.Rshift(self, shift)
    if self.isSigned == true then
        return self:ArithmeticRshift(shift)
    else
        return self:LogicalRshift(shift)
    end
end

function Int.Lshift(self, shift)
    if self.isSigned == true then
        return self:ArithmeticLshift(shift)
    else
        return self:LogicalLshift(shift)
    end
end

function Int.LogicalRshift(self, shift)
    for n = 1, shift, 1 do
        for i = self.bits, 2, -1 do 
            self.bitArray[i] = tonumber(self.bitArray[i - 1])
        end
        self.bitArray[1] = 0
    end
    return self
end

function Int.LogicalLshift(self, shift)
    return self:ArithmeticLshift(shift)
end

function Int.ArithmeticRshift(self, shift)
    for n = 1, shift, 1 do
        for i = self.bits, 2, -1 do 
            self.bitArray[i] = tonumber(self.bitArray[i - 1])
        end
    end
    return self
end

function Int.ArithmeticLshift(self, shift)
    for n = 1, shift, 1 do
        for i = 1, self.bits -1, 1 do 
            self.bitArray[i] = tonumber(self.bitArray[i + 1])
        end
        self.bitArray[self.bits] = 0
    end
    return self
end

function Int.CircularRshift(self, shift)
    for n = 1, shift, 1 do
        local lsb = tonumber(self.bitArray[self.bits])
        for i = self.bits, 2, -1 do 
            self.bitArray[i] = tonumber(self.bitArray[i - 1])
        end
        self.bitArray[1] = lsb
    end
    return self
end

function Int.CircularLshift(self, shift)
    for n = 1, shift, 1 do
        local msb = tonumber(self.bitArray[1])
        for i = 1, self.bits -1, 1 do 
            self.bitArray[i] = tonumber(self.bitArray[i + 1])
        end
        self.bitArray[self.bits] = msb
    end
    return self
end

function Int.And(self, value2)
    self:checkType(value2)
    for i = 1,self.bits,1 do 
        if self.bitArray[i] ~= value2.bitArray[i] then
            self.bitArray[i] = 0
        end
    end
    return self
end

function Int.Or(self, value2)
    self:checkType(value2)
    for i = 1,self.bits,1 do 
        if self.bitArray[i] ~= value2.bitArray[i] then
            self.bitArray[i] = 1
        end
    end
    return self
end

function Int.Xor(self, value2)
    self:checkType(value2)
    for i = 1,self.bits,1 do 
        if self.bitArray[i] == value2.bitArray[i] then
            self.bitArray[i] = 0
        else
            self.bitArray[i] = 1
        end
    end
    return self
end

function Int.Not(self)
    for i = 1,self.bits,1 do 
        if self.bitArray[i] == 1 then
            self.bitArray[i] = 0
        else
            self.bitArray[i] = 1
        end
    end
    return self
end