-- CharacterMarkdown - Ability Link Generators
-- UESP links for abilities and skills

local CM = CharacterMarkdown

-- =====================================================
-- ABILITY LINKS
-- =====================================================

-- Generate UESP URL for ability
local function GenerateAbilityURL(abilityName, abilityId)
    if not abilityName or abilityName == "[Empty]" or abilityName == "[Empty Slot]" then
        return nil
    end

    -- UESP format: https://en.uesp.net/wiki/Online:Ability_Name
    -- Strip rank suffixes (I, II, III, IV) from the end
    local urlName = abilityName
    urlName = urlName:gsub("%s+IV$", "") -- Remove " IV" at end
    urlName = urlName:gsub("%s+III$", "") -- Remove " III" at end
    urlName = urlName:gsub("%s+II$", "") -- Remove " II" at end
    urlName = urlName:gsub("%s+I$", "") -- Remove " I" at end

    -- Replace spaces with underscores, handle special characters
    urlName = urlName:gsub(" ", "_")
    -- Remove problematic characters
    urlName = urlName:gsub("[%(%)%[%]%{%}]", "")

    return "https://en.uesp.net/wiki/Online:" .. urlName
end

CM.links.GenerateAbilityURL = GenerateAbilityURL

-- Create markdown link for ability
local function CreateAbilityLink(abilityName, abilityId)
    if not abilityName or abilityName == "[Empty]" or abilityName == "[Empty Slot]" then
        return abilityName or "[Empty]"
    end

    -- Ensure abilityName is a string and sanitize it
    abilityName = tostring(abilityName)
    -- Remove all control characters (newlines, carriage returns, tabs) that could break URLs
    abilityName = abilityName:gsub("[\r\n\t]", "")
    -- Trim whitespace
    abilityName = abilityName:gsub("^%s+", ""):gsub("%s+$", "")
    -- Normalize multiple spaces to single space
    abilityName = abilityName:gsub("%s+", " ")
    if abilityName == "" then
        return "[Unknown]"
    end

    -- Check settings: if enableAbilityLinks is explicitly false, return plain text
    -- Use CM.GetSettings() which merges with defaults to ensure no nil values
    local settings = CM.GetSettings and CM.GetSettings() or {}
    if settings and settings.enableAbilityLinks == false then
        return abilityName
    end

    local url = GenerateAbilityURL(abilityName, abilityId)

    -- Ensure URL is valid before creating link
    if url and url ~= "" then
        -- Validate URL format to prevent truncation - ensure it starts with https:// and is complete
        if url:find("^https://") and url:find("en.uesp.net/wiki/Online:") then
            -- Ensure URL is complete (ends with proper format or ability name)
            if url:len() > 35 then -- Minimum URL length check (https://en.uesp.net/wiki/Online: + at least 1 char)
                local linkText = "[" .. abilityName .. "](" .. url .. ")"
                -- Basic validation: ensure we have brackets and parentheses in the right places
                -- Also ensure the URL is complete (contains closing parenthesis)
                if
                    linkText:find("%[")
                    and linkText:find("%]%(")
                    and linkText:find("%)$")
                    and linkText:find("https://en.uesp.net/wiki/Online:")
                then
                    return linkText
                end
            end
        end
    end

    -- Fallback: return plain text if link generation fails
    return abilityName
end

CM.links.CreateAbilityLink = CreateAbilityLink
