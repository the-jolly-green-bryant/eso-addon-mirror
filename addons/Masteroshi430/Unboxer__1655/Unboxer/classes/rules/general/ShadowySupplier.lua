
-- Bequeather / Shadowy Supplier

local addon = Unboxer
local class = addon:Namespace("rules.general")
local knownIds
local debug = false
local submenu = GetString(SI_GAMEPLAY_OPTIONS_GENERAL)

class.ShadowySupplier = addon.classes.Rule:Subclass()
function class.ShadowySupplier:New()
    return addon.classes.Rule.New(
        self, 
        {
            name           = "shadowysupplier",
            exampleItemIds = {
                79677, -- [Assassin's Potion Kit]
                79675, -- [Toxin Satchel]
                79504, -- [Unmarked Sack]
            },
            dependencies   = { "excluded2" },
            submenu        = submenu,
            title          = GetString(SI_UNBOXER_SHADOWY_SUPPLIER),
            knownIds       = knownIds,
        })
end

function class.ShadowySupplier:Match(data)
    -- Use :MatchKnownIds()
end

knownIds = {
  [79504]=1,[79675]=1,[79677]=1,
}