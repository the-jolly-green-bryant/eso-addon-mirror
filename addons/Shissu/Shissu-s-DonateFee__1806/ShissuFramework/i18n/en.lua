ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuFramework"] = {
  DONATE =          "You like this addon and want to show your support? Then send a donation to @Shissu :-)",
  LEFT =    "Linke Maustaste",
  RIGHT =   "Rechte Maustaste",
  TEXT =    "YOURTEXT",        
}

ShissuLocalization["ShissuLanguageChanger"] = {
  TITLE =   "TESO language settings",
  LANG =    "Language",
  DESC =    "Changes the language of Elder Scrolls Online to the selected language without restarting the game. %sAttention|r: The interface is reloaded directly.",
  SLASH =   "Alternatively, the language can also be changed in chat with the following command: %s/slc LANG",
}

ShissuLocalization["ShissuStandardCommands"] = {
  TITLE = "Standard Commands",
  DESC = "|cAFD3FF/rl|r - RELOADUI\n\n" .. 
    "|cAFD3FF/helm|r - Toogle helm \n\n" .. 
    "|cAFD3FF/on|r - Player status " .. EsoStrings[SI_PLAYERSTATUS1] .. "\n\n" .. 
    "|cAFD3FF/off|r - Player status " .. EsoStrings[SI_PLAYERSTATUS4] .. "\n\n" ..
    "|cAFD3FF/brb|r - Player status " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
    "|cAFD3FF/dnd|r - Player status " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
    "|cAFD3FF/afk|r - Player status " .. EsoStrings[SI_PLAYERSTATUS2] ..
    
    "|cAFD3FFNumber dice|r\n" ..
    "Dices a random number between 1 and your desired number. In addition, the speech output can be manipulated." .. "\n\n" .. 
    
    "|cAFD3FF/dice|r [NUMBER] [de,en,fr,ru]" .. "\n\n" .. 
    "|cAFD3FF/roll|r [NUMBER] [de,en,fr,ru]" .. "\n\n",
}

ZO_CreateStringId("SI_BINDING_NAME_SSC_helmToogle", "Show and hide helmet")
ZO_CreateStringId("SI_BINDING_NAME_SSC_offlineToogle", "Player status online/offline")
ZO_CreateStringId("SI_BINDING_NAME_SSC_reload", "Reload UI")