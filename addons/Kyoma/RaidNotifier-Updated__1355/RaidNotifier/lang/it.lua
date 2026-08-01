local L = {}

L.Description                            = "Mostra le notifiche sullo schermo su diversi eventi durante la Trial."

--------------------------------
----     General Stuff      ----
--------------------------------
L.Settings_General_Header                        	   = "Generale"
-- Settings
L.Settings_General_Notifications_Showcase           = "Mostra Notifiche"
L.Settings_General_Bufffood_Reminder					= "Promemoria del Bonus da Cibo"
L.Settings_General_Bufffood_Reminder_TT					= "Ti avvisa quando non hai bonus da cibo durante le Trial o quando sta per finire (vedi sotto)."
L.Settings_General_Bufffood_Reminder_Interval			= "Intervallo del Promemoria"
L.Settings_General_Bufffood_Reminder_Interval_TT		= "Intervallo, in secondi, in cui comparirà il promemoria del bonus da cibo, a partire dagli ultimi 10 minuti rimanenti."
L.Settings_General_Vanity_Pets							= "Disabilita Animali Domestici nelle Trial"
L.Settings_General_Vanity_Pets_TT						= "Nasconderà i tuoi animali domestici quando inizi una Trial. Al termine della Trial, l'animale verrà nuovamente visualizzato."
L.Settings_General_No_Assistants						= "Disattiva Assistenti in Combattimento"
L.Settings_General_No_Assistants_TT						= "Si applica solo durante le Trial e NON impedisce di evocarli."
L.Settings_General_Center_Screen_Announce				= "Tipo di Annuncio"
L.Settings_General_Center_Screen_Announce_TT			= "Il tipo di annuncio da utilizzare."
L.Settings_General_NotificationsScale					= "Dimesione delle Notificche"
L.Settings_General_NotificationsScale_TT				= "Dimesione con cui verranno visualizzate le notifiche minori e i conti alla rovescia."
L.Settings_General_UseDisplayName						= "Mostra Nome Utente"
L.Settings_General_UseDisplayName_TT					= "Mostrerà il nome utente di un giocatore nelle notifiche invece del nome del suo personaggio."
L.Settings_General_Unlock_Status_Icon					= "Sblocca Icona di Stato"
L.Settings_General_Unlock_Status_Icon_TT				= "Quando attivato, mostrerà un'icona di stato sullo schermo che può essere spostata."
L.Settings_General_Default_Sound						= "Suono Predefinito"
L.Settings_General_Default_Sound_TT						= "Il suono predefinito da utilizzare per una notifica."
-- Choices
L.Settings_General_Choices_Off							= "Disabilitato"
L.Settings_General_Choices_Full							= "Completo"
L.Settings_General_Choices_Normal						= "Normale"
L.Settings_General_Choices_Minimal						= "Minimale"
L.Settings_General_Choices_Self							= "Solo io"
L.Settings_General_Choices_Near							= "Vicino"
L.Settings_General_Choices_All							= "Tutti"
L.Settings_General_Choices_Always						= "Sempre"
L.Settings_General_Choices_Other						= "Altro"
L.Settings_General_Choices_Inverted						= "Invertito"
L.Settings_General_Choices_Small						= "Piccolo (obsoleto)"
L.Settings_General_Choices_Large						= "Grande (obsoleto)"
L.Settings_General_Choices_Major						= "Enorme (obsoleto)"
L.Settings_General_Choices_1s							= "1s"
L.Settings_General_Choices_500ms						= "0,5s"
L.Settings_General_Choices_200ms						= "0,2s"
L.Settings_General_Choices_Custom						= "Personalizzato"
L.Settings_General_Choices_Custom                   = "Custom"
L.Settings_General_Choices_Custom_Announcement      = "Personalizzato (mobile)"
L.Settings_General_Choices_SelfAndTanks             = "Self and tanks"
L.Settings_General_Choices_OnlyChaurusTotem			= "Solo Chaurus"	-- Specific for Kyne's Aegis
L.Settings_DreadsailReef_Choices_OnlyFireDome       = "Only Fire Dome"
L.Settings_DreadsailReef_Choices_OnlyIceDome        = "Only Ice Dome"
-- Alerts
L.Alerts_General_No_Bufffood                        = "Non hai nessun bonus da cibo!"
L.Alerts_General_Bufffood_Minutes                   = "Il tuo bonus da '<<1>>' si esaurirà tra |cbd0000<<2>>|r minuti!"
-- Bindings
L.Binding_ToggleUltimateExchange                    = "Alterna Mossa Finale"


--------------------------------
----    Ultimate Exchange   ----
--------------------------------
L.Settings_Ultimate_Header                           = "Scambia Mossa Finale (beta)"
L.Settings_Ultimate_Description                      = "Questa funzione ti consente di inviare informazioni sui tuoi punti mossa finale ai tuoi compagni di squadra in modo che possano vedere quanto sei vicino al lancio dell'abilità. Usa il valore del costo in base alle eventuali riduzioni che potresti ottenere dalle armature o dalle passive."
-- Settings
L.Settings_Ultimate_Enabled                          = "Abilitato"
L.Settings_Ultimate_Enabled_TT                       = "Consente la condivisione e la ricezione di informazioni delle abilità mossa finale. È sempre disabilitato al di fuori delle Trial."
L.Settings_Ultimate_Hidden                           = "Nascosto"
L.Settings_Ultimate_Hidden_TT                        = "Nasconde la finestra delle mosse finali, ma non disabilita la funzione stessa."
L.Settings_Ultimate_UseColor                         = "Usa Colore"
L.Settings_Ultimate_UseColor_TT                      = "Dai all'abilità mossa finale di qualcuno un colore basato sulle soglie dall'80 e al 100 percento."
L.Settings_Ultimate_UseDisplayName                   = "Mostra Nome Utente"
L.Settings_Ultimate_UseDisplayName_TT                = "Mostra il nome utente nella finestra della mossa finale invece del nome del personaggio."
L.Settings_Ultimate_ShowHealers                      = "Mostra Guaritori"
L.Settings_Ultimate_ShowHealers_TT                   = "Mostra l'abilità mossa finale dei membri del gruppo con il ruolo di guaritore."
L.Settings_Ultimate_ShowTanks                        = "Mostra Tank"
L.Settings_Ultimate_ShowTanks_TT                     = "Mostra l'abilità mossa finale dei membri del gruppo con il ruolo di tank."
L.Settings_Ultimate_ShowDps                          = "Mostra Danno"
L.Settings_Ultimate_ShowDps_TT                       = "Mostra l'abilità mossa finale dei membri del gruppo con il ruolo di danno."
L.Settings_Ultimate_TargetUlti                       = "Abilità Mossa Finale"
L.Settings_Ultimate_TargetUlti_TT                    = "Quale abilità Mossa Finale verrà utilizzata per il valore percentuale visto dagli altri."
L.Settings_Ultimate_OverrideCost                     = "Sostituisci Costo"
L.Settings_Ultimate_OverrideCost_TT                  = "Usa questo valore quando invii il costo della tua abilità mossa finale ad altri. Se impostato a 0, la sostituzione sarà disabilitata."


--------------------------------
----        Profiles        ----
--------------------------------
L.Settings_Profile_Header                            = "Profili"
L.Settings_Profile_Description                       = "Puoi gestire da qui le impostazioni dei profili. Include l'opzione per abilitare un profilo globale che applicherà le stesse impostazioni a TUTTI i personaggi dell'account. A causa della permanenza di queste opzioni, la gestione deve essere prima attivata utilizzando la casella di controllo nella parte inferiore del pannello."
L.Settings_Profile_UseGlobal                         = "Applica Impostazioni Globali"
L.Settings_Profile_UseGlobal_Warning                 = "Il passaggio tra i profili locali e globali ricaricherà l'interfaccia."
L.Settings_Profile_Copy                              = "Seleziona un Profilo da Copiare"
L.Settings_Profile_Copy_TT                           = "Seleziona un profilo da cui copiare le impostazioni per il profilo attualmente in uso. Il profilo attivo verrà applicato al personaggio corrente o globalmente se tale funzione è abilitata. Il profilo esistente verrà sovrascritto in modo permanente.\n\nQuesta azione non può essere annullata!"
L.Settings_Profile_CopyButton                        = "Copia Profilo"
L.Settings_Profile_CopyButton_Warning                = "La copia di un profilo ricaricherà l'interfaccia."
L.Settings_Profile_CopyCannotCopy                    = "Impossibile copiare il profilo selezionato. Riprova o seleziona un altro profilo."
L.Settings_Profile_Delete                            = "Seleziona un Profilo da Eliminare"
L.Settings_Profile_Delete_TT                         = "Seleziona un profilo per rimuovere le sue impostazioni dal database. Se accedi a questo personaggio in un secondo momento e le impostazioni globali non vengono applicate, verrà creato un profilo con le impostazioni predefinite.\n\nUn profilo eliminato non può essere recuperato!"
L.Settings_Profile_DeleteButton                      = "Elimina Profilo"
L.Settings_Profile_Guard                             = "Abilita Gestione Profilo"


--------------------------------
----       Countdowns       ----
--------------------------------
L.Settings_Countdown_Header							= "Tempi di Ricarica"
L.Settings_Countdown_Description					= "Cambia aspetto e comportamento del tempi di ricarica."
L.Settings_Countdown_TimerScale						= "Dimensione Timer Principale (obsoleto)"
L.Settings_Countdown_TimerScale_TT					= "Dimensione dello schermo del timer."
L.Settings_Countdown_TextScale						= "Dimensione Testo Principale (obsoleto)"
L.Settings_Countdown_TextScale_TT					= "Dimensione del testo visualizzato."
L.Settings_Countdown_TimerPrecise					= "Precisione Timer"
L.Settings_Countdown_TimerPrecise_TT				= "Imposta la precisione del timer per il tempo di ricarica."
L.Settings_Countdown_UseColors						= "Usa Colori"
L.Settings_Countdown_UseColors_TT					= "Se attivato, utilizzerà i colori giallo/arancione/rosso per i tempi di ricarica fino a raggiungere lo zero."


--------------------------------
----          Trials        ----
--------------------------------
L.Settings_Trials_Header                            = "Trial"
L.Settings_Trials_Description                       = "Qui puoi configurare le notifiche per ogni Trial. Hanno tutte un suono configurabile e molte di loro non aiuteranno solo te, ma anche i tuoi compagni di squadra."


