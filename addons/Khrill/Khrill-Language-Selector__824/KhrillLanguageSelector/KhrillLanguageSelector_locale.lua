--                v 1.6.0               --
--[[
   à : \195\160    è : \195\168    ğ : \196\159    ì : \195\172    ò : \195\178    ş : \197\159    ù : \195\185
   á : \195\161    é : \195\169                    í : \195\173    ó : \195\179                    ú : \195\186
   â : \195\162    ê : \195\170                    î : \195\174    ô : \195\180                    û : \195\187
   ã : \195\163    ë : \195\171                    ï : \195\175    õ : \195\181                    ü : \195\188
   ä : \195\164                                    ñ : \195\177    ö : \195\182
   æ : \195\166                                    ı : \196\177    ø : \195\184
   ç : \195\167                                                    œ : \197\147
   Ä : \195\132   Ğ : \196\158   İ : \196\176   Ö : \195\150   Ü : \195\156    ß : \195\159    Ş : \197\158
]]

KLS_Lang = {
	["en"] = {LOCALE = "EN",
	
		Settings_enable = "Enable",
		Settings_keybindText = "|cFF6A00Note :|r\nYou can also assign a key to change language.\nSee in options Keybindings/|cFF6A00Khrill|r Language Selector.",
		Settings_control = "Settings",
		Settings_printFlag = "Display the flag",
		Settings_positionning = "Positioning",
		Settings_positionningText = "This option displays the frame to be able to choose the location on the screen.",
	},
	["fr"] = {LOCALE = "FR",
	
		Settings_enable = "Actif",
		Settings_keybindText = "|cFF6A00Note :|r\nVous pouvez aussi assigner une touche de raccourci pour changer de langage.\nVoir dans Commandes/Raccourcis/|cFF6A00Khrill|r Language Selector.",
		Settings_control = "Réglages",
		Settings_printFlag = "Afficher le drapeau",
		Settings_positionning = "Positionnement",
		Settings_positionningText = "Cette option permet d'afficher le cadre afin de pouvoir choisir son emplacement sur l'écran.",
	},
	["de"] = {LOCALE = "DE", -- by votan
	
		Settings_enable = "Aktivieren",
		Settings_keybindText = "|cFF6A00Anmerkung :|r\nDu kannst auch eine Taste zum sprache ändern zuweisen in den TESO-Tastatureinstellungen.\nZu finden unter |cFF6A00Khrill|r Language Selector",
		Settings_control = "Einstellungen",
		Settings_printFlag = "Anzeigen der Flagge",
		Settings_positionning = "Positionierung",
		Settings_positionningText = "Diese Option zeigt den Rahmen, um die Position auf dem Bildschirm zu wählen.",
	},
	["es"] = {LOCALE = "ES", -- by Cervanteso
	
		Settings_enable = "Permitir",
		Settings_keybindText = "|cFF6A00Note :|r\nTambién puede asignar una tecla de acceso directo para cambiar el idioma..\nVer Controles/Asignación de teclas/|cFF6A00Khrill|r Language Selector.",
		Settings_control = "Ajustes",
		Settings_printFlag = "Visualice la bandera",
		Settings_positionning = "Posicionamiento",
		Settings_positionningText = "Esta opción muestra el fotograma con el fin de elegir su ubicación en la pantalla.",
	},
	["it"] = {LOCALE = "IT", -- by DarioZ
	
		Settings_enable = "Abilita",
		Settings_keybindText = "|cFF6A00Nota:|r\nPuoi anche assegnare un tasto per cambiare linguaggio.\nVedi in opzioni Assegnazione/|cFF6A00Khrill|r Language Selector.",
		Settings_control = "Impostazioni",
		Settings_printFlag = "Mostra la bandiera",
		Settings_positionning = "Posizionamento",
		Settings_positionningText = "Questa opzione mostra una finestra per poter scegliere il posizionamento sullo schermo.",
	},
	["br"] = {LOCALE = "BR", -- by Leju
	
		Settings_enable = "Permitir",
		Settings_keybindText = "|cFF6A00Note :|r\nYou can also assign a key to change language.\nSee in options Keybindings/|cFF6A00Khrill|r Language Selector.",
		Settings_control = "Ajustes",
		Settings_printFlag = "Visualizar Bandeira",
		Settings_positionning = "Posicionamento",
		Settings_positionningText = "Mostra na tela o quadro com as bandeiras para escolher o idioma.",
	},
	["ru"] = {LOCALE = "RU", -- by TERAB1T
	
		Settings_enable = "Enable",
		Settings_keybindText = "|cFF6A00Note :|r\nYou can also assign a key to change language.\nSee in options Keybindings/|cFF6A00Khrill|r Language Selector.",
		Settings_control = "Settings (translation needed)",
		Settings_printFlag = "Display the flag",
		Settings_positionning = "Positioning",
		Settings_positionningText = "This option displays the frame to be able to choose the location on the screen.",
	},
	["tr"] = {LOCALE = "TR", -- by CradonWar
	
		Settings_enable = "Etkinleştir",
		Settings_keybindText = "|cFF6A00Not :|r\nDili değiştirmek için bir tuş da atayabilirsin.\nTuşlar/|cFF6A00Khrill|r Language Selector seçeneklerine bakın.",
		Settings_control = "Ayarlar",
		Settings_printFlag = "Bayrak Göster:",
		Settings_positionning = "KONUMLANDIRMA",
		Settings_positionningText = "Bu seçenek ekranda konum seçebilmek için çerçeve gösterir.",
	}
}
ZO_CreateStringId("SI_BINDING_NAME_KLS_EN", "English (EN)")
ZO_CreateStringId("SI_BINDING_NAME_KLS_FR", "French (FR)")
ZO_CreateStringId("SI_BINDING_NAME_KLS_DE", "German (DE)")
ZO_CreateStringId("SI_BINDING_NAME_KLS_ES", "Spanish (ES)")
ZO_CreateStringId("SI_BINDING_NAME_KLS_IT", "Italian (IT)")
ZO_CreateStringId("SI_BINDING_NAME_KLS_BR", "Portuguese (BR)")
ZO_CreateStringId("SI_BINDING_NAME_KLS_RU", "Russian (RU)")
ZO_CreateStringId("SI_BINDING_NAME_KLS_TR", "Turkish (TR)")