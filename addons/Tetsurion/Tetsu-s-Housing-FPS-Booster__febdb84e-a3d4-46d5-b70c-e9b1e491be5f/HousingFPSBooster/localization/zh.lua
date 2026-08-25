HousingFPSBooster = HousingFPSBooster or {}
HousingFPSBooster.L = HousingFPSBooster.L or {}

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
    HousingFPSBooster.L.TITLE                = "Tetsu's Housing FPS Booster"
    HousingFPSBooster.L.ENABLE_BOOSTER       = "启用住宅加速器"
    HousingFPSBooster.L.ENABLE_BOOSTER_TT    = "优化住宅内的后台UI、罗盘与动作条以提升帧率。"
    HousingFPSBooster.L.HIDE_COMBAT_BARS     = "隐藏动作条与属性栏"
    HousingFPSBooster.L.HIDE_COMBAT_BARS_TT  = "在住宅非战斗状态下隐藏技能与资源条（生命/魔法/耐力）。"
end