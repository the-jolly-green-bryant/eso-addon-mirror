--- ESO-Database.com Export AddOn for http://www.eso-database.com
--- written by Keldor
---
--- Please report bugs at http://www.eso-database.com/en/contact/

----
--- Initialize global Variables
----
ESODatabaseExport = {}
ESODatabaseExport.Name = "ESODatabaseExport"
ESODatabaseExport.DisplayName = "ESO-Database.com Export"
ESODatabaseExport.SavedVariablesName = "ESODBDataExportV4"
ESODatabaseExport.AddonVersion = "4.6.18"
ESODatabaseExport.AddonVersionInt = 4618
ESODatabaseExport.VariableVersion = 22
ESODatabaseExport.AccountWideVariableVersion = 23
ESODatabaseExport.NumKeepStats = 12
ESODatabaseExport.SessionTimestamp = 0

ESODatabaseExport.InitialExportInterval = 100
ESODatabaseExport.InitialExportItemSetCollectionDelay = 5
ESODatabaseExport.InitialExportAntiquityDelay = 5
ESODatabaseExport.InitialExportAchievementsDelay = 5
ESODatabaseExport.DataExportDelay = 2000
ESODatabaseExport.ExportGuildMembersStartDelay = 3200
ESODatabaseExport.ExportGuildMembersRunInterval = 150
ESODatabaseExport.ExportGuildMembersPerRun = 50
ESODatabaseExport.ScanInterval = 60000 -- 1 Minute
ESODatabaseExport.ScanGuildInterval = 1800000 -- 30 Min

ESODatabaseExport.Default = {
	Stats = {}
}
ESODatabaseExport.AccountWideDefault = {
	Guilds = {},
	TimedActivities = {},
	Currencies = {
		Bank = {},
		Account = {},
	},
	Unknown = {
		Recipes = {},
	},
}
ESODatabaseExport.GlobalStore = {
	Lang = "",
	FenceSellsUsed = 0,
	FenceLaundersUsed = 0,
	DisableLootTracking = false,
	CurrentLockPickDifficulty = "",
	LastCompleteQuestRepeatType = "",
	MailCache = {
		GuildStore = {},
		WorthyReward = {},
	},
	GuildMemberExportQueue = {},
	InitialExportJobActive = false,
	InitialExportJobs = {},
	InitialDataExportStartSeconds = 0,
	Fishing = {
		LastAction = nil,
		InteractableName = nil,
		FishingActive = false,
		ReelIn = GetString(_G.SI_GAMECAMERAACTIONTYPE17),
		StartTimeStamp = 0,
	},
}


----
--- Initialize local Variables
----
local sv -- Saved variables
local ssv -- Saved variables stats for current game session
local svAccount -- Saved variables for account wide data


----
--- Export Functions
----
function ESODatabaseExport.InitSessionStatEntry()

	ESODatabaseExport.SessionTimestamp = GetTimeStamp()

	table.insert(sv.Stats, ESODBExportStats:GetDefault(ESODatabaseExport.SessionTimestamp))

	sv.Stats = ESODBExportStats:CleanupStatsTable(sv.Stats, ESODatabaseExport.NumKeepStats)
	ssv = sv.Stats[1]
end

---
--- This function ensures that all tables created in case
--- an event fired before the initial export has completed.
---
function ESODatabaseExport.InitSavedVariableTables()
	sv.Achievements = {}
	sv.Antiquities = {}
	sv.CharStats = {}
	sv.Collectibles = {}
	sv.Guilds = {}
	sv.ItemSetCollectionPieces = {}
	sv.LoreBooks = {}
	sv.LoreBookCollections = {}
	sv.Recipes = {}
	sv.ResearchTimers = {}
	sv.SkillLines = {}
	sv.TalesOfTribute = {}
	sv.Titles = {}
	sv.Tradeskills = {}
	sv.Quests = {}
	sv.EndlessDungeon = {}
	sv.Currencies = {}
	sv.Scribing = {
		Grimoires = {},
		Scripts = {},
	}
end

function ESODatabaseExport.ClearUnknownValues()

	svAccount.Unknown.Recipes = {}
end

function ESODatabaseExport.InitStatisticsDefaultValues()

	local _, sellsUsed = GetFenceSellTransactionInfo()
	local _, laundersUsed = GetFenceLaunderTransactionInfo()

	ESODatabaseExport.GlobalStore.FenceSellsUsed = sellsUsed
	ESODatabaseExport.GlobalStore.FenceLaundersUsed = laundersUsed
end

function ESODatabaseExport.ExportMetaData()

	local characterName, megaserver = ESODBExportUtils:GetCharacterInfo()

	sv.Id = tonumber(GetCurrentCharacterId())
	sv.Timestamp = ESODatabaseExport.SessionTimestamp
	sv.AddonVersion = ESODatabaseExport.AddonVersionInt
	svAccount.AddonVersion = ESODatabaseExport.AddonVersionInt
	sv.Lang = ESODatabaseExport.GlobalStore.Lang
    sv.Megaserver = megaserver
	sv.CharacterName = characterName
	sv.Gender = GetUnitGender("player")
	sv.RaceId = GetUnitRaceId("player")
	sv.ClassId = GetUnitClassId("player")
	sv.AllianceId = GetUnitAlliance("player")
end

function ESODatabaseExport.ExportCharacterBaseInfo()

	local _, isEmperor = GetAchievementCriterion(935, 1)

	sv.Title = GetUnitTitle("player")
	sv.Emperor = isEmperor
	sv.AchievementPoints = GetEarnedAchievementPoints()
	sv.AvailableSkillPoints = GetAvailableSkillPoints()
	sv.AlliancePoints = GetCarriedCurrencyAmount(CURT_ALLIANCE_POINTS)
	sv.ZoneId = GetZoneId(GetCurrentMapZoneIndex())

	ssv.Playtime = GetSecondsPlayed()

	ESODatabaseExport.ExportMundus()
end

function ESODatabaseExport.ExportMundus()

	sv.MundusAbilityId = nil

	local numBuffs = GetNumBuffs("player")
	for i = 1, numBuffs do
		local _, _, _, _, _, _, _, _, _, _, id = GetUnitBuffInfo("player", i)
		if ESODBExportUtils:TableContains(ESODBExportConst.MundusAbilityIds, id) == true then
			sv.MundusAbilityId = id
		end
	end
end

function ESODatabaseExport.ExportJusticeInfo()
	sv.Bounty = GetFullBountyPayoffAmount()
	sv.InfamyLevel = GetInfamyLevel(GetInfamy())
end

function ESODatabaseExport.ExportPrimaryHouse()

	local primaryHouse = GetHousingPrimaryHouse()
	if primaryHouse > 0 then
		sv.PrimaryResidence = GetCollectibleIdForHouse(primaryHouse)
	end
end

function ESODatabaseExport.EventAntiquityDiggingGameOver(_, gameOverFlags)

	if gameOverFlags == ANTIQUITY_DIGGING_GAME_OVER_FLAGS_VICTORY then
		ssv.Antiquity.DiggingVictory = ssv.Antiquity.DiggingVictory + 1
		ssv.Antiquity.DiggingTotal = ssv.Antiquity.DiggingTotal + 1

	elseif gameOverFlags == ANTIQUITY_DIGGING_GAME_OVER_FLAGS_ANTIQUITY_BROKEN then
		ssv.Antiquity.DiggingAntiquityBroken = ssv.Antiquity.DiggingAntiquityBroken + 1
		ssv.Antiquity.DiggingTotal = ssv.Antiquity.DiggingTotal + 1

	elseif gameOverFlags == ANTIQUITY_DIGGING_GAME_OVER_FLAGS_OUT_OF_TIME then
		ssv.Antiquity.DiggingOutOfTime = ssv.Antiquity.DiggingOutOfTime + 1
		ssv.Antiquity.DiggingTotal = ssv.Antiquity.DiggingTotal + 1
	end
end

function ESODatabaseExport.EventAntiquityDiggingBonusLootUnearthed()
	ssv.Antiquity.DiggingBonusLootUnearthed = ssv.Antiquity.DiggingBonusLootUnearthed + 1
end

function ESODatabaseExport.EventAntiquityDiggingAntiquityUnearthed()

	local antiquityId = GetTrackedAntiquityId()
	local difficulty = GetAntiquityDifficulty(antiquityId)
	local difficultyIndex = ESODBExportUtils:GetAntiquityDifficultyIndex(difficulty)

	if difficultyIndex ~= "" then
		ssv.AntiquityDifficulty[difficultyIndex] = ssv.AntiquityDifficulty[difficultyIndex] + 1
	end
end

function ESODatabaseExport.EventAntiquityLeadAcquired()
	ssv.Antiquity.LeadAcquired = ssv.Antiquity.LeadAcquired + 1
end

function ESODatabaseExport.EventCollectibleUseResult(_, result)

	if result == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then

		local actionSlotIndex = GetCurrentQuickslot()
		local actionSlotItemLink = GetSlotItemLink(actionSlotIndex)
		local collectibleId = GetCollectibleIdFromLink(actionSlotItemLink)

		-- Antiquarian's Eye
		if collectibleId == GetAntiquityScryingToolCollectibleId() then
			ssv.Antiquity.AntiquariansEyeUsed = ssv.Antiquity.AntiquariansEyeUsed + 1
		end
	end
end

function ESODatabaseExport.EventAntiquityDigSitesOnMap(_, antiquityId)

	local difficulty = GetAntiquityDifficulty(antiquityId)
	local difficultyIndex = ESODBExportUtils:GetAntiquityDifficultyIndex(difficulty)

	if difficultyIndex ~= "" then
		ssv.AntiquityScryingDifficulty[difficultyIndex] = ssv.AntiquityScryingDifficulty[difficultyIndex] + 1
	end

	ssv.Antiquity.ScryingTotal = ssv.Antiquity.ScryingTotal + 1
end

function ESODatabaseExport.EventAntiquityUpdated(_, antiquityId)
	ESODatabaseExport.ExportAntiquityInfo(antiquityId)
end

function ESODatabaseExport.EventItemSetCollectionUpdated(_, itemSetId)
	ESODatabaseExport.ExportItemSetCollectionSet(itemSetId)
end

function ESODatabaseExport.EventTimedActivityProgressUpdated(_, index, _, _, complete)

	local timedActivityType = GetTimedActivityType(index)
	if complete == true then
		if timedActivityType == TIMED_ACTIVITY_TYPE_DAILY then
			ssv.TimedActivities.Daily = ssv.TimedActivities.Daily + 1
		elseif timedActivityType == TIMED_ACTIVITY_TYPE_WEEKLY then
			ssv.TimedActivities.Weekly = ssv.TimedActivities.Weekly + 1
		end
	end
end

function ESODatabaseExport.EventTributeInviteAccepted()
	ssv.TalesOfTribute.InvitesAccepted = ssv.TalesOfTribute.InvitesAccepted + 1
end

function ESODatabaseExport.EventTributeInviteDeclined()
	ssv.TalesOfTribute.InvitesDeclined = ssv.TalesOfTribute.InvitesDeclined + 1
end

function ESODatabaseExport.EventTributeInviteSent()
	ssv.TalesOfTribute.InvitesSent = ssv.TalesOfTribute.InvitesSent + 1
end

function ESODatabaseExport.EventTributePlayerTurnStarted(_, isLocalPlayer)
	if isLocalPlayer == true then
		ssv.TalesOfTribute.Turns = ssv.TalesOfTribute.Turns + 1
	end
end

function ESODatabaseExport.SetTributeVictoryByType(victoryType, matchType)

	if matchType == TRIBUTE_MATCH_TYPE_CASUAL then
		ssv.TalesOfTribute.VictoriesCausual = ssv.TalesOfTribute.VictoriesCausual + 1
	elseif matchType == TRIBUTE_MATCH_TYPE_CLIENT then
		ssv.TalesOfTribute.VictoriesNpc = ssv.TalesOfTribute.VictoriesNpc + 1
	elseif matchType == TRIBUTE_MATCH_TYPE_COMPETITIVE then
		ssv.TalesOfTribute.VictoriesRanked = ssv.TalesOfTribute.VictoriesRanked + 1
	elseif matchType == TRIBUTE_MATCH_TYPE_PRIVATE then
		ssv.TalesOfTribute.VictoriesFriendly = ssv.TalesOfTribute.VictoriesFriendly + 1
	end

	if victoryType == TRIBUTE_VICTORY_TYPE_EARLY_CONCESSION or victoryType == TRIBUTE_VICTORY_TYPE_CONCESSION then

		ssv.TalesOfTribute.VictoriesEarlyConcession = ssv.TalesOfTribute.VictoriesEarlyConcession + 1

		if matchType == TRIBUTE_MATCH_TYPE_CASUAL then
			ssv.TalesOfTribute.VictoriesCausualEarlyConcession = ssv.TalesOfTribute.VictoriesCausualEarlyConcession + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_CLIENT then
			ssv.TalesOfTribute.VictoriesNpcEarlyConcession = ssv.TalesOfTribute.VictoriesNpcEarlyConcession + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_COMPETITIVE then
			ssv.TalesOfTribute.VictoriesRankedEarlyConcession = ssv.TalesOfTribute.VictoriesRankedEarlyConcession + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_PRIVATE then
			ssv.TalesOfTribute.VictoriesFriendlyEarlyConcession = ssv.TalesOfTribute.VictoriesFriendlyEarlyConcession + 1
		end
	elseif victoryType == TRIBUTE_VICTORY_TYPE_PATRON then

		ssv.TalesOfTribute.VictoriesPatron = ssv.TalesOfTribute.VictoriesPatron + 1

		if matchType == TRIBUTE_MATCH_TYPE_CASUAL then
			ssv.TalesOfTribute.VictoriesCausualPatron = ssv.TalesOfTribute.VictoriesCausualPatron + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_CLIENT then
			ssv.TalesOfTribute.VictoriesNpcPatron = ssv.TalesOfTribute.VictoriesNpcPatron + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_COMPETITIVE then
			ssv.TalesOfTribute.VictoriesRankedPatron = ssv.TalesOfTribute.VictoriesRankedPatron + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_PRIVATE then
			ssv.TalesOfTribute.VictoriesFriendlyPatron = ssv.TalesOfTribute.VictoriesFriendlyPatron + 1
		end
	elseif victoryType == TRIBUTE_VICTORY_TYPE_PRESTIGE then

		ssv.TalesOfTribute.VictoriesPrestige = ssv.TalesOfTribute.VictoriesPrestige + 1

		if matchType == TRIBUTE_MATCH_TYPE_CASUAL then
			ssv.TalesOfTribute.VictoriesCausualPrestige = ssv.TalesOfTribute.VictoriesCausualPrestige + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_CLIENT then
			ssv.TalesOfTribute.VictoriesNpcPrestige = ssv.TalesOfTribute.VictoriesNpcPrestige + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_COMPETITIVE then
			ssv.TalesOfTribute.VictoriesRankedPrestige = ssv.TalesOfTribute.VictoriesRankedPrestige + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_PRIVATE then
			ssv.TalesOfTribute.VictoriesFriendlyPrestige = ssv.TalesOfTribute.VictoriesFriendlyPrestige + 1
		end
	end
end