--------------------------------
----     Hel Ra Citadel / Ciudadela de Hel Ra     ----
--------------------------------
L.Settings_HelRa_Header                             = "Hel Ra Citadel / Cittadella di Hel Ra"
-- Settings
L.Settings_HelRa_Yokeda_Meteor                      = "Yokeda: Meteora"
L.Settings_HelRa_Yokeda_Meteor_TT                   = "Ti avvisa quando lo Yokeda sta per attaccare con una meteora."
L.Settings_HelRa_Warrior_StoneForm                  = "Guerriero: Forma di Pietra"
L.Settings_HelRa_Warrior_StoneForm_TT               = "Ti avvisa quando tu e/o gli altri state per essere trasformati in pietra dal Guerriero."
L.Settings_HelRa_Warrior_ShieldThrow                = "Lancio dello scudo del Guerriero"
L.Settings_HelRa_Warrior_ShieldThrow_TT             = "Ti avvisa quando il Guerrero sta sul punto di lanciare il suo scudo."
--Alerts
L.Alerts_HelRa_Yokeda_Meteor                        = "|cFF0000Meteora|r in arrivo su di te. Blocca!"
L.Alerts_HelRa_Yokeda_Meteor_Other                  = "|cFF0000Meteora|r in arrivo su |c595959<<!C:1>>|r."
L.Alerts_HelRa_Warrior_StoneForm                    = "|c595959Forma di Pietra|r in arrivo su di te. Non usare sinegie!"
L.Alerts_HelRa_Warrior_StoneForm_Other              = "|c595959Forma di Pietra|r in arrivo su |cFF0000<<!C:1>>|r."
L.Alerts_HelRa_Warrior_ShieldThrow                  = "|cFF0000Lancio dello Scudo|r in arrivo. "


--------------------------------
----   Aetherian Archives / Archivo Aetérico   ----
--------------------------------
L.Settings_Archive_Header                           = "Aetherian Archives / Archivi Aetherian"
-- Settings
L.Settings_Archive_StormAtro_ImpendingStorm         = "Atronach della Tempesta: Tempesta Imminente"
L.Settings_Archive_StormAtro_ImpendingStorm_TT      = "Ti avvisa quando l'atronach della tempesta sta per effettuare il suo grande attacco ad area."
L.Settings_Archive_StormAtro_LightningStorm         = "Atronach della Tempesta: Tempesta di Fulmini"
L.Settings_Archive_StormAtro_LightningStorm_TT      = "Ti avverte quando l'atronach della tempesta invoca dei fulmini dal cielo dai quali devi ripararti."
L.Settings_Archive_StoneAtro_BoulderStorm           = "Atronach di Pietra: Tempesta di Pietre"
L.Settings_Archive_StoneAtro_BoulderStorm_TT        = "Ti avvisa quando l'Atronach di Pietra inizia a lanciare pietre contro le persone."
L.Settings_Archive_StoneAtro_BigQuake               = "Atronach di Pietra: Gran Terremoto"
L.Settings_Archive_StoneAtro_BigQuake_TT            = "Ti avvisa quando l'Atronach di Pietra inizia a calpestare il terreno."
L.Settings_Archive_Overcharge                       = "Mob: Sovraccarico"
L.Settings_Archive_Overcharge_TT                    = "Ti avvisa quando sei il bersaglio delle capacità di sovraccarico di un nemico."
L.Settings_Archive_Call_Lightning                   = "Mob: Evocazione dei Fulmini"
L.Settings_Archive_Call_Lightning_TT                = "Ti avvisa quando un nemico sovraccarico ti prende di mira con la sua abilità di Evocazione dei Fulmini."
-- Alerts
L.Alerts_Archive_StormAtro_ImpendingStorm           = "|cFF0000Tempesta Imminente|r in arrivo!"
L.Alerts_Archive_StormAtro_LightningStorm           = "|cfef92eTempesta di Fulmini|r in arrivo! Entra nella luce!"
L.Alerts_Archive_StoneAtro_BoulderStorm             = "|cFF0000Tempesta di Pietra|r in arrivo! Blocca per evitare di essere travolto!"
L.Alerts_Archive_StoneAtro_BigQuake                 = "|cFF0000Gran Terremoto|r in arrivo!"
L.Alerts_Archive_Overcharge                         = "|c46edffSovraccarico|r su di te."
L.Alerts_Archive_Overcharge_Other                   = "|c46edffSovraccarico|r su |cFF0000<<!C:1>>|r."
L.Alerts_Archive_Call_Lightning                     = "|c46edffEvocazione dei Fulmini|r in arrivo su di te. Continua a muoverti!"
L.Alerts_Archive_Call_Lightning_Other               = "|c46edffEvocazione dei Fulmini|r in arrivo su |cFF0000<<!C:1>>|r."


--------------------------------
----    Sanctum Ophidia     ----
--------------------------------
L.Settings_Sanctum_Header                           = "Sanctum Ophidia / Tempio di Ophidia"
-- Settings
L.Settings_Sanctum_Magicka_Detonation               = "Serpente: Detonazione Magicka"
L.Settings_Sanctum_Magicka_Detonation_TT            = "Ti avvisa quando hai il malus della detonazione magicka durante il combattimento contro il Serpente."
L.Settings_Sanctum_Serpent_Poison                   = "Serpente: Fase del Veleno"
L.Settings_Sanctum_Serpent_Poison_TT                = "Ti avvisa quando inizia la fase del veleno durante il combattimento contro il Serpente."
L.Settings_Sanctum_Serpent_World_Shaper             = "Serpente: Modellatore del Mondo (Modalità Difficile)"
L.Settings_Sanctum_Serpent_World_Shaper_TT          = "Ti avverte quando il Serpente inizia il suo attacco Modellatore del Mondo, contando fino a quando non viene scatenato."
L.Settings_Sanctum_Mantikora_Spear                  = "Mantikora: Lancia"
L.Settings_Sanctum_Mantikora_Spear_TT               = "Ti avvisa quando sei il bersaglio dalla lancia della Mantikora."
L.Settings_Sanctum_Mantikora_Quake                  = "Mantikora: Terremoto"
L.Settings_Sanctum_Mantikora_Quake_TT               = "Ti avvisa quando sei il bersaglio dei tre terremoti o delle rune della Mantikora."
L.Settings_Sanctum_Troll_Boulder                    = "Mob: Lancio di Pietre del Troll"
L.Settings_Sanctum_Troll_Boulder_TT                 = "Ti avvisa quando un troll si prepara a lanciarti delle pietre."
L.Settings_Sanctum_Troll_Poison                     = "Mobs: Veleno del Troll"
L.Settings_Sanctum_Troll_Poison_TT                  = "Ti avvisa quando un troll si prepara a lanciarti un veleno contagioso."
L.Settings_Sanctum_Overcharge                       = "Mob: Sovraccarico"
L.Settings_Sanctum_Overcharge_TT                    = "Ti avvisa quando sei il bersaglio delle capacità di sovraccarico di un nemico."
L.Settings_Sanctum_Call_Lightning                   = "Mob: Evocazione dei Fulmini"
L.Settings_Sanctum_Call_Lightning_TT                = "Ti avvisa quando un nemico sovraccarico ti prende di mira con la sua abilità di Evocazione dei Fulmini."
-- Alerts
L.Alerts_Sanctum_Serpent_Poison0                    = "|c39942eFase del Veleno|r in arrivo! Accumulate insieme!"
L.Alerts_Sanctum_Serpent_Poison1                    = "|c39942eFase del Veleno|r in arrivo! Seguito dai |ccc0000Lamia|r."
L.Alerts_Sanctum_Serpent_Poison2                    = "|c39942eFase del Veleno|r in arrivo! Seguito dai |c009933Mantikora|r." --left
L.Alerts_Sanctum_Serpent_Poison3                    = "|c39942eFase del Veleno|r in arrivo! Seguito dai |c009933Mantikora|r." --right
L.Alerts_Sanctum_Serpent_Poison4                    = "|c39942eFase del Veleno|r in arrivo! Seguito dagli |cff33cceScudi|r."
L.Alerts_Sanctum_Serpent_Poison5                    = "|c39942eFase del Veleno|r Finale!"
L.Alerts_Sanctum_Serpent_World_Shaper               = "|c00c832Modellatore del Mondo|r a"
L.Alerts_Sanctum_Magicka_Detonation                 = "|c234afaDetonazione Magicka|r! Consuma tutta la tua magia!"
L.Alerts_Sanctum_Mantikora_Spear                    = "|ccde846Lancia|r del Mantikora su di te! Scappa!"
L.Alerts_Sanctum_Mantikora_Spear_Other              = "|ccde846Lanza|r del Mantikora su <<C:1>>! Scappa!"
L.Alerts_Sanctum_Mantikora_Quake                    = "|ccde846Terremoto|r del Mantikora su di te! Scappa!"
L.Alerts_Sanctum_Troll_Poison                       = "|c66ff33Veneno del Troll|r in arrivo. Non diffonderlo!"
L.Alerts_Sanctum_Troll_Poison_Other                 = "|c66ff33Veneno del Troll|r in arrivo su |cFF0000<<!C:1>>|r."
L.Alerts_Sanctum_Troll_Boulder                      = "|c595959Lancio delle Pietre|r in arrivo. Schivalo!"
L.Alerts_Sanctum_Troll_Boulder_Other                = "|c595959Lancio delle Pietre|r in arrivo su |cFF0000<<!C:1>>|r."
L.Alerts_Sanctum_Overcharge                         = "|c46edffSovraccarico|r in arrivo su di te."
L.Alerts_Sanctum_Overcharge_Other                   = "|c46edffSovraccarico|r in arrivo su |cFF0000<<!C:1>>|r."
L.Alerts_Sanctum_Call_Lightning                     = "|c46edffEvocazione dei Fulmini|r in arrivo su di te. Continua a muoverti!"
L.Alerts_Sanctum_Call_Lightning_Other               = "|c46edffEvocazione dei Fulmini|r in arrivo su |cFF0000<<!C:1>>|r."


--------------------------------
----    Maelstrom Arena / Arena Maelstrom     ----
--------------------------------
L.Settings_Maelstrom_Header                         = "Maelstrom Arena / Arena Maelstrom"
-- Settings
L.Settings_Maelstrom_Stage7_Poison                  = "Fase 7: Veleno"
L.Settings_Maelstrom_Stage7_Poison_TT               = "Ti avvisa quando sei avvelenato durante la Fase 7 (Cripta del Risentimento)."
L.Settings_Maelstrom_Stage9_Synergy                 = "Fase 9: Esplosione Spettrale (Sinergia)"
L.Settings_Maelstrom_Stage9_Synergy_TT              = "Ti avvisa quando hai una Sinergia nella fase 9 (Teatro della Disperazione) dopo aver raccolto 3 Fantasmi (dorati)."
-- Alerts
L.Alerts_Maelstrom_Stage7_Poison                    = "|c39942eAvvelenato|r! Usa una delle due aree per purificarti!"
L.Alerts_Maelstrom_Stage9_Synergy                   = "|c23afe7Esplosione Spettrale|r pronta! Usa la sinergia!"


