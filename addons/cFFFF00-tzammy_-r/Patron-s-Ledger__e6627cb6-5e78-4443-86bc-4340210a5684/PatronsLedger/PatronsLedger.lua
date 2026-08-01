--[[
Patron's Ledger - Tales of Tribute Companion for PS5
Version: 1.0.0

BASED ON:
- TributeImprovedLeaderboard by @andy.s
  (Rank tracking, leaderboard UI enhancements)
- ExoYsTributesEnhancement by @ExoY94
  (Match statistics tracking structure)

Enhanced Features:
- Leaderboard enhancements (rank display, colorization)
- Match statistics tracking (wins, losses, time, victory types)
- Post-match summaries with detailed stats
- Slash command configuration (no dependencies needed)
- Fully optimized for PS5/console gamepad UI
- Extensive bug fixes and safety improvements

Original Authors: @andy.s, @ExoY94
PS5 Enhancement & Integration: @tzammy_

This addon combines and enhances code from the above addons.
If you are an original author and wish this to be removed, please contact me.
]]

local NAME = "PatronsLedger"
local EM = EVENT_MANAGER

--[[ ==================== ]]
--[[   CONSTANTS           ]]
--[[ ==================== ]]

local PENDING_NONE = 0
local PENDING_START = 1
local PENDING_END = 2

local OUTCOME_UNKNOWN = 0
local OUTCOME_VICTORY = 1
local OUTCOME_DEFEAT = 2

-- Polling configuration for score updates (ranked matches only)
local SCORE_POLL_MAX_ATTEMPTS = 20
local SCORE_POLL_DELAY_MS = 500  -- 500ms between polls
local SCORE_POLL_TIMEOUT_MS = 10000  -- 10 seconds total timeout

--[[ ==================== ]]
--[[   STATE VARIABLES     ]]
--[[ ==================== ]]

-- Leaderboard tracking
local leaderboardSize = 0
local rankState, scoreState = PENDING_NONE, PENDING_NONE
local rankStart, scoreStart, rankEnd, scoreEnd = 0, 0, 0, 0
local rankSignPlus = "00ff00"
local rankSignMinus = "ff1c1c"

-- Score polling state (for ranked matches only)
local scorePollAttempts = 0
local scorePollStartTime = 0
local isPollingForScore = false

-- Match tracking (ranked matches only)
local matchData = {}

-- SavedVariables (settings + statistics, single source of truth)
local savedVars = nil

--[[ ==================== ]]
--[[   VICTORY TYPE NAMES  ]]
--[[ ==================== ]]

local victoryTypeName = {
	[TRIBUTE_VICTORY_TYPE_PRESTIGE] = "Prestige",
	[TRIBUTE_VICTORY_TYPE_PATRON] = "Patron",
	[TRIBUTE_VICTORY_TYPE_CONCESSION] = "Concession",
	[TRIBUTE_VICTORY_TYPE_EARLY_CONCESSION] = "Early Concession",
	[TRIBUTE_VICTORY_TYPE_SYSTEM_DISBAND] = "System Disband",
}

--[[ ==================== ]]
--[[   UTILITY FUNCTIONS   ]]
--[[ ==================== ]]

local function IsMatchDataInitialized()
	return not ZO_IsTableEmpty(matchData)
end

local function ClearMatchData()
	matchData = {}
end


-- Return current rank, total players and percent
local function GetPlayerStats()
	local playerLeaderboardRank, totalLeaderboardPlayers = GetTributeLeaderboardRankInfo()
	local topPercent = totalLeaderboardPlayers == 0 and 100 or playerLeaderboardRank * 100 / totalLeaderboardPlayers
	return playerLeaderboardRank, totalLeaderboardPlayers, topPercent
end

-- Print colored chat message
local function PrintMessage(message)
	if savedVars.showChatNotifications then
		d(message)
	end
end

-- Format time in MM:SS or HH:MM:SS
local function FormatTime(milliseconds)
	local totalSeconds = math.floor(milliseconds / 1000)
	local hours = math.floor(totalSeconds / 3600)
	local minutes = math.floor((totalSeconds % 3600) / 60)
	local seconds = totalSeconds % 60

	if hours > 0 then
		return string.format("%d:%02d:%02d", hours, minutes, seconds)
	else
		return string.format("%d:%02d", minutes, seconds)
	end
end

--[[ ==================== ]]
--[[   MATCH DATA MANAGER  ]]
--[[   (Ranked Matches)    ]]
--[[ ==================== ]]

