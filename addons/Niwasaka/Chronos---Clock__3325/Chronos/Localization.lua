local Chronos = _G['Chronos']

ChronosLocalizationData = {
    de = {
        --General
        name = "Chronos",
        --Changelog
        changelog_title = "<<1>> Changelog",
        changelog_from = "v<<1>> von <<2>>",
        changelog_message = {
            "|cFFA500Chronos Version 1.3.2|r",
            "",
            "|cFFFF00Allgemein:|r",
            "[*] Verschiedene Bugfixes",
            "[*] API-Anpassung auf Version 50 - Season Zero Pt. 2.",
            "",
            "|cFFFF00Uhr:|r",
            "[*] Initialisierung der Uhr verbessert",
            "[*] UTC-Offset-Berechnung korrigiert",
            "[*] Problem behoben, wodurch Hintergrundeinstellungen in den Einstellungen nicht korrekt angezeigt wurden",
            "",
        },
        --Settings
        SETTINGS_HEADER_GENERAL = "Allgemein",
        SETTINGS_CLOCK_TITLE = "Uhrzeit",
        SETTINGS_TOOLTIP_CLOCK = "Hier findest du alle Einstellungen für die Uhrzeit",
        SETTINGS_CLOCK_SHOW = "Uhr anzeigen",
        SETTINGS_CLOCK_COLOR = "Schriftfarbe",
        SETTINGS_CLOCK_FONT = "Schriftart",
        SETTINGS_CLOCK_FONTSIZE = "Schriftgröße",
        SETTINGS_CLOCK_OUTLINE = "Textumriss",
        SETTINGS_CLOCK_SHOW_BG = "Hintergrund anzeigen",
        SETTINGS_CLOCK_BG = "Hintergrund",
        SETTINGS_CLOCK_BGCOLOR = "Hintergrundfarbe",
        SETTINGS_TOOLTIP_BGCOLOR = "Die Hintergrundfarbe ändert sich nur bei der Option Solid",
        SETTINGS_CLOCK_BGTRANSPARENCY = "Transparenz",
        SETTINGS_CLOCK_TIMEZONE_HEADER = "Zeitzonen",
        SETTINGS_CLOCK_TIMEZONE_HEADER_TOOLTIP = "Stelle hier die von dir gewünschte Zeitzone ein.",
        SETTINGS_CLOCK_DST = "Sommer/Winterzeit",
        SETTINGS_CLOCK_TIMEZONE = "Zeitzone",
        SETTINGS_CLOCK_SHOW_UTC = "UTC anzeigen",
        SETTINGS_CLOCK_TIMEZONE_RESET = "Zurücksetzen",
        SETTINGS_CLOCK_TIMEZONE_FONTRATIO = "Größenunterschied",
        SETTINGS_CLOCK_TIMEZONES_LIST = "Zeitzonen",
        SETTINGS_SHOW_CHANGELOG = "Changelog automatisch öffnen [Update]",
        SETTINGS_SHOW_CHANGELOGBUTTON = "Changelog öffnen",
    },

    en = {
        --General
        name = "Chronos",
        --Changelog
        changelog_title = "<<1>> Changelog",
        changelog_from = "v<<1>> from <<2>>",
        changelog_message = {
            "|cFFA500Chronos Version 1.3.2|r",
            "",
            "|cFFFF00General:|r",
            "[*] Various bug fixes",
            "[*] API bump to version 50 - Season Zero Pt. 2.",
            "",
            "|cFFFF00Clock:|r",
            "[*] Improved clock initialization",
            "[*] Fixed UTC offset calculation",
            "[*] Fixed background settings not showing correctly in the settings menu",
            "",
        },
        -- Settings
        SETTINGS_HEADER_GENERAL = "General",
        SETTINGS_CLOCK_TITLE = "Clock",
        SETTINGS_TOOLTIP_CLOCK = "Here you will find all the settings for the time",
        SETTINGS_CLOCK_SHOW = "Show clock",
        SETTINGS_CLOCK_COLOR = "Change colour",
        SETTINGS_CLOCK_FONT = "Font",
        SETTINGS_CLOCK_FONTSIZE = "Font size",
        SETTINGS_CLOCK_OUTLINE = "Text Outline",
        SETTINGS_CLOCK_SHOW_BG = "Show Background",
        SETTINGS_CLOCK_BG = "Background",
        SETTINGS_CLOCK_BGCOLOR = "Background colour",
        SETTINGS_TOOLTIP_BGCOLOR = "The background colour only changes with the option Solid",
        SETTINGS_CLOCK_BGTRANSPARENCY = "Transparency",
        SETTINGS_CLOCK_TIMEZONE_HEADER = "Timezones",
        SETTINGS_CLOCK_TIMEZONE_HEADER_TOOLTIP = "Set the desired time zone here",
        SETTINGS_CLOCK_DST = "DST-Support",
        SETTINGS_CLOCK_TIMEZONE = "Timezone",
        SETTINGS_CLOCK_SHOW_UTC = "Show UTC",
        SETTINGS_CLOCK_TIMEZONE_RESET = "Reset",
        SETTINGS_CLOCK_TIMEZONE_FONTRATIO = "UTC Font ratio",
        SETTINGS_CLOCK_TIMEZONES_LIST = "Timezones",
        SETTINGS_SHOW_CHANGELOG = "Open Changelog automatically [Update]",
        SETTINGS_SHOW_CHANGELOGBUTTON = "Open Changelog",
    },
}

local function GetLocaleString(langId, langStr)
    if (ChronosLocalizationData[langId] ~= nil) and (ChronosLocalizationData[langId][langStr] ~= nil) then
        return ChronosLocalizationData[langId][langStr]
    end

    return ChronosLocalizationData["en"][langStr]
end

function Chronos.GetDefaultLocaleString(langStr)
    return GetLocaleString(GetCVar("language.2"), langStr)
end