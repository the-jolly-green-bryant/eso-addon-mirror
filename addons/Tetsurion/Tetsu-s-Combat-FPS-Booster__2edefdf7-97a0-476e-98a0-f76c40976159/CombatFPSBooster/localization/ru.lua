CombatFPSBooster = CombatFPSBooster or {}
CombatFPSBooster.L = CombatFPSBooster.L or {}

local function IsRussian()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then
        lang = GetCVar("Language.lang")
    end
    if (not lang or lang == "") and GetLanguage then
        lang = GetLanguage()
    end
    if lang then
        lang = string.lower(lang)
        return lang == "ru" or string.sub(lang, 1, 2) == "ru"
    end
    return false
end

if IsRussian() then
    CombatFPSBooster.L.TITLE          = "Tetsu's Combat FPS Booster"
    CombatFPSBooster.L.HIDE_INSTANCE   = "Скрывать HUD весь данж"
    CombatFPSBooster.L.HIDE_INSTANCE_TT= "Если включено: компас и трекер квестов спрятаны на весь групповой данж, триал, арену или Бесконечный архив. XP, золото, лут и игровые анонсы по-прежнему только в бою. Логово и открытое подземелье не трогает."
    CombatFPSBooster.L.HIDE_COMPASS   = "Скрывать компас в бою"
    CombatFPSBooster.L.HIDE_COMPASS_TT= "Полностью отключает верхнюю полоску компаса во время боя. Снимает тригонометрическую нагрузку с процессора."
    CombatFPSBooster.L.HIDE_QUESTS    = "Скрывать трекер квестов в бою"
    CombatFPSBooster.L.HIDE_QUESTS_TT = "Прячет список активных заданий в правой части экрана во время боя."
    CombatFPSBooster.L.HIDE_ALERTS    = "Скрывать XP и лут"
    CombatFPSBooster.L.HIDE_ALERTS_TT = "В бою прячет ленту лута на консоли, золото, тики XP и левую плашку прогресса. Режим «весь данж» их между боями не держит."
    CombatFPSBooster.L.HIDE_CSA       = "Скрывать игровые анонсы в бою"
    CombatFPSBooster.L.HIDE_CSA_TT    = "Прячет крупные сообщения по центру экрана только в бою. Режим «весь данж» на них не действует."
    CombatFPSBooster.L.FILTER_MASTER    = "В данже только нужные аддоны"
    CombatFPSBooster.L.FILTER_MASTER_TT = "Настройки фильтра свои у каждого персонажа. Если включено: при входе в групповой данж, триал, арену или Бесконечный архив аддон запоминает текущую раскладку, включает только отмеченные ниже аддоны и перезагружает UI. При выходе возвращает сохранённую раскладку. Логово и открытое подземелье не трогает. Библиотеки и сам бустер не выключает. Если ни один аддон не отмечен как нужный — ничего не меняет и пишет предупреждение в чат."
    CombatFPSBooster.L.FILTER_ITEM      = "В данже: "
    CombatFPSBooster.L.FILTER_ITEM_TT   = "Вкл = оставить/включить этот аддон в данже. Выкл = выключить его в данже. Пока опция выше выключена, изменения не применяются."
    CombatFPSBooster.L.FILTER_EMPTY_WARN= "Combat FPS Booster: фильтр данжа включён, но ни один аддон не отмечен как нужный. Ничего не изменено."
    CombatFPSBooster.L.FILTER_APPLY     = "Combat FPS Booster: включаю данжный набор аддонов, перезагружаю UI."
    CombatFPSBooster.L.FILTER_RESTORE   = "Combat FPS Booster: возвращаю мировой набор аддонов, перезагружаю UI."
    CombatFPSBooster.L.FILTER_NOAPI     = "Combat FPS Booster: не удалось сменить набор аддонов. Повторной перезагрузки не будет."
    CombatFPSBooster.L.FILTER_COUNT     = "Аддонов в списке: "
    CombatFPSBooster.L.FILTER_COUNT_TT  = "Строка для проверки. Ниже — галочки по установленным аддонам. Библиотеки и этот бустер скрыты."
    CombatFPSBooster.L.FILTER_SECTION   = "Аддоны в данж"
    CombatFPSBooster.L.FILTER_SECTION_TT= "Какие установленные аддоны оставлять включёнными в данже или триале."
    CombatFPSBooster.L.PRESET_SELECT    = "Пресет"
    CombatFPSBooster.L.PRESET_SELECT_TT = "Переключение сохранённых наборов аддонов. Список пресетов общий на аккаунт."
    CombatFPSBooster.L.PRESET_NAME      = "Имя пресета"
    CombatFPSBooster.L.PRESET_NAME_TT   = "Имя, под которым сохранить. То же имя перезапишет пресет."
    CombatFPSBooster.L.PRESET_SAVE      = "Сохранить пресет"
    CombatFPSBooster.L.PRESET_SAVE_BTN  = "Сохранить"
    CombatFPSBooster.L.PRESET_SAVE_TT   = "Записать текущие вкл/выкл в это имя. Снятые аддоны остаются в памяти пресета."
    CombatFPSBooster.L.PRESET_DELETE    = "Удалить пресет"
    CombatFPSBooster.L.PRESET_DELETE_BTN= "Удалить"
    CombatFPSBooster.L.PRESET_DELETE_TT = "Удалить выбранный пресет. Последний пресет удалить нельзя."
    CombatFPSBooster.L.PRESET_DIVIDER   = "──────── аддоны ────────"
    CombatFPSBooster.L.PRESET_SAVED     = "Combat FPS Booster: пресет сохранён: "
    CombatFPSBooster.L.PRESET_DELETED   = "Combat FPS Booster: пресет удалён: "
    CombatFPSBooster.L.PRESET_LAST      = "Combat FPS Booster: последний пресет удалить нельзя."
    CombatFPSBooster.L.PRESET_NOW       = "Combat FPS Booster: активный пресет: "
end
