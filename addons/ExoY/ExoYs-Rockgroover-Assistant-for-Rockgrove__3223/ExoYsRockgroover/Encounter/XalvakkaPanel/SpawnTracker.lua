Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.xalvakka = ERG.xalvakka or {}
local Xalvakka = ERG.xalvakka

local spawnData_old = {
  [1] = --ground floor
  {
    [15000] = "Iron Attronach",
    [75000] = "Havocrel Goliath",
    [135000] = "Iron Attronach",
    [195000] = "Havocrel Goliath",
  },
  [2] = --intermediate floor
  {
    [15000] = "Iron Attronach",
    [75000] = "Havocrel Goliath",
    [135000] = "Iron Attronach",
    [195000] = "Havocrel Goliath",
  },
  [3] = --final floor
  {
    [15000] = "Iron Attronach",
    [75000] = "Havocrel Goliath",
    [135000] = "Iron Attronach",
    [195000] = "Havocrel Goliath",
  },
}

local spawnData = {
  [15000] = "Iron Attronach",
  [30000] = "Big Adds",
  [75000] = "Havocrel Goliath",
  [90000] = "Big Adds",
  [135000] = "Iron Attronach",
  [150000] = "Big Adds",
  [195000] = "Havocrel Goliath",
}

--[[
 Spawns:
 15 Iron
 30 big ( ) --> oft weiter als 100 auseinander
 small nicht detected?
 75 mini
 89/91?
]]


function Xalvakka.InitializeSpawnTracker()
  local function OnAddSpawn()
    if not ERG.combat.state then return end
    if ERG.arena.boss ~= "xalvakka" then return end
    local currentTime = GetGameTimeMilliseconds()

    -- handle multiple events
    if currentTime - Xalvakka.lastSpawn < 3000 then return end
    Xalvakka.lastSpawn = currentTime

    local floorTime = currentTime - Xalvakka.referenceTime
    --d("ERG Spawn at "..floorTime)

    -- interprete unit
    local inaccuracy = 5000

    for spawnTime, unitName in pairs(spawnData) do
      if floorTime > (spawnTime - inaccuracy) and floorTime < (spawnTime + inaccuracy) then
          CombatAlerts.Alert(unitName, "Add Spawn", ERG.GetCombatAlertsColor({1,0,0,1}), nil, 1500)
        break
      end
    end
  end

  ERG.EM:RegisterForEvent(Xalvakka.name.."AddSpawn", EVENT_COMBAT_EVENT, OnAddSpawn)
  ERG.EM:AddFilterForEvent(Xalvakka.name.."AddSpawn", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 10298)

  --local function Output(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  --  d(zo_strformat("ERG VolatailShell <<2>> (<<1>>)", GetGameTimeMilliseconds()-Xalvakka.referenceTime, result))
  --end

  --ERG.EM:RegisterForEvent(Xalvakka.name.."VolatailShell1", EVENT_COMBAT_EVENT, Output)
  --ERG.EM:AddFilterForEvent(Xalvakka.name.."VolatailShell1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 150529)

  -- 2200, 2240, 2245, 2250
  --ERG.EM:RegisterForEvent(Xalvakka.name.."VolatailShell2", EVENT_COMBAT_EVENT, Output)
  --ERG.EM:AddFilterForEvent(Xalvakka.name.."VolatailShell2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 149294 )
end
