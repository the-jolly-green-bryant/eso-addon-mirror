-- Translated by: @ninibini

local Register = LibCombatAlerts.RegisterString

Register("SI_CA_MODULE_LOAD"                    , "Modul [<<1>>] geladen.")
Register("SI_CA_MODULE_UNLOAD"                  , "Modul [<<1>>] entladen.")
Register("SI_CA_CORRUPTED"                      , "|cFF0000FEHLER:|r Deine Combat Alerts Installation scheint beschädigt zu sein, wahrscheinlich aufgrund eines fehlerhaften Minion-Updates. |cFF0000Bitte das Addon löschen und neu installieren.|r")

Register("SI_CA_PURGEABLE_EFFECTS"              , "Reinigbare Effekte")
Register("SI_CA_NEARBY"                         , "Spieler in der Nähe")
Register("SI_CA_NEARBY_EMPTY"                   , "Keine Spieler")

Register("SI_CA_SETTINGS_SUPPRESS"              , "Lademeldungen der Module unterdrücken")
Register("SI_CA_SETTINGS_DISABLE_ANNOYING"      , "Nervige Grundspiel-Meldungen deaktivieren")
Register("SI_CA_SETTINGS_BYPASS_PURGE_CHECK"    , "Reinigbare Effekte immer verfolgen")
Register("SI_CA_SETTINGS_BYPASS_PURGE_CHECK_TT" , "Standardmäßig wird das gruppenweite Verfolgen von reinigbaren Effekten deaktiviert, wenn der Spieler keine AoE-Reinigungsfähigkeit ausgerüstet hat; das Aktivieren dieser Option umgeht diese Anforderung.")
Register("SI_CA_SETTINGS_NEARBY"                , "Spieler in der Nähe anzeigen")

Register("SI_CA_SETTINGS_MODULES"               , "Module")
Register("SI_CA_SETTINGS_MODULE_INFO"           , "Zonen: <<1>>\nAutor: <<2>>")
Register("SI_CA_SETTINGS_MODULE_ABILITY"        , "Meldung für <<1>> anzeigen")
Register("SI_CA_SETTINGS_MODULE_ABILITY_NEARBY" , "Meldung für nahegelegenen <<1>> anzeigen")
Register("SI_CA_SETTINGS_MODULE_RAID_LEAD"      , "Raidleitungsmodus aktivieren")
Register("SI_CA_SETTINGS_MODULE_RAID_LEAD_TT"   , "Normalerweise sind einige Meldungen nur für bestimmte relevante Spieler sichtbar. Dies geschieht, um die Ablenkung durch irrelevante Meldungen zu reduzieren.\n\nWenn dieser Modus aktiviert ist, werden diese Einschränkungen umgangen. Dies soll dabei helfen, anderen Spielern Anweisungen zu geben.")

Register("SI_CA_SETTINGS_REPOSITION"            , "UI-Elemente neu positionieren")
Register("SI_CA_SETTINGS_MOVE_ELEMENTS"         , "Elemente neu positionieren")
Register("SI_CA_SETTINGS_MOVE_ELEMENTS_TT"      , "Eine Reihe von UI-Elementen können jederzeit mit der Maus bewegt werden, ohne das Einstellungsmenü zu verwenden. Die meisten UI-Elemente sind jedoch außerhalb des Kampfes ausgeblendet, und diese Option ermöglicht es Ihnen, UI-Elemente außerhalb des Kampfes neu zu positionieren.")
Register("SI_CA_SETTINGS_RESET_ELEMENTS"        , "Alle Elemente zurücksetzen")

Register("SI_CA_MOVE_STATUS"                    , "Statusanzeige")
Register("SI_CA_MOVE_GROUP_PANEL"               , "Gruppenanzeige")
Register("SI_CA_MOVE_NEARBY"                    , "In der Nähe")

Register("SI_CA_LEGACY_HOF"                     , "Das Addon „Halls of Fabrication Status Panel“ wurde eingestellt und sollte deinstalliert werden; seine Funktionen wurden in dieses Addon integriert.")
