local strings = { 
-- Localization Start

-- Item Tooltip

    EHP_STRING_TOOLTIP_TITLE            = "ESO-Hub.com <<C:1>> Daten",
    EHP_STRING_TOOLTIP_TITLE_DURATION   = " (Letzte 14 Tage)",
    EHP_STRING_TOOLTIP_AVERAGE          = "ESO-Hub.com mittlerer Preis: <<1>>",
    EHP_STRING_TOOLTIP_LISTINGS         = "<<1>> - <<2>> in <<3>> Auktionen",
    EHP_STRING_TOOLTIP_SUGGESTED_SINGLE = "Empfohlener Preis: <<1>>",
    EHP_STRING_TOOLTIP_SUGGESTED_RANGE  = "Empfohlener Preis: <<1>> - <<2>>",
    EHP_STRING_TOOLTIP_TIMESTAMP        = "Preisdaten vom <<1>>, <<2>>",

    -- Settings

    EHP_STRING_SETTING_ACCOUNTWIDE         = "Accountweite Einstellungen",
    EHP_STRING_SETTING_INVENTORY           = "Inventar",
    EHP_STRING_SETTING_INVENTORY_TOOLTIP   = "Zeige die empfohlenen Auktionsspreise im Inventar anstelle des NSC-Verkaufswertes.",
    EHP_STRING_SETTING_INVENTORY_TOOLTIP_DISABLED     = "Ziege empfohlene Auktionspreise im Inventar an Stelle ihrer NPC Verkaufswerte.\nDeaktiviert wegen einer inkompatiblen Einstellung in: <<1>>\nNachdem die inkompatible Eisntellung deaktiviert wurde, muss das UI neu geladen werden, um diese Einstellung verfügbar zu machen.",
    EHP_STRING_SETTING_LISTINGS_TOOLTIP               = "Listenpreise in Tooltips",
    EHP_STRING_SETTING_LISTINGS_TOOLTIP_TOOLTIP       = "Anzeige der Listenpreise in Gegenstands-Tooltips",
    EHP_STRING_SETTING_SALES_TOOLTIP                  = "Verkaufspreise in Tooltips",
    EHP_STRING_SETTING_SALES_TOOLTIP_TOOLTIP          = "Anzeige der Verkaufspreise in Gegenstands-Tooltips",
    EHP_STRING_SETTING_CONTEXTMENU_POSTTOCHAT         = "Kontextmenü: in den Chat posten",
    EHP_STRING_SETTING_CONTEXTMENU_POSTTOCHAT_TOOLTIP = "Fügt eine eine Option zu Kontextmenüs von Gegenständen und deren Links hinzu, um ESO-Hub.com Preisinformationen in den Chat zu posten",
    EHP_STRING_SETTING_CONTEXTMENU_VIEWONLINE         = "Kontextmenü: Online Anzeigen",
    EHP_STRING_SETTING_CONTEXTMENU_VIEWONLINE_TOOLTIP = "Fügt eine eine Option zu Kontextmenüs von Gegenständen und deren Links hinzu, um jene auf ESO-Hub.com zu anzuzeigen",

    -- Inventory Context Menu

    EHP_STRING_CONTEXTMENU_POSTTOCHAT_LISTINGS  = "ESO-Hub Listenpreis zum Chat",
    EHP_STRING_CONTEXTMENU_POSTTOCHAT_SALES     = "ESO-Hub Verkaufspreis zum Chat",
    EHP_STRING_CONTEXTMENU_POSTTOCHAT_FORMAT    = "ESO-Hub.com Preis für <<1>>: <<2>> (<<3>> <<4>>)", -- <<1>> itemLink, <<2>> suggested/average price, <<3>> number of listings <<4>> 'sales' or 'listings')
    EHP_STRING_SALES                            = "Verkäufe",
    EHP_STRING_LISTINGS                         = "Angebote",
    EHP_STRING_CONTEXTMENU_VIEWONLINE           = "Auf ESO-Hub.com anzeigen",

    -- Slash Commands

    EHP_STRING_SLASHCOMMAND_HELP1 = "[LibEsoHubPrices] Die folgenden Eingabebefehle stehen zur Verfügung:",
    EHP_STRING_SLASHCOMMAND_HELP2 = "/ehp accountwide (on/off): Ändert Nutzung accountweiter Einstellungen",
    EHP_STRING_SLASHCOMMAND_HELP4 = "/ehp inventory (none/listings/sales): Überschreiben der im Inventar angezeigten NSC-Verkaufswerte mit den empfohlenen Auktionsspreisen", -- do not translate (none/listings/sales)
    EHP_STRING_SLASHCOMMAND_HELP5 = "/ehp listingstooltip (on/off): Ändert die Anzeige der Listenpreise im Inventar.",
    EHP_STRING_SLASHCOMMAND_HELP6 = "/ehp salestooltip (on/off): Ändert die Anzeige der Verkaufspreise im Inventar",
    EHP_STRING_SLASHCOMMAND_HELP7 = "/ehp contextmenu chat (on/off): Ändert die Anzeige einer Option im Kontextmenü um ESO-Hub.com Preisinformationen in den Chat zu posten.",
    EHP_STRING_SLASHCOMMAND_HELP8 = "/ehp contextmenu online (on/off): Ändert die Anzeige einer Option im Kontextmenü um Gegenstände auf ESO-Hub.com zu anzuzeigen",
    EHP_STRING_SLASHCOMMAND_HELP9 = "/ehp: Zeigt diese Hilfe",

    EHP_STRING_SETTING_MESSAGE_INVENTORY   = "Überschreiben der im Inventarpreisen",
    EHP_STRING_SETTING_MESSAGE_LISTING_TOOLTIP     = "Anzeige der Listenpreise in Gegenstands-Tooltips",
    EHP_STRING_SETTING_MESSAGE_SALES_TOOLTIP     = "Anzeige der Verkaufspreise in Gegenstands-Tooltips",
    EHP_STRING_SETTING_MESSAGE_ACCOUNTWIDE = "Nutzung accountweiter Einstellungen",

    EHP_STRING_SETTING_MESSAGE_CONTEXTMENU_POSTTOCHAT = "Fügt eine eine Option zu Kontextmenüs von Gegenständen und deren Links hinzu, um ESO-Hub.com Preisinformationen in den Chat zu posten.",
    EHP_STRING_SETTING_MESSAGE_CONTEXTMENU_VIEWONLINE = "Fügt eine eine Option zu Kontextmenüs von Gegenständen und deren Links hinzu, um jene auf ESO-Hub.com zu anzuzeigen",

    EHP_STRING_ON  = "ein",
    EHP_STRING_OFF = "aus",

-- Localization End
}

for stringId, stringValue in pairs(strings) do
    if _G[stringId] then
        SafeAddString(_G[stringId], stringValue, 1)
    else
        ZO_CreateStringId(stringId, stringValue)
        SafeAddVersion(stringId, 1)
    end
end