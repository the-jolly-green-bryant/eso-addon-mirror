local PUIAddon = _G['PUIAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.PUIAddon_CLOSE		= 'Schließe'
L.PUIAddon_CLEAR 		= 'Auswahl löschen'
L.PUIAddon_DEFAULT 		= 'Standardauswahl '
L.PUIAddon_RUN			= 'Führen Ausgewählte Config'
L.PUIAddon_COMPLETE		= 'Addon Konfiguration abgeschlossen:'
L.PUIAddon_SUCCESS		= '--> Erfolgreich konfiguriert '
L.PUIAddon_ADDONS		= ' addons.'


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k,v in pairs(PUIAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function PUIAddon:GetLanguage() -- set new language return
		return L
	end
end
