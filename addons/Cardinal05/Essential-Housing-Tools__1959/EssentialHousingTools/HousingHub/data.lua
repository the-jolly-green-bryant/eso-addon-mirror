if IsNewerEssentialHousingHubVersionAvailable() or not IsEssentialHousingHubRootPathValid() then
	return
end

local EHH = EssentialHousingHub
if not EHH then
	return
end

--[ Open House Categories ]--

function EHH:GetOpenHouseCategories()
	local categories = self.Defs.CategoryFilters
	local maxCategoryVersion = #categories or 1
	return categories[maxCategoryVersion] or {}, maxCategoryVersion
end

function EHH:GetOpenHouseCategoryVersionAndIndex(categoryId)
	local categoryVersion = math.floor(categoryId)
	local categoryIndex = math.floor(0.5 + 1000 * (categoryId - categoryVersion))
	return categoryVersion, categoryIndex
end

function EHH:GetOpenHouseCategoryName(categoryId)
	categoryId = tonumber(categoryId)
	if not categoryId then
		return nil
	end

	local categoryVersion, categoryIndex = self:GetOpenHouseCategoryVersionAndIndex(categoryId)
	local categoryList = self.Defs.CategoryFilters[categoryVersion]
	return categoryList and categoryList[categoryIndex] or nil
end

function EHH:GetOpenHouseSubcategoryName(categoryId)
	local categoryName = self:GetOpenHouseCategoryName(categoryId)
	if categoryName then
		local dividerIndex = string.find(categoryName, " / ")
		if dividerIndex then
			return string.sub(categoryName, dividerIndex + 3)
		else
			return categoryName
		end
	end

	return nil
end

--[ State Tracking ]--

function EHH:GetInstallTimestamp()
	return data.InstallTimestamp
end

function EHH:GetPersistentStateTable()
	local data = self:GetData()
	local state = data.PersistentState
	if not state then
		state = {}
		data.PersistentState = state
	end
	return state
end

function EHH:GetPersistentState(key)
	key = tostring(key)
	if "string" == type(key) then
		key = string.lower(key)
		local state = self:GetPersistentStateTable()
		return state[key]
	end
	return nil
end

function EHH:SetPersistentState(key, value)
	key = tostring(key)
	if "string" == type(key) then
		key = string.lower(key)
		local state = self:GetPersistentStateTable()
		state[key] = value
	end
end

function EHH:ClearPersistentStateTable()
	self:GetData().PersistentState = {}
end

function EHH:ClearMessageStates()
	local data = self:GetData()
	data.MessageStates = {}
end

function EHH:GetMessageStates()
	local data = self:GetData()
	if not data.MessageStates then
		data.MessageStates = {}
	end
	return data.MessageStates
end

function EHH:HasShownMessage(key)
	if key then
		return true == self:GetMessageStates()[key]
	end
end

function EHH:SetMessageShown(key, shown)
	if key then
		self:GetMessageStates()[key] = false ~= shown
	end
end

---[ Houses ]---

function EHH:CreateHouseKey(world, houseId, owner)
	houseId = tonumber(houseId) or 0
	owner = string.lower(owner)
	if self:IsOwnerLocalPlayer(owner) then
		owner = nil
	end

	if 0 ~= houseId or owner then
		local houseKey = string.format("%d%s", houseId, owner or "")
		return houseKey, houseId, owner
	end
	
	return nil
end

function EHH:GetHouseKeyInfo(houseKey)
	local houseId, owner = nil, nil

	if houseKey then
		local separatorIndex = string.find(houseKey, "@")
		if separatorIndex then
			houseId = tonumber(string.sub(houseKey, 1, separatorIndex - 1))
			owner = self:Trim(string.sub(houseKey, separatorIndex))
		else
			houseId = tonumber(houseKey)
		end

		if 0 == houseId then
			houseId = nil
		end

		if "" == owner then
			owner = nil
		end
	end

	return houseId, owner
end

