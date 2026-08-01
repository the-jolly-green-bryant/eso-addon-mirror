local TBoxAddon = _G['TBoxAddon']
local pTC = TBoxAddon.TColor
TBoxAddon.DB = {}
TBoxAddon.AT = {}
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Russian
-- (Requires human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- General
	L.TBoxAddon_SEARCHBOX				= "Поиск клада по имени."
	L.TBoxAddon_CLOSE					= "Закрыть Treasure Box"
	L.TBoxAddon_TITLE					= "Treasure Box"
	L.TBoxAddon_RECENT					= "Недавно найдено:"
	L.TBoxAddon_FAVZONE					= "Верхняя зона:"
	L.TBoxAddon_UPDATE1					= "[TBox]: База данных Treasure Box обновлена."
	L.TBoxAddon_UPDATE2					= "[TBox]: Пожалуйста /reloadui для завершения."
	L.TBoxAddon_UPDATE3					= "[TBox]: Подождите, пожалуйста..."
	L.TBoxAddon_NOCATEGORY				= "Без категории"
	L.TBoxAddon_RESETSEARCH				= "Нажмите кнопку, чтобы сбросить текстовый поиск.\n\n"..pTC("FFFFFF", "НОТА: ").."Другие фильтры сохраняются."
	L.TBoxAddon_TFOUNDOFF				= pTC("00FF00", "Показать только найдено").." есть"..pTC("FFFFFF", " ON").."\n\nНажмите, чтобы переключить показ всех сокровищ, нашли ли вы их или нет."
	L.TBoxAddon_TFOUNDON				= pTC("00FF00", "Показать только найдено").." есть"..pTC("FFFFFF", " OFF").."\n\nЩелкните, чтобы показать только те сокровища, которые вы нашли у одного из ваших персонажей."
	L.TBoxAddon_RESETFILTER				= "Сбросить фильтры"
	L.TBoxAddon_RQUALITYS1				= "Только показать "
	L.TBoxAddon_RQUALITYS2				= " и предметы более высокого качества в списке недавно найденных."
	L.TBoxAddon_UPDATING				= "[TBox]: Treasure Box обновление базы данных, пожалуйста, не перезапустите..."

-- Navigation
	L.TBoxAddon_TFOUND					= "Сокровище Найдено:"
	L.TBoxAddon_QUALITYHEAD				= "Качество сокровищ:"
	L.TBoxAddon_TIMEHEAD				= "Время найдено:"
	L.TBoxAddon_TIMEDAYS1				= "Последние"
	L.TBoxAddon_TIMEDAYS2				= "дней"
	L.TBoxAddon_ANY						= "Все"
	L.TBoxAddon_ALLTYPES				= "Категория: Все"
	L.TBoxAddon_ALLZONES				= "Нашел в: Все"
	L.TBoxAddon_ANYFOUND				= "Найдено по: Все"
	L.TBoxAddon_QUALITYS				= "Показать качество: "
	L.TBoxAddon_QUALITY1				= "Normal"
	L.TBoxAddon_QUALITY2				= "Fine"
	L.TBoxAddon_QUALITY3				= "Superior"
	L.TBoxAddon_QUALITY4				= "Epic"
	L.TBoxAddon_QUALITY5				= "Legendary"
	L.TBoxAddon_FINZONES				= "Найдено в зонах:"
	L.TBoxAddon_LFOUNDIN				= "Последний найденный в: "
	L.TBoxAddon_LFOUNDBY				= "Последний раз нашел: "
	L.TBoxAddon_FOUNDON					= "Последний найденный: "
	L.TBoxAddon_TOTALF					= "Всего найдено: "
	L.TBoxAddon_NEVER					= "Никогда"
	L.TBoxAddon_NONE					= "Нет"
	L.TBoxAddon_UNKNOWN					= "Неизвестно"
	L.TBoxAddon_SALPHA					= "Сортировать алфавитно"
	L.TBoxAddon_SFOUND					= "Сортировать по номеру найдено"

-- Settings
	L.TBoxAddon_GOPTS					= "Общие настройки"
	L.TBoxAddon_CHARALPHA				= "Сортировка списка персонажей"
	L.TBoxAddon_CHARALPHAT				= "Enabled показывает список символов в алфавитном порядке. В противном случае он использует порядок выбора персонажей в игре.\n\n"..pTC("FFFFFF", "НОТА: ").."Игра возвращает только порядок СОЗДАНИЯ персонажа. Он не отслеживает переупорядоченные вручную символы."
	L.TBoxAddon_USTIME					= "12 часов Времени"
	L.TBoxAddon_USTIMET					= "При включении отметки времени для ранее найденных сокровищ будут отображаться через 12 часов с am / pm после времени. Выключите, чтобы показать в 24-часовом (военном) времени."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ru') then -- overwrite GetLanguage for new language
	for k, v in pairs(TBoxAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function TBoxAddon:GetLanguage() -- set new language return
		return L
	end
end
