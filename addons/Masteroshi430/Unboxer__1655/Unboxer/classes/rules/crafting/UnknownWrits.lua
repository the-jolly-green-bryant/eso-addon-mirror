
-- UnknownWrits

local addon = Unboxer
local class = addon:Namespace("rules.crafting")
local knownIds
local debug = false
local submenu = GetString("SI_QUESTTYPE", QUEST_TYPE_CRAFTING)

class.UnknownWrits = addon.classes.Rule:Subclass()
function class.UnknownWrits:New()
    return addon.classes.Rule.New(
        self, 
        {
            name          = "unknownwrits",
            exampleItemIds = {
                217917, -- [Unknown blacksmith Writ]
                217918, -- [Unknown clothier Writ]
				217921, -- [Unknown provisioning Writ]
				
            },
            dependencies  = { "excluded2" },
            submenu       = submenu,
            title         = GetString(SI_UNBOXER_UNKNOWN_WRITS),
            knownIds      = knownIds,
        })
end

function class.UnknownWrits:Match(data)

end

knownIds = {
  [217917]=1,[217918]=1,[217919]=1,[217920]=1,[217921]=1,[217922]=1,
  [217923]=1,
}
