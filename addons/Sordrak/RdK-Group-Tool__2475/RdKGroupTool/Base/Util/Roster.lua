-- RdK Group Tool Roster
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.util = RdKGTool.util or {}
RdKGTool.util.roster = RdKGTool.util.roster or {}

local RdKGToolRoster = RdKGTool.util.roster

RdKGToolRoster.callbackName = RdKGTool.addonName .. "Util.Roster"
RdKGToolRoster.friends = {}
RdKGToolRoster.guilds = {}
RdKGToolRoster.guilds[1] = {}
RdKGToolRoster.guilds[1].all = {}
RdKGToolRoster.guilds[1].at = {}
RdKGToolRoster.guilds[1].name = ""
RdKGToolRoster.guilds[1].id = 0
RdKGToolRoster.guilds[2] = {}
RdKGToolRoster.guilds[2].all = {}
RdKGToolRoster.guilds[2].at = {}
RdKGToolRoster.guilds[2].name = ""
RdKGToolRoster.guilds[2].id = 0
RdKGToolRoster.guilds[3] = {}
RdKGToolRoster.guilds[3].all = {}
RdKGToolRoster.guilds[3].at = {}
RdKGToolRoster.guilds[3].name = ""
RdKGToolRoster.guilds[3].id = 0
RdKGToolRoster.guilds[4] = {}
RdKGToolRoster.guilds[4].all = {}
RdKGToolRoster.guilds[4].at = {}
RdKGToolRoster.guilds[4].name = ""
RdKGToolRoster.guilds[4].id = 0
RdKGToolRoster.guilds[5] = {}
RdKGToolRoster.guilds[5].all = {}
RdKGToolRoster.guilds[5].at = {}
RdKGToolRoster.guilds[5].name = ""
RdKGToolRoster.guilds[5].id = 0

RdKGToolRoster.state = {}
RdKGToolRoster.state.guildListConsumers = {}

RdKGToolRoster.constants = {}
RdKGToolRoster.constants.RDK = "Retter des Kaiserreiches"
RdKGToolRoster.constants.adminRanks = {}
RdKGToolRoster.constants.adminRanks[1] = 1
RdKGToolRoster.constants.adminRanks[2] = 2
RdKGToolRoster.constants.adminRanks[3] = 3


--[[
	Current Known Bugs:
	- If the game fucks up, the API doesn't come up with any guilds, players etc. This means that under certain circumstances this functionality doesn't work
	- If anything changes on the roster during a loading screen, it won't be noticed. EVENT_PLAYER_ACTIVATED should be used to completely rebuild the roster. Yet for performance reason this hasn't been implemented.
]]

function RdKGToolRoster.Initialize()
	--create list
	
	for guildId = 1, GetNumGuilds() do
		RdKGToolRoster.guilds[guildId].name = GetGuildName(RdKGToolRoster.GetGuildIdFromId(guildId))
        for memberId = 1, GetNumGuildMembers(RdKGToolRoster.GetGuildIdFromId(guildId)) do
            local hasCharacter, charName, zoneName, classType, alliance, level, championRank, zoneId = GetGuildMemberCharacterInfo(RdKGToolRoster.GetGuildIdFromId(guildId), memberId)
            local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(RdKGToolRoster.GetGuildIdFromId(guildId), memberId)

			charName = zo_strformat("<<!aC:1>>", charName)
			local character = {}
			character.displayName = name
			character.name = charName
			character.rankIndex = rankIndex
			local charNameIndex = string.sub(charName, 1, 1)
			local displayNameIndex = string.sub(name, 2, 2)

			RdKGToolRoster.guilds[guildId][charNameIndex] = RdKGToolRoster.guilds[guildId][charNameIndex] or {}
			RdKGToolRoster.guilds[guildId].at[displayNameIndex] = RdKGToolRoster.guilds[guildId].at[displayNameIndex] or {}
			RdKGToolRoster.guilds[guildId].id = GetGuildId(guildId)
			
			table.insert(RdKGToolRoster.guilds[guildId].all, character)
			table.insert(RdKGToolRoster.guilds[guildId].at[displayNameIndex], character)
			table.insert(RdKGToolRoster.guilds[guildId][charNameIndex], character)
			
		end
	end
	
	for friendIndex = 1, GetNumFriends() do
        local displayName, note, playerStatus, secsSinceLogoff = GetFriendInfo(friendIndex)
		local hasCharacter, characterName, zoneName, classType, alliance, level, championRank, zoneId = GetFriendCharacterInfo(friendIndex)
		characterName = zo_strformat("<<!aC:1>>", characterName)
		
		local character = {}
		character.displayName = displayName
		character.name = characterName
		
		table.insert(RdKGToolRoster.friends, character)
    end
	
	
	EVENT_MANAGER:RegisterForEvent(RdKGToolRoster.callbackName, EVENT_FRIEND_ADDED, RdKGToolRoster.OnFriendAdded)
	EVENT_MANAGER:RegisterForEvent(RdKGToolRoster.callbackName, EVENT_FRIEND_REMOVED, RdKGToolRoster.OnFriendRemoved)
	EVENT_MANAGER:RegisterForEvent(RdKGToolRoster.callbackName, EVENT_GUILD_MEMBER_ADDED, RdKGToolRoster.OnGuildMemberAdded)
	EVENT_MANAGER:RegisterForEvent(RdKGToolRoster.callbackName, EVENT_GUILD_MEMBER_REMOVED, RdKGToolRoster.OnGuildMemberRemoved)
	EVENT_MANAGER:RegisterForEvent(RdKGToolRoster.callbackName, EVENT_GUILD_MEMBER_RANK_CHANGED, RdKGToolRoster.OnGuildMemberRankChanged)
	
	EVENT_MANAGER:RegisterForEvent(RdKGToolRoster.callbackName, EVENT_GUILD_SELF_JOINED_GUILD, RdKGToolRoster.OnGuildJoined)
	EVENT_MANAGER:RegisterForEvent(RdKGToolRoster.callbackName, EVENT_GUILD_SELF_LEFT_GUILD, RdKGToolRoster.OnGuildLeft)
