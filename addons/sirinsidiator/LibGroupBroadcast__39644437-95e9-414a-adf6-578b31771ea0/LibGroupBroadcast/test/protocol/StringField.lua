-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local StringField = LGB.internal.class.StringField
local BinaryBuffer = LGB.internal.class.BinaryBuffer

Taneth("LibGroupBroadcast", function()
    describe("StringField", function()
        it("should be able to create a new instance", function()
            local field = StringField:New("test")
            assert.is_true(ZO_Object.IsInstanceOf(field, StringField))
        end)

        it("should support a defaultValue", function()
            local value = "a"
            local field = StringField:New("test", { defaultValue = value })
            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, {}))

            buffer:Rewind()
            local output = {}
            local actual = field:Deserialize(buffer, output)
            assert.equals(value, actual)
            assert.same({ test = value }, output)
        end)

        it("should be able to serialize and deserialize a string", function()
            local field = StringField:New("test")
            assert.is_true(field:IsValid())

            local buffer = BinaryBuffer:New(1)
            local expectedNumBits = 8 + 0 * 8
            assert.is_true(field:Serialize(buffer, { test = "" }))
            assert.equals(expectedNumBits, buffer:GetNumBits())
            expectedNumBits = expectedNumBits + 8 + 4 * 8
            assert.is_true(field:Serialize(buffer, { test = "test" }))
            assert.equals(expectedNumBits, buffer:GetNumBits())
            expectedNumBits = expectedNumBits + 8 + 5 * 8 * 3
            assert.is_true(field:Serialize(buffer, { test = "あいうえお" }))
            assert.equals(expectedNumBits, buffer:GetNumBits())

            buffer:Rewind()
            local output = {}
            assert.equals("", field:Deserialize(buffer, output))
            assert.same({ test = "" }, output)
            assert.equals("test", field:Deserialize(buffer, output))
            assert.same({ test = "test" }, output)
            assert.equals("あいうえお", field:Deserialize(buffer, output))
            assert.same({ test = "あいうえお" }, output)
        end)

        it("should be able to serialize and deserialize an optimized string using options", function()
            local field = StringField:New("test", { characters = "0123456789", minLength = 4, maxLength = 8 })
            assert.is_true(field:IsValid())
            local minBits, maxBits = field:GetNumBitsRange()
            assert.equals(3 + 4 * 4, minBits)
            assert.equals(3 + 8 * 4, maxBits)

            local buffer = BinaryBuffer:New(1)
            assert.is_false(field:Serialize(buffer, { test = "" }))
            local expectedNumBits = 3 + 4 * 4
            assert.is_true(field:Serialize(buffer, { test = "0123" }))
            assert.equals(expectedNumBits, buffer:GetNumBits())
            expectedNumBits = expectedNumBits + 3 + 7 * 4
            assert.is_true(field:Serialize(buffer, { test = "3456789" }))
            assert.equals(expectedNumBits, buffer:GetNumBits())
            assert.is_false(field:Serialize(buffer, { test = " 56789a" }))

            buffer:Rewind()
            local output = {}
            assert.equals("0123", field:Deserialize(buffer, output))
            assert.same({ test = "0123" }, output)
            assert.equals("3456789", field:Deserialize(buffer, output))
            assert.same({ test = "3456789" }, output)
        end)

        it("should be able to serialize and deserialize a string with a custom character set", function()
            local field = StringField:New("test", { characters = "あいうえお" })
            assert.is_true(field:IsValid())
            local minBits, maxBits = field:GetNumBitsRange()
            assert.equals(8 + 0 * 3, minBits)
            assert.equals(8 + 255 * 3, maxBits)

            local buffer = BinaryBuffer:New(1)
            local expectedNumBits = 8 + 0 * 3
            assert.is_true(field:Serialize(buffer, { test = "" }))
            assert.equals(expectedNumBits, buffer:GetNumBits())
            expectedNumBits = expectedNumBits + 8 + 2 * 3
            assert.is_true(field:Serialize(buffer, { test = "あい" }))
            assert.equals(expectedNumBits, buffer:GetNumBits())
            expectedNumBits = expectedNumBits + 8 + 2 * 3
            assert.is_true(field:Serialize(buffer, { test = "えお" }))
            assert.equals(expectedNumBits, buffer:GetNumBits())
            assert.is_false(field:Serialize(buffer, { test = "test" }))

            buffer:Rewind()
            local output = {}
            assert.equals("", field:Deserialize(buffer, output))
            assert.same({ test = "" }, output)
            assert.equals("あい", field:Deserialize(buffer, output))
            assert.same({ test = "あい" }, output)
            assert.equals("えお", field:Deserialize(buffer, output))
            assert.same({ test = "えお" }, output)
        end)

        it("should fail to serialize when trying to write more characters than the maximum length", function()
            local field = StringField:New("test", { maxLength = 4 })
            assert.is_true(field:IsValid())

            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, { test = "test" }))
            assert.is_false(field:Serialize(buffer, { test = "tests" }))
        end)
    end)
end)
