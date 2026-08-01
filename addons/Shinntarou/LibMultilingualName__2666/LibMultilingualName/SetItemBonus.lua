LibMultilingualName = LibMultilingualName
local LIB = LibMultilingualName -- local name
local LMN = LIB -- Lib Multilingual Name

local initializationStage = 0

local debugMessage = ""

local function split(str, delim)
    if string.find(str, delim) == nil then
        return {str}
    end

    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local lastPos
    for part, pos in string.gfind(str, pat) do
        table.insert(result, part)
        lastPos = pos
    end
    table.insert(result, string.sub(str, lastPos))

    return result
end

local function escape_magic(s)
    s = tostring(s)
    return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1"))
end

local function str_replace(str, this, that)
    return str:gsub(regexEscape(this), that:gsub("%%", "%%%%")) -- only % needs to be escaped for 'that'
end

local function sanitize_description(s)
    s = string.gsub(s, "%|c%x%x%x%x%x%x([^%|]+)%|r", "%1")

    -- patterns that i must avoid in this replacement.
    --Pendant que l'élan est active, lancer des compétences à Vigueur en combat génère une charge de <<1>> pendant <<2>>, ce qui augmente vos dégâts physiques de <<3>> jusqu'à |cffffff5|r fois. Lorsque vous atteignez le nombre maximal de charges, votre attaque lourde suivante consomme toutes les charges et libère une violente explosion d'énergie autour de votre cible, qui inflige <<4>> à toutes les cibles dans les <<5>> mètres, les dégâts s'adaptant à vos dégâts magiques ou physiques, selon ce qui est le plus élevé.
    --5 objets Infliger des degats critiques vous confere une charge d Endurance du geant pendant 5 secondes jusqu a une fois par demi-seconde Chaque charge d Endurance du geant ajoute 40 degats physiques et se cumule jusqu a 10 fois Porter une attaque lourde entierement chargee supprime Endurance du geant et confere Force du geant pendant 15 secondes ce qui augmente vos degats physiques de 61 par charge supprimee Vous ne pouvez pas avoir Endurance et Force du geant en meme temps
    --[138012]="Infliger des dégâts critiques vous confère une charge de <<1>>, jusqu'à une fois par demi-seconde. Chaque charge de <<1>> ajoute <<2>> dégâts physiques, et se cumule jusqu'à |cffffff10|r fois.\r\n\r\nPorter une attaque lourde entièrement chargée supprime <<1>> et confère <<3>> pendant <<4>>, ce qui augmente vos dégâts physiques de <<5>> par charge supprimée.\r\n\r\nVous ne pouvez pas avoir Endurance et Force du géant en même temps.",
    -- orig:2 objets Pendant que l elan est active lancer des competences a Vigueur en combat genere une charge d Elan frenetique pendant 20 secondes ce qui augmente vos degats physiques de 38 jusqu a 5 fois Lorsque vous atteignez le nombre maximal de charges votre attaque lourde suivante consomme toutes les charges et libere une violente explosion d energie autour de votre cible qui inflige 3 447 degats de Physique a toutes les cibles dans les 8 metres les degats s adaptant a vos degats magiques ou physiques selon ce qui est le plus eleve
    --[139902]="Verursacht Ihr Schaden mit einem Wuchtschlag, wird ein Feind mit einem anhaltenden, nicht zu entfernenden Blutfluch belegt. Es kann immer nur einen Feind mit Blutfluch gleichzeitig geben. Verursacht Ihr weiteren Wuchtschaden, geht der Blutfluch über. Blockt Ihr einen Angriff von einem mit Blutfluch belegten Feind ab, wird bei Euch <<1>> Magicka wiederhergestellt. Dieser Effekt kann einmal alle <<2>> eintreten.",

    local patternDataList = {
        ["a"] = {"à", "â", "á", "ã", "ä", "å", "ā"},
        ["i"] = {"ì", "í", "î", "ï", "ī"},
        ["u"] = {"ù", "ú", "û", "ü", "ū", "ü"},
        ["e"] = {"è", "é", "ê", "ë", "ē", "è", "é"},
        ["o"] = {"ò", "ó", "ô", "õ", "ö", "ø", "ō"},
        ["A"] = {"À", "Á", "Â", "Ā", "Ã", "Ä", "Å"},
        ["I"] = {"Ì", "Ï", "Ī", "Í"},
        ["U"] = {"Ū"},
        ["E"] = {"È", "É", "Ê", "Ē", "Ë"},
        ["O"] = {"Ò", "Ó", "Ô", "Ō", "Õ", "Ö"},
        [" "] = {
            '%"',
            "%-",
            "’",
            "”",
            "%'",
            "%:",
            "%;",
            "%(",
            "%)"
            --"%.", "%,"
        },
        [""] = {
            --German
            " alle ",
            --French
            " de ",
            " d'",
            " fin ",
            " finun ",
        }
    }
    for _to, patternData in pairs(patternDataList) do
        for _key, pattern in pairs(patternData) do
            s = string.gsub(s, pattern, _to)
        end
    end

    --[[
    s = string.gsub(s, "[ñ]", "n")
    s = string.gsub(s, "[ý]", "y")
    s = string.gsub(s, "[þ]", "p")
    s = string.gsub(s, "[Ç]", "C")
    

    s = string.gsub(s, "æ", "ae")
    s = string.gsub(s, "Æ", "AE")
    s = string.gsub(s, "[Œ]", "OE")
    s = string.gsub(s, "[œ]", "oe")
    ]]
    --s = string.gsub(s, "'", " ")
    --s = string.gsub(s, "'", " ")
    --s = string.gsub(s, "%,", " ")
    --s = string.gsub(s, "%.", " ")

    s = string.gsub(s, "\n+", " ")
    s = string.gsub(s, "\r+", " ")

    s = string.gsub(s, "%s+", " ")
    s = string.gsub(s, "%s+$", "")
    s = string.gsub(s, "^%s+", "")
    return s
