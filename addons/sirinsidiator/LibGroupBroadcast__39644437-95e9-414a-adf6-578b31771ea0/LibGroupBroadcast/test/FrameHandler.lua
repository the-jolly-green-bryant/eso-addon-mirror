-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local BinaryBuffer = LGB.internal.class.BinaryBuffer
local FrameHandler = LGB.internal.class.FrameHandler
local ControlMessageBase = LGB.internal.class.ControlMessageBase
local CustomEventControlMessage = LGB.internal.class.CustomEventControlMessage
local FixedSizeDataMessage = LGB.internal.class.FixedSizeDataMessage
local FlexSizeDataMessage = LGB.internal.class.FlexSizeDataMessage

Taneth("LibGroupBroadcast", function()
    describe("FrameHandler", function()
        it("should be able to create a new instance", function()
            local handler = FrameHandler:New()
            assert.is_true(ZO_Object.IsInstanceOf(handler, FrameHandler))
        end)

        it("should be able to serialize and deserialize an empty message", function()
            local handler = FrameHandler:New()
            local serialized = handler:Serialize()
            assert.equals(
                "3C 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",
                serialized:ToHexString())
            local controlMessages, dataMessages = handler:Deserialize("group3", serialized)
            assert.equals(0, #controlMessages)
            assert.equals(0, #dataMessages)
        end)

        it("should be able to serialize control messages", function()
            local handler = FrameHandler:New()
            for i = 1, 20 do
                local message = CustomEventControlMessage:New(i % 16)
                message.data:WriteUInt((16 - i) % 16, 4)
                if i < 18 then
                    assert.is_true(handler:AddControlMessage(message))
                else
                    assert.is_false(handler:AddControlMessage(message))
                end
            end

            local serialized = handler:Serialize()

            local expected =
            "2B 00 0E 4C 5B 6A 79 88 97 A6 B5 C4 D3 E2 F1 00 1F 1F 2E 3D 00 00 00 00 00 00 00 00 00 00 00 00"
            assert.equals(expected, serialized:ToHexString())
        end)

        it("should be able to deserialize control messages", function()
            local input =
            "2B 00 0E 4C 5B 6A 79 88 97 A6 B5 C4 D3 E2 F1 00 1F 1F 2E 3D 00 00 00 00 00 00 00 00 00 00 00 00"
            local handler = FrameHandler:New()
            local serialized = BinaryBuffer.FromHexString(input)
            local controlMessages, dataMessages = handler:Deserialize("group3", serialized)
            assert.equals(17, #controlMessages)
            assert.equals(0, #dataMessages)
            for i = 1, 17 do
                assert.is_true(ZO_Object.IsInstanceOf(controlMessages[i], ControlMessageBase))
                assert.equals(i % 16, controlMessages[i].id)
                assert.equals((16 - i) % 16, controlMessages[i].data:ReadUInt(4))
            end
        end)

        it("should be able to serialize fixed size data messages", function()
            local handler = FrameHandler:New()
            for i = 1, 20 do
                local message = FixedSizeDataMessage:New(2 ^ 9 - i)
                message.data:WriteUInt(2 ^ 7 - i, 7)
                if i < 16 then
                    assert.is_true(handler:AddFixedSizeDataMessage(message))
                else
                    assert.is_false(handler:AddFixedSizeDataMessage(message))
                end
            end

            local serialized = handler:Serialize()

            local expected =
            "28 F0 FF FF FF 7E FE FD FE 7C FD FB FD 7A FC F9 FC 78 FB F7 FB 76 FA F5 FA 74 F9 F3 F9 72 F8 F1"
            assert.equals(expected, serialized:ToHexString())
        end)

        it("should be able to deserialize fixed size data messages", function()
            local input =
            "28 F0 FF FF FF 7E FE FD FE 7C FD FB FD 7A FC F9 FC 78 FB F7 FB 76 FA F5 FA 74 F9 F3 F9 72 F8 F1"
            local handler = FrameHandler:New()
            local serialized = BinaryBuffer.FromHexString(input)
            local controlMessages, dataMessages = handler:Deserialize("group3", serialized)
            assert.equals(0, #controlMessages)
            assert.equals(15, #dataMessages)
            for i = 1, 15 do
                assert.is_true(ZO_Object.IsInstanceOf(dataMessages[i], FixedSizeDataMessage))
                assert.equals(2 ^ 9 - i, dataMessages[i].id)
                assert.equals(2 ^ 7 - i, dataMessages[i].data:ReadUInt(7))
            end
        end)

        it("should be able to serialize short flex size data messages", function()
            local handler = FrameHandler:New()
            for i = 1, 20 do
                local data = BinaryBuffer:New(8)
                data:WriteUInt(2 ^ 8 - i, 8)
                local message = FlexSizeDataMessage:New(2 ^ 9 - i, data)
                if i < 11 then
                    assert.is_true(handler:AddFlexSizeDataMessage(message))
                else
                    assert.is_false(handler:AddFlexSizeDataMessage(message))
                end
            end

            local serialized = handler:Serialize()

            local expected =
            "20 0A FF 80 FF FF 00 FE FE 80 FD FE 00 FC FD 80 FB FD 00 FA FC 80 F9 FC 00 F8 FB 80 F7 FB 00 F6"
            assert.equals(expected, serialized:ToHexString())
        end)

        it("should be able to deserialize short flex data size messages", function()
            local input =
            "20 0A FF 80 FF FF 00 FE FE 80 FD FE 00 FC FD 80 FB FD 00 FA FC 80 F9 FC 00 F8 FB 80 F7 FB 00 F6"
            local handler = FrameHandler:New()
            local serialized = BinaryBuffer.FromHexString(input)
            local controlMessages, dataMessages = handler:Deserialize("group3", serialized)
            assert.equals(0, #controlMessages)
            assert.equals(10, #dataMessages)
            for i = 1, 10 do
                assert.is_true(ZO_Object.IsInstanceOf(dataMessages[i], FlexSizeDataMessage))
                assert.equals(2 ^ 9 - i, dataMessages[i].id)
                assert.equals(2 ^ 8 - i, dataMessages[i].data:ReadUInt(8))
            end
        end)

        it("should be able to serialize a long flex size data message", function()
            local handler = FrameHandler:New()
            local byteLength = 80
            local data = BinaryBuffer:New(byteLength * 8)
            for i = 1, byteLength do
                data:WriteUInt(i, 8)
            end
            data:Rewind()
            local message = FlexSizeDataMessage:New(511, data)
            assert.is_false(message.isContinued)
            assert.is_false(message.hasContinuation)

            assert.is_true(handler:AddFlexSizeDataMessage(message))
            assert.is_false(message.isContinued)
            assert.is_true(message.hasContinuation)
            local serialized1 = handler:Serialize()
            local expected =
            "38 01 FF ED 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14 15 16 17 18 19 1A 1B 1C"
            assert.equals(expected, serialized1:ToHexString())
            handler:Reset()

            assert.is_true(handler:AddFlexSizeDataMessage(message))
            assert.is_true(message.isContinued)
            assert.is_true(message.hasContinuation)
            local serialized2 = handler:Serialize()
            local expected =
            "30 01 FF EF 1D 1E 1F 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F 30 31 32 33 34 35 36 37 38"
            assert.equals(expected, serialized2:ToHexString())
            handler:Reset()

            assert.is_true(handler:AddFlexSizeDataMessage(message))
            assert.is_true(message.isContinued)
            assert.is_false(message.hasContinuation)
            local serialized3 = handler:Serialize()
            local expected =
            "38 01 FF DE 39 3A 3B 3C 3D 3E 3F 40 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F 50 00 00 00 00"
            assert.equals(expected, serialized3:ToHexString())
            handler:Reset()

            assert.is_false(handler:AddFlexSizeDataMessage(message))
        end)

        it("should be able to deserialize a long flex size data message", function()
            local input1 =
            "38 01 FF ED 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14 15 16 17 18 19 1A 1B 1C"
            local input2 =
            "30 01 FF EF 1D 1E 1F 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F 30 31 32 33 34 35 36 37 38"
            local input3 =
            "38 01 FF DE 39 3A 3B 3C 3D 3E 3F 40 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F 50 00 00 00 00"

            local handler = FrameHandler:New()

            local serialized1 = BinaryBuffer.FromHexString(input1)
            local controlMessages, dataMessages = handler:Deserialize("group3", serialized1)
            assert.equals(0, #controlMessages)
            assert.equals(0, #dataMessages)

            local serialized2 = BinaryBuffer.FromHexString(input2)
            controlMessages, dataMessages = handler:Deserialize("group3", serialized2)
            assert.equals(0, #controlMessages)
            assert.equals(0, #dataMessages)

            local serialized3 = BinaryBuffer.FromHexString(input3)
            controlMessages, dataMessages = handler:Deserialize("group3", serialized3)
            assert.equals(0, #controlMessages)
            assert.equals(1, #dataMessages)
            assert.is_true(ZO_Object.IsInstanceOf(dataMessages[1], FlexSizeDataMessage))
            assert.equals(511, dataMessages[1].id)
            for i = 1, 80 do
                assert.equals(i, dataMessages[1].data:ReadUInt(8))
            end
        end)
    end)
end)
