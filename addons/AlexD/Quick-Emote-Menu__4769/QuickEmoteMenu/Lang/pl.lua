local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME          = "?",
    SI_QUICKEMOTEMENU_CATEGORIES            = "Kategorie",
    SI_QUICKEMOTEMENU_FAVORITES             = "Ulubione",
    SI_QUICKEMOTEMENU_NO_FAVORITES          = "(puste)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE        = "Przełącz",
    SI_QUICKEMOTEMENU_OPTION_HOVER          = "Opóźnienie hover podmenu (ms)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP  = "0 = otwieraj tylko kliknięciem",
    SI_QUICKEMOTEMENU_OPTION_UIMODE         = "Pokazuj przycisk tylko w trybie UI",
    SI_QUICKEMOTEMENU_OPTION_UIMODE_TOOLTIP =
    "Pokazuje główny przycisk tylko wtedy, gdy kursor myszy jest aktywny (tryb UI). Zostanie ukryty po powrocie do normalnego trybu gry/interakcji.",
    SI_QUICKEMOTEMENU_OPTION_DETACH         = "Odłącz przycisk od czatu",
    SI_QUICKEMOTEMENU_OPTION_DETACH_TOOLTIP = "Przenosi przycisk poza okno czatu. Przycisk można swobodnie przeciągać.",
    SI_QUICKEMOTEMENU_OPTION_SETTINGS       = "Ustawienia",
    SI_QUICKEMOTEMENU_OPTION_ATTACH_BUTTON  = "Przypnij przycisk",
    SI_QUICKEMOTEMENU_OPTION_DETACH_BUTTON  = "Odłącz przycisk",
    SI_QUICKEMOTEMENU_OPTION_SHOW_PANEL     = "Pokaż panel ustawień",
    SI_QUICKEMOTEMENU_OPTION_CLOSE          = "Zamknij menu po emote (LPM)",
    SI_QUICKEMOTEMENU_OPTION_RESET          = "Resetuj pozycję przycisku",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION    = [[
|c3399FFFUNKCJE|r
• Szybki dostęp do emotek dzięki kategoriom i ulubionym
• Kategorie i emotki są ładowane bezpośrednio z danych gry
• Nowe emotki dodane do gry automatycznie pojawią się na liście

|c3399FFSTEROWANIE|r
• LPM na przycisku otwiera lub zamyka menu
• PPM i przeciąganie przesuwa przycisk
• LPM na emote odtwarza go
• PPM na emote dodaje lub usuwa z Ulubionych

|c3399FFMENU|r
• Kategorie — przeglądaj emote według kategorii
• Ulubione — szybki dostęp do zapisanych emote
• Podmenu otwierają się na hover lub kliknięcie (zobacz opóźnienie)
• Menu otwierają się góra/dół i lewo/prawo w zależności od pozycji przycisku

|c3399FFWSKAZÓWKI|r
• Użyj skrótu klawiszowego do przełączania menu
• /qempanel otwiera ten panel ustawień
• Ulubione są zapisywane na całe konto
]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
