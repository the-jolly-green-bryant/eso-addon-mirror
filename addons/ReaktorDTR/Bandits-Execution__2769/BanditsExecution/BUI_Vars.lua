BUIE.Defaults = {
  ExecutionThreshold         = 25,
  ExecutionIcon              = true,
  ExecutionChangeTargetColor = true,
  ExecutionTargetColor       = BUIE.Color(255, 0, 0),
  ExecutionTargetColor1      = BUIE.Color(255, 40, 70),
  ExecutionSound             = false,
  ExecutionSoundType         = "Objective_Complete",
}

function BUIE.Vars.Initialize()
  BUIE.Vars = ZO_SavedVars:NewAccountWide('BUIE_VARS', 1, nil, BUIE.Defaults)
end