function EHH:GetHouses(world)
	local worldHouses = nil

	world = self:GetWorldCode(world)
	if world then
		local data = self:GetData()

		local houses = data.Houses
		if not houses then
			houses = {}
			data.Houses = houses
		end

		worldHouses = houses[world]
		if not worldHouses then
			worldHouses = {}
			houses[world] = worldHouses
		end
	end

	return worldHouses
end

function EHH:GetHouse(world, houseId, owner)
	local worldHouses = self:GetHouses(world)
	if worldHouses then
		local houseKey = self:CreateHouseKey(world, houseId, owner)
		if houseKey then
			return worldHouses[houseKey] or nil
		end
	end
	
	return nil
end

function EHH:GetOrCreateHouse(world, houseId, owner)
	local house
	local worldHouses = self:GetHouses(world)
	if worldHouses then
		local houseKey
		houseKey, houseId, owner = self:CreateHouseKey(world, houseId, owner)
		if houseKey then
			house = worldHouses[houseKey]
			if not house then
				house =
				{
					HouseId = houseId,
					Owner = owner,
					LastVisitTS = nil,
					Note = nil,
				}
				worldHouses[houseKey] = house
			end
		end
	end

	return house
end

function EHH:GetHouseLastVisit(world, houseId, owner)
	local house = self:GetHouse(world, houseId, owner)
	if house then
		return house.LastVisitTS
	end

	return nil
end

function EHH:SetHouseLastVisit(world, houseId, owner, timestamp)
	local house = self:GetOrCreateHouse(world, houseId, owner)
	if house then
		house.LastVisitTS = timestamp or GetTimeStamp()
	end
end

function EHH:GetHouseNote(world, houseId, owner)
	local house = self:GetHouse(world, houseId, owner)
	if house then
		return house.Note
	end

	return nil
end

function EHH:SetHouseNote(world, houseId, owner, note)
	local house = self:GetOrCreateHouse(world, houseId, owner)
	if house then
		house.Note = note
	end
end

---[ Inaccessible Houses ]---

function EHH:GetInaccessibleHouses(world)
	world = self:GetWorldCode(world)

	local data = self:GetData()
	local inaccessibleHouses = data.InaccessibleHouses
	if not inaccessibleHouses then
		inaccessibleHouses = {}
		data.InaccessibleHouses = inaccessibleHouses
	end

	local worldInaccessibleHouses = inaccessibleHouses[world]
	if not worldInaccessibleHouses then
		worldInaccessibleHouses = {}
		inaccessibleHouses[world] = worldInaccessibleHouses
	end

	return worldInaccessibleHouses
end

function EHH:GetInaccessibleHouse(world, houseId, owner)
	if self:IsOwnerLocalPlayer(owner) then
		return
	end

	if type(houseId) ~= "number" or houseId <= 0 then
		return
	end
	
	world = world or self.World

	local houseKey
	houseKey, houseId, owner = self:CreateHouseKey(world, houseId, owner)
	local inaccessibleHouses = self:GetInaccessibleHouses(world)
	local house = inaccessibleHouses[houseKey]

	if house and type(house.publishedDate) == "number" then
		local openHouse = self:GetOpenHouse(houseId, owner)
		if openHouse and type(openHouse.O) == "number" then
			if openHouse.O > house.publishedDate then
				-- The open house has since been republished by the owner;
				-- clear the inaccessible flag to give the owner another chance.
				inaccessibleHouses[houseKey] = nil
				return nil, houseKey
			end
		end
	end

	return inaccessibleHouses[houseKey], houseKey
end

function EHH:SetHouseInaccessibleFlag(world, houseId, owner, isInaccessible, attemptedDate, publishedDate)
	world = world or self.World

	local house, houseKey = self:GetInaccessibleHouse(world, houseId, owner)
	if not houseKey then
		return
	end

	local inaccessibleHouses = self:GetInaccessibleHouses(world)
	if isInaccessible then
		if not attemptedDate then
			attemptedDate = self:GetDate()
		end
		if not publishedDate then
			local openHouse = self:GetOpenHouse(houseId, owner)
			publishedDate = openHouse and openHouse.O or nil
		end

		inaccessibleHouses[houseKey] =
		{
			attemptedDate = attemptedDate,
			publishedDate = publishedDate,
		}
	else
		inaccessibleHouses[houseKey] = nil
	end
