ChromaConfig.variableVersion = 1
local defaultAllianceVars = {
  Alliances = {
    [ALLIANCE_ALDMERI_DOMINION] = {
      UseCustomColor = true,
      Color = "ffd900",
    },
    [ALLIANCE_EBONHEART_PACT] = {
      UseCustomColor = true,
      Color = "ff0000",
    },
    [ALLIANCE_DAGGERFALL_COVENANT] = {
      UseCustomColor = true,
      Color = "0000ff",
    },
  },
  Teams = {
    [BATTLEGROUND_ALLIANCE_FIRE_DRAKES] = {
      UseCustomColor = true,
      Color = "ff6600",
    },
    [BATTLEGROUND_ALLIANCE_PIT_DAEMONS] = {
      UseCustomColor = true,
      Color = "70c733",
    },
    [BATTLEGROUND_ALLIANCE_STORM_LORDS] = {
      UseCustomColor = true,
      Color = "d90fff",
    },
  },
}

local defaultBackgroundVars = {
  BackgroundColor = nil,
  UseCustomColorDuringBattlegrounds = false,
}

local defaultNotificationVars = {
  DeathEffectColor = nil,
  DeathKeybindColor = nil,
  Keybinds = {
  },
}
for k,v in pairs(ChromaConfig.StaticData.Keybinds) do
  defaultNotificationVars.Keybinds[k] = {
    Color = nil,
  }
end

function ChromaConfig:InitializeSettings()
  ChromaConfig.allianceVars = LibSavedVars
    :NewAccountWide(ChromaConfig.ADDON_NAME.."_Settings", "Alliance", defaultAllianceVars)
    :EnableDefaultsTrimming()
  ChromaConfig.backgroundVars = LibSavedVars
    :NewAccountWide(ChromaConfig.ADDON_NAME.."_Settings", "Background_Account", defaultBackgroundVars)
    :AddCharacterSettingsToggle(ChromaConfig.ADDON_NAME.."_Settings", "Background_Character")
    :EnableDefaultsTrimming()
  ChromaConfig.notificationVars = LibSavedVars
    :NewAccountWide(ChromaConfig.ADDON_NAME.."_Settings", "Notification_Account", defaultNotificationVars)
    :AddCharacterSettingsToggle(ChromaConfig.ADDON_NAME.."_Settings", "Notification_Character")
    :EnableDefaultsTrimming()
end
