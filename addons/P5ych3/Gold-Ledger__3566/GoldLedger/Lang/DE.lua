local currencyChangeReasons =
{
    [CURRENCY_CHANGE_REASON_ABILITY_UPGRADE_PURCHASE] = "Fertigkeit erlernt",
    [CURRENCY_CHANGE_REASON_ACHIEVEMENT]              = "Errungenschaft",
    [CURRENCY_CHANGE_REASON_ACTION]                   = "Unbekannt (ACTION)",
    [CURRENCY_CHANGE_REASON_BAGSPACE]                 = "Inventarerweiterung",
    [CURRENCY_CHANGE_REASON_BANKSPACE]                = "Bankerweiterung",
    [CURRENCY_CHANGE_REASON_BANK_DEPOSIT]             = "Bankeinzahlung",
    [CURRENCY_CHANGE_REASON_BANK_FEE]                 = "Unknown (BANK_FEE)",
    [CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL]          = "Bankabhebung",
    [CURRENCY_CHANGE_REASON_BATTLEGROUND]             = "Unbekannt (BATTLEGROUND)",
    [CURRENCY_CHANGE_REASON_BOUNTY_CONFISCATED]       = "Kopfgeld gezahlt",
    [CURRENCY_CHANGE_REASON_BOUNTY_PAID_FENCE]        = "Kopfgeld gezahlt (Hehler)",
    [CURRENCY_CHANGE_REASON_BOUNTY_PAID_GUARD]        = "Kopfgeld gezahlt (Wache)",
    [CURRENCY_CHANGE_REASON_BUYBACK]                  = "Rückkauf",
    [CURRENCY_CHANGE_REASON_CASH_ON_DELIVERY]         = "Bargeld durch Lieferung",
    [CURRENCY_CHANGE_REASON_COMMAND]                  = "Unbekannt (COMMAND)",
    [CURRENCY_CHANGE_REASON_CONSUME_FOOD_DRINK]       = "Unbekannt (CONSUME_FOOD_DRINK)",
    [CURRENCY_CHANGE_REASON_CONSUME_POTION]           = "Unbekannt (CONSUME_POTION)",
    [CURRENCY_CHANGE_REASON_CONVERSATION]             = "Dialogoption",
    [CURRENCY_CHANGE_REASON_CRAFT]                    = "Handwerk",
    [CURRENCY_CHANGE_REASON_DEATH]                    = "Unbekannt (DEATH)",
    [CURRENCY_CHANGE_REASON_DECONSTRUCT]              = "Zerlegen",
    [CURRENCY_CHANGE_REASON_EDIT_GUILD_HERALDRY]      = "Zunftheraldik bearbeiten",
    [CURRENCY_CHANGE_REASON_FEED_MOUNT]               = "Pferd (Erhöhung der Tragkraft)",
    [CURRENCY_CHANGE_REASON_GUILD_BANK_DEPOSIT]       = "Bankeinzahlung (Gilde)",
    [CURRENCY_CHANGE_REASON_GUILD_BANK_WITHDRAWAL]    = "Bank entnahme (Gilde)",
    [CURRENCY_CHANGE_REASON_GUILD_FORWARD_CAMP]       = "Unbekannt (GUILD_FORWARD_CAMP)",
--    [CURRENCY_CHANGE_REASON_GUILD_STANDARD]           = "Unbekannt (GUILD_STANDARD)", --P5YCH3 - This enum was removed in update 36 - Firesong.
    [CURRENCY_CHANGE_REASON_GUILD_TABARD]             = "Wappenrock",
    [CURRENCY_CHANGE_REASON_HARVEST_REAGENT]          = "Unbekannt (HARVEST_REAGENT)",
--    [CURRENCY_CHANGE_REASON_HOOKPOINT_STORE]          = "Unbekannt (HOOKPOINT_STORE)", --P5YCH3 --This enum was removed prior to update 28.
    [CURRENCY_CHANGE_REASON_JUMP_FAILURE_REFUND]      = "Unbekannt (JUMP_FAILURE_REFUND)",
    [CURRENCY_CHANGE_REASON_KEEP_REPAIR]              = "Bergfriedreperatur",
--    [CURRENCY_CHANGE_REASON_KEEP_REWARD]              = "Bergfriedbelohnung", --P5YCH3 --This enum was replaced in update 19 - Wolfhunter.
    [CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD]    = "Bergfriedbelohnung",
    [CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD]    = "Bergfriedbelohnung",
    [CURRENCY_CHANGE_REASON_KEEP_UPGRADE]             = "Bergfriederweiterung",
    [CURRENCY_CHANGE_REASON_KILL]                     = "Unbekannt (KILL)",
    [CURRENCY_CHANGE_REASON_LOOT]                     = "Loot",
    [CURRENCY_CHANGE_REASON_LOOT_STOLEN]              = "Gestohlen",
    [CURRENCY_CHANGE_REASON_MAIL]                     = "Nachricht",
    [CURRENCY_CHANGE_REASON_MEDAL]                    = "Unbekannt (MEDAL)",
    [CURRENCY_CHANGE_REASON_PICKPOCKET]               = "Taschendiebstahl",
    [CURRENCY_CHANGE_REASON_PLAYER_INIT]              = "Unbekannt (PLAYER_INIT)",
    [CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER]        = "Unbekannt (PVP_KILL_TRANSFER)",
    [CURRENCY_CHANGE_REASON_PVP_RESURRECT]            = "Unbekannt (PVP_RESURRECT)",
    [CURRENCY_CHANGE_REASON_QUESTREWARD]              = "Questbelohnung",
    [CURRENCY_CHANGE_REASON_RECIPE]                   = "Unbekannt (RECIPE)",
    [CURRENCY_CHANGE_REASON_REFORGE]                  = "Unbekannt (REFORGE)",
    [CURRENCY_CHANGE_REASON_RESEARCH_TRAIT]           = "Unbekannt (RESEARCH_TRAIT)",
    [CURRENCY_CHANGE_REASON_RESPEC_ATTRIBUTES]        = "Attributänderungen",
    [CURRENCY_CHANGE_REASON_RESPEC_CHAMPION]          = "Championzurücksetzung",
    [CURRENCY_CHANGE_REASON_RESPEC_MORPHS]            = "Morphzurücksetzung",
    [CURRENCY_CHANGE_REASON_RESPEC_SKILLS]            = "Fertigkeitszurücksetzung",
    [CURRENCY_CHANGE_REASON_REWARD]                   = "Unbekannt (REWARD)",
    [CURRENCY_CHANGE_REASON_SELL_STOLEN]              = "Hehler",
    [CURRENCY_CHANGE_REASON_SOULWEARY]                = "Unbekannt (SOULWEARY)",
    [CURRENCY_CHANGE_REASON_SOUL_HEAL]                = "Unbekannt (SOUL_HEAL)",
    [CURRENCY_CHANGE_REASON_STABLESPACE]              = "Unbekannt (STABLESPACE)",
    [CURRENCY_CHANGE_REASON_STUCK]                    = "Festfahren",
    [CURRENCY_CHANGE_REASON_TRADE]                    = "Handel",
    [CURRENCY_CHANGE_REASON_TRADINGHOUSE_LISTING]     = "Auflistung im Gildenladen",
    [CURRENCY_CHANGE_REASON_TRADINGHOUSE_PURCHASE]    = "Kauf im Gildenladen",
    [CURRENCY_CHANGE_REASON_TRADINGHOUSE_REFUND]      = "Rückerstattung des Gildenladens",
    [CURRENCY_CHANGE_REASON_TRAIT_REVEAL]             = "Unbekannt (TRAIT_REVEAL)",
    [CURRENCY_CHANGE_REASON_TRAVEL_GRAVEYARD]         = "Wegschrein",
    [CURRENCY_CHANGE_REASON_VENDOR]                   = "Verkäufer",
    [CURRENCY_CHANGE_REASON_VENDOR_LAUNDER]           = "Geldwäsche",
    [CURRENCY_CHANGE_REASON_VENDOR_REPAIR]            = "Gerätereparaturen",
}