end

local function checker(description, format)
    for _key2, pattern in pairs({"%s*%d*%s*%.?%d*%s*", "%s*.-%s*"}) do
        local tmpFormat = format
        tmpFormat = string.gsub(tmpFormat, "<<[^>]+>>", pattern, 99)
        tmpFormat = string.gsub(tmpFormat, "＜＜[^＞]+＞＞", pattern, 99)
        --debugStr = debugStr .. "\n tmpFormat :\n" .. tmpFormat
        local matched = string.match(description, tmpFormat)
        if matched then
            --debugStr = debugStr .. "\n matched :\n" .. matched
            return true
        end
    end

    return false
end

local function checker2(description, format)
    local tmpFormat = format
    local delimiter = "__delimiter__"
    tmpFormat = string.gsub(tmpFormat, "<<[^>]+>>", delimiter, 99)
    tmpFormat = string.gsub(tmpFormat, "＜＜[^＞]+＞＞", delimiter, 99)

    local matched
    local debgStr = ""
    for _key, _substr in ipairs(split(tmpFormat, delimiter)) do
        matched = string.match(description, _substr)
        if not matched then
            debgStr = debgStr .. "\n NOT matched: " .. _substr
            return false, debgStr
        end
        debgStr = debgStr .. "\n matched: " .. _substr
    end

    return true
end

-- return Set item's unique ability descriptions.
--
-- NOTICE!
-- This function works under these conditions.
-- 1. a set bonus ability(max items ability) has a name that is the same as that of the set.
-- 2. only a unique ability. not common bonus. e.g) 'Adds XXXX Health' doesn't be included.
--
-- ESOクライアントから抽出したデータを分析しました。
-- 2021年時点では、セット装備のセットボーナスアビリティはそのセット装備と同一名称のアビリティが該当していますので、それを利用しています。
-- 一般的なボーナスは記載されません。 例） 武器攻撃力 が XXXX 増加する
-- この結果が未来永劫に正しい保証はありません。

