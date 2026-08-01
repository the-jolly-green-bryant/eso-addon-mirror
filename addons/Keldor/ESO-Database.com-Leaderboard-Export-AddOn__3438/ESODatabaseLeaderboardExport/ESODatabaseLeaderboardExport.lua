--- ESO-Database.com Leaderboard Export AddOn for http://www.eso-database.com
--- written by Keldor
---
--- Please report bugs at http://www.eso-database.com/en/contact/

----
--- Initialize global Variables
----
ESODatabaseLeaderboardExport = {}
ESODatabaseLeaderboardExport.Name = "ESODatabaseLeaderboardExport"
ESODatabaseLeaderboardExport.DisplayName = "ESO-Database.com Leaderboard Export"
ESODatabaseLeaderboardExport.AddonVersion = "1.0.13"
ESODatabaseLeaderboardExport.AddonVersionInt = 1013
ESODatabaseLeaderboardExport.SavedVariablesName = "ESODBLeaderboardExportSV"
ESODatabaseLeaderboardExport.VariableVersion = 1
ESODatabaseLeaderboardExport.DataQueueWeeklyTrialInterval = 600000 -- 10 minutes
ESODatabaseLeaderboardExport.DataQueueWeeklyChallengeInterval = 600000 -- 10 minutes
ESODatabaseLeaderboardExport.DataQueueInterval = 1200000 -- 20 minutes
ESODatabaseLeaderboardExport.DataQueueIntervalOffset = 60000 -- 1 minute
ESODatabaseLeaderboardExport.QueueInterval = 1000
ESODatabaseLeaderboardExport.DatasetInterval = 250
ESODatabaseLeaderboardExport.DatasetsPerInterval = 500
ESODatabaseLeaderboardExport.Megaserver = ""
ESODatabaseLeaderboardExport.Queue = {
	JobActive = false,
	Jobs = {},
}
ESODatabaseLeaderboardExport.ValidMegaservers = {
	"NA",
	"EU",
}
ESODatabaseLeaderboardExport.JobType = {
	TRIAL = 1,
	WEEKLY_TRIAL = 2,
	WEEKLY_CHALLENGE = 3,
	BATTLEGROUND = 4,
	TALES_OF_TRIBUTE = 5,
}
ESODatabaseLeaderboardExport.AccountWideDefault = {
	NA = {
		Trials = {},
		WeeklyTrial = {},
		WeeklyChallenge = {},
		Battlegrounds = {},
		TalesOfTribute = {},
	},
	EU = {
		Trials = {},
		WeeklyTrial = {},
		WeeklyChallenge = {},
		Battlegrounds = {},
		TalesOfTribute = {},
	},
}

----
--- Initialize local Variables
----
local svAccount -- Saved variables for account wide data


----
--- Functions
----

function ESODatabaseLeaderboardExport.QueueManager()

	-- Exit function if a job is still running
	if ESODatabaseLeaderboardExport.Queue.JobActive == true then
		return
	end

	if #ESODatabaseLeaderboardExport.Queue.Jobs > 0 then

		ESODatabaseLeaderboardExport.Queue.JobActive = true

		local jobData = ESODatabaseLeaderboardExport.Queue.Jobs[1]

		if jobData.Type == ESODatabaseLeaderboardExport.JobType.TRIAL then
			pcall(ESODatabaseLeaderboardExport.ExportTrial, jobData.Category, jobData.RaidId, jobData.ClassId)
		elseif jobData.Type == ESODatabaseLeaderboardExport.JobType.WEEKLY_TRIAL then
			pcall(ESODatabaseLeaderboardExport.ExportWeeklyTrial)
		elseif jobData.Type == ESODatabaseLeaderboardExport.JobType.WEEKLY_CHALLENGE then
			pcall(ESODatabaseLeaderboardExport.ExportWeeklyChallenge)
		elseif jobData.Type == ESODatabaseLeaderboardExport.JobType.BATTLEGROUND then
			pcall(ESODatabaseLeaderboardExport.ExportBattleground, jobData.BattlegroundType)
		elseif jobData.Type == ESODatabaseLeaderboardExport.JobType.TALES_OF_TRIBUTE then
			pcall(ESODatabaseLeaderboardExport.ExportTalesOfTribute, jobData.LeaderboardType)
		end

		table.remove(ESODatabaseLeaderboardExport.Queue.Jobs, 1)
	end
