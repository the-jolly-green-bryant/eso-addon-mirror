--[[

Target Whisper
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- General
SafeAddString( TARGETWHISPER_SLASH_CMD, "/targetwhisper", 1)
-- Bindings
SafeAddString( SI_BINDING_NAME_TARGETWHISPER_START_DIRECT,     "Chat mit anvisiertem Spieler beginnen |c777777- Öffnet den Chat nur when ein Spieler anvisiert wird.|r", 1)
SafeAddString( SI_BINDING_NAME_TARGETWHISPER_START,            "Chat (mit anvisiertem Spieler) beginnen |c777777- Wie die vorherige Option, aber öffnet den normalen Chat auch wenn kein Spieler anvisiert wird.|r", 1)
SafeAddString( SI_BINDING_NAME_TARGETWHISPER_START_LAST,       "Chat (mit letztem anvisiertem Spieler) beginnen |c777777- Öffnet den Chat zum letzten anvisierten Spieler (oder den normalen Chat wenn noch niemand anvisiert wurde).|r", 1)
SafeAddString( SI_BINDING_NAME_TARGETWHISPER_START_LAST_ENEMY, "Chat (mit letztem anvisiertem gegnerischen Spieler) beginnen |c777777- Wie die vorherige Option, aber nur für Gegner.|r", 1)
-- Messages
SafeAddString( TARGETWHISPER_MSG_INVALID_INPUT, "Ungültige Eingabe", 1)
SafeAddString( TARGETWHISPER_MSG_USAGE,         "Anwendung: "..GetString(TARGETWHISPER_SLASH_CMD).." N\nN=0: Timeout aus\nN>0: Timeout nach N Sekunden", 1)
SafeAddString( TARGETWHISPER_MSG_CURRENT_TIME,  "Aktuelles Timeout: ", 1)
SafeAddString( TARGETWHISPER_MSG_SET_TO,        "Timeout eingestellt auf ", 1)
SafeAddString( TARGETWHISPER_MSG_SECONDS,       " Sekunde(n)", 1)
SafeAddString( TARGETWHISPER_MSG_TIME_OFF,      "Timeout aus", 1)