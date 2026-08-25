HousingFPSBooster = HousingFPSBooster or {}
HousingFPSBooster.L = HousingFPSBooster.L or {}

local function IsRussian()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then lang = GetCVar("Language.lang") end
    if (not lang or lang == "") and GetLanguage then lang = GetLanguage() end
    if lang then
        lang = string.lower(lang)
        return lang == "ru" or string.sub(lang, 1, 2) == "ru"
    end
    return false
end

if IsRussian() then
    HousingFPSBooster.L.TITLE                = "Tetsu's Housing FPS Booster"
    HousingFPSBooster.L.ENABLE_BOOSTER       = "Включить бустер жилья"
    HousingFPSBooster.L.ENABLE_BOOSTER_TT    = "Оптимизирует интерфейс, скрывает компас, квесты и боевые панели в домах для максимального FPS."
    HousingFPSBooster.L.HIDE_COMBAT_BARS     = "Скрывать скиллы и ресурсы"
    HousingFPSBooster.L.HIDE_COMBAT_BARS_TT  = "Скрывает полоски способностей и ресурсов (здоровье, магия, выносливость) в доме вне боя. В бою на манекене панели возвращаются."
end