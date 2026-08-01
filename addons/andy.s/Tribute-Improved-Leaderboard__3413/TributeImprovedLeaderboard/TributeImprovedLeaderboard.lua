local NAME = "TributeImprovedLeaderboard"
local EM = EVENT_MANAGER

local PENDING_NONE = 0
local PENDING_START = 1
local PENDING_END = 2

local leaderboardSize = 0
local rankState, scoreState = PENDING_NONE, PENDING_NONE
local rankStart, scoreStart, rankEnd, scoreEnd = 0, 0, 0, 0
local rankSignPlus = "00ff00+"
local rankSignMinus = "ff1c1c"

-- Return current rank, total players and percent.
local function GetPlayerStats()
	local playerLeaderboardRank, totalLeaderboardPlayers = GetTributeLeaderboardRankInfo()
	local topPercent = totalLeaderboardPlayers == 0 and 100 or playerLeaderboardRank * 100 / totalLeaderboardPlayers
	return playerLeaderboardRank, totalLeaderboardPlayers, topPercent
end

-- TODO: add language support.
local function PrintScore()
	if rankEnd > 0 then
		local rankChange = rankStart - rankEnd
		local scoreChange = scoreEnd - scoreStart
		local topPercent = leaderboardSize == 0 and 100 or rankEnd * 100 / leaderboardSize
		if rankStart > 0 then
			d(string.format("[ToT] Rank: |cffffff%d/%d|r (|c%s%d|r). Score: |cffffff%d|r (|c%s%d|r). Top |cffffff%.1f%%|r", rankEnd, leaderboardSize, rankChange < 0 and rankSignMinus or rankSignPlus, rankChange, scoreEnd, scoreChange < 0 and rankSignMinus or rankSignPlus, scoreChange, topPercent))
		else
			d(string.format("|c00ff00[ToT] Rank gained!|r Rank: |cffffff%d/%d|r. Score: |cffffff%d|r (|c%s%d|r). Top |cffffff%.1f%%|r", rankEnd, leaderboardSize, scoreEnd, scoreChange < 0 and rankSignMinus or rankSignPlus, scoreChange, topPercent))
		end
	else
		-- Went from ranked to unranked (is this even possible?).
		if rankStart > 0 then
			d(string.format("|cFF0000[ToT] Rank lost!|r Current score: |cffffff%d|r", scoreEnd))
		else
			d(string.format("[ToT] Unranked. Current score: |cffffff%d|r", scoreEnd))
		end
	end
end

local function UpdateRank(type, skipRequest)
	if skipRequest or RequestTributeLeaderboardRank() == LEADERBOARD_DATA_READY then
		if type == PENDING_START then
			rankStart, leaderboardSize = GetTributeLeaderboardRankInfo()
		elseif type == PENDING_END then
			rankEnd, leaderboardSize = GetTributeLeaderboardRankInfo()
		end
		-- Print score if both values are ready.
		if type == PENDING_END and scoreState == PENDING_NONE then
			PrintScore()
		end
		rankState = PENDING_NONE
		return true
	else
		rankState = type
		return false
	end
end

local function UpdateScore(type, skipRequest)
	if skipRequest or QueryTributeLeaderboardData() == LEADERBOARD_DATA_READY then
		if type == PENDING_START then
			_, scoreStart = GetTributeLeaderboardLocalPlayerInfo(TRIBUTE_LEADERBOARD_TYPE_RANKED)
		elseif type == PENDING_END then
			_, scoreEnd = GetTributeLeaderboardLocalPlayerInfo(TRIBUTE_LEADERBOARD_TYPE_RANKED)
		end
		-- Kludge alert! UpdateRank() seems to never request leaderboard rank and always uses the old value? Get the latest value here just to make sure.
		-- Also we could use GetTributeLeaderboardLocalPlayerInfo() first value, but it always returns 0 outside of top 100 :<
		if RequestTributeLeaderboardRank() == LEADERBOARD_DATA_READY then
			if type == PENDING_START then
				rankStart, leaderboardSize = GetTributeLeaderboardRankInfo()
			elseif type == PENDING_END then
				rankEnd, leaderboardSize = GetTributeLeaderboardRankInfo()
			end
		end
		-- Print score if both values are ready.
		if type == PENDING_END and rankState == PENDING_NONE then
			PrintScore()
		end
		scoreState = PENDING_NONE
		return true
	else
		scoreState = type
		return false
	end