end

--functions
function RdKGToolRoster.GetGuildIdFromId(id)
--Elsweyr Changes
	if GetGuildId ~= nil then
		return GetGuildId(id)
	else
		return id
	end
end

function RdKGToolRoster.GetGuidIdFromEventGuidId(id)
	if GetGuildId ~= nil then
		for guildId = 1, GetNumGuilds() do
			if id == GetGuildId(guildId) then
				id = guildId
				break
			end
		end
	end
	return id
end

function RdKGToolRoster.IsFriendByCharName(name)
	local nameExists = false
	if name ~= nil then
		for i = 1, #RdKGToolRoster.friends do
			if RdKGToolRoster.friends[i].name == name then
				nameExists = true
				break
			end	
		end
	end
	return nameExists
end

function RdKGToolRoster.IsFriendByAccountName(name)
	local nameExists = false
	if name ~= nil then
		for i = 1, #RdKGToolRoster.friends do
			if RdKGToolRoster.friends[i].displayName == name then
				nameExists = true
				break
			end	
		end
	end
	return nameExists
end

function RdKGToolRoster.IsFriend(name)
	local nameExists = false
	if name ~= nil then
		for i = 1, #RdKGToolRoster.friends do
			if RdKGToolRoster.friends[i].displayName == name or RdKGToolRoster.friends[i].name == name then
				nameExists = true
				break
			end	
		end
	end
	return nameExists
end

function RdKGToolRoster.IsGuildMemberByCharName(name, guildAllowed)
	local nameExists = false
	if name ~= nil and string.len(name) > 2 then
		local index = string.sub(name, 1, 1)
		for guildId = 1, #RdKGToolRoster.guilds do
			local guildDictionary = RdKGToolRoster.guilds[guildId][index]
			if guildAllowed == nil or (guildAllowed ~= nil and guildAllowed[guildId] ~= nil and guildAllowed[guildId] == true) then
				if guildDictionary ~= nil then
					for i = 1, #guildDictionary do
						if guildDictionary[i].name == name then
							nameExists = true
							break
						end
					end
				end
			end
		end
	end
	return nameExists
end

function RdKGToolRoster.IsGuildMemberByAccountName(name, guildAllowed)
	local nameExists = false
	if name ~= nil and string.len(name) > 2 then
		local index = string.sub(name, 2, 2)
		for guildId = 1, #RdKGToolRoster.guilds do
			local guildDictionary = RdKGToolRoster.guilds[guildId].at[index]
			if guildAllowed == nil or (guildAllowed ~= nil and guildAllowed[guildId] ~= nil and guildAllowed[guildId] == true) then
				if guildDictionary ~= nil then
					for i = 1, #guildDictionary do
						if guildDictionary[i].displayName == name then
							nameExists = true
							break
						end
					end
				end
			end
		end
	end
	return nameExists
