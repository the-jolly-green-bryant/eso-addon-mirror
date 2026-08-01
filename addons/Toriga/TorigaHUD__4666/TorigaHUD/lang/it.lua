-- Italian Localization Strings for TorigaHUD
local strings = {
    BINDING_NAME_TORIGAHUD_TOGGLE_DRAG = "Sblocca/Blocca Posizione HUD",
    
    TORIGAHUD_SETTINGS_DISPLAY_NAME = "Impostazioni |cFFD700TorigaHUD|r",
    TORIGAHUD_SETTINGS_GENERAL_HEADER = "Impostazioni Generali",
    TORIGAHUD_SETTINGS_HIDE_OOC = "Nascondi fuori dal combattimento",
    TORIGAHUD_SETTINGS_HIDE_OOC_TT = "Se attivo, nasconde le barre delle risorse quando sei fuori dal combattimento e non hai un bersaglio selezionato.",
    TORIGAHUD_SETTINGS_SHOW_SHIELDS = "Mostra lo Scudo Protettivo",
    TORIGAHUD_SETTINGS_SHOW_SHIELDS_TT = "Se abilitato, mostra una barra semitrasparente azzurra sopra la salute per indicare lo scudo protettivo attivo.",
    TORIGAHUD_SETTINGS_LERP_SPEED = "Velocità Animazione Barre",
    TORIGAHUD_SETTINGS_LERP_SPEED_TT = "Regola la velocità di scivolamento delle barre. (1.00 = aggiornamento istantaneo senza animazione)",
    TORIGAHUD_SETTINGS_SEGMENT_SIZE = "Valore per Segmento (Salute/Risorse)",
    TORIGAHUD_SETTINGS_SEGMENT_SIZE_TT = "Regola quanti punti di risorsa rappresenta ogni singolo blocco delle barre (Salute, Magicka, Stamina, Target). Ad esempio, 2000 significa che ogni blocco corrisponde a 2000 punti.",
    TORIGAHUD_SETTINGS_SCALE = "Scala HUD (Dimensione)",
    TORIGAHUD_SETTINGS_SCALE_TT = "Regola la dimensione globale di tutti gli elementi grafici dell'HUD.",
    TORIGAHUD_SETTINGS_PRESETS_HEADER = "Preset & Posizionamento",
    TORIGAHUD_SETTINGS_PRESET = "Preset di Layout",
    TORIGAHUD_SETTINGS_PRESET_TT = "Seleziona uno dei preset predefiniti per riorganizzare istantaneamente l'interfaccia dell'HUD.",
    TORIGAHUD_SETTINGS_PRESET_DEFAULT = "Default",
    TORIGAHUD_SETTINGS_PRESET_VERTICAL = "Focus Combat (Verticale)",
    TORIGAHUD_SETTINGS_PRESET_HORIZONTAL = "Focus Combat (Orizzontale)",
    TORIGAHUD_SETTINGS_PRESET_MINIMALIST = "Minimalist (Compatto)",
    TORIGAHUD_SETTINGS_UNLOCK = "Sblocca Posizione HUD",
    TORIGAHUD_SETTINGS_UNLOCK_TT = "Abilita questa opzione per sbloccare temporaneamente le barre. Questo chiuderà il menu opzioni e mostrerà un dialogo Applica/Annulla per posizionare gli elementi col mouse.",
    TORIGAHUD_SETTINGS_RESET = "Ripristina Posizioni Default",
    TORIGAHUD_SETTINGS_RESET_TT = "Ripristina la posizione originaria di tutte le barre dell'HUD.",
    
    TORIGAHUD_DRAG_XP = "XP",
    TORIGAHUD_DRAG_TARGET = "BERSAGLIO",
    
    TORIGAHUD_DIALOG_TITLE = "TRASCINA LE BARRE DOVE VUOI",
    TORIGAHUD_DIALOG_APPLY = "APPLICA",
    TORIGAHUD_DIALOG_CANCEL = "ANNULLA",
    
    TORIGAHUD_TEXT_HEALTH = "SALUTE",
    TORIGAHUD_TEXT_LEVEL = "LIVELLO",
    TORIGAHUD_TEXT_XP = "ESPERIENZA",
    TORIGAHUD_TEXT_MAGICKA = "MAGICKA",
    TORIGAHUD_TEXT_STAMINA = "STAMINA",
    TORIGAHUD_TEXT_TARGET_TEST = "BERSAGLIO DI PROVA",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId("SI_" .. stringId, stringValue)
end
