if IsNewerEssentialHousingHubVersionAvailable() or not IsEssentialHousingHubRootPathValid() then
	return
end

local EHH = EssentialHousingHub
if not EHH then
	return
end

---[ Player Names ]---

function EHH:GetAllKnownPlayerNames()
	local allKnownPlayerNames = self.AllPlayerNames
	if not allKnownPlayerNames then
		allKnownPlayerNames = {}
		self.AllPlayerNames = allKnownPlayerNames

		do
			local list = self:GetHouses(self.World)
			for houseKey, house in pairs(list) do
				if house.Owner then
					local name = self:Trim(string.lower(house.Owner))
					allKnownPlayerNames[name] = true
				end
			end
		end

		do
			local list = self:GetRecentlyVisitedHouses()
			for index, house in ipairs(list) do
				if house.Owner then
					local name = self:Trim(string.lower(house.Owner))
					allKnownPlayerNames[name] = true
				end
			end
		end

		local numFriends = GetNumFriends()
		for friendIndex = 1, numFriends do
			local name = self:Trim(string.lower(GetFriendInfo(friendIndex)))
			if "" ~= name then
				allKnownPlayerNames[name] = true
			end
		end
	end

	return allKnownPlayerNames
end

function EHH:IsKnownPlayer(name)
	if name then
		name = self:Trim(string.lower(name))
		local allKnownPlayerNames = self:GetAllKnownPlayerNames()
		return allKnownPlayerNames[name] ~= nil
	end

	return false
end

function EHH:GetMatchingPlayerNames(partialName)
	if "string" ~= type(partialName) then
		return
	end

	partialName = self:Trim(string.lower(partialName))
	local nameLength = #partialName
	if nameLength < 2 then
		return
	end

	local matches = self:GetMatchingGuildMemberNames(partialName)
	local playerNames = self:GetAllKnownPlayerNames()
	for name in pairs(playerNames) do
		if string.sub(name, 1, nameLength) == partialName then
			matches[name] = true
		end
	end

	return matches
end

---[ Guilds ]---

function EHH:ClearGuildCache()
	self.GuildsCache = nil
	self.GuildMemberNamesCache = nil
	self.AllGuildMemberNamesCache = nil
end

function EHH:LoadGuildData(guildIndex)
	local guildId = GetGuildId(guildIndex)
	if guildId and 0 ~= guildId then
		local canEditNotes = DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_NOTE_EDIT)
		local canReadNotes = DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_NOTE_READ)
		local description = GetGuildDescription(guildId)
		local memberIndex = GetPlayerGuildMemberIndex(guildId)
		local motd = GetGuildMotD(guildId)
		local name = self:Trim(GetGuildName(guildId))
		local numMembers = GetNumGuildMembers(guildId)
		local _, note = GetGuildMemberInfo(guildId, memberIndex)

		if name and "" ~= name then
			local guildhallOwner, guildhallHouseId
			if description and "" ~= description then
				-- Attempt to parse a guildhall tag in the form of:
				-- Guildhall: [HouseName] @OwnerName
				local hallTagStartIndex, hallTagEndIndex = string.find(string.lower(description), "guildhall:", 1, true)
				if not hallTagEndIndex then
					hallTagStartIndex, hallTagEndIndex = string.find(string.lower(description), "guild hall:", 1, true)
				end

				if hallTagEndIndex then
					local houseNameStartIndex = hallTagEndIndex + 1
					local houseOwnerStartIndex = string.find(description, "@", houseNameStartIndex, true)
					if houseOwnerStartIndex then
						local descriptionLength = #description
						local houseOwnerEndIndex = houseOwnerStartIndex

						repeat
							houseOwnerEndIndex = houseOwnerEndIndex + 1
							local c = string.sub(description, houseOwnerEndIndex, houseOwnerEndIndex)
						until houseOwnerEndIndex >= descriptionLength or not c or "" == c or " " == c or "\n" == c

						if houseOwnerStartIndex < houseOwnerEndIndex then
							guildhallOwner = self:Trim(string.sub(description, houseOwnerStartIndex, houseOwnerEndIndex))
							if guildhallOwner ~= "" and houseNameStartIndex < (houseOwnerStartIndex - 2) then
								local houseName = self:Trim(string.sub(description, houseNameStartIndex, houseOwnerStartIndex - 1))
								if houseName ~= "" then
									local DO_NOT_USE_NICKNAMES = false
									local houses = self:FindHousesByName(houseName, DO_NOT_USE_NICKNAMES)
									if houses and houses[1] then
										guildhallHouseId = houses[1].Id
									end
								end
							end
						end
					end
				end
			end

			return {
				CanEditNotes = canEditNotes,
				CanReadNotes = canReadNotes,
				Description = description,
				GuildIndex = guildIndex,
				GuildhallOwner = guildhallOwner,
				GuildhallHouseId = guildhallHouseId,
				Id = guildId,
				MemberIndex = memberIndex,
				MotD = motd,
				Name = name,
				Note = note,
				NumMembers = numMembers,
			}
		end
	end
end

function EHH:GetGuilds()
	local list = self.GuildsCache
	if not list then
		list = {}
		self.GuildsCache = list

		for guildIndex = 1, GetNumGuilds() do
			list[guildIndex] = self:LoadGuildData(guildIndex)
		end
	else
		-- Always refresh local player's member index to avoid desync issues.
		for _, guild in pairs(list) do
			guild.MemberIndex = GetPlayerGuildMemberIndex(guild.Id)
		end
	end

	return list
