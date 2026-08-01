local default = "Défaut: "
local on, off = "Activé", "Désactivé"

local lang    = {
  ExecutionPanel                 = "Exécution",
  ExecutionThreshold             = "Seuil d'exécution",
  ExecutionThresholdDesc         = "Définissez le pourcentage de santé du seuil d'exécution souhaité. \nLa mise à zéro désactivera les alertes. \n" .. default .. BUIE.Defaults.ExecutionThreshold,
  ExecutionIcon                  = "Icône d'exécution",
  ExecutionIconDesc              = "Afficher l'icône d'exécution sous la barre de santé cible pendant la phase d'exécution. \n" .. default .. (BUIE.Defaults.ExecutionIcon and on or off),
  ExecutionTargetHeader          = "Barre de santé cible",
  ExecutionChangeTargetColor     = "Modification de barre",
  ExecutionChangeTargetColorDesc = "Modification de la couleur de la barre de santé de la cible pendant la phase d'exécution.\n" .. default .. (BUIE.Defaults.ExecutionChangeTargetColor and on or off),
  ExecutionTargetColor           = "Couleur de la barre",
  ExecutionTargetColorDesc       = "Couleur de la barre de santé de la cible pendant la phase d'exécution.\n" .. default .. BUI.TranslateColor(BUIE.Defaults.ExecutionTargetColor),
  ExecutionSoundHeader           = "Notification sonore",
  ExecutionSound                 = "Jouer son",
  ExecutionSoundDesc             = "Jouez le son lorsque la phase d'exécution commence.\n" .. default .. (BUIE.Defaults.ExecutionSound and on or off),
  ExecutionSoundType             = "Son d'exécution",
  ExecutionSoundTypeDesc         = "Un son qui jouera au début de la phase d'exécution. \n" .. default .. BUIE.Defaults.ExecutionSoundType,
  ExecutionReset                 = "Réinitialiser",
  ExecutionResetDesc             = "Réinitialiser les paramètres d'exécution d'origine?",
}
BUI:JoinTables(BUI.Localization.en, lang)