-- Shared addon namespace.
Ultivite = Ultivite or {}

-- ZO_GetChatSystem is the current chat entry point. Retain the older globals for
-- compatibility with clients and chat replacements that still publish them.
function Ultivite.GetChatSystem()
    if type(ZO_GetChatSystem) == "function" then
        local ok, system = pcall(ZO_GetChatSystem)
        if ok and system then return system end
    end
    if KEYBOARD_CHAT_SYSTEM then return KEYBOARD_CHAT_SYSTEM end
    if CHAT_SYSTEM then return CHAT_SYSTEM end
    return nil
end

function Ultivite.GetChatTextEntry()
    local system = Ultivite.GetChatSystem()
    return system and system.textEntry or nil
end
