if IsNewerEssentialHousingHubVersionAvailable() or not IsEssentialHousingHubRootPathValid() then
	return
end

local EHH = EssentialHousingHub
if not EHH then
	return
end

local function StripCharacter(s, c, r)
	if s then
		return string.gsub(s, c, r or "")
	end
end

---[ Essential Housing Community ]---

function EHH:GetCurrentSignerName()
	return string.format("%s (%s)", self:GetCharacterName(), GetDisplayName())
end

do
	local isCommunityDefined = false

	function EHH:IsCommunityDefined()
		if not isCommunityDefined then
			isCommunityDefined = EHT and EHT.Community and EHT.Community.GetRecord and EHT.Community.SetRecord and true or false
		end
		return isCommunityDefined
	end
end

function EHH:CheckCommunityConnection(suppressDialog)
	local valid = self:IsCommunityDefined()
	if valid and nil == self.IsCommunityTimestampValid then
		self.IsCommunityTimestampValid = "number" == type(EHT.Community.LocalTimeStamp) and math.abs(GetTimeStamp() - EHT.Community.LocalTimeStamp) <= self.Defs.Limits.MaxCommunityServerTimestampDifference
	end
	valid = valid and self.IsCommunityTimestampValid

	if not valid and not suppressDialog then
		local message

		if self:HasShownMessage("CheckCommunityConnection") then
			message = "" ..
				"|cffff00The Community App cannot be detected\n\n" ..
				"|cffffffPlease reinstall the Community App in order to restart your sync process, then type |c00ffff/reloadui|cffffff. " ..
				"If you continue to receive this message after doing so, please check the following:\n\n" ..
				"* EssentialHousingCommunity Add-on\n" ..
				"Features that need a connection to the Community server, such as Open Houses and Guest Journals, require the " ..
				"EssentialHousingCommunity Add-on to be enabled.\n\n" ..
				"* EssentialHousingCommunity App\n" ..
				"In addition, the EssentialHousingCommunity app (prebundled with the Housing Hub or Essential Housing Tools) must be installed.\n\n" ..
				"* Cloud drive/backup software backing up your ESO data folder\n" ..
				"Apps such as DropBox, Google Drive, iCloud and OneDrive can actually cause ESO to fail to save larger add-on data files properly. " ..
				"To resolve such an issue, add a Folder Exclusion to your Cloud drive/backup software for the following folder and its subfolders:\n" ..
				"|c00ffff\\Documents\\Elder Scrolls Online\\live\\ folder or any subfolders|cffffff\n\n" ..
				"* Firewall or virus scanner software\n" ..
				"A digital signature for an application is expensive so we have elected not to purchase one; for this reason, some firewall and virus " ..
				"scanner software may block the EssentialHousingCommunity app from running, connecting to the Community server or from updating its own files. " ..
				"To resolve such an issue, please unblock the EssentialHousingCommunity app in your firewall or virus scanner software.\n\n" ..
				"|cffffffWatch the |c00ffffInstallation Guide video (<1 min)|cffffff now?"
		else
			self:SetMessageShown("CheckCommunityConnection", true)
			message = "" ..
				"|cffffffTo use this feature, the following must be installed and enabled:\n\n" ..
				"|cffffff* Essential Housing Community add-on\n" ..
				"|cffffff* Essential Housing Community application\n\n" ..
				"|cffffffWatch the |c00ffffInstallation Guide video (<1 min)|cffffff now?"
		end

		local dialogData =
		{
			body = message,
			buttons =
			{
				{
					text = "Not right now",
					handler = function() end,
				},
				{
					text = "Watch guide video",
					handler = function()
						self:ShowURL(self.Defs.Urls.SetupCommunityPC)
					end,
				},
			},
		}
		self:ShowCustomDialog(dialogData)
	end

	return valid
end

function EHH:GetCommunityRecord(key)
	if not self:IsCommunityDefined() then
		return nil
	end

	if "string" ~= type(key) then
		return nil
	end

	return EHT.Community.GetRecord(key)
end

