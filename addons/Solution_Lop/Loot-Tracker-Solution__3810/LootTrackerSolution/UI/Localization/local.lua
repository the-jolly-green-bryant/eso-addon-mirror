LootTrackerSolution.Localization  = LootTrackerSolution.Localization or {}

local Localization = LootTrackerSolution.Localization

-- Switch case ingame language
function Localization.Initialize()
    local lang = GetCVar("language.2")
    if lang == "ru" then
        LocalizationLoadRu()
    elseif lang == "jp" then
        LocalizationLoadJp()
    elseif lang == "zh" then
        LocalizationLoadZh()
    elseif lang == "de" then
        LocalizationLoadDe()
    elseif lang == "fr" then
        LocalizationLoadFr()
    elseif lang == "kr" or lang == "kb" then
        LocalizationLoadKr()
    elseif lang == "es" or lang == "cs" then
        LocalizationLoadEs()
    elseif lang == "it" then
        LocalizationLoadIt()
    elseif lang == "br" or lang == "pt" then
        LocalizationLoadPt()
    elseif lang == "pl" then
        LocalizationLoadPl()
    elseif lang == "ua" or lang == "ut" then
        LocalizationLoadUa()
    elseif lang == "tr" or lang == "tb" then
        LocalizationLoadTr()
    else -- default en
        LocalizationLoadEn()
    end
end