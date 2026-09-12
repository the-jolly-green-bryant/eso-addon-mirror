local strings = {
	SI_KEYBINDINGS_CATEGORY_PBSMINIMAP = "Mini-carte",
	SI_PBSMINIMAP_MINI_MAP_TOOLTIP = "Applique les fonctionnalités de la mini-carte à la carte intégrée.",
	SI_PBSMINIMAP_APPLY_BUTTON = "Appliquer",
}

for stringId, stringValue in pairs(strings) do
	SafeAddString(_G[stringId], stringValue, 2)
end