function EHH:SetCommunityFXRecord(houseId, effects)
	if "number" ~= type(houseId) or 0 >= houseId or (nil ~= effects and "table" ~= type(effects)) then
		return false
	end

	if not self:CheckCommunityConnection() then
		return false
	end

	local ts = GetTimeStamp()
	local version = self.AddOnVersion
	local world = string.lower(self.World)
	local player = string.lower(self.DisplayNameLower)
	local key = string.format("fx__%s__%s__%d", world, player, houseId)
	local data =
	{
		TS = ts,
		Version = version,
		Effects = effects,
	}
	local result = EHT.Community.SetRecord(key, data)

	if result and EHT.Data and EHT.Data.ClearHouseFXDirty then
		EHT.Data.ClearHouseFXDirty(houseId)
	end

	-- Eliminate this home's duplicate record from an existing legacy bulk record.
	local legacyRecord = self:GetCommunityLegacyFXRecord(player)
	if "table" == type(legacyRecord) and (nil ~= tonumber(legacyRecord.HouseId) or "table" == type(legacyRecord.Houses)) then
		local updated = false
		local empty = true

		if nil ~= tonumber(legacyRecord.HouseId) then
			empty = false
			if houseId == legacyRecord.HouseId and world == string.lower(legacyRecord.World) then
				legacyRecord.HouseId = nil
				legacyRecord.World = nil
				legacyRecord.TS = nil
				legacyRecord.Effects = nil
				legacyRecord.Version = nil
				updated = true
			end
		end

		if "table" == type(legacyRecord.Houses) then
			for index, house in pairs(legacyRecord.Houses) do
				if houseId == house.HouseId and world == string.lower(house.World) then
					table.remove(legacyRecord.Houses, index)
					updated = true
				else
					empty = false
				end
			end
		end

		if empty then
			updated = true
			legacyRecord = {}
		end

		if updated then
			key = string.format("fx__%s", player)
			EHT.Community.SetRecord(key, legacyRecord)
		end
	end

	return result
end

function EHH:GetCommunityLegacyFXRecord(player)
	if not self:IsCommunityDefined() then
		return nil
	end

	if "string" ~= type(player) then
		return nil
	end

	local key = string.format("fx__%s", string.lower(player))
	return EHT.Community.GetRecord(key)
end

function EHH:GetCommunityHouseFXRecord(player, world, houseId)
	if not self:IsCommunityDefined() then
		return nil
	end

	houseId = tonumber(houseId)
	if "string" ~= type(player) or "string" ~= type(world) or "number" ~= type(houseId) then
		return nil
	end

	world = string.lower(world)
	if not self:IsValidWorldCode(world) then
		return nil
	end

	player = string.lower(player)
	local key = string.format("fx__%s__%s__%d", world, player, houseId)
	local data = EHT.Community.GetRecord(key)
	if "table" == type(data) then
		return data
	end

	data = nil
	key = string.format("fx__%s", player)
	local legacyRecord = EHT.Community.GetRecord(key)
	if "table" == type(legacyRecord) then
		if houseId == legacyRecord.HouseId and string.lower(legacyRecord.World) == world then
			data =
			{
				TS = legacyRecord.TS,
				World = legacyRecord.World,
				HouseId = legacyRecord.HouseId,
				Effects = legacyRecord.Effects,
				Version = legacyRecord.Version,
			}
		elseif "table" == type(legacyRecord.Houses) then
			for index, house in pairs(legacyRecord.Houses) do
				if houseId == house.HouseId and string.lower(house.World) == world then
					data = house
					break
				end
			end
		end
	end

	return data
end

function EHH:UpgradeCommunityOpenHouseRecord(record, key)
	if "table" ~= type(record) then
		return record, false
	end

	if "table" ~= type(record.Houses) then
		return record, false
	end

	local upgradedData = {}
	local ts = tonumber(record.TS) or GetTimeStamp()
	local defaultDate = self:GetDate(ts)
	upgradedData.TS = ts
	upgradedData.Version = self.AddOnVersion

	local hasDates = "table" == type(record.Dates)
	for world, houses in pairs(record.Houses) do
		if "table" == type(houses) and self:IsValidWorldCode(world) then
			local upgradedHouses = {}
			upgradedData[world] = upgradedHouses

			for houseId, houseName in pairs(houses) do
				local dateOpened = hasDates and record.Dates[world] and record.Dates[world][houseId] or nil
				upgradedHouses[houseId] =
				{
					N = houseName,
					O = dateOpened or defaultDate,
				}
			end
		end
	end

	if key then
		EHT.Community.SetRawRemoteRecord(key, upgradedData)
	end

	return upgradedData, true