end

function RdKGToolRoster.IsGuildMember(name)
	local nameExists = false
	if name ~= nil and string.len(name) > 2 then
		local accIndex = string.sub(name, 2, 2)
		local charIndex = string.sub(name, 1, 1)
		for guildId = 1, #RdKGToolRoster.guilds do
			local guildDictionary = RdKGToolRoster.guilds[guildId][charIndex]
			if guildDictionary ~= nil then
				for i = 1, #guildDictionary do
					if guildDictionary[i].name == name then
						nameExists = true
						break
					end
				end
			end
			guildDictionary = RdKGToolRoster.guilds[guildId].at[accIndex]
			if guildDictionary ~= nil then
				for i = 1, #guildDictionary do
					if guildDictionary[i].displayName == name then
						nameExists = true
						break
					end
				end
			end
		end
	end
	return nameExists
end

function RdKGToolRoster.GetGuildIdForName(name)
	local retVal = nil
	if name ~= nil then
		for i = 1, #RdKGToolRoster.guilds do
			if RdKGToolRoster.guilds[i].name == name then
				retVal = i
				break
			end
		end
	end
	return retVal
end

function RdKGToolRoster.IsRdKMember(displayName)
	local isMember = false
	for guildId = 1, #RdKGToolRoster.guilds do
		if RdKGToolRoster.guilds[guildId].name == RdKGToolRoster.constants.RDK then
			local guild = RdKGToolRoster.guilds[guildId]
			local guildDictionary = guild.at[string.sub(displayName, 2, 2)]
			if guildDictionary ~= nil then
				for j = 1, #guildDictionary do
					if guildDictionary[j].displayName == displayName then
						isMember = true
						break
					end
				end
				break
			end
		end
	end
	return isMember
end

function RdKGToolRoster.IsGuildOfficerOf(targetName, officerName)
	local isOfficer = false
	if targetName ~= nil and officerName ~= nil then
		for guildId = 1, #RdKGToolRoster.guilds do
			
			local guild = RdKGToolRoster.guilds[guildId]
			local targetGuildDictionary = guild.at[string.sub(targetName, 2, 2)]
			local officerGuildDictionary = guild.at[string.sub(officerName, 2, 2)]
			local isInGuild = false
			local isGuidOfficer = false
			if targetGuildDictionary ~= nil and officerGuildDictionary ~= nil then
				for j = 1, #targetGuildDictionary do
					if targetGuildDictionary[j].displayName == targetName then
						isInGuild = true
						break
					end
				end
				for j = 1, #officerGuildDictionary do
					if officerGuildDictionary[j].displayName == officerName then
						for k = 1, #RdKGToolRoster.constants.adminRanks do
							if RdKGToolRoster.constants.adminRanks[k] == officerGuildDictionary[j].rankIndex then
								isGuidOfficer = true
								break
							end
						end
					end
				end
				if isGuidOfficer == true and isInGuild == true then
					isOfficer = true
					break
				end
			end
		end
	end
	return isOfficer
end

function RdKGToolRoster.IsGuildOfficer(displayName)
	local isOfficer = false
	if displayName ~= nil then
		for guildId = 1, #RdKGToolRoster.guilds do
			--d("index: " .. guildId)
			local guild = RdKGToolRoster.guilds[guildId]
			local guildDictionary = guild.at[string.sub(displayName, 2, 2)]
			if guildDictionary ~= nil then
				for j = 1, #guildDictionary do
					if guildDictionary[j].displayName == displayName then
						--d("member exists")
						for k = 1, #RdKGToolRoster.constants.adminRanks do
							if RdKGToolRoster.constants.adminRanks[k] == guildDictionary[j].rankIndex then
								isOfficer = true
								break
							end
						end
						break
					end
				end
				if isOfficer == true then
					break
				end
			end
		end
	end
	return isOfficer
end

function RdKGToolRoster.IsRdKAdmin(displayName)
	local isAdmin = false
	if displayName ~= nil then
		for guildId = 1, #RdKGToolRoster.guilds do
			if RdKGToolRoster.guilds[guildId].name == RdKGToolRoster.constants.RDK then
				local guild = RdKGToolRoster.guilds[guildId]
				local guildDictionary = guild.at[string.sub(displayName, 2, 2)]
				if guildDictionary ~= nil then

					for j = 1, #guildDictionary do
						if guildDictionary[j].displayName == displayName then
							for k = 1, #RdKGToolRoster.constants.adminRanks do
								if RdKGToolRoster.constants.adminRanks[k] == guildDictionary[j].rankIndex then
									isAdmin = true
									break
								end
							end
							break
						end
					end
					break
				end
			end
		end
	end
	return isAdmin
