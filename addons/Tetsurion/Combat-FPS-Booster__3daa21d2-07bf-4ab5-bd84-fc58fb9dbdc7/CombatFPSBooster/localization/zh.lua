CombatFPSBooster = CombatFPSBooster or {}
local L = CombatFPSBooster.L or {}

local clientLang = GetCVar("Language.lang")
if clientLang == "zh" then
    L.TITLE           = "Combat FPS Booster"
    L.HIDE_COMPASS    = "战斗中隐藏指南针"
    L.HIDE_COMPASS_TT = "在战斗中完全隐藏顶部指南针，以减轻 CPU 负担。"
    L.HIDE_QUESTS     = "战斗中隐藏任务追踪"
    L.HIDE_QUESTS_TT  = "在战斗中隐藏屏幕右侧的当前任务列表。"
    L.HIDE_ALERTS     = "战斗中隐藏经验/金币提示"
    L.HIDE_ALERTS_TT  = "在战斗中隐藏屏幕中心的经验、金币及拾取提示，减少群体战斗时的掉帧。"
end

CombatFPSBooster.L = L