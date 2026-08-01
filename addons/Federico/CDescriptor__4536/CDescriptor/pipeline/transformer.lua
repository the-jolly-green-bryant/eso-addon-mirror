-- Maps raw extractor output to the output schema.
-- Pure Lua: no ESO globals, no UI. Fully testable offline.
CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

local M = {}
local KO = CDescriptor.KeyOrders  -- populated by core/key_orders.lua before this runs

local SLOT_LABELS = { "1", "2", "3", "4", "5" }

-- Strips ESO color markup: |cRRGGBBtext|r  →  text
local function strip_markup(s)
  if type(s) ~= "string" then return s end
  s = s:gsub("|c%x%x%x%x%x%x(.-)%|r", "%1")
  s = s:gsub("%s*\n+%s*", " ")   -- collapse newlines to a single space
  return (s:match("^(.-)%s*$"))  -- trim trailing whitespace
end

-- ── Skills ────────────────────────────────────────────────────────────────

local function format_skill_slot(slot_data)
  if not slot_data or slot_data.name == "" then return nil end
  local name = strip_markup(slot_data.name)
  if slot_data.is_ultimate then
    name = name .. " (Ultimate)"
  end
  if slot_data.scripts and next(slot_data.scripts) then
    local clean_scripts = { __key_order = KO.SCRIPTS }
    for label, s in pairs(slot_data.scripts) do
      clean_scripts[label] = {
        __key_order = KO.SCRIPT_ENTRY,
        name        = strip_markup(s.name),
        description = strip_markup(s.description),
      }
    end
    return { name = name, scripts = clean_scripts }
  end
  return name
end

local function transform_bar(bar_slots)
  if not bar_slots then return {} end
  local out = { __key_order = KO.BAR }
  for i = 1, 5 do
    local entry = format_skill_slot(bar_slots[i])
    if entry ~= nil then out[SLOT_LABELS[i]] = entry end
  end
  local ult = format_skill_slot(bar_slots[6])
  if ult ~= nil then out["R"] = ult end
  return out
end

-- ── Gear ──────────────────────────────────────────────────────────────────

local function transform_enchant(item)
  if not item or item.enchant == "" then return nil end
  local desc = strip_markup(item.enchant_desc or "")
  if desc == "" then return item.enchant end
  return { name = item.enchant, effect = desc }
end

local function transform_weapon_slot(item)
  if not item then return nil end
  return {
    __key_order = KO.GEAR_WEAPON,
    item    = item.weapon_type or item.name,
    set     = item.set_name,
    quality = item.quality,
    trait   = strip_markup(item.trait),
    enchant = transform_enchant(item),
  }
end

local function transform_armor_slot(item)
  if not item then return nil end
  return {
    __key_order = KO.GEAR_ARMOR,
    item    = item.name,
    set     = item.set_name,
    weight  = item.armor_type,
    quality = item.quality,
    trait   = strip_markup(item.trait),
    enchant = transform_enchant(item),
  }
end

local function transform_jewelry_slot(item)
  if not item then return nil end
  return {
    __key_order = KO.GEAR_JEWELRY,
    item    = item.name,
    set     = item.set_name,
    quality = item.quality,
    trait   = strip_markup(item.trait),
    enchant = transform_enchant(item),
  }
end

local function transform_gear(gear)
  if not gear then return {} end
  return {
    weapons = {
      bar_1 = transform_weapon_slot(gear.bar_1_weapon),
      bar_2 = transform_weapon_slot(gear.bar_2_weapon),
    },
    armor = {
      head     = transform_armor_slot(gear.head),
      shoulder = transform_armor_slot(gear.shoulder),
      chest    = transform_armor_slot(gear.chest),
      gloves   = transform_armor_slot(gear.gloves),
      waist    = transform_armor_slot(gear.waist),
      legs     = transform_armor_slot(gear.legs),
      boots    = transform_armor_slot(gear.boots),
    },
    jewelry = {
      neck   = transform_jewelry_slot(gear.neck),
      ring_1 = transform_jewelry_slot(gear.ring_1),
      ring_2 = transform_jewelry_slot(gear.ring_2),
    },
  }
end

-- ── Sets ──────────────────────────────────────────────────────────────────

