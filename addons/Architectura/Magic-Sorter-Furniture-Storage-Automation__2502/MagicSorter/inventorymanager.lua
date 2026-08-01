local MInventoryManager = ZO_Object:Subclass()

function InstantiateMagicInventoryManager(dataManager)
	local manager = MInventoryManager:New(dataManager)
	return manager
end

function MInventoryManager:New(...)
	local object = ZO_Object.New(self)
	object:Initialize(...)
	return object
end

function MInventoryManager:Initialize(dataManager)
	self.dataManager = dataManager
	self.bagStatistics = {}
	self.characterStatistics = {}
	self.houseStatistics = {}
	self.queuedBagUpdates = {}
	self:InitializeSavedVars()
	self:InitializeStaticData()
	self:InitializeEventHandlers()
	self:InitializeTooltipHandlers()
end

function MInventoryManager:InitializeSavedVars()
	local dataManager = self:GetDataManager()
	local inventory = self:GetInventoryData()
	if "table" ~= type(inventory) then
		inventory = {}
		self.dataManager:GetData().inventory = inventory
	end
	if "table" ~= type(inventory.bags) then
		inventory.bags = {}
	end
	if "table" ~= type(inventory.characters) then
		inventory.characters = {}
	end
	if "table" ~= type(inventory.houses) then
		inventory.houses = {}
	end
end

function MInventoryManager:InitializeStaticData()
	local dataManager = self:GetDataManager()
	local eventDescriptor = dataManager.EventDescriptor .. "InventoryManager"

	self.InventoryBag = BAG_BACKPACK
	self.EventDescriptors = {
		["ACTIVATE"] = eventDescriptor .. "PlayerActivate",
		["PLACE"] = eventDescriptor .. "PlaceFurniture",
		["RETRIEVE"] = eventDescriptor .. "RetrieveFurniture",
		["INVENTORY"] = eventDescriptor .. "InventoryUpdate",
		["UPDATE_CHARACTER"] = eventDescriptor .. "UpdateCharacter",
		["UPDATE_HOUSE"] = eventDescriptor .. "UpdateHouse",
	}
end

