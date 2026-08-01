if IsNewerEssentialHousingHubVersionAvailable() or not IsEssentialHousingHubRootPathValid() then
	return
end

local EHH = EssentialHousingHub
if not EHH then
	return
end

---[ Current Zone ]---

function EHH:IsInDifferentZone()
	local houseId = self:GetHouseId()
	local owner = self:GetOwner()
	return houseId ~= self.CurrentHouseId or owner ~= self.CurrentHouseOwner
end

function EHH:UpdateCurrentZone()
	self.CurrentHouseId = self:GetHouseId()
	self.CurrentHouseOwner = self:GetOwner()
end

function EHH:UpdateCurrentHouseStats()
	if 0 == self.CurrentHouseId then
		self.CurrentHousePopulation = 0
		self.CurrentTraditionalItems = 0
	else
		self.CurrentHousePopulation = self:GetHousePopulation()
		self.CurrentTraditionalItems = GetNumHouseFurnishingsPlaced(HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM)
	end
	self:RefreshWidget()
end

---[ Items ]---

function EHH:GetItemLinkTags(link, categoryFilter)
	local tags = {}

	local numTags = GetItemLinkNumItemTags(link)
	if numTags and 0 < numTags then
		for index = 1, numTags do
			local name, category = GetItemLinkItemTagInfo(link, index)
			if not categoryFilter or category == categoryFilter then
				local tag = { name = name, category = category }
				table.insert(tags, tag)
			end
		end
	end

	return tags
end

function EHH:GetItemLinkFurnitureBehaviorTags(link)
	return self:GetItemLinkTags(link, TAG_CATEGORY_FURNITURE_BEHAVIOR)
end

---[ Housing Editor State ]---

function EHH:IsHUDMode()
	return GetHousingEditorMode() == HOUSING_EDITOR_MODE_DISABLED
end

function EHH:IsSelectionMode()
	return GetHousingEditorMode() == HOUSING_EDITOR_MODE_SELECTION
end

function EHH:IsPlacementMode()
	return GetHousingEditorMode() == HOUSING_EDITOR_MODE_PLACEMENT
end

---[ Current House ]---

function EHH:GetHousePopulation()
	return GetCurrentHousePopulation() or 0
end

function EHH:GetHousePopulationCap()
	return GetCurrentHousePopulationCap() or 0
end

function EHH:GetHouseId()
	return GetCurrentZoneHouseId()
end

function EHH:IsHouseZone()
	return 0 ~= GetCurrentZoneHouseId()
end

function EHH:GetOwner()
	return GetCurrentHouseOwner() or "", self:GetHouseId() or 0
end

function EHH:IsOwner()
	return IsOwnerOfCurrentHouse()
end

function EHH:IsOwnerLocalPlayer(owner)
	return not owner or "" == owner or string.lower(owner) == self.DisplayNameLower
end

function EHH:IsInOwnedHouse(houseId)
	return self:IsOwner() and self:GetHouseId() == tonumber(houseId)
end

function EHH:IsCurrentHouseOpen()
	local owner, houseId = self:GetOwner()
	return 0 ~= houseId and self:IsOpenHouse(houseId, owner)
end

function EHH:AreOwnersEqual(owner1, owner2)
	local lowerOwner1 = string.lower(owner1)
	local lowerOwner2 = string.lower(owner2)

	local isLocalOwner1 = nil == lowerOwner1 or "" == lowerOwner1 or lowerOwner1 == self.DisplayNameLower
	local isLocalOwner2 = nil == lowerOwner2 or "" == lowerOwner2 or lowerOwner2 == self.DisplayNameLower
	if isLocalOwner1 then
		return isLocalOwner2
	elseif isLocalOwner2 then
		return false
	end

	return lowerOwner1 == lowerOwner2
end

function EHH:IsHousePreview()
	return self:IsHouseZone() and "" == self:GetOwner()
end

