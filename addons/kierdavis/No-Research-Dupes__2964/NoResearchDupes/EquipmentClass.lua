local EquipmentClass = {}

-- None of the stock "item type" enums provide a convenient level of detail, so we define our own:
-- Smithing weapons:
EquipmentClass.AXE = 1
EquipmentClass.MACE = 2
EquipmentClass.SWORD = 3
EquipmentClass.TH_AXE = 4
EquipmentClass.TH_MACE = 5
EquipmentClass.TH_SWORD = 6
EquipmentClass.DAGGER = 7
-- Woodworking weapons:
EquipmentClass.BOW = 8
EquipmentClass.FIRE_STAFF = 9
EquipmentClass.FROST_STAFF = 10
EquipmentClass.LIGHTNING_STAFF = 11
EquipmentClass.HEALING_STAFF = 12
-- Smithing apparel:
EquipmentClass.HEAVY_CHEST = 13
EquipmentClass.HEAVY_FEET = 14
EquipmentClass.HEAVY_HAND = 15
EquipmentClass.HEAVY_HEAD = 16
EquipmentClass.HEAVY_LEGS = 17
EquipmentClass.HEAVY_SHOULDERS = 18
EquipmentClass.HEAVY_WAIST = 19
-- Clothing apparel:
EquipmentClass.MEDIUM_CHEST = 20
EquipmentClass.MEDIUM_FEET = 21
EquipmentClass.MEDIUM_HAND = 22
EquipmentClass.MEDIUM_HEAD = 23
EquipmentClass.MEDIUM_LEGS = 24
EquipmentClass.MEDIUM_SHOULDERS = 25
EquipmentClass.MEDIUM_WAIST = 26
EquipmentClass.LIGHT_CHEST = 27
EquipmentClass.LIGHT_FEET = 28
EquipmentClass.LIGHT_HAND = 29
EquipmentClass.LIGHT_HEAD = 30
EquipmentClass.LIGHT_LEGS = 31
EquipmentClass.LIGHT_SHOULDERS = 32
EquipmentClass.LIGHT_WAIST = 33
-- Woodworking apparel:
EquipmentClass.SHIELD = 34
-- Jewellery apparel:
EquipmentClass.RING = 35
EquipmentClass.NECKLACE = 36

local nameMap = {
  [EquipmentClass.AXE] = "1H axe",
  [EquipmentClass.MACE] = "1H mace",
  [EquipmentClass.SWORD] = "1H sword",
  [EquipmentClass.TH_AXE] = "2H axe",
  [EquipmentClass.TH_MACE] = "2H mace",
  [EquipmentClass.TH_SWORD] = "2H sword",
  [EquipmentClass.DAGGER] = "1H dagger",
  [EquipmentClass.BOW] = "bow",
  [EquipmentClass.FIRE_STAFF] = "fire staff",
  [EquipmentClass.FROST_STAFF] = "frost staff",
  [EquipmentClass.LIGHTNING_STAFF] = "lightning staff",
  [EquipmentClass.HEALING_STAFF] = "healing staff",
  [EquipmentClass.HEAVY_CHEST] = "heavy chest armor",
  [EquipmentClass.HEAVY_FEET] = "heavy feet armor",
  [EquipmentClass.HEAVY_HAND] = "heavy hand armor",
  [EquipmentClass.HEAVY_HEAD] = "heavy head armor",
  [EquipmentClass.HEAVY_LEGS] = "heavy leg armor",
  [EquipmentClass.HEAVY_SHOULDERS] = "heavy shoulder armor",
  [EquipmentClass.HEAVY_WAIST] = "heavy waist armor",
  [EquipmentClass.MEDIUM_CHEST] = "medium chest armor",
  [EquipmentClass.MEDIUM_FEET] = "medium feet armor",
  [EquipmentClass.MEDIUM_HAND] = "medium hand armor",
  [EquipmentClass.MEDIUM_HEAD] = "medium head armor",
  [EquipmentClass.MEDIUM_LEGS] = "medium leg armor",
  [EquipmentClass.MEDIUM_SHOULDERS] = "medium shoulder armor",
  [EquipmentClass.MEDIUM_WAIST] = "medium waist armor",
  [EquipmentClass.LIGHT_CHEST] = "light chest armor",
  [EquipmentClass.LIGHT_FEET] = "light feet armor",
  [EquipmentClass.LIGHT_HAND] = "light hand armor",
  [EquipmentClass.LIGHT_HEAD] = "light head armor",
  [EquipmentClass.LIGHT_LEGS] = "light leg armor",
  [EquipmentClass.LIGHT_SHOULDERS] = "light shoulder armor",
  [EquipmentClass.LIGHT_WAIST] = "light waist armor",
  [EquipmentClass.SHIELD] = "shield",
  [EquipmentClass.RING] = "ring",
  [EquipmentClass.NECKLACE] = "necklace",
}
function EquipmentClass.getName(ec)
  return nameMap[ec]
