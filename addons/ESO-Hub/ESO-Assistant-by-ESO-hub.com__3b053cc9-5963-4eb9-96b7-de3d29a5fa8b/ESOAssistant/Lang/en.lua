-- Every variable must start with this addon's unique ID, as each is a global.
local strings = {
	SI_ESOASSISTANT_SHOW = "Show on ESO-Hub.com",
	SI_ESOASSISTANT_SHOW_ZONE = "Show Zone on ESO-Hub.com",
	SI_ESOASSISTANT_SHOW_ITEMSET = "Show Item Set on ESO-Hub.com",
	SI_ESOASSISTANT_SHOW_SKILL_LINE = "Show Skill Line on ESO-Hub.com",
	SI_ESOASSISTANT_SHOW_ABILITY = "Show Skill on ESO-Hub.com",

	SI_ESOASSISTANT_MENU_SHOW_QR = "Show QR Code",
	SI_ESOASSISTANT_MENU_SHOW_QR_TT = "Show a QR code containing the URL on screen when selecting 'Show on ESO-Hub.com'",
	SI_ESOASSISTANT_MENU_OPEN_LINK= "Open Link",
	SI_ESOASSISTANT_MENU_OPEN_LINK_TT= "Open the URL when selecting 'Show on ESO-Hub.com'",


	-- Keybindings.
	SI_BINDING_NAME_ESOASSISTANT_DISPLAY = "Visit ESO-Hub.com",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end