function ESODatabaseExport.SetTributeDefeatByType(victoryType, matchType)

	if matchType == TRIBUTE_MATCH_TYPE_CASUAL then
		ssv.TalesOfTribute.DefeatsCausual = ssv.TalesOfTribute.DefeatsCausual + 1
	elseif matchType == TRIBUTE_MATCH_TYPE_CLIENT then
		ssv.TalesOfTribute.DefeatsNpc = ssv.TalesOfTribute.DefeatsNpc + 1
	elseif matchType == TRIBUTE_MATCH_TYPE_COMPETITIVE then
		ssv.TalesOfTribute.DefeatsRanked = ssv.TalesOfTribute.DefeatsRanked + 1
	elseif matchType == TRIBUTE_MATCH_TYPE_PRIVATE then
		ssv.TalesOfTribute.DefeatsFriendly = ssv.TalesOfTribute.DefeatsFriendly + 1
	end

	if victoryType == TRIBUTE_VICTORY_TYPE_EARLY_CONCESSION or victoryType == TRIBUTE_VICTORY_TYPE_CONCESSION then

		ssv.TalesOfTribute.DefeatsEarlyConcession = ssv.TalesOfTribute.DefeatsEarlyConcession + 1

		if matchType == TRIBUTE_MATCH_TYPE_CASUAL then
			ssv.TalesOfTribute.DefeatsCausualEarlyConcession = ssv.TalesOfTribute.DefeatsCausualEarlyConcession + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_CLIENT then
			ssv.TalesOfTribute.DefeatsNpcEarlyConcession = ssv.TalesOfTribute.DefeatsNpcEarlyConcession + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_COMPETITIVE then
			ssv.TalesOfTribute.DefeatsRankedEarlyConcession = ssv.TalesOfTribute.DefeatsRankedEarlyConcession + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_PRIVATE then
			ssv.TalesOfTribute.DefeatsFriendlyEarlyConcession = ssv.TalesOfTribute.DefeatsFriendlyEarlyConcession + 1
		end
	elseif victoryType == TRIBUTE_VICTORY_TYPE_PATRON then

		ssv.TalesOfTribute.DefeatsPatron = ssv.TalesOfTribute.DefeatsPatron + 1

		if matchType == TRIBUTE_MATCH_TYPE_CASUAL then
			ssv.TalesOfTribute.DefeatsCausualPatron = ssv.TalesOfTribute.DefeatsCausualPatron + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_CLIENT then
			ssv.TalesOfTribute.DefeatsNpcPatron = ssv.TalesOfTribute.DefeatsNpcPatron + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_COMPETITIVE then
			ssv.TalesOfTribute.DefeatsRankedPatron = ssv.TalesOfTribute.DefeatsRankedPatron + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_PRIVATE then
			ssv.TalesOfTribute.DefeatsFriendlyPatron = ssv.TalesOfTribute.DefeatsFriendlyPatron + 1
		end
	elseif victoryType == TRIBUTE_VICTORY_TYPE_PRESTIGE then

		ssv.TalesOfTribute.DefeatsPrestige = ssv.TalesOfTribute.DefeatsPrestige + 1

		if matchType == TRIBUTE_MATCH_TYPE_CASUAL then
			ssv.TalesOfTribute.DefeatsCausualPrestige = ssv.TalesOfTribute.DefeatsCausualPrestige + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_CLIENT then
			ssv.TalesOfTribute.DefeatsNpcPrestige = ssv.TalesOfTribute.DefeatsNpcPrestige + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_COMPETITIVE then
			ssv.TalesOfTribute.DefeatsRankedPrestige = ssv.TalesOfTribute.DefeatsRankedPrestige + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_PRIVATE then
			ssv.TalesOfTribute.DefeatsFriendlyPrestige = ssv.TalesOfTribute.DefeatsFriendlyPrestige + 1
		end
	end
end

function ESODatabaseExport.EventTributeGameFlowStateChange(_, flowState)

	if flowState == TRIBUTE_GAME_FLOW_STATE_GAME_OVER then

		local prestigeObtained = GetTributePlayerPerspectiveResource(TRIBUTE_PLAYER_PERSPECTIVE_SELF, TRIBUTE_RESOURCE_PRESTIGE)
		if prestigeObtained > 0 then
			ssv.TalesOfTribute.PrestigeObtain = ssv.TalesOfTribute.PrestigeObtain + prestigeObtained
		end

		local victoryPerspective, victoryType = GetTributeResultsWinnerInfo()
		local matchDurationMS, goldAccumulated, cardsAcquired = GetTributeMatchStatistics()
		local matchType = GetTributeMatchType()

		if victoryPerspective == TRIBUTE_PLAYER_PERSPECTIVE_SELF then
			ssv.TalesOfTribute.Victories = ssv.TalesOfTribute.Victories + 1
			ESODatabaseExport.SetTributeVictoryByType(victoryType, matchType)
		else
			ssv.TalesOfTribute.Defeats = ssv.TalesOfTribute.Defeats + 1
			ESODatabaseExport.SetTributeDefeatByType(victoryType, matchType)
		end

		ssv.TalesOfTribute.MatchDurationMS = ssv.TalesOfTribute.MatchDurationMS + matchDurationMS
		ssv.TalesOfTribute.GoldAccumulated = ssv.TalesOfTribute.GoldAccumulated + goldAccumulated
		ssv.TalesOfTribute.CardsAcquired = ssv.TalesOfTribute.CardsAcquired + cardsAcquired

		if matchType == TRIBUTE_MATCH_TYPE_CASUAL then
			ssv.TalesOfTribute.MatchTypePlayedCausual = ssv.TalesOfTribute.MatchTypePlayedCausual + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_CLIENT then
			ssv.TalesOfTribute.MatchTypePlayedNpc = ssv.TalesOfTribute.MatchTypePlayedNpc + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_COMPETITIVE then
			ssv.TalesOfTribute.MatchTypePlayedRanked = ssv.TalesOfTribute.MatchTypePlayedRanked + 1
		elseif matchType == TRIBUTE_MATCH_TYPE_PRIVATE then
			ssv.TalesOfTribute.MatchTypePlayedFriendly = ssv.TalesOfTribute.MatchTypePlayedFriendly + 1
		end
	end
end

function ESODatabaseExport.InitEndlessDungeonGlobalStorageVars()

    if type(svAccount.Store) == "nil" then
		svAccount.Store = {}
    end

	if type(svAccount.Store.EndlessDungeon) == "nil" then
		svAccount.Store.EndlessDungeon = {
			Kills = 0,
			Died = 0,
			ArchiveFortunesLooted = 0,
		}
	end
end

function ESODatabaseExport.ResetEndlessDungeonGlobalStorageVars()
	svAccount.Store.EndlessDungeon.Kills = 0
	svAccount.Store.EndlessDungeon.Died = 0
	svAccount.Store.EndlessDungeon.ArchiveFortunesLooted = 0
end

function ESODatabaseExport.EventEndlessDungeonStarted()

	ssv.EndlessDungeon.RunsStarted = ssv.EndlessDungeon.RunsStarted + 1

	ESODatabaseExport.ResetEndlessDungeonGlobalStorageVars()
end

function ESODatabaseExport.EventEndlessDungeonCounterValueChanged(_, counterType, counterValue)

	if counterType == ENDLESS_DUNGEON_COUNTER_TYPE_ARC then
		if counterValue > 1 then
			ssv.EndlessDungeon.CompletedArcs = ssv.EndlessDungeon.CompletedArcs + 1
		end
	elseif counterType == ENDLESS_DUNGEON_COUNTER_TYPE_CYCLE then
		if counterValue > 1 then
			ssv.EndlessDungeon.CompletedCycles = ssv.EndlessDungeon.CompletedCycles + 1
		end
	elseif counterType == ENDLESS_DUNGEON_COUNTER_TYPE_STAGE then
		if counterValue > 1 then
			ssv.EndlessDungeon.CompletedStages = ssv.EndlessDungeon.CompletedStages + 1
		end
	end
end

function ESODatabaseExport.EventEndlessDungeonBuffStackCountUpdated(_, _, abilityId)

	local abilityBuffType, isAvatarVision = GetAbilityEndlessDungeonBuffType(abilityId)

	if abilityBuffType == ENDLESS_DUNGEON_BUFF_TYPE_VERSE then
		ssv.EndlessDungeon.VersesReceived = ssv.EndlessDungeon.VersesReceived + 1
	elseif abilityBuffType == ENDLESS_DUNGEON_BUFF_TYPE_VISION then

		if isAvatarVision then
			ssv.EndlessDungeon.AvatarVisionsReceived = ssv.EndlessDungeon.AvatarVisionsReceived + 1
		else
			ssv.EndlessDungeon.VisionsReceived = ssv.EndlessDungeon.VisionsReceived + 1
		end
	end

end

function ESODatabaseExport.EventHousingFurniturePlaced(_, furnitureId)

	local categoryId = ESODBExportUtils:GetFurnitureCategoryIdFromFurnitureId(furnitureId)
	local categoryStatsKey = ESODBExportUtils:FurnitureCategoryIdToStatsKey(categoryId)

	if categoryStatsKey ~= nil and type(ssv.Housing[categoryStatsKey]) ~= nil then
		ssv.Housing[categoryStatsKey] = ssv.Housing[categoryStatsKey] + 1
	end

	ssv.Housing.Placed = ssv.Housing.Placed + 1
end

function ESODatabaseExport.EventHousingFurnitureMoved()
	ssv.Housing.Moved = ssv.Housing.Moved + 1
end

function ESODatabaseExport.EventHousingFurnitureRemoved()
	ssv.Housing.Removed = ssv.Housing.Removed + 1
end

function ESODatabaseExport.EventEndlessDungeonCompleted()

	local arc = GetEndlessDungeonCounterValue(ENDLESS_DUNGEON_COUNTER_TYPE_ARC)
	local cycle = GetEndlessDungeonCounterValue(ENDLESS_DUNGEON_COUNTER_TYPE_CYCLE)
	local stage = GetEndlessDungeonCounterValue(ENDLESS_DUNGEON_COUNTER_TYPE_STAGE)
	local numVerses, numNonAvatarVisions, numAvatarVisions = GetNumEndlessDungeonLifetimeVerseAndVisionStackCounts()
	local runDurationMS = GetEndlessDungeonFinalRunTimeMilliseconds()

	ssv.EndlessDungeon.RunsCompleted = ssv.EndlessDungeon.RunsCompleted + 1

	table.insert(sv.EndlessDungeon, {
		DateTime = GetTimeStamp(),
		Score = GetEndlessDungeonScore(),
		GroupType = GetEndlessDungeonGroupType(),
		RunDurationMS = runDurationMS,
		Kills = svAccount.Store.EndlessDungeon.Kills,
		Died = svAccount.Store.EndlessDungeon.Died,
		ArchiveFortunesLooted = svAccount.Store.EndlessDungeon.ArchiveFortunesLooted,
		Counters = {
			Arc = arc,
			Cycle = cycle,
			Stage = stage,
		},
		Buffs = {
			Verses = numVerses,
			NonAvatarVisions = numNonAvatarVisions,
			AvatarVisions = numAvatarVisions,
		},
	})

	-- Save current run records
	ssv.EndlessDungeon.RecordArc = arc
	ssv.EndlessDungeon.RecordCycle = cycle
	ssv.EndlessDungeon.RecordStage = stage
	ssv.EndlessDungeon.RunDurationsMS = ssv.EndlessDungeon.RunDurationsMS + runDurationMS

	ESODatabaseExport.ResetEndlessDungeonGlobalStorageVars()
end

function ESODatabaseExport.EventBattlegroundStateChanged(_, _, currentState)

	if currentState == BATTLEGROUND_STATE_RUNNING then

		ssv.Battleground.Started = ssv.Battleground.Started + 1

		local battlegroundAlliance = GetUnitBattlegroundTeam("player")
		local battlegroundGameType = ESODBExportUtils:GetBattlegroundType()

		if battlegroundAlliance == BATTLEGROUND_TEAM_FIRE_DRAKES then
			ssv.Battleground.PlayedAllianceFireDrakes = ssv.Battleground.PlayedAllianceFireDrakes + 1
		elseif battlegroundAlliance == BATTLEGROUND_TEAM_PIT_DAEMONS then
			ssv.Battleground.PlayedAlliancePitDaemons = ssv.Battleground.PlayedAlliancePitDaemons + 1
		elseif battlegroundAlliance == BATTLEGROUND_TEAM_STORM_LORDS then
			ssv.Battleground.PlayedAllianceStormLords = ssv.Battleground.PlayedAllianceStormLords + 1
		end

		if battlegroundGameType == BATTLEGROUND_GAME_TYPE_CAPTURE_THE_FLAG then
			ssv.Battleground.PlayedGameTypeCaptureTheRelic = ssv.Battleground.PlayedGameTypeCaptureTheRelic + 1
		elseif battlegroundGameType == BATTLEGROUND_GAME_TYPE_CRAZY_KING then
			ssv.Battleground.PlayedGameTypeCrazyKing = ssv.Battleground.PlayedGameTypeCrazyKing + 1
		elseif battlegroundGameType == BATTLEGROUND_GAME_TYPE_DEATHMATCH then
			ssv.Battleground.PlayedGameTypeDeathmatch = ssv.Battleground.PlayedGameTypeDeathmatch + 1
		elseif battlegroundGameType == BATTLEGROUND_GAME_TYPE_DOMINATION then
			ssv.Battleground.PlayedGameTypeDomination = ssv.Battleground.PlayedGameTypeDomination + 1
		elseif battlegroundGameType == BATTLEGROUND_GAME_TYPE_MURDERBALL then
			ssv.Battleground.PlayedGameTypeChaosball = ssv.Battleground.PlayedGameTypeChaosball + 1
		end

	elseif currentState == BATTLEGROUND_STATE_POSTGAME then

		local battlegroundWinStatus = ESODBExportUtils:GetBattlegroundWinnerStatus()
		if battlegroundWinStatus == ESODBExportConst.BattlegroundWinnerStatus.WINNER then
			ssv.Battleground.Wins = ssv.Battleground.Wins + 1
		else
			ssv.Battleground.Defeats = ssv.Battleground.Defeats + 1
		end

		ssv.Battleground.Completed = ssv.Battleground.Completed + 1
	end
end

function ESODatabaseExport.EventBattlegroundKill(_, _, _, _, _, _, _, battlegroundKillType)

	if battlegroundKillType == BATTLEGROUND_KILL_TYPE_ASSIST then
		ssv.Battleground.KillAssists = ssv.Battleground.KillAssists + 1
	elseif battlegroundKillType == BATTLEGROUND_KILL_TYPE_KILLED_BY_MY_TEAM then
		ssv.Battleground.TeamKills = ssv.Battleground.TeamKills + 1
	elseif battlegroundKillType == BATTLEGROUND_KILL_TYPE_KILLING_BLOW then
		ssv.Battleground.Kills = ssv.Battleground.Kills + 1
	end
end

function ESODatabaseExport.EventGuildMemberAdded(_, guildID)
	ESODatabaseExport.ExportGuild(nil, guildID)
end

function ESODatabaseExport.EventGuildMemberRemoved(_, guildID)
	ESODatabaseExport.ExportGuild(nil, guildID)
end

function ESODatabaseExport.EventCraftedAbilityLockStateChanged(_, craftedAbilityId, isUnlocked)
	if isUnlocked == true then
		table.insert(sv.Scribing.Grimoires, craftedAbilityId)
	end
end

function ESODatabaseExport.EventCraftedAbilityScriptLockStateChanged(_, craftedAbilityScriptId, isUnlocked)
	if isUnlocked == true then
		table.insert(sv.Scribing.Scripts, craftedAbilityScriptId)
	end
end

