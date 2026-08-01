--                v 1.3.2               --
--[[
   à : \195\160    è : \195\168    ì : \195\172    ò : \195\178    ù : \195\185
   á : \195\161    é : \195\169    í : \195\173    ó : \195\179    ú : \195\186
   â : \195\162    ê : \195\170    î : \195\174    ô : \195\180    û : \195\187
   ã : \195\163    ë : \195\171    ï : \195\175    õ : \195\181    ü : \195\188
   ä : \195\164                    ñ : \195\177    ö : \195\182
   æ : \195\166                                    ø : \195\184
   ç : \195\167                                    œ : \197\147
   Ä : \195\132   Ö : \195\150   Ü : \195\156    ß : \195\159
]]

KHID_Lang = {
	["en"] = {LOCALE = "EN",
	
		Settings_enable = "Enable",
		Settings_choose = "Choose an item",
		Settings_control = "Settings",
		Settings_warning = "Will need to reload the UI.", 
		Settings_showWithInventory = "Show with the inventory",
		Settings_hideEmpty = "Hide the interface if empty",
		Settings_showConsumable = "Show trophies which are consumables",
		Settings_maxCol = "Number of disguises per line",
		Settings_maxRow = "Maximum number of lines",
		Settings_fixedSize = "Maximal fixed size",
		Settings_tooltipPosition = "Tooltip's position",
		Settings_itemIcon = "Icons in inventory",
		Settings_itemIconTip = "Mark objects by a specific icon in the inventory",
		Settings_itemIconColor = "Color of the icon",
		Settings_newItem = "Warn when looting of a new disguise", 
		Settings_newItemTip = "Displays a message at the center of the screen when you loot a new disguise",
		Settings_sysmessage = "Display system messages",
		Settings_positionning = "Positioning",
		Settings_positionningText = "This option displays the frame to be able to choose the location on the screen.\nOnce completed, disable the option.",
		Settings_keybindText = "|cFF6A00Note :|r\nYou can also assign a key to show/hide manually.\nSee in options Keybindings/|cFF6A00Khrill|r Hero In Disguise/Show-hide the window.",

		SI_BINDING_NAME_KHIDTOGGLE = "Show/hide the window",
		
		Message_Marked = "Marked as",
		Message_Unmarked = "Unmark",
	},
	["de"] = {LOCALE = "DE", --Googletrad
	
		Settings_enable = "Aktivieren",
		Settings_choose = "W\195\164hlen Sie ein Element",
		Settings_control = "Einstellungen",
		Settings_warning = "Oberfl\195\164che neu laden.", 
		Settings_showWithInventory = "Mit dem Inventar anzeigen",
		Settings_hideEmpty = "Blenden Sie die Schnittstelle, wenn leer",
		Settings_showConsumable = "Show Troph\195\164en, die Verbrauchsmaterialien", 
		Settings_maxCol = "Anzahl der Verkleidungen pro Zeile",
		Settings_maxRow = "Maximale Anzahl von Zeilen",
		Settings_fixedSize = "Maximale feste Gr\195\182\195\159e", 
		Settings_tooltipPosition = "Position des Quickinfo",
		Settings_itemIcon = "Icons im Inventar", 
		Settings_itemIconTip = "Mark-Objekte von einem bestimmten Symbol im Inventar", 
		Settings_itemIconColor = "Farbe des Symbols", 
		Settings_newItem = "Warnen wenn die Entdeckung einer neuen Verkleidung", 
		Settings_newItemTip = "Zeigt eine Meldung in der Mitte des Bildschirms, wenn Sie eine neue Verkleidung pl\195\188ndern", 
		Settings_sysmessage = "System Nachricht anzeigen",
		Settings_positionning = "Positionierung",
		Settings_positionningText = "Diese Option zeigt den Rahmen, um die Position auf dem Bildschirm zu w\195\164hlen.\nDeaktivieren Sie diese Option anschlie\195\159end wieder.",
		Settings_keybindText = "|cFF6A00Anmerkung :|r\nDu kannst auch eine Taste zum Anzeigen/Verbergen zuweisen.\nIn den Tastatureinstellungen unter: |cFF6A00Khrill|r Hero In Disguise.",

		SI_BINDING_NAME_KHIDTOGGLE = "Anzeigen/ausblenden Fenster",

		Message_Marked = "Markiert als", 
		Message_Unmarked = "Nicht markieren", 
	},
	["es"] = {LOCALE = "ES", --Googletrad
	
		Settings_enable = "Activo",
		Settings_choose = "Seleccione un elemento",
		Settings_control = "Ajustes",
		Settings_warning = "Requiere una recarga de la interfaz.", 
		Settings_showWithInventory = "Mostrar con el inventario",
		Settings_hideEmpty = "Ocultar la interfaz si est\195\161 vac\195\173o",
		Settings_showConsumable = "Mostrar trofeos que son consumibles", 
		Settings_maxCol = "N\195\186mero de disfraces por l\195\173nea",
		Settings_maxRow = "El n\195\186mero m\195\161ximo de l\195\173neas",
		Settings_fixedSize = "Tama\195\177o fijo m\195\161ximo", 
		Settings_tooltipPosition = "Posici\195\179n de la informaci\195\179n sobre herramientas",
		Settings_itemIcon = "Iconos en inventario", 
		Settings_itemIconTip = "Marcos objetos por un icono espec\195\173fico en el inventario", 
		Settings_itemIconColor = "Color del icono", 
		Settings_newItem = "Advertir al descubrir un nuevo disfraz", 
		Settings_newItemTip = "Muestra un mensaje en el centro de la pantalla al bot\195\173n un nuevo disfraz", 
		Settings_sysmessage = "Mostrar mensaje del sistema",
		Settings_positionning = "Posicionamiento",
		Settings_positionningText = "Esta opci\195\179n muestra el fotograma con el fin de elegir su ubicaci\195\179n en la pantalla.\nCuando haya terminado, desactive la opci\195\179n.",
		Settings_keybindText = "|cFF6A00Nota :|r\nTambi\195\169n puede asignar una tecla de acceso directo para mostrar / ocultar la interfaz de forma manual.\nVer Controles/Asignaci\195\179n de teclas/|cFF6A00Khrill|r Hero In Disguise/Mostrar-ocultar la ventana.",

		SI_BINDING_NAME_KHIDTOGGLE = "Mostrar/ocultar la ventana",

		Message_Marked = "Marcado como", 
		Message_Unmarked = "Desmarcar", 
	},
	["fr"] = {LOCALE = "FR",
	
		Settings_enable = "Actif",
		Settings_choose = "Choisir un \195\169l\195\169ment",
		Settings_control = "R\195\169glages",
		Settings_warning = "N\195\169cessite un rechargement de l'interface.", 
		Settings_showWithInventory = "Afficher avec l'inventaire",
		Settings_hideEmpty = "Masquer l'interface si vide",
		Settings_showConsumable = "Afficher les troph\195\169es qui sont consommables", 
		Settings_maxCol = "Nombre de d\195\169guisements par ligne",
		Settings_maxRow = "Nombre de lignes maximal",
		Settings_fixedSize = "Taille maximale fixe", 
		Settings_tooltipPosition = "Position de l'infobulle",
		Settings_itemIcon = "Ic\195\180nes dans l'inventaire", 
		Settings_itemIconTip = "Marquer les objets par un ic\195\180ne sp\195\169cifique dans l'inventaire", 
		Settings_itemIconColor = "Couleur de l'ic\195\180ne", 
		Settings_newItem = "Alerter quand on ramasse un nouveau d\195\169guisement", 
		Settings_newItemTip = "Affiche un message au centre de l'\195\169cran quand on ramasse un nouveau d\195\169guisement", 
		Settings_sysmessage = "Afficher message syst\195\168me",
		Settings_positionning = "Positionnement",
		Settings_positionningText = "Cette option permet d'afficher le cadre afin de pouvoir choisir son emplacement sur l'\195\169cran.\nUne fois termin\195\169, d\195\169sactiver l'option.",
		Settings_keybindText = "|cFF6A00Note :|r\nVous pouvez aussi assigner une touche de raccourci pour afficher/cacher manuellement votre fen\195\170tre.\nVoir dans Commandes/Raccourcis/|cFF6A00Khrill|r Hero In Disguise/Afficher-cacher la fen\195\170tre.",

		SI_BINDING_NAME_KHIDTOGGLE = "Afficher/cacher la fen\195\170tre",

		Message_Marked = "Marquer comme", 
		Message_Unmarked = "D\195\169s\195\169lectionner", 
	}
}