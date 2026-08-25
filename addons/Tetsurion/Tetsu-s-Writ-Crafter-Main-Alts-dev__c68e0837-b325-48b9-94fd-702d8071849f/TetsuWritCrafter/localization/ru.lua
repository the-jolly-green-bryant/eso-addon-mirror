TetsuWritCrafter = TetsuWritCrafter or {}

local function IsRussian()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then lang = GetCVar("Language.lang") end
    if (not lang or lang == "") and GetLanguage then lang = GetLanguage() end
    if lang then
        lang = string.lower(lang)
        return lang == "ru" or string.sub(lang, 1, 2) == "ru"
    end
    return false
end

if IsRussian() then
    local L = TetsuWritCrafter.L
    L.TITLE                   = "|cFFD700Tetsu's|r Writ Crafter"
    L.ALTS_SECTION_LABEL      = "Персонажи для дейликов"
    L.ALTS_SECTION_TT         = "Включите или отключите персонажей для автокрафта."
    L.CHAR_ENABLED_TT         = "Включить предварительный крафт для <<1>>."
    
    L.KEYBIND_CRAFT_ALL       = "|c00FF00[R3]|r Скрафтить на всех (<<1>> шт.)"
    L.CONFIRM_TITLE           = "Массовый крафт заказов"
    L.CONFIRM_PROMPT          = "Изготовить <<1>> предм. для всех активных персонажей?"
    
    L.PROGRESS_CRAFTING       = "Крафт дейлик-предметов..."
    L.PROGRESS_BANK_DEPOSIT   = "Банк: Выгрузка вещей и наград..."
    L.PROGRESS_BANK_WITHDRAW  = "Банк: Забор нужных вещей..."
    L.PROGRESS_STATUS         = "Обработано: <<1>> из <<2>>"
    
    L.ERR_NOT_ENOUGH_BANK     = "Недостаточно места в банке! Нужно: <<1>>, Свободно: <<2>>."
    L.ERR_BAG_FULL            = "Недостаточно места в рюкзаке! Нужно: <<1>>, Свободно: <<2>>."
    L.ERR_NOT_ENOUGH_MATS     = "Недостаточно материалов для крафта!"
    
    L.SYNC_STATUS             = "Синхронизировано: |c00FF00<<1>> из <<2>>|r. Требуется зайти на: |cFFFF00<<3>>|r"
    L.READY_BRIEFING          = "Готов к работе! Шаблон: |cFFD700<<1>>|r. Активных твинков в очереди: |cFFD700<<2>>|r."
end