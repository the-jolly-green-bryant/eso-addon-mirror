-- Defines __key_order arrays for JSON serialization order.
-- Centralizing here avoids scattering ordering decisions across transform logic.
CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

CDescriptor.KeyOrders = {
  ROOT         = { "character", "bar_1_skills", "bar_2_skills", "gear", "sets_buffs", "stats", "buffs", "passive_skills", "champion_points" },
  BAR          = { "1", "2", "3", "4", "5", "R" },
  SCRIPTS      = { "a", "b", "c" },
  SCRIPT_ENTRY = { "name", "description" },
  SET_ENTRY    = { "bonuses", "count_equipped", "count_perfected" },
  BUFF_ENTRY   = { "name", "description", "stacks", "source" },
  CP_DISCIPLINE   = { "slottable", "passive" },
  CP_SKILL_ENTRY  = { "name", "points" },
  GEAR_WEAPON  = { "item", "set", "quality", "trait", "enchant" },
  GEAR_ARMOR   = { "item", "set", "weight", "quality", "trait", "enchant" },
  GEAR_JEWELRY = { "item", "set", "quality", "trait", "enchant" },
}
