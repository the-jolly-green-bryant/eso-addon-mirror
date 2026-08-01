-- SPDX-FileCopyrightText: 2023 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

local static = {}
local meta = {}
local cache = {}

setmetatable(cache, {
    __mode = "v" -- make cached values weak references so they get collected
})

-- see https://en.wikipedia.org/wiki/Double-precision_floating-point_format#Precision_limitations_on_integer_values
local MIN_SAFE_INT = -9007199254740991  -- = -2^53 + 1
local MAX_SAFE_INT =  9007199254740991  -- =  2^53 - 1
local MAX_SAFE_INT_ID64 = StringToId64("9007199254740991")
local function isSafeNumber(value)
    return not (value < MIN_SAFE_INT or value > MAX_SAFE_INT)
end
static.isSafeNumber = isSafeNumber

local function safeIntegerToString(value)
    assert(isSafeNumber(value), "Insufficient precision for conversion")
    local result = string.format("%.f", value)
    assert(value == tonumber(result), "Not an integer value")
    return result
end

local function fromLuaNumber(value)
    if cache[value] ~= nil then
        return cache[value], true
    end
    local obj = {}
    obj.id64 = StringToId64(safeIntegerToString(value))
    obj.string = Id64ToString(obj.id64)
    if value >= 0 then
        obj.number = tonumber(obj.string)
    end
    return obj, false
end

local function fromId64(value)
    -- a considerable amount of id64s are not valid numbers, so we can't use them as a key
    local str = Id64ToString(value)
    if cache[str] ~= nil then
        return cache[str], true
    end
    local obj = {}
    obj.string = str
    obj.id64 = value
    if CompareId64s(value, MAX_SAFE_INT_ID64) <= 0 then
        obj.number = tonumber(obj.string)
    end
    return obj, false
end

local function fromString(value)
    if cache[value] ~= nil then
        return cache[value], true
    end
    local obj = {}
    obj.id64 = StringToId64(value)
    obj.string = Id64ToString(obj.id64)
    if CompareId64s(obj.id64, MAX_SAFE_INT_ID64) <= 0 then
        obj.number = tonumber(obj.string)
    end
    return obj, false
end

local function throwProtectionError()
    error("id64 must not be modified")
end

local dummyMetaTable = {}

local function makeImmutable(tbl, metaTemplate)
    local obj = newproxy(true)
    tbl.__address = tostring(obj)

    local meta = getmetatable(obj)
    meta.__index = tbl
    meta.__newindex = throwProtectionError
    meta.__metatable = dummyMetaTable
    for k, v in pairs(metaTemplate) do
        meta[k] = v
    end
    return obj
end

local function isInstance(value)
    return not (
        type(value) ~= "userdata"
        or getmetatable(value) ~= dummyMetaTable
        or not cache[value.string]
        or cache[value.string].__address ~= value.__address
    )
end
static.isInstance = isInstance

local function createId64(value, isLuaNumber)
    local obj, isCached
    local valueType = type(value)
    if valueType == "nil" then
        return nil
    elseif valueType == "number" then
        if isLuaNumber then
            obj, isCached = fromLuaNumber(value)
        else
            obj, isCached = fromId64(value)
        end
    elseif valueType == "string" and not isLuaNumber then
        obj, isCached = fromString(value)
    elseif isInstance(value) then
        return cache[value.string]
    end

    assert(obj ~= nil, "Unsupported value type " .. valueType)

    if not isCached then
        obj = makeImmutable(obj, meta)
        cache[obj.string] = obj
        if obj.number then
            cache[obj.number] = obj
        end
    end
    return obj
end

local function fromNumber(value)
    return createId64(value, true)
end
static.fromNumber = fromNumber

id64 = makeImmutable(static, {
    __call = function(self, value) return createId64(value, false) end,
})

local NUMBERS_BYTE_OFFSET = string.byte("0", 1, 1)
local function stringDivideByTwo(value)
    local add = 0
    local newValue = ""
    for i = 1, #value do
        local digit = value:byte(i, i) - NUMBERS_BYTE_OFFSET
        local result = math.floor(digit / 2) + add
        if #newValue > 0 or result > 0 then
            newValue = newValue .. result
        end
        add = (digit % 2) * 5
    end
    if newValue == "" then return "0" end
    return newValue
end

local function stringEndsOdd(value)
    local last = #value
    return value:byte(last, last) % 2
end

-- from https://stackoverflow.com/questions/11006844/convert-a-very-large-number-from-decimal-string-to-binary-representation
local function stringToBinary(value)
    if value == "0" then return "0" end
    local binary = ""
    while value ~= "0" do
        binary = stringEndsOdd(value) .. binary
        value = stringDivideByTwo(value)
    end
    return binary
end