end

function EHH:GetCommunityStreamChannelRecordByKey(key)
	if EHT and EHT.Community then
		local record = EHT.Community.GetRecord(key)
		return record
	end
	return nil
end

function EHH:GetCommunityStreamChannelRecord(player)
	if "string" ~= type(player) then
		return nil
	end
	local key = string.format("sc__%s", string.lower(player))
	return self:GetCommunityStreamChannelRecordByKey(key)
end

function EHH:SetCommunityStreamChannelRecord(record, suppressDialog, suppressPostReloadFlag)
	if "table" ~= type(record) then
		return false
	end

	if not self:CheckCommunityConnection(true == suppressDialog) then
		return nil
	end

	record.TS = GetTimeStamp()
	record.Version = self.AddOnVersion

	local key = string.format("sc__%s", self.DisplayNameLower)
	return EHT.Community.SetRecord(key, record, suppressPostReloadFlag)
end

function EHH:SetCommunityOpenHouseRecord(record, suppressDialog, suppressPostReloadFlag)
	if not self:CheckCommunityConnection(true == suppressDialog) then
		return nil
	end

	record = self:UpgradeCommunityOpenHouseRecord(record)
	if "table" ~= type(record) then
		return false
	end

	local ts = GetTimeStamp()
	local now = self:GetDate(ts)
	for world, houses in pairs(record) do
		if "table" == type(houses) and self:IsValidWorldCode(world) then
			for houseId, house in pairs(houses) do
				if "table" == type(house) then
					if not house.O then
						house.O = now
					end
				end
			end
		end
	end

	record.TS = ts
	record.Version = self.AddOnVersion

	local key = string.format("oh__%s", self.DisplayNameLower)
	return EHT.Community.SetRecord(key, record, suppressPostReloadFlag)
end

function EHH:GetCommunityOpenHouseRecord(player)
	if "string" ~= type(player) then
		return nil
	end
	local key = string.format("oh__%s", string.lower(player))
	return self:GetCommunityOpenHouseRecordByKey(key)
end

function EHH:GetCommunityOpenHouseRecordByKey(key)
	if EHT and EHT.Community then
		local record = EHT.Community.GetRecord(key)
		local upgradedRecord = self:UpgradeCommunityOpenHouseRecord(record, key)
		return upgradedRecord
	end
	return nil
end

function EHH:GetOpenHouses(player)
	local record = self:GetCommunityOpenHouseRecord(player or self.DisplayName)
	if "table" == type(record) then
		local houses = record[self.World]
		if "table" == type(houses) then
			return houses
		end
	end
	return nil
end

function EHH:GetOpenHouse(houseId, player)
	local openHouses = self:GetOpenHouses(player)
	return openHouses and openHouses[houseId]
end

function EHH:GetOpenHouseName(houseId, player)
	local openHouse = self:GetOpenHouse(houseId, player)
	return openHouse and openHouse.N or nil
end

function EHH:GetOpenHouseCategory(houseId, player)
	local openHouse = self:GetOpenHouse(houseId, player)
	return openHouse and openHouse.C or self:GetUncategorizedOpenHouseCategory()
end

function EHH:GetOpenHouseDescription(houseId, player)
	local openHouse = self:GetOpenHouse(houseId, player)
	return openHouse and openHouse.D or nil
end

function EHH:GetOpenHouseInfo(houseId, player)
	local openHouse = self:GetOpenHouse(houseId, player)
	if openHouse then
		local name = openHouse.N
		local opened = openHouse.O
		local category = openHouse.C or self:GetUncategorizedOpenHouseCategory()
		local description = openHouse.D
		return name, opened, category, description
	end
