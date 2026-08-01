function ZeebsOffTaunt.BuildTrialOptions(input)
  local options = {}

  for _, v in ipairs(input) do
    if type(v.items) == "table" then
      table.insert(options, {
        type = "submenu",
        name = tostring(v.name),
        controls = ZeebsOffTaunt.BuildTrialOptions(v.items),
      })
    else
      table.insert(options, {
        type = "checkbox",
        name = tostring(v.name),
        getFunc = function() return ZeebsOffTaunt.SV.bosses[v.name] end,
        setFunc = function(value) ZeebsOffTaunt.SV.bosses[v.name] = value end,
      })
    end
  end

  return options
end

function ZeebsOffTaunt.BuildMenu()
  local panelName = ZeebsOffTaunt.name .. "Panel"
  local LAM = LibAddonMenu2
  local panelData = {
    type = "panel",
    name = "Zeebs's OffTaunt",
    author = "@Jarva [EU], @SlipperySoap [NA],@zbzszzzt123 [NA]",
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
      default = ZeebsOffTaunt.SV.overrideTimer,
      getFunc = function() return ZeebsOffTaunt.SV.overrideTimer end,
      setFunc = function(value)
          ZeebsOffTaunt.SV.overrideTimer = value
      end
    },
    {
      type = "checkbox",
      name = "Debug",
      getFunc = function() return ZeebsOffTaunt.debug end,
      setFunc = function(value) ZeebsOffTaunt.debug = value end,
    },
    {
      type = "description", text = "You can select which trial bosses/adds you want to block taunt for below."
    },
  }

  local trialOptions = ZeebsOffTaunt.BuildTrialOptions(ZeebsOffTaunt.trials)

  for k,v in pairs(trialOptions) do table.insert(optionsData, v) end

  LAM:RegisterOptionControls(panelName, optionsData)
end
