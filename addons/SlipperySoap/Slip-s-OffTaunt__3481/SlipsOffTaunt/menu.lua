function SlipsOffTaunt.BuildTrialOptions(input)
  local options = {}

  for _, v in ipairs(input) do
    if type(v.items) == "table" then
      table.insert(options, {
        type = "submenu",
        name = tostring(v.name),
        controls = SlipsOffTaunt.BuildTrialOptions(v.items),
      })
    else
      table.insert(options, {
        type = "checkbox",
        name = tostring(v.name),
        getFunc = function() return SlipsOffTaunt.SV.bosses[v.name] end,
        setFunc = function(value) SlipsOffTaunt.SV.bosses[v.name] = value end,
      })
    end
  end

  return options
end

function SlipsOffTaunt.BuildMenu()
  local panelName = SlipsOffTaunt.name .. "Panel"
  local LAM = LibAddonMenu2
  local panelData = {
    type = "panel",
    name = "Slip's OffTaunt",
    author = "@Jarva [EU], @SlipperySoap [NA]",
    registerForDefaults = true,
    registerForRefresh = true,
  }

  LAM:RegisterAddonPanel(panelName, panelData)

  local optionsData = {
    {
      type = "description", text = "The blocking of taunt can be overridden by holding down the taunt skill for longer than the Override Timer that you set, and then releasing the taunt skill with your cursor on the target."
    },
    {
      type = "slider",
      name = "Override Timer (in ms)",
      min = 100,
      max = 5000, -- Slip: increased this from 1000 to 5000
      step = 50,
      default = SlipsOffTaunt.SV.overrideTimer,
      getFunc = function() return SlipsOffTaunt.SV.overrideTimer end,
      setFunc = function(value)
          SlipsOffTaunt.SV.overrideTimer = value
      end
    },
    {
      type = "checkbox",
      name = "Debug",
      getFunc = function() return SlipsOffTaunt.debug end,
      setFunc = function(value) SlipsOffTaunt.debug = value end,
    },
    {
      type = "description", text = "You can select which trial bosses/adds you want to block taunt for below."
    },
  }

  local trialOptions = SlipsOffTaunt.BuildTrialOptions(SlipsOffTaunt.trials)

  for k,v in pairs(trialOptions) do table.insert(optionsData, v) end

  LAM:RegisterOptionControls(panelName, optionsData)
end
