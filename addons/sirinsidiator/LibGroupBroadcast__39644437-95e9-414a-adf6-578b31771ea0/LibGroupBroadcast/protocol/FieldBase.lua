-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast

local AVAILABLE_OPTIONS = {
    defaultValue = true,
}

--[[ doc.lua begin ]] --

--- @docType hidden
--- @class FieldOptionsBase
--- @field defaultValue any? The default value for the field.

--- @docType hidden
--- @class FieldBase
--- @field protected index integer
--- @field protected label string
--- @field protected warnings table<string>
--- @field protected subfields table<FieldBase>
--- @field protected options FieldOptionsBase
--- @field private avaliableOptions table<string, boolean>
--- @field protected New fun(self: FieldBase, label: string, options?: FieldOptionsBase): FieldBase
--- @field private MUST_IMPLEMENT fun(self:FieldBase, methodName: string)
--- @field protected Initialize fun(self:FieldBase, label: string, options?: FieldOptionsBase)
--- @field protected Subclass fun(): FieldBase
--- @field protected GetNumBitsRangeInternal fun(self:FieldBase): integer, integer
--- @field Serialize fun(self:FieldBase, data: BinaryBuffer, input: table)
--- @field Deserialize fun(self:FieldBase, data: BinaryBuffer, output?: table): any
local FieldBase = ZO_InitializingObject:Subclass()
LGB.internal.class.FieldBase = FieldBase

local function ValidateOptions(self, options)
    if not options then
        return {}
    end

    self:Assert(type(options) == "table", "Options must be a table")
    for key, _ in pairs(options) do
        self:Assert(self.avaliableOptions[key], "Unknown option: " .. key .. " for field " .. self.label)
    end
    return options
end

--- Initializes a new FieldBase object.
--- @protected
--- @param label string The label of the field.
--- @param options? FieldOptionsBase Optional configuration for the field.
function FieldBase:Initialize(label, options)
    self.index = 0
    self.label = label
    self.warnings = {}
    self.subfields = {}
    self:Assert(type(label) == "string", "Label must be a string")
    self:RegisterAvailableOptions(AVAILABLE_OPTIONS)
    self.options = ValidateOptions(self, options)
end

--- Internal function to link a field with a protocol.
--- @param index integer The index of the field in the protocol.
--- @return string[] labels The labels of the field.
function FieldBase:RegisterWithProtocol(index)
    assert(self.index == 0, "Field has already been registered with a protocol")
    self.index = index
    return { self.label }
end

--- Internal function to add options for validation.
--- @protected
--- @param availableOptions table<string, boolean> Additional available options for the field, used for validation.
function FieldBase:RegisterAvailableOptions(availableOptions)
    self.avaliableOptions = ZO_ShallowTableCopy(availableOptions, self.avaliableOptions)
end

--- Internal function to validate and get the options.
--- @protected
--- @param availableOptions? table<string, boolean> Optional available options for the field, used for validation.
--- @return FieldOptionsBase options The validated options.
function FieldBase:ValidateAndGetOptions(availableOptions)
    if availableOptions then
        for key, _ in pairs(self.options) do
            self:Assert(key == "defaultValue" or availableOptions[key], "Unknown option: " .. key)
        end
    end
    return self.options
end

--- Asserts that the condition is true and adds a warning if it is not.
--- @protected
--- @param condition boolean The condition to check.
--- @param message string The warning message to add.
--- @return boolean valid Whether the condition is true.
function FieldBase:Assert(condition, message)
    if not condition then
        local warnings = self.warnings
        warnings[#warnings + 1] = message
        return false
    end
    return true
end

--- Internal function to register a subfield, so it can be checked for warnings and validity.
--- @protected
--- @generic T : FieldBase
--- @param field T The subfield to register.
--- @return T field The passed field.
function FieldBase:RegisterSubField(field)
    self.subfields[#self.subfields + 1] = field
    return field
end

--- Returns the warnings for this field.
--- @return table<string> warnings The warnings for this field.
function FieldBase:GetWarnings()
    local warnings = { self.warnings }
    for i = 1, #self.subfields do
        warnings[#warnings + 1] = self.subfields[i]:GetWarnings()
    end

    local output = {}
    ZO_CombineNumericallyIndexedTables(output, unpack(warnings))
    return output
end

--- Returns whether the field is valid.
--- @return boolean valid Whether the field is valid.
function FieldBase:IsValid()
    if #self.warnings > 0 then
        return false
    end
    for i = 1, #self.subfields do
        if not self.subfields[i]:IsValid() then
            return false
        end
    end
    return true
end

--- Returns the label of the field.
--- @return string label The label of the field.
function FieldBase:GetLabel()
    return self.label
end

--- Tests whether the input table contains a value for this field that can be skipped when serializing an OptionalField.
--- @protected
--- @param values table The table to get the value from.
--- @return boolean optional Whether the value is the default value.
function FieldBase:IsValueOptional(values)
    local value = values[self.label]
    return value == nil or value == self.options.defaultValue
end

--- Applies the default value from the options to the output table, as needed for the OptionalField.
--- @protected
--- @param output? table An optional table to apply the default value to.
--- @return any value The default value.
function FieldBase:ApplyDefaultValue(output)
    if output then
        output[self.label] = self.options.defaultValue
    end
    return self.options.defaultValue
end

--- Gets the value from the input table based on the label of the field, or options.defaultValue if the value is nil.
--- @protected
--- @param values? table The table to get the value from.
--- @return any value The value or options.defaultValue.
function FieldBase:GetInputOrDefaultValue(values)
    local value
    if values then
        value = values[self.label]
    end
    if value == nil then
        return self.options.defaultValue
    end
    return value
end

--- Returns the minimum and maximum number of bits the serialized data will take up.
--- @return integer minBits The minimum number of bits the serialized data will take up.
--- @return integer maxBits The maximum number of bits the serialized data will take up.
function FieldBase:GetNumBitsRange() return self:GetNumBitsRangeInternal() end

--[[ doc.lua end ]] --

FieldBase:MUST_IMPLEMENT("GetNumBitsRangeInternal")
FieldBase:MUST_IMPLEMENT("Serialize")
FieldBase:MUST_IMPLEMENT("Deserialize")
