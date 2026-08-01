local strings = {
	RVP_CHAT_DISPLAY_LABEL		= "Afficher les changements de familier dans le chat",
	RVP_CHAT_DISPLAY_TOOLTIP	= "Voir le changement de familier s'afficher dans le chat",
	RVP_FREQ_LABEL				= "Frequency", -- Needs new
	RVP_FREQ_TOOLTIP			= "Choisissez la fréquence de changement de familier",
	RVP_FREQ_ON_LOGIN			= "A l'authentification",
	RVP_FREQ_ON_LOAD_SCREEN		= "A chaque écran de chargement",
	RVP_FREQ_NEVER				= "Never", -- Needs new
	RVP_FREQ_WARNING			= "Needs UI reload.", -- Needs new
	RVP_RELOAD_UI_LABEL			= "Reload UI", -- Needs new
	RVP_PET_CHAT_LOG			= "Le familier est maintenant ",
}

for id, value in pairs(strings) do
	--SafeAddString(id, value, 1)
	ZO_CreateStringId(id, value)
end
