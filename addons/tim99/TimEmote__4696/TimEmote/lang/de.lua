--                v 1.7.0               --
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

TimEmote = TimEmote or {}
local TE = TimEmote
TE.Lang = TE.Lang or {}

TE.Lang["de"] = {
		LOCALE = "DE",

		Settings_control = "Einstellungen",
		Settings_title1 = "Bewegliches Fenster",
		Settings_description1 = "Erlaubt das Verschieben des TimEmote-Fensters.",
		Settings_displaySize = "Anzeigegröße",
		Settings_displaySizeTip = "Ändert Schriftgröße, Zeilenhöhe und Breite der Emote-Listen.",
		DisplaySize_compact = "Kompakt (14)",
		DisplaySize_normal = "Normal (15)",
		DisplaySize_large = "Groß (16)",
		Settings_contrast = "Hintergrundkontrast",
		Settings_contrastTip = "Bestimmt, wie kräftig die Hintergründe der Header und Emote-Listen erscheinen.",
		Settings_title3 = "Deckkraft",
		Settings_description3 = "Ändert die Deckkraft des TimEmote-Fensters.",
		Settings_warning = "Zum Anwenden muss die Benutzeroberfläche neu geladen werden.",
		Settings_group = "Gruppennamen",
		Settings_groupItem = "Gruppe",
		Settings_groupItemTip = "Name dieser Gruppe",
		Settings_groupNoname = "Unbenannt",
		Settings_groupDefault = "Favoriten",
		Settings_groupNewBtn = "Neu",
		Settings_groupNewBtnTip = "Eine neue Gruppe hinzufügen",
		Settings_groupDeleteBtn = "Löschen",
		Settings_groupDeleteBtnTip = "Diese Gruppe löschen",
		Settings_groupDeleteWarning = "Diese Gruppe und alle darin enthaltenen Favoriten werden gelöscht.",
		UI_list = "Liste",
		Message_notSelGroup = "Wähle zuerst eine Gruppe mit einem Linksklick auf ihre Überschrift aus.",
		Message_noEmote = "In dieser Gruppe ist kein Emote verfügbar.",
		Message_lastGroup = "Mindestens eine Gruppe muss erhalten bleiben.",
		Tooltip_playRandom = "Zufälliges Emote abspielen",
		Tooltip_moveDown = "Nach unten verschieben",
		Tooltip_moveUp = "Nach oben verschieben",
		Tooltip_listHeader = "Emote:\nLinksklick: abspielen\nShift + Linksklick: zur aktiven Gruppe hinzufügen/entfernen\nDoppelklick: nächste Farbe",
		Tooltip_groupHeader = "Header:\nLinksklick: Gruppe aktivieren\n--------------------\nEmote:\nLinksklick: abspielen\nShift + Linksklick: entfernen\nDoppelklick: nächste Farbe",
	}
