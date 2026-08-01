----------
-- globals
----------
SprintSens = {}
SprintSens.config = {}
SprintSens.debug = false
SprintSens.name = "SprintSens"

SprintSens.events = {
  worker = SprintSens.name .. ".Worker",
  activation = SprintSens.name .. ".Activation",
  sprintStart = SprintSens.name .. ".SprintStart",
  sprintStop = SprintSens.name .. ".SprintStop",
  indicator = SprintSens.name .. ".Indicator",
  rejector = SprintSens.name .. ".Rejector"
}

--------
-- funcs
--------
function SprintSens.Debug(msg)
  if SprintSens.debug then
    d(msg)
  end
end

function SprintSens.SetSens(value)
  SprintSens.Debug("Sensitivity " .. value)
  SetSetting(SETTING_TYPE_CAMERA, 2, value)
  SetSetting(SETTING_TYPE_CAMERA, 3, value)
end

function SprintSens.SetSprintSens()
  SprintSens.SetSens(SprintSens.config.sprintSens/100)
end

function SprintSens.SetDefaultSens()
  SprintSens.SetSens(SprintSens.config.defaultSens/100)
end

function SprintSens.RegisterLoop(name, handler)
  SprintSens.Debug(name .. " registered")
  EVENT_MANAGER:RegisterForUpdate(name, 5, handler)
end

function SprintSens.UnregisterLoop(name)
  SprintSens.Debug(name .. " unregistered")
  EVENT_MANAGER:UnregisterForUpdate(name)
end

function SprintSens.Indicator()
  return IsPlayerMoving() and not ArePlayerWeaponsSheathed()
end

function SprintSens.Worker()
  if IsShiftKeyDown() and SprintSens.Indicator() then
    SprintSens.SetSprintSens()
  else
    SprintSens.SetDefaultSens()
  end
end

function SprintSens.OnLoad(event, addon)
  if addon == SprintSens.name then
    SprintSens.LoadConfig()
    SprintSens.RegisterLoop(SprintSens.events.worker, SprintSens.Worker)
  end
end

function SprintSens.LoadConfig() 
  local lam = LibStub("LibAddonMenu-2.0")
  lam:RegisterAddonPanel("SprintSensOptions", SprintSens.settings.panel)
  lam:RegisterOptionControls("SprintSensOptions", SprintSens.settings.controls)
  SprintSens.config = ZO_SavedVars:NewAccountWide("SprintSensSettings", 1, nil, SprintSens.settings.defaults)
end

-------------
-- deprecated
-------------
function SprintSens.IndicatorLoop()
  if SprintSens.Indicator() then
    SprintSens.SetSprintSens()
    SprintSens.UnregisterLoop(SprintSens.events.indicator)
    SprintSens.RegisterLoop(SprintSens.events.rejector, SprintSens.RejectorLoop)
  end
end

function SprintSens.RejectorLoop()
  if not SprintSens.Indicator() then
    SprintSens.SetDefaultSens()
    SprintSens.UnregisterLoop(SprintSens.events.rejector)
    SprintSens.RegisterLoop(SprintSens.events.indicator, SprintSens.IndicatorLoop)
  end
end

function SprintSens.OnSprintStart(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue)
  if hitValue == 0 then
    if SprintSens.Indicator() then
      SprintSens.SetSprintSens()
      SprintSens.RegisterLoop(SprintSens.events.rejector, SprintSens.RejectorLoop)
    else
      SprintSens.RegisterLoop(SprintSens.events.indicator, SprintSens.IndicatorLoop)
    end
  end
end

function SprintSens.OnSprintStop()
  SprintSens.SetDefaultSens()
  SprintSens.UnregisterLoop(SprintSens.events.rejector)
  SprintSens.UnregisterLoop(SprintSens.events.indicator)
end