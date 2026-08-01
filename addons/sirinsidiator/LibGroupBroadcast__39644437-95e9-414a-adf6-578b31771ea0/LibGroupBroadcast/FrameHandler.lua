-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local CalculateCRC3ROHC = LGB.internal.CalculateCRC3ROHC
local BinaryBuffer = LGB.internal.class.BinaryBuffer
local ControlMessageBase = LGB.internal.class.ControlMessageBase
local ControlMessageCountMessage = LGB.internal.class.ControlMessageCountMessage
local FixedSizeDataMessage = LGB.internal.class.FixedSizeDataMessage
local FlexSizeDataMessage = LGB.internal.class.FlexSizeDataMessage
local logger = LGB.internal.logger

--- @class FrameHandler
--- @field New fun(self: FrameHandler): FrameHandler
local FrameHandler = ZO_InitializingObject:Subclass()
LGB.internal.class.FrameHandler = FrameHandler

local MAX_BROADCAST_MESSAGE_BYTES = 32
local MAX_CONTROL_MESSAGES_BASE_COUNT = 2 ^ 2 - 1
local MAX_CONTROL_MESSAGES_EXTRA_COUNT = 2 ^ 4 - 1
local HEADER_BYTES = 2
local FRAME_PROTOCOL_VERSION = 1
local CHECKSUM_PLACEHOLDER_VALUE = 2 ^ 3 - 1

function FrameHandler:Initialize()
    self.controlMessages = {}
    self.extraControlMessages = {}
    self.fixedMessages = {}
    self.flexMessages = {}
    self.unfinishedFlexMessages = {}
    self.data = BinaryBuffer:New(MAX_BROADCAST_MESSAGE_BYTES * 8)
    self.bytesFree = MAX_BROADCAST_MESSAGE_BYTES - HEADER_BYTES
end

function FrameHandler:Reset()
    ZO_ClearTable(self.controlMessages)
    ZO_ClearTable(self.extraControlMessages)
    ZO_ClearTable(self.fixedMessages)
    ZO_ClearTable(self.flexMessages)
    self.data:Clear()
    self.bytesFree = MAX_BROADCAST_MESSAGE_BYTES - HEADER_BYTES
end

function FrameHandler:ClearUnfinishedMessages()
    ZO_ClearTable(self.unfinishedFlexMessages)
end

function FrameHandler:GetBytesFree()
    return self.bytesFree
end

function FrameHandler:HasData()
    return #self.controlMessages > 0 or #self.fixedMessages > 0 or #self.flexMessages > 0
end

