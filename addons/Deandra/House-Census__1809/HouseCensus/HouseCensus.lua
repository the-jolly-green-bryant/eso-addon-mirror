-- Addon info
local AddonName = "HouseCensus"

local function OnEventHousingCensusChanged(eventCode, newPopulation)
    d("Housing population changed to "..newPopulation..".")
end

local function PrintHouseCensus()
    d("There are ".. GetCurrentHousePopulation() .. " out of a possible " .. GetCurrentHousePopulationCap() .. " players in this home.")
end

local function AllHousesInfo()
	for i=1,70 do
		local name,description,icon,lockedIcon,unlocked,purchasable,isActive,Collectible,categoryType,hint,isPlaceholder = GetCollectibleInfo(GetCollectibleIdForHouse(i))
		d(i .. ": " .. name)
	end
end

SLASH_COMMANDS["/census"]=PrintHouseCensus
SLASH_COMMANDS["/listhome"]=AllHousesInfo

EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_HOUSING_POPULATION_CHANGED, OnEventHousingCensusChanged)