-- CharacterMarkdown - API Layer - PvP
-- Abstraction for Alliance War and Battlegrounds

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.pvp = {}

local api = CM.api.pvp

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

-- gender: Optional parameter - should be passed from collector level
--        Defaults to 1 (Female) if not provided (for backward compatibility)
function api.GetRank(gender)
    gender = gender or CM.SafeCall(GetUnitGender, "player") or GENDER_MALE
    local success, rank, subRank = CM.SafeCallMulti(GetUnitAvARank, "player")
    rank = (success and rank) or 0
    subRank = (success and subRank) or 0
    local rankName = "Recruit"
    local points = CM.SafeCall(GetUnitAvARankPoints, "player") or 0

    if rank > 0 then
        rankName = CM.SafeCall(GetAvARankName, gender, rank) or rankName
    end

    return {
        rank = rank,
        subRank = subRank,
        name = rankName,
        points = points,
    }
end

function api.GetCampaign()
    local campaignId = CM.SafeCall(GetAssignedCampaignId)
    if not campaignId or campaignId == 0 then
        return { name = "None", id = 0 }
    end

    local name = CM.SafeCall(GetCampaignName, campaignId)

    -- Emperor status check
    local hasEmperor = CM.SafeCall(DoesCampaignHaveEmperor, campaignId)
    local empInfo = nil
    if hasEmperor then
        local success, alliance, characterName, displayName = CM.SafeCallMulti(GetCampaignEmperorInfo, campaignId)
        empInfo = {
            name = characterName,
            account = displayName,
            alliance = alliance,
        }
    end

    return {
        id = campaignId,
        name = name or "Unknown",
        hasEmperor = hasEmperor,
        emperor = empInfo,
    }
end

function api.GetBattlegroundInfo()
    -- Battleground MMR/Rank if available
    -- Note: BG leaderboard data usually requires async queries
    -- We'll return basic state here
    local isInBG = CM.SafeCall(IsActiveWorldBattleground)
    return {
        isActive = isInBG,
    }
end

-- Composition functions moved to collector level
