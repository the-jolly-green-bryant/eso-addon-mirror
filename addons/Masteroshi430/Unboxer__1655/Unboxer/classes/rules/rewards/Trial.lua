
-- Trials

local addon = Unboxer
local class = addon:Namespace("rules.rewards")
local knownIds
local debug = false
local submenu = GetString(SI_UNBOXER_QUEST_REWARDS)

class.Trial = addon.classes.Rule:Subclass()
function class.Trial:New()
    return addon.classes.Rule.New(
        self, 
        {
            name           = "trial",
            exampleItemIds = {
                151970, -- [Dragon God's Time-Worn Hoard]
                139668, -- [Mage's Knowledgeable Coffer]
				188134, -- [Taleria's Sundry Treasure]
            },
            dependencies   = { "excluded2" },
            submenu        = submenu,
            title          = GetString("SI_RAIDCATEGORY", RAID_CATEGORY_TRIAL),
            knownIds       = knownIds,
        })
end

function class.Trial:Match(data)
  
    -- if addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_UNDAUNTED_LOWER)
       -- and addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_WEEKLY_LOWER)
    -- then
        -- return true
    -- end
end

knownIds = {
  [54993]=1,[55773]=1,[56931]=1,[57850]=1,[81187]=1,[81188]=1,
  [87702]=1,[87703]=1,[87705]=1,[87706]=1,[87707]=1,[87708]=1,
  [94089]=1,[94090]=1,[126130]=1,[126131]=1,[134585]=1,[134586]=1,
  [138711]=1,[138712]=1,[139664]=1,[139665]=1,[139666]=1,[139667]=1,
  [139668]=1,[139669]=1,[139670]=1,[139671]=1,[139672]=1,[139673]=1,
  [139674]=1,[139675]=1,[141738]=1,[141739]=1,[151970]=1,[151971]=1,
  [165421]=1,[165422]=1,[176054]=1,[176055]=1,[188134]=1,
[188139]=1,
[197827]=1,
[197828]=1,
[204820]=1,
[204821]=1,
[204822]=1,
[204823]=1,
[204824]=1,
[204825]=1,
[204826]=1,
[204827]=1,
[204828]=1,
[204829]=1,
[204830]=1,
[204831]=1,
[204832]=1,
[204833]=1,
[204834]=1,
[204835]=1,
[207944]=1,
[207945]=1,
}