function FrameHandler:AddControlMessage(message)
    if self.bytesFree < 1 then return false end

    if #self.controlMessages < MAX_CONTROL_MESSAGES_BASE_COUNT then
        self.controlMessages[#self.controlMessages + 1] = message
    else
        local extraCount = #self.extraControlMessages
        if extraCount == 0 then
            if self.bytesFree < 2 then return false end
            extraCount = 1
            self.extraControlMessages[1] = ControlMessageCountMessage:New()
            self.bytesFree = self.bytesFree - 1
        elseif extraCount >= MAX_CONTROL_MESSAGES_EXTRA_COUNT then
            return false
        else
            self.extraControlMessages[1]:SetCount(extraCount)
        end
        self.extraControlMessages[extraCount + 1] = message
    end

    self.bytesFree = self.bytesFree - 1
    return true
end

function FrameHandler:AddDataMessage(message)
    if ZO_Object.IsInstanceOf(message, FixedSizeDataMessage) then
        return self:AddFixedSizeDataMessage(message)
    elseif ZO_Object.IsInstanceOf(message, FlexSizeDataMessage) then
        return self:AddFlexSizeDataMessage(message)
    end
    logger:Warn("Tried to add unsupported data message type")
    return false
end

function FrameHandler:AddFixedSizeDataMessage(message)
    if self.bytesFree < 2 then return false end

    self.fixedMessages[#self.fixedMessages + 1] = message

    self.bytesFree = self.bytesFree - 2
    return true
end

function FrameHandler:AddFlexSizeDataMessage(message)
    if self.bytesFree < 3 then return false end
    if message:IsFullySent() then return false end

    self.flexMessages[#self.flexMessages + 1] = message
    message:UpdateStatus(self.bytesFree)

    self.bytesFree = self.bytesFree - message:GetBytesToSend()
    return true
end

function FrameHandler:Serialize()
    self.data:Clear()
    self.data:WriteUInt(FRAME_PROTOCOL_VERSION, 3)
    self.data:WriteUInt(CHECKSUM_PLACEHOLDER_VALUE, 3)
    self.data:WriteUInt(#self.controlMessages, 2)
    self.data:WriteUInt(#self.fixedMessages, 4)
    self.data:WriteUInt(#self.flexMessages, 4)

    if #self.extraControlMessages > 0 then
        for _, message in ipairs(self.extraControlMessages) do
            message:Serialize(self.data)
        end
    end

    for _, message in ipairs(self.controlMessages) do
        message:Serialize(self.data)
    end

    for _, message in ipairs(self.fixedMessages) do
        message:Serialize(self.data)
    end

    for _, message in ipairs(self.flexMessages) do
        message:Serialize(self.data)
    end

    local checksum = CalculateCRC3ROHC(self.data)
    self.data:Rewind(4)
    self.data:WriteUInt(checksum, 3)

    return self.data
end

function FrameHandler:Deserialize(senderTag, buffer)
    local controlMessages = {}
    local dataMessages = {}

    buffer:Rewind()
    local version = buffer:ReadUInt(3)
    if version ~= FRAME_PROTOCOL_VERSION then
        logger:Warn("Received data with unsupported version %d", version)
        return controlMessages, dataMessages
    end

    local expectedChecksum = buffer:ReadUInt(3)
    buffer:Seek(-3)
    buffer:WriteUInt(CHECKSUM_PLACEHOLDER_VALUE, 3)
    local checksum = CalculateCRC3ROHC(buffer)
    if checksum ~= expectedChecksum then
        logger:Warn("Received data with invalid checksum")
        return controlMessages, dataMessages
    end

    buffer:Rewind(7)
    local controlMessageCount = buffer:ReadUInt(2)
    local fixedMessageCount = buffer:ReadUInt(4)
    local flexMessageCount = buffer:ReadUInt(4)

    local extraControlMessages = {}
    if controlMessageCount > 0 then
        local firstControlMessageId = buffer:ReadUInt(4)
        buffer:Seek(-4)
        if firstControlMessageId == 0 then
            local countMessage = ControlMessageCountMessage.CastFrom(ControlMessageCountMessage.Deserialize(buffer))
            for i = 1, countMessage:GetCount() do
                extraControlMessages[i] = ControlMessageBase.Deserialize(buffer)
            end
        end
    end

    for _ = 1, controlMessageCount do
        controlMessages[#controlMessages + 1] = ControlMessageBase.Deserialize(buffer)
    end

    if #extraControlMessages > 0 then
        for i = 1, #extraControlMessages do
            controlMessages[#controlMessages + 1] = extraControlMessages[i]
        end
    end

    for _ = 1, fixedMessageCount do
        dataMessages[#dataMessages + 1] = FixedSizeDataMessage.Deserialize(buffer)
    end

    local senderUnfinishedFlexMessagesById
    for _ = 1, flexMessageCount do
        local message = FlexSizeDataMessage.Deserialize(buffer)
        local id = message:GetId()
        if message:IsContinuation() then
            if not senderUnfinishedFlexMessagesById then
                senderUnfinishedFlexMessagesById = self:ResolveSenderUnfinishedFlexMessages(senderTag)
            end
            local unfinishedMessage = senderUnfinishedFlexMessagesById[id]
            if unfinishedMessage then
                if unfinishedMessage:CanAppendMessage(message) then
                    unfinishedMessage:AppendMessage(message)
                    if not unfinishedMessage:HasContinuation() then
                        unfinishedMessage:Finalize()
                        dataMessages[#dataMessages + 1] = unfinishedMessage
                        senderUnfinishedFlexMessagesById[id] = nil
                    end
                else
                    senderUnfinishedFlexMessagesById[id] = nil
                end
            end
        elseif message:HasContinuation() then
            if not senderUnfinishedFlexMessagesById then
                senderUnfinishedFlexMessagesById = self:ResolveSenderUnfinishedFlexMessages(senderTag)
            end
            senderUnfinishedFlexMessagesById[id] = message
        else
            dataMessages[#dataMessages + 1] = message
        end
    end

    return controlMessages, dataMessages
end

function FrameHandler:ResolveSenderUnfinishedFlexMessages(senderTag)
    local displayName = GetUnitDisplayName(senderTag)
    local senderKey = (displayName and displayName ~= "") and displayName or senderTag
    if not self.unfinishedFlexMessages[senderKey] then
        self.unfinishedFlexMessages[senderKey] = {}
    end
    return self.unfinishedFlexMessages[senderKey]
end
