LCH = LCH or {}
local LCH = LCH
LCH.Orphic = {
  lastThunderThrall = 0,
  isFirstThunderThrall = true,
  lastLightningFlood = 0,
  isFirstLightningFlood = true,
  xorynActive = false,
}

LCH.Orphic.constants = {
  color_change_id = 213913, -- Color change/mirrors mechanic

  thunder_thrall_id = 214383,
  thunder_thrall_first_cd = 8.0, -- how soon Xoryn can first jump
  thunder_thrall_cd = 25.5, -- how often Xoryn jumps

  lightning_flood_id = 214355,
  lightning_flood_first_cd = 3.0, -- how soon Xoryn can cast first cone
  lightning_flood_cd = 21.5, -- how often Xoryn casts cone

  shield_throw_id = 221945, -- Crystal Sentinel Shield Throw

  breakout_id = 220185, -- Debuff falls off when Orphic first becomes active
  xoryn_immune_id = {
    [217987] = true, -- Xoryn defeated
    [219545] = true, -- Xoryn jumps away in execute
  },

  heavy_shock_id = 222071,

  fate_sealer_id = 214311, -- Ball summon
}

-- TODO: Teach Kabs For loops
function LCH.Orphic.AddMirrorIcons()
  if LCH.savedVariables.showMirrorIcons and LCH.hasOSI() then
    if table.getn(LCH.status.MirrorIconNumber1) == 0 then
      table.insert(LCH.status.MirrorIconNumber1, 
        OSI.CreatePositionIcon(
          149311,22871,85560,
          "LucentCitadelHelper/icons/1.dds",
          1 * OSI.GetIconSize()))
    end
    if table.getn(LCH.status.MirrorIconNumber2) == 0 then
      table.insert(LCH.status.MirrorIconNumber2, 
        OSI.CreatePositionIcon(
          151030,22870,86281,
          "LucentCitadelHelper/icons/2.dds",
          1 * OSI.GetIconSize()))
    end
    if table.getn(LCH.status.MirrorIconNumber3) == 0 then
      table.insert(LCH.status.MirrorIconNumber3, 
        OSI.CreatePositionIcon(
          151808,22869,87932,
          "LucentCitadelHelper/icons/3.dds",
          1 * OSI.GetIconSize()))
    end
    if table.getn(LCH.status.MirrorIconNumber4) == 0 then
      table.insert(LCH.status.MirrorIconNumber4, 
        OSI.CreatePositionIcon(
          151158,22864,89721,
          "LucentCitadelHelper/icons/4.dds",
          1 * OSI.GetIconSize()))
    end
    if table.getn(LCH.status.MirrorIconNumber5) == 0 then
      table.insert(LCH.status.MirrorIconNumber5, 
        OSI.CreatePositionIcon(
          149300,22871,90476,
          "LucentCitadelHelper/icons/5.dds",
          1 * OSI.GetIconSize()))
    end
    if table.getn(LCH.status.MirrorIconNumber6) == 0 then
      table.insert(LCH.status.MirrorIconNumber6, 
        OSI.CreatePositionIcon(
          147443,22868,89821,
          "LucentCitadelHelper/icons/6.dds",
          1 * OSI.GetIconSize()))
    end
    if table.getn(LCH.status.MirrorIconNumber7) == 0 then
      table.insert(LCH.status.MirrorIconNumber7, 
        OSI.CreatePositionIcon(
          146799,22869,87913,
          "LucentCitadelHelper/icons/7.dds",
          1 * OSI.GetIconSize()))
    end
    if table.getn(LCH.status.MirrorIconNumber8) == 0 then
      table.insert(LCH.status.MirrorIconNumber8, 
        OSI.CreatePositionIcon(
          147539,22869,86217,
          "LucentCitadelHelper/icons/8.dds",
          1 * OSI.GetIconSize()))
    end
  end
end

function LCH.Orphic.RemoveMirrorIcons()
  LCH.DiscardPositionIconList(LCH.status.MirrorIconNumber1)
  LCH.status.MirrorIconNumber1 = {}

  LCH.DiscardPositionIconList(LCH.status.MirrorIconNumber2)
  LCH.status.MirrorIconNumber2 = {}

  LCH.DiscardPositionIconList(LCH.status.MirrorIconNumber3)
  LCH.status.MirrorIconNumber3 = {}

  LCH.DiscardPositionIconList(LCH.status.MirrorIconNumber4)
  LCH.status.MirrorIconNumber4 = {}

  LCH.DiscardPositionIconList(LCH.status.MirrorIconNumber5)
  LCH.status.MirrorIconNumber5 = {}

  LCH.DiscardPositionIconList(LCH.status.MirrorIconNumber6)
  LCH.status.MirrorIconNumber6 = {}

  LCH.DiscardPositionIconList(LCH.status.MirrorIconNumber7)
  LCH.status.MirrorIconNumber7 = {}
  
  LCH.DiscardPositionIconList(LCH.status.MirrorIconNumber8)
  LCH.status.MirrorIconNumber8 = {}
end

function LCH.Orphic.Init()
  LCH.Orphic.lastThunderThrall = GetGameTimeSeconds()
  LCH.Orphic.isFirstThunderThrall = true
  LCH.Orphic.xorynActive = false
end

