--                v 3                --
TimEmote = TimEmote or {}
local TE = TimEmote
TE.Lang = TE.Lang or {}

TE.Lang["ru"] = {
		LOCALE = "RU",

		Settings_control = "Настройки",
		Settings_title1 = "Перемещать окно",
		Settings_description1 = "Разрешить перемещение окна TimEmote.",
		Settings_displaySize = "Размер интерфейса",
		Settings_displaySizeTip = "Меняет шрифт, высоту строк и ширину списков эмоций.",
		DisplaySize_compact = "Компактный (14)",
		DisplaySize_normal = "Обычный (15)",
		DisplaySize_large = "Крупный (16)",
		Settings_contrast = "Контраст фона",
		Settings_contrastTip = "Настраивает яркость фона заголовков и списков эмоций.",
		Settings_title3 = "Прозрачность",
		Settings_description3 = "Изменить прозрачность окна TimEmote.",
		Settings_warning = "Нужно перезагрузить интерфейс.",

		Settings_group = "Группы",
		Settings_groupItem = "Группа",
		Settings_groupItemTip = "Название группы",
		Settings_groupNoname = "Без имени",
		Settings_groupDefault = "Избранное",
		Settings_groupNewBtn = "Новая",
		Settings_groupNewBtnTip = "Добавить группу",
		Settings_groupDeleteBtn = "Удалить",
		Settings_groupDeleteBtnTip = "Удалить группу",
		Settings_groupDeleteWarning = "Группа и все её избранные эмоции будут удалены.",

		UI_list = "Список",

		Message_notSelGroup = "Сначала выберите группу кликом по заголовку.",
		Message_noEmote = "В группе нет эмоций.",
		Message_lastGroup = "Должна остаться хотя бы одна группа.",

		Tooltip_playRandom = "Случайная эмоция",
		Tooltip_moveDown = "Переместить вниз",
		Tooltip_moveUp = "Переместить вверх",
		Tooltip_listHeader = "Эмоция:\nЛКМ: сыграть\nShift + ЛКМ: добавить/убрать из активной группы\nДвойной клик: следующий цвет",
		Tooltip_groupHeader = "Заголовок:\nЛКМ: выбрать группу\n--------------------\nЭмоция:\nЛКМ: сыграть\nShift + ЛКМ: убрать\nДвойной клик: следующий цвет",
	}
