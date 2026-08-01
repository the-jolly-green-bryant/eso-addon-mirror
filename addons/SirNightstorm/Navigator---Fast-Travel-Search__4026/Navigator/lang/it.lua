local mkstr = Navigator.mkstr

-- Controls menu entry (opens the Navigator tab on the World Map)
mkstr("SI_BINDING_NAME_NAVIGATOR_SEARCH", "Apri mappa")
--mkstr("SI_BINDING_NAME_NAVIGATOR_FOCUSSEARCH", "Search (on World Map)")

-- Name of the tab on the World Map
mkstr("NAVIGATOR_TAB_SEARCH","Navigator")

-- Shown on the bottom keybind bar


-- Edit box hint text (<<1>> is replaced by 'Tab')
mkstr("NAVIGATOR_SEARCH_KEYPRESS","Cerca (<<1>>)")
mkstr("NAVIGATOR_SEARCH","Cerca luogo, zona or @player")

-- Category Headings
mkstr("NAVIGATOR_CATEGORY_BOOKMARKS", "Preferiti")
mkstr("NAVIGATOR_CATEGORY_RECENT", "Recenti")
mkstr("NAVIGATOR_CATEGORY_ZONES", "Zone")




-- Result hints
mkstr("NAVIGATOR_HINT_NORESULTS", "Nessun risulato")
mkstr("NAVIGATOR_HINT_NORECENTS", "Le destinazioni a cui hai viaggiato appariranno qui")
mkstr("NAVIGATOR_HINT_NOBOOKMARKS", "Pulsante destro del mouse su una destinazione per aggiungrere (o rimuovere) ai preferiti")
mkstr("NAVIGATOR_HINT_SHOWUNDISCOVERED", "Clicca per mostrare posizione sconosciute")

-- Enter key label (keep it short!)
mkstr("NAVIGATOR_KEY_ENTER", "Invio")

-- Result types




-- Tooltips
mkstr("NAVIGATOR_NOT_KNOWN", "Non conosciuto da questo personaggio") -- Location not known
mkstr("NAVIGATOR_TIP_CLICK_TO_TRAVEL", "Premi per viaggiare a <<1>>") -- 1:zone/destination
mkstr("NAVIGATOR_TIP_DOUBLECLICK_TO_TRAVEL", "Doppio-click per viaggiare a <<1>>") -- 1:zone/destination
mkstr("NAVIGATOR_TOOLTIP_ACTION_RESULT", "<<1>>: <<2>>") -- e.g. 1:"Single-click" 2:"Show On Map"
mkstr("NAVIGATOR_TOOLTIP_GUILDTRADERS", "<<1[/1 mercante di gilda nelle vicinanze/$d mercanti di gilde nelle vicinanze]>>")
--mkstr("NAVIGATOR_TOOLTIP_VIEWMENU", "Switch to alternative views")
--mkstr("NAVIGATOR_TOOLTIP_CLEARVIEW", "Right-click to clear view\nRight-click to clear view")

-- Action and menu items
mkstr("NAVIGATOR_TRAVEL_TO_ZONE", "Viaggia a <<1>>")
mkstr("NAVIGATOR_MENU_ADDBOOKMARK", "Aggiungi preferiti")
mkstr("NAVIGATOR_MENU_ADDHOUSEBOOKMARK", "Aggiungi residenza principale ai preferiti")
mkstr("NAVIGATOR_MENU_REMOVEBOOKMARK", "Rimuovi preferito")
mkstr("NAVIGATOR_MENU_MOVEBOOKMARKUP", "Sposta su")
mkstr("NAVIGATOR_MENU_MOVEBOOKMARKDOWN", "Sposta giù")
--mkstr("NAVIGATOR_MENU_PLAYERS", "Players")
--mkstr("NAVIGATOR_MENU_GUILDTRADERS", "Guild Traders")
--mkstr("NAVIGATOR_MENU_TREASUREMAPS_SURVEYS", "Treasure Maps & Surveys")
--mkstr("NAVIGATOR_MENU_CLEARVIEW", "Clear view")



