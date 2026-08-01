-- local Log = LibDataPacker_Logger()
local BinaryBuffer = LibDataPacker_BinaryBuffer
local floor = math.floor
local ceil = math.ceil
local log = math.log
local char = string.char
local BitAnd = BitAnd
local BitOr = BitOr
local BitLShift = BitLShift
local BitRShift = BitRShift
local ipairs = ipairs

local lib = {}

-- ----------------------------------------------------------------------------

local meters = {}
-- GLOBAL_IMP_LIB_DATA_PACKER_METERS = meters

local function GetMeter(schema)
    local meter = meters[schema]
    if not meter then
        meter = PerformanceMeter.New(5000)
        meters[schema] = meter
    end

    return meter
end

-- ----------------------------------------------------------------------------

local function maxBitLengthFor(number)
    return ceil(log(number + 1) / log(2))
end

local function getMaxValueForBitLength(number)
    return 2^number - 1
end

-- ----------------------------------------------------------------------------

local EMPTY = 0
local NUMERIC = 1
local TABLE = 2
local ARRAY = 3
local BOOLEAN = 4
local STRING = 5
local ENUM = 6
local VARIABLE_LENGTH_ARRAY = 7
local OPTIONAL = 8

-- ----------------------------------------------------------------------------

--- @class Field
--- @field __index Field
--- @field name string|nil The field name
--- @field fieldType integer The field type (EMPTY, NUMERIC, TABLE, ARRAY)
local Field = {}
Field.__index = Field

--- Creates a new Field object
--- @param name string|nil The field name
--- @param fieldType integer The field type
--- @return Field @The new Field object
function Field.New(name, fieldType)
    --- @class (partial) Field
    local o = setmetatable({}, Field)

    o.name = name
    o.fieldType = fieldType

    return o
end

function Field:Serialize(data, buffer)
    assert(false, 'Must be overridden')
end

function Field:Unserialize(buffer)
    assert(false, 'Must be overridden')
end

function Field:GetMaxBitLength()
    assert(false, 'Must be overridden')
end

function Field:Skip(buffer)
    assert(false, 'Must be overridden')
end

-- ----------------------------------------------------------------------------

--- @class Numeric : Field
--- @field __index Numeric
--- @field bitLength integer The bit length for the numeric field
local Numeric = setmetatable({}, { __index = Field })
Numeric.__index = Numeric

--- @class NumericWithPrecision : Field
--- @field __index NumericWithPrecision
--- @field bitLength integer The bit length for the numeric field
--- @field mult number Multiplier
local NumericWithPrecision = setmetatable({}, { __index = Field })
NumericWithPrecision.__index = NumericWithPrecision

--- Creates a new Numeric field
--- @param name string|nil The field name
--- @param bitLength integer The bit length for the numeric field
--- @param precision integer|nil
--- @return Numeric|NumericWithPrecision @The new Numeric field
function Numeric.New(name, bitLength, precision)
    --- @class (partial) Numeric
    local o = Field.New(name, NUMERIC)
    o.bitLength = bitLength

    if precision and type(precision) == 'number' and precision ~= 0 then
        setmetatable(o, NumericWithPrecision)
        o.mult = 10^precision
    else
        setmetatable(o, Numeric)
    end

    return o
end

--- Handles a numeric value
--- @param data number The numeric data to handle
--- @return string|nil The binary string representation, or nil on error
function Numeric:Serialize(data, binaryBuffer)
    if type(data) ~= 'number' then
        error(('Value must be a number, got %s: %s'):format(type(data), tostring(data)))
    end

    binaryBuffer:Write(data, self.bitLength)
end

function Numeric:Unserialize(binaryBuffer)
    -- TODO: length check
    return binaryBuffer:Read(self.bitLength)
end

function Numeric:Skip(binaryBuffer)
    binaryBuffer:Skip(self.bitLength)
end

function Numeric:GetMaxBitLength()
    return self.bitLength
end

local function transformForward(number, mult)
    return floor(number * mult + 0.5)
end

