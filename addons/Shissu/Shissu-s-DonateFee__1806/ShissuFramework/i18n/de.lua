ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuFramework"] = {
  DONATE =  "Du magst dieses Addon und möchtest gerne deine Unterstützung ausdrücken? Dann sende eine Spende an @Shissu :-)",
  LEFT =    "Linke Maustaste",
  RIGHT =   "Rechte Maustaste",     
  TEXT =    "DEINTEXT",   
}

ShissuLocalization["ShissuLanguageChanger"] = {
  TITLE =   "TESO Spracheinstellungen",
  LANG =    "Sprache",
  DESC =    "Ändert die Sprache von Elder Scrolls Online auf die ausgewählte Sprache ohne das Spiel neuzustarten. %sAchtung|r: Das Interface wird direkt neugeladen.",
  SLASH =   "Alternativ lässt sich die Sprache auch im Chat mit folgendem Befehl verändern: %s/slc LANG",
}

ShissuLocalization["ShissuStandardCommands"] = {
  TITLE = "Standard Befehle",
  DESC =  "|cAFD3FF/rl|r - RELOADUI\n\n" .. 
    "|cAFD3FF/helm|r - Helm ein-/ausblenden \n\n" ..
    "|cAFD3FF/on|r - Spielerstatus " .. EsoStrings[SI_PLAYERSTATUS1] .. "\n\n" .. 
    "|cAFD3FF/off|r - Spielerstatus " .. EsoStrings[SI_PLAYERSTATUS4] .. "\n\n" ..
    "|cAFD3FF/brb|r - Spielerstatus " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
    "|cAFD3FF/dnd|r - Spielerstatus " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
    "|cAFD3FF/afk|r - Spielerstatus " .. EsoStrings[SI_PLAYERSTATUS2] .. "\n\n" ..
    
    "|cAFD3FFZufallszahl würfeln|r\n" ..
    "Würfelt eine zufällige Zahl zwischen 1 und deiner Wunschzahl. Zusätzlich lässt sich die Sprachausgabe manipulieren." .. "\n\n" .. 
    
    "|cAFD3FF/dice|r [ZAHL] [de,en,fr,ru]" .. "\n\n" .. 
    "|cAFD3FF/roll|r [ZAHL] [de,en,fr,ru]" .. "\n\n"
}

ZO_CreateStringId("SI_BINDING_NAME_SSC_helmToogle", "Helm ein- und ausblenden")
ZO_CreateStringId("SI_BINDING_NAME_SSC_offlineToogle", "Spielerstatus On-/Offline")
ZO_CreateStringId("SI_BINDING_NAME_SSC_reload", "Reload UI")