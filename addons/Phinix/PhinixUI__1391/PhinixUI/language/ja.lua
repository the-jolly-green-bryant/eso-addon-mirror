local PUIAddon = _G['PUIAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Japanese
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.PUIAddon_CLOSE 		= '閉じる'
L.PUIAddon_CLEAR 		= '明確な選択'
L.PUIAddon_DEFAULT 		= 'デフォルト選択'
L.PUIAddon_RUN			= '選択した設定を実行'
L.PUIAddon_COMPLETE		= 'アドオン構成が完了しました:'
L.PUIAddon_SUCCESS		= '-->正常に設定された '
L.PUIAddon_ADDONS		= ' アドオン.'


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k,v in pairs(PUIAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function PUIAddon:GetLanguage() -- set new language return
		return L
	end
end
