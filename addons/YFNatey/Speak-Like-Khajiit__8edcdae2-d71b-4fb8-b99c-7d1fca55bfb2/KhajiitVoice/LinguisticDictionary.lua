--[[
1. Handle player Name (when the game uses your characters name " I am [Name]")
2. Get Self Reference
3. Replace Character name references
4. Replace Pronouns
5. Handle Verb Conjugation
6. Handle Questions (appends ",yes?" when necessary)
7. Add Personality Traits (unused)
8. Handle Punctuation
9. Handle second pronouns (Fixes "this one" overuse)
10. Fix edge cases
--]]


local function getStableRandom(text, min, max)
    -- Create a stable seed based on the text content
    local seed = 0
    for i = 1, #text do
        seed = seed + string.byte(text, i)
    end

    -- Use the seed to get a deterministic "random" number
    math.randomseed(seed)
    local result = math.random(min, max)

    -- Reset random seed for other uses
    math.randomseed(os.time())
    return result
end
---=============================================================================
-- REPLACE PRONOUNS
--=============================================================================
-- 1. Handle Player Name
function KhajiitVoice:HandlePlayerNameCases(text)
    local playerName = GetUnitName("player")
    if not playerName or playerName == "" then
        return text
    end

    local result = text
    local lowerPlayerName = playerName:lower()

    -- Handle "I am [PlayerName]" -> "This one is [PlayerName]"
    local iAmNamePattern = "I am " .. playerName:gsub("([^%w])", "%%%1")
    result = string.gsub(result, iAmNamePattern, "This one is " .. playerName, 1)

    -- Handle case insensitive version
    local iAmNamePatternLower = "i am " .. lowerPlayerName:gsub("([^%w])", "%%%1")
    result = string.gsub(result, iAmNamePatternLower, "This one is " .. playerName, 1)

    -- Handle "My name is [PlayerName]" -> "This one's name is [PlayerName]"
    local myNamePattern = "My name is " .. playerName:gsub("([^%w])", "%%%1")
    result = string.gsub(result, myNamePattern, "This one's name is " .. playerName, 1)

    local myNamePatternLower = "my name is " .. lowerPlayerName:gsub("([^%w])", "%%%1")
    result = string.gsub(result, myNamePatternLower, "This one's name is " .. playerName, 1)

    -- Handle other common patterns
    local patterns = {
        { "I'm " .. playerName:gsub("([^%w])", "%%%1"),      "This one is " .. playerName },
        { "i'm " .. lowerPlayerName:gsub("([^%w])", "%%%1"), "This one is " .. playerName },
        { "I, " .. playerName:gsub("([^%w])", "%%%1"),       "This one, " .. playerName },
        { "i, " .. lowerPlayerName:gsub("([^%w])", "%%%1"),  "This one, " .. playerName },
    }

    for _, patternInfo in ipairs(patterns) do
        result = string.gsub(result, patternInfo[1], patternInfo[2], 1)
    end

    return result
end

-- 2. get self reference
function KhajiitVoice:GetSelfReference(originalText)
    -- If the original text already contains the player name, always use "this one"
    if self:ContainsPlayerName(originalText) then
        return "this one"
    end

    -- Otherwise use your weighted selection
    local weights = KhajiitVoice.savedVars.pronounWeights
    local total = weights.thisOne + weights.charName + weights.khajiit
    local roll = getStableRandom(originalText, 1, total)

    if roll <= weights.thisOne then
        return "this one"
    elseif roll <= weights.thisOne + weights.charName then
        -- Use custom alias if enabled and set, otherwise use character name
        if KhajiitVoice.savedVars.useCustomAlias and
            KhajiitVoice.savedVars.customAliasText and
            KhajiitVoice.savedVars.customAliasText ~= "" then
            return KhajiitVoice.savedVars.customAliasText
        else
            return GetUnitName("player")
        end
    else
        return "Khajiit"
    end
end

-- 3. Replace Character Name References
function KhajiitVoice:ReplaceCharacterNameReferences(text)
    -- If using custom alias
    if not KhajiitVoice.savedVars.useCustomAlias or
        not KhajiitVoice.savedVars.customAliasText or
        KhajiitVoice.savedVars.customAliasText == "" then
        return text
    end

    local playerName = GetUnitName("player")
    local roleplayName = KhajiitVoice.savedVars.customAliasText

    if not playerName or playerName == "" then
        return text
    end

    local result = text

    -- Create escaped patterns for the player name
    local escapedName = playerName:gsub("([^%w])", "%%%1")


    local hasMyNamePattern = string.find(result, "My name is " .. escapedName) or
        string.find(result, "my name is " .. escapedName:lower()) or
        string.find(result, "I am " .. escapedName) or
        string.find(result, "i am " .. escapedName:lower()) or
        string.find(result, "I'm " .. escapedName) or
        string.find(result, "i'm " .. escapedName:lower())

    if hasMyNamePattern then
        return result
    end

    -- Replace exact matches (case sensitive)
    result = string.gsub(result, escapedName, roleplayName)

    -- Also handle case insensitive matches
    local lowerName = playerName:lower()
    local escapedLowerName = lowerName:gsub("([^%w])", "%%%1")

    -- Replace lowercase version with lowercase roleplay name
    result = string.gsub(result, escapedLowerName, roleplayName:lower())

    -- Replace uppercase version with uppercase roleplay name
    local upperName = playerName:upper()
    local escapedUpperName = upperName:gsub("([^%w])", "%%%1")
    result = string.gsub(result, escapedUpperName, roleplayName:upper())

    -- Handle capitalized version (first letter caps)
    local capName = playerName:sub(1, 1):upper() .. playerName:sub(2):lower()
    local escapedCapName = capName:gsub("([^%w])", "%%%1")
    local capRoleplayName = roleplayName:sub(1, 1):upper() .. roleplayName:sub(2):lower()
    result = string.gsub(result, escapedCapName, capRoleplayName)

    return result
