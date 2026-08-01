ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuFramework"] = {
  DONATE =     "Vous aimez cet addon et vous voulez exprimer votre soutien? Envoyez ensuite un don à @Shissu: -)",
    LEFT =    "Bouton gauche de la souris",
  RIGHT =   "Bouton droit de la souris",    
  TEXT =    "VOTRE TEXTE",    
}

ShissuLocalization["ShissuLanguageChanger"] = {
  TITLE =   "TESO paramètres linguistiques",
  LANG =    "Langue",
  DESC =    "Change la langue de Elder Scrolls Online à la langue sélectionnée sans redémarrer le jeu. %sappel|r: L'interface est rechargée directement.",
  SLASH =   "Alternativement, la langue peut aussi être changée dans le chat avec la commande suivante: %s/slc LANG",
}

ShissuLocalization["ShissuStandardCommands"] = {
  TITLE = "Commandes standard",
  DESC = "|cAFD3FF/rl|r - RELOADUI\n\n" .. 
    "|cAFD3FF/helm|r - Afficher/masquer le casque \n\n" .. 
    "|cAFD3FF/on|r - Statut du joueur " .. EsoStrings[SI_PLAYERSTATUS1] .. "\n\n" .. 
    "|cAFD3FF/off|r - Statut du joueur " .. EsoStrings[SI_PLAYERSTATUS4] .. "\n\n" ..
    "|cAFD3FF/brb|r - Statut du joueur " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
    "|cAFD3FF/dnd|r - Statut du joueur " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
    "|cAFD3FF/afk|r - Statut du joueur " .. EsoStrings[SI_PLAYERSTATUS2] ..
    
    "|cAFD3FFNombre de dés|r\n" ..
    "Désaccorde un nombre aléatoire entre 1 et le nombre désiré. De plus, la sortie vocale peut être manipulée." .. "\n\n" .. 
    
    "|cAFD3FF/dice|r [NUMBER] [de,en,fr,ru]" .. "\n\n" .. 
    "|cAFD3FF/roll|r [NUMBER] [de,en,fr,ru]" .. "\n\n",
}

ZO_CreateStringId("SI_BINDING_NAME_SSC_helmToogle", "Montrer et cacher un casque")
ZO_CreateStringId("SI_BINDING_NAME_SSC_offlineToogle", "Statut du joueur en ligne/hors ligne")
ZO_CreateStringId("SI_BINDING_NAME_SSC_reload", "Reload UI")