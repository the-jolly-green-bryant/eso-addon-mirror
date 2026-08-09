-- MailHistory by @PacificOshie.  Have fun!

-- /script SetCVar("language.2", "ru")

-- Russian translations by: @Verling.P, @PacificOshie

local langRu = {

    -- SETTINGS

    SI_MAILHISTORY_SETTINGS_DESCRIPTION = "Mail History создает список истории почты, помещая туда копию вашей переписки при отправке, получении, возврате и удалении почтовых сообщений.",

    SI_MAILHISTORY_SETTINGS_HISTORY_HEADER = "История Почты",
    SI_MAILHISTORY_SETTINGS_HISTORY_DESCRIPTION = "Откройте историю писем в любое время, используя команду: /mailhistory",
    SI_MAILHISTORY_SETTINGS_SHOWSYSTEMMAIL = "Показывать письма Системное в истории",
    --TODO SI_MAILHISTORY_SETTINGS_SHOWSYSTEMMAIL_TOOLTIP = "Show system mail from hirelings, traders, pvp, etc.  The system mail is only shown in the history if it has been saved.",

    SI_MAILHISTORY_SETTINGS_CHAT_HEADER = "Чат",
    SI_MAILHISTORY_SETTINGS_CHAT_DESCRIPTION = "Настройки вывода сообщений в окне Чата, когда:",
    SI_MAILHISTORY_SETTINGS_CHATSENTMAIL = "Отправляем письмо",
    SI_MAILHISTORY_SETTINGS_CHATREADMAIL = "Получаем, удаляем или возвращаем письмо",
    SI_MAILHISTORY_SETTINGS_CHATWARNINGS = "Пропущено письмо из-за конфликта аддонов",

    SI_MAILHISTORY_SETTINGS_STORAGE_HEADER = "Размеры хранилища",
    --TODO SI_MAILHISTORY_SETTINGS_SAVESYSTEMMAIL = "Save system mail (hirelings, traders, pvp, etc)",
    SI_MAILHISTORY_SETTINGS_STORAGE_DESCRIPTION = "Количество писем в истории влияет на использование памяти, дискового пространства и производительность.",
    SI_MAILHISTORY_SETTINGS_NUMMAILTOKEEP = "Общее количество записей сохраняемой почты",
    SI_MAILHISTORY_SETTINGS_STORAGE_DEFAULT = "По умолчанию <<1>>.",

    SI_MAILHISTORY_SETTINGS_DATETIME_HEADER = "Дата и время",
    SI_MAILHISTORY_SETTINGS_DISPLAYDATEFORMAT = "Формат даты",
    SI_MAILHISTORY_SETTINGS_DISPLAYDATEFORMAT_SYSTEM = "система (<<1>>)",  -- e.g., System default (3/11/2023)
    SI_MAILHISTORY_SETTINGS_DISPLAYTIMEFORMAT = "Формат времени",
    SI_MAILHISTORY_SETTINGS_DISPLAYTIMEFORMAT_SYSTEM = "система (<<1>>)",  -- e.g., System default (2:15 PM)

    -- MAIL

    SI_MAILHISTORY_MAIL_CHARACTER = "Персонаж:",

    SI_MAILHISTORY_MAIL_DATETIME_SENT = "Отправлено:",
    SI_MAILHISTORY_MAIL_DATETIME_RTS = "Возвращено:",
    SI_MAILHISTORY_MAIL_DATETIME_RECEIVED = "Принято:",

    SI_MAILHISTORY_MAIL_TO = "Кому:",
    SI_MAILHISTORY_MAIL_TO_MULTIPLE = "(НЕСКОЛЬКО)",  -- Used in the history when the same mail is sent to multiple recipients.
    SI_MAILHISTORY_MAIL_FROM = "От кого:",
    SI_MAILHISTORY_MAIL_SYSTEM_PREFIX = "(Системное) <<1>>",  -- System mail gets this sender prefix.
    SI_MAILHISTORY_MAIL_CS_PREFIX = "(СПК) <<1>>",  -- Customer support mail gets this sender prefix.

    SI_MAILHISTORY_MAIL_SUBJECT = "Тема:",

    SI_MAILHISTORY_MAIL_ATTACHMENTS = "Вложения:",
    SI_MAILHISTORY_MAIL_ATTACHMENT_GOLD_SENT = "Отослано <<1>> золотых монет.",
    SI_MAILHISTORY_MAIL_ATTACHMENT_GOLD_RTS = "Возвращено <<1>> золотых монет.",
    SI_MAILHISTORY_MAIL_ATTACHMENT_GOLD_RECEIVED = "Принято <<1>> золотых монет.",
    SI_MAILHISTORY_MAIL_ATTACHMENT_COD_SENT = "Принято с отсрочкой платежа <<1>> золотых монет.",  -- Request COD when sending mail.
    SI_MAILHISTORY_MAIL_ATTACHMENT_COD_RTS = "Возвращено с отсрочкой платежа <<1>> золотых монет.",
    SI_MAILHISTORY_MAIL_ATTACHMENT_COD_RECEIVED = "Отослано с отсрочкой платежа <<1>> золотых монет.",  -- Send COD payment when receiving mail.
    SI_MAILHISTORY_MAIL_ATTACHMENT_MISSING = "Неизвестные вложения.",  -- Attachment info is missing.
    SI_MAILHISTORY_MAIL_ATTACHMENT_NONE = "Нет вложений.",

    -- CHAT

    -- Notification when the mail data is missing for a known mail identifier.  Some other addons process mail before Mail History can save the mail.
    SI_MAILHISTORY_CHAT_WARNING_MISSING_DATA = "Пропущена почта из-за других дополнений.",

}

for stringId, stringValue in pairs(langRu) do
    ZO_CreateStringId(stringId, stringValue)
    -- Use version 2 to have this string override the default because en/English is version 1.
    SafeAddVersion(stringId, 2)
end
