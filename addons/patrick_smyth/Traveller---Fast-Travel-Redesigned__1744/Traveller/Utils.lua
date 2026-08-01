--[[
    Traveller by Patrick Smyth
    
    This module contains routines that are not specific to Traveller but are more general-purpose

--]]
Utils = { }

-- ==========================================================================================
--
-- String handling routines
--

function Utils:IsString(inString)
    -- function returns false for an empty, invalid or blank string
    local goodStr = (inString ~= nil)

    if goodStr then
        local typeStr = type(inString)
        goodStr = (typeStr == "string")
    end

    if goodStr then
        goodStr = (inString ~= "")
    end

    if goodStr then
        local trimString = self:Trim(inString)

        goodStr = (trimString ~= "")
    end

    return goodStr
end

function Utils:IsEmptyStr(inString)
    -- function returns true for an empty or blank string

    local emptyStr = (inString == nil)

    if not emptyStr then
        local typeStr = type(inString)
        local gotStr = (typeStr == "string")

        if gotStr then
            emptyStr = (inString == "")

            if not emptyStr then
                local trimString = self:Trim(inString)

                emptyStr = (trimString == "")
            end
        end
    end

    return emptyStr
end

function Utils:GetStartStr(inString, length)
    local result = ""

    inString = inString or ""
    length = length or 0

    if length > 0 then
        local inLen = string.len(inString)

        if inLen <= length then
            result = inString
        else
            result = string.sub(inString, 1, length)
        end
    end

    return result
end

function Utils:StartsWithStr(inString, prefix)
    local matched = true
    local prelen = 0

    inString = inString or ""
    prefix = prefix or ""

    prelen = string.len(prefix)

    if (prelen > 0) and (inString ~= "") then
        local starter = self:GetStartStr(inString, prelen)
        matched = (starter == prefix)
    elseif prelen > 0 then
        matched = false
    end

    return matched
end

function Utils:EndsWithStr(inString, suffix)
    local matched = true
    local suflen = 0

    inString = inString or ""
    suffix = suffix or ""

    suflen = string.len(suffix)

    if (suflen > 0) and (inString ~= "") then
        local ending = self:GetEndStr(inString, suflen)
        matched = (ending == suffix)
    elseif suflen > 0 then
        matched = false
    end

    return matched
end

function Utils:GetEndStr(inString, length)
    local result = ""

    inString = inString or ""
    length = length or 0

    if length > 0 then
        local inLen = string.len(inString)

        if inLen <= length then
            result = inString
        else
            result = string.sub(inString, -length)
        end
    end

    return result
end

function Utils:RemoveFromStartStr(inString, matchString)
    local matchLen = 0
    local result = ""
    local inLen = 0

    inString = inString or ""
    matchString = matchString or ""

    matchLen = string.len(matchString)
    result = self:Trim(inString)
    inLen = string.len(result)

    if (inLen > matchLen) and (matchLen > 0) then
        local tmpString = self:GetStartStr(result, matchLen)
 
        if tmpString == matchString then
            result = string.sub(result, matchLen + 1)
            result = self:Trim(result)
        end
    elseif result == matchString then
        result = ""
    end

    return result
end

function Utils:RemoveFromEndStr(inString, matchString)
    local matchLen = 0
    local result = ""
    local inLen = 0

    inString = inString or ""
    matchString = matchString or ""

    matchLen = string.len(matchString)
    result = self:Trim(inString)
    inLen = string.len(result)

    if (inLen > matchLen) and (matchLen > 0) then
        local tmpString = self:GetEndStr(result, matchLen)
 
        if tmpString == matchString then
            result = string.sub(result, 1, inLen - matchLen)
            result = self:Trim(result)
        end
    elseif result == matchString then
        result = ""
    end

    return result
end

function Utils:Trim(inString)
    local result = ""
    inString = inString or ""

    if inString ~= "" then
        result = zo_strtrim(inString)
        result = result or ""
    end

    return result
end

function Utils:Trim2(inString)
    local result = self:Trim(inString)

    if result == "" then
        result = nil
    end

    return result
end

-- ==========================================================================================
--
-- Number handling routines
--

function Utils:IsNumber(inNumber)
    -- function returns false for an empty or invalid number
    local goodNum = (inNumber ~= nil)

    if goodNum then
        local typeNum = type(inNumber)
        goodNum = (typeNum == "number")
    end

    return goodNum
end

-- ==========================================================================================
--
-- Table handling routines
--

function Utils:TableCopy(source, destination)
    source = source or { }

    ZO_DeepTableCopy(source, destination)

    return destination
end

function Utils:TableConcat(base, addition, overwriteBase)
    base = base or { }
    overwriteBase = overwriteBase or false

    if addition ~= nil then
        for k, v in pairs(addition) do
            if overwriteBase then
                -- note that this overwrites any values in base that are common to both tables
                base[k] = v
            elseif base[k] == nil then
                -- note that this ignores any values in addition that are common to both tables
                base[k] = v
            end
        end
    end

    return base
end

function Utils:TableClear(clearThis)

    if clearThis ~= nil then
        ZO_ClearTable(clearThis)
    else
        clearThis = { }
    end

    return clearThis
end

-- ==========================================================================================
--
-- Auto-completion
--

function Utils:ACLookup(ACtable, target)
    local normName = ""
    local results = nil
    target = target or ""

    if (target ~= "") and (ACtable ~= nil) then
        results = GetTopMatchesByLevenshteinSubStringScore(ACtable, target, 1, 1)
    end

    if results ~= nil then
        normName = results[1]
        normName = normName or ""
    end

    return normName
end