for i, value in pairs(currencyChangeReasons) do
  ZO_CreateStringId("SI_GOLD_LEDGER_REASON"..i, value)
end

ZO_CreateStringId("SI_BINDING_NAME_LEDGER_TOGGLE"        , "Hauptbuch öffnen/schließen")
ZO_CreateStringId("SI_GOLD_LEDGER_EMPTY"                 , "No record found for the selected period and character.")
ZO_CreateStringId("SI_GOLD_LEDGER_HEADER_TIMESTAMP"      , "Zeitpunkt")
ZO_CreateStringId("SI_GOLD_LEDGER_HEADER_CHARACTER"      , "Charakter")
ZO_CreateStringId("SI_GOLD_LEDGER_HEADER_REASON"         , "Grund")
ZO_CreateStringId("SI_GOLD_LEDGER_HEADER_VARIATION"      , "Veränderung")
ZO_CreateStringId("SI_GOLD_LEDGER_HEADER_BALANCE"        , "Kontostand")
ZO_CreateStringId("SI_GOLD_LEDGER_PERIOD_1_HOUR"         , "1 Stunde")
ZO_CreateStringId("SI_GOLD_LEDGER_PERIOD_1_DAY"          , "1 Tag")
ZO_CreateStringId("SI_GOLD_LEDGER_PERIOD_1_WEEK"         , "1 Woche")
ZO_CreateStringId("SI_GOLD_LEDGER_PERIOD_1_MONTH"        , "1 Monat")
ZO_CreateStringId("SI_GOLD_LEDGER_PERIOD_1_QUARTER"      , "1 Viertel")
ZO_CreateStringId("SI_GOLD_LEDGER_PERIOD_1_YEAR"         , "1 Jahr")
ZO_CreateStringId("SI_GOLD_LEDGER_ALL_CHARACTERS"        , "Alle Charakter")
ZO_CreateStringId("SI_GOLD_LEDGER_BANK_CHARACTER"        , "Bank")
ZO_CreateStringId("SI_GOLD_LEDGER_MERGE_LABEL"           , "Ähnliche zusammenführen")
ZO_CreateStringId("SI_GOLD_LEDGER_SEARCH_LABEL"          , "Suche nach Grund.") --P5YCH3 - Added missing variable.
ZO_CreateStringId("SI_GOLD_LEDGER_SUMMARY1"              , "Kontostand änderte sich um <<1>> in <<z:2>>.")
ZO_CreateStringId("SI_GOLD_LEDGER_SUMMARY2"              , "Größte Einnahme <<1>> (<<2>>) und größte Ausgabe war <<3>> (<<4>>).")
ZO_CreateStringId("SI_GOLD_LEDGER_SUMMARY2_EXPENSE"      , "Größte Ausgabe war <<1>> (<<2>>).")
ZO_CreateStringId("SI_GOLD_LEDGER_SUMMARY2_PROFIT"       , "Größte Einnahme <<1>> (<<2>>).")
ZO_CreateStringId("SI_GOLD_LEDGER_SUMMARY_EMPTY"         , "")
------------------------------------------------
--P5YCH3 - New translation values.
------------------------------------------------
ZO_CreateStringId("SI_GOLD_LEDGER_MAIN_WINDOW_INVENTORY_BUTTON"         , "Inventar")
ZO_CreateStringId("SI_GOLD_LEDGER_MAIN_WINDOW_INVENTORY_BUTTON_TOOLTIP" , "• Links Klick:\nÖffnen Sie Ihr Inventarmenü.")
ZO_CreateStringId("SI_GOLD_LEDGER_MAIN_WINDOW_SETTINGS_BUTTON"          , "Konfigurieren")
ZO_CreateStringId("SI_GOLD_LEDGER_MAIN_WINDOW_SETTINGS_BUTTON_TOOLTIP"  , "• Links Klick:\nÖffnen Sie die Addon-Einstellungen.")

