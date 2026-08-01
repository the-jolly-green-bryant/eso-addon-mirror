-- CharacterMarkdown - API Layer - Lore Library
-- Abstraction for lore books and collections

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.lore = {}

local api = CM.api.lore

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetNumCategories()
    return CM.SafeCall(GetNumLoreCategories) or 0
end

function api.GetCategoryInfo(categoryIndex)
    local success, name, numCollections, categoryId = CM.SafeCallMulti(GetLoreCategoryInfo, categoryIndex)
    if success then
        return {
            name = name,
            numCollections = numCollections,
            id = categoryId,
        }
    end
    return nil
end

function api.GetCollectionInfo(categoryIndex, collectionIndex)
    local success, name, description, numKnownBooks, totalBooks, hidden, _, collectionId =
        CM.SafeCallMulti(GetLoreCollectionInfo, categoryIndex, collectionIndex)

    if success then
        return {
            name = name,
            description = description,
            numKnownBooks = numKnownBooks,
            totalBooks = totalBooks,
            hidden = hidden,
            id = collectionId,
        }
    end
    return nil
end

function api.GetBookInfo(categoryIndex, collectionIndex, bookIndex)
    local success, title, _, known, bookId =
        CM.SafeCallMulti(GetLoreBookInfo, categoryIndex, collectionIndex, bookIndex)

    if success then
        return {
            title = title,
            known = known,
            id = bookId,
        }
    end
    return nil
end

function api.FindCategoryByName(targetName)
    local numCategories = api.GetNumCategories()
    for i = 1, numCategories do
        local info = api.GetCategoryInfo(i)
        if info and info.name == targetName then
            return i, info
        end
    end
    return nil
end

CM.DebugPrint("API", "Lore API module loaded")