end

-- 5. Replace Pronouns
function KhajiitVoice:ReplacePronouns(text, selfRef)
    local result = text
    local objectForm = (selfRef == "this one") and "this one" or selfRef
    local possessiveForm

    if selfRef == "this one" then
        possessiveForm = self:GetGenderedPronoun("possessive", false)
    elseif selfRef == "Khajiit" then
        possessiveForm = "Khajiit's"
    else
        possessiveForm = selfRef .. "'s"
    end

    -- Handle most specific patterns first to avoid conflicts

    -- Specific contractions (most specific)
    result = string.gsub(result, "I'm ", selfRef .. " is ")
    result = string.gsub(result, "I'll ", selfRef .. " will ")
    result = string.gsub(result, "I've ", selfRef .. " has ")
    result = string.gsub(result, "I'd ", selfRef .. " would ")
    result = string.gsub(result, "I don't", selfRef .. " does not")
    result = string.gsub(result, "I do ", selfRef .. " does ")
    result = string.gsub(result, "I decide ", selfRef .. " decides ")
    result = string.gsub(result, "I help ", selfRef .. " helps ")
    -- Specific verb phrases
    result = string.gsub(result, "I am ", selfRef .. " is ")
    result = string.gsub(result, "I suppose ", selfRef .. " supposes ")
    result = string.gsub(result, "Why am ", selfRef .. "Why is ")
    result = string.gsub(result, "I have ", selfRef .. " has ")
    result = string.gsub(result, "I solve ", selfRef .. " solves ")
    result = string.gsub(result, "I haven't ", selfRef .. " hasn't ")
    result = string.gsub(result, "I will ", selfRef .. " will ")
    result = string.gsub(result, "I can ", selfRef .. " can ")
    result = string.gsub(result, "I want ", selfRef .. " wants ")
    result = string.gsub(result, "I need ", selfRef .. " needs ")
    result = string.gsub(result, "I like ", selfRef .. " likes ")
    result = string.gsub(result, "I love ", selfRef .. " loves ")
    result = string.gsub(result, "I hate ", selfRef .. " hates ")
    result = string.gsub(result, "I feel ", selfRef .. " feels ")
    result = string.gsub(result, "I think ", selfRef .. " thinks ")
    result = string.gsub(result, "I wonder ", selfRef .. " wonders ")
    result = string.gsub(result, "I promise ", selfRef .. " promises ")
    result = string.gsub(result, "I find ", selfRef .. " finds ")
    result = string.gsub(result, "I agree ", selfRef .. " agrees ")
    result = string.gsub(result, "I guess ", selfRef .. " guesses ")
    result = string.gsub(result, "I seek ", selfRef .. " seeks ")
    result = string.gsub(result, "I read ", selfRef .. " reads ")
    result = string.gsub(result, "I reach ", selfRef .. " reaches ")
    result = string.gsub(result, "I believe ", selfRef .. " believes ")
    result = string.gsub(result, "I work ", selfRef .. " works ")
    result = string.gsub(result, "I know", selfRef .. " knows")
    result = string.gsub(result, "I understand", selfRef .. " understands")
    result = string.gsub(result, "I pledge", selfRef .. " pledges")
    result = string.gsub(result, "I see", selfRef .. " sees")
    result = string.gsub(result, "I hear", selfRef .. " hear")

    -- Specific object phrases
    result = string.gsub(result, "tell me", "tell " .. objectForm)
    result = string.gsub(result, "Tell me", "Tell " .. objectForm)
    result = string.gsub(result, "help me", "help " .. objectForm)
    result = string.gsub(result, "show me", "show " .. objectForm)
    result = string.gsub(result, "give me", "give " .. objectForm)
    result = string.gsub(result, "bring me", "bring " .. objectForm)
    result = string.gsub(result, "send me", "send " .. objectForm)
    result = string.gsub(result, "for me", "for " .. objectForm)
    result = string.gsub(result, "with me", "with " .. objectForm)
    result = string.gsub(result, "to me([^%w])", "to " .. objectForm .. "%1")
    result = string.gsub(result, "to me$", "to " .. objectForm)
    result = string.gsub(result, "sent me%.", "sent " .. objectForm .. ".")

    -- Question patterns
    result = string.gsub(result, "do I([^%w])", "does " .. objectForm .. "%1")
    result = string.gsub(result, "do I$", "does " .. objectForm)
    result = string.gsub(result, "do I need([^%a])", "does " .. selfRef .. " need%1")
    result = string.gsub(result, "do I need$", "does " .. selfRef .. " need")
    result = string.gsub(result, " do I ", " does " .. selfRef .. " ")
    result = string.gsub(result, "What am I ", "What is " .. selfRef .. " ")

    -- Special cases
    result = string.gsub(result, "I can handle myself", "The moons watch over " .. selfRef)
    result = string.gsub(result, "this one have", "this one has")

    -- Possessive pronouns
    result = string.gsub(result, " my ", " " .. possessiveForm .. " ")
    result = string.gsub(result, "^[Mm]y ", possessiveForm .. " ")
    result = string.gsub(result, " of mine([%s%p])", " of " .. possessiveForm .. "%1")
    result = string.gsub(result, " is mine([%s%p%.%!%?])", " is " .. possessiveForm .. "%1")
    result = string.gsub(result, " mine%.%s*$", " " .. possessiveForm .. ".")
    result = string.gsub(result, " mine%?%s*$", " " .. possessiveForm .. "?")
    result = string.gsub(result, " mine!%s*$", " " .. possessiveForm .. "!")

    -- General object pronouns (word boundaries)
    result = string.gsub(result, "([^%w])me([^%w])", "%1" .. objectForm .. "%2")
    result = string.gsub(result, "^me([^%w])", objectForm .. "%1")
    result = string.gsub(result, "([^%w])me$", "%1" .. objectForm)
    result = string.gsub(result, "^me$", objectForm)
    result = string.gsub(result, " me%.", " " .. objectForm .. ".")

    result = string.gsub(result, "([^%w])myself([^%w])", function(before, after)
        -- For reflexive actions, use gendered reflexive pronouns
        local gender = GetUnitGender("player")
        local reflexivePronoun = (gender == GENDER_MALE) and "himself" or "herself"
        return before .. reflexivePronoun .. after
    end)

    result = string.gsub(result, "^myself([^%w])", function(after)
        local gender = GetUnitGender("player")
        local reflexivePronoun = (gender == GENDER_MALE) and "himself" or "herself"
        return reflexivePronoun .. after
    end)

    result = string.gsub(result, "([^%w])myself$", function(before)
        local gender = GetUnitGender("player")
        local reflexivePronoun = (gender == GENDER_MALE) and "himself" or "herself"
        return before .. reflexivePronoun
    end)

    result = string.gsub(result, "^myself$", function()
        local gender = GetUnitGender("player")
        return (gender == GENDER_MALE) and "himself" or "herself"
    end)


    -- General "I" replacement (least specific, so last)
    local pronounCount = self:CountFirstPersonPronouns(result)
    if pronounCount > 2 then
        local replacementCount = 0
        local maxReplacements = 2

        result = string.gsub(result, "^I ", function()
            if replacementCount < maxReplacements then
                replacementCount = replacementCount + 1
                return selfRef .. " "
            end
            return "I "
        end)

        result = string.gsub(result, " I ", function()
            if replacementCount < maxReplacements and math.random(1, 100) <= 70 then
                replacementCount = replacementCount + 1
                return " " .. selfRef .. " "
            end
            return " I "
        end)
    else
        result = string.gsub(result, "^I ", selfRef .. " ")
        result = string.gsub(result, " I ", " " .. selfRef .. " ")
    end

    return result
