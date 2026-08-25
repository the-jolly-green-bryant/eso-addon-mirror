HousingFPSBooster = HousingFPSBooster or {}
HousingFPSBooster.L = HousingFPSBooster.L or {}

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
    HousingFPSBooster.L.TITLE                = "Tetsu's Housing FPS Booster"
    HousingFPSBooster.L.ENABLE_BOOSTER       = "Housing-Booster aktivieren"
    HousingFPSBooster.L.ENABLE_BOOSTER_TT    = "Optimiert Hintergrund-UI, Kompass und Leisten in Spielerhäusern für mehr FPS."
    HousingFPSBooster.L.HIDE_COMBAT_BARS     = "Aktionsleisten & Attribute ausblenden"
    HousingFPSBooster.L.HIDE_COMBAT_BARS_TT  = "Blendet Fähigkeiten- und Ressourcenleisten außerhalb des Kampfes in Häusern aus."
end