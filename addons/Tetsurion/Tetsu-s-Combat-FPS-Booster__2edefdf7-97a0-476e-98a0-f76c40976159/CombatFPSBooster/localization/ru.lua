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
    CombatFPSBooster.L.HIDE_INSTANCE_TT= "Если включено: компас и трекер квестов спрятаны между боями в зонах из списка ниже — и только если их галочки тоже включены. XP, золото, лут и CSA по-прежнему только в бою."

    CombatFPSBooster.L.WHOLE_WHERE       = "Где действует режим весь данж"
    CombatFPSBooster.L.WHOLE_WHERE_TT    = "Где компас и трекер квестов остаются спрятанными между боями, если их галочки тоже включены. XP, золото, лут и CSA по-прежнему только в бою. В Сиродиле этот режим компас не прячет."
    CombatFPSBooster.L.WHOLE_DUNGEON     = "Данжи и триалы"
    CombatFPSBooster.L.WHOLE_DUNGEON_TT  = "Групповые подземелья и испытания."
    CombatFPSBooster.L.WHOLE_ARENA       = "Арены"
    CombatFPSBooster.L.WHOLE_ARENA_TT    = "Водоворот, Драгонстар, Ватешран, Блэкроуз."
    CombatFPSBooster.L.WHOLE_ARCHIVE     = "Бесконечный архив"
    CombatFPSBooster.L.WHOLE_ARCHIVE_TT  = "Забеги Бесконечного архива."
    CombatFPSBooster.L.WHOLE_BG          = "Поля сражений"
    CombatFPSBooster.L.WHOLE_BG_TT       = "Матчи БГ. Пресеты аддонов здесь не меняются."
    CombatFPSBooster.L.WHOLE_CYRO        = "Сиродил и Имперский город"
    CombatFPSBooster.L.WHOLE_CYRO_TT     = "Война альянсов. Компас остаётся; между боями можно держать спрятанным только трекер квестов."
    CombatFPSBooster.L.PRESET_APPLY_PVP  = "Combat FPS Booster: в Сиродиле и на БГ пресет применить нельзя."
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
    CombatFPSBooster.L.FILTER_APPLY     = "Combat FPS Booster: включаю пресет аддонов "
    CombatFPSBooster.L.FILTER_APPLY_TAIL = ", перезагружаю UI."
    CombatFPSBooster.L.FILTER_RESTORE   = "Combat FPS Booster: возвращаю предыдущий набор аддонов, перезагружаю UI."
    CombatFPSBooster.L.FILTER_NOAPI     = "Combat FPS Booster: не удалось сменить набор аддонов. Повторной перезагрузки не будет."
    CombatFPSBooster.L.FILTER_COUNT     = "Аддонов в списке: "
    CombatFPSBooster.L.FILTER_COUNT_TT  = "Строка для проверки. Ниже — галочки по установленным аддонам. Библиотеки и этот бустер скрыты."
    CombatFPSBooster.L.FILTER_SECTION   = "Аддоны в данж"
    CombatFPSBooster.L.FILTER_SECTION_TT= "Какие установленные аддоны оставлять включёнными в данже или триале."
    CombatFPSBooster.L.FILTER_AUTO      = "Автосмена аддонов в данже"
    CombatFPSBooster.L.FILTER_AUTO_TT   = "Вкл: при входе в данж запоминается текущий набор, ставится выбранный пресет, при выходе набор возвращается. Выкл: ручной режим. Снимок мировых аддонов стирается — сначала сохраните пресет на мир, чтобы потом включить его кнопкой. «Применить» работает только при выключенной автосмене."
    CombatFPSBooster.L.FILTER_AUTO_OFF  = "Combat FPS Booster: ручные пресеты. Снимок мира очищен. Примените пресет из списка."
    CombatFPSBooster.L.PRESET_APPLY     = "Применить пресет"
    CombatFPSBooster.L.PRESET_APPLY_BTN = "Применить"
    CombatFPSBooster.L.PRESET_APPLY_TT  = "Включить выбранный пресет сейчас и перезагрузить UI. Только если автосмена выключена. Сначала сохраните пресет на мир, если потом нужно будет вернуться."
    CombatFPSBooster.L.PRESET_APPLY_NEED_MANUAL = "Combat FPS Booster: чтобы применить пресет вручную, выключите автосмену."
    CombatFPSBooster.L.PRESET_APPLY_COMBAT = "Combat FPS Booster: в бою пресет применить нельзя."
    CombatFPSBooster.L.PRESET_PREVIEW_HEAD = "Включены в этом пресете:"
    CombatFPSBooster.L.PRESET_PREVIEW_EMPTY = "(ни один аддон не отмечен)"
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