function MInventoryManager:InitializeEventHandlers()
	local function OnPlayerActivated(...)
		self:OnPlayerActivated(...)
	end

	local function OnFurniturePlaced(...)
		self:OnFurniturePlaced(...)
	end

	local function OnFurnitureRetrieved(...)
		self:OnFurnitureRetrieved(...)
	end

	local function OnInventorySingleSlotUpdated(...)
		self:OnInventorySingleSlotUpdated(...)
	end

	EVENT_MANAGER:RegisterForEvent(self.EventDescriptors["ACTIVATE"], EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(self.EventDescriptors["PLACE"], EVENT_HOUSING_FURNITURE_PLACED, OnFurniturePlaced)
	EVENT_MANAGER:RegisterForEvent(self.EventDescriptors["RETRIEVE"], EVENT_HOUSING_FURNITURE_REMOVED, OnFurnitureRetrieved)
	EVENT_MANAGER:RegisterForEvent(self.EventDescriptors["INVENTORY"], EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySingleSlotUpdated)
end

function MInventoryManager:DestroyEventHandlers()
	for _, descriptor in pairs(self.EventDescriptors) do
		EVENT_MANAGER:UnregisterForUpdate(descriptor)
	end
end

function MInventoryManager:GetHouseId()
	return IsOwnerOfCurrentHouse() and GetCurrentZoneHouseId() or 0
end

function MInventoryManager:GetItemIdLink(itemId)
	if tonumber(itemId) then
		itemId = tonumber(itemId)
		if itemId < 0 then
			itemId = -itemId
		end
		return "|".."H1:item:"..tostring(itemId)..string.rep(":0", 20).."|h|h"
	end
end

function MInventoryManager:GetItemLinkItemId(link)
	local itemId = GetItemLinkItemId(link)
	if itemId then
		local isBound = IsItemLinkBound(link)
		if isBound then
			itemId = -itemId
		end
	end
	return itemId or 0
end

function MInventoryManager:GetFurnitureLinkInfo(link)
	if link and link ~= "" then
		local furnitureDataId = GetItemLinkFurnitureDataId(link)
		local categoryId, subcategoryId, themeId, limitId = GetFurnitureDataInfo(furnitureDataId)
		if categoryId and categoryId ~= 0 then
			return link, categoryId, subcategoryId, themeId, limitId
		end
	end
	return nil
end

function MInventoryManager:GetFurnitureItemIdInfo(itemId)
	if itemId then
		local link = self:GetItemIdLink(itemId)
		return self:GetFurnitureLinkInfo(link)
	end
end

function MInventoryManager:GetBagFurnitureInfo(bag, slot)
	if IsItemPlaceableFurniture(bag, slot) and not IsItemStolen(bag, slot) then
		local link = GetItemLink(bag, slot)
		return self:GetFurnitureLinkInfo(link)
	end
	return nil
end

function MInventoryManager:GetPlacedFurnitureInfo(furnitureId)
	local link, collectibleLink = GetPlacedFurnitureLink(furnitureId)
	if not collectibleLink or collectibleLink == "" then
		return self:GetFurnitureLinkInfo(link)
	end
	return nil
end

function MInventoryManager:IsBagFurnitureTracked(bag, slot)
	local link = self:GetBagFurnitureInfo(bag, slot)
	return nil ~= link
end

function MInventoryManager:IsPlacedFurnitureTracked(furnitureId)
	local link = self:GetPlacedFurnitureInfo(furnitureId)
	return nil ~= link
end

function MInventoryManager:GetDataManager()
	return self.dataManager
end

function MInventoryManager:GetInventoryData()
	return self.dataManager:GetData().inventory
end

function MInventoryManager:GetInventoryUpdateData()
	local data = self:GetInventoryData()
	if not data.lastUpdate then
		data.lastUpdate = {}
	end
	return data.lastUpdate
end

function MInventoryManager:GetBagInventory(bagId)
	if tonumber(bagId) then
		bagId = tonumber(bagId)
		local inventory = self:GetInventoryData().bags[bagId]
		if not inventory then
			inventory = {}
			self:GetInventoryData().bags[bagId] = inventory
		end
		return inventory
	end
end

function MInventoryManager:GetCharacterInventory(characterId)
	if not characterId then
		characterId = self:GetCurrentCharacter()
	end
	local inventory = self:GetInventoryData().characters[characterId]
	if not inventory then
		inventory = {}
		self:GetInventoryData().characters[characterId] = inventory
	end
	return inventory
end

function MInventoryManager:GetHouseInventory(houseId)
	if not houseId then
		houseId = self:GetHouseId()
	end
	if tonumber(houseId) then
		houseId = tonumber(houseId)
		local inventory = self:GetInventoryData().houses[houseId]
		if not inventory then
			inventory = {}
			self:GetInventoryData().houses[houseId] = inventory
		end
		return inventory
	end
end

function MInventoryManager:GetCurrentCharacter()
	local numCharacters = GetNumCharacters()
	local characterId = GetCurrentCharacterId()
	local characterName
	for index = 1, numCharacters do
		local name, gender, level, classId, raceId, alliance, id, locationId = GetCharacterInfo(index)
		if id == characterId then
			characterName = name
			break
		end
	end
	return characterId, characterName
end

function MInventoryManager:CalculateInventoryStatistics(inventory, stats)
	if inventory and stats then
		local categories, themes = {}, {}
		local limits = {
			[HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM] = 0,
			[HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM] = 0,
		}
		stats.categories, stats.limits, stats.themes = categories, limits, themes
		for itemId, count in pairs(inventory) do
			local link = self:GetItemIdLink(itemId)
			local furnitureDataId = GetItemLinkFurnitureDataId(link)
			local categoryId, subcategoryId, themeId, limitId = GetFurnitureDataInfo(furnitureDataId)
			if limitId and limits[limitId] then
				limits[limitId] = limits[limitId] + count
			end
			if categoryId then
				local category = categories[categoryId]
				if not category then
					category = {count = 0, subcategories = {},}
					categories[categoryId] = category
				end
				category.count = category.count + count
				if subcategoryId then
					category.subcategories[subcategoryId] = (category.subcategories[subcategoryId] or 0) + count
				end
			end
			if themeId then
				themes[themeId] = (themes[themeId] or 0) + count
			end
		end
	end
end

function MInventoryManager:GetBagStatistics(bag)
	local stats = self.bagStatistics[bag]
	if not stats then
		local inventory = self:GetBagInventory(bag)
		if inventory then
			stats = {bag = bag, size = GetBagSize(bag),}
			self:CalculateInventoryStatistics(inventory, stats)
			self.bagStatistics[bag] = stats
		end
	end
	return stats
end

function MInventoryManager:GetCharacterStatistics(characterId)
	characterId = characterId or self:GetCurrentCharacter()
	local stats = self.characterStatistics[characterId]
	if not stats then
		local inventory = self:GetCharacterInventory(characterId)
		if inventory then
			stats = {character = characterId, size = GetBagSize(bag),}
			self:CalculateInventoryStatistics(inventory, stats)
			self.characterStatistics[characterId] = stats
		end
	end
	return stats
end

function MInventoryManager:GetHouseStatistics(houseId)
	if not houseId then
		houseId = self:GetHouseId()
	end
	local stats = self.houseStatistics[houseId]
	if not stats and self:GetLastHouseUpdate(houseId) ~= 0 then
		local inventory = self:GetHouseInventory(houseId)
		if inventory then
			stats = {houseId = houseId, maxLimits = {
				[HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM] = GetHouseFurnishingPlacementLimit(houseId, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM),
				[HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM] = GetHouseFurnishingPlacementLimit(houseId, HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM),
			},}
			self:CalculateInventoryStatistics(inventory, stats)
			self.houseStatistics[houseId] = stats
		end
	end
	return stats
end

function MInventoryManager:FlushBagStatistics(bag)
	if bag then
		self.bagStatistics[bag] = nil
	end
end

function MInventoryManager:FlushCharacterStatistics(characterId)
	characterId = characterId or self:GetCurrentCharacter()
	if characterId then
		self.characterStatistics[characterId] = nil
	end
end

function MInventoryManager:FlushHouseStatistics(houseId)
	if houseId then
		self.houseStatistics[houseId] = nil
	end
end

function MInventoryManager:GetLastBagUpdate(bag)
	if tonumber(bag) then
		local lastUpdateKey = string.format("bag%s", tostring(bag))
		local lastUpdates = self:GetInventoryUpdateData()
		return lastUpdates[lastUpdateKey] or 0
	end
	return 0
end

function MInventoryManager:GetLastCharacterUpdate(characterId)
	if not characterId then
		characterId = self:GetCurrentCharacter()
	end
	if characterId then
		local lastUpdateKey = string.format("char%s", tostring(characterId))
		local lastUpdates = self:GetInventoryUpdateData()
		return lastUpdates[lastUpdateKey] or 0
	end
	return 0
end

function MInventoryManager:GetLastHouseUpdate(houseId)
	if not houseId then
		houseId = self:GetHouseId()
	end
	if tonumber(houseId) then
		local lastUpdateKey = string.format("house%s", tostring(houseId))
		local lastUpdates = self:GetInventoryUpdateData()
		return lastUpdates[lastUpdateKey] or 0
	end
	return 0
end

function MInventoryManager:RefreshLastBagUpdate(bag)
	if tonumber(bag) then
		local lastUpdateKey = string.format("bag%s", tostring(bag))
		local lastUpdates = self:GetInventoryUpdateData()
		lastUpdates[lastUpdateKey] = GetTimeStamp()
	end
end

function MInventoryManager:RefreshLastCharacterUpdate(characterId)
	if not characterId then
		characterId = self:GetCurrentCharacter()
	end
	if characterId then
		local lastUpdateKey = string.format("char%s", tostring(characterId))
		local lastUpdates = self:GetInventoryUpdateData()
		lastUpdates[lastUpdateKey] = GetTimeStamp()
	end
end

function MInventoryManager:RefreshLastHouseUpdate(houseId)
	if not houseId then
		houseId = self:GetHouseId()
	end
	if tonumber(houseId) then
		local lastUpdateKey = string.format("house%s", tostring(houseId))
		local lastUpdates = self:GetInventoryUpdateData()
		lastUpdates[lastUpdateKey] = GetTimeStamp()
	end
end

function MInventoryManager:UpdateBagInventories()
	EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptors["UPDATE_BAG"])
	for bag in pairs(self.queuedBagUpdates) do
		self:UpdateBagInventory(bag)
	end
	ZO_ClearTable(self.queuedBagUpdates)
