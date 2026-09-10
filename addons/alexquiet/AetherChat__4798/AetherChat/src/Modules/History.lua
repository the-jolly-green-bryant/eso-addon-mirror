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
    
    local retentionSeconds = 604800 -- 1 week default
    if AetherChat.Settings and AetherChat.Settings.Get then
        retentionSeconds = tonumber(AetherChat.Settings.Get('historyRetention', 604800)) or 604800
    elseif AetherChat.savedVars.historyRetention then
        retentionSeconds = tonumber(AetherChat.savedVars.historyRetention) or 604800
    end

    -- Clean any malformed loot lines that lost their item link in past sessions
    for chKey, list in pairs(AetherChat.savedVars.history) do
        if type(list) == 'table' and tostring(chKey):find('loot') then
            for i = #list, 1, -1 do
                local msg = list[i]
                if msg and msg.text and msg.text:find("%d+:%d+:%d+:%d+:%d+:%d+") and not msg.text:find("|H") then
                    table.remove(list, i)
                end
            end
        end
    end

    if retentionSeconds <= 0 then return end -- 0 = Unlimited retention

    local now = GetTimeStamp()
    for chKey, list in pairs(AetherChat.savedVars.history) do
        if type(list) == 'table' then
            for i = #list, 1, -1 do
                local msg = list[i]
                if msg and msg.timestamp and tonumber(msg.timestamp) then
                    if (now - tonumber(msg.timestamp)) > retentionSeconds then
                        table.remove(list, i)
                    end
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
        if current and nextMsg and current.text == nextMsg.text then
            if not current.timestamp or not nextMsg.timestamp or math.abs(current.timestamp - nextMsg.timestamp) < 5 then
                table.remove(list, i + 1)
            else
                i = i + 1
            end
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

function History.AddMessage(channelKey, author, messageText, timestamp, role, isSelf, isWhisper, zoneLang, originalChannel)
    -- Check if history persistence is explicitly disabled (defaults to true if nil)
    local shouldPersist = true
    if AetherChat.Settings and AetherChat.Settings.Get then
        shouldPersist = AetherChat.Settings.Get('persistHistory', true)
    elseif AetherChat.savedVars and AetherChat.savedVars.persistHistory ~= nil then
        shouldPersist = AetherChat.savedVars.persistHistory
    end
    if shouldPersist == false then return end

    if not AetherChat.savedVars then return end
    if not AetherChat.savedVars.history then
        AetherChat.savedVars.history = {}
    end
    
    local historyStore = AetherChat.savedVars.history
    if not historyStore[channelKey] then
        historyStore[channelKey] = {}
    end
    
    local list = historyStore[channelKey]
    local maxCount = AetherChat.savedVars.maxHistory or 150
    local nowStamp = GetTimeStamp()
    local text = messageText or ''

    -- Deduplication check on recent messages in this channel
    if #list > 0 then
        for idx = #list, math.max(1, #list - 5), -1 do
            local prev = list[idx]
            if prev and prev.text == text then
                if prev.timestamp and math.abs(nowStamp - prev.timestamp) < 3 then
                    return -- Duplicate received within 3 seconds, reject
                end
            end
        end
    end
    
    local timeStr = timestamp or GetTimeString():sub(1, 5)
    local srcChannel = originalChannel or channelKey
    local entry = {
        author = author or 'Inconnu',
        text = text,
        time = timeStr,
        role = role or 0,
        isSelf = isSelf or false,
        isWhisper = isWhisper or false,
        zoneLang = zoneLang or nil,
        channel = srcChannel,
        originalChannel = srcChannel,
        timestamp = nowStamp,
    }
    
    table.insert(list, entry)
    
    while #list > maxCount do
        table.remove(list, 1)
    end
end