function EHH:GetPreviousHouse()
	local recentHouses = self:GetRecentlyVisitedHouses()
	if not recentHouses then
		return nil, nil
	end
	
	local numRecentHouses = #recentHouses
	if 0 == numRecentHouses then
		return nil, nil
	end
	
	local recentHouse = recentHouses[1]
	if recentHouse and 1 < numRecentHouses and self:IsHouseZone() then
		local currentHouseId = self:GetHouseId()
		local currentOwner = self:GetOwner()

		if currentHouseId == recentHouse.HouseId and self:AreOwnersEqual(currentOwner, recentHouse.Owner) then
			recentHouse = recentHouses[2]
		end
	end

	if recentHouse then
		local houseId, owner = recentHouse.HouseId, recentHouse.Owner
		return houseId, owner
	end

	return nil, nil
end

function EHH:JumpToPreviousHouse()
	local houseId, owner = self:GetPreviousHouse()
	if houseId then
		self:JumpToHouse(houseId, owner)
	else
		self:DisplayNotification("No recent homes to jump to.")
	end
end

---[ House Data ]---

function EHH:IsHouseOwned(houseId)
	if not houseId then
		houseId = GetCurrentZoneHouseId()
	end

	local collectibleId = GetCollectibleIdForHouse(houseId)
	local collected = IsCollectibleUnlocked(collectibleId) or false
	return collected
end

function EHH:GetHouseName(houseId)
	if not houseId then
		houseId = GetCurrentZoneHouseId()
	end

	local collectibleId = GetCollectibleIdForHouse(houseId)
	return GetCollectibleName(collectibleId) or ""
end

function EHH:GetHouseNickname(houseId, owner)
	local isOwner = self:IsOwnerLocalPlayer(owner)
	local collectibleId = GetCollectibleIdForHouse(houseId)
	local houseNickname

	if isOwner then
		houseNickname = GetCollectibleNickname(collectibleId)
	else
		local openHouse = self:GetOpenHouse(houseId, owner)
		if openHouse and openHouse.N and "" ~= openHouse.N then
			houseNickname = openHouse.N
		end
	end

	return houseNickname or ""
end

function EHH:GetHouseNicknameOrName(houseId, owner)
	houseId = tonumber(houseId)
	if not houseId or 0 == houseId then
		return "Primary home"
	end

	local houseName = self:GetHouseNickname(houseId, owner)
	if houseName and "" ~= houseName then
		return houseName
	end

	return self:GetHouseName(houseId)
end

function EHH:GetHouseDescription(houseId, owner)
	local name = self:GetHouseName(houseId, owner)
	local nickname = self:GetHouseNickname(houseId, owner)
	local title = "" == nickname and name or string.format("%s (%s)", name, nickname)
	local isOwner = self:IsOwnerLocalPlayer(owner)

	if isOwner then
		return title
	else
		return string.format("%s owned by %s", title, owner)
	end
end

function EHH:GetCurrentHouseNickname()
	local houseId = self:GetHouseId()
	local ownerName = self:GetOwner()
	return self:GetHouseNickname(houseId, ownerName)
end

function EHH:GetCurrentHouseNicknameOrName()
	local houseId = self:GetHouseId()
	local ownerName = self:GetOwner()
	return self:GetHouseNicknameOrName(houseId, ownerName)
end

function EHH:GetHousePreviewImage(houseId)
	return GetHousePreviewBackgroundImage(houseId or GetCurrentZoneHouseId()) or ""
end

function EHH:GetHouseIcon(houseId)
	local collectibleId = GetCollectibleIdForHouse(houseId or GetCurrentZoneHouseId())
	local _, _, houseIcon = GetCollectibleInfo(collectibleId)
	return houseIcon or ""
end

function EHH:GetAllHouses(forceRefresh)
	if forceRefresh or not self.HouseIdCache then
		if not self.HouseIdCache then
			self.HouseIdCache = {}
		else
			ZO_ClearTable(self.HouseIdCache)
		end

		for houseId = 1, 500 do
			local collectibleId = GetCollectibleIdForHouse(houseId)
			if 0 ~= collectibleId then
				local house =
				{
					Collected = self:IsHouseOwned(houseId),
					CollectibleId = collectibleId,
					Icon = self:GetHouseIcon(houseId),
					Id = houseId,
					Image = self:GetHousePreviewImage(houseId),
					Name = self:GetHouseName(houseId),
					Nickname = self:GetHouseNickname(houseId),
				}
				house.Description = "" == house.Nickname and house.Name or string.format("%s (%s)", house.Name, house.Nickname)
				self.HouseIdCache[houseId] = house
			end
		end
	end

	return self.HouseIdCache
