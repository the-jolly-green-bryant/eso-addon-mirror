local strings = {
	-- Translation updated by @lucelem
	SI_KEYBINDINGS_CATEGORY_PBSMINIMAP = "Мини-карта",
	SI_PBSMINIMAP_MINI_MAP_TOOLTIP = "Включает встроенный функционал мини-карты.",
	SI_PBSMINIMAP_APPLY_BUTTON = "Применить",
}

for stringId, stringValue in pairs(strings) do
	SafeAddString(_G[stringId], stringValue, 2)
end