end

---[ Recently Visited Houses ]---

function EHH:GetRecentlyVisitedHouses(world)
	local data = self:GetData()

	local list = data.RecentlyVisitedHouses
	if not list then
		list = {}
		data.RecentlyVisitedHouses = list
	end

	local worldList
	world = self:GetWorldCode(world)
	if world then
		worldList = list[world]
		if not worldList then
			worldList = {}
			list[world] = worldList
		end
	end

	return worldList
end

function EHH:GetRecentlyVisitedHouseByIndex(index)
	local list = self:GetRecentlyVisitedHouses()
	if list then
		return list[index or 1]
	end

	return nil
end

function EHH:RemoveAllRecentlyVisitedHouses(world)
	local data = self:GetData()

	local list = data.RecentlyVisitedHouses
	if not list then
		list = {}
		data.RecentlyVisitedHouses = list
	end

	world = self:GetWorldCode(world)
	if world then
		list[world] = {}
	end

	self:OnRecentlyVisitedHousesUpdated()
end

local function OnRecentlyVisitedHousesUpdated()
	HUB_EVENT_MANAGER:UnregisterForUpdate("HousingHub.OnRecentlyVisitedHousesUpdated")
	HUB_CALLBACKS:FireCallbacks(HOUSING_HUB_CALLBACK_RECENTLY_VISITED_HOMES_UPDATED)
end

function EHH:OnRecentlyVisitedHousesUpdated()
	HUB_EVENT_MANAGER:RegisterForUpdate("HousingHub.OnRecentlyVisitedHousesUpdated", 25, OnRecentlyVisitedHousesUpdated)
end

function EHH:RemoveRecentlyVisitedHouse(world, houseId, owner)
	local list = self:GetRecentlyVisitedHouses(world)
	if not list then
		return false
	end

	if self:IsOwnerLocalPlayer(owner) then
		owner = nil
	else
		owner = string.lower(owner)
	end

	local result = false
	for index = #list, 1, -1 do
		local item = list[index]
		if houseId == item.HouseId and owner == item.Owner then
			table.remove(list, index)
			result = true
		end
	end
	
	self:OnRecentlyVisitedHousesUpdated()
	return result
end

function EHH:UpdateRecentlyVisitedHouses()
	if not self:IsHouseZone() or self:IsHousePreview() then
		return
	end

	local ts = GetTimeStamp()
	local world = self:GetWorldCode()
	local houseId = self:GetHouseId()
	local owner = string.lower(self:GetOwner())

	self:AddRecentlyVisitedHouse(world, houseId, owner, ts)

	if self:IsOwner() then
		self:IncUMTD("n_hvis", 1)
	elseif self:IsCurrentHouseOpen() then
		self:IncUMTD("n_ohvis", 1)
	else
		self:IncUMTD("n_gvis", 1)
	end
end

function EHH:AddRecentlyVisitedHouse(world, houseId, owner, ts)
	if not world or not houseId then
		return false
	end

	if self:IsOwnerLocalPlayer(owner) then
		owner = nil
	end
	ts = tonumber(ts) or GetTimeStamp()

	self:RemoveRecentlyVisitedHouse(world, houseId, owner)

	local list = self:GetRecentlyVisitedHouses(world)
	if not list then
		return false
	end

	local item =
	{
		HouseId = houseId,
		Owner = owner,
		TS = ts,
	}

	local inserted = false
	local numRecents = #list
	for index = 1, numRecents do
		local recent = list[index]
		if not recent or not recent.TS or ts > recent.TS then
			table.insert(list, index, item)
			inserted = true
			break
		end
	end
	
	if not inserted then
		table.insert(list, item)
	end

	local maxSize = self.Defs.Limits.MaxRecentlyVisitedHouses
	while #list > maxSize do
		table.remove(list, maxSize + 1)
	end

	self:SetHouseLastVisit(world, houseId, owner, ts)
	self:OnRecentlyVisitedHousesUpdated()

	return true
