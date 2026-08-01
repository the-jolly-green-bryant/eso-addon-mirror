local RegisterForEvent = sidWarTools.RegisterForEvent
local UnregisterForEvent = sidWarTools.UnregisterForEvent
local WrapFunction = sidWarTools.WrapFunction

local function Initialize(saveData)
	if(saveData.showObjectiveLevel) then
		local keepIdByName = {}
		for id = 1, GetNumKeeps() do
			keepIdByName[GetKeepName(id)] = id
		end
		
		local originalGetKeepName = GetKeepName
		local function GetKeepNameAndLevel(keepId)
			local keepName = originalGetKeepName(keepId)
			local keepType = GetKeepType(keepId)
			if(keepType == KEEPTYPE_RESOURCE) then
				local _, bgQueryType = GetKeepKeysByIndex(1)
				return string.format("%s (Lv. %d)", keepName, GetKeepDefensiveLevel(keepId, bgQueryType))
			elseif(keepType == KEEPTYPE_KEEP) then
				local _, bgQueryType = GetKeepKeysByIndex(1)
				local woodLevel = GetKeepResourceLevel(keepId, bgQueryType, RESOURCETYPE_WOOD)
				local foodLevel = GetKeepResourceLevel(keepId, bgQueryType, RESOURCETYPE_FOOD)
				local oreLevel = GetKeepResourceLevel(keepId, bgQueryType, RESOURCETYPE_ORE)
				return string.format("%s (Lv. %d/%d/%d)", keepName, woodLevel, foodLevel, oreLevel)
			end

			return keepName
		end

		local function KeepNameWrapper(originalFunction, ...)
			originalGetKeepName = GetKeepName
			GetKeepName = GetKeepNameAndLevel
			originalFunction(...)
			GetKeepName = originalGetKeepName
		end
		
		local tooltip = ZO_KeepTooltip
		WrapFunction(tooltip, "SetKeep", KeepNameWrapper)
		WrapFunction(tooltip, "RefreshKeepInfo", KeepNameWrapper)

		local isPinTypeResourceOrKeep = {
			[MAP_PIN_TYPE_MILL_ALDMERI_DOMINION] = true,
			[MAP_PIN_TYPE_MILL_DAGGERFALL_COVENANT] = true,
			[MAP_PIN_TYPE_MILL_EBONHEART_PACT] = true,
			[MAP_PIN_TYPE_MILL_NEUTRAL] = true,
			[MAP_PIN_TYPE_MINE_ALDMERI_DOMINION] = true,
			[MAP_PIN_TYPE_MINE_DAGGERFALL_COVENANT] = true,
			[MAP_PIN_TYPE_MINE_EBONHEART_PACT] = true,
			[MAP_PIN_TYPE_MINE_NEUTRAL] = true,
			[MAP_PIN_TYPE_FARM_ALDMERI_DOMINION] = true,
			[MAP_PIN_TYPE_FARM_DAGGERFALL_COVENANT] = true,
			[MAP_PIN_TYPE_FARM_EBONHEART_PACT] = true,
			[MAP_PIN_TYPE_FARM_NEUTRAL] = true,
			[MAP_PIN_TYPE_KEEP_ALDMERI_DOMINION] = true,
			[MAP_PIN_TYPE_KEEP_DAGGERFALL_COVENANT] = true,
			[MAP_PIN_TYPE_KEEP_EBONHEART_PACT] = true,
			[MAP_PIN_TYPE_KEEP_NEUTRAL] = true,
		}

		WrapFunction(COMPASS.container, "GetCenterOveredPinInfo", function(originalGetCenterOveredPinInfo, self, index)
			local description, pinType, distance, drawLayer, drawLevel, isSupressed = originalGetCenterOveredPinInfo(self, index)
			if(isPinTypeResourceOrKeep[pinType] and keepIdByName[description]) then
				description = GetKeepNameAndLevel(keepIdByName[description])
			end
			return description, pinType, distance, drawLayer, drawLevel, isSupressed
		end)
	end
end

sidWarTools.InitializeObjectiveLevelDisplay = Initialize
