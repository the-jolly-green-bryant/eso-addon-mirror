local PUIAddon = _G['PUIAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Russian
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.PUIAddon_CLOSE 		= 'близко'
L.PUIAddon_CLEAR 		= 'Очистить выбор'
L.PUIAddon_DEFAULT 		= 'Выбор по умолчанию'
L.PUIAddon_RUN			= 'Запустить выбранную конфигурацию'
L.PUIAddon_COMPLETE		= 'Настройка аддона завершена:'
L.PUIAddon_SUCCESS		= '--> Успешно настроен '
L.PUIAddon_ADDONS		= ' аддоны.'


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ru') then -- overwrite GetLanguage for new language
	for k,v in pairs(PUIAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function PUIAddon:GetLanguage() -- set new language return
		return L
	end
end