end

function MInventoryManager:UpdateBagInventory(bag)
	local inventory = self:GetBagInventory(bag)
	if inventory then
		self:FlushBagStatistics(bag)
		ZO_ClearTable(inventory)
		local bag = self.InventoryBag
		local numSlots = GetBagSize(bag)
		for slot = 0, numSlots - 1 do
			local link = self:GetBagFurnitureInfo(bag, slot)
			if link then
				local itemId = self:GetItemLinkItemId(link)
				if itemId ~= 0 then
					inventory[itemId] = (inventory[itemId] or 0) + 1
				end
			end
		end
		self:RefreshLastBagUpdate(bag)
		return inventory
	end
end

function MInventoryManager:UpdateCharacterInventory()
	EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptors["UPDATE_CHARACTER"])
	local inventory = self:GetCharacterInventory()
	if inventory then
		self:FlushCharacterStatistics()
		ZO_ClearTable(inventory)
		local bag = self.InventoryBag
		local numSlots = GetBagSize(bag)
		for slot = 0, numSlots - 1 do
			local link = self:GetBagFurnitureInfo(bag, slot)
			if link then
				local itemId = self:GetItemLinkItemId(link)
				if itemId ~= 0 then
					inventory[itemId] = (inventory[itemId] or 0) + 1
				end
			end
		end
		self:RefreshLastCharacterUpdate()
		return inventory
	end
