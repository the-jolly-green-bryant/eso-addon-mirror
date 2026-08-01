-- ============================================================================
-- Companion Wardrobe
-- Loadout Sorting and Filtering
--
-- Responsibilities:
-- - Manage loadout sort modes.
-- - Filter visible loadouts by favorite/normal state.
-- - Produce sorted loadout index lists for the main window.
-- - Provide localized sort mode labels.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

MHCWL.SORT_MODE_SLOT = "slot"
MHCWL.SORT_MODE_NAME = "name"

function MHCWL.GetFavoriteLoadoutSortMode()
    return MHCWL.saved
        and MHCWL.saved.settings
        and MHCWL.saved.settings.favoriteLoadoutSortMode
        or MHCWL.SORT_MODE_SLOT
end

function MHCWL.GetLoadoutSortMode()
    return MHCWL.saved
        and MHCWL.saved.settings
        and MHCWL.saved.settings.loadoutSortMode
        or MHCWL.SORT_MODE_SLOT
end

function MHCWL.GetSortedLoadoutIndexes(companionData)
    local indexes = {}

    if not companionData then return indexes end

    local count = MHCWL.GetSetupCount(companionData)

    for i = 1, count do
        table.insert(indexes, i)
    end

    local favoriteSortMode = MHCWL.GetFavoriteLoadoutSortMode()
    local normalSortMode = MHCWL.GetLoadoutSortMode()

    table.sort(indexes, function(a, b)
        local setupA = companionData.setups[a]
        local setupB = companionData.setups[b]

        local favoriteA = setupA and setupA.isFavorite == true
        local favoriteB = setupB and setupB.isFavorite == true

        if favoriteA ~= favoriteB then
            return favoriteA
        end

        local activeSortMode =
            favoriteA
            and favoriteSortMode
            or normalSortMode

        if activeSortMode == MHCWL.SORT_MODE_NAME then
            local nameA = zo_strlower(tostring(setupA and setupA.name or ""))
            local nameB = zo_strlower(tostring(setupB and setupB.name or ""))

            if nameA ~= nameB then
                return nameA < nameB
            end
        end

        return a < b
    end)

    return indexes
end

MHCWL.LOADOUT_SORT_MODES = {
    {
        favorite = MHCWL.SORT_MODE_SLOT,
        normal = MHCWL.SORT_MODE_SLOT,
        labelString = "MHCWL_SORT_MODE_SLOT_ORDER",
    },
    {
        favorite = MHCWL.SORT_MODE_NAME,
        normal = MHCWL.SORT_MODE_NAME,
        labelString = "MHCWL_SORT_MODE_ALL_AZ",
    },
    {
        favorite = MHCWL.SORT_MODE_NAME,
        normal = MHCWL.SORT_MODE_SLOT,
        labelString = "MHCWL_SORT_MODE_FAVORITES_AZ",
    },
    {
        favorite = MHCWL.SORT_MODE_SLOT,
        normal = MHCWL.SORT_MODE_NAME,
        labelString = "MHCWL_SORT_MODE_FAVORITES_SLOT",
    },
}

function MHCWL.GetCurrentLoadoutSortModeIndex()
    local favoriteMode = MHCWL.GetFavoriteLoadoutSortMode()
    local normalMode = MHCWL.GetLoadoutSortMode()

    for index, mode in ipairs(MHCWL.LOADOUT_SORT_MODES) do
        if mode.favorite == favoriteMode
        and mode.normal == normalMode then
            return index
        end
    end

    return 1
end

function MHCWL.GetCurrentLoadoutSortMode()
    return MHCWL.LOADOUT_SORT_MODES[MHCWL.GetCurrentLoadoutSortModeIndex()]
end

function MHCWL.CycleLoadoutSortMode()
    local currentIndex = MHCWL.GetCurrentLoadoutSortModeIndex()
    local nextIndex = currentIndex + 1

    if nextIndex > #MHCWL.LOADOUT_SORT_MODES then
        nextIndex = 1
    end

    local mode = MHCWL.LOADOUT_SORT_MODES[nextIndex]

    MHCWL.saved.settings.favoriteLoadoutSortMode = mode.favorite
    MHCWL.saved.settings.loadoutSortMode = mode.normal

    MHCWL.Notify(GetString(MHCWL_SORTING_PREFIX) .. MHCWL.GetLoadoutSortModeLabel(mode))

    if MHCWL.window then
        MHCWL.RebuildWindowContent()
    end
end

function MHCWL.ShouldShowLoadout(setup)
    if not setup then return false end

    if setup.isFavorite then
        return MHCWL.saved.settings.showFavoriteLoadouts ~= false
    end

    return MHCWL.saved.settings.showNormalLoadouts ~= false
end

function MHCWL.GetVisibleSortedLoadoutIndexes(companionData)
    local sortedIndexes = MHCWL.GetSortedLoadoutIndexes(companionData)
    local visibleIndexes = {}

    for _, index in ipairs(sortedIndexes) do
        local setup = companionData.setups[index]

        if MHCWL.ShouldShowLoadout(setup) then
            table.insert(visibleIndexes, index)
        end
    end

    return visibleIndexes
end