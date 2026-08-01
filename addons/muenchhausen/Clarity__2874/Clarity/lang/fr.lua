--French language file for "Clarity" addon by ChtiClem, Baertram
local strings = {
--Addon LAM menu
	SI_CLARITY_LAM_OPTION_FORM_GRASS = "Définit l'herbe à:",
	SI_CLARITY_LAM_OPTION_HIDE_GRASS = "Cacher l'herbe",
	SI_CLARITY_LAM_OPTION_HIDE_LIGHT = "Cacher les rayons du soleil",
	SI_CLARITY_LAM_OPTION_HIDE_EFFECTS = "Cacher les effets sur les alliés",
	SI_CLARITY_LAM_OPTION_INFO = "Ces options sont aussi appliquées lorsque Clarity est activé manuellement par |cB39C7A/clarity|r ou un raccourci clavier. Pour réactiver le fonctionnement automatique, faire |cB39C7A/clarity auto|r.",
	SI_CLARITY_LAM_OPTION_AUTO = "Activer automatiquement pendant un combat ?",
	SI_CLARITY_LAM_OPTION_AUTO_TT = "Si NON, Clarity ne peut être activé que manuellement.",
	SI_CLARITY_TOGGLE_ON = " est ON.",
	SI_CLARITY_TOGGLE_OFF = " est OFF.",
--Keybindings
	SI_BINDING_NAME_TOGGLE_GRASS = "Activer/Désactiver Clarity",
}
for stringId, stringValue in pairs(strings) do ZO_CreateStringId(stringId, stringValue) SafeAddVersion(stringId, 1) end