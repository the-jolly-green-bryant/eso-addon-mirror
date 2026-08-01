-- Advanced Disable Controller UI Menu
-- Author: Lionas
local PanelTitle = "Advanced Disable Controller UI"
local Author = "Lionas, Setsu"

local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

function LoadLAM2Panel()
  local PanelData = 
  {
      type = "panel",
      name = PanelTitle,
      author = Author,
      slashCommand = "/adcui",
      registerForRefresh = true,
      registerForDefaults = true,
  }
  local OptionsData = 
  {
    { -- Description
      type = "description",
      text = GetString(ADCUI_DESCRIPTION),
    },
    { -- [General Settings]
			type = "header",
			name = GetString(ADCUI_GENERAL_SETTINGS_HEADER),
		},
    { -- Use Account Wide Settings
      type = "checkbox",
      name = GetString(ADCUI_ACCOUNT_WIDE_SETTINGS),
      tooltip = GetString(ADCUI_ACCOUNT_WIDE_SETTINGS_TOOLTIP),
      default = false,
      getFunc = 
        function() 
          local settings = ADCUI:getSettings()
          return settings.useAccountWideSettings
        end,
      setFunc = 
        function(value) 
          ADCUI.savedVariables.useAccountWideSettings = value
          ADCUI.savedVariablesAccountWide.useAccountWideSettings = value
        end,
    },
    { -- Use Controller UI
      type = "checkbox",
      name = GetString(ADCUI_USE_CONTROLLER_UI),
      tooltip = GetString(ADCUI_USE_CONTROLLER_UI),
      default = false,
      getFunc = 
        function(value)
          local settings = ADCUI:getSettings()
          return settings.useControllerUI
        end,
      setFunc = 
        function(value) 
          local settings = ADCUI:getSettings()
          settings.useControllerUI = value
          ADCUI:cycleGamepadPreferredMode()
        end,
    },
    { -- Use Gamepad Buttons
      type = "checkbox",
      name = GetString(ADCUI_USE_GAMEPAD_BUTTONS),
      tooltip = GetString(ADCUI_USE_GAMEPAD_BUTTONS_TOOLTIP),
      default = false,
      disabled = 
        function(value)
          local settings = ADCUI:getSettings()
          return settings.useControllerUI
        end,
      getFunc = 
        function(value)
          local settings = ADCUI:getSettings()
          return settings.useGamepadButtons
        end,
      setFunc = 
        function(value) 
          local settings = ADCUI:getSettings()
          settings.useGamepadButtons = value
          ADCUI:cycleGamepadPreferredMode()
        end,
    },
    { -- Use Gamepad Action Bar
      type = "checkbox",
      name = GetString(ADCUI_USE_GAMEPAD_ACTION_BAR),
      tooltip = GetString(ADCUI_USE_GAMEPAD_ACTION_BAR_TOOLTIP),
      default = false,
      disabled = 
        function(value)
          local settings = ADCUI:getSettings()
          return settings.useControllerUI
        end,
      getFunc = 
        function(value)
          local settings = ADCUI:getSettings()
          return settings.useGamepadActionBar
        end,
      setFunc = 
        function(value) 
          local settings = ADCUI:getSettings()
          settings.useGamepadActionBar = value
          ADCUI:setGamepadActionBarOverrideState(value)
          ADCUI:cycleGamepadPreferredMode()
        end,
    },
    { -- [Compass]
			type = "header",
			name = GetString(ADCUI_COMPASS_HEADER),
		},
    { -- Lock Enabled
      type = "checkbox",
      name = GetString(ADCUI_LOCK_TITLE),
      tooltip = GetString(ADCUI_LOCK_TOOLTIP),
      getFunc = 
        function() 
          local settings = ADCUI:getSettings()
          return settings.lockEnabled
        end,
      setFunc = 
        function(value) 
          local settings = ADCUI:getSettings()
          settings.lockEnabled = value
          ADCUI:adjustCompass()
        end,
    },
    { -- Scale
      type = "slider",
      name = GetString(ADCUI_SCALE_TITLE),
      tooltip = GetString(ACCUI_SCALE_TOOLTIP),
      min = 8,
      max = 11,
      step = 1,
      default = ADCUI.default.scale * 10,
      getFunc = 
        function() 
          local settings = ADCUI:getSettings()
          return settings.scale * 10
        end,
      setFunc = 
        function(value) 
          local settings = ADCUI:getSettings()
          settings.scale = tonumber(value) / 10.0
          ADCUI:frameUpdate()
        end,
    },
    { -- Width
      type = "slider",
      name = GetString(ADCUI_WIDTH_TITLE),
      tooltip = GetString(ADCUI_WIDTH_TOOLTIP),
      min = 0,
      max = 1500,
      step = 10,
      default = ADCUI.default.width,
      getFunc = 
        function()
          local settings = ADCUI:getSettings()
          return settings.width
        end,
      setFunc = 
        function(value)
          local settings = ADCUI:getSettings()
          settings.width = tonumber(value) 
          ADCUI:frameUpdate() 
        end,
    },
    { -- Height
      type = "slider",
      name = GetString(ADCUI_HEIGHT_TITLE),
      tooltip = GetString(ADCUI_HEIGHT_TOOLTIP),
      min = 0,
      max = 100,
      step = 1,
      default = ADCUI.default.height,
      getFunc = 
        function() 
          local settings = ADCUI:getSettings()
          return settings.height 
        end,
      setFunc = 
        function(value) 
          local settings = ADCUI:getSettings()
          settings.height = tonumber(value) 
          ADCUI:frameUpdate() 
        end,
    },
    { -- Pin Label Scale
      type = "slider",
      name = GetString(ADCUI_LABEL_SCALE_TITLE),
      tooltip = GetString(ADCUI_LABEL_SCALE_TOOLTIP),
      min = 6,
      max = 11,
      step = 1,
      default = ADCUI.default.pinLabelScale * 10,
      getFunc = 
        function() 
          local settings = ADCUI:getSettings()
          return settings.pinLabelScale * 10
        end,
      setFunc = 
        function(value) 
          local settings = ADCUI:getSettings()
          settings.pinLabelScale = tonumber(value) / 10.0
          ADCUI:frameUpdate()
        end,
    },
    { -- [Fonts]
			type = "header",
			name = GetString(ADCUI_FONTS_HEADER),
		},
    { -- Reticle
      type = "dropdown",
      name = GetString(ADCUI_RETICLE_FONT),
      tooltip = GetString(ADCUI_RETICLE_FONT_TOOLTIP),
      choices = ADCUI.const.FONT_NAMES,
      choicesValues = ADCUI.const.FONTS,
      default = ADCUI.default.fonts.reticle,
      scrollable = true,
      getFunc = function()
          local settings = ADCUI:getSettings()
          return settings.fonts.reticle
        end,
      setFunc = function(value)
          local settings = ADCUI:getSettings()
          settings.fonts.reticle = value
          if ADCUI:originalIsInGamepadPreferredMode() and not settings.useControllerUI then
            ADCUI:setReticleFont(value, settings.fonts.reticleContext)
          end
        end,
    },
    { -- Reticle Context
      type = "dropdown",
      name = GetString(ADCUI_RETICLE_CONTEXT_FONT),
      tooltip = GetString(ADCUI_RETICLE_CONTEXT_FONT_TOOLTIP),
      choices = ADCUI.const.FONT_NAMES,
      choicesValues = ADCUI.const.FONTS,
      default = ADCUI.default.fonts.reticleContext,
      scrollable = true,
      getFunc = function()
          local settings = ADCUI:getSettings()
          return settings.fonts.reticleContext
        end,
      setFunc = function(value)
          local settings = ADCUI:getSettings()
          settings.fonts.reticleContext = value
          if ADCUI:originalIsInGamepadPreferredMode() and not settings.useControllerUI then
            ADCUI:setReticleFont(settings.fonts.reticle, value)
          end
        end,
    },
    { -- StealthIcon
      type = "dropdown",
      name = GetString(ADCUI_STEALTH_ICON_FONT),
      tooltip = GetString(ADCUI_STEALTH_ICON_FONT_TOOLTIP),
      choices = ADCUI.const.FONT_NAMES,
      choicesValues = ADCUI.const.FONTS,
      default = ADCUI.default.fonts.stealthIcon,
      scrollable = true,
      getFunc = function()
          local settings = ADCUI:getSettings()
          return settings.fonts.stealthIcon
        end,
      setFunc = function(value)
          local settings = ADCUI:getSettings()
          settings.fonts.stealthIcon = value
          if ADCUI:originalIsInGamepadPreferredMode() and not settings.useControllerUI then
            ADCUI:setStealthIconFont(value)
          end
        end,
    },
  }   
  
  LAM2:RegisterAddonPanel(PanelTitle.."LAM2Options", PanelData)
  LAM2:RegisterOptionControls(PanelTitle.."LAM2Options", OptionsData)
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------