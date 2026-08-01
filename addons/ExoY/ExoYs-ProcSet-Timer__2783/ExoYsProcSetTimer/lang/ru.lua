-- Set Origin Locations
EPT_ORIGIN_ALL = "Все"
EPT_ORIGIN_ARENA = "Арена"
EPT_ORIGIN_TRIAL = "Испытания"
EPT_ORIGIN_DUNGEON = "Подземелья"
EPT_ORIGIN_UNDAUNTED = "Неустрашимые"
EPT_ORIGIN_CRAFTING = "Ремесленное"
EPT_ORIGIN_OVERLAND = "Мир"
EPT_ORIGIN_MYTHIC = "Мифический"
EPT_ORIGIN_MISC = "Разное"
EPT_ORIGIN_PVP = "PvP"
--
--
EPT_DEMO_GUI_NAME = "Пример сетов"
EPT_DUMMY_DESCRIPTION = "Используйте пример интерфейса для упрощения настройки. Он не может отображать цвета или моделировать какое-либо поведение (пока)."
EPT_DUMMY_BUTTON = "Показать/Скрыть Пример"

EPT_SPECIAL_NOTE = "Примечание. Изменения Design влияют только на специальные индикаторы после /reloadui. \n Это будет исправлено в будущем обновлении."


EPT_ACTION_TOGGLE_STRING = "Toggle"
--------------
-- Bindings --
--------------

EPT_BINDING_ZEN_TOOGLE = "Заан: Сосредоточьтесь на боссе - Toggle"

----------
-- MENU --
----------

--Feedback
EPT_FEEDBACK_DESCRIPTION = "У вас были какие-нибудь ошибки? \n - Пожалуйста, дайте мне об этом знать!"
EPT_FEEDBACK_BUTTON = "Обратная связь"
EPT_FEEDBACK_WARNING = "Я активно играю на PC(EU). \n Ожидайте задержки в ответах на PC(NA)."

-- Submenu Names
EPT_SETTINGS_INFORMATION = "Общие Настройки"
EPT_SETTINGS_DESIGN = "Design"


-- Settings General



-- Settings Design

EPT_SETTINGS_ICON_NAME = "Размер иконки"
EPT_SETTINGS_ICON_TOOLTIP = ""

EPT_SETTINGS_FONT_NAME = "Шрифт"
EPT_SETTINGS_FONT_TOOLTIP = "Это влияет на все записи, кроме основного индикатора.."

EPT_SETTINGS_COLORS = "Цвет"

EPT_SETTINGS_COLOR_TIMER = "Перезарядка"
EPT_SETTINGS_COLOR_ACTIVE_NAME = "Активный"
EPT_SETTINGS_COLOR_ACTIVE_TOOLTIP = ""
EPT_SETTINGS_COLOR_COOLDOWN_NAME = "Перезарядка"
EPT_SETTINGS_COLOR_COOLDOWN_TOOLTIP = ""
EPT_SETTINGS_COLOR_STANDBY_NAME = "Готов"
EPT_SETTINGS_COLOR_STANDBY_TOOLTIP = ""

EPT_SETTINGS_COLOR_VALUE = "Затронутые Игроки"
EPT_SETTINGS_COLOR_HIGH_NAME = "Высокий"
EPT_SETTINGS_COLOR_HIGH_TOOLTIP = "Затронуто более 70% вашей группы."
EPT_SETTINGS_COLOR_MEDIUM_NAME = "Средний"
EPT_SETTINGS_COLOR_MEDIUM_TOOLTIP = "Затронуто от 30% до 70% вашей группы."
EPT_SETTINGS_COLOR_LOW_NAME = "Низкий"
EPT_SETTINGS_COLOR_LOW_TOOLTIP = "Затронуто менее 30% вашей группы."

EPT_SETTINGS_INDICATOR = "Индикатор"
EPT_SETTINGS_INDICATOR_SHOW_DECIMAL_NAME = "Показывать Десятичные"
EPT_SETTINGS_INDICATOR_SHOW_DECIMAL_TOOLTIP = "Отображает первую десятичную цифру, когда остается менее 10 секунд"
EPT_SETTINGS_INDICATOR_CHANGE_COLOR_NAME = "Сменить Цвет"
EPT_SETTINGS_INDICATOR_CHANGE_COLOR_TOOLTIP = ""
EPT_SETTINGS_INDICATOR_NAME = "Размер"
EPT_SETTINGS_INDICATOR_TOOLTIP = ""
EPT_SETTINGS_INDICATOR_FONT_NAME = "Шрифт"
EPT_SETTINGS_INDICATOR_FONT_TOOLTIP = ""
EPT_SETTINGS_INDICATOR_OFFSETX_NAME = "Смещение X"
EPT_SETTINGS_INDICATOR_OFFSETX_TOOLTIP = ""
EPT_SETTINGS_INDICATOR_OFFSETY_NAME = "Смещение Y"
EPT_SETTINGS_INDICATOR_OFFSETY_TOOLTIP = ""