end

function EHH:IsOpenHouse(houseId, player)
	return nil ~= self:GetOpenHouse(houseId, player)
	--return openHouse and not openHouse.expired
	--local active, expired = openHouse and not openHouse.expired, openHouse and openHouse.expired
	--return active, expired
end

function EHH:ToggleOpenHouse(houseId, houseCategory, houseDescription, enabled, suppressDialog)
	if not houseId or 0 >= houseId then
		return nil
	end

	if not self:CheckCommunityConnection(true == suppressDialog) then
		return nil
	end

	local record = self:GetCommunityOpenHouseRecord(self.DisplayName)
	if "table" ~= type(record) then
		record = {}
	end

	local houses = record[self.World]
	if "table" ~= type(houses) then
		houses = {}
		record[self.World] = houses
	end

	local house = houses[houseId]
	if nil == enabled then
		enabled = nil == house
	end

	if enabled then
		houses[houseId] =
		{
			C = houseCategory or (house and house.C or nil),
			D = houseDescription or (house and house.D or nil),
			N = GetCollectibleNickname(GetCollectibleIdForHouse(houseId)),
			O = self:GetDate(GetTimeStamp()),
		}
	else
		houses[houseId] = nil
	end

	if nil == self:SetCommunityOpenHouseRecord(record) then
		return nil
	end

	if enabled then
		EssentialHousingHub:IncUMTD("n_hop", 1)
	end

	return enabled
end

function EHH:UpdateOpenHouseNickname(collectibleId)
	if GetCollectibleCategoryType(collectibleId) ~= COLLECTIBLE_CATEGORY_TYPE_HOUSE then
		return
	end

	local houseId = self:GetHouseIdByCollectibleId(collectibleId)
	if not houseId then
		return
	end

	local newName = GetCollectibleNickname(collectibleId)
	local currentName = self:GetOpenHouseName(houseId)

	if currentName and "" ~= currentName and newName and "" ~= newName and currentName ~= newName then
		local USE_EXISTING_CATEGORY = nil
		local USE_EXISTING_DESCRIPTION = nil
		local ENABLED = true
		local SUPPRESS_DIALOG = true
		self:ToggleOpenHouse(houseId, USE_EXISTING_CATEGORY, USE_EXISTING_DESCRIPTION, ENABLED, SUPPRESS_DIALOG)
		self:DisplayNotification(string.format("Updating Open House name to \"%s\"...", newName))
	end
end

function EHH:AppendSignatureToCommunityGuestbookRecord(world, owner, houseId)
	local key = string.lower(string.format("gb__%s__%s__%s", tostring(world), tostring(owner), tostring(houseId)))
	local record = EHT.Community.GetRawRemoteRecord(key)
	local signature = string.format("%s,%s;", self:GetCurrentSignerName(), tostring(GetTimeStamp()))

	if not record or "string" == type(record) then
		EHT.Community.SetRawRemoteRecord(key, signature .. (record or ""))
	end
end

function EHH:SetCommunitySignGuestbookRecord(signatures)
	if not signatures then
		return false
	end

	if not self:CheckCommunityConnection() then
		return nil
	end

	self:IncUMTD("n_js", 1)

	local key = string.format("sg__%s", self.DisplayNameLower)
	return EHT.Community.SetRecord(key, signatures)
end

function EHH:GetCommunitySignGuestbookRecord()
	if not self:CheckCommunityConnection() then
		return nil
	end

	local key = string.format("sg__%s", self.DisplayNameLower)
	local record = EHT.Community.GetRawLocalRecord(key)

	return record or ""
end

function EHH:GetCommunityGuestbookRecord(owner, houseId, world)
	if not self:IsCommunityDefined() then
		return nil
	end

	if not houseId then
		owner, houseId = self:GetOwner()
	end

	if "" == owner or 0 == houseId then
		return nil
	end

	if not world then
		world = self.World
	end

	local key = string.lower(string.format("gb__%s__%s__%s", tostring(world), tostring(owner), tostring(houseId)))
	local record = EHT.Community.GetRecord(key)

	if "string" == type(record) and 0 < #record then
		local signatures = { SplitString(";", record) }
		local signature

		for index = #signatures, 1, -1 do
			signature = { SplitString(",", signatures[index]) }

			if not signature or 2 > #signature then
				table.remove(signatures, index)
			else
				signature[2] = tonumber(signature[2])

				if not signature[2] then
					table.remove(signatures, index)
				else
					signatures[index] = signature
				end
			end
		end

		return signatures
	end

	return {}
