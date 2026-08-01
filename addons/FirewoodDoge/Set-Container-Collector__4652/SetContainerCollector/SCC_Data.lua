SetContainerCollector = SetContainerCollector or {}
local SCC = SetContainerCollector
SCC.Data = SCC.Data or {}

--[[
  Pool definitions (resolved at runtime via LibSets or explicit setIds).
  Keys are used by /scc pool <key> and container entries with type = "pool".
--]]
SCC.Data.Pools = {
  ap_elite = {
    label = "AP Elite Gear Vendor",
    dropMechanic = LIBSETS_DROP_MECHANIC_AP_ELITE_GEAR_LOCKBOX_MERCHANT,
  },
  telvar = {
    label = "Tel Var Equipment Lockbox",
    dropMechanic = LIBSETS_DROP_MECHANIC_TELVAR_EQUIPMENT_LOCKBOX_MERCHANT,
  },
  battleground_merchant = {
    label = "Battleground Merchant",
    setIds = { 326, 327, 328, 329 },
  },
  cyrodiil_bruma = {
    label = "Bruma Quartermaster",
    dropMechanic = LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_BRUMA,
    armorType = ARMORTYPE_MEDIUM,
  },
  cyrodiil_cropsford = {
    label = "Cropsford Quartermaster",
    dropMechanic = LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_CROPSFORD,
    armorType = ARMORTYPE_LIGHT,
  },
  cyrodiil_vlastarus = {
    label = "Vlastarus Quartermaster",
    dropMechanic = LIBSETS_DROP_MECHANIC_CITY_CYRODIIL_VLASTARUS,
    armorType = ARMORTYPE_HEAVY,
  },
  maj_mystery = {
    label = "Maj's Mystery Coffer",
    equipSlot = EQUIP_TYPE_SHOULDERS,
    setIds = {
      265, 170, 268, 166, 269, 167, 266, 162, 267, 163, 270, 165,
    },
  },
  glirion_mystery = {
    label = "Glirion's Mystery Coffer",
    equipSlot = EQUIP_TYPE_SHOULDERS,
    setIds = {
      272, 169, 273, 168, 278, 274, 276, 280, 271, 277, 279, 275,
    },
  },
  urgarlag_mystery = {
    label = "Urgarlag's Mystery Coffer",
    equipSlot = EQUIP_TYPE_SHOULDERS,
    setIds = {
      164, 183, 256, 257, 341, 342, 349, 350, 397, 398, 432, 436,
      458, 459, 478, 479, 534, 535, 577, 578, 608, 609, 632, 633,
      666, 667, 683, 687, 734, 738, 797, 801, 828, 829,
    },
  },
}

--[[
  Container itemId -> definition (populated by SCC_Data_*.lua)

  type "pool"  : poolKey in SCC.Data.Pools
  type "sets"  : setIds; optional equipSlot / weaponType
  type "set"   : setId; optional equipSlot

  Unregistered single-set boxes fall back to GetItemLinkContainerSetInfo (autoResolved).
--]]
SCC.Data.Containers = {}

function SCC.Data.Register(itemId, def)
  SCC.Data.Containers[itemId] = def
end

function SCC.Data.RegisterSet(itemId, label, setId, equipSlot)
  local def = {
    type = "set",
    label = label,
    setId = setId,
  }
  if equipSlot then
    def.equipSlot = equipSlot
  end
  SCC.Data.Register(itemId, def)
end

function SCC.Data.RegisterSets(itemId, label, setIds, options)
  options = options or {}
  SCC.Data.Register(itemId, {
    type = "sets",
    label = label,
    setIds = setIds,
    equipSlot = options.equipSlot,
    weaponType = options.weaponType,
  })
end

function SCC.Data.RegisterPool(itemId, poolKey, label)
  SCC.Data.Register(itemId, {
    type = "pool",
    poolKey = poolKey,
    label = label,
  })
end

function SCC.Data.RegisterBatch(entries)
  for itemId, def in pairs(entries) do
    SCC.Data.Register(itemId, def)
  end
end
