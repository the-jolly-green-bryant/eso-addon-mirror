PotionReminder = PotionReminder or {}

local unlockUI = false

function PotionReminder.onGetUnlockUI()
    return unlockUI
end

function PotionReminder.onSetUnlockUI(value)
    if value then
        PotionReminder.unlockUI()
    else 
        PotionReminder.lockUI()
    end
    unlockUI = value
end

function PotionReminder.onResetPosition()
    PotionReminderNotification:ClearAnchors()
    PotionReminderNotification:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PotionReminder.defaultSavedVariables.xPos, PotionReminder.defaultSavedVariables.yPos)
    PotionReminder.savedVariables.xPos = PotionReminder.defaultSavedVariables.xPos
    PotionReminder.savedVariables.yPos = PotionReminder.defaultSavedVariables.yPos
end

function PotionReminder.onGetNotificationColour()
    return unpack(PotionReminder.savedVariables.notificationColour)
end

function PotionReminder.onSetNotificationColour(r, g, b, a)
    local colour = { r, g, b, a }
    PotionReminder.savedVariables.notificationColour = colour
    PotionReminder.setNotificationColour(colour)
end

function PotionReminder.onGetAutoHideNotification()
    return PotionReminder.savedVariables.autoHideNotification
end

function PotionReminder.onSetAutoHideNotification(value)
    PotionReminder.savedVariables.autoHideNotification = value
    PotionReminderNotificationDurationSlider:UpdateDisabled()
end

function PotionReminder.onGetNotificationDuration()
    return PotionReminder.savedVariables.notificationDuration
end

function PotionReminder.onSetNotificationDuration(value)
    PotionReminder.savedVariables.notificationDuration = value
end

function PotionReminder.onGetNotificationDurationSliderDisabled()
    return not PotionReminder.savedVariables.autoHideNotification
end

function PotionReminder.onGetNotifyOnNormalDifficulty()
    return PotionReminder.savedVariables.notifyOnNormalDifficulty
end

function PotionReminder.onSetNotifyOnNormalDifficulty(value)
    PotionReminder.savedVariables.notifyOnNormalDifficulty = value
end

function PotionReminder.onGetNotifyInTrashFights()
    return PotionReminder.savedVariables.notifyInTrashFights
end

function PotionReminder.onSetNotifyInTrashFights(value)
    PotionReminder.savedVariables.notifyInTrashFights = value
end

function PotionReminder.setupMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Potion Reminder",
        author = "Kamaros",
        version = PotionReminder.version
    }
    LAM:RegisterAddonPanel(PotionReminder.name .. "Menu", panelData)

    local optionsData = {
        {
            type = "header",
            name = "Position/Appearance"
        },
        {
            type = "checkbox",
            name = "Unlock UI",
            tooltip = "Unlock to position notification in desired position",
            getFunc = PotionReminder.onGetUnlockUI,
            setFunc = PotionReminder.onSetUnlockUI
        },
        {
            type = "button",
            name = "Reset Position",
            func = PotionReminder.onResetPosition
        },
        {
            type = "colorpicker",
            name = "Notification Colour",
            tooltip = "Colour of the \"Drink Potion!\" notification",
            getFunc = PotionReminder.onGetNotificationColour,
            setFunc = PotionReminder.onSetNotificationColour
        },
        {
            type = "header",
            name = "Behaviour"
        },
        {
            type = "checkbox",
            name = "Automatically Hide Notification",
            tooltip = "Automatically hide the \"Drink Potion!\" notification after a certain duration",
            getFunc = PotionReminder.onGetAutoHideNotification,
            setFunc = PotionReminder.onSetAutoHideNotification,
        },
        {
            type = "slider",
            name = "Display Time",
            tooltip = "How long to display the \"Drink Potion!\" notification before hiding it",
            min = 1,
            max = 5,
            step = 0.5,
            getFunc = PotionReminder.onGetNotificationDuration,
            setFunc = PotionReminder.onSetNotificationDuration,
            disabled = PotionReminder.onGetNotificationDurationSliderDisabled,
            reference = "PotionReminderNotificationDurationSlider"
        },
        {
            type = "divider"
        },
        {
            type = "checkbox",
            name = "Notify On Normal Difficulty",
            getFunc = PotionReminder.onGetNotifyOnNormalDifficulty,
            setFunc = PotionReminder.onSetNotifyOnNormalDifficulty
        },
        {
            type = "checkbox",
            name = "Notify In Trash Fights",
            getFunc = PotionReminder.onGetNotifyInTrashFights,
            setFunc = PotionReminder.onSetNotifyInTrashFights
        },
    }
    LAM:RegisterOptionControls(PotionReminder.name .. "Menu", optionsData)
end