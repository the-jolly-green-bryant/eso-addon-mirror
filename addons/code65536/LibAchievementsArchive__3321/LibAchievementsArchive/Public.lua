local Internal = LibAchievementsArchiveInternal
local Public = LibAchievementsArchive


--------------------------------------------------------------------------------
-- Base-Game Analogues
--------------------------------------------------------------------------------

function Public.ArchivedGetAchievementProgress( charId, achievementId )
	if (not charId) then charId = Internal.charId end
	local data = Internal.ReadData(charId, achievementId)
	return data.progress
end

function Public.ArchivedGetAchievementTimestamp( charId, achievementId )
	if (not charId) then charId = Internal.charId end
	local data = Internal.ReadData(charId, achievementId)
	return data.timestamp
end

function Public.ArchivedIsAchievementComplete( charId, achievementId )
	if (not charId) then charId = Internal.charId end
	local data = Internal.ReadData(charId, achievementId)
	return data.timestamp > 0
end

function Public.ArchivedGetAchievementNumCriteria( achievementId )
	local key = Internal.GetKey(achievementId)
	return #key
end

function Public.ArchivedGetAchievementCriterion( charId, achievementId, criterionIndex )
	if (not charId) then charId = Internal.charId end
	if (not criterionIndex) then criterionIndex = 1 end
	local description = GetAchievementCriterion(achievementId, criterionIndex)
	local key = Internal.GetKey(achievementId)
	local data = Internal.ReadData(charId, achievementId)
	return description, data.criteria[criterionIndex] or 0, key[criterionIndex] or 0
end

function Public.ArchivedGetAchievementLink( charId, achievementId, linkStyle )
	local key = Internal.GetKey(achievementId)
	if (#key == 0) then return "" end
	if (not charId) then charId = Internal.charId end
	if (type(linkStyle) ~= "number") then linkStyle = LINK_STYLE_DEFAULT end
	local data = Internal.ReadData(charId, achievementId)
	return string.format("|H%d:achievement:%d:%s:%d|h|h", linkStyle, achievementId, Id64ToString(data.progress), data.timestamp)
end


--------------------------------------------------------------------------------
-- Character Information
--------------------------------------------------------------------------------

function Public.GetValidCharacterIds( onlyCurrentServerAndAccount )
	local results = { }

	if (onlyCurrentServerAndAccount) then
		-- Key off of historical information if possible, in case of account name changes
		local server, account = Public.GetCharacterInformation()
		if (not server) then
			server = Internal.server
			account = Internal.userId
		end
		for charId, data in pairs(Internal.data.characters) do
			local charServer, charAccount = zo_strsplit(",", data)
			if (charServer == server and charAccount == account) then
				table.insert(results, charId)
			end
		end
	else
		for charId in pairs(Internal.data.characters) do
			table.insert(results, charId)
		end
	end

	return results
end

function Public.GetCharacterInformation( charId )
	if (not charId) then charId = Internal.charId end
	if (type(charId) == "string" and type(Internal.data.characters[charId]) == "string") then
		return zo_strsplit(",", Internal.data.characters[charId])
	end
	return nil
end


--------------------------------------------------------------------------------
-- Miscellaneous
--------------------------------------------------------------------------------

Public.ArchivedGetMaxAchievementId = Internal.GetMaxAchievementId