function ESODatabaseExport.ExportCharacterStats()

	sv.CharStats = {}
	sv.CharStats.ArmorRating = GetPlayerStat(STAT_ARMOR_RATING)
	sv.CharStats.AttackPower = ESODBExportUtils:GetPlayerStat(STAT_ATTACK_POWER)
	sv.CharStats.Block = ESODBExportUtils:GetPlayerStat(STAT_BLOCK)
	sv.CharStats.CriticalResistance = ESODBExportUtils:GetPlayerStat(STAT_CRITICAL_RESISTANCE)
	sv.CharStats.CriticalStrike = ESODBExportUtils:GetPlayerStat(STAT_CRITICAL_STRIKE)
	sv.CharStats.ResistCold = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_COLD)
	sv.CharStats.ResistDisease = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_DISEASE)
	sv.CharStats.ResistDrown = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_DROWN)
	sv.CharStats.ResistEarth = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_EARTH)
	sv.CharStats.ResistFire = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_FIRE)
	sv.CharStats.ResistGeneric = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_GENERIC)
	sv.CharStats.ResistMagic = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_MAGIC)
	sv.CharStats.ResistOblivion = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_OBLIVION)
	sv.CharStats.ResistPhysical = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_PHYSICAL)
	sv.CharStats.ResistPoison = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_POISON)
	sv.CharStats.ResistShock = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_SHOCK)
	sv.CharStats.ResistStart = ESODBExportUtils:GetPlayerStat(STAT_DAMAGE_RESIST_START)
	sv.CharStats.Dodge = ESODBExportUtils:GetPlayerStat(STAT_DODGE)
	sv.CharStats.HealingTaken = ESODBExportUtils:GetPlayerStat(STAT_HEALING_TAKEN)
	sv.CharStats.HealthMax = ESODBExportUtils:GetPlayerStat(STAT_HEALTH_MAX)
	sv.CharStats.HealthRegenCombat = ESODBExportUtils:GetPlayerStat(STAT_HEALTH_REGEN_COMBAT)
	sv.CharStats.HealthRegenIdle = ESODBExportUtils:GetPlayerStat(STAT_HEALTH_REGEN_IDLE)
	sv.CharStats.MagickaMax = ESODBExportUtils:GetPlayerStat(STAT_MAGICKA_MAX)
	sv.CharStats.MagickaRegenCombat = ESODBExportUtils:GetPlayerStat(STAT_MAGICKA_REGEN_COMBAT)
	sv.CharStats.MagickaRegenIdle = ESODBExportUtils:GetPlayerStat(STAT_MAGICKA_REGEN_IDLE)
	sv.CharStats.Miss = ESODBExportUtils:GetPlayerStat(STAT_MISS)
	sv.CharStats.Mitigation = ESODBExportUtils:GetPlayerStat(STAT_MITIGATION)
	sv.CharStats.MountStaminaMax = ESODBExportUtils:GetPlayerStat(STAT_MOUNT_STAMINA_MAX)
	sv.CharStats.MountStaminaRegenCombat = ESODBExportUtils:GetPlayerStat(STAT_MOUNT_STAMINA_REGEN_COMBAT)
	sv.CharStats.MountStaminaRegenMoving = ESODBExportUtils:GetPlayerStat(STAT_MOUNT_STAMINA_REGEN_MOVING)
	sv.CharStats.Parry = ESODBExportUtils:GetPlayerStat(STAT_PARRY)
	sv.CharStats.PhysicalPenetration = ESODBExportUtils:GetPlayerStat(STAT_PHYSICAL_PENETRATION)
	sv.CharStats.PhysicalResist = ESODBExportUtils:GetPlayerStat(STAT_PHYSICAL_RESIST)
	sv.CharStats.Power = ESODBExportUtils:GetPlayerStat(STAT_POWER)
	sv.CharStats.SpellCritical = ESODBExportUtils:GetPlayerStat(STAT_SPELL_CRITICAL)
	sv.CharStats.SpellMitigation = ESODBExportUtils:GetPlayerStat(STAT_SPELL_MITIGATION)
	sv.CharStats.SpellPenetration = ESODBExportUtils:GetPlayerStat(STAT_SPELL_PENETRATION)
	sv.CharStats.SpellPower = ESODBExportUtils:GetPlayerStat(STAT_SPELL_POWER)
	sv.CharStats.SpellResist = ESODBExportUtils:GetPlayerStat(STAT_SPELL_RESIST)
	sv.CharStats.StaminaMax = ESODBExportUtils:GetPlayerStat(STAT_STAMINA_MAX)
	sv.CharStats.StaminaRegenCombat = ESODBExportUtils:GetPlayerStat(STAT_STAMINA_REGEN_COMBAT)
	sv.CharStats.StaminaRegenIdle = ESODBExportUtils:GetPlayerStat(STAT_STAMINA_REGEN_IDLE)
	sv.CharStats.WeaponPower = ESODBExportUtils:GetPlayerStat(STAT_WEAPON_POWER)

end

function ESODatabaseExport.ExportTalesOfTributeData()

	if type(sv.TalesOfTribute) == "nil" then
		sv.TalesOfTribute = {}
	end

	sv.TalesOfTribute.Cards = {}

	for _, patronData in TRIBUTE_DATA_MANAGER:TributePatronIterator() do
		if patronData:IsNeutral() == true or IsCollectibleUnlocked(patronData:GetPatronCollectibleId()) == true then

			-- Export starter cards
			local numStarterCards = patronData:GetNumStarterCards()
			if numStarterCards > 0 then
				for index = 1, numStarterCards do
					table.insert(sv.TalesOfTribute.Cards, {
						Id = patronData:GetStarterCardIdByIndex(index)
					})
				end
			end

			-- Export patron card deck, not including starter cards
			local currentDockCards = patronData:GetDockCards()
			for _, card in ipairs(currentDockCards) do
				table.insert(sv.TalesOfTribute.Cards, {
					Id = card.cardId
				})
			end
		end
	end
end

function ESODatabaseExport.UpdateTalesOfTributeClubData()

	if RequestTributeClubData() == TRIBUTE_PLAYER_INITIALIZATION_STATE_SUCCESS then
		ESODatabaseExport.ExportTalesOfTributeClubRank()
	end

	ESODatabaseExport.GlobalStore.InitialExportJobActive = false
end

function ESODatabaseExport.ExportTalesOfTributeClubRank()

	if type(sv.TalesOfTribute) == "nil" then
		sv.TalesOfTribute = {}
	end

	local experience, clubRankRequirement = GetTributePlayerExperienceInCurrentClubRank()

	sv.TalesOfTribute.Club = {}
	sv.TalesOfTribute.Club.Rank = GetTributePlayerClubRank()
	sv.TalesOfTribute.Club.MatchesPlayed = GetTotalClubMatchesPlayed()
	sv.TalesOfTribute.Club.MatchStreak = GetCurrentClubMatchStreak()

	sv.TalesOfTribute.Club.Experience = {}
	sv.TalesOfTribute.Club.Experience.Current = experience
	sv.TalesOfTribute.Club.Experience.Total = GetTributePlayerClubTotalExperience()
	sv.TalesOfTribute.Club.Experience.RankRequirement = clubRankRequirement
end

function ESODatabaseExport.ExportTimedActivities()

	svAccount.TimedActivities.Lang = ESODatabaseExport.GlobalStore.Lang
	svAccount.TimedActivities.Timestamp = GetTimeStamp()
	svAccount.TimedActivities.Daily = {}
	svAccount.TimedActivities.Weekly = {}

	if IsTimedActivitySystemAvailable() == true then

		local numActivities = GetNumTimedActivities()
		if numActivities > 0 then
			for index = 1, numActivities do

				local rewards = {}
				local type = GetTimedActivityType(index)
				local id = GetTimedActivityId(index)
				local difficulty = GetTimedActivityDifficulty(index)
				local name = GetTimedActivityName(index)
				local description = GetTimedActivityDescription(index)
				local numRewards = GetNumTimedActivityRewards(index)
				local uniqueID = type .. "-" .. id .. "-" .. difficulty

				if numRewards > 0 then
					for rewardIndex = 1, numRewards do

						local rewardId, quantity = GetTimedActivityRewardInfo(index, rewardIndex)
						local rewardData = REWARDS_MANAGER:GetInfoForReward(rewardId, quantity)

						table.insert(rewards, {
							Id = rewardId,
							Quantity = quantity,
							Name = rewardData:GetFormattedName(),
							Icon = rewardData:GetKeyboardIcon(),
						})
					end
				end

				if type == TIMED_ACTIVITY_TYPE_DAILY then

					local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.TimedActivities.Daily, "UniqueId", uniqueID, {
						UniqueId = uniqueID,
					})

					svAccount.TimedActivities.Daily[tableIndex].Id = id
					svAccount.TimedActivities.Daily[tableIndex].Difficulty = difficulty
					svAccount.TimedActivities.Daily[tableIndex].Name = name
					svAccount.TimedActivities.Daily[tableIndex].Description = description
					svAccount.TimedActivities.Daily[tableIndex].Rewards = rewards

				elseif type == TIMED_ACTIVITY_TYPE_WEEKLY then

					local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.TimedActivities.Weekly, "UniqueId", uniqueID, {
						UniqueId = uniqueID,
					})

					svAccount.TimedActivities.Weekly[tableIndex].Id = id
					svAccount.TimedActivities.Weekly[tableIndex].Difficulty = difficulty
					svAccount.TimedActivities.Weekly[tableIndex].Name = name
					svAccount.TimedActivities.Weekly[tableIndex].Description = description
					svAccount.TimedActivities.Weekly[tableIndex].Rewards = rewards
				end
			end
		end
	end

	ESODatabaseExport.GlobalStore.InitialExportJobActive = false
end

function ESODatabaseExport.ExportRidingStats()

	local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()

	sv.RidingStats = {}
	sv.RidingStats.InventoryBonus = inventoryBonus
	sv.RidingStats.MaxInventoryBonus = maxInventoryBonus
	sv.RidingStats.StaminaBonus = staminaBonus
	sv.RidingStats.MaxStaminaBonus = maxStaminaBonus
	sv.RidingStats.SpeedBonus = speedBonus
	sv.RidingStats.MaxSpeedBonus = maxSpeedBonus
end

function ESODatabaseExport.ExportLevel()

	sv.Level = {}
	sv.Level.EffectiveLevel = GetUnitEffectiveLevel("player")
	sv.Level.Level = GetUnitLevel("player")
	sv.Level.XP = GetUnitXP("player")
	sv.Level.XPMax = GetUnitXPMax("player")

	ESODatabaseExport.ExportCharacterStats()
end

function ESODatabaseExport.ExportChampionRank()

	sv.Level.ChampionPoints = GetPlayerChampionPointsEarned()
	sv.Level.ChampionXPCurrent = GetPlayerChampionXP()
	sv.Level.ChampionXPMax = GetNumChampionXPInChampionPoint(sv.Level.ChampionPoints)
	sv.Level.ChampionAttribute = GetChampionPointPoolForRank(sv.Level.ChampionPoints + 1)
end

function ESODatabaseExport.ExportAvA()

	local avaRank, avaCurrentPoints, avaMaxPoints = ESODBExportUtils:GetCurrentAvARankProgress()

	sv.AvA = {}
	sv.AvA.Rank = avaRank
	sv.AvA.RankName = zo_strformat(SI_UNIT_NAME, GetAvARankName(sv.Gender, avaRank))
	sv.AvA.RankPoints = avaCurrentPoints
	sv.AvA.RankPointsMax = avaMaxPoints
end

function ESODatabaseExport.ExportGold()

	local characterGold = GetCarriedCurrencyAmount(CURT_MONEY)
	local bankGold = GetBankedCurrencyAmount(CURT_MONEY)

	ssv.Gold.Total = characterGold + bankGold
	ssv.Gold.Character = characterGold
	ssv.Gold.Bank = bankGold
end

function ESODatabaseExport.ExportTelVarStones()

	local characterTelVarStones = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	local bankTelVarStones = GetBankedCurrencyAmount(CURT_TELVAR_STONES)

	ssv.TelVarStones.Total = characterTelVarStones + bankTelVarStones
	ssv.TelVarStones.Character = characterTelVarStones
	ssv.TelVarStones.Bank = bankTelVarStones

	if characterTelVarStones > ssv.TelVarStones.HighestAmountOnCharacter then
		ssv.TelVarStones.HighestAmountOnCharacter = characterTelVarStones
	end
end

function ESODatabaseExport.ExportTradeskills()

	sv.Tradeskills = {}

	for _, craftingType in pairs(ESODBExportConst.Tradeskills) do

		local skillType, skillIndex = GetCraftingSkillLineIndices(craftingType)
		local _, rank = GetSkillLineInfo(skillType, skillIndex)
		local lastRankXP, nextRankXP, currentXP = GetSkillLineXPInfo(skillType, skillIndex)
		local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(sv.Tradeskills, "Id", craftingType, {
			Id = craftingType,
		})

		sv.Tradeskills[tableIndex]["Rank"] = rank
		sv.Tradeskills[tableIndex]["CurrentXP"] = (currentXP - lastRankXP)
		sv.Tradeskills[tableIndex]["NextRankXP"] = (nextRankXP - lastRankXP)
		sv.Tradeskills[tableIndex]["Traits"] = {}

		local numLines = GetNumSmithingResearchLines(craftingType)
		if numLines > 0 then
			for researchLineIndex = 1, numLines do

				local _, _, numTraits, _ = GetSmithingResearchLineInfo(craftingType, researchLineIndex)
				if numTraits > 0 then

					local lineTableIndex = ESODBExportUtils:SetTableIndexByFieldValue(sv.Tradeskills[tableIndex].Traits, "Id", researchLineIndex, {
						Id = researchLineIndex,
						List = {},
					})

					sv.Tradeskills[tableIndex].Traits[lineTableIndex].List = {}

					for traitIndex = 1, numTraits do

						local traitType, _, known = GetSmithingResearchLineTraitInfo(craftingType, researchLineIndex, traitIndex)
						local traitTableIndex = ESODBExportUtils:SetTableIndexByFieldValue(sv.Tradeskills[tableIndex].Traits[lineTableIndex].List, "Id", traitType, {
							Id = traitType,
						})

						sv.Tradeskills[tableIndex].Traits[lineTableIndex].List[traitTableIndex]["Line"] = researchLineIndex
						sv.Tradeskills[tableIndex].Traits[lineTableIndex].List[traitTableIndex]["Trait"] = traitType
						sv.Tradeskills[tableIndex].Traits[lineTableIndex].List[traitTableIndex]["Known"] = known

						-- Export research timers
						ESODatabaseExport.ExportResearchTimers(craftingType, researchLineIndex, traitIndex, traitType)
					end
				end
			end
		end
	end

	ESODatabaseExport.GlobalStore.InitialExportJobActive = false
end

function ESODatabaseExport.ExportResearchTimers(craftingType, researchLineIndex, traitIndex, traitType)

	if type(ESODBExportConst.TradeskillResearchTypes[craftingType]) ~= "nil" then

		local durationSecs, timeRemainingSecs = GetSmithingResearchLineTraitTimes(craftingType, researchLineIndex, traitIndex)
		if durationSecs then

			local startTime = GetTimeStamp() - (durationSecs - timeRemainingSecs)
			local endTime = startTime + durationSecs

			if type(sv.ResearchTimers) == "nil" then
				sv.ResearchTimers = {}
			end

			local lookupKey = tonumber(craftingType .. researchLineIndex .. traitIndex .. traitType)
			local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(sv.ResearchTimers, "LookupKey", lookupKey, {
				LookupKey = lookupKey
			})

			sv.ResearchTimers[tableIndex]["Type"] = craftingType
			sv.ResearchTimers[tableIndex]["Line"] = researchLineIndex
			sv.ResearchTimers[tableIndex]["Trait"] = traitType
			sv.ResearchTimers[tableIndex]["StartTime"] = startTime
			sv.ResearchTimers[tableIndex]["EndTime"] = endTime
		end
	end
end

