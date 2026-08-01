SetContainerCollector = SetContainerCollector or {}
local SCC = SetContainerCollector
SCC.Data = SCC.Data or {}

local RS = SCC.Data.RegisterSets

local BG_SETS = { 326, 327, 328, 329 }

local WEAPONS = {
  { 126093, "Unknown Battleground Axe", WEAPONTYPE_AXE, EQUIP_TYPE_ONE_HAND },
  { 126094, "Unknown Battleground Maul", WEAPONTYPE_TWO_HANDED_HAMMER, nil },
  { 126095, "Unknown Battleground Sword", WEAPONTYPE_SWORD, EQUIP_TYPE_ONE_HAND },
  { 126096, "Unknown Battleground Battleaxe", WEAPONTYPE_TWO_HANDED_AXE, nil },
  { 126097, "Unknown Battleground Mace", WEAPONTYPE_HAMMER, EQUIP_TYPE_ONE_HAND },
  { 126098, "Unknown Battleground Greatsword", WEAPONTYPE_TWO_HANDED_SWORD, nil },
  { 126099, "Unknown Battleground Dagger", WEAPONTYPE_DAGGER, nil },
  { 126100, "Unknown Battleground Bow", WEAPONTYPE_BOW, nil },
  { 126101, "Unknown Battleground Inferno Staff", WEAPONTYPE_FIRE_STAFF, nil },
  { 126102, "Unknown Battleground Ice Staff", WEAPONTYPE_FROST_STAFF, nil },
  { 126103, "Unknown Battleground Lightning Staff", WEAPONTYPE_LIGHTNING_STAFF, nil },
  { 126104, "Unknown Battleground Restoration Staff", WEAPONTYPE_HEALING_STAFF, nil },
  { 126105, "Unknown Battleground Shield", WEAPONTYPE_SHIELD, nil },
}

for _, entry in ipairs(WEAPONS) do
  RS(entry[1], entry[2], BG_SETS, {
    weaponType = entry[3],
    equipSlot = entry[4],
  })
end
