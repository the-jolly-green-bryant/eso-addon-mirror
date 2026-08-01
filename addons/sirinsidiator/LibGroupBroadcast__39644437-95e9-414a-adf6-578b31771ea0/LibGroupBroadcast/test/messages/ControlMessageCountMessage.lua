-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local BinaryBuffer = LGB.internal.class.BinaryBuffer
local ControlMessageBase = LGB.internal.class.ControlMessageBase
local ControlMessageCountMessage = LGB.internal.class.ControlMessageCountMessage

Taneth("LibGroupBroadcast", function()
    describe("ControlMessageCountMessage", function()
        it("should be able to create a new instance", function()
            local message = ControlMessageCountMessage:New()
            assert.is_true(ZO_Object.IsInstanceOf(message, ControlMessageCountMessage))
            assert.equals(0, message:GetId())
        end)

        it("should be able to deserialize and cast from a buffer", function()
            local data = BinaryBuffer:New(16)
            data:WriteUInt(0xFFFF, 16)
            data:Rewind()

            local baseMessage = ControlMessageBase.Deserialize(data)
            assert.is_false(ZO_Object.IsInstanceOf(baseMessage, ControlMessageCountMessage))
            local message = ControlMessageCountMessage.CastFrom(baseMessage)
            assert.equals(baseMessage, message)
            assert.is_true(ZO_Object.IsInstanceOf(message, ControlMessageCountMessage))

            assert.equals(0xF, message:GetId())
            assert.equals(0xF, message:GetCount())
            assert.equals(9, data.cursor)
        end)

        it("should be able to set and get the correct count", function()
            local message = ControlMessageCountMessage:New()

            assert.equals(0, message:GetCount())

            message:SetCount(5)
            assert.equals(5, message:GetCount())

            message:SetCount(15)
            assert.equals(15, message:GetCount())
        end)
    end)
end)
