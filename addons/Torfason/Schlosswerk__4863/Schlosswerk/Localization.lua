local SW = Schlosswerk

function SW:GetEffectiveLanguage()
    local gameLanguage = "en"
    if GetCVar then
        gameLanguage = string.lower(GetCVar("language.2") or "en")
    end

    if self.LocalizationData and self.LocalizationData[gameLanguage] then
        return gameLanguage
    end

    return "en"
end

function SW:L(key)
    local language = self:GetEffectiveLanguage()
    local languageTable = self.LocalizationData and self.LocalizationData[language]
    local englishTable = self.LocalizationData and self.LocalizationData.en

    if languageTable and languageTable[key] ~= nil then
        return languageTable[key]
    end
    if englishTable and englishTable[key] ~= nil then
        return englishTable[key]
    end
    return key
end
