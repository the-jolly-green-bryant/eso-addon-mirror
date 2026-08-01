local PUIAddon = _G['PUIAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.PUIAddon_CLOSE 		= 'Vicino'
L.PUIAddon_CLEAR 		= 'Cancella selezione'
L.PUIAddon_DEFAULT 		= 'Selezione predefinita'
L.PUIAddon_RUN			= 'Esegui la configurazione selezionata'
L.PUIAddon_COMPLETE		= 'Configurazione addon completa:'
L.PUIAddon_SUCCESS		= '--> configurato correttamente '
L.PUIAddon_ADDONS		= ' addons.'


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k,v in pairs(PUIAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function PUIAddon:GetLanguage() -- set new language return
		return L
	end
end
