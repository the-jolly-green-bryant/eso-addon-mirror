--English base Strings
local stringsEN = {
	-- Activated
	["SI_FSBOUNTDECAY_ACTIVATED"] = "Activated",
	-- Options Settings header
	["SI_FSBOUNTDECAY_HEADER_GENERAL_SETTINGS"] = "General Settings",
	--Options Settings checkbox isClock
	["SI_FSBOUNTDECAY_CHECKBOX_ISCLOCK"] = "Format HH:MM:SS",
	["SI_FSBOUNTDECAY_CHECKBOX_ISCLOCK_TOOLTIP"] = "If checked, show Bounty and Heat as '01:12:01'. If not, show as '4321'",
	--Options Settings checkbox showInfo
	["SI_FSBOUNTDECAY_CHECKBOX_SHOW_INFO"] = "Show Info",
	["SI_FSBOUNTDECAY_CHECKBOX_SHOW_INFO_TOOLTIP"] = "Display Infamy levels on chat?",
	--Options Settings button default
	["SI_FSBOUNTDECAY_BUTTON_DEFAULT"] = "Default Location",
	["SI_FSBOUNTDECAY_BUTTON_DEFAULT_TOOLTIP"] = "Move the window to the default location",
	--slash commands
	["SI_FSBOUNTDECAY_SLASH_COMMANDS_TITLE"] = "FS slash commands: ",
	["SI_FSBOUNTDECAY_SLASH_COMMANDS_GOLD"] = "Gold donation:",
	["SI_FSBOUNTDECAY_SLASH_COMMANDS_ISCLOCK"] = "Format HH:MM:SS: ",
	["SI_FSBOUNTDECAY_SLASH_COMMANDS_SHOWINFO"] = "Show Info:",
	["SI_FSBOUNTDECAY_SLASH_COMMANDS_RELOAD"] = "Reload the UI to take effect. (/reloadui)",
	["SI_FSBOUNTDECAY_SLASH_COMMANDS_DEFAULTS"] = "Reset position of window",
	["SI_FSBOUNTDECAY_SLASH_COMMANDS_INVALID"] = "Command invalid",
	["SI_FSBOUNTDECAY_SLASH_COMMANDS_NEW_VALUE"] = "New value: ",
	-- Show Info
	["SI_FSBOUNTDECAY_SLASH_SHOWINFO_INFAMY"] = "Infamy: ",
	["SI_FSBOUNTDECAY_SLASH_SHOWINFO_INFAMY_LEVEL"] = "Infamy level: ",
	-- Window
	["SI_FSBOUNTDECAY_WINDOW_HEADER"] = "Seconds to Clear",
	["SI_FSBOUNTDECAY_WINDOW_BOUNTY"] = "Bounty: ",
	["SI_FSBOUNTDECAY_WINDOW_HEAT"] = "Heat: "
}
for stringId, stringContent in pairs(stringsEN) do
    ZO_CreateStringId(stringId, stringContent)
    SafeAddVersion(stringId, 1)
end