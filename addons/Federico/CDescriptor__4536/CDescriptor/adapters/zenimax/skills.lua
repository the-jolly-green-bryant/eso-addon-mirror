CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

CDescriptor.Adapters = CDescriptor.Adapters or {}

local IsScribingEnabled                  = IsScribingEnabled
local GetNumCraftedAbilities             = GetNumCraftedAbilities
local GetCraftedAbilityIdAtIndex         = GetCraftedAbilityIdAtIndex
local GetAbilityIdForCraftedAbilityId    = GetAbilityIdForCraftedAbilityId
local GetCraftedAbilityActiveScriptIds   = GetCraftedAbilityActiveScriptIds
local GetCraftedAbilityScriptDisplayName = GetCraftedAbilityScriptDisplayName
local GetCraftedAbilityScriptDescription = GetCraftedAbilityScriptDescription
local GetSlotType                        = GetSlotType
local GetSlotName                        = GetSlotName
local GetSlotBoundId                     = GetSlotBoundId

local M = {}

-- Maps ability_id → crafted_id using the inverse function GetAbilityIdForCraftedAbilityId.
-- GetAbilityCraftedAbilityId(abilityId) doesn't reliably resolve morph IDs;
-- iterating crafted abilities and reversing the map is the correct approach.
local function build_crafted_ability_map()
  local map = {}  -- ability_id OR crafted_id -> crafted_id
  if not IsScribingEnabled or not IsScribingEnabled() then return map end
  local n = GetNumCraftedAbilities()
  for i = 1, n do
    local crafted_id = GetCraftedAbilityIdAtIndex(i)
    -- GetSlotBoundId returns crafted_id directly for scribing skills
    map[crafted_id] = crafted_id
    -- Also map the underlying ability_id as fallback
    local ability_id = GetAbilityIdForCraftedAbilityId(crafted_id)
    if ability_id and ability_id ~= 0 then
      map[ability_id] = crafted_id
    end
  end
  return map
end

local function get_scribing_scripts(crafted_id)
  local p_id, s_id, t_id = GetCraftedAbilityActiveScriptIds(crafted_id)
  local slots = { p_id, s_id, t_id }
  local labels = { "a", "b", "c" }
  local scripts = {}
  for i, script_id in ipairs(slots) do
    if script_id and script_id ~= 0 then
      scripts[labels[i]] = {
        name        = GetCraftedAbilityScriptDisplayName(script_id) or "",
        description = GetCraftedAbilityScriptDescription(crafted_id, script_id) or "",
      }
    end
  end
  return scripts
end

local function get_bar_slots(hotbar_category, crafted_map, debug_out)
  local slots = {}
  local skill_index = 1

  for slot = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 do
    local slot_type   = GetSlotType(slot, hotbar_category)
    local is_ultimate = (slot_type == ACTION_SLOT_TYPE_ULTIMATE)
    local name        = GetSlotName(slot, hotbar_category) or ""
    local ability_id  = GetSlotBoundId(slot, hotbar_category)

    if debug_out then
      debug_out[#debug_out + 1] = {
        slot       = slot,
        name       = name,
        ability_id = ability_id,
        matched    = crafted_map[ability_id] ~= nil,
      }
    end

    local slot_data = {
      name        = name,
      ability_id  = ability_id,
      is_ultimate = is_ultimate,
      scripts     = nil,
    }

    local crafted_id = crafted_map[ability_id]
    if crafted_id then
      local scripts = get_scribing_scripts(crafted_id)
      if next(scripts) then
        slot_data.scripts = scripts
      end
    end

    if is_ultimate then
      slots[6] = slot_data
    else
      slots[skill_index] = slot_data
      skill_index = skill_index + 1
    end
  end

  return slots
end

function M.get_all_bars()
  local crafted_map = build_crafted_ability_map()
  local debug_slots = nil

  if CDescriptor.Constants and CDescriptor.Constants.DEBUG then
    debug_slots = {}
  end

  local result = {
    bar_1 = get_bar_slots(HOTBAR_CATEGORY_PRIMARY, crafted_map, debug_slots),
    bar_2 = get_bar_slots(HOTBAR_CATEGORY_BACKUP,  crafted_map, debug_slots),
  }

  if debug_slots then
    local crafted_map_debug = {}
    for ability_id, crafted_id in pairs(crafted_map) do
      crafted_map_debug[#crafted_map_debug + 1] = {
        ability_id = ability_id,
        crafted_id = crafted_id,
      }
    end
    result._debug = {
      crafted_map = crafted_map_debug,
      slots       = debug_slots,
    }
  end

  return result
end

CDescriptor.Adapters.Skills = M
