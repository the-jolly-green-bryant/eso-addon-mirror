CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

CDescriptor.Adapters = CDescriptor.Adapters or {}

local GetPlayerStat           = GetPlayerStat
local GetAttributeSpentPoints = GetAttributeSpentPoints

local M = {}

-- Each entry: { key = output field name, stat = STAT_* constant }
-- Defined lazily because STAT_* globals are only available at runtime.
local STAT_MAP

local function init_stat_map()
  if STAT_MAP then return end
  STAT_MAP = {
    -- Resources
    { key = "health_max",           stat = STAT_HEALTH_MAX },
    { key = "magicka_max",          stat = STAT_MAGICKA_MAX },
    { key = "stamina_max",          stat = STAT_STAMINA_MAX },
    -- Regen (combat)
    { key = "health_regen",         stat = STAT_HEALTH_REGEN_COMBAT },
    { key = "magicka_regen",        stat = STAT_MAGICKA_REGEN_COMBAT },
    { key = "stamina_regen",        stat = STAT_STAMINA_REGEN_COMBAT },
    -- Damage
    { key = "weapon_spell_damage",  stat = STAT_WEAPON_AND_SPELL_DAMAGE },
    { key = "spell_damage",         stat = STAT_SPELL_POWER },
    -- Critical
    { key = "spell_critical",       stat = STAT_SPELL_CRITICAL },
    { key = "critical_chance",      stat = STAT_CRITICAL_CHANCE },
    { key = "critical_resistance",  stat = STAT_CRITICAL_RESISTANCE },
    -- Penetration
    { key = "spell_penetration",    stat = STAT_SPELL_PENETRATION },
    { key = "physical_penetration", stat = STAT_PHYSICAL_PENETRATION },
    { key = "offensive_penetration",stat = STAT_OFFENSIVE_PENETRATION },
    -- Mitigation
    { key = "armor",                stat = STAT_ARMOR_RATING },
    { key = "spell_resistance",     stat = STAT_SPELL_RESIST },
    { key = "physical_resistance",  stat = STAT_PHYSICAL_RESIST },
    { key = "mitigation",           stat = STAT_MITIGATION },
    -- Healing
    { key = "healing_done",         stat = STAT_HEALING_DONE },
    { key = "healing_taken",        stat = STAT_HEALING_TAKEN },
  }
end

function M.get_stats()
  init_stat_map()
  local result = {
    attribute_points = {
      health  = GetAttributeSpentPoints(ATTRIBUTE_HEALTH),
      magicka = GetAttributeSpentPoints(ATTRIBUTE_MAGICKA),
      stamina = GetAttributeSpentPoints(ATTRIBUTE_STAMINA),
    },
  }
  for _, entry in ipairs(STAT_MAP) do
    result[entry.key] = GetPlayerStat(entry.stat, STAT_BONUS_OPTION_APPLY_BONUS)
  end
  return result
end

CDescriptor.Adapters.Stats = M
