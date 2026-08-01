
local SubmoduleManager = {}
Harvest:RegisterModule("submoduleManager", SubmoduleManager)

local addOnNameToPotentialSubmodule = {
	HarvestMapAD = {
		displayName = "HarvestMap-AD-Zones",
		savedVarsName = "HarvestAD_SavedVars",
		downloadedVarsName = "HarvestAD_Data",
		zones = {
			["auridon"] = true,
			["grahtwood"] = true,
			["greenshade"] = true,
			["malabaltor"] = true,
			["reapersmarch"] = true,
		},
	},
	HarvestMapEP = {
		displayName = "HarvestMap-EP-Zones",
		savedVarsName = "HarvestEP_SavedVars",
		downloadedVarsName = "HarvestEP_Data",
		zones = {
			["bleakrock"] = true,
			["stonefalls"] = true,
			["deshaan"] = true,
			["shadowfen"] = true,
			["eastmarch"] = true,
			["therift"] = true,
			["balfoyen"] = true,
		},
	},
	HarvestMapDC = {
		displayName = "HarvestMap-DC-Zones",
		savedVarsName = "HarvestDC_SavedVars",
		downloadedVarsName = "HarvestDC_Data",
		zones = {
			["glenumbra"] = true,
			["stormhaven"] = true,
			["rivenspire"] = true,
			["alikr"] = true,
			["bangkorai"] = true,
		},
	},
	HarvestMapDLC = {
		displayName = "HarvestMap-DLC-Zones",
		savedVarsName = "HarvestDLC_SavedVars",
		downloadedVarsName = "HarvestDLC_Data",
	},
	HarvestMapNF = {
		displayName = "HarvestMap-NoFaction-Zones",
		savedVarsName = "HarvestNF_SavedVars",
		downloadedVarsName = "HarvestNF_Data",
		zones = {
			["cyrodiil"] = true,
			["craglorn"] = true,
			["coldharbor"] = true,
			["main"] = true,
		},
	},
}

function SubmoduleManager:Initialize()
	self.submodules = {}
	
	for addOnName, submodule in pairs(addOnNameToPotentialSubmodule) do
		self.submodules[addOnName] = submodule
		-- load the savedVars
		_G[submodule.savedVarsName] = _G[submodule.savedVarsName] or {}
		submodule.savedVars = _G[submodule.savedVarsName]
		-- load downloaded data
		submodule.downloadedVars = _G[submodule.downloadedVarsName] or {}
	end
	
end

-- returns the correct table for the map (HarvestMap, HarvestMapAD/DC/EP save file tables)
-- may return nil if the submodule for the given map is not loaded
function SubmoduleManager:GetSubmoduleForMap(map)
	
	-- split of the zone prefic of the given map name
	local zoneName = string.gsub(map, "/.*$", "" )
	
	-- check if the zone belongs to one of the submodules
	for addOnName, submodule in pairs(addOnNameToPotentialSubmodule) do
		if submodule.zones and submodule.zones[zoneName] then
			-- the module does match the given map, however it might not be loaded
			-- so we need to additionally check if there exist savedVars for that module
			if submodule.savedVars then
				return submodule
			else
				return nil
			end
		end
	end
	
	-- otherwise return the NF module
	-- note that this may be nil if the NF module is not loaded
	return self.submodules["HarvestMapDLC"]
	
end
