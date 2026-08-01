local LCCC = LibCodesCommonCode
local Internal = LibMultiAccountAchievementsInternal
local Public = LibMultiAccountAchievements


--------------------------------------------------------------------------------
-- Base-Game Analogues
--------------------------------------------------------------------------------

function Public.GetAchievementProgress( owner, achievementId )
	if (Internal.IsOwnerCurrentPlayer(owner)) then
		return GetAchievementProgress(achievementId)
	else
		local data = Internal.ReadData(owner, achievementId)
		return data.progress
	end
end

function Public.GetAchievementTimestamp( owner, achievementId )
	if (Internal.IsOwnerCurrentPlayer(owner)) then
		return GetAchievementTimestamp(achievementId)
	else
		local data = Internal.ReadData(owner, achievementId)
		return data.timestamp
	end
end

function Public.IsAchievementComplete( owner, achievementId )
	if (Internal.IsOwnerCurrentPlayer(owner)) then
		return IsAchievementComplete(achievementId)
	else
		local data = Internal.ReadData(owner, achievementId)
		return data.timestamp > 0
	end
end

function Public.GetAchievementCriterion( owner, achievementId, criterionIndex )
	if (Internal.IsOwnerCurrentPlayer(owner)) then
		return GetAchievementCriterion(achievementId, criterionIndex)
	else
		criterionIndex = criterionIndex or 1
		local data = Internal.ReadData(owner, achievementId)
		local results = { GetAchievementCriterion(achievementId, criterionIndex) }
		results[2] = data.criteria[criterionIndex] or 0
		return unpack(results)
	end
end

function Public.GetAchievementLink( owner, achievementId, linkStyle )
	if (Internal.IsOwnerCurrentPlayer(owner)) then
		return GetAchievementLink(achievementId, linkStyle)
	else
		if (type(linkStyle) ~= "number") then linkStyle = LINK_STYLE_DEFAULT end
		local data = Internal.ReadData(owner, achievementId)
		return (#data.criteria > 0) and string.format("|H%d:achievement:%d:%s:%d|h|h", linkStyle, achievementId, Id64ToString(data.progress), data.timestamp) or ""
	end
end


--------------------------------------------------------------------------------
-- Server/Account/Character Information
--------------------------------------------------------------------------------

function Public.GetServers( )
	local results = { }

	for _, data in pairs(Internal.accts) do
		local server, account = zo_strsplit(",", data)
		if (server and account) then
			results[server] = true
		end
	end

	return LCCC.GetSortedKeys(results, Internal.server)
end

function Public.GetAccounts( )
	local results = { }

	for _, data in pairs(Internal.accts) do
		local server, account = zo_strsplit(",", data)
		if (server and account) then
			table.insert(results, { server, account })
		end
	end

	table.sort(results, function( a, b )
		if (a[1] == b[1]) then
			return a[2] < b[2]
		elseif (a[1] == Internal.server) then
			return true
		elseif (b[1] == Internal.server) then
			return false
		else
			return a[1] < b[1]
		end
	end)

	return results
end

do
	local compare = function( a, b )
		if (a[2] == b[2]) then
			if (a[3] == Internal.userId and a[3] ~= b[3]) then
				return true
			elseif (b[3] == Internal.userId and b[3] ~= a[3]) then
				return false
			else
				return LCCC.CompareCharIds(a[1], b[1])
			end
		elseif (a[2] == Internal.server) then
			return true
		elseif (b[2] == Internal.server) then
			return false
		else
			return a[2] < b[2]
		end
	end

	function Public.GetCharacters( server, account )
		local results = { }

		if (server == true) then server = Internal.server end
		if (account == true) then account = Internal.userId end

		for charId in pairs(Internal.chars) do
			local charServer, charAccount, charName = Public.GetCharacterInfo(charId)
			if (charServer and charAccount and (not server or server == charServer) and (not account or account == charAccount)) then
				table.insert(results, { charId, charServer, charAccount, charName })
			end
		end

		table.sort(results, compare)
		return results
	end
end

function Public.GetCharacterInfo( charId )
	local idx, name = zo_strsplit(",", Internal.chars[charId or Internal.charId])
	if (idx and name) then
		local server, account = zo_strsplit(",", Internal.accts[tonumber(idx)])
		if (server and account) then
			return server, account, name
		end
	end
	return nil
end


--------------------------------------------------------------------------------
-- Miscellaneous
--------------------------------------------------------------------------------

Public.GetMaxAchievementId = Internal.GetMaxAchievementId
