HousingFPSBooster = HousingFPSBooster or {}
HousingFPSBooster.L = HousingFPSBooster.L or {}

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
    HousingFPSBooster.L.TITLE                = "Tetsu's Housing FPS Booster"
    HousingFPSBooster.L.ENABLE_BOOSTER       = "Activar optimizador de casas"
    HousingFPSBooster.L.ENABLE_BOOSTER_TT    = "Optimiza la interfaz, la brújula y las barras en casas para mejorar los FPS."
    HousingFPSBooster.L.HIDE_COMBAT_BARS     = "Ocultar barras de acción y atributos"
    HousingFPSBooster.L.HIDE_COMBAT_BARS_TT  = "Oculta las barras de habilidades y recursos fuera de combate en las casas."
end