-- Every variable must start with this addon's unique ID, as each is a global.
local strings = {
	SI_ESOASSISTANT_SHOW = "Auf ESO-Hub.com anzeigen",
	SI_ESOASSISTANT_SHOW_ZONE = "Gebiet auf ESO-Hub.com anzeigen",
	SI_ESOASSISTANT_SHOW_ITEMSET = "Item Set auf ESO-Hub.com anzeigen",
	SI_ESOASSISTANT_SHOW_SKILL_LINE = "Skill Linie auf ESO-Hub.com anzeigen",
	SI_ESOASSISTANT_SHOW_ABILITY = "Skill auf ESO-Hub.com anzeigen",

	SI_ESOASSISTANT_MENU_SHOW_QR = "QR Code anzeigen",
	SI_ESOASSISTANT_MENU_SHOW_QR_TT = "Zeigt einen QR code mit der URL an, wenn 'Auf ESO-Hub.com anzeigen' gewählt wird",
	SI_ESOASSISTANT_MENU_OPEN_LINK= "Link öffnen",
	SI_ESOASSISTANT_MENU_OPEN_LINK_TT= "Öffnet die URL im Browser, wenn 'Auf ESO-Hub.com anzeigen' gewählt wird",

	-- Keybindings.
	SI_BINDING_NAME_ESOASSISTANT_DISPLAY = "ESO-Hub.com besuchen",
}

for stringId, stringValue in pairs(strings) do
	SafeAddString(stringId, stringValue,1)
end