end

function EHH:GetNumHousesOwned()
	local num = 0
	local houses = self:GetAllHouses()
	for houseId, houseData in pairs(houses) do
		if IsCollectibleUnlocked(houseData.CollectibleId) then
			num = num + 1
		end
	end
	return num
end

function EHH:GetHouseById(houseId)
	local houses = self:GetAllHouses()
	return houses[houseId]
end

function EHH:GetHouseNameById(houseId)
	local houses = self:GetAllHouses()
	local house = houses[houseId]
	return house and house.Name
end

function EHH:GetHouseByCollectibleId(collectibleId)
	collectibleId = tonumber(collectibleId)

	local houses = self:GetAllHouses()
	for _, house in pairs(houses) do
		if collectibleId == house.CollectibleId then
			return house
		end
	end

	return nil
end

function EHH:GetHouseIdByCollectibleId(collectibleId)
	local house = self:GetHouseByCollectibleId(collectibleId)
	if house then
		return house.Id
	end

	return nil
end

function EHH:FindHousesByName(search, includeNicknames)
	if nil == search or "" == search then
		return {}
	end

	if nil == includeNicknames then
		includeNicknames = true
	end

	local searchText = string.lower(search)
	local houses = self:GetAllHouses()
	local matches = {}

	for houseId, house in pairs(houses) do
		if PlainStringFind(string.lower(house.Name), searchText) or (includeNicknames and PlainStringFind(string.lower(house.Nickname), searchText)) then
			table.insert(matches, house)
		end
	end

	return matches
end

function EHH:GetHouseByName(houseName)
	local EXCLUDE_NICKNAMES = false
	local houses = self:FindHousesByName(houseName, EXCLUDE_NICKNAMES)

	if 1 == #houses then
		return houses[1]
	end
end

function EHH:GetLimitName(limitType)
	return self.Defs.FurnitureLimits[limitType] or ""
end

function EHH:GetLimit(limitType, houseId)
	if not houseId or 0 == houseId then
		houseId = self:GetHouseId()
		if not houseId or 0 == houseId then
			return 0
		end
	end

	local limitMax = GetHouseFurnishingPlacementLimit(houseId, limitType)
	local limitUsed = GetNumHouseFurnishingsPlaced(limitType)
	local limitName = self:GetLimitName(limitType)
	return limitName, limitMax, limitUsed
end

---[ Furniture ]---

function EHH:IsItemIdCollectible(itemId)
	local cName = GetCollectibleName(itemId)
	local cLink = GetCollectibleLink(itemId)
	return nil ~= cName and "" ~= cName, cName, cLink
end

function EHH:GenerateEffectLink(effectId, effectTypeId, effectTypeName)
	if not effectTypeId or not effectTypeName then
		return EHH.LINK_UNKNOWN_EFFECT
	else
		return string.format("|H1:effect:%s:%s:0:0:0:0|h%s|h", tostring(effectTypeId or 0), tostring(effectId or 0), effectTypeName or "Unknown Effect")
	end
end

function EHH:GetFurnitureLink(furnitureId)
	local id, pathIndex = self:GetFurnitureIdInfo(furnitureId)

	if self:IsEffectId(id) then
		local effectType = self:GetEffectTypeById(id)
		if not effectType then return EHH.LINK_UNKNOWN_EFFECT end

		local effectTypeId = effectType.Index
		local effectTypeName = effectType.Name

		return self:GenerateEffectLink(id, effectTypeId, effectTypeName)
	end

	local link, collectibleLink = GetPlacedFurnitureLink(id, LINK_STYLE_BRACKETS)
	if nil == link or "" == link then link = collectibleLink end
	if nil == link then link = EHH.LINK_UNKNOWN_ITEM end

	if link and pathIndex then
		local linkDataTerminator = string.find(link, "%|h")
		if linkDataTerminator then
			local linkData = string.sub(link, 1, linkDataTerminator - 1)
			local linkTerminator = string.sub(link, linkDataTerminator)
			link = string.format("%s:node%d%s", linkData, pathIndex, linkTerminator)
		end
	end

	return link
end

function EHH:GetEffectLinkInfo(link)
	if nil == link then return nil end
	local _, _, effectTypeId, effectId = string.find(link, "effect:(%d+):(%d+):")
	return tonumber(effectId), tonumber(effectTypeId)
