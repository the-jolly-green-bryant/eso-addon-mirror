-- Russian Localization Strings for TorigaHUD
local strings = {
    BINDING_NAME_TORIGAHUD_TOGGLE_DRAG = "Блокировка/разблокировка позиций HUD",
    
    TORIGAHUD_SETTINGS_DISPLAY_NAME = "Настройки |cFFD700TorigaHUD|r",
    TORIGAHUD_SETTINGS_GENERAL_HEADER = "Основные настройки",
    TORIGAHUD_SETTINGS_HIDE_OOC = "Скрывать вне боя",
    TORIGAHUD_SETTINGS_HIDE_OOC_TT = "Если включено, скрывает панели ресурсов вне боя и при отсутствии активной цели.",
    TORIGAHUD_SETTINGS_SHOW_SHIELDS = "Показывать щит",
    TORIGAHUD_SETTINGS_SHOW_SHIELDS_TT = "Если включено, отображает полупрозрачную синюю полосу поверх здоровья для индикации активных щитов.",
    TORIGAHUD_SETTINGS_LERP_SPEED = "Скорость анимации панелей",
    TORIGAHUD_SETTINGS_LERP_SPEED_TT = "Регулирует плавность движения полос ресурсов. (1.00 = мгновенное обновление, без анимации)",
    TORIGAHUD_SETTINGS_SEGMENT_SIZE = "Значение одного сегмента",
    TORIGAHUD_SETTINGS_SEGMENT_SIZE_TT = "Задает количество очков ресурса на один блок панели (здоровье, магия, запас сил, цель). Например, 2000 означает 2000 очков за блок.",
    TORIGAHUD_SETTINGS_SCALE = "Масштаб HUD",
    TORIGAHUD_SETTINGS_SCALE_TT = "Регулирует общий размер всех элементов интерфейса.",
    TORIGAHUD_SETTINGS_PRESETS_HEADER = "Шаблоны и позиционирование",
    TORIGAHUD_SETTINGS_PRESET = "Шаблоны разметки",
    TORIGAHUD_SETTINGS_PRESET_TT = "Выберите готовый шаблон для быстрого изменения расположения элементов.",
    TORIGAHUD_SETTINGS_PRESET_VERTICAL = "Боевой фокус (Вертикально)",
    TORIGAHUD_SETTINGS_PRESET_HORIZONTAL = "Боевой фокус (Горизонтально)",
    TORIGAHUD_SETTINGS_PRESET_MINIMALIST = "Минимализм (Компактно)",
    TORIGAHUD_SETTINGS_UNLOCK = "Разблокировать HUD",
    TORIGAHUD_SETTINGS_UNLOCK_TT = "Позволяет перетаскивать панели мышью. Закроет меню настроек и выведет диалоговое окно подтверждения.",
    TORIGAHUD_SETTINGS_RESET = "Сбросить позиции",
    TORIGAHUD_SETTINGS_RESET_TT = "Возвращает все панели HUD в исходное положение.",
    
    TORIGAHUD_DRAG_XP = "ОПЫТ",
    TORIGAHUD_DRAG_TARGET = "ЦЕЛЬ",
    
    TORIGAHUD_DIALOG_TITLE = "ПЕРЕТАЩИТЕ ПАНЕЛИ В НУЖНОЕ МЕСТО",
    TORIGAHUD_DIALOG_APPLY = "ПРИМЕНИТЬ",
    TORIGAHUD_DIALOG_CANCEL = "ОТМЕНА",
    
    TORIGAHUD_TEXT_HEALTH = "ЗДОРОВЬЕ",
    TORIGAHUD_TEXT_LEVEL = "УРОВЕНЬ",
    TORIGAHUD_TEXT_XP = "ОПЫТ",
    TORIGAHUD_TEXT_MAGICKA = "МАГИЯ",
    TORIGAHUD_TEXT_STAMINA = "ЗАПАС СИЛ",
    TORIGAHUD_TEXT_TARGET_TEST = "ТЕСТОВАЯ МИШЕНЬ",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId("SI_" .. stringId, stringValue)
end