local function InitializeMatchData()
	local function InitPlayerOpponentTable()
		return {
			[TRIBUTE_PLAYER_PERSPECTIVE_SELF] = 0,
			[TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT] = 0,
		}
	end

	local opponentName, opponentType = GetTributePlayerInfo(TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT)

	matchData = {
		matchType = GetTributeMatchType(),
		opponentName = opponentName,
		opponentType = opponentType,
		outcome = OUTCOME_UNKNOWN,
		matchStart = GetGameTimeMilliseconds(),
		matchDuration = 0,
		turns = InitPlayerOpponentTable(),
		patrons = {}, -- Will be populated after patron drafting
		firstPlayer = nil, -- Will be set when first turn starts
	}
end

-- Capture patron IDs after drafting is complete
local function CaptureMatchPatrons()
	if not IsMatchDataInitialized() then return end

	local patrons = {}
	-- There are 4 patron draft slots (0-3)
	for i = 0, 3 do
		local patronId = GetDraftedPatronId(i)
		if patronId and patronId > 0 then
			table.insert(patrons, {
				id = patronId,
				name = GetTributePatronName(patronId)
			})
		end
	end

	matchData.patrons = patrons
end

--[[ ==================== ]]
--[[   STATISTICS MANAGER  ]]
--[[   (Ranked Matches)    ]]
--[[ ==================== ]]

local function CreateCharStatistics(charId)
	local function VictoryDefeatStatsTableStructure()
		local tableStructure = {}
		for i = 1, 4 do
			tableStructure[i] = {}
			for j = 0, 5 do
				tableStructure[i][j] = 0
			end
		end
		return tableStructure
	end

	-- Only create statistics for ranked matches
	savedVars.statistics.character[charId] = {
		name = GetUnitName("player"),
		server = GetWorldName(),
		games = {
			[TRIBUTE_MATCH_TYPE_COMPETITIVE] = {time = 0, played = 0, won = 0},
		},
		victory = VictoryDefeatStatsTableStructure(),
		defeat = VictoryDefeatStatsTableStructure(),
		-- New: Track opponent win/loss records
		opponents = {},
		-- New: Track patron combination win/loss records
		patrons = {},
		-- New: Track first hand statistics
		firstHand = {
			asSelf = {played = 0, won = 0},
			asOpponent = {played = 0, won = 0},
		},
	}
end

local function PostMatchProcess()
	if not savedVars.trackStatistics then return end
	if not IsMatchDataInitialized() then return end

	local victoryPerspective, victoryType = GetTributeResultsWinnerInfo()
	local victory = victoryPerspective == TRIBUTE_PLAYER_PERSPECTIVE_SELF

	matchData.outcome = victory and OUTCOME_VICTORY or OUTCOME_DEFEAT
	matchData.matchDuration = GetGameTimeMilliseconds() - matchData.matchStart

	local charId = GetCurrentCharacterId()
	if not savedVars.statistics.character[charId] then
		CreateCharStatistics(charId)
	end

	-- Record match data (only for ranked)
	local store = savedVars.statistics.character[charId]
	local matchTypeData = store.games[TRIBUTE_MATCH_TYPE_COMPETITIVE]

	if not matchTypeData then
		-- Fallback: create entry if somehow missing
		matchTypeData = {time = 0, played = 0, won = 0}
		store.games[TRIBUTE_MATCH_TYPE_COMPETITIVE] = matchTypeData
	end

	matchTypeData.played = matchTypeData.played + 1
	if victory then
		matchTypeData.won = matchTypeData.won + 1
	end
	matchTypeData.time = matchTypeData.time + matchData.matchDuration

	-- Record victory/defeat type (with validation)
	if victory then
		if not store.victory[TRIBUTE_MATCH_TYPE_COMPETITIVE] then
			store.victory[TRIBUTE_MATCH_TYPE_COMPETITIVE] = {}
		end
		store.victory[TRIBUTE_MATCH_TYPE_COMPETITIVE][victoryType] = (store.victory[TRIBUTE_MATCH_TYPE_COMPETITIVE][victoryType] or 0) + 1
	else
		if not store.defeat[TRIBUTE_MATCH_TYPE_COMPETITIVE] then
			store.defeat[TRIBUTE_MATCH_TYPE_COMPETITIVE] = {}
		end
		store.defeat[TRIBUTE_MATCH_TYPE_COMPETITIVE][victoryType] = (store.defeat[TRIBUTE_MATCH_TYPE_COMPETITIVE][victoryType] or 0) + 1
	end

	-- Track opponent statistics
	if matchData.opponentName and matchData.opponentName ~= "" then
		if not store.opponents then
			store.opponents = {}
		end
		if not store.opponents[matchData.opponentName] then
			store.opponents[matchData.opponentName] = {played = 0, won = 0}
		end
		store.opponents[matchData.opponentName].played = store.opponents[matchData.opponentName].played + 1
		if victory then
			store.opponents[matchData.opponentName].won = store.opponents[matchData.opponentName].won + 1
		end
	end

	-- Track patron combination statistics
	if matchData.patrons and #matchData.patrons > 0 then
		if not store.patrons then
			store.patrons = {}
		end

		-- Create a sorted patron list for consistent tracking
		local sortedPatrons = {}
		for _, patron in ipairs(matchData.patrons) do
			table.insert(sortedPatrons, patron)
		end
		-- Sort by ID
		table.sort(sortedPatrons, function(a, b) return a.id < b.id end)

		-- Create key from sorted IDs
		local patronIds = {}
		for _, patron in ipairs(sortedPatrons) do
			table.insert(patronIds, patron.id)
		end
		local patronKey = table.concat(patronIds, ",")

		-- Store patron names in sorted order (only first time)
		if not store.patrons[patronKey] then
			local patronNames = {}
			for _, patron in ipairs(sortedPatrons) do
				table.insert(patronNames, patron.name)
			end
			store.patrons[patronKey] = {
				played = 0,
				won = 0,
				names = table.concat(patronNames, ", ")
			}
		end

		store.patrons[patronKey].played = store.patrons[patronKey].played + 1
		if victory then
			store.patrons[patronKey].won = store.patrons[patronKey].won + 1
		end
	end

	-- Track first hand statistics
	if matchData.firstPlayer then
		-- Initialize firstHand structure if it doesn't exist (for existing saves)
		if not store.firstHand then
			store.firstHand = {
				asSelf = {played = 0, won = 0},
				asOpponent = {played = 0, won = 0},
			}
		end

		if matchData.firstPlayer == TRIBUTE_PLAYER_PERSPECTIVE_SELF then
			store.firstHand.asSelf.played = store.firstHand.asSelf.played + 1
			if victory then
				store.firstHand.asSelf.won = store.firstHand.asSelf.won + 1
			end
		else
			store.firstHand.asOpponent.played = store.firstHand.asOpponent.played + 1
			if victory then
				store.firstHand.asOpponent.won = store.firstHand.asOpponent.won + 1
			end
		end
	end
