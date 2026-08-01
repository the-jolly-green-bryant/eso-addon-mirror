-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local ArrayField = LGB.internal.class.ArrayField
local FlagField = LGB.internal.class.FlagField
local NumericField = LGB.internal.class.NumericField
local BinaryBuffer = LGB.internal.class.BinaryBuffer

Taneth("LibGroupBroadcast", function()
    describe("ArrayField", function()
        it("should be able to create a new instance", function()
            local field = ArrayField:New(FlagField:New("test"))
            assert.is_true(ZO_Object.IsInstanceOf(field, ArrayField))
        end)

        it("should use the label of the inner field", function()
            local field = ArrayField:New(FlagField:New("test"))
            assert.is_true(field:IsValid())
            assert.equals("test", field.label)
        end)

        it("should return a min and max number of bits, based on the passed field", function()
            local fieldA = ArrayField:New(FlagField:New("testA"), { maxLength = 15 })
            local fieldB = ArrayField:New(FlagField:New("testB"))
            local fieldC = ArrayField:New(NumericField:New("testC", { numBits = 4 }), { minLength = 5, maxLength = 9 })
            assert.is_true(fieldA:IsValid())
            assert.is_true(fieldB:IsValid())
            assert.is_true(fieldC:IsValid())

            local minA, maxA = fieldA:GetNumBitsRange()
            assert.equals(4, minA)
            assert.equals(4 + 15, maxA)

            local minB, maxB = fieldB:GetNumBitsRange()
            assert.equals(8, minB)
            assert.equals(8 + 255, maxB)

            local minC, maxC = fieldC:GetNumBitsRange()
            assert.equals(3 + 5 * 4, minC)
            assert.equals(3 + 9 * 4, maxC)
        end)

        it("should support a defaultValue", function()
            local value = { true, false, true }
            local field = ArrayField:New(FlagField:New("test"), { defaultValue = value })
            local buffer = BinaryBuffer:New(11)
            assert.is_true(field:Serialize(buffer, {}))
            assert.equals(8 + 3, buffer:GetNumBits())

            buffer:Rewind()
            local output = {}
            local actual = field:Deserialize(buffer, output)
            assert.same(value, actual)
            assert.same({ test = value }, output)
        end)

        it("should be able to serialize and deserialize an empty array", function()
            local field = ArrayField:New(FlagField:New("test"))
            assert.is_true(field:IsValid())

            local buffer = BinaryBuffer:New(8)
            assert.is_true(field:Serialize(buffer, { test = {} }))
            assert.equals(8, buffer:GetNumBits())

            buffer:Rewind()
            local output = {}
            local actual = field:Deserialize(buffer, output)
            assert.same({}, actual)
            assert.same({ test = {} }, output)
        end)

        it("should be able to serialize and deserialize an array of values", function()
            local input = { true, false, true, false }
            local field = ArrayField:New(FlagField:New("test"))
            assert.is_true(field:IsValid())

            local buffer = BinaryBuffer:New(8)
            assert.is_true(field:Serialize(buffer, { test = input }))
            assert.equals(8 + #input, buffer:GetNumBits())

            buffer:Rewind()
            local output = {}
            local actual = field:Deserialize(buffer, output)
            assert.same(input, actual)
            assert.same({ test = input }, output)
        end)

        it("should be able to serialize and deserialize an array of values with a min length", function()
            local input = { 1, 2, 3, 4, 5 }
            local field = ArrayField:New(NumericField:New("test", { numBits = 4 }), { minLength = 5, maxLength = 9 })
            assert.is_true(field:IsValid())

            local buffer = BinaryBuffer:New(8)
            assert.is_true(field:Serialize(buffer, { test = input }))
            assert.equals(3 + #input * 4, buffer:GetNumBits())

            buffer:Rewind()
            local output = {}
            local actual = field:Deserialize(buffer, output)
            assert.same(input, actual)
            assert.same({ test = input }, output)
        end)
    end)
end)
