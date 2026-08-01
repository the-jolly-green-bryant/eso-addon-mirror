ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_TOGGLE", "Interface-Menü ein/ausblenden")
for i = 1, 24 do
  ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_SET_"..i, "Set "..i.." benutzen")
end
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_UNDRESS", "Komplette Ausrüstung ablegen")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_PAGE_SELECT_PREVIOUS", "Vorherige Seite auswählen")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_PAGE_SELECT_NEXT", "Nächste Seite auswählen")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_CANCEL_PENDING_LOAD", "Ausstehende Warteschlange abbrechen")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_TOGGLE_GROUP_ROLE", "Gruppenrolle umschalten")

DressingRoom._msg = {
  weaponType = {
    [WEAPONTYPE_AXE] = "Axt",
    [WEAPONTYPE_BOW] = "Bogen",
    [WEAPONTYPE_DAGGER] = "Dolch",
    [WEAPONTYPE_FIRE_STAFF] = "Flammenstab",
    [WEAPONTYPE_FROST_STAFF] = "Froststab",
    [WEAPONTYPE_HAMMER] = "Hammer",
    [WEAPONTYPE_HEALING_STAFF] = "Heilungsstab",
    [WEAPONTYPE_LIGHTNING_STAFF] = "Blitzstab",
    [WEAPONTYPE_NONE] = "Keine",
    [WEAPONTYPE_RUNE] = "Rune",
    [WEAPONTYPE_SHIELD] = "Schild",
    [WEAPONTYPE_SWORD] = "Schwert",
    [WEAPONTYPE_TWO_HANDED_AXE] = "Zweihandaxt",
    [WEAPONTYPE_TWO_HANDED_HAMMER] = "Streitkolben",
    [WEAPONTYPE_TWO_HANDED_SWORD] = "Bidenhänder",
  },
  
  loadingSet = "Lade Set %s...",
  skillBarSaved = "Skillset %d Leiste %d gespeichert",
  skillBarLoaded = "Skillset %d Leiste %d geladen",
  skillBarDeleted = "Skillset %d Leiste %d gelöscht",
  gearSetSaved = "Rüstungsset %d gespeichert",
  gearSetLoaded = "Rüstungsset %d geladen",
  gearSetDeleted = "Rüstungsset %d gelöscht",
  noGearSaved = "Fur dieses Set %d ist keine Rüstung gespeichert.",

  options = {
    reloadUIWarning = "UI neuladen erforderlich",
    autoReloadUIWarning = "Diese Option wird die UI automatisch neu laden",
    reloadUI = "UI neuladen",
    accountWideSettings = {
      name = "Accountweite Einstellungen",
      tooltip = "Nutze die selben Einstellungen für jeden Charakter\nÄnderungen werden keinen Einfluss auf gespeicherte Sets haben",
    },
    sectionBehaviour = "Verhaltenseinstellungen",
    autoRechargeWeapons = {
      name = "Automatische Waffenladung",
      tooltip = "Wenn die Waffenverzauberung aufgebraucht ist wird automatisch ein Seelenstein zur Aufladung benutzt.",
    },
    clearEmptyGear = {
      name = "Leere Rüstungsslots ablegen",
      tooltip = "Beim Laden eines Rüstungssets werden die unbenutzten Slots abgelegt, anstatt die bisher angezogenen Rüstungsteile weiter zu benutzen.",
    },
    clearEmptyPoisons = {
      name = "Leere Gifte ablegen",
      tooltip = "Beim Laden eines Rüstungssets mit Waffen werden die unbenutzten Gifte abgelegt, anstatt die bisher ausgerüsteten Gifte weiter zu benutzen.",
    },
    clearEmptySkill = {
      name = "Leere Skillslots räumen",
      tooltip = "Beim Laden einer Skill-Leiste werden die unbenutzten Slots geleert, anstatt die bisher geslotteten Skills weiter zu benutzen",
    },
    ignoreAppearanceSlot = {
      name = "Ignoriere Verkleidungsslot",
      tooltip = "Ziehe keine Verkleidungen oder Wappenröcke an oder aus.",
    },
    enableOutfits = {
      name = "Save/load outfits",
      tooltip = "Save and load the active outfit with gear presets",
    },
    disableInCombat = {
      name = "im Kampf deaktivieren",
      tooltip = "Deaktivieren des Ladens von Fertigkeiten/Sets während des Kampfes, anstatt die Aktion am ende des Kampfes auszführen",
    },
    sectionUI = "UI Einstellungen",
    showNotificationArea = {
      name = "Benachrichtigungsbereich anzeigen",
      tooltip = "Zeigt den Benachrichtigungsbereich und den Namen des aktuell geladenen Sets an.",
    },
    lockNotificationArea = {
      name = "Benachrichtigungsbereich sperren",
      tooltip = "Sperrt die Position des Benachrichtigungsbereiches",
    },
    activeBarOnly = {
      name = "Skillset-Taste nur für die aktive Leiste anzeigen",
      tooltip = "Zeigt die Skillset-Taste nur für die aktive Skill-Leiste",
    },
    lockWindowPosition = {
      name = "Sperrt Fensterposition",
      tooltip = "Sperrt die Fensterposition um nicht verrückt werden zu können",
    },
    fontSize = {
      name = "Schriftgrösse",
      tooltip = "Schriftgrösse der Oberfläche",
    },
    btnSize = {
      name = "Grösse der Skill-Icons",
      tooltip = "Grösse der Skillsymbole auf der Oberfläche",
    },
    columnMajorOrder = {
      name = "Die Sets in der ersten Spalte sortieren",
      tooltip = "Spalten anstelle von Zeilen zur Sortierung der Sets benutzen",
    },
    openWithSkillsWindow = {
      name = "Oberfläche mit Skills automatisch einblenden",
      tooltip = "Bei der Aktivierung des Skill-Fensters DressingRoom automatisch öffnen",
    },
    openWithInventoryWindow = {
      name = "Oberfläche automatisch mit Inventar einblenden",
      tooltip = "Bei der Aktivierung des Inventars DressingRoom automatisch öffnen",
    },
    numRows = {
      name = "Anzahl der Reihen",
      tooltip = "Anzahl der Sets in jeder Spalte der Oberfläche.",
    },
    numCols = {
      name = "Anzahl der Spalten",
      tooltip = "Anzahl der Sets in jeder Reihe der Oberfläche.",
    },
    showChatMessages = {
      name = "Nachricht im Chat",
      tooltip = "Beim Laden, Speichern oder Löschen einer Skillleiste oder eines Rüstungssets wird eine Nachricht im Chat-Fenster gesendet",
    },
    singleBarToCurrent = {
      name = "Einzelne Skillleiste als aktiv laden",
      tooltip = "Laden eines Sets ohne Rüstungsteile mit einer einzigen gespeicherten Skilleiste wird nur die gespeicherte Skilleiste laden und die leere Skillleiste ignorieren",
    },
    autoCloseOnMovement = {
      name = "Bei Bewegung automatisch schliessen",
      tooltip = "Schliesst DressingRoom automatisch wenn man sich bewegt",
    },
    enablePages = {
      name = "Seite aktivieren",
      tooltip = "Die Deaktivierung wird deine bestehenden Seiten nicht löschen, sie werden lediglich versteckt bis diese Option wieder aktiviert wird.",
    },
    confirmPageDelete = {
      name = "Bestätigen Sie das Löschen der Seite",
      tooltip = "Sicherheitsbestätigung beim Löschen einer bestehenden Seite.",
    },
    alwaysChangePageOnZoneChanged = {
      name = "Bei jedem Zonenwechsel Seite laden",
      tooltip = "Sollte kein Preset nach der neuen Zone benannt sein wird die erste Seite geladen.",
    },
    useOldUI = {
      name = "Alte UI nutzen",
      tooltip = "Ursprüngliche Oberflache wird verwendet",
    },
    roleSpecificPresets = {
      name = "Rollenspezifische Seiten aktivieren",
      tooltip = "Zeige separate alternative Seiten für jede Gruppenrolle.",
    },
    roleFromLFGTool = {
      name = "Rolle automatisch per LFG-Tool auswählen",
      tooltip = "Die Seite wird automatisch an die gewählte Rolle im LFG-Tool angepasst.",
    },
    autoSaveChangesOnClose = {
      name = "Auto save changes on window close",
      tooltip = "Automatically save all your changes when you close the Dressing Room window.\n|cff8000Note that you always need to reload UI or log out to save data to disk.|r",
    },
    expertFeatures = "Expertenfunktionen",
    enableExpertFeatures = {
      name = "Aktiviert Expertenfunktionen",
      tooltip = "Ich habe alle Warnungen gelesen und eine Sicherungskopie meiner Dressing Room SavedVariables erstellt",
    },
    changeDefaultRole = {
      name = "Ändert die Standardrolle",
      tooltip = "Dies kann verwendet werden wenn eine falsche Standardrolle ausgewählt wurde."
    },
    exchangePages = {
      name = "Tauscht die Seiten",
      tooltip = "Dadurch werden alle \"%s\" Presets mit der ausgewählten getauscht."
    },
    purgeCharacterData = {
      name = "|cff0000Charakterdaten löschen|r",
      tooltip = "Löscht alle Seiten und Einstellugen für diesen Charakter\n\nTastenbelegungen sind davon nicht betroffen",
    },
    importPresetsFromCharacter = {
      name = "Import presets from character",
      tooltip = "This will not delete your current presets if the option below isn't enabled, only add the new pages to the end of the list.",
    },
    purgePresetsBeforeImporting = {
      name = "Purge presets before importing",
      tooltip = "Copy presets from another character without keeping the old ones.",
    },
    importAlphaGear = "|cff0000Import von AlphaGear|r",
    importAlphaGearWarning = "|cff0000WARNUNG - EXPERIMENTELLE OPTION! - sorgfältig lesen vor Drücken dieser Taste!|r\n\nDies wird alle existierenden DressingRoom Seiten und Presets löschen (und Tastenbelegungen falls Option ausgewählt). Wenn Sie dieses Addon bereits verwendet haben, sichern Sie bitte Ihre Daten, bevor Sie diese Otion nutzen. Alle aktuellen Dressing Room Daten werden überschrieben.\n\nDiese Version ist kompatibel mit'|cFFAA33AlphaGear 2 %s|r', und es wird nicht garantiert, dass es mit einer anderen Version funktioniert. Nutzung auf eigenes Risiko.%s\n\nDiese Option wird das UI automatisch neu laden.",
    importAlphaGearVersionMismatchWarning = "Installierte Version:",
    importAlphaGearNotDetected = "AlphaGear nicht gefunden, bitte aktivieren Sie es um diese Option zu nutzen",
    importAlphaGearRebindKeys = {
      name = "Tasten neu belegen",
      tooltip = "Es wird empfohlen, diese Option deaktiviert zu lassen und Ihre Voreinstellungen zuerst manuell zu überprüfen, bevor Sie sie auf EIN setzen",
    },
  },

  setupWindowText = "Wählen sie die bevorzugte Rolle für den Charakter:",
  setupWindowText2 = "Dies kann später in den Add-On Einstellungen geändert werden.",

  confirmDeletePagePromptOld = "Seite wirklich löschen?",
  confirmDeletePagePrompt = "Seite wirklich löschen \"<<1>>\"?",
  editPageNamePrompt = "Neuen Namen eingeben für \"<<1>>\":",

  changesSave = "Confirm Changes",
  changesUndo = "Cancel All Changes",

  barBtnText = "Klick : Skillleiste laden\nShift + Click : Skillleiste speichern\nCtrl + Click : Skillleiste löschen",
  gearBtnText = "Klick : Rüstungsset anziehen\nShift + Click : Rüstungsset speichern\nCtrl + Click : Rüstungsset löschen",
  setBtnText = "Klick : Rüstungsset und beide Skillleisten laden",

  bttnUndressText = "Ausziehen",
  undressClicked = "Komplette Ausrüstung ablegen",

  set = "Setzen",
  usedBy = "Genutzt von:",

  rechargedWeapon = "Aufgeladen |cff0000%s|r nutzt |c00ff00%s|r",

  waitingForWeaponSwap = "Auf Leistenwechsel warten",
  waitingForOutOfCombat = "Auf Kampfende Warten",
}

