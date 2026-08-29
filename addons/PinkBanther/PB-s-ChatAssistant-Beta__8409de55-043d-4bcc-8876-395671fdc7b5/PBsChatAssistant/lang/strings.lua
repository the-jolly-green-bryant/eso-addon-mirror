local strings = {
	SI_KEYBINDINGS_CATEGORY_PBSCHATASSISTANT = "PB’s ChatAssistant",
	SI_BINDING_NAME_PBSCHATASSISTANT_START_CHAT = "Open Chat",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