end

local function PrintMatchSummary()
	if not savedVars.showMatchSummary then return end
	if not IsMatchDataInitialized() then return end

	-- Ensure we have a valid outcome set
	if not matchData.outcome or matchData.outcome == OUTCOME_UNKNOWN then return end

	-- Validate turn data exists
	if not matchData.turns then return end

	local playerTurns = matchData.turns[TRIBUTE_PLAYER_PERSPECTIVE_SELF] or 0
	local opponentTurns = matchData.turns[TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT] or 0
	local totalTime = matchData.matchDuration or 0

	local outcome = matchData.outcome == OUTCOME_VICTORY and "|c00ff00Victory|r" or "|cff1c1cDefeat|r"

	PrintMessage(string.format("|cFFFF00[ToT Ranked Summary]|r %s", outcome))
	PrintMessage(string.format("  Duration: %s | Your Turns: %d | Opponent Turns: %d",
		FormatTime(totalTime), playerTurns, opponentTurns))

	if matchData.opponentName and matchData.opponentName ~= "" then
		PrintMessage(string.format("  Opponent: %s", matchData.opponentName))
	end

	-- Display patrons used in this match
	if matchData.patrons and #matchData.patrons > 0 then
		local patronNames = {}
		for _, patron in ipairs(matchData.patrons) do
			table.insert(patronNames, patron.name)
		end
		PrintMessage(string.format("  Patrons: %s", table.concat(patronNames, ", ")))
	end

	-- Display who had first turn in this match
	if matchData.firstPlayer then
		local firstPlayerText = matchData.firstPlayer == TRIBUTE_PLAYER_PERSPECTIVE_SELF and "You" or "Opponent"
		PrintMessage(string.format("  First Turn: %s", firstPlayerText))
	end
end

--[[ ==================== ]]
--[[   RANK TRACKING       ]]
--[[   (Ranked Matches)    ]]
--[[ ==================== ]]

local function PrintScore()
	if not savedVars.enabled then return end

	if rankEnd > 0 then
		local rankChange = rankStart - rankEnd
		local scoreChange = scoreEnd - scoreStart
		local topPercent = leaderboardSize == 0 and 100 or rankEnd * 100 / leaderboardSize

		local rankColor = rankChange < 0 and rankSignMinus or rankSignPlus
		local scoreColor = scoreChange < 0 and rankSignMinus or rankSignPlus

		if rankStart > 0 then
			PrintMessage(string.format("[ToT Ranked] Rank: |cffffff%d/%d|r (|c%s%+d|r). Score: |cffffff%d|r (|c%s%+d|r). Top |cffffff%.1f%%|r",
				rankEnd, leaderboardSize, rankColor, rankChange, scoreEnd, scoreColor, scoreChange, topPercent))
		else
			PrintMessage(string.format("|c00ff00[ToT Ranked] Rank gained!|r Rank: |cffffff%d/%d|r. Score: |cffffff%d|r (|c%s%+d|r). Top |cffffff%.1f%%|r",
				rankEnd, leaderboardSize, scoreEnd, scoreColor, scoreChange, topPercent))
		end
	else
		if rankStart > 0 then
			PrintMessage(string.format("|cFF0000[ToT Ranked] Rank lost!|r Current score: |cffffff%d|r", scoreEnd))
		else
			PrintMessage(string.format("[ToT Ranked] Unranked. Current score: |cffffff%d|r", scoreEnd))
		end
	end
