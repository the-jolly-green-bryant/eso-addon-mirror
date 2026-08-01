-- Ukrainian Adjectives Module for DovahMova
-- Handles declension of Ukrainian adjectives with ^a tag based on noun gender

local AdjectivesModule = {}

-- Helper function to work with UTF-8 strings
local function utf8_len(str)
    local _, count = string.gsub(str, "[^\128-\193]", "")
    return count
end

local function utf8_sub(str, start_pos, end_pos)
    local len = utf8_len(str)
    local byte_start = 1
    local byte_end = #str
    local char_count = 0
    
    -- Find start byte position
    if start_pos > 0 then
        for pos = 1, #str do
            if string.match(str, "^[^\128-\193]", pos) then
                char_count = char_count + 1
                if char_count == start_pos then
                    byte_start = pos
                    break
                end
            end
        end
    elseif start_pos < 0 then
        -- Handle negative indices (from end)
        start_pos = len + start_pos + 1
        for pos = 1, #str do
            if string.match(str, "^[^\128-\193]", pos) then
                char_count = char_count + 1
                if char_count == start_pos then
                    byte_start = pos
                    break
                end
            end
        end
    end
    
    -- Find end byte position
    if end_pos then
        char_count = 0
        if end_pos > 0 then
            for pos = 1, #str do
                if string.match(str, "^[^\128-\193]", pos) then
                    char_count = char_count + 1
                    if char_count == end_pos then
                        -- Find the end of this character
                        local next_pos = pos + 1
                        while next_pos <= #str and not string.match(str, "^[^\128-\193]", next_pos) do
                            next_pos = next_pos + 1
                        end
                        byte_end = next_pos - 1
                        break
                    end
                end
            end
        elseif end_pos < 0 then
            -- Handle negative indices
            end_pos = len + end_pos + 1
            for pos = 1, #str do
                if string.match(str, "^[^\128-\193]", pos) then
                    char_count = char_count + 1
                    if char_count == end_pos then
                        -- Find the end of this character
                        local next_pos = pos + 1
                        while next_pos <= #str and not string.match(str, "^[^\128-\193]", next_pos) do
                            next_pos = next_pos + 1
                        end
                        byte_end = next_pos - 1
                        break
                    end
                end
            end
        end
    end
    
    return string.sub(str, byte_start, byte_end)
end

-- Function to decline Ukrainian adjectives based on gender
-- @param adj: adjective string (without ^a tag)
-- @param gender: gender code (m, f, n, p)
-- @return: declined adjective
function AdjectivesModule.DeclineAdjective(adj, gender)
    if not adj or adj == "" then
        return adj
    end
    
    -- Default to masculine if gender is unknown or masculine
    if not gender or gender == "m" then
        return adj
    end
    
    -- Check if adjective ends with -ий or -ній
    -- Using pattern matching which works better with UTF-8
    if string.match(adj, "ий$") then
        -- Remove last 2 characters and add appropriate ending
        local stem = string.gsub(adj, "ий$", "")
        
        if gender == "f" then
            return stem .. "а"
        elseif gender == "n" then
            return stem .. "е"
        elseif gender == "p" then
            return stem .. "і"
        end
    elseif string.match(adj, "ій$") then
        -- Remove last 2 characters and add appropriate ending
        local stem = string.gsub(adj, "ій$", "")
        
        if gender == "f" then
            return stem .. "я"
        elseif gender == "n" then
            return stem .. "є"
        elseif gender == "p" then
            return stem .. "і"
        end
    end
    
    -- Return unchanged if no matching pattern
    return adj
end

