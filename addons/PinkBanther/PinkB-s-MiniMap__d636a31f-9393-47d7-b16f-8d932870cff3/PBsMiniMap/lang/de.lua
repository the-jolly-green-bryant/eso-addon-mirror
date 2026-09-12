local strings = {
	SI_KEYBINDINGS_CATEGORY_PBSMINIMAP = "Mini Map",
	SI_PBSMINIMAP_MINI_MAP_TOOLTIP = "Aktiviert das Mini Map Feature der eingebauten Karte.",
	SI_PBSMINIMAP_APPLY_BUTTON = "Anwenden",
	SI_PBSMINIMAP_SHOW_IN_SETTINGS = "Mini Map jetzt einblenden",
}

for stringId, stringValue in pairs(strings) do
	SafeAddString(_G[stringId], stringValue, 2)
end
