LC = LC or {}
local LC = LC
LC.Trash = {}

function LC.Trash.CombatEvent(result, abilityId, targetType, targetUnitId, sourceName, hitValue)
  -- Swashbuckler: Targeted
  if result == ACTION_RESULT_EFFECT_GAINED and abilityId == LC.data.swashbuckler_targeted then
    local isDPS, isHeal, isTank = GetPlayerRoles()
    if LC.units ~= nil and LC.units[targetUnitId] ~= nil then
      if (isTank or isHeal) and LC.savedVariables.showSwashbucklerOnUser then
        CombatAlerts.Alert(nil, "Swashbuckler targets " .. LC.units[targetUnitId].name, 0xCCCCCCFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
      end
      local unitTag = LC.units[targetUnitId].tag
      if unitTag ~= nil and LC.savedVariables.showSwashbucklerTargetIcon then
        -- Note the icon will remain for the full 6s even if the Swashbuckler dies.
        LC.AddIconForDuration(unitTag, "LucentCitadel/icons/target.dds", 6000)
      end
    end
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      if LC.savedVariables.showSwashbucklerTargeted then
        -- Show chase bar
        local action = {6000, "BLOCK!", 0.2, 0.57, 1, 0.9, nil}
        -- TODO Implement canceling cast bar if Swashbuckler dies
        CombatAlerts.CastAlertsStart(LC.data.swashbuckler_targeted, "Swashbuckler targets you", 6000, 6000, nil, action)
        PlaySound(SOUNDS.DUEL_START)
      end
    end
  end

  if result == ACTION_RESULT_EFFECT_FADED and abilityId == LC.data.swashbuckler_targeted then
    local isDPS, isHeal, isTank = GetPlayerRoles()
    -- if I myself am a tank, I want to see that a Swashbuckler is now lose.
    -- TODO: test if this shows after Swashbuckler dies if the buff is ongoing (<6s)
    if isTank and LC.savedVariables.showSwashbucklerLoose then
      CombatAlerts.Alert(nil, "Swashbuckler loose", 0xCCAAAAFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
    end
  end

  if result == ACTION_RESULT_BEGIN and abilityId == LC.data.overseer_cascading_boot and targetType == COMBAT_UNIT_TYPE_PLAYER then
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, {-2, 1})
  end

  if result == ACTION_RESULT_BEGIN and abilityId == LC.data.keelcutter_expelled_fire and targetType == COMBAT_UNIT_TYPE_PLAYER then
    CombatAlerts.Alert("DO NOT MOVE", GetAbilityName(LC.data.keelcutter_expelled_fire), 0xFF3333FF, SOUNDS.CHAMPION_POINTS_COMMITTED, hitValue)
  end

  if result == ACTION_RESULT_EFFECT_GAINED and abilityId == LC.data.brewmaster_potion then
    if LC.savedVariables.showBrewmasterPotions and targetUnitId ~= nil and LC.units[targetUnitId] ~= nil then
      LC.AddGroundIconOnPlayerForDuration(
        LC.units[targetUnitId].tag,
        "LucentCitadel/icons/potion.dds",
        15000)
    end
  end
end

function LC.Trash.EffectChanged(changeType, abilityId, unitTag, beginTime, endTime)
  -- Swashbuckler: Aperture
  if changeType == EFFECT_RESULT_GAINED and abilityId == LC.data.swashbuckler_aperture and unitTag == "player" then
    if LC.savedVariables.showSwashbucklerAperture then
      -- Show chase bar
      --local duration = endTime - beginTime
      local duration = 5000
      local action = {duration, "KITE BACK", 1, 0.57, 0.2, 0.9, nil}
      -- TODO Implement canceling cast bar if Swashbuckler dies
      CombatAlerts.CastAlertsStart(LC.data.swashbuckler_targeted, "Kite Daggers", duration, duration, nil, action)
      PlaySound(SOUNDS.DUEL_START)
    end
  end
end

function LC.Trash.DrawLeversForGroup(groupNum)
  if not LC.savedVariables.showLeversIcons then
    return
  end
  -- Update levers.
  for i = 1, 3 do
    local index = groupNum*3 + i
    table.insert(
      LC.status.leverIcons,
      LC.AddGroundIcon(
        LC.data.levers[index][1],
        LC.data.levers[index][2] + 200,
        LC.data.levers[index][3]))
  end
end

function LC.Trash.ClearLeverIcons()
  if #LC.status.leverIcons > 0 and LC.hasOSI() then
    for k,v in pairs(LC.status.leverIcons) do
      OSI.DiscardPositionIcon(v)
    end
    LC.status.leverIcons = {}
  end
end

function LC.Trash.ResetLeversState()
  -- TODO: Move this to clearui out of combat?
  LC.status.lastBestGroup = -1
  LC.Trash.ClearLeverIcons()
end

function LC.Trash.ShouldDisplayLevers()
  if not LC.savedVariables.showLeversPanel then
    return false
  end

  -- Do not check distances if you're not in the side-trash zones.
  -- Use simple comparisons before doing expensive distance calculations.
  if not LC.IsPlayerInBox(
      LC.data.lightning_bounds[1],
      LC.data.lightning_bounds[2],
      LC.data.lightning_bounds[3],
      LC.data.lightning_bounds[4]) and 
    not LC.IsPlayerInBox(
      LC.data.poison_bounds[1],
      LC.data.poison_bounds[2],
      LC.data.poison_bounds[3],
      LC.data.poison_bounds[4]) then
    return false
  end

  -- check I am close to any of the places
  local mn = 1000000000
  for k, v in pairs(LC.data.levers) do
    local d = LC.GetPlayerToPlaceDist(v[1], v[2], v[3])
    if d < mn then
      mn = d
    end
  end
  return mn < 2000*2000 -- 20m. max distance to render the lever check panel.
end

-- Returns whether dist1 is a better lever guess than dist2.
-- Pre: They can't both be empty.
function LC.Trash.BetterLeverDist(dist1, dist2)
  --d("[LC] betterleverdist called with " .. #dist1 .. ", " .. #dist2)
  if #dist1 < 3 or #dist2 < 3 then
    d("[LC] ERROR: BetterLeverDist dist arrays are incomplete.")
    --return -1
  end
  -- Each value from dist[1], dist[2], dist[3] represents the shortest distance from that lever to any group member.
  -- Heuristic one.
  local onLever1 = 0
  local onLever2 = 0
  local d1Sum = 0
  local d2Sum = 0
  for i=1,3 do
    d1Sum = d1Sum + dist1[i]
    d2Sum = d2Sum + dist2[i]
    if dist1[i] <= 5 then
      onLever1 = onLever1 + 1
    end
    if dist2[i] <= 5 then
      onLever2 = onLever2 + 1
    end
  end

  -- Check which one has more people on levers, otherwise sum of distances.
  if onLever1 > onLever2 then
    return true
  end

  if onLever2 > onLever1 then
    return false
  end

  return d1Sum < d2Sum
end

function LC.Trash.RenderLevers()
  -- testing, 3 entrance icons.
  local bestDist = {}
  local bestGroup = 0

  -- TODO: Optimization: only check poison when in poison bounding box, and same for ligthning.
  -- TODO: Optimization 2: first check if inside bounding box (for 6 diff boxes) then check their icons
  for leverGroup = 0,5 do
    local dist = {}
    for i = 1,3 do
      local index = leverGroup*3 + i

      dist[i] = LC.GetClosestGroupDist(
        LC.data.levers[index][1],
        LC.data.levers[index][2],
        LC.data.levers[index][3])
      dist[i] = math.sqrt(dist[i])/100
    end
    if #bestDist == 0 or LC.Trash.BetterLeverDist(dist, bestDist) then
      bestDist = dist
      bestGroup = leverGroup
    end
  end
  if bestGroup ~= LC.status.lastBestGroup then
    LC.status.lastBestGroup = bestGroup
    LC.Trash.DrawLeversForGroup(bestGroup)
  end

  -- TODO do local label = LCStatusLabelLever1Value and see if it works to simplify.
  if bestDist[1] > 5 then
    LCStatusLabelLever1Value:SetColor(
      LC.data.color.orange[1],
      LC.data.color.orange[2],
      LC.data.color.orange[3])
    LCStatusLabelLever1Value:SetText(string.format("%.3fm", bestDist[1]))
  else
    LCStatusLabelLever1Value:SetColor(
      LC.data.color.green[1],
      LC.data.color.green[2],
      LC.data.color.green[3])
    LCStatusLabelLever1Value:SetText("OK")
  end

  if bestDist[2] > 5 then
    LCStatusLabelLever2Value:SetColor(
      LC.data.color.orange[1],
      LC.data.color.orange[2],
      LC.data.color.orange[3])
    LCStatusLabelLever2Value:SetText(string.format("%.3fm", bestDist[2]))
  else
    LCStatusLabelLever2Value:SetColor(
      LC.data.color.green[1],
      LC.data.color.green[2],
      LC.data.color.green[3])
    LCStatusLabelLever2Value:SetText("OK")
  end

  if bestDist[3] > 5 then
    LCStatusLabelLever3Value:SetColor(
      LC.data.color.orange[1],
      LC.data.color.orange[2],
      LC.data.color.orange[3])
    LCStatusLabelLever3Value:SetText(string.format("%.3fm", bestDist[3]))
  else
    LCStatusLabelLever3Value:SetColor(
      LC.data.color.green[1],
      LC.data.color.green[2],
      LC.data.color.green[3])
    LCStatusLabelLever3Value:SetText("OK")
  end

  LCStatus:SetHidden(false)
  LCStatusLabelLever1:SetHidden(false)
  LCStatusLabelLever1Value:SetHidden(false)
  LCStatusLabelLever2:SetHidden(false)
  LCStatusLabelLever2Value:SetHidden(false)
  LCStatusLabelLever3:SetHidden(false)
  LCStatusLabelLever3Value:SetHidden(false)
end