function LCH.Orphic.ColorChange(result, targetType, targetUnitId, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 2000 then
    local hitOffset = 1000
    LCH.Alert("", "Color Change", 0x96DED1FF, LCH.Orphic.constants.color_change_id, SOUNDS.BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM, 4000)
    CombatAlerts.CastAlertsStart(LCH.Orphic.constants.color_change_id, "Color Change", hitValue - hitOffset, 12000, nil, nil)
  end
end

function LCH.Orphic.ShieldThrow(result, targetType, targetUnitId, hitValue)
  -- Xoryn Jump Mechanic
  if result == ACTION_RESULT_BEGIN and hitValue > 500 then
    --LCH.Alert("", "Shield Throw", 0xCC8747FF, LCH.Orphic.constants.shield_throw_id, SOUNDS.DUEL_START, 2000)
    CombatAlerts.CastAlertsStart(LCH.Orphic.constants.shield_throw_id, "Shield Throw", hitValue, nil, nil, { hitValue, "Block!", 1, 0.4, 0, 0.5, nil })
  end
end

function LCH.Orphic.ThunderThrall(result, targetType, targetUnitId, hitValue)
  -- Xoryn Jump Mechanic
  if result == ACTION_RESULT_BEGIN and hitValue > 500 then
    LCH.Orphic.xorynActive = true
    LCH.Orphic.lastThunderThrall = GetGameTimeSeconds()
    LCH.Orphic.isFirstThunderThrall = false

    --if targetType == COMBAT_UNIT_TYPE_PLAYER then
    --  LCH.Alert("", "Thunder Thrall", 0xFFD666FF, LCH.Orphic.constants.thunder_thrall_id, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
    --end
  end
end

function LCH.Orphic.LightningFlood(result, targetType, targetUnitId, hitValue)
  -- Xoryn Cone Mechanic
  if result == ACTION_RESULT_BEGIN and hitValue > 500 then
    LCH.Orphic.xorynActive = true
    LCH.Orphic.lastLightningFlood = GetGameTimeSeconds()
    LCH.Orphic.isFirstLightningFlood = false
  end
end

function LCH.Orphic.HeavyShock(result, targetType, targetUnitId, hitValue)
  -- Xoryn Channel Mechanic
  -- TODO(wonder): This isn't working, find actual ability ID
  if result == ACTION_RESULT_BEGIN then
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      LCH.Alert("", "Heavy Shock", 0xFFD666FF, LCH.Orphic.constants.heavy_shock_id, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
    end

    LCH.AddIconForDuration(
      LCH.GetTagForId(targetUnitId),
      "LucentCitadelHelper/icons/electric-danger.dds",
      hitValue
    )
  end
end

function LCH.Orphic.FateSealer(result, targetType, targetUnitId, hitValue)
  -- Ball Summon Mechanic
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    LCH.Alert("", "Summon Fate Pillar", 0xFFD666FF, LCH.Orphic.constants.fate_sealer_id, SOUNDS.DUEL_START, 2000)
  end
end

function LCH.Orphic.Breakout(result, targetType, targetUnitId, hitValue)
  -- Orphic first becomes active when debuff falls off
  if result == ACTION_RESULT_EFFECT_FADED then
    zo_callLater(function () LCH.Orphic.xorynActive = true end, 1000)
  end
end

function LCH.Orphic.XorynImmune(result, targetType, targetUnitId, hitValue)
  -- Detects when Xoryn becomes immune
  if result == ACTION_RESULT_BEGIN then
    LCH.Orphic.xorynActive = false
  end
end

function LCH.Orphic.UpdateTick(timeSec)
  LCHStatus:SetHidden(not (LCH.savedVariables.showXorynJumpTimer or LCH.savedVariables.showXorynConeTimer))

  LCH.Orphic.ThunderThrallUpdateTick(timeSec)
  LCH.Orphic.LightningFloodUpdateTick(timeSec)
end

function LCH.Orphic.ThunderThrallUpdateTick(timeSec)
  LCHStatusLabelOrphic1:SetHidden(not (LCH.savedVariables.showXorynJumpTimer and LCH.Orphic.xorynActive))
  LCHStatusLabelOrphic1Value:SetHidden(not (LCH.savedVariables.showXorynJumpTimer and LCH.Orphic.xorynActive))

  local delta = timeSec - LCH.Orphic.lastThunderThrall

  local timeLeft = 0
  if LCH.Orphic.isFirstThunderThrall then
    timeLeft = LCH.Orphic.constants.thunder_thrall_first_cd - delta
  else
    timeLeft = LCH.Orphic.constants.thunder_thrall_cd - delta
  end

  LCHStatusLabelOrphic1Value:SetText(LCH.GetSecondsRemainingString(timeLeft))
end

function LCH.Orphic.LightningFloodUpdateTick(timeSec)
  LCHStatusLabelOrphic2:SetHidden(not (LCH.savedVariables.showXorynConeTimer and LCH.Orphic.xorynActive))
  LCHStatusLabelOrphic2Value:SetHidden(not (LCH.savedVariables.showXorynConeTimer and LCH.Orphic.xorynActive))

  local delta = timeSec - LCH.Orphic.lastLightningFlood

  local timeLeft = 0
  if LCH.Orphic.isFirstLightningFlood then
    timeLeft = LCH.Orphic.constants.lightning_flood_first_cd - delta
  else
    timeLeft = LCH.Orphic.constants.lightning_flood_cd - delta
  end

  LCHStatusLabelOrphic2Value:SetText(LCH.GetSecondsRemainingString(timeLeft))
end