end

---[ Favorite Houses ]---

function EHH:GetFavoriteHouses(world)
	local data = self:GetData()

	local allFavorites = data.FavoriteHouses
	if not allFavorites then
		allFavorites = {}
		data.FavoriteHouses = allFavorites
	end

	world = self:GetWorldCode(world)
	if not world then
		return
	end

	local favorites = allFavorites[world]
	if not favorites then
		favorites = {}
		allFavorites[world] = favorites
	end

	return favorites
end

function EHH:AddOrUpdateFavoriteHouse(world, houseId, owner, preferredIndex)
	world = self:GetWorldCode(world)
	if not world then
		return false
	end

	local favorites = self:GetFavoriteHouses(world)
	local maxFavorites = self.Defs.Limits.MaxFavoriteHouses
	local numFavorites = #favorites

	if preferredIndex then
		preferredIndex = math.min(preferredIndex, numFavorites + 1)
		if preferredIndex > maxFavorites then
			return false
		end
	end

	local houseKey
	houseKey, houseId, owner = self:CreateHouseKey(world, houseId, owner)
	if not houseKey then
		return false
	end

	for index, favoriteHouseKey in ipairs(favorites) do
		if favoriteHouseKey == houseKey then
			table.remove(favorites, index)
			if preferredIndex and index < preferredIndex then
				preferredIndex = preferredIndex - 1
			end
			numFavorites = #favorites
			break
		end
	end

	if preferredIndex then
		preferredIndex = math.min(preferredIndex, numFavorites + 1)
	end

	if numFavorites >= maxFavorites then
		return false
	end

	if preferredIndex then
		table.insert(favorites, preferredIndex, houseKey)
	else
		table.insert(favorites, houseKey)
	end

	self:InvalidateHubList("Favorites")
	self:RefreshHousingHub()

	return true
end

function EHH:RemoveFavoriteHouse(world, houseId, owner)
	local houseKey
	houseKey, houseId, owner = self:CreateHouseKey(world, houseId, owner)

	if not houseKey then
		return false
	end

	local favorites = self:GetFavoriteHouses(world)
	if not favorites then
		return false
	end

	-- Find the favorite.

	local favoriteIndex
	for index, favoriteHouseKey in pairs(favorites) do
		if favoriteHouseKey == houseKey then
			favoriteIndex = index
			break
		end
	end

	if not favoriteIndex then
		return false
	end

	-- Remove the favorite.

	table.remove(favorites, favoriteIndex)

	self:InvalidateHubList("Favorites")
	self:RefreshHousingHub()

	return true
end

