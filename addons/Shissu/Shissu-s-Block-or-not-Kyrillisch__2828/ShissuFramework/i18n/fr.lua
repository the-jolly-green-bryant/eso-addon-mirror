-- Automatische Generierung
ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuFramework"] = {
  DONATE  = "Vous aimez cet addon et souhaitez exprimer votre soutien ? Envoyez ensuite un don à @Shissu :-)",
  LEFT    = "Souris gauche",
  RIGHT   = "Souris droite",     
  MIDDLE  = "Clic du milieu",

  NOTE    = "Notebook",
  FILTER  = "Protocole de filtrage",

  TEXT    = "VOTRETEXTE",   
  INFO    = "Informations",
  ERR     = "ERREUR",
  MISSING = "Fichier %1 non trouvé.",

  ADD     = "Ajouter",
  DELETE  = "Supprimer",
  SAVE    = "Sauvegarder",
}

ShissuLocalization["ShissuFileIntegrity"] = {
  TITLE   = "Intégrité des fichiers",
  FILES   = "Fichiers",
  INFO    = "Les fichiers suivants ont été (non) chargés avec succès. Si ces fichiers sont manquants, la fonctionnalité des différents modules ne peut être garantie. Veuillez réinstaller l'addon.",
}

ShissuLocalization["ShissuLanguageChanger"] = {
  TITLE   = "TESO Paramètres linguistiques",
  LANG    = "Langue",
  DESC    = "Change la langue de Elder Scrolls Online à la langue sélectionnée sans redémarrer le jeu.",
  SLASH   = "Il est également possible de changer la langue dans le chat avec la commande suivante : %1/slc LANG",
  WARNING = "%1A l'attention de|r: L'interface est rechargée directement.",
}

ShissuLocalization["ShissuStandardCommands"] = {
  TITLE   = "Commandes standard",
  DESC    = "|cAFD3FF/rl|r - RELOADUI\n\n" .. 
            "|cAFD3FF/on|r - Statut " .. EsoStrings[SI_PLAYERSTATUS1] .. "\n\n" .. 
            "|cAFD3FF/off|r - Statut " .. EsoStrings[SI_PLAYERSTATUS4] .. "\n\n" ..
            "|cAFD3FF/brb|r - Statut " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
            "|cAFD3FF/dnd|r - Statut " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
            "|cAFD3FF/afk|r - Statut " .. EsoStrings[SI_PLAYERSTATUS2] .. "\n\n" ..
            
            "|cAFD3FFlancer un nombre aléatoire|r\n" ..
            "Faites rouler un nombre aléatoire entre 1 et le nombre que vous souhaitez. Vous pouvez également manipuler la sortie vocale." .. "\n\n" .. 
            
            "|cAFD3FF/dice|r [NUMÉRO] [de,en,es,fr,jp,ru]" .. "\n\n" .. 
            "|cAFD3FF/roll|r [NUMÉRO] [de,en,es,fr,jp,ru]" .. "\n\n",

  DE_DICE  = "%1 hat bei einem Zufallswurf (1-%2) die Zahl %3 erwürfelt.",
  EN_DICE  = "%1 has rolled the number %3 on a random roll (1-%2).",
  ES_DICE  = "%1 ha rodado el número %3 en un rodaje aleatorio (1-%2).",
  FR_DICE  = "%1 roule le nombre %3 dans un jet alkatoire de 1-%2.",
  JP_DICE  = "%1 はランダムに %3 を転がしました (1-%2)。",
  RU_DICE  = "%1 выкатила число %3 на случайном отрезке (1-%2).",
}

ZO_CreateStringId("SI_BINDING_NAME_SSC_offlineToogle", "Statut du joueur On-/Offline")
ZO_CreateStringId("SI_BINDING_NAME_SSC_reload", "Reload UI")