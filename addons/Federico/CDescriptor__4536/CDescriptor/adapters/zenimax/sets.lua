-- Collects all set bonus tiers and piece counts from equipped items.
CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

CDescriptor.Adapters = CDescriptor.Adapters or {}

local GetEquippedItemInfo     = GetEquippedItemInfo
local GetItemLink             = GetItemLink
local GetItemLinkSetInfo      = GetItemLinkSetInfo
local GetItemLinkSetBonusInfo = GetItemLinkSetBonusInfo

local M = {}

local WEAPON_SLOTS = {
  EQUIP_SLOT_MAIN_HAND,
  EQUIP_SLOT_OFF_HAND,
  EQUIP_SLOT_BACKUP_MAIN,
  EQUIP_SLOT_BACKUP_OFF,
}
local ARMOR_SLOTS = {
  EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_CHEST,
  EQUIP_SLOT_HAND, EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET,
  EQUIP_SLOT_NECK, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2,
}

local function get_set_data(link)
  local has_set, set_name, num_bonuses, num_normal, _, _, num_perfected = GetItemLinkSetInfo(link, true)
  if not has_set or num_bonuses == 0 then return nil, nil, nil, nil, nil end

  local raw_bonuses = {}
  for i = 1, num_bonuses do
    local num_required, desc = GetItemLinkSetBonusInfo(link, true, i)
    if desc and desc ~= "" then
      raw_bonuses[#raw_bonuses + 1] = { required = num_required, desc = desc }
    end
  end
  table.sort(raw_bonuses, function(a, b) return a.required < b.required end)
  local bonuses = {}
  for _, entry in ipairs(raw_bonuses) do
    bonuses[#bonuses + 1] = entry.desc
  end
  local n_normal = num_normal   or 0
  local n_perf   = num_perfected or 0
  return set_name, bonuses, n_normal + n_perf, n_normal, n_perf
end

function M.get_active_sets()
  local sets = {}
  local all_slots = {}
  for _, s in ipairs(WEAPON_SLOTS) do all_slots[#all_slots+1] = s end
  for _, s in ipairs(ARMOR_SLOTS)  do all_slots[#all_slots+1] = s end

  for _, equip_slot in ipairs(all_slots) do
    local _, has_item = GetEquippedItemInfo(equip_slot)
    if has_item then
      local link = GetItemLink(BAG_WORN, equip_slot, LINK_STYLE_BRACKETS)
      if link and link ~= "" then
        local set_name, bonuses, count, n_normal, n_perf = get_set_data(link)
        if set_name and not sets[set_name] then
          sets[set_name] = {
            bonuses         = bonuses,
            count_equipped  = count,
            count_perfected = n_perf,
          }
        end
      end
    end
  end

  -- When "Perfected X" and "X" both appear (same family), drop "X":
  -- the perfected entry already includes all non-perfected pieces in its count.
  local to_remove = {}
  for name in pairs(sets) do
    if name:sub(1, 10) == "Perfected " then
      local base = name:sub(11)
      if sets[base] then
        to_remove[#to_remove + 1] = base
      end
    end
  end
  for _, name in ipairs(to_remove) do
    sets[name] = nil
  end

  return sets
end

CDescriptor.Adapters.Sets = M
