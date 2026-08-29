CombatFPSBooster = CombatFPSBooster or {}
CombatFPSBooster.L = CombatFPSBooster.L or {}

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
    CombatFPSBooster.L.TITLE          = "Tetsu's Combat FPS Booster"
    CombatFPSBooster.L.HIDE_COMPASS   = "Скрывать компас в бою"
    CombatFPSBooster.L.HIDE_COMPASS_TT= "Полностью отключает верхнюю полоску компаса во время боя. Снимает тригонометрическую нагрузку с процессора."
    CombatFPSBooster.L.HIDE_QUESTS    = "Скрывать трекер квестов в бою"
    CombatFPSBooster.L.HIDE_QUESTS_TT = "Прячет список активных заданий в правой части экрана во время боя."
    CombatFPSBooster.L.HIDE_ALERTS    = "Скрывать оповещения опыта и золота"
    CombatFPSBooster.L.HIDE_ALERTS_TT = "Скрывает всплывающие оповещения (получение опыта, золота, лута) в бою, убирая микрофризы."
    CombatFPSBooster.L.FILTER_MASTER    = "В данже только нужные аддоны"
    CombatFPSBooster.L.FILTER_MASTER_TT = "Если включено: при входе в групповой данж, триал, арену или Бесконечный архив аддон запоминает текущую раскладку, включает только отмеченные ниже аддоны и перезагружает UI. При выходе возвращает сохранённую раскладку. Логово и открытое подземелье не трогает. Библиотеки и сам бустер не выключает. Если ни один аддон не отмечен как нужный — ничего не меняет и пишет предупреждение в чат."
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
end