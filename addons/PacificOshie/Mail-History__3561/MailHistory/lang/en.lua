-- MailHistory by @PacificOshie.  Have fun!

-- /script SetCVar("language.2", "en")

--

local langEn = {

    -- SETTINGS

    SI_MAILHISTORY_SETTINGS_DESCRIPTION = "Mail History saves a copy of your mail when sending, taking, returning, and deleting mail to provide a history of your mail activity.",

    SI_MAILHISTORY_SETTINGS_HISTORY_HEADER = "Mail History",
    SI_MAILHISTORY_SETTINGS_HISTORY_DESCRIPTION = "Toggle the history window with command: /mailhistory",
    SI_MAILHISTORY_SETTINGS_AUTOTOGGLEMAINWINDOW = "Show the history window at the mailbox",
    SI_MAILHISTORY_SETTINGS_SHOWSYSTEMMAIL = "Show system mail that has been saved",
    SI_MAILHISTORY_SETTINGS_SHOWSYSTEMMAIL_TOOLTIP = "Show system mail from hirelings, traders, pvp, etc.  The system mail is only shown in the history if it has been saved.",
    SI_MAILHISTORY_SETTINGS_SHOWTOOLTIPSUMMARY = "Show mail details as a tooltip in history",

    SI_MAILHISTORY_SETTINGS_CHAT_HEADER = "Chat",
    SI_MAILHISTORY_SETTINGS_CHAT_DESCRIPTION = "Options to log a mail summary in the chat window.",
    SI_MAILHISTORY_SETTINGS_CHATSENTMAIL = "Chat when sending mail",
    SI_MAILHISTORY_SETTINGS_CHATREADMAIL = "Chat when taking, returning, or deleting mail",
    SI_MAILHISTORY_SETTINGS_CHATWARNINGS = "Chat when missing mail due to conflicting addons",

    SI_MAILHISTORY_SETTINGS_STORAGE_HEADER = "Storage",
    SI_MAILHISTORY_SETTINGS_SAVESYSTEMMAIL = "Save system mail (hirelings, traders, pvp, etc)",
    SI_MAILHISTORY_SETTINGS_STORAGE_DESCRIPTION = "The number of mail affects memory usage, disk space, and performance.",
    SI_MAILHISTORY_SETTINGS_NUMMAILTOKEEP = "Total number of mail to save",
    SI_MAILHISTORY_SETTINGS_STORAGE_DEFAULT = "Default <<1>>.",

    SI_MAILHISTORY_SETTINGS_DATETIME_HEADER = "Date and Time",
    SI_MAILHISTORY_SETTINGS_DISPLAYDATEFORMAT = "Date format",
    SI_MAILHISTORY_SETTINGS_DISPLAYDATEFORMAT_SYSTEM = "System (<<1>>)",  -- e.g., System (3/11/2023)
    SI_MAILHISTORY_SETTINGS_DISPLAYTIMEFORMAT = "Time format",
    SI_MAILHISTORY_SETTINGS_DISPLAYTIMEFORMAT_SYSTEM = "System (<<1>>)",  -- e.g., System (2:15 PM)

    SI_MAILHISTORY_SETTINGS_EXPORT_HEADER = "Export",
    SI_MAILHISTORY_SETTINGS_EXPORT_SEPARATOR = "Field separator",  -- Separator character for TSV (tabs) or CSV (commas).
    SI_MAILHISTORY_SETTINGS_EXPORT_SEPARATOR_TOOLTIP = "The separator character to use between data fields when exporting the mail history.",
    SI_MAILHISTORY_SETTINGS_EXPORT_SEPARATOR_TAB = "Tab (TSV)",
    SI_MAILHISTORY_SETTINGS_EXPORT_SEPARATOR_COMMA = "Comma (CSV)",

    -- MAIL

    SI_MAILHISTORY_MAIL_CHARACTER = "Character:",

    SI_MAILHISTORY_MAIL_DATETIME_SENT = "Sent:",
    SI_MAILHISTORY_MAIL_DATETIME_RTS = "Returned:",
    SI_MAILHISTORY_MAIL_DATETIME_RECEIVED = "Received:",

    SI_MAILHISTORY_MAIL_TO = "To:",
    SI_MAILHISTORY_MAIL_TO_MULTIPLE = "(MULTIPLE)",  -- Used in the history when the same mail is sent to multiple recipients.
    SI_MAILHISTORY_MAIL_FROM = "From:",
    SI_MAILHISTORY_MAIL_SYSTEM_PREFIX = "(System) <<1>>",  -- System mail gets this sender prefix.
    SI_MAILHISTORY_MAIL_CS_PREFIX = "(CS) <<1>>",  -- Customer support mail gets this sender prefix.

    SI_MAILHISTORY_MAIL_SUBJECT = "Subject:",

    SI_MAILHISTORY_MAIL_ATTACHMENTS = "Attachments:",
    SI_MAILHISTORY_MAIL_ATTACHMENT_GOLD_SENT = "Sent <<1>> gold.",
    SI_MAILHISTORY_MAIL_ATTACHMENT_GOLD_RTS = "Returned <<1>> gold.",
    SI_MAILHISTORY_MAIL_ATTACHMENT_GOLD_RECEIVED = "Received <<1>> gold.",
    SI_MAILHISTORY_MAIL_ATTACHMENT_COD_SENT = "Requested COD of <<1>> gold.",  -- Request COD when sending mail.
    SI_MAILHISTORY_MAIL_ATTACHMENT_COD_RTS = "Returned COD of <<1>> gold.",
    SI_MAILHISTORY_MAIL_ATTACHMENT_COD_RECEIVED = "Sent COD payment of <<1>> gold.",  -- Send COD payment when receiving mail.
    SI_MAILHISTORY_MAIL_ATTACHMENT_MISSING = "Unknown attachment.",  -- Attachment info is missing.
    SI_MAILHISTORY_MAIL_ATTACHMENT_NONE = "No attachments.",

    -- EXPORT

    SI_MAILHISTORY_EXPORT_CHARACTER = "Character",
    SI_MAILHISTORY_EXPORT_STATUS = "Status",  -- Status values: Sent, Returned, Received.
    SI_MAILHISTORY_EXPORT_DATETIME = "Timestamp",  -- Date and Time.
    SI_MAILHISTORY_EXPORT_DIRECTION = "Direction",  -- Direction values: To, From.
    SI_MAILHISTORY_EXPORT_NAME = "Name",
    SI_MAILHISTORY_EXPORT_SUBJECT = "Subject",
    SI_MAILHISTORY_EXPORT_BODY = "Message",
    SI_MAILHISTORY_EXPORT_GOLD = "Gold",
    SI_MAILHISTORY_EXPORT_COD = "COD",
    SI_MAILHISTORY_EXPORT_ATTACHMENTS = "Attachments",

    -- MAILSEND

    SI_MAILHISTORY_MAILSEND_REPLY = "Reply",
    SI_MAILHISTORY_MAILSEND_REPLY_ABBREVIATION = "RE",
    SI_MAILHISTORY_MAILSEND_FORWARD = "Forward",
    SI_MAILHISTORY_MAILSEND_FORWARD_ABBREVIATION = "FW",
    SI_MAILHISTORY_MAILSEND_FORWARD_BODY_TRUNCATED = "[Message Clipped]",  -- Displayed at the bottom of a forwarded mail when the text was truncated due to maximum mail length.

    -- MAINWINDOW

    SI_MAILHISTORY_MAINWINDOW_EXPORTBUTTON = "Export",  -- Displays the CSV to export (copy to clipboard).
    SI_MAILHISTORY_MAINWINDOW_OPTIONSBUTTON = "Options",  -- Opens the addon settings window.
    SI_MAILHISTORY_MAINWINDOW_STATUS_LOADING = "Loading...",  -- While loading all mail into the list.
    SI_MAILHISTORY_MAINWINDOW_STATUS_MATCHING = "Matching...",  -- While applying the search filter.
    SI_MAILHISTORY_MAINWINDOW_STATUS_ALL = "Showing <<1>> mail.",
    SI_MAILHISTORY_MAINWINDOW_STATUS_SEARCHFILTER = "Matched <<1>> of <<2>> mail.",  -- Only showing the mail that matched the search filter.
    SI_MAILHISTORY_MAINWINDOW_SEARCHFILTER_PROMPT = "Search filter...",
    SI_MAILHISTORY_MAINWINDOW_SEARCHFILTER_RESET_TOOLTIP = "Reset search filter",

    -- POPUPWINDOW

    SI_MAILHISTORY_POPUPWINDOW_PREVBUTTON_TOOLTIP = "Previous mail",
    SI_MAILHISTORY_POPUPWINDOW_NEXTBUTTON_TOOLTIP = "Next mail",

    -- EXPORTWINDOW

    SI_MAILHISTORY_EXPORTWINDOW_HEADER = "Export",
    SI_MAILHISTORY_EXPORTWINDOW_PREVBUTTON_TOOLTIP = "Previous page",
    SI_MAILHISTORY_EXPORTWINDOW_NEXTBUTTON_TOOLTIP = "Next page",
    SI_MAILHISTORY_EXPORTWINDOW_STATUS = "Showing page <<1>> of <<2>>.",

    -- CHAT

    -- Notification when the mail data is missing for a known mail identifier.  Some other addons process mail before Mail History can save the mail.
    SI_MAILHISTORY_CHAT_WARNING_MISSING_DATA = "Missed mail due to other addons.",
    -- Notification when the MailR addon is detected.  Some old addons replaced the ESOUI mail functions so Mail History is not notified of mail.
    SI_MAILHISTORY_CHAT_WARNING_MAILR = "Limited history due to MailR.",

    -- KEYBINDINGS

    SI_BINDING_NAME_MAILHISTORY_TOGGLE = "Toggle history window",

}

for stringId, stringValue in pairs(langEn) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