end

local function UpdateRank(type, skipRequest)
	if skipRequest or RequestTributeLeaderboardRank() == LEADERBOARD_DATA_READY then
		local rank, size = GetTributeLeaderboardRankInfo()
		-- Validate that we got valid data
		if rank and size then
			if type == PENDING_START then
				rankStart, leaderboardSize = rank, size
			elseif type == PENDING_END then
				rankEnd, leaderboardSize = rank, size
			end
			if type == PENDING_END and scoreState == PENDING_NONE then
				PrintScore()
			end
			rankState = PENDING_NONE
			return true
		end
	end
	rankState = type
	return false
end

local function UpdateScore(type, skipRequest)
	if skipRequest or QueryTributeLeaderboardData() == LEADERBOARD_DATA_READY then
		local _, score = GetTributeLeaderboardLocalPlayerInfo(TRIBUTE_LEADERBOARD_TYPE_RANKED)
		-- Validate that we got valid score data
		if score then
			if type == PENDING_START then
				scoreStart = score
			elseif type == PENDING_END then
				scoreEnd = score
			end
		end

		if RequestTributeLeaderboardRank() == LEADERBOARD_DATA_READY then
			local rank, size = GetTributeLeaderboardRankInfo()
			if rank and size then
				if type == PENDING_START then
					rankStart, leaderboardSize = rank, size
				elseif type == PENDING_END then
					rankEnd, leaderboardSize = rank, size
				end
			end
		end

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

-- Check if score has updated and handle accordingly (ranked matches only)
local function CheckScoreUpdate()
	if not isPollingForScore then return end

	local currentTime = GetGameTimeMilliseconds()
	local elapsedTime = currentTime - scorePollStartTime

	-- Check if we've exceeded timeout
	if elapsedTime >= SCORE_POLL_TIMEOUT_MS or scorePollAttempts >= SCORE_POLL_MAX_ATTEMPTS then
		-- Timeout reached - display current data even if unchanged
		if savedVars.showChatNotifications then
			PrintMessage(string.format("|cFFFF00[ToT Ranked]|r Score update timed out after %d attempts (%.1fs). Displaying current data...",
				scorePollAttempts, elapsedTime / 1000))
		end
		PrintScore()
		isPollingForScore = false
		scorePollAttempts = 0
		return
	end

	-- Get current score from the data we just received
	local _, currentScore = GetTributeLeaderboardLocalPlayerInfo(TRIBUTE_LEADERBOARD_TYPE_RANKED)

	-- Check if score has changed from start
	if currentScore and currentScore ~= scoreStart then
		-- Score has changed! Update and display
		scoreEnd = currentScore

		-- Also update rank information
		local rankReady = RequestTributeLeaderboardRank()
		if rankReady == LEADERBOARD_DATA_READY then
			local rank, size = GetTributeLeaderboardRankInfo()
			if rank and size then
				rankEnd, leaderboardSize = rank, size
			end
		end

		-- Optional: Log successful poll time for debugging
		-- Uncomment the line below if you want to see how long it took to get updated score
		-- PrintMessage(string.format("|c888888[Debug] Score updated after %d polls (%.1fs)|r", scorePollAttempts, elapsedTime / 1000))

		PrintScore()
		isPollingForScore = false
		scorePollAttempts = 0
		return
	end

	-- Score hasn't changed yet, request new data after delay
	scorePollAttempts = scorePollAttempts + 1
	zo_callLater(function()
		-- Request new data, which will trigger EVENT_TRIBUTE_LEADERBOARD_DATA_RECEIVED
		QueryTributeLeaderboardData()
	end, SCORE_POLL_DELAY_MS)
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
	-- Initialize polling state
	scorePollAttempts = 0
	scorePollStartTime = GetGameTimeMilliseconds()
	isPollingForScore = true

	-- Start polling for score updates
	-- We delay the first request to give the server time to process the match
	zo_callLater(function()
		-- This will trigger EVENT_TRIBUTE_LEADERBOARD_DATA_RECEIVED
		QueryTributeLeaderboardData()
	end, SCORE_POLL_DELAY_MS)
end


--[[ ==================== ]]
--[[   TURN TRACKING       ]]
--[[   (Ranked Matches)    ]]
--[[ ==================== ]]

