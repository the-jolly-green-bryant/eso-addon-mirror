--	Bindings
ZO_CreateStringId("SI_BINDING_NAME_REPEAT_DIALOG", "Dialog wiederholen")
ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_BODY_HIDDEN", "Zeige/Verberge Haupttext")


--	Options
NTDial_Texts = {
  	optionError = "NTakDialog: Kein spezifisches Icon gefunden. Bitte hinterlasse einen Kommentar beim Addon auf esoui.com und gib folgende Nummer an: #",
	isNeeded	= " muss aktiviert sein",
	doNothing	= "Nichts machen",
	dontUse		= "Nicht verwenden",
	dontDisplay = "Nicht anzeigen",
	choicesAlign = {
		"Links",
		"Zentriert",
		"Rechts",
	},
	optionRepeat 	= "<Bitte zu wiederholen.>",
	optionRestart	= "<Bitte nochmals von Anfang>",
	cat00 = {
		title	= "CHARAKTERÜBERGREIFENDE EINSTELLUNGEN",
	},
	cat0 = {
		title	= "Konversationsverlauf",
		opt0	= "Verlauf im Dialogfenster anzeigen",
		opt0b	= "Display only last reply",
		opt1	= "Den gewählten Optionen einen Präfix voranstellen",
		opt2	= "Namen anzeigen",
		opt3	= "avec saut de ligne",
		optA	= "Verlauf im Chat ausgeben",
	},
	catX = {
		optTextSize	= "Grössenanpassung der Text (0 = Standard)",
		optAlignH	= "Horizontal Ausrichtung",
		optPaddingH	= "Horizontal Innenabstand (in px)",		
		optPaddingV	= "Vertical Innenabstand (in px)",
	},
	cat1 = {
		title	= "Anpassungen der Dialogfenster", -- Optimierungen
		opt1	= "Benutzerdefinierte Dialogfenstergrösse",
		warn1	= "Bei Deaktivierung wird das UI neu geladen um die Standardwerte wiederherzustellen.",
		opt2	= "Breite (in %, ~47 ist Standard)",
		opt3	= "Höhe (in %, 30 ist Standard)",
		opt4	= "Vertikale Verschiebung (in %, 0 ist Standard)",
		opt10	= "Verwende benutzerdefinierten Innenabstand",
		opt11	= "Automatischer Innenabstand je nach Breite",
		opt12	= "Linker Innenabstand (in px, 10 ist Standard)",
		opt13	= "Rechter Innenabstand (in px, 30 ist Standard)",
		opt21	= "Hintergrund Transparenz (in %)",
		opt22	= "Transparenz von Inhalt (in %)",
	},
	cat2 = {
		title	= "Anpassungen der Namen", -- Titel
		opt4	= "Namen bereinigen",
		opt5	= "Verwende alternative Farbe",
	},
	cat3 = {
		title	= "Anpassungen der Text",
		opt11	= "Entferne alle Texte (Zuhören!)",
		opt12	= "Verwende Verzögerungen von ", -- opt20
		opt20	= "Fortlaufende Textanzeige",
		opt21	= "Fenstergrösse erweitern beim Anzeigen von Text",
		opt22	= "Verzögerung vor Start (in ms)",
		opt23	= "Verzögerung pro Zeichen (in ms)",
		opt24	= "Ausmass des Einblende-Effekts (in Zeichen)",
		opt25	= "Wenn Optionstaste gedrückt, sofort alles anzeigen",
		-- desc2	= "Beachte dass der ganze Text sofort angezeigt werden kann wenn die Nummer einer Option gedrückt wird",
	},
	cat4 = {
		title	= "Anpassungen der Optionen",
		optA	= "Sofort anzeigen",
		optB	= "Anzeigen nachdem der Hauptteil eingeblendet ist",
		optC	= "Anzeigen wenn Optionstaste gedrück wird",
		optD	= "Einblendedauer (in ms, 0 ist Standard)",
        opt4	= "“Lebt wohl” Option ausgrauen",
		optR0	= "Eine “Wiederholen” Option hinzufügen",
		warnR0	= "Diese Option funktioniert (vorerst) nur wenn sie mit der Maus angeklickt wird. Wenn die Tastatur verwendet werden soll, kann ein Tastenkürzel unter “Steuerung > Erweiterungen” festgelegt werden.",
		optR1	= "“Wiederholen” Option ausgrauen",
		opt11	= "Icons hinzufügen",
		desc11	= "Vorschau der verwendeten Icons:",
		opt12	= "Leerzeichen nach dem Icon",
		opt21	= "Nummern hinzufügen",
		opt22	= "Nummerierungsstil",
		desc22	= "“x” ist die Nummer. Beispiele: ",
		opt23	= "Leerzeichen nach der Nummerierung",
		opt31	= "Transparenz (in %)",
	},
	cat5 = {
		title	= "Hover-Effekt der Optionen",
		opt1	= "Rahmenbreite (in px, 2 ist Standard)",
		opt2	= "Hintergrund Deckkraft",
		opt3	= "Hintergrund in voller Breite",
	},
	cat6 = {
		title	= "Einstellungen für spezifische Dialoge",
		menu1	= "Bankiers",
		menu2	= "Händler/Handwerker",
		menu3	= "Gildenhändler",
		menu4	= "Stallmeister",
		menu9	= "Beschreibungen",
		menuA	= "Quests", -- TO TRANSLATE
    	opt1	= "Dialoge stumm schalten",
    	opt2	= "Öffne Läden automatisch",
		opt3	= "Schnellere Textanzeige",
		opt4	= "Sofort anzeigen",
		optA1	= "Quests automatisch öffnen",
		optA2	= "Quests automatisch annehmen",
		optA3	= "Quests autoamtisch abgeben",
	},
}