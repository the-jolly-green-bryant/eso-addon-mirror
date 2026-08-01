-- CharacterMarkdown - API Layer - Guilds
-- Abstraction for guild membership and ranks

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.guilds = {}

local api = CM.api.guilds

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetNumGuilds()
    return CM.SafeCall(GetNumGuilds) or 0
end

function api.GetGuildInfo(guildIndex)
    local guildId = CM.SafeCall(GetGuildId, guildIndex)
    if not guildId then
        return nil
    end

    local name = CM.SafeCall(GetGuildName, guildId)
    local allianceId = CM.SafeCall(GetGuildAlliance, guildId)
    local rankIndex = nil
    local memberIndex = CM.SafeCall(GetPlayerGuildMemberIndex, guildId)
    if memberIndex and memberIndex > 0 then
        local successMember, _, _, memberRankIndex = CM.SafeCallMulti(GetGuildMemberInfo, guildId, memberIndex)
        if successMember then
            rankIndex = memberRankIndex
        end
    end
    local memberCount = CM.SafeCall(GetNumGuildMembers, guildId)

    -- Rank name (optional, but useful)
    local rankName = nil
    if rankIndex and rankIndex > 0 then
        -- Note: Rank indices are usually 1-based in Lua for some functions,
        -- but GuildRanks might need GetGuildRankId checks.
        -- Usually GetGuildRankCustomName(guildId, rankIndex) works.
        -- SafeCallMulti handles potential API variance
        local success, rName = CM.SafeCallMulti(GetGuildRankCustomName, guildId, rankIndex)
        if success and rName and rName ~= "" then
            rankName = rName
        end
    end

    return {
        id = guildId,
        name = name or "Unknown",
        allianceId = allianceId, -- Only return ID, not name (alliance name is cross-domain)
        rankIndex = rankIndex,
        rankName = rankName,
        memberIndex = memberIndex,
        memberCount = memberCount,
    }
end

-- Composition functions moved to collector level
