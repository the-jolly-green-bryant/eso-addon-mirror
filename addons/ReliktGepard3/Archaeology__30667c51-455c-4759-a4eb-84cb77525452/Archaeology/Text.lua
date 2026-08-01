local AA = Archaeology

function AA:Print(message)
    local text = tostring(message or "")

    -- Keep addon text white, but resume white after embedded colored segments.
    text = text:gsub("|r", "|r|cFFFFFF")

    d(string.format("|cFFFFFF[%s] %s|r", self.name, text))
end

function AA.NormalizeText(text)
    if not text then
        return ""
    end

    if type(zo_strtrim) == "function" then
        text = zo_strtrim(text)
    end

    if type(zo_strlower) == "function" then
        text = zo_strlower(text)
    end

    return text
end

function AA.FormatLeadTime(secondsRemaining)
    if type(ZO_FormatAntiquityLeadTime) == "function" then
        return ZO_FormatAntiquityLeadTime(secondsRemaining)
    end

    if type(secondsRemaining) ~= "number" or secondsRemaining <= 0 then
        return "expired"
    end

    local hours = math.floor(secondsRemaining / 3600)
    local minutes = math.floor((secondsRemaining % 3600) / 60)
    return string.format("%dh %02dm", hours, minutes)
end

local function TryGetEnumString(enumIdNames, value)
    if type(GetString) ~= "function" then
        return nil
    end

    for _, enumIdName in ipairs(enumIdNames) do
        local enumId = _G[enumIdName] or enumIdName
        local ok, textValue = pcall(function()
            return GetString(enumId, value)
        end)

        if ok and type(textValue) == "string" and textValue ~= "" and textValue ~= enumIdName then
            return textValue
        end
    end

    return nil
end

local function GetDifficultyFallbackName(difficulty)
    if type(difficulty) ~= "number" then
        return nil
    end

    difficulty = math.floor(difficulty)
    if difficulty >= 1 and difficulty <= #AA.difficultyNameFallbacks then
        return AA.difficultyNameFallbacks[difficulty]
    end

    -- Some enums are zero-based; map 0..4 -> Simple..Ultimate.
    if difficulty >= 0 and difficulty < #AA.difficultyNameFallbacks then
        return AA.difficultyNameFallbacks[difficulty + 1]
    end

    return nil
end

function AA.BuildDifficultyText(difficulty)
    if type(difficulty) ~= "number" then
        return "Unknown Difficulty"
    end

    return TryGetEnumString(
        { "SI_ANTIQUITYDIFFICULTY", "SI_ANTIQUITY_DIFFICULTY", "SI_ANTIQUITYSCRYINGDIFFICULTY" },
        difficulty
    ) or GetDifficultyFallbackName(difficulty) or string.format("Difficulty %d", difficulty)
end
