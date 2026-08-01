local addon = SquirrelSlayer

-- Mots-clés par langue pour détecter les écureuils dans les noms d'unités.
local SQUIRREL_NAMES = {
    fr = { "ecureuil" },
    en = { "squirrel" },
    de = { "eichhornchen" },
    es = { "ardilla" },
    ru = { "белка" },
    zh = { "松鼠" },
}

--- Normalise un texte (minuscules, retrait accents principaux).
--- @param sourceText string
--- @return string normalizedText
local function NormalizeString(sourceText)
    if type(sourceText) ~= "string" or sourceText == "" then return "" end

    local normalizedText = sourceText:match("([^%^]+)") or sourceText
    normalizedText = zo_strlower(normalizedText)
    normalizedText = normalizedText
        :gsub("à", "a"):gsub("á", "a"):gsub("â", "a"):gsub("ä", "a"):gsub("ã", "a"):gsub("å", "a")
        :gsub("ç", "c")
        :gsub("è", "e"):gsub("é", "e"):gsub("ê", "e"):gsub("ë", "e")
        :gsub("ì", "i"):gsub("í", "i"):gsub("î", "i"):gsub("ï", "i")
        :gsub("ñ", "n")
        :gsub("ò", "o"):gsub("ó", "o"):gsub("ô", "o"):gsub("ö", "o"):gsub("õ", "o")
        :gsub("ù", "u"):gsub("ú", "u"):gsub("û", "u"):gsub("ü", "u")
        :gsub("ý", "y"):gsub("ÿ", "y")
        :gsub("œ", "oe"):gsub("æ", "ae")
        :gsub("ß", "ss")
    return normalizedText
end

--- Vérifie si un nom d'unité correspond à un écureuil.
--- @param unitName string
--- @return boolean
local function IsSquirrelName(unitName)
    if not unitName or unitName == "" then return false end

    local cleanedUnitName = NormalizeString(unitName)
    for _, localizedKeywords in pairs(SQUIRREL_NAMES) do
        for _, keyword in ipairs(localizedKeywords) do
            if cleanedUnitName:find(keyword, 1, true) then return true end
        end
    end
    return false
end

--- Nettoie un nom pour comparaison (retire suffixes et met en minuscules).
--- @param sourceName string
--- @return string
local function CleanName(sourceName)
    if not sourceName then return "" end
    return zo_strlower((sourceName:match("([^%^]+)") or sourceName))
end

addon.Internal.IsSquirrelName = IsSquirrelName
addon.Internal.CleanName = CleanName
