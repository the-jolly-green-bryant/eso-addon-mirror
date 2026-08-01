ESODBGameDataExportUtils = {}

function ESODBGameDataExportUtils:GetTableIndexByFieldValue(table, field, value)

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

function ESODBGameDataExportUtils:CleanupStatsTable(statsTable, numKeepEntries)

	local count = 0

	-- Sort the table by Timestamp remove the oldest entries
	table.sort(statsTable, function(a, b) return a.Timestamp > b.Timestamp end)

	for key in ipairs(statsTable) do
		count = count + 1
		if(count > numKeepEntries) then
			table.remove(statsTable, key)
		end
	end

	return statsTable
end

function ESODBGameDataExportUtils:IsNameInTable(name, table)
	local status = false
	if type(table[string.lower(name)]) ~= "nil" then
		status = true
	end
	return status
end

function ESODBGameDataExportUtils:IsChest(name)
	return ESODBGameDataExportUtils:IsNameInTable(name, ESODBGameDataExportConst.ChestNames)
end

function ESODBGameDataExportUtils:IsPsijikPortal(name)
	return ESODBGameDataExportUtils:IsNameInTable(name, ESODBGameDataExportConst.PsijikPortalNames)
end

function ESODBGameDataExportUtils:IsThievesTrove(name)
	return ESODBGameDataExportUtils:IsNameInTable(name, ESODBGameDataExportConst.ThievesTroveNames)
end