
-- Archival Fortunes Containers, Purse, Pouch

local addon = Unboxer
local class = addon:Namespace("rules.currency")
local knownIds
local debug = false
local submenu = GetString(SI_INVENTORY_MODE_CURRENCY)

class.ArchivalFortunes = addon.classes.Rule:Subclass()
function class.ArchivalFortunes:New()
    return addon.classes.Rule.New(
        self, 
        {
            name           = "fortunes",
            exampleItemIds = {
                203614, -- [Archival Fortunes Container]
                203832, -- [Archival Fortunes Purse]
				203891, -- [Archival Fortunes Pouch]				
            },
            dependencies   = { "excluded2" },
            submenu        = submenu,
            title          = GetString(SI_UNBOXER_ARCHIVAL_FORTUNES),
            knownIds       = knownIds,
        })
end

function class.ArchivalFortunes:Match(data)
    
    -- Exclude PTS containers
    if data.flavorText == "" 
       or data.bindType ~= BIND_TYPE_ON_PICKUP
    then
        return
    end
    
    -- Containers, Purse, Pouch types of Archival Fortunes
    if addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_ARCHIVAL_FORTUNES_LOWER) then
        return true
    end
end

knownIds = {
  [203614]=1,[203832]=1,[203891]=1,[203892]=1, [203893]=1,
}