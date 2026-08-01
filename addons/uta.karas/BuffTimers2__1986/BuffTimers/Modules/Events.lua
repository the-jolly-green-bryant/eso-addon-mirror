BuffTimers.eventUpdateActive = false

function BuffTimers.EventAddOnLoaded(event, addonName)
  if addonName == BuffTimers.name then
    EVENT_MANAGER:UnregisterForEvent(BuffTimers.name, EVENT_ADD_ON_LOADED)
    BuffTimers:SettingsLoad()
    BuffTimers:SettingsBuildMenu()
    BuffTimers:WindowInitialize()
    BuffTimers:NotificationInitialize()
    EVENT_MANAGER:RegisterForEvent(BuffTimers.name, EVENT_EFFECT_CHANGED, BuffTimers.EventEffectChanged)
  end
end

function BuffTimers.EventEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
  local barNumber
  if sourceType == COMBAT_UNIT_TYPE_PLAYER then
    if BuffTimers.debug then
      BuffTimers:DebugEvent(changeType, effectName, beginTime, endTime, abilityId)
    end
    if BuffTimers.targetEffectTypes[changeType] then
      barNumber = BuffTimers:BarNumber(effectName, abilityId)
      if barNumber then
        BuffTimers:WindowStart(barNumber, beginTime, endTime, iconName)
      end
      barNumber = BuffTimers.groupBuffsAbilityId[abilityId]
      if barNumber then
        BuffTimers:WindowStartGroupBuff(barNumber, beginTime, endTime)
      end
    elseif changeType == EFFECT_RESULT_FADED then
      if BuffTimers.acceptFadeAbilityId[abilityId] then
        barNumber = BuffTimers:BarNumber(effectName, abilityId)
        if barNumber then
          BuffTimers:WindowStopByFade(barNumber)
        end
      end
    end
  elseif sourceType == COMBAT_UNIT_TYPE_GROUP then
    if BuffTimers.targetEffectTypes[changeType] then
      barNumber = BuffTimers.groupBuffsAbilityId[abilityId]
      if barNumber then
        BuffTimers:WindowStartGroupBuff(barNumber, beginTime, endTime)
      end
    end
  end
end

function BuffTimers.EventUpdate()
  for k, v in pairs(BuffTimers.activeBars) do
    BuffTimers:WindowRefresh(k, v)
  end
  BuffTimers:NotificationRefresh()
  if (table.maxn(BuffTimers.activeBars) == 0) and (table.maxn(BuffTimers.notifications) == 0) then
    EVENT_MANAGER:UnregisterForUpdate(BuffTimers.name)
    BuffTimers.eventUpdateActive = false
  end
end
