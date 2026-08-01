local FixVisualBugs = _G['FixVisualBugs']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Polish
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- Settings panel
L.FVBAddon_AutoIWFix			= "Automatyczna naprawa broni"
L.FVBAddon_AutoIWFixTip			= "Automatycznie napraw błąd niewidzialnej broni (eksperymentalnie). Możesz także ustawić skrót klawiszowy, aby ręcznie naprawić błędy wizualne."

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'pl') then -- overwrite GetLanguage for new language
	for k,v in pairs(FixVisualBugs:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function FixVisualBugs:GetLanguage() -- set new language return
		return L
	end
end
