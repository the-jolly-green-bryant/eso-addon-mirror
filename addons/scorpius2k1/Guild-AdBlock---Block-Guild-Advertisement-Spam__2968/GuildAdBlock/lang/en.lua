local strings = {
	SI_GUILD_AD_BLOCK_LANG 		= "en",

	SI_GUILD_AD_BLOCK_ENABLE	= "Enabled",
	SI_GUILD_AD_BLOCK_NOTIFY	= "Blocked Notification",

	SI_GUILD_AD_BLOCK_ENABLE_TT	= "Enable/Disable Guild AdBlock",
	SI_GUILD_AD_BLOCK_NOTIFY_TT	= "Show Blocked Notifications In Chat",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
