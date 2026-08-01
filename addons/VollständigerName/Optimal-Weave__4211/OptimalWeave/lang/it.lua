-- =============================================================================
-- === OptimalWeave Language File: Italian (it.lua)                           ===
-- =============================================================================
--[[
    AddOn Name:         OptimalWeave
    File:               lang/it.lua
    Description:        Italian localization using ZO_CreateStringId
    Version:            1.17.0
    Author:             Orollas & VollständigerName
--]]
-- =============================================================================

-- =============================================================================
-- == PANEL & AUTHOR INFORMATION ===============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_PANEL_NAME", "|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r")
ZO_CreateStringId("OW_MENU_AUTHORS", "|cEE82EEO|r|cDD74ECr|r|cCD65EAo|r|cBC57E8l|r|cAB48E6l|r|c9B3AE4a|r|c8A2BE2s|r & |cFFD700Vo|r|cF7D418l|r|cF3D324l|r|cEFD130s|r|cEBD03Ctä|r|cE3CD54n|r|cE0CC60d|r|cDCCA6Ci|r|cD8C978g|r|cD4C784e|r|cD0C690r|r|cCCC49CNa|r|cC4C1B4me|r")
ZO_CreateStringId("OW_MENU_WEBSITE", "https://github.com/VollstaendigerName")

-- =============================================================================
-- == INFORMATION SECTION ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_INFO_HEADER", "Informazioni & README")
ZO_CreateStringId("OW_MENU_INFO_TEXT", "Il cooldown globale (GCD) è di 1000ms. OptimalWeave gestisce la coda delle abilità in base alla modalità selezionata. Personalizza il comportamento con le impostazioni.")
ZO_CreateStringId("OW_MENU_MODE_HEADER", "Meccaniche principali")
ZO_CreateStringId("OW_MENU_CONDITIONS_HEADER", "Regole di attivazione")
ZO_CreateStringId("OW_MENU_ADVANCED_HEADER", "Controlli avanzati")
ZO_CreateStringId("OW_MENU_PERFORMANCE_HEADER", "Impostazioni prestazioni")
ZO_CreateStringId("OW_MENU_MODE_ACTIVE", "Addon attivo")
ZO_CreateStringId("OW_MENU_MODE_INACTIVE", "Addon inattivo")
ZO_CreateStringId("OW_MENU_DISABLED_TOOLTIP", "Questa opzione è disabilitata")
ZO_CreateStringId("OW_MENU_LATENCY_WARNING", "Attenzione: Latenza alta può causare lag!")

ZO_CreateStringId("OW_MENU_DISCLAIMER_LABEL", "|cFF0000Disclaimer|r") 
ZO_CreateStringId("OW_MENU_DISCLAIMER_TOOLTIP", "|cFF0000Disclaimer:|r Questo addon non è affiliato con ZeniMax Media Inc. The Elder Scrolls® è un marchio registrato di ZeniMax Media Inc. Tutti i diritti riservati.")

