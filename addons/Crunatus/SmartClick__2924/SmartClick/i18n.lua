local localization = {
    ["en"] = {
		SI_SMARTCLICK_DOUBLECLICK = "Double-click ignores the behavior",
		SI_SMARTCLICK_KEYBOARD_SENSITIVITY = "Keyboard sensitivity",
		SI_SMARTCLICK_ONCE_PER_ROTATION = "One-time action",
		SI_SMARTCLICK_PVP_ONLY = "Only in PvP zone",
		SI_SMARTCLICK_COMBAT_ONLY = "Only in Combat",
    },
	["de"] = {
		SI_SMARTCLICK_DOUBLECLICK = "Ein Doppelklick ignoriert das verhalten",
		SI_SMARTCLICK_KEYBOARD_SENSITIVITY = "Tastaturempfindlichkeit",
		SI_SMARTCLICK_ONCE_PER_ROTATION = "Einmalige Aktion",
		SI_SMARTCLICK_PVP_ONLY = "Nur in der PvP zone",
		SI_SMARTCLICK_COMBAT_ONLY = "Nur im Kampf",
	},
	["fr"] = {
		SI_SMARTCLICK_DOUBLECLICK = "Le double-clic ignore le comportement",
		SI_SMARTCLICK_KEYBOARD_SENSITIVITY = "Sensibilite du clavier",
		SI_SMARTCLICK_ONCE_PER_ROTATION = "Action unique",
		SI_SMARTCLICK_PVP_ONLY = "Uniquement dans la zone PvP",
		SI_SMARTCLICK_COMBAT_ONLY = "Seulement en combat",
	},		
	["ru"] = {
		SI_SMARTCLICK_DOUBLECLICK = "Двойной щелчок игнорирует поведение",
		SI_SMARTCLICK_KEYBOARD_SENSITIVITY = "Чувствительность клавиатуры",
		SI_SMARTCLICK_ONCE_PER_ROTATION = "Однократное действие",
		SI_SMARTCLICK_PVP_ONLY = "Только в PvP зоне",
		SI_SMARTCLICK_COMBAT_ONLY = "Только в бою",
	},
}

-- Add localization
local lang = localization[GetCVar("Language.2")] and GetCVar("Language.2") or "en"
for stringId, stringValue in pairs(localization[lang]) do
   ZO_CreateStringId(tostring(stringId), stringValue)
   SafeAddVersion(stringId, 1)
end
