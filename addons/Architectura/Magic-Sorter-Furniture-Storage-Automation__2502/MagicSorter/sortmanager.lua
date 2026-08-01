local MSortManager = ZO_Object:Subclass()

local function Rotate2D(x, y, angle)
	local cosine, sine = math.cos(angle), math.sin(angle)
	return y * sine + x * cosine, y * cosine - x * sine
end

function InstantiateMagicSortManager(dataManager)
	return MSortManager:New(dataManager)
end

function MSortManager:SetDebugEnabled(enabled)
	self.debugEnabled = enabled
end

function MSortManager:ToggleDebug()
	local enabled = not self.debugEnabled
	self:SetDebugEnabled(enabled)
	df("Sort Manager: Debug is %s.", enabled and "enabled" or "disabled")
end

function MSortManager:TableToString(t, output, depth)
	if not output then
		output = {}
		depth = 1
	end
	local tType = type(t)
	if tType == "nil" then
		table.insert(output, "nil")
	elseif tType == "string" then
		if #t > 20 then
			t = string.sub(t, 1, 20) .. "..."
		end
		table.insert(output, string.format("\"%s\"", t))
	elseif tType == "function" then
		table.insert(output, "[function]")
	elseif tType ~= "table" then
		table.insert(output, tostring(t))
	else
		if depth <= 3 then
			table.insert(output, "{")
			for key, value in pairs(t) do
				self:TableToString(key, output, depth + 1)
				table.insert(output, ":")
				self:TableToString(value, output, depth + 1)
				table.insert(output, ", ")
			end
			table.insert(output, "}")
		else
			table.insert(output, "[nested table]")
		end
	end
	if depth == 1 then
		return table.concat(output)
	end
end

function MSortManager:WriteDebug(message, ...)
	if message and self.debugEnabled then
		local params = {...}
		for paramIndex, param in ipairs(params) do
			local t = type(param)
			if t == "nil" then
				params[paramIndex] = "nil"
			elseif t ~= "table" then
				params[paramIndex] = tostring(param)
			else
				params[paramIndex] = self:TableToString(param)
			end
		end
		message = "|c00ffffD]|cffffff " .. message
		if #params == 0 then
			d(message)
		else
			df(message, unpack(params))
		end
	end
end

function MSortManager:WriteDebugArguments(message, ...)
	if message and self.debugEnabled then
		local numArgs = select("#", ...)
		if numArgs == 0 then
			self:WriteDebug(message)
		else
			local paramFormat = numArgs == 1 and "|cffff77%s|cffffff" or (string.rep("|cffff77%s|cffffff, ", numArgs - 1) .. "|cffff77%s|cffffff")
			self:WriteDebug(string.format("%s(%s)", message, paramFormat), ...)
		end
	end
end

function MSortManager:WriteDebugCall(procedureName, ...)
	if procedureName and self.debugEnabled then
		self:WriteDebugArguments(string.format("Call |cffff00%s|cffffff", procedureName), ...)
	end
end

function MSortManager:WriteDebugReturn(procedureName, ...)
	if procedureName and self.debugEnabled then
		self:WriteDebugArguments(string.format("Return |cffff00%s|cffffff: ", procedureName), ...)
	end
end

function MSortManager:New(...)
	local object = ZO_Object.New(self)
	object:Initialize(...)
	return object
end

function MSortManager:Initialize(dataManager)
	self.actionLog = {}
	self.debugEnabled = false
	self.dataManager = dataManager
	self:ClearState()
	self:InitializeStaticData()
	self:SetIsRunning(false)
	SLASH_COMMANDS["/debugmagicsorter"] = function() self:ToggleDebug() end
end

function MSortManager:InitializeStaticData()
	local dataManager = self:GetDataManager()
	self.JumpTimeoutMS = 20000
	self.InventoryBag = BAG_BACKPACK
	self.MaxActionLogLines = 1001
	self.MinimumInventorySlots = 1
	self.RetryJumpTimeoutMS = 30000
	self.SwapIntervalMS = 800

	self.EventDescriptors = {
		["JUMP"] = dataManager.EventDescriptor .. "JumpToHouse",
		["SWAP"] = dataManager.EventDescriptor .. "Swap",
		["ORGANIZE"] = dataManager.EventDescriptor .. "OrganizeFurniture",
	}

	self.EventTypes = {
		["EXCEPTION"] = {
			["NO_HOMES"] = "No storage homes are configured",
			["INVENTORY_FULL"] = "Please clear at least %d inventory slot(s).",
			["SWAP_REMOVE"] = "Failed to remove furnishing.",
			["SWAP_PLACE"] = "Failed to place furnishing.",
		},
		["STATE"] = {
			["RESUME"] = "Sorting storage homes' furniture...",
			["SUSPEND"] = "Sorting is suspended",
			["COMPLETE"] = "Storage homes have been sorted",
		},
		["JUMP"] = {
			["JUMP"] = "Preparing to jump to %s...",
			["RETRY"] = "Retrying to jump to %s...",
		},
		["SWAP"] = {
			["SWAP"] = "Swapping furniture items...",
			["PLACE"] = "Placed %s",
			["REMOVE"] = "Removed %s",
		},
		["ORGANIZE"] = {
			["ORGANIZE"] = "Organizing furniture storage...",
			["ORGANIZE_PERCENT"] = "Organizing furniture storage (%d%%)...",
		},
	}

	self.LimitTypes = {
		[HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM] = "Traditional",
		[HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM] = "Special",
	}

	self.FurnitureThemes = {
		[FURNITURE_THEME_TYPE_ALL] = "ALL",
		[FURNITURE_THEME_TYPE_ARGONIAN] = "Argonian",
		[FURNITURE_THEME_TYPE_AYLEID] = "Ayleid",
		[FURNITURE_THEME_TYPE_BRETON] = "Breton",
		[FURNITURE_THEME_TYPE_CLOCKWORK] = "Clockwork",
		[FURNITURE_THEME_TYPE_DAEDRIC] = "Daedric",
		[FURNITURE_THEME_TYPE_DARK_ELF] = "Dark Elf",
		[FURNITURE_THEME_TYPE_DWARVEN] = "Dwarven",
		[FURNITURE_THEME_TYPE_GENERIC] = "Other",
		[FURNITURE_THEME_TYPE_HIGH_ELF] = "High Elf",
		[FURNITURE_THEME_TYPE_IMPERIAL] = "Imperial",
		[FURNITURE_THEME_TYPE_KHAJIIT] = "Khajit",
		[FURNITURE_THEME_TYPE_NORD] = "Nord",
		[FURNITURE_THEME_TYPE_ORC] = "Orc",
		[FURNITURE_THEME_TYPE_PRIMAL] = "Primal",
		[FURNITURE_THEME_TYPE_REDGUARD] = "Redguard",
		[FURNITURE_THEME_TYPE_WOOD_ELF] = "Wood Elf",
		[FURNITURE_THEME_TYPE_VAMPIRIC] = "Vampiric",
	}
	self.FurnitureThemeList = {}
	for themeId, themeName in pairs(self.FurnitureThemes) do
		local sortWeight = 50
		if FURNITURE_THEME_TYPE_ALL == themeId then
			sortWeight = 1
		elseif FURNITURE_THEME_TYPE_GENERIC == themeId then
			sortWeight = 100
		end
		table.insert(self.FurnitureThemeList, {id = themeId, name = themeName, sortWeight = sortWeight})
	end
	table.sort(self.FurnitureThemeList, function(a, b) return a.sortWeight < b.sortWeight or (a.sortWeight == b.sortWeight and a.name < b.name) end)