-- =============================================================================
-- == CORE SETTINGS ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SETTINGS_HEADER", "Impostazioni principali")
ZO_CreateStringId("OW_MENU_MODE_LABEL", "Modalità operativa")
ZO_CreateStringId("OW_MENU_MODE_TOOLTIP", "|c00FF00Sequenziale:|r Consente l’uso delle abilità solo dopo un attacco leggero.\n|cFF0000Rigido:|r Blocco totale. Nessuna coda durante GCD.\n|cFFFF00Intelligente:|r Coda permessa solo senza Attacco Leggero.\n|c00FFFFNessuno:|r Disabilitato.")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_COND", "Sequenziale")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_HARD", "Rigido")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_SOFT", "Intelligente")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_NONE", "Nessuno")
ZO_CreateStringId("OW_MENU_COMBAT_LABEL", "Attivo solo in combattimento")
ZO_CreateStringId("OW_MENU_COMBAT_TOOLTIP", "Gestisce la coda solo durante il combattimento.")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_LABEL", "Richiede bersaglio nemico")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_TOOLTIP", "Richiede un bersaglio nemico selezionato.")
ZO_CreateStringId("OW_MENU_BLOCKING_LABEL", "Ignora durante blocco")
ZO_CreateStringId("OW_MENU_BLOCKING_TOOLTIP", "Disabilita i controlli durante il blocco.")
ZO_CreateStringId("OW_MENU_GROUNDAOE_LABEL", "Blocca doppio lancio AoE")
ZO_CreateStringId("OW_MENU_GROUNDAOE_TOOLTIP", "Previene doppi lanci accidentali di abilità a terra.")
ZO_CreateStringId("OW_MENU_DISABLE_TANK", "Disabilita come Tank")
ZO_CreateStringId("OW_MENU_DISABLE_TANK_TOOLTIP", "Disabilita automaticamente nel ruolo Tank")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL", "Disabilita come Healer")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL_TOOLTIP", "Disabilita automaticamente nel ruolo Healer")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR", "Disattiva funzioni sulla barra secondaria")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP", "Disattiva la maggior parte delle funzioni dell'addon sulla barra secondaria.")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR", "Disattiva assistente weaving sulla barra secondaria")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP", "Disattiva l'assistente weaving (gestione GCD) sulla barra secondaria.")

ZO_CreateStringId("OW_MENU_DEACTIVATE_IN_PVP_HEADER", "Disattivazione in PvP")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP", "Disattiva funzioni in PvP")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP", "Disattiva la maggior parte delle funzioni dell'addon nelle aree PvP")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP", "Disattiva assistente tessitura in PvP")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP", "Disattiva l'assistente tessitura (gestione GCD) nelle aree PvP")

-- =============================================================================
-- == BLOCK ID SETTINGS ========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKED_HEADER", "Abilità bloccate")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_LABEL", "Blocca nuovo ID")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_TOOLTIP", "Inserisci ID abilità (es. 134160)")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_LABEL", "ID attualmente bloccati")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_TOOLTIP", "Clicca per rimuovere")

-- =============================================================================
-- == ADVANCED SETTINGS ========================================================
-- =============================================================================
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL", "Buffer istantaneo (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL_TOOLTIP", "Margine di sicurezza per abilità istantanee (0-100ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED", "Buffer incanalate (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED_TOOLTIP", "Buffer per abilità incanalate (0-400ms)")
ZO_CreateStringId("OW_MENU_GCD_SLOT", "Slot rilevamento GCD")
ZO_CreateStringId("OW_MENU_GCD_SLOT_TOOLTIP", "Slot barra azioni per GCD (1-8)")
ZO_CreateStringId("OW_MENU_MIN_GCD", "Soglia minima GCD (ms)")
ZO_CreateStringId("OW_MENU_MIN_GCD_TOOLTIP", "Durata minima GCD per rilevamento (0-20ms)")
ZO_CreateStringId("OW_MENU_RESET_TIME_LABEL", "Tempo di reset (secondi)")
ZO_CreateStringId("OW_MENU_RESET_TIME_TOOLTIP", "Reimposta il tracciamento dopo non aver lanciato nulla per questo numero di secondi.")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_LABEL", "Slot di tracciamento GCD automatico")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_TOOLTIP", "Seleziona automaticamente il miglior slot di tracciamento GCD dagli slot 3-8")
ZO_CreateStringId("OW_MENU_QUEUE_TIME", "Tempo base coda (ms)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME_TOOLTIP", "Finestra coda predefinita (100-2000ms)")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_LABEL", "Reset cambio arma")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_TOOLTIP", "Resetta GCD al cambio arma")
ZO_CreateStringId("OW_MENU_RESETONDODGE_LABEL", "Reset schivata")
ZO_CreateStringId("OW_MENU_RESETONDODGE_TOOLTIP", "Resetta GCD durante la schivata")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_LABEL", "Sguainare automaticamente")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP", "Sguaina automaticamente le armi in combattimento")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_LABEL", "Reimposta tutto")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_TOOLTIP", "Reimposta tutte le impostazioni ai valori predefiniti")