function History.GetMessagesForCustomTab(tabId)
    if not AetherChat.savedVars or not AetherChat.savedVars.history then
        return {}
    end

    local tabData = AetherChat.CustomTabs and AetherChat.CustomTabs.GetTab and AetherChat.CustomTabs.GetTab(tabId)
    if not tabData or not tabData.filters then
        return AetherChat.savedVars.history[tabId] or {}
    end

    local f = tabData.filters
    local merged = {}
    local seen = {}
    local historyStore = AetherChat.savedVars.history

    local function AddFromChannel(sourceKey, defaultChannel)
        local list = historyStore[sourceKey]
        if list and type(list) == 'table' then
            for _, msg in ipairs(list) do
                local matches = false
                if sourceKey == 'zone' then
                    local zLang = msg.zoneLang
                    if not zLang and msg.text then
                        if msg.text:find("%[FR%]") then zLang = 'fr'
                        elseif msg.text:find("%[EN%]") then zLang = 'en'
                        elseif msg.text:find("%[DE%]") then zLang = 'de'
                        elseif msg.text:find("%[ES%]") then zLang = 'es'
                        end
                    end
                    if zLang == 'fr' and (f.zone_fr or f.zone) then matches = true
                    elseif zLang == 'en' and (f.zone_en or f.zone) then matches = true
                    elseif zLang == 'de' and (f.zone_de or f.zone) then matches = true
                    elseif zLang == 'es' and (f.zone_es or f.zone) then matches = true
                    elseif f.zone then matches = true
                    end
                elseif sourceKey:find('^guild(%d)') then
                    local gNum = sourceKey:match('^guild(%d)')
                    if f['guild' .. gNum] then matches = true end
                elseif sourceKey:find('^officer(%d)') then
                    local oNum = sourceKey:match('^officer(%d)')
                    if f['officer' .. oNum] then matches = true end
                elseif sourceKey == 'party' then
                    if f.party then matches = true end
                elseif sourceKey == 'general' or sourceKey == 'say' then
                    if f.say or f.yell or f.emote or f.npc then matches = true end
                elseif sourceKey:sub(1, 3) == 'dm:' then
                    if f.whisper then matches = true end
                end

                if matches then
                    local dedupKey = tostring(msg.timestamp or 0) .. "_" .. tostring(msg.author or "") .. "_" .. tostring(msg.text or "")
                    if not seen[dedupKey] then
                        seen[dedupKey] = true
                        local copy = {
                            author = msg.author,
                            text = msg.text,
                            time = msg.time,
                            role = msg.role,
                            isSelf = msg.isSelf,
                            isWhisper = msg.isWhisper,
                            zoneLang = msg.zoneLang,
                            channel = msg.channel or defaultChannel or sourceKey,
                            originalChannel = msg.originalChannel or msg.channel or defaultChannel or sourceKey,
                            timestamp = msg.timestamp or 0,
                        }
                        table.insert(merged, copy)
                    end
                end
            end
        end
    end

    -- 1. Zone
    if f.zone or f.zone_fr or f.zone_en or f.zone_de or f.zone_es or f.zone_ru or f.zone_jp or f.zone_zh then
        AddFromChannel('zone', 'zone')
    end

    -- 2. Guilds 1 to 5 and Officers 1 to 5
    for i = 1, 5 do
        if f['guild' .. i] then
            AddFromChannel('guild' .. i, 'guild' .. i)
        end
        if f['officer' .. i] then
            AddFromChannel('officer' .. i, 'officer' .. i)
        end
    end

    -- 3. Party
    if f.party then
        AddFromChannel('party', 'party')
    end

    -- 4. General / Say / Yell / Emote / NPC
    if f.say or f.yell or f.emote or f.npc then
        AddFromChannel('general', 'say')
    end

    -- 5. Whispers
    if f.whisper then
        for chKey, _ in pairs(historyStore) do
            if tostring(chKey):sub(1, 3) == 'dm:' then
                AddFromChannel(chKey, 'whisper')
            end
        end
    end

    -- 6. Direct messages in tabId history (if any)
    local directList = historyStore[tabId]
    if directList and type(directList) == 'table' then
        for _, msg in ipairs(directList) do
            local dedupKey = tostring(msg.timestamp or 0) .. "_" .. tostring(msg.author or "") .. "_" .. tostring(msg.text or "")
            if not seen[dedupKey] then
                seen[dedupKey] = true
                table.insert(merged, msg)
            end
        end
    end

    -- Sort chronologically by timestamp
    table.sort(merged, function(a, b)
        local tsA = a.timestamp or 0
        local tsB = b.timestamp or 0
        if tsA == tsB then
            return (a.time or "") < (b.time or "")
        end
        return tsA < tsB
    end)

    -- Cap to maxHistory
    local maxCount = AetherChat.savedVars.maxHistory or 150
    while #merged > maxCount do
        table.remove(merged, 1)
    end

    return merged
end

function History.GetMessages(channelKey)
    if not AetherChat.savedVars or not AetherChat.savedVars.history then
        return {}
    end
    if channelKey and channelKey:find('^custom_') then
        return History.GetMessagesForCustomTab(channelKey)
    end
    return AetherChat.savedVars.history[channelKey] or {}
end
