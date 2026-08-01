local strings = {

	-- BOSSES
	SI_ICTHENEXTBOSS_AMONCRUL = "Амонкрул",
	SI_ICTHENEXTBOSS_THIRSK = "Барон Тирск",
	SI_ICTHENEXTBOSS_GLORGOLOCH = "Глорголок Разрушитель",
	SI_ICTHENEXTBOSS_CHARR = "Поджигатель Чар",
	SI_ICTHENEXTBOSS_KHROGO = "Король Крого",
	SI_ICTHENEXTBOSS_MALYGDA = "Леди Малигда",
	SI_ICTHENEXTBOSS_MAZALUHAD = "Мазалухад",
	SI_ICTHENEXTBOSS_NUNATAK = "Нунатак",
	SI_ICTHENEXTBOSS_MATRON = "Визжащая Матрона",
	SI_ICTHENEXTBOSS_VOLGHASS = "Волгас",
	SI_ICTHENEXTBOSS_YSENDA = "Изенда Сияющая",
	SI_ICTHENEXTBOSS_ZOAL = "Зоал Недремлющий",
	SI_ICTHENEXTBOSS_MOLAG = "Имитация Молага Бала",

	-- DISTRICTS
	SI_ICTHENEXTBOSS_NOBLESDISTRICT = "5-Район Знати",
	SI_ICTHENEXTBOSS_ARENADISTRICT = "2-Район Арена",
	SI_ICTHENEXTBOSS_TEMPLEDISTRICT = "4-Храмовый район",
	SI_ICTHENEXTBOSS_ARBORETUMDISTRICT = "3-Дендрарий",
	SI_ICTHENEXTBOSS_MEMORIALDISTRICT = "1-Мемориальный район",
	SI_ICTHENEXTBOSS_ELVENGARDENSDISTRICT = "6-Район Эльфийские сады",
	SI_ICTHENEXTBOSS_CAN = "0-Имперская канализация",
	
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_NOBLESDISTRICT = "5-Район Знати",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_ARENADISTRICT = "2-Район Арена",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_TEMPLEDISTRICT = "4-Храмовый район",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_ARBORETUMDISTRICT = "3-Дендрарий",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_MEMORIALDISTRICT = "1-Мемориальный район",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_ELVENGARDENSDISTRICT = "6-Район Эльфийские сады",
	SI_BINDING_NAME_SI_ICTHENEXTBOSS_CAN = "0-Имперская канализация",

	-- GUI
	SI_ICTHENEXTBOSS_GUI_WIDTH = "270",
	SI_ICTHENEXTBOSS_OPTION_DESCRIPTION = "Отслеживает время появления боссов в Имперском Городе.",
	SI_ICTHENEXTBOSS_OPTION_TIMETABLE = "Показать таблицу с временем появления",
	SI_ICTHENEXTBOSS_OPTION_MAPTIMERS = "Показать время появления на карте",
	SI_ICTHENEXTBOSS_OPTION_MAPTIMERS_TOOLTIP = "Это отключит увеличение на карте Имперского Города.\nНе работает с Режимом-Геймпада!",
	SI_ICTHENEXTBOSS_OPTION_EVENT_TIMERS = "Event timers (7 minutes)",
	SI_ICTHENEXTBOSS_OPTION_OPACITY = "Прозрачность (без курсора)",
	SI_ICTHENEXTBOSS_OPTION_OPACITY_TOOLTIP = "Прозрачность окна, когда курсор не наведён. Полностью непрозрачно при наведении.",
	SI_ICTHENEXTBOSS_OPTION_HIDE_COMBAT = "Скрывать в бою",
	SI_ICTHENEXTBOSS_OPTION_HIDE_MOVING = "Скрывать при движении",
	SI_ICTHENEXTBOSS_OPTION_REDUCED = "Сокращённый вид (только следующий район)",
	SI_ICTHENEXTBOSS_OPTION_REDUCED_TOOLTIP = "Уменьшает окно, показывая только следующий район.",
	SI_ICTHENEXTBOSS_OPTION_DEBUG = "Отладка",
	SI_ICTHENEXTBOSS_NO_TIMERS = "Нет таймеров",
}

for id, value in pairs(strings) do
	ZO_CreateStringId(id, value)
	SafeAddVersion(id, 1)
end