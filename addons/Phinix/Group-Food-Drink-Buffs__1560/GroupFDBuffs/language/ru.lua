local GroupFDB = _G['GroupFDB']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Russian (Thanks ESOUI.com user Scope for the translation.)
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- Panel Strings.
L.GroupFDB_Title		= "Group Food & Drink Buffs"
	L.GroupFDB_GOpts		= "Общие настройки"
L.GroupFDB_SGF				= "Мониторинг групповых фреймов"
L.GroupFDB_SGFD				= "Покажите значки еды напитка на кадрах группового блока."
L.GroupFDB_SRF				= "Мониторинг Raid Frames"
L.GroupFDB_SRFD				= "Покажите еду с напитками на рамах."
	L.GroupFDB_SAB			= "Показывать индикатор активного эффекта"
	L.GroupFDB_SABD			= "Показывать иконку для активного эффекта еды или напитка на рамках рейда или группы."
	L.GroupFDB_SJB			= "Показывать индикатор плохой пищи"
	L.GroupFDB_SJBD			= "Показывать иконку активного эффекта от низкокачественной еды или напитка на рамках рейда или группы."
	L.GroupFDB_SNB			= "Показывать индикатор отсутсвующего эффекта"
	L.GroupFDB_SNBD			= "Показывать красную иконку на рамках рейда или группы если у персонажа нет активного эффекта от еды или напитка."
L.GroupFDB_GMode			= "Групповой режим"
L.GroupFDB_GModeD			= "Выберите модуль поддержки для групповых кадров, которые вы используете в данный момент. По умолчанию это нормальные фреймы игры."
L.GroupFDB_RMode			= "Режим Рейд Бафф"
L.GroupFDB_RModeD			= "Выберите модуль поддержки для фреймов, которые вы используете в данный момент. По умолчанию это нормальные фреймы игры."
	L.GroupFDB_GIS			= "Размер иконки в группе"
	L.GroupFDB_GISD			= "Размер иконки еды/напитка при отображении на стандартных рамках группы, как множитель в 8 пикселей."
	L.GroupFDB_RIS			= "Размер иконки в рейде"
	L.GroupFDB_RISD			= "Размер иконки еды/напитка при отображении на стандартных рамках рейда, как множитель в 8 пикселей."
L.GroupFDB_GXIO				= "Смещение горизонтальной иконки группы"
L.GroupFDB_GXIOD			= "Регулирует положение значка «Еда/напитки» в рамке группы слева направо."
L.GroupFDB_GYIO				= "Смещение вертикальной иконки группы"
L.GroupFDB_GYIOD			= "Регулирует положение иконки еды/питья в рамке группы вверх и вниз."
L.GroupFDB_RXIO				= "Смещение горизонтального значка рейда"
L.GroupFDB_RXIOD			= "Регулирует положение значка еды/питья на рейд-раме слева направо."
L.GroupFDB_RYIO				= "Смещение вертикального значка рейда"
L.GroupFDB_RYIOD			= "Регулирует положение значка еды/питья рамки рейда вверх и вниз."

-- Group frame support options
L.GroupFDB_Mode1			= "По умолчанию"
--L.GroupFDB_Mode2			= "Foundry Tactical Combat"
--L.GroupFDB_Mode3			= "Lui Extended"
--L.GroupFDB_Mode4			= "Bandits User Interface"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ru') then -- overwrite GetLanguage for new language
	for k,v in pairs(GroupFDB:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function GroupFDB:GetLanguage() -- set new language return
		return L
	end
end
