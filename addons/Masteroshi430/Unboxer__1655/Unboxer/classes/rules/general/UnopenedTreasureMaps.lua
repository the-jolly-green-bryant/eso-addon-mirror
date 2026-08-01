
-- UnopenedTreasureMaps

local addon = Unboxer
local class = addon:Namespace("rules.general")
local knownIds
local debug = false
local submenu = GetString(SI_GAMEPLAY_OPTIONS_GENERAL)

class.UnopenedTreasureMaps = addon.classes.Rule:Subclass()
function class.UnopenedTreasureMaps:New()
    return addon.classes.Rule.New(
        self, 
        {
            name          = "unopenedtreasuremaps",
            exampleItemIds = {
               224681,  --Unopened Treasure Map
				
            },
            dependencies  = { "excluded2" },
            submenu       = submenu,
            title         = GetString(SI_UNBOXER_UNOPENED_TREASURE_MAPS),
            knownIds      = knownIds,
        })
end

function class.UnopenedTreasureMaps:Match(data)

end

knownIds = {
[224681]=1,  --Unopened Treasure Map
}
