-- Globals
SprintSens.settings = {}
SprintSens.settings.controls = {}

SprintSens.settings.defaults = {

  accountWideSettings = false,

  defaultRotationSpeed1st = 0.85,
  defaultRotationSpeed3rd = 0.85,
  gamepadDefaultCamSens = 0.85,

  keyboardUpdateInterval = 5,
  GamepadUpdateInterval = 5,
}

-- Locals
local accountWideSettings

-- Functions
local function LoadConfig()

  SprintSens.config = ZO_SavedVars:NewAccountWide("SprintSensSettings", 4, nil, SprintSens.settings.defaults)

  local panelData = {
    type = "panel",
    name = "|cAF4FFFSprint Sensitivity Fix|r",
    author = "|cAF4FFF@GalacticWar|r",
    version = "5.6",
    registerForDefaults = true,
  }

  local optionsData = {
    {
			type = "header",
      name = "|cC3C198Settings|r"
		},
    {
      type = "checkbox",
      name = "Account-Wide Settings",
      tooltip = "If enabled, these settings are shared across all characters on the account.",
      default = false,
      getFunc = function() return SprintSens.config.accountWideSettings end,
      setFunc = function(value)
        SprintSens.config.accountWideSettings = value
        accountWideSettings = value
        if accountWideSettings then
          SprintSens.config.defaultRotationSpeed1st = GetSetting(2, 3)
          SprintSens.config.defaultRotationSpeed3rd = GetSetting(2, 2)
          SprintSens.config.gamepadDefaultCamSens = GetSetting(15, 3)
        end
      end,
    },
    {
      type = "slider",
      name = "Keyboard 1st Person Camera Sensitivity",
      tooltip = "Adjusts the sensitivity of the mouse when moving the camera in 1st person mode.",
      min = 0,
      max = 100,
      default = 50,
      getFunc = function() return math.floor((GetSetting(2, 3) - 0.1) * 66.66 + 0.125) end,
      setFunc = function(value)
        SetSetting(2, 3, value / 66.66 + 0.1)
        if accountWideSettings then
          SprintSens.config.defaultRotationSpeed1st = value / 66.66 + 0.1
        end
      end,
    },
    {
      type = "slider",
      name = "Keyboard 3rd Person Camera Sensitivity",
      tooltip = "Adjusts the sensitivity of the mouse when moving the camera in 3rd person mode.",
      min = 0,
      max = 100,
      default = 50,
      getFunc = function() return math.floor((GetSetting(2, 2) - 0.1) * 66.66 + 0.125) end,
      setFunc = function(value)
        SetSetting(2, 2, value / 66.66 + 0.1)
        if accountWideSettings then
          SprintSens.config.defaultRotationSpeed3rd = value / 66.66 + 0.1
        end
      end,
    },
    {
      type = "slider",
      name = "Gamepad Camera Sensitivity",
      tooltip = "Adjusts the sensitivity of the gamepad when moving the camera.",
      min = 0,
      max = 200,
      default = 50,
      getFunc = function() return math.floor((GetSetting(15, 3) - 0.65) * 250 + 0.125) end,
      setFunc = function(value)
        SetSetting(15, 3, value * 0.004 + 0.65)
        if accountWideSettings then
          SprintSens.config.gamepadDefaultCamSens = value * 0.004 + 0.65
        end
      end,
    },
    {
			type = "header",
      name = "|cC3C198Advanced|r"
		},
    {
      type = "slider",
      name = "Keyboard Update Frequency |c404040(for advanced users)|r",
      tooltip = "Adjusts how often the addon checks for state changes (in milliseconds).\n\n" ..
      "The addon is extremely optimized, so this doesn't make a difference (Default: 5).",
      min = 5,
      max = 20,
      default = 5,
      getFunc = function() return SprintSens.config.keyboardUpdateInterval end,
      setFunc = function(value)
        SprintSens.config.keyboardUpdateInterval = value
        SprintSens.settingsUpdate(NULL, value, NULL)
      end,
    },
    {
      type = "slider",
      name = "Gamepad Update Frequency |c404040(for advanced users)|r",
      tooltip = "Adjusts how often the addon checks for state changes (in milliseconds).\n\n" ..
      "The addon is extremely optimized, so this doesn't make a difference (Default: 5).",
      min = 5,
      max = 20,
      default = 5,
      getFunc = function() return SprintSens.config.gamepadUpdateInterval end,
      setFunc = function(value)
        SprintSens.config.gamepadUpdateInterval = value
        SprintSens.settingsUpdate(NULL, NULL, value)
      end,
    },
  }

  accountWideSettings = SprintSens.config.accountWideSettings

  local LAM = LibAddonMenu2
  LAM:RegisterAddonPanel("SprintSensOptions", panelData)
  LAM:RegisterOptionControls("SprintSensOptions", optionsData)
end

SprintSens.LoadConfig = LoadConfig