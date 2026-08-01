-- CharacterMarkdown - Companion Link Generators
-- UESP links for companions

local CM = CharacterMarkdown

-- =====================================================
-- COMPANION LINKS
-- =====================================================

local function GenerateCompanionURL(companionName)
    if
        not companionName
        or companionName == ""
        or companionName == "Unknown"
        or companionName == "Unknown Companion"
    then
        return nil
    end

    -- Replace spaces with underscores
    local urlName = companionName:gsub(" ", "_")

    -- Handle special characters (keep apostrophes and hyphens as-is, UESP accepts them)

    return "https://en.uesp.net/wiki/Online:" .. urlName
end

CM.links.GenerateCompanionURL = GenerateCompanionURL

local function CreateCompanionLink(companionName)
    if
        not companionName
        or companionName == ""
        or companionName == "Unknown"
        or companionName == "Unknown Companion"
    then
        return companionName or "Unknown"
    end

    -- Check settings: if enableAbilityLinks is explicitly false, return plain text
    -- Use CM.GetSettings() which merges with defaults to ensure no nil values
    local settings = CM.GetSettings and CM.GetSettings() or {}
    if settings and settings.enableAbilityLinks == false then
        return companionName
    end

    local url = GenerateCompanionURL(companionName)
    if url then
        return "[" .. companionName .. "](" .. url .. ")"
    else
        return companionName
    end
end

CM.links.CreateCompanionLink = CreateCompanionLink
