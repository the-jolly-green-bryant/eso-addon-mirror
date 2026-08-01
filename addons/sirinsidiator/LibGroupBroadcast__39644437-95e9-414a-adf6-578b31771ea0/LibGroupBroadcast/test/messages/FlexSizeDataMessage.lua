-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local BinaryBuffer = LGB.internal.class.BinaryBuffer
local FlexSizeDataMessage = LGB.internal.class.FlexSizeDataMessage

Taneth("LibGroupBroadcast", function()
    describe("FlexSizeDataMessage", function()
        it("should be able to create a new instance", function()
            local buffer = BinaryBuffer:New(1)
            local message = FlexSizeDataMessage:New(0, buffer)
            assert.is_true(ZO_Object.IsInstanceOf(message, FlexSizeDataMessage))
        end)

        it("should accept options for isRelevantInCombat and replaceQueuedMessages", function()
            local data = BinaryBuffer:New(1)
            local message = FlexSizeDataMessage:New(0, data, { isRelevantInCombat = true, replaceQueuedMessages = true })
            assert.is_true(message:IsRelevantInCombat())
            assert.is_true(message:ShouldDeleteQueuedMessages())
        end)

        it("should be deserialized and created from a buffer", function()
            local data = BinaryBuffer:New(64)
            data:WriteUInt(511, 9)
            data:WriteUInt(3, 5)
            data:WriteBit(true)
            data:WriteBit(true)
            data:WriteUInt(0xFFFFFFFF, 32)
            data:Rewind()

            local message = FlexSizeDataMessage.Deserialize(data)
            assert.is_true(ZO_Object.IsInstanceOf(message, FlexSizeDataMessage))

            assert.equals(511, message:GetId())
            assert.equals(6, message:GetSize())
            assert.is_true(message:IsContinuation())
            assert.is_true(message:HasContinuation())
            local messageData = message:GetData()
            assert.equals("FF FF FF FF", messageData:ToHexString())
            assert.equals(6 * 8 + 1, data.cursor)
        end)

        it("should calculate the number of bytes to send correctly when the available bytes are less than the maximum", function()
            local data = BinaryBuffer:New(8 * 100)
            local message = FlexSizeDataMessage:New(511, data)
            local bytesFree = 10
            message:UpdateStatus(bytesFree)
            assert.equals(bytesFree, message:GetBytesToSend())
        end)

        it("should calculate the correct size and continuation status based on data size", function()
            local data = BinaryBuffer:New(8)
            local message = FlexSizeDataMessage:New(511, data)
            assert.equals(3, message:GetSize())
            message:UpdateStatus(256)
            assert.equals(3, message:GetBytesToSend())
            assert.is_false(message:IsContinuation())
            assert.is_false(message:HasContinuation())
            assert.is_true(message:IsFullySent())

            data = BinaryBuffer:New(8 * 100)
            message = FlexSizeDataMessage:New(511, data)
            assert.equals(2 + 100, message:GetSize())

            message:UpdateStatus(256)
            assert.equals(2 + 28, message:GetBytesToSend())
            assert.equals(2 + 72, message:GetSize())
            assert.is_false(message:IsContinuation())
            assert.is_true(message:HasContinuation())
            assert.is_false(message:IsFullySent())

            message:UpdateStatus(256)
            assert.equals(2 + 28, message:GetBytesToSend())
            assert.equals(2 + 44, message:GetSize())
            assert.is_true(message:IsContinuation())
            assert.is_true(message:HasContinuation())
            assert.is_false(message:IsFullySent())

            message:UpdateStatus(256)
            assert.equals(2 + 28, message:GetBytesToSend())
            assert.equals(2 + 16, message:GetSize())
            assert.is_true(message:IsContinuation())
            assert.is_true(message:HasContinuation())
            assert.is_false(message:IsFullySent())

            message:UpdateStatus(256)
            assert.equals(2 + 16, message:GetBytesToSend())
            assert.equals(2 + 0, message:GetSize())
            assert.is_true(message:IsContinuation())
            assert.is_false(message:HasContinuation())
            assert.is_true(message:IsFullySent())
        end)

        it("should be serialized to a buffer", function()
            local data = BinaryBuffer:New(16)
            data:WriteUInt(0xFFFF, 16)

            local message = FlexSizeDataMessage:New(511, data)
            local buffer = BinaryBuffer:New(64)
            buffer:Seek(8)

            message:UpdateStatus(64)
            message:Serialize(buffer)
            assert.equals("00 FF 84 FF FF 00 00 00", buffer:ToHexString())
            assert.equals(8 + 8 * 4 + 1, buffer.cursor)
        end)

        it("should automatically align data to full bytes", function()
            local data = BinaryBuffer:New(13)
            data:WriteBit(1)
            data:WriteUInt(0xFF, 8)
            data:WriteUInt(0, 4)

            local message = FlexSizeDataMessage:New(1, data)
            local buffer = BinaryBuffer:New(64)
            buffer:Seek(8)

            message:UpdateStatus(64)
            message:Serialize(buffer)
            assert.equals("00 00 84 FF 80 00 00 00", buffer:ToHexString())
            assert.equals(8 + 8 * 4 + 1, buffer.cursor)
        end)

        it("should be able to split and recombine a long message", function()
            local data = BinaryBuffer:New(8 * 100)
            for i = 1, 100 do
                data:WriteUInt(i, 8)
            end

            local message = FlexSizeDataMessage:New(123, data)

            local MAX_BUFFER_SIZE = 30 * 8
            local buffers = {}
            while not message:IsFullySent() do
                local buffer = BinaryBuffer:New(MAX_BUFFER_SIZE)
                message:UpdateStatus(MAX_BUFFER_SIZE)
                message:Serialize(buffer)
                buffers[#buffers + 1] = buffer
            end

            assert.equals(4, #buffers)

            local combinedBuffer = BinaryBuffer:New(#buffers * MAX_BUFFER_SIZE)
            for _, buffer in ipairs(buffers) do
                buffer:Rewind()
                combinedBuffer:WriteBuffer(buffer)
            end

            combinedBuffer:Rewind()

            local recombinedMessage = FlexSizeDataMessage.Deserialize(combinedBuffer)
            while recombinedMessage:HasContinuation() do
                local continuation = FlexSizeDataMessage.Deserialize(combinedBuffer)
                assert.is_true(recombinedMessage:CanAppendMessage(continuation))
                recombinedMessage:AppendMessage(continuation)
            end

            recombinedMessage:Finalize()
            assert.equals(123, recombinedMessage:GetId())
            assert.equals(2 + 100, recombinedMessage:GetSize())
            local recombinedData = recombinedMessage:GetData()
            for i = 1, 100 do
                assert.equals(i, recombinedData:ReadUInt(8))
            end
        end)
    end)
end)
