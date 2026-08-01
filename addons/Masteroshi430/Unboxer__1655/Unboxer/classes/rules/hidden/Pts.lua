local addon = Unboxer
local class = addon:Namespace("rules.hidden")
local knownIds
local debug = false

-- PTS
class.Pts = addon.classes.Rule:Subclass()
function class.Pts:New()
    return addon.classes.Rule.New(
        self, 
        {
            name = "pts",
            dependencies = {
                "companions",
                "dungeon",
                "excluded2",
                "fishing",
                "materials",
                "outfitstyles",
                "solorepeatable",
                "reprints",
                "runeboxes",
                "solo",
                "solorepeatable",
                "transmutation",
                "treasuremaps",
                "trial",
                "vendorgear",
            },
            hidden = true,
            knownIds = knownIds,
        })
end

function class.Pts:Match(data)
    -- if (string.find(data.icon, "quest_container_001") -- misc containers
        -- and data.quality < ITEM_FUNCTIONAL_QUALITY_ARTIFACT)
       -- or GetItemLinkSetInfo(data.itemLink) -- if item set information is displayed on the container, even after all the tel-var merchant containers are processed, assume PTS box
       -- or data.flavorText == "" -- if flavorText is still empty after processing dependencies, assume PTS box
       -- or data.bindType == BIND_TYPE_NONE -- character-bound
    -- then
        -- return true
    -- end
end

knownIds = {
  [74686]=1,[81221]=1,[134665]=1,[134666]=1,[134667]=1,[140413]=1,
  [140414]=1,[153878]=1,[178398]=1,[178399]=1,[178400]=1,[178401]=1,
  [178402]=1,[178403]=1,[178404]=1,[178405]=1,[178406]=1,
  [192434]=1,[217948]=1,
}