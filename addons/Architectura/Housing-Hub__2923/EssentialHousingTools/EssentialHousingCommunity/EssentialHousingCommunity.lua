---[ Constants ]---

local ADDON_VERSION = 44
local ADDON_AUTHOR = "@Cardinal05, @Architectura"
local ADDON_NAME = "EssentialHousingCommunity"
local ADDON_TITLE = "Essential Housing Community"
local ADDON_TITLE_LONG = ADDON_TITLE .. " (v " .. ADDON_VERSION .. ")"
local ADDON_ROOT_PATH = "user:/AddOns/EssentialHousingTools/EssentialHousingCommunity/"
local ADDON_ICON_PATH = "/EssentialHousingTools/EssentialHousingCommunity/EssentialHousingCommunity.dds"

function IsNewerEssentialHousingCommunityVersionAvailable()
	-- A newer version is already installed.
	return EHT and EHT.Community and EHT.Community.ADDON_VERSION and EHT.Community.ADDON_VERSION > ADDON_VERSION
end

if IsNewerEssentialHousingCommunityVersionAvailable() then
	return
end

function IsEssentialHousingCommunityRootPathValid()
	local manager = GetAddOnManager()
	local numAddOns = manager:GetNumAddOns()
	for index = 1, numAddOns do
		local name, title, author, description, enabled = manager:GetAddOnInfo(index)
		if enabled and name == ADDON_NAME or title == ADDON_TITLE then
			local rootPath = manager:GetAddOnRootDirectoryPath(index)
			return string.lower(rootPath) == string.lower(ADDON_ROOT_PATH)
		end
	end
	return false
end

function ValidateEssentialHousingCommunityRootPath()
	local valid = IsEssentialHousingCommunityRootPathValid()
	if not valid then
		zo_callLater(function()
			df("WARNING!  The %s add-on appears to be installed in an incorrect AddOns folder.", ADDON_TITLE)
			df("Please uninstall any copies of %s, and then reinstall %s to the default installation folder:", ADDON_TITLE, ADDON_TITLE)
			d("/Documents/Elder Scrolls Online/live/AddOns/EssentialHousingTools/EssentialHousingCommunity")
			d(" *Note: Do -NOT- remove any related SavedVariables files as they contain your settings, favorites, recently visited homes, etc.")
		end, 6000)
	end
	return valid
end

if not ValidateEssentialHousingCommunityRootPath() then
	return
end

function IsEssentialHousingCommunityInstallationValid()
	return IsEssentialHousingCommunityRootPathValid() and not IsNewerEssentialHousingCommunityVersionAvailable()
end

---[ Namespaces ]---

if not EHT then EHT = { } end
if not EHT.Community then EHT.Community = { } end
local C = EHT.Community

---[ Constants ]---

EHCOMMUNITY_DIALOG_WIDTH = 1160
EHCOMMUNITY_DIALOG_CONTENT_WIDTH = 1060

C.ADDON_VERSION = ADDON_VERSION
C.ADDON_AUTHOR = ADDON_AUTHOR
C.ADDON_NAME = ADDON_NAME
C.ADDON_TITLE = ADDON_TITLE
C.ADDON_TITLE_LONG = ADDON_TITLE_LONG
C.ADDON_ROOT_PATH = ADDON_ROOT_PATH
C.ADDON_ICON_PATH = ADDON_ICON_PATH
C.ADDON_ICON_STRING = zo_iconFormat(C.ADDON_ICON_PATH, 36, 36)

C.SAVED_VARS_VERSION = 1
C.SAVED_VARS_FILE = "EssentialHousingCommunitySavedVars"
C.SAVED_VARS_DEFAULTS = { PublicRecords = { } }

C.RECORD_MAX_LENGTH = 699990
C.RECORD_TYPES =
{
	fx = "FX",
	oh = "Open House",
	gb = "Guest Journal",
	cr = "Contest Registration",
	sc = "Streamer Channel",
}

C.MAX_CONNECTION_MESSAGE_AGE_SECONDS = 60 * 60 * 24
C.MAX_RELOAD_UI_SECONDS = 45
C.MIN_RELOAD_UI_OPERATIONS = 3

C.IsDev = "@cardinal05" == string.lower( GetDisplayName() ) or "@architectura" == string.lower( GetDisplayName() )
C.Vars = { }
C.Records = { }

C.ConnectionSuccessMessages =
{
	"updated record:",
}

