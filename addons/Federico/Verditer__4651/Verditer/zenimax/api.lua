
Verditer = Verditer or {}
Verditer.zenimax = Verditer.zenimax or {}
local Verditer = Verditer

Verditer.zenimax.api = {}
local M = Verditer.zenimax.api

M.GetGameTimeMilliseconds = GetGameTimeMilliseconds
M.GetAPIVersion           = GetAPIVersion
M.GetWorldName            = GetWorldName

M.GetString = GetString

M.GetUnitName             = GetUnitName
M.GetUnitDisplayName      = GetUnitDisplayName
M.GetUnitClass            = GetUnitClass
M.GetUnitRace             = GetUnitRace
M.GetUnitLevel            = GetUnitLevel
M.GetUnitChampionPoints   = GetUnitChampionPoints
M.GetUnitAlliance         = GetUnitAlliance

M.GetUnitPower            = GetUnitPower
M.IsUnitDead              = IsUnitDead

M.GetNumKillingAttacks          = GetNumKillingAttacks
M.GetKillingAttackInfo          = GetKillingAttackInfo
M.DoesKillingAttackHaveAttacker = DoesKillingAttackHaveAttacker
M.GetKillingAttackerInfo        = GetKillingAttackerInfo

M.GetCurrentMapZoneIndex  = GetCurrentMapZoneIndex
M.GetZoneNameByIndex      = GetZoneNameByIndex

M.GetAbilityName          = GetAbilityName
M.GetAbilityIcon          = GetAbilityIcon

M.GetUIMousePosition = GetUIMousePosition

M.GetFramerate = GetFramerate
