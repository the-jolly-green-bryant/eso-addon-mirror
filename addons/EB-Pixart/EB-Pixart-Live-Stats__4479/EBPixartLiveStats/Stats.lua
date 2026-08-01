local Addon = EBPixartLiveStats

Addon.Stats = Addon.Stats or {}

local Stats = Addon.Stats
local HEALING_ADVANCED_STAT_CACHE = {}
local HEALING_ADVANCED_CONFIG = {
    outgoing = {
        playerStatName = "STAT_HEALING_DONE",
        advancedDisplayType = "ADVANCED_STAT_DISPLAY_TYPE_HEALING_DONE",
        labels = {
            "les soins effectues pour cent",
            "les soins effectués pour cent",
            "les soins effectues / pour cent",
            "les soins effectués / pour cent",
            "healing done percent",
            "healing done",
        },
    },
    incoming = {
        playerStatName = "STAT_HEALING_TAKEN",
        advancedDisplayType = "ADVANCED_STAT_DISPLAY_TYPE_HEALING_TAKEN",
        labels = {
            "soins recus",
            "soins reçus",
            "healing taken",
        },
    },
}

local function ResolveGlobalNumber(name)
    local value = _G[name]
    if type(value) == "number" then
        return value
    end

    return nil
end

local function NormalizeText(text)
    local normalized = tostring(text or ""):lower()
    local replacements = {
        ["à"] = "a", ["á"] = "a", ["â"] = "a", ["ä"] = "a",
        ["ç"] = "c",
        ["è"] = "e", ["é"] = "e", ["ê"] = "e", ["ë"] = "e",
        ["ì"] = "i", ["í"] = "i", ["î"] = "i", ["ï"] = "i",
        ["ò"] = "o", ["ó"] = "o", ["ô"] = "o", ["ö"] = "o",
        ["ù"] = "u", ["ú"] = "u", ["û"] = "u", ["ü"] = "u",
        ["ÿ"] = "y",
        ["œ"] = "oe",
        ["æ"] = "ae",
    }

    for source, target in pairs(replacements) do
        normalized = normalized:gsub(source, target)
    end

    normalized = normalized:gsub("[%c%p]", " ")
    normalized = normalized:gsub("%s+", " ")
    return normalized
end

local function ParseLocalizedNumber(text)
    local token = tostring(text or ""):match("[-+]?%d+[%.,]?%d*")
    if not token then
        return nil
    end

    token = token:gsub(",", ".")
    return tonumber(token)
end

local function NormalizePercent(value)
    local amount = tonumber(value) or 0
    if zo_abs(amount) < 0.05 then
        return 0
    end

    return amount
end

local function ReadPlayerStat(statId)
    if not statId or type(GetPlayerStat) ~= "function" then
        return 0
    end

    local value = GetPlayerStat(statId)
    return tonumber(value) or 0
end

local function ReadPlayerStatByName(...)
    for index = 1, select("#", ...) do
        local statId = ResolveGlobalNumber(select(index, ...))
        if statId then
            return ReadPlayerStat(statId)
        end
    end

    return 0
end

local function ReadAdvancedFlatValue(...)
    if type(GetAdvancedStatValue) ~= "function" then
        return 0
    end

    for index = 1, select("#", ...) do
        local displayType = ResolveGlobalNumber(select(index, ...))
        if displayType then
            local _, flatValue = GetAdvancedStatValue(displayType)
            return tonumber(flatValue) or 0
        end
    end

    return 0
end

local function ReadAdvancedValues(...)
    if type(GetAdvancedStatValue) ~= "function" then
        return 0, 0
    end

    for index = 1, select("#", ...) do
        local displayType = ResolveGlobalNumber(select(index, ...))
        if displayType then
            local _, flatValue, percentValue = GetAdvancedStatValue(displayType)
            return tonumber(flatValue) or 0, tonumber(percentValue) or 0
        end
    end

    return 0, 0
end

