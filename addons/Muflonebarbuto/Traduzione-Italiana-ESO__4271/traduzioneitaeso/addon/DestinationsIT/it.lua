-- Integrazione Destinations per TraduzioneItaESO
-- Sopprime il warning della lingua non supportata e segna "it" come lingua valida

if Destinations then
    -- Notifica Destinations che la lingua italiana è gestita da TraduzioneItaESO
    Destinations.effective_menu_lang = "it"
    Destinations.supported_menu_lang = true
    
    -- Annulla la registrazione dell'evento warning prima che venga attivato
    EVENT_MANAGER:UnregisterForEvent(Destinations.name, EVENT_PLAYER_ACTIVATED)
end