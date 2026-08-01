--[[

Target Whisper
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- General
SafeAddString( TARGETWHISPER_SLASH_CMD, "/targetwhisper", 1)
-- Bindings
SafeAddString( SI_BINDING_NAME_TARGETWHISPER_START_DIRECT,     "Dialogue avec joueur ciblée |c777777- Seulement si un joueur est ciblée.|r", 1)
SafeAddString( SI_BINDING_NAME_TARGETWHISPER_START,            "Dialogue (avec joueur ciblée) |c777777- Comme l'antérieure option, mais le dialogue normale apparaît si aucun joueur est ciblée.|r", 1)
SafeAddString( SI_BINDING_NAME_TARGETWHISPER_START_LAST,       "Dialogue (avec joueur ciblée dernière) |c777777- Dialogue avec le joueur qui était ciblée en dernier (ou dialogue normal si ne personne était ciblée jusqu'ici).|r", 1)
SafeAddString( SI_BINDING_NAME_TARGETWHISPER_START_LAST_ENEMY, "Dialogue (avec joueur ennemi ciblée dernière) |c777777- Comme l'antérieure option, mais seulement pour des ennemis.|r", 1)
-- Messages
SafeAddString( TARGETWHISPER_MSG_INVALID_INPUT, "Donnée invalide", 1)
SafeAddString( TARGETWHISPER_MSG_USAGE,         "Usage: "..GetString(TARGETWHISPER_SLASH_CMD).." N\nN=0: Durée éteinte\nN>0: Durée en N secondes", 1)
SafeAddString( TARGETWHISPER_MSG_CURRENT_TIME,  "Durée actuelle: ", 1)
SafeAddString( TARGETWHISPER_MSG_SET_TO,        "Durée définie à ", 1)
SafeAddString( TARGETWHISPER_MSG_SECONDS,       " seconde(s)", 1)
SafeAddString( TARGETWHISPER_MSG_TIME_OFF,      "Durée éteinte", 1)