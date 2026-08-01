AudibleFishBiteSettingsMenu = ZO_Object:Subclass()

function AudibleFishBiteSettingsMenu:New()
  local obj = ZO_Object.New(self)
  obj:Initialize()
  return obj
end

function AudibleFishBiteSettingsMenu:Initialize()
  self:CreateOptionsMenu()
end

local str = AudibleFishBite:GetStrings()

function AudibleFishBiteSettingsMenu:CreateOptionsMenu()
  local soundVars = AudibleFishBite.soundVars

  local panel = {
    type            = "panel",
    name            = AudibleFishBite.ADDON_TITLE,
    author          = AudibleFishBite.AUTHOR,
    version         = AudibleFishBite.VERSION,
    website         = AudibleFishBite.WEBSITE,
    donation        = AudibleFishBite.DONATION,
    feedback        = AudibleFishBite.FEEDBACK,
    slashCommand    = nil,
    registerForRefresh = true
  }

  local optionsData = {}

  table.insert(optionsData, {
    type = "header",
    name = str.SOUND_SETTINGS,
  })

  table.insert(optionsData, {
    type = 'soundslider',
    name = str.SOUND_FILE,
    tooltip = str.SOUND_FILE_INFO,
    playSound = true,
    showSoundName = true,
    saveSoundIndex = false,
    getFunc = function()
        return soundVars.SoundFile
    end,
    setFunc = function(value)
        soundVars.SoundFile = value
    end,
    default = soundVars.SoundFile,
  })

  self.settingsMenuPanel = LibAddonMenu2:RegisterAddonPanel(AudibleFishBite.ADDON_NAME.."SettingsMenuPanel", panel)
  LibAddonMenu2:RegisterOptionControls(AudibleFishBite.ADDON_NAME.."SettingsMenuPanel", optionsData)
end