end

function EHH:GetFurnitureLinkName(link, pathIndex, excludePathIndex)
	if pathIndex == EHH.INVALID_PATH_NODE then
		pathIndex = nil
	end

	local effectId, effectTypeId = self:GetEffectLinkInfo(link)
	if effectId and effectTypeId then
		local effectType = EHH.EffectType:GetByIndex(effectTypeId)
		return effectType and effectType.Name or ""
	end

	local name = GetItemLinkName(link)
	if nil == name or "" == name then
		name = GetCollectibleName(GetCollectibleIdFromLink(link))
	end

	if link and not pathIndex then
		local _, nodeSeparator = string.find(link, "%:node")
		if nodeSeparator then
			local nodeStartIndex = nodeSeparator + 1
			nodeSeparator = string.find(link, "%p", nodeStartIndex)
			if nodeSeparator then
				local nodeEndIndex = nodeSeparator - 1
				pathIndex = tonumber(string.sub(link, nodeStartIndex, nodeEndIndex))
			end
		end
	end

	if not excludePathIndex and pathIndex and nil ~= name and "" ~= name then
		name = string.format("(%s%d) %s", EHH.ICON_PATHING, pathIndex, name)
	end

	return name
end

function EHH:GetFurnitureLinkIconFile(link)
	local effectId, effectTypeId = self:GetEffectLinkInfo(link)
	if effectId and effectTypeId then
		return "/esoui/art/treeicons/gamepad/achievement_categoryicon_champion.dds"
	end

	local itemIcon = GetItemLinkIcon(link)
	local collectibleId = GetCollectibleIdFromLink(link)
	if nil ~= collectibleId and 0 ~= collectibleId then _, _, itemIcon = GetCollectibleInfo(collectibleId) end
	return itemIcon
end

function EHH:GetFurnitureLinkIcon(link)
	local itemIcon = self:GetFurnitureLinkIconFile(link)
	if nil ~= itemIcon and "" ~= itemIcon then itemIcon = zo_iconFormat(itemIcon) end
	return itemIcon or ""
end

function EHH:GetFurnitureLinkSetName(link)
	local setName = nil

	local effectId, effectTypeId = self:GetEffectLinkInfo(link)
	if effectId and effectTypeId then return nil end

	if nil ~= link then
		-- Map Name exceptions for consistency

		local itemId = self:GetFurnitureLinkItemId(link)
		if 137874 == itemId then return self:GetFurnitureLinkSetName(self:GetFurnitureItemIdLink(119711)) end

		-- Otherwise, parse the Set Name from the Item's Name

		local itemName = self:GetFurnitureLinkName(link)
		if nil ~= itemName then
			itemName = string.lower(itemName)

			local indexParen1 = string.find(itemName, "(", 1, true)
			if nil ~= indexParen1 then
				local indexParen2 = string.find(itemName, ")", indexParen1 + 1, true)
				if nil ~= indexParen2 then indexParen2 = indexParen2 - 1 end
				setName = string.sub(itemName, indexParen1 + 1, indexParen2)
			end
		end
	end

	return setName
end

function EHH:GetFurnitureLinkItemId(link)
	if nil == link or "" == link or link == LINK_UNKNOWN_EFFECT or link == LINK_UNKNOWN_ITEM then return nil end

	local effectId, effectTypeId = self:GetEffectLinkInfo(link)
	if effectTypeId then return self.Defs.BaseEffectItemTypeId + effectTypeId end

	local startIndex

	if string.sub(link, 4, 9) == ":item:" then
		startIndex = 10
	elseif string.sub(link, 4, 16) == ":collectible:" then
		startIndex = 17
	else
		return link
	end

	local colonIndex = string.find(link, ":", startIndex + 1)
	local pipeIndex = string.find(link, "|", startIndex + 1)

	if nil == colonIndex and nil == pipeIndex then return nil end
	if nil ~= colonIndex and nil ~= pipeIndex then colonIndex = math.min(colonIndex, pipeIndex) end

	return tonumber(string.sub(link, startIndex, (nil ~= colonIndex and colonIndex or pipeIndex) - 1))
end

