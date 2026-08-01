local LC = LibCoro


-- Returns a list of tables: { index = idx, hour_ts = hour_timestamp }
-- For each whole hour UTC boundary that has at least one timestamp <= it.
-- 'timestamps' must be a sorted array of numbers (Unix seconds, UTC).
-- local function get_closest_previous_indices(timestamps)
--     local result = {}
--     if #timestamps == 0 then return result end

--     local first_ts = timestamps[1]
--     local last_ts = timestamps[#timestamps]

--     -- Find the first whole hour boundary that is >= first timestamp
--     local start_hour = math.floor(first_ts / 3600) * 3600
--     -- Find the last whole hour boundary that is <= last timestamp
--     local end_hour = math.floor(last_ts / 3600) * 3600

--     local idx = 1  -- current index in timestamps
--     for hour_ts = start_hour, end_hour, 3600 do
--         -- Advance idx while the next timestamp is <= hour_ts
--         while idx < #timestamps and timestamps[idx + 1] <= hour_ts do
--             idx = idx + 1
--         end
--         -- Now timestamps[idx] is the closest previous timestamp (or equal) to hour_ts
--         if timestamps[idx] <= hour_ts then
--             result[#result+1] =  { index = idx, hour_ts = hour_ts }
--         end
--     end

--     return result
-- end


local data
GLOBAL_IMP_CYRODIIL_OBSERVER_DATA = data

local TIMESTAMP = 1
local PLAYERS = 2
local HMMM = 3

local function OnPlayerActivated(_, initial)
    -- for selectionIndex = 1, GetNumSelectionCampaigns() do
    --     local campaignId = GetSelectionCampaignId(selectionIndex)
    --     local campaignData = {}
    --     data[campaignId] = campaignData

    --     for a = ALLIANCE_ITERATION_BEGIN, ALLIANCE_ITERATION_END do
    --         campaignData[a] = {
    --             [TIMESTAMP] = {},
    --             [PLAYERS] = {},
    --         }
    --     end
    -- end

    data = ImpData2 or {}
    ImpData2 = data

    data.GetTopFrom = function(alliance)
        local maxScore = 0
        local maxName = nil

        for pName, pData in pairs(data[102][alliance][PLAYERS]) do
            if pData[pData.last] > maxScore then
                maxScore = pData[pData.last]
                maxName = pName
            end
        end
        df('Name: %s', maxName)
        return data[102][alliance][PLAYERS][maxName]
    end

    local t0, t
    EVENT_MANAGER:RegisterForEvent('gdfffffffsdfsf', EVENT_CAMPAIGN_LEADERBOARD_DATA_RECEIVED, function(_, campaignId, alliance)
        local ts = GetTimeStamp32()
        t0 = GetGameTimeSeconds()

        if not data[campaignId] then
            data[campaignId] = {}
        end

        if not data[campaignId][alliance] then
            data[campaignId][alliance] = {
                [TIMESTAMP] = {},
                [PLAYERS] = {},
            }
        end

        local allianceCampaignData = data[campaignId][alliance]
        local n = #allianceCampaignData[TIMESTAMP] + 1
        allianceCampaignData[TIMESTAMP][n] = ts


        -- allianceCampaignData[HMMM] = get_closest_previous_indices(allianceCampaignData[TIMESTAMP])
        allianceCampaignData[HMMM] = nil


        local players = allianceCampaignData[PLAYERS]

        for e = 1, GetNumCampaignAllianceLeaderboardEntries(campaignId, alliance) do
            local isPlayer, alliancePointsRank, name, points, _, displayName, achievedEmperorForAlliance = GetCampaignAllianceLeaderboardEntryInfo(campaignId, alliance, e)

            local uid = name

            if not players[uid] then
                players[uid] = {
                    last = 0
                }
            end
            -- players[uid].displayName = displayName  -- TODO: unnecessary tbh

            local player = players[uid]

            if player[player.last] == points then
                if player.last > 1 then
                    player[player.last] = nil
                end
            end

            player[n] = points
            player.last = n
        end

        t = GetGameTimeSeconds()
        df('Full update for campaign %d alliance %d took %.4f ms', campaignId, alliance, (t - t0) * 1000)
    end)

    EVENT_MANAGER:RegisterForUpdate('kdfjndjkhnjkghnf', 1000 * 30 * 1, function()
        for a = ALLIANCE_ITERATION_BEGIN, ALLIANCE_ITERATION_END do
            QueryCampaignLeaderboardData(a)
        end
    end)
end


local function CreateList()
	local Label = LibScrollList.Label
	local combine = LibScrollList.combine
	local Column = LibScrollList.Column
	local ScrollList = LibScrollList.Table

	local defaultStyle = {
		SetFont = {'ZoFontWinH4'},
		-- SetColor = {0.1, 0.1, 0.1, 0.9},
		SetMaxLineCount = {1},
	}

	local headerStyle = combine(defaultStyle, {
		SetFont = {'ZoFontGameLargeBold'},
		-- SetColor = {0.3, 0.3, 0.2, 0.9},
		SetModifyTextType = {MODIFY_TEXT_TYPE_UPPERCASE},
	})

	local alignRight= {
		SetHorizontalAlignment = {TEXT_ALIGN_RIGHT}
	}

	local alignLeft= {
		SetHorizontalAlignment = {TEXT_ALIGN_LEFT}
	}

	local scoreStyle = combine(defaultStyle, alignRight)
	local nameStyle = combine(defaultStyle, alignLeft)

	local ScoreCell = Label(scoreStyle, function(ctrl, value) ctrl:SetText(ZO_LocalizeDecimalNumber(value)) end)
	local ScoreHeader = Label(combine(scoreStyle, headerStyle))
	local NameCell = Label(nameStyle)
	local NameHeader = Label(combine(nameStyle, headerStyle))

	local SORTABLE = true
	local columns = {
        Column('Alliance',  90,  0, NameCell,  'Alliance', NameHeader,  SORTABLE),
        Column('Name',     180,  0, NameCell,  'Name',     NameHeader,  SORTABLE),
        Column('Score',    140,  0, ScoreCell, 'Score',    ScoreHeader, SORTABLE),
        Column('Diff24h',  140,  0, ScoreCell, '+/24h',    ScoreHeader, SORTABLE),
        Column('Diff8h',   140,  0, ScoreCell, '+/8h',     ScoreHeader, SORTABLE),
        Column('Diff1h',   140,  0, ScoreCell, '+/1h',     ScoreHeader, SORTABLE),
    }

	local WITH_HEADERS = true

    local postCreateCallback = function(rowControl)
		local background = CreateControlFromVirtual('$(parent)Background', rowControl, 'IMP_TallListSelectedHighlight')
        background:SetAlpha(0.6)

        -- rowControl:SetHandler('OnMouseEnter', showTooltip)
        -- rowControl:SetHandler('OnMouseExit', ZO_Tooltips_HideTextTooltip)

        -- rowControl:SetHandler('OnMouseDown', onMouseDown)

        -- local scrollList = rowControl:GetParent():GetParent()

        -- ZO_ScrollList_EnableSelection(scrollList, 'ZO_ThinListHighlight', LayoutMatchRow)
	    -- ZO_ScrollList_SetDeselectOnReselect(scrollList, true)
	end
    local ALPHA = 0.6
    local ALLIANCE_COLORS = {}
    for a = 0, 3 do
        local c = GetAllianceColor(a)
        c:SetAlpha(ALPHA)
        ALLIANCE_COLORS[a] = c
    end
	local postSetupCallback = function(rowControl, dataEntryData, scrollList)
        local alliance = dataEntryData[1]
        GetControl(rowControl, 'Background'):SetColor(ALLIANCE_COLORS[alliance]:UnpackRGBA())
	end

    local scrollList = ScrollList(WITH_HEADERS)
    scrollList:AddDataType(1, columns, 30, postCreateCallback, postSetupCallback)

    local REPLACE = true
	local currentScrollControl = scrollList:Create('ScrollList', IMP_STATS_CyrodiilObserver, REPLACE)
    -- currentScrollControl:SetDimensions(140*2+180, 400)

	return scrollList
end



local function OnAddonsLoaded()
    EVENT_MANAGER:RegisterForEvent('adgjkgdnjdnjgg', EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    local scrollList = CreateList()

    -- local ALLIANCE = 1

    SLASH_COMMANDS['/cyroobserver'] = function()
        if IMP_STATS_CyrodiilObserver:IsHidden() then
            IMP_STATS_CyrodiilObserver:SetHidden(false)
        else
            IMP_STATS_CyrodiilObserver:SetHidden(true)
            return
        end

        local data_ = {}

        for a = 1, 3 do
            local ALLIANCE = a

            local players = data[102][ALLIANCE][PLAYERS]
            local timestamps = data[102][ALLIANCE][TIMESTAMP]

            local now = GetTimeStamp32()
            local twentyFourHAgo = now - 24 * 60 * 60
            local eightHAgo = now - 8 * 60 * 60
            local oneHAgo = now - 1 * 60 * 60
            local indexTwentyFourHAgo , indexEightHAgo, indexOneHAgo
            for t = #timestamps, 1, -1 do
                if timestamps[t] < oneHAgo and not indexOneHAgo then
                    indexOneHAgo = t + 1
                end

                if timestamps[t] < eightHAgo and not indexEightHAgo then
                    indexEightHAgo = t + 1
                end

                if timestamps[t] < twentyFourHAgo and not indexTwentyFourHAgo then
                    indexTwentyFourHAgo = t + 1
                    break
                end
            end


            indexTwentyFourHAgo = indexTwentyFourHAgo or 1
            indexEightHAgo = indexEightHAgo or 1
            indexOneHAgo = indexOneHAgo or 1


            local scores_t, scores_t2, scores_t3 = {}, {}, {}
            for name, scores in pairs(players) do
                ZO_ClearNumericallyIndexedTable(scores_t)
                ZO_ClearNumericallyIndexedTable(scores_t2)
                ZO_ClearNumericallyIndexedTable(scores_t3)

                for i, score in pairs(scores) do
                    if type(i) ~= 'string' then
                        if i > indexTwentyFourHAgo then
                            scores_t3[#scores_t3+1] = score
                        end

                        if i > indexEightHAgo then
                            scores_t[#scores_t+1] = score
                        end

                        if i > indexOneHAgo then
                            scores_t2[#scores_t2+1] = score
                        end
                    end
                end
                table.sort(scores_t)
                table.sort(scores_t2)
                table.sort(scores_t3)
                local scoreEightHAgo = scores_t[1] or scores[scores.last]
                local scoreOneHAgo = scores_t2[1] or scores[scores.last]
                local scoreTwentyFourHAgo = scores_t3[1] or scores[scores.last]

                data_[#data_+1] = {
                    a,
                    name,
                    scores[scores.last],
                    scores[scores.last] - scoreTwentyFourHAgo,
                    scores[scores.last] - scoreEightHAgo,
                    scores[scores.last] - scoreOneHAgo,
                }
            end

        end

        scrollList:Update(1, data_)
    end
end


EVENT_MANAGER:RegisterForEvent('lkgndgfjgndkd', EVENT_ADD_ONS_LOADED, OnAddonsLoaded)