end

function MSortManager:GetDataManager()
	return self.dataManager
end

function MSortManager:IsRunning()
	return self.isRunning
end

function MSortManager:SetIsRunning(isRunning)
	CancelCast()
	self:UnregisterAllUpdates()
	self:ClearActivityState()
	self.isRunning = isRunning
end

function MSortManager:UnregisterAllUpdates()
	for _, descriptor in pairs(self.EventDescriptors) do
		EVENT_MANAGER:UnregisterForUpdate(descriptor)
	end
end

function MSortManager:ClearActivityState()
	self.jumpHouse = nil
	self.swapHouse = nil
end

function MSortManager:ClearState()
	self.houseRemovables = {}
	self:ClearActivityState()
end

function MSortManager:LogAction(action)
	if not self.actionLog then
		self.actionLog = {}
	end
	table.insert(self.actionLog, 1, action)
	local iterations = 0
	while #self.actionLog > self.MaxActionLogLines and iterations < 100 do
		table.remove(self.actionLog, self.MaxActionLogLines + 1)
		iterations = iterations + 1
	end
	MagicSorter_StorageProgressDetail:RefreshActionLog()
end

function MSortManager:GetActionLog()
	if not self.actionLog then
		self.actionLog = {}
	end
	return self.actionLog
end

function MSortManager:DumpActionLog()
	d("Magic Sorter Action Log")
	d("_______________________")
	d(table.concat(self:GetActionLog(), "\n"))
end

function MSortManager:GetPlacementLocation()
	local x, y, z, heading = GetPlayerWorldPositionInHouse()
	x, y, z = math.ceil(x / 10) * 10, math.ceil(y / 2) * 2, math.ceil(z / 10) * 10
	heading = math.rad(math.ceil(math.deg(heading) / 2) * 2)
	return self.placementX or x, self.placementY or y, self.placementZ or z, self.placementHeading or heading
end

function MSortManager:RefreshPlacementLocation()
	SCENE_MANAGER:Show("hud")
	HousingEditorJumpToSafeLocation()
	zo_callLater(function()
		self.placementX, self.placementY, self.placementZ, self.placementHeading = nil, nil, nil, nil
		self.placementX, self.placementY, self.placementZ, self.placementHeading = self:GetPlacementLocation()
	end, 350)
end

function MSortManager:GetEventTypeString(eventType, event, ...)
	local types = self.EventTypes[eventType]
	if types then
		return string.format(types[event] or "", ...)
	else
		return ""
	end
end

function MSortManager:GetHouseId()
	if IsOwnerOfCurrentHouse() then
		return GetCurrentZoneHouseId()
	end
	return 0
end

function MSortManager:OnStateChanged(eventType, event, ...)
	self:WriteDebugCall("OnStateChanged", eventType, event, ...)
	local suppressLogAction = false
	if eventType == "EXCEPTION" then
		if event == "NO_HOMES" then
			zo_callLater(function()
				self:SetAllDialogsHidden(true)
				self:StartStorageWizard()
			end, 3000)
		end
	elseif eventType == "STATE" then
		if event == "RESUME" then
			self:SetIsRunning(true)
		elseif event == "SUSPEND" then
			self:SetIsRunning(false)
		elseif event == "COMPLETE" then
			self:SetIsRunning(false)
			suppressLogAction = true
		end
	elseif eventType == "JUMP" then
		self.swapHouse = nil
	elseif eventType == "SWAP" then
		self.swapHouse = self:GetCurrentHouse()
		self.jumpHouse = nil
	elseif eventType == "ORGANIZE" then
		if event == "ORGANIZE_PERCENT" then
			suppressLogAction = true
		end
	end
	local eventMessage = self:GetEventTypeString(eventType, event, ...)
	if not suppressLogAction then
		self:LogAction(string.gsub(eventMessage, "\n", "  "))
	end
	self.lastEvent = { eventType = eventType, event = event, eventMessage = eventMessage }
	self:GetDataManager():OnSortManagerStateChanged(eventType, event, eventMessage)
end

function MSortManager:OnPlayerActivated()
	self:WriteDebugCall("OnPlayerActivated")
	EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptors["JUMP"])
	if self:CheckState() then
		if IsActiveWorldBattleground() then
			self:Suspend()
			self:LogAction("Battleground entered; suspending sort operation.")
		elseif GetCurrentCampaignId() ~= 0 then
			self:Suspend()
			self:LogAction("Alliance War Campaign entered; suspending sort operation.")
		elseif self.jumpHouse then
			CancelCast()
			if self:GetHouseId() == self.jumpHouse.houseId then
				self:WriteDebug("Jump complete.")
				self.jumpHouse = nil
				zo_callLater(function() self:OrganizeHouse() end, 1200)
			else
				self:WriteDebug("Incorrect jump destination.")
				self:JumpToHouse(self.jumpHouse)
			end
		elseif self:GetHouseId() == 0 then
			self:Suspend()
			self:LogAction("Zone jump was unplanned; suspending sort operation.")
		end
	end
end

function MSortManager:OnFurnitureChanged(...)
	if not self:CheckState() then
		self:ClearState()
	end
end

function MSortManager:Start(resume)
	if not self:IsRunning() then
		local precalc = false

		if resume then
			self:ClearActivityState()
		else
			self:ClearState()
			self.actionLog = {}
			if self:GetDataManager():IsQuickSortMode() then
				precalc = true
			end
		end

		if self:ValidateInventorySpace(self.MinimumInventorySlots) then
			if self:GetAndValidateConfiguration() then
				self:OnStateChanged("STATE", "RESUME")
				if precalc then
					self:PreCalculateHouseRemovables()
				else
					self:OrganizeHouse()
				end
			else
				self:OnStateChanged("EXCEPTION", "NO_HOMES")
			end
		end
	end
