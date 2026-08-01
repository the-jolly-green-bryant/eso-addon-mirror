-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local logger = LGB.internal.logger

--[[ doc.lua begin ]] --

--- @docType options
--- @class FlagFieldOptions: FieldOptionsBase
--- @field defaultValue boolean? The default value for the field.

--- @docType hidden
--- @class FlagField: FieldBase
--- @field New fun(self: FlagField, label: string, options?: FlagFieldOptions): FlagField
local FlagField = FieldBase:Subclass()
LGB.internal.class.FlagField = FlagField

--- @protected
function FlagField:Initialize(label, options)
    FieldBase.Initialize(self, label, options)
    options = self.options --[[@as FlagFieldOptions]]
    self:Assert(options.defaultValue == nil or type(options.defaultValue) == "boolean", "defaultValue must be a boolean")
end

--- @protected
function FlagField:GetNumBitsRangeInternal()
    return 1, 1
end

--- Picks the value from the input table based on the label and serializes it to the data stream.
--- @param data BinaryBuffer The data stream to write to.
--- @param input table The input table to pick a value from.
--- @return boolean success Whether the value was successfully serialized.
function FlagField:Serialize(data, input)
    local value = self:GetInputOrDefaultValue(input)
    if type(value) ~= "boolean" then
        logger:Warn("Value must be a boolean")
        return false
    end
    data:GrowIfNeeded(1)
    data:WriteBit(value)
    return true
end

--- Deserializes the value from the data stream, optionally storing it in a table.
--- @param data BinaryBuffer The data stream to read from.
--- @param output? table An optional table to store the deserialized value in with the label of the field as key.
--- @return boolean value The deserialized value.
function FlagField:Deserialize(data, output)
    local value = data:ReadBit(true) --[[@as boolean]]
    if output then
        output[self.label] = value
    end
    return value
end
