-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local BinaryBuffer = LGB.internal.class.BinaryBuffer
local ControlMessageBase = LGB.internal.class.ControlMessageBase
local CustomEventControlMessage = LGB.internal.class.CustomEventControlMessage

Taneth("LibGroupBroadcast", function()
    describe("CustomEventControlMessage", function()
        it("should be able to create a new instance", function()
            local message = CustomEventControlMessage:New(0)
            assert.is_true(ZO_Object.IsInstanceOf(message, CustomEventControlMessage))
            assert.equals(0, message:GetId())
        end)

        it("should be able to deserialize and cast from a buffer", function()
            local data = BinaryBuffer:New(16)
            data:WriteUInt(0xAFFF, 16)
            data:Rewind()

            local baseMessage = ControlMessageBase.Deserialize(data)
            assert.is_false(ZO_Object.IsInstanceOf(baseMessage, CustomEventControlMessage))
            local message = CustomEventControlMessage.CastFrom(baseMessage)
            assert.equals(baseMessage, message)
            assert.is_true(ZO_Object.IsInstanceOf(message, CustomEventControlMessage))

            assert.equals(10, message:GetId())
            assert.same({ 36, 37, 38, 39 }, message:GetEvents())
            assert.equals(9, data.cursor)
        end)

        it("should return the correct message id for an event id", function()
            assert.equals(1, CustomEventControlMessage.GetMessageIdFromEventId(0))
            assert.equals(1, CustomEventControlMessage.GetMessageIdFromEventId(1))
            assert.equals(1, CustomEventControlMessage.GetMessageIdFromEventId(3))
            assert.equals(2, CustomEventControlMessage.GetMessageIdFromEventId(4))
            assert.equals(10, CustomEventControlMessage.GetMessageIdFromEventId(39))
        end)

        it("should properly validate message ids", function()
            assert.is_false(CustomEventControlMessage.IsValidMessageId(0))
            assert.is_true(CustomEventControlMessage.IsValidMessageId(1))
            assert.is_true(CustomEventControlMessage.IsValidMessageId(10))
            assert.is_false(CustomEventControlMessage.IsValidMessageId(11))
        end)

        it("should properly validate event ids", function()
            local expectedError = "Custom event ID must be a number from 0 to 39."
            assert.has_error(expectedError, function() return CustomEventControlMessage.AssertIsValidEventId(false) end)
            assert.has_error(expectedError, function() return CustomEventControlMessage.AssertIsValidEventId(-1) end)
            assert.has_no_error(function() return CustomEventControlMessage.AssertIsValidEventId(0) end)
            assert.has_no_error(function() return CustomEventControlMessage.AssertIsValidEventId(39) end)
            assert.has_error(expectedError, function() return CustomEventControlMessage.AssertIsValidEventId(40) end)
        end)

        it("should be able to set and get an event", function()
            local eventId = 1
            local messageId = CustomEventControlMessage.GetMessageIdFromEventId(eventId)
            local message = CustomEventControlMessage:New(messageId)

            local events1 = message:GetEvents()
            assert.equals(0, #events1)

            message:SetEvent(eventId)
            local events2 = message:GetEvents()
            assert.equals(1, #events2)
            assert.equals(eventId, events2[1])
        end)

        it("should be able to set and get multiple events", function()
            local eventId1 = 5
            local eventId2 = 7
            local messageId = CustomEventControlMessage.GetMessageIdFromEventId(eventId1)
            local messageId2 = CustomEventControlMessage.GetMessageIdFromEventId(eventId2)
            assert.equals(messageId, messageId2)
            local message = CustomEventControlMessage:New(messageId)

            local events1 = message:GetEvents()
            assert.equals(0, #events1)

            message:SetEvent(eventId1)
            message:SetEvent(eventId2)
            local events2 = message:GetEvents()
            assert.equals(2, #events2)
            assert.equals(eventId1, events2[1])
            assert.equals(eventId2, events2[2])
        end)
    end)
end)
