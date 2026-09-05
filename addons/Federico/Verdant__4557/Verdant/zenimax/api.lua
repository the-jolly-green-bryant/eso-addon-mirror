
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
M.IsUnitInCombat          = IsUnitInCombat
M.DoesUnitExist           = DoesUnitExist
M.GetGroupSize            = GetGroupSize
M.GetUnitName             = GetUnitName
M.AreUnitsEqual           = AreUnitsEqual
M.GetUnitClassId          = GetUnitClassId
M.ZO_GetClassIcon         = ZO_GetClassIcon
M.GetUnitZone             = GetUnitZone
M.GetTimeStamp            = GetTimeStamp
M.GetUIGlobalScale        = GetUIGlobalScale
M.GetDateStringFromTimestamp = GetDateStringFromTimestamp
M.GetCurrentZoneDungeonDifficulty = GetCurrentZoneDungeonDifficulty
M.GetLatency              = GetLatency
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
M.GetSlotAbilityCost                     = GetSlotAbilityCost
M.GetActiveHotbarCategory                = GetActiveHotbarCategory
M.GetActiveHotbarCategory                = GetActiveHotbarCategory
M.GetUnitPower                           = GetUnitPower
M.GetAbilityName                         = GetAbilityName
M.GetAbilityIcon                         = GetAbilityIcon
M.GetAbilityDescription                  = GetAbilityDescription
M.IsAbilityPassive                       = IsAbilityPassive
M.GetAbilityEffectDescription            = GetAbilityEffectDescription
M.GetNumBuffs                            = GetNumBuffs
M.GetUnitBuffInfo                        = GetUnitBuffInfo
M.GetSpecificSkillAbilityKeysByAbilityId = GetSpecificSkillAbilityKeysByAbilityId
M.GetSkillLineId                         = GetSkillLineId

M.GetUIMousePosition = GetUIMousePosition
M.MouseIsOver        = MouseIsOver
