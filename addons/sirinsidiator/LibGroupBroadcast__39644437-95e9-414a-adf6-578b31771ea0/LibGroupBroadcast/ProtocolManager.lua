-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local logger = LGB.internal.logger
local CustomEventControlMessage = LGB.internal.class.CustomEventControlMessage
local Protocol = LGB.internal.class.Protocol

local CUSTOM_EVENT_CALLBACK_PREFIX = "OnCustomEvent_"

--- @class ProtocolManagerProxy
--- @field IsGrouped fun(self: ProtocolManagerProxy): boolean
--- @field QueueDataMessage fun(self: ProtocolManagerProxy, message: FixedSizeDataMessage | FlexSizeDataMessage)
--- @field IsProtocolEnabled fun(self: ProtocolManagerProxy, protocolId: number): boolean

--[[ doc.lua begin ]] --

--- @class ProtocolManager
--- @field New fun(self: ProtocolManager, gameApiWrapper: GameApiWrapper, callbackManager: ZO_CallbackObject, dataMessageQueue: MessageQueue): ProtocolManager
local ProtocolManager = ZO_InitializingObject:Subclass()
LGB.internal.class.ProtocolManager = ProtocolManager

--- @private
--- @param gameApiWrapper GameApiWrapper
--- @param callbackManager ZO_CallbackObject
--- @param dataMessageQueue MessageQueue
function ProtocolManager:Initialize(gameApiWrapper, callbackManager, dataMessageQueue)
    self.callbackManager = callbackManager
    self.dataMessageQueue = dataMessageQueue
    self.customEvents = {}
    self.customEventOptions = {}
    self.pendingCustomEvents = {}
    self.protocols = {}
    self.proxy = {
        IsGrouped = function() return gameApiWrapper:IsGrouped() end,
        IsProtocolEnabled = function(_, protocolId) return self:IsProtocolEnabled(protocolId) end,
        QueueDataMessage = function(_, message) self:QueueDataMessage(message) end,
    }
end

function ProtocolManager:SetSaveData(saveData)
    self.saveData = saveData
    self.customEventDisabled = saveData:GetCustomEventDisabled()
    self.protocolDisabled = saveData:GetProtocolDisabled()
end

function ProtocolManager:IsCustomEventEnabled(eventIdOrName)
    if not self.customEventDisabled then return false end
    if type(eventIdOrName) == "string" then
        eventIdOrName = self.customEvents[eventIdOrName]
    end
    return self.customEventDisabled[eventIdOrName] ~= true
end

function ProtocolManager:SetCustomEventEnabled(eventId, enabled)
    if not self.customEventDisabled then return end
    if enabled then
        self.customEventDisabled[eventId] = nil
    else
        self.customEventDisabled[eventId] = true
    end
end

function ProtocolManager:IsProtocolEnabled(protocolId)
    if not self.protocolDisabled then return false end
    return self.protocolDisabled[protocolId] ~= true
end

function ProtocolManager:SetProtocolEnabled(protocolId, enabled)
    if not self.protocolDisabled then return end
    if enabled then
        self.protocolDisabled[protocolId] = nil
    else
        self.protocolDisabled[protocolId] = true
    end
end

function ProtocolManager:ClearQueuedMessages(reason)
    self.dataMessageQueue:Clear(reason)
    ZO_ClearTable(self.pendingCustomEvents)
end

function ProtocolManager:DeclareCustomEvent(handlerData, eventId, eventName, options)
    CustomEventControlMessage.AssertIsValidEventId(eventId)
    assert(type(eventName) == "string" and eventName ~= "", "eventName must be a non-empty string.")

    local customEvents = self.customEvents
    if customEvents[eventId] then
        error(string.format("Custom event with ID %d already exists with name '%s'.", eventId, customEvents[eventId]))
    end
    if customEvents[eventName] then
        error(string.format("Custom event with name '%s' already exists for ID %d.", eventName, customEvents[eventName]))
    end

    customEvents[eventId] = eventName
    customEvents[eventName] = eventId
    options = options or {}
    self.customEventOptions[eventId] = options
    assert(type(self.customEventOptions[eventId]) == "table", "options must be a table.")

    handlerData.customEvents[#handlerData.customEvents + 1] = { eventId, eventName, options.displayName, options
        .userSettings }
    return function()
        self.pendingCustomEvents[eventId] = true
        self.callbackManager:FireCallbacks("RequestSendData")
    end
end