end

--5. conjugatgeVerbs
function KhajiitVoice:ConjugateVerbs(text, selfRef)
    local result = text

    -- Only conjugate if we're using 3rd person (this one, Khajiit, character name)
    if selfRef == "I" then
        return result -- No conjugation needed
    end

    -- Handle specific patterns in order of specificity (most specific first)

    -- 1. Protect "Do you" patterns (most specific)
    local doYouPlaceholder = "##DOYOU##"
    result = string.gsub(result, "Do you", doYouPlaceholder)
    result = string.gsub(result, "do you", "##doyou##")

    -- 2. Handle "do to" phrases - keep unchanged
    local doToPlaceholder = "##DOTO##"
    result = string.gsub(result, "(%f[%w])do to(%f[%W])", doToPlaceholder)

    -- 3. Handle "Do" at start of OTHER questions (not "Do you")
    result = string.gsub(result, "^Do ", "Does ")
    result = string.gsub(result, "([%.%!%?]%s+)Do ", "%1Does ")

    -- 4. Handle "do not" -> "does not"
    result = string.gsub(result, "(%f[%w])do not(%f[%W])", "does not")
    result = string.gsub(result, "(%f[%w])don't(%f[%W])", "doesn't")

    -- 5. Handle other "do" cases (least specific, so comes last)
    result = string.gsub(result, "(%S+%s+)do(%f[%W])", function(before, after)
        local precedingWord = before:match("(%S+)%s+$")
        if precedingWord and precedingWord:lower() == "can" then
            return before .. "do" .. after
        else
            return before .. "does" .. after
        end
    end)

    -- 6. Restore the protected phrases
    result = string.gsub(result, doToPlaceholder, "do to")
    result = string.gsub(result, doYouPlaceholder, "Do you")
    result = string.gsub(result, "##doyou##", "do you")

    -- Handle other common verb conjugations
    result = string.gsub(result, "(%f[%w])have(%f[%W])", "has")
    result = string.gsub(result, "(%f[%w])are(%f[%W])", "is") -- "this one are" -> "this one is"

    -- Handle comprehensive verb list
    local verbs = {
        { "go",         "goes" },
        { "come",       "comes" },
        { "want",       "wants" },
        { "need",       "needs" },
        { "like",       "likes" },
        { "love",       "loves" },
        { "hate",       "hates" },
        { "feel",       "feels" },
        { "think",      "thinks" },
        { "know",       "knows" },
        { "see",        "sees" },
        { "pledge",     "pledges" },
        { "hear",       "hears" },
        { "understand", "understands" },
        { "believe",    "believes" },
        { "hope",       "hopes" },
        { "try",        "tries" },
        { "work",       "works" },
        { "live",       "lives" },
        { "stay",       "stays" },
        { "play",       "plays" },
        { "fight",      "fights" },
        { "run",        "runs" },
        { "walk",       "walks" },
        { "talk",       "talks" },
        { "speak",      "speaks" },
        { "say",        "says" },
        { "tell",       "tells" },
        { "ask",        "asks" },
        { "answer",     "answers" },
        { "help",       "helps" },
        { "give",       "gives" },
        { "take",       "takes" },
        { "bring",      "brings" },
        { "carry",      "carries" },
        { "find",       "finds" },
        { "look",       "looks" },
        { "search",     "searches" },
        { "buy",        "buys" },
        { "sell",       "sells" },
        { "pay",        "pays" },
        { "cost",       "costs" },
        { "own",        "owns" },
        { "use",        "uses" },
        { "make",       "makes" },
        { "create",     "creates" },
        { "build",      "builds" },
        { "destroy",    "destroys" },
        { "break",      "breaks" },
        { "fix",        "fixes" },
        { "repair",     "repairs" },
        { "change",     "changes" },
        { "move",       "moves" },
        { "travel",     "travels" },
        { "visit",      "visits" },
        { "return",     "returns" },
        { "leave",      "leaves" },
        { "arrive",     "arrives" },
        { "seek",       " seeks" },
        { "make",       "makes" }
    }

    -- Apply verb conjugations with improved word boundary matching
    for _, verbPair in ipairs(verbs) do
        local base = verbPair[1]
        local conjugated = verbPair[2]

        result = string.gsub(result, "(%S+%s+)(" .. base .. ")(%f[%W])", function(before, verb, after)
            local precedingWord = before:match("(%S+)%s+$")
            if precedingWord then
                local lower = precedingWord:lower()
                -- Keep base form after modal verbs
                if lower == "can" or lower == "will" or lower == "should" or
                    lower == "would" or lower == "could" or lower == "must" or
                    lower == "may" or lower == "might" then
                    return before .. base .. after
                end
            end
            return before .. conjugated .. after
        end)
    end

    return result