--------------------------------
----     Maw of Lorkhaj / Fauces de Lorkhaj    ----
--------------------------------
L.Settings_MawLorkhaj_Header								= "Maw of Lorkhaj / Fauci di Lorkhaj"
-- Settings
L.Settings_MawLorkhaj_Zhaj_GripOfLorkhaj            		= "Zhaj'hassa: Morsa di Lorkhaj"
L.Settings_MawLorkhaj_Zhaj_GripOfLorkhaj_TT        			= "Ricevi un avviso quando la morsa di Lorkhaj inizia a influenzarti."
L.Settings_MawLorkhaj_Zhaj_Glyphs                   		= "Zhaj'hassa: Piattaforme di purificazione (beta)"
L.Settings_MawLorkhaj_Zhaj_Glyphs_TT                		= "Mostra una finestra con tutte le piattaforme di purificazione, il loro stato e il tempo di rigenerazione."
L.Settings_MawLorkhaj_Zhaj_Glyphs_Invert            		= "       - Vista invertita"
L.Settings_MawLorkhaj_Zhaj_Glyphs_Invert_TT         		= "Inverti piattaforme di purificazione."
L.Settings_MawLorkhaj_Twin_Aspects                  		= "Gemelli della Luna Falsa: Aspetti"
L.Settings_MawLorkhaj_Twin_Aspects_TT          			    = "Ti avvisa quando ottieni l'aspetto Lunare o Ombra durante la lotta contro i Gemelli della Luna Fals.\n\n    'Completo' ti avvisa quando ottieni un aspetto, quando inizi la conversione in un aspetto e quando la conversione è completa.\n     'Normale' ti avvisa quando ottieni un aspetto e quando inizi la conversione.\n    'Minimale' ti avvisa solo quando inizierà la conversione."
L.Settings_MawLorkhaj_Twin_Aspects_Status          			= "       - Mostra Stato"
L.Settings_MawLorkhaj_Twin_Aspects_Status_TT        		= "Mostra il tuo aspetto attuale nella schermata di stato durante il combattimento con il boss"
L.Settings_MawLorkhaj_Rakkhat_Unstable_Void         		= "Rakkhat: Vuoto Instabile"
L.Settings_MawLorkhaj_Rakkhat_Unstable_Void_TT      		= "Ti avvisa quando hai l'effetto Vuoto Instabile di Rakkhat."
L.Settings_MawLorkhaj_Rakkhat_Unstable_Void_Countdown		= "       - Conto alla Rovescia"
L.Settings_MawLorkhaj_Rakkhat_Unstable_Void_Countdown_TT	= "Quando abilitato, visualizzerà il conto alla rovescia invece di una semplice notifica per il Vuoto Instabile."
L.Settings_MawLorkhaj_Rakkhat_ThreshingWings        		= "Rakkhat: Ali Taglienti"
L.Settings_MawLorkhaj_Rakkhat_ThreshingWings_TT     		= "Ti avvisa quando Rakkhat usa la sua abilità Ali Taglienti, che può atterrarti."
L.Settings_MawLorkhaj_Rakkhat_DarknessFalls         		= "Rakkhat: Cascata di Tenebre"
L.Settings_MawLorkhaj_Rakkhat_DarknessFalls_TT     			= "Ti avvisa quando Rakkhat usa la sua abilità Cascata di Tenebre, dove il soffitto inizia a crollare."
L.Settings_MawLorkhaj_Rakkhat_DarkBarrage           		= "Rakkhat: Sbarramento Oscuro"
L.Settings_MawLorkhaj_Rakkhat_DarkBarrage_TT       			= "Avvisa quando Rakkhat usa la sua abilità Sbarramento Oscuro indirizzata sul tank."
L.Settings_MawLorkhaj_Rakkhat_LunarBastion1        			= "Rakkhat: Bastione Lunare Ottenuto"
L.Settings_MawLorkhaj_Rakkhat_LunarBastion1_TT    			= "Mostra quando un giocatore ottiene la benedizione della piattaforma luminosa."
L.Settings_MawLorkhaj_Rakkhat_LunarBastion2       			= "Rakkhat: Bastione Lunare Perso"
L.Settings_MawLorkhaj_Rakkhat_LunarBastion2_TT      		= "Mostra quando un giocatore perde la benedizione della piattaforma luminosa."
L.Settings_MawLorkhaj_Hulk_ArmorWeakened            		= "Hulk: Armatura Indebolita"
L.Settings_MawLorkhaj_Hulk_ArmorWeakened_TT         		= "Avverte quando Hulk applica una carica di Malus Armatura Indebolita con il suo attacco Colpo Tonante. Non dovrai accumulare più di due cariche del malus o il danno in arrivo sarà troppo alto da gestire."
L.Settings_MawLorkhaj_ShatteringStrike           			= "Mob: Impatto Devastante"
L.Settings_MawLorkhaj_ShatteringStrike_TT        		  	= "Ricevi un avviso quando un selvaggio Dro-m'Athra sta per attaccare con un Impatto Devastante."
L.Settings_MawLorkhaj_Shattered                     		= "Mob: Armatura Distrutta"
L.Settings_MawLorkhaj_Shattered_TT                  		= "Ricevi un avviso quando la tua armatura è distrutta."
L.Settings_MawLorkhaj_MarkedForDeath               			= "Mob: Marchiato per la Morte (Pantere)"
L.Settings_MawLorkhaj_MarkedForDeath_TT           			= "Ricevi un avviso se ricevi il marchio della morte delle Pantere da un Terribile Inseguitore Dro-m'Athra."
L.Settings_MawLorkhaj_Suneater_Eclipse            			= "Mob: Campo dell'Eclisse dei Divora-Sole (Annullamento)"
L.Settings_MawLorkhaj_Suneater_Eclipse_TT         			= "Ricevi un avviso se il Campo dell'Eclisse è su di te."
-- Alerts
L.Alerts_MawLorkhaj_Zhaj_GripOfLorkhaj              = "Attenzione! |c000055Morsa di Lorkhaj!|r Purificati subito!"
L.Alerts_MawLorkhaj_Lunar_Aspect                    = "Ricevuto Aspetto |cFEFF7FLunare|r."
L.Alerts_MawLorkhaj_Shadow_Aspect                   = "Ricevuto Aspetto |c000055Ombra|r."
L.Alerts_MawLorkhaj_Lunar_Conversion                = "Conversione in Aspetto |cFEFF7FLunare|r."
L.Alerts_MawLorkhaj_Shadow_Conversion               = "Conversione in Aspetto |c000055Ombra|r."
L.Alerts_MawLorkhaj_Rakkhat_Unstable_Void           = "Pericolo! |c000055Vuoto Instabile|r sotto di te."
L.Alerts_MawLorkhaj_Rakkhat_Unstable_Void_Other     = "Pericolo! |c000055Vuoto Instabile|r sotto |cFF0000<<C:1>>|r."
L.Alerts_MawLorkhaj_Rakkhat_ThreshingWings          = "|cFF0000Ali Taglienti|r in arrivo! Blocca!"
L.Alerts_MawLorkhaj_Rakkhat_DarknessFalls           = "|cFF0000Cascata di Tenebre|r in arrivo!"
L.Alerts_MawLorkhaj_Rakkhat_DarkBarrage             = "|cFF0000Sbarramento Oscuro|r in arrivo."
L.Alerts_MawLorkhaj_Rakkhat_LunarBastion1           = "Hai Ottenuto il |cFEFF7FBastione Lunare|r."
L.Alerts_MawLorkhaj_Rakkhat_LunarBastion1_Other     = "|cFF0000<<C:1>>|r ha ottenuto il |cFEFF7FBastione Lunare|r."
L.Alerts_MawLorkhaj_Rakkhat_LunarBastion2           = "Hai Perso il |cFEFF7FBastione Lunare|r."
L.Alerts_MawLorkhaj_Rakkhat_LunarBastion2_Other     = "|cFF0000<<C:1>>|r ha perso il |cFEFF7FBastione Lunare|r."
L.Alerts_MawLorkhaj_Hulk_ArmorWeakened1             = "Hai accumulato 1 carica del malus |c000055Armatura indebolita|r."
L.Alerts_MawLorkhaj_Hulk_ArmorWeakened1_Other       = "|cFF0000<<!aC:1>>|r ha accumulato 1 carica del malus |c000055Armatura Indebolita|r."
L.Alerts_MawLorkhaj_Hulk_ArmorWeakened2             = "Hai accumulato |cFF00002 cariche|r del malus |c000055Armatura Indebolita|r!"
L.Alerts_MawLorkhaj_Hulk_ArmorWeakened2_Other       = "|cFF0000<<!aC:1>>|r ha accumulato |cFF00002 cariche|r del malus |c000055Armatura Indebolita|r!"
L.Alerts_MawLorkhaj_Suneater_Eclipse                = "|cFF0000Campo dell'Eclisse|r in arrivo su di te."
L.Alerts_MawLorkhaj_Suneater_Eclipse_Other          = "|cFF0000Campo dell'Eclisse|r in arrivo su |cFF0000<<C:1>>|r!"
L.Alerts_MawLorkhaj_ShatteringStrike                = "|c000055Impatto Devastante|r in arrivo su di te."
L.Alerts_MawLorkhaj_ShatteringStrike_Other          = "|c000055Impatto Devastante|r in arrivo su |cFF0000<<C:1>>|r!"
L.Alerts_MawLorkhaj_Shattered                       = "La tua |c595959Armatura|r è stata |cff0000Distrutta|r."
L.Alerts_MawLorkhaj_MarkedForDeath                  = "Attenzione! Le |c000055Pantere|r ti stanno inseguendo!"