-- =============================================================================
-- == LATENCY COMPENSATION =====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_LATENCY_HEADER", "Compensazione latenza")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_LABEL", "Regolazione automatica")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_TOOLTIP", "Regola automaticamente in base alla latenza. Consigliato per connessioni stabili.")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_LABEL", "Latenza manuale (ms)")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_TOOLTIP", "Valore fisso per connessioni instabili (0-200ms).")

-- =============================================================================
-- == (SUB)CLASS SETTINGS ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SUBCLASS_HEADER", "Impostazioni classe e gilda")
ZO_CreateStringId("OW_MENU_SUBCLASS_GRIMFOCUS", "Bruco Focalizzazione")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS", "Stack richiesti")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS_TOOLTIP", "Numero di stack per l'attivazione (consigliato: 10)")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS", "Blocca tutti i morph")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP", "|cFF5555• Focalizzazione Instancabile:|r Sempre bloccato\n|cFFFF00• Bruco Focalizzazione e Determinazione Spietata:|r Usabile solo a 10 stack\n|cAAAAAADisabilita:|r Comportamento predefinito")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE", "Abilita stack personalizzati")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP", "|cFFD700Abilitato:|r Usa impostazione stack \n|cAAAAAADisabilitato:|r Blocca sempre fino a 10 stack\n")

-- == BLOCK GUILDS SETTINGS ===================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_GUILDS", "Gilde")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS", "Blocca abilità cacciatore della Gilda dei Guerrieri")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS_TOOLTIP", "Blocca tutti i morph delle abilità cacciatore della Gilda dei Guerrieri (Cacciatore Esperto, Cacciatore Mimetizzato & Cacciatore del Male)")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS", "Blocca abilità luce della Gilda dei Maghi")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS_TOOLTIP", "Blocca tutti i morph delle abilità luce (Luce Magica, Luce Interiore & Luce Magica Raggiante)")

ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS", "Disabilita in PvP")
ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP", "Disabilita il blocco abilità Cacciatore/Luce in PvP")

-- == BLOCK MOLTEN WHIP SETTINGS ===============================================

ZO_CreateStringId("OW_MENU_SUBCLASS_MOLTENWHIP", "Frusta Fusa")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK", "Blocca abilità Frusta Fusa")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK_TOOLTIP", "Blocca l'abilità Frusta Fusa per evitare di perdere i tre stack")

-- == BLOCK FATECARVER SETTINGS ================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_FATECARVER", "Arcanista Fatecarver")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS", "Blocca lancio Fatecarver")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP", "Blocca il lancio fino al soddisfacimento delle condizioni.")
ZO_CreateStringId("OW_MENU_CRUX_STACKS", "Stack Crux richiesti")
ZO_CreateStringId("OW_MENU_CRUX_STACKS_TOOLTIP", "Stack Crux minimi per il lancio (consigliato: 3)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM", "Soglia HP (%)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP", "Disabilita blocco Fatecarver quando HP è inferiore a questo valore")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE", "Abilita controllo HP per Fatecarver")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP", "Disabilita blocco Fatecarver quando la salute è bassa")

ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM", "Soglia Vigore (%)")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP", "Disabilita il blocco di Fatecarver quando il Vigore è basso")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE", "Abilita controllo Vigore per Fatecarver")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP", "Disabilita il blocco di Fatecarver quando il vigore è basso")

-- == BLOCK CEPHALIARCH'S FLAIL SETTINGS =======================================
ZO_CreateStringId("OW_MENU_SUBCLASS_CEPHALIARCHSFLAIL", "Flagello del Cefaliarco")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL", "Blocca Flagello del Cefaliarco")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL_TOOLTIP", "Blocca il Flagello del Cefaliarco quando hai 3 accumuli di Crux")

