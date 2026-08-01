LCH = LCH or {}
local LCH = LCH
LCH.Xoryn = {
  knotHolder = nil,

  lastFluctuatingCurrent = 0,
  fluctuatingCurrentDuration = 0,
  isFluctuatingActive = false,
  fluctuatingHolder = nil,

  lastOverloadedCurrent = 0,
  overloadedCurrentDuration = 0,

  activeIcons = {}
}

LCH.Xoryn.constants = {
  splintered_burst_id = 219799, -- Crystal Atronach AOE On Tank
  glass_stomp_id = 219797, -- Splintered Shards cast ID
  arcane_conveyance_cast_id = 223024, -- Tether cast
  arcane_conveyance_debuff_id = 223060, -- Tether debuff
  lustrous_javelin_id = 223546, -- Mantikora Javelin
  necrotic_barrage_id = 223198, -- Necrotic Barrage
  accelerating_charge_id = 214542, -- Channel before chain lightning
  fluctuating_current_id = 214597, -- Debuff when holding it
  overloaded_current_id = 214745, -- Debuff from holding/dropping fluctuating current
  tempest_id = 215107, -- Groupwide line mechanic from mirrors
  fluctuating_max_time = 15.0, -- Max time you can hold fluctuating current before death
  structured_entropy_id = 126371,
  knot_carry_id = 213477, -- When a user picks up the knot
}

function LCH.Xoryn.Init()
  LCH.Xoryn.knotHolder = nil

  LCH.Xoryn.lastFluctuatingCurrent = GetGameTimeSeconds()
  LCH.Xoryn.fluctuatingCurrentDuration = 16 -- Time to first fluctuating when fight starts
  LCH.Xoryn.isFluctuatingActive = false
  LCH.Xoryn.fluctuatingHolder = nil

  LCH.Xoryn.lastOverloadedCurrent = 0
  LCH.Xoryn.overloadedCurrentDuration = 0
end

-- [!] adjust label scale and draw order
function LCH.Xoryn.adjustLabelForIcon(icon)
  local order = icon.ctrl:GetDrawLevel() + 1
  icon.myLabel:SetDrawLevel( order )
end

function LCH.Xoryn.KnotCarry(result, targetType, targetUnitId, hitValue)
  if (result == ACTION_RESULT_EFFECT_GAINED_DURATION) then
    LCH.Xoryn.knotHolder = LCH.GetNameForId(targetUnitId)
  elseif (result == ACTION_RESULT_EFFECT_FADED) then
    LCH.Xoryn.knotHolder = nil
  end
end

