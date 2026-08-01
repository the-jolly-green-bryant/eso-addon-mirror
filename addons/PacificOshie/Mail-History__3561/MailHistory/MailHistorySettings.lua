-- MailHistory by @PacificOshie.  Have fun!

function MailHistory.LoadSettingsPanel()
    local LAM = LibAddonMenu2

    local panelName = "MailHistorySettingsPanel"
    local panelData = {
        type = "panel",
        name = "Mail History",
        author = "@PacificOshie",
        website = "https://www.esoui.com/downloads/info3561-MailHistory.html",
        slashCommand = "/mailhistorysettings",
    }
    local panel = LAM:RegisterAddonPanel(panelName, panelData)

    local optionsData = {
        {
            type = "description",
            text = GetString(SI_MAILHISTORY_SETTINGS_DESCRIPTION),
        },
        {
            type = "divider",
            alpha = 0,
        },
        {
            type = "header",
            name = GetString(SI_MAILHISTORY_SETTINGS_HISTORY_HEADER),
        },
        {
            type = "description",
            text = GetString(SI_MAILHISTORY_SETTINGS_HISTORY_DESCRIPTION),
        },
        {
            type = "checkbox",
            name = GetString(SI_MAILHISTORY_SETTINGS_AUTOTOGGLEMAINWINDOW),
            getFunc = function() return MailHistory.settings.autoToggleMainWindow end,
            setFunc = function(value) MailHistory.settings.autoToggleMainWindow = value end,
            default = true,
        },
        {
            type = "checkbox",
            name = GetString(SI_MAILHISTORY_SETTINGS_SHOWSYSTEMMAIL),
            getFunc = function() return MailHistory.settings.showSystemMail end,
            setFunc = function(value) MailHistory.settings.showSystemMail = value end,
            default = true,
            tooltip = GetString(SI_MAILHISTORY_SETTINGS_SHOWSYSTEMMAIL_TOOLTIP),
        },
        {
            type = "checkbox",
            name = GetString(SI_MAILHISTORY_SETTINGS_SHOWTOOLTIPSUMMARY),
            getFunc = function() return MailHistory.settings.showTooltipSummary end,
            setFunc = function(value) MailHistory.settings.showTooltipSummary = value end,
            default = false,
        },
        {
            type = "divider",
            alpha = 0,
        },
        {
            type = "header",
            name = GetString(SI_MAILHISTORY_SETTINGS_CHAT_HEADER),
        },
        {
            type = "description",
            text = GetString(SI_MAILHISTORY_SETTINGS_CHAT_DESCRIPTION),
        },
        {
            type = "checkbox",
            name = GetString(SI_MAILHISTORY_SETTINGS_CHATSENTMAIL),
            getFunc = function() return MailHistory.settings.chatSentMail end,
            setFunc = function(value) MailHistory.settings.chatSentMail = value end,
            default = false,
        },
        {
            type = "checkbox",
            name = GetString(SI_MAILHISTORY_SETTINGS_CHATREADMAIL),
            getFunc = function() return MailHistory.settings.chatReadMail end,
            setFunc = function(value) MailHistory.settings.chatReadMail = value end,
            default = false,
        },
        {
            type = "checkbox",
            name = GetString(SI_MAILHISTORY_SETTINGS_CHATWARNINGS),
            getFunc = function() return MailHistory.settings.chatWarnings end,
            setFunc = function(value) MailHistory.settings.chatWarnings = value end,
            default = false,
        },
        {
            type = "divider",
            alpha = 0,
        },
        {
            type = "header",
            name = GetString(SI_MAILHISTORY_SETTINGS_STORAGE_HEADER),
        },
        {
            type = "checkbox",
            name = GetString(SI_MAILHISTORY_SETTINGS_SAVESYSTEMMAIL),
            getFunc = function() return MailHistory.settings.saveSystemMail end,
            setFunc = function(value) MailHistory.settings.saveSystemMail = value end,
            default = true,
        },
        {
            type = "description",
            text = GetString(SI_MAILHISTORY_SETTINGS_STORAGE_DESCRIPTION),
        },
        {
            type = "slider",
            name = GetString(SI_MAILHISTORY_SETTINGS_NUMMAILTOKEEP),
            getFunc = function() return MailHistory.settings.numMailToKeep end,
            setFunc = function(value) MailHistory.settings.numMailToKeep = value end,
            min = MailHistory.SAVED_MAIL_MIN,
            max = MailHistory.SAVED_MAIL_MAX,
            default = MailHistory.SAVED_MAIL_DEFAULT,
        },
        {
            type = "description",
            text = zo_strformat(GetString(SI_MAILHISTORY_SETTINGS_STORAGE_DEFAULT), MailHistory.SAVED_MAIL_DEFAULT),
        },
        {
            type = "divider",
            alpha = 0,
        },
        {
            type = "header",
            name = GetString(SI_MAILHISTORY_SETTINGS_DATETIME_HEADER),
        },
        {
            type = "dropdown",
            name = GetString(SI_MAILHISTORY_SETTINGS_DISPLAYDATEFORMAT),
            choices = {
                zo_strformat(GetString(SI_MAILHISTORY_SETTINGS_DISPLAYDATEFORMAT_SYSTEM), os.date("%x")),
                "YYYY-MM-DD",
                "DD/MM/YYYY",
                "MM/DD/YYYY",
            },
            choicesValues = {
                "%x",
                "%Y-%m-%d",
                "%d/%m/%Y",
                "%m/%d/%Y",
            },
            getFunc = function() return MailHistory.settings.displayDateFormat end,
            setFunc = function(value) MailHistory.settings.displayDateFormat = value end,
            default = "%x",
        },
        {
            type = "dropdown",
            name = GetString(SI_MAILHISTORY_SETTINGS_DISPLAYTIMEFORMAT),
            choices = {
                zo_strformat(GetString(SI_MAILHISTORY_SETTINGS_DISPLAYTIMEFORMAT_SYSTEM), os.date("%X")),
                "24:mm:ss",
                "12:mm:ss XM",
            },
            choicesValues = {
                "%X",
                "%H:%M:%S",
                "%I:%M:%S %p",
            },
            getFunc = function() return MailHistory.settings.displayTimeFormat end,
            setFunc = function(value) MailHistory.settings.displayTimeFormat = value end,
            default = "%X",
        },
        {
            type = "divider",
            alpha = 0,
        },
        {
            type = "header",
            name = GetString(SI_MAILHISTORY_SETTINGS_EXPORT_HEADER),
        },
        {
            type = "dropdown",
            name = GetString(SI_MAILHISTORY_SETTINGS_EXPORT_SEPARATOR),
            choices = {
                GetString(SI_MAILHISTORY_SETTINGS_EXPORT_SEPARATOR_TAB),
                GetString(SI_MAILHISTORY_SETTINGS_EXPORT_SEPARATOR_COMMA),
            },
            choicesValues = {
                "\t",
                ",",
            },
            getFunc = function() return MailHistory.settings.exportSeparator end,
            setFunc = function(value) MailHistory.settings.exportSeparator = value end,
            default = "\t",
            tooltip = GetString(SI_MAILHISTORY_SETTINGS_EXPORT_SEPARATOR_TOOLTIP),
        },
    }
    LAM:RegisterOptionControls(panelName, optionsData)
end