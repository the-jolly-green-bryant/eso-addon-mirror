-- -----------------------------------------------------------------------------
-- Lang/ru.lua
-- -----------------------------------------------------------------------------
local strings = {
    SKILLBLOCKER_NJ_UNLOCK_ALL                         = "Разблокировать все",
    SKILLBLOCKER_NJ_UNLOCKED                           = "Разблокировано",
    SKILLBLOCKER_NJ_LOCKED                             = "Заблокировано",
    SKILLBLOCKER_NJ_LOCKED_COMBAT                      = "Заблокирован в бою",
    SKILLBLOCKER_NJ_LOCKED_ACTIVE                      = "Заблокирован пока активен",
    SKILLBLOCKER_NJ_LOADED                             = "Успешно загружен",
    SKILLBLOCKER_NJ_LOCKED_WEREWOLF                    = "Заблокирован в форме вервольфа",

    SKILLBLOCKER_NJ_BLOCK_SETTINGS                     = "Настройка блокировки",
    SKILLBLOCKER_NJ_BLOCK_STACKS                       = "Блокировать если стаков <",
    SKILLBLOCKER_NJ_BLOCK_CRUX                         = "Блокировать если круксов <",
    SKILLBLOCKER_NJ_BLOCK_REVERSE                      = "Блокировать если круксов ≥",
    SKILLBLOCKER_NJ_BLOCK_PROC                         = "Блокировать до <<1>> прока",
    SKILLBLOCKER_NJ_BLOCK_HP                           = "Блокировать если HP цели >",
    SKILLBLOCKER_NJ_BLOCK_ULTIMATE                     = "Блокировать если < <<1>> очков",
    SKILLBLOCKER_NJ_BLOCK_DURATION                     = "Блокировать на <<1>> сек",
    SKILLBLOCKER_NJ_BLOCK_DEBUFF                       = "Блокировать до <<1>> взрыва",

    SKILLBLOCKER_NJ_GENERAL_SETTINGS                   = "Общие настройки",
    SKILLBLOCKER_NJ_REMEMBER                           = "Запоминать заблокированные навыки?",
    SKILLBLOCKER_NJ_SHOW_ALERT                         = "Показывать предупреждение",
    SKILLBLOCKER_NJ_ALERT_TOOLTIP                      = "Показывать системное предупреждение при попытке использовать заблокированный навык",

    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_SETTINGS         = "Настройка защиты от двойного прожатия",
    SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA               = "Сброс защиты после ЛА",
    SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA_TOOLTIP       = "Если включено, легкая атака (ЛКМ) мгновенно снимает блокировку и позволяет снова прожать умение.",
    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION         = "Длительность защиты",
    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION_TOOLTIP = "Время в секундах, в течение которого кнопка будет неактивна после нажатия (0 = ∞).",

    SKILLBLOCKER_NJ_MENU_ACTIVE_BLOCKS_TITLE           = "Мой список заблокированных навыков:",
    SKILLBLOCKER_NJ_MAIN_BAR                           = "Передняя панель:",
    SKILLBLOCKER_NJ_BACK_BAR                           = "Задняя панель:",

    SKILLBLOCKER_NJ_ACTION_ENABLE                      = "Включить",
    SKILLBLOCKER_NJ_ACTION_DISABLE                     = "Отключить",

    SKILLBLOCKER_NJ_MENU_DOUBLE_CAST_TITLE             = "Блокировка двойного прожатия",
    SKILLBLOCKER_NJ_MENU_STACK_TITLE                   = "Блокировка по стакам",
    SKILLBLOCKER_NJ_MENU_CRUX_TITLE                    = "Блокировка по круксам",
    SKILLBLOCKER_NJ_MENU_PROC_TITLE                    = "Блокировка по прокам скилла",
    SKILLBLOCKER_NJ_MENU_DEBUFF_TITLE                  = "Блокировка по «взрывам» скилла",
    SKILLBLOCKER_NJ_MENU_ULTIMATE_TITLE                = "Блокировка по очкам ультимейта",
    SKILLBLOCKER_NJ_MENU_DURATION_TITLE                = "Блокировка по длительности",
    SKILLBLOCKER_NJ_MENU_HP_TITLE                      = "Блокировка по здоровью цели",
    SKILLBLOCKER_NJ_MENU_CRIMINAL_TITLE                = "Блокировка «Преступление»",

    SKILLBLOCKER_NJ_DELETE_FROM_SLOT                   = "Удалить из слота",

    SI_BINDING_NAME_SKILLBLOCKER_NJ_UNLOCK_ALL         = "Разблокировать все навыки",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_1      = "Перекл. блок: Слот 1",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_2      = "Перекл. блок: Слот 2",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_3      = "Перекл. блок: Слот 3",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_4      = "Перекл. блок: Слот 4",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_5      = "Перекл. блок: Слот 5",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_6      = "Перекл. блок: Ульта",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end