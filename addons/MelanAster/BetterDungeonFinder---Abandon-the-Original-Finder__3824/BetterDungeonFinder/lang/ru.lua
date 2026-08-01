local BAF = BetterDungonFinder
--[[
For translation, you have to copy this file and rename it in xx.lua, and translated the strings below. 
you can get the xx for your language by typing following line in game chat
/script d(GetCVar("language.2"))
]]
 
--[[
If the font size of dungeon in your language is ok, let it empty.
you can set it with my pre-made settings.
"BAFWinH3"  20KB size
"BAFWinH4"  18KB size default setting
"BAFWinH5"  15KB size
 
Or you can define your own font.
Take a look at [url]https://wiki.esoui.com/Fonts[/url]
 
For example:
local MyFont = string.format(
      "$(%s)|$(KB_%s)|%s",    --you don't need to understand this
      fontStyle,              --like "MEDIUM_FONT" (it's more complex to use other fonts not provided by eso)
      fontSize,               --like 12
      fontWeight              --like "soft-shadow-thin"
    )
BAFFontSize = MyFont
]]
 
BAFFontSize = ""
 
--String Used in addon. Contributed by Lost.Seeker
BAFLang_SI = {
  FirstTime = "[BetterDungeonFinder] Первая загрузка\r\n- Используйте Enter чтобы вызвать курсор для переноса |t30:30:esoui/art/lfg/lfg_indexicon_dungeon_up.dds|t\r\n- Назначте кнопку для BDF в настройках (Опционально)\r\n- Дополнительные опции в меню настроек BDF",
  
  TITLE = "Better Dungeon Finder",
  TITLE_BaseDungeon = "Подземелья",
  TITLE_DLCDungeon = "DLC Подземелья",
  TITLE_Undauted = "Неустрашимые", 
  
  Caption_SK = "|c808080Очки навыков|r",
  Caption_HM = "|c808080Хард мод|r",
  Caption_SR = "|c808080На время|r",
  Caption_ND = "|c808080Без смертей|r",
  Caption_TR = "|c808080Трифекта|r",
  
  BUTTON_Empty = "|cFF0000Очистить|r",
  BUTTON_Empty_Clear = "Очистить (0)",
  
  BUTTON_N_Info = "|cFFD700"..GetString(SI_DUNGEONDIFFICULTY1).."|r\r\n(ЛКМ) Выбрать\r\n(ПКМ) Перемещение",
  BUTTON_V_Info = "|cFFD700"..GetString(SI_DUNGEONDIFFICULTY2).."|r\r\n(ЛКМ) Выбрать\r\n(ПКМ) Перемещение",
  BUTTON_Sky_Info = "(Двойное нажатие) Выбрать ВСЕ не полученные",
  
  BUTTON_Queue_Status_Queue = "|c32CD32Поиск!|r",
  BUTTON_Queue_Status_Cancel = "|cFF0000Отмена|r",
  BUTTON_Queue_Status_Ready = "|cFFFF00Готовы?|r",
  BUTTON_Queue_Status_Fight = "Сражение",
  BUTTON_BG_Tooltip = "(ЛКМ) 4на4   (ПКМ) 8на8",
  
  DIALOG_TITLE = "[BDF] Сохранить список Подземелий",
  DIALOG_TEXT = "Введите новое имя для списка",
  
  SETTING_Finder_Lock = "Заблокировать",
  SETTING_Finder_Lock_Info = "Заблокировать перемещение окна BDF",
  SETTING_Finder_Pure = "Черный фон",
  SETTING_Finder_Pure_Info = "Отключить полупрозрачность фона",
  SETTING_Finder_Title = "Названия слева",
  SETTING_Finder_Title_Info = "Откл. для отображения по центру",
  SETTING_Finder_TitleV = "Смещение названий",
  SETTING_Finder_Alpha_Low = "Фон не активных",
  SETTING_Finder_Alpha_High = "Фон активных",
  SETTING_Finder_Alpha_Tooltip = "No - 0 ~ 1 - Full",
  SETTING_Coffer_Helper = "Undaunted Coffer Helper", --New
  SETTING_Coffer_Helper_Tooltip = "Add the Collection Status of Shoulders to the Coffer Information in Shop", --New
  SETTING_Hide_Shoudler_Count = "Hide the Collection of Monster Set Shoulders", --New
  SETTING_Hide_Shoudler_Count_Tooltip = "When Enabled, Equipment Collection Statistics will not Include Monster Set Shoulders", --New
  
  SETTING_Trigger_Header = "Иконка аддона",
  SETTING_Trigger_Lock = "Заблокировать",
  SETTING_Trigger_Lock_Info = "Заблокировать перемещение иконки на экране",
  SETTING_Trigger_Hide = "Скрыть",
  SETTING_Trigger_Hide_Info = "Скрыть отображение иконки на экране",
  
  SETTING_Other_Header = "Другие опции",
  SETTING_Other_AutoUDQ = "Автоматизация Неустрашимых",
  SETTING_Other_AutoUDQ_Info = "Автоматически брать и сдавать задания Неустрашимых при взаимодействии с НПС",
  SETTING_Other_AutoUDQ_Delay = "Задержка взаимодействия (ms)",
  SETTING_Other_AutoSwitchQuest = "Переключить на Неустрашимых",
  SETTING_Other_AutoSwitchQuest_Info = "Автоматически переключать на отслеживание Неустрашимых в подземелье",
  SETTING_Other_DoubleCQTE = "Напомнить про задание!",
  SETTING_Other_DoubleCQTE_Info = "При наличии задания `очков навыка` в подземелье для выхода потребуется дополнительное подтверждение",
  DIALOG_DoubelCQTE_MT = "Обнаружено не выполненое |cFFD700задание очков навыка|r (<<1>>). Подтвердить выход?",
  
  SETTING_Other_MarkChests = "Возможные места сундуков (OdySI)",
  SETTING_Other_MarkChests_Info = "Записывать и отображать места сундуков в подземелье, которые вы открывали (Требуется OdySupportIcons)",
  SETTING_Other_ShareChests = "Делиться местами сундуков",
  SETTING_Other_ShareChests_Info = "Во время первого раза `вне боя`, попробовать поделиться возможными местами сундоков с группой \r\nТребуется наличие BDF, OdySupportIcons и LibGroupBroadcast",
  
  SETTING_Other_AutoConfirm = "Автоподтверждение за x секунд",
  SETTING_Other_BGSound = "Разрешение звукового оповещения",
  SETTING_Other_BGSound_Info = "Временное разрешение фонового звукового оповещения, пока идет отсчет подтверждения",
  
  SETTING_Sort_Header = "Настройка сортировки",
  SETTING_Sort_Header_Des = "Change the Relative Positions of Dungeons in the Interface. By default, They are Arranged by Unlock Level or Release Date", --New
  SETTING_Sort_AZ_Info = "Алфавитное, так-же как оригинал",
  
  KEYBIND = "Open/Close BDF",
  
  WARNING_ChangRole = "[BDF] Попробуйте позже.",
  WARNING_NoSelect = "[BDF] Нет выбранных подземелий.",
  WARNING_Difficulty = "[BDF] Сейчас нельзя сменить сложность.",
  WARNING_ReloadUI = "Требуется перезагрузка интерфейса.",
  
  MESSAGE_AddChestMark = "[BDF] Добавлено место появления сундука",
  MESSAGE_ReceivedChest = "[BDF] Получены <<1>> места появления сундуков от <<2>>"
}
--Waring: Every line in BAFLang_SI should be ended with ,