function BuffTimers:BarNumber(effectName, abilityId)
  local barNumber
  if BuffTimers.settings.buffNames[effectName] then
    barNumber = BuffTimers.settings.buffNames[effectName]
  elseif BuffTimers.settings.buffNames[abilityId] then
    barNumber = BuffTimers.settings.buffNames[abilityId]
  end
  return barNumber
end
