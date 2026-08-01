
-- Tel Var Sachels/Crates

local addon = Unboxer
local class = addon:Namespace("rules.currency")
local knownIds
local debug = false
local submenu = GetString(SI_INVENTORY_MODE_CURRENCY)

class.TelVar = addon.classes.Rule:Subclass()
function class.TelVar:New()
    return addon.classes.Rule.New(
        self, 
        {
            name           = "telvar",
            exampleItemIds = {
                69413, -- [Light Tel Var Satchel]
                69433, -- [Scamp's Tel Var Sack]
            },
            dependencies   = { "excluded2" },
            submenu        = submenu,
            title          = GetString(SI_UNBOXER_TEL_VAR_STONES),
            knownIds       = knownIds,
        })
end

function class.TelVar:Match(data)
    
    -- Exclude PTS containers
    if data.flavorText == "" 
       or data.bindType ~= BIND_TYPE_ON_PICKUP
    then
        return
    end
    
    -- Light, Medium and Heavy Tel Var sacks
    if addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_TEL_VAR_LOWER) then
        return true
    end
end

knownIds = {
  [69413]=1,[69414]=1,[69415]=1,[69433]=1,
}