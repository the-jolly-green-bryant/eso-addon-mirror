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
if FCORep == nil then FCORep = {} end
local FCORep = FCORep
FCORep.localizationVars.localizationAll = {
	--English
    [1] = {
		-- Options menu
        ["options_description"] 				 = "FCO Repair - Helps you to repair your equipment",
		["options_header1"] 			 		 = "General settings",
    	["options_language"] 					 = "Language",
		["options_language_tooltip"] 			 = "Choose the language",
		["options_language_use_client"] 		 = "Use client language",
		["options_language_use_client_tooltip"]  = "Always let the addon use the game client's language.",
		["options_language_dropdown_selection1"] = "English",
		["options_language_dropdown_selection2"] = "German",
		["options_language_dropdown_selection3"] = "French",
		["options_language_dropdown_selection4"] = "Spanish",
        ["options_language_dropdown_selection5"] = "Italian",
        ["options_language_dropdown_selection6"] = "Japanese",
        ["options_language_dropdown_selection7"] = "Russian",
		["options_language_description1"]		 = "CAUTION: Changing the language/save option will reload the user interface!",
        ["options_savedvariables"]				 = "Save settings",
        ["options_savedvariables_tooltip"]       = "Save the addon settings for all your characters of your account, or single for each character",
        ["options_savedVariables_dropdown_selection1"] = "Each character",
        ["options_savedVariables_dropdown_selection2"] = "Account wide",
        --Options repair
        ["options_header_repair"]                = "Repair",
        ["options_header_repair_condition"]      = "Condition",
        ["options_repair_condition_colorize"]    = "Colorize repair condition",
        ["options_repair_condition_colorize"]    = "Colorize the condition of each repairable item at the repair panel.\nYou define the threshold value and the color.",
        ["options_repair_condition_value_low"]   = "Low",
        ["options_repair_condition_value_medium"]= "Medium",
        ["options_repair_condition_value_high"]  = "High",
        ["options_repair_condition_threshold"]   = "Threshold",
        ["options_repair_condition_color"]       = "Color",
        ["options_header_sort"]                  = "Sort",
        ["options_sort_add_sortheader_text"]     = "Equip.",
        ["options_sort_add_sortheader"]          = "'Equipped' sort header",
        ["options_sort_add_sortheader_tooltip"]  = "Add a 'equipped' status sort header to the repair panel where you can sort your items by their 'currently equipped state'",
        ["options_sort_sortheader_default"]        = "Default sort direction",
        ["options_sort_sortheader_default_tooltip"]= "The default sort direction for the sort header (Equipped first / Non-equipped first",
        ["options_sort_sortheader_default_off"]     = "Off",
        ["options_sort_sortheader_default_equipped"] = "Equipped",
        ["options_sort_sortheader_default_nonequipped"] = "Non equipped",
        ["options_header_repair_name"]           = GetString(SI_INVENTORY_SORT_TYPE_NAME),
        ["options_repair_name_brackets"]         = "Add [ ] around equipped name",
        ["options_repair_name_brackets_tooltip"] = "Add the [ ] around the name of equipped items",
    },
--==============================================================================
	--German / Deutsch
    [2] = {
		-- Options menu
        ["options_description"] 				 = "FCO Repair - Hilft dir bei der Reperatur deiner Ausrüstung",
		["options_header1"] 			 		 = "Generelle Einstellungen",
    	["options_language"] 					 = "Sprache",
		["options_language_tooltip"] 			 = "Wählen Sie die Sprache aus",
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
        ["options_savedvariables"]				 = "Einstellungen speichern",
        ["options_savedvariables_tooltip"]       = "Die Einstellungen dieses Addons werden für alle Charactere Ihres Accounts, oder für jeden Character einzeln gespeichert",
        ["options_savedVariables_dropdown_selection1"] = "Jeder Charakter",
        ["options_savedVariables_dropdown_selection2"] = "Ganzer Account",
        --Options repair
        ["options_header_repair"]                = "Reperatur",
        ["options_header_repair_condition"]      = "Zustand",
        ["options_repair_condition_colorize"]    = "Färbe Zustand ein",
        ["options_repair_condition_colorize_tooltip"]    = "Färbe den Gegenstand's Zustand Wert im Reperatur Fenster ein.\nDu definierst die Farbe und den Schwellenwert.",
        ["options_repair_condition_value_low"]   = "Gering",
        ["options_repair_condition_value_medium"]= "Mittel",
        ["options_repair_condition_value_high"]  = "Hoch",
        ["options_repair_condition_threshold"]   = "Schwellenwert",
        ["options_repair_condition_color"]       = "Farbe",
        ["options_header_sort"]                  = "Sortierung",
        ["options_sort_add_sortheader_text"]     = "Ausg.",
        ["options_sort_add_sortheader"]          = "'Ausgerüstet' Sortierung",
        ["options_sort_add_sortheader_tooltip"]  = "Füge im Reperatur Fenster eine Sortierung 'Ausgerüstet' hinzu, welche dir die Sortierung nach ausgerüsteter/nicht ausgerüsteten Gegenständen ermöglicht.",
        ["options_sort_sortheader_default"]        = "Standard Sortierung",
        ["options_sort_sortheader_default_tooltip"]= "Die standard Sortierung (Ausgerüstet zuerst/Nicht-ausgerüstet zuerst)",
        ["options_sort_sortheader_default_off"]     = "Aus",
        ["options_sort_sortheader_default_equipped"] = "Ausgerüstet",
        ["options_sort_sortheader_default_nonequipped"] = "Nicht ausgerüstet",
        ["options_header_repair_name"]           = GetString(SI_INVENTORY_SORT_TYPE_NAME),
        ["options_repair_name_brackets"]         = "[ ] um den Namen für Ausgerüstete",
        ["options_repair_name_brackets_tooltip"] = "Zeige [ ] um den Namen herum an, wenn der Gegenstand ausgerüstet ist",
    },
--==============================================================================
--French / Französisch
	[3] = {
		-- Options menu
		["options_description"] 						 = "FCO Repair - Helps you to repair your equipment",
		["options_header1"] 							 = "Général",
		["options_language"]							 = "Langue",
		["options_language_tooltip"]					 = "Choisir la langue",
		["options_language_use_client"] 		 		 = "Utilisez le langage client",
		["options_language_use_client_tooltip"]  		 = "Toujours laisser l'addon utiliser la langue du client de jeu.",
		["options_language_dropdown_selection1"]		 = "Anglais",
		["options_language_dropdown_selection2"]		 = "Allemand",
		["options_language_dropdown_selection3"]		 = "Français",
		["options_language_dropdown_selection4"] 		 = "Espagnol",
        ["options_language_dropdown_selection5"]	 	 = "Italien",
        ["options_language_dropdown_selection6"]         = "Japonais",
        ["options_language_dropdown_selection7"] 		 = "Russe",
		["options_language_description1"]				 = "ATTENTION : Modifier un de ces réglages provoquera un chargement",
		["options_savedvariables"]						 = "Sauvegarder",
		["options_savedvariables_tooltip"] 				 = "Sauvegarder les données de l'addon pour tous les personages du compte, ou individuellement pour chaque personage",
		["options_savedVariables_dropdown_selection1"]	 = "Individuellement",
		["options_savedVariables_dropdown_selection2"]	 = "Compte",
        --Options repair
        ["options_header_repair"]                = "Réparation",
        ["options_header_repair_condition"]      = "Condition",
        ["options_repair_condition_colorize"]    = "Colore la condition de réparation",
        ["options_repair_condition_colorize"]    = "Colorer la condition des objets réparables",
        ["options_repair_condition_value_low"]   = "Niveau bas",
        ["options_repair_condition_value_medium"]= "Niveau moyen",
        ["options_repair_condition_value_high"]  = "Niveau haut",
        ["options_repair_condition_threshold"]   = "Seuil",
        ["options_repair_condition_color"]       = "Couleur",
        ["options_header_sort"]                  = "Tri",
        ["options_sort_add_sortheader_text"]     = "Equipé",
        ["options_sort_add_sortheader"]          = "Tri de l'en-tête 'Equipé'",
        ["options_sort_add_sortheader_tooltip"]  = "Ajoute le statut 'Equipé' dans la fenêtre de réparation. Vous pouvez trier vos objets par leur état d'équipement actuel.",
        ["options_sort_sortheader_default"]        = "Direction du tri par défaut",
        ["options_sort_sortheader_default_tooltip"]= "Le tri par défaut pour l'en-tête de tri (Equipé en premier/Non-équipé en premier.",
        ["options_sort_sortheader_default_off"]     = "Off",
        ["options_sort_sortheader_default_equipped"] = "Equipé",
        ["options_sort_sortheader_default_nonequipped"] = "Non equipé",
        ["options_header_repair_name"]           = GetString(SI_INVENTORY_SORT_TYPE_NAME),
        ["options_repair_name_brackets"] = "Ajouter des [ ] autour du nom",
        ["options_repair_name_brackets_tooltip"] = "Ajoute des [ ] autour du nom des objets équipés.",
    },
--==============================================================================
--Spanish
	[4] = {
        -- Options menu
        ["options_description"] 				         = "FCO Repair - Helps you to repair your equipment",
		["options_header1"] 							 = "General",
		["options_language"]							 = "Idioma",
		["options_language_tooltip"]					 = "Elegir idioma",
		["options_language_use_client"] 		 		 = "Utilizar el idioma del cliente",
		["options_language_use_client_tooltip"]  		 = "Deje siempre que el addon de utilizar el idioma del cliente de juego.",
		["options_language_dropdown_selection1"]		 = "Inglés",
		["options_language_dropdown_selection2"]		 = "Alemán",
		["options_language_dropdown_selection3"]		 = "Francés",
		["options_language_dropdown_selection4"]		 = "Espa\195\177ol",
        ["options_language_dropdown_selection5"] 		 = "Italiano",
        ["options_language_dropdown_selection6"]         = "Japonés",
        ["options_language_dropdown_selection7"] 		 = "Ruso",
		["options_language_description1"]				 = "CUIDADO: Modificar uno de esos parámetros recargará la interfaz",
		["options_savedvariables"]						 = "Guardar",
		["options_savedvariables_tooltip"] 				 = "Guardar los parámetros del addon para toda la cuenta o individualmente para cada personaje",
		["options_savedVariables_dropdown_selection1"]	 = "Individualmente",
		["options_savedVariables_dropdown_selection2"]	 = "Cuenta",
	},
--==============================================================================
    --Italian
    [5] = {
        -- Options menu
        ["options_description"] 				 = "FCO Repair - Helps you to repair your equipment",
        ["options_header1"] 			 		 = "Impostazioni generali",
        ["options_language"] 					 = "Lingua",
        ["options_language_tooltip"] 			 = "Scegli la lingua",
		["options_language_use_client"] 		 		 = "Utilizzare la lingua del client",
		["options_language_use_client_tooltip"]  		 = "Lasciate sempre l'addon usare il linguaggio del client di gioco.",
        ["options_language_dropdown_selection1"] = "Inglese",
        ["options_language_dropdown_selection2"] = "Germano",
        ["options_language_dropdown_selection3"] = "Francese",
        ["options_language_dropdown_selection4"] = "Spagnolo",
        ["options_language_dropdown_selection5"] = "Italiano",
        ["options_language_dropdown_selection6"] = "Giapponese",
        ["options_language_dropdown_selection7"] = "Russo",
        ["options_language_description1"]		 = "ATTENZIONE: modifica della lingua opzione / salvare ricaricherà l'interfaccia utente!",
        ["options_reloadui"]					 = "ATTENZIONE: La modifica di questa opzione ricaricherà l'interfaccia utente!",
        ["options_savedvariables"]				 = "Salvare le impostazioni",
        ["options_savedvariables_tooltip"]       = "Salvare le impostazioni addon per tutti i tuoi personaggi del tuo account, o unico per ogni carattere",
        ["options_savedVariables_dropdown_selection1"] = "Ogni personaggio",
        ["options_savedVariables_dropdown_selection2"] = "Tutto acconto",
    },
--==============================================================================
    --Japanese
    [6] = {
        -- Options menu
        ["options_description"] 				 = "FCO Repair - Helps you to repair your equipment",
        ["options_header1"] 			 		 = "一般設定",
        ["options_language"] 					 = "言語",
        ["options_language_tooltip"] 			 = "言語の選択",
		["options_language_use_client"] 		 = "クライアントの言語を使用する",
		["options_language_use_client_tooltip"]  = "アドオンが常にクライアントの言語を使用するようにします。",
        ["options_language_dropdown_selection1"] = "英語",
        ["options_language_dropdown_selection2"] = "ドイツ語",
        ["options_language_dropdown_selection3"] = "フランス語",
        ["options_language_dropdown_selection4"] = "スペイン語",
        ["options_language_dropdown_selection5"] = "イタリア語",
        ["options_language_dropdown_selection6"] = "日本語",
        ["options_language_dropdown_selection7"] = "ロシア",
        ["options_language_description1"]		 = "注意: 言語の変更/設定の保存時にはUIがリロードされます！",
        ["options_savedvariables"]				 = "設定の保存",
        ["options_savedvariables_tooltip"]       = "アドオンの設定をアカウントの全キャラクターまたはキャラクター毎に保存します",
        ["options_savedVariables_dropdown_selection1"] = "キャラクター毎",
        ["options_savedVariables_dropdown_selection2"] = "アカウント全体",
    },
--==============================================================================
	--Russian
    [7] = {
        -- Options menu
        ["options_description"]                  = "FCO Repair - Helps you to repair your equipment",
        ["options_header1"]                      = "Основные настройки",
        ["options_language"]                     = "Язык",
        ["options_language_tooltip"]             = "Выбepитe язык",
		["options_language_use_client"]          = "Использовать язык клиента",
		["options_language_use_client_tooltip"]  = "Всегда использовать аддоном язык клиента игры.",
        ["options_language_dropdown_selection1"] = "Aнглийcкий",
        ["options_language_dropdown_selection2"] = "Нeмeцкий",
        ["options_language_dropdown_selection3"] = "Фpaнцузcкий",
        ["options_language_dropdown_selection4"] = "Иcпaнcкий",
        ["options_language_dropdown_selection5"] = "Итaльянcкий",
        ["options_language_dropdown_selection6"] = "Япoнcкий",
        ["options_language_dropdown_selection7"] = "Pуccкий",
        ["options_language_description1"]        = "ВНИМAНИE: Измeнeниe языкa/нacтpoeк coxpaнeния пpивeдeт к пepeзaгpузкe интepфeйca!",
        ["options_savedvariables"]               = "Нacтpoйки coxpaнeния",
        ["options_savedvariables_tooltip"]     = "Coxpaнять oбщиe нacтpoйки для вcex пepcoнaжeй aккaунтa или oтдeльныe для кaждoгo пepcoнaжa",
        ["options_savedVariables_dropdown_selection1"] = "Для кaждoгo пepcoнaжa",
        ["options_savedVariables_dropdown_selection2"] = "Oбщиe нa aккaунт",
    },
}
--Meta table trick to use english localization for german and french values, which are missing
local fco_reploc = FCORep.localizationVars.localizationAll
setmetatable(fco_reploc[2], {__index = fco_reploc[1]})
setmetatable(fco_reploc[3], {__index = fco_reploc[1]})
setmetatable(fco_reploc[4], {__index = fco_reploc[1]})
setmetatable(fco_reploc[5], {__index = fco_reploc[1]})
setmetatable(fco_reploc[6], {__index = fco_reploc[1]})
setmetatable(fco_reploc[7], {__index = fco_reploc[1]})
