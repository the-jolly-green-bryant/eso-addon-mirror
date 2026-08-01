local EZReport = _G['EZReport']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Russian (Thanks to ESOUI.com user stribog for the translations.)
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Labels
L.EZReport_GOpts				= "Глобальные параметры"
L.EZReport_TIcon				= "Показывать иконку цели"
L.EZReport_DTime				= "Показать заданное время"
L.EZReport_RCooldown			= "Отчет о перезарядке"
L.EZReport_RCooldownM			= "EZReport уже сообщал сегодня: Перезарядка отчетности включена."
L.EZReport_OutputChat			= "Показать сообщения чата"
L.EZReport_12HourFormat			= "12-часовой формат времени"
L.EZReport_IncPrev				= "Включить данные предыдущего отчета"
L.EZReport_DCategory			= "Категория по умолчанию"
L.EZReport_DReason				= "Причина по умолчанию"
L.EZReport_Reset				= "Сбросить историю отчетов"
L.EZReport_Clear				= "ЧИСТО"

-- Target Reported Colors
L.EZReport_RColorS				= "Целевые сообщаемые цвета"
L.EZReport_RColor1				= "Универсальный цвет"
L.EZReport_RColor2				= "Цвет плохого имени"
L.EZReport_RColor3				= "Токсичный цвет"
L.EZReport_RColor4				= "Обман Цвет"
L.EZReport_RColor5				= "Alt сообщает цвет"

-- Addon Setting Tooltips
L.EZReport_TIconT				= "Покажите значок, обозначающий цели, о которых вы ранее сообщали. Соответствует значкам, отображаемым при выборе категории в окне отчета."
L.EZReport_DTimeT				= "Отображение времени последнего сообщения о цели рядом со значком цели. Если о текущем персонаже никогда не сообщалось, отображается самое последнее время, когда сообщалось о каком-либо персонаже в его аккаунте."
L.EZReport_RCooldownT			= "При включении запрещает создание отчетов по горячим клавишам, если вы уже сообщили о цели сегодня. Полезно при составлении отчетов для больших групп ботов, чтобы вы могли спамить связку клавиш, и система отчетов активируется только тогда, когда у вас есть цель, о которой вы еще не сообщили."
L.EZReport_OutputChatT			= "Отображает информативные сообщения, связанные с различными функциями расширения в чате."
L.EZReport_12HourFormatT		= "Когда включено, сгенерированные временные метки будут использовать 12-часовой формат времени (час плюс AM или PM). Отключение этого параметра покажет 24-часовой формат «военного времени»."
L.EZReport_IncPrevT				= "Включает данные о дате, времени и имени о предыдущих отчетах этого персонажа или известных альтернативах при отправке отчета."
L.EZReport_DCategoryT			= "Выберите подкатегорию по умолчанию для автоматического выбора при открытии окна отчета."
L.EZReport_DReasonT				= "Включите выбранную причину в разделе пользовательских сведений окна отчетов. Вручную (по умолчанию) можно оставить это поле пустым, чтобы вы могли вводить его вручную."
L.EZReport_ResetT				= "Очистить всю базу данных ранее сообщенных персонажей и аккаунтов."
L.EZReport_ResetM				= "База данных EZReport была сброшена."

-- Category List
L.EZReport_CatList1				= "Плохое имя"
L.EZReport_CatList2				= "домогательство"
L.EZReport_CatList3				= "Мошенничество"
L.EZReport_CatList4				= "Другой"
L.EZReport_CatList5				= "Нет (по умолчанию)"

-- Reason List
L.EZReport_ReasonList1			= "Botting"
L.EZReport_ReasonList2			= "Эксплуатируя"
L.EZReport_ReasonList3			= "домогательство"
L.EZReport_ReasonList4			= "Ручной (по умолчанию)"

-- Chat List
L.EZReport_CReason1				= "Общий отчет"
L.EZReport_CReason2				= "Плохое имя"
L.EZReport_CReason3				= "Токсическое поведение"
L.EZReport_CReason4				= "Мошенничество"

-- Chat Strings
L.EZReport_RepT					= "Сообщается:"
L.EZReport_RepC					= "Сообщаемый персонаж:"
L.EZReport_Unkn					= "неизвестный аккаунт"
L.EZReport_Now					= "сейчас:"
L.EZReport_Char					= "персонаж:"
L.EZReport_For					= "за:"
L.EZReport_NoMatch				= "Совпадений не найдено."

-- Info Panel
L.EZReport_RAcct				= "Отчет по аккаунту: "
L.EZReport_RAlts				= "Ранее сообщенные Alts: "

-- General Strings
L.EZReport_RLast				= "Сообщить о последней цели игрока"
L.EZReport_RHistory				= "История целевых отчетов"
L.EZReport_ROpen				= "Открыть главное окно"
L.EZReport_Reason				= "Причина (необязательно):"
L.EZReport_CName				= "Название характера:"
L.EZReport_AName				= "Имя пользователя:"
L.EZReport_MLoc					= "Карта:"
L.EZReport_Coords				= "Coords:"
L.EZReport_Time					= "Дата / время:"
L.EZReport_CButton				= "Очистить"
L.EZReport_Today				= "сегодня"
L.EZReport_Updated				= "База данных EZReport обновлена."
L.EZReport_AccUnavail			= "Аккаунт недоступен"
L.EZReport_LocUnavail			= "Расположение недоступно"
L.EZReport_Wayshrine			= "Wayshrine"
L.EZReport_Accounts				= "Отчеты по аккаунту"
L.EZReport_Characters			= "Отчеты по персонажу"
L.EZReport_Locations			= "Отчеты по местоположению"
L.EZReport_Generated			= "Создано: EZReport от Phinix"
L.EZReport_Previous				= "Ранее сообщалось:"
L.EZReport_Confirm				= "Подтвердите удаление"
L.EZReport_Cancel				= "отменить"
L.EZReport_Delete				= "удалять"

-- Tooltip strings
L.EZReport_TTShow				= "Нажмите, чтобы показать сводку отчета."
L.EZReport_TTClick				= "Нажмите в поле результатов и нажмите:"
L.EZReport_TTSelect1			= "Ctrl+A"
L.EZReport_TTSelect2			= " выбрать все."
L.EZReport_TTCopy1				= "Ctrl+C"
L.EZReport_TTCopy2				= " копировать."
L.EZReport_TTPaste1				= "Ctrl+V"
L.EZReport_TTPaste2				= " вставить в другом месте."
L.EZReport_TTAccounts			= "Переключиться на показ аккаунтов."
L.EZReport_TTCharacters			= "Переключиться на показ символов."
L.EZReport_TTEMode				= "Переключиться в режим редактирования базы данных."
L.EZReport_TTRMode				= "Переключиться в режим текстового отчета."
L.EZReport_TTCEntry1			= "Щелчок левой кнопкой мыши"
L.EZReport_TTCEntry2			= " показывать записи персонажей."
L.EZReport_TTAEntry1			= "Shift+щелчок левой кнопкой мыши"
L.EZReport_TTAEntry2			= " показать записи аккаунта."
L.EZReport_TTDEntry1			= "Щелкните правой кнопкой мыши"
L.EZReport_TTDEntry2			= " удалить выбранную запись."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ru') then -- overwrite GetLanguage for new language
	for k, v in pairs(EZReport:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function EZReport:GetLanguage() -- set new language return
		return L
	end
end
