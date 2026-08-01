ESODBExportUtils = {}

function ESODBExportUtils:PrintMessage(text)
    CHAT_SYSTEM:AddMessage("[|c2080D0" .. ESODatabaseExport.DisplayName .. "|r] " .. text)
end

function ESODBExportUtils:TableContains(tab, val)
	for _, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end

function ESODBExportUtils:IsSupportedLanguage()
	return ESODBExportUtils:TableContains(ESODBExportConst.SupportedLanguages, string.lower(GetCVar("Language.2")))
end

function ESODBExportUtils:GetCharacterInfo()

	local name = GetUnitName("player")
	local uniqueName = GetUniqueNameForCharacter(name)
	local megaserver = string.sub(uniqueName, 0, 2)

	return name, megaserver
end

function ESODBExportUtils:GetPlayerStat(name)
	return GetPlayerStat(name, STAT_BONUS_OPTION_DONT_APPLY_BONUS, STAT_SOFT_CAP_OPTION_DONT_APPLY_SOFT_CAP)
end

function ESODBExportUtils:GetCurrentAvARankProgress()

	local rank = GetUnitAvARank("player")
	local rankPoints = GetUnitAvARankPoints("player")
	local _, _, rankStartsAt, nextRankAt = GetAvARankProgress(rankPoints)

	if rankPoints >= nextRankAt then
		local lastRankPoints = GetNumPointsNeededForAvARank(rank - 1)
		local maxRankPoints = GetNumPointsNeededForAvARank(rank)
		local fullRankPoints = maxRankPoints - lastRankPoints
		return rank, fullRankPoints, fullRankPoints
	else
		return rank, rankPoints - rankStartsAt, nextRankAt - rankStartsAt
	end
end

function ESODBExportUtils:AlchemyTraitNameToIndex(name)

	local index

	name = string.lower(name)

	if type(ESODBExportConst.Alchemy.TraitNames[ESODatabaseExport.GlobalStore.Lang][name]) ~= "nil" then
		index = ESODBExportConst.Alchemy.TraitNames[ESODatabaseExport.GlobalStore.Lang][name]
	end

	return index
end

function ESODBExportUtils:GetAchievementsInLine(achievementId)

	local list = {}

	local lineAchievementId = achievementId
	while lineAchievementId ~= 0 do
		lineAchievementId = GetPreviousAchievementInLine(lineAchievementId)
		if lineAchievementId ~= 0 then
			table.insert(list, lineAchievementId)
		end
	end

	return list
end

function ESODBExportUtils:GetGuildLeaderCharacterName(guildID, leaderName)

    local charName = ""

    if leaderName ~= "" then
        local leaderIndex = GetGuildMemberIndexFromDisplayName(guildID, leaderName)
        local leaderHasCharacter, leaderCharacterName = GetGuildMemberCharacterInfo(guildID, leaderIndex)

        if leaderHasCharacter == true then
            charName = zo_strformat(SI_UNIT_NAME, leaderCharacterName)
        end
    end

    return charName
end

function ESODBExportUtils:GetLockpickingDifficultyIndex(difficulty)

	local index

	if difficulty == LOCK_QUALITY_SIMPLE then
		index = "Simple"
	elseif difficulty == LOCK_QUALITY_INTERMEDIATE then
		index = "Intermediate"
	elseif difficulty == LOCK_QUALITY_ADVANCED then
		index = "Advanced"
	elseif difficulty == LOCK_QUALITY_MASTER then
		index = "Master"
	elseif difficulty == LOCK_QUALITY_IMPOSSIBLE then
		index = "Impossible"
	end

	return index
end

function ESODBExportUtils:GetLangNameMatch(name, table)

	if type(table[ESODatabaseExport.GlobalStore.Lang]) ~= "nil" and table[ESODatabaseExport.GlobalStore.Lang] == name then
		return true
	end

	return false
end

function ESODBExportUtils:GetCombatIsHeal(result)
    return (
        result == ACTION_RESULT_HEAL or
        result == ACTION_RESULT_CRITICAL_HEAL or
        result == ACTION_RESULT_HOT_TICK or
        result == ACTION_RESULT_HOT_TICK_CRITICAL
    )
end

function ESODBExportUtils:GetCombatIsDamage(result)
    return (
        result == ACTION_RESULT_DAMAGE or
        result == ACTION_RESULT_CRITICAL_DAMAGE or
        result == ACTION_RESULT_DOT_TICK or
        result == ACTION_RESULT_DOT_TICK_CRITICAL or
        result == ACTION_RESULT_BLOCKED_DAMAGE or
        result == ACTION_RESULT_DAMAGE_SHIELDED or
        result == ACTION_RESULT_FALL_DAMAGE
    )
end

function ESODBExportUtils.OldAddonDetection()

	local AddOnManager = GetAddOnManager()
	local numAddOns = AddOnManager:GetNumAddOns()

	for addOnIndex = 1, numAddOns do
		local name, _, _, _, enabled = AddOnManager:GetAddOnInfo(addOnIndex)
		if name == "ESODBExport" and enabled == true then
			AddOnManager:SetAddOnEnabled(addOnIndex, false)
			ESODBExportUtils:PrintMessage(GetString(ESODB_OUTDATED_ADDON_ALERT))
			break
		end
	end
