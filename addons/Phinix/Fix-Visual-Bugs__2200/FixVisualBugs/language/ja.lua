local FixVisualBugs = _G['FixVisualBugs']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Japanese
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- Settings panel
L.FVBAddon_AutoIWFix			= "自動武器修正"
L.FVBAddon_AutoIWFixTip			= "目に見えない武器のバグを自動的に修正します（実験的）。 キーバインドを設定して、視覚的なバグを手動で修正することもできます。"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k,v in pairs(FixVisualBugs:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function FixVisualBugs:GetLanguage() -- set new language return
		return L
	end
end