C.ConnectionFailureMessages =
{
	{
		Issue = "The " .. C.ADDON_ICON_STRING .. " Essential Housing Community app cannot complete or verify its installation.",
		Messages =
		{
			"cannot determine if another instance is already running",
			"could not access startup applications to determine",
			"could not be configured to run",
			"could not be registered to run",
			"could not install the latest update package",
			"could not remove the update package",
			"failed to update registry key",
			"startup applications could not be accessed",
		},
		Recommendations =
		{
			{
				Cause =
					"To keep Community features free of charge for all members, we have decided not to purchase a costly digital signature for the Community app. " ..
					"As a result, some Antivirus or Firewall products may block the 'unsigned' Community app from running.",
				Resolution =
					"An 'exception' may need to be added to your Antivirus or Firewall for EssentialHousingCommunity.exe " ..
					"in order to allow the Community app to function properly.",
			},
		}
	},
	{
		Issue = "The " .. C.ADDON_ICON_STRING .. " Essential Housing Community app cannot access (read and/or write) its own data files.",
		Messages =
		{
			"could not open the local record cache file",
			"could not read the local record cache file",
			"failed to load local cache",
			"failed to merge server data into local cache",
			"open the publicrecords",
			"process the publicrecords",
			"read the publicrecords",
			"update communitydata",
			"update the publicrecords",
		},
		Recommendations =
		{
			{
				Cause =
					"To keep Community features free of charge for all members, we have decided not to purchase a costly digital signature for the Community app. " ..
					"As a result, some Antivirus or Firewall products may block the 'unsigned' Community app from running.",
				Resolution =
					"An 'exception' may need to be added to your Antivirus or Firewall for EssentialHousingCommunity.exe " ..
					"in order to allow the Community app to function properly.",
			},
			{
				Cause =
					"Cloud Drive or Cloud Backup apps may interfere with the ability for add-ons to update their saved data correctly.",
				Resolution =
					"Open any cloud drive or cloud backup software that may be installed on your system, " ..
					"such as Google Drive, OneDrive or DropBox.\n" ..
					"Add an exclusion for the following folder (including its subfolders and files):\n" ..
					"   Documents\\Elder Scrolls Online\\live",
			},
			{
				Cause =
					"The following folder, or any files within, may be 'read-only':\n" ..
					"   Documents\\Elder Scrolls Online\\live\\AddOns\\EssentialHousingTools\\EssentialHousingCommunity",
				Resolution =
					"Launch Windows Explorer and open the folder:\n" ..
					"   Documents\\Elder Scrolls Online\n" ..
					"Right-click the 'live' folder and click 'Properties...'.\n" ..
					"Uncheck the 'Read-only' checkbox and click 'Apply'.\n" ..
					"Choose 'Apply changes to this folder, subfolders and files' and click 'OK'.",
			},
		},
	},
	{
		Issue = "The " .. C.ADDON_ICON_STRING .. " Essential Housing Community app cannot access (read and/or write) its SavedVariables files.",
		Messages =
		{
			"failed to read the \\savedvariables",
			"read the savedvariables",
		},
		Recommendations =
		{
			{
				Cause =
					"To keep Community features free of charge for all members, we have decided not to purchase a costly digital signature for the Community app. " ..
					"As a result, some Antivirus or Firewall products may block the 'unsigned' Community app from running.",
				Resolution =
					"An 'exception' may need to be added to your Antivirus or Firewall for EssentialHousingCommunity.exe " ..
					"in order to allow the Community app to function properly.",
			},
			{
				Cause =
					"Cloud Drive or Backup syncs may prevent add-ons from updating your data and settings.",
					"prevent AddOns and/or The Elder Scrolls Online game itself from updating your data and settings.",
				Resolution =
					"Add an exclusion for the following folder and any subfolders to any cloud backup or drive software that you may " ..
					"have running, such as Google Drive, OneDrive, DropBox, etc.:\n" ..
					"   Documents\\Elder Scrolls Online\\live",
			},
			{
				Cause =
					"The following folder, or any files within, may be flagged as read-only:\n" ..
					"   Documents\\Elder Scrolls Online\\live\\SavedVariables",
				Resolution =
					"Open the following folder with Windows Explorer:\n" ..
					"   Documents\\Elder Scrolls Online\\live\n" ..
					"Right-click the 'SavedVariables' folder and click 'Properties...'.\n" ..
					"Uncheck the 'Read-only' checkbox and click 'Apply'.\n" ..
					"Choose 'Apply changes to this folder, subfolders and files' and click 'OK'.",
			},
		},
	},
	{
		Issue = "The " .. C.ADDON_ICON_STRING .. " Essential Housing Community app cannot connect to the Community Server.",
		Messages =
		{
			"connect to the community server",
		},
		Recommendations =
		{
			{
				Cause =
					"The Community Server or your Internet connection may have experienced a temporary connectivity issue.",
				Resolution =
					"Reload the UI (type /reloadui into the Chat window) or restart your game to attempt to sync with the server again.",
			},
			{
				Cause =
					"To keep Community features free of charge for all members, we have decided not to purchase a costly digital signature for the Community app. " ..
					"As a result, some Antivirus or Firewall products may block the 'unsigned' Community app from running.",
				Resolution =
					"An 'exception' may need to be added to your Antivirus or Firewall for EssentialHousingCommunity.exe " ..
					"in order to allow the Community app to function properly.",
			},
		},
	},
}

