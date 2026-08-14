local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME         = "?",
    SI_QUICKEMOTEMENU_CATEGORIES           = "Kategorie",
    SI_QUICKEMOTEMENU_FAVORITES            = "Ulubione",
    SI_QUICKEMOTEMENU_NO_FAVORITES         = "(puste)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE       = "Przełącz",
    SI_QUICKEMOTEMENU_OPTION_HOVER         = "Opóźnienie hover podmenu (ms)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP = "0 = otwieraj tylko kliknięciem",
    SI_QUICKEMOTEMENU_OPTION_CLOSE         = "Zamknij menu po emote (LPM)",
    SI_QUICKEMOTEMENU_OPTION_RESET         = "Resetuj pozycję przycisku",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION   = [[|c3399FFSTEROWANIE|r
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
• Ulubione są zapisywane na całe konto]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
