ESODBLeaderboardExportUtils = {}

function ESODBLeaderboardExportUtils:GetTableIndexByFieldValue(table, field, value)

	local status = false

	for key, obj in ipairs(table) do
		if type(obj[field]) ~= "nil" then
			if obj[field] == value then
				status = key
			end
		end
	end

	return status
end

function ESODBLeaderboardExportUtils:SetTableIndexByFieldValue(svTable, field, value, default)

	local tableIndex = ESODBLeaderboardExportUtils:GetTableIndexByFieldValue(svTable, field, value)
	if tableIndex == false then
		table.insert(svTable, default)
		tableIndex = #svTable
	end

	return tableIndex
end

function ESODBLeaderboardExportUtils:GetMegaserver()
	return string.upper(string.sub(GetUniqueNameForCharacter(GetUnitName("player")), 0, 2))
end

function ESODBLeaderboardExportUtils:IsValidMegaserver(megaserver, megaservers)

	local status = false

	for _, megaserverKey in pairs(megaservers) do
		if megaserverKey == megaserver then
			status = true
		end
	end

	return status
end