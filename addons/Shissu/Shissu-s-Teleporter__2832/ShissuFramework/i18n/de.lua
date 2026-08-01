-- Automatische Generierung
ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuFramework"] = {
  DONATE  = "Du magst dieses Addon und möchtest gerne deine Unterstützung ausdrücken? Dann sende eine Spende an @Shissu :-)",
  LEFT    = "Linke Maustaste",
  RIGHT   = "Rechte Maustaste",     
  MIDDLE  = "Mittlere Maustaste",

  NOTE    = "Notizbuch",
  FILTER  = "Chat-Filter Protokoll",

  TEXT    = "DEINTEXT",   
  INFO    = "Information",
  ERR     = "FEHLER",
  MISSING = "Datei %1 nicht gefunden.",

  ADD     = "Hinzufügen",
  DELETE  = "Entfernen",
  SAVE    = "Speichern",
}

ShissuLocalization["ShissuFileIntegrity"] = {
  TITLE   = "Datenintegrität",
  FILES   = "Dateien",
  INFO    = "Die folgenden Dateien wurden (nicht) erfolgreich geladen. Bei fehlenden Dateien ist die Funktionsfähigkeit der einzelnen Module nicht gewährleistet. Bitte installieren Sie das Addon neu.",
}

ShissuLocalization["ShissuLanguageChanger"] = {
  TITLE   = "TESO Spracheinstellungen",
  LANG    = "Sprache",
  DESC    = "Ändert die Sprache von Elder Scrolls Online auf die ausgewählte Sprache ohne das Spiel neuzustarten.",
  SLASH   = "Alternativ lässt sich die Sprache auch im Chat mit folgendem Befehl verändern: %1/slc LANG",
  WARNING = "%1Achtung|r: Das Interface wird direkt neugeladen.",
}

ShissuLocalization["ShissuStandardCommands"] = {
  TITLE   = "Standardbefehle im Chat",
  DESC    = "|cAFD3FF/rl|r - RELOADUI\n\n" .. 
            "|cAFD3FF/on|r - Spielerstatus " .. EsoStrings[SI_PLAYERSTATUS1] .. "\n\n" .. 
            "|cAFD3FF/off|r - Spielerstatus " .. EsoStrings[SI_PLAYERSTATUS4] .. "\n\n" ..
            "|cAFD3FF/brb|r - Spielerstatus " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
            "|cAFD3FF/dnd|r - Spielerstatus " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
            "|cAFD3FF/afk|r - Spielerstatus " .. EsoStrings[SI_PLAYERSTATUS2] .. "\n\n" ..
            
            "|cAFD3FFZufallszahl würfeln|r\n" ..
            "Würfelt eine zufällige Zahl zwischen 1 und deiner Wunschzahl. Zusätzlich lässt sich die Sprachausgabe manipulieren." .. "\n\n" .. 
            
            "|cAFD3FF/dice|r [ZAHL] [de,en,es,fr,jp,ru]" .. "\n\n" .. 
            "|cAFD3FF/roll|r [ZAHL] [de,en,es,fr,jp,ru]" .. "\n\n",

  DE_DICE  = "%1 hat bei einem Zufallswurf (1-%2) die Zahl %3 erwürfelt.",
  EN_DICE  = "%1 has rolled the number %3 on a random roll (1-%2).",
  ES_DICE  = "%1 ha rodado el número %3 en un rodaje aleatorio (1-%2).",
  FR_DICE  = "%1 roule le nombre %3 dans un jet alkatoire de 1-%2.",
  JP_DICE  = "%1 はランダムに %3 を転がしました (1-%2)。",
  RU_DICE  = "%1 выкатила число %3 на случайном отрезке (1-%2).",
}

ZO_CreateStringId("SI_BINDING_NAME_SSC_offlineToogle", "Spielerstatus On-/Offline")
ZO_CreateStringId("SI_BINDING_NAME_SSC_reload", "Reload UI")