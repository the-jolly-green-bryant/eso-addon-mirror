RanckorsData = {}

local function ProcessLeaderboardData(campaignId, playerAlliance)
    local uiBuffer = {}
    local leaderName, leaderPoints = nil, 0
    local playerName = GetUnitName("player")
    local playerPosition, playerPoints = nil, 0

    local totalEntries = GetNumCampaignLeaderboardEntries(campaignId)
    for i = 1, totalEntries do
        local _, rank, charName, points, _, alliance = GetCampaignLeaderboardEntryInfo(campaignId, i)

        if alliance == playerAlliance then
            -- Track the player’s alliance leader (highest points within the alliance)
            if points > leaderPoints then
                leaderName = charName
                leaderPoints = points
            end
            -- Track the player’s own rank and points
            if charName == playerName then
                playerPosition = rank
                playerPoints = points
            end
        end
    end

    -- Display the player’s info
    if playerName and playerPosition then
        table.insert(uiBuffer, string.format(RanckorsStrings.PlayerInfo, playerName, playerPosition, RanckorsHelpers.FormatNumberWithCommas(playerPoints)))
    end
    -- Display the alliance leader’s info or a fallback message if no leader is found
    if leaderName then
        local pointDifference = leaderPoints - (playerPoints or 0)
        table.insert(uiBuffer, string.format(RanckorsStrings.AllianceLeader, leaderName, RanckorsHelpers.FormatNumberWithCommas(leaderPoints)))
        table.insert(uiBuffer, string.format(RanckorsStrings.PointDifference, RanckorsHelpers.FormatNumberWithCommas(pointDifference)))
    else
        table.insert(uiBuffer, RanckorsStrings.NoLeaderError)
    end

    return table.concat(uiBuffer, "\n")
end

function RanckorsData.RefreshAllData()
    local uiBuffer = {}

    -- Get campaign and player details
    local campaignId = GetAssignedCampaignId("player")
    local homeCampaignName = GetCampaignName(campaignId) or "Unknown Campaign"
    local playerAlliance = GetUnitAlliance("player")
    local allianceName = GetAllianceName(playerAlliance) or "Unknown Alliance"

    -- Add home campaign and alliance details
    table.insert(uiBuffer, RanckorsStrings.HomeCampaign .. homeCampaignName)
    table.insert(uiBuffer, RanckorsStrings.Alliance .. allianceName)

    -- Get emperor details
local emperorAlliance, emperorName = GetCampaignEmperorInfo(campaignId)
if emperorName and emperorName ~= "" then
    local reignDuration = RanckorsHelpers.FormatReignDuration(GetCampaignEmperorReignDuration(campaignId) or 0)

    -- Determine the correct color for the alliance
    local allianceColor
    if emperorAlliance == ALLIANCE_ALDMERI_DOMINION then
        allianceColor = RanckorsColors.Aldmeri
    elseif emperorAlliance == ALLIANCE_EBONHEART_PACT then
        allianceColor = RanckorsColors.Ebonheart
    elseif emperorAlliance == ALLIANCE_DAGGERFALL_COVENANT then
        allianceColor = RanckorsColors.Daggerfall
    else
        allianceColor = RanckorsColors.White  -- Fallback for unknown alliances
    end

    -- Format the emperor line with colored alliance name
    table.insert(
        uiBuffer,
        RanckorsStrings.CurrentEmperor .. emperorName .. " (" .. allianceColor .. GetAllianceName(emperorAlliance) .. "|r)"
    )
    table.insert(uiBuffer, RanckorsStrings.EmperorReign .. reignDuration)
else
    table.insert(uiBuffer, RanckorsStrings.NoEmperor)
end

    -- Get alliance scores and potential points
    local alliances = {
        { index = ALLIANCE_ALDMERI_DOMINION, name = "Aldmeri Dominion", color = RanckorsColors.Aldmeri },
        { index = ALLIANCE_EBONHEART_PACT, name = "Ebonheart Pact", color = RanckorsColors.Ebonheart },
        { index = ALLIANCE_DAGGERFALL_COVENANT, name = "Daggerfall Covenant", color = RanckorsColors.Daggerfall }
    }

    for _, alliance in ipairs(alliances) do
        local currentPoints = GetCampaignAllianceScore(campaignId, alliance.index) or 0
        local potentialPoints = RanckorsLeaderBoardTracker:CalculatePotentialPoints(alliance.index, campaignId) or 0
        table.insert(uiBuffer, string.format(RanckorsStrings.AlliancePoints, alliance.color .. alliance.name .. "|r", RanckorsHelpers.FormatNumberWithCommas(currentPoints), RanckorsHelpers.FormatNumberWithCommas(potentialPoints)))
    end

    -- Add leaderboard details
    local leaderboardDetails = ProcessLeaderboardData(campaignId, playerAlliance)
    table.insert(uiBuffer, leaderboardDetails)

    -- Return the final formatted UI content
    return table.concat(uiBuffer, "\n")
end