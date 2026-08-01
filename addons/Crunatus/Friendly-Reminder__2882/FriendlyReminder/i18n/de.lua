local localization_strings = {
	-- Day of Week
	SI_FRIENDLYREMINDER_WEEKDAY1 = "Montag",
	SI_FRIENDLYREMINDER_WEEKDAY2 = "Dienstag",
	SI_FRIENDLYREMINDER_WEEKDAY3 = "Mittwoch",
	SI_FRIENDLYREMINDER_WEEKDAY4 = "Donnerstag",
	SI_FRIENDLYREMINDER_WEEKDAY5 = "Freitag",
	SI_FRIENDLYREMINDER_WEEKDAY6 = ZO_ERROR_COLOR:Colorize("Samstag"),
	SI_FRIENDLYREMINDER_WEEKDAY7 = ZO_ERROR_COLOR:Colorize("Sonntag"),
	
	-- Month
	SI_FRIENDLYREMINDER_MONTH1 = "Januar",
	SI_FRIENDLYREMINDER_MONTH2 = "Februar",
	SI_FRIENDLYREMINDER_MONTH3 = "März",
	SI_FRIENDLYREMINDER_MONTH4 = "April",
	SI_FRIENDLYREMINDER_MONTH5 = "Mai",
	SI_FRIENDLYREMINDER_MONTH6 = "Juni",
	SI_FRIENDLYREMINDER_MONTH7 = "Juli",
	SI_FRIENDLYREMINDER_MONTH8 = "August",
	SI_FRIENDLYREMINDER_MONTH9 = "September",
	SI_FRIENDLYREMINDER_MONTH10 = "Oktober",
	SI_FRIENDLYREMINDER_MONTH11 = "November",
	SI_FRIENDLYREMINDER_MONTH12 = "Dezember",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(tostring(stringId), stringValue)
   SafeAddVersion(stringId, 1)
end