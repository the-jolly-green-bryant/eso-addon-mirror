local TT = TamrielicTongues

TT.Tokenizer = {}

local function isAsciiLetter(character)
    return character:match("[A-Za-z]") ~= nil
end

-- Maps ASCII word runs while preserving punctuation, whitespace, numbers and
-- ESO link/color markup. Non-ASCII text is deliberately passed through unchanged in v1.
-- The callback also receives a sentence-start flag: message start, . ! ? or
-- a line break. Quotes/whitespace do not consume that flag; visible text does.
function TT.Tokenizer:MapWords(text, callback)
    local out = {}
    local i = 1
    local length = #text
    local sentenceStart = true

    while i <= length do
        local prefix = text:sub(i, i + 1)
        local colorTag = prefix == "|c" and text:sub(i, i + 7):match("^|c%x%x%x%x%x%x$")
        if prefix == "||" then
            out[#out + 1] = prefix
            i = i + 2
            sentenceStart = false
        elseif colorTag then
            out[#out + 1] = colorTag
            i = i + 8
        elseif prefix == "|r" then
            out[#out + 1] = prefix
            i = i + 2
        elseif prefix == "|H" then
            local firstCloseStart, firstCloseEnd = text:find("|h", i + 2, true)
            if firstCloseStart then
                local secondCloseStart, secondCloseEnd = text:find("|h", firstCloseEnd + 1, true)
                if secondCloseStart then
                    out[#out + 1] = text:sub(i, secondCloseEnd)
                    i = secondCloseEnd + 1
                    sentenceStart = false
                else
                    out[#out + 1] = text:sub(i)
                    break
                end
            else
                out[#out + 1] = text:sub(i)
                break
            end
        else
            local character = text:sub(i, i)
            if isAsciiLetter(character) then
                local start = i
                i = i + 1
                while i <= length and isAsciiLetter(text:sub(i, i)) do
                    i = i + 1
                end
                out[#out + 1] = callback(text:sub(start, i - 1), sentenceStart)
                sentenceStart = false
            else
                out[#out + 1] = character
                if character:match("[%.!?\r\n]") then
                    sentenceStart = true
                elseif character:match("[%w\128-\255]") then
                    sentenceStart = false
                end
                i = i + 1
            end
        end
    end

    return table.concat(out)
end
