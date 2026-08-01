local SK = SwissKnife
local SKDC = SK.Data.common
local SKH = SK.HelperFunctions
local SKDE = SK.Data.equipmentData

local function compressEmptyChild(setId)
	local next = next
	local trackedSetsItems = SK.globalSV.trackedSetsItems
	if SKH.hasTableChild(trackedSetsItems, {setId, SK.AccName, SK.PlayerName}) then
		local tablePN = trackedSetsItems[setId][SK.AccName][SK.PlayerName]
		if tablePN ~= nil and next(tablePN) == nil then
			tablePN = nil
		end
	end
	if SKH.hasTableChild(trackedSetsItems, {setId, SK.AccName, SK.storageName}) then
		local tableSN = trackedSetsItems[setId][SK.AccName][SK.storageName]
		if tableSN ~= nil and next(tableSN) == nil then
			tableSN = nil
		end
	end
	if SKH.hasTableChild(trackedSetsItems, {setId, SK.AccName}) then
		local tableAN = trackedSetsItems[setId][SK.AccName]
		if tableAN ~= nil and next(tableAN) == nil then
			tableAN = nil
		end
	end
	local tableIS = SK.globalSV.trackedSetsItems[setId]
	if tableIS ~= nil and next(tableIS) == nil then
		tableIS = nil
	end
end

local function getCacheKey(ownerName, bagId, slotIndex)
	local key
	if ownerName ~= nil and bagId ~= nil and slotIndex ~= nil then key = "_"..ownerName.."_"..bagId.."_"..slotIndex end
	return key
end

local function getItemLinkSetInfo(itemLink)
    local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink)
	local isCompanionEquipment = GetItemLinkActorCategory(itemLink) == GAMEPLAY_ACTOR_CATEGORY_COMPANION
	if not hasSet and isCompanionEquipment and SK.savedVars.trackCompanionItems then
		hasSet = true
		setId = SK.companionsItemSetId
		setName = SK.companionsItemSetName
		isCompanionEquipment = true
	end
	return hasSet, setId, setName, isCompanionEquipment
end

local function isHouseStoreAvailable()
	for _, bagId in ipairs(SKDC.BAG_HOUSE_BANKS) do
	    for slotIndex = 0,  GetBagSize(bagId) - 1 do
		    if GetItemLinkSetInfo(GetItemLink(bagId, slotIndex)) then
			    return true
		    end
	    end
	end
	return false
end

local function isLevelConditionPass(itemLink)
    local requiredLevel = GetItemLinkRequiredLevel(itemLink)
    local requiredChampionPoints = GetItemLinkRequiredChampionPoints(itemLink)
	return SK.savedVars.trackLowLevelSetsItems or (not SK.savedVars.trackLowLevelSetsItems and
		(requiredLevel == 50 and requiredChampionPoints == 160))
end

local function isCraftedConditionPass(itemLink)
	return SK.savedVars.trackCraftedSetsItems or (not SK.savedVars.trackCraftedSetsItems and
			not IsItemLinkCrafted(itemLink))
end

local function isTrackedSetPartsItem(itemLink)
	local hasSet, setId, _, isCompanionEquipment = getItemLinkSetInfo(itemLink)
	if not hasSet then return end
	if not isCompanionEquipment then
		if not isLevelConditionPass(itemLink) then return end
		if not isCraftedConditionPass(itemLink) then return end
	end
    return true, setId
end

local function emptyCharacterTable()
	SK.trackedSetsItemsCache = {}
	local isAvailable = isHouseStoreAvailable()
	local trackedSetsItems = SK.globalSV.trackedSetsItems
	for setId, _ in pairs(trackedSetsItems) do
		SKH.setTableChild(trackedSetsItems, {setId, SK.AccName, SK.PlayerName}, nil)
		if isAvailable then
			SKH.setTableChild(trackedSetsItems, {setId, SK.AccName, SK.storageName}, nil)
		else
			if SKH.hasTableChild(trackedSetsItems, {setId, SK.AccName, SK.storageName}) then
				for bagId, _ in pairs(trackedSetsItems[setId][SK.AccName][SK.storageName]) do
					if not SKH.isValueInList(SKDC.BAG_HOUSE_BANKS, bagId) then
						SKH.setTableChild(trackedSetsItems, {setId, SK.AccName, SK.storageName, bagId}, nil)
					end
				end
			end
		end
		compressEmptyChild(setId)
	end
	if not SK.savedVars.trackCompanionItems then SK.globalSV.trackedSetsItems[SK.companionsItemSetId] = nil end
end

local function addOneTrackedSetsItem(setId, ownerName, bagId, slotIndex, itemLink)
	SKH.setTableChild(SK.globalSV.trackedSetsItems, {setId, SK.AccName, ownerName, bagId, slotIndex},
		SKH.compressItemLink(itemLink))
	local key = getCacheKey(ownerName, bagId, slotIndex)
    if key ~= nil then SKH.setTableChild(SK.trackedSetsItemsCache, {key}, setId) end
end

