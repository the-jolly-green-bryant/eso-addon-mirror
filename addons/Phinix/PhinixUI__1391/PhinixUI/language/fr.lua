local PUIAddon = _G['PUIAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- French
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.PUIAddon_CLOSE		= 'Fermer'
L.PUIAddon_CLEAR 		= 'Effacer la sélection'
L.PUIAddon_DEFAULT 		= 'Sélection par défaut'
L.PUIAddon_RUN			= 'Exécutez config sélectionnée'
L.PUIAddon_COMPLETE		= 'Addon configuration complète:'
L.PUIAddon_SUCCESS		= '--> Avec succès configuré '
L.PUIAddon_ADDONS		= ' addons.'


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k,v in pairs(PUIAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function PUIAddon:GetLanguage() -- set new language return
		return L
	end
end