end

function ESODBExportUtils:IsGuildStoreMail(mailId, returned, fromSystem, fromCustomerService)

	if fromSystem == true and returned == false and fromCustomerService == false then

		local senderCharacterName = string.lower(GetMailSender(mailId))
		if ESODBExportUtils:GetLangNameMatch(senderCharacterName, ESODBExportConst.GuildStoreNames) then
			return true
		end
	end

	return false
end

function ESODBExportUtils:IsWorthyRewardMail(subject, returned, fromSystem, fromCustomerService)

	if fromSystem == true and returned == false and fromCustomerService == false then
		subject = string.lower(subject)
		if ESODBExportUtils:GetLangNameMatch(subject, ESODBExportConst.WorthyRewardMailSubjects) then
			return true
		end
	end

	return false
end

function ESODBExportUtils:GetTableIndexByFieldValue(table, field, value)

	local status = false

	for key, obj in ipairs(table) do
		if type(obj[field]) ~= "nil" then
			if obj[field] == value then
				status = key
			end
		end
	end

	return status
end

function ESODBExportUtils:SetTableIndexByFieldValue(svTable, field, value, default)

	local tableIndex = ESODBExportUtils:GetTableIndexByFieldValue(svTable, field, value)
	if tableIndex == false then
		table.insert(svTable, default)
		tableIndex = #svTable
	end

	return tableIndex
end

function ESODBExportUtils:GetWritType(questName)

	questName = string.lower(questName)

	for craftingType, nameTable in ipairs(ESODBExportConst.WritQuestNames) do
		if ESODBExportUtils:GetLangNameMatch(questName, nameTable) == true then
			return craftingType
		end
	end

	return ESODBExportConst.TradeskillWrits.CRAFTING_WRIT_NONE
end

function ESODBExportUtils:GetAntiquityDifficultyIndex(difficulty)

	local difficultyIndex = ""

	if difficulty == ANTIQUITY_DIFFICULTY_SIMPLE then
		difficultyIndex = "Simple"
	elseif difficulty == ANTIQUITY_DIFFICULTY_INTERMEDIATE then
		difficultyIndex = "Intermediate"
	elseif difficulty == ANTIQUITY_DIFFICULTY_ADVANCED then
		difficultyIndex = "Advanced"
	elseif difficulty == ANTIQUITY_DIFFICULTY_MASTER then
		difficultyIndex = "Master"
	elseif difficulty == ANTIQUITY_DIFFICULTY_ULTIMATE then
		difficultyIndex = "Ultimate"
	end

	return difficultyIndex
end

function ESODBExportUtils:GetPoiEventType()

	local poiType = ESODBExportConst.POIEventType.NONE
	local px, py = GetMapPlayerPosition("player")
	local zoneIndex = GetCurrentMapZoneIndex()
	local x, y, icon

	for poiIndex = 1, GetNumPOIs(zoneIndex) do

		x, y, _, icon = GetPOIMapInfo(zoneIndex, poiIndex)
		if icon == "/esoui/art/icons/poi/poi_portal_complete.dds" or icon == "/esoui/art/icons/poi/poi_portal_incomplete.dds" then

			x, y = x - px, y - py
			x, y = x * x, y * y

			if (x + y) < 0.0003 then

				local zoneId = tonumber(GetZoneId(zoneIndex))
				local parentZoneId = tonumber(GetParentZoneId(zoneId))

				if type(ESODBExportPOIZoneTypes.DarkAnchors[zoneId]) ~= "nil" or type(ESODBExportPOIZoneTypes.DarkAnchors[parentZoneId]) ~= "nil" then
					poiType = ESODBExportConst.POIEventType.DARK_ANCHOR
					break
				elseif type(ESODBExportPOIZoneTypes.AbyssalGeysers[zoneId]) ~= "nil" or type(ESODBExportPOIZoneTypes.AbyssalGeysers[parentZoneId]) ~= "nil" then
					poiType = ESODBExportConst.POIEventType.ABYSSAL_GEYSERS
					break
				elseif type(ESODBExportPOIZoneTypes.Harrowstorms[zoneId]) ~= "nil" or type(ESODBExportPOIZoneTypes.Harrowstorms[parentZoneId]) ~= "nil" then
					poiType = ESODBExportConst.POIEventType.HARROWSTORM
					break
				elseif type(ESODBExportPOIZoneTypes.VolcanicVents[zoneId]) ~= "nil" or type(ESODBExportPOIZoneTypes.VolcanicVents[parentZoneId]) ~= "nil" then
					poiType = ESODBExportConst.POIEventType.VOLCANIC_VENT
					break
				elseif type(ESODBExportPOIZoneTypes.MirrormoorIncursions[zoneId]) ~= "nil" or type(ESODBExportPOIZoneTypes.MirrormoorIncursions[parentZoneId]) ~= "nil" then
					poiType = ESODBExportConst.POIEventType.MIRRORMOOR_INCURSION
					break
				end
			end
		end
	end

	return poiType
