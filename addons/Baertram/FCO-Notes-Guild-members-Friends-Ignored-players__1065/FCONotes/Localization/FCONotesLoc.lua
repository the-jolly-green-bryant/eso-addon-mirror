--[[ Umlauts & special characters list
	ä --> \195\164
	Ä --> \195\132
	ö --> \195\182
	Ö --> \195\150
	ü --> \195\188
	Ü --> \195\156
	ß --> \195\159

   à : \195\160    è : \195\168    ì : \195\172    ò : \195\178    ù : \195\185
   á : \195\161    é : \195\169    í : \195\173    ó : \195\179    ú : \195\186
   â : \195\162    ê : \195\170    î : \195\174    ô : \195\180    û : \195\187
      	 		   ë : \195\171    ï : \195\175
   æ : \195\166    ø : \195\184
   ç : \195\167                                    œ : \197\147
   Ä : \195\132    Ö : \195\150    Ü : \195\156    ß : \195\159
   ä : \195\164    ö : \195\182    ü : \195\188
   ã : \195\163    õ : \195\181  				   \195\177 : \195\177
]]
FCONotes.fco_notesloc = {
	--English
    [1] = {
		-- Options menu
        ["options_description"]                  = "Change notes about your guild mates & other options",
		["options_header1"] 			 		 = "General settings",
    	["options_language"] 					 = "Language",
		["options_language_TT"] 			 = "Choose the language",
		["options_language_dropdown_selection1"] = "English",
		["options_language_dropdown_selection2"] = "German",
		["options_language_dropdown_selection3"] = "French",
		["options_language_dropdown_selection4"] = "Spanish",
        ["options_language_dropdown_selection5"] = "Italian",
		["options_language_description1"]		 = "CAUTION: Changing the language/save option will reload the user interface!",
        ["options_reloadui"]					 = "CAUTION: Changing this option will reload the user interface!",
        ["options_savedvariables"]				 = "Save settings",
        ["options_savedvariables_TT"]       = "Save the addon settings for all your characters of your account, or single for each character",
        ["options_savedVariables_dropdown_selection1"] = "Each character",
        ["options_savedVariables_dropdown_selection2"] = "Account wide",
		["options_header_options"]				 = "Options",
        ["options_header_color"]				 = "Colors & icons",
        ["options_icon1_color"]					 = "Color",
        ["options_icon1_color_TT"]			 = "Color for the note icon",
        ["options_icon1_texture"]				 = "Icon for the guild roster",
        ["options_icon1_texture_TT"]		 = "Icon for the guild roster note",
        ["options_icon1_size"]				 	 = "Size",
        ["options_icon1_size_TT"]			 = "Size of the icon for the note",
        ["options_icon1_x"]                      = "Offset left",
        ["options_icon1_x_TT"]              = "Offset of the icon from the left border of the recent guild roster member row",
        ["options_icon1_y"]                      = "Offset top",
        ["options_icon1_y_TT"]              = "Offset of the icon from the top border of the recent guild roster member row",
        ["options_icon2_texture"]				 = "Friends list icon",
        ["options_icon2_texture_TT"]		 = "Icon for the friends list note",
        ["options_icon3_texture"]				 = "Icon for the ignore list",
        ["options_icon3_texture_TT"]		 = "Icon for the ignore list note",
        ["options_note_guild_options"]			 = "Personal guild note options",
        ["options_save_guild_notes_account_wide"] = "Save by account name",
        ["options_save_guild_notes_account_wide_TT"] = "Save the personal guild note for the account name, and not for each different guild",
        ["options_header_guild_roster"]         = "Guild roster options",
        ["options_enable_notes_guild_roster"]	 = "Enable notes: Guild roster",
        ["options_enable_notes_guild_roster_TT"] = "Enable the personal notes at the guild rosters",
        ["options_always_open_guild_roster"]    = "Always open guild roster first",
        ["options_always_open_guild_roster_TT"] = "Will always open the guild roster at first, instead of the guild home, if you press the keybind or click the menu's icon",
        ["options_header_friend_list"]           = "Friends list options",
        ["options_enable_notes_friends_list"]	 = "Enable notes: Friends list",
        ["options_enable_notes_friends_list_TT"] = "Enable the personal notes at the friends list",
        ["options_enable_notes_ignore_list"]	 = "Enable notes: Ignore list",
        ["options_enable_notes_ignore_list_TT"] = "Enable the personal notes at the ignore list",
        ["options_header_friends_list"] = "Friends list",
        ["options_header_ignore_list"] = "Ignore list",

        ["chat_pre_guild_officer"] = "FCO Note about",
        --Chat commands
        ["chatcommands_info"]					 = "|c00FF00FCO|r|cFFFF00Notes|r|cFFFFFF - Change notes about your guild mates & other options|r",
        ["chatcommands_help"]					 = "'help' / 'list': Shows this information about the addon",
        ["chatcommands_backup"]			         = "'backup': Backup all personal notes.\n'backupguilds': Backup the current saved personal guild member notes.\n'backupfriends': Backup the current saved personal friends list notes.\n'backupignore': Backup the current saved personal ignore list notes.\n|cFF0000ATTENTION:|r Will reload the UI after 3 seconds!",
        ["chatcommands_restore"]			     = "'restore': Restore all personal notes.\n'restoreguilds': Restore the current saved personal guild member notes.\n'restorefriends': Restore the current saved personal friends list notes.\n'restoreignore': Restore the current saved personal ignore list notes.\n|cFF0000ATTENTION:|r Will reload the UI!",
        ["chatcommands_backup_feedback_true"]    = "|c00FF00FCO|r|cFFFF00Notes|r - Backup has been created - Reloding UI in 3 seconds",
        ["chatcommands_backup_feedback_false"]   = "|cFF0000FCO|r|cFFFF00Notes|r - Backup could not be created!",
        --Context menu
        ["context_menu_add_personal_guild_note"] = "|c22DD22FCO Notes|r Change personal note",
        ["context_menu_remove_personal_guild_note"] = "|cDD2222FCO Notes|r Delete personal note",
        ["context_menu_send_personal_guild_note_to_officer_chat"] = "|c0000DDFCO Notes|r Send to officer chat",
		--Keybindings
		["SI_BINDING_NAME_FCO_NOTES_ADD"]		= "Change note",
    },

	--German / Deutsch
    [2] = {
		-- Options menu
        ["options_description"]                  = "Verfasse Hinweis Texte zu deinen Gilden Mitgliedern & andere Optionen",
		["options_header1"] 			 		 = "Generelle Einstellungen",
    	["options_language"] 					 = "Sprache",
		["options_language_TT"] 			 = "Wählen Sie die Sprache aus.",
		["options_language_dropdown_selection1"] = "Englisch",
		["options_language_dropdown_selection2"] = "Deutsch",
		["options_language_dropdown_selection3"] = "Französisch",
		["options_language_dropdown_selection4"] = "Spanisch",
        ["options_language_dropdown_selection5"] = "Italienisch",
		["options_language_description1"]		 = "ACHTUNG: Veränderungen der Sprache/der Speicherart laden die Benutzeroberfläche neu!",
        ["options_reloadui"]					 = "ACHTUNG: Veränderung dieser Option wird die Benutzeroberfläche neu laden!",
        ["options_savedvariables"]				 = "Einstellungen speichern",
        ["options_savedvariables_TT"]       = "Die Einstellungen dieses Addons werden für alle Charactere Ihres Accounts, oder für jeden Character einzeln gespeichert.",
        ["options_savedVariables_dropdown_selection1"] = "Jeder Charakter",
        ["options_savedVariables_dropdown_selection2"] = "Ganzer Account",
		["options_header_options"]				 = "Optionen",
        ["options_header_color"]				 = "Farben & Symbole",
        ["options_icon1_color"]					 = "Farbe",
        ["options_icon1_color_TT"]			 = "Farbe für das Symbol der Notiz",
        ["options_icon1_texture"]				 = "Symbol für Gilden Mitglieder",
        ["options_icon1_texture_TT"]		 = "Symbol für die Gilden Mitglieder Notiz",
        ["options_icon1_size"]				 	 = "Größe",
        ["options_icon1_size_TT"]			 = "Größe des Symboles für die Notiz",
        ["options_icon1_x"]                      = "Position von Links",
        ["options_icon1_x_TT"]              = "Die Position des Symbols vom linken Rand der Gildenmitglied Zeile entfernt (Standard Wert: xxx)",
        ["options_icon1_y"]                      = "Position von Oben",
        ["options_icon1_y_TT"]              = "Die Position des Symbols vom oberen Rand Gildenmitglied Zeile aus gesehen (Standrd Wert: 0)",
        ["options_icon2_texture"]				 = "Symbol für die Freundesliste",
        ["options_icon2_texture_TT"]		 = "Symbol für die Freundeslisten Notiz",
        ["options_icon3_texture"]				 = "Symbol für die Ignorierenliste",
        ["options_icon3_texture_TT"]		 = "Symbol für die Ignorierenliste Notiz",
        ["options_note_guild_options"]			 = "Persönliche Gildennotiz Optionen",
        ["options_save_guild_notes_account_wide"] = "Speichere pro Accountname",
        ["options_save_guild_notes_account_wide_TT"] = "Speichert die persönliche Gildennotiz zum Accountnamen, und nicht unterschiedlich je Gilde",
        ["options_header_guild_roster"]         = "Gilden Mitglieder Optionen",
        ["options_enable_notes_guild_roster"]	 = "Aktiviere Notizen: Gilden Mitglieder",
        ["options_enable_notes_guild_roster_TT"] = "Aktiviere die persönlichen Notizen auf der Gilden Mitglieder Liste",
        ["options_always_open_guild_roster"]    = "Immer Gilden Mitglieder zuerst öffnen",
        ["options_always_open_guild_roster_TT"] = "Es werden immer die Gildenmitglieder zuerst aufgerufen, anstelle der Gilden Übersicht, wenn man die Tastenkombination für die Gilde drückt, oder im Menü auf das Symbol klickt.",
        ["options_header_friend_list"]           = "Freundesliste Optionen",
        ["options_enable_notes_friends_list"]	 = "Aktiviere Notizen: Freundesliste",
        ["options_enable_notes_friends_list_TT"] = "Aktiviere die persönlichen Notizen auf der Freundesliste",
        ["options_enable_notes_ignore_list"]	 = "Aktiviere Notizen: Ignorierenliste",
        ["options_enable_notes_ignore_list_TT"] = "Aktiviere die persönlichen Notizen auf der Ignorierenliste",
        ["options_header_friends_list"] = "Freundesliste",
        ["options_header_ignore_list"] = "Ignorierte Liste",

        ["chat_pre_guild_officer"] = "FCO Notiz über",
        --Chat commands
        ["chatcommands_info"]					 = "|c00FF00FCO|r|cFFFF00Notes|cFFFFFF - Verfasse Hinweis Texte zu deinen Gilden Mitgliedern & andere Optionen",
        ["chatcommands_help"]					 = "'help' / 'list': Zeige diese Informationen über das Addon",
        ["chatcommands_backup"]			         = "'backup': Speichert all aktuellen persönlichen Notizen für ein Backup ab.\n'backupguilds': Speichert die aktuellen persönlichen Gildenmitglieder Notizen für ein Backup ab.\n'backupfriends': Speichert die aktuellen persönlichen Freundesliste Notizen für ein Backup ab.\n'backupignore': Speichert die aktuellen persönlichen Ignorierenliste Notizen für ein Backup ab.\n|cFF0000ACHTUNG:|r Es wird die Benutzeroberfläche nach 3 Sekunden neu geladen!",
        ["chatcommands_restore"]			     = "'restore': Stellt alle persönlichen Notizen aus einem Backup wieder her.\n'restoreguilds': Stellt die persönlichen Gildenmitglieder Notizen aus einem Backup wieder her.\n'restorefriends': Stellt die persönlichen Freundesliste Notizen aus einem Backup wieder her.\n'restoreignore': Stellt die persönlichen Ignorierenliste Notizen aus einem Backup wieder her.\n|cFF0000ACHTUNG:|r Es wird die Benutzeroberfläche nach 3 Sekunden neu geladen!",
        ["chatcommands_backup_feedback_true"]    = "|c00FF00FCO|r|cFFFF00Notes|r - Backup wurde erstellt - Benutzeroberfläche lädt neu in 3 Sekunden",
        ["chatcommands_backup_feedback_false"]   = "|cFF0000FCO|r|cFFFF00Notes|r - Backup konnte nicht erstellt werden!",
        --Context menu
        ["context_menu_add_personal_guild_note"] = "|c22DD22FCO Notes|r Ändere persönliche Notiz",
        ["context_menu_remove_personal_guild_note"] = "|cDD2222FCO Notes|r Lösche persönliche Notiz",
        ["context_menu_send_personal_guild_note_to_officer_chat"] = "|c0000DDFCO Notes|r An Offizierschat senden",
		--Keybindings
		["SI_BINDING_NAME_FCO_NOTES_ADD"]		= "Hinweis ändern",

    },

    --French / Französisch
	[3] = {
		-- Options menu
        ["options_description"] = "Change notes about your guild mates & other options",
		["options_header1"] = "General",
		["options_language"] = "Langue",
		["options_language_TT"] = "Choisir le langue",
		["options_language_dropdown_selection1"] = "Anglais",
		["options_language_dropdown_selection2"] = "Allemand",
		["options_language_dropdown_selection3"] = "Francais",
		["options_language_dropdown_selection4"] = "Espagnol",
        ["options_language_dropdown_selection5"] = "Italien",
		["options_language_description1"]	 = "ATTENTION: Modifier un de ces réglages provoquera un chargement.",
        ["options_reloadui"]				 = "ATTENTION: Modifier ce réglage provoquera un chargement.",
		["options_savedvariables"]	 = "Sauvegarder",
		["options_savedvariables_TT"] = "Sauvegarder les données de l'addon pour tous les personages du compte, ou individuellement pour chaque personnages",
		["options_savedVariables_dropdown_selection1"] = "Individuellement",
		["options_savedVariables_dropdown_selection2"] = "Compte",
		["options_header_options"]				 = "Options",
        ["options_header_color"]						 = "Couleur & icône",
        ["options_icon1_color"]							 = "Couleur",
        ["options_icon1_color_TT"]					 = "Couleur de l'icône pour la note",
        ["options_icon1_texture"]				 = "Icône",
        ["options_icon1_texture_TT"]		 = "Icône pour la note",
        ["options_icon1_size"]				 	 = "Taille",
        ["options_icon1_size_TT"]			 = "Taille de l'icône pour la note",

        --Chat commands
        --Context menu
        --Keybindings
	},

--Spanish / Español
	[4] = {
		-- Options menu
        ["options_description"] = "Change notes about your guild mates & other options",
		["options_header1"] = "General",
		["options_language"] = "Idioma",
		["options_language_TT"] = "Elegir idioma",
		["options_language_dropdown_selection1"] = "Inglés",
		["options_language_dropdown_selection2"] = "Alemán",
		["options_language_dropdown_selection3"] = "Francés",
		["options_language_dropdown_selection4"] = "Espa\195\177ol",
        ["options_language_dropdown_selection5"] = "Italiano",
		["options_language_description1"]	 = "CUIDADO: Modificar uno de estos parámetros recargará la interfaz.",
		["options_reloadui"]	 			 = "CUIDADO: Modificar esto parámetro recargará la interfaz.",
		["options_savedvariables"]	 = "Guardar",
		["options_savedvariables_TT"] = "Guardar los parámetros del addon para todos los personajes de la cuenta o individualmente para cada personaje",
		["options_savedVariables_dropdown_selection1"] = "Individualmente",
		["options_savedVariables_dropdown_selection2"] = "Cuenta",
		["options_header_options"]				 = "Opciones",
        ["options_header_color"]						 = "Color e icono",
        ["options_icon1_color"]							 = "Color",
        ["options_icon1_color_TT"]					 = "Color del icono para el nota",
        ["options_icon1_texture"]				 = "Icono",
        ["options_icon1_texture_TT"]		 = "Icono para el nota",
        ["options_icon1_size"]				 	 = "Tama\195\177o",
        ["options_icon1_size_TT"]			 = "Tama\195\177o del icono para el nota",

        --Chat commands
        --Context menu
		--Keybindings
	},

    --Italian / Italiano
    [5] = {
        -- Options menu
        ["options_description"]                  = "Cambia note circa i vostri compagni di gilda & other options",
        ["options_header1"] 			 		 = "Impostazioni generali",
        ["options_language"] 					 = "Lingua",
        ["options_language_TT"] 			 = "Scegli la lingua",
        ["options_language_dropdown_selection1"] = "Inglese",
        ["options_language_dropdown_selection2"] = "Germano",
        ["options_language_dropdown_selection3"] = "Francese",
        ["options_language_dropdown_selection4"] = "Spagnolo",
        ["options_language_dropdown_selection5"] = "Italiano",
        ["options_language_description1"]		 = "ATTENZIONE: modifica della lingua opzione / salvare ricaricherà l'interfaccia utente!",
        ["options_reloadui"]					 = "ATTENZIONE: La modifica di questa opzione ricaricherà l'interfaccia utente!",
        ["options_savedvariables"]				 = "Salvare le impostazioni",
        ["options_savedvariables_TT"]       = "Salvare le impostazioni addon per tutti i tuoi personaggi del tuo account, o unico per ogni carattere",
        ["options_savedVariables_dropdown_selection1"] = "Ogni personaggio",
        ["options_savedVariables_dropdown_selection2"] = "Tutto acconto",
        ["options_header_options"]				 = "Opzioni",
        ["options_header_color"]				 = "Colori & icone",
        ["options_icon1_color"]					 = "Colori",
        ["options_icon1_color_TT"]			 = "Colore per l'icona della nota",
        ["options_icon1_texture"]				 = "Icona",
        ["options_icon1_texture_TT"]		 = "L'icona della nota",
        ["options_icon1_size"]				 	 = "Dimensione",
        ["options_icon1_size_TT"]			 = "Dimensioni dell'icona per la nota",
        ["options_icon1_x"]                      = "Offset di sinistra",
        ["options_icon1_x_TT"]              = "Offset dell'icona dal bordo sinistro della riga recente membro roster della gilda",
        ["options_icon1_y"]                      = "Offset dall'alto",
        ["options_icon1_y_TT"]              = "Offset of the icon from the top border of the recent guild roster member row",
        ["options_note_guild_options"]			 = "Opzioni di nota gilda personale",
        ["options_save_guild_notes_account_wide"] = "Risparmia il nome di acconto",
        ["options_save_guild_notes_account_wide_TT"] = "Salvare la nota gilda personale per il nome di account, e non per ogni differente gilda",
        ["options_header_guild_roster"]         = "Guild roster options",
        ["options_always_open_guild_roster"]    = "Always open guild roster first",

        --Chat commands
        ["chatcommands_info"]					 = "|c00FF00FCO|r|cFFFF00Notes|r|cFFFFFF - Cambia note circa i vostri compagni di gilda & other options|r",
        ["chatcommands_help"]					 = "'help' / 'list': Mostra questa informazioni su l'addon",
        --Context menu
        ["context_menu_add_personal_guild_note"] = "|c22DD22FCO Notes|r Cambiare nota personale",
        ["context_menu_remove_personal_guild_note"] = "|cDD2222FCO Notes|r Eliminare nota personale",
        ["context_menu_send_personal_guild_note_to_officer_chat"] = "|c0000DDFCO Notes|r Send to officer chat",
        --Keybindings
        ["SI_BINDING_NAME_FCO_NOTES_ADD"]		= "Cambiare nota personale",
    },

}
local fco_notesloc = FCONotes.fco_notesloc

--Meta table trick to use english localization for german, french and spanish values, which are missing
setmetatable(fco_notesloc[2], {__index = fco_notesloc[1]})
setmetatable(fco_notesloc[3], {__index = fco_notesloc[1]})
setmetatable(fco_notesloc[4], {__index = fco_notesloc[1]})
setmetatable(fco_notesloc[5], {__index = fco_notesloc[1]})