end

function EHH:SignCommunityGuestbook()
	local owner, houseId = self:GetOwner()
	if not owner or "" == owner or not houseId or 0 == houseId then
		return false
	end

	owner = string.lower(owner)
	local signatures = self:GetCommunitySignGuestbookRecord()
	if not signatures then
		return false
	end

	local ts = GetTimeStamp()
	local world = self.World
	local signature = string.format("%s,%s,%s,%s,%s;", tostring(ts), world, tostring(owner), tostring(houseId), self:GetCurrentSignerName())
	signatures = signature .. signatures

	if 2048 < #signatures then
		local delimiter = 0
		while delimiter and delimiter < 2048 do
			delimiter = string.find(signatures, ";", delimiter + 1)
		end
		if delimiter then
			signatures = string.sub(signatures, 1, delimiter)
		end
	end

	local result = self:SetCommunitySignGuestbookRecord(signatures)
	if result then
		self:AppendSignatureToCommunityGuestbookRecord(world, owner, houseId)
	end

	return result
end

function EHH:GetGuestbook(owner, houseId, world)
	local signatures = self:GetCommunityGuestbookRecord(owner, houseId, world)

	if "table" == type(signatures) then
		table.sort(signatures, function(a, b) return ("table" == type(a) and "table" == type(b)) and a[2] < b[2] or false end)
	end

	return signatures
end

function EHH:HasSignedGuestbook()
	local signatures = self:GetGuestbook()

	if "table" == type(signatures) then
		local mySig = string.lower(string.format("(%s)", GetDisplayName()))

		for _, signature in pairs(signatures) do
			if string.find(string.lower(signature[1]), mySig) then
				return true
			end
		end
	end

	return false
end

function EHH:SetCommunityResetGuestbookRecord()
	if 0 == self:GetHouseId() or not self:IsOwner() then
		return false
	end

	if not self:CheckCommunityConnection() then
		return nil
	end

	local world = string.lower(self.World)
	local owner = self.DisplayNameLower
	local houseId = tostring(self:GetHouseId())
	local key = string.format("gr__%s__%s__%s", world, owner, houseId)
	local result, message = EHT.Community.SetRecord(key, { TS = GetTimeStamp() })

	if result then
		local key = string.lower(string.format("gb__%s__%s__%s", tostring(world), tostring(owner), tostring(houseId)))
		EHT.Community.SetRawRemoteRecord(key, "")
	end

	return result, message
end

function EHH:RequestResetGuestbook()
	if not self:IsOwner() then
		return false
	end

	local houseId = self:GetHouseId()

	if 0 == houseId then
		return false
	end

	local signatures = self:GetGuestbook()

	if "table" ~= type(signatures) or 0 >= #signatures then
		return false
	end

	return self:SetCommunityResetGuestbookRecord()
end

function EHH:SetComUMTD(data)
	if "string" ~= type(data) then
		return nil
	end

	local SUPPRESS_DIALOG = true
	if not self:CheckCommunityConnection(SUPPRESS_DIALOG) then
		return nil
	end

	local key = string.format("td__%s", self.DisplayNameLower)
	local SUPPRESS_POST_RELOAD_NOTIFICATION = true
	local result, message = EHT.Community.SetRecord(key, data, SUPPRESS_POST_RELOAD_NOTIFICATION)

	return result, message
end

function EHH:GetContestants(suppressDialog)
	if not self:CheckCommunityConnection(suppressDialog) then
		return nil
	end

	local key = string.format("cn__%s", string.lower(self.World))
	local rec = EHT.Community.GetRecord(key)
	local list = {}

	if "table" == type(rec) then
		for index, entry in pairs(rec) do
			if "table" == type(entry) and entry.HouseId and entry.Player then
				table.insert(list, { Player = string.lower(entry.Player), HouseId = tonumber(entry.HouseId), HouseName = tostring(entry.HouseName or "") })
			end
		end
	end

	return list
