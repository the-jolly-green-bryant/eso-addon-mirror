AUI_FightData = {}

local gAddonName = "AUI_FightData"
local gAddonVersion = 1

local function GetDefaultFightData()
	local data =
	{
		records = {}
	}

	return data
end

local function Initialize(event, addon)

	if addon ~= gAddonName then return end

	EVENT_MANAGER:UnregisterForEvent(gAddonName, EVENT_ADD_ON_LOADED)

	AUI_FightData = ZO_SavedVars:NewAccountWide("AUI_Fights", gAddonVersion, nil, GetDefaultFightData())	
end

EVENT_MANAGER:RegisterForEvent(gAddonName, EVENT_ADD_ON_LOADED, function(...) Initialize(...) end)