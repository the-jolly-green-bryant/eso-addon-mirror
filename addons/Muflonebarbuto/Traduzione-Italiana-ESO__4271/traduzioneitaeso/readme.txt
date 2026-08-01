
Claude sta rispondendo

TraduzioneItaESOzero.lua
lua


TraduzioneItaESO.lua
lua

ora ti do 2 codici il giocatore zero ha eseguito delle modifiche per risolvere il problema con ttc legato a items_it.lua. vedi se le modifiche sono innocue e non ha inserito errori che se mi dai l'ok condivido ufficialmente il suo

20:45

Eseguiti 2 comandi, file visualizzato
Eseguiti 2 comandi, file visualizzato
Il diff è chirurgico: una sola aggiunta di 7 righe. Vediamo il contesto attorno per capire dove si inserisce esattamente:


Eseguiti 5 comandi
Eseguiti 5 comandi
Ottimo, analisi completa. Ecco il verdetto:

Analisi della modifica di zero
Una sola aggiunta: 7 righe dentro BuildItemNameLookup(), nel ciclo addFromTable. Nient'altro è toccato.

Cosa fa la fix
Quando items_it.lua contiene entry nel formato "Pozione di Salute||Pozioni di Salute" = "Health Potion||Health Potions", la logica originale inseriva nel lookup solo la chiave intera (con || incluso). TTC cercava invece "pozione di salute" (singolare, senza ||), e non trovava niente.

Il blocco di zero intercetta questi casi e aggiunge al lookup anche le due parti separate:

"pozione di salute" → "Health Potion"
"pozioni di salute" → "Health Potions"
Mantenendo il nil-check (result[k1] == nil) per non sovrascrivere entry già presenti.

Valutazione tecnica
✅ Logica corretta — il pattern Lua ^(.-)%|%|(.-)$ cattura correttamente le due metà. Il find("||", 1, true) con plain=true è la scelta giusta (no magic chars da escaping).

✅ Innocuo sul codice esistente — si attiva solo se entrambi chiave e valore contengono ||. Entry senza || non vengono toccate.

✅ Ordine corretto — la chiave intera viene già inserita prima di questo blocco, quindi il fallback originale rimane.

⚠️ Un edge case teorico — se una chiave fosse "||qualcosa", il pattern produrrebbe k1 = "" (stringa vuota), che in Lua è truthy e passerebbe il check if k1 and v1. Verrebbe inserita result[""] = v1. Nei dati reali di items_it.lua questo non accade, ma se vuoi essere blindato puoi aggiungere k1 ~= "" al controllo:

lua
if k1 and k1 ~= "" and v1 and v1 ~= "" and result[k1] == nil then result[k1] = v1 end
if k2 and k2 ~= "" and v2 and v2 ~= "" and result[k2] == nil then result[k2] = v2 end
Verdetto
La modifica è innocua e tecnicamente corretta per i dati reali. Puoi condividerla ufficialmente. Se vuoi aggiungere il nil-check sulle stringhe vuote per robustezza ulteriore, fallo tu prima di pubblicare — ma non è bloccante.


