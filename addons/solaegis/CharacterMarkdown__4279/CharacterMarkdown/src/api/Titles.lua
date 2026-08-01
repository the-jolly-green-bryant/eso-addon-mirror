-- CharacterMarkdown - API Layer - Titles
-- Abstraction for character titles

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.titles = {}

local api = CM.api.titles

-- =====================================================
-- CACHING
-- =====================================================

local _titleCache = {}

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetCurrentTitle()
    if CM.utils and CM.utils.GetPlayerTitle then
        return CM.utils.GetPlayerTitle() or ""
    end

    local title = CM.SafeCall(GetUnitTitle, "player")
    return title or ""
end

function api.GetCurrentTitleIndex()
    return CM.SafeCall(GetCurrentTitleIndex) or 0
end

function api.GetNumTitles()
    return CM.SafeCall(GetNumTitles) or 0
end

function api.GetTitle(titleIndex)
    if _titleCache[titleIndex] then
        return _titleCache[titleIndex]
    end

    local name = CM.SafeCall(GetTitle, titleIndex) or ""
    _titleCache[titleIndex] = name
    return name
end

function api.ClearCache()
    _titleCache = {}
end

function api.GetAllTitles()
    local titles = {}
    local numOwned = api.GetNumTitles()
    local currentIndex = api.GetCurrentTitleIndex()

    for index = 1, numOwned do
        local name = api.GetTitle(index)
        if name and name ~= "" then
            table.insert(titles, {
                id = index,
                name = name,
                owned = true,
                isCurrent = (index == currentIndex),
            })
        end
    end

    table.sort(titles, function(a, b)
        return (a.name or "") < (b.name or "")
    end)

    return titles
end

CM.DebugPrint("API", "Titles API module loaded")
