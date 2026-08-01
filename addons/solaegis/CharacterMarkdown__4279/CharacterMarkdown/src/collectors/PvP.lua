-- CharacterMarkdown - PvP Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

-- =====================================================
-- BASIC PVP DATA
-- =====================================================

local function CollectBasicPvPData()
    -- Use API layer granular functions (composition at collector level)
    -- Get gender from Character API to pass to PvP API
    local characterInfo = CM.api.character.GetGender()
    local genderId = characterInfo and characterInfo.id or 1 -- Default to 1 (Female) if not available

    local rank = CM.api.pvp.GetRank(genderId)
    local campaign = CM.api.pvp.GetCampaign()
    local battleground = CM.api.pvp.GetBattlegroundInfo()

    local basic = {}

    -- Transform API data to expected format (backward compatibility)
    if rank then
        basic.rank = rank.rank or 0
        basic.rankName = rank.name or "Recruit"
        basic.rankPoints = rank.points or 0
    else
        basic.rank = 0
        basic.rankName = "Recruit"
        basic.rankPoints = 0
    end

    if campaign then
        basic.campaignId = campaign.id or nil
        basic.campaignName = campaign.name or "None"
        basic.hasEmperor = campaign.hasEmperor or false
        basic.emperor = campaign.emperor
    else
        basic.campaignName = "None"
        basic.campaignId = nil
        basic.hasEmperor = false
        basic.emperor = nil
    end

    if battleground then
        basic.isInBattleground = battleground.isActive or false
    else
        basic.isInBattleground = false
    end

    return basic
end

-- =====================================================
-- DETAILED PVP STATS
-- =====================================================

local function GetBattlegroundLeaderboard(bgType)
    local success, currentRank, currentScore = CM.SafeCallMulti(GetBattlegroundLeaderboardLocalPlayerInfo, bgType)
    if success then
        return {
            rank = currentRank or 0,
            score = currentScore or 0,
        }
    end
    return { rank = 0, score = 0 }
end

local function CollectPvPStatsData()
    local characterInfo = CM.api.character.GetGender()
    local genderId = characterInfo and characterInfo.id or 1
    local rank = CM.api.pvp.GetRank(genderId)
    local campaign = CM.api.pvp.GetCampaign()

    local pvp = {
        rank = rank and rank.rank or 0,
        rankName = rank and rank.name or "Recruit",
        rankPoints = rank and rank.points or 0,
        allianceName = nil,
        progression = nil,
        campaign = nil,
        rewards = nil,
    }

    local alliance = CM.SafeCall(GetUnitAlliance, "player")
    if alliance then
        pvp.allianceName = CM.SafeCall(GetAllianceName, alliance)
    end

    if (pvp.rankPoints or 0) > 0 then
        local success, subRankStart, nextSubRank = CM.SafeCallMulti(GetAvARankProgress, pvp.rankPoints)
        if success then
            subRankStart = subRankStart or 0
            nextSubRank = nextSubRank or subRankStart
            local pointsToNext = math.max(0, nextSubRank - pvp.rankPoints)
            local range = nextSubRank - subRankStart
            local progressPercent = range > 0 and ((pvp.rankPoints - subRankStart) / range * 100) or 0
            pvp.progression = {
                currentPoints = pvp.rankPoints,
                subRankStart = subRankStart,
                nextSubRank = nextSubRank,
                pointsToNext = pointsToNext,
                progressPercent = progressPercent,
            }
        end
    end

    if campaign and campaign.id and campaign.id > 0 then
        pvp.campaign = {
            name = campaign.name,
            isActive = true,
            ruleset = {
                name = nil,
                allowsCP = CM.SafeCall(DoesCurrentCampaignRulesetAllowChampionPoints) or false,
            },
        }

        local rulesetId = CM.SafeCall(GetCampaignRulesetId, campaign.id)
        if rulesetId then
            pvp.campaign.ruleset.name = CM.SafeCall(GetCampaignRulesetName, rulesetId)
        end

        local earnedTier = CM.SafeCall(GetPlayerCampaignRewardTierInfo, campaign.id) or 0
        local loyaltyStreak = CM.SafeCall(GetCurrentCampaignLoyaltyStreak) or 0
        pvp.rewards = {
            earnedTier = earnedTier,
            loyaltyStreak = loyaltyStreak,
        }
    end

    return {
        pvp = pvp,
        leaderboards = {
            playerPosition = { found = false },
        },
        battlegrounds = {
            leaderboards = {
                deathmatch = GetBattlegroundLeaderboard(BATTLEGROUND_LEADERBOARD_TYPE_DEATHMATCH),
                flagGames = GetBattlegroundLeaderboard(BATTLEGROUND_LEADERBOARD_TYPE_FLAG_GAMES),
                landGrab = GetBattlegroundLeaderboard(BATTLEGROUND_LEADERBOARD_TYPE_LAND_GRAB),
            },
        },
    }
end

-- =====================================================
-- UNIFIED PVP COLLECTOR
-- =====================================================

local function CollectPvPData()
    -- Always collect basic PvP data
    local basic = CollectBasicPvPData()

    -- Check settings to determine if detailed stats should be collected
    local settings = CM.GetSettings()
    local includePvPStats = settings and settings.includePvPStats or false

    local result = {
        basic = basic,
        stats = nil, -- Only populated if includePvPStats is true
        summary = {},
    }

    -- Add computed metrics
    if basic.rank then
        result.summary.rankProgress = {
            currentRank = basic.rank,
            rankName = basic.rankName or "Recruit",
            rankPoints = basic.rankPoints or 0,
        }
    end

    if basic.campaignName and basic.campaignName ~= "None" then
        result.summary.campaignParticipation = {
            active = true,
            campaignName = basic.campaignName,
            hasEmperor = basic.hasEmperor or false,
        }
    else
        result.summary.campaignParticipation = {
            active = false,
        }
    end

    result.summary.battlegroundStatus = {
        isActive = basic.isInBattleground or false,
    }

    if includePvPStats then
        result.stats = CollectPvPStatsData()
    end

    return result
end

CM.collectors.CollectPvPData = CollectPvPData

CM.collectors.CollectPvPStatsData = function()
    local settings = CM.GetSettings()
    local includePvPStats = settings and settings.includePvPStats or false

    if includePvPStats then
        return CollectPvPStatsData()
    end

    return {
        pvp = {},
        leaderboards = {},
        battlegrounds = {},
    }
end

CM.DebugPrint("COLLECTOR", "PvP collector module loaded")
