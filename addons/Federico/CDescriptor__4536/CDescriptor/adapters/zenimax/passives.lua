-- Collects learned passive skills across all relevant skill lines.
CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

CDescriptor.Adapters = CDescriptor.Adapters or {}

local GetNumSkillLines     = GetNumSkillLines
local GetSkillLineId       = GetSkillLineId
local GetSkillLineNameById = GetSkillLineNameById
local GetNumSkillAbilities = GetNumSkillAbilities
local GetSkillAbilityInfo  = GetSkillAbilityInfo

local M = {}

local SKILL_TYPES = {
  SKILL_TYPE_CLASS,
  SKILL_TYPE_WEAPON,
  SKILL_TYPE_ARMOR,
  SKILL_TYPE_GUILD,
  SKILL_TYPE_WORLD,
  SKILL_TYPE_RACIAL,
  SKILL_TYPE_AVA,
}

-- Returns a table keyed by skill line name: { learned = N, total = M }
-- Only includes lines where at least one passive is learned.
function M.get_learned_passives()
  local result = {}
  for _, skill_type in ipairs(SKILL_TYPES) do
    local num_lines = GetNumSkillLines(skill_type)
    for line_index = 1, num_lines do
      local skill_line_id = GetSkillLineId(skill_type, line_index)
      local line_name     = GetSkillLineNameById(skill_line_id)
      local total   = 0
      local learned = 0
      for skill_index = 1, GetNumSkillAbilities(skill_type, line_index) do
        local _, _, earned_rank, passive, _, purchased = GetSkillAbilityInfo(skill_type, line_index, skill_index)
        if passive then
          total = total + 1
          if purchased and earned_rank and earned_rank > 0 then
            learned = learned + 1
          end
        end
      end
      if learned > 0 then
        result[line_name] = { learned = learned, total = total }
      end
    end
  end
  return result
end

CDescriptor.Adapters.Passives = M