EPT_SETTINGS_EDGE = "Края"
EPT_SETTINGS_EDGE_SHOW_NAME = "Показать край"
EPT_SETTINGS_EDGE_SHOW_TOOLTIP = ""
EPT_SETTINGS_EDGE_CHANGE_COLOR_NAME = "Изменить цвет"
EPT_SETTINGS_EDGE_CHANGE_COLOR_TOOLTIP = ""
EPT_SETTINGS_EDGE_NAME = "Размер"
EPT_SETTINGS_EDGE_TOOLTIP = ""

EPT_SETTINGS_NAME_DISPLAY = "Показывать название сета"
EPT_SETTINGS_NAME_DISPLAY_NAME = "Размер"
EPT_SETTINGS_NAME_DISPLAY_TOOLTIP = ""
EPT_SETTINGS_NAME_DISPLAY_POSITION_NAME = "Позиция"
EPT_SETTINGS_NAME_DISPLAY_POSITION_TOOLTIP = ""
EPT_SETTINGS_NAME_DISPLAY_SHOW_BACKGROUND_NAME = "Показывать фон"
EPT_SETTINGS_NAME_DISPLAY_SHOW_BACKGROUND_TOOLTIP = ""
EPT_SETTINGS_NAME_DISPLAY_GAME_NAME = "Игровой режим"
EPT_SETTINGS_NAME_DISPLAY_GAME_TOOLTIP = ""
EPT_SETTINGS_NAME_DISPLAY_MOUSE_NAME = "Режим мыши"
EPT_SETTINGS_NAME_DISPLAY_MOUSE_TOOLTIP = ""
EPT_SETTINGS_NAME_DISPLAY_HOVER_NAME = "Только наведение мыши"
EPT_SETTINGS_NAME_DISPLAY_HOVER_TOOLTIP = ""

EPT_SETTINGS_TRANSPARENCY = "Очистить экран (Экспериментальный)"
EPT_SETTINGS_TRANSPARENCY_NAME = "Cкрыть иконки, когда не в бою"
EPT_SETTINGS_TRANSPARENCY_WARNING = "Если этот параметр включен, иконки нельзя перемещать, если они не находятся в бою."


EPT_SETTINGS_SPECIAL = "Специальные Сеты"

EPT_SETTINGS_SPECIAL_ZEN_FOCUS_NAME = "Фокус на боссе"
EPT_SETTINGS_SPECIAL_ZEN_FOCUS_TOOLTIP = "Показывает стеки З'ен для босса постоянно, если вместо целевого юнита присутствует только один."
EPT_SETTINGS_SPECIAL_ZEN_FOCUS_HINT = "Чтобы изменить эту опцию во время боя, можно назначить горячую клавишу или использовать команду в чат */eptzen*"
EPT_SETTINGS_SPECIAL_ZEN_FOCUS_NOTE = "Примечание: информацию о юнитах можно получить только при наведении на прицел или если юнит классифицирован как босс.\n"..
"Поскольку З'ен обычно применяется только к боссу. Эта опция упрощает отслеживание, даже если не смотрит на босса.\n"..
"Однако могут возникнуть ситуации, когда это нежелательно. Поэтому предусмотрены чат-команда и горячая клавиша.\n"

EPT_SETTINGS_SPECIAL_OPPORTUNIST_SLAYER = "Показать ожидаемую продолжительность Великой Ярости»."
EPT_SETTINGS_SPECIAL_OPPORTUNIST_AFFECTED = "Показать количество затронутых единиц."

EPT_SETTINGS_SPECIAL_MARTIAL_STAMINA_NAME = "Показать панель запаса сил"
EPT_SETTINGS_SPECIAL_MARTIAL_STAMINA_NOTE = "Примечание. Чтобы адаптировать панель запаса сил к значку, измените размер. На данный момент требуется /reloadui."

------------
-- Filter --
------------

EPT_WHITELIST = "Белый список"
EPT_BLACKLIST = "Черный список"

EPT_ADD_TO = "Добавить к"
EPT_REMOVE_FROM = "Удалить из"

-----------------
-- Menu Filter --
-----------------

EPT_SETTINGS_FILTER_WHITE = "Белый список"
EPT_SETTINGS_FILTER_BLACK = "Черный список"
EPT_SETTINGS_FILTER = "Фильтр"
EPT_SETTINGS_FILTER_ACTIVE_NAME = "Активировать фильтр"
EPT_SETTINGS_FILTER_ACTIVE_TOOLTIP = ""
EPT_SETTINGS_FILTER_TYPE_NAME = "Выберите тип фильтра"
EPT_SETTINGS_FILTER_TYPE_TOOLTIP = "Белый список = ON; Черный список = OFF"
EPT_SETTINGS_FILTER_MANAGE_LIST = "Управление фильтрами"
EPT_SETTINGS_FILTER_SELECT_ACTION ="Выберите действие"
EPT_SETTINGS_FILTER_SELECT_ACTION_TOOLTIP = "Добавить = ON; Удалить = OFF"
EPT_SETTINGS_FILTER_SELECT_ORIGIN = "Выбрать источник"
EPT_SETTINGS_FILTER_SELECT_SET = "Выбрать сет"
EPT_SETTINGS_BUTTON_ADD = "Добавить"
EPT_SETTINGS_BUTTON_REMOVE = "Удалить"
EPT_SETTINGS_FILTER_BUTTON = "Выполнить"

EPT_SETTINGS_FILTER_SET_INFO = "Информация о сете"