end

function MInventoryManager:UpdateHouseInventory()
	EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptors["UPDATE_HOUSE"])
	local houseId = self:GetHouseId()
	if houseId then
		self:FlushHouseStatistics(houseId)
		local inventory = self:GetHouseInventory(houseId)
		if inventory then
			ZO_ClearTable(inventory)
			local furnitureId = GetNextPlacedHousingFurnitureId()
			while furnitureId do
				local link = self:GetPlacedFurnitureInfo(furnitureId)
				if link then
					local itemId = self:GetItemLinkItemId(link)
					if itemId ~= 0 then
						inventory[itemId] = (inventory[itemId] or 0) + 1
					end
				end
				furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
			end
			self:RefreshLastHouseUpdate()
			return inventory
		end
	end
end

function MInventoryManager:QueueDeferredBagInventoryUpdate(bag)
	--self.queuedBagUpdates[bag] = true
	--EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptors["UPDATE_BAG"])
	--EVENT_MANAGER:RegisterForUpdate(self.EventDescriptors["UPDATE_BAG"], 200, function() self:UpdateBagInventories() end)
end

function MInventoryManager:QueueDeferredCharacterInventoryUpdate()
	--EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptors["UPDATE_CHARACTER"])
	--EVENT_MANAGER:RegisterForUpdate(self.EventDescriptors["UPDATE_CHARACTER"], 200, function() self:UpdateCharacterInventory() end)
end

function MInventoryManager:QueueDeferredHouseInventoryUpdate()
	EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptors["UPDATE_HOUSE"])
	EVENT_MANAGER:RegisterForUpdate(self.EventDescriptors["UPDATE_HOUSE"], 200, function() self:UpdateHouseInventory() end)
end

function MInventoryManager:CalculateInventoryTransferStatistics(sourceInventory, destinationInventory, operator)
	local coeff
	if operator == "+" then
		coeff = 1
	elseif operator == "-" then
		coeff = -1
	end
	if not coeff then
		assert("CalculateInventoryTransferStatistics: Invalid argument for parameter 'operator'.")
		return
	end
	if sourceInventory and destinationInventory then
		local stats = {}
		self:CalculateInventoryStatistics(destinationInventory, stats)
		for itemId, count in pairs(sourceInventory) do
			local link, categoryId, subcategoryId, themeId, limitId = self:GetFurnitureItemIdInfo(itemId)
			if link and link ~= "" and categoryId and categoryId ~= 0 then
				local category = stats.categories[categoryId]
				if not category then
					category = {count = 0, subcategories = {},}
					stats.categories[categoryId] = category
				end
				category.count = category.count + coeff
				category.subcategories[subcategoryId] = (category.subcategories[subcategoryId] or 0) + coeff
				stats.themes[themeId] = (stats.themes[themeId] or 0) + coeff
				if stats.limits[limitId] then
					stats.limits[limitId] = stats.limits[limitId] + coeff
				end
			end
		end
		return stats
	end
end

