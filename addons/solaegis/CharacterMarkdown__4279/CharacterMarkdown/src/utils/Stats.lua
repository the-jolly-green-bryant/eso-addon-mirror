-- CharacterMarkdown - Stats Utilities
-- Safe stat retrieval with error handling

local CM = CharacterMarkdown

-- =====================================================
-- SAFE STAT RETRIEVAL
-- =====================================================

-- Safely get player stat with default value on error
local function SafeGetPlayerStat(statType, defaultValue)
    defaultValue = defaultValue or 0
    if not statType then
        return defaultValue
    end
    local success, value = pcall(function()
        return GetPlayerStat(statType)
    end)
    if success and value ~= nil then
        return value
    end
    return defaultValue
end

CM.utils.SafeGetPlayerStat = SafeGetPlayerStat

-- =====================================================
-- PLAYER TITLE RETRIEVAL
-- =====================================================

-- Safely get player title, checking custom title first, then API
local function GetPlayerTitle()
    -- Check for custom title first - try CM.charData, then CharacterMarkdownData
    local customTitle = ""
    if CM.charData and CM.charData.customTitle and CM.charData.customTitle ~= "" then
        customTitle = CM.charData.customTitle
    elseif CharacterMarkdownData and CharacterMarkdownData.customTitle and CharacterMarkdownData.customTitle ~= "" then
        customTitle = CharacterMarkdownData.customTitle
        -- Sync to CM.charData if it exists (for consistency)
        if CM.charData then
            CM.charData.customTitle = customTitle
        end
    end

    if customTitle and customTitle ~= "" then
        return customTitle
    end

    -- Use GetUnitTitle("player") to get the active title directly
    -- Note: GetUnitTitle may be a newer API function
    local GetUnitTitleFunc = rawget(_G, "GetUnitTitle")
    if GetUnitTitleFunc and type(GetUnitTitleFunc) == "function" then
        local success, titleName = pcall(GetUnitTitleFunc, "player")
        if success and titleName and titleName ~= "" then
            return titleName
        end
    end

    -- Fallback to empty string if API call fails
    return ""
end

CM.utils.GetPlayerTitle = GetPlayerTitle
