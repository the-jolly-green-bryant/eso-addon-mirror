
-- Tribute

local addon = Unboxer
local class = addon:Namespace("rules.rewards")
-- local rules = addon.classes.rules
local knownIds
local debug = false
local submenu = GetString(SI_UNBOXER_QUEST_REWARDS)

class.Tribute  = addon.classes.Rule:Subclass()
function class.Tribute:New()
    return addon.classes.Rule.New(
        self, 
        {
            name          = "tribute",
            exampleItemIds = {
			 187908, -- [Tribute Victory]
			 190362, -- [Master's Purse]
			 187908, -- [Cardsharp's Purse]
			 },
            submenu       = submenu,
            title         = GetString(SI_UNBOXER_TRIBUTE),
            knownIds      = knownIds,
        })
end

function class.Tribute:Match(data)
    -- Use :MatchKnownIds()
end

knownIds = {
    [187909]=1, [187908]=1, [187910]=1, [187911]=1, [190362]=1, [193775]=1, [193776]=1, [193777]=1, [193778]=1,
}