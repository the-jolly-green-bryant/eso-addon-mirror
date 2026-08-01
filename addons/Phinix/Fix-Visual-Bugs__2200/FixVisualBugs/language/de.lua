local FixVisualBugs = _G['FixVisualBugs']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- Settings panel
L.FVBAddon_AutoIWFix			= "Automatischer Waffenfix"
L.FVBAddon_AutoIWFixTip			= "Unsichtbare Waffenfehler automatisch beheben (experimentell). Sie können auch eine Tastenkombination festlegen, um visuelle Fehler manuell zu beheben."

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k,v in pairs(FixVisualBugs:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function FixVisualBugs:GetLanguage() -- set new language return
		return L
	end
end
