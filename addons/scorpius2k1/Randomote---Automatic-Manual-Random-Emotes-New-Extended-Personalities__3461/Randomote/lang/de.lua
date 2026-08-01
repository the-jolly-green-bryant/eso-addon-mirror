local strings = {
	SI_RANDOMOTE_LANG 					= "de",
	SI_RANDOMOTE_ENABLE					= "Automatisch",
	SI_RANDOMOTE_ENABLE_TT				= "Aktivieren/Deaktivieren der Verwendung zufälliger Emotes im Leerlauf",
	SI_RANDOMOTE_STANDARD				= "Standard-Emotes",
	SI_RANDOMOTE_STANDARD_TT			= "Verwenden Sie Standard-Emotes",
	SI_RANDOMOTE_COLLECTIBLE			= "Sammelbare Emotes",
	SI_RANDOMOTE_COLLECTIBLE_TT			= "Verwenden Sie sammelbare Emotes (verdienbar, Kronen-Shop usw.)",
	SI_RANDOMOTE_CHAT_OUTPUT			= "Chat-Ausgabe",
	SI_RANDOMOTE_CHAT_OUTPUT_TT			= "Informationen über das Chatfenster anzeigen (nützlich, um den Slash-Befehl, die nächste Emote-Zeit usw. zu sehen)",
	SI_RANDOMOTE_DELAY_IDLE				= "Leerlaufverzögerung",
	SI_RANDOMOTE_DELAY_IDLE_TT			= "Zeit in Sekunden Der Spieler ist inaktiv, um automatisch mit Emotes zu beginnen",
	SI_RANDOMOTE_DELAY_MIN				= "Emote-Verzögerung (Minimum)",
	SI_RANDOMOTE_DELAY_MIN_TT			= "Mindestzeit in Sekunden zwischen Emotes",
	SI_RANDOMOTE_DELAY_MAX				= "Emote-Verzögerung (Maximum)",
	SI_RANDOMOTE_DELAY_MAX_TT			= "Maximale Zeit in Sekunden zwischen Emotes",
	SI_RANDOMOTE_FEEDBACK 				= "Feedback abschicken",
	SI_RANDOMOTE_FEEDBACK_TT 			= "Senden Sie dem Autor des Addons eine Nachricht mit Feedback, Vorschlägen oder Fehlerberichten",
	SI_RANDOMOTE_DESCRIPTION_SLASH		= "Slash-Befehle",
	SI_RANDOMOTE_DESCRIPTION_EMOTE		= "Zufälliges Emote",
	SI_RANDOMOTE_DESCRIPTION_SETTINGS 	= "Einstellungsmenü",
	SI_RANDOMOTE_EMOTE_LIST				= "Emote-Liste",
	SI_BINDING_NAME_INVOKE_RANDOM		= "Zufälliges Emote",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
