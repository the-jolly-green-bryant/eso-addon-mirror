--	Bindings
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAP",			"Schulterseite tauschen")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAP_X",		"Schulterseite tauschen (schnell)")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAPCENTER",	"Tauschen/Zentrieren")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAPCENTER_X",	"Tauschen/Zentrieren (schnell)")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_CENTER",		"Zentriere Kamera")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_CENTER_X",		"Zentriere Kamera (schnell)")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_ALT_ALL",		"Alt. Kamerawerte")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_ALT_DIST",		"Alt. Distanz")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_ALT_FOV",		"Alt. Sichtfeld")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SIEGE",		"Belagerungskamera umschalten")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC0",		"Kamera: Bevorzugt")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC1",		"Kamera: Statisch 1")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC2",		"Kamera: Statisch 2")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC3",		"Kamera: Statisch 3")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_TOGGLE_CHAT",	"ON/OFF - Chatten Kamera")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_TOGGLE_CRAFT",	"ON/OFF - Handwerksstation Kam.")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_TOGGLE_LOCKP",	"ON/OFF - Schlösserknacken Kam.")


--	Options
NTCam_Texts = {
	cat0 = {
		title	= "CHARAKTERÜBERGREIFENDE EINSTELLUNGEN",
	},
	cat1 = {
		title	= "BEVORZUGTE KAMERA",
		desc1	= "Diese Einstellungen übersteuern die regulären Kamera Einstellungen.",
		opt1	= "Kameraentfernung (0 für Egoperspektive)",
    	opt1b	= "Sichtfeld",
		opt2	= "Schulterseite",
		choices = {
			"Zentriert",
			"Links",
			"Rechts",
		},
		opt3	= "Horizontale Position", --  wenn auf Schulterseite
		opt3b	= "Horizontale Verschiebung (statische)",
		warn3b	= "Der Wert dieser Einstellung wird nicht durch Interaktionen/Ereignisse modifiziert.",
		opt4	= "Vertikale Verschiebung",
		opt5	= "Vertikale Verschiebung (zentriert)",
		warn5	= "Diese Einstellung wird nur berücksichtigt wenn mit der vorhandenen Tastenbelegung in die Mitte zentriert wird.",
		--
		desc11	= "Nach einer “Interaktion” oder einem “Ereignis” die vorherigen Kamera Parameter wiederherstellen. Ausser wenn die Wiederherstellung der bevorzugten Kamera aktiviert ist:",
		opt11	= "Stattdessen bevorzugte Kamera wiederherstellen",
		--
	},
	cat2 = {
		title0	= "ALTERNATIVE KAMERAS",
		desc0	= "Sie können nur mit einem Tastenkürzel gewechselt werden.",
		title1	= "ALTERNATIVE WERTE",
		desc1	= "Diese alternativen Kamerawerte können die der bevorzugten Kamera ersetzen.",
		title2	= "STATISCHE KAMERAS",
		desc2 	= "Du kannst zu diesen Kameras nur mit einem Tastenkürzel wechseln.\nDiese Kameras werden durch Interaktionen oder Ereignisse NICHT verändert.", -- \nWeiter haben diese Kameras auch einen erweiterten horizontalen Wertebereich für die Positionierung.",
		opt0	= "In Chat ausgeben wenn Kamera gewechselt wird",
		msg0	= "Wechsel zur statischen Kamera #",
		menuX	= "Statische Kamera ",
		opt1	= "Kameraentfernung",
		opt2	= "Sichtfeld",
		opt3	= "Horizontale Position",
		opt3b	= "Horizontale Verschiebung",
		opt4	= "Vertikale Verschiebung",
	},
	menuX = {
		opt0	= "Verhindere Änderungen an Standardkamera",
		warn1	= "Du musst “Verhindere Kameränderungen bei Interaktionen” verwenden damit es funktioniert.",
		opt1	= "Vorlage",
		choices = {
			"Nichts machen", -- old: Keine ( aucun )
			"Zentriert in der dritten Person",
			"Wechsel zu Egoperspektive",
			"Wechsel zur dritten Person",
			"Abstand nehmen",
			"Fokussieren",
			"Benutzerdefiniert",
		},
		opt2	= "Ändere Entfernung …",
		opt2b	= "Ändere Sichtfeld …",
		opt3	= "Ändere horizontale Position …",
		opt4	= "Ändere vertikale Position …",
		opt5	= "Verzögerung um Kamera wiederherzustellen (x 0.1s)",
		opt6	= "Smoothing",	-- TODO
		to		= "… um:",
		opt10	= "Keine andere Änderung während ", -- .. Menu title
	},
	cat3 = {
		title	= "INTERAKTIONS KAMERAS", -- "ÄNDERUNGEN DER KAMERA BEI INTERAKTIONEN",
		desc1	= "Verwalte wie Interaktionen die bevorzugte Kamera beeinflussen",
		menu1 = {
			title	= "Chatten",
		},
		menu2 = {
			title	= "Handwerksstation",
		},
		menu3 = {
			title	= "Monturtisch",
		},
		menu4 = {
			title	= "Schlösserknacken",
		},
	},
	cat4 = {
		title	= "EREIGNIS-GESTEUERTE KAMERAS", -- "EREIGNISBASIERTE ÄNDERUNGEN DER KAMERA",
		desc1	= "Verwalte wie Ereignisse die bevorzugte Kamera beeinflussen.",
		menu0 = {	-- TODO
			title	= "while moving",
			opt1	= "Output speed to chat",
			opt2	= "Move / Sprint threshold",
			desc1	= "When the movement speed is above the threshold (e.g. while sprinting), the below settings can override the above ones.",
		},
		menu1 = {
			title	= "auf Reittier",
		},
		menu2 = {
			title	= "schleichend",
		},
		menu3 = {
			title	= "beim Waffe ziehen/verstauen",
			desc1	= "Die Waffe ziehen/verstauen Ereignisse werden nur mit der Tastenbelegung ausgelöst.\n(Der Einsatz von Fertigkeit löst dieses Ereignis leider nicht aus.)\nUntenstehende Einstellung kann verwendet werden um bei Kampfbeginn “Waffe ziehen” auszulösen.",
			opt1	= "Kampfbeginn löst “Waffe ziehen” aus",
		},
		menu4 = {
			title	= "im Kampf",
			opt1	= "Auto-sheath weapon after combat", -- TODO
		},
		menu5 = {
			title	= "als Werwolf",
			opt1	= "Kameraentfernung auf Minimum als Werwolf",
		},
	}
}