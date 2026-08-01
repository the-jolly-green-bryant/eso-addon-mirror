-- Orchestrates data collection. Receives adapters as parameter for testability.
CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

local M = {}

function M.extract(adapters)
  return {
    character = adapters.character.get_info(),
    skills    = adapters.skills.get_all_bars(),
    gear      = adapters.gear.get_equipped(),
    sets      = adapters.sets.get_active_sets(),
    stats     = adapters.stats.get_stats(),
    buffs     = adapters.buffs.get_active_buffs(),
    passives        = adapters.passives        and adapters.passives.get_learned_passives()    or nil,
    champion_points = adapters.champion_points and adapters.champion_points.get_champion_points() or nil,
  }
end

CDescriptor.Extractor = M
return M
