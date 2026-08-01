local RC = _G['RollCallAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Russian
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

--Strings for /toss.
L.RollCallToss1			= "Головы."
L.RollCallToss2			= "Хвосты."
L.RollCallToss3			= " бросает Дрейк, и она приземляется "
L.RollCallTossQ1		= "[Бросить] Использование: /toss вариант"
L.RollCallTossQ2		= "[Бросить] Допустимый вариант: 2 (имеется в виду двухсторонняя монета)."
L.RollCallTossQ3		= "[Бросить] По умолчанию 2 (при нет или введено неверное значение)."

--Strings for /roll.
L.RollCallRoll1			= "[Рулон] из "
L.RollCallRoll2			= " из "
L.RollCallRoll3			= " от: "
L.RollCallRoll4			= " броска "
L.RollCallRoll5			= " бросает деревянный кубик и бросает "
L.RollCallRoll6			= " Деревянные кубики и роллы "
L.RollCallRollQ1		= "[Рулон] Использование: /roll вариант"
L.RollCallRollQ2		= "[Рулон] Допустимые значения: 6, 10, 12, 18, 24, 50, 100 и 1000."
L.RollCallRollQ3		= "[Рулон] По умолчанию 100 (при нет или введено неверное значение). Смотрите параметры."
L.RollCallRollQ4		= "[Рулон] 'Специальные' значения: 6, 12, 18 и 24."

--Settings panel strings.
L.RollCallCharOpt		= "Варианты персонажей"
L.RollCallRollO			= "Опция броска по умолчанию"
L.RollCallRollOD		= "Выберите поведение по умолчанию при вводе /roll без опции числа По умолчанию это стандартный выкат из 100. Смотрите параметры."
L.RollCallOpt1			= "Бросок 1 умереть."
L.RollCallOpt2			= "Бросьте 2 кубика."
L.RollCallOpt3			= "Бросьте 3 кубика."
L.RollCallOpt4			= "Бросьте 4 кубика."
L.RollCallOpt5			= "Рулон / 10"
L.RollCallOpt6			= "Рулон / 20"
L.RollCallOpt7			= "Рулон / 50"
L.RollCallOpt8			= "Рулон / 100"
L.RollCallOpt9			= "Рулон / 1000"
L.RollCallDC			= "Отключить в бою"
L.RollCallDCD			= "Запрещает RollCall отвечать на пинги, если вы находитесь в бою. Предотвращает нежелательный спам в чате во время групповых боев, когда пинг карт является частым из-за надстроек DPS."
L.RollCallCM			= "Включить режим чата"
L.RollCallCMD			= "Включить отправку вывода (без графики) в активный чат вместо группы. ПРИМЕЧАНИЕ. Вам все равно придется вручную нажимать клавишу ввода, чтобы опубликовать сообщение из-за ограничений API, предотвращающих спам в чате через надстройки."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ru') then -- overwrite GetLanguage for new language
	for k,v in pairs(RC:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function RC:GetLanguage() -- set new language return
		return L
	end
end