--------
-- Public Methods, Consts
--------

function LIB.SearchRawSetItemBonus(langCode, id, itemLink, itemLinkLangCode)
    if langCode == nil then
        return false
    end
    if id == nil then
        return false
    end

    local abilityIds = LIB.SetItemIdToAbilityIds[id]
    if abilityIds == nil or #abilityIds < 1 then
        return false
    end

    local debugStr = ""
    local originalSetBonusDescription = ""

    local clientLangCode = LIB.GetClientLangCode()
    if LMN.DUMMY_LANG_CODES[clientLangCode] then
        clientLangCode = LMN.DUMMY_LANG_CODES[clientLangCode]
    end
    if itemLinkLangCode ~= nil and LMN.DUMMY_LANG_CODES[itemLinkLangCode] then
        itemLinkLangCode = LMN.DUMMY_LANG_CODES[itemLinkLangCode]
    end
    if not itemLinkLangCode then
        itemLinkLangCode = clientLangCode
    end
    debugStr = debugStr .. "\n itemLinkLangCode:" .. itemLinkLangCode

    if LIB.IsLoaded(itemLinkLangCode) and itemLink then
        for numOfSetItems = 10, 0, -1 do
            -- GetItemLinkSetBonusInfo(string itemLink, boolean equipped, number index)
            -- Returns: number numRequired, string bonusDescription
            local numRequired, bonusDescription = GetItemLinkSetBonusInfo(itemLink, false, numOfSetItems)
            if string.len(originalSetBonusDescription) > 0 then
                originalSetBonusDescription = originalSetBonusDescription .. "\n"
            end
            bonusDescription = sanitize_description(bonusDescription)
            originalSetBonusDescription = originalSetBonusDescription .. bonusDescription
            if string.len(bonusDescription) > 0 then
                break
            end
        end
        debugStr = debugStr .. " orig:" .. originalSetBonusDescription
    end
    if originalSetBonusDescription then
        originalSetBonusDescription = string.gsub(originalSetBonusDescription, "^%(.-%)%s-", "")
    end

    local str = ""
    for _key, abilityId in pairs(abilityIds) do
        debugStr = debugStr .. "\n abilityId:" .. abilityId
        if string.len(originalSetBonusDescription) > 0 then
            local format = LIB.GetRawAbilityDescription(itemLinkLangCode, abilityId)
            if not format then
                debugStr = debugStr .. "\n undefined abilityId, or LMN_(langCode) not loaded. abilityId:" .. abilityId .. " langCode:" .. itemLinkLangCode
            else
                format = sanitize_description(format)
                format = escape_magic(format)
    
                local matched = false
    
                matched = checker(originalSetBonusDescription, format)
    
                if matched then
                    return LIB.GetRawAbilityDescription(langCode, abilityId), abilityId, 1, debugStr
                end
                debugStr = debugStr .. "\n checker1 failed."
    
                local debugStr2
                matched, debugStr2 = checker2(originalSetBonusDescription, format)
                if matched then
                    return LIB.GetRawAbilityDescription(langCode, abilityId), abilityId, 2, debugStr
                end
                debugStr = debugStr .. "\n checker2 failed. debugStr2:" .. debugStr2
            end
        end

        if string.len(str) > 0 then
            str = str .. "\n"
        end
        local tmpText = LIB.GetRawAbilityDescription(langCode, abilityId)
        if tmpText then
            str = str .. tmpText
        end
    end

    return str, nil, -1, debugStr
end

function LIB.SearchSetItemBonus(langCode, id, itemLink, itemLinkLangCode)
    local description, abilityId, fuzzyLevel, debugStr = LIB.SearchRawSetItemBonus(langCode, id, itemLink, itemLinkLangCode)
    if description then
        return description, abilityId, fuzzyLevel, debugStr
    else
        return "NotFound. Lang Code " .. langCode .. " Id " .. id , false, false, ""
    end
end