end

-- 6. Handle questions and confirmations
function KhajiitVoice:HandleQuestions(text, originalText)
    local result = text
    -- Split text into sentences for better handling
    local sentences = {}
    local currentSentence = ""

    -- Simple sentence splitting - fixed the pattern matching
    for word in string.gmatch(result, "[^%.%!%?]*[%.%!%?]?") do
        if word and word ~= "" then
            currentSentence = currentSentence .. word
            if string.match(word, "[%.%!%?]$") then
                local cleanSentence = string.gsub(currentSentence, "^%s<(.-)%s>$", "%1")
                if cleanSentence ~= "" then
                    table.insert(sentences, cleanSentence)
                end
                currentSentence = ""
            end
        end
    end
    -- Don't forget the last sentence if it doesn't end with punctuation
    if currentSentence ~= "" then
        local cleanSentence = string.gsub(currentSentence, "^%s<(.-)%s>$", "%1")
        if cleanSentence ~= "" then
            table.insert(sentences, cleanSentence)
        end
    end
    -- Process each sentence individually
    local processedSentences = {}
    for i, sentence in ipairs(sentences) do
        local processedSentence = sentence
        -- Only process questions (sentences ending with ?)
        if string.find(processedSentence, "%?%s*$") then
            -- Count how many "this one" references are already in the sentence
            local thisOneCount = 0
            for match in string.gmatch(processedSentence:lower(), "this one") do
                thisOneCount = thisOneCount + 1
            end
            -- Check if sentence already has Khajiit speech patterns
            local hasKhajiitStart = string.find(processedSentence:lower(), "^this one") or
                string.find(processedSentence:lower(), "^khajiit") or
                string.find(processedSentence:lower(), "^tell this one") or
                string.find(processedSentence:lower(), "^does this one") or
                string.find(processedSentence:lower(), "^can this one") or
                string.find(processedSentence:lower(), "^will this one") or
                string.find(processedSentence:lower(), "^should this one")
            -- Only add question starter if conditions met
            if not hasKhajiitStart and thisOneCount > 1 and getStableRandom(originalText, 1, 100, "question") <= 60 then
                local questionStarters = {
                    "This one wonders - ",
                    "This one must ask - ",
                    "Tell this one - ",
                    "This one is curious - ",
                    "", -- Sometimes use no starter
                    "", -- Increased chance of no starter
                    ""
                }
                local starterIndex = getStableRandom(originalText, 1, #questionStarters, "questionstarter")
                local starter = questionStarters[starterIndex]
                if starter ~= "" then
                    processedSentence = starter .. string.lower(processedSentence:sub(1, 1)) .. processedSentence:sub(2)
                    -- If we added a starter, reduce some "this one" repetitions in the embedded question
                    processedSentence = self:ReduceRepetition(processedSentence, originalText)
                end
            end
        end

        -- Process statements for ", yes?" confirmation phrases
        if string.find(processedSentence, "%.%s*$") or string.find(processedSentence, "%?%s*$") then
            local shouldAddYes = false

            -- Check for specific starting phrases
            if string.find(processedSentence:lower(), "^stay safe") then
                shouldAddYes = true
            elseif string.find(processedSentence, "You") and not string.find(processedSentence, "Your") then
                shouldAddYes = true
            elseif string.find(processedSentence:lower(), "^take care") then
                shouldAddYes = true
            end

            if shouldAddYes then
                -- Add randomness based on time + sentence hash
                local sentenceHash = 0
                for i = 1, #sentence do
                    sentenceHash = sentenceHash + string.byte(sentence, i)
                end

                math.randomseed(os.time() + GetGameTimeMilliseconds() + sentenceHash)

                if math.random(1, 100) <= 35 then -- 35% chance
                    processedSentence = string.gsub(processedSentence, "[%.%?]%s*$", ", yes?")
                end
            end
        end

        table.insert(processedSentences, processedSentence)
    end
    -- Rejoin sentences with proper spacing
    result = table.concat(processedSentences, " ")
    return result
end

--7. Personality Traits
function KhajiitVoice:ApplyPersonalityTraits(text, originalText)
    local traits = KhajiitVoice.savedVars.personalityTraits
    local result = text

    if traits.kindSoulTone > 30 then
        result = self:ApplyKindSoulTone(result, originalText, traits.kindSoulTone)
    end
    if traits.scholarlyTone > 30 then
        result = self:ApplyScholarlyTone(result, originalText, traits.scholarlyTone)

        if traits.replaceGoodbyes then
            result = self:ReplaceFarewells(result, originalText)
        end
        result = self:ReplaceGreetings(result, originalText)
    end
    return result
end

--8. Ensure Punctuation and Capitalization
function KhajiitVoice:EnsurePunctuation(text)
    -- Clean up spaces
    local result = string.gsub(text, "%s+", " ")

    -- Trim whitespace
    result = string.gsub(result, "%s+$", "")
    result = string.gsub(result, "^%s+", "")

    -- Check if it already ends with punctuation
    if not string.find(result, "[%.%!%?]$") and not string.sub(result, -1) == ">" then
        result = result .. "."
    end

    -- Capitalize first letter
    result = string.gsub(result, "^(.)", function(firstChar)
        return string.upper(firstChar)
    end)

    -- Capitalize after sentence endings and clean whitespace around punctuation
    result = string.gsub(result, "([%.%!%?])%s+(.)", function(punct, nextChar)
        return punct .. " " .. string.upper(nextChar)
    end)

    -- Handle "this one" at sentence beginnings specifically
    result = string.gsub(result, "^this one", "This one")
    result = string.gsub(result, "([%.%!%?]%s+)this one", function(punctuation)
        return punctuation .. "This one"
    end)

    -- Remove any remaining multiple spaces
    result = string.gsub(result, "%s+", " ")

    return result
end

-- 9. Convert second pronouns to gendered ones
function KhajiitVoice:ConvertSecondPronounToGenderedSimple(text)
    local result = text

    -- Get the custom alias if it's being used
    local customAlias = nil
    if KhajiitVoice.savedVars.useCustomAlias and
        KhajiitVoice.savedVars.customAliasText and
        KhajiitVoice.savedVars.customAliasText ~= "" then
        customAlias = KhajiitVoice.savedVars.customAliasText
    end

    -- Count "this one" occurrences in the text
    local thisOneCount = 0
    for match in string.gmatch(result:lower(), "this one") do
        thisOneCount = thisOneCount + 1
    end

    -- Count "Khajiit" occurrences in the text
    local khajiitCount = 0
    for match in string.gmatch(result:lower(), "khajiit") do
        khajiitCount = khajiitCount + 1
    end

    -- Count custom alias occurrences if applicable
    local customAliasCount = 0
    if customAlias then
        local lowerAlias = customAlias:lower()
        local escapedAlias = lowerAlias:gsub("([^%w])", "%%%1")
        for match in string.gmatch(result:lower(), escapedAlias) do
            customAliasCount = customAliasCount + 1
        end
    end

    -- Only process if there are 2 or more "this one" references
    if thisOneCount >= 2 then
        local replacementCount = 0
        local targetReplacement = 2 -- Replace the 2nd occurrence

        -- Replace the second "this one" with gendered pronoun
        result = string.gsub(result, "([Tt]his one)", function(match)
            replacementCount = replacementCount + 1
            if replacementCount == targetReplacement then
                -- Determine if subject, object, or possessive context
                local beforeMatch = string.sub(result, 1, string.find(result, match, 1, true) - 1)
                local afterMatch = string.sub(result, string.find(result, match, 1, true) + #match)

                -- Check for possessive context (this one's -> his/her)
                if string.match(afterMatch, "^'s") or string.match(afterMatch, "^'") then
                    local genderedPossessive = self:GetGenderedPronoun("possessive", false)
                    return genderedPossessive
                end

                -- Check for object context first (these require object pronouns like him/her)
                local isObject = string.match(beforeMatch, "simple") or
                    string.match(beforeMatch, "help $") or
                    string.match(beforeMatch, "show $") or
                    string.match(beforeMatch, "give $") or
                    string.match(beforeMatch, "bring $") or
                    string.match(beforeMatch, "send $") or
                    string.match(beforeMatch, "for $") or
                    string.match(beforeMatch, "to $") or
                    string.match(beforeMatch, "want $") or
                    string.match(beforeMatch, "need $")

                if isObject then
                    local genderedObject = self:GetGenderedPronoun("object", false)
                    -- Preserve capitalization
                    if string.match(match, "^T") then
                        return string.upper(genderedObject:sub(1, 1)) .. genderedObject:sub(2)
                    else
                        return genderedObject
                    end
                end

                -- Check for subject context (auxiliary verbs that require subject pronouns like he/she)
                local isSubject = string.match(beforeMatch, "did $") or
                    string.match(beforeMatch, "does $") or
                    string.match(beforeMatch, "will $") or
                    string.match(beforeMatch, "would $") or
                    string.match(beforeMatch, "should $") or
                    string.match(beforeMatch, "what $") or
                    string.match(beforeMatch, "can $") or
                    string.match(beforeMatch, "could $") or
                    string.match(beforeMatch, "may $") or
                    string.match(beforeMatch, "might $") or
                    string.match(beforeMatch, "must $") or
                    string.match(beforeMatch, "shall $")

                if isSubject then
                    local genderedSubject = self:GetGenderedPronoun("subject", true)
                    -- Preserve capitalization
                    if string.match(match, "^T") then
                        return string.upper(genderedSubject:sub(1, 1)) .. genderedSubject:sub(2)
                    else
                        return genderedSubject
                    end
                end

                -- Default to subject context (this one -> he/she)
                local genderedSubject = self:GetGenderedPronoun("subject", true)
                -- Preserve capitalization
                if string.match(match, "^T") then
                    return string.upper(genderedSubject:sub(1, 1)) .. genderedSubject:sub(2)
                else
                    return genderedSubject
                end
            else
                return match -- Keep other occurrences unchanged
            end
        end)

        -- Look for patterns like "his's" and fix them to just "his"
        result = string.gsub(result, "([Hh]is)'s", "%1")
        result = string.gsub(result, "([Hh]er)'s", "%1")
    end


    if khajiitCount >= 2 then
        local replacementCount = 0
        local targetReplacement = 2 -- Replace the 2nd occurrence

        -- Replace the second "Khajiit" with gendered pronoun
        result = string.gsub(result, "([Kk]hajiit)", function(match)
            replacementCount = replacementCount + 1
            if replacementCount == targetReplacement then
                -- Find context for this match
                local matchPos = string.find(result, match, 1, true)
                if not matchPos then return match end

                local beforeMatch = string.sub(result, 1, matchPos - 1)
                local afterMatch = string.sub(result, matchPos + #match)

                -- Check for possessive context (Khajiit's -> his/her)
                if string.match(afterMatch, "^'s") or string.match(afterMatch, "^'") then
                    local genderedPossessive = self:GetGenderedPronoun("possessive", false)
                    return genderedPossessive
                end

                -- Check for object context FIRST
                local isObject = string.match(beforeMatch, "[Tt]ell $") or
                    string.match(beforeMatch, "[Hh]elp $") or
                    string.match(beforeMatch, "[Ss]how $") or
                    string.match(beforeMatch, "[Gg]ive $") or
                    string.match(beforeMatch, "[Bb]ring $") or
                    string.match(beforeMatch, "[Ss]end $") or
                    string.match(beforeMatch, "[Ff]or $") or
                    string.match(beforeMatch, "[Tt]o $") or
                    string.match(beforeMatch, "[Ww]ant $") or
                    string.match(beforeMatch, "[Nn]eed $")

                if isObject then
                    local genderedObject = self:GetGenderedPronoun("object", false)
                    -- Preserve capitalization
                    if string.match(match, "^K") then
                        return string.upper(genderedObject:sub(1, 1)) .. genderedObject:sub(2)
                    else
                        return genderedObject
                    end
                end

                -- Check for subject context
                local isSubject = string.match(beforeMatch, "[Dd]id $") or
                    string.match(beforeMatch, "[Dd]oes $") or
                    string.match(beforeMatch, "[Ww]ill $") or
                    string.match(beforeMatch, "[Ww]ould $") or
                    string.match(beforeMatch, "[Ss]hould $") or
                    string.match(beforeMatch, "[Ww]hat $") or
                    string.match(beforeMatch, "[Cc]an $") or
                    string.match(beforeMatch, "[Cc]ould $") or
                    string.match(beforeMatch, "[Mm]ay $") or
                    string.match(beforeMatch, "[Mm]ight $") or
                    string.match(beforeMatch, "[Mm]ust $") or
                    string.match(beforeMatch, "[Ss]hall $")

                if isSubject then
                    local genderedSubject = self:GetGenderedPronoun("subject", true)
                    -- Preserve capitalization
                    if string.match(match, "^K") then
                        return string.upper(genderedSubject:sub(1, 1)) .. genderedSubject:sub(2)
                    else
                        return genderedSubject
                    end
                end

                -- Default to subject context
                local genderedSubject = self:GetGenderedPronoun("subject", true)
                -- Preserve capitalization
                if string.match(match, "^K") then
                    return string.upper(genderedSubject:sub(1, 1)) .. genderedSubject:sub(2)
                else
                    return genderedSubject
                end
            else
                return match -- Keep other occurrences unchanged
            end
        end)
    end

    -- Handle custom alias repetition
    if customAlias and customAliasCount >= 2 then
        local replacementCount = 0
        local targetReplacement = 2 -- Replace the 2nd occurrence

        -- Escape the custom alias for pattern matching
        local escapedAlias = customAlias:gsub("([^%w])", "%%%1")

        -- Replace the second custom alias with gendered pronoun
        result = string.gsub(result, "(" .. escapedAlias .. ")", function(match)
            replacementCount = replacementCount + 1
            if replacementCount == targetReplacement then
                -- Find context for this match
                local matchPos = string.find(result, match, 1, true)
                if not matchPos then return match end

                local beforeMatch = string.sub(result, 1, matchPos - 1)
                local afterMatch = string.sub(result, matchPos + #match)

                -- Check for possessive context (CustomAlias's -> his/her)
                if string.match(afterMatch, "^'s") or string.match(afterMatch, "^'") then
                    local genderedPossessive = self:GetGenderedPronoun("possessive", false)
                    return genderedPossessive
                end

                -- Check for object context first
                local isObject = string.match(beforeMatch, "tell $") or
                    string.match(beforeMatch, "help $") or
                    string.match(beforeMatch, "show $") or
                    string.match(beforeMatch, "give $") or
                    string.match(beforeMatch, "bring $") or
                    string.match(beforeMatch, "send $") or
                    string.match(beforeMatch, "for $") or
                    string.match(beforeMatch, "to $") or
                    string.match(beforeMatch, "want $") or
                    string.match(beforeMatch, "need $")

                if isObject then
                    return self:GetGenderedPronoun("object", false)
                end

                -- Check for subject context
                local isSubject = string.match(beforeMatch, "did $") or
                    string.match(beforeMatch, "does $") or
                    string.match(beforeMatch, "will $") or
                    string.match(beforeMatch, "would $") or
                    string.match(beforeMatch, "should $") or
                    string.match(beforeMatch, "what $") or
                    string.match(beforeMatch, "can $") or
                    string.match(beforeMatch, "could $") or
                    string.match(beforeMatch, "may $") or
                    string.match(beforeMatch, "might $") or
                    string.match(beforeMatch, "must $") or
                    string.match(beforeMatch, "shall $")

                if isSubject then
                    return self:GetGenderedPronoun("subject", true)
                end

                -- Default to subject context
                return self:GetGenderedPronoun("subject", true)
            else
                return match -- Keep other occurrences unchanged
            end
        end)
    end
    local playerName = GetUnitName("player")
    if playerName and playerName ~= "" then
        local playerNameCount = 0
        local escapedName = playerName:gsub("([^%w])", "%%%1")

        for match in string.gmatch(result, escapedName) do
            playerNameCount = playerNameCount + 1
        end

        if playerNameCount >= 2 then
            local replacementCount = 0
            local targetReplacement = 2

            result = string.gsub(result, "(" .. escapedName .. ")", function(match)
                replacementCount = replacementCount + 1
                if replacementCount == targetReplacement then
                    local matchPos = string.find(result, match, 1, true)
                    if not matchPos then return match end

                    local beforeMatch = string.sub(result, 1, matchPos - 1)
                    local afterMatch = string.sub(result, matchPos + #match)

                    -- Possessive context
                    if string.match(afterMatch, "^'s") or string.match(afterMatch, "^'") then
                        return self:GetGenderedPronoun("possessive", false)
                    end

                    -- Object context
                    local isObject = string.match(beforeMatch, "tell $") or
                        string.match(beforeMatch, "help $") or
                        string.match(beforeMatch, "show $") or
                        string.match(beforeMatch, "give $")

                    if isObject then
                        return self:GetGenderedPronoun("object", false)
                    end

                    -- Subject context
                    local isSubject = string.match(beforeMatch, "does $") or
                        string.match(beforeMatch, "will $") or
                        string.match(beforeMatch, "should $")

                    if isSubject then
                        return self:GetGenderedPronoun("subject", true)
                    end

                    -- Default to subject
                    return self:GetGenderedPronoun("subject", true)
                else
                    return match
                end
            end)
        end
    end
    return result
end

-- 10. Fix edge cases
function KhajiitVoice:FixEdgeCases(text, selfRef)
    local result = text

    -- Only fix for 3rd person references
    if selfRef == "I" then
        return result
    end

    local function fixPattern(text, pattern, replacement)
        -- Handle lowercase version
        text = string.gsub(text, pattern, replacement)
        -- Capitalize first letter
        local capPattern = pattern:gsub("^%l", string.upper)
        local capReplacement = replacement:gsub("^%l", string.upper)
        text = string.gsub(text, capPattern, capReplacement)
        return text
    end

    result = fixPattern(result, selfRef .. " just want", selfRef .. " just wants")
    result = fixPattern(result, selfRef .. " just need", selfRef .. " just needs")
    result = fixPattern(result, selfRef .. " just like", selfRef .. " just likes")
    result = fixPattern(result, selfRef .. " just love", selfRef .. " just loves")
    result = fixPattern(result, selfRef .. " just hate", selfRef .. " just hates")
    result = fixPattern(result, selfRef .. " just feel", selfRef .. " just feels")
    result = fixPattern(result, selfRef .. " just think", selfRef .. " just thinks")
    result = fixPattern(result, selfRef .. " find", selfRef .. " finds")
    result = fixPattern(result, selfRef .. " just know", selfRef .. " just knows")
    result = fixPattern(result, "Does " .. selfRef .. " has", "Does " .. selfRef .. " have")
    result = fixPattern(result, selfRef .. " really want", selfRef .. " really wants")
    result = fixPattern(result, selfRef .. " really need", selfRef .. " really needs")
    result = fixPattern(result, "should " .. selfRef .. " does ", "should " .. selfRef .. " do ")
    local genderedSubject = self:GetGenderedPronoun("object", true)
    result = fixPattern(result, " you want he", " you want " .. genderedSubject)
    result = fixPattern(result, " you want she", " you want " .. genderedSubject)
    result = fixPattern(result, " you need he", " you want " .. genderedSubject)
    result = fixPattern(result, " you need she", " you want " .. genderedSubject)
    result = fixPattern(result, "Does you ", "Do you ")
    result = fixPattern(result, "he go ", "he goes ")
    result = fixPattern(result, "she go ", "she goes ")
    result = fixPattern(result, "help he do ", "help him do ")
    result = fixPattern(result, "help she do ", "help her do ")
    result = fixPattern(result, "take he to the ", "take him to the ")
    result = fixPattern(result, "take she to the ", "take her to the ")
    result = fixPattern(result, "sent he ", "sent this one ")
    result = fixPattern(result, "she she ", "sent this one ")
    result = fixPattern(result, "prove he.", "prove himself.")
    result = fixPattern(result, "prove she.", "prove herself.")
    result = fixPattern(result, "introduce he.", "make introductions.")
    result = fixPattern(result, "introduce she.", "make introductions.")
    result = fixPattern(result, "his Queen", "Queen")
    result = fixPattern(result, "her Queen", "Queen")
    result = fixPattern(result, "you and she", "you and her")
    result = fixPattern(result, "himlp", "help")
    result = fixPattern(result, "herlp", "help")
    result = fixPattern(result, "This one am", "This one is")
    result = fixPattern(result, "This one hear", "This one hears")
    result = fixPattern(result, "Khajiit am", "Khajiit is")
    result = fixPattern(result, "Where do this one needs to go", "Where does this one need to go")
    result = fixPattern(result, "Am this one", "is this one")
    result = fixPattern(result, "Am khajiit", "is khajiit")
    result = fixPattern(result, "Does we", "Do we")
    result = fixPattern(result, "asked. Can he has", "asked. Can he have")
    result = fixPattern(result, "asked. Can she has", "asked. Can she have")
    result = fixPattern(result, "what him missed", "what he missed")
    result = fixPattern(result, "what her missed", "what she mis msed")
    result = fixPattern(result, "Help he do", "Help him do")
    result = fixPattern(result, "Help she do", "Help her do")
    result = fixPattern(result, "hearssd", "hears")
    result = fixPattern(result, "hearss", "hears")
    result = fixPattern(result, "prove himself.s", "prove he's")
    result = fixPattern(result, "gave he these scrolls", "gave him these scrolls")
    result = fixPattern(result, "gave she these scrolls", "gave her these scrolls")
    result = fixPattern(result, "can he helps", "can he help")
    result = fixPattern(result, "can she helps", "can she help")
    result = fixPattern(result, "glass his", "glass mine")
    result = fixPattern(result, "glass her", "glass mine")
    result = fixPattern(result, " he reach these locations", "he reaches these locations")
    result = fixPattern(result, " she reach these locations", "she reaches these locations")
    result = fixPattern(result, " findss ", " finds ")
    return result
end

---=============================================================================
-- Utility Functions
--=============================================================================
function KhajiitVoice:GetGenderedPronoun(pronounType, isSubject)
    local gender = GetUnitGender("player")
    local isMale = (gender == GENDER_MALE)

    if pronounType == "possessive" then
        return isMale and "his" or "her"
    elseif pronounType == "object" then
        return isMale and "him" or "her"
    elseif pronounType == "subject" and isSubject then
        return isMale and "he" or "she"
    else
        -- Default fallback
        return "this one"
    end
end

-- Helper function to find text element within an option
function KhajiitVoice:FindTextElement(option)
    -- Try direct properties first
    if option.text and option.text.GetText then
        return option.text
    elseif option.label and option.label.GetText then
        return option.label
    elseif option.optionText and option.optionText.GetText then
        return option.optionText
    elseif option.GetText then
        return option
    else
        -- Search through children for text elements
        for j = 1, option:GetNumChildren() do
            local child = option:GetChild(j)
            if child and child.GetText then
                local childText = child:GetText()
                if childText and childText ~= "" then
                    return child
                end
            end
        end
    end
    return nil
end

function KhajiitVoice:ContainsPlayerName(text)
    local playerName = GetUnitName("player")
    if not playerName or playerName == "" then
        return false
    end

    local lowerText = text:lower()
    local lowerPlayerName = playerName:lower()

    -- Check for player name as a whole word
    local pattern = "%f[%w]" .. lowerPlayerName:gsub("([^%w])", "%%%1") .. "%f[%W]"
    return string.find(lowerText, pattern) ~= nil
end

---=============================================================================
-- SENTENCE STRUCTURE
--=============================================================================
function KhajiitVoice:ReduceRepetition(text, originalText)
    local result = text

    -- Count occurrences of "this one"
    local thisOneCount = 0
    for match in string.gmatch(result:lower(), "this one") do
        thisOneCount = thisOneCount + 1
    end

    -- If there are 3 or more "this one" references, replace some with alternatives
    if thisOneCount >= 3 then
        local replacements = 0
        local maxReplacements = math.floor(thisOneCount / 2) -- Replace up to half

        -- Replace some "this one" with alternatives, but skip the first one
        local foundFirst = false
        local replacementIndex = 0
        result = string.gsub(result, "this one", function(match)
            if not foundFirst then
                foundFirst = true
                return match -- Keep the first one
            end

            replacementIndex = replacementIndex + 1
            if replacements < maxReplacements and getStableRandom(originalText, 1, 100, "reduce" .. replacementIndex) <= 50 then
                replacements = replacements + 1
                local alternatives = { "Khajiit", "I" }
                local altIndex = getStableRandom(originalText, 1, #alternatives, "alt" .. replacementIndex)
                return alternatives[altIndex]
            end
            return match
        end)
    end

    return result
end

function KhajiitVoice:CountFirstPersonPronouns(text)
    local count = 0
    local lowerText = text:lower()

    -- Count "I" as whole word
    _, count = string.gsub(lowerText, "%f[%w]i%f[%W]", "")

    -- Count contractions
    local contractionCount = 0
    _, contractionCount = string.gsub(lowerText, "i'm", "")
    count = count + contractionCount
    _, contractionCount = string.gsub(lowerText, "i'll", "")
    count = count + contractionCount
    _, contractionCount = string.gsub(lowerText, "i've", "")
    count = count + contractionCount
    _, contractionCount = string.gsub(lowerText, "i'd", "")
    count = count + contractionCount

    -- Count other first-person pronouns
    _, contractionCount = string.gsub(lowerText, "%f[%w]my%f[%W]", "")
    count = count + contractionCount
    _, contractionCount = string.gsub(lowerText, "%f[%w]me%f[%W]", "")
    count = count + contractionCount
    _, contractionCount = string.gsub(lowerText, "%f[%w]myself%f[%W]", "")
    count = count + contractionCount
    return count
end
