-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
	SI_LOOTALERT_MESSAGE = " ist aktiv!",
	-- Keybindings.
	SI_BINDING_NAME_LOOTALERT_DISPLAY = "Zeigen Sie das Loot Alert an",
}

for stringId, stringValue in pairs(localization_strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end