function ESODatabaseExport.ExportAlchemyTraits()

	local tableIndex = ESODBExportUtils:GetTableIndexByFieldValue(sv.Tradeskills, "Id", CRAFTING_TYPE_ALCHEMY)
	if tableIndex ~= false then

		for _, itemId in pairs(ESODBExportConst.Alchemy.Reagents) do

			local itemLink = string.format("|H1:item:%i:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)

			for i = 1, 4 do
				local known, traitName = GetItemLinkReagentTraitInfo(itemLink, i)
				if known then

					local traitIndex = ESODBExportUtils:AlchemyTraitNameToIndex(traitName)
					if traitIndex ~= nil then

						local traitId = tonumber(itemId .. traitIndex)
						local traitTableIndex = ESODBExportUtils:GetTableIndexByFieldValue(sv.Tradeskills[tableIndex].Traits, "TraitId", traitId)
						if traitTableIndex == false then
							table.insert(sv.Tradeskills[tableIndex].Traits, {
								TraitId = traitId,
								Id = itemId,
								Trait = traitIndex
							})
						end
					end
				end
			end
		end
	end

	ESODatabaseExport.GlobalStore.InitialExportJobActive = false
end

function ESODatabaseExport.ExportEnchantingRuneTraits()

	local tableIndex = ESODBExportUtils:GetTableIndexByFieldValue(sv.Tradeskills, "Id", CRAFTING_TYPE_ENCHANTING)
	if tableIndex ~= false then
		for _, itemId in pairs(ESODBExportConst.Enchanting.Runes) do
			if IsRuneKnown(itemId) then
				local traitTableIndex = ESODBExportUtils:GetTableIndexByFieldValue(sv.Tradeskills[tableIndex].Traits, "Id", itemId)
				if traitTableIndex == false then
					table.insert(sv.Tradeskills[tableIndex].Traits, {
						Id = itemId
					})
				end
			end
		end
	end

	ESODatabaseExport.GlobalStore.InitialExportJobActive = false
end

function ESODatabaseExport.ExportSkillLines()

	sv.SkillLines = {}

	local numSkillTypes = GetNumSkillTypes()
	for skillType = 1, numSkillTypes do

		local numSkillLines = GetNumSkillLines(skillType)
		for skillLineIndex = 1, numSkillLines do

			local skillLineId = GetSkillLineId(skillType, skillLineIndex)
			local _, rank = GetSkillLineInfo(skillType, skillLineIndex)
			local lastRankXP, nextRankXP, currentXP = GetSkillLineXPInfo(skillType, skillLineIndex)

			table.insert(sv.SkillLines, {
				Id = skillLineId,
				Rank = rank,
				CurrentXP = (currentXP - lastRankXP),
				NextRankXP = (nextRankXP - lastRankXP)
			})
		end
	end

	ESODatabaseExport.GlobalStore.InitialExportJobActive = false
end

function ESODatabaseExport.ExportAchievements()

	sv.Achievements = {}

	local achievementId = 1;
	local runnerName = ESODatabaseExport.Name .. "ExportAchievements"

	EVENT_MANAGER:UnregisterForUpdate(runnerName)
	EVENT_MANAGER:RegisterForUpdate(runnerName, ESODatabaseExport.InitialExportAchievementsDelay, function()

		local endAchievementId = achievementId + 200
		for exportAchievementId = achievementId, endAchievementId do
			ESODatabaseExport.ExportAchievementById(exportAchievementId)
		end

		achievementId = endAchievementId

		if achievementId >= ESODBExportDatabaseIds.MaxAchievementId then
			EVENT_MANAGER:UnregisterForUpdate(runnerName)
			ESODatabaseExport.GlobalStore.InitialExportJobActive = false
		end
	end)

	ESODatabaseExport.GlobalStore.InitialExportJobActive = false
end

function ESODatabaseExport.ExportAchievementById(achievementId)

	local name, _, _, _, completed = GetAchievementInfo(achievementId)

	if name == "" then
		return
	end

	if completed == true then

		table.insert(sv.Achievements, {
			achievementId = achievementId,
			completed = true,
			timestamp = GetAchievementTimestamp(achievementId)
		})

		-- Get previous achievements in line
		local lineIds = ESODBExportUtils:GetAchievementsInLine(achievementId)
		if #lineIds > 0 then
			for _, lineAchievementId in pairs(lineIds) do
				_, _, _, _, completed = GetAchievementInfo(lineAchievementId)
				table.insert(sv.Achievements, {
					achievementId = lineAchievementId,
					completed = true,
					timestamp = GetAchievementTimestamp(lineAchievementId)
				})
			end
		end
	else

		local numCriteria = GetAchievementNumCriteria(achievementId)
		if numCriteria > 0 then

			local criterions = {}
			for j = 1, numCriteria do

				local _, numCompleted, _ = GetAchievementCriterion(achievementId, j)
				table.insert(criterions, {
					index = j,
					numCompleted = numCompleted,
				})
			end

			table.insert(sv.Achievements, {
				achievementId = achievementId,
				completed = false,
				criterions = criterions,
			})
		end
	end
end

function ESODatabaseExport.ExportRecipe(_, recipeListIndex, recipeIndex)

    local known, name = GetRecipeInfo(recipeListIndex, recipeIndex)
    local recipeItemLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex)
    local _, _, _, recipeItemId = ZO_LinkHandler_ParseLink(recipeItemLink)

    if recipeItemId ~= "" and type(recipeItemId) ~= "nil" then

		-- Ensure the value is a number
		recipeItemId = tonumber(recipeItemId)

        if known == true then
            table.insert(sv.Recipes, recipeItemId)
        end

        if type(ESODBExportRecipes.Known[recipeItemId]) == "nil" then
            if ESODBExportUtils:GetTableIndexByFieldValue(svAccount.Unknown.Recipes, "Id", recipeItemId) == false then
                local _, icon, _, _, quality = GetRecipeResultItemInfo(recipeListIndex, recipeIndex)
                local listName = GetRecipeListInfo(recipeListIndex)
                table.insert(svAccount.Unknown.Recipes, {
                    Id = recipeItemId,
                    Name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name),
                    CategoryName = listName,
                    Quality = quality,
                    Icon = icon,
                })
            end
        end
    end
end

function ESODatabaseExport.ExportRecipes()

	sv.Recipes = {}

	local numLists = GetNumRecipeLists()
	for recipeListIndex = 1, numLists do
		local _, numRecipes = GetRecipeListInfo(recipeListIndex)
		if numRecipes > 0 then
			for recipeIndex = 1, numRecipes do
                ESODatabaseExport.ExportRecipe(nil, recipeListIndex, recipeIndex)
			end
		end
	end

	ESODatabaseExport.GlobalStore.InitialExportJobActive = false
end

function ESODatabaseExport.ExportQuestById(questId)
	table.insert(sv.Quests, questId)
end

function ESODatabaseExport.ExportCompletedQuests()

	sv.Quests = {}

	local questId = GetNextCompletedQuestId()
	while questId ~= nil do
		questId = tonumber(questId)
		ESODatabaseExport.ExportQuestById(questId)
		questId = GetNextCompletedQuestId(questId)
	end

	ESODatabaseExport.GlobalStore.InitialExportJobActive = false
end

function ESODatabaseExport.ExportLoreBook(_, categoryIndex, collectionIndex, bookIndex)

	local _, _, known = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
	local bookItemLink = GetLoreBookLink(categoryIndex, collectionIndex, bookIndex, LINK_STYLE_BRACKETS)
	local _, _, _, bookItemId = ZO_LinkHandler_ParseLink(bookItemLink)

	if bookItemId ~= "" and known then
		table.insert(sv.LoreBooks, tonumber(bookItemId))
	end
end

function ESODatabaseExport.ExportLoreBooks()

	sv.LoreBooks = {}
	sv.LoreBookCollections = {}

	local numCategories = GetNumLoreCategories()
	if numCategories > 0 then
		for categoryIndex = 1, numCategories do
			local _, numCollections = GetLoreCategoryInfo(categoryIndex)
			if numCollections > 0 then
				for collectionIndex = 1, numCollections do

					local nameCollection, _, numKnownBooks, totalBooks = GetLoreCollectionInfo(categoryIndex, collectionIndex)

					if totalBooks > 0 then
						if numKnownBooks == totalBooks then
							table.insert(sv.LoreBookCollections, zo_strformat(SI_TOOLTIP_ITEM_NAME, nameCollection))
						else

							for bookIndex = 1, totalBooks do
								ESODatabaseExport.ExportLoreBook(nil, categoryIndex, collectionIndex, bookIndex)
							end
						end
					end
				end
			end
		end
	end

	ESODatabaseExport.GlobalStore.InitialExportJobActive = false
end

function ESODatabaseExport.ExportCollectiblesForCategory(categoryIndex, subCategoryIndex, numCollectibles)

    if numCollectibles > 0 then
        for collectibleIndex = 1, numCollectibles do
            local collectibleId = GetCollectibleId(categoryIndex, subCategoryIndex, collectibleIndex)
			ESODatabaseExport.ExportCollectibleById(collectibleId)
        end
    end
end

function ESODatabaseExport.ExportCollectibleById(collectibleId)

	local _, _, _, _, unlocked, _, active, categoryType = GetCollectibleInfo(collectibleId)

	-- Valid category
	if type(ESODBExportConst.CollectionsCategoryTypes[categoryType]) ~= "nil" then

		local nickname = GetCollectibleNickname(collectibleId)

		-- Only add nickname property for entries with this value to reduce file size
		if nickname ~= "" then
			table.insert(sv.Collectibles, {
				Id = collectibleId,
				Unlocked = unlocked,
				Active = active,
				Nickname = nickname
			})
		else
			table.insert(sv.Collectibles, {
				Id = collectibleId,
				Unlocked = unlocked,
				Active = active
			})
		end
	end
end

function ESODatabaseExport.ExportCollectibles()

    sv.Collectibles = {}

    local numCategories = GetNumCollectibleCategories()
    if numCategories > 0 then
        for categoryIndex = 1, numCategories do

            local _, numSubCategories, numCollectibles = GetCollectibleCategoryInfo(categoryIndex)
            ESODatabaseExport.ExportCollectiblesForCategory(categoryIndex, nil, numCollectibles)

            if numSubCategories > 0 then
                for subCategoryIndex = 1, numSubCategories do
                    local _, subNumCollectibles = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)
                    ESODatabaseExport.ExportCollectiblesForCategory(categoryIndex, subCategoryIndex, subNumCollectibles)
                end
            end
        end
    end

	ESODatabaseExport.GlobalStore.InitialExportJobActive = false
end

function ESODatabaseExport.EventCollectibleNotificationNew(_, collectibleId)
	ESODatabaseExport.ExportCollectibleById(collectibleId)
end

function ESODatabaseExport.ExportAntiquityInfo(antiquityId)

	local numRecovered = GetNumAntiquitiesRecovered(antiquityId)
	if numRecovered > 0 then

		local numLoreEntriesAcquired = GetNumAntiquityLoreEntriesAcquired(antiquityId)
		local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(sv.Antiquities, "Id", antiquityId, {
			Id = antiquityId,
			Recovered = 0,
			LoreEntriesAcquired = 0
		})

		sv.Antiquities[tableIndex].Recovered = numRecovered
		sv.Antiquities[tableIndex].LoreEntriesAcquired = numLoreEntriesAcquired
	end
end

function ESODatabaseExport.ExportItemSetCollectionSet(itemSetId)

	local numPieces = GetNumItemSetCollectionPieces(itemSetId)
	if numPieces > 0 then
		for i = 1, numPieces do
			local pieceId = GetItemSetCollectionPieceInfo(itemSetId, i)
			if IsItemSetCollectionPieceUnlocked(pieceId) == true then
				local tableIndex = ESODBExportUtils:GetTableIndexByFieldValue(sv.ItemSetCollectionPieces, "PieceId", pieceId)
				if tableIndex == false then
					table.insert(sv.ItemSetCollectionPieces, {
						PieceId = pieceId
					})
				end
			end
		end
	end
end

function ESODatabaseExport.ExportAntiquities()

	sv.Antiquities = {}

	local ids = ESODBExportUtils:GetAntiquityIds()
	local count = #ids
	local index = 1;
	local runnerName = ESODatabaseExport.Name .. "ExportAntiquities"

	EVENT_MANAGER:UnregisterForUpdate(runnerName)
	EVENT_MANAGER:RegisterForUpdate(runnerName, ESODatabaseExport.InitialExportAntiquityDelay, function()

		ESODatabaseExport.ExportAntiquityInfo(ids[index])

		if index >= count then
			EVENT_MANAGER:UnregisterForUpdate(runnerName)
			ESODatabaseExport.GlobalStore.InitialExportJobActive = false
		end

		index = index + 1
	end)
end

function ESODatabaseExport.ExportItemSetCollections()

	sv.ItemSetCollectionPieces = {}

	local ids = ESODBExportUtils:GetItemSetCollectionIDs()
	local count = #ids
	local index = 1;
	local runnerName = ESODatabaseExport.Name .. "ExportItemSetCollection"

	EVENT_MANAGER:UnregisterForUpdate(runnerName)
	EVENT_MANAGER:RegisterForUpdate(runnerName, ESODatabaseExport.InitialExportItemSetCollectionDelay, function()

		ESODatabaseExport.ExportItemSetCollectionSet(ids[index])

		if index >= count then
			EVENT_MANAGER:UnregisterForUpdate(runnerName)
			ESODatabaseExport.GlobalStore.InitialExportJobActive = false
		end

		index = index + 1
	end)
end

function ESODatabaseExport.ExportScribing()

	sv.Scribing = {
		Grimoires = {},
		Scripts = {},
	}

	local numCraftedAbilities = GetNumCraftedAbilities()
	for i = 1, numCraftedAbilities do

		local craftedAbilityId = GetCraftedAbilityIdAtIndex(i)
		local craftedAbilityData = SCRIBING_DATA_MANAGER:GetCraftedAbilityData(craftedAbilityId)

		if craftedAbilityData:IsUnlocked() == true then
			table.insert(sv.Scribing.Grimoires, craftedAbilityId)

			for scribingSlot = SCRIBING_SLOT_ITERATION_BEGIN, SCRIBING_SLOT_ITERATION_END do
				local scriptIds = craftedAbilityData:GetScriptIdsForScribingSlot(scribingSlot)
				for _, scriptId in ipairs(scriptIds) do
					local scriptData = SCRIBING_DATA_MANAGER:GetCraftedAbilityScriptData(scriptId)
					if scriptData:IsUnlocked() == true then
						table.insert(sv.Scribing.Scripts, scriptData:GetId())
					end
				end
			end
		end
	end

	ESODatabaseExport.GlobalStore.InitialExportJobActive = false
end

function ESODatabaseExport.ExportCurrencies()

	sv.Currencies = {}
	svAccount.Currencies = ESODatabaseExport.AccountWideDefault.Currencies

	-- Character
	for _, currencyType in pairs(ESODBExportConst.Currencies.Character) do
		ESODatabaseExport.ExportCurrency(currencyType, CURRENCY_LOCATION_CHARACTER, nil)
	end

	-- Account wide
	for _, currencyType in pairs(ESODBExportConst.Currencies.Account) do
		ESODatabaseExport.ExportCurrency(currencyType, CURRENCY_LOCATION_ACCOUNT, nil)
	end

	-- Bank
	for _, currencyType in pairs(ESODBExportConst.Currencies.Bank) do
		ESODatabaseExport.ExportCurrency(currencyType, CURRENCY_LOCATION_BANK, nil)
	end
end

function ESODatabaseExport.ExportCurrency(type, location, amount)

	if amount == nil then
		amount = GetCurrencyAmount(type, location)
	end

	if location == CURRENCY_LOCATION_ACCOUNT or location == CURRENCY_LOCATION_BANK then

		local svKey
		if location == CURRENCY_LOCATION_ACCOUNT then
			svKey = "Account"
		else
			svKey = "Bank"
		end

		local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.Currencies[svKey], "CurrencyType", type, {
			CurrencyType = type,
			Amount = 0,
		})

		svAccount.Currencies[svKey][tableIndex].Amount = amount

	elseif location == CURRENCY_LOCATION_CHARACTER then

		local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(sv.Currencies, "CurrencyType", type, {
			CurrencyType = type,
			Amount = 0,
		})

		sv.Currencies[tableIndex].Amount = amount
	end
end

function ESODatabaseExport.ExportGuildRecruitment(tableIndex, guildID)

	local recruitmentStatus = GetGuildRecruitmentStatus(guildID)
	if recruitmentStatus == GUILD_RECRUITMENT_STATUS_ATTRIBUTE_VALUE_LISTED then

		local recruitmentMessage, headerMessage, _, primaryFocus, secondaryFocus, personality, language, minimumCP = GetGuildRecruitmentInfo(guildID)
		svAccount.Guilds[tableIndex].Recruitment = {
			RecruitmentMessage = recruitmentMessage,
			HeaderMessage = headerMessage,
			PrimaryFocus = primaryFocus,
			SecondaryFocus = secondaryFocus,
			Personality = personality,
			Language = language,
			MinimumCP = minimumCP,
			StartTime = GetGuildRecruitmentStartTime(guildID),
			EndTime = GetGuildRecruitmentEndTime(guildID),
			RoleDPS = GetGuildRecruitmentRoleValue(guildID, LFG_ROLE_DPS),
			RoleHeal = GetGuildRecruitmentRoleValue(guildID, LFG_ROLE_HEAL),
			RoleTank = GetGuildRecruitmentRoleValue(guildID, LFG_ROLE_TANK)
		}
	else
		svAccount.Guilds[tableIndex].Recruitment = {}
	end
