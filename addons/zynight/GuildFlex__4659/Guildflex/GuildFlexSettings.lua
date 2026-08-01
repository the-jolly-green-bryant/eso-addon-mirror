function GuildFlex.SettingsBuildGuildTable()
  -- Rebuild the list of guilds the player currently belongs to.
  -- First entry is always "None" (no guild displayed).
  GuildFlex.guildChoices = {}
  GuildFlex.guildChoices[1] = "None"
  for i = 1, GetNumGuilds() do
    local guildId = GetGuildId(i)
    GuildFlex.guildChoices[i + 1] = GetGuildName(guildId)
  end
end

function GuildFlex.SettingsBuildMenu()
  local LAM2 = LibAddonMenu2

  local addonPanel = {
    type                = "panel",
    name                = GuildFlex.name,
    displayName         = ZO_ColorDef:New("3366cc"):Colorize(GuildFlex.name),
    version             = GuildFlex.version,
    registerForRefresh  = true,
    registerForDefaults = true,
  }

  local optionControls = {
    {
      type    = "checkbox",
      name    = "Enable rotation",
      tooltip = "Whether or not to rotate the displayed guild name based on the settings below.",
      getFunc = function() return GuildFlex.settings.enableRotation end,
      setFunc = function(value)
        GuildFlex.settings.enableRotation = value
        GuildFlex.EnableRotation(value)
      end,
    },
    {
      type    = "checkbox",
      name    = "Use character-specific settings",
      tooltip = "If checked, settings will be saved per character. If unchecked, settings will be account-wide.",
      getFunc = function() return GuildFlex.settings.useCharacterSettings end,
      setFunc = function(value)
        if GuildFlex.settings.useCharacterSettings == value then return end

        if value then
          -- Switching to character-specific: seed with current account settings
          local charSettings = ZO_SavedVars:NewCharacterIdSettings("GuildFlexSavedVariables", GuildFlex.varVersion, nil, GuildFlex.settings)
          for k, v in pairs(GuildFlex.settings) do
            charSettings[k] = v
          end
          charSettings.useCharacterSettings = true
          GuildFlex.settings = charSettings
        else
          -- Switching to account-wide: copy character settings back
          local accountSettings = ZO_SavedVars:NewAccountWide("GuildFlexSavedVariables", GuildFlex.varVersion, nil, GuildFlex.settings)
          for k, v in pairs(GuildFlex.settings) do
            accountSettings[k] = v
          end
          accountSettings.useCharacterSettings = false
          GuildFlex.settings = accountSettings
        end

        GuildFlex.ReloadSettings()
      end,
      default = false,
    },
    {
      type    = "slider",
      name    = "Change Interval (seconds)",
      min     = 1,
      max     = 60,
      step    = 1,
      getFunc = function() return GuildFlex.settings.changeIntervalSeconds end,
      setFunc = function(number)
        GuildFlex.settings.changeIntervalSeconds = number
        GuildFlex.ReloadSettings()
      end,
    },
    {
      type    = "slider",
      name    = "Change Interval (minutes)",
      min     = 0,
      max     = 59,
      step    = 1,
      getFunc = function() return GuildFlex.settings.changeIntervalMinutes end,
      setFunc = function(number)
        GuildFlex.settings.changeIntervalMinutes = number
        GuildFlex.ReloadSettings()
      end,
    },
  }

  -- One dropdown per possible guild slot (ESO max = 5)
  for i = 1, GuildFlex.maxGuilds do
    local slotIndex = i  -- capture for closures
    table.insert(optionControls, {
      type     = "dropdown",
      name     = "Guild " .. slotIndex,
      tooltip  = "Guild " .. slotIndex .. " in the rotation.",
      choices  = GuildFlex.guildChoices,
      scrollable = true,
      getFunc  = function() return GuildFlex.settings["guildChoice" .. slotIndex] end,
      setFunc  = function(selected)
        GuildFlex.settings["guildChoice" .. slotIndex] = selected
        GuildFlex.ReloadSettings()
      end,
      default  = "None",
    })
  end

  LAM2:RegisterAddonPanel("GuildFlexPanel", addonPanel)
  LAM2:RegisterOptionControls("GuildFlexPanel", optionControls)
end

function GuildFlex.SettingsLoad()
  local defaultSettings = {
    changeIntervalSeconds = 0,
    changeIntervalMinutes = 1,
    enableRotation        = true,
    useCharacterSettings  = false,
  }

  -- Default: no guild selected in any slot
  for i = 1, GuildFlex.maxGuilds do
    defaultSettings["guildChoice" .. i] = "None"
  end

  -- Load account-wide settings first
  local accountSettings = ZO_SavedVars:NewAccountWide("GuildFlexSavedVariables", GuildFlex.varVersion, nil, defaultSettings)

  -- Optionally fall back to per-character settings
  if accountSettings.useCharacterSettings then
    GuildFlex.settings = ZO_SavedVars:NewCharacterIdSettings("GuildFlexSavedVariables", GuildFlex.varVersion, nil, accountSettings)
  else
    GuildFlex.settings = accountSettings
  end

  -- Initialise guildList from settings
  GuildFlex.guildList = {}
  for i = 1, GuildFlex.maxGuilds do
    GuildFlex.guildList[i] = GuildFlex.settings["guildChoice" .. i]
  end

  -- Calculate the rotation timer
  GuildFlex.guildTimer = GuildFlex.settings.changeIntervalMinutes * 60000
                       + GuildFlex.settings.changeIntervalSeconds * 1000
  if GuildFlex.guildTimer < 1000 then  -- failsafe: never allow a sub-second timer
    GuildFlex.guildTimer = 60000
    GuildFlex.settings.changeIntervalMinutes = 1
    GuildFlex.settings.changeIntervalSeconds = 0
    d("GuildFlex had to reset your timer to default values due to an error.")
  end
end
