local TBoxAddon = _G['TBoxAddon']
local L = TBoxAddon.DB.Strings
local dQC = TBoxAddon.DB.QualityColors

TBoxAddon.AT.TreasureTable = {} -- initialize the dynamically generated active tables (AT)
TBoxAddon.AT.TreasureTableF = {}
TBoxAddon.AT.Categories = {}
TBoxAddon.AT.Zones = {}
TBoxAddon.AT.TreasuresFound = 0 -- total treasures found by any characters
TBoxAddon.AT.TreasuresTotal = 0 -- total treasures available in the current API
TBoxAddon.AT.FavoriteZone = "" -- zone where the most treasure has been found

local updateRunning = false
local maxTreasureId = 0
local cCheck = {}


local function FinalizeMainTables(rebuild, version) -- initialize saved variable structure and clear old obsolete data
	local tFound = 0
	local tTotal = 0

	for k, d in pairs(TBoxAddon.ASV.TreasureDB) do
		if not TBoxAddon.AT.TreasureTable[k] then 
			if d.name ~= nil then
				for t, v in pairs(TBoxAddon.AT.TreasureTable) do -- attempt to migrate/preserve saved data if treasure ID changes
					if v.name == d.name then
						TBoxAddon.ASV.TreasureDB[t] = d
					end
				end
				TBoxAddon.ASV.TreasureDB[k] = nil
			end
		end
	end
	
	for k, v in pairs(TBoxAddon.AT.TreasureTable) do -- add items to the saved variable database for tracking and fast post-init loading
		if TBoxAddon.ASV.TreasureDB[k] == nil then
			TBoxAddon.ASV.TreasureDB[k] = {
				name = v.name,
				found = false,
				lastFound = 0,
				lastID = 0,
				lastZone = 0,
				total = 0,
				IDs = {},
				zones={},
				categories = {},
			}
			for i, d in pairs(v.categories) do TBoxAddon.ASV.TreasureDB[k].categories[d] = true end
		else
			if (rebuild) then -- update saved item name & category in case they change
				TBoxAddon.ASV.TreasureDB[k].name = v.name
				TBoxAddon.ASV.TreasureDB[k].categories = {}
				for i, d in pairs(v.categories) do TBoxAddon.ASV.TreasureDB[k].categories[d] = true end
			end
		end
		tTotal = tTotal + 1
	end
	TBoxAddon.AT.TreasuresTotal = tTotal

	if (rebuild) then -- clear possible obsolete categories on full update
		for k, v in pairs(TBoxAddon.ASV.Categories) do
			if not cCheck[k] and k ~= L.TBoxAddon_NOCATEGORY then TBoxAddon.ASV.Categories[k] = nil end
		end
	end

	for k, d in pairs(TBoxAddon.ASV.TreasureDB) do
		if (d.found) then tFound = tFound + 1 end -- update the number of found treasures
		if d.zones ~= nil then -- update the global list of zones where treasure has been found
			for t in pairs(d.zones) do
				if t then
					if t ~= "" and not TBoxAddon.ASV.Zones[t] then
						TBoxAddon.ASV.Zones[t] = true
					elseif t == "" then
						local tZone = zo_strformat("<<t:1>>",GetZoneNameById(GetParentZoneId(GetZoneId(GetUnitZoneIndex("player")))))
						local zOpt = ""
						if tZone ~= nil and tZone ~= "" then -- fix for cases where the game returns "" for the player's current zone
							if not d.zones[tZone] then
								TBoxAddon.ASV.TreasureDB[k].zones[tZone] = true
								zOpt = tZone
							end
						else
							if not d.zones[L.TBoxAddon_UNKNOWN] then
								TBoxAddon.ASV.TreasureDB[k].zones[L.TBoxAddon_UNKNOWN] = true
								zOpt = L.TBoxAddon_UNKNOWN
							end
						end
						TBoxAddon.ASV.TreasureDB[k].zones[t] = nil
						TBoxAddon.ASV.Zones[zOpt] = true
						if d.lastZone and d.lastZone == "" then
							TBoxAddon.ASV.TreasureDB[k].lastZone = zOpt
						end
					end
				end
			end
		end
	end
	for k, v in pairs(TBoxAddon.ASV.Zones) do
		if k == "" then
			TBoxAddon.ASV.Zones[k] = nil
		--	TBoxAddon.ASV.Zones[L.TBoxAddon_UNKNOWN] = true -- i don't want to see "Unknown" in the nav list of zones atm
		end
	end
	TBoxAddon.AT.TreasuresFound = tFound

	TBoxAddon.AT.Categories = {} -- sort the category table alphabetically
	for k, v in pairs(TBoxAddon.ASV.Categories) do
		TBoxAddon.AT.Categories[#TBoxAddon.AT.Categories + 1] = k
	end
	table.sort(TBoxAddon.AT.Categories)

	TBoxAddon.AT.Zones = {} -- sort the zone table alphabetically
	for k, v in pairs(TBoxAddon.ASV.Zones) do
		TBoxAddon.AT.Zones[#TBoxAddon.AT.Zones + 1] = k
	end
	table.sort(TBoxAddon.AT.Zones)

	TBoxAddon.AT.TreasureTableF = {} -- create second table containing only found treasures (for toggle option)
	for k, v in pairs(TBoxAddon.ASV.TreasureDB) do
		if (v.found) and TBoxAddon.AT.TreasureTable[k] then
			TBoxAddon.AT.TreasureTableF[k] = true
		end
	end

	TBoxAddon.InitCheck = 2
	updateRunning = false

	if rebuild then
		TBoxAddon.ASV.aOpts.APIversion = GetAPIVersion() -- update saved API version to avoid full auto update until major content patch
		TBoxAddon.ResetPending = true
		zo_callLater(function()

			if version ~= nil and version > TBoxAddon.ASV.aOpts.version then TBoxAddon.ASV.aOpts.version = version end -- update last DB maintenance version

			d(L.TBoxAddon_UPDATE1.." ("..tostring(maxTreasureId)..")")
			d(L.TBoxAddon_UPDATE2)
		--	ReloadUI()
		end, 5000)
	end
end

local function ProcessItemLink(tId, tLink, tCats) -- build the main treasure box database indexed by item ID
	local tName = zo_strformat("<<t:1>>",GetItemLinkName(tLink))
	local tQual = GetItemLinkQuality(tLink)
	local numItemTags = GetItemLinkNumItemTags(tLink)

	if not tCats then -- use saved variable list of categories unless rebuilding for extra speed
		tCats = {}
		if numItemTags == 0 then
			tCats[1] = L.TBoxAddon_NOCATEGORY
		else
			for i = 1, numItemTags do
				local itemTagDescription, _ = GetItemLinkItemTagInfo(tLink, i)
				if itemTagDescription and itemTagDescription ~= "" then
					local cFormat = zo_strformat("<<t:1>>",itemTagDescription)
					tCats[#tCats + 1] = cFormat
					if not cCheck[cFormat] then cCheck[cFormat] = true end
					TBoxAddon.ASV.Categories[cFormat] = true
				end
			end
		end
	end

	TBoxAddon.AT.TreasureTable[tId] = {
		link = tLink,
		name = tName,
		quality = tQual,
		categories = tCats,
		}
	return
end

local function RebuildStarter(stage, version) -- rebuild the treasure box database from scratch on 1st load or API update (slow)
	local tempInt = (stage == 1) and 0 or 1
	local IdLow = (25000 * stage) - 25000
	local IdHigh = 25000 * stage
	local sMax = 10

	if stage == 1 then TBoxAddon.AT.TreasureTable = {} d(L.TBoxAddon_UPDATING) end

	for i = IdLow, IdHigh, 1 do
		local tId = i+tempInt
		local tLink = "|H1:item:" .. tostring(tId) .. ":4:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:17:0:0:0|h|h"
		local itemType, specializedItemType = GetItemLinkItemType(tLink)

		if itemType == ITEMTYPE_TREASURE and specializedItemType == SPECIALIZED_ITEMTYPE_TREASURE then
	--	if itemType == ITEMTYPE_TREASURE then
			if maxTreasureId < tId then maxTreasureId = tId end
			ProcessItemLink(tId, tLink)
		end

		if i == IdHigh then
			if stage == sMax then
				FinalizeMainTables(true, version)
				return
			else
				zo_callLater(function() RebuildStarter(stage+1, version) end, 500)
				return
			end
		end
	end
end

local function UpdateStarter() -- update the treasure box database from saved variables (fast)
	for tID, data in pairs(TBoxAddon.ASV.TreasureDB) do
		local sLink = "|H1:item:" .. tostring(tID) .. ":4:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:17:0:0:0|h|h"
		ProcessItemLink(tID, sLink, data.categories)
	end

	FinalizeMainTables(false)
	return
end

function TBoxAddon.DB.InitTables(rebuild, version) -- initialize building the internal treasure box database
	if not updateRunning then
		tempFilter = {}
		updateRunning = true
		if not TBoxAddon.ASV.Categories[L.TBoxAddon_NOCATEGORY] then TBoxAddon.ASV.Categories[L.TBoxAddon_NOCATEGORY] = true end

	-- only run the slower functions to completely rebuild the database if API version changes or user manually runs "/tbox update"
		if (rebuild) then
			cCheck = {}
			RebuildStarter(1, version)
		else
			local cAPIversion = TBoxAddon.ASV.aOpts.APIversion
			if cAPIversion and cAPIversion == GetAPIVersion() then
				UpdateStarter()
			else
				cCheck = {}
				RebuildStarter(1, version)
			end
		end
	end
end