end


----
--- Weekly Trial export
----
function ESODatabaseLeaderboardExport.ExportWeeklyTrial()

	if type(svAccount[ESODatabaseLeaderboardExport.Megaserver]) == "nil" then
		svAccount[ESODatabaseLeaderboardExport.Megaserver] = {}
	end

	svAccount[ESODatabaseLeaderboardExport.Megaserver].WeeklyTrial = {}

	local _, trialRaidId = GetRaidOfTheWeekLeaderboardInfo(RAID_CATEGORY_TRIAL)
	local tableIndex = ESODBLeaderboardExportUtils:SetTableIndexByFieldValue(svAccount[ESODatabaseLeaderboardExport.Megaserver].WeeklyTrial, "RaidId", trialRaidId, {
		RaidId = trialRaidId,
	})

	-- Reset old entries
	svAccount[ESODatabaseLeaderboardExport.Megaserver].WeeklyTrial[tableIndex] = {
		RaidId = trialRaidId,
		Timestamp = GetTimeStamp(),
		Scores = {},
		ExportComplete = false,
	}

	local numEntries = GetNumTrialOfTheWeekLeaderboardEntries()
	if numEntries > 0 then
		ESODatabaseLeaderboardExport.BulkExportWeeklyTrialData(tableIndex, 1, numEntries, ESODatabaseLeaderboardExport.Name .. "ExportWeeklyTrial")
	else
		ESODatabaseLeaderboardExport.Queue.JobActive = false
	end
end

function ESODatabaseLeaderboardExport.BulkExportWeeklyTrialData(tableIndex, index, numEntries, runnerName)

	local maxIndex = index + ESODatabaseLeaderboardExport.DatasetsPerInterval

	if maxIndex > numEntries then
		maxIndex = numEntries
	end

	for i = index, maxIndex, 1 do
		ESODatabaseLeaderboardExport.ExportWeeklyTrialEntry(i, tableIndex)
	end

	-- Set the next start index
	index = (maxIndex + 1)

	-- No more entries left, finish job
	if maxIndex >= numEntries then
		svAccount[ESODatabaseLeaderboardExport.Megaserver].WeeklyTrial[tableIndex].ExportComplete = true
		ESODatabaseLeaderboardExport.Queue.JobActive = false
	else
		EVENT_MANAGER:RegisterForUpdate(runnerName, ESODatabaseLeaderboardExport.DatasetInterval, function()
			EVENT_MANAGER:UnregisterForUpdate(runnerName)
			index = ESODatabaseLeaderboardExport.BulkExportWeeklyTrialData(tableIndex, index, numEntries, runnerName)
		end)
	end

	return index
end

function ESODatabaseLeaderboardExport.ExportWeeklyTrialEntry(entryIndex, tableIndex)

	local ranking, charName, score, rowClassId, allianceId, displayName = GetTrialOfTheWeekLeaderboardEntryInfo(entryIndex)
	if ranking > 0 then
		table.insert(svAccount[ESODatabaseLeaderboardExport.Megaserver].WeeklyTrial[tableIndex].Scores, {
			UserId = displayName,
			CharName = charName,
			ClassId = rowClassId,
			AllianceId = allianceId,
			Score = score,
		})
	end
end


