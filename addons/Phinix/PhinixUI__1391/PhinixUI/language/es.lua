local PUIAddon = _G['PUIAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Spanish
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.PUIAddon_CLOSE 		= 'Cerrar'
L.PUIAddon_CLEAR 		= 'Selección clara'
L.PUIAddon_DEFAULT 		= 'Selección predeterminada'
L.PUIAddon_RUN			= 'Ejecutar configuración seleccionada'
L.PUIAddon_COMPLETE		= 'Configuración complementaria completa:'
L.PUIAddon_SUCCESS		= '--> Configurado con éxito '
L.PUIAddon_ADDONS		= ' addons.'


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k,v in pairs(PUIAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function PUIAddon:GetLanguage() -- set new language return
		return L
	end
end
