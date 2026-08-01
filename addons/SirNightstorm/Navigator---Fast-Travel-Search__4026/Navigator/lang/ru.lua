local mkstr = Navigator.mkstr

-- Controls menu entry (opens the Navigator tab on the World Map)
mkstr("SI_BINDING_NAME_NAVIGATOR_SEARCH", "Открыть карту мира")
--mkstr("SI_BINDING_NAME_NAVIGATOR_FOCUSSEARCH", "Search (on World Map)")

-- Name of the tab on the World Map
mkstr("NAVIGATOR_TAB_SEARCH","Навигатор")




-- Edit box hint text (<<1>> is replaced by 'Tab')
mkstr("NAVIGATOR_SEARCH_KEYPRESS","Поиск (<<1>>)")
mkstr("NAVIGATOR_SEARCH","Название места, локации или @игрока")

-- Category Headings
mkstr("NAVIGATOR_CATEGORY_BOOKMARKS", "Закладки")
mkstr("NAVIGATOR_CATEGORY_RECENT", "Недавние")
mkstr("NAVIGATOR_CATEGORY_ZONES", "Локации")




-- Result hints
mkstr("NAVIGATOR_HINT_NORESULTS", "Результаты не найдены")
mkstr("NAVIGATOR_HINT_NORECENTS", "Здесь будут автоматически отображаться места, которые вы посещали недавно")
mkstr("NAVIGATOR_HINT_NOBOOKMARKS", "Нажмите правой кнопкой мыши по месту, чтобы создать (или удалить) закладку для него")
mkstr("NAVIGATOR_HINT_SHOWUNDISCOVERED", "Нажмите, чтобы отобразить неисследованные места")

-- Enter key label (keep it short!)
mkstr("NAVIGATOR_KEY_ENTER", "Enter")






-- Tooltips
mkstr("NAVIGATOR_NOT_KNOWN", "Не открыто этим персонажем") -- Location not known
mkstr("NAVIGATOR_TIP_CLICK_TO_TRAVEL", "Щелкните, чтобы переместиться в <<1>>") -- 1:zone
mkstr("NAVIGATOR_TIP_DOUBLECLICK_TO_TRAVEL", "Щелкните дважды, чтобы переместиться в <<1>>") -- 1:zone
mkstr("NAVIGATOR_TOOLTIP_ACTION_RESULT", "<<1>>: <<2>>") -- e.g. 1:"Single-click" 2:"Show On Map"
--mkstr("NAVIGATOR_TOOLTIP_GUILDTRADERS", "<<1[/1 Guild Trader nearby/$d Guild Traders nearby]>>")
--mkstr("NAVIGATOR_TOOLTIP_VIEWMENU", "Switch to alternative views")
--mkstr("NAVIGATOR_TOOLTIP_CLEARVIEW", "Right-click to clear view\nRight-click to clear view")

-- Action and menu items
mkstr("NAVIGATOR_TRAVEL_TO_ZONE", "Переместиться в <<1>>")
mkstr("NAVIGATOR_MENU_ADDBOOKMARK", "Добавить закладку")
mkstr("NAVIGATOR_MENU_ADDHOUSEBOOKMARK", "Добавить закладку основного дома")
mkstr("NAVIGATOR_MENU_REMOVEBOOKMARK", "Удалить закладку")
mkstr("NAVIGATOR_MENU_MOVEBOOKMARKUP", "Переместить закладку вверх")
mkstr("NAVIGATOR_MENU_MOVEBOOKMARKDOWN", "Переместить закладку вниз")
--mkstr("NAVIGATOR_MENU_PLAYERS", "Players")
--mkstr("NAVIGATOR_MENU_GUILDTRADERS", "Guild Traders")
--mkstr("NAVIGATOR_MENU_TREASUREMAPS_SURVEYS", "Treasure Maps & Surveys")
--mkstr("NAVIGATOR_MENU_CLEARVIEW", "Clear view")



