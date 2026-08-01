-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local Handler = LGB.internal.class.Handler
local logger = LGB.internal.logger

--[[ doc.lua begin ]] --

--- @class HandlerManager
--- @field New fun(self: HandlerManager, protocolManager: ProtocolManager): HandlerManager
local HandlerManager = ZO_InitializingObject:Subclass()
LGB.internal.class.HandlerManager = HandlerManager

function HandlerManager:Initialize(protocolManager)
    self.protocolManager = protocolManager
    self.data = {}
    self.dataByName = {}
    self.dataByHandler = {}
end

function HandlerManager:RegisterHandler(addonName, handlerName)
    assert(type(addonName) == "string" and addonName ~= "", "addonName must be a non-empty string.")
    assert(handlerName == nil or (type(handlerName) == "string" and handlerName ~= ""),
        "handlerName must be a non-empty string.")

    local handlerData
    if handlerName then
        assert(handlerName ~= addonName, "handlerName and addonName must not be the same.")
        handlerData = self.dataByName[handlerName]
        if handlerData then
            error("Handler name '" ..
                handlerName .. "' has already been registered by '" .. handlerData.addonName .. "'.")
        end
    end

    handlerData = self.dataByName[addonName]
    if handlerData then
        error("Addon '" .. addonName .. "' has already been registered as a handler.")
    end

    handlerData = {
        handlerName = handlerName,
        addonName = addonName,
        customEvents = {},
        protocols = {},
    }

    local handler = Handler:New({
        DeclareCustomEvent = function(_, ...)
            return self.protocolManager:DeclareCustomEvent(handlerData, ...)
        end,
        DeclareProtocol = function(_, ...)
            return self.protocolManager:DeclareProtocol(handlerData, ...)
        end,
        SetApi = function(_, api)
            handlerData.api = api
        end,
        SetDisplayName = function(_, displayName)
            handlerData.displayName = displayName
        end,
        SetDescription = function(_, description)
            handlerData.description = description
        end,
        SetUserSettings = function(_, settings)
            handlerData.settings = settings
        end,
        IsCustomEventEnabled = function(_, eventIdOrName)
            return self.protocolManager:IsCustomEventEnabled(eventIdOrName)
        end,
    })
    self.data[#self.data + 1] = handlerData
    if handlerName then
        self.dataByName[handlerName] = handlerData
    end
    self.dataByName[addonName] = handlerData
    self.dataByHandler[handler] = handlerData
    return handler
end

function HandlerManager:GetHandlerApi(handlerName)
    local handlerData = self.dataByName[handlerName]
    if handlerData then
        return handlerData.api
    end
end

function HandlerManager:GetHandlerData(handler)
    return self.dataByHandler[handler]
end

function HandlerManager:GetHandlers()
    return self.data
end