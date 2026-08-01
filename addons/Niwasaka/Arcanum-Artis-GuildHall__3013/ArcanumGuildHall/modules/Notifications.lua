local ArcanumGuildHall = _G["ArcanumGuildHall"]

local LN = LibNotifications
local LN_provider = LN:CreateProvider()

local activeReminderNotification = nil
local activeFirstTimeNotification = nil
local REMINDER_UPDATE_NAME = ArcanumGuildHall.name .. "_ReminderNotification"

local function removeNotificationByReference(notification)
    if not notification then
        return
    end

    for index, entry in ipairs(LN_provider.notifications) do
        if entry == notification then
            table.remove(LN_provider.notifications, index)
            LN_provider:UpdateNotifications()
            return
        end
    end
end

local function acceptNotification(notification)
    ArcanumGuildHall.db.showReminder = false
    activeReminderNotification = nil
    removeNotificationByReference(notification)
end

local function declineNotification(notification)
    ArcanumGuildHall.db.showReminder = true
    activeReminderNotification = nil
    removeNotificationByReference(notification)
end

local function addNotification()
    EVENT_MANAGER:UnregisterForUpdate(REMINDER_UPDATE_NAME)

    if activeReminderNotification then
        return
    end

    local msg = {
        dataType = NOTIFICATIONS_REQUEST_DATA,
        secsSinceRequest = ZO_NormalizeSecondsSince(0),
        message = ArcanumGuildHall.db.defaultNotMessage or ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_TEXT"),
        heading = ArcanumGuildHall.db.defaultNotTitle or ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_TITLE"),
        texture = "ArcanumGuildHall/imgs/aaguild.dds",
        shortDisplayText = "!",
        controlsOwnSounds = false,
    }

    msg.keyboardAcceptCallback = function()
        acceptNotification(msg)
    end
    msg.keyboardDeclineCallback = function()
        declineNotification(msg)
    end
    msg.gamepadAcceptCallback = function()
        acceptNotification(msg)
    end
    msg.gamepadDeclineCallback = function()
        declineNotification(msg)
    end

    activeReminderNotification = msg
    table.insert(LN_provider.notifications, msg)
    LN_provider:UpdateNotifications()
end

function ArcanumGuildHall:ShowFirstTimeInfo()
    if self.db.firstTimeInfoShown or activeFirstTimeNotification then
        return
    end

    self.db.firstTimeInfoShown = true

    local msg = {
        dataType = NOTIFICATIONS_REQUEST_DATA,
        secsSinceRequest = ZO_NormalizeSecondsSince(0),
        message = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_MESSAGE_FIRST"),
        heading = ArcanumGuildHall.GetDefaultLocaleString("SETTINGS_NOTIFICATION_TITLE"),
        texture = "ArcanumGuildHall/imgs/aaguild.dds",
        shortDisplayText = "!",
        controlsOwnSounds = false,
    }

    msg.keyboardAcceptCallback = function()
        self.db.enableReminder = true
        activeFirstTimeNotification = nil
        removeNotificationByReference(msg)
        self:ShowNotification()
    end
    msg.keyboardDeclineCallback = function()
        self.db.enableReminder = false
        activeFirstTimeNotification = nil
        removeNotificationByReference(msg)
    end
    msg.gamepadAcceptCallback = msg.keyboardAcceptCallback
    msg.gamepadDeclineCallback = msg.keyboardDeclineCallback

    activeFirstTimeNotification = msg
    table.insert(LN_provider.notifications, msg)
    LN_provider:UpdateNotifications()
end

function ArcanumGuildHall:ShowNotification()
    if not self.db.enableReminder then
        return
    end

    local currentDay = os.date("%A")

    if self.db.selectedReminderDay ~= currentDay then
        self.db.showReminder = true
        return
    end

    if self.db.showReminder and not activeReminderNotification then
        EVENT_MANAGER:UnregisterForUpdate(REMINDER_UPDATE_NAME)
        EVENT_MANAGER:RegisterForUpdate(REMINDER_UPDATE_NAME, 1, addNotification)
    end
end

function ArcanumGuildHall:ShowAnnouncementNotification(msg)
    local notification = {
        dataType = NOTIFICATIONS_ALERT_DATA,
        secsSinceRequest = ZO_NormalizeSecondsSince(0),
        message = msg,
        heading = ArcanumGuildHall.GetDefaultLocaleString("ANNOUNCEMENTS_TEXT"),
        texture = "ArcanumGuildHall/imgs/aaguild.dds",
        shortDisplayText = "!",
        controlsOwnSounds = false,
    }

    local function dismiss()
        removeNotificationByReference(notification)
    end

    notification.keyboardAcceptCallback = dismiss
    notification.keyboardDeclineCallback = dismiss
    notification.gamepadAcceptCallback = dismiss
    notification.gamepadDeclineCallback = dismiss

    table.insert(LN_provider.notifications, notification)
    LN_provider:UpdateNotifications()
end