----
--- Weekly Challenge export
----
function ESODatabaseLeaderboardExport.ExportWeeklyChallenge()

	if type(svAccount[ESODatabaseLeaderboardExport.Megaserver]) == "nil" then
		svAccount[ESODatabaseLeaderboardExport.Megaserver] = {}
	end

	svAccount[ESODatabaseLeaderboardExport.Megaserver].WeeklyChallenge = {}

	local _, trialRaidId = GetRaidOfTheWeekLeaderboardInfo(RAID_CATEGORY_CHALLENGE)

	local numClasses = GetNumClasses()
	if numClasses > 0 then
		for classIndex = 1, numClasses do

			local classId = GetClassInfo(classIndex)

			local uniqueId = trialRaidId .. "-" .. classId
			local tableIndex = ESODBLeaderboardExportUtils:SetTableIndexByFieldValue(svAccount[ESODatabaseLeaderboardExport.Megaserver].WeeklyChallenge, "UniqueId", uniqueId, {
				UniqueId = uniqueId,
				RaidId = trialRaidId,
				ClassId = classId,
			})

			-- Reset old entries
			svAccount[ESODatabaseLeaderboardExport.Megaserver].WeeklyChallenge[tableIndex] = {
				UniqueId = uniqueId,
				RaidId = trialRaidId,
				ClassId = classId,
				Timestamp = GetTimeStamp(),
				Scores = {},
				ExportComplete = false,
			}

			local numEntries = GetNumChallengeOfTheWeekLeaderboardEntries(classId)
			if numEntries > 0 then
				ESODatabaseLeaderboardExport.BulkExportWeeklyChallengeData(classId, tableIndex, 1, numEntries, ESODatabaseLeaderboardExport.Name .. "ExportWeeklyChallengeData")
			else
				ESODatabaseLeaderboardExport.Queue.JobActive = false
			end
		end
	end
end

function ESODatabaseLeaderboardExport.BulkExportWeeklyChallengeData(classId, tableIndex, index, numEntries, runnerName)

	local maxIndex = index + ESODatabaseLeaderboardExport.DatasetsPerInterval

	if maxIndex > numEntries then
		maxIndex = numEntries
	end

	for i = index, maxIndex, 1 do
		ESODatabaseLeaderboardExport.ExportWeeklyChallengeEntry(classId, i, tableIndex)
	end

	-- Set the next start index
	index = (maxIndex + 1)

	-- No more entries left, finish job
	if maxIndex >= numEntries then
		svAccount[ESODatabaseLeaderboardExport.Megaserver].WeeklyChallenge[tableIndex].ExportComplete = true
		ESODatabaseLeaderboardExport.Queue.JobActive = false
	else
		EVENT_MANAGER:RegisterForUpdate(runnerName, ESODatabaseLeaderboardExport.DatasetInterval, function()
			EVENT_MANAGER:UnregisterForUpdate(runnerName)
			index = ESODatabaseLeaderboardExport.BulkExportWeeklyChallengeData(classId, tableIndex, index, numEntries, runnerName)
		end)
	end

	return index
end

function ESODatabaseLeaderboardExport.ExportWeeklyChallengeEntry(classId, entryIndex, tableIndex)

	local ranking, charName, score, rowClassId, allianceId, displayName = GetChallengeOfTheWeekLeaderboardEntryInfo(classId, entryIndex)
	if ranking > 0 then
		table.insert(svAccount[ESODatabaseLeaderboardExport.Megaserver].WeeklyChallenge[tableIndex].Scores, {
			UserId = displayName,
			CharName = charName,
			ClassId = rowClassId,
			AllianceId = allianceId,
			Score = score,
		})
	end
end


----
--- Trial export
----
function ESODatabaseLeaderboardExport.ExportTrial(category, raidId, classId)

	if type(svAccount[ESODatabaseLeaderboardExport.Megaserver]) == "nil" then
		svAccount[ESODatabaseLeaderboardExport.Megaserver] = {}
	end
	if type(svAccount[ESODatabaseLeaderboardExport.Megaserver].Trials) == "nil" then
		svAccount[ESODatabaseLeaderboardExport.Megaserver].Trials = {}
	end

	if category == RAID_CATEGORY_CHALLENGE then
		ESODatabaseLeaderboardExport.ExportChallengeTrial(raidId, classId)
	else
		ESODatabaseLeaderboardExport.ExportNormalTrial(raidId)
	end
end

function ESODatabaseLeaderboardExport.ExportNormalTrial(raidId)

	local uniqueTrialId = RAID_CATEGORY_TRIAL .. "-" .. raidId
	local tableIndex = ESODBLeaderboardExportUtils:SetTableIndexByFieldValue(svAccount[ESODatabaseLeaderboardExport.Megaserver].Trials, "UniqueId", uniqueTrialId, {
		UniqueId = uniqueTrialId,
	})

	-- Reset old entries
	svAccount[ESODatabaseLeaderboardExport.Megaserver].Trials[tableIndex] = {
		UniqueId = uniqueTrialId,
		RaidId = raidId,
		RaidCategory = RAID_CATEGORY_TRIAL,
		Timestamp = GetTimeStamp(),
		Scores = {},
		ExportComplete = false,
	}

	local numEntries = GetNumTrialLeaderboardEntries(raidId)
	if numEntries > 0 then
		ESODatabaseLeaderboardExport.BulkExportNormalTrialData(raidId, tableIndex, 1, numEntries, ESODatabaseLeaderboardExport.Name .. "ExportNormalTrial")
	else
		ESODatabaseLeaderboardExport.Queue.JobActive = false
	end