end

function ESODatabaseExport.ExportGuildMembersFromQueue()

	local maxIndex = #ESODatabaseExport.GlobalStore.GuildMemberExportQueue
	if maxIndex > 0 then

		local runnerDelay = 0

		for _, guildId in ipairs(ESODatabaseExport.GlobalStore.GuildMemberExportQueue) do

			local updaterRuns = 1
			local guildNumMembers = GetNumGuildMembers(guildId)

			local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.Guilds, "Id", guildId, {
				Id = guildID
			})

			if guildNumMembers >= ESODatabaseExport.ExportGuildMembersPerRun then
				updaterRuns = math.floor(guildNumMembers / ESODatabaseExport.ExportGuildMembersPerRun)
			end

			for runnerNumber = 1, updaterRuns do

				local runnerName = ESODatabaseExport.Name .. "ExportGuildMembers_" .. guildId .. "_" .. runnerNumber
				runnerDelay = runnerDelay + ESODatabaseExport.ExportGuildMembersRunInterval

				EVENT_MANAGER:UnregisterForUpdate(runnerName)
				EVENT_MANAGER:RegisterForUpdate(runnerName, runnerDelay, function()

					local runnerStartIndex = ((runnerNumber - 1) * ESODatabaseExport.ExportGuildMembersPerRun)
					local runnerEndIndex = runnerStartIndex + ESODatabaseExport.ExportGuildMembersPerRun

					if runnerNumber == updaterRuns then
						runnerEndIndex = guildNumMembers
					end

					ESODatabaseExport.ExportGuildMembers(guildId, tableIndex, runnerStartIndex, runnerEndIndex)
					EVENT_MANAGER:UnregisterForUpdate(runnerName)
				end)
			end
		end

		ESODatabaseExport.GlobalStore.GuildMemberExportQueue = {}
	end
end

function ESODatabaseExport.ExportGuildMembers(guildID, tableIndex, startIndex, endIndex)

	local i = 0
	for m = startIndex, endIndex, 1 do

		local hasCharacter, characterName, _, classId, alliance, level, championRank = GetGuildMemberCharacterInfo(guildID, m)
		if hasCharacter then
			if type(#svAccount.Guilds[tableIndex]) ~= "nil" then
				i = #svAccount.Guilds[tableIndex].Members
				svAccount.Guilds[tableIndex].Members[(i + 1)] = {
					CharacterName = zo_strformat(SI_UNIT_NAME, characterName),
					ClassId = classId,
					AllianceId = alliance,
					Level = level,
					ChampionRank = championRank
				}
			end
		end
	end
end

function ESODatabaseExport.ExportGuild(guildIndex, guildID)

	if type(guildIndex) ~= "nil" then
		guildID = GetGuildId(guildIndex)
	end

	local guildName = GetGuildName(guildID)
	local _, _, leaderName = GetGuildInfo(guildID)
	local guildLeaderCharacterName = ESODBExportUtils:GetGuildLeaderCharacterName(guildID, leaderName)
	local guildTraderInfo = GetGuildOwnedKioskInfo(guildID)

	if type(guildTraderInfo) ~= "nil" then
		guildTraderInfo = zo_strformat(SI_GUILD_HIRED_TRADER, guildTraderInfo)
	else
		guildTraderInfo = ""
	end

	local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.Guilds, "Id", guildID, {
		Id = guildID
	})

	svAccount.Guilds[tableIndex]["Name"] = guildName
	svAccount.Guilds[tableIndex]["Megaserver"] = sv.Megaserver
	svAccount.Guilds[tableIndex]["AllianceId"] = GetGuildAlliance(guildID)
	svAccount.Guilds[tableIndex]["FoundedDate"] = GetGuildFoundedDate(guildID)
	svAccount.Guilds[tableIndex]["LeaderCharacterName"] = guildLeaderCharacterName
	svAccount.Guilds[tableIndex]["GuildTrader"] = guildTraderInfo
	svAccount.Guilds[tableIndex]["Members"] = {}
	svAccount.Guilds[tableIndex]["Recruitment"] = {}

	table.insert(sv.Guilds, guildID)
	table.insert(ESODatabaseExport.GlobalStore.GuildMemberExportQueue, guildID)

	ESODatabaseExport.ExportGuildRecruitment(tableIndex, guildID)
end

function ESODatabaseExport.ExportGuilds()

	local exportName = ESODatabaseExport.Name .. "ExportGuildMembersQueue"
	EVENT_MANAGER:UnregisterForUpdate(exportName)

	ESODatabaseExport.GlobalStore.GuildMemberExportQueue = {}
	sv.Guilds = {}
	svAccount.Guilds = {}

	local guildCount = GetNumGuilds()
	if guildCount > 0 then

		for guildIndex = 1, guildCount, 1 do
			ESODatabaseExport.ExportGuild(guildIndex, nil)
		end

		-- Export guild members for guilds
		EVENT_MANAGER:RegisterForUpdate(exportName, ESODatabaseExport.ExportGuildMembersStartDelay, function()
			ESODatabaseExport.ExportGuildMembersFromQueue()
			EVENT_MANAGER:UnregisterForUpdate(exportName)
		end)
	end
end

function ESODatabaseExport.ExportTitles()

	sv.Titles = {}

	local numTitles = GetNumTitles()
	if numTitles > 0 then
		for titleIndex = 1, numTitles do
			table.insert(sv.Titles, GetTitle(titleIndex))
		end
	end

	ESODatabaseExport.GlobalStore.InitialExportJobActive = false
end


----
--- Event Functions
----
function ESODatabaseExport.EventDisableLootTracking()
	ESODatabaseExport.GlobalStore.DisableLootTracking = true
end

function ESODatabaseExport.EventEnableLootTracking()
	ESODatabaseExport.GlobalStore.DisableLootTracking = false
end

function ESODatabaseExport.EventMoneyUpdate(_, newMoney, oldMoney, reason)

    local moneyEarned = newMoney - oldMoney
    local moneyValue = 0
    local moneyValueEarned = 0
    local moneyValuePaid = 0
    local moneyKey = ""

    -- Money looted from enemies, chests
    if reason == CURRENCY_CHANGE_REASON_LOOT then
        moneyKey = "EarnedLoot"
        moneyValue = moneyEarned
        moneyValueEarned = moneyEarned

        if moneyValue > ssv.Gold.HighestAmountLootedGold then
            ssv.Gold.HighestAmountLootedGold = moneyValue
        end

    -- Money gained from item sale to merchant
    -- Money lost from item purchase from merchant
    elseif reason == CURRENCY_CHANGE_REASON_VENDOR then

        if moneyEarned < 0 then
            moneyKey = "PaidMerchant"
            moneyValue = (moneyEarned * -1)
            moneyValuePaid = moneyValue

            if moneyValue > ssv.Gold.MostExpensivePurchaseMerchant then
                ssv.Gold.MostExpensivePurchaseMerchant = moneyValue
            end
        else
            moneyKey = "EarnedMerchant"
            moneyValue = moneyEarned
            moneyValueEarned = moneyEarned

            if moneyValue > ssv.Gold.BestSellMerchant then
                ssv.Gold.BestSellMerchant = moneyValue
            end
        end

    -- Money received from quest reward
    elseif reason == CURRENCY_CHANGE_REASON_QUESTREWARD then
        moneyKey = "EarnedQuest"
        moneyValue = moneyEarned
        moneyValueEarned = moneyEarned

    -- Money received from antiquity reward
    elseif reason == CURRENCY_CHANGE_REASON_ANTIQUITY_REWARD then
        moneyKey = "EarnedAntiquityReward"
        moneyValue = moneyEarned
        moneyValueEarned = moneyEarned

    -- Money paid to npc during quest conversation
    elseif reason == CURRENCY_CHANGE_REASON_CONVERSATION then
        moneyKey = "PaidQuestConversation"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

    -- Money paid to upgrade backpack
    elseif reason == CURRENCY_CHANGE_REASON_BAGSPACE then
        moneyKey = "PaidUpgradeBackpack"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

    -- Money paid for Wayshrine travel
    elseif reason == CURRENCY_CHANGE_REASON_TRAVEL_GRAVEYARD then
        moneyKey = "PaidWayshrineTravel"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

        -- The Fast travel event is not fired for payed fast travels
        ssv.FastTravel = ssv.FastTravel + 1

    -- Money paid for mount feed
    elseif reason == CURRENCY_CHANGE_REASON_FEED_MOUNT then
        moneyKey = "PaidMountFeed"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

    -- Money paid for item repair
    elseif reason == CURRENCY_CHANGE_REASON_VENDOR_REPAIR then
        moneyKey = "PaidRepair"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

        if moneyValue > ssv.Gold.MostExpensiveRepair then
            ssv.Gold.MostExpensiveRepair = moneyValue
        end

    -- Money paid at guild store to buy an item
    elseif reason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_PURCHASE then
        moneyKey = "PaidStore"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

        ssv.Trading.NumGuildStoreBuys = ssv.Trading.NumGuildStoreBuys + 1

        if moneyValue > ssv.Gold.MostExpensivePurchaseGuildStore then
            ssv.Gold.MostExpensivePurchaseGuildStore = moneyValue
        end

    -- Money paid for respec attributes
    elseif reason == CURRENCY_CHANGE_REASON_RESPEC_ATTRIBUTES then
        moneyKey = "PaidRespecAttributes"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

    -- Money paid for respec morphs
    elseif reason == CURRENCY_CHANGE_REASON_RESPEC_MORPHS then
        moneyKey = "PaidRespecMorphs"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

    -- Money paid for respec skills
    elseif reason == CURRENCY_CHANGE_REASON_RESPEC_SKILLS then
        moneyKey = "PaidRespecSkills"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

    -- Money paid for adding items to tradehouse
    elseif reason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_LISTING then
        moneyKey = "PaidStoreSell"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

    -- Stolen gold
    elseif reason == CURRENCY_CHANGE_REASON_LOOT_STOLEN then

        if moneyEarned > 0 then
            moneyValueEarned = moneyEarned
            ssv.Justice.PickpocketGold = ssv.Justice.PickpocketGold + moneyEarned

            if moneyEarned > ssv.Gold.HighestAmountPickpocketGold then
                ssv.Gold.HighestAmountPickpocketGold = moneyEarned
            end
        end

    -- Money received from fence
    elseif reason == CURRENCY_CHANGE_REASON_SELL_STOLEN then
        moneyKey = "EarnedFence"
        moneyValue = moneyEarned
        moneyValueEarned = moneyEarned

        if moneyValue > ssv.Gold.BestSellFence then
            ssv.Gold.BestSellFence = moneyValue
        end

    -- Money paid for launder items
    elseif reason == CURRENCY_CHANGE_REASON_VENDOR_LAUNDER then
        moneyKey = "PaidLaunder"
        moneyValue = (moneyEarned * -1)
        moneyValuePaid = moneyValue

        if moneyValue > ssv.Gold.MostExpensiveLaunder then
            ssv.Gold.MostExpensiveLaunder = moneyValue
        end
    end

    -- Set category gold amount
    if moneyKey ~= "" and moneyValue >= 0 then
        ssv.Gold[moneyKey] = ssv.Gold[moneyKey] + moneyValue
    end

    -- Increase total earned money
    if moneyValueEarned > 0 then
        ssv.Gold.EarnedTotal = ssv.Gold.EarnedTotal + moneyValueEarned
    end

    -- Increase total paid money
    if moneyValuePaid > 0 then
        ssv.Gold.PaidTotal = ssv.Gold.PaidTotal + moneyValuePaid
    end

	ESODatabaseExport.ExportGold()
end

function ESODatabaseExport.EventCurrencyUpdate(_, currencyType, currencyLocation, newAmount, oldAmount, reason)

	local currencyDiff = newAmount - oldAmount

	-- Endless Dungeon curreny tracking
	if currencyType == CURT_ENDLESS_DUNGEON then
		if reason == CURRENCY_CHANGE_REASON_VENDOR then
			currencyDiff = (currencyDiff * -1)
			ssv.EndlessDungeon.ArchiveFortunesSpent = ssv.EndlessDungeon.ArchiveFortunesSpent + currencyDiff
		elseif reason == CURRENCY_CHANGE_REASON_LOOT or reason == CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER then
			ssv.EndlessDungeon.ArchiveFortunesLooted = ssv.EndlessDungeon.ArchiveFortunesLooted + currencyDiff
			svAccount.Store.EndlessDungeon.ArchiveFortunesLooted = svAccount.Store.EndlessDungeon.ArchiveFortunesLooted + currencyDiff
		end
	end

	-- Update bank and account wide currencies
	if currencyLocation == CURRENCY_LOCATION_ACCOUNT or currencyLocation == CURRENCY_LOCATION_BANK then
		ESODatabaseExport.ExportCurrency(currencyType, currencyLocation, newAmount)
	elseif currencyLocation == CURRENCY_LOCATION_CHARACTER then
		ESODatabaseExport.ExportCurrency(currencyType, currencyLocation, newAmount)
	end
end

function ESODatabaseExport.EventTelVarStoneUpdate(_, newTelVarStones, oldTelVarStones, reason)

	local telVarStonesEarned = newTelVarStones - oldTelVarStones
	local telVarStonesValue = 0
	local telVarStonesValueEarned = 0
	local telVarStonesValueLost = 0
	local telVarStonesKey = ""

	-- Tel'Var stones from NPC
	if reason == CURRENCY_CHANGE_REASON_LOOT then
		telVarStonesKey = "EarnedNPC"
		telVarStonesValue = telVarStonesEarned
		telVarStonesValueEarned = telVarStonesEarned

		if telVarStonesValueEarned > ssv.TelVarStones.MostEarnedNPC then
			ssv.TelVarStones.MostEarnedNPC = telVarStonesValueEarned
		end

	-- Lost player death/eraned player kill
	elseif reason == CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER then

		-- Player death
		if telVarStonesEarned < 0 then
			telVarStonesKey = "LostPlayer"
			telVarStonesValue = (telVarStonesEarned * -1)
			telVarStonesValueLost = telVarStonesValue

			if telVarStonesValueLost > ssv.TelVarStones.MostLostPlayer then
				ssv.TelVarStones.MostLostPlayer = telVarStonesValueLost
			end
		else
			telVarStonesKey = "EarnedPlayer"
			telVarStonesValue = telVarStonesEarned
			telVarStonesValueLost = telVarStonesValue

			if telVarStonesValueEarned > ssv.TelVarStones.MostEarnedPlayer then
				ssv.TelVarStones.MostEarnedPlayer = telVarStonesValueEarned
			end
		end

	-- Lost death
	elseif reason == CURRENCY_CHANGE_REASON_DEATH then

		telVarStonesKey = "LostDeath"
		telVarStonesValue = (telVarStonesEarned * -1)
		telVarStonesValueLost = telVarStonesValue

		if telVarStonesValueLost > ssv.TelVarStones.MostLostDeath then
			ssv.TelVarStones.MostLostDeath = telVarStonesValueLost
		end

	-- Lost vendor
	elseif reason == CURRENCY_CHANGE_REASON_VENDOR then
		telVarStonesKey = "LostVendor"
		telVarStonesValue = (telVarStonesEarned * -1)
		telVarStonesValueLost = telVarStonesValue

		if telVarStonesValueLost > ssv.TelVarStones.MostExpensivePurchase then
			ssv.TelVarStones.MostExpensivePurchase = telVarStonesValueLost
		end
	end

	-- Set category tel var stones
	if telVarStonesKey ~= "" and telVarStonesValue >= 0 then
		ssv.TelVarStones[telVarStonesKey] = ssv.TelVarStones[telVarStonesKey] + telVarStonesValue
	end

	-- Increase total earned tel var stones
	if telVarStonesValueEarned > 0 then
		ssv.TelVarStones.EarnedTotal = ssv.TelVarStones.EarnedTotal + telVarStonesValueEarned
	end

	-- Increase total lost tel var stones
	if telVarStonesValueLost > 0 then
		ssv.TelVarStones.LostTotal = ssv.TelVarStones.LostTotal + telVarStonesValueLost
	end

	ESODatabaseExport.ExportTelVarStones()
end