end


--consumers / listeners
function RdKGToolRoster.GuildListConsumerExists(name)
	local exists = false
	if name ~= nil then
		for i = 1, #RdKGToolRoster.state.guildListConsumers do
			if RdKGToolRoster.state.guildListConsumers[i].name == name then
				exists = true
				break
			end
		end
	end
	return exists
end

function RdKGToolRoster.AddGuildListConsumer(name, callback)
	if name ~= nil and callback ~= nil then
		if RdKGToolRoster.GuildListConsumerExists(name) == false then
			local entry = {}
			entry.name = name
			entry.callback = callback
			table.insert(RdKGToolRoster.state.guildListConsumers, entry)
		end
	end
end

function RdKGToolRoster.RemoveGuildListConsumer(name)
	if name ~= nil then
		for i = 1, #RdKGToolRoster.state.guildListConsumers do
			if RdKGToolRoster.state.guildListConsumers[i].name == name then
				table.remove(RdKGToolRoster.state.guildListConsumers, i)
				break
			end
		end
	end
end

function RdKGToolRoster.GuildListChanged()
	for i = 1, #RdKGToolRoster.state.guildListConsumers do
		if type(RdKGToolRoster.state.guildListConsumers[i].callback) == "function" then
			RdKGToolRoster.state.guildListConsumers[i].callback()
		end
	end
end

function RdKGToolRoster.GetGuildIndex(guildId)
	local guildIndex = nil
	for i = 1, 5 do
		if guildId == RdKGToolRoster.guilds[i].id then
			guildIndex = i
			break
		end
	end
	return guildIndex
end

--callbacks
function RdKGToolRoster.OnFriendAdded(eventCode, name)
	if eventCode == EVENT_FRIEND_ADDED then
		for friendIndex = 1, GetNumFriends() do
			local displayName, note, playerStatus, secsSinceLogoff = GetFriendInfo(friendIndex)
			local hasCharacter, characterName, zoneName, classType, alliance, level, championRank, zoneId = GetFriendCharacterInfo(friendIndex)
			if name == displayName then
				characterName = zo_strformat("<<!aC:1>>", characterName)
				local character = {}
				character.displayName = displayName
				character.name = characterName
				
				table.insert(RdKGToolRoster.friends, character)
				break
			end
		end
	end
end

function RdKGToolRoster.OnFriendRemoved(eventCode, displayName)
	if eventCode == EVENT_FRIEND_REMOVED then
		for i = 1, #RdKGToolRoster.friends do
			if RdKGToolRoster.friends[i].displayName == displayName then
				table.remove(RdKGToolRoster.friends, i)
				break
			end
		end
	end
end

function RdKGToolRoster.OnGuildMemberAdded(eventCode, guildId, displayName)
	if eventCode == EVENT_GUILD_MEMBER_ADDED and guildId ~= nil then
		guildId = RdKGToolRoster.GetGuildIndex(guildId)
		for memberId = 1, GetNumGuildMembers(RdKGToolRoster.GetGuildIdFromId(guildId)) do
			
			local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(RdKGToolRoster.GetGuildIdFromId(guildId), memberId)
			if name == displayName then
				local hasCharacter, charName, zoneName, classType, alliance, level, championRank, zoneId = GetGuildMemberCharacterInfo(RdKGToolRoster.GetGuildIdFromId(guildId), memberId)
				charName = zo_strformat("<<!aC:1>>", charName)

				local character = {}
				character.displayName = name
				character.name = charName

				local charNameIndex = string.sub(charName, 1, 1)
				local displayNameIndex = string.sub(name, 2, 2)
				RdKGToolRoster.guilds[guildId][charNameIndex] = RdKGToolRoster.guilds[guildId][charNameIndex] or {}
				RdKGToolRoster.guilds[guildId].at[displayNameIndex] = RdKGToolRoster.guilds[guildId].at[displayNameIndex] or {}
			
				table.insert(RdKGToolRoster.guilds[guildId].all, character)
				table.insert(RdKGToolRoster.guilds[guildId].at[displayNameIndex], character)
				table.insert(RdKGToolRoster.guilds[guildId][charNameIndex], character)
				break
			end
		end
	end
end

