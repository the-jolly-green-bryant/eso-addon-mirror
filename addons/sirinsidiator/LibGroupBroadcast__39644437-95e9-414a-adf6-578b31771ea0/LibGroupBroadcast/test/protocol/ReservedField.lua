-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local ReservedField = LGB.internal.class.ReservedField
local BinaryBuffer = LGB.internal.class.BinaryBuffer

Taneth("LibGroupBroadcast", function()
    describe("ReservedField", function()
        it("should be able to create a new instance", function()
            local field = ReservedField:New("test", 1)
            assert.is_true(ZO_Object.IsInstanceOf(field, ReservedField))
        end)

        it("should be able to serialize and deserialize a number of bits", function()
            local fieldA = ReservedField:New("testA", 1)
            local fieldB = ReservedField:New("testB", 8)
            assert.is_true(fieldA:IsValid())
            assert.is_true(fieldB:IsValid())

            local buffer = BinaryBuffer:New(1)
            assert.is_true(fieldA:Serialize(buffer))
            assert.equals(1, buffer:GetNumBits())
            assert.is_true(fieldB:Serialize(buffer))
            assert.equals(9, buffer:GetNumBits())

            buffer:Rewind()
            assert.is_nil(fieldA:Deserialize(buffer))
            assert.equals(2, buffer.cursor)
            assert.is_nil(fieldB:Deserialize(buffer))
            assert.equals(10, buffer.cursor)
        end)
    end)
end)
