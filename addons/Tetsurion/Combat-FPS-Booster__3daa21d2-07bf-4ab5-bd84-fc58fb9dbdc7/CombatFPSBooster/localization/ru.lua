CombatFPSBooster = CombatFPSBooster or {}
local L = CombatFPSBooster.L or {}

local clientLang = GetCVar("Language.lang")
if clientLang == "ru" then
    L.TITLE           = "Combat FPS Booster"
    L.HIDE_COMPASS    = "Скрывать компас в бою"
    L.HIDE_COMPASS_TT = "Полностью отключает верхнюю полоску компаса во время боя. Снимает тригонометрическую нагрузку с процессора."
    L.HIDE_QUESTS     = "Скрывать трекер квестов в бою"
    L.HIDE_QUESTS_TT  = "Прячет список активных заданий в правой части экрана во время боя."
    L.HIDE_ALERTS     = "Скрывать оповещения опыта и золота в бою"
    L.HIDE_ALERTS_TT  = "Скрывает всплывающие оповещения (получение опыта, золота, лута) в бою, убирая просадки кадров при быстром убийстве мобов."
end

CombatFPSBooster.L = L