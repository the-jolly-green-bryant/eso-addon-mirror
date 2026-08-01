-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local FlagField = LGB.internal.class.FlagField

--[[ doc.lua begin ]] --

--- @docType hidden
--- @class OptionalField: FieldBase
--- @field protected isNilField FlagField
--- @field protected valueField FieldBase
--- @field New fun(self: OptionalField, valueField: FieldBase): OptionalField
local OptionalField = FieldBase:Subclass()
LGB.internal.class.OptionalField = OptionalField

--- @protected
function OptionalField:Initialize(valueField)
    FieldBase.Initialize(self, valueField.label)

    self.isNilField = self:RegisterSubField(FlagField:New("IsNil"))
    self.valueField = self:RegisterSubField(valueField)
    self:Assert(ZO_Object.IsInstanceOf(valueField, FieldBase), "'valueField' must be an instance of FieldBase")
end

--- @protected
function OptionalField:GetNumBitsRangeInternal()
    local minFlagBits, maxFlagBits = self.isNilField:GetNumBitsRange()
    local _, maxValueBits = self.valueField:GetNumBitsRange()
    return minFlagBits, maxFlagBits + maxValueBits
end

--- Picks the value from the input table based on the label and serializes it to the data stream.
--- @param data BinaryBuffer The data stream to write to.
--- @param input table The input table to pick a value from.
--- @return boolean success Whether the value was successfully serialized.
function OptionalField:Serialize(data, input)
    if self.valueField:IsValueOptional(input) then
        if not self.isNilField:Serialize(data, { [self.isNilField.label] = true }) then return false end
    else
        if not self.isNilField:Serialize(data, { [self.isNilField.label] = false }) then return false end
        if not self.valueField:Serialize(data, input) then return false end
    end
    return true
end

--- Deserializes the value from the data stream, optionally storing it in a table.
--- @param data BinaryBuffer The data stream to read from.
--- @param output? table An optional table to store the deserialized value in with the label of the field as key.
--- @return any|nil value The deserialized value.
function OptionalField:Deserialize(data, output)
    if self.isNilField:Deserialize(data) then
        return self.valueField:ApplyDefaultValue(output)
    end
    return self.valueField:Deserialize(data, output)
end
