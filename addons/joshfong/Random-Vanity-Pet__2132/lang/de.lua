local strings = {
	RVP_CHAT_DISPLAY_LABEL		= "Änderungen im Chat ausgeben",
	RVP_CHAT_DISPLAY_TOOLTIP	= "Das ausgewählte Pet (Begleittier) im Chat ausgeben.",
	RVP_FREQ_LABEL				= "Frequenz",
	RVP_FREQ_TOOLTIP			= "Wie oft möchtest du dein Pet wechseln lassen",
	RVP_FREQ_ON_LOGIN			= "Beim Einloggen",
	RVP_FREQ_ON_LOAD_SCREEN		= "Jeder Ladebildschirm",
	RVP_FREQ_NEVER				= "Nie",
	RVP_FREQ_WARNING			= "Benötigt Neuladen der UI (Benutzer Oberfläche).",
	RVP_RELOAD_UI_LABEL			= "UI neu laden",
	RVP_PET_CHAT_LOG			= "Pet wurde gewechselt zu ",
}

for id, value in pairs(strings) do
	ZO_CreateStringId(id, value)
	SafeAddVersion(id, 1)
end
