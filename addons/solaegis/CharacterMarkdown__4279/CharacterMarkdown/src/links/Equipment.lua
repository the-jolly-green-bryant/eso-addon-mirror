-- CharacterMarkdown - Equipment Link Generators
-- UESP links for sets and equipment

local CM = CharacterMarkdown

-- =====================================================
-- SET LINKS
-- =====================================================

-- Generate UESP URL for set
local function GenerateSetURL(setName)
    if not setName or setName == "-" or setName == "" then
        return nil
    end

    -- UESP format: https://en.uesp.net/wiki/Online:Set_Name_Set
    local urlName = setName:gsub(" ", "_")
    urlName = urlName:gsub("[%(%)%[%]%{%}]", "")
    urlName = urlName:gsub("_Set$", "")

    return "https://en.uesp.net/wiki/Online:" .. urlName .. "_Set"
end

CM.links.GenerateSetURL = GenerateSetURL

-- Create markdown link for set
local function CreateSetLink(setName)
    if not setName or setName == "-" or setName == "" then
        return setName or "-"
    end

    -- Check settings: if external links are disabled, return plain text
    -- Check both enableSetLinks and enableAbilityLinks (they're toggled together in UI)
    -- Use CM.GetSettings() which merges with defaults to ensure no nil values
    local settings = CM.GetSettings and CM.GetSettings() or {}
    if settings then
        -- If either setting is explicitly false, disable links
        if settings.enableSetLinks == false or settings.enableAbilityLinks == false then
            return setName
        end
    end

    local url = GenerateSetURL(setName)

    if url then
        -- Only add " Set" suffix if it's not already there
        local displayName = setName
        if not displayName:match(" Set$") then
            displayName = displayName .. " Set"
        end
        return "[" .. displayName .. "](" .. url .. ")"
    else
        return setName
    end
end

CM.links.CreateSetLink = CreateSetLink
