HousingFPSBooster = HousingFPSBooster or {}
HousingFPSBooster.L = HousingFPSBooster.L or {}

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
    HousingFPSBooster.L.TITLE                = "Tetsu's Housing FPS Booster"
    HousingFPSBooster.L.ENABLE_BOOSTER       = "Activer le booster de maison"
    HousingFPSBooster.L.ENABLE_BOOSTER_TT    = "Optimise l'interface, le compas et les barres dans les maisons pour améliorer les FPS."
    HousingFPSBooster.L.HIDE_COMBAT_BARS     = "Masquer barres d'action et attributs"
    HousingFPSBooster.L.HIDE_COMBAT_BARS_TT  = "Masque les barres de compétences et de ressources hors combat dans les maisons."
end