-- Status / error messages
mkstr("NAVIGATOR_NO_TRAVEL_PLAYER", "Nessun giocatore disponibile per il viaggio")
mkstr("NAVIGATOR_CANNOT_TRAVEL_TO_PLAYER", "Impossibile viaggiare da <<1>>") -- 1:player
mkstr("NAVIGATOR_NO_PLAYER_IN_ZONE", "Impossibile trovare un giocatore a cui viaggiare in <<1>>") -- 1:zone
mkstr("NAVIGATOR_PLAYER_NOT_IN_ZONE", "<<1>> non è più in <<2>>") -- 1:player 2:zone
mkstr("NAVIGATOR_TRAVELING_TO_LOCATION", "In viaggio verso <<1>>") -- 1:location
mkstr("NAVIGATOR_RECALLING_TO_LOCATION_COST", "Richiamo a <<1>> usando <<2>>") -- 1:location 2:cost
mkstr("NAVIGATOR_TRAVELING_TO_ZONE_VIA_PLAYER", "In viaggio verso <<1>> via <<2>>") -- 1:zone 2:player
mkstr("NAVIGATOR_TRAVELING_TO_PLAYER_IN_ZONE", "In viaggio verso <<1>> in <<2>>") -- 1:player 2:zone
mkstr("NAVIGATOR_TRAVELING_TO_HOUSE_INSIDE", "In viaggio verso <<1>> (interno)") -- 1:house
mkstr("NAVIGATOR_TRAVELING_TO_HOUSE_OUTSIDE", "In viaggio verso <<1>> (esterno)") -- 1:house
mkstr("NAVIGATOR_TRAVELING_TO_PLAYER_HOUSE", "In viaggio verso casa <<gu:1>>") -- 1:house

-- Chat slash command
mkstr("NAVIGATOR_SLASH_DESCRIPTION", "Navigator: Teletrasporto verso la zona, la wayshrine, la casa o il giocatore indicato")

-- Custom location names
mkstr("NAVIGATOR_LOCATION_OBLIVIONPORTAL", "Portale per Oblivion")

-- Add-on Settings
--mkstr("NAVIGATOR_SETTINGS_DEFAULT_TAB_NAME",                "Selezione automatica scheda Navigator")
--mkstr("NAVIGATOR_SETTINGS_DEFAULT_TAB_TOOLTIP",             "Apertura automatica scheda Navigator all apertura della mappa.")
--mkstr("NAVIGATOR_SETTINGS_DEFAULT_TAB_WARNING",             "Navigator non può selezionare automaticamente la sua scheda quando l'addon |c99FFFFFaster Travel|r è attivo")

mkstr("NAVIGATOR_SETTINGS_RECENT_COUNT_NAME",               "Voci nella lista recenti")
mkstr("NAVIGATOR_SETTINGS_RECENT_COUNT_TOOLTIP",            "Impostare questo a 0 disabilitera la lista dei recenti")

mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_NAME",        "Conferma viaggio rapido")
mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_TOOLTIP",     "Se/Quando mostrare l'avviso standard quando si salta a una wayshrine. Influisce solo su Navigator, non la mappa del mondo")
mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_CHOICE_1",    "Sempre")
mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_CHOICE_2",    "Prezzo <<1>>") --  1:goldicon
mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_CHOICE_3",    "Mai")

mkstr("NAVIGATOR_SETTINGS_LIST_POI_NAME",                   "Mostra punti di interesse nella mappa della zona")
mkstr("NAVIGATOR_SETTINGS_LIST_POI_TOOLTIP",                "Se questo è disabilitato, solo le \"destinazioni\" come le wayshrines, dungeons, case o giocatori verranno elencate")

mkstr("NAVIGATOR_SETTINGS_INCLUDE_UNDISCOVERED_NAME",       "Mostra e cerca luoghi non ancora scoperti")
mkstr("NAVIGATOR_SETTINGS_INCLUDE_UNDISCOVERED_TOOLTIP",    "Elenca le posizioni non scoperte e mostrale nei risultati di ricerca")

mkstr("NAVIGATOR_SETTINGS_USE_HOUSE_NICKNAME_NAME",         "Mostra e cerca i soprannomi delle case")

mkstr("NAVIGATOR_SETTINGS_AUTO_FOCUS_NAME",                 "Selezione automatica della casella di ricerca")
mkstr("NAVIGATOR_SETTINGS_AUTO_FOCUS_TOOLTIP",              "Inserisce automaticamente il cursore nella casella di ricerca quando la scheda è selezionata. Ciò significa che il tasto 'M' non può essere utilizzato per uscire dalla mappa; usa invece il tasto 'Esc'.")
mkstr("NAVIGATOR_SETTINGS_AUTO_FOCUS_WARNING",              "Quando attivo, il tasto 'M' non può essere usato per uscire dalla mappa; dovrai usare 'Esc'.")

mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_NAME",               "Comando chat")
mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_TOOLTIP",            "Seleziona quale nome dare al comando in chat")
mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_CHOICE_1",           "Off") -- Chat command is disabled
mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_WARNING",            "|c8080FFPithka's Achievement Tracker|r ha il comando di teletrasporto abilitato che occupa '/tp'")
mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_UNAVAILABLE",        "|cFFFF00|t24:24:/esoui/art/miscellaneous/eso_icon_warning.dds:inheritcolor|t|r Il comando chat diNavigator è disponibile solo se l' addon |c99FFFFLibSlashCommander|r è installato e abilitato")

mkstr("NAVIGATOR_SETTINGS_ACTIONS_NAME",                    "Azioni del clic del mouse e tasto Invio")
mkstr("NAVIGATOR_SETTINGS_ACTIONS_SINGLE_CLICK",             "Click singolo")
mkstr("NAVIGATOR_SETTINGS_ACTIONS_DOUBLE_CLICK",            "Click doppio")
mkstr("NAVIGATOR_SETTINGS_ACTIONS_ENTER_KEY",               "Tasto [Invio]")
--mkstr("NAVIGATOR_SETTINGS_ACTIONS_CHOICE_SHOW_ON_MAP",      "Mostra in mappa")
mkstr("NAVIGATOR_SETTINGS_ACTIONS_CHOICE_SET_DESTINATION",  "Imposta destinazione")
--mkstr("NAVIGATOR_SETTINGS_ACTIONS_CHOICE_TRAVEL",           "Viaggia")

mkstr("NAVIGATOR_SETTINGS_DESTINATION_ACTIONS_NAME",        "Destinazioni di viaggio")
mkstr("NAVIGATOR_SETTINGS_DESTINATION_ACTIONS_TOOLTIP",     "Azione per Mouse e tasti per Wayshrines, Dungeons, Trials, Arene e Castelli")
mkstr("NAVIGATOR_SETTINGS_DESTINATION_ACTIONS_WARNING",     "Se il clic singolo è impostato su Viaggia, l'azione del doppio clic non verrà eseguita")

mkstr("NAVIGATOR_SETTINGS_ZONE_ACTIONS_NAME",               "Zone")
mkstr("NAVIGATOR_SETTINGS_ZONE_ACTIONS_TOOLTIP",            "Azioni del mouse e tastiera per le zone")


mkstr("NAVIGATOR_SETTINGS_HOUSE_ACTIONS_TOOLTIP",           "Azioni del mouse e tastiera per le tue case")

--mkstr("NAVIGATOR_SETTINGS_POI_ACTIONS_NAME",                "Punti di interesse")
mkstr("NAVIGATOR_SETTINGS_POI_ACTIONS_TOOLTIP",             "Azioni del mouse e tasti per posizioni sulla mappa come città, luoghi di missioni e localita sorprendenti")

mkstr("NAVIGATOR_SETTINGS_JOIN_GUILD_NAME",                 "Unisciti alla nostra gilda!")
mkstr("NAVIGATOR_SETTINGS_JOIN_GUILD_DESCRIPTION",          "|cC5C29E|H1:guild:767808|hMora's Whispers|h è un vivace rifugio sociale con un mercante gratuito, un sacco di eventi, lotterie settimanali, la base della gilda completamente attrezzata e un discord molto attivo! Clicca sul link sopra per scoprire di più. |r")


-- -----------------------------------------------------------------------------
-- Notes: gsub uses Lua patterns - https://www.lua.org/pil/20.2.html
--        "^Thing" matches "Thing" at the start of a name
--        "Thing$" matches "Thing" at the end of a name
function Navigator.DisplayName(name)
    name = name:gsub("^Dungeon: ", "")
    name = name:gsub("^Trial: ", "")
    name = name:gsub("^Prova: ", "")
    name = name:gsub("^Santuario della ", "La ")
    name = name:gsub("^Santuario delle ", "Le ")
    name = name:gsub("^Santuario dell'", "L'")
    name = name:gsub("^Santuario di ", "")
    name = name:gsub("^Santuario del ", "")
    return name
end
function Navigator.SearchName(name)
    name = name:gsub("^Dungeon: ", "")
    name = name:gsub("^Trial: ", "")
    name = name:gsub("^Prova: ", "")
    name = name:gsub("^Santuario della ", "La ")
    name = name:gsub("^Santuario delle ", "Le ")
    name = name:gsub("^Santuario dell'", "L'")
    name = name:gsub("^Santuario di ", "")
    name = name:gsub("^Santuario del ", "")
    name = name:gsub(" II$", " II 2", 1):gsub(" I$", " I 1", 1) -- Allows searches like COA2 (for City of Ash II)
    return name
end
function Navigator.KeepSuffix(name)
    return nil
end