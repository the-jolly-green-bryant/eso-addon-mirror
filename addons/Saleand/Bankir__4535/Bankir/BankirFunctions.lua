Bankir = Bankir or {}

--Create an example itemlink of the setItem's itemId (level 50, CP160) using the itemQuality subtype.
--See UESP website for a description of the itemLink: [url]https://en.uesp.net/wiki/Online:Item_Link[/url]
--Example itemLink: "|H0:itemname:5413:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
--The following qualities are available: 357-Trash, 366-Normal, 367-Magic, 368-Arcane, 369-Artifact, 370-Legendary
--> Parameters: itemId number: The item's itemId
-->             itemLvl: The item level. If not set, default is 50
-->             itemQualitySubType number: The itemquality number of ESO, described above (standard value: 366 -> Normal)

--> Returns:    itemLink String: The generated itemLink for the item with the given quality
local function buildItemLink(itemId, itemLvl, itemQualitySubType, isCrafted)
	if itemId == nil or itemId == 0 then return end
	itemLvl = itemLvl or 50
	if not itemQualitySubType then
		if itemLvl < 50 then
			itemQualitySubType = 2 --normal lvl 1-50
		else
			itemQualitySubType = 366 --normal lvl 50 cp 160
		end
	end
	isCrafted = isCrafted or 0
	return string.format("|H1:item:%d:%d:%d:0:0:0:0:0:0:0:0:0:0:0:0:%d:%d:0:0:%d:0|h|h",
		itemId, itemQualitySubType, itemLvl, ITEMSTYLE_NONE, isCrafted, 10000)
end

-- Item link's internalLevel field is weird for Rubedite Ingot.
-- Normally, it's 1, but for Rubedite Ingot that is in guild bank it's 0 for some strange reason.
-- This function is a workaround to fix the problem of comparing item links of Rubedite Ingot
-- stacks, one of which is in bag and the other one is in guild bank and has broken internalLevel.
local function normalizeItemLink(itemLink)
	local parts = {zo_strsplit(':', itemLink)}
	-- parts[1] = "|H0"
	-- parts[2] = "item"
	-- parts[3] = itemId
	-- parts[4] = subType
	-- parts[5] = internalLevel
	if parts[5] == "0" then
		parts[5] = "1"
	end
	return table.concat(parts, ":")
end

local function isEqualItemLink(itemLink1, itemLink2)
	if not itemLink1 or not itemLink2 then
		return false
	end
	
	itemLink1 = Bankir.Functions.normalizeItemLink(itemLink1)
	itemLink2 = Bankir.Functions.normalizeItemLink(itemLink2)
	
	if itemLink1 ~= itemLink2 then
		return false
	end
	
	--[[
	if GetItemLinkItemId(itemLink1) ~= GetItemLinkItemId(itemLink2) then
		return false
	end
	if GetItemLinkDisplayQuality(itemLink1) ~= GetItemLinkDisplayQuality(itemLink2) then
		return false
	end	
	if GetItemLinkRequiredLevel(itemLink1) ~= GetItemLinkRequiredLevel(itemLink2) then
		return false
	end
	]]--
    return true
end

local function getEquipFilterType(itemLink)
	local armorType = GetItemLinkArmorType(itemLink)
	if armorType ~= ARMORTYPE_NONE then
		return armorType
	end
	local weaponType = GetItemLinkWeaponType(itemLink)
	if weaponType ~= WEAPONTYPE_NONE then
		if weaponType == WEAPONTYPE_BOW then
			return EQUIPMENT_FILTER_TYPE_BOW
		elseif weaponType == WEAPONTYPE_SHIELD then
			return EQUIPMENT_FILTER_TYPE_SHIELD
		elseif weaponType == WEAPONTYPE_HEALING_STAFF then
			return EQUIPMENT_FILTER_TYPE_RESTO_STAFF
		elseif weaponType == WEAPONTYPE_FIRE_STAFF
		or weaponType == WEAPONTYPE_FROST_STAFF
		or weaponType == WEAPONTYPE_LIGHTNING_STAFF then
			return EQUIPMENT_FILTER_TYPE_DESTRO_STAFF
		elseif weaponType == WEAPONTYPE_TWO_HANDED_SWORD
		or weaponType == WEAPONTYPE_TWO_HANDED_AXE
		or weaponType == WEAPONTYPE_TWO_HANDED_HAMMER then
			return EQUIPMENT_FILTER_TYPE_TWO_HANDED
		elseif weaponType == WEAPONTYPE_AXE
		or weaponType == WEAPONTYPE_DAGGER
		or weaponType == WEAPONTYPE_HAMMER
		or weaponType == WEAPONTYPE_SWORD then
			return EQUIPMENT_FILTER_TYPE_ONE_HANDED
		end
	end
	local equipType = GetItemLinkEquipType(itemLink)
	if equipType == EQUIP_TYPE_NECK then
		return EQUIPMENT_FILTER_TYPE_NECK
	elseif equipType == EQUIP_TYPE_RING then
		return EQUIPMENT_FILTER_TYPE_RING
	end
