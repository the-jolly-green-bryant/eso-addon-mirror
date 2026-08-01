if B1UI == nil then B1UI = {} end

local localization_strings = {
		SI_B1UI_ADDON_NAME = "Notizbuch 1",
		SI_B1UI_AUTHOR = "Bloodspill",
		SI_B1UI_VERSION_NUM = "|c00FF003.2|r",
			
		-- Settings Panel
		SI_B1UI_DESCRIPTION_INFO = "Ein Virtuelles Notizbuch.",
		
		SI_B1UI_HEADER_GENERAL = "Allgemeine Einstellungen",
		
		SI_B1UI_SHOWTITLE_LABEL = "Titel anzeigen",
		SI_B1UI_SHOWTITLE_TOOLTIP = "Zeigt den Titel des Buches.",		
		
		SI_B1UI_TITLE_LABEL = "Buchtitel",		
		SI_B1UI_TITLE_TOOLTIP = "Ändert den Titel des buchs.",
		
		SI_B1UI_COLOR_LABEL = "buchen Farbe",
		SI_B1UI_COLOR_TOOLTIP = "Ändert die Farbe des Buchs.",
		
		SI_B1UI_DIALOG = "Bestätigungsdialoge",
		SI_B1UI_DIALOG_TOOLTIP = "Ein-/Ausschalten Bestätigungsdialoge",
		
		SI_B1UI_LOCK_LABEL = "Position sperren",
		SI_B1UI_LOCK_TOOLTIP = "Das ermöglicht es dir, das Notizbuch an Stelle zu fixieren, damit es nicht verschoben werden kann.",	
		
		SI_B1UI_BUTTON_LABEL = "Chat Button einblenden",
		SI_B1UI_BUTTON_TOOLTIP = "Fügt eine Schaltfläche im Chat-Fenster zu öffnen/schließen du das Buch.",

		SI_B1UI_OFFSETMAX_LABEL = "Offset Maximierte Chat Button",
		SI_B1UI_OFFSETMAX_TOOLTIP = "Offsets die Schaltfläche in der maximierten Chat-Fenster.",
		
		SI_B1UI_OFFSETMIN_LABEL = "Offset Minimierte Chat Button",
		SI_B1UI_OFFSETMIN_TOOLTIP = "Offsets die Schaltfläche in der minimiert Chat-Fenster .",
		
		SI_B1UI_WARNING = "Das Setzen dieser Einstellung führt zu einem Ladebildschirm.",		
		
		-- UI Panel	
		SI_B1UI_CLOSEBUTTON_TOOLTIP = "Schliesse das Buch.",
		
		SI_B1UI_RUNBUTTON_TOOLTIP = "Führen du diese Seite als Lua-Script.",		

		SI_B1UI_DELETEBUTTON_TITLE = "Seite löschen",
		SI_B1UI_DELETEBUTTON_MAINTEXT = "Wollen du, um diese Seite zu löschen?",
		SI_B1UI_DELETEBUTTON_TOOLTIP = "Löschen du diese Seite.",
		
		SI_B1UI_NEWBUTTON_TITLE = "Neue Seite",
		SI_B1UI_NEWBUTTON_MAINTEXT = "Wollen du eine neue Seite erstellen?",
		SI_B1UI_NEWBUTTON_TOOLTIP = "Erstellen du eine neue Seite.",
		
		SI_B1UI_SAVEBUTTON_TITLE = "Seite speichern",
		SI_B1UI_SAVEBUTTON_MAINTEXT = "Wollen du Änderungen an der Seite zu speichern?",
		SI_B1UI_SAVEBUTTON_TOOLTIP = "Speichern du die Änderungen auf dieser Seite gemacht.",
		
		SI_B1UI_UNDOPAGE_TITLE = "Undo Seite",
		SI_B1UI_UNDOPAGE_MAINTEXT = "Möchten du alle Änderungen an dieser Seite rückgängig zu machen? Es wird zurück zum letzten zu speichern.",
		SI_B1UI_UNDOBUTTON_TOOLTIP = "Rückgängig Änderungen an dieser Seite gemacht.",
		
		SI_B1UI_INFORMATION_TOOLTIP = "Befehle:\n|c00FF00/nb1|r schaltet das Fenster ein/aus.\n|c00FF00/nb1s|r schaltet die Einstellungen ein/aus.\n|c00FF00/rl|r lädt die Benutzerschnittstelle.",
		
		SI_B1UI_YES_LABEL = "Ja",
		SI_B1UI_NO_LABEL = "Nein",

		-- Controls Panel
		SI_B1UI_KEYBIND_LABEL = "Notizbuch 1",
	}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end