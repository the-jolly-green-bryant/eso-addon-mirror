-- SatuveXboxUI Resource Navigator - data layer
--
-- ESO does not expose a live list of harvest-node positions.  This module is
-- intentionally independent from route calculation so bundled or third-party
-- datasets can be registered later without changing the navigator.

BUI.ResourceData = BUI.ResourceData or {}
local Data = BUI.ResourceData

Data.SchemaVersion = 1
Data.Revision = Data.Revision or 0
Data.Datasets = Data.Datasets or {}
Data.Providers = Data.Providers or {}
Data.ProviderErrors = Data.ProviderErrors or {}

Data.Categories = {
	ORE = "ORE",
	WOOD = "WOOD",
	CLOTHING = "CLOTHING",
	ALCHEMY = "ALCHEMY",
	RUNES = "RUNES",
}

Data.CategoryNames = {
	ORE = "Ore / Blacksmithing",
	WOOD = "Wood",
	CLOTHING = "Clothing",
	ALCHEMY = "Alchemy Plant",
	RUNES = "Runestone",
}

local aliases = {
	ORE="ORE", BLACKSMITHING="ORE", JEWELRY="ORE", JEWELRYCRAFTING="ORE",
	WOOD="WOOD", WOODWORKING="WOOD",
	CLOTHING="CLOTHING", CLOTHIER="CLOTHING", CLOTH="CLOTHING",
	ALCHEMY="ALCHEMY", PLANT="ALCHEMY", PLANTS="ALCHEMY", REAGENT="ALCHEMY",
	RUNES="RUNES", RUNE="RUNES", RUNESTONE="RUNES", ENCHANTING="RUNES",
}

function Data.NormalizeCategory(category)
	if type(category) ~= "string" then return nil end
	return aliases[string.upper(category)]
end

local function GetMapTable(dataset, mapId)
	if type(dataset) ~= "table" then return nil end
	local source = dataset.nodes or dataset.maps or dataset
	if type(source) ~= "table" then return nil end
	return source[mapId] or source[tostring(mapId)]
end

-- Dataset format:
-- { nodes = { [mapId] = { {x=.5, y=.5, type="ORE", ...}, ... } } }
-- Optional worldZoneId/worldX/worldZ fields improve distance accuracy.  The
-- relaxed aliases also make a future HarvestMap-style converter straightforward.
function Data.RegisterDataset(name, dataset)
	if type(name) ~= "string" or name == "" or type(dataset) ~= "table" then return false end
	Data.Datasets[name] = dataset
	Data.Revision = Data.Revision + 1
	return true
end

function Data.UnregisterDataset(name)
	if Data.Datasets[name] then
		Data.Datasets[name] = nil
		Data.Revision = Data.Revision + 1
		return true
	end
	return false
end

-- Dynamic providers are queried only while a map grid is being built, never
-- by the 40 ms HUD update.  This is used by the optional HarvestMap adapter.
function Data.RegisterProvider(name, provider)
	if type(name) ~= "string" or name == "" or type(provider) ~= "function" then return false end
	Data.Providers[name] = provider
	Data.Revision = Data.Revision + 1
	return true
end

function Data.UnregisterProvider(name)
	if Data.Providers[name] then
		Data.Providers[name] = nil
		Data.Revision = Data.Revision + 1
		return true
	end
	return false
end

function Data.NotifyProviderChanged()
	Data.Revision = Data.Revision + 1
end

function Data.GetNodes(mapId)
	local result = {}
	for datasetName, dataset in pairs(Data.Datasets) do
		local nodes = GetMapTable(dataset, mapId)
		if type(nodes) == "table" then
			for index, source in ipairs(nodes) do
				local category = Data.NormalizeCategory(source.type or source.category or source.resourceType)
				local x = tonumber(source.x or source.mapX)
				local y = tonumber(source.y or source.mapY)
				if category and x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
					result[#result + 1] = {
						id = source.id or ("data:" .. datasetName .. ":" .. tostring(mapId) .. ":" .. tostring(index)),
						mapId = tonumber(mapId), x = x, y = y, type = category,
						worldZoneId = source.worldZoneId or source.zoneId,
						worldX = tonumber(source.worldX), worldZ = tonumber(source.worldZ),
						source = datasetName,
					}
				end
			end
		end
	end
	for providerName, provider in pairs(Data.Providers) do
		local ok, nodes = pcall(provider, mapId)
		if ok and type(nodes) == "table" then
			Data.ProviderErrors[providerName] = nil
			for index, source in ipairs(nodes) do
				local category = Data.NormalizeCategory(source.type or source.category or source.resourceType)
				local x, y = tonumber(source.x or source.mapX), tonumber(source.y or source.mapY)
				if category and x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
					source.id = source.id or ("provider:" .. providerName .. ":" .. tostring(mapId) .. ":" .. tostring(index))
					source.mapId, source.x, source.y, source.type = tonumber(mapId), x, y, category
					source.source = source.source or providerName
					result[#result + 1] = source
				end
			end
		else
			Data.ProviderErrors[providerName] = ok and "provider returned no node table" or tostring(nodes)
		end
	end
	return result
end

function Data.GetRevision()
	return Data.Revision
end
