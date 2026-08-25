CombatFPSBooster = CombatFPSBooster or {}
CombatFPSBooster.L = CombatFPSBooster.L or {}

local function IsGerman()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then lang = GetCVar("Language.lang") end
    if (not lang or lang == "") and GetLanguage then lang = GetLanguage() end
    if lang then
        lang = string.lower(lang)
        return lang == "de" or string.sub(lang, 1, 2) == "de"
    end
    return false
end

if IsGerman() then
    CombatFPSBooster.L.TITLE          = "Tetsu's Combat FPS Booster"
    CombatFPSBooster.L.HIDE_COMPASS   = "Kompass im Kampf ausblenden"
    CombatFPSBooster.L.HIDE_COMPASS_TT= "Blendet den Kompass im Kampf vollständig aus, um die CPU zu entlasten."
    CombatFPSBooster.L.HIDE_QUESTS    = "Quest-Tracker im Kampf ausblenden"
    CombatFPSBooster.L.HIDE_QUESTS_TT = "Blendet aktive Quests während des Kampfes aus."
    CombatFPSBooster.L.HIDE_ALERTS    = "Benachrichtigungen im Kampf ausblenden"
    CombatFPSBooster.L.HIDE_ALERTS_TT = "Blendet XP-/Gold- und Beutemeldungen im Kampf aus."
end