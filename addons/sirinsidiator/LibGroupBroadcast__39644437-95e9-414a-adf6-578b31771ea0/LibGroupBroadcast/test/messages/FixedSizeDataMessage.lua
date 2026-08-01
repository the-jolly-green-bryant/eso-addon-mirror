-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local BinaryBuffer = LGB.internal.class.BinaryBuffer
local FixedSizeDataMessage = LGB.internal.class.FixedSizeDataMessage

Taneth("LibGroupBroadcast", function()
    describe("FixedSizeDataMessage", function()
        it("should be able to create a new instance", function()
            local buffer = BinaryBuffer:New(1)
            local message = FixedSizeDataMessage:New(0, buffer)
            assert.is_true(ZO_Object.IsInstanceOf(message, FixedSizeDataMessage))
        end)

        it("should be deserialized and created from a buffer", function()
            local data = BinaryBuffer:New(32)
            data:WriteUInt(0xFFFFFFFF, 32)
            data:Rewind()

            local message = FixedSizeDataMessage.Deserialize(data)
            assert.is_true(ZO_Object.IsInstanceOf(message, FixedSizeDataMessage))

            assert.equals(511, message:GetId())
            assert.equals(2, message:GetSize())
            local messageData = message:GetData()
            assert.equals(0x7F, messageData:ReadUInt(7))
            assert.equals(17, data.cursor)
        end)

        it("should be serialized to a buffer", function()
            local data = BinaryBuffer:New(7)
            data:WriteUInt(0x7F, 7)
            data:Rewind()

            local message = FixedSizeDataMessage:New(511, data)
            local buffer = BinaryBuffer:New(32)
            buffer:Seek(8)

            message:Serialize(buffer)
            assert.equals("00 FF FF 00", buffer:ToHexString())
            assert.equals(25, buffer.cursor)
        end)

        it("should accept options for isRelevantInCombat and replaceQueuedMessages", function()
            local data = BinaryBuffer:New(1)
            local message = FixedSizeDataMessage:New(0, data, { isRelevantInCombat = true, replaceQueuedMessages = true })
            assert.is_true(message:IsRelevantInCombat())
            assert.is_true(message:ShouldDeleteQueuedMessages())
        end)
    end)
end)