local function deleteOneTrackedSetsItem(bagId, slotIndex, ownerName)
	local key = getCacheKey(ownerName, bagId, slotIndex)
	local setId = SK.trackedSetsItemsCache[key]
	if setId ~= nil then
		SKH.setTableChild(SK.globalSV.trackedSetsItems, {setId, SK.AccName, ownerName, bagId, slotIndex}, nil)
	    SKH.setTableChild(SK.trackedSetsItemsCache, {key}, nil)
		return setId
	end
end

local function fillOneBagSetItems(bagId, ownerName)
    local slotsCount = GetBagSize(bagId)
    for slotIndex = 0, slotsCount - 1 do
        local itemLink = GetItemLink(bagId, slotIndex)
        local isTrackedSetParts, setId = isTrackedSetPartsItem(itemLink)
	    if isTrackedSetParts then
			addOneTrackedSetsItem(setId, ownerName, bagId, slotIndex, itemLink)
	    end
    end
end

local function updateTrackedSetItems()
	-- prevent refresh data twice
	if SK.isTrackedSetsItemsDataLoad then return end
	if SK.savedVars.trackSetsItems then
		emptyCharacterTable()
		for _, bagId in ipairs(SKDC.BAG_CHARACTERS) do
			fillOneBagSetItems(bagId, SK.PlayerName)
		end
		for _, bagId in ipairs(SKDC.BAG_BANKS) do
			if bagId ~= BAG_GUILDBANK then fillOneBagSetItems(bagId, SK.storageName) end
		end
		for _, bagId in ipairs(SKDC.BAG_HOUSE_BANKS) do
			fillOneBagSetItems(bagId, SK.storageName)
		end
		local companionOwnerName = SKH.getCurrentCompanionOwnerName()
		if companionOwnerName ~= nil and SK.savedVars.trackCompanionItems then
			fillOneBagSetItems(BAG_COMPANION_WORN, companionOwnerName)
		end
		SK.isTrackedSetsItemsDataLoad = true
	end
end

local function getTrackedSetBagIcon(owner, bag)
	if owner == SK.storageName then
		if SKH.isValueInList(SKDC.BAG_HOUSE_BANKS, bag) then
			return "SwissKnife/textures/gui/house.dds"
		elseif SKH.isValueInList(SKDC.BAG_BANKS, bag) then
			return "SwissKnife/textures/gui/chest.dds"
		end
	elseif bag == BAG_WORN or bag == BAG_COMPANION_WORN then
		return "SwissKnife/textures/gui/cowled.dds"
	elseif bag == BAG_BACKPACK then
		return "SwissKnife/textures/gui/knapsack.dds"
	end
end

local function getTrackedSetItemArmorType(itemLink)
	local equipType = GetItemLinkEquipType(itemLink)
	if SKH.isValueInList(SKDE.ITEM_PRESETS[0].equipTypes, equipType) then
		local armorType = GetItemLinkArmorType(itemLink)
		if armorType == ARMORTYPE_HEAVY then
	        return GetString(SI_SK_INFO_ARMOR_HEAVY_MARKER), GetString(SI_SK_INFO_ARMOR_HEAVY)
	    elseif armorType == ARMORTYPE_MEDIUM then
	        return GetString(SI_SK_INFO_ARMOR_MEDIUM_MARKER), GetString(SI_SK_INFO_ARMOR_MEDIUM)
	    elseif armorType == ARMORTYPE_LIGHT then
	        return GetString(SI_SK_INFO_ARMOR_LIGHT_MARKER), GetString(SI_SK_INFO_ARMOR_LIGHT)
		end
	end
	return "", nil
end

local function conditionalRefreshSetsItemsList()
	if SKMD.isVisible and SKMD.mode == SKDC.MAIN_DIALOGUE_TRACKED_SET_ITEMS_MODE then
		SKMD.setsItemsList:Refresh()
		SKMD.setsItemsList:RefreshFilters()
	else
		SKMD.needRefreshAfterOpen = true
	end
end

-- Export helper functions
SK.HelperFunctions.isHouseStoreAvailable = isHouseStoreAvailable
SK.HelperFunctions.getItemLinkSetInfo = getItemLinkSetInfo
SK.HelperFunctions.isTrackedSetPartsItem = isTrackedSetPartsItem
SK.HelperFunctions.compressEmptyChild = compressEmptyChild
SK.HelperFunctions.addOneTrackedSetsItem = addOneTrackedSetsItem
SK.HelperFunctions.deleteOneTrackedSetsItem = deleteOneTrackedSetsItem
SK.HelperFunctions.fillOneBagSetItems = fillOneBagSetItems
SK.HelperFunctions.updateTrackedSetItems = updateTrackedSetItems
SK.HelperFunctions.getTrackedSetBagIcon = getTrackedSetBagIcon
SK.HelperFunctions.getTrackedSetItemArmorType = getTrackedSetItemArmorType
SK.HelperFunctions.conditionalRefreshSetsItemsList = conditionalRefreshSetsItemsList
