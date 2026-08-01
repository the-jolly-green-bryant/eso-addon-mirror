---=============================================================================
-- PERSONALITY
--=============================================================================


function KhajiitVoice:ApplyKindSoulTone(text, originalText, intensity)
    local result = text
    local kindExpressions = patterns.khajiitExpressions.kindSoulExpressions
    local traits = KhajiitVoice.savedVars.personalityTraits
    -- Replace greetings with kind versions
    local isGreeting = string.find(originalText:lower(), "hello") or
        string.find(originalText:lower(), "hi") or
        string.find(originalText:lower(), "hey") or
        string.find(originalText:lower(), "greetings") or
        string.find(originalText:lower(), "good day")

    if isGreeting and getStableRandom(originalText, 1, 100, "kindgreet") <= intensity then
        local index = getStableRandom(originalText, 1, #kindExpressions.greetings, "kindgreetindex")
        local kindGreeting = kindExpressions.greetings[index]
        result = string.gsub(result, "^Hello%.?%s*", kindGreeting .. " ")
        result = string.gsub(result, "^Hi%.?%s*", kindGreeting .. " ")
        result = string.gsub(result, "^Hey%.?%s*", kindGreeting .. " ")
        result = string.gsub(result, "^Greetings%.?%s*", kindGreeting .. " ")
        result = string.gsub(result, "^Good day%.?%s*", kindGreeting .. " ")
    end

    -- Replace farewells with kind versions
    local isFarewell = string.find(originalText:lower(), "goodbye") or
        string.find(originalText:lower(), "farewell") or
        string.find(originalText:lower(), "see you") or
        string.find(originalText:lower(), "take care") or
        string.find(originalText:lower(), "bye")

    if traits.replaceGoodbyes then
        if isFarewell and math.random(1, 100) <= intensity then
            local index = math.random(1, #kindExpressions.farewells)
            local kindFarewell = kindExpressions.farewells[index]

            result = string.gsub(result, "^Farewell%.?%s*", kindFarewell .. " ")
            result = string.gsub(result, "^Goodbye%.?%s*", kindFarewell .. "")
            result = string.gsub(result, "^See you%.?%s*", kindFarewell .. " ")
            result = string.gsub(result, "^Take care%.?%s*", kindFarewell .. " ")
            result = string.gsub(result, "^Bye%.?%s*", kindFarewell .. " ")
        end
    end
    -- Apply flowery word replacements
    for pattern, replacement in pairs(kindExpressions.replacements) do
        if getStableRandom(originalText, 1, 100, "kind" .. pattern) <= (intensity / 2) then
            result = string.gsub(result, pattern, replacement)
        end
    end

    -- Apply flowery intensifiers
    for pattern, replacement in pairs(kindExpressions.flowerySpeech.intensifiers) do
        if getStableRandom(originalText, 1, 100, "kindintense" .. pattern) <= (intensity / 3) then
            result = string.gsub(result, "%f[%w]" .. pattern .. "%f[%W]", replacement)
        end
    end

    -- Add endearments to sentences (occasionally)
    if getStableRandom(originalText, 1, 100, "kindendear") <= (intensity / 4) then
        -- Skip endearments for store/vendor interactions
        if not string.find(result, "Store (", 1, true) then -- true = plain text search, case sensitive
            -- Check if endearments already exist
            local hasEndearment = false
            local endearments = kindExpressions.endearments

            for _, endearment in ipairs(endearments) do
                if string.find(result, endearment, 1, true) then
                    hasEndearment = true
                    break
                end
            end

            -- Only add if no endearment already exists
            if not hasEndearment then
                local npcName = GetUnitName("interact") or ""
                local index = getStableRandom(originalText .. npcName, 1, #endearments)

                local endearment = endearments[index]

                -- Add endearment before punctuation or at end
                if string.find(result, "[%.%!%?]$") then
                    result = string.gsub(result, "([%.%!%?])$", endearment .. "%1")
                else
                    result = result .. endearment
                end
            end
        end
    end
    return result
end

-- Apply scholarly tone
function KhajiitVoice:ApplyScholarlyTone(text, originalText, intensity)
    local result = text
    local scholarlyExpressions = patterns.khajiitExpressions.scholarlyExpressions
    local traits = KhajiitVoice.savedVars.personalityTraits

    -- Replace greetings with scholarly versions
    local isGreeting = string.find(originalText:lower(), "hello") or
        string.find(originalText:lower(), "hi") or
        string.find(originalText:lower(), "hey") or
        string.find(originalText:lower(), "greetings") or
        string.find(originalText:lower(), "good day")

    if isGreeting and getStableRandom(originalText, 1, 100, "scholarlygreet") <= intensity then
        local index = getStableRandom(originalText, 1, #scholarlyExpressions.greetings, "scholarlygreetindex")
        local scholarlyGreeting = scholarlyExpressions.greetings[index]
        result = string.gsub(result, "^Hello%.?%s*", scholarlyGreeting .. " ")
        result = string.gsub(result, "^Hi%.?%s*", scholarlyGreeting .. " ")
        result = string.gsub(result, "^Hey%.?%s*", scholarlyGreeting .. " ")
        result = string.gsub(result, "^Greetings%.?%s*", scholarlyGreeting .. " ")
        result = string.gsub(result, "^Good day%.?%s*", scholarlyGreeting .. " ")
    end

    -- NEW: Handle questions with scholarly starters (intensity-based complexity)
    local isQuestion = string.find(result, "%?%s*$")
    if isQuestion and getStableRandom(originalText, 1, 100, "scholarlyquestion") <= (intensity / 2) then
        -- Check if it already has a scholarly start
        local hasScholarlyStart = string.find(result:lower(), "^this one wonders") or
            string.find(result:lower(), "^the ancient texts") or
            string.find(result:lower(), "^scholarly contemplation") or
            string.find(result:lower(), "^the wisdom of ages") or
            string.find(result:lower(), "^as the philosophers") or
            string.find(result:lower(), "^this one is curious") or
            string.find(result:lower(), "^tell this one")

        if not hasScholarlyStart then
            local questionStarters

            -- Choose simple or verbose starters based on intensity
            if intensity <= 100 then
                questionStarters = scholarlyExpressions.questionStarters.simple
            else
                questionStarters = scholarlyExpressions.questionStarters.verbose
            end

            local index = getStableRandom(originalText, 1, #questionStarters, "scholarlyqstarter")
            local questionStarter = questionStarters[index]

            -- Convert first letter to lowercase and prepend starter
            result = questionStarter .. string.lower(result:sub(1, 1)) .. result:sub(2)
        end
    end

    -- Replace farewells with scholarly versions
    if traits.replaceGoodbyes then
        local isFarewell = string.find(originalText:lower(), "goodbye") or
            string.find(originalText:lower(), "farewell") or
            string.find(originalText:lower(), "see you") or
            string.find(originalText:lower(), "take care") or
            string.find(originalText:lower(), "bye")

        if isFarewell and math.random(1, 100) <= intensity then
            local index = math.random(1, #scholarlyExpressions.farewells)
            local scholarlyFarewell = scholarlyExpressions.farewells[index]
            result = string.gsub(result, "^Farewell%.?%s*", scholarlyFarewell .. " ")
            result = string.gsub(result, "^Goodbye%.?%s*", scholarlyFarewell .. "")
            result = string.gsub(result, "^See you%.?%s*", scholarlyFarewell .. " ")
            result = string.gsub(result, "^Take care%.?%s*", scholarlyFarewell .. " ")
            result = string.gsub(result, "^Bye%.?%s*", scholarlyFarewell .. " ")
        end
    end

    -- Apply scholarly word replacements
    for pattern, replacement in pairs(scholarlyExpressions.replacements) do
        if getStableRandom(originalText, 1, 100, "scholarlywrd" .. pattern) <= (intensity / 0.2) then
            result = string.gsub(result, pattern, replacement)
        end
    end

    return result
end

function KhajiitVoice:GetFarewellIndex()
    local farewells = patterns.khajiitExpressions.farewell
    -- Use true randomness for farewells to get variety
    return math.random(1, #farewells)
end

function KhajiitVoice:ReplaceFarewells(text, originalText)
    local result = text

    -- Function to select a random farewell (truly random for variety)
    local function getRandomFarewell()
        local farewells = patterns.khajiitExpressions.farewell
        local index = math.random(#farewells) -- True randomness
        return farewells[index]
    end

    -- Handle "Farewell" patterns
    result = string.gsub(result, "^Farewell%.?%s*", function()
        return getRandomFarewell() .. " "
    end)

    result = string.gsub(result, "^Goodbye%.?%s*", function()
        return getRandomFarewell() .. " "
    end)

    return result
end

-- Stable greeting replacement
function KhajiitVoice:ReplaceGreetings(text, originalText)
    local result = text

    local function getStableGreeting()
        local greetings = patterns.khajiitExpressions.greeting
        local index = getStableRandom(originalText, 1, #greetings, "greeting")
        return greetings[index]
    end

    -- Replace various greeting patterns
    result = string.gsub(result, "^Hello%.?%s*", function()
        return getStableGreeting() .. " "
    end)

    result = string.gsub(result, "^Hi%.?%s*", function()
        return getStableGreeting() .. " "
    end)

    result = string.gsub(result, "^Hey%.?%s*", function()
        return getStableGreeting() .. " "
    end)

    result = string.gsub(result, "^Greetings%.?%s*", function()
        return getStableGreeting() .. " "
    end)

    result = string.gsub(result, "^Good day%.?%s*", function()
        return getStableGreeting() .. " "
    end)

    return result
end
