local TT = TamrielicTongues

TT.Normalizer = {}

function TT.Normalizer:Trim(value)
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

function TT.Normalizer:GetCase(value)
    -- A single capital (especially "I" or "A") is title case, not emphasis
    -- that should uppercase an entire translated word.
    if #value > 1 and value == string.upper(value) and value ~= string.lower(value) then
        return "upper"
    end

    local first = value:sub(1, 1)
    local rest = value:sub(2)
    if first == string.upper(first) and first ~= string.lower(first) and rest == string.lower(rest) then
        return "title"
    end

    return "lower"
end

function TT.Normalizer:ApplyCase(value, caseMode)
    if caseMode == "upper" then
        return string.upper(value)
    elseif caseMode == "title" then
        return string.upper(value:sub(1, 1)) .. value:sub(2)
    end
    return string.lower(value)
end
