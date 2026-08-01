local RPOTracker = _G['RPOTracker']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Russian
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Panel Strings
--L.RPOTRACK_Title		= "|cFF9900Pale Order|r |cFEE854Tracker|r"
L.RPOTRACK_SOpts		= "Самостоятельные варианты"
L.RPOTRACK_GOpts		= "Групповые параметры трекера"

-- Self Tracker Options
L.RPOTRACK_Show			= "Показать трекер"
L.RPOTRACK_ShowD		= "Покажите RotPO оборудованный трекер состояния для игрока."
L.RPOTRACK_Lock			= "Блокировка трекера"
L.RPOTRACK_LockD		= "При разблокировке вы можете переместить трекер, чтобы сохранить новую позицию."
L.RPOTRACK_ShowG		= "Шоу сгруппировано"
L.RPOTRACK_ShowGD		= "Покажите RotPO оборудованный трекер статуса для игрока, когда сгруппируется."
L.RPOTRACK_ShowBG		= "Показать фон"
L.RPOTRACK_ShowBGD		= "Покажите черный фон за значком трекера RotPO."
L.RPOTRACK_Label		= "Шоу лейбл"
L.RPOTRACK_LabelD		= "Покажите текстовую метку, указывающую на прочность процента RotPO на основе количества присутствующих членов группы."
L.RPOTRACK_TScale		= "Шкала трекера"
L.RPOTRACK_TScaleD		= "Масштабируйте размеры для значка трекера."
L.RPOTRACK_LScale		= "Шкала этикетки"
L.RPOTRACK_LScaleD		= "Масштабируйте размеры для текстовой метки."
L.RPOTRACK_LabelX		= "Метка горизонтального смещения"
L.RPOTRACK_LabelXD		= "Отрегулируйте положение текстовой метки RotPO слева направо."
L.RPOTRACK_LabelY		= "Метка вертикального смещения"
L.RPOTRACK_LabelYD		= "Отрегулируйте положение текстовой метки RotPO вверх и вниз."

-- Group Tracker Options
L.RPOTRACK_SGF			= "Мониторинг групповых рам"
L.RPOTRACK_SGFD			= "Показать RotPO значок для групповых единиц."
L.RPOTRACK_SRF			= "Мониторинг рейдов"
L.RPOTRACK_SRFD			= "Показать RotPO значок на рамках RAID UNIT."
L.RPOTRACK_GIS			= "Размер значка группы"
L.RPOTRACK_GISD			= "Размер значка RotPO при отображении на стандартных групповых кадрах."
L.RPOTRACK_RIS			= "Размер значка рейда"
L.RPOTRACK_RISD			= "Размер значка RotPO при отображении на стандартных кадрах RAID."
L.RPOTRACK_GXIO			= "Групповое горизонтальное смещение значков"
L.RPOTRACK_GXIOD		= "Отрегулируйте положение группового кадра RotPO слева направо."
L.RPOTRACK_GYIO			= "Групповое вертикальное смещение значков"
L.RPOTRACK_GYIOD		= "Отрегулируйте положение значка группы RotPO вверх и вниз."
L.RPOTRACK_RXIO			= "Набег горизонтальный смещение значков"
L.RPOTRACK_RXIOD		= "Отрегулируйте положение значка RAID Frame RotPO слева направо."
L.RPOTRACK_RYIO			= "Смещение вертикальной иконы набега"
L.RPOTRACK_RYIOD		= "Отрегулируйте положение значка RAID Frame RotPO вверх и вниз."

-- 3rd Party Frame Options
L.RPOTRACK_Mode1		= "По умолчанию"
--L.RPOTRACK_Mode2		= "Foundry Tactical Combat"
--L.RPOTRACK_Mode3		= "Lui Extended"
--L.RPOTRACK_Mode4		= "Bandits User Interface"
--L.RPOTRACK_Mode5		= "AUI"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ru') then -- overwrite GetLanguage for new language
	for k, v in pairs(RPOTracker:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function RPOTracker:GetLanguage() -- set new language return
		return L
	end
end
