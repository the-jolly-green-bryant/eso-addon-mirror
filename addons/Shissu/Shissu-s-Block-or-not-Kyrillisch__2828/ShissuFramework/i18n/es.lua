-- Automatische Generierung
ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuFramework"] = {
  DONATE  = "¿Te gusta este addon y te gustaría expresar tu apoyo? Entonces envía una donación a @Shissu :-)",
  LEFT    = "Clic de ratón (Izquierda)",
  RIGHT   = "Clic de ratón (Derecho)",     
  MIDDLE  = "El botón central del ratón",

  NOTE    = "Cuaderno",
  FILTER  = "Protocolo de filtro de chat",

  TEXT    = "TUTEXTO",   
  INFO    = "Información",
  ERR     = "ERROR",
  MISSING = "Archivo %1 no encontrado.",

  ADD     = "Añades",
  DELETE  = "Retire",
  SAVE    = "Guardar",
}

ShissuLocalization["ShissuFileIntegrity"] = {
  TITLE   = "Integridad del archivo",
  FILES   = "Archivos",
  INFO    = "Los siguientes archivos fueron (no) cargados con éxito. Si estos archivos faltan, no se puede garantizar la funcionalidad de los módulos individuales. Por favor, reinstale el addon.",
}

ShissuLocalization["ShissuLanguageChanger"] = {
  TITLE   = "TESO Configuración del idioma",
  LANG    = "Idioma",
  DESC    = "Cambia el idioma de Elder Scrolls Online al idioma seleccionado sin reiniciar el juego.",
  SLASH   = "Alternativamente, el lenguaje también puede ser cambiado en el chat con el siguiente comando: %1/slc LANG",
  WARNING = "%1Atención|r: La interfaz se recarga directamente.",
}

ShissuLocalization["ShissuStandardCommands"] = {
  TITLE   = "Comandos estándar",
  DESC    = "|cAFD3FF/rl|r - RELOADUI\n\n" .. 
            "|cAFD3FF/on|r - Estado del jugador " .. EsoStrings[SI_PLAYERSTATUS1] .. "\n\n" .. 
            "|cAFD3FF/off|r - Estado del jugador " .. EsoStrings[SI_PLAYERSTATUS4] .. "\n\n" ..
            "|cAFD3FF/brb|r - Estado del jugador " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
            "|cAFD3FF/dnd|r - Estado del jugador " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
            "|cAFD3FF/afk|r - Estado del jugador " .. EsoStrings[SI_PLAYERSTATUS2] .. "\n\n" ..
            
            "|cAFD3FFlanzar un número al azar|r\n" ..
            "Lanza un número al azar entre el 1 y el número deseado. También puedes manipular la salida de voz." .. "\n\n" .. 
            
            "|cAFD3FF/dice|r [NÚMERO] [de,en,es,fr,jp,ru]" .. "\n\n" .. 
            "|cAFD3FF/roll|r [NÚMERO] [de,en,es,fr,jp,ru]" .. "\n\n",

  DE_DICE  = "%1 hat bei einem Zufallswurf (1-%2) die Zahl %3 erwürfelt.",
  EN_DICE  = "%1 has rolled the number %3 on a random roll (1-%2).",
  ES_DICE  = "%1 ha rodado el número %3 en un rodaje aleatorio (1-%2).",
  FR_DICE  = "%1 roule le nombre %3 dans un jet alkatoire de 1-%2.",
  JP_DICE  = "%1 はランダムに %3 を転がしました (1-%2)。",
  RU_DICE  = "%1 выкатила число %3 на случайном отрезке (1-%2).",
}

ZO_CreateStringId("SI_BINDING_NAME_SSC_offlineToogle", "Estado del jugador On-/Offline")
ZO_CreateStringId("SI_BINDING_NAME_SSC_reload", "Reload UI")