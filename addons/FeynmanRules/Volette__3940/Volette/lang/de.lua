local localizationStrings = {
    VOLETTE_YES = "Ja",
    VOLETTE_NO = "Nein",

    VOLETTE_REQUIRES_RELOADUI = "Erfordert das Neuladen der Benutzeroberfläche.",
    VOLETTE_RELOADUI_DIALOG_TITLE = "Benutzeroberfläche neu laden",
    VOLETTE_RELOADUI_DIALOG_DESCRIPTION = "Die Änderung wird wirksam, wenn du die Benutzeroberfläche neu lädst. Möchtest du das jetzt tun?",

    VOLETTE_CONFIRM_DIALOG_TITLE = "Bestätigung",
    VOLETTE_CONFIRM_DIALOG_DESCRIPTION = "Bestätigst du diese Aktion?",

    VOLETTE_HQ_OWNER_CRAFT = "Eigentümer des QG der Handwerkskunst",
    VOLETTE_HQ_OWNER_PARSE = "Eigentümer des QG des Trainings",
    VOLETTE_HQ_OWNER_MISSING = "Sie müssen den HQ-Besitzer in den Einstellungen auswählen.",

    VOLETTE_CONTACTS_ENABLE = "Kontakte-Menü aktivieren",
    VOLETTE_CONTACTS_ENABLE_TOOLTIP = "Aktivieren, um ein zusätzliches Kontakte-Menü neben deiner Freundesliste zu erhalten",
    VOLETTE_CONTACTS_ADDED = "<<1>> wurde zu den Kontakten hinzugefügt.",
    VOLETTE_CONTACTS_REMOVED = "<<1>> wurde aus den Kontakten entfernt.",
    VOLETTE_CONTACTS_EXISTS = "<<1>> ist bereits in den Kontakten.",
    VOLETTE_CONTACTS_WAS_INVITED = "<<1>> wurde eingeladen.",
    VOLETTE_CONTACTS_WHISPER_BUTTON_TOOLTIP = "Flüstern",
    VOLETTE_CONTACTS_INVITE_BUTTON_TOOLTIP = "Einladen",
    VOLETTE_CONTACTS_REMOVE_BUTTON_TOOLTIP = "Von der Liste entfernen",
    VOLETTE_CONTACTS_PIN_BUTTON_TOOLTIP = "Anheften",
    VOLETTE_CONTACTS_UNPIN_BUTTON_TOOLTIP = "Lösen",

    VOLETTE_TRAVEL_WAYSHRINE_CHOICE = "Wählen Sie ein Haus in der Nähe eines Wegschreins",
    VOLETTE_TRAVEL_WAYSHRINE_CHOICE_TOOLTIP = "Versucht, vor diesem Haus zu teleportieren, wenn Sie den Befehl |cffcc00/v-wayshrine|r verwenden. Wenn Sie dieses Haus nicht besitzen, wird ein anderes verwendet.",
    VOLETTE_TRAVEL_AUTO = "Auto",
    VOLETTE_TRAVEL_WAYSHRINE_RECOMMENDATION = "Sie müssen eines der kompatiblen Häuser besitzen. \"<<1>>\" wird empfohlen.",
    VOLETTE_TRAVEL_WAYSHRINE_PORTING = "Teleportation außerhalb von \"<<1>>\".",
    VOLETTE_TRAVEL_SEARCHING_ANOTHER_WAYSHRINE = "Sie müssen \"<<1>>\" besitzen. Versuche, ein anderes Haus zu finden...",

    VOLETTE_SAVINGS_SUBMENU_TITLE = "Ersparnisse",
    VOLETTE_SAVINGS_SUBMENU_DESCRIPTION = "Lass dein Vermögen nicht auf Alts liegen! Lege deine Währungen automatisch in der Bank an, wenn sie anfangen sich anzusammeln.",
    VOLETTE_SAVINGS_ENABLE = "|c66a3ffAktivieren|r",
    VOLETTE_SAVINGS_MINIMUM_AMOUNT = "Mindestbetrag",
    VOLETTE_SAVINGS_MAXIMUM_AMOUNT = "Höchstbetrag",
    VOLETTE_SAVINGS_MINIMUM_AMOUNT_TOOLTIP = "Deine Charaktere werden immer mindestens diesen Betrag in ihren Taschen haben.",
    VOLETTE_SAVINGS_MAXIMUM_AMOUNT_TOOLTIP = "Deine Charaktere werden nie mehr als diesen Betrag in ihren Taschen behalten.",
    VOLETTE_SAVINGS_ENABLE_FOR_DESCRIPTION = "Aktivieren für folgende Charaktere:",
    VOLETTE_SAVINGS_DEPOSIT = "Einzahlung: <<1>>",
    VOLETTE_SAVINGS_WITHDRAWAL = "Abhebung: <<1>>",
    VOLETTE_SAVINGS_NOT_ENOUGH_CURRENCIES = "<<1>> konnte in der Bank nicht gefunden werden.",

    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HOME = "Zur Hauptresidenz portieren",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HQ_CRAFT = "Zum Handwerks-HQ portieren",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HQ_PARSE = "Zum Trainings-HQ portieren",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_WAYSHRINE = "Zum Wegschrein portieren",

}


for stringId, stringValue in pairs(localizationStrings) do
    SafeAddString(_G[stringId], stringValue, 4)
end
