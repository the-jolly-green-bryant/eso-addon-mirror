-- ============================================================================
-- AetherChat : Chat History & Configurable Retention Module
-- ============================================================================
AetherChat = AetherChat or {}
local AetherChat = AetherChat

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

function History.CleanDuplicates(channelKey)
    if not AetherChat.savedVars or not AetherChat.savedVars.history then return end
    local list = AetherChat.savedVars.history[channelKey]
    if not list or type(list) ~= 'table' then return end

    local i = 1
    while i < #list do
        local current = list[i]
        local nextMsg = list[i + 1]
        if nextMsg and current.text == nextMsg.text and (not current.timestamp or not nextMsg.timestamp or math.abs(current.timestamp - nextMsg.timestamp) < 10) then
            table.remove(list, i + 1)
        else
            i = i + 1
        end
    end
end

function History.CleanAllDuplicates()
    if not AetherChat.savedVars or not AetherChat.savedVars.history then return end
    for chKey, _ in pairs(AetherChat.savedVars.history) do
        History.CleanDuplicates(chKey)
    end
end

function History.AddMessage(channelKey, author, messageText, timestamp, role, isSelf, isWhisper, zoneLang)
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
    local nowStamp = GetTimeStamp()
    local text = messageText or ''

    -- Strict Deduplication check on recent messages in this channel
    if #list > 0 then
        for idx = #list, math.max(1, #list - 5), -1 do
            local prev = list[idx]
            if prev and prev.text == text then
                if not prev.timestamp or math.abs(nowStamp - prev.timestamp) < 5 then
                    return -- Exact duplicate within 5s, reject
                end
            end
        end
    end
    
    local timeStr = timestamp or GetTimeString():sub(1, 5)
    local entry = {
        author = author or 'Inconnu',
        text = text,
        time = timeStr,
        role = role or 0,
        isSelf = isSelf or false,
        isWhisper = isWhisper or false,
        zoneLang = zoneLang or nil,
        timestamp = nowStamp,
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
