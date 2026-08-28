-- ============================================================================
-- AetherChat : Chat History & Configurable Retention Module
-- ============================================================================
AetherChat = AetherChat or {}
AetherChat.History = {}

local History = AetherChat.History

function History.GetChannelKey(serverType, channelId)
    return string.format('%s:%s', tostring(serverType), tostring(channelId or 'general'))
end

function History.PruneExpiredMessages()
    if not AetherChat.savedVars or not AetherChat.savedVars.history then return end
    local retentionSeconds = AetherChat.savedVars.historyRetention or 604800 -- default: 1 week (604800s)
    if retentionSeconds <= 0 then return end -- 0 = Unlimited

    local now = GetTimeStamp()
    for chKey, list in pairs(AetherChat.savedVars.history) do
        if type(list) == 'table' then
            for i = #list, 1, -1 do
                local msg = list[i]
                if msg.timestamp and (now - msg.timestamp > retentionSeconds) then
                    table.remove(list, i)
                end
            end
        end
    end
end

function History.AddMessage(channelKey, author, messageText, timestamp, role, isSelf, isWhisper)
    if not AetherChat.savedVars or not AetherChat.savedVars.persistHistory then return end
    
    local historyStore = AetherChat.savedVars.history
    if not historyStore then
        AetherChat.savedVars.history = {}
        historyStore = AetherChat.savedVars.history
    end
    
    if not historyStore[channelKey] then
        historyStore[channelKey] = {}
    end
    
    local list = historyStore[channelKey]
    local maxCount = AetherChat.savedVars.maxHistory or 150
    
    local timeStr = timestamp or GetTimeString():sub(1, 5)
    local entry = {
        author = author or 'Inconnu',
        text = messageText or '',
        time = timeStr,
        role = role or 0,
        isSelf = isSelf or false,
        isWhisper = isWhisper or false,
        timestamp = GetTimeStamp(),
    }
    
    table.insert(list, entry)
    
    while #list > maxCount do
        table.remove(list, 1)
    end
end

function History.GetMessages(channelKey)
    if not AetherChat.savedVars or not AetherChat.savedVars.history then
        return {}
    end
    return AetherChat.savedVars.history[channelKey] or {}
end
