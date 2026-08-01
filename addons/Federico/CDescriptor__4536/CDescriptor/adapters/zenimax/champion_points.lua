-- Collects champion point investments grouped by discipline (slottable vs passive).
CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

CDescriptor.Adapters = CDescriptor.Adapters or {}

local GetNumChampionDisciplines        = GetNumChampionDisciplines
local GetChampionDisciplineId          = GetChampionDisciplineId
local GetChampionDisciplineName        = GetChampionDisciplineName
local GetNumChampionDisciplineSkills   = GetNumChampionDisciplineSkills
local GetChampionSkillId               = GetChampionSkillId
local GetNumPointsSpentOnChampionSkill = GetNumPointsSpentOnChampionSkill
local GetChampionSkillName             = GetChampionSkillName
local GetChampionSkillType             = GetChampionSkillType
local IsChampionSystemUnlocked         = IsChampionSystemUnlocked

local M = {}

local SLOTTABLE_TYPES = {
  [CHAMPION_SKILL_TYPE_NORMAL_SLOTTABLE]    = true,
  [CHAMPION_SKILL_TYPE_STAT_POOL_SLOTTABLE] = true,
}

function M.get_champion_points()
  if not IsChampionSystemUnlocked or not IsChampionSystemUnlocked() then
    return nil
  end

  local result = {}
  local num_disciplines = GetNumChampionDisciplines()

  for disc_index = 1, num_disciplines do
    local discipline_id   = GetChampionDisciplineId(disc_index)
    local discipline_name = GetChampionDisciplineName(discipline_id)
    local slottable = {}
    local passive   = {}

    local num_skills = GetNumChampionDisciplineSkills(disc_index)
    for skill_index = 1, num_skills do
      local skill_id = GetChampionSkillId(disc_index, skill_index)
      local points   = GetNumPointsSpentOnChampionSkill(skill_id)
      if points and points > 0 then
        local name       = GetChampionSkillName(skill_id)
        local skill_type = GetChampionSkillType(skill_id)
        local entry = { name = name, points = points }
        if SLOTTABLE_TYPES[skill_type] then
          slottable[#slottable + 1] = entry
        else
          passive[#passive + 1] = entry
        end
      end
    end

    result[discipline_name] = { slottable = slottable, passive = passive }
  end

  return result
end

CDescriptor.Adapters.ChampionPoints = M
