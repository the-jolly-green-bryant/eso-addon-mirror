local localizedStrings = {
  ["en"] = {
    SOUND_SETTINGS = "Sound Settings",
    SOUND_FILE = "Sound File",
    SOUND_FILE_INFO = "This is the sound that will be played when you have a fish on the line."
  },
}

function AudibleFishBite:GetStrings()
  local lang = GetCVar("language.2")
  return localizedStrings[lang]
end