ZO_CreateStringId("SI_GOLD_LEDGER_TITLE"                          , "Gold Ledger")
ZO_CreateStringId("SI_GOLD_LEDGER_SETTINGS_HEADER"                , "Konfigurieren")
ZO_CreateStringId("SI_GOLD_LEDGER_VIEW_LEDGER_BUTTON"             , "Gold Ledger Ansehen")
ZO_CreateStringId("SI_GOLD_LEDGER_VIEW_LEDGER_BUTTON_TOOLTIP"     , "Verfolgen Sie Ihr Geld sitzungsübergreifend. Sehen Sie sich eine praktische Übersicht an, in der detailliert beschrieben wird, wie Ihr Gold gesammelt oder ausgegeben wird.")

ZO_CreateStringId("SI_GOLD_LEDGER_VIEW_INVENTORY_BUTTON"          , "Öffnen Sie Das Inventar")
ZO_CreateStringId("SI_GOLD_LEDGER_VIEW_INVENTORY_BUTTON_TOOLTIP"  , "Öffnen Sie Ihr Inventarmenü.")
ZO_CreateStringId("SI_GOLD_LEDGER_SHOW_INVENTORY_OPTION"          , "Inventarsymbol Anzeigen")
ZO_CreateStringId("SI_GOLD_LEDGER_SHOW_INVENTORY_OPTION_TOOLTIP"  , "Zeigen Sie das Gold Ledger-Symbol im Inventarmenü an.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_HIDE_WINDOW_OPTION"      , "Banker-Schaltfläche blendet Fenster aus")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_HIDE_WINDOW_TOOLTIP"     , "Wenn Sie die Banker-Taste verwenden, wird die Hauptanzeige ausgeblendet.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_ASSISTANT"               , "Bankassistent")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_ASSISTANT_TOOLTIP"       , "Wählen Sie aus, welcher Assistent verwendet wird, wenn auf die Banker-Schaltfläche geklickt wird.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_ASSISTANT"             , "Händlerassistent")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_ASSISTANT_TOOLTIP"     , "Wählen Sie aus, welcher Assistent verwendet werden soll, wenn der Kaufmann-Button angeklickt wird.")
ZO_CreateStringId("SI_GOLD_LEDGER_ICON_TOOLTIP"                   , ZO_HIGHLIGHT_TEXT:Colorize("Gold Ledger\n---------------") .. "\n• Links Klick:\nZiehen und ablegen, um dieses Fenster zu verschieben.\n\n• Mittelklick:\nÖffnen Sie das Addon-Einstellungsmenü.\n\n• Rechtsklick:\nZeigen Sie Ihr Inventarmenü an.")
ZO_CreateStringId("SI_GOLD_LEDGER_INVENTORY_ICON_TOOLTIP"         , ZO_HIGHLIGHT_TEXT:Colorize("Gold Ledger\n---------------") .. "\n• Links Klick:\nOffen Gold Ledger.\n\n• Mittelklick:\nÖffnen Sie das Addon-Einstellungsmenü.\n\n• Rechtsklick:\nZiehen und ablegen, um dieses Symbol neu zu positionieren.")
ZO_CreateStringId("SI_GOLD_LEDGER_CURRENT_BANK_BALANCE_TOOLTIP"   , "Aktueller Kontostand.\n\n• Links Klick:\nNutzen Sie Ihren persönlichen Bankassistenten.")
ZO_CreateStringId("SI_GOLD_LEDGER_CURRENT_BAG_BALANCE_TOOLTIP"    , "Aktuelle Taschenbilanz.\n\n• Links Klick:\nÖffnen Sie Ihr Inventarmenü.\n\n• Rechtsklick:\nSpawnen Sie Ihren Händler\n\n• Mittelklick:\nSpawnen Sie Ihren Händler - Gestohlene Waren")
ZO_CreateStringId("SI_GOLD_LEDGER_CONSOLE_COMMANDS"               , "Konsolenbefehle")
ZO_CreateStringId("SI_GOLD_LEDGER_COMMAND_GOLD_LEDGER"            , "Schaltet das Hauptanzeigefenster von Gold Ledger um.")
ZO_CreateStringId("SI_GOLD_LEDGER_COMMAND_GOLD_LEDGER_SHORT"      , "Schaltet das Hauptanzeigefenster von Gold Ledger um.")
ZO_CreateStringId("SI_GOLD_LEDGER_COMMAND_LEDGER"                 , "Schaltet das Hauptanzeigefenster von Gold Ledger um.")
ZO_CreateStringId("SI_GOLD_LEDGER_COMMAND_LEDGER_SHORT"           , "Schaltet das Hauptanzeigefenster von Gold Ledger um.")
ZO_CreateStringId("SI_GOLD_LEDGER_COMMAND_LEDGER_SETTINGS"        , "Öffnet das Addon-Einstellungsfeld (dieses Menü).")
ZO_CreateStringId("SI_GOLD_FUNCTIONS_HEADER"                      , "Gold Ledger - Funktionen")
ZO_CreateStringId("SI_GOLD_SETTINGS_HEADER"                       , "Gold Ledger - Konfigurieren (dieses Menü)")