end

function ESODatabaseLeaderboardExport.BulkExportNormalTrialData(raidId, tableIndex, index, numEntries, runnerName)

	local maxIndex = index + ESODatabaseLeaderboardExport.DatasetsPerInterval

	if maxIndex > numEntries then
		maxIndex = numEntries
	end

	for i = index, maxIndex, 1 do
		ESODatabaseLeaderboardExport.ExportNormalTrialEntry(raidId, i, tableIndex)
	end

	-- Set the next start index
	index = (maxIndex + 1)

	-- No more entries left, finish job
	if maxIndex >= numEntries then
		svAccount[ESODatabaseLeaderboardExport.Megaserver].Trials[tableIndex].ExportComplete = true
		ESODatabaseLeaderboardExport.Queue.JobActive = false
	else
		EVENT_MANAGER:RegisterForUpdate(runnerName, ESODatabaseLeaderboardExport.DatasetInterval, function()
			EVENT_MANAGER:UnregisterForUpdate(runnerName)
			index = ESODatabaseLeaderboardExport.BulkExportNormalTrialData(raidId, tableIndex, index, numEntries, runnerName)
		end)
	end

	return index
end

function ESODatabaseLeaderboardExport.ExportNormalTrialEntry(raidId, entryIndex, tableIndex)

	local ranking, charName, score, rowClassId, allianceId, displayName = GetTrialLeaderboardEntryInfo(raidId, entryIndex)
	if ranking > 0 then
		table.insert(svAccount[ESODatabaseLeaderboardExport.Megaserver].Trials[tableIndex].Scores, {
			UserId = displayName,
			CharName = charName,
			ClassId = rowClassId,
			AllianceId = allianceId,
			Score = score,
		})
	end
end

function ESODatabaseLeaderboardExport.ExportChallengeTrial(raidId, classId)

	local uniqueTrialId = RAID_CATEGORY_CHALLENGE .. "-" .. raidId .. "-" .. classId
	local tableIndex = ESODBLeaderboardExportUtils:SetTableIndexByFieldValue(svAccount[ESODatabaseLeaderboardExport.Megaserver].Trials, "UniqueId", uniqueTrialId, {
		UniqueId = uniqueTrialId,
	})

	-- Reset old entries
	svAccount[ESODatabaseLeaderboardExport.Megaserver].Trials[tableIndex] = {
		UniqueId = uniqueTrialId,
		RaidId = raidId,
		ClassId = classId,
		RaidCategory = RAID_CATEGORY_TRIAL,
		Timestamp = GetTimeStamp(),
		Scores = {},
		ExportComplete = false,
	}

	local numEntries = GetNumChallengeLeaderboardEntries(raidId, classId)
	if numEntries > 0 then
		ESODatabaseLeaderboardExport.BulkExportChallengeTrialData(raidId, classId, tableIndex, 1, numEntries, ESODatabaseLeaderboardExport.Name .. "ExportChallengeTrial")
	else
		ESODatabaseLeaderboardExport.Queue.JobActive = false
	end
end

function ESODatabaseLeaderboardExport.BulkExportChallengeTrialData(raidId, classId, tableIndex, index, numEntries, runnerName)

	local maxIndex = index + ESODatabaseLeaderboardExport.DatasetsPerInterval

	if maxIndex > numEntries then
		maxIndex = numEntries
	end

	for i = index, maxIndex, 1 do
		ESODatabaseLeaderboardExport.ExportChallengeTrialEntry(raidId, classId, i, tableIndex)
	end

	-- Set the next start index
	index = (maxIndex + 1)

	-- No more entries left, finish job
	if maxIndex >= numEntries then
		svAccount[ESODatabaseLeaderboardExport.Megaserver].Trials[tableIndex].ExportComplete = true
		ESODatabaseLeaderboardExport.Queue.JobActive = false
	else
		EVENT_MANAGER:RegisterForUpdate(runnerName, ESODatabaseLeaderboardExport.DatasetInterval, function()
			EVENT_MANAGER:UnregisterForUpdate(runnerName)
			index = ESODatabaseLeaderboardExport.BulkExportChallengeTrialData(raidId, classId, tableIndex, index, numEntries, runnerName)
		end)
	end

	return index