end

local weaponTypeMap = {
  [WEAPONTYPE_AXE] = EquipmentClass.AXE,
  [WEAPONTYPE_HAMMER] = EquipmentClass.MACE,
  [WEAPONTYPE_SWORD] = EquipmentClass.SWORD,
  [WEAPONTYPE_TWO_HANDED_AXE] = EquipmentClass.TH_AXE,
  [WEAPONTYPE_TWO_HANDED_HAMMER] = EquipmentClass.TH_MACE,
  [WEAPONTYPE_TWO_HANDED_SWORD] = EquipmentClass.TH_SWORD,
  [WEAPONTYPE_DAGGER] = EquipmentClass.DAGGER,
  [WEAPONTYPE_BOW] = EquipmentClass.BOW,
  [WEAPONTYPE_FIRE_STAFF] = EquipmentClass.FIRE_STAFF,
  [WEAPONTYPE_FROST_STAFF] = EquipmentClass.FROST_STAFF,
  [WEAPONTYPE_LIGHTNING_STAFF] = EquipmentClass.LIGHTNING_STAFF,
  [WEAPONTYPE_HEALING_STAFF] = EquipmentClass.HEALING_STAFF,
  [WEAPONTYPE_SHIELD] = EquipmentClass.SHIELD,
}
local function getWeaponOrShieldEquipmentClass(slotData)
  local weaponType = GetItemWeaponType(slotData.bagId, slotData.slotIndex)
  local equipmentClass = weaponTypeMap[weaponType]
  if equipmentClass ~= nil then
    return equipmentClass
  else
    error("unrecognised WeaponType " .. tostring(weaponType) .. " on item '" .. tostring(slotData.name) .. "'")
  end