-- Function to process a string containing adjective^a and noun^gender tags
-- @param text: input string with tags
-- @return: processed string with properly declined adjectives
function AdjectivesModule.ProcessTaggedString(text)
    if not text or text == "" then
        return text
    end
    
    -- WORKAROUND: Fix ESO client UTF-8 corruption for DLC/extension motif items
    -- The client corrupts stems like "рубед" → "� убед", "рубедогарт" → "� убедогарт", etc.
    -- Use flexible patterns to handle any endings after the corrupted stem
    text = string.gsub(text, "^� убедогарт", "рубедогарт")   -- рубедогартований → � убедогартований
    text = string.gsub(text, "^� убіноясенев", "рубіноясенев") -- рубіноясеневий → � убіноясеневий  
    text = string.gsub(text, "^� убед", "рубед")             -- рубедітовий → � убедітовий
    -- Generic fallback for any other "руб*" words
    text = string.gsub(text, "^� уб", "руб")
    
    local debugMode = false -- Set to true for debug output
    if debugMode then
        d(string.format("ADJ-DEBUG: Processing: '%s'", text))
    end
    
    
    -- Pattern to find adjective^a or ^а followed by noun with gender tag
    -- This will match patterns like "сталевий^a булава^f" or "стальний^а булава^f"
    -- Using UTF-8 compatible patterns
    local pattern_latin = "([^%s]+)%^a%s+([^%s]+)%^([fmnp])"
    local pattern_cyrillic = "([^%s]+)%^а%s+([^%s]+)%^([fmnp])"
    
    -- Also try pattern without adjective tag but with space between words
    -- This matches patterns like "стальний булава^f" or "стальний булава^f (Mace)"
    -- Using (.-) to capture everything after gender tag and better UTF-8 compatible patterns
    local pattern_no_tag = "([^%s]+ий)%s+([^%s]+)%^([fmnp])(.-)"
    local pattern_no_tag_ij = "([^%s]+ій)%s+([^%s]+)%^([fmnp])(.-)"
    
    -- Try Latin 'a' pattern first
    local result = string.gsub(text, pattern_latin, function(adj, noun, gender)
        local declinedAdj = AdjectivesModule.DeclineAdjective(adj, gender)
        return declinedAdj .. " " .. noun
    end)
    
    -- If we found a match, clean up and return
    if result ~= text then
        result = string.gsub(result, "%^[aаfmnp]", "")
        return result
    end
    
    -- Try Cyrillic 'а' pattern
    result = string.gsub(text, pattern_cyrillic, function(adj, noun, gender)
        local declinedAdj = AdjectivesModule.DeclineAdjective(adj, gender)
        return declinedAdj .. " " .. noun
    end)
    
    -- If we found a match, clean up and return
    if result ~= text then
        result = string.gsub(result, "%^[aаfmnp]", "")
        return result
    end
    
    -- If no matches with ^a/^а tag, try patterns without tag
    if result == text then
        -- Look for gender tag at the end
        local beforeGender, gender, afterGender = string.match(text, "^(.-)%^([fmnp])(.*)$")
        
        if beforeGender and gender then
            -- Split text into words and process each word
            local words = {}
            for word in string.gmatch(beforeGender, "[^%s]+") do
                -- WORKAROUND: Repair corruption that happens during string splitting
                -- The word "Рубедітовий" gets split incorrectly into "�" + "убедітовий"
                -- We need to reconstruct it here
                -- Check for corrupted fragments (various forms of replacement character)
                if word == "�" or word == "?" or string.byte(word, 1) == 239 or string.len(word) == 1 and string.byte(word, 1) > 127 then
                    -- Skip this corrupted fragment completely - don't add it to words
                    if debugMode then
                        d(string.format("ADJ-DEBUG: Skipping corrupted fragment: '%s'", word))
                    end
                    -- Continue to next iteration without adding anything to words array
                elseif word == "убедітовий" or word == "убедогартований" or word == "убіноясеневий" then
                    -- This is the second part of a corrupted word - reconstruct the full word
                    local repairedWord = string.gsub(word, "^уб", "руб") -- Replace "уб" at start with "руб"
                    if debugMode then
                        d(string.format("ADJ-DEBUG: Repairing corrupted word: '%s' → '%s'", word, repairedWord))
                    end
                    
                    -- Check if repaired word is an adjective and decline it
                    if string.match(repairedWord, "ий$") or string.match(repairedWord, "ій$") then
                        if debugMode then
                            d(string.format("ADJ-DEBUG: Declining repaired word '%s' with gender '%s'", repairedWord, gender))
                        end
                        local declinedWord = AdjectivesModule.DeclineAdjective(repairedWord, gender)
                        if debugMode then
                            d(string.format("ADJ-DEBUG: Declined '%s' → '%s'", repairedWord, declinedWord))
                        end
                        table.insert(words, declinedWord)
                    else
                        table.insert(words, repairedWord)
                    end
                -- Normal processing for non-corrupted words
                elseif string.match(word, "ий$") or string.match(word, "ій$") then
                    if debugMode then
                        d(string.format("ADJ-DEBUG: Declining word '%s' with gender '%s'", word, gender))
                    end
                    local declinedWord = AdjectivesModule.DeclineAdjective(word, gender)
                    if debugMode then
                        d(string.format("ADJ-DEBUG: Declined '%s' → '%s'", word, declinedWord))
                    end
                    table.insert(words, declinedWord)
                else
                    if debugMode then
                        d(string.format("ADJ-DEBUG: Keeping word unchanged: '%s'", word))
                    end
                    table.insert(words, word)
                end
            end
            
            -- Reconstruct the string
            result = table.concat(words, " ")
            if debugMode then
                d(string.format("ADJ-DEBUG: After reconstruction: '%s'", result))
            end
            
            -- Add back the trailing text (if any)
            result = result .. afterGender
            if debugMode then
                d(string.format("ADJ-DEBUG: After adding trailing text: '%s'", result))
            end
            
            -- Remove all tags and return
            result = string.gsub(result, "%^[aаfmnp]", "")
            if debugMode then
                d(string.format("ADJ-DEBUG: After removing tags: '%s'", result))
            end
            return result
        else
            -- No gender tag found at all
            result = text
        end
    end
    
    -- Also handle cases where there might be multiple words between tags
    -- Pattern for "adjective^a/^а ... noun^gender"
    -- Skip this for now as it's causing issues
    
    -- Remove remaining ^a/^а tags from adjectives that weren't followed by gendered nouns
    result = string.gsub(result, "%^[aа]", "")
    
    -- Remove gender tags from nouns
    result = string.gsub(result, "%^[fmnp]", "")
    
    -- WORKAROUND: Final repair pass for any corruption that happened during processing
    result = string.gsub(result, "� убедогарт", "рубедогарт")
    result = string.gsub(result, "� убіноясенев", "рубіноясенев")  
    result = string.gsub(result, "� убед", "рубед")
    result = string.gsub(result, "� уб", "руб")
    
    if debugMode then
        d(string.format("ADJ-DEBUG: Final result: '%s'", result))
    end
    
    return result
