-- All the texts that need a translation. As this is being used as the
-- default (fallback) language, all strings that the addon uses MUST
-- be defined here.

--base language is english
BugCatcher_localization_strings = BugCatcher_localization_strings  or {}

BugCatcher_localization_strings["de"] = {
    -- Settings titles
    SI_BUGCATCHER_BUG_INFO = "Fehlerinformationen",
    SI_BUGCATCHER_PREV_BUG = "< < <",
    SI_BUGCATCHER_NEXT_BUG = "> > >",
    SI_BUGCATCHER_DISMISS_BUG = "Fehler verwerfen",
    SI_BUGCATCHER_WIPE_ALL_BUGS = "Alle Fehler löschen",
    SI_BUGCATCHER_SHOW_LOG = "Fehlerprotokoll anzeigen",
    SI_BUGCATCHER_WIPE_BUGS = "Fehler löschen",

    SI_BUGCATCHER_NO_BUGS_FOUND = "Keine Fehler gefunden",
    SI_BUGCATCHER_NOTHING = "Hier gibt es nichts zu sehen.",

    SI_BUGCATCHER_HAVE_NO_BUGS = "Wenn der Sack ausgeblendet ist, hast du keine Fehler.",
    SI_BUGCATCHER_HAVE_BUGS = "Wenn der Sack nicht ausgeblendet ist, hast du Fehler.",
    SI_BUGCATCHER_FULL = "Der Sack ist voll, es können keine weiteren Fehler gespeichert werden. Bitte zeige deine Fehler oder lösche sie so schnell wie möglich.",

    -- Format strings
    SI_BUGCATCHER_BUGS_FOUND = "Fehler <<1>> von <<2>>",        -- unused, see Core setName()
    SI_BUGCATCHER_CAUGHT_DUPLICATE = "<<1>> Duplikate gefunden, zuletzt gesehen am <<2>>.",
    SI_BUGCATCHER_TIMESTAMP = "<<1>> um <<2>><<3>>",        -- unused
    SI_BUGCATCHER_CAUGHT_BUG = "Ein Fehler gefangen (insgesamt <<1>>).",

    SI_BUGCATCHER_TOTAL_BUGS = "<<1>> Fehler aktuell gespeichert.",

    BUGCATCHER_LOCKUI_NAME = "Sackposition sperren",
    BUGCATCHER_LOCKUI = "Wenn aktiviert, wird das Bug Sack-Symbol auf dem Bildschirm an Ort und Stelle gesperrt.",
    BUGCATCHER_RESETPOS = "Sackposition zurücksetzen",
}