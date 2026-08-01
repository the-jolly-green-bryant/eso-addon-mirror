-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local ProtocolManager = LGB.internal.class.ProtocolManager
local Protocol = LGB.internal.class.Protocol
local FlagField = LGB.internal.class.FlagField
local NumericField = LGB.internal.class.NumericField
local OptionalField = LGB.internal.class.OptionalField
local FixedSizeDataMessage = LGB.internal.class.FixedSizeDataMessage
local FlexSizeDataMessage = LGB.internal.class.FlexSizeDataMessage

local function CreateProtocolManager(createWithoutSaveData)
    local internal = LGB.SetupMockInstance(createWithoutSaveData)
    local handler = internal.handlerManager:RegisterHandler("test")
    return internal.protocolManager, handler, internal
end

Taneth("LibGroupBroadcast", function()
    describe("ProtocolManager", function()
        it("should be able to create a new instance", function()
            local manager = CreateProtocolManager()
            assert.is_true(ZO_Object.IsInstanceOf(manager, ProtocolManager))
        end)

        it("should be able to declare multiple different custom events", function()
            local _, handler = CreateProtocolManager()
            local fireEvent1 = handler:DeclareCustomEvent(0, "test1")
            local fireEvent2 = handler:DeclareCustomEvent(1, "test2")
            assert.equals(type(fireEvent1), "function")
            assert.equals(type(fireEvent2), "function")
        end)

        it("should not be able to declare the same custom event twice", function()
            local _, handler = CreateProtocolManager()
            local fireEvent1 = assert.has_no_error(function() return handler:DeclareCustomEvent(0, "test1") end)
            assert.equals(type(fireEvent1), "function")
            assert.has_error("Custom event with ID 0 already exists with name 'test1'.",
                function() return handler:DeclareCustomEvent(0, "test2") end)
            assert.has_error("Custom event with name 'test1' already exists for ID 0.",
                function() return handler:DeclareCustomEvent(1, "test1") end)
        end)

        it("should be able to generate and handle custom events", function()
            local manager, handler = CreateProtocolManager()
            local fireEvent1 = handler:DeclareCustomEvent(0, "test1")
            local fireEvent2 = handler:DeclareCustomEvent(1, "test2")
            local fireEvent3 = handler:DeclareCustomEvent(39, "test3")

            local triggered = 0
            manager.callbackManager:RegisterCallback("RequestSendData", function()
                triggered = triggered + 1
            end)

            fireEvent1()
            fireEvent2()
            fireEvent3()
            assert.equals(3, triggered)

            local messages = manager:GenerateCustomEventMessages()
            assert.equals(2, #messages)
            assert.equals(1, messages[1]:GetId())
            local events1 = messages[1]:GetEvents()
            assert.equals(2, #events1)
            assert.equals(0, events1[1])
            assert.equals(1, events1[2])

            assert.equals(10, messages[2]:GetId())
            local events2 = messages[2]:GetEvents()
            assert.equals(1, #events2)
            assert.equals(39, events2[1])

            local receivedUnitTag1, receivedUnitTag2, receivedUnitTag3
            assert.is_true(manager:RegisterForCustomEvent("test1", function(unitTag)
                receivedUnitTag1 = unitTag
            end))
            assert.is_true(manager:RegisterForCustomEvent("test2", function(unitTag)
                receivedUnitTag2 = unitTag
            end))
            assert.is_true(manager:RegisterForCustomEvent("test3", function(unitTag)
                receivedUnitTag3 = unitTag
            end))
            local unhandledMessages = manager:HandleCustomEventMessages("group1", messages)
            assert.equals(0, #unhandledMessages)
            assert.equals("group1", receivedUnitTag1)
            assert.equals("group1", receivedUnitTag2)
            assert.equals("group1", receivedUnitTag3)
        end)

        it("should be able to declare multiple different data protocols", function()
            local _, handler = CreateProtocolManager()
            local protocol1 = handler:DeclareProtocol(0, "test1")
            local protocol2 = handler:DeclareProtocol(1, "test2")
            assert.is_true(ZO_Object.IsInstanceOf(protocol1, Protocol))
            assert.is_true(ZO_Object.IsInstanceOf(protocol2, Protocol))
        end)

        it("should not be able to declare the same data protocol twice", function()
            local _, handler = CreateProtocolManager()
            local protocol1 = assert.has_no_error(function() return handler:DeclareProtocol(0, "test1") end)
            assert.is_true(ZO_Object.IsInstanceOf(protocol1, Protocol))
            assert.has_error("Protocol with ID 0 already exists with name 'test1'.",
                function() return handler:DeclareProtocol(0, "test2") end)
            assert.has_error("Protocol with name 'test1' already exists for ID 0.",
                function() return handler:DeclareProtocol(1, "test1") end)
        end)

        it("should be able to generate and handle data messages", function()
            local manager, handler = CreateProtocolManager()

            local triggered = 0
            manager.callbackManager:RegisterCallback("RequestSendData", function()
                triggered = triggered + 1
            end)

            local protocol1IncomingUnitTag, protocol1IncomingData
            local protocol2IncomingUnitTag, protocol2IncomingData

            local protocol1 = handler:DeclareProtocol(0, "test1")
            protocol1:AddField(FlagField:New("flagA"))
            protocol1:AddField(FlagField:New("flagB"))
            protocol1:OnData(function(unitTag, data)
                protocol1IncomingUnitTag = unitTag
                protocol1IncomingData = data
            end)
            assert.is_true(protocol1:Finalize())

            local protocol2 = handler:DeclareProtocol(1, "test2")
            protocol2:AddField(FlagField:New("flagC"))
            protocol2:AddField(NumericField:New("number"))
            protocol2:OnData(function(unitTag, data)
                protocol2IncomingUnitTag = unitTag
                protocol2IncomingData = data
            end)
            assert.is_true(protocol2:Finalize())

            assert.is_true(protocol1:Send({ flagA = true, flagB = false }))
            assert.equals(1, triggered)
            local message1 = manager.dataMessageQueue:DequeueMessage()
            assert.is_true(ZO_Object.IsInstanceOf(message1, FixedSizeDataMessage))
            message1.data:Rewind()

            assert.is_true(protocol2:Send({ flagC = true, number = 1 }))
            assert.equals(2, triggered)
            local message2 = manager.dataMessageQueue:DequeueMessage()
            assert.is_true(ZO_Object.IsInstanceOf(message2, FlexSizeDataMessage))
            message2.data:Rewind()

            manager:HandleDataMessages("group1", { message1 })
            assert.equals("group1", protocol1IncomingUnitTag)
            assert.equals(true, protocol1IncomingData.flagA)
            assert.equals(false, protocol1IncomingData.flagB)

            manager:HandleDataMessages("group2", { message2 })
            assert.equals("group2", protocol2IncomingUnitTag)
            assert.equals(true, protocol2IncomingData.flagC)
            assert.equals(1, protocol2IncomingData.number)
        end)

        it("should dynamically choose the correct message type for the amount of data", function()
            local manager, handler = CreateProtocolManager()

            local protocol = handler:DeclareProtocol(0, "test")
            protocol:AddField(NumericField:New("numberA", { numBits = 6 }))
            protocol:AddField(OptionalField:New(NumericField:New("numberB")))
            protocol:OnData(function() end)
            assert.is_true(protocol:Finalize())

            assert.is_true(protocol:Send({ numberA = 1 }))
            local message1 = manager.dataMessageQueue:DequeueMessage()
            assert.is_true(ZO_Object.IsInstanceOf(message1, FixedSizeDataMessage))

            assert.is_true(protocol:Send({ numberA = 2, numberB = 3 }))
            local message2 = manager.dataMessageQueue:DequeueMessage()
            assert.is_true(ZO_Object.IsInstanceOf(message2, FlexSizeDataMessage))
        end)

        it("should clear all messages and custom events", function()
            local manager, handler = CreateProtocolManager()

            local protocol = handler:DeclareProtocol(0, "test")
            protocol:AddField(NumericField:New("numberA", { numBits = 6 }))
            protocol:AddField(OptionalField:New(NumericField:New("numberB")))
            protocol:OnData(function() end)
            assert.is_true(protocol:Finalize())

            local fireEvent = handler:DeclareCustomEvent(0, "test")
            assert.is_not_nil(fireEvent)

            fireEvent()
            assert.is_true(protocol:Send({ numberA = 1 }))

            assert.is_true(manager:HasRelevantMessages())
            manager:ClearQueuedMessages()
            assert.is_false(manager:HasRelevantMessages())
        end)

        it("should ignore events or messages when save data was not loaded yet", function()
            local manager, handler, internal = CreateProtocolManager(true)

            local protocol = handler:DeclareProtocol(0, "test")
            protocol:AddField(NumericField:New("numberA", { numBits = 6 }))
            protocol:AddField(OptionalField:New(NumericField:New("numberB")))
            protocol:OnData(function() end)
            assert.is_true(protocol:Finalize())

            local fireEvent = handler:DeclareCustomEvent(0, "test")
            assert.is_not_nil(fireEvent)

            fireEvent()
            assert.is_true(manager.pendingCustomEvents[0])
            assert.is_false(manager:HasRelevantMessages())

            assert.is_true(protocol:Send({ numberA = 1 }))
            assert.is_true(internal.dataMessageQueue:HasRelevantMessages())
            assert.is_false(manager:HasRelevantMessages())
        end)

        it("should allow to disable specific protocols and custom events", function()
            local manager, handler, internal = CreateProtocolManager()
            assert.is_not_nil(internal.saveData)

            local protocol = handler:DeclareProtocol(0, "test")
            protocol:AddField(NumericField:New("numberA", { numBits = 6 }))
            protocol:AddField(OptionalField:New(NumericField:New("numberB")))
            protocol:OnData(function() end)
            assert.is_true(protocol:Finalize())

            local fireEvent = handler:DeclareCustomEvent(0, "test")
            assert.is_not_nil(fireEvent)

            assert.is_true(manager:IsCustomEventEnabled(0))
            fireEvent()
            assert.is_true(manager.pendingCustomEvents[0])
            assert.is_true(manager:HasRelevantMessages())

            manager:SetCustomEventEnabled(0, false)
            assert.is_false(manager:IsCustomEventEnabled(0))

            manager:RemoveDisabledMessages()
            assert.is_false(manager:HasRelevantMessages())

            assert.is_true(manager:IsProtocolEnabled(0))
            assert.is_true(protocol:Send({ numberA = 1 }))
            assert.is_true(internal.dataMessageQueue:HasRelevantMessages())
            assert.is_true(manager:HasRelevantMessages())

            manager:SetProtocolEnabled(0, false)
            assert.is_false(manager:IsProtocolEnabled(0))

            manager:RemoveDisabledMessages()
            assert.is_false(manager:HasRelevantMessages())
        end)
    end)
end)
