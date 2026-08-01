local SFT = SamisFishTrackerAddon
local visibility = SFT.constants.visibility
local LAM2 = LibAddonMenu2

local visibilityChoiceMap = {
  ["Always Show"] = visibility.SHOW,
  ["Always Hide"] = visibility.HIDE,
  ["Auto (Fishing Nodes)"] = visibility.AUTO,
}

local function getVisibilityChoice()
  local mode = SFT.savedVariables.visibility

  if mode == visibility.SHOW then
    return "Always Show"
  elseif mode == visibility.AUTO then
    return "Auto (Fishing Nodes)"
  end

  return "Always Hide"
end

function SFT.settingsInit()
  if not LAM2 then
    return
  end

  local panelData = {
    type = "panel",
    name = "Sami's Fish Tracker",
    author = "@samihaize",
    version = SFT.version,
  }

  LAM2:RegisterAddonPanel("SamisFishTrackerOptions", panelData)

  local optionsData = {}
  optionsData[#optionsData + 1] = {
    type = "description",
    text =
    "Tracks your fish and estimated Perfect Roe across bag and bank. Slash commands: /sft, /sft show, /sft hide, /sft auto, /sft reset.",
  }

  optionsData[#optionsData + 1] = {
    type = "header",
    name = "Display Options",
  }
  optionsData[#optionsData + 1] = {
    type = "dropdown",
    name = "Visibility Mode",
    tooltip = "Choose when the tracker window is shown",
    choices = { "Always Show", "Always Hide", "Auto (Fishing Nodes)" },
    getFunc = function()
      return getVisibilityChoice()
    end,
    setFunc = function(choice)
      SFT.savedVariables.visibility = visibilityChoiceMap[choice] or visibility.HIDE
      SFT.ApplyVisibilitySetting()
    end,
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = "Show Average Fish Per Hour",
    tooltip = "Show or hide the Avg/hr line in the tracker window",
    getFunc = function()
      return SFT.savedVariables.showAverageRate ~= false
    end,
    setFunc = function(value)
      SFT.savedVariables.showAverageRate = value
      SFT.UpdateAverageRateLabel()
      SFT.ResizeWindow()
    end,
    default = true,
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = "Auto Update Avg/hr",
    tooltip = "Automatically refresh the Avg/hr value over time",
    getFunc = function()
      return SFT.savedVariables.averageRateAutoUpdateEnabled ~= false
    end,
    setFunc = function(value)
      SFT.savedVariables.averageRateAutoUpdateEnabled = value
      SFT.ConfigureAverageRateAutoUpdate()
    end,
    default = true,
  }
  optionsData[#optionsData + 1] = {
    type = "slider",
    name = "Avg/hr Update Frequency (seconds)",
    tooltip = "How often Avg/hr updates automatically",
    min = 1,
    max = 60,
    step = 1,
    getFunc = function()
      return SFT.savedVariables.averageRateUpdateIntervalSeconds or 1
    end,
    setFunc = function(value)
      SFT.savedVariables.averageRateUpdateIntervalSeconds = value
      SFT.ConfigureAverageRateAutoUpdate()
    end,
    default = 1,
    disabled = function()
      return SFT.savedVariables.averageRateAutoUpdateEnabled == false
    end,
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = "Use Rolling Window for Avg/hr",
    tooltip = "Use a rolling window (stable rate) instead of session lifetime (volatile early-session)",
    getFunc = function()
      return SFT.savedVariables.averageRateUseRollingWindow ~= false
    end,
    setFunc = function(value)
      SFT.savedVariables.averageRateUseRollingWindow = value
      SFT.UpdateAverageRateLabel(true)
    end,
    default = true,
  }
  optionsData[#optionsData + 1] = {
    type = "slider",
    name = "Rolling Window Duration (minutes)",
    tooltip = "Time window for rolling average calculation",
    min = 0.5,
    max = 60,
    step = 0.5,
    getFunc = function()
      return (SFT.savedVariables.averageRateRollingWindowSeconds or 300) / 60
    end,
    setFunc = function(value)
      SFT.savedVariables.averageRateRollingWindowSeconds = value * 60
      SFT.UpdateAverageRateLabel(true)
    end,
    default = 5,
    disabled = function()
      return SFT.savedVariables.averageRateUseRollingWindow == false
    end,
  }

  optionsData[#optionsData + 1] = {
    type = "header",
    name = "Roe Estimation",
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = "Enable Roe Tracking",
    tooltip = "Show roe estimation and fillet stats tracking",
    getFunc = function()
      return SFT.savedVariables.enableRoeTracking ~= false
    end,
    setFunc = function(value)
      SFT.savedVariables.enableRoeTracking = value
      if SFT.ApplyRoeTrackingVisibility then
        SFT.ApplyRoeTrackingVisibility()
      end
      SFT.RefreshStorageLabels()
    end,
    default = true,
  }
  optionsData[#optionsData + 1] = {
    type = "slider",
    name = "Roe Rate",
    tooltip = "Expected Perfect Roe chance per fish",
    min = 0.0001,
    max = 5.0,
    step = 0.0001,
    getFunc = function()
      d(" getFunc roe rate: " ..
        tostring(SFT.savedVariables.roeRate) .. ", default: " .. tostring(SFT.constants.roeRate) .. ")")
      return tonumber(string.format("%.4f", SFT.savedVariables.roeRate or SFT.constants.roeRate))
    end,
    setFunc = function(value)
      SFT.savedVariables.roeRate = value
      SFT.UpdateFishCount(SFT.fishamount)
      SFT.RefreshStorageLabels()
    end,
    default = SFT.constants.roeRate,
    disabled = function()
      return SFT.savedVariables.enableRoeTracking == false or SFT.savedVariables.autoSyncRoeRate == true
    end,
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = "Auto-sync Roe Rate from observed data",
    tooltip = "Automatically update Roe Rate with the observed rate each time a fillet or roe event is recorded",
    getFunc = function()
      return SFT.savedVariables.autoSyncRoeRate == true
    end,
    setFunc = function(value)
      SFT.savedVariables.autoSyncRoeRate = value
      if value then
        SFT.ApplyLastRoeRateToRoeRateSetting()
      end
    end,
    default = false,
    disabled = function()
      return SFT.savedVariables.enableRoeTracking == false
    end,
  }

  optionsData[#optionsData + 1] = {
    type = "header",
    name = "Actions",
  }
  optionsData[#optionsData + 1] = {
    type = "button",
    name = "Reset Session Fish Count",
    tooltip = "Sets the tracker count back to 0",
    func = function()
      SFT.ResetFishAmount()
    end,
    warning = "This only resets the tracked count, not fish in your inventory.",
  }
  optionsData[#optionsData + 1] = {
    type = "button",
    name = "Reset Roe/Fillet Tracking",
    tooltip = "Reset fillets since roe, last roe rate, and roe found counters",
    func = function()
      SFT.ResetRoeFilletTracking()
    end,
    warning = "This only resets roe/fillet tracking data.",
    disabled = function()
      return SFT.savedVariables.enableRoeTracking == false
    end,
  }
  optionsData[#optionsData + 1] = {
    type = "button",
    name = "Use Last Roe % as Roe Rate",
    tooltip = "Set Roe Rate to the last observed roe percentage",
    func = function()
      SFT.ApplyLastRoeRateToRoeRateSetting()
    end,
    disabled = function()
      return SFT.savedVariables.enableRoeTracking == false
    end,
  }

  LAM2:RegisterOptionControls("SamisFishTrackerOptions", optionsData)
end
