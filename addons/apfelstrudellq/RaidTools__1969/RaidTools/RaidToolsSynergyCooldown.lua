RaidToolsSyCD = {}

function RaidToolsSyCD.Init()
	
end

function RaidToolsSyCD.BuildUI()
	-- body
end

function RaidToolsSyCD.OnEffectChanged(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	--d(string.format('changeType: %s, effectName: %s, unitTag: %s, stackCount: %s, buffType: %s, effectType: %s, abilityType: %s, statusEffectType: %s, unitName: %s, unitId: %s, abilityId: %s, sourceType: %s',
	--	changeType, effectName, unitTag, stackCount, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType
	--))
end

function RaidToolsSyCD.OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	--d(string.format('result: %s, abilityName: %s, sourceName: %s, sourceType: %s, sourceUnitId: %s, abilityId: %s, targetUnitId: %s, targetName: %s', result, abilityName, sourceName, sourceType, sourceUnitId, abilityId,targetUnitId, targetName))
end