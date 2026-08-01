
-- Materials

local addon = Unboxer
local class = addon:Namespace("rules.crafting")
local knownIds
local debug = false
local submenu = GetString("SI_QUESTTYPE", QUEST_TYPE_CRAFTING)

class.Materials = addon.classes.Rule:Subclass()
function class.Materials:New()
    return addon.classes.Rule.New(
        self, 
        {
            name          = "materials",
            exampleItemIds = {
                142147, -- [Shipment of Cloth V]
                115712, -- [Waxed Apothecary's Parcel]
				208146, -- [West Weald Lumber Supplies]
            },
            dependencies  = { "excluded2" },
            submenu       = submenu,
            title         = GetString("SI_SMITHINGFILTERTYPE", SMITHING_FILTER_TYPE_RAW_MATERIALS),
            knownIds      = knownIds,
        })
end

function class.Materials:Match(data)
    
    if data.bindType ~= BIND_TYPE_ON_PICKUP or data.quality > ITEM_FUNCTIONAL_QUALITY_ARCANE then
        return
    end
    
    if addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_RAW_MATERIAL_LOWER)
       or addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_FOR_CRAFTING_LOWER)
       or addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_WAXED_LOWER)
       or addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_WAXED2_LOWER)
    then
        return true
    end
end
knownIds = {
  [99246]=1,[99247]=1,[99248]=1,[99249]=1,[99250]=1,[99251]=1,
  [99252]=1,[99253]=1,[99254]=1,[99256]=1,[99257]=1,[99258]=1,
  [99259]=1,[99260]=1,[99261]=1,[99262]=1,[99263]=1,[99264]=1,
  [99265]=1,[99266]=1,[99267]=1,[99268]=1,[99269]=1,[99270]=1,
  [99271]=1,[99272]=1,[99273]=1,[99274]=1,[99275]=1,[99276]=1,
  [99277]=1,[99278]=1,[99279]=1,[99280]=1,[99281]=1,[99282]=1,
  [115712]=1,[134979]=1,[134980]=1,[134981]=1,[134988]=1,[134989]=1,
  [134990]=1,[134991]=1,[134992]=1,[134993]=1,[134994]=1,[134995]=1,
  [134996]=1,[134997]=1,[138816]=1,[138817]=1,[138818]=1,[138819]=1,
  [138820]=1,[138821]=1,[138822]=1,[138823]=1,[138824]=1,[140460]=1,
  [142134]=1,[142135]=1,[142136]=1,[142137]=1,[142138]=1,[142139]=1,
  [142140]=1,[142141]=1,[142142]=1,[142143]=1,[142144]=1,[142145]=1,
  [142146]=1,[142147]=1,[142148]=1,[142149]=1,[142150]=1,[142151]=1,
  [142152]=1,[142153]=1,[142154]=1,[142155]=1,[142156]=1,[142157]=1,
  [142158]=1,[142159]=1,[142160]=1,[142161]=1,[142162]=1,[142163]=1,
  [142164]=1,[142165]=1,[142166]=1,[142167]=1,[142168]=1,[142169]=1,
  [142170]=1,[142171]=1,[142172]=1,[142173]=1,[142174]=1,[142175]=1,
  [142176]=1,[142177]=1,[147603]=1,[208146]=1,[208147]=1,[212219]=1,
  [212247]=1,[212248]=1,[212249]=1,
[204813]=1,
[204815]=1,
[204816]=1,
[204817]=1,
[204819]=1,
[212219]=1,
[212230]=1,
[212238]=1,
[212247]=1,
[212248]=1,
[212249]=1,
[212251]=1,
[212252]=1,
[224709]=1,
[225244]=1, --Veterancy Crafting Satchel
[225245]=1, --Veterancy Crafting Bag
[225246]=1, --Veterancy Crafting Pouch
}