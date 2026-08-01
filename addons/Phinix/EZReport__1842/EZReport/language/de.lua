local EZReport = _G['EZReport']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Labels
L.EZReport_GOpts				= "Globale Optionen"
L.EZReport_TIcon				= "Zielvorgabe anzeigen"
L.EZReport_DTime				= "Zielzeit anzeigen"
L.EZReport_RCooldown			= "Abklingzeit für Berichte"
L.EZReport_RCooldownM			= "EZReport hat bereits heute berichtet: Die Abklingzeit für Berichterstellung ist aktiviert."
L.EZReport_OutputChat			= "Chatnachrichten anzeigen"
L.EZReport_12HourFormat			= "12 Stunden Zeitformat"
L.EZReport_IncPrev				= "Vorherige Berichtsdaten einbeziehen"
L.EZReport_DCategory			= "Standardkategorie"
L.EZReport_DReason				= "Standardgrund"
L.EZReport_Reset				= "Berichtsverlauf zurücksetzen"
L.EZReport_Clear				= "KLAR"

-- Target Reported Colors
L.EZReport_RColorS				= "Ziel gemeldete Farben"
L.EZReport_RColor1				= "Generische Farbe"
L.EZReport_RColor2				= "Falsche Namensfarbe"
L.EZReport_RColor3				= "Giftige Farbe"
L.EZReport_RColor4				= "Betrug Farbe"
L.EZReport_RColor5				= "Alt gemeldete Farbe"

-- Addon Setting Tooltips
L.EZReport_TIconT				= "Zeigen Sie ein Symbol an, das Ziele angibt, die Sie zuvor gemeldet haben. Entspricht den Symbolen, die beim Auswählen einer Kategorie im Berichtsfenster angezeigt werden."
L.EZReport_DTimeT				= "Zeigt die Uhrzeit an, zu der ein Ziel zuletzt neben dem Zielberichts-Symbol gemeldet wurde. Wenn das aktuelle Zeichen nie gemeldet wurde, wird die letzte Zeit angezeigt, zu der ein beliebiges Zeichen in seinem Konto gemeldet wurde."
L.EZReport_RCooldownT			= "Wenn diese Option aktiviert ist, wird die Hotkey-Berichterstellung verhindert, wenn Sie das Ziel bereits heute gemeldet haben. Dies ist hilfreich, wenn Sie große Gruppen von Bots melden, damit Sie die Keybind spamieren können, und das Berichtssystem wird nur aktiviert, wenn Sie ein Ziel haben, das Sie noch nicht gemeldet haben."
L.EZReport_OutputChatT			= "Zeigt informative Nachrichten zu verschiedenen Addon-Funktionen im Chat an."
L.EZReport_12HourFormatT		= "Wenn diese Option aktiviert ist, verwenden die generierten Zeitstempel das 12-Stunden-Zeitformat (Stunde plus AM oder PM). Wenn Sie diese Option deaktivieren, wird das 24-Stunden-Format 'Militärzeit' angezeigt."
L.EZReport_IncPrevT				= "Enthält Datums-, Uhrzeit- und Namensdaten über frühere Berichte dieses Charakters oder bekannte Änderungen beim Senden eines Berichts."
L.EZReport_DCategoryT			= "Wählen Sie die Standardunterkategorie aus, die beim Öffnen des Berichtsfensters automatisch ausgewählt werden soll."
L.EZReport_DReasonT				= "Fügen Sie den ausgewählten Grund in den Abschnitt 'Benutzerdefinierte Details' des Berichtsfensters ein. Die Option Manuell (Standard) soll diese Option leer lassen, damit Sie sie manuell eingeben können."
L.EZReport_ResetT				= "Lösche die gesamte Datenbank der zuvor gemeldeten Charaktere und Konten."
L.EZReport_ResetM				= "Die EZReport-Datenbank wurde zurückgesetzt."

-- Category List
L.EZReport_CatList1				= "Schlechter Name"
L.EZReport_CatList2				= "Belästigung"
L.EZReport_CatList3				= "Betrug"
L.EZReport_CatList4				= "Andere"
L.EZReport_CatList5				= "Keine (Standard)"