end

function MSortManager:Resume()
	self:Start(true)
end

function MSortManager:Suspend()
	if self:IsRunning() then
		self:OnStateChanged("STATE", "SUSPEND")
	end
end

function MSortManager:Cancel()
	self:Suspend()
end

function MSortManager:GetLastReport()
	return self:GetDataManager():GetData().lastReport or {}
end

function MSortManager:Complete()
	local report = {}
	local placeableCount = 0
	local bagId = self.InventoryBag
	local bagSize = GetBagSize(bagId)
	local categoryCapacityDeficits = {}

	for slotIndex = 0, bagSize - 1 do
		if self:IsBagFurniturePlaceableInAnyHouse(bagId, slotIndex) then
			local stackSize = GetSlotStackSize(bagId, slotIndex)
			placeableCount = placeableCount + stackSize
			local categoryId, subcategoryId, themeId, limitId = self:GetFurnitureCategoryByBagAndSlot(bagId, slotIndex)
			if subcategoryId then
				local themeFiltered = false
				local eligibleHouses = self:GetHousesByFurnitureCategoryAndTheme(subcategoryId)
				if eligibleHouses then
					for _, houseId in ipairs(eligibleHouses) do
						if self:DoesHouseHaveCapacity(houseId, limitId, 1) then
							themeFiltered = true
							break
						end
					end
				end
				local categoryKey
				if themeFiltered then
					categoryKey = string.format("%d_%d_%d", categoryId, subcategoryId, themeId)
				else
					categoryKey = string.format("%d_%d", categoryId, subcategoryId)
				end
				if not categoryCapacityDeficits[categoryKey] then
					categoryCapacityDeficits[categoryKey] = {categoryId = categoryId, subcategoryId = subcategoryId, themeId = themeFiltered and themeId or nil, slotDeficit = 0}
				end
				categoryCapacityDeficits[categoryKey].slotDeficit = categoryCapacityDeficits[categoryKey].slotDeficit + stackSize
			end
		end
	end

	for _, house in ipairs(self.houseList) do
		local removables = self:GetHouseRemovables(house.houseId)
		local removableCount = 0
		if removables then
			removableCount = #removables
		end
		if removableCount > 0 then
			local themeFiltered = "table" == type(house.assignedThemeIds) and NonContiguousCount(house.assignedThemeIds) ~= 0
			for _, item in pairs(removables) do
				local categoryId, subcategoryId, themeId = item.categoryId, item.subcategoryId, item.themeId
				if subcategoryId then
					local categoryKey
					if themeFiltered then
						categoryKey = string.format("%d_%d_%d", categoryId, subcategoryId, themeId)
					else
						categoryKey = string.format("%d_%d", categoryId, subcategoryId)
					end
					local stackSize = 1
					if not categoryCapacityDeficits[categoryKey] then
						categoryCapacityDeficits[categoryKey] = {categoryId = categoryId, subcategoryId = subcategoryId, themeId = themeFiltered and themeId or nil, slotDeficit = 0}
					end
					categoryCapacityDeficits[categoryKey].slotDeficit = categoryCapacityDeficits[categoryKey].slotDeficit + stackSize
				end
			end
		end
	end

	table.insert(report, "MAGIC SORTER REPORT")
	if NonContiguousCount(categoryCapacityDeficits) == 0 then
		table.insert(report, "Storage home capacity was sufficient for all furnishings.")
	else
		table.insert(report, "|cffffaaInsufficient storage capacity|cffffff for these categories / styles:")

		local deficitReport = {}
		for categoryKey, categoryDeficit in pairs(categoryCapacityDeficits) do
			categoryDeficit.categoryName = self:GetFurnitureCategoryName(categoryDeficit.categoryId, categoryDeficit.subcategoryId) or ""
			if categoryDeficit.themeId then
				local themeName = self.FurnitureThemes[categoryDeficit.themeId]
				if themeName then
					categoryDeficit.categoryName = string.format("%s (%s)", categoryDeficit.categoryName, themeName)
				end
			end
			local parentName = self:GetFurnitureCategoryName(categoryDeficit.categoryId)
			if parentName and parentName ~= "" then
				categoryDeficit.parentCategoryName = parentName
			end
			table.insert(deficitReport, categoryDeficit)
		end
		table.sort(deficitReport, function(categoryA, categoryB) return categoryA.categoryName < categoryB.categoryName end)

		local previousParentCategoryName, previousParentCategoryCount = "", 0
		local parentCategoryFormat = "  |cffff33%d item%s|c33ffff, %s"

		for _, deficit in ipairs(deficitReport) do
			if previousParentCategoryName ~= deficit.parentCategoryName then
				if previousParentCategoryName ~= "" then
					table.insert(report, string.format(parentCategoryFormat, previousParentCategoryCount, previousParentCategoryCount == 1 and "" or "s", previousParentCategoryName))
				end
				previousParentCategoryName = deficit.parentCategoryName
				previousParentCategoryCount = 0
			end
			local slotDeficit = deficit.slotDeficit or 0
			previousParentCategoryCount = previousParentCategoryCount + slotDeficit
			table.insert(report, string.format("|cffffaa%d item%s|cffffff, %s", slotDeficit, slotDeficit == 1 and "" or "s", deficit.categoryName))
		end

		if previousParentCategoryCount ~= 0 then
			table.insert(report, string.format(parentCategoryFormat, previousParentCategoryCount, previousParentCategoryCount == 1 and "" or "s", previousParentCategoryName))
		end
	end

	self:GetDataManager():OnSortCompleted(report)
	self:OnStateChanged("STATE", "COMPLETE")
end

function MSortManager:CheckState()
	return self:IsRunning()
end

function MSortManager:GetAndValidateConfiguration()
	local data = self:GetDataManager()
	local houses = {}
	ZO_DeepTableCopy(data:GetStorageHouses(), houses)
	self.houses = houses
	if not houses or NonContiguousCount(houses) == 0 then
		return false
	end

	local houseList = {}
	self.houseList = houseList
	for houseId, house in pairs(self.houses) do
		table.insert(houseList, house)
	end

	local categories = {}
	self.categories = categories
	for houseId, house in pairs(self.houses) do
		for categoryId in pairs(house.assignedCategoryIds) do
			local category = categories[categoryId]
			if not category then
				category = {}
				categories[categoryId] = category
			end
			category[houseId] = true
		end
	end

	return true
end

function MSortManager:OnInventorySpaceCheck()
	local unregister = false
	if self:IsRunning() or self:GetDataManager():IsDialogHidden("StorageProgress") then
		unregister = true
	else
		local minimumSlots = self.minimumSlots or 1
		local numFreeSlots = GetNumBagFreeSlots(self.InventoryBag)
		if numFreeSlots >= minimumSlots then
			self:Resume()
			unregister = true
		end
	end
	if unregister then
		EVENT_MANAGER:UnregisterForUpdate(self:GetDataManager().EventDescriptor .. "InventorySpace")
	end
