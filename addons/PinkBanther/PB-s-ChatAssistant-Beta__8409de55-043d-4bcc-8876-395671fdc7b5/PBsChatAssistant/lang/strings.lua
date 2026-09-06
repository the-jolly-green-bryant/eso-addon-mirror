local strings = {
	SI_KEYBINDINGS_CATEGORY_PBSCHATASSISTANT = "PB’s ChatAssistant",
	SI_BINDING_NAME_PBSCHATASSISTANT_START_CHAT = "Open Chat",
	SI_BINDING_NAME_PBSCHATASSISTANT_CHANNEL_NEXT = "Next Chat Channel",
	SI_BINDING_NAME_PBSCHATASSISTANT_CHANNEL_PREV = "Previous Chat Channel",

	SI_PBSCHATASSISTANT_DELAY = "Wait before opening",
	SI_PBSCHATASSISTANT_DELAY_TOOLTIP = "The console raises its text input screen only when the chat box takes focus fresh, so the box is opened after a short pause rather than instantly. If the box opens but the input screen does not follow, this is too short for your console: raise it.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
