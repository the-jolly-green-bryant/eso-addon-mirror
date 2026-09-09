local TT = TamrielicTongues

TT.ChatOutput = {
    eventName = TT.ADDON_NAME .. "_IncomingChat",
}

function TT.ChatOutput:OnChatMessage(channelType, fromName, text, isCustomerService, fromDisplayName)
    if isCustomerService or not TT.saved then
        return
    end

    local profile, body = TT.MessageDetector:Detect(text)
    if not profile then return end
    local state = TT.Proficiency:GetState(profile.id)
    if not state then return end

    local document = TT.Analysis:FromEncoded(profile, body)
    local rendered, stats = TT.Comprehension:Render(document, TT.Knowledge:Snapshot(state))
    local hasSender = type(fromDisplayName) == "string" and fromDisplayName ~= ""
    local award = TT.Progression:Observe(state, document, {
        now = GetTimeStamp(),
        eligible = hasSender and self:IsExposureChannel(channelType),
        isSelf = hasSender and string.lower(fromDisplayName) == string.lower(GetDisplayName()),
    })
    -- Hiding the translation affects presentation only, never exposure. Rendering
    -- used the pre-award snapshot so learning cannot reroll this message.
    if not TT.saved.showTranslations or stats.translatedWords == 0 then
        return rendered, stats, award
    end
    local formatted = TT.Formatter:Translation(profile, rendered)

    -- Defer one frame so ESO and chat-formatting addons can render the original
    -- foreign-language line first without us replacing their formatter.
    if zo_callLater then
        zo_callLater(function()
            CHAT_ROUTER:AddSystemMessage(formatted)
        end, 0)
    else
        CHAT_ROUTER:AddSystemMessage(formatted)
    end
    return rendered, stats, award
end

function TT.ChatOutput:IsExposureChannel(channelType)
    if type(channelType) ~= "number" then return false end
    if self.exposureChannels then return self.exposureChannels[channelType] == true end
    return channelType == CHAT_CHANNEL_SAY or channelType == CHAT_CHANNEL_YELL
        or channelType == CHAT_CHANNEL_WHISPER or channelType == CHAT_CHANNEL_PARTY
end

function TT.ChatOutput:Initialize()
    EVENT_MANAGER:RegisterForEvent(
        self.eventName,
        EVENT_CHAT_MESSAGE_CHANNEL,
        function(_, channelType, fromName, text, isCustomerService, fromDisplayName)
            TT.ChatOutput:OnChatMessage(channelType, fromName, text, isCustomerService, fromDisplayName)
        end
    )
end