for index, message in ipairs(C.ConnectionSuccessMessages) do
	C.ConnectionSuccessMessages[index] = string.lower(message)
end

for _, data in ipairs(C.ConnectionFailureMessages) do
	local messages = data.Messages
	if messages then
		for index, message in ipairs(messages) do
			messages[index] = string.lower(message)
		end
	end
end

---[ Initialization ]---

function C.Initialize()
	C.Vars = ZO_SavedVars:NewAccountWide( C.SAVED_VARS_FILE, C.SAVED_VARS_VERSION, nil, C.SAVED_VARS_DEFAULTS )
	C.InitializeVars()
	C.InitializeSlashCommands()

	EVENT_MANAGER:RegisterForUpdate( "EHC.PostReloadAlert", 2000, C.PostReloadAlert )
	EVENT_MANAGER:RegisterForUpdate( "EHC.CleanPublicRecords", 3000, C.CleanPublicRecords )
end

function C.InitializeVars()
	C.Vars.CommunityUserId = GetDisplayName()
end

function C.InitializeSlashCommands()
	SLASH_COMMANDS[ "/ehc" ] = C.SlashCommand( C.DumpVersion )
	if C.IsDev then
		SLASH_COMMANDS[ "/ehcstats" ] = C.SlashCommand( C.DumpStats, "General Stats" )
		SLASH_COMMANDS[ "/ehcfx" ] = C.SlashCommand( C.DumpFX, "Top 50 FX Used" )
		SLASH_COMMANDS[ "/ehcrecs" ] = C.SlashCommand( C.DumpRecordTypes, "Record Types" )
		SLASH_COMMANDS[ "/ehcpubs" ] = C.SlashCommand( C.DumpPublishers, "Publishers" )
		SLASH_COMMANDS[ "/ehcusers" ] = C.SlashCommand( C.DumpUsers, "Users" )
	end
end

---[ Utilities ]---

function C.Exception( message, data )
	if C.IsDev then
		d( message )
		if data then
			d( "Details:" )
			d( string.sub( tostring( data ), 1, 10240 ) )
		end
	end
end

function C.CloneTable( obj )
	local oT = type( obj )

	if "table" ~= oT then
		if "number" == oT then
			if obj ~= obj or -obj ~= -obj then
				return 0
			else
				return obj
			end
		elseif "boolean" == oT or "string" == oT then
			return obj
		else
			return nil
		end
	end

	local tbl = { }

	for k, v in pairs( obj ) do
		tbl[ k ] = C.CloneTable( v )
	end

	return tbl
end

function C.TableCountShallow( t )
	local count = 0
	if nil ~= t and "table" == type( t ) then for _, _ in pairs( t ) do count = count + 1 end end
	return count
end

function C.SerializeTable( t )
	local tt = type( t )
	local s, tk, tv

	if "string" == tt then
		s = string.format( "%q", t )
		-- Optimize quote escaping for the host's serialization writer.
		s = string.format( "'%s'", string.gsub( string.gsub( string.sub( s, 2, -2 ), "\\\"", "\"" ), "'", "\\'" ) )
	elseif "number" == tt then
		local _, f = math.modf( t )

		if 0 == f then
			s = string.format( "%d", t )
		else
			s = string.format( "%f", t )
		end
	elseif "table" == tt then
		s = "{"

		for k, v in pairs( t ) do
			tk = C.SerializeTable( k )
			tv = C.SerializeTable( v )

			if "" ~= tk and "" ~= tv then
				s = s .. string.format( "[%s]=%s,", tk, tv )
			end
		end

		s = s .. "}"
	else
		s = ""
	end

	return s
end

---[ Time ]---

function C.GetTimestamp()
	local tstamp = GetTimeStamp()
	local dateString, timeString = FormatAchievementLinkTimestamp( tstamp )
	return tstamp, dateString, timeString
end