local function OnPlayerTurnStart(_, isPlayer)
	if not IsMatchDataInitialized() then return end
	if not matchData.turns then return end

	local perspective = isPlayer and TRIBUTE_PLAYER_PERSPECTIVE_SELF or TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT

	-- Track who got the first turn (only set once)
	if matchData.firstPlayer == nil then
		matchData.firstPlayer = perspective
	end

	if matchData.turns[perspective] then
		matchData.turns[perspective] = matchData.turns[perspective] + 1
	end
end

--[[ ==================== ]]
--[[   EVENT HANDLERS      ]]
--[[ ==================== ]]

local function OnGameFlowStateChange(_, flowState)
	-- Only track rank for competitive (ranked) matches
	if GetTributeMatchType() ~= TRIBUTE_MATCH_TYPE_COMPETITIVE then return end

	if flowState == TRIBUTE_GAME_FLOW_STATE_INTRO then
		InitializeMatchData()
		GameStart()
	elseif flowState == TRIBUTE_GAME_FLOW_STATE_PLAYING then
		-- Capture patrons after drafting is complete and game has started
		CaptureMatchPatrons()
	elseif flowState == TRIBUTE_GAME_FLOW_STATE_GAME_OVER then
		-- GameOver will start event-driven polling for score updates
		GameOver()

		-- Process match statistics and display summary
		-- Wait a bit to ensure all data is processed
		zo_callLater(function()
			PostMatchProcess()
			PrintMatchSummary()
			-- Clear match data after processing
			zo_callLater(function()
				ClearMatchData()
			end, 100)
		end, 500)
	elseif flowState == TRIBUTE_GAME_FLOW_STATE_INACTIVE then
		ClearMatchData()
	end
end

--[[ ==================== ]]
--[[   UI ENHANCEMENTS     ]]
--[[ ==================== ]]

local function SetupUIEnhancements()
	-- Show total leaderboard size in activity finder
	ZO_PostHook(ZO_ActivityFinderTemplate_Shared, "RefreshTributeSeasonData", function(self)
		if self.leaderboardRankLabel and GetTributePlayerCampaignRank() == TRIBUTE_TIER_PLATINUM then
			local playerLeaderboardRank, totalLeaderboardPlayers, topPercent = GetPlayerStats()
			local formattedLeaderboardRank = zo_strformat(SI_TRIBUTE_FINDER_LEADERBOARD_RANK_CONTENT_PERCENT,
				zo_strformat("<<1>>/<<2>>", playerLeaderboardRank, totalLeaderboardPlayers), topPercent)
			local colorizedFormattedLeaderboardRank = ZO_SELECTED_TEXT:Colorize(formattedLeaderboardRank)
			self.leaderboardRankLabel:SetText(zo_strformat(SI_TRIBUTE_FINDER_LEADERBOARD_RANK_LABEL, colorizedFormattedLeaderboardRank))
		end
	end)

	-- Keyboard leaderboard header
	if ZO_TributeLeaderboardsManager_Keyboard then
		ZO_TributeLeaderboardsManager_Keyboard.RefreshHeaderPlayerInfo = function(self)
			local playerLeaderboardRank, totalLeaderboardPlayers, topPercent = GetPlayerStats()

			local displayedScore = self.currentScoreData or GetString(SI_LEADERBOARDS_NO_CURRENT_SCORE)
			if self.currentScoreData and topPercent <= 10 and savedVars.colorizeLeaderboard then
				displayedScore = string.format("|c%s%s|r", topPercent <= 2 and "eeca2a" or "2dc50e", self.currentScoreData)
			end
			self.currentScoreLabel:SetText(zo_strformat(SI_LEADERBOARDS_CURRENT_SCORE, displayedScore))

			local rankingTypeText = GetString("SI_LEADERBOARDTYPE", LEADERBOARD_LIST_MANAGER.leaderboardRankType)
			local displayedRank = playerLeaderboardRank > 0 and zo_strformat(SI_TRIBUTE_FINDER_LEADERBOARD_RANK_CONTENT_PERCENT,
				zo_strformat("<<1>>/<<2>>", playerLeaderboardRank, totalLeaderboardPlayers), topPercent) or GetString(SI_LEADERBOARDS_NOT_RANKED)
			self.currentRankLabel:SetText(zo_strformat(SI_LEADERBOARDS_CURRENT_RANK, rankingTypeText, displayedRank))
		end
	end

	-- Gamepad leaderboard header
	if ZO_TributeLeaderboardsManager_Gamepad then
		ZO_TributeLeaderboardsManager_Gamepad.RefreshHeaderPlayerInfo = function(self)
			local headerData = GAMEPAD_LEADERBOARD_LIST:GetContentHeaderData()
			headerData.data1HeaderText = GetString(SI_GAMEPAD_LEADERBOARDS_CURRENT_SCORE_LABEL)

			local playerLeaderboardRank, totalLeaderboardPlayers, topPercent = GetPlayerStats()
			if self.currentScoreData then
				headerData.data1Text = (topPercent <= 10 and savedVars.colorizeLeaderboard) and
					string.format("|c%s%s|r", topPercent <= 2 and "eeca2a" or "2dc50e", self.currentScoreData) or self.currentScoreData
			else
				headerData.data1Text = GetString(SI_LEADERBOARDS_NO_SCORE_RECORDED)
			end

			local rankingTypeText = GetString("SI_LEADERBOARDTYPE", LEADERBOARD_LIST_MANAGER.leaderboardRankType)
			headerData.data2HeaderText = zo_strformat(SI_GAMEPAD_LEADERBOARDS_CURRENT_RANK_LABEL, rankingTypeText)
			headerData.data2Text = playerLeaderboardRank > 0 and zo_strformat(SI_TRIBUTE_FINDER_LEADERBOARD_RANK_CONTENT_PERCENT,
				zo_strformat("<<1>>/<<2>>", playerLeaderboardRank, totalLeaderboardPlayers), topPercent) or GetString(SI_LEADERBOARDS_NOT_RANKED)
		end
	end

	-- Colorize points in the ToT leaderboard rows
	local function SetupLeaderboardPlayerEntry(self, control, data)
		if not savedVars.colorizeLeaderboard then
			control.pointsLabel:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
			return
		end

		-- Safety: Check if GAMEPAD_LEADERBOARDS exists
		local leaderboardData = nil
		if self.GetSelectedLeaderboardData then
			leaderboardData = self:GetSelectedLeaderboardData()
		elseif GAMEPAD_LEADERBOARDS then
			leaderboardData = GAMEPAD_LEADERBOARDS:GetSelectedLeaderboardData()
		end

		if not leaderboardData then
			control.pointsLabel:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
			return
		end
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

	if LEADERBOARDS then
		ZO_PostHook(LEADERBOARDS, "SetupLeaderboardPlayerEntry", SetupLeaderboardPlayerEntry)
	end
	if GAMEPAD_LEADERBOARD_LIST then
		ZO_PostHook(GAMEPAD_LEADERBOARD_LIST, "SetupLeaderboardPlayerEntry", SetupLeaderboardPlayerEntry)
	end
