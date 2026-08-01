function TitleFlex.SettingsBuildTitleTable() --construct a table of titles the player has, with first one being "None"
  TitleFlex.titleChoices[1] = GetString(SI_STATS_NO_TITLE)
  for i=1,GetNumTitles() do
    TitleFlex.titleChoices[i+1] = GetTitle(i)
  end
end

function TitleFlex.SettingsBuildMenu() --construct the settings tab
  local LAM2 = LibAddonMenu2
  
  local addonPanel = {
    type                = 'panel',
    name                = TitleFlex.name,
    displayName         = ZO_ColorDef:New('3366cc'):Colorize(TitleFlex.name),
    version             = TitleFlex.version,
    registerForRefresh  = true,
    registerForDefaults = true,
  }

  local optionControls = {
      {
        type = "checkbox",
        name = "Enable rotation",
        tooltip = "Whether or not to rotate the titles based on the settings below",
        getFunc = function() return TitleFlex.settings.enableRotation end,
        setFunc = function(value)
          TitleFlex.settings.enableRotation = value
          TitleFlex.EnableRotation(value)
        end
      }, 
      {
        type    = 'slider',
        name    = 'Change Interval (seconds)',
        min     = 1,
        max     = 60,
        step    = 1,
        getFunc = function() return TitleFlex.settings.changeIntervalSeconds end,
        setFunc = function(number)
        TitleFlex.settings.changeIntervalSeconds = number
        TitleFlex.ReloadSettings()
        end
      },
      {
        type    = 'slider',
        name    = 'Change Interval (minutes)',
        min     = 0,
        max     = 59,
        step    = 1,
        getFunc = function() return TitleFlex.settings.changeIntervalMinutes end,
        setFunc = function(number)
        TitleFlex.settings.changeIntervalMinutes = number
        TitleFlex.ReloadSettings()
        end
      },
      {
        type = 'dropdown',
        name = 'Title 1',
        tooltip = 'First title in the rotation',
        choices = TitleFlex.titleChoices,
        scrollable = true,
        getFunc = function() return TitleFlex.settings.titleChoice1 end,
        setFunc = function(selected)
            for index, name in ipairs(TitleFlex.titleChoices) do
              if name == selected then
                TitleFlex.settings.titleChoice1 = name
                TitleFlex.ReloadSettings()
                break
              end
            end
          end,
        default = TitleFlex.settings.titleChoice1,
      },
      {
        type = 'dropdown',
        name = 'Title 2',
        tooltip = 'Second title in the rotation',
        choices = TitleFlex.titleChoices,
        scrollable = true,
        getFunc = function() return TitleFlex.settings.titleChoice2 end,
        setFunc = function(selected)
            for index, name in ipairs(TitleFlex.titleChoices) do
              if name == selected then
                TitleFlex.settings.titleChoice2 = name
                TitleFlex.ReloadSettings()
                break
              end
            end
          end,
        default = TitleFlex.settings.titleChoice2,
      },
      {
        type = 'dropdown',
        name = 'Title 3',
        tooltip = 'Third title in the rotation',
        choices = TitleFlex.titleChoices,
        scrollable = true,
        getFunc = function() return TitleFlex.settings.titleChoice3 end,
        setFunc = function(selected)
            for index, name in ipairs(TitleFlex.titleChoices) do
              if name == selected then
                TitleFlex.settings.titleChoice3 = name
                TitleFlex.ReloadSettings()
                break
              end
            end
          end,
        default = TitleFlex.settings.titleChoice3,
      },
      {
        type = 'dropdown',
        name = 'Title 4',
        tooltip = 'Fourth title in the rotation',
        choices = TitleFlex.titleChoices,
        scrollable = true,
        getFunc = function() return TitleFlex.settings.titleChoice4 end,
        setFunc = function(selected)
            for index, name in ipairs(TitleFlex.titleChoices) do
              if name == selected then
                TitleFlex.settings.titleChoice4 = name
                TitleFlex.ReloadSettings()
                break
              end
            end
          end,
        default = TitleFlex.settings.titleChoice4,
      },
      {
        type = 'dropdown',
        name = 'Title 5',
        tooltip = 'Fifth title in the rotation',
        choices = TitleFlex.titleChoices,
        scrollable = true,
        getFunc = function() return TitleFlex.settings.titleChoice5 end,
        setFunc = function(selected)
            for index, name in ipairs(TitleFlex.titleChoices) do
              if name == selected then
                TitleFlex.settings.titleChoice5 = name
                TitleFlex.ReloadSettings()
                break
              end
            end
          end,
        default = TitleFlex.settings.titleChoice5,
      },
      {
        type = 'dropdown',
        name = 'Title 6',
        tooltip = 'Sixth title in the rotation',
        choices = TitleFlex.titleChoices,
        scrollable = true,
        getFunc = function() return TitleFlex.settings.titleChoice6 end,
        setFunc = function(selected)
            for index, name in ipairs(TitleFlex.titleChoices) do
              if name == selected then
                TitleFlex.settings.titleChoice6 = name
                TitleFlex.ReloadSettings()
                break
              end
            end
          end,
        default = TitleFlex.settings.titleChoice6,
      },
      {
        type = 'dropdown',
        name = 'Title 7',
        tooltip = 'Seventh title in the rotation',
        choices = TitleFlex.titleChoices,
        scrollable = true,
        getFunc = function() return TitleFlex.settings.titleChoice7 end,
        setFunc = function(selected)
            for index, name in ipairs(TitleFlex.titleChoices) do
              if name == selected then
                TitleFlex.settings.titleChoice7 = name
                TitleFlex.ReloadSettings()
                break
              end
            end
          end,
        default = TitleFlex.settings.titleChoice7,
      },
      {
        type = 'dropdown',
        name = 'Title 8',
        tooltip = 'Eight title in the rotation',
        choices = TitleFlex.titleChoices,
        scrollable = true,
        getFunc = function() return TitleFlex.settings.titleChoice8 end,
        setFunc = function(selected)
            for index, name in ipairs(TitleFlex.titleChoices) do
              if name == selected then
                TitleFlex.settings.titleChoice8 = name
                TitleFlex.ReloadSettings()
                break
              end
            end
          end,
        default = TitleFlex.settings.titleChoice8,
      },
       {
        type = 'dropdown',
        name = 'Title 9',
        tooltip = 'Ninth title in the rotation',
        choices = TitleFlex.titleChoices,
        scrollable = true,
        getFunc = function() return TitleFlex.settings.titleChoice9 end,
        setFunc = function(selected)
            for index, name in ipairs(TitleFlex.titleChoices) do
              if name == selected then
                TitleFlex.settings.titleChoice9 = name
                TitleFlex.ReloadSettings()
                break
              end
            end
          end,
        default = TitleFlex.settings.titleChoice9,
      },
      {
        type = 'dropdown',
        name = 'Title 10',
        tooltip = 'Tenth title in the rotation',
        choices = TitleFlex.titleChoices,
        scrollable = true,
        getFunc = function() return TitleFlex.settings.titleChoice10 end,
        setFunc = function(selected)
            for index, name in ipairs(TitleFlex.titleChoices) do
              if name == selected then
                TitleFlex.settings.titleChoice10 = name
                TitleFlex.ReloadSettings()
                break
              end
            end
          end,
        default = TitleFlex.settings.titleChoice10,
      },
    }

  LAM2:RegisterAddonPanel('TitleFlexPanel', addonPanel)
  LAM2:RegisterOptionControls('TitleFlexPanel', optionControls)
