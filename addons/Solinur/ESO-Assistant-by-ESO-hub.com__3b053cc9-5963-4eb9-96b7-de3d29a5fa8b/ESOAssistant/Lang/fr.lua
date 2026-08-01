-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
	SI_ESOASSISTANT_SHOW = "Voir sur ESO-Hub.com",
	SI_ESOASSISTANT_SHOW_ZONE = "Voir la zone sur ESO-Hub.com",
	SI_ESOASSISTANT_SHOW_ITEMSET = "Voir le set sur ESO-Hub.com",
	SI_ESOASSISTANT_SHOW_SKILL_LINE = "Voir la ligne sur ESO-Hub.com",
	SI_ESOASSISTANT_SHOW_ABILITY = "Voir la skill sur ESO-Hub.com",

	SI_ESOASSISTANT_MENU_SHOW_QR = "Afficher le code QR",
	SI_ESOASSISTANT_MENU_SHOW_QR_TT = "Afficher un code QR contenant l'URL à l'écran lors de la sélection de 'Voir sur ESO-Hub.com'",
	SI_ESOASSISTANT_MENU_OPEN_LINK= "Ouvrir le lien",
	SI_ESOASSISTANT_MENU_OPEN_LINK_TT= "Ouvrez l'URL dans le navigateur lorsque vous sélectionnez 'Voir sur ESO-Hub.com'",

	-- Keybindings.
	SI_BINDING_NAME_ESOASSISTANT_DISPLAY = "Visitez ESO-Hub.com",
}


for stringId, stringValue in pairs(localization_strings) do
	SafeAddString(stringId, stringValue, 1)
end