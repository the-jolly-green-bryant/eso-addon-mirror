local LEJ = LibExtendedJournal

LEJ.Used = true

CollectiblesTracker = {
	name = "CollectiblesTracker",

	-- Default settings
	defaults = {
		ct = { filterId = 1, hide = { } },
		ec = { filterId = 1, hide = { } },
	},

	data = { },
	dataGen = { },
}
local CollectiblesTracker = CollectiblesTracker

local function OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= CollectiblesTracker.name) then return end

	EVENT_MANAGER:UnregisterForEvent(CollectiblesTracker.name, EVENT_ADD_ON_LOADED)

	CollectiblesTracker.vars = ZO_SavedVars:NewAccountWide("CollectiblesTrackerSavedVariables", 1, nil, CollectiblesTracker.defaults, nil, "$InstallationWide")

	CollectiblesTracker.InitializeBrowser()

	ZO_CreateStringId("SI_BINDING_NAME_HOLIDAY_MEMENTO", string.format("%s: %s", GetString(SI_EVENTCOLLECTIBLES_TITLE), GetString(SI_EVENTCOLLECTIBLES_CAKE)))
end

function CollectiblesTracker.SummonCake( )
	for _, collectibleId in ipairs(CollectiblesTracker.data.cakes) do
		if (IsCollectibleUnlocked(collectibleId)) then
			UseCollectible(collectibleId)
			return
		end
	end
end

EVENT_MANAGER:RegisterForEvent(CollectiblesTracker.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
