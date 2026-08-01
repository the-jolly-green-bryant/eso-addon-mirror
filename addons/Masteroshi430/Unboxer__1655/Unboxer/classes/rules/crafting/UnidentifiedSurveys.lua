
-- UnidentifiedSurveys

local addon = Unboxer
local class = addon:Namespace("rules.crafting")
local knownIds
local debug = false
local submenu = GetString("SI_QUESTTYPE", QUEST_TYPE_CRAFTING)

class.UnidentifiedSurveys = addon.classes.Rule:Subclass()
function class.UnidentifiedSurveys:New()
    return addon.classes.Rule.New(
        self, 
        {
            name          = "unidentifiedsurveys",
            exampleItemIds = {
                219849, -- [Unidentified Blacksmith Survey Report]
                219850, -- [Unidentified Clothier Survey Report]
				219851, -- [Unidentified Woodworker Survey Report]
				
            },
            dependencies  = { "excluded2" },
            submenu       = submenu,
            title         = GetString(SI_UNBOXER_UNIDENTIFIED_SURVEYS),
            knownIds      = knownIds,
        })
end

function class.UnidentifiedSurveys:Match(data)

end

knownIds = {
  [219849]=1,[219850]=1,[219851]=1,[219852]=1,[219853]=1,[219854]=1,
  [224707]=1, --Sealed Survey Report Stack
}
