local strings = {

    BREAKREMINDER_OPTION_DESCRIPTION = "Reminds you (and @Iriidsuke as well) to have a break from time to time !",
    BREAKREMINDER_OPTION_ACCOUNT_WIDE = "Use account wide paramaters",
    BREAKREMINDER_OPTION_ACCOUNT_WIDE_TOOLTIP = "Switching between local and global profiles will reload the interface.",
    BREAKREMINDER_OPTION_NOTIFICATION_DELAY_DESCRIPTION = "Time between each notification",
    BREAKREMINDER_OPTION_NOTIFICATION_DELAY_TOOLTIP = "In minutes",
    BREAKREMINDER_OPTION_NOTIFICATION_COLOR_DESCRIPTION = "Color of the notification",
    BREAKREMINDER_OPTION_NOTIFICATION_COLOR_TOOLTIP = "",
    BREAKREMINDER_OPTION_NOTIFICATION_DURATION_DESCRIPTION = "Duration of the notification",
    BREAKREMINDER_OPTION_NOTIFICATION_DURATION_TOOLTIP = "In seconds",
    BREAKREMINDER_OPTION_NOTIFICATION_COMBAT_DESCRIPTION = "Notify during fights",
    BREAKREMINDER_OPTION_NOTIFICATION_COMBAT_TOOLTIP = "If set to no, notification will be shown after the fight",
    BREAKREMINDER_OPTION_NOTIFICATION_RESET_DESCRIPTION = "Reset the timer",
    BREAKREMINDER_OPTION_NOTIFICATION_RESET_TOOLTIP = "Timer will start again from now",
    BREAKREMINDER_OPTION_REMINDER = "Reminders",
    BREAKREMINDER_DIALOG_TITLE = "Reminder",
    BREAKREMINDER_DIALOG_ADD = "Define a reminder",
    BREAKREMINDER_DIALOG_INSTRUCTION = "Define a reminder in ",
    BREAKREMINDER_DIALOG_IN = "In <<1>> minutes:",
    BREAKREMINDER_DIALOG_MINUTES = "minutes",
    BREAKREMINDER_DIALOG_REMEMBER = "Remember at next login",
    BREAKREMINDER_NOTIF_REMINDER_ADDED = "Reminder added.",
    BREAKREMINDER_NOTIF_IN = "Reminder in <<1>> minutes : <<2>>",
    BREAKREMINDER_NOTIF_UNKNOWN = "Didn't you forget something?",
    BREAKREMINDER_NOTIF_TOO_MUCH = "You must delete some reminders before adding some more!",

    BREAKREMINDER_BREAK_TITLE = "It's time for a break!",
    BREAKREMINDER_BREAK_TEXT = "You should have a drink, a walk, or a pee!",
    BREAKREMINDER_BREAK_START = "Will remind you to have a break in <<1>> minutes!",

    MOUTON_AUTHOR_FEEDBACK_MAIL = "In-game mail feedback",
    MOUTON_AUTHOR_FEEDBACK_MAIL_HEADER = "Feedback for <<1>> (<<2>>)",
    MOUTON_AUTHOR_FEEDBACK_ESOUI = "ESOUI comments",
    MOUTON_AUTHOR_DONATE_GOLD = "Donation in gold",
    MOUTON_AUTHOR_DONATE_GOLD_HEADER = "Donation for <<1>>",
    MOUTON_AUTHOR_DONATE_ESOUI = "ESOUI donation page",
    MOUTON_AUTHOR_DONATE_CROWNS = "Donation in crowns"
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