--------------------------------
----    Dragonstar Arena / Arena de Estrella del Dragón    ----
--------------------------------
L.Settings_Dragonstar_Header                        = "Dragonstar Arena / Arena della Stella del Drago"
-- Settings
L.Settings_Dragonstar_General_Taking_Aim            = "Generale: Prendi la Mira"
L.Settings_Dragonstar_General_Taking_Aim_TT         = "Ti avvisa quando sei il bersaglio dell'abilità Prendi la Mira."
L.Settings_Dragonstar_General_Crystal_Blast         = "Generale: Esplosione di Cristallo"
L.Settings_Dragonstar_General_Crystal_Blast_TT      = "Ti avvisa quando sei il bersaglio dall'abilità Esplosione di Cristallo."
L.Settings_Dragonstar_Arena2_Crushing_Shock         = "Arena 2: Scarica Distruttiva"
L.Settings_Dragonstar_Arena2_Crushing_Shock_TT      = "Ti avvisa quando sei il bersaglio dall'abilità Scarica Distruttivo nell'Arena del Ghiaccio."
L.Settings_Dragonstar_Arena6_Drain_Resource         = "Arena 6: Prosciuga Risorse"
L.Settings_Dragonstar_Arena6_Drain_Resource_TT      = "Ti avvisa quando sei il bersaglio dalle frecce avvelenate Prosciuga Risorse nell'Arena Bosmer."
L.Settings_Dragonstar_Arena7_Unstable_Core          = "Arena 7: Nucleo Instabile (Eclissi)"
L.Settings_Dragonstar_Arena7_Unstable_Core_TT       = "Ti avvisa quando un Nucleo Instabile (Eclissi) è posizionato su di te dal Boss Templari nell'Arena Sacrificale."
L.Settings_Dragonstar_Arena8_Ice_Charge             = "Arena 8: Carica Glaciale"
L.Settings_Dragonstar_Arena8_Ice_Charge_TT          = "Ti avvisa quando un Centurione di Ghiaccio sta per lanciare il suo attacco di ghiaccio."
L.Settings_Dragonstar_Arena8_Fire_Charge            = "Arena 8: Carica Infuocata"
L.Settings_Dragonstar_Arena8_Fire_Charge_TT         = "Ti avvisa quando un Centurione di Fuoco sta per lanciare il suo attacco di fuoco."
-- Alerts
L.Alerts_Dragonstar_General_Taking_Aim              = "|cFF6600Prendi la Mira|r è su di te!"
L.Alerts_Dragonstar_General_Crystal_Blast           = "|c990099Esplosione di Cristallo|r è su di te!"
L.Alerts_Dragonstar_Arena2_Crushing_Shock           = "|c3366EEScarica Distruttiva|r in arrivo! Blocca!"
L.Alerts_Dragonstar_Arena6_Drain_Resource           = "|c00CC00Prosciuga Risorse|r in arrivo! Schiva!"
L.Alerts_Dragonstar_Arena6_Drain_Resource_Other     = "|c00CC00Prosciuga Risorse|r in arrivo su |cFF0000<<C:1>>|r."
L.Alerts_Dragonstar_Arena7_Unstable_Core            = "Hai il |cDDDD33Nucleo Instabile|r! Liberati!"
L.Alerts_Dragonstar_Arena8_Ice_Charge               = "|c6699FFCarica Glaciale|r in arrivo su di te! Interrompi o Schiva!"
L.Alerts_Dragonstar_Arena8_Ice_Charge_Other         = "|c6699FFCarica Glaciale|r viene lanciata su |cFF0000<<C:1>>|r. Interrompi!"
L.Alerts_Dragonstar_Arena8_Fire_Charge              = "|cFF3113Carica Infuocata|r in arrivo su di te! Interrompi o Schiva!"
L.Alerts_Dragonstar_Arena8_Fire_Charge_Other        = "|c6699FCarica Infuocata|r viene lanciata su |cFF0000<<C:1>>|r. Interrompi!"



--------------------------------
---- Halls Of Fabrication / Salones de Fabricación   ----
--------------------------------
L.Settings_HallsFab_Header                          = "Halls of Fabrication / Sale di Fabbricazione"
-- Settings
L.Settings_HallsFab_Taking_Aim                      = "Generale: Prendi la Mira"
L.Settings_HallsFab_Taking_Aim_TT                   = "Ti avvisa quando sei il bersaglio dell'abilità Prendi la Mira."
L.Settings_HallsFab_Taking_Aim_Dynamic              = "       - Conto alla Rovescia"
L.Settings_HallsFab_Taking_Aim_Dynamic_TT           = "Se abilitato, mostrerà il conto alla rovescia invece di una semplice notifica prima dell'attacco Prendi la Mira."
L.Settings_HallsFab_Taking_Aim_Duration             = "       - Durata del Conto alla Rovescia"
L.Settings_HallsFab_Taking_Aim_Duration_TT          = "La durata del conto alla rovescia in millisecondi."
L.Settings_HallsFab_Draining_Ballista               = "Generale: Balista Drenante"
L.Settings_HallsFab_Draining_Ballista_TT            = "Ti avvisa quando l'attacco della sfera deve essere interrotto."
L.Settings_HallsFab_Conduit_Strike                  = "Generale: Colpo Conduttore"
L.Settings_HallsFab_Conduit_Strike_TT               = "Ti avvisa quando è in arrivo il Colpo Conduttore."
L.Settings_HallsFab_Power_Leech                     = "Generale: Scarica Drenante"
L.Settings_HallsFab_Power_Leech_TT                  = "Ti avvisa quando sei stordito dal Colpo Condottore e devi liberarti."
L.Settings_HallsFab_Venom_Injection                 = "Cacciatori: Iniezione di Veleno"
L.Settings_HallsFab_Venom_Injection_TT              = "Mostra una finestra di stato per quando sei affetto da Iniezione di Veleno durante i Boss Cacciatore."
L.Settings_HallsFab_Conduit_Spawn                   = "Pinnacolo: Apparizione dei Conduttori"
L.Settings_HallsFab_Conduit_Spawn_TT                = "Ti avvisa quando viene generato un Conduttore durante il combattimento contro il boss Factotum del Pinnacolo."
L.Settings_HallsFab_Conduit_Drain                   = "Pinnacolo: Conduttore Dranante"
L.Settings_HallsFab_Conduit_Drain_TT                = "Ti avvisa quando un Conduttore ti sta prosciugando durante il combattimento contro il boss Factotum del Pinnacolo."
L.Settings_HallsFab_Scalded_Debuff                  = "Pinnacolo: Malus Ustione"
L.Settings_HallsFab_Scalded_Debuff_TT               = "Mostra una piccola icona di stato che riporta il tempo fino a quando non scompare e quanto è grande l'effetto del malus sulla guarigione."
L.Settings_HallsFab_Overcharge_Aura                 = "Comitato: Aura Sovraccarica"
L.Settings_HallsFab_Overcharge_Aura_TT              = "Ti avvisa quando il Rivendicatore inizia a sovraccaricare la sua aura."
L.Settings_HallsFab_Overpower_Auras                 = "Comitato: Aure Travolgenti"
L.Settings_HallsFab_Overpower_Auras_TT              = "Ti avvisa quando i tank devono scambiarsi i Boss del Comitato"
L.Settings_HallsFab_Overpower_Auras_Duration        = "       - Durata del Conto alla Rovescia"
L.Settings_HallsFab_Overpower_Auras_Duration_TT     = "La durata del conto alla rovescia in millisecondi."
L.Settings_HallsFab_Overpower_Auras_Dynamic         = "       - Conto alla Rovescia Dinamico"
L.Settings_HallsFab_Overpower_Auras_Dynamic_TT      = "Quando viene attivato, tenterà di interrompere il conto alla rovescia una volta che i tank avranno scambiato i boss."
L.Settings_HallsFab_Fabricant_Spawn                 = "Comitato: Apparizione dei Fabbricanti Danneggiati"
L.Settings_HallsFab_Fabricant_Spawn_TT              = "Ti avvisa quando viene visualizzato un Fabbricante Danneggiato."
L.Settings_HallsFab_Catastrophic_Discharge          = "Comitato: Sscarica Catastrofica"
L.Settings_HallsFab_Catastrophic_Discharge_TT       = "Ti avvisa quando un Fabbricante Danneggiato avvia una scarica contro di te."
L.Settings_HallsFab_Reclaim_Achieve                 = "Comitato: Reclama il Danneggiato - Obbiettivo Fallito"
L.Settings_HallsFab_Reclaim_Achieve_TT              = "Ti avvisa quando il bombardiere raggiunge il Vendicatore."
-- Alerts
L.Alerts_HallsFab_Taking_Aim                        = "|cFF6600Prendi la Mira|r è su di te!"
L.Alerts_HallsFab_Taking_Aim_Other                  = "|cFF6600Prendi la Mira|r è su |cFF0000<<C:1>>|r!"
L.Alerts_HallsFab_Taking_Aim_Simple                 = "|cFF6600Prendi la Mira|r."
L.Alerts_HallsFab_Conduit_Spawn                     = "Sta per apparire un Conduttore."
L.Alerts_HallsFab_Conduit_Drain                     = "Un Conduttore ti sta prosciugando!"
L.Alerts_HallsFab_Conduit_Drain_Other               = "Un Conduttore sta prosciugando |cFF0000<<C:1>>|r!"
L.Alerts_HallsFab_Conduit_Strike                    = "|cFF0000Colpo Conduttore|r in arrivo. Blocca!"
L.Alerts_HallsFab_Draining_Ballista                 = "|cFFC000Balista Drenante|r su di te! Blocca o Interrompi!"
L.Alerts_HallsFab_Draining_Ballista_Other           = "|cFFC000Balista Drenante|r su |cFF0000<<C:1>>|r! Interrompi!"
L.Alerts_HallsFab_Power_Leech                       = "|c6600FFPotere Prosciugante|r! Liberati!"
L.Alerts_HallsFab_Overcharge_Aura                   = "|c3366EEAura Sovraccarica|r del Rivendicatore."
L.Alerts_HallsFab_Overpower_Auras                   = "|cFF0000Conto alla Rovescia dell'Aura!|r"
L.Alerts_HallsFab_Catastrophic_Discharge            = "|cFF0000Scarica Catastrofica|r su di te! Blocca!"
L.Alerts_HallsFab_Fabricant_Spawn                   = "|cFFC000È apparso un Fabbricante Difettoso|r."
L.Alerts_HallsFab_Reclaim_Achieve                   = "|cDCD822[Obsolescenza Programmata]|r - Obbiettivo |cFF0000Fallito|r."



