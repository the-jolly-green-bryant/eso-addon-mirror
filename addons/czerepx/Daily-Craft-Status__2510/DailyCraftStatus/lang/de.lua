-- German localization

local _addon = _G["DailyCraftStatus"]

-- these strings need to match game strings 
_addon.langQuestInfo = 
{
	["deliver"] = "Beliefert",
	["craft"] = { "Stellt", "Herstell" }, 
	["material"] = { "material", "zutaten" },
	["questnames"] = {
		--quest name unique substring followed by status character (or any string actually) 
		{"schmied","M"}, --Metal
		{"schneid","T"}, --Tuch
		{"schrein","H"}, --Holz
		{"schmuck","S"}, --Schmuck
		{"alchem","A"},
		{"verzaub","V"},
		{"versorg","K"}  --Kochen
	}	
}	

-- addon strings for translation
_addon.translation =
{
	["Lock"] = "Sperren",
	["Save"] = "Speichern",
	["Unlock"] = "Entsperren",
	["Toggle Stock"] = "Material Lager Umschalten",
	["Toggle Raw Stock"] = "Rohstoff Lager Umschalten",
	["Toggle Surveys"] = "Fundberichte Umschalten",
	["Always On"] = "Immer Sichtbar",
	["Auto-hide"] = "Autom. Verstecken",
	["Mail Stock"] = "Mail im Lager Einberechnen",
	["Loot Mail"] = "Loot Mietling Mail",
	["Pick Up Survey"] = "Der Bank Entnehmen",
	["Clear Survey Pick List"] = "Auswahlliste Leeren",
	["Settings"] = "Einstellungen",
	["Alts Status"] = "Andere Charaktere",

--options menu
	["Account Settings"] = "Account Einstellungen",
	["Low Threshold"] = "Geringe Anzahl Schwellenwert (Questgegenstände)",
	["Low Quantity"] = "Geringe Anzahl (Questgegenstände)",
	["Auto-save position"] = "Position Autom. speichern für jeden Charakter",
	["Use Icons"] = "Symbole für den Queststatus",
	["Low Stock Warn"] = "Geringe Material Anzahl Warnung",
	["Show Marker After Daily Reset"] = "Zeige Marker nach täglichem Reset",
	["Show Marker For Riding Training"] = "Zeige Marker für Reittraining",
	["Track Alts Data"] = "Zusätzliche Daten für Charaktere",
	["Preserve Icon in UI mode"] = "Dock-Symbol sichtbar halten (UI)",
	["Keep Visible On Warnings"] = "Bei Warnungen sichtbar halten",
	["Separate Backpack Quantity"] = "Getrennte Anzahl für Materialien im Rucksack",
	["Show in HUD Only"] = "Nur in der Hauptoberfläche anzeigen",
	["Character Settings"] = "Charakter Einstellungen",
	["Show Stock"] = "Zeige bearbeitetes Material Lager",
	["Show Raw Stock"] = "Zeige Rohstoff Lager",
	["Show Surveys"] = "Zeige Fundberichte",
	["Show Inventory Space"] = "Zeige Freien Rucksackraum",
	["Always Visible"] = "Immer sichtbar",
	["Appearance"] = "Aussehen",
	["Single Row Display"] = "Einzelne Zeile Anzeige",
	["Align To Bar Center"] = "An der Leistenmitte ausrichten",
	["UI Scale"] = "Schriftgröße",
	["Background Style"] = "Hintergrundstil",
	["Share Appearance"] = "Gleiches Aussehen für alle Charaktere",
	["Low Mat Threshold"] = "Geringe Material Anzahl Schwellenwert",
	["Own Low Stock"] = "Eigene Geringe Material Anzahl",
	["Find Item"] = "Finde (im Lager und in Handwerks-Materialien)",
	["Search Results"] = "Ergebnisse",
	["Low Stock"] = "Geringe Anzahl (optional - Mat. wird unterstrichen)",
	["High Stock"] = "Hoche Anzahl (optional - Mat. wird versteckt)",
	["Add Item"] = "Gegenstand Hinzufügen",
	["Custom Materials"] =  "Benutzerdefinierte Materialien",
	["Custom Materials (All Characters)"] = "Benutzerdef. Materialien (Alle Char.)",
	["Item"] = "Gegenstand",
	["Custom Materials Help"] =
			"Suche nach Gegenstände unten, oder du kannst z.B. den \'Im Chat anzeigen\' Befehl benutzen, um den ItemLink im Chat anzuzeigen, und dann markierst du ihn dort und kopierst ihn in die Zwischenablage (STRG+C) und fügst ihn hier ein. " ..
			"Du kannst auch eine nummerische itemId benutzen, oder deinen eigenen Text. Um einen Gegenstand zu löschen, leere einfach das Textfeld."
			,
	["Survey Statistics"] = "Fundberichte Statistik",
	["Survey Statistics Help"] = 
			"Definiere deine eigenen Statistiken mit den folgenden Ziffern, in beliebiger Reihenfolge.\n" ..
			"0 - Fundberichte insgesamt, 1 - Bester nach Ort, 2 - Zweitbester, 3 - Dritbester, " ..
			"4 - Bester in Kargstein, 5 - Fundberichte im Rucksack, 6 - Kargstein insgesamt\n"..
			"z.B.: benutze 50 um nur den Rucksack und die Gesamtanzahl zu sehen."
			,
	["Display Pattern"] = "Anzeige Muster",
	["Research Tracking"] =  "Verfügbare Analyseplätze",
}