function ESODatabaseExport.EventLootRecived(_, _, itemLink, quantity, _, _, self, isPickpocketLoot, _, _, isStolen)

	-- Track only own items
	if not self then
		return
	end

	-- No item logging when bank, shop, merchant... window is open
	if ESODatabaseExport.GlobalStore.DisableLootTracking == true then
		return
	end

	local indexName = ""
	local qualityIndex = ""
	local itemType = GetItemLinkItemType(itemLink)
	local quality = GetItemLinkDisplayQuality(itemLink)

	if quality == ITEM_DISPLAY_QUALITY_TRASH then
		qualityIndex = "Trash"
	elseif quality == ITEM_DISPLAY_QUALITY_NORMAL then
		qualityIndex = "Normal"
	elseif quality == ITEM_DISPLAY_QUALITY_MAGIC then
		qualityIndex = "Magic"
	elseif quality == ITEM_DISPLAY_QUALITY_ARCANE then
		qualityIndex = "Arcane"
	elseif quality == ITEM_DISPLAY_QUALITY_ARTIFACT then
		qualityIndex = "Artifact"
	elseif quality == ITEM_DISPLAY_QUALITY_LEGENDARY then
		qualityIndex = "Legendary"
	end

	if qualityIndex ~= "" then
		ssv.LootQuality[qualityIndex] = ssv.LootQuality[qualityIndex] + quantity
	end

	if itemType == ITEMTYPE_ARMOR then
		indexName = "Armors"
	elseif itemType == ITEMTYPE_WEAPON then
		indexName = "Weapons"
	elseif itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL then
		indexName = "BlacksmithingMats"
	elseif itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL then
		indexName = "ClothierMats"
	elseif itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL then
		indexName = "WoodworkingMats"
	elseif itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY then
		indexName = "EnchantingRunes"
	elseif itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL then
		indexName = "JewelryCraftingMats"
	elseif itemType == ITEMTYPE_STYLE_MATERIAL then
		indexName = "StyleMaterial"
	elseif itemType == ITEMTYPE_DRINK then
		indexName = "Drinks"
	elseif itemType == ITEMTYPE_FOOD then
		indexName = "Foods"
	elseif itemType == ITEMTYPE_SOUL_GEM then
		indexName = "SoulGems"
	elseif itemType == ITEMTYPE_RECIPE then
		indexName = "Recipes"
	elseif itemType == ITEMTYPE_LOCKPICK or itemType == ITEMTYPE_TOOL then
		indexName = "Lockpicks"
	elseif itemType == ITEMTYPE_INGREDIENT then
		indexName = "Ingredients"
	elseif itemType == ITEMTYPE_REAGENT then
		indexName = "Reagents"
	elseif itemType == ITEMTYPE_POTION then
		indexName = "Potions"
	elseif itemType == ITEMTYPE_TROPHY then
		indexName = "Trophies"
	elseif IsAlchemySolvent(itemType) == true then
		indexName = "AlchemyBase"
	elseif itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY  or itemType == ITEMTYPE_GLYPH_WEAPON then
		indexName = "Glyphs"
	elseif itemType == ITEMTYPE_TRASH then
		indexName = "Trash"
	elseif itemType == ITEMTYPE_LURE then
		indexName = "Lure"
	elseif itemType == ITEMTYPE_FISH then
		indexName = "Fishing"
	elseif itemType == ITEMTYPE_COLLECTIBLE then
		indexName = "Collectible"
	elseif itemType == ITEMTYPE_SCRIBING_INK then
		indexName = "ScribingInk"
	end

	if indexName ~= "" then
		ssv.Loot[indexName] = ssv.Loot[indexName] + quantity
	end

	if isPickpocketLoot == true or isStolen == true then
		ssv.Justice.PickpocketItems = ssv.Justice.PickpocketItems + quantity
		ssv.Justice["LootQuality" .. qualityIndex] = ssv.Justice["LootQuality" .. qualityIndex] + quantity
	end
end

function ESODatabaseExport.EventUnitDeathStateChanged(_, unitTag, isDead)

	if unitTag == "player" and isDead == true and not IsPlayerInAvAWorld() then

		ssv.Combat.Dead = ssv.Combat.Dead + 1

		if IsInstanceEndlessDungeon() then
			ssv.EndlessDungeon.Died = ssv.EndlessDungeon.Died + 1
			svAccount.Store.EndlessDungeon.Died = svAccount.Store.EndlessDungeon.Died + 1
		end

	elseif unitTag == "player" and not isDead then
		ssv.Combat.Alive = ssv.Combat.Alive + 1
	end
end

function ESODatabaseExport.EventPlayerDead()
	if IsPlayerInAvAWorld() then
		ssv.Kills.AvADeads = ssv.Kills.AvADeads + 1
	elseif IsActiveWorldBattleground() then
		ssv.Battleground.Died = ssv.Battleground.Died + 1
	end
end

function ESODatabaseExport.EventBeginLockpick()
	ESODatabaseExport.GlobalStore.CurrentLockPickDifficulty = GetLockQuality()
	ssv.Lockpicking.Total = ssv.Lockpicking.Total + 1
end

function ESODatabaseExport.TrackLockpicking(lockpickEventType)

	local difficultIndex = ESODBExportUtils:GetLockpickingDifficultyIndex(ESODatabaseExport.GlobalStore.CurrentLockPickDifficulty)
	if type(difficultIndex) ~= "nil" then
		ssv.Lockpicking[difficultIndex] = ssv.Lockpicking[difficultIndex] + 1
	end

	ssv.Lockpicking[lockpickEventType] = ssv.Lockpicking[lockpickEventType] + 1
end

function ESODatabaseExport.EventLockpickSuccess()
	ESODatabaseExport.TrackLockpicking("Success")
end

function ESODatabaseExport.EventLockpickFailed()
	ESODatabaseExport.TrackLockpicking("Fail")
end

function ESODatabaseExport.EventLockpickBroke()
	ssv.Lockpicking.Broke = ssv.Lockpicking.Broke + 1
end

function ESODatabaseExport.EventCombatEvent(_, result, _, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, damageType, _, _, _, _, overflow)

	--
	-- Track slaughterfish deads
	--
    if result == ACTION_RESULT_KILLING_BLOW and targetType == COMBAT_UNIT_TYPE_PLAYER then
		abilityName = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, abilityName))
		if ESODBExportUtils:GetLangNameMatch(abilityName, ESODBExportConst.SlaughterfishAttackStatusStrings) then
			ssv.Combat.DeathsSlaughterfish = ssv.Combat.DeathsSlaughterfish + 1
		end
    end

	if result == ACTION_RESULT_FALL_DAMAGE and targetType == COMBAT_UNIT_TYPE_PLAYER then
		ssv.Combat.FallingDmg = ssv.Combat.FallingDmg + hitValue
	end

	--
	-- Track kill stats
	--
	if (sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET or sourceType == COMBAT_UNIT_TYPE_GROUP) and (targetType == COMBAT_UNIT_TYPE_NONE or targetType == COMBAT_UNIT_TYPE_OTHER) then

		-- Tracking NPC and player kills
		if result == ACTION_RESULT_KILLING_BLOW and (sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET) then
			ssv.Kills.AvAKills = ssv.Kills.AvAKills + 1
		elseif result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP then

			local specialNPCKey = ESODBExportUtils:GetSpecialNPCKey(targetName)
			if type(specialNPCKey) ~= "nil" then
				ssv.Kills[specialNPCKey] = ssv.Kills[specialNPCKey] + 1
			end

			-- Endless Dungeon kills
			if IsInstanceEndlessDungeon() then
				ssv.EndlessDungeon.Kills = ssv.EndlessDungeon.Kills + 1
				svAccount.Store.EndlessDungeon.Kills = svAccount.Store.EndlessDungeon.Kills + 1
			end

			ssv.Kills.Kills = ssv.Kills.Kills + 1
		end
	end

	--
	-- Track damage and heal stats
	--
	if hitValue > 0 and (sourceType ~= COMBAT_UNIT_TYPE_NONE or targetType ~= COMBAT_UNIT_TYPE_NONE) then

		-- Heal event
		if ESODBExportUtils:GetCombatIsHeal(result) == true then

			-- Heal in
			if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then
				ssv.Combat.HealIn = ssv.Combat.HealIn + hitValue

				if overflow > 0 then
					ssv.Combat.HealInOverflow = ssv.Combat.HealInOverflow + overflow
				end
			end

			-- Heal out
			if sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_OTHER or sourceType == COMBAT_UNIT_TYPE_OTHER then
				ssv.Combat.HealOut = ssv.Combat.HealOut + hitValue

				if overflow > 0 then
					ssv.Combat.HealOutOverflow = ssv.Combat.HealOutOverflow + overflow
				end
			end

		-- Damage event
		elseif ESODBExportUtils:GetCombatIsDamage(result) == true then

			-- Damage out event
			if damageType > 0 and (targetType == COMBAT_UNIT_TYPE_NONE or targetType == COMBAT_UNIT_TYPE_OTHER or targetType == COMBAT_UNIT_TYPE_TARGET_DUMMY) and (sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET) then

				if targetType == COMBAT_UNIT_TYPE_TARGET_DUMMY then
					ssv.Combat.DummyDmgOut = ssv.Combat.DummyDmgOut + hitValue
				else
					ssv.Combat.DmgOut = ssv.Combat.DmgOut + hitValue
				end

			-- Damage in event
			elseif sourceName ~= "" and damageType > 0 and (targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET) and sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
				ssv.Combat.DmgIn = ssv.Combat.DmgIn + hitValue
			end
		end
	end
end

function ESODatabaseExport.EventFastTravel()
	ssv.FastTravel = ssv.FastTravel + 1
end

function ESODatabaseExport.EventQuestAdded()
	ssv.Quest.Add = ssv.Quest.Add + 1
end

function ESODatabaseExport.EventQuestCompleteDialog(_, journalIndex)
	ESODatabaseExport.GlobalStore.LastCompleteQuestRepeatType = GetJournalQuestRepeatType(journalIndex)
end

function ESODatabaseExport.EventQuestRemoved(_, isCompleted, _, questName, _, _, questID)

	if isCompleted then

		local writType = ESODBExportUtils:GetWritType(questName)
		if writType ~= CRAFTING_WRIT_NONE then

			local indexName = ""
			if writType == ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_ALCHEMIST then
				indexName = "AlchemistWritsCompleted"
			elseif writType == ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_BLACKSMITH then
				indexName = "BlacksmithWritsCompleted"
			elseif writType == ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_CLOTHIER then
				indexName = "ClothierWritsCompleted"
			elseif writType == ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_ENCHANTER then
				indexName = "EnchanterWritsCompleted"
			elseif writType == ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_PROVISIONER then
				indexName = "ProvisionerWritsCompleted"
			elseif writType == ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_WOODWORKER then
				indexName = "WoodworkerWritsCompleted"
			elseif writType == ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_JEWELRYCRAFTING then
				indexName = "JewelryCraftingWritsCompleted"
			end

			if indexName ~= "" then
				ssv.Crafting[indexName] = ssv.Crafting[indexName] + 1
			end
		end

		if ESODatabaseExport.GlobalStore.LastCompleteQuestRepeatType ~= QUEST_REPEAT_NOT_REPEATABLE and ESODatabaseExport.GlobalStore.LastCompleteQuestRepeatType ~= QUEST_REPEAT_EVENT_RESET then
			ssv.Quest.Repeatable = ssv.Quest.Repeatable + 1
		end

		ssv.Quest.Complete = ssv.Quest.Complete + 1

		ESODatabaseExport.ExportQuestById(questID)
	else
		ssv.Quest.Remove = ssv.Quest.Remove + 1
	end

	ESODatabaseExport.GlobalStore.LastCompleteQuestRepeatType = ""
end

function ESODatabaseExport.EventCraftCompleted(_, craftSkill)

	local keyName = ""

	if craftSkill == CRAFTING_TYPE_BLACKSMITHING then
		keyName = "Blacksmithing"
	elseif craftSkill == CRAFTING_TYPE_CLOTHIER then
		keyName = "Clothier"
	elseif craftSkill == CRAFTING_TYPE_ENCHANTING then
		keyName = "Enchanting"
		ESODatabaseExport.ExportEnchantingRuneTraits()
	elseif craftSkill == CRAFTING_TYPE_ALCHEMY then
		keyName = "Alchemy"
	elseif craftSkill == CRAFTING_TYPE_PROVISIONING then
		keyName = "Provisioning"
	elseif craftSkill == CRAFTING_TYPE_WOODWORKING then
		keyName = "Woodworking"
	elseif craftSkill == CRAFTING_TYPE_JEWELRYCRAFTING then
		keyName = "Jewelrycrafting"
	end

	if keyName ~= "" then
		ssv.Crafting[keyName] = ssv.Crafting[keyName] + 1
	end
end

function ESODatabaseExport.EventGroupInviteResponse(_, _, response)

	if response == GROUP_INVITE_RESPONSE_ACCEPTED then
		ssv.GroupInvitesAccepted = ssv.GroupInvitesAccepted + 1
	end
end

function ESODatabaseExport.EventGuildSelfJoinedGuild()
	ssv.GuildJoin = ssv.GuildJoin + 1
	ESODatabaseExport.ExportGuilds()
end

function ESODatabaseExport.EventGuildSelfLeftGuild()
	ssv.GuildLeave = ssv.GuildLeave + 1
	ESODatabaseExport.ExportGuilds()
end

function ESODatabaseExport.EventShowBook()
	ssv.BooksOpened = ssv.BooksOpened + 1
end

function ESODatabaseExport.EventBankedMoneyUpdate()

	local characterGold = GetCarriedCurrencyAmount(CURT_MONEY)
	local bankGold = GetBankedCurrencyAmount(CURT_MONEY)

	ssv.Gold.Total = characterGold + bankGold
	ssv.Gold.Character = characterGold
	ssv.Gold.Bank = bankGold
end

function ESODatabaseExport.EventBankedTelVarStonesUpdate()

	local characterTelVarStones = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	local bankTelVarStones = GetBankedCurrencyAmount(CURT_TELVAR_STONES)

	ssv.TelVarStones.Total = characterTelVarStones + bankTelVarStones
	ssv.TelVarStones.Character = characterTelVarStones
	ssv.TelVarStones.Bank = bankTelVarStones

	if characterTelVarStones > ssv.TelVarStones.HighestAmountOnCharacter then
		ssv.TelVarStones.HighestAmountOnCharacter = characterTelVarStones
	end
end

function ESODatabaseExport.EventExperienceUpdate(_, reason, _, previousExperience, currentExperience)

	local diff = (currentExperience - previousExperience)

	ssv.Points.ExperiencePoints = ssv.Points.ExperiencePoints + diff

	local reasonIndex = ""

	if reason == PROGRESS_REASON_KILL then
		reasonIndex = "Kill"
	elseif reason == PROGRESS_REASON_QUEST then
		reasonIndex = "Quest"
	elseif reason == PROGRESS_REASON_KEEP_REWARD then
		reasonIndex = "Keep"
	elseif reason == PROGRESS_REASON_SCRIPTED_EVENT then
		reasonIndex = "ScriptedEvent"

		-- Track completed world events
		local poiEventType = ESODBExportUtils:GetPoiEventType()
		if poiEventType == ESODBExportConst.POIEventType.DARK_ANCHOR then
			ssv.WorldEvents.DarkAnchor = ssv.WorldEvents.DarkAnchor + 1
		elseif poiEventType == ESODBExportConst.POIEventType.ABYSSAL_GEYSERS then
			ssv.WorldEvents.AbyssalGeyser = ssv.WorldEvents.AbyssalGeyser + 1
		elseif poiEventType == ESODBExportConst.POIEventType.HARROWSTORM then
			ssv.WorldEvents.Harrowstorm = ssv.WorldEvents.Harrowstorm + 1
		elseif poiEventType == ESODBExportConst.POIEventType.VOLCANIC_VENT then
			ssv.WorldEvents.VolcanicVent = ssv.WorldEvents.VolcanicVent + 1
		elseif poiEventType == ESODBExportConst.POIEventType.MIRRORMOOR_INCURSION then
			ssv.WorldEvents.MirrormoorIncursion = ssv.WorldEvents.MirrormoorIncursion + 1
		end

	elseif reason == PROGRESS_REASON_LOCK_PICK then
		reasonIndex = "LockPick"
	elseif reason == PROGRESS_REASON_DISCOVER_POI then
		reasonIndex = "POIDiscovered"
	elseif reason == PROGRESS_REASON_COMPLETE_POI then
		reasonIndex = "POICompleted"
	elseif reason == PROGRESS_REASON_OVERLAND_BOSS_KILL then
		reasonIndex = "OverlandBossKill"
	end

	if reasonIndex ~= "" then
		ssv.ExperiencePointsSource[reasonIndex] = ssv.ExperiencePointsSource[reasonIndex] + diff
	end
