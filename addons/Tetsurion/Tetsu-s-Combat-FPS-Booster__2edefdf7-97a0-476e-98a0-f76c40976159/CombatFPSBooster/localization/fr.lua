CombatFPSBooster = CombatFPSBooster or {}
CombatFPSBooster.L = CombatFPSBooster.L or {}

local function IsFrench()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then lang = GetCVar("Language.lang") end
    if (not lang or lang == "") and GetLanguage then lang = GetLanguage() end
    if lang then
        lang = string.lower(lang)
        return lang == "fr" or string.sub(lang, 1, 2) == "fr"
    end
    return false
end

if IsFrench() then
    CombatFPSBooster.L.TITLE          = "Tetsu's Combat FPS Booster"
    CombatFPSBooster.L.HIDE_COMPASS   = "Masquer le compas en combat"
    CombatFPSBooster.L.HIDE_COMPASS_TT= "Masque complètement le compas pendant le combat."
    CombatFPSBooster.L.HIDE_QUESTS    = "Masquer les quêtes en combat"
    CombatFPSBooster.L.HIDE_QUESTS_TT = "Masque le suivi des quêtes pendant le combat."
    CombatFPSBooster.L.HIDE_ALERTS    = "Masquer les alertes en combat"
    CombatFPSBooster.L.HIDE_ALERTS_TT = "Masque les alertes d'or/XP et de butin pendant le combat."
end