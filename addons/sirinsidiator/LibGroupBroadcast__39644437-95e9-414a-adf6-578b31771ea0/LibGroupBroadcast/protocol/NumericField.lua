-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local logger = LGB.internal.logger

--[[ doc.lua begin ]] --

--- @docType options
--- @class NumericFieldOptions: FieldOptionsBase
--- @field defaultValue number? The default value for the field
--- @field numBits number? The number of bits to use for the field. If not provided, it will be calculated based on the value range.
--- @field minValue number? The minimum value that can be sent. If not provided, it will be calculated based on the number of bits and maxValue.
--- @field maxValue number? The maximum value that can be sent. If not provided, it will be calculated based on the number of bits and minValue.
--- @field precision number? The precision to use when sending the value. Will be used to divide the value before sending and multiply it after receiving. If not provided, the value will be sent as is.
--- @field trimValues boolean? Whether to trim values to the range. If not provided, send will fail with a warning when the value is out of range.

--- @docType hidden
--- @class NumericField: FieldBase
--- @field protected minValue number
--- @field protected maxValue number
--- @field protected maxSendValue number
--- @field protected numBits number
--- @field protected options NumericFieldOptions
--- @field New fun(self: NumericField, label: string, options?: NumericFieldOptions): NumericField
local NumericField = FieldBase:Subclass()
LGB.internal.class.NumericField = NumericField

--[[ doc.lua end ]] --
local MIN_SUPPORTED_VALUE = 0
local MAX_SUPPORTED_VALUE = 2 ^ 32 - 1
local AVAILABLE_OPTIONS = {
    numBits = true,
    minValue = true,
    maxValue = true,
    precision = true,
    trimValues = true,
}

--- use FPU's rounding mode as seen in https://stackoverflow.com/a/58411671
--- @param num number
--- @return number
local function Round(num)
    return num + (2 ^ 52 + 2 ^ 51) - (2 ^ 52 + 2 ^ 51)
end

--- @param value number
--- @param precision number?
--- @return number
local function ApplyPrecision(value, precision)
    if not precision or precision == 1 then
        return value
    elseif precision > 1 then
        -- the FPU rounding returns incorrect results for precision > 1
        return math.floor(value / precision + 0.5)
    else
        -- need to invert like this, otherwise we get incorrect results in some cases
        return Round(value * (1 / precision))
    end
end
--[[ doc.lua begin ]] --

--- Initializes a new NumericField object.
--- @protected
--- @param label string The label of the field.
--- @param options NumericFieldOptions Optional configuration for the field.
--- @see NumericFieldOptions
function NumericField:Initialize(label, options)
    self:RegisterAvailableOptions(AVAILABLE_OPTIONS)
    FieldBase.Initialize(self, label, options)
    options = self.options --[[@as NumericFieldOptions]]

    if not self:Assert(options.numBits == nil or (options.numBits >= 2 and options.numBits <= 32), "Number of bits must be between 2 and 32") then return end

    if options.minValue then
        self.minValue = options.minValue
    elseif options.numBits then
        if options.maxValue then
            self.minValue = options.maxValue - 2 ^ options.numBits + 1
        else
            self.minValue = MIN_SUPPORTED_VALUE
        end
    else
        self.minValue = MIN_SUPPORTED_VALUE
    end

    if options.maxValue then
        self.maxValue = options.maxValue
    elseif options.numBits then
        local minValue = self.minValue or MIN_SUPPORTED_VALUE
        self.maxValue = minValue + 2 ^ options.numBits - 1
    else
        self.maxValue = MAX_SUPPORTED_VALUE
    end

    local range = ApplyPrecision(self.maxValue - self.minValue, options.precision)
    if not self:Assert(range > 0, "Value range must be more than 0") then return end
    if not self:Assert(range <= MAX_SUPPORTED_VALUE, "Value range is larger than 2^32-1") then return end

    local numBits = options.numBits or 0
    if numBits == 0 then
        while range > 0 do
            range = BitRShift(range, 1)
            numBits = numBits + 1
        end
        if not self:Assert(numBits <= 32, "Number of bits must be at most 32") then return end
    end
    self.maxSendValue = 2 ^ numBits - 1
    if not self:Assert(self.maxSendValue >= range, string.format("Effective value range (%s) is larger then possible transmission value (%s)", range, self.maxSendValue)) then return end
    self.numBits = numBits

    if options.defaultValue then
        if not self:Assert(type(options.defaultValue) == "number", "defaultValue must be a number") then return end
        if not self:Assert(options.defaultValue >= self.minValue and options.defaultValue <= self.maxValue, "defaultValue out of range") then return end
    end
end

--- @protected
function NumericField:GetNumBitsRangeInternal()
    return self.numBits, self.numBits
end

--- Picks the value from the input table based on the label and serializes it to the data stream.
--- @param data BinaryBuffer The data stream to write to.
--- @param input table The input table to pick a value from.
--- @return boolean success Whether the value was successfully serialized.
function NumericField:Serialize(data, input)
    local value = self:GetInputOrDefaultValue(input)
    if type(value) ~= "number" then
        logger:Warn("Value must be a number")
        return false
    end

    local options = self.options
    if options.trimValues then
        logger:Debug("Trimming value to range")
        if value < self.minValue then
            value = self.minValue
        elseif value > self.maxValue then
            value = self.maxValue
        end
    else
        if value < self.minValue or value > self.maxValue then
            logger:Warn("Value out of range")
            return false
        end
    end

    value = ApplyPrecision(value - self.minValue, options.precision)
    assert(value >= 0 and value <= self.maxSendValue, "Value out of range") -- should never happen
    data:GrowIfNeeded(self.numBits)
    data:WriteUInt(value, self.numBits)
    return true
end

--- Deserializes the value from the data stream, optionally storing it in a table.
--- @param data BinaryBuffer The data stream to read from.
--- @param output? table An optional table to store the deserialized value in with the label of the field as key.
--- @return number value The deserialized value.
function NumericField:Deserialize(data, output)
    local value = data:ReadUInt(self.numBits)
    local precision = self.options.precision
    if precision then
        value = value * precision
    end
    value = value + self.minValue

    if output then output[self.label] = value end
    return value
end
