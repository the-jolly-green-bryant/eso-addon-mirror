local FixVisualBugs = _G['FixVisualBugs']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- Settings panel
L.FVBAddon_AutoIWFix			= "Correzione automatica dell'arma"
L.FVBAddon_AutoIWFixTip			= "Risolto automaticamente il bug dell'arma invisibile (sperimentale). Puoi anche impostare una combinazione di tasti per correggere i bug visivi manualmente."

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k,v in pairs(FixVisualBugs:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function FixVisualBugs:GetLanguage() -- set new language return
		return L
	end
end