function RdKGToolRoster.OnGuildMemberRemoved(eventCode, guildId, displayName, characterName)
	if eventCode == EVENT_GUILD_MEMBER_REMOVED and guildId ~= nil then
		guildId = RdKGToolRoster.GetGuildIndex(guildId)
		local charName = ""
		local accIndex = string.sub(displayName, 2, 2)
		
		for i = 1, #RdKGToolRoster.guilds[guildId].all do
			if RdKGToolRoster.guilds[guildId].all[i].displayName == displayName then
				charName = RdKGToolRoster.guilds[guildId].all[i].name
				table.remove(RdKGToolRoster.guilds[guildId].all, i)
				break
			end
		end
		
		local accDictionary = RdKGToolRoster.guilds[guildId].at[accIndex]
		if accDictionary ~= nil then
			for i = 1, #accDictionary do
				if accDictionary[i].displayName == displayName then
					table.remove(accDictionary, i)
					break
				end
			end
		end
		
		if charName == "" then
			--debug
		else
			local charIndex = string.sub(charName, 1, 1)
			local charDictionary = RdKGToolRoster.guilds[guildId][charIndex]
			if charDictionary ~= nil then
				for i = 1, #charDictionary do
					if charDictionary[i].name == charName then
						table.remove(charDictionary, i)
						break
					end
				end
			end
		end
	end
end

function RdKGToolRoster.OnGuildMemberRankChanged(eventCode, guildId, displayName, rankIndex)
	if eventCode == EVENT_GUILD_MEMBER_RANK_CHANGED then
		guildId = RdKGToolRoster.GetGuildIndex(guildId)
		local guild = RdKGToolRoster.guilds[guildId]
		local accIndex = string.sub(displayName, 2, 2)
		local accDictionary = guild.at[accIndex]
		if accDictionary ~= nil then
			for i = 1, #accDictionary do
				if accDictionary[i].displayName == displayName then
					accDictionary[i].rankIndex = rankIndex
					break
				end
			end
		end
	end
end

function RdKGToolRoster.OnGuildJoined(eventCode, guildId, guildName)
	--d("id: " .. guildId)
	--d("Num: " .. GetNumGuilds())
	if eventCode == EVENT_GUILD_SELF_JOINED_GUILD then
		--guildId = RdKGToolRoster.GetGuidIdFromEventGuidId(guildId)
		local guildIndex = GetNumGuilds()
		if guildIndex ~= nil then
			RdKGToolRoster.guilds[guildIndex].name = GetGuildName(guildId)
			for memberId = 1, GetNumGuildMembers(guildId) do
				local hasCharacter, charName, zoneName, classType, alliance, level, championRank, zoneId = GetGuildMemberCharacterInfo(guildId, memberId)
				local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, memberId)

				charName = zo_strformat("<<!aC:1>>", charName)
				local character = {}
				character.displayName = name
				character.name = charName
				local charNameIndex = string.sub(charName, 1, 1)
				local displayNameIndex = string.sub(name, 2, 2)

				RdKGToolRoster.guilds[guildIndex][charNameIndex] = RdKGToolRoster.guilds[guildIndex][charNameIndex] or {}
				RdKGToolRoster.guilds[guildIndex].at[displayNameIndex] = RdKGToolRoster.guilds[guildIndex].at[displayNameIndex] or {}
				RdKGToolRoster.guilds[guildIndex].id = GetGuildId(guildIndex)
				
				table.insert(RdKGToolRoster.guilds[guildIndex].all, character)
				table.insert(RdKGToolRoster.guilds[guildIndex].at[displayNameIndex], character)
				table.insert(RdKGToolRoster.guilds[guildIndex][charNameIndex], character)
				
			end
			RdKGToolRoster.GuildListChanged()
		end
	end
end

function RdKGToolRoster.OnGuildLeft(eventCode, guildId, guildName)
	--d(guildId)
	if eventCode == EVENT_GUILD_SELF_LEFT_GUILD then
		guildId = RdKGToolRoster.GetGuildIndex(guildId)
		--if guildId > 5 then
		--	guildId = RdKGToolRoster.GetGuildIndex(guildId)
		--end
		if guildId ~= nil and guildId >= 1 and guildId <= 5 then
			table.remove(RdKGToolRoster.guilds, guildId)
			RdKGToolRoster.guilds[5] = {}
			RdKGToolRoster.guilds[5].all = {}
			RdKGToolRoster.guilds[5].at = {}
			RdKGToolRoster.guilds[5].name = ""
		end
		RdKGToolRoster.GuildListChanged()
	end
end