end

function EHH:GetContestant(player)
	local list = self:GetContestants(true)
	if not list then return nil, nil end

	player = string.lower(player)

	for index, entry in ipairs(list) do
		if player == entry.Player then
			return entry, index
		end
	end

	return nil, nil
end

function EHH:SetContestant(houseId)
	houseId = tonumber(houseId)

	if not self:CheckCommunityConnection() then
		return false
	end

	local ts = GetTimeStamp()
	local player = self.DisplayNameLower
	local world = string.lower(self.World)
	local houseName = houseId and GetCollectibleNickname(GetCollectibleIdForHouse(houseId)) or nil
	local key = string.format("cr__%s__%s", player, world or "")
	local rec = string.format("%s;%s;%s", tostring(ts or 0), tostring(houseId or 0), StripCharacter(houseName or ""))

	return EHT.Community.SetRecord(key, rec)
end

function EHH:SetContestantVote(player, houseId)
	player = tostring(player or "")
	houseId = tonumber(houseId)

	if not houseId or "" == player then
		return false
	end

	if not self:CheckCommunityConnection() then
		return false
	end

	local ts = GetTimeStamp()
	local world = string.lower(self.World)
	local key = string.format("cv__%s__%s", self.DisplayNameLower, world or "")
	local rec = string.format("%s;%s;%s", tostring(ts or 0), StripCharacter(player), tostring(houseId or 0))

	return EHT.Community.SetRecord(key, rec)
end

function EHH:GetLeaderboard(suppressDialog)
	if not self:CheckCommunityConnection(suppressDialog) then
		return nil
	end

	local key = string.format("cl__%s", string.lower(self.World))
	local rec = EHT.Community.GetRecord(key)
	local list = {}

	if "table" == type(rec) then
		for index, entry in ipairs(rec) do
			if "table" == type(entry) and entry.HouseId and entry.Player then
				table.insert(list, { Player = string.lower(entry.Player), HouseId = tonumber(entry.HouseId), HouseName = tostring(entry.HouseName or ""), Votes = tonumber(entry.Votes) })
			end
		end
	end

	return list
end

function EHH:EstimateCommunityFXRecordSize( houseId )
	if not self:IsCommunityDefined() or not EHT.Community or not EHT.Community.EstimateRecordSize then
		return 0
	end

	houseId = tonumber(houseId)
	if not houseId then
		return 0
	end

	local player = string.lower(self.DisplayNameLower)
	local world = string.lower(self.World)
	return tonumber(EHT.Community.EstimateRecordSize(string.format("fx__%s__%s__%d", world, player, houseId))) or 0
end