function EHH:GetFurnitureItemId(id)
	local link = self:GetFurnitureLink(id)
	return self:GetFurnitureLinkItemId(link), link
end

function EHH:GetFurnitureItemIdLink(itemId)
	itemId = tonumber(itemId)
	if not itemId then
		return nil
	end

	local effectType = self:GetItemIdEffectType(itemId)
	if effectType then
		return self:GenerateEffectLink(nil, effectType.Index, effectType.Name)
	end

	local dataId = GetCollectibleFurnitureDataId(itemId)

	if nil ~= dataId and 0 ~= dataId then
		return GetCollectibleLink(itemId, LINK_STYLE_BRACKETS)
	else
		return string.format("|H1:item:%s%s|h|h", tostring(itemId), string.rep(":0", 20))
	end
end

function EHH:GetFurnitureLimitType(link)
	if nil == link or "" == link then return end

	local effectId, effectTypeId = self:GetEffectLinkInfo(link)
	if effectId and effectTypeId then return 1000, 9999 end

	local dataId, itemId, limitType, limitName
	itemId = self:GetFurnitureLinkItemId(link)

	if nil == itemId or 0 >= itemId then return end

	if self:IsItemIdCollectible(itemId) then
		dataId = GetCollectibleFurnitureDataId(itemId)
	else
		dataId = GetItemLinkFurnitureDataId(link)
	end

	if nil ~= dataId then
		_, _, _, limitType = GetFurnitureDataInfo(dataId)
		limitName = self:GetLimitName(limitType)
	end

	return limitType, limitName
end

function EHH:GetFurnitureLimitTypeByItemId(itemId)
	return self:GetFurnitureLimitType(self:GetFurnitureItemIdLink(itemId))
end

function EHH:GetFurnitureInfo(id)
	local furnitureId, pathIndex = self:GetFurnitureIdInfo(id)
	if nil == furnitureId then return nil end

	local x, y, z, pitch, yaw, roll = self:GetFurniturePositionAndOrientation(id)
	if (nil == x or (0 == x and 0 == y and 0 == z)) and not self:IsEffectId(furnitureId) then return nil end

	local link = self:GetFurnitureLink(id)
	local itemId = self:GetFurnitureLinkItemId(link)
	local name = self:GetFurnitureLinkName(link, pathIndex)
	local icon = self:GetFurnitureLinkIconFile(link)
	local collectibleId = nil
	local limitType = nil
	local dataId = nil

	if self:IsItemIdCollectible(itemId) then
		collectibleId = itemId
		dataId = GetCollectibleFurnitureDataId(collectibleId)
	else
		dataId = GetItemLinkFurnitureDataId(link)
	end

	if nil ~= dataId then
		_, _, _, limitType = GetFurnitureDataInfo(dataId)
	end

	return x, y, z, pitch, yaw, roll, itemId, collectibleId, link, name, icon, dataId, limitType
end

function EHH:RefreshFurnitureIdList()
	local list = self.FurnitureIdList
	local ts = GetFrameTimeMilliseconds()

	if not self.FurnitureIdListTimestamp or self.FurnitureIdListTimestamp < ts then
		self.FurnitureIdListTimestamp = ts

		local houseId = self:GetHouseId()
		if houseId and 0 ~= houseId then
			ZO_ClearTable(list)

			local furnitureId = GetNextPlacedHousingFurnitureId()
			while furnitureId do
				list[self:FromId64(furnitureId)] = furnitureId
				furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
			end
		end
	end

	return self.FurnitureIdList
end

function EHH:FindFurnitureId(furnitureId, link)
	local idType = type(furnitureId)
	if "number" ~= idType and "string" ~= idType then return end

	local sid = furnitureId
	if "number" == idType then
		sid = self:FromId64(furnitureId)
	end

	local idList = self.FurnitureIdList
	local id = idList[sid]
	if not id then
		idList = self:RefreshFurnitureIdList()
		id = idList[sid]
	end

	return id
end

---[ Furniture State ]---

function EHH:GetFurnitureNumStates(furnitureId)
	return GetPlacedHousingFurnitureNumObjectStates(self:FindFurnitureId(furnitureId)) or 0
end