end

function ESODBExportUtils:GetAntiquityIds()

	local ids = {}

	for _, antiquityData in ANTIQUITY_DATA_MANAGER:AntiquityIterator() do
		table.insert(ids, antiquityData:GetId())
	end

	return ids
end

function ESODBExportUtils:GetItemSetCollectionIDs()

	local ids = {}

	for _, itemSetCollectionData in ITEM_SET_COLLECTIONS_DATA_MANAGER:ItemSetCollectionIterator() do
		table.insert(ids, itemSetCollectionData:GetId())
	end

	return ids
end

function ESODBExportUtils:GetSpecialNPCKey(targetName)

	local npcKey
	targetName = string.lower(zo_strformat("<<1>>", targetName))

	if type(ESODBExportNPC.List[targetName]) ~= "nil" then
		npcKey = ESODBExportNPC.List[targetName]
	end

	return npcKey
end

function ESODBExportUtils:GetBattlegroundWinnerStatus()

	local highestScore = 0
	local winnerTeam
	local playerTeam = GetUnitBattlegroundTeam("player")
	local scoreTeamFireDrakes = GetCurrentBattlegroundScore(BATTLEGROUND_TEAM_FIRE_DRAKES)
	local scoreTeamPitDaemons = GetCurrentBattlegroundScore(BATTLEGROUND_TEAM_PIT_DAEMONS)
	local scoreTeamStormLords = GetCurrentBattlegroundScore(BATTLEGROUND_TEAM_STORM_LORDS)

	-- Draw counts as player team win
	if (scoreTeamFireDrakes == scoreTeamPitDaemons or scoreTeamFireDrakes == scoreTeamStormLords) and playerTeam == BATTLEGROUND_TEAM_FIRE_DRAKES then
		winnerTeam = BATTLEGROUND_TEAM_FIRE_DRAKES
	elseif (scoreTeamPitDaemons == scoreTeamFireDrakes or scoreTeamPitDaemons == scoreTeamStormLords) and playerTeam == BATTLEGROUND_TEAM_PIT_DAEMONS then
		winnerTeam = BATTLEGROUND_TEAM_PIT_DAEMONS
	elseif (scoreTeamStormLords == scoreTeamFireDrakes or scoreTeamStormLords == scoreTeamPitDaemons) and playerTeam == BATTLEGROUND_TEAM_STORM_LORDS then
		winnerTeam = BATTLEGROUND_TEAM_STORM_LORDS
	else

		-- Find the winner team based on the most points
		if(scoreTeamFireDrakes > highestScore) then
			highestScore = scoreTeamFireDrakes
			winnerTeam = BATTLEGROUND_TEAM_FIRE_DRAKES
		end

		if(scoreTeamPitDaemons > highestScore) then
			highestScore = scoreTeamPitDaemons
			winnerTeam = BATTLEGROUND_TEAM_PIT_DAEMONS
		end

		if(scoreTeamStormLords > highestScore) then
			highestScore = scoreTeamStormLords
			winnerTeam = BATTLEGROUND_TEAM_STORM_LORDS
		end
	end

	if winnerTeam == playerTeam then
		return ESODBExportConst.BattlegroundWinnerStatus.WINNER
	else
		return ESODBExportConst.BattlegroundWinnerStatus.LOSER
	end
end

function ESODBExportUtils:GetBattlegroundType()
	local battlegroundId = GetCurrentBattlegroundId()
	return GetBattlegroundGameType(battlegroundId)
end

function ESODBExportUtils:GetFurnitureCategoryIdFromFurnitureId(furnitureId)

	local _, _, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
	return GetFurnitureDataCategoryInfo(furnitureDataId)
end

function ESODBExportUtils:FurnitureCategoryIdToStatsKey(categoryId)

	local key

	if categoryId == 2 then
		key = "PlacedCategorySuite"
	elseif categoryId == 3 then
		key = "PlacedCategoryParlor"
	elseif categoryId == 4 then
		key = "PlacedCategoryLibrary"
	elseif categoryId == 5 then
		key = "PlacedCategoryDining"
	elseif categoryId == 6 then
		key = "PlacedCategoryCourtyard"
	elseif categoryId == 7 then
		key = "PlacedCategoryUndercroft"
	elseif categoryId == 8 then
		key = "PlacedCategoryHearth"
	elseif categoryId == 9 then
		key = "PlacedCategoryGallery"
	elseif categoryId == 10 then
		key = "PlacedCategoryWorkshop"
	elseif categoryId == 11 then
		key = "PlacedCategoryLighting"
	elseif categoryId == 12 then
		key = "PlacedCategoryConservatory"
	elseif categoryId == 13 then
		key = "PlacedCategoryStructures"
	elseif categoryId == 14 then
		key = "PlacedCategoryMiscellaneous"
	elseif categoryId == 16 then
		key = "PlacedCategoryMounts"
	elseif categoryId == 25 then
		key = "PlacedCategoryServices"
	elseif categoryId == 33 then
		key = "PlacedCategoryNonCombatPets"
	end

	return key
end