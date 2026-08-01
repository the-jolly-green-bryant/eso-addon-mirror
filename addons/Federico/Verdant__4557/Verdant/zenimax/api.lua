
Verdant = Verdant or {}
Verdant.zenimax = Verdant.zenimax or {}
local Verdant = Verdant

Verdant.zenimax.api = {}
local M = Verdant.zenimax.api

M.GetGameTimeMilliseconds = GetGameTimeMilliseconds
M.GetAPIVersion           = GetAPIVersion
M.GetWorldName            = GetWorldName

M.GetString = GetString

M.IsUnitGrouped           = IsUnitGrouped
M.GetGroupSize            = GetGroupSize
M.GetUnitName             = GetUnitName
M.GetUnitDisplayName      = GetUnitDisplayName
M.GetUnitClass            = GetUnitClass
M.GetUnitRace             = GetUnitRace
M.GetUnitLevel            = GetUnitLevel
M.GetUnitChampionPoints   = GetUnitChampionPoints
M.GetUnitAlliance         = GetUnitAlliance

M.GetCurrentMapZoneIndex  = GetCurrentMapZoneIndex
M.GetZoneNameByIndex      = GetZoneNameByIndex

M.GetSlotName                            = GetSlotName
M.GetSlotBoundId                         = GetSlotBoundId
M.GetAbilityName                         = GetAbilityName
M.GetAbilityIcon                         = GetAbilityIcon
M.GetSpecificSkillAbilityKeysByAbilityId = GetSpecificSkillAbilityKeysByAbilityId
M.GetSkillLineId                         = GetSkillLineId

M.GetUIMousePosition = GetUIMousePosition
