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
end