end
local armorTypeMap = {
  [ARMORTYPE_HEAVY  * 1000 + EQUIP_TYPE_CHEST] = EquipmentClass.HEAVY_CHEST,
  [ARMORTYPE_HEAVY  * 1000 + EQUIP_TYPE_FEET] = EquipmentClass.HEAVY_FEET,
  [ARMORTYPE_HEAVY  * 1000 + EQUIP_TYPE_HAND] = EquipmentClass.HEAVY_HAND,
  [ARMORTYPE_HEAVY  * 1000 + EQUIP_TYPE_HEAD] = EquipmentClass.HEAVY_HEAD,
  [ARMORTYPE_HEAVY  * 1000 + EQUIP_TYPE_LEGS] = EquipmentClass.HEAVY_LEGS,
  [ARMORTYPE_HEAVY  * 1000 + EQUIP_TYPE_SHOULDERS] = EquipmentClass.HEAVY_SHOULDERS,
  [ARMORTYPE_HEAVY  * 1000 + EQUIP_TYPE_WAIST] = EquipmentClass.HEAVY_WAIST,
  [ARMORTYPE_MEDIUM * 1000 + EQUIP_TYPE_CHEST] = EquipmentClass.MEDIUM_CHEST,
  [ARMORTYPE_MEDIUM * 1000 + EQUIP_TYPE_FEET] = EquipmentClass.MEDIUM_FEET,
  [ARMORTYPE_MEDIUM * 1000 + EQUIP_TYPE_HAND] = EquipmentClass.MEDIUM_HAND,
  [ARMORTYPE_MEDIUM * 1000 + EQUIP_TYPE_HEAD] = EquipmentClass.MEDIUM_HEAD,
  [ARMORTYPE_MEDIUM * 1000 + EQUIP_TYPE_LEGS] = EquipmentClass.MEDIUM_LEGS,
  [ARMORTYPE_MEDIUM * 1000 + EQUIP_TYPE_SHOULDERS] = EquipmentClass.MEDIUM_SHOULDERS,
  [ARMORTYPE_MEDIUM * 1000 + EQUIP_TYPE_WAIST] = EquipmentClass.MEDIUM_WAIST,
  [ARMORTYPE_LIGHT  * 1000 + EQUIP_TYPE_CHEST] = EquipmentClass.LIGHT_CHEST,
  [ARMORTYPE_LIGHT  * 1000 + EQUIP_TYPE_FEET] = EquipmentClass.LIGHT_FEET,
  [ARMORTYPE_LIGHT  * 1000 + EQUIP_TYPE_HAND] = EquipmentClass.LIGHT_HAND,
  [ARMORTYPE_LIGHT  * 1000 + EQUIP_TYPE_HEAD] = EquipmentClass.LIGHT_HEAD,
  [ARMORTYPE_LIGHT  * 1000 + EQUIP_TYPE_LEGS] = EquipmentClass.LIGHT_LEGS,
  [ARMORTYPE_LIGHT  * 1000 + EQUIP_TYPE_SHOULDERS] = EquipmentClass.LIGHT_SHOULDERS,
  [ARMORTYPE_LIGHT  * 1000 + EQUIP_TYPE_WAIST] = EquipmentClass.LIGHT_WAIST,
}
local function getArmorEquipmentClass(slotData)
  local armorType = GetItemArmorType(slotData.bagId, slotData.slotIndex)
  local equipmentClass = armorTypeMap[armorType * 1000 + slotData.equipType]
  if equipmentClass ~= nil then
    return equipmentClass
  else
    error("unrecognised ArmorType " .. tostring(weaponType) .. " on item '" .. tostring(slotData.name) .. "'")
  end
end
local equipTypeMap = {
  [EQUIP_TYPE_MAIN_HAND] = getWeaponOrShieldEquipmentClass,
  [EQUIP_TYPE_OFF_HAND] = getWeaponOrShieldEquipmentClass,
  [EQUIP_TYPE_ONE_HAND] = getWeaponOrShieldEquipmentClass,
  [EQUIP_TYPE_TWO_HAND] = getWeaponOrShieldEquipmentClass,
  [EQUIP_TYPE_CHEST] = getArmorEquipmentClass,
  [EQUIP_TYPE_FEET] = getArmorEquipmentClass,
  [EQUIP_TYPE_HAND] = getArmorEquipmentClass,
  [EQUIP_TYPE_HEAD] = getArmorEquipmentClass,
  [EQUIP_TYPE_LEGS] = getArmorEquipmentClass,
  [EQUIP_TYPE_SHOULDERS] = getArmorEquipmentClass,
  [EQUIP_TYPE_WAIST] = getArmorEquipmentClass,
  [EQUIP_TYPE_NECK] = function(_) return EquipmentClass.NECKLACE end,
  [EQUIP_TYPE_RING] = function(_) return EquipmentClass.RING end,
}
function EquipmentClass.forSlotData(slotData)
  local handler = equipTypeMap[slotData.equipType]
  if handler ~= nil then
    return handler(slotData)
  else
    error("unrecognised EquipType " .. tostring(slotData.equipType) .. " on item '" .. tostring(slotData.name) .. "'"
      .. " it=" .. tostring(slotData.itemType))
  end
end

if NoResearchDupes == nil then
  NoResearchDupes = {}
end
NoResearchDupes.EquipmentClass = EquipmentClass
