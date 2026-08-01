-- CharacterMarkdown - Outfit Styles Collector
-- Collects unlocked outfit styles from the Collectibles system

local CM = CharacterMarkdown

local function CollectStylesData()
    local settings = CM.GetSettings()
    if not settings.includeStyles then
        return { count = 0, categories = {} }
    end

    local collectiblesApi = CM.api.collectibles
    if not collectiblesApi then
        return { count = 0, categories = {} }
    end

    -- Outfit Styles is category type COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE
    local styles = collectiblesApi.GetUnlockedCollectibles(COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE)

    -- Group by subcategory if detailed view is requested
    -- Note: GetUnlockedCollectibles currently returns a flat list.
    -- To group them, we'd need to iterate categories manually.

    local categories = {}
    local totalCount = styles.count or 0

    if settings.showStylesDetailed then
        -- For now, we'll keep the flat list as categories.all
        categories.all = styles.list
    end

    local result = {
        count = totalCount,
        categories = categories,
        summary = {
            totalUnlocked = totalCount,
        },
    }

    return result
end

CM.collectors.CollectStylesData = CollectStylesData

CM.DebugPrint("COLLECTOR", "Styles collector module loaded")
