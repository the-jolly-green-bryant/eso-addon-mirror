ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_TOGGLE", "Interface-Menü ein/ausbleden")
for i = 1, 12 do
  ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_SET_"..i, "Set "..i.." benutzen")
end

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
    [WEAPONTYPE_TWO_HANDED_HAMMER] = "Zweihandkolben",
    [WEAPONTYPE_TWO_HANDED_SWORD] = "Zweihandschwert",
  },
  
  skillBarSaved = "Skillset %d Leiste %d gespeichert",
  skillBarLoaded = "Skillset %d Leiste %d geladen",
  skillBarDeleted = "Skillset %d Leiste %d gelöscht",
  gearSetSaved = "Rüstungsset %d gespeichert",
  gearSetLoaded = "Rüstungsset %d geladen",
  gearSetDeleted = "Rüstungsset %d gelöscht",
  noGearSaved = "Fur dieses Set %d ist keine Rüstung gespeichert.",

  options = {
    reloadUIWarning = "UI neuladen erforderlich",
    reloadUI = "UI neuladen",
    clearEmptyGear = {
      name = "Leere Rüstungsslots ablegen",
      tooltip = "Beim Laden eines Rüstungssets werden die unbenutzten Slots abgelegt, anstatt die bisher angezogenen Rüstungsteile weiter zu benutzen.",
    },
    clearEmptySkill = {
      name = "Leere Skillslots räumen",
      tooltip = "Beim Laden einer Skill-Leiste werden die unbenutzten Slots geleert, anstatt die bisher geslotteten Skills weiter zu benutzen",
    },
    activeBarOnly = {
      name = "Skillset-Taste nur für die aktive Leiste anzeigen",
      tooltip = "Zeigt die Skillset-Taste nur für die aktive Skill-Leiste",
    },
    fontSize = {
      name = "Schriftgrösse",
      tooltip = "Schriftgrösse der Oberfläche",
    },
    btnSize = {
      name = "Grösse der Skill-Icons",
      tooltip = "Grösse der Skillsymbole in der Oberfläche",
    },
    columnMajorOrder = {
      name = "Die Sets nach der ersten Spalte sortieren",
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
      tooltip = "Beim Laden, Speichern oder Löschen einer Skillleiste oder eines Rüstungssets wird eine Nachricht ins Chat-Fensters gesendet",
    },
    singleBarToCurrent = {
      name = "Einzelne Skillleiste als aktiv laden",
      tooltip = "Laden eines Sets ohne Rüstungsteile mit einer einzigen gespeicherten Skilleiste wird nur die gespeicherte Skilleiste laden und die leere Skillleiste ignorieren",
    },
    alwaysChangePageOnZoneChanged = {
      name = "Always change page on zone change",
      tooltip = "If there is no preset with the name of the new zone that you arrived in, load the default (first) page",
    },
  },
  
  barBtnText = "Klick : Skillleiste laden\nShift + Click : Skillleiste speichern\nCtrl + Click : Skillleiste löschen",
  gearBtnText = "Klick : Rüstungsset anziehen\nShift + Click : Rüstungsset speichern\nCtrl + Click : Rüstungsset löschen",
  setBtnText = "Klick : Rüstungsset und beide Skillleisten laden",
}

