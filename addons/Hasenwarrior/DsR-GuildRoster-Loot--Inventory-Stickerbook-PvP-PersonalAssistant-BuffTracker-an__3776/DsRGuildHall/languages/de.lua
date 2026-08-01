local DsRIcon = DsRglobals:HolidayIconLoad()

-- German

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Quality
DsR_Quality_NONE       = "- Inaktiv -"
DsR_Quality_NORMAL     = "1 - Normal"
DsR_Quality_FINE       = "2 - |c00FF00Erlesen|r"
DsR_Quality_SUPERIOR   = "3 - |c259EFAÜberragend|r"
DsR_Quality_EPIC       = "4 - |c8525FAEpisch|r"
DsR_Quality_LEGENDARY  = "5 - |cF7C42ALegendär|r"
DsR_Quality_MYTHIC     = "6 - |cFFA500Mystisch|r"

-- RavenBar
DsR_Bar_TurnOff        = "Ausschalten"
DsR_Bar_TurnOn         = "Anzeigen"
DsR_Bar_PosTOP         = "Oben"
DsR_Bar_PosBOTTOM      = "Unten"
DsR_Bar_Inventory      = "Inventar"
DsR_Bar_Bank           = "Bank"
DsR_Bar_InventoryBank  = "Inventar/Bank"
DsR_Bar_SoulGemsEmpty  = "Leere"
DsR_Bar_SoulGems       = "Gefüllt"
DsR_Bar_SoulGemsboth   = "Leere/Gefüllte"
DsR_Bar_BankUse        = "Belegt"
DsR_Bar_BankMax        = "Gesamt"
DsR_Bar_BankUseMax     = "Belegt/Gesamt"

-- Chat
DsR_Chat_SAY     = "Sagen"
DsR_Chat_ZONE    = "Zone"
DsR_Chat_PARTY   = "Gruppe"
DsR_Chat_G1      = "Gilde 1"
DsR_Chat_G2      = "Gilde 2"
DsR_Chat_G3      = "Gilde 3"
DsR_Chat_G4      = "Gilde 4"
DsR_Chat_G5      = "Gilde 5"