-- from https://stackoverflow.com/a/5249750
local function stringAddition(valueA, valueB)
    local result = ""
    local valueARev = valueA:reverse()
    local valueBRev = valueB:reverse()
    local lengthA = #valueA
    local lengthB = #valueB
    if lengthA > lengthB then
        valueBRev = valueBRev .. string.rep("0", lengthA - lengthB)
        lengthB = lengthA
        elseif lengthB > lengthA then
        valueARev = valueARev .. string.rep("0", lengthB - lengthA)
        lengthA = lengthB
    end

    local carry = 0
    for i = 1, lengthA do
        local digitA = valueARev:byte(i, i) - NUMBERS_BYTE_OFFSET
        local digitB = valueBRev:byte(i, i) - NUMBERS_BYTE_OFFSET
        local digitSum = digitA + digitB + carry
        if digitSum > 9 then
            digitSum = digitSum - 10
            carry = 1
        else
            carry = 0
        end
        result = digitSum .. result
    end

    if carry > 0 then
        result = carry .. result
    end

    return result
end

-- from https://www.geeksforgeeks.org/difference-of-two-large-numbers/
local function stringSubtraction(valueA, valueB)
    local result = ""
    local valueARev = valueA:reverse()
    local valueBRev = valueB:reverse()
    local lengthA = #valueA
    local lengthB = #valueB
    if lengthA > lengthB then
        valueBRev = valueBRev .. string.rep("0", lengthA - lengthB)
        lengthB = lengthA
    elseif lengthB > lengthA then
        valueARev = valueARev .. string.rep("0", lengthB - lengthA)
        lengthA = lengthB
    end

    local carry = 0
    for i = 1, lengthA do
        local digitA = valueARev:byte(i, i) - NUMBERS_BYTE_OFFSET
        local digitB = valueBRev:byte(i, i) - NUMBERS_BYTE_OFFSET
        local subtracted = digitA - digitB - carry
        if subtracted < 0 then
            subtracted = subtracted + 10
            carry = 1
        else
            carry = 0
        end

        result = subtracted .. result
    end
    result = result:gsub("^0*", "")
    if result == "" then
        return "0"
    end
    return result
end

local function addId64WithNumber(a, b)
    assert(b > 0, "Adding a negative number to id64 is not supported")
    local result = (a.number or 0) + b
    local numeric = true
    if not a.number or result > MAX_SAFE_INT then
        result = stringAddition(a.string, safeIntegerToString(b))
        numeric = false
    end
    return createId64(result, numeric)
end

local function addId64WithId64(a, b)
    local result = (a.number or 0) + (b.number or 0)
    local numeric = true
    if not a.number or not b.number or result > MAX_SAFE_INT then
        result = stringAddition(a.string, b.string)
        numeric = false
    end
    return createId64(result, numeric)
end

meta.__add = function(a, b)
    if type(a) == "number" then
        return addId64WithNumber(b, a)
    elseif type(b) == "number" then
        return addId64WithNumber(a, b)
    end
    return addId64WithId64(a, b)
end

local function subtractNumberFromId64(a, b)
    if b < 0 then
        return addId64WithNumber(a, -b)
    end

    local result = (a.number or 0) - b
    local numeric = true
    if not a.number or result > MAX_SAFE_INT then
        result = stringSubtraction(a.string, safeIntegerToString(b))
        numeric = false
    end
    return createId64(result, numeric)
end

local function subtractId64FromNumber(a, b)
    if a < 0 then
        return addId64WithNumber(b, -a)
    end

    local result = a - (b.number or 0)
    local numeric = true
    if not a.number or result > MAX_SAFE_INT then
        result = stringSubtraction(safeIntegerToString(a), b.string)
        numeric = false
    end
    return createId64(result, numeric)
end

local function subtractId64FromId64(a, b)
    local result = (a.number or 0) - (b.number or 0)
    local numeric = true
    if not a.number or not b.number or result > MAX_SAFE_INT then
        result = stringSubtraction(a.string, b.string)
        numeric = false
    end
    return createId64(result, numeric)
end

meta.__sub = function(a, b)
    if type(a) == "number" then
        return subtractId64FromNumber(a, b)
    elseif type(b) == "number" then
        return subtractNumberFromId64(a, b)
    end
    return subtractId64FromId64(a, b)
end

-- https://www.tutorialspoint.com/program-to-multiply-two-strings-and-return-result-as-string-in-cplusplus
meta.__mul = function(a, b)
    error("The multiplication operator is not supported by id64")
end

-- https://www.geeksforgeeks.org/divide-large-number-represented-string/
meta.__div = function(a, b)
    error("The division operator is not supported by id64")
end

meta.__mod = function(a, b)
    error("The modulo operator is not supported by id64")
end

meta.__pow = function(a, b)
    error("The power operator is not supported by id64")
end

meta.__unm = function(self)
    return createId64(0, true) - self
end

meta.__le = function(a, b)
    return a.string == b.string or CompareId64s(a.id64, b.id64) == -1
end

meta.__lt = function(a, b)
    return CompareId64s(a.id64, b.id64) == -1
end

meta.__eq = function(a, b)
    return a.string == b.string
end

meta.__concat = function(a, b)
    return tostring(a) .. tostring(b)
end

meta.__tostring = function(self)
    return self.string
end
