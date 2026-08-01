LCH = LCH or {}
local LCH = LCH
LCH.Xynizata = {
  xynizataActive = false,
  lastPiercingBeam = 0,
  isFirstPiercingBeam = true,
  lastVitrify = 0,
  isFirstVitrify = true,

  lastCast = 0,
}

LCH.Xynizata.constants = {
  crystal_bolt_id = 219073,
  crystal_burst_id = 219076,

  piercing_beam_id = 219165,
  piercing_beam_first_cd = 14.0,
  piercing_beam_cd = 32.0,

  vitrify_id = 219083,
  vitrify_first_cd = 9.0,
  vitrify_cd = 20.0,
}

function LCH.Xynizata.Init()
  if not LCH.Xynizata.xynizataActive then
    LCH.Xynizata.xynizataActive = true

    LCH.Xynizata.lastPiercingBeam = GetGameTimeSeconds()
    LCH.Xynizata.isFirstPiercingBeam = true

    LCH.Xynizata.lastVitrify = GetGameTimeSeconds()
    LCH.Xynizata.isFirstVitrify = true

    LCH.Xynizata.lastCast = GetGameTimeSeconds()
  end
end

function LCH.Xynizata.CrystalBolt(result, targetType, targetUnitId, hitValue)
  LCH.Xynizata.Init()

  LCH.Xynizata.lastCast = GetGameTimeSeconds()
end

function LCH.Xynizata.CrystalBurst(result, targetType, targetUnitId, hitValue)
  LCH.Xynizata.Init()

  LCH.Xynizata.lastCast = GetGameTimeSeconds()
end

function LCH.Xynizata.PiercingBeam(result, targetType, targetUnitId, hitValue)
  LCH.Xynizata.Init()

  if result == ACTION_RESULT_BEGIN and hitValue > 500 then
    LCH.Alert("Xynizata", "Piercing Beam", 0x5D3FD3FF, LCH.Xynizata.constants.piercing_beam_id, SOUNDS.OBJECTIVE_DISCOVERED, 2000)

    LCH.Xynizata.lastPiercingBeam = GetGameTimeSeconds()
    LCH.Xynizata.isFirstPiercingBeam = false
  end

  LCH.Xynizata.lastCast = GetGameTimeSeconds()
end

function LCH.Xynizata.Vitrify(result, targetType, targetUnitId, hitValue)
  LCH.Xynizata.Init()

  if result == ACTION_RESULT_BEGIN and hitValue > 500 then
    if LCH.savedVariables.showXynizataBeamTime then
      LCH.Alert("Xynizata", "Vitrify (Interrupt)", 0xDA70D6FF, LCH.Xynizata.constants.vitrify_id, SOUNDS.FRIEND_INVITE_RECEIVED, 2000)
    end
    LCH.Xynizata.lastVitrify = GetGameTimeSeconds()
    LCH.Xynizata.isFirstVitrify = false
  end

  LCH.Xynizata.lastCast = GetGameTimeSeconds()
end

function LCH.Xynizata.UpdateTick(timeSec)
  if LCH.Xynizata.xynizataActive then
    if LCH.savedVariables.showXynizataBeamTime or LCH.savedVariables.showXynizataChannelTimer then
      LCHStatus:SetHidden(false)
    end
    
    LCH.Xynizata.DetectIfDead(timeSec)

    LCH.Xynizata.PiercingBeamUpdateTick(timeSec)
    LCH.Xynizata.VitrifyUpdateTick(timeSec)
  end
end

function LCH.Xynizata.PiercingBeamUpdateTick(timeSec)
  LCHStatusLabelXoryn4:SetHidden(not (LCH.savedVariables.showXynizataBeamTimer and LCH.Xynizata.xynizataActive))
  LCHStatusLabelXoryn4Value:SetHidden(not (LCH.savedVariables.showXynizataBeamTimer and LCH.Xynizata.xynizataActive))

  local delta = timeSec - LCH.Xynizata.lastPiercingBeam

  local timeLeft = 0
  if LCH.Xynizata.isFirstPiercingBeam then
    timeLeft = LCH.Xynizata.constants.piercing_beam_first_cd - delta
  else
    timeLeft = LCH.Xynizata.constants.piercing_beam_cd - delta
  end

  LCHStatusLabelXoryn4Value:SetText(LCH.GetSecondsRemainingString(timeLeft))
end

function LCH.Xynizata.VitrifyUpdateTick(timeSec)
  LCHStatusLabelXoryn5:SetHidden(not (LCH.savedVariables.showXynizataChannelTimer and LCH.Xynizata.xynizataActive))
  LCHStatusLabelXoryn5Value:SetHidden(not (LCH.savedVariables.showXynizataChannelTimer and LCH.Xynizata.xynizataActive))

  local delta = timeSec - LCH.Xynizata.lastVitrify

  local timeLeft = 0
  if LCH.Xynizata.isFirstVitrify then
    timeLeft = LCH.Xynizata.constants.vitrify_first_cd - delta
  else
    timeLeft = LCH.Xynizata.constants.vitrify_cd - delta
  end

  LCHStatusLabelXoryn5Value:SetText(LCH.GetSecondsRemainingString(timeLeft))
end

function LCH.Xynizata.DetectIfDead(timeSec)
  -- Hacky workaround to detect if Xynizata is dead for now if no casts in last 12s.
  if LCH.Xynizata.xynizataActive then
    local timeNow = GetGameTimeSeconds()
    if timeNow - LCH.Xynizata.lastCast > 12 then
      LCH.Xynizata.xynizataActive = false
    end
  end
end