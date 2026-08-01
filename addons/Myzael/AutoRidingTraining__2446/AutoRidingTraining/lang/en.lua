local strings = {
	ART_STABLE_MASTER_CAPTION = "stablemaster",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end