
-- Furnisher Documents

local addon = Unboxer
local class = addon:Namespace("rules.vendor")
local rules = addon.classes.rules
local knownIds
local debug = false
local submenu = GetString(SI_GAMEPAD_VENDOR_CATEGORY_HEADER)

class.Furnisher = addon.classes.Rule:Subclass()
function class.Furnisher:New()
    return addon.classes.Rule.New(
        self, 
        {
            name          = "furnisher",
            exampleItemIds = {
                134682, -- [Clockwork Journeyman Furnisher's Document]
                134683, -- [Morrowind Master Furnisher's Document]
            },
            dependencies = { "excluded2" },
            submenu       = submenu,
            title         = GetString(SI_UNBOXER_FURNISHER),
            knownIds      = knownIds,
        })
end

function class.Furnisher:Match(data)
    
    -- if data.bindType == BIND_TYPE_ON_PICKUP 
       -- and (addon:StringContainsStringIdOrDefault(data.flavorText, SI_UNBOXER_FURNISHING_LOWER)
            -- or addon:StringContainsStringIdOrDefault(data.name, SI_UNBOXER_FOLIO_LOWER))
    -- then
        -- return true
    -- end
end

knownIds = {
  [121364]=1,[127106]=1,[134683]=1,[134684]=1,[153621]=1,[153622]=1,
  [153623]=1,[153888]=1,[159653]=1,[159654]=1,[171568]=1,[171569]=1,
  [171571]=1,[171572]=1,[171573]=1,[171574]=1,[171575]=1,[171753]=1,
  [171754]=1,[171778]=1,[171808]=1,[181612]=1,[214255]=1,[214256]=1,
  [214257]=1,[211091]=1,[211090]=1,[211092]=1,[184190]=1,[184191]=1,
  [190122]=1,[190123]=1,[190870]=1,[194430]=1,[198598]=1,[198599]=1,
  [204500]=1,[204501]=1,
  [224293]=1, --Solstice Journeyman Furnisher's Document
  [224294]=1, --Solstice Master Furnisher's Document
[224665]=1,  --Unidentified Blackfeather Flight Item
[224666]=1,  --Unidentified Lamp Knight's Art Item
[224667]=1,  --Unidentified Arkay's Clarity Item
}