end

function ESODatabaseExport.EventChampionPointGained()
	sv.Level.ChampionPoints = GetPlayerChampionPointsEarned()
	sv.Level.ChampionXPCurrent = GetPlayerChampionXP()
	sv.Level.ChampionXPMax = GetNumChampionXPInChampionPoint(sv.Level.ChampionPoints)
	sv.Level.ChampionAttribute = GetChampionPointPoolForRank(sv.Level.ChampionPoints + 1)
end

function ESODatabaseExport.EventLevelUpdate()

	sv.AvailableSkillPoints = GetAvailableSkillPoints()

	ESODatabaseExport.ExportLevel()
end

function ESODatabaseExport.EventChampionLevelAchieved()
	ESODatabaseExport.ExportChampionRank()
end

function ESODatabaseExport.EventAlliancePointUpdate(_, _, _, difference)

	if difference > 0 then
		ssv.Points.AlliancePoints = ssv.Points.AlliancePoints + difference
	end

	ESODatabaseExport.ExportAvA()
end

function ESODatabaseExport.EventInventoryItemDestroyed()
	ssv.Loot.Destroyed = ssv.Loot.Destroyed + 1
end

function ESODatabaseExport.EventJusticePickpocketFailed()
	ssv.Justice.PickpocketFailed = ssv.Justice.PickpocketFailed + 1
end

function ESODatabaseExport.EventJusticeBountyPayoffAmountUpdated(_, oldBounty, newBounty)

	if newBounty > oldBounty then
		ssv.Justice.BountyReceived = ssv.Justice.BountyReceived + (newBounty - oldBounty)
	elseif newBounty == 0 and oldBounty ~= 0 then
		ssv.Justice.BountyPaid = ssv.Justice.BountyPaid + oldBounty
	end

	ESODatabaseExport.ExportJusticeInfo()
end

function ESODatabaseExport.EventJusticeStolenItemsRemoved()
	ssv.Justice.NumItemsRemoved = ssv.Justice.NumItemsRemoved + 1
	ESODatabaseExport.ExportJusticeInfo()
end

function ESODatabaseExport.EventJusticeFenceUpdate(_, sellsUsed, laundersUsed)

	local numSells = sellsUsed - ESODatabaseExport.GlobalStore.FenceSellsUsed
	local numLaunders = laundersUsed - ESODatabaseExport.GlobalStore.FenceLaundersUsed

	if numSells > 0 then
		ssv.Justice.FenceSells = ssv.Justice.FenceSells + numSells
	end

	if numLaunders > 0 then
		ssv.Justice.FenceLaunders = ssv.Justice.FenceLaunders + numLaunders
	end

	ESODatabaseExport.GlobalStore.FenceSellsUsed = sellsUsed
	ESODatabaseExport.GlobalStore.FenceLaundersUsed = laundersUsed
end

function ESODatabaseExport.EventMailInboxUpdate()

	ESODatabaseExport.GlobalStore.MailCache.GuildStore = {}
	ESODatabaseExport.GlobalStore.MailCache.WorthyReward = {}

	local numMails = GetNumMailItems()
	if numMails > 0 then

		local mailId = GetNextMailId()
		while mailId ~= nil do

			local _, attachedMoney = GetMailAttachmentInfo(mailId)

			if attachedMoney > 0 then

				local _, _, subject = GetMailItemInfo(mailId)
				local _, returned, fromSystem, fromCustomerService = GetMailFlags(mailId)

				if ESODBExportUtils:IsGuildStoreMail(mailId, returned, fromSystem, fromCustomerService) then
					ESODatabaseExport.GlobalStore.MailCache.GuildStore[mailId] = attachedMoney
				elseif ESODBExportUtils:IsWorthyRewardMail(subject, returned, fromSystem, fromCustomerService) then
					ESODatabaseExport.GlobalStore.MailCache.WorthyReward[mailId] = attachedMoney
				end
			end

			mailId = GetNextMailId(mailId)
		end
	end
end

function ESODatabaseExport.EventMailTakeAttachedMoneySuccess(_, mailId)

	if type(ESODatabaseExport.GlobalStore.MailCache.GuildStore[mailId]) ~= "nil" then
		ssv.Gold.EarnedGuildStore = ssv.Gold.EarnedGuildStore + ESODatabaseExport.GlobalStore.MailCache.GuildStore[mailId]
		ssv.Gold.EarnedTotal = ssv.Gold.EarnedTotal + ESODatabaseExport.GlobalStore.MailCache.GuildStore[mailId]

		ssv.Trading.NumGuildStoreSells = ssv.Trading.NumGuildStoreSells + 1

		if ESODatabaseExport.GlobalStore.MailCache.GuildStore[mailId] > ssv.Gold.BestSellGuildStore then
			ssv.Gold.BestSellGuildStore = ESODatabaseExport.GlobalStore.MailCache.GuildStore[mailId]
		end
	end

	if type(ESODatabaseExport.GlobalStore.MailCache.WorthyReward[mailId]) ~= "nil" then
		ssv.Gold.EarnedWorthyReward = ssv.Gold.EarnedWorthyReward + ESODatabaseExport.GlobalStore.MailCache.WorthyReward[mailId]
		ssv.Gold.EarnedTotal = ssv.Gold.EarnedTotal + ESODatabaseExport.GlobalStore.MailCache.WorthyReward[mailId]
	end
end

function ESODatabaseExport.EventSellReceipt(_, _, itemQuantity)
	ssv.Trading.NumMerchantSells = ssv.Trading.NumMerchantSells + itemQuantity
end

function ESODatabaseExport.EventBuyReceipt(_, _, _, entryQuantity)
	ssv.Trading.NumMerchantBuys = ssv.Trading.NumMerchantBuys + entryQuantity
end

function ESODatabaseExport.EventBuybackReceipt(_, _, itemQuantity, money)

	ssv.Trading.NumMerchantBuybacks = ssv.Trading.NumMerchantBuybacks + itemQuantity
	ssv.Gold.PaidBuyback = ssv.Gold.PaidBuyback + money

	if money > ssv.Gold.MostExpensiveBuyback then
		ssv.Gold.MostExpensiveBuyback = money
	end
end

function ESODatabaseExport.EventDuelFinished(_, duelResult, wasLocalPlayersResult)

	if duelResult == DUEL_RESULT_WON then
		if wasLocalPlayersResult == true then
			ssv.Duels.Won = ssv.Duels.Won + 1
		else
			ssv.Duels.Lost = ssv.Duels.Lost + 1
		end
	end
end

function ESODatabaseExport.EventTraitLearned()
	ESODatabaseExport.ExportAlchemyTraits()
	ESODatabaseExport.ExportEnchantingRuneTraits()
end

function ESODatabaseExport.EventSmithingTraitResearchCompleted(_, craftingSkillType, researchLineIndex, traitIndex)

	local tableIndex = ESODBExportUtils:GetTableIndexByFieldValue(sv.Tradeskills, "Id", craftingSkillType)
	if tableIndex ~= false then
		local lineTableIndex = ESODBExportUtils:GetTableIndexByFieldValue(sv.Tradeskills[tableIndex].Traits, "Id", researchLineIndex)
		if lineTableIndex == false then
			table.insert(sv.Tradeskills[tableIndex].Traits, {
				Id = researchLineIndex,
				List = {},
			})
			lineTableIndex = #sv.Tradeskills[tableIndex].Traits
			sv.Tradeskills[tableIndex].Traits[lineTableIndex].List = {}
		end

		local traitType = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
		local traitTableIndex = ESODBExportUtils:SetTableIndexByFieldValue(sv.Tradeskills[tableIndex].Traits[lineTableIndex].List, "Id", traitType, {
			Id = traitType
		})

		sv.Tradeskills[tableIndex].Traits[lineTableIndex].List[traitTableIndex]["Line"] = researchLineIndex
		sv.Tradeskills[tableIndex].Traits[lineTableIndex].List[traitTableIndex]["Trait"] = traitType
		sv.Tradeskills[tableIndex].Traits[lineTableIndex].List[traitTableIndex]["Known"] = true
	end
end

function ESODatabaseExport.EventSkillRankUpdate(_, skillType)

	if skillType == SKILL_TYPE_TRADESKILL then
		ESODatabaseExport.ExportTradeskills()
	elseif skillType == SKILL_TYPE_AVA then
		ESODatabaseExport.ExportAvA()
	end

	ESODatabaseExport.ExportSkillLines()
end

function ESODatabaseExport.EventGuildRecruitmentInfoUpdated(_, guildId)

	local tableIndex = ESODBExportUtils:SetTableIndexByFieldValue(svAccount.Guilds, "Id", guildID, {
		Id = guildID
	})

	ESODatabaseExport.ExportGuildRecruitment(tableIndex, guildId)
end

function ESODatabaseExport.EventChampionPurchaseResult(_ , result)

	if result == CHAMPION_PURCHASE_SUCCESS then
		ESODatabaseExport.ExportCharacterStats()
	end
end

function ESODatabaseExport.EventTitleUpdate(_, unitTag)

	if unitTag == "player" then
		sv.Title = GetUnitTitle("player")
	end
end

function ESODatabaseExport.EventAchievementAwarded(_, _, _, id)
	sv.AchievementPoints = GetEarnedAchievementPoints()
	ESODatabaseExport.ExportAchievementById(id)
end

function ESODatabaseExport.EventSkillPointsChanged()
	sv.AvailableSkillPoints = GetAvailableSkillPoints()
end

function ESODatabaseExport.EventSkillRespecResult(_, result)

	if result == RESPEC_RESULT_SUCCESS then
		sv.AvailableSkillPoints = GetAvailableSkillPoints()
	end
end

function ESODatabaseExport.EventZoneChanged()
	sv.ZoneId = GetZoneId(GetCurrentMapZoneIndex())
end

function ESODatabaseExport.EventHousingPrimaryResidenceSet()
	ESODatabaseExport.ExportPrimaryHouse()
end

function ESODatabaseExport.EventOnInteract(_, result, interactTargetName)

	if result ~= CLIENT_INTERACT_RESULT_SUCCESS then
		return
	end

	local name = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, interactTargetName))

	-- Backpack not working
	if ESODBExportUtils:GetLangNameMatch(name, ESODBExportConst.PsijikPortalNames) then
		ssv.Loot.PsijikPortals = ssv.Loot.PsijikPortals + 1
	elseif ESODBExportUtils:GetLangNameMatch(name, ESODBExportConst.ThievesTroveNames) == true then
		ssv.Loot.ThievesTroves = ssv.Loot.ThievesTroves + 1
	elseif ESODBExportUtils:GetLangNameMatch(name, ESODBExportConst.HeavySackNames) == true then
		ssv.Loot.HeavySacks = ssv.Loot.HeavySacks + 1
	end
end

function ESODatabaseExport.FishingInteraction()

	local action, interactableName, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
	if (action and interactableName) then

		if (ESODatabaseExport.GlobalStore.Fishing.LastAction == action) then
			return
		end

		ESODatabaseExport.GlobalStore.Fishing.LastAction = action

		if (additionalInfo == _G.ADDITIONAL_INTERACT_INFO_FISHING_NODE) then
			ESODatabaseExport.GlobalStore.Fishing.InteractableName = interactableName
		else
			local fishing = interactableName == ESODatabaseExport.GlobalStore.Fishing.InteractableName

			if (fishing) then
				ESODatabaseExport.GlobalStore.Fishing.FishingActive = true
				ESODatabaseExport.GlobalStore.Fishing.StartTimeStamp = GetTimeStamp()
			else
				ESODatabaseExport.GlobalStore.Fishing.FishingActive = false
				ESODatabaseExport.SaveTimeUsedForFishing()
			end
		end
	else
		if (ESODatabaseExport.GlobalStore.Fishing.LastAction == action) then
			return
		end

		ESODatabaseExport.GlobalStore.Fishing.LastAction = action
	end
end

function ESODatabaseExport.FishingCheckInteraction(interactionPossible)

	if (interactionPossible) then
		local action = GetGameCameraInteractableActionInfo()
		if (action ~= ESODatabaseExport.GlobalStore.Fishing.ReelIn) then
			if (ESODatabaseExport.GlobalStore.Fishing.FishingActive) then
				ESODatabaseExport.GlobalStore.Fishing.FishingActive = false
				ESODatabaseExport.SaveTimeUsedForFishing()
			end
		end
	end
end

function ESODatabaseExport.SaveTimeUsedForFishing()

	if(ESODatabaseExport.GlobalStore.Fishing.StartTimeStamp > 0) then
		local timeUsedFishing = (GetTimeStamp() - ESODatabaseExport.GlobalStore.Fishing.StartTimeStamp)
		ESODatabaseExport.GlobalStore.Fishing.StartTimeStamp = 0
		ssv.Fishing.FishingRodCasts = ssv.Fishing.FishingRodCasts + 1
		ssv.Fishing.TimeSpent = ssv.Fishing.TimeSpent + timeUsedFishing
	end
end

function ESODatabaseExport.ToggleInitialExportChatMessage()

	if type(svAccount.HideInitialExportChatMessage) == "nil" then
		svAccount.HideInitialExportChatMessage = false
	end

	if svAccount.HideInitialExportChatMessage == true then
		svAccount.HideInitialExportChatMessage = false
		ESODBExportUtils:PrintMessage(GetString(ESODB_COMMAND_DISABLE_STARTUP_MESSAGE_SHOW))
	else
		svAccount.HideInitialExportChatMessage = true
		ESODBExportUtils:PrintMessage(GetString(ESODB_COMMAND_DISABLE_STARTUP_MESSAGE_HIDDEN))
	end
end


----
--- This function is called every ESODBExport.ScanInterval seconds and on AddOn loaded.
----
function ESODatabaseExport.Export()

	local eventBaseName = ESODatabaseExport.Name .. "Delayed"
	local exportDelay = 0

	exportDelay = exportDelay + ESODatabaseExport.DataExportDelay
	EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportBaseData")
	EVENT_MANAGER:RegisterForUpdate(eventBaseName .. "ExportBaseData", exportDelay, function()
		ESODatabaseExport.ExportLevel()
		ESODatabaseExport.ExportChampionRank()
		ESODatabaseExport.ExportPrimaryHouse()
		ESODatabaseExport.ExportRidingStats()
		ESODatabaseExport.ExportGold()
		ESODatabaseExport.ExportTelVarStones()
		ESODatabaseExport.ExportAvA()
		ESODatabaseExport.ExportJusticeInfo()
		ESODatabaseExport.ExportCharacterBaseInfo()
		ESODatabaseExport.ExportCharacterStats()
		ESODatabaseExport.ExportTalesOfTributeData()
		EVENT_MANAGER:UnregisterForUpdate(eventBaseName .. "ExportBaseData")
	end)
end

