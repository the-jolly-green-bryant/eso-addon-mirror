--German language file for "Clarity" addon

local strings = {
--Addon LAM menu
	SI_CLARITY_LAM_OPTION_FORM_GRASS	= "Stellt Gras auf:",
	SI_CLARITY_LAM_OPTION_HIDE_GRASS	= "Blendet Gras aus",
	SI_CLARITY_LAM_OPTION_HIDE_LIGHT	= "Blendet Lichtstrahlen aus",
	SI_CLARITY_LAM_OPTION_HIDE_EFFECTS	= "Blendet zusätzliche Effekte von Verbündeten aus",
	SI_CLARITY_LAM_OPTION_INFO			= "Diese Optionen werden auch bei manueller Verwendung von |cB39C7A/clarity|r oder einem Tastenkürzel angewendet. Um die automatische Funktion wieder zu aktivieren, benutze |cB39C7A/clarity auto|r.",
	SI_CLARITY_LAM_OPTION_AUTO			= "Automatisch im Kampf aktivieren",
	SI_CLARITY_LAM_OPTION_AUTO_TT		= "Wenn AUS wird Clarity nur manuell aktiviert.",
	SI_CLARITY_TOGGLE_ON	 			= " ist AN.",
	SI_CLARITY_TOGGLE_OFF	 			= " ist AUS.",
	
--Keybindings
	SI_BINDING_NAME_TOGGLE_GRASS 		= "Clarity AN/AUS",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
