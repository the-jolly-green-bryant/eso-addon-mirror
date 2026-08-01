local LAM = LibAddonMenu2

function cqm:initLAM(icon_themes)
  local panelData = {
    type = "panel",
    version = cqm.version,
    name = "ConspicuousQuestMarkers",
    displayName = ZO_HIGHLIGHT_TEXT:Colorize("ConspicuousQuestMarkers"),
    author = "Jhenox",
    slashCommand = "/cqm",
    registerForRefresh = true,
    registerForDefaults = true
  }
  local getSelected
  local setSelected
  local optionsData = {}
  optionsData[#optionsData + 1] = {
    type = "description",
    text = GetString(CQM_UNINSTALL_DESC),
  }
  optionsData[#optionsData + 1] = {
    type = "description",
    text = GetString(CQM_EXITGAME_DESC),
  }
  optionsData[#optionsData + 1] = {
    type = "header",
    name = GetString(CQM_HEADER_OPTIONS),
    width = "full"
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = GetString(CQM_SHOW_ON_COMPASS_NAME),
    tooltip = GetString(CQM_SHOW_ON_COMPASS_TOOLTIP),
    default = true,
    getFunc = function()
      return cqm.SV.show_on_compass
    end,
    setFunc = function(val)
      cqm.SV.show_on_compass = val
    end,
    width = "full",
    warning = GetString(CQM_RELOAD),
  }
  optionsData[#optionsData + 1] = {
    type = "slider",
    name = GetString(CQM_MARKER_SIZE_NAME),
    tooltip = GetString(CQM_MARKER_SIZE_TOOLTIP),
    min = 32,
    max = 96,
    step = 1,
    getFunc = function()
      return cqm.SV.quest_marker_size
    end,
    setFunc = function(val)
      cqm.SV.quest_marker_size = val
      cqm.OnPlayerActivated()
    end,
    width = "full",
    default = 32
  }
  local iconPickerIndex = #optionsData + 1
  optionsData[iconPickerIndex] = {
    type = "iconpicker",
    name = GetString(CQM_ICON_THEME_NAME),
    tooltip = GetString(CQM_ICON_THEME_TOOLTIP),
    choices = {},
    getFunc = function()
      for i = 1, #icon_themes do
        if icon_themes[i]["theme"] == cqm.SV.icon_theme then
          getSelected = icon_themes[i]["sample"]
        end
      end
      return getSelected
    end,
    setFunc = function(val)
      for i = 1, #icon_themes do
        if icon_themes[i]["sample"] == val then
          setSelected = icon_themes[i]["theme"]
        end
      end
      cqm.SV.icon_theme = setSelected
      cqm.OnPlayerActivated()
    end,
    choicesTooltips = {},
    maxColumns = 4,
    visibleRows = 4,
    iconSize = 32,
    width = "full",
    beforeShow = function(control, iconPicker)
      return preventShow
    end,
    warning = GetString(CQM_RELOAD),
    -- requiresReload = false,
    default = icon_themes[1]["sample"]
  }
  for i = 1, #icon_themes do
    table.insert(optionsData[iconPickerIndex]["choices"], icon_themes[i]["sample"])
    table.insert(optionsData[iconPickerIndex]["choicesTooltips"], icon_themes[i]["tooltip"])
  end
  LAM:RegisterAddonPanel("ConspicuousQuestMarkers", panelData)
  LAM:RegisterOptionControls("ConspicuousQuestMarkers", optionsData)
end
