-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local NumericField = LGB.internal.class.NumericField
local logger = LGB.internal.logger

local AVAILABLE_OPTIONS = {
    numBits = true,
    maxValue = true,
}

--[[ doc.lua begin ]] --

--- @docType options
--- @class EnumFieldOptions: FieldOptionsBase
--- @field maxValue number? The max value of the field. Defaults to the length of the valueTable. Can be used to reserve space for future values.
--- @field numBits number? The number of bits to use for the field. Can be used to reserve a specific number of bits for future values.

--- @docType hidden
--- @class EnumField: FieldBase
--- @field protected indexField NumericField
--- @field protected valueTable any[]
--- @field protected valueLookup table
--- @field New fun(self: EnumField, label: string, valueTable: any[], options?: EnumFieldOptions): EnumField
local EnumField = FieldBase:Subclass()
LGB.internal.class.EnumField = EnumField

--- @protected
function EnumField:Initialize(label, valueTable, options)
    self:RegisterAvailableOptions(AVAILABLE_OPTIONS)
    FieldBase.Initialize(self, label, options)
    options = self.options --[[@as EnumFieldOptions]]

    if not self:Assert(type(valueTable) == "table" and #valueTable > 0, "The valueTable must be a non-empty table") then return end
    self.indexField = self:RegisterSubField(NumericField:New("index", {
        numBits = options.numBits,
        minValue = 1,
        maxValue = math.max(#valueTable, options.maxValue or 0),
    }))

    self.valueTable = valueTable
    self.valueLookup = {}
    for i = 1, #valueTable do
        self.valueLookup[valueTable[i]] = i
    end

    if options.defaultValue then
        self:Assert(self.valueLookup[options.defaultValue] ~= nil, "The defaultValue has to be part of the valueTable")
    end
end

--- @protected
function EnumField:GetNumBitsRangeInternal()
    return self.indexField:GetNumBitsRange()
end

--- Picks the value from the input table based on the label and serializes it to the data stream.
--- @param data BinaryBuffer The data stream to write to.
--- @param input table The input table to pick a value from.
--- @return boolean success Whether the value was successfully serialized.
function EnumField:Serialize(data, input)
    local value = self:GetInputOrDefaultValue(input)
    local index = self.valueLookup[value]
    if not index then
        logger:Warn("Tried to serialize value that is not part of the valueTable")
        return false
    end
    return self.indexField:Serialize(data, { index = index })
end

--- Deserializes the value from the data stream, optionally storing it in a table.
--- @param data BinaryBuffer The data stream to read from.
--- @param output? table An optional table to store the deserialized value in with the label of the field as key.
--- @return any value The deserialized value.
function EnumField:Deserialize(data, output)
    local index = self.indexField:Deserialize(data)
    local value = self.valueTable[index]
    if value == nil then
        logger:Warn("Tried to deserialize unknown index:", index)
    end
    if output then output[self.label] = value end
    return value
end