function MInventoryManager:QueryInventoryItems(inventory, query)
	local results = {}
	if "table" == type(inventory) and "table" == type(query) then
		do
			local copy = {}
			ZO_DeepTableCopy(query, copy)
			query = copy
		end
		for _, item in ipairs(inventory) do
			local link, categoryId, subcategoryId, themeId, limitId = self:GetFurnitureItemIdInfo(item.itemId)
			if link and link ~= "" and categoryId and categoryId ~= 0 then
				local include = true
				local matchedCategory = false
				if include and query.categories then
					local remaining = query.categories[subcategoryId]
					if not remaining or remaining <= 0 then
						include = false
					else
						matchedCategory = true
					end
				end
				local matchedTheme = false
				if include and query.themes then
					local remaining = query.themes[themeId]
					if not remaining or remaining <= 0 then
						include = false
					else
						matchedTheme = true
					end
				end
				local matchedLimit = false
				if include and query.limits then
					local remaining = query.limits[limitId]
					if not remaining or remaining <= 0 then
						include = false
					else
						matchedLimit = true
					end
				end
				if include then
					if matchedCategory then
						query.categories[subcategoryId] = query.categories[subcategoryId] - 1
					end
					if matchedTheme then
						query.themes[themeId] = query.themes[themeId] - 1
					end
					if matchedLimit then
						query.limits[limitId] = query.limits[limitId] - 1
					end
					table.insert(results, item)
				end
			end
		end
		if query.copy then
			local copy = {}
			ZO_DeepTableCopy(results, copy)
			results = copy
		end
	end
	return results
end

function MInventoryManager:OnPlayerActivated(...)
	self:QueueDeferredHouseInventoryUpdate()
end

function MInventoryManager:OnFurniturePlaced(...)
	self:QueueDeferredHouseInventoryUpdate()
end

function MInventoryManager:OnFurnitureRetrieved(...)
	self:QueueDeferredHouseInventoryUpdate()
end

function MInventoryManager:OnInventorySingleSlotUpdated(event, bag)
	if bag == BAG_BACKPACK then
		self:QueueDeferredCharacterInventoryUpdate()
	else
		self:QueueDeferredBagInventoryUpdate(bag)
	end
end

function MInventoryManager:AppendFurnitureTooltipInfo(control, itemLink)
	local link, categoryId, subcategoryId, themeId, limitId = self:GetFurnitureLinkInfo(itemLink)
	if link and link ~= "" and categoryId and categoryId ~= 0 and subcategoryId and subcategoryId ~= 0 and themeId and themeId ~= 0 then
		local categoryName = GetFurnitureCategoryName(categoryId) or ""
		local subcategoryName = GetFurnitureCategoryName(subcategoryId) or ""
		local themeName = self:GetDataManager():GetSortManager().FurnitureThemes[themeId] or ""
		local addDivider = true
		if subcategoryName ~= "" then
			local info = string.format("|cddddbb%s|r\n|cffffff%s |caaaaaa/|cffffff %s|r", "Category / Subcategory", categoryName, subcategoryName)
			if addDivider then
				ZO_Tooltip_AddDivider(control)
				addDivider = false
			end
			control:AddLine(info, "$(MEDIUM_FONT)|$(KB_16)", nil, nil, nil, nil, nil, TEXT_ALIGN_CENTER)
		end
		if themeName ~= "" then
			local info = string.format("|cddddbb%s|r\n|cffffff%s|r", "Style", themeName)
			if addDivider then
				ZO_Tooltip_AddDivider(control)
				addDivider = false
			end
			control:AddLine(info, "$(MEDIUM_FONT)|$(KB_16)", nil, nil, nil, nil, nil, TEXT_ALIGN_CENTER)
		end
	end
end

do
	local function AddTooltipHandler(control, method, linkFunction)
		local original = control[method]
		control[method] = function(control, ...)
			if original then
				original(control, ...)
			end
			local itemLink = linkFunction(...)
			if itemLink then
				MAGIC_SORTER:GetInventoryManager():AppendFurnitureTooltipInfo(control, itemLink)
			end
		end
	end

	function MInventoryManager:InitializeTooltipHandlers()
		AddTooltipHandler(PopupTooltip, "SetLink", function(itemLink) return itemLink end)
		AddTooltipHandler(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
		AddTooltipHandler(ItemTooltip, "SetBagItem", GetItemLink)
		AddTooltipHandler(ItemTooltip, "SetLootItem", GetLootItemLink)
		AddTooltipHandler(ItemTooltip, "SetStoreItem", GetStoreItemLink)
		AddTooltipHandler(ItemTooltip, "SetTradeItem", GetTradeItemLink)
		AddTooltipHandler(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
		AddTooltipHandler(ItemTooltip, "SetPlacedFurniture", function(furnitureId) return GetPlacedFurnitureLink(furnitureId) end)
	end
end
