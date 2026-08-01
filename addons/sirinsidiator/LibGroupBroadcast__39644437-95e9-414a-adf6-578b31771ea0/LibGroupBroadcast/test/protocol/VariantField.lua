-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local VariantField = LGB.internal.class.VariantField
local TableField = LGB.internal.class.TableField
local FlagField = LGB.internal.class.FlagField
local NumericField = LGB.internal.class.NumericField
local BinaryBuffer = LGB.internal.class.BinaryBuffer
local OptionalField = LGB.internal.class.OptionalField

Taneth("LibGroupBroadcast", function()
    describe("VariantField", function()
        it("should be able to create a new instance", function()
            local field = VariantField:New({})
            assert.is_true(ZO_Object.IsInstanceOf(field, VariantField))
        end)

        it("should support a defaultValue", function()
            local field = VariantField:New({
                FlagField:New("flagA"),
                FlagField:New("flagB"),
            }, { defaultValue = { flagA = true } })
            assert.equals("variants(flagA, flagB)", field:GetLabel())

            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, {}))

            buffer:Rewind()
            local output = {}
            local actual = field:Deserialize(buffer, output)
            assert.is_true(actual)
            assert.same({ flagA = true }, output)
        end)

        it("should be able to serialize and deserialize nested fields", function()
            local field = VariantField:New({
                TableField:New("table", {
                    FlagField:New("flag"),
                    NumericField:New("number"),
                }),
                NumericField:New("number"),
            })
            assert.is_true(field:IsValid())

            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, {
                table = { flag = true, number = 42 }
            }))
            assert.is_true(field:Serialize(buffer, {
                number = 69
            }))

            buffer:Rewind()
            local output = {}
            local data = field:Deserialize(buffer, output)
            assert.same({ flag = true, number = 42 }, data)
            assert.same({ table = { flag = true, number = 42 } }, output)

            output = {}
            data = field:Deserialize(buffer, output)
            assert.equals(69, data)
            assert.same({ number = 69 }, output)
        end)

        it("should be possible to be optional", function()
            local field = OptionalField:New(VariantField:New({
                NumericField:New("test"),
                NumericField:New("test2"),
            }))
            assert.is_true(field:IsValid())

            local buffer = BinaryBuffer:New(1)
            assert.is_true(field:Serialize(buffer, {
                test = 42
            }))
            assert.equals(1 + 1 + 32, buffer:GetNumBits())
            assert.is_true(field:Serialize(buffer, {
            }))
            assert.equals(34 + 1, buffer:GetNumBits())

            buffer:Rewind()
            local output = {}
            local data = field:Deserialize(buffer, output)
            assert.equals(42, data)
            assert.same({ test = 42 }, output)

            output = {}
            data = field:Deserialize(buffer, output)
            assert.is_nil(data)
            assert.same({ test = nil }, output)
        end)
    end)
end)
