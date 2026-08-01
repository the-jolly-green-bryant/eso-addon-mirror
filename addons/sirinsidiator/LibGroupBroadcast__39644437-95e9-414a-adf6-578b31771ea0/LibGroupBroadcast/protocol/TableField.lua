-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local logger = LGB.internal.logger

--[[ doc.lua begin ]] --

--- @docType options
--- @class TableFieldOptions: FieldOptionsBase
--- @field defaultValue table? The default value for the field.

--- @docType hidden
--- @class TableField: FieldBase
--- @field protected fields FieldBase[]
--- @field New fun(self: TableField, label: string, valueFields: FieldBase[], options?: TableFieldOptions): TableField
local TableField = FieldBase:Subclass()
LGB.internal.class.TableField = TableField

--- @protected
function TableField:Initialize(label, valueFields, options)
    FieldBase.Initialize(self, label, options)
    options = self.options --[[@as TableFieldOptions]]

    if self:Assert(type(valueFields) == "table", "'fields' must be a table") then
        for i = 1, #valueFields do
            if not self:Assert(ZO_Object.IsInstanceOf(valueFields[i], FieldBase), "All valueFields must be instances of FieldBase") then break end
            self:RegisterSubField(valueFields[i])
        end
    else
        valueFields = {}
    end
    self.fields = valueFields

    if options.defaultValue then
        self:Assert(type(options.defaultValue) == "table", "defaultValue must be a table")
    end
end

--- @protected
function TableField:GetNumBitsRangeInternal()
    local minBits, maxBits = 0, 0
    for i = 1, #self.fields do
        local minFieldBits, maxFieldBits = self.fields[i]:GetNumBitsRange()
        minBits = minBits + minFieldBits
        maxBits = maxBits + maxFieldBits
    end
    return minBits, maxBits
end

--- Picks the value from the input table based on the label and serializes it to the data stream.
--- @param data BinaryBuffer The data stream to write to.
--- @param input table The input table to pick a value from.
--- @return boolean success Whether the value was successfully serialized.
function TableField:Serialize(data, input)
    local value = self:GetInputOrDefaultValue(input)
    if type(value) ~= "table" then
        logger:Warn("value must be a table")
        return false
    end

    for i = 1, #self.fields do
        local field = self.fields[i]
        if not field:Serialize(data, value) then return false end
    end
    return true
end

--- Deserializes the value from the data stream, optionally storing it in a table.
--- @param data BinaryBuffer The data stream to read from.
--- @param output? table An optional table to store the deserialized value in with the label of the field as key.
--- @return table value The deserialized value.
function TableField:Deserialize(data, output)
    local value = {}
    for i = 1, #self.fields do
        local field = self.fields[i]
        value[field.label] = field:Deserialize(data)
    end

    if output then output[self.label] = value end
    return value
end
