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
      type = "checkbox",
      name = "Use character-specific settings",
      tooltip = "If checked, settings will be saved per character. If unchecked, settings will be account-wide.",
      getFunc = function() return TitleFlex.settings.useCharacterSettings end,
      setFunc = function(value)
        if TitleFlex.settings.useCharacterSettings == value then return end
        
        -- Switch between account-wide and character-specific settings
        if value then
          -- Switching to character-specific - copy account settings
          local charSettings = ZO_SavedVars:NewCharacterIdSettings("TitleFlexSavedVariables", TitleFlex.varVersion, nil, TitleFlex.settings)
          for k,v in pairs(TitleFlex.settings) do
            charSettings[k] = v
          end
          charSettings.useCharacterSettings = true
          TitleFlex.settings = charSettings
        else
          -- Switching to account-wide - copy character settings
          local accountSettings = ZO_SavedVars:NewAccountWide("TitleFlexSavedVariables", TitleFlex.varVersion, nil, TitleFlex.settings)
          for k,v in pairs(TitleFlex.settings) do
            accountSettings[k] = v
          end
          accountSettings.useCharacterSettings = false
          TitleFlex.settings = accountSettings
        end
        
        TitleFlex.ReloadSettings()
      end,
      default = false,
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
  }

  -- Dynamically add dropdowns for all 100 titles
  for i = 1, TitleFlex.maxTitles do
    table.insert(optionControls, {
      type = 'dropdown',
      name = 'Title ' .. i,
      tooltip = 'Title ' .. i .. ' in the rotation',
      choices = TitleFlex.titleChoices,
      scrollable = true,
      getFunc = function() return TitleFlex.settings["titleChoice" .. i] end,
      setFunc = function(selected)
        for index, name in ipairs(TitleFlex.titleChoices) do
          if name == selected then
            TitleFlex.settings["titleChoice" .. i] = name
            TitleFlex.ReloadSettings()
            break
          end
        end
      end,
      default = TitleFlex.settings["titleChoice" .. i],
    })
  end

  LAM2:RegisterAddonPanel('TitleFlexPanel', addonPanel)
  LAM2:RegisterOptionControls('TitleFlexPanel', optionControls)
end

function TitleFlex.SettingsLoad() --set the default settings, then load if there are any saved previously
  local defaultSettings = {
    changeIntervalSeconds = 0,
    changeIntervalMinutes = 1,
    enableRotation = true,
    useCharacterSettings = false,
  }

  -- Initialize default settings for all titles
  for i = 1, TitleFlex.maxTitles do
    defaultSettings["titleChoice" .. i] = GetString(SI_STATS_NO_TITLE)
  end

  -- First load account-wide settings
  local accountSettings = ZO_SavedVars:NewAccountWide('TitleFlexSavedVariables', TitleFlex.varVersion, nil, defaultSettings)
  
  -- Check if we should use character-specific settings
  if accountSettings.useCharacterSettings then
    -- Load character-specific settings, using account settings as defaults
    TitleFlex.settings = ZO_SavedVars:NewCharacterIdSettings('TitleFlexSavedVariables', TitleFlex.varVersion, nil, accountSettings)
  else
    TitleFlex.settings = accountSettings
  end

  -- Initialize titleList with all titles
  TitleFlex.titleList = {}
  for i = 1, TitleFlex.maxTitles do
    TitleFlex.titleList[i] = TitleFlex.settings["titleChoice" .. i]
  end

  -- Calculate the timer based on chosen values
  TitleFlex.titleTimer = TitleFlex.settings.changeIntervalMinutes * 60000 + TitleFlex.settings.changeIntervalSeconds * 1000
  if TitleFlex.titleTimer < 1000 then -- failsafe for invalid timer values
    TitleFlex.titleTimer = 60000
    TitleFlex.settings.changeIntervalMinutes = 1
    TitleFlex.settings.changeIntervalSeconds = 0
    d("TitleFlex had to reset your timer to default values due to an error.")
  end
end