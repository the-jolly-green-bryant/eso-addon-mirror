--	Bindings
ZO_CreateStringId("SI_BINDING_NAME_NTLOOT_OVERRIDE_SMART", "Schlaues Stehlen übersteuern")
ZO_CreateStringId("SI_BINDING_NAME_NTLOOT_TOGGLE_AUTOLOOT", "Autom. Einsammeln umschalten")


--	Options
NTLnS_Texts = {
	choices = {
		hPosition = {
			"Links",
			"Zentriert",
			"Rechts",
		},
		vPosition = {
			"Oben",
			"Mitte",
			"Unten",
		}
	},
	actions = {
		take	= "Einfangen",
		use		= "Benutzen",
	},
	insects = {
		"Schmetterling",
		"Fackelkäfer",
		"Wespe",
		"Fleischfliegen",
		"Libelle",
		"Netchkalb",
		"Zunderfliege",
		"Seths Dovahviin",
	},
	seats = {
		"Sitzgelegenheit",
	},
	isNeeded	= " muss aktiviert sein",
	align		= "Ausrichtung",
	alpha		= "Deckkraft",
	cat00 = {
		title	= "CHARAKTERÜBERGREIFENDE EINSTELLUNGEN",
	},
	cat0 = {
		title	= "BEVORZUGTE EINSAMMELN EINSTELLUNGEN",
		desc0	= "Diese Einstellungen übersteuern die regulären Einsammeln Einstellungen.",
		opt1	= "Immer alles einsammeln",
		opt2	= "Immer alles stehlen",
	},
	cat1 = {
		title	= "OPTIMIERUNGEN BEIM EINSAMMELN",
		opt1	= "Kein autom. Einsammeln bei wenig freiem Inventar",
		warn1	= "Die “Immer alles einsammeln” Spielwelt Einstellung wird dynamisch ein- und ausgeschaltet.",
		opt1b	= "Unteres Limit für Inventarplatz",
		opt11	= "Verberge Interaktion bei leerem Behälter",
		opt12	= "Verberge Interaktion bei Insekten",
	},
	cat2 = {
		title	= "OPTIMIERUNGEN BEIM STEHLEN",
		opt1	= "Verwende “Schlaues Stehlen”",
		opt1b	= "Übersteuern durch doppeltes Drücken (in ms)",
		warn1	= "Die “Immer alles stehlen” Spielwelt Einstellung wird dynamisch ein- und ausgeschaltet.",
		desc1	= "“Schlaues Stehlen” kann ungewollte oder versehentliche Diebstähle verhindern.\nFalls du nicht vollständig verborgen bist, wird das Bestehlen von Personen verhindert, Behälter werden nur geöffnet aber nicht geplündert und herumliegenden Gegenständen werden nicht direkt eingesammelt.\nAnmerkung: Ein Tastenkürzel zum Übersteuern kann unter Steuerung gesetzt werden (gedrückt halten zum Übersteuern).",
		menu	= "Erweiterte Einstellungen",
			desc10	= "Spezifische Aktionen auswählen wo “Schlaues Stehlen” deaktiviert sein soll.\nSchieb die Schuld nicht auf mich wenn du erwischt wirst!",
			opt10	= "Verwende erweiterte Einstellungen",
			opt11	= "“Schlaues Stehlen” für Behälter",
			opt11b	= "“Schlaues Stehlen” fürs Schlösserknacken",
			opt12	= "”Schlaues Stehlen” für herumliegende Gegenstände",
			opt13	= "“Schlaues Stehlen” fürs Bestehlen von Personen",
		opt2	= "über Tastenkürzel wenn Stehlen verhindert wird", -- [icon] ..
		opt2b	= "Alternative Position für ", -- .. icon
		opt3	= "Zeige Timer an wenn ein Kopfgeld aktiv ist",
		opt4	= "Verhindere Sitzen Aktion beim Schleichen",
	},
	cat3 = {
		title	= "INFORMATIONSANZEIGE", -- ZUSÄTZLICHE INFORMATIONS ANZEIGE
		sub0	= "IM INVENTAR",
			opt01	= "Ersetze “Inventarplatz” mit ", -- .. [icon]
			opt02	= "Dem Inventar ein “Gestohlen” Filter hinzufügen",
			opt03	= "Skip a line (compatibility with other addons)",
			-- opt02tt = "Benötigt die Biliothek \'LibFilters 3.0\' installiert und aktiviert!",
		sub1	= "IN PLÜNDER FENSTER",
		sub2	= "INHALT",
			opt21	= "Freie Inventarplätze …",
			opt21b	= "Anzahl gestohlener Gegenstände", -- 
			opt22	= "Verkaufte Gegenstände …",
			opt23	= "Geschobene Gegenstände …",
			opt223	= "Gruppiere Verkaufte und Geschobene",
			optRed	= "… in rot wenn weniger übrig als:",
			opt24	= "Zeit bis Hehler-Limiten zurückgesetzt werden",
	},
}