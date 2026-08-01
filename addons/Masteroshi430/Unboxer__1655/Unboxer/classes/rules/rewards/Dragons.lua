
-- Dragons

local addon = Unboxer
local class = addon:Namespace("rules.rewards")
local rules = addon.classes.rules
local knownIds
local debug = false
local submenu = GetString(SI_UNBOXER_QUEST_REWARDS)

class.Dragons  = addon.classes.Rule:Subclass()
function class.Dragons:New()
    return addon.classes.Rule.New(
        self, 
        {
            name          = "dragons",
            exampleItemId = 150700, -- [Half-Digested Adventurer's Backpack]
            submenu       = submenu,
            title         = GetString(SI_UNBOXER_DRAGONS),
            knownIds      = knownIds,
        })
end

function class.Dragons:Match(data)
    
    -- -- Match dragon attack drops
    -- if string.find(data.icon, "digested") then
        -- return true
    -- end
end

knownIds = {
  [150700]=1,[150721]=1,[151936]=1,[156535]=1,[156810]=1,
}