local function SelectBestStatValue(primaryValue, fallbackValue)
    local primary = tonumber(primaryValue) or 0
    if primary ~= 0 then
        return primary
    end

    return tonumber(fallbackValue) or 0
end

local function GetAdvancedCategoryId(categoryIndex)
    if type(GetAdvancedStatsCategoryId) == "function" then
        return GetAdvancedStatsCategoryId(categoryIndex)
    end

    if type(GetAdvancedStatCategoryId) == "function" then
        return GetAdvancedStatCategoryId(categoryIndex)
    end

    return nil
end

local function IsHealingBonusCategory(categoryName)
    local normalized = NormalizeText(categoryName)
    return normalized:find("bonus curatif", 1, true) ~= nil
        or normalized:find("curatif", 1, true) ~= nil
        or normalized:find("healing bonus", 1, true) ~= nil
        or normalized:find("healing", 1, true) ~= nil
end

local function MatchesHealingLabel(text, labels)
    local normalized = NormalizeText(text)
    for _, label in ipairs(labels or {}) do
        if normalized:find(NormalizeText(label), 1, true) then
            return true
        end
    end

    return false
end

local function DebugValueToString(value)
    if value == nil then
        return "nil"
    end

    return tostring(value)
end

local function DumpChatLine(label, value)
    if Addon and Addon.Print then
        Addon:Print(string.format("[EBLS DEBUG] %s = %s", label, DebugValueToString(value)))
    end
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then
        return false, "fonction absente"
    end

    return pcall(fn, ...)
end

local function DumpChatFullLine(label, value)
    if Addon and Addon.Print then
        Addon:Print(string.format("[EBLS DEBUG FULL] %s = %s", label, DebugValueToString(value)))
    end
end

local function IsNumeric(value)
    return type(value) == "number"
end

local function DumpNumericVariants(label, value)
    DumpChatFullLine(label, value)
    if IsNumeric(value) then
        DumpChatFullLine(label .. " x100", value * 100)
    end
end

local function IsHealingCandidateConstant(name, value)
    if type(name) ~= "string" or type(value) ~= "number" then
        return false
    end

    local upperName = name:upper()
    return upperName:find("HEAL", 1, true) ~= nil
        or upperName:find("HEALING", 1, true) ~= nil
        or upperName:find("DONE", 1, true) ~= nil
        or upperName:find("OUTGOING", 1, true) ~= nil
        or upperName:find("INCOMING", 1, true) ~= nil
        or upperName:find("BONUS", 1, true) ~= nil
        or upperName:find("CUR", 1, true) ~= nil
end

