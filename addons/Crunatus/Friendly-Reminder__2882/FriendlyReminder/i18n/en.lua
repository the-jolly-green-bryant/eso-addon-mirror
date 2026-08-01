local localization_strings = {
	-- Day of Week
	SI_FRIENDLYREMINDER_WEEKDAY1 = "Monday",
	SI_FRIENDLYREMINDER_WEEKDAY2 = "Tuesday",
	SI_FRIENDLYREMINDER_WEEKDAY3 = "Wednesday",
	SI_FRIENDLYREMINDER_WEEKDAY4 = "Thursday",
	SI_FRIENDLYREMINDER_WEEKDAY5 = "Friday",
	SI_FRIENDLYREMINDER_WEEKDAY6 = ZO_ERROR_COLOR:Colorize("Saturday"),
	SI_FRIENDLYREMINDER_WEEKDAY7 = ZO_ERROR_COLOR:Colorize("Sunday"),
	
	-- Month
	SI_FRIENDLYREMINDER_MONTH1 = "January",
	SI_FRIENDLYREMINDER_MONTH2 = "February",
	SI_FRIENDLYREMINDER_MONTH3 = "March",
	SI_FRIENDLYREMINDER_MONTH4 = "April",
	SI_FRIENDLYREMINDER_MONTH5 = "May",
	SI_FRIENDLYREMINDER_MONTH6 = "June",
	SI_FRIENDLYREMINDER_MONTH7 = "July",
	SI_FRIENDLYREMINDER_MONTH8 = "August",
	SI_FRIENDLYREMINDER_MONTH9 = "September",
	SI_FRIENDLYREMINDER_MONTH10 = "October",
	SI_FRIENDLYREMINDER_MONTH11 = "November",
	SI_FRIENDLYREMINDER_MONTH12 = "December",
	
	-- Settings
	SI_FRIENDLYREMINDER_DELETE_DAILY = "Delete ALL daily reminders. This action cannot be undone.",
	SI_FRIENDLYREMINDER_DELETE_MONTH = "Delete ALL reminders for %s. This action cannot be undone.",
	
	SI_FRIENDLYREMINDER_SHOW_ONCE = "Show Only Once",
	SI_FRIENDLYREMINDER_SHOW_ONCE_DESC = "Show reminders only once a day.",

	SI_FRIENDLYREMINDER_SHOW_CHAT = "Show In Chat",
	SI_FRIENDLYREMINDER_SHOW_CHAT_DESC = "Show a message in the chat window.",
	
	SI_FRIENDLYREMINDER_SHOW_ANNOUNCEMENT = "Show Announcement",
	SI_FRIENDLYREMINDER_SHOW_ANNOUNCEMENT_DESC = "Show announcement on the screen.",

	SI_FRIENDLYREMINDER_SEND_NOTIFICATION = "Send Notification",
	SI_FRIENDLYREMINDER_SEND_NOTIFICATION_DESC = "Send notification message.\n\n'Circonians LibNotifications' required.",
	
	SI_FRIENDLYREMINDER_START_TIME = "A new day begins at",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(tostring(stringId), stringValue)
   SafeAddVersion(stringId, 1)
end