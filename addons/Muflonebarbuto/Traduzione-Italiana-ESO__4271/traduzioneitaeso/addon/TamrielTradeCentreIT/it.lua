-- ===========================================================================================
-- TAMRIEL TRADE CENTRE - TRADUZIONI INTERFACCIA ITALIANA
-- File: addon/TamrielTradeCentreIT/it.lua
-- Addon: Traduzione Italiana ESO
-- Autore: Muflonebarbuto
--
-- NOTA: Questo file contiene SOLO le traduzioni dell'interfaccia UI di TTC.
--       L'integrazione dei prezzi è gestita da TraduzioneItaESO_TTC.lua
-- ===========================================================================================

-- Verifica che la lingua del gioco sia italiano
if GetCVar("language.2") ~= "it" then
    return {}
end

-- Tabella traduzioni stringhe UI di TamrielTradeCentre
local translations = {
    -- ═══════════════════════════════════════════════════════════════════════════════════
    -- INTERFACCIA PRINCIPALE
    -- ═══════════════════════════════════════════════════════════════════════════════════
    
    SI_TTC_TITLE = "Tamriel Trade Centre",
    SI_TTC_SEARCH = "Cerca",
    SI_TTC_SEARCHING = "Ricerca in corso...",
    SI_TTC_CLEAR = "Pulisci",
    SI_TTC_REFRESH = "Aggiorna",
    
    -- ═══════════════════════════════════════════════════════════════════════════════════
    -- RISULTATI RICERCA
    -- ═══════════════════════════════════════════════════════════════════════════════════
    
    SI_TTC_NO_RESULTS = "Nessun risultato trovato",
    SI_TTC_RESULTS_FOUND = "<<1>> risultati trovati",
    SI_TTC_LOADING_RESULTS = "Caricamento risultati...",
    SI_TTC_ERROR_SEARCH = "Errore durante la ricerca",
    
    -- ═══════════════════════════════════════════════════════════════════════════════════
    -- COLONNE TABELLA
    -- ═══════════════════════════════════════════════════════════════════════════════════
    
    SI_TTC_ITEM_NAME = "Oggetto",
    SI_TTC_PRICE = "Prezzo",
    SI_TTC_UNIT_PRICE = "Prezzo unitario",
    SI_TTC_QUANTITY = "Quantità",
    SI_TTC_SELLER = "Venditore",
    SI_TTC_GUILD = "Gilda",
    SI_TTC_LOCATION = "Località",
    SI_TTC_LAST_SEEN = "Visto",
    SI_TTC_AGE = "Età",
    
    -- ═══════════════════════════════════════════════════════════════════════════════════
    -- PREZZI E STATISTICHE
    -- ═══════════════════════════════════════════════════════════════════════════════════
    
    SI_TTC_SUGGESTED_PRICE = "Prezzo suggerito",
    SI_TTC_AVG_PRICE = "Prezzo medio",
    SI_TTC_MIN_PRICE = "Prezzo minimo",
    SI_TTC_MAX_PRICE = "Prezzo massimo",
    SI_TTC_PRICE_PER_UNIT = "Prezzo per unità",
    
    SI_TTC_GOLD = "Oro",
    SI_TTC_GOLD_SHORT = "o",
    
    -- ═══════════════════════════════════════════════════════════════════════════════════
    -- TEMPO
    -- ═══════════════════════════════════════════════════════════════════════════════════
    
    SI_TTC_TIME_NOW = "Ora",
    SI_TTC_TIME_MINUTES = "<<1>> min",
    SI_TTC_TIME_HOURS = "<<1>> ore",
    SI_TTC_TIME_DAYS = "<<1>> giorni",
    SI_TTC_TIME_WEEKS = "<<1>> settimane",
    
    SI_TTC_JUST_NOW = "Proprio ora",
    SI_TTC_MINUTE_AGO = "1 minuto fa",
    SI_TTC_MINUTES_AGO = "<<1>> minuti fa",
    SI_TTC_HOUR_AGO = "1 ora fa",
    SI_TTC_HOURS_AGO = "<<1>> ore fa",
    SI_TTC_DAY_AGO = "1 giorno fa",
    SI_TTC_DAYS_AGO = "<<1>> giorni fa",
    
    -- ═══════════════════════════════════════════════════════════════════════════════════
    -- FILTRI
    -- ═══════════════════════════════════════════════════════════════════════════════════
    
    SI_TTC_FILTER = "Filtro",
    SI_TTC_FILTERS = "Filtri",
    SI_TTC_FILTER_REGION = "Regione",
    SI_TTC_FILTER_SERVER = "Server",
    SI_TTC_FILTER_GUILD = "Gilda",
    SI_TTC_FILTER_QUALITY = "Qualità",
    SI_TTC_FILTER_LEVEL = "Livello",
    SI_TTC_FILTER_PRICE_MIN = "Prezzo min",
    SI_TTC_FILTER_PRICE_MAX = "Prezzo max",
    
    SI_TTC_SHOW_ALL = "Mostra tutti",
    SI_TTC_RESET_FILTERS = "Reimposta filtri",
    
    -- ═══════════════════════════════════════════════════════════════════════════════════
    -- REGIONI E SERVER
    -- ═══════════════════════════════════════════════════════════════════════════════════
    
    SI_TTC_REGION_EU = "Europa",
    SI_TTC_REGION_NA = "Nord America",
    SI_TTC_SERVER_PC = "PC",
    SI_TTC_SERVER_PS = "PlayStation",
    SI_TTC_SERVER_XBOX = "Xbox",
    
    -- ═══════════════════════════════════════════════════════════════════════════════════
    -- MESSAGGI
    -- ═══════════════════════════════════════════════════════════════════════════════════
    
    SI_TTC_MSG_COPIED = "Copiato negli appunti",
    SI_TTC_MSG_WHISPER = "Invia sussurro",
    SI_TTC_MSG_MAIL = "Invia posta",
    SI_TTC_MSG_INVITE = "Invita in gruppo",
    
    SI_TTC_ERROR_CONNECTION = "Errore di connessione al server TTC",
    SI_TTC_ERROR_TIMEOUT = "Timeout richiesta",
    SI_TTC_ERROR_INVALID_ITEM = "Oggetto non valido",
    
    -- ═══════════════════════════════════════════════════════════════════════════════════
    -- TOOLTIP
    -- ═══════════════════════════════════════════════════════════════════════════════════
    
    SI_TTC_TOOLTIP_PRICE = "Prezzo TTC",
    SI_TTC_TOOLTIP_SUGGESTED = "Prezzo suggerito: <<1>>",
    SI_TTC_TOOLTIP_AVG = "Media: <<1>>",
    SI_TTC_TOOLTIP_RANGE = "Range: <<1>> - <<2>>",
    SI_TTC_TOOLTIP_SALES = "<<1>> vendite nelle ultime 24h",
    SI_TTC_TOOLTIP_CLICK = "Click per cercare su TTC",
    
    -- ═══════════════════════════════════════════════════════════════════════════════════
    -- IMPOSTAZIONI
    -- ═══════════════════════════════════════════════════════════════════════════════════
    
    SI_TTC_SETTINGS = "Impostazioni",
    SI_TTC_SETTINGS_GENERAL = "Generali",
    SI_TTC_SETTINGS_DISPLAY = "Visualizzazione",
    SI_TTC_SETTINGS_TOOLTIP = "Tooltip",
    SI_TTC_SETTINGS_NOTIFICATIONS = "Notifiche",
    
    SI_TTC_SETTING_SHOW_TOOLTIP = "Mostra prezzi nei tooltip",
    SI_TTC_SETTING_SHOW_TOOLTIP_DESC = "Mostra i prezzi TTC nei tooltip degli oggetti",
    
    SI_TTC_SETTING_AUTO_SEARCH = "Ricerca automatica",
    SI_TTC_SETTING_AUTO_SEARCH_DESC = "Cerca automaticamente l'oggetto quando lo ispezioni",
    
    SI_TTC_SETTING_SHOW_ICON = "Mostra icona minimap",
    SI_TTC_SETTING_SHOW_ICON_DESC = "Mostra l'icona TTC sulla minimap",
    
    SI_TTC_SETTING_MAX_RESULTS = "Risultati massimi",
    SI_TTC_SETTING_MAX_RESULTS_DESC = "Numero massimo di risultati da mostrare",
    
    -- ═══════════════════════════════════════════════════════════════════════════════════
    -- MERCANTI NPC (KIOSK LOCATIONS)
    -- ═══════════════════════════════════════════════════════════════════════════════════
    
    -- Glenumbra
    SI_TTC_NPC_DAYNASSADRANO = "daynas sadrano",
    SI_TTC_NPC_MAJHASUR = "majhasur",
    SI_TTC_NPC_ONURAIMAHT = "onurai-maht",
    
    -- Stormhaven
    SI_TTC_NPC_AMBARYSTERAN = "ambarys teran",
    SI_TTC_NPC_UZARRUR = "uzarrur",
    
    -- Rivenspire
    SI_TTC_NPC_GIRLADDA = "girladda",
    SI_TTC_NPC_REESA = "reesa",
    
    -- Bangkorai
    SI_TTC_NPC_RASHOMTA = "rashomta",
    SI_TTC_NPC_KERTHOR = "kerthor",
    
    -- Auridon
    SI_TTC_NPC_ELOMIN = "elomin",
    SI_TTC_NPC_PIRONDIL = "pirondil",
    
    -- Grahtwood
    SI_TTC_NPC_BURASHNA = "burashna",
    SI_TTC_NPC_FARANYON = "faranyon",
    
    -- Greenshade
    SI_TTC_NPC_ELANWEN = "elanwen",
    SI_TTC_NPC_LINDAFWE = "lindafwe",
    
    -- Malabal Tor
    SI_TTC_NPC_ARUSHNA = "arushna",
    SI_TTC_NPC_TALQUA = "talqua",
    
    -- Reaper's March
    SI_TTC_NPC_GEILA = "geila",
    SI_TTC_NPC_ENJIHABA = "enjihaba",
    
    -- Stonefalls
    SI_TTC_NPC_MADATHRAS = "madathras",
    SI_TTC_NPC_DRANOS = "dranos",
    
    -- Deshaan
    SI_TTC_NPC_GAVYNA = "gavyna",
    SI_TTC_NPC_TABIA = "tabia",
    
    -- Shadowfen
    SI_TTC_NPC_DEEGUS = "deegus",
    SI_TTC_NPC_ARUSHNA = "arushna",
    
    -- Eastmarch
    SI_TTC_NPC_BALDURGRAUFSSON = "baldur grauf's son",
    SI_TTC_NPC_FRISVALD = "frisvald",
    
    -- The Rift
    SI_TTC_NPC_GJARUND = "gjarund",
    SI_TTC_NPC_THOREKI = "thoreki",
    
    -- ═══════════════════════════════════════════════════════════════════════════════════
    -- AZIONI CONTEXT MENU
    -- ═══════════════════════════════════════════════════════════════════════════════════
    
    SI_TTC_CONTEXT_SEARCH = "Cerca su TTC",
    SI_TTC_CONTEXT_PRICE_CHECK = "Controlla prezzo",
    SI_TTC_CONTEXT_COPY_NAME = "Copia nome oggetto",
    SI_TTC_CONTEXT_COPY_LINK = "Copia link",
    
    -- ═══════════════════════════════════════════════════════════════════════════════════
    -- VARIE
    -- ═══════════════════════════════════════════════════════════════════════════════════
    
    SI_TTC_OPEN_WINDOW = "Apri finestra TTC",
    SI_TTC_CLOSE_WINDOW = "Chiudi finestra",
    SI_TTC_MINIMIZE = "Minimizza",
    SI_TTC_MAXIMIZE = "Massimizza",
    
    SI_TTC_HELP = "Aiuto",
    SI_TTC_ABOUT = "Informazioni",
    SI_TTC_VERSION = "Versione",
    
    SI_TTC_LOADING = "Caricamento...",
    SI_TTC_PLEASE_WAIT = "Attendere prego...",
    SI_TTC_DONE = "Completato",
    
    -- ═══════════════════════════════════════════════════════════════════════════════════
    -- QUALITÀ OGGETTI
    -- ═══════════════════════════════════════════════════════════════════════════════════
    
    SI_TTC_QUALITY_TRASH = "Spazzatura",
    SI_TTC_QUALITY_NORMAL = "Normale",
    SI_TTC_QUALITY_FINE = "Buono",
    SI_TTC_QUALITY_SUPERIOR = "Superiore",
    SI_TTC_QUALITY_EPIC = "Epico",
    SI_TTC_QUALITY_LEGENDARY = "Leggendario",
}

-- Ritorna le traduzioni UI (TTC le caricherà automaticamente)
return translations
