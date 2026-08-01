local PMAddon = _G['PMAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Russian
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.PMAddon_GLOBAL			= "ГЛОБАЛЬНЫЕ ВАРИАНТЫ"
L.PMAddon_LOCK				= "Положение блокировки"
L.PMAddon_LOCKTIP			= "Предотвращает перемещение окна конфигурации яда."
L.PMAddon_BACK				= "Скрыть фон"
L.PMAddon_BACKTIP			= "Скрывает фон окна ядовитой конфигурации."
L.PMAddon_ICONS				= "Показать значки экипировки"
L.PMAddon_ICONSTIP			= "Показывает пиктограммы для ваших активных и неактивных ядов оружия, когда они назначены на любимый слот."
L.PMAddon_THEME				= "Тема Оборудования Значок"
L.PMAddon_THEMETIP			= "Выберите стиль для экипированных индикаторов яда."
L.PMAddon_STYLE1			= "Границы"
L.PMAddon_STYLE2			= "проверки"
L.PMAddon_DEBUG				= "Показать текст отладки"
L.PMAddon_DEBUGTIP			= "Показывает описательный текст в чате, когда происходят определенные вещи."
L.PMAddon_Tooltip			= "Shift-click, чтобы назначить экипированный яд на слот. Щелкните правой кнопкой мыши, чтобы очистить."

-- Keybind strings
L.PMAddon_KBT				= "Переключить окно настройки яда"
L.PMAddon_KB1				= "Снаряжать/снимать Слот 1 Яд"
L.PMAddon_KB2				= "Снаряжать/снимать Слот 2 Яд"
L.PMAddon_KB3				= "Снаряжать/снимать Слот 3 Яд"
L.PMAddon_KB4				= "Снаряжать/снимать Слот 4 Яд"

-- Debug strings
L.PMAddon_PNE				= "Желаемого яда больше нет в ваших сумках."
L.PMAddon_NPE				= "У активного оружия нет экипированного яда."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ru') then -- overwrite GetLanguage for new language
	for k,v in pairs(PMAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function PMAddon:GetLanguage() -- set new language return
		return L
	end
end
