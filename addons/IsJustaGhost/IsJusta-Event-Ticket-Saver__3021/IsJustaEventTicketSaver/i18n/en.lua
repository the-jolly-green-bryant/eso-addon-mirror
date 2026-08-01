------------------------------------------------
-- English localization for IsJustaEventTicketSaver
------------------------------------------------

local strings = {
	SI_IJA_EVENTTICKETSAVER_NOSPACE = "You will lose Event tickets if you turn this quest in without spending some tickets first.",
	SI_IJA_EVENTTICKETSAVER_ALERT = "Too Many Tickets",
	SI_IJA_EVENTTICKETSAVER_OPTIONTEXT = "[<<1>>/<<2>> Tickets] <<3>>",

	SI_IJA_EVENTTICKETSAVER_TARGET_TIMER = "Tickets in <<1>>",
	SI_IJA_EVENTTICKETSAVER_TICKETS_AVAILABLE = "Tickets Available",

	SI_IJA_EVENTTICKETSAVER_AUTOCOMPLETE = "Auto-Complete.",
	SI_IJA_EVENTTICKETSAVER_AUTOCOMPLETE_TOOLTIP = "Auto-completes quests that reward event tickets if the offered ticket would not put you over 12.",
	
	SI_IJA_EVENTTICKETSAVER_AUTOCLOSE = "Help me save tickets.",
	SI_IJA_EVENTTICKETSAVER_AUTOCLOSE_TOOLTIP = "Auto exits Quest turn-in if you have too many event tickets.\nPrevents using The Jubilee Cake if you have too many event tickets.",
	
	SI_IJA_EVENTTICKETSAVER_SHOWTIME = "Display time.",
	SI_IJA_EVENTTICKETSAVER_SHOWTIME_TOOLTIP = "Time in seconds to show number of tickets on HUD.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
