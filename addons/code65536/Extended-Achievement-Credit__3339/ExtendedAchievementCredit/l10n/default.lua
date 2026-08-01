if (LibMultiAccountAchievements or LibAchievementsArchive) then
	local Register = LibCodesCommonCode.RegisterString

	Register("SI_EAC_TITLE"       , "Extended Achievement Credit")

	Register("SI_EAC_EARNED"      , "Earned")
	Register("SI_EAC_UNEARNED"    , "Unearned")
	Register("SI_EAC_HISTORICAL"  , "Historical Credit")

	Register("SI_EAC_DATES_FIRST" , "Show the dates column first")
	Register("SI_EAC_HIDE_TIMES"  , "Hide times from the dates column")

	Register("SI_EAC_HIST_MODES"  , "Show historical achievement credit for")
	Register("SI_EAC_HIST_MODE0"  , GetString(SI_CHECK_BUTTON_DISABLED))
	Register("SI_EAC_HIST_MODE1"  , "Current character")
	Register("SI_EAC_HIST_MODE2"  , "Current account")
	Register("SI_EAC_HIST_MODE3"  , "All accounts and servers")

	Register("SI_EAC_CHAR_MODES"  , "Show character-specific achievement credit for")
	Register("SI_EAC_CHAR_MODE1"  , "Current server")
	SI_EAC_CHAR_MODE2 = SI_EAC_HIST_MODE2
	SI_EAC_CHAR_MODE3 = SI_EAC_HIST_MODE3

	Register("SI_EAC_CHAT_UPDATE" , "Show updates to achievement progress in chat")
end
