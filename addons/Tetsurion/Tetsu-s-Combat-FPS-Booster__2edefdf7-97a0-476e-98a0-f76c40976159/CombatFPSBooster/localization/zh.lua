CombatFPSBooster = CombatFPSBooster or {}
CombatFPSBooster.L = CombatFPSBooster.L or {}

local function IsChinese()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then lang = GetCVar("Language.lang") end
    if (not lang or lang == "") and GetLanguage then lang = GetLanguage() end
    if lang then
        lang = string.lower(lang)
        return lang == "zh" or string.sub(lang, 1, 2) == "zh"
    end
    return false
end

if IsChinese() then
    CombatFPSBooster.L.TITLE          = "Tetsu's Combat FPS Booster"
    CombatFPSBooster.L.HIDE_COMPASS   = "战斗中隐藏罗盘"
    CombatFPSBooster.L.HIDE_COMPASS_TT= "在战斗中完全隐藏顶部罗盘，以减轻 CPU 负担。"
    CombatFPSBooster.L.HIDE_QUESTS    = "战斗中隐藏任务追踪"
    CombatFPSBooster.L.HIDE_QUESTS_TT = "在战斗中隐藏右侧的任务列表。"
    CombatFPSBooster.L.HIDE_ALERTS    = "战斗中隐藏经验/金币提示"
    CombatFPSBooster.L.HIDE_ALERTS_TT = "在战斗中隐藏屏幕中央的经验、金币与拾取提示。"
end