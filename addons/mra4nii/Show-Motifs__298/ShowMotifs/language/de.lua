local ShowMotifs = _G['ShowMotifs']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Strings
L.GENERAL					= "Allgemein"
L.ICON_THEME				= "Symbol Thema"
L.ICON_THEME_TOOLTIP		= "Symbol Thema welches in der Listenansicht verwendet wird\n\nHinweis für Nutzer von Inventory Grid View: Symbole werden nicht in der 'Gitter' (Grid) Ansicht angezeigt."
L.ICON_SIZE					= "Motivsymbol Größe"
L.ICON_SIZE_TOOLTIP			= "Größe des Motivsymbols"
L.ARMOR_ICON_SIZE			= "Rüstungssymbol Größe"
L.ARMOR_ICON_SIZE_TOOLTIP	= "Größe des Rüstungssymbols"
L.II_POSITION				= "Inventar Icon Position"
L.II_POSITION_TOOLTIP		= "Stellen Sie die Position für die Symbole in Bezug auf linken Rand des Inventarliste "
L.GSS_POSITION				= "Guild Shop Icon Position"
L.GSS_POSITION_TOOLTIP		= "Stellen Sie die Position für die Symbole in Bezug auf linken Rand der Gilde speichern Suchergebnisliste "
L.GSL_POSITION				= "Guild Eintrag Icon Position"
L.GSL_POSITION_TOOLTIP		= "Stellen Sie die Position für die Symbole in Bezug auf linken Rand der Zunft Store-Eintrag Panel"
L.RACIAL					= "Zeige Symbol für Rassenmotiv"
L.RACIAL_TOOLTIP			= "Zeige das Symbol für das Rassenmotiv in der Listenansicht\n\nHinweis für Nutzer von Inventory Grid View: Symbole werden nicht in der 'Gitter' (Grid) Ansicht angezeigt."
L.ARMOR						= "Zeige Symbol für Rüstungsart"
L.ARMOR_TOOLTIP				= "Zeige das Symbol für die Rüstungsart in der Listenansicht"
L.LETTER					= "Verwende Buchstaben"
L.LETTER_TOOLTIP			= "Zeige Buchstaben anstelle der Symbole für Rüstungsarten\n\n(L)eicht - Leichte Rüstung\n(M)ittel - Mittlere Rüstung\n(H)Schwer - Schwere Rüstung"
L.COLOR						= "Symbole nach Qualität einfärben"
L.COLOR_TOOLTIP				= "Zeigt Symbole für Motiv und Rüstungsart in der Qualitätsfarbe des Gegenstands"
L.TOOLTIP					= "Zeige Tooltips"
L.TOOLTIP_TOOLTIP			= "Zeige Tooltips wenn der Mauscursor in der Listenansicht über den Symbolen ist.\n\nHinweis für Nutzer von Inventory Grid View: Symbole werden nicht in der 'Gitter' (Grid) Ansicht angezeigt."

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k, v in pairs(ShowMotifs:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function ShowMotifs:GetLanguage() -- set new language return
		return L
	end
end
