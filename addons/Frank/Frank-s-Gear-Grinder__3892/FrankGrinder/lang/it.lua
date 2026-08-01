local strings = {

    -----------
    -- Menu
    GG_MENU_LE_HEADER = "Promemoria di scadenza delle tracce",
    GG_MENU_LE_DESC = "I promemoria vengono attivati quando il giocatore cambia zona. Le tracce che scadono entro il numero di giorni impostato faranno apparire un promemoria. Dopo un promemoria, gli avvisi verranno messi in pausa per l’intervallo configurato.",
    GG_MENU_LE_ENABLED = "Attivato",
    GG_MENU_LE_ENABLED_TT = "Attivare i promemoria di scadenza delle tracce?",
    GG_MENU_LE_ANNOUNCE_REMINDERS = "Annuncia i promemoria",
    GG_MENU_LE_ANNOUNCE_REMINDERS_TT = "Mostrare un annuncio sullo schermo per i promemoria di scadenza delle tracce?",
    GG_MENU_LE_CHAT_REMINDERS = "Mostra promemoria in chat",
    GG_MENU_LE_CHAT_REMINDERS_TT = "Mostrare i promemoria nella finestra della chat?",
    GG_MENU_LE_WARNING_PERIOD = "Anticipo del promemoria (giorni) [1–20]",
    GG_MENU_LE_WARNING_PERIOD_TT = "Quanti giorni prima della scadenza della traccia deve iniziare il promemoria.",
    GG_MENU_LE_NO_WARNING_PERIOD = "Intervallo senza promemoria (minuti) [1–120]",
    GG_MENU_LE_NO_WARNING_PERIOD_TT = "L’intervallo in secondi tra un promemoria e l’altro.",
    GG_MENU_GF_HEADER = "Notifiche degli annunci del Cerca Gruppo",
    GG_MENU_GF_ENABLED = "Attivato",
    GG_MENU_GF_ENABLED_TT = "Attivare le notifiche del Cerca Gruppo nella finestra della chat?",
    GG_MENU_GF_CHECK_INTERVAL = "Intervallo di controllo (secondi) [5–60]",
    GG_MENU_GF_CHECK_INTERVAL_TT = "L’intervallo in secondi per controllare il Cerca Gruppo alla ricerca di nuovi annunci delle Prove. Minimo 5 secondi, massimo 60 secondi.",
    GG_MENU_GF_TRIAL_HEADER = "Prove da notificare dal Cerca Gruppo",
    GG_MENU_GF_TRIAL_DESC = "Nota: gli annunci creati con l’opzione \"Qualsiasi Prova\" saranno inclusi nelle notifiche.",
    GG_MENU_GF_TRIAL_TT = "Includere gli annunci %s del Cerca Gruppo?",
    GG_MENU_PA_HEADER = "Integrazione Personal Assistant",
    GG_MENU_PA_DESC = "Requisiti:\n- Addon: LibCharacterKnowledge, LibPrice (e una fonte prezzi attiva come TamrielTradeCentre, Master Merchant o Arkadius' Trade Tools)\n- Un profilo LOOT dedicato di Personal Assistant per il tuo Mercante, affinché gli oggetti in eccesso e destinati alla vendita NON vengano appresi automaticamente al prelievo dalla banca.\n\nRegole di instradamento:\n1. Oggetti sconosciuti al Crafter → inviati al Crafter\n2. Oggetti di basso valore inviati al prossimo personaggio secondo LibCharacterKnowledge\n3. Oggetti in eccesso e di alto valore inviati al Mercante (se abilitato), altrimenti lasciati in banca.",
    GG_MENU_PA_ENABLED = "Abilitato?",
    GG_MENU_PA_ENABLED_TT = "L’override di Personal Assistant è abilitato? La disattivazione richiede il ricaricamento dell’interfaccia.",
    GG_MENU_PA_SALE_VALUE_THRESHOLD = "Soglia valore di vendita",
    GG_MENU_PA_SALE_VALUE_THRESHOLD_TT = "Gli oggetti con valore di vendita inferiore o uguale a questa soglia sono considerati di basso valore.",
    GG_MENU_PA_CRAFTER_CHARACTER_NAME = "Nome del Crafter",
    GG_MENU_PA_CRAFTER_CHARACTER_NAME_TT = "Nome del personaggio che funge da Crafter.",
    GG_MENU_PA_TRADER_CHARACTER_NAME = "Nome del Mercante",
    GG_MENU_PA_TRADER_CHARACTER_NAME_TT = "Nome del personaggio che funge da Mercante.",
    GG_MENU_PA_WITHDRAW_TO_TRADER_ENABLED = "Preleva al Mercante?",
    GG_MENU_PA_WITHDRAW_TO_TRADER_ENABLED_TT = "Gli oggetti in eccesso vengono prelevati dalla banca al Mercante.",

    -----------
    -- core
    GG_LAM_NOT_FOUND = "LibAddonMenu2 non trovato, impossibile creare il menu.",
    GG_CHARACTERS = "Personaggi",
    GG_SHOW_WINDOW = "Mostra finestra",
    GG_TOGGLE_LOCATION_TRACKER = "Attiva/disattiva il tracciamento del cambio di posizione",
    GG_REMAINING = " Rimanente",
    GG_ELAPSED = " Trascorso",

    -----------
    -- Lead Expiry
    GG_LE_NEW_LEAD = "Indizio nuovo/non scoperto",
    GG_LE_LEAD = "Indizio",
    GG_LE_LORE_LEAD = "Indizio di codex/lore incompleto",
    GG_LE_EXPIRY_IN = " Scade tra ",
    GG_LE_EXPIRING_IN = "Indizio in scadenza tra ",
    GG_LE_FOUND_IN = " trovato in ",
    GG_LE_UNKNOWN_NAME = "Indizio sconosciuto",
    GG_LE_UNKNOWN_ZONE = "Zona sconosciuta",
    GG_LE_REMIND = "RIC.", 
    GG_LE_IGNORE = "IGN.",
    GG_LE_DISABLE_REMINDER = "Disattiva promemoria",
    GG_LE_ENABLE_REMINDER = "Attiva promemoria",
    GG_LE_TOGGLE_REMINDER = "Attiva/disattiva promemoria",

    -----------
    -- Group Finder
    GG_GF_NEW_LISTING = "Nuovo annuncio",
    GG_GF_UPDATED_LISTING = "Annuncio aggiornato",
    GG_GF_REMOVED_LISTING = "Annuncio rimosso",
    GG_GF_NO_LISTING = "Ricerca gruppo: |cff0000Nessun annuncio trovato.|r Verrai avvisato quando ne apparirà uno.",

    -----------
    -- Location Change
    GG_LOCATION_CHANGED = "Posizione cambiata",
    GG_LOCATION_ENABLED = "Tracciamento del cambio di posizione attivato",
    GG_LOCATION_DISABLED = "Tracciamento del cambio di posizione disattivato",

    -----------
    -- Night Market
    GG_NM_MENU_ELMS_GUIDANCE_HEADER = "Guida agli obiettivi delle missioni del Mercato Notturno",
    GG_NM_MENU_BLUE_MARKERS = "I marcatori blu indicano una possibile posizione di inizio missione.",
    GG_NM_MENU_GREEN_MARKERS = "I marcatori verdi mostrano una possibile posizione dell'obiettivo della missione.",
    GG_NM_MENU_NOTE_ON_ELMS = "Nota: devi avere ElmsMarkers installato e abilitato perché questi marcatori appaiano.",
    GG_NM_MENU_QUEST_LIST_HDR = "I numeri corrispondono alle seguenti missioni.",
    GG_NM_MENU_HIDE_TRACKER = "Nascondi il tracciatore del punteggio di fazione",
    GG_NM_MENU_HIDE_TRACKER_TT = "Nasconde i punteggi di fazione del Mercato Notturno sullo schermo.",
    GG_NM_MENU_ELMS_ENABLE = "Abilitare l'iniezione dei marcatori di ElmsMarkers?",
    GG_NM_MENU_ELMS_ENABLE_TT = "Aggiunge marcatori 3D in ElmsMarkers per le missioni del Mercato Notturno.",
    GG_NM_GROUP_AUTO = "Automazione gruppo Argent",
    GG_NM_GROUP_AUTO_OFF = "DISATTIVATO",
    GG_NM_GROUP_AUTO_ON = "ATTIVATO",
    GG_NM_GROUP_AUTO_ERROR_NOTINZONE = "Non nella zona evento",
    GG_NM_GROUP_AUTO_ERROR_ZONENOTACTIVE = "Zona evento non attiva",
    GG_NM_GROUP_AUTO_ERROR_FAILEDTWICE = "Creazione Cerca Gruppo fallita due volte",
    GG_NM_GROUP_AUTO_ALLDONE = "Tutte le chiavi ottenute",
    GG_NM_GROUP_AUTO_LISTINGREMOVED = "Annuncio rimosso",
    GG_NM_GROUP_AUTO_QUESTSHARE1 = "Condivise",
    GG_NM_GROUP_AUTO_QUESTSHARE2 = "missione/i con il gruppo.",
    GG_NM_GROUP_AUTOMATION_KEYBIND = "Attiva/disattiva automazione gruppo Argent",


    -----------
    -- Time
    GG_TIME_SECONDS = "secondi",
    GG_TIME_MINUTES = "minuti",
    GG_TIME_HOURS = "ore",
    GG_TIME_DAYS = "giorni",
    GG_TIME_NONE = "Nessuno",

}

for id, val in pairs(strings) do
   ZO_CreateStringId(id, val)
   SafeAddVersion(id, 1)
end