-- IconText position
DsR_IconTextout   = "Aus"
DsR_IconTextright = "Rechts"
DsR_IconTextleft  = "Links"
DsR_IconTextup    = "Oben"
DsR_IconTextdown  = "Unten"

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Donation
ZO_CreateStringId("DsRGuild_donationMailSubject"             , "Spende für DsR GuildRoster")
ZO_CreateStringId("DsRGuild_donationMailTxT"                 , "Ich liebe dein Gilden-Addon, darum eine Spende für Dich und der Gilde 'Die sieben Raben', für die Arbeit am Addon\n Vielen Dank und weiter so.\n\nLG\n<<1>>")
ZO_CreateStringId("DsRGuild_donationSmall"                   , zo_iconFormat("/esoui/art/icons/housing_sum_inc_altcup001.dds", 26, 26) .. "|c9fb6cdKlein|r")
ZO_CreateStringId("DsRGuild_donationMiddle"                  , zo_iconFormat("/esoui/art/icons/housing_sum_inc_altcup003.dds", 26, 26) .. "|c9fb6cdMittel|r")
ZO_CreateStringId("DsRGuild_donationNormal"                  , zo_iconFormat("/esoui/art/icons/housing_sum_inc_altcup003.dds", 26, 26) .. "|c9fb6cdNormal|r")
ZO_CreateStringId("DsRGuild_donationBig"                     , zo_iconFormat("/esoui/art/icons/housing_sum_inc_altcup006.dds", 26, 26) .. "|c9fb6cdAngemessen|r")
ZO_CreateStringId("DsRGuild_donationTxt"                     , "|c80dfffÜber eine Spende für mich und der Gilde 'Die sieben Raben' würde ich mich freuen|r :-)")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- SLASH COMMANDS
ZO_CreateStringId("DsRGuildcmd_addonupdate"                  , "Öffne das Popup-Fenster 'Addon-Update News'")
ZO_CreateStringId("DsRGuildcmd_settings"                     , "Öffne das Einstellungsmenü")
ZO_CreateStringId("DsRGuildcmd_inventory"                    , "Öffne den InventoryManager")
ZO_CreateStringId("DsRGuildcmd_buff"                         , "Öffne die Buffverwaltung")
ZO_CreateStringId("DsRGuildcmd_binding"                      , "Binde alle Set-Gegenstände")
ZO_CreateStringId("DsRGuildcmd_post"                         , "Poste alle Set-Gegenstände")
ZO_CreateStringId("DsRGuildcmd_port"                         , "Porte zurück in die Mainbase")
ZO_CreateStringId("DsRGuildcmd_death"                        , "'Tabelle des Todes' - Optionen")
ZO_CreateStringId("DsRGuildcmd_deathwindow"                  , "Öffne die 'Tabelle des Todes'")
ZO_CreateStringId("DsRGuildcmd_deathreset"                   , "Setze die 'Tabelle des Todes' zurück")
ZO_CreateStringId("DsRGuildcmd_deathpost"                    , "Poste die aktuellen Tode im Chat")
ZO_CreateStringId("DsRGuildcmd_repair"                       , "Repariere deine komplette Rüstung")
ZO_CreateStringId("DsRGuildcmd_recharge"                     , "Lade deine Waffen wieder auf")
ZO_CreateStringId("DsRGuildcmd_repairandrecharge"            , "Repariere Rüstung und lade Waffen wieder auf")
ZO_CreateStringId("DsRGuildcmd_Companion"                    , "|c9fb6cdDsR GuildRoster - Gefährten|r")
ZO_CreateStringId("DsRGuildcmd_Assistant"                    , "|c9fb6cdDsR GuildRoster - Gehilfen|r")
ZO_CreateStringId("DsRGuildcmd_General"                      , "|c9fb6cdDsR GuildRoster - Allgemein|r")
ZO_CreateStringId("DsRGuildcmd_GroupAttack"                  , "Startet die Gruppenattacke")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- General
ZO_CreateStringId("DsR_Guild"                                , "GILDENHAUS")
ZO_CreateStringId("DsR_Hall"                                 , "Gildenhaus")
ZO_CreateStringId("DsR_Leaders"                              , zo_iconFormat("/DsRGuildHall/misc/DsR_RabenwachtFLO.dds", 26, 26) .. "Gildenleitung" .. zo_iconFormat("/DsRGuildHall/misc/DsR_RabenwachtFLO.dds", 26, 26))
ZO_CreateStringId("DsR_HallMem"                              , "eigenes Haupthaus")
ZO_CreateStringId("DsR_Post"                                 , "Gildenmail")
ZO_CreateStringId("DsR_Event"                                , "Anstehende Gildenevent's")
ZO_CreateStringId("DsR_Aldmeri"                              , "Aldmeri-Dominion")
ZO_CreateStringId("DsR_Ebonheart"                            , "Ebenerz-Pakt")
ZO_CreateStringId("DsR_Daggerfall"                           , "Dolchsturz-Bündnis")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Holiday center message
ZO_CreateStringId("DsR_valentinTXT"                          , "wünschen Dir einen schönen")
ZO_CreateStringId("DsR_valentinEvent"                        , "VALENTINSTAG")
ZO_CreateStringId("DsR_esterTXT"                             , "wünschen Dir und Deiner Familie")
ZO_CreateStringId("DsR_esterEvent"                           , "FROHE OSTERN")
ZO_CreateStringId("DsR_halloweenTXT"                         , "wünschen Dir ein grausames")
ZO_CreateStringId("DsR_halloweenEvent"                       , "HALLOWEEN")
ZO_CreateStringId("DsR_xmasTXT"                              , "wünschen Dir und Deiner Familie")
ZO_CreateStringId("DsR_xmasEvent"                            , "FROHE WEIHNACHTEN")
ZO_CreateStringId("DsR_newyearTXT"                           , "wünschen Dir und Deiner Familie ein gesundes und frohes")
ZO_CreateStringId("DsR_newyearEvent"                         , "NEUES JAHR")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Locations
ZO_CreateStringId("DsR_HelRa"                                , "Zitadelle von Hel Ra")
ZO_CreateStringId("DsR_AA"                                   , "Ätherisches Archiv")
ZO_CreateStringId("DsR_Sanctum"                              , "Sanctum Ophidia")
ZO_CreateStringId("DsR_Schlund"                              , "Schlund von Lorkhaj")
ZO_CreateStringId("DsR_HoF"                                  , "Hallen der Fertigung")
ZO_CreateStringId("DsR_Anstalt"                              , "Anstalt Sanctorium")
ZO_CreateStringId("DsR_Wolkenruh"                            , "Wolkenruh")
ZO_CreateStringId("DsR_Sonnenspitz"                          , "Sonnspitz")
ZO_CreateStringId("DsR_Kynes"                                , "Kynes Ägis")
ZO_CreateStringId("DsR_Fels"                                 , "Felshain")
ZO_CreateStringId("DsR_Grauensegel"                          , "Grauenssegelriff")
ZO_CreateStringId("DsR_Wahnsinn"                             , "Rand des Wahnsinns")
ZO_CreateStringId("DsR_Luminit"                              , "Luminit-Zitadelle")
ZO_CreateStringId("DsR_Gebein"                               , "Gebeinkäfig")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- days
ZO_CreateStringId("DsR_Mo"                                   , "Montag")
ZO_CreateStringId("DsR_Di"                                   , "Dienstag")
ZO_CreateStringId("DsR_Mi"                                   , "Mittwoch")
ZO_CreateStringId("DsR_Do"                                   , "Donnerstag")
ZO_CreateStringId("DsR_Fr"                                   , "Freitag")
ZO_CreateStringId("DsR_Sa"                                   , "Samstag")
ZO_CreateStringId("DsR_So"                                   , "Sonntag")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Guildmail
ZO_CreateStringId("DsR_TITLE_COMPOSE"                        , "Komponieren")
ZO_CreateStringId("DsR_TITLE_RECIPIENTS"                     , "Empfänger")
ZO_CreateStringId("SI_COMPOSE_BUTTON_SEND"                   , "Senden")
ZO_CreateStringId("SI_COMPOSE_BUTTON_CANCEL"                 , "Stornieren")
ZO_CreateStringId("SI_COMPOSE_BUTTON_PAUSE"                  , "Pause")
ZO_CreateStringId("SI_COMPOSE_BUTTON_CONTINUE"               , "Fortsetzen")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- DsR-AutoInvite
ZO_CreateStringId("SI_DsRAI"                                 , "|c9fb6cdDsR-AutoInvite|r")
ZO_CreateStringId("SI_DsRAI_NO_GROUP_MESSAGE"                , "Gruppe ist leer")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_ON_OFF"                , "Encounterlog Status")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_ON_OFF_TP"             , "Als Gruppenleiter ein Hinweis auf Logstatus auf dem Bildschirm anzeigen?\n(Wird nur angezeigt, wenn Du Dich im Raid befindest)")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_START"                 , "Encounterlog Starten")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_START_TP"              , "Soll ich Dich Fragen, ob 'Encounterlog' gestartet werden soll, sobal Du den Raid beitritts?")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_LOG"                   , "Aufzeichnung für den Raid gestartet")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_LOG_STOP"              , "Aufzeichnung für den Raid gestoppt")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_DIALOG"                , "Aufzeichnung für den Raid starten?")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_DIALOG_STOP"           , "Aufzeichnung für den Raid stoppen?")
ZO_CreateStringId("SI_DsRAI_SEND_TO_USER"                    , " |c9fb6cd[DsR-AI]|r |c32CD32Schicke Einladung an|r |c01A5C6<<1>>|r")
ZO_CreateStringId("SI_DsRAI_USER_LEAVE"                      , " |c9fb6cd[DsR-AI]|r |c01A5C6<<1>>|r |cEE0000hat die Gruppe verlassen|r")
ZO_CreateStringId("SI_DsRAI_KICK"                            , " |c9fb6cd[DsR-AI]|r |cEE0000Kicke|r |c01A5C6<<1>>|r (Offline für <<2>>)")
ZO_CreateStringId("SI_DsRAI_GROUP_OPEN_RESTART"              , " |c9fb6cd[DsR-AI]|r Wieder Platz in der Gruppe.")
ZO_CreateStringId("SI_DsRAI_START_ON"                        , " |c9fb6cd[DsR-AI]|r horcht auf den Text >> |cFF4242<<1>>|r <<")
ZO_CreateStringId("SI_DsRAI_STOP"                            , "Stoppe |c9fb6cdDsR-AI|r")
ZO_CreateStringId("SI_DsRAI_GROUP_FULL_STOP"                 , " |c9fb6cd[DsR-AI]|r Gruppe voll. |c9fb6cdDsR-AI|r deaktiviert.")
ZO_CreateStringId("SI_DsRAI_OFF"                             , " |c9fb6cd[DsR-AI]|r |cEE0000deaktiviert|r")
ZO_CreateStringId("SI_DsRAI_ERROR_ACCOUNT"                   , " |c9fb6cd[DsR-AI]|r Kann den Spieler |c01A5C6<<1>>|r nicht finden. Bitte manuell einladen.")
ZO_CreateStringId("SI_DsRAI_ERROR_ZONE"                      , " |c9fb6cd[DsR-AI]|r Der Spieler |c01A5C6<<1>>|r ist nicht in Cyrodiil, sondern in <<2>>")
ZO_CreateStringId("SI_DsRAI_INV_BLOCK"                       , " |c9fb6cd[DsR-AI]|r Blocke Einladung um Abstürze zu vermeiden.")
ZO_CreateStringId("SI_DsRAI_ERROR_INVITE"                    , " |c9fb6cd[DsR-AI]|r Fehler - Konnte in folgendem Channel nicht inviten:")
ZO_CreateStringId("SI_DsRAI_ERROR_KICK_TABLE"                , " |c9fb6cd[DsR-AI]|r Kein Spieler in der Gruppe mit dem Namen |c01A5C6<<1>>|r gefunden. Bitte manuell kicken.")
ZO_CreateStringId("SI_DsRAI_OPT_ENABLED"                     , "Aktiviert")
ZO_CreateStringId("SI_DsRAI_TT_ENABLED"                      , "AutoInvite aktivieren oder nicht")
ZO_CreateStringId("SI_DsRAI_OPT_STRING"                      , "Invite Text")
ZO_CreateStringId("SI_DsRAI_TT_STRING"                       , "Der Text, auf welchen Autoinvite horcht.\nUm auf mehrere Worte zu achten, diese mit einem |cFF4242;|r getrennt eintragen,\nz.B. Rabe|cFF4242;|rRaven|cFF4242;|rLFG")
ZO_CreateStringId("SI_DsRAI_OPT_MAX_SIZE"                    , "Max. Gruppengröße")
ZO_CreateStringId("SI_DsRAI_TT_MAX_SIZE"                     , "Maximale Anzahl an Spieler die in die Gruppe eingeladen werden")
ZO_CreateStringId("SI_DsRAI_OPT_RESTART"                     , "Neustart")
ZO_CreateStringId("SI_DsRAI_TT_RESTART"                      , "Startet AutoInvite neu, wenn die Gruppe nicht voll ist")
ZO_CreateStringId("SI_DsRAI_OPT_CYRCHECK"                    , "Cyrodiil Check")
ZO_CreateStringId("SI_DsRAI_TT_CYRCHECK"                     , "Nur Spieler einladen, die auch in Cyrodiil sind.\n(Diese Bedingung ist tritt nur ein, wenn du selbst ebenfalls in Cyrodiil bist.)")
ZO_CreateStringId("SI_DsRAI_OPT_KICK"                        , "Auto kick")
ZO_CreateStringId("SI_DsRAI_TT_KICK"                         , "Automatisches Kicken von Spielern welche Offline sind")
ZO_CreateStringId("SI_DsRAI_OPT_KICK_TIME"                   , "Zeit bevor Kick")
ZO_CreateStringId("SI_DsRAI_TT_KICK_TIME"                    , "Anzahl der Sekunden die gewartet werden sollen, bevor Offline Spieler gekickt werden.")
ZO_CreateStringId("SI_DsRAI_BTN_REFRESH"                     , "Liste aktualisieren")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- DsR-Party
ZO_CreateStringId("DsRGuildGroup_GRP_CHAR_LONG"              , "Charaktername")
ZO_CreateStringId("DsRGuildGroup_GRP_ACC_LONG"               , "Username")
ZO_CreateStringId("DsRGuildGroup_GRP_LOCATION_LONG"          , "Ort")
ZO_CreateStringId("DsRGuildGroup_GRP_CLASS_LONG"             , "Klasse")
ZO_CreateStringId("DsRGuildGroup_GRP_LVL"                    , "LVL")
ZO_CreateStringId("DsRGuildGroup_GRP_ROLE_LONG"              , "Rolle")
ZO_CreateStringId("DsRGuildGroup_GRP_LEADER_TT"              , "Anführer")
ZO_CreateStringId("DsRGuildGroup_GRP_AVA_STRING"             , "AvA Rang")
ZO_CreateStringId("DsRGuildGroup_AVGCP"                      , "Durchschnittliche Championpunkte: |cffffff<<1>>|r")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Setting Menue
ZO_CreateStringId("DsRGuildMenue_DsRinternal"                , "Die sieben Raben - Intern")
ZO_CreateStringId("DsRGuildMenue_lootmanager"                , "Lootmanager")
ZO_CreateStringId("DsRGuildMenue_stickerbook"                , "Stickeralbum ")
ZO_CreateStringId("DsRGuildMenue_alliancewar"                , "|ced2431Allianzkrieg|r")
ZO_CreateStringId("DsRGuildMenue_cyrostatus"                 , "Cyrodiil")
ZO_CreateStringId("DsRGuildMenue_GroupRaid"                  , "Gruppe & Raids")
ZO_CreateStringId("DsRGuildMenue_Divers"                     , "Andere nützliche Dinge")
ZO_CreateStringId("DsRGuildMenue_PvPandBG"                   , "PvP & Schlachtfelder")
ZO_CreateStringId("DsRGuildMenue_general"                    , "Allgemein")
ZO_CreateStringId("DsRGuildMenue_cyrodiil"                   , "Cyrodiil ")
ZO_CreateStringId("DsRGuildMenue_ImperialCity"               , "|c7393B3Eingänge & Namen|r")
ZO_CreateStringId("DsRGuildMenue_BuffReminder"               , "Reminder - XP-/AP-Rollen, Essen")
ZO_CreateStringId("DsRGuildMenue_InventoryManager"           , "Inventar Manager")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Informationen
ZO_CreateStringId("DsRGuildMenue_DsRInfoNews"                , "Gilden-Update News anzeigen?")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Friends
ZO_CreateStringId("DsRGuildMenue_DsRFriendsONLINE"           , "|c00ff00<<1>>|r |c9fb6cdhat sich mit -> |r<<2>> |c9fb6cd<- eingeloggt|r")
ZO_CreateStringId("DsRGuildMenue_DsRFriendsOFFLINE"          , "|c00ff00<<1>>|r |cFAA0A0hat sich mit -> |r<<2>> |cFAA0A0<- ausgeloggt|r")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- LootManager
ZO_CreateStringId("DsRGuildLoot_experience"                  , " Erfahrung ")
ZO_CreateStringId("DsRGuildLoot_cAchievementsTxt"            , "Vollendet! ")
ZO_CreateStringId("DsRGuildLoot_pAchievementsTxt"            , "Fortschritt:")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- StickerBook
ZO_CreateStringId("DsRGuildBind_bindunknown"                 , "Binde alle Set-Gegenstände")
ZO_CreateStringId("DsRGuildBind_postunbounted"               , "Poste alle Set-Gegenstände")
ZO_CreateStringId("DsRGuildBind_req_requestPrefixdefault"    , "Kann ich bekommen? -> ")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Buff Analyse
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseDebug"           , "Ability im Chat ausgeben")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseFilterName"      , "Filter nach diesem Name")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseCopyID1"         , "Füge ID ")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseCopyID2"         , " zur Liste '")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseCopyID3"         , "' hinzu")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseFilter"          , "Suchen:")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseFilterAll"       , "Alle")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseFilterClose"     , "Schließen")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseFilterSave"      , "Speichern")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseFilterRefresh"   , "|cFF0000Zurücksetzen|r")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseFound"           , "Anzahl: %s%d|r / |cFFA500%d|r")
ZO_CreateStringId("DsRGuildcmd_BuffSettingButtonWindow"       , "Buff-Management")
ZO_CreateStringId("DsRGuildMenue_BuffsIDAnaly"                , "|c00CDCDDsR Buff-Analyse|r")
ZO_CreateStringId("DsRGuildMenue_BuffsIDAnalySearch"          , "|c00CDCDSuche ID's|r")
ZO_CreateStringId("DsRGuildMenue_BuffsWindowButton"           , "|c00CDCDDsR Buff-Management|r")
ZO_CreateStringId("DsRGuildMenue_BuffsWindowChar"             , "Eingeloggter Char: ")
ZO_CreateStringId("DsRGuildMenue_BuffsWhiteDesc"              , "Die Zahlen müssen immer mit einem |cFFA500KOMMA|r getrennt werden.")
ZO_CreateStringId("DsRGuildMenue_BuffsWhiteDesc1"             , "Die Reihenfolge auf der UI, ist die Reihenfolge in der Liste")
ZO_CreateStringId("DsRGuildMenue_BuffsCheckClean"             , "|cFF0000Prüfe Listen auf doppelte Werte|r")
ZO_CreateStringId("DsRGuildMenue_BuffsSetRole"                , "Mach Dich zum %s")
ZO_CreateStringId("DsRGuildMenue_BuffsShowList"               , "Vorschau")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- PvP
ZO_CreateStringId("DsRGuildPvP_ap_repairtxt"                 , "Reparatur: ")
ZO_CreateStringId("DsRGuildPvP_ap_killstxt"                  , "Kill: ")
ZO_CreateStringId("DsRGuildPvP_ap_defensetxt"                , "Verteidigt: ")
ZO_CreateStringId("DsRGuildPvP_ap_offensetxt"                , "Erobert: ")
ZO_CreateStringId("DsRGuildPvP_ap_revivaltxt"                , "Wiederbelebung: ")
ZO_CreateStringId("DsRGuildPvP_ap_awardstxt"                 , "Auszeichungen: ")
ZO_CreateStringId("DsRGuildPvP_ap_battlegroundtxt"           , "Platzierung: ")
ZO_CreateStringId("DsRGuildPvP_ap_questtxt"                  , "Quest: ")
ZO_CreateStringId("DsRGuildPvP_ap_telvarBankuse"             , "Aktiviere TelVar-Limit im Inventar")
ZO_CreateStringId("DsRGuildPvP_ap_telvarBankuseTP"           , "Wenn aktiviert, gleicht Ihr TelVar-Steine im Inventar aus, wenn Du eine Bank öffnest")
ZO_CreateStringId("DsRGuildPvP_ap_telvarBankinv"             , "Wieviele sollen behalten werden")
ZO_CreateStringId("DsRGuildPvP_ap_telvarBankinvTP"           , "Zu behaltende TelVar-Steine im Inventar beim öffnen einer Bank")
ZO_CreateStringId("DsRGuildPvP_ap_telvarSaverPort"          , " |c9fb6cd[DsR-Port]|r |c35fc38Porte in die Basis zurück|r")
ZO_CreateStringId("DsRGuildPvP_ap_telvarSaverPort1"          , " |c9fb6cd[DsR-CyroPort]|r |c35fc38Warteschlange nach|r |c5C6BFF<<1>>|r |c35fc38betreten!|r")
ZO_CreateStringId("DsRGuildPvP_ap_telvarSaverPort2"          , " |c9fb6cd[DsR-CyroPort]|r |c35fc38Warteschlange nach|r |c5C6BFF%s|r |c35fc38betreten!|r")
ZO_CreateStringId("DsRGuildPvP_ap_telvarSaverPortBreak"      , " |c9fb6cd[DsR-CyroPort]|r |cff0000Du befindest Dich nicht im|r |c5C6BFFPvP-Gebiet|r |cff0000!!!|r")
ZO_CreateStringId("DsRGuildPvP_ap_telvarSaverPortMesHead"    , zo_iconFormat(DsRIcon, 34, 34) .. "|c9fb6cdTelVar Saver|r" .. zo_iconFormat(DsRIcon, 34, 34))
ZO_CreateStringId("DsRGuildPvP_ap_telvarSaverPortMesQuest"   , "Gruppe nach Cyro porten?")
ZO_CreateStringId("DsRGuildPvP_ap_telvarSaverKeybindmsg"     , "Autom. Port nach Cyrodiil")
ZO_CreateStringId("DsRGuildPvP_KillingBlowmsgA"              , "Tödlichen Schlag auf ")
ZO_CreateStringId("DsRGuildPvP_VictimEmperor"                , "Du hast den Kaiser <<1>> getötet")
ZO_CreateStringId("DsRGuildPvP_KillingBlowmsgB"              , " mit ")
ZO_CreateStringId("DsRGuildPvP_KillingChat"                  , "Assist: ")
ZO_CreateStringId("DsRGuildPvP_KillingDeath"                 , "Tode: ")
ZO_CreateStringId("DsRGuildPvP_KillingBlow"                  , "Kills: ")
ZO_CreateStringId("DsRGuildPvP_KillingAP"                    , "AP: ")
ZO_CreateStringId("DsRGuildPvP_KillingTV"                    , "TV: ")
ZO_CreateStringId("DsRGuildPvP_qstate_QUEUEING"              , "|c35fc38Warteschlange für |c5C6BFF%s|r")
ZO_CreateStringId("DsRGuildPvP_qstate_ENTERING"              , "|c35fc38Betrete |c5C6BFF%s|r")
ZO_CreateStringId("DsRGuildPvP_qstate_LEAVING"               , "|c35fc38Warteschlange verlassen für |c5C6BFF%s|r")
ZO_CreateStringId("DsRGuildPvP_qstate_CONFIRMING"            , "|c35fc38Warteschlange bestätigen für |c5C6BFF%s|r")
ZO_CreateStringId("DsRGuildPvP_qstate_WAITING"               , "|c35fc38In Warteschlange für |c5C6BFF%s|r")
ZO_CreateStringId("DsRGuildPvP_qstate_FINISHED"              , "|c35fc38Warteschlange beendet für |c5C6BFF%s|r")
ZO_CreateStringId("DsRGuildPvP_qstate_UNKNOWN"               , "|c35fc38Unbekannter Warteschlangenstatus für |c5C6BFF%s|r")
ZO_CreateStringId("DsRGuildPvP_qstate_UNKNOWN_Q"             , "Unbekannte Warteschlange")
ZO_CreateStringId("DsRGuildPvP_qstate_Q_NUMBER"              , "%d")
ZO_CreateStringId("DsRGuildPvP_qstate_Q_TIME"                , "Zeit in der Warteschlange: %s")
ZO_CreateStringId("DsRGuildPvP_VolendrungInACT"              , " Volendrung inaktiv")
ZO_CreateStringId("DsRGuildPvP_VolendrungACT"                , " Volendrung aktiv, nicht enthüllt!")
ZO_CreateStringId("DsRGuildPvP_VolendrungRELEAVED"           , " Volendrung enthüllt!")
ZO_CreateStringId("DsRGuildPvP_VolendrungDROPPED"            , " Volendrung fallen gelassen!")
ZO_CreateStringId("DsRGuildPvP_GroupInviteZonemsg"           , "Cyro LFM")
ZO_CreateStringId("DsRGuildPvP_telVarSaverNoStoneINV"        , "|cb81414Kein|r %s |cb81414im Inventar vorhanden!!!|r")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- PvP - Boss Timer
ZO_CreateStringId("DsRPvPBossTimer_AMONCRUL"	             , "Amoncrul")
ZO_CreateStringId("DsRPvPBossTimer_THIRSK"		             , "Baron Thirsk")
ZO_CreateStringId("DsRPvPBossTimer_GLORGOLOCH"	             , "Glorgoloch der Zerstörer")
ZO_CreateStringId("DsRPvPBossTimer_CHARR" 		             , "Entflammer Charr")
ZO_CreateStringId("DsRPvPBossTimer_KHROGO"  	             , "König Khrogo")
ZO_CreateStringId("DsRPvPBossTimer_MALYGDA" 	             , "Fürstin Malygda")
ZO_CreateStringId("DsRPvPBossTimer_MAZALUHAD" 	             , "Mazaluhad")
ZO_CreateStringId("DsRPvPBossTimer_NUNATAK" 	             , "Nunatak")
ZO_CreateStringId("DsRPvPBossTimer_MATRON"	 	             , "Die kreischende Matrone")
ZO_CreateStringId("DsRPvPBossTimer_VOLGHASS"	             , "Volghass")
ZO_CreateStringId("DsRPvPBossTimer_YSENDA"	 	             , "Ysenda Strahlenpracht")
ZO_CreateStringId("DsRPvPBossTimer_ZOAL" 		             , "Zoal der Immerwache")
ZO_CreateStringId("DsRPvPBossTimer_MOLAG" 		             , "Das Simulakrum von Molag Bal")
ZO_CreateStringId("DsRPvPBossTimer_CAN"					     , "(0) Kanalisation")
ZO_CreateStringId("DsRPvPBossTimer_MEMORIALDISTRICT"	     , "(1) Gedenkbezirk")
ZO_CreateStringId("DsRPvPBossTimer_ARENADISTRICT"		     , "(2) Arenabezirk")
ZO_CreateStringId("DsRPvPBossTimer_ARBORETUMDISTRICT"	     , "(3) Arboretum")
ZO_CreateStringId("DsRPvPBossTimer_TEMPLEDISTRICT"		     , "(4) Tempelbezirk")
ZO_CreateStringId("DsRPvPBossTimer_NOBLESDISTRICT"		     , "(5) Adelsbezirk")
ZO_CreateStringId("DsRPvPBossTimer_ELVENGARDENSDISTRICT"     , "(6) Elfengartenbezirk")
ZO_CreateStringId("DsRPvPBossTimer_SLASHcmd"				 , "Starte den Timer eines Bezirkes, z.B. /dsrstart 1")
ZO_CreateStringId("DsRPvPBossTimer_Menue"					 , "Kaiserstadt")
ZO_CreateStringId("DsRPvPBossTimer_GUI_WIDTH"				 , "230")
ZO_CreateStringId("DsRPvPBossTimer_StartManu"           	 , "Starte Bosstimer im entsprechenden Bezirk")
ZO_CreateStringId("DsRPvPBossTimer_enabled"                  , "Aktiviert")
ZO_CreateStringId("DsRPvPBossTimer_positionfixed"            , "Position fixiert ")
ZO_CreateStringId("DsRPvPBossTimer_showBGtransparent"        , "Hintergrund transparent?")
ZO_CreateStringId("DsRPvPBossTimer_hideworldmap"             , "Auf Weltkarte unsichtbar")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Beams
ZO_CreateStringId("DsRGuildBeam_LightShowAlertDialog"        , "Das Licht des Zusammenhalts funktionieren nicht ordnungsgemäß mit den aktuellen Videosettings des Spiels\n\n Bitte öffne |cffff33Einstellungen|r > |cffff33Video|r und setzen Sie die |cffff33SubSampling-Qualität|r auf |c33ffffHOCH|r.\n")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Inventory Manager
ZO_CreateStringId("DsRGuildInventory_HeaderWindow"           , zo_iconFormat(DsRIcon, 36, 36) .. "|c9fb6cdDsR - Inventar Manager|r")
ZO_CreateStringId("DsRGuildInventory_Open"                   , "Inventar Manager")
ZO_CreateStringId("DsRGuildInventory_OpenGrab"               , "Inventar Manager (ohne Fokus)")
ZO_CreateStringId("DsRGuildInventory_ShowOnlyDupl"           , "Nur Duplikate anzeigen")
ZO_CreateStringId("DsRGuildInventory_ShowOnlyMarked"         , "Nur markierte Elemente anzeigen")
ZO_CreateStringId("DsRGuildInventory_ShowOnlyMarkedTP"       , "Zeige nur Gegenstände die z.B. gestohlen sind")
ZO_CreateStringId("DsRGuildInventory_RescanCharBank"         , "Überprüfung aktuellen Charakter und Bank")
ZO_CreateStringId("DsRGuildInventory_NeedUpdate"             , "Ein Update ist nötig")
ZO_CreateStringId("DsRGuildInventory_NoNeedUpdate"           , "Alles auf Stand")
ZO_CreateStringId("DsRGuildInventory_LoadingInv"             , "Lade Inventar ")
ZO_CreateStringId("DsRGuildInventory_LoadingInvOf"           , "Lade Inventar von ")
ZO_CreateStringId("DsRGuildInventory_LoadingInvBank"         , "Lade Bankinventar")
ZO_CreateStringId("DsRGuildInventory_LoadingInvHouseChest"   , "Lade Inventar der Haustruhe ")
ZO_CreateStringId("DsRGuildInventory_LoadingInvGuildBank"    , "Lade Inventar der Gildenbank")
ZO_CreateStringId("DsRGuildInventory_SortingInventory"       , "Sortiere Inventar")
ZO_CreateStringId("DsRGuildInventory_WornSet"                , " (Ausgerüstet)")
ZO_CreateStringId("DsRGuildInventory_InvBank"                , "Bank")
ZO_CreateStringId("DsRGuildInventory_InvGuildBank"           , "Gildenbank")
ZO_CreateStringId("DsRGuildInventory_InvSetItems"            , "|c9fb6cd%d Set's (%d Gegenstände) , %d Gegenstände|r")
ZO_CreateStringId("DsRGuildInventory_InvSetOfItems"          , "|c9fb6cd%d von %d Set's, %d von %d Setgegenständen|r")
ZO_CreateStringId("DsRGuildInventory_InvItems"               , "|c9fb6cd%s (%d Gegenstände)|r")
ZO_CreateStringId("DsRGuildInventory_InvOfItems"             , "|c9fb6cd%s (%d von %d Gegenständen)|r")
ZO_CreateStringId("DsRGuildInventory_ItemLock"               , "Sperren")
ZO_CreateStringId("DsRGuildInventory_ItemUnLock"             , "Entsperren")
ZO_CreateStringId("DsRGuildInventory_ItemLockQueued"         , "Sperren (Warteschlange)")
ZO_CreateStringId("DsRGuildInventory_ItemLockQueuedCan"      , "Sperren abbrechen (Warteschlange)")
ZO_CreateStringId("DsRGuildInventory_ItemUnLockQueued"       , "Entsperren (Warteschlange)")
ZO_CreateStringId("DsRGuildInventory_ItemUnLockQueuedCan"    , "Entsperren abbrechen (Warteschlange)")
ZO_CreateStringId("DsRGuildInventory_LinkInChat"             , "Link in Chat")
ZO_CreateStringId("DsRGuildInventory_ShowOnlyLoots"          , "Zeige nur Loot an")
ZO_CreateStringId("DsRGuildInventory_ShowCraftedSets"        , "Zeige hergestellte Set's")
ZO_CreateStringId("DsRGuildInventory_ShowTradeableSets"      , "Zeige handelbare Set's")
ZO_CreateStringId("DsRGuildInventory_ShowBoundSets"          , "Zeige gebundene Set's")
ZO_CreateStringId("DsRGuildInventory_ShowMonsterSets"        , "Zeige Monster-Set's")
ZO_CreateStringId("DsRGuildInventory_ShowOtherItems"         , "Zeige andere Gegenstände")
ZO_CreateStringId("DsRGuildInventory_ShowOnlyCP160"          , "Zeige nur CP160 Gegenstände")
ZO_CreateStringId("DsRGuildInventory_ShowOnlyNonCP160"       , "Zeige nur nonCP160 Gegenstände")
ZO_CreateStringId("DsRGuildInventory_ResetFilters"           , "|u16:0:: Filter zurücksetzen|u")
ZO_CreateStringId("DsRGuildInventory_InvOpenSettings"        , "|u16:0:: Einstellungen|u")
ZO_CreateStringId("DsRGuildInventory_InvRescan"              , "|u16:0:: Überprüfe Inventar|u")
ZO_CreateStringId("DsRGuildInventory_Health"                 , "Leben")
ZO_CreateStringId("DsRGuildInventory_Magicka"                , "Magicka")
ZO_CreateStringId("DsRGuildInventory_Stamina"                , "Ausdauer")
ZO_CreateStringId("DsRGuildInventory_PrismaticDef"           , "prismat. Verteidigung")
ZO_CreateStringId("DsRGuildInventory_AbsorbHealth"           , "Lebensabsorption")
ZO_CreateStringId("DsRGuildInventory_AbsorbMagicka"          , "Magickaabsorption")
ZO_CreateStringId("DsRGuildInventory_AbsorbStamina"          , "Ausdauerabsorption")
ZO_CreateStringId("DsRGuildInventory_Crushing"               , "Abhärtung")
ZO_CreateStringId("DsRGuildInventory_Oblivion"               , "Zerschmettern")
ZO_CreateStringId("DsRGuildInventory_Flame"                  , "Flamme")
ZO_CreateStringId("DsRGuildInventory_Disease"                , "Fäulnis")
ZO_CreateStringId("DsRGuildInventory_Frost"                  , "Frost")
ZO_CreateStringId("DsRGuildInventory_Hardening"              , "Abhärtung")
ZO_CreateStringId("DsRGuildInventory_Poison"                 , "Gift")
ZO_CreateStringId("DsRGuildInventory_PrismaticWeapon"        , "prismat. Ansturm")
ZO_CreateStringId("DsRGuildInventory_Shock"                  , "Schock")
ZO_CreateStringId("DsRGuildInventory_Weakening"              , "Schwächung")
ZO_CreateStringId("DsRGuildInventory_WeaponDamage"           , "Waffenkraft")
ZO_CreateStringId("DsRGuildInventory_Bashing"                , "Einschlagen")
ZO_CreateStringId("DsRGuildInventory_DecreasePhysicalHarm"   , "verringerter physischer Schaden")
ZO_CreateStringId("DsRGuildInventory_DecreaseSpellHarm"      , "verringerter magischer Schaden")
ZO_CreateStringId("DsRGuildInventory_DiseaseResist"          , "Seuchenresistenz")
ZO_CreateStringId("DsRGuildInventory_FlameResist"            , "Flammenresistenz")
ZO_CreateStringId("DsRGuildInventory_FrostResist"            , "Frostresistenz")
ZO_CreateStringId("DsRGuildInventory_HealthRecovery"         , "Lebensregeneration")
ZO_CreateStringId("DsRGuildInventory_SpellDamage"            , "erhöhter magischer Schaden")
ZO_CreateStringId("DsRGuildInventory_WeaponDamage"           , "erhöhter physischer Schaden")
ZO_CreateStringId("DsRGuildInventory_MagickaRecovery"        , "Magickaregeneration")
ZO_CreateStringId("DsRGuildInventory_PoisonResist"           , "Giftresistenz")
ZO_CreateStringId("DsRGuildInventory_PotionBoost"            , "Trankverbesserung")
ZO_CreateStringId("DsRGuildInventory_PotionSpeed"            , "Tranktempo")
ZO_CreateStringId("DsRGuildInventory_ReduceStaminaCost"      , "Waffenkostenminderung")
ZO_CreateStringId("DsRGuildInventory_ReduceSpellCost"        , "Zauberkostenminderung")
ZO_CreateStringId("DsRGuildInventory_ReduceBashCost"         , "Absteifung")
ZO_CreateStringId("DsRGuildInventory_ShockResist"            , "Schockresistenz")
ZO_CreateStringId("DsRGuildInventory_StaminaRecovery"        , "Ausdauerregeneration")
ZO_CreateStringId("DsRGuildInventory_ReduceSkillCost"        , "Fähigkeitenkostenminderung")
ZO_CreateStringId("DsRGuildInventory_PrismaticRecovery"      , "prismat. Regeneration")
ZO_CreateStringId("DsRGuildInventory_ChatLock"               , "-> gesperrt")
ZO_CreateStringId("DsRGuildInventory_ChatUnLock"             , "-> entsperrt")
ZO_CreateStringId("DsRGuildInventory_ChatLockQueued"         , "-> in Warteschlange zum sperren")
ZO_CreateStringId("DsRGuildInventory_ChatLockQueuedREM"      , "-> aus Warteschlange entfernt")
ZO_CreateStringId("DsRGuildInventory_ChatUnLockQueued"       , "-> in Warteschlange zum entsperren")
ZO_CreateStringId("DsRGuildInventory_FilterChest"            , "ACE-|c9fb6cd-- Truhen --|r")
ZO_CreateStringId("DsRGuildInventory_FilterChar"             , "ACA-|c9fb6cd-- Charakter --|r")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Achievement Tracker
ZO_CreateStringId("DsRGuildAchievTracker_SubMenu"            , "Errungenschaftsverfolgung")
ZO_CreateStringId("DsRGuildAchievTracker_hideCompleted"      , "Entferne abgeschlossene")
ZO_CreateStringId("DsRGuildAchievTracker_hideCompletedTP"    , "Entfernt Errungenschaften automatisch aus der Verfolgung, nachdem diese abgeschlossen sind.")
ZO_CreateStringId("DsRGuildAchievTracker_bgAlpha"            , "Stärke des Hintergrundes")
ZO_CreateStringId("DsRGuildAchievTracker_bgAlphaTP"          , "Passe die Transparenz des Hintergrundes an. 0 = Ausgeblendet")
ZO_CreateStringId("DsRGuildAchievTracker_reset"              , "Verfolgungen löschen")
ZO_CreateStringId("DsRGuildAchievTracker_resetTP"            , "Löscht alle Verfolungen von Errungenschaften")
ZO_CreateStringId("DsRGuildAchievTrackerFav_Fav"             , "|c9fb6cdDsR-Verfolgung|r")
ZO_CreateStringId("DsRGuildAchievTrackerFav_FavADD"          , "Errungenschaft verfolgen")
ZO_CreateStringId("DsRGuildAchievTrackerFav_FavREM"          , "Verfolgung entfernen")
ZO_CreateStringId("DsRGuildAchievTrackerFav_FavGoTo"         , "Gehe zu Errungenschaft")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Crafting
ZO_CreateStringId("DsRGuildCrafting_SubMenu"                 , "Handwerk")
ZO_CreateStringId("DsRGuildCrafting_PrecraftNoProfessions"   , " |c9fb6cd[DsR-Precrafter]|r |cEE0000Es sind in den Einstellungen keine Berufe aktiviert! Es wurde nichts in die Warteschlange gesetzt werden|r")
ZO_CreateStringId("DsRGuildCrafting_PrecraftNoInvSpace"      , " |c9fb6cd[DsR-Precrafter]|r |cEE0000Nicht genügend Inventarplätze vorhanden|r")
ZO_CreateStringId("DsRGuildCrafting_PrecraftNoZero"          , " |c9fb6cd[DsR-Precrafter]|r |cEE0000Die Warteschlange wurde geleert. Precrafter deaktiviert!|r")
ZO_CreateStringId("DsRGuildCrafting_PrecraftOneRot"          , " |c00ff00Dailys|r")
ZO_CreateStringId("DsRGuildCrafting_PrecraftQueue"           , "|c00ff00Herstellung für |r")
ZO_CreateStringId("DsRGuildCrafting_PrecraftItems"           , " Gegenstände")
ZO_CreateStringId("DsRGuildCrafting_PrecraftFinish"          , " erledigt")
ZO_CreateStringId("DsRGuildCrafting_PrecraftMats"            , " Es fehlen dir leider Materialien!")
ZO_CreateStringId("DsRGuildCrafting_PrecraftCMDadd"          , "Füge x-Rotation(en) in die Warteschlange ein. 0=Leeren")
ZO_CreateStringId("DsRGuildCrafting_PrecraftCMDrem"          , "Entferne alles aus der Warteschlange")
ZO_CreateStringId("DsRGuildCrafting_AlchemyFinish"           , "Daily " .. zo_iconFormat("/esoui/art/icons/skilllinexp_alchemy.dds", 20, 20) .. " |c42ffa1Alchemie|r erledigt")
ZO_CreateStringId("DsRGuildCrafting_ProvisionFinish"         , "Daily " .. zo_iconFormat("/esoui/art/icons/skilllinexp_provisioner.dds", 20, 20) .. " |c42ffa1Versorger|r erledigt")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Death Table
ZO_CreateStringId("DsRGuildDeathTable_Window"                , "Todesliste")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- CrownList
ZO_CreateStringId("DsRGuildMenue_cyrodiilCrownListHead"      , "|c00CDCDAbstand Lead|r")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Trading Price
ZO_CreateStringId("DsRGuildPrice_Loaded"                     , "geladen")
ZO_CreateStringId("DsRGuildPrice_NoPriceData"                , "Preis in Chat -> Kein Preis")
ZO_CreateStringId("DsRGuildPrice_NoPriceDataChat"            , "Kein Preis für ")
ZO_CreateStringId("DsRGuildPrice_PriceToChat"                , " in Chat -> ")
ZO_CreateStringId("DsRGuildPrice_AVGPriceToChat"             , "ø-Preis ")
ZO_CreateStringId("DsRGuildPrice_AVGPrice"                   , "ø-Preis ")
ZO_CreateStringId("DsRGuildPrice_GoldFor"                    , " Gold für ")
ZO_CreateStringId("DsRGuildPrice_For"                        , " für ")
ZO_CreateStringId("DsRGuildPrice_detailed"                   , " (Ausführlich)")
ZO_CreateStringId("DsRGuildPrice_Sale"                       , "Verkäufe")
ZO_CreateStringId("DsRGuildPrice_WritVouchers"               , "Schriebscheine")
ZO_CreateStringId("DsRGuildPrice_items"                      , "Items")
ZO_CreateStringId("DsRGuildPrice_TTCnotavailable"            , "TTC nicht vorhanden!")
ZO_CreateStringId("DsRGuildPrice_MMnotavailable"             , "MM nicht vorhanden!")
ZO_CreateStringId("DsRGuildPrice_ATTnotavailable"            , "ATT nicht vorhanden!")
ZO_CreateStringId("DsRGuildPrice_SPACE"                      , "LEERZEICHEN")
ZO_CreateStringId("DsRGuildPrice_EMPTY"                      , "KEIN")
ZO_CreateStringId("DsRGuildPrice_Defaultprice"               , "Standardpreis ")
ZO_CreateStringId("DsRGuildPrice_Profitprice"                , "Gewinn ")
ZO_CreateStringId("DsRGuildPrice_TTCprice"                   , "TTC Preis ")
ZO_CreateStringId("DsRGuildPrice_MMprice"                    , "MM Preis ")
ZO_CreateStringId("DsRGuildPrice_ATTprice"                   , "ATT Preis ")
ZO_CreateStringId("DsRGuildPrice_Tradeprice"                 , "Verkaufspreis ")
ZO_CreateStringId("DsRGuildPrice_Averageprice"               , "Durchschnittspreis ")
ZO_CreateStringId("DsRGuildPrice_Bestprice"                  , "Bester Preis ")
ZO_CreateStringId("DsRGuildPrice_DisableStartupLog"          , "Startmeldungen ausschalten")
ZO_CreateStringId("DsRGuildPrice_DisableStartupLogTP"        , "Entfernt Meldungen beim Start, außer '|c9fb6cd[DsR-Price]|r Initialized'")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Personal
ZO_CreateStringId("DsRGuildPersonal_GeneralZERO"              , "0 deaktiviert die Option")
ZO_CreateStringId("DsRGuildPersonal_GeneralNothing"           , "nichts machen")
ZO_CreateStringId("DsRGuildPersonal_GeneralDepoBank"          , "In die Bank")
ZO_CreateStringId("DsRGuildPersonal_GeneralWithBank"          , "Ins Inventar")
ZO_CreateStringId("DsRGuildPersonal_Deposit"                  , "|c35fc38eingelagert|r")
ZO_CreateStringId("DsRGuildPersonal_DepositMenu"              , " |c3b3b3b(nur einlagern)|r")
ZO_CreateStringId("DsRGuildPersonal_Withdraw"                 , "|cFAA0A0entnommen|r")
ZO_CreateStringId("DsRGuildPersonal_MenueLoading"             , "|cFF0000!!!ACHTUNG!!!\n\nDer Personal Assistant wird gerade geladen. Bitte warten und keine Einstellungen verändern bis dieses Symbol verschwindet!\n\nESO kann für einige Sekunden schlecht reagieren.\nSobald alle Einstellungen erstellt wurden verschwindet dieses Symbol und Du kannst mit den Einstellungen arbeiten.")
ZO_CreateStringId("DsRGuildPersonal_MenueBanking"             , " |c7393B3Banking|r")
ZO_CreateStringId("DsRGuildPersonal_MenueBankingAvA"          , " - Belagerungswaffen")
ZO_CreateStringId("DsRGuildPersonal_MenueAvAShopping"         , " |c7393B3Belagerungsmeister|r")
ZO_CreateStringId("DsRGuildPersonal_MenueJunk"                , " |c7393B3Trödel|r")
ZO_CreateStringId("DsRGuildPersonal_BankingDepositTransaction", "|cA52A2A<<2>>x|r <<t:1>> |c35fc38eingelagert|r")
ZO_CreateStringId("DsRGuildPersonal_BankingWithdrawTransaction", "|cA52A2A<<2>>x|r <<t:1>> |cFAA0A0entnommen|r")
ZO_CreateStringId("DsRGuildPersonal_CurrencyRecipe"           , "|c7393B3Rezepte / Anleitungen etc|r")
ZO_CreateStringId("DsRGuildPersonal_CurrencyCyro"             , "|c7393B3Cyrodiil|r")
ZO_CreateStringId("DsRGuildPersonal_CurrencyTP"               , "Leere das Feld um es zu deaktivieren")
ZO_CreateStringId("DsRGuildPersonal_SoulGemEmpty"             , zo_iconFormat(GetItemLinkIcon("|H0:item:33265:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 26, 26) .. LocalizeString("<<1>>", "|H0:item:33265:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"))
ZO_CreateStringId("DsRGuildPersonal_SoulGem"                  , zo_iconFormat(GetItemLinkIcon("|H0:item:33271:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 26, 26) .. LocalizeString("<<1>>", "|H0:item:33271:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"))
ZO_CreateStringId("DsRGuildPersonal_Glyphe"                   , "Glyphe")
ZO_CreateStringId("DsRGuildPersonal_Jewelry"                  , "Schmuck")
ZO_CreateStringId("DsRGuildPersonal_AvAShopTP"                , "Der Wert '0' deaktiviert den Handel")
ZO_CreateStringId("DsRGuildPersonal_AvAShopBought"            , "|c35fc38Gekauft|r <<1>> x <<2>> für <<3>>")
ZO_CreateStringId("DsRGuildPersonal_AvAShopMissing"           , "|cEE0000Nicht gekauft|r <<1>>x <<2>> für <<3>> (<<4>> fehlen)")
ZO_CreateStringId("DsRGuildPersonal_JunkSellFinish"           , "|c00ff00Trödel verkauft für:|r <<1>>")
ZO_CreateStringId("DsRGuildPersonal_JunkManuSetPermJunk"      , "Als perm. Trödel markieren")
ZO_CreateStringId("DsRGuildPersonal_JunkManuRemPermJunk"      , "Nicht mehr als perm. Trödel markieren")
ZO_CreateStringId("DsRGuildPersonal_JunkManuClearPermJunk"    , "Aus Trödelliste entfernen")
ZO_CreateStringId("DsRGuildPersonal_DeconstructAlways"        , " immer")
ZO_CreateStringId("DsRGuildPersonal_DeconstructMythic"        , " [Mystische] Gegenstände")
ZO_CreateStringId("DsRGuildPersonal_DeconstructFinish"        , " |cFF0000<<1>>|r |c00ff00Gegenstände verwertet|r")
ZO_CreateStringId("DsRGuildPersonal_DeconstructFinishOne"     , " |cFF0000<<1>>|r |c00ff00Gegenstand verwertet|r")
ZO_CreateStringId("DsRGuildPersonal_DeconstructAbort"         , " |cFAA0A0Die automatische Verwertung wurde blockiert, da du eine laufende Handwerksaufgabe hast.|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeMenu"              , " |c7393B3Hungergefühl|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeFoodend"           , "|cFF0000" .. zo_iconFormat("/esoui/art/icons/justice_stolen_food_001.dds", 38, 38) .. " Kein Buff-Food aktiv, nimm was zu Dir!|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeFoodendSec"        , "|cFF0000läuft in|r |cFFFF00<<1[$d Sekunden/$d Sekunden/$d Sekunden]>>|r|cFF0000 ab|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeFoodendMin"        , "|cFF0000läuft in|r |cFFFF00<<1[$d Minuten/$d Minute/$d Minuten]>>|r|cFF0000 ab|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeXPend"             , zo_iconFormat("/esoui/art/icons/crowncrate_experiencescroll_002.dds", 38, 38) .. "|cFF0000 Kein " .. zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds", 40, 40) .. "-Buff aktiviert|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeXPendSec"          , "|cFF0000" .. zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds", 38, 38) .. "-Buff läuft in|r |cFFFF00<<1[$d Sekunden/$d Sekunden/$d Sekunden]>>|r|cFF0000 ab|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeXPendMin"          , "|cFF0000" .. zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds", 38, 38) .. "-Buff läuft in|r |cFFFF00<<1[$d Minuten/$d Minute/$d Minuten]>>|r|cFF0000 ab|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAPend"             , zo_iconFormat("/esoui/art/icons/ava_skill_boost_food_002.dds", 38, 38) .. "|cFF0000 Kein " .. zo_iconFormat("/DsRGuildHall/misc/DsR_AP.dds", 40, 40) .. "-Buff aktiviert|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAPendSec"          , "|cFF0000" .. zo_iconFormat("/DsRGuildHall/misc/DsR_AP.dds", 38, 38) .. "-Buff läuft in|r |cFFFF00<<1[$d Sekunden/$d Sekunden/$d Sekunden]>>|r|cFF0000 ab|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAPendMin"          , "|cFF0000" .. zo_iconFormat("/DsRGuildHall/misc/DsR_AP.dds", 38, 38) .. "-Buff läuft in|r |cFFFF00<<1[$d Minuten/$d Minute/$d Minuten]>>|r|cFF0000 ab|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAutoEatTyp"        , "|cFFD39BDein ausgewähltes Essen: |r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAutoEatXPAP"       , "|cFFD39BDeine ausgewählte Rolle: |r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAutoEatTypDesc"    , "|cFFAE42Um das automatische Essen für diesen Charakter zu aktivieren, öffne das Inventar, klicken mit der rechten Maustaste auf das gewünschte Essen oder Getränk und wählen die Option „Hungergefühl befriedigen“.|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeSetFood"           , "|c35fc38Aktiviere|r dieses  " .. zo_iconTextFormat("/esoui/art/icons/justice_stolen_food_001.dds", 20, 20, " ") .. "-Food")
ZO_CreateStringId("DsRGuildPersonal_ConsumeRemFood"           , "|cFAA0A0Stoppe|r dieses  " .. zo_iconTextFormat("/esoui/art/icons/justice_stolen_food_001.dds", 20, 20, " ") .. "-Food")
ZO_CreateStringId("DsRGuildPersonal_ConsumeSetAP"             , "|c35fc38Aktiviere|r diese " .. zo_iconTextFormat("/DsRGuildHall/misc/DsR_AP.dds", 24, 24, " ") .. "-Rolle")
ZO_CreateStringId("DsRGuildPersonal_ConsumeRemAP"             , "|cFAA0A0Stoppe|r diese " .. zo_iconTextFormat("/DsRGuildHall/misc/DsR_AP.dds", 24, 24, " ") .. "-Rolle")
ZO_CreateStringId("DsRGuildPersonal_ConsumeSetXP"             , "|c35fc38Aktiviere|r diese " .. zo_iconTextFormat("/DsRGuildHall/misc/DsR_XP.dds", 24, 24, " ") .. "-Rolle")
ZO_CreateStringId("DsRGuildPersonal_ConsumeRemXP"             , "|cFAA0A0Stoppe|r diese " .. zo_iconTextFormat("/DsRGuildHall/misc/DsR_XP.dds", 24, 24, " ") .. "-Rolle")
ZO_CreateStringId("DsRGuildPersonal_ConsumeFailTyp"           , " |cFAA0A0ist kein Essen/Trinken|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeFailXP"            , " |cFAA0A0ist keine XP-Rolle|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeFailAP"            , " |cFAA0A0ist keine AP-Rolle|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeSetAutoTyp"        , " |c35fc38wird autom. Konsumiert|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeSetAutoXPAp"       , " |c35fc38wird autom. Aktiviert|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeRemAutoTyp"        , " |cFAA0A0autom. Konsumierung gestoppt|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeRemAutoXPAP"       , " |cFAA0A0autom. Aktivierung gestoppt|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeEating"            , "|c00ff00Hungergefühl gestillt mit: |r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAttention"         , "|cFAA0A0Du hast <<1[$d/nurnoch $d/nurnoch $d]>> in deinem Inventar.|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAttentionA1"       , "|cFAA0A0Du hast |r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAttentionA2"       , "|cFAA0A0 für die autom. Konsumierung gesetzt, aber Du hast keine mehr im Inventar.|r|cFF0000 Autom. Konsum wurde deaktiviert!!|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeButton"            , "Entfernen")
ZO_CreateStringId("DsRGuildPersonal_RepairMenue"              , " |c7393B3Rüstungswerkstatt|r")
ZO_CreateStringId("DsRGuildPersonal_RepairGlobalsAll"         , "Alles")
ZO_CreateStringId("DsRGuildPersonal_RepairGlobalsWorn"        , "Abgenutzt")
ZO_CreateStringId("DsRGuildPersonal_RepairGlobalsNone"        , "Nichts")
ZO_CreateStringId("DsRGuildPersonal_RepairGlobalAlways"       , "Immer")
ZO_CreateStringId("DsRGuildPersonal_RepairGlobalRaiding"      , "Nur im Raid")
ZO_CreateStringId("DsRGuildPersonal_RepairGlobalNever"        , "Niemals")
ZO_CreateStringId("DsRGuildPersonal_RepairRepaired"           , "Repariert ")
ZO_CreateStringId("DsRGuildPersonal_RepairRecharged"          , "Aufgeladen ")
ZO_CreateStringId("DsRGuildPersonal_RepairFor"                , " für: ")
ZO_CreateStringId("DsRGuildPersonal_RepairCannotAfford"       , "Reparatur nicht möglich von ")
ZO_CreateStringId("DsRGuildPersonal_RepairTotalCost"          , "Summe Werkstattkosten: ")
ZO_CreateStringId("DsRGuildPersonal_RepairTotalGearCost"      , "Alles repariert für: ")
ZO_CreateStringId("DsRGuildPersonal_RepairGearCostAfford"     , "Du kannst Dir die Werkstattkosten nicht leisten von: ")
ZO_CreateStringId("DsRGuildPersonal_SurveyUnkown"             , " |c3b3b3b(inkl. Unidentifizierte)|r")
ZO_CreateStringId("DsRGuildPersonal_MasterUnkown"             , " |c3b3b3b(inkl. Unbekannte)|r")
ZO_CreateStringId("DsRGuildPersonal_TreasureUnkown"           , " |c3b3b3b(inkl. Ungeöffnet)|r")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- MainMenue Window
ZO_CreateStringId("DsRGuildcmd_MainButtonWindow"              , "Trödelliste")
ZO_CreateStringId("DsRGuildMainWindow_Header"                 , zo_iconFormat(DsRIcon, 36, 36) .. "|c9fb6cdDsR - persönliche Trödelliste|r" .. zo_iconFormat(DsRIcon, 36, 36))
ZO_CreateStringId("DsRGuildcmd_MainListEmpty"                 , "Trödelliste ist leer")
ZO_CreateStringId("DsRGuildcmd_MainListTRUE"                  , "Immer")
ZO_CreateStringId("DsRGuildcmd_MainListFALSE"                 , "Nie")
ZO_CreateStringId("DsRGuildcmd_MainListALL"                   , "Alle")
ZO_CreateStringId("DsRGuildcmd_MainListCLOSE"                 , "Schließen")
ZO_CreateStringId("DsRGuildcmd_MainListDESC"                  , "|cFFFF00*|r |c9fb6cdwird bereits über die Einstellungen geregelt (wenn eingestellt)|r")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Unknown Tracker
ZO_CreateStringId("DsRGuildUnknown_MenuLeft"                  , "Links")
ZO_CreateStringId("DsRGuildUnknown_MenuRight"                 , "Rechts")
ZO_CreateStringId("DsRGuildUnknown_MenuCorner"                , "Iconecke")
ZO_CreateStringId("DsRGuildUnknown_MenuLearning"              , "Lernen")
ZO_CreateStringId("DsRGuildUnknown_MenuLearningNot"           , "Nicht lernen")
ZO_CreateStringId("DsRGuildUnknown_MenuLearningAll"           , "Lernen auf allen Accounts")
ZO_CreateStringId("DsRGuildUnknown_SelectIcon1"               , "Haken")
ZO_CreateStringId("DsRGuildUnknown_SelectIcon2"               , "Brief 1")
ZO_CreateStringId("DsRGuildUnknown_SelectIcon3"               , "Brief 2")
ZO_CreateStringId("DsRGuildUnknown_SelectIcon4"               , "Achtung")
ZO_CreateStringId("DsRGuildUnknown_SelectIcon5"               , "Info")
ZO_CreateStringId("DsRGuildUnknown_SelectIcon6"               , "Buch")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Auto Welcome
ZO_CreateStringId("DsRGuildUnknown_WelcomeOnOff"              , "Aktiviere Willkomensnachricht für diese Gilde")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- MENU
DsR.Localization.de = {
        --Warnings
        ReloadUiWarn    = "|cFAA0A0Die Änderungen werden erst nach Neuladen der Benutzeroberfläche sichtbar.|r",
        ReloadUiWarn1   = "|cFAA0A0Diese Einstellung benötigt ein Neuladen der Benutzeroberfläche.|r",
        ReloadUiWarn2   = "|cFAA0A0Das Ein-/Ausschalten dieser Einstellung bewirkt ein sofortiges Neuladen der Benutzeroberfläche.|r",
        
        --IndexMenu
        IndexMisc                = "Allgemein",
        IndexLootManager         = "Lootmanager",
        IndexStickerbook         = "Stickerbook",
        IndexAllianceWarGeneral  = "Allianzkrieg - Allgemein",
        IndexAllianceWarCyrodiil = "Allianzkrieg - Cyrodiil",
        IndexAllianceWarImpCity  = "Allianzkrieg - Kaiserstadt",
        IndexGroupRaid           = "Gruppe & Raids - Allgemein",
        IndexGroupBuff           = "Gruppe & Raids - Buffs",
        IndexAchievTrack         = "Errungenschaftsverfolgung",
        IndexCrafting            = "Handwerk",
        IndexInventoryManager    = "Inventar Manager",
        IndexTradingPrice        = "Handelspreise",
        IndexTrackerGeneral      = "Unknown Tracker",
        IndexPersonalAssBank     = "Banking",
        IndexPersonalAssBankAvA  = "Banking AvA",
        IndexPersonalAssJunk     = "Trödel / Verwerten",
        IndexPersonalAssConsumer = "Hungergefühl",
        IndexPersonalAssRepair   = "Rüstungswerkstatt",
        IndexPersonalAssAvAshop  = "Belagerungsmeister",
        IndexBarMenu             = "RabenBar",

        --Options - 'IndexMisc'
        DsRGuild_donationTxt1         = "|c80dfffÜber eine " .. zo_iconFormat("/esoui/art/currency/currency_gold.dds", 16, 16) .. "-Spende für mich und der Gilde 'Die sieben Raben' würde ich mich sehr freuen :-)|r",
        DsRGuildMenue_accsettings     = "|cFFAE42Alle Einstellungen gelten Accountweit!|r",
        DsRGuildMenue_UpdateNews      = "|c35fc38Addon-Update News anzeigen?|r",
        DsRGuildMenue_UpdateNewsDesc  = "Soll ein PopUp-Fenster angezeigt werden beim ersten Einloggen mit den Änderungen, nach einem Update vom Addon?",
        
            -- Submenu - chatcommands
            DsRGuildMenue_chatcommands           = "Chatbefehle",
            DsRGuildMenue_accKeybindAddonUpdate  = "|cFFAE42/dsraddonupdate|r = Öffne das Popup-Fenster 'Addon-Update News'",
            DsRGuildMenue_accKeybind             = "|cFFAE42/dsr|r = Öffne das Einstellungsmenü über den Chat",
            DsRGuildBind_slashdsrim              = "|cFFAE42/dsrinventory|r = Öffne den DsR InventoryManager",
            DsRGuildBind_slashDESC1              = "|cFFAE42/dsrbind|r = Binde alle Set-Gegenstände",
            DsRGuildBind_slashDESC2              = "|cFFAE42/dsrpost|r = Poste alle Set-Gegenstände, welche Du schon kennst in den Chat",
            DsRGuildBind_slashDESC3              = "|cFFAE42/dsrstart [ZAHL]|r = Starte den Timer eines Bezirkes, z.B. /dsrstart 1",
            DsRGuildPvP_ap_telvarSaverKeybind    = "|cFFAE42/dsrport|r = Porte autom. in eine leere Cyrokampagne",
            
            -- Submenu - Developer
            DsRGuildMenue_Developer              = "Developer-Modus",
            DsRGuildMenue_DeveloperDesc          = "Aktiviert im Inventar, Bank etc. im Kontextmenü (rechte Maustaste) Optionen für Entwickler",
            DsRGuildMenue_DeveloperAct           = "|cFFAE42Developer-Modus aktivieren|r",
            DsRGuildMenue_DeveloperID            = "ID",
            DsRGuildMenue_DeveloperICON          = "ICON",
            DsRGuildMenue_DeveloperLINK          = "LINK",
            DsRGuildMenue_DeveloperTYPE          = "TYPE",
            DsRGuildMenue_DeveloperTRAIT         = "TRAIT",
            DsRGuildMenue_DeveloperShowAll       = "Zeige alle",

            -- Submenu - DsRinternalInfosS
            DsRGuildMenue_DsRinternalInfos  = "Gildeninformationen |cb81414(nur DsR-Gilde)|r",
            DsRGuildMenue_DsRInfoHome       = "|cFFAE42Im Gildenhauptfenster werden die Informationen immer dargestellt!|r",
            DsRGuildMenue_DsRInfoRoster     = "Reiter 'Mitglieder'",
            DsRGuildMenue_DsRInfoRank       = "Reiter 'Ränge'",
            DsRGuildMenue_DsRInfoRecrut     = "Reiter 'Rekrutierung'",
            DsRGuildMenue_DsRInfoMasterJoint = "Rabenwacht",
            DsRGuildMenue_DsRMasterJoint     = zo_iconFormat("/esoui/art/chatwindow/chat_notification_up.dds", 26, 26) .. "Chatnachricht wenn " .. zo_iconFormat("/DsRGuildHall/misc/DsR_Rabenwacht.dds", 26, 26) .. "Rabenwacht joint?",
            DsRGuildMenue_DsRMasterJoinSound = zo_iconFormat("/esoui/art/chatwindow/chat_notification_up.dds", 26, 26) .. "Sound abspielen wenn " .. zo_iconFormat("/DsRGuildHall/misc/DsR_Rabenwacht.dds", 26, 26) .. "Rabenwacht joint?",

            -- Submenu - Take 1
            DsRGuildMenue_DsRTakeOneMenue     = zo_iconFormat("/esoui/art/guild/history/gamepad/gp_guildhistory_withdrawitems.dds", 26, 26) .. "|c00CDCDBrauch nur EINS|r",
            DsRGuildMenue_DsRTakeOneOnOff     = "|cFFAE42Aktiviere die Option|r",
            DsRGuildMenue_DsRTakeOneOnOffDesc = "Wenn Aktiviert, hast Du im Kontextmenü (rechte Maustaste) in der Bank etc. die Option, nur 1 Gegenstand zu entnehmen, anstatt alle",
            DsRGuildMenue_DsRTakeOne          = "|c9fb6cd[DsR]|r Entnehme 1",
            DsRGuildMenue_DsRTakeOneBackFull  = "|c9fb6cd[DsR]|r |cFAA0A0Du benötigst min. 2 freie Plätze im Inventar|r",

            -- Submenu - Welcome
            DsRGuildUnknown_WelcomeMain       = zo_iconFormat("/esoui/art/chatwindow/chat_notification_up.dds", 26, 26) .. "|c00CDCDWillkommen|r",
            DsRGuildUnknown_WelcomeGenOnOff   = "Aktiviere die Willkomensnachrichten",
            DsRGuildUnknown_WelcomeMemberName = "|cFFAE42%1 = Spielername|r",
            DsRGuildUnknown_WelcomeNoGuild    = "|cFAA0A0Trete einer Gilde bei, um dieses zu verwenden!|r",
            DsRGuildUnknown_WelcomeTXT        = "Willkomensnachricht",
            DsRGuildUnknown_WelcomeAttention  = "|cadff2fDie Chatnachricht wird nur ausgeführt, wenn das neue Gildenmitglied zum Zeitpunkt auch ONLINE ist.|r",
            DsRGuildUnknown_WelcomeAttentionA = "|cadff2fZusätzlich aktiviert sich die Nachricht nur, wenn Du nicht im Kampf bist.|r",


            -- Submenu - Friends
            DsRGuildMenue_DsRFriendsMenue     = zo_iconFormat("/esoui/art/friends/friends_tabicon_friends.dds", 26, 26) .. "|c00CDCDFreunde|r",
            DsRGuildMenue_DsRFriends          = "Kein Freundstatus anzeigen",
            DsRGuildMenue_DsRFriendsDesc      = "Verbirgt die Chatnachricht, wenn sich ein Freund ein-/ausloggt.",
            DsRGuildMenue_DsRFriendsCOLOR     = "Farbig angepasste Benachrichtigungen",
            DsRGuildMenue_DsRFriendsCOLORDesc = "Nur wenn 'Kein Freundesstatus anzeigen' auf |cFAA0A0AUS|r !!\nErsetzt die normale gelbe Benachrichtigung in eine farbenfrohe Variante.",
            DsRGuildMenue_DsRFriendsLogin     = "Welcher ACC-Name soll dennoch angezeigt werden",
            DsRGuildMenue_DsRFriendsLoginDesc = "Eine Liste in welcher je Zeile ein Freund (Accountname inkl. @) eingetragen werden kann, welcher beim Ein-/Ausloggen angezeigt wird.\nAls Beispiel:\n@Hasenwarrior\n@Hasenwarrior2\n\nDrücke die ENTER Taste, um eine neue Zeile zu beginnen.",

            -- Submenu - GuildChat
            DsRGuildMenue_DsRSTACHATMenue     = zo_iconFormat("/esoui/art/chatwindow/chat_notification_up.dds", 26, 26) .. "|c00CDCDStandardchat|r",
            DsRGuildMenue_DsRSTACHATONOFF     = "Standardchat aktivieren",
            DsRGuildMenue_DsRSTACHATONOFFDesc = "Diese Einstellung ignoriert die Einstellungen der Addons\n|cb81414- pChat\n- rChat\n- AccountSettings|r",
            DsRGuildMenue_DsRSTACHATdropdown  = "Welcher Chat soll beim Start gesetzt werden",


        --Options - 'IndexLootManager'
            -- Submenu - Notification Screen
            DsRGuildMenue_notificationscreen     = "Bildschirm",
            DsRGuildLoot_screenloot_deactivate   = "Bildschirm-Loot deaktivieren",
            DsRGuildLoot_own_loot_quali          = "Zeige eigenen Loot ab Qualität ....",
            DsRGuildMenue_notificationspecial    = "|c00CDCDBesonderer Loot|r",
            DsRGuildMenue_notificationspecialTxt = "|cFFAE42Dieser wird immer angezeigt, auch wenn die Hauptfunktion deaktiviert ist|r",
            DsRGuildLoot_fortified_nirncrux      = zo_iconFormat(GetItemLinkIcon("|H0:item:56863:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22)  .. LocalizeString("<<1>>", "|H0:item:56863:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_potent_nirncrux         = zo_iconFormat(GetItemLinkIcon("|H0:item:56862:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22)  .. LocalizeString("<<1>>", "|H0:item:56862:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_kuta                    = zo_iconFormat(GetItemLinkIcon("|H0:item:45854:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22)  .. LocalizeString("<<1>>", "|H0:item:45854:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_hakeijo                 = zo_iconFormat(GetItemLinkIcon("|H0:item:68342:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22)  .. LocalizeString("<<1>>", "|H0:item:68342:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_LuminousInk             = zo_iconFormat(GetItemLinkIcon("|H0:item:204881:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:204881:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_rubyblossomextract      = zo_iconFormat(GetItemLinkIcon("|H0:item:171328:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:171328:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_mourningdew             = zo_iconFormat(GetItemLinkIcon("|H0:item:171433:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:171433:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_PerfectRoe              = zo_iconFormat(GetItemLinkIcon("|H0:item:64222:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22)  .. LocalizeString("<<1>>", "|H0:item:64222:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_AetherialDust           = zo_iconFormat(GetItemLinkIcon("|H0:item:115026:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:115026:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_AethericCipher          = zo_iconFormat(GetItemLinkIcon("|H0:item:115028:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:115028:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_endeavor                = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_SEALS)) .. "|cA52A2A".. GetCurrencyName(CURT_SEALS, false):gsub("%^.+", "") .. "|r",

            -- Submenu - Notification Chat
            DsRGuildMenue_notificationchat       = "Chat",
            DsRGuildBind_ArmorCollected          = "|cb81414|t30:30:/esoui/art/collections/collections_tabicon_itemsets_down.dds:inheritcolor|t|r" .. "Zeige nur fehlende Stickerbook Gegenstände",
            DsRGuildBind_ArmorCollectedDesc      = "Es wird nur noch Chatloot angezeigt von ''Rüstungen und Waffen'', welche noch nicht im Stickeralbum sind.",
            DsRGuildLoot_chatloot_trait          = zo_iconFormat("/esoui/art/inventory/inventory_trait_reconstruct_icon.dds", 22, 22) .. "Zeige Trait bei Rüstung/Waffen",
            DsRGuildLoot_chatloot_deactivate     = "Chat-Loot deaktivieren",
            DsRGuildLoot_group_loot_deactivate   = "Gruppen-Loot aktivieren",
            DsRGuildLoot_group_loot_quali        = "Zeige Gruppen-Loot ab Qualität ....",
            DsRGuildLoot_experience_gain         = zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds", 22, 22) .. "Erfahrungsgewinn",
            DsRGuildLoot_experience_gainTXT      = "Minimum XP-Gewinn zum Anzeigen",
            DsRGuildLoot_gold_gain               = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_MONEY)) .. GetCurrencyName(CURT_MONEY, false):gsub("%^.+", ""),
            DsRGuildLoot_gold_gainTXT            = "Minimum Gold-Gewinn zum Anzeigen",
            DsRGuildLoot_imperial_fragments      = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_IMPERIAL_FRAGMENTS)) .. GetCurrencyName(CURT_IMPERIAL_FRAGMENTS, false):gsub("%^.+", ""),
            DsRGuildMenue_notificationOther      = "|c00CDCDWährung|r",
            DsRGuildLoot_undauntedkeys           = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_UNDAUNTED_KEYS)) .. GetCurrencyName(CURT_UNDAUNTED_KEYS, false):gsub("%^.+", ""),
            DsRGuildLoot_event_Tickets           = zo_iconFormat("/esoui/art/currency/icon_eventticket_loot.dds", 22, 22) .. "Ereignisscheine",
            DsRGuildLoot_transmute_crystals      = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_TRANSMUTE_CRYSTALS)) .. GetCurrencyName(CURT_TRANSMUTE_CRYSTALS, false):gsub("%^.+", ""),
            DsRGuildLoot_archival_fortunes       = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_ARCHIVAL_FORTUNES)) .. GetCurrencyName(CURT_ARCHIVAL_FORTUNES, false):gsub("%^.+", ""),
            DsRGuildLoot_completed_Achievements  = zo_iconFormat("/esoui/art/tutorial/journal_tabicon_achievements_up.dds", 22, 22) .. "Abgeschlossene Erfolge",
            DsRGuildLoot_progress_Achievements   = zo_iconFormat("/esoui/art/tutorial/journal_tabicon_achievements_up.dds", 22, 22) .. "Fortschritt Erfolge",
            DsRGuildLoot_bookloot                = zo_iconFormat("/esoui/art/icons/housing_bre_inc_book_open001.dds", 22, 22) .. "Fortschritt von Büchern",
            DsRGuildLoot_experience_skill        = "|c00CDCDFertigkeiten|r",
            DsRGuildLoot_experience_A            = "|c00CDCDFortschritt|r",
            DsRGuildLoot_experience_OnOff        = zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds", 22, 22) .. "Erfahrungsgewinn aktivieren",
            DsRGuildLoot_exp_WEAPON              = zo_iconFormat("/esoui/art/icons/ability_weapon_016.dds", 22, 22) .. "Waffen",
            DsRGuildLoot_exp_ARMOR               = zo_iconFormat("/esoui/art/icons/passive_armor_012.dds", 22, 22) .. "Rüstung",
            DsRGuildLoot_exp_GUILD               = zo_iconFormat("/esoui/art/icons/crownstore_skillline_fightersguild.dds", 22, 22) .. "Gilden",
            DsRGuildLoot_exp_AVA                 = zo_iconFormat("/esoui/art/icons/crownstore_skillline_alliancewar_assault.dds", 22, 22) .. "Allianzkrieg",
            DsRGuildLoot_exp_Excavation          = zo_iconFormat("/esoui/art/icons/u26_ability_digging_02.dds", 22, 22) .. "Ausgrabung",
            DsRGuildLoot_exp_Scrying             = zo_iconFormat("/esoui/art/icons/ability_scrying_02.dds", 22, 22) .. "Spähen",
            DsRGuildLoot_exp_Legerdemain         = zo_iconFormat("/esoui/art/icons/skilllinexp_ledgermain.dds", 22, 22) .. "Lug und Trug",
            DsRGuildLoot_exp_SoulMagic           = zo_iconFormat("/esoui/art/icons/soulgem_006_filled.dds", 22, 22) .. "Seelenmagie",
            DsRGuildLoot_exp_Vampire             = zo_iconFormat("/esoui/art/icons/ability_vampire_007.dds", 22, 22) .. "Vampir",
            DsRGuildLoot_exp_Werewolf            = zo_iconFormat("/esoui/art/icons/ability_werewolf_010.dds", 22, 22) .. "Werwolf",
            DsRGuildLoot_experience_crafting     = "|c00CDCDHandwerk|r",
            DsRGuildLoot_exp_alchemy             = zo_iconFormat("/esoui/art/icons/skilllinexp_alchemy.dds", 22, 22) .. "Alchemie",
            DsRGuildLoot_exp_blacksmithing       = zo_iconFormat("/esoui/art/icons/skilllinexp_blacksmithing.dds", 22, 22) .. "Schmiedekunst",
            DsRGuildLoot_exp_woodworking         = zo_iconFormat("/esoui/art/icons/skilllinexp_woodworking.dds", 22, 22) .. "Schreinerei",
            DsRGuildLoot_exp_clothier            = zo_iconFormat("/esoui/art/icons/skilllinexp_clothier.dds", 22, 22) .. "Schneiderei",
            DsRGuildLoot_exp_enchanting          = zo_iconFormat("/esoui/art/icons/skilllinexp_enchanting.dds", 22, 22) .. "Verzaubern",
            DsRGuildLoot_exp_jewelrymaking       = zo_iconFormat("/esoui/art/icons/skilllinexp_jewelrymaking.dds", 22, 22) .. "Schmuckhandwerk",
            DsRGuildLoot_exp_provisioner         = zo_iconFormat("/esoui/art/icons/skilllinexp_provisioner.dds", 22, 22) .. "Versorgen",
            
            -- Submenu - Notification Beuteverlauf
            DsRGuildLootHistory_Menue             = "Beuteverlauf",
            DsRGuildLootHistory_MenueOnOff        = "|cFFAE42Deaktiviere den angepassten Beuteverlauf|r",
            DsRGuildLootHistory_NLootMS           = "Loot-Anzeigedauer |c808080(Sekunden)|r",
            DsRGuildLootHistory_NLootMSDesc       = "Hierzu zählt alles an Loot, außer Erfahrung, XP etc.",
            DsRGuildLootHistory_PLootMS           = "Erfahrung-, XP-, etc. Anzeigedauer |c808080(Sekunden)|r",
            DsRGuildLootHistory_PLootMSDesc       = "Hierzu zählt alles was aufaddiert wird beim Beuteverlauf, wie Erfahrung, XP etc",
            DsRGuildLootHistory_MaxItem           = "Maximal gleichzeitig angezeigte Elemente",
            DsRGuildLootHistory_ShowMenue         = "Beuteverlauf bei geöffneten Menüs anzeigen",
            DsRGuildLootHistory_ShowSkill         = "|cFFAE42Zeige 'Offene Welt' XP-Fortschritt|r",

            -- Submenu - Handelswerte - Loot
            DsRGuildMenue_trading       = "|c00CDCDHandelswerte|r",
            DsRGuildLoot_trade_chat     = "Im Chat anzeigen",
            DsRGuildLoot_trade_screen   = "Auf dem Bildschirm anzeigen",
            DsRGuildLoot_trade_history  = "Im Beuteverlauf anzeigen",
            DsRGuildLoot_trade_support1 = "|c7393B3Unterstützt werden:|r",
            DsRGuildLoot_trade_support2 = "|cadff2fMasterMerchant (MM), Tamriel Trade Centre (TTC) und Arkadius Trade Tool (ATT)|r",

            -- Submenu - Behälter - Loot
            DsRGuildMenue_Container     = "AutoLoot - Beutel, Rucksack",
            DsRGuildMenue_IC            = "Kaiserstadt",
            DsRGuildMenue_OW            = "Offene Welt",
            DsRGuildMenue_EA            = "Endloses Archiv",
            DsRGuildLoot_FM             = zo_iconFormat(GetItemLinkIcon("|H0:item:197790:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:197790:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_BGR            = zo_iconFormat(GetItemLinkIcon("|H0:item:188144:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:188144:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_BVS            = zo_iconFormat(GetItemLinkIcon("|H0:item:178470:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:178470:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_hAR            = zo_iconFormat(GetItemLinkIcon("|H0:item:150700:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:150700:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_ICversorger    = zo_iconFormat(GetItemLinkIcon("|H0:item:212238:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:212238:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_ICschmied      = zo_iconFormat(GetItemLinkIcon("|H0:item:212249:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:212249:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_ICschneider    = zo_iconFormat(GetItemLinkIcon("|H0:item:212252:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:212252:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_ICalchemi      = zo_iconFormat(GetItemLinkIcon("|H0:item:212251:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:212251:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_ICrunen        = zo_iconFormat(GetItemLinkIcon("|H0:item:212248:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:212248:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_ICholz         = zo_iconFormat(GetItemLinkIcon("|H0:item:212247:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:212247:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_EAschmuck      = zo_iconFormat(GetItemLinkIcon("|H0:item:203205:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:203205:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_EAversorger    = zo_iconFormat(GetItemLinkIcon("|H0:item:203212:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:203212:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_EAschneider    = zo_iconFormat(GetItemLinkIcon("|H0:item:203200:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:203200:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_EAschmied      = zo_iconFormat(GetItemLinkIcon("|H0:item:203199:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:203199:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_EAalchemi      = zo_iconFormat(GetItemLinkIcon("|H0:item:203181:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:203181:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_EArunen        = zo_iconFormat(GetItemLinkIcon("|H0:item:203201:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:203201:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_EAholz         = zo_iconFormat(GetItemLinkIcon("|H0:item:203213:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:203213:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),



        --Options - 'IndexStickerbook'
        DsRGuildBind_autobindloot             = "Automatisch binden beim Aufheben?",
        DsRGuildBind_Iconshowin               = "|cFFAE42Wo soll das Icon|r " .. "|cb81414|t30:30:/esoui/art/collections/collections_tabicon_itemsets_down.dds:inheritcolor|t|r" .. " |cFFAE42angezeigt werden?|r",
        DsRGuildBind_show_bag                 = "Inventar - Rucksack",
        DsRGuildBind_show_bagDesc             = "Zeige Icon in deinem Charakterinventar",
        DsRGuildBind_show_trading             = "Inventar - Handeln",
        DsRGuildBind_show_tradingDesc         = "Zeige Icon wenn Du mit einem anderem Spieler handels",
        DsRGuildBind_show_bank                = "Inventar - Bank",
        DsRGuildBind_show_bankDesc            = "Zeige Icon in deiner persönlichen Bank",
        DsRGuildBind_show_housebank           = "Inventar - Haustruhen",
        DsRGuildBind_show_housebankDesc       = "Zeige Icon in deinen Haustruhen",
        DsRGuildBind_show_guildbank           = "Inventar - Gildenbank",
        DsRGuildBind_show_guildbankDesc       = "Zeige Icon in der Gildenbank",
        DsRGuildBind_show_crafting            = "Inventar - Handwerksstation",
        DsRGuildBind_show_craftingDesc        = "Zeige Icon an Handwerksstation, inklusive des Verwertungsassistenten",
        DsRGuildBind_show_transmute           = "Inventar - Transmutationsstelle",
        DsRGuildBind_show_transmuteDesc       = "Zeige Icon an der Transmutationsstation während der Umwandlung",
        DsRGuildBind_show_guildstore          = "Inventar - Gildenhändler",
        DsRGuildBind_show_guildstoreDesc      = "Zeige Icon in der Suchliste und persönlichen Liste beim Gildenhändler",
        DsRGuildBind_chat_SystemShow          = "Chat - Systemnachricht",
        DsRGuildBind_chat_SystemShowDesc      = "Zeige ein Symbol an, wenn eine Systemmeldung einen Gegenstand enthält, der nicht in deiner Sammlung ist.",
        DsRGuildBind_chat_MessageShow         = "Chat - Chatnachricht",
        DsRGuildBind_chat_MessageShowDesc     = "Zeige ein Symbol an, wenn eine Spieler-Chatnachricht einen Gegenstand enthält, der nicht in deiner Sammlung ist.",
        DsRGuildBind_Iconposition             = "|cFFAE42Ausrichtung des Icon's im Inventar etc|r",
        DsRGuildBind_pos_iconOffset           = "Verschiebung Inventar",
        DsRGuildBind_pos_iconOffsetDesc       = "Horizontale Verschiebung des Icon's im Inventar (ohne Gildenhändler)",
        DsRGuildBind_pos_iconStoreOffset      = "Verschiebung Gildenhändler",
        DsRGuildBind_pos_iconStoreOffsetDesc  = "Horizontale Verschiebung des Icon's beim Gildenhändler",
        DsRGuildBind_req_desc                 = "|cFFAE42Ein paar Werkzeuge für einen einfacheren Handel mit Sammlerausrüstung.|r",
        DsRGuildBind_req_showRequestLink      = "'Könnt ich gebrauchen' Button",
        DsRGuildBind_req_showRequestLinkDesc  = "Zeige einen [Req] Button vor Nachrichten von Spielern an, die Links zu nicht gesammelten Gegenständen enthalten.\nDurch Klicken auf den Button wird automatisch ein Flüstern an diesen Spieler vorbereitet, um die Gegenstände anzufordern.",
        DsRGuildBind_req_requestInWhisper     = "Nachfrage übers Anflüstern?",
        DsRGuildBind_req_requestInWhisperDesc = "Verwende den Flüsterkanal, um Gegenstände vom Spieler anzufordern.\nWenn ausgeschaltet, wird die Nachricht stattdessen im gleichen Kanal wie die ursprüngliche Nachricht vorausgefüllt.",
        DsRGuildBind_req_requestPrefix        = "Nachrichtenpräfix",
        DsRGuildBind_req_requestPrefixDesc    = "Der Nachrichtenpräfix für die Anforderung von Gegenständen über den [Req]-Button. Empfohlene Länge <= 10 Zeichen.",

        --Options - 'IndexAllianceWarGeneral'
            -- Submenu - Tötungen
            DsRGuildMenue_PvPandBGkilling    = zo_iconFormat("/esoui/art/deathrecap/deathrecap_killingblow_icon.dds", 28, 28) .. "|c00CDCDTötungen|r",
            DsRGuildPvP_PvPKillFeedCyro      = "PvP-Todesstöße - Cyrodiil",
            DsRGuildPvP_PvPKillFeedImperial  = "PvP-Todesstöße - Kaiserstadt",
            DsRGuildPvP_KillingBlowScreen    = "Tödlichen Schlag auf dem Bildschirm anzeigen?",
            DsRGuildPvP_KillingBlowChat      = "Tödlichen Schlag im Chat anzeigen?",
            DsRGuildPvP_KillingChatMenue     = "Wen habe ich sonst getötet? (Assist)",
            DsRGuildPvP_KillingChatMenueDesc = "Zeigt dir an, ob Du jemanden getötet hast, ohne tödlichen Schlag!",
            DsRGuildPvP_EnableAnimation      = "Animation über tödlichen Schlag aktivieren?",
            DsRGuildPvP_EnableAnimationDesc  = "Färbt den Bildschirmrand in der ausgewählten Farbe, wenn dein Angriff tödlich war.",
            DsRGuildPvP_ColorAnimation       = "Farbe der Bildschirmanimation",
            DsRGuildPvP_ColorAnimationDesc   = "Wähle die Farbe für die Animation des Bildschirmrandes, beim tödlichen Schlag",

            -- Submenu - Killcounter
            DsRGuildMenue_cyrodiilqueue        = zo_iconFormat("/esoui/art/icons/battleground_medal_killingblow_007.dds", 28, 28) .. "|c00CDCDKill Counter|r",
            DsRGuildMenue_cyrodiilqueueenable  = "Kill Counter anzeigen?",
            DsRGuildMenue_statsBarLocked       = "Position des Kill Counter's sperren",
            DsRGuildMenue_statsBarLockedDesc   = "Wenn EIN, kannst Du den Kill Counter nicht verschieben.\nWenn AUS, kannst Du den Kill Counter überall auf dem Bildschirm verschieben.",
            DsRGuildMenue_hideInPvE            = "Kill Counter nur in PvP-Zonen?",
            DsRGuildMenue_hideInPvEDesc        = "Wenn EIN, wird der Kill Counter ausgeblendet, wenn Du nicht im PvP bist. Bei AUS ist der Kill Counter immer sichtbar.",
            DsRGuildMenue_scoreWindowScale     = "Größe des Kill Counter's in Prozent:",
            DsRGuildMenue_scoreWindowScaleDesc = "Verändert die Größe des Kill Counter's um den angegebenen Prozentsatz",

            -- Submenu - Playercounter
            DsRGuildMenue_cyrodiilCP           = zo_iconFormat("/esoui/art/lfg/lfg_indexicon_group_up.dds", 28, 28) .. "|c00CDCDPlayer Counter|r",
            DsRGuildMenue_cyrodiilCPenable     = "Player Counter anzeigen?",
            DsRGuildMenue_cyrodiilCPUNK        = "Unbekannte Spieler anzeigen?",
            DsRGuildMenue_cyrodiilCPcompl      = "Zeige Statistik der bereits erkannten Spieler",
            DsRGuildMenue_cyrodiilCPenableDesc = "Lasse Dir anzeigen, wieviele Spieler in deiner Nähe sind, egal ob Freund oder Feind/nEr erkennt alle Spieler, die:/n - Kämpfen /n - Fertigkeiten ausführen /n - Du anschaust /n - ... ",
            DsRGuildMenue_cyrodiilCPdebug      = "Debug mode?",
            DsRGuildMenue_cyrodiilCPdebugDesc  = "Sollte auf AUS stehen!!! Nur für Entwickler!",

            -- Submenu - Follow the Crown
            DsRGuildMenue_cyrodiilCrown          = zo_iconFormat("/esoui/art/lfg/lfg_leader_icon.dds", 28, 28) .. "|c00CDCDGruppenleiter|r",
            DsRGuildMenue_cyrodiilCrownPfeil     = "Zeige mir den Weg zum Lead",
            DsRGuildMenue_cyrodiilCrownPfeilSize = "Größe",
            DsRGuildMenue_cyrodiilCrownPfeilPos  = "Position vom HUD?",
            DsRGuildMenue_cyrodiilCrownList      = "Distanzliste der Gruppe zum Lead anzeigen?",
            DsRGuildMenue_cyrodiilCrownPfeilFak  = "Debug: Fake-Krone aktivieren",

            -- Submenu - Allianzpunkte
            DsRGuildPvP_alliancepointsmsg      = zo_iconFormat("/esoui/art/currency/alliancepoints_64.dds", 28, 28) .. "|c00CDCDAllianzpunkte|r",
            DsRGuildPvP_alliancepoints         = zo_iconFormat("/DsRGuildHall/misc/DsR_AP.dds", 26, 26) .. "Erzielte Allianzpunkte anzeigen?",
            DsRGuildPvP_ap_gain                = "Minimum AP-Gewinn zum Anzeigen",
            DsRGuildPvP_ap_repair              = zo_iconFormat("/esoui/art/vendor/vendor_tabicon_repair_down.dds", 26, 26) .. "Reparatur",
            DsRGuildPvP_ap_kills               = zo_iconFormat("/esoui/art/deathrecap/deathrecap_killingblow_icon.dds", 28, 28) .. "Kills",
            DsRGuildPvP_ap_offensechat         = "Eroberungen (Chat)",
            DsRGuildPvP_ap_offensescreen       = "Eroberungen (Bildschirm)",
            DsRGuildPvP_ap_defensechat         = "Verteidigung (Chat)",
            DsRGuildPvP_ap_defensescreen       = "Verteidigung (Bildschirm)",
            DsRGuildPvP_ap_revival             = "Wiederbelebung",
            DsRGuildPvP_ap_awards              = "Auszeichungen / Rank",
            DsRGuildPvP_ap_quest               = zo_iconFormat("/esoui/art/worldmap/map_indexicon_quests_down.dds", 26, 26) .. "Quest",
            DsRGuildPvP_ap_battleground        = zo_iconFormat("/esoui/art/battlegrounds/battlegrounds_tabicon_battlegrounds_down.dds", 26, 26) .. "Platzierung (Schlachtfelder)",

        --Options - 'IndexAllianceWarCyrodiil'
            -- Submenu - Porten
            DsRGuildMenue_cyrodiilPortImp      = zo_iconFormat("/esoui/art/mappins/ava_imperialdistrict_neutral.dds", 28, 28) .. "|c00CDCDKaiserstadt - Port|r",
            DsRGuildPvP_portImperial           = "Port von Cyrodiil in die Kaiserstadt?",
            DsRGuildPvP_portImperialGroup      = "Gruppenport, wenn ich die Krone habe?",

            -- Submenu - Burgtore
            DsRGuildMenue_cyrodiildoor              = zo_iconFormat("/DsRGuildHall/misc/DsR_CastleDoor.dds", 28, 28) .. "|c00CDCDBurgtore|r",
            DsRGuildMenue_cyrodiildoorOnOff         = "Burgtore anzeigen?",
            DsRGuildMenue_cyrodiildoorpintint       = "Farbe",
            DsRGuildMenue_cyrodiildoorpintintDesc   = "Farbe für die MapPins der Burgentore auf der Karte",
            DsRGuildMenue_cyrodiildoorpintsize      = "Größe",
            DsRGuildMenue_cyrodiildoorpintsizeDesc  = "Lege die Größe der Burgtore auf der Karte fest",
            DsRGuildMenue_cyrodiildoorpintlayer     = "Layer",
            DsRGuildMenue_cyrodiildoorpintlayerDesc = "Pins mit höheren Nummern werden über Pins mit niedrigeren Nummern gezeichnet.\nErhöhen Sie die Pin-Ebene, damit sie über anderen Pin-Typen angezeigt wird.\nBeispiele: Quests 110, Gruppenmitglieder 130, Wegschreine 140, Spieler 160.",
 
            -- Submenu - Burginfo
            DsRGuildMenue_cyroposition              = zo_iconFormat("esoui/art/mappins/ava_largekeep_neutral.dds", 28, 28) .. "|c00CDCDBurginfo|r",
            PvPKeepInfo_enabled                     = "Burginformationen deaktivieren",
            PvPKeepInfo_updatetimer                 = "Updateinterval",
            PvPKeepInfo_updatetimerDesc             = "Wie oft soll deine Position abgefragt werden\nDefault: 1 Sekunde",
            PvPKeepInfo_showBGtransparent           = "Hintergrund transparent?",
           
            -- Submenu - Kampfgeschehen
            DsRGuildMenue_cyrowar                   = zo_iconFormat("/esoui/art/icons/servicemappins/servicepin_fightersguild.dds", 28, 28) .. "|c00CDCDKampfgeschehen|r",
            DsRGuildPvPstatus_enabled               = "Aktiviert",
            DsRGuildPvPstatus_positionfixed         = "Position fixiert" .. zo_iconFormat("/esoui/art/progression/progression_crafting_locked_up.dds", 26, 26),
            DsRGuildPvPstatus_showBGtransparent     = "Hintergrund transparent?",
            DsRGuildPvPstatus_hideworldmap          = "Auf Weltkarte unsichtbar",
            DsRGuildPvPstatus_showflags             = "Zeige Flaggen" .. zo_iconFormat("/esoui/art/compass/ava_flagneutral.dds", 26, 26),
            DsRGuildPvPstatus_showsieges            = "Zeige Belagerungen" .. zo_iconFormat("/esoui/art/compass/compass_bg_flagattack_pin.dds", 26, 26),
            DsRGuildPvPstatus_showownerchanges      = "Zeige Zeit für Burgendrehzeit",
            DsRGuildPvPstatus_showactiontimers      = "Zeige Zeit bis AP-Punkte",
            DsRGuildPvPstatus_colordefault          = "Standardfarbe",
            DsRGuildPvPstatus_colorcooldown         = "Abklingfarbe",
            DsRGuildPvPstatus_colorflipspositive    = "Positive Flaggendrehfarbe",
            DsRGuildPvPstatus_colorflipsnegative    = "Negative Flaggendrehfarbe",
            DsRGuildPvPstatus_showkeeps             = zo_iconFormat("/esoui/art/compass/ava_largekeep_neutral.dds", 26, 26) .. "Zeige Burgen",
            DsRGuildPvPstatus_showoutposts          = zo_iconFormat("/esoui/art/compass/ava_outpost_neutral.dds", 26, 26) .. "Zeige Außenposten",
            DsRGuildPvPstatus_showresources         = zo_iconFormat("/esoui/art/mappins/ava_lumbermill_neutral.dds", 28, 28) .. "Zeige Ressourcen",
            DsRGuildPvPstatus_showvillages          = zo_iconFormat("/esoui/art/compass/ava_town_neutral.dds", 26, 26) .. "Zeige Dörfer",
            DsRGuildPvPstatus_showtemples           = zo_iconFormat("/esoui/art/compass/ava_artifacttemple_ebonheart.dds", 26, 26) .. "Zeige Tempel",
            DsRGuildPvPstatus_showdestructibles     = zo_iconFormat("/esoui/art/mappins/ava_milegate_passable.dds", 28, 28) .. "Zeige Zerstörbares",

        --Options - 'IndexAllianceWarImpCity'
        DsRGuildMenue_ImperialCityDistrict     = "|cFFAE42Kanalisationseingänge / Bezirksnamen anzeigen?|r",
        DsRGuildMenue_ImperialCityDistrictDesc = "Kanalisationseingänge auf der Karte der Kaiserstadt beschriften.",
        DsRGuildMenue_ImperialCitySewers       = "|cFFAE42Bezirksnamen an Leitern anzeigen?|r",
        
            -- Submenu - Telvar Steine
            DsRGuildPvP_ap_telvarmsg            = zo_iconFormat("/esoui/art/hud/telvar_meter_currency.dds", 28, 28) .. "|c00CDCDTelvar Steine|r",
            DsRGuildPvP_ap_telvar               = "Erzielte Telvar Steine anzeigen?",
            DsRGuildPvP_ap_telvartxt            = "Ab welchen Wert soll ich Dir es zeigen?",
            DsRGuildPvP_ap_telvarSaver          = "Autom. Cyro-Porten, wenn Telvar-Steine über:",
            DsRGuildPvP_ap_telvarSaverDesc      = "Du wirst automatisch in Deine Heimat-Cyrodill-Kampagne oder eine zufällige Cyrodill-Kampagne reingeportet, wenn Du dich in der Kaiserstadt befindest und die angegebene Menge überschritten wurde. Um dies auszuschalten, setze die Zahl auf 0.",
            DsRGuildPvP_ap_telvarSaverGroup     = "Gruppenport, wenn ich die Krone habe?",
            DsRGuildPvP_ap_telvarSaverGroupDesc = "Wenn Du der Gruppenleiter bist, wird die gesamte Gruppe automatisch in die Warteschlange gestellt.",
            DsRGuildPvP_telVarSaverU49          = "|cadff2fDas Porten in die Mainbase um die TelVar-Steine zu sichern, über /dsrport oder ein Taste möglich.|r",
            DsRGuildPvP_telVarSaverU49a         = "|cb81414ACHTUNG!!|r |H0:item:68347:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h |cb81414wird benötigt|r",
            
            -- Submenu - Bosstimer
            DsRPvPBossTimer_BossTimerMenue       = zo_iconFormat("/esoui/art/miscellaneous/timer_32.dds", 28, 28) .. "|c00CDCDStatus & Bosstimer|r",
            DsRPvPBossTimer_OPTION_TIMETABLE     = "Status & Bosstimer anzeigen",
            DsRPvPBossTimer_OPTION_MAPTIMERS     = "  - Bosstimer auf Kaiserstadt Karte",
            DsRPvPBossTimer_OPTION_MAPTIMERSDesc = "Deaktiviert den Zoom auf der Kaiserstadt Karte.\nFunktioniert nicht im Gamepad-Modus!",
            DsRPvPBossTimer_OPTION_EVENT_TIMERS  = "Event Timer (7 Minuten)",

            DsRGuildPvP_GoldScamp                = zo_iconFormat("DsRGuildHall/misc/DsR_Scamp.dds", 28, 28) .. "|c00CDCDList-/Gierskamp|r",
            DsRGuildPvP_GoldScampOnOff           = "Zeige die Positionen der Skamps an",

        --Options - 'IndexGroupRaid'
            -- Submenu - Tabelle des Todes
            DsRGuildDeathTable_SubMenu         = "|c00CDCDTabelle des Todes|r",
            DsRGuildDeathTable_GroupJoin       = "Tabelle beim Gruppenbeitritt anzeigen",
            DsRGuildDeathTable_GroupJoinDesc   = "Wenn diese Option aktiviert ist, wird die „Tabelle des Todes“ angezeigt, wenn Du einer Gruppe beitritts. Wenn diese Option deaktiviert ist, ändert sich der Status der Liste nicht.",
            DsRGuildDeathTable_GroupLeave      = "Tabelle beim Verlassen der Gruppe ausblenden",
            DsRGuildDeathTable_GroupLeaveDesc  = "Wenn die Option aktiviert ist, wird die 'Tabelle des Todes' ausgeblendet, wenn Du die Gruppe verlässt. Wenn diese Option deaktiviert ist, ändert sich der Status der Liste nicht.",
            DsRGuildDeathTable_ResetTable      = "Tabelle zurücksetzen beim Gruppenbeitritt",
            DsRGuildDeathTable_ResetTableDesc  = "Wenn diese Option aktiviert ist, wird die „Tabelle des Todes“ zurückgesetzt, wenn Du einer Gruppe beitritts. Wenn diese Option deaktiviert ist, bleiben die Daten beim Beitritt in die Gruppe unverändert.",
            DsRGuildDeathTable_bgAlpha         = "Stärke des Hintergrundes",
            DsRGuildDeathTable_bgAlphaDesc     = "Passe die Transparenz des Hintergrundes an. 0 = Ausgeblendet",
            DsRGuildDeathTable_Color           = "Benutzerdefinierte Farben",
            DsRGuildDeathTable_ColorTitle      = "Titelfarbe",
            DsRGuildDeathTable_ColorTitleDesc  = "Ändere die Farbe des Namens von der 'Tabelle des Todes'.",
            DsRGuildDeathTable_ColorPlayer     = "Spieler",
            DsRGuildDeathTable_ColorPlayerDesc = "Ändere die Farbe der Namen in der 'Tabelle des Todes'.",
            DsRGuildDeathTable_ColorCount      = "Todeszähler",
            DsRGuildDeathTable_ColorCountDesc  = "Ändere die Farbe der Nummern des Todeszähler in der 'Tabelle des Todes'.",
            DsRGuildDeathTable_Lenght          = "Länge",
            DsRGuildDeathTable_LenghtDESC      = "|cFFAE42Hier kannst Du einstellen, wieviele Tode der Zähler anzeigt,|r",
            DsRGuildDeathTable_LenghtDESC1     = "|cFFAE42bevor dieser sich in ein Scroll-Fenster verwandelt.|r",
            DsRGuildDeathTable_LenghtSlid      = "Länge auf dem Bildschirm",
            DsRGuildDeathTable_LenghtSlidDesc  = "10 = Wäre die optimale Länge für 12er Gruppen",

            -- Submenu - Schatztruhen
            DsRGuildMenue_TreasureFound   = "|c00CDCDSchatztruhen|r",
            DsRGuildLootChest_Desc1       = "|cFFAE42Sobald Du eine Schatztruhe findest und im Dungeon / Raid,sowie in einer Gruppe bist,|r",
            DsRGuildLootChest_Desc2       = "|cFFAE42kannst Du durch '|cFFAE42Enter|r' |cFFAE42drücken, die gefundene Schatztruhe mitteilen, sobald du sie benutzt|r",
            DsRGuildLootChest_Desc3       = "|cFAA0A0(Achtung! Die Möglichkeit taucht nur auf, wenn die Kiste noch verschlossen ist)|r",
            DsRGuildLootChest_MenueOnOff  = "Aktiviere Gruppen-Chatnachricht",
            DsRGuildLootChest_OnlyEN      = "Nur auf Englisch?",
            DsRGuildLootChest_OnlyENDesc  = "Option nur für die deutsche Spielversion",

            -- Submenu - GroupAttack
            DsRGuildMenue_GroupAttack         = "|c00CDCDGruppenattacke|r",
            DsRGuildGroupAttackTimer          = "Von wieviel Sekunden soll gestartet werden?",
            DsRGuildGroupAttack_FRIENDLYNAME  = "Gruppenattacke",
            DsRGuildGroupAttack_DESCRIPTION   = "Erlaubt es dir Attacken countdowns an deine Gruppe zu senden.",
            DsRGuildGroupAttack_NOT_LEADER    = "|c9fb6cd[DsR-GroupAttack]|r |cFF0000Du musst der Gruppenleiter sein um einen Countdown zu starten!",
            DsRGuildGroupAttack_COMMAND_HELP  = "Startet einen Pull Countdown.",
            DsRGuildGroupAttack_Desc1         = "|cFAA0A0Achtung! Die Gruppenattacke kann nur als Gruppenleiter gestartet werden|r",
            DsRGuildGroupAttack_Desc2         = "|cFFA500Info: Du kannst den Countdown im Chat mit|r '/dsrattack' |cFFA500oder über eine Tastenzuweisung starten|r",


        --Options - 'IndexGroupBuff'
        DsRGuildMenue_Buffs           = "|c00CDCDBuffs|r",
        DsRGuildMenue_BuffsDesc       = "|cadff2fLasse Dir eine Liste der aktiven Buffs anzeigen|r",
        DsRGuildMenue_BuffsEnable     = "|cFFAE42Aktiviere die Liste|r",
        DsRGuildMenue_BuffsTxtOnOff   = "Buff-Bezeichnung ausblenden",
        DsRGuildMenue_BuffsTxtSize    = "Buff-Bezeichnung - Größe",
        DsRGuildMenue_BuffsTxtCol     = "Buff-Bezeichnung - Farbe",
        DsRGuildMenue_BuffsBarColor   = "Farbe der Progressbar",
        DsRGuildMenue_BuffsBarMultiCol = "Unterschiedliche Farben der Progressbar?",
        DsRGuildMenue_BuffsBarShield   = "Farbe der Progressbar - Schild",
        DsRGuildMenue_BuffsBarHeal     = "Farbe der Progressbar - Heilung",
        DsRGuildMenue_BuffsBarDamage   = "Farbe der Progressbar - Schaden",
        DsRGuildMenue_BuffsBarUlti     = "Farbe der Progressbar - Ulti",
        DsRGuildMenue_BuffsBarSelfBuff = "Farbe der Progressbar - Eigene-Buffs",
        DsRGuildMenue_BuffsBarGroupBuff = "Farbe der Progressbar - Gruppen-Buffs",
        DsRGuildMenue_BuffsBarOtherBuff = "Farbe der Progressbar - Alle anderen Buffs",
        DsRGuildMenue_BuffsBarDefault   = "Farbe der Progressbar - Nicht zugeordnete",
        DsRGuildMenue_BuffsDDSSize    = "Größe der Icons",
        DsRGuildMenue_BuffsTimerCol   = "Farbe des Timerzahl (im Icon)",
        DsRGuildMenue_BuffsCountCol   = "Farbe des Gruppencounters",
        DsRGuildMenue_BuffsCountSiz   = "Größe des Gruppencounters",
        DsRGuildMenue_BuffsWhitelist  = "|c00FF00Anzuzeigende Buffs (Whitelist)|r",
        DsRGuildMenue_BuffsWhiteDesc  = "Die Zahlen müssen immer mit einem |cFFA500KOMMA|r getrennt werden",
        DsRGuildMenue_BuffsWhiteDesc1 = "Die Reihenfolge auf der UI, ist die Reihenfolge in der Liste",
        DsRGuildMenue_BuffsWhiteRaid  = "Einstellung der Whitelist-Orte gem. Characterauswahl",
        DsRGuildMenue_BuffsSelectMenu = "|c00FF00Übersicht der Buff-ID's|r",
        DsRGuildMenue_BuffsIDAnalyse  = "|c00CDCDDsR Buff-Analyse|r",
        DsRGuildMenue_BuffsIDinfo     = "Suche Dir die passenden ID's raus für deine Buffliste",
        DsRGuildMenue_BuffsCheckClean = "|cFF0000Prüfe Liste auf Doppelte|r",
        DsRGuildMenue_BuffsTableRowMax = "Anzahl der Buffs, bis eine weitere Spalte erstellt wird",
        DsRGuildMenue_BuffsSettingMenu = "|c00FF00Buff-Management|r",
        DsRGuildMenue_BuffsSettingBUT  = "|c00CDCDDsR Buff-Management|r",
        DsRGuildMenue_BuffsSettingINFO = "Öffne das Buff-Management Fenster",
        DsRGuildMenue_BuffsSettingINFO1 = "|cFFA500Info: Du kannst es auch im Chat mit|r '/dsrbuff' |cFFA500oder über eine Tastenzuweisung öffnen|r",

        -- Options - Licht des Zusammenhalts
        DsRGuildMenue_beams                            = "Licht des Zusammenhalts",
        DsRGuildMenue_BeamAttention                    = "|cFAA0A0Subsampling-Qualität muss auf >>Hoch<< sein. Ansonsten funktioniert dieses Modul nicht richtig.|r",
        DsRGuildMenue_BeamAttention2                   = "|cFAA0A0Die |c35fc38[Temporäre] |cFAA0A0Einhüllung geht nicht in: Städten, Schlachtfeld und Kaiserstadt|r",
        DsRGuildBeam_LightEnabled                      = "|cFFAE42Umhülle dein Team mit dem Licht|r",
        DsRGuildBeam_LightEnabledDesc                  = "Rufe das Licht des Zusammenhalts herbei für ihre Segnungen des Gruppensupports..",
        DsRGuildBeam_LightEnabledTEMP                  = "|c35fc38[TEMPORÄR] Umhülle dein Char mit Licht|r",
        DsRGuildBeam_LightEnabledTEMPDesc              = "Rufe das Licht des Zusammenhalts herbei für die Einstellungen\nWird spätestens nach den RELOADUI oder Beenden deaktiviert",
        DsRGuildBeam_LightEnabledTEMPRGB               = "|c35fc38[TEMPORÄR] Welche Farbe soll es sein?|r",
        DsRGuildBeam_LightCombatOnly                   = "Nur während des Kampfes " .. zo_iconFormat("/esoui/art/progression/progression_tabicon_combatskills_down.dds", 28, 28) ..  "  anzeigen",
        DsRGuildBeam_LightCombatOnlyDesc               = "Das Licht des Zusammenhalts wird nur während des Kampfes erscheinen.",
        DsRGuildBeam_LightAlpha                        = "Die Strahlkraft ihres Lichts.",
        DsRGuildBeam_LightAlphaDesc                    = "Passe die göttliche Strahlkraft an, mit der das Licht des Zusammenhalts leuchtet.",
        DsRGuildBeam_LightTyp                          = "Aussehen des Lichts",
        DsRGuildBeam_LightHeight                        = "Länge des Lichts",
        DsRGuildBeam_LightHeightDesc                    = "Reguliere die Länge des Lichts des Zusammenhalts.",
        DsRGuildBeam_LightScale                        = "Breite des Lichts",
        DsRGuildBeam_LightScaleDesc                    = "Reguliere die Breite des Lichts des Zusammenhalts.",
        DsRGuildBeam_LightAlwaysIgnoresDepthBuffer     = "Licht NICHT durch Hindernisse verdecken?",
        DsRGuildBeam_LightAlwaysIgnoresDepthBufferDesc = "Mit dem Auschalten, wird das Licht an Hindernissen unterbrochen\nStandard = AUS",
        DsRGuildBeam_LightOwn                          = "Eigenen " .. zo_iconFormat("/esoui/art/charactercreate/charactercreate_faceicon_down.dds", 28, 28) ..  " auch in Licht hüllen?",
        DsRGuildBeam_HeaderTWO                         = zo_iconFormat("/esoui/art/deathrecap/deathrecap_killingblow_icon.dds", 28, 28) .. "|c00CDCDLicht der Gefallenen...|r",
        DsRGuildBeam_LightDeadONOFF                    = "Bei Gefallenen anzeigen?",
        DsRGuildBeam_LightDead                         = "... bei Toten anzeigen",
        DsRGuildBeam_LightDeadDesc                     = "Zeige das strahlende Licht auf gefallenden Gruppenmitgliedern.",
        DsRGuildBeam_LightDeadColor                    = "   -> Farbe",
        DsRGuildBeam_LightBeingResurrecting            = "... bei aktiver Wiederbelebung anzeigen",
        DsRGuildBeam_LightBeingResurrectingDesc        = "Zeige das strahlende Licht des Zusammenhalts auf gefallenden Gruppenmitgliedern an, die gerade eine Wiederbelebung erhalten.",
        DsRGuildBeam_LightResurrecting                 = "... bei aktiver/erfolgreicher Wiederbelebung anzeigen",
        DsRGuildBeam_LightResurrectingDesc             = "Zeige das strahlende Licht des Zusammenhalts auf gefallenden Gruppenmitgliedern an, die erfolgreich Wiederbelebt wurden.",
        DsRGuildBeam_HeaderTHREE                       = zo_iconFormat("/esoui/art/icons/u38_housing_meridialights.dds", 28, 28) .. "|c00CDCDLicht der Champions auf ...|r",
        DsRGuildBeam_HeaderTHREE_desc                  = "|cFFAE42Zeige das Licht des Zusammenhalts auf einzelne Gruppenmitgliedern gemäß Rolle an|r",
        DsRGuildBeam_HighlightLeaderONOFF              = "Gesonderte Farbe unabhängig der Rolle",
        DsRGuildBeam_HighlightLeader                   = "Gruppenleiter",
        DsRGuildBeam_HighlightTanks                    = "Tank",
        DsRGuildBeam_HighlightHealers                  = "Heiler",
        DsRGuildBeam_HighlightDDs                      = "DD",
        DsRGuildBeam_HeaderFOUR                        = zo_iconFormat("/esoui/art/icons/poi/poi_wayshrine_complete.dds", 28, 28) .. "|c00CDCDOrte des Lichts...|r",
        DsRGuildBeam_LightGroupMembers                 = "Strahle Licht auf andere Gruppenmitgliedern",
        DsRGuildBeam_LightGroupMembersDesc             = "Lasst das strahlende Licht des Zusammenhalts von allen anderen Gruppenmitgliedern in den unten aufgeführten Szenarien erstrahlen.",
        DsRGuildBeam_LightBattlegroundTeam             = "Schlachtfeld",
        DsRGuildBeam_LightBattlegroundTeamDesc         = "Lasst das strahlende Licht des Zusammenhalts auf die Gruppenmitgliedern im Schlachtfeld erstrahlen.",
        DsRGuildBeam_LightCyrodiilTeam                 = "Cyrodiil",
        DsRGuildBeam_LightCyrodiilTeamDesc             = "Lasst das strahlende Licht des Zusammenhalts auf die Gruppenmitgliedern in Cyrodiil erstrahlen.",
        DsRGuildBeam_LightImperialCityTeam             = "Kaiserstadt",
        DsRGuildBeam_LightImperialCityTeamDesc         = "Lasst das strahlende Licht des Zusammenhalts auf die Gruppenmitgliedern in der Kaiserstadt erstrahlen.",
        DsRGuildBeam_LightNonPVPTeam                   = "Offene Welt",
        DsRGuildBeam_LightNonPVPTeamDesc               = "Lasst das strahlende Licht des Zusammenhalts auf die Gruppenmitgliedern in der offenen Welt erstrahlen",
        DsRGuildBeam_LightRAIDTeam                     = "Verlies / Prüfung",
        DsRGuildBeam_LightRAIDTeamDesc                 = "Lasst das strahlende Licht des Zusammenhalts auf die Gruppenmitgliedern im Verlies / Prüfung erstrahlen",
        DsRGuildBeam_HeaderFIVE                        = zo_iconFormat("/DsRGuildHall/misc/DsR_Leader.dds", 28, 28) .. " |c00CDCDGruppenleiter...|r",

        --Options - 'IndexAchievTrack'
        DsRGuildAchievTracker_Desc1                       = "|cFFAE42Die folgenden Einstellungen sind|r Accountweit",
        DsRGuildAchievTracker_Desc2                       = "|cFFAE42Die zu Verfolgungen jedoch|r Charactergebunden",
        DsRGuildAchievTracker_OnOff                       = "Errungenschaftsverfolgung deaktivieren",
        DsRGuildAchievTracker_Lock                        = "Position sperren" .. zo_iconFormat("/esoui/art/progression/progression_crafting_locked_up.dds", 26, 26),
        DsRGuildAchievTracker_LockDesc                    = "Macht das Fenster unbeweglich und an seiner Position fixiert.",
        DsRGuildAchievTracker_ShowIcons                   = "Icons anzeigen",
        DsRGuildAchievTracker_ShowIconsDesc               = "Zeigt das entsprechende Symbol links neben dem Namen der Errungenschaft an.",
        DsRGuildAchievTracker_Show_Desc                   = "Beschreibung anzeigen",
        DsRGuildAchievTracker_Show_DescDesc               = "Zeigt den Beschreibungstext unter dem Namen an. Ausschalten, um Platz zu sparen.",
        DsRGuildAchievTracker_hideOldZoneAchievements     = "Nur Errungenschaften fürs aktuelle Gebiet zeigen",
        DsRGuildAchievTracker_hideOldZoneAchievementsDesc = "Blendet automatisch Errungenschaften aus welche nicht dem aktuellen Gebiet entsprechend.",
        DsRGuildAchievTracker_maxTracked                  = "Maximum an Verfolgbaren",
        DsRGuildAchievTracker_maxTrackedDesc              = "Passt die maximale Anzahl der verfolgten Errungenschaften an.\nEine 0 bedeutet unbegrenzt.",
        DsRGuildAchievTracker_fontSizeName                = "Schriftgröße - Name",
        DsRGuildAchievTracker_fontSizeNameDesc            = "Passe die Schriftgröße des Namens der Errungenschaft an",
        DsRGuildAchievTracker_fontSize_Desc               = "Schriftgröße - Beschreibung",
        DsRGuildAchievTracker_fontSize_DescDesc           = "Passe die Schriftgröße der Beschreibung der Errungenschaft an",

        --Options - 'IndexCrafting'
        DsRGuildCrafting_DailyHeader    = "|c00CDCDAlchemie, Versorger - Daily's|r",
        DsRGuildCrafting_Alchemy        = zo_iconFormat("/esoui/art/icons/skilllinexp_alchemy.dds", 26, 26) .. "autom. Herstellung von Alchemie",
        DsRGuildCrafting_Provision      = zo_iconFormat("/esoui/art/icons/skilllinexp_provisioner.dds", 26, 26) .. "autom. Herstellung von Speis und Trank",
        DsRGuildCrafting_PrecraftHeader = "|c00CDCDRüstung und Schmuck - Vorrausschauend|r",
        DsRGuildCrafting_Precraft_DESC1 = "|cFFAE42Du kannst für die täglichen Handwerks-Daily's Rüstung und Schmuck für 'X'-Tage herstellen.|r",
        DsRGuildCrafting_Precraft_DESC2 = "|cFFAE42/dsrcraft [ZAHL] |cFAA0A0= Stellt für die gewünschte Anzahl von Rotationen, Gegenstände für ausgewählte|r",
        DsRGuildCrafting_Precraft_DESC3 = "|cFAA0A0Tagesaufträge her. Eine Rotation ist ein 3-Tages-Zyklus für einen bestimmten Beruf.|r",
        
        --Options - 'IndexInventoryManager'
        DsRGuildInventory_InvOnOff             = "|cFFAE42Deaktiviere den Inventar Manager|r",
        DsRGuildInventory_GeneralSettings      = "|c00CDCDAllgemeine Einstellungen|r",
        DsRGuildInventory_DefaultSettings      = "|cFAA0A0Standardeinstellungen der Filter beim Login oder nach dem /reloadui:|r",
        DsRGuildInventory_ShowOnlyLoots        = "Zeige nur Loot an",
        DsRGuildInventory_ShowCraftedSets      = "Zeige hergestellte Set's" .. zo_iconFormat("/esoui/art/inventory/inventory_tabicon_crafting_up.dds", 32, 32),
        DsRGuildInventory_ShowTradeableSets    = "Zeige handelbare Set's" .. zo_iconFormat("/esoui/art/guild/ownership_icon_guildtrader.dds", 32, 32),
        DsRGuildInventory_ShowBoundSets        = "Zeige gebundene Set's" .. zo_iconFormat("/esoui/art/worldmap/map_indexicon_key_up.dds", 32, 32),
        DsRGuildInventory_ShowMonsterSets      = "Zeige Monster-Set's" .. zo_iconFormat("/esoui/art/leveluprewards/levelup_veteran.dds", 32, 32),
        DsRGuildInventory_ShowOtherItems       = "Zeige andere Gegenstände",
        DsRGuildInventory_WindowSettings       = "|c00CDCDInventarfenster Einstellungen|r",
        DsRGuildInventory_ShowWinInventar      = "Zeige den Manager im Inventarfenster an",
        DsRGuildInventory_ShowWinInventarDesc  = "Soll der InventarManager automatisch angezeigt werde, sobal Du ins Inventar gehst?",
        DsRGuildInventory_ShowItemPrice        = zo_iconFormat("/DsRGuildHall/misc/tradehammer.dds", 26, 26) .. "Zeige Verkaufspreis an",
        DsRGuildInventory_ShowItemEnchantments = zo_iconFormat("/esoui/art/inventory/gamepad/gp_inventory_icon_craftbag_enchanting.dds", 26, 26) .. "Zeige Verzauberungen an",
        DsRGuildInventory_ShowNonCP160         = "Zeige an 'nonCP160 - Gegenstände' die Stufe an",
        DsRGuildInventory_BagNameWidth         = "Breite des Inventarortes",
        
        --Options - 'IndexTradingPrice'
        DsRGuildPrice_PriceOnOff                = "|cFFAE42Deaktiviere die Preisanzeige|r",
        DsRGuildPrice_FormatSettings            = "|c00CDCDFormateinstellungen|r",
        DsRGuildPrice_Thousandsep               = "Tausendertrennzeichen",
        DsRGuildPrice_ThousandsepDesc           = "Trennzeichen zum Aufteilen von Tausenderwerten",
        DsRGuildPrice_RoundPrice                = "Runde Preis",
        DsRGuildPrice_ToolTipColor              = "Farbe Tooltip",
        DsRGuildPrice_ToolTipInfoColor          = "Farbe Tooltipinfo",
        DsRGuildPrice_TooltipLineSpacing        = "Zeilenabstand für Tooltips",
        DsRGuildPrice_TooltipLineSpacingDesc    = "Ändere den Abstand für jede Tooltip-Zeile",
        DsRGuildPrice_SubMenueBoundItem         = zo_iconFormat("/esoui/art/collections/collections_categoryicon_locked_up.dds", 26, 26) .. "|c00CDCDGebundene Gegenstände|r",
        DsRGuildPrice_SubMenueTooltipFont       = zo_iconFormat("/esoui/art/crafting/sketches_tabicon_up.dds", 26, 26) .. "|c00CDCDTooltip Schriftart|r",
        DsRGuildPrice_SubMenueContextMenu       = zo_iconFormat("/esoui/art/tradinghouse/tradinghouse_listings_tabicon_up.dds", 26, 26) .. "|c00CDCDKontextmenü|r",
        DsRGuildPrice_SubMenueLowPriceIndi      = zo_iconFormat("/esoui/art/miscellaneous/gamepad/gp_scrollarrow.dds", 26, 26) .. "|c00CDCDHinweis auf Tiefstpreis|r",
        DsRGuildPrice_SubMenueOverridePrice     = zo_iconFormat("/esoui/art/bank/gamepad/gp_bank_menuicon_gold_deposit.dds", 26, 26) .. "|c00CDCDPreisüberschreibung|r",
        DsRGuildPrice_SubMenuePriceSettings     = zo_iconFormat("/DsRGuildHall/misc/tradehammer.dds", 26, 26) .. "|c00CDCDHandelspreise|r",
        DsRGuildPrice_SubMenueDoubleTooltip     = "|c00CDCDTooltip FIX|r",
        DsRGuildPrice_DoubleFix                 = "Doppelte Tooltipeintrag entfernen",
        DsRGuildPrice_BountVendorPrice          = "Verkaufspreis im Grid",
        DsRGuildPrice_BountVendorPriceDesc      = "Berechnet den Verkäuferpreis für gebundene Artikel im Grid",
        DsRGuildPrice_BountIndicator            = "Hinweissymbol (*) anzeigen",
        DsRGuildPrice_BountIndicatorColor       = "Farbe Hinweissymbol (*)",
        DsRGuildPrice_TooltipFont               = "Tooltip Schriftart",
        DsRGuildPrice_TooltipFontDesc           = "Schriftart für den Preis im Tooltip",
        DsRGuildPrice_TooltipinfoFont           = "Tooltip Info Schriftart",
        DsRGuildPrice_TooltipinfoFontDesc       = "Schriftart für die Info im Tooltip",
        DsRGuildPrice_ContextMenuUse            = "|c9fb6cd[DsR-Price]|r-Menü aktivieren",
        DsRGuildPrice_ContextMenuColor          = "Kontextmenü Farbe",
        DsRGuildPrice_LowPriceIndiTooltip       = "Hinweissymbol (*) im Tooltip",
        DsRGuildPrice_LowPriceIndiTooltipDesc   = "Zeigt ein Hinweis auf Tiefstpreis im Tooltip an, wenn der Preis niedriger oder gleich dem Händlerpreis ist",
        DsRGuildPrice_LowPriceIndiGrid          = "Hinweissymbol (*) im Grid",
        DsRGuildPrice_LowPriceIndiGridDesc      = "Funktioniert, wenn 'Verkaufspreis im Grid' aktiviert ist",
        DsRGuildPrice_LowPriceIndiColor         = "Farbe Hinweissymbol (*)",
        DsRGuildPrice_OverridePriceGrid         = "Überschreibe Preise im Grid",
        DsRGuildPrice_OverridePriceGridDesc     = "Überschreibt den Preis vom Gegenstand im Grid",
        DsRGuildPrice_OverridePriceGridBeh      = "Welcher Preis soll genommen werden",
        DsRGuildPrice_OverridePriceGridBehDesc  = "Lege fest, welcher Preis verwendet werden soll.\n(Das entsprechende Addon muss natürlich aktiviert sein)",
        DsRGuildPrice_OverridePriceFirstOn      = "Aktiviere Einzelpreis (obere Position)",
        DsRGuildPrice_OverridePriceFirstOnDesc  = "Zeige den Einzelpreis im Grid (obere Position)",
        DsRGuildPrice_OverridePriceSecondOn     = "Aktiviere Gesamtpreis (untere Position)",
        DsRGuildPrice_OverridePriceSecondOnDesc = "Zeige den Gesamtpreis im Grid (untere Position)",
        DsRGuildPrice_OverridePriceSwitch       = "Vertausche Einzelpreis und Gesamtpreis",
        DsRGuildPrice_OverridePriceSwitchDesc   = "Zeigen Sie im Raster den Einzelpreis oben und den Gesamtpreis unten an",
        DsRGuildPrice_PriceSettingsVendor       = "Zeige Händlerpreis im Tooltip",
        DsRGuildPrice_PriceSettingsRound        = "Runde auf nächsten vollen Wert",
        DsRGuildPrice_SubMenueTTCsettings       = "|cadff2fTamriel Trade Centre (TTC)|r",
        DsRGuildPrice_TTCuse                    = "|cFFAE42Verwende TTC-Preise|r",
        DsRGuildPrice_TTCscale                  = "Skaliere den TTC-Preis",
        DsRGuildPrice_TTCscaleDesc              = "Skaliere den TTC-Preis in Prozent (%)",
        DsRGuildPrice_TTCalternatscale          = "Skalierung Durchschnittspreis",
        DsRGuildPrice_TTCalternatscaleDesc      = "Skaliere den alternativen TTC-Durchschnittspreis in Prozent (%)",
        DsRGuildPrice_TTCalternat               = "TTC-Durchschnittspreis",
        DsRGuildPrice_TTCalternatDesc           = "Alternativen durchschnittlichen TTC-Preis festlegen, wenn kein vorgeschlagener TTC-Preis vorhanden ist",
        DsRGuildPrice_TTCalternatColor          = "Farbe TTC-Durchschnittspreis",
        DsRGuildPrice_TTCalternatColorDesc      = "Überschreibt einige Farben, wenn der Preis den alternativen durchschnittlichen TTC-Preis beinhaltet",
        DsRGuildPrice_TTCtooltip                = "Zeige TTC-Preis im Tooltip",
        DsRGuildPrice_TTCtooltipOri             = "Originalen TTC-Preis im Tooltip",
        DsRGuildPrice_SubMenueMMsettings        = "|cadff2fMaster Merchant (MM)|r",
        DsRGuildPrice_MMuse                     = "|cFFAE42Verwende MM-Preise|r",
        DsRGuildPrice_MMscale                   = "Skaliere den MM-Preis",
        DsRGuildPrice_MMscaleDesc               = "Skaliere den MM-Preis in Prozent (%)",
        DsRGuildPrice_MMtooltip                 = "Zeige MM-Preis im Tooltip",
        DsRGuildPrice_MMtooltipOri              = "Originalen MM-Preis im Tooltip",
        DsRGuildPrice_SubMenueATTsettings       = "|cadff2fArkadius Trade Tool (ATT)|r",
        DsRGuildPrice_ATTuse                    = "|cFFAE42Verwende ATT-Preise|r",
        DsRGuildPrice_ATTscale                  = "Skaliere den ATT-Preis",
        DsRGuildPrice_ATTscaleDesc              = "Skaliere den ATT-Preis in Prozent (%)",
        DsRGuildPrice_ATTdayrange               = "Anzahl Tage des ATT-Preis",
        DsRGuildPrice_ATTdayrangeDesc           = "ATT-Preis für diese Anzahl Tage berechnen",
        DsRGuildPrice_ATTtooltip                = "Zeige ATT-Preis im Tooltip",
        DsRGuildPrice_ATTtooltipOri             = "Originalen ATT-Preis im Tooltip",
        DsRGuildPrice_SubMenueAvgPrice          = "|cadff2fDurchschnittlicher (Handels-)Preis|r",
        DsRGuildPrice_AvgPriceuse               = "|cFFAE42Verwende ø-(Handels-)Preis|r",
        DsRGuildPrice_AvgPriceuseDesc           = "Durchschnittlichen (Handels-)Preis von 'MM, TTC, ATT' verwenden",
        DsRGuildPrice_AvgPricedisplay           = "Zeige ø-(Handels-)Preis im Tooltip",
        DsRGuildPrice_AvgPriceIncTTC            = "Inklusive TTC Preis",
        DsRGuildPrice_AvgPriceIncTTCalt         = "Inklusive TTC ø-Preis",
        DsRGuildPrice_AvgPriceIncMM             = "Inklusive MM Preis",
        DsRGuildPrice_AvgPriceIncATT            = "Inklusive ATT Preis",
        DsRGuildPrice_SubMenueBestPrice         = "|cadff2fBester Preis|r",
        DsRGuildPrice_BestPriceuse              = "|cFFAE42Verwende besten Preis|r",
        DsRGuildPrice_BestPriceuseDesc          = "Durchschnittlichen (Handels-)Preis von 'Preis (Gewinn), MM, TTC, ATT' verwenden",
        DsRGuildPrice_BestPricedisplay          = "Zeige besten Preis im Tooltip",
        DsRGuildPrice_BestPriceTTCalt           = "Inklusive TTC ø-Preis",
        DsRGuildPrice_BestPriceprofit           = "Inklusive Preis (Gewinn)",
        DsRGuildPrice_BestPricesource           = "Zeige die Quelle des Preises an",
        
        --Options - 'IndexTracker'
        DsRGuildUnknown_TrackerOnOff         = "|cFFAE42Deaktiviere den Tracker|r",
        DsRGuildUnknown_TrackerACCSettings   = "|cFFBF00Account-Einstellungen|r",
        DsRGuildUnknown_MenuInvIcon          = "|c00CDCDIcons bei|r",
        SI_SCRIBING_TITLE                    = zo_iconFormat("/esoui/art/crafting/gamepad/gp_crafting_menuicon_scribing.dds", 26, 26) .. GetString(SI_SCRIBING_TITLE),
        SI_ITEMTYPE8                         = zo_iconFormat("/esoui/art/tradinghouse/gamepad/gp_tradinghouse_racial_style_motif_book.dds", 26, 26) .. GetString(SI_ITEMTYPE8),
        SI_ITEMTYPE29                        = zo_iconFormat("/esoui/art/tradinghouse/gamepad/gp_tradinghouse_trophy_recipe_fragment.dds", 26, 26) .. GetString(SI_ITEMTYPE29),
        SI_ITEMTYPE61                        = zo_iconFormat("/esoui/art/crafting/gamepad/gp_crafting_menuicon_furnishings.dds", 26, 26) .. GetString(SI_ITEMTYPE61),
        SI_SPECIALIZEDITEMTYPE82             = zo_iconFormat("/esoui/art/tradinghouse/gamepad/gp_tradinghouse_racial_style_motif_chapter.dds", 26, 26) .. GetString(SI_SPECIALIZEDITEMTYPE82),
        DsRGuildUnknown_Runeboxes            = zo_iconFormat("/esoui/art/tradinghouse/gamepad/gp_tradinghouse_trophy_runebox_fragment.dds", 26, 26) .. "Runenkiste",
        DsRGuildUnknown_ToolChat             = "|c00CDCDTooltip & Chat|r",
        DsRGuildUnknown_TooltipShow          = "Im Tooltip anzeigen",
        DsRGuildUnknown_ChatShow             = "Im Chat anzeigen",
        DsRGuildUnknown_InventarShow         = "Im Inventar anzeigen",
        DsRGuildUnknown_MenuIcon             = "|c00CDCDIcon (Inventar, Bank ...)|r",
        DsRGuildUnknown_PositionTP           = "Wo soll das Icon angezeigt werden im Inventar etc.?",
        DsRGuildUnknown_IconArt              = "Welches Icon?",
        DsRGuildUnknown_IconMulti            = "Multi Icon verwenden (" .. "|c00ff00|t24:24:/esoui/art/buttons/accept_up.dds:inheritcolor|t|r" .. "/" .. "|c2400db|t24:24:/esoui/art/buttons/plus_up.dds:inheritcolor|t|r" .. "/" .. "|cff0000|t24:24:/esoui/art/buttons/decline_up.dds:inheritcolor|t|r" .. " )",
        DsRGuildUnknown_IconOnlyUnknownINV   = "Zeige Inventar-Icon nur bei 'Unbekannten'",
        DsRGuildUnknown_IconOnlyUnknownCHAT  = "Zeige Chat-Icon nur bei 'Unbekannten'",
        DsRGuildUnknown_ColorUnknown         = "Farbe: Unbekannt",
        DsRGuildUnknown_ColorUnknownOther    = "Farbe: Bekannt (aber nicht bei allen)",
        DsRGuildUnknown_ColorKnownAll        = "Farbe: Bekannt (bei allen)",
        DsRGuildUnknown_axesOffset           = "|c00CDCDPosition des Icons|r",
        DsRGuildUnknown_XaxesOffset          = "Verschiebung in X-Achse (Horizontal)",
        DsRGuildUnknown_YaxesOffset          = "Verschiebung in Y-Achse (Vertikal)",
        DsRGuildUnknown_IconSize             = "Größe des Icons",
        DsRGuildUnknown_Layer                = "Layer",
        DsRGuildUnknown_MenuTrack            = "Verfolgen",
        DsRGuildUnknown_MenuPrio             = "Priorität",
        DsRGuildUnknown_MenuPrioDesc         = "Bestimmt die Reihenfolge der Namen im Tooltip\n1=Erster, 20= Letzter",

        --Options - 'IndexPersonalAss'
        DsRGuildPersonal_GeneralUse                   = "|cFFAE42Aktiviere deinen persönlichen Assistenten|r",
        DsRGuildPersonal_General                      = "|cff9029Alle Einstellungen sind 'Charakterbezogen'|r",
        DsRGuildPersonal_ConsumeCHARSettings          = "|cFFBF00Charakter-Einstellungen|r",
        DsRGuildPersonal_CurrencyUse                  = "|cFFAE42Aktiviere das Banking|r",
        DsRGuildPersonal_BankingAvAUse                = "|cFFAE42Aktiviere das Cyrodiil-Banking|r",
        DsRGuildPersonal_BankingStack                 = "|cFFAE42Gegenstände autom. Stapeln|r |c3b3b3b(Bank / Inventar)|r",
        DsRGuildPersonal_GeneralAttention1            = "|cFAA0A0Hinweis:|r",
        DsRGuildPersonal_GeneralAttention2            = "|cFAA0A0Es kann zu einem kurzen einfrieren des Bildes kommen, wenn viele Gegenstände verschoben werden!|r",
        DsRGuildPersonal_BankingDefaultMenu           = "|cFFBF00Standardwerte aller Charakter|r",
        DsRGuildPersonal_BankingDefaultMenuAttention1 = "|cFAA0A0Die Einstellungen überschreiben die jeweiligen Einstellungen der Charaktere|r",
        DsRGuildPersonal_BankingDefaultMenuAttention2 = "|cFAA0A0und kann nicht Rückgängig gemacht werden|r",
        DsRGuildPersonal_CurrencyCurrency             = "|c00CDCDWährung|r",
        DsRGuildPersonal_CurrencyGold                 = zo_iconFormat("/esoui/art/currency/currency_gold.dds", 26, 26) .. "Gold",
        DsRGuildPersonal_CurrencyGoldDesc             = "Leere das Feld um es zu deaktivieren",
        DsRGuildPersonal_CurrencySchrieb              = zo_iconFormat("/esoui/art/icons/icon_writvoucher.dds", 26, 26) .. "Schriebscheine",
        DsRGuildPersonal_CurrencySchriebDesc          = "Leere das Feld um es zu deaktivieren",
        DsRGuildPersonal_CurrencyAP                   = zo_iconFormat("/esoui/art/currency/alliancepoints_64.dds", 26, 26) .. "Allianzpunkte",
        DsRGuildPersonal_CurrencyAPDesc               = "Leere das Feld um es zu deaktivieren",
        DsRGuildPersonal_CurrencyTelVar               = zo_iconFormat("/esoui/art/hud/telvar_meter_currency.dds", 26, 26) .. "TelVar Steine",
        DsRGuildPersonal_CurrencyTelVarDesc           = "Leere das Feld um es zu deaktivieren",
        DsRGuildPersonal_CurrencyLockPickGem          = "|c00CDCDDietriche / Seelensteine|r",
        DsRGuildPersonal_SoulGemEmpty                 = "leere ",
        DsRGuildPersonal_Repairkit                    = zo_iconFormat(GetItemLinkIcon("|H0:item:44879:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 26, 26) .. LocalizeString("<<1>>", "|H0:item:44879:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
        DsRGuildPersonal_CurrencyMapRecipe            = "|c00CDCDKarten / Fragmente etc|r",
        DsRGuildPersonal_CurrencyRecipeALL            = "|c228B22|t30:30:/esoui/art/icons/heraldrycrests_misc_starburst_01.dds:inheritcolor|t|r" .. "Immer alles einlagern",
        DsRGuildPersonal_CurrencyRecipeKnown          = "|c228B22|t30:30:/esoui/art/icons/heraldrycrests_misc_starburst_01.dds:inheritcolor|t|r" .. "Nur Bekannte einlagern",
        DsRGuildPersonal_CurrencyRecipeUnknown        = "|cb81414|t30:30:/esoui/art/icons/heraldrycrests_misc_starburst_01.dds:inheritcolor|t|r" .. "Nur Unbekannte entnehmen",
        DsRGuildPersonal_CurrencyPvPSubmenu           = zo_iconFormat("/esoui/art/icons/fragment_gladiator_proof.dds", 26, 26) .. "|c00CDCD Meriten, Marken, Beweise|r",
        DsRGuildPersonal_CurrencyPvPMerite            = zo_iconFormat(GetItemLinkIcon("|H0:item:151939:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:151939:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
        DsRGuildPersonal_CurrencyPvPMarke             = zo_iconFormat(GetItemLinkIcon("|H0:item:212235:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:212235:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
        DsRGuildPersonal_CurrencyPvPBeweis            = zo_iconFormat(GetItemLinkIcon("|H0:item:138783:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:138783:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
        DsRGuildPersonal_CurrencyAmount               = "         Menge",
        DsRGuildPersonal_JunkUse                      = zo_iconFormat("/esoui/art/inventory/inventory_tabicon_junk_up.dds", 26, 26) .. "|cFFAE42Aktiviere das Makieren als Trödel|r",
        DsRGuildPersonal_JunkSell                     = zo_iconFormat("/esoui/art/inventory/inventory_tabicon_junk_up.dds", 26, 26) .. "|cFFAE42Trödel automatisch verkaufen|r",
        DsRGuildPersonal_DeconstructUse               = zo_iconFormat("/esoui/art/crafting/enchantment_tabicon_deconstruction_up.dds", 26, 26) .. "|cFFAE42Aktiviere das autom. Verwerten|r",
        DsRGuildPersonal_MenueJunkJunk                = "|c00CDCDAls Trödel makieren|r",
        DsRGuildPersonal_JunkPlunder                  = zo_iconFormat("/esoui/art/inventory/inventory_tabicon_junk_up.dds", 26, 26) .. "Plunder",
        DsRGuildPersonal_JunkPrey                     = zo_iconFormat("/esoui/art/inventory/inventory_tabicon_junk_up.dds", 26, 26) .. "Beute",
        DsRGuildPersonal_JunkArmorWeaponNoTrait       = zo_iconFormat("/esoui/art/inventory/inventory_trait_retrait_icon.dds", 26, 26) .. "Waffen/Rüstung ohne Trait",
        DsRGuildPersonal_MenueJunkDeconstruct         = "|c00CDCDVerwerten|r",
        DsRGuildPersonal_DeconstructNoTrait           = "Gegenstände ohne [Trait] immer",
        DsRGuildPersonal_DeconstructJunk              = zo_iconFormat("/esoui/art/inventory/inventory_tabicon_junk_up.dds", 26, 26) .. "Trödel-Gegenstände immer",
        DsRGuildPersonal_DeconstructSetItem           = zo_iconFormat("/esoui/art/collections/collections_tabicon_itemsets_up.dds", 26, 26) .. "Set-Gegenstände",
        DsRGuildPersonal_DeconstructCrafted           = zo_iconFormat("/esoui/art/crafting/reconstruct_tabicon_disabled.dds", 26, 26) .. "[Hergestellte] Gegenstände",
        DsRGuildPersonal_DeconstructReconstr          = zo_iconFormat("/esoui/art/inventory/inventory_reconstructeditem.dds", 26, 26) .. "[Rekonstruiert] Gegenstände",
        DsRGuildPersonal_DeconstructDescQuali         = "|c00CDCDStelle ein bis zu welcher Qualität verwertet werden soll|r",
        DsRGuildPersonal_Glyphe                       = "Glyphe",
        DsRGuildPersonal_DeconstructWithorBelow       = "|c6d6d6d(mit Qualität gleich oder geringer)|r",
        DsRGuildPersonal_Jewelry                      = "Schmuck",
        DsRGuildPersonal_ConsumeOnOff                 = "|cFFAE42Aktiviere dein Hungergefühl|r",
        DsRGuildPersonal_ConsumeACCSettings           = "|cFFBF00Account-Einstellungen|r",
        DsRGuildPersonal_ConsumeInterval              = "|cFFAE42Der Benachrichtigungsinterval beträgt alle 30 Sekunden!|r",
        DsRGuildPersonal_ConsumeBuffFoodONOff         = zo_iconFormat("/esoui/art/icons/justice_stolen_food_001.dds", 26, 26) .. "Buff-Food Erinnerung einschalten?",
        DsRGuildPersonal_ConsumeBuffFoodfalse         = "Erinnern wenn kein Buff-Food vorhanden?",
        DsRGuildPersonal_ConsumeBuffFoodMinTime       = "Ab wann sollen wir dich erinnern? |c3b3b3b(in Minuten)|r",
        DsRGuildPersonal_ConsumeXPONOff               = zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds", 26, 26) .. "-Buff Erinnerung einschalten?",
        DsRGuildPersonal_ConsumeXPfalse               = "Erinnern wenn kein XP-Buff vorhanden?",
        DsRGuildPersonal_ConsumeXPMinTime             = "Ab wann sollen wir dich erinnern? |c3b3b3b(in Minuten)|r",
        DsRGuildPersonal_ConsumeAPONOff               = zo_iconFormat("/DsRGuildHall/misc/DsR_AP.dds", 26, 26) .. "-Buff Erinnerung einschalten?",
        DsRGuildPersonal_ConsumeAPfalse               = "Erinnern wenn kein AP-Buff vorhanden?",
        DsRGuildPersonal_ConsumeAPMinTime             = "Ab wann sollen wir dich erinnern? |c3b3b3b(in Minuten)|r",
        DsRGuildPersonal_ConsumeInfo1                 = "|cFAA0A0Entsprechendes Bufffood, AP-, XP-Rolle kann im Inventar|r",
        DsRGuildPersonal_ConsumeInfo2                 = "|cFAA0A0über die rechte Maustaste zugewiesen/entfernt werden|r",
        DsRGuildPersonal_ConsumeAutoEat               = "Hungergefühl befriedigen ab |c3b3b3b(in Minuten)|r",
        DsRGuildPersonal_ConsumeAutoEatDesc           = "Der Wert '0' deaktiviert das Befriedigen des Hungergefühls",
        DsRGuildPersonal_ConsumeAutoXP                = "autom. " .. zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds", 26, 26) .. "-Rolle aktivieren",
        DsRGuildPersonal_ConsumeAutoAP                = "autom. " .. zo_iconFormat("/DsRGuildHall/misc/DsR_AP.dds", 26, 26) .. "-Rolle aktivieren",
        DsRGuildPersonal_AvAShopMainDesc1             = "Was darf ich für dich einkaufen oder bis wohin auffüllen,",
        DsRGuildPersonal_AvAShopMainDesc2             = "sobald Du ein Belagerungsmeister ansprichst",
        DsRGuildPersonal_AvAShopUse                   = "|cFFAE42Aktiviere das Handeln mit einem Meister|r",
        DsRGuildPersonal_RepairMenueDesc              = "|cFAA0A0ACHTUNG: Diese Einstellungen gelten Accountweit!",
        DsRGuildPersonal_RepairMenueOnOff             = "|cFFAE42Aktiviere die Rüstungswerkstatt|r",
        DsRGuildPersonal_RepairChat                   = "|c35fc38Werkstatt-News im Chat anzeigen|r",
        DsRGuildPersonal_RepairStores                 = "|c00CDCDGeschäfte|r",
        DsRGuildPersonal_RepairStoresAuto             = "Autoreparatur in Geschäften",
        DsRGuildPersonal_RepairRepairing              = "|c00CDCDReparieren|r",
        DsRGuildPersonal_RepairRepairingAuto          = "Automatisches Reparieren",
        DsRGuildPersonal_RepairRepairingAutoAny       = "Verwende beliebiges Reparaturmaterial",
        DsRGuildPersonal_RepairKit                    = "Ab wann soll Repariert werden",
        DsRGuildPersonal_RepairRecharging             = "|c00CDCDAufladen|r",
        DsRGuildPersonal_RepairRechargingAuto         = "Automatisches Aufladen",
        DsRGuildPersonal_RepairRechargingAutoAny      = "Verwende beliebige Seelensteine",
        DsRGuildPersonal_RepairRecharge               = "Ab wann soll Aufgeladen werden",

        --Options - 'BarMenu'
        DsRGuildBarMenu_OnOff          = "|cFFAE42Aktiviere die Rabenbar|r",
        DsRGuildBarMenu_OnOffDesc      = "Lasse Dir die Rabenbar auf dem Desktop anzeigen",
        DsRGuildBarMenu_accsettings    = "|cFFAE42Alle Einstellungen gelten Accountweit!|r",
        DsRGuildBarMenu_PosUPBOT       = "Position der RabenBar",
        DsRGuildBarMenu_Bankspace      = zo_iconFormat("/esoui/art/icons/mapkey/mapkey_bank.dds", 22, 22) .. "Bank",
        DsRGuildBarMenu_Inventoryspace = zo_iconFormat("/esoui/art/inventory/gamepad/gp_inventory_icon_all.dds", 22, 22) .. "Inventar",
        DsRGuildBarMenu_SoulGem        = zo_iconFormat("/esoui/art/icons/soulgem_006_filled.dds", 22, 22) .. "Seelensteine",
        DsRGuildBarMenu_LockPick       = zo_iconFormat(GetItemLinkIcon("|H0:item:30357:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:30357:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
        DsRGuildBarMenu_CurrencyAP     = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_ALLIANCE_POINTS)) .. GetCurrencyName(CURT_ALLIANCE_POINTS, false):gsub("%^.+", ""),
        DsRGuildBarMenu_CurrencyTelVar = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_TELVAR_STONES)) .. GetCurrencyName(CURT_TELVAR_STONES, false):gsub("%^.+", ""),
        DsRGuildBarMenu_CurrencyXP     = zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds", 22, 22) .. "-Fortschritt",
        DsRGuildBarMenu_RefreshTimer   = "Updateintervall in Sekunden|u1:4::|u" .. zo_iconFormat("/esoui/art/tutorial/timer_icon.dds",28,28),
        DsRGuildBarMenu_Scale          = "Skalierung der Schriftgröße",
        DsRGuildBarMenu_SpaceOffSet    = "Abstand zwischen Werte",
        DsRGuildBarMenu_MenueHide      = "In Menüs ausblenden",
        DsRGuildBarMenu_Campion        = zo_iconFormat("/esoui/art/mainmenu/menubar_champion_up.dds", 24, 24) .. "Champion/Level",
        DsRGuildBarMenu_Crowns         = string.format("|t24:24:%s|t", GetCurrencyKeyboardIcon(CURT_CROWNS)) .. GetCurrencyName(CURT_CROWNS, false):gsub("%^.+", ""),
        DsRGuildBarMenu_writvoucher    = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_WRIT_VOUCHERS)) .. GetCurrencyName(CURT_WRIT_VOUCHERS, false):gsub("%^.+", ""),
        DsRGuildBarMenu_OStime         = zo_iconFormat("/esoui/art/lfg/lfg_indexicon_timedactivities_up.dds", 22, 22) .. "Uhrzeit",
        DsRGuildBarMenu_Stolen         = zo_iconFormat("/esoui/art/inventory/inventory_stolenitem_icon.dds", 22, 22) .. "Hehlerware",
        DsRGuildBarMenu_Background     = "Hintergrund anzeigen",
        DsRGuildBarMenu_BgTransparent  = "Sichtbarkeit des Hintergrundes",
        DsRGuildBarMenu_TomeChallenge  = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_TOME_CHALLENGE_REROLLS)) .. GetCurrencyName(CURT_TOME_CHALLENGE_REROLLS, false):gsub("%^.+", ""),
        DsRGuildBarMenu_TomePoints     = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_TOME_POINTS)) .. GetCurrencyName(CURT_TOME_POINTS, false):gsub("%^.+", ""),
        DsRGuildBarMenu_TomePointCach  = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_TOME_POINT_CACHES)) .. GetCurrencyName(CURT_TOME_POINT_CACHES, false):gsub("%^.+", ""),
        DsRGuildBarMenu_TomeToken      = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_TOME_TOKENS)) .. GetCurrencyName(CURT_TOME_TOKENS, false):gsub("%^.+", ""),
        DsRGuildBarMenu_TradeBars      = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_TRADE_BARS)) .. GetCurrencyName(CURT_TRADE_BARS, false):gsub("%^.+", ""),
}
