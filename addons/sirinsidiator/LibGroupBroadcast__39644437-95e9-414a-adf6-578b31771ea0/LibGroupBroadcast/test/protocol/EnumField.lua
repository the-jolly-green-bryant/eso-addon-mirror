-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local EnumField = LGB.internal.class.EnumField
local BinaryBuffer = LGB.internal.class.BinaryBuffer

Taneth("LibGroupBroadcast", function()
    describe("EnumField", function()
        it("should be able to create a new instance", function()
            local field = EnumField:New("test", {})
            assert.is_true(ZO_Object.IsInstanceOf(field, EnumField))
        end)

        it("should return a min and max number of bits, based on the passed field and options", function()
            local fieldA = EnumField:New("testA", { "a", "b", "c" })
            local fieldB = EnumField:New("testB", { "a", "b", "c", "d", "e" })
            local fieldC = EnumField:New("testC", { "a", "b", "c" }, { numBits = 5 })
            assert.is_true(fieldA:IsValid())
            assert.is_true(fieldB:IsValid())
            assert.is_true(fieldC:IsValid())

            local minA, maxA = fieldA:GetNumBitsRange()
            assert.equals(2, minA)
            assert.equals(2, maxA)

            local minB, maxB = fieldB:GetNumBitsRange()
            assert.equals(3, minB)
            assert.equals(3, maxB)

            local minC, maxC = fieldC:GetNumBitsRange()
            assert.equals(5, minC)
            assert.equals(5, maxC)
        end)

        it("should support a defaultValue", function()
            local values = { "a", true, 1, "test" }
            local field = EnumField:New("test", values, { defaultValue = values[2] })
            assert.is_true(field:IsValid())

            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, {}))
            buffer:Rewind()
            local output = {}
            assert.equals(values[2], field:Deserialize(buffer, output))
            assert.same({ test = values[2] }, output)
        end)

        it("should be able to serialize and deserialize a value", function()
            local values = { "a", true, 1, "test" }
            local field = EnumField:New("test", values)
            assert.is_true(field:IsValid())
            for i = 1, #values do
                local buffer = BinaryBuffer:New(1)
                assert.is_true(field:Serialize(buffer, { test = values[i] }))
                buffer:Rewind()
                local output = {}
                assert.equals(values[i], field:Deserialize(buffer, output))
                assert.same({ test = values[i] }, output)
                assert.equals(2, buffer:GetNumBits())
            end
        end)
    end)
end)