--Bankers
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_TOGGLED_TYTHIS"          , "Tythis Andromo der Bankier – umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_UNAVAILABLE_TYTHIS"      , "Tythis Andromo der Bankier ist nicht freigeschaltet. Kann nicht umgeschaltet werden.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_ALTERNATIVE_TYTHIS"      , "Tythis Andromo der Bankier wurde stattdessen umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_TOGGLED_EZABI"           , "Ezabi der Bankier – umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_UNAVAILABLE_EZABI"       , "Ezabi der Bankier ist nicht freigeschaltet. Kann nicht umgeschaltet werden.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_ALTERNATIVE_EZABI"       , "Ezabi der Bankier wurde stattdessen umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_TOGGLED_JANGLEPLUME"     , "Baron Jangleplume der Bankier – umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_UNAVAILABLE_JANGLEPLUME" , "Baron Jangleplume der Bankier ist nicht freigeschaltet. Kann nicht umgeschaltet werden.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_ALTERNATIVE_JANGLEPLUME" , "Baron Jangleplume der Bankier wurde stattdessen umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_TOGGLED_FACTOTUM"        , "Factotum Immobilienverwalter – umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_UNAVAILABLE_FACTOTUM"    , "Factotum Immobilienverwalter ist nicht freigeschaltet. Kann nicht umgeschaltet werden.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_ALTERNATIVE_FACTOTUM"    , "Factotum Immobilienverwalter wurde stattdessen umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_TOGGLED_PYROCLAST"       , "Pyroclast, Infernace-Konservator – umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_UNAVAILABLE_PYROCLAST"   , "Pyroclast, Infernace-Konservator ist nicht freigeschaltet. Kann nicht umgeschaltet werden.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_ALTERNATIVE_PYROCLAST"   , "Pyroclast, Infernace-Konservator wurde stattdessen umgeschaltet.")