-- Status / error messages
mkstr("NAVIGATOR_NO_TRAVEL_PLAYER", "Нет игроков для перемещения")
mkstr("NAVIGATOR_CANNOT_TRAVEL_TO_PLAYER", "Невозможно переместиться к игроку <<1>>") -- 1:player
mkstr("NAVIGATOR_NO_PLAYER_IN_ZONE", "Не удалось найти игрока, к которому можно переместиться в локации <<1>>") -- 1:zone
mkstr("NAVIGATOR_PLAYER_NOT_IN_ZONE", "<<1>> больше не находится в <<2>>") -- 1:player 2:zone
mkstr("NAVIGATOR_TRAVELING_TO_LOCATION", "Перемещение в <<1>>") -- 1:location
mkstr("NAVIGATOR_RECALLING_TO_LOCATION_COST", "Перемещение в <<1>> за <<2>>") -- 1:location 2:cost
mkstr("NAVIGATOR_TRAVELING_TO_ZONE_VIA_PLAYER", "Перемещение в <<1>> к <<2>>") -- 1:zone 2:player
mkstr("NAVIGATOR_TRAVELING_TO_PLAYER_IN_ZONE", "Перемещение к <<1>> в <<2>>") -- 1:player 2:zone
mkstr("NAVIGATOR_TRAVELING_TO_HOUSE_INSIDE", "Перемещение в <<1>> (внутри)") -- 1:house
mkstr("NAVIGATOR_TRAVELING_TO_HOUSE_OUTSIDE", "Перемещение в <<1>> (снаружи)") -- 1:house
mkstr("NAVIGATOR_TRAVELING_TO_PLAYER_HOUSE", "Перемещение в дом <<gu:1>>") -- 1:house

-- Chat slash command
mkstr("NAVIGATOR_SLASH_DESCRIPTION", "Навигатор: Перемещение к указанной локации, дорожному святилищу, дому или игроку")

-- Custom location names
mkstr("NAVIGATOR_LOCATION_OBLIVIONPORTAL", "Портал Обливиона")

-- Add-on Settings
--mkstr("NAVIGATOR_SETTINGS_DEFAULT_TAB_NAME",                "Автоматический выбор вкладки аддона")
--mkstr("NAVIGATOR_SETTINGS_DEFAULT_TAB_TOOLTIP",             "Автоматическое переключение на вкладку аддона при открытии карты.")
--mkstr("NAVIGATOR_SETTINGS_DEFAULT_TAB_WARNING",             "Этот аддон не может автоматически переключаться на вкладку, когда включен аддон «|c99FFFFFaster Travel|r».")

mkstr("NAVIGATOR_SETTINGS_RECENT_COUNT_NAME",               "Количество последних направлений")
mkstr("NAVIGATOR_SETTINGS_RECENT_COUNT_TOOLTIP",            "Укажите 0, чтобы отключить список «Недавнее».")

mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_NAME",        "Подтверждение быстрого перемещения")
mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_TOOLTIP",     "Использование стандартного оповещения при взаимодействии с дорожными святилищами. Активно только на вкладке аддона и не затрагивает карту мира.")
mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_CHOICE_1",    "Всегда")
mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_CHOICE_2",    "Когда имеется стоимость <<1>>") --  1:goldicon
mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_CHOICE_3",    "Никогда")

mkstr("NAVIGATOR_SETTINGS_LIST_POI_NAME",                   "Отображение точек интереса в локации")
mkstr("NAVIGATOR_SETTINGS_LIST_POI_TOOLTIP",                "Когда отключено, в списке будут отображаться только такие «направления» как дорожные святилища, подземелья, дома или игроки.")

mkstr("NAVIGATOR_SETTINGS_INCLUDE_UNDISCOVERED_NAME",       "Отображение и поиск неисследованных мест")
mkstr("NAVIGATOR_SETTINGS_INCLUDE_UNDISCOVERED_TOOLTIP",    "Отображение неисследованных мест в списке локаций и в результатах поиска.")

mkstr("NAVIGATOR_SETTINGS_USE_HOUSE_NICKNAME_NAME",         "Отображение и поиск названий домов")

mkstr("NAVIGATOR_SETTINGS_AUTO_FOCUS_NAME",                 "Автофокус на строке поиска")
mkstr("NAVIGATOR_SETTINGS_AUTO_FOCUS_TOOLTIP",              "Автоматическое переключение курсора на в строку поиска при открытии вкладки аддона. Это приведёт к невозможности закрыть карту клавишей [M] или [Alt]. Используйте клавишу [Escape] для выхода.")
mkstr("NAVIGATOR_SETTINGS_AUTO_FOCUS_WARNING",              "Когда опция включена, клавиши [M] и [Alt] не будет закрывать карту. Используйте клавишу [Escape] для выхода.")

mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_NAME",               "Команда чата")
mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_TOOLTIP",            "Выбор используемой чат-команды.")
mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_CHOICE_1",           "Отключена")
mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_WARNING",            "Аддон «|c8080FFPithka's Achievement Tracker|r» также использует команду «/tp».")
mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_UNAVAILABLE",        "|cFFFF00|t24:24:/esoui/art/miscellaneous/eso_icon_warning.dds:inheritcolor|t|r Чат-команды доступны только при использовании аддона «|c99FFFFLibSlashCommander|r».")

mkstr("NAVIGATOR_SETTINGS_ACTIONS_NAME",                    "Управление с помощью мыши и клавиатуры")
mkstr("NAVIGATOR_SETTINGS_ACTIONS_SINGLE_CLICK",            "Одиночное нажатие")
mkstr("NAVIGATOR_SETTINGS_ACTIONS_DOUBLE_CLICK",            "Двойное нажатие")
mkstr("NAVIGATOR_SETTINGS_ACTIONS_ENTER_KEY",               "Клавиша [Enter]")
--mkstr("NAVIGATOR_SETTINGS_ACTIONS_CHOICE_SHOW_ON_MAP",      "Показать на карте")
mkstr("NAVIGATOR_SETTINGS_ACTIONS_CHOICE_SET_DESTINATION",  "Указать пункт назначения")
--mkstr("NAVIGATOR_SETTINGS_ACTIONS_CHOICE_TRAVEL",           "Переместиться")

mkstr("NAVIGATOR_SETTINGS_DESTINATION_ACTIONS_NAME",        "Основные направления")
mkstr("NAVIGATOR_SETTINGS_DESTINATION_ACTIONS_TOOLTIP",     "Взаимодействие с дорожными святилищами, подземельями, испытаниями, аренами и крепостями.")
mkstr("NAVIGATOR_SETTINGS_DESTINATION_ACTIONS_WARNING",     "Когда одиночное нажатие установлено для перемещения, двойное нажатие будет недоступно.")

mkstr("NAVIGATOR_SETTINGS_ZONE_ACTIONS_NAME",               "Локации")
--mkstr("NAVIGATOR_SETTINGS_ZONE_ACTIONS_TOOLTIP",            "Mouse and key actions for zones")


--mkstr("NAVIGATOR_SETTINGS_HOUSE_ACTIONS_TOOLTIP",           "Mouse and key actions for your houses")


mkstr("NAVIGATOR_SETTINGS_POI_ACTIONS_TOOLTIP",             "Взаимодействие с такими местами как города, камни Мундуса и примечательные места.")

mkstr("NAVIGATOR_SETTINGS_JOIN_GUILD_NAME",                 "Присоединяйтесь к нашей гильдии!")
mkstr("NAVIGATOR_SETTINGS_JOIN_GUILD_DESCRIPTION",          "|cC5C29E|H1:guild:767808|hMora's Whispers|h — это активная социальная гильдия с бесплатным торговцем, множеством событий, еженедельными лотереями, полностью оборудованным гильд-холлом, активным Discord и многим другим! Нажмите на ссылку выше, чтобы узнать больше!|r")


-- -----------------------------------------------------------------------------
-- Notes: gsub uses Lua patterns - https://www.lua.org/pil/20.2.html
--        "^Thing" matches "Thing" at the start of a name
--        "Thing$" matches "Thing" at the end of a name
function Navigator.DisplayName(name)
    name = name:gsub("^Дорожное святилище ", "ДС ")
    name = name:gsub("^Подземелье: ", "") -- Dungeon
    name = name:gsub("^Испытание: ", "") -- Trial
    name = name:gsub("^Дорожное святилище ", "") -- Wayshrine
    name = zo_strformat("<<C:1>>", name) -- Upper-case first letter
    return name
end
function Navigator.SearchName(name)
    name = name:gsub("^Подземелье: ", "") -- Dungeon
    name = name:gsub("^Испытание: ", "") -- Trial
    name = name:gsub("^Дорожное святилище ", "") -- Wayshrine

    -- Allow searches like ГП2 (for City of Ash II)
    -- "Город Пепла II"
    name = name:gsub(" II$", " II 2", 1):gsub(" I$", " I 1", 1)
    return name
end
function Navigator.KeepSuffix(name)
    return nil
end
