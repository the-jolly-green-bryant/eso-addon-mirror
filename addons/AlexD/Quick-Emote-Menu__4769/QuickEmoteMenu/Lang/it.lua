local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME          = "?",
    SI_QUICKEMOTEMENU_CATEGORIES            = "Categorie",
    SI_QUICKEMOTEMENU_FAVORITES             = "Preferiti",
    SI_QUICKEMOTEMENU_NO_FAVORITES          = "(vuoto)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE        = "Attiva/Disattiva",
    SI_QUICKEMOTEMENU_OPTION_HOVER          = "Ritardo hover sottomenu (ms)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP  = "0 = apri solo al clic",
    SI_QUICKEMOTEMENU_OPTION_UIMODE         = "Mostra pulsante solo in modalità UI",
    SI_QUICKEMOTEMENU_OPTION_UIMODE_TOOLTIP =
    "Mostra il pulsante principale solo quando il cursore del mouse è attivo (modalità UI). Viene nascosto tornando alla normale modalità di gioco/interazione.",
    SI_QUICKEMOTEMENU_OPTION_CLOSE          = "Chiudi menu dopo emote (clic sinistro)",
    SI_QUICKEMOTEMENU_OPTION_RESET          = "Reimposta posizione pulsante",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION    = [[
|c3399FFFUNZIONALITÀ|r
• Accesso rapido agli emote con categorie e preferiti
• Categorie ed emote vengono caricati direttamente dai dati del gioco
• I nuovi emote aggiunti dal gioco appariranno automaticamente nella lista

|c3399FFCONTROLLI|r
• Clic sinistro sul pulsante per aprire o chiudere il menu
• Clic destro e trascina il pulsante per spostarlo
• Clic sinistro su un'emote per riprodurla
• Clic destro su un'emote per aggiungere o rimuovere dai Preferiti

|c3399FFMENU|r
• Categorie — sfoglia emote per categoria
• Preferiti — accesso rapido alle emote salvate
• I sottomenu si aprono al passaggio o clic (vedi ritardo)
• I menu si aprono sopra/sotto e sx/dx in base alla posizione del pulsante

|c3399FFCONSIGLI|r
• Usa il tasto di scelta rapida per attivare/disattivare il menu
• /qempanel apre questo pannello impostazioni
• I Preferiti sono salvati a livello di account
]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
