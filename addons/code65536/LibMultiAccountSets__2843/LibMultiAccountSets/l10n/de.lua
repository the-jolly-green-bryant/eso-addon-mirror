-- Translated by: @ninibini

local Register = LibCodesCommonCode.RegisterString

Register("SI_LMAS_SCAN_STATUS"             , "%d / %d gesammelt (+%d neu)")

Register("SI_LMAS_SETTINGS_CHATCOMMAND"    , "Die Addon Einstellungen können über den |c00CCFF/lmas|r Chat Befehl aufgerufen werden.")

Register("SI_LMAS_SETTINGS_CHAT_SECTION"   , "Chat Benachrichtigungen")
Register("SI_LMAS_SETTINGS_CHAT_UPDATES"   , "Aktualisierungen in der Gegenstandsset-Sammlung")

Register("SI_LMAS_SETTINGS_SHARE_SECTION"  , "Accountdaten teilen")
Register("SI_LMAS_SETTINGS_SHARE_CAPTION"  , "Exportieren/kopieren, oder einfügen/importieren, um Daten auszutauschen")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTC"  , "Akt. Account exportieren")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTCT" , "Set Gegenstandssammlung des aktuellen Accounts exportieren")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTA"  , "Alles exportieren")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTAT" , "Set Gegenstandssammlung aller gespeicherten Accounts exportieren")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTS"  , "Ausgewählte exportieren (%d)")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTST" , "Set Gegenstandssammlung der unten eingetragenen Accounts exportieren")
Register("SI_LMAS_SETTINGS_SHARE_IMPORT"   , "Importieren")
Register("SI_LMAS_SETTINGS_SHARE_CLEAR"    , "Löschen")
Register("SI_LMAS_SETTINGS_SHARE_SELECT"   , "Für Export ausgewählte Accounts")
Register("SI_LMAS_SETTINGS_SHARE_SELECTT"  , "Kommagetrennte Liste von Accounts, für „Ausgewählte exportieren“")

Register("SI_LMAS_SETTINGS_DELETE_SECTION" , "Account Daten löschen")
Register("SI_LMAS_SETTINGS_DELETE_BUTTON"  , "Löschen")
Register("SI_LMAS_SETTINGS_DELETE_WARNING" , "Löscht alle Daten über gesammelte Sets für alle Accounts und lädt die UI neu.")

Register("SI_LMAS_SETTINGS_NOSAVE_SECTION" , "Ignorierte Accounts")
Register("SI_LMAS_SETTINGS_NOSAVE_CAPTION" , "Kommagetrennte Liste von Accounts, die beim Speichern ignoriert werden")

Register("SI_LMAS_SHARE_EXPORT_LIMIT"      , "[<<1>>/<<2>>] übersprungen; Datenlimit erreicht.")
Register("SI_LMAS_SHARE_IMPORT_STALE"      , "[<<1>>/<<2>>] übersprungen; aktuellere Daten vorhanden.")
Register("SI_LMAS_SHARE_IMPORT_DONE"       , "[<<1>>/<<2>>] importiert. (<<3>>)")
Register("SI_LMAS_SHARE_IMPORT_INVALID"    , "Import wegen korrupter bzw. unvollständige Daten abgebrochen.")
Register("SI_LMAS_SHARE_IMPORT_BADVERSION" , "Die importierten Daten wurden von einer nicht kompatiblen Version von LibMultiAccountSets erstellt. Bitte stellt sicher, dass beide Benutzer die aktuellste Version von LibMultiAccountSets verwenden.")
Register("SI_LMAS_SHARE_IMPORT_NEWACCOUNT" , "Es wurden einer oder mehrere noch nicht vorhandene Accounts importiert; |c00CCFF/reloadui|r ausführen, damit die neu importierten Accounts in Menüs und Einstellungen angezeigt werden.")
Register("SI_LMAS_SHARE_IMPORT_TALLY"      , "<<1>> Accounts importiert.")
