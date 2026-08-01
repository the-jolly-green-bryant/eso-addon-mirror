local strings = {
	SI_BINDING_NAME_PB_DEBUG = "Debug",
	SI_BINDING_NAME_PB_GUILD_INVITE = "Guild Auto Invite",
	SI_BINDING_NAME_PB_GUILD_ASK = "Guild Recruit Wisper",
	SI_BINDING_NAME_PB_HIDE_MAP_CLUTTER = "Hide Map Clutter",
	SI_BINDING_NAME_PB_GUILD_MENU = "PB Guild Menu",
	SI_BINDING_NAME_PB_GUILD_MENU_LEADERBOARD = "Recruitment Leaderboard"
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
