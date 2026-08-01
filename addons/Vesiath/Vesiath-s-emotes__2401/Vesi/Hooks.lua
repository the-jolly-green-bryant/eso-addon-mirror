V.Hooks = {
    Init = function(self)
        -- Wait 5 seconds for other addons to register their formatters to prevent compatability issues
        zo_callLater(function() 
            V.MessageFormatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
            V.OriginalFormatter = V.MessageFormatters[EVENT_CHAT_MESSAGE_CHANNEL]
            CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, V.Hooks.EmoteParser)
        end, 5000)
        self.Titles()
    end,

    EmoteParser = function(messageType, fromName, text, isFromCustomerService, fromDisplayName)
        text = V.Emotes:ParseEmoteFromText(text)
        return V.OriginalFormatter(messageType, fromName, text, isFromCustomerService, fromDisplayName)
    end,

    Titles = function()
        oGet = GetTitle
        GetTitle = function(index)
            t = oGet(index)
            return V.Titles:GetTitleByTitleName(GetUnitDisplayName("player"), t) or t
        end

        oUGet = GetUnitTitle
        GetUnitTitle = function(u)
            t = oUGet(u)
            n = GetUnitDisplayName(u)
            return V.Titles:GetTitleByTitleName(n, t) or V.Titles:GetGlobalTitle(n) or t
        end
    end,
}