end

function ESODatabaseLeaderboardExport.ExportChallengeTrialEntry(raidId, classId, entryIndex, tableIndex)

	local ranking, charName, score, rowClassId, allianceId, displayName = GetChallengeLeaderboardEntryInfo(raidId, classId, entryIndex)
	if ranking > 0 then
		table.insert(svAccount[ESODatabaseLeaderboardExport.Megaserver].Trials[tableIndex].Scores, {
			UserId = displayName,
			CharName = charName,
			ClassId = rowClassId,
			AllianceId = allianceId,
			Score = score,
		})
	end
end


----
--- Battleground export
----
function ESODatabaseLeaderboardExport.ExportBattleground(battlegroundType)

	if type(svAccount[ESODatabaseLeaderboardExport.Megaserver]) == "nil" then
		svAccount[ESODatabaseLeaderboardExport.Megaserver] = {}
	end
	if type(svAccount[ESODatabaseLeaderboardExport.Megaserver].Battlegrounds) == "nil" then
		svAccount[ESODatabaseLeaderboardExport.Megaserver].Battlegrounds = {}
	end

	local tableIndex = ESODBLeaderboardExportUtils:SetTableIndexByFieldValue(svAccount[ESODatabaseLeaderboardExport.Megaserver].Battlegrounds, "UniqueId", battlegroundType, {
		UniqueId = battlegroundType,
	})

	-- Reset old entries
	svAccount[ESODatabaseLeaderboardExport.Megaserver].Battlegrounds[tableIndex] = {
		UniqueId = battlegroundType,
		BattlegroundType = battlegroundType,
		Timestamp = GetTimeStamp(),
		Scores = {},
		ExportComplete = false,
	}

	local numEntries = GetNumBattlegroundLeaderboardEntries(battlegroundType)
	if numEntries > 0 then
		ESODatabaseLeaderboardExport.BulkExportBattlegroundData(battlegroundType, tableIndex, 1, numEntries, ESODatabaseLeaderboardExport.Name .. "ExportBattleground")
	else
		ESODatabaseLeaderboardExport.Queue.JobActive = false
	end
end

function ESODatabaseLeaderboardExport.BulkExportBattlegroundData(battlegroundType, tableIndex, index, numEntries, runnerName)

	local maxIndex = index + ESODatabaseLeaderboardExport.DatasetsPerInterval

	if maxIndex > numEntries then
		maxIndex = numEntries
	end

	for i = index, maxIndex, 1 do
		ESODatabaseLeaderboardExport.ExportBattlegroundEntry(battlegroundType, i, tableIndex)
	end

	-- Set the next start index
	index = (maxIndex + 1)

	-- No more entries left, finish job
	if maxIndex >= numEntries then
		svAccount[ESODatabaseLeaderboardExport.Megaserver].Battlegrounds[tableIndex].ExportComplete = true
		ESODatabaseLeaderboardExport.Queue.JobActive = false
	else
		EVENT_MANAGER:RegisterForUpdate(runnerName, ESODatabaseLeaderboardExport.DatasetInterval, function()
			EVENT_MANAGER:UnregisterForUpdate(runnerName)
			index = ESODatabaseLeaderboardExport.BulkExportBattlegroundData(battlegroundType, tableIndex, index, numEntries, runnerName)
		end)
	end

	return index
end

function ESODatabaseLeaderboardExport.ExportBattlegroundEntry(battlegroundType, entryIndex, tableIndex)

	local rank, displayName, characterName, score = GetBattlegroundLeaderboardEntryInfo(battlegroundType, entryIndex)
	if rank > 0 then
		table.insert(svAccount[ESODatabaseLeaderboardExport.Megaserver].Battlegrounds[tableIndex].Scores, {
			CharName = characterName,
			Score = score,
			UserId = displayName,
		})
	end