----
--- This function is called only once when the AddOn has loaded.
----
function ESODatabaseExport.ExportOnce()

	-- Add one time exports to job queue
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.ExportAntiquities)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.ExportTitles)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.ExportTradeskills)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.ExportAlchemyTraits)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.UpdateTalesOfTributeClubData)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.ExportEnchantingRuneTraits)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.ExportSkillLines)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.ExportAchievements)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.ExportRecipes)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.ExportCompletedQuests)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.ExportLoreBooks)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.ExportCollectibles)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.ExportTimedActivities)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.ExportItemSetCollections)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.ExportScribing)
	table.insert(ESODatabaseExport.GlobalStore.InitialExportJobs, ESODatabaseExport.InitialDataExportComplete)

	local initialExportRunnerName = ESODatabaseExport.Name .. "InitExport"

	EVENT_MANAGER:RegisterForUpdate(initialExportRunnerName, ESODatabaseExport.InitialExportInterval, function()

		if ESODatabaseExport.GlobalStore.InitialExportJobActive == true then
			return
		end

		if #ESODatabaseExport.GlobalStore.InitialExportJobs > 0 then
			ESODatabaseExport.GlobalStore.InitialExportJobActive = true
			pcall(ESODatabaseExport.GlobalStore.InitialExportJobs[1])
			table.remove(ESODatabaseExport.GlobalStore.InitialExportJobs, 1)
		else
			EVENT_MANAGER:UnregisterForUpdate(initialExportRunnerName)
		end
	end)
end

function ESODatabaseExport.InitialDataExportComplete()

	sv.InitialDataExportComplete = true

	if type(svAccount.HideInitialExportChatMessage) == "nil" or svAccount.HideInitialExportChatMessage == false then

		local exportSeconds = zo_max((GetFrameTimeSeconds() - ESODatabaseExport.GlobalStore.InitialDataExportStartSeconds), 0)
		local formattedTime = ZO_FormatTime(exportSeconds, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS)

		ESODBExportUtils:PrintMessage(zo_strformat(GetString(ESODB_EXPORT_COMPLETE), formattedTime))
	end
end

----
--- This function is called when the user's interface loads and their
--- character is activated after logging in or performing a reload of the UI.
----
function ESODatabaseExport.PlayerActivated()
	ESODBExportUtils.OldAddonDetection()
end

----
--- This function is called when the user's interface loads and their
--- character is activated after logging in or performing a reload of the UI.
---
--- Informs about unsupported client language
----
function ESODatabaseExport.InvalidClientWarning()
	EVENT_MANAGER:UnregisterForEvent(ESODatabaseExport.Name, EVENT_PLAYER_ACTIVATED)
	ESODBExportUtils:PrintMessage(string.format(GetString(ESODB_LANGUAGE_ALERT), ESODatabaseExport.GlobalStore.Lang))
end

----
--- OnAddOnLoaded
----
function ESODatabaseExport.OnAddOnLoaded(_, addonName)

	if addonName ~= ESODatabaseExport.Name then return end

	EVENT_MANAGER:UnregisterForEvent(ESODatabaseExport.Name, EVENT_ADD_ON_LOADED)

	if ESODBExportUtils:IsSupportedLanguage() == false then
		EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_PLAYER_ACTIVATED, ESODatabaseExport.InvalidClientWarning)
		return
	end

    -- Register saved variables
	sv = ZO_SavedVars:NewCharacterIdSettings(ESODatabaseExport.SavedVariablesName , ESODatabaseExport.VariableVersion, nil, ESODatabaseExport.Default)
	svAccount = ZO_SavedVars:NewAccountWide(ESODatabaseExport.SavedVariablesName, ESODatabaseExport.AccountWideVariableVersion, nil, ESODatabaseExport.AccountWideDefault)

	----
	---  Init
	----
	sv.InitialDataExportComplete = false
	ESODatabaseExport.GlobalStore.InitialDataExportStartSeconds = GetFrameTimeSeconds()
	ESODatabaseExport.GlobalStore.Lang = string.lower(GetCVar("Language.2"))

	ESODatabaseExport.InitSavedVariableTables()
	ESODatabaseExport.InitSessionStatEntry()
	ESODatabaseExport.ClearUnknownValues()
	ESODatabaseExport.InitEndlessDungeonGlobalStorageVars()
	ESODatabaseExport.InitStatisticsDefaultValues()
	ESODatabaseExport.ExportMetaData()
	ESODatabaseExport.ExportCurrencies()
	ESODatabaseExport.Export()
	ESODatabaseExport.ExportOnce()
	ESODatabaseExport.ExportGuilds()

	-- Event filters for performance
	EVENT_MANAGER:AddFilterForEvent(ESODatabaseExport.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_IN_GAMEPAD_PREFERRED_MODE, false)
	EVENT_MANAGER:AddFilterForEvent(ESODatabaseExport.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)

	----
	---  Register Events
	----
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_PLAYER_ACTIVATED, ESODatabaseExport.PlayerActivated)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_MONEY_UPDATE, ESODatabaseExport.EventMoneyUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CURRENCY_UPDATE, ESODatabaseExport.EventCurrencyUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TELVAR_STONE_UPDATE, ESODatabaseExport.EventTelVarStoneUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LOOT_RECEIVED, ESODatabaseExport.EventLootRecived)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_UNIT_DEATH_STATE_CHANGED, ESODatabaseExport.EventUnitDeathStateChanged)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_PLAYER_DEAD, ESODatabaseExport.EventPlayerDead)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_BEGIN_LOCKPICK, ESODatabaseExport.EventBeginLockpick)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LOCKPICK_SUCCESS, ESODatabaseExport.EventLockpickSuccess)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LOCKPICK_FAILED, ESODatabaseExport.EventLockpickFailed)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LOCKPICK_BROKE, ESODatabaseExport.EventLockpickBroke)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_COMBAT_EVENT, ESODatabaseExport.EventCombatEvent)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_END_FAST_TRAVEL_INTERACTION, ESODatabaseExport.EventFastTravel)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_END_FAST_TRAVEL_KEEP_INTERACTION, ESODatabaseExport.EventFastTravel)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_QUEST_ADDED, ESODatabaseExport.EventQuestAdded)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_QUEST_COMPLETE_DIALOG, ESODatabaseExport.EventQuestCompleteDialog)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_QUEST_REMOVED, ESODatabaseExport.EventQuestRemoved)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CRAFT_COMPLETED, ESODatabaseExport.EventCraftCompleted)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_GROUP_INVITE_RESPONSE, ESODatabaseExport.EventGroupInviteResponse)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_GUILD_SELF_JOINED_GUILD, ESODatabaseExport.EventGuildSelfJoinedGuild)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_GUILD_SELF_LEFT_GUILD, ESODatabaseExport.EventGuildSelfLeftGuild)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SHOW_BOOK, ESODatabaseExport.EventShowBook)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_BANKED_MONEY_UPDATE, ESODatabaseExport.EventBankedMoneyUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_BANKED_TELVAR_STONES_UPDATE, ESODatabaseExport.EventBankedTelVarStonesUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_EXPERIENCE_GAIN, ESODatabaseExport.EventExperienceUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CHAMPION_POINT_GAINED, ESODatabaseExport.EventChampionPointGained)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LEVEL_UPDATE, ESODatabaseExport.EventLevelUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CHAMPION_LEVEL_ACHIEVED, ESODatabaseExport.EventChampionLevelAchieved)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ALLIANCE_POINT_UPDATE, ESODatabaseExport.EventAlliancePointUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_INVENTORY_ITEM_DESTROYED, ESODatabaseExport.EventInventoryItemDestroyed)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TRAIT_LEARNED, ESODatabaseExport.EventTraitLearned)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, ESODatabaseExport.EventSmithingTraitResearchCompleted)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SKILL_RANK_UPDATE, ESODatabaseExport.EventSkillRankUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_GUILD_RECRUITMENT_INFO_UPDATED, ESODatabaseExport.EventGuildRecruitmentInfoUpdated)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CHAMPION_PURCHASE_RESULT, ESODatabaseExport.EventChampionPurchaseResult)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TITLE_UPDATE, ESODatabaseExport.EventTitleUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ACHIEVEMENT_AWARDED, ESODatabaseExport.EventAchievementAwarded)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SKILL_POINTS_CHANGED, ESODatabaseExport.EventSkillPointsChanged)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SKILL_RESPEC_RESULT, ESODatabaseExport.EventSkillRespecResult)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ZONE_CHANGED, ESODatabaseExport.EventZoneChanged)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_HOUSING_PRIMARY_RESIDENCE_SET, ESODatabaseExport.EventHousingPrimaryResidenceSet)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CLIENT_INTERACT_RESULT, ESODatabaseExport.EventOnInteract)

	-- Justice events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_PICKPOCKET_FAILED, ESODatabaseExport.EventJusticePickpocketFailed)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_BOUNTY_PAYOFF_AMOUNT_UPDATED, ESODatabaseExport.EventJusticeBountyPayoffAmountUpdated)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_STOLEN_ITEMS_REMOVED, ESODatabaseExport.EventJusticeStolenItemsRemoved)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_FENCE_UPDATE, ESODatabaseExport.EventJusticeFenceUpdate)

	-- Guildstore events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_MAIL_INBOX_UPDATE, ESODatabaseExport.EventMailInboxUpdate)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS, ESODatabaseExport.EventMailTakeAttachedMoneySuccess)

	-- Trading events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SELL_RECEIPT, ESODatabaseExport.EventSellReceipt)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_BUY_RECEIPT, ESODatabaseExport.EventBuyReceipt)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_BUYBACK_RECEIPT, ESODatabaseExport.EventBuybackReceipt)

	-- Duel Events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_DUEL_FINISHED, ESODatabaseExport.EventDuelFinished)

	-- Trigger export functions
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SMITHING_TRAIT_RESEARCH_STARTED, ESODatabaseExport.ExportTradeskills)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_COLLECTIBLE_NOTIFICATION_NEW, ESODatabaseExport.EventCollectibleNotificationNew)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_RECIPE_LEARNED, ESODatabaseExport.ExportRecipe)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LORE_BOOK_LEARNED, ESODatabaseExport.ExportLoreBook)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_RIDING_SKILL_IMPROVEMENT, ESODatabaseExport.ExportRidingStats)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SKILL_LINE_ADDED, ESODatabaseExport.ExportSkillLines)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE, ESODatabaseExport.ExportSkillLines)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE, ESODatabaseExport.ExportSkillLines)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_SKILL_XP_UPDATE, ESODatabaseExport.ExportSkillLines)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_PLAYER_TITLES_UPDATE, ESODatabaseExport.ExportTitles)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_NOW_KOS, ESODatabaseExport.ExportJusticeInfo)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_NO_LONGER_KOS, ESODatabaseExport.ExportJusticeInfo)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_INFAMY_UPDATED, ESODatabaseExport.ExportJusticeInfo)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_JUSTICE_GOLD_REMOVED, ESODatabaseExport.ExportJusticeInfo)

	-- Antiquity events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ANTIQUITY_DIGGING_GAME_OVER, ESODatabaseExport.EventAntiquityDiggingGameOver)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ANTIQUITY_DIGGING_BONUS_LOOT_UNEARTHED, ESODatabaseExport.EventAntiquityDiggingBonusLootUnearthed)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ANTIQUITY_DIGGING_ANTIQUITY_UNEARTHED, ESODatabaseExport.EventAntiquityDiggingAntiquityUnearthed)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ANTIQUITY_LEAD_ACQUIRED, ESODatabaseExport.EventAntiquityLeadAcquired)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_COLLECTIBLE_USE_RESULT, ESODatabaseExport.EventCollectibleUseResult)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_REVEAL_ANTIQUITY_DIG_SITES_ON_MAP, ESODatabaseExport.EventAntiquityDigSitesOnMap)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ANTIQUITY_UPDATED, ESODatabaseExport.EventAntiquityUpdated)

	-- Item Set Collection events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ITEM_SET_COLLECTION_UPDATED, ESODatabaseExport.EventItemSetCollectionUpdated)

	-- Timed Activity
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, ESODatabaseExport.EventTimedActivityProgressUpdated)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TIMED_ACTIVITIES_UPDATED, ESODatabaseExport.ExportTimedActivities)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED, ESODatabaseExport.ExportTimedActivities)

	-- Tales of Tribute events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TRIBUTE_CLUB_EXPERIENCE_GAINED, ESODatabaseExport.UpdateTalesOfTributeClubData)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TRIBUTE_CLUB_RANK_CHANGED, ESODatabaseExport.UpdateTalesOfTributeClubData)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TRIBUTE_CLUB_INIT, ESODatabaseExport.ExportTalesOfTributeClubRank)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TRIBUTE_INVITE_ACCEPTED, ESODatabaseExport.EventTributeInviteAccepted)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TRIBUTE_INVITE_DECLINED, ESODatabaseExport.EventTributeInviteDeclined)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TRIBUTE_INVITE_SENT, ESODatabaseExport.EventTributeInviteSent)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TRIBUTE_PLAYER_TURN_STARTED, ESODatabaseExport.EventTributePlayerTurnStarted)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, ESODatabaseExport.EventTributeGameFlowStateChange)

	-- Endless Dungeon
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ENDLESS_DUNGEON_INITIALIZED, ESODatabaseExport.InitEndlessDungeonGlobalStorageVars)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ENDLESS_DUNGEON_STARTED, ESODatabaseExport.EventEndlessDungeonStarted)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ENDLESS_DUNGEON_COMPLETED, ESODatabaseExport.EventEndlessDungeonCompleted)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ENDLESS_DUNGEON_COUNTER_VALUE_CHANGED, ESODatabaseExport.EventEndlessDungeonCounterValueChanged)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ENDLESS_DUNGEON_BUFF_STACK_COUNT_UPDATED, ESODatabaseExport.EventEndlessDungeonBuffStackCountUpdated)

	-- Battlegrounds
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_BATTLEGROUND_STATE_CHANGED, ESODatabaseExport.EventBattlegroundStateChanged)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_BATTLEGROUND_KILL, ESODatabaseExport.EventBattlegroundKill)

	-- Housing
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_HOUSING_FURNITURE_PLACED, ESODatabaseExport.EventHousingFurniturePlaced)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_HOUSING_FURNITURE_MOVED, ESODatabaseExport.EventHousingFurnitureMoved)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_HOUSING_FURNITURE_REMOVED, ESODatabaseExport.EventHousingFurnitureRemoved)

	-- Scribing
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CRAFTED_ABILITY_LOCK_STATE_CHANGED, ESODatabaseExport.EventCraftedAbilityLockStateChanged)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CRAFTED_ABILITY_SCRIPT_LOCK_STATE_CHANGED, ESODatabaseExport.EventCraftedAbilityScriptLockStateChanged)

	-- Guilds
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_GUILD_MEMBER_ADDED, ESODatabaseExport.EventGuildMemberAdded)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_GUILD_MEMBER_REMOVED, ESODatabaseExport.EventGuildMemberRemoved)

	-- Loot tracking disable events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_OPEN_BANK, ESODatabaseExport.EventDisableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_OPEN_GUILD_BANK, ESODatabaseExport.EventDisableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_MAIL_OPEN_MAILBOX, ESODatabaseExport.EventDisableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_OPEN_TRADING_HOUSE, ESODatabaseExport.EventDisableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_OPEN_STORE, ESODatabaseExport.EventDisableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CRAFTING_STATION_INTERACT, ESODatabaseExport.EventDisableLootTracking)

	-- Loot tracking enable events
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CLOSE_BANK, ESODatabaseExport.EventEnableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CLOSE_GUILD_BANK, ESODatabaseExport.EventEnableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_MAIL_CLOSE_MAILBOX, ESODatabaseExport.EventEnableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CLOSE_TRADING_HOUSE, ESODatabaseExport.EventEnableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_CLOSE_STORE, ESODatabaseExport.EventEnableLootTracking)
	EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_END_CRAFTING_STATION_INTERACT, ESODatabaseExport.EventEnableLootTracking)

	-- Fishing time
	ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", ESODatabaseExport.FishingInteraction)
	ZO_PreHookHandler(RETICLE.interact, "OnHide", ESODatabaseExport.FishingInteraction)
	ZO_PostHook(RETICLE, "TryHandlingInteraction", ESODatabaseExport.FishingCheckInteraction)


	----
	---  Register updates
	----
	EVENT_MANAGER:RegisterForUpdate(ESODatabaseExport.Name .. "ExportInterval", ESODatabaseExport.ScanInterval, ESODatabaseExport.Export)
end


----
--- AddOn init
----
EVENT_MANAGER:RegisterForEvent(ESODatabaseExport.Name, EVENT_ADD_ON_LOADED, ESODatabaseExport.OnAddOnLoaded)
SLASH_COMMANDS["/esodb"] = ESODBExportCommand.Handle
