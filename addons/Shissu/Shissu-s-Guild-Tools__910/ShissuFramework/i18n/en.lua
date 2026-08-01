-- Automatische Generierung
ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuFramework"] = {
  DONATE  = "Feedback? You like this addon and would like to express your support? Then send a donation to @Shissu :-)",
  LEFT    = "Left mouse click",
  RIGHT   = "Right mouse click",     
  MIDDLE  = "Middle mouse button",

  NOTE    = "Notebook",
  FILTER  = "Chat Filter Protocol",

  TEXT    = "YOURTEXT",   
  INFO    = "Info",
  ERR     = "ERROR",
  MISSING = "File %1 not found.",

  ADD     = "Add",
  DELETE  = "Remove",
  SAVE    = "Save",
}

ShissuLocalization["ShissuFileIntegrity"] = {
  TITLE   = "File integrity",
  FILES   = "Files",
  INFO    = "The following files were (not) loaded successfully. If the files are missing, the functionality of each module is not guaranteed. Please reinstall the addon.",
}

ShissuLocalization["ShissuLanguageChanger"] = {
  TITLE   = "TESO Language settings",
  LANG    = "Language",
  DESC    = "Changes the language of Elder Scrolls Online to the selected language without restarting the game",
  SLASH   = "Alternatively, the language can also be changed in the chat using the following command: %1/slc LANG",
  WARNING = "%1Attention|r: The interface is reloaded directly.",
}

ShissuLocalization["ShissuStandardCommands"] = {
  TITLE   = "Standard commands",
  DESC    = "|cAFD3FF/rl|r - RELOADUI\n\n" .. 
            "|cAFD3FF/on|r - Player status " .. EsoStrings[SI_PLAYERSTATUS1] .. "\n\n" .. 
            "|cAFD3FF/off|r - Player status " .. EsoStrings[SI_PLAYERSTATUS4] .. "\n\n" ..
            "|cAFD3FF/brb|r - Player status " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
            "|cAFD3FF/dnd|r - Player status " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
            "|cAFD3FF/afk|r - Player status " .. EsoStrings[SI_PLAYERSTATUS2] .. "\n\n" ..
            
            "|cAFD3FFDice randomly|r\n" ..
            "Roll a random number between 1 and your desired number. You can also manipulate the voice output." .. "\n\n" .. 
            
            "|cAFD3FF/dice|r [NUMBER] [de,en,es,fr,jp,ru]" .. "\n\n" .. 
            "|cAFD3FF/roll|r [NUMBER] [de,en,es,fr,jp,ru]" .. "\n\n",

  DE_DICE  = "%1 hat bei einem Zufallswurf (1-%2) die Zahl %3 erwürfelt.",
  EN_DICE  = "%1 has rolled the number %3 on a random roll (1-%2).",
  ES_DICE  = "%1 ha rodado el número %3 en un rodaje aleatorio (1-%2).",
  FR_DICE  = "%1 roule le nombre %3 dans un jet alkatoire de 1-%2.",
  JP_DICE  = "%1 はランダムに %3 を転がしました (1-%2)。",
  RU_DICE  = "%1 выкатила число %3 на случайном отрезке (1-%2).",
}

ZO_CreateStringId("SI_BINDING_NAME_SSC_offlineToogle", "Player status on-/offline")
ZO_CreateStringId("SI_BINDING_NAME_SSC_reload", "Reload UI")