end

function MSortManager:RegisterInventorySpaceCheck(minimumSlots)
	self.minimumSlots = minimumSlots or 1
	local myself = self
	EVENT_MANAGER:RegisterForUpdate(self:GetDataManager().EventDescriptor .. "InventorySpace", 2000, function()
		myself:OnInventorySpaceCheck()
	end)
end

function MSortManager:ValidateInventorySpace(minimumSlots)
	minimumSlots = minimumSlots or 1
	local numFreeSlots = GetNumBagFreeSlots(self.InventoryBag)
	if numFreeSlots < minimumSlots then
		self:Suspend()
		self:OnStateChanged("EXCEPTION", "INVENTORY_FULL", minimumSlots)
		self:RegisterInventorySpaceCheck(minimumSlots)
		return false
	end
	return true
end

function MSortManager:GetCurrentHouse()
	local houseId = self:GetHouseId()
	local house = self.houses[houseId]
	return house
end

function MSortManager:GetFurnitureCategoryName(categoryId, subcategoryId)
	local categoryName = GetFurnitureCategoryName(categoryId) or ""
	local subcategoryName = GetFurnitureCategoryName(subcategoryId) or ""
	if subcategoryName ~= "" then
		return string.format("%s, %s", categoryName, subcategoryName)
	else
		return categoryName
	end
end

function MSortManager:GetFurnitureCategoryByFurnitureId(furnitureId)
	local _, collectibleLink = GetPlacedFurnitureLink(furnitureId)
	if not collectibleLink or collectibleLink == "" then
		local _, _, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
		local categoryId, subcategoryId, themeId, limitId = GetFurnitureDataInfo(furnitureDataId)
		if categoryId and categoryId ~= 0 and subcategoryId ~= 0 then
			return categoryId, subcategoryId, themeId or 0, limitId
		end
	end
	return nil
end

function MSortManager:GetFurnitureCategoryByBagAndSlot(bagId, slotIndex)
	local furnitureDataId = GetItemFurnitureDataId(bagId, slotIndex)
	local categoryId, subcategoryId, themeId, limitId = GetFurnitureDataInfo(furnitureDataId)
	if categoryId and categoryId ~= 0 and subcategoryId ~= 0 then
		return categoryId, subcategoryId, themeId or 0, limitId
	end
	return nil
end

function MSortManager:GetHousesByFurnitureCategoryAndTheme(subcategoryId, themeId)
	local houses = {}
	local subcategory = self.categories[subcategoryId]
	if subcategory then
		for houseId in pairs(subcategory) do
			local house = self.houses[houseId]
			if house then
				if not house.assignedThemeIds or NonContiguousCount(house.assignedThemeIds) == 0 or house.assignedThemeIds[themeId] then
					table.insert(houses, houseId)
				end
			end
		end
	end
	return houses
end

function MSortManager:IsStoredFurniture(houseId, categoryId, subcategoryId, themeId)
	local house = self.houses[houseId]
	if house then
		local subcategory = self.categories[subcategoryId]
		if subcategory then
			if subcategory[houseId] then
				if not house.assignedThemeIds or NonContiguousCount(house.assignedThemeIds) == 0 or house.assignedThemeIds[themeId] then
					return true
				end
			end
		end
	end
	return false
end

function MSortManager:GetStoredFurniture()
	local houseId = self:GetHouseId()
	local items = {}
	if houseId ~= 0 then
		local furnitureId = GetNextPlacedHousingFurnitureId()
		while furnitureId do
			local categoryId, subcategoryId, themeId = self:GetFurnitureCategoryByFurnitureId(furnitureId)
			if self:IsStoredFurniture(houseId, categoryId, subcategoryId, themeId) then
				local itemName = GetPlacedHousingFurnitureInfo(furnitureId) or ""
				table.insert(items, {furnitureId = furnitureId, name = itemName})
			end
			furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
		end
	end
	table.sort(items, function(itemA, itemB) return itemA.name < itemB.name end)
	return items
end

function MSortManager:IsFurnitureRemovableFromHouse(houseId, furnitureId, categoryId, subcategoryId, themeId)
	local subcategory = self.categories[subcategoryId]
	if subcategory then
		if not subcategory[houseId] then
			return true
		end
	end
	local house = self.houses[houseId]
	if house then
		if house.assignedThemeIds and NonContiguousCount(house.assignedThemeIds) ~= 0 and not house.assignedThemeIds[themeId] then
			return true
		end
	end
	return false
end

function MSortManager:IsFurniturePlaceable(bagId, slotIndex)
	return IsItemPlaceableFurniture(bagId, slotIndex) and not IsItemStolen(bagId, slotIndex)
end

function MSortManager:IsFurniturePlaceableInAnyHouse(exceptHouseId, categoryId, subcategoryId, themeId)
	for houseId, house in pairs(self.houses) do
		if exceptHouseId ~= houseId and self:IsFurniturePlaceableInHouse(houseId, categoryId, subcategoryId, themeId) then
			return true
		end
	end
	return false
end

function MSortManager:IsBagFurniturePlaceableInAnyHouse(bagId, slotIndex)
	if self:IsFurniturePlaceable(bagId, slotIndex) then
		local categoryId, subcategoryId, themeId = self:GetFurnitureCategoryByBagAndSlot(bagId, slotIndex)
		for houseId, house in pairs(self.houses) do
			if self:IsFurniturePlaceableInHouse(houseId, categoryId, subcategoryId, themeId) then
				return true
			end
		end
	end
	return false
end

function MSortManager:IsFurniturePlaceableInHouse(houseId, categoryId, subcategoryId, themeId)
	local subcategory = self.categories[subcategoryId]
	if subcategory then
		if subcategory[houseId] then
			local house = self.houses[houseId]
			if house then
				if not house.assignedThemeIds or NonContiguousCount(house.assignedThemeIds) == 0 or house.assignedThemeIds[themeId] then
					return true
				end
			end
		end
	end
	return false
end

function MSortManager:HasVisitedHouse(houseId)
	return nil ~= self.houseRemovables[houseId]
end

function MSortManager:GetHouseCapacity(houseId, limitType)
	local stats = self:GetDataManager():GetInventoryManager():GetHouseStatistics(houseId)
	if stats then
		local maxLimit = stats.maxLimits[limitType]
		local usedLimit = stats.limits[limitType]
		if maxLimit and usedLimit then
			return maxLimit - usedLimit
		end
	end
end

