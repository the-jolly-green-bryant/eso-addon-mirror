Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.units = ERG.units or {}
local Units = ERG.units


function Units.Initialize()
  Units.name = ERG.name.."Units"

  Units.ResetVariables()

  ERG.EM:RegisterForEvent(Units.name.."IdentifyGroupMember", EVENT_EFFECT_CHANGED, Units.OnIdentifyGroupMember)
  ERG.EM:AddFilterForEvent(Units.name.."IdentifyGroupMember", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

  ERG.EM:RegisterForEvent(Units.name.."IdentifyBoss", EVENT_EFFECT_CHANGED, Units.OnIdentifyBoss)
  ERG.EM:AddFilterForEvent(Units.name.."IdentifyBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "boss1")

  -- detect non boss-entity
  for _, encounter in ipairs( ERG.GetEncounterList() ) do
    if ERG[encounter].GetIdentifyEnemyList then
      for abilityId, callback in pairs( ERG[encounter].GetIdentifyEnemyList() ) do
        ERG.EM:RegisterForEvent( Units.name.."IdentifyEnemy"..tostring(abilityId), EVENT_COMBAT_EVENT, function(...) Units.OnIdentifyEnemy(callback, ...) end)
        ERG.EM:AddFilterForEvent( Units.name.."IdentifyEnemy"..tostring(abilityId), EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
        ERG.EM:AddFilterForEvent( Units.name.."IdentifyEnemy"..tostring(abilityId), EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
      end
    end
  end

  -- detect damage on nps's
  for _, result in ipairs( ERG.GetDamageResults() ) do
    ERG.EM:RegisterForEvent( Units.name.."DamageEnemy"..tostring(result), EVENT_COMBAT_EVENT, Units.OnDamageEvent)
    ERG.EM:AddFilterForEvent( Units.name.."DamageEnemy"..tostring(result), EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, result)
    ERG.EM:AddFilterForEvent( Units.name.."DamageEnemy"..tostring(result), EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
  end

end


function Units.ResetVariables()  --TODO combatStart?
  Units.group = { tag = {}, id = {} }
  Units.boss = nil
  Units.enemy = {}
  Units.damage = {}
end

function Units.OnCombatStart()

end


function Units.OnIdentifyGroupMember(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId)
  if changeType == EFFECT_RESULT_GAINED then
    if unitTag and unitId then
      Units.group.tag[unitId] = unitTag
      Units.group.id[unitTag] = unitId
    end
  end
end

--/script d(Rockgroover.units.boss)
function Units.OnIdentifyBoss(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId)
  if changeType == EFFECT_RESULT_GAINED then
    if unitId then
    --if unitId and not Units.boss then --TODO
      Units.boss = unitId
    end
  end
end


function Units.OnIdentifyEnemy(callback, ...)
  local params = {...}
  local paramTable = ERG.GetEventParameterNames( params[1] )

  local sourceUnitId = params[ paramTable["sourceUnitId"] ]
  local abilityId = params[ paramTable["abilityId"] ]

  if not sourceUnitId then return end
  if Units.enemy[sourceUnitId] then return end
  Units.enemy[sourceUnitId] = callback
  if type(callback) == "function" then
    callback(true, sourceUnitId)
  end
end


function Units.OnDamageEvent(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  if not targetUnitId then return end
  if Units.damage[targetUnitId] then
     Units.damage[targetUnitId] = Units.damage[targetUnitId] + hitValue
  end
  if overflow ~= 0 then
    if targetUnitId == Units.boss then
      ERG.ClearArena()
    end
    if Units.enemy[targetUnitId] then
      local callback = Units.enemy[targetUnitId]
      if type(callback) == "function" then
        callback(false, targetUnitId)
      end
      Units.enemy[targetUnitId] = nil
    end
  end
end
