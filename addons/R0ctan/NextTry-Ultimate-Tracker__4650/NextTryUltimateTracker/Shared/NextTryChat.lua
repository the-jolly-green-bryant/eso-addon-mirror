NextTryShared = NextTryShared or {}

local MODULE_VERSION = 1

if not NextTryShared.Chat or (NextTryShared.Chat.version or 0) < MODULE_VERSION then
    local Chat = {}
    Chat.version = MODULE_VERSION

    local function Try(fn)
        if type(fn) ~= "function" then return false end
        local ok = pcall(fn)
        return ok == true
    end

    function Chat.Format(prefix, message, color)
        prefix = tostring(prefix or "NextTry")
        color = tostring(color or "84E291")
        return string.format("|c%s[%s]|r %s", color, prefix, tostring(message or ""))
    end

    function Chat.Print(prefix, message, color)
        local text = Chat.Format(prefix, message, color)
        local printed = false

        if CHAT_ROUTER then
            printed = Try(function() CHAT_ROUTER:AddSystemMessage(text) end) or printed
        end

        if not printed and CHAT_SYSTEM then
            printed = Try(function() CHAT_SYSTEM:AddMessage(text) end) or printed
        end

        if not printed and ZO_GetChatSystem then
            local ok, chatSystem = pcall(ZO_GetChatSystem)
            if ok and chatSystem then
                if chatSystem.primaryContainer then
                    printed = Try(function() chatSystem.primaryContainer:AddMessage(text) end) or printed
                end
                if not printed and chatSystem.containers then
                    for _, cc in ipairs(chatSystem.containers) do
                        if not printed and cc and cc.windows then
                            for i = 1, #cc.windows do
                                local win = cc.windows[i]
                                if win then
                                    printed = Try(function() cc:AddEventMessageToWindow(win, text, CHAT_CATEGORY_SYSTEM) end) or printed
                                    if printed then break end
                                end
                            end
                        end
                        if printed then break end
                    end
                end
            end
        end

        return printed
    end

    NextTryShared.Chat = Chat
end

