local strings = {
	SI_BINDING_NAME_PBSCHATASSISTANT_START_CHAT = "チャットを開く",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
