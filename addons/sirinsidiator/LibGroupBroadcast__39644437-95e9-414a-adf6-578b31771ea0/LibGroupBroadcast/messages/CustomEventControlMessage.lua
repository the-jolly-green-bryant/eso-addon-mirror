-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local ControlMessageBase = LGB.internal.class.ControlMessageBase

local CustomEventControlMessage = ControlMessageBase:Subclass()
LGB.internal.class.CustomEventControlMessage = CustomEventControlMessage

local CUSTOM_EVENT_MESSAGE_ID_START = 1
local CUSTOM_EVENT_MESSAGE_ID_RANGE = 10
local MIN_CUSTOM_EVENT_ID = 0
local MAX_CUSTOM_EVENT_ID = 39
local INVALID_CUSTOM_EVENT_ID_MESSAGE = string.format(
    "Custom event ID must be a number from %d to %d.",
    MIN_CUSTOM_EVENT_ID, MAX_CUSTOM_EVENT_ID)

function CustomEventControlMessage:SetEvent(eventId)
    self.data:Rewind(1 + eventId % 4)
    self.data:WriteBit(1)
end

function CustomEventControlMessage:GetEvents()
    local events = {}
    self.data:Rewind()
    for i = 1, self.data:GetNumBits() do
        if self.data:ReadBit(true) then
            events[#events + 1] = (self.id - CUSTOM_EVENT_MESSAGE_ID_START) * 4 + i - 1
        end
    end
    return events
end

function CustomEventControlMessage.CastFrom(message)
    return setmetatable(message, CustomEventControlMessage)
end

function CustomEventControlMessage.GetMessageIdFromEventId(eventId)
    return CUSTOM_EVENT_MESSAGE_ID_START + math.floor(eventId / 4)
end

function CustomEventControlMessage.IsValidMessageId(messageId)
    return messageId >= CUSTOM_EVENT_MESSAGE_ID_START and
        messageId < CUSTOM_EVENT_MESSAGE_ID_START + CUSTOM_EVENT_MESSAGE_ID_RANGE
end

function CustomEventControlMessage.AssertIsValidEventId(eventId)
    assert(type(eventId) == "number" and eventId >= MIN_CUSTOM_EVENT_ID and eventId <= MAX_CUSTOM_EVENT_ID,
        INVALID_CUSTOM_EVENT_ID_MESSAGE)
end