--------------------------------
----   Asylum Sanctorium    ----
--------------------------------
L.Settings_Asylum_Header                         = "Asylum Sanctorium"
-- Settings
L.Settings_Asylum_Defiling_Blast                 = "San Llothis: Esplosione di Tintura Contaminate"
L.Settings_Asylum_Defiling_Blast_TT              = "Ti avvisa quando San Llothis prende come bersaglio te o altri con il suo attacco a cono."
L.Settings_Asylum_Soul_Stained_Corruption        = "San Llothis: Corruzione dell'Anima Contaminata"
L.Settings_Asylum_Soul_Stained_Corruption_TT     = "Ti avvisa quando San Llothis prende come bersaglio un giocatore con il suo attacco che dovrà essere interrotto."
L.Settings_Asylum_Teleport_Strike                = "San Felms: Attacco Teletrasportato"
L.Settings_Asylum_Teleport_Strike_TT             = "Ti avvisa quando San Felms si teletrasporterà da te."
L.Settings_Asylum_Exhaustive_Charges             = "San Olms: Carichi Faticosi"
L.Settings_Asylum_Exhaustive_Charges_TT          = "Ti avvisa quando San Olms sta per lanciare il suo attacco che lascia dietro di sé tre grandi cerchi di fulmini."
L.Settings_Asylum_Storm_The_Heavens              = "San Olms: Assalto dai Cieli"
L.Settings_Asylum_Storm_The_Heavens_TT           = "Ti avvisa quando San Olms sta per volare e generare un gran numero di piccoli cerchi di fulmini."
L.Settings_Asylum_Gusts_Of_Steam                 = "San Olms: Raffiche di Vapore"
L.Settings_Asylum_Gusts_Of_Steam_TT              = "Ti avvisa quando San Olms sta per saltare da una parte all'altra, segnalando la fase successiva del combattimento."
L.Settings_Asylum_Gusts_Of_Steam_Slider          = "       - Percentuale prima del salto"
L.Settings_Asylum_Gusts_Of_Steam_Slider_TT       = "Mostra una notifica in percentuale prima che il boss esegua il suo salto."
L.Settings_Asylum_Protector_Spawn                = "San Olms: Apparizione del Protettore"
L.Settings_Asylum_Protector_Spawn_TT             = "Ti avvisa quando sta per apparire un Protettore."
L.Settings_Asylum_Trial_By_Fire                  = "San Olms: Prova del Fuoco"
L.Settings_Asylum_Trial_By_Fire_TT               = "Ti avvisa quando San Olms è in fase di escuzione del lancio del fuoco."
-- Alerts
L.Alerts_Asylum_Defiling_Blast                   = "Pericolo! |c00cc00Esplosione di Tintura Contaminate|r su di te."
L.Alerts_Asylum_Defiling_Blast_Other             = "Pericolo! |c00cc00Esplosione di Tintura Contaminate|r su |cFF0000<<C:1>>|r."
L.Alerts_Asylum_Soul_Stained_Corruption          = "|c3366EECorruzione dell'Anima Contaminata|r in arrivo. Interrompi!"
L.Alerts_Asylum_Teleport_Strike                  = "|cFF3366Attacco Teletrasportato|r su di te."
L.Alerts_Asylum_Teleport_Strike_Other            = "|cFF3366Attacco Teletrasportato|r su |cFF0000<<C:1>>|r."
L.Alerts_Asylum_Exhaustive_Charges               = "|cFF0000Carichi Faticosi|r in arrivo."
L.Alerts_Asylum_Storm_The_Heavens                = "|cFF0000Assalto dai Cieli|r in arrivo! Allontanati lentamente!"
L.Alerts_Asylum_Gusts_Of_Steam                   = "|cFF9900Raffiche di Vapore|r in arrivo! Nasconditi!"
L.Alerts_Asylum_Pre_Gusts_Of_Steam               = "<<1>> per il |cFF0000salto|r! Preparati a nasconderti!"
L.Alerts_Asylum_Trial_By_Fire                    = "|cFF5500Fuoco|r in arrivo!"
L.Alerts_Asylum_Protector_Spawn                  = "Il |c0000FFProtettore|r è apparso!"
L.Alerts_Asylum_Protector_Active                 = "Il |c0000FFProtettore|r è attivo!"



--------------------------------
------   CLOUDREST         -----
--------------------------------
L.Settings_Cloudrest_Header			            = "Cloudrest"
-- Settings
L.Settings_Cloudrest_Olorime_Spears             = "Generale: Lancia di Olorime"
L.Settings_Cloudrest_Olorime_Spears_TT          = "Ti avvisa quando sono apparse le lance e qualcuno deve raccoglierle."
L.Settings_Cloudrest_Shadow_Realm_Cast          = "Generale: Apparizione del Portale"
L.Settings_Cloudrest_Shadow_Realm_Cast_TT       = "Ti avvisa quando appare un portale per il Regno delle Ombre."
L.Settings_Cloudrest_Hoarfrost                  = "Faralielle: Brina"
L.Settings_Cloudrest_Hoarfrost_TT               = "Ti avvisa quando hai il malus Brina su di te, che richiede l'attivazione di una sinergia per rimuoverla"
L.Settings_Cloudrest_Hoarfrost_Countdown        = "       - Usa Conto alla Rovescia"
L.Settings_Cloudrest_Hoarfrost_Countdown_TT     = "Mostra un conto alla rovescia che ti dirà quando puoi rilasciarla."
L.Settings_Cloudrest_Hoarfrost_Shed             = "Faralielle: Rilascia Brina"
L.Settings_Cloudrest_Hoarfrost_Shed_TT          = "Ti avvisa quando il malus Brina è stato rilasciato da un altro giocatore e deve essere raccolto."
L.Settings_Cloudrest_Heavy_Attack               = "Mini Boss: Attacco Pesante"
L.Settings_Cloudrest_Heavy_Attack_TT            = "Ti avvisa quando il mini boss del Fulmine (Colpo Elettrizzante), Fuoco (Spaccatura Ardente) o Gelo (Colpo Devastante) sta preparando un attacco pesante."
L.Settings_Cloudrest_Chilling_Comet             = "Faralielle: Cometa Gelida"
L.Settings_Cloudrest_Chilling_Comet_TT          = "Ti avvisa quando ti viene applicato il malus Cometa Gelida e devi bloccarlo senza incrociare un altro giocatore che ha lo stesso malus prima dell'esplosione."
L.Settings_Cloudrest_Roaring_Flare              = "Siroria: Fiamma Ruggente"
L.Settings_Cloudrest_Roaring_Flare_TT           = "Ti avvisa quando tu o un membro del tuo gruppo avete il malus Fiamma Ruggente che richiede che almeno 3 membri si raggruppino insieme per annullarlo."
L.Settings_Cloudrest_Track_Roaring_Flare        = "       - Segui Fiamma Ruggente"
L.Settings_Cloudrest_Track_Roaring_Flare_TT     = "Mostra una freccia sottile attorno al reticolo che punta verso il giocatore colpito dalla Fiamma Ruggente."
L.Settings_Cloudrest_Voltaic_Overload           = "Belanaril: Sovraccarico Voltaico"
L.Settings_Cloudrest_Voltaic_Overload_TT        = "Ti avvisa quando stai per ottenere il malus Sovraccarico Voltaico,con il quale, dopo che malus ti ha colpito, non dovresti cambiare la tua barra delle abilità per 10 secondi."
L.Settings_Cloudrest_Nocturnals_Favor	        = "Z'Maja: Favore di Nocturnal"
L.Settings_Cloudrest_Nocturnals_Favor_TT        = "Ti avvisa quando Z'Maja ti prende come bersaglio con il suo attacco pesante."
L.Settings_Cloudrest_Baneful_Barb               = "Yaghra Mostruoso: Spina Dannosa"
L.Settings_Cloudrest_Baneful_Barb_TT            = "Ti avvisa quando lo Yaghra Mostruoso ti ha preso come bersaglio prima e sta per eseguire il suo attacco Spina Dannosa."
L.Settings_Cloudrest_Break_Amulet               = "Z'Maja: Solo meccaniche importante della fase finale"
L.Settings_Cloudrest_Break_Amulet_TT            = "Disabilita le notifiche delle Sfere e dei Tentacoli in fase di esecuzione."
L.Settings_Cloudrest_Sum_Shadow_Beads           = "Z'Maja: Sfere"
L.Settings_Cloudrest_Sum_Shadow_Beads_TT        = "Ti avvisa quando stanno per apparire le Sfere."
L.Settings_Cloudrest_Tentacle_Spawn             = "Z'Maja: Apparizione dei Rampicanti"
L.Settings_Cloudrest_Tentacle_Spawn_TT          = "Ti avvisa quando stanno per apparire le Rampicanti di Nocturnal."
L.Settings_Cloudrest_Crushing_Darkness          = "Z'Maja: Oscurità Schiacciante"
L.Settings_Cloudrest_Crushing_Darkness_TT       = "Ti avvisa quando l'AoE ti sta seguendo e devi allontanarti."
L.Settings_Cloudrest_Malicious_Strike           = "Z'Maja: Colpo Dannoso"
L.Settings_Cloudrest_Malicious_Strike_TT        = "Ti avvisa quando le Sfere sono state distrutte e devi bloccare o schivare."
L.Settings_Cloudrest_Shadow_Splash              = "Z'Maja: Shadow Splash"
L.Settings_Cloudrest_Shadow_Splash_TT           = "Alerts you when Z'Maja starts channeling this spell. If not interrupted in time, some players will be teleported into the sky and take fall damage."