-- Reason List
L.EZReport_ReasonList1			= "Botting"
L.EZReport_ReasonList2			= "Ausnutzen"
L.EZReport_ReasonList3			= "Belästigung"
L.EZReport_ReasonList4			= "Manuell (Standard)"

-- Chat List
L.EZReport_CReason1				= "Allgemeiner Bericht"
L.EZReport_CReason2				= "Schlechter Name"
L.EZReport_CReason3				= "Toxisches Verhalten"
L.EZReport_CReason4				= "Betrug"

-- Chat Strings
L.EZReport_RepT					= "Berichtet:"
L.EZReport_RepC					= "Gemeldeter charakter:"
L.EZReport_Unkn					= "unbekanntes konto"
L.EZReport_Now					= "jetzt:"
L.EZReport_Char					= "charakter:"
L.EZReport_For					= "zum:"
L.EZReport_NoMatch				= "Keine Treffer gefunden."

-- Info Panel
L.EZReport_RAcct				= "Berichtskonto: "
L.EZReport_RAlts				= "Zuvor gemeldete Alts: "

-- General Strings
L.EZReport_RLast				= "Letztes Spielerziel melden"
L.EZReport_RHistory				= "Zielberichtshistorie"
L.EZReport_ROpen				= "Hauptfenster öffnen"
L.EZReport_Reason				= "Grund (optional):"
L.EZReport_CName				= "Charaktername:"
L.EZReport_AName				= "Kontobezeichnung:"
L.EZReport_MLoc					= "Karte:"
L.EZReport_Coords				= "Coords:"
L.EZReport_Time					= "Terminzeit:"
L.EZReport_CButton				= "Klar"
L.EZReport_Today				= "Heute"
L.EZReport_Updated				= "Die EZReport-Datenbank wurde aktualisiert."
L.EZReport_AccUnavail			= "Konto nicht verfügbar"
L.EZReport_LocUnavail			= "Standort nicht verfügbar"
L.EZReport_Wayshrine			= "Der Wegschrein von"
L.EZReport_Accounts				= "Berichte nach Konto"
L.EZReport_Characters			= "Berichte nach Charakter"
L.EZReport_Locations			= "Berichte nach Standort"
L.EZReport_Generated			= "Generiert: EZReport von Phinix"
L.EZReport_Previous				= "Zuvor berichtet:"
L.EZReport_Confirm				= "Löschen bestätigen"
L.EZReport_Cancel				= "Stornieren"
L.EZReport_Delete				= "Löschen"

-- Tooltip strings
L.EZReport_TTShow				= "Klicken Sie hier, um die Berichtszusammenfassung anzuzeigen."
L.EZReport_TTClick				= "Klicken Sie in das Ergebnisfeld und drücken Sie:"
L.EZReport_TTSelect1			= "Strg+A"
L.EZReport_TTSelect2			= " zum alle auszuwählen."
L.EZReport_TTCopy1				= "Strg+C"
L.EZReport_TTCopy2				= " zum Kopieren."
L.EZReport_TTPaste1				= "Strg+V"
L.EZReport_TTPaste2				= " zum Einfügen an anderer Stelle."
L.EZReport_TTAccounts			= "Wechseln Sie zum Anzeigen von Konten."
L.EZReport_TTCharacters			= "Wechseln Sie zum Anzeigen von Zeichen."
L.EZReport_TTEMode				= "Wechseln Sie in den Datenbankbearbeitungsmodus."
L.EZReport_TTRMode				= "Wechseln Sie in den Textberichtmodus."
L.EZReport_TTCEntry1			= "Linksklick"
L.EZReport_TTCEntry2			= " um Zeicheneinträge anzuzeigen."
L.EZReport_TTAEntry1			= "Umschalt+Linksklick"
L.EZReport_TTAEntry2			= " um Kontoeinträge anzuzeigen."
L.EZReport_TTDEntry1			= "Rechtsklick"
L.EZReport_TTDEntry2			= " um den ausgewählten Eintrag zu löschen."


------------------------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k, v in pairs(EZReport:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function EZReport:GetLanguage() -- set new locale return
		return L
	end
end