function MSortManager:GetHouseLimit(houseId, limitType)
	local stats = self:GetDataManager():GetInventoryManager():GetHouseStatistics(houseId)
	if stats then
		return stats.maxLimits[limitType]
	end
end

function MSortManager:DoesHouseHaveCapacity(houseId, limitType, additional)
	additional = additional or 1
	local capacity = self:GetHouseCapacity(houseId, limitType)
	if capacity then
		local existingItemCount = self:GetPlaceableFurnitureCountForHouse(houseId, limitType) or 0
		local slotsRemaining = capacity - existingItemCount - additional
		return slotsRemaining >= 0
	end
	return nil
end

function MSortManager:GetHouseRemovables(houseId)
	return self.houseRemovables[houseId]
end

do
	local function RemovableComparer(a, b)
		return a.stackSize > b.stackSize
	end

	function MSortManager:SetHouseRemovables(houseId, list)
		-- Optimize removables with a descending stack size sort where stack size is grouped by item id and bound state.
		if list then
			local stackSizes = {}
			for _, item in ipairs(list) do
				local stackDescriptor = item.itemId * (item.bound and 1 or -1)
				local stackSize = stackSizes[stackDescriptor]
				stackSizes[stackDescriptor] = (stackSize or 0) + 1
				item.stackDescriptor = stackDescriptor
			end
			for _, item in ipairs(list) do
				item.stackSize = stackSizes[item.stackDescriptor] or 1
			end
			table.sort(list, RemovableComparer)
		end
		self.houseRemovables[houseId] = list
	end
end

function MSortManager:GetRemovableFurnitureList()
	local list = {}
	local houseId = self:GetHouseId()
	local furnitureId = GetNextPlacedHousingFurnitureId()
	while furnitureId and furnitureId ~= 0 do
		local categoryId, subcategoryId, themeId, limitId = self:GetFurnitureCategoryByFurnitureId(furnitureId)
		if categoryId then
			if not self:IsFurniturePlaceableInHouse(houseId, categoryId, subcategoryId, themeId) and self:IsFurniturePlaceableInAnyHouse(houseId, categoryId, subcategoryId, themeId) then
				local itemLink = GetPlacedFurnitureLink(furnitureId)
				local itemId = GetItemLinkItemId(itemLink) or 0
				local bound = IsItemLinkBound(itemLink)
				table.insert(list, {furnitureId = furnitureId, categoryId = categoryId, subcategoryId = subcategoryId, themeId = themeId, itemId = itemId, bound = bound, limitType = limitId})
			end
		end
		furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
	end
	self:SetHouseRemovables(houseId, list)
	return list
end

function MSortManager:PreCalculateHouseRemovables(currentHouseIndex)
	if #self.houseList == 0 then
		self:OrganizeHouse()
		return
	end

	currentHouseIndex = currentHouseIndex or 1
	local inventoryManager = self:GetDataManager():GetInventoryManager()
	local house = self.houseList[currentHouseIndex]

	if house then
		local houseId = house.houseId
		local lastUpdate = inventoryManager:GetLastHouseUpdate(houseId)
		if lastUpdate ~= 0 then
			local list = {}
			local inventory = inventoryManager:GetHouseInventory(houseId)

			for itemId, count in pairs(inventory) do
				itemId = math.abs(itemId)
				local link, categoryId, subcategoryId, themeId, limitId = inventoryManager:GetFurnitureItemIdInfo(itemId)
				if categoryId and categoryId ~= 0 then
					if not self:IsFurniturePlaceableInHouse(houseId, categoryId, subcategoryId, themeId) and self:IsFurniturePlaceableInAnyHouse(houseId, categoryId, subcategoryId, themeId) then
						for itemIndex = 1, count do
							table.insert(list, {categoryId = categoryId, subcategoryId = subcategoryId, themeId = themeId, itemId = itemId, bound = bound, limitType = limitId})
						end
					end
				end
			end

			self:SetHouseRemovables(houseId, list)
		end

		zo_callLater(function() self:PreCalculateHouseRemovables(currentHouseIndex + 1) end, 10)
		return
	end

	self:OrganizeHouse()
end

function MSortManager:GetOutboundFurnitureList(houseId)
	local items
	local outbound = {}
	local targetBuckets = {}
	local currentHouseId = self:GetHouseId()
	houseId = houseId or currentHouseId
	if houseId == currentHouseId then
		items = self:GetRemovableFurnitureList()
	else
		items = self:GetHouseRemovables(houseId)
	end
	for _, item in pairs(items) do
		local furnitureId = item.furnitureId
		local subcategoryId = item.subcategoryId
		local themeId = item.themeId
		local limitType = item.limitType
		local stackSize = item.stackSize or 1
		local targetHouses = self:GetHousesByFurnitureCategoryAndTheme(subcategoryId, themeId)
		for _, targetHouseId in ipairs(targetHouses) do
			local targetHouse = self.houses[targetHouseId]
			if targetHouse and self:HasVisitedHouse(targetHouseId) then
				local bucket = targetBuckets[targetHouseId]
				if not bucket then
					bucket = {}
					targetBuckets[targetHouseId] = bucket
				end
				local used = (bucket[limitType] or 0)
				for targetCount = 1, stackSize do
					if self:DoesHouseHaveCapacity(targetHouseId, limitType, used + 1) then
						table.insert(outbound, item)
						used = used + 1
					else
						break
					end
				end
				bucket[limitType] = used
			end
		end
	end
	return outbound
end

function MSortManager:GetPlaceableFurnitureList()
	local houseId = self:GetHouseId()
	return self:GetPlaceableFurnitureListForHouse(houseId)
end

do
	local function PlaceableComparer(a, b)
		return a.stackSize < b.stackSize
	end

	function MSortManager:GetPlaceableFurnitureListForHouse(houseId, filterLimitType)
		local list = {}
		local bagId = self.InventoryBag
		local numSlots = GetBagSize(bagId)
		local capacityTraditional = self:GetHouseCapacity(houseId, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM) or 0
		local capacitySpecial = self:GetHouseCapacity(houseId, HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM) or 0
		for slotIndex = 0, numSlots do
			local categoryId, subcategoryId, themeId = self:GetFurnitureCategoryByBagAndSlot(bagId, slotIndex)
			if categoryId and subcategoryId then
				local furnitureDataId = GetItemFurnitureDataId(bagId, slotIndex)
				local _, _, _, limitType = GetFurnitureDataInfo(furnitureDataId)
				if self:IsFurniturePlaceable(bagId, slotIndex) and self:IsFurniturePlaceableInHouse(houseId, categoryId, subcategoryId, themeId) and (not filterLimitType or filterLimitType == limitType) then
					if limitType == HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM and capacityTraditional and capacityTraditional > 0 then
						local stackSize = GetSlotStackSize(bagId, slotIndex)
						capacityTraditional = capacityTraditional - stackSize
						table.insert(list, {categoryId = categoryId, subcategoryId = subcategoryId, themeId = themeId, bagId = bagId, slotIndex = slotIndex, stackSize = stackSize, limitType = limitType})
					elseif limitType == HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM and capacitySpecial and capacitySpecial > 0 then
						local stackSize = GetSlotStackSize(bagId, slotIndex)
						capacitySpecial = capacitySpecial - stackSize
						table.insert(list, {categoryId = categoryId, subcategoryId = subcategoryId, themeId = themeId, bagId = bagId, slotIndex = slotIndex, stackSize = stackSize, limitType = limitType})
					end
				end
			end
		end
		table.sort(list, PlaceableComparer)
		return list
	end
