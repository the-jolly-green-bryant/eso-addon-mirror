ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_TOGGLE", "Montrer/Cacher la Fenêtre")
for i = 1, 24 do
  ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_SET_"..i, "Utiliser l'ensemble "..i)
end
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_UNDRESS", "Unequip All Gear")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_PAGE_SELECT_PREVIOUS", "Select Previous Page")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_PAGE_SELECT_NEXT", "Select Next Page")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_CANCEL_PENDING_LOAD", "Cancel Pending Load")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_TOGGLE_GROUP_ROLE", "Toggle Group Role")

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
  
  loadingSet = "Loading set %s...",
  skillBarSaved = "Ensemble de compétences %d, barre %d sauvegardée",
  skillBarLoaded = "Ensemble de compétences %d, barre %d chargée",
  skillBarDeleted = "Ensemble de compétences %d, barre %d effacée",
  gearSetSaved = "Ensemble d'équipement %d sauvegardé",
  gearSetLoaded = "Ensemble d'équipement %d chargé",
  gearSetDeleted = "Ensemble d'équipement %d effacé",
  noGearSaved = "Aucun équipement sauvegardé pour l'ensemble %d",
  
  options = {
    reloadUIWarning = "Nécessite de recharger l'IU",
    autoReloadUIWarning = "This option will reload your UI automatically!",
    reloadUI = "Recharger l'IU",
    accountWideSettings = {
      name = "Account-wide settings",
      tooltip = "Use the same behaviour and UI settings for each character\nChanging this will not affect your saved presets",
    },
    sectionBehaviour = "Behaviour settings",
    autoRechargeWeapons = {
      name = "Automatically recharge weapons",
      tooltip = "When your weapon enchantment runs out, automatically use a soul gem to recharge it",
    },
    clearEmptyGear = {
      name = "Déséquiper les slots d'équipement",
      tooltip = "Au chargement d'un ensemble d'équipement, ne pas conserver l'équipement précédent pour les emplacements sauvegardés vides",
    },
    clearEmptyPoisons = {
      name = "Déséquiper les slots de poisons",
      tooltip = "Au chargement d'un ensemble d'armes, ne pas conserver les poisons précédent pour les emplacements sauvegardés vides",
    },
    clearEmptySkill = {
      name = "Vider les slots de compétence",
      tooltip = "Au chargement d'une barre de compétence, restaurer les emplacements de compétences vides au lieu de conserver les compétences précédemment actives",
    },
    ignoreAppearanceSlot = {
      name = "Ignore appearance slot",
      tooltip = "Do not equip or unequip disguises or guild tabards",
    },
    enableOutfits = {
      name = "Save/load outfits",
      tooltip = "Save and load the active outfit with gear presets",
    },
    disableInCombat = {
      name = "Disable in combat",
      tooltip = "Disable loading skill and/or gear sets while in combat, instead of postponing the action until combat has ended",
    },
    sectionUI = "UI settings",
    showNotificationArea = {
      name = "Show notification area",
      tooltip = "Display the notification area and the name of the currently loaded preset",
    },
    lockNotificationArea = {
      name = "Lock notification area",
      tooltip = "Lock the UI position of the notification area",
    },
    activeBarOnly = {
      name = "Boutons de la barre active seulement",
      tooltip = "Ne montre les boutons des sets de compétences que pour la barre active",
    },
    lockWindowPosition = {
      name = "Lock Window Position",
      tooltip = "Lock the window position so it can't be dragged",
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
    autoCloseOnMovement = {
      name = "Auto close on movement",
      tooltip = "Automatically close the Dressing Room window if you start moving",
    },
    enablePages = {
      name = "Enable pages",
      tooltip = "Disabling this will not clear your existing pages, they will only be hidden until you enable this again",
    },
    confirmPageDelete = {
      name = "Confirm page delete",
      tooltip = "Display a confirmation prompt when deleting a page",
    },
    alwaysChangePageOnZoneChanged = {
      name = "Always change page on zone change",
      tooltip = "If there is no preset with the name of the new zone that you arrived in, load the default (first) page",
    },
    useOldUI = {
      name = "Use old UI",
      tooltip = "Use the original page picker",
    },
    roleSpecificPresets = {
      name = "Enable role-specific pages",
      tooltip = "Display separate alternative pages for each group role",
    },
    roleFromLFGTool = {
      name = "Auto-select role by LFG tool",
      tooltip = "Select the appropriate alternative page automatically upon changing your group role in the LFG tool",
    },
    autoSaveChangesOnClose = {
      name = "Auto save changes on window close",
      tooltip = "Automatically save all your changes when you close the Dressing Room window.\n|cff8000Note that you always need to reload UI or log out to save data to disk.|r",
    },
    expertFeatures = "Expert features",
    enableExpertFeatures = {
      name = "Enable expert features",
      tooltip = "I have read all warnings, and made a backup of my Dressing Room SavedVariables",
    },
    changeDefaultRole = {
      name = "Change default role",
      tooltip = "You can use this if you selected a wrong default role.",
    },
    exchangePages = {
      name = "Exchange pages",
      tooltip = "This will *swap* all your \"%s\" presets with the selected one.",
    },
    purgeCharacterData = {
      name = "|cff0000Purge character data|r",
      tooltip = "Delete all pages and presets, and reset all settings for this character\n\nKey bindings will not be changed",
    },
    importPresetsFromCharacter = {
      name = "Import presets from character",
      tooltip = "This will not delete your current presets if the option below isn't enabled, only add the new pages to the end of the list.",
    },
    purgePresetsBeforeImporting = {
      name = "Purge presets before importing",
      tooltip = "Copy presets from another character without keeping the old ones.",
    },
    importAlphaGear = "|cff0000Import from AlphaGear|r",
    importAlphaGearWarning = "|cff0000WARNING - EXPERIMENTAL FEATURE! - read carefully before pressing this button!|r\n\nThis will delete ALL your existing Dressing Room pages and overwrite ALL your existing Dressing Room presets (and key bindings if you choose the option below). If you have already been using this addon, please backup your saved variables file before using this. All your current Dressing Room data WILL be overwritten.\n\nThis version is compatible with '|cFFAA33AlphaGear 2 %s|r', and it is not guaranteed to work with any other version. Use at your own risk.%s\n\nThis option will also reload your UI automatically.",
    importAlphaGearVersionMismatchWarning = "Your installed version:",
    importAlphaGearNotDetected = "AlphaGear not detected, please enable it in order to use this option",
    importAlphaGearRebindKeys = {
      name = "Rebind keys",
      tooltip = "It is recommended leaving this OFF and manually checking your presets first, before setting it to ON",
    },
  },

  setupWindowText = "Choisir le role préféré pour ce personnage:",
  setupWindowText2 = "Celà pourra t-être changer plus tard dans les options de l'addon.",

  confirmDeletePagePromptOld = "Really delete page?",
  confirmDeletePagePrompt = "Really delete page \"<<1>>\"?",
  editPageNamePrompt = "Enter new name for \"<<1>>\":",

  changesSave = "Confirm Changes",
  changesUndo = "Cancel All Changes",

  barBtnText = "Clic pour charger cette barre de compétences\nMaj + Clic pour sauvegarder\nCtrl + Clic pour effacer",
  gearBtnText = "Clic pour charger l'ensemble\nMaj + Clic pour sauvegarder l'ensemble\nCtrl + Clic pour effacer l'ensemble",
  setBtnText = "Clic pour mettre l'ensemble et charger les deux barres de compétences",

  bttnUndressText = "Undress",
  undressClicked = "Unequipping all gear",

  set = "Set",
  usedBy = "Used by:",

  rechargedWeapon = "Recharged |cff0000%s|r using |c00ff00%s|r",

  waitingForWeaponSwap = "Waiting for bar swap",
  waitingForOutOfCombat = "Waiting for out of combat",
}

