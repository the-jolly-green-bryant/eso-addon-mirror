--* ZOS API surface used by Vermilion. functions are
--* forwarded by value (M.X = X), captured at module load. This is the same
--* call cost as the bare global with the wrapper benefit of a namespace.
--* Consumers may local-cache hot-path entries:
--*   local GetGameTimeMs = Vermilion.zenimax.api.GetGameTimeMilliseconds
--? This may not be necessary, however I found it cleaner to have all API calls explicitly go through the wrapper for readability.

Vermilion = Vermilion or {}
Vermilion.zenimax = Vermilion.zenimax or {}
local Vermilion = Vermilion

Vermilion.zenimax.api = {}
local M = Vermilion.zenimax.api

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