-- Alerts
L.Alerts_Cloudrest_Olorime_Spears               = "Le |cffd000Lance|r! sono apparse! (<<1>>)"
L.Alerts_Cloudrest_Hoarfrost0                   = "|c00ddffBrina|r su di te!"
L.Alerts_Cloudrest_Hoarfrost1                   = "|cff0000Ultima|r |c00ddffBrina|r su di te!"
L.Alerts_Cloudrest_Hoarfrost_Other0             = "|c00ddffBrina|r su |cff0000<<!C:1>>|r."
L.Alerts_Cloudrest_Hoarfrost_Other1             = "|cff0000Ultima|r |c00ddffBrina|r su |cff0000<<!C:1>>|r."
L.Alerts_Cloudrest_Hoarfrost_Countdown0         = "Liberati dalla |c00ddffBrina|r a..."
L.Alerts_Cloudrest_Hoarfrost_Countdown1         = "Liberati dall'|cff0000Ultima|r |c00ddffBrina|r a..."
L.Alerts_Cloudrest_Hoarfrost_Syn                = "|cff0000Usa la Sinergia|r per liberarti della Brina!"
L.Alerts_Cloudrest_Hoarfrost_Shed               = "|c00ddffBrina|r rilasciata."
L.Alerts_Cloudrest_Hoarfrost_Shed_Other         = "|c00ddffBrina|r rilasciata da |cff0000<<!C:1>>|r."
L.Alerts_Cloudrest_Heavy_Attack                 = "|c0bf29eAttacco Pesante|r su di te!"
L.Alerts_Cloudrest_Heavy_Attack_Other           = "|c0bf29eAttacco Pesante|r su |cff0000<<!C:1>>|r!"
L.Alerts_Cloudrest_Baneful_Barb                 = "|cff0000Spina Dannosa|r. Schiva!"
L.Alerts_Cloudrest_Baneful_Barb_Other           = "|cff0000Spina Dannosa|r su |cff0000<<!C:1>>|r."
L.Alerts_Cloudrest_Chilling_Comet               = "|cff0000Cometa Gelida|r su di te. Blocca!"
L.Alerts_Cloudrest_Roaring_Flare                = "|cff7700Fiamma Ruggente|r su di te."
L.Alerts_Cloudrest_Roaring_Flare_2              = "|cff0000<<!C:1>>|r |t100%:100%:Esoui/Art/Buttons/large_leftarrow_up.dds|t |cff7700Fiamma Ruggente|r |t100%:100%:Esoui/Art/Buttons/large_rightarrow_up.dds|t |cff0000<<!C:2>>|r."
L.Alerts_Cloudrest_Roaring_Flare_Other          = "|cff7700Fiamma Ruggente|r su |cff0000<<!C:1>>|r. Raggruppatevi!"
L.Alerts_Cloudrest_Voltaic_Current              = "|c55b4d4Sovraccarico Voltaico|r in arrivo su di te tra:"
L.Alerts_Cloudrest_Voltaic_Overload             = "|c4d61c1Sovraccarico Voltaico|r su di te! Cambi la barra delle abilità!"
L.Alerts_Cloudrest_Voltaic_Overload_Cd          = "|c4d61c1Sovraccarico Voltaico|r. Non cambiare la barra delle abilità!"
L.Alerts_Cloudrest_Shadow_Realm_Cast            = "Apparizione del |cab82ffPortale|r: (<<1>>)"
L.Alerts_Cloudrest_Tentacle_Spawn               = "Le |c00a86bRampicananti|r sono apparse."
L.Alerts_Cloudrest_Sum_Shadow_Beads             = "Le |cab82ffSfere|r stanno per apparire."
L.Alerts_Cloudrest_Nocturnals_Favor             = "|cff0000Favore di Nocturnal|r su di te!"
L.Alerts_Cloudrest_Crushing_Darkness            = "|cfc0c66Oscurità Schiacciante|r su di te. Stai lontano dal gruppo!"
L.Alerts_Cloudrest_Malicious_Strike             = "|cff0000Colpo Dannoso|r su di te. Blocca!"
L.Alerts_Cloudrest_Shadow_Splash                = "Z'Maja is casting. |cFF0000Interrupt|r!"

--------------------------------
------   SUNSPIRE          -----
--------------------------------
L.Settings_Sunspire_Header				  = "Sunspire"
-- Settings
L.Settings_Sunspire_Chilling_Comet        = "Generale: Cometa Gelida"
L.Settings_Sunspire_Chilling_Comet_TT     = "Te avisa cuando un cometa gélido se dirige hacia ti. Aléjate del grupo, bloquea y no te cruces con otro jugador que también sea objetivo de un cometa gélido. Este ataque tomará como objetivo a dos jugadores a la vez."
L.Settings_Sunspire_Sweeping_Breath	      = "Nahviintaas: Respiro Profondo"
L.Settings_Sunspire_Sweeping_Breath_TT    = "Ti avvisa del soffio di fuoco di Nahviintas. L'attacco inizia da un lato dell'arena e l'attraversa fino all'altra estremità, ferendo tutti i giocatori all'interno dell'area. I giocatori devono bloccare o schivare questo attacco."
L.Settings_Sunspire_Molten_Meteor         = "Nahviintaas: Meteora Fusa"
L.Settings_Sunspire_Molten_Meteor_TT	  = "Ti avvisa quando una Meteora Fusa si sta dirigendo verso di te. Spostati sul bordo dell'arena, blocca e cerca di non incontrare un altro giocatore che è l'obiettivo di una meteora fusa. Questo attacco prenderà come bersaglio tre giocatori alla volta."
L.Settings_Sunspire_Focus_Fire            = "Yolnahkriin: Fuoco Concentrato"
L.Settings_Sunspire_Focus_Fire_TT         = "Ti avvisa quando un membro del gruppo viene preso come bersaglio dal Fuoco Concentrato. Questo attacco richiede che i membri del gruppo si stringano insieme per dissipare il danno. Ci sarà un malus persistente dopo l'attacco, aumentando il danno subito del successivo Fuoco Concentrato. A causa di questo effetto, i giocatori dovrebbero raggrupparsi in due gruppi separati."
L.Settings_Sunspire_Breath                = "Generale: Respiro di Fuoco/del Gelo/Bollente"
L.Settings_Sunspire_Breath_TT             = "Ti avvisa quando il cono dell'attacco è orientato su di te, infliggendo gravi danni. "
L.Settings_Sunspire_Cataclism             = "Yolnahkriin: Cataclisma"
L.Settings_Sunspire_Cataclism_TT          = "Ti avvisa quando il boss userà il suo Respiro di Fuoco nel mezzo dell'arena. Tutti devono spostarsi ai margini dell'arena e uccidere i nemici aggiuntivi. "
L.Settings_Sunspire_Frozen_Tomb           = "Lokkestiiz: Tomba di Ghiaccio"
L.Settings_Sunspire_Frozen_Tomb_TT        = "Ti avvisa quando appare una Tomba di Ghiaccio. Un giocatore dovrà entrare nella tomba, che lo congelerà e infliggerà danni nel tempo. Dovrà essere guarito per essere liberato. Richiede tre giocatori diversi completare la tomba, uno alla volta, a causa del malus."
L.Settings_Sunspire_Thrash                = "Nahviintaas: Flagello"
L.Settings_Sunspire_Thrash_TT             = "Ti avvisa quando il boss sta per colpire il gruppo con la testa, abbattendovi tutti. Questo attacco deve essere schivato o bloccato."
L.Settings_Sunspire_Mark_For_Death        = "Nahviintaas: Marchio dell  Morte"
L.Settings_Sunspire_Mark_For_Death_TT     = "Ti avvisa quando hai un marchio della morte, che infligge gravi danni nel tempo e rimuove completamente tutta la tua resistenza."
L.Settings_Sunspire_Time_Breach           = "Nahviintaas: Breccia Temporale"
L.Settings_Sunspire_Time_Breach_TT        = "Ti avvisa quando è stato aperto un portale per le modifiche temporali."
L.Settings_Sunspire_Negate_Field          = "Servitore Eterno: Campo di Annullamento"
L.Settings_Sunspire_Negate_Field_TT       = "Mostra un avviso se il Campo di Annullamento influisce su di te dopo la Breccia Temporale."
L.Settings_Sunspire_Shock_Bolt            = "Servitore Eterno: Proiettile Elettrico"
L.Settings_Sunspire_Shock_Bolt_TT         = "Visualizza un conto alla rovescia del Proiettile Elettrico che ti informa quando il gruppo dovrà stringersi per far rimuovere un giocatore."
L.Settings_Sunspire_Apocalypse            = "Servitore Eterno: Apocalisse Transitoria"
L.Settings_Sunspire_Apocalypse_TT         = "Ti avvisa quando un Servitore Eterno sta incanalando il suo attacco verso il gruppo nel livello superiore. Ti mostra un conto alla rovescia fino a quando non puoi interrompere la canalizzazione e finché non finisce di incanalare l'attacco."


-- Alerts
L.Alerts_Sunspire_Chilling_Comet          = "|c00ddffCometa Gelida|r su di te. Blocca!"
L.Alerts_Sunspire_Chilling_Comet_Other    = "|c00ddffCometa gélido|r sobre |cff0000<<!C:1>>|r."
L.Alerts_Sunspire_Sweeping_Breath         = "|cff0000Respiro Profondo|r! Blocca o schiva!"
L.Alerts_Sunspire_Molten_Meteor           = "|c00ddffMeteora Fusa|r su di te! Stai lontano dal gruppo!"
L.Alerts_Sunspire_Molten_Meteor_Other     = "|c00ddffMeteora Fusa|r su <<!C:1>>|r."
L.Alerts_Sunspire_Focus_Fire              = "|cff7700Fuoco Concentrato|r su di te tra:"
L.Alerts_Sunspire_Focus_Fire_Other        = "|cff7700Fuoco Concentrato|r su |cff0000<<!C:1>>|r tra:"
L.Alerts_Sunspire_Atronach_Zap            = "Gli |cff7700Atronach|r appariranno tra"
L.Alerts_Sunspire_Frost_Atronach          = "Gli |cff7700Atronach del Gelo|r sono apparsi!"
L.Alerts_Sunspire_Breath                  = "|cffff00<<1>>|r su di te!"
L.Alerts_Sunspire_Breath_Other            = "|cffff00<<1>>|r su |cff0000<<!C:2>>|r."
L.Alerts_Sunspire_Cataclism               = "|cff3300Cataclisma|r termina tra:"
L.Alerts_Sunspire_Frozen_Tomb             = "|c00ddffTomba del Ghiaccio|r: (<<1>>)"
L.Alerts_Sunspire_Thrash                  = "|cff0000Flagello|r in arrivo! Blocca!"
L.Alerts_Sunspire_Mark_For_Death          = "Marchio della Morte su di te"
L.Alerts_Sunspire_Mark_For_Death_Other    = "Marchio della Morte su |cff0000<<!C:1>>|r."
L.Alerts_Sunspire_Time_Breach_Countdown   = "|c81cc00Breccia Temporale|r tra:"
L.Alerts_Sunspire_Negate_Field            = "|c53c4c9Campo di Annullamento|r su di te!"
L.Alerts_Sunspire_Negate_Field_Others     = "|c53c4c9Campo di Annullamento|r su <<!C:1>>!"
L.Alerts_Sunspire_Shock_Bolt              = "|c00ddffProiettile Elettrico|r in arrivo! Raggruppatevi per disperderlo!"
L.Alerts_Sunspire_Apocalypse              = "|cffff00Apocalisse Transitoria|r in arrivo! Interrompi."
L.Alerts_Sunspire_Apocalypse_Ends         = "|cffff00Apocalisse Transitoria|r terminerà tra:"


