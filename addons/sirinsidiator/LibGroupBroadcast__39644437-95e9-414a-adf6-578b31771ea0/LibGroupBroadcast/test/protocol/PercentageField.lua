-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local PercentageField = LGB.internal.class.PercentageField
local BinaryBuffer = LGB.internal.class.BinaryBuffer

Taneth("LibGroupBroadcast", function()
    describe("PercentageField", function()
        it("should be able to create a new instance", function()
            local field = PercentageField:New("test")
            assert.is_true(ZO_Object.IsInstanceOf(field, PercentageField))
        end)

        it("should support a defaultValue", function()
            local value = 1
            local field = PercentageField:New("test", { defaultValue = value })
            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, {}))

            buffer:Rewind()
            local actual = field:Deserialize(buffer)
            assert.equals(value, actual)
        end)

        it("should transfer values between 0 and 1 with 1/127 precision", function()
            local field = PercentageField:New("test")
            assert.is_true(field:IsValid())
            local numBits = field:GetNumBitsRange()
            assert.equals(7, numBits)
            assert.equals(0, field.minValue)
            assert.equals(1, field.maxValue)
            assert.equals(127, field.maxSendValue)

            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, { test = 0 }))
            assert.is_true(field:Serialize(buffer, { test = 1 }))
            assert.is_true(field:Serialize(buffer, { test = 0.5 }))
            assert.is_true(field:Serialize(buffer, { test = 0.25 }))
            assert.is_true(field:Serialize(buffer, { test = 0.75 }))
            assert.is_false(field:Serialize(buffer, { test = -0.1 }))
            assert.is_false(field:Serialize(buffer, { test = 1.1 }))

            buffer:Rewind()
            local output = {}
            assert.equals(0, field:Deserialize(buffer, output))
            assert.same({ test = 0 }, output)
            assert.equals(1, field:Deserialize(buffer, output))
            assert.same({ test = 1 }, output)
            assert.equals(64 / 127, field:Deserialize(buffer, output))
            assert.same({ test = 64 / 127 }, output)
            assert.equals(32 / 127, field:Deserialize(buffer, output))
            assert.same({ test = 32 / 127 }, output)
            assert.equals(95 / 127, field:Deserialize(buffer, output))
            assert.same({ test = 95 / 127 }, output)
        end)

        it("should be able to set a custom number of bits", function()
            local field = PercentageField:New("test", { numBits = 6 })
            assert.is_true(field:IsValid())
            local numBits = field:GetNumBitsRange()
            assert.equals(6, numBits)
            assert.equals(0, field.minValue)
            assert.equals(1, field.maxValue)
            assert.equals(63, field.maxSendValue)

            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, { test = 0 }))
            assert.is_true(field:Serialize(buffer, { test = 1 }))
            assert.is_true(field:Serialize(buffer, { test = 0.5 }))
            assert.is_true(field:Serialize(buffer, { test = 0.25 }))
            assert.is_true(field:Serialize(buffer, { test = 0.75 }))
            assert.is_false(field:Serialize(buffer, { test = -0.1 }))
            assert.is_false(field:Serialize(buffer, { test = 1.1 }))

            buffer:Rewind()
            local output = {}
            assert.equals(0, field:Deserialize(buffer, output))
            assert.same({ test = 0 }, output)
            assert.equals(1, field:Deserialize(buffer, output))
            assert.same({ test = 1 }, output)
            assert.equals(32 / 63, field:Deserialize(buffer, output))
            assert.same({ test = 32 / 63 }, output)
            assert.equals(16 / 63, field:Deserialize(buffer, output))
            assert.same({ test = 16 / 63 }, output)
            assert.equals(47 / 63, field:Deserialize(buffer, output))
            assert.same({ test = 47 / 63 }, output)
        end)
    end)
end)