end


--[[ ==================== ]]
--[[   STATISTICS COMMANDS ]]
--[[ ==================== ]]

local function PrintStatistics()
	local charId = GetCurrentCharacterId()
	if not savedVars.statistics.character[charId] then
		PrintMessage("|cff1c1c[ToT Stats]|r No statistics recorded yet")
		return
	end

	local stats = savedVars.statistics.character[charId].games
	local s = stats[TRIBUTE_MATCH_TYPE_COMPETITIVE]

	if not s or s.played == 0 then
		PrintMessage("|cff1c1c[ToT Stats]|r No ranked matches played yet")
		return
	end

	local winRate = s.played > 0 and (s.won / s.played * 100) or 0
	local avgTime = s.played > 0 and (s.time / s.played) or 0

	PrintMessage("|c00ff00[ToT Ranked Stats]|r")
	PrintMessage(string.format("  Played: %d | Won: %d | Win Rate: %.1f%%", s.played, s.won, winRate))
	PrintMessage(string.format("  Total Time: %s | Avg Time: %s", FormatTime(s.time), FormatTime(avgTime)))

	-- Display first hand statistics
	local charData = savedVars.statistics.character[charId]
	if charData.firstHand then
		local fh = charData.firstHand
		local totalSelf = fh.asSelf.played or 0
		local totalOpponent = fh.asOpponent.played or 0
		local total = totalSelf + totalOpponent

		if total > 0 then
			local selfWinRate = totalSelf > 0 and (fh.asSelf.won / totalSelf * 100) or 0
			local opponentWinRate = totalOpponent > 0 and (fh.asOpponent.won / totalOpponent * 100) or 0
			local selfPercent = (totalSelf / total * 100)

			PrintMessage("|cFFFF00  First Turn Stats:|r")
			PrintMessage(string.format("    You went first: %d times (%.1f%%) | Win Rate: %.1f%%",
				totalSelf, selfPercent, selfWinRate))
			PrintMessage(string.format("    Opponent went first: %d times (%.1f%%) | Win Rate: %.1f%%",
				totalOpponent, 100 - selfPercent, opponentWinRate))
		end
	end
end

