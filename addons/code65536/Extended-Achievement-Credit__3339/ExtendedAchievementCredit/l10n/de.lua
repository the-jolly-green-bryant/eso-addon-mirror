-- Translated by: @ninibini

if (LibMultiAccountAchievements or LibAchievementsArchive) then
	local Register = LibCodesCommonCode.RegisterString

	Register("SI_EAC_EARNED"      , "Erreichte Ziele")
	Register("SI_EAC_UNEARNED"    , "Offene Ziele")
	Register("SI_EAC_HISTORICAL"  , "Errungenschaftshistorie")

	Register("SI_EAC_DATES_FIRST" , "Datumspalte zuerst anzeigen")
	Register("SI_EAC_HIDE_TIMES"  , "Keine Uhrzeit in der Datumspalte anzeigen")

	Register("SI_EAC_HIST_MODES"  , "Errungenschaftshistorie anzeigen für")
	Register("SI_EAC_HIST_MODE1"  , "Aktueller Charakter")
	Register("SI_EAC_HIST_MODE2"  , "Aktueller Account")
	Register("SI_EAC_HIST_MODE3"  , "Alle Accounts und Server")

	Register("SI_EAC_CHAR_MODES"  , "Charakter Errungenschaften anzeigen für")
	Register("SI_EAC_CHAR_MODE1"  , "Aktueller Server")

	Register("SI_EAC_CHAT_UPDATE" , "Fortschritt der Errungenschaften im Chat anzeigen")
end