--- Handles a numeric value
--- @param data number The numeric data to handle
--- @return string|nil The binary string representation, or nil on error
function NumericWithPrecision:Serialize(data, binaryBuffer)
    if type(data) ~= 'number' then
        error(('Value must be a number, got %s: %s'):format(type(data), tostring(data)))
    end

    binaryBuffer:Write(transformForward(data, self.mult), self.bitLength)
end

local function transformBackward(number, mult)
    return number / mult
end

function NumericWithPrecision:Unserialize(binaryBuffer)
    -- TODO: length check
    return transformBackward(binaryBuffer:Read(self.bitLength), self.mult)
end

-- TODO: inherit from Numeric then?
NumericWithPrecision.GetMaxBitLength = Numeric.GetMaxBitLength
NumericWithPrecision.Skip = Numeric.Skip

-- ----------------------------------------------------------------------------

--- @class Array : Field
--- @field __index Array
--- @field length integer The array length
--- @field subType Field The field type for array elements
local Array = setmetatable({}, { __index = Field })
Array.__index = Array

--- Creates a new Array field
--- @param name string|nil The field name
--- @param length integer The array length
--- @param subtype Field The field type for array elements
--- @return Array The new Array field
function Array.New(name, length, subtype)
    --- @class (partial) Array
    local o = setmetatable(Field.New(name, ARRAY), Array)

    o.length = length
    o.subType = subtype

    return o
end

--- Handles an array of values
--- @param data table The array data to handle
--- @return string|nil The binary string representation, or nil on error
function Array:Serialize(data, binaryBuffer)
    if type(data) ~= 'table' then error('Value must be a table') end

    for _, datum in ipairs(data) do
        self.subType:Serialize(datum, binaryBuffer)
    end
end

function Array:Unserialize(dataBuffer)
    local result = {}

    -- TODO: length check

    for i = 1, self.length do
        result[i] = self.subType:Unserialize(dataBuffer)
    end

    return result
end

function Array:Skip(binaryBuffer)
    for _ = 1, self.length do
        self.subType:Skip(binaryBuffer)
    end
end

function Array:GetMaxBitLength()
    return self.length * self.subType:GetMaxBitLength()
end

-- ----------------------------------------------------------------------------

--- @class VLArray : Field
--- @field __index VLArray
--- @field length Numeric The array max length
--- @field subType Field The field type for array elements
local VLArray = setmetatable({}, { __index = Field })
VLArray.__index = VLArray

--- Creates a new VLArray field
--- @param name string|nil The field name
--- @param maxLength integer The array max length
--- @param subtype Field The field type for array elements
--- @return VLArray The new Array field
function VLArray.New(name, maxLength, subtype)
    --- @class (partial) VLArray
    local o = setmetatable(Field.New(name, VARIABLE_LENGTH_ARRAY), VLArray)

    local bitLength = maxBitLengthFor(maxLength)
    o.length = Numeric.New(nil, bitLength) --[[@as Numeric]]

    o.subType = subtype

    return o
end

