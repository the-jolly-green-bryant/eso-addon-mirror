local strings = {
	SI_AD_BLOCK_PLUS_ENABLE			= "Aktiviert",
	SI_AD_BLOCK_PLUS_ENABLE_TT		= "Aktivieren/Deaktivieren von AdBlock Plus",

	SI_AD_BLOCK_PLUS_NOTIFY			= "Blockierte Benachrichtigungen",	
	SI_AD_BLOCK_PLUS_NOTIFY_TT		= "Blockierte Benachrichtigungen im Chat anzeigen",

	SI_AD_BLOCK_PLUS_FRIEND			= "Benachrichtigungen zum Freundstatus",
	SI_AD_BLOCK_PLUS_FRIEND_TT		= "Anzeigen der Auf/Aus Benachrichtigungen eines Freundes im Chat",
	SI_AD_BLOCK_PLUS_FRIEND_TYPE	= "freundin",
	SI_AD_BLOCK_PLUS_FRIEND_ONLINE	= "hat sich eingeloggt",
	SI_AD_BLOCK_PLUS_FRIEND_OFFLINE	= "hat sich abgemeldet",	

	SI_AD_BLOCK_PLUS_AGRESSIVE 		= "Aggressive Filterung",
	SI_AD_BLOCK_PLUS_AGRESSIVE_TT	= "Erzwingen Sie eine strengere Überprüfung für alle aktivierten Blockierungsoptionen",

	SI_AD_BLOCK_PLUS_BLOCK			= "Blockieren",
	SI_AD_BLOCK_PLUS_BLOCKED_ADVERT	= "Blockierte Werbung",
	SI_AD_BLOCK_PLUS_BLOCKED_SINCE 	= "Seit der Installation",
	SI_AD_BLOCK_PLUS_BLOCKED_TOTAL 	= "Insgesamt Blockiert",

	SI_AD_BLOCK_PLUS_HEADER_BLOCKING = "Blockieren",
	SI_AD_BLOCK_PLUS_HEADER_CHANNELS = "Überwachte Chat-Kanäle",
	SI_AD_BLOCK_PLUS_HEADER_ADVANCED = "Erweitert",

	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET = "Filter Preset",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_TT = "Vordefinierte Optionen zum Blockieren",

	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_1 = "Basic",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_2 = "Erweitert",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_3 = "Streng",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_4 = "Voll",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_5 = "Benutzerdefiniert",

	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_1 = "• Erfolge, Kronen, Gilden\n• Zonenkanal",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_2 = "• Erfolge, Kronen, Gilden, URL\n• Zone, Schreien, Kanäle sagen",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_3 = "• Alle Blockierungsoptionen\n• Zone, Schreien, Gilde, Kanäle sagen",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_4 = "• Alle Blockierungsoptionen\n• Alle Kanäle",
	SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_5 = "Benutzerdefinierte Optionen",

	SI_AD_BLOCK_PLUS_HISTORY_LAST = "Letzte",
	SI_AD_BLOCK_PLUS_DESCRIPTION_SLASH = "Schrägstrichbefehle",
	SI_AD_BLOCK_PLUS_DESCRIPTION_HISTORY = "Verlaufsfenster",
	SI_AD_BLOCK_PLUS_DESCRIPTION_SETTINGS = "Einstellungsmenü",
	SI_AD_BLOCK_PLUS_WELCOME_FIRSTRUN = "Vielen Dank, dass Sie AdBlockPlus verwenden!",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
