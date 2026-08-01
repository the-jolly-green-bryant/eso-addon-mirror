AudibleFishBite.variableVersion = 1

local defaultSoundVars = {
  SoundFile = SOUNDS.BATTLEGROUND_MURDERBALL_TAKEN_OWN_TEAM,
}

function AudibleFishBite:InitializeSettings()
  AudibleFishBite.soundVars = LibSavedVars
    :NewAccountWide(AudibleFishBite.ADDON_NAME.."_Settings", "Sound_Account", defaultSoundVars)
    :AddCharacterSettingsToggle(AudibleFishBite.ADDON_NAME.."_Settings", "Sound_Character")
    :EnableDefaultsTrimming()
end
