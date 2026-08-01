local strings = {
	SI_GROUP_SYNERGIZER_LANG 		= "de",

	SI_GROUP_SYNERGIZER_ENABLE 		= "Aktiviert",
	SI_GROUP_SYNERGIZER_SOUND 		= "Verbesserter Sound",
	SI_GROUP_SYNERGIZER_SCREEN 		= "Verbesserte Visuelle Darstellung",
	SI_GROUP_SYNERGIZER_ENHANCE 	= "Verbesserte LFG",
	SI_GROUP_SYNERGIZER_ACCEPT 		= "Bereitschaftsprüfungen automatisch akzeptieren",
	SI_GROUP_SYNERGIZER_RELEASE 	= "Automatische Freigabe auf Schlachtfeldern",
	SI_GROUP_SYNERGIZER_SLASH 		= "Versprechen/Gruppen-Schrägstrich-Befehle",
	SI_GROUP_SYNERGIZER_DELAY 		= "Verzögerung der Tonbenachrichtigung",

	SI_GROUP_SYNERGIZER_LFG_CHAT	= "Bereitschaftsprüfung!",
	SI_GROUP_SYNERGIZER_LFG_CHAT_A	= "Automatische Bereitschaftsprüfung!",
	SI_GROUP_SYNERGIZER_LFG_SCREEN	= "Gruppenbereitschaftsprüfung!", 

	SI_GROUP_SYNERGIZER_ENABLE_TT 	= "LFG-Enhancer aktivieren/deaktivieren",
	SI_GROUP_SYNERGIZER_SOUND_TT 	= "Mehr hörbarer Ton bei Bereitschaftsprüfung",
	SI_GROUP_SYNERGIZER_SCREEN_TT 	= "Bessere Bildschirmbenachrichtigung bei Bereitschaftsprüfung",
	SI_GROUP_SYNERGIZER_ENHANCE_TT 	= "Tägliche Zusagen/Quests anzeigen, aktive Quests automatisch akzeptieren und im Gruppen- und Aktivitätsfinder überprüfen",
	SI_GROUP_SYNERGIZER_ACCEPT_TT 	= "Bereitschaftsprüfung 'Suche nach Gruppe' automatisch akzeptieren",
	SI_GROUP_SYNERGIZER_RELEASE_TT 	= "Automatische Freigabe auf Schlachtfeldern Tod",
	SI_GROUP_SYNERGIZER_SLASH_TT 	= "Schrägstrichbefehle \nTägliches Versprechen /pl /pledge \nGruppe verlassen /lv /leave",
	SI_GROUP_SYNERGIZER_DELAY_TT 	= "Verzögerung (in Sekunden) zwischen Tonmeldungen bei LFG-Bereitschaftsprüfung",

	SI_GROUP_SYNERGIZER_SLASH_WARN	= "Neuladen der Benutzeroberfläche erforderlich"
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
