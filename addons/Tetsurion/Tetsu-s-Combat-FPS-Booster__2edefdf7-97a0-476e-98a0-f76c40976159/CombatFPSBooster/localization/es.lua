CombatFPSBooster = CombatFPSBooster or {}
CombatFPSBooster.L = CombatFPSBooster.L or {}

local function IsSpanish()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then lang = GetCVar("Language.lang") end
    if (not lang or lang == "") and GetLanguage then lang = GetLanguage() end
    if lang then
        lang = string.lower(lang)
        return lang == "es" or string.sub(lang, 1, 2) == "es"
    end
    return false
end

if IsSpanish() then
    CombatFPSBooster.L.TITLE          = "Tetsu's Combat FPS Booster"
    CombatFPSBooster.L.HIDE_COMPASS   = "Ocultar brújula en combate"
    CombatFPSBooster.L.HIDE_COMPASS_TT= "Oculta la brújula durante el combate para mejorar el rendimiento."
    CombatFPSBooster.L.HIDE_QUESTS    = "Ocultar misiones en combate"
    CombatFPSBooster.L.HIDE_QUESTS_TT = "Oculta el rastreador de misiones durante el combate."
    CombatFPSBooster.L.HIDE_ALERTS    = "Ocultar alertas en combate"
    CombatFPSBooster.L.HIDE_ALERTS_TT = "Oculta notificaciones de XP, oro y botín durante el combate."
end