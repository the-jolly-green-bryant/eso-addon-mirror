local L = {}

L.CaroAM_LocationDropdown = "Ort"
L.CaroAM_LocationAddCurrent = "Aktuellen Ort hinzufügen"
L.CaroAM_EnemyDropdown = "Gegnernamen"
L.CaroAM_EnemyRecordNames = "Begegnungen aufzeichnen"
L.CaroAM_EnemyAddNameDiag = "Gib bitte den exakten Namen des Gegners ein:"
L.CaroAM_EnemyAddName = "Namen hinzufügen"
L.CaroAM_EnemyRemoveName = "Namen entfernen"
L.CaroAM_OnlyAsGroupLeader = "Nur als Gruppenanführer aktivieren"
L.CaroAM_OnlyAsGroupLeaderTT = "Aktiviere diese Einstellung, wenn das Addon in Gruppen nur als Gruppenanführer Zielmarkierungen setzen soll."
L.CaroAM_OnlyTrialsAndDungeons = "Diese Funktion ist nur für Arenen, Verliese und Prüfungen verfügbar."
L.CaroAM_ExplainNames = "Du kannst Gegner anhand ihrer Namen bestimmen, damit das Addon automatisch die von dir gewählten Markierungen setzt, sobald du den jeweiligen Gegner anschaust. Du kannst entweder Namen von Hand einfügen (beachte dabei die exakte Schreibweise), oder du aktivierst die Aufzeichnen-Funktion um die Auswahlliste beim Spielen zu füllen."


for stringId, stringValue in pairs(L) do
	SafeAddString(_G[stringId], stringValue, 0)
end

CarosAutoMarker.PreSetEnemies = {
	[636]= { -- HRC
		"erzürnender Welwa",
		"Erstmagier-Kettenweber",
		"Erstmagier-Kettenweberin",
		"Anka-Ra-Flammenformer",
		"Erstmagier-Überlader",
		"Erstmagier-Überladerin",
	}, 	
	[638]= { -- AA
		"Erstmagier-Überlader",
		"Erstmagier-Überladerin",
	}, 
	[639]= { -- SO
		"Schuppenhof-Überlader",
	}, 
	[725]= { -- MoL
		"dro-m'Athra-Sonnenfresserin",
		"dro-m'Athra-Wilde",
		"Ogerschamane",
		"Ogerfleischreißer",
	}, 
	[975]= { -- HoF
		"Kondensator",
		"rekonstruierte Arkebuse",
		"Abfänger Negatrix",
		"Abfänger Positrox",
	}, 
	[1000]= { -- AS
		"ordinierter Läuterer",
	}, 
	[1051]= { -- CR
		"Schatten der Gefallenen",
		"boshafte Sphäre",
		"Schatten von Siroria",
		"Schatten von Relequen",
		"Schatten von Galenwe",
	}, 
	[1121]= { -- SS
		"Alkoshs Schicksal",
		"Sturmatronach",
		"Alkoshs Wille",
		"Flammenatronach",
		"wachsame Statue",
		"Jones Sturmkralle",
		"Jodes Feuerzahn",
		"Senche-raht",
		"Alkoshs Brüllen",
	}, 
	[1196]= { -- KA
		"Vampir-Durchtränkerin",
		"Vampir-Durchtränker",
		"Halbriesen-Seeschamane",
		"Halbriesen-Seeschamanin",
		"Halbriesen-Gezeitenbrecher",
		"Halbriesen-Gezeitenbrecherin",
		"Halbriesen-Verschanzer",
		"Halbriesen-Verschanzerin",
	}, 
	[1263] = { -- RG
		"Sul-Xan-Seelenweber",
		"Sul-Xan-Seelenweberin",
		"einbrennender Meteor",
		"Feuerbehemoth",
		"Fleischabscheulichkeit",
		"Chaosblute-Ausweider",
		"Chaosblute-Barbar",
		"Chaosblute-Fackelwirker",
	}, 	
	[1344] = { -- DSR
		"Grauenssegel-Kielschlitzerin",
		"Grauenssegel-Braumeisterin",
		"Grauenssegel-Braumeister",
		"Grauenssegel-Kielschlitzer",
	},
}