local function transform_sets(sets)
  if not sets then return {} end
  local out = {}
  for name, data in pairs(sets) do
    local clean_bonuses = {}
    for _, b in ipairs(data.bonuses or {}) do
      clean_bonuses[#clean_bonuses + 1] = strip_markup(b)
    end
    local cp = data.count_perfected
    out[name] = {
      __key_order     = KO.SET_ENTRY,
      bonuses         = clean_bonuses,
      count_equipped  = data.count_equipped,
      count_perfected = (cp and cp > 0 and cp < data.count_equipped) and cp or nil,
    }
  end
  return out
end

-- ── Passives ──────────────────────────────────────────────────────────────

-- Returns a flat object: { ["Skill Line"] = "learned/total", ... }
local function transform_passives(passives)
  if not passives then return {} end
  local out = {}
  for line_name, data in pairs(passives) do
    out[line_name] = data.learned .. "/" .. data.total
  end
  return out
end

-- ── Stats ─────────────────────────────────────────────────────────────────

local function transform_stats(stats)
  if not stats then return {} end
  return stats  -- already clean integers from GetPlayerStat
end

-- ── Buffs ─────────────────────────────────────────────────────────────────

local function transform_buffs(buffs)
  if not buffs then return {} end
  local out = {}
  for _, b in ipairs(buffs) do
    -- name first, description second — order matters for readability
    local desc = b.description and strip_markup(b.description) or nil
    local entry = {
      __key_order = KO.BUFF_ENTRY,
      name        = b.name,
      description = desc,
      stacks      = b.stacks,
      source      = (not b.cast_by_player) and "external" or nil,
    }
    out[#out + 1] = entry
  end
  return out
end

-- ── Champion Points ───────────────────────────────────────────────────────

local function transform_champion_points(cp)
  if not cp then return {} end
  local out = {}
  for discipline_name, discipline_data in pairs(cp) do
    local slottable = {}
    for _, entry in ipairs(discipline_data.slottable or {}) do
      slottable[#slottable + 1] = {
        __key_order = KO.CP_SKILL_ENTRY,
        name   = entry.name,
        points = entry.points,
      }
    end
    local passive = {}
    for _, entry in ipairs(discipline_data.passive or {}) do
      passive[#passive + 1] = {
        __key_order = KO.CP_SKILL_ENTRY,
        name   = entry.name,
        points = entry.points,
      }
    end
    out[discipline_name] = {
      __key_order = KO.CP_DISCIPLINE,
      slottable = slottable,
      passive   = passive,
    }
  end
  return out
end

-- ── Root ──────────────────────────────────────────────────────────────────

-- config fields (all boolean, nil treated as default):
--   include_sets     → default true
--   include_stats    → default false
--   include_buffs    → default false
--   include_passives → default false
--   include_cp       → default false
function M.transform(raw, config)
  config = config or {}
  local include_sets     = config.include_sets     ~= false  -- default true
  local include_stats    = config.include_stats    == true   -- default false
  local include_buffs    = config.include_buffs    == true   -- default false
  local include_passives = config.include_passives == true   -- default false
  local include_cp       = config.include_cp       == true   -- default false

  local character = raw.character or {}
  local skills    = raw.skills or {}

  local result = {
    __key_order  = KO.ROOT,
    character    = {
      name            = character.name,
      class           = character.class,
      race            = character.race,
      level           = character.level,
      champion_points = character.champion_points,
    },
    bar_1_skills = transform_bar(skills.bar_1),
    bar_2_skills = transform_bar(skills.bar_2),
    gear         = transform_gear(raw.gear),
  }

  if include_sets     then result.sets_buffs      = transform_sets(raw.sets)                          end
  if include_stats    then result.stats           = transform_stats(raw.stats)                         end
  if include_buffs    then result.buffs           = transform_buffs(raw.buffs)                         end
  if include_passives then result.passive_skills  = transform_passives(raw.passives)                   end
  if include_cp       then result.champion_points = transform_champion_points(raw.champion_points)     end

  if CDescriptor.Constants and CDescriptor.Constants.DEBUG and skills._debug then
    result._debug = skills._debug
  end

  return result
end

CDescriptor.Transformer = M
return M
