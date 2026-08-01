local PUIAddon = _G['PUIAddon']

PUIAddon.AddonDB = {

[1] = 	{vars = function() return (AzurahDB ~= nil) end,						name = "Azurah",								run = function(opt) PUIAddon.Azurah() end},
[2] = 	{vars = function() return (SrendarrDB ~= nil) end,						name = "Srendarr",								run = function(opt) PUIAddon.Srendarr() end},
[3] = 	{vars = function() return (ChatWindowManager ~= nil) end,				name = "Chat Window Manager",					run = function(opt) PUIAddon.ChatWindowManager() end},
[4] = 	{vars = function() return (LOOTDROP_DB ~= nil) end,						name = "LootDrop",								run = function(opt) PUIAddon.LootDrop() end},
[5] = 	{vars = function() return (ClockTST_Settings ~= nil) end,				name = "Clock (Tamriel Standard Time)",			run = function(opt) PUIAddon.ClockTST() end},
[6] = 	{vars = function() return (DungeonTracker ~= nil) end,					name = "Dungeon Tracker",						run = function(opt) PUIAddon.DungeonTracker() end},
[7] = 	{vars = function() return (SALTIVars ~= nil) end,						name = "SALTI",									run = function(opt) PUIAddon.SALTI() end},

[8] = 	{vars = function() return (VotansMiniMap_Data ~= nil) end,				name = "Votan's Mini Map",						run = function(opt) PUIAddon.VotansMiniMap() end},
[9] = 	{vars = function() return (ADRSV ~= nil) end,							name = "Action Duration Reminder",				run = function(opt) PUIAddon.ActionDurationReminder() end},
[10] = 	{vars = function() return (LBooks_SavedVariables ~= nil) end,			name = "LoreBooks",								run = function(opt) PUIAddon.LoreBooks() end},
[11] = 	{vars = function() return (SkyS_SavedVariables ~= nil) end,				name = "SkyShards",								run = function(opt) PUIAddon.SkyShards() end},
[12] = 	{vars = function() return (MP_SavedVars ~= nil) end,					name = "Map Pins",								run = function(opt) PUIAddon.MapPins() end},
[13] = 	{vars = function() return (ParlezPlusSavedVariables ~= nil) end,		name = "Parlez Plus",							run = function(opt) PUIAddon.ParlezPlus() end},
[14] = 	{vars = function() return (RCHAT_OPTS ~= nil) end,						name = "rChat",									run = function(opt) PUIAddon.rChat() end},
[15] = 	{vars = function() return (Postmaster ~= nil) end,						name = "Postmaster",							run = function(opt) PUIAddon.Postmaster() end},
[16] = 	{vars = function() return (Harvest_SavedVars ~= nil) end,				name = "Harvest Map",							run = function(opt) PUIAddon.HarvestMap(opt) end},
[17] = 	{vars = function() return (CMLD_SavedVariables ~= nil) end,				name = "Crafting Material Level Display",		run = function(opt) PUIAddon.CraftingMaterialLevelDisplay() end},
[18] = 	{vars = function() return (AutoRecharge_SavedVariables ~= nil) end,		name = "Auto Recharge",							run = function(opt) PUIAddon.Recharge() end},
[19] = 	{vars = function() return (VotansFisherman_Data ~= nil) end,			name = "Votan's Fisherman",						run = function(opt) PUIAddon.VotansFisherman() end},
[20] = 	{vars = function() return (NO_THANK_YOU_VARS ~= nil) end,				name = "No, thank you!",						run = function(opt) PUIAddon.NoThankYou() end},

}

PUIAddon.DefaultOff = {
--	["wykkyds Macros"] = true,

}

PUIAddon.Dependencies = {

}

function PUIAddon.GetSorted(sTable, sMode, sFunc)	-- Returns an indexed table of sorted values based on selection (key/value/sub-value).

-- Default values:
	sMode = (sMode == nil or sMode == 1) and 1 or (sMode ~= 2) and sMode or 2

	-- Special case for sorting by function (see LUA documentation for table.sort)
	local function FunctionSort(tbl, sortFunction)
		local keys = {}
		for key in pairs(tbl) do
			table.insert(keys, key)
		end
		table.sort(keys, function(a, b)
			return sortFunction(tbl[a], tbl[b])
		end)
		return keys
	end
	if sFunc ~= nil then
		local fSorted = FunctionSort(sTable, sFunc)
		return fSorted
	end

	local oTable = {}

	if sMode == 1 then
		local iTable = {}
		for k, v in pairs(sTable) do
			iTable[#iTable + 1] = v
		end
		table.sort(iTable)
		oTable = iTable
	elseif sMode == 2 then
		local iTable = {}
		for k, v in pairs(sTable) do
			iTable[#iTable + 1] = k
		end
		table.sort(iTable)
		oTable = iTable
	else
		local iTable = {}
		for k, v in pairs(sTable) do
			iTable[#iTable + 1] = v[sMode]
		end
		table.sort(iTable)
		oTable = iTable
	end

	return oTable
end

function PUIAddon.TColor(color, text) -- Wraps the color tags with the passed color around the given text.
	local cText = "|c"..tostring(color)..tostring(text).."|r"
	return cText
end

local pChars = {
	["Dar'jazad"] = "Rajhin's Echo",
	["Quantus Gravitus"] = "Maker of Things",
	["Nina Romari"] = "Sanguine Coalescence",
	["Valyria Morvayn"] = "Dragon's Teeth",
	["Sanya Lightspear"] = "Thunderbird",
	["Divad Arbolas"] = "Gravity of Words",
	["Dro'samir"] = "Dark Matter",
	["Irae Aundae"] = "Prismatic Inversion",
	["Quixoti'coatl"] = "Time Toad",
	["Cythirea"] = "Mazken Stormclaw",
	["Fear-No-Pain"] = "Soul Sap",
	["Wax-in-Winter"] = "Cold Blooded",
	["Nateo Mythweaver"] = "In Strange Lands",
	["Cindari Atropa"] = "Dragon's Breath",
	["Kailyn Duskwhisper"] = "Nowhere's End",
	["Draven Blightborn"] = "From Outside",
	["Lorein Tarot"] = "Entanglement",
	["Koh-Ping"] = "Global Cooling",
}

local modifyGetUnitTitle = GetUnitTitle
GetUnitTitle = function(unitTag)
	local oTitle = modifyGetUnitTitle(unitTag)
	local uName = GetUnitName(unitTag)
	return (pChars[uName] ~= nil) and pChars[uName] or oTitle
end