function C.GetTimestampDateTime( tstamp )
	local dateString, timeString = FormatAchievementLinkTimestamp( tstamp )
	return dateString, timeString
end

function C.GetTimestampDifferenceInSeconds( tstamp1, tstamp2 )
	if nil == tstamp2 then tstamp2 = GetTimeStamp() end
	return GetDiffBetweenTimeStamps( tstamp1, tstamp2 )
end

---[ Data Tier ]---

function C.GetRecordTypeName( recordType )
	return C.RECORD_TYPES[ recordType ]
end

function C.RequestPrioritySave()
	-- No longer supported due to file contention issues as of Update 29.
end

function C.GetHashValue( s, range )
	if not s or "string" ~= type( s ) then
		return nil
	end

	range = range or 2048

	local hash = 0

	for index = 1, #s do
		hash = ( hash + string.byte( string.sub( s, index, index ) ) ) % range
	end

	return hash + 1
end

function C.IsPostReloadAlertFlagSet()
	return true == C.Vars.PostReloadAlert
end

function C.SetPostReloadAlertFlag()
	C.Vars.PostReloadAlert = true
	C.RequestPrioritySave()
end

function C.ClearPostReloadAlertFlag()
	C.Vars.PostReloadAlert = false
	C.RequestPrioritySave()
end

function C.GetRecords()
	return C.Records
end

function C.SetRawRemoteRecord( key, value )
	if not key or not value then
		return nil
	end

	key = string.lower( key )
	C.Records[ key ] = value
	return C.Records[ key ]
end

function C.GetRawRemoteRecord( key )
	return C.Records[ string.lower( key ) ]
end

function C.GetRecord( key )
	key = string.lower( key )

	local record = C.Records[key]
	if record then
		if "string" == type( record ) and "{" == string.sub( record, 1, 1 ) then
			local dataFunc = zo_loadstring( "return " .. record )
			if dataFunc then
				local dataTable = dataFunc()
				if "table" == type( dataTable ) then
					dataTable.Key = key
					C.Records[key] = dataTable
					return dataTable
				else
					C.Exception( string.format( "EHT.Community.GetRecord(%s)\nParse failed.", tostring( key ) ), record )
				end
			end
		else
			return record
		end
	end

	return nil
end

function C.GetRawLocalRecords()
	local data = C.Vars.PublicRecords

	if "table" ~= type( data ) then
		data = { }
		C.Vars.PublicRecords = data
	end

	return data
end

function C.GetRawLocalRecord( key )
	local records = C.GetRawLocalRecords()
	local data = records[key]

	if "table" == type( data ) then
		return table.concat( data, "" )
	end

	return nil
end

function C.EstimateRecordSize( key )
	key = string.lower( key or "" )
	local data = C.Records[key]
	local s = C.SerializeTable( data )
	return #s
end

function C.SetRecord( key, data, suppressPostReloadFlag )
	if "string" ~= type( key ) or ( "string" ~= type( data ) and "table" ~= type( data ) ) then
		return false
	end

	data = C.CloneTable( data )
	key = string.lower( key )

	local records = C.Vars.PublicRecords
	if not records then
		records = { }
		C.Vars.PublicRecords = records
	end

	if "table" == type( data ) then
		data.TS = GetTimeStamp()
	end

	local dataString

	if "table" == type( data ) then
		dataString = C.SerializeTable( data )
	else
		dataString = data
	end

	local fragments = { }

	if #dataString > C.RECORD_MAX_LENGTH then
		return false, "Record size too large."
	end

	for index = 1, #dataString, 350 do
		table.insert( fragments, string.sub( dataString, index, index + 349 ) )
	end

	-- Temporarily update local cache
	C.Records[key] = data
	records[key] = fragments

	if not suppressPostReloadFlag then
		C.SetPostReloadAlertFlag()
	end

	C.RequestPrioritySave()
	return true
end

function C.CleanPublicRecords()
	EVENT_MANAGER:UnregisterForUpdate( "EHC.CleanPublicRecords" )

	if C.CleanedPublicRecords then return end
	C.CleanedPublicRecords = true

	local records = C.GetRawLocalRecords()
	local updated = false

	for key in pairs( records ) do
		key = string.lower( tostring( key ) )

		if string.sub( key, 1, 4 ) == "gr__" then
			-- Wipe Guest Journal Reset requests once sent.
			records[key] = nil
			updated = true
		elseif string.sub( key, 1, 4 ) == "sg__" then
			-- Wipe Guest Journal Signature requests once sent.
			records[key] = nil
			updated = true
		end
	end
end

---[ UI ]---