end


----
--- Tales of Tribute export
----
function ESODatabaseLeaderboardExport.ExportTalesOfTribute(leaderboardType)

	if type(svAccount[ESODatabaseLeaderboardExport.Megaserver]) == "nil" then
		svAccount[ESODatabaseLeaderboardExport.Megaserver] = {}
	end
	if type(svAccount[ESODatabaseLeaderboardExport.Megaserver].TalesOfTribute) == "nil" then
		svAccount[ESODatabaseLeaderboardExport.Megaserver].TalesOfTribute = {}
	end

	local tableIndex = ESODBLeaderboardExportUtils:SetTableIndexByFieldValue(svAccount[ESODatabaseLeaderboardExport.Megaserver].TalesOfTribute, "UniqueId", leaderboardType, {
		UniqueId = leaderboardType,
	})

	-- Reset old entries
	svAccount[ESODatabaseLeaderboardExport.Megaserver].TalesOfTribute[tableIndex] = {
		UniqueId = leaderboardType,
		LeaderboardType = leaderboardType,
		Timestamp = GetTimeStamp(),
		Scores = {},
		ExportComplete = false,
	}

	local numEntries = GetNumTributeLeaderboardEntries(leaderboardType)
	if numEntries > 0 then
		ESODatabaseLeaderboardExport.BulkExportTalesOfTributeData(leaderboardType, tableIndex, 1, numEntries, ESODatabaseLeaderboardExport.Name .. "ExportTalesOfTribute")
	else
		ESODatabaseLeaderboardExport.Queue.JobActive = false
	end
end

function ESODatabaseLeaderboardExport.BulkExportTalesOfTributeData(leaderboardType, tableIndex, index, numEntries, runnerName)

	local maxIndex = index + ESODatabaseLeaderboardExport.DatasetsPerInterval

	if maxIndex > numEntries then
		maxIndex = numEntries
	end

	for i = index, maxIndex, 1 do
		ESODatabaseLeaderboardExport.ExportTalesOfTributeEntry(leaderboardType, i, tableIndex)
	end

	-- Set the next start index
	index = (maxIndex + 1)

	-- No more entries left, finish job
	if maxIndex >= numEntries then
		svAccount[ESODatabaseLeaderboardExport.Megaserver].TalesOfTribute[tableIndex].ExportComplete = true
		ESODatabaseLeaderboardExport.Queue.JobActive = false
	else
		EVENT_MANAGER:RegisterForUpdate(runnerName, ESODatabaseLeaderboardExport.DatasetInterval, function()
			EVENT_MANAGER:UnregisterForUpdate(runnerName)
			index = ESODatabaseLeaderboardExport.BulkExportTalesOfTributeData(leaderboardType, tableIndex, index, numEntries, runnerName)
		end)
	end

	return index
end

function ESODatabaseLeaderboardExport.ExportTalesOfTributeEntry(leaderboardType, entryIndex, tableIndex)

	local rank, displayName, characterName, score = GetTributeLeaderboardEntryInfo(leaderboardType, entryIndex)
	if rank > 0 then
		table.insert(svAccount[ESODatabaseLeaderboardExport.Megaserver].TalesOfTribute[tableIndex].Scores, {
			CharName = characterName,
			Score = score,
			UserId = displayName,
		})
	end
end


----
--- Event callbacks
----
function ESODatabaseLeaderboardExport.ExportTrialData(_, raidCategory, raidId, classId)

	if QueryRaidLeaderboardData(raidCategory, raidId, classId) == LEADERBOARD_DATA_RESPONSE_PENDING then
		return
	end

	local _, trialRaidId = GetRaidOfTheWeekLeaderboardInfo(RAID_CATEGORY_CHALLENGE)

	if (raidCategory == RAID_CATEGORY_CHALLENGE and trialRaidId == raidId) or (raidCategory == RAID_CATEGORY_TRIAL and raidId == 0) then
		table.insert(ESODatabaseLeaderboardExport.Queue.Jobs, {
			Type = ESODatabaseLeaderboardExport.JobType.WEEKLY_CHALLENGE,
		})
	else
		table.insert(ESODatabaseLeaderboardExport.Queue.Jobs, {
			Type = ESODatabaseLeaderboardExport.JobType.TRIAL,
			Category = raidCategory,
			RaidId = raidId,
			ClassId = classId,
		})
	end
