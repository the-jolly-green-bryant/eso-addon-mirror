-- Translation by @FusRoDah
local strings = {
	SI_KEYBINDINGS_CATEGORY_PBSMINIMAP = "小地图",
	SI_PBSMINIMAP_MINI_MAP_TOOLTIP = "启用内置地图的小地图功能。",
	SI_PBSMINIMAP_APPLY_BUTTON = "应用",
	SI_PBSMINIMAP_SHOW_IN_SETTINGS = "现在显示小地图",
}

for stringId, stringValue in pairs(strings) do
	SafeAddString(_G[stringId], stringValue, 2)
end