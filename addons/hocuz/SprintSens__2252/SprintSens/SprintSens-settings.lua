----------
-- globals
----------
SprintSens.settings = {}
SprintSens.settings.controls = {}

SprintSens.settings.panel = {
  type = "panel",
  name = "SprintSens",
  author = 'Hoci Poci Li',
  version = '1.7'
}

SprintSens.settings.defaults = {
  defaultSens = 75,
  sprintSens = 135
}

-----------
-- settings
-----------
table.insert(SprintSens.settings.controls, {
  type = "slider",
  name = "Default Sensitivity",
  tooltip = "Default Sensitivity",
  default = SprintSens.settings.defaults.defaultSens,
  min = 1,
  max = 160,
  getFunc = function() 
    return SprintSens.config.defaultSens
  end,
  setFunc = function(value)
    SprintSens.config.defaultSens = value
  end
})

table.insert(SprintSens.settings.controls, {
  type = "slider",
  name = "Sprint Sensitivity",
  tooltip = "Sprint Sensitivity",
  default = SprintSens.settings.defaults.sprintSens,
  min = 1,
  max = 160,
  getFunc = function() 
    return SprintSens.config.sprintSens
  end,
  setFunc = function(value)
    SprintSens.config.sprintSens = value
  end
})