--------------------------------
------   KYNE'S AEGIS      -----
--------------------------------
L.Settings_KynesAegis_Header                        = "Egida di Kyne"
-- Settings
L.Settings_KynesAegis_Crashing_Wall                 = "Generale: Onda schiacciante"
L.Settings_KynesAegis_Crashing_Wall_TT              = "Ti avvisa quando il Mezzo Gigante Rompighiaccio inizia il suo attacco Onda Schiacciante, con un conto alla rovescia fino a quando non si scatena. Blocca o rotola per schivarlo."
L.Settings_KynesAegis_Sanguine_Prison               = "Generale: Prigione Sanguinaria"
L.Settings_KynesAegis_Sanguine_Prison_TT            = "Ti avvisa quando il tuo alleato è intrappolato nella Prigione Sanguinaria lanciata dal Cavaliere Pungente. Devi liberare il tuo alleato focalizzandoti sulla sua prigione."
L.Settings_KynesAegis_Blood_Fountain                = "Generale: Fontana del Sangue"
L.Settings_KynesAegis_Blood_Fountain_TT             = "Ti avvisa quando Cavaliere del Sangue inizia il suo attacco Fontana del Sangue, con un conto alla rovescia fino a quando non si scatena. Ha l'aspetto di un AoE(effetto ad area) a forma di croce, e deve essere evitato perché infligge danni pesanti."
L.Settings_KynesAegis_Totem                         = "Yandir: Apparizione dei Totem"
L.Settings_KynesAegis_Totem_TT                      = "Ti avvisa quando alcuni totem appaiono durante la battaglia con il boss Yandir il Macellaio.\n\nTotem del Drago: ne appaiono sempre due allo stesso tempo; ognuno di loro spara del fuoco lungo una linea retta nelle due direzioni opposte.\nTotem dell'Arpia: genera un'aura di fulmine che irradia l'esterno.\nTotem del Gargoyle: immobilizza giocatori a caso nella pietra.\nTotem del Chaurus: avvelena diverse persone, e questo veleno non deve essere diffuso agli altri, ecco perché non andrebbe accumulato in questa fase."
L.Settings_KynesAegis_Yandir_FireShaman_Meteor      = "Yandir HM: Meteors"
L.Settings_KynesAegis_Yandir_FireShaman_Meteor_TT   = "Alerts you when Butcher's Fire Shamans will cast meteors on players."
L.Settings_KynesAegis_Vrol_FireMage_Meteor          = "Vrol: Meteors"
L.Settings_KynesAegis_Vrol_FireMage_Meteor_TT       = "Alerts you when Vrolsworn Fire Mages from the boat will cast meteors on players."
L.Settings_KynesAegis_Ichor_Eruption                = "Falgravn: Ichor Eruption"
L.Settings_KynesAegis_Ichor_Eruption_TT             = "Shows countdown until Falgravn will release his Ichor Eruption."
L.Settings_KynesAegis_Ichor_Eruption_CD_Time        = "       - Countdown time"
L.Settings_KynesAegis_Ichor_Eruption_CD_Time_TT     = "Time before Ichor Eruption when countdown should pop up."

-- Alerts
L.Alerts_KynesAegis_Crashing_Wall                   = "|cd2a100Onda Schiacciante|r in"
L.Alerts_KynesAegis_Sanguine_Prison_Other           = "|cff0000<<!aC:1>>|r è intrappolato nella |cb00000Prigione Sanguinaria|r. Liberalo!"
L.Alerts_KynesAegis_Blood_Fountain                  = "|cb00000Fontana del Sangue|r in"
L.Alerts_KynesAegis_Dragon_Totem                    = "2 |cffa500Totem del Drago|r sono apparsi. Evita il fuoco!"
L.Alerts_KynesAegis_Harpy_Totem                     = "Il |c00bfffTotem dell'Arpia|r è apparso."
L.Alerts_KynesAegis_Gargoyle_Totem                  = "Il |cf5f5dcTotem del Gargoyle|r è apparso."
L.Alerts_KynesAegis_Chaurus_Totem                   = "Il |c39942eTotem del Chaurus|r è apparso. Non accumularlo!"
L.Alerts_KynesAegis_FireMage_Meteor                 = "|cffa500Meteor|r on you in"
L.Alerts_KynesAegis_FireMage_Meteor_Other           = "Meteors in"
L.Alerts_KynesAegis_Ichor_Eruption                  = "|cb00000Ichor Eruption|r in"


--------------------------------
------   ROCKGROVE         -----
--------------------------------
L.Settings_Rockgrove_Header                        = "Rockgrove"
-- Settings
L.Settings_Rockgrove_Sundering_Strike              = "General: Sundering Strike"
L.Settings_Rockgrove_Sundering_Strike_TT           = "Alerts you when the Sul-Xan Reaper makes Sundering Strike attack. Roll dodge it."
L.Settings_Rockgrove_Astral_Shield                 = "General: Astral Shield"
L.Settings_Rockgrove_Astral_Shield_TT              = "Alerts you when the Sul-Xan Soulweaver casts his Astral Shield."
L.Settings_Rockgrove_Soul_Remnant                  = "General: Soul Remnant (Soulweaver)"
L.Settings_Rockgrove_Soul_Remnant_TT               = "Alerts you when Soul Remnants targets you (as result of breaking Sul-Xan Soulweaver's Astral Shield)."
L.Settings_Rockgrove_Prime_Meteor                  = "General: Prime Meteor"
L.Settings_Rockgrove_Prime_Meteor_TT               = "Shows countdown when meteor appears indicating the time before it explodes. Make sure to kill the meteor in time."
L.Settings_Rockgrove_Hasted_Assault                = "General: Hasted Assault"
L.Settings_Rockgrove_Hasted_Assault_TT             = "Alerts you when the Havocrel Barbarian makes Hasted Assault attack. He teleports from player to player in random order and attacks them. This should be blocked."
L.Settings_Rockgrove_Savage_Blitz                  = "Oaxiltso: Savage Blitz"
L.Settings_Rockgrove_Savage_Blitz_TT               = "Alerts you when the Oaxiltso charges at the furthest player."
L.Settings_Rockgrove_Noxious_Sludge                = "Oaxiltso: Noxious Sludge"
L.Settings_Rockgrove_Noxious_Sludge_TT             = "Alerts you when someone is poisoned by Oaxiltso and has to go cleanse in the pool."
L.Settings_Rockgrove_Cinder_Cleave                 = "Oaxiltso's mini-boss: Cinder Cleave"
L.Settings_Rockgrove_Cinder_Cleave_TT              = "Alerts you when Havocrel Annihilator casts his Cinder Cleave ability on someone during the fight with Oaxiltso."
L.Settings_Rockgrove_Embrace_Of_Death              = "Flame-Herald Bahsei: Embrace of Death"
L.Settings_Rockgrove_Embrace_Of_Death_TT           = "Alerts you when someone got cursed by Flame-Herald Bahsei. That person will explode after 8 seconds, spreading the curse. It's important to keep cursed player separated from the group."
L.Settings_Rockgrove_Embrace_Of_Death_TT_All       = "|cFF0000WARNING!|r If your group will get too much curses your screen may be fully covered in countdowns for a duration of those curses! We're working on ways to improve this notification."
L.Settings_Rockgrove_Bahsei_Cone_Direction         = "Flame-Herald Bahsei HM: Cone direction"
L.Settings_Rockgrove_Bahsei_Cone_Direction_TT      = "Alerts you of the cone direction if the portal opened."
L.Settings_Rockgrove_Bahsei_Portal_Number          = "Flame-Herald Bahsei HM: Portal number (beta)"
L.Settings_Rockgrove_Bahsei_Portal_Number_TT       = "Tells you the number of portal being opened."
L.Settings_Rockgrove_Xalvakka_Unstable_Charge      = "Xalvakka HM: Unstable charge (staying on blob)"
L.Settings_Rockgrove_Xalvakka_Unstable_Charge_TT   = "Alerts you when you're staying on blob. It's not healthy!"

-- Alerts
L.Alerts_Rockgrove_Sundering_Strike                = "Incoming |cCDCDCDSundering Strike|r on you!"
L.Alerts_Rockgrove_Sundering_Strike_Other          = "Incoming |cCDCDCDSundering Strike|r on |cFF0000<<!aC:1>>|r!"
L.Alerts_Rockgrove_Astral_Shield_Cast              = "|cFFFF8FAstral Shield|r has been casted. Prepare to dodge or block!"
L.Alerts_Rockgrove_Soul_Remnant                    = "Incoming |c8FF2FFSoul Remnant|r!"
L.Alerts_Rockgrove_Prime_Meteor                    = "|cFFD600Prime Meteor|r will explode in"
L.Alerts_Rockgrove_Hasted_Assault                  = "Incoming |cFF0000Hasted Assault|r! Block!"
L.Alerts_Rockgrove_Savage_Blitz                    = "Oaxiltso charges at |cFF0000<<!aC:1>>|r!"
L.Alerts_Rockgrove_Noxious_Sludge_Self             = "You're poisoned by |c008C22Noxious Sludge|r! Cleanse in the pool!"
L.Alerts_Rockgrove_Noxious_Sludge_Other1           = "|cFF0000<<!aC:1>>|r is poisoned by |c008C22Noxious Sludge|r."
L.Alerts_Rockgrove_Noxious_Sludge_Other2           = "|cFF0000<<!aC:1>>|r and |cFF0000<<!aC:2>>|r are poisoned by |c008C22Noxious Sludge|r."
L.Alerts_Rockgrove_Cinder_Cleave                   = "|cD74700Cinder Cleave|r on you!"
L.Alerts_Rockgrove_Cinder_Cleave_Other             = "|cD74700Cinder Cleave|r on |cFF0000<<!aC:1>>|r."
L.Alerts_Rockgrove_Embrace_Of_Death                = "You're cursed by |c0A929BEmbrace of Death|r! Stay away! Explosion in"
L.Alerts_Rockgrove_Embrace_Of_Death_Other          = "|cFF0000<<!aC:1>>|r cursed by |c0A929BEmbrace of Death|r! Explosion in"
L.Alerts_Rockgrove_Bahsei_Cone_Direction_Clockwise = "-> Move |cF48020clockwise|r ->"
L.Alerts_Rockgrove_Bahsei_Cone_Direction_CounterCW = "<- Move |c15FFC2counterclockwise|r <-"
L.Alerts_Rockgrove_Bahsei_Portal_Number            = "Portal #<<1>>"
L.Alerts_Rockgrove_Xalvakka_Unstable_Charge        = "Move away from |c008C22blob|r!"


