-- https://esoapi.uesp.net/100021/data/c/h/a/CHAT_SYSTEM.AddMessage.html
CHAT_SYSTEM = {}

local messages = {}

function CHAT_SYSTEM.AddMessage(self, text)
    table.insert(messages, text)
end

function CHAT_SYSTEM:contains(value)
    -- Custom function for testing purposes

    for key, message in pairs(messages) do
        if string.match(message, value) then
            return true;
        end
    end

    return false
end

return CHAT_SYSTEM