end

function TitleFlex.SettingsLoad() --set the default settings, then load if there are any saved previously
  local defaultSettings = {
    changeIntervalSeconds  = 0,
    changeIntervalMinutes  = 1,
    titleChoice1  = GetString(SI_STATS_NO_TITLE),
    titleChoice2  = GetString(SI_STATS_NO_TITLE),
    titleChoice3  = GetString(SI_STATS_NO_TITLE),
    titleChoice4  = GetString(SI_STATS_NO_TITLE),
    titleChoice5  = GetString(SI_STATS_NO_TITLE),
    titleChoice6  = GetString(SI_STATS_NO_TITLE),
    titleChoice7  = GetString(SI_STATS_NO_TITLE),
    titleChoice8  = GetString(SI_STATS_NO_TITLE),
    titleChoice9  = GetString(SI_STATS_NO_TITLE),
    titleChoice10 = GetString(SI_STATS_NO_TITLE),
    enableRotation = true,
  }
  TitleFlex.settings = ZO_SavedVars:New('TitleFlexSavedVariables', TitleFlex.varVersion, nil, defaultSettings)
  TitleFlex.titleList = {
    [1] = TitleFlex.settings.titleChoice1,
    [2] = TitleFlex.settings.titleChoice2,
    [3] = TitleFlex.settings.titleChoice3,
    [4] = TitleFlex.settings.titleChoice4,
    [5] = TitleFlex.settings.titleChoice5,
    [6] = TitleFlex.settings.titleChoice6,
    [7] = TitleFlex.settings.titleChoice7,
    [8] = TitleFlex.settings.titleChoice8,
    [9] = TitleFlex.settings.titleChoice9,
    [10] = TitleFlex.settings.titleChoice10,
  }
  -- calculate the timer based on chosen values by converting from seconds+minutes into milliseconds
  TitleFlex.titleTimer = TitleFlex.settings.changeIntervalMinutes*1000*60+TitleFlex.settings.changeIntervalSeconds*1000
  if TitleFlex.titleTimer < 1000 then -- failsafe for when you somehow get a timer set to less than 1 second, potentially causing a kick
    TitleFlex.titleTimer = 60000
    TitleFlex.settings.changeIntervalMinutes = 1
    TitleFlex.settings.changeIntervalSeconds = 0
    d("TitleFlex had to reset your timer to default values due to an error.")
  end
end