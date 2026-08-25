CombatFPSBooster = CombatFPSBooster or {}
CombatFPSBooster.L = CombatFPSBooster.L or {}

local function IsJapanese()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then lang = GetCVar("Language.lang") end
    if (not lang or lang == "") and GetLanguage then lang = GetLanguage() end
    if lang then
        lang = string.lower(lang)
        return lang == "ja" or string.sub(lang, 1, 2) == "ja"
    end
    return false
end

if IsJapanese() then
    CombatFPSBooster.L.TITLE          = "Tetsu's Combat FPS Booster"
    CombatFPSBooster.L.HIDE_COMPASS   = "戦闘中にコンパスを非表示"
    CombatFPSBooster.L.HIDE_COMPASS_TT= "戦闘中に上部コンパスを完全に非表示にしてCPU負荷を軽減します。"
    CombatFPSBooster.L.HIDE_QUESTS    = "戦闘中にクエストを非表示"
    CombatFPSBooster.L.HIDE_QUESTS_TT = "戦闘中に画面右側のクエスト追跡を非表示にします。"
    CombatFPSBooster.L.HIDE_ALERTS    = "戦闘中に通知を非表示"
    CombatFPSBooster.L.HIDE_ALERTS_TT = "戦闘中に中央の経験値・ゴールド・戦利品通知を非表示にします。"
end