-- CharacterMarkdown - Social Data Collector
-- Composition logic moved from API layer
-- Includes guilds and mail

local CM = CharacterMarkdown

-- =====================================================
-- GUILDS
-- =====================================================

local function CollectGuildsData()
    -- Use API layer granular functions (composition at collector level)
    local numGuilds = CM.api.guilds.GetNumGuilds()

    local data = {
        list = {},
        count = numGuilds or 0,
    }

    for i = 1, numGuilds do
        local guild = CM.api.guilds.GetGuildInfo(i)
        if guild then
            -- Get alliance name using alliance API (cross-domain composition)
            local allianceName = "Unknown"
            if guild.allianceId then
                local name = CM.SafeCall(GetAllianceName, guild.allianceId)
                if name then
                    allianceName = zo_strformat("<<1>>", name)
                end
            end

            -- Transform to expected format (backward compatibility)
            table.insert(data.list, {
                id = guild.id,
                name = guild.name or "Unknown",
                alliance = {
                    id = guild.allianceId,
                    name = allianceName,
                },
                rankIndex = guild.rankIndex,
                rankName = guild.rankName,
                memberIndex = guild.memberIndex,
                memberCount = guild.memberCount,
            })
        end
    end

    -- Add computed summary
    local allianceDistribution = {}
    for _, guild in ipairs(data.list) do
        local allianceName = guild.alliance and guild.alliance.name or "Unknown"
        allianceDistribution[allianceName] = (allianceDistribution[allianceName] or 0) + 1
    end

    data.summary = {
        totalGuilds = data.count,
        allianceDistribution = allianceDistribution,
    }

    return data
end

CM.collectors.CollectGuildsData = CollectGuildsData

-- =====================================================
-- MAIL
-- =====================================================

local function CollectMailData()
    -- Use API layer granular functions (composition at collector level)
    local mailList = CM.api.mail.GetAllMail()

    local data = {
        list = mailList or {},
        count = #(mailList or {}),
    }

    -- Add computed summary
    local unreadCount = 0
    local attachmentCount = 0
    for _, mail in ipairs(data.list) do
        if not mail.isRead then
            unreadCount = unreadCount + 1
        end
        if mail.hasAttachments then
            attachmentCount = attachmentCount + mail.attachmentCount
        end
    end

    data.summary = {
        totalMail = data.count,
        unreadCount = unreadCount,
        readCount = data.count - unreadCount,
        attachmentCount = attachmentCount,
    }

    return data
end

CM.collectors.CollectMailData = CollectMailData

CM.DebugPrint("COLLECTOR", "Social collector module loaded")
