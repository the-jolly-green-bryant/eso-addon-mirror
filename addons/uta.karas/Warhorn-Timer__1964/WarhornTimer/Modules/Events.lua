function WarhornTimer.EventAddOnLoaded(event, addonName)
  if addonName == WarhornTimer.name then
    EVENT_MANAGER:UnregisterForEvent(WarhornTimer.name, EVENT_ADD_ON_LOADED)
    WarhornTimer:SettingsLoad()
    WarhornTimer:SettingsBuildMenu()
    WarhornTimer:WindowInitialize()
    EVENT_MANAGER:RegisterForEvent(WarhornTimer.name, EVENT_EFFECT_CHANGED, WarhornTimer.EventEffectChanged)
  end
end

function WarhornTimer.EventEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
  if sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_GROUP then
    if WarhornTimer.targetEffectTypes[changeType] then
      if WarhornTimer.abilityIdList[abilityId] then
        WarhornTimer:WindowStart(beginTime, endTime, iconName)
      end
    end
  end
end

function WarhornTimer.EventUpdate()
  WarhornTimer:WindowRefresh()
end