--- Handles an array of values
--- @param data table The array data to handle
--- @return string|nil The binary string representation, or nil on error
function VLArray:Serialize(data, binaryBuffer)
    if type(data) ~= 'table' then error('Value must be a table') end

    self.length:Serialize(#data, binaryBuffer)

    for _, datum in ipairs(data) do
        self.subType:Serialize(datum, binaryBuffer)
    end
end

function VLArray:Unserialize(binaryBuffer)
    local result = {}

    -- TODO: length check

    local length = self.length:Unserialize(binaryBuffer)

    local subType = self.subType
    for i = 1, length do
        result[i] = subType:Unserialize(binaryBuffer)
    end

    return result
end

function VLArray:Skip(binaryBuffer)
    local length = self.length:Unserialize(binaryBuffer)

    local subType = self.subType
    for _ = 1, length do
        subType:Skip(binaryBuffer)
    end
end

function VLArray:GetMaxBitLength()
    local lenghtMaxBitLength = self.length:GetMaxBitLength()
    return lenghtMaxBitLength + getMaxValueForBitLength(lenghtMaxBitLength) * self.subType:GetMaxBitLength()
end

-- ----------------------------------------------------------------------------

local function isSequential(tbl)
    if next(tbl) ~= 1 then
        return false
    else
        return next(tbl, #tbl) == nil
    end
end

--- @class Table : Field
--- @field __index Table
--- @field _fields Field[] The fields contained in the table
local Table = setmetatable({}, { __index = Field })
Table.__index = Table

--- Creates a new Table field
--- @param name string|nil The field name
--- @param fields Field[] The fields contained in the table
--- @return Table @The new Table field
function Table.New(name, fields, ignoreNames)
    --- @class (partial) Table
    local o = setmetatable(Field.New(name, TABLE), Table)

    o._fields = fields
    o._ignoreNames = ignoreNames

    assert(isSequential(fields), 'Fields table must be a simple array!')

    o._indicies = {}
    for i = 1, #fields do
        if fields[i].name then
            o._indicies[fields[i].name] = i
        else
            o._indicies[#o._indicies+1] = i
        end
    end

    return o
end

--- Handles a table of values
--- @param data table The table data to handle
--- @return string|nil @The binary string representation, or nil on error
function Table:Serialize(data, binaryBuffer)
    if type(data) ~= 'table' then error('Value must be a table') end

    if self._ignoreNames then
        for i = 1, #self._fields do
            local field = self._fields[i]
            local datum = data[i]
            field:Serialize(datum, binaryBuffer)
        end
    else
        for i = 1, #self._fields do
            local field = self._fields[i]
            local datum = data[field.name]
            field:Serialize(datum, binaryBuffer)
        end
    end
end

function Table:Unserialize(dataBuffer)
    local result = {}

    local l = 1
    for i = 1, #self._fields do
        local field = self._fields[i]

        local unserializedData = field:Unserialize(dataBuffer)

        if self._ignoreNames or not field.name then
            result[l] = unserializedData
            l = l + 1
        else
            result[field.name] = unserializedData
        end
    end

    return result
end

function Table:Skip(binaryBuffer)
    for i = 1, #self._fields do
        self._fields[i]:Skip(binaryBuffer)
    end
end

function Table:GetMaxBitLength()
    local totalBitLength = 0

    for i = 1, #self._fields do
        totalBitLength = totalBitLength + self._fields[i]:GetMaxBitLength()
    end

    return totalBitLength
end

function Table:Replace(name, substitute)
    self._fields[self._indicies[name]] = substitute
end

function Table:GetFields()
    return self._fields
end

function Table:ShallowCopy(fieldsToCopy)
    local newFieldsArray = {}

    if fieldsToCopy then
        for i = 1, #fieldsToCopy do
            local fieldIndex = self._indicies[fieldsToCopy[i]]
            newFieldsArray[i] = self._fields[fieldIndex]
        end
    else
        ZO_ShallowTableCopy(self._fields, newFieldsArray)
    end

    return Table.New(self.name, newFieldsArray, self._ignoreNames)
end

function Table:Remove(index)
    table.remove(self._fields, self._indicies[index])
end

-- ----------------------------------------------------------------------------

--- @class Boolean : Field
--- @field __index Boolean
local Boolean = setmetatable({}, { __index = Field })
Boolean.__index = Boolean

--- Creates a new Boolean field
--- @param name string|nil The field name
--- @return Boolean @The new Boolean field
function Boolean.New(name)
    --- @class (partial) Boolean
    local o = setmetatable(Field.New(name, BOOLEAN), Boolean)

    return o
end

--- Handles a boolean value
--- @param data boolean The boolean data to handle
--- @return string|nil The binary string representation, or nil on error
function Boolean:Serialize(data, binaryBuffer)
    if type(data) ~= 'boolean' then error('Value must be a boolean') end

    binaryBuffer:WriteBit(data and 1 or 0)
end

function Boolean:Unserialize(dataBuffer)
    return dataBuffer:Read(1) == 1
end

function Boolean:Skip(binaryBuffer)
    binaryBuffer:Skip(1)
end

function Boolean:GetMaxBitLength()
    return 1
end

-- ----------------------------------------------------------------------------

--- @class String : Field
--- @field __index String
local String = setmetatable({}, { __index = Field })
String.__index = String

--- Creates a new Boolean field
--- @param name string|nil The field name
--- @return String @The new String field
function String.New(name, maxLength)
    --- @class (partial) String
    local o = setmetatable(Field.New(name, STRING), String)

    local lengthBits = maxBitLengthFor(maxLength)
    o.length = Numeric.New(nil, lengthBits) --[[@as Numeric]]

    return o
end

--- Handles a string value
--- @param data string The string data to handle
--- @return string|nil The binary string representation, or nil on error
function String:Serialize(data, binaryBuffer)
    if type(data) ~= 'string' then error('Value must be a string') end

    self.length:Serialize(#data, binaryBuffer)

    for i = 1, #data do
        local byte = data:byte(i)
        binaryBuffer:Write(byte, 8)
    end
end

local precomputedPointerChange = {}
do
    for i = 0, 5 do
        precomputedPointerChange[i] = floor((i + 8) / 6)
    end
end
local function read8(buffer)
    local startPointer, startShift = buffer.chunkPointer, buffer.shift

    buffer.shift = (startShift + 8) % 6
    buffer.chunkPointer = buffer.chunkPointer + precomputedPointerChange[startShift]

    local decimal = buffer[buffer.chunkPointer]
    for i = buffer.chunkPointer-1, startPointer, -1  do
        decimal = BitOr(BitLShift(decimal, 6), buffer[i])
    end

    return BitAnd(0xFF, BitRShift(decimal, startShift))
end

function String:Unserialize(dataBuffer)
    local bytesTotal = self.length:Unserialize(dataBuffer)

    local bytes = {}

    if dataBuffer.chunkSize == 6 then
        local p = floor(bytesTotal / 6) * 6
        local reminder = bytesTotal % 6

        for i = 1, p, 6 do
            local decimal = dataBuffer:Read(48)  -- TODO: optimizable
            for k = 0, 4 do
                bytes[i+k] = BitAnd(decimal, 0xFF); decimal = BitRShift(decimal, 8)
            end
            bytes[i+5] = decimal
        end

        for i = p+1, p+reminder do
            bytes[i] = read8(dataBuffer)
        end
    else
        for i = 1, bytesTotal do
            bytes[i] = dataBuffer:Read(8)
        end
    end

    return char(unpack(bytes))
end

function String:Skip(binaryBuffer)
    local bytesTotal = self.length:Unserialize(binaryBuffer)
    binaryBuffer:Skip(bytesTotal * 8)
end

function String:GetMaxBitLength()
    local lenghtMaxBitLength = self.length:GetMaxBitLength()
    return lenghtMaxBitLength + getMaxValueForBitLength(lenghtMaxBitLength) * 8
end

-- ----------------------------------------------------------------------------

--- @class Enum : Field
--- @field __index Enum
local Enum = setmetatable({}, { __index = Field })
Enum.__index = Enum

--- Creates a new Enum field
--- @param name string|nil The field name
--- @param enumTable table The table of values
--- @param inverted boolean|nil If the table is lookup table instead
--- @param bitLength number|nil Amount of reserved bits for Enum 
--- @return Enum @The new Enum field
function Enum.New(name, enumTable, inverted, bitLength)
    --- @class (partial) Enum
    local o = setmetatable(Field.New(name, ENUM), Enum)

    o.forward = enumTable

    o.backward = {}
    for k, v in pairs(enumTable) do
        o.backward[v] = k
    end

    if inverted then
        o.forward, o.backward = o.backward, o.forward
    end

    local calculatedBitLength = maxBitLengthFor(#o.backward)

    if bitLength then
        if calculatedBitLength > bitLength then
            error(('Enum `%s` requires more bits (%d) than reserved (%d)'):format(string(o.name), calculatedBitLength, bitLength))
        end
        o.bitLength = bitLength
    else
        o.bitLength = calculatedBitLength
    end

    o.subType = Numeric.New(nil, o.bitLength) --[[@as Numeric]]

    return o
end

--- Handles a boolean value
--- @param data any The data to handle
--- @return string|nil The binary string representation, or nil on error
function Enum:Serialize(data, binaryBuffer)
    local newValue = self.forward[data]

    if newValue == nil then
        error(('Value %s is not found in enum table'):format(tostring(data)))
    end

    self.subType:Serialize(newValue, binaryBuffer)
end

function Enum:Unserialize(dataBuffer)
    local result = self.subType:Unserialize(dataBuffer)
    local newResult = self.backward[result]

    if newResult == nil then
        error(('Value %s not found in lookup table'):format(tostring(result)))
    end

    return newResult
end

function Enum:Skip(binaryBuffer)
    self.subType:Skip(binaryBuffer)
end

function Enum:GetMaxBitLength()
    return self.subType:GetMaxBitLength()
end

-- ----------------------------------------------------------------------------

--- @class Optional : Field
--- @field __index Optional
--- @field subfield Field Subfield
local Optional = setmetatable({}, { __index = Field })
Optional.__index = Optional

--- Creates a new Optional field
--- @param subfield Field The subfield
--- @return Optional @The new Optional field
function Optional.New(subfield)
    --- @class (partial) Optional
    local o = setmetatable(Field.New(subfield.name, OPTIONAL), Optional)

    o.subfield = subfield

    return o
end

--- Handles a data
--- @param data any The field data to handle
--- @return string|nil The binary string representation, or nil on error
function Optional:Serialize(data, binaryBuffer)
    binaryBuffer:WriteBit(data == nil and 0 or 1)

    if data ~= nil then
        self.subfield:Serialize(data, binaryBuffer)
    end
end

function Optional:Unserialize(dataBuffer)
    if dataBuffer:Read(1) == 0 then return end

    return self.subfield:Unserialize(dataBuffer)
end

function Optional:Skip(binaryBuffer)
    if binaryBuffer:Read(1) == 0 then return end

    self.subfield:Skip(binaryBuffer)
end

function Optional:GetMaxBitLength()
    return self.subfield:GetMaxBitLength() + 1
end

-- ----------------------------------------------------------------------------

lib.BaseField = Field

lib.Field = {
    Number = Numeric.New,
    Array = Array.New,
    VLArray = VLArray.New,
    Table = Table.New,
    Bool = Boolean.New,
    String = String.New,
    Enum = Enum.New,
    Optional = Optional.New,
}

lib.Diagnostics = {
    MaxLength = function(schema, base)
        return ceil(schema:GetMaxBitLength() / base.bitLength)
    end,
}

function lib.Pack(data, schema, base)
    base = base or lib.Base.Base64RCF4648

    local binaryBuffer = BinaryBuffer.New(nil, base.bitLength)
    schema:Serialize(data, binaryBuffer)

    return base:Encode(binaryBuffer)
end

function lib.UnpackMeteredPerStage(data, schema, base)
    base = base or lib.Base.Base64RCF4648

    local meter = GetMeter(schema)

    local t0 = GetGameTimeSeconds()
    local decoded = base:Decode(data)
    meter:AddMeasurement(1, GetGameTimeSeconds() - t0)

    t0 = GetGameTimeSeconds()
    local unserialized = schema:Unserialize(decoded)
    meter:AddMeasurement(2, GetGameTimeSeconds() - t0)

    return unserialized
end

function lib.UnpackUnmetered(data, schema, base)
    base = base or lib.Base.Base64RCF4648
    return schema:Unserialize(base:Decode(data))
end

lib.Unpack = lib.UnpackUnmetered

function lib.Repack(data, oldSchema, newSchema, oldBase, newBase)
    newSchema = newSchema or oldSchema
    newBase = newBase or oldBase

    return lib.Pack(lib.Unpack(data, oldSchema, oldBase), newSchema, newBase)
end

-- ----------------------------------------------------------------------------

LibDataPacker = lib
