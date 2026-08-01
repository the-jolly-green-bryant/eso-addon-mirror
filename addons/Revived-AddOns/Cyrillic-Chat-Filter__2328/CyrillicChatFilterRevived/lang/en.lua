local strings = {
	SI_CYRILLIC_CHAT_FILTER_SETTINGS_DESC = "Toggle the filter for each category below, if you don't wanna receive message with cyrillic content.\n",
}
for ident, str in pairs(strings) do
	ZO_CreateStringId(ident, str)
	SafeAddVersion(ident, 1)
end