-- == BLOCK TENTACULAR DREAD SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_TENTACULAR", "Tentacular Dread")
ZO_CreateStringId("OW_MENU_TENTACULAR", "Blocca Tentacular Dread")
ZO_CreateStringId("OW_MENU_TENTACULAR_TOOLTIP", "Blocca l'abilità Tentacular Dread fino al soddisfacimento delle condizioni.")

-- == Execute Check Settings ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_HEADER", "Controllo Esecuzione")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE", "Abilita controllo esecuzione")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE_TOOLTIP", "Abilita o disabilita la funzione di controllo esecuzione")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD", "Soglia Esecuzione (%)")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD_TOOLTIP", "Percentuale di salute del bersaglio al di sotto della quale sono consentiti gli incantesimi di esecuzione")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELLS_HEADER", "Incantesimi di Esecuzione")

-- == Grouped Execute Spells ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS", "Distruzione Radiosa, Gloria Radiosa, Oppressione Radiosa")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP", "Blocca i morph di Distruzione Radiosa finché il bersaglio non è nell'intervallo di esecuzione")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS", "Lama dell'Assassino, Incidere, Lama del Killer")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP", "Blocca i morph di Lama dell'Assassino finché il bersaglio non è nell'intervallo di esecuzione")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS", "Ira dei Maghi, Furia dei Maghi, Furia Infinita")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP", "Blocca i morph di Furia dei Maghi finché il bersaglio non è nell'intervallo di esecuzione")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS", "Fendente Inverso, Colpo Inverso, Boia")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP", "Blocca i morph di Fendente Inverso finché il bersaglio non è nell'intervallo di esecuzione")

-- == Work in progress ================================================
ZO_CreateStringId("OW_WIP", "WIP")

-- =============================================================================
-- == WEAPON SETTINGS ==========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEADER", "Disattiva in base al tipo di arma")

ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON", "Disattiva assistente weaving sul tipo di arma")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP", "Disattiva solo l'assistente weaving (gestione GCD) per i tipi di arma selezionati")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON", "Disattiva funzioni sul tipo di arma")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP", "Disattiva la maggior parte delle funzioni dell'addon per i tipi di arma selezionati")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE", "Ascia")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP", "Disattiva quando è equipaggiata un'ascia")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER", "Martello")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP", "Disattiva quando è equipaggiato un martello")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD", "Spada")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP", "Disattiva quando è equipaggiata una spada")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER", "Pugnale")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP", "Disattiva quando è equipaggiato un pugnale")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD", "Spada a due mani")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP", "Disattiva quando è equipaggiata una spada a due mani")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE", "Ascia a due mani")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP", "Disattiva quando è equipaggiata un'ascia a due mani")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER", "Martello a due mani")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP", "Disattiva quando è equipaggiato un martello a due mani")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW", "Arco")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP", "Disattiva quando è equipaggiato un arco")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF", "Bastone del fuoco")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP", "Disattiva quando è equipaggiato un bastone del fuoco")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF", "Bastone del gelo")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP", "Disattiva quando è equipaggiato un bastone del gelo")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF", "Bastone del fulmine")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP", "Disattiva quando è equipaggiato un bastone del fulmine")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF", "Bastone della guarigione")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP", "Disattiva quando è equipaggiato un bastone della guarigione")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD", "Scudo")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP", "Disattiva quando è equipaggiato uno scudo")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE", "Runa")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP", "Disattiva quando è equipaggiata una runa")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE", "Nessuna arma")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP", "Disattiva quando non è equipaggiata alcuna arma")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED", "Arma riservata")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP", "Disattiva quando è equipaggiato un tipo di arma riservato")

