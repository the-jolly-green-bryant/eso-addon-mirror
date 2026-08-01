------------------------------------------------------------------------------------------------------------------
-- Russian (ru)
-- Format and phrasing by Pirokar13
-- version 1.0
------------------------------------------------------------------------------------------------------------------
-- Every variable must start with this addon's unique ID, as each is a global. 
-- ZDFT_
local strings = {
    -- Addon name
    ["ZDFT_NAME"] = "Zai's Dungeon Finder Tools",

    -- Error Strings
    ["ZDFT_INVALID_DUNGEON_DATA"] = "Неверные данные подземелья",
    ["ZDFT_INVALID_DUNGEON_DATA_TEXT"] = "Неверные данные подземелья",
    ["ZDFT_COULD_NOT_FIND_FILTER"] = "Не удалось найти фильтр",
    ["ZDFT_COULD_NOT_ACCESS_DROPDOWN"] = "Не удалось получить доступ к элементам выпадающего списка",

    -- Dungeon Types
    ["ZDFT_DLC_DUNGEON_TEXT"] = "Подземелье из дополнений",
    ["ZDFT_BASE_GAME_TEXT"] = "Базовая игра",
    
    -- Difficulty Types
    ["ZDFT_NORMAL_VETERAN"] = "Любая сложность",

    -- Achievement Categories
    ["ZDFT_VETERAN_ACHIEVEMENTS_TEXT"] = "Ветеранские достижения",
    ["ZDFT_TRIFECTA_TEXT"] = "Трифекта",
    ["ZDFT_HARDMODE_TEXT"] = "Сложный режим",
    ["ZDFT_SPEEDRUN_TEXT"] = "Скоростное прохождение",
    ["ZDFT_NODEATH_TEXT"] = "Без смертей",
    ["ZDFT_ALL_3_VETERAN"] = "Все 3 ветеранских достижения",
    
    -- Pledge Givers
    ["ZDFT_MAJ_AL_RAGATH"] = "Мадж аль-Рагат",
    ["ZDFT_GLIRION_REDBEARD"] = "Глирион Рыжебородый",
    ["ZDFT_URGARLAG_CHIEF"] = "Ургарлаг Бич Вождей",
    
    -- Pledge Quest Status
    ["ZDFT_DAILY_PLEDGE"] = "Ежедневный обет",
    ["ZDFT_TODAYS_PLEDGE_QUESTS"] = "Сегодняшние обеты",
    ["ZDFT_TODAYS_PLEDGE_STATUS"] = "Статус сегодняшних обетов",
    ["ZDFT_READY_TO_TURN_IN"] = "Готово к сдаче",
    ["ZDFT_QUEST_IN_PROGRESS"] = "Задание в процессе",
    ["ZDFT_ALREADY_COMPLETED_TODAY"] = "Уже выполнено сегодня",
    ["ZDFT_AVAILABLE_TO_ACCEPT"] = "Доступно к принятию",
    ["ZDFT_NO_ACTIVE_QUEST"] = "Нет активного задания",
    
    -- Pledge Actions & Results
    ["ZDFT_SELECT_PLEDGES_BUTTON"] = "Выбрать обеты на сегодня",
    ["ZDFT_NO_PLEDGES_FOUND"] = "Не найдено обетов для выбранной сложности.",
    ["ZDFT_NO_PLEDGES_FOUND_TEXT"] = "Не найдено обетов для выбранной сложности.",
    ["ZDFT_SELECTED_PLEDGES_FORMAT"] = "Обетов выбрано: %d, сложность: %s",
    ["ZDFT_DESELECTED_PLEDGES_TEXT"] = "Отменено обетов: %d",

    -- Collections
    ["ZDFT_SETTINGS_COLLECTIONS"] = "Коллекции",
    ["ZDFT_SETTINGS_SHOW_COLLECTION_BUTTON"] = "Показать кнопку коллекций",
    ["ZDFT_SETTINGS_SHOW_COLLECTION_BUTTON_TT"] = "Показать кнопку для быстрого выбора подземелий с неполными наборами снаряжения или коллекциями стилей",
    ["ZDFT_SETTINGS_COLLECTION_TYPE"] = "Тип коллекции",
    ["ZDFT_SETTINGS_COLLECTION_TYPE_TT"] = "Выберите тип коллекций для проверки при выборе подземелий",
    ["ZDFT_SETTINGS_COLLECTION_SETS"] = "Части наборов",
    ["ZDFT_SETTINGS_COLLECTION_MOTIFS"] = "Стили мотивов",
    ["ZDFT_SETTINGS_COLLECTION_BOTH"] = "Оба",
    ["ZDFT_SETTINGS_COLLECTION_DIFFICULTY"] = "Сложность кнопки коллекции",
    ["ZDFT_SETTINGS_COLLECTION_DIFFICULTY_TT"] = "Выберите, какие сложности подземелий выбирать для коллекций",

    -- Collection Button Text and Messages
    ["ZDFT_SELECT_COLLECTIONS_BUTTON"] = "Выбрать коллекции",
    ["ZDFT_SELECT_COLLECTIONS_BUTTON_FORMAT"] = "Выбрать %s",
    ["ZDFT_SETS_TEXT"] = "Наборы",
    ["ZDFT_MOTIFS_TEXT"] = "Мотивы",

    -- Collection Button Alert Messages
    ["ZDFT_NO_COLLECTIONS_FOUND_TEXT"] = "Не найдено подземелий с неполными %s",
    ["ZDFT_DESELECTED_COLLECTIONS_TEXT"] = "Отменено %d коллекций",
    ["ZDFT_SELECTED_COLLECTIONS_FORMAT"] = "Выбрано %d подземелий %s с неполными коллекциями",
    ["ZDFT_SELECTED_COLLECTIONS_FORMAT_NO_DIFFICULTY"] = "Выбрано %d подземелий с неполными %s",

    -- Color Legend
    ["ZDFT_COLOR_LEGEND_TITLE"] = "Цветовая легенда обетов",
    ["ZDFT_COLOR_LEGEND_BLUE"] = "Синий: Доступно к принятию",
    ["ZDFT_COLOR_LEGEND_ORANGE"] = "Оранжевый: Задание в процессе",
    ["ZDFT_COLOR_LEGEND_GREEN"] = "Зелёный: Готово к сдаче",
    ["ZDFT_COLOR_LEGEND_GREY"] = "Серый: Уже выполнено сегодня",
    
    -- Settings - Achievement Icons
    ["ZDFT_SETTINGS_ACHIEVEMENT_ICONS"] = "Иконки достижений",
    ["ZDFT_SETTINGS_SHOW_TRIFECTA"] = "Показывать иконку трифекты",
    ["ZDFT_SETTINGS_SHOW_TRIFECTA_TT"] = "Показывать иконку достижения трифекты",
    ["ZDFT_SETTINGS_SHOW_HARDMODE"] = "Показывать иконку усложненного режима",
    ["ZDFT_SETTINGS_SHOW_HARDMODE_TT"] = "Показывать иконку достижения усложненного режима",
    ["ZDFT_SETTINGS_SHOW_NODEATH"] = "Показывать иконку без смертей",
    ["ZDFT_SETTINGS_SHOW_NODEATH_TT"] = "Показывать иконку достижения без смертей",
    ["ZDFT_SETTINGS_SHOW_SPEEDRUN"] = "Показывать иконку скоростного прохождения",
    ["ZDFT_SETTINGS_SHOW_SPEEDRUN_TT"] = "Показывать иконку достижения на скоростное прохождение",
    ["ZDFT_SETTINGS_SHOW_CLEARED"] = "Показывать иконку пройденного подземелья",
    ["ZDFT_SETTINGS_SHOW_CLEARED_TT"] = "Показывать иконку достижения на задание подземелья",
    ["ZDFT_SETTINGS_SHOW_MOTIF"] = "Показывать иконку мотива",
    ["ZDFT_SETTINGS_SHOW_MOTIF_TT"] = "Показывать иконку достижения мотива",
    ["ZDFT_SETTINGS_SHOW_SET"] = "Показывать иконку коллекции наборов",
    ["ZDFT_SETTINGS_SHOW_SET_TT"] = "Показывать иконку коллекции наборов",

    -- Settings - Pledge
    ["ZDFT_SETTINGS_PLEDGE"] = "Настройки обетов",
    ["ZDFT_SETTINGS_HIGHLIGHT_PLEDGES"] = "Подсветка подземелий для обетов",
    ["ZDFT_SETTINGS_HIGHLIGHT_PLEDGES_TT"] = "Окрашивать названия подземелий для отображения статуса",
    ["ZDFT_SETTINGS_SHOW_PLEDGE_ICON"] = "Отображать иконку обета",
    ["ZDFT_SETTINGS_SHOW_PLEDGE_ICON_TT"] = "Отображать иконку ключа Неустрашимых рядом с подземельями для обетов",
    
    -- Settings - UI
    ["ZDFT_SETTINGS_UI"] = "Настройки интерфейса",
    ["ZDFT_SETTINGS_SHOW_BUTTON"] = "Показывать кнопку 'Выбрать обеты на сегодня'",
    ["ZDFT_SETTINGS_SHOW_BUTTON_TT"] = "Показывать кнопку для автоматического выбора сегодняшних обетов",
    ["ZDFT_SETTINGS_PLEDGE_DIFFICULTY"] = "Сложность обетов",
    ["ZDFT_SETTINGS_PLEDGE_DIFFICULTY_TT"] = "Какую сложность использовать при выборе сегодняшних обетов",
    ["ZDFT_SETTINGS_FOLLOW_FINDER"] = "Сложность в режиме группы",
    ["ZDFT_SETTINGS_ALWAYS_NORMAL"] = "Всегда обычная",
    ["ZDFT_SETTINGS_ALWAYS_VETERAN"] = "Всегда ветеранская",
    ["ZDFT_SETTINGS_BOTH_DIFFICULTIES"] = "Любая сложность",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