end

function EHH:GetGuildByIndex(guildIndex)
	local guilds = self:GetGuilds()
	return guilds[guildIndex]
end

function EHH:GetGuildById(guildId)
	local guilds = self:GetGuilds()
	for _, guild in ipairs(guilds) do
		if guildId == guild.Id then
			return guild
		end
	end

	return nil
end

function EHH:GetGuildByName(name)
	name = self:Trim(string.lower(name))
	if not name or "" == name then
		return nil
	end

	local guilds = self:GetGuilds()
	for index, guild in pairs(guilds) do
		if string.lower(guild.Name) == name then
			return guild
		end
	end

	return nil
end

function EHH:FindGuildsByName(name)
	name = self:Trim(string.lower(name))
	if not name or "" == name then
		return nil
	end
	local nameLength = #name

	local guilds = self:GetGuilds()
	local matches = {}
	for index, guild in pairs(guilds) do
		if string.sub(string.lower(guild.Name), 1, nameLength) == name then
			table.insert(matches, guild)
		end
	end

	return matches
end

function EHH:GetLocalPlayerGuildMemberIndex(guildIndex)
	local guild = self:GetGuildByIndex(guildIndex)
	if not guild then
		return nil
	end

	return guild.MemberIndex
end

function EHH:GetGuildMemberNames(index)
	local list = self.GuildMemberNamesCache
	if not list then
		list = {}
		self.GuildMemberNamesCache = list

		for guildIndex = 1, GetNumGuilds() do
			local guildId = GetGuildId(guildIndex)
			if guildId and 0 ~= guildId then
				local guildList = {}
				list[guildIndex] = guildList

				local numMembers = GetNumGuildMembers(guildId)
				for memberIndex = 1, numMembers do
					local name = self:Trim(string.lower(GetGuildMemberInfo(guildId, memberIndex) or ""))
					if name ~= "" then
						table.insert(guildList, name)
					end
				end
			end
		end
	end

	return list[index]
end

function EHH:GetAllGuildMemberNames()
	local list = self.AllGuildMemberNamesCache
	if not list then
		list = {}
		self.AllGuildMemberNamesCache = list

		for guildIndex = 1, GetNumGuilds() do
			local guildList = self:GetGuildMemberNames(guildIndex)
			if guildList then
				for _, name in pairs(guildList) do
					list[name] = true
				end
			end
		end
	end

	return list
end

function EHH:GetMatchingGuildMemberNames(partialName)
	local matches = {}
	if "string" ~= type(partialName) then
		return matches
	end

	partialName = self:Trim(string.lower(partialName))
	local nameLength = #partialName
	if nameLength < 2 then
		return matches
	end

	local names = self:GetAllGuildMemberNames()
	for name in pairs(names) do
		if string.sub(name, 1, nameLength) == partialName then
			matches[name] = true
		end
	end

	return matches
end

function EHH:GetGuildHeraldry(guildId)
	local bkgCategoryIndex, bkgStyleIndex, bkgColor1, bkgColor2, crestCategoryIndex, crestStyleIndex, crestColor = GetGuildHeraldryAttribute(guildId)
	return bkgCategoryIndex, bkgStyleIndex, bkgColor1, bkgColor2, crestCategoryIndex, crestStyleIndex, crestColor
end

function EHH:GetHeraldryTextures(bkgCategoryIndex, bkgStyleIndex, bkgColor1, bkgColor2, crestCategoryIndex, crestStyleIndex, crestColor)
	local bkgCategoryTexture = GetHeraldryGuildFinderBackgroundCategoryIcon(bkgCategoryIndex)
	local bkgStyleTexture = GetHeraldryGuildFinderBackgroundStyleIcon(bkgCategoryIndex, bkgStyleIndex)
	local crestTexture = GetHeraldryGuildFinderCrestStyleIcon(crestCategoryIndex, crestStyleIndex)

	local _, dyeCategory, bkgColor1R, bkgColor1G, bkgColor1B, colorSortKey = GetHeraldryColorInfo(bkgColor1)
	local _, dyeCategory, bkgColor2R, bkgColor2G, bkgColor2B, colorSortKey = GetHeraldryColorInfo(bkgColor2)
	local _, dyeCategory, crestColorR, crestColorG, crestColorB, colorSortKey = GetHeraldryColorInfo(crestColor)

	local textures = {}
	table.insert(textures, { TextureFile = bkgCategoryTexture, ScaleX = 1, ScaleY = 1, Color = { R = bkgColor1R, G = bkgColor1G, B = bkgColor1B }, SampleRGB = 1, SampleAlpha = 0 })
	table.insert(textures, { TextureFile = bkgStyleTexture, ScaleX = 0.99, ScaleY = 0.99, Color = { R = bkgColor2R, G = bkgColor2G, B = bkgColor2B }, SampleRGB = 1, SampleAlpha = 0.25, Add = true, })
	table.insert(textures, { TextureFile = crestTexture, ScaleX = 1, ScaleY = 1, Color = { R = crestColorR, G = crestColorG, B = crestColorB }, SampleRGB = 1, SampleAlpha = 0.25 })

	return textures
end

---[ Module Registration ]---

EssentialHousingHub.Modules.Social = true