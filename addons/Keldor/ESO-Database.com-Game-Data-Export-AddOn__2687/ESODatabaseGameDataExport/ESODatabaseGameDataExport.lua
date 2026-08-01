--- ESO-Database.com Export AddOn for http://www.eso-database.com
--- written by Keldor
---
--- Please report bugs at http://www.eso-database.com/en/contact/

----
--- Initialize global Variables
----
ESODBGameDataExport = {}
ESODBGameDataExport.Name = "ESODatabaseGameDataExport"
ESODBGameDataExport.DisplayName = "ESO-Database.com Game Data Export"
ESODBGameDataExport.AddonVersion = "1.0.24"
ESODBGameDataExport.AddonVersionInt = 1024
ESODBGameDataExport.SavedVariablesName = "ESODBGameDataExportSV"
ESODBGameDataExport.NumKeepChests = 1500
ESODBGameDataExport.NumKeepPsijikPortals = 1500
ESODBGameDataExport.NumKeepThievesTroves = 1500
ESODBGameDataExport.VariableVersion = 1
ESODBGameDataExport.AccountWideDefault = {
	GameData = {
		Chests = {},
		PsijikPortals = {},
		ThievesTroves = {}
	}
}


----
--- Initialize local Variables
----
local svAccount -- Saved variables for account wide data


----
--- Export Functions
----
function ESODBGameDataExport.InitGameData()

	ESODatabaseGameDataExportUtils:CleanupStatsTable(svAccount.GameData.Chests, ESODBGameDataExport.NumKeepChests)
	ESODatabaseGameDataExportUtils:CleanupStatsTable(svAccount.GameData.PsijikPortals, ESODBGameDataExport.NumKeepPsijikPortals)
	ESODatabaseGameDataExportUtils:CleanupStatsTable(svAccount.GameData.ThievesTroves, ESODBGameDataExport.NumKeepThievesTroves)
end



function ESODBGameDataExport.ExportMapPoint(type)

	if GetCurrentZoneHouseId() ~= 0 then
		return
	end

	local svType

	if type == "Chest" then
		svType = svAccount.GameData.Chests
	elseif type == "PsijikPortal" then
		svType = svAccount.GameData.PsijikPortals
	elseif type == "ThievesTrove" then
		svType = svAccount.GameData.ThievesTroves
	end

	local normalizedX, normalizedY = GetMapPlayerPosition("player")
	local zoneIndex = GetUnitZoneIndex("player")
	local zoneId = GetZoneId(zoneIndex)
	local x = (math.floor(normalizedX * 10000) / 10000)
	local y = (math.floor(normalizedY * 10000) / 10000)
	local mapContentType = GetMapContentType()
	local id = tostring(zoneId) .. tostring(x) .. tostring(y)
	local tableIndex = ESODBGameDataExportUtils:GetTableIndexByFieldValue(svType, "Id", id)

	if tableIndex == false then
		table.insert(svType, {
			Id = id,
			X = x,
			Y = y,
			ZoneId = zoneId,
			MapContentType = mapContentType,
			Timestamp = GetTimeStamp()
		})
	end
end


----
--- Event Functions
----
function ESODBGameDataExport.EventOnInteract(_, result, interactTargetName)

	if result ~= CLIENT_INTERACT_RESULT_SUCCESS then
		return
	end

	local name = zo_strformat(SI_TOOLTIP_ITEM_NAME, interactTargetName)

	if ESODBGameDataExportUtils:IsChest(name) == true then
		ESODBGameDataExport.ExportMapPoint("Chest")
	elseif ESODBGameDataExportUtils:IsPsijikPortal(name) == true then
		ESODBGameDataExport.ExportMapPoint("PsijikPortal")
	elseif ESODBGameDataExportUtils:IsThievesTrove(name) == true then
		ESODBGameDataExport.ExportMapPoint("ThievesTrove")
	end
end


----
--- OnAddOnLoaded
----
function ESODBGameDataExport.OnAddOnLoaded(_, addonName)

	if addonName ~= ESODBGameDataExport.Name then return end

	EVENT_MANAGER:UnregisterForEvent(ESODBGameDataExport.Name, EVENT_ADD_ON_LOADED)

    -- Register saved variables
	svAccount = ZO_SavedVars:NewAccountWide(ESODBGameDataExport.SavedVariablesName, ESODBGameDataExport.VariableVersion, nil, ESODBGameDataExport.AccountWideDefault)

	----
	---  Register Events
	----
	EVENT_MANAGER:RegisterForEvent(ESODBGameDataExport.Name, EVENT_CLIENT_INTERACT_RESULT, ESODBGameDataExport.EventOnInteract)
end


----
--- AddOn init
----
EVENT_MANAGER:RegisterForEvent(ESODBGameDataExport.Name, EVENT_ADD_ON_LOADED, ESODBGameDataExport.OnAddOnLoaded)