-- =============================================================================
-- == CUSTOM BLOCK LIST SETTINGS ===============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLIST_HEADER", "Liste di blocco personalizzate")
ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_HEADER", "Lista di Blocco Personalizzata")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_DESC", "Aggiungi ID abilità per bloccarle. Puoi anche aggiungere incantesimi facendo clic con il tasto destro sullo slot della barra delle azioni (richiede ricaricamento)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_LABEL", "ID Abilità")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP", "Inserisci l'ID numerico dell'abilità (es. 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_ADD_BUTTON", "Aggiungi alla Lista di Blocco")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_LIST_HEADER", "Abilità Bloccate:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST", "Attiva Lista di Blocco Personalizzata")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP", "Attiva o disattiva la funzionalità della lista di blocco personalizzata")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SV_DESC", "Controlla il tuo file SavedVariables:\n customBlockList = {\n   [AbilityID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK", "Abilita controllo salute per lista di blocco personalizzata")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Se abilitato, gli incantesimi nella lista di blocco saranno bloccati solo se la tua salute è sopra la soglia.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT", "Soglia salute per lista di blocco personalizzata (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Gli incantesimi della lista di blocco sono bloccati solo quando la tua salute è superiore a questa percentuale.")

-- =============================================================================
-- == CUSTOM RECAST BLOCK LIST SETTINGS ========================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLERECASTBLOCK_HEADER", "Lista di Blocco Rilancio Personalizzata")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_DESC", "Aggiungi ID abilità per bloccarle dall'essere rilanciate fino a quando il tempo effetto rimanente è inferiore alla soglia. Puoi anche aggiungere incantesimi facendo clic con il tasto destro sullo slot della barra delle azioni (richiede ricaricamento).")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL", "ID Abilità")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP", "Inserisci l'ID numerico dell'abilità (es. 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON", "Aggiungi alla Lista di Blocco Rilancio")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER", "Abilità Bloccate per Rilancio:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST", "Attiva Lista di Blocco Rilancio Personalizzata")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP", "Attiva o disattiva la funzionalità della lista di blocco rilancio personalizzata")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME", "Tempo di Blocco Rilancio (s)")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME_TOOLTIP", "Tempo in secondi sotto il quale un'abilità nella lista di blocco rilancio può essere rilanciata (1.0 = 1 secondo)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SV_DESC", "Controlla il tuo file SavedVariables:\n customRecastBlockList = {\n   [AbilityID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK", "Abilita controllo salute per lista di blocco rilancio personalizzata")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Se abilitato, gli incantesimi nella lista di blocco rilancio saranno bloccati solo se la tua salute è sopra la soglia.")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT", "Soglia salute per lista di blocco rilancio personalizzata (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Gli incantesimi della lista di blocco rilancio sono bloccati solo quando la tua salute è superiore a questa percentuale.")

-- =============================================================================

ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_MAIN_TEXT", "L'ID dell'abilità è stato aggiunto/rimosso. Se non vuoi aggiungere o rimuovere altre abilità, per favore ricarica l'interfaccia per visualizzare i cambiamenti.")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_YES", "Ricarica interfaccia")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_LATER", "Più tardi")

ZO_CreateStringId("OW_MENU_DIALOG_BUTTON_OK", "OK")
ZO_CreateStringId("OW_MENU_INVALID_ID_DIALOG_MAIN_TEXT", "Errore: Inserisci un ID abilità valido")
ZO_CreateStringId("OW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT", "L'ID dell'abilità non esiste")
ZO_CreateStringId("OW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT", "L'ID dell'abilità è già nella lista di blocco")