--------------------------------
------   DREADSAIL REEF    -----
--------------------------------
L.Settings_DreadsailReef_Header                    = "Dreadsail Reef"
-- Settings
L.Settings_DreadsailReef_Dome_Type                 = "Lylanar & Turlassil: Fire/Ice Dome filter"
L.Settings_DreadsailReef_Dome_Type_TT              = "You can restrict notifications to some specific Dome."
L.Settings_DreadsailReef_Dome_Activation           = "Lylanar & Turlassil: Fire/Ice Dome activation"
L.Settings_DreadsailReef_Dome_Activation_TT        = "Alerts you when someone gets Fire or Ice Dome."
L.Settings_DreadsailReef_Dome_Stack_Alert          = "Lylanar & Turlassil: Fire/Ice Dome stacks alert"
L.Settings_DreadsailReef_Dome_Stack_Alert_TT       = "Alerts you when someone gets too many stacks from Fire or Ice Dome."
L.Settings_DreadsailReef_Dome_Stack_Threshold      = "Lylanar & Turlassil: Fire/Ice Dome stack threshold"
L.Settings_DreadsailReef_Dome_Stack_Threshold_TT   = "Specify how many stacks should be received by the player to fire the alert."
L.Settings_DreadsailReef_Imminent_Debuffs          = "Lylanar & Turlassil: Imminent Blister/Chill"
L.Settings_DreadsailReef_Imminent_Debuffs_TT       = "Alerts you when tank receives Imminent Blister debuff from Lylanar or Imminent Chill debuff from Turlassil. Tanks should swap in 10 seconds."
L.Settings_DreadsailReef_Brothers_Heavy_Attack     = "Lylanar & Turlassil: Heavy attack"
L.Settings_DreadsailReef_Brothers_Heavy_Attack_TT  = "Alerts you when Lylanar or Turlassil makes their heavy attack (Broiling Hew / Stinging Shear)."
L.Settings_DreadsailReef_ReefGuardian_ReefHeart    = "Reef Guardian: Reef Heart spawn"
L.Settings_DreadsailReef_ReefGuardian_ReefHeart_TT = "Alerts you when Reef Heart appears. You have 60 seconds to kill it or it's a group wipe. There can be several Hearts active at the same time."
L.Settings_DreadsailReef_ReefHeart_Result          = "Reef Guardian: Reef Heart success/failure"
L.Settings_DreadsailReef_ReefHeart_Result_TT       = "Alerts you if you have executed Reef Heart or not."
L.Settings_DreadsailReef_Rapid_Deluge              = "Taleria: Rapid Deluge"
L.Settings_DreadsailReef_Rapid_Deluge_TT           = "Alerts you when you or someone got Rapid Deluge debuff. They'll explode in 6 seconds, and the best option to handle the damage is to be swimming at that time."

-- Alerts
L.Alerts_DreadsailReef_Destructive_Ember           = "<<!aC:1>> activated |cFFA500Fire Dome|r!"
L.Alerts_DreadsailReef_Piercing_Hailstone          = "<<!aC:1>> activated |c20C3D0Ice Dome|r!"
L.Alerts_DreadsailReef_Imminent_Blister            = "You're afflicted by |cF27D0CImminent Blister|r! Swap tanks until"
L.Alerts_DreadsailReef_Imminent_Blister_Other      = "|cFF0000<<!aC:1>>|r afflicted by |cF27D0CImminent Blister|r! Swap tanks until"
L.Alerts_DreadsailReef_Imminent_Chill              = "You're afflicted by |cB4CFFAImminent Chill|r! Swap tanks until"
L.Alerts_DreadsailReef_Imminent_Chill_Other        = "|cFF0000<<!aC:1>>|r afflicted by |cB4CFFAImminent Chill|r! Swap tanks until"
L.Alerts_DreadsailReef_Broiling_Hew                = "Incoming |cCDCDCDBroiling Hew|r on you!"
L.Alerts_DreadsailReef_Broiling_Hew_Other          = "Incoming |cCDCDCDBroiling Hew|r on |cFF0000<<!aC:1>>|r!"
L.Alerts_DreadsailReef_Stinging_Shear              = "Incoming |cCDCDCDStinging Shear|r on you!"
L.Alerts_DreadsailReef_Stinging_Shear_Other        = "Incoming |cCDCDCDStinging Shear|r on |cFF0000<<!aC:1>>|r!"
L.Alerts_DreadsailReef_Fire_Dome_Stack_Alert       = "You have |cFF0000<<1>>|r stacks from |cFFA500Fire Dome|r!"
L.Alerts_DreadsailReef_Fire_Dome_Stack_Alert_Other = "<<!aC:1>> have |cFF0000<<2>>|r stacks from |cFFA500Fire Dome|r!"
L.Alerts_DreadsailReef_Ice_Dome_Stack_Alert        = "You have |cFF0000<<1>>|r stacks from |c20C3D0Ice Dome|r!"
L.Alerts_DreadsailReef_Ice_Dome_Stack_Alert_Other  = "<<!aC:1>> have |cFF0000<<2>>|r stacks from |c20C3D0Ice Dome|r!"
L.Alerts_DreadsailReef_ReefGuardian_ReefHeart      = "Reef Heart #|cFF0000<<1>>|r spawned!"
L.Alerts_DreadsailReef_ReefHeart_Success           = "Reef Heart #|cFF0000<<1>>|r |c7CFC00destroyed|r!"
L.Alerts_DreadsailReef_ReefHeart_Success_Unknown   = "Reef Heart |c7CFC00destroyed|r!"
L.Alerts_DreadsailReef_ReefHeart_Failure           = "Reef Heart #|cFF0000<<1>>|r |cFF0000empowered|r. You're doomed!"
L.Alerts_DreadsailReef_ReefHeart_Failure_Unknown   = "Reef Heart |cFF0000empowered|r. You're doomed!"
L.Alerts_DreadsailReef_Rapid_Deluge                = "You got |c1CA3ECRapid Deluge|r! You should be swimming in"
L.Alerts_DreadsailReef_Rapid_Deluge_Other          = "|cFF0000<<!aC:1>>|r got |c1CA3ECRapid Deluge|r! Swim in"


--------------------------------
------   SANITY'S EDGE     -----
--------------------------------
L.Settings_SanityEdge_Header                       = "Sanity's Edge"
-- Settings
L.Settings_SanityEdge_Chimera_Sunburst             = "Chimera: Sunburst"
L.Settings_SanityEdge_Chimera_Sunburst_TT          = "Alerts you Chimera casts Sunburst on the group during its Inferno attack. Move away from the boss, and block or dodge it."
L.Settings_SanityEdge_Ansuul_Sunburst              = "Ansuul: Sunburst"
L.Settings_SanityEdge_Ansuul_Sunburst_TT           = "Alerts you when Ansuul casts Sunburst on player. Target player should move away from the group. Keep moving, don't block or dodge it."
L.Settings_SanityEdge_Ansuul_Poisoned_Mind         = "Ansuul: Poisoned Mind"
L.Settings_SanityEdge_Ansuul_Poisoned_Mind_TT      = "Alerts you when Ansuul casts Poisoned Mind. Stay in group. HM: don't stack with other player who has this mechanic."

-- Alerts
L.Alerts_SanityEdge_Chimera_Sunburst               = "|cff9500Meteor|r at you!"
L.Alerts_SanityEdge_Ansuul_Sunburst                = "|c00ddffSunburst|r at you!"
L.Alerts_SanityEdge_Ansuul_Sunburst_Other          = "|c00ddffSunburst|r at <<!aC:1>>|r"
L.Alerts_SanityEdge_Ansuul_Poisoned_Mind           = "|c008C22Poison|r at you!"
L.Alerts_SanityEdge_Ansuul_Poisoned_Mind_Other     = "|c008C22Poison|r at <<!aC:1>>|r"


--------------------------------
----       Debugging        ----
--------------------------------
L.Settings_Debug_Header                  = "Debug"
L.Settings_Debug                         = "Abilita Modalità Debug"
L.Settings_Debug_TT                      = "Mostra i messaggi di debug nella finestra di chat"
L.Settings_Debug_DevMode                 = "Modalità Sviluppatore"
L.Settings_Debug_DevMode_TT              = "Quando viene attivato, vengono mostrati alcuni avvisi non corretti, orari non corrispondenti o non completamente testati. In generale non dovrebbero produrre alcun errore per l'interfaccia, ma si consiglia di utilizzare l'addon 'error catcher'."
L.Settings_Debug_DevMode_Warning         = "Richiede la Modalità Sviluppatore"

L.Settings_Debug_Tracker_Header          = "Tracciamento Debug"
L.Settings_Debug_Tracker_Description     = "Questa è una funzionalità di debug che ha lo scopo di tracciare e visualizzare i potenziali meccanismi durante il corso di un test visualizzando informazioni su eventi ed effetti di combattimento. A causa dell'input potenzialmente enorme, hai alcune opzioni per aiutarti a evitare di inondare la finestra della chat."
L.Settings_Debug_Tracker_Enabled         = "Attivato"
L.Settings_Debug_Tracker_SpamControl     = "Controllo Spam"
L.Settings_Debug_Tracker_SpamControl_TT  = "Con questo, ogni abilità/effetto apparirà solo una volta in base al suo tipo di azione. L'elenco delle abilità conosciute in questa sessione può essere cancellato con il comando \"/rndebug clear\"."
L.Settings_Debug_Tracker_MyEnemyOnly     = "Solo dal Mio Nemico"
L.Settings_Debug_Tracker_MyEnemyOnly_TT  = "Quando attivato, limiterà l'apparizione alle abilità/effetti rivolti al giocatore e NON a quelli che provengono dal giocatore o da qualsiasi membro del gruppo. Utile per quando stai cercando un'azione specifica e non vuoi attivare il controllo dello spam"



--TODO: get rid of this ugly, bulky localization method
for k, v in pairs(L) do
    local string = "RAIDNOTIFIER_" .. string.upper(k)
    ZO_CreateStringId(string, v)
end

function RaidNotifier:GetLocale()
	return L
end
function RaidNotifier:MissingLocale()
	d("Obviously not missing any english strings....")
end

--if (GetCVar('language.2') == 'de') then
--	local MissingL = {}
--	for k, v in pairs(RaidNotifier:GetLocale()) do
--		if (not L[k]) then
--			table.insert(MissingL, k)
--			L[k] = v
--		end
--	end
--	function RaidNotifier:GetLocale()
--		return L
--	end
--	-- for debugging
--	function RaidNotifier:MissingLocale()
--		df("Missing strings for '%s'", GetCVar('language.2'))
--		d(MissingL)
--	end
--end