local function PrintDetailedStatistics()
	local charId = GetCurrentCharacterId()
	if not savedVars.statistics.character[charId] then
		PrintMessage("|cff1c1c[ToT Stats]|r No statistics recorded yet")
		return
	end

	local store = savedVars.statistics.character[charId]
	local stats = store.games[TRIBUTE_MATCH_TYPE_COMPETITIVE]

	if not stats or stats.played == 0 then
		PrintMessage("|cff1c1c[ToT Stats]|r No ranked matches played yet")
		return
	end

	-- Basic stats
	local winRate = stats.played > 0 and (stats.won / stats.played * 100) or 0
	local lossCount = stats.played - stats.won

	PrintMessage("|c00ff00[ToT Ranked Stats - Detailed]|r")
	PrintMessage(string.format("  Total: %d played | %d won | %d lost | %.1f%% win rate",
		stats.played, stats.won, lossCount, winRate))

	-- Victory breakdown
	if store.victory and store.victory[TRIBUTE_MATCH_TYPE_COMPETITIVE] then
		PrintMessage("|c00ff00  Victories by type:|r")
		local victoryData = store.victory[TRIBUTE_MATCH_TYPE_COMPETITIVE]
		local totalVictories = 0

		for victoryType, count in pairs(victoryData) do
			if count > 0 then
				local typeName = victoryTypeName[victoryType] or "Unknown"
				PrintMessage(string.format("    %s: %d", typeName, count))
				totalVictories = totalVictories + count
			end
		end

		if totalVictories == 0 then
			PrintMessage("    No victories recorded")
		end
	end

	-- Defeat breakdown
	if store.defeat and store.defeat[TRIBUTE_MATCH_TYPE_COMPETITIVE] then
		PrintMessage("|cff1c1c  Defeats by type:|r")
		local defeatData = store.defeat[TRIBUTE_MATCH_TYPE_COMPETITIVE]
		local totalDefeats = 0

		for defeatType, count in pairs(defeatData) do
			if count > 0 then
				local typeName = victoryTypeName[defeatType] or "Unknown"
				PrintMessage(string.format("    %s: %d", typeName, count))
				totalDefeats = totalDefeats + count
			end
		end

		if totalDefeats == 0 then
			PrintMessage("    No defeats recorded")
		end
	end
end

local function PrintOpponentStatistics()
	local charId = GetCurrentCharacterId()
	if not savedVars.statistics.character[charId] then
		PrintMessage("|cff1c1c[ToT Stats]|r No statistics recorded yet")
		return
	end

	local store = savedVars.statistics.character[charId]
	if not store.opponents or not next(store.opponents) then
		PrintMessage("|cff1c1c[ToT Opponents]|r No opponent data recorded yet")
		return
	end

	PrintMessage("|c00ff00[ToT Ranked - Opponent Stats]|r")

	-- Sort opponents by games played
	local opponents = {}
	for name, data in pairs(store.opponents) do
		table.insert(opponents, {name = name, data = data})
	end
	table.sort(opponents, function(a, b) return a.data.played > b.data.played end)

	for _, opponent in ipairs(opponents) do
		local winRate = opponent.data.played > 0 and (opponent.data.won / opponent.data.played * 100) or 0
		local lost = opponent.data.played - opponent.data.won
		PrintMessage(string.format("  %s: %d-%d (%.1f%%)",
			opponent.name, opponent.data.won, lost, winRate))
	end
end

local function PrintPatronStatistics()
	local charId = GetCurrentCharacterId()
	if not savedVars.statistics.character[charId] then
		PrintMessage("|cff1c1c[ToT Stats]|r No statistics recorded yet")
		return
	end

	local store = savedVars.statistics.character[charId]
	if not store.patrons or not next(store.patrons) then
		PrintMessage("|cff1c1c[ToT Patrons]|r No patron data recorded yet")
		return
	end

	PrintMessage("|c00ff00[ToT Ranked - Patron Combo Stats]|r")

	-- Sort patron combos by games played
	local patronCombos = {}
	for key, data in pairs(store.patrons) do
		table.insert(patronCombos, data)
	end
	table.sort(patronCombos, function(a, b) return a.played > b.played end)

	for _, combo in ipairs(patronCombos) do
		local winRate = combo.played > 0 and (combo.won / combo.played * 100) or 0
		local lost = combo.played - combo.won
		PrintMessage(string.format("  %s", combo.names))
		PrintMessage(string.format("    %d-%d (%.1f%%)", combo.won, lost, winRate))
	end
end

--[[ ==================== ]]
--[[   SLASH COMMANDS      ]]
--[[ ==================== ]]

