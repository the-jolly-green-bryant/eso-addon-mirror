CrowdednESO = {}
CrowdednESO.name = "CrowdednESO"

-- ============================================================
-- Localize global API functions once at file scope.
-- In Lua, a global lookup (_G.GetGuildInfo) is a table index,
-- while a local/upvalue lookup is a direct register access.
-- Since these are called inside loops, caching them as locals
-- removes a table lookup on every single call.
-- ============================================================
local GetNumGuilds                        = GetNumGuilds
local GetGuildId                          = GetGuildId
local GetGuildInfo                        = GetGuildInfo
local GetNumFriends                       = GetNumFriends
local GetFriendInfo                       = GetFriendInfo
local GetNumSelectionCampaigns            = GetNumSelectionCampaigns
local GetSelectionCampaignPopulationData  = GetSelectionCampaignPopulationData
local GetSelectionCampaignId              = GetSelectionCampaignId
local GetCampaignName                     = GetCampaignName
local GetCampaignRulesetType              = GetCampaignRulesetType
local GetCampaignRulesetId                = GetCampaignRulesetId
local GetString                           = GetString
local floor                               = math.floor

-- Cached once instead of re-fetched on every campaign loop iteration
-- (GetString does a lookup into the client string table each call).
local VENGEANCE_NAME = GetString(SI_CAMPAIGN_OVERVIEW_CATEGORY_VENGEANCE)

function CrowdednESO.start()

    local numGuilds = GetNumGuilds()
    local total = 0
    local online = 0

    for i = 1, numGuilds do
        local guildID = GetGuildId(i)
        local numMembers, numOnline = GetGuildInfo(guildID)
        total = total + numMembers
        online = online + numOnline
    end

    local numFriends = GetNumFriends()

    if numFriends ~= 0 then
        for i = 1, numFriends do
            local _, _, friendStatus = GetFriendInfo(i)
            if friendStatus ~= PLAYER_STATUS_OFFLINE then
                online = online + 1
            end
        end
        total = total + numFriends
    end

    local campaignTotal = 0
    local campaignOnline = 0
    local campaigns = GetNumSelectionCampaigns()

    for c = 1, campaigns do
        -- Call GetSelectionCampaignId(c) once and reuse the result,
        -- instead of calling it twice (name check + ruleset check).
        local campaignId = GetSelectionCampaignId(c)

        local aldPop = GetSelectionCampaignPopulationData(c, ALLIANCE_ALDMERI_DOMINION)
        local dagPop = GetSelectionCampaignPopulationData(c, ALLIANCE_DAGGERFALL_COVENANT)
        local eboPop = GetSelectionCampaignPopulationData(c, ALLIANCE_EBONHEART_PACT)
        local lTotal = 360

        if GetCampaignName(campaignId) == VENGEANCE_NAME then
            lTotal = 900
        elseif GetCampaignRulesetType(GetCampaignRulesetId(campaignId)) == CAMPAIGN_RULESET_TYPE_IMPERIAL_CITY then
            lTotal = 180
        end

        campaignOnline = campaignOnline
            + CrowdednESO.getCampaignNumbers(aldPop, lTotal)
            + CrowdednESO.getCampaignNumbers(dagPop, lTotal)
            + CrowdednESO.getCampaignNumbers(eboPop, lTotal)
        campaignTotal = campaignTotal + lTotal
    end

    local gOnline = online + campaignOnline
    local gTotal = total + campaignTotal

    -- Guard against divide-by-zero (e.g. no guilds/friends, or no campaigns
    -- available yet) which previously could produce nan/inf percentages.
    local campaignPercentage = campaignTotal > 0 and floor(campaignOnline / campaignTotal * 100) or 0
    local guildPercentage = total > 0 and floor(online / total * 100) or 0
    local percentage = gTotal > 0 and floor(gOnline / gTotal * 100) or 0

    if guildPercentage > campaignPercentage then -- guild population alone is more accurate for the percentage when low campaign population.
        percentage = guildPercentage
        gOnline = online
        gTotal = total
    end

    local crowdMeter = " Very Low"
    if percentage > 50 then crowdMeter = " Overcrowded!"
    elseif percentage > 40 then crowdMeter = " Very High"
    elseif percentage > 30 then crowdMeter = " High"
    elseif percentage > 20 then crowdMeter = " Medium High"
    elseif percentage > 10 then crowdMeter = " Medium"
    elseif percentage > 5  then crowdMeter = " Medium Low"
    elseif percentage > 2  then crowdMeter = " Low"
    end

    CHAT_SYSTEM:AddMessage("|cC3C09CGame Crowdedness:|r |cFFFFFF" .. crowdMeter .. "|r |c9DFE00" .. percentage .. "%|r |cC3C09C(" .. gOnline .. "/" .. gTotal .. ")|r")
end

-- regular 360, vengeance 900, IC maybe 180
-- Lookup table replaces the previous long if/elseif chains: O(1) table
-- index instead of up to 4 sequential comparisons per call, and this
-- function is called 3 times per campaign per refresh.
local CAMPAIGN_POP_VALUES = {
    [900] = { [CAMPAIGN_POP_FULL] = 300, [CAMPAIGN_POP_HIGH] = 225, [CAMPAIGN_POP_MEDIUM] = 150, [CAMPAIGN_POP_LOW] = 37 },
    [180] = { [CAMPAIGN_POP_FULL] = 60,  [CAMPAIGN_POP_HIGH] = 45,  [CAMPAIGN_POP_MEDIUM] = 30,  [CAMPAIGN_POP_LOW] = 8  },
    [360] = { [CAMPAIGN_POP_FULL] = 120, [CAMPAIGN_POP_HIGH] = 90,  [CAMPAIGN_POP_MEDIUM] = 60,  [CAMPAIGN_POP_LOW] = 15 },
}

function CrowdednESO.getCampaignNumbers(pop, total)
    local table_for_total = CAMPAIGN_POP_VALUES[total]
    if not table_for_total then
        return 0
    end
    return table_for_total[pop] or 0
end

ZO_PreHookHandler(ZO_CampaignBrowser, "OnHide", function() CrowdednESO.start() end)
ZO_PreHookHandler(ZO_CampaignBrowser_GamepadTopLevelAvaRankFooter, "OnHide", function() CrowdednESO.start() end)