end

local function getNameOfType(itemType, idTypeStr)
	local s = ""
	if type(itemType) == "string" then -- Bankir custom string types
		local id = string.match(itemType, "(%d+)$") -- get ending number
		if id then
			local name = string.match(itemType, "^(%D+)") -- get starting word
			if name == "Equipment" then
				s = GetString("SI_EQUIPMENTFILTERTYPE", id)
			elseif name == "Intricate" then
				s = GetString(SI_ITEMTRAITTYPE20) -- "Intricate"
			elseif name == "Research" then
				s = GetString(SI_ITEMSELLINFORMATION3) -- "Can research"
			elseif name == "Companion" then
				s = GetString(SI_ITEM_FORMAT_STR_COMPANION) -- "Companion Item"
			elseif name == "RecipeUnknown" or name == "Unopened" then
				s = zo_strformat(GetString(SI_ALCHEMY_UNKNOWN_RESULT), GetString("SI_SPECIALIZEDITEMTYPE", id)) -- "Food recipe (unknown)"
			elseif name == "CapCP" then
				s = string.format("%s (%s %s)", GetString("SI_ITEMTYPE", id), zo_iconTextFormatNoSpace(ZO_GetGamepadChampionPointsIcon(), 18, 18, GetString(SI_ITEM_FORMAT_STR_CHAMPION)), "150-160") -- "Food (CP150-160)"
			elseif name == "Scalable" then
				s = string.format("%s (%s)", GetString("SI_ITEMTYPE", id), GetString(SI_STATS_SCALED_LEVEL)) -- "Food (Scaled level)"
			elseif name == "RepairKit" then -- return "Equipment repair kit" instead of "Tool"
				local itemLink = buildItemLink(id)
				s = GetItemLinkName(itemLink)
			end
		end
	elseif idTypeStr == "itemId" then
		local itemLink = buildItemLink(itemType)
		s = GetItemLinkName(itemLink)
	elseif idTypeStr == "itemType" then
		s = GetString("SI_ITEMTYPE", itemType)
	elseif idTypeStr == "specializedItemType" then
		s = GetString("SI_SPECIALIZEDITEMTYPE", itemType)
	end
	return s
end

local function getHouseBankName(bagId)
	local name
	local collectibleId = GetCollectibleForBag(bagId)
	if collectibleId ~= 0 then
		local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
		if collectibleData then
			name = collectibleData:GetNickname()
			if name == "" then
				name = collectibleData:GetFormattedName()
			end
		end
	end
	return name
end

local function getGuildNameFromString(guildString)
	local guildId = string.match(guildString, "(%d+)$")
	local guildName = GetGuildName(tonumber(guildId))
	if not guildName or guildName == "" then
		guildName = "Guild" .. getGuildIndexFromId(guildId)
	end
	return guildName
end

local function getGuildIndexFromId(guildId)
	for i = 1, GetNumGuilds() do
		local id = GetGuildId(i)
		if id == guildId then
			return i
		end
	end
end

local function getBagName(bagId)
	if bagId == BAG_BACKPACK then
		return GetString(SI_BAG1)
	elseif bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
		return GetString(SI_BAG2)
	elseif string.find(bagId, "Guild") then
		return getGuildNameFromString(bagId)
	elseif bagId == BAG_GUILDBANK then
		local guildId = GetSelectedGuildBankId()
		return GetGuildName(guildId)
	elseif IsHouseBankBag(bagId) then
		return getHouseBankName(bagId)
	end
end

local function checkItemForQuests(bagId, slotId)
	--DoesItemFulfillJournalQuestCondition(bagId, slotId, journalQuestIndex, stepIndex, conditionIndex)
	local result = 0
	local quests = QUEST_JOURNAL_MANAGER:GetQuestList()
	for i, questInfo in pairs(quests) do
		if questInfo.questType == QUEST_TYPE_CRAFTING then
			for conditionIndex = 1, select(5, GetJournalQuestStepInfo(questInfo.questIndex, QUEST_MAIN_STEP_INDEX)) do
				--local conditionType = select(8, GetJournalQuestConditionInfo(questInfo.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex))
				local _, current, required = GetJournalQuestConditionInfo(questInfo.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)
				if current and required then
					if DoesItemFulfillJournalQuestCondition(bagId, slotId, questInfo.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex) then
						result = result + required
					end
				end
			end
		end
	end
	return result
end

Bankir.Functions = {
	buildItemLink = buildItemLink,
	normalizeItemLink = normalizeItemLink,
	isEqualItemLink = isEqualItemLink,
	getEquipFilterType = getEquipFilterType,
	getNameOfType = getNameOfType,
	getHouseBankName = getHouseBankName,
	getGuildNameFromString = getGuildNameFromString,
	getGuildIndexFromId = getGuildIndexFromId,
	getBagName = getBagName,
	checkItemForQuests = checkItemForQuests,
}