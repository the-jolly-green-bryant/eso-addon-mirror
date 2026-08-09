-- MailHistoryConsole settings.lua — Harvens panel.
--
-- This file is new in the console port.  It replaces MailHistorySettings.lua
-- (LibAddonMenu-2), since LAM doesn't exist on console.
--
-- Original Mail History addon by @PacificOshie.

MailHistory = MailHistory or {}

function MailHistory.registerSettings()
    if MailHistory._settingsRegistered then return end
    MailHistory._settingsRegistered = true

    local LHAS = LibHarvensAddonSettings
    if not LHAS then
        d("|cFF0000[MailHistoryConsole] LibHarvensAddonSettings not loaded — settings panel unavailable")
        return
    end

    local panel = LHAS:AddAddon("Mail History", { allowDefaults = true })
    if not panel then return end

    -- Subtitle/byline in the gamepad settings header.
    panel.version = "1"
    panel.author = "@PacificOshie"

    local settings = MailHistory.settings

    panel:AddSetting({
        type = LHAS.ST_LABEL,
        label = GetString(SI_MAILHISTORY_SETTINGS_DESCRIPTION),
    })

    -- HISTORY

    panel:AddSetting({
        type = LHAS.ST_SECTION,
        label = GetString(SI_MAILHISTORY_SETTINGS_HISTORY_HEADER),
    })

    panel:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = GetString(SI_MAILHISTORY_SETTINGS_SHOWSYSTEMMAIL),
        tooltip = GetString(SI_MAILHISTORY_SETTINGS_SHOWSYSTEMMAIL_TOOLTIP),
        default = true,
        getFunction = function() return settings.showSystemMail end,
        setFunction = function(v) settings.showSystemMail = v; MailHistory.RefreshHistoryList() end,
    })

    panel:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = GetString(SI_MAILHISTORY_SETTINGS_SAVESYSTEMMAIL),
        default = true,
        getFunction = function() return settings.saveSystemMail end,
        setFunction = function(v) settings.saveSystemMail = v end,
    })

    local TEXT_SIZE_ITEMS = {
        { name = GetString(SI_MAILHISTORY_SETTINGS_LISTTEXTSIZE_SMALL), key = "small" },
        { name = GetString(SI_MAILHISTORY_SETTINGS_LISTTEXTSIZE_MEDIUM), key = "medium" },
        { name = GetString(SI_MAILHISTORY_SETTINGS_LISTTEXTSIZE_LARGE), key = "large" },
    }

    local function ItemNameForKey(items, key)
        for _, item in ipairs(items) do
            if item.key == key then return item.name end
        end
        return items[1].name
    end

    panel:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = GetString(SI_MAILHISTORY_SETTINGS_LISTTEXTSIZE),
        items = TEXT_SIZE_ITEMS,
        default = TEXT_SIZE_ITEMS[2].name,
        getFunction = function() return ItemNameForKey(TEXT_SIZE_ITEMS, settings.listTextSize) end,
        setFunction = function(combobox, name, item) settings.listTextSize = item.key; MailHistory.RefreshHistoryList() end,
    })

    -- CHAT

    panel:AddSetting({
        type = LHAS.ST_SECTION,
        label = GetString(SI_MAILHISTORY_SETTINGS_CHAT_HEADER),
    })

    panel:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = GetString(SI_MAILHISTORY_SETTINGS_CHATSENTMAIL),
        default = false,
        getFunction = function() return settings.chatSentMail end,
        setFunction = function(v) settings.chatSentMail = v end,
    })

    panel:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = GetString(SI_MAILHISTORY_SETTINGS_CHATREADMAIL),
        default = false,
        getFunction = function() return settings.chatReadMail end,
        setFunction = function(v) settings.chatReadMail = v end,
    })

    panel:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = GetString(SI_MAILHISTORY_SETTINGS_CHATWARNINGS),
        default = false,
        getFunction = function() return settings.chatWarnings end,
        setFunction = function(v) settings.chatWarnings = v end,
    })

    -- STORAGE

    panel:AddSetting({
        type = LHAS.ST_SECTION,
        label = GetString(SI_MAILHISTORY_SETTINGS_STORAGE_HEADER),
    })

    panel:AddSetting({
        type = LHAS.ST_SLIDER,
        label = GetString(SI_MAILHISTORY_SETTINGS_NUMMAILTOKEEP),
        tooltip = GetString(SI_MAILHISTORY_SETTINGS_STORAGE_DESCRIPTION),
        min = MailHistory.SAVED_MAIL_MIN,
        max = MailHistory.SAVED_MAIL_MAX,
        step = 100,
        format = "%d",
        default = MailHistory.SAVED_MAIL_DEFAULT,
        getFunction = function() return settings.numMailToKeep end,
        setFunction = function(v) settings.numMailToKeep = v; MailHistory.DataTableUpdated() end,
    })

    -- DATE AND TIME

    panel:AddSetting({
        type = LHAS.ST_SECTION,
        label = GetString(SI_MAILHISTORY_SETTINGS_DATETIME_HEADER),
    })

    local DATE_ITEMS = {
        { name = zo_strformat(GetString(SI_MAILHISTORY_SETTINGS_DISPLAYDATEFORMAT_SYSTEM), os.date("%x")), format = "%x" },
        { name = "YYYY-MM-DD", format = "%Y-%m-%d" },
        { name = "DD/MM/YYYY", format = "%d/%m/%Y" },
        { name = "MM/DD/YYYY", format = "%m/%d/%Y" },
    }
    local TIME_ITEMS = {
        { name = zo_strformat(GetString(SI_MAILHISTORY_SETTINGS_DISPLAYTIMEFORMAT_SYSTEM), os.date("%X")), format = "%X" },
        { name = "24:mm:ss", format = "%H:%M:%S" },
        { name = "12:mm:ss XM", format = "%I:%M:%S %p" },
    }

    local function ItemNameForFormat(items, fmt)
        for _, item in ipairs(items) do
            if item.format == fmt then return item.name end
        end
        return items[1].name
    end

    panel:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = GetString(SI_MAILHISTORY_SETTINGS_DISPLAYDATEFORMAT),
        items = DATE_ITEMS,
        default = DATE_ITEMS[1].name,
        getFunction = function() return ItemNameForFormat(DATE_ITEMS, settings.displayDateFormat) end,
        -- LHAS dropdown callback: (combobox, name, itemTable) — itemTable is ours, read .format.
        setFunction = function(combobox, name, item) settings.displayDateFormat = item.format end,
    })

    panel:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = GetString(SI_MAILHISTORY_SETTINGS_DISPLAYTIMEFORMAT),
        items = TIME_ITEMS,
        default = TIME_ITEMS[1].name,
        getFunction = function() return ItemNameForFormat(TIME_ITEMS, settings.displayTimeFormat) end,
        setFunction = function(combobox, name, item) settings.displayTimeFormat = item.format end,
    })
end
