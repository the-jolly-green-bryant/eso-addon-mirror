OCH = OCH or {}
local OCH = OCH
OCH.ShaperOfFlesh = {
  numChannelersDone = 0,
  numShapersKilled = 0,
  
  channelersIdentified = {},
  chargeIcons = {},
  daedrothSpawnIcons = {},
}

OCH.ShaperOfFlesh.constants = {
  shaper_alive_buff_id = 232560, -- Meat Spawner Buff on Shaper of Flesh while they are alive
  meat_spawner_id = 235735, -- Buff on Shaper of Flesh when summoning adds
  charge_id = 236496, -- Ogrim Charge

  shaper_of_flesh_shield_id = 232511, -- Shield buff on Shaper of Flesh when Channeler is alive
  channeler_shield_id = 232510, -- Shield buff on Channelers while there are Shapers of Flesh to be killed

  channeler_name = "Channeler",

  channeler_ability_ids = {
    [240982] = true, -- Slice
    [241047] = true, -- Coldfire Barrage
    [240984] = true, -- Heavy Strike
    [240983] = true, -- Kick
    [241024] = true, -- Soul Cleave
    [240986] = true, -- Sweeping Strike
    [240981] = true, -- Chop
  },

  daedroth_spawn_event_name = OCH.name .. "DaedrothSpawnNotifier",
}

function OCH.ShaperOfFlesh.Init()
  OCH.ShaperOfFlesh.numChannelersDone = 0
  OCH.ShaperOfFlesh.numShapersKilled = 0
  OCH.ShaperOfFlesh.channelersIdentified = {}
  OCH.ShaperOfFlesh.ClearIcons()
  EVENT_MANAGER:UnregisterForUpdate(OCH.ShaperOfFlesh.constants.daedroth_spawn_event_name)
end

function OCH.ShaperOfFlesh.ClearIcons()
  OCH.DiscardPositionIconList(OCH.ShaperOfFlesh.chargeIcons)
  OCH.ShaperOfFlesh.chargeIcons = {}
  OCH.DiscardPositionIconList(OCH.ShaperOfFlesh.daedrothSpawnIcons)
  OCH.ShaperOfFlesh.daedrothSpawnIcons = {}
end

function OCH.ShaperOfFlesh.OgrimCharge(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 100 then
    OCH.Alert("Ogrim", "Charge", 0xCC8747FF, abilityId, SOUNDS.DUEL_START, 1200)
    OCH.AddIconForDuration(OCH.GetTagForId(targetUnitId), "OsseinCageHelper/icons/meeting-point.dds", hitValue)

    zo_callLater(function () OCH.ShaperOfFlesh.OgrimChargeGroundIcon(targetUnitId, 1200) end, hitValue)
  end
end

function OCH.ShaperOfFlesh.OgrimChargeGroundIcon(targetUnitId, duration)
  local icon = OCH.AddGroundIconOnPlayerForDuration(OCH.GetTagForId(targetUnitId), "OsseinCageHelper/icons/meeting-point.dds", duration)
  table.insert(OCH.ShaperOfFlesh.chargeIcons, icon)
end

function OCH.ShaperOfFlesh.MeatSpawner(abilityId, result, targetType, sourceName, sourceUnitId, targetUnitId, hitValue)
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    local displaySourceName = sourceName or GetUnitDisplayName(OCH.GetTagForId(sourceUnitId)) or ""
    local displayTargetName = GetUnitDisplayName(OCH.GetTagForId(targetUnitId)) or ""
    OCH:Trace(1, string.format(
      "Meat Spawner - Ability: %s, ID: %d, Hit Value: %d, Source name: %s, Target name: %s",
      GetFormattedAbilityName(abilityId), abilityId, hitValue, displaySourceName, displayTargetName
    ))
  end
end

function OCH.ShaperOfFlesh.ShaperOfFleshShieldFaded(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_EFFECT_FADED then
    OCH.ShaperOfFlesh.numChannelersDone = OCH.ShaperOfFlesh.numChannelersDone + 1
    if OCH.savedVariables.showChannelerDone then
      OCH.Alert("", string.format("Channeler #%d: DONE", OCH.ShaperOfFlesh.numChannelersDone), 0x99CCFFFF, nil, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
    end

    if OCH.savedVariables.showDaedrothSpawn and OCH.ShaperOfFlesh.numChannelersDone == 4 then
      OCH.ShaperOfFlesh.AddDaedrothSpawnPointIcons()
    end
  end
end

function OCH.ShaperOfFlesh.AddDaedrothSpawnPointIcons()
  OCH.ShaperOfFlesh.daedrothSpawnIcon1 = OCH.AddGroundCustomIcon(
    216014, 32952, 74279,
    "OsseinCageHelper/icons/daedroth.dds"
  )
  OCH.ShaperOfFlesh.daedrothSpawnIcon2 = OCH.AddGroundCustomIcon(
    213063, 32948, 74771,
    "OsseinCageHelper/icons/daedroth.dds"
  )
  OCH.ShaperOfFlesh.daedrothSpawnIcons = {
    OCH.ShaperOfFlesh.daedrothSpawnIcon1,
    OCH.ShaperOfFlesh.daedrothSpawnIcon2,
  }
end

function OCH.ShaperOfFlesh.ShaperOfFleshKilled(abilityId, result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_EFFECT_FADED then
    OCH.ShaperOfFlesh.numShapersKilled = OCH.ShaperOfFlesh.numShapersKilled + 1
    if OCH.ShaperOfFlesh.numShapersKilled == 4 then
      if OCH.savedVariables.showDaedrothSpawn then
        OCH.ShaperOfFlesh.DaedrothSpawnAlert()
        OCH.ShaperOfFlesh.DaedrothSpawnNotifyLoop()
      end
    end
  end
end

function OCH.ShaperOfFlesh.DaedrothSpawnAlert()
  OCH.Alert("Imminent", "Daedroth Spawn", 0xFF6600FF, nil, SOUNDS.DUEL_BOUNDARY_WARNING, 2000)
end

function OCH.ShaperOfFlesh.DaedrothSpawnNotifyLoop()
  local name = OCH.ShaperOfFlesh.constants.daedroth_spawn_event_name
  EVENT_MANAGER:RegisterForUpdate(name, 50000, 
    function()
      if OCH.status.isShaperOfFlesh then
        OCH.ShaperOfFlesh.DaedrothSpawnAlert()
      else
        EVENT_MANAGER:UnregisterForUpdate(name)
      end
    end 
  )
end

function OCH.ShaperOfFlesh.UpdateTick(timeSec)

end