end

function ESODatabaseLeaderboardExport.ExportBattlegroundData(_, battlegroundType)

	if QueryBattlegroundLeaderboardData(battlegroundType) == LEADERBOARD_DATA_RESPONSE_PENDING then
		return
	end

	-- Add queried data to job queue
	table.insert(ESODatabaseLeaderboardExport.Queue.Jobs, {
		Type = ESODatabaseLeaderboardExport.JobType.BATTLEGROUND,
		BattlegroundType = battlegroundType,
	})
end

function ESODatabaseLeaderboardExport.ExportTalesOfTributeData(_, leaderboardType)

	if QueryTributeLeaderboardData(leaderboardType) == LEADERBOARD_DATA_RESPONSE_PENDING then
		return
	end

	-- Add queried data to job queue
	table.insert(ESODatabaseLeaderboardExport.Queue.Jobs, {
		Type = ESODatabaseLeaderboardExport.JobType.TALES_OF_TRIBUTE,
		LeaderboardType = leaderboardType,
	})
end

function ESODatabaseLeaderboardExport.QueryTrials()

	local numRaids = GetNumRaidLeaderboards(RAID_CATEGORY_TRIAL)
	if numRaids > 0 then

		local offset = 5000
		local currentOffset = offset

		for raidId in ZO_GetNextRaidLeaderboardIdIter(RAID_CATEGORY_TRIAL) do
			EVENT_MANAGER:RegisterForUpdate(ESODatabaseLeaderboardExport.Name .. "TrialQueue" .. raidId, currentOffset, function()
				ESODatabaseLeaderboardExport.ExportTrialData(nil, RAID_CATEGORY_TRIAL, raidId, 0)
				EVENT_MANAGER:UnregisterForUpdate(ESODatabaseLeaderboardExport.Name .. "TrialQueue" .. raidId)
			end)

			currentOffset = currentOffset + offset
		end
	end

	numRaids = GetNumRaidLeaderboards(RAID_CATEGORY_CHALLENGE)
	if numRaids > 0 then

		local offset = 5000
		local currentOffset = offset

		for raidId in ZO_GetNextRaidLeaderboardIdIter(RAID_CATEGORY_CHALLENGE) do

			local numClasses = GetNumClasses()
			if numClasses > 0 then
				for classIndex = 1, numClasses do

					local classId = GetClassInfo(classIndex)

					EVENT_MANAGER:RegisterForUpdate(ESODatabaseLeaderboardExport.Name .. "TrialQueueChallenge" .. raidId .. "-" .. classId, currentOffset, function()
						ESODatabaseLeaderboardExport.ExportTrialData(nil, RAID_CATEGORY_CHALLENGE, raidId, classId)
						EVENT_MANAGER:UnregisterForUpdate(ESODatabaseLeaderboardExport.Name .. "TrialQueueChallenge" .. raidId .. "-" .. classId)
					end)

					currentOffset = currentOffset + offset
				end
			end
		end
	end
end

function ESODatabaseLeaderboardExport.QueryBattlegrounds()

	local function GetNextBattlegroundLeaderboardTypeIter(state, lastBattlegroundLeaderboardType)
		return GetNextBattlegroundLeaderboardType(lastBattlegroundLeaderboardType)
	end

	for battlegroundType in GetNextBattlegroundLeaderboardTypeIter do
		ESODatabaseLeaderboardExport.ExportBattlegroundData(nil, battlegroundType)
	end
end

function ESODatabaseLeaderboardExport.QueryTalesOfTribute()

	local function GetNextTributeLeaderboardTypeIter(state, lastTributeLeaderboardType)
		return GetNextTributeLeaderboardType(lastTributeLeaderboardType)
	end

	for tributeLeaderboardType in GetNextTributeLeaderboardTypeIter do
		ESODatabaseLeaderboardExport.ExportTalesOfTributeData(nil, tributeLeaderboardType)
	end
end