function LCH.Xoryn.SplinteredBurst(result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN then
    -- if targetType == COMBAT_UNIT_TYPE_PLAYER then
    --   LCH.Alert("", "Splintered Burst", 0x66CCFFFF, LCH.Xoryn.constants.glass_stomp_id, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
    --   CombatAlerts.AlertCast(LCH.Xoryn.constants.glass_stomp_id, "Splintered Burst", hitValue, {-2, 1})
    -- end

    LCH.AddIconForDuration(
      LCH.GetTagForId(targetUnitId),
      "LucentCitadelHelper/icons/crystal-burst.dds",
      hitValue
    )
  end
end

function LCH.Xoryn.ArcaneConveyanceIncoming(result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 1000 then
    LCH.Alert("", "Arcane Conveyance Incoming", 0xFFD700FF, LCH.Xoryn.constants.arcane_conveyance_cast_id, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
  end
end

function LCH.Xoryn.ArcaneConveyance(result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    --if targetType == COMBAT_UNIT_TYPE_PLAYER then
    --  LCH.Alert("", "Arcane Conveyance (you)", 0xFFD700FF, LCH.Xoryn.constants.arcane_conveyance_cast_id, SOUNDS.DUEL_START, 2000)
    --end

    LCH.AddIconForDuration(
      LCH.GetTagForId(targetUnitId),
      "LucentCitadelHelper/icons/death-warning.dds",
      hitValue
    )
  elseif result == ACTION_RESULT_EFFECT_FADED then
    LCH.RemoveIcon(LCH.GetTagForId(targetUnitId))
  end
end

function LCH.Xoryn.NecroticBarrage(result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 500 and LCH.savedVariables.showNecroticBarrage then
    LCH.Alert("Necrotic Barrage", LCH.Xoryn.knotHolder, 0xBF40BFFF, LCH.Xoryn.constants.necrotic_barrage_id, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
    CombatAlerts.AlertCast(LCH.Xoryn.constants.necrotic_barrage_id, nil, hitValue, {-3, 0})
  end
end

function LCH.Xoryn.AcceleratingCharge(result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 2000 then
    --LCH.Alert("", "Chain Lightning", 0xFFD666FF, LCH.Xoryn.constants.accelerating_charge_id, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
    CombatAlerts.CastAlertsStart(LCH.Xoryn.constants.accelerating_charge_id, "Chain Lightning", hitValue + 2900, nil, nil, { hitValue, "Block!", 1, 0.4, 0, 0.5, SOUNDS.FRIEND_INVITE_RECEIVED })
  end
end

function LCH.Xoryn.Tempest(result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 500 then
    --LCH.Alert("", "Tempest", 0x6082B6FF, LCH.Xoryn.constants.tempest_id, SOUNDS.BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM, 2000)
    CombatAlerts.CastAlertsStart(LCH.Xoryn.constants.tempest_id, "Tempest", 8000, 10000, nil, nil)
  end
end

function LCH.Xoryn.FluctuatingCurrent(result, targetType, targetUnitId, hitValue)
  local borderId = "fluctuatingCurrent"

  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    LCH.Xoryn.isFluctuatingActive = true
    LCH.Xoryn.lastFluctuatingCurrent = GetGameTimeSeconds()
    LCH.Xoryn.fluctuatingCurrentDuration = hitValue / 1000
    
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      --LCH.Alert("", "Fluctuating Current (you)", 0xFFD666FF, LCH.Xoryn.constants.fluctuating_current_id, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
      CombatAlerts.ScreenBorderEnable(0x22AAFF99, hitValue, borderId)
    end

    local unitTag = LCH.GetTagForId(targetUnitId)
    LCH.Xoryn.fluctuatingHolder = GetUnitDisplayName(unitTag)

    LCH.AddIconForDuration(
      unitTag,
      "LucentCitadelHelper/icons/electric-empty.dds",
      hitValue
    )
    LCH.Xoryn.activeIcons[targetUnitId] = "fluctuating"
    LCH.Xoryn.createFluctuatingIconTextControls(unitTag, GetGameTimeSeconds())

  elseif result == ACTION_RESULT_EFFECT_FADED then
    LCH.Xoryn.isFluctuatingActive = false

    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      CombatAlerts.ScreenBorderDisable(borderId)
    end

    LCH.Xoryn.removeFluctuatingIconTextControls(LCH.GetTagForId(targetUnitId))

    -- The overloaded buff happens before fluctuating falls off, so calling LCH.RemoveIcon() would remove the overloaded icon
    if LCH.Xoryn.activeIcons[targetUnitId] == "fluctuating" then
      LCH.RemoveIcon(LCH.GetTagForId(targetUnitId))
      LCH.Xoryn.activeIcons[targetUnitId] = nil
    end
  end
end

function LCH.Xoryn.createFluctuatingIconTextControls(unitTag, beginTime)
  -- check if OdySupportIcons is active and the affected unit is a player
  if LCH.hasOSI() and IsUnitPlayer(unitTag) then
    -- retrieve the displayname of the affected player
    local displayName = GetUnitDisplayName( unitTag )
    -- [!] retrieve the icon object for the affected player
    local icon = OSI.GetIconForPlayer( displayName )
    if icon then
      -- [!] create a label control if no custom control is available
      if not icon.myLabel then
        icon.myLabel = icon.ctrl:CreateControl(icon.ctrl:GetName() .. "Label", CT_LABEL)
        icon.myLabel:SetAnchor(CENTER, icon.ctrl, CENTER, 0, 0)
        icon.myLabel:SetFont("$(BOLD_FONT)|42|outline")
        icon.myLabel:SetScale(3)
        icon.myLabel:SetDrawLayer(DL_BACKGROUND)
        icon.myLabel:SetDrawTier(DT_LOW)
        icon.myLabel:SetColor(0.9, 0.9, 0.9, 0.85)
      end
      -- [!] adjust label for icon
      LCH.Xoryn.adjustLabelForIcon(icon)

      -- [!] update custom label and show it
      icon.myLabel:SetText(tostring(0))
      icon.myLabel:SetHidden(false)
      -- [!] update custom timer
      icon.startTimer = beginTime
    end
  end
end

function LCH.Xoryn.removeFluctuatingIconTextControls(unitTag)
  -- check if OdySupportIcons is active and the affected unit is a player
  if LCH.hasOSI() and IsUnitPlayer(unitTag) then
    -- retrieve the displayname of the affected player
    local displayName = GetUnitDisplayName( unitTag )
    -- [!] retrieve the icon object for the affected player
    local icon = OSI.GetIconForPlayer( displayName )
    if icon then
      -- [!] hide custom label
      icon.myLabel:SetHidden(true)
    end
  end
end

function LCH.Xoryn.OverloadedCurrent(result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      LCH.Xoryn.lastOverloadedCurrent = GetGameTimeSeconds()
      LCH.Xoryn.overloadedCurrentDuration = hitValue / 1000
    end

    if LCH.savedVariables.showOverloadedCurrentIcons then
      LCH.AddIconForDuration(
        LCH.GetTagForId(targetUnitId),
        "LucentCitadelHelper/icons/no-electric.dds",
        hitValue
      )
      LCH.Xoryn.activeIcons[targetUnitId] = "overloaded"
    end
    
  elseif result == ACTION_RESULT_EFFECT_FADED then
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      LCH.Xoryn.overloadedCurrentDuration = 0
    end

    if LCH.savedVariables.showOverloadedCurrentIcons or LCH.Xoryn.activeIcons[targetUnitId] == "overloaded" then
      LCH.RemoveIcon(LCH.GetTagForId(targetUnitId))
      LCH.Xoryn.activeIcons[targetUnitId] = nil
    end
  end
end

function LCH.Xoryn.UpdateTick(timeSec)
  LCHStatus:SetHidden(
    not (LCH.savedVariables.showFluctuatingCurrentHolder or LCH.savedVariables.showFluctuatingCurrentTimer or 
         LCH.savedVariables.showOverloadedCurrentTimer or 
         LCH.savedVariables.showXynizataBeamTime or LCH.savedVariables.showXynizataChannelTimer)
  )

  LCH.Xoryn.FluctuatingCurrentUpdateTick(timeSec)
  LCH.Xoryn.FluctuatingCurrentIconUpdateTick(timeSec)
  LCH.Xoryn.OverloadedCurrentUpdateTick(timeSec)
end

function LCH.Xoryn.FluctuatingCurrentUpdateTick(timeSec)
  LCHStatusLabelXoryn1:SetHidden(not (LCH.savedVariables.showFluctuatingCurrentHolder))
  LCHStatusLabelXoryn1Value:SetHidden(not (LCH.savedVariables.showFluctuatingCurrentHolder))
  LCHStatusLabelXoryn2:SetHidden(not (LCH.savedVariables.showFluctuatingCurrentTimer))
  LCHStatusLabelXoryn2Value:SetHidden(not (LCH.savedVariables.showFluctuatingCurrentTimer))

  local delta = timeSec - LCH.Xoryn.lastFluctuatingCurrent
  local timeLeft = LCH.Xoryn.fluctuatingCurrentDuration - delta

  if LCH.Xoryn.isFluctuatingActive then
    LCHStatusLabelXoryn1Value:SetText(string.format("%s [%s]", LCH.Xoryn.fluctuatingHolder, LCH.Xoryn.getActiveFluctuatingText(delta)))

    LCHStatusLabelXoryn2Value:SetText(string.format("%s", LCH.Xoryn.getActiveFluctuatingText(timeLeft)))
    LCHStatusLabelXoryn2Value:SetColor(LCH.UnpackRGBA(0xFFD666FF))
  else
    LCHStatusLabelXoryn1Value:SetText("-")
    
    if LCH.status.isHMBoss then
      -- HM: total duration between new Fluctuating casts is ~61s, total Fluctuating duration is 60s
      timeLeft = timeLeft + 1
    else
      -- HM: total duration between new Fluctuating casts is ~61s, total Fluctuating duration is 29s
      timeLeft = timeLeft + 32
    end

    LCHStatusLabelXoryn2Value:SetText("INCOMING: " .. LCH.Xoryn.getInactiveFluctuatingText(timeLeft))
    LCHStatusLabelXoryn2Value:SetColor(LCH.UnpackRGBA(0xFF8500FF))
  end
end

function LCH.Xoryn.FluctuatingCurrentIconUpdateTick(timeSec)
  -- update icons even out of combat
  -- check if OdySupportIcons is active
  if LCH.hasOSI() then
    -- [!] search for group members with custom timer
    for i = 1, GROUP_SIZE_MAX do
      local name = GetUnitDisplayName( "group" .. i )
      local icon = OSI.GetIconForPlayer( name )

      -- [!] update custom label if icon and timer are available
      if icon and icon.startTimer then
        local timeElapsed = timeSec - icon.startTimer
        if timeElapsed > (LCH.Xoryn.constants.fluctuating_max_time - 3) then
          if math.fmod(zo_floor(timeElapsed*10), 10) < 5 then
            icon.myLabel:SetColor(0.9, 0.9, 0.9, 0.85)
          else
            icon.myLabel:SetColor(0.9, 0, 0, 0.85)
          end
        else
          icon.myLabel:SetColor(0.9, 0.9, 0.9, 0.85)
        end
        icon.myLabel:SetText(tostring(zo_floor(timeElapsed)))
        LCH.Xoryn.adjustLabelForIcon(icon)
      end
    end
  end
end

function LCH.Xoryn.getActiveFluctuatingText(seconds)
  if seconds > 0 then 
    return string.format("%.0f", seconds) .. "s"
  else
    return "-"
  end
end

function LCH.Xoryn.getInactiveFluctuatingText(seconds)
  if seconds > 5 then 
    return string.format("%.0f", seconds) .. "s"
  elseif seconds > 0 then 
    return string.format("%.1f", seconds) .. "s"
  else
    return "NOW"
  end
end

function LCH.Xoryn.OverloadedCurrentUpdateTick(timeSec)
  LCHStatusLabelXoryn3:SetHidden(not (LCH.savedVariables.showOverloadedCurrentTimer))
  LCHStatusLabelXoryn3Value:SetHidden(not (LCH.savedVariables.showOverloadedCurrentTimer))

  local delta = timeSec - LCH.Xoryn.lastOverloadedCurrent
  local timeLeft = LCH.Xoryn.overloadedCurrentDuration - delta

  LCHStatusLabelXoryn3Value:SetText(LCH.Xoryn.getOverloadedText(timeLeft))
  local color = (timeLeft > 0 and 0xFF0000FF or 0x00FF00FF)
  LCHStatusLabelXoryn3Value:SetColor(LCH.UnpackRGBA(color))
end

function LCH.Xoryn.getOverloadedText(seconds)
  if seconds > 5 then 
    return string.format("%.0f", seconds) .. "s "
  elseif seconds > 0 then 
    return string.format("%.1f", seconds) .. "s "
  else
    return "NO"
  end
end