local function RegisterSlashCommands()
	SLASH_COMMANDS["/totlb"] = function(args)
		args = args:lower()

		if args == "" or args == "help" then
			d("|c00ff00[Patron's Ledger]|r Available commands:")
			d("  |cFFFF00Basic:|r")
			d("    /totlb on/off - Enable/disable addon")
			d("    /totlb status - Show current settings")
			d("  |cFFFF00Statistics:|r")
			d("    /totlb stats - Show ranked match statistics")
			d("    /totlb stats detailed - Show detailed victory/defeat breakdown")
			d("    /totlb stats opponents - Show win rate vs each opponent")
			d("    /totlb stats patrons - Show win rate with patron combos")
			d("  |cFFFF00Display:|r")
			d("    /totlb chat on/off - Toggle chat notifications")
			d("    /totlb color on/off - Toggle leaderboard colors")
			d("    /totlb summary on/off - Toggle match summary")
			d("  |cFFFF00Tracking:|r")
			d("    /totlb track on/off - Track match statistics")

		elseif args == "on" then
			savedVars.enabled = true
			d("|c00ff00[Patron's Ledger]|r Addon enabled")

		elseif args == "off" then
			savedVars.enabled = false
			d("|cff1c1c[Patron's Ledger]|r Addon disabled")

		elseif args == "chat on" then
			savedVars.showChatNotifications = true
			d("|c00ff00[Patron's Ledger]|r Chat notifications enabled")

		elseif args == "chat off" then
			savedVars.showChatNotifications = false
			d("|cff1c1c[Patron's Ledger]|r Chat notifications disabled")

		elseif args == "color on" then
			savedVars.colorizeLeaderboard = true
			d("|c00ff00[Patron's Ledger]|r Leaderboard colorization enabled")

		elseif args == "color off" then
			savedVars.colorizeLeaderboard = false
			d("|cff1c1c[Patron's Ledger]|r Leaderboard colorization disabled")

		elseif args == "summary on" then
			savedVars.showMatchSummary = true
			d("|c00ff00[Patron's Ledger]|r Match summary enabled")

		elseif args == "summary off" then
			savedVars.showMatchSummary = false
			d("|cff1c1c[Patron's Ledger]|r Match summary disabled")

		elseif args == "track on" then
			savedVars.trackStatistics = true
			d("|c00ff00[Patron's Ledger]|r Statistics tracking enabled")

		elseif args == "track off" then
			savedVars.trackStatistics = false
			d("|cff1c1c[Patron's Ledger]|r Statistics tracking disabled")

		elseif args == "status" then
			d("|c00ff00[Patron's Ledger]|r Current settings:")
			d("  Addon: " .. (savedVars.enabled and "|c00ff00Enabled|r" or "|cff1c1cDisabled|r"))
			d("  Chat notifications: " .. (savedVars.showChatNotifications and "|c00ff00On|r" or "|cff1c1cOff|r"))
			d("  Leaderboard colors: " .. (savedVars.colorizeLeaderboard and "|c00ff00On|r" or "|cff1c1cOff|r"))
			d("  Match summary: " .. (savedVars.showMatchSummary and "|c00ff00On|r" or "|cff1c1cOff|r"))
			d("  Track statistics: " .. (savedVars.trackStatistics and "|c00ff00On|r" or "|cff1c1cOff|r"))

		elseif args == "stats" then
			PrintStatistics()

		elseif args == "stats detailed" then
			PrintDetailedStatistics()

		elseif args == "stats opponents" then
			PrintOpponentStatistics()

		elseif args == "stats patrons" then
			PrintPatronStatistics()

		else
			d("|cff1c1c[Patron's Ledger]|r Unknown command. Type |cffffff/totlb help|r for available commands")
		end
	end

	d("|c00ff00[Patron's Ledger]|r Ranked Tribute tracker loaded. Type |cffffff/totlb help|r for commands")
end

--[[ ==================== ]]
--[[   INITIALIZATION      ]]
--[[ ==================== ]]

local function Initialize()
	-- Load saved variables
	savedVars = ZO_SavedVars:NewAccountWide("PatronsLedgerSV", 1, nil, {
		enabled = true,
		showChatNotifications = true,
		colorizeLeaderboard = true,
		trackStatistics = true,
		showMatchSummary = true,
		statistics = {
			character = {}
		},
	})

	-- Register event handlers
	EM:RegisterForEvent(NAME, EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, OnGameFlowStateChange)
	EM:RegisterForEvent(NAME, EVENT_TRIBUTE_PLAYER_TURN_STARTED, OnPlayerTurnStart)

	-- Handle both PENDING_START and event-driven polling for PENDING_END
	EM:RegisterForEvent(NAME, EVENT_TRIBUTE_LEADERBOARD_RANK_RECEIVED, function()
		if rankState == PENDING_START then
			UpdateRank(rankState, true)
		end
	end)

	EM:RegisterForEvent(NAME, EVENT_TRIBUTE_LEADERBOARD_DATA_RECEIVED, function()
		if scoreState == PENDING_START then
			UpdateScore(scoreState, true)
		elseif isPollingForScore then
			-- This is part of our event-driven polling mechanism
			CheckScoreUpdate()
		end
	end)

	-- Setup UI enhancements
	SetupUIEnhancements()

	-- Register slash commands
	RegisterSlashCommands()
end

-- Load the addon
EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, function(_, name)
	if name == NAME then
		Initialize()
		EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
	end
end)
