
function AdvancedGroupRoster.OnGroupPlayerOffline(eventCode, unitTag, isOnline)
	local unitName = GetUnitName(unitTag):gsub("%^.+", "")

	if isOnline then
        AdvancedGroupRoster.kickTable[unitName] = nil
    else
        AdvancedGroupRoster.kickTable[unitName] = GetTimeStamp()
    end
end

function AdvancedGroupRoster.onUpdate()
	AdvancedGroupRoster.kickCheck()

	--[[local groupSize = GetGroupSize()

	if groupSize > 0 and AdvancedGroupRoster.inGroup == false then
		AdvancedGroupRoster.inGroup = true

		local players_dropdown = WINDOW_MANAGER:GetControlByName("AGRGroupList")
		players_dropdown:UpdateChoices(AdvancedGroupRoster.getGroupMembers())
	elseif groupSize <= 0 and AdvancedGroupRoster.inGroup == true then
		AdvancedGroupRoster.inGroup = false

		local players_dropdown = WINDOW_MANAGER:GetControlByName("AGRGroupList")
		players_dropdown:UpdateChoices(AdvancedGroupRoster.getGroupMembers())
	end]]
end

function AdvancedGroupRoster.kickByName(name)
	if name == '' then
		return
	end

    AdvancedGroupRoster.kickTable[name] = nil

	local tag = AdvancedGroupRoster.findGroupUnitTag(name)

	if tag == nil then
		d("ERROR: Failed to kick player: "..name)
		return
	end

	d("Kicked "..GetUnitName(tag).." ("..GetUnitDisplayName(tag)..") from group")
	GroupKick(tag)
end

function AdvancedGroupRoster.kickCheck()
	if AdvancedGroupRoster.SV.groupInviteEnabled == false or AdvancedGroupRoster.SV.groupInviteAutoKick == 0 or GetGroupSize() == 0 or IsUnitGroupLeader('player') == false then
		return
	end

    local now = GetTimeStamp()

    for p, t in pairs(AdvancedGroupRoster.kickTable) do
        local offTime = GetDiffBetweenTimeStamps(now, t)

        if offTime > AdvancedGroupRoster.SV.groupInviteAutoKick then
            AdvancedGroupRoster.kickByName(p)
        end
    end
end