end

local function UpdateData(type)
	rankState = type
	scoreState = type
	local rank = UpdateRank(type)
	local score = UpdateScore(type)
	return rank and score
end

local function GameStart()
	UpdateData(PENDING_START)
end

local function GameOver()
	UpdateData(PENDING_END)
end

--[[
function TestPrintScore(rank, score)
	UpdateData(PENDING_START)
	zo_callLater(function()
		if rankState == PENDING_NONE and scoreState == PENDING_NONE then
			rankEnd, scoreEnd = rank, score
			PrintScore()
		else
			d('|c888888Still pending...|r')
		end
	end, 1000)
end
]]

local function Initialize()
	EM:RegisterForEvent(NAME, EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, function(_, state)
		if GetTributeMatchType() == TRIBUTE_MATCH_TYPE_COMPETITIVE then
			if state == TRIBUTE_GAME_FLOW_STATE_INTRO then
				GameStart()
			elseif state == TRIBUTE_GAME_FLOW_STATE_GAME_OVER then
				GameOver()
			end
		end
	end)

	EM:RegisterForEvent(NAME, EVENT_TRIBUTE_LEADERBOARD_RANK_RECEIVED, function()
		if rankState == PENDING_START or rankState == PENDING_END then
			--d(string.format('|c888888Rank received: %d|r', rankState))
			UpdateRank(rankState, true)
		end
	end)

	EM:RegisterForEvent(NAME, EVENT_TRIBUTE_LEADERBOARD_DATA_RECEIVED, function()
		if scoreState == PENDING_START or scoreState == PENDING_END then
			--d(string.format('|c888888Score received: %d|r', scoreState))
			UpdateScore(scoreState, true)
		end
	end)

	-- Show total leaderboard size in activity finder.
	ZO_PostHook(ZO_ActivityFinderTemplate_Shared, "RefreshTributeSeasonData", function(self)
		if self.leaderboardRankLabel ~= "" and GetTributePlayerCampaignRank() == TRIBUTE_TIER_PLATINUM then
			local playerLeaderboardRank, totalLeaderboardPlayers, topPercent = GetPlayerStats()
			local formattedLeaderboardRank = zo_strformat(SI_TRIBUTE_FINDER_LEADERBOARD_RANK_CONTENT_PERCENT, zo_strformat("<<1>>/<<2>>", playerLeaderboardRank, totalLeaderboardPlayers), topPercent)
			local colorizedFormattedLeaderboardRank = ZO_SELECTED_TEXT:Colorize(formattedLeaderboardRank)
			self.leaderboardRankLabel:SetText(zo_strformat(SI_TRIBUTE_FINDER_LEADERBOARD_RANK_LABEL, colorizedFormattedLeaderboardRank))
		end
	end)

	-- Keyboard leaderboard header.
	-- Override this function completely, since there is no point in post hook.
	ZO_TributeLeaderboardsManager_Keyboard.RefreshHeaderPlayerInfo = function(self)
		local playerLeaderboardRank, totalLeaderboardPlayers, topPercent = GetPlayerStats()

		local displayedScore = self.currentScoreData or GetString(SI_LEADERBOARDS_NO_CURRENT_SCORE)
		if self.currentScoreData and topPercent <= 10 then
			displayedScore = string.format("|c%s%s|r", topPercent <= 2 and "eeca2a" or "2dc50e", self.currentScoreData)
		end
		self.currentScoreLabel:SetText(zo_strformat(SI_LEADERBOARDS_CURRENT_SCORE, displayedScore))

		local rankingTypeText = GetString("SI_LEADERBOARDTYPE", LEADERBOARD_LIST_MANAGER.leaderboardRankType)
		local displayedRank = playerLeaderboardRank > 0 and zo_strformat(SI_TRIBUTE_FINDER_LEADERBOARD_RANK_CONTENT_PERCENT, zo_strformat("<<1>>/<<2>>", playerLeaderboardRank, totalLeaderboardPlayers), topPercent) or GetString(SI_LEADERBOARDS_NOT_RANKED)
		self.currentRankLabel:SetText(zo_strformat(SI_LEADERBOARDS_CURRENT_RANK, rankingTypeText, displayedRank))
	end

	-- Gamepad leaderboard header.
	ZO_TributeLeaderboardsManager_Gamepad.RefreshHeaderPlayerInfo = function(self)
		local headerData = GAMEPAD_LEADERBOARD_LIST:GetContentHeaderData()
		headerData.data1HeaderText = GetString(SI_GAMEPAD_LEADERBOARDS_CURRENT_SCORE_LABEL)

		local playerLeaderboardRank, totalLeaderboardPlayers, topPercent = GetPlayerStats()
		if self.currentScoreData then
			headerData.data1Text = topPercent <= 10 and string.format("|c%s%s|r", topPercent <= 2 and "eeca2a" or "2dc50e", self.currentScoreData) or self.currentScoreData
		else
			headerData.data1Text = GetString(SI_LEADERBOARDS_NO_SCORE_RECORDED)
		end

		local rankingTypeText = GetString("SI_LEADERBOARDTYPE", LEADERBOARD_LIST_MANAGER.leaderboardRankType)
		headerData.data2HeaderText = zo_strformat(SI_GAMEPAD_LEADERBOARDS_CURRENT_RANK_LABEL, rankingTypeText)
		headerData.data2Text = playerLeaderboardRank > 0 and zo_strformat(SI_TRIBUTE_FINDER_LEADERBOARD_RANK_CONTENT_PERCENT, zo_strformat("<<1>>/<<2>>", playerLeaderboardRank, totalLeaderboardPlayers), topPercent) or GetString(SI_LEADERBOARDS_NOT_RANKED)
	end

	-- Colorize points in the ToT leaderboard rows based on top %.
	local SetupLeaderboardPlayerEntry = function(self, control, data)
		local leaderboardData = self.GetSelectedLeaderboardData and self:GetSelectedLeaderboardData() or GAMEPAD_LEADERBOARDS:GetSelectedLeaderboardData()
		if leaderboardData.leaderboardRankType == LEADERBOARD_TYPE_TRIBUTE and data.rank > 0 then
			local _, totalLeaderboardPlayers = GetTributeLeaderboardRankInfo()
			local topPercent = totalLeaderboardPlayers == 0 and 100 or data.rank * 100 / totalLeaderboardPlayers
			if topPercent <= 2 then
				control.pointsLabel:SetColor(0.93, 0.79, 0.17)
			elseif topPercent <= 10 then
				control.pointsLabel:SetColor(0.18, 0.77, 0.05)
			else
				control.pointsLabel:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
			end
		else
			control.pointsLabel:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
		end
	end
	ZO_PostHook(LEADERBOARDS, "SetupLeaderboardPlayerEntry", SetupLeaderboardPlayerEntry)
	ZO_PostHook(GAMEPAD_LEADERBOARD_LIST, "SetupLeaderboardPlayerEntry", SetupLeaderboardPlayerEntry)

	-- Adjust timer position for russian language (otherwise labels overlap).
	if GetCVar("Language.2") == "ru" then	
		ZO_TributeLeaderboardsInformationArea_KeyboardTimer:ClearAnchors()
		ZO_TributeLeaderboardsInformationArea_KeyboardTimer:SetAnchor(TOPRIGHT, ZO_TributeLeaderboardsInformationArea_Keyboard, TOPRIGHT)
	end
end

EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, function(_, name)
	if name == NAME then
		Initialize()
		EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
	end
end)