end

function MSortManager:GetPlaceableFurnitureCountForHouse(houseId, filterLimitType, includeUnknown)
	local count1, count2 = 0, 0
	local capacity1 = self:GetHouseCapacity(houseId, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM) or 0
	local capacity2 = self:GetHouseCapacity(houseId, HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM) or 0
	local placeables = self:GetPlaceableFurnitureListForHouse(houseId, filterLimitType)
	if placeables then
		for index, item in ipairs(placeables) do
			if item.limitType == HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM then
				count1 = count1 + (item.stackSize or 1)
			elseif item.limitType == HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM then
				count2 = count2 + (item.stackSize or 1)
			end
		end
		if not includeUnknown then
			count1 = math.min(count1, capacity1 or 0)
			count2 = math.min(count2, capacity2 or 0)
		end
	end
	return count1 + count2
end

function MSortManager:GetNextHouse()
	self:WriteDebug("Current House (%d)", self:GetHouseId() or 0)
	self:WriteDebugCall("GetNextHouse")
	local freeSlots = math.max(0, GetNumBagFreeSlots(self.InventoryBag) - 1)
	local currentHouse = self:GetCurrentHouse()
	local visitedPlaceables, visitedPlaceableHouse = 0, nil
	local visitedRemovables, visitedRemovableHouse = 0, nil
	local unvisitedPlaceables, unvisitedHouse = 0, nil
	local unvisited = 0
	local houses = {}
	self:GetRemovableFurnitureList()
	for _, house in ipairs(self.houseList) do
		if not self:HasVisitedHouse(house.houseId) then
			unvisited = unvisited + 1
			local placeableCount = self:GetPlaceableFurnitureCountForHouse(house.houseId, nil, true) or 0
			if not unvisitedHouse or placeableCount > unvisitedPlaceables then
				unvisitedHouse = house
				unvisitedPlaceables = placeableCount
			end
		else
			local placeableCount = self:GetPlaceableFurnitureCountForHouse(house.houseId)
			if placeableCount > visitedPlaceables then
				visitedPlaceableHouse = house
				visitedPlaceables = placeableCount
			end
			local removableCount = 0
			local removableList = self:GetOutboundFurnitureList(house.houseId)
			if removableList then
				removableCount = math.min(freeSlots, #removableList)
			end
			if removableCount > visitedRemovables then
				visitedRemovableHouse = house
				visitedRemovables = removableCount
			end
		end
	end
	local targetHouse
	if unvisitedHouse then
		if visitedPlaceables >= (0.65 * freeSlots) then
			targetHouse = visitedPlaceableHouse
		elseif visitedRemovables >= (0.65 * freeSlots) then
			targetHouse = visitedRemovableHouse
		end
		targetHouse = targetHouse or unvisitedHouse
	else
		if visitedPlaceables > 0 then
			targetHouse = visitedPlaceableHouse
		elseif visitedRemovables > 0 then
			targetHouse = visitedRemovableHouse
		end
	end
	return targetHouse
end

function MSortManager:OnOrganizeFurniture()
	if not self:CheckState() then
		return
	end
	local PI, PI2, EPSILON = math.pi, 2 * math.pi, math.rad(10)
	local items, index = self.organizeItems, self.organizeItemIndex
	while items and index and index <= #items do
		self:OnStateChanged("ORGANIZE", "ORGANIZE_PERCENT", math.floor(100 * (index / #items)))
		local item = items[index]
		if item then
			index = index + 1
			self.organizeItemIndex = index
			local x, y, z = HousingEditorGetFurnitureWorldPosition(item.furnitureId)
			local pitch, yaw, roll = HousingEditorGetFurnitureOrientation(item.furnitureId)
			local yawp = math.abs(yaw - item.yaw)
			if yawp > PI then yawp = PI2 - yawp end
			local yawc = yawp > EPSILON and (math.abs(PI2 - (yawp + PI)) % PI2) > EPSILON
			if math.abs(x - item.x) > 5 or math.abs(y - item.y) > 5 or math.abs(z - item.z) > 5 or yawc then
				HousingEditorRequestChangePositionAndOrientation(item.furnitureId, item.x, item.y, item.z, item.pitch, item.yaw, item.roll)
				return
			end
		else
			break
		end
	end
	EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptors["ORGANIZE"])
	self.organizeItems = nil
	self.organizeItemIndex = nil
	self:OrganizeHouse(true)
end

function MSortManager:OrganizeFurniture()
	local houseId = self:GetHouseId()
	local houseLimit = self:GetHouseLimit(houseId or 0, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM) or 0
	local largeHouse = houseLimit > 400
	local maxExtentZ = largeHouse and 3000 or 1000
	local maxExtentX = largeHouse and 400 or 200
	local initialExtentX = maxExtentX
	local placementOffset = largeHouse and -500 or -250
	local extentIncrement = largeHouse and 100 or 50
	local initialExtentIncrement = extentIncrement
	local elevationIncrement = largeHouse and 15 or 8
	local x, y, z, yaw = self:GetPlacementLocation()
	yaw = yaw or 0
	local xo, zo = Rotate2D(0, placementOffset, yaw)
	x, y, z = x + xo, y + 10, z + zo
	local items = self:GetStoredFurniture()
	if #items == 0 then
		local myself = self
		zo_callLater(function() myself:OrganizeHouse(true) end, 100)
		return
	end
	table.sort(items, function(itemA, itemB)
		return itemA.name < itemB.name
	end)
	local previousName, groupIndex = nil, 0
	for index, item in ipairs(items) do
		if item.name ~= previousName then
			groupIndex = groupIndex + 1
		end
		item.idString = Id64ToString(item.furnitureId)
		item.groupIndex = groupIndex
		local minX, minY, minZ, maxX, maxY, maxZ = HousingEditorGetFurnitureLocalBounds(item.furnitureId)
		minX, minY, minZ, maxX, maxY, maxZ = 100 * minX, 100 * minY, 100 * minZ, 100 * maxX, 100 * maxY, 100 * maxZ
		item.sizeX, item.sizeY, item.sizeZ = maxX - minX, maxY - minY, maxZ - minZ
		item.offsetX, item.offsetY, item.offsetZ = -0.5 * (maxX + minX), -0.5 * (maxY + minY), -0.5 * (maxZ + minZ)
		item.pitch, item.yaw, item.roll, item.yawOffset = 0, 0, 0, 0
		local ox, oy, oz = item.offsetX, item.offsetY, item.offsetZ
		local sx, sy, sz = item.sizeX, item.sizeY, item.sizeZ
		if item.sizeX <= item.sizeZ then
			item.offsetX, item.offsetZ = Rotate2D(ox, oz, 0.5 * math.pi)
			item.sizeX, item.sizeZ = sz, sx
			item.yawOffset = 0.5 * math.pi
		end
		item.areaScore = 0.5 * (item.sizeX + item.sizeZ)
		previousName = item.name
	end
	local numGroups = groupIndex
	table.sort(items, function(itemA, itemB)
		return
			 itemA.areaScore < itemB.areaScore or
			(itemA.areaScore == itemB.areaScore and itemA.groupIndex < itemB.groupIndex) or
			(itemA.areaScore == itemB.areaScore and itemA.groupIndex == itemB.groupIndex and itemA.idString < itemB.idString)
	end)
	local minOffsetX, maxOffsetX, minOffsetZ, maxOffsetZ = 0, 0, 0, 0
	local currentX, currentY, currentZ, groupOffset = nil, 0, 0, 0
	local previousSizeX, previousSizeY, previousSizeZ = 0, 0, 0
	local iterationsY, maxY = 0, 0
	groupIndex = nil
	local function AdvancePosition(item)
		if not currentX or (math.abs(minOffsetX) > maxExtentX and maxOffsetX > maxExtentX) then
			if currentX then
				extentIncrement = extentIncrement * 1.25
				currentY = currentY + elevationIncrement
				maxExtentX = maxExtentX + extentIncrement
				if math.abs(currentZ) > maxExtentZ then
					iterationsY = iterationsY + 1
					extentIncrement = initialExtentIncrement
					maxExtentZ = maxExtentZ * 1.5
					maxExtentX = maxExtentX * 0.5
					currentX, currentY, currentZ = 0, iterationsY * 850, 0
					minOffsetX, minOffsetZ = 0, 0
					maxOffsetX, maxOffsetZ = 0, 0
					maxY = 0
				end
			end
			currentX, minOffsetX, maxOffsetX, minOffsetZ = 0, -0.5 * item.sizeX, 0.5 * item.sizeX, maxOffsetZ
			direction = 0
		elseif math.abs(minOffsetX) <= maxOffsetX then
			currentX, minOffsetX = minOffsetX - 0.5 * item.sizeX - 1, minOffsetX - item.sizeX - 2
			direction = -1
		else
			currentX, maxOffsetX = maxOffsetX + 0.5 * item.sizeX + 1, maxOffsetX + item.sizeX + 2
			direction = 1
		end
		maxOffsetZ = math.max(maxOffsetZ, minOffsetZ + item.sizeZ)
		currentZ = minOffsetZ + 0.5 * item.sizeZ
	end
	for index, item in ipairs(items) do
		if not groupIndex then
			groupIndex = item.groupIndex
			groupOffset = 1
			AdvancePosition(item)
		elseif groupIndex ~= item.groupIndex then
			groupIndex = item.groupIndex
			groupOffset = 1
			AdvancePosition(item)
		else
			groupOffset = groupOffset + 1
		end
		local itemOffsetX, itemOffsetZ = Rotate2D(currentX + item.offsetX, -currentZ + item.offsetZ, yaw)
		item.x = math.ceil(x + itemOffsetX)
		item.y = math.ceil(y + item.offsetY + 0.5 * item.sizeY + currentY)
		item.z = math.ceil(z + itemOffsetZ)
		item.yaw = yaw + (item.yawOffset or 0)
		maxY = math.max(maxY, currentY + item.sizeY + 20)
	end
	self.organizeItems = items
	self.organizeItemIndex = 1
	self:OnStateChanged("ORGANIZE", "ORGANIZE")
	EVENT_MANAGER:RegisterForUpdate(self.EventDescriptors["ORGANIZE"], 130, function() self:OnOrganizeFurniture() end)
end

function MSortManager:OrganizeHouse(skipFurnitureOrganization, skipCurrentHouse)
	self:WriteDebugCall("OrganizeHouse")
	if not self:CheckState() then
		return
	end
	self:RefreshPlacementLocation()
	local house = self:GetCurrentHouse()
	if not house then
		self:JumpToAnyHouse()
		return
	end
	if not skipCurrentHouse then
		local placementList = self:GetPlaceableFurnitureList()
		if #placementList ~= 0 then
			self:SwapFurniture(house)
			return
		end
		if not self:ValidateInventorySpace() then
			return
		end
		local numFreeSlots = GetNumBagFreeSlots(self.InventoryBag)
		local removalList = self:GetOutboundFurnitureList()
		if #removalList ~= 0 and numFreeSlots > 1 then
			self:SwapFurniture(house)
			return
		end
	end
	local nextHouse = self:GetNextHouse()
	if not skipFurnitureOrganization and self:GetDataManager():IsOrganizationEnabled() then
		zo_callLater(function() self:OrganizeFurniture() end, 650)
		return
	end
	if nextHouse then
		self:SwapFurniture(nextHouse)
		return
	end
	self:Complete()
end

function MSortManager:SwapFurniture(house)
	self:WriteDebugCall("SwapFurniture", house and house.houseId or "nil")
	if not self:CheckState() then
		return
	end
	self.swapHouse = house
	if self.swapHouse ~= self:GetCurrentHouse() then
		self:JumpToHouse(self.swapHouse)
		return
	end
	self:OnStateChanged("SWAP", "SWAP")
	local myself = self
	EVENT_MANAGER:RegisterForUpdate(self.EventDescriptors["SWAP"], self.SwapIntervalMS, function() myself:SwapAnyItem() end)
end

function MSortManager:SwapAnyItem()
	self:WriteDebugCall("SwapAnyItem")
	if not self:CheckState() then
		return
	end
	if self.swapHouse ~= self:GetCurrentHouse() then
		EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptors["SWAP"])
		self:JumpToHouse(self.swapHouse)
		return
	end
	local numFreeSlots = GetNumBagFreeSlots(self.InventoryBag)
	local houseId = self:GetHouseId()
	local placeList = self:GetPlaceableFurnitureList()
	local capacity1 = self:GetHouseCapacity(houseId, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM) or 0
	local capacity2 = self:GetHouseCapacity(houseId, HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM) or 0
	for _, item in ipairs(placeList) do
		if  (item.limitType == HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM and capacity1 > 0) or
			(item.limitType == HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM and capacity2 > 0) then
			if self:PlaceFurniture(item.bagId, item.slotIndex) then
				return
			end
		end
	end
	if not self:ValidateInventorySpace() then
		return
	end
	local removeList = self:GetOutboundFurnitureList()
	if numFreeSlots > 1 then
		local item = removeList[1]
		if item and self:RemoveFurniture(item.furnitureId) then
			return
		end
	end
	EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptors["SWAP"])
	self:OrganizeHouse(nil, true)
end

function MSortManager:JumpToAnyHouse()
	self:WriteDebugCall("JumpToAnyHouse")
	if not self:CheckState() then
		return
	end
	local targetHouse
	for houseId, house in pairs(self.houses) do
		targetHouse = house
		break
	end
	if targetHouse then
		self:JumpToHouse(targetHouse)
		return
	end
	self:Complete()
end

function MSortManager:OnJumpToHouseFailed(house)
	self:WriteDebugCall("OnJumpToHouseFailed", house and house.houseId or "nil")
	EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptors["JUMP"])
	if not self:CheckState() then
		return
	end
	local myself = self
	EVENT_MANAGER:RegisterForUpdate(self.EventDescriptors["JUMP"], 2000, function() myself:RetryJumpToHouse() end)
