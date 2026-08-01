ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_TOGGLE", "Montrer/Cacher la Fenêtre")
for i = 1, 12 do
  ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_SET_"..i, "Utiliser l'ensemble "..i)
end

DressingRoom._msg = {
  weaponType = {
    [WEAPONTYPE_AXE] = "Hache",
    [WEAPONTYPE_BOW] = "Arc",
    [WEAPONTYPE_DAGGER] = "Dague",
    [WEAPONTYPE_FIRE_STAFF] = "Bâton Infernal",
    [WEAPONTYPE_FROST_STAFF] = "Bâton de Glace",
    [WEAPONTYPE_HAMMER] = "Marteau",
    [WEAPONTYPE_HEALING_STAFF] = "Bâton de Rétablissement",
    [WEAPONTYPE_LIGHTNING_STAFF] = "Bâton de Foudre",
    [WEAPONTYPE_NONE] = "Aucune",
    [WEAPONTYPE_RUNE] = "Rune", -- ??
    [WEAPONTYPE_SHIELD] = "Bouclier",
    [WEAPONTYPE_SWORD] = "Epée",
    [WEAPONTYPE_TWO_HANDED_AXE] = "Hache de Bataille",
    [WEAPONTYPE_TWO_HANDED_HAMMER] = "Masse",
    [WEAPONTYPE_TWO_HANDED_SWORD] = "Epée Longue",
  },
  
  skillBarSaved = "Ensemble de compétences %d, barre %d sauvegardée",
  skillBarLoaded = "Ensemble de compétences %d, barre %d chargée",
  skillBarDeleted = "Ensemble de compétences %d, barre %d effacée",
  gearSetSaved = "Ensemble d'équipement %d sauvegardé",
  gearSetLoaded = "Ensemble d'équipement %d chargé",
  gearSetDeleted = "Ensemble d'équipement %d effacé",
  noGearSaved = "Aucun équipement sauvegardé pour l'ensemble %d",
  
  options = {
    reloadUIWarning = "Nécessite de recharger l'IU",
    reloadUI = "Recharger l'IU",
    clearEmptyGear = {
      name = "Déséquiper les slots d'équipement",
      tooltip = "Au chargement d'un ensemble d'équipement, ne pas conserver l'équipement précédent pour les emplacements sauvegardés vides",
    },
    clearEmptySkill = {
      name = "Vider les slots de compétence",
      tooltip = "Au chargement d'une barre de compétence, restaurer les emplacements de compétences vides au lieu de conserver les compétences précédemment actives",
    },
    activeBarOnly = {
      name = "Boutons de la barre active seulement",
      tooltip = "Ne montre les boutons des sets de compétences que pour la barre active",
    },
    fontSize = {
      name = "Taille de la police",
      tooltip = "Taille de la police de caractères de l'interface",
    },
    btnSize = {
      name = "Taille des icônes",
      tooltip = "Taille des icônes de compétences",
    },
    columnMajorOrder = {
      name = "Classer les ensembles par colonne",
      tooltip = "Classer les ensembles par ligne (horizontalement) ou par colonne (verticalement) d'abord",
    },
    openWithSkillsWindow = {
      name = "Afficher avec la fenêtre des compétences",
      tooltip = "Affiche automatiquement l'interface lors de l'ouverture de la fenêtre des compétences",
    },
    openWithInventoryWindow = {
      name = "Afficher avec la fenêtre d'inventaire",
      tooltip = "Affiche automatiquement l'interface lors de l'ouverture de la fenêtre d'inventaire",
    },
    numRows = {
      name = "Nombre de lignes",
      tooltip = "Nombre d'ensembles par colonne dans la fenêtre",
    },
    numCols = {
      name = "Nombre de colonnes",
      tooltip = "Nombre d'ensembles par ligne dans la fenêtre",
    },
    showChatMessages = {
      name = "Afficher les messages dans le chat",
      tooltip = "Affiche un message dans le chat lorsque vous sauvez, équipez ou supprimez un ensemble d'équipement ou une barre de compétences",
    },
    singleBarToCurrent = {
      name = "Equiper les sets mono-barre sur la barre active",
      tooltip = "Lorsque vous équipez un set avec une seule barre de compétences et aucun équipement, la barre de compétence active sera modifiée et la barre vide sera ignorée",
    },
  },
  
  barBtnText = "Clic pour charger cette barre de compétences\nMaj + Clic pour sauvegarder\nCtrl + Clic pour effacer",
  gearBtnText = "Clic pour charger l'ensemble\nMaj + Clic pour sauvegarder l'ensemble\nCtrl + Clic pour effacer l'ensemble",
  setBtnText = "Clic pour mettre l'ensemble et charger les deux barres de compétences",
}

