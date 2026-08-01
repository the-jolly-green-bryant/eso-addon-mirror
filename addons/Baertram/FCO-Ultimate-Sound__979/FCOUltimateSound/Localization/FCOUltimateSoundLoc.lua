-- Version 0.0.8a

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
local FCOUS = FCOUS
FCOUS.localizationVars.localizationAll = {
	--English
    [1] = {
		-- Options menu
        ["options_description"] 				 = "FCO Ultimate Sound will change your 'ultimate ready' sound",
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
		--Options on/off
		["options_header_ultimate_sound"]		 = "'Ultimate ready' sound",
        ["options_toggle_noultimatesound"]		 = "Turn 'Ultimate ready' sound off",
        ["options_toggle_noultimatesound_tooltip"]	 = "If your ultimate is ready you will hear a sound. This will be played each time you kill an enemy, if your ultimate is ready. This option turns of this ultimate ready sound.",
		["options_newultimatesound1"] 			 = "Weapon bar 1",
        ["options_newultimatesound1_tooltip"] 	 = "Play this sound if your ultimate is ready at your weapon bar 1 (Weapon bar must be active to hear the sound. You won't hear the sound of weapon bar 1 if the ultimate is ready there and you are using weapon bar 2 at the moment!)",
        ["options_newultimatesound2"] 			 = "Weapon bar 2",
        ["options_newultimatesound2_tooltip"] 	 = "Play this sound if your ultimate is ready at your weapon bar 2 (Weapon bar must be active to hear the sound. You won't hear the sound of weapon bar 2 if the ultimate is ready there and you are using weapon bar 1 at the moment!)",
        ["options_only_play_ultimate_if_in_fight"] = "Only play in combat",
        ["options_only_play_ultimate_if_in_fight_tooltip"] = "Only play the ultimate ready sound if you are in combat",
        ["options_play_ultimate_always_on_weapon_switch"] = "Play on weapon switch",
        ["options_play_ultimate_always_on_weapon_switch_tooltip"] = "Always play the ultimate ready sound if you switch your weapons and your ultimate is ready. Will only play out of combat if you have disabled the setting 'only play in combat'.",
		["options_header_sound_on_weapon_switch"]		= "Weapon switch sound",
		["options_play_sound_on_weapon_switch1"]			= "Play sound on weapon switch - Bar 1",
		["options_play_sound_on_weapon_switch1_tooltip"]	= "Play the selected sound if you switch your weapons to action bar 1. Select 'NONE' to disable the sound",
		["options_play_sound_on_weapon_switch2"]			= "Play sound on weapon switch - Bar 2",
		["options_play_sound_on_weapon_switch2_tooltip"]	= "Play the selected sound if you switch your weapons to action bar 2. Select 'NONE' to disable the sound",
		["options_only_play_sound_if_in_fight"]			= "Only play switch sound in combat",
		["options_only_play_sound_if_in_fight_tooltip"]	= "Only play the weapon switch sound if you are in combat",
        --Chat commands
        ["chatcommands_info"]					 = "|c00FF00FCO|cFFFF00UltimateSound|r",
        ["chatcommands_help"]					 = "|cFFFFFF'help' / 'list'|cFFFF00: Shows this information about the addon",
        ["chatcommands_toggle_noultimatesound"]	 = "|cFFFFFF'toggle'|cFFFF00: Toggle 'Play Ultimate ready' sound on/off",
        ["chatcommands_noultimatesound_on"]	 	 = "'Play Ultimate ready' sound is ON",
        ["chatcommands_noultimatesound_off"]	 = "'Play Ultimate ready' sound is OFF",
    },
--==============================================================================
	--German / Deutsch
    [2] = {
		-- Options menu
        ["options_description"] 				 = "FCO Ultimate Sound verändert deinen 'Ultimate bereit' Sound",
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
		--Options on/off
		["options_header_ultimate_sound"]		 = "Ultimate bereit Klang",
        ["options_toggle_noultimatesound"]		 = "Schalte 'Ultimate bereit' Sound aus",
        ["options_toggle_noultimatesound_tooltip"]		 = "Jedes Mal wenn deine Ultimate bereit ist spielt das System einen Sound ab. Diese Option schaltet diesen Sound aus.",
        ["options_newultimatesound1"] 			 = "Waffenleiste 1",
        ["options_newultimatesound1_tooltip"] 	 = "Dieser Klang wird abgespielt, wenn Ihre Ultimate auf der Waffenleiste 1 bereit ist (Die Waffenleiste 1 muss aktiv sein, damit Sie den Klang hören. Sie werden nicht den Klang hören, wenn Sie die Waffenleiste 2 aktiv haben, und die Ultimate Fähigkeit auf Leiste 1 bereit ist!)",
        ["options_newultimatesound2"] 			 = "Waffenleiste 2",
        ["options_newultimatesound2_tooltip"] 	 = "Dieser Klang wird abgespielt, wenn Ihre Ultimate auf der Waffenleiste 2 bereit ist (Die Waffenleiste 2 muss aktiv sein, damit Sie den Klang hören. Sie werden nicht den Klang hören, wenn Sie die Waffenleiste 1 aktiv haben, und die Ultimate Fähigkeit  auf Leiste 2 bereit ist!)",
        ["options_only_play_ultimate_if_in_fight"] = "Nur im Kampf abspielen",
        ["options_only_play_ultimate_if_in_fight_tooltip"] = "Den 'Ultimate bereit' Sound nur abspielen, wenn du dich im Kampf befindest",
        ["options_play_ultimate_always_on_weapon_switch"] = "Bei Waffenwechsel abspielen",
        ["options_play_ultimate_always_on_weapon_switch_tooltip"] = "Spielt den 'Ultimate Fähigkeit bereit' Klang immer beim Waffenwechsel ab. Wird nur außerhalb des Kampfes abgespielt, wenn die entsprechende Option gesetzt wurde.",

		["options_header_sound_on_weapon_switch"]		= "Waffenwechsel Klang",
		["options_play_sound_on_weapon_switch1"]		= "Leiste 1",
		["options_play_sound_on_weapon_switch1_tooltip"]= "Spielt den ausgewählten Klang ab, wenn die Waffen zur Aktionsleiste 1 gewechselt werden. Wähle 'NONE' aus, um den Klang abzuschalten",
		["options_play_sound_on_weapon_switch2"]		= "Leiste 2",
		["options_play_sound_on_weapon_switch2_tooltip"]= "Spielt den ausgewählten Klang ab, wenn die Waffen zur Aktionsleiste 2 gewechselt werden. Wähle 'NONE' aus, um den Klang abzuschalten",
		["options_only_play_sound_if_in_fight"]			= "Nur Waffenwechsel Klang im Kampf abspielen",
		["options_only_play_sound_if_in_fight_tooltip"]	= "Spielt den Waffenwechsel Klang nur ab, wenn du dich im Kampf befindest",

        --Chat commands
        ["chatcommands_info"]					 = "|c00FF00FCO|cFFFF00UltimateSound|r",
        ["chatcommands_help"]					 = "|cFFFFFF'help' / 'list'|cFFFF00: Zeigt diese Informationen an",
        ["chatcommands_toggle_noultimatesound"]	 = "|cFFFFFF'toggle'|cFFFF00: Schalte 'Ultimate bereit Sound' an/aus",
        ["chatcommands_noultimatesound_on"]	 	 = "'Ultimate bereit Sound' ist AN",
        ["chatcommands_noultimatesound_off"]	 = "'Ultimate bereit Sound' ist AUS",
    },
--==============================================================================
--French / Französisch
	[3] = {
		-- Options menu
        ["options_description"] 				 		 = "FCO Ultimate Sound changera votre son pour 'Ultime prête' ",
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
		--Options on/off
		["options_header_ultimate_sound"]		 = "Son de l'ultime prête",

		["options_toggle_noultimatesound"]		 = "Activer le son de l'ultime prête' OFF",
		["options_toggle_noultimatesound_tooltip"]	 = "Si votre compétence ultime est prête, vous allez entendre un son. Le son sera joué à chaque fois que vous tuerez un ennemi si votre ultime est prête. Cette option désactive le son d'ultime prête.",

		["options_newultimatesound1"] 			 = "Barre d'arme 1",
		["options_newultimatesound1_tooltip"] 	 = "Joue le son si votre compétence ultime est prête sur votre barre d'action 1. La barre d'arme doit être activée pour entendre le son. Vous n'entendrez pas le son de la barre d'action 1 si l'ultime est prête et que vous utilisez la barre d'action 2 à ce moment-là.",
		["options_newultimatesound2"] 			 = "Barre d'arme 2",
		["options_newultimatesound2_tooltip"] 	 = "Joue le son si votre compétence ultime est prête sur votre barre d'action 2. La barre d'arme doit être activée pour entendre le son. Vous n'entendrez pas le son de la barre d'action 2 si l'ultime est prête et que vous utilisez la barre d'action 1 à ce moment-là.",
		["options_play_ultimate_always_on_weapon_switch"] = "Jouer au changement d'arme",
		["options_play_ultimate_always_on_weapon_switch_tooltip"] = "Toujours jouer le son d'ultime prête si vous changer d'arme et que votre compétence ultime est prête. Sera joué en dehors des combats si vous avez désactivé l'option 'Jouer seulement en combat'.",

		["options_only_play_ultimate_if_in_fight"] = "Jouer seulement en combat",
		["options_only_play_ultimate_if_in_fight_tooltip"] = "Joue le son d'ultime prête seulement en combat.",

		["options_header_sound_on_weapon_switch"]		= "Son au changement d'arme",
		["options_play_sound_on_weapon_switch1"]			= "Jouer le son au passage à la barre d'action 1",
		["options_play_sound_on_weapon_switch1_tooltip"]	= "Joue le son sélectionné lorsque vous passez à la barre d'action 1. Sélectionner 'NON' pour désactiver le son",
		["options_play_sound_on_weapon_switch2"]			= "Jouer le son au passage à la barre d'action 2",
		["options_play_sound_on_weapon_switch2_tooltip"]	= "Joue le son sélectionné lorsque vous passez à la barre d'action 2. Sélectionner 'NON' pour désactiver le son",
		["options_only_play_sound_if_in_fight"]			= "Jouer seulement le son de changement d'arme en combat",
		["options_only_play_sound_if_in_fight_tooltip"]	= "Joue le son de changement d'arme uniquement lorsque vous êtes en combat",

		--Chat commands
		["chatcommands_info"]					 = "|c00FF00FCO|cFFFF00UltimateSound|r",
		["chatcommands_help"]					 = "|cFFFFFF'help' / 'list'|cFFFF00: Révèle cette information sur l'extension",
		["chatcommands_toggle_noultimatesound"]	 = "|cFFFFFF'toggle'|cFFFF00: Basculer 'Jouer le son ultime prête' on/off",
		["chatcommands_noultimatesound_on"]	 	 = "Le son 'ultime prête' est activé",
		["chatcommands_noultimatesound_off"]	 = "Le son 'ultime prête' est désactivé",
	},
--==============================================================================
--Spanish
	[4] = {
		-- Options menu
        ["options_description"] 				 		 = "FCO Ultimate Sound will change your 'ultimate ready' sound",
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
		["options_language_dropdown_selection6"] 		 = "Japonés",
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
        ["options_description"] 				 		 = "FCO Ultimate Sound will change your 'ultimate ready' sound",
		["options_header1"] 							 = "General",
		["options_language"]							 = "Idioma",
		["options_language_tooltip"]					 = "Elegir idioma",
		["options_language_use_client"] 		 		 = "Utilizzare la lingua del client",
		["options_language_use_client_tooltip"]  		 = "Lasciate sempre l'addon usare il linguaggio del client di gioco.",
		["options_language_dropdown_selection1"] = "Inglese",
		["options_language_dropdown_selection2"] = "Germano",
		["options_language_dropdown_selection3"] = "Francese",
		["options_language_dropdown_selection4"] = "Spagnolo",
		["options_language_dropdown_selection5"] = "Italiano",
		["options_language_dropdown_selection6"]  = "Giapponese",
		["options_language_dropdown_selection7"] = "Russo",
		["options_language_description1"]				 = "CUIDADO: Modificar uno de esos parámetros recargará la interfaz",
		["options_savedvariables"]						 = "Guardar",
		["options_savedvariables_tooltip"] 				 = "Guardar los parámetros del addon para toda la cuenta o individualmente para cada personaje",
		["options_savedVariables_dropdown_selection1"]	 = "Individualmente",
		["options_savedVariables_dropdown_selection2"]	 = "Cuenta",
	},
	--==============================================================================
	--Japanese
	[6] = {
		-- Options menu
		["options_description"] 				 = "FCO Ultimate Sound will change your 'ultimate ready' sound",
		["options_header1"] 			 		 = "一般設定",
		["options_language"] 					 = "言語",
		["options_language_tooltip"] 			 = "言語を選択します",
		["options_language_use_client"] 		 = "クライアントの言語を使用する",
		["options_language_use_client_tooltip"]  = "アドオンが常にクライアントの言語を使用するようにします。",
		["options_language_dropdown_selection1"] = "英語",
		["options_language_dropdown_selection2"] = "ドイツ語",
		["options_language_dropdown_selection3"] = "フランス語",
		["options_language_dropdown_selection4"] = "スペイン語",
		["options_language_dropdown_selection5"] = "イタリア語",
		["options_language_dropdown_selection6"] = "日本語",
		["options_language_dropdown_selection7"] = "ロシア語",
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
		["options_description"] 				 = "FCO Ultimate Sound will change your 'ultimate ready' sound",
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
		["options_savedvariables_tooltip"]       = "Coxpaнять oбщиe нacтpoйки для вcex пepcoнaжeй aккaунтa или oтдeльныe для кaждoгo пepcoнaжa",
		["options_savedVariables_dropdown_selection1"] = "Для кaждoгo пepcoнaжa",
		["options_savedVariables_dropdown_selection2"] = "Oбщиe нa aккaунт",
	},
}

--Meta table trick to use english localization for german and french values, which are missing
setmetatable(FCOUS.localizationVars.localizationAll[2], {__index = FCOUS.localizationVars.localizationAll[1]})
setmetatable(FCOUS.localizationVars.localizationAll[3], {__index = FCOUS.localizationVars.localizationAll[1]})
setmetatable(FCOUS.localizationVars.localizationAll[4], {__index = FCOUS.localizationVars.localizationAll[1]})
setmetatable(FCOUS.localizationVars.localizationAll[5], {__index = FCOUS.localizationVars.localizationAll[1]})
setmetatable(FCOUS.localizationVars.localizationAll[6], {__index = FCOUS.localizationVars.localizationAll[1]})
setmetatable(FCOUS.localizationVars.localizationAll[7], {__index = FCOUS.localizationVars.localizationAll[1]})