function EHH:GetFurnitureStateByStateName(stateName, furnitureId)
	if nil == stateName then return nil end
	stateName = self:Trim(string.lower(stateName))

	if "open" == stateName then
		return self.Defs.States.ON
	end

	if "closed" == stateName then
		return self.Defs.States.OFF
	end

	if	"on" == stateName or
		"lit" == stateName or
		"light" == stateName or
		"active" == stateName or
		"inact" == stateName or
		"raised" == stateName or
		"turned up" == stateName or
		"cheesiest" == stateName or
		"stacked" == stateName or
		"scrying" == stateName or
		"sealed" == stateName then
		return self.Defs.States.ON
	end

	if	"off" == stateName or
		"extinguish" == stateName or
		"extinguished" == stateName or
		"inactive" == stateName or
		"broken" == stateName or
		"lowered" == stateName or
		"turned down" == stateName or
		"cheesy" == stateName or
		"scattered" == stateName or
		"closed" == stateName or
		"close" == stateName then
		return self.Defs.States.OFF
	end

	if	"magically lit" == stateName or
		"blue light" == stateName or
		"calm" == stateName then
		return self.Defs.States.ON
	end

	if	"naturally lit" == stateName or
		"green light" == stateName or
		"regal" == stateName or
		"open" == stateName then
		return self.Defs.States.ON2
	end

	if	"red light" == stateName or
		"passionate" == stateName then
		return self.Defs.States.ON3
	end

	if	"pure" == stateName then
		return self.Defs.States.ON4
	end

	if	"radiant" == stateName then
		return self.Defs.States.ON5
	end

	-- Fallbacks

	if furnitureId then
		-- State name lookup
		local numStates = self:GetFurnitureNumStates(furnitureId)
		local matchingStateIndex

		for stateIndex = 1, numStates do
			local furnitureStateName = self:Trim(string.lower(GetPlacedFurniturePreviewVariationDisplayName(furnitureId, stateIndex) or ""))
			if stateName == furnitureStateName then
				matchingStateIndex = stateIndex
				break
			end
		end
		
		if matchingStateIndex then
			-- Return furniture state at the index of the matching state's index within the furniture's "array" of possible states
			return self.Defs.DefaultFurnitureStates[matchingStateIndex]
		end
	end
	
	-- Partial state name
	
	if string.find(stateName, " up") or string.find(stateName, " on") or string.find(stateName, " active") or string.find(stateName, " open") then
		return self.Defs.States.ON
	elseif string.find(stateName, " down") or string.find(stateName, " off") or string.find(stateName, " inactive") or string.find(stateName, " close") then
		return self.Defs.States.OFF
	end

	return nil
end

function EHH:DoesFurnitureHaveIndexableStateNames(furnitureId)
	local numStates = GetPlacedHousingFurnitureNumObjectStates(furnitureId)
	if 0 == numStates then return false end

	local stateNames = {}
	for stateIndex = 1, numStates do
		local stateName = string.lower(GetPlacedFurniturePreviewVariationDisplayName(furnitureId, stateIndex) or "")
		if stateNames[stateName] then
			return false
		end
		stateNames[stateName] = true
	end

	return true
end

function EHH:GetFurnitureStateIndex(furnitureId, state)
	if nil == state or state == self.Defs.States.TOGGLE then return nil end

	local numStates = self:GetFurnitureNumStates(furnitureId)
	if nil == numStates or 0 == numStates then return nil end

	local stateName, stateIndex
	if self:DoesFurnitureHaveIndexableStateNames(furnitureId) then
		for variationIndex = 1, numStates do
			stateName = GetPlacedFurniturePreviewVariationDisplayName(furnitureId, variationIndex)
			if state == self:GetFurnitureStateByStateName(stateName, furnitureId) then
				stateIndex = variationIndex - 1
				break
			end
		end
	end

	if not stateIndex then
		stateIndex = self:GetTableValueKey(self.Defs.DefaultFurnitureStates, state)
		if stateIndex then
			stateIndex = stateIndex - 1
		end
	end

	return stateIndex
end

-- Furniture is assumed to be stateful.
function EHH:GetFurnitureStateByStateIndex(furnitureId, stateIndex)
	if not stateIndex then
		return
	end

	local stateName = GetPlacedFurniturePreviewVariationDisplayName(furnitureId, stateIndex)
	local state = self:GetFurnitureStateByStateName(stateName, furnitureId)
	return state or self.Defs.DefaultFurnitureStates[stateIndex]
