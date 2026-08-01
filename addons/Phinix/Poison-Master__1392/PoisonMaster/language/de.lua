local PMAddon = _G['PMAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.PMAddon_GLOBAL			= "GLOBALE OPTIONEN"
L.PMAddon_LOCK				= "Position verriegeln"
L.PMAddon_LOCKTIP			= "Verhindert das Verschieben des Gift-Konfigurationsfensters."
L.PMAddon_BACK				= "Hintergrund ausblenden"
L.PMAddon_BACKTIP			= "Blendet den Hintergrund des Gift-Konfigurationsfensters aus."
L.PMAddon_ICONS				= "Zeige Ausrüstungssymbole"
L.PMAddon_ICONSTIP			= "Zeigt Symbolanzeigen für Ihre aktiven und inaktiven Waffengifte an, wenn Sie einem Favoritenplatz zugewiesen sind."
L.PMAddon_THEME				= "Icon-Theme ausrüsten"
L.PMAddon_THEMETIP			= "Wählen Sie den Stil für die Giftindikatoren."
L.PMAddon_STYLE1			= "Grenzen"
L.PMAddon_STYLE2			= "Prüft"
L.PMAddon_DEBUG				= "Debugtext anzeigen"
L.PMAddon_DEBUGTIP			= "Zeigt beschreibenden Text im Chat an, wenn bestimmte Dinge auftreten."
L.PMAddon_Tooltip			= "Klicken Sie bei gedrückter Umschalttaste, um dem Steckplatz ausgerüstetes Gift zuzuweisen. Zum Löschen mit der rechten Maustaste klicken."

-- Keybind strings
L.PMAddon_KBT				= "Umschalten Poison-Konfigurationsfensters"
L.PMAddon_KB1				= "Ausrüsten/Unequip Slot 1 Gift"
L.PMAddon_KB2				= "Ausrüsten/Unequip Slot 2 Gift"
L.PMAddon_KB3				= "Ausrüsten/Unequip Slot 3 Gift"
L.PMAddon_KB4				= "Ausrüsten/Unequip Slot 4 Gift"

-- Debug strings
L.PMAddon_PNE				= "Gewünschtes Gift ist nicht mehr in Ihren Taschen."
L.PMAddon_NPE				= "Aktive Waffe hat kein ausgerüstetes Gift zuzuteilen."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k,v in pairs(PMAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function PMAddon:GetLanguage() -- set new language return
		return L
	end
end
