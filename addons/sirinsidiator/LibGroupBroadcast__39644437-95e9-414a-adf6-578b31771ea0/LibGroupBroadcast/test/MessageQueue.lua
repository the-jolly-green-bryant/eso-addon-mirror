-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local BinaryBuffer = LGB.internal.class.BinaryBuffer
local MessageQueue = LGB.internal.class.MessageQueue
local FixedSizeDataMessage = LGB.internal.class.FixedSizeDataMessage
local FlexSizeDataMessage = LGB.internal.class.FlexSizeDataMessage

local function CreateMessageWithByteSize(id, byteSize, options)
    local buffer = BinaryBuffer:New((byteSize - 2) * 8)
    local message = FlexSizeDataMessage:New(id, buffer, options)
    return message
end

Taneth("LibGroupBroadcast", function()
    describe("MessageQueue", function()
        it("should be able to create a new instance", function()
            local queue = MessageQueue:New()
            assert.is_true(ZO_Object.IsInstanceOf(queue, MessageQueue))
        end)

        it("should be able to clear all messages", function()
            local queue = MessageQueue:New()
            for i = 1, 5 do
                local message = FixedSizeDataMessage:New(i)
                queue:EnqueueMessage(message)
            end

            assert.is_true(queue:HasRelevantMessages())
            queue:Clear()
            assert.is_false(queue:HasRelevantMessages())
        end)

        it("should be able to delete specific messages by id", function()
            local queue = MessageQueue:New()
            local expected = FixedSizeDataMessage:New(1)
            queue:EnqueueMessage(expected)

            assert.is_true(queue:HasRelevantMessages())
            queue:DeleteMessagesByProtocolId(1)
            assert.is_false(queue:HasRelevantMessages())
        end)

        it("should be able to return the oldest queued message", function()
            local queue = MessageQueue:New()
            local expected = FixedSizeDataMessage:New(1)
            queue:EnqueueMessage(expected)
            for i = 2, 5 do
                local message = FixedSizeDataMessage:New(i)
                queue:EnqueueMessage(message)
            end

            local actual = queue:GetOldestRelevantMessage()
            assert.equals(expected, actual)
        end)

        it("should be able to return the oldest queued combat relevant message", function()
            local queue = MessageQueue:New()
            for i = 1, 5 do
                local message = FixedSizeDataMessage:New(i, BinaryBuffer:New(7))
                queue:EnqueueMessage(message)
            end
            local expected = FixedSizeDataMessage:New(6, BinaryBuffer:New(7), { isRelevantInCombat = true })
            queue:EnqueueMessage(expected)
            for i = 7, 10 do
                local message = FixedSizeDataMessage:New(i, BinaryBuffer:New(7), { isRelevantInCombat = true })
                queue:EnqueueMessage(message)
            end

            local actual = queue:GetOldestRelevantMessage(true)
            assert.equals(expected, actual)
        end)

        it("should be able to return the oldest queued message when in combat with no queued combat relevant messages",
            function()
                local queue = MessageQueue:New()
                local expected = FixedSizeDataMessage:New(1)
                queue:EnqueueMessage(expected)
                for i = 2, 5 do
                    local message = FixedSizeDataMessage:New(i)
                    queue:EnqueueMessage(message)
                end

                local actual = queue:GetOldestRelevantMessage(true)
                assert.equals(expected, actual)
            end)

        it("should be able to return the smallest queued message",
            function()
                local queue = MessageQueue:New()
                for i = 1, 3 do
                    local message = CreateMessageWithByteSize(i, 4 + i)
                    queue:EnqueueMessage(message)
                end
                local expected = CreateMessageWithByteSize(4, 3)
                queue:EnqueueMessage(expected)
                for i = 5, 7 do
                    local message = CreateMessageWithByteSize(i, 4 + i)
                    queue:EnqueueMessage(message)
                end

                local actual = queue:GetNextRelevantEntry()
                assert.equals(expected, actual)
            end)

        it("should be able to return the smallest queued combat relevant message", function()
            local queue = MessageQueue:New()
            for i = 1, 3 do
                local message = CreateMessageWithByteSize(i, 4 + i, { isRelevantInCombat = true })
                queue:EnqueueMessage(message)
            end
            local message = CreateMessageWithByteSize(4, 3)
            queue:EnqueueMessage(message)
            local expected = CreateMessageWithByteSize(5, 3, { isRelevantInCombat = true })
            queue:EnqueueMessage(expected)
            for i = 6, 8 do
                local message = CreateMessageWithByteSize(i, 4 + i, { isRelevantInCombat = true })
                queue:EnqueueMessage(message)
            end

            local actual = queue:GetNextRelevantEntry(true)
            assert.equals(expected, actual)
        end)

        it("should be able to return the smallest queued message when in combat with no queued combat relevant messages",
            function()
                local queue = MessageQueue:New()
                for i = 1, 3 do
                    local message = CreateMessageWithByteSize(i, 4 + i)
                    queue:EnqueueMessage(message)
                end
                local expected = CreateMessageWithByteSize(4, 3)
                queue:EnqueueMessage(expected)
                for i = 5, 7 do
                    local message = CreateMessageWithByteSize(i, 4 + i)
                    queue:EnqueueMessage(message)
                end

                local actual = queue:GetNextRelevantEntry(true)
                assert.equals(expected, actual)
            end)

        it("should be able to return the oldest and smallest queued message",
            function()
                local queue = MessageQueue:New()
                local expected = CreateMessageWithByteSize(1, 3)
                queue:EnqueueMessage(expected)
                for i = 2, 4 do
                    local message = CreateMessageWithByteSize(i, 2 + i)
                    queue:EnqueueMessage(message)
                end
                local message = CreateMessageWithByteSize(4, 3)
                queue:EnqueueMessage(message)
                for i = 6, 8 do
                    local message = CreateMessageWithByteSize(i, 2 + i)
                    queue:EnqueueMessage(message)
                end

                local actual = queue:GetNextRelevantEntry(true)
                assert.equals(expected, actual)
            end)

        it("should be able to return the oldest queued message with the exact size",
            function()
                local queue = MessageQueue:New()
                for i = 1, 3 do
                    local message = CreateMessageWithByteSize(i, 2 + i)
                    message:UpdateStatus(100)
                    queue:EnqueueMessage(message)
                end
                local expected = CreateMessageWithByteSize(4, 3)
                queue:EnqueueMessage(expected)
                for i = 5, 7 do
                    local message = CreateMessageWithByteSize(i, 2 + i)
                    queue:EnqueueMessage(message)
                end

                local actual = queue:GetNextRelevantEntryWithExactSize(3)
                assert.equals(expected, actual)
            end)

        it("should be able to return the oldest queued combat relevant message with the exact size",
            function()
                local queue = MessageQueue:New()
                local expected = CreateMessageWithByteSize(1, 3, { isRelevantInCombat = true })
                queue:EnqueueMessage(expected)
                for i = 2, 5 do
                    local message = CreateMessageWithByteSize(i, 3, { isRelevantInCombat = true })
                    queue:EnqueueMessage(message)
                end
                for i = 6, 10 do
                    local message = CreateMessageWithByteSize(i, 3)
                    queue:EnqueueMessage(message)
                end

                local actual = queue:GetNextRelevantEntryWithExactSize(3, true)
                assert.equals(expected, actual)
            end)

        it("should return no message when there are no messages with the exact size",
            function()
                local queue = MessageQueue:New()
                for i = 1, 5 do
                    local message = FixedSizeDataMessage:New(i)
                    queue:EnqueueMessage(message)
                end

                local actual = queue:GetNextRelevantEntryWithExactSize(1)
                assert.is_nil(actual)
            end)
    end)
end)