-- =============================================================================
-- == RESOURCE-BASED BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER", "Lista di blocco basata sulle risorse")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_RESOURCE_DESC", "Aggiungi ID abilità per bloccarle quando la tua risorsa principale (Magicka o Vigore) è sotto la soglia. Puoi anche aggiungere abilità facendo clic con il tasto destro sullo slot della barra delle azioni (richiede ricaricamento).")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST", "Abilita lista di blocco basata sulle risorse")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST_TOOLTIP", "Abilita o disabilita la funzionalità della lista di blocco basata sulle risorse")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK", "Abilita controllo risorsa")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK_TOOLTIP", "Quando abilitato, le abilità nella lista di blocco risorse saranno bloccate solo se la tua risorsa principale (Magicka o Vigore) è sopra la soglia.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT", "Soglia risorsa (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT_TOOLTIP", "Le abilità nella lista di blocco risorse sono bloccate solo quando la tua risorsa principale (Magicka o Vigore) è superiore a questa percentuale.")
ZO_CreateStringId("OW_MENU_RESOURCE_BLOCK_SPELL", "Abilità: ")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK", "Controllo Magicka")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK_TOOLTIP", "Abilita il blocco basato su Magicka per questa abilità")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE", "Blocca quando Magicka è sotto la soglia")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE_TOOLTIP", "Blocca l'abilità quando Magicka è sotto la soglia (deseleziona per consentire solo quando sotto)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD", "Soglia Magicka (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD_TOOLTIP", "Soglia percentuale di Magicka")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK", "Controllo Vigore")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK_TOOLTIP", "Abilita il blocco basato su Vigore per questa abilità")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE", "Blocca quando Vigore è sotto la soglia")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE_TOOLTIP", "Blocca l'abilità quando Vigore è sotto la soglia (deseleziona per consentire solo quando sotto)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD", "Soglia Vigore (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD_TOOLTIP", "Soglia percentuale di Vigore")

-- =============================================================================
-- == KEYBINDINGS LOCALIZATION =================================================
-- =============================================================================

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_OPTIMALWEAVE", "|c6D6D6DOpti|r|c8A8A8AmalWea|r|cC4C4C4ve|r")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_MODE", "Alterna Modalità (Rigido/Intelligente/Disabilitato)")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_BLOCK_LIST", "Alterna Lista di Blocco Personalizzata")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_RECAST_BLOCK_LIST", "Alterna Lista di Blocco Rilancio Personalizzata")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_FEATURES", "Alterna Disattivazione Funzioni Barra Secondaria")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_WEAVE_ASSIST", "Alterna Disattivazione Assistente Tessitura Barra Secondaria")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_EXECUTE_CHECK", "Alterna Controllo Esecuzione")

-- =============================================================================
-- == REMOVE BUTTON ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON", "Rimuovi")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP", "Rimuovi questa abilità dalla lista di blocco (/reloadui richiesto)")

-- =============================================================================
-- == SETTIINGS MODE ===========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_MODE_SELECTION_LABEL", "Modalità impostazioni")
ZO_CreateStringId("OW_MENU_MODE_SELECTION_TOOLTIP", "Scegli se le impostazioni sono condivise tra tutti i personaggi di questo account (Condiviso sull'account) o salvate separatamente per ogni personaggio (Per personaggio).")
ZO_CreateStringId("OW_MENU_MODE_ACCOUNTWIDE", "Condiviso sull'account")
ZO_CreateStringId("OW_MENU_MODE_PERCHARACTER", "Per personaggio")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_SETTINGS_MAIN_TEXT", "La modalità impostazioni è cambiata. Ricaricare l'interfaccia per applicare le modifiche?")

-- =============================================================================
-- == IN COMBAT MENU BLOCKING ==================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU", "Blocca ultimo menu in combattimento")
ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU_TOOLTIP", "Impedisce l'apertura dell'ultimo menu (ALT) durante il combattimento.")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU", "Blocca menu personaggio in combattimento")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU_TOOLTIP", "Impedisce l'apertura del menu personaggio (C) durante il combattimento.")

-- =============================================================================
-- == GCD DISPLAY ==============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SHOW_GCD_LABEL", "Mostra il tempo di ricarica globale (GCD)")
ZO_CreateStringId("OW_MENU_SHOW_GCD_TOOLTIP", "Mostra l'indicatore GCD (fornito da ZOS) sopra la barra delle azioni.")

-- =============================================================================
-- == BLOCKLIST COMBAT ONLY ====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_LABEL", "Liste di blocco solo in combattimento")
ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_TOOLTIP", "Tutte le liste di blocco personalizzate sono attive solo durante il combattimento. Fuori dal combattimento, tutte le liste di blocco sono disabilitate.")

-- =============================================================================
-- === END OF ITALIAN LOCALIZATION ============================================
-- =============================================================================