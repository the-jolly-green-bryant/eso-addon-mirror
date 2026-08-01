--Brazilian base Strings
local stringsBR = {
	-- Activated
	["SI_FSBOUNTDECAY_ACTIVATED"] = "Ativado",
	-- Options Settings header
	["SI_FSBOUNTDECAY_HEADER_GENERAL_SETTINGS"] = "Configurações Gerais",
	--Options Settings checkbox isClock
	["SI_FSBOUNTDECAY_CHECKBOX_ISCLOCK"] = "Formato HH:MM:SS",
	["SI_FSBOUNTDECAY_CHECKBOX_ISCLOCK_TOOLTIP"] = "Se marcado, mostra Bounty e Heat como '01:12:01'. Caso contrário, mostra como '4321'",
	--Options Settings checkbox showInfo
	["SI_FSBOUNTDECAY_CHECKBOX_SHOW_INFO"] = "Mostrar Informações",
	["SI_FSBOUNTDECAY_CHECKBOX_SHOW_INFO_TOOLTIP"] = "Mostrar os níveis de infâmia do chat?",
	--Options Settings button default
	["SI_FSBOUNTDECAY_BUTTON_DEFAULT"] = "Localização padrão",
	["SI_FSBOUNTDECAY_BUTTON_DEFAULT_TOOLTIP"] = "Mover a janela para a posição padrão?",
	--slash commands
	["SI_FSBOUNTDECAY_SLASH_COMMANDS_TITLE"] = "Comandos do FS: ",
	["SI_FSBOUNTDECAY_SLASH_COMMANDS_GOLD"] = "Doação:",
	["SI_FSBOUNTDECAY_SLASH_COMMANDS_SHOWINFO"] = "Mostrar Informações: ",
	["SI_FSBOUNTDECAY_SLASH_COMMANDS_RELOAD"] = "Recarregue a UI para ter efeito. (/reloadui)",
	["SI_FSBOUNTDECAY_SLASH_COMMANDS_DEFAULTS"] = "Redefinir posição da tela",
	["SI_FSBOUNTDECAY_SLASH_COMMANDS_INVALID"] = "Comando Invalido",
	-- Show Info
	["SI_FSBOUNTDECAY_SLASH_SHOWINFO_INFAMY"] = "Infâmia: ",
	["SI_FSBOUNTDECAY_SLASH_SHOWINFO_INFAMY_LEVEL"] = "Nível de infâmia: ",
	-- Window
	["SI_FSBOUNTDECAY_WINDOW_HEADER"] = "Segundos para zerar",
	["SI_FSBOUNTDECAY_WINDOW_BOUNTY"] = "Bounty: ",
	["SI_FSBOUNTDECAY_WINDOW_HEAT"] = "Heat: "
}
for stringId, stringContent in pairs(stringsBR) do
    ZO_CreateStringId(stringId, stringContent)
    SafeAddVersion(stringId, 1)
end