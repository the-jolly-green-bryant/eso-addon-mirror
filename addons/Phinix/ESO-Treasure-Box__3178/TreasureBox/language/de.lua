local TBoxAddon = _G['TBoxAddon']
local pTC = TBoxAddon.TColor
TBoxAddon.DB = {}
TBoxAddon.AT = {}
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German
-- (Requires human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- General
	L.TBoxAddon_SEARCHBOX				= "Suche nach Schätzen mit Namen."
	L.TBoxAddon_CLOSE					= "Schließen Treasure Box"
	L.TBoxAddon_TITLE					= "Treasure Box"
	L.TBoxAddon_RECENT					= "Kürzlich gefunden:"
	L.TBoxAddon_FAVZONE					= "Obere Zone:"
	L.TBoxAddon_UPDATE1					= "[TBox]: Treasure Box-Datenbank aktualisiert."
	L.TBoxAddon_UPDATE2					= "[TBox]: Bitte /reloadui zum Vervollständigen."
	L.TBoxAddon_UPDATE3					= "[TBox]: Bitte haltet euch bereit..."
	L.TBoxAddon_NOCATEGORY				= "Unkategorisiert"
	L.TBoxAddon_RESETSEARCH				= "Klicken Sie auf die Schaltfläche, um die Textsuche zurückzusetzen.\n\n"..pTC("FFFFFF", "NOTIZ: ").."Andere Filter werden beibehalten."
	L.TBoxAddon_TFOUNDOFF				= pTC("00FF00", "Nur gefundene anzeigen").." ist"..pTC("FFFFFF", " AN").."\n\nKlicken Sie hier, um ALLE Schätze anzuzeigen, unabhängig davon, ob Sie sie gefunden haben oder nicht."
	L.TBoxAddon_TFOUNDON				= pTC("00FF00", "Nur gefundene anzeigen").." ist"..pTC("FFFFFF", " AUS").."\n\nKlicken Sie hier, um nur Schätze anzuzeigen, die Sie bei einem Ihrer Charaktere gefunden haben."
	L.TBoxAddon_RESETFILTER				= "Filter zurücksetzen"
	L.TBoxAddon_RQUALITYS1				= "Nur anzeigen "
	L.TBoxAddon_RQUALITYS2				= " und hochwertigere Produkte in der Liste Kürzlich gefunden."
	L.TBoxAddon_UPDATING				= "[TBox]: Treasure Box datenbankaktualisierung, bitte starten Sie nicht neu..."

-- Navigation
	L.TBoxAddon_TFOUND					= "Schatz gefunden:"
	L.TBoxAddon_QUALITYHEAD				= "Schatzqualität:"
	L.TBoxAddon_TIMEHEAD				= "Zeit gefunden:"
	L.TBoxAddon_TIMEDAYS1				= "Letzte"
	L.TBoxAddon_TIMEDAYS2				= "Tage"
	L.TBoxAddon_ANY						= "Alle"
	L.TBoxAddon_ALLTYPES				= "Kategorie: Alle"
	L.TBoxAddon_ALLZONES				= "Gefunden in: Alle"
	L.TBoxAddon_ANYFOUND				= "Gefunden von: Alle"
	L.TBoxAddon_QUALITYS				= "Zeigen Qualität: "
	L.TBoxAddon_QUALITY1				= "Normal"
	L.TBoxAddon_QUALITY2				= "Fine"
	L.TBoxAddon_QUALITY3				= "Superior"
	L.TBoxAddon_QUALITY4				= "Epic"
	L.TBoxAddon_QUALITY5				= "Legendary"
	L.TBoxAddon_FINZONES				= "In Zonen gefunden:"
	L.TBoxAddon_LFOUNDIN				= "Zuletzt gefunden in: "
	L.TBoxAddon_LFOUNDBY				= "Zuletzt gefunden von: "
	L.TBoxAddon_FOUNDON					= "Zuletzt gefunden am: "
	L.TBoxAddon_TOTALF					= "Insgesamt gefunden: "
	L.TBoxAddon_NEVER					= "Niemals"
	L.TBoxAddon_NONE					= "Keiner"
	L.TBoxAddon_UNKNOWN					= "Unbekannt"
	L.TBoxAddon_SALPHA					= "Sortieren Sie alphabetisch"
	L.TBoxAddon_SFOUND					= "Sortieren nach Nummer gefunden"

-- Settings
	L.TBoxAddon_GOPTS					= "Allgemeine Optionen"
	L.TBoxAddon_CHARALPHA				= "Zeichenliste sortieren"
	L.TBoxAddon_CHARALPHAT				= "Aktiviert zeigt die Liste der Zeichen alphabetisch an. Andernfalls wird die Charakterauswahlreihenfolge des Spiels verwendet.\n\n"..pTC("FFFFFF", "NOTIZ: ").."Das Spiel gibt nur die Reihenfolge der Charaktererstellung zurück. Es verfolgt keine manuell neu geordneten Zeichen."
	L.TBoxAddon_USTIME					= "12-Stunden-Zeit"
	L.TBoxAddon_USTIMET					= "Wenn aktiviert, werden Zeitstempel für zuvor gefundene Schätze im 12-Stunden-Format mit am/pm nach der Uhrzeit angezeigt. Ausschalten, um in 24 Stunden (Militärzeit) zu zeigen."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k, v in pairs(TBoxAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function TBoxAddon:GetLanguage() -- set new language return
		return L
	end
end
