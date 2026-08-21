-- Functions
local function loadConfig()

  local panelData = {
    type = "panel",
    name = "|cC3C198Sprint Sensitivity Fix|r",
    author = "|cC3C198@GalacticWar|r",
    version = "6.0",
    registerForDefaults = true,
  }

  local optionsData = {
    {
			type = "header",
      name = "|cC3C198Mouse Settings|r"
		},
    {
      type = "slider",
      name = "1st Person Horizontal Look Speed",
      tooltip = "Adjusts the horizontal sensitivity of the mouse when moving the camera in 1st person mode.",
      min = 0,
      max = 100,
      default = 50,
      getFunc = function() return math.floor((GetSetting(2, 3) - 0.1) / 0.015 + 0.5) end,
      setFunc = function(value)
        SetSetting(2, 3, value * 0.015 + 0.1)
      end,
    },
    {
      type = "slider",
      name = "1st Person Vertical Look Speed",
      tooltip = "Adjusts the vertical sensitivity of the mouse when moving the camera in 1st person mode.",
      min = 0,
      max = 100,
      default = 50,
      getFunc = function() return math.floor((GetSetting(2, 19) - 0.1) / 0.015 + 0.5) end,
      setFunc = function(value)
        SetSetting(2, 19, value * 0.015 + 0.1)
      end,
    },
    {
      type = "slider",
      name = "3rd Person Horizontal Look Speed",
      tooltip = "Adjusts the horizontal sensitivity of the mouse when moving the camera in 3rd person mode.",
      min = 0,
      max = 100,
      default = 50,
      getFunc = function() return math.floor((GetSetting(2, 2) - 0.1) / 0.015 + 0.5) end,
      setFunc = function(value)
        SetSetting(2, 2, value * 0.015 + 0.1)
      end,
    },
    {
      type = "slider",
      name = "3rd Person Vertical Look Speed",
      tooltip = "Adjusts the vertical sensitivity of the mouse when moving the camera in 3rd person mode.",
      min = 0,
      max = 100,
      default = 50,
      getFunc = function() return math.floor((GetSetting(2, 18) - 0.1) / 0.015 + 0.5) end,
      setFunc = function(value)
        SetSetting(2, 18, value * 0.015 + 0.1)
      end,
    },
    {
			type = "header",
		},


    {
			type = "header",
      name = "|cC3C198Gamepad Settings|r"
		},
    {
      type = "slider",
      name = "Horizontal Look Sensitivity",
      tooltip = "Adjusts the horizontal sensitivity of the gamepad when moving the camera.",
      min = 0,
      max = 500,
      default = 50,
      getFunc = function() return math.floor((GetSetting(15, 3) - 0.65) / 0.004 + 0.5) end,
      setFunc = function(value)
        SetSetting(15, 3, value * 0.004 + 0.65)
      end,
    },
    {
      type = "slider",
      name = "Vertical Look Sensitivity",
      tooltip = "Adjusts the vertical sensitivity of the gamepad when moving the camera.",
      min = 0,
      max = 500,
      default = 50,
      getFunc = function() return math.floor((GetSetting(15, 15) - 0.65) / 0.004 + 0.5) end,
      setFunc = function(value)
        SetSetting(15, 15, value * 0.004 + 0.65)
      end,
    },
    {
			type = "header"
		},
  }

  local LAM = LibAddonMenu2
  LAM:RegisterAddonPanel("SprintSensitivityFixOptions", panelData)
  LAM:RegisterOptionControls("SprintSensitivityFixOptions", optionsData)
end

SprintSensitivityFix.loadConfig = loadConfig
