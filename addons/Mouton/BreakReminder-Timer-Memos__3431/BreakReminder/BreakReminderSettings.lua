local BR = BreakReminder

BreakReminder.settings = {}
local settings = {}

function settings.__index(self, key)
    local sets = BR.GetSettings()
    return sets[key]
end

function settings.__newindex(self, key, value)
    local sets = BR.GetSettings()
    sets[key] = value
end

setmetatable(BR.settings, settings)

local function GetItem(k)
    local i = 1
    for _, item in pairs(BR.settings.reminders) do
        if i == k then
            return item
        end
        i = i + 1
    end
    return nil
end

local function draftMail(gold)
    local isDonation = gold and gold > 0
    local headerString = GetString(isDonation and MOUTON_AUTHOR_DONATE_GOLD_HEADER or MOUTON_AUTHOR_FEEDBACK_MAIL_HEADER)

    ZO_MailSendToField:SetText(BR.options.recipient:sub(1, 1) == "@" and BR.options.recipient or "@" .. BR.options.recipient)
    ZO_MailSendSubjectField:SetText(zo_strformat(headerString, BR.options.name, BR.options.version))
    ZO_MailSendBodyField:TakeFocus()

    if isDonation then
        QueueMoneyAttachment(gold)
        ZO_MailSendSendCurrency:OnBeginInput()
    else
        ZO_MailSendBodyField:TakeFocus()
    end
end

local function showMail(gold)
    SCENE_MANAGER:Show('mailSend')
    zo_callLater(function() draftMail(gold) end, 250)
end

function BR.options.feedback()
    ClearMenu()
    local isEUServer = GetWorldName() == "EU Megaserver"
    if isEUServer then AddCustomMenuItem(GetString(MOUTON_AUTHOR_FEEDBACK_MAIL), function() showMail() end) end
    AddCustomMenuItem(GetString(MOUTON_AUTHOR_FEEDBACK_ESOUI), function() RequestOpenUnsafeURL(BR.options.website .. "#comments") end)
    ShowMenu()
end

function BR.options.donation()
    ClearMenu()
    local isEUServer = GetWorldName() == "EU Megaserver"
    if isEUServer then AddCustomMenuItem(GetString(MOUTON_AUTHOR_DONATE_GOLD), function() showMail(5000) end) end
    if isEUServer then AddCustomMenuItem(GetString(MOUTON_AUTHOR_DONATE_CROWNS), function() SCENE_MANAGER:Show("show_market") end) end
    AddCustomMenuItem(GetString(MOUTON_AUTHOR_DONATE_ESOUI), function() RequestOpenUnsafeURL(BR.options.website .. "#donate") end)
    ShowMenu()
end

function BR.RefreshSettings()
    local control = GetControl("BRSettingsReminders")
    if (control) then
        LibAddonMenu2.util.RequestRefreshIfNeeded(control)
    end
end

function BR.SetupReminderSettings()
    local controls = {}

    table.insert(controls, {
        type = "button",
        width = "full",
        name = GetString(BREAKREMINDER_DIALOG_ADD),
        func = function() BR.dialogs_show("BREAKREMINDER_EDIT_TIMER") end,
    })

    for i = 1, BR.options.max_reminders do
        table.insert(controls, {
            type = "reminder",
            name = "Reminder" .. i,
            isMultiline = true,
            width = "full",
            getFunc = function() return GetItem(i) end,
            func = function() BR.RemoveReminder(GetItem(i)) end,
        })
    end
    return controls
end

function BR.GetSettings()
    if (BR.accountSettings.accountWide) then
        return BR.accountSettings
    else
        return BR.localSettings
    end
end

function BreakReminder:CreateAddonMenu()
    local LAM = LibAddonMenu2
    local i = 0

    local panel = LAM:RegisterAddonPanel(BR.name .. "Options", BR.options)

    local optionsData = {
        {
            type = "description",
            title = nil,
            text = GetString(BREAKREMINDER_OPTION_DESCRIPTION),
            width = "full",
        },
        {
            type = "header",
            name = "",
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(BREAKREMINDER_OPTION_ACCOUNT_WIDE),
            warning = GetString(BREAKREMINDER_OPTION_ACCOUNT_WIDE_TOOLTIP),
            getFunc = function() return BR.accountSettings.accountWide end,
            setFunc = function(value)
                BR.accountSettings.accountWide, BR.localSettings.accountWide = value, value
                if (BR.accountSettings.accountWide) then
                    for k, v in pairs(BR.defaultSettings) do
                        BR.accountSettings[k] = BR.localSettings[k]
                    end
                else
                    for k, v in pairs(BR.defaultSettings) do
                        BR.localSettings[k] = BR.accountSettings[k]
                    end
                end
                ReloadUI()
            end,
            width = "full"
        },
        {
            type = "slider",
            min = 5,
            max = 240,
            step = 5,
            name = GetString(BREAKREMINDER_OPTION_NOTIFICATION_DELAY_DESCRIPTION),
            tooltip = GetString(BREAKREMINDER_OPTION_NOTIFICATION_DELAY_TOOLTIP),
            getFunc = function() return BR.settings.notificationDelay end,
            setFunc = function(value)
                BR.settings.notificationDelay = value
                BR.ResetTimer()
            end,
            width = "full"
        },
        {
            type = "colorpicker",
            name = GetString(BREAKREMINDER_OPTION_NOTIFICATION_COLOR_DESCRIPTION),
            tooltip = GetString(BREAKREMINDER_OPTION_NOTIFICATION_COLOR_TOOLTIP),
            getFunc = function() return unpack(BR.settings.notificationColour) end,
            setFunc = function(r, g, b, a) BR.settings.notificationColour = { r, g, b, a } end,
            width = "full"
        },
        {
            type = "slider",
            min = 1,
            max = 60,
            name = GetString(BREAKREMINDER_OPTION_NOTIFICATION_DURATION_DESCRIPTION),
            tooltip = GetString(BREAKREMINDER_OPTION_NOTIFICATION_DURATION_TOOLTIP),
            getFunc = function() return BR.settings.notificationDuration end,
            setFunc = function(value) BR.settings.notificationDuration = value end,
            width = "full"
        },
        {
            type = "checkbox",
            name = GetString(BREAKREMINDER_OPTION_NOTIFICATION_COMBAT_DESCRIPTION),
            tooltip = GetString(BREAKREMINDER_OPTION_NOTIFICATION_COMBAT_TOOLTIP),
            getFunc = function() return BR.settings.notificationDuringFights end,
            setFunc = function(value) BR.settings.notificationDuringFights = value end,
            width = "full"
        },
        {
            type = "button",
            name = GetString(BREAKREMINDER_OPTION_NOTIFICATION_RESET_DESCRIPTION),
            tooltip = GetString(BREAKREMINDER_OPTION_NOTIFICATION_RESET_TOOLTIP),
            width = "full",
            func = function() BR.ResetTimer() end,
        },
        {
            type = "submenu",
            name = GetString(BREAKREMINDER_OPTION_REMINDER),
            reference = "BRSettingsReminders",
            controls = BR.SetupReminderSettings()
        }
    }

    BR.SetupReminderSettings()
    LAM:RegisterOptionControls(BR.name .. "Options", optionsData)
end