end

do
	local nextJumpAllowedMS = 0

	function MSortManager:RequestJumpToHouse(house, isRetry)
		self:WriteDebugCall("RequestJumpToHouse", house and house.houseId or "nil", isRetry)
		local frameTime = GetFrameTimeMilliseconds()
		if nextJumpAllowedMS <= frameTime then
			if IsPlayerActivated() then
				nextJumpAllowedMS = frameTime + 1000
				EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptors["JUMP"])
				self:OnStateChanged("JUMP", isRetry and "RETRY" or "JUMP", house.houseName)
				RequestJumpToHouse(house.houseId)
				local myself = self
				EVENT_MANAGER:RegisterForUpdate(self.EventDescriptors["JUMP"], isRetry and self.RetryJumpTimeoutMS or self.JumpTimeoutMS, function() myself:OnJumpToHouseFailed(house) end)
			else
				self:WriteDebug("Jump deferred pending player activation.")
			end
		end
	end
end

function MSortManager:JumpToHouse(house)
	self:WriteDebugCall("JumpToHouse", house and house.houseId or "nil")
	if not self:CheckState() then
		return
	end
	if self.jumpHouse then
		self:WriteDebug("Jump already in progress.")
		return
	end
	EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptors["JUMP"])
	CancelCast()
	self.jumpHouse = house
	local myself = self
	EVENT_MANAGER:RegisterForUpdate(self.EventDescriptors["JUMP"], 2000, function() myself:RequestJumpToHouse(house, false) end)
