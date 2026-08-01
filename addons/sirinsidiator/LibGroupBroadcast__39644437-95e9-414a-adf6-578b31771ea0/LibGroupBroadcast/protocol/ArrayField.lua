-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local NumericField = LGB.internal.class.NumericField
local logger = LGB.internal.logger

--[[ doc.lua begin ]] --

--- @docType options
--- @class ArrayFieldOptions : FieldOptionsBase
--- @field minLength number? The minimum length of the array.
--- @field maxLength number? The maximum length of the array.
--- @field defaultValue table? The default value for the field.

--- @docType hidden
--- @class ArrayField: FieldBase
--- @field protected minLength number
--- @field protected maxLength number
--- @field protected countField NumericField
--- @field protected valueField FieldBase
--- @field New fun(self:ArrayField, valueField: FieldBase, options?: ArrayFieldOptions): ArrayField
local ArrayField = FieldBase:Subclass()
LGB.internal.class.ArrayField = ArrayField

--[[ doc.lua end ]] --
local DEFAULT_MAX_LENGTH = 2 ^ 8 - 1
local AVAILABLE_OPTIONS = {
    minLength = true,
    maxLength = true,
}
--[[ doc.lua begin ]] --

--- @protected
function ArrayField:Initialize(valueField, options)
    self:RegisterAvailableOptions(AVAILABLE_OPTIONS)
    FieldBase.Initialize(self, valueField.label, options)
    options = self.options --[[@as ArrayFieldOptions]]

    local minLength = options.minLength or 0
    local maxLength = options.maxLength or DEFAULT_MAX_LENGTH
    self:Assert(type(minLength) and minLength >= 0, "minLength must be a number >= 0")
    self:Assert(type(maxLength) and maxLength > minLength, "maxLength must be a number > minLength")
    self:Assert(ZO_Object.IsInstanceOf(valueField, FieldBase), "valueField must be an instance of FieldBase")

    self.countField = self:RegisterSubField(NumericField:New("count", {
        minValue = minLength,
        maxValue = maxLength,
    }))
    self.minLength = minLength
    self.maxLength = maxLength
    self.valueField = self:RegisterSubField(valueField)

    if options.defaultValue then
        self:Assert(type(options.defaultValue) == "table", "defaultValue must be a table")
    end
end

--- @protected
function ArrayField:GetNumBitsRangeInternal()
    local minCountBits, maxCountBits = self.countField:GetNumBitsRange()
    local minValueBits, maxValueBits = self.valueField:GetNumBitsRange()
    local minBits = minCountBits + self.minLength * minValueBits
    local maxBits = maxCountBits + self.maxLength * maxValueBits
    return minBits, maxBits
end

--- Picks the value from the input table based on the label and serializes it to the data stream.
--- @param data BinaryBuffer The data stream to write to.
--- @param input table The input table to pick a value from.
--- @return boolean success Whether the value was successfully serialized.
function ArrayField:Serialize(data, input)
    local value = self:GetInputOrDefaultValue(input)
    if type(value) ~= "table" then
        logger:Warn("value must be a table")
        return false
    end

    if #value < self.minLength or #value > self.maxLength then
        logger:Warn("length must be between " .. self.minLength .. " and " .. self.maxLength)
        return false
    end

    local count = #value
    if not self.countField:Serialize(data, { count = count }) then
        return false
    end

    for i = 1, count do
        if not self.valueField:Serialize(data, { [self.label] = value[i] }) then
            return false
        end
    end
    return true
end

--- Deserializes the value from the data stream, optionally storing it in a table.
--- @param data BinaryBuffer The data stream to read from.
--- @param output? table An optional table to store the deserialized value in with the label of the field as key.
--- @return any[] value The deserialized value.
function ArrayField:Deserialize(data, output)
    local count = self.countField:Deserialize(data)
    local value = {}
    for i = 1, count do
        value[i] = self.valueField:Deserialize(data)
    end

    if output then output[self.label] = value end
    return value
end
