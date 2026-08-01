-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast

--[[ doc.lua begin ]] --

--- @class CustomEventOptions
--- @field displayName string? A display name for use in various places.
--- @field description string? A description for use in various places.
--- @field userSettings UserSettings? Additional settings
--- @field isRelevantInCombat boolean? Whether the customEvent is relevant in combat.

--- @class Handler
--- @field private proxy table
--- @field protected New fun(self: Handler, proxy: table): Handler
local Handler = ZO_InitializingObject:Subclass()
LGB.internal.class.Handler = Handler

--- @protected
function Handler:Initialize(proxy)
    self.proxy = proxy
end

--- Sets the API object for the handler which is returned by LibGroupBroadcast's GetHandler function.
--- @param api table The API object to set.
--- @see LibGroupBroadcast.GetHandlerApi
function Handler:SetApi(api)
    self.proxy:SetApi(api)
end

--- Sets a display name for the handler for use in various places.
--- @param displayName string The display name to set.
function Handler:SetDisplayName(displayName)
    self.proxy:SetDisplayName(displayName)
end

--- Sets a description for the handler for use in various places.
--- @param description string The description to set.
function Handler:SetDescription(description)
    self.proxy:SetDescription(description)
end

--- Sets custom settings for the handler.
--- @param settings UserSettings An instance of UserSettings.
function Handler:SetUserSettings(settings)
    assert(ZO_Object.IsInstanceOf(settings, LGB.internal.class.UserSettings),
        "Settings must be an instance of UserSettings")
    self.proxy:SetUserSettings(settings)
end

--- Declares a custom event that can be used to send messages without data to other group members with minimal overhead or throws an error if the declaration failed.
---
--- Each event id and event name has to be globally unique between all addons. In order to coordinate which values are already in use,
--- every author is required to reserve them on the following page on the esoui wiki, before releasing their addon to the public:
--- https://wiki.esoui.com/LibGroupBroadcast_IDs
--- @param eventId number The custom event ID to use.
--- @param eventName string The custom event name to use.
--- @param options? CustomEventOptions Configuration for the custom event
--- @return function FireEvent A function that can be called to request sending this custom event to other group members.
--- @see CustomEventOptions
function Handler:DeclareCustomEvent(eventId, eventName, options)
    return self.proxy:DeclareCustomEvent(eventId, eventName, options)
end

--- Returns whether the user has enabled data transmission for this custom event in the settings.
---
--- You can check this before calling FireEvent, otherwise the library will show the blocked attempts in its own UI.
--- If you want to inform the user that your addon won't work due to the custom event being disabled,
--- you should only do so in a non-intrusive way (e.g. when they actively interact with features that require it).
---
--- **It is highly discouraged to show unsolicited notifications (e.g. chat messages or popups) about this.**
--- @param eventIdOrName number | string The id or name of the custom event to check.
--- @return boolean IsEnabled Whether the custom event is allowed to be sent.
function Handler:IsCustomEventEnabled(eventIdOrName)
    return self.proxy:IsCustomEventEnabled(eventIdOrName)
end

--- Declares a new protocol with the given ID and name and returns the Protocol object instance or throws an error if the declaration failed.
---
--- The protocol id and name have to be globally unique between all addons. In order to coordinate which values are already in use,
--- every author is required to reserve them on the following page on the esoui wiki, before releasing their addon to the public:
--- https://wiki.esoui.com/LibGroupBroadcast_IDs
--- @param protocolId number The ID of the protocol to declare.
--- @param protocolName string The name of the protocol to declare.
--- @return Protocol protocol The Protocol object instance that was declared.
--- @see Protocol
function Handler:DeclareProtocol(protocolId, protocolName)
    return self.proxy:DeclareProtocol(protocolId, protocolName)
end
