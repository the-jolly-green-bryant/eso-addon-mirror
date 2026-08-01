-- Russian localization
 
local _addon = _G["DailyCraftStatus"]
 
-- the strings need to match game strings 
_addon.langQuestInfo = 
{
    ["deliver"] = "Доставить", 
    ["craft"] = { "Создать" },
    ["material"] = { "материал" },
    ["questnames"] = {
        --quest name unique substring followed by status character (or any string actually) 
        {"кузнец","K"},
        {"портн","П"},
        {"столяр","C"},
        {"ювелир","Ю"},
        {"алхимик","A"},
        {"зачаровател","З"},
        {"снабжен","C"}
    }   
}   
 
-- addon strings for translation
 
_addon.translation =
{
    ["Lock"] = "Заблокировать",
    ["Save"] = "Сохранить",
    ["Unlock"] = "Разблокировать",
    ["Toggle Stock"] = "Отображение материалов",
    ["Toggle Raw Stock"] = "Отображение сырья",
    ["Toggle Surveys"] = "Отображение карт",
    ["Always On"] = "Всегда включено",
    ["Auto-hide"] = "Автоскрытие",
    ["Mail Stock"] = "Просчитать почту",
    ["Loot Mail"] = "Забрать из почты",
    ["Pick Up Survey"] = "Извлечь карту",
    ["Clear Survey Pick List"] = "Очистить список карт",
    ["Settings"] = "Настройки",
    ["Alts Status"] = "Другие персонажи",
 
--options menu
    ["Account Settings"] = "Настройки аккаунта",
    ["Low Threshold"] = "Порог квестовых предметов",
    ["Low Quantity"] = "Низкое количество (квестовые предметы)",
    ["Auto-save position"] = "Авто сохранение позиции",
    ["Use Icons"] = "Использовать иконки",
    ["Low Stock Warn"] = "Предупреждать о малом кол-ве материалов",
    ["Show Marker After Daily Reset"] = "Показывать маркер после сброса ежедн. зад.",
    ["Show Marker For Riding Training"] = "Показывать маркер для тренировки по езде",
    ["Track Alts Data"] = "Больше данных для персонажей",
    ["Preserve Icon in UI mode"] = "Показывать значок док-станции",
    ["Keep Visible On Warnings"] = "Оставайтесь видимыми при предупреждениях",
    ["Separate Backpack Quantity"] = "Разделять отображение рюкзака",
    ["Show in HUD Only"] = "Показывать только на главном экране",
    ["Character Settings"] = "Настройки персонажа",
    ["Show Stock"] = "Показывать материалы",
    ["Show Raw Stock"] = "Показывать сырье",
    ["Show Surveys"] = "Показывать карты",
    ["Show Inventory Space"] = "Показывать свободное место в рюкзаке",
    ["Always Visible"] = "Видно всегда",
    ["Appearance"] = "Внешний вид",
    ["Single Row Display"] = "Показывать в одну строку",
    ["Align To Bar Center"] = "Выровнять по середине панели",
    ["UI Scale"] = "Размер",
    ["Background Style"] = "Стиль фона",
    ["Share Appearance"] = "Одинаковый внешний вид для всех персонажей",
    ["Low Mat Threshold"] = "Пороговое значение материалов",
    ["Own Low Stock"] = "Собственное низкое значение",
    ["Find Item"] = "Найти",
    ["Search Results"] = "Результаты поиска",
    ["Low Stock"] = "Низкое количество",
    ["High Stock"] = "Высокое количество",
    ["Add Item"] = "Добавить",
    ["Custom Materials"] =  "Пользовательские материалы",
    ["Custom Materials (All Characters)"] = "Пользовательские материалы (Все перс.)",
    ["Item"] = "Предмет",
    ["Custom Materials Help"] = 
            "Найдите предметы ниже или используйте команду 'ссылка в чат', чтобы вставить ссылку на предмет в чат, а затем скопируйте ссылку сюда " ..
            "Вы также можете использовать числовой идентификатор предмета или свой собственный текст. Чтобы удалить предмет, просто очистите текстовое поле."
            ,
    ["Survey Statistics"] =  "Статистика карт",
    ["Survey Statistics Help"] = 
            "Определите свою собственную статистику карт, используя цифры ниже в любом порядке\n" ..
            "0 - Все карты, 1 - Лучшие по локации, 2 - 2 Лучшие, 3 - 3 Лучшие, " ..
            "4 - Лучшие в Краглорне, 5 - Карты в рюкзаке, 6 - Всего в Краглорне\n"..
            "Пример: напечатайте 50 чтобы видеть только рюкзак и общее количество"
            ,
    ["Display Pattern"] =  "Шаблон",
}