function C.PostReloadAlert()
	EVENT_MANAGER:UnregisterForUpdate( "EHC.PostReloadAlert" )

	if C.IsPostReloadAlertFlagSet() then
		C.ClearPostReloadAlertFlag()

		if EHT and EHT.UI and EHT.UI.ShowAlertDialog then
			EHT.UI.ShowAlertDialog( "", "|cffffffYour data will be sync'd with the server now.\n\n" ..
				"|cffff88If you currently have guests, please advise them to type |c88ffff/reloadui|cffff88 as this will send your data " ..
				"to them. Please note that any guests that have not installed the Community app must do so first." )
		end
	end
end

function C.ShowExceptionDialog(data)
	local dialog = EHCommunityExceptionDialog
	if not data then
		dialog:SetHidden(true)
		return
	end

	dialog.IssueLabel:SetText(data.Issue or "Unknown issue")

	for recIndex, recContainer in ipairs(dialog.RecommendationContainers) do
		local recData = data.Recommendations[recIndex]
		if not recData then
			recContainer:SetHidden(true)
		else
			recContainer.CauseLabel:SetText(recData.Cause or "Unknown cause")
			recContainer.ResolutionLabel:SetText(recData.Resolution or "Unknown resolution")
			recContainer:SetHidden(false)
		end
	end

	dialog:SetHidden(false)
end

function C.HideExceptionDialog(snoozeUntilTimestamp)
	local dialog = EHCommunityExceptionDialog
	dialog:SetHidden(true)

	if snoozeUntilTimestamp then
		C.Vars.ExceptionSnoozeUntilTimestamp = tonumber(snoozeUntilTimestamp)
	end
end

function C.CheckConnectionMessages()
	if 0 == GetCurrentZoneHouseId() or not IsOwnerOfCurrentHouse() then
		-- Only display warnings while in the player's own home to avoid interrupting at less opportune times.
		return
	end

	local messages = C.ConnectionMessages
	if "table" ~= type(messages) then
		-- The EssentialHousingCommunity app is either not installed, completely malfunctioning or does not support Connection Message logging.
		return true
	end
-- /script EHT.Community.Vars.ExceptionSnoozeUntilTimestamp = 0
	local snoozeUntilTimestamp = tonumber(C.Vars.ExceptionSnoozeUntilTimestamp) or 0
	if snoozeUntilTimestamp > GetTimeStamp() then
		-- Exception warnings have been snoozed until a future time.
		return true
	end

	local currentTimestamp = GetTimeStamp()
	local successMessages = C.ConnectionSuccessMessages
	local failureMessages = C.ConnectionFailureMessages
	local messageData, success = nil, true
	local entryTimestamp

	for entryIndex, entryData in ipairs(messages) do
		entryTimestamp = entryData.ts
		if entryTimestamp then
			if snoozeUntilTimestamp > entryTimestamp then
				-- We have already snoozed warnings until something newer than these messages appears.
				break
			end

			local seconds = GetDiffBetweenTimeStamps(entryTimestamp, currentTimestamp)
			if seconds > C.MAX_CONNECTION_MESSAGE_AGE_SECONDS then
				-- We will never consider messages older than the maximum allowable age.
				break
			end
		end

		local message = string.lower(entryData.message)
		if "" ~= message then
			for _, successMessage in ipairs(successMessages) do
				if PlainStringFind(message, successMessage) then
					-- The most recent noteworthy message is that of a successful connection.
					messageData = successMessage
					break
				end
			end

			if messageData then
				break
			end

			for _, failureData in ipairs(failureMessages) do
				for _, failureMessage in ipairs(failureData.Messages) do
					if PlainStringFind(message, failureMessage) then
						-- The most recent noteworthy message is that of a connection failure.
						messageData = failureData
						success = false
						break
					end
				end
			end

			if messageData then
				break
			end
		end
	end

	if success then
		return true
	end
	
	if entryTimestamp then
		-- Snooze further warnings at least until a new failure appears after the one we are about to display.
		C.Vars.ExceptionSnoozeUntilTimestamp = entryTimestamp + 1
	end

	C.ShowExceptionDialog(messageData)
	return false
end

function C.SlashCommand( func, caption )
	return function( ... )
		local heading = "Essential Housing Community"
		df( "%s\n%s", heading, tostring( caption or "" ) )
		return func( ... )
	end
end

function C.DumpVersion( cmd )
	df( "Version %s", tostring( C.ADDON_VERSION ) )
	return true
end

