function OffTaunt.BuildTrialOptions(input)
  local options = {}

  for _, v in ipairs(input) do
    if type(v.items) == "table" then
      table.insert(options, {
        type = "submenu",
        name = tostring(v.name),
        controls = OffTaunt.BuildTrialOptions(v.items),
      })
    else
      table.insert(options, {
        type = "checkbox",
        name = tostring(v.name),
        getFunc = function() return OffTaunt.SV.bosses[v.name] end,
        setFunc = function(value) OffTaunt.SV.bosses[v.name] = value end,
      })
    end
  end

  return options
end

function OffTaunt.BuildMenu()
  local panelName = OffTaunt.name .. "Panel"
  local LAM = LibAddonMenu2
  local panelData = {
    type = "panel",
    name = "OffTaunt",
    author = "@Jarva [EU]",
    registerForDefaults = true,
    registerForRefresh = true,
  }

  LAM:RegisterAddonPanel(panelName, panelData)

  local optionsData = {
    {
      type = "slider",
      name = "Override Timer",
      min = 100,
      max = 1000,
      step = 50,
      default = OffTaunt.SV.overrideTimer,
      getFunc = function() return OffTaunt.SV.overrideTimer end,
      setFunc = function(value)
          OffTaunt.SV.overrideTimer = value
      end
    },
    {
      type = "checkbox",
      name = "Debug",
      getFunc = function() return OffTaunt.debug end,
      setFunc = function(value) OffTaunt.debug = value end,
    }
  }

  local trialOptions = OffTaunt.BuildTrialOptions(OffTaunt.trials)

  for k,v in pairs(trialOptions) do table.insert(optionsData, v) end

  LAM:RegisterOptionControls(panelName, optionsData)
end
