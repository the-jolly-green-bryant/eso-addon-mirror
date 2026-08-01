local strings = {
	GNOTIF_OPTIONS_H = "Options",

	GNOTIF_NOTIFY = "Notify connections",
	GNOTIF_NOTIFY_TT = "Display a message when guild members log in or log out",

	GNOTIF_NOTIFINTAB = "Display notification",
	GNOTIF_NOTIFINTAB_TT = "Select where to display the notification",
	GNOTIF_NOTIFINTAB1 = "In first tab",
	GNOTIF_NOTIFINTAB2 = "Everywhere the guildchat is displayed",

	GNOTIF_FRIENDORGUILD = "Notify friends in my guild",
	GNOTIF_FRIENDORGUILD_TT = "Choose which message to display when a friend is in the same guild as me",
	GNOTIF_FRIENDORGUILD1 = "Only show Friend message",
	GNOTIF_FRIENDORGUILD2 = "Only show Guild message",

	GNOTIF_CUSTOMCOLOR = "Message color",
	GNOTIF_CUSTOMCOLOR_TT = "Select the color of the message",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
