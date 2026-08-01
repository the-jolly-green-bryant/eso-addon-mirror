
-- Lore Book Reprints

local addon = Unboxer
local class = addon:Namespace("rules.vendor")
local rules = addon.classes.rules
local knownIds
local debug = false
local submenu = GetString(SI_GAMEPAD_VENDOR_CATEGORY_HEADER)

class.LoreLibraryReprints  = addon.classes.Rule:Subclass()
function class.LoreLibraryReprints:New()
    return addon.classes.Rule.New(
        self, 
        {
            name           = "reprints",
            exampleItemIds = {
                120384, -- [Guild Reprint: Daedric Princes]
                126792, -- [Temple Doctrine: The 36 Lessons]
            },
            dependencies  = { "excluded", "festival", "furnisher" },
            submenu        = submenu,
            title          = GetString(SI_UNBOXER_REPRINTS),
            knownIds       = knownIds,
        })
end

function class.LoreLibraryReprints:Match(data)
    
    -- if data.bindType == BIND_TYPE_ON_PICKUP 
       -- and string.find(data.icon, 'book') 
       -- and not string.find(data.icon, 'lore_book4_detail4_color2')
    -- then
        -- return true
    -- end
end

knownIds = {
  [120377]=1,[120378]=1,[120379]=1,[120380]=1,[120381]=1,[120382]=1,
  [120383]=1,[120384]=1,[120385]=1,[120386]=1,[120387]=1,[120388]=1,
  [120389]=1,[120390]=1,[120391]=1,[120392]=1,[120393]=1,[120394]=1,
  [120395]=1,[120396]=1,[120397]=1,[120398]=1,[120399]=1,[120400]=1,
  [120401]=1,[120402]=1,[120403]=1,[120404]=1,[120405]=1,[126792]=1,
  [134547]=1,[145596]=1,[167353]=1,
}