do
	local IsMetaDataLoaded = false
	local MetaData
	local MetaDataParsers = {}
	
	function EHH:IsCommunityMetaDataLoaded()
		return IsMetaDataLoaded
	end

	-- Streamer Meta Data Parser

	MetaDataParsers["sc__"] = function(self, key, rec)
		local data = self:GetCommunityStreamChannelRecordByKey(key)
		if data then
			local player = string.sub(key, 5)
			local channelName = tostring(data.ChannelName)
			local url = tostring(data.URL)
			if channelName and "" ~= channelName and url and "" ~= url then
				local description = tostring(data.Description or "")
				local schedule = tostring(data.Schedule or "")
				local lastLiveTS = tonumber(data.LastLiveTS or "")
				local lastEndTS = tonumber(data.LastEndTS or "")
				local channelData =
				{
					Player = player,
					ChannelName = channelName,
					Description = description,
					LastLiveTS = lastLiveTS,
					LastEndTS = lastEndTS,
					Schedule = schedule,
					URL = url,
				}

				local channels = MetaData.sc
				if not channels then
					channels = {}
					MetaData.sc = channels
				end
				table.insert(channels, channelData)
			end
		end

		return true
	end

	-- Open House Meta Data Parser

	MetaDataParsers["oh__"] = function(self, key, rec)
		local data = self:GetCommunityOpenHouseRecordByKey(key)
		if data then
			local player = string.sub(key, 5)
			for w, houses in pairs(data) do
				if self:IsValidWorldCode(w) and "table" == type(houses) then
					local worldList = MetaData["oh__" .. w]
					if not worldList then
						worldList =
						{
							Type = "oh",
							World = w,
							Houses = {}
						}
						MetaData["oh__" .. w] = worldList
					end

					local houseList = worldList.Houses
					for houseId, houseData in pairs(houses) do
						local guestbookKey = string.lower(string.format("gb__%s__%s__%s", w, player, houseId))
						local guestbookRecord = EHT.Community.GetRecord(guestbookKey)
						local numSignatures = 0
						if "string" == type(guestbookRecord) then
							numSignatures = self:GetStringOccurrenceCount(guestbookRecord, ";")
						end

						local houseMetaData =
						{
							player,
							houseId,
							houseData.N,
							houseData.O,
							houseData.C,
							houseData.D,
							numSignatures
						}
						table.insert(houseList, houseMetaData)
					end
				end
			end
		end

		return true
	end

	-- Deferred, long-running Community metadata parsing process

	function EHH:LoadAllCommunityMetaData()
		if IsMetaDataLoaded then
			return true
		end

		if not MetaData then
			MetaData = {}

			if not EHT or not EHT.Community or not EHT.Community.GetRecords then
				IsMetaDataLoaded = false
				return false
			end

			local records = EHT.Community.GetRecords()

			if "table" ~= type(records) then
				IsMetaDataLoaded = false
				return false
			end

			local key = nil
			local MAX_RECORDS_PER_FRAME = 100

			EVENT_MANAGER:RegisterForUpdate("EssentialHousingHub.LoadAllCommunityMetaData", 1, function()
				local numRecords = 0
				local rec

				repeat
					key, rec = next(records, key)
					if rec then
						local parserKey = key and string.sub(key, 1, 4)
						local parser = MetaDataParsers[parserKey]
						if parser then
							parser(self, key, rec)
						end
					else
						IsMetaDataLoaded = true
						EVENT_MANAGER:UnregisterForUpdate("EssentialHousingHub.LoadAllCommunityMetaData")
						zo_callLater(function() self:OnCommunityMetaDataLoaded() end, 1000)
					end
					numRecords = numRecords + 1
				until numRecords == MAX_RECORDS_PER_FRAME or not rec
			end)
		end
	end

	function EHH:GetAllCommunityMetaData()
		if IsMetaDataLoaded then
			return MetaData
		end
		return nil
	end
end

function EHH:GetCommunityMetaData(filters)
	local records = self:GetAllCommunityMetaData()
	if not records then
		return
	end

	local list = {}
	local t, w
	if filters then
		t = filters.Type
		w = filters.World
	end

	for key, rec in pairs(records) do
		if	(not t or t == rec.Type) and
			(not w or w == rec.World) then
			list[key] = rec
		end
	end

	return list
end

function EHH:GetCommunityMetaDataByKey(key)
	local records = self:GetAllCommunityMetaData()
	return records[key]
end

function EHH:FlushCommunityMetaDataCache()
	IsMetaDataLoaded = false
	self:LoadAllCommunityMetaData()
end

---[ DecoTrack ]---

function EHH:GetDecoTrackAPI()
	if DecoTrack and DecoTrack.Interop and DecoTrack.Interop.GetAPI then
		return DecoTrack.Interop.GetAPI() or 0
	else
		return 0
	end
end

function EHH:GetDecoTrackCountsByItemId(itemId)
	if 1 > self:GetDecoTrackAPI() then return nil end
	if not DecoTrack.Interop.GetCountsByItemId then return nil end
	return DecoTrack.Interop.GetCountsByItemId(itemId)
end

function EHH:SearchDecoTrack(searchText)
	if 2 > self:GetDecoTrackAPI() then return nil end
	if not DecoTrack.Interop.Search then return nil end
	return DecoTrack.Interop.Search(searchText)
