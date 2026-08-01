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
FCOUltimateReminder.localizationVars.localizationAll = {
	--English
    [1] = {
		-- Options menu
	    ["options_description"]                  = "Reminds you to use your ultimate abilities, if equipped and ready.",
		["options_header1"] 			 		 = "General settings",
    	["options_language"] 					 = "Language",
		["options_language_tooltip"] 			 = "Choose the language",
		["options_language_dropdown_selection1"] = "English",
		["options_language_dropdown_selection2"] = "German",
		["options_language_dropdown_selection3"] = "French",
		["options_language_dropdown_selection4"] = "Spanish",
        ["options_language_dropdown_selection5"] = "Italian",
        ["options_language_dropdown_selection6"] = "Japanese",
        ["options_language_dropdown_selection7"] = "Russian",
		["options_language_description1"]		 = "CAUTION: Changing the language/save option will reload the user interface!",
        ["options_reloadui"]					 = "CAUTION: Changing this option will reload the user interface!",
        ["options_savedvariables"]				 = "Save settings",
        ["options_savedvariables_tooltip"]       = "Save the addon settings for all your characters of your account, or single for each character",
        ["options_savedVariables_dropdown_selection1"] = "Each character",
        ["options_savedVariables_dropdown_selection2"] = "Account wide",
		["options_header_options"]				 = "Options",
		["options_text_alert_enabled"]				=	"Show text alert",
		["options_text_alert_enabled_tooltip"]		=	"Show/Hide a text alert if your ultimate ability is ready.\n\nSet your text below!",
		["options_text_alert_ultimate_ability_text"]			=	"Ultimate ready text",
		["options_text_alert_ultimate_ability_text_tooltip"]	=	"Show this text as your ultimate ability is ready",
		["options_icon_alert_enabled"]				=	"Show icon alert",
		["options_icon_alert_enabled_tooltip"]		=	"Show/Hide an icon alert if your ultimate ability is ready.\n\nSet the icon's size, position and symbol below. Use your mouse to drag&drop the icon on the screen!\n\nThe icon will be hidden again if you click it with your right mouse button.",
		["options_alert_only_in_combat"]			=	"Only in combat",
		["options_alert_only_in_combat_tooltip"]	=	"Only show the icon alert if you are in combat",
        ["options_icon_alert_width"]				=	"Icon width",
        ["options_icon_alert_width_tooltip"]		=	"The icons width",
        ["options_icon_alert_height"]				=	"Icon height",
        ["options_icon_alert_height_tooltip"]		=	"The icons height",
        ["options_icon_alert_symbol"]				=	"Icon",
        ["options_icon_alert_symbol_tooltip"]		=	"The icons texture",
        ["options_icon_alert_position_x"]			=	"Icon position x",
        ["options_icon_alert_position_x_tooltip"]	=	"The icons position on the x-axis",
        ["options_icon_alert_position_y"]			=	"Icon position y",
        ["options_icon_alert_position_y_tooltip"]	=	"The icons position on the y-axis",
        ["options_icon_alert_show_value"]           =   "Show value/needed",
        ["options_icon_alert_show_value_tooltip"]   =   "Show your actual ultimate ability value and the needed ultimate ability value to use it",
        ["options_icon_alert_show_percentage"]           =   "Show percentage",
        ["options_icon_alert_show_percentage_tooltip"]   =   "Show the actual percentage of ultimate ability value (100% = Ultimate ability is ready)",
        ["options_icon_alert_blink"]				=	"Blink alert icon",
        ["options_icon_alert_blink_tooltip"]		=	"Should the alert icon blink if the ultimate value to use it was reached?",
        ["options_visible_with_ultimate_full"]          = "Only with full ultimate",
        ["options_visible_with_ultimate_full_tooltip"]  = "Only show the icon if your ultimate value reached the threshold to execute the ultimate ability.",
        ["options_visible_on_weapon_bar"]               = "Only on weapon bar",
        ["options_visible_on_weapon_bar_tooltip"]       = "Only show the icon if you got the following weapon bar activated. 1, 2 or 3 for both bars.",
        ["options_alert_sound"]						=	"Alert sound",
		["options_alert_sound_tooltip"]				=	"To play an ultimate ability ready sound please install the addon 'FCOUltimateSound'.\n\nClick this button to open the addon's description page.",
        ["options_alert_chat_output"]	            =	"Output results to chat",
        ["options_alert_chat_output_tooltip"]	    =	"Output the results of the ultimate ability ready check to the chat?",
        ["options_alert_test"]						=	"Test alert",
        ["options_alert_test_tooltip"]				=	"Test your chosen alert text and/or icon settings.",
		["options_header_text_alert"]				=	"Text alert",
		["options_header_icon_alert"]				=	"Icon alert",
		["options_header_sound_alert"]				=	"Sound alert",
        ["icon_tooltip_text_ready"]					=	"Your ultimate skill is ready!",
		["icon_tooltip_text_not_ready"]				=	"Your ultimate skill is not ready",
        ["debugMode_false"]							=	"Debug mode: |cDD2222deactivated|r",
        ["debugMode_true"]							=	"Debug mode: |c22DD22activated|r",
    },

	--German / Deutsch
    [2] = {
		-- Options menu
        ["options_description"]                  = "Erinnert dich daran deine Ultimate Fertigkeitne zu nutzen, wenn diese ausgerüstet und bereit sind",
		["options_header1"] 			 		 = "Generelle Einstellungen",
    	["options_language"] 					 = "Sprache",
		["options_language_tooltip"] 			 = "Wählen Sie die Sprache aus.",
		["options_language_use_client"] 		 = "Benutze Spiel Sprache",
		["options_language_use_client_tooltip"]  = "Lässt das AddOn immer die Sprache des Spiel Clients nutzen.",
		["options_language_dropdown_selection1"] = "Englisch",
		["options_language_dropdown_selection2"] = "Deutsch",
		["options_language_dropdown_selection3"] = "Französisch",
		["options_language_dropdown_selection4"] = "Spanisch",
        ["options_language_dropdown_selection5"] = "Italienisch",
        ["options_language_dropdown_selection6"] = "Japanisch",
        ["options_language_dropdown_selection7"] = "Russisch",
		["options_language_description1"]		 = "ACHTUNG: Veränderungen der Sprache/der Speicherart laden die Benutzeroberfläche neu!",
        ["options_reloadui"]					 = "ACHTUNG: Veränderung dieser Option wird die Benutzeroberfläche neu laden!",
        ["options_savedvariables"]				 = "Einstellungen speichern",
        ["options_savedvariables_tooltip"]       = "Die Einstellungen dieses Addons werden für alle Charactere Ihres Accounts, oder für jeden Character einzeln gespeichert.",
        ["options_savedVariables_dropdown_selection1"] = "Jeder Charakter",
        ["options_savedVariables_dropdown_selection2"] = "Ganzer Account",
		["options_header_options"]				 = "Optionen",
		["options_text_alert_enabled"]				=	"Zeige Text Warnung",
		["options_text_alert_enabled_tooltip"]		=	"Zeigt/Versteckt eine Text Nachricht wenn deine Ultimate Fertigkeit bereit ist.\n\nSetze deinen Text für die Nachricht weiter unten in den Einstellungen!",
		["options_text_alert_ultimate_ability_text"]			=	"Ultimate bereit Text",
		["options_text_alert_ultimate_ability_text_tooltip"]	=	"Zeige diesen Text, wenn deine Ultimate Fertigkeit bereit ist.",
		["options_icon_alert_enabled"]				=	"Zeige Symbol Warnung",
		["options_icon_alert_enabled_tooltip"]		=	"Zeige/Verstecke ein Symbol wenn deine Ultimate Fertigkeiten bereit ist.\n\nLege das zu zeigende Symbol, Größe und Position weiter unten in den Einstellungen fest. Um das Symbol auf der Oberfläche zu bewegen kannst du Drag&Drop nutzen!\n\nDas Symbol verschwindet durch einen Rechtsklick!",
		["options_alert_only_in_combat"]			=	"Nur im Kampf",
		["options_alert_only_in_combat_tooltip"]	=	"Zeigt die Symbol Warnung nur im Kampf an",
        ["options_icon_alert_width"]				=	"Symbol Breite",
        ["options_icon_alert_width_tooltip"]		=	"Die breite des Symbols",
        ["options_icon_alert_height"]				=	"Symbol Höhe",
        ["options_icon_alert_height_tooltip"]		=	"Die Höhe des Symbols",
        ["options_icon_alert_symbol"]				=	"Symbol",
        ["options_icon_alert_symbol_tooltip"]		=	"Die Grafik des Symbols",
        ["options_icon_alert_position_x"]			=	"Symbol Position X",
        ["options_icon_alert_position_x_tooltip"]	=	"Die Position des Symbols auf der X-Achse",
        ["options_icon_alert_position_y"]			=	"Symbol Position Y",
        ["options_icon_alert_position_y_tooltip"]	=	"Die Position des Symbols auf der Y-Achse",
        ["options_icon_alert_show_value"]           =   "Zeige Wert/Benötigt",
        ["options_icon_alert_show_value_tooltip"]   =   "Zeige den aktuell verfügbaren Ultimate Fertigkeit Wert und den benötigten Wert über dem Symbol an",
        ["options_icon_alert_show_percentage"]           =   "Zeige Prozent",
        ["options_icon_alert_show_percentage_tooltip"]   =   "Zeige den Ultimate Fertigkeit Prozentwert im Symbol an (100% = Ultimate Fertigkeit ist bereit)",
        ["options_icon_alert_blink"]				=	"Blinkendes Symbol",
        ["options_icon_alert_blink_tooltip"]		=	"Soll das Symbol blinken, wenn der Ultimate Wert erreicht wurde?",
        ["options_visible_with_ultimate_full"]          = "Nur mit voller Ulti",
        ["options_visible_with_ultimate_full_tooltip"]  = "Zeige das Icon nur dann an, wenn deine Ultimate Fertigkeit voll aufgeladen ist.",
        ["options_visible_on_weapon_bar"]               = "Nur auf Waffenleiste",
        ["options_visible_on_weapon_bar_tooltip"]       = "Zeige das Icon nur auf der folgenden Waffenleiste an. 1, 2, oder 3 für beide Leisten.",
		["options_alert_sound"]						=	"Akkustische Warnung",
		["options_alert_sound_tooltip"]				=	"Um einen Ultimate Fertigkeit Fertig-Sound abzuspielen installieren Sie bitte das AddOn 'FCOUltimateSound'.\n\Mit einem Klick auf diesen Knopf öffnen Sie die AddOn Beschreibung.",
        ["options_alert_chat_output"]	            =	"Ergebnis in den Chat",
        ["options_alert_chat_output_tooltip"]	    =	"Zeige das Ergebnis des Ultimate Fähigkeit Fertig-Checks im Chat?",
        ["options_alert_test"]						=	"Test Warnung",
        ["options_alert_test_tooltip"]				=	"Testst Ihre gewählten Warnungseinstellungen für den Text und/oder das Symbol.",
		["options_header_text_alert"]				=	"Text Warnung",
		["options_header_icon_alert"]				=	"Symbol Warnung",
		["options_header_sound_alert"]				=	"Akkustische Warnung",
		["icon_tooltip_text_ready"]					=	"Deine Ultimate Fertigkeit ist bereit!",
        ["icon_tooltip_text_not_ready"]				=	"Deine Ultimate Fertigkeit ist nicht bereit",
        ["debugMode_false"]							=	"Debug mode: |cDD2222Deaktiviert|r",
        ["debugMode_true"]							=	"Debug mode: |c22DD22Aktiviert|r",
    },

    --French / Französisch
	[3] = {
		-- Options menu
        ["options_description"]                  = "Pour être alerté quand le buff de boisson/nourriture expire",
		["options_header1"] = "Général",
		["options_language"] = "Langue",
		["options_language_tooltip"] = "Choisir la langue",
		["options_language_use_client"] 		 		 = "Utilisez le langage client",
		["options_language_use_client_tooltip"]  		 = "Toujours laisser l'addon utiliser la langue du client de jeu.",
		["options_language_dropdown_selection1"]		 = "Anglais",
		["options_language_dropdown_selection2"]		 = "Allemand",
		["options_language_dropdown_selection3"]		 = "Français",
		["options_language_dropdown_selection4"] 		 = "Espagnol",
        ["options_language_dropdown_selection5"]	 	 = "Italien",
        ["options_language_dropdown_selection6"]         = "Japonais",
        ["options_language_dropdown_selection7"] 		 = "Russe",
		["options_language_description1"]	 = "ATTENTION: Modifier un de ces réglages provoquera un chargement.",
        ["options_reloadui"]				 = "ATTENTION: Modifier ce réglage provoquera un chargement.",
		["options_savedvariables"]	 = "Sauvegarder",
		["options_savedvariables_tooltip"] = "Sauvegarder les données de l'addon pour tous les personnages du compte, ou pour chaque personnage séparément",
		["options_savedVariables_dropdown_selection1"] = "Individuellement",
		["options_savedVariables_dropdown_selection2"] = "Compte",
		["options_header_options"]				 	= 	"Options",

	},

--Spanish / Español
	[4] = {
		-- Options menu
        ["options_description"]                  = "Te recuerda que debes usar tus habilidades definitivas, si está equipado y listo",
		["options_header1"] = "General",
		["options_language"] = "Idioma",
		["options_language_tooltip"] = "Elegir idioma",
		["options_language_use_client"] 		 		 = "Utilizar el idioma del cliente",
		["options_language_use_client_tooltip"]  		 = "Deje siempre que el addon de utilizar el idioma del cliente de juego.",
		["options_language_dropdown_selection1"]		 = "Inglés",
		["options_language_dropdown_selection2"]		 = "Alemán",
		["options_language_dropdown_selection3"]		 = "Francés",
		["options_language_dropdown_selection4"]		 = "Espa\195\177ol",
        ["options_language_dropdown_selection5"] 		 = "Italiano",
        ["options_language_dropdown_selection6"]         = "Japonés",
        ["options_language_dropdown_selection7"] 		 = "Ruso",
		["options_language_description1"]	 = "CUIDADO: Modificar uno de estos parámetros recargará la interfaz.",
		["options_reloadui"]	 			 = "CUIDADO: Modificar esto parámetro recargará la interfaz.",
		["options_savedvariables"]	 = "Guardar",
		["options_savedvariables_tooltip"] = "Guardar los parámetros del addon para todos los personajes de la cuenta o individualmente para cada personaje",
		["options_savedVariables_dropdown_selection1"] = "Individualmente",
		["options_savedVariables_dropdown_selection2"] = "Cuenta",
		["options_header_options"]				 = "Opciones",

	},

    --Italian / Italiano
    [5] = {
        -- Options menu
    },

	--Japanese
    [6] = {
		-- Options menu
    },

--Russian
    [7] = {
        -- Options menu
    },
}
--Meta table trick to use english localization for german, french and spanish values, which are missing
local fco_urloc = FCOUltimateReminder.localizationVars.localizationAll
setmetatable(fco_urloc[2], {__index = fco_urloc[1]})
setmetatable(fco_urloc[3], {__index = fco_urloc[1]})
setmetatable(fco_urloc[4], {__index = fco_urloc[1]})
setmetatable(fco_urloc[5], {__index = fco_urloc[1]})
setmetatable(fco_urloc[6], {__index = fco_urloc[1]})
setmetatable(fco_urloc[7], {__index = fco_urloc[1]})
