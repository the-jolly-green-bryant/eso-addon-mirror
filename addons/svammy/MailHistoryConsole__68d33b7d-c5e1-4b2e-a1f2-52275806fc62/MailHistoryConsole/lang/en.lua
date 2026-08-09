-- MailHistory by @PacificOshie.  Have fun!

-- /script SetCVar("language.2", "en")

--

local langEn = {

    -- SETTINGS

    SI_MAILHISTORY_SETTINGS_DESCRIPTION = "Mail History saves a copy of your mail when sending, taking, returning, and deleting mail to provide a history of your mail activity.",

    SI_MAILHISTORY_SETTINGS_HISTORY_HEADER = "Mail History",
    SI_MAILHISTORY_SETTINGS_HISTORY_DESCRIPTION = "Toggle the history window with command: /mailhistory",
    SI_MAILHISTORY_SETTINGS_SHOWSYSTEMMAIL = "Show system mail that has been saved",
    SI_MAILHISTORY_SETTINGS_SHOWSYSTEMMAIL_TOOLTIP = "Show system mail from hirelings, traders, pvp, etc.  The system mail is only shown in the history if it has been saved.",

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

    -- CHAT

    -- Notification when the mail data is missing for a known mail identifier.  Some other addons process mail before Mail History can save the mail.
    SI_MAILHISTORY_CHAT_WARNING_MISSING_DATA = "Missed mail due to other addons.",

    -- CONSOLE SCENE

    SI_MAILHISTORY_TITLE = "Mail History",  -- Scene header title and mail-scene keybind label.
    SI_MAILHISTORY_EMPTY = "No mail history yet.",  -- The only list entry when the history is empty.
    SI_MAILHISTORY_SETTINGS_LISTTEXTSIZE = "History list text size",
    SI_MAILHISTORY_SETTINGS_LISTTEXTSIZE_SMALL = "Small",
    SI_MAILHISTORY_SETTINGS_LISTTEXTSIZE_MEDIUM = "Medium",
    SI_MAILHISTORY_SETTINGS_LISTTEXTSIZE_LARGE = "Large",

}

for stringId, stringValue in pairs(langEn) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
