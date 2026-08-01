local strings = {
	SI_CYRILLIC_CHAT_FILTER_SETTINGS_DESC = "Aktiviert den Filter für die untenstehenden Kategorien, wenn Ihr keine Nachrichten mit kyrillischem Inhalt erhalten möchtet.\n",
}
for ident, str in pairs(strings) do
	SafeAddString(_G[ident], str, 0)
end