function C.DumpFX( cmd )
	local ids, idsByPlayer, players = { }, { }, { }

	for key, value in pairs( C.Records ) do
		if string.sub( key, 1, 4 ) == "fx__" then
			if "string" == type( value ) then
				value = C.GetRecord( key )
			end

			if "table" == type( value ) then
				local houses = value.Houses
				if "table" == type( houses ) then
					for houseId, house in pairs( houses ) do
						local effects = house.Effects
						if "table" == type( effects ) then
							for effectIndex, effect in pairs( effects ) do
								local typeId = tonumber( effect.EffectType )
								if typeId then
									ids[typeId] = ( ids[typeId] or 0 ) + 1
									players[key] = ( players[key] or 0 ) + 1

									local playerIds = idsByPlayer[typeId]
									if not playerIds then
										playerIds = {}
										idsByPlayer[typeId] = playerIds
									end
									playerIds[key] = true
								end
							end
						end
					end
				end
			end
		end
	end

	local numPlayers = NonContiguousCount( players )
	local totalFX = 0
	local maxFX, maxFXPlayer
	local list = {}

	for id, count in pairs( players ) do
		if not maxFX or count > maxFX then
			maxFX = count
			maxFXPlayer = id
		end
	end

	for id, count in pairs( ids ) do
		local players = idsByPlayer[id] and NonContiguousCount(idsByPlayer[id]) or 0
		table.insert( list, { id, count, players } )
		totalFX = totalFX + count
	end

	local SORT_BY_PLAYERS = 1
	local SORT_BY_PLACED = 2

	local sortBy = SORT_BY_PLAYERS
	if "placed" == cmd then
		sortBy = SORT_BY_PLACED
	end

	if sortBy == SORT_BY_PLACED then
		table.sort( list, function( a, b ) return a[2] > b[2] end )
	else
		table.sort( list, function( a, b ) return a[3] > b[3] end )
	end

	local maxIndex = math.min( #list, 50 )
	local avgFX = totalFX / numPlayers

	for index = 1, maxIndex do
		local item = list[index]
		local id, count, players = item[1], item[2], item[3]
		local effectType = EHT.EffectType:GetByIndex( id )
		local typeName = effectType and effectType.Name or string.format( "(id: %d)", id )
		
		if sortBy == SORT_BY_PLACED then
			df( "x%d instances (%.2f%%) by %d player (%.2f%%) > %s\n", count, 100 * ( count / totalFX ), players, 100 * ( players / numPlayers ), typeName )
		else
			df( "x%d players (%.2f%%), x%d instances (%.2f%%) > %s\n", players, 100 * ( players / numPlayers ), count, 100 * ( count / totalFX ), typeName )
		end
	end

	df( "\n%d Total FX published by %d members", totalFX, numPlayers )
	df( "%d Average FX published by members", avgFX or 0 )
	df( "%d Maximum FX published by any member (%s)", maxFX or 0, maxFXPlayer or "" )
end

function C.DumpRecordTypes()
	local ids, list = { }, { }

	for key, data in pairs( C.Records ) do
		local id = string.match( key, "^(%w+)__" )
		if id then
			local dataLength = 0
			if "string" == type( data ) then
				dataLength = #data
			else
				dataLength = C.EstimateRecordSize( key )
			end

			local item = ids[id]
			if item then
				item[1] = item[1] + 1
				item[2] = item[2] + dataLength
			else
				item =
				{
					1,
					dataLength,
				}
				ids[id] = item
			end
		end
	end

	local totalCount, totalDataLength = 0, 0

	for id, idItem in pairs( ids ) do
		local count, dataLength = idItem[1], idItem[2]
		local item =
		{
			string.lower( C.GetRecordTypeName( id ) or string.format( "%q", id or "" ) ),
			count,
			dataLength,
		}
		table.insert( list, item )
		totalCount = totalCount + count
		totalDataLength = totalDataLength + dataLength
	end

	table.sort( list, function( a, b ) return a[1] < b[1] end )
	
	local function GetDataLengthDescription( dataLength )
		if dataLength >= 10240 then
			return string.format( "%dKb", dataLength / 1024 )
		else
			return string.format( "%.2fKb", dataLength / 1024 )
		end
	end

	for index, item in ipairs( list ) do
		local recordTypeName, count, dataLength = item[1], item[2], item[3]
		recordTypeName = recordTypeName .. " " .. string.rep( "_", 24 - #recordTypeName )
		local dataLengthDescription = GetDataLengthDescription( dataLength )

		df( " %s %d rec (%s)\n", recordTypeName, count, dataLengthDescription )
	end

	df( "\n%d total rec (%s)", totalCount, GetDataLengthDescription( totalDataLength ) )
end

function C.DumpStats()
	local hub = EssentialHousingHub
	local openHouses =
	{
		na = 0,
		eu = 0,
		categories = {},
	}
	local openHousesPerUser = {}

	for recordKey in pairs(C.Records) do
		local recordType = string.match(recordKey, "^(%w%w)__")
		if "oh" == recordType then
			local record = hub:GetCommunityOpenHouseRecordByKey(recordKey)
			if record then
				local numHousesForUser = 0
				if record.na then
					local houseCount = 0
					for houseId, houseRecord in pairs(record.na) do
						houseCount = houseCount + 1
						if houseRecord.C then
							openHouses.categories[houseRecord.C] = (openHouses.categories[houseRecord.C] or 0) + 1
						end
					end
					openHouses.na = openHouses.na + houseCount
					numHousesForUser = numHousesForUser + houseCount
				end
				if record.eu then
					local houseCount = 0
					for houseId, houseRecord in pairs(record.eu) do
						houseCount = houseCount + 1
						if houseRecord.C then
							openHouses.categories[houseRecord.C] = (openHouses.categories[houseRecord.C] or 0) + 1
						end
					end
					openHouses.eu = openHouses.eu + houseCount
					numHousesForUser = numHousesForUser + houseCount
				end
				if numHousesForUser > 0 then
					table.insert(openHousesPerUser, numHousesForUser)
				end
			end
		end
	end

	local categoryCounts = {}
	for categoryId, categoryCount in pairs(openHouses.categories) do
		local categoryName = hub:GetOpenHouseCategoryName(categoryId)
		if categoryName then
			categoryCounts[categoryName] = (categoryCounts[categoryName] or 0) + categoryCount
		end
	end

	local categoryList = {}
	for categoryName, categoryCount in pairs(categoryCounts) do
		table.insert(categoryList, {name = categoryName, count = categoryCount})
	end

	table.sort(categoryList, function(left, right)
		return left.count > right.count
	end)

	table.sort(openHousesPerUser, function(left, right)
		return left < right
	end)

	local numOpenHouses = openHouses.na + openHouses.eu
	local numOpenHouseUsers = #openHousesPerUser
	local averageOpenHousesPerUser = numOpenHouses / numOpenHouseUsers
	local medianOpenHousesPerUser = 0
	local minOpenHousesPerUser = 0
	local maxOpenHousesPerUser = 0
	if numOpenHouseUsers > 0 then
		local medianIndex = zo_ceil(numOpenHouseUsers * 0.5)
		medianOpenHousesPerUser = openHousesPerUser[medianIndex]
		minOpenHousesPerUser = openHousesPerUser[1]
		maxOpenHousesPerUser = openHousesPerUser[numOpenHouseUsers]
	end

	d("[ Open House Categories ]")
	local categorizedHomes = 0
	for _, categoryData in ipairs(categoryList) do
		df("... %u %s", categoryData.count, categoryData.name)
		if "(Uncategorized)" ~= categoryData.name then
			categorizedHomes = categorizedHomes + categoryData.count
		end
	end
	df("%u Categorized Homes", categorizedHomes)

	d("|ac-")

	d("[ Open Houses ]")
	df("... %u Europe", openHouses.eu)
	df("... %u North America", openHouses.na)
	df("%u Open Houses", numOpenHouses)

	d("|ac-")

	d("[ Open House Engagement ]")
	df("... %u Min Open Houses/User", minOpenHousesPerUser)
	df("... %u Max Open Houses/User", maxOpenHousesPerUser)
	df("... %.2f Median Open Houses/User", medianOpenHousesPerUser)
	df("... %.2f Average Open Houses/User", averageOpenHousesPerUser)
	df("%u Open House Users", numOpenHouseUsers)
end

function C.DumpPublishers( startIndex )
	local ids, list = { }, { }

	for key in pairs( C.Records ) do
		local id = string.match( key, ".*(@[a-zA-Z0-9]+).*" )

		if id and not ids[id] then
			ids[id] = true
		end
	end

	for id in pairs( ids ) do
		table.insert( list, id )
	end

	startIndex = tonumber( startIndex ) or 1
	local endIndex = math.min( #list, startIndex + 99 )

	table.sort( list )

	for index = startIndex, endIndex do
		df( "[%d] %s", index, list[index] )
	end

	df( "Shown %d through %d of %d total publishers", startIndex, endIndex, #list )
end

do
	local cachedIds, cachedList, cachedNumSignatures = nil, nil, nil

	function C.DumpUsers( startIndexOrDisplayName )
		local ids, list, signatures = cachedIds, cachedList, cachedNumSignatures or 0
		if not ids then
			ids, list = { }, { }

			for key, value in pairs( C.Records ) do
				key = string.lower( key )
				local id = string.match( key, ".*(@[a-zA-Z0-9]+).*" )

				if id and not ids[id] then
					ids[id] = 0
				end

				if string.sub( key, 1, 2 ) == "gb" then
					local iters = 0

					while 0 < #value and 500 > iters do
						local p1, p2, id = string.find( value, "%((%@[a-zA-Z0-9]-)%)" )

						if not p1 or not p2 or not id then
							value = ""
						else
							id = EssentialHousingHub:Trim( string.lower( id ) )
							local sigs = ids[id] or 0
							ids[id] = sigs + 1
							value = string.sub( value, p2 + 1 )

							local ps = string.find( value, ";" )
							if ps then
								value = string.sub( value, ps + 1 )
							end

							signatures = signatures + 1
						end

						iters = iters + 1
					end
				end
			end

			for id in pairs( ids ) do
				table.insert( list, id )
			end

			table.sort( list )

			cachedIds, cachedList, cachedNumSignatures = ids, list, signatures
		end

		local numListEntries = #list
		local startIndex = tonumber( startIndexOrDisplayName )

		if startIndex or startIndexOrDisplayName == "" then
			startIndex = startIndex or 1
			local endIndex = math.min( numListEntries, startIndex + 99 )

			for index = startIndex, endIndex do
				local id = list[index]
				df( "[%d] %s%s", index, id, ( ids[id] and 0 < ids[id] ) and string.format( " (signed %d journals)", ids[id] ) or "" )
			end

			df( "Users %d - %d (%d total users)", startIndex, endIndex, numListEntries )
		else
			local partialDisplayName = string.lower( tostring( startIndexOrDisplayName ) )
			local numUsers = 0

			for index, id in ipairs( list ) do
				if PlainStringFind( id, partialDisplayName ) then
					df( "[%d] %s%s", index, id, ( ids[id] and 0 < ids[id] ) and string.format( " (signed %d journals)", ids[id] ) or "" )
				end
					numUsers = numUsers + 1
			end

			df( "%d users matched \"%s\" (%d total users)", numUsers, partialDisplayName, numListEntries )
		end

		df( "Guest journals have been signed %d times.", signatures )
	end
end

---[ Event Handlers ]---

function C.OnAddOnLoaded( event, addonName )
	if addonName == C.ADDON_NAME then
		EVENT_MANAGER:UnregisterForEvent( C.ADDON_NAME, EVENT_ADD_ON_LOADED )
		C.Initialize()
	end
end

function C.OnPlayerActivated()
	local retries = tonumber(C.Vars.ExceptionRetries) or 0
	retries = retries + 1

	local timestamp = tonumber(C.Vars.ExceptionRetryTimeStamp) or 0
	local timestampDeltaSeconds = GetTimeStamp() - timestamp

	if 1 < timestampDeltaSeconds and timestampDeltaSeconds < C.MAX_RELOAD_UI_SECONDS and retries < C.MIN_RELOAD_UI_OPERATIONS then
		C.Vars.ExceptionRetries = retries
		ReloadUI()
		return
	end

	C.Vars.ExceptionRetryTimeStamp = nil
	C.Vars.ExceptionRetries = nil
	C.CheckConnectionMessages()
end

---[ Event Registration ]---

EVENT_MANAGER:RegisterForEvent( C.ADDON_NAME, EVENT_ADD_ON_LOADED, C.OnAddOnLoaded )
EVENT_MANAGER:RegisterForEvent( C.ADDON_NAME, EVENT_PLAYER_ACTIVATED, C.OnPlayerActivated )

---[ Global Xml Functions ]---

function EHCommunity_ExceptionDialog_Close()
	C.HideExceptionDialog()
end

function EHCommunity_ExceptionDialog_CloseAndSnooze()
	local SNOOZE_UNTIL_TIMESTAMP = GetTimeStamp() + 60 * 60 * 24 * 14 -- Two weeks
	C.HideExceptionDialog(SNOOZE_UNTIL_TIMESTAMP)
end

function EHCommunity_DoubleReloadUI()
	-- C.Vars.ExceptionRetryTimeStamp = GetTimeStamp()
	C.Vars.ExceptionRetryTimeStamp = nil
	C.Vars.ExceptionRetries = 0
	ReloadUI()
end

function EHCommunity_ExceptionDialog_Retry()
	EHCommunity_DoubleReloadUI()
end

EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.Community = true
