
-- Companions

local addon = Unboxer
local class = addon:Namespace("rules.general")
local knownIds
local debug = false
local submenu = GetString(SI_GAMEPLAY_OPTIONS_GENERAL)

class.Companions = addon.classes.Rule:Subclass()
function class.Companions:New()
    return addon.classes.Rule.New(
        self, 
        {
            name           = "companions",
            exampleItemIds = {
                178470, -- [Hidden Treasure Bag]
				188144, -- [Fallen Knight's Pack]
				187747, -- [Hidden Wallet]
            },
            dependencies   = { "excluded2" },
            submenu        = submenu,
            title          = GetString(SI_MAPFILTER14),
            knownIds       = knownIds,
        })
end

function class.Companions:Match(data)
    -- TODO: match companion names here?  Can't say until the localizations are done.
end

knownIds = {
  [178412]=1,[178413]=1,[178470]=1,[188144]=1,[187747]=1,
  [197789]=1,[197790]=1,[212167]=1,[212168]=1, [188135]=1, 
  }