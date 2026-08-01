local strings = {
	RVP_CHAT_DISPLAY_LABEL		= "Display changes in chat box",
	RVP_CHAT_DISPLAY_TOOLTIP	= "Show which pet you switched to in the chat box.",
	RVP_FREQ_LABEL				= "Frequency",
	RVP_FREQ_TOOLTIP			= "How often you want your pet to swap",
	RVP_FREQ_ON_LOGIN			= "On Login",
	RVP_FREQ_ON_LOAD_SCREEN		= "Every Load Screen",
	RVP_FREQ_NEVER				= "Never",
	RVP_FREQ_WARNING			= "Needs UI reload.",
	RVP_RELOAD_UI_LABEL			= "Reload UI",
	RVP_PET_CHAT_LOG			= "Pet changed to ",
}

for id, value in pairs(strings) do
	ZO_CreateStringId(id, value)
	SafeAddVersion(id, 1)
end
