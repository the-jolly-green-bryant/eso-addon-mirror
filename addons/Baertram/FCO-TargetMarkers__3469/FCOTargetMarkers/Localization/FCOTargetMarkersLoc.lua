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
local FCOTM = FCOTM
FCOTM.localizationVars.localizationAll = {
	--English
    [1] = {
		-- Options menu
        ["options_description"] 				 = "FCO TargetMarkers helps you with the target markers",
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
		--Group
		["options_header_settings_group"] 			 	   = "Group settings",
		["options_block_markers_if_grouped_and_no_leader"] = "Block if no group leader",
		["options_block_markers_if_grouped_and_no_leader_TT"] = "Block target marker changes if you are grouped but not the group leader",
		--Unit frames
		["options_header_settings_unitframes"] 			    = 	"Unit frames",
		["options_change_unit_frame_target_marker_size"] = 		"Change target marker size",
		["options_change_unit_frame_target_marker_size_TT"] = 	"Change the target marker size via the slider",
		["options_target_marker_size"] = 						"Size",
		["options_target_marker_size_TT"] = 					"Target marker size",
        --Chat commands
        ["chatcommands_info"]					 = "|c00FF00FCO|cFFFF00TargetMarkers|cFFFFFF",
        ["chatcommands_help"]					 = "|cFFFFFF'help' / 'list'|cFFFF00: Shows this information about the addon",
        ["chatcommands_debug"]					 = "|cFFFFFF'debug'|cFFFF00: Enable/Disable debug messages. |c990000[Attention]|cFFFF00 This will  flood your local chat!",
        ["chatcommands_debug_on"]				 = "Debug: ON",
        ["chatcommands_debug_off"]				 = "Debug: OFF",
        ["chatcommands_deepdebug_on"]			 = "Deep debug: ON",
        ["chatcommands_deepdebug_off"]			 = "Deep debug: OFF",
		--Keybinds
		["SI_BINDING_NAME_FCOTM_TOGGLE_1"]	     = "Toggle target marker 1",
		["SI_BINDING_NAME_FCOTM_TOGGLE_2"]	     = "Toggle target marker 2",
		["SI_BINDING_NAME_FCOTM_TOGGLE_3"]	     = "Toggle target marker 3",
		["SI_BINDING_NAME_FCOTM_TOGGLE_4"]	     = "Toggle target marker 4",
		["SI_BINDING_NAME_FCOTM_TOGGLE_5"]	     = "Toggle target marker 5",
		["SI_BINDING_NAME_FCOTM_TOGGLE_6"]	     = "Toggle target marker 6",
		["SI_BINDING_NAME_FCOTM_TOGGLE_7"]	     = "Toggle target marker 7",
		["SI_BINDING_NAME_FCOTM_TOGGLE_8"]	     = "Toggle target marker 8",
		["SI_BINDING_NAME_FCOTM_REMOVE_ALL"]     = "Remove all target markers",
    },
--==============================================================================
	--German / Deutsch
    [2] = {
		-- Options menu
        ["options_description"] 				 = "FCO TargetMarkers hilft dir mit den Target Markierungen",
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
		--Group
		["options_header_settings_group"] 			 	   = "Gruppen Einstellungen",
		["options_block_markers_if_grouped_and_no_leader"] = "Blockieren wenn nicht Gruppenanführer",
		["options_block_markers_if_grouped_and_no_leader_TT"] = "Blockiert die Zielmarkierungen wenn du in einer Gruppe, aber kein Gruppenanführer bist",
		--Unit frames
		["options_header_settings_unitframes"] 			    = 	"Einheiten Rahmen",
		["options_change_unit_frame_target_marker_size"] = 		"Ändere Zielmarkierungs Größe",
		["options_change_unit_frame_target_marker_size_TT"] = 	"Ändere die Zielmarkierungs Größe mit dem Schieberegler",
		["options_change_unit_frame_target_marker_size"] = 		"Ändere Zielmarkierungs Größe",
		["options_change_unit_frame_target_marker_size_TT"] = 	"Ändere die Zielmarkierungs Größe mit dem Schieberegler",
		["options_target_marker_size"] = 						"Größe",
		["options_target_marker_size_TT"] = 					"Zielmarkierungs Größe",
        --Chat commands
        ["chatcommands_info"]					 = "|c00FF00FCO|cFFFF00TargetMarkers|cFFFFFF",
        ["chatcommands_help"]					 = "|cFFFFFF'hilfe' / 'liste'|cFFFF00: Zeigt diese Information zum Addon an",
        ["chatcommands_debug"]					 = "|cFFFFFF'debug'|cFFFF00: Aktiviere/Deaktive Debug Nachrichten. |c990000[Achtung]|cFFFF00 Ihr lokaler Chat wird mit Nachrichten überschwemmt!",
        ["chatcommands_debug_on"]				 = "Debug: AN",
        ["chatcommands_debug_off"]				 = "Debug: AUS",
        ["chatcommands_deepdebug_on"]			 = "Deep debug: AN",
        ["chatcommands_deepdebug_off"]			 = "Deep debug: AUS",
		--Keybinds
		["SI_BINDING_NAME_FCOTM_TOGGLE_1"]	     = "Toggle Zielmarkierung 1",
		["SI_BINDING_NAME_FCOTM_TOGGLE_2"]	     = "Toggle Zielmarkierung 2",
		["SI_BINDING_NAME_FCOTM_TOGGLE_3"]	     = "Toggle Zielmarkierung 3",
		["SI_BINDING_NAME_FCOTM_TOGGLE_4"]	     = "Toggle Zielmarkierung 4",
		["SI_BINDING_NAME_FCOTM_TOGGLE_5"]	     = "Toggle Zielmarkierung 5",
		["SI_BINDING_NAME_FCOTM_TOGGLE_6"]	     = "Toggle Zielmarkierung 6",
		["SI_BINDING_NAME_FCOTM_TOGGLE_7"]	     = "Toggle Zielmarkierung 7",
		["SI_BINDING_NAME_FCOTM_TOGGLE_8"]	     = "Toggle Zielmarkierung 8",
 		["SI_BINDING_NAME_FCOTM_REMOVE_ALL"]     = "Alle Zielmarkierung entfernen",
   },
--French / Französisch
	[3] = {
		-- Options menu
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
		["options_language_dropdown_selection6"] 		 = "Japonais",
		["options_language_dropdown_selection7"] 		 = "Russe",
		["options_language_description1"]				 = "ATTENTION : Modifier un de ces réglages provoquera un chargement",
		["options_savedvariables"]						 = "Sauvegarder",
		["options_savedvariables_tooltip"] 				 = "Sauvegarder les données de l'addon pour tous les personages du compte, ou individuellement pour chaque personage",
		["options_savedVariables_dropdown_selection1"]	 = "Individuellement",
		["options_savedVariables_dropdown_selection2"]	 = "Compte",
	},
--Spanish
	[4] = {
		-- Options menu
		["options_header1"]                            = "General",
		["options_language"]                           = "Idioma",
		["options_language_tooltip"]                   = "Elegir idioma",
		["options_language_use_client"]                = "Utilizar el idioma del cliente",
		["options_language_use_client_tooltip"]        = "Deje siempre que el addon de utilizar el idioma del cliente de juego.",
		["options_language_dropdown_selection1"]       = "Inglés",
		["options_language_dropdown_selection2"]       = "Alemán",
		["options_language_dropdown_selection3"]       = "Francés",
		["options_language_dropdown_selection4"]       = "Espa\195\177ol",
		["options_language_dropdown_selection5"]       = "Italiano",
		["options_language_dropdown_selection6"]       = "Japonés",
		["options_language_dropdown_selection7"]       = "Ruso",
		["options_language_description1"]              = "CUIDADO: Modificar uno de esos parámetros recargará la interfaz",
		["options_savedvariables"]                     = "Guardar",
		["options_savedvariables_tooltip"]             = "Guardar los parámetros del addon para toda la cuenta o individualmente para cada personaje",
		["options_savedVariables_dropdown_selection1"] = "Individualmente",
		["options_savedVariables_dropdown_selection2"] = "Cuenta",
	},
--Italian
	[5] = {
		-- Options menu
		["options_header1"]                            = "General",
		["options_language"]                           = "Idioma",
		["options_language_tooltip"]                   = "Elegir idioma",
		["options_language_use_client"]                = "Utilizzare la lingua del client",
		["options_language_use_client_tooltip"]        = "Lasciate sempre l'addon usare il linguaggio del client di gioco.",
		["options_language_dropdown_selection1"]       = "Inglese",
		["options_language_dropdown_selection2"]       = "Germano",
		["options_language_dropdown_selection3"]       = "Francese",
		["options_language_dropdown_selection4"]       = "Spagnolo",
		["options_language_dropdown_selection5"]       = "Italiano",
		["options_language_dropdown_selection6"]       = "Giapponese",
		["options_language_dropdown_selection7"]       = "Russo",
		["options_language_description1"]              = "CUIDADO: Modificar uno de esos parámetros recargará la interfaz",
		["options_savedvariables"]                     = "Guardar",
		["options_savedvariables_tooltip"]             = "Guardar los parámetros del addon para toda la cuenta o individualmente para cada personaje",
		["options_savedVariables_dropdown_selection1"] = "Individualmente",
		["options_savedVariables_dropdown_selection2"] = "Cuenta",
	},
	--Japanese
    [6] = {
		-- Options menu
		["options_header1"]                            = "一般設定",
		["options_language"]                           = "言語",
		["options_language_tooltip"]                   = "言語を選択します",
		["options_language_use_client"]                = "クライアントの言語を使用する",
		["options_language_use_client_tooltip"]        = "アドオンが常にクライアントの言語を使用するようにします。",
		["options_language_dropdown_selection1"]       = "英語",
		["options_language_dropdown_selection2"]       = "ドイツ語",
		["options_language_dropdown_selection3"]       = "フランス語",
		["options_language_dropdown_selection4"]       = "スペイン語",
		["options_language_dropdown_selection5"]       = "イタリア語",
		["options_language_dropdown_selection6"]       = "日本語",
		["options_language_dropdown_selection7"]       = "ロシア語",
		["options_language_description1"]              = "注意: 言語の変更/設定の保存時にはUIがリロードされます！",
		["options_savedvariables"]                     = "設定の保存",
		["options_savedvariables_tooltip"]             = "アドオンの設定をアカウントの全キャラクターまたはキャラクター毎に保存します",
		["options_savedVariables_dropdown_selection1"] = "キャラクター毎",
		["options_savedVariables_dropdown_selection2"] = "アカウント全体",
	},
--Russian
	[7]	= {
		["options_description"] = "FCO TargetMarkers помогает с маркерами на целях",
		["options_header1"]                            = "Основные настройки",
		["options_language"]                           = "Язык",
		["options_language_tooltip"]                   = "Выбepитe язык",
		["options_language_use_client"]                = "Использовать язык клиента",
		["options_language_use_client_tooltip"]        = "Всегда использовать аддоном язык клиента игры.",
		["options_language_dropdown_selection1"]       = "Aнглийcкий",
		["options_language_dropdown_selection2"]       = "Нeмeцкий",
		["options_language_dropdown_selection3"]       = "Фpaнцузcкий",
		["options_language_dropdown_selection4"]       = "Иcпaнcкий",
		["options_language_dropdown_selection5"]       = "Итaльянcкий",
		["options_language_dropdown_selection6"]       = "Япoнcкий",
		["options_language_dropdown_selection7"]       = "Pуccкий",
		["options_language_description1"]              = "ВНИМAНИE: Измeнeниe языкa/нacтpoeк coxpaнeния пpивeдeт к пepeзaгpузкe интepфeйca!",
		["options_savedvariables"]                     = "Нacтpoйки coxpaнeния",
		["options_savedvariables_tooltip"]             = "Coxpaнять oбщиe нacтpoйки для вcex пepcoнaжeй aккaунтa или oтдeльныe для кaждoгo пepcoнaжa",
		["options_savedVariables_dropdown_selection1"] = "Для кaждoгo пepcoнaжa",
		["options_savedVariables_dropdown_selection2"] = "Oбщиe нa aккaунт",

		--Group
		["options_header_settings_group"] = "Настройки в группе",
		["options_block_markers_if_grouped_and_no_leader"] = "Блокировать, если вы не РЛ",
		["options_block_markers_if_grouped_and_no_leader_TT"] = "Блокировать маркировку цели, если вы в группе, но не являетесь ее лидером",
		--Unit frames
		["options_header_settings_unitframes"] = "Маркеры",
		["options_change_unit_frame_target_marker_size"] = "Изменить размер маркеров",
		["options_change_unit_frame_target_marker_size_TT"] = "Изменить размер маркеров с помощью ползунка",
		["options_target_marker_size"] = "Размер",
		["options_target_marker_size_TT"] = "Размер маркеров",
		--Chat commands
		["chatcommands_info"] = "|c00FF00FCO|cFFFF00TargetMarkers|cFFFFFF",
		["chatcommands_help"] = "|cFFFFFF'help' / 'list'|cFFFF00: Показывает эту информацию о аддоне",
		["chatcommands_debug"] = "|cFFFFFF'debug'|cFFFF00: Вкл/Откл сообщения отладки. |c990000[Внимание]|cFFFF00 Это захламит локальный чат!",
		["chatcommands_debug_on"] = "Отладка: Вкл",
		["chatcommands_debug_off"] = "Отладка: Откл",
		["chatcommands_deepdebug_on"] = "Глубокая отладка: Вкл",
		["chatcommands_deepdebug_off"] = "Глубокая отладка: Откл",
		--Keybinds
		["SI_BINDING_NAME_FCOTM_TOGGLE_1"] = "Переключить маркер цели 1",
		["SI_BINDING_NAME_FCOTM_TOGGLE_2"] = "Переключить маркер цели 2",
		["SI_BINDING_NAME_FCOTM_TOGGLE_3"] = "Переключить маркер цели 3",
		["SI_BINDING_NAME_FCOTM_TOGGLE_4"] = "Переключить маркер цели 4",
		["SI_BINDING_NAME_FCOTM_TOGGLE_5"] = "Переключить маркер цели 5",
		["SI_BINDING_NAME_FCOTM_TOGGLE_6"] = "Переключить маркер цели 6",
		["SI_BINDING_NAME_FCOTM_TOGGLE_7"] = "Переключить маркер цели 7",
		["SI_BINDING_NAME_FCOTM_TOGGLE_8"] = "Переключить маркер цели 8",
		["SI_BINDING_NAME_FCOTM_REMOVE_ALL"] = "Убрать все маркеры на целях",
	}
}
--Meta table trick to use english localization for german and french values, which are missing
local fco_targetmarkerloc = FCOTM.localizationVars.localizationAll
setmetatable(fco_targetmarkerloc[2], {__index = fco_targetmarkerloc[1]}) --de
setmetatable(fco_targetmarkerloc[3], {__index = fco_targetmarkerloc[1]}) --de
setmetatable(fco_targetmarkerloc[4], {__index = fco_targetmarkerloc[1]}) --de
setmetatable(fco_targetmarkerloc[5], {__index = fco_targetmarkerloc[1]}) --de
setmetatable(fco_targetmarkerloc[6], {__index = fco_targetmarkerloc[1]}) --de
setmetatable(fco_targetmarkerloc[7], {__index = fco_targetmarkerloc[1]}) --de
