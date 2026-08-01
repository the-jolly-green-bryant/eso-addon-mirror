-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local TableField = LGB.internal.class.TableField
local FlagField = LGB.internal.class.FlagField
local OptionalField = LGB.internal.class.OptionalField
local NumericField = LGB.internal.class.NumericField
local BinaryBuffer = LGB.internal.class.BinaryBuffer

Taneth("LibGroupBroadcast", function()
    describe("TableField", function()
        it("should be able to create a new instance", function()
            local field = TableField:New("test", {})
            assert.is_true(ZO_Object.IsInstanceOf(field, TableField))
        end)

        it("should support a defaultValue", function()
            local value = { flag = true }
            local field = TableField:New("test", { FlagField:New("flag") }, { defaultValue = value })
            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, {}))

            buffer:Rewind()
            local output = {}
            local actual = field:Deserialize(buffer, output)
            assert.same(value, actual)
            assert.same({ test = value }, output)
        end)

        it("should be able to serialize and deserialize nested fields", function()
            local field = TableField:New("test", {
                FlagField:New("flag"),
                NumericField:New("numberA", { defaultValue = 1 }),
                OptionalField:New(NumericField:New("numberB")),
            })
            assert.is_true(field:IsValid())

            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, { test = { flag = true, numberA = 42, numberB = 0 } }))
            assert.is_true(field:Serialize(buffer, { test = { flag = false, numberA = 69 } }))
            assert.is_true(field:Serialize(buffer, { test = { flag = true } }))

            buffer:Rewind()
            local output = {}
            local data = field:Deserialize(buffer, output)
            assert.same({ flag = true, numberA = 42, numberB = 0 }, data)
            assert.same({ test = { flag = true, numberA = 42, numberB = 0 } }, output)

            data = field:Deserialize(buffer, output)
            assert.same({ flag = false, numberA = 69 }, data)
            assert.same({ test = { flag = false, numberA = 69 } }, output)

            data = field:Deserialize(buffer, output)
            assert.same({ flag = true, numberA = 1 }, data)
            assert.same({ test = { flag = true, numberA = 1 } }, output)
        end)
    end)
end)
