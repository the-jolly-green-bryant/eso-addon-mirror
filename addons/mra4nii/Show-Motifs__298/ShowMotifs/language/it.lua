local ShowMotifs = _G['ShowMotifs']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Strings
L.GENERAL					= "Generale"
L.ICON_THEME				= "Tema delle icone"
L.ICON_THEME_TOOLTIP		= "Scegli Tema per le icone.\n\nNota per Inventory Grid Visualizza gli utenti aggiuntivi: le icone non vengono visualizzate in modalità 'griglia.'"
L.ICON_SIZE					= "Icona di Racial Motif"
L.ICON_SIZE_TOOLTIP			= "Imposta le dimensioni per le icone del motivo razziale"
L.ARMOR_ICON_SIZE			= "Tipo di icona Dimensione dell'armatura"
L.ARMOR_ICON_SIZE_TOOLTIP	= "Impostare la dimensione per le icone Tipo di armatura"
L.II_POSITION				= "Posizione icona inventario"
L.II_POSITION_TOOLTIP		= "Imposta la posizione per le icone relative al bordo sinistro dell'elenco di inventario"
L.GSS_POSITION				= "Posizione icona negozio gilda"
L.GSS_POSITION_TOOLTIP		= "Imposta la Posizione per le icone relative al bordo sinistro dell'elenco dei risultati della ricerca dell'archivio di gilda"
L.GSL_POSITION				= "Posizione dell'icona dell'elenco delle gilde"
L.GSL_POSITION_TOOLTIP		= "Imposta la Posizione per le icone relative al bordo sinistro del pannello di elenco dello store di gilda"
L.RACIAL					= "Mostra l'icona di Motivo razziale"
L.RACIAL_TOOLTIP			= "Mostra l'icona del motivo razziale.\n\nNota per gli utenti aggiuntivi di Grid View di Inventory: le icone non vengono visualizzate in modalità 'griglia'"
L.ARMOR						= "Mostra l'icona del tipo armatura"
L.ARMOR_TOOLTIP				= "Mostra l'icona del tipo di armatura.\n\nNota per gli utenti aggiuntivi di Grid View di Inventory: le icone non vengono visualizzate in modalità 'griglia'"
L.LETTER					= "Usa le lettere"
L.LETTER_TOOLTIP			= "Mostra lettera invece di simboli grafici per Tipo di armatura"
L.COLOR						= "Usa il colore di qualità"
L.COLOR_TOOLTIP				= "Imposta il colore per le icone in base alla qualità delle voci"
L.TOOLTIP					= "Mostra suggerimenti"
L.TOOLTIP_TOOLTIP			= "Mostra i suggerimenti per le icone al passaggio del mouse.\n\nNota per gli utenti aggiuntivi di Grid View di Inventory: le icone non vengono visualizzate in modalità 'griglia'"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k, v in pairs(ShowMotifs:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function ShowMotifs:GetLanguage() -- set new language return
		return L
	end
end
