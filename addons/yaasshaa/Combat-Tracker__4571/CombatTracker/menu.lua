local CombatTracker = CombatTracker
local EM = EVENT_MANAGER


function CombatTracker.setupAddonMenu()
  local LAM2 = LibAddonMenu2
  if LAM2 == nil then return end

  local savedVars = CombatTracker.savedVars
  local defaults = CombatTracker.defaults

  -- todo: check LibMediaProvider
  local fontFaceChoices = {
    "Bold",
    "Medium",
    "Gamepad Light",
    "Gamepad Medium",
    "Gamepad Bold",
    "Stone Tablet",
    "Antique Font",
    "Handwritten Font",
    "Univers 55",
    "Consola",
  }
  local fontFaceValues = {
    "$(BOLD_FONT)",
    "$(MEDIUM_FONT)",
    "$(GAMEPAD_LIGHT_FONT)",
    "$(GAMEPAD_MEDIUM_FONT)",
    "$(GAMEPAD_BOLD_FONT)",
    "$(STONE_TABLET_FONT)",
    "$(ANTIQUE_FONT)",
    "$(HANDWRITTEN_FONT)",
    "/EsoUI/Common/Fonts/Univers55.slug",
    "/EsoUI/Common/Fonts/Consola.slug",
  }

  -- FONT_STYLE_*
  local fontStyleChoices = {
    "normal",
    "shadow",
    "soft-shadow-thin",
    "soft-shadow-thick",
    "thick-outline",
    "outline",
    "outline-shadow",
    "outline-shadow-thick",
  }
  local fontStyleValues = {
    "",
    "shadow",
    "soft-shadow-thin",
    "soft-shadow-thick",
    "thick-outline",
    "outline",
    "outline-shadow",
    "outline-shadow-thick",
  }

  local optionsTable = {
    {
      type = "divider",
      alpha = 0.25,
    },
    {
      type = "checkbox",
      name = "Enabled",
      getFunc = function() return savedVars.enabled end,
      setFunc = function(value)
        savedVars.enabled = value
      end,
      default = defaults.enabled,
    },
    {
      type = "checkbox",
      name = "Locked",
      getFunc = function() return savedVars.locked end,
      setFunc = function(value)
        savedVars.locked = value
        CombatTrackerFrame:SetMovable(not value)
        CombatTrackerFrame:SetMouseEnabled(not value)
      end,
      default = defaults.locked,
    },
    {
      type = "divider",
      alpha = 0.25,
    },
    {
      type = "checkbox",
      name = "Show Fight Timer",
      getFunc = function() return savedVars.showTime end,
      setFunc = function(value)
        savedVars.showTime = value
      end,
      tooltip = "Switch between displaying plain text or timer",
      default = defaults.showTime,
    },
    {
      type = "checkbox",
      name = "Keep After Combat",
      getFunc = function() return savedVars.keep end,
      setFunc = function(value)
        savedVars.keep = value
      end,
      tooltip = "Keep the tracker visible after combat ends",
      default = defaults.keep,
    },
    {
      type = "checkbox",
      name = "Stop Timer on Boss Death",
      getFunc = function() return savedVars.stopOnBossDeath end,
      setFunc = function(value)
        savedVars.stopOnBossDeath = value
      end,
      tooltip = "Freeze the timer immediately when all bosses defeated",
      disabled = function() return not savedVars.showTime end,
      default = defaults.stopOnBossDeath,
    },
    {
      type = "slider",
      name = "Timer Update Interval",
      getFunc = function() return savedVars.updateInterval end,
      setFunc = function(value)
        savedVars.updateInterval = value
      end,
      min = 0,
      max = 1000,
      step = 10,
      tooltip = "Timer update frequency in milliseconds\nLower value means faster updates, down to 0 ms for every frame",
      disabled = function() return not savedVars.showTime end,
      default = defaults.updateInterval,
    },
    {
      type = "dropdown",
      name = "Timer Decimals Format",
      choices = {"None", ".0", ".00", ".000"},
      choicesValues = {0, 1, 2, 3},
      getFunc = function() return savedVars.timePrecision end,
      setFunc = function(value)
        savedVars.timePrecision = value
      end,
      tooltip = "Number of decimal places to display",
      disabled = function() return not savedVars.showTime end,
      default = defaults.timePrecision,
    },
    {
      type = "divider",
      alpha = 0.25,
    },
    {
      type = "colorpicker",
      name = "In Combat Color",
      getFunc = function() return unpack(savedVars.inCombatColor) end,
      setFunc = function(r, g, b, a)
        savedVars.inCombatColor = {r, g, b, a}
        CombatTracker.applyColor(true)
      end,
      default = ZO_ColorDef:New(unpack(defaults.inCombatColor)),
    },
    {
      type = "colorpicker",
      name = "Out of Combat Color",
      getFunc = function() return unpack(savedVars.outOfCombatColor) end,
      setFunc = function(r, g, b, a)
        savedVars.outOfCombatColor = {r, g, b, a}
        CombatTracker.applyColor(false)
      end,
      disabled = function() return not savedVars.keep end,
      default = ZO_ColorDef:New(unpack(defaults.outOfCombatColor)),
    },
    {
      type = "divider",
      alpha = 0.25,
    },
    {
      type = "editbox",
      name = "In Combat Text",
      getFunc = function() return savedVars.inCombatText end,
      setFunc = function(value)
        savedVars.inCombatText = value
      end,
      tooltip = "Plain text to display during combat (if timer disabled)",
      maxChars = 128,
      disabled = function() return savedVars.showTime end,
      default = defaults.inCombatText,
    },
    {
      type = "editbox",
      name = "Out of Combat Text",
      getFunc = function() return savedVars.outOfCombatText end,
      setFunc = function(value)
        savedVars.outOfCombatText = value
      end,
      tooltip = "Plain text to display after combat (if timer disabled)",
      maxChars = 128,
      disabled = function() return savedVars.showTime or not  savedVars.keep end,
      default = defaults.outOfCombatText,
    },
    {
      type = "editbox",
      name = "In Combat Timer Format",
      getFunc = function() return savedVars.inCombatFormat end,
      setFunc = function(value)
        if not string.find(value, "%%s") then
          value = defaults.inCombatFormat
        end
        savedVars.inCombatFormat = value
        CombatTrackerMenu_InCombatFormat.editbox:SetText(value)
      end,
      tooltip = "Use \"|cff3333%s|r\" as a placeholder for the fight timer\nFor example \"|cff3333In Combat %s|r\"\nOr use \"|cff3333%s|r\" to display only time\nYou can also use (Enter) to make a new line",
      isMultiline = true,
      maxChars = 128,
      disabled = function() return not savedVars.showTime end,
      default = defaults.inCombatFormat,
      reference = "CombatTrackerMenu_InCombatFormat",
    },
    {
      type = "editbox",
      name = "Out of Combat Timer Format",
      getFunc = function() return savedVars.outOfCombatFormat end,
      setFunc = function(value)
        savedVars.outOfCombatFormat = value
        CombatTrackerMenu_OutOfCombatFormat.editbox:SetText(value)
      end,
      tooltip = "Use \"|cff3333%s|r\" as a placeholder for the fight timer or just enter plain text (e.g. \"|cff3333Out of Combat|r\")",
      isMultiline = true,
      maxChars = 128,
      disabled = function() return not savedVars.showTime or not savedVars.keep end,
      default = defaults.outOfCombatFormat,
      reference = "CombatTrackerMenu_OutOfCombatFormat",
    },
    {
      type = "divider",
      alpha = 0.25,
    },
    {
      type = "dropdown",
      name = "Font",
      choices = fontFaceChoices,
      choicesValues = fontFaceValues,
      getFunc = function() return savedVars.fontFace end,
      setFunc = function(value)
        savedVars.fontFace = value
        CombatTracker.applyFont()
      end,
      scrollable = true,
      default = defaults.fontFace,
    },
    {
      type = "slider",
      name = "Font Size",
      getFunc = function() return savedVars.fontSize end,
      setFunc = function(value)
        savedVars.fontSize = value
        CombatTracker.applyFont()
      end,
      min = 16,
      max = 80,
      step = 1,
      default = defaults.fontSize,
    },
    {
      type = "dropdown",
      name = "Font Style",
      choices = fontStyleChoices,
      choicesValues = fontStyleValues,
      getFunc = function() return savedVars.fontStyle end,
      setFunc = function(value)
        savedVars.fontStyle = value
        CombatTracker.applyFont()
      end,
      scrollable = true,
      default = defaults.fontStyle,
    },
    {
      type = "dropdown",
      name = "Horizontal Alignment",
      choices = {"Left", "Center", "Right"},
      choicesValues = {TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT},
      getFunc = function() return savedVars.horizontalAlignment end,
      setFunc = function(value)
        savedVars.horizontalAlignment = value
        CombatTrackerFrameLabel:SetHorizontalAlignment(value)
        CombatTracker.restorePosition()
      end,
      default = defaults.horizontalAlignment,
    },
    {
      type = "dropdown",
      name = "Vertical Alignment",
      choices = {"Top", "Center", "Bottom"},
      choicesValues = {TEXT_ALIGN_TOP, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM},
      getFunc = function() return savedVars.verticalAlignment end,
      setFunc = function(value)
        savedVars.verticalAlignment = value
        CombatTrackerFrameLabel:SetVerticalAlignment(value)
        CombatTracker.restorePosition()
      end,
      default = defaults.verticalAlignment,
    },
  }

  -- CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
  --   if panel:GetName() ~= "CombatTrackerMenu" then return end
  -- end)

  CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
    if panel:GetName() ~= "CombatTrackerMenu" then return end
    CombatTracker.inMenu = true
    CombatTrackerFrame:SetHidden(false)
    CombatTrackerFrame:SetDrawLayer(DL_OVERLAY)
    CombatTracker.refreshState()
  end)

  CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
    if panel:GetName() ~= "CombatTrackerMenu" then return end
    CombatTracker.inMenu = false
    CombatTrackerFrame:SetHidden(true)
    CombatTrackerFrame:SetDrawLayer(DL_CONTROLS)
    CombatTracker.applyColor()
    CombatTracker.refreshState()
  end)

  local panelData = {
    type = "panel",
    name = "Combat Tracker",
    author = "yaasshaa",
    version = CombatTracker.version,
    registerForRefresh = true,
    registerForDefaults = true,
  }
  LAM2:RegisterAddonPanel("CombatTrackerMenu", panelData)
  LAM2:RegisterOptionControls("CombatTrackerMenu", optionsTable)
end