local function CollectHealingCandidateConstants(limit)
    local names = {}

    for name, value in pairs(_G) do
        if IsHealingCandidateConstant(name, value) then
            names[#names + 1] = name
        end
    end

    table.sort(names)

    local maxCount = tonumber(limit) or 30
    while #names > maxCount do
        table.remove(names)
    end

    return names
end

function Stats:DumpOutgoingHealingDebug()
    local config = HEALING_ADVANCED_CONFIG.outgoing
    local cached = HEALING_ADVANCED_STAT_CACHE.outgoing

    local okCurrent, currentValue = SafeCall(ReadHealingAdvancedPercent, "outgoing")
    DumpChatLine("outgoingHealingPercent actuel", okCurrent and currentValue or currentValue)

    local okDirect, directStat = SafeCall(ReadPlayerStatByName, config.playerStatName)
    DumpChatLine("source direct stat / STAT_HEALING_DONE", okDirect and directStat or directStat)

    local okAdvancedValues, advancedFlat, advancedPercent = SafeCall(ReadAdvancedValues, config.advancedDisplayType)
    if okAdvancedValues then
        DumpChatLine("source advanced display / flat", advancedFlat)
        DumpChatLine("source advanced display / percent", advancedPercent)
    else
        DumpChatLine("source advanced display", advancedFlat)
    end

    if cached then
        DumpChatLine("source C / cache categoryId", cached.categoryId)
        DumpChatLine("source C / cache statIndex", cached.statIndex)
        DumpChatLine("source C / cache statType", cached.statType)

        local okInfo, _, displayName, description, flatValueDescription, percentValueDescription = SafeCall(GetAdvancedStatInfo, cached.categoryId, cached.statIndex)
        if okInfo then
            DumpChatLine("source C / cache displayName", displayName)
            DumpChatLine("source C / cache description", description)
            DumpChatLine("source C / cache flatValueDescription", flatValueDescription)
            DumpChatLine("source C / cache percentValueDescription", percentValueDescription)
        else
            DumpChatLine("source C / cache info", displayName)
        end

        local okValue, _, cachedFlatValue, cachedPercentValue = SafeCall(GetAdvancedStatValue, cached.statType)
        if okValue then
            DumpChatLine("source C / cache flatValue", cachedFlatValue)
            DumpChatLine("source C / cache percentValue", cachedPercentValue)
        else
            DumpChatLine("source C / cache value", cachedFlatValue)
        end
    else
        DumpChatLine("source C / cache", nil)
    end

    local okCategories, numCategories = SafeCall(GetNumAdvancedStatCategories)
    if okCategories then
        local foundAny = false

        for categoryIndex = 1, tonumber(numCategories) or 0 do
            local categoryId = GetAdvancedCategoryId(categoryIndex)
            if categoryId then
                local okCategory, categoryName, numStats = SafeCall(GetAdvancedStatCategoryInfo, categoryId)
                if okCategory and (tonumber(numStats) or 0) > 0 and IsHealingBonusCategory(categoryName) then
                    for statIndex = 1, tonumber(numStats) or 0 do
                        local okInfo, statType, displayName, description, flatValueDescription, percentValueDescription = SafeCall(GetAdvancedStatInfo, categoryId, statIndex)
                        if okInfo then
                            local matchText = string.format(
                                "%s %s %s %s",
                                tostring(displayName or ""),
                                tostring(description or ""),
                                tostring(flatValueDescription or ""),
                                tostring(percentValueDescription or "")
                            )

                            if MatchesHealingLabel(matchText, config.labels) then
                                local okValue, _, flatValue, percentValue = SafeCall(GetAdvancedStatValue, statType)
                                foundAny = true
                                DumpChatLine("source D / found categoryName", categoryName)
                                DumpChatLine("source D / found statIndex", statIndex)
                                DumpChatLine("source D / found statType", statType)
                                DumpChatLine("source D / found displayName", displayName)
                                DumpChatLine("source D / found description", description)
                                DumpChatLine("source D / found flatValueDescription", flatValueDescription)
                                DumpChatLine("source D / found percentValueDescription", percentValueDescription)
                                if okValue then
                                    DumpChatLine("source D / found flatValue", flatValue)
                                    DumpChatLine("source D / found percentValue", percentValue)
                                else
                                    DumpChatLine("source D / found value", flatValue)
                                end
                            end
                        else
                            DumpChatLine("source D / GetAdvancedStatInfo", statType)
                        end
                    end
                elseif not okCategory then
                    DumpChatLine("source D / GetAdvancedStatCategoryInfo", categoryName)
                end
            end
        end

        if not foundAny then
            DumpChatLine("source D / found", nil)
        end
    else
        DumpChatLine("source D / GetNumAdvancedStatCategories", numCategories)
    end
end

function Stats:DumpOutgoingHealingDebugFull()
    local config = HEALING_ADVANCED_CONFIG.outgoing
    local okCurrent, currentValue = SafeCall(ReadHealingAdvancedPercent, "outgoing")
    DumpChatFullLine("addon actuel", okCurrent and currentValue or currentValue)

    local okDirect, directValue = SafeCall(ReadPlayerStatByName, config.playerStatName)
    if okDirect then
        DumpNumericVariants("STAT_HEALING_DONE", directValue)
    else
        DumpChatFullLine("STAT_HEALING_DONE", directValue)
    end

    local okAdvancedValues, advancedFlat, advancedPercent = SafeCall(ReadAdvancedValues, config.advancedDisplayType)
    if okAdvancedValues then
        DumpChatFullLine("advanced flat", advancedFlat)
        DumpNumericVariants("advanced percent brut", advancedPercent)
    else
        DumpChatFullLine("advanced values", advancedFlat)
    end

    local okNormalized, normalizedCurrent = SafeCall(NormalizePercent, okCurrent and currentValue or nil)
    DumpChatFullLine("valeur finale normalisee", okNormalized and normalizedCurrent or normalizedCurrent)

    local candidateConstants = CollectHealingCandidateConstants(30)
    if #candidateConstants == 0 then
        DumpChatFullLine("constantes candidates", nil)
    else
        for _, constantName in ipairs(candidateConstants) do
            local constantValue = _G[constantName]
            DumpChatFullLine("CONST " .. constantName, constantValue)

            local okPlayer, playerStatValue = SafeCall(GetPlayerStat, constantValue)
            if okPlayer then
                DumpChatFullLine("test player stat " .. constantName, playerStatValue)
            else
                DumpChatFullLine("test player stat " .. constantName, playerStatValue)
            end

            local okAdvanced, _, flatValue, percentValue = SafeCall(GetAdvancedStatValue, constantValue)
            if okAdvanced then
                DumpChatFullLine("test advanced flat " .. constantName, flatValue)
                DumpNumericVariants("test advanced percent " .. constantName, percentValue)
            else
                DumpChatFullLine("test advanced " .. constantName, flatValue)
            end
        end
    end

    local okCategories, numCategories = SafeCall(GetNumAdvancedStatCategories)
    if okCategories then
        DumpChatFullLine("GetNumAdvancedStatCategories", numCategories)
        for categoryIndex = 1, tonumber(numCategories) or 0 do
            local categoryId = GetAdvancedCategoryId(categoryIndex)
            if categoryId then
                local okCategory, categoryName, numStats = SafeCall(GetAdvancedStatCategoryInfo, categoryId)
                if okCategory then
                    DumpChatFullLine("advanced category", string.format("%s (%s)", DebugValueToString(categoryName), DebugValueToString(numStats)))
                    if (tonumber(numStats) or 0) > 0 then
                        for statIndex = 1, tonumber(numStats) or 0 do
                            local okInfo, statType, displayName, description, flatValueDescription, percentValueDescription = SafeCall(GetAdvancedStatInfo, categoryId, statIndex)
                            if okInfo then
                                local matchText = string.format(
                                    "%s %s %s %s",
                                    tostring(displayName or ""),
                                    tostring(description or ""),
                                    tostring(flatValueDescription or ""),
                                    tostring(percentValueDescription or "")
                                )

                                if MatchesHealingLabel(matchText, config.labels) or IsHealingBonusCategory(categoryName) then
                                    DumpChatFullLine("scan statType", statType)
                                    DumpChatFullLine("scan displayName", displayName)
                                    DumpChatFullLine("scan description", description)
                                    DumpChatFullLine("scan flatValueDescription", flatValueDescription)
                                    DumpChatFullLine("scan percentValueDescription", percentValueDescription)

                                    local okValue, _, flatValue, percentValue = SafeCall(GetAdvancedStatValue, statType)
                                    if okValue then
                                        DumpChatFullLine("scan flatValue", flatValue)
                                        DumpNumericVariants("scan percentValue", percentValue)
                                    else
                                        DumpChatFullLine("scan value", flatValue)
                                    end
                                end
                            else
                                DumpChatFullLine("scan GetAdvancedStatInfo", statType)
                            end
                        end
                    end
                else
                    DumpChatFullLine("GetAdvancedStatCategoryInfo", categoryName)
                end
            end
        end
    else
        DumpChatFullLine("GetNumAdvancedStatCategories", numCategories)
    end
end

local function ReadHealingAdvancedPercent(kind)
    local config = HEALING_ADVANCED_CONFIG[kind]
    if not config then
        return 0
    end

    if kind == "outgoing" then
        return NormalizePercent(ReadPlayerStatByName(config.playerStatName))
    end

    local cached = HEALING_ADVANCED_STAT_CACHE[kind]
    if cached and type(GetAdvancedStatInfo) == "function" and type(GetAdvancedStatValue) == "function" then
        local _, _, _, flatValueDescription, percentValueDescription = GetAdvancedStatInfo(cached.categoryId, cached.statIndex)
        local _, flatValue, percentValue = GetAdvancedStatValue(cached.statType)

        if tonumber(percentValue) and tonumber(percentValue) ~= 0 then
            return NormalizePercent(percentValue)
        end

        local parsedPercent = ParseLocalizedNumber(percentValueDescription)
        if parsedPercent ~= nil then
            return NormalizePercent(parsedPercent)
        end

        local parsedFlat = ParseLocalizedNumber(flatValueDescription)
        if parsedFlat ~= nil then
            return NormalizePercent(parsedFlat)
        end

        if tonumber(flatValue) and tonumber(flatValue) ~= 0 then
            return NormalizePercent(flatValue)
        end
    end

    if type(GetNumAdvancedStatCategories) == "function" and type(GetAdvancedStatCategoryInfo) == "function" and type(GetAdvancedStatInfo) == "function" and type(GetAdvancedStatValue) == "function" then
        for categoryIndex = 1, GetNumAdvancedStatCategories() do
            local categoryId = GetAdvancedCategoryId(categoryIndex)
            if categoryId then
                local categoryName, numStats = GetAdvancedStatCategoryInfo(categoryId)
                if (tonumber(numStats) or 0) > 0 and IsHealingBonusCategory(categoryName) then
                    for statIndex = 1, numStats do
                        local statType, displayName, description, flatValueDescription, percentValueDescription = GetAdvancedStatInfo(categoryId, statIndex)
                        local matchText = string.format(
                            "%s %s %s %s",
                            tostring(displayName or ""),
                            tostring(description or ""),
                            tostring(flatValueDescription or ""),
                            tostring(percentValueDescription or "")
                        )

                        if MatchesHealingLabel(matchText, config.labels) then
                            HEALING_ADVANCED_STAT_CACHE[kind] = {
                                categoryId = categoryId,
                                statIndex = statIndex,
                                statType = statType,
                            }

                            local _, flatValue, percentValue = GetAdvancedStatValue(statType)
                            if tonumber(percentValue) and tonumber(percentValue) ~= 0 then
                                return NormalizePercent(percentValue)
                            end

                            local parsedPercent = ParseLocalizedNumber(percentValueDescription)
                            if parsedPercent ~= nil then
                                return NormalizePercent(parsedPercent)
                            end

                            local parsedFlat = ParseLocalizedNumber(flatValueDescription)
                            if parsedFlat ~= nil then
                                return NormalizePercent(parsedFlat)
                            end

                            if tonumber(flatValue) and tonumber(flatValue) ~= 0 then
                                return NormalizePercent(flatValue)
                            end
                        end
                    end
                end
            end
        end
    end

    local _, fallbackPercent = ReadAdvancedValues(config.advancedDisplayType)
    if fallbackPercent ~= 0 then
        return NormalizePercent(fallbackPercent)
    end

    return NormalizePercent(ReadPlayerStatByName(config.playerStatName))
end

function Stats:Initialize()
    self:ResetSession()
    SLASH_COMMANDS["/eblsdebugheal"] = function()
        self:DumpOutgoingHealingDebug()
    end
    SLASH_COMMANDS["/eblsdebughealfull"] = function()
        self:DumpOutgoingHealingDebugFull()
    end
end

function Stats:ResetSession()
    self.session = {
        totalDamage = 0,
        totalHealing = 0,
        combatStartAt = 0,
        inCombat = false,
    }
end

function Stats:StartCombat()
    if self.session.inCombat then
        return
    end

    self.session.inCombat = true
    self.session.combatStartAt = GetFrameTimeMilliseconds()
    Addon.sv.stats.combatStartAt = self.session.combatStartAt
end

function Stats:EndCombat()
    if not self.session.inCombat then
        return
    end

    self.session.inCombat = false
    Addon.sv.stats.lastCombatEndAt = GetFrameTimeMilliseconds()
end

function Stats:AddDamage(amount)
    local value = zo_max(0, tonumber(amount) or 0)
    self.session.totalDamage = self.session.totalDamage + value
    Addon.sv.stats.totalDamage = Addon.sv.stats.totalDamage + value
end

function Stats:AddHealing(amount)
    local value = zo_max(0, tonumber(amount) or 0)
    self.session.totalHealing = self.session.totalHealing + value
    Addon.sv.stats.totalHealing = Addon.sv.stats.totalHealing + value
end

function Stats:GetSnapshot()
    return {
        totalDamage = self.session.totalDamage,
        totalHealing = self.session.totalHealing,
        inCombat = self.session.inCombat,
        combatStartAt = self.session.combatStartAt,
    }
end

function Stats.GetLiveStats()
    local spellCritRating = ReadPlayerStatByName("STAT_SPELL_CRITICAL")
    local weaponCritRating = ReadPlayerStatByName("STAT_CRITICAL_STRIKE")
    local spellPower = ReadPlayerStatByName("STAT_SPELL_POWER")
    local weaponPower = ReadPlayerStatByName("STAT_POWER", "STAT_ATTACK_POWER")
    local spellPen = ReadPlayerStatByName("STAT_SPELL_PENETRATION")
    local weaponPen = ReadPlayerStatByName("STAT_PHYSICAL_PENETRATION")
    local outgoingHealingPercent = ReadHealingAdvancedPercent("outgoing")
    local incomingHealingPercent = ReadHealingAdvancedPercent("incoming")
    local blockPercent = SelectBestStatValue(
        ReadPlayerStatByName("STAT_BLOCK"),
        select(2, ReadAdvancedValues("ADVANCED_STAT_DISPLAY_TYPE_BLOCK", "ADVANCED_STAT_DISPLAY_TYPE_BLOCK_MITIGATION"))
    )
    local blockCost = ReadAdvancedFlatValue("ADVANCED_STAT_DISPLAY_TYPE_BLOCK_COST")
    local moveSpeedPercent = SelectBestStatValue(
        ReadPlayerStatByName("STAT_MOVEMENT_SPEED", "STAT_MOVE_SPEED", "STAT_SPRINT_SPEED"),
        select(2, ReadAdvancedValues("ADVANCED_STAT_DISPLAY_TYPE_MOVEMENT_SPEED", "ADVANCED_STAT_DISPLAY_TYPE_MOVE_SPEED", "ADVANCED_STAT_DISPLAY_TYPE_SPRINT_SPEED"))
    )
    local physicalResistance = ReadPlayerStatByName("STAT_PHYSICAL_RESIST")
    local spellResistance = ReadPlayerStatByName("STAT_SPELL_RESIST")
    local criticalResistance = ReadPlayerStatByName("STAT_CRITICAL_RESISTANCE")

    return {
        spellCritRating = spellCritRating,
        weaponCritRating = weaponCritRating,
        spellCritPercent = (type(GetCriticalStrikeChance) == "function" and GetCriticalStrikeChance(spellCritRating, true)) or 0,
        weaponCritPercent = (type(GetCriticalStrikeChance) == "function" and GetCriticalStrikeChance(weaponCritRating, true)) or 0,
        spellPower = zo_floor(spellPower),
        weaponPower = zo_floor(weaponPower),
        spellPen = zo_floor(spellPen),
        weaponPen = zo_floor(weaponPen),
        outgoingHealingPercent = outgoingHealingPercent,
        incomingHealingPercent = incomingHealingPercent,
        blockPercent = blockPercent,
        blockCost = zo_floor(blockCost),
        moveSpeedPercent = moveSpeedPercent,
        physicalResistance = zo_floor(physicalResistance),
        spellResistance = zo_floor(spellResistance),
        criticalResistance = zo_floor(criticalResistance),
    }
end
