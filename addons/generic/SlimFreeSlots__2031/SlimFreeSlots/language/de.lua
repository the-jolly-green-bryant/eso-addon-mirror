if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language

  local strings = {
    SI_SFS_SETUP_SHOW_INVENTORYBOX = "Inventarbox anzeigen",
    SI_SFS_SETUP_SHOW_ALERTS = "Warnungen bei wenig Platz anzeigen",
    SI_SFS_SETUP_COLORGOOD = "Farbe bei genug freiem Platz",
    SI_SFS_SETUP_COLORGOOD_DESC = "Diese Farbe wird verwendet solange keine Grenze unterschritten ist",
    SI_SFS_SETUP_THRESHOLD1 = "Warn-Grenzen",
    SI_SFS_SETUP_THRESHOLD1_DESC = "Wenn die freien Plätze den Wert unterschreiten, wird die Farbe geändert und es wird eine Warnung ausgegeben",
    SI_SFS_ALERT_FULL = "Inventar voll",
    SI_SFS_ALERT_THRESHOLD_REACHED = "%d oder weniger Inventarplätze frei",
    SI_SFS_FREE_INV = "Freie Slots:",
    SI_SFS_FREE_BANK = "Bank Slots:",
  }
  
  for stringId, stringValue in pairs(strings) do
     ZO_CreateStringId(stringId, stringValue)
     SafeAddVersion(stringId, 1)
  end
  
end