end

function MSortManager:RetryJumpToHouse()
	local house = self.jumpHouse
	self:WriteDebugCall("RetryJumpToHouse", house and house.houseId or "nil")
	if not self:CheckState() then
		return
	end
	if not house then
		self:WriteDebug("No jump is in progress.")
		return
	end
	EVENT_MANAGER:UnregisterForUpdate(self.EventDescriptors["JUMP"])
	CancelCast()
	self.jumpHouse = house
	local myself = self
	EVENT_MANAGER:RegisterForUpdate(self.EventDescriptors["JUMP"], 2000, function() myself:RequestJumpToHouse(house, true) end)
end

function MSortManager:RemoveFurniture(furnitureId)
	self:WriteDebugCall("RemoveFurniture", furnitureId and Id64ToString(furnitureId) or "nil")
	if not self:CheckState() then
		return false
	end
	if StackBag then
		StackBag(self.InventoryBag)
	end
	local categoryName = self:GetFurnitureCategoryName(self:GetFurnitureCategoryByFurnitureId(furnitureId))
	local furnitureName, _, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
	local _, _, _, limitType = GetFurnitureDataInfo(furnitureDataId)
	local itemName = string.format("%s\n(%s)", GetItemLinkName(GetPlacedFurnitureLink(furnitureId)) or "item", categoryName or "Unknown Category")
	-- The intent to remove an item is sufficient to clear the associated limit type's At Capacity flag.
	local result = HousingEditorRequestRemoveFurniture(furnitureId)
	if result == HOUSING_REQUEST_RESULT_SUCCESS then
		self:OnStateChanged("SWAP", "REMOVE", itemName)
		return true
	else
		self:OnStateChanged("EXCEPTION", "SWAP_REMOVE")
		return false
	end
end

function MSortManager:PlaceFurniture(bagId, slotIndex)
	bagId = bagId or self.InventoryBag
	self:WriteDebugCall("PlaceFurniture", bagId, slotIndex)
	if not self:CheckState() then
		return false
	end
	local categoryName = self:GetFurnitureCategoryName(self:GetFurnitureCategoryByBagAndSlot(bagId, slotIndex))
	local itemName = string.format("%s\n(%s)", GetItemName(bagId, slotIndex) or "item", categoryName or "Unknown Category")
	local x, y, z, yaw = self:GetPlacementLocation()
	local offsetX, offsetZ = Rotate2D(0, -800, yaw)
	x, z = x + offsetX, z + offsetZ
	local furnitureName = GetItemName(bagId, slotIndex)
	local furnitureDataId = GetItemFurnitureDataId(bagId, slotIndex)
	local _, _, _, limitType = GetFurnitureDataInfo(furnitureDataId)
	local result = HousingEditorRequestItemPlacement(bagId, slotIndex, x, y, z, 0, yaw, 0)
	if result == HOUSING_REQUEST_RESULT_SUCCESS then
		self:OnStateChanged("SWAP", "PLACE", itemName)
		return true
	elseif result == HOUSING_REQUEST_RESULT_HIGH_IMPACT_ITEM_PLACE_LIMIT or result == HOUSING_REQUEST_RESULT_LOW_IMPACT_ITEM_PLACE_LIMIT or result == HOUSING_REQUEST_RESULT_PERSONAL_TEMP_ITEM_PLACE_LIMIT or result == HOUSING_REQUEST_RESULT_TOTAL_TEMP_ITEM_PLACE_LIMIT then
		self:OnStateChanged("SWAP", "LIMIT")
		return false
	else
		self:OnStateChanged("EXCEPTION", "SWAP_PLACE")
		return false
	end
end
