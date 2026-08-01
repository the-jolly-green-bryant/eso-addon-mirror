local FixVisualBugs = _G['FixVisualBugs']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Spanish
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- Settings panel
L.FVBAddon_AutoIWFix			= "Arreglo automático de armas"
L.FVBAddon_AutoIWFixTip			= "Corregir el error del arma invisible automáticamente (experimental). También puede configurar una combinación de teclas para corregir los errores visuales manualmente."

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k,v in pairs(FixVisualBugs:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function FixVisualBugs:GetLanguage() -- set new language return
		return L
	end
end
