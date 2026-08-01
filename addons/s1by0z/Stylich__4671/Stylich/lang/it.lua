local STLLang = Stylich.Lang
STLLang.msg = STLLang.msg or {}
local m = STLLang.msg

-- Categorie di aspetto
m.CATEGORY_TYPE_COSTUME = 'Costume'
m.CATEGORY_TYPE_POLYMORPH = 'Polimorfismo'
m.CATEGORY_TYPE_SKIN = 'Aspetto'
m.CATEGORY_TYPE_PERSONALITY = 'Personalità'
m.CATEGORY_TYPE_HAT = 'Cappello'
m.CATEGORY_TYPE_HAIR = 'Acconciatura'
m.CATEGORY_TYPE_FACIAL_HAIR_HORNS = 'Barba'
m.CATEGORY_TYPE_FACIAL_ACCESSORY = 'Ornamenti grandi'
m.CATEGORY_TYPE_PIERCING_JEWELRY = 'Ornamenti piccoli'
m.CATEGORY_TYPE_HEAD_MARKING = 'Segno facciale'
m.CATEGORY_TYPE_BODY_MARKING = 'Segno corporeo'
m.CATEGORY_TYPE_VANITY_PET = 'Cucciolo'
m.CATEGORY_TYPE_MOUNT = 'Cavalcatura'
m.GEAR_APPEARANCE = 'Aspetto (arma)'

-- Etichette
m.STYLE = 'Stile'
m.OUTFIT = 'Tenuta'
m.TITLE = 'Titolo'
m.HOTKEY = 'Scorciatoia'
m.MEMENTO = 'Memento'
m.REVEAL = 'Ritardo'
m.COMPANION = 'Compagno'
m.COMPANION_NONE = '- Nessuno -'
m.COMPANION_KEEP = '- Non toccare -'
m.WEAPONS = 'Armi'
m.APPLY_SECTION = "ALL'APPLICAZIONE"
m.OPTIONS = 'Opzioni'

-- Elenchi a discesa
m.SLOT = 'Slot'
m.HOTKEY_NONE = '- Nessuno -'
m.MEMENTO_NONE = '- Nessuno -'
m.NO_OUTFIT = '- Nessuna tenuta -'
m.NO_TITLE = '- Nessun titolo -'
m.WEAPON_UNEQUIP = 'Slot vuoto (verrà rimossa)'
m.WEAPON_NONE = "Mantieni l'arma attuale (questo slot non viene modificato)"

-- Opzioni
m.OPT_SHOW_BUTTON = 'Mostra il pulsante mobile'
m.OPT_SHOW_DROPDOWN = "Mostra l'elenco di cambio rapido"
m.OPT_LOCK_BUTTON = 'Blocca la posizione del pulsante mobile'
m.OPT_PLAY_MEMENTOS = "Riproduci il memento d'ingresso quando applichi uno stile"
m.OPT_HIDE_ON_MENUS = "Nascondi Stylich quando un menu è aperto"
m.OPT_CLOSE_COMBAT = "Chiudi la finestra quando entri in combattimento"
m.OPT_HELP =
	"|cFFAA33Creare uno stile|r\n"..
	"- Componi il tuo aspetto nel gioco, poi premi Aggiorna per salvarlo.\n"..
	"- Oppure trascina un'arma dall'inventario su uno slot armi.\n"..
	"- Clic destro su uno slot armi per alternare: vuoto (rimuovi) o mantieni (lascia la tua arma).\n"..
	"- Scegli una Tenuta, un Titolo e un Memento d'ingresso dagli elenchi.\n\n"..
	"|cFFAA33Memento d'ingresso|r\n"..
	"Quando applichi uno stile, il suo memento si attiva per mascherare il cambiamento: il nuovo aspetto si rivela al termine dell'animazione. Se il memento è ancora in ricarica, lo stile non cambia (così la rivelazione avviene sempre)."

-- Finestre di conferma
m.CONFIRM_UPDATE_TITLE = 'Aggiorna stile'
m.CONFIRM_UPDATE_TEXT = "Sovrascrivere «<<1>>» con il tuo aspetto attuale?"
m.CONFIRM_DELETE_TITLE = 'Elimina stile'
m.CONFIRM_DELETE_TEXT = "Eliminare lo stile «<<1>>»?"

-- Descrizioni comandi
m.TT_NEW = 'Nuovo stile'
m.TT_RENAME = 'Rinomina / proprietà'
m.TT_UPDATE = "Aggiorna dall'aspetto attuale"
m.TT_APPLY = 'Applica stile'
m.TT_DELETE = 'Elimina stile'
m.TT_OPTIONS = 'Opzioni'
m.TT_REVEAL = "Ritardo prima che il tuo nuovo aspetto appaia sotto il memento d'ingresso. Più corto = rivelazione più rapida; più lungo maschera il cambiamento più a lungo. Regolalo sulla durata del tuo memento."

-- Scorciatoie da tastiera
m.BIND_SHOW = 'Apri/chiudi la finestra'
m.BIND_SLOT = 'Applica lo stile dello slot'

-- Messaggi in chat
m.MSG_NO_STYLE_SLOT = "Stylich: nessuno stile assegnato allo slot <<1>>."
m.MSG_CREATED = "Stylich: «<<1>>» creato."
m.MSG_MEMENTO_COOLDOWN = "Stylich: memento d'ingresso non pronto (<<1>>s) - stile non applicato."
m.MSG_WEAPON_NOT_FOUND = "Stylich: arma non trovata: <<1>>."
m.MSG_WEAPON_DUP = "Stylich: quest'arma è già assegnata a un altro slot."
m.MSG_WEAPON_ONLY = "Stylich: qui si possono rilasciare solo armi."
m.MSG_NO_SPACE = "Stylich: spazio insufficiente nello zaino per rimuovere <<1>>."
m.MSG_COMBAT_WEAPONS = "Stylich: impossibile cambiare armi in combattimento."