function EHH:MoveFavoriteHouse(world, oldIndex, newIndex)
	oldIndex, newIndex = tonumber(oldIndex), tonumber(newIndex)
	if oldIndex == newIndex or not oldIndex or not newIndex then
		return false
	end

	local favorites = self:GetFavoriteHouses(world)
	if not favorites then
		return false
	end

	local numFavorites = #favorites
	local maxIndex = math.min(numFavorites + 1)
	newIndex = math.min(newIndex, maxIndex)
	if 1 > oldIndex or 1 > newIndex or oldIndex > numFavorites then
		return false
	end

	-- Get the favorite that is being moved.

	local houseData = table.remove(favorites, oldIndex)
	if not houseData then
		return false
	end

	newIndex = math.min(newIndex, #favorites + 1)
	table.insert(favorites, newIndex, houseData)

	self:InvalidateHubList("Favorites")
	self:RefreshHousingHub()

	return true
end

function EHH:GetFavoriteHouse(favoriteIndex)
	local favorites = self:GetFavoriteHouses()
	local houseKey = favorites[favoriteIndex]
	if houseKey then
		local houseId, owner = self:GetHouseKeyInfo(houseKey)
		return houseId, owner
	end
end

function EHH:GetFavoriteHouseIndex(world, houseId, owner)
	local houseKey
	houseKey, houseId, owner = self:CreateHouseKey(world, houseId, owner)
	if not houseKey then
		return nil
	end

	local favorites = self:GetFavoriteHouses(world)
	if not favorites then
		return nil
	end

	for index, favoriteHouseKey in ipairs(favorites) do
		if favoriteHouseKey == houseKey then
			return index
		end
	end

	return nil
end

function EHH:IsFavoriteHouse(world, houseId, owner)
	return nil ~= self:GetFavoriteHouseIndex(world, houseId, owner)
end

function EHH:ToggleFavoriteHouse(world, houseId, owner)
	if self:IsFavoriteHouse(world, houseId, owner) then
		self:RemoveFavoriteHouse(world, houseId, owner)
		return false
	else
		return self:AddOrUpdateFavoriteHouse(world, houseId, owner)
	end
end

---[ Primary Houses ]---

function EHH:GetPrimaryHouses(world)
	world = self:GetWorldCode(world)
	if not world then
		return nil
	end

	local houses = self:GetData().PrimaryHouses
	if not houses then
		houses = {}
		self:GetData().PrimaryHouses = houses
	end

	local worldHouses = houses[world]
	if not worldHouses then
		worldHouses = {}
		houses[world] = worldHouses
	end

	return worldHouses
end

function EHH:GetPrimaryHouse(characterName)
	local primaryHouses = self:GetPrimaryHouses()

	if not characterName then
		characterName = self:GetCharacterName()
	end
	characterName = string.lower(characterName)

	local houseId = primaryHouses[characterName]
	local house = nil

	if houseId then
		house = self:GetHouseById(houseId)
	end

	if not house then
		houseId = GetHousingPrimaryHouse()
		house = self:GetHouseById(houseId)
	end

	return house
end

function EHH:GetPrimaryHouseId()
	local house = self:GetPrimaryHouse()
	if house then
		return house.Id
	end

	return nil
end

function EHH:SetPrimaryHouse(characterName, houseId)
	local primaryHouses = self:GetPrimaryHouses()

	if not characterName then
		characterName = self:GetCharacterName()
	end
	characterName = string.lower(characterName)

	primaryHouses[characterName] = houseId
end

function EHH:RemovePrimaryHouse(characterName)
	local primaryHouses = self:GetPrimaryHouses()

	if not characterName then
		characterName = self:GetCharacterName()
	end
	characterName = string.lower(characterName)

	primaryHouses[characterName] = nil
end

---[ Guest Journal Signatures ]---

local function GuestComparer(left, right)
	return left.visitDate > right.visitDate
end

function EHH:GetAllHouseGuests()
	local houseGuests = self.HouseGuestList
	if not houseGuests then
		houseGuests = {}
		self.HouseGuestList = houseGuests

		local openHouses = self:GetOpenHouses()
		if openHouses then
			local owner = self.DisplayNameLower

			for houseId, houseData in pairs(openHouses) do
				local signatures = self:GetCommunityGuestbookRecord(owner, houseId)
				if signatures then
					for _, signature in pairs(signatures) do
						local guestName, guestVisitDate = signature[1], tonumber(signature[2])
						if guestName and guestVisitDate then
							local startIndex, endIndex, guestDisplayName = string.find(guestName, "%((.+)%)")
							if guestDisplayName and startIndex and startIndex > 2 then
								guestName = string.sub(guestName, 1, startIndex - 2)
							end

							local guest =
							{
								houseId = houseId,
								houseName = houseData.N or self:GetHouseName(houseId),
								name = guestName,
								displayName = guestDisplayName,
								visitDate = guestVisitDate,
							}
							table.insert(houseGuests, guest)
						end
					end
				end
			end

			table.sort(houseGuests, GuestComparer)
		end
	end

	return houseGuests
end

function EHH:ResetViewedGuestCount()
	self:SetPersistentState("ViewedGuestCount", nil)
end

function EHH:GetViewedGuestCount()
	return self:GetPersistentState("ViewedGuestCount") or 0
end

function EHH:UpdateViewedGuestCount()
	local guests = self:GetAllHouseGuests()
	self:SetPersistentState("ViewedGuestCount", guests and #guests or 0)
end

function EHH:HasUnviewedGuests(guests)
	guests = guests or self:GetAllHouseGuests()
	local currentGuestCount = self:GetViewedGuestCount()
	local newGuestCount = guests and #guests or 0
	return 0 ~= newGuestCount and newGuestCount ~= currentGuestCount
end

function EHH:OnGuestJournalSigned()
	local houseId = self:GetHouseId()
	if 0 ~= houseId then
		local owner = self:GetOwner()
		local data =
		{
			houseId = houseId,
			owner = owner,
			timestamp = GetTimeStamp(),
		}
		self:SetPersistentState("RecentJournalSignature", data)
	end
end

function EHH:HasLocalPlayerRecentlySignedGuestJournal()
	local houseId = self:GetHouseId()
	if 0 ~= houseId then
		local owner = self:GetOwner()
		local data = self:GetPersistentState("RecentJournalSignature")
		if "table" == type(data) then
			if houseId == data.houseId and owner == data.owner then
				local ts = tonumber(data.timestamp)
				if ts and (GetTimeStamp() - ts) < 3600 then
					return true
				end
			end
		end
	end
	return false
end

---[ Effects ]---

function EHH:GetHouseEffects(houseId, owner)
	if not houseId or 0 == houseId then
		houseId = houseId or self:GetHouseId()
		owner = owner or self:GetOwner()
	end

	local isLocalPlayer = self:IsOwnerLocalPlayer(owner)
	local effects, timestamp
	local house

	if self.IsEHT and EHT.Data.GetHouseEffectsAndTimestamp then
		house = EHT.Data.GetHouseEffectsAndTimestamp(houseId, owner)
		if house then
			if not isLocalPlayer then
				timestamp = tonumber(house.EffectsTimestamp)
			end
			effects = house.Effects
		end
	end

	if not self.IsEHT or not isLocalPlayer then
		local houseKey = self:CreateHouseKey(self.World, houseId, owner)
		if houseKey then
			local publishedEffects = self:GetCommunityHouseFXRecord(owner, self.World, houseId)
			if publishedEffects and "table" == type(publishedEffects.Effects) then
				local publishedTimestamp = tonumber(publishedEffects.TS)
				if publishedTimestamp and (not timestamp or 0 == timestamp or timestamp < publishedTimestamp) then
					effects = self:CloneTable(publishedEffects.Effects)
					timestamp = publishedTimestamp
				end
			end

			if house and not effects then
				effects = house.Effects
				if not effects then
					effects = {}
					house.Effects = effects
				end
			end
		end
	end

	return effects, timestamp
end

---[ Live Streams ]---

function EHH:GetHousingHubStreamMessagePosition()
	local position = self:GetPersistentState("LiveStreamMessagePosition")
	local maxX, maxY = GuiRoot:GetDimensions()
	local offsetX, offsetY = 0, 0
	if "table" == type(position) then
		offsetX, offsetY = tonumber(position.X) or 0, tonumber(position.Y) or 0
	end
	return maxX * offsetX, maxY * offsetY
end

function EHH:SetHousingHubStreamMessagePosition(offsetX, offsetY)
	local maxX, maxY = GuiRoot:GetDimensions()
	local position =
	{
		X = (tonumber(offsetX) or 0) / maxX,
		Y = (tonumber(offsetY) or 0) / maxY,
	}
	self:SetPersistentState("LiveStreamMessagePosition", position)
end

function EHH:HasShownLiveStreamMessage(channelData)
	if "table" == type(channelData) then
		local lastLiveStreams = self:GetPersistentState("LastLiveStreams")
		if "table" == type(lastLiveStreams) then
			local lastLiveTS = tonumber(lastLiveStreams[channelData.Player])
			return lastLiveTS and channelData.LastLiveTS <= lastLiveTS
		end
	end
	return false
end

function EHH:SetLiveStreamMessageShown(channelData)
	if "table" == type(channelData) then
		local lastLiveStreams = self:GetPersistentState("LastLiveStreams")
		if "table" ~= type(lastLiveStreams) then
			lastLiveStreams = {}
			self:SetPersistentState("LastLiveStreams", lastLiveStreams)
		end
		lastLiveStreams[channelData.Player] = channelData.LastLiveTS
	end
end

---[ Stream Channel ]---

function EHH:GetStreamChannelData()
	local data = self:GetData()
	local channelData = data.StreamChannel
	if "table" ~= type(channelData) then
		channelData = {}
		data.StreamChannel = channelData
	end
	return channelData
end

function EHH:IsStreamChannelDataValid()
	local data = self:GetStreamChannelData()
	if	"table" == type(data) and
		data.ChannelName and tostring(data.ChannelName) ~= "" and
		data.Description and tostring(data.Description) ~= "" and
		data.Schedule and tostring(data.Schedule) ~= "" and
		data.URL and tostring(data.URL) ~= "" then
		return true
	end
	return false
end

function EHH:UpdateStreamChannelData()
	if self:IsStreamChannelDataValid() then
		local data = self:GetStreamChannelData()
		return self:SetCommunityStreamChannelRecord(data)
	end
	return false
end

function EHH:UpdateStreamChannelLastLiveTS(ts, durationHours)
	if self:IsStreamChannelDataValid() then
		local data = self:GetStreamChannelData()
		data.LastLiveTS = ts
		data.LastEndTS = ts + (durationHours or 2) * 3600
		return self:SetCommunityStreamChannelRecord(data)
	end
	return false
end

function EHH:ClearStreamChannelData()
	local data = self:GetStreamChannelData()
	if "table" == type(data) and next(data) then
		ZO_ClearTable(data)
		return self:SetCommunityStreamChannelRecord({})
	end
end

function EHH:StreamChannelGoLive(durationHours)
	if self:UpdateStreamChannelLastLiveTS(GetTimeStamp(), durationHours) then
		local INSTANT = true
		self:IncUMTD("n_scl", 1, INSTANT)
		return true
	end
	self:ShowStreamChannelSettings()
	return false
end

function EHH:OpenStreamChannelURL(url)
	if url and "" ~= url then
		self:ShowURL(url)
		local INSTANT = true
		self:IncUMTD("n_scvis", 1, INSTANT)
	end
end

function EHH:AreStreamChannelsLive()
	local now = GetTimeStamp()
	local metaDataList = self:GetCommunityMetaDataByKey("sc")
	local MAX_BROADCAST_SECONDS = self.Defs.Limits.MaxBroadcastSeconds

	if "table" == type(metaDataList) then
		for key, channelData in pairs(metaDataList) do
			local lastLiveTS = tonumber(channelData.LastLiveTS)
			if lastLiveTS then
				local lastEndTS = tonumber(channelData.LastEndTS)
				if not lastEndTS or lastEndTS < lastLiveTS then
					lastEndTS = lastLiveTS + MAX_BROADCAST_SECONDS
				end
				if now <= lastEndTS then
					return true
				end
			end
		end
	end

	return false
end

---[ Data Migration ]---

function EHH:UpgradeAndRepairSavedVariables()
	local data = self:GetData()
	
	if not data.InstallTimestamp then
		data.InstallTimestamp = GetTimeStamp()
	end

	if not data.Houses then
		data.Houses = {}
	end

	if not data.FavoriteHouses then
		data.FavoriteHouses = {}
	end

	do
		local function CompareFavoriteHouses(left, right)
			return left[1] < right[1]
		end

		for world, favoriteHouses in pairs(data.FavoriteHouses) do
			local numericallyIndexedFavoriteHouses = {}
			for index, houseKey in pairs(favoriteHouses) do
				if "string" == type(houseKey) then
					table.insert(numericallyIndexedFavoriteHouses, {index, string.lower(houseKey)})
				else
					table.insert(numericallyIndexedFavoriteHouses, {index, houseKey})
				end
			end

			table.sort(numericallyIndexedFavoriteHouses, CompareFavoriteHouses)

			local newFavorites = {}
			data.FavoriteHouses[world] = newFavorites
			for _, favorite in ipairs(numericallyIndexedFavoriteHouses) do
				table.insert(newFavorites, favorite[2])
			end
		end
	end
end

function EHH:MigrateHouseDataFromEHT(forceMigration)
	if not self.IsEHT then
		return false
	end

	local getFavoritesFunction = EHT.Data.GetFavoriteHouses
	local getNotesFunction = EHT.Data.GetHouseNotes
	local getRecentsFunction = EHT.Data.GetRecentlyVisited
	local getInaccessiblesFunction = EHT.Biz.GetInaccessibleHouses
	if not getFavoritesFunction and not getNotesFunction and not getRecentsFunction and not getInaccessiblesFunction then
		return false
	end

	if self:GetPersistentState("EHTDataMigrationDate") and not forceMigration then
		return false
	end
	self:SetPersistentState("EHTDataMigrationDate", GetTimeStamp())

	local worldCodes = self:GetAllWorldCodes()
	for world in pairs(worldCodes) do
		if getFavoritesFunction then
			local favoriteHouses = getFavoritesFunction(world)
			if "table" == type(favoriteHouses) then
				for favoriteIndex, favoriteHouse in pairs(favoriteHouses) do
					if "table" == type(favoriteHouse) then
						local houseId, owner = favoriteHouse.HouseId, favoriteHouse.Owner
						self:AddOrUpdateFavoriteHouse(world, houseId, owner)
					end
				end
			end
		end

		if getNotesFunction then
			local houseNotes = getNotesFunction(world)
			if "table" == type(houseNotes) then
				for houseKey, houseNote in pairs(houseNotes) do
					if "table" == type(houseNote) and houseNote.Note then
						local note = tostring(houseNote.Note)
						if "" ~= note then
							local houseId, owner = self:GetHouseKeyInfo(string.lower(houseKey))
							houseId = tonumber(houseId)

							local noteData = { Note = note, Date = tonumber(houseNote.Date) or GetTimeStamp() }
							self:SetHouseNote(world, houseId, owner, noteData)
						end
					end
				end
			end
		end
		
		if getRecentsFunction then
			local recentHouses = getRecentsFunction(world)
			if "table" == type(recentHouses) then
				local numRecentHouses = #recentHouses
				for recentIndex = numRecentHouses, 1, -1 do
					local recentHouse = recentHouses[recentIndex]
					if "table" == type(recentHouse) then
						local houseId = tonumber(recentHouse.HouseId)
						if houseId then
							local owner = string.lower(recentHouse.Owner)
							local ts = tonumber(recentHouse.Timestamp)
							self:AddRecentlyVisitedHouse(world, houseId, owner, ts)
						end
					end
				end
			end
		end
		
		if getInaccessiblesFunction then
			local INACCESSIBLE = true
			local inaccessibleHouses = getInaccessiblesFunction(world)
			if "table" == type(inaccessibleHouses) then
				for houseKey, dates in pairs(inaccessibleHouses) do
					if "table" == type(dates) and dates.attemptedDate then
						local attemptedDate = tonumber(dates.attemptedDate)
						if attemptedDate then
							local publishedDate = tonumber(dates.publishedDate)
							local houseId, owner = self:GetHouseKeyInfo(string.lower(houseKey))
							houseId = tonumber(houseId)
							self:SetHouseInaccessibleFlag(world, houseId, owner, INACCESSIBLE, attemptedDate, publishedDate)
						end
					end
				end
			end
		end
	end

	if self.IsEHT then
		local allHouses = EHT.Data.GetHouses()
		if "table" == type(allHouses) then
			for houseKey, houseData in pairs(allHouses) do
				if "table" == type(houseData) and houseData.VisitTimestamp then
					local houseId, owner = self:GetHouseKeyInfo(houseKey)
					if houseId then
						local timestamp = tonumber(houseData.VisitTimestamp)
						if timestamp and 0 ~= timestamp then
							for world in pairs(worldCodes) do
								self:SetHouseLastVisit(world, houseId, owner, timestamp)
							end
						end
					end
				end
			end
		end
	end

	return true
end

---[ Module Registration ]---

EssentialHousingHub.Modules.Data = true