end

-- Function to extract gender from a tagged noun
-- @param taggedNoun: noun with gender tag (e.g., "булава^f")
-- @return: gender code (m, f, n, p) or nil
function AdjectivesModule.ExtractGender(taggedNoun)
    if not taggedNoun then
        return nil
    end
    
    local gender = string.match(taggedNoun, "%^([fmnp])$")
    return gender
end

-- Function to remove gender tag from noun
-- @param taggedNoun: noun with gender tag
-- @return: noun without tag
function AdjectivesModule.RemoveGenderTag(taggedNoun)
    if not taggedNoun then
        return taggedNoun
    end
    
    return string.gsub(taggedNoun, "%^[fmnp]$", "")
end

-- Debug version of ProcessTaggedString with detailed logging
function AdjectivesModule.ProcessTaggedStringDebug(text)
    if not text or text == "" then
        return text
    end
    
    print(string.format("=== DEBUG ProcessTaggedString ==="))
    print(string.format("Input: '%s'", text))
    
    -- Pattern to find adjective^a or ^а followed by noun with gender tag
    local pattern_latin = "([^%s]+)%^a%s+([^%s]+)%^([fmnp])"
    local pattern_cyrillic = "([^%s]+)%^а%s+([^%s]+)%^([fmnp])"
    
    -- Try Latin 'a' pattern first
    local result = string.gsub(text, pattern_latin, function(adj, noun, gender)
        local declinedAdj = AdjectivesModule.DeclineAdjective(adj, gender)
        print(string.format("Latin pattern matched: adj='%s', noun='%s', gender='%s' → '%s'", 
            adj, noun, gender, declinedAdj))
        return declinedAdj .. " " .. noun
    end)
    
    print(string.format("After Latin pattern: '%s'", result))
    
    -- If we found a match, clean up and return
    if result ~= text then
        result = string.gsub(result, "%^[aаfmnp]", "")
        print(string.format("Cleaned up and returning: '%s'", result))
        return result
    end
    
    -- Try Cyrillic 'а' pattern
    result = string.gsub(text, pattern_cyrillic, function(adj, noun, gender)
        local declinedAdj = AdjectivesModule.DeclineAdjective(adj, gender)
        print(string.format("Cyrillic pattern matched: adj='%s', noun='%s', gender='%s' → '%s'", 
            adj, noun, gender, declinedAdj))
        return declinedAdj .. " " .. noun
    end)
    
    print(string.format("After Cyrillic pattern: '%s'", result))
    
    -- If we found a match, clean up and return
    if result ~= text then
        result = string.gsub(result, "%^[aаfmnp]", "")
        print(string.format("Cleaned up and returning: '%s'", result))
        return result
    end
    
    -- If no matches with ^a/^а tag, try patterns without tag
    print("No ^a/^а patterns matched, trying general processing...")
    if result == text then
        -- Look for gender tag at the end
        local beforeGender, gender, afterGender = string.match(text, "^(.-)%^([fmnp])(.*)$")
        print(string.format("Gender tag extraction: before='%s', gender='%s', after='%s'", 
            tostring(beforeGender), tostring(gender), tostring(afterGender)))
        
        if beforeGender and gender then
            -- Split text into words and process each word
            local words = {}
            print("Processing words:")
            for word in string.gmatch(beforeGender, "[^%s]+") do
                print(string.format("  Word: '%s'", word))
                -- Check if word is an adjective (ends with -ий or -ій) and decline it
                if string.match(word, "ий$") or string.match(word, "ій$") then
                    local declinedWord = AdjectivesModule.DeclineAdjective(word, gender)
                    print(string.format("    Adjective declined: '%s' → '%s' (gender: %s)", word, declinedWord, gender))
                    table.insert(words, declinedWord)
                else
                    print(string.format("    Not an adjective, keeping: '%s'", word))
                    table.insert(words, word)
                end
            end
            
            -- Reconstruct the string
            result = table.concat(words, " ")
            print(string.format("Reconstructed: '%s'", result))
            
            -- Add back the trailing text (if any)
            result = result .. afterGender
            print(string.format("With trailing text: '%s'", result))
            
            -- Remove all tags and return
            result = string.gsub(result, "%^[aаfmnp]", "")
            print(string.format("Final result: '%s'", result))
            return result
        else
            -- No gender tag found at all
            print("No gender tag found, returning unchanged")
            result = text
        end
    end
    
    -- Remove remaining tags
    result = string.gsub(result, "%^[aа]", "")
    result = string.gsub(result, "%^[fmnp]", "")
    print(string.format("After tag cleanup: '%s'", result))
    
    return result