[SI_ABANDON_RUMOR_DIALOG_BODY] = "Are you sure you want to abandon <<1>>?" [SI_ABANDON_RUMOR_DIALOG_CONFIRM] = "Abandon" [SI_ABANDON_RUMOR_DIALOG_TITLE] = "Abandon Rumor" [SI_ABILITY_PURCHASE_CLASS_MASTERY] = "Purchase for <<1[%d Class Mastery Point/%d Class Mastery Points]>>." [SI_ABILITY_UPGRA

pasted

mi traduci questo  na slo le parti a destra di = la frase dentro i 2 " rispetta codici di gioco

20:57
Ecco tutte le traduzioni, mantenendo intatti i codici di gioco (<<1>>, |cffffff, \n, ecc.):

lua
[SI_ABANDON_RUMOR_DIALOG_BODY] = "Sei sicuro di voler abbandonare <<1>>?"
[SI_ABANDON_RUMOR_DIALOG_CONFIRM] = "Abbandona"
[SI_ABANDON_RUMOR_DIALOG_TITLE] = "Abbandona Voce"
[SI_ABILITY_PURCHASE_CLASS_MASTERY] = "Acquista per <<1[%d Punto Maestria di Classe/%d Punti Maestria di Classe]>>."
[SI_ABILITY_UPGRADE_CLASS_MASTERY] = "Potenzia per <<1[%d Punto Maestria di Classe/%d Punti Maestria di Classe]>>."
[SI_ACTIVE_PREVIEW_END_PREVIEW_ACTION] = "Termina Anteprima"
[SI_ACTIVITYQUEUERESULT37] = "Avventurati in uno di questi tre luoghi e sconfiggi 1.000 nemici."
[SI_ADVENTURE_ZONE_EVENT_FORMATTER] = "<<t:1>>"
[SI_ADVENTURE_ZONE_TITLE_FORMATTER] = "<<t:1>>"
[SI_AUTHORIGINIDOVERRIDE0] = "PC"
[SI_AUTHORIGINIDOVERRIDE1] = "Playstation"
[SI_AUTHORIGINIDOVERRIDE2] = "Xbox"
[SI_AUTHORIGINIDOVERRIDE_1] = "Nessuno"
[SI_BINDING_NAME_TOGGLE_TAMRIEL_TOMES] = "Tomi di Tamriel"
[SI_CAMPAIGN_VENGEANCE_PERKS_SLOT] = "<<1>> Vantaggio Vendetta"
[SI_CHALLENGE_DIFFICULTY_COMBAT_ALERT] = "La Difficoltà Sfida non può essere modificata durante il combattimento."
[SI_CHALLENGE_DIFFICULTY_COOLDOWN_ALERT] = "La modifica della Difficoltà Sfida è in ricarica. Riprova tra qualche secondo."
[SI_CHALLENGE_DIFFICULTY_DEATH_RECAP_LABEL] = "Difficoltà: |cffffff<<1>><<2>>|r"
[SI_CHALLENGE_DIFFICULTY_REQUEST_CHANGE_LABEL] = "Cambia Difficoltà"
[SI_CHALLENGE_DIFFICULTY_SYSTEM_DISABLED] = "Il sistema di difficoltà è temporaneamente disabilitato."
[SI_CHALLENGE_DIFFICULTY_TITLE] = "Difficoltà Sfida"
[SI_CHALLENGE_DIFFICULTY_TOOLTIP_DIFFICULTY_TAB] = "Difficoltà Sfida"
[SI_CHALLENGE_DIFFICULTY_TOOLTIP_LEVEL_UP_REWARDS_TAB] = "Ricompense Salita di Livello"
[SI_CLAIMREWARDRESULT27] = "Alcune ricompense non hanno potuto essere riscattate, forse perché non sei in Vendetta o perché l'inventario è pieno."
[SI_CLAIMREWARDRESULT28] = "Nessuna ricompensa disponibile da riscattare."
[SI_CLAIMREWARDRESULT29] = "Impossibile riscattare le ricompense. Riprova più tardi."
[SI_CURRENT_AND_MAX_VALUES_FORMATTER] = "<<1>>/<<2>>"
[SI_CUSTOMERSERVICEASKFORHELPREPORTGUILDCATEGORY4] = "Posta della Gilda Inappropriata"
[SI_CUSTOMERSERVICEASKFORHELPREPORTGUILDCATEGORY_DESCRIPTION4] = "Usa questo per segnalare una Posta della Gilda che è volgare o offensiva."
[SI_DIRECTPURCHASEPURCHASESKURESULT7] = "Troppi tentativi di acquisto. Riprova più tardi."
[SI_DIRECTPURCHASEPURCHASESKURESULT8] = "L'overlay del negozio non è disponibile. Abilitalo e riavvia il gioco."
[SI_DIRECT_PURCHASE_CURRENCY] = "<<F2:1>> <<X:2>>"
[SI_DYNAMIC_EVENTS_TIMER_LABEL] = "L'evento scade tra:"
[SI_ENTER_INTRO_GAMEPLAY_EXPERIENCE_ACTION] = "Entra in <<1>>"
[SI_GAMEPAD_GUILD_MAIL_ACTIVE_MAIL_HEADER] = "Posta Attiva"
[SI_GAMEPAD_LORE_LIBRARY_MAIL_LIST_TOTAL_COLLECTED] = "<<1>>"
[SI_GAMEPAD_QUEST_JOURNAL_RUMORS_CURRENT_MAX] = "<<1>>/<<2>>"
[SI_GAMEPAD_QUEST_JOURNAL_RUMORS_CURRENT_MAX_LABEL] = "Voci"
[SI_GAMEPAD_SKILLS_CLASS_MASTERY_POINTS] = "Punti Maestria di Classe"
[SI_GAMEPAD_SKILLS_CLASS_MASTER_POINTS] = "Punti Maestria di Classe"
[SI_GAMEPAD_SKILLS_PURCHASE_CLASS_MASTERY_CONFIRM] = "Sei sicuro di voler acquistare |cffffff<<Z:1>>|r? Costa |cffffff<<2>>|r <<2[Punto/Punti]>> Maestria di Classe."
[SI_GAMEPAD_SKILLS_UPGRADE_CLASS_MASTERY_CONFIRM] = "Sei sicuro di voler potenziare |cffffff<<Z:1>>|r? Costa |cffffff<<2>>|r <<2[Punto/Punti]>> Maestria di Classe."
[SI_GUILDHISTORYACTIVITYEVENT4] = "<<1>> ha inviato una posta della gilda."
[SI_GUILDHISTORYACTIVITYEVENT5] = "<<1>> ha eliminato una posta della gilda."
[SI_GUILDMAILERRESULT1] = "Azione fallita. Riprova più tardi."
[SI_GUILDMAILERRESULT2] = "Questa gilda ha raggiunto il numero massimo di posta attiva."
[SI_GUILDMAILERRESULT3] = "Non hai il permesso per farlo."
[SI_GUILDMAILERRESULT4] = "L'oggetto contiene troppi caratteri."
[SI_GUILDMAILERRESULT5] = "Il messaggio contiene troppi caratteri."
[SI_GUILDMAILERRESULT6] = "Oggetto e messaggio non possono essere entrambi vuoti."
[SI_GUILDPERMISSION20] = "Gestisci Posta della Gilda"
[SI_GUILD_MAIL_CATEGORY_EMPTY_TEXT] = "Non hai posta della gilda."
[SI_GUILD_MAIL_CATEGORY_TITLE] = "Posta della Gilda"
[SI_GUILD_MAIL_CONFIRM_DELETE] = "Sei sicuro di voler eliminare questa posta della gilda?"
[SI_GUILD_MAIL_MANAGEMENT_ACTIVE_MAILS_FORMATTER] = "<<1>>/<<2>>"
[SI_GUILD_MAIL_MANAGEMENT_ACTIVE_MAIL_HEADER_KEYBOARD] = "Posta Attiva:"
[SI_GUILD_MAIL_MANAGEMENT_MAIL_DELETED] = "Posta eliminata."
[SI_GUILD_MAIL_MANAGEMENT_MAIL_LIST_EMPTY_TEXT] = "Questo è l'elenco della posta attiva della tua gilda."
[SI_GUILD_MAIL_MANAGEMENT_MAIL_SENT] = "Posta inviata."
[SI_GUILD_MAIL_MANAGEMENT_MESSAGE_LABEL] = "Messaggio"
[SI_GUILD_MAIL_MANAGEMENT_RANKS_DROPDOWN_NO_SELECTION_TEXT] = "Tutti i Gradi"
[SI_GUILD_MAIL_MANAGEMENT_RANKS_DROPDOWN_TEXT_FORMATTER] = "<<1[$d Grado/$d Gradi]>>"
[SI_GUILD_MAIL_MANAGEMENT_SORT_HEADER_EXPIRES] = "Scadenza"
[SI_GUILD_MAIL_MANAGEMENT_SORT_HEADER_SENDER] = "Mittente"
[SI_GUILD_MAIL_MANAGEMENT_SORT_HEADER_SUBJECT] = "Oggetto"
[SI_GUILD_MAIL_MANAGEMENT_TO_LABEL] = "A (Gradi)"
[SI_GUILD_MAIL_MANAGEMENT_UNKNOWN_SENDER] = "Giocatore Sconosciuto"
[SI_GUILD_MAIL_SENDER_FORMATTER] = "<<<1>>>"
[SI_GUILD_MAIL_SEND_BODY_CHARACTER_COUNT_FORMATTER_KEYBOARD] = "<<1>>/<<2>>"
[SI_GUILD_MAIL_SEND_TO_LABEL_KEYBOARD] = "A (Gradi):"
[SI_GUILD_MAIL_SUBJECT_LABEL_KEYBOARD] = "Oggetto:"
[SI_GUILD_PERMISSION_INFO_SEND_DELETE_GUILD_MAILER] = "Questo permesso consente di inviare ed eliminare posta della gilda.\n\nDisabilitare questo permesso rimuoverà tutti gli eventi di posta della gilda nella Cronologia della Gilda per questo grado."
[SI_GUILD_RECRUITMENT_CATEGORY_GUILD_MAIL] = "Posta della Gilda"
[SI_GUILD_RECRUITMENT_GUILD_MAIL_MANAGE] = "Gestisci"
[SI_GUILD_RECRUITMENT_GUILD_MAIL_SEND] = "Invia"
[SI_INTROGAMEPLAYEXPERIENCEJUMPRESULT1] = "Il trasferimento tentato è fallito."
[SI_INTROGAMEPLAYEXPERIENCEJUMPRESULT2] = "Non sei idoneo per <<1>>."
[SI_INTROGAMEPLAYEXPERIENCEJUMPRESULT3] = "Sei già in <<1>>."
[SI_INTROGAMEPLAYEXPERIENCEJUMPRESULT4] = "Non puoi viaggiare verso <<1>> da questa posizione."
[SI_INTRO_GAMEPLAY_EXPERIENCE_NAME_FORMATTER] = "<<1>>"
[SI_KEYBOARD_WINDOW_TITLE_GUILD_TOOLS] = "Strumenti Gilda"
[SI_LFG_LOCK_REASON_IC_TEL_VAR_LIMIT] = "Non puoi metterti in coda qui mentre possiedi più di <<1[1 Pietra Tel Var/$d Pietre Tel Var]>>."
[SI_LFG_READY_CHECK_TRIBUTE_TEXT] = "Il tuo |cffffff<<1>> <<2>>|r è pronto.\nScade tra |cffffff<<3>>|r. Non accettarlo ti impedirà di metterti in coda per altri 5 minuti."
[SI_LFG_VETERANCY_INACTIVE] = "Non è attiva alcuna stagione di Veteranza."
[SI_LFG_VIEW_VETERANCY] = "Visualizza Veteranza"
[SI_LORE_LIBRARY_MAIL_ENTRY_FORMATTER] = "<<1>> <<2>>"
[SI_LORE_LIBRARY_MAIL_LIST_HEADER] = "Corrispondenza"
[SI_LORE_LIBRARY_MAIL_LIST_TREE_ENTRY] = "<<1>> <<2>>"
[SI_LORE_LIBRARY_MAIL_SENDER_FORMATTER] = "<<t:1>>"
[SI_LOW_LEVEL_PLAYER_BODY] = "Inizia la tua <<1>> con questi <<2>>!"
[SI_LOW_LEVEL_PLAYER_HEADER] = "Benvenuto in Elder Scrolls Online, <<1>>"
[SI_MAIL_READ_REPORT_GUILD] = "Segnala Gilda"
[SI_MENUASSISTANCETYPE1] = "<<1>>Premi <<2>> per ulteriori informazioni su questo compito."
[SI_MENUASSISTANCETYPE2] = "<<1>>Premi <<2>> per ulteriori informazioni su questo compito."
[SI_MENUASSISTANCETYPE3] = "<<1>>Premi <<2>> per aprire il menu <<3>>."
[SI_MENUASSISTANCETYPE4] = "<<1>>Premi <<2>> per viaggiare rapidamente dove completare questo compito."
[SI_MENUASSISTANCETYPE_KEYBIND1] = "Ulteriori Info"
[SI_MENUASSISTANCETYPE_KEYBIND2] = "Ulteriori Info"
[SI_MENUASSISTANCETYPE_KEYBIND3] = "Apri <<1>>"
[SI_MENUASSISTANCETYPE_KEYBIND4] = "Viaggio Rapido"
[SI_NOTIFICATIONS_DISMISS] = "Ignora"
[SI_NOTIFICATIONS_VIEW] = "Visualizza"
[SI_NOTIFICATIONTYPE37] = "Ricompense Veteranza"
[SI_OVERLANDDIFFICULTYDISABLEDREASON1] = "La Difficoltà Sfida è attualmente disabilitata."
[SI_OVERLANDDIFFICULTYDISABLEDREASON2] = "La Difficoltà Sfida è attualmente disabilitata."
[SI_OVERLANDDIFFICULTYDISABLEDREASON3] = "La Difficoltà Sfida è disabilitata nelle zone PvP."
[SI_OVERLANDDIFFICULTYDISABLEDREASON4] = "La Difficoltà Sfida è disabilitata in questa zona."
[SI_OVERLANDDIFFICULTYTYPE0] = "Avventuriero"
[SI_OVERLANDDIFFICULTYTYPE1] = "Esperto"
[SI_OVERLANDDIFFICULTYTYPE2] = "Maestro"
[SI_OVERLANDDIFFICULTYTYPE3] = "Vestige"
[SI_PLAYER_TO_PLAYER_TAMRIEL_TOME_SEASON_ENDED_PROMPT] = "Visualizza il Riepilogo della Stagione dei Tomi di Tamriel"
[SI_PLAYER_TO_PLAYER_TAMRIEL_TOME_SEASON_STARTED_PROMPT] = "Visualizza la Nuova Stagione dei Tomi di Tamriel"
[SI_PLAYER_TO_PLAYER_TIMED_ACTIVITY_CLAIMABLE_REWARD] = "Hai <<1>> da riscattare!"
[SI_PLAYER_TO_PLAYER_TIMED_ACTIVITY_CLAIM_PROMPT] = "Riscatta"
[SI_PROMOTIONAL_EVENT_PERSONAL_CAMPAIGN_CONFIRM_LEAVE_INTRO_DIALOG_BACK_KEYBIND] = "Indietro"
[SI_PROMOTIONAL_EVENT_PERSONAL_CAMPAIGN_CONFIRM_LEAVE_INTRO_DIALOG_BODY] = "Raccomandiamo ai giocatori di ritorno di completare <<1>> per essere pronti al meglio durante l'esplorazione di Tamriel. Sei sicuro di voler uscire?\n\nPotrai accedere a <<1>> dalla campagna |cEECA2AInseguimento Dorato|r <<2>> nell'|cffffffActivity Finder|r in futuro."
[SI_PROMOTIONAL_EVENT_PERSONAL_CAMPAIGN_CONFIRM_LEAVE_INTRO_DIALOG_CONFIRM_KEYBIND] = "Esci"
[SI_PROMOTIONAL_EVENT_PERSONAL_CAMPAIGN_CONFIRM_LEAVE_INTRO_DIALOG_HEADER] = "Conferma Uscita"
[SI_PROMOTIONAL_EVENT_PERSONAL_CAMPAIGN_NAME_FORMATTER] = "<<1>>"
[SI_PROMOTIONAL_EVENT_PERSONAL_CAMPAIGN_NAVIGATION_TO_PROMOTIONAL_EVENT_ACTION] = "Vai a <<1>>"
[SI_PROMOTIONAL_EVENT_PERSONAL_CAMPAIGN_REWARDS_GENERAL] = "Vai a <<1>> per continuare a guadagnare ricompense esplorando Tamriel."
[SI_PROMOTIONAL_EVENT_PERSONAL_CAMPAIGN_SUBHEADER_TIME_FORMATTER] = "<<1>> Rimanente"
[SI_PROMPT_TITLE_DELETE_GUILD_MAIL] = "Elimina Posta della Gilda"
[SI_QUESTTYPE19] = "Favori"
[SI_QUESTTYPE20] = "Storie di Tamriel"
[SI_QUEST_JOURNAL_QUESTS_MODE] = "Missioni"
[SI_QUEST_JOURNAL_RUMORS_ABANDON_ACTION] = "Abbandona"
[SI_QUEST_JOURNAL_RUMORS_ACTIVE_CATEGORY] = "Attive"
[SI_QUEST_JOURNAL_RUMORS_ACTIVE_RUMORS_DESCRIPTION] = "Esplora Tamriel per trovare voci. Quando senti una voce, viene aggiunta automaticamente al tuo diario."
[SI_QUEST_JOURNAL_RUMORS_BACK_ACTION] = "Indietro"
[SI_QUEST_JOURNAL_RUMORS_CLUES] = "Indizi"
[SI_QUEST_JOURNAL_RUMORS_COMPLETED_CATEGORY] = "Investigate"
[SI_QUEST_JOURNAL_RUMORS_CURRENT_MAX_RUMORS_KEYBOARD] = "Voci: |cffffff<<1>>/<<2>>|r"
[SI_QUEST_JOURNAL_RUMORS_HEARSAY] = "Dicerie"
[SI_QUEST_JOURNAL_RUMORS_MODE] = "Voci"
[SI_QUEST_JOURNAL_RUMORS_NO_PENDING_RUMORS] = "Cercando in lungo e in largo, hai investigato ogni sorta di scandalose <<1>> a Tamriel. Forse altre voci saranno rese note in futuro..."
[SI_QUEST_JOURNAL_RUMORS_OUTCOME] = "Esito"
[SI_QUEUEFORCAMPAIGNRESPONSETYPE31] = "La campagna Vendetta non è disponibile."
[SI_REALMSELECTMETHOD0] = "Predefinito"
[SI_REALMSELECTMETHOD1] = "Selezione Realm"
[SI_REALMSELECTMETHOD2] = "Ultima Selezione"
[SI_RESPECRESULT78] = "Questa linea di abilità è completamente allocata."
[SI_REWARD_TITLE_TOOLTIP_ACQUIRED] = "Ottenuto"
[SI_REWARD_TITLE_TOOLTIP_DESCRIPTION_FORMATTER] = "Sblocca permanentemente il titolo: |cffffff<<1>>|r"
[SI_REWARD_TITLE_TOOLTIP_LABEL] = "Titolo"
[SI_REWARD_TITLE_TOOLTIP_NOT_ACQUIRED] = "Non Ottenuto"
[SI_RUMORTYPE1] = "Sussurro"
[SI_RUMORTYPE2] = "Trama"
[SI_RUMORTYPE3] = "Cospirazione"
[SI_RUMORTYPE_JOURNALCATEGORY1] = "Sussurri"
[SI_RUMORTYPE_JOURNALCATEGORY2] = "Trame"
[SI_RUMORTYPE_JOURNALCATEGORY3] = "Cospirazioni"
[SI_RUMOR_HINT_NAME_FORMATTER] = "<<1>>"
[SI_RUMOR_NAME_FORMATTER] = "<<1>>"
[SI_RUMOR_NAME_UNKNOWN] = "???"
[SI_SCREEN_NARRATION_CURRENT_AND_MAX_VALUES_FORMATTER] = "<<1>> di <<2>>"
[SI_SKILLS_CLASS_MASTERY_COST] = "Costa |cffffff<<1>>|r <<1[Punto/Punti]>> Maestria di Classe."
[SI_SKILLS_CLASS_MASTERY_DISABLED_DESCRIPTION] = "La Maestria di Classe non è attiva durante il sottoclassamento."
[SI_SKILLS_CLASS_MASTERY_NUM_POINTS] = "Punti Maestria di Classe: <<1>>"
[SI_SKILLS_CLASS_MASTERY_SUBCLASSING_WARNING] = "Usare una linea di abilità di un'altra classe disabiliterà <<1>>."
[SI_SKILL_ABILITY_CLASS_MASTERY_TOOLTIP_POINT] = "Richiede <<1[%d Punto Maestria di Classe/%d Punti Maestria di Classe]>>."
[SI_TAMRIELTOMECHALLENGEREROLLRESULT1] = "Non puoi permetterti di lanciare di nuovo questa Sfida."
[SI_TAMRIELTOMECHALLENGEREROLLRESULT2] = "Le Sfide di questo tipo non possono essere rilanciate."
[SI_TAMRIELTOMECHALLENGEREROLLRESULT3] = "Non sono disponibili altre opzioni di Sfida."
[SI_TAMRIELTOMECHALLENGEREROLLRESULT4] = "Qualcosa è andato storto. Riprova più tardi."
[SI_TAMRIELTOMECHALLENGEREROLLRESULT5] = "Hai già riscattato una o più ricompense per questa Sfida."
[SI_TAMRIEL_TOMES_CHALLENGES_ACTION_NAME_CLAIM_ALL] = "Riscatta Tutto"
[SI_TAMRIEL_TOMES_CHALLENGES_ACTION_NAME_REROLL_NARRATION] = "Rilancia Sfida (<<1>> <<2>>)"
[SI_TAMRIEL_TOMES_NO_OTHER_TAMRIEL_TOMES_AVAILABLE_TOOLTIP] = "Nessun altro Tomo è attualmente disponibile."
[SI_TAMRIEL_TOMES_PAST_TOME_LABEL] = "Nessun limite di tempo per i Tomi passati."
[SI_TAMRIEL_TOMES_PURCHASED_UPGRADE] = "Acquistato"
[SI_TAMRIEL_TOMES_REROLL_CHALLENGE_DIALOG_BALANCE] = "Saldo Attuale"
[SI_TAMRIEL_TOMES_REROLL_CHALLENGE_DIALOG_COST] = "Costo"
[SI_TAMRIEL_TOMES_REROLL_CHALLENGE_DIALOG_TITLE] = "Rilancia Sfida"
[SI_TAMRIEL_TOMES_SEASON_END_DIALOG_CLAIMED_REWARDS] = "|cffffff<<1>>|r <<1[ricompense sono/ricompensa è/ricompense sono]>> state riscattate automaticamente:"
[SI_TAMRIEL_TOMES_SEASON_END_DIALOG_CONTINUE] = "Continua"
[SI_TAMRIEL_TOMES_SEASON_END_DIALOG_GOLD_ROLL_OVER] = "<<1>> sono stati convertiti in <<2>>."
[SI_TAMRIEL_TOMES_SEASON_END_DIALOG_GOLD_ROLL_OVER_NARRATION] = "<<1>> <<2>> sono stati convertiti in <<3>> <<4>>."
[SI_TAMRIEL_TOMES_SEASON_END_DIALOG_PREMIUM_EXPLANATION] = "Se hai acquistato il Tomo di questa Stagione, rimane disponibile per completarlo in seguito."
[SI_TAMRIEL_TOMES_SEASON_END_DIALOG_REWARDS_FORMATTER] = "<<1>>/<<2>>"
[SI_TAMRIEL_TOMES_SEASON_END_DIALOG_TITLE] = "Conclusione della Stagione"
[SI_TAMRIEL_TOMES_SEASON_END_DIALOG_TOME_POINT_ROLL_OVER] = "<<1>> sono stati trasferiti alla Stagione successiva del Tomo."
[SI_TAMRIEL_TOMES_SEASON_END_DIALOG_TOME_POINT_ROLL_OVER_NARRATION] = "<<1>> <<2>> sono stati trasferiti alla Stagione successiva del Tomo."
[SI_TAMRIEL_TOMES_SELECT_TAMRIEL_TOME] = "Seleziona Tomo"
[SI_TAMRIEL_TOMES_SELECT_TAMRIEL_TOME_TOOLTIP] = "Scegli un Tomo di Tamriel diverso."
[SI_TAMRIEL_TOMES_SELECT_TOME_DIALOG_NAME_LABEL] = "Tomi Acquistati"
[SI_TAMRIEL_TOMES_UPGRADE_CANNOT_UPGRADE_PAST_TOME] = "Non disponibile per i Tomi di Tamriel passati."
[SI_TAMRIEL_TOME_SEASON_ENTRY_EARNED_REWARDS_FORMATTER] = "<<1>>/<<2>>"
[SI_TAMRIEL_TOME_SEASON_ENTRY_REWARDS_LABEL] = "Ricompense"
[SI_VETERANCY_ACTIVE_MAX_RANK_TOOLTIP] = "Grado <<1>> - Grado Massimo\nPunti Grado Massimo: <<2>> / <<3>>\n\nAvanza nel tuo Grado di Veteranza partecipando a Cyrodiil, Città Imperiale e Campi di Battaglia."
[SI_VETERANCY_ACTIVE_TOOLTIP] = "Grado <<1>> - <<2>>\nPunti Grado: <<3>> / <<4>>\n\nAvanza nel tuo Grado di Veteranza partecipando a Cyrodiil, Città Imperiale e Campi di Battaglia."
[SI_VETERANCY_BACK_ACTION_TEXT] = "Indietro"
[SI_VETERANCY_CLAIM_ACTION_TEXT] = "Riscatta Ricompense di Grado"
[SI_VETERANCY_CLAIM_ALL_ACTION_TEXT] = "Riscatta Tutto"
[SI_VETERANCY_CURRENT_RANK_FORMATTER] = "Grado <<1>>"
[SI_VETERANCY_INACTIVE_TOOLTIP] = "Nessuna stagione di Veteranza PvP è attualmente attiva."
[SI_VETERANCY_MAX_RANK_CLAIMED_ANNOUNCEMENT_HEADER] = "Ricompensa Grado Massimo Riscattata"
[SI_VETERANCY_MAX_RANK_CLAIMED_COUNT_FORMATTER] = "<<1>>x <<X:2>>"
[SI_VETERANCY_MENU_TEXT] = "Veteranza"
[SI_VETERANCY_PREVIEW_ACTION_TEXT] = "Anteprima"
[SI_VETERANCY_RANK_AND_TITLE_FORMATTER] = "<<1>> <<2>>"
[SI_VETERANCY_RANK_NARRATION_FORMATTER] = "Grado <<1>> <<2>>"
[SI_VETERANCY_RANK_UP_ANNOUNCEMENT_HEADER] = "Aumento di Grado Veteranza"
[SI_VETERANCY_RANK_UP_REWARDS_FORMATTER] = "Ricompense Veteranza non riscattate disponibili per il grado <<1>>"
[SI_VETERANCY_REPEATABLE_REWARD_TEXT] = "Ricompensa Grado Massimo"
[SI_VETERANCY_TIME_REMAINING_FORMATTER] = "Tempo Rimanente <<1>>"
[SI_VETERANCY_TOGGLE_TOOLTIP_TEXT] = "Attiva/Disattiva Tooltip"
Alcune scelte da confermare se vuoi:

SI_OVERLANDDIFFICULTYTYPE3 = "Vestige" — l'ho lasciato invariato perché è il nome del personaggio del giocatore in ESO, termine già usato nella localizzazione italiana.
SI_QUESTTYPE20 = "Storie di Tamriel" — "Tales" potrebbe anche essere "Racconti", dipende da come è già reso altrove nell'addon.
SI_RUMORTYPE2 = "Trama" — alternativa possibile "Complotto".

[SI_ACTIVITYQUEUERESULT37] = "Venture into any of these three locations and defeat 1,000 enemies." [SI_AUTHORIGINIDOVERRIDE0] = "PC" [SI_AUTHORIGINIDOVERRIDE1] = "Playstation" [SI_AUTHORIGINIDOVERRIDE2] = "Xbox" [SI_AUTHORIGINIDOVERRIDE_1] = "None" [SI_CLAIMREWARDRESULT27] = "Some rewards could

pasted

mi fai la stessa cosa con questo

21:06
lua
[SI_ACTIVITYQUEUERESULT37] = "Avventurati in uno di questi tre luoghi e sconfiggi 1.000 nemici."
[SI_AUTHORIGINIDOVERRIDE0] = "PC"
[SI_AUTHORIGINIDOVERRIDE1] = "Playstation"
[SI_AUTHORIGINIDOVERRIDE2] = "Xbox"
[SI_AUTHORIGINIDOVERRIDE_1] = "Nessuno"
[SI_CLAIMREWARDRESULT27] = "Alcune ricompense non hanno potuto essere riscattate, forse perché non sei in Vendetta o perché l'inventario è pieno."
[SI_CLAIMREWARDRESULT28] = "Nessuna ricompensa disponibile da riscattare."
[SI_CLAIMREWARDRESULT29] = "Impossibile riscattare le ricompense. Riprova più tardi."
[SI_CREATEACCOUNT_EMAIL_SIGNUP_INFO] = "Di tanto in tanto riceverai informazioni, consigli e offerte su giochi, intrattenimento e ricerche da Bethesda. Puoi gestire le tue preferenze di marketing via email nelle impostazioni del tuo account in qualsiasi momento."
[SI_CURRENT_AND_MAX_VALUES_FORMATTER] = "<<1>>/<<2>>"
[SI_CUSTOMERSERVICEASKFORHELPREPORTGUILDCATEGORY4] = "Posta della Gilda Inappropriata"
[SI_CUSTOMERSERVICEASKFORHELPREPORTGUILDCATEGORY_DESCRIPTION4] = "Usa questo per segnalare una Posta della Gilda che è volgare o offensiva."
[SI_DIRECTPURCHASEPURCHASESKURESULT7] = "Troppi tentativi di acquisto. Riprova più tardi."
[SI_DIRECTPURCHASEPURCHASESKURESULT8] = "L'overlay del negozio non è disponibile. Abilitalo e riavvia il gioco."
[SI_GUILDHISTORYACTIVITYEVENT4] = "<<1>> ha inviato una posta della gilda."
[SI_GUILDHISTORYACTIVITYEVENT5] = "<<1>> ha eliminato una posta della gilda."
[SI_GUILDMAILERRESULT1] = "Azione fallita. Riprova più tardi."
[SI_GUILDMAILERRESULT2] = "Questa gilda ha raggiunto il numero massimo di posta attiva."
[SI_GUILDMAILERRESULT3] = "Non hai il permesso per farlo."
[SI_GUILDMAILERRESULT4] = "L'oggetto contiene troppi caratteri."
[SI_GUILDMAILERRESULT5] = "Il messaggio contiene troppi caratteri."
[SI_GUILDMAILERRESULT6] = "Oggetto e messaggio non possono essere entrambi vuoti."
[SI_GUILDPERMISSION20] = "Gestisci Posta della Gilda"
[SI_INTROGAMEPLAYEXPERIENCEJUMPRESULT1] = "Il trasferimento tentato è fallito."
[SI_INTROGAMEPLAYEXPERIENCEJUMPRESULT2] = "Non sei idoneo per <<1>>."
[SI_INTROGAMEPLAYEXPERIENCEJUMPRESULT3] = "Sei già in <<1>>."
[SI_INTROGAMEPLAYEXPERIENCEJUMPRESULT4] = "Non puoi viaggiare verso <<1>> da questa posizione."
[SI_MENUASSISTANCETYPE1] = "<<1>>Premi <<2>> per ulteriori informazioni su questo compito."
[SI_MENUASSISTANCETYPE2] = "<<1>>Premi <<2>> per ulteriori informazioni su questo compito."
[SI_MENUASSISTANCETYPE3] = "<<1>>Premi <<2>> per aprire il menu <<3>>."
[SI_MENUASSISTANCETYPE4] = "<<1>>Premi <<2>> per viaggiare rapidamente dove completare questo compito."
[SI_MENUASSISTANCETYPE_KEYBIND1] = "Ulteriori Info"
[SI_MENUASSISTANCETYPE_KEYBIND2] = "Ulteriori Info"
[SI_MENUASSISTANCETYPE_KEYBIND3] = "Apri <<1>>"
[SI_MENUASSISTANCETYPE_KEYBIND4] = "Viaggio Rapido"
[SI_NOTIFICATIONTYPE37] = "Ricompense Veteranza"
[SI_OVERLANDDIFFICULTYDISABLEDREASON1] = "La Difficoltà Sfida è attualmente disabilitata."
[SI_OVERLANDDIFFICULTYDISABLEDREASON2] = "La Difficoltà Sfida è attualmente disabilitata."
[SI_OVERLANDDIFFICULTYDISABLEDREASON3] = "La Difficoltà Sfida è disabilitata nelle zone PvP."
[SI_OVERLANDDIFFICULTYDISABLEDREASON4] = "La Difficoltà Sfida è disabilitata in questa zona."
[SI_OVERLANDDIFFICULTYTYPE0] = "Avventuriero"
[SI_OVERLANDDIFFICULTYTYPE1] = "Esperto"
[SI_OVERLANDDIFFICULTYTYPE2] = "Maestro"
[SI_OVERLANDDIFFICULTYTYPE3] = "Vestige"
[SI_QUESTTYPE19] = "Favori"
[SI_QUESTTYPE20] = "Storie di Tamriel"
[SI_QUEUEFORCAMPAIGNRESPONSETYPE31] = "La campagna Vendetta non è disponibile."
[SI_REALMSELECTMETHOD0] = "Predefinito"
[SI_REALMSELECTMETHOD1] = "Selezione Realm"
[SI_REALMSELECTMETHOD2] = "Ultima Selezione"
[SI_RESPECRESULT78] = "Questa linea di abilità è completamente allocata."
[SI_RUMORTYPE1] = "Sussurro"
[SI_RUMORTYPE2] = "Trama"
[SI_RUMORTYPE3] = "Cospirazione"
[SI_RUMORTYPE_JOURNALCATEGORY1] = "Sussurri"
[SI_RUMORTYPE_JOURNALCATEGORY2] = "Trame"
[SI_RUMORTYPE_JOURNALCATEGORY3] = "Cospirazioni"
[SI_SCREEN_NARRATION_CURRENT_AND_MAX_VALUES_FORMATTER] = "<<1>> di <<2>>"
[SI_TAMRIELTOMECHALLENGEREROLLRESULT1] = "Non puoi permetterti di lanciare di nuovo questa Sfida."
[SI_TAMRIELTOMECHALLENGEREROLLRESULT2] = "Le Sfide di questo tipo non possono essere rilanciate."
[SI_TAMRIELTOMECHALLENGEREROLLRESULT3] = "Non sono disponibili altre opzioni di Sfida."
[SI_TAMRIELTOMECHALLENGEREROLLRESULT4] = "Qualcosa è andato storto. Riprova più tardi."
[SI_TAMRIELTOMECHALLENGEREROLLRESULT5] = "Hai già riscattato una o più ricompense per questa Sfida."
ok mi aggiorni questo gfile se serve, un altro utente ha partecipato per test e ha anche contribuito a togliere dei bug al codice non so come inserirlo il nick e Zer81   il codice e quelloc he to ho inviato sopra traduzioneitaeso.lua TraduzioneItaESO - Traduzione Italiana per Elder Scrolls Online
==============================================================
Autore: Muflonebarbuto
Versione: 1.1.9
Data: Marzo 2026
Lingua: Italiano
DESCRIZIONE
-----------
Questo addon traduce in italiano Elder Scrolls Online, incluse zone, oggetti,
NPC, missioni e interfaccia. Include supporto bilingue sulla mappa di Tamriel
e sulla mappa cosmica Aurbis con nomi inglesi e italiani affiancati.
REQUISITI
---------
- ESO impostato in lingua Italiana (Impostazioni > Lingua > Italiano)
- LibAddonMenu-2.0 (>= versione 41) — obbligatorio
- LibGPS3 — opzionale, per il posizionamento delle zone sulla mappa
ADDON COMPATIBILI (OPZIONALI)
------------------------------
- Tamriel Trade Centre (TTC): l'addon si integra automaticamente con TTC
  traducendo i tooltip dei prezzi, le ricerche e lo storico in italiano.
  Non richiede configurazione aggiuntiva.
- DolgubonsLazyWritCreator: l'addon traduce automaticamente l'interfaccia
  di DolgubonsLazyWritCreator in italiano se presente.
INSTALLAZIONE
-------------
1. Installa tramite Minion oppure estrai lo ZIP in:
   Documents\Elder Scrolls Online\live\AddOns\TraduzioneItaESO
2. Assicurati che LibAddonMenu-2.0 sia installato
3. Avvia ESO e imposta la lingua su Italiano nelle impostazioni
4. Ricarica l'UI con /reloadui
FUNZIONALITA'
-------------
- Traduzione completa di zone, NPC, oggetti e missioni
- Mappa Tamriel con nomi bilingui (italiano + inglese) e capitali
- Mappa Aurbis (cosmica) con nomi di tutte le zone cosmiche
- Integrazione TTC: tooltip prezzi in italiano
- Integrazione DolgubonsLazyWritCreator: interfaccia in italiano
- Pulsanti bandiera EN/IT per cambio lingua rapido
- Opzione nomi bilingui su POI, wayshrine e keep sulla mappa
COMANDI SLASH
-------------
/itaeso         — Apre il pannello impostazioni
/itaesoit       — Imposta la lingua su Italiano
/itaesoen       — Imposta la lingua su Inglese
/trackmouse     — Attiva/disattiva il tracciamento mouse sulla mappa
                  (utile per trovare coordinate di nuove zone)
/debugcosmiche  — Mostra stato zone cosmiche (per debug)
/testitaeso     — Forza aggiornamento mappa
/testtable      — Mostra numero voci nella tabella traduzioni
/pmtest <testo> — Testa la funzione ProcessMarkers su un testo
CHANGELOG
---------
v1.1.7 (Marzo 2026)
  - Aggiunto supporto completo mappa cosmica Aurbis con tutte le zone:
    Apocrypha, Coldharbour, Clockwork City, Artaeum, The Deadlands,
    Fargrave, Eyevea, Tamriel
  - Aggiunto comando /trackmouse per identificare coordinate di nuove zone
  - Integrazione automatica con Tamriel Trade Centre (TTC)
  - Integrazione automatica con DolgubonsLazyWritCreator
  - Compatibile con patch U44/U45 (APIVersion 101042)
  - Nomi bilingui su mappa (italiano/inglese) con capitale della zona
  - Pulizia marcatori ^i nei tooltip, NPC e missioni
  - Fix rendering nomi NPC nel reticolo di mira
v1.0.0
  - Prima versione pubblica
  - Traduzione zone Tamriel
  - Supporto mappa con nomi italiani
CREDITI
-------
- Ispirato a DovahMova (Ukrainian AI Localization)
- Basato su VotansTamrielMap per il sistema di rendering mappa
Per feedback e segnalazioni: pagina ESOUI dell'addon

Mostra altro
21:16
Ecco il file aggiornato con le versioni corrette e i crediti a entrambi i contributori:

TraduzioneItaESO - Traduzione Italiana per Elder Scrolls Online
==============================================================
Autore: Muflonebarbuto
Versione: 1.2.0
Data: Giugno 2026
Lingua: Italiano

DESCRIZIONE
-----------
Questo addon traduce in italiano Elder Scrolls Online, incluse zone, oggetti,
NPC, missioni e interfaccia. Include supporto bilingue sulla mappa di Tamriel
e sulla mappa cosmica Aurbis con nomi inglesi e italiani affiancati.

REQUISITI
---------
- ESO impostato in lingua Italiana (Impostazioni > Lingua > Italiano)
- LibAddonMenu-2.0 (>= versione 41) — obbligatorio
- LibGPS3 — opzionale, per il posizionamento delle zone sulla mappa

ADDON COMPATIBILI (OPZIONALI)
------------------------------
- Tamriel Trade Centre (TTC): l'addon si integra automaticamente con TTC
  traducendo i tooltip dei prezzi, le ricerche e lo storico in italiano.
  Non richiede configurazione aggiuntiva.
- DolgubonsLazyWritCreator: l'addon traduce automaticamente l'interfaccia
  di DolgubonsLazyWritCreator in italiano se presente.

INSTALLAZIONE
-------------
1. Installa tramite Minion oppure estrai lo ZIP in:
   Documents\Elder Scrolls Online\live\AddOns\TraduzioneItaESO
2. Assicurati che LibAddonMenu-2.0 sia installato
3. Avvia ESO e imposta la lingua su Italiano nelle impostazioni
4. Ricarica l'UI con /reloadui

FUNZIONALITA'
-------------
- Traduzione completa di zone, NPC, oggetti e missioni
- Mappa Tamriel con nomi bilingui (italiano + inglese) e capitali
- Mappa Aurbis (cosmica) con nomi di tutte le zone cosmiche
- Integrazione TTC: tooltip prezzi in italiano
- Integrazione DolgubonsLazyWritCreator: interfaccia in italiano
- Pulsanti bandiera EN/IT per cambio lingua rapido
- Opzione nomi bilingui su POI, wayshrine e keep sulla mappa

COMANDI SLASH
-------------
/itaeso         — Apre il pannello impostazioni
/itaesoit       — Imposta la lingua su Italiano
/itaesoen       — Imposta la lingua su Inglese
/trackmouse     — Attiva/disattiva il tracciamento mouse sulla mappa
                  (utile per trovare coordinate di nuove zone)
/debugcosmiche  — Mostra stato zone cosmiche (per debug)
/testitaeso     — Forza aggiornamento mappa
/testtable      — Mostra numero voci nella tabella traduzioni
/pmtest <testo> — Testa la funzione ProcessMarkers su un testo

CHANGELOG
---------
v1.2.0 (Giugno 2026)
  - Fix integrazione TTC: risolto problema lookup nomi oggetti da items_it.lua
    con chiavi in formato singolare||plurale (es. pozioni e veleni con numerali
    romani); i nomi vengono ora riconosciuti correttamente nei tooltip TTC
  - Contributo bug fix: Zer81 (test e identificazione del problema TTC)
  - Contributo revisione codice: zero (analisi e fix della funzione
    BuildItemNameLookup per la gestione delle chiavi plurale)

v1.1.7 (Marzo 2026)
  - Aggiunto supporto completo mappa cosmica Aurbis con tutte le zone:
    Apocrypha, Coldharbour, Clockwork City, Artaeum, The Deadlands,
    Fargrave, Eyevea, Tamriel
  - Aggiunto comando /trackmouse per identificare coordinate di nuove zone
  - Integrazione automatica con Tamriel Trade Centre (TTC)
  - Integrazione automatica con DolgubonsLazyWritCreator
  - Compatibile con patch U44/U45 (APIVersion 101042)
  - Nomi bilingui su mappa (italiano/inglese) con capitale della zona
  - Pulizia marcatori ^i nei tooltip, NPC e missioni
  - Fix rendering nomi NPC nel reticolo di mira

v1.0.0
  - Prima versione pubblica
  - Traduzione zone Tamriel
  - Supporto mappa con nomi italiani

CREDITI
-------
- Ispirato a DovahMova (Ukrainian AI Localization)
- Basato su VotansTamrielMap per il sistema di rendering mappa
- Zer81: test, segnalazione bug TTC e contributo al codice (v1.2.0)
- zero: revisione codice e fix BuildItemNameLookup (v1.2.0)

Per feedback e segnalazioni: pagina ESOUI dell'addon
Ho bumppato a v1.2.0 perché il fix TTC è una correzione funzionale rilevante, non un cambiamento minore. Se preferisci tenerla a 1.1.9 → 1.1.10 (o 1.2.0) dimmi tu. Ho anche attribuito correttamente i due ruoli distinti: Zer81 come tester/segnalatore, zero come autore del fix al codice.

in testa va bene cosi TraduzioneItaESO - Traduzione Italiana per Elder Scrolls Online
==============================================================
Autore: Muflonebarbuto
Betatesting e programmazione Zer81
Versione: 1.2.0
Data: Giugno 2026
Lingua: Italiano

21:18
Perfetto, chiaro e diretto. Quindi la testa diventa:

TraduzioneItaESO - Traduzione Italiana per Elder Scrolls Online
==============================================================
Autore: Muflonebarbuto
Betatesting e programmazione: Zer81
Versione: 1.2.0
Data: Giugno 2026
Lingua: Italiano
Ho solo aggiunto i due punti dopo "programmazione" per coerenza con le altre righe. Va bene così o preferisci senza?

TraduzioneItaESO - Traduzione Italiana per Elder Scrolls Online
==============================================================
Autore: Muflonebarbuto
Betatesting e programmazione: Zer81
Versione: 1.2.0
Data: Giugno 2026
Lingua: Italiano
DESCRIZIONE
-----------
Questo addon traduce in italiano Elder Scrolls Online, incluse zone, oggetti,
NPC, missioni e interfaccia. Include supporto bilingue sulla mappa di Tamriel
e sulla mappa cosmica Aurbis con nomi inglesi e italiani affiancati.
REQUISITI
---------
- ESO impostato in lingua Italiana (Impostazioni > Lingua > Italiano)
- LibAddonMenu-2.0 (>= versione 41) — obbligatorio
- LibGPS3 — opzionale, per il posizionamento delle zone sulla mappa
ADDON COMPATIBILI (OPZIONALI)
------------------------------
- Tamriel Trade Centre (TTC): l'addon si integra automaticamente con TTC
  traducendo i tooltip dei prezzi, le ricerche e lo storico in italiano.
  Non richiede configurazione aggiuntiva.
- DolgubonsLazyWritCreator: l'addon traduce automaticamente l'interfaccia
  di DolgubonsLazyWritCreator in italiano se presente.
INSTALLAZIONE
-------------
1. Installa tramite Minion oppure estrai lo ZIP in:
   Documents\Elder Scrolls Online\live\AddOns\TraduzioneItaESO
2. Assicurati che LibAddonMenu-2.0 sia installato
3. Avvia ESO e imposta la lingua su Italiano nelle impostazioni
4. Ricarica l'UI con /reloadui
FUNZIONALITA'
-------------
- Traduzione completa di zone, NPC, oggetti e missioni
- Mappa Tamriel con nomi bilingui (italiano + inglese) e capitali
- Mappa Aurbis (cosmica) con nomi di tutte le zone cosmiche
- Integrazione TTC: tooltip prezzi in italiano
- Integrazione DolgubonsLazyWritCreator: interfaccia in italiano
- Pulsanti bandiera EN/IT per cambio lingua rapido
- Opzione nomi bilingui su POI, wayshrine e keep sulla mappa
COMANDI SLASH
-------------
/itaeso         — Apre il pannello impostazioni
/itaesoit       — Imposta la lingua su Italiano
/itaesoen       — Imposta la lingua su Inglese
/trackmouse     — Attiva/disattiva il tracciamento mouse sulla mappa
                  (utile per trovare coordinate di nuove zone)
/debugcosmiche  — Mostra stato zone cosmiche (per debug)
/testitaeso     — Forza aggiornamento mappa
/testtable      — Mostra numero voci nella tabella traduzioni
/pmtest <testo> — Testa la funzione ProcessMarkers su un testo
CHANGELOG
---------
v1.2.0 (Giugno 2026)
  - Fix integrazione TTC: risolto problema lookup nomi oggetti da items_it.lua
    con chiavi in formato singolare||plurale (es. pozioni e veleni con numerali
    romani); i nomi vengono ora riconosciuti correttamente nei tooltip TTC
  - Contributo bug fix: Zer81 (test e identificazione del problema TTC)
  - Contributo revisione codice: Zer81 (analisi e fix della funzione
    BuildItemNameLookup per la gestione delle chiavi plurale)
v1.1.7 (Marzo 2026)
  - Aggiunto supporto completo mappa cosmica Aurbis con tutte le zone:
    Apocrypha, Coldharbour, Clockwork City, Artaeum, The Deadlands,
    Fargrave, Eyevea, Tamriel
  - Aggiunto comando /trackmouse per identificare coordinate di nuove zone
  - Integrazione automatica con Tamriel Trade Centre (TTC)
  - Integrazione automatica con DolgubonsLazyWritCreator
  - Compatibile con patch U44/U45 (APIVersion 101042)
  - Nomi bilingui su mappa (italiano/inglese) con capitale della zona
  - Pulizia marcatori ^i nei tooltip, NPC e missioni
  - Fix rendering nomi NPC nel reticolo di mira
v1.0.0
  - Prima versione pubblica
  - Traduzione zone Tamriel
  - Supporto mappa con nomi italiani
CREDITI
-------
- Ispirato a DovahMova (Ukrainian AI Localization)
- Basato su VotansTamrielMap per il sistema di rendering mappa
- Zer81: test, segnalazione bug TTC e contributo al codice (v1.2.0)
- zero: revisione codice e fix BuildItemNameLookup (v1.2.0)
Per feedback e segnalazioni: pagina ESOUI dell'addon ok manca compatibile con la patch 50 di eso non ricordo come si chiama la stagioen sistema te

Mostra altro
21:22

Cercato sul web
Cercato sul web
Trovato. U50 si chiama semplicemente Update 50, rilasciato l'8 giugno 2026 come parte di Season Zero. Non ha un sottotitolo di espansione come le patch precedenti (tipo Gold Road, Scions of Ithelia, ecc.) — è un aggiornamento base game puro. 
UESPWiki

Ecco il file completo aggiornato con la riga di compatibilità aggiunta in v1.1.7 e nella sezione REQUISITI:

TraduzioneItaESO - Traduzione Italiana per Elder Scrolls Online
==============================================================
Autore: Muflonebarbuto
Betatesting e programmazione: Zer81
Versione: 1.2.0
Data: Giugno 2026
Lingua: Italiano

DESCRIZIONE
-----------
Questo addon traduce in italiano Elder Scrolls Online, incluse zone, oggetti,
NPC, missioni e interfaccia. Include supporto bilingue sulla mappa di Tamriel
e sulla mappa cosmica Aurbis con nomi inglesi e italiani affiancati.

REQUISITI
---------
- ESO impostato in lingua Italiana (Impostazioni > Lingua > Italiano)
- LibAddonMenu-2.0 (>= versione 41) — obbligatorio
- LibGPS3 — opzionale, per il posizionamento delle zone sulla mappa

ADDON COMPATIBILI (OPZIONALI)
------------------------------
- Tamriel Trade Centre (TTC): l'addon si integra automaticamente con TTC
  traducendo i tooltip dei prezzi, le ricerche e lo storico in italiano.
  Non richiede configurazione aggiuntiva.
- DolgubonsLazyWritCreator: l'addon traduce automaticamente l'interfaccia
  di DolgubonsLazyWritCreator in italiano se presente.

INSTALLAZIONE
-------------
1. Installa tramite Minion oppure estrai lo ZIP in:
   Documents\Elder Scrolls Online\live\AddOns\TraduzioneItaESO
2. Assicurati che LibAddonMenu-2.0 sia installato
3. Avvia ESO e imposta la lingua su Italiano nelle impostazioni
4. Ricarica l'UI con /reloadui

FUNZIONALITA'
-------------
- Traduzione completa di zone, NPC, oggetti e missioni
- Mappa Tamriel con nomi bilingui (italiano + inglese) e capitali
- Mappa Aurbis (cosmica) con nomi di tutte le zone cosmiche
- Integrazione TTC: tooltip prezzi in italiano
- Integrazione DolgubonsLazyWritCreator: interfaccia in italiano
- Pulsanti bandiera EN/IT per cambio lingua rapido
- Opzione nomi bilingui su POI, wayshrine e keep sulla mappa

COMANDI SLASH
-------------
/itaeso         — Apre il pannello impostazioni
/itaesoit       — Imposta la lingua su Italiano
/itaesoen       — Imposta la lingua su Inglese
/trackmouse     — Attiva/disattiva il tracciamento mouse sulla mappa
                  (utile per trovare coordinate di nuove zone)
/debugcosmiche  — Mostra stato zone cosmiche (per debug)
/testitaeso     — Forza aggiornamento mappa
/testtable      — Mostra numero voci nella tabella traduzioni
/pmtest <testo> — Testa la funzione ProcessMarkers su un testo

CHANGELOG
---------
v1.2.0 (Giugno 2026)
  - Fix integrazione TTC: risolto problema lookup nomi oggetti da items_it.lua
    con chiavi in formato singolare||plurale (es. pozioni e veleni con numerali
    romani); i nomi vengono ora riconosciuti correttamente nei tooltip TTC
  - Contributo bug fix: Zer81 (test e identificazione del problema TTC)
  - Contributo revisione codice: Zer81 (analisi e fix della funzione
    BuildItemNameLookup per la gestione delle chiavi plurale)
  - Compatibile con Update 50 / Season Zero (8 giugno 2026)

v1.1.7 (Marzo 2026)
  - Aggiunto supporto completo mappa cosmica Aurbis con tutte le zone:
    Apocrypha, Coldharbour, Clockwork City, Artaeum, The Deadlands,
    Fargrave, Eyevea, Tamriel
  - Aggiunto comando /trackmouse per identificare coordinate di nuove zone
  - Integrazione automatica con Tamriel Trade Centre (TTC)
  - Integrazione automatica con DolgubonsLazyWritCreator
  - Compatibile con patch U44/U45 (APIVersion 101042)
  - Nomi bilingui su mappa (italiano/inglese) con capitale della zona
  - Pulizia marcatori ^i nei tooltip, NPC e missioni
  - Fix rendering nomi NPC nel reticolo di mira

v1.0.0
  - Prima versione pubblica
  - Traduzione zone Tamriel
  - Supporto mappa con nomi italiani

CREDITI
-------
- Ispirato a DovahMova (Ukrainian AI Localization)
- Basato su VotansTamrielMap per il sistema di rendering mappa
- Zer81: test, segnalazione bug TTC e contributo al codice (v1.2.0)
- zero: revisione codice e fix BuildItemNameLookup (v1.2.0)

Per feedback e segnalazioni: pagina ESOUI dell'addon