end

function EHH:GetDecoTrackCountsByHouse()
	if 2 > self:GetDecoTrackAPI() then return nil end
	if not DecoTrack or not DecoTrack.Data or "table" ~= type(DecoTrack.Data.Houses) then return nil end

	local template = {}
	local containers = DecoTrack.Data.Houses
	local counts = {}

	for limitType = HOUSING_FURNISHING_LIMIT_TYPE_MIN_VALUE, HOUSING_FURNISHING_LIMIT_TYPE_MAX_VALUE do
		template[limitType] = 0
	end

	for _, container in pairs(DecoTrack.Data.Houses) do
		if container.HouseId then
			local house = self:CloneTable(template)
			counts[container.HouseId] = house

			for itemId, count in pairs(container.Items) do
				local limitType = self:GetFurnitureLimitTypeByItemId(itemId)

				if limitType then
					house[limitType] = house[limitType] + count
				end
			end
		end
	end

	return counts
end

function EHH:DoesDecoTrackSupportEnhancedSearch()
	return 3 <= self:GetDecoTrackAPI()
end

function EHH:DoesDecoTrackSupportBoundItems()
	return 4 <= self:GetDecoTrackAPI()
end

function EHH:DoesDecoTrackSupportCallbacks()
	return 5 <= self:GetDecoTrackAPI()
end

function EHH:HasRegisteredForDecoTrackCallbacks(key)
	return self.RegisteredDecoTrackCallbacks and self.RegisteredDecoTrackCallbacks[key]
end

function EHH:RegisterForDecoTrackCallbacks(key, callback)
	local registeredCallbacks = self.RegisteredDecoTrackCallbacks
	if not registeredCallbacks then
		registeredCallbacks = {}
		self.RegisteredDecoTrackCallbacks = registeredCallbacks
	end

	if registeredCallbacks[key] then
		return true
	end

	if self:DoesDecoTrackSupportCallbacks() and DecoTrack.Interop.CallbackManager then
		DecoTrack.Interop.CallbackManager:RegisterCallback("FullUpdate", callback)
		registeredCallbacks[key] = true
		return true
	end

	return false
end

function EHH:HasDecoTrackVisitedAllOwnedHomes()
	if 0 < self:GetDecoTrackAPI() and DecoTrack.Interop.HasVisitedAllOwnedHomes then
		return DecoTrack.Interop.HasVisitedAllOwnedHomes()
	end

	return true
end

function EHH:DecoTrackVisitAllHomes()
	if 0 < self:GetDecoTrackAPI() and DecoTrack.UpdateAllHouses then
		DecoTrack.UpdateAllHouses()
		return true
	end

	return false
end

---[ Tamriel Trade Centre ]---

function EHH:IsTradingPriceInfoAvailable()
	return TamrielTradeCentrePrice ~= nil and TamrielTradeCentrePrice.GetPriceInfo ~= nil
end

--[[
If no price data is available, returns:
	nil

If price data is available, returns:
{
	Avg
	Min
	Max
	EntryCount
	AmountCount
	SuggestedPrice
}
]]

function EHH:GetItemLinkTradingPriceInfo(itemLink)
	if not self:IsTradingPriceInfoAvailable() then
		return
	end

	local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
	if priceInfo then
		if priceInfo.SuggestedPrice then
			priceInfo.Resale = priceInfo.SuggestedPrice
		elseif priceInfo.Avg then
			priceInfo.Resale = priceInfo.Avg
		elseif priceInfo.Min and priceInfo.Max then
			priceInfo.Resale = 0.5 * (priceInfo.Min + priceInfo.Max)
		end
	end

	return priceInfo
end

function EHH_IsCommunityConnectionValid()
	local SUPPRESS_DIALOG = true
	return EssentialHousingHub:CheckCommunityConnection(SUPPRESS_DIALOG)
end

function EHH_GetCommunityConnectionInvalidTooltipMessage()
	return "Community App is not setup or Community Add-On is disabled"
end

---[ Module Registration ]---

EssentialHousingHub.Modules.Interop = true