--Merchants
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_TOGGLED_NUZHIMEH"          , "Nuzhimeh der Kaufmann – umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_UNAVAILABLE_NUZHIMEH"      , "Tythis Andromo der Bankier ist nicht freigeschaltet. Kann nicht umgeschaltet werden.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_ALTERNATIVE_NUZHIMEH"      , "Nuzhimeh der Kaufmann wurde stattdessen umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_TOGGLED_FEZEZ"             , "Fezez der Kaufmann – umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_UNAVAILABLE_FEZEZ"         , "Fezez der Kaufmann ist nicht freigeschaltet. Kann nicht umgeschaltet werden.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_ALTERNATIVE_FEZEZ"         , "Fezez der Kaufmann wurde stattdessen umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_TOGGLED_FACTOTEM"          , "Factotum Handelsdelegierter – umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_UNAVAILABLE_FACTOTEM"      , "Factotum Handelsdelegierter ist nicht freigeschaltet. Kann nicht umgeschaltet werden.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_ALTERNATIVE_FACTOTEM"      , "Factotum Handelsdelegierter wurde stattdessen umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_TOGGLED_PEDDLER"           , "Hausiererin, der Kaufmann – umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_UNAVAILABLE_PEDDLER"       , "Hausiererin, der Kaufmann ist nicht freigeschaltet. Kann nicht umgeschaltet werden.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_ALTERNATIVE_PEDDLER"       , "Hausiererin, der Kaufmann wurde stattdessen umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_TOGGLED_HOARFROST"         , "Hoarfrost, Takubar Trader – umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_UNAVAILABLE_HOARFROST"     , "Hoarfrost, Takubar Trader ist nicht freigeschaltet. Kann nicht umgeschaltet werden.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_ALTERNATIVE_HOARFROST"     , "Hoarfrost, Takubar Trader wurde stattdessen umgeschaltet.")

--Fences
ZO_CreateStringId("SI_GOLD_LEDGER_FENCE_TOGGLED_PIRHARRI"          , "Pirharri der Schmuggler – umgeschaltet.")
ZO_CreateStringId("SI_GOLD_LEDGER_FENCE_UNAVAILABLE_PIRHARRI"      , "Pirharri der Schmuggler ist nicht freigeschaltet. Kann nicht umgeschaltet werden.")

--ZO_CreateStringId("SI_GOLD_LEDGER_WIP"                            , "Placeholder text.")
------------------------------------------------