function ProtocolManager:RemoveDisabledMessages()
    if not self.saveData then return end

    for eventId, disabled in pairs(self.customEventDisabled) do
        if disabled then
            self.pendingCustomEvents[eventId] = nil
        end
    end

    for protocolId, disabled in pairs(self.protocolDisabled) do
        if disabled then
            self.dataMessageQueue:DeleteMessagesByProtocolId(protocolId, "disabled")
        end
    end
end

function ProtocolManager:GetCustomEventCallbackName(eventName)
    assert(type(eventName) == "string", "eventName must be a string.")
    local eventId = self.customEvents[eventName]
    if eventId then
        return CUSTOM_EVENT_CALLBACK_PREFIX .. eventId
    end
end

function ProtocolManager:RegisterForCustomEvent(eventName, callback)
    local callbackName = self:GetCustomEventCallbackName(eventName)
    if callbackName then
        self.callbackManager:RegisterCallback(callbackName, callback)
        return true
    end
    return false
end

function ProtocolManager:UnregisterForCustomEvent(eventName, callback)
    local callbackName = self:GetCustomEventCallbackName(eventName)
    if callbackName then
        self.callbackManager:UnregisterCallback(callbackName, callback)
        return true
    end
    return false
end

function ProtocolManager:GenerateCustomEventMessages()
    local messagesById = {}
    for eventId in pairs(self.pendingCustomEvents) do
        local messageId = CustomEventControlMessage.GetMessageIdFromEventId(eventId)
        local message = messagesById[messageId]
        if not message then
            message = CustomEventControlMessage:New(messageId)
            messagesById[messageId] = message
        end
        message:SetEvent(eventId)
        self.pendingCustomEvents[eventId] = nil
    end

    local messages = {}
    for _, message in pairs(messagesById) do
        messages[#messages + 1] = message
    end
    return messages
end

function ProtocolManager:HandleCustomEventMessages(unitTag, messages)
    local unhandledMessages = {}
    for _, message in ipairs(messages) do
        local messageId = message:GetId()
        if CustomEventControlMessage.IsValidMessageId(messageId) then
            local eventMessage = CustomEventControlMessage.CastFrom(message)
            local events = eventMessage:GetEvents()
            for i = 1, #events do
                self.callbackManager:FireCallbacks(CUSTOM_EVENT_CALLBACK_PREFIX .. events[i], unitTag)
            end
        else
            unhandledMessages[#unhandledMessages + 1] = message
        end
    end
    return unhandledMessages
end

function ProtocolManager:DeclareProtocol(handlerData, protocolId, protocolName)
    assert(type(protocolId) == "number", "protocolId must be a number.")
    assert(type(protocolName) == "string", "protocolName must be a string.")

    local protocols = self.protocols
    if protocols[protocolId] then
        error(string.format("Protocol with ID %d already exists with name '%s'.", protocolId,
            protocols[protocolId]:GetName()))
    end
    if protocols[protocolName] then
        error(string.format("Protocol with name '%s' already exists for ID %d.", protocolName,
            protocols[protocolName]:GetId()))
    end

    local protocol = Protocol:New(protocolId, protocolName, self.proxy)
    protocols[protocolId] = protocol
    protocols[protocolName] = protocol
    handlerData.protocols[#handlerData.protocols + 1] = protocol
    return protocol
end

function ProtocolManager:QueueDataMessage(message)
    self.dataMessageQueue:EnqueueMessage(message)
    self.callbackManager:FireCallbacks("RequestSendData")
end

function ProtocolManager:HasRelevantMessages(inCombat)
    if not self.saveData then return false end

    for eventId in pairs(self.pendingCustomEvents) do
        if not inCombat then
            return true
        else
            local options = self.customEventOptions[eventId]
            if options.isRelevantInCombat then
                return true
            end
        end
    end

    return self.dataMessageQueue:HasRelevantMessages(inCombat)
end

function ProtocolManager:HandleDataMessages(unitTag, messages)
    local unknownIds = {}
    local unknownCount = 0
    for _, message in ipairs(messages) do
        local protocol = self.protocols[message:GetId()]
        if not protocol then
            unknownIds[message:GetId()] = true
            unknownCount = unknownCount + 1
        elseif not protocol:IsFinalized() then
            logger:Warn("Received data message for protocol '%s', which has not been finalized", protocol:GetName())
        else
            protocol:Receive(unitTag, message)
        end
    end

    if unknownCount > 0 then
        local ids = {}
        for id in pairs(unknownIds) do
            ids[#ids + 1] = id
        end
        logger:Debug("Received %d data messages with unknown protocol IDs (%s) from %s", unknownCount,
            table.concat(ids, ", "), unitTag)
    end
end