function ESODatabaseLeaderboardExport.QueueTrialOfTheWeek()

	-- Add queried data to job queue
	table.insert(ESODatabaseLeaderboardExport.Queue.Jobs, {
		Type = ESODatabaseLeaderboardExport.JobType.WEEKLY_TRIAL,
	})
end

function ESODatabaseLeaderboardExport.QueueChallengeOfTheWeek()

	-- Add queried data to job queue
	table.insert(ESODatabaseLeaderboardExport.Queue.Jobs, {
		Type = ESODatabaseLeaderboardExport.JobType.WEEKLY_CHALLENGE,
	})
end


----
--- OnAddOnLoaded
----
function ESODatabaseLeaderboardExport.OnAddOnLoaded(_, addonName)

	if addonName ~= ESODatabaseLeaderboardExport.Name then return end

	EVENT_MANAGER:UnregisterForEvent(ESODatabaseLeaderboardExport.Name, EVENT_ADD_ON_LOADED)

    -- Register saved variables
	svAccount = ZO_SavedVars:NewAccountWide(ESODatabaseLeaderboardExport.SavedVariablesName, ESODatabaseLeaderboardExport.VariableVersion, nil, ESODatabaseLeaderboardExport.AccountWideDefault)

	-- Set and check megaserver
	ESODatabaseLeaderboardExport.Megaserver = ESODBLeaderboardExportUtils:GetMegaserver()
	if ESODBLeaderboardExportUtils:IsValidMegaserver(ESODatabaseLeaderboardExport.Megaserver, ESODatabaseLeaderboardExport.ValidMegaservers) == false then
		return
	end


	----
	---  Register Events
	----
	EVENT_MANAGER:RegisterForEvent(ESODatabaseLeaderboardExport.Name, EVENT_RAID_LEADERBOARD_DATA_RECEIVED, ESODatabaseLeaderboardExport.ExportTrialData)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseLeaderboardExport.Name, EVENT_BATTLEGROUND_LEADERBOARD_DATA_RECEIVED, ESODatabaseLeaderboardExport.ExportBattlegroundData)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseLeaderboardExport.Name, EVENT_TRIBUTE_LEADERBOARD_DATA_RECEIVED, ESODatabaseLeaderboardExport.ExportTalesOfTributeData)

	----
	---  Register updates
	----
	EVENT_MANAGER:RegisterForUpdate(ESODatabaseLeaderboardExport.Name .. "QueueTrialOfTheWeek", ESODatabaseLeaderboardExport.DataQueueWeeklyTrialInterval, ESODatabaseLeaderboardExport.QueueTrialOfTheWeek)
	EVENT_MANAGER:RegisterForUpdate(ESODatabaseLeaderboardExport.Name .. "QueueChallengeOfTheWeek", ESODatabaseLeaderboardExport.DataQueueWeeklyChallengeInterval, ESODatabaseLeaderboardExport.QueueChallengeOfTheWeek)
	EVENT_MANAGER:RegisterForUpdate(ESODatabaseLeaderboardExport.Name .. "QueueTrialsInterval", ESODatabaseLeaderboardExport.DataQueueInterval, ESODatabaseLeaderboardExport.QueryTrials)
	EVENT_MANAGER:RegisterForUpdate(ESODatabaseLeaderboardExport.Name .. "QueueBattlegroundsInterval", (ESODatabaseLeaderboardExport.DataQueueInterval + ESODatabaseLeaderboardExport.DataQueueIntervalOffset), ESODatabaseLeaderboardExport.QueryBattlegrounds)
	EVENT_MANAGER:RegisterForUpdate(ESODatabaseLeaderboardExport.Name .. "QueueTalesOfTributeInterval", (ESODatabaseLeaderboardExport.DataQueueInterval + ESODatabaseLeaderboardExport.DataQueueIntervalOffset), ESODatabaseLeaderboardExport.QueryTalesOfTribute)
	EVENT_MANAGER:RegisterForUpdate(ESODatabaseLeaderboardExport.Name .. "QueueManager", ESODatabaseLeaderboardExport.QueueInterval, ESODatabaseLeaderboardExport.QueueManager)
end


----
--- AddOn init
----
EVENT_MANAGER:RegisterForEvent(ESODatabaseLeaderboardExport.Name, EVENT_ADD_ON_LOADED, ESODatabaseLeaderboardExport.OnAddOnLoaded)
