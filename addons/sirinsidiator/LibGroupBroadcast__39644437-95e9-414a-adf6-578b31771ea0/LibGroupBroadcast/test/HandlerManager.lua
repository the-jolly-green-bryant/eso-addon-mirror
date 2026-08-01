-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local HandlerManager = LGB.internal.class.HandlerManager
local Handler = LGB.internal.class.Handler

Taneth("LibGroupBroadcast", function()
    describe("HandlerManager", function()
        it("should be able to create a new instance", function()
            local manager = HandlerManager:New()
            assert.is_true(ZO_Object.IsInstanceOf(manager, HandlerManager))
        end)

        it("should be able to register a private handler", function()
            local manager = HandlerManager:New()
            local handler = manager:RegisterHandler("test1")
            assert.is_true(ZO_Object.IsInstanceOf(handler, Handler))
            assert.is_nil(manager:GetHandlerApi("test1"))
        end)

        it("should be able to register and get a handler table by addon and handler name", function()
            local manager = HandlerManager:New()
            local handlerApi = {}
            local handler = manager:RegisterHandler("test1", "test2")
            assert.is_true(ZO_Object.IsInstanceOf(handler, Handler))
            handler:SetApi(handlerApi)
            assert.equals(handlerApi, manager:GetHandlerApi("test1"))
            assert.equals(handlerApi, manager:GetHandlerApi("test2"))
        end)

        it("should not be possible to register an addon or handler name more than once", function()
            local manager = HandlerManager:New()
            local handlerApi1 = {}
            local handler1 = manager:RegisterHandler("test1", "test2")
            assert.is_true(ZO_Object.IsInstanceOf(handler1, Handler))
            handler1:SetApi(handlerApi1)

            local handlerApi2 = {}
            assert.has_error("Addon 'test1' has already been registered as a handler.", function() return manager:RegisterHandler("test1", "test3") end)

            local handler3 = manager:RegisterHandler("test4", "test3")
            assert.is_true(ZO_Object.IsInstanceOf(handler3, Handler))
            handler3:SetApi(handlerApi2)

            assert.equals(handlerApi1, manager:GetHandlerApi("test1"))
            assert.equals(handlerApi1, manager:GetHandlerApi("test2"))
            assert.equals(handlerApi2, manager:GetHandlerApi("test3"))
            assert.equals(handlerApi2, manager:GetHandlerApi("test4"))
        end)

        it("should be possible to set a display name and description for a handler", function()
            local manager = HandlerManager:New()
            local handler = manager:RegisterHandler("test1", "test2")
            local displayName = "Test Handler"
            local description = "This is a test handler."
            handler:SetDisplayName(displayName)
            handler:SetDescription(description)

            local handlerData = manager:GetHandlerData(handler)
            assert.equals(displayName, handlerData.displayName)
            assert.equals(description, handlerData.description)
        end)
    end)
end)