end

function EHH:GetFurnitureState(furnitureId)
	local key = self:FromId64(furnitureId)
	if not key then
		return
	end

	local state = self.FurniturePendingStates[key]
	if state then
		return state
	end

	if self:IsEffectId(furnitureId) then
		return nil
	end
	furnitureId = self:FindFurnitureId(furnitureId)

	if 0 == GetPlacedHousingFurnitureNumObjectStates(furnitureId) then
		return nil
	end

	local stateIndex = GetPlacedHousingFurnitureCurrentObjectStateIndex(furnitureId)
	return self:GetFurnitureStateByStateIndex(furnitureId, stateIndex + 1)
end

function EHH:SetFurnitureState(furnitureIds, state)
	local result = true
	if "table" == type(furnitureIds) then
		for index, furnitureId in ipairs(furnitureIds) do
			result = result and self:SetFurnitureStateInternal(furnitureId, state)
		end
	else
		result = self:SetFurnitureStateInternal(furnitureIds, state)
	end

	return result
end

function EHH:SetFurnitureStateInternal(furnitureId, state)
	local key = self:FromId64(furnitureId)
	if not key then
		return false
	end

	local queueState = self.FurniturePendingStates[ key ]
	if queueState then
		for queueIndex, queueEntry in pairs(self.FurnitureStateQueue) do
			if queueEntry.key == key then
				table.remove(self.FurnitureStateQueue, queueIndex)
				break
			end
		end
	end

	self.FurniturePendingStates[key] = state
	table.insert(self.FurnitureStateQueue, { key = key, state = state })
	HUB_EVENT_MANAGER:RegisterForUpdate("self:UpdateFurnitureStateQueue", 1, function(...) return self:UpdateFurnitureStateQueue(...) end)
	return true
end

function EHH:UpdateFurnitureStateQueue()
	HUB_EVENT_MANAGER:UnregisterForUpdate("self:UpdateFurnitureStateQueue")

	local queueEntry = self.FurnitureStateQueue[1]
	if not queueEntry then
		return
	end
	
	local lastChangeTimestamp = self.FurnitureStateTimestamps[queueEntry.key]
	local currentTimestamp = GetFrameTimeMilliseconds()
	if lastChangeTimestamp and (currentTimestamp - lastChangeTimestamp) < self.Defs.Limits.PerFurnitureStateChangeDurationMS then
		HUB_EVENT_MANAGER:RegisterForUpdate("self:UpdateFurnitureStateQueue", self.Defs.Limits.PerFurnitureStateChangeDelayMS, function(...) return self:UpdateFurnitureStateQueue(...) end)
		return
	end

	table.remove(self.FurnitureStateQueue, 1)
	self.FurniturePendingStates[queueEntry.key] = nil

	local furnitureId = self:FindFurnitureId(queueEntry.key)
	if furnitureId then
		local numStates = self:GetFurnitureNumStates(furnitureId)
		if 0 < numStates then
			if queueEntry.state ~= self:GetFurnitureState(furnitureId) then
				local stateIndex = self:GetFurnitureStateIndex(furnitureId, queueEntry.state)
				HousingEditorRequestChangeState(furnitureId, stateIndex)
				self.FurnitureStateTimestamps[queueEntry.key] = currentTimestamp

				HUB_EVENT_MANAGER:RegisterForUpdate("self:UpdateFurnitureStateQueue", self.Defs.Limits.PerFurnitureStateChangeDelayMS, function(...) return self:UpdateFurnitureStateQueue(...) end)
				return
			end
		end
	end

	HUB_EVENT_MANAGER:RegisterForUpdate("self:UpdateFurnitureStateQueue", 1, function(...) return self:UpdateFurnitureStateQueue(...) end)
end

------[ Effects ]------

function EHH:GetEffectTypeById(id)
	return nil
end

function EHH:GetItemIdEffectType(itemId)
	return nil
end

function EHH:IsEffectItemId(itemId)
	return nil ~= self:GetItemIdEffectType(itemId)
end

function EHH:IsEffectItemLink(link)
	local effectId, effectTypeId = self:GetEffectLinkInfo(link)
	return nil ~= effectTypeId
end

