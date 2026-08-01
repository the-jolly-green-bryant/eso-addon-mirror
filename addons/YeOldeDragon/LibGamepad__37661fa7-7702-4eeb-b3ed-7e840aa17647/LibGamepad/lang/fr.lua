local STRINGS = {
	-- Addons Management
	SI_LIBGAMEPAD_ADDONS_GENERAL_HEADER = "Général",
	SI_LIBGAMEPAD_ADDONS_TOGGLE_TT = "Gérer les extensions installées et leurs dépendances.",
	SI_LIBGAMEPAD_ADDONS_RELOADUI = "Recharger l'interface",
	SI_LIBGAMEPAD_ADDONS_RELOADUI_TT = "Recharge l'interface utilisateur. Équivalent à la commande /reloadui.",
	SI_LIBGAMEPAD_RELOAD_UI_WARNING = "Êtes-vous sûr de vouloir recharger l'interface utilisateur ?",
	SI_LIBGAMEPAD_DEBUG_SHORTCUT = "Raccourci de menu",
	SI_LIBGAMEPAD_DEBUG_SHORTCUT_TT = "Affiche un raccourci vers ce menu dans le menu principal d'OPTIONS.",
	-- Addons
	SI_LIBGAMEPAD_ADDONS_HEADER = "Options des extensions",
	-- LibGamepadLAM
	SI_LIBGAMEPADLAM_NOT_IMPLEMENTED = "Option non implémentée en mode manette.",
	SI_LIBGAMEPADLAM_EDITBOX_CURRENT_VALUE = "Valeur actuelle :",
	SI_LIBGAMEPADLAM_EDITBOX_PROMPT = "Entrez la nouvelle valeur, puis appuyez sur Confirmer.",
	SI_LIBGAMEPADLAM_EDITBOX_FIELD_HEADER = "Valeur",
	SI_LIBGAMEPADLAM_EDITBOX_PLACEHOLDER = "Saisissez ici...",
	SI_LIBGAMEPADLAM_TOOLTIP_DEFAULT_VALUE = "Valeur par défaut :",
}

local function OverrideString(stringIdName, value)
	local stringId = _G[stringIdName]
	if stringId ~= nil then
		SafeAddString(stringId, value, 2)
	else
		ZO_CreateStringId(stringIdName, value)
	end
end

for stringIdName, value in pairs(STRINGS) do
	OverrideString(stringIdName, value)
end