function AdvancedGroupRoster.getRole(characterName)
	local searchCharacterName = string.gsub(characterName, "-", "")
	local searchName = ''

	for j=1, 7 do
		for index, name in pairs(AdvancedGroupRoster.SV.rolePlayers[j]) do
			searchName = string.gsub(name, "-", "")

			if string.find(searchName, searchCharacterName) then
				local pieces = AdvancedGroupRoster.string_split(name)
				return AdvancedGroupRoster.SV.roleNames[j] .. " ("..pieces[#pieces]..")"
			end
		end
	end

	if AdvancedGroupRoster.SV.nonRoledDPS == true then
		return AdvancedGroupRoster.SV.roleNames[3]
	end

	return 'None'
end

function AdvancedGroupRoster.getName(pieces)
	local name = ''

	for i=1, #pieces do
		if i == #pieces then
			break
		end

		name = name .. pieces[i] .. ' '
	end

	return AdvancedGroupRoster.trim(name)
end

function AdvancedGroupRoster.checkRaidManagementInvite(characterName)
	if AdvancedGroupRoster.startsWith(characterName, '@') == true then
		characterName = AdvancedGroupRoster.findCharacterName(characterName)

		if AdvancedGroupRoster.startsWith(characterName, '@') == true then
			return "ERROR: User ID was passed in as character name and was unable to be located."
		end
	end

	-- check for guild rank or higher
	for guildId, rank in pairs(AdvancedGroupRoster.SV.guildRank) do
		if rank ~= 'Do Not Use' then
			local useRankIndex = 0

			for rankIndex=1, GetNumGuildRanks(guildId) do
				if GetGuildRankCustomName(guildId, rankIndex) == rank then
					useRankIndex = rankIndex
					break
				end
			end

			if useRankIndex ~= 0 then
				local useMemberIndex = 0

				for memberIndex=1, GetNumGuildMembers(guildId) do
					local _, getCharacterName, _, _, _, _, _, _ = GetGuildMemberCharacterInfo(guildId, memberIndex)
					getCharacterName = zo_strformat("<<1>>", getCharacterName)

					if getCharacterName == characterName then
						useMemberIndex = memberIndex
						break
					end
				end

				if useMemberIndex ~= 0 then
					local _, _, foundRankIndex, _, _ = GetGuildMemberInfo(guildId, useMemberIndex)

					if useRankIndex < foundRankIndex then
						return 'Player was found to have a lesser rank then needed to join raid.'
					end
				end
			end
		end
	end

	if AdvancedGroupRoster.SV.raidManagementEnable == false then
		--d("Raid Management is turned off, so returning true")
		return 'true'
	end

	if AdvancedGroupRoster.SV.groupSizeRaidManage > 0 and GetGroupSize() < AdvancedGroupRoster.SV.groupSizeRaidManage then
		--d("Group Size is less then the group size for raid management to start, so returning true")
		return 'true'
	end

	local playersType = 0
	local playersAmount = 0

	local searchCharacterName = string.gsub(characterName, "-", "")
	local searchName = ''

	for j=1, 7 do
		for index, name in pairs(AdvancedGroupRoster.SV.rolePlayers[j]) do
			searchName = string.gsub(name, "-", "")

			if string.find(searchName, searchCharacterName) then
				playersType = j
				playersAmount = name
				break
			end
		end
	end

	if playersType == 0 then
		if AdvancedGroupRoster.SV.nonRoledDPS == true then
			playersType = 3
			playersAmount = characterName
		elseif AdvancedGroupRoster.SV.groupInviteNonRoled == true then
			--d("Player type not found and non roled as dps is turned on, so returning true")
			return 'true'
		else
			return "ERROR: Did not invite '"..characterName.."' because they are not roled."
		end
	end

	--Have to find all players in group that are of this players type; if less then wanted, just invite, but if more, have to figure out who to kick
	local playersInType = {}
	local atLeastOne = 0
	local searchGroupName = nil

	for i=1, GetGroupSize() do
		for index, name in pairs(AdvancedGroupRoster.SV.rolePlayers[playersType]) do
			searchName = string.gsub(name, "-", "")
			searchGroupName = GetUnitName(GetGroupUnitTagByIndex(i))
			searchGroupName = string.gsub(searchGroupName, "-", "")

			if string.find(searchName, searchGroupName) then
				table.insert(playersInType, name)
				atLeastOne = atLeastOne + 1
			end
		end
	end

	if atLeastOne < AdvancedGroupRoster.SV.roleAmount[playersType] then
		--d("There is not enough of that role type in group, so returning true ("..playersType..")")
		return 'true'
	end

	if AdvancedGroupRoster.SV.useRankingAutoKick == false then
		return "ERROR: Did not invite '"..characterName.."' because you already have enough of their role."
	end

	-- go through and figure out who has the highest score and kick; if more all have same, kick randomly
	if AdvancedGroupRoster.SV.nonRoledDPS == true and playersType == 3 then
		return "ERROR: Did not invite '"..characterName.."' DPS are not ranked."
	end

	local pieces = AdvancedGroupRoster.string_split(playersAmount)
	playersAmount = pieces[#pieces]

	local name = ''
	local playerToKickName = nil
	local highestNumber = playersAmount

	for _, fullName in pairs(playersInType) do
		pieces = AdvancedGroupRoster.string_split(fullName)
		name = AdvancedGroupRoster.getName(pieces)
		number = pieces[#pieces]

		if name ~= AdvancedGroupRoster.SV.playerName and highestNumber < number then
			playerToKickName = name
			highestNumber = number
		end
	end

	--[[if playerToKickName == nil then
		for _, fullName in pairs(playersInType) do
			pieces = AdvancedGroupRoster.string_split(fullName)
			name = pieces[1]
			number = pieces[2]

			if name ~= AdvancedGroupRoster.SV.playerName and playersAmount == number then
				playerToKickName = name
				break
			end
		end
	end]]

	if playerToKickName ~= nil then
		--d("Trying to kick player '"..playerToKickName.."' and returning true")
		AdvancedGroupRoster.kickByName(playerToKickName)
		return 'true'
	else
		return "ERROR: Did not invite '"..characterName.."' because you already have enough of their role and none could be found to auto-kick."
	end

	--d("Reached the end and returned false")
	
	return 'false'
end

function AdvancedGroupRoster.checkRaidManagementKick()
	--check if auto-kick not roled is on
	if AdvancedGroupRoster.SV.groupInviteKickNonRoled == false or AdvancedGroupRoster.SV.raidManagementEnable == false then
		return
	end

	if AdvancedGroupRoster.SV.combatControlsKickNonRoled == true and IsUnitInCombat('player') == true then
		return
	end

	if AdvancedGroupRoster.SV.groupSizeRaidManage > 0 and GetGroupSize() < AdvancedGroupRoster.SV.groupSizeRaidManage then
		return
	end

	--if yes, go through each group member, get the unit tag, find the role, and if role doesn't exist, kick, but only kick up to the amount you need, so just one
	local playersType = 0
	local characterName = 'nil'

	for i=1, GetGroupSize() do
		playersType = 0
		characterName = GetUnitName(GetGroupUnitTagByIndex(i))

		for j=1, 7 do
			for index, name in pairs(self.SV.rolePlayers[j]) do
				if string.find(name, characterName) then
					playersType = j
					break
				end
			end

			if playersType ~= 0 then
				break
			end
		end

		if playersType == 0 then
			AdvancedGroupRoster.kickByName(characterName)
			return
		end
	end
end