function EHH:IsEffectId(id)
	return id == id and (("number" == type(id) and 8 >= #tostring(id)) or ("string" == type(id) and 8 >= #id and "-" ~= string.sub(tostring(id), 1, 1)))
end

function EHH:IsEffectGroupId(id)
	if self:IsEffectId(id) then
		id = tonumber(id)
		if id and id >= self.Defs.Limits.MinEffectGroupId and id <= self.Defs.Limits.MaxEffectGroupId then
			return true, id
		end
	end
	return false, nil
end

function EHH:GetEffectGroupBit(id)
	local id = tonumber(id)
	if id and id >= self.Defs.Limits.MinEffectGroupId and id <= self.Defs.Limits.MaxEffectGroupId then
		local ordinal = 1 + (id - self.Defs.Limits.MinEffectGroupId)
		return EHH.Bit.New(ordinal)
	end
	return nil
end

function EHH:GetEffectGroupId(bit)
	bit = tonumber(bit)
	if not bit then return nil end
	local index = EHH.Bit.FirstBit(bit)
	if index then return (-1 + self.Defs.Limits.MinEffectGroupId) + index end
	return nil
end

---[ Jumping ]---

function EHH:GetPendingJumpToHouseRequest()
	return self.HouseJumpRequest
end

function EHH:IsJumpingToHouse()
	local request = self:GetPendingJumpToHouseRequest()
	if not request then
		return false
	end

	if not request.StartTime or (GetFrameTimeMilliseconds() - request.StartTime) > self.Defs.Limits.HouseJumpRequestTimeout then
		self:CancelJumpToHouse()
		return false
	end

	local x, y, z = self:GetPlayerWorldPosition()
	if 1 < zo_distance3D(x, y, z, request.PlayerX, request.PlayerY, request.PlayerZ) then
		self:CancelJumpToHouse()
		return false
	end

	return true
end

function EHH:CancelJumpToHouse()
	if not self.IsCancelingJumpToHouse then
		self.IsCancelingJumpToHouse = true

		if self.Defs.EnableEffects then
			EHH.Effect.CancelPortalJump()
		end

		self.HouseJumpRequest = nil
		CancelCast()
		HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. ".HouseJumpRequested")

		self.IsCancelingJumpToHouse = nil
	end
end

function EHH:JumpToHouse(houseId, owner, source, suppressNotification, outsideEntrance, metaData, onSuccess, onFailure)
	houseId = 0 ~= houseId and houseId or nil

	local isOwner = self:IsOwnerLocalPlayer(owner)
	if isOwner then
		owner = nil
	else
		owner = string.lower(owner)
	end

	if not houseId and isOwner then
		houseId = self:GetPrimaryHouseId()
		if 0 == houseId or not houseId then
			return
		end
	end

	local pronoun = isOwner and "your" or string.format("%s's", owner)
	local houseNickname = self:GetHouseNicknameOrName(houseId, owner)

	if not suppressNotification then
		local outsideIndicator = isOwner and outsideEntrance and " (Outside Entrance)" or ""
		self:DisplayNotification(string.format("Jumping to %s %s%s", pronoun, houseNickname, outsideIndicator))
	end

	self:CancelJumpToHouse()
	StopAllMovement()

	local x, y, z = self:GetPlayerWorldPosition()
	self.HouseJumpRequest =
	{
		HouseId = houseId,
		Owner = owner,
		OutsideEntrance = outsideEntrance,
		Source = source,
		StartTime = GetFrameTimeMilliseconds(),
		PlayerX = x,
		PlayerY = y,
		PlayerZ = z,
		MetaData = metaData,
		OnSuccess = onSuccess,
		OnFailure = onFailure,
	}

	HUB_EVENT_MANAGER:RegisterForUpdate(self.Name .. ".HouseJumpRequested", self.Defs.Limits.HouseJumpRequestTimeout, function()
		self:OnHouseJumpRequestTimedOut(self.HouseJumpRequest)
	end)

	if isOwner then
		RequestJumpToHouse(houseId, outsideEntrance)
	else
		if houseId then
			JumpToSpecificHouse(owner, houseId)
		else
			JumpToHouse(owner)
		end
	end

	return pronoun, houseNickname
end

---[ Module Registration ]---

EssentialHousingHub.Modules.Housing = true