end

-- Debug function for quick testing
function AdjectivesModule.DebugSpecificCases()
    local testCases = {
        "стальний поножі^p",
        "мідний намисто^n"
    }
    
    print("=== Debug Specific Problem Cases ===")
    for i, testCase in ipairs(testCases) do
        print(string.format("\n--- Test %d: '%s' ---", i, testCase))
        local result = AdjectivesModule.ProcessTaggedStringDebug(testCase)
        print(string.format("Final debug result: '%s'", result))
    end
    
    -- Test DeclineAdjective function directly
    print("\n=== Testing DeclineAdjective directly ===")
    local directTests = {
        {adj = "стальний", gender = "p", expected = "стальні"},
        {adj = "мідний", gender = "n", expected = "мідне"},
        {adj = "дубовий", gender = "f", expected = "дубова"},
        {adj = "синій", gender = "f", expected = "синя"}
    }
    
    for i, test in ipairs(directTests) do
        local result = AdjectivesModule.DeclineAdjective(test.adj, test.gender)
        local status = result == test.expected and "✓ PASS" or "✗ FAIL"
        print(string.format("%s Direct test %d: '%s' + '%s' → '%s' (expected: '%s')", 
            status, i, test.adj, test.gender, result, test.expected))
    end
end

-- Export the module
DovahMova_Adjectives = AdjectivesModule

return AdjectivesModule
