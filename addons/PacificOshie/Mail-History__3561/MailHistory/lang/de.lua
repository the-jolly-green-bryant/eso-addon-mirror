-- MailHistory by @PacificOshie.  Have fun!

-- /script SetCVar("language.2", "de")

-- German translations by: Beartram, @PacificOshie

local langDe = {

    -- SETTINGS

    SI_MAILHISTORY_SETTINGS_DESCRIPTION = "Mail History speichert eine Kopie deiner Mails beim Senden, Entnehmen, Zurücksenden, und Löschen, damit du eine Historie deiner Mails einsehen kannst.",

    SI_MAILHISTORY_SETTINGS_HISTORY_HEADER = "Mail Historie",
    SI_MAILHISTORY_SETTINGS_HISTORY_DESCRIPTION = "Öffne die Historie wann immer du möchtest per Chat Befehl: /mailhistory",
    SI_MAILHISTORY_SETTINGS_AUTOTOGGLEMAINWINDOW = "Zeige Historie beim Erstellen/Anzeigen von Mails",
    SI_MAILHISTORY_SETTINGS_SHOWSYSTEMMAIL = "Zeige System Mail in der Historie",
    --TODO SI_MAILHISTORY_SETTINGS_SHOWSYSTEMMAIL_TOOLTIP = "Show system mail from hirelings, traders, pvp, etc.  The system mail is only shown in the history if it has been saved.",
    SI_MAILHISTORY_SETTINGS_SHOWTOOLTIPSUMMARY = "Zeige Mail Details als Tooltip",

    SI_MAILHISTORY_SETTINGS_CHAT_HEADER = "Chat",
    SI_MAILHISTORY_SETTINGS_CHAT_DESCRIPTION = "Mail Zusammenfassungs-Log im Chat",
    SI_MAILHISTORY_SETTINGS_CHATSENTMAIL = "Chat: Mail gesendet",
    SI_MAILHISTORY_SETTINGS_CHATREADMAIL = "Chat: Anhang entnommen, Mail zurück/gelöscht",
    SI_MAILHISTORY_SETTINGS_CHATWARNINGS = "Chat: wenn Mail durch andere AddOns fehlt",

    SI_MAILHISTORY_SETTINGS_STORAGE_HEADER = "Speicher",
    --TODO SI_MAILHISTORY_SETTINGS_SAVESYSTEMMAIL = "Save system mail (hirelings, traders, pvp, etc)",
    SI_MAILHISTORY_SETTINGS_STORAGE_DESCRIPTION = "Die Anzahl der Mails wird den Speicher, Plattenplatz sowie die Performance beeinflussen.",
    SI_MAILHISTORY_SETTINGS_NUMMAILTOKEEP = "Maximale Zahl Mails die gespeichert werden",
    SI_MAILHISTORY_SETTINGS_STORAGE_DEFAULT = "Default <<1>>.",

    SI_MAILHISTORY_SETTINGS_DATETIME_HEADER = "Datum und Uhrzeit",
    SI_MAILHISTORY_SETTINGS_DISPLAYDATEFORMAT = "Datumsformat",
    SI_MAILHISTORY_SETTINGS_DISPLAYDATEFORMAT_SYSTEM = "System (<<1>>)",  -- e.g., System default (3/11/2023)
    SI_MAILHISTORY_SETTINGS_DISPLAYTIMEFORMAT = "Zeitformat",
    SI_MAILHISTORY_SETTINGS_DISPLAYTIMEFORMAT_SYSTEM = "System (<<1>>)",  -- e.g., System default (2:15 PM)

    SI_MAILHISTORY_SETTINGS_EXPORT_HEADER = "Export",
    SI_MAILHISTORY_SETTINGS_EXPORT_SEPARATOR = "Feldtrennzeichen",  -- Separator character for TSV (tabs) or CSV (commas).
    SI_MAILHISTORY_SETTINGS_EXPORT_SEPARATOR_TOOLTIP = "Das Trennzeichen, das zwischen den Datenfeldern beim Exportieren der Mail-Historie verwendet wird.",
    SI_MAILHISTORY_SETTINGS_EXPORT_SEPARATOR_TAB = "Tabulator (TSV)",
    SI_MAILHISTORY_SETTINGS_EXPORT_SEPARATOR_COMMA = "Komma (CSV)",

    -- MAIL

    SI_MAILHISTORY_MAIL_CHARACTER = "Charakter:",

    SI_MAILHISTORY_MAIL_DATETIME_SENT = "Gesendet:",
    SI_MAILHISTORY_MAIL_DATETIME_RTS = "Zurück ges.:",
    SI_MAILHISTORY_MAIL_DATETIME_RECEIVED = "Empfangen:",

    SI_MAILHISTORY_MAIL_TO = "An:",
    SI_MAILHISTORY_MAIL_TO_MULTIPLE = "(MEHRERE)",  -- Used in the history when the same mail is sent to multiple recipients.
    SI_MAILHISTORY_MAIL_FROM = "Von:",
    SI_MAILHISTORY_MAIL_SYSTEM_PREFIX = "(System) <<1>>",  -- System mail gets this sender prefix.
    SI_MAILHISTORY_MAIL_CS_PREFIX = "(CS) <<1>>",  -- Customer support mail gets this sender prefix.

    SI_MAILHISTORY_MAIL_SUBJECT = "Betreff:",

    SI_MAILHISTORY_MAIL_ATTACHMENTS = "Anhänge:",
    SI_MAILHISTORY_MAIL_ATTACHMENT_GOLD_SENT = "<<1>> Gold gesendet.",
    SI_MAILHISTORY_MAIL_ATTACHMENT_GOLD_RTS = "<<1>> Gold zurück gesendet.",
    SI_MAILHISTORY_MAIL_ATTACHMENT_GOLD_RECEIVED = "<<1>> Gold erhalten.",
    SI_MAILHISTORY_MAIL_ATTACHMENT_COD_SENT = "COD in Höhe von <<1>> Gold angefordert.",  -- Request COD when sending mail.
    SI_MAILHISTORY_MAIL_ATTACHMENT_COD_RTS = "COD in Höhe von <<1>> Gold zurück gesendet.",
    SI_MAILHISTORY_MAIL_ATTACHMENT_COD_RECEIVED = "COD Zahlung in Höhe von <<1>> Gold.",  -- Send COD payment when receiving mail.
    SI_MAILHISTORY_MAIL_ATTACHMENT_MISSING = "Unbekannter Anhang.",  -- Attachment info is missing.
    SI_MAILHISTORY_MAIL_ATTACHMENT_NONE = "Keine Anhänge.",

    -- MAILSEND

    SI_MAILHISTORY_MAILSEND_REPLY = "Antworten",
    SI_MAILHISTORY_MAILSEND_REPLY_ABBREVIATION = "AW",
    SI_MAILHISTORY_MAILSEND_FORWARD = "Weiterleiten",
    SI_MAILHISTORY_MAILSEND_FORWARD_ABBREVIATION = "WG",
    SI_MAILHISTORY_MAILSEND_FORWARD_BODY_TRUNCATED = "[Nachricht gekürzt]",  -- Displayed at the bottom of a forwarded mail when the text was truncated due to maximum mail length.

    -- MAINWINDOW

    SI_MAILHISTORY_MAINWINDOW_EXPORTBUTTON = "Exportieren",  -- Displays the CSV to export (copy to clipboard).
    SI_MAILHISTORY_MAINWINDOW_OPTIONSBUTTON = "Optionen",
    SI_MAILHISTORY_MAINWINDOW_STATUS_LOADING = "Lädt...",  -- While loading all mail into the list.
    SI_MAILHISTORY_MAINWINDOW_STATUS_MATCHING = "Sucht...",  -- While applying the search filter.
    SI_MAILHISTORY_MAINWINDOW_STATUS_ALL = "Zeigt <<1>> Mails.",
    SI_MAILHISTORY_MAINWINDOW_STATUS_SEARCHFILTER = "<<1>> von <<2>> Mails gefunden.",  -- Only showing the mail that matched the search filter.
    SI_MAILHISTORY_MAINWINDOW_SEARCHFILTER_PROMPT = "Suche / Filter...",
    SI_MAILHISTORY_MAINWINDOW_SEARCHFILTER_RESET_TOOLTIP = "Suche/Filter zurücksetzen",

    -- POPUPWINDOW

    SI_MAILHISTORY_POPUPWINDOW_PREVBUTTON_TOOLTIP = "Vorherige Mail",
    SI_MAILHISTORY_POPUPWINDOW_NEXTBUTTON_TOOLTIP = "Nächste Mail",

    -- EXPORTWINDOW

    SI_MAILHISTORY_EXPORTWINDOW_HEADER = "Export",
    SI_MAILHISTORY_EXPORTWINDOW_PREVBUTTON_TOOLTIP = "Vorherige Seite",
    SI_MAILHISTORY_EXPORTWINDOW_NEXTBUTTON_TOOLTIP = "Nächste Seite",
    SI_MAILHISTORY_EXPORTWINDOW_STATUS = "Seite <<1>> von <<2>> angezeigt.",

    -- CHAT

    -- Notification when the mail data is missing for a known mail identifier.  Some other addons process mail before Mail History can save the mail.
    SI_MAILHISTORY_CHAT_WARNING_MISSING_DATA = "Fehlende Mail durch andere AddOns.",
    -- Notification when the MailR addon is detected.  Some old addons replaced the ESOUI mail functions so Mail History is not notified of mail.
    SI_MAILHISTORY_CHAT_WARNING_MAILR = "Eingeschränkte Historie wegen des AddOns \'MailR\'.",

    -- KEYBINDINGS

    --TODO SI_BINDING_NAME_MAILHISTORY_TOGGLE = "Toggle history window",

}

for stringId, stringValue in pairs(langDe) do
    ZO_CreateStringId(stringId, stringValue)
    -- Use version 2 to have this string override the default because en/English is version 1.
    SafeAddVersion(stringId, 2)
end
