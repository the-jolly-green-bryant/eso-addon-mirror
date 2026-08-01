-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local EnumField = LGB.internal.class.EnumField
local logger = LGB.internal.logger

local TOO_MANY_VARIANTS_SET = {}
local AVAILABLE_OPTIONS = {
    maxNumVariants = true,
    numBits = true,
}

--[[ doc.lua begin ]] --

--- @docType options
--- @class VariantFieldOptions: FieldOptionsBase
--- @field defaultValue table? The default value for the field.
--- @field maxNumVariants number? The maximum number of variants that can be used. Can be used to reserve space for future variants.
--- @field numBits number? The number of bits to use for the amount of variants. Can be used to reserve additional space to allow for future variants.

--- @docType hidden
--- @class VariantField: FieldBase
--- @field protected labelField EnumField
--- @field protected variants FieldBase[]
--- @field protected variantByLabel table<string, FieldBase>
--- @field New fun(self: VariantField, variants: FieldBase[], options?: VariantFieldOptions): VariantField
local VariantField = FieldBase:Subclass()
LGB.internal.class.VariantField = VariantField

--- @protected
function VariantField:Initialize(variants, options)
    self:RegisterAvailableOptions(AVAILABLE_OPTIONS)
    FieldBase.Initialize(self, "variants", options)
    options = self.options --[[@as VariantFieldOptions]]

    local entries = {}
    local variantByLabel = {}
    if self:Assert(type(variants) == "table" and #variants > 1, "'variants' must be a table with at least 2 entries") then
        for i = 1, #variants do
            local variant = variants[i]
            if not self:Assert(ZO_Object.IsInstanceOf(variant, FieldBase), "All variants must be instances of FieldBase") then break end
            if not self:Assert(not variantByLabel[variant.label], "All variants must have unique labels") then break end
            self:RegisterSubField(variant)
            variantByLabel[variant.label] = variant
            entries[#entries + 1] = variant.label
        end
        self.label = string.format("%s(%s)", self.label, table.concat(entries, ", "))
    end

    self.labelField = self:RegisterSubField(EnumField:New("label", entries, {
        numBits = options.numBits,
        maxValue = options.maxNumVariants,
    }))
    self.variants = variants
    self.variantByLabel = variantByLabel

    if options.defaultValue then
        self:Assert(type(options.defaultValue) == "table", "defaultValue must be a table")
    end
end

function VariantField:RegisterWithProtocol(index)
    local labels = FieldBase.RegisterWithProtocol(self, index)
    for i = 1, #self.variants do
        labels[i] = self.variants[i].label
    end
    return labels
end

function VariantField:PickValue(values)
    local value
    local count = 0
    for i = 1, #self.variants do
        local variant = self.variants[i]
        if values[variant.label] ~= nil then
            value = { [variant.label] = values[variant.label] }
            count = count + 1
        end
    end
    if count > 1 then
        logger:Warn("Expected exactly one variant to be set for field %s, but found %d", self.label, count)
        return TOO_MANY_VARIANTS_SET
    end
    return value
end

--- @protected
function VariantField:GetNumBitsRangeInternal()
    local minBits, maxBits = self.labelField:GetNumBitsRange()
    for i = 1, #self.variants do
        local minVariantBits, maxVariantBits = self.variants[i]:GetNumBitsRange()
        minBits = minBits + minVariantBits
        maxBits = maxBits + maxVariantBits
    end
    return minBits, maxBits
end

function VariantField:IsValueOptional(values)
    for i = 1, #self.variants do
        if not self.variants[i]:IsValueOptional(values) then
            return false
        end
    end
    return true
end

function VariantField:ApplyDefaultValue(output)
    local default = self.options.defaultValue
    if not default then return nil end
    local label, value = next(default)
    if label and output then
        output[label] = value
    end
    return value
end

--- @protected
function VariantField:GetValueOrDefault(values)
    local count = 0
    local value
    for i = 1, #self.variants do
        local variant = self.variants[i]
        if values[variant.label] ~= nil then
            value = { [variant.label] = values[variant.label] }
            count = count + 1
        end
    end

    if count > 1 then
        return TOO_MANY_VARIANTS_SET
    end

    if value == nil then
        return self.options.defaultValue
    end
    return value
end

--- Picks the value from the input table based on the label and serializes it to the data stream.
--- @param data BinaryBuffer The data stream to write to.
--- @param input table The input table to pick a value from.
--- @return boolean success Whether the value was successfully serialized.
function VariantField:Serialize(data, input)
    local value = self:GetValueOrDefault(input)
    if value == TOO_MANY_VARIANTS_SET then
        logger:Warn("Expected at most one variant to be set for field %s, but found %d", self.label)
        return false
    end

    if type(value) ~= "table" then
        logger:Warn("Value must be a table")
        return false
    end

    local label = next(value)
    local variant = self.variantByLabel[label]
    if not variant then
        logger:Warn("Tried to serialize unknown variant:", label)
        return false
    end

    if not self.labelField:Serialize(data, { label = label }) then return false end
    if not variant:Serialize(data, value) then return false end
    return true
end

--- Deserializes the value from the data stream, optionally storing it in a table.
--- @param data BinaryBuffer The data stream to read from.
--- @param output? table An optional table to store the deserialized value in with the label of the field as key.
--- @return any value The deserialized value.
function VariantField:Deserialize(data, output)
    local label = self.labelField:Deserialize(data)
    local variant = self.variantByLabel[label]
    if not variant then
        logger:Warn("Tried to deserialize unknown variant:", label)
        return nil
    end

    local value = variant:Deserialize(data, output)
    if output then output[variant.label] = value end
    return value
end
