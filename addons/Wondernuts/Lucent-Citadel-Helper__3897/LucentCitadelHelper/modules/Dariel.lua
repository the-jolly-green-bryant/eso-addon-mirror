LCH = LCH or {}
local LCH = LCH
LCH.Dariel = {
  powerfulThrowTarget = nil,
}

LCH.Dariel.constants = {
  powerful_throw_id = 218971,
  
}

function LCH.Dariel.Init()

end

function LCH.Dariel.PowerfulThrow(result, targetType, targetUnitId, hitValue, abilityId)
  local displayTargetName = GetUnitDisplayName(LCH.GetTagForId(targetUnitId)) or ""
  LCH:Trace(2, string.format(
    "Ability: %s, ID: %d, Hit Value: %d, Target name: %s, Result: %d", 
    GetFormattedAbilityName(abilityId), abilityId, hitValue, displayTargetName, result
  ))

  if result == ACTION_RESULT_BEGIN and hitValue > 500 then
    LCH.Alert("Dariel", string.format("Powerful Throw -> %s", LCH.GetNameForId(targetUnitId)), 0xFFD666FF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, hitValue)
    local unitTag = LCH.GetTagForId(targetUnitId)
    LCH.Dariel.powerfulThrowTarget = unitTag
    LCH.AddIconForDuration(unitTag, "LucentCitadelHelper/icons/meeting-point.dds", hitValue)

  elseif result == ACTION_RESULT_EFFECT_GAINED and targetType == COMBAT_UNIT_TYPE_NONE and hitValue > 0 then
    CombatAlerts.AlertCast(abilityId, "", 1500, {-2, 1})
    local unitTag = LCH.Dariel.powerfulThrowTarget
    local icon = LCH.AddGroundIconOnPlayerForDuration(unitTag, "LucentCitadelHelper/icons/meeting-point.dds", 2000)
  end
end
