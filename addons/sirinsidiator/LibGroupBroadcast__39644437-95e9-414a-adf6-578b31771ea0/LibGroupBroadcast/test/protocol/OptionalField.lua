-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local OptionalField = LGB.internal.class.OptionalField
local NumericField = LGB.internal.class.NumericField
local BinaryBuffer = LGB.internal.class.BinaryBuffer

Taneth("LibGroupBroadcast", function()
    describe("OptionalField", function()
        it("should be able to create a new instance", function()
            local field = OptionalField:New(NumericField:New("test"))
            assert.is_true(ZO_Object.IsInstanceOf(field, OptionalField))
        end)

        it("should be use the label of the inner field", function()
            local field = OptionalField:New(NumericField:New("test"))
            assert.is_true(field:IsValid())
            assert.equals("test", field.label)
        end)

        it("should return a min and max number of bits, based on the passed field", function()
            local fieldA = OptionalField:New(NumericField:New("testA"))
            local fieldB = OptionalField:New(NumericField:New("testB", { numBits = 4 }))
            assert.is_true(fieldA:IsValid())
            assert.is_true(fieldB:IsValid())

            local minA, maxA = fieldA:GetNumBitsRange()
            assert.equals(1, minA)
            assert.equals(1 + 32, maxA)

            local minB, maxB = fieldB:GetNumBitsRange()
            assert.equals(1, minB)
            assert.equals(1 + 4, maxB)
        end)

        it("should be able to serialize and deserialize nil and use only 1 bit", function()
            local field = OptionalField:New(NumericField:New("test"))
            assert.is_true(field:IsValid())
            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, { test = nil }))
            buffer:Rewind()
            local output = {}
            assert.is_nil(field:Deserialize(buffer, output))
            assert.same({ test = nil }, output)
            assert.equals(1, buffer:GetNumBits())
        end)

        it("should be able to serialize and deserialize a value and use the correct number of bits", function()
            local field = OptionalField:New(NumericField:New("test", { numBits = 4 }))
            assert.is_true(field:IsValid())
            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, { test = 0 }))
            buffer:Rewind()
            local output = {}
            assert.equals(0, field:Deserialize(buffer, output))
            assert.same({ test = 0 }, output)
            assert.equals(5, buffer:GetNumBits())
        end)

        it("should be able to serialize and deserialize a default value", function()
            local field = OptionalField:New(NumericField:New("test", { defaultValue = 3 }))
            assert.is_true(field:IsValid())
            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, {}))
            buffer:Rewind()
            local output = {}
            assert.equals(3, field:Deserialize(buffer, output))
            assert.same({ test = 3 }, output)
            assert.equals(1, buffer:GetNumBits())
        end)
    end)
end)
